local SUseChatBubbleItemError = class("SUseChatBubbleItemError")
SUseChatBubbleItemError.TYPEID = 12621829
SUseChatBubbleItemError.ITEM_NOT_EXIST = 1
SUseChatBubbleItemError.ROLE_LEVEL_LOW = 2
SUseChatBubbleItemError.CHAT_BUBBLE_CLOSED = 3
SUseChatBubbleItemError.ROLE_GENDER_ERROR = 4
SUseChatBubbleItemError.ROLE_MENPAI_ERROR = 5
SUseChatBubbleItemError.BUBBLE_NEVER_EXPIRE = 6
function SUseChatBubbleItemError:ctor(errorCode)
  self.id = 12621829
  self.errorCode = errorCode or nil
end
function SUseChatBubbleItemError:marshal(os)
  os:marshalInt32(self.errorCode)
end
function SUseChatBubbleItemError:unmarshal(os)
  self.errorCode = os:unmarshalInt32()
end
function SUseChatBubbleItemError:sizepolicy(size)
  return size <= 65535
end
return SUseChatBubbleItemError
