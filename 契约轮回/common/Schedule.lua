--
-- Author: LaoY
-- Date: 2018-06-29 20:16:55
--

--定时器 time scale相关未测试
Schedule = Schedule or class("Schedule")

local Schedule = Schedule
local Time = Time
local math_max = math.max

Schedule.ID = 0
function Schedule:ctor()
	self.time_list = {}
	self.time_count = 0
	self.time = 0

	self.is_in_freme_update = false

	self.frame_add_list = {}
	self.frame_del_list = {}

	-- FixedUpdateBeat改为 UpdateBeat，减少消耗
	-- FixedUpdateBeat:Add(self.LateUpdate,self,2,1)
	UpdateBeat:Add(self.LateUpdate,self,2,1)
end

function Schedule:dctor()
	-- FixedUpdateBeat:Remove(self.LateUpdate)
	UpdateBeat:Remove(self.LateUpdate)
end

local status, err
function Schedule:LateUpdate(deltaTime)
	self.is_in_freme_update = true
	local delete_list

	-- 这句代码每帧会分配一次堆内存
	-- local time_id_list = table.keys(self.time_list)
	-- for k,id in pairs(time_id_list) do
	-- 	local vo = self.time_list[id]

	for id,vo in pairs(self.time_list) do
		if vo and vo.id == id then
			local delta = (not vo.scale) and deltaTime or Time.unscaledDeltaTime	
			vo.time = vo.time - delta
			if vo.time <= 0 then
				-- 该函数如果调用C#方法报错，会跳过该帧，定时器会不删除一直报错
				-- vo.func()
				-- 改为安全模式 先运行一段时间，后续移除。pcall也会造成一定的性能消耗
				status, err = pcall(vo.func)
				if not status then
					if AppConfig.Debug then
						logError(vo.source,err)
					else
						logError(err)
					end
					if AppConfig.Debug and PlatformManager and not PlatformManager:GetInstance():IsMobile() then
						vo.func()
					end
				end
				-- if vo.func then
				-- 	vo.func()
				-- end
				if vo.loop > 0 then
					vo.loop = vo.loop - 1
					vo.time = vo.time + vo.duration
				end
				
				if vo.loop == 0 then
					delete_list = delete_list or {}
					delete_list[#delete_list+1] = id
				elseif vo.loop < 0 then
					vo.time = vo.time + vo.duration
				end
			end			
		end
	end

	-- time_id_list = nil

	self.is_in_freme_update = false
	
	if delete_list then
		for k,id in pairs(delete_list) do
			self:Stop(id)
		end
	end

	for id,node in pairs(self.frame_add_list) do
		self.time_list[id] = node
		-- self.frame_add_list[id] = nil
	end
	for k,v in pairs(self.frame_add_list) do
		self.frame_add_list[k] = nil
	end

	for k,id in pairs(self.frame_del_list) do
		self.time_list[id] = nil
		-- self.frame_del_list[k] = nil
	end
	for k,v in pairs(self.frame_del_list) do
		self.frame_del_list[k] = nil
	end
end

function Schedule:Start(func,duration,loop,scale)
	duration = duration or 0
	Schedule.ID = Schedule.ID + 1
	self.time_count = self.time_count + 1
	local node = {
		time_index = Schedule.ID,
		func = func,
		duration = duration,
		loop = loop or -1,
		scale = scale ~= nil and  scale or false,
		time = duration,
		id = Schedule.ID,
	}

	if self.is_in_freme_update then
		self.frame_add_list[Schedule.ID] = node
	else
		self.time_list[Schedule.ID] = node
	end

	if AppConfig.Debug then
		node.source = debug.traceback()
	end
	return Schedule.ID
end

function Schedule:StartOnce(func,duration,scale)
	return self:Start(func,duration,1,scale)
end

function Schedule:Stop(id)
	if not id or not self.time_list[id] then
		return
	end
	self.time_count = math_max(0,self.time_count - 1)
	if self.is_in_freme_update then
		self.frame_del_list[#self.frame_del_list+1] = id
		self.time_list[id].id = -1
		return
	end
	self.time_list[id] = nil
end