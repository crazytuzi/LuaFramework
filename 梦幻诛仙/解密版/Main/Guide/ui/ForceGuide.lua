local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local GuideUtils = require("Main.Guide.GuideUtils")
local GuideDirect = require("consts.mzm.gsp.guide.confbean.GuideDirect")
local Vector = require("Types.Vector")
local ForceGuide = Lplus.Extend(ECPanelBase, "ForceGuide")
local def = ForceGuide.define
local _instance
def.static("=>", ForceGuide).Instance = function()
  if _instance == nil then
    _instance = ForceGuide()
  end
  return _instance
end
def.const("table").ArrowPos = {
  up = {
    x = 0,
    y = -100,
    r = 180
  },
  down = {
    x = 0,
    y = 100,
    r = 0
  },
  left = {
    x = 100,
    y = 0,
    r = -90
  },
  right = {
    x = -100,
    y = 0,
    r = 90
  }
}
def.field("number").cfgId = 0
def.field("function").callback = nil
def.field("function").clickAction = nil
def.field("number").teamSelect = 0
def.field("number").targetSelect = 0
def.field("number").correctTimer = 0
def.field("boolean").destroyUI = false
def.field("table").stepCfg = nil
local screenHeight, screenWidth
def.static("number", "boolean", "function").ShowForceGuide = function(cfgId, destroyUI, cb)
  if screenHeight == nil or screenWidth == nil then
    local GUIMan = require("GUI.ECGUIMan")
    screenHeight = GUIMan.Instance().m_uiRootCom:get_activeHeight()
    screenWidth = screenHeight / Screen.height * Screen.width
  end
  local dlg = ForceGuide.Instance()
  if dlg.m_created then
    warn("ShowForceGuide when a other guide is show")
    return
  end
  dlg.cfgId = cfgId
  dlg.callback = cb
  dlg.clickAction = nil
  dlg.destroyUI = destroyUI
  dlg.stepCfg = nil
  dlg:SetDepth(4)
  dlg.m_HideOnDestroy = true
  dlg:CreatePanel(RESPATH.PREFAB_FORCE_GUIDE, 0)
end
def.static().Close = function()
  local dlg = ForceGuide.Instance()
  GameUtil.RemoveGlobalTimer(dlg.correctTimer)
  dlg.correctTimer = 0
  dlg:DestroyPanel()
end
def.override().OnCreate = function(self)
  require("GUI.ECGUIMan").Instance():LockUI(false)
  self:SetGuideHead()
  self.correctTimer = GameUtil.AddGlobalTimer(0, false, function()
    if self.m_panel and not self.m_panel.isnil then
      self:UpdateGuide()
    end
  end)
end
def.override().OnDestroy = function(self)
  self.teamSelect = 0
  self.targetSelect = 0
  GameUtil.RemoveGlobalTimer(self.correctTimer)
  self.correctTimer = 0
end
def.override("boolean").OnShow = function(self, show)
  if show then
    gmodule.moduleMgr:GetModule(ModuleId.HERO):Stop()
    if self.destroyUI then
      require("GUI.ECGUIMan").Instance():DestroyUIAtLevel(1)
      require("Main.Chat.ui.ChannelChatPanel").CloseChannelChatPanel()
      require("Main.friend.ui.SocialDlg").CloseSocialDlg()
      require("Main.task.ui.TaskTalk").Instance():HideDlg()
      self.destroyUI = false
    end
  end
end
def.method().SetGuideHead = function(self)
  local cfg = GuideUtils.GetStepCfg(self.cfgId)
  if cfg.guidevoiceid > 0 then
    local ECSoundMan = require("Sound.ECSoundMan")
    ECSoundMan.Instance():Play2DInterruptSoundByID(cfg.guidevoiceid)
  end
  local groupRight = self.m_panel:FindDirect("Img_Right")
  local groupLeft = self.m_panel:FindDirect("Img_Left")
  local head
  if cfg.guidedirect == GuideDirect.LEFT then
    head = groupLeft
    groupRight:SetActive(false)
    groupLeft:SetActive(true)
  else
    head = groupRight
    groupLeft:SetActive(false)
    groupRight:SetActive(true)
  end
  head:set_localPosition(Vector.Vector3.new(cfg.x, cfg.y, 0))
  local sentence = head:FindDirect("Label"):GetComponent("UILabel")
  sentence:set_text(cfg.textdesc)
end
def.method().UpdateGuide = function(self)
  self.m_panel:FindDirect("Group_Hand/UI_ZhiYingDianJi"):SetActive(true)
  if self.stepCfg == nil then
    self.stepCfg = GuideUtils.GetStepCfg(self.cfgId)
  end
  local cfg = self.stepCfg
  local uiName = cfg.uipath
  if uiName == "fighttarget" then
    do
      local FightMgr = require("Main.Fight.FightMgr")
      local id, x, y = -1, 0, 0
      if self.teamSelect == 0 and self.targetSelect == 0 then
        id, x, y = FightMgr.Instance():GetFightUnitByPos(2, cfg.param + 1)
      else
        id, x, y = FightMgr.Instance():GetFightUnitByPos(self.teamSelect, self.targetSelect)
      end
      self:SetRectRaw(x, y - 32)
      if self.clickAction == nil then
        function self.clickAction()
          GameUtil.AddGlobalLateTimer(0, true, function()
            Event.DispatchEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.SELECT_TARGET, {id})
          end)
        end
      end
    end
  elseif uiName == "task" then
    require("Main.MainUI.ui.MainUIRightSubPanel").Instance():OpenSubPanel(true)
    do
      local MainUITaskTrace = require("Main.MainUI.ui.MainUITaskTrace")
      local target = MainUITaskTrace.Instance():GetTaskTraceUIItem(cfg.param)
      if target ~= nil and target:get_activeInHierarchy() then
        self:FitSelect(target)
        MainUITaskTrace.Instance():MakeTaskItemShow(target)
        if self.clickAction == nil then
          function self.clickAction()
            GameUtil.AddGlobalLateTimer(0, true, function()
              UICamera.Notify(target, "OnClick", nil)
            end)
          end
        end
      else
        warn("UI Changed, break this guide")
        self.callback(self.cfgId, false)
      end
    end
  else
    do
      local uiRoot = require("GUI.ECGUIMan").Instance().m_UIRoot
      local target = uiRoot:FindDirect(uiName)
      if target ~= nil and target:get_activeInHierarchy() and self:IsInScreen(target) then
        self:FitSelect(target)
        if self.clickAction == nil then
          function self.clickAction()
            GameUtil.AddGlobalLateTimer(0, true, function()
              UICamera.Notify(target, "OnClick", nil)
            end)
          end
        end
      else
        warn("UI Changed, break this guide")
        self.callback(self.cfgId, false)
      end
    end
  end
end
def.method("number", "number").SetRectRaw = function(self, x, y)
  local select = self.m_panel:FindDirect("Group_Hand")
  local widget1 = select:GetComponent("UIWidget")
  widget1:set_width(128)
  widget1:set_height(128)
  select:set_localPosition(Vector.Vector3.new(x, y + 64, 0))
  self:FitArrow()
end
def.method().FitArrow = function(self)
  local select = self.m_panel:FindDirect("Group_Hand")
  select:SetActive(true)
  local position = select:get_localPosition()
  local x = position.x ~= 0 and position.x or 1
  local y = position.y ~= 0 and position.y or 1
  local ratio = x / y
  local dir = "up"
  if ratio > 0 then
    if ratio <= 1.5 then
      dir = y > 0 and "up" or "down"
    else
      dir = x > 0 and "right" or "left"
    end
  elseif ratio >= -1.5 then
    dir = y > 0 and "up" or "down"
  else
    dir = x > 0 and "right" or "left"
  end
  local arrow = self.m_panel:FindDirect("Group_Hand/Arrow")
  self:SetArrow(dir, arrow)
end
def.method("string", "userdata").SetArrow = function(self, dir, arrow)
  local x = ForceGuide.ArrowPos[dir].x
  local y = ForceGuide.ArrowPos[dir].y
  local r = ForceGuide.ArrowPos[dir].r
  arrow:set_localPosition(Vector.Vector3.new(x, y, 0))
  arrow:set_localRotation(Quaternion.Euler(Vector.Vector3.new(0, 0, r)))
end
def.method("userdata").FitSelect = function(self, target)
  local box = target:GetComponent("BoxCollider")
  if box ~= nil then
    local size = box:get_size()
    local height = size.y
    local width = size.x
    local select = self.m_panel:FindDirect("Group_Hand")
    local offset = target:GetComponent("UIWidget"):get_pivotOffset()
    local offsetX = 0 - (offset.x - 0.5) * width
    local offsetY = 0 - (offset.y - 0.5) * height
    local widget1 = select:GetComponent("UIWidget")
    widget1:set_width(width)
    widget1:set_height(height)
    local position = target:get_position()
    local screenPos = WorldPosToScreen(position.x, position.y)
    select:set_localPosition(Vector.Vector3.new(screenPos.x + offsetX, screenPos.y + offsetY, 0))
    self:FitArrow()
  else
    error("This Button did't have BoxCollider")
  end
end
def.method("userdata", "=>", "boolean").IsInScreen = function(self, obj)
  if obj then
    local screenPos = WorldPosToScreen(obj.position.x, obj.position.y)
    if screenPos.x > screenWidth * 0.5 or screenPos.x < screenWidth * -0.5 or screenPos.y > screenHeight * 0.5 or screenPos.y < screenHeight * -0.5 then
      return false
    else
      return true
    end
  else
    return false
  end
end
def.method("string").onClick = function(self, id)
  if id == "Img_Under" then
    Toast(textRes.Guide[1])
  elseif id == "Img_Select" then
    if self.clickAction then
      self.clickAction()
    end
    self.callback(self.cfgId, true)
  end
end
ForceGuide.Commit()
return ForceGuide
