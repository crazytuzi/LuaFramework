local SWingNormalResult = class("SWingNormalResult")
SWingNormalResult.TYPEID = 12596533
SWingNormalResult.NOT_OWN_THIS_WING = 1
SWingNormalResult.NOT_ENOUGH_YUANBAO = 2
SWingNormalResult.ALREADY_OWN_THIS_WING = 3
SWingNormalResult.ADD_EXP__NOT_ENOUGH_ITEM = 4
SWingNormalResult.ADD_RANK__NOT_ENOUGH_ITEM = 5
SWingNormalResult.COLOR__NOT_ENOUGH_ITEM = 6
SWingNormalResult.RESET__NOT_ENOUGH_ITEM = 7
SWingNormalResult.ROLE_LV__NOT_ENOUGH = 8
SWingNormalResult.WING_LV__NOT_ENOUGH = 9
SWingNormalResult.WING_RANK__NOT_ENOUGH = 10
SWingNormalResult.NOT_OPEN_WING = 11
SWingNormalResult.REPEATED_SKILLS = 12
SWingNormalResult.NO_MORE_SKILLS_TO_RAN = 13
SWingNormalResult.TARGET_SKILL_INDEX_ILLEGAL = 14
SWingNormalResult.TARGET_SKILL_ALREADY_OWN = 15
SWingNormalResult.TARGET_SKILL_NOT_EXIST = 16
SWingNormalResult.TARGET_SKILL_ALREADY_SET = 17
SWingNormalResult.CHECK_ROLE_WING_INFO__DIFF_SERVER = 18
SWingNormalResult.CHECK_ROLE_WING_INFO__NOT_EXIST = 19
SWingNormalResult.CHANGE_WING_OCC_PLAN_ERR__NOT_OPEN_THIS_OCCUPATION = 20
function SWingNormalResult:ctor(result, args)
  self.id = 12596533
  self.result = result or nil
  self.args = args or {}
end
function SWingNormalResult:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SWingNormalResult:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SWingNormalResult:sizepolicy(size)
  return size <= 65535
end
return SWingNormalResult
