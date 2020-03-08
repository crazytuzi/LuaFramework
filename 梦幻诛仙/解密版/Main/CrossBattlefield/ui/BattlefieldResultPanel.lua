local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local BattlefieldResultPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local CrossBattlefieldUtils = require("Main.CrossBattlefield.CrossBattlefieldUtils")
local CrossBattlefieldModule = require("Main.CrossBattlefield.CrossBattlefieldModule")
local def = BattlefieldResultPanel.define
def.field("table").m_UIGOs = nil
def.field("table").m_params = nil
local instance
def.static("=>", BattlefieldResultPanel).Instance = function()
  if instance == nil then
    instance = BattlefieldResultPanel()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
end
def.method("table").ShowPanel = function(self, params)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  self.m_params = params
  self:SetModal(true)
  self:CreatePanel(RESPATH.PREFAB_CROSS_BATTLEFIELD_RESULT_PANEL, 1)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
  self.m_UIGOs = nil
  self.m_params = nil
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Conform" then
    self:DestroyPanel()
  end
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Img_Bg = self.m_panel:FindDirect("Img_Bg")
  self.m_UIGOs.Group_Rank = self.m_UIGOs.Img_Bg:FindDirect("Group_Rank")
  self.m_UIGOs.Img_RankIcon = self.m_UIGOs.Group_Rank:FindDirect("Img_RankIcon")
  self.m_UIGOs.Label_Name = self.m_UIGOs.Group_Rank:FindDirect("Label_Name")
  self.m_UIGOs.Group_Star = self.m_UIGOs.Group_Rank:FindDirect("Group_Star")
  self.m_UIGOs.Group_DarkStar = self.m_UIGOs.Group_Rank:FindDirect("Group_DarkStar")
  self.m_UIGOs.Group_KingStar = self.m_UIGOs.Group_Rank:FindDirect("Group_KingStar")
  self.m_UIGOs.Group_Info = self.m_UIGOs.Img_Bg:FindDirect("Group_Info")
  self.m_UIGOs.Group_Info2 = self.m_UIGOs.Group_Info:FindDirect("Group_Info")
  self.m_UIGOs.Label_WinPoints = self.m_UIGOs.Group_Info2:FindDirect("Group_WinPoints/Label_WinPoints")
  self.m_UIGOs.Group_Slider = self.m_UIGOs.Group_Info2:FindDirect("Group_Slider")
  self.m_UIGOs.Slider_Pro = self.m_UIGOs.Group_Slider:FindDirect("Slider_Pro")
  self.m_UIGOs.Label_Tips = self.m_UIGOs.Group_Slider:FindDirect("Label_Tips")
  self.m_UIGOs.Group_Label = self.m_UIGOs.Group_Info2:FindDirect("Group_Label")
  self.m_UIGOs.Group_Effect = self.m_UIGOs.Img_Bg:FindDirect("Group_Effect")
  self.m_UIGOs.Effect_GainStar = self.m_UIGOs.Group_Effect:FindDirect("UI_Panel_CrossServerBattle_RankResult_XingXingDianLiang")
  self.m_UIGOs.Effect_LoseStar = self.m_UIGOs.Effect_GainStar
  self.m_UIGOs.Effect_GainDuanwei = self.m_UIGOs.Group_Effect:FindDirect("UI_Panel_CrossServerBattle_RankResult_DuanWeiBianHua")
  self.m_UIGOs.Effect_LoseDuanwei = self.m_UIGOs.Effect_GainDuanwei
  self.m_UIGOs.Effect_Point = GameObject.GameObject("Effect_Point")
  self.m_UIGOs.Effect_Point.parent = self.m_UIGOs.Img_Bg
  self.m_UIGOs.Effect_Point.localScale = Vector.Vector3.one
  self.m_UIGOs.Effect_Point.localPosition = Vector.Vector3.zero
  self.m_UIGOs.Effect_Point:set_layer(ClientDef_Layer.UI)
end
def.method().UpdateUI = function(self)
  self:TweenWinPoint(self.m_params.last.winPoint, self.m_params.cur.winPoint)
  self:UpdateWinPointTips()
  self:UpdateDuanwei()
  self:UpdateBounceWinPoint()
end
def.method("number", "number").TweenWinPoint = function(self, from, to)
  local Label_Slider = self.m_UIGOs.Slider_Pro:FindDirect("Label_Slider")
  local MAX_WIN_POINT = _G.constant.CCrossFieldConsts.WIN_POINT_NUM_UPPER_LIMIT
  local function onUpdate(value)
    GUIUtils.SetText(self.m_UIGOs.Label_WinPoints, value)
    local progress = value / MAX_WIN_POINT
    GUIUtils.SetProgress(self.m_UIGOs.Slider_Pro, GUIUtils.COTYPE.SLIDER, progress)
    local sliderText = string.format("%s/%s", value, MAX_WIN_POINT)
    GUIUtils.SetText(Label_Slider, sliderText)
  end
  local function onFinished()
    local curDuanweiInfo = CrossBattlefieldModule.Instance():GetDuanweiInfoByStarNum(self.m_params.cur.starNum)
    local lastDuanweiInfo = CrossBattlefieldModule.Instance():GetDuanweiInfoByStarNum(self.m_params.last.starNum)
    self:SetDuanweiInfo(curDuanweiInfo, lastDuanweiInfo, nil)
  end
  onUpdate(from)
  self:WaitForSeconds(0.36, function()
    local INTERVAL = 0.05
    local STEP = 1
    local DURATION = 1
    if from < to then
      self:Tween(from, to, DURATION, onUpdate, onFinished)
    elseif from > to then
      do
        local dur1 = DURATION * (MAX_WIN_POINT - to) / (MAX_WIN_POINT - to + from)
        self:Tween(from, MAX_WIN_POINT, dur1, onUpdate, function()
          local lastDuanweiInfo = CrossBattlefieldModule.Instance():GetDuanweiInfoByStarNum(self.m_params.last.starNum)
          local immediatelyInfo = CrossBattlefieldModule.Instance():GetDuanweiInfoByStarNum(self.m_params.last.starNum + 1)
          self:SetDuanweiInfo(immediatelyInfo, lastDuanweiInfo, nil)
          self.m_params.last.starNum = self.m_params.last.starNum + 1
          local dur2 = DURATION - dur1
          self:Tween(0, to, dur2, onUpdate, onFinished)
        end)
      end
    else
      onFinished()
    end
  end)
end
def.method("number", "number", "number", "function", "function").Tween = function(self, from, to, duration, onUpdate, onFinished)
  local diff = to - from
  local interval = duration / math.abs(diff)
  local step = diff > 0 and 1 or -1
  local function tween(value)
    onUpdate(value)
    if value == to then
      onFinished()
      return
    end
    self:WaitForSeconds(interval, function()
      value = value + step
      if from ~= to then
        tween(value)
      end
    end)
  end
  local value = from
  tween(from)
end
def.method().UpdateWinPointTips = function(self)
  local MAX_WIN_POINT = _G.constant.CCrossFieldConsts.WIN_POINT_NUM_UPPER_LIMIT
  local text = textRes.CrossBattlefield[7]:format(MAX_WIN_POINT)
  GUIUtils.SetText(self.m_UIGOs.Label_Tips, text)
end
def.method().UpdateDuanwei = function(self)
  local lastDuanweiInfo = CrossBattlefieldModule.Instance():GetDuanweiInfoByStarNum(self.m_params.last.starNum)
  self:SetDuanweiInfo(lastDuanweiInfo, lastDuanweiInfo, nil)
end
def.method("table", "table", "table").SetDuanweiInfo = function(self, duanweiInfo, lastDuanweiInfo, params)
  GUIUtils.SetText(self.m_UIGOs.Label_Name, duanweiInfo.name)
  local uiSprite = self.m_UIGOs.Img_RankIcon:GetComponent("UISprite")
  if uiSprite then
    local width, height = uiSprite.width, uiSprite.height
    local depth = uiSprite.depth
    GameObject.DestroyImmediate(uiSprite)
    local uiTexture = self.m_UIGOs.Img_RankIcon:AddComponent("UITexture")
    uiTexture.width, uiTexture.height = width, height
    uiTexture.depth = depth
  end
  GUIUtils.SetTexture(self.m_UIGOs.Img_RankIcon, duanweiInfo.icon)
  if duanweiInfo.sortId > lastDuanweiInfo.sortId then
    self:PlayFXAtPosition(self.m_UIGOs.Effect_GainDuanwei, self.m_UIGOs.Img_RankIcon.position)
  elseif duanweiInfo.sortId < lastDuanweiInfo.sortId then
    self:PlayFXAtPosition(self.m_UIGOs.Effect_LoseDuanwei, self.m_UIGOs.Img_RankIcon.position)
  end
  self:SetDuanweiStarInfo(duanweiInfo, lastDuanweiInfo, params)
end
def.method("table", "table", "table").SetDuanweiStarInfo = function(self, duanweiInfo, lastDuanweiInfo, params)
  local params = params or {}
  local localStarNum = duanweiInfo.localStarNum
  local lastLocalStarNum = lastDuanweiInfo.localStarNum
  local childCount = self.m_UIGOs.Group_Star.childCount
  if localStarNum <= childCount then
    GUIUtils.SetActive(self.m_UIGOs.Group_Star, true)
    GUIUtils.SetActive(self.m_UIGOs.Group_DarkStar, true)
    GUIUtils.SetActive(self.m_UIGOs.Group_KingStar, false)
    for i = 1, childCount do
      local starGO = self.m_UIGOs.Group_Star:GetChild(i - 1)
      if i <= localStarNum then
        GUIUtils.SetActive(starGO, true)
      else
        GUIUtils.SetActive(starGO, false)
      end
      if duanweiInfo.starNum > lastDuanweiInfo.starNum then
        local diffStarNum = duanweiInfo.starNum - lastDuanweiInfo.starNum
        local beginStarNum = math.max(0, localStarNum - diffStarNum)
        if i > beginStarNum and i <= localStarNum then
          self:PlayFXAtPosition(self.m_UIGOs.Effect_GainStar, starGO.position)
        end
      elseif duanweiInfo.starNum < lastDuanweiInfo.starNum then
        local diffStarNum = lastDuanweiInfo.starNum - duanweiInfo.starNum
        local endStarNum = math.min(childCount, localStarNum + diffStarNum)
        if i > localStarNum and i <= endStarNum then
          self:PlayFXAtPosition(self.m_UIGOs.Effect_LoseStar, starGO.position)
        end
      end
    end
  else
    GUIUtils.SetActive(self.m_UIGOs.Group_Star, false)
    GUIUtils.SetActive(self.m_UIGOs.Group_DarkStar, false)
    GUIUtils.SetActive(self.m_UIGOs.Group_KingStar, true)
    local Label_StarNum = self.m_UIGOs.Group_KingStar:FindDirect("Label_StarNum")
    local starGO = self.m_UIGOs.Group_KingStar:FindDirect("Img_Star")
    GUIUtils.SetText(Label_StarNum, localStarNum)
    if duanweiInfo.starNum > lastDuanweiInfo.starNum then
      self:PlayFXAtPosition(self.m_UIGOs.Effect_GainStar, starGO.position)
    elseif duanweiInfo.starNum < lastDuanweiInfo.starNum then
      self:PlayFXAtPosition(self.m_UIGOs.Effect_LoseStar, starGO.position)
    end
  end
end
def.method().UpdateBounceWinPoint = function(self)
  local Group_Label = self.m_UIGOs.Group_Label
  local uiGrid = Group_Label:GetComponent("UIGrid")
  local Label_MVP = Group_Label:FindDirect("Label_MVP")
  local Label_Win = Group_Label:FindDirect("Label_Win")
  local curInfo = self.m_params.cur
  GUIUtils.SetActive(Label_MVP, curInfo.isMvp)
  if curInfo.isMvp then
    local bounce = {
      name = textRes.CrossBattlefield.Bounce[1]
    }
    bounce.value = _G.constant.CCrossFieldConsts.MVP_GET_WIN_POINT_NUM
    local Label_Points = Label_MVP:FindDirect("Label_Points")
    local pointText = string.format("+%s", bounce.value)
    GUIUtils.SetText(Label_Points, pointText)
  end
  local isBounceStrak = curInfo.winningStreak >= self.m_params.bounceStreak
  GUIUtils.SetActive(Label_Win, isBounceStrak)
  if isBounceStrak then
    local bounce = {
      name = textRes.CrossBattlefield.Bounce[2]:format(curInfo.winningStreak)
    }
    bounce.value = _G.constant.CCrossFieldConsts.STRAIGHT_WIN_GET_WIN_POINT_NUM
    local Label_Points = Label_Win:FindDirect("Label_Points")
    local Label_Num = Label_Win:FindDirect("Label_Num")
    local pointText = string.format("+%s", bounce.value)
    local numText = curInfo.winningStreak
    GUIUtils.SetText(Label_Points, pointText)
    GUIUtils.SetText(Label_Num, numText)
  end
  uiGrid:Reposition()
end
def.method("userdata", "table").SetBounceInfo = function(self, go, bounce)
  local Label_Name = go:FindDirect("Label_Name")
  local Label_Points = go:FindDirect("Label_Points")
  GUIUtils.SetText(Label_Name, bounce.name)
  local pointText = string.format("+%s", bounce.value)
  GUIUtils.SetText(Label_Points, pointText)
end
def.method("number", "function").WaitForSeconds = function(self, seconds, callback)
  GameUtil.AddGlobalTimer(seconds, true, function()
    if self.m_UIGOs == nil then
      return
    end
    if callback then
      callback()
    end
  end)
end
def.method("userdata", "table").PlayFXAtPosition = function(self, template, position)
  if template == nil then
    return
  end
  local fxName = "_" .. template.name
  local fx = self.m_UIGOs.Effect_Point:FindDirect(fxName)
  if fx == nil or fx.activeSelf then
    fx = GameObject.Instantiate(template)
    fx.name = fxName
    fx.parent = self.m_UIGOs.Effect_Point
    fx:SetActive(false)
  end
  fx.position = position
  fx:SetActive(true)
  local fxDuration = fx:GetComponent("FxDuration")
  if fxDuration then
    local duration = fxDuration.duration
    if duration < 0 then
      return
    end
    GameUtil.AddGlobalLateTimer(duration, true, function()
      if fx == nil or fx.isnil then
        return
      end
      fx:SetActive(false)
    end)
  end
end
return BattlefieldResultPanel.Commit()
