local SSyncBanquetInfo = class("SSyncBanquetInfo")
SSyncBanquetInfo.TYPEID = 12605960
function SSyncBanquetInfo:ctor(masterId, player_num, start_time)
  self.id = 12605960
  self.masterId = masterId or nil
  self.player_num = player_num or nil
  self.start_time = start_time or nil
end
function SSyncBanquetInfo:marshal(os)
  os:marshalInt64(self.masterId)
  os:marshalInt32(self.player_num)
  os:marshalInt64(self.start_time)
end
function SSyncBanquetInfo:unmarshal(os)
  self.masterId = os:unmarshalInt64()
  self.player_num = os:unmarshalInt32()
  self.start_time = os:unmarshalInt64()
end
function SSyncBanquetInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncBanquetInfo
