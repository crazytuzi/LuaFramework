local CGetTitleReq = class("CGetTitleReq")
CGetTitleReq.TYPEID = 12612882
function CGetTitleReq:ctor()
  self.id = 12612882
end
function CGetTitleReq:marshal(os)
end
function CGetTitleReq:unmarshal(os)
end
function CGetTitleReq:sizepolicy(size)
  return size <= 65535
end
return CGetTitleReq
