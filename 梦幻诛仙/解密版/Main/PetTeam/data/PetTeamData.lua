local Lplus = require("Lplus")
local PetTeamInfo = require("Main.PetTeam.data.PetTeamInfo")
local FormationInfo = require("Main.PetTeam.data.FormationInfo")
local ItemModule = require("Main.Item.ItemModule")
local PetTeamData = Lplus.Class("PetTeamData")
local def = PetTeamData.define
local _instance
def.static("=>", PetTeamData).Instance = function()
  if _instance == nil then
    _instance = PetTeamData()
  end
  return _instance
end
def.field("table")._formationCfg = nil
def.field("table")._formationLevelCfg = nil
def.field("table")._petSkillCfg = nil
def.field("table")._formationUpgradeCfg = nil
def.field("table")._teamMap = nil
def.field("number")._defenseTeamIdx = 0
def.field("table")._formationMap = nil
def.field("table")._unlockedSkillMap = nil
def.field("table")._skill2PetMap = nil
def.method().Init = function(self)
  self:_Reset()
end
def.method()._Reset = function(self)
  self._formationCfg = nil
  self._formationLevelCfg = nil
  self._petSkillCfg = nil
  self._formationUpgradeCfg = nil
  self._teamMap = nil
  self._defenseTeamIdx = 0
  self._formationMap = nil
  self._unlockedSkillMap = nil
  self._skill2PetMap = nil
end
def.method()._LoadFormationCfg = function(self)
  warn("[PetTeamData:_LoadFormationCfg] start Load FormationCfg!")
  self._formationCfg = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_PETTEAM_FormationCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local formationCfg = {}
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    formationCfg.id = DynamicRecord.GetIntValue(entry, "id")
    formationCfg.name = DynamicRecord.GetStringValue(entry, "name")
    formationCfg.iconId = DynamicRecord.GetIntValue(entry, "iconId")
    formationCfg.pos2IdxMap = {}
    formationCfg.pos2IdxMap[1] = DynamicRecord.GetIntValue(entry, "position1")
    formationCfg.pos2IdxMap[2] = DynamicRecord.GetIntValue(entry, "position2")
    formationCfg.pos2IdxMap[3] = DynamicRecord.GetIntValue(entry, "position3")
    formationCfg.pos2IdxMap[4] = DynamicRecord.GetIntValue(entry, "position4")
    formationCfg.pos2IdxMap[5] = DynamicRecord.GetIntValue(entry, "position5")
    formationCfg.idx2PosMap = {}
    formationCfg.idx2PosMap[formationCfg.pos2IdxMap[1]] = 1
    formationCfg.idx2PosMap[formationCfg.pos2IdxMap[2]] = 2
    formationCfg.idx2PosMap[formationCfg.pos2IdxMap[3]] = 3
    formationCfg.idx2PosMap[formationCfg.pos2IdxMap[4]] = 4
    formationCfg.idx2PosMap[formationCfg.pos2IdxMap[5]] = 5
    self._formationCfg[formationCfg.id] = formationCfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("=>", "table")._GetFormationCfgs = function(self)
  if nil == self._formationCfg then
    self:_LoadFormationCfg()
  end
  return self._formationCfg
end
def.method("number", "=>", "table").GetFormationCfg = function(self, id)
  return self:_GetFormationCfgs()[id]
end
def.method("=>", "table").GetAllFormationCfgs = function(self)
  local cfgList = {}
  local allFormationCfgs = self:_GetFormationCfgs()
  if allFormationCfgs then
    for id, cfg in pairs(allFormationCfgs) do
      if id ~= constant.CPetFightConsts.DEFAULT_FORMATION_ID then
        table.insert(cfgList, cfg)
      end
    end
    table.sort(cfgList, function(a, b)
      if a == nil then
        return true
      elseif b == nil then
        return false
      else
        local aInfo = self:GetFormationInfo(a.id)
        local bInfo = self:GetFormationInfo(b.id)
        if aInfo == nil and bInfo == nil or aInfo ~= nil and bInfo ~= nil then
          return a.id < b.id
        else
          return aInfo ~= nil
        end
      end
    end)
  end
  return cfgList
end
def.method("=>", "table").GetOwnFormationCfgs = function(self)
  local cfgList = {}
  local allFormationCfgs = self:_GetFormationCfgs()
  if allFormationCfgs then
    for id, cfg in pairs(allFormationCfgs) do
      if self:GetFormationInfo(id) and id ~= constant.CPetFightConsts.DEFAULT_FORMATION_ID then
        table.insert(cfgList, cfg)
      end
    end
    table.sort(cfgList, function(a, b)
      if a == nil then
        return true
      elseif b == nil then
        return false
      else
        return a.id < b.id
      end
    end)
  end
  return cfgList
end
def.method()._LoadFormationLevelCfg = function(self)
  warn("[PetTeamData:_LoadFormationLevelCfg] start Load FormationLevelCfg!")
  self._formationLevelCfg = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_PETTEAM_FormationLevelCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    local formationLevelCfg = {}
    formationLevelCfg.id = DynamicRecord.GetIntValue(entry, "id")
    formationLevelCfg.levelCfgs = {}
    local levelsStruct = entry:GetStructValue("levelsStruct")
    local levelCount = levelsStruct:GetVectorSize("levels")
    for j = 1, levelCount do
      local record = levelsStruct:GetVectorValueByIdx("levels", j - 1)
      local levelCfg = {}
      levelCfg.level = j - 1
      levelCfg.expToNextLevel = record:GetIntValue("expToNextLevel")
      levelCfg.posAttrs = {}
      for pos = 1, constant.CPetFightConsts.MAX_PET_NUMBER_PER_TEAM do
        local attrs = {}
        local positionAttrsStruct = record:GetStructValue("position" .. pos .. "AttrsStruct")
        local positionValuesStruct = record:GetStructValue("position" .. pos .. "ValuesStruct")
        local attrCount = positionAttrsStruct and positionAttrsStruct:GetVectorSize("position" .. pos .. "Attrs") or 0
        for k = 1, attrCount do
          local recordType = positionAttrsStruct:GetVectorValueByIdx("position" .. pos .. "Attrs", k - 1)
          local recordValue = positionValuesStruct:GetVectorValueByIdx("position" .. pos .. "Values", k - 1)
          local attrCfg = {}
          attrCfg.type = recordType:GetIntValue("attrType")
          attrCfg.value = recordValue:GetIntValue("attrValue")
          table.insert(attrs, attrCfg)
        end
        levelCfg.posAttrs[pos] = attrs
      end
      if j == levelCount then
        formationLevelCfg.maxLevel = levelCfg.level
      end
      formationLevelCfg.levelCfgs[levelCfg.level] = levelCfg
    end
    self._formationLevelCfg[formationLevelCfg.id] = formationLevelCfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("=>", "table")._GetFormationLevelCfgs = function(self)
  if nil == self._formationLevelCfg then
    self:_LoadFormationLevelCfg()
  end
  return self._formationLevelCfg
end
def.method("number", "=>", "table").GetFormationLevelCfg = function(self, id)
  local cfgs = self:_GetFormationLevelCfgs()
  return cfgs and cfgs[id] or nil
end
def.method("number", "number", "=>", "table").GetLevelCfg = function(self, formationId, level)
  local formationLevelCfg = self:GetFormationLevelCfg(formationId)
  local levelCfg = formationLevelCfg and formationLevelCfg.levelCfgs[level]
  return levelCfg
end
def.method("number", "number", "=>", "number").GetFormationUpgradeExp = function(self, id, level)
  local levelCfg = self:GetLevelCfg(id, level)
  return levelCfg and levelCfg.expToNextLevel or 0
end
def.method()._LoadSkillCfg = function(self)
  warn("[PetTeamData:_LoadSkillCfg] start Load SkillCfg!")
  self._petSkillCfg = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_PETTEAM_SkillCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local skillCfg = {}
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    skillCfg.id = DynamicRecord.GetIntValue(entry, "id")
    skillCfg.skillId = DynamicRecord.GetIntValue(entry, "skillId")
    skillCfg.unlockScore = DynamicRecord.GetIntValue(entry, "unlockScore")
    self._petSkillCfg[skillCfg.id] = skillCfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("=>", "table").GetSkillCfgs = function(self)
  if nil == self._petSkillCfg then
    self:_LoadSkillCfg()
  end
  return self._petSkillCfg
end
def.method("number", "=>", "table").GetSkillCfg = function(self, cfgId)
  return self:GetSkillCfgs()[cfgId]
end
def.method()._LoadFormationUpgradeCfg = function(self)
  warn("[PetTeamData:_LoadFormationUpgradeCfg] start Load FormationUpgradeCfg!")
  self._formationUpgradeCfg = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_PETTEAM_FormationUpgradeCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local upgradeCfg = {}
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    upgradeCfg.id = DynamicRecord.GetIntValue(entry, "id")
    upgradeCfg.items = {}
    local itemIdsStruct = entry:GetStructValue("itemIdsStruct")
    local itemCount = itemIdsStruct:GetVectorSize("itemIds")
    for j = 1, itemCount do
      local record = itemIdsStruct:GetVectorValueByIdx("itemIds", j - 1)
      local itemId = record:GetIntValue("itemId")
      table.insert(upgradeCfg.items, itemId)
    end
    self._formationUpgradeCfg[upgradeCfg.id] = upgradeCfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("=>", "table")._GetFormationUpgradeCfgs = function(self)
  if nil == self._formationUpgradeCfg then
    self:_LoadFormationUpgradeCfg()
  end
  return self._formationUpgradeCfg
end
def.method("number", "=>", "table").GetFormationUpgradeCfg = function(self, cfgId)
  return self:_GetFormationUpgradeCfgs()[cfgId]
end
def.method("number", "=>", "number").GetFormationByItem = function(self, itemId)
  if itemId <= 0 then
    return 0
  end
  local formationId = 0
  local formationUpgradeCfg = self:_GetFormationUpgradeCfgs()
  if formationUpgradeCfg then
    for id, upgradeCfg in pairs(formationUpgradeCfg) do
      if upgradeCfg and upgradeCfg.items and 0 < #upgradeCfg.items then
        for _, upgradeItemId in ipairs(upgradeCfg.items) do
          if upgradeItemId == itemId then
            formationId = id
            break
          end
        end
      end
      if formationId > 0 then
        break
      end
    end
  end
  return formationId
end
def.method("=>", "table").GetAllFormationUpgradeItemIds = function(self)
  local itemIds = {}
  local formationUpgradeCfgs = self:_GetFormationUpgradeCfgs()
  if formationUpgradeCfgs then
    for id, upgradeCfg in pairs(formationUpgradeCfgs) do
      if upgradeCfg and upgradeCfg.items and #upgradeCfg.items > 0 then
        for _, upgradeItemId in ipairs(upgradeCfg.items) do
          table.insert(itemIds, upgradeItemId)
        end
      end
    end
  end
  return itemIds
end
def.method("number").SetDefTeamIdx = function(self, teamIdx)
  if self._defenseTeamIdx ~= teamIdx then
    self._defenseTeamIdx = teamIdx
    warn("[PetTeamData:SetDefTeamIdx] set teamIdx:", teamIdx)
    Event.DispatchEvent(ModuleId.PETTEAM, gmodule.notifyId.PetTeam.PETTEAM_DEF_TEAM_CHANGE, {teamIdx = teamIdx})
  end
end
def.method("=>", "number").GetDefTeamIdx = function(self)
  return self._defenseTeamIdx
end
def.method("number", "table", "boolean").SetTeamInfo = function(self, teamIdx, teamInfo, bEvent)
  if nil == self._teamMap then
    self._teamMap = {}
  end
  self._teamMap[teamIdx] = teamInfo
  if bEvent then
    Event.DispatchEvent(ModuleId.PETTEAM, gmodule.notifyId.PetTeam.PETTEAM_TEAM_INFO_CHANGE, {teamIdx = teamIdx})
  end
end
def.method("number", "=>", "table").GetTeamInfo = function(self, teamIdx)
  return self._teamMap and self._teamMap[teamIdx] or nil
end
def.method("number", "table", "boolean").UpdateTeamPos = function(self, teamIdx, pos2PetMap, bEvent)
  local teamInfo = self:GetTeamInfo(teamIdx)
  if teamInfo then
    teamInfo:UpdateTeamPos(pos2PetMap)
    if bEvent then
      Event.DispatchEvent(ModuleId.PETTEAM, gmodule.notifyId.PetTeam.PETTEAM_TEAM_INFO_CHANGE, {teamIdx = teamIdx})
    end
  else
    local petTeamInfo = PetTeamInfo.New(teamIdx, constant.CPetFightConsts.DEFAULT_FORMATION_ID, pos2PetMap)
    self:SetTeamInfo(teamIdx, petTeamInfo, true)
  end
end
def.method("number", "number", "boolean").SetTeamFormation = function(self, teamIdx, formationId, bEvent)
  local teamInfo = self:GetTeamInfo(teamIdx)
  if teamInfo then
    teamInfo:SetFormation(formationId)
    if bEvent then
      Event.DispatchEvent(ModuleId.PETTEAM, gmodule.notifyId.PetTeam.PETTEAM_TEAM_INFO_CHANGE, {teamIdx = teamIdx})
    end
  else
    local petTeamInfo = PetTeamInfo.New(teamIdx, formationId, nil)
    self:SetTeamInfo(teamIdx, petTeamInfo, true)
  end
end
def.method("table", "boolean").SetFormationInfo = function(self, formationInfo, bEvent)
  if nil == formationInfo then
    return
  end
  if nil == self._formationMap then
    self._formationMap = {}
  end
  self._formationMap[formationInfo.id] = formationInfo
  if bEvent then
    Event.DispatchEvent(ModuleId.PETTEAM, gmodule.notifyId.PetTeam.PETTEAM_FORMATION_CHANGE, {
      formationId = formationInfo.id
    })
  end
end
def.method("number", "=>", "table").GetFormationInfo = function(self, formationId)
  return self._formationMap and self._formationMap[formationId] or nil
end
def.method("number", "number", "number", "boolean").UpdateFormation = function(self, formationId, level, exp, bEvent)
  local formationInfo = self:GetFormationInfo(formationId)
  if nil == formationInfo then
    formationInfo = FormationInfo.New(formationId, level, exp)
    self:SetFormationInfo(formationInfo, true)
  else
    formationInfo:SetLevel(level)
    formationInfo:SetExp(exp)
    if bEvent then
      Event.DispatchEvent(ModuleId.PETTEAM, gmodule.notifyId.PetTeam.PETTEAM_FORMATION_CHANGE, {
        formationId = formationInfo.id
      })
    end
  end
end
def.method("number", "=>", "number").GetFormationLevel = function(self, formationId)
  local formationInfo = self:GetFormationInfo(formationId)
  return formationInfo and formationInfo.level or 0
end
def.method("number", "=>", "number").GetFormationExp = function(self, formationId)
  local formationInfo = self:GetFormationInfo(formationId)
  return formationInfo and formationInfo.exp or 0
end
def.method("number", "=>", "number").GetFormationMaxLevel = function(self, formationId)
  local formationLevelCfg = self:GetFormationLevelCfg(formationId)
  return formationLevelCfg and formationLevelCfg.maxLevel or 0
end
def.method("number", "boolean", "=>", "boolean").CanFormationUpgrade = function(self, formationId, bUseFrag)
  local formationLevel = self:GetFormationLevel(formationId)
  if formationLevel >= self:GetFormationMaxLevel(formationId) then
    return false
  end
  local itemIds
  if formationLevel > 0 then
    if bUseFrag then
      local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
      local ItemUtils = require("Main.Item.ItemUtils")
      local fragItemIdList = ItemUtils.GetItemTypeRefIdList(ItemType.PET_FIGHT_FORMATION_FRAGMENT)
      if fragItemIdList then
        for _, itemId in ipairs(fragItemIdList) do
          local count = ItemModule.Instance():GetItemCountById(itemId)
          if count > 0 then
            return true
          end
        end
      end
    end
    itemIds = self:GetAllFormationUpgradeItemIds()
  else
    local upgradeCfg = self:GetFormationUpgradeCfg(formationId)
    if upgradeCfg then
      itemIds = upgradeCfg.items
    end
  end
  if itemIds and #itemIds > 0 then
    local result = false
    for _, itemId in ipairs(itemIds) do
      local count = ItemModule.Instance():GetItemCountById(itemId)
      if count > 0 then
        result = true
        break
      end
    end
    return result
  else
    return false
  end
end
def.method("boolean", "=>", "boolean").CanAnyFormationUpgrade = function(self, bUseFrag)
  local result = false
  local formationCfgs = self:_GetFormationCfgs()
  if formationCfgs then
    for id, formationCfg in pairs(formationCfgs) do
      if self:CanFormationUpgrade(id, bUseFrag) then
        result = true
        break
      end
    end
  end
  return result
end
def.method("number", "boolean", "boolean").SetSkillUnlock = function(self, skillId, bUnlocked, bEvent)
  if nil == self._unlockedSkillMap then
    self._unlockedSkillMap = {}
  end
  self._unlockedSkillMap[skillId] = bUnlocked
  if bEvent then
    Event.DispatchEvent(ModuleId.PETTEAM, gmodule.notifyId.PetTeam.PETTEAM_SKILL_CHANGE, {skillId = skillId})
  end
end
def.method("number", "=>", "boolean").GetSkillUnlock = function(self, skillId)
  local bUnlocked = self._unlockedSkillMap and self._unlockedSkillMap[skillId]
  return bUnlocked == true
end
def.method("userdata", "number", "boolean").SetPetSkill = function(self, petId, skillId, bEvent)
  if self._skill2PetMap then
    if petId then
      local oldSkillId
      for sId, pId in pairs(self._skill2PetMap) do
        if Int64.eq(pId, petId) then
          oldSkillId = sId
          break
        end
      end
      if oldSkillId then
        self._skill2PetMap[oldSkillId] = nil
      end
    end
  else
    self._skill2PetMap = {}
  end
  self._skill2PetMap[skillId] = petId
  if bEvent then
    Event.DispatchEvent(ModuleId.PETTEAM, gmodule.notifyId.PetTeam.PETTEAM_SKILL_CHANGE, {skillId = skillId, petId = petId})
  end
end
def.method("userdata", "=>", "number").GetPetSkill = function(self, petId)
  if petId and self._skill2PetMap then
    local skillId
    for sId, pId in pairs(self._skill2PetMap) do
      if Int64.eq(pId, petId) then
        skillId = sId
        break
      end
    end
    return skillId and skillId or 0
  else
    return 0
  end
end
def.method("number", "=>", "userdata").GetSkillPet = function(self, skillId)
  return self._skill2PetMap and self._skill2PetMap[skillId]
end
def.method("=>", "userdata").GetPetSkillCredit = function(self)
  local TokenType = require("consts.mzm.gsp.item.confbean.TokenType")
  return ItemModule.Instance():GetCredits(TokenType.PET_FIGHT_SCORE) or Int64.new(0)
end
def.method("table", "table").OnLeaveWorld = function(self, p1, p2)
  self:_Reset()
end
def.method("table").OnSSyncPetFightInformation = function(self, p)
  self:SetDefTeamIdx(p.info.defense_team)
  local teamInfos = p.info.team_info
  if teamInfos then
    for idx, teamInfo in pairs(teamInfos) do
      local petTeamInfo = PetTeamInfo.New(idx, teamInfo.formation_id, teamInfo.position2pet)
      self:SetTeamInfo(idx, petTeamInfo, true)
    end
  end
  local formations = p.info.formation_info
  if formations then
    for formationId, info in pairs(formations) do
      local formationInfo = FormationInfo.New(formationId, info.level, info.exp)
      self:SetFormationInfo(formationInfo, true)
    end
  end
  local skillInfo = p.info.skill_info
  if skillInfo then
    if skillInfo.skills then
      for _, id in pairs(skillInfo.skills) do
        self:SetSkillUnlock(id, true, false)
      end
      Event.DispatchEvent(ModuleId.PETTEAM, gmodule.notifyId.PetTeam.PETTEAM_SKILL_CHANGE, nil)
    end
    if skillInfo.pet2skill then
      for petId, skillId in pairs(skillInfo.pet2skill) do
        self:SetPetSkill(petId, skillId, false)
      end
      Event.DispatchEvent(ModuleId.PETTEAM, gmodule.notifyId.PetTeam.PETTEAM_SKILL_CHANGE, nil)
    end
  end
end
def.method("table").OnSSyncPetFightPosition = function(self, p)
  self:UpdateTeamPos(p.team, p.position2pet, true)
end
def.method("table").OnSSyncPetFightSkill = function(self, p)
  self._skill2PetMap = {}
  if p.pet2skill then
    for petId, skillId in pairs(p.pet2skill) do
      self:SetPetSkill(petId, skillId, false)
    end
    Event.DispatchEvent(ModuleId.PETTEAM, gmodule.notifyId.PetTeam.PETTEAM_SKILL_CHANGE, nil)
  end
end
PetTeamData.Commit()
return PetTeamData
