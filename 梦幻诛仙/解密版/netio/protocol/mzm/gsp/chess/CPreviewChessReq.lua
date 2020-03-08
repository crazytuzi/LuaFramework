local CPreviewChessReq = class("CPreviewChessReq")
CPreviewChessReq.TYPEID = 12619041
function CPreviewChessReq:ctor()
  self.id = 12619041
end
function CPreviewChessReq:marshal(os)
end
function CPreviewChessReq:unmarshal(os)
end
function CPreviewChessReq:sizepolicy(size)
  return size <= 65535
end
return CPreviewChessReq
