local CCancelCrossFieldMatchReq = class("CCancelCrossFieldMatchReq")
CCancelCrossFieldMatchReq.TYPEID = 12619528
function CCancelCrossFieldMatchReq:ctor()
  self.id = 12619528
end
function CCancelCrossFieldMatchReq:marshal(os)
end
function CCancelCrossFieldMatchReq:unmarshal(os)
end
function CCancelCrossFieldMatchReq:sizepolicy(size)
  return size <= 65535
end
return CCancelCrossFieldMatchReq
