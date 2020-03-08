local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GrowGuideNodeBase = import(".GrowGuideNodeBase")
local GrowAchievementNode = Lplus.Extend(GrowGuideNodeBase, CUR_CLASS_NAME)
local ItemUtils = require("Main.Item.ItemUtils")
local EasyBasicItemTip = require("Main.Common.EasyBasicItemTip")
local GUIUtils = require("GUI.GUIUtils")
local def = GrowAchievementNode.define
local GrowAchievementMgr = import("..GrowAchievementMgr")
local GrowAchievementVDMgr = import("..viewdata.GrowAchievementVDMgr")
def.const("number").AWARD_CELL_NUM = 2
def.field("table").uiObjs = nil
def.field("table").easyitemtip = nil
def.field("number").activeTab = 1
def.field("table").tabvdList = nil
def.field("table").achievementvdList = nil
def.field("boolean").isShowing = false
local instance
def.static("=>", GrowAchievementNode).Instance = function()
  if instance == nil then
    instance = GrowAchievementNode()
  end
  return instance
end
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  GrowGuideNodeBase.Init(self, base, node)
end
def.override("=>", "boolean").IsUnlock = function(self)
  return true
end
def.override("=>", "boolean").HaveNotifyMessage = function(self)
  return GrowAchievementMgr.Instance():HasAwardToDraw()
end
def.override().OnShow = function(self)
  if self.isShowing then
    self:UpdateTabListState()
    return
  end
  self.isShowing = true
  self:InitUI()
  self:UpdateUI()
  Event.RegisterEvent(ModuleId.GROW, gmodule.notifyId.Grow.UPDATE_GROW_ACHIEVEMENT, GrowAchievementNode.OnGrowAchievementUpdate)
end
def.override().OnHide = function(self)
  self.isShowing = false
  Event.UnregisterEvent(ModuleId.GROW, gmodule.notifyId.Grow.UPDATE_GROW_ACHIEVEMENT, GrowAchievementNode.OnGrowAchievementUpdate)
  self:Release()
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.ScrollView = self.m_node:FindDirect("Scroll View")
  self.uiObjs.List = self.uiObjs.ScrollView:FindDirect("List")
  self.uiObjs.uiList = self.uiObjs.List:GetComponent("UIList")
  self.uiObjs.Img_BgTab = self.m_node:FindDirect("Img_BgTab")
  self.uiObjs.ScrollView_Tab = self.uiObjs.Img_BgTab:FindDirect("Scroll View_Tab")
  self.uiObjs.List_Tab = self.uiObjs.ScrollView_Tab:FindDirect("List_Tab")
  self.uiObjs.uiList_Tab = self.uiObjs.List_Tab:GetComponent("UIList")
  self.easyitemtip = EasyBasicItemTip()
end
def.override("userdata").onClickObj = function(self, obj)
  local id = obj.name
  do break end
  do break end
  self:onClick(id)
end
def.override("string").onClick = function(self, id)
  if string.find(id, "Btn_CZGo_") then
    local index = tonumber(string.sub(id, #"Btn_CZGo_" + 1, -1))
    self:GoInForAchievement(index)
  elseif string.find(id, "Btn_CZGet_") then
    local index = tonumber(string.sub(id, #"Btn_CZGet_" + 1, -1))
    self:ReqAchievementAward(index)
  end
end
def.override("string", "boolean").onToggle = function(self, id, isActive)
  if isActive and tonumber(string.sub(id, #"item_" + 1, -1)) then
    local index = tonumber(string.sub(id, #"item_" + 1, -1))
    self:ShowList(index)
  end
end
def.method().UpdateUI = function(self)
  self.tabvdList = GrowAchievementVDMgr.Instance():GetTabListViewData()
  self:SetTabList(self.tabvdList)
  self.m_base:TouchGameObject(self.m_base.m_panel, self.m_base.m_parent)
end
def.method("table").SetTabList = function(self, list)
  if list == nil then
    return
  end
  self.uiObjs.uiList_Tab.itemCount = #list
  self.uiObjs.uiList_Tab:Resize()
  local listItems = self.uiObjs.uiList_Tab.children
  local activeTab = 0
  for i, v in ipairs(list) do
    local hasNotify = self:SetTabListItem(i, listItems[i], v)
    if activeTab == 0 and hasNotify then
      activeTab = i
    end
  end
  self.activeTab = activeTab
  if self.activeTab == 0 then
    self.activeTab = self:CalcActiveTab()
  end
  local tab = listItems[self.activeTab]
  if tab == nil then
    GUIUtils.SetActive(self.uiObjs.ScrollView, false)
  else
    local uiToggle = tab:GetComponent("UIToggle")
    if uiToggle.value == true then
      self:ShowList(self.activeTab)
    else
      GUIUtils.Toggle(tab, true)
    end
  end
end
def.method("number", "userdata", "table", "=>", "boolean").SetTabListItem = function(self, index, listItem, viewData)
  local name = viewData.name or "NIL"
  local Label_Tab = listItem:FindDirect("Label_Tab")
  GUIUtils.SetText(Label_Tab, name)
  local Img_Red = listItem:FindDirect("Img_Red")
  if GrowAchievementVDMgr.Instance():HasCanDrawAchievementAward(viewData.levelRange) then
    GUIUtils.SetActive(Img_Red, true)
    return true
  else
    GUIUtils.SetActive(Img_Red, false)
    return false
  end
end
def.method().UpdateTabListState = function(self)
  local list = self.tabvdList
  if list == nil or self.uiObjs == nil then
    return
  end
  if self.uiObjs.uiList_Tab.itemCount ~= #list then
    return
  end
  local listItems = self.uiObjs.uiList_Tab.children
  for i, v in ipairs(list) do
    self:SetTabListItem(i, listItems[i], v)
  end
end
def.method("number").ShowList = function(self, index)
  local tabviewdata = self.tabvdList[index]
  if tabviewdata == nil then
    return
  end
  self.achievementvdList = GrowAchievementVDMgr.Instance():GetListViewData(tabviewdata.levelRange)
  self:SetList(self.achievementvdList)
end
def.method("table").SetList = function(self, list)
  if list == nil then
    return
  end
  self.uiObjs.ScrollView:GetComponent("UIScrollView"):ResetPosition()
  self.uiObjs.uiList.itemCount = #list
  self.uiObjs.uiList:Resize()
  for i, v in ipairs(list) do
    self:SetListItem(i, v)
  end
  self.m_base:TouchGameObject(self.m_base.m_panel, self.m_base.m_parent)
end
def.method("number", "table").SetListItem = function(self, index, viewData)
  if index == 0 then
    return
  end
  local icon, name, desc = viewData.icon, viewData.name, viewData.desc
  local listItem = self.uiObjs.List:FindDirect("Group_CZ_" .. index)
  local Texture_Item = listItem:FindDirect(string.format("Group_Prize_%d/Img_Bg1_%d/Texture_Item1_%d", index, index, index))
  GUIUtils.SetTexture(Texture_Item, icon)
  local Label_Name = listItem:FindDirect("Label_Name_" .. index)
  GUIUtils.SetText(Label_Name, name)
  local Label_Name = listItem:FindDirect("Label_Describe_" .. index)
  GUIUtils.SetText(Label_Name, desc)
  local Group_Btn = listItem:FindDirect("Group_Btn_" .. index)
  local Img_Bg1 = listItem:FindDirect("Img_Bg1_" .. index)
  local Img_Bg2 = listItem:FindDirect("Img_Bg2_" .. index)
  local Btn_Go = Group_Btn:FindDirect("Btn_CZGo_" .. index)
  local Btn_Get = Group_Btn:FindDirect("Btn_CZGet_" .. index)
  local Img_Finish = Group_Btn:FindDirect("Img_Finish_" .. index)
  Img_Bg2:SetActive(false)
  Img_Finish:SetActive(false)
  Btn_Go:SetActive(false)
  Btn_Get:SetActive(false)
  local StateEnum = self.achievementvdList.StateEnum
  if viewData.state == StateEnum.ST_HAND_UP then
    Img_Bg2:SetActive(true)
    Img_Finish:SetActive(true)
    GUIUtils.SetLightEffect(Btn_Get, GUIUtils.Light.None)
  elseif viewData.state == StateEnum.ST_FINISHED then
    Btn_Get:SetActive(true)
    GUIUtils.SetLightEffect(Btn_Get, GUIUtils.Light.Square)
  else
    Btn_Go:SetActive(true)
  end
end
def.method("userdata", "number", "table", "number").SetAwardItem = function(self, cellRoot, index, itemBase, num)
  local cellObj = cellRoot:FindDirect("Img_Bg" .. index)
  if itemBase == nil then
    cellObj:SetActive(false)
    return
  end
  cellObj:SetActive(true)
  local iconId = itemBase.icon
  local Texture_Item = cellObj:FindDirect("Texture_Item" .. index)
  GUIUtils.SetTexture(Texture_Item, iconId)
  local id = cellRoot.transform.parent.gameObject.name .. "_" .. cellObj.name
  self.easyitemtip:RegisterItem2ShowTipEx(itemBase.itemid, id, cellObj)
end
def.method("table", "=>", "number").FindViewDataPos = function(self, viewdata)
  if self.achievementvdList == nil then
    return 0
  end
  local pos = 0
  for i, v in ipairs(self.achievementvdList) do
    if viewdata.id == v.id then
      pos = i
      break
    end
  end
  return pos
end
def.method("number").ReqAchievementAward = function(self, index)
  local achievementvd = self.achievementvdList[index]
  GrowAchievementMgr.Instance():ReqAchievementAward(achievementvd.id)
end
def.method("number").GoInForAchievement = function(self, index)
  local achievementvd = self.achievementvdList[index]
  local success = GrowAchievementMgr.Instance():GoInForAchievement(achievementvd.id)
  if success then
    self.m_base:DestroyPanel()
  end
end
def.static("table", "table").OnGrowAchievementUpdate = function(params, context)
  local id = unpack(params)
  local viewdata = GrowAchievementVDMgr.Instance():GetGrowAchievementViewData(id)
  local index = instance:FindViewDataPos(viewdata)
  instance:SetListItem(index, viewdata)
  instance:UpdateTabListState()
end
def.method("=>", "number").CalcActiveTab = function(self)
  local index = 1
  if self.tabvdList == nil then
    return index
  end
  for i, v in ipairs(self.tabvdList) do
    index = i
    if v.levelRange.isHeroIn then
      break
    end
  end
  return index
end
def.method().Release = function(self)
  self.uiObjs = nil
  self.tabvdList = nil
  self.achievementvdList = nil
  self.easyitemtip = nil
  self.activeTab = 1
end
return GrowAchievementNode.Commit()
