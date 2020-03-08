local Lplus = require("Lplus")
local InventoryDlgViewModel = Lplus.Class("InventoryDlgViewModel")
local def = InventoryDlgViewModel.define
local ItemUtils = require("Main.Item.ItemUtils")
local OcpEquipmentMgr = require("Main.Equip.OcpEquipmentMgr")
local ModelInfo = require("netio.protocol.mzm.gsp.pubdata.ModelInfo")
local WearPos = require("consts.mzm.gsp.item.confbean.WearPos")
local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
local FashionDressConst = require("netio.protocol.mzm.gsp.fashiondress.FashionDressConst")
local EquipUtils = require("Main.Equip.EquipUtils")
local instance
def.static("=>", InventoryDlgViewModel).Instance = function()
  if instance == nil then
    instance = InventoryDlgViewModel()
  end
  return instance
end
def.method("=>", "boolean").IsMultiOccupationOpen = function(self)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local feature = require("Main.FeatureOpenList.FeatureOpenListModule").Instance()
  local isOpen = feature:CheckFeatureOpen(Feature.TYPE_MULTI_OCCUPATION)
  return isOpen
end
def.method("number", "=>", "table").GetOccupationEquipments = function(self, occupation)
  local heroProp = _G.GetHeroProp()
  local heroOccupation = heroProp.occupation
  local heroEquipments = gmodule.moduleMgr:GetModule(ModuleId.ITEM):GetHeroEquipments()
  if heroOccupation == occupation then
    return heroEquipments
  else
    local equipments = OcpEquipmentMgr.Instance():GetOccupationEquipments(occupation)
    return equipments
  end
end
def.method("number", "number", "=>", "number", "table").GetEquipmentByPosition = function(self, occupation, position)
  local ItemModule = require("Main.Item.ItemModule")
  local heroProp = _G.GetHeroProp()
  local heroOccupation = heroProp.occupation
  if heroOccupation == occupation then
    return ItemModule.Instance():GetItemByPosition(ItemModule.EQUIPBAG, position)
  else
    local equipments = self:GetOccupationEquipments(occupation)
    if equipments then
      for k, v in pairs(equipments) do
        if v.position == position then
          return k, v
        end
      end
    end
    return -1, nil
  end
end
def.method("=>", "table").GetOwnedOccupations = function(self)
  local occupations = require("Main.MultiOccupation.MultiOccupationModule").Instance():getOwnOccupations() or {}
  return occupations
end
def.method("=>", "table").GetOwnedOccupationInfos = function(self)
  local heroProp = _G.GetHeroProp()
  local heroOccupation = heroProp.occupation
  local ownedOccupations = self:GetOwnedOccupations()
  local occupationInfos = {}
  local occupationName
  for i, ocp in ipairs(ownedOccupations) do
    occupationName = _G.GetOccupationName(ocp)
    if ocp == heroOccupation then
      occupationName = string.format("%s%s", occupationName, textRes.Equip.OcpEquipment[1])
    end
    occupationInfos[#occupationInfos + 1] = {ocp = ocp, name = occupationName}
  end
  return occupationInfos
end
def.method("number", "=>", "number").GetOccupationModelId = function(self, ocp)
  local heroProp = _G.GetHeroProp()
  local heroOccupation = heroProp.occupation
  local modelId = gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyModelId()
  if heroOccupation ~= ocp then
    local gender = heroProp.gender
    local ocpCfg = _G.GetOccupationCfg(ocp, gender)
    if ocpCfg then
      modelId = ocpCfg.modelId
    end
  end
  return modelId
end
def.method("number", "=>", "table").GetOccupationModelInfo = function(self, ocp)
  local heroProp = _G.GetHeroProp()
  local heroOccupation = heroProp.occupation
  local modelInfo = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):GetRoleModelInfo(gmodule.moduleMgr:GetModule(ModuleId.HERO).roleId)
  if heroOccupation ~= ocp then
    modelInfo = clone(modelInfo)
    local LoginUtility = require("Main.Login.LoginUtility")
    local createRoleCfg = LoginUtility.GetCreateRoleCfg(ocp, heroProp.gender)
    modelInfo.extraMap[ModelInfo.HAIR_COLOR_ID] = createRoleCfg.defaultHairDryId
    modelInfo.extraMap[ModelInfo.CLOTH_COLOR_ID] = createRoleCfg.defaultClothDryId
    modelInfo.extraMap[ModelInfo.FASHION_DRESS_ID] = FashionDressConst.NO_FASHION_DRESS
    modelInfo.extraMap[ModelInfo.QILING_EFFECT_LEVEL] = self:GetOcpQiLingEffectLevel(ocp)
    modelInfo.extraMap[ModelInfo.WEAPON] = nil
    local occupationBag = OcpEquipmentMgr.Instance():GetOccupationBag(ocp)
    if occupationBag then
      local item = occupationBag.items[WearPos.WEAPON]
      if item then
        modelInfo.extraMap[ModelInfo.WEAPON] = item.id
        modelInfo.extraMap[ModelInfo.QILING_LEVEL] = item.extraMap[ItemXStoreType.STRENGTH_LEVEL] or 0
      end
    end
    local try_evaluate = function(dst, src, key)
      dst[key] = src[key] and src[key] or dst[key]
    end
    local socpModelInfo = OcpEquipmentMgr.Instance():GetOccupationModelInfo(ocp)
    if socpModelInfo then
      try_evaluate(modelInfo.extraMap, socpModelInfo.extraMap, ModelInfo.HAIR_COLOR_ID)
      try_evaluate(modelInfo.extraMap, socpModelInfo.extraMap, ModelInfo.CLOTH_COLOR_ID)
      try_evaluate(modelInfo.extraMap, socpModelInfo.extraMap, ModelInfo.FASHION_DRESS_ID)
    end
  end
  return modelInfo
end
def.method("number", "=>", "number").GetOcpQiLingEffectLevel = function(self, ocp)
  local equipments = self:GetOccupationEquipments(ocp)
  return EquipUtils.CalcQiLingEffectLevel(equipments)
end
def.method("number", "function").AsyncLoadOccupationEquipments = function(self, occupation, onFinish)
  OcpEquipmentMgr.Instance():AsyncGetOccupationEquipments(occupation, function(equipments)
    if onFinish then
      onFinish(equipments)
    end
  end)
end
def.method().Clear = function(self)
  OcpEquipmentMgr.Instance():Clear()
end
InventoryDlgViewModel.Commit()
return InventoryDlgViewModel
