local SNotifyJailDeliveryBegin = class("SNotifyJailDeliveryBegin")
SNotifyJailDeliveryBegin.TYPEID = 12620042
function SNotifyJailDeliveryBegin:ctor(nameList, name)
  self.id = 12620042
  self.nameList = nameList or {}
  self.name = name or nil
end
function SNotifyJailDeliveryBegin:marshal(os)
  os:marshalCompactUInt32(table.getn(self.nameList))
  for _, v in ipairs(self.nameList) do
    os:marshalOctets(v)
  end
  os:marshalOctets(self.name)
end
function SNotifyJailDeliveryBegin:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalOctets()
    table.insert(self.nameList, v)
  end
  self.name = os:unmarshalOctets()
end
function SNotifyJailDeliveryBegin:sizepolicy(size)
  return size <= 65535
end
return SNotifyJailDeliveryBegin
