local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgCrossServerCharMenu = Lplus.Extend(ECPanelBase, "DlgCrossServerCharMenu")
local def = DlgCrossServerCharMenu.define
local dlg
local GUIUtils = require("GUI.GUIUtils")
def.field("table").roleInfo = nil
def.static("=>", DlgCrossServerCharMenu).Instance = function()
  if dlg == nil then
    dlg = DlgCrossServerCharMenu()
  end
  return dlg
end
def.override().OnCreate = function(self)
end
def.method("table").ShowDlg = function(self, info)
  if info == nil then
    return
  end
  self.roleInfo = info
  if self.m_panel then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.DLG_CROSS_SERVER_CHAR_MENU, 2)
  self:SetOutTouchDisappear()
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  self:ShowInfo()
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.override().OnDestroy = function(self)
  self.roleInfo = nil
end
def.method().ShowInfo = function(self)
  if self.m_panel == nil then
    return
  end
  local btn = self.m_panel:FindDirect("Img_BgMenu/Grid_Btn/Btn_Info")
  if require("Main.Team.TeamData").Instance():MeIsCaptain() == true and not gmodule.moduleMgr:GetModule(ModuleId.CROSS_SERVER):IsReady(self.roleInfo.roleid) then
    btn:SetActive(true)
    btn:FindDirect("Label_Info"):GetComponent("UILabel").text = textRes.CrossServer[41]
  else
    btn:SetActive(false)
  end
  local panel_info = self.m_panel:FindDirect("Img_BgMenu/Group_PlayerInfo")
  if panel_info == nil then
    return
  end
  local headPanel = panel_info:FindDirect("Img_BgTitle/Icon_Head")
  local frame = panel_info:FindDirect("Img_BgTitle/Img_BgHead")
  _G.SetAvatarFrameIcon(frame, self.roleInfo.avatarFrameId)
  _G.SetAvatarIcon(headPanel, self.roleInfo.avatarId)
  local serverInfo = _G.GetRoleServerInfo(self.roleInfo.roleid)
  panel_info:FindDirect("Label_ServerName"):GetComponent("UILabel").text = serverInfo and serverInfo.name or "unknown"
  panel_info:FindDirect("Label_UserName"):GetComponent("UILabel").text = self.roleInfo.name
  panel_info:FindDirect("Label_Lv"):GetComponent("UILabel").text = self.roleInfo.level
  local phaseInfo
  if self.roleInfo.stage > 0 then
    phaseInfo = gmodule.moduleMgr:GetModule(ModuleId.CROSS_SERVER):GetPhaseInfo(self.roleInfo.level, self.roleInfo.stage)
  end
  if not phaseInfo or not phaseInfo.name then
  end
  panel_info:FindDirect("Label_DuanWei/Label_Num"):GetComponent("UILabel").text = tostring(self.roleInfo.stage)
  local rate = 0
  if 0 < self.roleInfo.winCount + self.roleInfo.loseCount then
    rate = self.roleInfo.winCount * 100 / (self.roleInfo.winCount + self.roleInfo.loseCount)
  end
  panel_info:FindDirect("Label_Rate/Label_Num"):GetComponent("UILabel").text = string.format("%d%%", rate)
  panel_info:FindDirect("Label_Loss/Label_Num"):GetComponent("UILabel").text = string.format("%d/%d", self.roleInfo.winCount, self.roleInfo.loseCount)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Info" then
    if self.roleInfo then
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.ladder.CLeaderRemendMemberReq").new(self.roleInfo.roleid))
    end
    self:Hide()
  elseif id == "Btn_Tips" then
    self:Hide()
    gmodule.moduleMgr:GetModule(ModuleId.CROSS_SERVER):RequestMyLadderInfo()
  end
end
return DlgCrossServerCharMenu.Commit()
