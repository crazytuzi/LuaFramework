local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local QingAnResponsePanel = Lplus.Extend(ECPanelBase, "QingAnResponsePanel")
local GUIUtils = require("GUI.GUIUtils")
local ShituModule = Lplus.ForwardDeclare("ShituModule")
local TipsHelper = require("Main.Common.TipsHelper")
local ShituData = require("Main.Shitu.ShituData")
local def = QingAnResponsePanel.define
local instance
def.field("string").content = ""
def.field("userdata").currentApprenticeId = nil
def.field("userdata").timerBtnLabel = nil
def.field("number").timerId = -1
def.field("number").leftTime = 0
def.field("userdata").currentSessionId = nil
def.static("=>", QingAnResponsePanel).Instance = function()
  if instance == nil then
    instance = QingAnResponsePanel()
  end
  return instance
end
def.method("userdata", "userdata", "string").ShowResponsePanel = function(self, sessionId, roleId, msg)
  if self.m_panel ~= nil then
    return
  end
  self.currentSessionId = sessionId
  self.content = msg
  self.currentApprenticeId = roleId
  self:CreatePanel(RESPATH.PREFAB_QINGAN_PANEL, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:StartTimer()
end
def.method().InitUI = function(self)
  local Group_SayHello = self.m_panel:FindDirect("Img_Bg0/Group_SayHello")
  local Group_Response = self.m_panel:FindDirect("Img_Bg0/Group_Response")
  Group_SayHello:SetActive(false)
  Group_Response:SetActive(true)
  local Label_Info = Group_Response:FindDirect("Label_Info")
  local Label_Content = Group_Response:FindDirect("Label_Content")
  local shituData = ShituData.Instance()
  local apprentice = shituData:GetNowApprenticeById(self.currentApprenticeId)
  if apprentice ~= nil then
    GUIUtils.SetText(Label_Info, string.format(TipsHelper.GetHoverTip(constant.ShiTuConsts.masterPayRespectTips), apprentice.roleName))
  end
  GUIUtils.SetText(Label_Content, _G.TrimIllegalChar(self.content))
  self.timerBtnLabel = Group_Response:FindDirect("Btn_Later/Label_Later")
end
def.method("boolean").ResponseQingAn = function(self, op)
  ShituModule.ResponseQingAn(self.currentSessionId, self.currentApprenticeId, op)
  self:Close()
end
def.method().UpdateLaterBtn = function(self)
  GUIUtils.SetText(self.timerBtnLabel, string.format(textRes.Shitu[41], self.leftTime))
end
def.method().StartTimer = function(self)
  self.leftTime = constant.ShiTuConsts.masterReplyRespectTimes
  self:UpdateLaterBtn()
  self.timerId = GameUtil.AddGlobalTimer(1, false, function()
    self.leftTime = self.leftTime - 1
    self:UpdateLaterBtn()
    if self.leftTime <= 0 then
      self:Close()
    end
  end)
end
def.method().RemoveTimer = function(self)
  if self.timerId ~= 0 then
    GameUtil.RemoveGlobalTimer(self.timerId)
    self.timerId = 0
  end
end
def.method("=>", "boolean").IsHandingQingAn = function(self)
  return self.m_panel ~= nil
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:ResponseQingAn(false)
  elseif id == "Btn_Later" then
    self:ResponseQingAn(false)
  elseif id == "Btn_Guide" then
    self:ResponseQingAn(true)
  end
end
def.method().Close = function(self)
  self:DestroyPanel()
end
def.override().OnDestroy = function(self)
  self:RemoveTimer()
  self.content = ""
  self.currentApprenticeId = nil
  self.timerBtnLabel = nil
  self.leftTime = 0
  self.currentSessionId = nil
end
QingAnResponsePanel.Commit()
return QingAnResponsePanel
