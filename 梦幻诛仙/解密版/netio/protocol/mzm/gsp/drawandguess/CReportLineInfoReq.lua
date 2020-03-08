local CReportLineInfoReq = class("CReportLineInfoReq")
CReportLineInfoReq.TYPEID = 12617241
function CReportLineInfoReq:ctor(sessionId, line_id, color, size, point_list)
  self.id = 12617241
  self.sessionId = sessionId or nil
  self.line_id = line_id or nil
  self.color = color or nil
  self.size = size or nil
  self.point_list = point_list or {}
end
function CReportLineInfoReq:marshal(os)
  os:marshalInt64(self.sessionId)
  os:marshalInt32(self.line_id)
  os:marshalUInt8(self.color)
  os:marshalUInt8(self.size)
  os:marshalCompactUInt32(table.getn(self.point_list))
  for _, v in ipairs(self.point_list) do
    v:marshal(os)
  end
end
function CReportLineInfoReq:unmarshal(os)
  self.sessionId = os:unmarshalInt64()
  self.line_id = os:unmarshalInt32()
  self.color = os:unmarshalUInt8()
  self.size = os:unmarshalUInt8()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.drawandguess.PointInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.point_list, v)
  end
end
function CReportLineInfoReq:sizepolicy(size)
  return size <= 65535
end
return CReportLineInfoReq
