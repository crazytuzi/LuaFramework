local SFabaoExpTipRes = class("SFabaoExpTipRes")
SFabaoExpTipRes.TYPEID = 12595996
function SFabaoExpTipRes:ctor(fabaoid, exp)
  self.id = 12595996
  self.fabaoid = fabaoid or nil
  self.exp = exp or nil
end
function SFabaoExpTipRes:marshal(os)
  os:marshalInt32(self.fabaoid)
  os:marshalInt32(self.exp)
end
function SFabaoExpTipRes:unmarshal(os)
  self.fabaoid = os:unmarshalInt32()
  self.exp = os:unmarshalInt32()
end
function SFabaoExpTipRes:sizepolicy(size)
  return size <= 65535
end
return SFabaoExpTipRes
