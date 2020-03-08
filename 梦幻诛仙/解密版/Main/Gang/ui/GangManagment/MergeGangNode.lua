local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local GangData = require("Main.Gang.data.GangData")
local GangUtility = require("Main.Gang.GangUtility")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local MergeGangNode = Lplus.Extend(TabNode, "MergeGangNode")
local def = MergeGangNode.define
def.field("table").uiTbl = nil
def.field("number").state = 0
def.field("number").combineTime = 0
def.field("number").startTime = 0
def.const("table").GangMergeState = {
  NORMAL = 1,
  NONE = 2,
  APPLIED = 3,
  MERGING = 4
}
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
end
def.override().OnShow = function(self)
  self:InitUI()
  self:UpdateMergeState()
  self:UpdateUI()
end
def.method().InitUI = function(self)
  if not self.m_node or self.m_node.isnil then
    return
  end
  self.uiTbl = {}
  self.uiTbl.Label_Vitality = self.m_node:FindDirect("Img_Inputbg/Label_Number")
  self.uiTbl.Img_Slider = self.m_node:FindDirect("Img_SliderBg")
  self.uiTbl.Label_Time = self.m_node:FindDirect("Img_SliderBg/Label_Time")
  self.uiTbl.Label_Remain = self.m_node:FindDirect("Img_SliderBg/Label_ramain")
  self.uiTbl.Label_Sent = self.m_node:FindDirect("Label_SendRequest")
  self.uiTbl.Btn_CancelRequest = self.m_node:FindDirect("Btn_CancelRequest")
  self.uiTbl.Btn_CancelCombine = self.m_node:FindDirect("Btn_CancelCombine")
  self.uiTbl.Btn_List = self.m_node:FindDirect("Btn_List")
  self.uiTbl.Btn_Ruquest = self.m_node:FindDirect("Btn_Ruquest")
  self.uiTbl.Img_Red = self.m_node:FindDirect("Btn_Ruquest/Sprite")
  self.uiTbl.Img_Red:SetActive(GangData.Instance():IsHaveGangMergeApply())
end
def.method().UpdateUI = function(self)
  self:UpdateVitality()
  self:UpdateMergeFuncUI()
end
def.method().UpdateVitality = function(self)
  local vitality = GangData.Instance():GetVitality()
  self.uiTbl.Label_Vitality:GetComponent("UILabel"):set_text(vitality)
end
def.method().UpdateMergeFuncUI = function(self)
  if self.state == MergeGangNode.GangMergeState.MERGING then
    self.uiTbl.Img_Slider:SetActive(true)
    self.uiTbl.Label_Sent:SetActive(false)
    self.uiTbl.Btn_List:SetActive(true)
    self.uiTbl.Btn_CancelRequest:SetActive(false)
    self.uiTbl.Btn_CancelCombine:SetActive(true)
    local gangName = GangData.Instance():GetCombineGangInfo().targetGaneName or ""
    self.uiTbl.Label_Remain:GetComponent("UILabel"):set_text(string.format(textRes.Gang[305], gangName))
    Timer:RegisterListener(self.UpdateTimer, self)
  elseif self.state == MergeGangNode.GangMergeState.APPLIED then
    self.uiTbl.Img_Slider:SetActive(false)
    self.uiTbl.Label_Sent:SetActive(true)
    self.uiTbl.Btn_List:SetActive(true)
    self.uiTbl.Btn_CancelRequest:SetActive(true)
    self.uiTbl.Btn_CancelCombine:SetActive(false)
    local gangName = GangData.Instance():GetCombineGangInfo().targetGaneName or ""
    self.uiTbl.Label_Sent:GetComponent("UILabel"):set_text(string.format(textRes.Gang[300], gangName))
  elseif self.state == MergeGangNode.GangMergeState.NONE then
    self.uiTbl.Img_Slider:SetActive(false)
    self.uiTbl.Label_Sent:SetActive(false)
    self.uiTbl.Btn_List:SetActive(true)
    self.uiTbl.Btn_CancelRequest:SetActive(false)
    self.uiTbl.Btn_CancelCombine:SetActive(false)
  else
    self.uiTbl.Img_Slider:SetActive(false)
    self.uiTbl.Label_Sent:SetActive(false)
    self.uiTbl.Btn_List:SetActive(false)
    self.uiTbl.Btn_CancelRequest:SetActive(false)
    self.uiTbl.Btn_CancelCombine:SetActive(false)
  end
end
def.method("number", "=>", "string").MakeTimeStr = function(self, timeVal)
  if timeVal < 0 then
    return "00:00:00"
  end
  local hour = math.modf(timeVal / 3600)
  local min = math.modf((timeVal - hour * 3600) / 60)
  local sec = timeVal - hour * 3600 - min * 60
  local timeStr = string.format("%02d:%02d:%02d", hour, min, sec)
  return timeStr
end
def.method("number").UpdateTimer = function(self, dt)
  if self.state ~= MergeGangNode.GangMergeState.MERGING then
    return
  end
  local combineTime = self.combineTime
  local startTime = self.startTime
  local curTime = GetServerTime()
  local remainTime = combineTime - curTime
  local totalTime = combineTime - startTime
  local timeStr = self:MakeTimeStr(remainTime)
  self.uiTbl.Label_Time:GetComponent("UILabel"):set_text(timeStr)
  local sliverValue = 0
  if totalTime > 0 and remainTime > 0 then
    sliverValue = remainTime / totalTime
  end
  self.uiTbl.Img_Slider:GetComponent("UISlider"):set_sliderValue(sliverValue)
end
def.override().OnHide = function(self)
  Timer:RemoveListener(self.UpdateTimer)
  self.state = 0
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if "Btn_List" == id then
    self:OnBtnMergeCandidateList()
  elseif "Btn_Ruquest" == id then
    self:OnBtnRuquest()
  elseif "Btn_Rule" == id then
    self:OnBtnRule()
  elseif "Btn_CancelCombine" == id then
    self:OnCancelCombine()
  elseif "Btn_CancelRequest" == id then
    self:OnCancelCombine()
  end
end
def.method().UpdateMergeState = function(self)
  local state = MergeGangNode.GangMergeState.NORMAL
  state = MergeGangNode.GangMergeState.NONE
  local time = GangData.Instance():GetCombineGangInfo().applyEndTime or -1
  if time > 0 then
    local curTime = GetServerTime()
    if time > curTime then
      state = MergeGangNode.GangMergeState.APPLIED
    else
      self.startTime = time
      local nextDay = os.date("*t", time + 86400)
      local combineTime = os.time({
        day = nextDay.day,
        month = nextDay.month,
        year = nextDay.year,
        hour = 0,
        minute = 0,
        second = 0
      })
      self.combineTime = combineTime
      state = MergeGangNode.GangMergeState.MERGING
    end
  end
  self.state = state
end
def.method().OnBtnMergeCandidateList = function(self)
  if GangUtility.HeroIsBangZhu() then
    local GangMergeCandidatesPanel = require("Main.Gang.ui.GangManagment.GangMerge.GangMergeCandidatesPanel")
    GangMergeCandidatesPanel.Instance():ShowPanel()
  else
    Toast(textRes.Gang[308])
  end
end
def.method().OnMergeStateChange = function(self)
  local oldState = self.state
  self:UpdateMergeState()
  if oldState ~= self.state then
    self:UpdateUI()
  end
end
def.method().OnVitalityChange = function(self)
  local oldState = self.state
  self:UpdateMergeState()
  if oldState ~= self.state then
    self:UpdateUI()
  else
    self:UpdateVitality()
  end
end
def.method().OnGangNoticeStatesChange = function(self)
  if self.uiTbl then
    self.uiTbl.Img_Red:SetActive(GangData.Instance():IsHaveGangMergeApply())
  end
end
def.static("number", "table").SendCombineGangCancelReq = function(i, tag)
  if i == 1 then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CCombineGangCancelReq").new(tag.gangid))
  end
end
def.method().OnCancelCombine = function(self)
  if GangUtility.HeroIsBangZhu() then
    if self.state == MergeGangNode.GangMergeState.APPLIED or self.state == MergeGangNode.GangMergeState.MERGING then
      local combineInfo = GangData.Instance():GetCombineGangInfo()
      local gangid = combineInfo.targetGangId
      if gangid then
        local tag = {gangid = gangid}
        CommonConfirmDlg.ShowConfirm("", string.format(textRes.Gang[307], combineInfo.targetGaneName or ""), MergeGangNode.SendCombineGangCancelReq, tag)
      end
    end
  else
    Toast(textRes.Gang[308])
  end
end
def.method().OnBtnRule = function(self)
  local CommonUITipsDlg = require("GUI.CommonUITipsDlg")
  local tipContent = require("Main.Common.TipsHelper").GetHoverTip(701602020)
  CommonUITipsDlg.Instance():ShowDlg(tipContent, {x = 0, y = 0})
end
def.method().OnBtnRuquest = function(self)
  if GangUtility.HeroIsBangZhu() then
    local GangMergeRequestsPanel = require("Main.Gang.ui.GangManagment.GangMerge.GangMergeRequestsPanel")
    GangMergeRequestsPanel.Instance():ShowPanel()
    local data = GangData.Instance()
    if data:IsHaveGangMergeApply() then
      data:SetHaveGangMergeApply(false)
      Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_NoticeStatesChanged, {0})
    end
  else
    Toast(textRes.Gang[308])
  end
end
MergeGangNode.Commit()
return MergeGangNode
