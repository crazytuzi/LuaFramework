local Lplus = require("Lplus")
local PartnerInterface = Lplus.Class("PartnerInterface")
local def = PartnerInterface.define
local instance
local SkillUtils = require("Main.Skill.SkillUtility")
def.static("=>", PartnerInterface).Instance = function()
  if instance == nil then
    instance = PartnerInterface()
    instance:Init()
  end
  return instance
end
def.field("table")._partnerCfgsList = nil
def.field("table")._partnerInfos = nil
def.field("table")._partnerRankInfo = nil
def.method().Init = function(self)
  self:Reset()
  self:initPartnerRankInfo()
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, PartnerInterface.OnHeroLevelUp)
end
def.method().Reset = function(self)
  self._partnerCfgsList = {}
  self._partnerInfos = {}
  self._partnerInfos.ownPartners = {}
  self._partnerInfos.lineUps = {}
  for idx = 0, 2 do
    local lineup = {}
    lineup.positions = {
      0,
      0,
      0,
      0
    }
    lineup.zhenFaId = 0
    self._partnerInfos.lineUps[idx] = lineup
  end
  self._partnerInfos.partner2Property = {}
  self._partnerInfos.defaultLineUpNum = 0
  self._partnerInfos.partner2Skills = {}
end
def.method("number", "=>", "table").GetPartnerCfgById = function(self, partnerId)
  local allcfg = self:GetPartnerCfgsList()
  if not allcfg then
    return nil
  end
  for k, v in pairs(allcfg) do
    if v.id == partnerId then
      return v
    end
  end
  return nil
end
def.method("=>", "table").GetPartnerCfgsList = function(self)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp ~= nil and (self._partnerCfgsList == nil or #self._partnerCfgsList == 0) then
    self:_LoadPartnerCfgs()
  end
  return self._partnerCfgsList
end
local _cfg_cache = {}
def.method()._LoadPartnerCfgs = function(self)
  self._partnerCfgsList = {}
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_PARTNER_PARTNER_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local lastUnlockLevel = 0
  local UnlockLevel = 0
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    while true do
      local cfg = _cfg_cache[i]
      if cfg then
        UnlockLevel = cfg.unlockLevel
        if lastUnlockLevel ~= 0 and lastUnlockLevel < UnlockLevel then
          break
        end
      else
        local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
        cfg = {}
        cfg.unlockLevel = DynamicRecord.GetIntValue(entry, "unlockLevel")
        UnlockLevel = cfg.unlockLevel
        if lastUnlockLevel ~= 0 and lastUnlockLevel < UnlockLevel then
          break
        end
        cfg.id = DynamicRecord.GetIntValue(entry, "id")
        cfg.name = DynamicRecord.GetStringValue(entry, "name")
        cfg.faction = DynamicRecord.GetIntValue(entry, "faction")
        cfg.sex = DynamicRecord.GetIntValue(entry, "sex")
        cfg.partnerType = DynamicRecord.GetIntValue(entry, "partnerType")
        cfg.classType = DynamicRecord.GetIntValue(entry, "classType")
        cfg.classLevel = DynamicRecord.GetIntValue(entry, "classLevel")
        cfg.unlockItem = DynamicRecord.GetIntValue(entry, "unlockItem")
        cfg.unlockItemId = DynamicRecord.GetIntValue(entry, "unlockItemId")
        cfg.unlockItemNum = DynamicRecord.GetIntValue(entry, "unlockItemNum")
        cfg.modelId = DynamicRecord.GetIntValue(entry, "modelId")
        cfg.unlockItemId = DynamicRecord.GetIntValue(entry, "unlockItemId")
        cfg.rank = DynamicRecord.GetStringValue(entry, "rank")
        cfg.bornStr = DynamicRecord.GetIntValue(entry, "bornStr")
        cfg.bornDex = DynamicRecord.GetIntValue(entry, "bornDex")
        cfg.bornSpr = DynamicRecord.GetIntValue(entry, "bornSpr")
        cfg.bornCon = DynamicRecord.GetIntValue(entry, "bornCon")
        cfg.bornSta = DynamicRecord.GetIntValue(entry, "bornSta")
        cfg.addStrPerLevel = DynamicRecord.GetFloatValue(entry, "addStrPerLevel")
        cfg.addDexPerLevel = DynamicRecord.GetFloatValue(entry, "addDexPerLevel")
        cfg.addSprPerLevel = DynamicRecord.GetFloatValue(entry, "addSprPerLevel")
        cfg.addConPerLevel = DynamicRecord.GetFloatValue(entry, "addConPerLevel")
        cfg.addStaPerLevel = DynamicRecord.GetFloatValue(entry, "addStaPerLevel")
        cfg.bornMaxHP = DynamicRecord.GetFloatValue(entry, "bornMaxHP")
        cfg.bornMaxMp = DynamicRecord.GetFloatValue(entry, "bornMaxMp")
        cfg.bornPhyAtk = DynamicRecord.GetFloatValue(entry, "bornPhyAtk")
        cfg.bornPhyDef = DynamicRecord.GetFloatValue(entry, "bornPhyDef")
        cfg.bornMagAtk = DynamicRecord.GetFloatValue(entry, "bornMagAtk")
        cfg.bornMagDef = DynamicRecord.GetFloatValue(entry, "bornMagDef")
        cfg.bornSealHitLevel = DynamicRecord.GetFloatValue(entry, "bornSealHitLevel")
        cfg.bornSealResLevel = DynamicRecord.GetFloatValue(entry, "bornSealResLevel")
        cfg.bornPhyHitLevel = DynamicRecord.GetFloatValue(entry, "bornPhyHitLevel")
        cfg.bornPhyDodgeLevel = DynamicRecord.GetFloatValue(entry, "bornPhyDodgeLevel")
        cfg.bornMagHitLevel = DynamicRecord.GetFloatValue(entry, "bornMagHitLevel")
        cfg.bornMagDodogeLevel = DynamicRecord.GetFloatValue(entry, "bornMagDodogeLevel")
        cfg.bornPhyCrtRate = DynamicRecord.GetIntValue(entry, "bornPhyCrtRate")
        cfg.bornMagCrtRate = DynamicRecord.GetIntValue(entry, "bornMagCrtRate")
        cfg.bornPhyCrtValue = DynamicRecord.GetIntValue(entry, "bornPhyCrtValue")
        cfg.phyCrtLevel = DynamicRecord.GetIntValue(entry, "phyCrtLevel")
        cfg.bornMagCrtValue = DynamicRecord.GetIntValue(entry, "bornMagCrtValue")
        cfg.magCrtLevel = DynamicRecord.GetIntValue(entry, "magCrtLevel")
        cfg.bornSpeed = DynamicRecord.GetFloatValue(entry, "bornSpeed")
        cfg.level2propertyId = DynamicRecord.GetIntValue(entry, "level2propertyId")
        cfg.partnerAI = DynamicRecord.GetStringValue(entry, "partnerAI")
        cfg.Love2Friend = DynamicRecord.GetIntValue(entry, "Love2Friend")
        cfg.Love2Enemy = DynamicRecord.GetIntValue(entry, "Love2Enemy")
        cfg.yuanCfgId = DynamicRecord.GetIntValue(entry, "yuanCfgId")
        cfg.rankId = DynamicRecord.GetIntValue(entry, "rankId")
        cfg.skillIds = {}
        local rec2 = entry:GetStructValue("skillsStruct")
        local count = rec2:GetVectorSize("skillsList")
        for i = 1, count do
          local rec3 = rec2:GetVectorValueByIdx("skillsList", i - 1)
          local skillId = rec3:GetIntValue("skillId")
          if skillId ~= 0 then
            table.insert(cfg.skillIds, skillId)
          end
        end
        _cfg_cache[i] = cfg
      end
      table.insert(self._partnerCfgsList, cfg)
      break
    end
    if lastUnlockLevel == 0 and UnlockLevel > heroProp.level then
      lastUnlockLevel = UnlockLevel
    end
    if lastUnlockLevel ~= 0 and UnlockLevel > lastUnlockLevel then
      break
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  Event.DispatchEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_RefreshList, nil)
end
def.method().SortPartnerList = function(self)
  local function sortFn(l, r)
    local hasl = self:HasThePartner(l.id)
    local hasr = self:HasThePartner(r.id)
    if hasl == hasr then
      return l.unlockLevel < r.unlockLevel
    end
    return hasl
  end
  table.sort(self._partnerCfgsList, sortFn)
end
def.static("number", "=>", "table").GetPartnerSkillCfg = function(partnerSkillID)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PARTNER_PARTNER_SKILL_CFG, partnerSkillID)
  if record == nil then
    print("** ************* PartnerInterface.GetPartnerSkillCfg", partnerSkillID, "record == nil")
    return nil
  end
  local cfg = {}
  cfg.id = partnerSkillID
  cfg.needPartnerLevel = record:GetIntValue("needPartnerLevel")
  cfg.needPartnerXiuLianLevel = record:GetIntValue("needPartnerXiuLianLevel")
  cfg.needPartnerXiuLianLevelCount = record:GetIntValue("needPartnerXiuLianLevelCount")
  cfg.unLockYuanLevel = record:GetIntValue("unLockYuanLevel")
  cfg.improveYuanLevel = record:GetIntValue("improveYuanLevel")
  cfg.upLimit = record:GetIntValue("upLimit")
  local skillID = record:GetIntValue("skillId")
  if SkillUtils.IsPassiveSkill(skillID) == true then
    cfg.skillCfg = SkillUtils.GetPassiveSkillCfg(skillID)
  elseif SkillUtils.IsEnchantingSkill(skillID) == true then
    cfg.skillCfg = SkillUtils.GetEnchantingSkillCfg(skillID)
  else
    cfg.skillCfg = SkillUtils.GetSkillCfg(skillID)
  end
  return cfg
end
def.method("table")._SetPartnerInfos = function(self, partnerInfos)
  self._partnerInfos = partnerInfos
end
def.method("=>", "table").GetPartnerInfos = function(self)
  return self._partnerInfos
end
def.method("number", "table")._AddOwnPartner = function(self, partnerID, property)
  self._partnerInfos.ownPartners[partnerID] = partnerID
  self._partnerInfos.partner2Property[partnerID] = property
end
def.method("number", "=>", "boolean").HasThePartner = function(self, partnerID)
  return self._partnerInfos.ownPartners[partnerID] ~= nil
end
def.method("number", "table")._SetLineup = function(self, index, lineUp)
  self._partnerInfos.lineUps[index] = lineUp
end
def.method("number", "number")._SetLineupZhanfaID = function(self, index, ZhanfaID)
  self._partnerInfos.lineUps[index].zhenFaId = ZhanfaID
end
def.method("number", "=>", "table").GetLineup = function(self, index)
  local ret = self._partnerInfos.lineUps[index]
  return ret
end
def.method("number", "number", "=>", "number").GetLineupPosById = function(self, zhenFaId, id)
  for i, v in pairs(self._partnerInfos.lineUps[zhenFaId].positions) do
    if v == id then
      return i
    end
  end
  return -1
end
def.method("number")._SetDefaultLineUpNum = function(self, index)
  self._partnerInfos.defaultLineUpNum = index
end
def.method("=>", "number").GetDefaultLineUpNum = function(self)
  return self._partnerInfos.defaultLineUpNum
end
def.method("number", "table")._SetPartnerProperty = function(self, partnerID, property)
  self._partnerInfos.partner2Property[partnerID] = property
end
def.method("number", "=>", "table").GetPartnerProperty = function(self, partnerID)
  local property = self._partnerInfos.partner2Property[partnerID]
  property = self:AttachPropertyToPartner(partnerID, property)
  return property
end
def.method("number", "table")._SetReadyLovesToReplace = function(self, partnerID, lovesToReplace)
  local property = self._partnerInfos.partner2Property[partnerID]
  if property == nil then
    property = require("netio.protocol.mzm.gsp.partner.Property").new()
    self._partnerInfos.partner2Property[partnerID] = property
  end
  property.lovesToReplace = lovesToReplace
end
def.method("number", "=>", "table").GetReadyLovesToReplace = function(self, partnerID)
  local property = self._partnerInfos.partner2Property[partnerID]
  if property == nil then
    return nil
  end
  return property.lovesToReplace
end
def.method("number", "table")._SetPartnerLoveInfos = function(self, partnerID, LovesData)
  local property = self._partnerInfos.partner2Property[partnerID]
  if property == nil then
    property = require("netio.protocol.mzm.gsp.partner.Property").new()
    self._partnerInfos.partner2Property[partnerID] = property
  end
  property.loves = LovesData
end
def.method("number", "=>", "table").GetPartnerLoveInfos = function(self, partnerID)
  local property = self._partnerInfos.partner2Property[partnerID]
  if property == nil then
    return nil
  end
  return property.loves
end
def.method("number", "=>", "boolean").IsPartnerJoinedBattle = function(self, partnerID)
  local defaultLineUpNum = self._partnerInfos.defaultLineUpNum
  return self:IsPartnerInLineup(partnerID, defaultLineUpNum)
end
def.method("number", "number", "=>", "boolean").IsPartnerInLineup = function(self, partnerID, LineUpNum)
  if partnerID <= 0 then
    return false
  end
  local lineup = self._partnerInfos.lineUps[LineUpNum]
  if lineup ~= nil and lineup.positions then
    for k, v in pairs(lineup.positions) do
      if v == partnerID then
        return true
      end
    end
  end
  return false
end
def.static("table", "table").OnHeroLevelUp = function(param1, param2)
  instance:_LoadPartnerCfgs()
end
def.static("table", "table").OnHeroPropInit = function(param1, param2)
  instance:_LoadPartnerCfgs()
end
def.static("number", "=>", "table").GetPartnerCfg = function(partnerID)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PARTNER_PARTNER_CFG, partnerID)
  if record == nil then
    print("** ************* PartnerInterface.GetPartnerCfg", partnerID, "record == nil")
    return nil
  end
  local cfg = {}
  cfg.id = partnerID
  cfg.name = record:GetStringValue("name")
  cfg.faction = record:GetIntValue("faction")
  cfg.sex = record:GetIntValue("sex")
  cfg.partnerType = record:GetIntValue("partnerType")
  cfg.unlockItem = record:GetIntValue("unlockItem")
  cfg.unlockItemNum = record:GetIntValue("unlockItemNum")
  cfg.unlockLevel = record:GetIntValue("unlockLevel")
  cfg.modelId = record:GetIntValue("modelId")
  cfg.LoveId = record:GetIntValue("LoveId")
  cfg.bornStr = record:GetIntValue("bornStr")
  cfg.bornDex = record:GetIntValue("bornDex")
  cfg.bornSpr = record:GetIntValue("bornSpr")
  cfg.bornCon = record:GetIntValue("bornCon")
  cfg.bornSta = record:GetIntValue("bornSta")
  cfg.addStrPerLevel = record:GetFloatValue("addStrPerLevel")
  cfg.addDexPerLevel = record:GetFloatValue("addDexPerLevel")
  cfg.addSprPerLevel = record:GetFloatValue("addSprPerLevel")
  cfg.addConPerLevel = record:GetFloatValue("addConPerLevel")
  cfg.addStaPerLevel = record:GetFloatValue("addStaPerLevel")
  cfg.bornMaxHP = record:GetFloatValue("bornMaxHP")
  cfg.bornMaxMp = record:GetFloatValue("bornMaxMp")
  cfg.bornPhyAtk = record:GetFloatValue("bornPhyAtk")
  cfg.bornPhyDef = record:GetFloatValue("bornPhyDef")
  cfg.bornMagAtk = record:GetFloatValue("bornMagAtk")
  cfg.bornMagDef = record:GetFloatValue("bornMagDef")
  cfg.bornSealHitLevel = record:GetFloatValue("bornSealHitLevel")
  cfg.bornSealResLevel = record:GetFloatValue("bornSealResLevel")
  cfg.bornPhyHitLevel = record:GetFloatValue("bornPhyHitLevel")
  cfg.bornPhyDodgeLevel = record:GetFloatValue("bornPhyDodgeLevel")
  cfg.bornMagHitLevel = record:GetFloatValue("bornMagHitLevel")
  cfg.bornMagDodogeLevel = record:GetFloatValue("bornMagDodogeLevel")
  cfg.bornPhyCrtRate = record:GetIntValue("bornPhyCrtRate")
  cfg.bornMagCrtRate = record:GetIntValue("bornMagCrtRate")
  cfg.bornPhyCrtValue = record:GetIntValue("bornPhyCrtValue")
  cfg.bornMagCrtValue = record:GetIntValue("bornMagCrtValue")
  cfg.magCrtLevel = record:GetIntValue("magCrtLevel")
  cfg.bornSpeed = record:GetFloatValue("bornSpeed")
  cfg.level2propertyId = record:GetIntValue("level2propertyId")
  cfg.partnerAI = record:GetStringValue("partnerAI")
  cfg.Love2Friend = record:GetIntValue("Love2Friend")
  cfg.Love2Enemy = record:GetIntValue("Love2Enemy")
  cfg.yuanCfgId = record:GetIntValue("yuanCfgId")
  cfg.rankId = record:GetIntValue("rankId")
  cfg.skillIds = {}
  local rec2 = record:GetStructValue("skillsStruct")
  local count = rec2:GetVectorSize("skillsList")
  for i = 1, count do
    local rec3 = rec2:GetVectorValueByIdx("skillsList", i - 1)
    local skillId = rec3:GetIntValue("skillId")
    if skillId ~= 0 then
      table.insert(cfg.skillIds, skillId)
    end
  end
  return cfg
end
def.static("number", "number", "=>", "table").GetLevelToPropertyCfg = function(level2propertyId, level)
  local id = level2propertyId * 1000 + level
  local record = DynamicData.GetRecord(CFG_PATH.DATA_LEVEL_TO_PROPERTY_Cfg, id)
  if record == nil then
    warn("** ************* PartnerInterface.GetLevelToPropertyCfg", id, "record == nil")
    return nil
  end
  local cfg = {}
  cfg.level = record:GetIntValue("level")
  cfg.level2propertyId = record:GetIntValue("level2propertyId")
  cfg.addMaxHpPerLevel = record:GetFloatValue("addMaxHpPerLevel")
  cfg.addMaxMpPerLevel = record:GetFloatValue("addMaxMpPerLevel")
  cfg.addPhyAtkPerLevel = record:GetFloatValue("addPhyAtkPerLevel")
  cfg.addPhyDefPerLevel = record:GetFloatValue("addPhyDefPerLevel")
  cfg.addMagAtkPerLevel = record:GetFloatValue("addMagAtkPerLevel")
  cfg.addMagDefPerLevel = record:GetFloatValue("addMagDefPerLevel")
  cfg.addSealHitLevelPerLevel = record:GetFloatValue("addSealHitLevelPerLevel")
  cfg.addSealResLevelPerLevel = record:GetFloatValue("addSealResLevelPerLevel")
  cfg.addPhyHitLevelPerLevel = record:GetFloatValue("addPhyHitLevelPerLevel")
  cfg.addPhyDodgeLevelPerLevel = record:GetFloatValue("addPhyDodgeLevelPerLevel")
  cfg.addMagHitLevelPerLevel = record:GetFloatValue("addMagHitLevelPerLevel")
  cfg.addMagDodgeLevelPerLevel = record:GetFloatValue("addMagDodgeLevelPerLevel")
  cfg.addPhyCrtRatePerLevel = record:GetFloatValue("addPhyCrtRatePerLevel")
  cfg.addMagCrtRatePerLevel = record:GetFloatValue("addMagCrtRatePerLevel")
  cfg.addPhyCrtValuePerLevel = record:GetFloatValue("addPhyCrtValuePerLevel")
  cfg.addMagCrtValuePerLevel = record:GetFloatValue("addMagCrtValuePerLevel")
  cfg.addSpeedPerLevelPerLevel = record:GetFloatValue("addSpeedPerLevelPerLevel")
  cfg.addPhyCrtLevelPerLevel = record:GetFloatValue("addPhyCrtLevelPerLevel")
  cfg.addMagCrtLevelPerLevel = record:GetFloatValue("addMagCrtLevelPerLevel")
  cfg.addPhyCrtLevelDefPerLevel = record:GetFloatValue("addPhyCrtLevelDefPerLevel")
  cfg.addMagCrtLevelDefPerLevel = record:GetFloatValue("addMagCrtLevelDefPerLevel")
  return cfg
end
def.static("number", "=>", "table").CPartner2PropertyChange = function(ID)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PARTNER_PARTNER2PROPERTYCHANGE_CFG, ID)
  if record == nil then
    print("** ************* PartnerInterface.CPartner2PropertyChange", ID, "record == nil")
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.LV1Property = record:GetIntValue("LV1Property")
  cfg.LV2Property = record:GetIntValue("LV2Property")
  cfg.effectValue = record:GetFloatValue("effectValue")
  return cfg
end
def.static("number", "=>", "table").GetPartnerLoveCfg = function(ID)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PARTNER_PARTNER_LOVE_CFG, ID)
  if record == nil then
    print("** ************* PartnerInterface.GetPartnerLoveCfg ", ID, " record == nil")
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.LoveId2Rate = {}
  local rec2 = record:GetStructValue("LoveId2RateListStruct")
  local count = rec2:GetVectorSize("loveId2Rate")
  for i = 1, count do
    local rec3 = rec2:GetVectorValueByIdx("loveId2Rate", i - 1)
    local t = {}
    t.loveId = rec3:GetIntValue("loveId")
    t.loveRate = rec3:GetIntValue("loveRate")
    if t.loveId ~= 0 then
      table.insert(cfg.LoveId2Rate, t)
    end
  end
  return cfg
end
def.static("number", "=>", "table").GetPartnerLoveDataCfg = function(ID)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PARTNER_PARTNER_LOVE_DATA_CFG, ID)
  if record == nil then
    warn("** ************* PartnerInterface.CPartnerLoveDataCfg", ID, "record == nil")
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.toPartner1 = record:GetIntValue("toPartner1")
  cfg.toPartner2 = record:GetIntValue("toPartner2")
  cfg.toPartner3 = record:GetIntValue("toPartner3")
  cfg.loveIconId = record:GetIntValue("loveIconId")
  cfg.loveRank = record:GetIntValue("loveRank")
  cfg.loveDes = record:GetStringValue("loveDes")
  cfg.loveName = record:GetStringValue("loveName")
  cfg.loveType = record:GetStringValue("loveType")
  return cfg
end
def.static("number", "=>", "table").GetPartnerLoveDataCfgsForPartner = function(partnerID)
  local ret = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_PARTNER_PARTNER_LOVE_DATA_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = {}
    cfg.id = entry:GetIntValue("id")
    cfg.toPartner1 = entry:GetIntValue("toPartner1")
    cfg.toPartner2 = entry:GetIntValue("toPartner2")
    cfg.toPartner3 = entry:GetIntValue("toPartner3")
    cfg.loveRank = entry:GetIntValue("loveRank")
    cfg.loveDes = entry:GetStringValue("loveDes")
    cfg.loveName = entry:GetStringValue("loveName")
    cfg.loveType = entry:GetStringValue("loveType")
    print("**    cfg.toPartner1 ,cfg.toPartner2,cfg.toPartner3,partnerID", cfg.toPartner1, cfg.toPartner2, cfg.toPartner3, partnerID)
    if cfg.toPartner1 == partnerID or cfg.toPartner2 == partnerID or cfg.toPartner3 == partnerID then
      table.insert(ret, cfg)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return ret
end
def.static("number", "=>", "table").GetSpecialPartnerCfg = function(partnerID)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GET_SPECIAL_PARTNER_CFG, partnerID)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.partnerId = record:GetIntValue("partnerId")
  cfg.btnName = record:GetStringValue("btnName")
  cfg.uiPath = record:GetStringValue("uiPath")
  return cfg
end
def.static("number", "=>", "table").GetPartnerYuanshenCfg = function(yuanshenId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PARTNER_PARTNER_YUANSHEN_CFG, yuanshenId)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.costId = record:GetIntValue("costId")
  cfg.costItemId = record:GetIntValue("costItemId")
  cfg.picId = record:GetIntValue("picId")
  cfg.pasSkillIds = {}
  local rec2 = record:GetStructValue("skillsStruct")
  local count = rec2:GetVectorSize("pasSkillIds")
  for i = 1, count do
    local rec3 = rec2:GetVectorValueByIdx("pasSkillIds", i - 1)
    local skillId = rec3:GetIntValue("skillId")
    if skillId ~= 0 then
      table.insert(cfg.pasSkillIds, skillId)
    end
  end
  return cfg
end
def.static("number", "=>", "table").GetRankInfoCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_RANK_INFO_CFG, id)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.id = id
  cfg.rankEnum = record:GetIntValue("rankEnum")
  cfg.color = record:GetIntValue("color")
  cfg.rankValue = record:GetIntValue("rankValue")
  return cfg
end
def.method().initPartnerRankInfo = function(self)
  self._partnerRankInfo = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_PARTNER_RANK_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local rankId = entry:GetIntValue("rankId")
    local yuanLv = entry:GetIntValue("yuanLv")
    local rankData = entry:GetIntValue("rankData")
    self._partnerRankInfo[rankId] = instance._partnerRankInfo[rankId] or {}
    self._partnerRankInfo[rankId][yuanLv] = rankData
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("number", "=>", "number").getPartnerInfoCfgId = function(self, partnerId)
  local yuanLv = self:getYuanshenLevel(partnerId)
  if yuanLv > 0 then
    local partnerCfg = self:GetPartnerCfgById(partnerId)
    local rankId = partnerCfg.rankId
    return self._partnerRankInfo[rankId][yuanLv]
  end
  return 0
end
def.method("number", "=>", "number").getYuanshenLevel = function(self, partnerId)
  local property = self._partnerInfos.partner2Property[partnerId]
  if property then
    return property.yuanLv or 1
  end
  return 1
end
def.method("number", "number", "=>", "number").getSubYuanshenLevel = function(self, partnerId, index)
  local property = self._partnerInfos.partner2Property[partnerId]
  if property and property.levels then
    return property.levels[index] or 1
  end
  return 1
end
def.method("number", "number", "=>", "number").getCostItemNum = function(self, costId, yuanshenLv)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_PARTNER_PARTNER_YUANSHEN_COST_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local costId = entry:GetIntValue("costId")
    if costId == costId then
      local yuanLv = entry:GetIntValue("yuanLv")
      if yuanLv == yuanshenLv then
        local needNum = entry:GetIntValue("needNum")
        return needNum
      end
    end
  end
  return 0
end
def.method("number", "number", "table").setYuanshenInfo = function(self, partnerId, allLevel, subLevels)
  local property = self._partnerInfos.partner2Property[partnerId]
  property.yuanLv = allLevel
  property.levels = subLevels
end
def.method("number", "table").setPartnerSkills = function(self, partnerId, skills)
  local property = self._partnerInfos.partner2Property[partnerId]
  property.skillInfos = skills
end
def.method("number", "=>", "table").GetPartnerSkillInfos = function(self, partnerId)
  local property = self._partnerInfos.partner2Property[partnerId]
  if property then
    return property.skillInfos
  end
  return nil
end
def.method("number", "number").setYuanshenLevelUp = function(self, partnerId, index)
  local property = self._partnerInfos.partner2Property[partnerId]
  local level = property.levels[index]
  property.levels[index] = level + 1
end
def.method("number", "=>", "string").getRankLevelStr = function(self, rank)
  local rankEnum = require("consts.mzm.gsp.partner.confbean.RankEnum")
  if rank == rankEnum.RANK_SSS then
    return "SSS"
  elseif rank == rankEnum.RANK_SS then
    return "SS"
  elseif rank == rankEnum.RANK_S then
    return "S"
  elseif rank == rankEnum.RANK_A then
    return "A"
  elseif rank == rankEnum.RANK_B then
    return "B"
  elseif rank == rankEnum.RANK_C then
    return "C"
  elseif rank == rankEnum.RANk_D then
    return "D"
  end
  return nil
end
def.method("number", "=>", "userdata").getPartnerColor = function(self, colorId)
  local colorEnum = require("consts.mzm.gsp.partner.confbean.ParnterColorEnum")
  if colorId == colorEnum.WHITE then
    return Color.Color(1, 1, 1, 1)
  elseif colorId == colorEnum.GREEN then
    return Color.Color(0, 1, 0, 1)
  elseif colorId == colorEnum.BLUE then
    return Color.Color(0, 0, 1, 1)
  elseif colorId == colorEnum.VIOLET then
    return Color.Color(0.9, 0.5, 0.9, 1)
  elseif colorId == colorEnum.ORANGE then
    return Color.Color(1, 0.6, 1, 1)
  end
  return Color.Color(1, 1, 1, 1)
end
def.static("number", "=>", "table").GetPartnerYuanShenUpgradeCfg = function(position)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CPartnerYuanshenImproveCfg, position)
  if record == nil then
    Debug.LogError(string.format("GetPartnerYuanShenUpgradeCfg(%d) return nil", position))
    return nil
  end
  local cfg = {}
  cfg.position = position
  cfg.levelImproves = {}
  local improveStruct = record:GetStructValue("improveStruct")
  local count = improveStruct:GetVectorSize("improveList")
  for i = 1, count do
    local rec2 = improveStruct:GetVectorValueByIdx("improveList", i - 1)
    local t = {}
    t.frameColor = rec2:GetIntValue("frameColor")
    t.improveRequiredItemSiftId = rec2:GetIntValue("improveRequiredItemSiftId")
    t.improveRequiredItemNum = rec2:GetIntValue("improveRequiredItemNum")
    t.propertyTypes = {}
    local propertyTypesStruct = rec2:GetStructValue("propertyTypesStruct")
    local countTypes = propertyTypesStruct:GetVectorSize("propertyTypes")
    for i = 1, countTypes do
      local recTypes = propertyTypesStruct:GetVectorValueByIdx("propertyTypes", i - 1)
      local propertyType = recTypes:GetIntValue("propertyType")
      table.insert(t.propertyTypes, propertyType)
    end
    t.propertyRatios = {}
    local propertyRatiosStruct = rec2:GetStructValue("propertyRatiosStruct")
    local countRatios = propertyRatiosStruct:GetVectorSize("propertyRatios")
    for i = 1, countRatios do
      local recRatios = propertyRatiosStruct:GetVectorValueByIdx("propertyRatios", i - 1)
      local propertyRatio = recRatios:GetIntValue("propertyRatio")
      table.insert(t.propertyRatios, propertyRatio)
    end
    cfg.levelImproves[i] = t
  end
  return cfg
end
def.static("=>", "table").GetAllYuanShenPositions = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CPartnerYuanshenImproveCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local positions = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local position = record:GetIntValue("position")
    table.insert(positions, position)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return positions
end
def.static("number", "=>", "table").GetPartnerYuanShenPositionCfg = function(position)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CPartnerYuanshenPositionCfg, position)
  if record == nil then
    Debug.LogError(string.format("GetPartnerYuanShenPositionCfg(%d) return nil", position))
    return nil
  end
  local cfg = {}
  cfg.position = position
  cfg.name = record:GetStringValue("name")
  cfg.spriteName = record:GetStringValue("spriteName")
  return cfg
end
def.method("number", "table", "=>", "table").AttachPropertyToPartner = function(self, partnerId, property)
  if property == nil then
    return nil
  end
  return property
end
def.method("number", "table", "=>", "table").AttachYuanShenProperty = function(self, partnerId, property)
  if property == nil then
    return nil
  end
  local partnerCfg = PartnerInterface.Instance():GetPartnerCfgById(partnerId)
  if partnerCfg == nil then
    return property
  end
  local PartnerYuanShenMgr = require("Main.partner.PartnerYuanShenMgr")
  local PropertyType = require("consts.mzm.gsp.common.confbean.PropertyType")
  local yuanShenProperties = PartnerYuanShenMgr.Instance():GetYuanShenPropertiesByPartnerId(partnerId)
  local propertyMapField = {
    [PropertyType.MAG_CRT_VALUE] = "magCrt",
    [PropertyType.MAGDEF] = "magDef",
    [PropertyType.MAGATK] = "magAtk",
    [PropertyType.SEAL_RESIST] = "sealRes",
    [PropertyType.MAX_MP] = "maxMp",
    [PropertyType.MAX_HP] = "maxHp",
    [PropertyType.SPEED] = "speed",
    [PropertyType.PHY_CRT_VALUE] = "phyCrt",
    [PropertyType.PHYDEF] = "phyDef",
    [PropertyType.PHYATK] = "phyAtk"
  }
  local MathHelper = require("Common.MathHelper")
  for i, v in ipairs(yuanShenProperties) do
    local field = propertyMapField[v.type]
    if field then
      property[field] = MathHelper.Floor(property[field] * (1 + v.ratio / 100))
    end
  end
  property.hp = property.maxHp
  property.mp = property.maxMp
  return property
end
def.static("=>", "boolean").HasNotify = function()
  local PartnerYuanShenMgr = require("Main.partner.PartnerYuanShenMgr")
  if PartnerYuanShenMgr.Instance():HasNotify() then
    return true
  end
  return false
end
PartnerInterface.Commit()
return PartnerInterface
