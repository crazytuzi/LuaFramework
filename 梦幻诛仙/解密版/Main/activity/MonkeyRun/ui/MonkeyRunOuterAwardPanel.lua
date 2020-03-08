local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local MonkeyRunOuterAwardPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = require("Main.Item.ItemModule")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ECUIModel = require("Model.ECUIModel")
local Vector = require("Types.Vector")
local AwardUtils = require("Main.Award.AwardUtils")
local AwardItemTipHelper = require("Main.Award.AwardItemTipHelper")
local MonkeyRunMgr = require("Main.activity.MonkeyRun.MonkeyRunMgr")
local MonkeyRunUtils = require("Main.activity.MonkeyRun.MonkeyRunUtils")
local def = MonkeyRunOuterAwardPanel.define
def.const("number").MOVE_GRID_PER_FRAME = 2
def.const("number").INIT_TICKET_LIST_NUM = 5
def.const("number").SHOW_GET_TICKET_NUM = 2
def.field("table").uiObjs = nil
def.field(ECUIModel).heroModel = nil
def.field("number").curStandCell = 0
def.field("table").heroMoveDir = nil
def.field("table").heroMovePath = nil
def.field("boolean").disableOperate = false
def.field(AwardItemTipHelper).itemTipHelper = nil
def.field("boolean").useYuanbao = false
def.field("boolean").delayToShowEffect = false
def.field("boolean").needEffectToUpdateTicket = false
def.field("boolean").isInit = false
local instance
def.static("=>", MonkeyRunOuterAwardPanel).Instance = function()
  if instance == nil then
    instance = MonkeyRunOuterAwardPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self.m_panel and not self.m_panel.isnil then
    return
  end
  self:SetModal(true)
  self:CreatePanel(RESPATH.PREFAB_MONKEYRUN_PANEL, 1)
end
def.override().OnCreate = function(self)
  if self.m_panel == nil then
    return
  end
  self:InitUI()
  self:AjustCtrl()
  self:InitHeroModel()
  self:FillAwardGrid()
  self:UpdateGameTickets()
  self:UpdateHeroMoveRoundData()
  self:UpdateGameTime()
  self:UpdateGameCost()
  self:UpdateInnerGameBtnStatus()
  self.isInit = true
  Timer:RegisterIrregularTimeListener(self.Update, self)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, MonkeyRunOuterAwardPanel.OnBagInfoSynchronized)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_MonkeyRun_Move_Hero, MonkeyRunOuterAwardPanel.OnMoveHero)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_MonkeyRun_Get_Out_Award, MonkeyRunOuterAwardPanel.OnGetAward)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_MonkeyRun_Get_Ticket, MonkeyRunOuterAwardPanel.OnGetTicket)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_MonkeyRun_Ticket_Change, MonkeyRunOuterAwardPanel.OnTicketChange)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_MonkeyRun_OpenChange, MonkeyRunOuterAwardPanel.OnOpenChange)
end
def.override().OnDestroy = function(self)
  Timer:RemoveIrregularTimeListener(self.Update)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, MonkeyRunOuterAwardPanel.OnBagInfoSynchronized)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_MonkeyRun_Move_Hero, MonkeyRunOuterAwardPanel.OnMoveHero)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_MonkeyRun_Get_Out_Award, MonkeyRunOuterAwardPanel.OnGetAward)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_MonkeyRun_Get_Ticket, MonkeyRunOuterAwardPanel.OnGetTicket)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_MonkeyRun_Ticket_Change, MonkeyRunOuterAwardPanel.OnTicketChange)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_MonkeyRun_OpenChange, MonkeyRunOuterAwardPanel.OnOpenChange)
  self.uiObjs = nil
  self.curStandCell = 0
  self.heroMovePath = nil
  self.disableOperate = false
  self.itemTipHelper = nil
  self.useYuanbao = false
  self.delayToShowEffect = false
  self.needEffectToUpdateTicket = false
  self.isInit = false
  if self.heroModel ~= nil then
    self.heroModel:Destroy()
    self.heroModel = nil
  end
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.Group_Left = self.uiObjs.Img_Bg0:FindDirect("Group_Left")
  self.uiObjs.Label_TimeName = self.uiObjs.Group_Left:FindDirect("Label_TimeName")
  self.uiObjs.Label_TimeNum = self.uiObjs.Group_Left:FindDirect("Label_TimeNum")
  self.uiObjs.Group_Right = self.uiObjs.Img_Bg0:FindDirect("Group_Right")
  self.uiObjs.Group_QianDao = self.uiObjs.Group_Right:FindDirect("Group_QianDao")
  self.uiObjs.Group_Item = self.uiObjs.Group_QianDao:FindDirect("Group_Item")
  self.uiObjs.heroModelGroup = self.uiObjs.Group_Item:FindDirect("Img_BgModel")
  self.uiObjs.heroModel = self.uiObjs.heroModelGroup:FindDirect("Model")
  self.uiObjs.Label_Tips = self.uiObjs.Group_Right:FindDirect("Label_Tips")
  self.uiObjs.Label_RunNum = self.uiObjs.Group_Right:FindDirect("Label_RunNum")
  self.uiObjs.Label_Need = self.uiObjs.Group_Right:FindDirect("Label_Need")
  self.uiObjs.Btn_Reward = self.uiObjs.Group_Right:FindDirect("Btn_Reward")
  self.uiObjs.Group_Bottom = self.uiObjs.Group_Right:FindDirect("Group_Bottom")
  self.uiObjs.Btn_YuanbaoUse = self.uiObjs.Group_Bottom:FindDirect("Btn_YuanbaoUse")
  self.uiObjs.Group_Effect = self.uiObjs.Img_Bg0:FindDirect("Group_Effect")
  self.uiObjs.Reward_Effect = self.uiObjs.Btn_Reward:FindDirect("UI_Panel_MonkeyRun_ZhuaZiAnNiu")
  GUIUtils.SetActive(self.uiObjs.Group_Effect, false)
  GUIUtils.SetActive(self.uiObjs.Reward_Effect, false)
  GUIUtils.SetText(self.uiObjs.Label_Tips, textRes.activity[810])
  self.itemTipHelper = AwardItemTipHelper()
end
def.method().AjustCtrl = function(self)
  if self.uiObjs.heroModel:GetComponent("BoxCollider") ~= nil then
    self.uiObjs.heroModel:GetComponent("BoxCollider"):Destroy()
  end
  self.uiObjs.heroModel.localPosition = Vector.Vector3.new(0, self.uiObjs.heroModel:GetComponent("UIWidget").height / 2, 0)
  local curActivityId = MonkeyRunMgr.Instance():GetCurrentActivityId()
  local totalCellNum = MonkeyRunUtils.GetActivityOuterAwardGridCount(curActivityId)
  self.heroMoveDir = {}
  for i = 1, totalCellNum do
    local pre = i
    local target = i % totalCellNum + 1
    local preCell = self.uiObjs.Group_Item:FindDirect(string.format("Item_%03d", pre))
    local targetCell = self.uiObjs.Group_Item:FindDirect(string.format("Item_%03d", target))
    if preCell ~= nil and targetCell ~= nil then
      local dir = targetCell.localPosition - preCell.localPosition
      local delta = 5
      if delta < dir.x then
        self.heroMoveDir[i] = -270
      elseif dir.x < -delta then
        self.heroMoveDir[i] = -90
      elseif delta < dir.y then
        self.heroMoveDir[i] = 0
      elseif dir.y < -delta then
        self.heroMoveDir[i] = -180
      else
        self.heroMoveDir[i] = -180
      end
    else
      self.heroMoveDir[i] = -180
    end
  end
end
def.method().InitHeroModel = function(self)
  local curActivityId = MonkeyRunMgr.Instance():GetCurrentActivityId()
  local activityCfg = MonkeyRunUtils.GetMonkeyRunActivityCfgById(curActivityId)
  local heroeModelId = activityCfg.modelId
  local uiModel = self.uiObjs.heroModel:GetComponent("UIModel")
  local modelpath, modelcolor = GetModelPath(heroeModelId)
  if modelpath == nil or modelpath == "" then
    return
  end
  if self.heroModel then
    self.heroModel:Destroy()
  end
  local function AfterModelLoad()
    uiModel.modelGameObject = self.heroModel.m_model
    if uiModel.mCanOverflow ~= nil then
      uiModel.mCanOverflow = true
      local camera = uiModel:get_modelCamera()
      camera:set_orthographic(true)
    end
    self.heroModel:SetScale(1.8)
  end
  if not self.heroModel then
    self.heroModel = ECUIModel.new(heroeModelId)
    self.heroModel.m_bUncache = true
    self.heroModel:LoadUIModel(modelpath, function(ret)
      if not self.heroModel or not self.heroModel.m_model or self.heroModel.m_model.isnil then
        return
      end
      AfterModelLoad()
    end)
  end
  self:UpdateHeroToCurrentPos()
  self:ResetHeroStatus()
end
def.method().UpdateHeroToCurrentPos = function(self)
  local awardData = MonkeyRunMgr.Instance():GetCurActivityMonkeyRunOutData()
  local curCell = awardData and awardData:GetCurrentGridIndex() or 0
  self.curStandCell = curCell
  local curStanGrid = self.uiObjs.Group_Item:FindDirect(string.format("Item_%03d", curCell))
  self.uiObjs.heroModelGroup.localPosition = curStanGrid.localPosition
end
def.method().ResetHeroStatus = function(self)
  self.heroModel:SetDir(self.heroMoveDir[self.curStandCell] or -270)
  self.heroModel:Play(ActionName.Stand)
end
def.method("number").MoveHero = function(self, step)
  if self.heroMovePath ~= nil and #self.heroMovePath > 0 then
    local endMovePath = self.heroMovePath[#self.heroMovePath]
    local targetCell = self.uiObjs.Group_Item:FindDirect(string.format("Item_%03d", endMovePath.endCell))
    if targetCell ~= nil then
      self.heroModel:SetDir(self.heroMoveDir[endMovePath.endCell])
      self.uiObjs.heroModelGroup.localPosition = targetCell.localPosition
      self.curStandCell = endMovePath.endCell
    end
  end
  self.heroModel:Play(ActionName.Run)
  self.heroMovePath = {}
  local curActivityId = MonkeyRunMgr.Instance():GetCurrentActivityId()
  local totalCellNum = MonkeyRunUtils.GetActivityOuterAwardGridCount(curActivityId)
  if step > totalCellNum then
    step = step - (math.floor(step / totalCellNum) - 1) * totalCellNum
  end
  for i = 1, step + MonkeyRunOuterAwardPanel.MOVE_GRID_PER_FRAME - 1, MonkeyRunOuterAwardPanel.MOVE_GRID_PER_FRAME do
    local path = {}
    path.endCell = (self.curStandCell - 1 + math.min(i, step)) % totalCellNum + 1
    table.insert(self.heroMovePath, path)
  end
end
def.method("number").Update = function(self, tick)
  self:UpdateHeroMovePath(tick)
end
def.method("number").UpdateHeroMovePath = function(self, tick)
  if self.uiObjs.heroModelGroup and self.heroMovePath ~= nil and #self.heroMovePath > 0 then
    local curMovePath = self.heroMovePath[1]
    local targetCell = self.uiObjs.Group_Item:FindDirect(string.format("Item_%03d", curMovePath.endCell))
    if targetCell ~= nil then
      self.heroModel:SetDir(self.heroMoveDir[curMovePath.endCell])
      self.uiObjs.heroModelGroup.localPosition = targetCell.localPosition
    end
    self.curStandCell = curMovePath.endCell
    table.remove(self.heroMovePath, 1)
    if #self.heroMovePath == 0 then
      self:MoveEnd()
    end
  end
end
def.method().MoveEnd = function(self)
  self:ResetHeroStatus()
end
def.method().FillAwardGrid = function(self)
  self.itemTipHelper:Clear()
  local curActivityId = MonkeyRunMgr.Instance():GetCurrentActivityId()
  local activityGrids = MonkeyRunUtils.GetActivityOuterAwardGridCfg(curActivityId)
  for i = 1, #activityGrids do
    local cell = self.uiObjs.Group_Item:FindDirect(string.format("Item_%03d", i))
    self:FillGridInfo(cell, activityGrids[i])
  end
end
def.method("userdata", "table").FillGridInfo = function(self, grid, gridCfg)
  if grid == nil or gridCfg == nil then
    return
  end
  local Img_BgIcon = grid:FindDirect("Img_BgIcon")
  local Texture_Icon = Img_BgIcon:FindDirect("Texture_Icon")
  local Label_Num = Img_BgIcon:FindDirect("Label_Num")
  local Img_BgIcon1 = Img_BgIcon:FindDirect("Img_BgIcon1")
  local Img_Quality = Img_BgIcon:FindDirect("Img_Quality")
  GUIUtils.SetActive(Label_Num, false)
  local itemBase = ItemUtils.GetItemBase(gridCfg.itemId)
  if itemBase ~= nil then
    GUIUtils.FillIcon(Texture_Icon:GetComponent("UITexture"), itemBase.icon)
    self.itemTipHelper:RegisterItem2ShowTip(gridCfg.itemId, grid)
    GUIUtils.SetItemCellSprite(Img_Quality, gridCfg.gridColor)
    if gridCfg.lightEffectId ~= 0 then
      local effres = _G.GetEffectRes(gridCfg.lightEffectId)
      if effres == nil then
        warn("effect res not exist:" .. gridCfg.lightEffectId)
      else
        require("Fx.GUIFxMan").Instance():PlayAsChildLayerWithCallback(grid, effres.path, "Grid_Effect", 0, 0, 0.7, 0.7, -1, false, nil)
      end
    end
  else
    warn("not found monkeyrun grid item:" .. gridCfg.itemId)
  end
end
def.method().UpdateGameTickets = function(self)
  local curActivityId = MonkeyRunMgr.Instance():GetCurrentActivityId()
  local activityCfg = MonkeyRunUtils.GetMonkeyRunActivityCfgById(curActivityId)
  local ticketAwardCfg = MonkeyRunUtils.GetActivityTicketAwardCfg(curActivityId)
  local awardData = MonkeyRunMgr.Instance():GetCurActivityMonkeyRunOutData()
  local curTurn = awardData and awardData:GetAccumulateTurnCount() or 0
  local nextTurn = -1
  local nextIdx = -1
  for i = 1, #ticketAwardCfg do
    if nextTurn == -1 and curTurn < ticketAwardCfg[i].accumulateTurnCount then
      nextTurn = ticketAwardCfg[i].accumulateTurnCount
      nextIdx = i
      break
    end
  end
  local showCount = 0
  if nextIdx == -1 then
    showCount = #ticketAwardCfg
  else
    showCount = math.min(MonkeyRunOuterAwardPanel.INIT_TICKET_LIST_NUM + math.max(0, nextIdx - 1), #ticketAwardCfg)
  end
  local Scrollview = self.uiObjs.Group_Left:FindDirect("Group_Slider/Group_Item/Scrollview")
  local List_Items = Scrollview:FindDirect("List_Items")
  local uiList = List_Items:GetComponent("UIList")
  uiList.itemCount = showCount
  uiList:Resize()
  local uiItems = uiList.children
  for i = 1, #uiItems do
    local uiItem = uiItems[i]
    local isLastOne = i == #uiItems
    local isReceive = curTurn >= ticketAwardCfg[i].accumulateTurnCount
    local isShowDetail = false
    if nextTurn == -1 then
      isShowDetail = true
    elseif i <= activityCfg.initFlagCount then
      isShowDetail = true
    elseif curTurn >= ticketAwardCfg[activityCfg.initFlagCount].accumulateTurnCount then
      isShowDetail = nextTurn >= ticketAwardCfg[i].accumulateTurnCount
    else
      isShowDetail = false
    end
    self:FillTicketInfo(i, uiItem, ticketAwardCfg[i], activityCfg.nengLiangQiIconId, activityCfg.nengLiangQiItemId, isShowDetail, isReceive, isLastOne)
    local pos = uiItem.localPosition
  end
  local targetIdx = -1
  if nextIdx == -1 then
    targetIdx = #uiItems
  else
    targetIdx = nextIdx - MonkeyRunOuterAwardPanel.SHOW_GET_TICKET_NUM
  end
  local targetItem = uiItems[targetIdx]
  if targetItem ~= nil then
    GameUtil.AddGlobalTimer(0.1, true, function()
      if self.uiObjs == nil then
        return
      end
      local icon = targetItem:FindDirect("Img_Common_" .. targetIdx)
      local pos = targetItem.localPosition.y + icon:GetComponent("UIWidget").height / 2
      Scrollview:GetComponent("UIScrollView"):SetDragDistance(0, -pos, false)
    end)
  end
end
def.method("number", "userdata", "table", "number", "number", "boolean", "boolean", "boolean").FillTicketInfo = function(self, idx, item, cfg, itemIconId, itemId, isShowDetail, isReceive, isLastOne)
  if item == nil or cfg == nil then
    return
  end
  local Img_Common = item:FindDirect("Img_Common_" .. idx)
  local Label_CommonNum = item:FindDirect("Label_CommonNum_" .. idx)
  local Img_Finish = item:FindDirect("Img_Finish_" .. idx)
  local Label_Num = item:FindDirect("Label_Num_" .. idx)
  local Sprite = item:FindDirect("Sprite_" .. idx)
  GUIUtils.FillIcon(Img_Common:GetComponent("UITexture"), itemIconId)
  GUIUtils.FillIcon(Img_Finish:GetComponent("UITexture"), itemIconId)
  GUIUtils.SetTextureEffect(Img_Common:GetComponent("UITexture"), GUIUtils.Effect.Gray)
  self.itemTipHelper:RegisterItem2ShowTip(itemId, item)
  if isReceive then
    GUIUtils.SetActive(Img_Common, false)
    GUIUtils.SetActive(Label_CommonNum, false)
    GUIUtils.SetActive(Img_Finish, true)
  else
    GUIUtils.SetActive(Img_Common, true)
    GUIUtils.SetActive(Label_CommonNum, true)
    GUIUtils.SetActive(Img_Finish, false)
  end
  if cfg.ticketCount ~= 1 then
    GUIUtils.SetText(Label_CommonNum, cfg.ticketCount)
  else
    GUIUtils.SetText(Label_CommonNum, "")
  end
  if isShowDetail then
    GUIUtils.SetText(Label_Num, string.format(textRes.activity[812], cfg.accumulateTurnCount))
  else
    GUIUtils.SetText(Label_Num, "?")
  end
  GUIUtils.SetActive(Sprite, not isLastOne)
end
def.method().UpdateHeroMoveRoundData = function(self)
  local curActivityId = MonkeyRunMgr.Instance():GetCurrentActivityId()
  local activityCfg = MonkeyRunUtils.GetMonkeyRunActivityCfgById(curActivityId)
  local ticketAwardCfg = MonkeyRunUtils.GetActivityTicketAwardCfg(curActivityId)
  local awardData = MonkeyRunMgr.Instance():GetCurActivityMonkeyRunOutData()
  local curTurn = awardData and awardData:GetAccumulateTurnCount() or 0
  local nextTurn = -1
  local nextIdx = -1
  for i = 1, #ticketAwardCfg do
    if nextTurn == -1 and curTurn < ticketAwardCfg[i].accumulateTurnCount then
      nextTurn = ticketAwardCfg[i].accumulateTurnCount
      nextIdx = i
      break
    end
  end
  local turnTips = string.format(textRes.activity[811], curTurn)
  GUIUtils.SetText(self.uiObjs.Label_RunNum, turnTips)
  if nextTurn == -1 then
    GUIUtils.SetText(self.uiObjs.Label_Need, textRes.activity[834])
  else
    GUIUtils.SetText(self.uiObjs.Label_Need, string.format(textRes.activity[831], nextTurn - curTurn))
  end
end
def.method().UpdateGameTime = function(self)
  local ActivityInterface = require("Main.activity.ActivityInterface")
  local curActivityId = MonkeyRunMgr.Instance():GetCurrentActivityId()
  local openTime, activeTimeList, closeTime = ActivityInterface.Instance():getActivityStatusChangeTime(curActivityId)
  local curTime = _G.GetServerTime()
  local timeStr = ""
  if closeTime <= curTime then
    timeStr = textRes.activity[40]
  elseif openTime > curTime then
    timeStr = textRes.activity[51]
  else
    timeStr = _G.SeondsToTimeText(closeTime - curTime)
  end
  GUIUtils.SetText(self.uiObjs.Label_TimeName, textRes.activity[832])
  GUIUtils.SetText(self.uiObjs.Label_TimeNum, string.format(textRes.activity[833], timeStr))
end
def.method().UpdateGameCost = function(self)
  local Img_ItemGet = self.uiObjs.Group_Bottom:FindDirect("Img_ItemGet")
  local Img_Icon = Img_ItemGet:FindDirect("Img_Icon")
  local Label_Number = Img_ItemGet:FindDirect("Label_Number")
  local Label_ItemName = self.uiObjs.Group_Bottom:FindDirect("Label_ItemName")
  local curActivityId = MonkeyRunMgr.Instance():GetCurrentActivityId()
  local activityCfg = MonkeyRunUtils.GetMonkeyRunActivityCfgById(curActivityId)
  local itemBase = ItemUtils.GetItemBase(activityCfg.mainItemId)
  if itemBase ~= nil then
    GUIUtils.FillIcon(Img_Icon:GetComponent("UITexture"), itemBase.icon)
    local itemCount = ItemModule.Instance():GetItemCountById(activityCfg.mainItemId) + ItemModule.Instance():GetItemCountById(activityCfg.subItemId)
    GUIUtils.SetText(Label_Number, string.format("%d/%d", activityCfg.itemCount, itemCount))
    if self.useYuanbao then
      local ItemConsumeHelper = require("Main.Item.ItemConsumeHelper")
      ItemConsumeHelper.Instance():GetItemYuanBaoPrice(activityCfg.mainItemId, function(price)
        if self.uiObjs == nil then
          return
        end
        if self.useYuanbao then
          GUIUtils.SetText(Label_ItemName, string.format(textRes.activity[814], price))
        end
      end)
    else
      GUIUtils.SetText(Label_ItemName, itemBase.name)
    end
  end
  self.uiObjs.Btn_YuanbaoUse:GetComponent("UIToggle").value = self.useYuanbao
end
def.method("userdata").ShowCostItemTips = function(self, obj)
  local curActivityId = MonkeyRunMgr.Instance():GetCurrentActivityId()
  local activityCfg = MonkeyRunUtils.GetMonkeyRunActivityCfgById(curActivityId)
  if activityCfg ~= nil then
    ItemTipsMgr.Instance():ShowBasicTipsWithGO(activityCfg.mainItemId, obj, 0, true)
  end
end
def.method("boolean").SetUseYuanbao = function(self, useYuanbao)
  self.useYuanbao = useYuanbao
  self:UpdateGameCost()
  if useYuanbao then
    Toast(textRes.activity[825])
  end
end
def.method("number").BuyRunTimes = function(self, count)
  if count <= 0 then
    return
  end
  local curActivityId = MonkeyRunMgr.Instance():GetCurrentActivityId()
  local activityCfg = MonkeyRunUtils.GetMonkeyRunActivityCfgById(curActivityId)
  if activityCfg == nil then
    warn("moneky run activity is nil :" .. curActivityId)
    return
  end
  local needItemCount = activityCfg.itemCount * count
  local itemCount = ItemModule.Instance():GetItemCountById(activityCfg.mainItemId) + ItemModule.Instance():GetItemCountById(activityCfg.subItemId)
  if needItemCount <= itemCount then
    MonkeyRunMgr.Instance():DrawOutAward(count, false, 0)
  else
    local function queryPriceToBuyItem()
      local ItemConsumeHelper = require("Main.Item.ItemConsumeHelper")
      ItemConsumeHelper.Instance():GetItemYuanBaoPrice(activityCfg.mainItemId, function(price)
        local needYuanbao = price * math.max(0, needItemCount - itemCount)
        MonkeyRunMgr.Instance():DrawOutAward(count, true, needYuanbao)
      end)
    end
    if self.useYuanbao then
      queryPriceToBuyItem()
    else
      require("GUI.CommonConfirmDlg").ShowConfirm(textRes.activity[821], textRes.activity[822], function(selection, tag)
        if self.uiObjs == nil then
          return
        end
        if selection == 1 then
          self:SetUseYuanbao(true)
        end
      end, nil)
    end
  end
end
def.method("table").ShowAwardResult = function(self, awards)
  local btnName = ""
  if #awards == 1 then
    btnName = textRes.activity[823]
  else
    btnName = textRes.activity[824]
  end
  local MonkeyRunAwardResultPanel = require("Main.activity.MonkeyRun.ui.MonkeyRunAwardResultPanel")
  MonkeyRunAwardResultPanel.Instance():ShowOuterAwardPanel(awards, function()
    if self.uiObjs == nil then
      return
    end
    self:CheckToShowTicketEffect()
  end, btnName, function()
    if self.uiObjs == nil then
      return
    end
    self:BuyRunTimes(#awards)
  end)
end
def.method().CheckToShowTicketEffect = function(self)
  if self.uiObjs == nil then
    return
  end
  if self.needEffectToUpdateTicket and self:IsShow() then
    self:SetDelayToShowEffect(false)
    self:PlayTicketEffectAndUpdateData()
  end
end
def.method().UpdateInnerGameBtnStatus = function(self)
  local awardData = MonkeyRunMgr.Instance():GetCurActivityMonkeyRunOutData()
  local curTicketCount = awardData and awardData:GetTicketCount() or 0
  local Label_Name = self.uiObjs.Btn_Reward:FindDirect("Label_Name")
  local Label_Flag = self.uiObjs.Btn_Reward:FindDirect("Group_Flag/Label_Flag")
  GUIUtils.SetText(Label_Flag, curTicketCount)
  self.uiObjs.Btn_Reward:GetComponent("TweenScale").enabled = curTicketCount > 0
  GUIUtils.SetActive(self.uiObjs.Reward_Effect, curTicketCount > 0)
end
def.method().PlayTicketEffectAndUpdateData = function(self)
  local EFFECT_FLY_TIME = 0.6
  local curActivityId = MonkeyRunMgr.Instance():GetCurrentActivityId()
  local activityCfg = MonkeyRunUtils.GetMonkeyRunActivityCfgById(curActivityId)
  local ticketAwardCfg = MonkeyRunUtils.GetActivityTicketAwardCfg(curActivityId)
  local Scrollview = self.uiObjs.Group_Left:FindDirect("Group_Slider/Group_Item/Scrollview")
  local List_Items = Scrollview:FindDirect("List_Items")
  local uiList = List_Items:GetComponent("UIList")
  local uiItems = uiList.children
  local awardData = MonkeyRunMgr.Instance():GetCurActivityMonkeyRunOutData()
  local curTurn = awardData and awardData:GetAccumulateTurnCount() or 0
  local idx = 1
  for i = 1, #ticketAwardCfg do
    if ticketAwardCfg[i].accumulateTurnCount == curTurn then
      idx = i
      break
    elseif curTurn < ticketAwardCfg[i].accumulateTurnCount then
      idx = i - 1
      break
    end
  end
  local ticketItem = uiItems[idx]
  if ticketItem == nil then
    self:UpdateGameTickets()
    GUIUtils.SetActive(self.uiObjs.Group_Effect, false)
    self:MarkNeedTicketEffectToUpdate(false)
    self:UpdateInnerGameBtnStatus()
    return
  end
  self:UpdateGameTickets()
  GUIUtils.SetActive(self.uiObjs.Group_Effect, true)
  GameUtil.AddGlobalTimer(0.1, true, function()
    if self.uiObjs == nil then
      return
    end
    local beginWorldPos = ticketItem.transform:TransformPoint(Vector.Vector3.new(0, 0, 0))
    local beginPos = self.uiObjs.Img_Bg0.transform:InverseTransformPoint(beginWorldPos)
    local endWorldPos = self.uiObjs.Btn_Reward.transform:TransformPoint(Vector.Vector3.new(0, 0, 0))
    local endPos = self.uiObjs.Img_Bg0.transform:InverseTransformPoint(endWorldPos)
    local tp = TweenPosition.Begin(self.uiObjs.Group_Effect, EFFECT_FLY_TIME, endPos)
    tp.from = beginPos
  end)
  GameUtil.AddGlobalTimer(EFFECT_FLY_TIME, true, function()
    if self.uiObjs == nil then
      return
    end
    GUIUtils.SetActive(self.uiObjs.Group_Effect, false)
    self:MarkNeedTicketEffectToUpdate(false)
    self:UpdateInnerGameBtnStatus()
  end)
end
def.method("boolean").SetDelayToShowEffect = function(self, b)
  self.delayToShowEffect = b
end
def.method("boolean").MarkNeedTicketEffectToUpdate = function(self, b)
  self.needEffectToUpdateTicket = b
end
def.override("boolean").OnShow = function(self, s)
  if s then
    if self.heroModel ~= nil then
      self.heroModel:Play(ActionName.Stand)
    end
    self:CheckToShowTicketEffect()
  end
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Img_ItemGet" then
    self:OnClickCostItem(obj)
  elseif id == "Btn_YuanbaoUse" then
    self:OnClickUseYuanbao()
  elseif id == "Btn_Shop" then
    self:OnClickBtnShop()
  elseif id == "Btn_Reward" then
    self:OnClickBtnAward()
  elseif id == "Btn_Help" then
    self:OnClickBtnTips()
  elseif id == "Btn_Run" then
    self:OnClickBtnRun()
  elseif id == "Btn_10Run" then
    self:OnClickBtnRun10()
  else
    self.itemTipHelper:CheckItem2ShowTip(id)
  end
end
def.method("userdata").OnClickCostItem = function(self, obj)
  self:ShowCostItemTips(obj)
end
def.method().OnClickUseYuanbao = function(self)
  self:SetUseYuanbao(not self.useYuanbao)
end
def.method().OnClickBtnShop = function(self)
  MonkeyRunMgr.Instance():QueryToShowExchangeShop()
end
def.method().OnClickBtnAward = function(self)
  MonkeyRunMgr.Instance():QueryToShowInnerAwardPanel()
end
def.method().OnClickBtnTips = function(self)
  local curActivityId = MonkeyRunMgr.Instance():GetCurrentActivityId()
  local activityCfg = MonkeyRunUtils.GetMonkeyRunActivityCfgById(curActivityId)
  GUIUtils.ShowHoverTip(activityCfg.outerDrawTipId, 0, 0)
end
def.method().OnClickBtnRun = function(self)
  self:BuyRunTimes(1)
end
def.method().OnClickBtnRun10 = function(self)
  self:BuyRunTimes(10)
end
def.static("table", "table").OnBagInfoSynchronized = function(params, context)
  local self = instance
  self:UpdateGameCost()
end
def.static("table", "table").OnMoveHero = function(params, context)
  local self = instance
  local step = params.step
  self:MoveHero(step)
  self:UpdateHeroMoveRoundData()
end
def.static("table", "table").OnGetAward = function(params, context)
  local self = instance
  local awards = params
  local totalStep = 0
  for i = 1, #awards do
    totalStep = totalStep + awards[1].step
  end
  local delayTime = 0
  local MonkeyRunAwardResultPanel = require("Main.activity.MonkeyRun.ui.MonkeyRunAwardResultPanel")
  if MonkeyRunAwardResultPanel.Instance():IsShow() then
    delayTime = 0
  else
    delayTime = totalStep / MonkeyRunOuterAwardPanel.MOVE_GRID_PER_FRAME * 1 / 30 + 0.2
  end
  self:SetDelayToShowEffect(true)
  GameUtil.AddGlobalTimer(delayTime, true, function()
    if self.uiObjs == nil then
      return
    end
    self:ShowAwardResult(awards)
    MonkeyRunMgr.Instance():GetOutAward()
  end)
end
def.static("table", "table").OnGetTicket = function(params, context)
  local self = instance
  local delta = params.delta
  if self.delayToShowEffect then
    self:MarkNeedTicketEffectToUpdate(true)
  else
    self:PlayTicketEffectAndUpdateData()
  end
end
def.static("table", "table").OnTicketChange = function(params, context)
  local self = instance
  self:UpdateInnerGameBtnStatus()
end
def.static("table", "table").OnOpenChange = function(params, context)
  local self = instance
  if not MonkeyRunMgr.Instance():IsActivityOpened() then
    Toast(textRes.activity[830])
    self:DestroyPanel()
  end
end
return MonkeyRunOuterAwardPanel.Commit()
