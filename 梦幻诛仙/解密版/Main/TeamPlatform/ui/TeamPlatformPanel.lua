local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local TeamPlatformPanel = Lplus.Extend(ECPanelBase, "TeamPlatformPanel")
local GUIUtils = require("GUI.GUIUtils")
local TeamPlatformMgr = require("Main.TeamPlatform.TeamPlatformMgr")
local TeamPlatformUIMgr = require("Main.TeamPlatform.TeamPlatformUIMgr")
local TeamModule = require("Main.Team.TeamModule")
local TeamData = require("Main.Team.TeamData")
local AutoMatchMgr = require("Main.TeamPlatform.AutoMatchMgr")
local def = TeamPlatformPanel.define
local Vector = require("Types.Vector")
def.field("table").activities = nil
def.field("number").selectedRange = TeamPlatformMgr.MatchRange.First
def.field("number").toggleGroupIdCount = 1
def.field("number").maxMatchCount = 0
def.field("table").selectedOptions = nil
def.field("table").lastSelectedOptions = nil
def.field("number").targetOptionId = 0
def.field("number").targetOptionSubIndex = 0
def.field("table").uiObjs = nil
def.field("table").matchClassList = nil
def.field("table").teams = nil
def.field("number").selClassIndex = 0
def.field("number").selOptionIndex = 0
def.field("number").selSubOptionIndex = 0
def.field("number").OptionToggleGroup = 0
def.field("number").arTimerId = 0
local instance
def.static("=>", TeamPlatformPanel).Instance = function()
  if instance == nil then
    instance = TeamPlatformPanel()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  self.selectedOptions = {}
  self.m_TrigGC = true
end
def.method().ShowPanel = function(self)
  if self.m_panel then
    self:DestroyPanel()
  end
  self:PreloadDatas()
  self:CreatePanel(RESPATH.PREFAB_TEAM_PLATFORM_PANEL, 1)
  self:SetModal(true)
end
def.method("number").SetTargetOption = function(self, optionId)
  self.targetOptionId = optionId
  self.targetOptionSubIndex = 0
end
def.method("number").FocusOnTarget = function(self, optionId)
  self:SetTargetOption(optionId)
  self:ShowPanel()
end
def.override().OnCreate = function(self)
  self:InitUI()
  Event.RegisterEvent(ModuleId.TEAM_PLATFORM, gmodule.notifyId.TeamPlatform.SYNC_MATCH_STATE, TeamPlatformPanel.OnSyncMatchState)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.UPDATE_TEAM_INFO, TeamPlatformPanel.OnTeamInfoUpdate)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_CREATE_TEAM, TeamPlatformPanel.OnTeamInfoUpdate)
  Event.RegisterEvent(ModuleId.TEAM_PLATFORM, gmodule.notifyId.TeamPlatform.MATCH_MEMBERS_UPDATE, TeamPlatformPanel.OnMatchMembersUpdate)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.TEAM_PLATFORM, gmodule.notifyId.TeamPlatform.SYNC_MATCH_STATE, TeamPlatformPanel.OnSyncMatchState)
  Event.UnregisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.UPDATE_TEAM_INFO, TeamPlatformPanel.OnTeamInfoUpdate)
  Event.UnregisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_CREATE_TEAM, TeamPlatformPanel.OnTeamInfoUpdate)
  Event.UnregisterEvent(ModuleId.TEAM_PLATFORM, gmodule.notifyId.TeamPlatform.MATCH_MEMBERS_UPDATE, TeamPlatformPanel.OnMatchMembersUpdate)
  self:Clear()
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  self:UpdateUI()
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if string.sub(id, 1, #"item_") == "item_" then
    local index = tonumber(string.sub(id, #"item_" + 1, -1))
    local isChecked = GUIUtils.IsToggle(obj)
    self:OnMatchClassObjClicked(index, isChecked)
  elseif string.sub(id, 1, #"optionItem_") == "optionItem_" then
    local classItemObjName = obj.transform.parent.parent.gameObject.name
    local classindex = tonumber(string.sub(classItemObjName, #"item_" + 1, -1))
    local index = tonumber(string.sub(id, #"optionItem_" + 1, -1))
    local isChecked = GUIUtils.IsToggle(obj)
    self:OnMatchOptionObjClicked(classindex, index, isChecked)
  elseif string.sub(id, 1, #"subOptionItem_") == "subOptionItem_" then
    local optionItemObj = obj.transform.parent.parent.parent.gameObject
    local classItemObj = optionItemObj.transform.parent.parent.gameObject
    local classindex = tonumber(string.sub(classItemObj.name, #"item_" + 1, -1))
    local optionindex = tonumber(string.sub(optionItemObj.name, #"optionItem_" + 1, -1))
    local index = tonumber(string.sub(id, #"subOptionItem_" + 1, -1))
    local isChecked = GUIUtils.IsToggle(obj)
    self:OnMatchSubOptionObjClicked(classindex, optionindex, index, isChecked)
  elseif id == "Img_Di" then
    local parentName = obj.transform.parent.gameObject.name
    self:onClick(parentName)
  elseif id == "Img_Toggle" then
    self:OnAutoMatchToggleClick(obj)
  else
    self:onClick(id)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" or id == "Modal" then
    self:DestroyPanel()
  elseif id == "Btn_CreateTeam" then
    self:OnCreateTeamButtonClicked()
  elseif id == "Btn_AutoMatch" or id == "Btn_Auto" then
    self:OnMatchButtonClicked()
  elseif id == "Group_Lv1" then
    self:SelectMatchRange(TeamPlatformMgr.MatchRange.First)
  elseif id == "Group_Lv2" then
    self:SelectMatchRange(TeamPlatformMgr.MatchRange.Second)
  elseif id == "Group_New" then
    self:SelectMatchRange(TeamPlatformMgr.MatchRange.AidNewbie)
  elseif string.sub(id, 1, #"Btn_Apply_") == "Btn_Apply_" then
    local index = tonumber(string.sub(id, #"Btn_Apply_" + 1, -1))
    self:OnApplyTeamBtnClicked(index)
  elseif id == "Btn_Refresh" then
    self:OnRefreshBtnClicked()
  elseif id == "Btn_HanHua" then
    self:OnShoutToWorldBtnClick()
  elseif id == "Btn_Help" then
    self:OnAutoMatchTipBtnClick()
  end
end
def.method("string", "boolean").onToggle = function(self, id, isChecked)
end
def.method("userdata").OnAutoMatchToggleClick = function(self, obj)
  local uiToggle = obj:GetComponent("UIToggle")
  local isChecked = uiToggle.value
  uiToggle.value = false
  local matchOption = self:GetSelectedMatchOption()
  if matchOption == nil then
    Toast(textRes.TeamPlatform[8])
    return
  end
  local matchCfgId = matchOption[1]
  if isChecked then
    self:AskAutoMatchConfirm(function(s)
      if s == 1 then
        AutoMatchMgr.Instance():SetAuto(matchCfgId)
        if uiToggle.isnil == false then
          uiToggle.value = true
        end
      end
    end)
  else
    AutoMatchMgr.Instance():CancelAuto()
  end
end
def.method("function").AskAutoMatchConfirm = function(self, callback)
  local desc
  if TeamData.Instance():HasTeam() then
    desc = textRes.TeamPlatform[37]
  else
    desc = textRes.TeamPlatform[38]
  end
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirm(textRes.TeamPlatform[3], desc, callback, nil)
end
def.method().OnShoutToWorldBtnClick = function(self)
  TeamPlatformMgr.Instance():ShoutToWorld()
end
def.method().OnAutoMatchTipBtnClick = function(self)
  local tipId = 701603003
  GUIUtils.ShowHoverTip(tipId)
end
def.method("number", "boolean").OnMatchClassObjClicked = function(self, index, isChecked)
  if isChecked then
    self:OpenMatchClass(index)
  end
end
def.method("number", "number", "boolean").OnMatchOptionObjClicked = function(self, classIndex, index, isChecked)
  if isChecked then
    if classIndex ~= self.selClassIndex or index ~= self.selOptionIndex then
      self.selSubOptionIndex = 0
    end
    self.selClassIndex = classIndex
    self.selOptionIndex = index
    self:OpenSelectedOption()
    self:UpdateOptionDesc()
    self:UpdateMatchRange()
  elseif self.selSubOptionIndex == 0 then
    self.selOptionIndex = 0
  end
end
def.method("number", "number", "number", "boolean").OnMatchSubOptionObjClicked = function(self, classIndex, optionIdex, index, isChecked)
  if isChecked then
    self.selClassIndex = classIndex
    self.selOptionIndex = optionIdex
    self.selSubOptionIndex = index
    self:UpdateOptionDesc()
    self:UpdateMatchRange()
    self:RefreshMatchMemberInfo()
    local option = self.matchClassList[classIndex].optionList[optionIdex]
    self:CheckToShowAidNewbieOption(option)
  else
    self.selSubOptionIndex = 0
  end
end
def.method().OnCreateTeamButtonClicked = function(self)
  local TeamData = require("Main.Team.TeamData")
  local teamData = TeamData.Instance()
  if teamData:HasTeam() then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CLeaveTeamReq").new())
  else
    TeamModule.Instance():CreateTeam()
    self:DestroyPanel()
  end
end
def.method().OnMatchButtonClicked = function(self)
  if TeamPlatformMgr.Instance().isMatching then
    self:CancelMatch()
  else
    self:StartMatch()
  end
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.Group_LeftTarget = self.uiObjs.Img_Bg0:FindDirect("Group_LeftTarget")
  self.uiObjs.LeftScrollView = self.uiObjs.Group_LeftTarget:FindDirect("Scroll_View")
  self.uiObjs.LeftList = self.uiObjs.LeftScrollView:FindDirect("List_Activity")
  self.OptionToggleGroup = self.uiObjs.LeftList:FindDirect("Class_Activity/tween1/Name_Activity"):GetComponent("UIToggle").group
  self.uiObjs.Group_NoTeam = self.uiObjs.Img_Bg0:FindDirect("Group_NoTeam")
  self.uiObjs.RightScrollView = self.uiObjs.Group_NoTeam:FindDirect("Scroll_View")
  self.uiObjs.List_Team = self.uiObjs.RightScrollView:FindDirect("List_Team")
  self.uiObjs.Label_MatchInfo = self.uiObjs.Group_NoTeam:FindDirect("Label_MatchInfo")
  self.uiObjs.Btn_Refresh = self.uiObjs.Group_NoTeam:FindDirect("Btn_Refresh")
  self.uiObjs.Group_InTeam = self.uiObjs.Img_Bg0:FindDirect("Group_InTeam")
  self.uiObjs.Group_Lv1 = self.uiObjs.Group_InTeam:FindDirect("Group_Lv1")
  self.uiObjs.Group_Lv2 = self.uiObjs.Group_InTeam:FindDirect("Group_Lv2")
  self.uiObjs.Group_New = self.uiObjs.Group_InTeam:FindDirect("Group_New")
  GUIUtils.SetActive(self.uiObjs.Group_New, false)
  self.uiObjs.Label_TargetInfo = self.uiObjs.Group_InTeam:FindDirect("Label_TargetInfo")
  local hasTeam = TeamData.Instance():HasTeam()
  GUIUtils.SetActive(self.uiObjs.Group_NoTeam, not hasTeam)
  GUIUtils.SetActive(self.uiObjs.Group_InTeam, hasTeam)
  if hasTeam then
    self.uiObjs.Btn_Auto_Label = self.uiObjs.Group_InTeam:FindDirect("Btn_Auto/Label")
  else
    self.uiObjs.Btn_Auto_Label = self.uiObjs.Group_NoTeam:FindDirect("Btn_AutoMatch/Label")
  end
end
def.method().UpdateUI = function(self)
  self.maxMatchCount = TeamPlatformMgr.Instance():GetMaxMatchOptionCount()
  local matchClassList = TeamPlatformUIMgr.Instance():GetTeamPlatformPanelViewData()
  self.matchClassList = matchClassList
  self:CheckToSelectTargetOptions()
  self:SetMatchClassList(matchClassList)
  self:OpenSelectedClass()
  self:UpdateMatchState()
  self:UpdateRightGroup()
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method("table").SetMatchClassList = function(self, matchClassList)
  local itemCount = #matchClassList
  local uiList = self.uiObjs.LeftList:GetComponent("UIList")
  uiList.itemCount = itemCount
  uiList:Resize()
  local items = uiList.children
  for i, v in ipairs(matchClassList) do
    self:SetMatchClassItem(i, items[i], v)
  end
end
def.method("number", "userdata", "table").SetMatchClassItem = function(self, index, itemObj, itemViewData)
  local Label_Name = itemObj:FindDirect("Label")
  GUIUtils.SetText(Label_Name, itemViewData.name)
  GUIUtils.SetActive(itemObj:FindDirect("tween1"), false)
  local Group_Sign = itemObj:FindDirect("Group_Sign")
  self:MarkSignAsOpen(Group_Sign, false)
end
def.method("userdata", "boolean").MarkSignAsOpen = function(self, signObj, isOpen)
  GUIUtils.SetActive(GUIUtils.FindDirect(signObj, "Img_Up"), isOpen)
  GUIUtils.SetActive(GUIUtils.FindDirect(signObj, "Img_Down"), not isOpen)
end
def.method().OpenSelectedClass = function(self)
  if self.selClassIndex == 0 then
    self.selClassIndex = 1
  end
  local index = self.selClassIndex
  local matchClass = self.matchClassList[index]
  if matchClass == nil then
    return
  end
  local optionList = matchClass.optionList
  self:SetOptionList(index, optionList)
  self:OpenSelectedOption()
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method("number").OpenMatchClass = function(self, index)
  local matchClass = self.matchClassList[index]
  if matchClass == nil then
    return
  end
  local optionList = matchClass.optionList
  self:SetOptionList(index, optionList)
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method("number", "table").SetOptionList = function(self, classIndex, optionList)
  local classItemObj = self.uiObjs.LeftList:FindDirect("item_" .. classIndex)
  GUIUtils.Toggle(classItemObj, true)
  self:DragToMakeVisible(self.uiObjs.LeftScrollView, classItemObj)
  local tween = classItemObj:FindDirect("tween1")
  GUIUtils.SetActive(tween, true)
  local template = tween:FindDirect("Name_Activity")
  GUIUtils.SetActive(template, false)
  local uiTable = tween:GetComponent("UITable")
  uiTable:Reposition()
  local items = uiTable.children
  for i, v in ipairs(optionList) do
    local item = items[i]
    if item == nil or item.isnil then
      item = GameObject.Instantiate(template)
      item:SetActive(true)
      item.name = "optionItem_" .. i
      item.transform.parent = tween.transform
      item.transform.localScale = Vector.Vector3.one
      item.transform.localPosition = Vector.Vector3.zero
    else
      item = item.gameObject
    end
    self:SetOptionListItem(i, item, v)
  end
  local optionCount = #optionList
  for i = optionCount + 1, #items do
    local item = items[i]
    if item then
      GameObject.Destroy(item.gameObject)
    end
  end
end
def.method("number", "userdata", "table").SetOptionListItem = function(self, index, itemObj, itemViewData)
  local Label_Name = itemObj:FindDirect("Label")
  GUIUtils.SetText(Label_Name, itemViewData.name)
  local hasSubOptions = itemViewData:IsHaveSubOptions()
  GUIUtils.SetActive(itemObj:FindDirect("Group_Tween"), hasSubOptions)
  GUIUtils.SetActive(itemObj:FindDirect("Img_Toggle"), not hasSubOptions)
  local uiToggle = itemObj:GetComponent("UIToggle")
  if hasSubOptions then
    uiToggle.group = 0
  else
    uiToggle.group = self.OptionToggleGroup
  end
  local Img_OnMatch = itemObj:FindDirect("Img_OnMatch")
  GUIUtils.SetActive(Img_OnMatch, false)
  local isMatching = TeamPlatformMgr.Instance().isMatching
  if self:IsOptionMatching(itemViewData.id, 0) then
    GUIUtils.SetActive(Img_OnMatch, true)
    self.uiObjs.Img_OnMatch = Img_OnMatch
  end
end
def.method().OpenSelectedOption = function(self)
  if self.selOptionIndex == 0 then
    return
  end
  local classIndex = self.selClassIndex
  local count = #self.matchClassList[classIndex].optionList
  if count < self.selOptionIndex then
    self.selOptionIndex = count
  end
  local index = self.selOptionIndex
  local option = self.matchClassList[classIndex].optionList[index]
  self:CheckToShowAidNewbieOption(option)
  local classItemObj = self.uiObjs.LeftList:FindDirect("item_" .. self.selClassIndex)
  local optionItemObj = classItemObj:FindDirect("tween1/optionItem_" .. self.selOptionIndex)
  GUIUtils.Toggle(optionItemObj, true)
  local subCfg = option:GetSubCfg()
  if subCfg then
    local subOptionList = subCfg.optionList
    self:SetSubOptionList(self.selClassIndex, self.selOptionIndex, subOptionList)
    self:OpenSelectedSubOption(optionItemObj, subOptionList)
  else
    self:DragToMakeVisible(self.uiObjs.LeftScrollView, optionItemObj)
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
  self:RefreshMatchMemberInfo()
end
def.method("number", "number", "table").SetSubOptionList = function(self, classIndex, optionIndex, subOptionList)
  local classItemObj = self.uiObjs.LeftList:FindDirect("item_" .. classIndex)
  local optionItemObj = classItemObj:FindDirect("tween1/optionItem_" .. optionIndex)
  local tween = optionItemObj:FindDirect("Group_Tween/tween2")
  GUIUtils.SetActive(tween, true)
  local template = tween:FindDirect("Info_Activity")
  GUIUtils.SetActive(template, false)
  local uiTable = tween:GetComponent("UITable")
  uiTable:Reposition()
  local items = uiTable.children
  for i, v in ipairs(subOptionList) do
    local item = items[i]
    if item == nil then
      item = GameObject.Instantiate(template)
      item:SetActive(true)
      item.name = "subOptionItem_" .. i
      item.transform.parent = tween.transform
      item.transform.localScale = Vector.Vector3.one
      item.transform.localPosition = Vector.Vector3.zero
    else
      item = item.gameObject
    end
    self:SetSubOptionListItem(i, item, v)
  end
  local optionCount = #subOptionList
  for i = optionCount + 1, #items do
    local item = items[i]
    if item then
      GameObject.Destroy(item.gameObject)
    end
  end
end
def.method("number", "userdata", "table").SetSubOptionListItem = function(self, index, itemObj, itemViewData)
  local Label_Name = itemObj:FindDirect("Label_NameMap")
  GUIUtils.SetText(Label_Name, itemViewData.name)
  local Label_Lv = itemObj:FindDirect("Label_Lv")
  local text = string.format(textRes.TeamPlatform[6], itemViewData.minLevel, itemViewData.maxLevel)
  GUIUtils.SetText(Label_Lv, text)
  local Img_OnMatch = itemObj:FindDirect("Img_OnMatch")
  GUIUtils.SetActive(Img_OnMatch, false)
  local optionId = self.matchClassList[self.selClassIndex].optionList[self.selOptionIndex].id
  if self:IsOptionMatching(optionId, index) then
    GUIUtils.SetActive(Img_OnMatch, true)
    self.uiObjs.Img_OnMatch = Img_OnMatch
  end
end
def.method("number", "number", "=>", "boolean").IsOptionMatching = function(self, optionId, subOptionIdex)
  local isMatching = TeamPlatformMgr.Instance().isMatching
  if not isMatching then
    return false
  end
  local lastMatchDatas = TeamPlatformMgr.Instance():GetLastMatchData()
  if lastMatchDatas and lastMatchDatas[1] and lastMatchDatas[1][1] then
    local lastOptionId, lastSubOptionIndex = unpack(lastMatchDatas[1][1])
    if optionId == lastOptionId and lastSubOptionIndex == subOptionIdex then
      return true
    end
  end
  return false
end
def.method("userdata", "table").OpenSelectedSubOption = function(self, optionItemObj, subOptionList)
  if self.selSubOptionIndex <= 0 or self.selSubOptionIndex > #subOptionList then
    self.selSubOptionIndex = #subOptionList
  end
  local index = self.selSubOptionIndex
  if index == 0 then
    return
  end
  local subOptionItem = optionItemObj:FindDirect("Group_Tween/tween2/subOptionItem_" .. index)
  GUIUtils.Toggle(subOptionItem, true)
  self:DragToMakeVisible(self.uiObjs.LeftScrollView, subOptionItem)
end
def.method().UpdateRightGroup = function(self)
  if TeamData.Instance():HasTeam() then
    self:UpdateHasTeamRightGroup()
  else
    self.selectedRange = TeamPlatformMgr.MatchRange.First
    self:UpdateNoTeamRightGroup()
  end
end
def.method().UpdateNoTeamRightGroup = function(self)
  local matchOption = self:GetSelectedMatchOption()
  local matchMembersViewData = TeamPlatformUIMgr.Instance():GetTeamPlatformMatchMembersViewData(matchOption)
  local viewData = matchMembersViewData
  self.teams = viewData.teams
  local uiList = self.uiObjs.List_Team:GetComponent("UIList")
  uiList.itemCount = #viewData.teams
  uiList:Resize()
  local items = uiList.children
  for i, teamInfo in ipairs(viewData.teams) do
    self:SetTeamMatchInfo(i, items[i], teamInfo)
  end
  local text = string.format(textRes.TeamPlatform[19], matchMembersViewData.cpatainNum, matchMembersViewData.nonCapatainNum)
  GUIUtils.SetText(self.uiObjs.Label_MatchInfo, text)
  local Label_AutoMatch = self.uiObjs.Group_NoTeam:FindDirect("Label_IntelTeam")
  self:UpdateAutoMatchOption(matchOption, Label_AutoMatch)
end
def.method("table", "userdata").UpdateAutoMatchOption = function(self, matchOption, Label_AutoMatch)
  local canAutoMatch = false
  if matchOption then
    local matchCfgId = matchOption[1]
    canAutoMatch = AutoMatchMgr.Instance():CanAutoMatch(matchCfgId)
  end
  GUIUtils.SetActive(Label_AutoMatch, canAutoMatch)
  if canAutoMatch then
    local Img_Toggle = Label_AutoMatch:FindDirect("Img_Toggle")
    local matchCfgId = matchOption[1]
    local isAuto = AutoMatchMgr.Instance():IsAutoMatchcing(matchCfgId)
    GUIUtils.Toggle(Img_Toggle, isAuto)
  end
end
def.method("number", "userdata", "table").SetTeamMatchInfo = function(self, index, itemObj, teamInfo)
  itemObj.name = "matchInfoItem_" .. index
  local Btn_Apply = itemObj:FindDirect("Btn_Apply")
  if Btn_Apply then
    Btn_Apply.name = "Btn_Apply_" .. index
  end
  local Label_Name = itemObj:FindDirect("Label_Name")
  GUIUtils.SetText(Label_Name, teamInfo.cpatainName)
  local Label_MenPai = itemObj:FindDirect("Label_MenPai")
  GUIUtils.SetText(Label_MenPai, _G.GetOccupationName(teamInfo.cpatainOccupation))
  local Label_Lv = itemObj:FindDirect("Label_Lv")
  local text = string.format(textRes.Common[3], teamInfo.cpatainLevel)
  GUIUtils.SetText(Label_Lv, text)
  local Label = itemObj:FindDirect("Label")
  local text = string.format(textRes.TeamPlatform[20], teamInfo.matchName, teamInfo.levelRange.levelLow, teamInfo.levelRange.levelHigh)
  GUIUtils.SetText(Label, text)
  local teamCapacity = require("Main.Team.TeamUtils").GetTeamConsts("TEAM_CAPACITY")
  local val = teamInfo.membersNum / teamCapacity
  local Img_Slider = itemObj:FindDirect("Img_Slider")
  GUIUtils.SetProgress(Img_Slider, "UISlider", val)
  local Label_Num = Img_Slider:FindDirect("Label_Num")
  local text = string.format(textRes.TeamPlatform[21], teamInfo.membersNum, teamCapacity)
  GUIUtils.SetText(Label_Num, text)
end
def.method().UpdateHasTeamRightGroup = function(self)
  self:UpdateMatchRange()
  self:UpdateOptionDesc()
  local Label_AutoMatch = self.uiObjs.Group_InTeam:FindDirect("Label_IntelTeam")
  local matchOption = self:GetSelectedMatchOption()
  self:UpdateAutoMatchOption(matchOption, Label_AutoMatch)
end
def.method().UpdateOptionDesc = function(self)
  local text = ""
  if self.matchClassList[self.selClassIndex] and self.matchClassList[self.selClassIndex].optionList[self.selOptionIndex] then
    text = self.matchClassList[self.selClassIndex].optionList[self.selOptionIndex].instruction
  end
  GUIUtils.SetText(self.uiObjs.Label_TargetInfo, text)
end
def.method("number", "userdata", "userdata", "table").AddOptionListItem = function(self, index, template, rootObj, data)
  local newItemName = "Btn_List_" .. index
  local newItem = rootObj:FindDirect(newItemName)
  if newItem == nil then
    newItem = GameObject.Instantiate(template)
    newItem.name = newItemName
    newItem:SetActive(true)
    newItem.transform.parent = rootObj.transform
    newItem.transform.localScale = Vector.Vector3.one
    newItem.transform.localPosition = Vector.Vector3.zero
    local uiToggle = newItem:GetComponent("UIToggle")
    self:AssignUniqueGroupId(uiToggle)
  end
  newItem:FindDirect("Label_NameMap"):GetComponent("UILabel"):set_text(data.name)
  local levelRangeText = string.format(textRes.TeamPlatform[6], data.minLevel, data.maxLevel)
  newItem:FindDirect("Label_Lv"):GetComponent("UILabel"):set_text(levelRangeText)
end
def.method().StartMatch = function(self)
  local role = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  if role and (role:IsInState(RoleState.HUG) or role:IsInState(RoleState.BEHUG)) then
    Toast(textRes.Hero[57])
    return
  end
  if #self.matchClassList == 0 then
    Toast(textRes.TeamPlatform[25])
    return
  end
  if self.selOptionIndex == 0 then
    Toast(textRes.TeamPlatform[8])
    return
  end
  local matchOptions = self:GenMatchOptions()
  local result = TeamPlatformMgr.Instance():StartMatch(matchOptions, self.selectedRange)
  if result == TeamPlatformMgr.CResult.SUCCESS then
  elseif result == TeamPlatformMgr.CResult.ONLY_TEAM_LEADER_APPROVED then
    Toast(textRes.TeamPlatform[1])
  elseif result == TeamPlatformMgr.CResult.TEAM_MEMBERS_REACHED_MAX then
    Toast(textRes.TeamPlatform[2])
  end
end
def.method("=>", "table").GenMatchOptions = function(self)
  local matchOption = self:GetSelectedMatchOption()
  local matchOptions = {matchOption}
  return matchOptions
end
def.method("=>", "table").GetSelectedMatchOption = function(self)
  local classIndex = self.selClassIndex
  local matchClass = self.matchClassList[classIndex]
  if matchClass == nil then
    return nil
  end
  local optionList = matchClass.optionList
  local option = optionList[self.selOptionIndex]
  if option == nil then
    return nil
  end
  local subOptionIndex = 0
  local subCfg = option:GetSubCfg()
  if subCfg and subCfg.optionList[self.selSubOptionIndex] then
    subOptionIndex = subCfg.optionList[self.selSubOptionIndex].index
  end
  return {
    option.id,
    subOptionIndex
  }
end
def.method().CancelMatch = function(self)
  local result = TeamPlatformMgr.Instance():CancelMatch()
  if result == TeamPlatformMgr.CResult.SUCCESS then
  end
end
def.method().ShowMarchingState = function(self)
  self:SetMarchButtonText(textRes.TeamPlatform[4])
  self:OpenSelectedClass()
end
def.method().ShowIdlingState = function(self)
  self:SetMarchButtonText(textRes.TeamPlatform[3])
  if self.uiObjs.Img_OnMatch then
    GUIUtils.SetActive(self.uiObjs.Img_OnMatch, false)
  end
end
def.method("string").SetMarchButtonText = function(self, text)
  GUIUtils.SetText(self.uiObjs.Btn_Auto_Label, text)
end
def.method().UpdateMatchRange = function(self)
  if not TeamData.Instance():HasTeam() then
    return
  end
  local firstRange = TeamPlatformMgr.Instance():GetMatchRangeLevelBound(TeamPlatformMgr.MatchRange.First)
  local secondRange = TeamPlatformMgr.Instance():GetMatchRangeLevelBound(TeamPlatformMgr.MatchRange.Second)
  local matchOptions = self:GenMatchOptions()
  if matchOptions and matchOptions[1] then
    local minLevel = TeamPlatformMgr.Instance():GetMatchOptionMinLevel(matchOptions[1])
    firstRange.floor = math.max(firstRange.floor, minLevel)
    secondRange.floor = math.max(secondRange.floor, minLevel)
  end
  local Label_Lv = self.uiObjs.Group_Lv1:FindDirect("Label_Lv")
  Label_Lv:GetComponent("UILabel").text = string.format(textRes.TeamPlatform[6], firstRange.floor, firstRange.ceil)
  local Label_Lv = self.uiObjs.Group_Lv2:FindDirect("Label_Lv")
  Label_Lv:GetComponent("UILabel").text = string.format(textRes.TeamPlatform[6], secondRange.floor, secondRange.ceil)
  self:UpdateRangeToggle()
end
def.method().UpdateMatchState = function(self)
  if TeamPlatformMgr.Instance().isMatching then
    self:ShowMarchingState()
  else
    self:ShowIdlingState()
  end
end
def.method("number").SelectMatchRange = function(self, range)
  self.selectedRange = range
end
def.method("table").CheckToShowAidNewbieOption = function(self, optionData)
  if TeamPlatformMgr.Instance():IsAidNewbieAvilable(optionData) then
    self.uiObjs.Group_New:SetActive(true)
  else
    self.uiObjs.Group_New:SetActive(false)
    if self.selectedRange == TeamPlatformMgr.MatchRange.AidNewbie then
      self:SelectRange(TeamPlatformMgr.MatchRange.First)
    end
  end
end
def.method("number").SelectRange = function(self, range)
  self.selectedRange = range
  self:UpdateRangeToggle()
end
def.method().UpdateRangeToggle = function(self)
  local toggleObj
  if self.selectedRange == TeamPlatformMgr.MatchRange.First then
    toggleObj = self.uiObjs.Group_Lv1:FindDirect("Img_Di")
  elseif self.selectedRange == TeamPlatformMgr.MatchRange.Second then
    toggleObj = self.uiObjs.Group_Lv2:FindDirect("Img_Di")
  elseif self.selectedRange == TeamPlatformMgr.MatchRange.AidNewbie then
    toggleObj = self.uiObjs.Group_New:FindDirect("Img_Di")
  end
  GUIUtils.Toggle(toggleObj, true)
end
def.method().CheckToSelectTargetOptions = function(self)
  if self.matchClassList == nil then
    return
  end
  local targetOptionId = self.targetOptionId
  if targetOptionId == 0 then
    targetOptionId = constant.TeamPlatformConsts.ZHEN_YAO_MATCH_ID
  end
  for classIndex, v in ipairs(self.matchClassList) do
    for optionIndex, vv in ipairs(v.optionList) do
      if vv.id == targetOptionId then
        self.targetOptionId = targetOptionId
        self.selOptionIndex = optionIndex
        self.selClassIndex = classIndex
        self.selSubOptionIndex = self.targetOptionSubIndex
        break
      end
    end
  end
end
def.method().UpdateTeamBtnStates = function(self)
  local TeamData = require("Main.Team.TeamData")
  local teamData = TeamData.Instance()
  if teamData:HasTeam() then
    GUIUtils.SetText(self.uiObjs.Btn_Creat_Label, textRes.TeamPlatform[17])
  else
    GUIUtils.SetText(self.uiObjs.Btn_Creat_Label, textRes.TeamPlatform[16])
  end
end
def.method("number").OnApplyTeamBtnClicked = function(self, index)
  if self.teams == nil then
    return
  end
  local teamInfo = self.teams[index]
  if teamInfo then
    local teamId = teamInfo.teamId
    TeamModule.Instance():ApplyTeam(teamId)
  end
end
def.method().OnRefreshBtnClicked = function(self)
  if #self.matchClassList == 0 then
    Toast(textRes.TeamPlatform[25])
    return
  end
  local classIndex = self.selClassIndex
  local optionList = self.matchClassList[classIndex].optionList
  local option = optionList[self.selOptionIndex]
  if option == nil then
    Toast(textRes.TeamPlatform[8])
    return
  end
  local matchOption = self:GetSelectedMatchOption()
  local isSuccess = TeamPlatformMgr.Instance():ReqMatchMemberInfo(unpack(matchOption))
  self.uiObjs.Btn_Refresh:GetComponent("UIButton").isEnabled = false
  do
    local sec = TeamPlatformMgr.REQ_MATCH_INFO_MIN_INTERVAL_SEC
    local function updateRefreshBtnText(sec)
      local secText = ""
      if sec > 0 then
        secText = string.format(textRes.TeamPlatform[23], sec)
      end
      local text = string.format(textRes.TeamPlatform[22], secText)
      GUIUtils.SetText(self.uiObjs.Btn_Refresh:FindDirect("Label"), text)
    end
    local function countDown()
      GameUtil.AddGlobalTimer(1, true, function()
        if self.m_panel == nil then
          return
        end
        sec = sec - 1
        updateRefreshBtnText(sec)
        if sec > 0 then
          countDown()
        else
          self.uiObjs.Btn_Refresh:GetComponent("UIButton").isEnabled = true
        end
      end)
    end
    updateRefreshBtnText(sec)
    countDown()
  end
end
def.method().RefreshMatchMemberInfo = function(self)
  if #self.matchClassList == 0 then
    return
  end
  self:UpdateRightGroup()
  if self.arTimerId ~= 0 then
    return
  end
  local function reqMatchMemberInfo()
    local matchOption = self:GetSelectedMatchOption()
    if matchOption == nil then
      return false
    end
    local matchCfgId, index = unpack(matchOption)
    if matchCfgId and index then
      return TeamPlatformMgr.Instance():ReqMatchMemberInfo(matchCfgId, index)
    end
    return true
  end
  local isSuccess = reqMatchMemberInfo()
  if not isSuccess then
    self.arTimerId = GameUtil.AddGlobalTimer(TeamPlatformMgr.REQ_MATCH_INFO_MIN_INTERVAL_SEC, true, function()
      self.arTimerId = 0
      if not self:IsShow() then
        return
      end
      reqMatchMemberInfo()
    end)
  end
end
def.static("table", "table").OnSyncMatchState = function(params)
  local isMatching = params.isMatching
  if isMatching then
    instance:ShowMarchingState()
    instance:DestroyPanel()
  else
    instance:ShowIdlingState()
  end
end
def.static("table", "table").OnTeamInfoUpdate = function(params)
  local roleId = _G.GetMyRoleID()
  local TeamData = require("Main.Team.TeamData")
  local teamData = TeamData.Instance()
  if teamData:HasTeam() and not teamData:IsCaptain(roleId) then
    instance:DestroyPanel()
    return
  end
  instance:UpdateUI()
end
def.static("table", "table").OnMatchMembersUpdate = function(params)
  local self = instance
  self:UpdateRightGroup()
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method("userdata", "userdata").DragToMakeVisible = function(self, scrollView, targetObj)
  local uiScrollView = scrollView:GetComponent("UIScrollView")
  GameUtil.AddGlobalLateTimer(0, true, function()
    GameUtil.AddGlobalLateTimer(0, true, function()
      if self:IsShow() then
        uiScrollView:InvalidateBounds()
        uiScrollView:UpdatePosition()
        uiScrollView:DragToMakeVisible(targetObj.transform, 20)
      end
    end)
  end)
end
def.method().PreloadDatas = function(self)
  if TeamData.Instance():HasTeam() or self.targetOptionId > 0 then
  end
end
def.method().Clear = function(self)
  self.uiObjs = nil
  self.teams = nil
  local classIndex = self.selClassIndex
  local matchClass = self.matchClassList[classIndex]
  if matchClass then
    local optionList = matchClass.optionList
    local option = optionList[self.selOptionIndex]
    if option then
      self.targetOptionId = option.id
      self.targetOptionSubIndex = self.selSubOptionIndex
    end
  end
  self.selClassIndex = 0
  self.selOptionIndex = 0
  self.selSubOptionIndex = 0
end
def.method().Reset = function(self)
  self.targetOptionId = 0
  self.targetOptionSubIndex = 0
  self.selectedOptions = {}
  self.selectedRange = TeamPlatformMgr.MatchRange.First
end
return TeamPlatformPanel.Commit()
