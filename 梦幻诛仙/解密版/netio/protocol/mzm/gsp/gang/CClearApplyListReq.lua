local CClearApplyListReq = class("CClearApplyListReq")
CClearApplyListReq.TYPEID = 12589831
function CClearApplyListReq:ctor()
  self.id = 12589831
end
function CClearApplyListReq:marshal(os)
end
function CClearApplyListReq:unmarshal(os)
end
function CClearApplyListReq:sizepolicy(size)
  return size <= 65535
end
return CClearApplyListReq
