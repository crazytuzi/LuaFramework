local OctetsStream = require("netio.OctetsStream")
local GrowthType = class("GrowthType")
GrowthType.GROW_TYPE_BABY_BREED = 0
GrowthType.GROW_TYPE_CHANGE_NAME = 1
GrowthType.GROW_TYPE_CHOOSE_INTEREST = 2
GrowthType.GROW_TYPE_LEARN_COURSE = 3
GrowthType.GROW_TYPE_AUTO_BREED = 4
GrowthType.GROW_TYPE_ADULT_SELECT_OCCUPATION = 20
GrowthType.GROW_TYPE_ADULT_STUDY_SKILL = 21
GrowthType.GROW_TYPE_ADULT_CHANGE_OCCUPATION = 22
GrowthType.GROW_TYPE_ADULT_ADD_APT = 23
GrowthType.GROW_TYPE_ADULT_ADD_GROWTH = 24
function GrowthType:ctor()
end
function GrowthType:marshal(os)
end
function GrowthType:unmarshal(os)
end
return GrowthType
