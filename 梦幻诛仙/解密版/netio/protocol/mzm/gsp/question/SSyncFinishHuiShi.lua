local SSyncFinishHuiShi = class("SSyncFinishHuiShi")
SSyncFinishHuiShi.TYPEID = 12594709
function SSyncFinishHuiShi:ctor(isPass)
  self.id = 12594709
  self.isPass = isPass or nil
end
function SSyncFinishHuiShi:marshal(os)
  os:marshalInt32(self.isPass)
end
function SSyncFinishHuiShi:unmarshal(os)
  self.isPass = os:unmarshalInt32()
end
function SSyncFinishHuiShi:sizepolicy(size)
  return size <= 65535
end
return SSyncFinishHuiShi
