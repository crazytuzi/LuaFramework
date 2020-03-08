local SBanTradeRes = class("SBanTradeRes")
SBanTradeRes.TYPEID = 12584847
function SBanTradeRes:ctor(name)
  self.id = 12584847
  self.name = name or nil
end
function SBanTradeRes:marshal(os)
  os:marshalOctets(self.name)
end
function SBanTradeRes:unmarshal(os)
  self.name = os:unmarshalOctets()
end
function SBanTradeRes:sizepolicy(size)
  return size <= 65535
end
return SBanTradeRes
