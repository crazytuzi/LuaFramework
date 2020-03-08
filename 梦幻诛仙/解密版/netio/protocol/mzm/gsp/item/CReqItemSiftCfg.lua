local CReqItemSiftCfg = class("CReqItemSiftCfg")
CReqItemSiftCfg.TYPEID = 12584767
function CReqItemSiftCfg:ctor(siftcfgid)
  self.id = 12584767
  self.siftcfgid = siftcfgid or nil
end
function CReqItemSiftCfg:marshal(os)
  os:marshalInt32(self.siftcfgid)
end
function CReqItemSiftCfg:unmarshal(os)
  self.siftcfgid = os:unmarshalInt32()
end
function CReqItemSiftCfg:sizepolicy(size)
  return size <= 65535
end
return CReqItemSiftCfg
