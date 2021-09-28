local InitRequire = {
	ctrl_state = CTRL_STATE.START,
	require_list = {},
	require_count = 0,
	require_index = 0,
}

function InitRequire:Start()
	-- 获取基础的require列表.
	self.require_list = require("game/common/require_list")

	-- 创建渠道匹配器, 如果这个列表里面没有则使用默认的.
	local agentTable = {
		["dev"] = "agent/dev/agent_adapter",
		["its"] = "agent/dev/agent_adapter"
	}

	local agent_id = ChannelAgent.GetChannelID()
	if nil == agent_id then
		table.insert(self.require_list, "agent/dev/agent_adapter")
	else
		local agentPath = agentTable[agent_id]
		if agentPath ~= nil then
			table.insert(self.require_list, agentPath)
		else
			table.insert(self.require_list, "agent/agent_adapter")
		end
	end

	print_log("[loading] start require lua file", os.date())
	self.require_count = #self.require_list
	InitCtrl:SetText("加载中(不耗流量)")
	ReportManager:Step(Report.STEP_REQUIRE_START)
end

function InitRequire:Update(now_time, elapse_time)
	if self.ctrl_state == CTRL_STATE.UPDATE then
		local end_index = self.require_index + 12
		for i = self.require_index + 1, end_index do
			self.require_index = i
			if nil == self.require_list[i] then
				print_log("[loading] finish require lua file", os.date())
				ReportManager:Step(Report.STEP_REQUIRE_END)
				self.ctrl_state = CTRL_STATE.STOP
				InitCtrl:SetPercent(0.3, function()
					InitCtrl:OnCompleteRequire()
				end)
				return
			else
				local path = self.require_list[self.require_index]
				if string.match(path, "^config/auto_new/.*") then
					CheckLuaConfig(path, require(path))
				else
					require(path)
				end
			end
		end
		InitCtrl:SetPercent(self.require_index / self.require_count * 0.3)
	elseif self.ctrl_state == CTRL_STATE.START then
		self.ctrl_state = CTRL_STATE.UPDATE
		self:Start()
	elseif self.ctrl_state == CTRL_STATE.STOP then
		self.ctrl_state = CTRL_STATE.NONE
		self:Stop()
		PopCtrl(self)
	end
end

function InitRequire:Stop()
	GameRoot.Instance:PruneLuaBundles()
	collectgarbage("setpause", 100)
	collectgarbage("setstepmul", 5000)
end

return InitRequire