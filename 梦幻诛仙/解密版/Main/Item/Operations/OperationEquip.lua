local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local ItemModule = require("Main.Item.ItemModule")
local MathHelper = require("Common.MathHelper")
local OperationEquip = Lplus.Extend(OperationBase, "OperationEquip")
local def = OperationEquip.define
def.field("boolean").bind = false
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.EQUIP then
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
    return false
  end
  local bind = MathHelper.BitAnd(item.flag, ItemInfo.BIND)
  local itemBase = require("Main.Item.ItemUtils").GetItemBase(item.id)
  local function equip()
    local heroProp = _G.GetHeroProp()
    if heroProp == nil then
      return
    end
    local heroOcp = heroProp.occupation
    local ocp = context and context.ocp or heroOcp
    if ocp == heroOcp then
      local pEquip = require("netio.protocol.mzm.gsp.item.CEquip").new(itemKey, m_panel)
      gmodule.network.sendProtocol(pEquip)
      if PlayerIsInFight() then
        Toast(textRes.Item[9701])
      end
    else
      local OcpEquipmentMgr = require("Main.Equip.OcpEquipmentMgr")
      OcpEquipmentMgr.Instance():CPutOnOcpEquipReq(ocp, item.uuid[1])
    end
  end
  if bind ~= 0 or itemBase.isProprietary or itemBase.useLevel < 10 then
    equip()
  else
    CommonConfirmDlg.ShowConfirm(textRes.Item[102], textRes.Item[103], function(selection, tag)
      if selection == 1 then
        equip()
      end
    end, nil)
  end
  return true
end
OperationEquip.Commit()
return OperationEquip
