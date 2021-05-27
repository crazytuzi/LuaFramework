CrossServerData = CrossServerData or BaseClass(BaseController)


function CrossServerData:InitFlopCard()
	self.flop_num = 0
	self.brands_data = {}
	self.flop_record = ""
	self.drawed_num = 0	--当前已抽次数
end

function CrossServerData:SetFlopInfo(pro)
	self.flop_num = pro.flop_num
	self.brands_data = pro.brands_data
	self.flop_record = pro.flop_record
	self:DispatchEvent(CrossServerData.FLOP_DATA_CHANGE, {})
end

function CrossServerData:InitCrossBrand()
	self.cross_brand_data = {
		free_times = 0,
		can_turn = false,
		turn_gold = 0,
		reset_times = 0,
		reset_gold = 0,
		brand_list = {}
	}
	for i = 1, #TurnOverCardsCfg.allCards do
		self.cross_brand_data.brand_list[i] = {
			index = i,
			is_open = false,
			item_index = 1,
			item_data = CommonStruct.ItemDataWrapper(),
		}
	end
end

function CrossServerData.GetBrandTipContent()
	return TurnOverCardsCfg.TipContent
end

function CrossServerData:IsCanBrandConsumeNow()
	return self.cross_brand_data.can_turn
end

function CrossServerData:GetTurnCurBrandConsume()
	return self.cross_brand_data.turn_gold
end

function CrossServerData:GetBrandRecord()
	local list = {}
	local str = self.cross_brand_data.flop_record
	if nil == str then return {} end
	local tag_t = Split(str, ";")
	for i= #tag_t, 1, -1 do
		local str2 =  Split(tag_t[i], "#")
		local vo = {}
		vo.name = str2[1]
		vo.flop_opt = tonumber(str2[2])
		vo.pool_idx = tonumber(str2[3])
		vo.award_idx = tonumber(str2[4])
		table.insert(list, vo)
	end
	return list
end

function CrossServerData:GetCrossTumoAddTime(protocol)
	return self.add_time or 0
end

function CrossServerData:SetCrossTumoAddTime(protocol)
	if protocol.cross_start_time ~= 0 then
		self.add_time = protocol.cross_start_time + GlobalConfig.nIntervalDevilTokenTimes
	end
	
	self:DispatchEvent(CrossServerData.CROSS_TUMO_ADD_TIME)
end

function CrossServerData:SetBrandInfo(protocol)
	self.cross_brand_data.flop_num = protocol.flop_num
	self.cross_brand_data.flop_record = protocol.flop_record
	self.cross_brand_data.can_turn = protocol.is_can_draw
	local new_idx = protocol.flop_opt 		-- 新增翻好的牌
	local free_times = 1	-- 第一张牌免费
	local drawed_num = 0 	-- 已翻次数
	for k, v in ipairs(protocol.brands_data) do
		if self.cross_brand_data.brand_list[v.card_idx] then
			-- if not self.cross_brand_data.brand_list[k].is_open and v.item_index > 0 then
			-- 	new_idx = k
			-- end

			self.cross_brand_data.brand_list[v.card_idx].item_index = v.item_index
			self.cross_brand_data.brand_list[v.card_idx].is_open = v.item_index > 0
			self.cross_brand_data.brand_list[v.card_idx].item_data = CrossServerData.GetBrandItemData(v.pool_idx, v.item_index) or CommonStruct.ItemDataWrapper()

			if v.item_index > 0 then
				free_times = 0
				drawed_num = drawed_num + 1
			end
		end
	end

	self.cross_brand_data.turn_gold = TurnOverCardsCfg.extraConsumes[drawed_num + 1] and TurnOverCardsCfg.extraConsumes[drawed_num + 1].count or 0
	self.cross_brand_data.free_times = (self.cross_brand_data.can_turn and self.cross_brand_data.turn_gold == 0) and free_times or 0

	self.drawed_num = drawed_num

	self:DispatchEvent(CrossServerData.FLOP_DATA_CHANGE, new_idx)
end

function CrossServerData:GetAwardData()
end

function CrossServerData:GetDrawedNum()
	return self.drawed_num
end

function CrossServerData:GetFlopConsume()
	return self.cross_brand_data.turn_gold
end

function CrossServerData:BrandCanTurn()
	return self.cross_brand_data.can_turn
end

function CrossServerData:GetBrandDataList()
	return self.cross_brand_data.brand_list
end

function CrossServerData.GetBrandItemData(brand_index, item_index)
	local items_cfg = TurnOverCardsCfg.allCards[brand_index]
	if items_cfg and items_cfg[item_index] then
		return ItemData.FormatItemData(items_cfg[item_index].awards[1])
	end
end

function CrossServerData:GetBrandData(index)
	return self.cross_brand_data.brand_list[index]
end

function CrossServerData:GetResetBrandInfo()
	return {left_reset_times = 3, gold_consume = 200}
end

function CrossServerData:GetFreeCrossBrandTimes()
	return self.cross_brand_data.free_times
end

function CrossServerData:GetFreeCrossBrandRemind()
	return self.cross_brand_data.flop_num
end

function CrossServerData:GetBrandPreviewItems()
	local items = {}
	local items_cfg = TurnOverCardsCfg.showAwards
	local role_sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	local role_prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	for _, v in pairs(items_cfg) do
		if (nil == v.sex or v.sex == role_sex)
			and (nil == v.job or v.job == role_prof) then
			table.insert(items, ItemData.FormatItemData(v))
		end
	end
	return items
end

function CrossServerData:GetBrandRemind()
	return self.cross_brand_data.flop_num
end

-- CrossServerData.BossModCfgIndex = {
-- 	[1] = 11,
-- 	[2] = 12,
-- 	[3] = 13,
-- 	[4] = 14,
-- }

function CrossServerData:GetCrossBossIsRemind(boss_type, boss_id)
	return BossData.Instance:GetRemindFlag(boss_type, BossData.Instance:GetRemindex(boss_type, boss_id) or 0) == 0
end

function CrossServerData:GetCrossBossInfoRemindByIdx(tabbar_idx)
	local open_server_days = OtherData.Instance:GetOpenServerDays()
	for _, data in ipairs(ModBossConfig[CrossServerData.BossModCfgIndex[tabbar_idx]]) do
		if open_server_days >= data.opensvrday
		and BossData.BossIsEnoughAndTip(data)
		and BossData.Instance:GetRemindFlag(data.type, BossData.Instance:GetRemindex(data.type, data.BossId) or 0) == 0
		then
			if self:GetCrossBossInfoById(data.BossId) and self:GetCrossBossInfoById(data.BossId).refresh_time - Status.NowTime > 0 then
				return 0
			end
			return 1
		end
	end
	return 0
end

function CrossServerData:GetCrossBossInfoRemind()
	for tabbar_idx = 1, #CrossServerData.BossModCfgIndex do
		if self:GetCrossBossInfoRemindByIdx(tabbar_idx) > 0 then
			return 1
		end
	end
	return 0
end