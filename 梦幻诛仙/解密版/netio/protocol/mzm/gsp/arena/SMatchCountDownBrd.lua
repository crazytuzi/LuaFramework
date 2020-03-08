local SMatchCountDownBrd = class("SMatchCountDownBrd")
SMatchCountDownBrd.TYPEID = 12596753
function SMatchCountDownBrd:ctor(countdown)
  self.id = 12596753
  self.countdown = countdown or nil
end
function SMatchCountDownBrd:marshal(os)
  os:marshalInt32(self.countdown)
end
function SMatchCountDownBrd:unmarshal(os)
  self.countdown = os:unmarshalInt32()
end
function SMatchCountDownBrd:sizepolicy(size)
  return size <= 65535
end
return SMatchCountDownBrd
