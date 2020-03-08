local SMournNormalResult = class("SMournNormalResult")
SMournNormalResult.TYPEID = 12613380
SMournNormalResult.MOURNING = 1
SMournNormalResult.MOURN_TO_MAX = 2
SMournNormalResult.QUESTION_ERROR = 3
function SMournNormalResult:ctor(result, args)
  self.id = 12613380
  self.result = result or nil
  self.args = args or {}
end
function SMournNormalResult:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SMournNormalResult:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SMournNormalResult:sizepolicy(size)
  return size <= 65535
end
return SMournNormalResult
