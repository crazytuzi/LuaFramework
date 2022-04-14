-- 
-- @Author: LaoY
-- @Date:   2018-08-16 11:58:53
-- 
EventManager = EventManager or class("EventManager",BaseManager)
local EventManager = EventManager

function EventManager:ctor()
	EventManager.Instance = self
	self.event_list = {}
	self.interval_time_list = {}
	self.is_global_init = false
	self:AddEvent()
	self:Reset()
end

function EventManager:Reset()

end

function EventManager.GetInstance()
	if EventManager.Instance == nil then
		EventManager()
	end
	return EventManager.Instance
end

function EventManager:AddEvent()
	local function call_back()
		self:InitGlobalEvent()
	end
	GlobalEvent:AddListener(EventName.HotUpdateSuccess, call_back)
end

--[[
	@author LaoY
	@des	全局间隔时间派发的时间初始化
--]]
function EventManager:InitGlobalEvent()
	if self.is_global_init then
		return
	end
	self.is_global_init = true


	-- test
	-- local name = "aaaa"
	 GlobalEvent:AddTimeBrocast(BagEvent.UpdateGoods,0.2)
	 GlobalEvent:AddTimeBrocast(TeamEvent.NeedUpdateTeamList, 2)
	-- local function call_back(a)
	-- 	Yzprint('--LaoY EventManager.lua,line 48-- a=',a)
	-- end
	-- self.event_id = GlobalEvent:AddListener(name, call_back)
	-- for i=1,10 do
	-- 	GlobalEvent:Brocast(name,i)
	-- end
end

function EventManager:SetEventInfo(event_name,info)
	self.event_list[event_name] = info
end

function EventManager:GetEventInfo(event_name)
	return self.event_list[event_name]
end

function EventManager:StopSchedule(event_name)
	local info = self:GetEventInfo(event_name)
	if not info then
		return
	end
	if info.time_id then
        GlobalSchedule:Stop(info.time_id)
	    info.time_id = false
	    info.next_update_time = false
    end
end

function EventManager:SetEventIntervalTime(event_name,time)
	if self:GetEventInfo(event_name) then
		logError("recall func SetEventIntervalTime",event_name)
		return
	end
	local info = {
        time_id = false,                      	--定时器ID
        interval = time*1000,                   --间隔时间
        count = 0,                          	--间隔时间内需要执行的数量
        callback = false,                     	--回调函数
        last_time = os.clock() - time*1000,		--上一次调用的时间,初始化保证下一次能马上使用
    }
    self:SetEventInfo(event_name,info)
end

function EventManager:TimeBrocast(event_name,callback)
	local info = self:GetEventInfo(event_name)
	if not info then
		if callback then
			callback()
		end
	end
	local cur_time = os.clock()
	local next_update_time
	local time_id
	--距离下次触发剩余的时间
	local last_time = info.interval + info.last_time - cur_time
	last_time = last_time/1000
	if last_time <= 0 then
		if callback then
			callback()
			callback = false
		end
		info.count = 0
		info.last_time = cur_time
		info.callback = false
	else
		info.callback = callback
		info.count = info.count + 1
		if not info.time_id then
			local function func()
				if info.callback then
					info.callback()
				end
				info.last_time = os.clock() - info.interval
				info.time_id = false
				info.callback = false
			end
			info.time_id = GlobalSchedule:StartOnce(func,last_time)
		end
	end
end