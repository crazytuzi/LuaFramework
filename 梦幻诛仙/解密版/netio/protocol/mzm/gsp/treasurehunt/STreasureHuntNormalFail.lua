local STreasureHuntNormalFail = class("STreasureHuntNormalFail")
STreasureHuntNormalFail.TYPEID = 12633090
STreasureHuntNormalFail.ERROR_ACTIVITY_CFG_NOT_EXIST = 1
STreasureHuntNormalFail.ERROR_USER_INFO_NOT_EXIST = 2
STreasureHuntNormalFail.ERROR_ACTIVITY_CAN_NOT_TAKE_IN = 3
STreasureHuntNormalFail.ERROR_IN_OLD_TREASURE_WORLD = 4
STreasureHuntNormalFail.ERROR_TREASURE_ALEARDY_PASS = 5
STreasureHuntNormalFail.ERROR_TREASURE_CHAPTER_NOT_EXIST = 6
STreasureHuntNormalFail.ERROR_CURRENT_CHAPTER_NOT_EXIST = 7
STreasureHuntNormalFail.ERROR_ROLE_TREASURE_DATA_NOT_EXIST = 8
STreasureHuntNormalFail.ERROR_SESSION_NOT_EXIST = 9
STreasureHuntNormalFail.ERROR_STATUS_CAN_NOT_TACK_PART = 10
STreasureHuntNormalFail.ERROR_SET_STATUS = 11
STreasureHuntNormalFail.ERROR_TREASURE_HUNT_FAIL = 12
STreasureHuntNormalFail.ERROR_FUNCTION_NOT_OPEN = 13
STreasureHuntNormalFail.ERROR_TODAY_ACTIVITY_COUNT_MAX = 14
STreasureHuntNormalFail.ERROR_NPC_SERVICE_NOT_VALID = 15
STreasureHuntNormalFail.ERROR_TREASURE_HUNT_CAN_NOT_JOIN = 16
STreasureHuntNormalFail.ERROR_IN_TREASURE_HUNT_CAN_NOT_JOIN = 17
function STreasureHuntNormalFail:ctor(result)
  self.id = 12633090
  self.result = result or nil
end
function STreasureHuntNormalFail:marshal(os)
  os:marshalInt32(self.result)
end
function STreasureHuntNormalFail:unmarshal(os)
  self.result = os:unmarshalInt32()
end
function STreasureHuntNormalFail:sizepolicy(size)
  return size <= 65535
end
return STreasureHuntNormalFail
