local SSyncStorageExp = class("SSyncStorageExp")
SSyncStorageExp.TYPEID = 12583432
function SSyncStorageExp:ctor(newStorageExp)
  self.id = 12583432
  self.newStorageExp = newStorageExp or nil
end
function SSyncStorageExp:marshal(os)
  os:marshalInt64(self.newStorageExp)
end
function SSyncStorageExp:unmarshal(os)
  self.newStorageExp = os:unmarshalInt64()
end
function SSyncStorageExp:sizepolicy(size)
  return size <= 65535
end
return SSyncStorageExp
