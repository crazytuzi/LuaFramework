local CDrawReq = class("CDrawReq")
CDrawReq.TYPEID = 12630017
function CDrawReq:ctor(pass_type_id, pass_count, is_use_yuan_bao)
  self.id = 12630017
  self.pass_type_id = pass_type_id or nil
  self.pass_count = pass_count or nil
  self.is_use_yuan_bao = is_use_yuan_bao or nil
end
function CDrawReq:marshal(os)
  os:marshalInt32(self.pass_type_id)
  os:marshalInt32(self.pass_count)
  os:marshalUInt8(self.is_use_yuan_bao)
end
function CDrawReq:unmarshal(os)
  self.pass_type_id = os:unmarshalInt32()
  self.pass_count = os:unmarshalInt32()
  self.is_use_yuan_bao = os:unmarshalUInt8()
end
function CDrawReq:sizepolicy(size)
  return size <= 65535
end
return CDrawReq
