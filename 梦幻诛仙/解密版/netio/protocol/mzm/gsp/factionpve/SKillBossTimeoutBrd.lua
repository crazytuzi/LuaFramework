local SKillBossTimeoutBrd = class("SKillBossTimeoutBrd")
SKillBossTimeoutBrd.TYPEID = 12613647
function SKillBossTimeoutBrd:ctor()
  self.id = 12613647
end
function SKillBossTimeoutBrd:marshal(os)
end
function SKillBossTimeoutBrd:unmarshal(os)
end
function SKillBossTimeoutBrd:sizepolicy(size)
  return size <= 65535
end
return SKillBossTimeoutBrd
