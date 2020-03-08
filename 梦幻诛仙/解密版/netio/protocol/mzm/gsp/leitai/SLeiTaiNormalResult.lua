local SLeiTaiNormalResult = class("SLeiTaiNormalResult")
SLeiTaiNormalResult.TYPEID = 12591874
SLeiTaiNormalResult.ALREADY_LEAVE_LEITAI = 1
SLeiTaiNormalResult.TARGET_LEAVE_LEITAI = 2
SLeiTaiNormalResult.NOT_IN_LEI_TAI = 3
SLeiTaiNormalResult.ONLY_TEAM_LEADER_CAN_OPERATE = 4
SLeiTaiNormalResult.NOT_PK_TEAM_NORMAL_MEMBER = 5
SLeiTaiNormalResult.TARGET_NOT_LEADER = 10
function SLeiTaiNormalResult:ctor(result, args)
  self.id = 12591874
  self.result = result or nil
  self.args = args or {}
end
function SLeiTaiNormalResult:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SLeiTaiNormalResult:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SLeiTaiNormalResult:sizepolicy(size)
  return size <= 65535
end
return SLeiTaiNormalResult
