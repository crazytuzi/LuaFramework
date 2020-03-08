local SCatRenameFailed = class("SCatRenameFailed")
SCatRenameFailed.TYPEID = 12605714
SCatRenameFailed.NAME_INVALID = -1
SCatRenameFailed.NAME_TOO_SHORT = -2
SCatRenameFailed.NAME_TOO_LONG = -3
function SCatRenameFailed:ctor(retcode)
  self.id = 12605714
  self.retcode = retcode or nil
end
function SCatRenameFailed:marshal(os)
  os:marshalInt32(self.retcode)
end
function SCatRenameFailed:unmarshal(os)
  self.retcode = os:unmarshalInt32()
end
function SCatRenameFailed:sizepolicy(size)
  return size <= 65535
end
return SCatRenameFailed
