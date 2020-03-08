local CReqAllMallItemNum = class("CReqAllMallItemNum")
CReqAllMallItemNum.TYPEID = 12585482
function CReqAllMallItemNum:ctor()
  self.id = 12585482
end
function CReqAllMallItemNum:marshal(os)
end
function CReqAllMallItemNum:unmarshal(os)
end
function CReqAllMallItemNum:sizepolicy(size)
  return size <= 65535
end
return CReqAllMallItemNum
