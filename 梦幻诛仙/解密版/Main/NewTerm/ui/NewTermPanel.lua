local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local NewTermUtils = require("Main.NewTerm.NewTermUtils")
local NewTermData = require("Main.NewTerm.data.NewTermData")
local ActivityInterface = require("Main.activity.ActivityInterface")
local activityInterface = ActivityInterface.Instance()
local ActivityType = require("consts.mzm.gsp.activity.confbean.ActivityType")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local NewTermPanel = Lplus.Extend(ECPanelBase, "NewTermPanel")
local def = NewTermPanel.define
local instance
def.static("=>", NewTermPanel).Instance = function()
  if instance == nil then
    instance = NewTermPanel()
  end
  return instance
end
local CUR_AWARD_MAX_NUM = 3
local AWARD_MAX_BOX_NUM = 3
local AWARD_OPEN_SPRITE = "Box_1_0"
local AWARD_CLOSE_SPRITE = "Box_1_1"
local GREEN_LABEL = "00ff00"
local RED_LABEL = "ff0000"
def.field("table")._uiObjs = nil
def.field("table")._actDisplayCfg = nil
def.field("table")._actAchieveCfg = nil
def.field("table")._sortedSubActivityCfgs = nil
def.field("table")._actCurAchieveInfoMap = nil
def.field("table")._actCurAchieveCfgMap = nil
def.field("table")._actAwardListMap = nil
def.static("table", "table").ShowPanel = function(actDisplayCfg, actAchievementCfg)
  if nil == actDisplayCfg or nil == actAchievementCfg then
    warn("[ERROR][NewTermPanel:ShowPanel] actDisplayCfg or actAchievementCfg nil.")
    return
  elseif NewTermPanel.Instance():GetCurActivityId() == actDisplayCfg.activityId then
    warn("[NewTermPanel:ShowPanel] same activityId, return.")
    return
  end
  NewTermPanel.Instance():_InitData(actDisplayCfg, actAchievementCfg)
  if NewTermPanel.Instance():IsShow() then
    NewTermPanel.Instance():UpdateUI()
    return
  end
  instance:CreatePanel(RESPATH.PREFAB_NEW_TERM_PANEL, 1)
end
def.method("table", "table")._InitData = function(self, actDisplayCfg, actAchievementCfg)
  self._actDisplayCfg = actDisplayCfg
  self._actAchieveCfg = actAchievementCfg
end
def.method("=>", "number").GetCurActivityId = function(self)
  return self._actDisplayCfg and self._actDisplayCfg.activityId or 0
end
def.method("=>", "number").GetCurActivityTip = function(self)
  return self._actDisplayCfg and self._actDisplayCfg.tipId or 0
end
def.override().OnCreate = function(self)
  self:SetModal(true)
  self:_InitUI()
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.Img_Title = self.m_panel:FindDirect("Img_bg0/Group_view/Img_Title")
  self._uiObjs.Label_time = self.m_panel:FindDirect("Img_bg0/Group_shuoming/Label_time")
  self._uiObjs.Group_ScrollView = self.m_panel:FindDirect("Img_bg0/Group_Scroll View")
  self._uiObjs.ScrollView_main = self._uiObjs.Group_ScrollView:FindDirect("Scroll View_main")
  self._uiObjs.actUIScrollview = self._uiObjs.ScrollView_main:GetComponent("UIScrollView")
  self._uiObjs.List_Activity = self._uiObjs.ScrollView_main:FindDirect("List_item")
  self._uiObjs.actUIList = self._uiObjs.List_Activity:GetComponent("UIList")
end
def.override("boolean").OnShow = function(self, show)
  self:HandleEventListeners(show)
  if show then
    self:UpdateUI()
  else
  end
end
def.method().UpdateUI = function(self)
  GUIUtils.SetTexture(self._uiObjs.Img_Title, self._actDisplayCfg.titleTexId)
  local activityCfg = ActivityInterface.GetActivityCfgById(self._actDisplayCfg.activityId)
  GUIUtils.SetText(self._uiObjs.Label_time, activityCfg and activityCfg.timeDes or "")
  self:UpdateActivityList()
end
def.override().OnDestroy = function(self)
  self:ClearActivityList()
  self._actDisplayCfg = nil
  self._actAchieveCfg = nil
  self._sortedSubActivityCfgs = nil
  self._actCurAchieveInfoMap = nil
  self._actCurAchieveCfgMap = nil
  self._actAwardListMap = nil
  self._uiObjs = nil
end
def.method().UpdateActivityList = function(self)
  self._actCurAchieveInfoMap = {}
  self._actCurAchieveCfgMap = {}
  self._actAwardListMap = {}
  self:ClearActivityList()
  self._sortedSubActivityCfgs = NewTermUtils.GetSortedValidSubActs(self._actAchieveCfg)
  local actAmount = self._sortedSubActivityCfgs and #self._sortedSubActivityCfgs or 0
  if actAmount <= 0 then
    return
  end
  self._uiObjs.actUIList.itemCount = actAmount
  self._uiObjs.actUIList:Resize()
  self._uiObjs.actUIList:Reposition()
  for index, subActivityCfg in ipairs(self._sortedSubActivityCfgs) do
    self:ShowSubActivity(index, subActivityCfg)
  end
end
def.method("number", "table").ShowSubActivity = function(self, index, subActivityCfg)
  if nil == subActivityCfg then
    warn("[ERROR][NewTermPanel:ShowSubActivity] subActivityCfg nil at index:", index)
    return
  end
  local listItem = self._uiObjs.List_Activity:FindDirect("item_" .. index)
  if nil == listItem then
    warn("[ERROR][NewTermPanel:ShowSubActivity] listItem nil at index:", index)
    return
  end
  local activityCfg = ActivityInterface.GetActivityCfgById(subActivityCfg.activityId)
  self:ShowActivity(index, listItem, activityCfg)
  self:ShowAchieveRewards(index, listItem, subActivityCfg)
  local Img_table = listItem:FindDirect("Img_table")
  GUIUtils.SetActive(Img_table, index % 2 ~= 0)
end
def.method("number", "userdata", "table").ShowActivity = function(self, index, listItem, activityCfg)
  if activityCfg then
    local Img_BgIcon = listItem:FindDirect("Container_hd/Img_hd frame/Img_hdlogo")
    GUIUtils.SetTexture(Img_BgIcon, activityCfg.activityIcon)
    Img_BgIcon.name = "Img_BgIcon" .. index
    local Label_Name = listItem:FindDirect("Container_hd/Img_hd frame/Label_hdname")
    GUIUtils.SetText(Label_Name, activityCfg.activityName)
  else
    warn("[ERROR][NewTermPanel:ShowActivity] activityCfg nil.")
  end
end
def.method().ClearActivityList = function(self)
  self._uiObjs.actUIList.itemCount = 0
  self._uiObjs.actUIList:Resize()
  self._uiObjs.actUIList:Reposition()
end
def.method("number", "userdata", "table").ShowAchieveRewards = function(self, index, listItem, subActivityCfg)
  local curCount, goalCount = NewTermData.Instance():GetSubActivityProgress(subActivityCfg)
  curCount = math.min(curCount, goalCount)
  warn(string.format("[NewTermPanel:ShowAchieveRewards] subActivityCfg.activityId[%d]: curCount[%d], goalCount[%d].", subActivityCfg.activityId, curCount, goalCount))
  local Label_number = listItem:FindDirect("Label_number")
  GUIUtils.SetText(Label_number, curCount)
  local nextAchieveInfo, nextAchieveCfg
  local AchievementData = require("Main.achievement.AchievementData")
  local achievements = subActivityCfg.achievements
  local Lable_jindu = listItem:FindDirect("Lable_jindu")
  local progressStr = ""
  for idx = 1, AWARD_MAX_BOX_NUM do
    local achieveId = achievements and achievements[idx]
    local achieveCfg = AchievementData.GetAchievementGoalCfg(achieveId)
    local achieveInfo = achieveId and NewTermData.Instance():GetAchievementInfo(subActivityCfg.parentActivityId, achieveId)
    if achieveCfg then
      local achieveCurCount, achieveGoalCount = NewTermData.Instance():GetAchievemntProgress(subActivityCfg.parentActivityId, achieveId)
      local achieveState = achieveInfo and achieveInfo.state or 1
      local color = RED_LABEL
      if achieveState == 1 then
        color = RED_LABEL
      else
        color = GREEN_LABEL
      end
      progressStr = progressStr .. string.format(textRes.NewTerm.PROGRESS_FORMAT, color, achieveGoalCount)
      if nil == nextAchieveCfg and (achieveState ~= 3 or idx == AWARD_MAX_BOX_NUM) then
        nextAchieveCfg = achieveCfg
        nextAchieveInfo = achieveInfo
      end
    else
      warn("[ERROR][NewTermPanel:ShowAchieveRewards] achieveCfg nil for idx, achieveId:", idx, achieveId)
    end
    if idx ~= AWARD_MAX_BOX_NUM then
      progressStr = progressStr .. "/"
    end
  end
  GUIUtils.SetText(Lable_jindu, progressStr)
  self._actCurAchieveInfoMap[subActivityCfg.activityId] = nextAchieveInfo
  self._actCurAchieveCfgMap[subActivityCfg.activityId] = nextAchieveCfg
  local awardList = listItem:FindDirect("Container_gift")
  awardList.name = "Container_gift" .. index
  local uiList = awardList and awardList:GetComponent("UIList")
  if nextAchieveCfg then
    local awardId = nextAchieveCfg.fixAwardId
    self:ShowNextAwardList(index, awardId, uiList)
  else
    warn("[ERROR][NewTermPanel:ShowAchieveRewards] nextAchieveCfg nil.")
    uiList.itemCount = 0
    uiList:Resize()
    uiList:Reposition()
  end
  local Img_complete = listItem:FindDirect("Img_complete")
  local fetchBtn = listItem:FindDirect("Btn_get")
  local Label_get = fetchBtn:FindDirect("Label_get")
  local Img_Red = fetchBtn:FindDirect("Img_Red")
  local nextAchieveState = nextAchieveInfo and nextAchieveInfo.state or 1
  if nextAchieveState == 1 then
    GUIUtils.SetActive(Img_complete, false)
    GUIUtils.SetActive(fetchBtn, true)
    GUIUtils.SetActive(Img_Red, false)
    GUIUtils.SetActive(Label_get, true)
    GUIUtils.SetText(Label_get, textRes.NewTerm.JOIN_ACTIVITY)
  elseif nextAchieveState == 2 then
    GUIUtils.SetActive(Img_complete, false)
    GUIUtils.SetActive(fetchBtn, true)
    GUIUtils.SetActive(Img_Red, true)
    GUIUtils.SetActive(Label_get, true)
    GUIUtils.SetText(Label_get, textRes.NewTerm.AWARD_FETCH)
    GUIUtils.SetLightEffect(fetchBtn, GUIUtils.Light.Square)
  else
    GUIUtils.SetActive(Img_complete, true)
    GUIUtils.SetActive(fetchBtn, false)
    GUIUtils.SetActive(Img_Red, false)
    GUIUtils.SetActive(Label_get, false)
  end
end
def.method("number", "number", "userdata").ShowNextAwardList = function(self, index, awardId, uiList)
  if uiList then
    if awardId > 0 then
      local itemList = NewTermUtils.GetAwardItems(awardId)
      self._actAwardListMap[index] = itemList
      local itemCount = itemList and math.min(#itemList, CUR_AWARD_MAX_NUM) or 0
      uiList.itemCount = itemCount
      uiList:Resize()
      uiList:Reposition()
      for idx = 1, itemCount do
        local item = itemList[idx]
        local listItem = uiList.children[idx]
        self:ShowAward(idx, item, listItem)
      end
    else
      uiList.itemCount = 0
      uiList:Resize()
      uiList:Reposition()
    end
  else
    warn("[ERROR][NewTermPanel:ShowNextAwardList] UIList nil.")
  end
end
def.method("number", "table", "userdata").ShowAward = function(self, index, item, listItem)
  local ItemUtils = require("Main.Item.ItemUtils")
  local itemBase = ItemUtils.GetItemBase(item.itemId)
  if nil == itemBase then
    warn("[ERROR][NewTermPanel:ShowAward] itemBase nil for item.itemId:", item.itemId)
    return
  end
  if nil == listItem then
    warn("[ERROR][NewTermPanel:ShowAward] listItem nil at index:", index)
    return
  end
  GUIUtils.SetTexture(listItem, item.iconId)
  local Img_Frame = listItem:FindDirect("Img_gift frame1")
  GUIUtils.SetSprite(Img_Frame, string.format("Cell_%02d", itemBase.namecolor))
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_close" then
    self:DestroyPanel()
  elseif id == "Btn_tanhao" then
    self:OnBtn_Rule()
  elseif id == "Btn_get" then
    self:OnBtn_Get(clickObj)
  elseif string.find(id, "item_") then
    self:OnBtn_Award(clickObj)
  elseif string.find(id, "Img_BgIcon") then
    self:OnActivityIconClick(id)
  end
end
def.method().OnBtn_Rule = function(self)
  GUIUtils.ShowHoverTip(self:GetCurActivityTip(), 0, 0)
end
def.method("userdata").OnBtn_Get = function(self, clickObj)
  local parent = clickObj and clickObj.parent
  local id = parent and parent.name or ""
  local prefix = "item_"
  local index = tonumber(string.sub(id, string.len(prefix) + 1))
  local subActivityCfg = index and self._sortedSubActivityCfgs[index] or nil
  local activityId = subActivityCfg and subActivityCfg.activityId or 0
  local nextAchieveInfo = self._actCurAchieveInfoMap[activityId]
  local nextAchieveCfg = self._actCurAchieveCfgMap[activityId]
  if nextAchieveCfg then
    local nextAchieveState = nextAchieveInfo and nextAchieveInfo.state or 1
    if nextAchieveState == 1 then
      local bActivityOpen = ActivityInterface.Instance():isActivityOpend(activityId)
      if bActivityOpen then
        if NewTermUtils.IsActivityDone(activityId) then
          Toast(textRes.NewTerm.JOIN_ACTIVITY_FINISHED)
        else
          self:DestroyPanel()
          warn(string.format("[NewTermPanel:OnBtn_Get] dispatch event Activity_Todo on activityId[%d].", activityId))
          Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, {activityId})
        end
      else
        Toast(textRes.NewTerm.JOIN_ACTIVITY_NOT_OPEN)
      end
    elseif nextAchieveState == 2 then
      local NewTermProtocols = require("Main.NewTerm.NewTermProtocols")
      NewTermProtocols.SendCGetAchievementGoalAward(subActivityCfg.parentActivityId, nextAchieveCfg.id)
    else
      Toast(textRes.NewTerm.FETCH_AWARD_ALREADY_FETCHED)
    end
  else
    warn("[ERROR][NewTermPanel:OnBtn_Get] nextAchieveCfg nil for activityId:", activityId)
  end
end
def.method("userdata").OnBtn_Award = function(self, clickObj)
  local id = clickObj.name
  local togglePrefix = "item_"
  local itemIndex = tonumber(string.sub(id, string.len(togglePrefix) + 1))
  local parentId = clickObj.parent and clickObj.parent.name or ""
  local parentPrefix = "Container_gift"
  local actIndex = tonumber(string.sub(parentId, string.len(parentPrefix) + 1))
  local itemList = self._actAwardListMap[actIndex]
  local item = itemList and itemList[itemIndex] or nil
  if item and item.itemId and clickObj then
    ItemTipsMgr.Instance():ShowBasicTipsWithGO(item.itemId, clickObj, 0, false)
  end
end
def.method("string").OnActivityBGClick = function(self, id)
  local togglePrefix = "Img_name"
  local index = tonumber(string.sub(id, string.len(togglePrefix) + 1))
  local subActivityCfg = index and self._sortedSubActivityCfgs[index] or nil
  local actCfg = ActivityInterface.GetActivityCfgById(subActivityCfg and subActivityCfg.activityId or 0)
  self:_ShowActivityTip(actCfg)
end
def.method("string").OnActivityIconClick = function(self, id)
  local togglePrefix = "Img_BgIcon"
  local index = tonumber(string.sub(id, string.len(togglePrefix) + 1))
  local subActivityCfg = index and self._sortedSubActivityCfgs[index] or nil
  local actCfg = ActivityInterface.GetActivityCfgById(subActivityCfg and subActivityCfg.activityId or 0)
  self:_ShowActivityTip(actCfg)
end
def.method("table")._ShowActivityTip = function(self, actCfg)
  if actCfg == nil then
    warn("[ERROR][NewTermPanel:_ShowActivityTip] actCfg nil at index:", index)
    return
  end
  local activityID = actCfg.id
  local activityTip = require("Main.activity.ui.ActivityTip").Instance()
  if activityTip:IsShow() == false then
    if activityID > 0 then
      activityTip:SetActivityID(activityID)
      activityTip:ShowDlg()
    end
  else
    activityTip:HideDlg()
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
    eventFunc(ModuleId.ACHIEVEMENT, gmodule.notifyId.Achievement.ACHIEVEMENT_GOAL_INFO_CHANGE, NewTermPanel.OnAchievementChange)
    eventFunc(ModuleId.ACHIEVEMENT, gmodule.notifyId.Achievement.ACHIEVEMENT_INFO_UPDATE, NewTermPanel.OnAchievementUpdate)
  end
end
def.static("table", "table").OnAchievementChange = function(params, context)
  if instance then
    instance:UpdateActivityList()
  end
end
def.static("table", "table").OnAchievementUpdate = function(params, context)
  if instance then
    instance:UpdateActivityList()
  end
end
NewTermPanel.Commit()
return NewTermPanel
