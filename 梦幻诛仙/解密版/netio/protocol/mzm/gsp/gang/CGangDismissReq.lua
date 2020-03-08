local CGangDismissReq = class("CGangDismissReq")
CGangDismissReq.TYPEID = 12589937
function CGangDismissReq:ctor()
  self.id = 12589937
end
function CGangDismissReq:marshal(os)
end
function CGangDismissReq:unmarshal(os)
end
function CGangDismissReq:sizepolicy(size)
  return size <= 65535
end
return CGangDismissReq
