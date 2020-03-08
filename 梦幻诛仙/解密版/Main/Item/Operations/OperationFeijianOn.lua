local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local WearPos = require("consts.mzm.gsp.item.confbean.WearPos")
local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local ItemModule = require("Main.Item.ItemModule")
local MathHelper = require("Common.MathHelper")
local OperationFeijianOn = Lplus.Extend(OperationBase, "OperationFeijianOn")
local def = OperationFeijianOn.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.AIR_CRAFT_ITEM then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8103]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  if item == nil then
    return
  end
  local itemBase = require("Main.Item.ItemUtils").GetItemBase(item.id)
  local myLv = require("Main.Hero.HeroModule").Instance():GetHeroProp().level
  if myLv < itemBase.useLevel then
    Toast(string.format(textRes.Item[8365], itemBase.useLevel))
    return false
  end
  local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  local key, _ = ItemModule.Instance():GetItemByPosition(ItemModule.EQUIPBAG, WearPos.AIRCRAFT)
  if heroModule.myRole and heroModule.myRole:IsInState(RoleState.FLY) and key > 0 then
    Toast(textRes.Item[166])
    return true
  end
  local pEquipFeijian = require("netio.protocol.mzm.gsp.item.CPutOnAircraft").new(item.uuid[1])
  gmodule.network.sendProtocol(pEquipFeijian)
  return true
end
OperationFeijianOn.Commit()
return OperationFeijianOn
