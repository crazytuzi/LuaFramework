MoLongData = MoLongData or BaseClass()

function MoLongData:__init()
	if MoLongData.Instance ~= nil then
		print_error("[MoLongData] Attemp to create a singleton twice !")
	end
	MoLongData.Instance = self
	-- 红点显示
	self.molong_redpt = false
	self.expdetion_redpt = false
	self.magic_card_redpt = false
	self.sword_atr_online_redpt = false
	self.horoscope_attr_redpt = false
	self.horoscope_equip_redpt = false
	self.horoscope_starmap_redpt = false

	-- 配置表数据
	self.cfg =  ConfigManager.Instance:GetAutoConfig("mitama_auto")
	self.level_cfg = self.cfg .level or {}
	self.task_info_cfg = self.cfg .task_info or {}
	self.task_reward_cfg = self.cfg .task_reward or {}
	self.exchange_cfg = self.cfg .exchange or {}
	self.res = self.cfg .res or {}

	-- 服务器数据
	self.info_list = {}
	self.info = {}
	RemindManager.Instance:Register(RemindName.Collection, BindTool.Bind(self.GetCollectionRemind, self))
end

function MoLongData:__delete()
	RemindManager.Instance:UnRegister(RemindName.Collection)
	
	MoLongData.Instance = nil
end

-- 收集系统红点变化
function MoLongData:SetMagicCardRedpt(is_redpt)
	self.magic_card_redpt = is_redpt
end

function MoLongData:SetSwrodArtOnlineRedpt(is_redpt)
	self.sword_atr_online_redpt = is_redpt
end

function MoLongData:SetHoroscopeAttrRedpt(is_redpt)
	self.horoscope_attr_redpt = is_redpt
end

function MoLongData:SetHoroscopeEquipRedpt(is_redpt)
	self.horoscope_equip_redpt = is_redpt
end

function MoLongData:SetHoroscopeStarMapRedpt(is_redpt)
	self.horoscope_starmap_redpt = is_redpt
end

function MoLongData:ShowMolongInfoRedpt()
	for j=1,5 do
		local level = MoLongData.Instance:GetLevelByIndex(j)
		local level_sprite_list = self:GetSpiritLevelListByindex(j)
		for i=1,5 do
			if self:IsCanUpLevelSprite(j,i) and level >= level_sprite_list[i] then
				self.molong_redpt = true
				return
			end
		end
	end

	self.molong_redpt = false
end

function MoLongData:ShowExpdetionRedpt()
	for i=1,5 do
		local cur_yuhun_info = self:GetYuHunInfoByIndex(i)
		if cur_yuhun_info.task_status == 0 or cur_yuhun_info.task_status == 2 then
			if cur_yuhun_info.level > 0 then
				self.expdetion_redpt = true
				return
			end
		else
			local task_time = self:GetTaskTotalTimeBySeq(cur_yuhun_info.task_seq)
			local cur_time = TimeCtrl.Instance:GetServerTime()
			local total_time = task_time - (cur_time - cur_yuhun_info.task_begin_timestamp)
			if total_time <= 0 then
				self.expdetion_redpt = true
				return
			end
		end
	end

	self.expdetion_redpt = false
end

function MoLongData:GetCollectionRemind()
	return self:ShowMainUiCollectionRedpt() and 1 or 0
end

function MoLongData:ShowMainUiCollectionRedpt()
	if self.molong_redpt or self.expdetion_redpt or self.magic_card_redpt or self.sword_atr_online_redpt
		or self.horoscope_attr_redpt or self.horoscope_equip_redpt or self.horoscope_starmap_redpt then
		return true
	else
		return false
	end
end

-- protocol -----------------------------------
function MoLongData:SetMitamaAllInfo(protocol)
	self.hotspring_score = protocol.hotspring_score or 0
	self.info_list = protocol.info_list or {}
	self:ShowMolongInfoRedpt()
	self:ShowExpdetionRedpt()
end

function MoLongData:SetMitamaSingleInfo(protocol)
	self.seq = protocol.seq or 0
	self.info = protocol.info or {}

	self.info_list[self.seq + 1] = self.info
	self:ShowMolongInfoRedpt()
	self:ShowExpdetionRedpt()
end

function MoLongData:SetMitamaHotSpringScore(protocol)
	self.hotspring_score = protocol.hotspring_score or 0
end

function MoLongData:GetMitamaInfo()
	return self.info_list or {}
end

function MoLongData:IsCanUpLevelSprite(seq,index)
	local sprite_level = self:GetSpiritLevelListByindex(seq)[index]

	local data_list = self:GetUpgradeConsumeItemListBylevel(sprite_level)

	if data_list then
		for k, v in pairs(data_list) do
			local have_num = ItemData.Instance:GetItemNumInBagById(v.item_id)
			if have_num < v.num then
				return false
			end
		end
	end

	return true
end

-- 获取魔龙信息
function MoLongData:GetMolongDataBySeq(seq)
	local data = {}
	for k,v in pairs(self.level_cfg) do
		if seq == v.seq and v.level == 1 then
			return v
		end
	end

	return data
end

-- 根据seq获取魔龙模型
function MoLongData:GetMolongModelBySeq(seq)
	for k,v in pairs(self.res) do
		if v.seq == seq then
			return v.res
		end
	end
end

--获取御魂列表
function MoLongData:GetMitamaStarList()
	local data_list = {}

	for _, v in pairs(self.level_cfg) do
		for k, info in pairs(self.info_list) do
			if k - 1 == v.seq and info.level == v.level then
				v.task_status = info.task_status
				v.task_seq = info.task_seq
				v.task_begin_timestamp = info.task_begin_timestamp
				table.insert(data_list, v)
			end
		end
	end

	return data_list
end

--根据索引获取魂等级列表
function MoLongData:GetSpiritLevelListByindex(index)
	local data_list = {}

	for k, v in ipairs(self.info_list) do
		if index == k then
			data_list = v.spirit_level_list or {}
			break
		end
	end
	return data_list
end

--获取升级所消耗的物品列表
function MoLongData:GetUpgradeConsumeItemListBylevel(level)
	local data_list = {}

	for k, v in pairs(self.level_cfg) do
		if v.level == level then
			data_list = v.consume_item
			break
		end
	end

	return data_list
end

--获取总战力
function MoLongData:GetMitamaTotalCapBySeq(seq)
	local data = self:GetSpiritLevelListByindex(seq)
	local total_attr = CommonStruct.Attribute()
	local cap = 0

	local Mitama_level = self.info_list[seq].level

	for k, v in pairs(self.level_cfg) do
		if v.level <= Mitama_level and v.seq == seq then
			local attr = CommonDataManager.GetAttributteByClass(v)
			local mul_attr = CommonDataManager.MulAttribute(attr, 5)
			total_attr = CommonDataManager.AddAttributeAttr(total_attr, mul_attr)
		end
	end

	for k, v in pairs(data) do
		for _, m in pairs(self.level_cfg) do
			if seq == m.seq and v.level == m.level then
				local attr = CommonDataManager.GetAttributteByClass(m)
				total_attr = CommonDataManager.AddAttributeAttr(total_attr, attr)
			end
		end
	end

	cap = CommonDataManager.GetCapability(total_attr)
	return cap
end

--获取增加的战力
function MoLongData:GetMitamaLerpCapBySeqAndIndex(seq, index)
	local data = self:GetSpiritLevelListByindex(seq)
	local level = data[index].level
	local cur_attr = CommonStruct.Attribute()
	local next_attr = CommonStruct.Attribute()
	local lerp_attr = CommonStruct.Attribute()
	local cap = 0

	for _, m in pairs(self.level_cfg) do
		if seq == m.seq then
			if level == m.level then
				cur_attr = CommonDataManager.GetAttributteByClass(m)
			elseif level == m.level - 1 and nil ~= m then
				next_attr = CommonDataManager.GetAttributteByClass(m)
			end
		end
	end

	lerp_attr = CommonDataManager.LerpAttributeAttr(cur_attr, next_attr)
	cap = CommonDataManager.GetCapability(lerp_attr) > 0 and CommonDataManager.GetCapability(lerp_attr) or 0

	return cap
end

function MoLongData:GetMitamaMaxLevelBySeq(seq)
	local level = 0
	for k, v in pairs(self.level_cfg) do
		if seq == v.seq then
			level = v.level
			break
		end
	end

	return level
end

function MoLongData:GetLevelByIndex(index)
	for k, v in ipairs(self.info_list) do
		if k == index then
			return tonumber(v.level)
		end
	end
	return 0
end

function MoLongData:GetStarLevelByIndex(index, seq)
	local spirit_level_list = self:GetSpiritLevelListByindex(index)
	for k, v in ipairs(spirit_level_list) do
		if k == seq then
			return tonumber(v)
		end
	end
	return 0
end

function MoLongData:GetYuHunAttrByIndex(index)
	local attr_list = {}
	attr_list = CommonStruct.Attribute()

	local spirit_level_list = self:GetSpiritLevelListByindex(index)
	local level = tonumber(self:GetLevelByIndex(index))
	for k, v in ipairs(self.level_cfg) do
		if v.seq == index - 1 then
			if v.level == level then
				attr_list.max_hp = attr_list.max_hp + v.maxhp * 5
				attr_list.gong_ji = attr_list.gong_ji + v.gongji * 5
				attr_list.fang_yu = attr_list.fang_yu + v.fangyu * 5
				attr_list.ming_zhong = attr_list.ming_zhong + v.mingzhong * 5
				attr_list.shan_bi = attr_list.shan_bi + v.shanbi * 5
			end

			for _, l in ipairs(spirit_level_list) do
				if l == v.level then
					attr_list.max_hp = attr_list.max_hp + v.maxhp
					attr_list.gong_ji = attr_list.gong_ji + v.gongji
					attr_list.fang_yu = attr_list.fang_yu + v.fangyu
					attr_list.ming_zhong = attr_list.ming_zhong + v.mingzhong
					attr_list.shan_bi = attr_list.shan_bi + v.shanbi
				end
			end
		end
	end
	return attr_list
end

function MoLongData:GetAddYuHunAttr(index, star_level)
	local add_attr_list = {}
	local cur_attr = {}
	add_attr_list = CommonStruct.Attribute()
	cur_attr = CommonStruct.Attribute()

	for k, v in ipairs(self.level_cfg) do
		if v.seq == index - 1 then
			if star_level == v.level then
				cur_attr.max_hp = v.maxhp
				cur_attr.gong_ji = v.gongji
				cur_attr.fang_yu = v.fangyu
				cur_attr.ming_zhong = v.mingzhong
				cur_attr.shan_bi = v.shanbi
				break
			end
		end
	end

	for k, v in ipairs(self.level_cfg) do
		if v.seq == index - 1 then
			if star_level + 1 == v.level and (star_level + 1) <= 6 then
				add_attr_list.max_hp = v.maxhp - cur_attr.max_hp
				add_attr_list.gong_ji = v.gongji - cur_attr.gong_ji
				add_attr_list.fang_yu = v.fangyu - cur_attr.fang_yu
				add_attr_list.ming_zhong = v.mingzhong - cur_attr.ming_zhong
				add_attr_list.shan_bi = v.shanbi - cur_attr.shan_bi
				break
			end
		end
	end

	return add_attr_list
end

function MoLongData:GetLevelUpItemList(index, star_level)
	local item_list = {}
	for k, v in ipairs(self.level_cfg) do
		if v.seq == index - 1 then
			if star_level == v.level then
				item_list = v.consume_item
				break
			end
		end
	end
	return item_list
end
-- /tab1 ----------------------------------


-- tab2 -----------------------------------
--获取任务列表
function MoLongData:GetTaskInfoCfg()
	local data_list = {}

	for k, v in pairs(self.task_info_cfg) do
		v.reward_item_list = {}
		for _, m in pairs(self.task_reward_cfg) do
			if k == m.seq + 1 and m.is_show == 1 then
				table.insert(v.reward_item_list, m.reward_item)
			end
		end
		table.insert(data_list, v)
	end

	return data_list
end

function MoLongData:GetAllTaskList()
	return self.task_info_cfg
end

--获取任务所需时间
function MoLongData:GetTaskTotalTimeBySeq(seq)
	local time = 0
	for k, v in pairs(self.task_info_cfg) do
		if seq == v.seq then
			time = v.need_time
			break
		end
	end

	return time * 60
end

--通过下标获取御魂信息
function MoLongData:GetYuHunInfoByIndex(index)
	local info_list = {}
	if self.info_list[index] then
		info_list = self.info_list[index]
	end
	return info_list
end

-- /tab2 ----------------------------------


-- tab3 -----------------------------------
--获取兑换列表
function MoLongData:GetExchangeDataList()
	local data_list = {}
	local index = 1
	for i = 1, #self.exchange_cfg, 3 do
		data_list[index] = {self.exchange_cfg[i], self.exchange_cfg[i + 1], self.exchange_cfg[i + 2]}
		index = index + 1
	end

	return data_list
end

function MoLongData:GetHotSpringScore()
	return self.hotspring_score
end
-- /tab3 ----------------------------------