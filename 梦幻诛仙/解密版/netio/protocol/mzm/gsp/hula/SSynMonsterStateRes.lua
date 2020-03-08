local SSynMonsterStateRes = class("SSynMonsterStateRes")
SSynMonsterStateRes.TYPEID = 12608782
function SSynMonsterStateRes:ctor(state, seq)
  self.id = 12608782
  self.state = state or nil
  self.seq = seq or nil
end
function SSynMonsterStateRes:marshal(os)
  os:marshalInt32(self.state)
  os:marshalInt32(self.seq)
end
function SSynMonsterStateRes:unmarshal(os)
  self.state = os:unmarshalInt32()
  self.seq = os:unmarshalInt32()
end
function SSynMonsterStateRes:sizepolicy(size)
  return size <= 65535
end
return SSynMonsterStateRes
