local SFlopLotteryError = class("SFlopLotteryError")
SFlopLotteryError.TYPEID = 12618503
SFlopLotteryError.BAG_CAPACITY_NOT_ENOUGH = 1
SFlopLotteryError.MONEY_NOT_ENOUGH = 2
SFlopLotteryError.HANDLE_ERROR = 3
function SFlopLotteryError:ctor(code, params)
  self.id = 12618503
  self.code = code or nil
  self.params = params or {}
end
function SFlopLotteryError:marshal(os)
  os:marshalInt32(self.code)
  os:marshalCompactUInt32(table.getn(self.params))
  for _, v in ipairs(self.params) do
    os:marshalString(v)
  end
end
function SFlopLotteryError:unmarshal(os)
  self.code = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.params, v)
  end
end
function SFlopLotteryError:sizepolicy(size)
  return size <= 65535
end
return SFlopLotteryError
