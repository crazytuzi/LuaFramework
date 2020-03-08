local CUseChatBubbleItemReq = class("CUseChatBubbleItemReq")
CUseChatBubbleItemReq.TYPEID = 12621827
function CUseChatBubbleItemReq:ctor(bagId, grid)
  self.id = 12621827
  self.bagId = bagId or nil
  self.grid = grid or nil
end
function CUseChatBubbleItemReq:marshal(os)
  os:marshalInt32(self.bagId)
  os:marshalInt32(self.grid)
end
function CUseChatBubbleItemReq:unmarshal(os)
  self.bagId = os:unmarshalInt32()
  self.grid = os:unmarshalInt32()
end
function CUseChatBubbleItemReq:sizepolicy(size)
  return size <= 65535
end
return CUseChatBubbleItemReq
