local CPreviewChineseValentineReq = class("CPreviewChineseValentineReq")
CPreviewChineseValentineReq.TYPEID = 12622094
function CPreviewChineseValentineReq:ctor()
  self.id = 12622094
end
function CPreviewChineseValentineReq:marshal(os)
end
function CPreviewChineseValentineReq:unmarshal(os)
end
function CPreviewChineseValentineReq:sizepolicy(size)
  return size <= 65535
end
return CPreviewChineseValentineReq
