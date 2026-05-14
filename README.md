# 🏨 thd_motel | AstraV Transient Housing

A specialized motel system for the QBCore framework. This resource provides temporary accommodation for new or transient players, featuring meta-key access, automated rent cycles, and integrated personal storage.

![Version](https://img.shields.io/badge/Version-1.0.0-green?style=for-the-badge)
![Living](https://img.shields.io/badge/Living-Transient-emerald?style=for-the-badge)

---

## ✨ Features

- **Meta-Key Access**: Motel rooms are secured with physical key items that contain unique room metadata.
- **Automated Renting**: Players can rent rooms for configurable periods with automated payments.
- **Persistent Storage**: Every room includes a private stash for players to store their belongings.
- **Wardrobe System**: Access to saved outfits within the motel room.
- **Multiple Motel Locations**: Support for various motels across Los Santos (Pink Cage, Jefferson, etc.).
- **Optimized for QBCore**: Seamlessly handles player data and inventory integration.

---

## 🎨 Design Philosophy

`thd_motel` is designed for accessibility:
- **Emerald Theme**: Interaction menus and confirmation buttons use AstraV green.
- **Clean UI**: Simple, effective menus for renting and managing rooms.
- **AstraV Aesthetics**: Consistent with the server's premium glassmorphic style.

---

## 🛠️ Requirements

- **QBCore Framework**
- **ox_inventory**
- **qb-target**
- **oxmysql**

---

## 🚀 Installation

1. Drag the `thd_motel` folder into your `resources/[thd]` directory.
2. Add the following to your `server.cfg`:
   ```cfg
   ensure thd_motel
   ```
3. Import the provided SQL file to initialize motel room data.

---

## ⚙️ Configuration

Configure rent prices and motel locations in `config.lua`:

```lua
Config = {}
Config.Motels = {
    ["PinkCage"] = {
        label = "Pink Cage Motel",
        coords = vector3(312.42, -210.15, 54.22),
        price = 500, -- Daily rent
    }
}
```

---

## 🖱️ Interaction

- **Rent Room**: Use **Targeting (Alt)** or press **[E]** at the motel reception.
- **Access Room**: Ensure you have the **Motel Key** in your inventory to enter your assigned room.

---

*Part of the AstraV Premium Suite*
