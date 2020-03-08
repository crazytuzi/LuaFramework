local OctetsStream = require("netio.OctetsStream")
local ThingBean = class("ThingBean")
ThingBean.MAIL_ATTACHMENT_MONEY = 1
ThingBean.MAIL_ATTACHMENT_TOKEN = 2
ThingBean.MAIL_ATTACHMENT_EXP = 3
ThingBean.MAIL_ATTACHMENT_VIGOR = 4
ThingBean.MAIL_ATTACHMENT_STORE_EXP = 5
function ThingBean:ctor(id, count, thingType)
  self.id = id or nil
  self.count = count or nil
  self.thingType = thingType or nil
end
function ThingBean:marshal(os)
  os:marshalInt32(self.id)
  os:marshalInt32(self.count)
  os:marshalInt32(self.thingType)
end
function ThingBean:unmarshal(os)
  self.id = os:unmarshalInt32()
  self.count = os:unmarshalInt32()
  self.thingType = os:unmarshalInt32()
end
return ThingBean
