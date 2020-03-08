local SSetAutoAssignFuncRes = class("SSetAutoAssignFuncRes")
SSetAutoAssignFuncRes.TYPEID = 12585990
function SSetAutoAssignFuncRes:ctor(autoAssignOpenFlag)
  self.id = 12585990
  self.autoAssignOpenFlag = autoAssignOpenFlag or nil
end
function SSetAutoAssignFuncRes:marshal(os)
  os:marshalInt32(self.autoAssignOpenFlag)
end
function SSetAutoAssignFuncRes:unmarshal(os)
  self.autoAssignOpenFlag = os:unmarshalInt32()
end
function SSetAutoAssignFuncRes:sizepolicy(size)
  return size <= 65535
end
return SSetAutoAssignFuncRes
