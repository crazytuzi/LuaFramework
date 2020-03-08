local SRefreshShiTuTaskRep = class("SRefreshShiTuTaskRep")
SRefreshShiTuTaskRep.TYPEID = 12601640
SRefreshShiTuTaskRep.RESULT_SUCCESS = 1
SRefreshShiTuTaskRep.RESULT_ERROR_NOT_MASTER = 2
SRefreshShiTuTaskRep.RESULT_ERROR_NO_TIMES = 3
SRefreshShiTuTaskRep.RESULT_ERROR_ROLE_INFO = 4
SRefreshShiTuTaskRep.RESULT_ERROR_APPRENTICE_TASK_INIT = 5
SRefreshShiTuTaskRep.RESULT_ERROR_REFRESH_FAIL = 6
SRefreshShiTuTaskRep.RESULT_ERROR_APPRENTICE_STATE = 7
function SRefreshShiTuTaskRep:ctor(result, args)
  self.id = 12601640
  self.result = result or nil
  self.args = args or {}
end
function SRefreshShiTuTaskRep:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SRefreshShiTuTaskRep:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SRefreshShiTuTaskRep:sizepolicy(size)
  return size <= 65535
end
return SRefreshShiTuTaskRep
