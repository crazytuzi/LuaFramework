local OctetsStream = require("netio.OctetsStream")
local PlayCapture = class("PlayCapture")
PlayCapture.CAPTURE_SUCCESS = 0
PlayCapture.CAPTURE_FAIL = 1
function PlayCapture:ctor(fighterid, capturedFighterid, result)
  self.fighterid = fighterid or nil
  self.capturedFighterid = capturedFighterid or nil
  self.result = result or nil
end
function PlayCapture:marshal(os)
  os:marshalInt32(self.fighterid)
  os:marshalInt32(self.capturedFighterid)
  os:marshalInt32(self.result)
end
function PlayCapture:unmarshal(os)
  self.fighterid = os:unmarshalInt32()
  self.capturedFighterid = os:unmarshalInt32()
  self.result = os:unmarshalInt32()
end
return PlayCapture
