local SParaseleneActivityOpenRes = class("SParaseleneActivityOpenRes")
SParaseleneActivityOpenRes.TYPEID = 12598279
function SParaseleneActivityOpenRes:ctor()
  self.id = 12598279
end
function SParaseleneActivityOpenRes:marshal(os)
end
function SParaseleneActivityOpenRes:unmarshal(os)
end
function SParaseleneActivityOpenRes:sizepolicy(size)
  return size <= 65535
end
return SParaseleneActivityOpenRes
