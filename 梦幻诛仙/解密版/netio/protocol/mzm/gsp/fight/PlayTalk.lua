local OctetsStream = require("netio.OctetsStream")
local PlayTalk = class("PlayTalk")
function PlayTalk:ctor(fighterid, strid, args)
  self.fighterid = fighterid or nil
  self.strid = strid or nil
  self.args = args or {}
end
function PlayTalk:marshal(os)
  os:marshalInt32(self.fighterid)
  os:marshalInt32(self.strid)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function PlayTalk:unmarshal(os)
  self.fighterid = os:unmarshalInt32()
  self.strid = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
return PlayTalk
