local SNotifyPreviewChess = class("SNotifyPreviewChess")
SNotifyPreviewChess.TYPEID = 12619042
function SNotifyPreviewChess:ctor()
  self.id = 12619042
end
function SNotifyPreviewChess:marshal(os)
end
function SNotifyPreviewChess:unmarshal(os)
end
function SNotifyPreviewChess:sizepolicy(size)
  return size <= 65535
end
return SNotifyPreviewChess
