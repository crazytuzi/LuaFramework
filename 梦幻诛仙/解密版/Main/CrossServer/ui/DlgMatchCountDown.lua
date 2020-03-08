local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgMatchCountDown = Lplus.Extend(ECPanelBase, "DlgMatchCountDown")
local def = DlgMatchCountDown.define
local dlg
local teamData = require("Main.Team.TeamData").Instance()
def.field("number").matchedTime = 0
def.static("=>", DlgMatchCountDown).Instance = function()
  if dlg == nil then
    dlg = DlgMatchCountDown()
  end
  return dlg
end
def.override().OnCreate = function(self)
  Timer:RegisterListener(self.UpdateTime, self)
end
def.method().ShowDlg = function(self)
  if self.m_panel then
    return
  end
  self:CreatePanel(RESPATH.DLG_CROSS_SERVER_MATCH_COUNT_DOWN, 2)
  self:SetDepth(GUIDEPTH.TOP)
  self:SetModal(true)
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  if IsCrossingServer() then
    self:Hide()
    return
  end
  self.matchedTime = 0
  self:ShowMatchTime()
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.override().OnDestroy = function(self)
  Timer:RemoveListener(self.UpdateTime)
end
def.method().ShowMatchTime = function(self)
  if self.m_panel == nil then
    return
  end
  local timePanel = self.m_panel:FindDirect("Group_CountDown")
  if self.matchedTime < 0 then
    return
  end
  timePanel:SetActive(true)
  timePanel:FindDirect("Label1/Label_Num"):GetComponent("UILabel").text = "0"
  timePanel:FindDirect("Label3/Label_Num"):GetComponent("UILabel").text = "30"
end
def.method("string").onClick = function(self, id)
  if id == "Btn_QuitMatch" then
    require("GUI.CommonConfirmDlg").ShowConfirm("", textRes.CrossServer[6], function(i, tag)
      if i == 1 then
        gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.ladder.CLadderUnMatchReq").new())
      end
    end, {id = self})
  end
end
def.method("number").UpdateTime = function(self, tick)
  if self.matchedTime < 0 then
    return
  end
  self.matchedTime = self.matchedTime + tick
  if self.m_panel == nil then
    return
  end
  local timePanel = self.m_panel:FindDirect("Group_CountDown")
  timePanel:FindDirect("Label1/Label_Num"):GetComponent("UILabel").text = tostring(self.matchedTime)
end
return DlgMatchCountDown.Commit()
