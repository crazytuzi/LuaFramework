local SAgainstListRes = class("SAgainstListRes")
SAgainstListRes.TYPEID = 12616735
function SAgainstListRes:ctor(against_list, miss_turn_list)
  self.id = 12616735
  self.against_list = against_list or {}
  self.miss_turn_list = miss_turn_list or {}
end
function SAgainstListRes:marshal(os)
  os:marshalCompactUInt32(table.getn(self.against_list))
  for _, v in ipairs(self.against_list) do
    v:marshal(os)
  end
  os:marshalCompactUInt32(table.getn(self.miss_turn_list))
  for _, v in ipairs(self.miss_turn_list) do
    v:marshal(os)
  end
end
function SAgainstListRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.crosscompete.Against")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.against_list, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.crosscompete.AgainstFaction")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.miss_turn_list, v)
  end
end
function SAgainstListRes:sizepolicy(size)
  return size <= 65535
end
return SAgainstListRes
