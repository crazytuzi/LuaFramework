local SSyncBanquetPlayerNumberBrd = class("SSyncBanquetPlayerNumberBrd")
SSyncBanquetPlayerNumberBrd.TYPEID = 12605959
function SSyncBanquetPlayerNumberBrd:ctor(masterId, player_num)
  self.id = 12605959
  self.masterId = masterId or nil
  self.player_num = player_num or nil
end
function SSyncBanquetPlayerNumberBrd:marshal(os)
  os:marshalInt64(self.masterId)
  os:marshalInt32(self.player_num)
end
function SSyncBanquetPlayerNumberBrd:unmarshal(os)
  self.masterId = os:unmarshalInt64()
  self.player_num = os:unmarshalInt32()
end
function SSyncBanquetPlayerNumberBrd:sizepolicy(size)
  return size <= 65535
end
return SSyncBanquetPlayerNumberBrd
