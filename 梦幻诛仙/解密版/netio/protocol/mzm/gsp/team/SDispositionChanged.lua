local SDispositionChanged = class("SDispositionChanged")
SDispositionChanged.TYPEID = 12588323
function SDispositionChanged:ctor(disposition)
  self.id = 12588323
  self.disposition = disposition or {}
end
function SDispositionChanged:marshal(os)
  os:marshalCompactUInt32(table.getn(self.disposition))
  for _, v in ipairs(self.disposition) do
    v:marshal(os)
  end
end
function SDispositionChanged:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.team.TeamDispositionMemberInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.disposition, v)
  end
end
function SDispositionChanged:sizepolicy(size)
  return size <= 65535
end
return SDispositionChanged
