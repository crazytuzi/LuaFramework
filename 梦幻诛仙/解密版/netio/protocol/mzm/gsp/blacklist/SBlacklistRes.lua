local SBlacklistRes = class("SBlacklistRes")
SBlacklistRes.TYPEID = 12588549
function SBlacklistRes:ctor(list)
  self.id = 12588549
  self.list = list or {}
end
function SBlacklistRes:marshal(os)
  os:marshalCompactUInt32(table.getn(self.list))
  for _, v in ipairs(self.list) do
    v:marshal(os)
  end
end
function SBlacklistRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.blacklist.BlackRole")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.list, v)
  end
end
function SBlacklistRes:sizepolicy(size)
  return size <= 65535
end
return SBlacklistRes
