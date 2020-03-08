local CPutOffWuShi = class("CPutOffWuShi")
CPutOffWuShi.TYPEID = 12618778
function CPutOffWuShi:ctor()
  self.id = 12618778
end
function CPutOffWuShi:marshal(os)
end
function CPutOffWuShi:unmarshal(os)
end
function CPutOffWuShi:sizepolicy(size)
  return size <= 65535
end
return CPutOffWuShi
