local SGetTitleSuccess = class("SGetTitleSuccess")
SGetTitleSuccess.TYPEID = 12612881
function SGetTitleSuccess:ctor()
  self.id = 12612881
end
function SGetTitleSuccess:marshal(os)
end
function SGetTitleSuccess:unmarshal(os)
end
function SGetTitleSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetTitleSuccess
