local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemUtils = require("Main.Item.ItemUtils")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local ItemModule = require("Main.Item.ItemModule")
local PetMgr = require("Main.Pet.mgr.PetMgr")
local PetData = require("Main.Pet.data.PetData")
local OperationUsePetExtraModel = Lplus.Extend(OperationBase, "OperationUsePetExtraModel")
local def = OperationUsePetExtraModel.define
def.field("table").itemBase = nil
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.PET_CHANGEMODEL_ITEM then
    self.itemBase = itemBase
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8372]
end
def.method("=>", "boolean").CanUsePetModelItem = function(self)
  local open = IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_PET_CHANGE_MODEL)
  return open
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  if _G.CheckCrossServerAndToast() then
    return true
  end
  if not self:CanUsePetModelItem() then
    Toast(textRes.Pet[219])
    return true
  end
  local petList = self:GetCanMakeExtraModelPetList()
  require("Main.Pet.ui.PetSelectPanel").Instance():ShowPanel(petList, "", function(index, pet, userParams)
    if not self:CanUsePetModelItem() then
      Toast(textRes.Pet[219])
      return
    end
    if pet:HasExtraModel(self.itemBase.itemid) then
      Toast(textRes.Pet[258])
      return
    end
    local confirmStr
    if pet.extraModelCfgId ~= 0 then
      local existModelInfo = ItemUtils.GetItemBase(pet.extraModelCfgId)
      if existModelInfo == nil then
        warn("pet huizhi item not exist:" .. pet.extraModelCfgId)
        return
      end
      confirmStr = string.format(textRes.Pet[214], existModelInfo.name, self.itemBase.name)
    else
      confirmStr = string.format(textRes.Pet[215], self.itemBase.name)
    end
    CommonConfirmDlg.ShowConfirm("", confirmStr, function(result)
      if result == 1 then
        PetMgr.Instance():UsePetChangeModelItemReq(pet.id, itemKey)
      end
    end, nil)
  end, nil)
  return true
end
def.method("=>", "table").GetCanMakeExtraModelPetList = function(self)
  local petList = PetMgr.Instance():GetSortedPetList()
  local availableList = {}
  if self.itemBase ~= nil then
    local itemDetail = ItemUtils.GetPetHuiZhiItemCfg(self.itemBase.itemid)
    local cannotUsePetMap = {}
    if itemDetail ~= nil then
      local cannotUsePet = itemDetail.cannotUsePet
      for idx, petId in pairs(cannotUsePet) do
        cannotUsePetMap[petId] = cannotUsePetMap
      end
    end
    for i = 1, #petList do
      local canShow = true
      local pet = petList[i]
      local petCfg = pet:GetPetCfgData()
      if petCfg.type == PetData.PetType.WILD then
        canShow = false
      end
      local HeroPropMgr = require("Main.Hero.mgr.HeroPropMgr").Instance()
      local heroProp = HeroPropMgr.heroProp
      if petCfg.carryLevel > heroProp.level then
        canShow = false
      end
      if cannotUsePetMap[petCfg.templateId] ~= nil then
        canShow = false
      end
      if canShow then
        table.insert(availableList, pet)
      end
    end
  end
  return availableList
end
OperationUsePetExtraModel.Commit()
return OperationUsePetExtraModel
