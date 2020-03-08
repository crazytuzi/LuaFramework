local SApplyOrderIDRep = class("SApplyOrderIDRep")
SApplyOrderIDRep.TYPEID = 12588801
function SApplyOrderIDRep:ctor(retcode, cfgId, gameOrderId, orderCallbackURL, ext)
  self.id = 12588801
  self.retcode = retcode or nil
  self.cfgId = cfgId or nil
  self.gameOrderId = gameOrderId or nil
  self.orderCallbackURL = orderCallbackURL or nil
  self.ext = ext or nil
end
function SApplyOrderIDRep:marshal(os)
  os:marshalInt32(self.retcode)
  os:marshalInt32(self.cfgId)
  os:marshalOctets(self.gameOrderId)
  os:marshalOctets(self.orderCallbackURL)
  os:marshalOctets(self.ext)
end
function SApplyOrderIDRep:unmarshal(os)
  self.retcode = os:unmarshalInt32()
  self.cfgId = os:unmarshalInt32()
  self.gameOrderId = os:unmarshalOctets()
  self.orderCallbackURL = os:unmarshalOctets()
  self.ext = os:unmarshalOctets()
end
function SApplyOrderIDRep:sizepolicy(size)
  return size <= 4096
end
return SApplyOrderIDRep
