local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ExamChoiceDlg = Lplus.Extend(ECPanelBase, "ExamChoiceDlg")
local KejuConst = require("Main.Keju.KejuConst")
local KejuModule = Lplus.ForwardDeclare("KejuModule")
local KejuUtils = require("Main.Keju.KejuUtils")
local dlg
local def = ExamChoiceDlg.define
def.static("=>", ExamChoiceDlg).Instance = function()
  if dlg == nil then
    dlg = ExamChoiceDlg()
  end
  return dlg
end
def.field("table").data = nil
def.static("table").ShowKeju = function(data)
  local panel = ExamChoiceDlg.Instance()
  panel.data = data
  if panel.m_panel then
    panel:UpdataPanel()
  else
    panel:CreatePanel(RESPATH.PREFAB_KEJU_CHOICE, 1)
    panel:SetModal(true)
  end
end
def.override().OnCreate = function(self)
  self:UpdataPanel()
end
def.method().UpdataPanel = function(self)
  local ActivityInterface = require("Main.activity.ActivityInterface")
  local kejuActId = KejuUtils.GetKejuCfg().acticityId
  local activityCfg = ActivityInterface.GetActivityCfgById(kejuActId)
  local timeCfg = activityCfg.activityTimeCfgs[1]
  local startMinute = -1
  if timeCfg then
    startMinute = timeCfg.timeCommonCfg.activeHour * 60 + timeCfg.timeCommonCfg.activeMinute
  end
  if startMinute > 0 then
    local timeLabel1 = self.m_panel:FindDirect("Img_Bg1/Img_Bg2/Img_BgKe1/Label_Time"):GetComponent("UILabel")
    local timeLabel2 = self.m_panel:FindDirect("Img_Bg1/Img_Bg2/Img_BgKe2/Label_Time"):GetComponent("UILabel")
    local timeLabel3 = self.m_panel:FindDirect("Img_Bg1/Img_Bg2/Img_BgKe3/Label_Time"):GetComponent("UILabel")
    local start1 = startMinute
    local end1 = start1 + KejuUtils.GetKejuCfg().xiangShiTime / 60
    local start2 = startMinute
    local end2 = start2 + KejuUtils.GetKejuCfg().xiangShiTime / 60 + KejuUtils.GetKejuCfg().huiShiTime / 60
    local start3 = end2
    local end3 = start3 + KejuUtils.GetKejuCfg().dianShiPrepareTime / 60 + KejuUtils.GetKejuCfg().dianShiTime / 60
    timeLabel1:set_text(ExamChoiceDlg.GenTimeRange(start1, end1))
    timeLabel2:set_text(ExamChoiceDlg.GenTimeRange(start2, end2))
    timeLabel3:set_text(ExamChoiceDlg.GenTimeRange(start3, end3))
  end
  local btn1 = self.m_panel:FindDirect("Img_Bg1/Img_Bg2/Img_BgKe1/Btn_Join1")
  local btnlabel1 = btn1:FindDirect("Label_Join")
  if self.data[KejuConst.ExamType.XIANG_SHI].enable == KejuConst.ExamStatus.FINISH then
    btn1:GetComponent("UIButton"):set_isEnabled(false)
    btnlabel1:GetComponent("UILabel"):set_text(textRes.Keju[7])
  elseif self.data[KejuConst.ExamType.XIANG_SHI].enable == KejuConst.ExamStatus.OPEN then
    btn1:GetComponent("UIButton"):set_isEnabled(true)
    btnlabel1:GetComponent("UILabel"):set_text(textRes.Keju[8])
  elseif self.data[KejuConst.ExamType.XIANG_SHI].enable == KejuConst.ExamStatus.NOTOPEN then
    btn1:GetComponent("UIButton"):set_isEnabled(false)
    btnlabel1:GetComponent("UILabel"):set_text(textRes.Keju[9])
  elseif self.data[KejuConst.ExamType.XIANG_SHI].enable == KejuConst.ExamStatus.DENY then
    btn1:GetComponent("UIButton"):set_isEnabled(false)
    btnlabel1:GetComponent("UILabel"):set_text(textRes.Keju[19])
  end
  local btn2 = self.m_panel:FindDirect("Img_Bg1/Img_Bg2/Img_BgKe2/Btn_Join2")
  local btnlabel2 = btn2:FindDirect("Label_Join")
  if self.data[KejuConst.ExamType.HUI_SHI].enable == KejuConst.ExamStatus.FINISH then
    btn2:GetComponent("UIButton"):set_isEnabled(false)
    btnlabel2:GetComponent("UILabel"):set_text(textRes.Keju[7])
  elseif self.data[KejuConst.ExamType.HUI_SHI].enable == KejuConst.ExamStatus.OPEN then
    btn2:GetComponent("UIButton"):set_isEnabled(true)
    btnlabel2:GetComponent("UILabel"):set_text(textRes.Keju[8])
  elseif self.data[KejuConst.ExamType.HUI_SHI].enable == KejuConst.ExamStatus.NOTOPEN then
    btn2:GetComponent("UIButton"):set_isEnabled(false)
    btnlabel2:GetComponent("UILabel"):set_text(textRes.Keju[9])
  elseif self.data[KejuConst.ExamType.HUI_SHI].enable == KejuConst.ExamStatus.DENY then
    btn2:GetComponent("UIButton"):set_isEnabled(false)
    btnlabel2:GetComponent("UILabel"):set_text(textRes.Keju[19])
  end
  local btn3 = self.m_panel:FindDirect("Img_Bg1/Img_Bg2/Img_BgKe3/Btn_Join3")
  local btnlabel3 = btn3:FindDirect("Label_Join")
  if self.data[KejuConst.ExamType.DIAN_SHI].enable == KejuConst.ExamStatus.FINISH then
    btn3:GetComponent("UIButton"):set_isEnabled(false)
    btnlabel3:GetComponent("UILabel"):set_text(textRes.Keju[7])
  elseif self.data[KejuConst.ExamType.DIAN_SHI].enable == KejuConst.ExamStatus.OPEN then
    btn3:GetComponent("UIButton"):set_isEnabled(true)
    btnlabel3:GetComponent("UILabel"):set_text(textRes.Keju[8])
  elseif self.data[KejuConst.ExamType.DIAN_SHI].enable == KejuConst.ExamStatus.NOTOPEN then
    if self:IsInDianShiJinChangTime() then
      btn3:GetComponent("UIButton"):set_isEnabled(true)
      btnlabel3:GetComponent("UILabel"):set_text(textRes.Keju[32])
    else
      btn3:GetComponent("UIButton"):set_isEnabled(false)
      btnlabel3:GetComponent("UILabel"):set_text(textRes.Keju[9])
    end
  elseif self.data[KejuConst.ExamType.DIAN_SHI].enable == KejuConst.ExamStatus.DENY then
    btn3:GetComponent("UIButton"):set_isEnabled(false)
    btnlabel3:GetComponent("UILabel"):set_text(textRes.Keju[19])
  end
end
def.method("=>", "boolean").IsInDianShiJinChangTime = function(self)
  return KejuModule.IsInDianShiJinChangTime()
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" or id == "Modal" then
    self:DestroyPanel()
  elseif id == "Btn_Join1" then
    warn("xiangshi state is ...", KejuModule.Instance().data[KejuConst.ExamType.XIANG_SHI].enable)
    if KejuModule.Instance().data[KejuConst.ExamType.XIANG_SHI].enable == KejuConst.ExamStatus.OPEN then
      KejuModule.Instance():GotoXiangShi()
      self:DestroyPanel()
    elseif KejuModule.Instance().data[KejuConst.ExamType.XIANG_SHI].enable == KejuConst.ExamStatus.NOTOPEN then
      Toast(textRes.Keju[41])
    elseif KejuModule.Instance().data[KejuConst.ExamType.XIANG_SHI].enable == KejuConst.ExamStatus.FINISH then
      Toast(textRes.Keju[25])
    elseif KejuModule.Instance().data[KejuConst.ExamType.XIANG_SHI].enable == KejuConst.ExamStatus.DENY then
      Toast(textRes.Keju[44])
    end
  elseif id == "Btn_Join2" then
    warn("huishi state is ...", KejuModule.Instance().data[KejuConst.ExamType.HUI_SHI].enable)
    if KejuModule.Instance().data[KejuConst.ExamType.HUI_SHI].enable == KejuConst.ExamStatus.OPEN then
      KejuModule.Instance():GotoHuiShi()
      self:DestroyPanel()
    elseif KejuModule.Instance().data[KejuConst.ExamType.HUI_SHI].enable == KejuConst.ExamStatus.NOTOPEN then
      Toast(textRes.Keju[42])
    elseif KejuModule.Instance().data[KejuConst.ExamType.HUI_SHI].enable == KejuConst.ExamStatus.FINISH then
      Toast(textRes.Keju[26])
    elseif KejuModule.Instance().data[KejuConst.ExamType.HUI_SHI].enable == KejuConst.ExamStatus.DENY then
      Toast(textRes.Keju[45])
    end
  elseif id == "Btn_Join3" then
    warn("dianshi state is ...", KejuModule.Instance().data[KejuConst.ExamType.DIAN_SHI].enable)
    if KejuModule.Instance().data[KejuConst.ExamType.DIAN_SHI].enable == KejuConst.ExamStatus.OPEN then
      KejuModule.Instance():GotoDianShi()
      self:DestroyPanel()
    elseif KejuModule.Instance().data[KejuConst.ExamType.DIAN_SHI].enable == KejuConst.ExamStatus.NOTOPEN then
      if self:IsInDianShiJinChangTime() then
        KejuModule.Instance():GotoDianShi()
        self:DestroyPanel()
      else
        Toast(textRes.Keju[43])
      end
    elseif KejuModule.Instance().data[KejuConst.ExamType.DIAN_SHI].enable == KejuConst.ExamStatus.FINISH then
      Toast(textRes.Keju[27])
    elseif KejuModule.Instance().data[KejuConst.ExamType.DIAN_SHI].enable == KejuConst.ExamStatus.DENY then
      Toast(textRes.Keju[46])
    end
  elseif id == "Img_Pic1" then
    local tip = require("Main.Common.TipsHelper").GetHoverTip(KejuUtils.GetKejuCfg().xiangshiTip)
    require("GUI.CommonUITipsDlg").ShowCommonTip(tip, {x = 0, y = 0})
  elseif id == "Img_Pic2" then
    local tip = require("Main.Common.TipsHelper").GetHoverTip(KejuUtils.GetKejuCfg().huishiTip)
    require("GUI.CommonUITipsDlg").ShowCommonTip(tip, {x = 0, y = 0})
  elseif id == "Img_Pic3" then
    local tip = require("Main.Common.TipsHelper").GetHoverTip(KejuUtils.GetKejuCfg().dianshiTip)
    require("GUI.CommonUITipsDlg").ShowCommonTip(tip, {x = 0, y = 0})
  end
end
def.static("number", "number", "=>", "string").GenTimeRange = function(startTime, endTime)
  local hourStart = math.floor(startTime / 60) % 24
  local minuteStart = startTime % 60
  local hourEnd = math.floor(endTime / 60) % 24
  local minuteEnd = endTime % 60
  return string.format("%02d:%02d-%02d:%02d", hourStart, minuteStart, hourEnd, minuteEnd)
end
ExamChoiceDlg.Commit()
return ExamChoiceDlg
