local SOutGangNotify = class("SOutGangNotify")
SOutGangNotify.TYPEID = 12589947
function SOutGangNotify:ctor()
  self.id = 12589947
end
function SOutGangNotify:marshal(os)
end
function SOutGangNotify:unmarshal(os)
end
function SOutGangNotify:sizepolicy(size)
  return size <= 65535
end
return SOutGangNotify
