local QBCore = exports['qb-core']:GetCoreObject()

-- ============================================================
-- Utils
-- ============================================================
local function nowMs()
    return os.time() * 1000
end

local function minutesToMs(m)
    return (m or 0) * 60 * 1000
end

local function getFullName(Player)
    local ci = Player.PlayerData.charinfo or {}
    return (ci.firstname or "Unknown") .. " " .. (ci.lastname or "")
end

local function stashId(motelKey, roomId)
    return ("thd_motel_%s_%s"):format(motelKey, roomId)
end

-- Kapı kilitleme: qb-doorlock sürüm farklarını tolere edecek şekilde
local function lockDoorsForRoom(motelKey, roomId)
    local motel = Config.Motels[motelKey]
    if not motel or not motel.rooms or not motel.rooms[roomId] then return end

    local room = motel.rooms[roomId]
    local doorNames = room.doorNames or {}
    for _, doorName in ipairs(doorNames) do
        -- ox_doorlock entegrasyonu
        local door = exports.ox_doorlock:getDoorFromName(doorName)
        if door then
            exports.ox_doorlock:setDoorState(door.id, 1) -- 1: Kilitli
        else
            -- Eğer doorName zaten ID ise direkt gönder
            exports.ox_doorlock:setDoorState(doorName, 1)
        end
    end
end

-- ============================================================
-- DB Tables
-- ============================================================
CreateThread(function()
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS thd_motel (
            id INT AUTO_INCREMENT PRIMARY KEY,
            citizenid VARCHAR(50) NOT NULL,
            motel VARCHAR(50) NOT NULL,
            room INT NOT NULL,
            expires_at BIGINT NOT NULL,
            UNIQUE KEY uniq_rental (motel, room)
        );
    ]])

    MySQL.query([[
        CREATE TABLE IF NOT EXISTS motel_keys (
            id INT AUTO_INCREMENT PRIMARY KEY,
            citizenid VARCHAR(50) NOT NULL,
            motel VARCHAR(50) NOT NULL,
            room INT NOT NULL,
            expires_at BIGINT NOT NULL,
            owner_citizenid VARCHAR(50) NOT NULL,
            UNIQUE KEY uniq_key (citizenid, motel, room)
        );
    ]])
end)

-- ============================================================
-- STASH Register (optional)
-- ============================================================
CreateThread(function()
    Wait(500)
    for motelKey, motel in pairs(Config.Motels) do
        for roomId, room in pairs(motel.rooms or {}) do
            if room.stash and room.stash.coords then
                local sid = stashId(motelKey, roomId)
                local slots = (room.stash.slots) or (Config.DefaultStash and Config.DefaultStash.slots) or 40
                local weight = (room.stash.weight) or (Config.DefaultStash and Config.DefaultStash.weight) or 60000
                local label = ("%s - Oda %s Stash"):format(motel.label or motelKey, room.label or roomId)
                exports.ox_inventory:RegisterStash(sid, label, slots, weight, false)
            end
        end
    end
end)

-- ============================================================
-- Key metadata
-- ============================================================
local function buildKeyMetadata(ownerPlayer, holderPlayer, motelKey, roomId, expires)
    local motel = Config.Motels[motelKey]
    local room = motel and motel.rooms and motel.rooms[roomId]
    local roomNumber = room and room.label or tostring(roomId)

    local ownerName  = getFullName(ownerPlayer)
    local holderName = getFullName(holderPlayer)

    return {
        motel = motelKey,
        motelKey = motelKey,

        room = roomId,
        room_id = roomId,
        room_number = roomNumber,

        owner_name = ownerName,
        owner_citizenid = ownerPlayer.PlayerData.citizenid,

        holder_name = holderName,
        holder_citizenid = holderPlayer.PlayerData.citizenid,

        expires = expires,
        is_copy = (ownerPlayer.PlayerData.citizenid ~= holderPlayer.PlayerData.citizenid) or nil,

        label = ("Motel Anahtarı - Oda %s"):format(roomNumber),
        description = ("🏨 Oda: %s\n👤 Sahibi: %s\n🧍 Taşıyan: %s"):format(roomNumber, ownerName, holderName)
    }
end

-- ============================================================
-- Access check helpers
-- ============================================================
local function hasAccessCitizen(citizenid, motelKey, roomId)
    return MySQL.single.await([[
        SELECT id FROM motel_keys
        WHERE citizenid = ? AND motel = ? AND room = ? AND expires_at > ?
        LIMIT 1
    ]], { citizenid, motelKey, roomId, nowMs() }) ~= nil
end

QBCore.Functions.CreateCallback('thd_motel:server:hasAccess', function(source, cb, motelKey, roomId)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb(false) end
    cb(hasAccessCitizen(Player.PlayerData.citizenid, tostring(motelKey), tonumber(roomId)))
end)

-- ============================================================
-- Useable item (QB)
-- ============================================================
QBCore.Functions.CreateUseableItem("motel_key", function(source, item)
    TriggerClientEvent("QBCore:Client:UseMotelKey", source, item)
end)

-- ============================================================
-- Wardrobe (illenium-appearance) - server opens it
-- ============================================================
RegisterNetEvent('thd_motel:server:openWardrobe', function(motelKey, roomId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    motelKey = tostring(motelKey)
    roomId = tonumber(roomId)

    if not hasAccessCitizen(Player.PlayerData.citizenid, motelKey, roomId) then
        return TriggerClientEvent('QBCore:Notify', src, 'Bu oda için erişimin yok.', 'error')
    end

    TriggerClientEvent("illenium-appearance:client:openOutfitMenu", src)
end)

-- ============================================================
-- Stash open (optional)
-- ============================================================
RegisterNetEvent('thd_motel:server:openStash', function(motelKey, roomId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    motelKey = tostring(motelKey)
    roomId = tonumber(roomId)

    if not hasAccessCitizen(Player.PlayerData.citizenid, motelKey, roomId) then
        return TriggerClientEvent('QBCore:Notify', src, 'Bu oda için erişimin yok.', 'error')
    end

    TriggerClientEvent('thd_motel:client:openStash', src, stashId(motelKey, roomId))
end)

-- ============================================================
-- Inventory key removal (online + offline players.inventory JSON)
-- ============================================================
local function keyMatchesRoom(item, motelKey, roomId)
    if not item or item.name ~= Config.KeyItem then return false end
    local md = item.metadata
    if not md then return false end

    local mk = md.motel or md.motelKey
    local rid = tonumber(md.room_id or md.room)

    return (mk == motelKey) and (rid == tonumber(roomId))
end

local function removeRoomKeysOnline(src, motelKey, roomId)
    local slots = exports.ox_inventory:Search(src, 'slots', Config.KeyItem)
    if not slots then return 0 end

    local removed = 0
    for slot, item in pairs(slots) do
        local md = item.metadata
        if md then
            local mk = md.motel or md.motelKey
            local rid = tonumber(md.room_id or md.room)
            if mk == motelKey and rid == tonumber(roomId) then
                exports.ox_inventory:RemoveItem(src, Config.KeyItem, item.count or 1, md, slot)
                removed = removed + 1
            end
        end
    end

    return removed
end

local function removeRoomKeysOfflineByCitizenId(citizenid, motelKey, roomId)
    local inv = MySQL.scalar.await('SELECT inventory FROM players WHERE citizenid = ? LIMIT 1', { citizenid })
    if not inv or inv == '' then return 0 end

    local ok, items = pcall(json.decode, inv)
    if not ok or type(items) ~= 'table' then
        return 0
    end

    local newItems = {}
    local removed = 0

    for _, it in ipairs(items) do
        if keyMatchesRoom(it, motelKey, roomId) then
            removed = removed + 1
        else
            newItems[#newItems + 1] = it
        end
    end

    if removed > 0 then
        MySQL.update.await('UPDATE players SET inventory = ? WHERE citizenid = ?', { json.encode(newItems), citizenid })
    end

    return removed
end

-- ============================================================
-- RENT
-- ============================================================
RegisterNetEvent('thd_motel:server:rentRoom', function(motelKey, roomId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    motelKey = tostring(motelKey)
    roomId = tonumber(roomId)

    local motel = Config.Motels[motelKey]
    if not motel or not motel.rooms or not motel.rooms[roomId] then
        return TriggerClientEvent('QBCore:Notify', src, 'Geçersiz oda.', 'error')
    end

    local exists = MySQL.single.await([[
        SELECT id FROM thd_motel
        WHERE motel = ? AND room = ? AND expires_at > ?
        LIMIT 1
    ]], { motelKey, roomId, nowMs() })

    if exists then
        return TriggerClientEvent('QBCore:Notify', src, 'Bu oda şu an kirada.', 'error')
    end

    local price = motel.rentPrice or 0
    local paid = Player.Functions.RemoveMoney('cash', price, 'motel-rent')
    if not paid then paid = Player.Functions.RemoveMoney('bank', price, 'motel-rent') end
    if not paid then
        return TriggerClientEvent('QBCore:Notify', src, 'Yeterli paran yok.', 'error')
    end

    local expires = nowMs() + minutesToMs(motel.rentDurationMinutes or 60)

    MySQL.insert.await([[
        INSERT INTO thd_motel (citizenid, motel, room, expires_at)
        VALUES (?, ?, ?, ?)
    ]], { Player.PlayerData.citizenid, motelKey, roomId, expires })

    MySQL.insert.await([[
        INSERT INTO motel_keys (citizenid, motel, room, expires_at, owner_citizenid)
        VALUES (?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE expires_at = VALUES(expires_at), owner_citizenid = VALUES(owner_citizenid)
    ]], { Player.PlayerData.citizenid, motelKey, roomId, expires, Player.PlayerData.citizenid })

    local meta = buildKeyMetadata(Player, Player, motelKey, roomId, expires)
    exports.ox_inventory:AddItem(src, Config.KeyItem, 1, meta)

    TriggerClientEvent('QBCore:Notify', src, ('Oda kiralandı: %s'):format(meta.label), 'success')
end)

-- ============================================================
-- EXTEND (owner)
-- ============================================================
RegisterNetEvent('thd_motel:server:extendRental', function(motelKey)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    motelKey = tostring(motelKey)
    local motel = Config.Motels[motelKey]
    if not motel then return end

    local now = nowMs()

    local row = MySQL.single.await([[
        SELECT id, room, expires_at FROM thd_motel
        WHERE citizenid = ? AND motel = ? AND expires_at > ?
        ORDER BY expires_at DESC LIMIT 1
    ]], { Player.PlayerData.citizenid, motelKey, now })

    if not row then
        return TriggerClientEvent('QBCore:Notify', src, 'Aktif kiralaman yok (veya sahibi değilsin).', 'error')
    end

    local price = motel.extendPrice or motel.rentPrice or 0
    local paid = Player.Functions.RemoveMoney('bank', price, 'motel-extend')
    if not paid then
        return TriggerClientEvent('QBCore:Notify', src, 'Banka bakiyen yetersiz.', 'error')
    end


    local extra = minutesToMs(motel.rentDurationMinutes or 60)
    local newExp = tonumber(row.expires_at) + extra

    MySQL.update.await('UPDATE thd_motel SET expires_at = ? WHERE id = ?', { newExp, row.id })

    MySQL.update.await([[
        UPDATE motel_keys SET expires_at = ?
        WHERE motel = ? AND room = ? AND expires_at > ?
    ]], { newExp, motelKey, tonumber(row.room), now })

    TriggerClientEvent('QBCore:Notify', src, 'Kiralama süresi uzatıldı (tüm anahtarlar).', 'success')
end)

-- ============================================================
-- CANCEL (owner) + remove keys online/offline + lock door
-- ============================================================
RegisterNetEvent('thd_motel:server:cancelRental', function(motelKey)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    motelKey = tostring(motelKey)
    local now = nowMs()

    local row = MySQL.single.await([[
        SELECT id, room FROM thd_motel
        WHERE citizenid = ? AND motel = ? AND expires_at > ?
        ORDER BY expires_at DESC LIMIT 1
    ]], { Player.PlayerData.citizenid, motelKey, now })

    if not row then
        return TriggerClientEvent('QBCore:Notify', src, 'Aktif kiralaman yok (veya sahibi değilsin).', 'error')
    end

    local roomId = tonumber(row.room)

    -- Bu oda için erişimi olan herkes (silmeden önce)
    local keyHolders = MySQL.query.await([[
        SELECT citizenid FROM motel_keys
        WHERE motel = ? AND room = ?
    ]], { motelKey, roomId }) or {}

    -- DB sil
    MySQL.query.await('DELETE FROM thd_motel WHERE id = ?', { row.id })
    MySQL.query.await('DELETE FROM motel_keys WHERE motel = ? AND room = ?', { motelKey, roomId })

    -- Kapıyı kilitle
    lockDoorsForRoom(motelKey, roomId)

    TriggerClientEvent('QBCore:Notify', src, 'Kiralama iptal edildi (anahtarlar silindi).', 'success')

    -- Online + Offline anahtar temizliği
    for _, r in ipairs(keyHolders) do
        local cid = r.citizenid
        local targetPlayer = QBCore.Functions.GetPlayerByCitizenId(cid)

        if targetPlayer then
            local ps = targetPlayer.PlayerData.source
            local removed = removeRoomKeysOnline(ps, motelKey, roomId)
            if removed > 0 then
                TriggerClientEvent('QBCore:Notify', ps, 'Motel anahtarın iptal edildi (oda kapandı).', 'error')
            end
        else
            removeRoomKeysOfflineByCitizenId(cid, motelKey, roomId)
        end
    end
end)

RegisterNetEvent('thd_motel:server:toggleDoor', function(motelKey, roomId, doorId, newState)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    -- Access check logic copied from the callback
    local now = nowMs()
    local row = MySQL.single.await([[
        SELECT citizenid FROM thd_motel
        WHERE motel = ? AND room = ? AND expires_at > ?
    ]], { motelKey, roomId, now })

    local hasAccess = false
    if row and row.citizenid == Player.PlayerData.citizenid then
        hasAccess = true
    else
        local keyRow = MySQL.single.await([[
            SELECT citizenid FROM motel_keys
            WHERE citizenid = ? AND motel = ? AND room = ? AND expires_at > ?
        ]], { Player.PlayerData.citizenid, motelKey, roomId, now })
        if keyRow then hasAccess = true end
    end

    if hasAccess then
        exports.ox_doorlock:setDoorState(doorId, newState)
        
        if newState == 0 then
            TriggerClientEvent('InteractSound_SV:PlayWithinDistance', src, 5.0, 'key_unlock', 0.6)
            TriggerClientEvent('QBCore:Notify', src, 'Kapı açıldı.', 'success')
        else
            TriggerClientEvent('InteractSound_SV:PlayWithinDistance', src, 5.0, 'door_lock', 0.6)
            TriggerClientEvent('QBCore:Notify', src, 'Kapı kilitlendi.', 'error')
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'Erişim yetkin yok.', 'error')
    end
end)

-- ============================================================
-- COPY KEY (owner -> target)
-- ============================================================
RegisterNetEvent('thd_motel:server:copyKeyToPlayer', function(motelKey, targetSrc)
    local src = source
    local Owner = QBCore.Functions.GetPlayer(src)
    if not Owner then return end

    motelKey = tostring(motelKey)
    targetSrc = tonumber(targetSrc)

    local Target = targetSrc and QBCore.Functions.GetPlayer(targetSrc) or nil
    if not Target then
        return TriggerClientEvent('QBCore:Notify', src, 'Hedef oyuncu bulunamadı.', 'error')
    end

    local motel = Config.Motels[motelKey]
    if not motel then return end

    local now = nowMs()

    local rental = MySQL.single.await([[
        SELECT room, expires_at FROM thd_motel
        WHERE citizenid = ? AND motel = ? AND expires_at > ?
        ORDER BY expires_at DESC LIMIT 1
    ]], { Owner.PlayerData.citizenid, motelKey, now })

    if not rental then
        return TriggerClientEvent('QBCore:Notify', src, 'Aktif kiralaman yok (veya sahibi değilsin).', 'error')
    end

    local roomId = tonumber(rental.room)
    local expires = tonumber(rental.expires_at)

    local price = motel.copyKeyPrice or 0
    local paid = Owner.Functions.RemoveMoney('cash', price, 'motel-key-copy')
    if not paid then paid = Owner.Functions.RemoveMoney('bank', price, 'motel-key-copy') end
    if not paid then
        return TriggerClientEvent('QBCore:Notify', src, 'Yeterli paran yok (kopya ücreti).', 'error')
    end

    MySQL.insert.await([[
        INSERT INTO motel_keys (citizenid, motel, room, expires_at, owner_citizenid)
        VALUES (?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE expires_at = VALUES(expires_at), owner_citizenid = VALUES(owner_citizenid)
    ]], { Target.PlayerData.citizenid, motelKey, roomId, expires, Owner.PlayerData.citizenid })

    local meta = buildKeyMetadata(Owner, Target, motelKey, roomId, expires)
    exports.ox_inventory:AddItem(targetSrc, Config.KeyItem, 1, meta)

    TriggerClientEvent('QBCore:Notify', src, ('Anahtar kopyalandı: %s'):format(meta.label), 'success')
    TriggerClientEvent('QBCore:Notify', targetSrc, ('Sana bir motel anahtarı verildi: %s'):format(meta.label), 'success')
end)

-- ============================================================
-- EXPIRED CLEANUP + door lock + remove keys online/offline
-- ============================================================
local CLEANUP_INTERVAL_MS = 5 * 60 * 1000 -- 5 dk

local function cleanupExpiredRentals()
    local now = nowMs()

    local expired = MySQL.query.await([[
        SELECT motel, room FROM thd_motel
        WHERE expires_at <= ?
    ]], { now }) or {}

    if #expired == 0 then return end

    for _, e in ipairs(expired) do
        local motelKey = tostring(e.motel)
        local roomId = tonumber(e.room)

        local keyHolders = MySQL.query.await([[
            SELECT citizenid FROM motel_keys
            WHERE motel = ? AND room = ?
        ]], { motelKey, roomId }) or {}

        -- önce anahtarları envanterlerden temizle
        for _, r in ipairs(keyHolders) do
            local cid = r.citizenid
            local targetPlayer = QBCore.Functions.GetPlayerByCitizenId(cid)

            if targetPlayer then
                local ps = targetPlayer.PlayerData.source
                local removed = removeRoomKeysOnline(ps, motelKey, roomId)
                if removed > 0 then
                    TriggerClientEvent('QBCore:Notify', ps, 'Motel kiralamanın süresi doldu. Anahtarın iptal edildi.', 'error')
                end
            else
                removeRoomKeysOfflineByCitizenId(cid, motelKey, roomId)
            end
        end

        -- kapıyı kilitle
        lockDoorsForRoom(motelKey, roomId)

        -- sonra db temizle
        MySQL.query.await('DELETE FROM motel_keys WHERE motel = ? AND room = ?', { motelKey, roomId })
        MySQL.query.await('DELETE FROM thd_motel WHERE motel = ? AND room = ?', { motelKey, roomId })
    end
end

CreateThread(function()
    Wait(5000)
    while true do
        local ok, err = pcall(cleanupExpiredRentals)
        if not ok then
            print(('[thd_motel] cleanupExpiredRentals error: %s'):format(err))
        end
        Wait(CLEANUP_INTERVAL_MS)
    end
end)
