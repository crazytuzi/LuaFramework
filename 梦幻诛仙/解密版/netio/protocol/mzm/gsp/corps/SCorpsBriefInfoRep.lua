local SCorpsBriefInfoRep = class("SCorpsBriefInfoRep")
SCorpsBriefInfoRep.TYPEID = 12617504
function SCorpsBriefInfoRep:ctor(roleIds, corpsBriefInfos)
  self.id = 12617504
  self.roleIds = roleIds or {}
  self.corpsBriefInfos = corpsBriefInfos or {}
end
function SCorpsBriefInfoRep:marshal(os)
  os:marshalCompactUInt32(table.getn(self.roleIds))
  for _, v in ipairs(self.roleIds) do
    os:marshalInt64(v)
  end
  local _size_ = 0
  for _, _ in pairs(self.corpsBriefInfos) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.corpsBriefInfos) do
    os:marshalInt64(k)
    v:marshal(os)
  end
end
function SCorpsBriefInfoRep:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    table.insert(self.roleIds, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local BeanClazz = require("netio.protocol.mzm.gsp.corps.CorpsBriefInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.corpsBriefInfos[k] = v
  end
end
function SCorpsBriefInfoRep:sizepolicy(size)
  return size <= 65535
end
return SCorpsBriefInfoRep
