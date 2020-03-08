local COperateReq = class("COperateReq")
COperateReq.TYPEID = 12594193
function COperateReq:ctor(fighterid, op_type, content)
  self.id = 12594193
  self.fighterid = fighterid or nil
  self.op_type = op_type or nil
  self.content = content or nil
end
function COperateReq:marshal(os)
  os:marshalInt32(self.fighterid)
  os:marshalInt32(self.op_type)
  os:marshalOctets(self.content)
end
function COperateReq:unmarshal(os)
  self.fighterid = os:unmarshalInt32()
  self.op_type = os:unmarshalInt32()
  self.content = os:unmarshalOctets()
end
function COperateReq:sizepolicy(size)
  return size <= 65535
end
return COperateReq
