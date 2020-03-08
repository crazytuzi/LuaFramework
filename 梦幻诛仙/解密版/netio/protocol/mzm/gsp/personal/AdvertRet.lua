local OctetsStream = require("netio.OctetsStream")
local AdvertRet = class("AdvertRet")
AdvertRet.ERROR_ADVERT_TYPE = 0
AdvertRet.ERROR_CONTENT_MIN_LEN = 1
AdvertRet.ERROR_CONTENT_MAX_LEN = 2
AdvertRet.ERROR_CONTENT_INVALID = 3
AdvertRet.ERROR_ADVERT_RELEASED = 4
AdvertRet.ERROR_ADVERT_TIME_LIMIT = 5
AdvertRet.ERROR_SYSTEM = 6
AdvertRet.ERROR_ADVERT_NOT_EXIST = 7
AdvertRet.ERROR_PAGE_NUM_WRONG = 8
AdvertRet.ERROR_LEVLE_INVALID = 9
AdvertRet.ERROR_LOCATION_INVALID = 10
AdvertRet.ERROR_GENDER_INVALID = 11
AdvertRet.ERROR_REFRESH_INVALID = 12
AdvertRet.ERROR_ROLE_LEVLE_INVALID = 13
AdvertRet.ERROR_SEARCH_TO_MUCH = 14
function AdvertRet:ctor()
end
function AdvertRet:marshal(os)
end
function AdvertRet:unmarshal(os)
end
return AdvertRet
