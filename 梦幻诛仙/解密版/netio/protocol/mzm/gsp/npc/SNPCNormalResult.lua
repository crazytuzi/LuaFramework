local SNPCNormalResult = class("SNPCNormalResult")
SNPCNormalResult.TYPEID = 12586761
SNPCNormalResult.NPC_SERVICE_BUFF_ALREADY_HAVE = 1
SNPCNormalResult.NPC_SERVICE_IS_FORBIDDEN = 100
function SNPCNormalResult:ctor(result, args)
  self.id = 12586761
  self.result = result or nil
  self.args = args or {}
end
function SNPCNormalResult:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SNPCNormalResult:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SNPCNormalResult:sizepolicy(size)
  return size <= 65535
end
return SNPCNormalResult
