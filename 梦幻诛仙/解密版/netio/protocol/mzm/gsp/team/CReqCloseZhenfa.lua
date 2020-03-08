local CReqCloseZhenfa = class("CReqCloseZhenfa")
CReqCloseZhenfa.TYPEID = 12588329
function CReqCloseZhenfa:ctor()
  self.id = 12588329
end
function CReqCloseZhenfa:marshal(os)
end
function CReqCloseZhenfa:unmarshal(os)
end
function CReqCloseZhenfa:sizepolicy(size)
  return size <= 65535
end
return CReqCloseZhenfa
