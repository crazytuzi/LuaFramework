local CMagicMarkUnSelectPropReq = class("CMagicMarkUnSelectPropReq")
CMagicMarkUnSelectPropReq.TYPEID = 12609537
function CMagicMarkUnSelectPropReq:ctor(magicMarkType)
  self.id = 12609537
  self.magicMarkType = magicMarkType or nil
end
function CMagicMarkUnSelectPropReq:marshal(os)
  os:marshalInt32(self.magicMarkType)
end
function CMagicMarkUnSelectPropReq:unmarshal(os)
  self.magicMarkType = os:unmarshalInt32()
end
function CMagicMarkUnSelectPropReq:sizepolicy(size)
  return size <= 65535
end
return CMagicMarkUnSelectPropReq
