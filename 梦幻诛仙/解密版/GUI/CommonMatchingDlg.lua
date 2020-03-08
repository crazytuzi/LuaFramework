local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local CommonMatchingDlg = Lplus.Extend(ECPanelBase, "CommonMatchingDlg")
local GUIUtils = require("GUI.GUIUtils")
local def = CommonMatchingDlg.define
def.field("number").beginTickCount = 0
def.field("number").elapsedTime = 0
def.field("number").estimatedTime = 0
def.field("table").context = nil
def.field("function").onCancel = nil
def.field("number").timerId = 0
def.static("number", "function", "table", "=>", CommonMatchingDlg).ShowDlg = function(estimatedTime, onCancel, context)
  local dlg = CommonMatchingDlg()
  dlg.estimatedTime = estimatedTime
  dlg.onCancel = onCancel
  dlg.context = context
  dlg.elapsedTime = context and context._elapsedTime or 0
  dlg.beginTickCount = GameUtil.GetTickCount() - dlg.elapsedTime * 1000
  dlg:CreatePanel(RESPATH.DLG_CROSS_SERVER_MATCH_COUNT_DOWN, 0)
  dlg:SetDepth(GUIDEPTH.TOP)
  dlg:SetModal(true)
  return dlg
end
def.override().OnCreate = function(self)
  self.timerId = GameUtil.AddGlobalTimer(1, false, function()
    self:UpdateTime()
  end)
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  if IsCrossingServer() then
    self:HideDlg()
    return
  end
  self:ShowMatchTime()
end
def.method().HideDlg = function(self)
  self:DestroyPanel()
end
def.override().OnDestroy = function(self)
  if self.timerId ~= 0 then
    GameUtil.RemoveGlobalTimer(self.timerId)
    self.timerId = 0
  end
end
def.method().ShowMatchTime = function(self)
  if self.m_panel == nil then
    return
  end
  local timePanel = self.m_panel:FindDirect("Group_CountDown")
  timePanel:SetActive(true)
  local Label_MatchedTime = timePanel:FindDirect("Label1/Label_Num")
  local Label_EstimatedTime = timePanel:FindDirect("Label3/Label_Num")
  local matchedTime = self:GetMatchedTime()
  GUIUtils.SetText(Label_MatchedTime, matchedTime)
  GUIUtils.SetText(Label_EstimatedTime, self.estimatedTime)
end
def.method("=>", "number").GetMatchedTime = function(self)
  local curTickCount = GameUtil.GetTickCount()
  local matchedTime = math.floor((curTickCount - self.beginTickCount) / 1000)
  return matchedTime
end
def.method("string").onClick = function(self, id)
  if id == "Btn_QuitMatch" then
    self:HideDlg()
    _G.SafeCallback(self.onCancel, self.context)
  end
end
def.method().UpdateTime = function(self)
  if self.m_panel == nil then
    return
  end
  local timePanel = self.m_panel:FindDirect("Group_CountDown")
  local Label_MatchedTime = timePanel:FindDirect("Label1/Label_Num")
  local matchedTime = self:GetMatchedTime()
  GUIUtils.SetText(Label_MatchedTime, matchedTime)
end
return CommonMatchingDlg.Commit()
