local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local MonkeyRunInnerAwardPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = require("Main.Item.ItemModule")
local Vector = require("Types.Vector")
local MonkeyRunMgr = require("Main.activity.MonkeyRun.MonkeyRunMgr")
local MonkeyRunUtils = require("Main.activity.MonkeyRun.MonkeyRunUtils")
local ECUIModel = require("Model.ECUIModel")
local AwardItemTipHelper = require("Main.Award.AwardItemTipHelper")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local def = MonkeyRunInnerAwardPanel.define
def.field("table").uiObjs = nil
def.field("table").awardModels = nil
def.field("number").prepareShootTimerId = 0
def.field("number").shootTimerId = 0
def.field(ECUIModel).heroModel = nil
def.field("table").bulletOriginPos = nil
def.field("boolean").canShoot = true
def.field(AwardItemTipHelper).itemTipHelper = nil
def.field("boolean").isDrag = false
local instance
def.static("=>", MonkeyRunInnerAwardPanel).Instance = function()
  if instance == nil then
    instance = MonkeyRunInnerAwardPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self.m_panel and not self.m_panel.isnil then
    return
  end
  self:SetModal(true)
  self:CreatePanel(RESPATH.PREFAB_MONKEYRUN_INNER_PANEL, 1)
end
def.override().OnCreate = function(self)
  if self.m_panel == nil then
    return
  end
  self:InitUI()
  self:FillAwardItems()
  self:UpdateAwardStatus()
  self:UpdateTicketData()
  self:ShowActivityTime()
  self:InitMonkeyBullet()
  self:ResetMonkeyPos()
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_MonkeyRun_Ticket_Change, MonkeyRunInnerAwardPanel.OnTicketChange)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_MonkeyRun_Get_Inner_Award, MonkeyRunInnerAwardPanel.OnGetAward)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_MonkeyRun_OpenChange, MonkeyRunInnerAwardPanel.OnOpenChange)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_MonkeyRun_Inner_Award_Error, MonkeyRunInnerAwardPanel.OnError)
end
def.override().OnDestroy = function(self)
  self:StopPrepareShoot()
  self.uiObjs = nil
  if self.awardModels ~= nil then
    for idx, model in pairs(self.awardModels) do
      model:Destroy()
    end
    self.awardModels = nil
  end
  if self.heroModel ~= nil then
    self.heroModel:Destroy()
    self.heroModel = nil
  end
  self.bulletOriginPos = nil
  self.canShoot = true
  self.itemTipHelper = nil
  self.isDrag = false
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_MonkeyRun_Ticket_Change, MonkeyRunInnerAwardPanel.OnTicketChange)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_MonkeyRun_Get_Inner_Award, MonkeyRunInnerAwardPanel.OnGetAward)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_MonkeyRun_OpenChange, MonkeyRunInnerAwardPanel.OnOpenChange)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_MonkeyRun_Inner_Award_Error, MonkeyRunInnerAwardPanel.OnError)
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.Group_Item = self.uiObjs.Img_Bg0:FindDirect("Group_Item")
  self.uiObjs.Group_Bottom = self.uiObjs.Img_Bg0:FindDirect("Group_Bottom")
  self.uiObjs.Group_Power = self.uiObjs.Group_Bottom:FindDirect("Group_Power")
  self.uiObjs.Img_ItemGet = self.uiObjs.Group_Bottom:FindDirect("Img_ItemGet")
  self.uiObjs.Group_Date = self.uiObjs.Img_Bg0:FindDirect("Group_Date")
  self.uiObjs.Item_Bullet = self.uiObjs.Group_Bottom:FindDirect("Item_Bullet")
  self.uiObjs.Btn_Run = self.uiObjs.Group_Bottom:FindDirect("Btn_Run")
  self.uiObjs.ShootEffect = self.uiObjs.Group_Bottom:FindDirect("UI_Panel_MonkeyRun_InGame_HuoJianFaShe")
  self.uiObjs.MonkeyEffect = self.uiObjs.Item_Bullet:FindDirect("UI_Panel_MonkeyRun_InGame_HuoJianWeiBa")
  self.uiObjs.RunEffect = self.uiObjs.Btn_Run:FindDirect("Group_Fire")
  GUIUtils.SetActive(self.uiObjs.ShootEffect, false)
  GUIUtils.SetActive(self.uiObjs.MonkeyEffect, false)
  GUIUtils.SetActive(self.uiObjs.RunEffect, false)
  self.awardModels = {}
  self.itemTipHelper = AwardItemTipHelper()
end
def.method().FillAwardItems = function(self)
  self.itemTipHelper:Clear()
  local curActivityId = MonkeyRunMgr.Instance():GetCurrentActivityId()
  local activityCfg = MonkeyRunUtils.GetMonkeyRunActivityCfgById(curActivityId)
  local lotteryViewCfgId = activityCfg.lotteryViewCfgId
  local lotterCfg = ItemUtils.GetLotteryViewRandomCfg(lotteryViewCfgId)
  for i = 1, #lotterCfg.itemIds do
    local itemId = lotterCfg.itemIds[i]
    local item = self.uiObjs.Group_Item:FindDirect(string.format("Point_%02d", i))
    if item ~= nil then
      self.itemTipHelper:RegisterItem2ShowTip(itemId, item)
      self:FillAwardInfo(item, itemId)
    end
  end
end
def.method("userdata", "number").FillAwardInfo = function(self, item, itemId)
  if item == nil then
    return
  end
  local itemBase = ItemUtils.GetItemBase(itemId)
  if itemBase == nil then
    return
  end
  local Model = item:FindDirect("Model")
  local Icon = item:FindDirect("Icon")
  local Img_Get = item:FindDirect("Img_Get")
  local Label_Name = item:FindDirect("Img_Label/Label_Name")
  local itemColor = HtmlHelper.NameColor[itemBase.namecolor]
  local text = string.format("[%s]%s[-]", itemColor, itemBase.name)
  GUIUtils.SetText(Label_Name, text)
  local curActivityId = MonkeyRunMgr.Instance():GetCurrentActivityId()
  local modelId, modelScale, modelAngle = MonkeyRunUtils.GetMonkeyRunAwardModelCfgId(curActivityId, itemId)
  if modelId == 0 then
    GUIUtils.SetActive(Model, false)
    GUIUtils.SetActive(Icon, true)
    GUIUtils.FillIcon(Icon:GetComponent("UITexture"), itemBase.icon)
  else
    GUIUtils.SetActive(Model, true)
    GUIUtils.SetActive(Icon, false)
    do
      local uiModel = Model:GetComponent("UIModel")
      local itemName = item.name
      if self.awardModels[itemName] == nil then
        do
          local modelpath, modelcolor = GetModelPath(modelId)
          if modelpath == nil or modelpath == "" then
            return
          end
          local function AfterModelLoad(uiModel, awardModel)
            uiModel.modelGameObject = awardModel.m_model
            if uiModel.mCanOverflow ~= nil then
              uiModel.mCanOverflow = true
              local camera = uiModel:get_modelCamera()
              camera:set_orthographic(true)
            end
            local scale = 1
            if modelScale ~= 0 then
              scale = modelScale / 10000
            end
            awardModel:SetScale(scale)
            awardModel:SetDir(modelAngle)
            awardModel:SetAlpha(1)
          end
          local awardModel = ECUIModel.new(modelId)
          awardModel.m_bUncache = true
          awardModel:LoadUIModel(modelpath, function(ret)
            if self.awardModels == nil or self.awardModels[itemName] == nil or not awardModel.m_model or awardModel.m_model.isnil then
              return
            end
            AfterModelLoad(uiModel, awardModel)
          end)
          self.awardModels[itemName] = awardModel
        end
      end
    end
  end
  GUIUtils.SetActive(Img_Get, false)
end
def.method().UpdateAwardStatus = function(self)
  local curActivityId = MonkeyRunMgr.Instance():GetCurrentActivityId()
  local activityCfg = MonkeyRunUtils.GetMonkeyRunActivityCfgById(curActivityId)
  local innerData = MonkeyRunMgr.Instance():GetCurActivityMonkeyRunInnerData()
  local lotteryViewCfgId = activityCfg.lotteryViewCfgId
  local lotterCfg = ItemUtils.GetLotteryViewRandomCfg(lotteryViewCfgId)
  for i = 1, #lotterCfg.itemIds do
    local itemId = lotterCfg.itemIds[i]
    local item = self.uiObjs.Group_Item:FindDirect(string.format("Point_%02d", i))
    if item ~= nil then
      do
        local Img_Get = item:FindDirect("Img_Get")
        local Sprite = item:FindDirect("Sprite")
        local Icon = item:FindDirect("Icon")
        local Img_Label = item:FindDirect("Img_Label")
        local model = self.awardModels[item.name]
        if innerData then
          if innerData:IsAwardIndexHited(i) then
            GUIUtils.SetActive(Img_Get, true)
            Sprite:GetComponent("UISprite").alpha = 0.47058823529411764
            Icon:GetComponent("UITexture").alpha = 0.47058823529411764
            Img_Label:GetComponent("UISprite").alpha = 0.47058823529411764
            if model ~= nil then
              if model:IsInLoading() then
                model:AddOnLoadCallback("InnerAwardSetAlpha", function()
                  if self.uiObjs == nil then
                    return
                  end
                  model:ChangeAlpha(0.47058823529411764)
                end)
              else
                model:ChangeAlpha(0.47058823529411764)
              end
            end
          else
            GUIUtils.SetActive(Img_Get, false)
            Sprite:GetComponent("UISprite").alpha = 1
            Icon:GetComponent("UITexture").alpha = 1
            Img_Label:GetComponent("UISprite").alpha = 1
            if model ~= nil then
              if model:IsInLoading() then
                model:AddOnLoadCallback("InnerAwardSetAlpha", function()
                  if self.uiObjs == nil then
                    return
                  end
                  model:ChangeAlpha(1)
                end)
              else
                model:ChangeAlpha(1)
              end
            end
          end
        else
          GUIUtils.SetActive(Img_Get, true)
          Sprite:GetComponent("UISprite").alpha = 1
          Icon:GetComponent("UITexture").alpha = 1
          Img_Label:GetComponent("UISprite").alpha = 1
          if model ~= nil then
            if model:IsInLoading() then
              model:AddOnLoadCallback("InnerAwardSetAlpha", function()
                if self.uiObjs == nil then
                  return
                end
                model:ChangeAlpha(1)
              end)
            else
              model:ChangeAlpha(1)
            end
          end
        end
      end
    end
  end
end
def.method().UpdateTicketData = function(self)
  local Img_Icon = self.uiObjs.Img_ItemGet:FindDirect("Img_Icon")
  local Label_Number = self.uiObjs.Img_ItemGet:FindDirect("Label_Number")
  local curActivityId = MonkeyRunMgr.Instance():GetCurrentActivityId()
  local activityCfg = MonkeyRunUtils.GetMonkeyRunActivityCfgById(curActivityId)
  local innerData = MonkeyRunMgr.Instance():GetCurActivityMonkeyRunInnerData()
  local curCount = innerData and innerData:GetCurrentTicketCount() or 0
  GUIUtils.SetText(Label_Number, string.format("%d/%d", activityCfg.ticketCount, curCount))
  GUIUtils.FillIcon(Img_Icon:GetComponent("UITexture"), activityCfg.nengLiangQiIconId)
  self.itemTipHelper:RegisterItem2ShowTip(activityCfg.nengLiangQiItemId, self.uiObjs.Img_ItemGet)
  GUIUtils.SetActive(self.uiObjs.RunEffect, curCount > 0)
end
def.method().ShowActivityTime = function(self)
  local Label_Name = self.uiObjs.Group_Date:FindDirect("Label_Name")
  local Label_Date = self.uiObjs.Group_Date:FindDirect("Label_Date")
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
  GUIUtils.SetText(Label_Name, textRes.activity[832])
  GUIUtils.SetText(Label_Date, string.format(textRes.activity[833], timeStr))
end
def.method().InitMonkeyBullet = function(self)
  local Model = self.uiObjs.Item_Bullet:FindDirect("Model")
  local uiModel = Model:GetComponent("UIModel")
  local curActivityId = MonkeyRunMgr.Instance():GetCurrentActivityId()
  local activityCfg = MonkeyRunUtils.GetMonkeyRunActivityCfgById(curActivityId)
  local heroeModelId = activityCfg.modelId
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
end
def.method().ResetMonkeyPos = function(self)
  if self.bulletOriginPos == nil then
    self.bulletOriginPos = self.uiObjs.Item_Bullet.localPosition
  else
    self.uiObjs.Item_Bullet.localPosition = self.bulletOriginPos
  end
end
def.method().PrepareShoot = function(self)
  self:StopPrepareShoot()
  self:SetShoopEffectVisible(false)
  self:ResetMonkeyPos()
  local Img_Fornt = self.uiObjs.Group_Power:FindDirect("Img_Fornt")
  local progress = 100
  local normalSpeed = 10
  local highSpeed = 25
  local change = normalSpeed
  self.prepareShootTimerId = GameUtil.AddGlobalTimer(0.016666666666666666, false, function()
    progress = progress + change
    Img_Fornt:GetComponent("UISprite").fillAmount = progress / 100
    if progress > 105 then
      change = -normalSpeed
    elseif progress < -5 then
      change = normalSpeed
    elseif progress >= 25 and progress <= 75 then
      if change > 0 then
        change = highSpeed
      else
        change = -highSpeed
      end
    elseif change > 0 then
      change = normalSpeed
    else
      change = -normalSpeed
    end
  end)
end
def.method().StopPrepareShoot = function(self)
  if self.prepareShootTimerId ~= 0 then
    GameUtil.RemoveGlobalTimer(self.prepareShootTimerId)
    self.prepareShootTimerId = 0
  end
end
def.method().ShootMonkey = function(self)
  self:StopPrepareShoot()
  if self:CheckCanShootAndToast() then
    self:SetBtnShootAvailable(false)
    MonkeyRunMgr.Instance():DrawInnerAward()
  end
end
def.method("=>", "boolean").CheckCanShootAndToast = function(self)
  local activityId = MonkeyRunMgr.Instance():GetCurrentActivityId()
  local activityCfg = MonkeyRunUtils.GetMonkeyRunActivityCfgById(activityId)
  if activityCfg == nil then
    Toast(textRes.activity[820])
    return false
  end
  local innerData = MonkeyRunMgr.Instance():GetCurActivityMonkeyRunInnerData()
  if innerData == nil then
    Toast(textRes.activity[820])
    return false
  end
  if innerData:GetCurrentTicketCount() < activityCfg.ticketCount then
    Toast(textRes.activity[829])
    return false
  end
  return true
end
def.method("boolean").SetShoopEffectVisible = function(self, visible)
  if visible then
    GUIUtils.SetActive(self.uiObjs.ShootEffect, true)
    GUIUtils.SetActive(self.uiObjs.MonkeyEffect, true)
  else
    GUIUtils.SetActive(self.uiObjs.ShootEffect, false)
    GUIUtils.SetActive(self.uiObjs.MonkeyEffect, false)
  end
end
def.method("number").MoveMonkeyToAward = function(self, awardIndex)
  local item = self.uiObjs.Group_Item:FindDirect(string.format("Point_%02d", awardIndex))
  if item ~= nil then
    do
      local GUIMan = require("GUI.ECGUIMan")
      local uiRoot = GUIMan.Instance().m_uiRootCom
      local uiscreenWidth = Screen.width * uiRoot:GetPixelSizeAdjustment_int(Screen.height)
      local uiscreenHeight = uiRoot.activeHeight
      local upSpeed = uiscreenHeight * 3
      local dropSpeed = uiscreenHeight * 2
      local topPoint = uiscreenHeight * 1.2
      local targetWorldPos = item.transform:TransformPoint(Vector.Vector3.new(0, 0, 0))
      local targetPos = self.uiObjs.Group_Bottom.transform:InverseTransformPoint(targetWorldPos)
      local midllePos = Vector.Vector3.new(self.bulletOriginPos.x, topPoint, self.bulletOriginPos.z)
      local dropPos = Vector.Vector3.new(targetPos.x, topPoint, targetPos.z)
      local endPos = Vector.Vector3.new(targetPos.x, targetPos.y, targetPos.z)
      local upDuration = math.abs(midllePos.y - self.bulletOriginPos.y) / upSpeed
      local up = TweenPosition.Begin(self.uiObjs.Item_Bullet, upDuration, midllePos)
      up.from = self.bulletOriginPos
      local downDuration = math.abs(midllePos.y - endPos.y) / dropSpeed
      GameUtil.AddGlobalTimer(upDuration, true, function()
        if self.uiObjs == nil then
          return
        end
        local down = TweenPosition.Begin(self.uiObjs.Item_Bullet, downDuration, endPos)
        down.from = dropPos
      end)
      GameUtil.AddGlobalTimer(upDuration + downDuration, true, function()
        if self.uiObjs == nil then
          return
        end
        self:UpdateAwardStatus()
        self.heroModel:StopCurrentAnim()
        self.heroModel:CrossFade(ActionName.Idle1, 0.2)
        self.heroModel:CrossFadeQueued(ActionName.Stand, 0.2)
      end)
    end
  end
end
def.method("boolean").SetBtnShootAvailable = function(self, b)
  self.canShoot = b
end
def.method("=>", "boolean").CanShoot = function(self)
  return self.canShoot
end
def.method("table").ShowAwardResult = function(self, awards)
  local MonkeyRunAwardResultPanel = require("Main.activity.MonkeyRun.ui.MonkeyRunAwardResultPanel")
  MonkeyRunAwardResultPanel.Instance():ShowInnerAwardPanel(awards, function()
    if self.uiObjs == nil then
      return
    end
    self:SetBtnShootAvailable(true)
  end, "", nil)
end
def.method("string", "boolean").onPress = function(self, id, state)
  if id == "Btn_Run" then
    if not self:CanShoot() then
      if not state then
        Toast(textRes.activity[835])
      end
      return
    end
    if state then
      self:PrepareShoot()
    else
      self:ShootMonkey()
    end
  end
end
def.override("boolean").OnShow = function(self, s)
  if s and self.heroModel ~= nil then
    self.heroModel:Play(ActionName.Stand)
  end
end
def.method("string").onDragStart = function(self, id)
  if self.awardModels ~= nil and self.awardModels[id] ~= nil then
    self.isDrag = true
  end
end
def.method("string").onDragEnd = function(self, id)
  if self.awardModels ~= nil and self.awardModels[id] ~= nil and self.isDrag then
    self.isDrag = true
  end
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self.awardModels ~= nil and self.awardModels[id] ~= nil and self.isDrag then
    local model = self.awardModels[id]
    model:SetDir(model:GetDir() - dx / 2)
  end
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Help" then
    self:OnClickBtnTips()
  else
    self.itemTipHelper:CheckItem2ShowTip(id)
  end
end
def.method().OnClickBtnTips = function(self)
  local curActivityId = MonkeyRunMgr.Instance():GetCurrentActivityId()
  local activityCfg = MonkeyRunUtils.GetMonkeyRunActivityCfgById(curActivityId)
  GUIUtils.ShowHoverTip(activityCfg.innerDrawTipId, 0, 0)
end
def.static("table", "table").OnTicketChange = function(params, context)
  local self = instance
  self:UpdateTicketData()
end
def.static("table", "table").OnGetAward = function(params, context)
  local self = instance
  local hitIndex = params.hitIndex
  self:SetShoopEffectVisible(true)
  self:MoveMonkeyToAward(hitIndex + 1)
  local awards = params.awards
  GameUtil.AddGlobalTimer(2, true, function()
    if self.uiObjs == nil then
      return
    end
    self:ShowAwardResult(awards)
    MonkeyRunMgr.Instance():GetInnerAward()
  end)
end
def.static("table", "table").OnOpenChange = function(params, context)
  local self = instance
  if not MonkeyRunMgr.Instance():IsActivityOpened() then
    self:DestroyPanel()
  end
end
def.static("table", "table").OnError = function(params, context)
  local self = instance
  self:SetBtnShootAvailable(true)
end
return MonkeyRunInnerAwardPanel.Commit()
