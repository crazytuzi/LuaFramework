local SLoginWaitTimeOut = class("SLoginWaitTimeOut")
SLoginWaitTimeOut.TYPEID = 12607259
function SLoginWaitTimeOut:ctor()
  self.id = 12607259
end
function SLoginWaitTimeOut:marshal(os)
end
function SLoginWaitTimeOut:unmarshal(os)
end
function SLoginWaitTimeOut:sizepolicy(size)
  return size <= 65535
end
return SLoginWaitTimeOut
