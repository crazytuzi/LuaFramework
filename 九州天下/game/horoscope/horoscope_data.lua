HoroscopeData = HoroscopeData or BaseClass()

function HoroscopeData:__init()
	if HoroscopeData.Instance ~= nil then
		print_error("[MagicCardData] Attemp to create a singleton twice !")
	end
	HoroscopeData.Instance = self

	-- 服务器数据
	self.zodiac_level_list = {}
	self.xinghun_level_list = {}
	self.chinesezodiac_equip_list = {}
	self.zodiac_type = 0
	self.equip_type = 0
	self.equip_level = 0

	-- 配置表数据
	self.other = ConfigManager.Instance:GetAutoConfig("chinese_zodiac_cfg_auto").other
	self.single_info = ListToMap( ConfigManager.Instance:GetAutoConfig("chinese_zodiac_cfg_auto").single_info, "seq")
	self.suit_info = ConfigManager.Instance:GetAutoConfig("chinese_zodiac_cfg_auto").suit_info
	self.equip = ConfigManager.Instance:GetAutoConfig("chinese_zodiac_cfg_auto").equip
	self.xinghun = ConfigManager.Instance:GetAutoConfig("chinese_zodiac_cfg_auto").xinghun
	self.xinghun_extra_info = ConfigManager.Instance:GetAutoConfig("chinese_zodiac_cfg_auto").xinghun_extra_info


	self.equip_cfg = ListToMap(self.equip, "equip_type")
	self.xinghun_extra_info_cfg = ListToMap(self.xinghun_extra_info, "level")
	self.xinhun_seq_level_cfg = ListToMapList(self.xinghun, "seq", "level")
	self.suit_level_cfg = ListToMap(self.suit_info, "level")
end

function HoroscopeData:__delete()
	HoroscopeData.Instance = nil
end

function HoroscopeData:SetChineseZodiacAllInfo(data)
	self.zodiac_level_list = data.zodiac_level_list
	self.xinghun_level_list = data.xinghun_level_list
	self.xinghun_level_max_list = data.xinghun_level_max_list
	self.chinesezodiac_equip_list = data.chinesezodiac_equip_list
	self:FlushAttrRedPoint()
	self:FlushEquipRedPoint()
	self:FlushStarMapRedPoint()
end

function HoroscopeData:SetChineseZodiacEquipInfo(data)
	self.zodiac_type = data.zodiac_type
	self.equip_type = data.equip_type
	self.equip_level = data.equip_level

	self.chinesezodiac_equip_list[self.zodiac_type + 1][self.equip_type + 1] = self.equip_level
	self:FlushEquipRedPoint()
end

function HoroscopeData:GetStarLevelIsEqul(level_list)
	for i=1,#self.zodiac_level_list do
		local temp = self.zodiac_level_list[i]
		if temp ~= level_list[i] then
			return true
		end
	end

	return false
end

-- 星座属性红点
function HoroscopeData:FlushAttrRedPoint()
	MoLongData.Instance:SetHoroscopeAttrRedpt(false)
	for i = 1, 12 do
		local level = self:GetXzLevelBySeq(i - 1)
		local data = self:GetSingDataById(i - 1, level)
		local have_num = ItemData.Instance:GetItemNumInBagById(data.item_id)
		if have_num > 0 and level < 30 then
			MoLongData.Instance:SetHoroscopeAttrRedpt(true)
			return
		end
	end
end

-- 装备红点
function HoroscopeData:FlushEquipRedPoint()
	MoLongData.Instance:SetHoroscopeEquipRedpt(false)
	for j = 1, 12 do
		for i = 1, 8 do
			local zodiac_level = self:GetXzLevelBySeq(j - 1)
			local level = self:GetEquipLevelBySeqAndType(j - 1, i - 1)
			local equip_data = self:GetEquipDataByIndex(i - 1, level)
			local have_num = ItemData.Instance:GetItemNumInBagById(equip_data.consume_stuff_id)
			if have_num >= 1 and zodiac_level > 0 and level < 50 then
				MoLongData.Instance:SetHoroscopeEquipRedpt(true)
				return
			end
		end
	end
end

-- 星图红点
function HoroscopeData:FlushStarMapRedPoint()
	MoLongData.Instance:SetHoroscopeStarMapRedpt(false)
	for i = 1, 12 do
		local cur_level = self:GetXhLevelBySeq(i - 1)
		local need_data = self:GetDataBySeqAndLevel(i - 1,cur_level)
		local have_num = ItemData.Instance:GetItemNumInBagById(need_data.consume_stuff_id)
		local need_num = need_data.consume_stuff_num
		if have_num >= need_num and cur_level < 12 then
			MoLongData.Instance:SetHoroscopeStarMapRedpt(true)
			return
		end
	end
end

-- 配置表数据
-- 获取星座等级套装属性
function HoroscopeData:GetXzSuitData()
	local data = {}
	local level = self:GetXzSuitLevel()

	if level < 1 then
		level = 1
	elseif level < 5 then
		level = 5
	elseif level < 10 then
		level = 10
	elseif level < 15 then
		level = 15
	else
		level = 30
	end
	
	return self:GetXzSuitAttrByLevel(level)
end

function HoroscopeData:GetXzSuitAttrByLevel(level)
	return self.suit_level_cfg[level] or {}
end

-- 获取所有星座总属性
function HoroscopeData:GetXzAllAttr()
	local data = {
		maxhp = 0,
		gongji = 0,
		fangyu = 0,
		mingzhong = 0,
		shanbi = 0,
		baoji = 0,
		jianren = 0
	}
	for i = 0, 11 do
		local level = self:GetXzLevelBySeq(i)
		local Xz_Data = self:GetSingDataById(i, level)
		data.maxhp = data.maxhp + Xz_Data.maxhp
		data.gongji = data.gongji + Xz_Data.gongji
		data.fangyu = data.fangyu + Xz_Data.fangyu
		data.mingzhong = data.mingzhong + Xz_Data.mingzhong
		data.shanbi = data.shanbi + Xz_Data.shanbi
		data.baoji = data.baoji + Xz_Data.baoji
		data.jianren = data.jianren + Xz_Data.jianren
	end

	return data
end

-- 获取所有星座装备总属性
function HoroscopeData:GetXzAllEquipAttr()
	local data = {
		maxhp = 0,
		gongji = 0,
		fangyu = 0,
		mingzhong = 0,
		shanbi = 0,
		baoji = 0,
		jianren = 0
	}

	for j = 1, 12 do
		for i = 1, 8 do
			local equip_level = self:GetEquipLevelBySeqAndType(j - 1, i - 1)
			if equip_level > 0 then
				local equip_data = self:GetEquipDataByIndex(i - 1, equip_level)
				data.maxhp = data.maxhp + equip_data.maxhp
				data.gongji = data.gongji + equip_data.gongji
				data.fangyu = data.fangyu + equip_data.fangyu
				data.mingzhong = data.mingzhong + equip_data.mingzhong
				data.shanbi = data.shanbi + equip_data.shanbi
				data.baoji = data.baoji + equip_data.baoji
				data.jianren = data.jianren + equip_data.jianren
			end
		end
	end

	return data
end

-- 获取当前星座套装的等级
function HoroscopeData:GetXzSuitLevel(is_real)
	local level = self.zodiac_level_list[1]
	for i=1,#self.zodiac_level_list do
		local temp = self.zodiac_level_list[i]
		if level > temp then
			level = temp
		end
	end

	if is_real then
		if level < 1 then
			level = -1
		elseif level < 5 then
			level = 1
		elseif level < 10 then
			level = 5
		elseif level < 15 then
			level = 10
		elseif level < 30 then
			level = 15
		elseif level == 30 then
			level = 30
		else
			level = -1
		end
	end

	return level
end

--通过当前套装等级获取下一等级
function HoroscopeData:GetNextLevelByCurlevel(cur_level)
	local next_level = 1
	if cur_level == 0 then
		next_level = 1
	elseif cur_level == 1 then
		next_level = 5
	elseif cur_level == 5 then
		next_level = 10
	elseif cur_level == 10 then
		next_level = 15
	elseif cur_level == 15 then
		next_level = 30
	elseif cur_level == 30 then
		next_level = -1
	end

	return next_level
end

-- 获取保护符item_id
function HoroscopeData:GetProtectItemId()
	return self.other[1].xinghun_protect_item_id or 0
end

-- 根据id获得单个星座的信息
function HoroscopeData:GetSingDataById(seq, level, is_add)
	local temp_level = level or 0
	local data = {}
	local cfg_data = self.single_info[seq]
	if cfg_data then
		if is_add then
			return cfg_data
		else
			data.seq = cfg_data.seq
			data.maxhp = cfg_data.maxhp * temp_level
			data.gongji = cfg_data.gongji * temp_level
			data.fangyu = cfg_data.fangyu * temp_level
			data.mingzhong = cfg_data.mingzhong * temp_level
			data.shanbi = cfg_data.shanbi * temp_level
			data.baoji = cfg_data.baoji * temp_level
			data.jianren = cfg_data.jianren * temp_level
			data.item_id = cfg_data.item_id
			data.name = cfg_data.name	
		end		
	end

	return data
end


-- 根据index获得装备信息 index从0开始
function HoroscopeData:GetEquipDataByIndex(index, level, is_add)
	local temp_level = level or 0
	local data = {}
	local data_cfg = self.equip_cfg[index]
	if is_add then
		return data_cfg
	else
		data.equip_type = data_cfg.equip_type
        data.consume_stuff_id = data_cfg.consume_stuff_id
        data.consume_stuff_num = data_cfg.consume_stuff_num
        data.color = data_cfg.color
        data.name = data_cfg.name
        data.maxhp = data_cfg.maxhp * temp_level
        data.gongji = data_cfg.gongji * temp_level
        data.fangyu = data_cfg.fangyu * temp_level
        data.mingzhong = data_cfg.mingzhong * temp_level
        data.shanbi = data_cfg.shanbi * temp_level
        data.baoji = data_cfg.baoji * temp_level
        data.jianren = data_cfg.jianren * temp_level
	end
	return data
end

-- 根据星座seq和星魂等级获得星魂信息 从0开始
function HoroscopeData:GetDataBySeqAndLevel(seq, level)
	return self.xinhun_seq_level_cfg[seq][level][1]

	-- local data = {}
	-- for k,v in pairs(self.xinghun) do
	-- 	if v.seq == seq and v.level == level then
	-- 		table.insert(data,v)
	-- 	end
	-- end

	-- return data[1]
end

-- 服务器数据
-- 通过星座seq获取对应星座等级
function HoroscopeData:GetXzLevelBySeq(seq)
	local level = 0
	if self.single_info[seq] then
		level = self.zodiac_level_list[seq + 1]
	end
	return level
end

-- 根据星座seq和装备类型equip_type获取装备等级
function HoroscopeData:GetEquipLevelBySeqAndType(seq,equip_type)
	local level = 0
	level = self.chinesezodiac_equip_list[seq + 1][equip_type + 1]
	return level
end

-- 通过星座seq获取对应星魂等级
function HoroscopeData:GetXhLevelBySeq(seq)
	local level = 0
	if self.single_info[seq] then 
		level = self.xinghun_level_list[seq + 1]
	end
	return level
end

-- 获取总属性
function HoroscopeData:GetAllAttr()
	local attr_list = {}
	attr_list = CommonStruct.Attribute()

	for i = 0, 11 do
		local attr = self:GetDataBySeqAndLevel(i, self:GetXhLevelBySeq(i))
		attr_list.max_hp = attr_list.max_hp + attr.maxhp
		attr_list.gong_ji = attr_list.gong_ji + attr.gongji
		attr_list.fang_yu = attr_list.fang_yu + attr.fangyu
		attr_list.ming_zhong = attr_list.ming_zhong + attr.mingzhong
		attr_list.shan_bi = attr_list.shan_bi + attr.shanbi
	end

	return attr_list
end

-- 根据套装等级获取套装属性
function HoroscopeData:GetSuitAttrByLevel(level)
	local data = {}
	local cfg = self.xinghun_extra_info_cfg[level]
	if cfg then
		data.level = cfg.level
		data.max_hp = cfg.maxhp
		data.gong_ji = cfg.gongji
		data.fang_yu = cfg.fangyu
		data.ming_zhong = cfg.mingzhong
		data.shan_bi = cfg.shanbi
		data.bao_ji = cfg.baoji
		data.jian_ren = cfg.jianren
	end
	return data
end

-- 获取当前套装等级
function HoroscopeData:GetSuitLevel(is_real)
	local level = self.xinghun_level_list[1]
	for i = 1, #self.xinghun_level_list do
		local temp = self.xinghun_level_list[i]
		if level > temp then
			level = self.xinghun_level_list[i]
		end
	end

	if is_real and level < 3 then
		level = 0
	elseif level < 6 then
		 level = 3
	elseif level < 9 then
		level = 6
	elseif level < 12 then
		 level = 9
	elseif level == 12 then
		level = 12
	else
		level = -1
	end

	return level
end

-- 获取星座装备套装下一级
function HoroscopeData:GetEquipSuitNextLevel(cur_level)
	local level = -1
	local tab = {
		[0] = 3,
		[3] = 6,
		[6] = 9,
		[12] = -1
	}
	return tab[cur_level] and tab[cur_level] or level
end

-- 通过id获取星魂历史最高等级
function HoroscopeData:GetMaxLevelById(id)
	return self.xinghun_level_max_list[id]
end
