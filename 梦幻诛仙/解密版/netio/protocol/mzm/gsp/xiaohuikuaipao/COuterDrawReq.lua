local COuterDrawReq = class("COuterDrawReq")
COuterDrawReq.TYPEID = 12622862
function COuterDrawReq:ctor(activityId, count, isUseYuanBao, clientYuanBao, needYuanBao)
  self.id = 12622862
  self.activityId = activityId or nil
  self.count = count or nil
  self.isUseYuanBao = isUseYuanBao or nil
  self.clientYuanBao = clientYuanBao or nil
  self.needYuanBao = needYuanBao or nil
end
function COuterDrawReq:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.count)
  os:marshalUInt8(self.isUseYuanBao)
  os:marshalInt64(self.clientYuanBao)
  os:marshalInt64(self.needYuanBao)
end
function COuterDrawReq:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.count = os:unmarshalInt32()
  self.isUseYuanBao = os:unmarshalUInt8()
  self.clientYuanBao = os:unmarshalInt64()
  self.needYuanBao = os:unmarshalInt64()
end
function COuterDrawReq:sizepolicy(size)
  return size <= 65535
end
return COuterDrawReq
