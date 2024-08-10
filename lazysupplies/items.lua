--[[ Items.lua for Lazysupplies.lua

]]--

local supplies = {
  { name = "Fresh Fish", quantity = 1000, vendor = "Angler Winifred", classes = nil },
  { name = "Water Flask", quantity = 1000, vendor = "Angler Winifred", classes = nil },
  { name = "Emerald", quantity = 1000, vendor = "Jeweler Nonny", classes = { "CLR", "NEC" } },
  { name = "Cloudy Potion", quantity = 100, vendor = "Alchemist Redsa", classes = { "WAR", "CLR", "PAL", "BER", "MNK", "RNG", "DRU", "BRD" } },
  { name = "Malachite", quantity = 1000, vendor = "Gem Dealer Spiro", classes = { "MAG" } },
  { name = "Pearl", quantity = 1000, vendor = "Jeweler Nonny", classes = { "SHD", "MAG" } },
  { name = "Peridot", quantity = 1000, vendor = "Jeweler Nonny", classes = { "ENC" } },
  { name = "Tiny Dagger", quantity = 1000, vendor = "Weapon Merchant", classes = { "ENC" } },
  { name = "Basic Axe Components", quantity = 2, vendor = "Gaddi Buruca", classes = { "MAG", "BER" }, level_range = {1, 29} },
  { name = "Axe Components", quantity = 2, vendor = "Gaddi Buruca", classes = { "MAG", "BER" }, level_range = {30, 54} },
  { name = "Balanced Axe Components", quantity = 1000, vendor = "Gaddi Buruca", classes = { "BER" }, level_range = {55, 95} },
  { name = "Crafted Axe Components", quantity = 1000, vendor = "Gaddi Buruca", classes = { "BER" }, level_range = {96, 100} },
  { name = "Fine Axe Components", quantity = 1000, vendor = "Gaddi Buruca", classes = { "BER" }, level_range = {100, 115} },
  { name = "Honed Axe Components", quantity = 2, vendor = "Gaddi Buruca", classes = {  "MAG", "BER" }, level_range = {120, 125} }
}

return supplies


