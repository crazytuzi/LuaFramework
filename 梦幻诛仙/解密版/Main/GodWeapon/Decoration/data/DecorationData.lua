local MODULE_NAME = (...)
local Lplus = require("Lplus")
local DecorationData = Lplus.Class("DecorationData")
local def = DecorationData.define
local instance
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = require("Main.Item.ItemModule")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local DecorationUtils = require("Main.GodWeapon.Decoration.DecorationUtils")
def.field("table")._ownedWSList = nil
def.field("table")._allClsWSCache = nil
def.field("table")._allWSList = nil
def.field("number")._timer = 0
def.const("number").CACHE_RELEASE_TIME = 60
def.static("=>", DecorationData).Instance = function()
  if instance == nil then
    instance = DecorationData()
  end
  return instance
end
def.method().UpdateWSInfoList = function(self)
  self._allWSList = nil
  self:GetWSInfoList()
end
local WuShiInfo = require("netio.protocol.mzm.gsp.superequipment.WuShiInfo")
def.method("=>", "table").GetWSInfoList = function(self)
  if self._allWSList ~= nil then
    return self._allWSList
  end
  local retData = {}
  local mapWSType = {}
  local arrOwndWS = self:GetOwnedWSList() or {}
  local heroProp = _G.GetHeroProp()
  for _, wsInfo in ipairs(arrOwndWS) do
    local wsBasicCfg = DecorationUtils.GetWSBasicCfgById(wsInfo.wuShiCfgId)
    local displayCfg = self:GetDisplayCfg(wsBasicCfg.displayTypeId, heroProp.occupation, heroProp.gender) or {}
    for k, v in pairs(wsBasicCfg) do
      wsInfo[k] = v
    end
    wsInfo.modelId = displayCfg.modelId
    wsInfo.scale = displayCfg.scale
    table.insert(retData, wsInfo)
    mapWSType[wsInfo.type] = 1
  end
  table.sort(retData, function(a, b)
    if a.isOn ~= nil and a.isOn == WuShiInfo.ON then
      return true
    elseif b.isOn ~= nil and b.isOn == WuShiInfo.ON then
      return false
    elseif b.isActivate ~= nil and b.isActivate == WuShiInfo.ACTIVATE then
      if a.isActivate ~= nil and b.isActivate == WuShiInfo.ACTIVATE then
        return a.level > b.level
      else
        return false
      end
    elseif a.isActivate ~= nil and a.isActivate == WuShiInfo.ACTIVATE then
      if b.isActivate ~= nil and b.isActivate == WuShiInfo.ACTIVATE then
        return a.level > b.level
      else
        return true
      end
    elseif a.level > b.level then
      return true
    elseif a.level <= b.level then
      return false
    end
  end)
  local arrAllWS = self:GetAllClsWs() or {}
  for i = 1, #arrAllWS do
    local wsBasicCfg = DecorationUtils.GetWSBasicCfgById(arrAllWS[i].cfgId) or {}
    local displayCfg = self:GetDisplayCfg(wsBasicCfg.displayTypeId or 0, heroProp.occupation, heroProp.gender)
    if wsBasicCfg ~= nil and displayCfg ~= nil and mapWSType[wsBasicCfg.type] == nil then
      wsBasicCfg.modelId = displayCfg.equipModelId
      wsBasicCfg.scale = displayCfg.scale
      table.insert(retData, wsBasicCfg)
    end
  end
  self._allWSList = retData
  return retData
end
def.method("=>", "table").GetOwnedWSList = function(self)
  self._ownedWSList = self._ownedWSList or {}
  return self._ownedWSList
end
def.method("table").SetOwnedWSList = function(self, list)
  self._ownedWSList = list
end
def.method("table").AddOwndWS = function(self, WSInfo)
  if WSInfo == nil then
    return
  end
  self._ownedWSList = self._ownedWSList or {}
  table.insert(self._ownedWSList, WSInfo)
end
def.method("number", "table").UpdateOwndWSInfo = function(self, WSCfgId, WSInfo)
  local owndWSList = self:GetOwnedWSList()
  if #owndWSList == 0 then
    table.insert(owndWSList, WSInfo)
  else
    for i = 1, #owndWSList do
      if owndWSList[i].id == WSCfgId then
        if WSInfo == nil then
          table.remove(owndWSList, i)
          break
        end
        owndWSList[i] = WSInfo
        break
      end
    end
  end
  self._allWSList = nil
  self:GetWSInfoList()
end
def.method("number").PutOnWS = function(self, WSCfgId)
  local allWSList = self:GetWSInfoList() or {}
  for i = 1, #allWSList do
    local WSInfo = allWSList[i]
    if WSInfo.isOn ~= nil then
      if WSInfo.id == WSCfgId then
        WSInfo.isOn = WuShiInfo.ON
      else
        WSInfo.isOn = WuShiInfo.OFF
      end
    else
      break
    end
  end
end
def.method("=>", "table").PutOffWS = function(self)
  local allWSList = self:GetWSInfoList() or {}
  local retData
  for i = 1, #allWSList do
    local WSInfo = allWSList[i]
    if WSInfo.isOn ~= nil then
      if WSInfo.isOn == WuShiInfo.ON then
        retData = WSInfo
      end
      WSInfo.isOn = WuShiInfo.OFF
    else
      break
    end
  end
  return retData
end
def.method("number", "=>", "table").GetOwndWSInfoByCfgId = function(self, cfgId)
  local owndWSList = self:GetOwnedWSList()
  if owndWSList == nil then
    return nil
  end
  for _, wsInfo in ipairs(owndWSList) do
    if wsInfo.wuShiCfgId == cfgId then
      return wsInfo
    end
  end
  return nil
end
def.method("number", "=>", "table").GetSameTypeWSInfo = function(self, cfgId)
  local WSCfg = DecorationUtils.GetWSBasicCfgById(cfgId)
  if WSCfg == nil then
    return nil
  end
  local owndWSList = self:GetOwnedWSList()
  for _, wsInfo in ipairs(owndWSList) do
    if wsInfo.type == nil then
      local curWSBasicCfg = DecorationUtils.GetWSBasicCfgById(wsInfo.wuShiCfgId)
      if curWSBasicCfg ~= nil and curWSBasicCfg.type == WSCfg.type then
        return wsInfo
      end
    elseif wsInfo.type == WSCfg.type then
      return wsInfo
    end
  end
  return nil
end
def.method("number", "=>", "table").GetItemIdsByWSCfgId = function(self, WSCfgId)
  local wsBasicCfg = DecorationUtils.GetWSBasicCfgById(WSCfgId)
  if wsBasicCfg == nil then
    return nil
  end
  if wsBasicCfg.nxtLvId <= 0 then
    return nil
  end
  local itemIdList = {}
  local WSItemIds = DecorationUtils.GetItemIdsByWuShiType(wsBasicCfg.type)
  if WSItemIds ~= nil then
    for i = 1, #WSItemIds.itemIds do
      local itemId = WSItemIds.itemIds[i]
      table.insert(itemIdList, itemId)
    end
  end
  table.insert(itemIdList, wsBasicCfg.fragsItemId)
  return itemIdList
end
def.method("=>", "table").GetMapOwndWS = function(self)
  local arrOwndWS = self:GetOwnedWSList() or {}
  local retData = {}
  for _, WSInfo in ipairs(arrOwndWS) do
    retData[WSInfo.wuShiCfgId] = WSInfo
  end
  return retData
end
def.method("=>", "table").GetAllClsWs = function(self)
  if self._allClsWSCache == nil then
    self._allClsWSCache = DecorationUtils.GetAllWSCls()
    self._timer = _G.GameUtil.AddGlobalTimer(DecorationData.CACHE_RELEASE_TIME, true, function()
      self._allClsWSCache = nil
    end)
  else
    _G.GameUtil.RemoveGlobalTimer(self._timer)
    self._timer = _G.GameUtil.AddGlobalTimer(DecorationData.CACHE_RELEASE_TIME, true, function()
      self._allClsWSCache = nil
    end)
  end
  return self._allClsWSCache
end
local ModelInfo = require("netio.protocol.mzm.gsp.pubdata.ModelInfo")
def.method("number", "=>", "table").GetOccupationModelInfo = function(self, ocp)
  local heroProp = _G.GetHeroProp()
  local heroOccupation = heroProp.occupation
  local tmodelInfo = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):GetRoleModelInfo(gmodule.moduleMgr:GetModule(ModuleId.HERO).roleId)
  local modelInfo = clone(tmodelInfo)
  if heroOccupation ~= ocp then
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
def.method("=>", "number").GetHeroModelId = function(self)
  local pubMgr = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
  local myRole = pubMgr:GetRole(_G.GetHeroProp().id)
  if myRole then
    return myRole.mModelId
  else
    return 0
  end
end
def.method("number", "number", "number", "=>", "table").GetDisplayCfg = function(self, typeId, occupation, gender)
  local displayCfg = DecorationUtils.GetAppearanceByTypeId(typeId)
  if displayCfg == nil then
    return nil
  end
  for _, appearance in ipairs(displayCfg.apperances) do
    if appearance.occupation == occupation and appearance.gender == gender then
      return appearance
    end
  end
  return nil
end
def.method("number", "number", "=>", "table").GetDisplayCfgIgnoreOccup = function(self, typeId, gender)
  local displayCfg = DecorationUtils.GetAppearanceByTypeId(typeId)
  if displayCfg == nil then
    return nil
  end
  for _, appearance in ipairs(displayCfg.apperances) do
    if appearance.gender == gender then
      return appearance
    end
  end
  return nil
end
def.method("number", "number", "=>", "table").GetDisplayCfgByModelId = function(self, typeId, modelId)
  local displayCfg = DecorationUtils.GetAppearanceByTypeId(typeId)
  if displayCfg == nil then
    return nil
  end
  for _, appearance in ipairs(displayCfg.apperances) do
    if appearance.curModelId == modelId then
      return appearance
    end
  end
  return nil
end
def.method("number", "number", "number", "=>", "number").GetWeaponIdByWSCfgId = function(self, cfgId, occupation, gender)
  if cfgId < 1 then
    return 0
  end
  local wsBasicCfg = DecorationUtils.GetWSBasicCfgById(cfgId)
  if wsBasicCfg ~= nil then
    local displayCfg = self:GetDisplayCfg(wsBasicCfg.displayTypeId, occupation, gender)
    return displayCfg and displayCfg.equipModelId or 0
  end
  return 0
end
def.method("=>", "table").GetItemIds = function(self)
  local itemIds = {}
  local frags = ItemModule.Instance():GetItemsByItemType(ItemType.WU_SHI_FRAGMENT_ITEM)
  local WSItems = ItemModule.Instance():GetItemsByItemType(ItemType.WU_SHI_ITEM)
  for itemKey, item in pairs(frags) do
    table.insert(itemIds, item.id)
  end
  for _, item in pairs(WSItems) do
    table.insert(itemIds, item.id)
  end
  return itemIds
end
return DecorationData.Commit()
