local SQueryBoughtMoralValueRes = class("SQueryBoughtMoralValueRes")
SQueryBoughtMoralValueRes.TYPEID = 12619804
function SQueryBoughtMoralValueRes:ctor(bought_moral_value)
  self.id = 12619804
  self.bought_moral_value = bought_moral_value or nil
end
function SQueryBoughtMoralValueRes:marshal(os)
  os:marshalInt32(self.bought_moral_value)
end
function SQueryBoughtMoralValueRes:unmarshal(os)
  self.bought_moral_value = os:unmarshalInt32()
end
function SQueryBoughtMoralValueRes:sizepolicy(size)
  return size <= 65535
end
return SQueryBoughtMoralValueRes
