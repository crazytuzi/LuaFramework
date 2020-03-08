local SEnterJiuXiaoMapRes = class("SEnterJiuXiaoMapRes")
SEnterJiuXiaoMapRes.TYPEID = 12595457
SEnterJiuXiaoMapRes.WAIT_TIME_NOW = 1
function SEnterJiuXiaoMapRes:ctor(result, args)
  self.id = 12595457
  self.result = result or nil
  self.args = args or {}
end
function SEnterJiuXiaoMapRes:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SEnterJiuXiaoMapRes:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SEnterJiuXiaoMapRes:sizepolicy(size)
  return size <= 65535
end
return SEnterJiuXiaoMapRes
