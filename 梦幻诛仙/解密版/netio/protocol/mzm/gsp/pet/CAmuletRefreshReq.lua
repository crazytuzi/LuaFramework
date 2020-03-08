local CAmuletRefreshReq = class("CAmuletRefreshReq")
CAmuletRefreshReq.TYPEID = 12590614
function CAmuletRefreshReq:ctor(itemKey, costType, costYuanBao, yuanBaoNum, petid)
  self.id = 12590614
  self.itemKey = itemKey or nil
  self.costType = costType or nil
  self.costYuanBao = costYuanBao or nil
  self.yuanBaoNum = yuanBaoNum or nil
  self.petid = petid or nil
end
function CAmuletRefreshReq:marshal(os)
  os:marshalInt32(self.itemKey)
  os:marshalInt32(self.costType)
  os:marshalInt32(self.costYuanBao)
  os:marshalInt64(self.yuanBaoNum)
  os:marshalInt64(self.petid)
end
function CAmuletRefreshReq:unmarshal(os)
  self.itemKey = os:unmarshalInt32()
  self.costType = os:unmarshalInt32()
  self.costYuanBao = os:unmarshalInt32()
  self.yuanBaoNum = os:unmarshalInt64()
  self.petid = os:unmarshalInt64()
end
function CAmuletRefreshReq:sizepolicy(size)
  return size <= 65535
end
return CAmuletRefreshReq
