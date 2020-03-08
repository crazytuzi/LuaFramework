local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GrowGuideNodeBase = import(".GrowGuideNodeBase")
local DailyGoalNode = Lplus.Extend(GrowGuideNodeBase, CUR_CLASS_NAME)
local ItemUtils = require("Main.Item.ItemUtils")
local DailyGoalMgr = import("..DailyGoalMgr")
local DailyGoalVDMgr = import("..viewdata.DailyGoalVDMgr")
local EasyBasicItemTip = require("Main.Common.EasyBasicItemTip")
local GUIUtils = require("GUI.GUIUtils")
local ItemModule = require("Main.Item.ItemModule")
local def = DailyGoalNode.define
def.const("number").AWARD_CELL_NUM = 2
def.field("table").uiObjs = nil
def.field("table").goalsList = nil
def.field("table").easyitemtip = nil
local instance
def.static("=>", DailyGoalNode).Instance = function()
  if instance == nil then
    instance = DailyGoalNode()
  end
  return instance
end
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  GrowGuideNodeBase.Init(self, base, node)
end
def.override("=>", "boolean").IsUnlock = function(self)
  return DailyGoalMgr.Instance():IsUnlock()
end
def.override("=>", "boolean").HaveNotifyMessage = function(self)
  return DailyGoalMgr.Instance():HasAwardToDraw()
end
def.override().OnShow = function(self)
  self:InitUI()
  self:UpdateUI()
  Event.RegisterEvent(ModuleId.GROW, gmodule.notifyId.Grow.SYNC_DAILY_GOALS, DailyGoalNode.OnSyncDailyGoals)
  Event.RegisterEvent(ModuleId.GROW, gmodule.notifyId.Grow.UPDATE_DAILY_GOAL, DailyGoalNode.OnDailyGoalUpdate)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_GoldChanged, DailyGoalNode.OnMoneyGoldUpdate)
  Event.RegisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, DailyGoalNode.OnNewDay)
  Event.RegisterEvent(ModuleId.GROW, gmodule.notifyId.Grow.DAILY_GOALS_NOTIFY_UPDATE, DailyGoalNode.OnNotifyUpdate)
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.GROW, gmodule.notifyId.Grow.SYNC_DAILY_GOALS, DailyGoalNode.OnSyncDailyGoals)
  Event.UnregisterEvent(ModuleId.GROW, gmodule.notifyId.Grow.UPDATE_DAILY_GOAL, DailyGoalNode.OnDailyGoalUpdate)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_GoldChanged, DailyGoalNode.OnMoneyGoldUpdate)
  Event.UnregisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, DailyGoalNode.OnNewDay)
  Event.UnregisterEvent(ModuleId.GROW, gmodule.notifyId.Grow.DAILY_GOALS_NOTIFY_UPDATE, DailyGoalNode.OnNotifyUpdate)
  self:Release()
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.ScrollView = self.m_node:FindDirect("Scroll View")
  self.uiObjs.List = self.uiObjs.ScrollView:FindDirect("List")
  self.uiObjs.uiList = self.uiObjs.List:GetComponent("UIList")
  self.uiObjs.uiList.renameControl = false
  self.uiObjs.uiList.itemCount = 0
  self.uiObjs.Group_Refresh = self.m_node:FindDirect("Group_Refresh")
  self.uiObjs.Label_NeedNum = self.uiObjs.Group_Refresh:FindDirect("Label_Need/Img_BgNeed/Label_NeedNum")
  self.uiObjs.Label_HaveNum = self.uiObjs.Group_Refresh:FindDirect("Label_Have/Img_BgHave/Label_HaveNum")
  self.easyitemtip = EasyBasicItemTip()
end
def.method("userdata", "=>", "boolean").onClickObjEx = function(self, obj)
  local id = obj.name
  if obj.transform.parent.gameObject.name == "Group_Prize" then
    local concatid = obj.transform.parent.parent.gameObject.name .. "_" .. obj.name
    self.easyitemtip:CheckItem2ShowTip(concatid, 0, false)
  elseif id == "Btn_Go" then
    local listItem = obj.transform.parent.parent.gameObject
    local index = tonumber(string.sub(listItem.name, #"item_" + 1, -1))
    self:GoToGoal(index)
  elseif id == "Btn_Get" then
    local listItem = obj.transform.parent.parent.gameObject
    local index = tonumber(string.sub(listItem.name, #"item_" + 1, -1))
    self:ReqGoalAward(index)
  elseif id == "Btn_AddGold" then
    _G.GoToBuyGold()
  elseif id == "Btn_Refresh" then
    self:OnRefreshBtnClick()
  else
    return false
  end
  return true
end
def.override("string").onClick = function(self, id)
end
def.method().UpdateUI = function(self)
  self.goalsList = DailyGoalVDMgr.Instance():GetDailyGoalsViewData()
  self:ReorderGoalsList()
  self:SetList(self.goalsList)
  self:UpdateMoneys()
end
def.method().ReorderGoalsList = function(self)
  local list = self.goalsList
  table.sort(list, function(left, right)
    if right.isAwarded then
      if left.isAwarded then
        return left.rank < right.rank
      else
        return true
      end
    elseif left.isAwarded then
      return false
    elseif right.isFinished then
      if left.isFinished then
        return left.rank < right.rank
      else
        return false
      end
    elseif left.isFinished then
      return true
    else
      return left.rank < right.rank
    end
  end)
end
def.method("table").SetList = function(self, list)
  if list == nil then
    return
  end
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
  local name, curValue, totalValue = viewData.name, viewData.curValue, viewData.totalValue
  local awardItemList = viewData.awardItemList
  local isAwarded, isFinished = viewData.isAwarded, viewData.isFinished
  local listItem = self.uiObjs.List:FindDirect("item_" .. index)
  local Label_Name = listItem:FindDirect("Label_Name")
  Label_Name:GetComponent("UILabel").text = name
  local sliderObj = listItem:FindDirect("Slider")
  self:SetSliderBar(sliderObj, curValue, totalValue)
  local cellRoot = listItem:FindDirect("Group_Prize")
  for i = 1, DailyGoalNode.AWARD_CELL_NUM do
    local item = awardItemList[i]
    local itemBase
    local itemnum = 0
    if item then
      itemBase = {
        icon = item.iconId,
        itemid = item.itemId
      }
      itemnum = item.num
    end
    self:SetAwardItem(cellRoot, i, itemBase, itemnum)
  end
  local Group_Btn = listItem:FindDirect("Group_Btn")
  local Btn_Go = Group_Btn:FindDirect("Btn_Go")
  local Btn_Get = Group_Btn:FindDirect("Btn_Get")
  local Img_Finish = Group_Btn:FindDirect("Img_Finish")
  Img_Finish:SetActive(false)
  Btn_Go:SetActive(false)
  Btn_Get:SetActive(false)
  if isAwarded then
    Img_Finish:SetActive(true)
    GUIUtils.SetLightEffect(Btn_Get, GUIUtils.Light.None)
  elseif isFinished then
    Btn_Get:SetActive(true)
    GUIUtils.SetLightEffect(Btn_Get, GUIUtils.Light.Square)
  else
    Btn_Go:SetActive(true)
  end
end
def.method("userdata", "number", "number").SetSliderBar = function(self, sliderObj, val, max)
  local sliderValue = val / max
  local sliderText = string.format("%d/%d", val, max)
  local uiSlider = sliderObj:GetComponent("UISlider")
  uiSlider.sliderValue = sliderValue
  local Label_Num = sliderObj:FindDirect("Label_Num")
  Label_Num:GetComponent("UILabel").text = sliderText
end
def.method("userdata", "number", "table", "dynamic").SetAwardItem = function(self, cellRoot, index, itemBase, num)
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
  if itemBase.itemid ~= 0 then
    self.easyitemtip:RegisterItem2ShowTipEx(itemBase.itemid, id, cellObj)
  end
end
def.method("number", "=>", "number").FindGoalPos = function(self, goalId)
  if self.goalsList == nil then
    return 0
  end
  local pos = 0
  for i, v in ipairs(self.goalsList) do
    if goalId == v.id then
      pos = i
      break
    end
  end
  return pos
end
def.method("number").ReqGoalAward = function(self, index)
  local goal = self.goalsList[index]
  DailyGoalMgr.Instance():ReqGoalAward(goal.id)
end
def.method("number").GoToGoal = function(self, index)
  local goal = self.goalsList[index]
  local success = DailyGoalMgr.Instance():GoToGoal(goal.id)
  if success then
    self.m_base:DestroyPanel()
  end
end
def.method().UpdateMoneys = function(self)
  local needNum = DailyGoalMgr.Instance():GetRefreshNeedMoneyNum()
  local haveNum = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
  GUIUtils.SetText(self.uiObjs.Label_NeedNum, tostring(needNum))
  GUIUtils.SetText(self.uiObjs.Label_HaveNum, tostring(haveNum))
end
def.method().OnRefreshBtnClick = function(self)
  DailyGoalMgr.Instance():CRefreshDailyGoals()
end
def.static("table", "table").OnSyncDailyGoals = function(params, context)
  instance:UpdateUI()
end
def.static("table", "table").OnDailyGoalUpdate = function(params, context)
  local goalId = unpack(params)
  local viewdata = DailyGoalVDMgr.Instance():GetDailyGoalViewData(goalId)
  local index = instance:FindGoalPos(goalId)
  instance:SetListItem(index, viewdata)
end
def.static("table", "table").OnMoneyGoldUpdate = function(params, context)
  instance:UpdateMoneys()
end
def.static("table", "table").OnNewDay = function(params, context)
  DailyGoalMgr.Instance():CGetInitTargets()
end
def.static("table", "table").OnNotifyUpdate = function(params, context)
  if instance:IsUnlock() == false then
    require("Main.activity.ui.ActivityMain").Instance():HideDlg()
  end
end
def.method().Release = function(self)
  self.uiObjs = nil
  self.goalsList = nil
  self.easyitemtip = nil
end
return DailyGoalNode.Commit()
