local ModelInfo = require("netio.protocol.mzm.gsp.pubdata.ModelInfo")
local Vector = require("Types.Vector")
local FightMgr = require("Main.Fight.FightMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local MallPanel = require("Main.Mall.ui.MallPanel")
local MailModule = require("Main.Mall.MallModule")
local ECFxMan = require("Fx.ECFxMan")
local HeroInterface = require("Main.Hero.Interface")
local DyeData = require("Main.Dyeing.data.DyeData")
local EquipUtils = require("Main.Equip.EquipUtils")
local ItemModule = require("Main.Item.ItemModule")
local Octets = require("netio.Octets")
local MapModelInfo = require("netio.protocol.mzm.gsp.map.MapModelInfo")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local FashionShowType = require("consts.mzm.gsp.fashiondress.confbean.FashionShowType")
local GameUnitType = require("consts/mzm/gsp/common/confbean/GameUnitType")
local ECUIModel = require("Model.ECUIModel")
local NpcModel = require("Main.Pubrole.NpcModel")
local GUIUtils = require("GUI.GUIUtils")
local ProValueType = require("consts.mzm.gsp.common.confbean.ProValueType")
local GenderEnum = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
_G.GenderEnum = GenderEnum
local occupationCfgs
function _G.GetOccupationCfg(occupation, gender)
  if occupationCfgs == nil then
    local entries = DynamicData.GetTable(CFG_PATH.DATA_OCCUPATION_PROP_TABLE)
    local count = DynamicDataTable.GetRecordsCount(entries)
    occupationCfgs = {}
    local cfg = {}
    DynamicDataTable.FastGetRecordBegin(entries)
    for i = 0, count - 1 do
      local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
      cfg.occupation = DynamicRecord.GetIntValue(entry, "occupationId")
      cfg.gender = DynamicRecord.GetIntValue(entry, "gender")
      local ocfg = {}
      ocfg.modelId = DynamicRecord.GetIntValue(entry, "modelPath")
      ocfg.occupationName = DynamicRecord.GetStringValue(entry, "occupationName")
      ocfg.occupationMapId = DynamicRecord.GetIntValue(entry, "occupationMapId")
      ocfg.occupationDesc = DynamicRecord.GetStringValue(entry, "occupationDesc")
      ocfg.isAssist = DynamicRecord.GetCharValue(entry, "isAssist") ~= 0
      ocfg.switchId = DynamicRecord.GetIntValue(entry, "switchId")
      ocfg.defaultAvatarId = DynamicRecord.GetIntValue(entry, "defaultAvatarId")
      occupationCfgs[cfg.occupation] = occupationCfgs[cfg.occupation] or {}
      occupationCfgs[cfg.occupation][cfg.gender] = ocfg
    end
    DynamicDataTable.FastGetRecordEnd(entries)
  end
  return occupationCfgs[occupation] and occupationCfgs[occupation][gender] or nil
end
function _G.GetOccupationName(occupId)
  local occupationCfg = _G.GetOccupationCfg(occupId, GenderEnum.MALE)
  return occupationCfg and occupationCfg.occupationName or ""
end
function _G.GetIconPath(iconId)
  local resPath, resType
  local iconRecord = DynamicData.GetRecord(CFG_PATH.DATA_ICONRES, iconId)
  if iconRecord ~= nil then
    local cfgpath = iconRecord:GetStringValue("path")
    if cfgpath and cfgpath ~= "" then
      resPath = cfgpath and cfgpath .. ".u3dext"
    else
      warn("respath is empty for iconId: ", iconId)
    end
    resType = iconRecord:GetIntValue("iconType")
  end
  return resPath or "", resType or -1
end
function _G.GetSpritePath(iconId)
  local atlasPath, spriteName
  local iconRecord = DynamicData.GetRecord(CFG_PATH.DATA_ICONRES, iconId)
  if iconRecord ~= nil then
    local cfgpath = iconRecord:GetStringValue("path")
    if cfgpath and cfgpath ~= "" then
      atlasPath = cfgpath .. ".u3dext"
    else
      warn("atlasPath is empty for iconId: ", iconId)
    end
    spriteName = iconRecord:GetStringValue("spriteName")
  else
    warn("atlasPath is nil for iconId: ", iconId)
  end
  return atlasPath or "", spriteName or ""
end
function _G.GetModelPath(modelId)
  local modelRecord = DynamicData.GetRecord(CFG_PATH.DATA_MODEL_CONFIG, modelId)
  if modelRecord == nil then
    if modelId == nil then
      warn("_G.GetModelPath( nil ) == nil")
    else
      warn(string.format("_G.GetModelPath( %d ) == nil", modelId))
    end
    return ""
  end
  local path = modelRecord:GetStringValue("modelResPath")
  if path == nil or path == "" then
    warn(string.format("model cfg is nil or empty for id: %d", modelId))
    return ""
  end
  if string.lower(string.sub(path, -4, -1)) == ".fbx" then
    return path
  else
    path = string.format("%s.u3dext", path)
  end
  local color = modelRecord:GetIntValue("dyeColorId")
  return path, color
end
function _G.GetHalfBodyCfg(headidx)
  local cfg = {}
  cfg.path, cfg.type = GetIconPath(headidx)
  return cfg
end
function _G.GetSkillCfg(skillId)
  if skillId == nil or skillId == 0 then
    return
  end
  local record = DynamicData.GetRecord(CFG_PATH.DATA_SKILL_CFG, skillId)
  if record == nil then
    warn("skill cfg record is nil for id: ", skillId)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.name = record:GetStringValue("name")
  cfg.icon = record:GetIntValue("icon")
  cfg.cdRound = record:GetIntValue("cdRound")
  cfg.canAuto = record:GetCharValue("canAuto") ~= 0
  cfg.displayInFight = record:GetCharValue("displayInFight") ~= 0
  cfg.condition = record:GetIntValue("condition")
  cfg.skillType = record:GetIntValue("type")
  cfg.specialType = record:GetIntValue("specialType")
  cfg.skillPlayid = record:GetIntValue("skillPlayid")
  cfg.description = record:GetStringValue("description")
  cfg.simpleDesc = record:GetStringValue("simpleDesc")
  cfg.skilltargettype1 = record:GetIntValue("skilltargettype1")
  cfg.skilltargettype2 = record:GetIntValue("skilltargettype2")
  cfg.skilltargettype3 = record:GetIntValue("skilltargettype3")
  cfg.skilltargettype4 = record:GetIntValue("skilltargettype4")
  cfg.count = record:GetIntValue("count")
  return cfg
end
function _G.GetEffectRes(id)
  if id == 0 then
    return nil
  end
  local record = DynamicData.GetRecord(CFG_PATH.DATA_EFFECTSOURCE_CFG, id)
  if record == nil then
    warn("effect res cfg record is nil for id: ", id)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.path = record:GetStringValue("path")
  if cfg.path and cfg.path ~= "" then
    cfg.path = cfg.path .. ".u3dext"
  else
    warn("effect res path is nil or empty for id: ", id)
    return nil
  end
  cfg.sound = record:GetIntValue("sound")
  cfg.rotate = record:GetIntValue("rotate")
  return cfg
end
function _G.GetNameColorCfg(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_FONTANDCOLORTABLE_CFG, id)
  if record == nil then
    warn("name color cfg record is nil for id: ", id)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.r = record:GetIntValue("R")
  cfg.g = record:GetIntValue("G")
  cfg.b = record:GetIntValue("B")
  return cfg
end
local colorcfgCache = {}
function _G.GetColorData(id)
  local color = colorcfgCache[id]
  if color == nil then
    local record = DynamicData.GetRecord(CFG_PATH.DATA_FONTANDCOLORTABLE_CFG, id)
    if record == nil then
      warn("name color cfg record is nil for id: ", id)
      return nil
    end
    local r = record:GetIntValue("R")
    local g = record:GetIntValue("G")
    local b = record:GetIntValue("B")
    color = Color.Color(r / 255, g / 255, b / 255, 1)
    colorcfgCache[id] = color
  end
  return color
end
function _G.GetModelColorCfg(id)
  local record = DynamicData.GetRecord(CFG_PATH.MODEL_COLOR_CFG, id)
  if record == nil then
    print("model color cfg record is nil for id: ", id)
    return nil
  end
  local cfg = {}
  cfg.partNum = record:GetIntValue("partNum")
  cfg.part1_r = record:GetIntValue("part1R")
  cfg.part1_g = record:GetIntValue("part1G")
  cfg.part1_b = record:GetIntValue("part1B")
  cfg.part1_a = record:GetIntValue("part1Light")
  cfg.part2_r = record:GetIntValue("part2R")
  cfg.part2_g = record:GetIntValue("part2G")
  cfg.part2_b = record:GetIntValue("part2B")
  cfg.part2_a = record:GetIntValue("part2Light")
  cfg.part3_r = record:GetIntValue("part3R")
  cfg.part3_g = record:GetIntValue("part3G")
  cfg.part3_b = record:GetIntValue("part3B")
  cfg.part3_a = record:GetIntValue("part3Light")
  return cfg
end
function _G.GetAppearanceCfg(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MODEL_FIGURE, id)
  if record == nil then
    warn("GetAppearanceCfg get nil record for id: ", id)
    return nil
  end
  local cfg = {}
  cfg.id = DynamicRecord.GetIntValue(record, "id")
  cfg.weaponId = DynamicRecord.GetIntValue(record, "weaponId")
  cfg.wingId = DynamicRecord.GetIntValue(record, "wingId")
  cfg.horseid = DynamicRecord.GetIntValue(record, "horseid")
  cfg.flyMountId = DynamicRecord.GetIntValue(record, "flyMountId")
  cfg.faBaoId = DynamicRecord.GetIntValue(record, "faBaoId")
  cfg.scaleRate = DynamicRecord.GetIntValue(record, "scaleRate") / 100
  cfg.isShowDecorateItem = DynamicRecord.GetCharValue(record, "isShowDecorateItem") ~= 0
  return cfg
end
function _G.GetModelChangeCfg(id)
  local record = DynamicData.GetRecord(CFG_PATH.MODEL_CHANGE_CFG, id)
  if record == nil then
    warn("GetModelChangeCfg get nil record for id: ", id)
    return nil
  end
  local cfg = {}
  cfg.modelId = DynamicRecord.GetIntValue(record, "modelId")
  cfg.showOriginalWeapon = DynamicRecord.GetCharValue(record, "showOriginalWeapon") ~= 0
  cfg.weaponId = DynamicRecord.GetIntValue(record, "weaponId")
  cfg.showOriginalWing = DynamicRecord.GetCharValue(record, "showOriginalWing") ~= 0
  cfg.wingId = DynamicRecord.GetIntValue(record, "wingId")
  cfg.showOriginalFabao = DynamicRecord.GetCharValue(record, "showOriginalFabao") ~= 0
  cfg.fabaoId = DynamicRecord.GetIntValue(record, "fabaoId")
  cfg.showOriginalMount = DynamicRecord.GetCharValue(record, "showOriginalMount") ~= 0
  cfg.mountId = DynamicRecord.GetIntValue(record, "mountId")
  cfg.showOriginalAirCraft = DynamicRecord.GetCharValue(record, "showOriginalAirCraft") ~= 0
  cfg.aircraftId = DynamicRecord.GetIntValue(record, "aircraftId")
  cfg.showInFight = DynamicRecord.GetCharValue(record, "showInFight") ~= 0
  cfg.priority = DynamicRecord.GetIntValue(record, "priority")
  return cfg
end
function _G.GetChangeDressCfg(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_UTILS_CChangeFashionCfg, id)
  if record == nil then
    warn("GetChangeDressCfg get nil record for id: ", id)
    return nil
  end
  local cfg = {}
  cfg.changeType = DynamicRecord.GetIntValue(record, "changeType")
  cfg.modelId = DynamicRecord.GetIntValue(record, "modelCfgid")
  cfg.hairId = DynamicRecord.GetIntValue(record, "hairCfgid")
  cfg.bodyId = DynamicRecord.GetIntValue(record, "bodyCfgid")
  return cfg
end
function _G.GetWantedNameColor(moral)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_WANTED_NAME_COLOR_CFG)
  DynamicDataTable.SetCache(entries, true)
  local size = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, size - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local moralValue = record:GetIntValue("moralValue")
    local colorCfgId = record:GetIntValue("colorCfgId")
    cfgs[#cfgs + 1] = {k = moralValue, v = colorCfgId}
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  table.sort(cfgs, function(a, b)
    if a == nil or b == nil then
      return false
    else
      return a.k < b.k
    end
  end)
  for i = 1, #cfgs do
    if moral <= cfgs[i].k then
      return cfgs[i].v
    end
  end
  return 0
end
function _G.GetEquipmentModelCfg(id)
  local record = DynamicData.GetRecord(CFG_PATH.EQUIP_MODEL_CFG, id)
  if record == nil then
    print("CEquipModelCfg got nil record for id: ", id)
    return nil
  end
  return record:GetStringValue("resPath")
end
function _G.UnmarshalBean(beanclass, data)
  if data == nil or beanclass == nil then
    return nil
  end
  local bean = beanclass.new()
  Octets.unmarshalBean(data, bean)
  return bean
end
function _G.GetModelInfo(data)
  if data == nil then
    return nil
  end
  local modelInfo = MapModelInfo.new()
  Octets.unmarshalBean(data, modelInfo)
  return modelInfo
end
local m_serverStartTickCount = 0
local m_clientStartTickCount = 0
local m_serverZoneOffset = 0
function _G.SetServerTime(serverTickCount, zoneOffset)
  m_clientStartTickCount = GameUtil.GetTickCount()
  m_serverStartTickCount = serverTickCount
  m_serverZoneOffset = zoneOffset
end
function _G.GetServerZoneOffset()
  return m_serverZoneOffset
end
function _G.GetServerTime()
  local curTickCount = GameUtil.GetTickCount()
  return m_serverStartTickCount + math.floor((curTickCount - m_clientStartTickCount) / 1000)
end
function _G.GetServerSeconds()
  return m_serverStartTickCount
end
function _G.GetFormatItemNumString(haveNum, neededNum)
  if haveNum < neededNum then
    return string.format(textRes.Common[11], haveNum, neededNum)
  else
    return string.format(textRes.Common[12], haveNum, neededNum)
  end
end
function _G.GetTipCfg(tipId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TIP_LIB_CFG, tipId)
  if record == nil then
    warn(string.format("Missing tip cfg id = %d", tipId))
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.maxLevel = record:GetIntValue("maxLevel")
  cfg.minLevel = record:GetIntValue("minLevel")
  cfg.tipContent = record:GetStringValue("tipcontent")
  return cfg
end
function _G.GetRandomTip()
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local level = 0
  if heroProp ~= nil then
    level = heroProp.level
  end
  local TipsHelper = require("Main.Common.TipsHelper")
  local tip = TipsHelper.Instance():GetRandomTip(level)
  return tip
end
function _G.GetCommonPropNameCfg(key)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_COMMON_PROPERTYNAME_CFG, key)
  if record == nil then
    warn(string.format("Missing propperty name cfg key = %d", key))
    return nil
  end
  local cfg = {}
  cfg.propValue = record:GetIntValue("propValue")
  cfg.propName = record:GetStringValue("propName")
  cfg.propTips = record:GetStringValue("propTips")
  cfg.isGood = record:GetCharValue("isGood") ~= 0
  cfg.valueType = record:GetIntValue("valueType")
  cfg.sort = record:GetIntValue("sort")
  return cfg
end
function _G.PropValueToText(value, valueType)
  local prefix, absValue
  if value >= 0 then
    prefix = textRes.Common.Plus
    absValue = value
  else
    prefix = textRes.Common.Minus
    absValue = -value
  end
  local valueText
  if valueType == ProValueType.TEN_THOUSAND_RATE then
    valueText = string.format("%s%s", absValue / 100, textRes.Common.Percent)
  else
    valueText = tostring(absValue)
  end
  return string.format("%s%s", prefix, valueText)
end
local TIAN_YIN_NV_WEAPON_BONES = {
  "Root/Bip01 Pelvis/Bip01 Spine/Bip01_LeftWeapon/Bip01_LeftWeapon01/Bip01_LeftWeapon02/Bip01_LeftWeapon03",
  "Root/Bip01 Pelvis/Bip01 Spine/Bip01_RightWeapon/Bip01_RightWeapon01/Bip01_RightWeapon02/Bip01_RightWeapon03"
}
local TIAN_YIN_NV_MODEL_ID = 700300007
function _G.SetModelWeapon(model, id, lightLevel, modelInfo)
  if model == nil or model:IsDestroyed() then
    return
  end
  if model.mModelId == TIAN_YIN_NV_MODEL_ID then
    if model.weaponInfo == nil then
      model.weaponInfo = {}
    end
    model.weaponInfo.weaponId = id
    model.weaponInfo.lightLevel = lightLevel
    model.weaponInfo.modelInfo = modelInfo
    if id > 0 then
      do
        local equipRecord = DynamicData.GetRecord(CFG_PATH.DATA_EQQUIPCFG, id)
        if equipRecord == nil then
          return
        end
        local _modelid = equipRecord:GetIntValue("equipmodel")
        if modelInfo and modelInfo.equipModelId and 0 < modelInfo.equipModelId then
          _modelid = modelInfo.equipModelId
        end
        local lightEffectId = equipRecord:GetIntValue("lightEffectId")
        if modelInfo and modelInfo.effectId and 0 < modelInfo.effectId then
          lightEffectId = modelInfo.effectId
        end
        local equipRes = GetEquipmentModelCfg(_modelid)
        if equipRes == nil or equipRes == "" then
          return
        end
        local suffix = string.sub(equipRes, -4, -1)
        if string.lower(suffix) ~= ".fbx" then
          Debug.LogWarning(string.format("invalid change_equip_weapon res: char_model_id(%d), weaponId(%d), weapon_model_id(%d), equip_res(%s)", model.mModelId, id, _modelid, equipRes))
          return
        end
        model:ChangeEquip("Weapon", equipRes .. ".lua", false, function()
          local weapon_color = modelInfo and lightLevel or 0
          if weapon_color > 0 then
            SetModelWeaponColor(model, weapon_color)
          end
          model:RemoveEquipLightEffect(TIAN_YIN_NV_WEAPON_BONES)
          if lightEffectId > 0 then
            local eff = GetEffectRes(lightEffectId)
            if eff then
              model:SetEquipLightEffect(TIAN_YIN_NV_WEAPON_BONES, eff.path)
            end
          end
          if model:tryget("ReFly") then
            model:ReFly()
          end
        end)
      end
    else
      model:RemoveEquipLightEffect(TIAN_YIN_NV_WEAPON_BONES)
      model:RemoveEquip("Weapon")
    end
    return
  end
  if model.mECPartComponent == nil then
    model.mECPartComponent = require("Model.ECPartComponent").new(model)
    model.mECPartComponent.defaultLayer = model.defaultLayer
  else
    model.mECPartComponent:SetCharModel(model)
  end
  if model.mECPartComponent then
    if id > 0 then
      model.mECPartComponent:LoadRes(id, lightLevel, modelInfo)
    else
      model.mECPartComponent:Destroy()
    end
  end
end
function _G.SetModelWeaponAppearance(model, modelInfo)
  if model == nil or model:IsDestroyed() then
    return
  end
  if model.mModelId == TIAN_YIN_NV_MODEL_ID then
    local _weaponid = model.weaponInfo and model.weaponInfo.weaponId or 0
    local _lightLevel = model.weaponInfo and model.weaponInfo.lightLevel or 0
    SetModelWeapon(model, _weaponid, _lightLevel, modelInfo)
    return
  end
  if model.mECPartComponent == nil then
    return
  end
  model.mECPartComponent:SetModelInfo(modelInfo)
end
function _G.SetChildWeapon(model, child_weapon_id, lightLevel)
  local cfg
  if child_weapon_id and child_weapon_id > 0 then
    cfg = require("Main.Children.ChildrenUtils").GetChildEquipItem(child_weapon_id)
  end
  local weapon_model_id = cfg and cfg.modelId or 0
  if model.mECPartComponent == nil then
    if weapon_model_id > 0 then
      model.mECPartComponent = require("Model.ECPartComponent").new(model)
      model.mECPartComponent.defaultLayer = model.defaultLayer
    end
  else
    model.mECPartComponent:SetCharModel(model)
  end
  local function loadWeapon()
    if model.mECPartComponent then
      if weapon_model_id > 0 then
        model.mECPartComponent:LoadSingleWeaponByModelId(weapon_model_id)
      else
        model.mECPartComponent:Destroy()
      end
    end
  end
  if model:IsInLoading() then
    model:AddOnLoadCallback("SetChildWeapon", loadWeapon)
  else
    loadWeapon()
  end
end
function _G.ScaleModelWeaponEffect(model, isFly)
  if model == nil or model:IsDestroyed() then
    return
  end
  if model.mModelId == TIAN_YIN_NV_MODEL_ID then
    model:ScaleEquipLightEffect(TIAN_YIN_NV_WEAPON_BONES, isFly)
  elseif model.mECPartComponent then
    model.mECPartComponent:ScaleEquipLightEffect(isFly)
  end
end
local WearPos = require("consts.mzm.gsp.item.confbean.WearPos")
local weapon_color1 = Color.Color(0, 0, 0, 0)
local weapon_color2 = Color.Color(0, 0, 0, 0)
function _G.SetModelWeaponColor(model, lightLevel)
  if model.m_model == nil then
    return
  end
  if model.mModelId == TIAN_YIN_NV_MODEL_ID then
    local color
    local weaponObj = model.m_model:FindDirect("Weapon")
    if weaponObj == nil then
      return
    end
    local renders = weaponObj:GetRenderersInChildren()
    if model.weaponInfo.modelInfo == nil then
      local weapon = ItemModule.Instance():GetHeroEquipmentCfg(WearPos.WEAPON)
      if weapon == nil then
        return
      end
      local partInfo = EquipUtils.GetEquipBasicInfo(weapon.id)
      if partInfo == nil then
        return
      end
      color = GetMostAppropriateLightLevel(partInfo.equipmodel, lightLevel)
    end
    if color then
      AssignColor(weapon_color1, color.color1)
      AssignColor(weapon_color2, color.color2)
      for _, r in pairs(renders) do
        r.material:EnableKeyword("FlowingLightOn")
        if color1 then
          r.material:SetColor("_FlowingColor", color1)
        end
        if color2 then
          r.material:SetColor("_FlowingColor2", color2)
        end
      end
    else
      for _, r in pairs(renders) do
        r.material:DisableKeyword("FlowingLightOn")
      end
    end
  elseif model.mECPartComponent then
    model.mECPartComponent:ResetLightEffect(lightLevel)
  end
end
function _G.GetMostAppropriateLightLevel(weaponModelId, lightLevel)
  do return EquipUtils.GetWeaponColor(weaponModelId, lightLevel) end
  local color
  while color == nil do
    color = EquipUtils.GetWeaponColor(weaponModelId, lightLevel)
    if color or lightLevel < 12 then
      break
    else
      lightLevel = lightLevel - 1
    end
  end
  return color
end
function _G.IsModelInModelChangeCostume(model)
  if model.costumeInfo == nil then
    return false
  end
  return model.costumeInfo.showType == FashionShowType.REPLACE
end
function _G.ChangeRoleModelWithModelInfo(role, roleModelInfo, modelChangeCfgId, hairColor, clothColor)
  if role == nil or role:IsDestroyed() or roleModelInfo == nil then
    return
  end
  local function LoadNewModel()
    local cfg = GetModelChangeCfg(modelChangeCfgId)
    if cfg == nil then
      return
    end
    if cfg.modelId ~= role.mModelId then
      role:ChangeModel(cfg.modelId)
    end
    if role:tryget("SetState") then
      role:SetState(RoleState.TRANSFORM)
    end
    local modelInfo = ModelInfo.new()
    if not cfg.showOriginalWeapon then
      modelInfo.extraMap[ModelInfo.WEAPON] = cfg.weaponId
    else
      modelInfo.extraMap[ModelInfo.WEAPON] = roleModelInfo.extraMap[ModelInfo.WEAPON] or 0
    end
    if not cfg.showOriginalWing then
      modelInfo.extraMap[ModelInfo.WING] = cfg.wingId
    else
      modelInfo.extraMap[ModelInfo.WING] = roleModelInfo.extraMap[ModelInfo.WING] or 0
      modelInfo.extraMap[ModelInfo.WING_COLOR_ID] = roleModelInfo.extraMap[ModelInfo.WING_COLOR_ID] or 0
    end
    if not cfg.showOriginalFabao then
      modelInfo.extraMap[ModelInfo.FABAO] = cfg.fabaoId
      modelInfo.extraMap[ModelInfo.FABAO_LINGQI] = nil
    else
      modelInfo.extraMap[ModelInfo.FABAO] = roleModelInfo.extraMap[ModelInfo.FABAO] or 0
      modelInfo.extraMap[ModelInfo.FABAO_LINGQI] = roleModelInfo.extraMap[ModelInfo.FABAO_LINGQI] or 0
    end
    if not cfg.showOriginalAirCraft then
      modelInfo.extraMap[ModelInfo.AIRCRAFT] = cfg.aircraftId
      modelInfo.extraMap[ModelInfo.AIRCRAFT_COLOR_ID] = nil
    else
      modelInfo.extraMap[ModelInfo.AIRCRAFT] = roleModelInfo.extraMap[ModelInfo.AIRCRAFT] or 0
      modelInfo.extraMap[ModelInfo.AIRCRAFT_COLOR_ID] = roleModelInfo.extraMap[ModelInfo.AIRCRAFT_COLOR_ID]
    end
    modelInfo.extraMap[ModelInfo.HAIR_COLOR_ID] = hairColor
    modelInfo.extraMap[ModelInfo.CLOTH_COLOR_ID] = clothColor
    modelInfo.extraMap[ModelInfo.QILING_EFFECT_LEVEL] = roleModelInfo.extraMap[ModelInfo.QILING_EFFECT_LEVEL]
    modelInfo.extraMap[ModelInfo.MAGIC_MARK] = roleModelInfo.extraMap[ModelInfo.MAGIC_MARK]
    modelInfo.extraMap[ModelInfo.OCCUPATION] = roleModelInfo.extraMap[ModelInfo.OCCUPATION]
    modelInfo.extraMap[ModelInfo.GENDER] = roleModelInfo.extraMap[ModelInfo.GENDER]
    modelInfo.extraMap[ModelInfo.WUSHI_ID] = roleModelInfo.extraMap[ModelInfo.WUSHI_ID]
    modelInfo.modelid = roleModelInfo.modelid
    role:LoadModelInfo(modelInfo)
  end
  if role:IsInLoading() then
    role:AddOnLoadCallback("change_model", LoadNewModel)
  else
    LoadNewModel()
  end
end
function _G.RecoverRoleModelWithModelInfo(role, roleModelInfo)
  if role == nil or roleModelInfo == nil then
    return
  end
  local function loadNewModel()
    if roleModelInfo.extraMap[ModelInfo.WEAPON] == nil then
      roleModelInfo.extraMap[ModelInfo.WEAPON] = 0
    end
    if roleModelInfo.extraMap[ModelInfo.WING] == nil then
      roleModelInfo.extraMap[ModelInfo.WING] = 0
    end
    if roleModelInfo.extraMap[ModelInfo.FABAO] == nil then
      roleModelInfo.extraMap[ModelInfo.FABAO] = 0
    end
    if roleModelInfo.extraMap[ModelInfo.AIRCRAFT] == nil then
      roleModelInfo.extraMap[ModelInfo.AIRCRAFT] = 0
    end
    local loadModelInfo = ChangeModelInfo(roleModelInfo, false) or roleModelInfo
    role:ChangeModel(loadModelInfo.modelid)
    if role:tryget("RemoveState") then
      role:RemoveState(RoleState.TRANSFORM)
    end
    role:LoadModelInfo(loadModelInfo)
  end
  if role:IsInLoading() then
    role:AddOnLoadCallback("change_model", loadNewModel)
  else
    loadNewModel()
  end
end
function _G.CloneModelInfo(sample)
  if sample == nil then
    return nil
  end
  local ret = {}
  ret.modelid = sample.modelid
  ret.name = sample.name
  if sample.extraMap then
    ret.extraMap = {}
    for k, v in pairs(sample.extraMap) do
      ret.extraMap[k] = v
    end
  end
  return ret
end
local function RecoverReplaceCostume(model, ignoreCostume)
  if model == nil then
    return
  end
  local modelInfo
  local roleId = model:tryget("roleId")
  if roleId then
    modelInfo = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):GetRoleModelInfo(roleId)
  else
    modelInfo = model:tryget("initModelInfo")
    if modelInfo and ignoreCostume then
      modelInfo = CloneModelInfo(modelInfo)
      modelInfo.extraMap[ModelInfo.FASHION_DRESS_ID] = 0
    end
  end
  if modelInfo then
    RecoverRoleModelWithModelInfo(model, modelInfo)
  end
end
function _G.SetCostume(model, id, hairColor, clothColor, cb)
  if id == nil or id <= 0 then
    if model.costumeInfo then
      if model.costumeInfo.showType == FashionShowType.NORMAL then
        model:RemoveEquip("Equip")
        model:RemoveEquip("Hair")
        model:RemoveEquip("Panda")
        model:RemoveEquip("Body")
        if hairColor or clothColor then
          SetModelColor(model, hairColor, clothColor)
        end
        if model:tryget("ReFly") then
          model:ReFly()
        end
      elseif model.costumeInfo.showType == FashionShowType.REPLACE then
        RecoverReplaceCostume(model, true)
        if cb then
          if model:IsInLoading() then
            model:AddOnLoadCallback("SetCostume", cb)
          else
            _G.SafeCall(cb)
          end
        end
      end
    end
    model.costumeInfo = nil
    return
  end
  if model.costumeInfo and model.costumeInfo.id == id and model.costumeInfo.hairColor == hairColor and model.costumeInfo.clothColor == clothColor then
    return
  end
  local entry = DynamicData.GetRecord(CFG_PATH.DATA_FASHION_CFG, id)
  if entry == nil then
    return
  end
  if model.costumeInfo == nil then
    model.costumeInfo = {}
  end
  model.costumeInfo.id = id
  model.costumeInfo.hairColor = hairColor
  model.costumeInfo.clothColor = clothColor
  local old_type = model.costumeInfo.showType
  local fashionShowType = DynamicRecord.GetIntValue(entry, "fashionShowType")
  model.costumeInfo.showType = fashionShowType
  if fashionShowType == FashionShowType.REPLACE then
    local modelChangeCfgId = DynamicRecord.GetIntValue(entry, "modelChangeCfgId")
    if modelChangeCfgId > 0 then
      model.costumeInfo.modelChangeCfgId = modelChangeCfgId
      local modelInfo = model:tryget("initModelInfo")
      if modelInfo == nil then
        local roleId = model:tryget("roleId")
        if roleId then
          modelInfo = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):GetRoleModelInfo(roleId)
        end
      end
      if modelInfo then
        local costumeInfo = model.costumeInfo
        model.costumeInfo = nil
        model.showOrnament = true
        ChangeRoleModelWithModelInfo(model, modelInfo, modelChangeCfgId, hairColor or 0, clothColor or 0)
        model.costumeInfo = costumeInfo
        if cb then
          if model:IsInLoading() then
            model:AddOnLoadCallback("SetCostume", cb)
          else
            _G.SafeCall(cb)
          end
        end
      end
    end
    return
  end
  if old_type == FashionShowType.REPLACE then
    local costumeInfo = model.costumeInfo
    model.costumeInfo = nil
    RecoverReplaceCostume(model, true)
    model.costumeInfo = costumeInfo
  end
  local function SetNormalCostume()
    local equipList = {}
    local modelId = DynamicRecord.GetIntValue(entry, "modelId")
    local modelpath
    local count = 0
    if modelId > 0 then
      modelpath = GetModelPath(modelId)
    end
    if modelpath and modelpath ~= "" then
      equipList.Equip = modelpath .. ".lua"
      count = count + 1
    else
      equipList.Equip = ""
    end
    local headModelId = DynamicRecord.GetIntValue(entry, "headModelId")
    if headModelId and headModelId > 0 then
      modelpath = GetModelPath(headModelId)
      if modelpath and modelpath ~= "" then
        equipList.Hair = modelpath .. ".lua"
        count = count + 1
      end
    else
      equipList.Hair = ""
    end
    local pandaModelId = DynamicRecord.GetIntValue(entry, "shengWuNvPandaModelId")
    if pandaModelId and pandaModelId > 0 then
      modelpath = GetModelPath(pandaModelId)
      if modelpath and modelpath ~= "" then
        equipList.Panda = modelpath .. ".lua"
        count = count + 1
      end
    else
      equipList.Panda = ""
    end
    local bodyModelId = DynamicRecord.GetIntValue(entry, "bodyModelId")
    if bodyModelId and bodyModelId > 0 then
      modelpath = GetModelPath(bodyModelId)
      if modelpath and modelpath ~= "" then
        equipList.Body = modelpath .. ".lua"
        count = count + 1
      end
    else
      equipList.Body = ""
    end
    local function on_change_done(k)
      count = count - 1
      if count <= 0 then
        SetModelColor(model, hairColor, clothColor)
        if model:tryget("ReFly") then
          model:ReFly()
        end
      end
    end
    for k, v in pairs(equipList) do
      if v ~= "" then
        model:ChangeEquip(k, v, true, on_change_done)
      else
        model:RemoveEquip(k)
      end
    end
    if cb then
      _G.SafeCall(cb)
    end
  end
  if model:IsInLoading() then
    model:AddOnLoadCallback("set_costume", SetNormalCostume)
  else
    SetNormalCostume()
  end
end
function _G.SetChildCostume(model, childCfgId, id)
  if not model:is(ECUIModel) and (not model:tryget("m_roleType") or model.m_roleType ~= RoleType.CHILD and model.m_roleType ~= GameUnitType.CHILDREN) then
    return
  end
  local ChangeFashionType = require("consts.mzm.gsp.util.confbean.ChangeFashionType")
  local old_id = model.costumeInfo and model.costumeInfo.id or 0
  local current_type
  if old_id > 0 then
    local old_costume_cfg = DynamicData.GetRecord(CFG_PATH.DATA_UTILS_CChangeFashionCfg, old_id)
    if old_costume_cfg then
      current_type = DynamicRecord.GetIntValue(old_costume_cfg, "changeType")
    end
  end
  if id == nil or id <= 0 then
    local modelInfo = model:tryget("extraInfo") or model:tryget("initModelInfo")
    if current_type == ChangeFashionType.NORMAL then
      model:RemoveEquip("Ornament")
    elseif current_type == ChangeFashionType.MODEL then
      local initModelId = modelInfo and modelInfo.extraMap[ModelInfo.CHILDREN_MODEL_ID] or childCfgId
      local cfg = require("Main.Children.ChildrenUtils").GetChildrenCfgById(initModelId)
      if cfg then
        ChildCostumeChangeModel(model, cfg.modelId)
      end
    end
    model.costumeInfo = nil
    if modelInfo then
      local child_weapon_id = modelInfo.extraMap[ModelInfo.CHILDREN_WEAPON_ID]
      if child_weapon_id and child_weapon_id > 0 then
        SetChildWeapon(model, child_weapon_id, 0)
      elseif model.mECPartComponent then
        model.mECPartComponent:Destroy()
        model.mECPartComponent = nil
      end
    end
    return
  end
  if model.costumeInfo and model.costumeInfo.id == id then
    return
  end
  local entry = DynamicData.GetRecord(CFG_PATH.DATA_UTILS_CChangeFashionCfg, id)
  if entry == nil then
    return
  end
  local modelId = DynamicRecord.GetIntValue(entry, "modelCfgid")
  local changeType = DynamicRecord.GetIntValue(entry, "changeType")
  local weaponId = DynamicRecord.GetIntValue(entry, "weaponCfgid")
  if changeType == ChangeFashionType.NORMAL then
    local equipList = {}
    local hairId = DynamicRecord.GetIntValue(entry, "hairCfgid")
    local modelpath
    local count = 0
    if hairId > 0 then
      modelpath = GetModelPath(hairId)
    end
    if modelpath and modelpath ~= "" then
      equipList.Ornament = modelpath .. ".lua"
      count = count + 1
    else
      equipList.Ornament = ""
    end
    for k, v in pairs(equipList) do
      if v ~= "" then
        model:ChangeEquip(k, v, true, nil)
      else
        model:RemoveEquip(k)
      end
    end
  elseif changeType == ChangeFashionType.MODEL then
    ChildCostumeChangeModel(model, modelId)
  end
  if model.costumeInfo == nil then
    model.costumeInfo = {}
  end
  model.costumeInfo.id = id
  if weaponId > 0 then
    if model.mECPartComponent == nil then
      model.mECPartComponent = require("Model.ECPartComponent").new(model)
      model.mECPartComponent.defaultLayer = model.defaultLayer
    end
    local function LoadWeapon()
      model.mECPartComponent:LoadSingleWeaponByModelId(weaponId)
    end
    if model:IsInLoading() then
      model:AddOnLoadCallback("add_child_weapon", LoadWeapon)
    else
      LoadWeapon()
    end
  end
end
function _G.ChildCostumeChangeModel(model, modelId)
  if modelId == model.mModelId then
    return
  end
  local weapon = model.mECPartComponent
  if weapon then
    weapon:Detach()
    model.mECPartComponent = nil
  end
  local pos = model:GetPos()
  local dir = model:GetDir()
  model:Destroy()
  model:Init(modelId)
  if pos then
    model:LoadCurrentModel(pos.x, pos.y, dir)
  else
    model:LoadCurrentModel(0, 0, 180)
  end
  local function AttachWeapon()
    if weapon then
      weapon:AttachToModel(model)
      model.mECPartComponent = weapon
    end
  end
  if model:IsInLoading() then
    model:AddOnLoadCallback("attach_child_weapon", AttachWeapon)
  else
    AttachWeapon()
  end
end
local model_light_cfg_entries, model_light_cfg_index_map
function _G.GetModelLightCfg(modelId, level)
  if model_light_cfg_entries == nil then
    local entries = DynamicData.GetTable("data/cfg/mzm.gsp.item.confbean.CAllEquipQilinCfg.bny")
    model_light_cfg_entries = entries
    DynamicDataTable.SetCache(entries, true)
    local size = DynamicDataTable.GetRecordsCount(entries)
    model_light_cfg_index_map = {}
    DynamicDataTable.FastGetRecordBegin(entries)
    for i = 0, size - 1 do
      local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
      local linlevel = record:GetIntValue("linlevel")
      local modelId_cfg = record:GetIntValue("modelId")
      local key = bit.lshift(modelId_cfg, 8) + linlevel
      model_light_cfg_index_map[key] = i
    end
    DynamicDataTable.FastGetRecordEnd(entries)
  end
  if model_light_cfg_entries == nil then
    return nil
  end
  local key = bit.lshift(modelId, 8) + level
  local idx = model_light_cfg_index_map[key]
  while idx == nil do
    level = level - 1
    if level < 12 then
      break
    end
    key = bit.lshift(modelId, 8) + level
    idx = model_light_cfg_index_map[key]
  end
  if idx == nil then
    return nil
  end
  local record = DynamicDataTable.GetRecordByIdx(model_light_cfg_entries, idx)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.r = record:GetIntValue("r")
  cfg.g = record:GetIntValue("g")
  cfg.b = record:GetIntValue("b")
  cfg.a = record:GetIntValue("a")
  cfg.scale = record:GetIntValue("scale") / 10
  return cfg
end
local LIGHT_EFFECT_KEY = "light_effect"
local function DoSetModelLightEffect(model, color, lightScaleX, lightScaleY, boneName, offsetY)
  local lightObj = model:GetAccessory(LIGHT_EFFECT_KEY)
  if lightObj and not lightObj.isnil then
    local mat = lightObj:GetComponent("MeshRenderer").material
    if mat then
      mat:SetColor("_Color", color)
      local lightRes = require("Model.ECModel").lightRes
      mat:SetTexture("_MainTex", lightRes.tex)
      mat:SetFloat("_ScaleX", lightScaleX)
      mat:SetFloat("_ScaleY", lightScaleY)
      return
    else
      lightObj:Destroy()
    end
  end
  local function loaded(obj)
    if not obj or model.m_model == nil or model.m_model.isnil then
      return
    end
    local bone = model.m_model:FindDirect(boneName)
    if bone == nil then
      Debug.LogWarning("[SetModelLightEffect]bone not found: " .. boneName)
      return
    end
    model:RemoveAccessory(LIGHT_EFFECT_KEY)
    local lightObj = Object.Instantiate(obj, "GameObject")
    local lightRes = require("Model.ECModel").lightRes
    if lightRes.shader == nil or lightRes.tex == nil then
      lightObj:Destroy()
      return
    end
    local mat = Material.Material(lightRes.shader)
    mat:SetColor("_Color", color)
    mat:SetTexture("_MainTex", lightRes.tex)
    mat:SetFloat("_ScaleX", lightScaleX)
    mat:SetFloat("_ScaleY", lightScaleY)
    lightObj:GetComponent("MeshRenderer").material = mat
    if model:AddAccessory(LIGHT_EFFECT_KEY, lightObj, boneName, offsetY) == false then
      lightObj:Destroy()
    end
  end
  GameUtil.AsyncLoad(RESPATH.MODEL_LIGHT_PLANE, loaded)
end
local COMMON_SPINE_BONE = "Root"
function _G.SetModelLightEffect(model, level)
  if model == nil then
    return
  end
  model.lightLevel = level or 0
  if level == nil or level <= 0 then
    model:RemoveAccessory(LIGHT_EFFECT_KEY)
    return
  end
  if model:IsInLoading() then
    return
  end
  local roleId = model:tryget("roleId")
  local modelInfo
  if roleId then
    modelInfo = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):GetRoleModelInfo(roleId)
  else
    modelInfo = model:tryget("initModelInfo")
  end
  local modelId = modelInfo and modelInfo.modelid or model.mModelId
  local cfg = GetModelLightCfg(modelId, level)
  if cfg then
    local boneName = COMMON_SPINE_BONE
    local offsetY = model:GetBoxHeight() / 2
    DoSetModelLightEffect(model, Color.Color(cfg.r / 255, cfg.g / 255, cfg.b / 255, cfg.a / 255), cfg.scale, cfg.scale, boneName, offsetY)
  end
end
function _G.SetPetLightEffect(model, level)
  if model == nil then
    return
  end
  model.lightLevel = level or 0
  if level == nil or level <= 0 then
    model:RemoveAccessory(LIGHT_EFFECT_KEY)
    return
  end
  if model:IsInLoading() then
    return
  end
  local cfg = require("Main.Pet.PetUtility").GetPetJinjieModelCfg(level, model.mModelId)
  if cfg then
    DoSetModelLightEffect(model, Color.Color(cfg.r_num / 255, cfg.g_num / 255, cfg.b_num / 255, cfg.a_num / 255), cfg.lightXNum / 10, cfg.lightYNum / 10, cfg.boneName, 0)
  end
end
function _G.GetDigitalCaptcha(len)
  local len = len or 4
  local captchaTable = {}
  for i = 1, len do
    local num = math.random(0, 9)
    table.insert(captchaTable, num)
  end
  return table.concat(captchaTable)
end
function _G.SetModelExtra(model, modelInfo)
  if modelInfo == nil or modelInfo.extraMap == nil then
    return
  end
  local modelColorId = modelInfo.extraMap[ModelInfo.PET_EXTERIOR_COLOR_ID] or modelInfo.extraMap[ModelInfo.COLOR_ID]
  if modelColorId and modelColorId > 0 then
    local modelColor = GetModelColorCfg(modelColorId)
    if modelColor then
      model:SetColoration(modelColor)
    end
  end
  local outlookId = modelInfo.extraMap[ModelInfo.OUTLOOK_ID]
  local appearanceCfg
  if outlookId and outlookId > 0 then
    appearanceCfg = GetAppearanceCfg(outlookId)
  end
  local lin_level = modelInfo.extraMap[ModelInfo.QILING_EFFECT_LEVEL]
  if lin_level then
    SetModelLightEffect(model, lin_level)
  end
  local s = modelInfo.extraMap[ModelInfo.SCALE_RATE]
  if appearanceCfg then
    s = appearanceCfg.scaleRate
  end
  if s and model.m_model then
    model.m_model.localScale = model.m_model.localScale * s
  end
  local weapon_id = modelInfo.extraMap[ModelInfo.WEAPON]
  local wushi_id = modelInfo.extraMap[ModelInfo.WUSHI_ID] or 0
  if appearanceCfg then
    weapon_id = appearanceCfg.weaponId
    wushi_id = 0
  end
  if weapon_id then
    local lightLevel = modelInfo.extraMap[ModelInfo.QILING_LEVEL]
    if lightLevel == nil then
      lightLevel = 0
    end
    local DecorationMgr = require("Main.GodWeapon.DecorationMgr")
    local occupation = modelInfo.extraMap[ModelInfo.OCCUPATION]
    local gender = modelInfo.extraMap[ModelInfo.GENDER]
    if occupation and gender then
      local wushi_info = DecorationMgr.GetWuShiModelInfo(wushi_id, model.mModelId)
      SetModelWeapon(model, weapon_id, lightLevel, wushi_info)
    else
      SetModelWeapon(model, weapon_id, lightLevel, nil)
    end
  end
  local wing_id = modelInfo.extraMap[ModelInfo.WING]
  if appearanceCfg then
    wing_id = appearanceCfg.wingId
  end
  if wing_id then
    local wingDyeId = modelInfo.extraMap[ModelInfo.WING_COLOR_ID]
    if wingDyeId == nil then
      wingDyeId = 0
    end
    model:SetWing(wing_id, wingDyeId)
  end
  local fabaoId = modelInfo.extraMap[ModelInfo.FABAO_LINGQI]
  if appearanceCfg then
    fabaoId = appearanceCfg.faBaoId
  end
  if fabaoId == nil or fabaoId == 0 then
    fabaoId = modelInfo.extraMap[ModelInfo.FABAO]
  end
  if fabaoId and fabaoId > 0 then
    model:SetFabao(fabaoId)
  end
  local aircraft_id = modelInfo.extraMap[ModelInfo.AIRCRAFT]
  local aircraft_color = modelInfo.extraMap[ModelInfo.AIRCRAFT_COLOR_ID] or 0
  if appearanceCfg then
    aircraft_id = appearanceCfg.flyMountId
  end
  if aircraft_id then
    model:SetFeijianId(aircraft_id, aircraft_color)
  end
  local changeId = modelInfo.extraMap[ModelInfo.EXTERIOR_ID]
  local shapeShiftCardId = modelInfo.extraMap[ModelInfo.CHANGE_MODEL_CARD_CFGID] or 0
  local mini = modelInfo.extraMap[ModelInfo.CHANGE_MODEL_CARD_MINI] or 0
  if (changeId == nil or changeId <= 0) and shapeShiftCardId > 0 then
    if mini > 0 then
      SetShapeShiftCardMiniIcon(model, shapeShiftCardId)
    else
      local TurnedCardUtils = require("Main.TurnedCard.TurnedCardUtils")
      local change_cfg = TurnedCardUtils.GetChangeModelCardCfg(shapeShiftCardId)
      if change_cfg then
        model:SetOrnament(true)
        ChangeRoleModelWithModelInfo(model, modelInfo, change_cfg.changeModelId)
      end
      local shapeShift_level_cfg = TurnedCardUtils.GetCardLevelCfg(shapeShiftCardId)
      local card_level = modelInfo.extraMap[ModelInfo.CHANGE_MODEL_CARD_LEVEL]
      local level_info = shapeShift_level_cfg.cardLevels[card_level]
      if level_info and 0 < level_info.dyeId then
        model.colorId = level_info.dyeId
        local colorcfg = GetModelColorCfg(level_info.dyeId)
        model:SetColoration(colorcfg)
      end
      SetShapeShiftCardMiniIcon(model, 0)
    end
  end
  local hairColorId = modelInfo.extraMap[ModelInfo.HAIR_COLOR_ID]
  local clothesColorId = modelInfo.extraMap[ModelInfo.CLOTH_COLOR_ID]
  local costumeId = modelInfo.extraMap[ModelInfo.FASHION_DRESS_ID]
  if (changeId == nil or changeId <= 0) and (shapeShiftCardId == nil or shapeShiftCardId <= 0 or mini > 0) then
    if costumeId and costumeId > 0 then
      SetCostume(model, costumeId, hairColorId, clothesColorId)
    else
      SetModelColor(model, hairColorId, clothesColorId)
    end
  end
  local showOrnament = modelInfo.extraMap[ModelInfo.PET_SHIPIN]
  if appearanceCfg then
    showOrnament = appearanceCfg.isShowDecorateItem
  end
  if showOrnament then
    model:SetOrnament(true)
  end
  local stage_level = modelInfo.extraMap[ModelInfo.PET_STAGE_LEVEL]
  if stage_level then
    SetPetLightEffect(model, stage_level)
  end
  local magicMarkType = modelInfo.extraMap[ModelInfo.MAGIC_MARK]
  if magicMarkType and magicMarkType > 0 then
    local magicMarkCfg = gmodule.moduleMgr:GetModule(ModuleId.MAGIC_MARK):GetMagicMarkTypeCfg(magicMarkType)
    if magicMarkCfg and model:tryget("SetMagicMark") then
      model:SetMagicMark(magicMarkCfg.modelId)
    end
  elseif model:tryget("SetMagicMark") then
    model:SetMagicMark(0)
  end
  local petMarkId = modelInfo.extraMap[ModelInfo.PET_MARK_CFG_ID]
  if petMarkId and petMarkId > 0 then
    local roleType = model:tryget("m_roleType")
    if roleType == RoleType.PET or roleType == GameUnitType.PET then
      local markcfg = require("Main.Pet.PetMark.PetMarkUtils").GetPetMarkCfg(petMarkId)
      if markcfg and model:tryget("SetMagicMark") then
        model:SetMagicMark(markcfg.modelId)
      end
    end
  end
  local child_costume_id = modelInfo.extraMap[ModelInfo.CHILDREN_FASHION]
  local child_model_cfgId = modelInfo.extraMap[ModelInfo.CHILDREN_MODEL_ID]
  if child_costume_id and child_costume_id > 0 then
    SetChildCostume(model, child_model_cfgId, child_costume_id)
  end
  local child_weapon_id = modelInfo.extraMap[ModelInfo.CHILDREN_WEAPON_ID]
  if child_weapon_id and child_weapon_id > 0 then
    local costume_weaponId = 0
    if child_costume_id and child_costume_id > 0 then
      local entry = DynamicData.GetRecord(CFG_PATH.DATA_UTILS_CChangeFashionCfg, child_costume_id)
      costume_weaponId = DynamicRecord.GetIntValue(entry, "weaponCfgid")
    end
    if costume_weaponId == 0 then
      SetChildWeapon(model, child_weapon_id, 0)
    end
  end
end
function _G.SetShapeShiftCardMiniIcon(model, shapeShiftCardId)
  if model == nil then
    return
  end
  local name_panel = model.m_uiNameHandle
  if shapeShiftCardId == nil or shapeShiftCardId <= 0 then
    model:SetNameIcon(0)
  else
    local TurnedCardUtils = require("Main.TurnedCard.TurnedCardUtils")
    local change_cfg = TurnedCardUtils.GetChangeModelCardCfg(shapeShiftCardId)
    model:SetNameIcon(change_cfg.iconId)
  end
end
function _G.SetModelColor(model, hairColorId, clothesColorId)
  if model == nil then
    return
  end
  if hairColorId or clothesColorId then
    local color = {}
    local hairCfg
    if hairColorId and hairColorId > 0 then
      hairCfg = DyeData.GetColorFormula(hairColorId)
    end
    if hairCfg then
      color.hair = Color.Color(hairCfg.r / 255, hairCfg.g / 255, hairCfg.b / 255, hairCfg.a / 255)
    end
    local clothesCfg
    if clothesColorId and clothesColorId > 0 then
      clothesCfg = DyeData.GetColorFormula(clothesColorId)
    end
    if clothesCfg then
      color.clothes = Color.Color(clothesCfg.r / 255, clothesCfg.g / 255, clothesCfg.b / 255, clothesCfg.a / 255)
    end
    model:SetModelColor(color)
  end
end
local function GetLoadModelInfo(model, modelInfo, isInFight)
  local loadModelInfo
  if modelInfo then
    loadModelInfo = ChangeModelInfo(modelInfo, isInFight)
    if loadModelInfo then
      if not isInFight and model:tryget("SetState") then
        model:SetState(RoleState.TRANSFORM)
      end
    else
      if not isInFight and model:tryget("RemoveState") then
        model:RemoveState(RoleState.TRANSFORM)
      end
      modelInfo.extraMap[ModelInfo.EXTERIOR_ID] = nil
    end
  end
  if model:is(ECUIModel) or model:is(NpcModel) then
    model.initModelInfo = modelInfo
  end
  if loadModelInfo == nil then
    loadModelInfo = modelInfo
  end
  return loadModelInfo
end
function _G.LoadModel(model, modelInfo, x, y, dir, instantly, isInFight)
  if model == nil or modelInfo == nil then
    return false
  end
  local loadModelInfo = GetLoadModelInfo(model, modelInfo, isInFight)
  local modelpath, modelcolor = GetModelPath(loadModelInfo.modelid)
  if modelpath == nil or modelpath == "" then
    return false
  end
  model.mModelId = loadModelInfo.modelid
  model.colorId = modelcolor
  model:LoadModelInfo(loadModelInfo)
  model:LoadModel2(modelpath, x, y, dir, instantly)
  return true
end
function _G.LoadModelWithCallBack(model, modelInfo, instantly, isInFight, callback)
  if model == nil or modelInfo == nil then
    return false
  end
  local loadModelInfo = GetLoadModelInfo(model, modelInfo, isInFight)
  local modelpath, modelcolor = GetModelPath(loadModelInfo.modelid)
  if modelpath == nil or modelpath == "" then
    return false
  end
  model.mModelId = loadModelInfo.modelid
  model.colorId = modelcolor
  model:AddOnLoadCallback("onloaded", callback)
  model:LoadModelInfo(loadModelInfo)
  model:LoadModel2(modelpath, 0, 0, model.m_ang, instantly)
  return true
end
function _G.LoadModelWithoutTransform(model, modelInfo, x, y, dir, instantly)
  if model == nil or modelInfo == nil then
    return false
  end
  local pseudo_modelInfo = CloneModelInfo(modelInfo)
  pseudo_modelInfo.extraMap[ModelInfo.EXTERIOR_ID] = nil
  pseudo_modelInfo.extraMap[ModelInfo.CHANGE_MODEL_CARD_CFGID] = nil
  local costumeId = pseudo_modelInfo.extraMap[ModelInfo.FASHION_DRESS_ID]
  if costumeId and costumeId > 0 then
    local entry = DynamicData.GetRecord(CFG_PATH.DATA_FASHION_CFG, costumeId)
    local fashionShowType = DynamicRecord.GetIntValue(entry, "fashionShowType")
    if fashionShowType == FashionShowType.REPLACE then
      pseudo_modelInfo.extraMap[ModelInfo.FASHION_DRESS_ID] = nil
    end
  end
  local modelpath, modelcolor = GetModelPath(modelInfo.modelid)
  if modelpath == nil or modelpath == "" then
    return false
  end
  model.mModelId = modelInfo.modelid
  model.colorId = modelcolor
  model:LoadModelInfo(pseudo_modelInfo)
  model:LoadModel2(modelpath, x, y, dir, instantly)
  return true
end
function _G.ChangeModelInfo(modelInfo, isInFight)
  local changeModelId = modelInfo.extraMap[ModelInfo.EXTERIOR_ID]
  local petChangeModelId = modelInfo.extraMap[ModelInfo.PET_EXTERIOR_ID]
  local child_fashion = modelInfo.extraMap[ModelInfo.CHILDREN_FASHION]
  local costumeId = modelInfo.extraMap[ModelInfo.FASHION_DRESS_ID]
  local shapeShiftCardId = modelInfo.extraMap[ModelInfo.CHANGE_MODEL_CARD_CFGID]
  local hasModelChange = changeModelId and changeModelId > 0
  if hasModelChange and isInFight then
    local cfg = GetModelChangeCfg(changeModelId)
    hasModelChange = cfg ~= nil and cfg.showInFight
  end
  if not hasModelChange and shapeShiftCardId and shapeShiftCardId > 0 then
    local mini = modelInfo.extraMap[ModelInfo.CHANGE_MODEL_CARD_MINI] or 0
    if mini == 0 then
      local TurnedCardUtils = require("Main.TurnedCard.TurnedCardUtils")
      local change_cfg = TurnedCardUtils.GetChangeModelCardCfg(shapeShiftCardId)
      if change_cfg then
        changeModelId = change_cfg.changeModelId
        hasModelChange = true
      end
    end
  end
  if not hasModelChange and costumeId and costumeId > 0 then
    local rec = DynamicData.GetRecord(CFG_PATH.DATA_FASHION_CFG, costumeId)
    if rec then
      local fashionShowType = DynamicRecord.GetIntValue(rec, "fashionShowType")
      if fashionShowType == FashionShowType.REPLACE then
        changeModelId = DynamicRecord.GetIntValue(rec, "modelChangeCfgId")
      end
    end
  end
  if changeModelId and changeModelId > 0 then
    local cfg = GetModelChangeCfg(changeModelId)
    if cfg and (not isInFight or cfg.showInFight) then
      local loadModelInfo = CloneModelInfo(modelInfo)
      if not cfg.showOriginalWeapon then
        loadModelInfo.extraMap[ModelInfo.WEAPON] = cfg.weaponId
      end
      if not cfg.showOriginalWing then
        loadModelInfo.extraMap[ModelInfo.WING] = cfg.wingId
        loadModelInfo.extraMap[ModelInfo.WING_COLOR_ID] = nil
      end
      if not cfg.showOriginalFabao then
        loadModelInfo.extraMap[ModelInfo.FABAO] = cfg.fabaoId
        loadModelInfo.extraMap[ModelInfo.FABAO_LINGQI] = nil
      end
      if not cfg.showOriginalAirCraft then
        loadModelInfo.extraMap[ModelInfo.AIRCRAFT] = cfg.aircraftId
      end
      loadModelInfo.modelid = cfg.modelId
      return loadModelInfo
    else
      return nil
    end
  elseif petChangeModelId and petChangeModelId > 0 then
    modelInfo.modelid = petChangeModelId
    return modelInfo
  elseif child_fashion and child_fashion > 0 then
    local entry = DynamicData.GetRecord(CFG_PATH.DATA_UTILS_CChangeFashionCfg, child_fashion)
    if entry then
      local changeType = DynamicRecord.GetIntValue(entry, "changeType")
      if changeType == require("consts.mzm.gsp.util.confbean.ChangeFashionType").MODEL then
        local modelId = DynamicRecord.GetIntValue(entry, "modelCfgid")
        modelInfo.modelid = modelId
        return modelInfo
      end
    end
  end
  return nil
end
function _G.IsModelChanged(modelInfo)
  if modelInfo.extraMap[ModelInfo.EXTERIOR_ID] and modelInfo.extraMap[ModelInfo.EXTERIOR_ID] > 0 then
    return true
  end
  local costumeId = modelInfo.extraMap[ModelInfo.FASHION_DRESS_ID]
  local entry = DynamicData.GetRecord(CFG_PATH.DATA_FASHION_CFG, costumeId)
  if entry then
    local type = DynamicRecord.GetIntValue(entry, "fashionShowType")
    if type == FashionShowType.REPLACE then
      return true
    end
  end
  return false
end
function _G.QuaternionToEular(quaternion)
  return quaternion:get_eulerAngles()
end
function _G.StringToHtml(str)
  return string.format("<p align=left><font size=22>%s</font></p>", str)
end
function _G.GetDaysOfMonth(year, month)
  local daysList = {
    31,
    28,
    31,
    30,
    31,
    30,
    31,
    31,
    30,
    31,
    30,
    31
  }
  if year % 4 == 0 and year % 100 ~= 0 or year % 400 == 0 then
    daysList[2] = 29
  end
  local days = daysList[month]
  return days
end
function _G.PlayerIsInFight()
  local ret = false
  ret = FightMgr.Instance().isInFight
  ret = ret or require("Main.Fight.Replayer").Instance():IsPetFightCVC()
  return ret
end
function _G.PlayerIsInState(state)
  return gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole:IsInState(state)
end
function _G.PlayerIsTransportable()
  local me = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  local isInFollow = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):IsInFollowState(me.roleId)
  return not isInFollow and not me:IsInState(RoleState.UNTRANPORTABLE) and not me:IsInState(RoleState.BATTLE)
end
function _G.AdjustBGCamera(camera, w, h)
  local aspect = camera.aspect
  local orthographicSize = 1
  if w >= h * aspect then
    orthographicSize = h / 2
  else
    orthographicSize = w / aspect / 2
  end
  camera.orthographicSize = orthographicSize
end
function _G.Seconds2HMSTime(seconds)
  local s = seconds % 60
  local m = math.floor(seconds / 60) % 60
  local h = math.floor(seconds / 3600)
  return {
    h = h,
    m = m,
    s = s
  }
end
function _G.printChaofan(log)
  print(string.format("<color=brown>%s</color>", log))
end
function _G.GetSysConstCfg(constName)
  local record = DynamicData.GetRecord("data/cfg/mzm.gsp.chat.confbean.SysCfgConsts.bny", constName)
  if record == nil then
    warn("SysCfgConsts get nil record for id: ", constName)
    return -1
  end
  local value = record:GetIntValue("value")
  return value
end
function _G.GotoBuyYuanbao()
  local callback = function(id)
    if id == 1 then
      local MallPanel = require("Main.Mall.ui.MallPanel")
      require("Main.Mall.MallModule").RequireToShowMallPanel(MallPanel.StateConst.Pay, 0, 0)
    end
  end
  CommonConfirmDlg.ShowConfirm("", textRes.Common[413], callback, tag)
end
function _G.GoToBuySilver(needQuest)
  local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
  _G.GoToBuyCurrency(require("Main.Item.ui.BuyGoldSilverPanel").ExchangType.YUANBAO2SILVER, needQuest)
end
function _G.GoToBuyGold(needQuest)
  local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
  _G.GoToBuyCurrency(require("Main.Item.ui.BuyGoldSilverPanel").ExchangType.YUANBAO2GOLD, needQuest)
end
function _G.GoToBuyGoldIngot(needQuest)
  local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
  _G.GoToBuyCurrency(require("Main.Item.ui.BuyGoldSilverPanel").ExchangType.YUANBAO2INGOT, needQuest)
end
function _G.GoToBuyGoldByIngot(needQuest)
  local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
  _G.GoToBuyCurrency(require("Main.Item.ui.BuyGoldSilverPanel").ExchangType.INGOT2GOLD, needQuest)
end
function _G.GoToBuyCurrency(moneyType, needQuest)
  local BuyGoldSilverPanel = require("Main.Item.ui.BuyGoldSilverPanel")
  local function goToBuyCurrency()
    if _G.CheckCrossServerAndToast() then
      return
    end
    BuyGoldSilverPanel.Instance():ShowPanel(moneyType)
  end
  local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
  if needQuest then
    local title = textRes.Common[8]
    local moneyTypeMame = BuyGoldSilverPanel.TypeToName[moneyType].MoneyName
    local desc = string.format(textRes.Common[38], moneyTypeMame)
    if moneyType == MoneyType.GOLD_INGOT then
      desc = string.format(textRes.Common[41], moneyTypeMame)
    end
    CommonConfirmDlg.ShowConfirm(title, desc, function(s)
      if s == 1 then
        goToBuyCurrency()
      end
    end, nil)
  else
    goToBuyCurrency()
  end
end
function _G.GetBoneAddEffect(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_BONE_EFFECT_CFG, id)
  if record == nil then
    warn("GetBoneAddEffect ", id, "nil")
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.boneaddeffect = {}
  local rec2 = record:GetStructValue("AddEffectToBoneStruct")
  local count = rec2:GetVectorSize("AddEffectToBoneVector")
  for i = 0, count - 1 do
    local rec3 = rec2:GetVectorValueByIdx("AddEffectToBoneVector", i)
    local t = {}
    t.bone = rec3:GetStringValue("bone")
    t.effect = rec3:GetIntValue("effect")
    table.insert(cfg.boneaddeffect, t)
  end
  return cfg
end
function _G.PlaySkillInUIModel(model, skillId, gender, onPlayEnd)
  local SkillPlayHelper = require("Main.Skill.SkillPlayHelper")
  SkillPlayHelper.PlaySkillInUIModel(model, skillId, {gender = gender}, onPlayEnd)
end
function _G.GetRoleHeight()
  local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  local roleHeight = 0
  if heroModule.myRole then
    roleHeight = Calc3DYTo2DY(heroModule.myRole:GetRoleHeight() * 2)
  end
  return roleHeight
end
function _G.IsConnected()
  return gmodule.network.isconnected()
end
function _G.GetHeroProp()
  return HeroInterface.GetHeroProp()
end
function _G.GetMyRoleID()
  return gmodule.moduleMgr:GetModule(ModuleId.HERO).roleId
end
function _G.IsEnteredWorld()
  return gmodule.moduleMgr:GetModule(ModuleId.LOGIN):IsInWorld()
end
function _G.IsAllowTo(behavior)
  return require("Main.Hero.HeroBehaviorDefine").IsAllowTo(behavior)
end
local featureInstance
function _G.IsFeatureOpen(featureType)
  if featureInstance == nil then
    featureInstance = require("Main.FeatureOpenList.FeatureOpenListModule").Instance()
  end
  return featureInstance:CheckFeatureOpen(featureType)
end
local watchmoonmgr
function _G.IsWatchingMoon()
  if watchmoonmgr == nil then
    watchmoonmgr = require("Main.activity.WatchMoon.WatchMoonMgr").Instance()
  end
  return watchmoonmgr:IsWatchingMoon()
end
function _G.IsInServerStatus(role, status)
  local role_status = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):GetRoleStatus(role.roleId)
  if role_status == nil then
    return false
  end
  for _, v in pairs(role_status) do
    if v == status then
      return true
    end
  end
  return false
end
function _G.Charsize(ch)
  if not ch then
    return 0
  elseif ch > 240 then
    return 4
  elseif ch > 225 then
    return 3
  elseif ch > 192 then
    return 2
  else
    return 1
  end
end
function _G.Strlen(str)
  local len = 0
  local aNum = 0
  local hNum = 0
  local currentIndex = 1
  while currentIndex <= #str do
    local char = string.byte(str, currentIndex)
    local cs = Charsize(char)
    currentIndex = currentIndex + cs
    len = len + 1
    if cs == 1 then
      aNum = aNum + 1
    elseif cs >= 2 then
      hNum = hNum + 1
    end
  end
  return len, aNum, hNum
end
function _G.MakePos(len, from, to)
  if not from and not to then
    return 1, len
  elseif not to then
    if from > 0 then
      if len < from then
        return len, len + 1
      else
        return from, len
      end
    elseif from < 0 then
      if from + len >= 0 and len > from + len then
        return from + len + 1, len
      elseif from + len < 0 then
        return 1, len
      end
    else
      return 1, len
    end
  elseif not from then
    if to > 0 then
      if to <= len then
        return 1, to
      elseif len < to then
        return 1, len
      end
    elseif to < 0 then
      if to + len >= 0 and len > to + len then
        return 1, len + to + 1
      elseif to + len < 0 then
        return 1, len
      end
    else
      error("bad argument #d to 'from' (number expected,got nil)")
    end
  elseif from > 0 and to > 0 then
    if from <= len and to <= len and from <= to then
      return from, to
    elseif from <= len and len < to then
      return from, len
    else
      error(("invalid pos for list range(expected range(%d-%d),but got (%d-%d)) "):format(1, len, from, to))
    end
  elseif from < 0 and to < 0 then
    if from + len >= 0 and len > from + len and to + len >= 0 and len > to + len and from <= to then
      return from + len + 1, to + len + 1
    end
    error(("invalid pos for list range(expected range(%d-%d),but got (%d-%d)) "):format(-len, -1, from, to))
  elseif from > 0 and to < 0 then
    return from, to + len + 1
  elseif from < 0 and to > 0 then
    if to <= len then
      return from + len + 1, to
    else
      return from + len + 1, len
    end
    error(("invalid pos for list range got (%d-%d) "):format(from, to))
  else
    error(("invalid pos for list range got (%d-%d) "):format(from, to))
  end
end
function _G.StrSub(str, ...)
  local len = Strlen(str)
  if len <= 0 then
    return ""
  end
  local from, to = MakePos(len, ...)
  if len < from or to < from then
    return ""
  end
  local frombyte = 1
  local index = 1
  while true do
    if from <= index then
      break
    end
    local char = string.byte(str, frombyte)
    frombyte = frombyte + Charsize(char)
    index = index + 1
  end
  index = from
  local byteIndex = frombyte
  while true do
    if to < index then
      break
    end
    local char = string.byte(str, byteIndex)
    byteIndex = byteIndex + Charsize(char)
    index = index + 1
  end
  local tobyte = byteIndex
  return string.sub(str, frombyte, tobyte - 1)
end
local CharacterCodeSection
function _G.CheckCharSectionInString(str, isLittleEndian)
  if CharacterCodeSection == nil then
    CharacterCodeSection = {}
    local mt = {
      __index = function(t, k)
        if type(k) == "number" then
          if k >= 19968 and k <= 40869 or k >= 97 and k <= 122 or k >= 65 and k <= 90 or k >= 48 and k <= 57 then
            return true
          else
            return false
          end
        else
          return false
        end
      end
    }
    setmetatable(CharacterCodeSection, mt)
  end
  if str then
    isLittleEndian = isLittleEndian == nil or true
    local unicodeStr = GameUtil.Utf8ToUnicode(str)
    for i = 1, #unicodeStr, 2 do
      local char = string.sub(unicodeStr, i, i + 1)
      local charCode
      if isLittleEndian then
        local low, high = string.byte(char, 1, 2)
        charCode = bit.bor(bit.lshift(high, 8), low)
      else
        local higt, low = string.byte(char, 1, 2)
        charCode = bit.bor(bit.lshift(high, 8), low)
      end
      if not CharacterCodeSection[charCode] then
        return false
      end
    end
    return true
  else
    return true
  end
end
function _G.SafeCallback(callback, ...)
  if callback then
    callback(...)
  end
end
function _G.GetRoleServerInfo(roleId)
  if roleId == nil then
    return nil
  end
  local zoneId = _G.GetRoleZoneId(roleId)
  local serverCfg = require("Main.Login.ServerListMgr").Instance():GetServerCfg(zoneId)
  return serverCfg
end
function _G.GetRoleZoneId(roleId)
  local zoneId = roleId % 4096
  if type(zoneId) == "userdata" then
    return zoneId:ToNumber()
  end
  return zoneId
end
function _G.FileExists(fullpath)
  if fullpath:len() == 0 then
    return false
  end
  local file, _ = io.open(fullpath, "rb")
  if file then
    file:close()
  end
  return file ~= nil
end
function _G.FindFormatString(src, format)
  local result = ""
  for k in src:gmatch(format) do
    result = k
  end
  return result
end
function _G.GetStringFromOcts(octs)
  if not octs then
    warn("No OctetsStream Data", debug.traceback())
    return ""
  end
  if type(octs) ~= "userdata" then
    warn("Wrong OctetsStream Data Type", debug.traceback())
    return ""
  end
  local OctetsStream = require("netio.OctetsStream")
  local key, os = OctetsStream.beginTempStream()
  os:marshalOctets(octs)
  local str = os:unmarshalStringFromOctets()
  OctetsStream.endTempStream(key)
  return str
end
function _G.SeondsToTimeText(seconds)
  local t = Seconds2HMSTime(seconds)
  local h = t.h
  t.h = h % 24
  t.d = math.floor(h / 24)
  local timeText = ""
  if t.d > 0 then
    local day = string.format(textRes.Common[204], t.d)
    local hour = string.format(textRes.Common[203], t.h)
    timeText = string.format("%s%s", day, hour)
  elseif t.h > 0 then
    local hour = string.format(textRes.Common[203], t.h)
    local min = string.format(textRes.Common[202], t.m)
    timeText = string.format("%s%s", hour, min)
  elseif 0 < t.m then
    local min = string.format(textRes.Common[202], t.m)
    local second = string.format(textRes.Common[201], t.s)
    timeText = string.format("%s%s", min, second)
  else
    timeText = string.format(textRes.Common[201], t.s)
  end
  return timeText
end
local downStatus = {}
function _G.DownLoadDataFromURL(url, cb, mutiCB)
  if not url or url:len() < 0 then
    warn("An invalid URL")
    return
  end
  local md5 = GameUtil.md5(url)
  local imgPath = Application.temporaryCachePath .. "/" .. md5
  if _G.platform == 0 then
    imgPath = Application.dataPath .. "/" .. md5
  end
  if not FileExists(imgPath) then
    if downStatus[url] then
      warn("DownLoading img From URL")
      if mutiCB then
        table.insert(downStatus[url], cb)
      end
      return
    else
      downStatus[url] = {cb}
    end
    GameUtil.downLoadUrl(url, imgPath, function(ret, url, imgPath, bytes)
      if not ret then
        warn("Fail to downLoad img from URL", url)
      else
        for _, v in ipairs(downStatus[url]) do
          v(imgPath)
        end
      end
      downStatus[url] = nil
    end)
  elseif cb then
    cb(imgPath)
  end
end
local ONE_DAY_SECONDS = 86400
function GetTodayRemainSeconds()
  local curTime = _G.GetServerTime()
  local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
  local t = AbsoluteTimer.GetServerTimeTable(curTime)
  local nowHour = t.hour
  local nowMinite = t.min
  local nowSec = t.sec
  nowSec = nowHour * 3600 + nowMinite * 60 + nowSec
  return ONE_DAY_SECONDS - nowSec
end
function ReadFromFile(path)
  local fin = io.open(path, "r")
  if fin then
    local result = fin:read("*a")
    fin:close()
    return result
  else
    return nil
  end
end
function IsAndroidSix()
  local isAndroid6 = function(operatingSystem)
    local match = operatingSystem:match("[^%.%d]([67])%.(%d+)")
    if match then
      return match
    end
    return nil
  end
  if Application.platform == RuntimePlatform.Android then
    if isAndroid6(SystemInfo.operatingSystem) then
      return true
    else
      return false
    end
  else
    return false
  end
end
function GetDirVersionService(serviceName)
  local DirVersionXMLHelper = require("Common.DirVersionXMLHelper")
  local doc = DirVersionXMLHelper.GetXmlDoc()
  if doc == nil then
    return nil
  end
  for i, elem in ipairs(doc.root.el) do
    if elem.name == "services" then
      return elem.attr[serviceName]
    end
  end
  return nil
end
function IsEvaluationUpdate()
  local DirVersionXMLHelper = require("Common.DirVersionXMLHelper")
  local doc = DirVersionXMLHelper.GetXmlDoc()
  if doc == nil then
    return false
  end
  local attr = doc.root.attr.evaluation_update
  if attr and attr == "true" then
    return true
  else
    return false
  end
end
function _G.OffsetPath(path, offsetX, offsetY)
  local newPath = {}
  for k, v in ipairs(path) do
    local p = {
      x = v.x + offsetX,
      y = v.y + offsetY
    }
    table.insert(newPath, p)
  end
  return newPath
end
function _G.pretty(obj)
  local uniqueTables = {}
  local ptostring = function(obj)
    local success, value = pcall(function()
      return tostring(obj)
    end)
    return success and value or "[unknow]"
  end
  local function prettyInner(obj, tname, iskey)
    if iskey then
      return ptostring(obj)
    elseif type(obj) == "table" then
      if uniqueTables[obj] == nil then
        tname = tname or "$"
        uniqueTables[obj] = tname
        local str = "{"
        for k, v in pairs(obj) do
          if obj ~= v then
            local pair = prettyInner(k, k, true) .. "=" .. prettyInner(v, tname .. "." .. ptostring(k))
            str = str .. (str == "{" and pair or ", " .. pair)
          end
        end
        return str .. "}"
      else
        return uniqueTables[obj]
      end
    elseif type(obj) == "string" then
      return string.format("%q", obj)
    else
      return ptostring(obj)
    end
  end
  return prettyInner(obj)
end
function _G.IsCrossingServer()
  return require("Main.Login.CrossServerLoginMgr").Instance():IsCrossingServer()
end
function _G.ToastCrossingServerForbiden()
  Toast(textRes.Common[501])
end
function _G.CheckCrossServerAndToast(tip)
  if IsCrossingServer() then
    if tip then
      Toast(tip)
    else
      ToastCrossingServerForbiden()
    end
    return true
  else
    return false
  end
end
function _G.SafeLuckDog(f)
  if IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_COMMENT_GUIDE) then
    SafeCall(function()
      if f() then
        Event.DispatchEvent(ModuleId.SHARE, gmodule.notifyId.Share.LUCKYDOG, nil)
      end
    end)
  end
end
function _G.IsOverseasVersion()
  return ClientCfg.GetSDKType() == ClientCfg.SDKTYPE.UNISDK
end
function _G.IsEfunVersion()
  local sdktype = ClientCfg.GetSDKType()
  if sdktype == ClientCfg.SDKTYPE.UNISDK then
    local logingPlatform = require("ProxySDK.ECUniSDK").Instance():GetChannelType()
    if logingPlatform == "efuntw" or logingPlatform == "efunhk" then
      return true
    end
  end
  return false
end
function _G._NormalizeHttpURL(url)
  url = string.gsub(url, "^(http):", "%1s:")
  return url
end
function _G.NormalizeHttpURL(url)
  if _G.IsForceHttpsVersion() then
    return _G._NormalizeHttpURL(url)
  end
  return url
end
local FORCE_HTTPS_BEGIN_VERSION = 110
function _G.IsForceHttpsVersion()
  if _G.platform ~= _G.Platform.ios then
    return false
  end
  local version = GameUtil.GetProgramCurrentVersionInfo()
  version = tonumber(version) or 0
  return version >= FORCE_HTTPS_BEGIN_VERSION
end
function _G.AttachParams2URL(url, params)
  local PARAM_DELIMITER = "&"
  local KV_DELIMITER = "="
  local QUESTION_MARK = "?"
  local HASH_MARK = "#"
  local querystr, fragment
  local qmIndex = url:find(QUESTION_MARK, 1, true)
  local hmIndex = url:find(HASH_MARK, 1, true)
  if hmIndex then
    fragment = url:sub(hmIndex + 1, -1)
  end
  if qmIndex then
    local endIndex = hmIndex and hmIndex - 1 or -1
    querystr = url:sub(qmIndex + 1, endIndex)
    url = url:sub(1, qmIndex - 1)
  else
    local endIndex = hmIndex and hmIndex - 1 or -1
    url = url:sub(1, endIndex)
  end
  local queryParams = {}
  local index = 0
  if querystr then
    local queryParamStrs = querystr:split(PARAM_DELIMITER)
    for i, v in ipairs(queryParamStrs) do
      local kv = v:split(KV_DELIMITER)
      local key = kv[1]
      local value = kv[2]
      index = index + 1
      queryParams[key] = {i = index, str = v}
    end
  end
  local function addOrReplace(key, value)
    local str = string.format("%s%s%s", key, KV_DELIMITER, value)
    if queryParams[key] then
      queryParams[key].str = str
    else
      index = index + 1
      queryParams[key] = {i = index, str = str}
    end
  end
  for k, v in pairs(params) do
    addOrReplace(k, v)
  end
  local queryParamVector = {}
  for k, v in pairs(queryParams) do
    queryParamVector[#queryParamVector + 1] = v
  end
  table.sort(queryParamVector, function(l, r)
    return l.i < r.i
  end)
  local newQueryParamStrs = {}
  for i, v in ipairs(queryParamVector) do
    newQueryParamStrs[#newQueryParamStrs + 1] = v.str
  end
  local newquerystr = table.concat(newQueryParamStrs, PARAM_DELIMITER)
  url = string.format("%s%s%s", url, QUESTION_MARK, newquerystr)
  if fragment then
    url = string.format("%s%s%s", url, HASH_MARK, fragment)
  end
  return url
end
function _G.AttachGameData2URL(url)
  local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
  if heroProp == nil then
    return url
  end
  local partition = tostring(require("netio.Network").m_zoneid)
  local rolename = heroProp.name:urlencode()
  local roleid = tostring(heroProp.id)
  local platid = platform == Platform.ios and 0 or platform == Platform.android and 1 or -1
  local params = {
    partition = partition,
    roleid = roleid,
    rolename = rolename,
    platid = platid
  }
  return _G.AttachParams2URL(url, params)
end
function _G.GetAllOpenedOccupations()
  local occupations = {}
  local num = 0
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CREATE_ROLE_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local isOpen = record:GetCharValue("isOpen") == 1 and true or false
    if isOpen then
      local occupationId = record:GetIntValue("occupationId")
      if occupations[occupationId] == nil then
        num = num + 1
        occupations[occupationId] = occupationId
      end
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return occupations, num
end
function _G.GetAllRealOpenedOccupations()
  local allOccupations, num = GetAllOpenedOccupations()
  local SwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local SOccupationEnum = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
  if not IsFeatureOpen(SwitchInfo.TYPE_NEW_OCCUPATION__CANG_YU) then
    allOccupations[SOccupationEnum.CANG_YU_GE] = nil
    num = num - 1
  end
  if not IsFeatureOpen(SwitchInfo.TYPE_NEW_OCCUPATION_LING_YIN_DIAN) then
    allOccupations[SOccupationEnum.LING_YIN_DIAN] = nil
    num = num - 1
  end
  return allOccupations, num
end
function _G.requireAgain(path)
  package.loaded[path] = nil
  local paths = string.split(path, ".")
  require("Lplus").Unload(paths[#paths])
  return require(path)
end
local OracleData = require("Main.Oracle.data.OracleData")
function _G.GetOriginalSkill(skillId)
  local original_skill_id = OracleData.Instance():GetOriginSkillId(skillId)
  if original_skill_id == 0 then
    original_skill_id = skillId
  end
  return original_skill_id
end
local ServerModue = require("Main.Server.ServerModule")
function _G.IsMergedServer(zoneid)
  local serverList = ServerModue.Instance().m_Zoneids
  if not serverList then
    return false
  end
  for k, v in pairs(serverList) do
    if v == zoneid then
      return true
    end
  end
  return false
end
function _G.SetAvatarIcon(go, avatarId, avatarFrameId)
  if go == nil then
    return
  end
  local AvatarInterface = require("Main.Avatar.AvatarInterface")
  local avatarInterface = AvatarInterface.Instance()
  local function setTexture(texture)
    if avatarId == nil then
      avatarId = avatarInterface:getCurAvatarId()
    end
    local avatarCfg = AvatarInterface.GetAvatarCfgById(avatarId)
    if avatarCfg then
      GUIUtils.FillIcon(texture, avatarCfg.avatarId)
    end
    if avatarFrameId == nil then
      return
    end
    if avatarFrameId == 0 then
      avatarFrameId = require("Main.Avatar.AvatarFrameMgr").Instance():getDefaultAvatarFrameId()
    end
    local parent = go.parent
    local avatarFrameGo = parent:FindDirect("Img_AvatarFrame")
    if avatarFrameGo == nil then
      local widget = texture:GetComponent("UIWidget")
      avatarFrameGo = GameObject.GameObject("Img_AvatarFrame")
      local goPos = go.localPosition
      avatarFrameGo.position = go.position
      local frameTexture = avatarFrameGo:AddComponent("UITexture")
      frameTexture.depth = texture.depth + 100
      frameTexture:set_width(widget:get_width() * 1.5 + 2)
      frameTexture:set_height(widget:get_height() * 1.5 + 2)
      avatarFrameGo:set_layer(parent:get_layer())
      avatarFrameGo.parent = parent
      avatarFrameGo:set_localScale(go.transform.localScale)
    end
    _G.SetAvatarFrameIcon(avatarFrameGo, avatarFrameId)
  end
  local uitexture = go:GetComponent("UITexture")
  if uitexture then
    setTexture(uitexture)
    return
  end
  local sprite = go:GetComponent("UISprite")
  if sprite then
    local widget = sprite:GetComponent("UIWidget")
    local w = widget:get_width()
    local h = widget:get_height()
    local d = widget.depth
    Object.Destroy(sprite)
    local uitexture = go:AddComponent("UITexture")
    uitexture.depth = d
    uitexture:set_width(w)
    uitexture:set_height(h)
    setTexture(uitexture)
  else
    warn("!!!!!!!!SetAvatarIcon error: UISprite and UITexture are nil")
  end
end
function _G.ShowCommonCenterTip(tipId)
  local CommonDescDlg = require("GUI.CommonUITipsDlg")
  local tipContent = require("Main.Common.TipsHelper").GetHoverTip(tipId)
  CommonDescDlg.ShowCommonTip(tipContent, {x = 0, y = 0})
end
function _G.SetAvatarFrameIcon(go, avatarFrameId)
  if _G.IsNil(go) then
    return
  end
  local AvatarFrameMgr = require("Main.Avatar.AvatarFrameMgr")
  if avatarFrameId == nil then
    avatarFrameId = AvatarFrameMgr.Instance():getCurAvatarFrameId()
  end
  if avatarFrameId == 0 then
    avatarFrameId = AvatarFrameMgr.Instance():getDefaultAvatarFrameId()
  end
  local uisprite = go:GetComponent("UISprite")
  if uisprite then
    uisprite.enabled = false
  end
  local uitexture = go:GetComponent("UITexture")
  if uitexture == nil then
    local wgt = go:GetComponent("UIWidget")
    local depth = 0
    if wgt then
      depth = wgt:get_depth()
    end
    uitexture = go:AddComponent("UITexture")
    local wgts = go:GetComponents("UIWidget")
    for i, v in ipairs(wgts) do
      v:set_depth(depth + i * 10)
    end
  end
  if uitexture then
    local avatarFrameCfg = AvatarFrameMgr.GetAvatarFrameCfg(avatarFrameId)
    GUIUtils.FillIcon(uitexture, avatarFrameCfg.avatarFrameId)
  else
    warn("!!!!!!!setAvatarFrame UITexture is nil")
  end
end
function _G.IsOccupationOpen(occupation, gender)
  local genders
  if gender then
    genders = {gender}
  else
    genders = {
      GenderEnum.MALE,
      GenderEnum.FEMALE
    }
  end
  for _, gender in ipairs(genders) do
    local occupationCfg = _G.GetOccupationCfg(occupation, gender)
    if occupationCfg then
      local switchId = occupationCfg.switchId
      if switchId == 0 then
        return true
      end
      if switchId == nil and Application.isEditor then
        return true
      end
      if _G.IsFeatureOpen(switchId) then
        return true
      end
    end
  end
  return false
end
function _G.IsOccupationExist(occupation)
  local genders = {
    GenderEnum.MALE,
    GenderEnum.FEMALE
  }
  for _, gender in ipairs(genders) do
    local occupationCfg = _G.GetOccupationCfg(occupation, gender)
    if occupationCfg then
      return true
    end
  end
  return false
end
function _G.GenShareImagePath(fileName)
  fileName = "UserData/share_snapshot/" .. fileName
  local filePath
  if platform == 1 then
    filePath = Application.persistentDataPath .. "/" .. fileName
  elseif platform == 2 then
    filePath = Application.persistentDataPath .. "/" .. fileName
  else
    filePath = Application.dataPath .. "/" .. fileName
  end
  GameUtil.CreateDirectoryForFile(filePath)
  return filePath
end
