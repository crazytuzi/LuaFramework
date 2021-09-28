



local _M = {}
_M.__index = _M

print("EventManager init")

local EventCallBacks = {}
local GlobalCallBacks = {}
local EventRecvs = {}
local CSEventManager = CSEventManager

local function globle_callback(resData, ...)
  if resData.data.Count < 2 then
    return
  end

  local eventName = resData.data[0]
  local evtData = resData.data[1]
  local evs = EventCallBacks[eventName]
  
  local params = evtData
  if type(evtData) ~= "table" then
    
    
    params = {}
    local iter = evtData:GetEnumerator()
    while iter:MoveNext() do
      local data = iter.Current
      params[data.Key] = data.Value
    end
  end
  if evs then
    for name,val in pairs(evs) do
      val(eventName, params, ...) 
    end
  end
end

local function Subscribe(sEventName, fCallBack)
  
  if not EventCallBacks[sEventName] then
    EventCallBacks[sEventName] = {}
    CSEventManager.Subscribe(sEventName, globle_callback)
  end
  local evs = EventCallBacks[sEventName]
  table.insert(evs, fCallBack)
end

local function HasSubscribed(sEventName, fCallBack)
  if EventCallBacks[sEventName] then
    for _,v in ipairs(EventCallBacks[sEventName]) do
      if v == fCallBack then
        return true
      end
    end
  end
  return false
end

local function Unsubscribe(sEventName, fCallBack)
  local t = EventCallBacks[sEventName]
  if t then
    for k, fun in pairs(t) do
      if fun == fCallBack then
        table.remove(t, k)
      end
    end
  end

  CSEventManager.Unsubscribe(sEventName, fCallBack)
end

local function UnsubscribeAll()
  
  for name,val in pairs(EventCallBacks) do
    CSEventManager.Unsubscribe(name)
  end
  
  EventCallBacks = {}
  GlobalCallBacks = {}
end

local function Fire(...)
  CSEventManager.Fire(...)
  for _,v in ipairs(GlobalCallBacks) do
    v(...)
  end
end

local function SubscribeGlobalCallBack(fn)
  table.insert(GlobalCallBacks,fn)
end

local function UnsubscribeGlobalCallBack(fn)
  table.insert(GlobalCallBacks,fn)
end

_M.UnsubscribeAll = UnsubscribeAll
_M.Subscribe = Subscribe
_M.Unsubscribe = Unsubscribe
_M.Fire = Fire
_M.HasSubscribed = HasSubscribed
_M.SubscribeGlobalCallBack = SubscribeGlobalCallBack
_M.UnsubscribeGlobalCallBack = UnsubscribeGlobalCallBack

return _M
