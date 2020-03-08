local OctetsStream = require("netio.OctetsStream")
local CakeHistory = class("CakeHistory")
CakeHistory.HISTORY_TYPE__COOK = 1
function CakeHistory:ctor(historyType, recordTime, makeRoleName, masterName, itemId, orgRank, newRank)
  self.historyType = historyType or nil
  self.recordTime = recordTime or nil
  self.makeRoleName = makeRoleName or nil
  self.masterName = masterName or nil
  self.itemId = itemId or nil
  self.orgRank = orgRank or nil
  self.newRank = newRank or nil
end
function CakeHistory:marshal(os)
  os:marshalInt32(self.historyType)
  os:marshalInt64(self.recordTime)
  os:marshalOctets(self.makeRoleName)
  os:marshalOctets(self.masterName)
  os:marshalInt32(self.itemId)
  os:marshalInt32(self.orgRank)
  os:marshalInt32(self.newRank)
end
function CakeHistory:unmarshal(os)
  self.historyType = os:unmarshalInt32()
  self.recordTime = os:unmarshalInt64()
  self.makeRoleName = os:unmarshalOctets()
  self.masterName = os:unmarshalOctets()
  self.itemId = os:unmarshalInt32()
  self.orgRank = os:unmarshalInt32()
  self.newRank = os:unmarshalInt32()
end
return CakeHistory
