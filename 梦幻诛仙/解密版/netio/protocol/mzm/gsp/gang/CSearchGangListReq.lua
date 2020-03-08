local CSearchGangListReq = class("CSearchGangListReq")
CSearchGangListReq.TYPEID = 12589876
function CSearchGangListReq:ctor(condition)
  self.id = 12589876
  self.condition = condition or nil
end
function CSearchGangListReq:marshal(os)
  os:marshalString(self.condition)
end
function CSearchGangListReq:unmarshal(os)
  self.condition = os:unmarshalString()
end
function CSearchGangListReq:sizepolicy(size)
  return size <= 65535
end
return CSearchGangListReq
