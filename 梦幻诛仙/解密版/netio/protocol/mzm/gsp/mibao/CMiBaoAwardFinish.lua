local CMiBaoAwardFinish = class("CMiBaoAwardFinish")
CMiBaoAwardFinish.TYPEID = 12603403
function CMiBaoAwardFinish:ctor()
  self.id = 12603403
end
function CMiBaoAwardFinish:marshal(os)
end
function CMiBaoAwardFinish:unmarshal(os)
end
function CMiBaoAwardFinish:sizepolicy(size)
  return size <= 65535
end
return CMiBaoAwardFinish
