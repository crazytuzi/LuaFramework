local CWorldCanvass = class("CWorldCanvass")
CWorldCanvass.TYPEID = 12612367
function CWorldCanvass:ctor(target_roleid, use_yuanbao, client_yuanbao, text)
  self.id = 12612367
  self.target_roleid = target_roleid or nil
  self.use_yuanbao = use_yuanbao or nil
  self.client_yuanbao = client_yuanbao or nil
  self.text = text or nil
end
function CWorldCanvass:marshal(os)
  os:marshalInt64(self.target_roleid)
  os:marshalUInt8(self.use_yuanbao)
  os:marshalInt64(self.client_yuanbao)
  os:marshalOctets(self.text)
end
function CWorldCanvass:unmarshal(os)
  self.target_roleid = os:unmarshalInt64()
  self.use_yuanbao = os:unmarshalUInt8()
  self.client_yuanbao = os:unmarshalInt64()
  self.text = os:unmarshalOctets()
end
function CWorldCanvass:sizepolicy(size)
  return size <= 65535
end
return CWorldCanvass
