local CMagicMarkSelectPropReq = class("CMagicMarkSelectPropReq")
CMagicMarkSelectPropReq.TYPEID = 12609551
function CMagicMarkSelectPropReq:ctor(magicMarkType)
  self.id = 12609551
  self.magicMarkType = magicMarkType or nil
end
function CMagicMarkSelectPropReq:marshal(os)
  os:marshalInt32(self.magicMarkType)
end
function CMagicMarkSelectPropReq:unmarshal(os)
  self.magicMarkType = os:unmarshalInt32()
end
function CMagicMarkSelectPropReq:sizepolicy(size)
  return size <= 65535
end
return CMagicMarkSelectPropReq
