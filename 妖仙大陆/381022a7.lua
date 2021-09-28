

local Helper = require 'Zeus.Logic.Helper'
local Util   = require 'Zeus.Logic.Util'

local _M = {}

_M.__index = _M

local function GetComponent(self,key)
	return self.menu:GetComponent(key)
end

local function SetClickEvent(node,func)
	local t = {node = node,click = func}
	LuaUIBinding.HZPointerEventHandler(t)
end

local function Close(self)
  self.menu:Close()  
end

local function OnEnter(self)
	self.IsRunning = true
	for _,v in ipairs(self._on_enter_cbs or {}) do
		v(self)
	end
end

local function OnExit(self)
	self.IsRunning = false
	for _,v in ipairs(self._on_exit_cbs or {}) do
		v(self)
	end
end

local function OnDestory(self)
	for _,v in ipairs(self._on_destory_cbs or {}) do
		v(self)
	end	
end

local function GenUITag()
	local startTag = GlobalHooks.UITAG.GameUICustomStart
	local tag = math.random(startTag,startTag+1000)
	if not (MenuMgrU.Instance:GetCacheUIByTag(tag) and GlobalHooks.FindUI(tag)) then
		return tag
	else
		return GenUITag()
	end
end

local function InitComponent(self,xmlpath,uitag)
	
	local tag = uitag or GenUITag()
	self.menu = LuaMenuU.Create(xmlpath,tag)

  self.menu:SubscribOnExit(function ()
    OnExit(self)
  end)
  self.menu:SubscribOnEnter(function ()
    OnEnter(self)
  end)
  self.menu:SubscribOnDestory(function ()
    OnDestory(self)
  end)
  self.menu.ShowType = UIShowType.Cover
  self.menu.Enable = false
  local btn_close = GetComponent(self,'btn_close')
  if btn_close then
  	
  	SetClickEvent(btn_close,function (sender)
  		Close(self)
  	end)
  end

  local btn_back = GetComponent(self,'btn_back')
  if btn_back then
  	SetClickEvent(btn_back,function (sender)
  		Close(self)
  	end)
  end
end


local function Create(xmlpath,tag)
  local ret = {}
  setmetatable(ret, _M)
  InitComponent(ret,xmlpath,tag)
  return ret
end

local function AddExitEvent(self,cb)
	self._on_exit_cbs = self._on_exit_cbs or {}
	table.insert(self._on_exit_cbs,cb)
end

local function AddDestoryEvent(self,cb)
	self._on_destory_cbs = self._on_destory_cbs or {}
	table.insert(self._on_destory_cbs,cb)	
end

local function AddEnterEvent(self,cb)
	self._on_enter_cbs = self._on_enter_cbs or {}
	table.insert(self._on_enter_cbs,cb)	
end

local function RemoveAllExitEvent(self)
	self._on_exit_cbs = nil
end

local function RemoveAllDestoryEvent(self)
	self._on_destory_cbs = nil
end

local function RemoveAllEnterEvent(self)
	self._on_enter_cbs = nil
end

_M.Create = Create
_M.Close  = Close
_M.GetComponent = GetComponent
_M.AddExitEvent = AddExitEvent
_M.AddEnterEvent = AddEnterEvent
_M.AddDestoryEvent = AddDestoryEvent

_M.RemoveAllExitEvent = RemoveAllExitEvent
_M.RemoveAllDestoryEvent = RemoveAllDestoryEvent
_M.RemoveAllEnterEvent = RemoveAllEnterEvent


return _M
