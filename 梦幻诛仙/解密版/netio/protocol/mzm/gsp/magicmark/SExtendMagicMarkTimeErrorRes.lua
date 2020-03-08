local SExtendMagicMarkTimeErrorRes = class("SExtendMagicMarkTimeErrorRes")
SExtendMagicMarkTimeErrorRes.TYPEID = 12609545
SExtendMagicMarkTimeErrorRes.ERROR_ITEM_MAGIC_MARK_TYPE_NOT_SAME = 1
SExtendMagicMarkTimeErrorRes.ERROR_ITEM_NOT_ENOUGH = 2
SExtendMagicMarkTimeErrorRes.ERROR_ROLE_LEVEL_NOT_ENOUGH = 3
SExtendMagicMarkTimeErrorRes.ERROR_DO_NOT_NEED_EXTEND = 4
function SExtendMagicMarkTimeErrorRes:ctor(ret)
  self.id = 12609545
  self.ret = ret or nil
end
function SExtendMagicMarkTimeErrorRes:marshal(os)
  os:marshalInt32(self.ret)
end
function SExtendMagicMarkTimeErrorRes:unmarshal(os)
  self.ret = os:unmarshalInt32()
end
function SExtendMagicMarkTimeErrorRes:sizepolicy(size)
  return size <= 65535
end
return SExtendMagicMarkTimeErrorRes
