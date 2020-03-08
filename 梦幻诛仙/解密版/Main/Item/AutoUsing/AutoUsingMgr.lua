local MODULE_NAME = (...)
local Lplus = require("Lplus")
local AutoUsingMgr = Lplus.Class(MODULE_NAME)
local Cls = AutoUsingMgr
local def = Cls.define
local instance
def.static("=>", Cls).Instance = function()
  if instance == nil then
    instance = Cls()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, Cls.OnItemChange)
end
def.static("=>", "boolean").IsFeatureOpen = function()
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
  local bFeatureOpen = FeatureOpenListModule.Instance():CheckFeatureOpen(Feature.TYPE_AUTO_USE_ITEM_IN_BAG)
  return bFeatureOpen
end
def.static("number", "=>", "boolean").CanAutoUse = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_AUTOUSE_ITEM, itemId)
  return record ~= nil
end
def.static("table", "table").OnItemChange = function(p, c)
  if not Cls.IsFeatureOpen() then
    return
  end
  local ItemModule = require("Main.Item.ItemModule")
  local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
  local ItemUtils = require("Main.Item.ItemUtils")
  if p.bagId == ItemModule.BAG then
    for i = 1, #p.chgItems do
      local item = p.chgItems[i].item
      if Cls.CanAutoUse(item.id) then
        local itemKey = p.chgItems[i].itemKey
        local itemBase = ItemUtils.GetItemBase(item.id)
        if item and itemBase then
          local operations = ItemTipsMgr.Instance():GetBottomOperation(ItemTipsMgr.Source.Bag, item, itemBase)
          Cls._try2RunOpe(operations, item, itemKey, ItemModule.BAG)
        end
      end
    end
  end
end
def.static("table", "table", "number", "number")._try2RunOpe = function(opes, item, itemKey, bagId)
  for i = 1, #opes do
    local ope = opes[i]
    if ope:GetOperationName() == textRes.Item[8324] then
      ope:OperateAll(bagId, itemKey, nil, nil)
      break
    elseif ope:GetOperationName() == textRes.Item[8101] then
      for j = 1, item.number do
        ope:Operate(bagId, itemKey, nil, nil)
      end
      break
    end
  end
end
return Cls.Commit()
