local SStageBrd = class("SStageBrd")
SStageBrd.TYPEID = 12596745
SStageBrd.STG_PREPARE = 0
SStageBrd.STG_MATCH_1 = 1
SStageBrd.STG_MATCH_2 = 2
SStageBrd.STG_END = 3
function SStageBrd:ctor(stage)
  self.id = 12596745
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
