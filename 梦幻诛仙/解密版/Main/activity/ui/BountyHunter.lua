local Lplus = require("Lplus")
local ECGUIMan = require("GUI.ECGUIMan")
local Vector = require("Types.Vector")
local ECPanelBase = require("GUI.ECPanelBase")
local BountyHunter = Lplus.Extend(ECPanelBase, "BountyHunter")
local def = BountyHunter.define
local instance
local ActivityInterface = require("Main.activity.ActivityInterface")
local activityInterface = ActivityInterface.Instance()
local TaskInterface = require("Main.task.TaskInterface")
local taskInterface = TaskInterface.Instance()
local BTaskInfo = require("netio.protocol.mzm.gsp.bounty.BTaskInfo")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = require("Main.Item.ItemModule")
local MallUtility = require("Main.Mall.MallUtility")
local itemData = require("Main.Item.ItemData").Instance()
local BagInfo = require("netio.protocol.mzm.gsp.item.BagInfo")
def.static("=>", BountyHunter).Instance = function()
  if instance == nil then
    instance = BountyHunter()
    instance:Init()
  end
  return instance
end
def.field("table")._GraphIDs = nil
def.field("number")._selectedIndex = 0
def.field("boolean").isshowing = false
def.field("boolean").canRefresh = true
def.method().Init = function(self)
  self.m_TrigGC = true
  self._GraphIDs = {
    constant.BountyConsts.BOUNTYHUNTER_TASK_GRAPH_ID_1,
    constant.BountyConsts.BOUNTYHUNTER_TASK_GRAPH_ID_2,
    constant.BountyConsts.BOUNTYHUNTER_TASK_GRAPH_ID_3,
    constant.BountyConsts.BOUNTYHUNTER_TASK_GRAPH_ID_4
  }
end
def.method().ShowDlg = function(self)
  if self:IsShow() == false then
    self.isshowing = true
    self:CreatePanel(RESPATH.PREFAB_UI_BOUNTYHUNTER, 1)
    self:SetModal(true)
  end
end
def.method().HideDlg = function(self)
  self.isshowing = false
  self:DestroyPanel()
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_InfoChanged, BountyHunter.OnTaskInfoChanged)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, BountyHunter.OnEnterFight)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, BountyHunter.OnBagInfoSynchronized)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_InfoChanged, BountyHunter.OnTaskInfoChanged)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, BountyHunter.OnEnterFight)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, BountyHunter.OnBagInfoSynchronized)
  self._selectedIndex = 0
  self.isshowing = false
end
def.override("boolean").OnShow = function(self, s)
  if s == true then
    local Btn_Search = self.m_panel:FindDirect("Img_Bg/Group_Bottom/Btn_Search")
    if IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_BOUNTY_STAR_PROBABILITY) then
      Btn_Search:SetActive(true)
    else
      Btn_Search:SetActive(false)
    end
    self.canRefresh = true
    if activityInterface._bountyTaskInfos == nil then
      local p = require("netio.protocol.mzm.gsp.bounty.CFlushNewReq").new(0, Int64.new(0), Int64.new(0))
      gmodule.network.sendProtocol(p)
      self:Clear()
    else
      self:Fill()
    end
    local itemBase = ItemUtils.GetItemBase(constant.BountyConsts.BOUNTYHUNTER_FLUSH_ITEM_ID)
    if itemBase ~= nil then
      local Img_Bg = self.m_panel:FindDirect("Img_Bg")
      local Group_Bottom = Img_Bg:FindDirect("Group_Bottom")
      local Texture_Item = Group_Bottom:FindDirect("Texture_Item")
      local uiTexture = Texture_Item:GetComponent("UITexture")
      GUIUtils.FillIcon(uiTexture, itemBase.icon)
    end
  else
    self.canRefresh = true
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:HideDlg()
    return
  end
  if id == "Btn_Search" then
    local tipId = constant.BountyConsts.BOUNTYHUNTER_PROBABILITY_TIP_ID
    local tipStr = require("Main.Common.TipsHelper").GetHoverTip(tipId)
    local CommonUITipsDlg = require("GUI.CommonUITipsDlg")
    CommonUITipsDlg.Instance():ShowDlg(tipStr, {x = 0, y = 0})
    return
  end
  local fnTable = {}
  fnTable.Btn_Refresh = BountyHunter.OnBtn_Refresh
  fnTable.Btn_RefreshFree = BountyHunter.OnBtn_Refresh
  fnTable.Btn_Get = BountyHunter.OnBtn_Get
  fnTable.Btn_GiveUp = BountyHunter.OnBtn_GiveUp
  fnTable.Btn_Tips1 = BountyHunter.OnBtn_Tips1
  fnTable.Btn_Tips2 = BountyHunter.OnBtn_Tips2
  fnTable.Texture_Item = BountyHunter.OnTexture_Item
  fnTable.YuanbaoRaplace = BountyHunter.OnSelectYuanbaoReplace
  fnTable.Btn_YuanbaoRefresh = BountyHunter.OnYuanbaoRefreshClick
  local fn = fnTable[id]
  if fn ~= nil then
    fn(self)
    return
  end
  local strs = string.split(id, "_")
  if strs[1] == "Group" and strs[2] == "Task" then
    local index = tonumber(strs[3])
    if index ~= nil then
      self:SetSelect(index)
    end
  elseif strs[1] == "Img" and strs[2] == "BgPrize" then
    local index = tonumber(strs[3])
    if index ~= nil then
      self:_ShowAwardTip(index)
    end
  end
end
def.method().Clear = function(self, id)
  local Img_Bg = self.m_panel:FindDirect("Img_Bg")
  local Goup_Task = Img_Bg:FindDirect("Goup_Task")
  local Grid = Goup_Task:FindDirect("Grid")
  for idx = 1, 4 do
    local Group_Task_X = Grid:FindDirect(string.format("Group_Task_%d", idx))
    local Label_Name = Group_Task_X:FindDirect("Label_Name")
    local Img_Finish = Group_Task_X:FindDirect("Img_Finish")
    local Img_Get = Group_Task_X:FindDirect("Img_Get")
    local Img_GiveUp = Group_Task_X:FindDirect("Img_GiveUp")
    local graphID = self._GraphIDs[idx]
    Label_Name:GetComponent("UILabel"):set_text("")
    Img_Finish:SetActive(false)
    Img_Get:SetActive(false)
    Img_GiveUp:SetActive(false)
  end
  local Group_Bottom = Img_Bg:FindDirect("Group_Bottom")
  local Group_Top = Img_Bg:FindDirect("Group_Top")
  local Label_Times = Group_Top:FindDirect("Label_Times")
  local Label_Num = Group_Bottom:FindDirect("Label_Num")
  Label_Times:GetComponent("UILabel"):set_text("")
  Label_Num:GetComponent("UILabel"):set_text("")
  local Btn_Get = Group_Bottom:FindDirect("Btn_Get")
  local Btn_GiveUp = Group_Bottom:FindDirect("Btn_GiveUp")
  Btn_Get:SetActive(false)
  Btn_GiveUp:SetActive(false)
  local Group_Describe = Img_Bg:FindDirect("Group_Describe")
  local Label_TaskName = Group_Describe:FindDirect("Label_TaskName")
  local Label_Describe = Group_Describe:FindDirect("Label_Describe")
  Label_TaskName:GetComponent("UILabel"):set_text("")
  Label_Describe:GetComponent("UILabel"):set_text("")
  self.canRefresh = true
end
def.method().Fill = function(self, id)
  self:_FillList()
  self:_SetButtonRefresh()
  self:_FillNum()
  if self._selectedIndex == 0 then
    self._selectedIndex = 1
  end
  self:SetSelect(self._selectedIndex)
end
def.method()._FillList = function(self, id)
  local Img_Bg = self.m_panel:FindDirect("Img_Bg")
  local Goup_Task = Img_Bg:FindDirect("Goup_Task")
  local Grid = Goup_Task:FindDirect("Grid")
  local completeNum = 0
  local giveupNum = 0
  for idx = 1, 4 do
    local Group_Task_X = Grid:FindDirect(string.format("Group_Task_%d", idx))
    local Label_Name = Group_Task_X:FindDirect("Label_Name")
    local Img_Finish = Group_Task_X:FindDirect("Img_Finish")
    local Img_Get = Group_Task_X:FindDirect("Img_Get")
    local Img_GiveUp = Group_Task_X:FindDirect("Img_GiveUp")
    local graphID = self._GraphIDs[idx]
    local info = activityInterface._bountyTaskInfos[graphID]
    local taskCfg = TaskInterface.GetTaskCfg(info.taskId)
    Label_Name:GetComponent("UILabel"):set_text(taskCfg.taskName)
    local FINISHED = info.taskState == BTaskInfo.FINISHED
    local ALREADY_ACCEPTED = info.taskState == BTaskInfo.ALREADY_ACCEPTED
    local GIVE_UP = info.taskState == BTaskInfo.GIVE_UP
    if ALREADY_ACCEPTED == true and self._selectedIndex == 0 then
      self._selectedIndex = idx
    end
    Img_Finish:SetActive(FINISHED)
    Img_Get:SetActive(ALREADY_ACCEPTED)
    Img_GiveUp:SetActive(GIVE_UP)
    if FINISHED == true then
      completeNum = completeNum + 1
    end
    if GIVE_UP == true then
      giveupNum = giveupNum + 1
    end
  end
  activityInterface._flushNeedNum = 3 - completeNum - giveupNum
  activityInterface._flushNeedNum = math.max(0, activityInterface._flushNeedNum)
end
def.method()._FillNum = function(self, id)
  local Img_Bg = self.m_panel:FindDirect("Img_Bg")
  local Group_Bottom = Img_Bg:FindDirect("Group_Bottom")
  local Group_Top = Img_Bg:FindDirect("Group_Top")
  local Label_Times = Group_Top:FindDirect("Label_Times")
  local Label_Num = Group_Bottom:FindDirect("Label_Num")
  Label_Times:GetComponent("UILabel"):set_text("(" .. tostring(activityInterface._bountyCount) .. "/" .. tostring(constant.BountyConsts.BOUNTYHUNTER_DAY_UPPER_LIMIT) .. ")")
  local count = itemData:GetNumberByItemId(BagInfo.BAG, constant.BountyConsts.BOUNTYHUNTER_FLUSH_ITEM_ID)
  local str = string.format("%d / %d", count, activityInterface._flushNeedNum)
  if count < activityInterface._flushNeedNum then
    str = "[ff0000]" .. str .. "[-]"
  end
  Label_Num:GetComponent("UILabel"):set_text(str)
  local YuanbaoRaplace = Img_Bg:FindDirect("YuanbaoRaplace")
  local btn_Toggle = YuanbaoRaplace:GetComponent("UIToggle")
  local Btn_YuanbaoRefresh = Group_Bottom:FindDirect("Btn_YuanbaoRefresh")
  if count < activityInterface._flushNeedNum then
    YuanbaoRaplace:SetActive(true)
    if btn_Toggle.value then
      local itemId = constant.BountyConsts.BOUNTYHUNTER_FLUSH_ITEM_ID
      local count = itemData:GetNumberByItemId(BagInfo.BAG, itemId)
      local needNum = activityInterface._flushNeedNum - count
      local yuanbaoPrice = MallUtility.GetPriceByItemId(itemId)
      local yuanbaoNum = ItemModule.Instance():GetAllYuanBao()
      local Label_Number = Btn_YuanbaoRefresh:FindDirect("Label_Number")
      Label_Number:GetComponent("UILabel"):set_text(needNum * yuanbaoPrice)
    end
  else
    YuanbaoRaplace:SetActive(false)
  end
end
def.method()._SetButtonEnable = function(self)
  if activityInterface._bountyTaskInfos == nil then
    return
  end
  local Img_Bg = self.m_panel:FindDirect("Img_Bg")
  local Group_Bottom = Img_Bg:FindDirect("Group_Bottom")
  local graphID = self._GraphIDs[self._selectedIndex]
  local info = activityInterface._bountyTaskInfos[graphID]
  local Btn_Get = Group_Bottom:FindDirect("Btn_Get")
  local Btn_GiveUp = Group_Bottom:FindDirect("Btn_GiveUp")
  Btn_Get:SetActive(info.taskState == BTaskInfo.UN_ACCEPTED)
  Btn_GiveUp:SetActive(info.taskState == BTaskInfo.ALREADY_ACCEPTED)
end
def.method()._SetButtonRefresh = function(self)
  local completeNum = 0
  local giveupNum = 0
  for idx = 1, 4 do
    local graphID = self._GraphIDs[idx]
    local info = activityInterface._bountyTaskInfos[graphID]
    if info.taskState == BTaskInfo.FINISHED then
      completeNum = completeNum + 1
    end
    if info.taskState == BTaskInfo.GIVE_UP then
      giveupNum = giveupNum + 1
    end
  end
  local Img_Bg = self.m_panel:FindDirect("Img_Bg")
  local Group_Bottom = Img_Bg:FindDirect("Group_Bottom")
  local Btn_RefreshFree = Group_Bottom:FindDirect("Btn_RefreshFree")
  local Btn_Refresh = Group_Bottom:FindDirect("Btn_Refresh")
  local Btn_YuanbaoRefresh = Group_Bottom:FindDirect("Btn_YuanbaoRefresh")
  local YuanbaoRaplace = Img_Bg:FindDirect("YuanbaoRaplace")
  if completeNum + giveupNum >= 3 then
    Btn_RefreshFree:SetActive(true)
    Btn_Refresh:SetActive(false)
    YuanbaoRaplace:SetActive(false)
    Btn_YuanbaoRefresh:SetActive(false)
  else
    Btn_RefreshFree:SetActive(false)
    local count = itemData:GetNumberByItemId(BagInfo.BAG, constant.BountyConsts.BOUNTYHUNTER_FLUSH_ITEM_ID)
    if count >= activityInterface._flushNeedNum then
      Btn_Refresh:SetActive(true)
      YuanbaoRaplace:SetActive(false)
      Btn_YuanbaoRefresh:SetActive(false)
    else
      local btn_Toggle = YuanbaoRaplace:GetComponent("UIToggle")
      if btn_Toggle.value then
        Btn_Refresh:SetActive(false)
        Btn_YuanbaoRefresh:SetActive(true)
      else
        Btn_Refresh:SetActive(true)
        Btn_YuanbaoRefresh:SetActive(false)
      end
      YuanbaoRaplace:SetActive(true)
    end
  end
end
def.method("number")._SetSelect = function(self, index)
  self._selectedIndex = index
  local Img_Bg = self.m_panel:FindDirect("Img_Bg")
  local Goup_Task = Img_Bg:FindDirect("Goup_Task")
  local Grid = Goup_Task:FindDirect("Grid")
  for idx = 1, 4 do
    local Group_Task_X = Grid:FindDirect(string.format("Group_Task_%d", idx))
    local Img_Select = Group_Task_X:FindDirect("Img_Select")
    Img_Select:SetActive(self._selectedIndex == idx)
  end
end
def.method()._FillSelected = function(self)
  if activityInterface._bountyTaskInfos == nil then
    return
  end
  local Img_Bg = self.m_panel:FindDirect("Img_Bg")
  local Group_Describe = Img_Bg:FindDirect("Group_Describe")
  local Label_TaskName = Group_Describe:FindDirect("Label_TaskName")
  local Label_Describe = Group_Describe:FindDirect("Label_Describe")
  local Grid_Prize = Group_Describe:FindDirect("Group_Prize/Grid_Prize")
  local graphID = self._GraphIDs[self._selectedIndex]
  local info = activityInterface._bountyTaskInfos[graphID]
  local taskCfg = TaskInterface.GetTaskCfg(info.taskId)
  local bountyViewCfg = ActivityInterface.GetBountyViewCfg(info.taskId)
  if bountyViewCfg ~= nil then
    Label_TaskName:GetComponent("UILabel"):set_text(bountyViewCfg.taskName)
    for i = 1, 4 do
      local Texture_Prize = Grid_Prize:FindDirect(string.format("Img_BgPrize_%d/Texture_Prize", i))
      local itemID = bountyViewCfg.itemIDs[i]
      if itemID ~= nil and itemID > 0 then
        local itemBase = ItemUtils.GetItemBase(itemID)
        if itemBase ~= nil then
          Texture_Prize:SetActive(true)
          local uiTexture = Texture_Prize:GetComponent("UITexture")
          GUIUtils.FillIcon(uiTexture, itemBase.icon)
        else
          Texture_Prize:SetActive(false)
        end
      else
        Texture_Prize:SetActive(false)
      end
    end
  else
    for i = 1, 4 do
      local Texture_Prize = Grid_Prize:FindDirect(string.format("Img_BgPrize_%d/Texture_Prize", i))
      Texture_Prize:SetActive(false)
    end
    Label_TaskName:GetComponent("UILabel"):set_text(taskCfg.taskName)
  end
  local TaskString = require("Main.task.TaskString")
  local taskString = TaskString.Instance()
  taskString:SetTargetTaskCfg(taskCfg)
  taskString:SetConditionData(nil)
  local dispDesc = string.gsub(taskCfg.taskDes, "%$%((.-)%)%$", TaskString.DoReplace)
  Label_Describe:GetComponent("UILabel"):set_text(dispDesc)
end
def.static(BountyHunter).OnBtn_Refresh = function(self)
  if activityInterface._bountyCount >= constant.BountyConsts.BOUNTYHUNTER_DAY_UPPER_LIMIT then
    Toast(textRes.activity[384])
    return
  end
  if activityInterface._bountyTaskInfos == nil then
    self:sendCFlushNewReq(0, Int64.new(0), Int64.new(0))
    return
  end
  local completeNum = 0
  local giveupNum = 0
  for idx = 1, 4 do
    local graphID = self._GraphIDs[idx]
    local info = activityInterface._bountyTaskInfos[graphID]
    if info.taskState == BTaskInfo.ALREADY_ACCEPTED then
      Toast(textRes.activity[247])
      return
    end
    if info.taskState == BTaskInfo.FINISHED then
      completeNum = completeNum + 1
    end
    if info.taskState == BTaskInfo.GIVE_UP then
      giveupNum = giveupNum + 1
    end
  end
  if completeNum >= 3 or giveupNum >= 3 then
    self:sendCFlushNewReq(0, Int64.new(0), Int64.new(0))
    return
  end
  local itemData = require("Main.Item.ItemData").Instance()
  local BagInfo = require("netio.protocol.mzm.gsp.item.BagInfo")
  local count = itemData:GetNumberByItemId(BagInfo.BAG, constant.BountyConsts.BOUNTYHUNTER_FLUSH_ITEM_ID)
  local itemBase = ItemUtils.GetItemBase(constant.BountyConsts.BOUNTYHUNTER_FLUSH_ITEM_ID)
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  if count < activityInterface._flushNeedNum then
    if itemBase ~= nil then
      local Img_Bg = self.m_panel:FindDirect("Img_Bg")
      local YuanbaoRaplace = Img_Bg:FindDirect("YuanbaoRaplace")
      local btn_Toggle = YuanbaoRaplace:GetComponent("UIToggle")
      btn_Toggle.value = true
      BountyHunter.OnSelectYuanbaoReplace(self)
    end
    return
  end
  local str2 = "[" .. HtmlHelper.NameColor[itemBase.namecolor] .. "]" .. itemBase.name .. "[-]"
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirm(textRes.activity[240], string.format(textRes.activity[244], activityInterface._flushNeedNum, str2), BountyHunter.OnRefreshConfirm, {self})
end
def.static("number", "table").OnRefreshConfirm = function(id, tag)
  if id == 1 then
    local self = tag[1]
    self:sendCFlushNewReq(0, Int64.new(0), Int64.new(0))
  end
end
def.static(BountyHunter).OnBtn_Get = function(self)
  local succeed = ActivityInterface.CheckActivityConditionFinishCount(constant.BountyConsts.BOUNTYHUNTER_ACTIVITYID)
  if succeed == false then
    Toast(textRes.activity[249])
    return
  end
  if activityInterface._bountyTaskInfos == nil then
    return
  end
  for idx = 1, 4 do
    local graphID = self._GraphIDs[idx]
    local info = activityInterface._bountyTaskInfos[graphID]
    if info.taskState == BTaskInfo.ALREADY_ACCEPTED then
      Toast(textRes.activity[241])
      return
    end
  end
  local graphID = self._GraphIDs[self._selectedIndex]
  local info = activityInterface._bountyTaskInfos[graphID]
  require("Main.task.TaskAceptOperationByGraph").Instance():AceptTask(info.taskId, graphID)
end
def.static(BountyHunter).OnBtn_GiveUp = function(self)
  if activityInterface._bountyTaskInfos == nil then
    return
  end
  local graphID = self._GraphIDs[self._selectedIndex]
  local info = activityInterface._bountyTaskInfos[graphID]
  if info.taskState ~= BTaskInfo.ALREADY_ACCEPTED then
    return
  end
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirm(textRes.activity[240], textRes.activity[242], BountyHunter.OnGiveUpConfirm, {self})
end
def.static("number", "table").OnGiveUpConfirm = function(id, tag)
  if id == 1 then
    if activityInterface._bountyTaskInfos == nil then
      return
    end
    local self = tag[1]
    local graphID = self._GraphIDs[self._selectedIndex]
    local info = activityInterface._bountyTaskInfos[graphID]
    require("Main.task.TaskGiveupOperationByGraph").Instance():GiveUpTask(info.taskId, graphID)
  end
end
def.static(BountyHunter).OnBtn_Tips1 = function(self)
  local CommonUITipsDlg = require("GUI.CommonUITipsDlg")
  CommonUITipsDlg.Instance():ShowDlg(string.format(textRes.activity[245]), {x = 32, y = -170})
end
def.static(BountyHunter).OnBtn_Tips2 = function(self)
  local CommonUITipsDlg = require("GUI.CommonUITipsDlg")
  CommonUITipsDlg.Instance():ShowDlg(string.format(textRes.activity[246]), {x = 100, y = -95})
end
def.static(BountyHunter).OnTexture_Item = function(self)
  local itemID = constant.BountyConsts.BOUNTYHUNTER_FLUSH_ITEM_ID
  local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
  local Img_Bg = self.m_panel:FindDirect("Img_Bg")
  local Group_Bottom = Img_Bg:FindDirect("Group_Bottom")
  local Img_Item = Group_Bottom:FindDirect("Texture_Item/Img_Item")
  local position = Img_Item:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = Img_Item:GetComponent("UISprite")
  ItemTipsMgr.Instance():ShowBasicTips(itemID, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, true)
end
def.method("number").SetSelect = function(self, index)
  self:_SetSelect(index)
  self:_FillSelected()
  self:_SetButtonEnable()
end
def.method("number")._ShowAwardTip = function(self, index)
  local graphID = self._GraphIDs[self._selectedIndex]
  local info = activityInterface._bountyTaskInfos[graphID]
  local taskCfg = TaskInterface.GetTaskCfg(info.taskId)
  local bountyViewCfg = ActivityInterface.GetBountyViewCfg(info.taskId)
  if bountyViewCfg ~= nil then
    local itemID = bountyViewCfg.itemIDs[index]
    if itemID ~= nil and itemID > 0 then
      local Img_Bg = self.m_panel:FindDirect("Img_Bg")
      local Group_Describe = Img_Bg:FindDirect("Group_Describe")
      local Grid_Prize = Group_Describe:FindDirect("Group_Prize/Grid_Prize")
      local Img_BgPrize = Grid_Prize:FindDirect(string.format("Img_BgPrize_%d", index))
      local position = Img_BgPrize:get_position()
      local screenPos = WorldPosToScreen(position.x, position.y)
      local sprite = Img_BgPrize:GetComponent("UISprite")
      local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
      ItemTipsMgr.Instance():ShowBasicTips(itemID, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, false)
    end
  end
end
def.static("table", "table").OnTaskInfoChanged = function(p1, p2)
  instance:_FillList()
  instance:_FillNum()
  instance:_SetButtonRefresh()
end
def.static("table", "table").OnEnterFight = function(p1, p2)
  instance:HideDlg()
end
def.static("table", "table").OnBagInfoSynchronized = function(p1, p2)
  instance:_FillNum()
  instance:_SetButtonRefresh()
end
def.static(BountyHunter).OnSelectYuanbaoReplace = function(self)
  local Img_Bg = self.m_panel:FindDirect("Img_Bg")
  local YuanbaoRaplace = Img_Bg:FindDirect("YuanbaoRaplace")
  local btn_Toggle = YuanbaoRaplace:GetComponent("UIToggle")
  local Group_Bottom = Img_Bg:FindDirect("Group_Bottom")
  local Btn_Refresh = Group_Bottom:FindDirect("Btn_Refresh")
  local Btn_YuanbaoRefresh = Group_Bottom:FindDirect("Btn_YuanbaoRefresh")
  if btn_Toggle.value then
    local function confirmCallback(id)
      if id == 1 then
        btn_Toggle.value = true
        Btn_Refresh:SetActive(false)
        Btn_YuanbaoRefresh:SetActive(true)
        local itemId = constant.BountyConsts.BOUNTYHUNTER_FLUSH_ITEM_ID
        local count = itemData:GetNumberByItemId(BagInfo.BAG, itemId)
        local needNum = activityInterface._flushNeedNum - count
        local yuanbaoPrice = MallUtility.GetPriceByItemId(itemId)
        local yuanbaoNum = ItemModule.Instance():GetAllYuanBao()
        local Label_Number = Btn_YuanbaoRefresh:FindDirect("Label_Number")
        Label_Number:GetComponent("UILabel"):set_text(needNum * yuanbaoPrice)
      else
        btn_Toggle.value = false
        Btn_Refresh:SetActive(true)
        Btn_YuanbaoRefresh:SetActive(false)
      end
    end
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    CommonConfirmDlg.ShowConfirm("", textRes.activity[386], confirmCallback, {self})
  else
    Btn_Refresh:SetActive(true)
    Btn_YuanbaoRefresh:SetActive(false)
  end
end
def.static(BountyHunter).OnYuanbaoRefreshClick = function(self)
  if activityInterface._bountyCount >= constant.BountyConsts.BOUNTYHUNTER_DAY_UPPER_LIMIT then
    Toast(textRes.activity[384])
    return
  end
  for idx = 1, 4 do
    local graphID = self._GraphIDs[idx]
    local info = activityInterface._bountyTaskInfos[graphID]
    if info.taskState == BTaskInfo.ALREADY_ACCEPTED then
      Toast(textRes.activity[247])
      return
    end
  end
  local itemId = constant.BountyConsts.BOUNTYHUNTER_FLUSH_ITEM_ID
  local count = itemData:GetNumberByItemId(BagInfo.BAG, itemId)
  local needNum = activityInterface._flushNeedNum - count
  local yuanbaoPrice = MallUtility.GetPriceByItemId(itemId)
  local yuanbaoNum = ItemModule.Instance():GetAllYuanBao()
  local needYuanbao = yuanbaoPrice * needNum
  if needYuanbao <= Int64.ToNumber(yuanbaoNum) then
    self:sendCFlushNewReq(1, Int64.new(yuanbaoNum), Int64.new(needYuanbao))
  else
    _G.GotoBuyYuanbao()
  end
end
def.method("number", "userdata", "userdata").sendCFlushNewReq = function(self, tag, yuanbaoNum, needYuanbao)
  local tipStr = ""
  local infos = activityInterface._bountyTaskInfos
  if infos then
    for idx = 1, 4 do
      local graphID = self._GraphIDs[idx]
      local info = infos[graphID]
      local UN_ACCEPTED = info.taskState == BTaskInfo.UN_ACCEPTED
      if UN_ACCEPTED then
        local bountyTaskCfg = TaskInterface.GetBountyTaskCfg(info.taskId)
        tipStr = bountyTaskCfg.tipStr
        if bountyTaskCfg and tipStr ~= "" then
          break
        end
      end
    end
  end
  local function sendProtocol(id)
    if id == 0 and self.canRefresh then
      local p = require("netio.protocol.mzm.gsp.bounty.CFlushNewReq").new(tag, yuanbaoNum, needYuanbao)
      gmodule.network.sendProtocol(p)
      self.canRefresh = false
    end
  end
  if tipStr == "" then
    sendProtocol(0)
  else
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    local commonDlg = CommonConfirmDlg.ShowConfirmCoundDown("", tipStr, textRes.activity[397], textRes.activity[363], 0, 0, sendProtocol, {self})
  end
end
BountyHunter.Commit()
return BountyHunter
