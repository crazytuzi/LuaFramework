local CSeekHelpFromGangReq = class("CSeekHelpFromGangReq")
CSeekHelpFromGangReq.TYPEID = 12584450
function CSeekHelpFromGangReq:ctor(itemIndex)
  self.id = 12584450
  self.itemIndex = itemIndex or nil
end
function CSeekHelpFromGangReq:marshal(os)
  os:marshalInt32(self.itemIndex)
end
function CSeekHelpFromGangReq:unmarshal(os)
  self.itemIndex = os:unmarshalInt32()
end
function CSeekHelpFromGangReq:sizepolicy(size)
  return size <= 65535
end
return CSeekHelpFromGangReq
