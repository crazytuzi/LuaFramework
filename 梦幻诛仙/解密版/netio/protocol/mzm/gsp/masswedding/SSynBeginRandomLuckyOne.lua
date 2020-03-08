local SSynBeginRandomLuckyOne = class("SSynBeginRandomLuckyOne")
SSynBeginRandomLuckyOne.TYPEID = 12604953
function SSynBeginRandomLuckyOne:ctor()
  self.id = 12604953
end
function SSynBeginRandomLuckyOne:marshal(os)
end
function SSynBeginRandomLuckyOne:unmarshal(os)
end
function SSynBeginRandomLuckyOne:sizepolicy(size)
  return size <= 65535
end
return SSynBeginRandomLuckyOne
