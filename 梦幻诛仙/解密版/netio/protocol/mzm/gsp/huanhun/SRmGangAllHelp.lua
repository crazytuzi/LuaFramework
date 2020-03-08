local SRmGangAllHelp = class("SRmGangAllHelp")
SRmGangAllHelp.TYPEID = 12584464
function SRmGangAllHelp:ctor()
  self.id = 12584464
end
function SRmGangAllHelp:marshal(os)
end
function SRmGangAllHelp:unmarshal(os)
end
function SRmGangAllHelp:sizepolicy(size)
  return size <= 65535
end
return SRmGangAllHelp
