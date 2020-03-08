local Lplus = require("Lplus")
local PetUtility = Lplus.Class("PetUtility")
local def = PetUtility.define
local PetData = Lplus.ForwardDeclare("PetData")
local PetCfgData = Lplus.ForwardDeclare("PetCfgData")
local PetModule = Lplus.ForwardDeclare("PetModule")
local PetSkillData = Lplus.ForwardDeclare("PetSkillData")
def.field("table").cachedConstans = function(...)
  return {}
end
local instance
def.static("=>", PetUtility).Instance = function()
  if instance == nil then
    instance = PetUtility()
  end
  return instance
end
def.method("number", "=>", PetCfgData).GetPetCfg = function(self, petCfgId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PET_CFG, petCfgId)
  if record == nil then
    warn("[GetPetCfg] get nil record for id: ", petCfgId)
    return PetCfgData()
  end
  local petCfg = PetCfgData()
  petCfg.templateId = DynamicRecord.GetIntValue(record, "templateId")
  petCfg.typeRefId = DynamicRecord.GetIntValue(record, "PetTypeIdRef")
  petCfg.modelId = DynamicRecord.GetIntValue(record, "modelId")
  petCfg.carryLevel = DynamicRecord.GetIntValue(record, "catchLevel")
  petCfg.petOpenIdipSwitch = DynamicRecord.GetIntValue(record, "petOpenIdipSwitch")
  petCfg.type = DynamicRecord.GetIntValue(record, "type")
  petCfg.colorId = DynamicRecord.GetIntValue(record, "colorId")
  petCfg.isCanBeHuaShengSubPet = DynamicRecord.GetCharValue(record, "isCanBeHuaShengFuPet") == 1
  petCfg.isCanBeHuaShengMainPet = DynamicRecord.GetCharValue(record, "isCanBeHuaShengMainPet") == 1
  petCfg.isSpecial = DynamicRecord.GetCharValue(record, "isSpecial") == 1
  petCfg.decorateItemId = DynamicRecord.GetIntValue(record, "PetDecorateRef")
  petCfg.defaultAssignPointCfgId = DynamicRecord.GetIntValue(record, "defaultPetPointCfg") or 0
  petCfg.fanShengCfgId = DynamicRecord.GetIntValue(record, "petFanSHengConfId") or 0
  petCfg.petScoreConfId = DynamicRecord.GetIntValue(record, "petScoreConfId") or 0
  petCfg.changeModelCardClassType = DynamicRecord.GetIntValue(record, "changeModelCardClassType") or 0
  petCfg.changeModelCardLevel = DynamicRecord.GetIntValue(record, "changeModelCardLevel") or 0
  petCfg.petFightModelRatio = DynamicRecord.GetIntValue(record, "petFightModelRatio") or 0
  local PetQualityType = require("netio.protocol.mzm.gsp.pet.PetAptConsts")
  petCfg.minQualitys = {
    [PetQualityType.HP_APT] = record:GetIntValue("minHPApt"),
    [PetQualityType.PHYATK_APT] = record:GetIntValue("minPhyAtkApt"),
    [PetQualityType.PHYDEF_APT] = record:GetIntValue("minPhyDefApt"),
    [PetQualityType.MAGATK_APT] = record:GetIntValue("minMagAtkApt"),
    [PetQualityType.MAGDEF_APT] = record:GetIntValue("minMagDefApt"),
    [PetQualityType.SPEED_APT] = record:GetIntValue("minSpdApt")
  }
  petCfg.maxQualitys = {
    [PetQualityType.HP_APT] = record:GetIntValue("maxHPApt"),
    [PetQualityType.PHYATK_APT] = record:GetIntValue("maxPhyAtkApt"),
    [PetQualityType.PHYDEF_APT] = record:GetIntValue("maxPhyDefApt"),
    [PetQualityType.MAGATK_APT] = record:GetIntValue("maxMagAtkApt"),
    [PetQualityType.MAGDEF_APT] = record:GetIntValue("maxMagDefApt"),
    [PetQualityType.SPEED_APT] = record:GetIntValue("maxSpdApt")
  }
  petCfg.growMinValue = DynamicRecord.GetFloatValue(record, "growMinLimit")
  petCfg.growMaxValue = DynamicRecord.GetFloatValue(record, "growMaxLimit")
  petCfg.templateName = DynamicRecord.GetStringValue(record, "templateName")
  petCfg.shortName = DynamicRecord.GetStringValue(record, "shortName")
  petCfg.skillPropTabId = DynamicRecord.GetIntValue(record, "skillPropTabId")
  petCfg.bornMaxLife = DynamicRecord.GetIntValue(record, "bornMaxLife")
  petCfg.buyPrice = DynamicRecord.GetIntValue(record, "buyPrice")
  petCfg.yaoliLevelId = DynamicRecord.GetIntValue(record, "yaoliLevel") or 0
  petCfg.qualityStageRate = DynamicRecord.GetIntValue(record, "aptStageRate") or 0
  petCfg.qualityStageRate = petCfg.qualityStageRate / 10000
  petCfg.growStageRate = DynamicRecord.GetIntValue(record, "growStageRate") or 0
  return petCfg
end
def.static("number", "number", "number", "=>", "table").FindPetsByTypeAndCatachLevel = function(type, minCatchLevel, maxCatchLevel)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_PET_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local list = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = {}
    cfg.catchLevel = DynamicRecord.GetIntValue(entry, "catchLevel")
    cfg.type = DynamicRecord.GetIntValue(entry, "type")
    if type == cfg.type and minCatchLevel <= cfg.catchLevel and maxCatchLevel >= cfg.catchLevel then
      cfg.templateId = DynamicRecord.GetIntValue(entry, "templateId")
      table.insert(list, cfg)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return list
end
def.static("number", "=>", "table").GetPetTypeRefCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PET_TYPE_REF_CFG, id)
  if record == nil then
    warn("GetPetTypeRefCfg(" .. id .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.id = id
  cfg.wildId = record:GetIntValue("wildId")
  cfg.baobaoId = record:GetIntValue("baobaoId")
  cfg.bianYiId = record:GetIntValue("bianYiId")
  return cfg
end
def.method("string", "=>", "dynamic").GetPetConstants = function(self, key)
  if self.cachedConstans[key] then
    return self.cachedConstans[key]
  end
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PET_CONSTANTS_CFG, key)
  if record == nil then
    warn("GetPetConstants(" .. key .. ") return nil")
    return nil
  end
  local value = DynamicRecord.GetIntValue(record, "value")
  self.cachedConstans[key] = value
  return value
end
local yaoliCfgs = {}
local _yaoliNameMap
def.method("number", "number", "=>", "table").GetPetYaoLiCfg = function(self, yaoliLevelId, score)
  local PetYaoLi = require("consts.mzm.gsp.pet.confbean.PetYaoLi")
  local entries = DynamicData.GetTable(CFG_PATH.DATA_PET_YAO_LI_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  if yaoliCfgs[yaoliLevelId] == nil then
    yaoliCfgs[yaoliLevelId] = {}
    for i = 0, count - 1 do
      local entry = DynamicDataTable.GetRecordByIdx(entries, i)
      local _yaoliLevelId = DynamicRecord.GetIntValue(entry, "yaoliLevel")
      if _yaoliLevelId == yaoliLevelId then
        local cfg = {}
        cfg.minValue = DynamicRecord.GetIntValue(entry, "minValue")
        cfg.maxValue = DynamicRecord.GetIntValue(entry, "maxValue")
        cfg.recordIdx = i
        table.insert(yaoliCfgs[yaoliLevelId], cfg)
      end
    end
  end
  if _yaoliNameMap == nil then
    _yaoliNameMap = {}
    for k, v in pairs(PetYaoLi) do
      _yaoliNameMap[v] = k
    end
  end
  local function getCfg(cfg)
    local recordIdx = cfg.recordIdx
    if recordIdx == nil then
      return cfg
    end
    cfg.recordIdx = nil
    local record = DynamicDataTable.GetRecordByIdx(entries, recordIdx)
    cfg.petYaoLiLevel = DynamicRecord.GetIntValue(record, "petYaoLiLevel")
    cfg.yaoLiName = _yaoliNameMap[cfg.petYaoLiLevel] or ""
    cfg.iconBgCfgId = DynamicRecord.GetIntValue(record, "frameImage") or 0
    cfg.marketPriceLimit = DynamicRecord.GetIntValue(record, "marketPriceLimit") or 0
    cfg.iconBgSpriteName = ""
    local bgCfg = self:GetPetIconBgCfg(cfg.iconBgCfgId)
    if bgCfg then
      cfg.iconBgSpriteName = bgCfg.spriteName
    end
    local encodeChar = PetYaoLi.SSS
    if cfg.petYaoLiLevel >= PetYaoLi.A then
      encodeChar = string.char(65 + cfg.petYaoLiLevel - PetYaoLi.A)
    elseif cfg.petYaoLiLevel == PetYaoLi.S then
      encodeChar = string.char(83)
    elseif cfg.petYaoLiLevel == PetYaoLi.SS then
      encodeChar = string.char(84)
    elseif cfg.petYaoLiLevel == PetYaoLi.SSS then
      encodeChar = string.char(85)
    end
    cfg.encodeChar = encodeChar
    return cfg
  end
  local lastCfg
  for i, v in ipairs(yaoliCfgs[yaoliLevelId]) do
    lastCfg = v
    if score >= v.minValue and score <= v.maxValue then
      return getCfg(v)
    end
  end
  warn(string.format("Failed to get pet YaoLi Cfg for yaoliLevelId=%d, score=%d ", yaoliLevelId, score))
  if lastCfg then
    return getCfg(lastCfg)
  end
  return nil
end
def.method("number", "=>", "table").GetPetLevelScoreCfg = function(self, cfgId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PET_LEVEL_SCORE_CFG, cfgId)
  if record == nil then
    warn("GetPetLevelScoreCfg(" .. cfgId .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.id = cfgId
  cfg.minAptRate = record:GetIntValue("minAptRate")
  cfg.maxAptRate = record:GetIntValue("maxAptRate")
  cfg.minGrowRate = record:GetIntValue("minGrowRate")
  cfg.maxGrowRate = record:GetIntValue("maxGrowRate")
  cfg.param1Rate = record:GetIntValue("param1Rate")
  cfg.param2Rate = record:GetIntValue("param2Rate")
  return cfg
end
def.method("number", "=>", "table").GetPetIconBgCfg = function(self, cfgId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PET_ICON_BG_CFG, cfgId)
  if record == nil then
    warn("GetPetIconBgCfg(" .. cfgId .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.id = cfgId
  cfg.spriteName = record:GetStringValue("frameImage")
  return cfg
end
def.method("number", "=>", "table").GetPetSkillCfg = function(self, skillId)
  local cfg
  if not PetUtility.IsPassiveSkill(skillId) then
    return self:_GetPetSkillCfg(skillId)
  else
    return self:_GetPetPassiveSkillCfg(skillId)
  end
end
def.method("number", "=>", "table")._GetPetSkillCfg = function(self, skillId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_SKILL_CFG, skillId)
  if record == nil then
    warn("GetPetSkillCfg(" .. skillId .. ") return nil")
    return {}
  end
  local cfg = {}
  cfg.id = DynamicRecord.GetIntValue(record, "id")
  cfg.name = DynamicRecord.GetStringValue(record, "name")
  cfg.description = DynamicRecord.GetStringValue(record, "description")
  cfg.iconId = DynamicRecord.GetIntValue(record, "icon")
  cfg.conditionId = DynamicRecord.GetIntValue(record, "condition")
  cfg.type = DynamicRecord.GetIntValue(record, "type")
  return cfg
end
def.method("number", "=>", "table")._GetPetPassiveSkillCfg = function(self, skillId)
  return require("Main.Skill.SkillUtility").GetPassiveSkillCfg(skillId)
end
def.static("number", "=>", "boolean").IsPassiveSkill = function(skillId)
  return require("Main.Skill.SkillUtility").IsPassiveSkill(skillId)
end
def.method("=>", "table").GetPetPropTransCfg = function(self)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_PET_PROP_TRANS_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgList = {}
  for i = 0, count - 1 do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i)
    local cfg = {}
    cfg.templateId = DynamicRecord.GetIntValue(entry, "templateId")
    cfg.basePropType = DynamicRecord.GetIntValue(entry, "basePropType")
    cfg.fightPropType = DynamicRecord.GetIntValue(entry, "fightPropType")
    cfg.bp2fpFactor = DynamicRecord.GetFloatValue(entry, "bp2fpFactor")
    cfg.templateName = DynamicRecord.GetStringValue(entry, "templateName")
    local propKey = self:GenPropKey(cfg.basePropType, cfg.fightPropType)
    cfgList[propKey] = cfg
  end
  return cfgList
end
def.method("number", "number", "=>", "number").GenPropKey = function(self, basePropType, secondPropType)
  return basePropType * 10000 + secondPropType
end
def.method("number", "number", "=>", "table").GetExpandBagCfg = function(self, bagId, bagCapacity)
  local bagCfg = DynamicData.GetRecord(CFG_PATH.DATA_BAGCFG, bagId)
  local initCap = bagCfg:GetIntValue("initcapacity")
  local addCount = bagCfg:GetIntValue("addCount")
  local extendItemId = bagCfg:GetIntValue("extendItemId")
  local maxcapacity = bagCfg:GetIntValue("maxcapacity")
  local expandCount = (bagCapacity - initCap) / addCount + 1
  local cfg = {}
  cfg.expandItemId = extendItemId
  cfg.addSpaceNum = addCount
  cfg.expandCount = expandCount
  cfg.canExpand = true
  if bagCapacity >= maxcapacity then
    cfg.canExpand = false
  end
  local itemNeedNum = 0
  local bagExtendCfg = DynamicData.GetTable(CFG_PATH.DATA_EXTENDBAGCFG)
  local count = DynamicDataTable.GetRecordsCount(bagExtendCfg)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.GetRecordByIdx(bagExtendCfg, i)
    local cfgBagId = entry:GetIntValue("bagId")
    local cfgExpandCount = entry:GetIntValue("extendCount")
    if cfgExpandCount == expandCount and cfgBagId == bagId then
      cfg.itemNeedNum = entry:GetIntValue("itemCount")
      break
    end
  end
  return cfg
end
def.static("number", "=>", "table").GetPetLianGuItemCfg = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PET_LIANGU_ITEM_CFG, itemId)
  if record == nil then
    warn("GetPetLianGuItemCfg(" .. itemId .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.expectAddRate = record:GetIntValue("expectAddRate")
  cfg.floatExpectRate = record:GetIntValue("floatExpectRate")
  cfg.floatMaxNum = record:GetIntValue("floatMaxNum")
  cfg.minAddNum = record:GetIntValue("minAddNum")
  return cfg
end
def.static("number", "=>", "number").GetPetLevelUpExp = function(toLevel)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PET_LEVEL_UP_EXP_CFG, toLevel)
  if record == nil then
    warn("GetPetLevelUpExp(" .. toLevel .. ") return nil")
    return 0
  end
  local neededExp = record:GetIntValue("needExp")
  return neededExp
end
def.static("number", "=>", "table").FindPetTuJianCfgByTypeRefId = function(typeRefId)
  return PetUtility.FindPetTuJianCfg("petTypeCfgId", typeRefId)
end
def.static("number", "=>", "table").FindPetTuJianCfgByTemplateId = function(templateId)
  return PetUtility.FindPetTuJianCfg("petId", templateId)
end
def.static("string", "number", "=>", "table").FindPetTuJianCfg = function(attr, value)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_PET_TU_JIAN_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local petInfoList = {}
  local cfg
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfgValue = entry:GetIntValue(attr)
    if value == cfgValue then
      cfg = {}
      cfg.carryLevel = entry:GetIntValue("catchLevel")
      cfg.mapId = entry:GetIntValue("mapId")
      cfg.page = entry:GetIntValue("page")
      cfg.petTemplateId = entry:GetIntValue("petId")
      cfg.petTypeRefId = entry:GetIntValue("petTypeCfgId")
      cfg.templateId = entry:GetIntValue("templateId")
      cfg.desc = entry:GetStringValue("desc")
      break
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfg
end
def.static("number", "number", "=>", "table").GetTuJianPets = function(page, level)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_PET_TU_JIAN_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local petInfoList = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = {}
    cfg.carrayLevel = entry:GetIntValue("catchLevel")
    cfg.page = entry:GetIntValue("page")
    if page == cfg.page and level + 10 >= cfg.carrayLevel then
      cfg.mapId = entry:GetIntValue("mapId")
      cfg.petTemplateId = entry:GetIntValue("petId")
      cfg.petTypeRefId = entry:GetIntValue("petTypeCfgId")
      cfg.desc = entry:GetStringValue("desc")
      cfg.petTypeStr = entry:GetStringValue("petTypeStr") or ""
      cfg.needItemId = entry:GetIntValue("needItemId")
      cfg.needItemNum = entry:GetIntValue("needItemNum")
      cfg.npcId = entry:GetIntValue("npcId")
      cfg.getType = entry:GetIntValue("getType")
      cfg.isCommingSoon = false
      if level < cfg.carrayLevel then
        cfg.isCommingSoon = true
      end
      local isPetOpen = true
      if cfg.petTemplateId ~= 0 then
        local specicalPetCfg = PetUtility.Instance():GetPetCfg(cfg.petTemplateId)
        if specicalPetCfg ~= nil then
          isPetOpen = isPetOpen and IsFeatureOpen(specicalPetCfg.petOpenIdipSwitch)
        else
          warn("no pet templateId:" .. cfg.petTemplateId)
          isPetOpen = false
        end
      else
        local petTypeRefCfg = PetUtility.GetPetTypeRefCfg(cfg.petTypeRefId)
        if petTypeRefCfg ~= nil then
          local baobaoPet = PetUtility.Instance():GetPetCfg(petTypeRefCfg.baobaoId)
          local bianyiPet = PetUtility.Instance():GetPetCfg(petTypeRefCfg.bianYiId)
          if baobaoPet ~= nil and isPetOpen then
            isPetOpen = IsFeatureOpen(baobaoPet.petOpenIdipSwitch)
          end
          if bianyiPet ~= nil then
            isPetOpen = isPetOpen and IsFeatureOpen(bianyiPet.petOpenIdipSwitch)
          end
        else
          warn("no pet ref to type:" .. cfg.petTypeRefId)
          isPetOpen = false
        end
      end
      if isPetOpen then
        table.insert(petInfoList, cfg)
      end
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return petInfoList
end
def.static("number", "number").TryToExpandPetBag = function(bagId, bagCapacity)
  local ItemModule = require("Main.Item.ItemModule")
  local ItemUtils = require("Main.Item.ItemUtils")
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  local expandBagCfg = PetUtility.Instance():GetExpandBagCfg(bagId, bagCapacity)
  local titleName, targetName, failedPrompt, failedPrompt2, itemType
  if bagId == PetModule.PET_BAG_ID then
    titleName = textRes.Pet[11]
    targetName = textRes.Pet[14]
    failedPrompt = textRes.Pet[16]
    failedPrompt2 = textRes.Pet[30]
    itemType = ItemType.PET_EXPAND_BAG
  else
    titleName = textRes.Pet[12]
    targetName = textRes.Pet[15]
    failedPrompt = textRes.Pet[29]
    failedPrompt2 = textRes.Pet[31]
    itemType = ItemType.PET_EXPAND_STORAGE
  end
  if expandBagCfg.canExpand == false then
    Toast(failedPrompt2)
    return
  end
  local itemId = expandBagCfg.expandItemId
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  local USE_ITEM_NUM = expandBagCfg.itemNeedNum
  local items = ItemModule.Instance():GetItemsByItemType(ItemModule.BAG, itemType)
  local count = 0
  for k, v in pairs(items) do
    count = count + v.number
  end
  local itemNum = count
  local desc = targetName
  local title, extendItemId, itemNeed = titleName, itemId, USE_ITEM_NUM
  local ItemConsumeHelper = require("Main.Item.ItemConsumeHelper")
  ItemConsumeHelper.Instance():ShowItemConsume(title, desc, extendItemId, itemNeed, function(select)
    local function ExpandBag(extraParams)
      if bagId == PetModule.PET_BAG_ID then
        require("Main.Pet.mgr.PetMgr").Instance():ExpandPetBag(itemNum)
      else
        require("Main.Pet.mgr.PetStorageMgr").Instance():ExpandStorageCapacity(itemNum)
      end
    end
    if select < 0 then
    elseif select == 0 then
      ExpandBag({isYuanBaoBuZu = false})
    else
      ExpandBag({isYuanBaoBuZu = true})
    end
  end)
end
def.static("number", "number", "=>", "table").GetPetHuaShengNeedCfg = function(mainPetType, catchLevel)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_PET_HUA_SHENG_NEED_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfg = {}
  for i = 0, count - 1 do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i)
    cfg.mainPetType = DynamicRecord.GetIntValue(entry, "mainPetType")
    cfg.catchLevel = DynamicRecord.GetIntValue(entry, "catchLevel")
    if cfg.mainPetType == mainPetType and cfg.catchLevel == catchLevel then
      cfg.costCopper = DynamicRecord.GetIntValue(entry, "costCopper")
      cfg.needItemNum = DynamicRecord.GetIntValue(entry, "needItemNum")
      cfg.lowEnsureCfg = {}
      cfg.highEnsureCfg = {}
      local ensureSkillStruct = entry:GetStructValue("ensureSkillStruct")
      local size = ensureSkillStruct:GetVectorSize("ensureSkillVector")
      for i = 0, size - 1 do
        local vectorRow = ensureSkillStruct:GetVectorValueByIdx("ensureSkillVector", i)
        local lowEnsureNeedNum = vectorRow:GetIntValue("lowEnsureNeedNum")
        local highEnsureNeedNum = vectorRow:GetIntValue("highEnsureNeedNum")
        cfg.lowEnsureCfg[i] = lowEnsureNeedNum
        cfg.highEnsureCfg[i] = highEnsureNeedNum
      end
      break
    end
  end
  if cfg.costCopper == nil or cfg.needItemNum == nil then
    cfg.costCopper = cfg.costCopper or 0
    cfg.needItemNum = cfg.needItemNum or 0
    warn("GetPetHuaShengNeedCfg(" .. mainPetType .. "," .. catchLevel .. ") cannot find cfg")
  end
  return cfg
end
def.static("number", "=>", "table").GetPetFanShengNeedCfg = function(fanShengCfgId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PET_FAN_SHENG_NEED_CFG, fanShengCfgId)
  if record == nil then
    warn("GetPetFanShengNeedCfg(" .. fanShengCfgId .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.id = fanShengCfgId
  cfg.normalNeedItemNum = record:GetIntValue("putTongFanShengDanItemNum")
  cfg.advanceNeedItemNum = record:GetIntValue("gaoJiFanShengDanItemNum")
  return cfg
end
def.static("number", "=>", "table").GetPetEquipmentCfg = function(equipmentId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PET_EQUIPMENT_CFG, equipmentId)
  if record == nil then
    warn("GetPetEquipmentCfg(" .. equipmentId .. ") return nil")
    return nil
  end
  return PetUtility._GetPetEquipmentCfg(record)
end
def.static("=>", "table").GetAllPetEquipmentCfgs = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_PET_EQUIPMENT_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  for i = 0, count - 1 do
    local record = DynamicDataTable.GetRecordByIdx(entries, i)
    local cfg = PetUtility._GetPetEquipmentCfg(record)
    cfgs[#cfgs + 1] = cfg
  end
  return cfgs
end
def.static("userdata", "=>", "table")._GetPetEquipmentCfg = function(record)
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.equipLevel = record:GetIntValue("equipLevel")
  cfg.equipType = record:GetIntValue("equipType")
  cfg.petPropertyTableId = record:GetIntValue("PetPropertyTableId")
  cfg.skills = {}
  local monsterSkillId = record:GetIntValue("monsterSkillId")
  local skillIdMap = {}
  if monsterSkillId ~= 0 then
    skillIdMap[monsterSkillId] = true
    table.insert(cfg.skills, monsterSkillId)
  end
  local skillPropsStruct = record:GetStructValue("skillPropsStruct")
  local size = skillPropsStruct:GetVectorSize("skillPropsVector")
  for i = 0, size - 1 do
    local vectorRow = skillPropsStruct:GetVectorValueByIdx("skillPropsVector", i)
    local monsterSkillId = vectorRow:GetIntValue("monsterSkillId")
    local monsterSkillProb = vectorRow:GetIntValue("monsterSkillProb")
    local monster2SkillId = vectorRow:GetIntValue("monster2SkillId")
    local monster2SkillProb = vectorRow:GetIntValue("monster2SkillProb")
    if monsterSkillId > 0 and monsterSkillProb > 0 and skillIdMap[monsterSkillId] == nil then
      skillIdMap[monsterSkillId] = true
      table.insert(cfg.skills, monsterSkillId)
    end
    if monster2SkillId > 0 and monster2SkillProb > 0 and skillIdMap[monster2SkillId] == nil then
      skillIdMap[monster2SkillId] = true
      table.insert(cfg.skills, monster2SkillId)
    end
  end
  return cfg
end
def.static("number", "=>", "table").GetPetEquipmentPropertyCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PET_EQUIPMENT_PROP_CFG, id)
  if record == nil then
    warn("GetPetEquipmentPropertyCfg(" .. id .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.props = {}
  local propMap = {}
  local propsStruct = record:GetStructValue("propsStruct")
  local size = propsStruct:GetVectorSize("propsVector")
  for i = 0, size - 1 do
    local vectorRow = propsStruct:GetVectorValueByIdx("propsVector", i)
    local propType = vectorRow:GetIntValue("propType") or 0
    if propType ~= 0 and propMap[propType] == nil then
      propMap[propType] = propType
      table.insert(cfg.props, propType)
    end
  end
  return cfg
end
def.static("=>", "table").GetPetXiLianItemCfg = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_PET_XI_LIAN_ITEM_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfg = {}
  for i = 0, count - 1 do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i)
    local id = DynamicRecord.GetIntValue(entry, "id")
    local xilianItemLevel = DynamicRecord.GetIntValue(entry, "xilianItemLevel")
    cfg[xilianItemLevel] = cfg[xilianItemLevel] or {}
    table.insert(cfg[xilianItemLevel], id)
  end
  return cfg
end
def.static("number", "=>", "table").GetPetSkillBookItemCfg = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PET_SKILL_BOOK_ITEM_CFG, itemId)
  if record == nil then
    warn("GetPetSkillBookItemCfg(" .. itemId .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.id = itemId
  cfg.skillId = record:GetIntValue("skillId")
  cfg.itemPhase = record:GetIntValue("itemPhase")
  cfg.skillPhase = record:GetIntValue("skillPhase")
  return cfg
end
def.static("number", "=>", "table").GetPetShopCfg = function(petId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PET_SHOP_CFG, petId)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.petId = petId
  return cfg
end
def.static("number", "=>", "boolean").PetCanBuyInShop = function(petCfgId)
  local petShopCfg = PetUtility.GetPetShopCfg(petCfgId)
  if petShopCfg then
    local petCfg = PetUtility.Instance():GetPetCfg(petCfgId)
    local switchId = petCfg.petOpenIdipSwitch
    if IsFeatureOpen(switchId) then
      return true
    else
      return false
    end
  else
    return false
  end
end
def.static("number", "=>", "table").GetPetDecorateItemCfg = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PET_DECORATE_ITEM_CFG, itemId)
  if record == nil then
    warn("GetPetDecorateItemCfg(" .. itemId .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.addRealAptMaxLimit = record:GetIntValue("addRealAptMaxLimit")
  cfg.petCatchLevel = record:GetIntValue("petCatchLevel")
  return cfg
end
local petJinjieCfg
def.static("number", "=>", "table").GetPetJinjieCfgByPetId = function(petId)
  if petJinjieCfg ~= nil then
    return petJinjieCfg[petId]
  end
  local entries = DynamicData.GetTable(CFG_PATH.DATA_PET_JINJIE_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  petJinjieCfg = {}
  for i = 0, count - 1 do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i)
    local cfg = {}
    cfg.id = DynamicRecord.GetIntValue(entry, "id")
    cfg.templateName = DynamicRecord.GetStringValue(entry, "templateName")
    cfg.petCfgId = DynamicRecord.GetIntValue(entry, "petCfgId")
    cfg.stage = DynamicRecord.GetIntValue(entry, "stage")
    cfg.upStageNeedLevel = DynamicRecord.GetIntValue(entry, "upStageNeedLevel")
    cfg.itemType = DynamicRecord.GetIntValue(entry, "itemType")
    cfg.itemNum = DynamicRecord.GetIntValue(entry, "itemNum")
    cfg.growAddRate = DynamicRecord.GetIntValue(entry, "growAddRate")
    cfg.hpAptAdd = DynamicRecord.GetIntValue(entry, "hpAptAdd")
    cfg.phyAtkAptAdd = DynamicRecord.GetIntValue(entry, "phyAtkAptAdd")
    cfg.magAtkAptAdd = DynamicRecord.GetIntValue(entry, "magAtkAptAdd")
    cfg.phyDefAptAdd = DynamicRecord.GetIntValue(entry, "phyDefAptAdd")
    cfg.magDefAptAdd = DynamicRecord.GetIntValue(entry, "magDefAptAdd")
    cfg.speedAptAdd = DynamicRecord.GetIntValue(entry, "speedAptAdd")
    cfg.petJinJieSkillCfgId = DynamicRecord.GetIntValue(entry, "petJinJieSkillCfgId")
    cfg.skillId = PetUtility.GetPetStateSkillId(cfg.petJinJieSkillCfgId, cfg.stage)
    petJinjieCfg[cfg.petCfgId] = petJinjieCfg[cfg.petCfgId] or {}
    petJinjieCfg[cfg.petCfgId][cfg.stage] = cfg
  end
  return petJinjieCfg[petId]
end
def.static("number", "number", "=>", "table").GetPetNextStateCfg = function(petId, curStage)
  local jinjieCfg = PetUtility.GetPetJinjieCfgByPetId(petId)
  if jinjieCfg == nil then
    return nil
  end
  return jinjieCfg[curStage + 1]
end
local petJinjieSkillCfg = {}
def.static("number", "number", "=>", "number").GetPetStateSkillId = function(skillCfgId, curStage)
  if petJinjieSkillCfg[skillCfgId] ~= nil and petJinjieSkillCfg[skillCfgId][curStage] ~= nil then
    return petJinjieSkillCfg[skillCfgId][curStage]
  end
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PET_JINJIE_SKILL_CFG, skillCfgId)
  if record == nil then
    return -1
  end
  local skillList = {}
  local skillIdListStruct = record:GetStructValue("skillIdListStruct")
  local size = skillIdListStruct:GetVectorSize("skillIdList")
  for i = 0, size - 1 do
    local skill = skillIdListStruct:GetVectorValueByIdx("skillIdList", i)
    local skillId = skill:GetIntValue("skillId")
    skillList[i] = skillId
  end
  petJinjieSkillCfg[skillCfgId] = skillList
  local skillId = skillList[curStage]
  return skillId ~= nil and skillId or -1
end
local pet_light_entries, pet_light_catalog
def.static("number", "number", "=>", "table").GetPetJinjieModelCfg = function(stage, modelId)
  if pet_light_entries == nil or pet_light_catalog == nil then
    pet_light_catalog = {}
    pet_light_entries = DynamicData.GetTable(CFG_PATH.DATA_PET_JINJIE_MODEL_CFG)
    local count = DynamicDataTable.GetRecordsCount(pet_light_entries)
    DynamicDataTable.FastGetRecordBegin(pet_light_entries)
    for i = 1, count - 1 do
      local record = DynamicDataTable.FastGetRecordByIdx(pet_light_entries, i)
      local modelIdcfg = record:GetIntValue("petModelId")
      local stagecfg = record:GetIntValue("stage")
      local key = bit.lshift(modelIdcfg, 4) + stagecfg
      pet_light_catalog[key] = i
    end
    DynamicDataTable.FastGetRecordEnd(pet_light_entries)
  end
  local key = bit.lshift(modelId, 4) + stage
  local index = pet_light_catalog[key]
  if index == nil then
    warn("[GetPetJinjieModelCfg]data not found for stage and modelId: ", stage, modelId)
    return nil
  end
  local record = DynamicDataTable.GetRecordByIdx(pet_light_entries, index)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.lightXNum = record:GetIntValue("lightXNum")
  cfg.lightYNum = record:GetIntValue("lightYNum")
  cfg.r_num = record:GetIntValue("r_num")
  cfg.g_num = record:GetIntValue("g_num")
  cfg.b_num = record:GetIntValue("b_num")
  cfg.a_num = record:GetIntValue("a_num")
  cfg.boneName = record:GetStringValue("bindName")
  return cfg
end
def.static("table", "userdata").ShowPetEquipmentTip = function(equipment, sourceObj)
  local item = equipment
  local position = sourceObj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = sourceObj:GetComponent("UIWidget")
  local key = 1
  local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
  local ItemModule = require("Main.Item.ItemModule")
  ItemTipsMgr.Instance():ShowTips(item, ItemModule.EQUIPBAG, key, ItemTipsMgr.Source.PetItemEquip, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), 1)
end
def.static("table", "userdata", "number").ShowPetRepEquipmentTip = function(equipment, sourceObj, slot)
  local item = equipment
  local position = sourceObj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = sourceObj:GetComponent("UIWidget")
  local key = 1
  local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
  local ItemModule = require("Main.Item.ItemModule")
  local tip = ItemTipsMgr.Instance():ShowTips(item, ItemModule.EQUIPBAG, key, ItemTipsMgr.Source.PetBasicNode, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), 1)
  tip:SetOperateContext({slot = slot})
end
def.static("table", "userdata", "number").ShowPetSkillDataTip = function(petSkillData, sourceObj, prefer)
  PetUtility.ShowPetSkillTipEx(petSkillData.id, petSkillData.level, sourceObj, prefer)
end
def.static("number", "userdata", "number").ShowPetSkillTip = function(petSkillId, sourceObj, prefer)
  local fightingPet = require("Main.Pet.Interface").GetFightingPet()
  local level = 0
  if fightingPet then
    level = fightingPet.level
  else
    level = _G.GetHeroProp().level
  end
  PetUtility.ShowPetSkillTipEx(petSkillId, level, sourceObj, prefer)
end
function PetUtility.ShowPetSkillTipEx(petSkillId, level, sourceObj, prefer, context)
  local position = sourceObj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = sourceObj:GetComponent("UIWidget")
  require("Main.Skill.SkillTipMgr").Instance():ShowPetTipEx(petSkillId, level, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), prefer, context)
end
def.static("table", "userdata", "string", "string", "string", "string", "string", "dynamic", "boolean", "=>", "number").SetSkillList = function(pet, grid, skillIconName, rememberIconName, amuletIconName, rideIconName, petMarkIconName, addIconName, isShowMountsSkills)
  local GUIUtils = require("GUI.GUIUtils")
  local gridItemCount = grid:GetChildListCount()
  local gridChildList = grid:GetChildList()
  local selfSkillIdList = pet:GetSkillIdList()
  local selfSkillAmount = selfSkillIdList and #selfSkillIdList or 0
  local skillIdList = pet:GetConcatSkillIdList() or {}
  local concatSkillAmount = #skillIdList
  local mountsSkillEnd = concatSkillAmount
  if isShowMountsSkills then
    local skillMountsIdList = pet:GetProtectMountsSkillIdList() or {}
    for _, v in ipairs(skillMountsIdList) do
      table.insert(skillIdList, v)
    end
    mountsSkillEnd = mountsSkillEnd + #skillMountsIdList
  end
  local petMarkSkillId = pet:GetPetMarkSkillId()
  if petMarkSkillId > 0 then
    table.insert(skillIdList, petMarkSkillId)
  end
  grid:DragToMakeVisible(1, 100)
  local addSkillIconIndex = 1
  for i = 1, gridItemCount do
    local skillId = skillIdList[i]
    local objIndex = string.format("%02d", i)
    local itemObj = gridChildList[i].gameObject
    PetUtility.SafeSetActive(itemObj, skillIconName .. objIndex, false)
    PetUtility.SafeSetActive(itemObj, rememberIconName, false)
    PetUtility.SafeSetActive(itemObj, amuletIconName, false)
    PetUtility.SafeSetActive(itemObj, rideIconName, false)
    PetUtility.SafeSetActive(itemObj, petMarkIconName, false)
    if addIconName then
      PetUtility.SafeSetActive(itemObj, addIconName .. objIndex, false)
    end
    if skillId then
      PetUtility.SetPetSkillBgColor(itemObj, skillId)
      PetUtility.SafeSetActive(itemObj, skillIconName .. objIndex, true)
      if skillId == pet.rememberedSkillId and i <= selfSkillAmount then
        PetUtility.SafeSetActive(itemObj, rememberIconName, true)
      end
      if i > selfSkillAmount and i <= concatSkillAmount then
        PetUtility.SafeSetActive(itemObj, amuletIconName, true)
      end
      if i > concatSkillAmount and i <= mountsSkillEnd then
        PetUtility.SafeSetActive(itemObj, rideIconName, true)
      end
      if i > mountsSkillEnd then
        PetUtility.SafeSetActive(itemObj, petMarkIconName, true)
      end
      local skillCfg = PetUtility.Instance():GetPetSkillCfg(skillId)
      if skillCfg.iconId == 0 then
        warn(string.format("skill(%s)'s iconId == 0", skillCfg.name))
      end
      local uiTexture = gridChildList[i].gameObject:FindDirect(skillIconName .. objIndex):GetComponent("UITexture")
      GUIUtils.FillIcon(uiTexture, skillCfg.iconId)
      addSkillIconIndex = addSkillIconIndex + 1
    elseif i == addSkillIconIndex and pet.id ~= -1 then
      if addIconName then
        PetUtility.SafeSetActive(itemObj, addIconName .. objIndex, true)
      end
      PetUtility.SetOriginPetSkillBg(itemObj, "Img_SkillFg")
    else
      PetUtility.SetOriginPetSkillBg(itemObj, "Img_SkillFg")
    end
  end
  return addSkillIconIndex
end
def.static("userdata", "number").SetPetSkillBgColor = function(itemObj, skillId)
  local skillLevel = PetUtility.GetPetSkillLevel(skillId)
  local skillColor = 0
  if skillLevel == 0 then
    local MountsUtils = require("Main.Mounts.MountsUtils")
    local passiveSkillCfg = MountsUtils.GetMountsPassiveSkillCfgBySkillId(skillId)
    local GUIUtils = require("GUI.GUIUtils")
    if passiveSkillCfg ~= nil then
      GUIUtils.SetItemCellSprite(itemObj, MountsUtils.GetMountsSkillColor(passiveSkillCfg.passiveSkillIconColor))
    else
      local ItemColor = require("consts.mzm.gsp.item.confbean.Color")
      GUIUtils.SetItemCellSprite(itemObj, ItemColor.WHITE)
    end
    return
  else
    skillColor = PetUtility.GetPetSkillColor(skillLevel)
  end
  local spriteName = string.format("Cell_%02d", skillColor)
  itemObj:GetComponent("UISprite"):set_spriteName(spriteName)
end
def.static("userdata", "string").SetOriginPetSkillBg = function(itemObj, spriteName)
  if itemObj and not itemObj.isnil then
    local uiSprite = itemObj:GetComponent("UISprite")
    if uiSprite and spriteName then
      uiSprite:set_spriteName(spriteName)
    end
  end
end
local enableTween = false
def.static("userdata", "number", "number", "number", "varlist").SetYaoLiUI = function(obj, yaoliLevelId, yaoli, score, isTweening)
  enableTween = false
  local GUIUtils = require("GUI.GUIUtils")
  local Label_PowerLv = GUIUtils.FindDirect(obj, "Label_PowerLv")
  local Label_PowerNum = GUIUtils.FindDirect(obj, "Label_PowerNum")
  if not isTweening then
    GUIUtils.SetActive(obj:FindDirect("Group_AttributeChange"), false)
    GUIUtils.SetActive(obj:FindDirect("Btn_Promote"), true)
  end
  if yaoli < 0 then
    GUIUtils.SetText(Label_PowerLv, "")
    GUIUtils.SetText(Label_PowerNum, "")
    GUIUtils.SetActive(obj:FindDirect("Btn_Promote"), false)
    return
  end
  local cfg = PetUtility.Instance():GetPetYaoLiCfg(yaoliLevelId, score)
  local encodeChar = cfg.encodeChar
  GUIUtils.SetText(Label_PowerLv, encodeChar)
  GUIUtils.SetText(Label_PowerNum, yaoli)
end
def.static("userdata", "number", "number", "number", "number", "number").TweenYaoLiUI = function(obj, yaoliLevelId, from, to, scoreFrom, scoreTo)
  if from == to then
    return
  end
  local isTweening = true
  local duration = 1.5
  local lastyaoli = -1
  local t = 0
  local function tick(param, dt)
    if not enableTween or obj.isnil or not obj.activeInHierarchy then
      Timer:RemoveIrregularTimeListener(tick)
      return
    end
    t = t + dt
    if t > duration then
      t = duration
    end
    local rt = t / duration
    local val = rt
    if val == 1 then
      Timer:RemoveIrregularTimeListener(tick)
      isTweening = false
    end
    local yaoli = math.floor((1 - val) * from + to * val)
    local score = math.floor((1 - val) * scoreFrom + scoreTo * val)
    if lastyaoli ~= yaoli or not isTweening then
      lastyaoli = yaoli
      PetUtility.SetYaoLiUI(obj, yaoliLevelId, yaoli, score, isTweening)
      enableTween = true
    end
  end
  local GUIUtils = require("GUI.GUIUtils")
  local Group_AttributeChange = obj:FindDirect("Group_AttributeChange")
  if Group_AttributeChange then
    Group_AttributeChange:SetActive(true)
    GUIUtils.SetActive(obj:FindDirect("Btn_Promote"), false)
    local isGreen = from < to
    local isRed = not isGreen
    GUIUtils.SetActive(GUIUtils.FindDirect(Group_AttributeChange, "Img_ArrowRed"), isRed)
    local Label_Red = GUIUtils.FindDirect(Group_AttributeChange, "Label_Red")
    GUIUtils.SetActive(Label_Red, isRed)
    GUIUtils.SetActive(GUIUtils.FindDirect(Group_AttributeChange, "Img_ArrowGreen"), isGreen)
    local Label_Green = GUIUtils.FindDirect(Group_AttributeChange, "Label_Green")
    GUIUtils.SetActive(Label_Green, isGreen)
    local label = isGreen and Label_Green or Label_Red
    if isGreen then
      local text = string.format(textRes.Pet[128], to - from)
      GUIUtils.SetText(Label_Green, text)
    else
      local text = string.format(textRes.Pet[129], from - to)
      GUIUtils.SetText(Label_Red, text)
    end
  end
  PetUtility.SetYaoLiUI(obj, yaoliLevelId, from, scoreFrom, isTweening)
  enableTween = true
  Timer:RegisterIrregularTimeListener(tick, nil)
end
def.static("userdata", "table").SetYaoLiUIFromPet = function(obj, pet)
  if pet == nil then
    PetUtility.SetYaoLiUI(obj, 0, -1, -1)
    return
  end
  local petCfg = pet:GetPetCfgData()
  PetUtility.SetYaoLiUI(obj, petCfg.yaoliLevelId, pet:GetYaoLi(), pet:GetLevelScore())
end
def.static("userdata", "table", "table").TweenYaoLiUIFromPet = function(obj, pet, params)
  if pet == nil then
    PetUtility.SetYaoLiUI(obj, 0, -1, -1)
    return
  end
  local from, to, scoreFrom, scoreTo = params.from, params.to, params.scoreFrom, params.scoreTo
  local petCfg = pet:GetPetCfgData()
  PetUtility.TweenYaoLiUI(obj, petCfg.yaoliLevelId, from, to, scoreFrom, scoreTo)
end
def.static("userdata", "string", "boolean").SafeSetActive = function(root, name, state)
  local obj = root:FindDirect(name)
  if obj == nil then
    return
  end
  obj:SetActive(state)
end
def.static("table").PlayPetClickedAnimation = function(model)
  if model == nil then
    return
  end
  local animations = {
    {
      actionName = ActionName.Attack1,
      skillId = 110000000
    },
    {
      actionName = ActionName.Magic,
      skillId = 0
    }
  }
  local selectedIndex = math.random(1, #animations)
  local animation = animations[selectedIndex]
  local skillId = animation.skillId
  if skillId ~= 0 then
    _G.PlaySkillInUIModel(model, skillId)
  end
  local animationName = animation.actionName
  model:CrossFade(animationName, 0.1)
  model:CrossFadeQueued(ActionName.Stand, 0.25)
end
def.static("string", "=>", "number").GetPetShopConstants = function(key)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PET_SHOP_CONSTANTS_CFG, key)
  if record == nil then
    warn("GetPetShopConstants(" .. key .. ") return nil")
    return
  end
  local value = DynamicRecord.GetIntValue(record, "value")
  return value
end
def.static("number", "=>", "number").GetPetSkillScore = function(skillId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PET_SKILL_SCORE_CFG, skillId)
  if record == nil then
    warn("GetPetSkillScore(" .. skillId .. ") return nil")
    return 0
  end
  local value = record:GetIntValue("score")
  return value
end
def.static("number", "=>", "number").GetPetSkillLevel = function(skillId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PET_SKILL_SCORE_CFG, skillId)
  if record == nil then
    warn("GetPetSkillScore(" .. skillId .. ") return nil")
    return 0
  end
  return record:GetIntValue("skillLevel")
end
def.static("number", "=>", "number").GetPetSkillLevelEnumValue = function(skillId)
  local level = PetUtility.GetPetSkillLevel(skillId)
  if level == 0 then
    return -1
  else
    local record = DynamicData.GetRecord(CFG_PATH.DATA_PET_SKILL_QUALITY_COLOR_CFG, level)
    if record == nil then
      return -1
    end
    return record:GetIntValue("skillLevel")
  end
end
def.static("=>", "table").GetAllPetSkill = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_PET_SKILL_SCORE_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = PetUtility._GetPetSkillScoreCfg(record)
    table.insert(cfgs, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfgs
end
def.static("number", "=>", "table").GetPetSkillScoreCfg = function(skillId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PET_SKILL_SCORE_CFG, skillId)
  if record == nil then
    warn("GetPetSkillScore(" .. skillId .. ") return nil")
    return 0
  end
  return PetUtility._GetPetSkillScoreCfg(record)
end
def.static("userdata", "=>", "table")._GetPetSkillScoreCfg = function(record)
  local cfg = {}
  cfg.skillId = record:GetIntValue("skillId")
  cfg.score = record:GetIntValue("score")
  cfg.skillLevelId = record:GetIntValue("skillLevel")
  return cfg
end
def.static("number", "=>", "number").GetPetSkillColor = function(skillLevel)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PET_SKILL_QUALITY_COLOR_CFG, skillLevel)
  if record == nil then
    return 0
  end
  return record:GetIntValue("color")
end
local cfgs
def.static("=>", "table").GetPetGrowValueCfgs = function()
  if cfgs ~= nil then
    return cfgs
  end
  local entries = DynamicData.GetTable(CFG_PATH.DATA_PET_GROW_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.GetRecordByIdx(entries, i)
    local cfg = {}
    cfg.growColor = record:GetIntValue("growColor")
    cfg.minGrowRate = record:GetIntValue("maxGrowRate")
    cfg.maxGrowRate = record:GetIntValue("minGrowRate")
    if cfg.minGrowRate > cfg.maxGrowRate then
      cfg.minGrowRate, cfg.maxGrowRate = cfg.maxGrowRate, cfg.minGrowRate
    end
    table.insert(cfgs, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfgs
end
def.static("number", "=>", "table").GetPetExchangeCfg = function(petTemplateId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PET_EXCHANGE_CFG, petTemplateId)
  if record == nil then
    warn("GetPetExchangeCfg(" .. petTemplateId .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.petTemplateId = petTemplateId
  cfg.items = {}
  local itemsStruct = record:GetStructValue("itemCostListStruct")
  local size = itemsStruct:GetVectorSize("itemCostList")
  for i = 0, size - 1 do
    local vectorRow = itemsStruct:GetVectorValueByIdx("itemCostList", i)
    local row = {}
    row.itemTypeId = vectorRow:GetIntValue("itemTypeId")
    row.itemCount = vectorRow:GetIntValue("itemNum")
    table.insert(cfg.items, row)
  end
  return cfg
end
def.static("number", "=>", "table").GetPetRandomExchangeCfg = function(petType)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PET_RANDOM_EXCHANGE_CFG, petType)
  if record == nil then
    warn("GetPetRandomExchangeCfg(" .. petType .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.petType = petType
  cfg.items = {}
  local itemsStruct = record:GetStructValue("itemCostListStruct")
  local size = itemsStruct:GetVectorSize("itemCostList")
  for i = 0, size - 1 do
    local vectorRow = itemsStruct:GetVectorValueByIdx("itemCostList", i)
    local row = {}
    row.itemTypeId = vectorRow:GetIntValue("itemTypeId")
    row.itemCount = vectorRow:GetIntValue("itemNum")
    table.insert(cfg.items, row)
  end
  return cfg
end
def.static("number", "=>", "table").GetPetTypeCfg = function(petType)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PET_TYPE_CFG, petType)
  if record == nil then
    warn("GetPetTypeCfg(" .. petType .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.petType = petType
  cfg.typeName = record:GetStringValue("petTypeString")
  cfg.nameColor = record:GetIntValue("nameColor")
  cfg.typeQuality = record:GetIntValue("typeRefQuality")
  return cfg
end
def.static("number", "=>", "table").GetPetSpecialSkillCfg = function(skillId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PET_SPECIAL_SKILL_CFG, skillId)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.skillId = skillId
  cfg.canHuaSheng = record:GetCharValue("canHuaSheng") == 1
  return cfg
end
local cfgs
def.static("number", "=>", "string").GetPetSkillQualityColor = function(skillId)
  local score = PetUtility.GetPetSkillScore(skillId)
  if cfgs == nil then
    cfgs = PetUtility.GetAllPetSkillColorCfgs()
  end
  local NameColor = require("Main.Chat.HtmlHelper").NameColor
  local maxColorEnum = #NameColor
  local colorEnum = maxColorEnum
  for i, cfg in ipairs(cfgs) do
    if score <= cfg.score then
      colorEnum = cfg.color
      break
    end
  end
  colorEnum = math.min(colorEnum, maxColorEnum)
  return NameColor[colorEnum]
end
def.static("=>", "table").GetAllPetSkillColorCfgs = function()
  local cfgs = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_PET_SKILL_QUALITY_COLOR_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = PetUtility._GetPetSkillColorCfg(record)
    table.insert(cfgs, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  table.sort(cfgs, function(left, right)
    return left.score < right.score
  end)
  return cfgs
end
def.static("userdata", "=>", "table")._GetPetSkillColorCfg = function(record)
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.score = record:GetIntValue("score")
  cfg.color = record:GetIntValue("color")
  cfg.skillLevel = record:GetIntValue("skillLevel")
  return cfg
end
def.static("number", "number", "number", "=>", "string").GetPetGrowValueColor = function(value, min, max)
  local growValueCfgs = PetUtility.GetPetGrowValueCfgs()
  local rate = require("Common.MathHelper").Floor((value - min) / (max - min) * 10000)
  if rate < 0 then
    rate = 0
  end
  for i, cfg in ipairs(growValueCfgs) do
    if rate >= cfg.minGrowRate and rate <= cfg.maxGrowRate then
      return textRes.Pet.GrowValueColor[cfg.growColor]
    end
  end
  return textRes.Pet.GrowValueColor[#textRes.Pet.GrowValueColor]
end
def.static("number", "number", "number", "=>", "string").GetPetGrowValueMeaning = function(value, min, max)
  local growValueCfgs = PetUtility.GetPetGrowValueCfgs()
  local rate = require("Common.MathHelper").Floor((value - min) / (max - min) * 10000)
  if rate < 0 then
    rate = 0
  end
  for i, cfg in ipairs(growValueCfgs) do
    if rate >= cfg.minGrowRate and rate <= cfg.maxGrowRate then
      return textRes.Pet.GrowValueMeaning[cfg.growColor]
    end
  end
  return textRes.Pet.GrowValueMeaning[#textRes.Pet.GrowValueMeaning]
end
def.static(PetData, "=>", "table").GetPetGrowValueViewData = function(pet)
  local petCfg = pet:GetPetCfgData()
  local color = PetUtility.GetPetGrowValueColor(pet.growValue, petCfg.growMinValue, petCfg.growMaxValue)
  local value = string.format("%.3f", pet.growValue)
  local meaning = PetUtility.GetPetGrowValueMeaning(pet.growValue, petCfg.growMinValue, petCfg.growMaxValue)
  return {
    color = color,
    value = value,
    meaning = meaning
  }
end
def.static(PetData, "=>", "number").CalcPetYaoLi = function(petData)
  local petCfg = petData:GetPetCfgData()
  local qualitySum = petData.petQuality:GetQualitySum()
  local growValue = petData.growValue
  local qualityStageRate = petCfg.qualityStageRate
  local growStageRate = petCfg.growStageRate
  local total = qualitySum * qualityStageRate + growValue * growStageRate
  local skillScores = 0
  local skillIdList = petData:GetConcatSkillIdList()
  for i, skillId in ipairs(skillIdList) do
    skillScores = skillScores + PetUtility.GetPetSkillScore(skillId)
  end
  total = total * (1 + skillScores / 10000)
  if petData.soulProp then
    total = total + petData.soulProp:GetScore()
  end
  if petData:GetPetMarkCfgId() ~= 0 then
    local markLevelCfg = require("Main.Pet.PetMark.PetMarkUtils").GetPetMarkLevelCfg(petData:GetPetMarkCfgId())
    local levelCfg = markLevelCfg.levelCfg[petData:GetPetMarkLevel()]
    if levelCfg ~= nil then
      total = total + levelCfg.addYaoli
    end
  end
  return require("Common.MathHelper").Floor(total, 0.001)
end
def.static("number", "=>", "string").GetPetTypeSpriteName = function(petType)
  return string.format("Img_Pet%d", petType + 1)
end
def.static("number", "=>", "string").GetPetTypeColor = function(petType)
  local PetType = require("consts.mzm.gsp.pet.confbean.PetType")
  local colorMap = {
    [PetType.WILD] = "00ff00",
    [PetType.BAOBAO] = "66ffcc",
    [PetType.BIANYI] = "ff00ff",
    [PetType.MOSHOU] = "ff9229",
    [PetType.SHENSHOU] = "ff7474"
  }
  return colorMap[petType] or colorMap[PetType.SHENSHOU]
end
def.static(PetData, "=>", "string").GetColoredPetNameHtml = function(pet)
  local petCfg = pet:GetPetCfgData()
  local color = PetUtility.GetPetTypeColor(petCfg.type)
  local coloredPetName = string.format("<font color=#%s>%s</font>", color, pet.name)
  return coloredPetName
end
def.static(PetData, "=>", "string").GetColoredPetNameBBCode = function(pet)
  local petCfg = pet:GetPetCfgData()
  local color = PetUtility.GetPetTypeColor(petCfg.type)
  local coloredPetName = string.format("[%s]%s[-]", color, pet.name)
  return coloredPetName
end
def.static("number", "=>", "string").GetColoredSkillNameHtml = function(skillId)
  local skillCfg = PetUtility.Instance():GetPetSkillCfg(skillId)
  if skillCfg == nil then
    return ""
  end
  local skillName = skillCfg.name
  local color = PetUtility.GetPetSkillQualityColor(skillId)
  return string.format("<font color=#%s>%s</font>", color, skillName)
end
def.static("number", "=>", "string").GetColoredSkillNameBBCode = function(skillId)
  local skillCfg = PetUtility.Instance():GetPetSkillCfg(skillId)
  if skillCfg == nil then
    return ""
  end
  local skillName = skillCfg.name
  local color = PetUtility.GetPetSkillQualityColor(skillId)
  return string.format("[%s]%s[-]", color, skillName)
end
def.static("number").ShowGetPetInfo = function(petTemplateId)
  local petCfg = PetUtility.Instance():GetPetCfg(petTemplateId)
  local color = PetUtility.GetPetTypeColor(petCfg.type)
  local petName = petCfg.templateName
  local PersonalHelper = require("Main.Chat.PersonalHelper")
  PersonalHelper.GetPet(petName, color)
end
def.static(PetData, "userdata", "function", "=>", "table").CreateAndAttachPetUIModel = function(pet, uiModel, cb)
  local PetUIModel = require("Main.Pet.PetUIModel")
  local model = PetUIModel.new(pet.typeId, uiModel)
  model:LoadDefault(cb)
  model:SetOrnament(pet.isDecorated)
  model:SetCanExceedBound(true)
  local isPetMarkOpen = require("Main.Pet.PetMark.PetMarkMgr").Instance():IsFeatureOpen()
  if isPetMarkOpen then
    model:SetPetMark(pet:GetPetDisplayMarkModelId())
  end
  return model
end
def.static("number", "number", "number", "=>", "number").GetPetQualityProgress = function(value, min, max)
  local k = PetUtility.Instance():GetPetConstants("PET_APT_SHOW_RATE") or 8000
  k = k / 10000
  return (value - min * k) / (max - min * k)
end
def.static().OpenPetBianqingDlg = function()
  require("GUI.ECGUIMan").Instance():DestroyUIAtLevel(1)
  local StrongerType = require("consts.mzm.gsp.grow.confbean.StrongerType")
  require("Main.Grow.GrowUIMgr").OpenBianqiangPanel(StrongerType.PET_GROW)
end
def.static("table", "number", "=>", "string").GetHeadIconBGSpriteName = function(petCfg, score)
  local cfg = PetUtility.Instance():GetPetYaoLiCfg(petCfg.yaoliLevelId, score)
  return cfg.iconBgSpriteName
end
def.static("number", "=>", "table").GetTargetPetsCfg = function(targetType)
  local PubroleInterface = require("Main.Pubrole.PubroleInterface")
  local targetCfg = {}
  local entrys = DynamicData.GetTable(CFG_PATH.DATA_PET_CFG)
  local count = DynamicDataTable.GetRecordsCount(entrys)
  DynamicDataTable.FastGetRecordBegin(entrys)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entrys, i)
    local pType = record:GetIntValue("type")
    if pType == targetType then
      local cfg = {}
      cfg.id = record:GetIntValue("templateId")
      cfg.name = record:GetStringValue("templateName")
      local modelId = record:GetIntValue("modelId")
      local IconId = PubroleInterface.GetModelCfg(modelId).headerIconId
      cfg.icon = IconId
      table.insert(targetCfg, cfg)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entrys)
  return targetCfg
end
def.static("number", "=>", "table").GetShenShoePetsByType = function(targetType)
  local petsCfg = {}
  local entrys = DynamicData.GetTable(CFG_PATH.DATA_PET_EXCHANGE_CFG)
  local count = DynamicDataTable.GetRecordsCount(entrys)
  DynamicDataTable.FastGetRecordBegin(entrys)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entrys, i)
    if record then
      local petId = record:GetIntValue("petId")
      table.insert(petsCfg, petId)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entrys)
  local PubroleInterface = require("Main.Pubrole.PubroleInterface")
  local targetPets = {}
  for i = 1, count do
    local record = DynamicData.GetRecord(CFG_PATH.DATA_PET_CFG, petsCfg[i])
    if record then
      local pType = record:GetIntValue("type")
      if pType == targetType then
        local cfg = {}
        cfg.id = record:GetIntValue("templateId")
        cfg.name = record:GetStringValue("templateName")
        local modelId = record:GetIntValue("modelId")
        local IconId = PubroleInterface.GetModelCfg(modelId).headerIconId
        cfg.icon = IconId
        table.insert(targetPets, cfg)
      end
    end
  end
  return targetPets
end
def.static("number", "number", "=>", "boolean").IsRarityPet = function(petId, score)
  local TradingArcadeUtils = require("Main.TradingArcade.TradingArcadeUtils")
  local marketPetCfg = TradingArcadeUtils.GetMarketPetCfg(petId)
  if marketPetCfg == nil then
    return false
  end
  return score >= marketPetCfg.minPoint
end
def.static("number", "=>", "number").GetPetHSItemPrice = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_COMMERCE_ITEM_CFG, itemId)
  if nil == record then
    return 0
  end
  local price = record:GetIntValue("orginialPrice")
  local realPrice = price / 100
  return realPrice
end
def.static("number", "=>", "number").GetPetFSItemPrice = function(itemId)
  local mallType = require("consts.mzm.gsp.mall.confbean.MallType")
  local mallUitls = require("Main.Mall.MallUtility")
  local key = string.format("%d_%d", itemId, mallType.FUNCTION_MALL)
  return mallUitls.GetItemPrice(key)
end
def.static("number", "=>", "table").GetPetReplaceSkillCondition = function(petCfgId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PET_REPLACE_SKILL_CFG, petCfgId)
  if nil == record then
    warn("\232\175\165\229\174\160\231\137\169\228\184\141\232\131\189\229\134\141\231\148\159:" .. petCfgId)
    return nil
  end
  local condition = {}
  condition.petCfgId = record:GetIntValue("petCfgId")
  condition.itemId = record:GetIntValue("itemId")
  condition.itemNum = record:GetIntValue("itemNum")
  return condition
end
def.static("number", "=>", "table").GetPetHuiZhiCostCfgByPetType = function(petType)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PET_HUIZHI_COST_CFG, petType)
  if record == nil then
    warn("GetPetHuiZhiCostCfgByPetType(" .. petType .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.petType = petType
  cfg.costType = record:GetIntValue("costType")
  cfg.priceItemId = record:GetIntValue("priceItemId")
  cfg.costNum = record:GetIntValue("costNum")
  return cfg
end
def.static("number", "=>", "boolean").IsPetCfgId = function(id)
  local PET_CFG_ID_PREFIX = 1301
  if math.floor(id / 100000) == PET_CFG_ID_PREFIX then
    return true
  end
  return false
end
def.static("userdata").AddBoxCollider = function(obj)
  local boxCollider = obj:GetComponent("BoxCollider")
  if boxCollider == nil then
    boxCollider = obj:AddComponent("BoxCollider")
    local uiWidget = obj:GetComponent("UIWidget")
    if uiWidget ~= nil then
      uiWidget.autoResizeBoxCollider = true
      uiWidget:ResizeCollider()
    end
  end
end
def.static("table").ShowPetStageLevelTips = function(petData)
  if petData == nil then
    return
  end
  PetUtility.ShowPetDetailStageLevel(petData.stageLevel)
end
def.static("number").ShowPetDetailStageLevel = function(stageLevel)
  Toast(string.format(textRes.Pet[186], stageLevel))
end
def.static("number", "=>", "table").GetFakePetCfgById = function(cfgId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_FAKE_PET_CFG, cfgId)
  if record == nil then
    warn("GetFakePetCfgById(" .. cfgId .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.vicePetName = record:GetStringValue("vicePetName")
  cfg.vicePetAvatarFrameColorId = record:GetIntValue("vicePetAvatarFrameColorId")
  cfg.vicePetAvatarIconId = record:GetIntValue("vicePetAvatarIconId")
  cfg.vicePetMinRoleLevel = record:GetIntValue("vicePetMinRoleLevel")
  return cfg
end
PetUtility.Commit()
return PetUtility
