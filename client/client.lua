local QBCore = exports['qb-core']:GetCoreObject()

local AccessCache = {} -- AccessCache[motelKey][roomId] = true/false

local function setAccess(motelKey, roomId, value)
    AccessCache[motelKey] = AccessCache[motelKey] or {}
    AccessCache[motelKey][roomId] = value and true or false
end

local function getAccess(motelKey, roomId)
    return AccessCache[motelKey] and AccessCache[motelKey][roomId] == true
end

-- Access cache güncelle (periyodik)
CreateThread(function()
    Wait(1500) -- spawn sonrası
    while true do
        for motelKey, motel in pairs(Config.Motels) do
            for roomId, _ in pairs(motel.rooms or {}) do
                QBCore.Functions.TriggerCallback('thd_motel:server:hasAccess', function(ok)
                    setAccess(motelKey, roomId, ok)
                end, motelKey, roomId)
                Wait(50) -- spam azalt
            end
        end
        Wait(15000) -- 15 sn'de bir güncelle (istersen 5sn yap)
    end
end)


local function loadModel(model)
  if type(model) == "string" then model = joaat(model) end
  RequestModel(model)
  while not HasModelLoaded(model) do Wait(0) end
  return model
end

local function playKeySound()
    TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 5.0, 'keydoords', 0.6)
end

local function playLockedSound()
    TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 5.0, 'keydoors', 0.6)
end

local function playKeyAnim()
    local ped = PlayerPedId()
    RequestAnimDict("anim@heists@keycard@")
    while not HasAnimDictLoaded("anim@heists@keycard@") do Wait(10) end
    TaskPlayAnim(ped, "anim@heists@keycard@", "exit", 8.0, 1.0, 1200, 48, 0, false, false, false)
end


local function openWardrobe()
  if GetResourceState('illenium-appearance') == 'started' then
    TriggerEvent('illenium-appearance:client:openOutfitMenu')
  else
    QBCore.Functions.Notify('illenium-appearance çalışmıyor.', 'error')
  end
end

RegisterNetEvent('thd_motel:client:openStash', function(stashName)
  exports.ox_inventory:openInventory('stash', stashName)
end)

local function getDoorNameForRoom(motelKey, roomId)
  local motel = Config.Motels[motelKey]
  if not motel or not motel.rooms or not motel.rooms[roomId] then return nil end
  local r = motel.rooms[roomId]
  return r.doorNames and r.doorNames[1] or nil
end

local function findNearestDoorCoords(motelKey)
  local motel = Config.Motels[motelKey]
  if not motel or not motel.rooms then return nil, nil end

  local ped = PlayerPedId()
  local p = GetEntityCoords(ped)

  local nearestRoom, nearestDist

  for rid, room in pairs(motel.rooms) do
    if room.doorCoords then
      local dist = #(p - room.doorCoords)
      if not nearestDist or dist < nearestDist then
        nearestDist = dist
        nearestRoom = { room_id = rid, room = room }
      end
    end
  end

  return nearestRoom, nearestDist
end

local function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())

    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextCentre(1)
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(_x, _y)

        local factor = (string.len(text)) / 370
        DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 0, 0, 0, 80)
    end
end


-- ---------- Motel blip ----------

CreateThread(function()
    Wait(1000)

    for motelKey, motel in pairs(Config.Motels) do
        local blipCfg = motel.blip
        local rec = motel.reception

        if blipCfg and blipCfg.enabled and rec and rec.coords then
            local c = rec.coords

            local blip = AddBlipForCoord(c.x, c.y, c.z)
            SetBlipSprite(blip, blipCfg.sprite or 475)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, blipCfg.scale or 0.8)
            SetBlipColour(blip, blipCfg.color or 8)
            SetBlipAsShortRange(blip, blipCfg.shortRange ~= false)

            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(motel.label or motelKey)
            EndTextCommandSetBlipName(blip)
        end
    end
end)


-- ---------- Reception NPC ----------
CreateThread(function()
  for motelKey, motel in pairs(Config.Motels) do
    local rec = motel.reception
    if rec and rec.coords and rec.model then
      local model = loadModel(rec.model)
      local c = rec.coords

      local ped = CreatePed(0, model, c.x, c.y, c.z - 1.0, c.w, false, true)
      SetEntityInvincible(ped, true)
      SetBlockingOfNonTemporaryEvents(ped, true)
      FreezeEntityPosition(ped, true)

      exports['qb-target']:AddTargetEntity(ped, {
        options = {
          {
            icon = "fas fa-bed",
            label = (rec.targetLabel or "Resepsiyon") .. " - Oda Kirala",
            action = function()
              TriggerEvent('thd_motel:client:openRentMenu', motelKey)
            end
          },
          {
            icon = "fas fa-key",
            label = (rec.targetLabel or "Resepsiyon") .. " - Anahtar Kopyala",
            action = function()
              TriggerEvent('thd_motel:client:copyKeyPrompt', motelKey)
            end
          },
          {
            icon = "fas fa-clock",
            label = (rec.targetLabel or "Resepsiyon") .. " - Süre Uzat",
            action = function()
              TriggerServerEvent('thd_motel:server:extendRental', motelKey)
            end
          },
          {
            icon = "fas fa-ban",
            label = (rec.targetLabel or "Resepsiyon") .. " - Kirayı İptal Et",
            action = function()
              TriggerServerEvent('thd_motel:server:cancelRental', motelKey)
            end
          },
        },
        distance = 2.0
      })
    end
  end
end)

-- ---------- Room targets: stash + wardrobe ----------
CreateThread(function()
  Wait(500)
  for motelKey, motel in pairs(Config.Motels) do
    for roomId, room in pairs(motel.rooms or {}) do
      -- stash zone
      if room.stash and room.stash.coords then
        local zone = ('thd_motel_stash_%s_%s'):format(motelKey, roomId)
        exports['qb-target']:AddBoxZone(
          zone, room.stash.coords, 1.2, 1.2,
          { name = zone, heading = 0.0, minZ = room.stash.coords.z - 1.0, maxZ = room.stash.coords.z + 1.0 },
          {
            options = {
              {
                icon = "fas fa-box-open",
                label = ("Stash (Oda %s)"):format(room.label or roomId),
                action = function()
                  QBCore.Functions.TriggerCallback('thd_motel:server:hasAccess', function(ok)
                    if not ok then return QBCore.Functions.Notify('Bu oda için erişimin yok.', 'error') end
                    TriggerServerEvent('thd_motel:server:openStash', motelKey, roomId)
                  end, motelKey, roomId)
                end
              }
            },
            distance = 1.8
          }
        )
      end
    end
  end
end)

-- ---------- Rent menu ----------
RegisterNetEvent('thd_motel:client:openRentMenu', function(motelKey)
  local motel = Config.Motels[motelKey]
  if not motel then return end

  local menu = { { header = motel.label .. " | Oda Kirala", isMenuHeader = true } }

  for roomId, r in pairs(motel.rooms) do
    menu[#menu + 1] = {
      header = ("Oda %s"):format(r.label),
      txt = ("Ücret: $%d | Süre: %d dk"):format(motel.rentPrice, motel.rentDurationMinutes),
      params = { event = "thd_motel:client:rentRoom", args = { motel = motelKey, room = roomId } }
    }
  end

  menu[#menu + 1] = { header = "Kapat", params = { event = "qb-menu:closeMenu" } }
  exports['qb-menu']:openMenu(menu)
end)

RegisterNetEvent('thd_motel:client:rentRoom', function(data)
  TriggerServerEvent('thd_motel:server:rentRoom', data.motel, data.room)
end)

-- ---------- Copy key prompt ----------
RegisterNetEvent('thd_motel:client:copyKeyPrompt', function(motelKey)
  local motel = Config.Motels[motelKey]
  if not motel then return end

  local dialog = exports['qb-input']:ShowInput({
    header = motel.label .. " | Anahtar Kopyala",
    submitText = "Kopyala",
    inputs = { { text = "Hedef Oyuncu ID (server id)", name = "target", type = "number", isRequired = true } }
  })

  if not dialog or not dialog.target then return end
  TriggerServerEvent('thd_motel:server:copyKeyToPlayer', motelKey, tonumber(dialog.target))
end)

-- ---------- Use motel key (QB useable item triggers) ----------
RegisterNetEvent('QBCore:Client:UseMotelKey', function(item)
  if not item then return end
  local info = item.info or item.metadata or item.data
  if not info then
    QBCore.Functions.Notify('Anahtar bozuk (info/metadata yok).', 'error')
    return
  end

  local motelKey = info.motel or info.motelKey or "PinkCage"
  local room_id = tonumber(info.room_id or info.room)
  if not room_id then
    QBCore.Functions.Notify('Anahtar bozuk (room_id yok).', 'error')
    return
  end

  QBCore.Functions.TriggerCallback('thd_motel:server:hasAccess', function(hasAccess)
    if not hasAccess then
      QBCore.Functions.Notify('Bu anahtar sana ait değil veya süresi dolmuş.', 'error')
      TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 5.0, 'locked', 0.6)
      return
    end

    local nearest, dist = findNearestDoorCoords(motelKey)
    if not nearest or not dist or dist > (Config.UseDistance or 3.0) then
      return QBCore.Functions.Notify("Kapıya yeterince yakın değilsin.", "error")
    end

    if tonumber(nearest.room_id) ~= room_id then
      QBCore.Functions.Notify("Bu anahtar bu oda için değil.", "error")
      TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 5.0, 'locked', 0.6)
      return
    end

    local doorName = getDoorNameForRoom(motelKey, room_id)
    if not doorName then return QBCore.Functions.Notify("Kapı bulunamadı.", "error") end

    local door = exports.ox_doorlock:getDoorFromName(doorName)
    local doorId = door and door.id or doorName
    local doorData = door or exports.ox_doorlock:getDoor(doorId)
    local isLocked = (doorData and doorData.state == 1) or false

    playKeyAnim()

    local newState = isLocked and 0 or 1
    TriggerServerEvent('thd_motel:server:toggleDoor', motelKey, room_id, doorId, newState)

  end, motelKey, room_id)
end)

CreateThread(function()
    while true do
        local sleep = 1500
        local ped = PlayerPedId()
        local pCoords = GetEntityCoords(ped)

        for motelKey, motel in pairs(Config.Motels) do
            for roomId, room in pairs(motel.rooms or {}) do
                -- Oda sahibi/anahtarı olan kişiye kapı önünde belirteç göster
                if room.doorCoords and getAccess(motelKey, roomId) then
                    local dDist = #(pCoords - room.doorCoords)
                    if dDist < 10.0 then
                        sleep = 0
                        -- Sadece yüzen ok (yüksekliği düşürüldü)
                        DrawMarker(2, room.doorCoords.x, room.doorCoords.y, room.doorCoords.z + 0.4, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.2, 0.2, 0.2, 255, 215, 0, 200, true, true, 2, nil, nil, false)
                    end
                end

                if room.wardrobe and room.wardrobe.coords and getAccess(motelKey, roomId) then
                    local w = room.wardrobe.coords
                    local dist = #(pCoords - w)

                    if dist < 3.0 then
                        sleep = 0
                        DrawText3D(w.x, w.y, w.z, "[E] Gardırop")

                        if dist < 1.5 and IsControlJustReleased(0, 38) then -- E
                            TriggerServerEvent('thd_motel:server:openWardrobe', motelKey, roomId)
                            Wait(1000)
                        end
                    end
                end
            end
        end

        Wait(sleep)
    end
end)


-- (Opsiyonel) Koordinat kolay alma komutu
RegisterCommand('thdcoords', function()
  local p = GetEntityCoords(PlayerPedId())
  print(('vector3(%.2f, %.2f, %.2f)'):format(p.x, p.y, p.z))
  QBCore.Functions.Notify('Koordinat F8 console\'a yazıldı.', 'success')
end)
