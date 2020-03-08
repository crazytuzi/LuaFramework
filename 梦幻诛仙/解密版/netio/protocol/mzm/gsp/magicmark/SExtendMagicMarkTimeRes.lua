local SExtendMagicMarkTimeRes = class("SExtendMagicMarkTimeRes")
SExtendMagicMarkTimeRes.TYPEID = 12609542
function SExtendMagicMarkTimeRes:ctor(magicMarkType, expiredTime)
  self.id = 12609542
  self.magicMarkType = magicMarkType or nil
  self.expiredTime = expiredTime or nil
end
function SExtendMagicMarkTimeRes:marshal(os)
  os:marshalInt32(self.magicMarkType)
  os:marshalInt64(self.expiredTime)
end
function SExtendMagicMarkTimeRes:unmarshal(os)
  self.magicMarkType = os:unmarshalInt32()
  self.expiredTime = os:unmarshalInt64()
end
function SExtendMagicMarkTimeRes:sizepolicy(size)
  return size <= 65535
end
return SExtendMagicMarkTimeRes
