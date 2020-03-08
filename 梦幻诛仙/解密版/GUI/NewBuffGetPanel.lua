local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ECGUIMan = require("GUI.ECGUIMan")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local NewBuffGetPanel = Lplus.Extend(ECPanelBase, "NewBuffGetPanel")
local def = NewBuffGetPanel.define
def.field("table")._itemIcon = nil
def.field("string")._itemName = ""
def.field("table")._targetPosition = nil
def.field("table")._targetScale = nil
def.field("function")._onFinish = nil
def.field("table")._context = nil
def.const("number").CENTER_DISPLAY_TIME = 1.5
local CONTINUOUS_DISPLAY_TIMES = 5
local CONTINUOUS_DISPLAY_DURATION = 12
def.field("table")._waittingQueue = nil
def.field("table")._playHistorys = nil
local instance
def.static("=>", NewBuffGetPanel).Instance = function()
  if instance == nil then
    instance = NewBuffGetPanel()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, NewBuffGetPanel.OnLeaveWorld)
  self._playHistorys = {}
end
def.static("table", "table").OnLeaveWorld = function()
  instance:ForceStop()
  instance._playHistorys = {}
end
def.method("table", "string", "table", "table", "function", "table").ShowPanel = function(self, icon, name, targetPosition, targetScale, onFinish, context)
  local displayInfo = {}
  displayInfo.itemIcon = icon
  displayInfo.itemName = name
  displayInfo.targetPosition = targetPosition
  displayInfo.targetScale = targetScale
  displayInfo.onFinish = onFinish
  displayInfo.context = context
  self._waittingQueue = self._waittingQueue or {}
  table.insert(self._waittingQueue, displayInfo)
  if self:IsShow() then
    return
  end
  self:_ShowPanel()
end
def.method()._ShowPanel = function(self)
  local displayInfo = self._waittingQueue[1]
  if displayInfo == nil then
    return
  end
  if self:CanPlay() == false then
    if displayInfo.onFinish then
      displayInfo.onFinish(displayInfo.context)
    end
    self:ForceStop()
    return
  end
  self._itemIcon = displayInfo.itemIcon
  self._itemName = displayInfo.itemName
  self._targetPosition = displayInfo.targetPosition
  self._targetScale = displayInfo.targetScale
  self._onFinish = displayInfo.onFinish
  self._context = displayInfo.context
  self:CreatePanel(RESPATH.PREFAB_NEW_BUFF_GET_PANEL, -1)
end
def.method().ForceStop = function(self)
  self._waittingQueue = {}
  self:DestroyPanel()
end
def.method("=>", "boolean").CanPlay = function(self)
  if #self._playHistorys < CONTINUOUS_DISPLAY_TIMES then
    return true
  end
  local oldestplay = self._playHistorys[1]
  local newestplay = self._playHistorys[CONTINUOUS_DISPLAY_TIMES]
  local playInterval = math.abs(newestplay - oldestplay)
  if playInterval > CONTINUOUS_DISPLAY_DURATION then
    return true
  end
  local curTime = os.time()
  local curInterval = math.abs(curTime - newestplay)
  if curInterval > CONTINUOUS_DISPLAY_DURATION then
    return true
  end
  return false
end
def.override().OnCreate = function(self)
  local curTime = os.time()
  table.insert(self._playHistorys, curTime)
  if #self._playHistorys > CONTINUOUS_DISPLAY_TIMES then
    table.remove(self._playHistorys, 1)
  end
  local Img_Icon = self.m_panel:FindDirect("Img_Icon")
  if self._itemIcon and self._itemIcon.iconId then
    self:SetTextureIcon()
  elseif self._itemIcon and self._itemIcon.atlasName and self._itemIcon.spriteName then
    self:SetSpriteIcon()
  end
  self.m_panel:FindDirect("Label"):GetComponent("UILabel").text = self._itemName
  GameUtil.AddGlobalTimer(NewBuffGetPanel.CENTER_DISPLAY_TIME, true, function()
    if self.m_panel == nil or self.m_panel.isnil then
      return
    end
    self.m_panel:FindDirect("Label"):SetActive(false)
    local tweenPosition = Img_Icon:GetComponent("TweenPosition")
    if tweenPosition and self._targetPosition then
      tweenPosition.worldSpace = true
      tweenPosition.to = self._targetPosition
    end
    local tweenScale = Img_Icon:GetComponent("TweenScale")
    if tweenScale and self._targetScale then
      local curValue = tweenScale.value
      tweenScale.value = self._targetScale
      tweenScale:SetEndToCurrentValue()
      tweenScale.value = curValue
      tweenScale:SetStartToCurrentValue()
    end
    Img_Icon:GetComponent("UIPlayTween"):Play(true)
  end)
end
def.override().OnDestroy = function(self)
  self._itemIcon = nil
  self._itemName = ""
  self._targetPosition = nil
  self._targetScale = nil
  self._onFinish = nil
  self._context = nil
  table.remove(self._waittingQueue, 1)
  if #self._waittingQueue > 0 then
    local timer = GameUtil.AddGlobalTimer(0.25, false, function()
      if not self:IsShow() then
        GameUtil.RemoveGlobalTimer(timer)
        self:_ShowPanel()
      end
    end)
  end
end
def.method("string").onCommonPlayTweenFinish = function(self, id)
  if self._onFinish then
    self._onFinish(self._context)
  end
  self:DestroyPanel()
end
def.method().SetTextureIcon = function(self)
  local Img_Icon = self.m_panel:FindDirect("Img_Icon")
  Img_Icon:FindDirect("Texture"):SetActive(true)
  Img_Icon:FindDirect("Sprite"):SetActive(false)
  local uiTexture = Img_Icon:FindDirect("Texture"):GetComponent("UITexture")
  require("GUI.GUIUtils").FillIcon(uiTexture, self._itemIcon.iconId)
end
def.method().SetSpriteIcon = function(self)
  local Img_Icon = self.m_panel:FindDirect("Img_Icon")
  Img_Icon:FindDirect("Texture"):SetActive(false)
  Img_Icon:FindDirect("Sprite"):SetActive(true)
  local uiSprite = Img_Icon:FindDirect("Sprite"):GetComponent("UISprite")
  local atlasPath = string.format("%s/%s.prefab.u3dext", RESPATH.ATLAS_DIR, self._itemIcon.atlasName)
  GameUtil.AsyncLoad(atlasPath, function(obj)
    local atlas = obj:GetComponent("UIAtlas")
    uiSprite:set_atlas(atlas)
    uiSprite:set_spriteName(self._itemIcon.spriteName)
  end)
end
NewBuffGetPanel.Commit()
return NewBuffGetPanel
