ActSpecialRebateData = ActSpecialRebateData or BaseClass()

ActSpecialRebateData.ACT_TYPE = {
	[1] = 2205,	--foot
	[2] = 2207,	--head
	[3] = 2206,	--waist
	[4] = 2209,	--mask
	[5] = 2208,	--arm
	[6] = 2211,	--bead
	[7] = 2210,	--fabao
}

function ActSpecialRebateData:__init()
	if ActSpecialRebateData.Instance ~= nil then
		ErrorLog("[ActSpecialRebateData] Attemp to create a singleton twice !")
	end

	self.shengong_data = {}
	self.yaoshi_data = {}
	self.toushi_data = {}
	self.qilingbi_data = {}
	self.mask_data = {}
	self.xianbao_data = {}
	self.lingbao_data = {}
	self.upgrade_card_buy_data = {}

	local all_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	self.shenggong_cfg = all_cfg.shengong_upgrade
	self.yaoshi_cfg = all_cfg.yaoshi_upgrade
	self.toushi_cfg = all_cfg.toushi_upgrade
	self.qilingbi_cfg = all_cfg.qilinbi_upgrade
	self.mask_cfg = all_cfg.mask_upgrade
	self.xianbao_cfg = all_cfg.xianbao_upgrade
	self.lingbao_cfg = all_cfg.lingzhu_upgrade

	--self.upgrade_card_buy_cfg = ListToMapList(ConfigManager.Instance:GetAutoConfig("upgrade_card_buy_cfg_auto").buy_cfg, "related_activity_s")

	ActSpecialRebateData.Instance = self
	RemindManager.Instance:Register(RemindName.ActRebateFoot, BindTool.Bind(self.GetRemind, self, 1))
	RemindManager.Instance:Register(RemindName.ActRebateTouShi, BindTool.Bind(self.GetRemind, self, 2))
	RemindManager.Instance:Register(RemindName.ActRebateYaoShi, BindTool.Bind(self.GetRemind, self, 3))
	RemindManager.Instance:Register(RemindName.ActRebateMask, BindTool.Bind(self.GetRemind, self, 4))
	RemindManager.Instance:Register(RemindName.ActRebateQiLingBi, BindTool.Bind(self.GetRemind, self, 5))
	RemindManager.Instance:Register(RemindName.ActRebateLingBao, BindTool.Bind(self.GetRemind, self, 6))
	RemindManager.Instance:Register(RemindName.ActRebateXianBao, BindTool.Bind(self.GetRemind, self, 7))

end

function ActSpecialRebateData:__delete()
	RemindManager.Instance:UnRegister(RemindName.ActRebateFoot)
	RemindManager.Instance:UnRegister(RemindName.ActRebateTouShi)
	RemindManager.Instance:UnRegister(RemindName.ActRebateYaoShi)
	RemindManager.Instance:UnRegister(RemindName.ActRebateMask)
	RemindManager.Instance:UnRegister(RemindName.ActRebateQiLingBi)
	RemindManager.Instance:UnRegister(RemindName.ActRebateLingBao)
	RemindManager.Instance:UnRegister(RemindName.ActRebateXianBao)
	ActSpecialRebateData.Instance = nil
end

function ActSpecialRebateData:SetUpgradeCardByData(protocol)
	self.upgrade_card_buy_data[protocol.activity_id] = {}
	self.upgrade_card_buy_data[protocol.activity_id].activity_id = protocol.activity_id
	self.upgrade_card_buy_data[protocol.activity_id].grade = protocol.grade
	self.upgrade_card_buy_data[protocol.activity_id].is_already_buy = protocol.is_already_buy
end

function ActSpecialRebateData:SetShenGongData(protocol)
	self.shengong_data.grade = protocol.grade
	self.shengong_data.can_fetch_reward_flag = protocol.can_fetch_reward_flag
	self.shengong_data.fetch_reward_flag = protocol.fetch_reward_flag
end

function ActSpecialRebateData:SetYaoShiData(protocol)
	self.yaoshi_data.grade = protocol.yaoshi_grade
	self.yaoshi_data.can_fetch_reward_flag = protocol.can_fetch_reward_flag
	self.yaoshi_data.fetch_reward_flag = protocol.fetch_reward_flag
end

function ActSpecialRebateData:SetTouShiData(protocol)
	self.toushi_data.grade = protocol.toushi_grade
	self.toushi_data.can_fetch_reward_flag = protocol.can_fetch_reward_flag
	self.toushi_data.fetch_reward_flag = protocol.fetch_reward_flag
end

function ActSpecialRebateData:SetQiLinBiData(protocol)
	self.qilingbi_data.grade = protocol.qilinbi_grade
	self.qilingbi_data.can_fetch_reward_flag = protocol.can_fetch_reward_flag
	self.qilingbi_data.fetch_reward_flag = protocol.fetch_reward_flag
end

function ActSpecialRebateData:SetMaskData(protocol)
	self.mask_data.grade = protocol.mask_grade
	self.mask_data.can_fetch_reward_flag = protocol.can_fetch_reward_flag
	self.mask_data.fetch_reward_flag = protocol.fetch_reward_flag
end

function ActSpecialRebateData:SetXianBaoData(protocol)
	self.xianbao_data.grade = protocol.xianbao_grade
	self.xianbao_data.can_fetch_reward_flag = protocol.can_fetch_reward_flag
	self.xianbao_data.fetch_reward_flag = protocol.fetch_reward_flag
end

function ActSpecialRebateData:SetLingZhuData(protocol)
	self.lingbao_data.grade = protocol.lingzhu_grade
	self.lingbao_data.can_fetch_reward_flag = protocol.can_fetch_reward_flag
	self.lingbao_data.fetch_reward_flag = protocol.fetch_reward_flag
end

function ActSpecialRebateData:GetActCfgByViewType(view_type)
	if view_type == nil then
		return nil, nil
	end

	local data = {}
	local info = {}
	local through = {}
	local sort_data = {}
	local act_id = nil
	
	if ACT_SPECIAL_REBATE_TYPE.FOOT == view_type then
		data = TableCopy(self.shenggong_cfg)
		info = self.shengong_data
		act_id = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHENGONG_UPGRADE_NEW
	elseif ACT_SPECIAL_REBATE_TYPE.WAIST == view_type then
		data = TableCopy(self.yaoshi_cfg)
		info = self.yaoshi_data
		act_id = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_YAOSHI_UPGRADE
	elseif ACT_SPECIAL_REBATE_TYPE.HEAD == view_type then
		data = TableCopy(self.toushi_cfg)
		info = self.toushi_data
		act_id = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOUSHI_UPGRADE
	elseif ACT_SPECIAL_REBATE_TYPE.ARM == view_type then
		data = TableCopy(self.qilingbi_cfg)
		info = self.qilingbi_data
		act_id = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QILINBI_UPGRADE
	elseif ACT_SPECIAL_REBATE_TYPE.FACE == view_type then
		data = TableCopy(self.mask_cfg)
		info = self.mask_data
		act_id = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MASK_UPGRADE
	elseif ACT_SPECIAL_REBATE_TYPE.TREASURE == view_type then
		data = TableCopy(self.xianbao_cfg)
		info = self.xianbao_data
		act_id = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_XIANBAO_UPGRADE
	elseif ACT_SPECIAL_REBATE_TYPE.BEAD == view_type then
		data = TableCopy(self.lingbao_cfg)
		info = self.lingbao_data
		act_id = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGZHU_UPGRADE
	end

	if next(info) == nil then
		return sort_data, through
	end

	if next(data) ~= nil then
		local can_tab = bit:d2b(info.can_fetch_reward_flag) or {}
		local fetch_tab = bit:d2b(info.fetch_reward_flag) or {}
		
		for k,v in pairs(data) do
			local data_c = TableCopy(v)
			data_c.grade = info.grade
			data_c.is_can = can_tab[32 - k]
			data_c.is_get = fetch_tab[32 - k]
			data_c.view_type = view_type
			data_c.act_id = act_id
			data_c.sort = v.seq
			if data_c.is_can == 0 then
				data_c.sort = data_c.sort + 100
			end

			if data_c.is_get == 1 then
				data_c.sort = data_c.sort + 1000
			end

			table.insert(sort_data, data_c)
		end
	end

	table.sort(sort_data, function (a, b) return a.sort < b.sort end)

	-- if act_id ~= nil then
	-- 	local act_buy_cfg = self.upgrade_card_buy_cfg[act_id]
	-- 	local act_grade_cfg = {}
	-- 	if act_buy_cfg ~= nil then
	-- 		act_grade_cfg = ActivityData.Instance:GetRandActivityConfig(act_buy_cfg, act_id)
	-- 	end

	-- 	for k,v in pairs(act_grade_cfg) do
	-- 		if v.grade == info.grade or (v.same_order == 1 and info.grade <= v.grade) then
	-- 			through = TableCopy(v)
	-- 			local buy_data = self.upgrade_card_buy_data[act_id]
	-- 			through.is_buy = buy_data and buy_data.is_already_buy or 0
	-- 			break
	-- 		end
	-- 	end
	-- end

	return sort_data, through
end

function ActSpecialRebateData:GetRemind(view_type)
	local num = 0
	local data = self:GetActCfgByViewType(view_type)	

	if data ~= nil then
		for k,v in pairs(data) do
			if v.is_can == 1 and v.is_get == 0 then
				num = 1
				break
			end
		end
	end

	return num
end