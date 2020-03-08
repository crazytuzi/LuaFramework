local OctetsStream = require("netio.OctetsStream")
local PointInfo = class("PointInfo")
function PointInfo:ctor(point_x, point_y)
  self.point_x = point_x or nil
  self.point_y = point_y or nil
end
function PointInfo:marshal(os)
  os:marshalFloat(self.point_x)
  os:marshalFloat(self.point_y)
end
function PointInfo:unmarshal(os)
  self.point_x = os:unmarshalFloat()
  self.point_y = os:unmarshalFloat()
end
return PointInfo
