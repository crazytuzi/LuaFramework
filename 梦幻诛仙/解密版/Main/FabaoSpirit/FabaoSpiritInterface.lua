local MODULE_NAME = (...)
local Lplus = require("Lplus")
local FabaoSpiritInterface = Lplus.Class(MODULE_NAME)
local def = FabaoSpiritInterface.define
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = require("Main.Item.ItemModule")
local FabaoSpiritModule = require("Main.FabaoSpirit.FabaoSpiritModule")
local FabaoSpiritUtils = require("Main.FabaoSpirit.FabaoSpiritUtils")
local defaultLayer = ClientDef_Layer.UI_Model1
def.static("number", "=>", "number", "number").GetItemsNumByFilterId = function(filterItemId)
  local itemFilterCfg = ItemUtils.GetItemFilterCfg(filterItemId)
  if itemFilterCfg.siftCfgs == nil then
    return 0
  end
  local ret = 0
  local firstItemId = 0
  for i = 1, #itemFilterCfg.siftCfgs do
    local itemId = itemFilterCfg.siftCfgs[i].idvalue
    local num = ItemModule.Instance():GetNumberByItemId(ItemModule.BAG, itemId)
    ret = ret + num
    if i == 1 then
      firstItemId = itemId
    end
  end
  return ret, firstItemId
end
def.static("table", "=>", "table").transArrTotbl = function(arrProp)
  local retData = {}
  for i = 1, #arrProp do
    retData[arrProp[i].propType] = arrProp[i]
  end
  return retData
end
def.static("number", "=>", "table").FormatLeftTime = function(leftTime)
  local retData = {
    day = 0,
    hour = 0,
    min = 0,
    sec = 0
  }
  if leftTime >= 86400 then
    retData.day = math.floor(leftTime / 86400)
    retData.hour = math.floor(leftTime % 86400 / 3600)
  elseif leftTime >= 3600 then
    retData.hour = math.floor(leftTime / 3600)
    retData.min = math.floor(leftTime % 3600 / 60)
  elseif leftTime >= 60 then
    retData.min = math.floor(leftTime / 60)
    retData.sec = math.floor(leftTime % 60)
  else
    retData.sec = leftTime
  end
  return retData
end
def.static("table", "=>", "string").TimeToString = function(tblTime)
  local TEX = textRes.FabaoSpirit
  if tblTime.day ~= 0 then
    return TEX[25]:format(tblTime.day, TEX[7], tblTime.hour, TEX[8])
  elseif tblTime.hour ~= 0 then
    return TEX[25]:format(tblTime.hour, TEX[8], tblTime.min, TEX[9])
  elseif tblTime.min ~= 0 then
    return TEX[25]:format(tblTime.min, TEX[9], tblTime.sec, TEX[10])
  else
    return tblTime.sec .. TEX[10]
  end
end
def.static("=>", "table", "number").GetOwnedLQsAllInfos = function()
  local ownedLQInfos = FabaoSpiritModule.GetOwnedLQInfos()
  local retData = {}
  retData.arrSkillIds = {}
  retData.tblProps = {}
  local propTypeNum = 0
  local skills = {}
  for clsId, ownLQInfo in pairs(ownedLQInfos) do
    local LQClsCfg = FabaoSpiritUtils.GetLQClsCfgByClsId(clsId)
    local lv = 1
    if #LQClsCfg.arrCfgId ~= 1 then
      lv = ownLQInfo.level
    end
    local cfgId = LQClsCfg.arrCfgId[lv]
    local basicCfg = FabaoSpiritUtils.GetFabaoLQCfg(cfgId)
    if basicCfg and basicCfg.skillId ~= 0 then
      skills[basicCfg.skillId] = 0
    end
    local propCfg = FabaoSpiritUtils.GetFabaoLQPropCfgById(cfgId)
    if propCfg ~= nil then
      for i = 1, #propCfg.arrPropValues do
        local prop = propCfg.arrPropValues[i]
        local curVal = ownLQInfo.properties[prop.propType]
        local dstVal = prop.dstVal
        if retData.tblProps[prop.propType] == nil then
          retData.tblProps[prop.propType] = {}
          propTypeNum = propTypeNum + 1
        end
        local retTblProp = retData.tblProps[prop.propType]
        retTblProp.curVal = (retTblProp.curVal or 0) + curVal
        retTblProp.dstVal = (retTblProp.dstVal or 0) + dstVal
      end
    end
  end
  for skillId, _ in pairs(skills) do
    table.insert(retData.arrSkillIds, skillId)
  end
  return retData, propTypeNum
end
def.static("number", "=>", "table").GetClsCfgByItemId = function(itemId)
  local retData
  local itemCfg = FabaoSpiritUtils.GetItemCfgByItemId(itemId)
  if itemCfg == nil then
    return retData
  end
  local LQBasicCfg = FabaoSpiritUtils.GetFabaoLQCfg(itemCfg.LQCfgId)
  if LQBasicCfg == nil then
    return retData
  end
  local clsCfg = FabaoSpiritUtils.GetLQClsCfgByClsId(LQBasicCfg.classId)
  if clsCfg == nil then
    return retData
  end
  retData = {}
  retData.clsCfg = clsCfg
  retData.LQBasicCfg = LQBasicCfg
  return retData
end
def.static("=>", "table").GetOwnedLQBasicInfos = function()
  local ownedLQInfos = FabaoSpiritModule.GetOwnedLQInfos()
  local retData = {}
  if ownedLQInfos == nil then
    return retData
  end
  for clsId, ownLQInfo in pairs(ownedLQInfos) do
    local LQClsCfg = FabaoSpiritUtils.GetLQClsCfgByClsId(clsId)
    local lv = 1
    if #LQClsCfg.arrCfgId ~= 1 then
      lv = ownLQInfo.level
    end
    local cfgId = LQClsCfg.arrCfgId[lv]
    local basicCfg = FabaoSpiritUtils.GetFabaoLQCfg(cfgId)
    local data = {}
    data.level = ownLQInfo.level
    data.name = basicCfg.name
    data.icon = basicCfg.icon
    data.classId = clsId
    data.itemId = FabaoSpiritUtils.GetItemIdByCfgId(cfgId)
    retData[clsId] = data
  end
  return retData
end
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
def.static("number").ShowSelfLQTips = function(clsId)
  local ownedLQInfo = FabaoSpiritModule.GetOwnedLQInfos()[clsId]
  if ownedLQInfo ~= nil then
    local LQClsCfg = FabaoSpiritUtils.GetLQClsCfgByClsId(clsId)
    ownedLQInfo.class_id = clsId
    local cfgId = FabaoSpiritInterface.GetLQCfgIDByLQInfo(ownedLQInfo)
    local itemId = FabaoSpiritUtils.GetItemIdByCfgId(cfgId)
    local itemBase = ItemUtils.GetItemBase(itemId)
    if clsId ~= FabaoSpiritModule.GetEquipedLQClsId() then
      ownedLQInfo.bIsEquip = false
    else
      ownedLQInfo.bIsEquip = true
    end
    ItemTipsMgr.Instance():ShowFabaoLQWearTips(ownedLQInfo, itemBase, ItemTipsMgr.Source.Equip, 0, 0, 0, 0, 0, false)
  end
end
def.static("userdata", "number").ShowRoleLQTips = function(roleId, clsId)
  local Protocols = require("Main.FabaoSpirit.FabaoSpiritProtocols")
  Protocols.SendQueryRoleLQInfo(roleId, clsId)
end
def.static("number", "=>", "table").GetOwnLQBasicInfoByClsId = function(clsId)
  local retData
  local ownedLQInfos = FabaoSpiritModule.GetOwnedLQInfos()
  local ownLQInfo = ownedLQInfos[clsId]
  if ownLQInfo == nil then
    return retData
  end
  local LQClsCfg = FabaoSpiritUtils.GetLQClsCfgByClsId(clsId)
  if LQClsCfg == nil then
    return retData
  end
  local lv = 1
  if #LQClsCfg.arrCfgId ~= 1 then
    lv = ownLQInfo.level
  end
  local cfgId = LQClsCfg.arrCfgId[lv]
  local basicCfg = FabaoSpiritUtils.GetFabaoLQCfg(cfgId)
  retData = {}
  retData.level = ownLQInfo.level
  retData.name = basicCfg.name
  retData.icon = basicCfg.icon
  retData.classId = clsId
  retData.itemId = FabaoSpiritUtils.GetItemIdByCfgId(cfgId)
  return retData
end
def.static("table", "=>", "number").GetLQCfgIDByLQInfo = function(ownLQInfo)
  if ownLQInfo == nil then
    return 0
  end
  local LQClsId = ownLQInfo.class_id
  local LQClsCfg = FabaoSpiritUtils.GetLQClsCfgByClsId(LQClsId)
  local lv = 1
  if #LQClsCfg.arrCfgId ~= 1 then
    lv = ownLQInfo.level
  end
  local cfgId = LQClsCfg.arrCfgId[lv]
  return cfgId
end
local ECFxMan = require("Fx.ECFxMan")
local EC = require("Types.Vector3")
def.static("number", "userdata", "table")._addBoneEffect = function(effectId, model, effects)
  if model == nil or model.isnil then
    return
  end
  if effectId <= 0 then
    return
  end
  local boneEffect = GetBoneAddEffect(effectId)
  if boneEffect ~= nil then
    for k, v in ipairs(boneEffect.boneaddeffect) do
      local effres = GetEffectRes(v.effect)
      local bone = v.bone
      print(effres.path, bone)
      local position = EC.Vector3.zero
      local rotation = Quaternion.identity
      local duration = -1
      local parent = model:FindChild(bone)
      local highres = false
      local effect = ECFxMan.Instance():PlayAsChild(effres.path, parent, position, rotation, duration, highres, defaultLayer)
      if effect then
        effect:SetLayer(defaultLayer)
        effect:GetComponent("FxOne"):set_Stable(true)
        table.insert(effects, effect)
      end
    end
  end
end
def.static("table")._rmvModelEffects = function(effects)
  if effects == nil then
    return
  end
  for k, v in ipairs(effects) do
    ECFxMan.Instance():Stop(v)
  end
end
return FabaoSpiritInterface.Commit()
