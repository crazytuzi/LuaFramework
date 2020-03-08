local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgCrossServerBattleResult = Lplus.Extend(ECPanelBase, "DlgCrossServerBattleResult")
local def = DlgCrossServerBattleResult.define
local dlg
local GUIUtils = require("GUI.GUIUtils")
def.field("table").roleScoreInfo = nil
def.field("number").timeLeft = constant.CrossServerConsts.leaveSec
def.field("boolean").isWin = true
def.static("=>", DlgCrossServerBattleResult).Instance = function()
  if dlg == nil then
    dlg = DlgCrossServerBattleResult()
  end
  return dlg
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, DlgCrossServerBattleResult.OnEnterWorld)
  Timer:RegisterListener(self.UpdateTime, self)
end
def.method("table", "boolean").ShowDlg = function(self, info, isWin)
  if info == nil then
    return
  end
  self.roleScoreInfo = info
  self.isWin = isWin
  self.timeLeft = constant.CrossServerConsts.leaveSec
  if self.m_panel == nil then
    self:CreatePanel(RESPATH.DLG_CROSS_SERVER_BATTLE_RESULT, -1)
    self:SetDepth(GUIDEPTH.TOP)
    self:SetModal(true)
  else
    self:ShowInfo()
  end
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  self:ShowInfo()
  self.m_panel:FindDirect("Img_Bg/Label_TimeCountDown"):GetComponent("UILabel").text = tostring(math.floor(self.timeLeft))
  self.m_panel:FindDirect("Img_Bg/Btn_Close"):GetComponent("UIButton"):set_isEnabled(false)
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.override().OnDestroy = function(self)
  self.roleScoreInfo = nil
  Timer:RemoveListener(self.UpdateTime)
  Event.UnregisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, DlgCrossServerBattleResult.OnEnterWorld)
end
def.method().ShowInfo = function(self)
  if self.m_panel == nil then
    return
  end
  self.m_panel:FindDirect("Img_Bg/Img_Win"):SetActive(self.isWin)
  self.m_panel:FindDirect("Img_Bg/Img_Loss"):SetActive(not self.isWin)
  local mgr = gmodule.moduleMgr:GetModule(ModuleId.CROSS_SERVER)
  local teamInfo = mgr:GetMyMatchTeamInfo()
  if teamInfo == nil then
    warn("[DlgCrossServerBattleResult]my match team info not found")
    return
  end
  local listcomp = self.m_panel:FindDirect("Img_Bg/Scroll View/List_Member"):GetComponent("UIList")
  listcomp.itemCount = #teamInfo
  listcomp:Resize()
  for i = 1, #teamInfo do
    local panel = self.m_panel:FindDirect("Img_Bg/Scroll View/List_Member/Img_List_" .. i)
    local menpaiIcon = panel:FindDirect("Img_MenPai_" .. i)
    menpaiIcon:GetComponent("UISprite").spriteName = GUIUtils.GetOccupationSmallIcon(teamInfo[i].occupation)
    local genderIcon = panel:FindDirect("Img_Sex_" .. i)
    GUIUtils.SetSprite(genderIcon, GUIUtils.GetSexIcon(teamInfo[i].gender))
    panel:FindDirect("Label_UserName_" .. i):GetComponent("UILabel").text = teamInfo[i].name
    panel:FindDirect("Label_Level_" .. i):GetComponent("UILabel").text = teamInfo[i].level
    local score = self.roleScoreInfo and self.roleScoreInfo[teamInfo[i].roleid:tostring()]
    local label_add = panel:FindDirect("Label_AddNum_" .. i)
    local isPositive = true
    if self.isWin then
      label_add:GetComponent("UILabel").text = "+"
    else
      label_add:GetComponent("UILabel").text = "-"
      isPositive = false
    end
    label_add:FindDirect("Label_Num_" .. i):GetComponent("UILabel").text = score and math.abs(score) or 0
    local headPanel = panel:FindDirect(string.format("Icon_Frame_%d/Icon_Head_%d", i, i))
    local frame = panel:FindDirect(string.format("Icon_Frame_%d/Icon_Bg_%d", i, i))
    _G.SetAvatarFrameIcon(frame, teamInfo[i].avatarFrameId)
    _G.SetAvatarIcon(headPanel, teamInfo[i].avatarId)
    local genderIcon = panel:FindDirect("Group_Info2/Img_Sex")
    GUIUtils.SetSprite(genderIcon, GUIUtils.GetSexIcon(teamInfo[i].gender))
    local cur_phase = mgr:GetPhaseByScore(teamInfo[i].level, teamInfo[i].matchScore, isPositive, teamInfo[i].stage)
    teamInfo[i].stage = cur_phase
    local cur_phase_info
    if cur_phase > 0 then
      cur_phase_info = mgr:GetPhaseInfo(teamInfo[i].level, cur_phase)
    end
    panel:FindDirect("DuanWeiNow_" .. i):GetComponent("UISprite").spriteName = cur_phase_info and cur_phase_info.iconName or "1"
    if not cur_phase_info or not cur_phase_info.name then
    end
    panel:FindDirect(string.format("DuanWeiNow_%d/Label_%d", i, i)):GetComponent("UILabel").text = tostring(cur_phase)
    local next_phase = cur_phase + 1
    local next_phase_info = mgr:GetPhaseInfo(teamInfo[i].level, next_phase)
    panel:FindDirect("DuanWeiLater_" .. i):GetComponent("UISprite").spriteName = next_phase_info and next_phase_info.iconName or "1"
    panel:FindDirect(string.format("DuanWeiLater_%d/Label_%d", i, i)):GetComponent("UILabel").text = next_phase_info and next_phase_info.name or cur_phase_info.name
    if cur_phase_info then
      local slider = panel:FindDirect("Slider_" .. i)
      local next_min = next_phase_info and next_phase_info.upMinScore or cur_phase_info.downMaxScore
      local rate = (teamInfo[i].matchScore - cur_phase_info.upMinScore) / (next_min - cur_phase_info.upMinScore)
      if rate < 0 then
        rate = 0
      end
      if rate > 1 then
        rate = 1
      end
      slider:GetComponent("UISlider").value = rate
      slider:FindDirect("Label_Num_" .. i):GetComponent("UILabel").text = string.format("%d/%d", teamInfo[i].matchScore, next_min)
    end
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:Hide()
  end
end
def.method("number").UpdateTime = function(self, tick)
  self.timeLeft = self.timeLeft - tick
  if self.timeLeft < 0 then
    self.timeLeft = 0
    self:Hide()
  end
  if self.m_panel == nil then
    return
  end
  self.m_panel:FindDirect("Img_Bg/Label_TimeCountDown"):GetComponent("UILabel").text = tostring(math.floor(self.timeLeft))
end
def.static("table", "table").OnEnterWorld = function(p1, p2)
  if dlg and dlg.m_panel then
    dlg.m_panel:FindDirect("Img_Bg/Btn_Close"):GetComponent("UIButton"):set_isEnabled(true)
  end
end
return DlgCrossServerBattleResult.Commit()
