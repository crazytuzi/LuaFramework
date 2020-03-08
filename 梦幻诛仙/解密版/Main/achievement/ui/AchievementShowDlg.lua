local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local AchievementShowDlg = Lplus.Extend(ECPanelBase, "AchievementShowDlg")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local AchievementData = require("Main.achievement.AchievementData")
local AchievementFinishInfo = require("Main.achievement.AchievementFinishInfo")
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local def = AchievementShowDlg.define
local _instance
def.static("=>", AchievementShowDlg).Instance = function()
  if _instance == nil then
    _instance = AchievementShowDlg()
  end
  return _instance
end
def.field("number").m_id = 0
def.field("number").m_state = 0
def.field("number").m_time = 0
def.field("table").m_params = nil
def.field("boolean").m_compare = true
def.field("table").m_pos = nil
def.field("string").m_ownerName = ""
def.static("number", "number", "number", "string", "table", "boolean", "table").ShowPanel = function(id, state, achieveTime, name, params, compare, pos)
  local self = AchievementShowDlg.Instance()
  self.m_id = id
  self.m_state = state
  self.m_time = achieveTime
  self.m_ownerName = name
  self.m_params = params
  self.m_compare = compare
  self.m_pos = pos
  if self:IsCreated() then
    if self:IsLoaded() then
      self:UpdateAll()
      self:UpdatePos()
    end
  else
    self:CreatePanel(RESPATH.PREFAB_ACHIEVEMENT_TIP, 2)
    self:SetOutTouchDisappear()
  end
end
def.override().OnCreate = function(self)
  self:UpdateAll()
  self:UpdatePos()
end
def.method().UpdatePos = function(self)
  if self.m_pos == nil then
    return
  end
  local tipFrame = self.m_panel:FindDirect("Img_Bg")
  local pos = self.m_pos
  if pos.auto then
    local tipWidth = tipFrame:GetComponent("UISprite"):get_width()
    local tipHeight = tipFrame:GetComponent("UISprite"):get_height()
    local targetX, targetY = require("Common.MathHelper").ComputeTipsAutoPosition(pos.sourceX, pos.sourceY, pos.sourceW, pos.sourceH, tipWidth, tipHeight, pos.prefer, 1)
    targetY = targetY + tipHeight / 2
    tipFrame:set_localPosition(Vector.Vector3.new(targetX, targetY, 0))
  elseif pos then
    tipFrame:set_localPosition(Vector.Vector3.new(pos.x, pos.y, 0))
  end
end
def.method().UpdateAll = function(self)
  self:UpdateStaticInfo()
  self:UpdateDynamicInfo()
  self:UpdateCompareInfo()
end
def.method().UpdateStaticInfo = function(self)
  local goalCfg = AchievementData.GetAchievementGoalCfg(self.m_id)
  if goalCfg then
    local top = self.m_panel:FindDirect("Img_Bg/Group_Top")
    local title = top:FindDirect("Label_Title")
    local credit = top:FindDirect("Label_Credit")
    local Label_Type = top:FindDirect("Label_Type")
    local icon = top:FindDirect("Img_BgIcon/Texture_Icon")
    title:GetComponent("UILabel"):set_text(goalCfg.title)
    credit:GetComponent("UILabel"):set_text(tostring(goalCfg.point))
    GUIUtils.FillIcon(icon:GetComponent("UITexture"), goalCfg.iconId)
    local desc = self.m_panel:FindDirect("Img_Bg/Label_TaskInfo")
    desc:GetComponent("UILabel"):set_text(goalCfg.goalDes)
    local invisibleAchievementIndex = constant.AchievementConsts.invisibleAchievementIndex
    local achieveCfg = AchievementData.Instance():GetAchievementCfg(self.m_id)
    if achieveCfg and achieveCfg.bigTypeIndex == invisibleAchievementIndex then
      GUIUtils.SetText(Label_Type, textRes.Grow.Achievement[17])
    else
      GUIUtils.SetText(Label_Type, textRes.Grow.Achievement[18])
    end
  end
end
def.method().UpdateDynamicInfo = function(self)
  local bar = self.m_panel:FindDirect("Img_Bg/Group_Bottom/Label_Info1")
  if self.m_state > 1 then
    bar:GetComponent("UILabel"):set_text(textRes.Grow[81])
  else
    bar:GetComponent("UILabel"):set_text(textRes.Grow[82])
  end
  self:SetInfoBar(bar, self.m_state, self.m_time, self.m_ownerName, self.m_params)
  local Img_Done = self.m_panel:FindDirect("Img_Bg/Img_Done")
  GUIUtils.SetActive(Img_Done, self.m_state > 1)
end
def.method().UpdateCompareInfo = function(self)
  local bar = self.m_panel:FindDirect("Img_Bg/Group_Bottom/Label_Info2")
  local goalInfo = AchievementData.Instance():GetAchievementInfo(self.m_id)
  if goalInfo then
    bar:SetActive(true)
    local time = (goalInfo.achieve_time / 1000):ToNumber()
    self:SetInfoBar(bar, goalInfo.state, time, "", goalInfo.parameters)
  else
    bar:SetActive(false)
  end
end
def.method("userdata", "number", "number", "string", "table").SetInfoBar = function(self, uiGo, state, time, name, params)
  local timeLbl = uiGo:FindDirect("Label_TaskInfo")
  local slider = uiGo:FindDirect("Slider_Progress")
  if state > 1 then
    timeLbl:SetActive(true)
    slider:SetActive(false)
    local timeTbl = AbsoluteTimer.GetServerTimeTable(time)
    local timeStr = string.format(textRes.Grow[84], timeTbl.year, timeTbl.month, timeTbl.day)
    if name ~= "" then
      timeLbl:GetComponent("UILabel"):set_text("[00ff00]" .. name .. "[-]" .. timeStr)
    else
      timeLbl:GetComponent("UILabel"):set_text(timeStr)
    end
  else
    timeLbl:SetActive(false)
    slider:SetActive(true)
    local goalCfg = AchievementData.GetAchievementGoalCfg(self.m_id)
    local numerator, denominator = AchievementFinishInfo.getFinishInfoData(goalCfg, params)
    slider:GetComponent("UIProgressBar").value = numerator / denominator
    slider:FindDirect("Label_Number"):GetComponent("UILabel"):set_text(string.format("%d/%d", numerator, denominator))
  end
end
def.override().OnDestroy = function(self)
end
return AchievementShowDlg.Commit()
