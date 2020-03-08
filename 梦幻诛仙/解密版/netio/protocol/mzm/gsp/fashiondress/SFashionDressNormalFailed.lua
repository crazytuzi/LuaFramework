local SFashionDressNormalFailed = class("SFashionDressNormalFailed")
SFashionDressNormalFailed.TYPEID = 12603152
SFashionDressNormalFailed.CHANGE_OLD_PROPERTY_NOT_EXIST = 1
SFashionDressNormalFailed.CHANGE_NEW_PROPERTY_NOT_EXIST = 2
SFashionDressNormalFailed.CHANGE_NEW_PROPERTY_PROPERTY_EMPTY = 3
SFashionDressNormalFailed.CHANGE_PROPERTY_FULL = 4
SFashionDressNormalFailed.FASHION_DRESS_ROLE_INFO_NULL = 5
SFashionDressNormalFailed.FASHION_DRESS_CFG_NOT_EXIST = 6
SFashionDressNormalFailed.CHANGE_OLD_PROPERTY_NOT_IN = 7
SFashionDressNormalFailed.CHANGE_NEW_PROPERTY_ALREADY_IN = 8
SFashionDressNormalFailed.FASHION_DRESS_CFG_ID_REPEAT = 9
SFashionDressNormalFailed.NORMAL_FASHION_DRESS_CHECK_FAIL = 10
SFashionDressNormalFailed.REPLACE_FASHION_DRESS_GENDER_CHECK_FAIL = 11
SFashionDressNormalFailed.REPLACE_FASHION_DRESS_OCCUPATION_CHECK_FAIL = 12
SFashionDressNormalFailed.MULTI_OCCUPATION_CFG_NOT_FOUND = 13
SFashionDressNormalFailed.MULTI_OCCUPATION_CFG_EFFECT_TIME_WRONG = 14
SFashionDressNormalFailed.MULTI_OCCUPATION_CFG_REPEAT = 15
SFashionDressNormalFailed.CHANGE_PROPERTY_MULTI_OCCUPATION_WRONG = 16
SFashionDressNormalFailed.MULTI_OCCUPATION_NOT_HAS_THE_CFG = 17
SFashionDressNormalFailed.FASHION_REPLACE_NOT_OPEN = 18
SFashionDressNormalFailed.THEME_FASHION_NOT_OPEN = 19
SFashionDressNormalFailed.THEME_FASHION_AWARD_ALEARDY = 20
SFashionDressNormalFailed.THEME_FASHION_CFG_NOT_EXIST = 21
SFashionDressNormalFailed.THEME_FASHION_AWARD_CFG_NOT_EXIST = 22
SFashionDressNormalFailed.THEME_FASHION_AWARD_UNLOCK_NUM_NOT_ENOUGH = 23
SFashionDressNormalFailed.THEME_FASHION_AWARD_FAIL = 24
function SFashionDressNormalFailed:ctor(result)
  self.id = 12603152
  self.result = result or nil
end
function SFashionDressNormalFailed:marshal(os)
  os:marshalInt32(self.result)
end
function SFashionDressNormalFailed:unmarshal(os)
  self.result = os:unmarshalInt32()
end
function SFashionDressNormalFailed:sizepolicy(size)
  return size <= 65535
end
return SFashionDressNormalFailed
