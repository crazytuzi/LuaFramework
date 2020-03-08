local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local Scoreboard = Lplus.Extend(ECPanelBase, "Scoreboard")
local GUIUtils = require("GUI.GUIUtils")
local def = Scoreboard.define
local _instance
def.static("=>", "table").Instance = function()
  if _instance == nil then
    _instance = Scoreboard()
  end
  return _instance
end
def.field("string").name1 = ""
def.field("string").name2 = ""
def.field("string").icon1 = ""
def.field("string").icon2 = ""
def.field("number").score1 = 0
def.field("number").score2 = 0
def.field("number").endTime = 0
def.field("number").timer = 0
def.field("userdata").scoreLbl1 = nil
def.field("userdata").scoreLbl2 = nil
def.static("string", "string", "number", "number", "string", "string", "number").ShowScoreboard = function(name1, name2, score1, score2, icon1, icon2, endTime)
  local dlg = Scoreboard.Instance()
  dlg.name1 = name1
  dlg.name2 = name2
  dlg.icon1 = icon1
  dlg.icon2 = icon2
  dlg.score1 = score1
  dlg.score2 = score2
  dlg.endTime = endTime
  if dlg:IsShow() then
    dlg:DestroyPanel()
  end
  dlg:SetDepth(GUIDEPTH.BOTTOMMOST)
  dlg:CreatePanel(RESPATH.PREFAB_SINGLEBATTLE_BATTLEIN, 0)
end
def.static("number", "number").SetScore = function(score1, score2)
  local dlg = Scoreboard.Instance()
  dlg.score1 = score1
  dlg.score2 = score2
  if dlg:IsShow() then
    dlg:UpdateScore()
  end
end
def.static().Close = function()
  local dlg = Scoreboard.Instance()
  dlg:DestroyPanel()
end
def.override().OnCreate = function(self)
  self:UpdateName()
  self:UpdateScore()
  self:SetEndTime()
end
def.override().OnDestroy = function(self)
  GameUtil.RemoveGlobalTimer(self.timer)
  self.scoreLbl1 = nil
  self.scoreLbl2 = nil
end
def.method().UpdateName = function(self)
  local nameLbl1 = self.m_panel:FindDirect("Img_Bg/Img_FightMember/Group_Label/Img_RedLabel")
  local nameLbl2 = self.m_panel:FindDirect("Img_Bg/Img_FightMember/Group_Label/Img_BlueLabel")
  nameLbl1:GetComponent("UISprite"):set_spriteName(self.name1)
  nameLbl2:GetComponent("UISprite"):set_spriteName(self.name2)
  local icon1 = self.m_panel:FindDirect("Img_Bg/Img_FightMember/Group_Label/Img_RedBadge")
  local icon2 = self.m_panel:FindDirect("Img_Bg/Img_FightMember/Group_Label/Img_BlueBadge")
  icon1:GetComponent("UISprite"):set_spriteName(self.icon1)
  icon2:GetComponent("UISprite"):set_spriteName(self.icon2)
end
def.method().UpdateScore = function(self)
  if self.scoreLbl1 == nil then
    self.scoreLbl1 = self.m_panel:FindDirect("Img_Bg/Img_FightMember/Group_Label/Group_RedPoints/Label_Num"):GetComponent("UILabel")
  end
  if self.scoreLbl2 == nil then
    self.scoreLbl2 = self.m_panel:FindDirect("Img_Bg/Img_FightMember/Group_Label/Group_BluePoints/Label_Num"):GetComponent("UILabel")
  end
  self.scoreLbl1:set_text(tostring(self.score1))
  self.scoreLbl2:set_text(tostring(self.score2))
end
def.method().SetEndTime = function(self)
  local formatTime = function(score)
    if score < 0 then
      return ""
    end
    local minute = math.floor(score / 60)
    local second = score % 60
    return string.format("%02d:%02d", minute, second)
  end
  local timeLbl = self.m_panel:FindDirect("Img_Bg/Img_FightMember/Group_Time/Label_Time"):GetComponent("UILabel")
  timeLbl:set_text(formatTime(self.endTime - GetServerTime()))
  self.timer = GameUtil.AddGlobalTimer(1, false, function()
    if not timeLbl.isnil then
      timeLbl:set_text(formatTime(self.endTime - GetServerTime()))
    end
  end)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Detail" then
    require("Main.CaptureTheFlag.ui.BattleFieldDetail").ShowBattleFieldDetail()
  end
end
Scoreboard.Commit()
return Scoreboard
