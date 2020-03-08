local CTaskEnd = class("CTaskEnd")
CTaskEnd.TYPEID = 12608268
function CTaskEnd:ctor()
  self.id = 12608268
end
function CTaskEnd:marshal(os)
end
function CTaskEnd:unmarshal(os)
end
function CTaskEnd:sizepolicy(size)
  return size <= 65535
end
return CTaskEnd
