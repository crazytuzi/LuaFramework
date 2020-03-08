local SGetShiTuActiveInfoRep = class("SGetShiTuActiveInfoRep")
SGetShiTuActiveInfoRep.TYPEID = 12601656
SGetShiTuActiveInfoRep.RESULT_SUCCESS = 1
SGetShiTuActiveInfoRep.RESULT_ERROR_NO_SHITU = 2
SGetShiTuActiveInfoRep.RESULT_ERROR_ROLE_INFO = 3
function SGetShiTuActiveInfoRep:ctor(result, args)
  self.id = 12601656
  self.result = result or nil
  self.args = args or {}
end
function SGetShiTuActiveInfoRep:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SGetShiTuActiveInfoRep:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SGetShiTuActiveInfoRep:sizepolicy(size)
  return size <= 65535
end
return SGetShiTuActiveInfoRep
