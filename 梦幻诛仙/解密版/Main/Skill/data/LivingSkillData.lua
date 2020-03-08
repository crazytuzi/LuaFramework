local Lplus = require("Lplus")
local LivingSkillData = Lplus.Class("LivingSkillData")
local def = LivingSkillData.define
local instance
def.field("table").bagList = nil
def.field("table").bagLevelList = nil
def.field("boolean").bInit = false
def.field("boolean").bSyndBagLvList = false
def.static("=>", LivingSkillData).Instance = function()
  if nil == instance then
    instance = LivingSkillData()
    instance.bagList = {}
    instance.bagLevelList = {}
    instance.bInit = false
  end
  return instance
end
def.method().SetAllNull = function(self)
  self.bagList = {}
  self.bagLevelList = {}
  self.bSyndBagLvList = false
  self.bInit = false
end
def.method().InitLivingSkillBags = function(self)
  if self.bInit then
    return
  end
  self.bagList = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_LIVING_SKILL_BAG_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local bag = {}
    bag.id = DynamicRecord.GetIntValue(entry, "id")
    bag.iconId = DynamicRecord.GetIntValue(entry, "iconId")
    bag.name = DynamicRecord.GetStringValue(entry, "name")
    bag.templatename = DynamicRecord.GetStringValue(entry, "templatename")
    bag.desc = DynamicRecord.GetStringValue(entry, "desc")
    bag.showType = DynamicRecord.GetIntValue(entry, "showType")
    bag.levelUpTypeId = DynamicRecord.GetIntValue(entry, "levelUpTypeId")
    if nil ~= self.bagLevelList[bag.id] then
      bag.level = self.bagLevelList[bag.id]
    else
      bag.level = 0
    end
    bag.itemIdList = {}
    local skillBagStruct = DynamicRecord.GetStructValue(entry, "skillBagStruct")
    local skillBagAmount = DynamicRecord.GetVectorSize(skillBagStruct, "skillBagVector")
    for i = 0, skillBagAmount - 1 do
      local bagRecord = DynamicRecord.GetVectorValueByIdx(skillBagStruct, "skillBagVector", i)
      local bagId = bagRecord:GetIntValue("skillBagId")
      local skillBagInfo = LivingSkillData.GetSkillBagInfo(bagId)
      if skillBagInfo then
        local LifeSkillBagIdTypeEnum = require("consts.mzm.gsp.skill.confbean.LifeSkillBagIdTypeEnum")
        if skillBagInfo.idType == LifeSkillBagIdTypeEnum.siftId then
          local item = {}
          item.id = skillBagInfo.siftItemId
          item.bagId = bagId
          item.openLevel = skillBagInfo.openLevel
          item.bItem = false
          table.insert(bag.itemIdList, item)
        elseif skillBagInfo.idType == LifeSkillBagIdTypeEnum.itemId then
          local item = {}
          item.id = skillBagInfo.siftItemId
          item.bagId = bagId
          item.openLevel = skillBagInfo.openLevel
          item.bItem = true
          table.insert(bag.itemIdList, item)
        end
      end
    end
    local LifeSkillBagShowTypeEnum = require("consts.mzm.gsp.skill.confbean.LifeSkillBagShowTypeEnum")
    if bag.showType == LifeSkillBagShowTypeEnum.type1 then
      table.sort(bag.itemIdList, function(a, b)
        return a.openLevel < b.openLevel
      end)
    end
    table.insert(self.bagList, bag)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  self.bInit = true
end
def.method("=>", "table").GetBagList = function(self)
  if false == self.bInit then
    self:InitLivingSkillBags()
  end
  return self.bagList
end
def.method("number", "=>", "table").GetSkillBagByType = function(self, type)
  local skillBagList = self:GetBagList()
  for k, v in pairs(skillBagList) do
    if v.showType == type then
      return v
    end
  end
  return nil
end
def.method("number", "=>", "table").GetSkillBagById = function(self, skillBagId)
  if false == self.bInit then
    self:InitLivingSkillBags()
  end
  for k, v in pairs(self.bagList) do
    if v.id == skillBagId then
      return v
    end
  end
  return nil
end
def.method("number", "=>", "table").GetUnLockSkill = function(self, skillBagId)
  if false == self.bInit then
    self:InitLivingSkillBags()
  end
  local tbl = {}
  for k, v in pairs(self.bagList) do
    if v.id == skillBagId then
      for m, n in pairs(v.itemIdList) do
        if n.openLevel <= v.level then
          table.insert(tbl, n)
        end
      end
    end
  end
  table.sort(tbl, function(a, b)
    return a.openLevel < b.openLevel
  end)
  return tbl
end
def.method("number", "=>", "number").GetSkillMinUnlockLevel = function(self, skillBagId)
  if false == self.bInit then
    self:InitLivingSkillBags()
  end
  local minUnlockLevel = math.huge
  for k, v in pairs(self.bagList) do
    if v.id == skillBagId then
      for m, n in pairs(v.itemIdList) do
        minUnlockLevel = math.min(minUnlockLevel, n.openLevel)
      end
      break
    end
  end
  return minUnlockLevel
end
def.static("number", "=>", "table").GetItemsIdByShiftId = function(shiftId)
  local itemIdList = {}
  local record = DynamicData.GetRecord(CFG_PATH.DATA_LIVING_SKILL_ITEMS_CFG, shiftId)
  local recItemId = record:GetStructValue("itemsStruct")
  local size = recItemId:GetVectorSize("itemsVector")
  if size < 1 then
    return itemIdList
  end
  for i = 0, size - 1 do
    local rec = recItemId:GetVectorValueByIdx("itemsVector", i)
    local itemId = rec:GetIntValue("itemId")
    table.insert(itemIdList, itemId)
  end
  return itemIdList
end
def.static("number", "=>", "table").GetSkillBagInfo = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_LIVING_SKILL_CFG, id)
  local tbl
  if record then
    tbl = {}
    tbl.siftItemId = record:GetIntValue("siftItemId")
    tbl.openLevel = record:GetIntValue("openLevel")
    tbl.idType = record:GetIntValue("idType")
  end
  return tbl
end
def.method("table").SetSkillBagsLevel = function(self, skillBagList)
  self.bagLevelList = {}
  for k, v in pairs(skillBagList) do
    local bagId = v.skillBagId
    local level = v.skillLevel
    self.bagLevelList[bagId] = level
  end
  self.bSyndBagLvList = true
end
def.method("number", "number").SetSkillBagLevel = function(self, skillbagId, level)
  local skillBagList = self:GetBagList()
  for k, v in pairs(skillBagList) do
    if v.id == skillbagId then
      v.level = level
    end
  end
end
return LivingSkillData.Commit()
