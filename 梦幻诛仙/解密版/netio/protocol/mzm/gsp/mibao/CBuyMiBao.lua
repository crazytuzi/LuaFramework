local CBuyMiBao = class("CBuyMiBao")
CBuyMiBao.TYPEID = 12603397
function CBuyMiBao:ctor(current_currency_value, current_mibao_index_id, buy_times, is_use_yuan_bao, client_need_yuan_bao)
  self.id = 12603397
  self.current_currency_value = current_currency_value or nil
  self.current_mibao_index_id = current_mibao_index_id or nil
  self.buy_times = buy_times or nil
  self.is_use_yuan_bao = is_use_yuan_bao or nil
  self.client_need_yuan_bao = client_need_yuan_bao or nil
end
function CBuyMiBao:marshal(os)
  os:marshalInt64(self.current_currency_value)
  os:marshalInt32(self.current_mibao_index_id)
  os:marshalInt32(self.buy_times)
  os:marshalInt32(self.is_use_yuan_bao)
  os:marshalInt32(self.client_need_yuan_bao)
end
function CBuyMiBao:unmarshal(os)
  self.current_currency_value = os:unmarshalInt64()
  self.current_mibao_index_id = os:unmarshalInt32()
  self.buy_times = os:unmarshalInt32()
  self.is_use_yuan_bao = os:unmarshalInt32()
  self.client_need_yuan_bao = os:unmarshalInt32()
end
function CBuyMiBao:sizepolicy(size)
  return size <= 65535
end
return CBuyMiBao
