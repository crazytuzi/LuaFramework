local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local ItemModule = require("Main.Item.ItemModule")
local MathHelper = require("Common.MathHelper")
local OperationPetReplaceEquipment = Lplus.Extend(OperationBase, "OperationPetReplaceEquipment")
local def = OperationPetReplaceEquipment.define
def.field("number").itemType = -1
def.field("number").source = -1
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  self.itemType = itemBase.itemType
  self.source = source
  if (source == ItemTipsMgr.Source.PetBasicNode or source == ItemTipsMgr.Source.ChildrenBag) and itemBase.itemType == ItemType.PET_EQUIP then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8120]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local CommonUsePanel = require("GUI.CommonUsePanel")
  local PetMgr = Lplus.ForwardDeclare("PetMgr")
  if self.source == ItemTipsMgr.Source.PetBasicNode then
    local slot = context.slot
    local itemIdList = require("Main.Pet.mgr.PetEquipmentMgr").Instance():GetEquipmentSourceItemIdList(slot)
    CommonUsePanel.Instance():SetItemIdList(itemIdList)
    CommonUsePanel.Instance():ShowPanel(PetMgr.PetEquipmentItemFilter, nil, CommonUsePanel.Source.PetItemBag, {slot})
  elseif self.source == ItemTipsMgr.Source.ChildrenBag then
    local slot = context.slot
    local itemIdList = require("Main.Pet.mgr.PetEquipmentMgr").Instance():GetEquipmentSourceItemIdList(slot)
    CommonUsePanel.Instance():SetItemIdList(itemIdList)
    CommonUsePanel.Instance():ShowPanel(PetMgr.PetEquipmentItemFilter, nil, CommonUsePanel.Source.ChildrenItemBag, {slot})
  end
  return true
end
OperationPetReplaceEquipment.Commit()
return OperationPetReplaceEquipment
