local CTakeSingleBoss = class("CTakeSingleBoss")
CTakeSingleBoss.TYPEID = 12591387
function CTakeSingleBoss:ctor()
  self.id = 12591387
end
function CTakeSingleBoss:marshal(os)
end
function CTakeSingleBoss:unmarshal(os)
end
function CTakeSingleBoss:sizepolicy(size)
  return size <= 65535
end
return CTakeSingleBoss
