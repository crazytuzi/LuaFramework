local CSetAutoAssignFuncReq = class("CSetAutoAssignFuncReq")
CSetAutoAssignFuncReq.TYPEID = 12586000
CSetAutoAssignFuncReq.PROP_SYS_1 = 0
CSetAutoAssignFuncReq.PROP_SYS_2 = 1
CSetAutoAssignFuncReq.PROP_SYS_3 = 2
function CSetAutoAssignFuncReq:ctor(propSys, isAutoAssignOpen)
  self.id = 12586000
  self.propSys = propSys or nil
  self.isAutoAssignOpen = isAutoAssignOpen or nil
end
function CSetAutoAssignFuncReq:marshal(os)
  os:marshalInt32(self.propSys)
  os:marshalInt32(self.isAutoAssignOpen)
end
function CSetAutoAssignFuncReq:unmarshal(os)
  self.propSys = os:unmarshalInt32()
  self.isAutoAssignOpen = os:unmarshalInt32()
end
function CSetAutoAssignFuncReq:sizepolicy(size)
  return size <= 65535
end
return CSetAutoAssignFuncReq
