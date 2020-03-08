local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local CrossBattleRulePanel = Lplus.Extend(ECPanelBase, "CrossBattleRulePanel")
local GUIUtils = require("GUI.GUIUtils")
local def = CrossBattleRulePanel.define
def.const("table").Rules = {
  {
    title = textRes.CrossBattle.RuleTitle[0],
    rule = constant.CrossBattleConsts.cross_battle_register_tips
  },
  {
    title = textRes.CrossBattle.RuleTitle[1],
    rule = constant.CrossBattleConsts.cross_battle_vote_tips
  },
  {
    title = textRes.CrossBattle.RuleTitle[2],
    rule = constant.CrossBattleConsts.cross_battle_round_tips
  },
  {
    title = textRes.CrossBattle.RuleTitle[3],
    rule = constant.CrossBattleConsts.cross_battle_divide_tips
  },
  {
    title = textRes.CrossBattle.RuleTitle[4],
    rule = constant.CrossBattleConsts.cross_battle_point_tips
  },
  {
    title = textRes.CrossBattle.RuleTitle[5],
    rule = constant.CrossBattleConsts.cross_battle_selection_tips
  },
  {
    title = textRes.CrossBattle.RuleTitle[6],
    rule = constant.CrossBattleConsts.cross_battle_final_tips
  }
}
def.field("table").uiObjs = nil
local instance
def.static("=>", CrossBattleRulePanel).Instance = function()
  if instance == nil then
    instance = CrossBattleRulePanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_TEAM_PVP_CROSS_RULE, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:FillCrossBattleRulesTitle()
  self:ShowCrossBattleRuleDetail(1)
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.Group_Tab = self.uiObjs.Img_Bg0:FindDirect("Group_Tab")
  self.uiObjs.Scrollview = self.uiObjs.Group_Tab:FindDirect("Scrollview")
  self.uiObjs.Group_List = self.uiObjs.Scrollview:FindDirect("Group_List")
  self.uiObjs.Scrollview_Note = self.uiObjs.Img_Bg0:FindDirect("Group_Details/Group_Detail/Scrollview_Note")
  self.uiObjs.Drag_Tips = self.uiObjs.Scrollview_Note:FindDirect("Drag_Tips")
end
def.method().FillCrossBattleRulesTitle = function(self)
  local uiList = self.uiObjs.Group_List:GetComponent("UIList")
  uiList.itemCount = #CrossBattleRulePanel.Rules
  uiList:Resize()
  local items = uiList.children
  for i = 1, #items do
    local item = items[i]
    local Label = item:FindDirect(string.format("Label_1_%d", i))
    GUIUtils.SetText(Label, CrossBattleRulePanel.Rules[i].title)
  end
end
def.method("number").ShowCrossBattleRuleDetail = function(self, idx)
  if CrossBattleRulePanel.Rules[idx] ~= nil then
    local tipContent = require("Main.Common.TipsHelper").GetHoverTip(CrossBattleRulePanel.Rules[idx].rule)
    GUIUtils.SetText(self.uiObjs.Drag_Tips, tipContent)
    local uiScrollView = self.uiObjs.Scrollview_Note:GetComponent("UIScrollView")
    uiScrollView:ResetPosition()
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif string.find(id, "Tab_") then
    local idx = tonumber(string.sub(id, #"Tab_" + 1))
    self:ShowCrossBattleRuleDetail(idx)
  end
end
CrossBattleRulePanel.Commit()
return CrossBattleRulePanel
