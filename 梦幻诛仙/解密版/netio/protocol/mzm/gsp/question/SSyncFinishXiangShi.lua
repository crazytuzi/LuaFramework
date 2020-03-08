local SSyncFinishXiangShi = class("SSyncFinishXiangShi")
SSyncFinishXiangShi.TYPEID = 12594710
function SSyncFinishXiangShi:ctor(isPass)
  self.id = 12594710
  self.isPass = isPass or nil
end
function SSyncFinishXiangShi:marshal(os)
  os:marshalInt32(self.isPass)
end
function SSyncFinishXiangShi:unmarshal(os)
  self.isPass = os:unmarshalInt32()
end
function SSyncFinishXiangShi:sizepolicy(size)
  return size <= 65535
end
return SSyncFinishXiangShi
