local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local ItemModule = require("Main.Item.ItemModule")
local MathHelper = require("Common.MathHelper")
local OperationFabaoOn = Lplus.Extend(OperationBase, "OperationFabaoOn")
local def = OperationFabaoOn.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.FabaoBag and itemBase.itemType == ItemType.FABAO_ITEM then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8103]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  if self:CannotUseInFight() then
    return false
  end
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  local FabaoMgr = require("Main.Fabao.FabaoMgr")
  local itemBase = require("Main.Item.ItemUtils").GetItemBase(item.id)
  local HeroProp = require("Main.Hero.Interface").GetHeroProp()
  local minLevel = FabaoMgr.GetFabaoConstant("FABAO_MIN_ROLE_LEVEL") or 50
  if minLevel > HeroProp.level then
    Toast(textRes.Fabao[54]:format(minLevel))
    return false
  end
  if item == nil then
    return
  end
  local bind = MathHelper.BitAnd(item.flag, ItemInfo.BIND)
  if bind ~= 0 or itemBase.isProprietary then
    local pEquipFabao = require("netio.protocol.mzm.gsp.item.CPutOnFabao").new(item.uuid[1])
    gmodule.network.sendProtocol(pEquipFabao)
  else
    CommonConfirmDlg.ShowConfirm(textRes.Item[102], textRes.Item[103], function(selection, tag)
      if selection == 1 then
        local pEquipFabao = require("netio.protocol.mzm.gsp.item.CPutOnFabao").new(item.uuid[1])
        gmodule.network.sendProtocol(pEquipFabao)
      end
    end, nil)
  end
  return true
end
OperationFabaoOn.Commit()
return OperationFabaoOn
