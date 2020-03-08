local CGetXCorpsBriefInfoReq = class("CGetXCorpsBriefInfoReq")
CGetXCorpsBriefInfoReq.TYPEID = 12617511
function CGetXCorpsBriefInfoReq:ctor(corpsId)
  self.id = 12617511
  self.corpsId = corpsId or nil
end
function CGetXCorpsBriefInfoReq:marshal(os)
  os:marshalInt64(self.corpsId)
end
function CGetXCorpsBriefInfoReq:unmarshal(os)
  self.corpsId = os:unmarshalInt64()
end
function CGetXCorpsBriefInfoReq:sizepolicy(size)
  return size <= 65535
end
return CGetXCorpsBriefInfoReq
