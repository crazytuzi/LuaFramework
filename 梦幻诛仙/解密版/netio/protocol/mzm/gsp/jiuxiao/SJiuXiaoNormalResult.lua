local SJiuXiaoNormalResult = class("SJiuXiaoNormalResult")
SJiuXiaoNormalResult.TYPEID = 12595465
SJiuXiaoNormalResult.ENTER_JIU_XIAO_ROOM_ACTIVITY_NOT_OPEN = 1
SJiuXiaoNormalResult.TAKE_JIU_XIAO_AWARD_BE_TOKEN = 2
SJiuXiaoNormalResult.TAKE_JIU_XIAO_AWARD_AWARDED = 3
SJiuXiaoNormalResult.JIU_XIAO_TRANSFOR = 4
SJiuXiaoNormalResult.JIU_XIAO_TRANSFOR_OUTSIDE = 5
function SJiuXiaoNormalResult:ctor(result, args)
  self.id = 12595465
  self.result = result or nil
  self.args = args or {}
end
function SJiuXiaoNormalResult:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SJiuXiaoNormalResult:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SJiuXiaoNormalResult:sizepolicy(size)
  return size <= 65535
end
return SJiuXiaoNormalResult
