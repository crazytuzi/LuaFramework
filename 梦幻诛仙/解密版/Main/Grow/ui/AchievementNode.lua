local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GrowGuideNodeBase = require("Main.Grow.ui.GrowGuideNodeBase")
local AchievementData = require("Main.achievement.AchievementData")
local AchievementFinishInfo = require("Main.achievement.AchievementFinishInfo")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local ChatMsgData = require("Main.Chat.ChatMsgData")
local GrowUtils = require("Main.Grow.GrowUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ECMSDK = require("ProxySDK.ECMSDK")
local AchievementNode = Lplus.Extend(GrowGuideNodeBase, MODULE_NAME)
local def = AchievementNode.define
local SELECT_TYPE = {
  ALL = 1,
  FINISH = 2,
  NOTFINISH = 3
}
local SELECT_BTNNANME = {
  [1] = textRes.Grow.Achievement[4],
  [2] = textRes.Grow.Achievement[5],
  [3] = textRes.Grow.Achievement[6]
}
def.field("table").uiTbl = nil
def.field("number").lastGroupListNum = 0
def.field("number").lastSelectGroup = 0
def.field("table").groupList = nil
def.field("number").lastGroupIndex = 0
def.field("number").curGroupIndex = 1
def.field("number").curSmallGroupIndex = 1
def.field("number").selectType = SELECT_TYPE.ALL
def.field("table").archievementFinishList = nil
def.field("table").archievementTotailList = nil
def.field("table").archievementDetailList = nil
def.field("boolean").getAwardButtonShowEffect = false
local instance
def.static("=>", AchievementNode).Instance = function()
  if instance == nil then
    instance = AchievementNode()
  end
  return instance
end
def.override(ECPanelBase, "userdata").Init = function(self, panelbase, node)
  GrowGuideNodeBase.Init(self, panelbase, node)
  self:InitUI()
end
def.override().OnShow = function(self)
  self:UpdateUI()
  Event.RegisterEvent(ModuleId.ACHIEVEMENT, gmodule.notifyId.Achievement.ACHIEVEMENT_INFO_UPDATE, AchievementNode.OnArchievementInfoUpdate)
  Event.RegisterEvent(ModuleId.ACHIEVEMENT, gmodule.notifyId.Achievement.ACHIEVEMENT_GOAL_INFO_CHANGE, AchievementNode.OnArchievementInfoUpdate)
  Event.RegisterEvent(ModuleId.ACHIEVEMENT, gmodule.notifyId.Achievement.ACHIEVEMENT_SCORE_AWARD_CHANGE, AchievementNode.OnArchievementScoreAwardChange)
end
def.override().OnHide = function(self)
  self.getAwardButtonShowEffect = false
  self:SetTotalAwardButtonEffect(false)
  Event.UnregisterEvent(ModuleId.ACHIEVEMENT, gmodule.notifyId.Achievement.ACHIEVEMENT_INFO_UPDATE, AchievementNode.OnArchievementInfoUpdate)
  Event.UnregisterEvent(ModuleId.ACHIEVEMENT, gmodule.notifyId.Achievement.ACHIEVEMENT_GOAL_INFO_CHANGE, AchievementNode.OnArchievementInfoUpdate)
  Event.UnregisterEvent(ModuleId.ACHIEVEMENT, gmodule.notifyId.Achievement.ACHIEVEMENT_SCORE_AWARD_CHANGE, AchievementNode.OnArchievementScoreAwardChange)
end
def.override("=>", "boolean").IsUnlock = function(self)
  return AchievementNode.IsAchievementFeatureOpen()
end
def.override("string", "boolean").onToggle = function(self, id, isActive)
end
def.override("=>", "boolean").HaveNotifyMessage = function(self)
  if AchievementNode.IsAchievementFeatureOpen() then
    return AchievementData.Instance():CanGetAward()
  else
    return false
  end
end
def.method().OnDestroy = function(self)
  self.selectType = SELECT_TYPE.ALL
  self.lastGroupListNum = 1
end
def.method().Reset = function(self)
end
def.method().InitUI = function(self)
  if not self.uiTbl then
    self.uiTbl = {}
  end
  local uiTbl = self.uiTbl
  local Img_BgLeft = self.m_node:FindDirect("Img_BgLeft")
  local GroupScrollView = Img_BgLeft:FindDirect("Scroll View")
  local Table_List = GroupScrollView:FindDirect("Table_List")
  local Tab_1 = Table_List:FindDirect("Tab_1")
  uiTbl.ScrollView = GroupScrollView
  uiTbl.Table_List = Table_List
  uiTbl.Tab_1 = Tab_1
  local Group_Detail = self.m_node:FindDirect("Group_Detail")
  local Group_TotalInfo = self.m_node:FindDirect("Group_TotalInfo")
  uiTbl.Group_Detail = Group_Detail
  uiTbl.Group_TotalInfo = Group_TotalInfo
  do
    local Group_TotalInfo_uiTbl = {}
    uiTbl.Group_TotalInfo_uiTbl = Group_TotalInfo_uiTbl
    local TotalInfoScrollView = Group_TotalInfo:FindDirect("Img_Bg/Scroll View")
    local listScrollView = TotalInfoScrollView:GetComponent("UIScrollView")
    local GridList = TotalInfoScrollView:FindDirect("Grid")
    Group_TotalInfo_uiTbl.GridList = GridList
    local uiPanel = TotalInfoScrollView:GetComponent("UIPanel")
    local finalClipRegion = uiPanel:get_finalClipRegion()
    local uiList = GridList:GetComponent("UIList")
    local padding = uiList:get_padding()
    Group_TotalInfo_uiTbl.list_clip_size_y = finalClipRegion.w
    Group_TotalInfo_uiTbl.list_padding_size_y = padding.y
    local Img_InfoBg = Group_TotalInfo:FindDirect("Img_InfoBg")
    local CountInfoScrollView = Img_InfoBg:FindDirect("Scroll View")
    local listCountInfoScrollView = CountInfoScrollView:GetComponent("UIScrollView")
    local CountInfoGridList = CountInfoScrollView:FindDirect("Grid")
    Group_TotalInfo_uiTbl.Img_InfoBg = Img_InfoBg
    Group_TotalInfo_uiTbl.CountInfoGridList = CountInfoGridList
    local Btn_Prize = Group_TotalInfo:FindDirect("Btn_Prize")
    Group_TotalInfo_uiTbl.Btn_Prize = Btn_Prize
  end
  local Group_Detail_uiTbl = {}
  uiTbl.Group_Detail_uiTbl = Group_Detail_uiTbl
  local DetailInfoScrollView = Group_Detail:FindDirect("Img_Bg/Scroll View")
  local listScrollView = DetailInfoScrollView:GetComponent("UIScrollView")
  local GridList = DetailInfoScrollView:FindDirect("Grid")
  Group_Detail_uiTbl.ScrollView = DetailInfoScrollView
  Group_Detail_uiTbl.listScrollView = listScrollView
  Group_Detail_uiTbl.GridList = GridList
  local Table_TeamBtn = Group_Detail:FindDirect("Panel/Table_TeamBtn")
  local Btn_All_Label = Table_TeamBtn:FindDirect("Btn_All/Label_bTN")
  local Btn_Have_Label = Table_TeamBtn:FindDirect("Btn_Have/Label_bTN")
  local Btn_No_Label = Table_TeamBtn:FindDirect("Btn_No/Label_bTN")
  Group_Detail_uiTbl.Table_TeamBtn = Table_TeamBtn
  Table_TeamBtn:SetActive(false)
  Btn_All_Label:GetComponent("UILabel"):set_text(SELECT_BTNNANME[1])
  Btn_Have_Label:GetComponent("UILabel"):set_text(SELECT_BTNNANME[2])
  Btn_No_Label:GetComponent("UILabel"):set_text(SELECT_BTNNANME[3])
  local Btn_Class = Group_Detail:FindDirect("Btn_Class")
  local Btn_ClassLabel = Btn_Class:FindDirect("Label")
  local Img_Up = Group_Detail:FindDirect("Btn_Class/Img_Up")
  local Img_Down = Group_Detail:FindDirect("Btn_Class/Img_Down")
  Group_Detail_uiTbl.Btn_Class = Btn_Class
  Group_Detail_uiTbl.Btn_ClassLabel = Btn_ClassLabel
  Group_Detail_uiTbl.Img_Up = Img_Up
  Group_Detail_uiTbl.Img_Down = Img_Down
  Img_Up:SetActive(true)
  Img_Down:SetActive(false)
  Btn_ClassLabel:GetComponent("UILabel"):set_text(SELECT_BTNNANME[self.selectType] or "")
  local Slider_Attribute01 = Group_Detail:FindDirect("Slider_Attribute01")
  local Slider_AttributeNum01 = Slider_Attribute01:FindDirect("Label_AttributeNumber")
  Group_Detail_uiTbl.Slider_Attribute01 = Slider_Attribute01
  Group_Detail_uiTbl.Slider_AttributeNum01 = Slider_AttributeNum01
  local Slider_Attribute02 = Group_Detail:FindDirect("Slider_Attribute02")
  local Slider_AttributeNum02 = Slider_Attribute02:FindDirect("Label_AttributeNumber")
  Group_Detail_uiTbl.Slider_Attribute02 = Slider_Attribute02
  Group_Detail_uiTbl.Slider_AttributeNum02 = Slider_AttributeNum02
end
def.method().UpdateUI = function(self)
  self.groupList = AchievementData.Instance():GetAchievementTypeList()
  self:UpdateGroupObjects()
  GameUtil.AddGlobalLateTimer(0, true, function()
    if _G.IsNil(self.m_node) then
      return
    end
    self:GroupItemsUpdate()
    self:SelectGroup(1)
  end)
end
def.method().UpdateTotalInfo = function(self)
  self.uiTbl.Group_Detail:SetActive(false)
  self.uiTbl.Group_TotalInfo:SetActive(true)
  self:UpdateTotalAwardButtonState()
  GameUtil.AddGlobalLateTimer(0, true, function()
    if _G.IsNil(self.m_node) then
      return
    end
    self:FillTotalCountList()
    self:FillTotalList()
  end)
end
def.method().UpdateTotalAwardButtonState = function(self)
  local getAwardButtonShowEffect = AchievementData.Instance():CanGetAward()
  self:SetTotalAwardButtonEffect(getAwardButtonShowEffect)
end
def.method().UpdateDetailInfo = function(self)
  self.uiTbl.Group_Detail:SetActive(true)
  self.uiTbl.Group_TotalInfo:SetActive(false)
  local Group_Detail_uiTbl = self.uiTbl.Group_Detail_uiTbl
  local Slider_Attribute01 = Group_Detail_uiTbl.Slider_Attribute01
  local Slider_AttributeNum01 = Group_Detail_uiTbl.Slider_AttributeNum01
  local Slider_Attribute02 = Group_Detail_uiTbl.Slider_Attribute02
  local Slider_AttributeNum02 = Group_Detail_uiTbl.Slider_AttributeNum02
  local Btn_Class = Group_Detail_uiTbl.Btn_Class
  local bigTypeCfg = self.groupList[self.curGroupIndex]
  local invisibleAchievementIndex = constant.AchievementConsts.invisibleAchievementIndex
  if bigTypeCfg.index == invisibleAchievementIndex then
    Btn_Class:SetActive(false)
    Slider_Attribute01:SetActive(false)
    Slider_Attribute02:SetActive(false)
  else
    Btn_Class:SetActive(true)
    Slider_Attribute01:SetActive(true)
    Slider_Attribute02:SetActive(true)
  end
  local countInfo = AchievementData.Instance():GetAchievementCountInfo(bigTypeCfg.index)
  if not _G.IsNil(countInfo) then
    Slider_AttributeNum01:GetComponent("UILabel"):set_text(string.format("%d/%d", countInfo.curScore, countInfo.maxScore))
    Slider_AttributeNum02:GetComponent("UILabel"):set_text(string.format("%d/%d", countInfo.curCount, countInfo.maxCount))
    Slider_Attribute01:GetComponent("UIProgressBar").value = countInfo.curScore / countInfo.maxScore
    Slider_Attribute02:GetComponent("UIProgressBar").value = countInfo.curCount / countInfo.maxCount
  else
    warn("not find group countInfo:", self.curGroupIndex)
  end
  self:FillDetailList(false)
end
def.method().UpdateGroupObjects = function(self)
  local groupGridTemplate = self.uiTbl.Table_List
  local groupTemplate = self.uiTbl.Tab_1
  local groupList = self.groupList
  local groupDVal = #groupList - self.lastGroupListNum
  if #groupList == 0 then
    groupGridTemplate:GetChild(0):SetActive(false)
  else
    groupGridTemplate:GetChild(0):SetActive(true)
  end
  if groupDVal > 0 then
    for i = 1, groupDVal do
      self.lastGroupListNum = self.lastGroupListNum + 1
      AchievementNode.AddLastGroup(self.lastGroupListNum, "Tab_%d", groupGridTemplate, groupTemplate)
    end
  elseif groupDVal < 0 then
    local num = math.abs(groupDVal)
    for i = 1, num do
      local group = groupGridTemplate:GetChild(self.lastGroupListNum - 1)
      self:DestroySmallGroup(#groupList[self.lastGroupListNum].subTypeIdList, group)
      AchievementNode.DeleteLastGroup(self.lastGroupListNum, "Tab_1", groupGridTemplate)
      self.lastGroupListNum = self.lastGroupListNum - 1
    end
  end
  if groupDVal > 0 then
    for i = 1, #groupList do
      local group = groupGridTemplate:GetChild(i - 1)
      self:UpdateSmallGroup(#groupList[i].subTypeIdList, group)
      i = i + 1
    end
  end
  local uiTable = groupGridTemplate:GetComponent("UITable")
  uiTable:Reposition()
  self.m_base:TouchGameObject(self.m_base.m_panel, self.m_base.m_parent)
end
def.method().GroupItemsUpdate = function(self)
  self:FillGroupList()
end
def.method("number", "userdata").DestroySmallGroup = function(self, subTypeListNum, group)
  local tween = group:FindDirect("tween")
  if subTypeListNum > 0 then
    local Btn_List1 = tween:FindDirect("Btn_List1")
    Object.Destroy(Btn_List1)
  end
  local uiGrid = tween:GetComponent("UITable")
  uiGrid.repositionNow = true
  self.m_base:TouchGameObject(self.m_base.m_panel, self.m_base.m_parent)
end
def.method("number", "userdata").UpdateSmallGroup = function(self, subTypeListNum, group)
  local tween = group:FindDirect("tween")
  local Btn_List1 = tween:FindDirect("Btn_List1")
  if subTypeListNum > 0 then
    Btn_List1:SetActive(true)
    for i = 1, subTypeListNum do
      AchievementNode.AddLastGroup(i, "Btn_List%d", tween, Btn_List1)
      i = i + 1
    end
  else
    Object.Destroy(Btn_List1)
  end
  local uiGrid = tween:GetComponent("UITable")
  uiGrid.repositionNow = true
  self.m_base:TouchGameObject(self.m_base.m_panel, self.m_base.m_parent)
end
def.method().UpdateCurGroupInfo = function(self)
  if self.curGroupIndex == 1 then
    self:UpdateTotalInfo()
  else
    self:UpdateSubGroupToggleState()
    self:UpdateDetailInfo()
  end
end
def.method().FillGroupList = function(self)
  local groupList = self.groupList
  local gridTemplate = self.uiTbl.Table_List
  local groupTemplate = self.uiTbl.Tab_1
  for i = 1, #groupList do
    local groupNew = gridTemplate:GetChild(i - 1)
    self:FillGroupInfo(groupList[i], i, groupNew)
  end
  self.lastGroupListNum = #groupList
end
def.method("table", "number", "userdata").FillGroupInfo = function(self, groupInfo, index, groupNew)
  local Btn_Class = groupNew:FindDirect("Btn_Class")
  Btn_Class:FindDirect("Label"):GetComponent("UILabel"):set_text(groupInfo.name or "...")
  local Img_Down = Btn_Class:FindDirect("Img_Down")
  local Img_Up = Btn_Class:FindDirect("Img_Up")
  Img_Down:SetActive(index > 1)
  Img_Up:SetActive(false)
  local tween = groupNew:FindDirect("tween")
  local Btn_List1 = tween:FindDirect("Btn_List1")
  local smalGroupList = groupInfo.subTypeIdList
  tween:SetActive(false)
  if #smalGroupList > 0 then
    Btn_List1:SetActive(true)
    for i = 1, #smalGroupList do
      local groupNew = tween:GetChild(i - 1)
      self:FillSmallGroupInfo(smalGroupList, i, groupNew, index)
    end
  end
end
def.method("table", "number", "userdata", "number").FillSmallGroupInfo = function(self, smalGroupList, index, groupNew, bigGroup)
  local Label = groupNew:FindDirect("Label")
  local SubTypeName = ""
  local subTypeCfg = AchievementData.Instance():GetAchievementSubTypeCfg(smalGroupList[index])
  if subTypeCfg then
    SubTypeName = subTypeCfg.name
  end
  Label:GetComponent("UILabel"):set_text(SubTypeName)
  groupNew:GetComponent("UIToggle"):set_isChecked(false)
end
def.method().UpdateGroupToggleState = function(self)
  if self.curGroupIndex > 0 then
    local tabItem = self.uiTbl.Table_List:FindDirect("Tab_" .. self.curGroupIndex)
    local Btn_Class = tabItem:FindDirect("Btn_Class")
    Btn_Class:GetComponent("UIToggle").value = true
  end
end
def.method().UpdateSubGroupToggleState = function(self)
  local tabItem = self.uiTbl.Table_List:FindDirect("Tab_" .. self.curGroupIndex)
  local tween = tabItem:FindDirect("tween")
  local subTabItem = tween:FindDirect("Btn_List" .. self.curSmallGroupIndex)
  if _G.IsNil(subTabItem) then
    warn("UpdateSubGroupToggleState not find subTabItem:", self.curSmallGroupIndex)
    return
  end
  subTabItem:GetComponent("UIToggle").value = true
  local uiScrollView = self.uiTbl.ScrollView:GetComponent("UIScrollView")
  GameUtil.AddGlobalTimer(0.01, true, function()
    if uiScrollView == nil or uiScrollView.isnil then
      return
    end
    uiScrollView:DragToMakeVisible(subTabItem.transform, 10)
  end)
end
def.method().FillTotalList = function(self)
  local totalListInfo = AchievementData.Instance():GetLastFinishAchievements()
  self.archievementFinishList = totalListInfo
  local itemCount = #totalListInfo
  local Group_TotalInfo_uiTbl = self.uiTbl.Group_TotalInfo_uiTbl
  local GridList = Group_TotalInfo_uiTbl.GridList
  local uiList = GridList:GetComponent("UIList")
  uiList.itemCount = itemCount
  uiList:Resize()
  uiList:Reposition()
  for i = 1, itemCount do
    local listItem = GridList:FindDirect("item_" .. i)
    self:FillTotalListInfo(i, listItem, totalListInfo[i])
  end
end
def.method("number", "userdata", "table").FillTotalListInfo = function(self, index, uiItem, displayInfo)
  local Label_TaskInfo = uiItem:FindDirect("Label_TaskInfo"):GetComponent("UILabel")
  local Label_Title = uiItem:FindDirect("Label_Title"):GetComponent("UILabel")
  local Label_Credit = uiItem:FindDirect("Label_Credit"):GetComponent("UILabel")
  local Img_BgIcon1 = uiItem:FindDirect("Img_BgIcon1")
  local BgIconTexture = Img_BgIcon1:FindDirect("Texture_Icon")
  local BgIconNumLabel = Img_BgIcon1:FindDirect("Label_Num"):GetComponent("UILabel")
  local Img_GetIt = uiItem:FindDirect("Img_GetIt")
  local Label_Time = uiItem:FindDirect("Label_Time"):GetComponent("UILabel")
  local Img_Prize = uiItem:FindDirect("Img_Prize")
  local id = displayInfo.id
  local goalCfg = AchievementData.GetAchievementGoalCfg(id)
  local goalInfo = AchievementData.Instance():GetAchievementInfo(id)
  Img_GetIt:SetActive(true)
  if goalCfg then
    local itemCount = 0
    local itemList = self:getAwardItemList(goalCfg.fixAwardId)
    if #itemList > 0 then
      itemCount = itemList[1].num
    end
    Label_TaskInfo:set_text(goalCfg.goalDes)
    Label_Title:set_text(goalCfg.title)
    Label_Credit:set_text(goalCfg.point)
    BgIconNumLabel:set_text(itemCount)
    GUIUtils.SetTexture(BgIconTexture, goalCfg.iconId)
    Img_Prize:SetActive(0 < goalCfg.fixAwardId)
  else
    Label_TaskInfo:set_text("")
    Label_Title:set_text("")
    Label_Credit:set_text("")
    BgIconNumLabel:set_text("")
    Img_Prize:SetActive(false)
  end
  if goalInfo then
    Label_Time:set_text(self:GetTimeString(goalInfo.achieve_time))
  else
    Label_Time:set_text("--/--/--")
  end
end
def.method().FillTotalCountList = function(self)
  local Group_TotalInfo_uiTbl = self.uiTbl.Group_TotalInfo_uiTbl
  local GridList = Group_TotalInfo_uiTbl.CountInfoGridList
  local uiList = GridList:GetComponent("UIList")
  local bigTypeList = {}
  local hidenBigTypeCfg
  local invisibleAchievementIndex = constant.AchievementConsts.invisibleAchievementIndex
  for idx, bigTypeCfg in ipairs(self.groupList) do
    local bigTypeIndex = bigTypeCfg.index
    if bigTypeIndex >= 0 and bigTypeIndex ~= invisibleAchievementIndex then
      table.insert(bigTypeList, bigTypeCfg)
    elseif bigTypeIndex == invisibleAchievementIndex then
      hidenBigTypeCfg = bigTypeCfg
    end
  end
  local itemCount = #bigTypeList
  uiList.itemCount = itemCount
  uiList:Resize()
  uiList:Reposition()
  local curScore = 0
  local maxScore = 0
  local curCount = 0
  local maxCount = 0
  for i = 1, itemCount do
    local listItem = GridList:FindDirect("item_" .. i)
    local bigTypeCfg = bigTypeList[i]
    local countInfo = AchievementData.Instance():GetAchievementCountInfo(bigTypeCfg.index)
    self:FillTotalCountListInfo(i, listItem, bigTypeCfg.name, countInfo)
    curScore = curScore + countInfo.curScore
    maxScore = maxScore + countInfo.maxScore
    curCount = curCount + countInfo.curCount
    maxCount = maxCount + countInfo.maxCount
  end
  if hidenBigTypeCfg then
    local hidenCountInfo = AchievementData.Instance():GetAchievementCountInfo(hidenBigTypeCfg.index)
    curScore = curScore + hidenCountInfo.curScore
    maxScore = maxScore + hidenCountInfo.curScore
    curCount = curCount + hidenCountInfo.curCount
    maxCount = maxCount + hidenCountInfo.curCount
  end
  local Img_InfoBg = Group_TotalInfo_uiTbl.Img_InfoBg
  local Group = Img_InfoBg:FindDirect("Item_Total/Group")
  local Slider_Attribute01 = Group:FindDirect("Slider_Attribute01")
  local Slider_Attribute02 = Group:FindDirect("Slider_Attribute02")
  local Slider_AttributeNum01 = Slider_Attribute01:FindDirect("Label_AttributeNumber")
  local Slider_AttributeNum02 = Slider_Attribute02:FindDirect("Label_AttributeNumber")
  Slider_AttributeNum01:GetComponent("UILabel"):set_text(string.format("%d/%d", curScore, maxScore))
  Slider_AttributeNum02:GetComponent("UILabel"):set_text(string.format("%d/%d", curCount, maxCount))
  Slider_Attribute01:GetComponent("UIProgressBar").value = curScore / maxScore
  Slider_Attribute02:GetComponent("UIProgressBar").value = curCount / maxCount
end
def.method("number", "userdata", "string", "table").FillTotalCountListInfo = function(self, index, uiItem, name, countInfo)
  local Group = uiItem:FindDirect("Group")
  local Label_AttributeName = Group:FindDirect("Label_AttributeName"):GetComponent("UILabel")
  local Slider_Attribute01 = Group:FindDirect("Slider_Attribute01")
  local Slider_Attribute02 = Group:FindDirect("Slider_Attribute02")
  local Slider_AttributeNum01 = Slider_Attribute01:FindDirect("Label_AttributeNumber")
  local Slider_AttributeNum02 = Slider_Attribute02:FindDirect("Label_AttributeNumber")
  Label_AttributeName:set_text(name)
  Slider_AttributeNum01:GetComponent("UILabel"):set_text(string.format("%d/%d", countInfo.curScore, countInfo.maxScore))
  Slider_AttributeNum02:GetComponent("UILabel"):set_text(string.format("%d/%d", countInfo.curCount, countInfo.maxCount))
  Slider_Attribute01:GetComponent("UIProgressBar").value = countInfo.curScore / countInfo.maxScore
  Slider_Attribute02:GetComponent("UIProgressBar").value = countInfo.curCount / countInfo.maxCount
end
def.method("boolean").SetTotalAwardButtonEffect = function(self, show)
  if show ~= self.getAwardButtonShowEffect then
    self.getAwardButtonShowEffect = show
    local Group_TotalInfo_uiTbl = self.uiTbl.Group_TotalInfo_uiTbl
    local Btn_Prize = Group_TotalInfo_uiTbl.Btn_Prize
    if self.getAwardButtonShowEffect then
      GUIUtils.SetLightEffect(Btn_Prize, GUIUtils.Light.Square)
    else
      GUIUtils.SetLightEffect(Btn_Prize, GUIUtils.Light.None)
    end
  end
end
def.method("boolean").FillDetailList = function(self, bResetScrollView)
  local Group_Detail_uiTbl = self.uiTbl.Group_Detail_uiTbl
  local achievementList
  local subTypeId = self.groupList[self.curGroupIndex].subTypeIdList[self.curSmallGroupIndex]
  if not _G.IsNil(subTypeId) then
    local subTypeCfg = AchievementData.Instance():GetAchievementSubTypeCfg(subTypeId)
    achievementList = self:GetDetailList(subTypeCfg.achievementList)
  end
  achievementList = achievementList or {}
  self.archievementDetailList = {}
  local scrollViewObj = Group_Detail_uiTbl.ScrollView
  local scrollListObj = Group_Detail_uiTbl.GridList
  local GUIScrollList = scrollListObj:GetComponent("GUIScrollList")
  if not GUIScrollList then
    scrollListObj:AddComponent("GUIScrollList")
  end
  local uiScrollList = scrollListObj:GetComponent("UIScrollList")
  ScrollList_setUpdateFunc(uiScrollList, function(item, i)
    self:FillDetailListInfo(i, item, achievementList[i])
  end)
  ScrollList_setCount(uiScrollList, #achievementList)
  if bResetScrollView then
    scrollViewObj:GetComponent("UIScrollView"):ResetPosition()
  end
end
def.method("number", "userdata", "table").FillDetailListInfo = function(self, index, uiItem, achievementCfg)
  local id = achievementCfg.id
  local goalInfo = AchievementData.Instance():GetAchievementInfo(id)
  local goalCfg = AchievementData.GetAchievementGoalCfg(id)
  local Label_TaskInfo = uiItem:FindDirect("Label_TaskInfo"):GetComponent("UILabel")
  local Label_Title = uiItem:FindDirect("Label_Title"):GetComponent("UILabel")
  local Label_Credit = uiItem:FindDirect("Label_Credit"):GetComponent("UILabel")
  local Img_BgIcon1 = uiItem:FindDirect("Img_BgIcon1")
  local BgIconTexture = Img_BgIcon1:FindDirect("Texture_Icon")
  local BgIconNumLabel = Img_BgIcon1:FindDirect("Label_Num"):GetComponent("UILabel")
  local Label_Progress = uiItem:FindDirect("Label_Progress")
  local Img_GetIt = uiItem:FindDirect("Img_GetIt")
  local Label_Time = uiItem:FindDirect("Label_Time")
  local Img_Prize = uiItem:FindDirect("Img_Prize")
  local iconId = goalCfg.iconId
  local finishStr
  if goalInfo then
    finishStr = AchievementFinishInfo.getFinishInfoStr(goalCfg, goalInfo.parameters)
  else
    finishStr = AchievementFinishInfo.getFinishInfoStr(goalCfg, {
      0,
      0,
      0,
      0,
      0
    })
  end
  local itemCount = 0
  local itemList = self:getAwardItemList(goalCfg.fixAwardId)
  if #itemList > 0 then
    itemCount = itemList[1].num
  end
  local parentIdx = tonumber(uiItem.parent.name)
  self.archievementDetailList[parentIdx] = id
  Img_Prize:SetActive(0 < goalCfg.fixAwardId)
  Label_TaskInfo:set_text(goalCfg.goalDes)
  Label_Title:set_text(goalCfg.title)
  Label_Credit:set_text(goalCfg.point)
  Label_Progress:GetComponent("UILabel"):set_text(finishStr)
  BgIconNumLabel:set_text(itemCount)
  GUIUtils.SetTexture(BgIconTexture, iconId)
  if goalInfo and (goalInfo.state == 2 or goalInfo.state == 3) then
    Label_Time:GetComponent("UILabel"):set_text(self:GetTimeString(goalInfo.achieve_time))
    Label_Time:SetActive(true)
    Img_GetIt:SetActive(true)
    Label_Progress:SetActive(false)
  else
    Label_Time:SetActive(false)
    Img_GetIt:SetActive(false)
    Label_Progress:SetActive(true)
  end
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if "Btn_Class" == id and clickobj.parent and string.find(clickobj.parent.name, "Tab_") then
    self:OnGroupClick(clickobj)
  elseif string.find(id, "Btn_List") and clickobj.parent and string.find(clickobj.parent.name, "tween") then
    if clickobj:GetComponent("UIToggle"):get_isChecked() then
      local smallIndex = tonumber(string.sub(clickobj.name, string.len("Btn_List") + 1))
      local bigIndex = tonumber(string.sub(clickobj.parent.parent.name, string.len("Tab_") + 1))
      self:OnSmallGroupClick(smallIndex, bigIndex)
    else
      clickobj:GetComponent("UIToggle"):set_isChecked(true)
    end
  elseif "Btn_Share" == id and clickobj.parent and string.find(clickobj.parent.name, "item_") then
    local index = tonumber(string.sub(clickobj.parent.name, string.len("item_") + 1))
    self:OnTotalInfoShareClick(index, clickobj)
  elseif "Btn_Share" == id and clickobj.parent and clickobj.parent.name == "Img_ListBg" then
    local index = tonumber(clickobj.parent.parent.name)
    self:OnDetailInfoShareClick(index, clickobj)
  elseif "Img_Prize" == id and clickobj.parent and string.find(clickobj.parent.name, "item_") then
    local index = tonumber(string.sub(clickobj.parent.name, string.len("item_") + 1))
    self:OnTotalInfoPrizeClick(index, clickobj)
  elseif "Img_Prize" == id and clickobj.parent and clickobj.parent.name == "Img_ListBg" then
    local index = tonumber(clickobj.parent.parent.name)
    self:OnDetailInfoPrizeClick(index, clickobj)
  elseif "Btn_Prize" == id then
    self:OnBtnPrizeClick()
  elseif "Btn_Class" == id and clickobj.parent and clickobj.parent.name == "Group_Detail" then
    self:OnBtnDetailClassClick()
  elseif "Btn_All" == id and clickobj.parent and clickobj.parent.name == "Table_TeamBtn" then
    self:OnBtnTeamAllClick()
  elseif "Btn_Have" == id and clickobj.parent and clickobj.parent.name == "Table_TeamBtn" then
    self:OnBtnTeamHaveClick()
  elseif "Btn_No" == id and clickobj.parent and clickobj.parent.name == "Table_TeamBtn" then
    self:OnBtnTeamNoClick()
  else
    warn("AchievementNode.onclickobj:", clickobj.name, "|", clickobj.parent.name)
  end
end
def.override("string").onClick = function(self, id)
end
def.method("userdata").OnGroupClick = function(self, obj)
  local uiTbl = self.uiTbl
  local index = tonumber(string.sub(obj.parent.name, string.len("Tab_") + 1))
  local parentObj = obj.transform.parent.gameObject
  local tween = parentObj:FindDirect("tween")
  if tween.activeSelf then
    if index ~= 1 then
      self:UnSelectGroup(index)
    end
  else
    self:SelectGroup(index)
  end
end
def.method("number").SelectGroup = function(self, index)
  self.lastGroupIndex = self.curGroupIndex
  self.curGroupIndex = index
  if self.curGroupIndex ~= self.lastGroupIndex then
    self:CloseGroup(self.lastGroupIndex)
  end
  self:OpenGroup(self.curGroupIndex)
  if index == 1 then
    self:UpdateTotalInfo()
  else
    self.curSmallGroupIndex = 1
    self:UpdateSubGroupToggleState()
    self:UpdateDetailInfo()
  end
end
def.method("number").UnSelectGroup = function(self, index)
  self.lastGroupIndex = self.curGroupIndex
  self:CloseGroup(index)
end
def.method("number").OpenGroup = function(self, index)
  self.lastGroupIndex = self.curGroupIndex
  local tabItem = self.uiTbl.Table_List:FindDirect("Tab_" .. index)
  local Img_Down = tabItem:FindDirect("Btn_Class/Img_Down")
  local Img_Up = tabItem:FindDirect("Btn_Class/Img_Up")
  Img_Down:SetActive(false)
  Img_Up:SetActive(index > 1)
  tabItem:FindDirect("tween"):SetActive(true)
  self:RepositionTabs()
end
def.method("number").CloseGroup = function(self, index)
  if index <= 0 then
    return
  end
  local tabItem = self.uiTbl.Table_List:FindDirect("Tab_" .. index)
  local Img_Down = tabItem:FindDirect("Btn_Class/Img_Down")
  local Img_Up = tabItem:FindDirect("Btn_Class/Img_Up")
  Img_Down:SetActive(index > 1)
  Img_Up:SetActive(false)
  tabItem:FindDirect("tween"):SetActive(false)
  self:RepositionTabs()
end
def.method().RepositionTabs = function(self)
  GameUtil.AddGlobalLateTimer(0, true, function()
    if _G.IsNil(self.m_node) then
      return
    end
    local uiTable = self.uiTbl.Table_List:GetComponent("UITable")
    uiTable:Reposition()
  end)
end
def.method("number", "number").OnSmallGroupClick = function(self, smallIndex, bigIndex)
  if self.curGroupIndex ~= bigIndex then
    warn("OnSmallGroupClick, group index error !!!", bigIndex, "|", self.curGroupIndex)
  end
  self.curSmallGroupIndex = smallIndex
  self:UpdateDetailInfo()
end
def.method("number", "userdata").OnTotalInfoPrizeClick = function(self, index, obj)
  if self.archievementFinishList then
    local totalListInfo = self.archievementFinishList
    local achievementInfo = totalListInfo[index]
    if achievementInfo then
      local id = achievementInfo.id
      self:OnPrizeClick(id, obj)
    end
  end
end
def.method("number", "userdata").OnDetailInfoPrizeClick = function(self, index, obj)
  if self.archievementDetailList then
    local id = self.archievementDetailList[index]
    if id then
      self:OnPrizeClick(id, obj)
    end
  end
end
def.method("number", "userdata").OnPrizeClick = function(self, achievementId, btn)
  local goalCfg = AchievementData.GetAchievementGoalCfg(achievementId)
  if goalCfg then
    local itemList = self:getAwardItemList(goalCfg.fixAwardId)
    if #itemList > 0 then
      local itemId = itemList[1].itemId
      ItemTipsMgr.Instance():ShowBasicTipsWithGO(itemId, btn, 0, false)
    end
  end
end
def.method("number", "userdata").OnTotalInfoShareClick = function(self, index, obj)
  if self.archievementFinishList then
    local totalListInfo = self.archievementFinishList
    local achievementInfo = totalListInfo[index]
    if achievementInfo then
      local id = achievementInfo.id
      self:OnShareClick(id, obj)
    end
  end
end
def.method("number", "userdata").OnDetailInfoShareClick = function(self, index, obj)
  if self.archievementDetailList then
    local id = self.archievementDetailList[index]
    if id then
      self:OnShareClick(id, obj)
    end
  end
end
def.method("number", "userdata").OnShareClick = function(self, achievementId, btn)
  local goalCfg = AchievementData.GetAchievementGoalCfg(achievementId)
  local goalInfo = AchievementData.Instance():GetAchievementInfo(achievementId)
  local position = btn:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = btn:GetComponent("UISprite")
  local pos = {
    auto = true,
    sourceX = screenPos.x,
    sourceY = screenPos.y,
    sourceW = sprite:get_width(),
    sourceH = sprite:get_height(),
    prefer = -1
  }
  local btnList = {}
  local sdktype = ClientCfg.GetSDKType()
  if sdktype == ClientCfg.SDKTYPE.MSDK then
    if _G.LoginPlatform == MSDK_LOGIN_PLATFORM.WX then
      table.insert(btnList, {
        name = textRes.Grow.Achievement[12],
        tag = 5
      })
    elseif _G.LoginPlatform == MSDK_LOGIN_PLATFORM.QQ then
      table.insert(btnList, {
        name = textRes.Grow.Achievement[11],
        tag = 5
      })
    end
  end
  table.insert(btnList, {
    name = textRes.Chat[25],
    tag = 4
  })
  table.insert(btnList, {
    name = textRes.Chat.ChannelName[5],
    tag = 3
  })
  local hasGang = require("Main.Gang.GangModule").Instance():HasGang()
  if hasGang then
    table.insert(btnList, {
      name = textRes.Chat.ChannelName[2],
      tag = 2
    })
  end
  local hasTeam = require("Main.Team.TeamData").Instance():HasTeam()
  if hasTeam then
    table.insert(btnList, {
      name = textRes.Chat.ChannelName[3],
      tag = 1
    })
  end
  require("GUI.ButtonGroupPanel").ShowPanel(btnList, pos, function(index)
    local btn = btnList[index]
    if btn then
      local tag = btn.tag
      if tag == 1 then
        local name, cipher = self:MakeInfoPack(goalCfg, goalInfo)
        self:WriteToChannel(ChatMsgData.Channel.TEAM, name, cipher)
        self:SendTLog(goalCfg, goalInfo)
      elseif tag == 2 then
        local name, cipher = self:MakeInfoPack(goalCfg, goalInfo)
        self:WriteToChannel(ChatMsgData.Channel.FACTION, name, cipher)
        self:SendTLog(goalCfg, goalInfo)
      elseif tag == 3 then
        local name, cipher = self:MakeInfoPack(goalCfg, goalInfo)
        self:WriteToChannel(ChatMsgData.Channel.WORLD, name, cipher)
        self:SendTLog(goalCfg, goalInfo)
      elseif tag == 4 then
        do
          local FriendData = require("Main.friend.FriendData")
          local friendList = FriendData.Instance():GetFriendList()
          local friendNameList = {}
          for k, v in ipairs(friendList) do
            table.insert(friendNameList, {
              name = v.roleName,
              tag = v.roleId
            })
          end
          if #friendNameList > 0 then
            require("GUI.ScrollButtonGroupPanel").ShowPanel(friendNameList, pos, function(index, tag)
              local info = FriendData.Instance():GetFriendInfo(tag)
              if info then
                do
                  local SocialDlg = require("Main.friend.ui.SocialDlg")
                  SocialDlg.ShowSocialDlgWithCallback(SocialDlg.NodeId.Friend, function(panel)
                    if panel then
                      SocialDlg.ShowPrivateChat(info.roleId, info.roleName, true)
                      local name, cipher = self:MakeInfoPack(goalCfg, goalInfo)
                      panel.inputViewCtrl:AddInfoPack(name, cipher)
                      self:SendTLog(goalCfg, goalInfo)
                    end
                  end)
                end
              end
            end)
          else
            Toast(textRes.Grow[83])
          end
        end
      elseif tag == 5 then
        self:ShareArchievement(achievementId)
      end
    end
  end)
end
def.method("number", "string", "string").WriteToChannel = function(self, channel, name, cipher)
  require("Main.Chat.ui.ChannelChatPanel").ShowChannelChatPanelWithCallback(ChatMsgData.MsgType.CHANNEL, channel, function(panel)
    if panel and panel.inputViewCtrl then
      panel.inputViewCtrl:AddInfoPack(name, cipher)
    end
  end)
end
def.method("table", "table").SendTLog = function(self, cfg, info)
  local params = {}
  table.insert(params, cfg.id)
  table.insert(params, info.state)
  table.insert(params, (info.achieve_time / 1000):ToNumber())
  table.insert(params, table.concat(info.parameters, "-"))
  require("ProxySDK.ECMSDK").SendTLogToServer(_G.TLOGTYPE.SHAREACHIEVEMENT, params)
end
def.method("table", "table", "=>", "string", "string").MakeInfoPack = function(self, cfg, info)
  local roleName = require("Main.Hero.Interface").GetBasicHeroProp().name
  local name = cfg.title
  local id = cfg.id
  local state = info.state
  local time = (info.achieve_time / 1000):ToNumber()
  local params = info.parameters
  local infoStr = string.format("[%s]", name)
  local infoPack = string.format("{achieve:%s,%s,%d,%d,%s,%s}", name, roleName, id, state, tostring(time), table.concat(params, "|"))
  return infoStr, infoPack
end
def.method().OnBtnPrizeClick = function(self)
  require("Main.Grow.ui.AchievementPrizePanel").Instance():ShowPanel()
end
def.method().OnBtnDetailClassClick = function(self)
  local Group_Detail_uiTbl = self.uiTbl.Group_Detail_uiTbl
  local Table_TeamBtn = Group_Detail_uiTbl.Table_TeamBtn
  local Img_Up = Group_Detail_uiTbl.Img_Up
  local Img_Down = Group_Detail_uiTbl.Img_Down
  local isActive = Table_TeamBtn:get_activeInHierarchy()
  if isActive then
    Table_TeamBtn:SetActive(false)
    Img_Up:SetActive(true)
    Img_Down:SetActive(false)
  else
    Table_TeamBtn:SetActive(true)
    Img_Up:SetActive(false)
    Img_Down:SetActive(true)
  end
end
def.method().OnBtnTeamAllClick = function(self)
  self:UpdateSelectType(SELECT_TYPE.ALL)
end
def.method().OnBtnTeamHaveClick = function(self)
  self:UpdateSelectType(SELECT_TYPE.FINISH)
end
def.method().OnBtnTeamNoClick = function(self)
  self:UpdateSelectType(SELECT_TYPE.NOTFINISH)
end
def.method("number").UpdateSelectType = function(self, selectType)
  self.selectType = selectType
  local Group_Detail_uiTbl = self.uiTbl.Group_Detail_uiTbl
  local Table_TeamBtn = Group_Detail_uiTbl.Table_TeamBtn
  local Btn_ClassLabel = Group_Detail_uiTbl.Btn_ClassLabel
  Table_TeamBtn:SetActive(false)
  Btn_ClassLabel:GetComponent("UILabel"):set_text(SELECT_BTNNANME[self.selectType] or "")
  self:FillDetailList(false)
end
def.static("number", "string", "userdata", "userdata").AddLastGroup = function(listNum, groupName, gridTemplate, groupTemplate)
  if 1 == listNum then
    groupTemplate:SetActive(true)
    return
  end
  local groupNew = Object.Instantiate(groupTemplate)
  AchievementNode.CreateNewGroup(groupNew, gridTemplate, listNum, groupName)
  groupNew:SetActive(true)
end
def.static("userdata", "userdata", "number", "string").CreateNewGroup = function(groupNew, gridTemplate, count, name)
  groupNew:set_name(string.format(name, count))
  groupNew.parent = gridTemplate
  groupNew:set_localScale(Vector.Vector3.one)
  groupNew:SetActive(true)
end
def.static("number", "string", "userdata").DeleteLastGroup = function(listNum, groupName, gridTemplate)
  if 1 == listNum then
    gridTemplate:FindDirect(groupName):SetActive(false)
  elseif listNum > 1 then
    local template = gridTemplate:GetChild(listNum - 1)
    Object.Destroy(template)
  end
end
def.static("table", "table").OnArchievementInfoUpdate = function(p1, p2)
  local activityId = p1[1]
  if instance and activityId == constant.AchievementConsts.activityId then
    instance:UpdateCurGroupInfo()
  end
end
def.static("table", "table").OnArchievementScoreAwardChange = function(p1, p2)
  if instance then
    instance:UpdateTotalAwardButtonState()
  end
end
def.method("number", "=>", "table").getAwardItemList = function(self, awardId)
  local awardCfg = ItemUtils.GetGiftAwardCfgByAwardId(awardId)
  if awardCfg then
    return awardCfg.itemList
  end
  return {}
end
def.method("number").ShareArchievement = function(self, archievementId)
  local goalCfg = AchievementData.GetAchievementGoalCfg(archievementId)
  local goalInfo = AchievementData.Instance():GetAchievementInfo(archievementId)
  local title = string.format(textRes.Grow.Achievement[10], goalCfg.title)
  local heroName = require("Main.Hero.Interface").GetHeroProp().name
  if goalInfo then
    if goalInfo.state == 2 or goalInfo.state == 3 then
      local timeStr = self:GetTimeString(goalInfo.achieve_time)
      local desc = string.format(textRes.Grow.Achievement[7], goalCfg.goalDes, heroName, timeStr)
      self:SDKShareInfo(title, desc)
    else
      local finishStr = AchievementFinishInfo.getFinishInfoStr(goalCfg, goalInfo.parameters)
      local desc = string.format(textRes.Grow.Achievement[8], goalCfg.goalDes, heroName, finishStr)
      self:SDKShareInfo(title, desc)
    end
  else
    local desc = string.format(textRes.Grow.Achievement[8], goalCfg.goalDes, heroName, "--/--")
    self:SDKShareInfo(title, desc)
  end
end
def.method("string", "string").SDKShareInfo = function(self, title, content)
  local sdktype = ClientCfg.GetSDKType()
  if sdktype == ClientCfg.SDKTYPE.MSDK then
    if _G.LoginPlatform == MSDK_LOGIN_PLATFORM.WX and not ECMSDK.IsPlatformInstalled(_G.MSDK_LOGIN_PLATFORM.WX) then
      Toast(textRes.Common[311])
      return
    elseif _G.LoginPlatform == MSDK_LOGIN_PLATFORM.QQ and not ECMSDK.IsPlatformInstalled(_G.MSDK_LOGIN_PLATFORM.QQ) then
      Toast(textRes.Common[310])
      return
    elseif _G.LoginPlatform == MSDK_LOGIN_PLATFORM.GUEST then
      Toast(textRes.Common[313])
      return
    end
    local zone = MSDK_SHARE_SCENE.SINGEL
    ECMSDK.SendToFriend(zone, title, content)
  else
    local ECUniSDK = require("ProxySDK.ECUniSDK")
    if ECUniSDK.Instance():SDKIS(ECUniSDK.CHANNELTYPE.LOONG) then
      ECUniSDK.Instance():Share({title = title, desc = content})
    end
  end
end
def.method("table", "=>", "table").GetDetailList = function(self, achievementList)
  local retList = {}
  local selectType = self.selectType
  local bigTypeCfg = self.groupList[self.curGroupIndex]
  if bigTypeCfg and bigTypeCfg.index == constant.AchievementConsts.invisibleAchievementIndex then
    selectType = SELECT_TYPE.FINISH
  end
  if selectType == SELECT_TYPE.ALL then
    for i, achievementCfg in ipairs(achievementList) do
      if achievementCfg.nextId > 0 then
        table.insert(retList, achievementCfg)
        local id = achievementCfg.id
        local goalInfo = AchievementData.Instance():GetAchievementInfo(id)
        while true do
          if achievementCfg.nextId > 0 and goalInfo and (goalInfo.state == 2 or goalInfo.state == 3) then
            id = achievementCfg.nextId
            achievementCfg = AchievementData.Instance():GetAchievementCfg(id)
            goalInfo = AchievementData.Instance():GetAchievementInfo(id)
          else
            if achievementCfg == nil then
          end
          else
            table.insert(retList, achievementCfg)
            do break end
            else
              table.insert(retList, achievementCfg)
            end
          end
        end
    end
  elseif selectType == SELECT_TYPE.FINISH then
    for i, achievementCfg in ipairs(achievementList) do
      local id = achievementCfg.id
      local goalInfo = AchievementData.Instance():GetAchievementInfo(id)
      if achievementCfg.nextId > 0 then
        while achievementCfg.nextId > 0 and goalInfo and (goalInfo.state == 2 or goalInfo.state == 3) do
          table.insert(retList, achievementCfg)
          id = achievementCfg.nextId
          achievementCfg = AchievementData.Instance():GetAchievementCfg(id)
          goalInfo = AchievementData.Instance():GetAchievementInfo(id)
        end
      elseif goalInfo and (goalInfo.state == 2 or goalInfo.state == 3) then
        table.insert(retList, achievementCfg)
      end
    end
  elseif selectType == SELECT_TYPE.NOTFINISH then
    for i, achievementCfg in ipairs(achievementList) do
      local id = achievementCfg.id
      local goalInfo = AchievementData.Instance():GetAchievementInfo(id)
      if achievementCfg.nextId > 0 then
        while achievementCfg.nextId > 0 and goalInfo and (goalInfo.state == 2 or goalInfo.state == 3) do
          id = achievementCfg.nextId
          achievementCfg = AchievementData.Instance():GetAchievementCfg(id)
          goalInfo = AchievementData.Instance():GetAchievementInfo(id)
        end
        if achievementCfg and (goalInfo == nil or goalInfo.state == 1) then
          table.insert(retList, achievementCfg)
        end
      elseif goalInfo == nil or goalInfo.state == 1 then
        table.insert(retList, achievementCfg)
      end
    end
  else
    return achievementList
  end
  return retList
end
def.method("userdata", "=>", "string").GetTimeString = function(self, time)
  local timeSecond = time:ToNumber() / 1000
  if timeSecond <= 0 then
    return "--/--/--"
  end
  return os.date("%y/%m/%d", timeSecond)
end
def.static("=>", "boolean").IsAchievementFeatureOpen = function()
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local isOpen = _G.IsFeatureOpen(Feature.TYPE_ACHIEVEMENT)
  return isOpen
end
AchievementNode.Commit()
return AchievementNode
