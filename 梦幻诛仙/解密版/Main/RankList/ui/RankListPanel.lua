local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local RankListPanel = Lplus.Extend(ECPanelBase, "RankListPanel")
local def = RankListPanel.define
local MathHelper = require("Common.MathHelper")
local Vector = require("Types.Vector")
local ECGUIMan = require("GUI.ECGUIMan")
local RankListModule = require("Main.RankList.RankListModule")
local RankListUtils = require("Main.RankList.RankListUtils")
local SelfRankMgr = require("Main.RankList.SelfRankMgr")
local ECUIModel = require("Model.ECUIModel")
local Top3Mgr = require("Main.RankList.Top3Mgr")
local RankUnitInfoMgr = require("Main.RankList.RankUnitInfoMgr")
local ChartType = require("consts.mzm.gsp.chart.confbean.ChartType")
local RankListViewBase = require("Main.RankList.ui.RankListViewBase")
local GUIUtils = require("GUI.GUIUtils")
def.const("table").DisplayInfoEnum = {Detail = 1, Top3 = 2}
def.const("number").TOP_N = 3
def.const("string").UP_ARROW_NAME = "Img_ArrowG"
def.const("string").DOWN_ARROW_NAME = "Img_ArrowR"
def.const("string").NEW_ICON_NAME = "Img_NewIn"
def.const("table").Top3IconName = {
  "Img_Num1",
  "Img_Num2",
  "Img_Num3"
}
def.field("table").rankListClasses = nil
def.field("table").rankListData = nil
def.field("number").lastRankClassIndex = 0
def.field("number").rankClassIndex = 1
def.field("number").selectedRankListIndex = 1
def.field("number").displayInfo = 1
def.field("table").models = nil
def.field("string").dragObjId = ""
def.field("table").uiObjs = nil
def.field(RankListViewBase).curView = nil
def.field("boolean").bWaitToUpdate = false
def.field("boolean").bNeedRepositionRankList = false
local LIST_ITEM_PER_PAGE = 10
def.const("number").LIST_ITEM_PER_PAGE = LIST_ITEM_PER_PAGE
def.field("number").reqFrom = 1
def.field("number").reqTo = LIST_ITEM_PER_PAGE
local instance
def.static("=>", RankListPanel).Instance = function()
  if instance == nil then
    instance = RankListPanel()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self.models = {}
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  self.m_TrigGC = true
end
def.method().ShowPanel = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  if self:IsShow() then
    self:DestroyPanel()
  end
  self:InitCfgData()
  if self.rankClassIndex == 0 then
    self.rankClassIndex = 1
    self.selectedRankListIndex = 1
  elseif self.rankListClasses[self.rankClassIndex] == nil then
    self.rankClassIndex = 1
    self.selectedRankListIndex = 1
  elseif self.rankListClasses[self.rankClassIndex][self.selectedRankListIndex] == nil then
    self.selectedRankListIndex = 1
  end
  self:RequestData(nil)
  self:CreatePanel(RESPATH.PREFAB_RANK_LIST_PANEL_RES, 1)
  self:SetModal(true)
end
def.method("number").ShowChartView = function(self, chartType)
  if _G.CheckCrossServerAndToast() then
    return
  end
  self:LocateChartPos(chartType)
  self:ShowPanel()
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateUI()
  self:OpenTab(self.rankClassIndex)
  Event.RegisterEvent(ModuleId.RANK_LIST, gmodule.notifyId.RankList.RECEIVED_TOP_3_DATA, RankListPanel.OnRecievedTop3Data)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.RANK_LIST, gmodule.notifyId.RankList.RECEIVED_TOP_3_DATA, RankListPanel.OnRecievedTop3Data)
  self:Clear()
  RankListModule.Instance():ReleaseAllRankList()
end
def.override("boolean").OnShow = function(self, s)
  if not s then
    return
  end
  if self.uiObjs then
    local uiTable = self.uiObjs.Table_List:GetComponent("UITable")
    uiTable:Reposition()
    if self.uiObjs.ListRight.activeInHierarchy then
      local uiList = self.uiObjs.ListRight:GetComponent("UIList")
      uiList:Reposition()
    end
  end
  self:ResumeModels()
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Class" then
    self:OnTabButtonObjClicked(obj)
  else
    self:onClick(id)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Modal" then
    self:DestroyPanel()
  elseif string.sub(id, 1, #"SubTab_") == "SubTab_" then
    local index = tonumber(string.sub(id, #"SubTab_" + 1, -1))
    self:OnSubTabButtonClicked(index)
  elseif id == "Btn_Change" then
    self:OnSwitchDisplayInfoButtonClicked()
  elseif string.sub(id, 1, #"item_") == "item_" then
    local index = tonumber(string.sub(id, #"item_" + 1, -1))
    self:OnRankItemClicked(index)
  elseif id == "Btn_Tips" then
    self:OnTipsButtonClicked()
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.PANELNAME, {
      self.m_panelName
    })
  elseif string.sub(id, 1, #"Model") == "Model" then
    local index = tonumber(string.sub(id, #"Model" + 1, -1))
    self:OnModelClicked(index)
  end
end
def.method().InitCfgData = function(self)
  if self.rankListClasses == nil then
    local classCfgs = RankListModule.Instance():GetOpenedRankListClasses()
    self.rankListClasses = classCfgs
  end
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.Img_BgBottom = self.uiObjs.Img_Bg0:FindDirect("Img_BgBottom")
  self.uiObjs.Img_BgLeft = self.uiObjs.Img_Bg0:FindDirect("Img_BgLeft")
  self.uiObjs.TabScrollView = self.uiObjs.Img_BgLeft:FindDirect("Scroll View")
  self.uiObjs.Table_List = self.uiObjs.TabScrollView:FindDirect("Table_List")
  local template = self.uiObjs.Table_List:FindDirect("Tab_1")
  template:SetActive(false)
  template.name = "Tab_0"
  local Btn_Class = template:FindDirect("Btn_Class")
  Btn_Class:GetComponent("UIToggle").startsActive = false
  self.uiObjs.TableTemplate = template
  local subTabRoot = template:FindDirect("tween")
  subTabRoot:SetActive(false)
  local subTab = subTabRoot:FindDirect("Btn_PaiHangBang")
  subTab:SetActive(false)
  subTab.name = "SubTab_0"
  self.uiObjs.Group_Detail = {}
  self.uiObjs.Group_Detail.views = {}
  self.uiObjs.Group_Detail.views[4] = self.uiObjs.Img_Bg0:FindDirect("Group_Detail")
  self.uiObjs.Group_Three = self.uiObjs.Img_Bg0:FindDirect("Group_Three")
  self.uiObjs.Group_NoData = self.uiObjs.Img_Bg0:FindDirect("Group_NoData")
  self.uiObjs.Group_Detail.views[5] = self.uiObjs.Img_Bg0:FindDirect("Group_FightCrossServer")
  self.uiObjs.Group_Detail.views[3] = self.uiObjs.Img_Bg0:FindDirect("Group_TeamPVP")
  self:SetListObjs(4)
end
def.method("number").SetListObjs = function(self, colCount)
  self.uiObjs.Group_Detail.count = colCount
  local ScrollView = self.uiObjs.Group_Detail.views[colCount]:FindDirect("Group_List/Scroll View")
  self.uiObjs.listScrollView = ScrollView:GetComponent("UIScrollView")
  self.uiObjs.ListRight = ScrollView:FindDirect("List_Left")
  local uiPanel = ScrollView:GetComponent("UIPanel")
  local finalClipRegion = uiPanel:get_finalClipRegion()
  local uiList = self.uiObjs.ListRight:GetComponent("UIList")
  local padding = uiList:get_padding()
  self.uiObjs.rlist_clip_size_y = finalClipRegion.w
  self.uiObjs.rlist_padding_size_y = padding.y
end
def.method().UpdateUI = function(self)
  self:SetRankListClassList(self.rankListClasses)
end
def.method("table").SetRankListClassList = function(self, rankListClasses)
  local tabCount = #rankListClasses
  self:ResizeRankListClassList(tabCount)
  for i, rankListClass in ipairs(rankListClasses) do
    self:SetRankListClassInfo(i, rankListClass)
  end
  local uiTable = self.uiObjs.Table_List:GetComponent("UITable")
  uiTable:Reposition()
end
def.method("number").ResizeRankListClassList = function(self, count)
  local uiTable = self.uiObjs.Table_List:GetComponent("UITable")
  local tabTrans = uiTable.children
  local childCount = uiTable.gameObject.childCount
  for i = 1, childCount - 1 do
    local child = uiTable.gameObject:GetChild(i)
    child:SetActive(true)
  end
  local tableItemCount = childCount - 1
  if count > tableItemCount then
    for i = tableItemCount + 1, count do
      local tabItem = GameObject.Instantiate(self.uiObjs.TableTemplate)
      tabItem.name = "Tab_" .. i
      tabItem.transform.parent = self.uiObjs.Table_List.transform
      tabItem.transform.localScale = Vector.Vector3.one
      tabItem:SetActive(true)
    end
  elseif count < tableItemCount then
    for i = tabItemCount, count + 1, -1 do
      local tabItem = self.uiObjs.Table_List:FindDirect("Tab_" .. i)
      tabItem.transform.parent = nil
      GameObject.Destroy(tabItem)
    end
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
  uiTable:Reposition()
end
def.method("number", "table").SetRankListClassInfo = function(self, index, rankListClass)
  local tabItem = self.uiObjs.Table_List:FindDirect("Tab_" .. index)
  tabItem:FindDirect("Btn_Class/Label"):GetComponent("UILabel").text = rankListClass.name
end
def.method("userdata").OnTabButtonObjClicked = function(self, obj)
  local parentObj = obj.transform.parent.gameObject
  local index = tonumber(string.sub(parentObj.name, #"Tab_" + 1, -1))
  local tween = parentObj:FindDirect("tween")
  if tween.activeSelf then
    self:UnSelectTab(index)
  else
    self:SelectTab(index)
  end
end
def.method("number").SelectTab = function(self, index)
  if self.lastRankClassIndex ~= index then
    self.selectedRankListIndex = 1
  end
  self.lastRankClassIndex = self.rankClassIndex
  self.rankClassIndex = index
  self.displayInfo = RankListPanel.DisplayInfoEnum.Detail
  if self.rankClassIndex ~= self.lastRankClassIndex then
    self:CloseTab(self.lastRankClassIndex)
  end
  self:OpenTab(self.rankClassIndex)
end
def.method("number").UnSelectTab = function(self, index)
  self.lastRankClassIndex = self.rankClassIndex
  self:CloseTab(index)
end
def.method("number").OpenTab = function(self, index)
  self.lastRankClassIndex = self.rankClassIndex
  local tabItem = self.uiObjs.Table_List:FindDirect("Tab_" .. index)
  tabItem:FindDirect("tween"):SetActive(true)
  local rankLists = self.rankListClasses[index]
  self:SetRankLists(index, rankLists)
  self:UpdateTabToggleState()
  self:UpdateSelectedRankList()
  self:RepositionTabs()
end
def.method().ResetRankListView = function(self)
  self.bNeedRepositionRankList = true
  self.reqFrom = 1
  self.reqTo = RankListPanel.LIST_ITEM_PER_PAGE
end
def.method().UpdateTabToggleState = function(self)
  local classIndex = self.rankClassIndex
  local tabItem = self.uiObjs.Table_List:FindDirect("Tab_" .. classIndex)
  local Btn_Class = tabItem:FindDirect("Btn_Class")
  Btn_Class:GetComponent("UIToggle").value = true
end
def.method("number", "table").SetRankLists = function(self, classIndex, rankLists)
  local tabItem = self.uiObjs.Table_List:FindDirect("Tab_" .. classIndex)
  local tween = tabItem:FindDirect("tween")
  local tabCount = #rankLists
  self:ResizeRankListTable(tween, tabCount)
  for i, rankList in ipairs(rankLists) do
    self:SetRankListInfo(tween, i, rankList)
  end
end
def.method("userdata", "number").ResizeRankListTable = function(self, tabObj, count)
  local uiTable = tabObj:GetComponent("UITable")
  local tabTrans = uiTable.children
  local tableItemCount = #tabTrans
  if count > tableItemCount then
    for i = tableItemCount + 1, count do
      local template = tabObj:FindDirect("SubTab_0")
      local tabItem = GameObject.Instantiate(template)
      tabItem.name = "SubTab_" .. i
      tabItem.transform.parent = tabObj.transform
      tabItem.transform.localScale = Vector.Vector3.one
      tabItem:SetActive(true)
    end
  elseif count < tableItemCount then
    for i = tabItemCount, count + 1, -1 do
      local tabItem = tabObj:FindDirect("SubTab_" .. i)
      tabItem.transform.parent = nil
      GameObject.Destroy(tabItem)
    end
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
  uiTable:Reposition()
end
def.method("userdata", "number", "table").SetRankListInfo = function(self, tabObj, index, rankList)
  local tabItem = tabObj:FindDirect("SubTab_" .. index)
  tabItem:FindDirect("Label"):GetComponent("UILabel").text = rankList.name
end
def.method("number").CloseTab = function(self, index)
  if index == 0 then
    return
  end
  local tabItem = self.uiObjs.Table_List:FindDirect("Tab_" .. index)
  tabItem:FindDirect("tween"):SetActive(false)
  self:RepositionTabs()
end
def.method().RepositionTabs = function(self)
  GameUtil.AddGlobalLateTimer(0, true, function()
    if self.m_panel == nil then
      return
    end
    self.uiObjs.Table_List:GetComponent("UITable"):Reposition()
  end)
end
def.method().UpdateSelectedRankList = function(self)
  self:ResetRankListView()
  self:UpdateSubTabToggleState()
  self:ShowNoDataInfo()
  self:UpdateSwitchButtonText()
  self:RequestData(RankListPanel.OnRecievedData)
  self:UpdateSelfData()
  self:UpdateExtraInfo()
end
def.method().UpdateSubTabToggleState = function(self)
  local classIndex = self.rankClassIndex
  local index = self.selectedRankListIndex
  local tabItem = self.uiObjs.Table_List:FindDirect("Tab_" .. classIndex)
  local tween = tabItem:FindDirect("tween")
  local subTabItem = tween:FindDirect("SubTab_" .. index)
  subTabItem:GetComponent("UIToggle").value = true
  local uiScrollView = self.uiObjs.TabScrollView:GetComponent("UIScrollView")
  GameUtil.AddGlobalTimer(0, true, function()
    GameUtil.AddGlobalTimer(0, true, function()
      if uiScrollView == nil or uiScrollView.isnil then
        return
      end
      uiScrollView:DragToMakeVisible(subTabItem.transform, 10)
    end)
  end)
end
def.method().UpdateSelfData = function(self)
  local rankList = self.rankListClasses[self.rankClassIndex][self.selectedRankListIndex]
  self.m_panel:FindDirect("Img_Bg0/Label_Arena"):SetActive(false)
  if self.rankListData:IsShowMyRank() then
    self.m_panel:FindDirect("Img_Bg0/Img_BgBottom"):SetActive(true)
    local value = tostring(self.rankListData:GetSelfValue())
    self:SetSelfData(rankList.type, value)
    self.m_panel:FindDirect("Img_Bg0/Img_BgBottom/Btn_Change"):SetActive(self.rankListData:IsShowTop3())
  else
    self.m_panel:FindDirect("Img_Bg0/Img_BgBottom"):SetActive(false)
  end
end
def.method("number", "string").SetSelfData = function(self, type, value)
  local Group_Message = self.uiObjs.Img_BgBottom:FindDirect("Group_Message")
  local LabelName = Group_Message:FindDirect("Label_1"):GetComponent("UILabel")
  local typeName = textRes.RankList.MyRankDataTypeName[type] or ""
  LabelName.text = string.format(textRes.RankList[2], typeName)
  local Label_Content1 = Group_Message:FindDirect("Label_Content1"):GetComponent("UILabel")
  Label_Content1.text = value
end
def.method("function").ReqSelfRankInfo = function(self, callback)
  self.rankListData:ReqSelfRankInfo(callback)
end
def.method("function").RequestData = function(self, callback)
  self:RequestDataEx(self.reqFrom, self.reqTo, callback)
end
def.method("number", "number", "function").RequestDataEx = function(self, from, to, callback)
  print("req/", from, "~", to)
  self.reqFrom = from
  self.reqTo = to
  local rankList = self.rankListClasses[self.rankClassIndex][self.selectedRankListIndex]
  if rankList == nil then
    rankList = self.rankListClasses[1][1]
  end
  self.rankListData = RankListModule.Instance():GetRankListData(rankList.type)
  self:ReqSelfRankInfo(nil)
  self.rankListData:ReqRankList(from, to, callback)
end
def.static("table").OnRecievedData = function(rankListData)
  local self = instance
  self.bWaitToUpdate = false
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  local rankList = self.rankListClasses[self.rankClassIndex][self.selectedRankListIndex]
  if rankListData.type ~= rankList.type then
    return
  end
  self:UpdateSelfRankInfo()
  if #rankListData.list == 0 then
    return
  end
  self.rankListData = rankListData
  self:SetListObjs(self.rankListData.colCount)
  self:UpdateRankList()
  self:UpdateExtraInfo()
end
def.method().UpdateRankList = function(self)
  self:ShowDetailInfo()
  local itemAmount = #self.rankListData.list
  if itemAmount > self.reqTo then
    itemAmount = self.reqTo
  end
  local uiList = self.uiObjs.ListRight:GetComponent("UIList")
  uiList.itemCount = itemAmount
  uiList:Resize()
  uiList:Reposition()
  local uiScrollView = self.uiObjs.listScrollView
  if self.bNeedRepositionRankList then
    uiScrollView:ResetPosition()
    self.bNeedRepositionRankList = false
  end
  local from, to = self.reqFrom, itemAmount
  local displayInfoList = self.rankListData:GetViewData(from, to)
  self:SetListItemTitleInfo(displayInfoList.title)
  for i = 1, to - from + 1 do
    local displayInfo = displayInfoList[i]
    local index = i + from - 1
    self:SetListItemInfo(index, displayInfo)
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method().UpdateSelfRankInfo = function(self)
  if self.rankListData:IsShowMyRank() then
    self.uiObjs.Img_BgBottom:SetActive(true)
    local rank = self.rankListData:GetSelfRank()
    self:SetSelfRank(rank)
    local value = tostring(self.rankListData:GetSelfValue())
    self:SetSelfData(self.rankListData.type, value)
  else
    self.uiObjs.Img_BgBottom:SetActive(false)
  end
end
def.method().UpdateExtraInfo = function(self)
  local extraInfo = self.rankListData:GetExtraInfo()
  self:SetExtraInfo(extraInfo)
end
def.method("number", "table").SetListItemInfo = function(self, index, displayInfo)
  local function colourText(str)
    local color = textRes.RankList.RankColor[index]
    local text = tostring(str)
    if color then
      text = string.format("[%s]%s[-]", color, text)
    end
    return text
  end
  local rank, p2, p3, p4, stepInfo, p5 = unpack(displayInfo)
  local listItem = self.uiObjs.ListRight:FindDirect("item_" .. index)
  listItem:FindDirect("Label_1"):GetComponent("UILabel").text = colourText(rank)
  listItem:FindDirect("Label_2"):GetComponent("UILabel").text = colourText(p2)
  listItem:FindDirect("Label_3"):GetComponent("UILabel").text = colourText(p3)
  if p4 then
    listItem:FindDirect("Label_4"):GetComponent("UILabel").text = colourText(p4)
  end
  if p5 then
    local p5ui = listItem:FindDirect("Label_5")
    SafeCall(p5.handler, p5ui, p5.context)
  end
  if index % 2 == 0 then
    GUIUtils.SetActive(listItem:FindDirect("Img_Bg1"), false)
    GUIUtils.SetActive(listItem:FindDirect("Img_Bg2"), true)
  else
    GUIUtils.SetActive(listItem:FindDirect("Img_Bg2"), false)
    GUIUtils.SetActive(listItem:FindDirect("Img_Bg1"), true)
  end
  local Img_MingCiChange = listItem:FindDirect("Img_MingCiChange")
  local LabelObj = Img_MingCiChange:FindDirect("Label")
  LabelObj:GetComponent("UILabel").text = ""
  local uiSprite = Img_MingCiChange:GetComponent("UISprite")
  uiSprite.spriteName = "nil"
  local Img_NewIn = listItem:FindDirect("Img_NewIn")
  local uiSprite_Img_NewIn = Img_NewIn:GetComponent("UISprite")
  uiSprite_Img_NewIn.spriteName = "nil"
  local Img_MingCi = listItem:FindDirect("Img_MingCi")
  if rank <= 3 then
    local uiSprite = Img_MingCi:GetComponent("UISprite")
    uiSprite.spriteName = RankListPanel.Top3IconName[rank]
    listItem:FindDirect("Label_1"):SetActive(false)
  else
    local uiSprite = Img_MingCi:GetComponent("UISprite")
    uiSprite.spriteName = "nil"
    if stepInfo.isNew then
      uiSprite_Img_NewIn.spriteName = RankListPanel.NEW_ICON_NAME
    else
      local step = stepInfo.step
      local spriteName = "nil"
      local stepText = ""
      if step > 0 then
        spriteName = RankListPanel.UP_ARROW_NAME
        stepText = step
      elseif step < 0 then
        spriteName = RankListPanel.DOWN_ARROW_NAME
        stepText = math.abs(step)
      end
      local uiSprite = Img_MingCiChange:GetComponent("UISprite")
      uiSprite.spriteName = spriteName
      LabelObj:GetComponent("UILabel").text = stepText
    end
    listItem:FindDirect("Label_1"):SetActive(true)
  end
end
def.method("table").SetListItemTitleInfo = function(self, titleInfo)
  if titleInfo == nil then
    return
  end
  local Group = self.uiObjs.Group_Detail.views[self.uiObjs.Group_Detail.count]:FindDirect("Group_Title/Img_BgTitle/Group")
  for i = 1, #titleInfo do
    Group:FindDirect("Label" .. i):GetComponent("UILabel").text = titleInfo[i]
  end
end
def.method("number").OnSubTabButtonClicked = function(self, index)
  self:SelectRankList(index)
end
def.method("number").SelectRankList = function(self, index)
  self.selectedRankListIndex = index
  self.displayInfo = RankListPanel.DisplayInfoEnum.Detail
  self:UpdateSelectedRankList()
  local ECMSDK = require("ProxySDK.ECMSDK")
  ECMSDK.SendTLogToServer(_G.TLOGTYPE.RANKPAGE, {
    self.rankClassIndex,
    index
  })
end
def.method().ShowNoDataInfo = function(self)
  for k, v in pairs(self.uiObjs.Group_Detail.views) do
    v:SetActive(false)
  end
  self.uiObjs.Group_Three:SetActive(false)
  self.uiObjs.Group_NoData:SetActive(true)
  self:SetSelfRank(SelfRankMgr.OUT_OF_RANK_LIST)
end
def.method().ShowDetailInfo = function(self)
  for k, v in pairs(self.uiObjs.Group_Detail.views) do
    v:SetActive(k == self.uiObjs.Group_Detail.count)
  end
  self.uiObjs.Group_Three:SetActive(false)
  self.uiObjs.Group_NoData:SetActive(false)
end
def.method("number").SetSelfRank = function(self, rank)
  local text = tostring(rank)
  if rank <= SelfRankMgr.OUT_OF_RANK_LIST then
    text = textRes.RankList[1]
  end
  local label = self.uiObjs.Img_BgBottom:FindDirect("Group_Message/Label_Content2"):GetComponent("UILabel")
  label.text = text
end
def.method("table").SetExtraInfo = function(self, extraInfo)
  local label_extra_title = self.uiObjs.Img_BgBottom:FindDirect("Group_Message/Label_4")
  local label_extra_content = self.uiObjs.Img_BgBottom:FindDirect("Group_Message/Label_Content4")
  if extraInfo == nil then
    label_extra_title:SetActive(false)
    label_extra_content:SetActive(false)
  else
    label_extra_title:GetComponent("UILabel"):set_text(extraInfo.title)
    label_extra_content:GetComponent("UILabel"):set_text(extraInfo.content)
    label_extra_title:SetActive(true)
    label_extra_content:SetActive(true)
  end
end
def.method().OnSwitchDisplayInfoButtonClicked = function(self)
  if self.rankListData == nil or self.rankListData.list == nil or #self.rankListData.list == 0 then
    Toast(textRes.RankList[11])
    return
  end
  if self.displayInfo == RankListPanel.DisplayInfoEnum.Detail then
    self.displayInfo = RankListPanel.DisplayInfoEnum.Top3
    self:UpdateTop3Info()
  else
    self.displayInfo = RankListPanel.DisplayInfoEnum.Detail
    self:ShowDetailInfo()
  end
  self:UpdateSwitchButtonText()
end
def.method().UpdateTop3Info = function(self)
  if self.rankListData.top3Data == nil then
    self.rankListData:ReqTopNUnitInfo(RankListPanel.TOP_N)
    return
  end
  self:ShowTop3Info()
end
def.method().ShowTop3Info = function(self)
  for k, v in pairs(self.uiObjs.Group_Detail.views) do
    v:SetActive(false)
  end
  self.uiObjs.Group_Three:SetActive(true)
  self.uiObjs.Group_NoData:SetActive(false)
  local modelCount = RankListPanel.TOP_N
  for i = modelCount, 1, -1 do
    local modelObj = self.uiObjs.Group_Three:FindDirect("Model" .. i)
    GUIUtils.SetActive(modelObj, false)
  end
  local top3Data = self.rankListData.top3Data
  if top3Data.type == Top3Mgr.Top3Type.Model then
    self:ShowTop3ModelInfo()
  else
    warn("unrecongonized top3 data type = ", top3Data.type, debug.traceback())
  end
end
def.method().HideTop3Info = function(self)
  self.uiObjs.Group_Three:SetActive(false)
end
def.method().UpdateSwitchButtonText = function(self)
  if self.displayInfo == RankListPanel.DisplayInfoEnum.Top3 then
    self:SetSwitchButtonText(textRes.RankList[4])
  else
    self:SetSwitchButtonText(textRes.RankList[3])
  end
end
def.method("string").SetSwitchButtonText = function(self, text)
  local label = self.uiObjs.Img_BgBottom:FindDirect("Btn_Change/Label"):GetComponent("UILabel")
  label.text = text
end
def.method().ShowTop3ModelInfo = function(self)
  local displayInfoList = self.rankListData:GetViewData(1, RankListPanel.TOP_N)
  local top3Data = self.rankListData.top3Data
  local displayDatas = {}
  for i = 1, RankListPanel.TOP_N do
    local displayInfo = displayInfoList[i]
    if displayInfo == nil then
      break
    end
    local titleAndValue = displayInfoList.title[self.rankListData.top3Index]
    titleAndValue = string.format(textRes.RankList[2], titleAndValue) .. tostring(displayInfo[self.rankListData.top3Index])
    local displayData = {
      titleAndValue = titleAndValue,
      name = tostring(displayInfo[2]),
      modelInfo = top3Data.list[i]
    }
    table.insert(displayDatas, displayData)
  end
  for i = RankListPanel.TOP_N, 1, -1 do
    self:SetModel(i, displayDatas[i])
  end
end
def.method("number", "table").SetModel = function(self, i, displayData)
  if displayData == nil then
    self:ShowEmptyModel(i)
    return
  end
  local modelObj = self.uiObjs.Group_Three:FindDirect("Model" .. i)
  modelObj:SetActive(true)
  local uiModel = modelObj:GetComponent("UIModel")
  local modelId = displayData.modelInfo.modelid
  local modelPath = _G.GetModelPath(modelId)
  if self.models[i] ~= nil then
    self.models[i]:Destroy()
    self.models[i] = nil
  end
  self.models[i] = ECUIModel.new(modelId)
  _G.LoadModel(self.models[i], displayData.modelInfo, 0, 0, 180, false, false)
  self.models[i]:AddOnLoadCallback("RankListPanel_" .. i, function(ret)
    if self.m_panel == nil then
      return
    end
    local m = self.models[i].m_model
    if m == nil then
      return
    end
    uiModel.modelGameObject = m
    if uiModel.mCanOverflow ~= nil then
      uiModel.mCanOverflow = true
      local camera = uiModel:get_modelCamera()
      camera:set_orthographic(true)
      camera.depth = camera.depth
    end
    local model = self.models[i]
    model:CrossFade(ActionName.Idle1, 0.1)
    model:CrossFadeQueued(ActionName.Stand, 0.25)
  end)
  modelObj:FindDirect("Label1"):GetComponent("UILabel").text = displayData.titleAndValue
  modelObj:FindDirect("Label2"):GetComponent("UILabel").text = displayData.name
end
def.method("number").ShowEmptyModel = function(self, i)
  if self.models[i] ~= nil then
    self.models[i]:Destroy()
    self.models[i] = nil
  end
  local modelObj = self.uiObjs.Group_Three:FindDirect("Model" .. i)
  modelObj:FindDirect("Label1"):GetComponent("UILabel").text = textRes.RankList[5]
  modelObj:FindDirect("Label2"):GetComponent("UILabel").text = textRes.RankList[5]
end
def.method().ResumeModels = function(self)
  if self.models == nil then
    return
  end
  for i, model in ipairs(self.models) do
    model:Play(ActionName.Stand)
  end
end
def.method("string").onDragStart = function(self, id)
  self.dragObjId = id
end
def.method("string").onDragEnd = function(self, id)
  self.dragObjId = ""
  if string.find(id, "item_") then
    self:DragScrollView()
  end
end
def.method().DragScrollView = function(self)
  if self.uiObjs.rlist_template_size_y == nil or self.uiObjs.rlist_template_size_y < 1.0E-5 then
    local uiList = self.uiObjs.ListRight:GetComponent("UIList")
    local template = uiList:get_template()
    local trans = template.transform
    template:SetActive(true)
    local bounds = NGUIMath.CalculateRelativeWidgetBounds2t1b(trans, trans, false)
    template:SetActive(false)
    self.uiObjs.rlist_template_size_y = bounds.size.y
  end
  local dragAmount = self.uiObjs.listScrollView:GetDragAmount()
  local trans = self.uiObjs.ListRight.transform
  local bounds = NGUIMath.CalculateRelativeWidgetBounds2t1b(trans, trans, false)
  local bounds_size_y = bounds.size.y
  local M = bounds_size_y - self.uiObjs.rlist_clip_size_y
  local dy = M * dragAmount.y
  local page_height = self.uiObjs.rlist_template_size_y * LIST_ITEM_PER_PAGE + self.uiObjs.rlist_padding_size_y * (LIST_ITEM_PER_PAGE - 1)
  if dragAmount.y > 1 and self.bWaitToUpdate == false then
    self.bWaitToUpdate = true
    local startIdx = (MathHelper.Round(bounds_size_y / page_height) - 1) * LIST_ITEM_PER_PAGE + 1
    local endIdx = startIdx + 2 * LIST_ITEM_PER_PAGE - 1
    startIdx = math.max(1, startIdx)
    self:RequireRankList(startIdx, endIdx)
  else
    local base = page_height - self.uiObjs.rlist_clip_size_y
    local startIdx, endIdx
    if dy > base then
      startIdx = MathHelper.Floor((dy - base) / page_height) * LIST_ITEM_PER_PAGE + 1
      endIdx = startIdx + 2 * LIST_ITEM_PER_PAGE - 1
      startIdx = math.max(1, startIdx)
    elseif dy < 0 then
      startIdx = 1
      endIdx = LIST_ITEM_PER_PAGE
    end
    if startIdx and startIdx ~= self.reqFrom and endIdx ~= self.reqTo then
      self:RequireRankList(startIdx, endIdx)
    end
  end
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  if string.sub(id, 1, #"Model") ~= "Model" then
    return
  end
  local index = tonumber(string.sub(id, #"Model" + 1, -1))
  if self.models[index] then
    self.models[index]:SetDir(self.models[index].m_ang - dx / 2)
  end
end
def.method("number").OnRankItemClicked = function(self, index)
  self.rankListData:ShowUnitInfo(index)
end
def.method().OnTipsButtonClicked = function(self)
  local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
  local rankList = self.rankListClasses[self.rankClassIndex][self.selectedRankListIndex]
  local tipId = rankList.tipId
  local TipsHelper = require("Main.Common.TipsHelper")
  local tip = TipsHelper.GetHoverTip(tipId)
  local text = tip
  local tmpPosition = {x = 0, y = 0}
  local CommonDescDlg = require("GUI.CommonUITipsDlg")
  CommonDescDlg.ShowCommonTip(text, tmpPosition)
end
def.method("table", "=>", "string").GetFormatTimeStr = function(self, timeCfg)
  if timeCfg == nil then
    return "[no value]"
  end
  local str = ""
  if timeCfg.activeWeekDay == 0 then
    str = str .. textRes.activity[21]
  else
    str = str .. textRes.activity[29] .. textRes.activity[29 - timeCfg.activeWeekDay]
  end
  str = str.format("%s%02d:%02d", str, timeCfg.activeHour, timeCfg.activeMinute)
  return str
end
def.method("number").OnModelClicked = function(self, index)
  local rankData = self.rankListData.list[index]
  if rankData == nil then
    return
  end
  self.rankListData:ShowUnitInfo(index)
end
def.method().Clear = function(self)
  self.uiObjs = nil
  self.rankClassIndex = self.lastRankClassIndex
  self.lastRankClassIndex = 0
  self.displayInfo = RankListPanel.DisplayInfoEnum.Detail
  if self.models then
    for i, model in ipairs(self.models) do
      model:Destroy()
    end
  end
  self.models = {}
  self.bWaitToUpdate = false
  self.reqFrom = 1
  self.reqTo = RankListPanel.LIST_ITEM_PER_PAGE
  self.rankListClasses = nil
end
def.method().Reset = function(self)
  self.rankClassIndex = 1
  self.selectedRankListIndex = 1
end
def.method("number").LocateChartPos = function(self, chartType)
  self.rankListClasses = RankListModule.Instance():GetOpenedRankListClasses()
  if self.rankListClasses == nil then
    return
  end
  for i, rankClass in ipairs(self.rankListClasses) do
    for j, ranklist in ipairs(rankClass) do
      if ranklist.type == chartType then
        self.rankClassIndex = i
        self.selectedRankListIndex = j
      end
    end
  end
end
def.method("number", "number").RequireRankList = function(self, from, to)
  self:RequestDataEx(from, to, RankListPanel.OnRecievedData)
end
def.static("table", "table").OnRecievedTop3Data = function(params, context)
  local chartType = params[1]
  local self = instance
  if self.rankListData == nil or self.rankListData.type ~= chartType then
    return
  end
  local top3Data = self.rankListData.top3Data
  if top3Data == nil or top3Data.list == nil or #top3Data.list == 0 then
    return
  end
  self:ShowTop3Info()
end
return RankListPanel.Commit()
