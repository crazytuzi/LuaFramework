local CTaskWinCountAward = class("CTaskWinCountAward")
CTaskWinCountAward.TYPEID = 12601857
function CTaskWinCountAward:ctor(winCount)
  self.id = 12601857
  self.winCount = winCount or nil
end
function CTaskWinCountAward:marshal(os)
  os:marshalInt32(self.winCount)
end
function CTaskWinCountAward:unmarshal(os)
  self.winCount = os:unmarshalInt32()
end
function CTaskWinCountAward:sizepolicy(size)
  return size <= 65535
end
return CTaskWinCountAward
