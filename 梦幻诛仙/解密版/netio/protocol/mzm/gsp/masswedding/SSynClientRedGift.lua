local SSynClientRedGift = class("SSynClientRedGift")
SSynClientRedGift.TYPEID = 12604938
function SSynClientRedGift:ctor(redgiftCfgid)
  self.id = 12604938
  self.redgiftCfgid = redgiftCfgid or nil
end
function SSynClientRedGift:marshal(os)
  os:marshalInt32(self.redgiftCfgid)
end
function SSynClientRedGift:unmarshal(os)
  self.redgiftCfgid = os:unmarshalInt32()
end
function SSynClientRedGift:sizepolicy(size)
  return size <= 65535
end
return SSynClientRedGift
