local CGetCrossBattleFinalHistoryCorpsReq = class("CGetCrossBattleFinalHistoryCorpsReq")
CGetCrossBattleFinalHistoryCorpsReq.TYPEID = 12617087
function CGetCrossBattleFinalHistoryCorpsReq:ctor(session, rank, corps_id)
  self.id = 12617087
  self.session = session or nil
  self.rank = rank or nil
  self.corps_id = corps_id or nil
end
function CGetCrossBattleFinalHistoryCorpsReq:marshal(os)
  os:marshalInt32(self.session)
  os:marshalInt32(self.rank)
  os:marshalInt64(self.corps_id)
end
function CGetCrossBattleFinalHistoryCorpsReq:unmarshal(os)
  self.session = os:unmarshalInt32()
  self.rank = os:unmarshalInt32()
  self.corps_id = os:unmarshalInt64()
end
function CGetCrossBattleFinalHistoryCorpsReq:sizepolicy(size)
  return size <= 65535
end
return CGetCrossBattleFinalHistoryCorpsReq
