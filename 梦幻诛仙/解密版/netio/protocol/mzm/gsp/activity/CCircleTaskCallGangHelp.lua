local CCircleTaskCallGangHelp = class("CCircleTaskCallGangHelp")
CCircleTaskCallGangHelp.TYPEID = 12587545
function CCircleTaskCallGangHelp:ctor()
  self.id = 12587545
end
function CCircleTaskCallGangHelp:marshal(os)
end
function CCircleTaskCallGangHelp:unmarshal(os)
end
function CCircleTaskCallGangHelp:sizepolicy(size)
  return size <= 65535
end
return CCircleTaskCallGangHelp
