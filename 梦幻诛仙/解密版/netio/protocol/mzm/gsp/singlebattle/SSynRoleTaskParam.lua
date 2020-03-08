local SSynRoleTaskParam = class("SSynRoleTaskParam")
SSynRoleTaskParam.TYPEID = 12621600
function SSynRoleTaskParam:ctor(taskId, param)
  self.id = 12621600
  self.taskId = taskId or nil
  self.param = param or nil
end
function SSynRoleTaskParam:marshal(os)
  os:marshalInt32(self.taskId)
  os:marshalInt32(self.param)
end
function SSynRoleTaskParam:unmarshal(os)
  self.taskId = os:unmarshalInt32()
  self.param = os:unmarshalInt32()
end
function SSynRoleTaskParam:sizepolicy(size)
  return size <= 65535
end
return SSynRoleTaskParam
