local SCancelMatch = class("SCancelMatch")
SCancelMatch.TYPEID = 12593675
function SCancelMatch:ctor()
  self.id = 12593675
end
function SCancelMatch:marshal(os)
end
function SCancelMatch:unmarshal(os)
end
function SCancelMatch:sizepolicy(size)
  return size <= 65535
end
return SCancelMatch
