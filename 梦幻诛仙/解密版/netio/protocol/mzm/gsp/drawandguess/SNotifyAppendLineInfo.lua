local SNotifyAppendLineInfo = class("SNotifyAppendLineInfo")
SNotifyAppendLineInfo.TYPEID = 12617228
function SNotifyAppendLineInfo:ctor(line_id, action_id, point_list)
  self.id = 12617228
  self.line_id = line_id or nil
  self.action_id = action_id or nil
  self.point_list = point_list or {}
end
function SNotifyAppendLineInfo:marshal(os)
  os:marshalInt32(self.line_id)
  os:marshalInt32(self.action_id)
  os:marshalCompactUInt32(table.getn(self.point_list))
  for _, v in ipairs(self.point_list) do
    v:marshal(os)
  end
end
function SNotifyAppendLineInfo:unmarshal(os)
  self.line_id = os:unmarshalInt32()
  self.action_id = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.drawandguess.PointInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.point_list, v)
  end
end
function SNotifyAppendLineInfo:sizepolicy(size)
  return size <= 65535
end
return SNotifyAppendLineInfo
