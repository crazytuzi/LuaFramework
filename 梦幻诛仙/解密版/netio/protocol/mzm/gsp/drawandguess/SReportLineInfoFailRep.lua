local SReportLineInfoFailRep = class("SReportLineInfoFailRep")
SReportLineInfoFailRep.TYPEID = 12617245
SReportLineInfoFailRep.ERROR_SYSTEM = -1
SReportLineInfoFailRep.ERROR_USERID = -2
SReportLineInfoFailRep.ERROR_CFG = -3
SReportLineInfoFailRep.ERROR_ANSWERER_CANNOT_DRAW = -4
SReportLineInfoFailRep.ERROR_CAN_NOT_JOIN_ACTIVITY = -5
SReportLineInfoFailRep.ERROR_NOT_IN_TEAM = -6
SReportLineInfoFailRep.ERROR_TIME_OUT = -7
SReportLineInfoFailRep.ERROR_POINTS_ILLEGAL = -8
SReportLineInfoFailRep.ERROR_NOT_IN_GAME = -9
function SReportLineInfoFailRep:ctor(error_code, params)
  self.id = 12617245
  self.error_code = error_code or nil
  self.params = params or {}
end
function SReportLineInfoFailRep:marshal(os)
  os:marshalInt32(self.error_code)
  os:marshalCompactUInt32(table.getn(self.params))
  for _, v in ipairs(self.params) do
    os:marshalString(v)
  end
end
function SReportLineInfoFailRep:unmarshal(os)
  self.error_code = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.params, v)
  end
end
function SReportLineInfoFailRep:sizepolicy(size)
  return size <= 65535
end
return SReportLineInfoFailRep
