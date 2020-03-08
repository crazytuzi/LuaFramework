local Lplus = require("Lplus")
local EasyItemTipHelper = Lplus.Class("EasyItemTipHelper")
local def = EasyItemTipHelper.define
def.field("table").toShowTipItemMap = nil
def.method("number", "userdata").RegisterItem2ShowTip = function(self, itemId, clickedObj)
  self.toShowTipItemMap = self.toShowTipItemMap or {}
  self.toShowTipItemMap[clickedObj.name] = {itemId = itemId, clickedObj = clickedObj}
end
def.method("string", "=>", "boolean").CheckItem2ShowTip = function(self, id)
  if self.toShowTipItemMap == nil then
    return false
  end
  local itemInfo = self.toShowTipItemMap[id]
  if itemInfo == nil then
    return false
  end
  local ItemModule = require("Main.Item.ItemModule")
  local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
  local itemId = itemInfo.itemId
  local clickedObj = itemInfo.clickedObj
  local source = clickedObj
  local position = source:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = source:GetComponent("UIWidget")
  ItemTipsMgr.Instance():ShowBasicTips(itemId, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, true)
  return true
end
return EasyItemTipHelper.Commit()
