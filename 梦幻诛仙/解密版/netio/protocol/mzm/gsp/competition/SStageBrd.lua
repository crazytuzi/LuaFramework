local SStageBrd = class("SStageBrd")
SStageBrd.TYPEID = 12598531
SStageBrd.STG_NOTIFY = -1
SStageBrd.STG_PREPARE = 0
SStageBrd.STG_COMPETE_WAIT = 1
SStageBrd.STG_COMPETE_NORMAL = 2
SStageBrd.STG_COMPETE_NO_ENTER = 3
SStageBrd.STG_TRIGGER_MAP_ITEM = 4
function SStageBrd:ctor(stage)
  self.id = 12598531
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
