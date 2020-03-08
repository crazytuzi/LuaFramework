local SUnEuquipMagicMarkRes = class("SUnEuquipMagicMarkRes")
SUnEuquipMagicMarkRes.TYPEID = 12609539
SUnEuquipMagicMarkRes.SUCCESS = 1
SUnEuquipMagicMarkRes.ERROR_NOT_EQUIP = 2
SUnEuquipMagicMarkRes.ERROR_ROLE_LEVEL_NOT_ENOUGH = 3
function SUnEuquipMagicMarkRes:ctor(ret, magicMarkType)
  self.id = 12609539
  self.ret = ret or nil
  self.magicMarkType = magicMarkType or nil
end
function SUnEuquipMagicMarkRes:marshal(os)
  os:marshalInt32(self.ret)
  os:marshalInt32(self.magicMarkType)
end
function SUnEuquipMagicMarkRes:unmarshal(os)
  self.ret = os:unmarshalInt32()
  self.magicMarkType = os:unmarshalInt32()
end
function SUnEuquipMagicMarkRes:sizepolicy(size)
  return size <= 65535
end
return SUnEuquipMagicMarkRes
