local SEquipMagicMarkRes = class("SEquipMagicMarkRes")
SEquipMagicMarkRes.TYPEID = 12609538
SEquipMagicMarkRes.SUCCESS = 1
SEquipMagicMarkRes.ERROR_MAGIC_MARK_LOCKED = 2
SEquipMagicMarkRes.ERROR_ROLE_LEVEL_NOT_ENOUGH = 3
function SEquipMagicMarkRes:ctor(ret, magicMarkType)
  self.id = 12609538
  self.ret = ret or nil
  self.magicMarkType = magicMarkType or nil
end
function SEquipMagicMarkRes:marshal(os)
  os:marshalInt32(self.ret)
  os:marshalInt32(self.magicMarkType)
end
function SEquipMagicMarkRes:unmarshal(os)
  self.ret = os:unmarshalInt32()
  self.magicMarkType = os:unmarshalInt32()
end
function SEquipMagicMarkRes:sizepolicy(size)
  return size <= 65535
end
return SEquipMagicMarkRes
