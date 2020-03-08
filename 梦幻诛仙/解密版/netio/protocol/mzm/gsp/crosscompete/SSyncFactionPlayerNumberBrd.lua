local SSyncFactionPlayerNumberBrd = class("SSyncFactionPlayerNumberBrd")
SSyncFactionPlayerNumberBrd.TYPEID = 12616726
function SSyncFactionPlayerNumberBrd:ctor(factionid, player_num)
  self.id = 12616726
  self.factionid = factionid or nil
  self.player_num = player_num or nil
end
function SSyncFactionPlayerNumberBrd:marshal(os)
  os:marshalInt64(self.factionid)
  os:marshalInt32(self.player_num)
end
function SSyncFactionPlayerNumberBrd:unmarshal(os)
  self.factionid = os:unmarshalInt64()
  self.player_num = os:unmarshalInt32()
end
function SSyncFactionPlayerNumberBrd:sizepolicy(size)
  return size <= 65535
end
return SSyncFactionPlayerNumberBrd
