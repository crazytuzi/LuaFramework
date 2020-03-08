local SCreateGroupFail = class("SCreateGroupFail")
SCreateGroupFail.TYPEID = 12605211
SCreateGroupFail.LEVEL_NOT_ENOUGH = 1
SCreateGroupFail.CREATE_NUM_TO_LIMIT = 2
SCreateGroupFail.GROUP_NAME_ILLEGAL = 3
SCreateGroupFail.GROUP_TYPE_ILLEGAL = 4
function SCreateGroupFail:ctor(res)
  self.id = 12605211
  self.res = res or nil
end
function SCreateGroupFail:marshal(os)
  os:marshalInt32(self.res)
end
function SCreateGroupFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SCreateGroupFail:sizepolicy(size)
  return size <= 65535
end
return SCreateGroupFail
