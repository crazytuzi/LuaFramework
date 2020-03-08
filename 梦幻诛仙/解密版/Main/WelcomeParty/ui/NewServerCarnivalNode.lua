local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local AloneNodeBase = require("Main.Award.ui.AloneNodeBase")
local NewServerCarnivalNode = Lplus.Extend(AloneNodeBase, NewServerCarnivalNode)
local NewServerAwardMgr = require("Main.Award.mgr.NewServerAwardMgr")
local newServerAwardMgr = NewServerAwardMgr.Instance()
local def = NewServerCarnivalNode.define
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  AloneNodeBase.Init(self, base, node)
end
def.override("=>", ECPanelBase).CreatePanel = function(self)
  self.panel = require("Main.WelcomeParty.ui.UINewServerCarnival").Instance()
  if not self.panel:IsShow() then
    self.panel:ShowPanel()
  end
  return self.panel
end
def.override("=>", "boolean").IsOpen = function(self)
  return newServerAwardMgr:isOpenNewServerActivity()
end
def.override("=>", "boolean").IsHaveNotifyMessage = function(self)
  if self:IsOpen() then
    local tabId, index, isHaveAward = newServerAwardMgr:getCanGetAwardTabId()
    local isScoreAward = newServerAwardMgr:isOwnScoreAward()
    return isHaveAward or isScoreAward
  end
  return false
end
return NewServerCarnivalNode.Commit()
