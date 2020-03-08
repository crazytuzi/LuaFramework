local CMarryReq = class("CMarryReq")
CMarryReq.TYPEID = 12599812
CMarryReq.UNUSE_YUANBAO = 0
CMarryReq.USE_YUANBAO_REPLACE_ITEM = 1
function CMarryReq:ctor(level, useYuanBao)
  self.id = 12599812
  self.level = level or nil
  self.useYuanBao = useYuanBao or nil
end
function CMarryReq:marshal(os)
  os:marshalInt32(self.level)
  os:marshalInt32(self.useYuanBao)
end
function CMarryReq:unmarshal(os)
  self.level = os:unmarshalInt32()
  self.useYuanBao = os:unmarshalInt32()
end
function CMarryReq:sizepolicy(size)
  return size <= 65535
end
return CMarryReq
