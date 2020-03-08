local SGetFightDataSuccess = class("SGetFightDataSuccess")
SGetFightDataSuccess.TYPEID = 12628251
function SGetFightDataSuccess:ctor(active_name, passive_name, active_infos, passive_infos)
  self.id = 12628251
  self.active_name = active_name or nil
  self.passive_name = passive_name or nil
  self.active_infos = active_infos or {}
  self.passive_infos = passive_infos or {}
end
function SGetFightDataSuccess:marshal(os)
  os:marshalOctets(self.active_name)
  os:marshalOctets(self.passive_name)
  os:marshalCompactUInt32(table.getn(self.active_infos))
  for _, v in ipairs(self.active_infos) do
    v:marshal(os)
  end
  os:marshalCompactUInt32(table.getn(self.passive_infos))
  for _, v in ipairs(self.passive_infos) do
    v:marshal(os)
  end
end
function SGetFightDataSuccess:unmarshal(os)
  self.active_name = os:unmarshalOctets()
  self.passive_name = os:unmarshalOctets()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.petarena.PetFightInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.active_infos, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.petarena.PetFightInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.passive_infos, v)
  end
end
function SGetFightDataSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetFightDataSuccess
