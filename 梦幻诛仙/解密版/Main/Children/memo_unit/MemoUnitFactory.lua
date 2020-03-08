local MODULE_NAME = (...)
local Lplus = require("Lplus")
local MemoFactory = Lplus.Class(MODULE_NAME)
local BaseMemoUnit = import(".BaseMemoUnit")
local GrowthType = require("netio.protocol.mzm.gsp.children.GrowthType")
local def = MemoFactory.define
local function create(className)
  local className = className or "BaseMemoUnit"
  local Class = import("." .. className, MODULE_NAME)
  local obj = Class()
  return obj
end
def.static("number", "userdata", "table", "=>", BaseMemoUnit).Create = function(memoType, occurtime, params)
  local obj
  if memoType == GrowthType.GROW_TYPE_BABY_BREED then
    obj = create("BreedMemoUnit")
  elseif memoType == GrowthType.GROW_TYPE_AUTO_BREED then
    obj = create("HireBannyMemoUnit")
  elseif memoType == GrowthType.GROW_TYPE_CHANGE_NAME then
    obj = create("RenameMemoUnit")
  elseif memoType == GrowthType.GROW_TYPE_CHOOSE_INTEREST then
    obj = create("ZhuazhouMemoUnit")
  elseif memoType == GrowthType.GROW_TYPE_LEARN_COURSE then
    obj = create("StudyMemoUnit")
  elseif memoType == GrowthType.GROW_TYPE_ADULT_SELECT_OCCUPATION then
    obj = create("JoinMenpaiMemoUnit")
  elseif memoType == GrowthType.GROW_TYPE_ADULT_STUDY_SKILL then
    obj = create("LearnSkillMemoUnit")
  elseif memoType == GrowthType.GROW_TYPE_ADULT_CHANGE_OCCUPATION then
    obj = create("ChangeMenpaiMemoUnit")
  elseif memoType == GrowthType.GROW_TYPE_ADULT_ADD_APT then
    obj = create("AddPropMemoUnit")
  elseif memoType == GrowthType.GROW_TYPE_ADULT_ADD_GROWTH then
    obj = create("AddGrowthMemoUnit")
  else
    obj = create("BaseMemoUnit")
  end
  obj:Init(memoType, occurtime, params)
  return obj
end
return MemoFactory.Commit()
