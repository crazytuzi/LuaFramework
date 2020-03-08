local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local InteractMgr = require("Main.Shitu.interact.InteractMgr")
local InteractProtocols = require("Main.Shitu.interact.InteractProtocols")
local InteractUtils = require("Main.Shitu.interact.InteractUtils")
local ShiTuConst = require("netio.protocol.mzm.gsp.shitu.ShiTuConst")
local RecommandMasterPanel = Lplus.Extend(ECPanelBase, "RecommandMasterPanel")
local def = RecommandMasterPanel.define
local instance
def.static("=>", RecommandMasterPanel).Instance = function()
  if instance == nil then
    instance = RecommandMasterPanel()
  end
  return instance
end
def.const("number").UPDATE_INTERVAL = 1
def.field("number")._timeCounter = 0
def.const("number").SHOW_COUNT = 3
def.field("table")._uiObjs = nil
def.field("number")._timerID = 0
def.field("userdata")._sessionId = nil
def.field("table")._roleInfos = nil
def.field("table")._models = nil
def.static("userdata", "table").ShowPanel = function(sessionId, recommands)
  if not InteractMgr.Instance():IsFeatrueRecommandOpen(false) then
    if self:IsShow() then
      self:DestroyPanel()
    end
    return
  end
  RecommandMasterPanel.Instance():_InitData(sessionId, recommands)
  if RecommandMasterPanel.Instance():IsShow() then
    RecommandMasterPanel.Instance():UpdateUI()
    return
  end
  instance:CreatePanel(RESPATH.PREFAB_RECOMMAND_MASTER_PANEL, 1)
end
def.method("userdata", "table")._InitData = function(self, sessionId, recommands)
  self._sessionId = sessionId
  self._roleInfos = recommands
end
def.override().OnCreate = function(self)
  self:SetModal(true)
  self:_InitUI()
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.Label_Countdown = self.m_panel:FindDirect("Img_Bg/Btn_Yes/Label")
  self._uiObjs.ModelGroups = {}
  local ModelGroup = {}
  ModelGroup.Group_Model = self.m_panel:FindDirect("Img_Bg/Group_Teacher/Img_TeacherInfor1")
  ModelGroup.Model_Obj = ModelGroup.Group_Model:FindDirect("Model_Teacher")
  ModelGroup.uiModel = ModelGroup.Model_Obj:GetComponent("UIModel")
  ModelGroup.Img_Sex = ModelGroup.Group_Model:FindDirect("Img_Sex")
  ModelGroup.Img_Class = ModelGroup.Group_Model:FindDirect("Img_Class")
  ModelGroup.Label_Level = ModelGroup.Group_Model:FindDirect("Label_Level")
  ModelGroup.Label_Name = ModelGroup.Group_Model:FindDirect("Label_Name")
  table.insert(self._uiObjs.ModelGroups, ModelGroup)
  ModelGroup = {}
  ModelGroup.Group_Model = self.m_panel:FindDirect("Img_Bg/Group_Teacher/Img_TeacherInfor2")
  ModelGroup.Model_Obj = ModelGroup.Group_Model:FindDirect("Model_Teacher")
  ModelGroup.uiModel = ModelGroup.Model_Obj:GetComponent("UIModel")
  ModelGroup.Img_Sex = ModelGroup.Group_Model:FindDirect("Img_Sex")
  ModelGroup.Img_Class = ModelGroup.Group_Model:FindDirect("Img_Class")
  ModelGroup.Label_Level = ModelGroup.Group_Model:FindDirect("Label_Level")
  ModelGroup.Label_Name = ModelGroup.Group_Model:FindDirect("Label_Name")
  table.insert(self._uiObjs.ModelGroups, ModelGroup)
  ModelGroup = {}
  ModelGroup.Group_Model = self.m_panel:FindDirect("Img_Bg/Group_Teacher/Img_TeacherInfor3")
  ModelGroup.Model_Obj = ModelGroup.Group_Model:FindDirect("Model_Teacher")
  ModelGroup.uiModel = ModelGroup.Model_Obj:GetComponent("UIModel")
  ModelGroup.Img_Sex = ModelGroup.Group_Model:FindDirect("Img_Sex")
  ModelGroup.Img_Class = ModelGroup.Group_Model:FindDirect("Img_Class")
  ModelGroup.Label_Level = ModelGroup.Group_Model:FindDirect("Label_Level")
  ModelGroup.Label_Name = ModelGroup.Group_Model:FindDirect("Label_Name")
  table.insert(self._uiObjs.ModelGroups, ModelGroup)
end
def.override("boolean").OnShow = function(self, show)
  self:HandleEventListeners(show)
  if show then
    self:UpdateUI()
  else
  end
end
def.method().UpdateUI = function(self)
  self:_ClearTimer()
  self:ShowReccomandMasters()
  self:ShowCountdown(constant.CMasterRecommendConsts.RECOMMEND_MASTER_COUNTDOWN_TIME)
  self._timerID = GameUtil.AddGlobalTimer(RecommandMasterPanel.UPDATE_INTERVAL, false, function()
    local countdown = constant.CMasterRecommendConsts.RECOMMEND_MASTER_COUNTDOWN_TIME - self._timeCounter
    self._timeCounter = self._timeCounter + 1
    if countdown > 0 then
      self:ShowCountdown(countdown)
    else
      self:DestroyPanel()
    end
  end)
end
def.method("number").ShowCountdown = function(self, countdown)
  local str = string.format(textRes.Shitu.Interact.RECOMMAND_MASTER_AGREE_COUNTDOWN, countdown)
  GUIUtils.SetText(self._uiObjs.Label_Countdown, str)
end
def.method().ShowReccomandMasters = function(self)
  self:DestoryModels()
  if self._roleInfos and #self._roleInfos == RecommandMasterPanel.SHOW_COUNT then
    self._models = {}
    for i = 1, RecommandMasterPanel.SHOW_COUNT do
      self._models[i] = InteractUtils.ShowRoleInfo(self._uiObjs.ModelGroups[i], self._roleInfos[i])
    end
  else
    listItem("[ERROR][InteractUtils:ShowActiveInfo] show failed! #self._roleInfos:", self._roleInfos and #self._roleInfos or 0)
  end
end
def.method().DestoryModels = function(self)
  for i = 1, RecommandMasterPanel.SHOW_COUNT do
    local uiModel = self._uiObjs.ModelGroups and self._uiObjs.ModelGroups[i].uiModel
    if uiModel then
      uiModel.modelGameObject = nil
    end
    local model = self._models and self._models[i]
    if model then
      model:Destroy()
    end
  end
  self._models = nil
end
def.override().OnDestroy = function(self)
  warn("[RecommandMasterPanel:OnDestroy] OnDestroy:", debug.traceback())
  self:DestoryModels()
  self:_ClearTimer()
  self._timeCounter = 0
  self._sessionId = nil
  self._roleInfos = nil
  self._uiObjs = nil
end
def.method()._ClearTimer = function(self)
  if self._timerID ~= 0 then
    GameUtil.RemoveGlobalTimer(self._timerID)
    self._timerID = 0
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Yes" then
    self:OnBtn_Yes()
  elseif id == "Btn_No" then
    self:OnBtn_No()
  end
end
def.method().OnBtn_Yes = function(self)
  self:DoAgree()
end
def.method().DoAgree = function(self)
  InteractProtocols.SendCAgreeOrRefuseMasterRecommendReq(ShiTuConst.AGREE_RECOMMEND, self._sessionId)
  self:DestroyPanel()
end
def.method().OnBtn_No = function(self)
  require("GUI.CommonConfirmDlg").ShowConfirm(textRes.Shitu.Interact.RECOMMAND_MASTER_CANCEL_CONFIRM_TITLE, textRes.Shitu.Interact.RECOMMAND_MASTER_CANCEL_CONFIRM, function(id, tag)
    if id == 1 then
      self:DoRefuse()
    end
  end, nil)
end
def.method().DoRefuse = function(self)
  InteractProtocols.SendCAgreeOrRefuseMasterRecommendReq(ShiTuConst.REFUSE_RECOMMEND, self._sessionId)
  self:DestroyPanel()
end
def.method("boolean").HandleEventListeners = function(self, isRigister)
  local eventFunc
  if isRigister then
    eventFunc = Event.RegisterEvent
  else
    eventFunc = Event.UnregisterEvent
  end
  if eventFunc then
  end
end
def.static("table", "table").OnMatchCountdownChange = function(param, context)
end
RecommandMasterPanel.Commit()
return RecommandMasterPanel
