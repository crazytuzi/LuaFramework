local OctetsStream = require("netio.OctetsStream")
local WingSimpleData = class("WingSimpleData")
function WingSimpleData:ctor(curLv, curRank, checkWing)
  self.curLv = curLv or nil
  self.curRank = curRank or nil
  self.checkWing = checkWing or nil
end
function WingSimpleData:marshal(os)
  os:marshalInt32(self.curLv)
  os:marshalInt32(self.curRank)
  os:marshalInt32(self.checkWing)
end
function WingSimpleData:unmarshal(os)
  self.curLv = os:unmarshalInt32()
  self.curRank = os:unmarshalInt32()
  self.checkWing = os:unmarshalInt32()
end
return WingSimpleData
