local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local ItemModule = require("Main.Item.ItemModule")
local MathHelper = require("Common.MathHelper")
local OperationPetExp = Lplus.Extend(OperationBase, "OperationPetExp")
local def = OperationPetExp.define
def.field("number").itemType = -1
def.field("number").source = -1
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  self.itemType = itemBase.itemType
  self.source = source
  if source == ItemTipsMgr.Source.PetItemBag and itemBase.itemType == ItemType.PET_EXP_ITEM then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local petId = context[1]
  local itemType = self.itemType
  self:UsePetExpItem(petId, itemType, itemKey)
  return false
end
def.method("userdata", "number", "number").UsePetExpItem = function(self, petId, itemType, itemKey)
  local PetMgr = require("Main.Pet.mgr.PetMgr")
  if PetMgr.Instance():CanPetGainExp(petId) then
    PetMgr.Instance():UseItem(petId, itemKey, itemType)
  else
    local maxOverOwnerLevel = PetMgr.Instance():GetMaxOverOwnerLevel()
    Toast(string.format(textRes.Pet[55], maxOverOwnerLevel))
  end
end
def.override("number", "number", "userdata", "table", "=>", "boolean").OperateAll = function(self, bagId, itemKey, m_panel, context)
  local petId = context[1]
  local ItemModule = require("Main.Item.ItemModule")
  local ItemUtils = require("Main.Item.ItemUtils")
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  if item == nil then
    return
  end
  local itemBase = ItemUtils.GetItemBase(item.id)
  local askStr = string.format(textRes.Item[8323], HtmlHelper.NameColor[itemBase.namecolor], itemBase.name)
  local dlg = CommonConfirmDlg.ShowConfirm(textRes.Item[8324], askStr, function(selection, tag)
    if selection == 1 then
      self:AllUsePetExpItem(petId, itemKey)
    end
  end, nil)
  dlg:rename(m_panel.name)
  return true
end
def.method("userdata", "number").AllUsePetExpItem = function(self, petId, itemKey)
  local PetMgr = require("Main.Pet.mgr.PetMgr")
  PetMgr.Instance():AllUsePetExpItem(petId, itemKey)
end
OperationPetExp.Commit()
return OperationPetExp
