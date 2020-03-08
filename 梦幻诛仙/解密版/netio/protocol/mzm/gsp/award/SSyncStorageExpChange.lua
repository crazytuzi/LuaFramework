local SSyncStorageExpChange = class("SSyncStorageExpChange")
SSyncStorageExpChange.TYPEID = 12583430
function SSyncStorageExpChange:ctor(newStorageExp)
  self.id = 12583430
  self.newStorageExp = newStorageExp or nil
end
function SSyncStorageExpChange:marshal(os)
  os:marshalInt64(self.newStorageExp)
end
function SSyncStorageExpChange:unmarshal(os)
  self.newStorageExp = os:unmarshalInt64()
end
function SSyncStorageExpChange:sizepolicy(size)
  return size <= 65535
end
return SSyncStorageExpChange
