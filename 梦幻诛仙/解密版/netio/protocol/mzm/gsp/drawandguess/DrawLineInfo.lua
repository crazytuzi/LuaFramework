local OctetsStream = require("netio.OctetsStream")
local DrawLineInfo = class("DrawLineInfo")
function DrawLineInfo:ctor(line_id, action_id, color, size, point_list)
  self.line_id = line_id or nil
  self.action_id = action_id or nil
  self.color = color or nil
  self.size = size or nil
  self.point_list = point_list or {}
end
function DrawLineInfo:marshal(os)
  os:marshalInt32(self.line_id)
  os:marshalInt32(self.action_id)
  os:marshalUInt8(self.color)
  os:marshalUInt8(self.size)
  os:marshalCompactUInt32(table.getn(self.point_list))
  for _, v in ipairs(self.point_list) do
    v:marshal(os)
  end
end
function DrawLineInfo:unmarshal(os)
  self.line_id = os:unmarshalInt32()
  self.action_id = os:unmarshalInt32()
  self.color = os:unmarshalUInt8()
  self.size = os:unmarshalUInt8()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.drawandguess.PointInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.point_list, v)
  end
end
return DrawLineInfo
