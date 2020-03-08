local SNotifyReduceTreasureHuntTime = class("SNotifyReduceTreasureHuntTime")
SNotifyReduceTreasureHuntTime.TYPEID = 12633094
function SNotifyReduceTreasureHuntTime:ctor(reduce_seconds, left_seconds)
  self.id = 12633094
  self.reduce_seconds = reduce_seconds or nil
  self.left_seconds = left_seconds or nil
end
function SNotifyReduceTreasureHuntTime:marshal(os)
  os:marshalInt32(self.reduce_seconds)
  os:marshalInt32(self.left_seconds)
end
function SNotifyReduceTreasureHuntTime:unmarshal(os)
  self.reduce_seconds = os:unmarshalInt32()
  self.left_seconds = os:unmarshalInt32()
end
function SNotifyReduceTreasureHuntTime:sizepolicy(size)
  return size <= 65535
end
return SNotifyReduceTreasureHuntTime
