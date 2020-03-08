local SMemberLoginRes = class("SMemberLoginRes")
SMemberLoginRes.TYPEID = 12597817
function SMemberLoginRes:ctor(memberid)
  self.id = 12597817
  self.memberid = memberid or nil
end
function SMemberLoginRes:marshal(os)
  os:marshalInt64(self.memberid)
end
function SMemberLoginRes:unmarshal(os)
  self.memberid = os:unmarshalInt64()
end
function SMemberLoginRes:sizepolicy(size)
  return size <= 65535
end
return SMemberLoginRes
