local Lplus = require("Lplus")
local ComponentBase = require("Main.MainUI.ui.MainUIComponentBase")
local MainUIBuff = Lplus.Extend(ComponentBase, "MainUIBuff")
local BuffMgr = require("Main.Buff.BuffMgr")
local EffectType = require("consts.mzm.gsp.buff.confbean.EffectType")
local Vector = require("Types.Vector")
local def = MainUIBuff.define
local tipdlg
def.field("table")._sortedBuffList = nil
def.field("table")._tweenAlphaTimers = nil
def.field("table").uiObjs = nil
local MAX_BUFF_AMOUNT = 8
local instance
def.static("=>", MainUIBuff).Instance = function()
  if instance == nil then
    instance = MainUIBuff()
    instance:Init()
  end
  return instance
end
def.override().Init = function(self)
  self._tweenAlphaTimers = {}
end
def.override("=>", "boolean").CanShowInFight = function(self)
  return true
end
def.override().OnCreate = function(self)
  self:InitUI()
  self._sortedBuffList = {}
  Event.RegisterEvent(ModuleId.BUFF, gmodule.notifyId.Buff.SYNC_BUFF_LIST, MainUIBuff.OnSyncBuffList)
  Event.RegisterEvent(ModuleId.BUFF, gmodule.notifyId.Buff.ADD_BUFF, MainUIBuff.OnAddBuff)
  Event.RegisterEvent(ModuleId.BUFF, gmodule.notifyId.Buff.REMOVE_BUFF, MainUIBuff.OnRemoveBuff)
  Event.RegisterEvent(ModuleId.BUFF, gmodule.notifyId.Buff.BUFF_INFO_UPDATE, MainUIBuff.OnBuffInfoUpdate)
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  local ui_Buff_Role = self.m_node
  self.uiObjs.Buff_Role = ui_Buff_Role
  self.uiObjs.Grid = self.uiObjs.Buff_Role:FindDirect("Grid")
  if self.uiObjs.Grid == nil then
    return
  end
  self.uiObjs.template = self.uiObjs.Grid:FindDirect("Img_Buff")
  self.uiObjs.template:SetActive(false)
end
def.override().OnDestroy = function(self)
  self:HideGuideTip()
  self._sortedBuffList = nil
  self.uiObjs = nil
  Event.UnregisterEvent(ModuleId.BUFF, gmodule.notifyId.Buff.SYNC_BUFF_LIST, MainUIBuff.OnSyncBuffList)
  Event.UnregisterEvent(ModuleId.BUFF, gmodule.notifyId.Buff.ADD_BUFF, MainUIBuff.OnAddBuff)
  Event.UnregisterEvent(ModuleId.BUFF, gmodule.notifyId.Buff.REMOVE_BUFF, MainUIBuff.OnRemoveBuff)
  Event.UnregisterEvent(ModuleId.BUFF, gmodule.notifyId.Buff.BUFF_INFO_UPDATE, MainUIBuff.OnBuffInfoUpdate)
end
def.method().ClearUI = function(self)
end
def.override().OnShow = function(self)
  self:Fill()
end
def.static("table", "table").OnSyncBuffList = function()
  local self = instance
  self:Fill()
end
def.static("table", "table").OnAddBuff = function(params)
  local self = instance
  local buffId = params[1]
  local NewBuffGetPanel = require("GUI.NewBuffGetPanel")
  local ui_Buff_Role = self.uiObjs.Buff_Role
  local buff = BuffMgr.Instance():GetBuff(buffId)
  local buffName = buff:GetName()
  if not params.silence and buff:NeedAniOnAdd() then
    NewBuffGetPanel.Instance():ShowPanel({
      iconId = buff:GetIcon()
    }, buffName, ui_Buff_Role.transform.position, Vector.Vector3.new(0.2, 0.2, 0.2), MainUIBuff.OnAddBuffAnimationFinished, nil)
  else
    MainUIBuff.OnAddBuffAnimationFinished(nil)
  end
  if buffId == BuffMgr.EQUIP_BROKEN_BUFF_ID then
    self:ShowGuideTip(textRes.Buff[16])
  end
end
def.static("table", "table").OnRemoveBuff = function()
  local self = instance
  self:Fill()
end
def.static("table", "table").OnBuffInfoUpdate = function(params)
  local BuffMgr = require("Main.Buff.BuffMgr")
  local self = instance
  local buffId = params[1]
  local index
  for i, buff in ipairs(self._sortedBuffList) do
    if buff.id == buffId then
      index = i
      break
    end
  end
  local buff = BuffMgr.Instance():GetBuff(buffId)
  if index and buff then
    self:SetBuffInfo(buff, index)
  end
end
def.method("table").CheckBaoshidu = function(self, buff)
  if buff.id == BuffMgr.NUTRITION_BUFF_ID then
    local TipThreshhold = require("Main.Hero.HeroUtility").Instance():GetRoleCommonConsts("BAOTIP_LIMIT")
    if TipThreshhold and buff.remainValue:lt(TipThreshhold) then
      self:ShowGuideTip(textRes.Buff[15])
    end
  end
end
def.override().OnEnterFight = function(self)
end
def.override().OnLeaveFight = function(self)
end
def.static("table").OnAddBuffAnimationFinished = function(context)
  local self = instance
  self:Fill()
end
def.method().Fill = function(self)
  local BuffMgr = require("Main.Buff.BuffMgr")
  self._sortedBuffList = BuffMgr.Instance():GetBuffList()
  self:SetBuffList(self._sortedBuffList)
end
def.method("table").SetBuffList = function(self, buffList)
  if self.uiObjs.Grid == nil then
    return
  end
  local uiGrid = self.uiObjs.Grid:GetComponent("UIGrid")
  local buffAmount = #buffList
  local minValue = buffAmount > MAX_BUFF_AMOUNT and MAX_BUFF_AMOUNT or buffAmount
  for i = 1, minValue do
    local buff = buffList[i]
    self:SetBuffInfo(buff, i)
  end
  for i = buffAmount + 1, MAX_BUFF_AMOUNT do
    local ui_Img_Buff = self.uiObjs.Grid:FindDirect("Img_Buff_" .. i)
    GameObject.Destroy(ui_Img_Buff)
  end
  uiGrid:Reposition()
end
def.method("table", "number").SetBuffInfo = function(self, buff, index)
  if self.uiObjs.Grid == nil then
    return
  end
  self:CheckBaoshidu(buff)
  local timer = self._tweenAlphaTimers[index]
  if timer and timer.timerId ~= 0 then
    GameUtil.RemoveGlobalTimer(timer.timerId)
    self._tweenAlphaTimers[index] = nil
  end
  local ui_Img_Buff = self.uiObjs.Grid:FindDirect("Img_Buff_" .. index)
  if ui_Img_Buff == nil then
    ui_Img_Buff = GameObject.Instantiate(self.uiObjs.template)
    ui_Img_Buff:SetActive(true)
    ui_Img_Buff.name = "Img_Buff_" .. index
    ui_Img_Buff.transform.parent = self.uiObjs.Grid.transform
    ui_Img_Buff.transform.localScale = Vector.Vector3.one
    ui_Img_Buff.transform.localPosition = Vector.Vector3.zero
  end
  ui_Img_Buff:SetActive(true)
  ui_Img_Buff:GetComponent("UISprite"):set_alpha(1)
  ui_Img_Buff:GetComponent("UISprite"):set_color(Color.Color(1, 1, 1, 1))
  local tweenAlpha = ui_Img_Buff:GetComponent("TweenAlpha")
  if tweenAlpha then
    tweenAlpha:set_enabled(false)
  end
  local ui_Icon_Buff = ui_Img_Buff:FindDirect("Icon_Buff")
  local uiTexture = ui_Icon_Buff:GetComponent("UITexture")
  uiTexture:set_color(Color.Color(1, 1, 1, 1))
  local icon = buff:GetIcon()
  require("GUI.GUIUtils").FillIcon(uiTexture, icon)
  self:PrepareForBuffDisapper(buff, index)
end
def.method("table", "number").PrepareForBuffDisapper = function(self, buff, index)
  local ui_Buff_Role = self.uiObjs.Buff_Role
  if buff.id == BuffMgr.EQUIP_BROKEN_BUFF_ID then
    self:MakeBuffIconTweenAlpha(index)
  elseif buff.id == BuffMgr.NUTRITION_BUFF_ID then
    if buff:IsNearlyDisappear() then
      self:MakeBuffIconGray(index)
    end
  elseif buff:IsSystemBuff() then
    local buffCfgData = buff:GetCfgData()
    if buffCfgData.effectType ~= 0 and buffCfgData.vanishTip == 0 then
      return
    end
    if buffCfgData.effectType == EffectType.TIME then
      local endTime = buff.remainValue
      local curTime = _G.GetServerTime()
      local intervalSeconds = Int64.ToNumber(endTime - curTime)
      if intervalSeconds > 0 then
        local sleepSeconds = intervalSeconds - buffCfgData.vanishTip
        if sleepSeconds > 0 then
          do
            local timer = {}
            timer.timerId = GameUtil.AddGlobalTimer(sleepSeconds, true, function()
              if not self:IsLoaded() then
                return
              end
              self:MakeBuffIconTweenAlpha(index)
              timer.timerId = 0
            end)
            self._tweenAlphaTimers[index] = timer
          end
        else
          self:MakeBuffIconTweenAlpha(index)
        end
      end
    elseif buffCfgData.effectType == EffectType.AFTER_FIGHT and buff:IsNearlyDisappear() then
      self:MakeBuffIconGray(index)
    end
  end
end
def.method("number").MakeBuffIconTweenAlpha = function(self, index)
  local ui_Img_Buff = self.uiObjs.Grid:FindDirect("Img_Buff_" .. index)
  if ui_Img_Buff == nil then
    return
  end
  local tweenAlpha = ui_Img_Buff:GetComponent("TweenAlpha")
  if tweenAlpha == nil then
    tweenAlpha = ui_Img_Buff:AddComponent("TweenAlpha")
  end
  tweenAlpha:set_enabled(true)
  tweenAlpha:set_value(1)
  tweenAlpha = TweenAlpha.Begin(ui_Img_Buff, 1, 0)
  tweenAlpha.style = 2
end
def.method("number").MakeBuffIconGray = function(self, index)
  local ui_Img_Buff = self.uiObjs.Grid:FindDirect("Img_Buff_" .. index)
  if ui_Img_Buff == nil then
    return
  end
  local uiSprite = ui_Img_Buff:GetComponent("UISprite")
  uiSprite:set_color(Color.Color(0.3, 0.3, 0.3, 1))
  local ui_Icon_Buff = ui_Img_Buff:FindDirect("Icon_Buff")
  local uiTexture = ui_Icon_Buff:GetComponent("UITexture")
  uiTexture:set_color(Color.Color(0.3, 0.3, 0.3, 1))
end
def.method().ClearTweenAlphaTimers = function(self)
  for index, timer in pairs(self._tweenAlphaTimers) do
    if timer.timerId ~= 0 then
      GameUtil.RemoveGlobalTimer(timer.timerId)
      timer.timerId = 0
    end
  end
  self._tweenAlphaTimers = {}
end
def.method("string").ShowGuideTip = function(self, content)
  GameUtil.AddGlobalTimer(0.1, true, function()
    if not self:IsShow() then
      return
    end
    local CommonGuideTip = require("GUI.CommonGuideTip")
    if tipdlg then
      tipdlg.content = content
      tipdlg:UpdateContent()
    else
      tipdlg = CommonGuideTip.ShowGuideTip(content, self.uiObjs.Buff_Role, CommonGuideTip.StyleEnum.LEFT)
    end
  end)
end
def.method().HideGuideTip = function(self)
  if tipdlg then
    tipdlg:HideDlg()
    tipdlg = nil
  end
end
MainUIBuff.Commit()
return MainUIBuff
