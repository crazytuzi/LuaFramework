local CChooseInterest = class("CChooseInterest")
CChooseInterest.TYPEID = 12609305
function CChooseInterest:ctor(childid, client_draw_lots_cfgid)
  self.id = 12609305
  self.childid = childid or nil
  self.client_draw_lots_cfgid = client_draw_lots_cfgid or nil
end
function CChooseInterest:marshal(os)
  os:marshalInt64(self.childid)
  os:marshalInt32(self.client_draw_lots_cfgid)
end
function CChooseInterest:unmarshal(os)
  self.childid = os:unmarshalInt64()
  self.client_draw_lots_cfgid = os:unmarshalInt32()
end
function CChooseInterest:sizepolicy(size)
  return size <= 65535
end
return CChooseInterest
