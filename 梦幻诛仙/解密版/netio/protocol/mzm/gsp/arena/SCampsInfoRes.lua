local SCampsInfoRes = class("SCampsInfoRes")
SCampsInfoRes.TYPEID = 12596747
function SCampsInfoRes:ctor(camps)
  self.id = 12596747
  self.camps = camps or {}
end
function SCampsInfoRes:marshal(os)
  os:marshalCompactUInt32(table.getn(self.camps))
  for _, v in ipairs(self.camps) do
    v:marshal(os)
  end
end
function SCampsInfoRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.arena.Camp")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.camps, v)
  end
end
function SCampsInfoRes:sizepolicy(size)
  return size <= 65535
end
return SCampsInfoRes
