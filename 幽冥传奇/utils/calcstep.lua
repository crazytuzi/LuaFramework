------------------------------------------------------
--分步式计算。含：
-- 一. 分步式计算器 目的是解决for循环带来的性能问题。
--注意点：
--1.调用接口都应直接调用CalcStep提供的
--2.调用StartCalc后持有calcstepimpl的引用。尽量start前先尝试停止上次的。避免不必要的计算
--3.在计算方法里，一般只做界面刷新操作，原则上不直接提供给外部调用的数据。

-- 二. 系统运算队列 是为了解决单帧上处理计算过大，将分到各帧上进行处理
--注意点：
--1.对一些计算要注意取消，避免造成回调时调用已经失效的方法
--2.提供计算速度参数，需要较快速度算出结果，可设置快速计算 CALC_HIGHEST

-- 三.延迟指定帧计算
--@author bzw
------------------------------------------------------
CalcStep = CalcStep or BaseClass()
CalcStep.calcer_list = {}
CalcStep.system_calc_queues = {}
CalcStep.calc_delay_list = {}
CalcStep.pause_step = 0
CalcStep.current_step = 0
CalcStep.is_pause_refresh = false

CALC_HIGHEST = 1   			--快速结束计算
CALC_MIDDLE = 2				--中速结束计算
CALC_LOWER = 3				--慢速结束计算

function CalcStep:__init()
	if CalcStep.Instance ~= nil then
		Error("CalcStep has been created.")
	end
	CalcStep.Instance = self

	self.sys_calc_max_num_in_step = 3 		 --在每步中处理的默认最大个数
	
	Runner.Instance:AddRunObj(self, 5)
end

function CalcStep:__delete()
	CalcStep.Instance = nil
	Runner.Instance:RemoveRunObj(self)

	for k,v in pairs(CalcStep.calcer_list) do
		v:DeleteMe()
	end
	CalcStep.calcer_list = {}
end

function CalcStep.SetIsPuaseRefresh(is_pause_refresh)
	CalcStep.is_pause_refresh = is_pause_refresh
end

----------------------------------------------------
--分步式计算器
-----------------------------------------------------
--开始计算，返回新的计算器。一般用来代替引影响性能的for循环
--@step_start 开始的步，相当于for的i初始值
--@step_len 步长 for循环的长度
--@calc_fun 每步执行的方法
--@calc_end_callback 全部执行完后调用的方法
--@stepbystep 每帧执行n步。值越大越计算完成越快
function CalcStep.StartCalc(step_start, step_len, calc_fun, calc_end_callback, stepbystep)
	local step_impl = CalcStepImpl.New()

	if step_start == nil or step_len == nil or calc_fun == nil then
		return step_impl
	end

	if step_start > step_len then
		return step_impl
	end

	step_impl:StartCalc(step_start, step_len, calc_fun, calc_end_callback, stepbystep)
	table.insert(CalcStep.calcer_list, step_impl)
	return step_impl
end

--停止指定的计算器
function CalcStep.StopCalc(step_impl)
	for k,v in pairs(CalcStep.calcer_list) do
		if v == step_impl then
			v:DeleteMe()
			table.remove(CalcStep.calcer_list, k)
			break
		end
	end
end

--分步运算计算器
function CalcStep:StepCalceCalcer(now_time, elapse_time)
	local stop_list = {}
	for k,v in pairs(CalcStep.calcer_list) do
		v:Update(now_time, elapse_time)

		if v:GetIsCalcEnd() then
			table.insert(stop_list, k)
		end
	end

	if #stop_list > 0 then
		for i=#stop_list, 1, -1 do
			CalcStep.calcer_list[i]:OnCalcEnd()
			CalcStep.calcer_list[i]:DeleteMe()
			table.remove(CalcStep.calcer_list, stop_list[i])
		end
	end
end

-----------------------------------------------------
--系统运算队列
-----------------------------------------------------
--将计算增加到系统计算队列。由系统对计算进行统一控制与优化
--@key 索引，用于删除。一般直接指定self
--@calc_fun 计算方法
--@calc_speed 计算速度，有CALC_HIGHEST，CALC_MIDDLE，CALC_LOWER 3种值。
--注：不重要的计算，如界面暂时看不到的，calc_speed设置为CALC_LOWER，将有效提升性能
function CalcStep.AddToSystemCalcQueue(key, calc_fun, calc_speed, batch)
	local calc_t = {
		key = key, 
		calc_fun = calc_fun,
		step = calc_speed or CALC_HIGHEST,
		calc_speed = calc_speed or CALC_HIGHEST,
		batch = batch,
		}

	local queue = CalcStep.system_calc_queues[batch]
	if queue == nil then
		queue = {}
		CalcStep.system_calc_queues[batch] = queue
	end
	table.insert(queue, calc_t)
end

--从系统计算队列中移除，避免回调时调到已经失效的方法
--注：一般在__delete里移除
function CalcStep.RemoveFromSystemCalcQueue(key)
	for k,v in pairs(CalcStep.system_calc_queues) do
		local len = #v
		for i = len, 1, -1 do
			if v[i].key == key then
				table.remove(v, i)
			end
		end
	end
end

--移除计算批次
function CalcStep.RemoveCalcBatch(batch)
	CalcStep.system_calc_queues[batch] = nil
end

--系统运算队列
function CalcStep:StepCalcQueue(queue, now_time, elapse_time)
	local calc_num = 0
	local highest_calc_num = 0
	local calc_index_list = {}

	local calc_t = queue[1]
	if calc_t == nil then
		table.remove(queue, 1)
		return
	end

	if calc_t.step > 1 then
		calc_t.step = calc_t.step - 1
		return
	end

	local calc_num = 0
	local start_time = os.clock()
	local end_time = start_time
	for i=1,self.sys_calc_max_num_in_step do
		calc_t = queue[1]		
		if calc_t ~= nil then
			calc_t.step = calc_t.step - 1
			if calc_t.step <= 0 then
				if calc_t.calc_fun ~= nil then
					calc_t.calc_fun()
					calc_num = calc_num + 1
				end
				table.remove(queue, 1)
			end
		end
		
		end_time = os.clock()
		if end_time - start_time > 0.006 then
			break
	 	end
	end
	-- Log("calc_num:",calc_num, end_time - start_time)
end

-----------------------------------------------------
--延迟指定帧计算
-----------------------------------------------------
function CalcStep.AddDelayStepCallback(callback, step)
	if callback == nil or step == nil then return end

	local t = {dostep = CalcStep.current_step + step, callback = callback}
	table.insert(CalcStep.calc_delay_list, t)
	return t
end

function CalcStep:RemoveDelayStepCall(key)
	local len = #CalcStep.calc_delay_list
	for i=len, 1, -1 do
		if CalcStep.calc_delay_list[i] == key then
			table.remove(CalcStep.calc_delay_list, i)
		end
	end
end

function CalcStep:CalcDelayStepCallback(now_time,elapse_time)
	local len = #CalcStep.calc_delay_list
	for i=len, 1, -1 do
		local calc_t = CalcStep.calc_delay_list[i]
		if CalcStep.current_step >= calc_t.dostep then
			if calc_t.callback ~= nil then calc_t.callback() end

			table.remove(CalcStep.calc_delay_list, i)
		end
	end
end

--计算过程
function CalcStep:Update(now_time, elapse_time)
	if CalcStep.is_pause_refresh then
		return
	end
	
	CalcStep.current_step = CalcStep.current_step + 1

	if #CalcStep.calcer_list > 0 then
		self:StepCalceCalcer(now_time, elapse_time)
	end

	for k,v in pairs(CalcStep.system_calc_queues) do
		self:StepCalcQueue(v, now_time, elapse_time)
		if #v == 0 then
			CalcStep.system_calc_queues[k] = nil
		end
	end

	if #CalcStep.calc_delay_list > 0 then
		self:CalcDelayStepCallback(now_time,elapse_time)
	end
end


------------------------------------------------------
--分步式计算实例。以下方法外部不能直接调用。调用接口都应调用CalcStep提供的
--@author bzw
------------------------------------------------------
CalcStepImpl = CalcStepImpl or BaseClass()
function CalcStepImpl:__init()
	self.cur_step = 0
	self.step_len = 0
	self.calc_fun = nil
	self.calc_end_callback_list = nil
	self.stepbystep = 1
end

function CalcStepImpl:__delete()
	self.calc_fun = nil
end

function CalcStepImpl:StartCalc(step_start, step_len, calc_fun, calc_end_callback, stepbystep)
	self.cur_step = step_start
	self.step_len = step_len
	self.stepbystep = stepbystep or 1
	self.calc_fun = calc_fun
	self:AddCalcEndCallback(calc_end_callback)
end

function CalcStepImpl:GetIsCalcEnd()
	return self.cur_step > self.step_len
end

function CalcStepImpl:AddCalcEndCallback(calc_end_callback)
	if self.calc_end_callback_list == nil then
		self.calc_end_callback_list = {}
	end
	table.insert(self.calc_end_callback_list, calc_end_callback)
end

function CalcStepImpl:OnCalcEnd()
	for k,v in pairs(self.calc_end_callback_list) do
		v()
	end
end

function CalcStepImpl:Update(now_time, elapse_time)
	for i=1,self.stepbystep do
		if self.cur_step <= self.step_len then
			if self.calc_fun ~= nil then
				self.calc_fun(self.cur_step)
			end
			self.cur_step = self.cur_step + 1
		end
	end
end

