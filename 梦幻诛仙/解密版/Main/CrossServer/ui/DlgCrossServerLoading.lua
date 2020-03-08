local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgCrossServerLoading = Lplus.Extend(ECPanelBase, "DlgCrossServerLoading")
local def = DlgCrossServerLoading.define
local dlg
local GUIUtils = require("GUI.GUIUtils")
local RoleLadderCrossMatchInfo = require("netio.protocol.mzm.gsp.ladder.RoleLadderCrossMatchInfo")
def.field("number").sliderTimerId = -1
def.field("number").timeLeft = -1
def.field("table").headTextures = nil
def.field("boolean").isShow = false
def.static("=>", DlgCrossServerLoading).Instance = function()
  if dlg == nil then
    dlg = DlgCrossServerLoading()
  end
  return dlg
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.CROSS_SERVER, gmodule.notifyId.CrossServer.UPDATE_MATCH_PROGRESS, DlgCrossServerLoading.OnUpdateProgress)
  Timer:RegisterListener(self.UpdateTime, self)
end
def.method().ShowDlg = function(self)
  self.isShow = true
  if self.m_panel == nil then
    if _G.PlayerIsInFight() then
      return
    end
    self.headTextures = {}
    local tex_path = {}
    local mgr = gmodule.moduleMgr:GetModule(ModuleId.CROSS_SERVER)
    local teamInfos = mgr:GetMatchTeamInfos()
    for i = 1, 2 do
      local teamInfo = teamInfos[i]
      for j = 1, #teamInfo do
        local info = teamInfo[j]
        local key = string.format("CrossFight_%d_%d", info.occupation, info.gender)
        local path = string.format("Arts/Image/Icons/Functions/%s.png.u3dext", key)
        if self.headTextures[key] == nil then
          self.headTextures[key] = path
          table.insert(tex_path, path)
        end
      end
    end
    AsyncLoadArray(tex_path, function(texes)
      if self.isShow == false then
        return
      end
      for _, tex in pairs(texes) do
        self.headTextures[tex.name] = tex
      end
      self:CreatePanel(RESPATH.DLG_CROSS_SERVER_LOADING, -1)
      self:SetDepth(GUIDEPTH.TOP)
      self:SetModal(true)
    end)
  end
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  if _G.PlayerIsInFight() then
    self:Hide()
    return
  end
  self:ShowInfo()
  self.timeLeft = 60
end
def.method().Hide = function(self)
  self.headTextures = nil
  self:DestroyPanel()
  self.isShow = false
end
def.override().OnDestroy = function(self)
  if self.sliderTimerId > 0 then
    GameUtil.RemoveGlobalTimer(self.sliderTimerId)
    self.sliderTimerId = -1
  end
  Event.UnregisterEvent(ModuleId.CROSS_SERVER, gmodule.notifyId.CrossServer.UPDATE_MATCH_PROGRESS, DlgCrossServerLoading.OnUpdateProgress)
  Timer:RemoveListener(self.UpdateTime)
end
def.method().ShowInfo = function(self)
  if self.m_panel == nil then
    return
  end
  local teamInfos
  local group_name = {"Group_Red", "Group_Blue"}
  local teamIdx = 1
  local mgr = gmodule.moduleMgr:GetModule(ModuleId.CROSS_SERVER)
  local teamInfos = mgr:GetMatchTeamInfos()
  if teamInfos == nil then
    warn("[DlgCrossServerLoading]team infos is nil")
    return
  end
  for teamIdx = 1, 2 do
    local team_panel = self.m_panel:FindDirect(group_name[teamIdx])
    local teamInfo = teamInfos[teamIdx]
    for i = 1, 5 do
      local panel = team_panel:FindDirect("Img_Bg" .. i)
      if i <= #teamInfo then
        local info = teamInfo[i]
        panel:FindDirect("Group_Info1/Label_UserName"):GetComponent("UILabel").text = info.name
        local serverInfo = _G.GetRoleServerInfo(info.roleid)
        panel:FindDirect("Group_Info1/Label_ServerName"):GetComponent("UILabel").text = serverInfo and serverInfo.name or "unknown"
        local menpaiIcon = panel:FindDirect("Group_Info2/Img_MenPai")
        menpaiIcon:GetComponent("UISprite").spriteName = GUIUtils.GetOccupationSmallIcon(info.occupation)
        panel:FindDirect("Group_Info2/Label_Lv"):GetComponent("UILabel").text = tostring(info.level) .. textRes.Chat[58]
        local genderIcon = panel:FindDirect("Group_Info2/Img_Sex")
        GUIUtils.SetSprite(genderIcon, GUIUtils.GetSexIcon(info.gender))
        local headname = string.format("CrossFight_%d_%d", info.occupation, info.gender)
        local texture = self.headTextures[headname]
        if type(texture) == "string" then
          texture = nil
        end
        panel:FindDirect("Icon_Character"):GetComponent("UITexture").mainTexture = texture
        local duanweiIcon = panel:FindDirect("Group_Info2/Img_DuanWei")
        local phaseInfo = mgr:GetPhaseInfo(info.level, info.stage)
        if phaseInfo then
          duanweiIcon:GetComponent("UISprite").spriteName = phaseInfo.iconName
        end
        local slider = panel:FindDirect("Group_Info1/Slider"):GetComponent("UISlider")
        slider.value = info.process / RoleLadderCrossMatchInfo.LOGIN
      else
        panel:FindDirect("Group_Info1/Label_UserName"):GetComponent("UILabel").text = ""
        panel:FindDirect("Group_Info1/Label_ServerName"):GetComponent("UILabel").text = ""
        panel:FindDirect("Group_Info2/Label_Lv"):GetComponent("UILabel").text = ""
        panel:FindDirect("Group_Info2/Img_MenPai"):GetComponent("UISprite").spriteName = "0"
        panel:FindDirect("Group_Info2/Img_DuanWei"):GetComponent("UISprite").spriteName = ""
        panel:FindDirect("Icon_Character"):GetComponent("UITexture").mainTexture = nil
      end
    end
  end
  local count = 0
  local red_res = _G.GetEffectRes(702020075)
  local blue_res = _G.GetEffectRes(702020074)
  local function OnPlay()
    if self.m_panel == nil then
      return
    end
    count = count + 1
    if count > 5 then
      return
    end
    self.m_panel:FindDirect(group_name[1] .. "/Img_Bg" .. count):GetComponent("UIPlayTween"):Play(true)
    self.m_panel:FindDirect(group_name[2] .. "/Img_Bg" .. count):GetComponent("UIPlayTween"):Play(true)
    GameUtil.AddGlobalTimer(0.3, true, function()
      if self.m_panel == nil or count > 5 then
        return
      end
      if red_res then
        require("Fx.GUIFxMan").Instance():PlayAsChild(self.m_panel:FindDirect("Group_Red/Img_Bg" .. count), red_res.path, 0, 0, -1, false)
      end
      if blue_res then
        require("Fx.GUIFxMan").Instance():PlayAsChild(self.m_panel:FindDirect("Group_Blue/Img_Bg" .. count), blue_res.path, 0, 0, -1, false)
      end
      OnPlay()
    end)
  end
  GameUtil.AddGlobalTimer(0.1, true, OnPlay)
  if 0 >= self.sliderTimerId then
    self.sliderTimerId = GameUtil.AddGlobalTimer(0.1, false, DlgCrossServerLoading.UpdateSlider)
  end
end
def.method().ShowProgress = function(self)
  if self.m_panel == nil then
    return
  end
  local teamInfos = gmodule.moduleMgr:GetModule(ModuleId.CROSS_SERVER):GetMatchTeamInfos()
  if teamInfos == nil then
    return
  end
  local teamIdx = 1
  local group_name = {"Group_Red", "Group_Blue"}
  for teamIdx = 1, 2 do
    local team_panel = self.m_panel:FindDirect(group_name[teamIdx])
    local teamInfo = teamInfos[teamIdx]
    for i = 1, #teamInfo do
      local panel = team_panel:FindDirect("Img_Bg" .. i)
      local info = teamInfo[i]
      local slider = panel:FindDirect("Group_Info1/Slider"):GetComponent("UISlider")
      local value = info.process / RoleLadderCrossMatchInfo.LOGIN
      if value > slider.value then
        slider.value = slider.value + math.random(5) * 0.01
        if 1 < slider.value then
          slider.value = 1
        end
      end
    end
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Info" then
    self:Hide()
    require("Main.CrossServer.ui.DlgCrossServerTeam").Instance():ShowDlg()
  end
end
def.static("table", "table").OnUpdateProgress = function(p1, p2)
  if dlg == nil then
    return
  end
  dlg:ShowProgress()
end
def.static().UpdateSlider = function()
  if dlg == nil then
    return
  end
  dlg:ShowProgress()
end
def.method("number").UpdateTime = function(self, tick)
  self.timeLeft = self.timeLeft - tick
  if self.timeLeft < 0 then
    self.timeLeft = 0
  end
  if self.m_panel == nil then
    return
  end
  self.m_panel:FindDirect("Label_CountDown"):GetComponent("UILabel").text = tostring(self.timeLeft)
end
return DlgCrossServerLoading.Commit()
