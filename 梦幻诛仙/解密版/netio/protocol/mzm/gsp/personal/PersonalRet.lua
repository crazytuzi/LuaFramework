local OctetsStream = require("netio.OctetsStream")
local PersonalRet = class("PersonalRet")
PersonalRet.ROLE_NOT_EXIST = 0
PersonalRet.SIGN_INVALID = 1
PersonalRet.SIGN_LENGTH_INVALID = 2
PersonalRet.SCHOOL_INVALID = 3
PersonalRet.SCHOOL_LENGTH_INVALID = 4
PersonalRet.SYSTEM_ERROR = 5
PersonalRet.PRAISE_SELF = 6
PersonalRet.DAILY_PRAISE_SOMEONE_MAX = 7
PersonalRet.DAILY_PRAISE_MAX = 8
PersonalRet.PRAISE_MAX = 9
PersonalRet.HEAD_IMAGE_INVALID = 10
PersonalRet.GENDER_INVALID = 11
PersonalRet.AGE_INVALID = 12
PersonalRet.BIRTHDAY_INVALID = 13
PersonalRet.ANIMAL_SIGN_INVALID = 14
PersonalRet.CONSTELLATION_INVALID = 15
PersonalRet.BLOOD_TYPE_INVALID = 16
PersonalRet.OCCUPATION_INVALID = 17
PersonalRet.LOCATION_PROVINCE_INVALID = 18
PersonalRet.LOCATION_CITY_INVALID = 19
PersonalRet.HOBBY_INVALID = 20
PersonalRet.HOBBY_NUM_INVALID = 21
PersonalRet.PHOTO_INVALID = 22
function PersonalRet:ctor()
end
function PersonalRet:marshal(os)
end
function PersonalRet:unmarshal(os)
end
return PersonalRet
