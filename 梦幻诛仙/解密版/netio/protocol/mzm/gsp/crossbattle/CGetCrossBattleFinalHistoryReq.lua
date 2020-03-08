local CGetCrossBattleFinalHistoryReq = class("CGetCrossBattleFinalHistoryReq")
CGetCrossBattleFinalHistoryReq.TYPEID = 12617086
function CGetCrossBattleFinalHistoryReq:ctor(session)
  self.id = 12617086
  self.session = session or nil
end
function CGetCrossBattleFinalHistoryReq:marshal(os)
  os:marshalInt32(self.session)
end
function CGetCrossBattleFinalHistoryReq:unmarshal(os)
  self.session = os:unmarshalInt32()
end
function CGetCrossBattleFinalHistoryReq:sizepolicy(size)
  return size <= 65535
end
return CGetCrossBattleFinalHistoryReq
