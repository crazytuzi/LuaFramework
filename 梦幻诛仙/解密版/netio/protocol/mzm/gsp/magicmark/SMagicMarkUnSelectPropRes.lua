local SMagicMarkUnSelectPropRes = class("SMagicMarkUnSelectPropRes")
SMagicMarkUnSelectPropRes.TYPEID = 12609541
SMagicMarkUnSelectPropRes.SUCCESS = 1
SMagicMarkUnSelectPropRes.ERROR_NOT_SELECT = 2
SMagicMarkUnSelectPropRes.ERROR_ROLE_LEVEL_NOT_ENOUGH = 3
function SMagicMarkUnSelectPropRes:ctor(ret, magicMarkType)
  self.id = 12609541
  self.ret = ret or nil
  self.magicMarkType = magicMarkType or nil
end
function SMagicMarkUnSelectPropRes:marshal(os)
  os:marshalInt32(self.ret)
  os:marshalInt32(self.magicMarkType)
end
function SMagicMarkUnSelectPropRes:unmarshal(os)
  self.ret = os:unmarshalInt32()
  self.magicMarkType = os:unmarshalInt32()
end
function SMagicMarkUnSelectPropRes:sizepolicy(size)
  return size <= 65535
end
return SMagicMarkUnSelectPropRes
