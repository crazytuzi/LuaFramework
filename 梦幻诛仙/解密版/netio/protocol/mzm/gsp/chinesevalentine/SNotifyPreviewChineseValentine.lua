local SNotifyPreviewChineseValentine = class("SNotifyPreviewChineseValentine")
SNotifyPreviewChineseValentine.TYPEID = 12622093
function SNotifyPreviewChineseValentine:ctor()
  self.id = 12622093
end
function SNotifyPreviewChineseValentine:marshal(os)
end
function SNotifyPreviewChineseValentine:unmarshal(os)
end
function SNotifyPreviewChineseValentine:sizepolicy(size)
  return size <= 65535
end
return SNotifyPreviewChineseValentine
