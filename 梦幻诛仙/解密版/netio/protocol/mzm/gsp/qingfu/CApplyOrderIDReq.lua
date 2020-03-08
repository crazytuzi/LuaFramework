local CApplyOrderIDReq = class("CApplyOrderIDReq")
CApplyOrderIDReq.TYPEID = 12588803
function CApplyOrderIDReq:ctor(appid, cfgId, ext)
  self.id = 12588803
  self.appid = appid or nil
  self.cfgId = cfgId or nil
  self.ext = ext or nil
end
function CApplyOrderIDReq:marshal(os)
  os:marshalOctets(self.appid)
  os:marshalInt32(self.cfgId)
  os:marshalOctets(self.ext)
end
function CApplyOrderIDReq:unmarshal(os)
  self.appid = os:unmarshalOctets()
  self.cfgId = os:unmarshalInt32()
  self.ext = os:unmarshalOctets()
end
function CApplyOrderIDReq:sizepolicy(size)
  return size <= 4096
end
return CApplyOrderIDReq
