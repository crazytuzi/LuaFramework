local SQuitGroupFail = class("SQuitGroupFail")
SQuitGroupFail.TYPEID = 12605194
SQuitGroupFail.GROUP_NOT_EXIST = 1
SQuitGroupFail.NOT_IN_GROUP = 2
SQuitGroupFail.MASTER_CANNOT_QUIT = 3
function SQuitGroupFail:ctor(res)
  self.id = 12605194
  self.res = res or nil
end
function SQuitGroupFail:marshal(os)
  os:marshalInt32(self.res)
end
function SQuitGroupFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SQuitGroupFail:sizepolicy(size)
  return size <= 65535
end
return SQuitGroupFail
