local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
_G.RecordStatus = {
  StartRecord = 0,
  Recording = 1,
  CancleOp = 2,
  Sending = 3,
  Cancled = 4,
  SendSuccess = 5,
  SendFailure = 6,
  TranslateFailure = 7
}
local ECRecordTip = Lplus.Extend(ECPanelBase, "ECRecordTip")
local m_Instance
do
  local def = ECRecordTip.define
  def.field("table").mPanels = BLANK_TABLE_INIT
  def.field("table").mVolumePros = BLANK_TABLE_INIT
  def.field("number").mStatus = RecordStatus.StartRecord
  def.field("number").mVolume = 0
  def.field("number").mTimerID = 0
  def.field("boolean").mIsWaitClose = false
  def.field("number").mMsgId = 0
  def.method().Create = function(self)
  end
  def.method().Close = function(self)
    self:DestroyPanel()
  end
  def.override().OnDestroy = function(self)
    self.mStatus = RecordStatus.StartRecord
    self.mVolume = 0
    self.mIsWaitClose = false
    self.mMsgId = 0
    if self.mTimerID ~= 0 then
      GameUtil.RemoveGlobalTimer(self.mTimerID)
      self.mTimerID = 0
    end
  end
  def.override().OnCreate = function(self)
    if self.m_panel then
      self:InitControls()
      self:SwitchPanel()
    end
  end
  def.method().InitControls = function(self)
    self.mPanels[RecordStatus.StartRecord] = self:FindChild("Widget/SubPanel_SayTo")
    self.mPanels[RecordStatus.Recording] = self:FindChild("Widget/SubPanel_Send")
    self.mPanels[RecordStatus.CancleOp] = self:FindChild("Widget/SubPanel_Cancel")
    self.mPanels[RecordStatus.Sending] = self:FindChild("Widget/SubPanel_OnSend")
    self.mPanels[RecordStatus.SendSuccess] = self:FindChild("Widget/SubPanel_SendSuccess")
    self.mPanels[RecordStatus.SendFailure] = self:FindChild("Widget/SubPanel_SendLose")
    self.mPanels[RecordStatus.TranslateFailure] = self:FindChild("Widget/SubPanel_TranslateLose")
    self.mVolumePros[RecordStatus.StartRecord] = self:FindChild("Widget/SubPanel_SayTo/Progress_Voice")
    self.mVolumePros[RecordStatus.Recording] = self:FindChild("Widget/SubPanel_Send/Progress_Voice")
    self.mVolumePros[RecordStatus.CancleOp] = self:FindChild("Widget/SubPanel_Cancel/Progress_Voice")
    self.mVolumePros[RecordStatus.Sending] = self:FindChild("Widget/SubPanel_OnSend/Progress_Voice")
    self.mVolumePros[RecordStatus.SendSuccess] = self:FindChild("Widget/SubPanel_SendSuccess/Progress_Voice")
    self.mVolumePros[RecordStatus.SendFailure] = self:FindChild("Widget/SubPanel_SendLose/Progress_Voice")
    self.mVolumePros[RecordStatus.TranslateFailure] = self:FindChild("Widget/SubPanel_TranslateLose/Progress_Voice")
  end
  def.method().SwitchPanel = function(self)
    if not self:IsStatusValid(self.mStatus) then
      warn(("status(%d) is invalid"):format(self.mStatus))
      return
    end
    local status = self.mStatus
    for k, v in pairs(self.mPanels) do
      v:SetActive(false)
    end
    if status == RecordStatus.StartRecord then
      self.mPanels[RecordStatus.StartRecord]:SetActive(true)
    elseif status == RecordStatus.Recording then
      self.mPanels[RecordStatus.Recording]:SetActive(true)
    elseif status == RecordStatus.CancleOp then
      self.mPanels[RecordStatus.CancleOp]:SetActive(true)
    elseif status == RecordStatus.Sending then
      self.mPanels[RecordStatus.Sending]:SetActive(true)
    elseif status == RecordStatus.Cancled then
      self.mPanels[RecordStatus.Cancled]:SetActive(true)
      self:WaitToClose(1)
    elseif status == RecordStatus.SendSuccess then
      self.mPanels[RecordStatus.SendSuccess]:SetActive(true)
      self:WaitToClose(1)
    elseif status == RecordStatus.SendFailure then
      self.mPanels[RecordStatus.SendFailure]:SetActive(true)
      self:WaitToClose(1)
    end
    self.mVolumePros[self.mStatus]:GetComponent("UIProgressBar").value = self.mVolume / 100
  end
  def.method("number").WaitToClose = function(self, seconds)
    if seconds == 0 then
      self:Close()
      return
    end
    if self.mTimerID ~= 0 then
      GameUtil.RemoveGlobalTimer(self.mTimerID)
      self.mTimerID = 0
    end
    self.mIsWaitClose = true
    self.mTimerID = GameUtil.AddGlobalTimer(seconds, true, function()
      if self.mIsWaitClose then
        self:Close()
      end
    end)
  end
  def.method("number", "number").ColseByType = function(self, status, seconds)
    if self.mStatus == status then
      self:WaitToClose(seconds)
    end
  end
  def.method("number").UpdateTipId = function(self, id)
    self.mMsgId = id
  end
  def.method("number", "=>", "boolean").IsStatusValid = function(self, status)
    return self.mPanels[status] ~= nil
  end
  def.static("=>", ECRecordTip).Instance = function()
    if m_Instance == nil then
      m_Instance = ECRecordTip()
      m_Instance.m_depthLayer = GUIDEPTH.TOP
    end
    return m_Instance
  end
  def.method("number").Popup = function(self, status)
    if self.mStatus == status and self.m_panel then
      return
    end
    if self.mIsWaitClose then
      self.mIsWaitClose = false
    end
    self.mStatus = status
    if not self.m_panel then
      self:Create()
    else
      self:SwitchPanel()
    end
  end
  def.method("number").UpdateVolume = function(self, vol)
    if not self.m_panel or self.m_panel.isnil then
      return
    end
    if not self:IsStatusValid(self.mStatus) then
      warn(("status(%d) is invalid"):format(self.mStatus))
      return
    end
    self.mVolume = vol
    self.mVolumePros[self.mStatus]:GetComponent("UIProgressBar").value = vol / 100
  end
end
ECRecordTip.Commit()
return ECRecordTip
