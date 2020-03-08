local SStartShangGong = class("SStartShangGong")
SStartShangGong.TYPEID = 12610561
function SStartShangGong:ctor(shanggong_id, sessionid)
  self.id = 12610561
  self.shanggong_id = shanggong_id or nil
  self.sessionid = sessionid or nil
end
function SStartShangGong:marshal(os)
  os:marshalInt32(self.shanggong_id)
  os:marshalInt64(self.sessionid)
end
function SStartShangGong:unmarshal(os)
  self.shanggong_id = os:unmarshalInt32()
  self.sessionid = os:unmarshalInt64()
end
function SStartShangGong:sizepolicy(size)
  return size <= 65535
end
return SStartShangGong
