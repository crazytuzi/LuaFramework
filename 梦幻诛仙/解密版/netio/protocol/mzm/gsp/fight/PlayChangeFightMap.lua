local OctetsStream = require("netio.OctetsStream")
local PlayChangeFightMap = class("PlayChangeFightMap")
function PlayChangeFightMap:ctor(mapSource)
  self.mapSource = mapSource or nil
end
function PlayChangeFightMap:marshal(os)
  os:marshalInt32(self.mapSource)
end
function PlayChangeFightMap:unmarshal(os)
  self.mapSource = os:unmarshalInt32()
end
return PlayChangeFightMap
