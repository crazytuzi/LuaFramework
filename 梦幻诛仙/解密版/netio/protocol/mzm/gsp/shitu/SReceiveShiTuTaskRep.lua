local SReceiveShiTuTaskRep = class("SReceiveShiTuTaskRep")
SReceiveShiTuTaskRep.TYPEID = 12601642
SReceiveShiTuTaskRep.RESULT_SUCCESS = 1
SReceiveShiTuTaskRep.RESULT_ERROR_TASK_INFO = 2
SReceiveShiTuTaskRep.RESULT_ERROR_IN_TEAM = 3
SReceiveShiTuTaskRep.RESULT_ERROR_TIMES_MAX = 4
SReceiveShiTuTaskRep.RESULT_ERROR_ROLE_INFO = 5
SReceiveShiTuTaskRep.RESULT_ERROR_TASK_INIT = 6
SReceiveShiTuTaskRep.RESULT_ERROR_STATE = 7
SReceiveShiTuTaskRep.RESULT_ERROR_LEVEL_MAX = 8
function SReceiveShiTuTaskRep:ctor(result, args)
  self.id = 12601642
  self.result = result or nil
  self.args = args or {}
end
function SReceiveShiTuTaskRep:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SReceiveShiTuTaskRep:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SReceiveShiTuTaskRep:sizepolicy(size)
  return size <= 65535
end
return SReceiveShiTuTaskRep
