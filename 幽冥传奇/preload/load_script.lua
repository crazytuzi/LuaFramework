local load_script = {
	LOAD_STEP = 3,
	script_list = nil, 
	load_total = 0,
	load_done = 0,
	start_time = 0,
	task_status = 0,
}

function load_script:Name()
	return "load_script"
end

function load_script:Start()
	print("load_script:Start")
	if 0 ~= self.start_time then return end

	require(AGENT_PATH .. "agent_adapter2")

	if IS_IOS_OR_ANDROID then
		self.LOAD_STEP = 3
	else
		self.LOAD_STEP = 3
	end

	self.script_list = require("scripts/game/common/require_list")
	if nil == self.script_list then
		self.task_status = MainLoader.TASK_STATUS_EXIT
		return
	end

	self.load_total = #self.script_list
	self.load_done = 0

	self.start_time = NOW_TIME
	self.task_status = MainLoader.TASK_STATUS_FINE

	MainProber:Step(MainProber.STEP_TASK_LOAD_SCRIPT_BEG, self.load_total)
end

function load_script:Stop()
	print("load_script:Stop")
	if 0 == self.start_time then return end

	MainProber:Step(MainProber.STEP_TASK_LOAD_SCRIPT_END, self.load_total, self.load_done)

	self.script_list = nil
	self.load_done = 0
	self.load_total = 0
	self.start_time = 0
	self.task_status = 0
	
	collectgarbage("setpause", 100)
	collectgarbage("setstepmul", 5000)
end

function load_script:Update(dt)
	if 0 == self.start_time then return end

	if self.load_done == self.load_total then
		self.task_status = MainLoader.TASK_STATUS_DONE
		MainLoader:PushTask(require("scripts/play"))
	end

	local start_time = XCommon:getHighPrecisionTime()
	for i = self.load_done, self.load_total - 1 do
		self.load_done = self.load_done + 1
		require(self.script_list[self.load_done])

		if XCommon:getHighPrecisionTime() - start_time >= 0.012 then
			break
		end
	end

	return self.task_status
end

function load_script:Status()
	return self.task_status, self.load_total, self.load_done
end

return load_script 
