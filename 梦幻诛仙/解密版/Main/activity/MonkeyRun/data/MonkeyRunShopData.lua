local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local MonkeyRunShopData = Lplus.Class(CUR_CLASS_NAME)
local def = MonkeyRunShopData.define
def.field("userdata").shopPoint = nil
def.field("table").itemExchangeTimes = nil
def.method("table").RawSet = function(self, p)
  self.shopPoint = p.pointCount
  self.itemExchangeTimes = p.cfgId2available
end
def.method("=>", "userdata").GetCurrentShopPoint = function(self)
  return self.shopPoint
end
def.method("userdata").SetCurrentShopPoint = function(self, point)
  self.shopPoint = point
end
def.method("number", "=>", "number").GetItemCanBuyCount = function(self, itemCfgId)
  if self.itemExchangeTimes == nil then
    return -1
  end
  return self.itemExchangeTimes[itemCfgId] or -1
end
def.method("number", "number").SetItemCanBuyCount = function(self, itemCfgId, count)
  if self.itemExchangeTimes == nil then
    return
  end
  self.itemExchangeTimes[itemCfgId] = count
end
return MonkeyRunShopData.Commit()
