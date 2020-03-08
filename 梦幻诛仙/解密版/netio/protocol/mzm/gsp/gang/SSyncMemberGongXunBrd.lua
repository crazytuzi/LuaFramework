local SSyncMemberGongXunBrd = class("SSyncMemberGongXunBrd")
SSyncMemberGongXunBrd.TYPEID = 12589956
function SSyncMemberGongXunBrd:ctor(memberid, gongXun)
  self.id = 12589956
  self.memberid = memberid or nil
  self.gongXun = gongXun or nil
end
function SSyncMemberGongXunBrd:marshal(os)
  os:marshalInt64(self.memberid)
  os:marshalInt32(self.gongXun)
end
function SSyncMemberGongXunBrd:unmarshal(os)
  self.memberid = os:unmarshalInt64()
  self.gongXun = os:unmarshalInt32()
end
function SSyncMemberGongXunBrd:sizepolicy(size)
  return size <= 65535
end
return SSyncMemberGongXunBrd
