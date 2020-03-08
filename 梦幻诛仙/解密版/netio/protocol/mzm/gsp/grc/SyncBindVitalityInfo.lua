local RoleVitalityInfo = require("netio.protocol.mzm.gsp.grc.RoleVitalityInfo")
local SyncBindVitalityInfo = class("SyncBindVitalityInfo")
SyncBindVitalityInfo.TYPEID = 12600378
function SyncBindVitalityInfo:ctor(vitality_info, recall_bind_infos, back_bind_infos)
  self.id = 12600378
  self.vitality_info = vitality_info or RoleVitalityInfo.new()
  self.recall_bind_infos = recall_bind_infos or {}
  self.back_bind_infos = back_bind_infos or {}
end
function SyncBindVitalityInfo:marshal(os)
  self.vitality_info:marshal(os)
  os:marshalCompactUInt32(table.getn(self.recall_bind_infos))
  for _, v in ipairs(self.recall_bind_infos) do
    v:marshal(os)
  end
  os:marshalCompactUInt32(table.getn(self.back_bind_infos))
  for _, v in ipairs(self.back_bind_infos) do
    v:marshal(os)
  end
end
function SyncBindVitalityInfo:unmarshal(os)
  self.vitality_info = RoleVitalityInfo.new()
  self.vitality_info:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.grc.BindVitalityInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.recall_bind_infos, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.grc.BindVitalityInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.back_bind_infos, v)
  end
end
function SyncBindVitalityInfo:sizepolicy(size)
  return size <= 65535
end
return SyncBindVitalityInfo
