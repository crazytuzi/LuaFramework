local Lplus = require("Lplus")
local GroupOperationBase = require("Main.Group.operations.GroupOperationBase")
local GroupInviteOperation = Lplus.Extend(GroupOperationBase, "GroupInviteOperation")
local def = GroupInviteOperation.define
def.field("userdata").m_GroupId = nil
def.override("userdata", "=>", "boolean").CanOperate = function(self, groupId)
  if nil == groupId then
    return false
  end
  self.m_GroupId = groupId
  return true
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Group.OperationName[2]
end
def.override("=>", "boolean").Operate = function(self)
  if nil == self.m_GroupId then
    return false
  end
  local GroupInvitePanel = require("Main.Group.ui.GroupInvitePanel")
  GroupInvitePanel.Instance():ShowPanel(self.m_GroupId)
  return true
end
GroupInviteOperation.Commit()
return GroupInviteOperation
