local identify = class("GiftOfIdentify")
function identify:ctor()
  self.m_ShowIdentify = {}
  self.m_HasAcceptIdentify = {}
  self.m_AddIdentifyGift = {}
end
function identify:setAcceptIdentify(list)
  if list == nil then
    self.m_HasAcceptIdentify = {}
  else
    self.m_HasAcceptIdentify = list
  end
  SendMessage(MsgID_Gift_GetGiftOfIdentify)
end
function identify:getAcceptIdentify()
  return self.m_HasAcceptIdentify
end
function identify:setAddIdentifyGift(giftlist)
  giftlist = giftlist or {}
  self.m_AddIdentifyGift = DeepCopyTable(giftlist)
  SendMessage(MsgID_Gift_AddExGiftOfIdentify)
end
function identify:getAddIdentifyGift()
  return self.m_AddIdentifyGift
end
function identify:setShowIdentify(list)
  if list == nil then
    self.m_ShowIdentify = {}
  else
    self.m_ShowIdentify = list
  end
  SendMessage(MsgID_Gift_ShowGiftOfIdentify)
end
function identify:getShowIdentify()
  return self.m_ShowIdentify
end
return identify
