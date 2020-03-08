local SNormalResult = class("SNormalResult")
SNormalResult.TYPEID = 12592899
SNormalResult.BAG_FULL = 0
SNormalResult.MONEY_FULL = 1
SNormalResult.TOKEN_FULL = 2
SNormalResult.VIGOR_FULL = 3
SNormalResult.MAIL_NOT_AVAILABLE = 10
SNormalResult.UNKNOW = 100
function SNormalResult:ctor(ret, args)
  self.id = 12592899
  self.ret = ret or nil
  self.args = args or {}
end
function SNormalResult:marshal(os)
  os:marshalInt32(self.ret)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SNormalResult:unmarshal(os)
  self.ret = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SNormalResult:sizepolicy(size)
  return size <= 65535
end
return SNormalResult
