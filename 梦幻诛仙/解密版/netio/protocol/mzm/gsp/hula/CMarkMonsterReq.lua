local CMarkMonsterReq = class("CMarkMonsterReq")
CMarkMonsterReq.TYPEID = 12608776
function CMarkMonsterReq:ctor(seq, content)
  self.id = 12608776
  self.seq = seq or nil
  self.content = content or nil
end
function CMarkMonsterReq:marshal(os)
  os:marshalInt32(self.seq)
  os:marshalOctets(self.content)
end
function CMarkMonsterReq:unmarshal(os)
  self.seq = os:unmarshalInt32()
  self.content = os:unmarshalOctets()
end
function CMarkMonsterReq:sizepolicy(size)
  return size <= 65535
end
return CMarkMonsterReq
