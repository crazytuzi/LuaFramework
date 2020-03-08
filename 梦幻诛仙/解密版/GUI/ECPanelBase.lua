local Lplus = require("Lplus")
local EC = require("Types.Vector3")
local GUIEvents = require("Event.GUIEvents")
local ECSoundMan = require("Sound.ECSoundMan")
local ECPanelBase = Lplus.Class("ECPanelBase")
local def = ECPanelBase.define
def.field("userdata").m_panel = nil
def.field("string").m_panelName = ""
def.field("table").m_parent = nil
def.field("userdata").m_msgHandler = nil
def.field("number").m_stamp = 0
def.field("boolean").m_created = false
def.field("number").m_depthLayer = GUIDEPTH.NORMAL
def.field("boolean").m_isLoading = false
def.field("boolean").m_disappearing = false
def.field("boolean").m_HideOnDestroy = false
def.field("boolean").m_SyncLoad = false
def.field("boolean").m_TrigGC = false
def.field("boolean").m_ChangeLayerOnShow = false
def.field("boolean").m_TryIncLoadSpeed = false
def.field("userdata").m_panelHide = nil
def.field("boolean").m_modal = false
def.field("number").m_level = 0
def.field("boolean").m_hideBeforeShow = false
def.field("number").m_priority = 100
def.field("boolean").m_bCanMoveBackward = false
local depthLayers = {
  {depth = -2000, lastPanel = nil},
  {depth = 0, lastPanel = nil},
  {depth = 30000, lastPanel = nil},
  {depth = 60000, lastPanel = nil},
  {depth = 90000, lastPanel = nil},
  {depth = 120000, lastPanel = nil},
  {depth = 150000, lastPanel = nil}
}
local uiRoot = false
local g_handlers = {}
local g_modalCount = 0
local g_modalAction
def.virtual().OnCreate = function(self)
end
def.virtual().OnDestroy = function(self)
end
def.virtual("boolean").OnShow = function(self, s)
end
def.virtual().AfterCreate = function(self)
end
def.virtual("boolean", "boolean").OnGUIChange = function(self, rolechange, userchange)
end
def.method("=>", "boolean").IsShow = function(self)
  if not self.m_panel or self.m_panel.isnil then
    return false
  end
  return self.m_panel.activeSelf
end
def.method("=>", "boolean").IsCreated = function(self)
  return self.m_created
end
def.method("=>", "boolean").IsLoaded = function(self)
  if not self.m_panel or self.m_panel.isnil then
    return false
  end
  return true
end
def.method("=>", "boolean").IsLoading = function(self)
  return self.m_isLoading
end
local getPanelNameFromResName = function(resName)
  local i, j, cap = resName:lower():find("/([%w_]+)%.prefab%.u3dext$")
  if cap then
    return cap
  end
  local i, j, cap = resName:lower():find("([^/]*)$")
  return cap or "noname"
end
local findControl = function(name, obj)
  local t = obj:FindChild(name)
  if not t then
    warn("can not find control with name:" .. name)
  end
  return t
end
def.method("string", "userdata", "=>", "userdata").FindControl = function(self, name, parent)
  if parent == nil then
    return findControl(name, self.m_panel)
  else
    return findControl(name, parent)
  end
end
def.method("string", "=>", "userdata").FindChild = function(self, name)
  return self:FindControl(name, nil)
end
def.method("userdata", "=>", "string")._GetObjNamePath = function(self, obj)
  if not obj then
    return ""
  end
  local name_path = obj.name
  local p = obj.parent
  while true do
    if p == nil or p.name == "UI Root(2D)" then
      break
    end
    name_path = p.name .. "/" .. name_path
    p = p.parent
  end
  local panel_name = self.m_panel.name
  if name_path:sub(1, 1 + panel_name:len()) == panel_name .. "/" then
    name_path = name_path:sub(2 + panel_name:len())
  end
  return name_path
end
def.method("string", "=>", "string").GetObjNamePath = function(self, name)
  return self:_GetObjNamePath(self:FindChild(name))
end
def.method("number").SetLayer = function(self, l)
  if self.m_panel and not self.m_panel.isnil then
    self.m_panel:SetLayer(l)
    self:OnLayerChange(l)
  end
end
def.method("=>", "number").GetLayer = function(self)
  if self.m_panel and not self.m_panel.isnil then
    return self.m_panel.layer
  end
  return ClientDef_Layer.Invisible
end
def.virtual("number").OnLayerChange = function(self, newLayer)
end
def.method("string").RegisterPanel = function(self, resName)
  local panelName = getPanelNameFromResName(resName)
  self.m_panelName = panelName
  local ECGUIMan = require("GUI.ECGUIMan")
  ECGUIMan.Instance():RegisterPanel(self, panelName)
end
def.method().SetOutTouchDisappear = function(self)
  local ECGUIMan = require("GUI.ECGUIMan")
  ECGUIMan.Instance():SetOutTouchDisappear(self)
end
def.static("function").SetModalAction = function(func)
  g_modalAction = func
end
def.method("boolean").DoModalAction = function(self, modal)
  if self.m_level ~= 1 then
    return
  end
  local oldCount = g_modalCount
  if modal then
    g_modalCount = g_modalCount + 1
  else
    g_modalCount = g_modalCount > 0 and g_modalCount - 1 or 0
  end
  if oldCount + g_modalCount == 1 and g_modalAction then
    g_modalAction(g_modalCount > 0)
  end
  print(self.m_panelName, "Modal Count:", oldCount, "=>", g_modalCount)
end
def.method("boolean").SetModal = function(self, modal)
  self.m_modal = modal
  if self.m_panel ~= nil and modal == true then
    do
      local block = self.m_panel:FindDirect("Modal")
      if block ~= nil then
        return
      end
      self:DoModalAction(true)
      local block = GameObject:GameObject("")
      block:set_name("Modal")
      block:set_layer(self.m_panel:get_layer())
      block.parent = self.m_panel
      local box = block:AddComponent("BoxCollider")
      local sprite = block:AddComponent("UISprite")
      GameUtil.AsyncLoad(RESPATH.COMMONATLAS, function(obj)
        local atlas = obj:GetComponent("UIAtlas")
        if sprite == nil or sprite.isnil then
          return
        end
        sprite:set_atlas(atlas)
        sprite:set_spriteName(RESPATH.MODALSPRITE)
        sprite:set_autoResizeBoxCollider(true)
        sprite:set_width(1920)
        sprite:set_height(1080)
        sprite:set_depth(-1)
        sprite:set_alpha(0.65)
      end)
      self.m_msgHandler:Touch(block)
    end
  elseif self.m_panel ~= nil and modal == false then
    local block = self.m_panel:FindDirect("Modal")
    if block ~= nil then
      Object.Destroy(block)
      self:DoModalAction(false)
    end
  end
end
def.method("boolean").RawShow = function(self, show)
  if self.m_panel ~= nil then
    if self.m_ChangeLayerOnShow then
      if show then
        self:SetLayer(ClientDef_Layer.UI)
      else
        self:SetLayer(ClientDef_Layer.Invisible)
      end
    else
      self.m_panel:SetActive(show)
    end
    if not self.m_ChangeLayerOnShow or self.m_hideBeforeShow and show then
      self:OnShow(show)
    end
    if self.m_hideBeforeShow and show then
      self:SetModal(self.m_modal)
      self.m_hideBeforeShow = false
    end
  elseif show == false then
    self.m_hideBeforeShow = true
  else
    self.m_hideBeforeShow = false
  end
end
def.method("string", "number").CreatePanel = function(self, resName, level)
  self.m_level = level
  self:_createPanel(resName)
  require("GUI.ECGUIMan").Instance():pushShowFrames(self.m_panelName)
end
_G.panel_change_framerate_timer = 0
def.method("string")._createPanel = function(self, resName)
  local ECGUIMan = require("GUI.ECGUIMan")
  if ECGUIMan.Instance():TestUIPriority(self, self.m_level) == false then
    warn("************* ", tostring(resName), " \228\188\152\229\133\136\231\186\167\228\189\142\228\184\141\232\131\189\230\152\190\231\164\186\239\188\129\239\188\129")
    return
  end
  print(" Load UIRes Name begin = " .. resName)
  if self.m_panel then
    if self.m_disappearing then
      self:_DestroyPanel()
    else
      return
    end
  end
  self.m_created = true
  self.m_stamp = self.m_stamp + 1
  if self.m_isLoading then
    return
  end
  self.m_isLoading = true
  self:RegisterPanel(resName)
  local panelName = getPanelNameFromResName(resName)
  ECGUIMan.Instance():AddUI(self, self.m_level)
  Event.DispatchEvent(ModuleId.FIRST, gmodule.notifyId.First.Panel_PreCreate, {panelName, self})
  if not self.m_created then
    self.m_isLoading = false
    return
  end
  local function _on_finish(obj)
    if not obj then
      self:OnCreate()
      return
    end
    self:CreateFromGameObject(obj, panelName, nil, nil)
    if not self.m_hideBeforeShow then
      self:SetModal(self.m_modal)
    end
    self:BringTop()
    self:AfterCreate()
  end
  if self.m_panelHide then
    self.m_isLoading = false
    self.m_panelHide:SetActive(true)
    _on_finish(self.m_panelHide)
    Event.DispatchEvent(ModuleId.FIRST, gmodule.notifyId.First.Panel_PostCreate, {panelName, self})
    return
  end
  if self.m_TryIncLoadSpeed then
    if _G.panel_change_framerate_timer == 0 then
      do
        local old_frame_rate = Application.get_targetFrameRate()
        Application.set_targetFrameRate(60)
        _G.panel_change_framerate_timer = GameUtil.AddGlobalTimer(2, true, function()
          _G.panel_change_framerate_timer = 0
          if Application.get_targetFrameRate() == 60 then
            Application.set_targetFrameRate(old_frame_rate)
          end
        end)
      end
    else
      GameUtil.ResetGlobalTimer(_G.panel_change_framerate_timer)
    end
  end
  GameUtil.AsyncLoad(resName, function(obj)
    self.m_isLoading = false
    if not self.m_created then
      if obj then
        GameUtil.UnbindUserData(obj)
      end
      return
    end
    _on_finish(obj)
    if obj then
      GameUtil.UnbindUserData(obj)
    end
    if self.m_HideOnDestroy then
      self.m_panelHide = self.m_panel
    end
    Event.DispatchEvent(ModuleId.FIRST, gmodule.notifyId.First.Panel_PostCreate, {panelName, self})
  end, true, self.m_SyncLoad, self.m_SyncLoad)
end
def.method("userdata", "string", "table", "userdata").CreateFromGameObject = function(self, go, panelName, parentPanel, parentgameobject)
  if not uiRoot then
    uiRoot = GameObject.Find("/UI Root(2D)")
  end
  local panel
  if self.m_panelHide then
    panel = self.m_panelHide
  else
    panel = Object.Instantiate(go, "GameObject")
  end
  panel.name = panelName
  if not self.m_panelHide then
    local parentgo = uiRoot
    if parentgameobject then
      parentgo = parentgameobject
    end
    panel.parent = parentgo
    panel.localPosition = EC.Vector3.zero
    panel.localScale = EC.Vector3.one
  end
  self:TouchGameObject(panel, parentPanel)
  if not self.m_panel or panel.isnil then
    return
  end
  if _G.isDebugBuild then
    GameUtil.BeginSamp("OnCreate: " .. self.m_panel.name)
    self:OnCreate()
    GameUtil.EndSamp()
  else
    self:OnCreate()
  end
  if not self.m_panel or panel.isnil then
    return
  end
  if self.m_hideBeforeShow then
    self:RawShow(false)
  else
    self:OnShow(panel.activeSelf)
  end
end
def.method("userdata", "table").TouchGameObject = function(self, go, parentPanel)
  if _G.isDebugBuild then
    GameUtil.BeginSamp("TouchGameObject" .. go.name)
  end
  self.m_parent = parentPanel
  if parentPanel then
    self.m_depthLayer = parentPanel.m_depthLayer
  end
  local active = go.activeSelf
  self.m_panel = go
  local msgHandler = go:GetComponent("GUIMsgHandler")
  msgHandler = msgHandler or go:AddComponent("GUIMsgHandler")
  local msgt = {
    onSubmit = self:_onEvent("onSubmit"),
    onTextChange = self:_onEvent("onTextChange"),
    tick = self:_onEvent("tick"),
    onClick = self:_onEvent("onClick"),
    onLongPress = self:_onEvent("onLongPress"),
    onClickObj = self:_onEvent("onClickObj"),
    onPress = self:_onEvent("onPress"),
    onPressObj = self:_onEvent("onPressObj"),
    onKey = self:_onEvent("onKey"),
    onToggle = self:_onEvent("onToggle"),
    onScroll = self:_onEvent("onScroll"),
    onSelect = self:_onEvent("onSelect"),
    onSpringFinish = self:_onEvent("onSpringFinish"),
    onDragStart = self:_onEvent("onDragStart"),
    onDrag = self:_onEvent("onDrag"),
    onDragOver = self:_onEvent("onDragOver"),
    onDragOut = self:_onEvent("onDragOut"),
    onDragEnd = self:_onEvent("onDragEnd"),
    onDoubleClick = self:_onEvent("onDoubleClick"),
    onTweenerFinish = self:_onEvent("onTweenerFinish"),
    onPlayTweenFinish = self:_onEvent("onPlayTweenFinish")
  }
  msgHandler:SetMsgTable(msgt, self)
  self.m_msgHandler = msgHandler
  msgHandler:Touch(go)
  if _G.isDebugBuild then
    GameUtil.EndSamp()
  end
end
def.method().DestroyPanel = function(self)
  self.m_created = false
  local ECGUIMan = require("GUI.ECGUIMan")
  ECGUIMan.Instance():RemoveUI(self, self.m_level)
  if not self.m_panel or self.m_panel.isnil then
    return
  end
  if self.m_modal then
    self:SetModal(false)
  end
  self.m_hideBeforeShow = false
  local UIPlayTween = self.m_panel:GetComponent("UIPlayTween")
  if UIPlayTween then
    UIPlayTween:Play(true)
    self.m_disappearing = true
  else
    self:_DestroyPanel()
  end
end
def.method()._DestroyPanel = function(self)
  local ECGame = require("Main.ECGame")
  ECGame.EventManager:raiseEvent(self, GUIEvents.DestroyPanelEvent.new(self.m_panelName, self))
  Event.DispatchEvent(ModuleId.FIRST, gmodule.notifyId.First.Panel_PreDestroy, {
    self.m_panelName,
    self
  })
  self:OnDestroy()
  if self.m_HideOnDestroy then
    self.m_panelHide = self.m_panel
    self.m_panelHide:SetActive(false)
  else
    Object.Destroy(self.m_panel)
  end
  if depthLayers[self.m_depthLayer].lastPanel == self.m_panel then
    depthLayers[self.m_depthLayer].lastPanel = nil
  end
  self.m_panel = nil
  self.m_parent = nil
  self.m_msgHandler = nil
  self.m_disappearing = false
  self:OnShow(false)
  if self.m_TrigGC then
    local ECGame = require("Main.ECGame")
    ECGame.Instance():DelayGC(true)
  end
  Event.DispatchEvent(ModuleId.FIRST, gmodule.notifyId.First.Panel_PostDestroy, {
    self.m_panelName,
    self
  })
end
def.method("boolean").SetHideOnDestroy = function(self, bHideOnDestroy)
  self.m_HideOnDestroy = bHideOnDestroy
  if not bHideOnDestroy and self.m_panelHide then
    if self.m_panelHide ~= self.m_panel then
      Object.Destroy(self.m_panelHide)
    end
    self.m_panelHide = nil
  end
end
def.method("=>", "function").MakeStampChecker = function(self)
  local stamp = self.m_stamp
  return function()
    return self.m_panel ~= nil and stamp == self.m_stamp
  end
end
def.method("boolean").Show = function(self, s)
  if self.m_panel then
    self.m_panel:SetActive(s)
    self:OnShow(s)
  end
end
def.method().BringTop = function(self)
  if self.m_parent then
    self.m_parent:BringTop()
    return
  end
  self:_BringTopReal()
end
def.method()._BringTopReal = function(self)
  if not self.m_panel or self.m_panel.isnil then
    return
  end
  local depthLayer = depthLayers[self.m_depthLayer]
  if depthLayer.lastPanel ~= self.m_panel then
    depthLayer.depth = self.m_panel:BringUIPanelTopDepth(depthLayer.depth)
    depthLayer.lastPanel = self.m_panel
  end
end
def.method("number").SetDepth = function(self, depth)
  if self.m_panel then
    self:BringDepth(depth)
  else
    self.m_depthLayer = depth
  end
end
def.method("number").BringDepth = function(self, depth)
  local depthLayer = depthLayers[depth]
  if depthLayer.lastPanel ~= self.m_panel then
    depthLayer.depth = self.m_panel:BringUIPanelTopDepth(depthLayer.depth)
    depthLayer.lastPanel = self.m_panel
    self.m_depthLayer = depth
  end
end
def.virtual("boolean", "=>", "boolean")._canBringTop = function(self, pressState)
  return pressState
end
def.method("string", "=>", "function")._onEvent = function(self, eventName)
  local func = self:tryget(eventName)
  if not func then
    return nil
  end
  local function f(self, id, param1, param2, param3)
    if eventName == "onClick" or eventName == "onDoubleClick" or eventName == "onClickObj" or eventName == "onPress" and param1 == true or eventName == "onLongPress" then
      local ECGUIMan = require("GUI.ECGUIMan")
      if self.m_panel then
        ECGUIMan.Instance():NotifyDisappear(self.m_panel.name)
      else
        ECGUIMan.Instance():NotifyDisappear("")
      end
    end
    if not self.m_panel then
      return
    end
    local handlers = g_handlers[eventName]
    if handlers then
      for _, handler in ipairs(handlers) do
        if handler and handler(self, id, param1, param2, param3) then
          break
        end
      end
    end
    if func then
      if param1 ~= nil and param2 ~= nil and param3 ~= nil then
        func(self, id, param1, param2, param3)
      elseif param1 ~= nil and param2 ~= nil then
        func(self, id, param1, param2)
      elseif param1 ~= nil then
        func(self, id, param1)
      else
        func(self, id)
      end
    end
  end
  return f
end
def.static("string", "function").AddEventHook = function(eventName, func)
  local funcs = g_handlers[eventName]
  if not funcs then
    g_handlers[eventName] = {}
    funcs = g_handlers[eventName]
  end
  funcs[#funcs + 1] = func
end
def.static("string", "function").RemoveEventHook = function(eventName, func)
  local funcs = g_handlers[eventName]
  if not funcs then
    return
  end
  for i, handler in ipairs(funcs) do
    if handler == func then
      funcs[i] = false
      return
    end
  end
end
def.method("string").onPlayTweenFinish = function(self, id)
  if self.m_panel then
    if id == self.m_panel.name and self.m_disappearing then
      self:_DestroyPanel()
    elseif self:tryget("onCommonPlayTweenFinish") then
      self:onCommonPlayTweenFinish(id)
    end
  end
end
def.virtual("=>", "boolean").IsDebugUI = function(self)
  return false
end
def.virtual("=>", "boolean").OnMoveBackward = function(self)
  if self.m_level > 0 or self.m_bCanMoveBackward then
    self:DestroyPanel()
    return true
  end
  return false
end
def.virtual("=>", "boolean").IsAliveInReconnect = function(self)
  return false
end
ECPanelBase.Commit()
return ECPanelBase
