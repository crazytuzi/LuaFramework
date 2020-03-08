local SAgreeOrRefuseMasterRecommendRep = class("SAgreeOrRefuseMasterRecommendRep")
SAgreeOrRefuseMasterRecommendRep.TYPEID = 12601659
SAgreeOrRefuseMasterRecommendRep.RESULT_SUCCESS = 1
SAgreeOrRefuseMasterRecommendRep.RESULT_ERROR_TIME_OUT = 2
SAgreeOrRefuseMasterRecommendRep.RESULT_ERROR_HAS_MASTER = 3
SAgreeOrRefuseMasterRecommendRep.RESULT_ERROR_ROLE_INFO = 4
function SAgreeOrRefuseMasterRecommendRep:ctor(result, operator, args)
  self.id = 12601659
  self.result = result or nil
  self.operator = operator or nil
  self.args = args or {}
end
function SAgreeOrRefuseMasterRecommendRep:marshal(os)
  os:marshalInt32(self.result)
  os:marshalInt32(self.operator)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SAgreeOrRefuseMasterRecommendRep:unmarshal(os)
  self.result = os:unmarshalInt32()
  self.operator = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SAgreeOrRefuseMasterRecommendRep:sizepolicy(size)
  return size <= 65535
end
return SAgreeOrRefuseMasterRecommendRep
