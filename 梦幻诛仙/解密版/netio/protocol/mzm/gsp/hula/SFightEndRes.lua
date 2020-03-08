local SFightEndRes = class("SFightEndRes")
SFightEndRes.TYPEID = 12608771
function SFightEndRes:ctor(seq, result)
  self.id = 12608771
  self.seq = seq or nil
  self.result = result or nil
end
function SFightEndRes:marshal(os)
  os:marshalInt32(self.seq)
  os:marshalInt32(self.result)
end
function SFightEndRes:unmarshal(os)
  self.seq = os:unmarshalInt32()
  self.result = os:unmarshalInt32()
end
function SFightEndRes:sizepolicy(size)
  return size <= 65535
end
return SFightEndRes
