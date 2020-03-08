local CSiftItemBySiftCfgReq = class("CSiftItemBySiftCfgReq")
CSiftItemBySiftCfgReq.TYPEID = 12584734
function CSiftItemBySiftCfgReq:ctor(siftCfgid)
  self.id = 12584734
  self.siftCfgid = siftCfgid or nil
end
function CSiftItemBySiftCfgReq:marshal(os)
  os:marshalInt32(self.siftCfgid)
end
function CSiftItemBySiftCfgReq:unmarshal(os)
  self.siftCfgid = os:unmarshalInt32()
end
function CSiftItemBySiftCfgReq:sizepolicy(size)
  return size <= 65535
end
return CSiftItemBySiftCfgReq
