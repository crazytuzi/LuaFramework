local KeyExchange = class("KeyExchange")
KeyExchange.TYPEID = 106
function KeyExchange:ctor(nonce, blkickuser)
  self.id = 106
  self.nonce = nonce or nil
  self.blkickuser = blkickuser or nil
end
function KeyExchange:marshal(os)
  os:marshalOctets(self.nonce)
  os:marshalInt32(self.blkickuser)
end
function KeyExchange:unmarshal(os)
  self.nonce = os:unmarshalOctets()
  self.blkickuser = os:unmarshalInt32()
end
function KeyExchange:sizepolicy(size)
  return size <= 32
end
return KeyExchange
