local SChooseInterestSuccess = class("SChooseInterestSuccess")
SChooseInterestSuccess.TYPEID = 12609308
function SChooseInterestSuccess:ctor(childid, draw_lots_cfgid)
  self.id = 12609308
  self.childid = childid or nil
  self.draw_lots_cfgid = draw_lots_cfgid or nil
end
function SChooseInterestSuccess:marshal(os)
  os:marshalInt64(self.childid)
  os:marshalInt32(self.draw_lots_cfgid)
end
function SChooseInterestSuccess:unmarshal(os)
  self.childid = os:unmarshalInt64()
  self.draw_lots_cfgid = os:unmarshalInt32()
end
function SChooseInterestSuccess:sizepolicy(size)
  return size <= 65535
end
return SChooseInterestSuccess
