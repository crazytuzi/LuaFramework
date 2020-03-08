local SStageBrd = class("SStageBrd")
SStageBrd.TYPEID = 12596234
SStageBrd.STG_PREPARE = 0
SStageBrd.STG_MATCH = 1
SStageBrd.STG_FINISH_MATCH = 2
function SStageBrd:ctor(stage)
  self.id = 12596234
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
