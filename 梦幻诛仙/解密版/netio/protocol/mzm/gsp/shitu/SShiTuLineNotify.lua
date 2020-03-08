local SShiTuLineNotify = class("SShiTuLineNotify")
SShiTuLineNotify.TYPEID = 12601607
function SShiTuLineNotify:ctor(onlineStatus, profession, professionName)
  self.id = 12601607
  self.onlineStatus = onlineStatus or nil
  self.profession = profession or nil
  self.professionName = professionName or nil
end
function SShiTuLineNotify:marshal(os)
  os:marshalInt32(self.onlineStatus)
  os:marshalInt32(self.profession)
  os:marshalString(self.professionName)
end
function SShiTuLineNotify:unmarshal(os)
  self.onlineStatus = os:unmarshalInt32()
  self.profession = os:unmarshalInt32()
  self.professionName = os:unmarshalString()
end
function SShiTuLineNotify:sizepolicy(size)
  return size <= 65535
end
return SShiTuLineNotify
