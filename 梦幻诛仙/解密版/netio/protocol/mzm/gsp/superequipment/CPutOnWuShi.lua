local CPutOnWuShi = class("CPutOnWuShi")
CPutOnWuShi.TYPEID = 12618772
function CPutOnWuShi:ctor(wuShiCfgId)
  self.id = 12618772
  self.wuShiCfgId = wuShiCfgId or nil
end
function CPutOnWuShi:marshal(os)
  os:marshalInt32(self.wuShiCfgId)
end
function CPutOnWuShi:unmarshal(os)
  self.wuShiCfgId = os:unmarshalInt32()
end
function CPutOnWuShi:sizepolicy(size)
  return size <= 65535
end
return CPutOnWuShi
