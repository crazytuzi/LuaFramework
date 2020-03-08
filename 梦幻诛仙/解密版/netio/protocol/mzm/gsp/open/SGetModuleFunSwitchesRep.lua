local SGetModuleFunSwitchesRep = class("SGetModuleFunSwitchesRep")
SGetModuleFunSwitchesRep.TYPEID = 12599042
function SGetModuleFunSwitchesRep:ctor(funSwitches)
  self.id = 12599042
  self.funSwitches = funSwitches or {}
end
function SGetModuleFunSwitchesRep:marshal(os)
  os:marshalCompactUInt32(table.getn(self.funSwitches))
  for _, v in ipairs(self.funSwitches) do
    v:marshal(os)
  end
end
function SGetModuleFunSwitchesRep:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.funSwitches, v)
  end
end
function SGetModuleFunSwitchesRep:sizepolicy(size)
  return size <= 65535
end
return SGetModuleFunSwitchesRep
