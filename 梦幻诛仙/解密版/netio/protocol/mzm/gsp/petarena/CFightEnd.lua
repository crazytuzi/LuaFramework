local CFightEnd = class("CFightEnd")
CFightEnd.TYPEID = 12628252
function CFightEnd:ctor()
  self.id = 12628252
end
function CFightEnd:marshal(os)
end
function CFightEnd:unmarshal(os)
end
function CFightEnd:sizepolicy(size)
  return size <= 65535
end
return CFightEnd
