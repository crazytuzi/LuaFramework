local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local FeatureVotePanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local def = FeatureVotePanel.define
local Vector = require("Types.Vector")
local FeatureVoteMgr = require("Main.Vote.mgr.FeatureVoteMgr")
local UIButtonColor_State_Normal = 0
local UIButtonColor_State_Disabled = 3
local Item_Game_Toggle_Group = 23
def.field("table").m_UIGO = nil
def.field("table").m_options = nil
def.field("number").m_selIndex = 0
local instance
def.static("=>", FeatureVotePanel).Instance = function()
  if not instance then
    instance = FeatureVotePanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_PRIZE_FEATURE_VOTE, 0)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateUI()
  Event.RegisterEvent(ModuleId.VOTE, gmodule.notifyId.Vote.VOTE_SUCCESS, FeatureVotePanel.OnVoteSuccess)
  Event.RegisterEvent(ModuleId.VOTE, gmodule.notifyId.Vote.FEATURE_VOTE_CLOSE, FeatureVotePanel.OnFeatureVoteClose)
end
def.override().OnDestroy = function(self)
  self.m_UIGO = nil
  self.m_options = nil
  self.m_selIndex = 0
  Event.UnregisterEvent(ModuleId.VOTE, gmodule.notifyId.Vote.VOTE_SUCCESS, FeatureVotePanel.OnVoteSuccess)
  Event.UnregisterEvent(ModuleId.VOTE, gmodule.notifyId.Vote.FEATURE_VOTE_CLOSE, FeatureVotePanel.OnFeatureVoteClose)
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Confirm" then
    self:OnClickConfirmBtn()
  elseif id == "Img_Game" then
    self:OnClickOptionImg(obj)
  elseif id == "Toggle_Select" then
    self:OnClickOption(obj)
  end
end
def.method().InitUI = function(self)
  self.m_UIGO = {}
  self.m_UIGO.Group_PreGame = self.m_panel:FindDirect("Group_PreGame")
  self.m_UIGO.Img_Title = self.m_UIGO.Group_PreGame:FindDirect("Img_Title")
  self.m_UIGO.Label_Tips = self.m_UIGO.Group_PreGame:FindDirect("Label_Tips")
  self.m_UIGO.Btn_Confirm = self.m_UIGO.Group_PreGame:FindDirect("Btn_Confirm")
  self.m_UIGO.Group_Scrollview = self.m_UIGO.Group_PreGame:FindDirect("Group_Scrollview")
  self.m_UIGO.Scrollview_Games = self.m_UIGO.Group_Scrollview:FindDirect("Scrollview_Games")
  self.m_UIGO.List_Games = self.m_UIGO.Scrollview_Games:FindDirect("List_Games")
  local uiList = self.m_UIGO.List_Games:GetComponent("UIList")
  uiList.itemCount = 1
  uiList.renameControl = false
  local listTemplate = self.m_UIGO.List_Games:FindDirect("Item_Game")
  if self:IsSingleOption() then
    local Toggle_Select = listTemplate:FindDirect("Toggle_Select")
    Toggle_Select:GetComponent("UIToggle").group = Item_Game_Toggle_Group
  end
end
def.method().UpdateUI = function(self)
  self:UpdateTitle()
  self:UpdateDesc()
  self:UpdateOptions()
  self:UpdateVoteBtn()
end
def.method().OnClickConfirmBtn = function(self)
  if not self:HaveVoteTimes() then
    Toast(textRes.Vote[1001])
    return
  end
  if self.m_selIndex == 0 then
    Toast(textRes.Vote[1000])
    return
  end
  local option = self.m_options[self.m_selIndex]
  FeatureVoteMgr.Instance():Vote(option.id)
end
def.method("userdata").OnClickOptionImg = function(self, go)
  local parentName = go.parent.name
  local index = tonumber(string.sub(parentName, #"item_" + 1, -1))
  self:SelectOption(index)
  local option = self.m_options[index]
  local CommonDescDlg = require("GUI.CommonUITipsDlg")
  local tipContent = option.desc
  CommonDescDlg.ShowCommonTip(tipContent, {0, 0})
end
def.method("userdata").OnClickOption = function(self, go)
  local parentName = go.parent.name
  local index = tonumber(string.sub(parentName, #"item_" + 1, -1))
  self:SelectOption(index)
end
def.method("=>", "boolean").IsSingleOption = function(self)
  return true
end
def.method("=>", "boolean").HaveVoteTimes = function(self)
  return FeatureVoteMgr.Instance():GetLeftVoteTimes() > 0
end
def.method("number").SelectOption = function(self, index)
  local uiList = self.m_UIGO.List_Games:GetComponent("UIList")
  local maxIndex = uiList.itemCount
  if index > maxIndex or index <= 0 then
    return
  end
  self.m_selIndex = index
  local itemGo = self.m_UIGO.List_Games:GetChild(index)
  local Toggle_Select = itemGo:FindDirect("Toggle_Select")
  GUIUtils.Toggle(Toggle_Select, true)
end
def.method().UpdateTitle = function(self)
  local Label = self.m_UIGO.Img_Title:FindDirect("Label")
  local title = "title not given yet"
end
def.method().UpdateDesc = function(self)
  local Label = self.m_UIGO.Label_Tips
  local desc = "desc not given yet"
end
def.method().UpdateOptions = function(self)
  local optionViewdatas = self:GetOptionViewdatas()
  self.m_options = optionViewdatas
  local optionCount = #optionViewdatas
  local uiList = self.m_UIGO.List_Games:GetComponent("UIList")
  uiList.itemCount = optionCount
  uiList:Resize()
  local childGOs = uiList.children
  for i, v in ipairs(optionViewdatas) do
    local go = childGOs[i]
    local optionInfo = v
    self:SetOptionInfo(go, optionInfo)
  end
  local uiScrollView = self.m_UIGO.Scrollview_Games:GetComponent("UIScrollView")
  GameUtil.AddGlobalTimer(0, true, function(...)
    GameUtil.AddGlobalTimer(0, true, function(...)
      if uiScrollView == nil or uiScrollView.isnil then
        return
      end
      uiScrollView:ResetPosition()
    end)
  end)
end
def.method("userdata", "table").SetOptionInfo = function(self, go, optionInfo)
  local Img_CommonBg = go:FindDirect("Img_CommonBg")
  local Img_PreBg = go:FindDirect("Img_PreBg")
  local Label_Title = go:FindDirect("Label_Title")
  local Img_Game = go:FindDirect("Img_Game")
  GUIUtils.SetText(Label_Title, optionInfo.name)
  GUIUtils.SetTexture(Img_Game, optionInfo.icon)
  GUIUtils.SetActive(Img_PreBg, optionInfo.showPreBg)
end
def.method().UpdateVoteBtn = function(self)
  local uiButton = self.m_UIGO.Btn_Confirm:GetComponent("UIButton")
  local canVote = self:HaveVoteTimes()
  if canVote then
    uiButton.enabled = true
    uiButton:SetState(UIButtonColor_State_Normal, true)
  else
    uiButton.enabled = false
    uiButton:SetState(UIButtonColor_State_Disabled, true)
  end
end
def.method("=>", "table").GetOptionViewdatas = function(self)
  local FunctionType = require("consts.mzm.gsp.activity2.confbean.FunctionType")
  local voteDatas = FeatureVoteMgr.Instance():GetAllVoteDatas()
  local viewdatas = voteDatas
  for i, v in ipairs(voteDatas) do
    if v.functionType == FunctionType.FORECAST then
      v.showPreBg = true
    else
      v.showPreBg = false
    end
  end
  return viewdatas
end
def.static("table", "table").OnVoteSuccess = function()
  instance:UpdateVoteBtn()
end
def.static("table", "table").OnFeatureVoteClose = function()
  require("Main.Award.ui.AwardPanel").Instance():DestroyPanel()
end
return FeatureVotePanel.Commit()
