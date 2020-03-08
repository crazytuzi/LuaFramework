local SStageBrd = class("SStageBrd")
SStageBrd.TYPEID = 12616705
SStageBrd.STG_SIGN_UP = 0
SStageBrd.STG_MATCH = 1
SStageBrd.STG_WAIT_REMIND = 2
SStageBrd.STG_WAIT_COMPETE = 3
SStageBrd.STG_EARLY_CREATE_FACTION_1 = 4
SStageBrd.STG_PREPARE_1 = 5
SStageBrd.STG_FIGHT_1 = 6
SStageBrd.STG_FORCE_END_1 = 7
SStageBrd.STG_REST = 8
SStageBrd.STG_EARLY_CREATE_FACTION_2 = 9
SStageBrd.STG_PREPARE_2 = 10
SStageBrd.STG_FIGHT_2 = 11
SStageBrd.STG_FORCE_END_2 = 12
SStageBrd.STG_END = 13
function SStageBrd:ctor(stage)
  self.id = 12616705
  self.stage = stage or nil
end
function SStageBrd:marshal(os)
  os:marshalInt32(self.stage)
end
function SStageBrd:unmarshal(os)
  self.stage = os:unmarshalInt32()
end
function SStageBrd:sizepolicy(size)
  return size <= 65535
end
return SStageBrd
