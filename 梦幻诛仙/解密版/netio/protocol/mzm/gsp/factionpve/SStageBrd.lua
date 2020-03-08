local SStageBrd = class("SStageBrd")
SStageBrd.TYPEID = 12613634
SStageBrd.ACTIVATE = 0
SStageBrd.FINISH_ACTIVATE = 1
function SStageBrd:ctor(stage)
  self.id = 12613634
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
