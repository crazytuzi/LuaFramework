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
		["ats"] = "agent/dev/agent_adapter",
		["its"] = "agent/dev/agent_adapter",
		["de1"] = "agent/dev/agent_adapter",
	}

	local agentPath = agentTable[ChannelAgent.GetChannelID()]
	if agentPath ~= nil then
		table.insert(self.require_list, agentPath)
	else
		table.insert(self.require_list, "agent/agent_adapter")
	end

	self.require_count = #self.require_list
	InitCtrl:SetText("正在预加载游戏资源(不消耗流量)，请稍等")
	ReportManager:Step(Report.STEP_REQUIRE_START)

	-- 进入游戏前判断下是否有线下公告，有的话先弹公告
	-- http://45.83.237.23:1081/api/c2s/fetch_notice_content.php?spid=dev
	-- 线下公告请求（一进入游戏就弹窗）
	self.notice_info = nil
	if nil ~= GLOBAL_CONFIG.param_list.notice_query_url2 and GLOBAL_CONFIG.param_list.notice_query_url2 ~= "" then

		local agent_id = GLOBAL_CONFIG.package_info.config.agent_id
		local notice_query_url = string.format("%s?spid=%s", GLOBAL_CONFIG.param_list.notice_query_url2, agent_id)

		HttpClient:Request(notice_query_url, function(url, is_succ, data)
			print_log("SendNoticeRequest", url, is_succ, data)
			self.notice_info = cjson.decode(data)
			if is_succ and self.notice_info and next(self.notice_info.data) and InitCtrl:GetLoadingVisible() then
				InitCtrl:SetNoticeData(self.notice_info)
				InitCtrl:SetIsNeedShow(true)
			end
		end)
	end
end

function InitRequire:Update(now_time, elapse_time)
	if self.ctrl_state == CTRL_STATE.UPDATE then
		local end_index = self.require_index + 12
		for i = self.require_index + 1, end_index do
			self.require_index = i
			if nil == self.require_list[i] then
				ReportManager:Step(Report.STEP_REQUIRE_END)
				self.ctrl_state = CTRL_STATE.STOP
				InitCtrl:SetPercent(0.6, function()
					InitCtrl:OnCompleteRequire()
				end)
				return
			else
				require(self.require_list[self.require_index])
			end
		end
		InitCtrl:SetPercent(self.require_index / self.require_count * 0.6)
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