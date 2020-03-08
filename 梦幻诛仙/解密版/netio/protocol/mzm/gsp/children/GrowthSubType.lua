local OctetsStream = require("netio.OctetsStream")
local GrowthSubType = class("GrowthSubType")
GrowthSubType.BAO_SHI = 0
GrowthSubType.MOOD = 1
GrowthSubType.CLEAN = 2
GrowthSubType.TIRED = 3
GrowthSubType.BABY_BREED_OPERAT = 4
GrowthSubType.OLD_NAME = 0
GrowthSubType.NEW_NAME = 1
GrowthSubType.DRAW_LOTS_CFG_ID = 0
GrowthSubType.COURSE_TYPE = 0
GrowthSubType.IS_CRIT = 1
GrowthSubType.ADULT_SELECT_OCCUPATION_OCCU = 0
GrowthSubType.ADULT_STUDY_SKILL_ORIGINAL = 0
GrowthSubType.ADULT_STUDY_SKILL_NOW = 1
GrowthSubType.ADULT_CHANGE_OCCUPATION_ORIGINAL = 0
GrowthSubType.ADULT_CHANGE_OCCUPATION_NOW = 1
GrowthSubType.ADULT_ADD_APT_TYPE = 0
GrowthSubType.ADULT_ADD_APT_CHANGE = 1
GrowthSubType.ADULT_ADD_GROWTH_CHANGE = 0
function GrowthSubType:ctor()
end
function GrowthSubType:marshal(os)
end
function GrowthSubType:unmarshal(os)
end
return GrowthSubType
