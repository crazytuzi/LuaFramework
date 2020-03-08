local SSyncKeJuZiGeReq = class("SSyncKeJuZiGeReq")
SSyncKeJuZiGeReq.TYPEID = 12594713
function SSyncKeJuZiGeReq:ctor(keJuState)
  self.id = 12594713
  self.keJuState = keJuState or {}
end
function SSyncKeJuZiGeReq:marshal(os)
  os:marshalCompactUInt32(table.getn(self.keJuState))
  for _, v in ipairs(self.keJuState) do
    v:marshal(os)
  end
end
function SSyncKeJuZiGeReq:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.question.KeJuState")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.keJuState, v)
  end
end
function SSyncKeJuZiGeReq:sizepolicy(size)
  return size <= 65535
end
return SSyncKeJuZiGeReq
