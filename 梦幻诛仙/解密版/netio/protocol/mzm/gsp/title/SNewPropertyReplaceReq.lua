local SNewPropertyReplaceReq = class("SNewPropertyReplaceReq")
SNewPropertyReplaceReq.TYPEID = 12593924
function SNewPropertyReplaceReq:ctor(appellationIdNew, appellationIdOld)
  self.id = 12593924
  self.appellationIdNew = appellationIdNew or nil
  self.appellationIdOld = appellationIdOld or nil
end
function SNewPropertyReplaceReq:marshal(os)
  os:marshalInt32(self.appellationIdNew)
  os:marshalInt32(self.appellationIdOld)
end
function SNewPropertyReplaceReq:unmarshal(os)
  self.appellationIdNew = os:unmarshalInt32()
  self.appellationIdOld = os:unmarshalInt32()
end
function SNewPropertyReplaceReq:sizepolicy(size)
  return size <= 65535
end
return SNewPropertyReplaceReq
