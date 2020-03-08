local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local CrossBattleFightLoadingPanel = Lplus.Extend(ECPanelBase, "CrossBattleFightLoadingPanel")
local GUIUtils = require("GUI.GUIUtils")
local CrossBattleSelectionProcessInfo = require("netio.protocol.mzm.gsp.crossbattle.CrossBattleSelectionProcessInfo")
local EC = require("Types.Vector3")
local CorpsUtils = require("Main.Corps.CorpsUtils")
local def = CrossBattleFightLoadingPanel.define
def.field("table").uiObjs = nil
def.field("table").matchInfo = nil
def.field("number").waitTime = 0
def.field("number").timerId = 0
def.field("table").headTextures = nil
def.field("number").sliderTimerId = -1
def.field("number").mainEffectId = 0
def.field("number").subEffectId = 0
def.field("table").effects = nil
def.field("boolean").isHide = false
local instance
def.static("=>", CrossBattleFightLoadingPanel).Instance = function()
  if instance == nil then
    instance = CrossBattleFightLoadingPanel()
  end
  return instance
end
def.method("table", "number", "number", "number").ShowPanel = function(self, matchInfo, waitTime, mainEffectId, subEffectId)
  if self:IsShow() then
    return
  end
  self.matchInfo = matchInfo
  self.waitTime = waitTime
  self.mainEffectId = mainEffectId
  self.subEffectId = subEffectId
  self.headTextures = {}
  self.isHide = false
  local tex_path = {}
  for i = 1, 2 do
    local roles = self.matchInfo[i]:GetRoles()
    for j = 1, #roles do
      local info = roles[j]
      local key = string.format("CrossFight_%d_%d", info:GetOccupation(), info:GetGender())
      local path = string.format("Arts/Image/Icons/Functions/%s.png.u3dext", key)
      if self.headTextures[key] == nil then
        self.headTextures[key] = path
        table.insert(tex_path, path)
      end
    end
  end
  AsyncLoadArray(tex_path, function(texes)
    self.headTextures = {}
    for _, tex in pairs(texes) do
      self.headTextures[tex.name] = tex
    end
    if self.isHide then
      self:OnDestroy()
      return
    end
    self:CreatePanel(RESPATH.PREFAB_TEAM_PVP_CROSS_FIGHT_LOADING, -1)
    self:SetDepth(GUIDEPTH.TOP)
    self:SetModal(true)
  end)
end
def.override().OnCreate = function(self)
  if self.isHide then
    self:DestroyPanel()
    return
  end
  self:InitUI()
  self:ShowMatchInfo()
  self:UpdateWaitTime()
  self:StartTimer()
end
def.override().OnDestroy = function(self)
  if self.headTextures then
    for _, tex in pairs(self.headTextures) do
      Object.DestroyImmediate(tex, true)
    end
  end
  self.headTextures = nil
  if self.sliderTimerId > 0 then
    GameUtil.RemoveGlobalTimer(self.sliderTimerId)
    self.sliderTimerId = -1
  end
  if self.effects then
    for _, v in pairs(self.effects) do
      Object.DestroyImmediate(v, true)
    end
    self.effects = nil
  end
  self:StopTimer()
  self.uiObjs = nil
  self.matchInfo = nil
  self.mainEffectId = 0
  self.subEffectId = 0
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Label_CountDown = self.m_panel:FindDirect("Label_CountDown")
  self.uiObjs.Fx_RaceMainLv = self.m_panel:FindDirect("Fx_RaceMainLv")
  self.uiObjs.Fx_RaceSubLv = self.m_panel:FindDirect("Fx_RaceSubLv")
  self.effects = {}
end
def.method().ShowMatchInfo = function(self)
  if not self:IsLoaded() then
    return
  end
  if self.matchInfo == nil then
    return
  end
  local groupName = {"Group_Red", "Group_Blue"}
  local corpsName = {
    "Group_RedName",
    "Group_BlueName"
  }
  for corpsIdx = 1, 2 do
    local corpsInfo = self.matchInfo[corpsIdx]
    local CorpsName = self.m_panel:FindDirect(corpsName[corpsIdx])
    GUIUtils.SetText(CorpsName:FindDirect("Label_Name"), corpsInfo:GetCorpsName())
    local cfg = CorpsUtils.GetCorpsBadgeCfg(corpsInfo:GetCorpsIcon())
    if cfg == nil then
      GUIUtils.FillIcon(CorpsName:FindDirect("Team_Badge"):GetComponent("UITexture"), 0)
    else
      GUIUtils.FillIcon(CorpsName:FindDirect("Team_Badge"):GetComponent("UITexture"), cfg.iconId)
    end
    local teamCroup = self.m_panel:FindDirect(groupName[corpsIdx])
    local roles = corpsInfo:GetRoles()
    for i = 1, 5 do
      local rolesGroup = teamCroup:FindDirect("Img_Bg" .. i)
      if i <= #roles then
        local roleData = roles[i]
        GUIUtils.SetText(rolesGroup:FindDirect("Group_Info1/Label_UserName"), roleData:GetRoleName())
        GUIUtils.SetSprite(rolesGroup:FindDirect("Group_Info2/Img_MenPai"), GUIUtils.GetOccupationSmallIcon(roleData:GetOccupation()))
        GUIUtils.SetText(rolesGroup:FindDirect("Group_Info2/Label_Lv"), tostring(roleData:GetRoleLevel()) .. textRes.Chat[58])
        local serverInfo = _G.GetRoleServerInfo(roleData:GetRoleId())
        GUIUtils.SetText(rolesGroup:FindDirect("Group_Info1/Label_ServerName"), serverInfo and serverInfo.name or "unknown")
        GUIUtils.SetSprite(rolesGroup:FindDirect("Group_Info2/Img_MenPai"), GUIUtils.GetOccupationSmallIcon(roleData:GetOccupation()))
        local headname = string.format("CrossFight_%d_%d", roleData:GetOccupation(), roleData:GetGender())
        local Icon_Character = rolesGroup:FindDirect("Icon_Character")
        local texture = self.headTextures[headname]
        if type(texture) == "string" then
          texture = nil
        end
        Icon_Character:GetComponent("UITexture").mainTexture = texture
        Icon_Character.localPosition = EC.Vector3.zero
        local slider = rolesGroup:FindDirect("Group_Info1/Slider"):GetComponent("UISlider")
        slider.value = roleData:GetProgress() / CrossBattleSelectionProcessInfo.LOGIN
        local Img_Sex = rolesGroup:FindDirect("Group_Info2/Img_Sex")
        GUIUtils.SetSprite(Img_Sex, GUIUtils.GetGenderSprite(roleData:GetGender()))
      else
        GUIUtils.SetText(rolesGroup:FindDirect("Group_Info1/Label_UserName"), "")
        GUIUtils.SetText(rolesGroup:FindDirect("Group_Info1/Label_ServerName"), "")
        GUIUtils.SetText(rolesGroup:FindDirect("Group_Info2/Label_Lv"), "")
        GUIUtils.SetSprite(rolesGroup:FindDirect("Group_Info2/Img_MenPai"), "0")
        GUIUtils.SetSprite(rolesGroup:FindDirect("Group_Info2/Img_DuanWei"), "")
        rolesGroup:FindDirect("Icon_Character"):GetComponent("UITexture").mainTexture = nil
        local Img_Sex = rolesGroup:FindDirect("Group_Info2/Img_Sex")
        GUIUtils.SetSprite(Img_Sex, "")
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
    self.m_panel:FindDirect(groupName[1] .. "/Img_Bg" .. count):GetComponent("UIPlayTween"):Play(true)
    self.m_panel:FindDirect(groupName[2] .. "/Img_Bg" .. count):GetComponent("UIPlayTween"):Play(true)
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
    self.sliderTimerId = GameUtil.AddGlobalTimer(0.1, false, function()
      self:ShowProgress()
    end)
  end
  local function OnLoadEffect(objName, obj, container)
    if self.effects == nil then
      return
    end
    if obj == null then
      warn("[CrossBattleLoadingPanel]asycload obj is nil: ", effres)
      return
    end
    local eff = Object.Instantiate(obj, "GameObject")
    eff:SetActive(false)
    eff:SetLayer(ClientDef_Layer.UI, true)
    local effectName = tostring(objName)
    eff.name = effectName
    local uiparticle = container:GetComponent("UIParticle")
    if uiparticle == nil then
      uiparticle = container:AddComponent("UIParticle")
    end
    uiparticle.modelGameObject = eff
    uiparticle.depth = 100
    eff.parent = container
    eff.localPosition = EC.Vector3.zero
    eff.localScale = EC.Vector3.one
    eff:SetActive(true)
    self.effects[effectName] = obj
  end
  local mainEffectCfg = _G.GetEffectRes(self.mainEffectId)
  if mainEffectCfg then
    GameUtil.AsyncLoad(mainEffectCfg.path, function(obj)
      if self.uiObjs == nil then
        return
      end
      OnLoadEffect(self.mainEffectId, obj, self.uiObjs.Fx_RaceMainLv)
    end)
  end
  local subEffectCfg = _G.GetEffectRes(self.subEffectId)
  if subEffectCfg then
    GameUtil.AsyncLoad(subEffectCfg.path, function(obj)
      if self.uiObjs == nil then
        return
      end
      OnLoadEffect(self.subEffectId, obj, self.uiObjs.Fx_RaceSubLv)
    end)
  end
  GUIUtils.SetActive(self.m_panel:FindDirect(corpsName[1]), false)
  GUIUtils.SetActive(self.m_panel:FindDirect(corpsName[2]), false)
  GameUtil.AddGlobalTimer(3, true, function()
    if self.uiObjs == nil then
      return
    end
    GUIUtils.SetActive(self.uiObjs.Fx_RaceMainLv, false)
    GUIUtils.SetActive(self.uiObjs.Fx_RaceSubLv, false)
    GUIUtils.SetActive(self.m_panel:FindDirect(corpsName[1]), true)
    GUIUtils.SetActive(self.m_panel:FindDirect(corpsName[2]), true)
  end)
end
def.method().ShowProgress = function(self)
  if not self:IsLoaded() then
    return
  end
  if self.matchInfo == nil then
    return
  end
  local groupName = {"Group_Red", "Group_Blue"}
  for teamIdx = 1, 2 do
    local teamCroup = self.m_panel:FindDirect(groupName[teamIdx])
    local roles = self.matchInfo[teamIdx]:GetRoles()
    for i = 1, #roles do
      local roleGroup = teamCroup:FindDirect("Img_Bg" .. i)
      local roleData = roles[i]
      local slider = roleGroup:FindDirect("Group_Info1/Slider"):GetComponent("UISlider")
      local value = roleData:GetProgress() / CrossBattleSelectionProcessInfo.LOGIN
      if value > slider.value then
        slider.value = slider.value + math.random(5) * 0.01
        if 1 < slider.value then
          slider.value = 1
        end
      end
    end
  end
end
def.method("table").UpdateProgress = function(self, matchInfo)
  if not self:IsCreated() then
    return
  end
  self.matchInfo = matchInfo
  self:ShowProgress()
end
def.method().StartTimer = function(self)
  if self.timerId == 0 then
    self.timerId = GameUtil.AddGlobalTimer(1, false, function()
      self:Tick()
      self:UpdateWaitTime()
    end)
  end
end
def.method().Tick = function(self)
  if self.waitTime <= 0 then
    self.waitTime = 0
    return
  end
  self.waitTime = self.waitTime - 1
end
def.method().UpdateWaitTime = function(self)
  if self.uiObjs == nil then
    return
  end
  GUIUtils.SetText(self.uiObjs.Label_CountDown, self.waitTime)
end
def.method().StopTimer = function(self)
  if self.timerId > 0 then
    GameUtil.RemoveGlobalTimer(self.timerId)
    self.timerId = 0
  end
end
def.method().Hide = function(self)
  self.isHide = true
  self:DestroyPanel()
end
CrossBattleFightLoadingPanel.Commit()
return CrossBattleFightLoadingPanel
