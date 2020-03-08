local SSetMessageStateFail = class("SSetMessageStateFail")
SSetMessageStateFail.TYPEID = 12605216
SSetMessageStateFail.GROUP_NOT_EXIST = 1
SSetMessageStateFail.NOT_IN_GROUP = 2
function SSetMessageStateFail:ctor(res)
  self.id = 12605216
  self.res = res or nil
end
function SSetMessageStateFail:marshal(os)
  os:marshalInt32(self.res)
end
function SSetMessageStateFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SSetMessageStateFail:sizepolicy(size)
  return size <= 65535
end
return SSetMessageStateFail
