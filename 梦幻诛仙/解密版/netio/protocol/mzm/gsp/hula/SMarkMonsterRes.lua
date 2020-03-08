local SMarkMonsterRes = class("SMarkMonsterRes")
SMarkMonsterRes.TYPEID = 12608774
function SMarkMonsterRes:ctor(seq, content)
  self.id = 12608774
  self.seq = seq or nil
  self.content = content or nil
end
function SMarkMonsterRes:marshal(os)
  os:marshalInt32(self.seq)
  os:marshalOctets(self.content)
end
function SMarkMonsterRes:unmarshal(os)
  self.seq = os:unmarshalInt32()
  self.content = os:unmarshalOctets()
end
function SMarkMonsterRes:sizepolicy(size)
  return size <= 65535
end
return SMarkMonsterRes
