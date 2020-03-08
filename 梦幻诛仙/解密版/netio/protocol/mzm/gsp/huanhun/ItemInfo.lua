local OctetsStream = require("netio.OctetsStream")
local RoleBaseInfo = require("netio.protocol.mzm.gsp.huanhun.RoleBaseInfo")
local ItemInfo = class("ItemInfo")
ItemInfo.ST_TASK_ING = 0
ItemInfo.ST_TASK_DONE = 1
ItemInfo.ST_HELP__FALSE = 0
ItemInfo.ST_HELP__TRUE = 1
function ItemInfo:ctor(itemCfgId, awardXiuLianExp, itemNum, taskState, gangHelpState, friendHelpState, roleInfo)
  self.itemCfgId = itemCfgId or nil
  self.awardXiuLianExp = awardXiuLianExp or nil
  self.itemNum = itemNum or nil
  self.taskState = taskState or nil
  self.gangHelpState = gangHelpState or nil
  self.friendHelpState = friendHelpState or nil
  self.roleInfo = roleInfo or RoleBaseInfo.new()
end
function ItemInfo:marshal(os)
  os:marshalInt32(self.itemCfgId)
  os:marshalInt32(self.awardXiuLianExp)
  os:marshalInt32(self.itemNum)
  os:marshalInt32(self.taskState)
  os:marshalInt32(self.gangHelpState)
  os:marshalInt32(self.friendHelpState)
  self.roleInfo:marshal(os)
end
function ItemInfo:unmarshal(os)
  self.itemCfgId = os:unmarshalInt32()
  self.awardXiuLianExp = os:unmarshalInt32()
  self.itemNum = os:unmarshalInt32()
  self.taskState = os:unmarshalInt32()
  self.gangHelpState = os:unmarshalInt32()
  self.friendHelpState = os:unmarshalInt32()
  self.roleInfo = RoleBaseInfo.new()
  self.roleInfo:unmarshal(os)
end
return ItemInfo
