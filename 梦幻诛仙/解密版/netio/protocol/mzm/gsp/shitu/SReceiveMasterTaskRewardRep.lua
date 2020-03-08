local SReceiveMasterTaskRewardRep = class("SReceiveMasterTaskRewardRep")
SReceiveMasterTaskRewardRep.TYPEID = 12601644
SReceiveMasterTaskRewardRep.RESULT_SUCCESS = 1
SReceiveMasterTaskRewardRep.RESULT_ERROR_TASK_INFO = 2
SReceiveMasterTaskRewardRep.RESULT_ERROR_NOT_MASTER = 3
SReceiveMasterTaskRewardRep.RESULT_ERROR_ROLE_INFO = 4
SReceiveMasterTaskRewardRep.RESULT_ERROR_APPRENTICE_TASK_INIT = 5
SReceiveMasterTaskRewardRep.RESULT_ERROR_APPRENTICE_STATE = 6
SReceiveMasterTaskRewardRep.RESULT_ERROR_RECEIVE_FAIL = 7
SReceiveMasterTaskRewardRep.RESULT_ERROR_BAG_FULL = 8
function SReceiveMasterTaskRewardRep:ctor(result, args)
  self.id = 12601644
  self.result = result or nil
  self.args = args or {}
end
function SReceiveMasterTaskRewardRep:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SReceiveMasterTaskRewardRep:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SReceiveMasterTaskRewardRep:sizepolicy(size)
  return size <= 65535
end
return SReceiveMasterTaskRewardRep
