local SPublishShiTuTaskRep = class("SPublishShiTuTaskRep")
SPublishShiTuTaskRep.TYPEID = 12601637
SPublishShiTuTaskRep.RESULT_SUCCESS = 1
SPublishShiTuTaskRep.RESULT_ERROR_NOT_MASTER = 2
SPublishShiTuTaskRep.RESULT_ERROR_ROLE_INFO = 3
SPublishShiTuTaskRep.RESULT_ERROR_APPRENTICE_TASK_INIT = 4
SPublishShiTuTaskRep.RESULT_ERROR_APPRENTICE_STATE = 5
SPublishShiTuTaskRep.RESULT_ERROR_MAX_PUBLISH_TIMES = 6
function SPublishShiTuTaskRep:ctor(result, role_id, args)
  self.id = 12601637
  self.result = result or nil
  self.role_id = role_id or nil
  self.args = args or {}
end
function SPublishShiTuTaskRep:marshal(os)
  os:marshalInt32(self.result)
  os:marshalInt64(self.role_id)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SPublishShiTuTaskRep:unmarshal(os)
  self.result = os:unmarshalInt32()
  self.role_id = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SPublishShiTuTaskRep:sizepolicy(size)
  return size <= 65535
end
return SPublishShiTuTaskRep
