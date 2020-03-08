local SScoActivityStartRes = class("SScoActivityStartRes")
SScoActivityStartRes.TYPEID = 12587563
function SScoActivityStartRes:ctor()
  self.id = 12587563
end
function SScoActivityStartRes:marshal(os)
end
function SScoActivityStartRes:unmarshal(os)
end
function SScoActivityStartRes:sizepolicy(size)
  return size <= 65535
end
return SScoActivityStartRes
