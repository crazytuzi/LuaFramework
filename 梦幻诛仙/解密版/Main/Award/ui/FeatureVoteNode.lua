local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local AloneNodeBase = require("Main.Award.ui.AloneNodeBase")
local FeatureVoteNode = Lplus.Extend(AloneNodeBase, CUR_CLASS_NAME)
local FeatureVoteMgr = require("Main.Vote.mgr.FeatureVoteMgr")
local def = FeatureVoteNode.define
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  AloneNodeBase.Init(self, base, node)
end
def.override("=>", "boolean").IsOpen = function(self)
  return FeatureVoteMgr.Instance():IsOpen()
end
def.override("=>", "boolean").IsHaveNotifyMessage = function(self)
  return FeatureVoteMgr.Instance():GetNotifyMessageCount() > 0
end
def.override("=>", ECPanelBase).CreatePanel = function(self)
  self.panel = require("Main.Award.ui.FeatureVotePanel").Instance()
  self.panel:ShowPanel()
  return self.panel
end
def.static("=>", "string").GetCurActivityName = function(self)
  local ActivityInterface = require("Main.activity.ActivityInterface")
  local activityId = FeatureVoteMgr.Instance():GetActivityId()
  local activityCfg = ActivityInterface.GetActivityCfgById(activityId)
  return activityCfg and activityCfg.activityName or "nil"
end
return FeatureVoteNode.Commit()
