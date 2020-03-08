local CDrugRoomLevelUpReq = class("CDrugRoomLevelUpReq")
CDrugRoomLevelUpReq.TYPEID = 12605448
function CDrugRoomLevelUpReq:ctor()
  self.id = 12605448
end
function CDrugRoomLevelUpReq:marshal(os)
end
function CDrugRoomLevelUpReq:unmarshal(os)
end
function CDrugRoomLevelUpReq:sizepolicy(size)
  return size <= 65535
end
return CDrugRoomLevelUpReq
