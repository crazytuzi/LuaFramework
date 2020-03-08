local CUnEuquipMagicMarkReq = class("CUnEuquipMagicMarkReq")
CUnEuquipMagicMarkReq.TYPEID = 12609546
function CUnEuquipMagicMarkReq:ctor(magicMarkType)
  self.id = 12609546
  self.magicMarkType = magicMarkType or nil
end
function CUnEuquipMagicMarkReq:marshal(os)
  os:marshalInt32(self.magicMarkType)
end
function CUnEuquipMagicMarkReq:unmarshal(os)
  self.magicMarkType = os:unmarshalInt32()
end
function CUnEuquipMagicMarkReq:sizepolicy(size)
  return size <= 65535
end
return CUnEuquipMagicMarkReq
