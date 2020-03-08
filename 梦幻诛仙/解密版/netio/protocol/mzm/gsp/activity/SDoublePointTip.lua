local SDoublePointTip = class("SDoublePointTip")
SDoublePointTip.TYPEID = 12587546
function SDoublePointTip:ctor(pointnum)
  self.id = 12587546
  self.pointnum = pointnum or nil
end
function SDoublePointTip:marshal(os)
  os:marshalInt32(self.pointnum)
end
function SDoublePointTip:unmarshal(os)
  self.pointnum = os:unmarshalInt32()
end
function SDoublePointTip:sizepolicy(size)
  return size <= 65535
end
return SDoublePointTip
