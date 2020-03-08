local SReceiveShiTuActiveRewardRep = class("SReceiveShiTuActiveRewardRep")
SReceiveShiTuActiveRewardRep.TYPEID = 12601658
SReceiveShiTuActiveRewardRep.RESULT_SUCCESS = 1
SReceiveShiTuActiveRewardRep.RESULT_ERROR_BAG_FULL = 2
SReceiveShiTuActiveRewardRep.RESULT_ERROR_INDEX_ALEARDY_AWARD = 3
SReceiveShiTuActiveRewardRep.RESULT_ERROR_VALUE_NOT_ENOUGH = 4
SReceiveShiTuActiveRewardRep.RESULT_ERROR_AWARD_FAILED = 5
SReceiveShiTuActiveRewardRep.RESULT_ERROR_LEVEL_NOT_FOUND = 6
SReceiveShiTuActiveRewardRep.RESULT_ERROR_INDEX_NOT_EXIST = 7
SReceiveShiTuActiveRewardRep.RESULT_ERROR_NOT_MASTER = 8
SReceiveShiTuActiveRewardRep.RESULT_ERROR_ROLE_INFO = 9
SReceiveShiTuActiveRewardRep.RESULT_ERROR_NO_MASTER = 10
SReceiveShiTuActiveRewardRep.RESULT_ERROR_RELATION_START_DAY = 11
function SReceiveShiTuActiveRewardRep:ctor(result, args)
  self.id = 12601658
  self.result = result or nil
  self.args = args or {}
end
function SReceiveShiTuActiveRewardRep:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SReceiveShiTuActiveRewardRep:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SReceiveShiTuActiveRewardRep:sizepolicy(size)
  return size <= 65535
end
return SReceiveShiTuActiveRewardRep
