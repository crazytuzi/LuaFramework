local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DouDouClearTitle = Lplus.Extend(ECPanelBase, "DouDouClearTitle")
local GUIFxMan = require("Fx.GUIFxMan")
local MathHelper = require("Common.MathHelper")
local def = DouDouClearTitle.define
local _instance
def.static("=>", "table").Instance = function()
  if _instance == nil then
    _instance = DouDouClearTitle()
  end
  return _instance
end
def.field("string").upTitle = ""
def.field("string").middleTitle = ""
def.field("number").endTime = 0
def.field("number").timer = 0
def.field("string").downTitle = ""
def.field("number").downNumber = 0
def.field("table").EffectLevel = nil
def.static("string", "string", "number", "string", "number").ShowDouDouClearTitle = function(upTitle, middleTitle, endTime, downTitle, downNum)
  local dlg = DouDouClearTitle.Instance()
  dlg.upTitle = upTitle
  dlg.middleTitle = middleTitle
  dlg.endTime = endTime
  dlg.downTitle = downTitle
  dlg.downNumber = downNum
  if dlg:IsShow() then
    dlg:UpdateUp()
    dlg:UpdateMiddle()
    dlg:UpdateDown()
  else
    dlg:CreatePanel(RESPATH.PREFAB_DOUDOU_CLEAR_TITLE, 0)
  end
end
def.static().Close = function()
  local dlg = DouDouClearTitle.Instance()
  dlg:DestroyPanel()
end
def.static("string").SetUpTitle = function(upTitle)
  local dlg = DouDouClearTitle.Instance()
  dlg.upTitle = upTitle
  if dlg:IsShow() then
    dlg:UpdateUp()
  end
end
def.static("string", "number").SetMiddleTitle = function(middleTitle, endTime)
  local dlg = DouDouClearTitle.Instance()
  dlg.middleTitle = middleTitle
  dlg.endTime = endTime
  if dlg:IsShow() then
    dlg:UpdateMiddle()
  end
end
def.static("string", "number").SetDownTitle = function(downTitle, downNum)
  local dlg = DouDouClearTitle.Instance()
  dlg.downTitle = downTitle
  dlg.downNumber = downNum
  if dlg:IsShow() then
    dlg:UpdateDown()
  end
end
def.static("number", "number").PlayAddEffect = function(addNum, lv)
  local dlg = DouDouClearTitle.Instance()
  if dlg:IsShow() then
    dlg:AddEffect(addNum, lv)
  end
end
def.override().OnCreate = function(self)
  self:InitEffectLevel()
  self:UpdateUp()
  self:UpdateMiddle()
  self:UpdateDown()
end
def.override().OnDestroy = function(self)
  self:ClearEffectLevel()
  GameUtil.RemoveGlobalTimer(self.timer)
  self.timer = 0
end
def.override("boolean").OnShow = function(self, s)
  if self.m_panel and not self.m_panel.isnil then
    local lbl = self.m_panel:FindDirect("Img_Bg/Label_Down/Label_Num")
    local effect = lbl:FindDirect("score")
    if effect then
      effect:SetActive(false)
    end
  end
end
def.method().InitEffectLevel = function(self)
  self.EffectLevel = {}
  self.EffectLevel[1] = constant.CHulaCfgConsts.POINT_EFFECTID_1
  self.EffectLevel[2] = constant.CHulaCfgConsts.POINT_EFFECTID_2
  self.EffectLevel[3] = constant.CHulaCfgConsts.POINT_EFFECTID_3
  self.EffectLevel[4] = constant.CHulaCfgConsts.POINT_EFFECTID_4
end
def.method().ClearEffectLevel = function(self)
  self.EffectLevel = nil
end
def.method("number", "=>", "number").GetEffectIdByLevel = function(self, lv)
  if self.EffectLevel then
    lv = MathHelper.Plier(1, #self.EffectLevel, lv)
    return self.EffectLevel[lv]
  else
    return -1
  end
end
def.method().UpdateUp = function(self)
  local upLbl = self.m_panel:FindDirect("Img_Bg/Label_Up")
  if self.upTitle ~= "" then
    upLbl:SetActive(true)
    upLbl:GetComponent("UILabel"):set_text(self.upTitle)
  else
    upLbl:SetActive(false)
  end
end
local Second2Text = function(sec)
  if not (sec >= 0) or not sec then
    sec = 0
  end
  local minute = math.floor(sec / 60)
  local second = sec % 60
  local text
  if minute > 0 then
    text = string.format("%02d%s%02d%s", minute, textRes.Pitch[1], second, textRes.Pitch[2])
  else
    text = string.format("%02d%s", second, textRes.Pitch[2])
  end
  return text
end
def.method().UpdateMiddle = function(self)
  GameUtil.RemoveGlobalTimer(self.timer)
  self.timer = 0
  local middleLbl = self.m_panel:FindDirect("Img_Bg/Label")
  if self.middleTitle ~= "" then
    middleLbl:SetActive(true)
    do
      local lblCmp = middleLbl:GetComponent("UILabel")
      if 0 > self.endTime then
        lblCmp:set_text(self.middleTitle)
      else
        local leftSecond = self.endTime - GetServerTime()
        lblCmp:set_text(self.middleTitle .. Second2Text(leftSecond))
        if leftSecond > 0 then
          self.timer = GameUtil.AddGlobalTimer(1, false, function()
            local leftSec = self.endTime - GetServerTime()
            if leftSec < 0 then
              GameUtil.RemoveGlobalTimer(self.timer)
              self.timer = 0
            else
              if lblCmp.isnil then
                return
              end
              lblCmp:set_text(self.middleTitle .. Second2Text(leftSec))
            end
          end)
        end
      end
    end
  else
    middleLbl:SetActive(false)
  end
end
def.method().UpdateDown = function(self)
  local downLbl = self.m_panel:FindDirect("Img_Bg/Label_Down")
  local numLbl = downLbl:FindDirect("Label_Num")
  local hideLbl = self.m_panel:FindDirect("Img_Bg/Label_Ready")
  if self.downTitle ~= "" then
    downLbl:SetActive(true)
    downLbl:GetComponent("UILabel"):set_text(self.downTitle)
    numLbl:GetComponent("UILabel"):set_text(tostring(self.downNumber))
    hideLbl:SetActive(false)
  else
    downLbl:SetActive(false)
    hideLbl:SetActive(true)
  end
end
def.method("number", "number").AddEffect = function(self, num, lv)
  local lbl = self.m_panel:FindDirect("Img_Bg/Label_Down/Label_Num")
  local effectId = self:GetEffectIdByLevel(lv)
  if effectId > 0 then
    local effectRes = GetEffectRes(effectId)
    if effectRes then
      GUIFxMan.Instance():PlayAsChildLayerWithCallback(lbl, effectRes.path, "score", -32, -32, 1, 1, -1, false, function(fx, l)
        local lbl = fx:FindChild("Label")
        if lbl then
          local cmp = lbl:GetComponent("UILabel")
          cmp:set_depth(l)
          cmp:set_text("+" .. tostring(num))
        end
      end)
    end
  end
end
DouDouClearTitle.Commit()
return DouDouClearTitle
