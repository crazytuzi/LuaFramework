local CChildrenRefreshAmuletReq = class("CChildrenRefreshAmuletReq")
CChildrenRefreshAmuletReq.TYPEID = 12609416
CChildrenRefreshAmuletReq.USE = 1
CChildrenRefreshAmuletReq.UNUSE = 2
function CChildrenRefreshAmuletReq:ctor(costType, costYuanBao, yuanBaoNum, childrenid)
  self.id = 12609416
  self.costType = costType or nil
  self.costYuanBao = costYuanBao or nil
  self.yuanBaoNum = yuanBaoNum or nil
  self.childrenid = childrenid or nil
end
function CChildrenRefreshAmuletReq:marshal(os)
  os:marshalInt32(self.costType)
  os:marshalInt32(self.costYuanBao)
  os:marshalInt64(self.yuanBaoNum)
  os:marshalInt64(self.childrenid)
end
function CChildrenRefreshAmuletReq:unmarshal(os)
  self.costType = os:unmarshalInt32()
  self.costYuanBao = os:unmarshalInt32()
  self.yuanBaoNum = os:unmarshalInt64()
  self.childrenid = os:unmarshalInt64()
end
function CChildrenRefreshAmuletReq:sizepolicy(size)
  return size <= 65535
end
return CChildrenRefreshAmuletReq
