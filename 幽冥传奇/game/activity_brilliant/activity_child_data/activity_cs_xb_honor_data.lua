---------------
-- 消费荣耀
---------------
local XBHonorActData = {}

function XBHonorActData:Init(t)
	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	self.act_cfg = t.act_cfg
	self.act_id = t.act_cfg.act_id

	self.act_name = self.act_cfg.act_name
	self.data = {}
	self.client_cfg = OPER_ACT_CLIENT_CFG[self.act_id]
	self.is_valid = true

	self.cur_person_level = 1
	self.remind_num = 0
	return self
end

function XBHonorActData:Delete()
	self:RemoveAllEventListeners()
	self.is_valid = false
end

function XBHonorActData:HasRemind()
	return self.client_cfg.remind_param and (0 < #self.client_cfg.remind_param)
end

function XBHonorActData:IsValid()
	return self.is_valid
end

function XBHonorActData:ServerProtocol(protocol)
	self.data.rank_list = protocol.rank_list
	self.data.mine_rank = protocol.mine_rank
	self.data.mine_num = protocol.mine_num
	self.data.lingqu_flag = protocol.lingqu_flag

	self:SetRankDataList()
	self:SetCurPersonLevel()
	self:DispatchEvent("CZRY_DATA_CHANGE")
end

function XBHonorActData:GetRankDataList()
	return self.rank_data_list or {}
end

function XBHonorActData:GetEffectId()
	return self.act_cfg.config.viewEffectId or 309
end

function XBHonorActData:SetRankDataList()
	local data_list = {}
	self.rank_data_list = data_list
	for rank_level, rank_cfg in ipairs(self.act_cfg.config.rankings) do
		data_list[rank_level] = {rank_cfg = rank_cfg, role_list = {}}
	end

	if self.data.rank_list then
		for k, v in ipairs(self.data.rank_list) do
			for rank_level, val in ipairs(data_list) do
				if v[3] >= val.rank_cfg.count and #val.role_list < val.rank_cfg.maxGetCount then
					v.rank_level = rank_level
					val.role_list[#val.role_list + 1] = v
					break
				else
				end
			end
		end
	end
end

function XBHonorActData:SetCurPersonLevel()
	local cur_level = 1
	for i = 0, 7 do
		if bit:_and(bit:_rshift(self.data.lingqu_flag or 0, i), 1) == 1 then
			cur_level = cur_level + 1
		else
			break
		end
	end

	if self.cur_person_level ~= cur_level then
		self.cur_person_level = cur_level
	end

	self:SetPersonRewardRemind()
end

function XBHonorActData:SetPersonRewardRemind()
	if self.act_cfg.config.join_award[self.cur_person_level] then
		local need_count = self.act_cfg.config.join_award[self.cur_person_level].count
		local remind_num = self.data.mine_num >= need_count and 1 or 0
		if remind_num ~= self.remind_num then
			self.remind_num = remind_num
			RemindManager.Instance:DoRemind(RemindName.CSHonorActXFRY)
			self:DispatchEvent("REMIND_CHANGE")
		end
	else
		local remind_num = 0
		if remind_num ~= self.remind_num then
			self.remind_num = remind_num
			RemindManager.Instance:DoRemind(RemindName.CSHonorActXFRY)
			self:DispatchEvent("REMIND_CHANGE")
		end
	end
end

function XBHonorActData:GetCurPersonLevel()
	return self.cur_person_level
end

function XBHonorActData:GetRemindNum(remind_name)
	return self.remind_num
end

return XBHonorActData