local CSignPreciousGetAward = class("CSignPreciousGetAward")
CSignPreciousGetAward.TYPEID = 12593429
function CSignPreciousGetAward:ctor()
  self.id = 12593429
end
function CSignPreciousGetAward:marshal(os)
end
function CSignPreciousGetAward:unmarshal(os)
end
function CSignPreciousGetAward:sizepolicy(size)
  return size <= 65535
end
return CSignPreciousGetAward
