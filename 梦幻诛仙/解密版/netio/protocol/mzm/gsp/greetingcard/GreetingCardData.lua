local OctetsStream = require("netio.OctetsStream")
local GreetingCardData = class("GreetingCardData")
function GreetingCardData:ctor(cardCfgId, content, resourceId)
  self.cardCfgId = cardCfgId or nil
  self.content = content or nil
  self.resourceId = resourceId or nil
end
function GreetingCardData:marshal(os)
  os:marshalInt32(self.cardCfgId)
  os:marshalOctets(self.content)
  os:marshalInt32(self.resourceId)
end
function GreetingCardData:unmarshal(os)
  self.cardCfgId = os:unmarshalInt32()
  self.content = os:unmarshalOctets()
  self.resourceId = os:unmarshalInt32()
end
return GreetingCardData
