local SSystemSettingRes = class("SSystemSettingRes")
SSystemSettingRes.TYPEID = 12587267
function SSystemSettingRes:ctor(settingType, settingValue)
  self.id = 12587267
  self.settingType = settingType or nil
  self.settingValue = settingValue or nil
end
function SSystemSettingRes:marshal(os)
  os:marshalInt32(self.settingType)
  os:marshalInt32(self.settingValue)
end
function SSystemSettingRes:unmarshal(os)
  self.settingType = os:unmarshalInt32()
  self.settingValue = os:unmarshalInt32()
end
function SSystemSettingRes:sizepolicy(size)
  return size <= 65535
end
return SSystemSettingRes
