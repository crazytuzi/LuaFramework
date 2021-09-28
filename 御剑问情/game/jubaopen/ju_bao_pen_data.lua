JuBaoPenData = JuBaoPenData or BaseClass()

function JuBaoPenData:__init()
    if JuBaoPenData.Instance then
        print_error("[JuBaoPenData] Attempt to create singleton twice!")
        return
    end
    JuBaoPenData.Instance = self

    self.reward_lun = 1
    self.history_chongzhi = 0
    self.record_list = {}

    RemindManager.Instance:Register(RemindName.JuBaoPen, BindTool.Bind(self.IsShowRedPoint, self))
end

function JuBaoPenData:__delete()
	RemindManager.Instance:UnRegister(RemindName.JuBaoPen)
	JuBaoPenData.Instance = nil
end

function JuBaoPenData:SetRACornucopiaFetchInfo(protocol)
	self.reward_lun = protocol.reward_lun
	self.history_chongzhi = protocol.history_chongzhi
	self.record_list = {}
	local record_list = protocol.record_list
	local num = #record_list
	for i = 1, num do
		self.record_list[i] = record_list[num - i + 1]
	end
end

function JuBaoPenData:GetHistoryChongZhi()
	return self.history_chongzhi
end

function JuBaoPenData:GetRewardLun()
	return self.reward_lun
end

function JuBaoPenData:GetRecordList()
	return self.record_list
end

function JuBaoPenData:GetCornucopia()
	if not self.config_cornucopia then
		local cornucopia = ServerActivityData.Instance:GetCurrentRandActivityConfig().cornucopia_rate
		if cornucopia then
		    self.config_cornucopia = {}
		    for k,v in pairs(cornucopia) do
		    	self.config_cornucopia[v.lun] = self.config_cornucopia[v.lun] and self.config_cornucopia[v.lun] or {}
		    	table.insert(self.config_cornucopia[v.lun], v.reward_rate)
		    end
		    for k,v in pairs(self.config_cornucopia) do
		    	SortTools.SortAsc(v)
		    end
		end
	end
	return self.config_cornucopia
end

function JuBaoPenData:GetCornucopiaRate()
	if not self.config_cornucopia_rate then
		self.config_cornucopia_rate = ServerActivityData.Instance:GetCurrentRandActivityConfig().cornucopia
	end
	return self.config_cornucopia_rate
end

function JuBaoPenData:GetNeedChargeByLun(index)
	local config_cornucopia_rate = self:GetCornucopiaRate()
	local need_total_charge = 0
	local max_gold = 0
	if config_cornucopia_rate then
		for k,v in pairs(config_cornucopia_rate) do
			if v.lun == index then
				need_total_charge = v.need_total_charge or 0
				max_gold = v.max_reward_gold2 or 0
				break
			end
		end
	end
	return need_total_charge, max_gold
end

function JuBaoPenData:GetCornucopiaConfigByLun(index)
	local cornucopia = self:GetCornucopia()
	if cornucopia then
		return cornucopia[index]
	end
end

function JuBaoPenData:GetMaxLun()
	local max_lun = 0
	local cornucopia = self:GetCornucopia()
	if cornucopia then
		max_lun = #cornucopia
	end
	return max_lun
end

function JuBaoPenData:IsShowRedPoint()
	local remind = 0
	local max_lun = self:GetMaxLun()
	if OpenFunData.Instance:CheckIsHide("jubaopen") then
		if not RemindManager.Instance:RemindToday(RemindName.JuBaoPen) then
			remind = 1
		end
		if self.reward_lun <= max_lun and ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CORNUCOPIA) then
			local price = self:GetNeedChargeByLun(self.reward_lun)
			local gold = Scene.Instance:GetMainRole().vo.gold
			if self.history_chongzhi >= price and gold >= price then
				remind = 1
			end
		end
	end
	return remind
end

function JuBaoPenData:CheckIsShow()
	local max_lun = self:GetMaxLun()
	local is_first = DailyChargeData.Instance:HasFirstRecharge()
	if self.reward_lun <= max_lun and ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CORNUCOPIA)
	 	and OpenFunData.Instance:CheckIsHide("jubaopen") and is_first then
	 	return true
	end
	return false
end