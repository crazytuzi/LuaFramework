local OctetsStream = require("netio.OctetsStream")
local GrcPassedFriendInfo = class("GrcPassedFriendInfo")
function GrcPassedFriendInfo:ctor(nickname, figure_url)
  self.nickname = nickname or nil
  self.figure_url = figure_url or nil
end
function GrcPassedFriendInfo:marshal(os)
  os:marshalOctets(self.nickname)
  os:marshalOctets(self.figure_url)
end
function GrcPassedFriendInfo:unmarshal(os)
  self.nickname = os:unmarshalOctets()
  self.figure_url = os:unmarshalOctets()
end
return GrcPassedFriendInfo
