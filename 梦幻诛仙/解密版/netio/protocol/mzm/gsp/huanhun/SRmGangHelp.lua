local SRmGangHelp = class("SRmGangHelp")
SRmGangHelp.TYPEID = 12584465
function SRmGangHelp:ctor(roleId, boxIndexs)
  self.id = 12584465
  self.roleId = roleId or nil
  self.boxIndexs = boxIndexs or {}
end
function SRmGangHelp:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalCompactUInt32(table.getn(self.boxIndexs))
  for _, v in ipairs(self.boxIndexs) do
    os:marshalInt32(v)
  end
end
function SRmGangHelp:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.boxIndexs, v)
  end
end
function SRmGangHelp:sizepolicy(size)
  return size <= 65535
end
return SRmGangHelp
