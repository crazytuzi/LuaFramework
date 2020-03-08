local OctetsStream = require("netio.OctetsStream")
local CorpsPointRaceData = require("netio.protocol.mzm.gsp.crossbattle.CorpsPointRaceData")
local ReportCorpsPointRaceReq = class("ReportCorpsPointRaceReq")
function ReportCorpsPointRaceReq:ctor(activity_cfgid, corpsid, time_point_cfgid, data)
  self.activity_cfgid = activity_cfgid or nil
  self.corpsid = corpsid or nil
  self.time_point_cfgid = time_point_cfgid or nil
  self.data = data or CorpsPointRaceData.new()
end
function ReportCorpsPointRaceReq:marshal(os)
  os:marshalInt32(self.activity_cfgid)
  os:marshalInt64(self.corpsid)
  os:marshalInt32(self.time_point_cfgid)
  self.data:marshal(os)
end
function ReportCorpsPointRaceReq:unmarshal(os)
  self.activity_cfgid = os:unmarshalInt32()
  self.corpsid = os:unmarshalInt64()
  self.time_point_cfgid = os:unmarshalInt32()
  self.data = CorpsPointRaceData.new()
  self.data:unmarshal(os)
end
return ReportCorpsPointRaceReq
