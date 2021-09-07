CoolChatData = CoolChatData or BaseClass()

PERSONALIZE_WINDOW_OPERA_TYPE = {
	PERSONALIZE_WINDOW_BUBBLE_INFO = 0,					-- 请求气泡框信息
	PERSONALIZE_WINDOW_BUBBLE_UP_LEVEL = 1,				-- 升级气泡框请求
	PERSONALIZE_WINDOW_BUBBLE_USE = 2,					-- 使用气泡框请求
	PERSONALIZE_FRAME_INFO = 3,							-- 请求头像框信息
	PERSONALIZE_WINDOW_FRAME_UP_LEVEL = 4,				-- 头像框升级
	PERSONALIZE_WINDOW_FRAME_USE = 5,					-- 使用头像框
}

function CoolChatData:__init()
	if CoolChatData.Instance then
		print_error("[CoolChatData]:Attempt to create singleton twice!")
	end
	CoolChatData.Instance = self

	self.big_face_level = 0

	self.tuhaojin_info = {
		tuhaojin_level = 0,
		cur_tuhaojin_color = 0,
		max_tuhaojin_color = 0,
	}
	self.bubble_list = {}
	self.attr_data = {}
	self.select_seq = -1			--正在使用的聊天框
	self.cur_active_bigface_list = {} -- 当前激活的大表情组
	self.bubble_level_list = {}  		-- 气泡框等级
	RemindManager.Instance:Register(RemindName.CoolChat, BindTool.Bind(self.GetCoolChatRemind, self))

	self.bigchatface_cfg = ConfigManager.Instance:GetAutoConfig("bigchatface_auto")
	self.level_cfg = ListToMap(self.bigchatface_cfg.level_cfg, "big_face_level")

	self.tuhaojin_cfg = ConfigManager.Instance:GetAutoConfig("tuhaojin_auto")
	self.tuhaojin_level_cfg = ListToMap(self.tuhaojin_cfg.level_cfg, "tuhaojin_level")

	self.bubble_cfg = ConfigManager.Instance:GetAutoConfig("personalize_window_auto")
	self.bubble_single_level_cfg = ListToMap(self.bubble_cfg.bubble_level_cfg, "bubble_level")
end

function CoolChatData:__delete()
	RemindManager.Instance:UnRegister(RemindName.CoolChat)
	CoolChatData.Instance = nil
end

function CoolChatData:SetBigChatFaceAllInfo(info)
	self.big_face_level = info.big_face_level
	self.cur_active_bigface_list = self:GetActiveListByLevel()
end

function CoolChatData:GetBigFaceLevel()
	return self.big_face_level
end

-- 大表情是否激活
function CoolChatData:GetActiveStatusByIndex(index)
	return self.cur_active_bigface_list[index] or false
end

-- 得到大表情激活的等级
function CoolChatData:GetBigFaceActiveLevel(index)
	level = level or self.big_face_level
	local active_group = {}
	local big_face_cfg = CoolChatData.Instance:GetBigFaceConfig()
	if big_face_cfg then
		local level_cfg = big_face_cfg.level_cfg
		if level_cfg then
			for k,v in pairs(level_cfg) do
				if v.big_face_id == index then
					return v.big_face_level
				end
			end
		end
	end
	return 0
end

-- 根据大表情等级获得已经激活的表情组的ID
function CoolChatData:GetActiveGroupByLevel(level)
	level = level or self.big_face_level
	local active_group = {}
	local big_face_cfg = CoolChatData.Instance:GetBigFaceConfig()
	if big_face_cfg then
		local level_cfg = big_face_cfg.level_cfg
		if level_cfg then
			for i = 1, level + 1 do
				local cfg = level_cfg[i]
				if cfg then
					if cfg.big_face_id > 0 then
						active_group[cfg.big_face_id] = true
					end
				end
			end
		end
	end
	return active_group
end

-- 根据大表情组ID获得该组的表情
function CoolChatData:GetBigFaceByGroupId(index)
	index = index or 0
	local active_list = {}
	local big_face_cfg = CoolChatData.Instance:GetBigFaceConfig()
	if big_face_cfg then
		local group_config = big_face_cfg.group
		if group_config then
			local res_id = group_config[index].res_id
			if res_id then
				if type(res_id) == "string" then
					local temp = Split(res_id, ";")
					for k,v in pairs(temp) do
						active_list[tonumber(v)] = true
					end
				else
					active_list[res_id] = true
				end
			end
		end
	end
	return active_list
end

-- 根据大表情等级获得已经激活的表情
function CoolChatData:GetActiveListByLevel(level)
	level = level or self.big_face_level
	local active_list = {}
	local active_group = self:GetActiveGroupByLevel(level)
	if next(active_group) then
		for k,v in pairs(active_group) do
			local temp_list = self:GetBigFaceByGroupId(k)
			for k2,v2 in pairs(temp_list) do
				active_list[k2] = true
			end
		end
		-- local group_config = big_face_cfg.group
		-- if group_config then
		-- 	for k,v in pairs(active_group) do
		-- 		local res_id = group_config[k].res_id
		-- 		if res_id then
		-- 			if type(res_id) == "string" then
		-- 				local temp = Split(res_id, ";")
		-- 				for k,v in pairs(temp) do
		-- 					active_list[tonumber(v)] = true
		-- 				end
		-- 			else
		-- 				active_list[res_id] = true
		-- 			end
		-- 		end
		-- 	end
		-- end
	end
	return active_list
end

function CoolChatData:GetBigFaceConfig()
	if not self.bigchatface_cfg then
		self.bigchatface_cfg = ConfigManager.Instance:GetAutoConfig("bigchatface_auto")
	end
	return self.bigchatface_cfg
end

-- 获取大表情的等级配置
function CoolChatData:GetBigFaceLevelConfig(level)
	local cfg = {}
	if self.level_cfg then
		cfg = self.level_cfg[level]
	end
	return cfg
end

function CoolChatData:GetGoldTextConfig()
	if not self.tuhaojin_attr_cfg then
		self.tuhaojin_attr_cfg = ConfigManager.Instance:GetAutoConfig("tuhaojin_auto")
	end
	return self.tuhaojin_attr_cfg
end

-- 获取大表情的属性
function CoolChatData:GetBigFaceTotalAttr()
	local total_attr = CommonStruct.Attribute()
	local curr_cfg = self:GetBigFaceLevelConfig(self.big_face_level)
	local next_cfg = self:GetBigFaceLevelConfig(self.big_face_level + 1)
	if next_cfg then
		total_attr = CommonDataManager.LerpAttributeAttrNoUnderLine(curr_cfg, next_cfg)
	else
		total_attr = curr_cfg
	end
	return curr_cfg,total_attr
end

function CoolChatData:BigFaceIsMaxLevelByseq(seq)
	-- if not next(self.bigchatface_cfg) then
	-- 	return false
	-- end
	-- local max_lev = self.bigchatface_cfg.other[1].grid_max_level
	-- local lev = self.grid_level_list[seq + 1] or 0
	-- if lev >= max_lev then
	-- 	return true
	-- end
	return false
end

function CoolChatData:GetBigFaceItemByItemId(item_id)
	-- local grid_attr_cfg = self.bigchatface_cfg.grid_attr_cfg or {}
	-- for k, v in ipairs(grid_attr_cfg) do
	-- 	if v.active_item_id == item_id then
	-- 		return v
	-- 	end
	-- end
	return nil
end

function CoolChatData:SetTuHaoJinInfo(protocol)
	self.tuhaojin_info.tuhaojin_level = protocol.tuhaojin_level
	self.tuhaojin_info.cur_tuhaojin_color = protocol.cur_tuhaojin_color
	self.tuhaojin_info.max_tuhaojin_color = protocol.max_tuhaojin_color
end

function CoolChatData:GetTuHaoJinLevel()
	return self.tuhaojin_info.tuhaojin_level
end

function CoolChatData:GetTuHaoJinCurColor()
	return self.tuhaojin_info.cur_tuhaojin_color
end

function CoolChatData:GetTuHaoJinMaxColor()
	return self.tuhaojin_info.max_tuhaojin_color
end

-- 根据物品ID 获取精华属性
function CoolChatData:GetJingHuaAttrByItemId(item_id)
	-- for k,v in pairs(self.tuhaojin_attr_cfg) do
	-- 	if item_id == v.activre_item_id then
	-- 		return v
	-- 	end
	-- end
	return nil
end

-- 根据seq 获取精华属性
function CoolChatData:GetJingHuaAttrBySeq(seq)
	-- for k,v in pairs(self.tuhaojin_attr_cfg) do
	-- 	if seq == v.seq then
	-- 		return v
	-- 	end
	-- end
	return nil
end

-- 获取精华所有
function CoolChatData:GetAllJingHuaItemCfg()
	local config = {}
	local i = 1
	local tuhaojin_attr_cfg = self:GetGoldTextConfig().jinghua_attr_cfg
	if tuhaojin_attr_cfg then
		for k,v in pairs(tuhaojin_attr_cfg) do
			local data = {}
			data.item_id = v.activre_item_id
			data.limit_level = self:GetTuHaoJinActiveLevelBySeq(v.seq)
			config[i] = data
			i = i + 1
		end
		return config
	end
end

-- 根据seq获取当前激活等级
function CoolChatData:GetTuHaoJinActiveLevelBySeq(seq)
	local tuhaojin_cfg = self:GetGoldTextConfig()
	if tuhaojin_cfg then
		local level_cfg = tuhaojin_cfg.level_cfg
		if level_cfg then
			for k,v in ipairs(level_cfg) do
				if seq == v.tuhaojin_color_id then
					return v.tuhaojin_level
				end
			end
		end
	end
	return 0
end

-- 获取是否已全部激活精华
function CoolChatData:GetAllActivationTuHaoJin()
	-- local is_activation = true
	-- for k,v in pairs(self.tuhaojin_info.tuhaojin_list) do
	-- 	if v <= 0 then
	-- 		is_activation = false
	-- 	end
	-- end
	-- return is_activation
	return false
end

-- 获取土豪金等级配置
function CoolChatData:GetTuhaojinLevelConfig(level)
	local cfg = {}
	if self.tuhaojin_level_cfg then
		cfg = self.tuhaojin_level_cfg[level]
	end
	return cfg
end

-- 获取所有精华属性(土豪金)
function CoolChatData:GetJingHuaAllAttr()
	local curr_cfg = CommonStruct.Attribute()
	local next_cfg = CommonStruct.Attribute()
	local total_attr = CommonStruct.Attribute()
	curr_cfg = self:GetTuhaojinLevelConfig(self.tuhaojin_info.tuhaojin_level)
	next_cfg = self:GetTuhaojinLevelConfig(self.tuhaojin_info.tuhaojin_level + 1)
	if next_cfg then
		total_attr = CommonDataManager.LerpAttributeAttrNoUnderLine(curr_cfg, next_cfg)
	else
		total_attr = curr_cfg
	end
	return curr_cfg,total_attr
end

-- 获取气泡框等级配置
function CoolChatData:GetBubbleLevelConfig(level)
	local cfg = {}
	if self.bubble_single_level_cfg then
		cfg = self.bubble_single_level_cfg[level]
	end
	return cfg
end

-- 获取气泡框属性
function CoolChatData:GetBubbleAllAttr(index)
	local curr_cfg = CommonStruct.Attribute()
	local next_cfg = CommonStruct.Attribute()
	local total_attr = CommonStruct.Attribute()
	curr_cfg = self:GetBubbleLevelConfig(self.bubble_level_list[index])
	next_cfg = self:GetBubbleLevelConfig(self.bubble_level_list[index] + 1)
	if next_cfg then
		total_attr = CommonDataManager.LerpAttributeAttrNoUnderLine(curr_cfg, next_cfg)
	else
		total_attr = curr_cfg
	end
	return curr_cfg,total_attr
end

--获取当前精华是否最大等级
function CoolChatData:IsMaxLevelByseq(seq)
	-- local lev = self:GetTuHaoJinInfoBySeq(seq) or 0
	-- if lev >= TUHAOJIN_REQ_TYPE.TUHAOJIN_MAX_LEVEL then
	-- 	return true
	-- else
	-- 	return false
	-- end
	return false
end

function CoolChatData:SetBubbleAttribute()
	local total_attr = CommonStruct.Attribute()
	for k,v in pairs(self.bubble_level_list) do
		if v > 0 then
			local cfg = self:GetBubbleCfgByLevel(k, v)
			if cfg then
				total_attr.max_hp = total_attr.max_hp + (cfg.maxhp or 0)
				total_attr.gong_ji = total_attr.gong_ji + (cfg.gongji or 0)
				total_attr.fang_yu = total_attr.fang_yu + (cfg.fangyu or 0)
				total_attr.ming_zhong = total_attr.ming_zhong + (cfg.mingzhong or 0)
				total_attr.shan_bi = total_attr.shan_bi + (cfg.shanbi or 0)
				total_attr.bao_ji = total_attr.bao_ji + (cfg.baoji or 0)
				total_attr.jian_ren = total_attr.jian_ren + (cfg.jianren or 0)
			end
		end
	end
	self.attr_data = total_attr
end

function CoolChatData:GetBubbleAttribute()
	local config = TableCopy(self.attr_data)
	for k,v in pairs(config) do
		if v == 0 then
			config[k] = nil
		end
	end
	if next(config) == nil then
		config = self.attr_data
	end
	return config
end

function CoolChatData:GetBubbleIsActiveByType(bubble_type)
	local bubble_level_cfg = self:GetBubbleLevelCfg()
	if bubble_level_cfg then
		local bubble_level = self.bubble_level_list[bubble_type] or 0
		for k,v in pairs(bubble_level_cfg) do
			if v.bubble_type == bubble_type - 1 then
				if v.bubble_level == bubble_level then
					return v.is_active == 1
				end
			end
		end
	end
	return false
end

function CoolChatData:GetBubbleLimitLevelByType(bubble_type)
	local bubble_level_cfg = self:GetBubbleLevelCfg()
	local limit_level = 999
	if bubble_level_cfg then
		for k,v in pairs(bubble_level_cfg) do
			if v.bubble_type == bubble_type - 1 then
				if v.is_active == 1 then
					limit_level = v.bubble_level < limit_level and v.bubble_level or limit_level
				end
			end
		end
	end
	return limit_level
end

function CoolChatData:GetBubbleCfgByLevel(bubble_type, level)
	bubble_type = bubble_type - 1
	local bubble_level_cfg = self:GetBubbleLevelCfg()
	if bubble_level_cfg then
		for k,v in pairs(bubble_level_cfg) do
			if v.bubble_type == bubble_type then
				if v.bubble_level == level then
					return v
				end
			end
		end
	end
end

function CoolChatData:SetBubbleInfo(info)
	local bubble_list = {}
	self.select_seq = info.cur_use_bubble_type
	self.bubble_level_list = info.bubble_level
	local bubble_attr_cfg = self:GetBubbleCfg() or {}
	for k, v in ipairs(bubble_attr_cfg) do
		local data = {}
		for k1, v1 in pairs(v) do
			data[k1] = v1
		end
		bubble_list[k] = data
		bubble_list[k].is_activate = self:GetBubbleIsActiveByType(v.seq)
		bubble_list[k].limit_level = self:GetBubbleLimitLevelByType(v.seq)
		bubble_list[k].select_seq = info.cur_use_bubble_type
		bubble_list[k].level = self.bubble_level_list[v.seq]
	end
	self.bubble_list = bubble_list
	self:SetBubbleAttribute()
end

-- 气泡框等级配置
function CoolChatData:GetBubbleLevelCfg()
	if not self.bubble_level_cfg then
		self.bubble_level_cfg = ConfigManager.Instance:GetAutoConfig("personalize_window_auto").bubble_level_cfg
	end
	return self.bubble_level_cfg
end

function CoolChatData:GetBubbleCfg()
	if not self.bubble_attr_cfg then
		self.bubble_attr_cfg = ConfigManager.Instance:GetAutoConfig("personalize_window_auto").bubble_rim
	end
	return self.bubble_attr_cfg
end

function CoolChatData:GetBubbleIndexByItemId(item_id)
	local index = 0
	local bubble_attr_cfg = self:GetBubbleCfg() or {}
	for k, v in ipairs(bubble_attr_cfg) do
		local itme_data = v.item1 or {}
		if itme_data.item_id == item_id then
			index = v.seq
			break
		end
	end
	return index
end

function CoolChatData:GetBubbleCfgByItemId(item_id)
	if not item_id then return end
	local bubble_attr_cfg = self:GetBubbleCfg() or {}
	for k, v in ipairs(bubble_attr_cfg) do
		local itme_data = v.item1 or {}
		if itme_data.item_id == item_id then
			return v
		end
	end
	return
end

function CoolChatData:GetSelectSeq()
	return self.select_seq
end

function CoolChatData:GetBubbleInfo()
	return self.bubble_list
end

function CoolChatData:GetIsActivateByIndex(index)
	for k, v in ipairs(self.bubble_list) do
		if k == index then
			return v.is_activate
		end
	end
	return false
end

--获取是否有气泡框可升级
function CoolChatData:GetBubbleCanActivate()
	for k, v in ipairs(self.bubble_list) do
		if v.level < self:GetBubbleMaxLevel(v.seq) then
			local cfg = self:GetBubbleCfgByLevel(v.seq, v.level)
			if cfg then
				local need_num1 = cfg.common_item.num or 0
				if cfg.common_item.item_id == 0 then
					need_num1 = 0
				end
				local has_num1 = ItemData.Instance:GetItemNumInBagById(cfg.common_item.item_id) or 0

				--local prof = Scene.Instance:GetMainRole().vo.prof
				local prof = GameVoManager.Instance:GetMainRoleVo().prof
				local prof_item = cfg.prof_one_item
				if prof == 2 then
					prof_item = cfg.prof_two_item
				elseif prof == 3 then
					prof_item = cfg.prof_three_item
				elseif prof == 4 then
					prof_item = cfg.prof_four_item
				end
				local need_num2 = prof_item.num or 0
				if cfg.is_need_prof_item == 0 then
					need_num2 = 0
				end
				local has_num2 = ItemData.Instance:GetItemNumInBagById(prof_item.item_id) or 0

				if has_num1 >= need_num1 and has_num2 >= need_num2 then
					return true
				end
			end
		end
	end
	return false
end

--获取大表情红点
function CoolChatData:GetBigFaceRedPoint()
	if self.big_face_level < self:GetBigFaceMaxLevel() then
		local big_face_cfg = CoolChatData.Instance:GetBigFaceConfig()
		if big_face_cfg then
			local level_cfg = big_face_cfg.level_cfg
			if level_cfg then
				local cfg = level_cfg[self.big_face_level + 1]
				if cfg then
					local need_num1 = cfg.common_item.num or 0
					if cfg.common_item.item_id == 0 then
						need_num1 = 0
					end
					local has_num1 = ItemData.Instance:GetItemNumInBagById(cfg.common_item.item_id) or 0
					local prof = GameVoManager.Instance:GetMainRoleVo().prof
					local prof_item = cfg.prof_one_item
					if prof == 2 then
						prof_item = cfg.prof_two_item
					elseif prof == 3 then
						prof_item = cfg.prof_three_item
					elseif prof == 4 then
						prof_item = cfg.prof_four_item
					end
					local need_num2 = prof_item.num or 0
					if cfg.is_need_prof_item == 0 then
						need_num2 = 0
					end
					local has_num2 = ItemData.Instance:GetItemNumInBagById(prof_item.item_id) or 0
					if has_num1 >= need_num1 and has_num2 >= need_num2 then
						return true
					end
				end
			end
		end
	end
	return false
end

--获取土豪金红点
function CoolChatData:GetGoldTextRedPoint()
	local tuhaojin_level = self.tuhaojin_info.tuhaojin_level
	if tuhaojin_level < self:GetTuHaoJinMaxLevel() then
		local tuhaojin_cfg = CoolChatData.Instance:GetGoldTextConfig()
		if tuhaojin_cfg then
			local level_cfg = tuhaojin_cfg.level_cfg
			if level_cfg then
				local cfg = level_cfg[tuhaojin_level + 1]
				if cfg then
					local need_num1 = cfg.common_item.num or 0
					if cfg.common_item.item_id == 0 then
						need_num1 = 0
					end
					local has_num1 = ItemData.Instance:GetItemNumInBagById(cfg.common_item.item_id) or 0
					local prof = GameVoManager.Instance:GetMainRoleVo().prof
					local prof_item = cfg.prof_one_item
					if prof == 2 then
						prof_item = cfg.prof_two_item
					elseif prof == 3 then
						prof_item = cfg.prof_three_item
					elseif prof == 4 then
						prof_item = cfg.prof_four_item
					end
					local need_num2 = prof_item.num or 0
					if cfg.is_need_prof_item == 0 then
						need_num2 = 0
					end
					local has_num2 = ItemData.Instance:GetItemNumInBagById(prof_item.item_id) or 0
					if has_num1 >= need_num1 and has_num2 >= need_num2 then
						return true
					end
				end
			end
		end
	end
	return false
end

-- 获得炫酷聊天界面红点
function CoolChatData:GetCoolChatRedPoint()
	local flag = false
	flag = self:GetBubbleCanActivate()
	if not flag then
		flag = self:GetBigFaceRedPoint()
	end
	if not flag then
		flag = self:GetGoldTextRedPoint()
	end
	if not flag then
		flag = HeadFrameData.Instance:GetHeadFrameRedPoint()
	end
	return flag
end

function CoolChatData:GetCoolChatRemind()
	if self:GetCoolChatRedPoint() then
		return 1
	else
		return 0
	end
end

function CoolChatData:GetSeqByIndex(index)
	for k, v in ipairs(self.bubble_list) do
		if k == index then
			return v.seq
		end
	end
	return 0
end

function CoolChatData:GetBubbleDataByIndex(index)
	for k, v in ipairs(self.bubble_list) do
		if k == index then
			return v
		end
	end
	return {}
end

-- 是否使用了土豪金
function CoolChatData:GetIsUseTuHaoJin()
	-- return self.tuhaojin_info.is_use_tuhaojin == 1
	return false
end

-- 是否使用了土豪金
function CoolChatData:GetTuHaoJinColorByIndex(index)
	index = index or 0
	local tuhaojin_cfg = CoolChatData.Instance:GetGoldTextConfig()
	if tuhaojin_cfg then
		local jinghua_attr_cfg = tuhaojin_cfg.jinghua_attr_cfg
		if jinghua_attr_cfg then
			for k,v in pairs(jinghua_attr_cfg) do
				if index == v.seq then
					return  "#" .. v.color_id
				end
			end
		end
	end
	return COLOR.WHITE
end

-- 根据气泡框类型得到气泡框最大等级
function CoolChatData:GetBubbleMaxLevel(bubble_type)
	bubble_type = bubble_type or 0
	bubble_type = bubble_type - 1
	local bubble_level_cfg = self:GetBubbleLevelCfg()
	local max_level = 0
	if bubble_level_cfg then
		for k,v in pairs(bubble_level_cfg) do
			if v.bubble_type == bubble_type then
				max_level = v.bubble_level > max_level and v.bubble_level or max_level
			end
		end
	end
	return max_level
end

-- 大表情最大等级
function CoolChatData:GetBigFaceMaxLevel()
	local big_face_cfg = CoolChatData.Instance:GetBigFaceConfig()
	if big_face_cfg then
		local level_cfg = big_face_cfg.level_cfg
		if level_cfg then
			return (#level_cfg - 1)
		end
	end
	return 0
end

-- 土豪金最大等级
function CoolChatData:GetTuHaoJinMaxLevel()
	local tuhaojin_cfg = CoolChatData.Instance:GetGoldTextConfig()
	if tuhaojin_cfg then
		local level_cfg = tuhaojin_cfg.level_cfg
		if level_cfg then
			return (#level_cfg - 1)
		end
	end
	return 0
end