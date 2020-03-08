local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local HeroFightValueTip = Lplus.Extend(ECPanelBase, "HeroFightValueTip")
local def = HeroFightValueTip.define
local HeroSecondProp = Lplus.ForwardDeclare("HeroSecondProp")
local HeroExtraProp = Lplus.ForwardDeclare("HeroExtraProp")
local Vector = require("Types.Vector")
def.const("number").UNIFORM_TIMES = 5
def.const("number").ACCELERATE_TIMES = 20
def.const("table").State = {
  START = 1,
  RUNNING = 2,
  STOP = 3
}
def.const("number").DELAY_COUNT = 3
def.const("number").MAX_DIGITAL = 5
def.field("number")._from = 0
def.field("number")._to = 0
def.field("number")._timerId = 0
def.field("number")._lastInterval = 2
def.field("number")._last = 0
def.field("number")._cur = 0
def.field("number")._start = 0
def.field("number")._end = 0
def.field("number")._sign = 1
def.field("number")._stage = 0
def.field("userdata").ui_Img_Bg0 = nil
def.field("userdata").ui_Img_ArrowRed = nil
def.field("userdata").ui_Img_ArrowGreen = nil
def.field("userdata").ui_Label_Green = nil
def.field("userdata").ui_Label_Red = nil
def.field("userdata").ui_Label = nil
def.field("userdata").ui_Panel_Clip = nil
def.field("table").uiObjs = nil
def.field("boolean").isInit = false
def.field("userdata").ui_Panel = nil
local instance
def.static("=>", HeroFightValueTip).Instance = function()
  if instance == nil then
    instance = HeroFightValueTip()
    instance.m_HideOnDestroy = true
  end
  return instance
end
def.method("number", "number").ShowTip = function(self, from, to)
  self._from = from
  self._to = to
  self._lastInterval = 2
  if self:IsInvalid() then
    return
  end
  if self:IsShow() then
    self:ForceHideTip()
  end
  self:CreatePanel(RESPATH.PREFAB_FIGHT_VALUE, 0)
  self:SetDepth(GUIDEPTH.TOPMOST)
end
def.override().OnCreate = function(self)
  if not self.isInit then
    self:InitUI()
    self.isInit = true
  else
    self.ui_Panel:set_alpha(1)
    self:ResetUI()
  end
  self:_ShowTip()
end
def.method().InitUI = function(self)
  self.ui_Panel = self.m_panel:GetComponent("UIPanel")
  self.ui_Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.ui_Img_ArrowRed = self.ui_Img_Bg0:FindDirect("Img_ArrowRed")
  self.ui_Img_ArrowGreen = self.ui_Img_Bg0:FindDirect("Img_ArrowGreen")
  self.ui_Label_Green = self.ui_Img_Bg0:FindDirect("Label_Green")
  self.ui_Label_Red = self.ui_Img_Bg0:FindDirect("Label_Red")
  self.ui_Panel_Clip = self.ui_Img_Bg0:FindDirect("Panel_Clip")
  self.ui_Label = self.ui_Panel_Clip:FindDirect("Label")
  self.uiObjs = {}
  local template = self.ui_Label
  local localPosition = template.transform.localPosition
  local LABEL_WIDTH = 20
  for i = 1, HeroFightValueTip.MAX_DIGITAL do
    local labelObj = GameObject.Instantiate(template)
    labelObj.name = "Label_" .. i
    labelObj.transform.parent = self.ui_Panel_Clip.transform
    labelObj.transform.localScale = Vector.Vector3.one
    labelObj.transform.localPosition = localPosition
    labelObj.transform.localPosition = Vector.Vector3.new(localPosition.x + (i - 1) * LABEL_WIDTH, localPosition.y, localPosition.z)
    local ui_Label_Cur = labelObj:FindDirect("Label_Cur")
    ui_Label_Cur:AddComponent("BoxCollider")
    ui_Label_Cur.name = "Label_Cur_" .. i
    local ui_Label_Next = labelObj:FindDirect("Label_Next")
    ui_Label_Next:AddComponent("BoxCollider")
    ui_Label_Next.name = "Label_Next_" .. i
    self.uiObjs[i] = {}
    self.uiObjs[i].labelObj = labelObj
    self.uiObjs[i].labelCur = ui_Label_Cur
    self.uiObjs[i].labelNext = ui_Label_Next
    self.uiObjs[i].Widget_Bottom = labelObj:FindDirect("Widget_Bottom")
    self.uiObjs[i].Widget_Middle = labelObj:FindDirect("Widget_Middle")
    self.uiObjs[i].Widget_Top = labelObj:FindDirect("Widget_Top")
  end
  template:SetActive(false)
  local tweenAlpha = self.m_panel:GetComponent("TweenAlpha")
  if tweenAlpha then
    tweenAlpha.duration = 1
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method().ResetUI = function(self)
  local resetTweener = function(uiTweener)
    uiTweener.tweenFactor = 1
    uiTweener.enabled = false
  end
  for i = 1, HeroFightValueTip.MAX_DIGITAL do
    if self.uiObjs[i].Widget_Top.localPosition.y < self.uiObjs[i].Widget_Bottom.localPosition.y then
      self.uiObjs[i].Widget_Bottom, self.uiObjs[i].Widget_Top = self.uiObjs[i].Widget_Top, self.uiObjs[i].Widget_Bottom
    end
    self.uiObjs[i].labelCur.localPosition = self.uiObjs[i].Widget_Middle.localPosition
    self.uiObjs[i].labelNext.localPosition = self.uiObjs[i].Widget_Bottom.localPosition
    local uiTweenerCur = self.uiObjs[i].labelCur:GetComponent("UITweener")
    local uiTweenerNext = self.uiObjs[i].labelNext:GetComponent("UITweener")
    resetTweener(uiTweenerCur)
    resetTweener(uiTweenerNext)
  end
end
def.method()._ShowTip = function(self)
  self._sign = (self._to - self._from) / math.abs(self._to - self._from)
  self._stage = HeroFightValueTip.State.START
  self:UpdateArrowDirection()
  self:UpdateDeltaText()
  self:AdjustAnimDir()
  self:Running()
end
def.method().HideTip = function(self)
  if self._sign > 0 then
    self:PlayEndingFx()
  end
  self:DestroyPanel()
end
def.method().ForceHideTip = function(self)
  self:DestroyPanel()
  local uiTweener = self.m_panel:GetComponent("UITweener")
  if uiTweener then
    uiTweener.tweenFactor = 1
    uiTweener.enabled = false
  end
end
def.method("=>", "boolean").IsInvalid = function(self)
  if self._from == self._to then
    return true
  end
  return false
end
def.method().Running = function(self)
  if self._stage == HeroFightValueTip.State.START then
    local from = self._from
    local to
    if math.abs(self._to - self._from) >= HeroFightValueTip.DELAY_COUNT then
      to = self._from + self._sign * HeroFightValueTip.DELAY_COUNT
    else
      to = self._to
    end
    self:SetValue(from, to)
  elseif self._stage == HeroFightValueTip.State.RUNNING then
    local from = self._cur
    local to
    if math.abs(self._to - self._from) > 2 * HeroFightValueTip.DELAY_COUNT then
      to = self._to - self._sign * HeroFightValueTip.DELAY_COUNT
      self:SetValue(from, to)
    else
      self:KeepRunning()
    end
  elseif self._stage == HeroFightValueTip.State.STOP then
    local from = self._cur
    local to = self._to
    if math.abs(self._to - self._from) >= 2 * HeroFightValueTip.DELAY_COUNT then
      from = self._to - self._sign * HeroFightValueTip.DELAY_COUNT
      self:SetValue(from, to)
    elseif math.abs(self._to - self._from) > HeroFightValueTip.DELAY_COUNT then
      self:SetValue(from, to)
    else
      self:KeepRunning()
    end
  else
    self:HideTip()
  end
end
def.method().KeepRunning = function(self)
  self._stage = self._stage + 1
  self:Running()
end
def.method("number", "number").SetValue = function(self, start, stop)
  if start == stop then
    self:KeepRunning()
  end
  self._start = start
  self._cur = self._start
  self._end = stop
  local format = self:GetValueFormat()
  local strValue = string.format(format, self._cur + self._sign)
  local lastStrValue = string.format(format, self._cur)
  local inheritated = false
  for i = 1, HeroFightValueTip.MAX_DIGITAL - 1 do
    local num = tonumber(string.sub(strValue, i, i))
    local lastNum = tonumber(string.sub(lastStrValue, i, i))
    local labelObj = self.uiObjs[i].labelObj
    local labelCur = self.uiObjs[i].labelCur
    local labelNext = self.uiObjs[i].labelNext
    local Widget_Bottom = self.uiObjs[i].Widget_Bottom
    local Widget_Middle = self.uiObjs[i].Widget_Middle
    local Widget_Top = self.uiObjs[i].Widget_Top
    if lastNum ~= num and self._cur * self._sign < self._to * self._sign or inheritated then
      local interval = self:GetIntervalTime(i)
      if not inheritated then
      end
      inheritated = true
      local tween = TweenTransform.BeginEx(labelCur, interval, Widget_Middle.transform, Widget_Top.transform)
      local tween = TweenTransform.BeginEx(labelNext, interval, Widget_Bottom.transform, Widget_Middle.transform)
    end
    labelCur:GetComponent("UILabel"):set_text(lastNum)
    labelNext:GetComponent("UILabel"):set_text(num)
  end
  local format = self:GetValueFormat()
  local strValue
  local i = HeroFightValueTip.MAX_DIGITAL
  local labelObj = self.uiObjs[i].labelObj
  local labelCur = self.uiObjs[i].labelCur
  local labelNext = self.uiObjs[i].labelNext
  local Widget_Bottom = self.uiObjs[i].Widget_Bottom
  local Widget_Middle = self.uiObjs[i].Widget_Middle
  local Widget_Top = self.uiObjs[i].Widget_Top
  strValue = string.format(format, self._start)
  local tween = TweenTransform.BeginEx(labelCur, self:GetIntervalTime(i), Widget_Middle.transform, Widget_Top.transform)
  local tween = TweenTransform.BeginEx(labelNext, self:GetIntervalTime(i), Widget_Bottom.transform, Widget_Middle.transform)
  local num = tonumber(string.sub(strValue, i, i))
  labelCur:GetComponent("UILabel"):set_text(num)
  local nextNum = self:GetNextNumber(num)
  labelNext:GetComponent("UILabel"):set_text(nextNum)
end
def.method("string", "string").onTweenerFinish = function(self, id, tweenId)
  local str1 = string.sub(id, 1, #"Label_Next_")
  if str1 ~= "Label_Next_" then
    return
  end
  local index = tonumber(string.sub(id, #"Label_Next_" + 1, -1))
  if index ~= HeroFightValueTip.MAX_DIGITAL then
    self:SwitchLabelPos(index)
    return
  end
  self._last = self._cur
  self._cur = self._cur + self._sign * self:GetStep(index)
  local format = self:GetValueFormat()
  local strValue = string.format(format, self._cur + self._sign)
  local lastStrValue = string.format(format, self._last + self._sign)
  local inheritated = false
  for i = 1, HeroFightValueTip.MAX_DIGITAL - 1 do
    local num = tonumber(string.sub(strValue, i, i))
    local lastNum = tonumber(string.sub(lastStrValue, i, i))
    local labelObj = self.uiObjs[i].labelObj
    local labelCur = self.uiObjs[i].labelCur
    local labelNext = self.uiObjs[i].labelNext
    local Widget_Bottom = self.uiObjs[i].Widget_Bottom
    local Widget_Middle = self.uiObjs[i].Widget_Middle
    local Widget_Top = self.uiObjs[i].Widget_Top
    if lastNum ~= num and self._cur * self._sign < self._to * self._sign or inheritated then
      local interval = self:GetIntervalTime(i)
      if not inheritated then
      end
      inheritated = true
      local tween = TweenTransform.BeginEx(labelCur, interval, Widget_Middle.transform, Widget_Top.transform)
      local tween = TweenTransform.BeginEx(labelNext, interval, Widget_Bottom.transform, Widget_Middle.transform)
    end
    labelCur:GetComponent("UILabel"):set_text(lastNum)
    labelNext:GetComponent("UILabel"):set_text(num)
  end
  local index = HeroFightValueTip.MAX_DIGITAL
  self:SwitchLabelPos(index)
  local labelCur = self.uiObjs[index].labelCur
  local labelNext = self.uiObjs[index].labelNext
  local Widget_Bottom = self.uiObjs[index].Widget_Bottom
  local Widget_Middle = self.uiObjs[index].Widget_Middle
  local Widget_Top = self.uiObjs[index].Widget_Top
  local i = self._cur % 10
  local j = self:GetNextNumber(i)
  labelCur:GetComponent("UILabel"):set_text(math.floor(i))
  labelNext:GetComponent("UILabel"):set_text(math.floor(j))
  if self._cur * self._sign >= self._end * self._sign then
    self:KeepRunning()
    return
  end
  local tween = TweenTransform.BeginEx(labelCur, self:GetIntervalTime(index), Widget_Middle.transform, Widget_Top.transform)
  local tween = TweenTransform.BeginEx(labelNext, self:GetIntervalTime(index), Widget_Bottom.transform, Widget_Middle.transform)
end
def.method("number").SwitchLabelPos = function(self, index)
  local i = index
  self.uiObjs[i].labelCur, self.uiObjs[i].labelNext = self.uiObjs[i].labelNext, self.uiObjs[i].labelCur
end
def.method("number", "=>", "number").GetStep = function(self, index)
  local interval = math.abs(self._end - self._start)
  local fenmu = interval > HeroFightValueTip.UNIFORM_TIMES and HeroFightValueTip.UNIFORM_TIMES or interval
  return interval / fenmu
end
def.method("number", "=>", "number").GetIntervalTime = function(self, index)
  local interval = math.abs(self._end - self._start)
  local fenmu = interval > HeroFightValueTip.ACCELERATE_TIMES and HeroFightValueTip.ACCELERATE_TIMES or interval
  if self._stage == HeroFightValueTip.State.START or self._stage == HeroFightValueTip.State.STOP then
    self._lastInterval = 0.5 / fenmu
    return self._lastInterval
  else
    local interval = 2 / fenmu
    if not (interval > 0.1) or not interval then
      interval = 0.1
    end
    if not (interval < self._lastInterval) or not interval then
      interval = self._lastInterval
    end
    return interval
  end
end
def.method("=>", "string").GetValueFormat = function()
  return "%0" .. HeroFightValueTip.MAX_DIGITAL .. "d"
end
def.method().UpdateArrowDirection = function(self)
  self.ui_Img_ArrowGreen:SetActive(false)
  self.ui_Img_ArrowRed:SetActive(false)
  if self._sign > 0 then
    self.ui_Img_ArrowGreen:SetActive(true)
  else
    self.ui_Img_ArrowRed:SetActive(true)
  end
end
def.method().UpdateDeltaText = function(self)
  local interval = self._to - self._from
  self.ui_Label_Green:SetActive(false)
  self.ui_Label_Red:SetActive(false)
  if self._sign > 0 then
    self.ui_Label_Green:SetActive(true)
    interval = string.format("+%d", interval)
    self.ui_Label_Green:GetComponent("UILabel"):set_text(interval)
  else
    self.ui_Label_Red:SetActive(true)
    interval = string.format("%d", interval)
    self.ui_Label_Red:GetComponent("UILabel"):set_text(interval)
  end
end
def.method().AdjustAnimDir = function(self)
  if self._sign > 0 then
    return
  end
  for i = 1, HeroFightValueTip.MAX_DIGITAL do
    self.uiObjs[i].Widget_Bottom, self.uiObjs[i].Widget_Top = self.uiObjs[i].Widget_Top, self.uiObjs[i].Widget_Bottom
  end
end
def.method("number", "=>", "number").GetNextNumber = function(self, cur)
  local nextNum
  if self._sign > 0 then
    nextNum = cur < 9 and cur + 1 or 0
  else
    nextNum = cur > 0 and cur - 1 or 9
  end
  return nextNum
end
def.override().OnDestroy = function(self)
end
def.method().PlayEndingFx = function(self)
  local ECGUIMan = require("GUI.ECGUIMan")
  local uiRoot = ECGUIMan.Instance().m_UIRoot
  local uiPath = "panel_characterp/Img_Bg0/Label_Green"
  local Label_Green = uiRoot:FindDirect(uiPath)
  if Label_Green == nil or Label_Green.isnil then
    warn("UIPath: " .. uiPath .. ", not exist.")
    return
  end
  local uiPath = "panel_main/Pnl_RolePet/RolePetGroup/Img_BgCharacter/Img_IconRole"
  local Img_IconRole = uiRoot:FindDirect(uiPath)
  if Img_IconRole == nil or Img_IconRole.isnil then
    warn("UIPath: " .. uiPath .. ", not exist.")
    return
  end
  local effectId = 702020025
  local effectCfg = _G.GetEffectRes(effectId)
  if effectCfg == nil then
    return
  end
  local resPath = effectCfg.path
  GameUtil.AsyncLoad(resPath, function(ass)
    if ass == nil then
      return
    end
    if Label_Green.isnil or Img_IconRole.isnil then
      return
    end
    local parent = require("Fx.GUIFxMan").Instance().fxroot
    local go = GameObject.GameObject("FightValueFX")
    go:SetLayer(ClientDef_Layer.UI2)
    go.transform.parent = parent.transform
    go.transform.localScale = Vector.Vector3.one
    go.transform.position = Label_Green.transform.position
    local localPosition = go.transform.localPosition
    GameObject.Destroy(go)
    local fx = require("Fx.GUIFxMan").Instance():PlayAsChild(parent, resPath, localPosition.x, localPosition.y, -1, false)
    local duration = 0.8
    local destPos = Img_IconRole.transform.position
    local tp = TweenPosition.Begin(fx, duration, destPos)
    tp:set_worldSpace(true)
    tp.from = fx.transform.position
  end)
end
return HeroFightValueTip.Commit()
