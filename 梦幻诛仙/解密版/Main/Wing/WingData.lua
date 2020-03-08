local Lplus = require("Lplus")
local WingData = Lplus.Class("WingData")
local WingUtils = require("Main.Wing.WingUtils")
local def = WingData.define
def.field("number").level = 0
def.field("number").phase = 0
def.field("number").exp = 0
def.field("table").wings = nil
def.field("number").curWingId = 0
def.field("table").target_skills = nil
def.field("number").curOccupationId = 0
def.field("table").occPlanNames = nil
def.field("table").newOccPlans = nil
def.field("boolean").newOpendFlag = false
def.static("=>", WingData).new = function()
  local wingData = WingData()
  wingData.level = 0
  wingData.phase = 0
  wingData.exp = 0
  wingData.wings = {}
  wingData.curWingId = 0
  wingData.target_skills = {}
  wingData.curOccupationId = 0
  wingData.occPlanNames = {}
  wingData.newOccPlans = {}
  wingData.newOpendFlag = false
  return wingData
end
def.method("number").SetLevel = function(self, l)
  self.level = l
end
def.method("number").SetPhase = function(self, p)
  self.phase = p
end
def.method("number").SetExp = function(self, e)
  self.exp = e
end
def.method("table").SetWings = function(self, ws)
  for k, v in pairs(ws) do
    self:SetWing(v)
  end
end
def.method("table").SetWing = function(self, w)
  local wing = {}
  wing.id = w.cfgId
  wing.colorId = w.colorId
  wing.props = #w.proIds > 0 and clone(w.proIds) or nil
  wing.skills = 0 < #w.skills and clone(w.skills) or nil
  wing.resetProps = 0 < #w.reProIds and clone(w.reProIds) or nil
  wing.resetSkills = 0 < #w.reSkillIds and clone(w.reSkillIds) or nil
  wing.target_skills = {}
  for k, v in pairs(w.target_skills) do
    wing.target_skills[k] = v
  end
  self.wings[wing.id] = wing
  if 0 < #wing.target_skills then
    self.target_skills[wing.id] = {}
    for k, v in pairs(w.target_skills) do
      self.target_skills[wing.id][k] = v
    end
  end
end
def.method("number").SetCurWingId = function(self, curWingId)
  self.curWingId = curWingId
end
def.method("number").SetCurOccupationId = function(self, occupationId)
  self.curOccupationId = occupationId
end
def.method("table").SetOccPlansNames = function(self, planNames)
  self.occPlanNames = planNames
end
def.method("number", "userdata").SetOccPlanName = function(self, occId, name)
  for i, v in ipairs(self.occPlanNames) do
    if v.occId == occId then
      v.planName = name
      return
    end
  end
end
def.method("table").SetNewOccPlans = function(self, newOccPlans)
  self.newOccPlans = newOccPlans
end
def.method("boolean").SetNewOpendFlag = function(self, flag)
  self.newOpendFlag = flag
end
def.method().clearRedPointInfo = function(self)
  self.newOccPlans = {}
  self.newOpendFlag = false
end
def.method("=>", "table").GetNewOccPlans = function(self)
  return self.newOccPlans
end
def.method("=>", "boolean").isNewOpend = function(self)
  return self.newOpendFlag
end
def.method("=>", "number").GetCurOccupationId = function(self)
  return self.curOccupationId
end
def.method("=>", "number").GetLevel = function(self)
  return self.level
end
def.method("=>", "number").GetPhase = function(self)
  return self.phase
end
def.method("=>", "number").GetExp = function(self)
  return self.exp
end
def.method("number", "=>", "table").GetWingByWingId = function(self, wingId)
  return self.wings[wingId]
end
def.method("=>", "number").GetCurWingId = function(self)
  return self.curWingId
end
def.method("=>", "number").GetFirstWingId = function(self)
  for k, v in pairs(self.wings) do
    return k
  end
  return 0
end
def.method("=>", "table").GetCurWing = function(self)
  return self.wings[self.curWingId]
end
def.method("=>", "table").GetProperty = function(self)
  local property = WingUtils.GetWingLevelProps(self.level)
  for k, v in pairs(self.wings) do
    if v.props then
      local prop = WingUtils.ConvertWingProps(v.props)
      property:Plus(prop)
    end
  end
  return property
end
def.method("=>", "table").GetSkills = function(self)
  local skills = {}
  for k, v in pairs(self.wings) do
    local skill = v.skills and v.skills[1] or nil
    if skill then
      table.insert(skills, skill)
    end
  end
  table.sort(skills)
  return skills
end
def.method("=>", "table").GetTargetSkills = function(self)
  return self.target_skills
end
def.method("number", "number", "number").SetTargetSkill = function(self, wingId, pos, skillId)
  self.target_skills[wingId] = self.target_skills[wingId] or {}
  for idx, skill_id in pairs(self.target_skills[wingId]) do
    if skill_id == skillId then
      self.target_skills[wingId][idx] = nil
    end
  end
  if skillId ~= 0 then
    self.target_skills[wingId][pos] = skillId
  else
    self.target_skills[wingId][pos] = nil
  end
end
def.method("=>", "number")._countTargetSkills = function(self)
  local count = 0
  for wId, targetSkills in pairs(self.target_skills) do
    for posIdx, skill_id in pairs(targetSkills) do
      count = count + 1
    end
  end
  return count
end
def.method("number", "number", "=>", "number").GetTargetSkillIdByIdx = function(self, wingId, idx)
  self.target_skills[wingId] = self.target_skills[wingId] or {}
  return self.target_skills[wingId][idx] or 0
end
def.method("number", "number", "=>", "number").GetIndexBySkillId = function(self, wingId, skillId)
  local targetSkills = self.target_skills[wingId]
  if targetSkills == nil then
    return 0
  end
  for idx, sid in pairs(targetSkills) do
    if sid == skillId then
      return idx
    end
  end
  return 0
end
def.method("number", "number", "=>", "boolean").IsTargetSkill = function(self, wingId, skillId)
  local targetSkills = self.target_skills[wingId]
  if targetSkills == nil then
    return false
  end
  for idx, sid in pairs(targetSkills) do
    if skillId == sid then
      return true
    end
  end
  return false
end
def.method("number").UnsertAllPhaseTargetSkillBySkillId = function(self, skillid)
  for wingId, targetSkills in pairs(self.target_skills) do
    if targetSkills ~= nil then
      for idx, sid in pairs(targetSkills) do
        if sid == skillid then
          targetSkills[idx] = nil
        end
      end
    end
  end
end
def.method("=>", "table").GetCurOccPlanNameList = function(self)
  local list = {}
  for i, v in ipairs(self.occPlanNames) do
    local t = {}
    t.occId = v.occId
    local name = GetStringFromOcts(v.planName)
    if name == nil or name == "" then
      name = _G.GetOccupationName(t.occId)
    end
    t.name = name
    table.insert(list, t)
  end
  return list
end
def.method("number", "=>", "string").GetOccNameById = function(self, occId)
  for i, v in ipairs(self.occPlanNames) do
    if v.occId == occId then
      local name = GetStringFromOcts(v.planName)
      if name == nil or name == "" then
        name = _G.GetOccupationName(v.occId)
      end
      return name
    end
  end
  return ""
end
return WingData.Commit()
