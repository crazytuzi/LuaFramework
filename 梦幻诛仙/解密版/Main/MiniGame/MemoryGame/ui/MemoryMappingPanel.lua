local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local MemoryMappingPanel = Lplus.Extend(ECPanelBase, "MemoryMappingPanel")
local GUIUtils = require("GUI.GUIUtils")
local def = MemoryMappingPanel.define
local instance
def.field("table").uiObjs = nil
def.field("string").title = ""
def.field("table").textMap = nil
def.field("number").remainTime = 0
def.field("number").timerId = 0
def.static("=>", MemoryMappingPanel).Instance = function()
  if instance == nil then
    instance = MemoryMappingPanel()
  end
  return instance
end
def.method("string", "table", "number").ShowPanel = function(self, title, textMap, remainTime)
  if self.m_panel ~= nil then
    return
  end
  self.title = title
  self.textMap = textMap
  self.remainTime = remainTime
  self:CreatePanel(RESPATH.PREFAB_DANCE_MAPPING_PANEL, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:ShowMappingText()
  Event.RegisterEvent(ModuleId.MINI_GAME, gmodule.notifyId.MiniGame.MEMORY_GAME_QUESTION_START, MemoryMappingPanel.OnMemoryGameQuestionStart)
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
  self.title = ""
  self.textMap = nil
  self.remainTime = 0
  self:StopTextTimer()
  Event.UnregisterEvent(ModuleId.MINI_GAME, gmodule.notifyId.MiniGame.MEMORY_GAME_QUESTION_START, MemoryMappingPanel.OnMemoryGameQuestionStart)
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Label_Tips = self.m_panel:FindDirect("Img_Bg/Scrollview_Tips/Label_Tips")
end
def.method().ShowMappingText = function(self)
  self:UpdateMappingText()
  self:StartTextTimer()
end
def.method().StartTextTimer = function(self)
  self.timerId = GameUtil.AddGlobalTimer(1, false, function()
    self.remainTime = self.remainTime - 1
    if self.remainTime < 0 then
      self:StopTextTimer()
      self:DestroyPanel()
    else
      self:UpdateMappingText()
    end
  end)
end
def.method().UpdateMappingText = function(self)
  local textTbl = {}
  table.insert(textTbl, self.title)
  table.insert(textTbl, "\n")
  local curGameMemoryMap = require("Main.MiniGame.MemoryGame.MemoryGameDataMgr").Instance():GetCurGameMemoryMap()
  if self.textMap ~= nil and curGameMemoryMap ~= nil then
    for k, v in pairs(curGameMemoryMap) do
      table.insert(textTbl, string.format(textRes.MemoryCompetition[3], self.textMap[k], self.textMap[v]))
    end
  end
  table.insert(textTbl, "\n")
  table.insert(textTbl, string.format(textRes.MemoryCompetition[4], self.remainTime))
  GUIUtils.SetText(self.uiObjs.Label_Tips, table.concat(textTbl, "\n"))
end
def.method().StopTextTimer = function(self)
  if self.timerId ~= 0 then
    GameUtil.RemoveGlobalTimer(self.timerId)
  end
  self.timerId = 0
end
def.static("table", "table").OnMemoryGameQuestionStart = function(p1, p2)
  instance:DestroyPanel()
end
MemoryMappingPanel.Commit()
return MemoryMappingPanel
