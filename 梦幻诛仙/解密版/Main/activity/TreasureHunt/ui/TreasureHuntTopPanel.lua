local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local TreasureHuntTopPanel = Lplus.Extend(ECPanelBase, "TreasureHuntTopPanel")
local TreasureHuntUtils = require("Main.activity.TreasureHunt.TreasureHuntUtils")
local GUIUtils = require("GUI.GUIUtils")
local def = TreasureHuntTopPanel.define
local instance
def.field("userdata").ui_Time = nil
def.field("userdata").ui_Gift = nil
def.field("userdata").ui_Chapter = nil
def.field("number").endTime = 0
def.field("number").leftGiftNum = 10
def.field("number").totalGiftNum = 10
def.field("number").timerId = 0
def.field("number").lastTime = 0
def.field("number").chapterId = 1
def.static("=>", TreasureHuntTopPanel).Instance = function()
  if instance == nil then
    instance = TreasureHuntTopPanel()
  end
  return instance
end
def.method("number", "number", "number", "number").ShowPanel = function(self, endTime, leftGiftNum, totalGiftNum, chapterId)
  if self.m_panel ~= nil then
    self:StartCountDown(endTime)
    self:SetGift(leftGiftNum, totalGiftNum)
    return
  end
  self.endTime = endTime
  self.leftGiftNum = leftGiftNum
  self.totalGiftNum = totalGiftNum
  self.chapterId = chapterId
  self:CreatePanel(RESPATH.PREFAB_ACTIVITY_TREASURE_HUNT_TOP_PANEL, 0)
  self:SetModal(false)
end
def.method("number").StartCountDown = function(self, endTime)
  if self.m_panel == nil then
    return
  end
  local leftTime = endTime - _G.GetServerTime()
  if leftTime < 0 then
    return
  end
  if self.timerId ~= 0 then
    GameUtil.RemoveGlobalTimer(self.timerId)
  end
  self:SetTime(leftTime)
  self.timerId = GameUtil.AddGlobalTimer(0.05, false, function()
    leftTime = endTime - _G.GetServerTime()
    self:SetTime(leftTime)
    if leftTime < 0 then
      GameUtil.RemoveGlobalTimer(self.timerId)
    end
  end)
end
def.method("number").SetTime = function(self, time)
  if time == self.lastTime then
    return
  end
  self.lastTime = time
  local minute = time / 60
  local second = time % 60
  if self.ui_Time ~= nil then
    self.ui_Time:GetComponent("UILabel"):set_text(string.format(textRes.TreasureHunt[2], minute, second))
  end
end
def.method("number").SetChapter = function(self, chapterId)
  self.ui_Chapter:GetComponent("UILabel"):set_text(TreasureHuntUtils.GetChapterTextById(chapterId))
end
def.method("number", "number").SetGift = function(self, leftGiftNum, totalGiftNum)
  if self.ui_Gift ~= nil then
    self.ui_Gift:GetComponent("UILabel"):set_text(string.format(textRes.TreasureHunt[3], leftGiftNum, totalGiftNum))
  end
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:StartCountDown(self.endTime)
  self:SetGift(self.leftGiftNum, self.totalGiftNum)
  self:SetChapter(self.chapterId)
end
def.override().OnDestroy = function(self)
  self.ui_Time = nil
  self.ui_Gift = nil
  if self.timerId ~= 0 then
    GameUtil.RemoveGlobalTimer(self.timerId)
  end
end
def.method().InitUI = function(self)
  self.ui_Time = self.m_panel:FindDirect("Img_Bg/Group_Time/Label_Num")
  self.ui_Gift = self.m_panel:FindDirect("Img_Bg/Group_Gift/Label_GiftNum")
  self.ui_Chapter = self.m_panel:FindDirect("Img_Bg/Img_GuanKaNum/Label_Num")
end
TreasureHuntTopPanel.Commit()
return TreasureHuntTopPanel
