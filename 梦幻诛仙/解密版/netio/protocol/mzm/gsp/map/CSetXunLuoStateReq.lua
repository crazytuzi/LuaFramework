local CSetXunLuoStateReq = class("CSetXunLuoStateReq")
CSetXunLuoStateReq.TYPEID = 12590896
CSetXunLuoStateReq.UN_SET = 0
CSetXunLuoStateReq.SET = 1
function CSetXunLuoStateReq:ctor(state)
  self.id = 12590896
  self.state = state or nil
end
function CSetXunLuoStateReq:marshal(os)
  os:marshalInt32(self.state)
end
function CSetXunLuoStateReq:unmarshal(os)
  self.state = os:unmarshalInt32()
end
function CSetXunLuoStateReq:sizepolicy(size)
  return size <= 65535
end
return CSetXunLuoStateReq
