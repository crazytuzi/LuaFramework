local SDelFailureOrderRep = class("SDelFailureOrderRep")
SDelFailureOrderRep.TYPEID = 12588804
function SDelFailureOrderRep:ctor(retcode, gameOrderId)
  self.id = 12588804
  self.retcode = retcode or nil
  self.gameOrderId = gameOrderId or nil
end
function SDelFailureOrderRep:marshal(os)
  os:marshalInt32(self.retcode)
  os:marshalOctets(self.gameOrderId)
end
function SDelFailureOrderRep:unmarshal(os)
  self.retcode = os:unmarshalInt32()
  self.gameOrderId = os:unmarshalOctets()
end
function SDelFailureOrderRep:sizepolicy(size)
  return size <= 65535
end
return SDelFailureOrderRep
