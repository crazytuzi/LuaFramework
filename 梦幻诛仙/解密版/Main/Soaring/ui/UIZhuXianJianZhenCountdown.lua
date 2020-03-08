local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local UIZhuXianJianZhenCountdown = Lplus.Extend(ECPanelBase, "UIZhuXianJianZhenCountdown")
local GUIUtils = require("GUI.GUIUtils")
local def = UIZhuXianJianZhenCountdown.define
local instance
def.field("table")._uiGOs = nil
def.field("number")._iDuration = 0
def.field("number")._timerCountdown = 0
def.field("number")._iTimeCount = 0
def.field("number")._iRoundNum = 0
def.field("string")._strTitle = ""
def.field("string")._strContent = ""
def.field("number")._stageType = 1
def.const("table").StageType = {COLLECT_ITEM = 1, KILL_MONSTER = 2}
def.static("=>", UIZhuXianJianZhenCountdown).Instance = function()
  if instance == nil then
    instance = UIZhuXianJianZhenCountdown()
  end
  return instance
end
def.override().OnCreate = function(self)
  self:InitUI()
end
def.override().OnDestroy = function(self)
  if self._uiGOs ~= nil then
    self._uiGOs = nil
  end
  self._iDuration = 0
  self._iDuration = 0
  if self._timerCountdown ~= 0 then
    GameUtil.RemoveGlobalTimer(self._timerCountdown)
    self._timerCountdown = 0
  end
  self._iTimeCount = 0
end
def.method().InitUI = function(self)
  self._uiGOs = {}
  local lblRoundNum = self.m_panel:FindDirect("Img_Bg/Group_TrunNum/Label_TrunNum")
  local lblLeftTime = self.m_panel:FindDirect("Img_Bg/Group_Target/Img_LeftTime/Label_LeftTime")
  local img_MonsterNum = self.m_panel:FindDirect("Img_Bg/Group_Target/Img_MonsterNum")
  local img_ItemNum = self.m_panel:FindDirect("Img_Bg/Group_Target/Img_ItemNum")
  self._uiGOs.lblRoundNum = lblRoundNum
  self._uiGOs.lblLeftTime = lblLeftTime
  self._uiGOs.img_MonsterNum = img_MonsterNum
  self._uiGOs.img_ItemNum = img_ItemNum
  self._iTimeCount = 0
  self:UpdateUITimeCountdown()
  self._timerCountdown = GameUtil.AddGlobalTimer(1, false, function()
    if self._iTimeCount >= self._iDuration and self._timerCountdown ~= 0 then
      GameUtil.RemoveGlobalTimer(self._timerCountdown)
      self._timerCountdown = 0
      self:HidePanel()
      return
    end
    self._iTimeCount = self._iTimeCount + 1
    self:UpdateUITimeCountdown()
  end)
  self:UpdateUI()
end
def.method().UpdateUITimeCountdown = function(self)
  if not self:IsShow() then
    return
  end
  local tblTime = UIZhuXianJianZhenCountdown.TimeFormat(self._iDuration - self._iTimeCount)
  local lblLeftTime = self._uiGOs.lblLeftTime
  GUIUtils.SetText(lblLeftTime, textRes.Soaring.ZhuXianJianZhen[9]:format(tblTime.min, tblTime.sec))
end
def.static("number", "=>", "table").TimeFormat = function(seconds)
  local min = math.floor(seconds / 60)
  local sec = math.round(seconds % 60)
  return {min = min, sec = sec}
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_UI_ROUNDTIMECOUNT, 0)
end
def.method().HidePanel = function(self)
  if self:IsShow() then
    self:DestroyPanel()
  end
end
def.method().UpdateUI = function(self)
  if not self:IsShow() then
    return
  end
  if self._stageType == UIZhuXianJianZhenCountdown.StageType.COLLECT_ITEM then
    self._uiGOs.img_ItemNum:SetActive(true)
    self._uiGOs.img_MonsterNum:SetActive(false)
    local lblItemCount = self._uiGOs.img_ItemNum:FindDirect("Label_ItemNum")
    GUIUtils.SetText(lblItemCount, self._strContent)
  elseif self._stageType == UIZhuXianJianZhenCountdown.StageType.KILL_MONSTER then
    self._uiGOs.img_ItemNum:SetActive(false)
    self._uiGOs.img_MonsterNum:SetActive(true)
    local lblMonsterCount = self._uiGOs.img_MonsterNum:FindDirect("Label_MonsterNum")
    GUIUtils.SetText(lblMonsterCount, self._strContent)
  end
  self:UpdateTitle()
end
def.method().UpdateTitle = function(self)
  self._strTitle = self._strTitle or {}
  GUIUtils.SetText(self._uiGOs.lblRoundNum, self._strTitle)
end
def.method("number").SetStageType = function(self, eType)
  self._stageType = eType
end
def.method("string").SetTitle = function(self, str)
  self._strTitle = str
end
def.method("string").SetContent = function(self, str)
  self._strContent = str
end
def.method("number").SetDuration = function(self, iTime)
  self._iDuration = iTime
  self._iTimeCount = 0
end
return UIZhuXianJianZhenCountdown.Commit()
