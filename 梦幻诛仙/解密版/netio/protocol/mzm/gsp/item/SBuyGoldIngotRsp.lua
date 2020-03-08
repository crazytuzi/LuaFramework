local SBuyGoldIngotRsp = class("SBuyGoldIngotRsp")
SBuyGoldIngotRsp.TYPEID = 12584840
function SBuyGoldIngotRsp:ctor(yuanbao_num, value)
  self.id = 12584840
  self.yuanbao_num = yuanbao_num or nil
  self.value = value or nil
end
function SBuyGoldIngotRsp:marshal(os)
  os:marshalInt32(self.yuanbao_num)
  os:marshalInt32(self.value)
end
function SBuyGoldIngotRsp:unmarshal(os)
  self.yuanbao_num = os:unmarshalInt32()
  self.value = os:unmarshalInt32()
end
function SBuyGoldIngotRsp:sizepolicy(size)
  return size <= 65535
end
return SBuyGoldIngotRsp
