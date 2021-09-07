SendFlowerData = SendFlowerData or BaseClass()

function SendFlowerData:__init()
	if SendFlowerData.Instance then
		print_error("[SendFlowerData] Attemp to create a singleton twice !")
	end
	SendFlowerData.Instance = self
	self.num = 0
	self.flower_cfg = nil
	self.charm_cfg = nil
	self.info = {}
	RemindManager.Instance:Register(RemindName.SendFlower, BindTool.Bind(self.GetRemind, self))
end

function SendFlowerData:__delete()
    SendFlowerData.Instance =
	RemindManager.Instance:UnRegister(RemindName.SendFlower)
end

function SendFlowerData:SetInfo(protocol)
	self.info.draw_time_list = protocol.draw_time_list or {}
	self.info.draw_reward_flag = protocol.draw_reward_flag or 0
	self.info.reward_times_flag = bit:d2b(protocol.reward_times) or {}
	self.info.qixi_flower_charm = protocol.qixi_flower_charm or 0
end

function SendFlowerData:GetInfo()
	return self.info
end

function SendFlowerData:GetInfoDrawTimeList(seq)
	if self.info and self.info.draw_time_list then
		return self.info.draw_time_list[seq] or 0
	end
	return 0
end

function SendFlowerData:GetActiveFlag(index) 
	if self.info and self.info.reward_times_flag then
		return self.info.reward_times_flag[32 - index] or 1
	end
	return 1
end

function SendFlowerData:GetSendFlowerCfg()
	return ServerActivityData.Instance:GetCurrentRandActivityConfig().qixi_flower_gift or {}
end

function SendFlowerData:GetQiXiModel()
	if self.model_list == nil then
		self.model_list = {}
		local list = ServerActivityData.Instance:GetCurrentRandActivityConfig().qixi_model
		if list then
			self.model_list = ServerActivityData.Instance:GetCurrentRandActivityConfig().qixi_model[1] or {}
		end
	end
	return self.model_list
end

function SendFlowerData:GetFlowerCfg()
	if self.flower_cfg == nil and self.charm_cfg == nil then
		local cfg = self:GetSendFlowerCfg()
		local index = 1
		self.flower_cfg = {}
		self.charm_cfg = {}
		for k,v in pairs(cfg) do
			if v.task_type == 0 then
				self.flower_cfg[self.num] = v
				self.num = self.num + 1
			end
			if v.task_type ~= 0 then 
				self.charm_cfg[index] = v
				index = index + 1
			end
		end
	end
	return self.flower_cfg, self.charm_cfg, self.num
end

function SendFlowerData:GetRewardIist(item_id)
	local list = {}
	if item_id then
		list = ItemData.Instance:GetGiftItemListByProf(item_id)
	end
	return list
end

function SendFlowerData:GetRemind()
	local flower_cfg,charm_cfg,num = self:GetFlowerCfg()
	for i = 0, num - 1 do
		if self:GetActiveFlag(flower_cfg[i].index) == 0 then
			return 1
		end
	end
	return 0
end


