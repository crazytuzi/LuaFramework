local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local OperationFabaoGrow = Lplus.Extend(OperationBase, "OperationFabaoGrow")
local def = OperationFabaoGrow.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Equip and itemBase.itemType == ItemType.FABAO_ITEM then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8363]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  if self:CannotUseInFight() then
    return false
  end
  local HeroProp = require("Main.Hero.Interface").GetHeroProp()
  local FabaoMgr = require("Main.Fabao.FabaoMgr")
  local roleLv = HeroProp.level
  local minLevel = FabaoMgr.GetFabaoConstant("FABAO_MIN_ROLE_LEVEL") or 50
  if roleLv < minLevel then
    Toast(textRes.Fabao[35]:format(minLevel))
    return false
  end
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_FABAO_CLICK, {id = 3})
  return true
end
OperationFabaoGrow.Commit()
return OperationFabaoGrow
