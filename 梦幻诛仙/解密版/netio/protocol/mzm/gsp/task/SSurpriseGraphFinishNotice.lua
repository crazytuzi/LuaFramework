local SSurpriseGraphFinishNotice = class("SSurpriseGraphFinishNotice")
SSurpriseGraphFinishNotice.TYPEID = 12592156
function SSurpriseGraphFinishNotice:ctor(graphId)
  self.id = 12592156
  self.graphId = graphId or nil
end
function SSurpriseGraphFinishNotice:marshal(os)
  os:marshalInt32(self.graphId)
end
function SSurpriseGraphFinishNotice:unmarshal(os)
  self.graphId = os:unmarshalInt32()
end
function SSurpriseGraphFinishNotice:sizepolicy(size)
  return size <= 65535
end
return SSurpriseGraphFinishNotice
