

local _M = {}
_M.__index = _M

local FSM = {}
FSM.__index = FSM

local __COMMON_ID__ = 1
local running_stack = {}
local global_api = nil

local all_events = {}

local root_events_id = {}

local message_center = {}
local async_prefix = '_async'
local load_func
local _basicApi = {}
local function GenerateSubId()
	local id = __COMMON_ID__
	__COMMON_ID__ = __COMMON_ID__ + 1
	return id
end

local function SaveEvent(e)
	all_events[e.id] = e
	
end

local function RemoveEvent(e)
	all_events[e.id] = nil
end

local function AddToRoot(e)
	table.insert(root_events_id,e.id)
end

local function GetEvent(id)
	return all_events[id]
end

local function GetAllEvents()
	return all_events
end

local function OnRootEventUpdate(delta)
	for i=#root_events_id,1,-1 do
		local root = GetEvent(root_events_id[i])
		if root:IsComplete() then
			root:Log(1, 'Stop.')
			root:RemoveEvents(true)
			RemoveEvent(root)
			table.remove(root_events_id,i)
		else
			root:Update(delta)
		end
	end
end

local function OnReciveMessage(msgname,...)
	for i=#root_events_id,1,-1 do
		local root = GetEvent(root_events_id[i])
		root:OnReciveMessage(msgname,...)
	end
end


function _M.SetLogLevel(self,lv)
	self.LogLevel = lv
end



local function PushRunning(e)
	
	table.insert(running_stack, e)
end

local function PeekRunning()
	
	return running_stack[#running_stack]
end


local function PopRunning()
	
	table.remove(running_stack)
end



function FSM.Change(self,from,to,do_now)
	local next_state 
	if type(from) == 'table' then
		for _,v in ipairs(from) do
			if v == self.state then
				next_state = to
				break
			end
		end
	elseif self.state == from then
		next_state = to
	end
	if not next_state then
		
		
		return
	end
	
	if do_now and self.cb then
		self.cb(self.own,'leave',self.state)
		self.state = next_state
		self.cb(self.own,'enter',self.state)
	else
		table.insert(self.trans,next_state)
		self.state = next_state
	end	
end


	

function FSM.Create(fsm_table,own,cb)
	local ret = {trans = {},cb = cb,own = own}
	setmetatable(ret,FSM)
	for name,event in pairs(fsm_table) do
		
		ret[name] = function (fsm,now)
			fsm:Change(event.from,event.to,now)
		end
	end
	return ret
end

function FSM.IsState(self,state)
	return self.state == state
end

function FSM.Update(self)
	local pre_state = nil
	local count = 0
	while self.cb and #self.trans > 0 do
		local state = self.trans[1]
		if pre_state then
			
			self.cb(self.own,'leave',pre_state)
		end
		
		self.cb(self.own,'enter',state, pre_state)
		pre_state = state
		table.remove(self.trans,1)
		count = count + 1
		if count > 200 then
			error('while true')
		end
	end
end

local STATE = 
{
	INIT = 'init',
	RUNNING = 'running',
	SUSPENDED = 'suspended',
	CLOSE = 'close',
	INVALID = 'invalid',
}

local FSM_DRAMA_TABLE = {
	Init = {to = STATE.INIT},
	Run = {from = {STATE.INIT,STATE.SUSPENDED}, to = STATE.RUNNING},
	Suspend = {from = STATE.RUNNING, to = STATE.SUSPENDED},
	Close = {from = {STATE.SUSPENDED,STATE.RUNNING}, to = STATE.CLOSE}, 
	Invalid = {from = STATE.CLOSE, to = STATE.INVALID}
}

local function CheckRunning(co,running)
	local runing_co = coroutine.running()
	if runing_co ~= co and running then
		error('coroutine not running!')
	elseif runing_co == co and not running then
		error('coroutine is running!')
	end
end


local function Resume(self,...)
	
	local status = coroutine.status(self.co)
	if status ~= 'suspended' then
		self:Log(2,'coroutine status is not suspended ',status)
		return status
	end
	PushRunning(self)
	local ret = {coroutine.resume(self.co,...)}
	self:Log(1,'Resume',unpack(ret))
	if not ret[1] then	
		if not self.killed then
			error(debug.traceback(self.co)..ret[2])
		end
		self:Done()
	else
		self:SetOutput(unpack(ret,2))
	end
	PopRunning()
	return coroutine.status(self.co)
end

local function fsm_callback(self,actname,state,prestate)
	
	if state == STATE.INVALID and actname == 'enter' then
		if self.invaild_cbs then
			for _,v in ipairs(self.invaild_cbs) do
				v()
			end
		end

		if not self.parent then			
			
			PushRunning(self)
			for k,v in pairs(global_api) do
				local clear_func
				if k == 'Clear' and type(v) == 'function' then
					clear_func = v
				elseif type(v) == 'table' then
					clear_func = v.Clear
				end
				if clear_func then
					clear_func()
				end
			end
			self:Log(1, 'Clear.')
			PopRunning()
		end
		self._cacheduserdata = nil
	elseif state == STATE.CLOSE and actname == 'enter' then
		self:CleanTimer()
		self:CleanEvents()
	elseif state == STATE.RUNNING and actname == 'enter' then
		self:Log(1,'Start.')
		self.wait_all = false	
		self.sleep_time = nil
		self.await = nil
		local status = Resume(self, self, unpack(self.params))
		if status == 'dead' then
			self.fsm:Close()
			self:Log(2,'Close State.')
		elseif self.killed then
			self.fsm:Run(false)
		else
			self.fsm:Suspend(false)
		end
	end
end





















local function CreateDramaEvent(name,run_func,...)
	
	
	
	

	local self = {
		name = name,
		events = {}, 
		co = coroutine.create(run_func), 
		params = {...}, 
		api = global_api,
		id = GenerateSubId(),
		LogLevel = 0,
	}
	setmetatable(self,_M)
	self.fsm = FSM.Create(FSM_DRAMA_TABLE,self,fsm_callback)
	self.fsm:Init(true)
	SaveEvent(self)
	return self
end

local function CreateAsyncApi(fun_name,fn)
	return function (...)
		local running_event = PeekRunning()
		running_event:Log(2,'call',fun_name, ...)
		local e =  CreateDramaEvent(fun_name,fn,...)
		return running_event:AddEvent(e)		
	end
end

local function CreateSyncApi(fun_name,fn)
	return function (...)
		local running_event = PeekRunning()
		running_event:Log(2,'call',fun_name, ...)
		if running_event.killed and fun_name ~= 'Clear' then 
		 	return nil 
		end	
		local ret = {fn(running_event, ...)}
		if #ret > 0 then
			running_event:Log(2,'return',unpack(ret))
		end
		return unpack(ret)	
	end
end


local function Schdule(self,delta)
	for k,v in pairs(self.timers or {}) do
		v.ct = v.ct + delta
		if v.ct >= v.t then
			v.ct = 0
			local pass_time = v.t
			if pass_time < delta then
				pass_time = delta
			end
			
			self.LogLevel = self.LogLevel - 1
			v.func(pass_time,k)
			self.LogLevel = self.LogLevel + 1
			if v.once then
				if v.wait and not self.wait_all_timer then
					self.fsm:Run(false)
				end
				self:RemoveTimer(k)
			end
		end
	end
	if self.wait_all_timer then
		local count = 0
		for _,v in pairs(self.timers or {}) do
			count = count + 1
		end
		if count == 0 then
			self.fsm:Run(false)
		end
	end
end

function _M.Log(self,lv,...)
	if (self.LogLevel or 0) >= lv then
		local t = {...}
		local traceback = self.traceback
		local p = self.parent
		while p and traceback and p.traceback do
			traceback = traceback..'\n\n'..p.traceback
			p = p.parent
		end
		if traceback then
			table.insert(t,'\n\n'..traceback)
		end
		print('['..(self.name or 'undefined')..'] ',unpack(t))
	end
end


function _M.GetRootEvent(self)
	if not self.parent then
		return self
	end
	if not self._root then
		self._root =  self.parent:GetRootEvent()
	end
	return self._root
end


function _M.GetCacheduserdata(self,id)
	local ret = self._cacheduserdata and self._cacheduserdata[id] or {}
	return unpack(ret)
end

function _M.RemoveCacheduserdata(self,id)
	if self._cacheduserdata then
		
		self._cacheduserdata[id] = nil
	end
end

function _M.ForeachCacheduserdata(self,func)
	for id,v in pairs(self._cacheduserdata or {}) do
		func(id,unpack(v))
	end
end

function _M.AddCacheduserdata(self,obj,...)
	self._cacheduserdata = self._cacheduserdata or {}
	local id
	for i,v in pairs(self._cacheduserdata) do
		if v.obj == obj then
			id = i 
			break
		end
	end
	if not id then
		id = GenerateSubId()
	end
	local n = {...}
	table.insert(n,1,obj)
	self._cacheduserdata[id] = n
	return id
end

function _M.GenerateSubId()
	return GenerateSubId()
end

function _M.AddEvent(self,e)
	if self.killed or self.fsm:IsState(STATE.INVALID) then 
		return nil
	else
		self.events[e.id] = {e = e}
		e.parent = self
		e.LogLevel = self.LogLevel
		e.killed = nil
		e.fsm:Run(false)
		e.traceback = debug.traceback(self.co)
		e:Log(2,'AddEvent and Run')
		return e.id		
	end
end

function _M.IsComplete(self)
	return self.fsm:IsState(STATE.INVALID)
end

function _M.Await(self,second)
	if not self.fsm:IsState(STATE.RUNNING) then return end
	CheckRunning(self.co,true)
	self.sleep_time = second
	self.await = true
	self:Log(2,'await',second)
	self.fsm:Suspend(false)
	coroutine.yield()
end

function _M.WaitSelectsClose(self,ids,params)
	self:Log(2,'WaitSelectsClose')
	CheckRunning(self.co,true)

	for i,v in ipairs(ids) do
		local n = self.events[v]
		if n then
			n.wait = true
			if i == 1 then
				n.wait_params = params
			end
			n.select_list = ids
		end
	end
	self.fsm:Suspend(false)
	coroutine.yield()	
end

function _M.WaitTimer(self,t_id)
	CheckRunning(self.co,true)
	if t_id then
		local t = self.timers[t_id]
		t.wait = true
		self:Log(2,'WaitTimer',t)
	else
		self.wait_all_timer = true
		self:Log(2,'WaitAllTimer')
	end
	self.fsm:Suspend(false)
	coroutine.yield()
end


function _M.WaitClose(self,e_id,params)
	self:Log(2,'WaitClose',e_id)
	CheckRunning(self.co,true)
	local n = self.events[e_id]
	if n then
		if self.fsm:IsState(STATE.INVALID) then
			return n.e.GetOutputValue()
		end
		n.wait = true
		if type(params) == 'table' then
			n.wait_params = params
		end
		self:Log(2,'wait',n.e.name)
	else
		self.wait_all = true
		self:Log(2,'wait_all')
	end
	self.fsm:Suspend(false)
	coroutine.yield()
	self:Log(2,'WaitClose Cross',e_id)
	if n then
		local ret = n.e.output
		if ret and #ret > 0 then
			self:Log(2,'return',unpack(ret))
		end
		return unpack(ret)
	end
end

function _M.GetEvent(self,id)
	return self.events[id].e
end

function _M.GetOutputValue(self)
	return unpack(self.output)
end

function _M.SetAttribute(self,k,v)
	self.Attributes = self.Attributes or {}
	self.Attributes[k] = v
end

function _M.HasAttribute(self,k)
	if self.Attributes then
		return self.Attributes[k] ~= nil
	else
		return false
	end
end

function _M.GetAttribute(self,k)
	if self.Attributes then
		return self.Attributes[k]
	else
		return nil
	end
end

function _M.AddTimer(self, update_func, t, once)
	self.timers = self.timers or {}
	local timeId = GenerateSubId()
	self.timers[timeId] = {func = update_func, t = t or 0, once = once, ct = 0}
	self:Log(1,"AddTimer", timeId)
	return timeId
end

function _M.AddInvalidCB(self,cb)
	self.invaild_cbs = self.invaild_cbs or {}
	table.insert(self.invaild_cbs,cb)
end


function _M.RemoveTimer(self,timeId)
	if timeId and self.timers then
		self:Log(1,'RemoveTimer',timeId)
		self.timers[timeId] = nil
	end
end

function _M.CleanTimer(self)
	self.timers = {}	
end

function _M.RemoveEvents(self,recursive)
	for k,v in pairs(self.events) do
		if recursive then
			v.e:RemoveEvents(recursive)
		end
		RemoveEvent(v.e)
	end
end

function _M.CleanEvents(self)
	for k,v in pairs(self.events) do
		v.wait = nil
		v.wait_params = nil
		v.e:Done()
	end
	self:Log(2,'CleanEvents.')
	
end

function _M.SetClearOnExit(self,val)
	self.clear_on_exit = val
end

function _M.SetOutput(self,...)
	self.output = {...}
end

















function _M.SetTimeout(self,sec)
	
	self:RemoveTimer(self._timeout_tid)
	if sec >= 0 then
		self._timeout_tid = self:AddTimer(function ()
			self:Done()
		end,sec,true)
	end
end

function _M.Done(self,...)
	if self:IsComplete() then
		return
	end
	if not self.output then
		self:SetOutput(...)
	end
	self.killed = true
	self:Log(2,'Done.')
	self.fsm:Run(false)
	if self.done_cb then
		self.done_cb()
	end
end


function _M.Update(self,delta)
	if self.fsm:IsState(STATE.INIT) or self.fsm:IsState(STATE.INVALID) then
		return
	end
	
	PushRunning(self)
	Schdule(self,delta)
	PopRunning()
	self.fsm:Update()
	
	local check_empty = true
	for k,v in pairs(self.events) do
		local e = v.e
		e:Update(delta)
		if v.wait and v.wait_params then
			PushRunning(self)
			local up_func = v.wait_params.update
			if up_func and type(up_func) == 'function' then
				up_func(delta)
			end
			if v.wait_params.timeout then
				if v.wait_params.timeout > 0 then
					v.wait_params.timeout = v.wait_params.timeout - delta
				else
					e:Done()
				end
			end	
			PopRunning()
		end
		if e.fsm:IsState(STATE.INVALID) then
			if v.wait then
				self:Log(2,'wait to resume')
				if not self.wait_all then
					self.fsm:Run(false)
				end
				check_empty = false
				v.wait = nil
				v.wait_params = nil
				if v.select_list then
					
					for w,uid in ipairs(v.select_list) do
						local sub_e = self.events[uid]
						if sub_e then
							sub_e.wait = nil
							sub_e.wait_params = nil
							sub_e.select_list = nil
							sub_e.e:Done()
						end
					end
				end
				v.select_list = nil
			end
		else
			check_empty = false
		end
	end
	if check_empty then
		if self.killed then
			self.fsm:Invalid(true)
			self:Log(2,'invaild')
			
			return
		elseif not self.await and not self.fsm:IsState(STATE.SUSPENDED) then
	 		self:Done()
	 	elseif self.wait_all then
	 		self.fsm:Run(false)
		end
	end
	
	if self.await and self.sleep_time ~= nil then
		if self.sleep_time > 0 then
			self.sleep_time = self.sleep_time - delta
		else
			self.fsm:Run(false)
		end
	end
end



local function GetApi()
	return global_api
end


function _M.GetName(self)
	return self.name
end

function _M.GetID(self)
	return self.id
end

function _M.UnsubscribeMessage(self,msgname,fn)
	local h = self._message_center[msgname]
	if not fn then
		self._message_center[msgname] = nil
	else
		for i,v in ipairs(h or {}) do
			if v == fn then
				table.remove(h, i)
				break
			end
		end
	end
end

function _M.SubscribMessage(self, msgname, fn)
	self._message_center = self._message_center or {}
	self._message_center[msgname] = self._message_center[msgname] or {}
	table.insert(self._message_center[msgname], fn)
end

function _M.OnReciveMessage(self, msgname, ...)
	for k,v in pairs(self.events) do
		local e = v.e
		e:OnReciveMessage(msgname,...)
	end
	if self._message_center then 
		
		local h = self._message_center[msgname]
		for i,v in ipairs(h or {}) do
			v(msgname,...)
		end
	end
end






local function CreateApi(cur_api, name, func)
	if string.find(name,async_prefix) then
		local fun_name = string.sub(name,string.len(async_prefix) + 1)
		cur_api[fun_name] = CreateAsyncApi(fun_name,func)
	else
		cur_api[name] = CreateSyncApi(name,func)
	end	
end

local function RegisterApi(api_table, api_name)
	if not global_api then
		global_api = {}
		RegisterApi(_basicApi)
	end
	local cur_api
	if not api_name then
		cur_api = global_api
	else
		cur_api = global_api[api_name] or {}
		global_api[api_name] = cur_api
	end
	for k,v in pairs(api_table) do
		if type(v) == 'function' then
			CreateApi(cur_api,k,v)
		elseif k ~= '__index' then
			cur_api[k] = v
		end
	end	
end

local function GetRunningEvent(parent)
	return PeekRunning()
end

local function FroceStopScrpt(id)
	if not id then
		for i=#root_events_id,1,-1 do
			local root = GetEvent(root_events_id[i])
			root:Done()
			root:Update(0)
		end
	else
		local e = GetEvent(id)
		if e and not e.parent then
			e:Done()
			e:Update(0)
		end
	end
end

local function StopScript(id)
	if not id then
		for i=#root_events_id,1,-1 do
			local root = GetEvent(root_events_id[i])
			root:Done()
		end
	else
		local e = GetEvent(id)
		if e and not e.parent then
			e:Done()
		end
	end
end

local function IsScriptExist(id)
	local e = GetEvent(id)
	return e ~= nil and not e.parent
end

local function RegisterLoadFunction(func)
	if type(func) == 'function' then
		load_func = func
	end
end

local function Update(delta)
	OnRootEventUpdate(delta)
end

local function CreateScript(script_name,...)
 	if not load_func then
 		error('not register load function')
 	end
 	local ret = load_func(script_name)
	if not ret then
		return nil
	end
	local function node_func(node,...)
        if(string.find(script_name,"yy"))then
            DataMgr.Instance.UserData.PlayDrama = true;
        end
		ret.start(node.api,...)
	end
	return CreateDramaEvent(script_name,node_func,...)
end

local function FindScriptIDByName(script_name)
	for id, v in pairs(all_events) do
		if v.name == script_name then
			return id
		end
	end
end

local function GetAllScriptNames()
	local ret = {}
	for _,v in ipairs(root_events_id) do
		local root = GetEvent(v)
		table.insert(ret,root.name)
	end
	return ret
end

local function SendMessage(msgname, ...)
	
	OnReciveMessage(msgname,...)
end

function _M.SetRootEvent(self)
	if self.parent then
		error('root event has parent')
	end
	self.killed = nil
	self.fsm:Run(false)
	AddToRoot(self)
end






function _basicApi.Exit(parent)
	parent:GetRootEvent():Done()
end

function _basicApi.Wait(parent,id,params) 
	return parent:WaitClose(id,params)
end

function _basicApi.WaitTimer(parent,tid)
	parent:WaitTimer(tid)	
end


function _basicApi.WaitSelects(parent,ids,params)
	parent:WaitSelectsClose(ids,params)
end

function _basicApi.Sleep(parent,second)
	if second < 0 then
		parent:Await()
	else
		parent:Await(second)
	end
end

function _basicApi.AddPeriodicTimer(parent, t, update_func)
	return parent:AddTimer(update_func,t,false)
end

function _basicApi.RemoveTimer(parent,tid)
	parent:RemoveTimer(tid)
end

function _basicApi._asyncSubscribOnReciveMessage(self,msgname)
	self:SubscribMessage(msgname,function (name,...)
		self:Done(...)
	end) 
	self:Await()
end

function _basicApi.SendMessage(parent,msgname,...)
	SendMessage(msgname,...)
end

function _basicApi.StopEvent(parent,e_id)
	if not e_id then
		parent:Done()
	else
		local e = GetEvent(e_id)
		if e then
			e:Done()
		end
	end
end

function _basicApi.AddEvent(parent,func,...)
	local fn = CreateAsyncApi('custom_func', func)
	return fn(...)
end

function _basicApi.SetMyName(parent,name)
	parent.name = name
end

function _basicApi.GetMyName(parent)
	return parent.name
end

function _basicApi.SetTimeout(parent,sec)
	parent:SetTimeout(sec)
end


return
{
	
	Update = Update,
	RegisterApi = RegisterApi,
	GetApi = GetApi,	
	StopScript = StopScript,
	FroceStopScrpt = FroceStopScrpt,
	CreateScript = CreateScript,
	IsScriptExist = IsScriptExist,
	FindScriptIDByName = FindScriptIDByName,
	GetAllScriptNames = GetAllScriptNames,
	GetRunningEvent = GetRunningEvent,
	RegisterLoadFunction = RegisterLoadFunction,
	SendMessage = SendMessage,
}
