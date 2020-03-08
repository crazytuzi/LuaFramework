local SCreateLifeSkillItemFailed = class("SCreateLifeSkillItemFailed")
SCreateLifeSkillItemFailed.TYPEID = 12626691
SCreateLifeSkillItemFailed.ERROR_SYSTEM = -1
SCreateLifeSkillItemFailed.ERROR_USERID = -2
SCreateLifeSkillItemFailed.ERROR_CFG = -3
SCreateLifeSkillItemFailed.ERROR_BAG_FULL = -4
SCreateLifeSkillItemFailed.ERROR_CAN_NOT_JOIN_ACTIVITY = -5
SCreateLifeSkillItemFailed.ERROR_MAX_NUM = -6
SCreateLifeSkillItemFailed.ERROR_NOT_NEAR_NPC = -7
SCreateLifeSkillItemFailed.ERROR_NPC_SERVICE = -8
SCreateLifeSkillItemFailed.ERROR_SERVER_LEVEL_LESS = -9
SCreateLifeSkillItemFailed.ERROR_NOT_IN_GANG = -10
SCreateLifeSkillItemFailed.ERROR_LIVELY_LOW_RATE_LESS = -11
SCreateLifeSkillItemFailed.ERROR_YAODIAN_LEVEL_LESS = -12
SCreateLifeSkillItemFailed.ERROR_LIFE_SKILL_LEVEL = -13
SCreateLifeSkillItemFailed.ERROR_VIGOR_NOT_ENOUGH = -14
SCreateLifeSkillItemFailed.ERROR_PAY_NOT_ENOUGH = -15
function SCreateLifeSkillItemFailed:ctor(activity_cfgid, retcode)
  self.id = 12626691
  self.activity_cfgid = activity_cfgid or nil
  self.retcode = retcode or nil
end
function SCreateLifeSkillItemFailed:marshal(os)
  os:marshalInt32(self.activity_cfgid)
  os:marshalInt32(self.retcode)
end
function SCreateLifeSkillItemFailed:unmarshal(os)
  self.activity_cfgid = os:unmarshalInt32()
  self.retcode = os:unmarshalInt32()
end
function SCreateLifeSkillItemFailed:sizepolicy(size)
  return size <= 65535
end
return SCreateLifeSkillItemFailed
