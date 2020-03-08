local SNotifyChineseValentineClick = class("SNotifyChineseValentineClick")
SNotifyChineseValentineClick.TYPEID = 12622084
function SNotifyChineseValentineClick:ctor(roleId)
  self.id = 12622084
  self.roleId = roleId or nil
end
function SNotifyChineseValentineClick:marshal(os)
  os:marshalInt64(self.roleId)
end
function SNotifyChineseValentineClick:unmarshal(os)
  self.roleId = os:unmarshalInt64()
end
function SNotifyChineseValentineClick:sizepolicy(size)
  return size <= 65535
end
return SNotifyChineseValentineClick
