local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgTeamInfo = Lplus.Extend(ECPanelBase, "DlgTeamInfo")
local def = DlgTeamInfo.define
local dlg
local teamData = require("Main.Team.TeamData").Instance()
def.field("table").teamInfo = nil
def.static("=>", DlgTeamInfo).Instance = function()
  if dlg == nil then
    dlg = DlgTeamInfo()
  end
  return dlg
end
def.method("table").ShowDlg = function(self, teamInfo)
  if self.m_panel then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.DLG_TEAM_INFO_UI_RES, 2)
  self.teamInfo = teamInfo
  self:SetOutTouchDisappear()
  if self.m_panel then
    self:ShowTeamInfo()
  end
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  if self.teamInfo then
    self:ShowTeamInfo()
  end
end
def.method().Hide = function(self)
  self:DestroyPanel()
  self.teamInfo = nil
end
def.method().ShowTeamInfo = function(self)
  local teamPanel = self.m_panel:FindDirect("Img_BgTeamInfo")
  local i = 1
  for i = 1, 5 do
    local headPanel = teamPanel:FindDirect("Img_Head0" .. i)
    if headPanel ~= nil then
      local info = self.teamInfo[i]
      if info then
        headPanel:SetActive(true)
        _G.SetAvatarIcon(headPanel, info.avatarId)
        local frameIcon = headPanel:FindDirect("Img_AvatarFrame" .. i)
        _G.SetAvatarFrameIcon(frameIcon, info.avatarFrameid)
        headPanel:FindDirect("Label_Name0" .. i):GetComponent("UILabel"):set_text(info.name)
        headPanel:FindDirect("Label_School0" .. i):GetComponent("UILabel"):set_text(GetOccupationName(info.menpai))
        headPanel:FindDirect("Label_Lv0" .. i):GetComponent("UILabel"):set_text(info.level .. textRes.Team[2])
      else
        headPanel:SetActive(false)
      end
    end
  end
end
return DlgTeamInfo.Commit()
