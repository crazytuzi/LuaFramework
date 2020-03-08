local SNotifyJailDeliveryResult = class("SNotifyJailDeliveryResult")
SNotifyJailDeliveryResult.TYPEID = 12620044
SNotifyJailDeliveryResult.SUCCESS = 1
SNotifyJailDeliveryResult.FAIL = 2
function SNotifyJailDeliveryResult:ctor(result, nameList, name)
  self.id = 12620044
  self.result = result or nil
  self.nameList = nameList or {}
  self.name = name or nil
end
function SNotifyJailDeliveryResult:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.nameList))
  for _, v in ipairs(self.nameList) do
    os:marshalOctets(v)
  end
  os:marshalOctets(self.name)
end
function SNotifyJailDeliveryResult:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalOctets()
    table.insert(self.nameList, v)
  end
  self.name = os:unmarshalOctets()
end
function SNotifyJailDeliveryResult:sizepolicy(size)
  return size <= 65535
end
return SNotifyJailDeliveryResult
