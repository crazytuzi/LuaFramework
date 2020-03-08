local SSyncRedgiftActivityStartRes = class("SSyncRedgiftActivityStartRes")
SSyncRedgiftActivityStartRes.TYPEID = 12587588
function SSyncRedgiftActivityStartRes:ctor()
  self.id = 12587588
end
function SSyncRedgiftActivityStartRes:marshal(os)
end
function SSyncRedgiftActivityStartRes:unmarshal(os)
end
function SSyncRedgiftActivityStartRes:sizepolicy(size)
  return size <= 65535
end
return SSyncRedgiftActivityStartRes
