local SSyncRejectJoinGang = class("SSyncRejectJoinGang")
SSyncRejectJoinGang.TYPEID = 12589856
function SSyncRejectJoinGang:ctor(rejectName)
  self.id = 12589856
  self.rejectName = rejectName or nil
end
function SSyncRejectJoinGang:marshal(os)
  os:marshalString(self.rejectName)
end
function SSyncRejectJoinGang:unmarshal(os)
  self.rejectName = os:unmarshalString()
end
function SSyncRejectJoinGang:sizepolicy(size)
  return size <= 65535
end
return SSyncRejectJoinGang
