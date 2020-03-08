local SActiveSurpriseGraphNotice = class("SActiveSurpriseGraphNotice")
SActiveSurpriseGraphNotice.TYPEID = 12592159
function SActiveSurpriseGraphNotice:ctor(graphId)
  self.id = 12592159
  self.graphId = graphId or nil
end
function SActiveSurpriseGraphNotice:marshal(os)
  os:marshalInt32(self.graphId)
end
function SActiveSurpriseGraphNotice:unmarshal(os)
  self.graphId = os:unmarshalInt32()
end
function SActiveSurpriseGraphNotice:sizepolicy(size)
  return size <= 65535
end
return SActiveSurpriseGraphNotice
