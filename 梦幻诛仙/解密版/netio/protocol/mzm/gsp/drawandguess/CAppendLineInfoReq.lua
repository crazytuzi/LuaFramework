local CAppendLineInfoReq = class("CAppendLineInfoReq")
CAppendLineInfoReq.TYPEID = 12617231
function CAppendLineInfoReq:ctor(sessionId, line_id, point_list)
  self.id = 12617231
  self.sessionId = sessionId or nil
  self.line_id = line_id or nil
  self.point_list = point_list or {}
end
function CAppendLineInfoReq:marshal(os)
  os:marshalInt64(self.sessionId)
  os:marshalInt32(self.line_id)
  os:marshalCompactUInt32(table.getn(self.point_list))
  for _, v in ipairs(self.point_list) do
    v:marshal(os)
  end
end
function CAppendLineInfoReq:unmarshal(os)
  self.sessionId = os:unmarshalInt64()
  self.line_id = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.drawandguess.PointInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.point_list, v)
  end
end
function CAppendLineInfoReq:sizepolicy(size)
  return size <= 65535
end
return CAppendLineInfoReq
