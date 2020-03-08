local SGetShiTuTaskInfoRep = class("SGetShiTuTaskInfoRep")
SGetShiTuTaskInfoRep.TYPEID = 12601645
SGetShiTuTaskInfoRep.RESULT_SUCCESS = 1
SGetShiTuTaskInfoRep.RESULT_ERROR_NO_SHITU = 2
SGetShiTuTaskInfoRep.RESULT_ERROR_ROLE_INFO = 3
function SGetShiTuTaskInfoRep:ctor(result, args)
  self.id = 12601645
  self.result = result or nil
  self.args = args or {}
end
function SGetShiTuTaskInfoRep:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SGetShiTuTaskInfoRep:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SGetShiTuTaskInfoRep:sizepolicy(size)
  return size <= 65535
end
return SGetShiTuTaskInfoRep
