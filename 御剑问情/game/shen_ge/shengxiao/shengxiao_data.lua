ShengXiaoData = ShengXiaoData or BaseClass()
ShengXiaoData.HasOpenShenxiaoUplevel = false --是否打开过生肖升级界面
function ShengXiaoData:__init()
	if ShengXiaoData.Instance then
		print_error("[ShengXiaoData] Attemp to create a singleton twice !")
	end
	ShengXiaoData.Instance = self
	local chinese_zodiac_cfg = ConfigManager.Instance:GetAutoConfig("chinese_zodiac_cfg_auto") or {}

	self.equip_cfg = ListToMap(chinese_zodiac_cfg.equip, "equip_type", "level")

	self.single_info_cfg = ListToMap(chinese_zodiac_cfg.single_info, "seq", "level")

	self.xinghun_cfg = ListToMap(chinese_zodiac_cfg.xinghun, "seq", "level")

	self.miji_cfg = chinese_zodiac_cfg.miji_cfg

	self.bead_chapter_attr_cfg = chinese_zodiac_cfg.bead_chapter_attr

	self.miji_open_limit_cfg = chinese_zodiac_cfg.miji_open_limit

	self.miji_kong_limit_cfg = chinese_zodiac_cfg.miji_kong_open_limit

	self.point_effect_cfg = chinese_zodiac_cfg.point_effect

	self.xingling_point_effect_cfg = chinese_zodiac_cfg.xingling_point_effect

	self.bead_cfg = chinese_zodiac_cfg.bead

	self.starsoul_point_effect_cfg = chinese_zodiac_cfg.xinghun_effect

	self.xingling_cfg = chinese_zodiac_cfg.xingling

	self.xinghun_extra_cfg = chinese_zodiac_cfg.xinghun_extra_info

	self.suit_info_cfg = chinese_zodiac_cfg.suit_info
	self.other_cfg = chinese_zodiac_cfg.other
	table.sort(self.suit_info_cfg, function(a, b)
		return a.level < b.level
	end)

	self.combine_attr_cfg = chinese_zodiac_cfg.combine_attr

	self.funny_trun_combine = chinese_zodiac_cfg.funny_trun_combine

	self.zodiac_level_list = {}
	self.chinesezodiac_equip_list = {}
	self.xinghun_level_list = {}
	self.xinghun_level_max_list = {}
	self.xinghun_baoji_value_list = {}
	self.xinghun_old_level_list = {}
	for i = 1, GameEnum.CHINESE_ZODIAC_SOUL_MAX_TYPE_LIMIT do
		self.zodiac_level_list[i] = 0
		self.xinghun_level_list[i] = 0
		self.xinghun_level_max_list[i] = 0
		self.xinghun_old_level_list[i] = 0
		self.xinghun_baoji_value_list[i] = 0
		self.chinesezodiac_equip_list[i]  = {}
		for j = 1, GameEnum.CHINESE_ZODIAC_EQUIP_SLOT_MAX_LIMIT do
			self.chinesezodiac_equip_list[i][j] = 0
		end
	end
	self.uplevel_index = 1
	self.curr_chapter = 1
	self.is_stop_ernie_animation = true
	self.active_list = {}
	self.chapter_list = {}
	self.bead_by_combine_list = {}
	self.grid_seq_list = {}
	self.combine_type = {}
	self.ernie_bless_reward_list = {}
	self.cur_show_anim_list = {}
	self.spirit_list = {}
	self.chapter_total_cap = 0
	self.zodiac_progress = 1
	self.upgrade_zodiac = -1
	self.today_free_ggl_times = 0
	self.last_free_ggl_time = 0
	self.end_turn_index = 1
	self.miji_shengxiao_index = 1
	self.is_finish_all_chapter = 0
	self.equip_is_auto_buy = false
	self.miji_list = {}
	for i = 1, GameEnum.CHINESE_ZODIAC_SOUL_MAX_TYPE_LIMIT do
		self.miji_list[i]  = {}
		for j = 1, GameEnum.MIJI_KONG_NUM do
			self.miji_list[i][j] = -1
		end
	end

	RemindManager.Instance:Register(RemindName.ShengXiao_Equip, BindTool.Bind(self.CalcEquipRedPoint, self))
	RemindManager.Instance:Register(RemindName.ShengXiao_Uplevel, BindTool.Bind(self.CalcUpLevelRedPoint, self))
	RemindManager.Instance:Register(RemindName.ShengXiao_Piece, BindTool.Bind(self.CalcPieceRedPoint, self))
	RemindManager.Instance:Register(RemindName.ShengXiao_Spirit, BindTool.Bind(self.CalcSpiritRedPoint, self))
	RemindManager.Instance:Register(RemindName.ShengXiao_StarSoul, BindTool.Bind(self.CalcStarSoulRedPoint, self))
	RemindManager.Instance:Register(RemindName.ErnieView, BindTool.Bind(self.CalcErnieRedPoint, self))
end

function ShengXiaoData:__delete()
	RemindManager.Instance:UnRegister(RemindName.ShengXiao_Equip)
	RemindManager.Instance:UnRegister(RemindName.ShengXiao_Uplevel)
	RemindManager.Instance:UnRegister(RemindName.ShengXiao_Piece)
	RemindManager.Instance:UnRegister(RemindName.ShengXiao_Spirit)
	RemindManager.Instance:UnRegister(RemindName.ShengXiao_StarSoul)
	RemindManager.Instance:UnRegister(RemindName.ErnieView)
	self.spirit_list = nil
	ShengXiaoData.Instance = nil

	UnityEngine.PlayerPrefs.DeleteKey("enter_xingzuoyiji")
end

function ShengXiaoData:SetShengXiaoAllInfo(all_info)
	self.zodiac_level_list = all_info.zodiac_level_list
	self.xinghun_level_list = all_info.xinghun_level_list
	self.xinghun_level_max_list = all_info.xinghun_level_max_list
	self.xinghun_baoji_value_list = all_info.xinghun_baoji_value_list
	self.chinesezodiac_equip_list = all_info.chinesezodiac_equip_list
	self.zodiac_progress = all_info.zodiac_progress
	self.xinghun_progress = all_info.xinghun_progress
	self.upgrade_zodiac = all_info.upgrade_zodiac
	self.miji_list = all_info.miji_list
end

function ShengXiaoData:SetOneMijiInfo(one_info)
	self.miji_list[one_info.zodiac_type + 1][one_info.kong_index + 1] = one_info.miji_index
end

function ShengXiaoData:SetEndTurnIndex(index)
	self.end_turn_index = index + 1
end

function ShengXiaoData:GetEndIndex()
	return self.end_turn_index
end

function ShengXiaoData:SetMijiShengXiaoIndex(index)
	self.miji_shengxiao_index = index
end

function ShengXiaoData:GetMijiShengXiaoIndex()
	return self.miji_shengxiao_index
end

function ShengXiaoData:GetMijiCountByindex(index)
	local count = 0
	for k,v in pairs(self.miji_list[index]) do
		if v > -1 then
			count = count + 1
		end
	end
	return count
end

function ShengXiaoData:GetMijiToSkillCd()
	local total_cd = 0
	for k,v in pairs(self.miji_list) do
		if v then
			for k1,v1 in pairs(v) do
				if v1 >= 0 then
					local cfg = self:GetMijiCfgByIndex(v1)
					if cfg.type == 11 then
						total_cd = total_cd + cfg.value
					end
				end
			end
		end
	end
	return total_cd < 6000 and total_cd or 6000
end

function ShengXiaoData:GetMijiOpenCfgByIndex(index)
	for k,v in pairs(self.miji_open_limit_cfg) do
		if index - 1 == v.index then
			return v
		end
	end
	return nil
end

function ShengXiaoData:GetKongIsOpenByIndex(index)
	for k,v in pairs(self.miji_kong_limit_cfg) do
		if index - 1 == v.index then
			return v.zodiac_level_limit
		end
	end
	return 0
end

function ShengXiaoData:GetBagMijiList()
	local bag_list = {}
	for k,v in pairs(self.miji_cfg) do
		local bag_num = ItemData.Instance:GetItemNumInBagById(v.item_id)
		if bag_num > 0 then
			local have_type = 1
			for k1,v1 in pairs(self.miji_list[self.miji_shengxiao_index]) do
				if v1 >=0 then
					local miji_type = self:GetMijiCfgByIndex(v1).type
					if v.type == miji_type then
						have_type = 0
					end
				end
			end
			local vo = {}
			vo.item_num = bag_num
			vo.item_id = v.item_id
			vo.cfg_index = v.index
			vo.have_type = have_type
			vo.level = v.level
			table.insert(bag_list, vo)
		end
	end
	table.sort(bag_list, SortTools.KeyUpperSorters("have_type", "level"))
	return bag_list
end
function ShengXiaoData:GetAllMijiList()
	local bag_list = {}
	for k,v in pairs(self.miji_cfg) do
		local vo = {}
		vo.item_num = 1
		vo.item_id = v.item_id
		vo.cfg_index = v.index
		vo.level = v.level
		table.insert(bag_list, vo)
	end
	--table.sort(bag_list, SortTools.KeyUpperSorters("level"))
	return bag_list
end

function ShengXiaoData:GetMijiCfgByIndex(index)
	for k,v in pairs(self.miji_cfg) do
		if v.index == index then
			return v
		end
	end
	return nil
end

function ShengXiaoData:GetMijiCfgByItemId(item_id)
	for k,v in pairs(self.miji_cfg) do
		if v.item_id == item_id then
			return v
		end
	end
	return nil
end

function ShengXiaoData:GetZodiacMijiList(index)
	return self.miji_list[index]
end

function ShengXiaoData:GetUpgradeZodiac()
	return self.upgrade_zodiac
end

function ShengXiaoData:SetTianXianAllInfo(all_info)
	self.curr_chapter = all_info.curr_chapter + 1
	self.active_list = all_info.active_list
	self.chapter_list = all_info.chapter_list
	self.bead_by_combine_list = all_info.bead_by_combine_list
	self.is_finish_all_chapter = all_info.is_finish_all_chapter
end

function ShengXiaoData:GetIsFinishAll()
	return self.is_finish_all_chapter
end

function ShengXiaoData:SetCurShowList(data)
	if next(data) then
		self.cur_show_anim_list = data
	end
end

function ShengXiaoData:GetCurShowList()
	return self.cur_show_anim_list
end

function ShengXiaoData:SetTianXiangSignBead(all_info)
	if self.chapter_list[all_info.chapter + 1] == nil or self.chapter_list[all_info.chapter + 1][all_info.y + 1] == nil
		or self.chapter_list[all_info.chapter + 1][all_info.y + 1][all_info.x + 1] == nil then
		return
	end
	self.chapter_list[all_info.chapter + 1][all_info.y + 1][all_info.x + 1] = all_info.type
end

function ShengXiaoData:SetTianXiangCombind(all_info)
	self.active_list[all_info.curr_chapter + 1] = all_info.active_list
	self.bead_by_combine_list[all_info.curr_chapter + 1] = self.bead_by_combine_list[all_info.curr_chapter + 1] or {}
	self.bead_by_combine_list[all_info.curr_chapter + 1] = all_info.bead_by_combine_list
end

function ShengXiaoData:GetShowAnimListByChatper(chapter)
	return self.bead_by_combine_list[chapter]
end

function ShengXiaoData:GetMaxChapter()
	return self.curr_chapter
end

function ShengXiaoData:GetTianXianInfoByChapter(y, x, curr_chapter)
	local cur_chapter_list = self.chapter_list[curr_chapter]
	if cur_chapter_list == nil then
		return 0
	end
	if cur_chapter_list[y] == nil or cur_chapter_list[y][x] == nil then
		return 0
	end
	return cur_chapter_list[y][x]
end

function ShengXiaoData:GetTianxianInfoByPosAndChapter(chapter, y, x)
	if self.chapter_list[chapter] == nil or self.chapter_list[chapter][y] == nil or self.chapter_list[chapter][y][x] == nil then
		return 0
	end
	return self.chapter_list[chapter][y][x]
end

function ShengXiaoData:GetActiveList()
	return self.active_list
end

function ShengXiaoData:GetActiveListByChatper(chapter)
	return self.active_list[chapter]
end

function ShengXiaoData:GetOneChapterActive(chapter)
	local active_list = ShengXiaoData.Instance:GetActiveListByChatper(chapter)
	for k,v in pairs(active_list) do
		if v <= 0 then
			return false
		end
	end
	return true
end

function ShengXiaoData:GetChapterActiveNum(chapter)
	local active_list = ShengXiaoData.Instance:GetActiveListByChatper(chapter)
	local num = 0
	for k,v in pairs(active_list) do
		if v > 0 then
			num = num + 1
		end
	end
	return num
end

function ShengXiaoData:GetZodiacLevelList()
	return self.zodiac_level_list
end

function ShengXiaoData:GetZodiacLevelByIndex(index)
	return self.zodiac_level_list[index] or 0
end

function ShengXiaoData:GetMijiIsOpenByIndex(index)
	local miji_open_cfg = self:GetMijiOpenCfgByIndex(index)
	if index > 1 then
		local miji_count = self:GetMijiCountByindex(index - 1)
		return miji_count >= miji_open_cfg.last_miji_num_limit
	else
		return true
	end
end

function ShengXiaoData:GetMijiLimitCount(index)
	local miji_open_cfg = self:GetMijiOpenCfgByIndex(index)
	return miji_open_cfg.last_miji_num_limit
end

function ShengXiaoData:SetOneEquipInfo(zodiac_type, equip_type, equip_level)
	self.chinesezodiac_equip_list[zodiac_type + 1][equip_type + 1] = equip_level
end

function ShengXiaoData:GetZodiacInfoByIndex(index, level)
	local cfg = self.single_info_cfg[index - 1]
	return cfg and cfg[level] or nil
end

function ShengXiaoData:GetMaxZodiacLevel()
	local max_level = 0
	return max_level
end

function ShengXiaoData:GetEquipLevelListByindex(index)
	return self.chinesezodiac_equip_list[index]
end

function ShengXiaoData:GetOneEquipLevel(equip_type, equip_index)
	return self.chinesezodiac_equip_list[equip_type][equip_index]
end

function ShengXiaoData:GetEquipCfgByIndexAndLevel(index, level)
	local cfg = self.equip_cfg[index]
	return cfg and cfg[level] or nil
end

function ShengXiaoData:GetCurCanUpByIndex(index)
	local level = self:GetZodiacLevelByIndex(index)
	local cfg = self:GetZodiacInfoByIndex(index, level)
	local befor_level = self:GetZodiacLevelByIndex(index - 1)
	if cfg.level_limit > befor_level then
		return false
	end
	return true
end

function ShengXiaoData:GetShowRate()
	for i=1,12 do
		if not self:GetCurCanUpByIndex(i) then
			return i
		end
	end
	return 1
end
--uplevel面板 根据下标判断对应生肖是否可以升级（红点）
function ShengXiaoData:GetCanUpLevelRemindByIndex(index)
	local level = self:GetZodiacLevelByIndex(index)
	if level >= GameEnum.CHINESE_ZODIAC_LEVEL_MAX_LIMIT then
		return false
	end
	local cfg = self:GetZodiacInfoByIndex(index, level + 1)
	local befor_level = self:GetZodiacLevelByIndex(index - 1)
	local zodiac_progress = self:GetZodiacProgress()
	if index > zodiac_progress then
		return false
	end
	if cfg.level_limit > 0 and nil ~= befor_level then
		if cfg.level_limit > befor_level then
			return false
		end
		return ItemData.Instance:GetItemNumInBagById(cfg.item_id) >= cfg.expend
	end
	return ItemData.Instance:GetItemNumInBagById(cfg.item_id) >= cfg.expend
end
--瑞兽面板，根据下标返回对应瑞兽红点
function ShengXiaoData:GetSpiritRemindByStarIndex(index)
	local level = self:GetXingLingInfo(index).level
	if level >= 39 then
		return false
	end
	-- 服务端下发等级从-1开始
	local cfg = self:GetXingLingCfg(index - 1, level + 1)
	return ItemData.Instance:GetItemNumInBagById(cfg.uplevel_stuff_id) >= cfg.uplevel_stuff_num
end
--装备面板，根据生肖下标和装备位置获取对应装备红点
function ShengXiaoData:GetEquipRemindByEquipTypeAndIndex(equip_type, equip_index)
	local level = self:GetOneEquipLevel(equip_type, equip_index)
	if level >= GameEnum.CHINESE_ZODIAC_MAX_EQUIP_LEVEL then
		return false
	end
	local cfg = self:GetEquipCfgByIndexAndLevel(equip_index - 1, level + 1)
	local star_level = self:GetZodiacLevelByIndex(equip_type)
	if star_level < cfg.zodiac_level then
		return false
	end
	return ItemData.Instance:GetItemNumInBagById(cfg.consume_stuff_id) >= cfg.consume_stuff_num
end
--装备面板，根据生肖下标获取生肖item红点
function ShengXiaoData:GetEquipRemindByStarIndex(star_index)
	for i =1, 5 do
		if self:GetEquipRemindByEquipTypeAndIndex(star_index, i) then
			return true
		end
	end
	return false
end


--天相面板，根据生肖下标获取对应生肖item红点
function ShengXiaoData:GetStarSoulRemindByStarIndex(star_index)
	local zodiac_progress = self:GetStarSoulProgress()
	local cur_starsoul_level = self:GetStarSoulLevelByIndex(star_index)
	local cur_cfg = self:GetStarSoulInfoByIndexAndLevel(star_index, cur_starsoul_level)
	local item_num = ItemData.Instance:GetItemNumInBagById(cur_cfg.consume_stuff_id)
	if item_num >= cur_cfg.consume_stuff_num and self:GetStarSoulCanUp(star_index) and
		star_index <= zodiac_progress then
		return true
	else
		return false
	end
end

function ShengXiaoData:GetChapterAttrByChapter(chapter)
	for k,v in pairs(self.bead_chapter_attr_cfg) do
		if v.chapter == chapter - 1 then
			return v
		end
	end
	return nil
end

function ShengXiaoData:GetTotalLevel()
	local total_level = 0
	for i = 1, GameEnum.CHINESE_ZODIAC_SOUL_MAX_TYPE_LIMIT do
		total_level = total_level + self:GetZodiacLevelByIndex(i)
	end
	return total_level
end

function ShengXiaoData:GetTotalAttrListAndAttrState(is_next)
	local total_level = self:GetTotalLevel()
	local is_show_cur = true
	local is_show_next = true


	local suit_cfg = {}
	for k, v in pairs(self.suit_info_cfg) do
		if total_level == 0 and v.level == total_level then
			suit_cfg = self.suit_info_cfg[k + 1]
			is_show_cur = false
			break
		end

		if v.level > total_level then
			if k == 2 then
				suit_cfg = v
				is_show_cur = false
				break
			end

			if is_next then
				suit_cfg = v
				break
			end

			suit_cfg = self.suit_info_cfg[k - 1]
			break
		end

		if v.level == total_level and k < #self.suit_info_cfg then
			if is_next then
				suit_cfg = self.suit_info_cfg[k + 1]
				break
			end

			suit_cfg = v
			break
		end

		if k == #self.suit_info_cfg then
			is_show_next = false
			suit_cfg = v
			break
		end
	end

	return suit_cfg, is_show_cur, is_show_next
end

function ShengXiaoData:GetSuitCfgByLevel(level)
	for k,v in pairs(self.suit_info_cfg) do
		if v.level == level then
			return v
		end
	end
	return nil
end

function ShengXiaoData:GetShengXiaoIndexByCostItem(item_id)
	for k,v in pairs(self.single_info_cfg) do
		if v.item_id == item_id then
			return v.seq + 1
		end
	end
	return 0
end

function ShengXiaoData:SetUplevelIndex(index)
	self.uplevel_index = index
end

function ShengXiaoData:GetUplevelIndex()
	return self.uplevel_index
end

function ShengXiaoData:GetCombineCfgByIndex(index)
	for k,v in pairs(self.combine_attr_cfg) do
		if index == v.seq then
			return v
		end
	end
	return nil
end

function ShengXiaoData:GetOtherCfg()
	return self.other_cfg[1]
end

function ShengXiaoData:GetCostByMijiLevel(level)
	return self.other_cfg[1]["miji_compound_consume_gold" .. level + 1] or 0
end

-- 得到星座开锁进程
function ShengXiaoData:GetZodiacProgress()
	return self.zodiac_progress
end

---------------------------------------------摇奖机-----------------------------------------------

function ShengXiaoData:SetGunGunLeInfo(protocol)
	self.combine_type = protocol.combine_type
	self.today_free_ggl_times = protocol.today_free_ggl_times
	self.last_free_ggl_time = protocol.last_free_ggl_time
	self.ernie_bless_reward_list = {}
	for i = 1, protocol.count do
		local cfg = self:GetRollInfoByType(self.combine_type[i])
		if cfg then
			for k,v in pairs(cfg.reward_item) do
				local data = {}
				data.item_id = v.item_id
				data.num = v.num
				data.is_bind = v.is_bind
				table.insert(self.ernie_bless_reward_list, data)
			end
		end
	end
end

-- 得到摇奖机配置
function ShengXiaoData:GetRollInfoByType(combine_type)
	local index = 0
	local index1 = combine_type % 10
	combine_type = math.floor(combine_type / 10)
	local index2 = combine_type % 10
	combine_type = math.floor(combine_type / 10)
	local index3 = combine_type

	local same_count = 0
	-- 有3个相同数字
	if index1 == index2 and index1 == index3 then
		same_count = 3
		index = index1
	-- 有2个相同数字
	elseif index1 == index2 then
		same_count = 2
		index = index1
	elseif index1 == index3 then
		same_count = 2
		index = index1
	elseif index2 == index3 then
		same_count = 2
		index = index2
	end
	return self:FindFunnyTrunCfg(same_count, index)
end

function ShengXiaoData:FindFunnyTrunCfg(same_count, index)
	if same_count >= 2 then
		local find = false
		local cfg = nil
		for k1,v1 in pairs(self.funny_trun_combine) do
			if v1.combine_same_num == same_count then
				local combine_type_list = {}
				if type(v1.combine_type) == "number" then
					combine_type_list[1] = v1.combine_type
				elseif type(v1.combine_type) == "string" then
					combine_type_list = Split(v1.combine_type, ",")
				end
				for k2,v2 in pairs(combine_type_list) do
					if tonumber(v2) == index then
						find = true
						cfg = v1
						break
					end
				end
			end
		end
		if not find then
			return self:FindFunnyTrunCfg(same_count - 1, index)
		else
			return cfg
		end
	else
		return self:GetDefaultFunnyTrunCfg()
	end
end

-- 得到摇奖机安慰奖
function ShengXiaoData:GetDefaultFunnyTrunCfg()
	for k,v in pairs(self.funny_trun_combine) do
		if v.combine_same_num == 0 then
			return v
		end
	end
end

function ShengXiaoData:SetErnieIsStopPlayAni(switch)
	self.is_stop_ernie_animation = false
end

function ShengXiaoData:GetErnieIsStopPlayAni()
	return self.is_stop_ernie_animation
end

-- 得到摇奖机奖励列表
function ShengXiaoData:GetErnieBlessRewardDataList()
	return self.ernie_bless_reward_list
end
--装备红点
function ShengXiaoData:CalcEquipRedPoint()
	for i = 1, 12 do
		if self:GetEquipRemindByStarIndex(i) then
			return 1
		end
	end
	return 0
end
--生肖升级红点
function ShengXiaoData:CalcUpLevelRedPoint()
	if not OpenFunData.Instance:CheckIsHide("shengxiao_uplevel") then
		return 0
	end

	for i = 1, 12 do
		if self:GetCanUpLevelRemindByIndex(i) then
			return 1
		end
	end
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.ACTIVITY_TYPE_XINGZUOYIJI) then
		return 1
	end

	if self:GetXingzuoYijiRedPoint() and not ShengXiaoData.HasOpenShenxiaoUplevel then
		return 1
	end

	return 0
end

function ShengXiaoData:GetXingzuoYijiRedPoint()
	local info = RelicData.Instance:GetXingzuoYijiInfo()
	local gahter_count = RelicData.Instance:GetNowGatherNormalBoxNum() 	--星座遗迹木、银宝箱已收集次数
    local cfg = RelicData.Instance:GetRelicCfg().other[1]
    if cfg and cfg.common_box_gather_limit and gahter_count then
	    if cfg.common_box_gather_limit - gahter_count > 0  then			--判断允许收集次数是否大于已收集次数(木、银宝箱)
	    	if info and info.now_box_num and info.now_box_num > 0 then						--判断遗迹是否有箱子(木、银宝箱)
	    		return true
	    	end
	    end
	end
	if RelicData.Instance:IsShowBtnEffect() then 						--判断遗迹boss数目是否大于0
		return true
	end
	return false
end

-- 星图红点
function ShengXiaoData:CalcPieceRedPoint()
	if not OpenFunData.Instance:CheckIsHide("shengxiao_piece") then
		return 0
	end
	local flag = 0
	if self:IsErnieCanFree() then
		flag =  1
	end
	return flag
end

-- 星灵红点
function ShengXiaoData:CalcSpiritRedPoint()
	if not OpenFunData.Instance:CheckIsHide("shengxiao_spirit") then
		return 0
	end
	local flag = 0
	local max_chatpter = ShengXiaoData.Instance:GetMaxChapter()
	if max_chatpter > 1 then
		max_chatpter = max_chatpter - 1
	end
	if max_chatpter == 5 and ShengXiaoData.Instance:GetIsFinishAll() == 1 then
		max_chatpter = 5
	end
	for i = 1, max_chatpter do
		if self:GetSpiritRemindByStarIndex(i) then
			flag =  1
		end
	end
	return flag
end

-- 天相红点
function ShengXiaoData:CalcStarSoulRedPoint()
	if not OpenFunData.Instance:CheckIsHide("shengxiao_starsoul") then
		return 0
	end
	for i = 1,12 do
		if self:GetStarSoulRemindByStarIndex(i) then
			return 1
		end
	end
	return 0
end


-- 摇奖机
function ShengXiaoData:CalcErnieRedPoint()
	if not OpenFunData.Instance:CheckIsHide("shengxiao_piece") then
		return 0
	end
	local flag = 0
	if self:IsErnieCanFree() then
		flag = 1
	end
	return flag
end

function ShengXiaoData:GetNextFreeErnieTime()
	local cd = self:GetFreeCD()
	return self.last_free_ggl_time + cd
end

-- 得到摇奖机剩下的免费次数
function ShengXiaoData:GetRestFreeCount()
	local count = 0
	local other_cfg = self:GetOtherCfg()
	count = math.max(0, other_cfg.ggl_free_times - self.today_free_ggl_times)
	return count
end

-- 得到摇奖机免费次数CD
function ShengXiaoData:GetFreeCD()
	local cd = 0
	local other_cfg = self:GetOtherCfg()
	cd = other_cfg.ggl_free_times_cd or 0
	return cd
end

-- 摇奖机是否可以免费
function ShengXiaoData:IsErnieCanFree()
	local rest_free_count = self:GetRestFreeCount()
	if rest_free_count > 0 then
		local rest_time = self:GetNextFreeErnieTime() - TimeCtrl.Instance:GetServerTime()
		if rest_time <= 0 then
			return true
		end
	end
	return false
end

function ShengXiaoData:SetChapterTotalCap(cap)
	self.chapter_total_cap = cap
end

function ShengXiaoData:GetChapterTotalCap()
	return self.chapter_total_cap
end

function ShengXiaoData:GetBeadCfg(bead_type)
	for k,v in pairs(self.bead_cfg) do
		if bead_type == v.type then
			return v
		end
	 end
	 return nil
end

function ShengXiaoData:GetBeadInBagList()
	local bag_list = {}
	for k,v in pairs(self.bead_cfg) do
		local data = {}
		local item_num = ItemData.Instance:GetItemNumInBagById(v.item_id)
		data.item_id = v.item_id
		data.num = item_num
		data.is_from_shengxiao = true
		bag_list[v.type] = data
	end
	 return bag_list
end

function ShengXiaoData:GetPointEffectCfg(index)
	local point_effect_list = {}
	local cfg = {}
	for k,v in pairs(self.point_effect_cfg) do
		if v.seq + 1 == index then
			cfg = v
		end
	end
	for i=1,16 do
		if cfg["point" .. i .. "_x"] and cfg["point" .. i .. "_y"]
			and cfg["point" .. i .. "_y"] ~= "" and cfg["point" .. i .. "_x"] ~= "" then
			point_effect_list[i] = {}
			point_effect_list[i].x = cfg["point" .. i .. "_x"]
			point_effect_list[i].y = cfg["point" .. i .. "_y"]
		end
	end
	return point_effect_list
end

function ShengXiaoData:SetXinglingInfo(all_info)
	self.spirit_list = all_info
end

function ShengXiaoData:GetXingLingInfo(index)
	return self.spirit_list.xingling_list and self.spirit_list.xingling_list[index] or 0
end

function ShengXiaoData:GetXingLingAllInfo()
	return self.spirit_list
end

function ShengXiaoData:SaveEquipIsAutoBuy(is_auto_buy)
	self.equip_is_auto_buy = is_auto_buy
end

function ShengXiaoData:GetEquipIsAutoBuy()
	return self.equip_is_auto_buy
end

function ShengXiaoData:GetXingLingCfg(id, level)
	if not level or level > 39 then return {} end
	local cur_level = level >= 0 and level or 0
	local cfg = {}
	for k,v in pairs(self.xingling_cfg) do
		if v.id == id and v.level == cur_level then
			cfg = v
		end
	end
	return cfg
end

function ShengXiaoData:GetShowItems(id, level)
	local other_cfg = self:GetXingLingCfg(id, level)
	local data = {}
	data.item_id = other_cfg.uplevel_stuff_id
	return data
end

function ShengXiaoData:GetXinglingPointEffectCfg(index)
	local point_effect_list = {}
	local cfg = {}
	for k,v in pairs(self.xingling_point_effect_cfg) do
		if v.seq + 1 == index then
			cfg = v
		end
	end
	for i=1,16 do
		if cfg["point" .. i .. "_x"] and cfg["point" .. i .. "_y"]
			and cfg["point" .. i .. "_y"] ~= "" and cfg["point" .. i .. "_x"] ~= "" then
			point_effect_list[i] = {}
			point_effect_list[i].x = cfg["point" .. i .. "_x"]
			point_effect_list[i].y = cfg["point" .. i .. "_y"]
		end
	end
	return point_effect_list
end

--------------------------------星魂--------------------

function ShengXiaoData:GetStarSoulPointCfg(index)
	local point_effect_list = {}
	local cfg = {}
	for k,v in pairs(self.starsoul_point_effect_cfg) do
		if v.seq + 1 == index then
			cfg = v
		end
	end
	for i = 1, 10 do
		if cfg["point" .. i .. "_x"] and cfg["point" .. i .. "_y"]
			and cfg["point" .. i .. "_y"] ~= "" and cfg["point" .. i .. "_x"] ~= "" then
			point_effect_list[i] = {}
			point_effect_list[i].x = cfg["point" .. i .. "_x"]
			point_effect_list[i].y = cfg["point" .. i .. "_y"]
		end
	end
	return point_effect_list
end

function ShengXiaoData:SetShengXiaoOldLevelList()
	for i,v in ipairs(self.xinghun_level_list) do
		self.xinghun_old_level_list[i] = v
	end
end

function ShengXiaoData:GetShengXiaoOldLevelByIndex(index)
	return self.xinghun_old_level_list[index] or 0
end

function ShengXiaoData:GetStarSoulLevelList()
	return self.xinghun_level_list
end

function ShengXiaoData:GetStarSoulLevelByIndex(index)
	return self.xinghun_level_list[index] or 0
end

function ShengXiaoData:GetStarSoulMaxLevelList()
	return self.xinghun_level_max_list
end

function ShengXiaoData:GetStarSoulMaxLevelByIndex(index)
	return self.xinghun_level_max_list[index] or 0
end


function ShengXiaoData:GetStarSoulBaojiList()
	return self.xinghun_baoji_value_list
end

function ShengXiaoData:GetStarSoulBaojiByIndex(index)
	return self.xinghun_baoji_value_list[index] or 0
end

-- 得到星魂开锁进程
function ShengXiaoData:GetStarSoulProgress()
	return self.xinghun_progress or 0
end

function ShengXiaoData:GetStarSoulInfoByIndexAndLevel(index, level)
	local cfg = self.xinghun_cfg[index - 1]
	return cfg and cfg[level] or nil
end

function ShengXiaoData:GetNextStarSoulInfoByIndexAndLevel(index, level, attr_type)
	local cur_cfg = self:GetStarSoulInfoByIndexAndLevel(index, level)
	local cfg = self.xinghun_cfg[index - 1]
	for i,v in ipairs(cfg) do
		if v[attr_type] > cur_cfg[attr_type] then
			return v
			-- return v[attr_type] - cur_cfg[attr_type]
		end
	end
	return {}
end

function ShengXiaoData:GetStarSoulMaxLevel(index)
	local cfg = self.xinghun_cfg[index - 1]
	return cfg and #cfg or 0
end

function ShengXiaoData:GetStarSoulCanUp(index)
	-- local level = self:GetStarSoulLevelByIndex(index)
	local befor_level = self:GetStarSoulMaxLevelByIndex(index - 1)
	local cfg = self:GetStarSoulInfoByIndexAndLevel(index, 0)
	if cfg.backwards_highest_level > befor_level then
		return false
	end
	return true
end

function ShengXiaoData:GetStarSoulTotal()
	local total_level = 0
	for k,v in pairs(self.xinghun_level_list) do
		total_level = total_level + v
	end
	local cur_cfg, next_cfg = nil, nil
	if total_level < self.xinghun_extra_cfg[1].level then
		next_cfg = self.xinghun_extra_cfg[1]
	elseif total_level >= self.xinghun_extra_cfg[#self.xinghun_extra_cfg].level then
		cur_cfg = self.xinghun_extra_cfg[#self.xinghun_extra_cfg]
	else
		for k,v in pairs(self.xinghun_extra_cfg) do
			if v.level > total_level then
				cur_cfg = self.xinghun_extra_cfg[k - 1]
				next_cfg = v
				break
			end
		end
	end
	return cur_cfg, next_cfg, total_level
end

-- 当天箱子是否已全部采集完成
function ShengXiaoData:IsGatherComplete()
	return self:GetRemanentGatherCount() <= 0
end

-- 一键采集所有普通宝箱所需元宝
function ShengXiaoData:GetAllGatherNeedGold()
	local skip_cfg = RelicData.Instance:GetRelicCfg().skip_cfg[1]
	local remanent_gather_count = self:GetRemanentGatherCount()
	if skip_cfg then
		return skip_cfg.consume * remanent_gather_count
	end
	return 0
end

-- 当天可采集普通箱子最大数目
function ShengXiaoData:GetMaxGatherCount()
    local other_cfg = RelicData.Instance:GetRelicCfg().other[1]
    if other_cfg then
    	return other_cfg.common_box_gather_limit or 0
    end
    return 0
end

-- 当天剩余可采集箱子数目
function ShengXiaoData:GetRemanentGatherCount()
    local cur_gather_count = RelicData.Instance:GetNowGatherNormalBoxNum()
    local max_gather_count = self:GetMaxGatherCount()
    local remanent_gather_count = max_gather_count - cur_gather_count
    if remanent_gather_count < 0 then
    	remanent_gather_count = 0
    end
    return remanent_gather_count
end