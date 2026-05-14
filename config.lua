Config = {}

Config.KeyItem = "motel_key"


Config.ToggleLock = true
Config.UseDistance = 3.0

Config.DefaultStash = { slots = 40, weight = 60000, }

Config.Motels = {
  PinkCage = {
    label = "Pink Cage Motel",
    blip = {
      enabled = true,
      sprite = 475,
      color = 5,
      scale = 0.7,
      shortRange = true,
      name = "Pink Cage Motel",
    },
    rentPrice = 500,
    extendPrice = 350,
    copyKeyPrice = 200,
    rentDurationMinutes = 10080, -- her uzatma +7 gün

    reception = {
      coords = vector4(325.29, -229.64, 54.22, 155.54),
      model = `cs_bankman`,
      targetLabel = "Resepsiyon",
    },

    rooms = {
      [1] = {
        label = "1",
        doorNames = {"PinkCage1"},
        doorCoords = vector3(307.56, -213.26, 54.22),
        defaultLocked = true,
        stash = {
          coords = vector3(306.83, -208.53, 54.23),
          slots = Config.DefaultStash.slots,
          weight = Config.DefaultStash.weight,
        },
        wardrobe = {
         coords = vector3(302.89, -206.92, 54.23),
        },
      },
      [2] = {
        label = "2",
        doorNames = {"PinkCage2"},
        doorCoords = vector3(311.11, -203.51, 54.22),
        defaultLocked = true,
        stash = {
          coords = vector3(310.54, -198.71, 54.23),
          slots = Config.DefaultStash.slots,
          weight = Config.DefaultStash.weight,
        },
        wardrobe = {
         coords = vector3(306.64, -197.02, 54.23),
        },
      },
      [3] = {
        label = "3",
        doorNames = {"PinkCage3"},
        doorCoords = vector3(315.81, -194.63, 54.23),
        defaultLocked = true,
        stash = {
          coords = vector3(320.45, -194.14, 54.23),
          slots = Config.DefaultStash.slots,
          weight = Config.DefaultStash.weight,
        },
        wardrobe = {
         coords = vector3(322.15, -190.25, 54.23),
        },
      },
      [4] = {
        label = "4",
        doorNames = {"PinkCage4"},
        doorCoords = vector3(314.81, -219.75, 58.02),
        defaultLocked = true,
        stash = {
          coords = vector3(310.17, -220.37, 58.02),
          slots = Config.DefaultStash.slots,
          weight = Config.DefaultStash.weight,
        },
        wardrobe = {
         coords = vector3(308.50, -224.25, 58.02),
        },
      },
      [5] = {
        label = "5",
        doorNames = {"PinkCage5"},
        doorCoords = vector3(307.43, -213.27, 58.02),
        defaultLocked = true,
        stash = {
          coords = vector3(306.81, -208.59, 58.02),
          slots = Config.DefaultStash.slots,
          weight = Config.DefaultStash.weight,
        },
        wardrobe = {
         coords = vector3(302.87, -206.91, 58.02),
        },
      },
      [6] = {
        label = "6",
        doorNames = {"PinkCage6"},
        doorCoords = vector3(311.18, -203.43, 58.02),
        defaultLocked = true,
        stash = {
          coords = vector3(310.69, -198.69, 58.02),
          slots = Config.DefaultStash.slots,
          weight = Config.DefaultStash.weight,
        },
        wardrobe = {
         coords = vector3(306.79, -197.03, 58.02),
        },
      },
      [7] = {
        label = "7",
        doorNames = {"PinkCage7"},
        doorCoords = vector3(315.75, -194.68, 58.02),
        defaultLocked = true,
        stash = {
          coords = vector3(320.49, -194.17, 58.02),
          slots = Config.DefaultStash.slots,
          weight = Config.DefaultStash.weight,
        },
        wardrobe = {
         coords = vector3(322.17, -190.28, 58.02),
        },
      },
      [8] = {
        label = "8",
        doorNames = {"PinkCage8"},
        doorCoords = vector3(339.32, -219.46, 54.22),
        defaultLocked = true,
        stash = {
          coords = vector3(339.82, -224.16, 54.23),
          slots = Config.DefaultStash.slots,
          weight = Config.DefaultStash.weight,
        },
        wardrobe = {
         coords = vector3(343.72, -225.85, 54.23),
        },
      },
      [9] = {
        label = "9",
        doorNames = {"PinkCage9"},
        doorCoords = vector3(343.11, -209.65, 54.22),
        defaultLocked = true,
        stash = {
          coords = vector3(343.64, -214.35, 54.23),
          slots = Config.DefaultStash.slots,
          weight = Config.DefaultStash.weight,
        },
        wardrobe = {
         coords = vector3(347.57, -215.98, 54.23),
        },
      },
      [10] = {
        label = "10",
        doorNames = {"PinkCage10"},
        doorCoords = vector3(346.97, -199.67, 54.22),
        defaultLocked = true,
        stash = {
          coords = vector3(347.37, -204.37, 54.23),
          slots = Config.DefaultStash.slots,
          weight = Config.DefaultStash.weight,
        },
        wardrobe = {
         coords = vector3(351.23, -206.02, 54.23),
        },
      },
      [11] = {
        label = "11",
        doorNames = {"PinkCage11"},
        doorCoords = vector3(334.94, -227.51, 58.02),
        defaultLocked = true,
        stash = {
          coords = vector3(330.29, -228.01, 58.02),
          slots = Config.DefaultStash.slots,
          weight = Config.DefaultStash.weight,
        },
        wardrobe = {
         coords = vector3(328.55, -231.83, 58.02),
        },
      },
      [12] = {
        label = "12",
        doorNames = {"PinkCage12"},
        doorCoords = vector3(339.23, -219.57, 58.02),
        defaultLocked = true,
        stash = {
          coords = vector3(339.88, -224.21, 58.02),
          slots = Config.DefaultStash.slots,
          weight = Config.DefaultStash.weight,
        },
        wardrobe = {
         coords = vector3(343.75, -225.81, 58.02),
        },
      },
      [13] = {
        label = "13",
        doorNames = {"PinkCage13"},
        doorCoords = vector3(343.14, -209.64, 58.02),
        defaultLocked = true,
        stash = {
          coords = vector3(343.65, -214.37, 58.02),
          slots = Config.DefaultStash.slots,
          weight = Config.DefaultStash.weight,
        },
        wardrobe = {
         coords = vector3(347.58, -215.87, 58.02),
        },
      },
      [14] = {
        label = "14",
        doorNames = {"PinkCage14"},
        doorCoords = vector3(346.86, -199.67, 58.02),
        defaultLocked = true,
        stash = {
          coords = vector3(347.46, -204.45, 58.02),
          slots = Config.DefaultStash.slots,
          weight = Config.DefaultStash.weight,
        },
        wardrobe = {
         coords = vector3(351.33, -206.14, 58.02),
        },
      },
    },
  },

  Bayview = {
    label = "Bayview Lodge Motel",
    blip = {
      enabled = true,
      sprite = 475,
      color = 6,
      scale = 0.7,
      shortRange = true,
      name = "Bayview Lodge Motel",
    },
    rentPrice = 500,
    extendPrice = 350,
    copyKeyPrice = 200,
    rentDurationMinutes = 10080, -- her uzatma +7 gün

    reception = {
      coords = vector4(-702.87, 5790.01, 17.52, 63.69),
      model = `cs_bankman`,
      targetLabel = "Resepsiyon",
    },

    rooms = {
      [1] = {
        label = "1",
        doorNames = {"BayviewLodge1"},
        doorCoords = vector3(-681.78, 5769.97, 17.69),
        defaultLocked = true,
        stash = {
          coords = vector3(-677.09, 5770.73, 17.54),
          slots = Config.DefaultStash.slots,
          weight = Config.DefaultStash.weight,
        },
        wardrobe = {
         coords = vector3(-677.70, 5768.87, 17.54),
        },
      },
      [2] = {
        label = "2",
        doorNames = {"BayviewLodge2"},
        doorCoords = vector3(-683.60, 5766.05, 17.69),
        defaultLocked = true,
        stash = {
          coords = vector3(-678.83, 5766.93, 17.54),
          slots = Config.DefaultStash.slots,
          weight = Config.DefaultStash.weight,
        },
        wardrobe = {
         coords = vector3(-679.59, 5764.77, 17.54),
        },
      },
      [3] = {
        label = "3",
        doorNames = {"BayviewLodge3"},
        doorCoords = vector3(-685.43, 5762.12, 17.69),
        defaultLocked = true,
        stash = {
          coords = vector3(-680.62, 5762.87, 17.54),
          slots = Config.DefaultStash.slots,
          weight = Config.DefaultStash.weight,
        },
        wardrobe = {
         coords = vector3(-681.48, 5761.15, 17.54),
        },
      },
      [4] = {
        label = "4",
        doorNames = {"BayviewLodge4"},
        doorCoords = vector3(-687.26, 5758.19, 17.69),
        defaultLocked = true,
        stash = {
          coords = vector3(-682.48, 5759.02, 17.54),
          slots = Config.DefaultStash.slots,
          weight = Config.DefaultStash.weight,
        },
        wardrobe = {
         coords = vector3(-683.12, 5756.85, 17.54),
        },
      },
      [5] = {
        label = "5",
        doorNames = {"BayviewLodge5"},
        doorCoords = vector3(-691.06, 5759.37, 17.69),
        defaultLocked = true,
        stash = {
          coords = vector3(-690.45, 5754.79, 17.54),
          slots = Config.DefaultStash.slots,
          weight = Config.DefaultStash.weight,
        },
        wardrobe = {
         coords = vector3(-692.21, 5755.36, 17.54),
        },
      },
      [6] = {
        label = "6",
        doorNames = {"BayviewLodge6"},
        doorCoords = vector3(-694.89, 5761.20, 17.69),
        defaultLocked = true,
        stash = {
          coords = vector3(-694.36, 5756.57, 17.54),
          slots = Config.DefaultStash.slots,
          weight = Config.DefaultStash.weight,
        },
        wardrobe = {
         coords = vector3(-695.94, 5757.14, 17.54),
        },
      },
      [7] = {
        label = "7",
        doorNames = {"BayviewLodge7"},
        doorCoords = vector3(-698.90, 5763.04, 17.69),
        defaultLocked = true,
        stash = {
          coords = vector3(-698.16, 5758.29, 17.54),
          slots = Config.DefaultStash.slots,
          weight = Config.DefaultStash.weight,
        },
        wardrobe = {
         coords = vector3(-700.11, 5759.09, 17.54),
        },
      },
      [8] = {
        label = "8",
        doorNames = {"BayviewLodge8"},
        doorCoords = vector3(-702.82, 5764.85, 17.69),
        defaultLocked = true,
        stash = {
          coords = vector3(-702.06, 5759.98, 17.54),
          slots = Config.DefaultStash.slots,
          weight = Config.DefaultStash.weight,
        },
        wardrobe = {
         coords = vector3(-703.94, 5760.94, 17.54),
        },
      },
      [9] = {
        label = "9",
        doorNames = {"BayviewLodge9"},
        doorCoords = vector3(-706.73, 5766.68, 17.69),
        defaultLocked = true,
        stash = {
          coords = vector3(-706.13, 5762.13, 17.54),
          slots = Config.DefaultStash.slots,
          weight = Config.DefaultStash.weight,
        },
        wardrobe = {
         coords = vector3(-707.69, 5762.92, 17.54),
        },
      },
      [10] = {
        label = "10",
        doorNames = {"BayviewLodge10"},
        doorCoords = vector3(-709.92, 5768.59, 17.54),
        defaultLocked = true,
        stash = {
          coords = vector3(-709.82, 5763.71, 17.54),
          slots = Config.DefaultStash.slots,
          weight = Config.DefaultStash.weight,
        },
        wardrobe = {
         coords = vector3(-711.68, 5764.67, 17.54),
        },
      }
    }
  }
}
