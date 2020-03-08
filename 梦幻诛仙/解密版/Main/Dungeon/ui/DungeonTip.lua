local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DungeonTip = Lplus.Extend(ECPanelBase, "DungeonTip")
local DungeonUtils = require("Main.Dungeon.DungeonUtils")
local GUIUtils = require("GUI.GUIUtils")
local MathHelper = require("Common.MathHelper")
local def = DungeonTip.define
local _instance
def.const("number").EMERGENCYTIME = 30
def.field("boolean").show = false
def.field("string").title = ""
def.field("string").desc = ""
def.field("number").second = -1
def.field("number").timer = 0
def.field("number").leaveTimer = 0
def.static("=>", DungeonTip).Instance = function()
  if _instance == nil then
    _instance = DungeonTip()
    _instance:SetDepth(GUIDEPTH.BOTTOM)
  end
  return _instance
end
def.static().ShowDungeoTip = function()
  local dlg = DungeonTip.Instance()
  if not dlg:IsShow() then
    dlg:CreatePanel(RESPATH.PREFAB_DUNGEON_TIP, 0)
  end
end
def.override("boolean").OnShow = function(self, show)
  if show then
  end
end
def.override().OnDestroy = function(self)
  GameUtil.RemoveGlobalTimer(self.timer)
  self.timer = 0
  GameUtil.RemoveGlobalTimer(self.leaveTimer)
  self.leaveTimer = 0
end
def.static().CloseDungeonTip = function()
  local dlg = DungeonTip.Instance()
  dlg:DestroyPanel()
end
def.method("string").SetTitle = function(self, title)
  self.title = title
  if self.m_panel and not self.m_panel.isnil then
    local titleLabel = self.m_panel:FindDirect("Group_Info/Img_GuanKaNum/Label_Num"):GetComponent("UILabel")
    titleLabel:set_text(title)
  end
end
def.method("string").SetDesc = function(self, desc)
  self.desc = desc
  if self.m_panel and not self.m_panel.isnil then
    local descLabel = self.m_panel:FindDirect("Group_Info/Label2"):GetComponent("UILabel")
    descLabel:set_text(desc)
  end
end
def.method().DungeonEnd = function(self)
  local leaveTime = DungeonTip.EMERGENCYTIME
  self.leaveTimer = GameUtil.AddGlobalTimer(1, false, function()
    if leaveTime > 0 and leaveTime % 10 == 0 then
      Toast(string.format(textRes.Dungeon[24], leaveTime))
    end
    leaveTime = leaveTime - 1
  end)
end
def.method("number").SetTime = function(self, second)
  self.second = second
  if self.m_panel and not self.m_panel.isnil then
    self:UpdateTime()
  end
end
def.method().UpdateTime = function(self)
  if self.m_panel and not self.m_panel.isnil then
    local label1 = self.m_panel:FindDirect("Group_Info/Label1")
    local alphaTween = label1:GetComponent("TweenAlpha")
    if self.second < 0 then
      label1:SetActive(false)
      return
    elseif self.second > DungeonTip.EMERGENCYTIME then
      label1:SetActive(true)
      alphaTween:set_enabled(false)
    else
      label1:SetActive(true)
      alphaTween:set_enabled(true)
    end
    local timeLabel = label1:GetComponent("UILabel")
    local minute = math.floor(self.second / 60)
    local second = self.second % 60
    timeLabel:set_text(string.format(textRes.Dungeon[11], minute, second))
  end
end
def.override().OnCreate = function(self)
  self:SetTitle(self.title)
  self:SetDesc(self.desc)
  self:SetTime(self.second)
  self.timer = GameUtil.AddGlobalTimer(1, false, function()
    self.second = self.second - 1
    self:UpdateTime()
  end)
end
DungeonTip.Commit()
return DungeonTip
