local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local NewDailySignInPanel = Lplus.Extend(ECPanelBase, "NewDailySignInPanel")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local Vector = require("Types.Vector")
local ItemColor = require("consts.mzm.gsp.item.confbean.Color")
local DailySignInMgr = require("Main.Award.mgr.DailySignInMgr")
local NewDailySignInMgr = require("Main.Award.mgr.NewDailySignInMgr")
local ECMSDK = require("ProxySDK.ECMSDK")
local RelationShipChainMgr = require("Main.RelationShipChain.RelationShipChainMgr")
local AwardUtils = require("Main.Award.AwardUtils")
local AwardItemTipHelper = require("Main.Award.AwardItemTipHelper")
local ChessCellAwardType = require("consts.mzm.gsp.signprecious.confbean.ChessCellAwardType")
local ECUIModel = require("Model.ECUIModel")
local def = NewDailySignInPanel.define
def.const("number").DICE_NORMAL_SPEED = 5
def.const("number").DICE_ROTATE_SPEED = 40
def.const("number").GRID_RUN_DURATION = 0.5
def.const("number").MAX_DICE_NUMBER = 6
def.field("table").uiObjs = nil
def.field(AwardItemTipHelper).itemTipHelper = nil
def.field(ECUIModel).heroModel = nil
def.field(ECUIModel).diceModel = nil
def.field("number").diceRunSpeed = 0
def.field("number").diceResultTimer = 0
def.field("number").curStandCell = 0
def.field("table").heroMovePath = nil
def.field("boolean").disableOperate = false
local instance
def.static("=>", NewDailySignInPanel).Instance = function()
  if instance == nil then
    instance = NewDailySignInPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_PRIZE_NEW_QIANDAO, 0)
end
def.override().OnCreate = function(self)
  if self.m_panel == nil then
    return
  end
  self:InitUI()
  self:AjustCtrl()
  self:InitHeroModel()
  self:InitDiceModel()
  self:FillDailySignInInfo()
  self:CheckUnReceivedBoxAwardAndToast()
  Timer:RegisterIrregularTimeListener(self.Update, self)
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.DAILY_SIGN_IN_STATE_UPDATE, NewDailySignInPanel.OnSignInStateUpdate)
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.NEW_DAILY_SIGN_MOVE, NewDailySignInPanel.OnDiceMoveStep)
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.NEW_DAILY_SIGN_RESET, NewDailySignInPanel.OnHeroPositionReset)
end
def.override().OnDestroy = function(self)
  Timer:RemoveIrregularTimeListener(self.Update)
  if self.heroModel ~= nil then
    self.heroModel:Destroy()
    self.heroModel = nil
  end
  if self.diceModel ~= nil then
    self.diceModel:Destroy()
    self.diceModel = nil
  end
  if self.diceResultTimer ~= 0 then
    GameUtil.RemoveGlobalTimer(self.diceResultTimer)
    self.diceResultTimer = 0
  end
  self.uiObjs = nil
  self.itemTipHelper = nil
  self.diceRunSpeed = 0
  self.heroMovePath = nil
  self.disableOperate = false
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.DAILY_SIGN_IN_STATE_UPDATE, NewDailySignInPanel.OnSignInStateUpdate)
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.NEW_DAILY_SIGN_MOVE, NewDailySignInPanel.OnDiceMoveStep)
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.NEW_DAILY_SIGN_RESET, NewDailySignInPanel.OnHeroPositionReset)
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Group_Qiandao = self.m_panel:FindDirect("Group_Qiandao")
  self.uiObjs.Group_Up = self.uiObjs.Group_Qiandao:FindDirect("Group_Up")
  self.uiObjs.Group_Down = self.uiObjs.Group_Qiandao:FindDirect("Group_Down")
  self.uiObjs.Group_QianDao = self.uiObjs.Group_Qiandao:FindDirect("Group_QianDao")
  self.uiObjs.Label_Month = self.uiObjs.Group_Up:FindDirect("Img_BgTitle")
  self.uiObjs.Label_Qian = self.uiObjs.Group_Up:FindDirect("Group_Qian/Label_Qian")
  self.uiObjs.Label_BuQian = self.uiObjs.Group_Up:FindDirect("Group_BuQian/Label_BuQian")
  self.uiObjs.Group_QQ = self.uiObjs.Group_Up:FindDirect("Group_QQ")
  self.uiObjs.Group_WX = self.uiObjs.Group_Up:FindDirect("Group_Wechat")
  self.uiObjs.DailyAward = self.uiObjs.Group_Down:FindDirect("Item_001")
  self.uiObjs.diceBg = self.uiObjs.Group_Down:FindDirect("Img_Bg")
  self.uiObjs.diceModel = self.uiObjs.diceBg:FindDirect("Model")
  self.uiObjs.diceResult = self.uiObjs.diceBg:FindDirect("Img_Result")
  self.uiObjs.Group_Btn = self.uiObjs.Group_Down:FindDirect("Group_Btn")
  self.uiObjs.Btn_QD = self.uiObjs.Group_Btn:FindDirect("Btn_QD")
  self.uiObjs.Btn_BQ = self.uiObjs.Group_Btn:FindDirect("Btn_BQ")
  self.uiObjs.Img_YQD = self.uiObjs.Group_Btn:FindDirect("Img_YQD")
  self.uiObjs.ChessGrid = self.uiObjs.Group_QianDao:FindDirect("Group_Item")
  self.uiObjs.heroModelGroup = self.uiObjs.ChessGrid:FindDirect("Img_BgModel")
  self.uiObjs.heroModel = self.uiObjs.heroModelGroup:FindDirect("Model")
  self.itemTipHelper = AwardItemTipHelper()
end
def.method().AjustCtrl = function(self)
  self.uiObjs.DailyAward.name = "Sign_Award"
  if self.uiObjs.heroModel:GetComponent("BoxCollider") ~= nil then
    self.uiObjs.heroModel:GetComponent("BoxCollider"):Destroy()
  end
  self.uiObjs.heroModel.localPosition = Vector.Vector3.new(0, self.uiObjs.heroModel:GetComponent("UIWidget").height / 2, 0)
  GUIUtils.SetActive(self.uiObjs.diceResult, false)
end
def.method().InitHeroModel = function(self)
  local diceModelId = constant.CSignPreciousConsts.turn_table_walk_model_id
  local uiModel = self.uiObjs.heroModel:GetComponent("UIModel")
  local modelpath, modelcolor = GetModelPath(diceModelId)
  if modelpath == nil or modelpath == "" then
    return false
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
    self.heroModel = ECUIModel.new(diceModelId)
    self.heroModel.m_bUncache = true
    self.heroModel:LoadUIModel(modelpath, function(ret)
      if not self.heroModel or not self.heroModel.m_model or self.heroModel.m_model.isnil then
        return
      end
      AfterModelLoad()
    end)
  end
  self:UpdateHeroToCurrentPos()
end
def.method().UpdateHeroToCurrentPos = function(self)
  local curCell = NewDailySignInMgr.Instance():GetCurrentCell()
  self.curStandCell = curCell
  local curStanGrid = self.uiObjs.ChessGrid:FindDirect(string.format("Item_%03d", curCell))
  self.uiObjs.heroModelGroup.localPosition = curStanGrid.localPosition
end
def.method().InitDiceModel = function(self)
  local diceModelId = constant.CSignPreciousConsts.dice_model_id
  local uiModel = self.uiObjs.diceModel:GetComponent("UIModel")
  local modelpath, modelcolor = GetModelPath(diceModelId)
  if modelpath == nil or modelpath == "" then
    return false
  end
  if self.diceModel then
    self.diceModel:Destroy()
  end
  local function AfterModelLoad()
    uiModel.modelGameObject = self.diceModel.m_model
    if uiModel.mCanOverflow ~= nil then
      uiModel.mCanOverflow = true
      local camera = uiModel:get_modelCamera()
      camera:set_orthographic(true)
    end
    self.diceModel:StopCurrentAnim()
    self.diceModel:SetScale(9)
  end
  if not self.diceModel then
    self.diceModel = ECUIModel.new(diceModelId)
    self.diceModel.m_bUncache = true
    self.diceModel:LoadUIModel(modelpath, function(ret)
      if not self.diceModel or not self.diceModel.m_model or self.diceModel.m_model.isnil then
        return
      end
      AfterModelLoad()
    end)
  end
  self:NormalRunDice()
end
def.method().SpeedRunDice = function(self)
  self.diceRunSpeed = NewDailySignInPanel.DICE_ROTATE_SPEED
end
def.method().NormalRunDice = function(self)
  self.diceRunSpeed = NewDailySignInPanel.DICE_NORMAL_SPEED
end
def.method().FillDailySignInInfo = function(self)
  self.itemTipHelper:Clear()
  self:FillTopBasicInfo()
  self:UpdateExtraAwardView()
  self:FillMonthDailyAwardInfo()
  self:SetBtnQiandaoStatus()
  self:FillBoxGrid()
end
def.method().FillTopBasicInfo = function(self)
  local signInStates = DailySignInMgr.Instance():GetSignInStates()
  GUIUtils.SetSprite(self.uiObjs.Label_Month, signInStates.date.month)
  GUIUtils.SetText(self.uiObjs.Label_Qian, signInStates.signedDays)
  GUIUtils.SetText(self.uiObjs.Label_BuQian, signInStates.canRedressTimes)
end
def.method().UpdateExtraAwardView = function(self)
  local groupQQ = self.uiObjs.Group_QQ
  local groupWX = self.uiObjs.Group_WX
  local loginTypeInfo, qqVipInfo = RelationShipChainMgr.GetPrivilegeAwardCfg()
  local vipLevel = RelationShipChainMgr.GetSepicalVIPLevel()
  GUIUtils.SetActive(groupQQ, _G.LoginPlatform == MSDK_LOGIN_PLATFORM.QQ and not GameUtil.IsEvaluation() and not ClientCfg.IsOtherChannel())
  GUIUtils.SetActive(groupWX, ECMSDK.IsWXGameCenter() and not GameUtil.IsEvaluation() and not ClientCfg.IsOtherChannel())
  GUIUtils.SetActive(groupQQ:FindDirect("Group_ExtraPrize"), vipLevel ~= 0)
  GUIUtils.SetActive(groupQQ:FindDirect("Group_ExtraPrize/Img_SvipIcon"), vipLevel == 2)
  GUIUtils.SetActive(groupQQ:FindDirect("Group_ExtraPrize/Img_VipIcon"), vipLevel == 1)
  GUIUtils.SetActive(groupQQ:FindDirect("Group_GameCenterPrize"), ECMSDK.IsQQGameCenter())
  if loginTypeInfo then
    GUIUtils.SetText(groupQQ:FindDirect("Group_GameCenterPrize/Label_GameCenterNumber"), tostring(loginTypeInfo.sign_extra_award_num))
    GUIUtils.SetText(groupWX:FindDirect("Label_ExtraNumber"), tostring(loginTypeInfo.sign_extra_award_num))
  end
  if qqVipInfo then
    GUIUtils.SetText(groupQQ:FindDirect("Group_ExtraPrize/Label_ExtraNumber"), tostring(qqVipInfo.sign_extra_award_num))
  end
end
def.method().FillMonthDailyAwardInfo = function(self)
  local dailySignMgr = DailySignInMgr.Instance()
  local signInStates = dailySignMgr:GetSignInStates()
  local monthAwards = dailySignMgr:GetWholeMonthAwardList(signInStates.date.year, signInStates.date.month)
  local todayAward
  if not signInStates.isTodaySigned then
    todayAward = monthAwards[signInStates.signedDays + 1]
  elseif dailySignMgr:IsHaveCanRedressDays() then
    todayAward = monthAwards[signInStates.signedDays + 1]
  else
    todayAward = monthAwards[signInStates.signedDays]
  end
  self:FillItemInfo(self.uiObjs.DailyAward, todayAward.itemId, todayAward.num)
end
def.method("userdata", "number", "number").FillItemInfo = function(self, item, itemId, itemNum)
  local itemBase = ItemUtils.GetItemBase(itemId)
  local Img_BgIcon = item:FindDirect("Img_BgIcon")
  local Texture_Icon = Img_BgIcon:FindDirect("Texture_Icon")
  local Label_Num = Img_BgIcon:FindDirect("Label_Num")
  if itemBase ~= nil then
    GUIUtils.FillIcon(Texture_Icon:GetComponent("UITexture"), itemBase.icon)
    GUIUtils.SetText(Label_Num, itemNum)
    self.itemTipHelper:RegisterItem2ShowTip(itemId, item)
  else
    GUIUtils.FillIcon(Texture_Icon:GetComponent("UITexture"), 0)
    GUIUtils.SetText(Label_Num, "0")
  end
end
def.method().SetBtnQiandaoStatus = function(self)
  local dailySignMgr = DailySignInMgr.Instance()
  local signInStates = dailySignMgr:GetSignInStates()
  if not signInStates.isTodaySigned then
    GUIUtils.SetActive(self.uiObjs.Btn_QD, true)
    GUIUtils.SetActive(self.uiObjs.Btn_BQ, false)
    GUIUtils.SetActive(self.uiObjs.Img_YQD, false)
    GUIUtils.SetLightEffect(self.uiObjs.diceBg, GUIUtils.Light.Round)
  elseif dailySignMgr:IsHaveCanRedressDays() then
    GUIUtils.SetActive(self.uiObjs.Btn_QD, false)
    GUIUtils.SetActive(self.uiObjs.Btn_BQ, true)
    GUIUtils.SetActive(self.uiObjs.Img_YQD, false)
    GUIUtils.SetLightEffect(self.uiObjs.diceBg, GUIUtils.Light.Round)
  else
    GUIUtils.SetActive(self.uiObjs.Btn_QD, false)
    GUIUtils.SetActive(self.uiObjs.Btn_BQ, false)
    GUIUtils.SetActive(self.uiObjs.Img_YQD, true)
    GUIUtils.SetLightEffect(self.uiObjs.diceBg, GUIUtils.Light.None)
  end
end
def.method().DisableAllQiandaoBtn = function(self)
  self.disableOperate = true
end
def.method().EnableAllQiandaoBtn = function(self)
  self.disableOperate = false
  self:SetBtnQiandaoStatus()
end
def.method().FillBoxGrid = function(self)
  GUIUtils.SetActive(self.uiObjs.ChessGrid:FindDirect("Item_000"), false)
  local newDailySignInMgr = NewDailySignInMgr.Instance()
  for i = 1, 50 do
    local gridItem = self.uiObjs.ChessGrid:FindDirect(string.format("Item_%03d", i))
    if gridItem then
      if newDailySignInMgr:GetChessItemAward(i) then
        self:FillChessItemInfo(gridItem, newDailySignInMgr:GetChessItemAward(i))
      elseif newDailySignInMgr:GetChessBoxAward(i) then
        self:FillChessBoxInfo(gridItem, newDailySignInMgr:GetChessBoxAward(i))
      else
        self:FillEmptyItemInfo(gridItem)
      end
    end
  end
end
def.method("userdata", "table").FillChessItemInfo = function(self, gridItem, itemAward)
  self:SetAsItemContainer(gridItem)
  self:FillItemInfo(gridItem, itemAward.item_id, itemAward.item_count)
end
def.method("userdata", "table").FillChessBoxInfo = function(self, gridItem, boxAward)
  self:SetAsBoxContainer(gridItem)
  local Texture_Icon = gridItem:FindDirect("Img_BgIcon/Texture_Icon")
  if boxAward.cell_award_type == ChessCellAwardType.DIAMOND_BOX then
    GUIUtils.FillIcon(Texture_Icon:GetComponent("UITexture"), constant.CSignPreciousConsts.diamond_box_icon_id)
  elseif boxAward.cell_award_type == ChessCellAwardType.GOLD_BOX then
    GUIUtils.FillIcon(Texture_Icon:GetComponent("UITexture"), constant.CSignPreciousConsts.gold_box_icon_id)
  elseif boxAward.cell_award_type == ChessCellAwardType.SILVER_BOX then
    GUIUtils.FillIcon(Texture_Icon:GetComponent("UITexture"), constant.CSignPreciousConsts.silver_box_icon_id)
  else
    GUIUtils.FillIcon(Texture_Icon:GetComponent("UITexture"), 0)
  end
end
def.method("userdata").FillEmptyItemInfo = function(self, gridItem)
  self:SetAsItemContainer(gridItem)
  self:FillItemInfo(gridItem, 0, 0)
end
def.method("userdata").SetAsItemContainer = function(self, gridItem)
  local Img_BgIcon = gridItem:FindDirect("Img_BgIcon")
  local Texture_Icon = Img_BgIcon:FindDirect("Texture_Icon")
  local Label_Num = Img_BgIcon:FindDirect("Label_Num")
  local Img_Select = gridItem:FindDirect("Img_Select")
  local Img_BgIcon1 = Img_BgIcon:FindDirect("Img_BgIcon1")
  GUIUtils.SetActive(Label_Num, false)
  local borderSize = gridItem:GetComponent("UIWidget").width
  Texture_Icon:GetComponent("UITexture").width = borderSize * 0.6
  Texture_Icon:GetComponent("UITexture").height = borderSize * 0.6
  Img_BgIcon1:GetComponent("UISprite").enabled = false
end
def.method("userdata").SetAsBoxContainer = function(self, gridItem)
  local Img_BgIcon = gridItem:FindDirect("Img_BgIcon")
  local Texture_Icon = Img_BgIcon:FindDirect("Texture_Icon")
  local Label_Num = Img_BgIcon:FindDirect("Label_Num")
  local Img_Select = gridItem:FindDirect("Img_Select")
  local Img_BgIcon1 = Img_BgIcon:FindDirect("Img_BgIcon1")
  GUIUtils.SetActive(Label_Num, false)
  local borderSize = gridItem:GetComponent("UIWidget").width
  Texture_Icon:GetComponent("UITexture").width = borderSize * 0.9
  Texture_Icon:GetComponent("UITexture").height = borderSize * 0.9
  Img_BgIcon1:GetComponent("UISprite").enabled = true
end
def.method("number").ShowDiceRotateAndResult = function(self, step)
  self:DisableAllQiandaoBtn()
  self:SpeedRunDice()
  self:DelayToShowDiceResult(step)
end
def.method("number").DelayToShowDiceResult = function(self, step)
  if self.diceResultTimer == 0 then
    self.diceResultTimer = GameUtil.AddGlobalTimer(constant.CSignPreciousConsts.dice_rotate_seconds, true, function()
      self.diceResultTimer = 0
      self:NormalRunDice()
      self:ShowDiceResultAndMoveHero(step)
    end)
  end
end
def.method("number").ShowDiceResultAndMoveHero = function(self, step)
  GUIUtils.SetActive(self.uiObjs.diceModel, false)
  GUIUtils.SetActive(self.uiObjs.diceResult, true)
  GUIUtils.SetSprite(self.uiObjs.diceResult, string.format("Result_%02d", step))
  GameUtil.AddGlobalTimer(2, true, function()
    if self.m_created then
      self:ResetDiceState()
      self:MoveHero(step)
    end
  end)
end
def.method().ResetDiceState = function(self)
  GUIUtils.SetActive(self.uiObjs.diceModel, true)
  GUIUtils.SetActive(self.uiObjs.diceResult, false)
end
def.method("number").MoveHero = function(self, step)
  self.heroModel:Play(ActionName.Run)
  self.heroMovePath = {}
  for i = 1, step do
    local path = {}
    path.endCell = (self.curStandCell - 1 + i) % constant.CSignPreciousConsts.cell_total_num + 1
    path.duration = NewDailySignInPanel.GRID_RUN_DURATION
    table.insert(self.heroMovePath, path)
  end
end
def.method().MoveEnd = function(self)
  self:ResetHeroStatus()
  self:EnableAllQiandaoBtn()
  self:CheckToReceiveAwardOrOpenBox()
end
def.method().ResetHeroStatus = function(self)
  self.heroModel:SetDir(-180)
  self.heroModel:Play(ActionName.Stand)
end
def.method().CheckToReceiveAwardOrOpenBox = function(self)
  local curCell = NewDailySignInMgr.Instance():GetCurrentCell()
  local newDailySignInMgr = NewDailySignInMgr.Instance()
  if newDailySignInMgr:GetChessItemAward(curCell) then
    self:TryToGetItemAward()
  elseif newDailySignInMgr:GetChessBoxAward(curCell) then
    self:CheckToShowBoxAward()
  end
end
def.method().TryToGetItemAward = function(self)
  NewDailySignInMgr.Instance():GetItemAward()
end
def.method().CheckToShowBoxAward = function(self)
  Toast(textRes.Award[153])
  GameUtil.AddGlobalTimer(1, true, function()
    NewDailySignInMgr.Instance():TryToGetBoxAward()
  end)
end
def.method("=>", "number").GetNextBoxAwardCell = function(self)
  local newDailySignInMgr = NewDailySignInMgr.Instance()
  for i = 1, NewDailySignInPanel.MAX_DICE_NUMBER do
    local cell = (self.curStandCell - 1 + i) % constant.CSignPreciousConsts.cell_total_num + 1
    if newDailySignInMgr:GetChessBoxAward(cell) then
      return cell
    end
  end
  return -1
end
def.method("number").ConfrimToOpenBoxAward = function(self, cell)
  local NewDailySignInConfirmPanel = require("Main.Award.ui.NewDailySignInConfirmPanel")
  NewDailySignInConfirmPanel.Instance():ShowConfirmPanel(cell)
end
def.method().CheckUnReceivedBoxAwardAndToast = function(self)
  local newDailySignInMgr = NewDailySignInMgr.Instance()
  if newDailySignInMgr:HasPrecious() then
    Toast(textRes.Award[156])
    GameUtil.AddGlobalTimer(2, true, function()
      NewDailySignInMgr.Instance():TryToGetBoxAward()
    end)
  end
end
def.method().ResetHeroPosition = function(self)
  self.heroMovePath = nil
  self:ResetHeroStatus()
  self:UpdateHeroToCurrentPos()
end
def.method("number").Update = function(self, tick)
  self:UpdateDiceRotate()
  self:UpdateHeroMovePath(tick)
end
def.method().UpdateDiceRotate = function(self)
  if self.diceModel then
    local angle = (self.diceModel.m_ang + self.diceRunSpeed) % 360
    self.diceModel:SetDir(angle)
  end
end
def.method("number").UpdateHeroMovePath = function(self, tick)
  if self.uiObjs.heroModelGroup and self.heroMovePath ~= nil and #self.heroMovePath > 0 then
    local curMovePath = self.heroMovePath[1]
    local targetCell = self.uiObjs.ChessGrid:FindDirect(string.format("Item_%03d", curMovePath.endCell))
    local curPos = self.uiObjs.heroModelGroup.localPosition
    local endPos = targetCell.localPosition
    local targetPos = curPos + (endPos - curPos) / curMovePath.duration * tick
    if curMovePath.dir == nil then
      local dir = endPos - curPos
      local delta = 5
      if delta < dir.x then
        curMovePath.dir = -270
      elseif dir.x < -delta then
        curMovePath.dir = -90
      elseif delta < dir.y then
        curMovePath.dir = 0
      elseif dir.y < -delta then
        curMovePath.dir = -180
      else
        curMovePath.dir = -180
      end
    end
    self.heroModel:SetDir(curMovePath.dir)
    self.uiObjs.heroModelGroup.localPosition = targetPos
    curMovePath.duration = curMovePath.duration - tick
    if 0 >= curMovePath.duration then
      self.curStandCell = curMovePath.endCell
      table.remove(self.heroMovePath, 1)
    end
    if #self.heroMovePath == 0 then
      self:MoveEnd()
    end
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Tips" then
    self:OnBtnTipsClick()
  elseif id == "Btn_QD" or id == "Btn_BQ" or id == "Model" or id == "Img_Bg" then
    self:OnBtnQiandaoClick()
  elseif string.find(id, "Item_") then
    self:OnBtnGridClick(id)
  else
    self.itemTipHelper:CheckItem2ShowTip(id)
  end
end
def.method().OnBtnTipsClick = function(self)
  local tipId = AwardUtils.GetAwardConsts("TIP_ID")
  local tipContent = require("Main.Common.TipsHelper").GetHoverTip(tipId)
  local CommonUITipsDlg = require("GUI.CommonUITipsDlg")
  CommonUITipsDlg.Instance():ShowDlg(tipContent, {x = 0, y = 0})
end
def.method().OnBtnQiandaoClick = function(self)
  local newDailySignInMgr = NewDailySignInMgr.Instance()
  if self.disableOperate or newDailySignInMgr:HasPrecious() then
    Toast(textRes.Award[157])
    return
  end
  local level = AwardUtils.GetAwardConsts("CAN_SIGN_LEVEL")
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if level > heroProp.level then
    Toast(textRes.Award[55])
    return
  end
  local dailySignMgr = DailySignInMgr.Instance()
  local signInStates = dailySignMgr:GetSignInStates()
  if signInStates.isTodaySigned and not dailySignMgr:IsHaveCanRedressDays() then
    return
  end
  local cell = self:GetNextBoxAwardCell()
  if cell > 0 and NewDailySignInMgr.Instance():IsReceivedFirstBox() then
    self:ConfrimToOpenBoxAward(cell)
  else
    local index = signInStates.signedDays + 1
    local result = DailySignInMgr.Instance():SignInOrRedress(index)
    if result == DailySignInMgr.CResult.SUCCESS then
      local ECMSDK = require("ProxySDK.ECMSDK")
      ECMSDK.SendTLogToServer(_G.TLOGTYPE.DAILYSIGN, {index})
    elseif result == DailySignInMgr.CResult.NOT_SIGN_IN or result == DailySignInMgr.CResult.NOT_FIRST_REDRESS_DAY then
      Toast(textRes.Award[61])
    end
  end
end
def.method("string").OnBtnGridClick = function(self, id)
  local index = tonumber(string.sub(id, #"Item_" + 1))
  if index ~= nil then
    if NewDailySignInMgr.Instance():GetChessBoxAward(index) then
      local cfg = NewDailySignInMgr.Instance():GetChessBoxAward(index)
      require("Main.Award.ui.NewDailySignInBoxTips").Instance():ShowPanel(cfg.gold_precious_cfg_id, cfg.cell_award_type)
    else
      self.itemTipHelper:CheckItem2ShowTip(id)
    end
  end
end
def.static("table", "table").OnSignInStateUpdate = function(params, context)
  instance:FillDailySignInInfo()
end
def.static("table", "table").OnDiceMoveStep = function(params, context)
  instance:ShowDiceRotateAndResult(params.step)
end
def.static("table", "table").OnHeroPositionReset = function(params, context)
  instance:ResetHeroPosition()
end
return NewDailySignInPanel.Commit()
