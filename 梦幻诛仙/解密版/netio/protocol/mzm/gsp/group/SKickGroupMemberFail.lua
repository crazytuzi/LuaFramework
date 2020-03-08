local SKickGroupMemberFail = class("SKickGroupMemberFail")
SKickGroupMemberFail.TYPEID = 12605206
SKickGroupMemberFail.GROUP_NOT_EXIST = 1
SKickGroupMemberFail.ONLY_MASTER_CAN_KICK = 2
SKickGroupMemberFail.NOT_IN_GROUP = 3
function SKickGroupMemberFail:ctor(res)
  self.id = 12605206
  self.res = res or nil
end
function SKickGroupMemberFail:marshal(os)
  os:marshalInt32(self.res)
end
function SKickGroupMemberFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SKickGroupMemberFail:sizepolicy(size)
  return size <= 65535
end
return SKickGroupMemberFail
