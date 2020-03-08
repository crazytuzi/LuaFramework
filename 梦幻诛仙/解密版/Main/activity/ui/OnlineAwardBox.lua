local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local OnlineAwardBox = Lplus.Extend(ECPanelBase, "OnlineAwardBox")
local def = OnlineAwardBox.define
local instance
def.field("number").timerId = 0
def.static("=>", OnlineAwardBox).Instance = function()
  if instance == nil then
    instance = OnlineAwardBox()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self.m_TrigGC = true
end
def.method().ShowDlg = function(self)
  if self:IsShow() then
    return
  end
  self:SetModal(true)
  self:CreatePanel(RESPATH.PREFEB_ONLINE_BOX, 0)
end
def.method().HideDlg = function(self)
  self:DestroyPanel()
end
def.method().sendGetBoxAward = function(self)
  local req = require("netio.protocol.mzm.gsp.activity.CGetOnlineBoxRewardReq").new()
  gmodule.network.sendProtocol(req)
end
def.override().OnCreate = function(self)
end
def.override("boolean").OnShow = function(self, b)
  if b then
    self.timerId = GameUtil.AddGlobalTimer(constant.OnlineTreasureBoxActivityConst.endGetAwardBoxTime, true, function()
      self.timerId = 0
      self:sendGetBoxAward()
      self:HideDlg()
    end)
  else
    warn("==========timerId:", self.timerId)
    if self.timerId ~= 0 then
      GameUtil.RemoveGlobalTimer(self.timerId)
    end
  end
end
def.override().OnDestroy = function(self)
end
def.method("string").onClick = function(self, id)
  warn("------onClick:", id)
  self:sendGetBoxAward()
  self:HideDlg()
end
return OnlineAwardBox.Commit()
