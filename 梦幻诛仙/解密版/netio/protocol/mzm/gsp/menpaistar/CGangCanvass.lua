local CGangCanvass = class("CGangCanvass")
CGangCanvass.TYPEID = 12612363
function CGangCanvass:ctor(target_roleid, text)
  self.id = 12612363
  self.target_roleid = target_roleid or nil
  self.text = text or nil
end
function CGangCanvass:marshal(os)
  os:marshalInt64(self.target_roleid)
  os:marshalOctets(self.text)
end
function CGangCanvass:unmarshal(os)
  self.target_roleid = os:unmarshalInt64()
  self.text = os:unmarshalOctets()
end
function CGangCanvass:sizepolicy(size)
  return size <= 65535
end
return CGangCanvass
