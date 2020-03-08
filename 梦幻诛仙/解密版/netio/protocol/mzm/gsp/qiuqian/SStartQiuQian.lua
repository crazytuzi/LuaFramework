local SStartQiuQian = class("SStartQiuQian")
SStartQiuQian.TYPEID = 12610817
function SStartQiuQian:ctor(qiuqian_id, sessionid)
  self.id = 12610817
  self.qiuqian_id = qiuqian_id or nil
  self.sessionid = sessionid or nil
end
function SStartQiuQian:marshal(os)
  os:marshalInt32(self.qiuqian_id)
  os:marshalInt64(self.sessionid)
end
function SStartQiuQian:unmarshal(os)
  self.qiuqian_id = os:unmarshalInt32()
  self.sessionid = os:unmarshalInt64()
end
function SStartQiuQian:sizepolicy(size)
  return size <= 65535
end
return SStartQiuQian
