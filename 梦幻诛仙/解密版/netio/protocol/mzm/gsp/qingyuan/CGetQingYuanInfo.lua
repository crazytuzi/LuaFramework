local CGetQingYuanInfo = class("CGetQingYuanInfo")
CGetQingYuanInfo.TYPEID = 12602888
function CGetQingYuanInfo:ctor()
  self.id = 12602888
end
function CGetQingYuanInfo:marshal(os)
end
function CGetQingYuanInfo:unmarshal(os)
end
function CGetQingYuanInfo:sizepolicy(size)
  return size <= 65535
end
return CGetQingYuanInfo
