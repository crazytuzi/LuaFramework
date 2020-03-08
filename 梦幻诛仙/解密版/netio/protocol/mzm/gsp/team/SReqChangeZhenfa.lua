local SReqChangeZhenfa = class("SReqChangeZhenfa")
SReqChangeZhenfa.TYPEID = 12588320
function SReqChangeZhenfa:ctor(ChangedZhenfaId, ZhenfaLevel)
  self.id = 12588320
  self.ChangedZhenfaId = ChangedZhenfaId or nil
  self.ZhenfaLevel = ZhenfaLevel or nil
end
function SReqChangeZhenfa:marshal(os)
  os:marshalInt32(self.ChangedZhenfaId)
  os:marshalInt32(self.ZhenfaLevel)
end
function SReqChangeZhenfa:unmarshal(os)
  self.ChangedZhenfaId = os:unmarshalInt32()
  self.ZhenfaLevel = os:unmarshalInt32()
end
function SReqChangeZhenfa:sizepolicy(size)
  return size <= 65535
end
return SReqChangeZhenfa
