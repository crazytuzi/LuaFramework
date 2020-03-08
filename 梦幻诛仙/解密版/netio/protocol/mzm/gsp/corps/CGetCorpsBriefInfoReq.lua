local CGetCorpsBriefInfoReq = class("CGetCorpsBriefInfoReq")
CGetCorpsBriefInfoReq.TYPEID = 12617503
function CGetCorpsBriefInfoReq:ctor(roleIds)
  self.id = 12617503
  self.roleIds = roleIds or {}
end
function CGetCorpsBriefInfoReq:marshal(os)
  os:marshalCompactUInt32(table.getn(self.roleIds))
  for _, v in ipairs(self.roleIds) do
    os:marshalInt64(v)
  end
end
function CGetCorpsBriefInfoReq:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    table.insert(self.roleIds, v)
  end
end
function CGetCorpsBriefInfoReq:sizepolicy(size)
  return size <= 65535
end
return CGetCorpsBriefInfoReq
