local CQuitGangReq = class("CQuitGangReq")
CQuitGangReq.TYPEID = 12589873
function CQuitGangReq:ctor()
  self.id = 12589873
end
function CQuitGangReq:marshal(os)
end
function CQuitGangReq:unmarshal(os)
end
function CQuitGangReq:sizepolicy(size)
  return size <= 65535
end
return CQuitGangReq
