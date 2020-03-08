local Lplus = require("Lplus")
local GangSkillData = Lplus.Class("GangSkillData")
local def = GangSkillData.define
local instance
def.field("table").bagList = nil
def.field("table").bagLevelList = nil
def.field("boolean").bInit = false
def.static("=>", GangSkillData).Instance = function()
  if nil == instance then
    instance = GangSkillData()
    instance.bagList = {}
    instance.bagLevelList = {}
    instance.bInit = false
  end
  return instance
end
def.method().SetAllNull = function(self)
  self.bagList = {}
  self.bagLevelList = {}
  self.bInit = false
end
def.method().InitGangSkillBags = function(self)
  if self.bInit then
    return
  end
  self.bagList = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_GANG_SKILL_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local bag = {}
    bag.id = DynamicRecord.GetIntValue(entry, "id")
    bag.skillid = DynamicRecord.GetIntValue(entry, "skillid")
    bag.typeId = DynamicRecord.GetIntValue(entry, "typeId")
    bag.templatename = DynamicRecord.GetStringValue(entry, "templatename")
    bag.skilldesc = DynamicRecord.GetStringValue(entry, "skilldesc")
    table.insert(self.bagList, bag)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  self.bInit = true
end
def.method("=>", "table").GetBagList = function(self)
  if false == self.bInit then
    self:InitGangSkillBags()
  end
  return self.bagList
end
def.method("=>", "table").GetBagLevelList = function(self)
  return self.bagLevelList
end
def.method("table").SetSkillsLevel = function(self, skillBags)
  for k, v in pairs(skillBags) do
    self.bagLevelList[v.skillid] = v.level
  end
end
def.method("number", "number").SetSkillLevel = function(self, skillId, level)
  self.bagLevelList[skillId] = level
end
def.method("number", "=>", "number").GetSkillLevel = function(self, skillId)
  if self.bagLevelList[skillId] then
    return self.bagLevelList[skillId]
  else
    return 0
  end
end
return GangSkillData.Commit()
