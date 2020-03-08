local Lplus = require("Lplus")
local BaseData = require("Main.Children.data.BaseData")
local YouthData = Lplus.Extend(BaseData, "YouthData")
local AdulthoodInfo = require("netio.protocol.mzm.gsp.children.AdulthoodInfo")
local ChildrenUtils = require("Main.Children.ChildrenUtils")
local ChildAssignPropScheme = require("Main.Children.data.ChildAssignPropScheme")
local def = YouthData.define
def.field("table").info = nil
def.field(ChildAssignPropScheme).assignPropScheme = nil
def.final("=>", YouthData).New = function()
  local data = YouthData()
  return data
end
def.override("table").RawSet = function(self, child)
  BaseData.RawSet(self, child)
  if require("netio.Octets").getSize(child.child_period_info) > 0 then
    local info = UnmarshalBean(AdulthoodInfo, child.child_period_info)
    self:UpdateInfo(info)
  end
end
def.method("table").UpdateInfo = function(self, info)
  self.info = info
  self.assignPropScheme = ChildAssignPropScheme()
  self.assignPropScheme:RawSet(self.info.propSet)
end
def.method("number").SetMenpai = function(self, menpai)
  if self.info then
    self.info.occupation = menpai
  end
end
def.method("=>", "number").GetMenpai = function(self)
  if self.info then
    return self.info.occupation
  end
  return -1
end
def.method("number", "=>", "number").GetSkillLevel = function(self, skillId)
  if self.info then
    return self.info.occupationSkill2Value[skillId] or 1
  end
  return -1
end
def.method("=>", "table").GetChildEquips = function(self)
  return self.info and self.info.equipItem
end
def.method("number", "boolean").SetFightSkill = function(self, skillId, use)
  if self.info then
    if use then
      table.insert(self.info.fightSkills, skillId)
    else
      for i, v in ipairs(self.info.fightSkills) do
        if v == skillId then
          table.remove(self.info.fightSkills, i)
          return
        end
      end
    end
  end
end
def.method("number", "=>", "boolean").IsFightSkill = function(self, skillId)
  if self.info and self.info.fightSkills then
    for i, v in ipairs(self.info.fightSkills) do
      if v == skillId then
        return true
      end
    end
  end
  return false
end
def.method("number", "number", "number").ChangeSkill = function(self, pos, add_id, replaceSkillid)
  if self.info and add_id > 0 then
    self.info.skillBookSkills[pos + 1] = add_id
  end
end
def.method("number", "number").UpdateSkillLevel = function(self, skillId, level)
  if self.info then
    self.info.occupationSkill2Value[skillId] = level
  end
end
def.method("number", "number").UpdateQuality = function(self, quality, val)
  if self.info then
    self.info.aptitudeInitMap[quality] = val
  end
end
def.method("table").UpdateProps = function(self, propMap)
  if self.info then
    self.info.propMap = propMap
  end
end
def.method("table").UpdatePropSet = function(self, propSet)
  if self.info then
    self.info.propSet = propSet
    if self.assignPropScheme then
      self.assignPropScheme:RawSet(self.info.propSet)
    end
  end
end
def.method("=>", "boolean").HasPropSet = function(self)
  return self.info ~= nil and self.info.propSet ~= nil and table.nums(self.info.propSet) > 0
end
def.method("number").UpdateSkillNum = function(self, num)
  if self.info then
    self.info.unLockSkillPosNum = num
  end
end
def.method("number").SetSpecialSkill = function(self, skillId)
  if self.info then
    self.info.specialSkillid = skillId
  end
end
def.method("number").SetGrowth = function(self, growValue)
  if self.info then
    self.info.grow = growValue
  end
end
def.method("number").SetGrowthItemCount = function(self, count)
  if self.info then
    self.info.useGrowthItemCount = count
  end
end
def.method("=>", "number").GetWeaponId = function(self)
  if self.info == nil then
    return 0
  end
  local ChildEuqipPos = require("consts.mzm.gsp.item.confbean.ChildEuqipPos")
  local itemInfo = self.info.equipItem[ChildEuqipPos.WEAPON]
  return itemInfo and itemInfo.id or 0
end
def.method("=>", "table").GetAmuletSkills = function(self)
  local PetEquipType = require("consts.mzm.gsp.petequip.confbean.PetEquipType")
  local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
  if self.info == nil then
    return {}
  end
  local amuletInfo = self.info.equipPetItem[PetEquipType.AMULET]
  if amuletInfo == nil then
    return {}
  end
  local amuletSkills = {}
  amuletSkills[1] = amuletInfo.extraMap[ItemXStoreType.PET_EQUIP_SKILL_ID_1]
  amuletSkills[2] = amuletInfo.extraMap[ItemXStoreType.PET_EQUIP_SKILL_ID_2]
  return amuletSkills
end
def.method("=>", "number").GetEquipsMinLevel = function(self)
  if self.info == nil then
    return 0
  end
  local level = -1
  local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
  for i, v in pairs(self.info.equipItem) do
    local equipLv = v.extraMap[ItemXStoreType.CHILDREN_EQUIP_LEVEL]
    if level == -1 or level > equipLv then
      level = equipLv
    end
  end
  return level
end
def.method("=>", "number").CalYouthChildScore = function(self)
  if self.info == nil then
    return 0
  end
  local aptitudeTotalScore = 0
  for k, v in pairs(self.info.aptitudeInitMap) do
    aptitudeTotalScore = aptitudeTotalScore + v * constant.CChildrenConsts.child_rating_aptitude_ratio / 10000
  end
  local growTotalScore = self.info.grow * constant.CChildrenConsts.child_rating_grow_ratio / 10000
  local PetSkillLevelEnum = require("consts.mzm.gsp.pet.confbean.PetSkillLevelEnum")
  local skillTotalScore = 1
  for i = 1, #self.info.skillBookSkills do
    local skillId = self.info.skillBookSkills[i]
    local skillLevel = require("Main.Pet.PetUtility").GetPetSkillLevelEnumValue(skillId)
    if skillLevel == PetSkillLevelEnum.NORMAL then
      skillTotalScore = skillTotalScore + constant.CChildrenConsts.child_rating_low_skill_ratio / 10000
    elseif skillLevel == PetSkillLevelEnum.HIGH then
      skillTotalScore = skillTotalScore + constant.CChildrenConsts.child_rating_high_skill_ratio / 10000
    elseif skillLevel == PetSkillLevelEnum.SUPER then
      skillTotalScore = skillTotalScore + constant.CChildrenConsts.child_rating_super_skill_ratio / 10000
    end
  end
  local amuletSkills = self:GetAmuletSkills()
  for i = 1, #amuletSkills do
    local skillId = amuletSkills[i]
    local skillLevel = require("Main.Pet.PetUtility").GetPetSkillLevelEnumValue(skillId)
    if skillLevel == PetSkillLevelEnum.NORMAL then
      skillTotalScore = skillTotalScore + constant.CChildrenConsts.child_rating_low_skill_ratio / 10000
    elseif skillLevel == PetSkillLevelEnum.HIGH then
      skillTotalScore = skillTotalScore + constant.CChildrenConsts.child_rating_high_skill_ratio / 10000
    elseif skillLevel == PetSkillLevelEnum.SUPER then
      skillTotalScore = skillTotalScore + constant.CChildrenConsts.child_rating_super_skill_ratio / 10000
    end
  end
  local specialSkillScore = 0
  if self.info.specialSkillid and 0 < self.info.specialSkillid then
    specialSkillScore = specialSkillScore + constant.CChildrenConsts.child_rating_special_skill_ratio / 10000
  end
  local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
  local equipTotalScore = 0
  local equips = self:GetChildEquips()
  for i = 1, #equips do
    local equipLevel = equips[i].extraMap[ItemXStoreType.CHILDREN_EQUIP_LEVEL]
    equipTotalScore = equipTotalScore + equipLevel * constant.CChildrenConsts.child_rating_equip_level_ratio / 10000
  end
  local occupationSkillTotalScore = 0
  local skills = ChildrenUtils.GetMenpaiSkills(self:GetMenpai())
  for i = 1, #skills do
    local skillId = skills[i].skillid
    local skillLevel = self:GetSkillLevel(skillId)
    occupationSkillTotalScore = occupationSkillTotalScore + skillLevel * constant.CChildrenConsts.child_rating_occupation_skill_ratio / 10000
  end
  return math.ceil((aptitudeTotalScore + growTotalScore) * skillTotalScore + specialSkillScore + equipTotalScore + occupationSkillTotalScore)
end
YouthData.Commit()
return YouthData
