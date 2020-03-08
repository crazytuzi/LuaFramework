local SBothGiveUpBrd = class("SBothGiveUpBrd")
SBothGiveUpBrd.TYPEID = 12616714
function SBothGiveUpBrd:ctor(id1, name1, id2, name2)
  self.id = 12616714
  self.id1 = id1 or nil
  self.name1 = name1 or nil
  self.id2 = id2 or nil
  self.name2 = name2 or nil
end
function SBothGiveUpBrd:marshal(os)
  os:marshalInt64(self.id1)
  os:marshalString(self.name1)
  os:marshalInt64(self.id2)
  os:marshalString(self.name2)
end
function SBothGiveUpBrd:unmarshal(os)
  self.id1 = os:unmarshalInt64()
  self.name1 = os:unmarshalString()
  self.id2 = os:unmarshalInt64()
  self.name2 = os:unmarshalString()
end
function SBothGiveUpBrd:sizepolicy(size)
  return size <= 65535
end
return SBothGiveUpBrd
