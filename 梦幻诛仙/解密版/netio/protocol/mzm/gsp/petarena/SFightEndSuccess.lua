local SFightEndSuccess = class("SFightEndSuccess")
SFightEndSuccess.TYPEID = 12628254
function SFightEndSuccess:ctor(add_point, point, today_point)
  self.id = 12628254
  self.add_point = add_point or nil
  self.point = point or nil
  self.today_point = today_point or nil
end
function SFightEndSuccess:marshal(os)
  os:marshalInt32(self.add_point)
  os:marshalInt32(self.point)
  os:marshalInt32(self.today_point)
end
function SFightEndSuccess:unmarshal(os)
  self.add_point = os:unmarshalInt32()
  self.point = os:unmarshalInt32()
  self.today_point = os:unmarshalInt32()
end
function SFightEndSuccess:sizepolicy(size)
  return size <= 65535
end
return SFightEndSuccess
