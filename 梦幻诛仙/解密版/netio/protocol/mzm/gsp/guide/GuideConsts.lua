local OctetsStream = require("netio.OctetsStream")
local GuideConsts = class("GuideConsts")
GuideConsts.GUIDE_TYPE_SURVEY_NEW = 0
GuideConsts.GUIDE_TYPE_SURVEY_OLD = 1
function GuideConsts:ctor()
end
function GuideConsts:marshal(os)
end
function GuideConsts:unmarshal(os)
end
return GuideConsts
