local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local HistoryMgr = require("Main.CrossBattle.History.HistoryMgr")
local HistoryUtils = require("Main.CrossBattle.History.HistoryUtils")
local HistoryData = require("Main.CrossBattle.History.data.HistoryData")
local HistoryCorpsPanel = Lplus.Extend(ECPanelBase, "HistoryCorpsPanel")
local def = HistoryCorpsPanel.define
local instance
def.static("=>", HistoryCorpsPanel).Instance = function()
  if instance == nil then
    instance = HistoryCorpsPanel()
  end
  return instance
end
def.field("table")._uiObjs = nil
def.field("number")._season = 0
def.field("table")._corpsBrief = nil
def.field("table")._corpsInfo = nil
def.field("table")._models = nil
local RankSprite = {
  [1] = "Img_1st",
  [2] = "Img_2nd",
  [3] = "Img_3rd"
}
def.static("number", "table").ShowPanel = function(season, corpsBrief)
  if not HistoryMgr.Instance():IsOpen(true) then
    if HistoryCorpsPanel.Instance():IsShow() then
      HistoryCorpsPanel.Instance():DestroyPanel()
    end
    return
  end
  HistoryCorpsPanel.Instance():InitData(season, corpsBrief)
  if HistoryCorpsPanel.Instance():IsShow() then
    HistoryCorpsPanel.Instance():UpdateUI()
    return
  end
  instance:CreatePanel(RESPATH.PREFAB_CROSSBATTLE_HISTORY_TEAM_PANEL, 2)
end
def.method("number", "table").InitData = function(self, season, corpsBrief)
  self._season = season
  self._corpsBrief = corpsBrief
end
def.override().OnCreate = function(self)
  self:SetModal(true)
  self:_InitUI()
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.Group_Title = self.m_panel:FindDirect("Group_Title")
  self._uiObjs.Label_Title = self._uiObjs.Group_Title:FindDirect("Label")
  self._uiObjs.Img_Rank = self._uiObjs.Group_Title:FindDirect("Img_Rank")
  self._uiObjs.Img_Badge = self._uiObjs.Group_Title:FindDirect("Img_Badge")
  self._uiObjs.Label_TeamName = self._uiObjs.Group_Title:FindDirect("Label_TeamName")
  self._uiObjs.Label_ServerName = self._uiObjs.Group_Title:FindDirect("Label_Server")
  self._uiObjs.Group_Team = self.m_panel:FindDirect("Group_Team")
  self._uiObjs.ScrollList = self._uiObjs.Group_Team:FindDirect("ScrollList")
  self._uiObjs.List = self._uiObjs.ScrollList:FindDirect("List")
  self._uiObjs.uiList = self._uiObjs.List:GetComponent("UIList")
end
def.override("boolean").OnShow = function(self, show)
  self:HandleEventListeners(show)
  if show then
    self:UpdateUI()
  else
  end
end
def.method().UpdateUI = function(self)
  self:ShowTitle()
  self:TryShowCorpsMembers()
end
def.override().OnDestroy = function(self)
  self:_Reset()
end
def.method()._Reset = function(self)
  self:_ClearCorps()
  self._season = 0
  self._corpsBrief = nil
  self._corpsInfo = nil
  self._uiObjs = nil
end
def.method().ShowTitle = function(self)
  local rank = self._corpsBrief and self._corpsBrief.corps_rank or 0
  local title = textRes.CrossBattle.History.RANK_TITLE[rank]
  title = title and string.format(title, self._season) or ""
  GUIUtils.SetText(self._uiObjs.Label_Title, title)
  local spriteName = RankSprite[rank]
  if spriteName then
    GUIUtils.SetSprite(self._uiObjs.Img_Rank, spriteName)
  end
  HistoryUtils.ShowCorpsBriefInfo(self._uiObjs.Img_Badge, self._uiObjs.Label_TeamName, self._uiObjs.Label_ServerName, self._corpsBrief)
end
def.method().TryShowCorpsMembers = function(self)
  self:_ClearCorps()
  if self._corpsBrief then
    local corpsInfo = HistoryData.Instance():GetCorpsInfo(self._season, self._corpsBrief.corps_rank, self._corpsBrief.corps_id)
    if corpsInfo then
      self:ShowCorpsMembers(corpsInfo)
    else
      require("Main.CrossBattle.History.HistoryProtocols").SendCGetTeamInfo(self._season, self._corpsBrief.corps_rank, self._corpsBrief.corps_id)
    end
  else
    warn("[ERROR][HistoryCorpsPanel:TryShowCorpsMembers] self._corpsBrief nil.")
  end
end
def.method("table").ShowCorpsMembers = function(self, corpsInfo)
  self._corpsInfo = corpsInfo
  local memberSet = self._corpsInfo and self._corpsInfo.corps_member_set or nil
  local memberList = self:GetMemberListFromSet(memberSet)
  if memberList and #memberList > 0 then
    self._uiObjs.uiList.itemCount = #memberList
    self._uiObjs.uiList:Resize()
    self._uiObjs.uiList:Reposition()
    for i = 1, #memberList do
      self:ShowMemberInfo(i, memberList[i])
    end
  end
end
def.method("table", "=>", "table").GetMemberListFromSet = function(self, memberSet)
  local result
  if memberSet then
    result = {}
    local CorpsDuty = require("consts.mzm.gsp.corps.confbean.CorpsDuty")
    for _, memberInfo in pairs(memberSet) do
      if memberInfo.duty == CorpsDuty.CAPTAIN then
        table.insert(result, 1, memberInfo)
      else
        table.insert(result, memberInfo)
      end
    end
  end
  return result
end
def.method("number", "table").ShowMemberInfo = function(self, idx, memberInfo)
  local listItem = self._uiObjs.uiList.children[idx]
  if nil == listItem then
    warn("[ERROR][HistoryCorpsPanel:ShowMemberInfo] listItem nil at idx:", idx)
    return
  end
  if nil == memberInfo then
    warn("[ERROR][HistoryCorpsPanel:ShowMemberInfo] memberInfo nil at idx:", idx)
    return
  end
  local Img_Leader = listItem:FindDirect("Group_Model/Img_Leader")
  GUIUtils.SetActive(Img_Leader, idx == 1)
  local Model = listItem:FindDirect("Group_Model/Model")
  local uiModel = Model and Model:GetComponent("UIModel")
  local model = self:FillModel(memberInfo.role_model_info, uiModel)
  if nil == self._models then
    self._models = {}
  end
  table.insert(self._models, model)
  local Label_SX_PowerNumber = listItem:FindDirect("Group_Model/Group_Info/Img_SX_BgPower/Label_SX_PowerNumber")
  GUIUtils.SetText(Label_SX_PowerNumber, memberInfo.role_fight_value)
  local Label_Name = listItem:FindDirect("Group_Model/Group_Info/Label_Name")
  GUIUtils.SetText(Label_Name, _G.GetStringFromOcts(memberInfo.role_name))
  local Img_Sex = listItem:FindDirect("Group_Model/Group_Info/Img_Sex")
  GUIUtils.SetSprite(Img_Sex, GUIUtils.GetSexIcon(memberInfo.gender))
  local Label_Lv = listItem:FindDirect("Group_Model/Group_Info/Label_Lv")
  GUIUtils.SetText(Label_Lv, memberInfo.role_level)
  local Img_School = listItem:FindDirect("Group_Model/Group_Info/Img_School")
  GUIUtils.SetSprite(Img_School, GUIUtils.GetOccupationSmallIcon(memberInfo.occupation))
end
def.method("table", "userdata", "=>", "table").FillModel = function(self, modelInfo, uiModel)
  local model
  if modelInfo and not _G.IsNil(uiModel) then
    model = require("Model.ECUIModel").new(modelInfo.modelid)
    _G.LoadModelWithCallBack(model, modelInfo, false, false, function()
      model:OnLoadGameObject()
      uiModel.modelGameObject = model.m_model
      GameUtil.AddGlobalTimer(0.01, true, function()
        if not _G.IsNil(model) and not _G.IsNil(model.m_model) then
          model.m_model:SetActive(true)
          model:Play("Stand_c")
        else
          warn("[ERROR][HistoryCorpsPanel:FillModel] _G.IsNil(model), _G.IsNil(model.m_model):", _G.IsNil(model), _G.IsNil(model.m_model))
        end
      end)
    end)
  else
    warn("[ERROR][HistoryCorpsPanel:FillModel] modelInfo:", modelInfo)
    warn("[ERROR][HistoryCorpsPanel:FillModel] uiModel:", uiModel)
  end
  return model
end
def.method()._ClearCorps = function(self)
  self:DestroyModels()
  if self._uiObjs and self._uiObjs.uiList then
    self._uiObjs.uiList.itemCount = 0
    self._uiObjs.uiList:Resize()
    self._uiObjs.uiList:Reposition()
  end
end
def.method().DestroyModels = function(self)
  if self._models then
    for _, model in ipairs(self._models) do
      if model then
        model:Destroy()
      end
    end
    self._models = nil
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  end
end
def.method("boolean").HandleEventListeners = function(self, isRigister)
  local eventFunc
  if isRigister then
    eventFunc = Event.RegisterEvent
  else
    eventFunc = Event.UnregisterEvent
  end
  if eventFunc then
  end
end
def.method("table").OnSGetTeamInfo = function(self, p)
  if p and p.session == self._season and p.rank == self._corpsBrief.corps_rank and Int64.eq(p.corps_id, self._corpsBrief.corps_id) then
    self:ShowCorpsMembers(p)
  else
    warn(string.format("[ERROR][HistoryCorpsPanel:OnSGetTeamInfo] p.session[%d], p.rank[%d], p.corps_id[%s].", p.session, p.rank, Int64.tostring(p.corps_id)))
    warn(string.format("[ERROR][HistoryCorpsPanel:OnSGetTeamInfo] self._season[%d], self._corpsBrief.corps_rank[%d], self._corpsBrief.corps_id[%s].", self._season, self._corpsBrief.corps_rank, Int64.tostring(self._corpsBrief.corps_id)))
  end
end
HistoryCorpsPanel.Commit()
return HistoryCorpsPanel
