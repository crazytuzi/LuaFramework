local SMagicMarkSelectPropRes = class("SMagicMarkSelectPropRes")
SMagicMarkSelectPropRes.TYPEID = 12609548
SMagicMarkSelectPropRes.SUCCESS = 1
SMagicMarkSelectPropRes.ERROR_LOCKED = 2
SMagicMarkSelectPropRes.ERROR_ROLE_LEVEL_NOT_ENOUGH = 3
function SMagicMarkSelectPropRes:ctor(ret, magicMarkType)
  self.id = 12609548
  self.ret = ret or nil
  self.magicMarkType = magicMarkType or nil
end
function SMagicMarkSelectPropRes:marshal(os)
  os:marshalInt32(self.ret)
  os:marshalInt32(self.magicMarkType)
end
function SMagicMarkSelectPropRes:unmarshal(os)
  self.ret = os:unmarshalInt32()
  self.magicMarkType = os:unmarshalInt32()
end
function SMagicMarkSelectPropRes:sizepolicy(size)
  return size <= 65535
end
return SMagicMarkSelectPropRes
