local SynActiveDataRes = class("SynActiveDataRes")
SynActiveDataRes.TYPEID = 12599555
function SynActiveDataRes:ctor(activeDatas, award_active_index_id_set)
  self.id = 12599555
  self.activeDatas = activeDatas or {}
  self.award_active_index_id_set = award_active_index_id_set or {}
end
function SynActiveDataRes:marshal(os)
  os:marshalCompactUInt32(table.getn(self.activeDatas))
  for _, v in ipairs(self.activeDatas) do
    v:marshal(os)
  end
  local _size_ = 0
  for _, _ in pairs(self.award_active_index_id_set) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, _ in pairs(self.award_active_index_id_set) do
    os:marshalInt32(k)
  end
end
function SynActiveDataRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.active.ActiveData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.activeDatas, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    self.award_active_index_id_set[v] = v
  end
end
function SynActiveDataRes:sizepolicy(size)
  return size <= 65535
end
return SynActiveDataRes
