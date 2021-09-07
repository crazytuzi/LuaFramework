QiXiActivityData = QiXiActivityData or BaseClass()
function QiXiActivityData:__init()
	if QiXiActivityData.Instance then
		ErrorLog("[QiXiActivityData] attempt to create singleton twice!")
		return
	end
	QiXiActivityData.Instance =self
	self.yuehui_my_score = 0			-- 我的积分
	self.yuehui_mate_score = 0			-- 伴侣积分
	self.yuehui_total_score = 0			-- 累积积分
	self.yuehui_remain_score = 0		-- 剩余积分
	self.yuehui_remain_num_list = {} 	-- 剩余兑换次数
	RemindManager.Instance:Register(RemindName.QixiCombat, BindTool.Bind(self.GetRemind, self))
end

function QiXiActivityData:__delete()
	QiXiActivityData.Instance = nil
	RemindManager.Instance:UnRegister(RemindName.QixiCombat)
end

function QiXiActivityData:SetJuHuaSuanInfo(info)
	self.yuehui_my_score = info.yuehui_my_score
	self.yuehui_mate_score = info.yuehui_mate_score
	self.yuehui_total_score = info.yuehui_total_score
	self.yuehui_remain_score = info.yuehui_remain_score
	self.yuehui_remain_num_list = info.yuehui_remain_num_list
end

function QiXiActivityData:GetRemind()
	for k,v in pairs(self:GetJuHuaSuanData()) do
		if v.fetch_reward_flag == 0 then
		 	return 1
		end
	end
	return 0
end

function QiXiActivityData:GetJuHuaSuanData()
	if nil == self.yuehui_dazuozhan then
		self.yuehui_dazuozhan = ServerActivityData.Instance:GetCurrentRandActivityConfig().yuehui_dazuozhan
	end
	local data = {}
	local count
	for i,v in ipairs(self.yuehui_dazuozhan) do
		data[i] = TableCopy(v)
		count = self.yuehui_remain_num_list[v.seq + 1] or 0
		data[i].task_achieve_count = count > 0 and 0 or 1
		data[i].fetch_reward_flag = (v.score <= self.yuehui_remain_score and count > 0) and 0 or 1
	end
	table.sort(data, SortTools.KeyLowerSorters("fetch_reward_flag", "task_achieve_count", "seq"))
	return data
end
