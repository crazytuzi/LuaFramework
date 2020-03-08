local SyncItemSwitches = class("SyncItemSwitches")
SyncItemSwitches.TYPEID = 12601107
function SyncItemSwitches:ctor(infos)
  self.id = 12601107
  self.infos = infos or {}
end
function SyncItemSwitches:marshal(os)
  os:marshalCompactUInt32(table.getn(self.infos))
  for _, v in ipairs(self.infos) do
    v:marshal(os)
  end
end
function SyncItemSwitches:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.idip.ItemSwitchInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.infos, v)
  end
end
function SyncItemSwitches:sizepolicy(size)
  return size <= 65535
end
return SyncItemSwitches
