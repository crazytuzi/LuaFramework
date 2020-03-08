local SSynSendSkyLantern = class("SSynSendSkyLantern")
SSynSendSkyLantern.TYPEID = 12624131
function SSynSendSkyLantern:ctor(role_id, activity_id)
  self.id = 12624131
  self.role_id = role_id or nil
  self.activity_id = activity_id or nil
end
function SSynSendSkyLantern:marshal(os)
  os:marshalInt64(self.role_id)
  os:marshalInt32(self.activity_id)
end
function SSynSendSkyLantern:unmarshal(os)
  self.role_id = os:unmarshalInt64()
  self.activity_id = os:unmarshalInt32()
end
function SSynSendSkyLantern:sizepolicy(size)
  return size <= 65535
end
return SSynSendSkyLantern
