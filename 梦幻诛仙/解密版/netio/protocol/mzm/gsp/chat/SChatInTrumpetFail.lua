local SChatInTrumpetFail = class("SChatInTrumpetFail")
SChatInTrumpetFail.TYPEID = 12585273
SChatInTrumpetFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SChatInTrumpetFail.ROLE_STATUS_ERROR = -2
SChatInTrumpetFail.PARAM_ERROR = -3
SChatInTrumpetFail.YUANBAO_NOT_MATCH = 1
SChatInTrumpetFail.ITEM_AND_YUANBAO_NOT_ENOUGH = 2
SChatInTrumpetFail.CAN_NOT_SPEAK = 3
function SChatInTrumpetFail:ctor(res)
  self.id = 12585273
  self.res = res or nil
end
function SChatInTrumpetFail:marshal(os)
  os:marshalInt32(self.res)
end
function SChatInTrumpetFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SChatInTrumpetFail:sizepolicy(size)
  return size <= 65535
end
return SChatInTrumpetFail
