local SHuanhunNormalResult = class("SHuanhunNormalResult")
SHuanhunNormalResult.TYPEID = 12584458
SHuanhunNormalResult.SEEK_HELP_GANG__LEFT_NUM_NULL = 1
SHuanhunNormalResult.SEEK_HELP_GANG__REPEAT = 2
SHuanhunNormalResult.SEEK_HELP_GANG__NO_GANG = 3
SHuanhunNormalResult.SEEK_HELP_GANG__SUC = 4
SHuanhunNormalResult.ADD_ITEM__FULL = 5
SHuanhunNormalResult.ADD_ITEM__COUNT_ERROR = 6
SHuanhunNormalResult.ADD_ITEM__ID_ERROR = 7
SHuanhunNormalResult.SEEK_HELP_GANG__NO_ENOUGH_FULL_BOX = 8
SHuanhunNormalResult.CHECK_OTHER_HELP_ITEM__OUT_TIME = 10
SHuanhunNormalResult.HELP_OTHER_COUNT_NULL = 20
SHuanhunNormalResult.HELP_OTHER_FORBID_NON_LEVEL = 21
SHuanhunNormalResult.ADD_ITEM_ERROR__HUN_CLOSE = 22
function SHuanhunNormalResult:ctor(result, args)
  self.id = 12584458
  self.result = result or nil
  self.args = args or {}
end
function SHuanhunNormalResult:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SHuanhunNormalResult:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SHuanhunNormalResult:sizepolicy(size)
  return size <= 65535
end
return SHuanhunNormalResult
