local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local AchievementData = require("Main.achievement.AchievementData")
local AchievementFinishInfo = require("Main.achievement.AchievementFinishInfo")
local AchievementGetPanel = Lplus.Extend(ECPanelBase, "AchievementGetPanel")
local def = AchievementGetPanel.define
local _instance
def.field("table").transforms = nil
def.field("userdata").panelClip = nil
def.field("userdata").template = nil
def.field("table").waitQueue = nil
def.field("table").displayQueue = nil
def.field("number").timer = -1
def.field("number").updateTimer = -1
def.field("boolean").open = false
def.static("=>", AchievementGetPanel).Instance = function()
  if _instance == nil then
    AchievementGetPanel.Init()
  end
  return _instance
end
def.method("number").ShowPanel = function(self, achievementId)
  self:showTip(achievementId)
end
def.method("boolean").SetOpen = function(self, open)
  self.open = open
  if self.open then
    self:ShowOne()
  end
end
def.method().Reset = function(self)
  self.open = false
  if self.waitQueue and #self.waitQueue > 0 then
    self.waitQueue = {}
  end
  while self.displayQueue and 0 < #self.displayQueue do
    self:DestroyOne()
  end
end
def.static().Init = function()
  if _instance == nil then
    _instance = AchievementGetPanel()
    _instance.waitQueue = {}
    _instance.displayQueue = {}
    _instance:SetDepth(6)
    _instance:CreatePanel(RESPATH.PREFAB_ACHEVEMENT_GET_PANEL, -1)
  end
end
def.override().OnCreate = function(self)
  self.template = self.m_panel:FindDirect("Img_ListBg")
  self.template:SetActive(false)
  local panelClip = self.m_panel:FindDirect("Widget_Position")
  self.panelClip = panelClip
  self.transforms = {}
  local i = 1
  while true do
    local pos = panelClip:FindDirect(string.format("Widget_Position%d", i))
    if pos == nil then
      break
    end
    local transform = pos.transform
    table.insert(self.transforms, transform)
    i = i + 1
  end
  if #self.transforms >= 1 then
    self.template.transform.localPosition = self.transforms[1].localPosition
  end
  self:ShowOne()
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if id == "Btn_Close" then
    while #self.displayQueue > 0 do
      self:DestroyOne()
    end
  end
end
def.method("number").showTip = function(self, achievementId)
  local goalCfg = AchievementData.GetAchievementGoalCfg(achievementId)
  if goalCfg then
    self:AddToQueue({content = goalCfg})
    if self:IsShow() then
      self:ShowOne()
    end
  end
end
def.method().ShowOne = function(self)
  if _G.IsNil(self.m_panel) then
    return
  end
  if not self.open then
    return
  end
  if self.timer == -1 then
    do
      local tbl = self.waitQueue[1]
      if tbl == nil then
        return
      end
      table.remove(self.waitQueue, 1)
      local achievementTip = Object.Instantiate(self.template)
      achievementTip.parent = self.panelClip
      achievementTip:set_localScale(Vector.Vector3.one)
      achievementTip.transform.localPosition = self.template.transform.localPosition
      GameUtil.AddGlobalTimer(0, true, function()
        if _G.IsNil(achievementTip) then
          return
        end
        achievementTip.transform.localPosition = self.template.transform.localPosition
      end)
      achievementTip:SetActive(true)
      self:SetContent(achievementTip, tbl.content)
      self:GoUp(1)
      table.insert(self.displayQueue, 1, {
        tip = achievementTip,
        time = GetServerTime()
      })
      self.timer = GameUtil.AddGlobalTimer(0.2, true, function()
        self.timer = -1
        self:ShowOne()
      end)
      if 0 > self.updateTimer then
        self.updateTimer = GameUtil.AddGlobalTimer(0.1, false, function()
          self:UpdateDisplayQueue()
        end)
      end
    end
  end
end
def.method("number").GoUp = function(self, offset)
  for i = 1, #self.displayQueue do
    local achievementTip = self.displayQueue[i].tip
    if achievementTip ~= nil then
      local from = self.transforms[i]
      local to = self.transforms[i + offset]
      if to ~= nil then
        achievementTip.transform = from
        self:MoveUp(achievementTip, to)
      else
        self:DestroyOne()
      end
    end
  end
end
def.method("table").AddToQueue = function(self, tbl)
  table.insert(self.waitQueue, tbl)
end
def.method("userdata", "table").SetContent = function(self, achievementTip, goalCfg)
  local Label_TaskInfo = achievementTip:FindDirect("Label_TaskInfo"):GetComponent("UILabel")
  local Label_Title = achievementTip:FindDirect("Label_Title"):GetComponent("UILabel")
  local Label_Credit = achievementTip:FindDirect("Label_Credit"):GetComponent("UILabel")
  local Img_BgIcon1 = achievementTip:FindDirect("Img_BgIcon1")
  local Texture_Icon = Img_BgIcon1:FindDirect("Texture_Icon")
  local Label_Num = Img_BgIcon1:FindDirect("Label_Num")
  local iconId = goalCfg.iconId
  local finishStr = ""
  if goalInfo then
    finishStr = AchievementFinishInfo.getFinishInfoStr(goalCfg, goalInfo.parameters)
  end
  Label_TaskInfo:set_text(goalCfg.goalDes)
  Label_Title:set_text(goalCfg.title)
  Label_Credit:set_text(goalCfg.point)
  Label_Num:SetActive(false)
  GUIUtils.SetTexture(Texture_Icon, iconId)
end
def.method("userdata", "userdata").MoveUp = function(self, achievementTip, transform)
  TweenTransform.BeginEx(achievementTip, 1.5, achievementTip.transform, transform)
end
def.method().DestroyOne = function(self)
  local oldest = self.displayQueue[#self.displayQueue]
  Object.Destroy(oldest.tip)
  table.remove(self.displayQueue, #self.displayQueue)
end
def.method().UpdateDisplayQueue = function(self)
  if #self.displayQueue > 0 then
    local oldest = self.displayQueue[#self.displayQueue]
    local curTime = GetServerTime()
    if curTime - oldest.time > 4 then
      self:DestroyOne()
    end
  elseif 0 <= self.updateTimer then
    GameUtil.RemoveGlobalTimer(self.updateTimer)
    self.updateTimer = -1
  end
end
return AchievementGetPanel.Commit()
