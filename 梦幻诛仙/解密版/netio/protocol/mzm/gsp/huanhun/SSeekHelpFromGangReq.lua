local SSeekHelpFromGangReq = class("SSeekHelpFromGangReq")
SSeekHelpFromGangReq.TYPEID = 12584462
function SSeekHelpFromGangReq:ctor(itemIndex)
  self.id = 12584462
  self.itemIndex = itemIndex or nil
end
function SSeekHelpFromGangReq:marshal(os)
  os:marshalInt32(self.itemIndex)
end
function SSeekHelpFromGangReq:unmarshal(os)
  self.itemIndex = os:unmarshalInt32()
end
function SSeekHelpFromGangReq:sizepolicy(size)
  return size <= 65535
end
return SSeekHelpFromGangReq
