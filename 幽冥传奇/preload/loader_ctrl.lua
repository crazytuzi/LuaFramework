MainLoader = {
	TASK_STATUS_EXIT = 1,
	TASK_STATUS_FINE = 2, 
	TASK_STATUS_DONE = 3,

	parall_list = {},

	serial_list = {},
	serial_head = nil,
	serial_stop = false,

	view = nil,
}

function MainLoader:Start()
	print("MainLoader:Start")
	MainProber:Step(MainProber.STEP_MAIN_LOADER_BEG)
	self:PushTask(require(AGENT_PATH .. "agent_adapter"))
end

function MainLoader:Stop()
	print("MainLoader:Stop")
	if nil ~= self.serial_head then
		self.serial_head:Stop()
		self.serial_head = nil
	end
	self.serial_list = {}

	for i = #self.parall_list, 1, -1 do
		local task = self.parall_list[i]
		if nil ~= task and nil ~= task.Stop then
			task:Stop()
		end
	end
	self.parall_list = {}

	if nil ~= self.view then
		self.view:Destroy()
		self.view = nil
	end
end

function MainLoader:Update(dt)
	if nil == self.serial_head then
		self.serial_head = self:PopTask()
		if nil ~= self.serial_head then
			self.serial_head:Start()
			if nil ~= self.view then
				self.view:StartTask(self.serial_head)
			end
		end
	else
		local status = self.serial_head:Update(dt)
		if self.TASK_STATUS_FINE ~= status then
			if nil ~= self.view then
				self.view:StopTask(self.serial_head)
			end
			self.serial_head:Stop()
			self.serial_head = nil
		end
	end

	for i = #self.parall_list, 1, -1 do
		local task = self.parall_list[i]
		if nil ~= task then
			if nil == task.Update or self.TASK_STATUS_FINE ~= task:Update() then
				if nil ~= task.Stop then
					task:Stop()
				end
				table.remove(self.parall_list, i)
			end
		end
	end

	if nil ~= self.view then
		self.view:Update(dt)
	end
end

function MainLoader:EnterBackground()
	
	if nil ~= self.serial_head and nil ~= self.serial_head.EnterBackground then
		self.serial_head:EnterBackground()
	end
end

function MainLoader:EnterForeground()
	if nil ~= self.serial_head and nil ~= self.serial_head.EnterForeground then
		self.serial_head:EnterForeground()
	end
end

function MainLoader:NetStateChanged(net_state)
	if nil ~= self.serial_head and nil ~= self.serial_head.NetStateChanged then
		self.serial_head:NetStateChanged(net_state)
	end
end

function MainLoader:GlobalConfigChanged()
end

function MainLoader:PushTask(task)
	if nil ~= task and nil ~= task.Start and nil ~= task.Stop and nil ~= task.Update then
		table.insert(self.serial_list, task)
	end
end

function MainLoader:PopTask()
	return table.remove(self.serial_list, 1)
end

function MainLoader:AddTask(task)
	if nil ~= task then
		table.insert(self.parall_list, task)
		if nil ~= task.Start then
			task:Start()
		end
	end
end

function MainLoader:OpenView()
	if nil == self.view then
		self.view = require("scripts/preload/loader_view")
		if nil ~= self.view then
			self.view:Create()
		end
	end
end

function MainLoader:OpenReconnectView()
	local quick_reconnect = AdapterToLua:getInstance():getDataCache("QUICK_RECONNECT")
	if quick_reconnect == "true" then
		self.view = require("scripts/preload/loader_view")
		if nil ~= self.view then
			self.view:OpenReconnectView()
		end
	end
end

function MainLoader:CloseReconnectView()
	if nil ~= self.view then
		self.view:CloseReconnectView()
	end
end

function MainLoader:AuditVersionChanged()
	if nil == self.view then return end
	self.view:AuditVersionChanged()
end

function MainLoader:CloseView()
	if nil ~= self.view then
		self.view:Destroy()
		self.view = nil
	end
end
