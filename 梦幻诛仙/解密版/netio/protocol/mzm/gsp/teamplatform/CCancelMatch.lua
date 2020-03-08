local CCancelMatch = class("CCancelMatch")
CCancelMatch.TYPEID = 12593672
function CCancelMatch:ctor()
  self.id = 12593672
end
function CCancelMatch:marshal(os)
end
function CCancelMatch:unmarshal(os)
end
function CCancelMatch:sizepolicy(size)
  return size <= 65535
end
return CCancelMatch
