local SChangeTryMatchAgain = class("SChangeTryMatchAgain")
SChangeTryMatchAgain.TYPEID = 12593667
function SChangeTryMatchAgain:ctor()
  self.id = 12593667
end
function SChangeTryMatchAgain:marshal(os)
end
function SChangeTryMatchAgain:unmarshal(os)
end
function SChangeTryMatchAgain:sizepolicy(size)
  return size <= 65535
end
return SChangeTryMatchAgain
