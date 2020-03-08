local SWingErrorInfo = class("SWingErrorInfo")
SWingErrorInfo.TYPEID = 12596497
SWingErrorInfo.WING_SCHEMA_ERROR = 1
SWingErrorInfo.WING_PROPERTY_RESET_ITEM_NOT_ENOUGH = 2
SWingErrorInfo.WING_LEVEL_UP_CFG_ERROR = 3
SWingErrorInfo.WING_LEVEL_UP_ROLE_LEVEL_ERROR = 4
SWingErrorInfo.WING_LEVEL_UP_PHASE_ERROR = 5
SWingErrorInfo.WING_PHASE_UP_CFG_ERROR = 6
SWingErrorInfo.WING_PHASE_UP_LEVEL_ERROR = 7
SWingErrorInfo.WING_PHASE_UP_ITEM_NOT_ENOUGH = 8
SWingErrorInfo.YUANBAO_NOT_ENOUGH = 9
SWingErrorInfo.WING_SKILL_RESET_ITEM_NOT_ENOUGH = 10
SWingErrorInfo.WING_DYE_ITEM_NOT_ENOUGH = 11
SWingErrorInfo.WING_MODEL_ERROR = 12
SWingErrorInfo.WING_DYE_ITEM_CFG_ERROR = 13
SWingErrorInfo.NO_PROPERTY_TO_REPLACE = 14
SWingErrorInfo.NO_RIGHT_TO_RESET_PROPERTY = 15
SWingErrorInfo.WING_RESET_SKILL_ITEM_NOT_ENOUGH = 16
SWingErrorInfo.MAIN_SKILL_ERROE = 17
SWingErrorInfo.SUB_SKILL_ERROE = 18
SWingErrorInfo.HAS_SKILL_TO_UNDERSTAND = 19
function SWingErrorInfo:ctor(resCode)
  self.id = 12596497
  self.resCode = resCode or nil
end
function SWingErrorInfo:marshal(os)
  os:marshalInt32(self.resCode)
end
function SWingErrorInfo:unmarshal(os)
  self.resCode = os:unmarshalInt32()
end
function SWingErrorInfo:sizepolicy(size)
  return size <= 65535
end
return SWingErrorInfo
