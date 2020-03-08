local SNotifyPKStarted = class("SNotifyPKStarted")
SNotifyPKStarted.TYPEID = 12619801
function SNotifyPKStarted:ctor(active_role_id, target_role_id)
  self.id = 12619801
  self.active_role_id = active_role_id or nil
  self.target_role_id = target_role_id or nil
end
function SNotifyPKStarted:marshal(os)
  os:marshalInt64(self.active_role_id)
  os:marshalInt64(self.target_role_id)
end
function SNotifyPKStarted:unmarshal(os)
  self.active_role_id = os:unmarshalInt64()
  self.target_role_id = os:unmarshalInt64()
end
function SNotifyPKStarted:sizepolicy(size)
  return size <= 65535
end
return SNotifyPKStarted
