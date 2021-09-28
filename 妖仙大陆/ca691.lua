










local UpdateEvents = {}
local LateUpdateEvents = {}
local FixedUpdateEvents = {}
local now_scene = nil


local Guide_Closed_Mask = nil


local Customer_Service_Mask = nil

CSEventManager = EventManager

EventManager = require"Zeus.Logic.EventManager"
cjson = require"cjson"

_ = {}

emptyFunc = function() end
emptyTable = {}

Pomelo = {}

SearchPath = {
  "Zeus/UI/",
  "Zeus/Logic/",
  "Zeus/Model/",
  "Xmds/Pomelo/",
  "Zeus/Scene/",
}


GlobalHooks = {
  InitNetWork = function()
    if now_scene then
      now_scene.InitNetWork()
    end
  end,
  Fin = function (relogin)
    if now_scene then
      now_scene.fin(relogin)
    end
    
    UpdateBeat:Clear()
    LateUpdateBeat:Clear()
    FixedUpdateBeat:Clear()
    EventManager.UnsubscribeAll()
    
    
    
    
  end,
  Init = function (self)
    
    print("GlobalHooks.init")
    require"Xmds.Pomelo.Pomelo"

    UpdateBeat:Add(OnMainUpdate, self)
    LateUpdateBeat:Add(OnMainLateUpdate, self)
    FixedUpdateBeat:Add(OnMainFixedUpdate, self)
    EventManager = require"Zeus.Logic.EventManager"
    now_scene = require"Zeus.Scene.Battle"
    now_scene:init()
  end,
  InitGuideMask = function ()
    DataMgr.Instance.UserData:SetClientConfig("guide_closed",Guide_Closed_Mask,false)
    DataMgr.Instance.UserData:SetClientConfig("customer_closed",Customer_Service_Mask,false)
  end,
  DynamicPushs = {},
  HudVals = {},
  talkVoicePath = nil,
  playTalkVoice = function(path)
    if GlobalHooks.talkVoicePath then
        GlobalHooks.stopTalkVoice(GlobalHooks.talkVoicePath)
    end
    GlobalHooks.talkVoicePath = path
    XmdsSoundManager.GetXmdsInstance():PlaySound(path)
  end,
  stopTalkVoice = function(path)
    XmdsSoundManager.GetXmdsInstance():stopClipSource(path)
  end,
}

require"shortcut"
require "Zeus.Model.DataHelper"

function OnMainUpdate(deltatime, unscaledDeltaTime)
  Time:SetDeltaTime(deltatime, unscaledDeltaTime)
  
  
  for name, val in pairs(UpdateEvents) do
    val(deltatime)
  end
  if now_scene then
    now_scene:update(deltatime)
  end
end

function OnMainLateUpdate()
  
  
  
  for name, val in pairs(LateUpdateEvents) do
    val()
  end
end

function OnMainFixedUpdate(fixedTime)
  
  
  
  for name, val in pairs(FixedUpdateEvents) do
    val(fixedTime)
  end
end

function OnLevelWasLoaded(level)
  print("[OnLevelWasLoaded]", level)
end

function AddUpdateEvent(name, fun)
  
  if(UpdateEvents[name]) then
      return
  end
  UpdateEvents[name] = fun
end

function AddLateUpdate(name, fun)
  
  if(LateUpdateEvents[name]) then
      return
  end
  LateUpdateEvents[name] = fun
end

function AddFixedUpdate(name, fun)
  
  if(FixedUpdateEvents[name]) then
      return
  end
  FixedUpdateEvents[name] = fun
end

function RemoveUpdateEvent(name, force)
  if not force then
    
  end
  UpdateEvents[name] = nil
end

function RemoveLateUpdate(name)
  
  if(LateUpdateEvents[name]) then
      return
  end
  LateUpdateEvents[name] = nil
end

function RemoveFixedUpdate(name)
  
  if(FixedUpdateEvents[name]) then
      return
  end
  FixedUpdateEvents[name] = nil
end

function Main()
  print("[Lua Main]")

  

  
end
