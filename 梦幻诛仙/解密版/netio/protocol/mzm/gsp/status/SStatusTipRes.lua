local SStatusTipRes = class("SStatusTipRes")
SStatusTipRes.TYPEID = 12592388
function SStatusTipRes:ctor(ret)
  self.id = 12592388
  self.ret = ret or nil
end
function SStatusTipRes:marshal(os)
  os:marshalInt32(self.ret)
end
function SStatusTipRes:unmarshal(os)
  self.ret = os:unmarshalInt32()
end
function SStatusTipRes:sizepolicy(size)
  return size <= 65535
end
return SStatusTipRes
