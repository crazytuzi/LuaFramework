local SCreateCorpsSucBro = class("SCreateCorpsSucBro")
SCreateCorpsSucBro.TYPEID = 12617499
function SCreateCorpsSucBro:ctor(corpsName, captainName)
  self.id = 12617499
  self.corpsName = corpsName or nil
  self.captainName = captainName or nil
end
function SCreateCorpsSucBro:marshal(os)
  os:marshalOctets(self.corpsName)
  os:marshalOctets(self.captainName)
end
function SCreateCorpsSucBro:unmarshal(os)
  self.corpsName = os:unmarshalOctets()
  self.captainName = os:unmarshalOctets()
end
function SCreateCorpsSucBro:sizepolicy(size)
  return size <= 65535
end
return SCreateCorpsSucBro
