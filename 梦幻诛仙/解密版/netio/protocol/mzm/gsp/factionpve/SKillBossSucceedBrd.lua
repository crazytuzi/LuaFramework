local SKillBossSucceedBrd = class("SKillBossSucceedBrd")
SKillBossSucceedBrd.TYPEID = 12613648
function SKillBossSucceedBrd:ctor()
  self.id = 12613648
end
function SKillBossSucceedBrd:marshal(os)
end
function SKillBossSucceedBrd:unmarshal(os)
end
function SKillBossSucceedBrd:sizepolicy(size)
  return size <= 65535
end
return SKillBossSucceedBrd
