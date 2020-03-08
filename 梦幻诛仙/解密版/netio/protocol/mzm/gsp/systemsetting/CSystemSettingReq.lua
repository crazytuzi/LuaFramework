local CSystemSettingReq = class("CSystemSettingReq")
CSystemSettingReq.TYPEID = 12587265
function CSystemSettingReq:ctor(settingType, settingValue)
  self.id = 12587265
  self.settingType = settingType or nil
  self.settingValue = settingValue or nil
end
function CSystemSettingReq:marshal(os)
  os:marshalInt32(self.settingType)
  os:marshalInt32(self.settingValue)
end
function CSystemSettingReq:unmarshal(os)
  self.settingType = os:unmarshalInt32()
  self.settingValue = os:unmarshalInt32()
end
function CSystemSettingReq:sizepolicy(size)
  return size <= 65535
end
return CSystemSettingReq
