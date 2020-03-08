local CBuyGoldIngotReq = class("CBuyGoldIngotReq")
CBuyGoldIngotReq.TYPEID = 12584839
function CBuyGoldIngotReq:ctor(yuanbao_num, client_yuanbao)
  self.id = 12584839
  self.yuanbao_num = yuanbao_num or nil
  self.client_yuanbao = client_yuanbao or nil
end
function CBuyGoldIngotReq:marshal(os)
  os:marshalInt32(self.yuanbao_num)
  os:marshalInt64(self.client_yuanbao)
end
function CBuyGoldIngotReq:unmarshal(os)
  self.yuanbao_num = os:unmarshalInt32()
  self.client_yuanbao = os:unmarshalInt64()
end
function CBuyGoldIngotReq:sizepolicy(size)
  return size <= 65535
end
return CBuyGoldIngotReq
