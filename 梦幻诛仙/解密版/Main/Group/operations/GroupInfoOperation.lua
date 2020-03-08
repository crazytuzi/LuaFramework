local Lplus = require("Lplus")
local GroupOperationBase = require("Main.Group.operations.GroupOperationBase")
local GroupInfoOperation = Lplus.Extend(GroupOperationBase, "GroupInfoOperation")
local def = GroupInfoOperation.define
def.field("userdata").m_GroupId = nil
def.override("userdata", "=>", "boolean").CanOperate = function(self, groupId)
  if nil == groupId then
    return false
  end
  self.m_GroupId = groupId
  return true
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Group.OperationName[1]
end
def.override("=>", "boolean").Operate = function(self)
  if nil == self.m_GroupId then
    return false
  end
  local GroupModule = require("Main.Group.GroupModule")
  local groupBasicInfo = GroupModule.Instance():GetGroupBasicInfo(self.m_GroupId)
  if nil == groupBasicInfo then
    return false
  end
  local isInited = groupBasicInfo.isInited
  if isInited then
    local GroupSocialPanel = require("Main.Group.ui.GroupSocialPanel")
    GroupSocialPanel.Instance():ShowPanel(self.m_GroupId)
  else
    local protocolMgr = require("Main.Group.GroupProtocolMgr")
    protocolMgr.SetWaitForSingleInfo(true)
    protocolMgr.CSingleGroupInfoReq(groupBasicInfo.groupId, groupBasicInfo.groupVersion)
  end
  return true
end
GroupInfoOperation.Commit()
return GroupInfoOperation
