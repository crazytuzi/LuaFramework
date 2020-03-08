local SGetMiBaoInfo = class("SGetMiBaoInfo")
SGetMiBaoInfo.TYPEID = 12603393
function SGetMiBaoInfo:ctor(current_lucky_value, current_score, current_mibao_index_id)
  self.id = 12603393
  self.current_lucky_value = current_lucky_value or nil
  self.current_score = current_score or nil
  self.current_mibao_index_id = current_mibao_index_id or nil
end
function SGetMiBaoInfo:marshal(os)
  os:marshalInt32(self.current_lucky_value)
  os:marshalInt32(self.current_score)
  os:marshalInt32(self.current_mibao_index_id)
end
function SGetMiBaoInfo:unmarshal(os)
  self.current_lucky_value = os:unmarshalInt32()
  self.current_score = os:unmarshalInt32()
  self.current_mibao_index_id = os:unmarshalInt32()
end
function SGetMiBaoInfo:sizepolicy(size)
  return size <= 65535
end
return SGetMiBaoInfo
