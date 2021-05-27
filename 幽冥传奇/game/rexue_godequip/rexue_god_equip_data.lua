ReXueGodEquipData = ReXueGodEquipData or BaseClass(BaseData)

COMPOSE_DEF = {
	[1] = 10

}

ReXueGodEquipData.SHENZHU_RESULT = "SHENZHU_RESULT" -- 神铸升级结果
ReXueGodEquipData.SHENGE_RESULT = "SHENGE_RESULT" -- 神格升级结果

function ReXueGodEquipData:__init( ... )
	if ReXueGodEquipData.Instance then
		ErrorLog("[ReXueGodEquipData] Attemp to create a singleton twice !")
	end
	ReXueGodEquipData.Instance = self
	self.exchange_data = {}

	self.weapon_equip_list = {}
	self.compose_data = {}

	self:InitReXueShenzhu()
end


function ReXueGodEquipData:__delete( ... )
	-- body
end


--兑换
function ReXueGodEquipData:InitData( ... )
	self.exchange_data = {}

	--local index = 0
	local viplv = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_VIP_GRADE)
	local openday = OtherData.Instance:GetOpenServerDays()
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local combineDay = OtherData.Instance:GetCombindDays()
	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	for i, v in ipairs(ExchangeGodEquipCfg.exchange) do
		if v.combinday == 0 then
			if level >= v.level and circle >= v.circle and viplv >= v.viplv and openday >= v.openday then
				if v.sex == nil or v.sex == sex then
					table.insert(self.exchange_data, v)
				end
			end
		else
			if combineDay >= 1 then
				table.insert(self.exchange_data, v)
			end
		end
	end
end


function ReXueGodEquipData:GetExchangeData()
	return self.exchange_data
end


function ReXueGodEquipData:GetIsRemindData()
	for k, v in pairs(self.exchange_data) do
		if self:GetIsCanDuiHuan(v) then
			return 1
		end
	end
	return 0
end

function ReXueGodEquipData:GetIsCanDuiHuan(data)
	local consume = data.comsumes[1]
	local consume_count = consume.count
	local had_count = BagData.Instance:GetItemNumInBagById(consume.id, nil) 
	if had_count >= consume_count then
		return true
	end
	return false
end

--热血神装--神甲
function ReXueGodEquipData:GetReXueList()
	-- local openday = OtherData.Instance:GetOpenServerDays()
	-- local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	-- local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	-- local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	-- local config = ItemSynthesisConfig[pos] and ItemSynthesisConfig[pos].list[1]
	-- local data = {}
	-- if openday >= config.openlimit.serverday and level >= config.openlimit.level and  circle >= config.openlimit.circle then
	-- 	for k, v in pairs(config.itemList) do
	-- 		if v.sex == sex or v.sex == nil then

	-- 			if level >= (v.openlimit.level or 0) and  
	-- 			circle >= (v.openlimit.circle or 0) and 
	-- 			openday >= (v.openlimit.serverday or 0) and( level >= (v.openlimit.minlevel or 0) and level <= (v.openlimit.maxlevel or 9999)) then
	-- 				local cur_data = {
	-- 					award = v.award,
	-- 					consume = v.consume,
	-- 					isClient = v.openlimit.isClient,
	-- 					is_need_shouchong = v.openlimit.is_need_shouchong,
	-- 					child_index = 1,
	-- 					index = k,
	-- 					remin_data = v,
	-- 				}
	-- 				table.insert(data, cur_data)
	-- 			end
	-- 		end	
	-- 	end
	-- end
	-- return data
end

--霸者装备
function ReXueGodEquipData:SetRewardComspoe( ... )
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local open_day = OtherData.Instance:GetOpenServerDays()
	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	local r_index = 1
	self.compose_data = {}
	self.compose_data[1] = {}
	self.compose_data[2] = {}
	self.compose_data[3] = {}
	self.compose_data[4] = {}

	local cfg1 = ItemSynthesisConfig[10]
	--for k,v in pairs(cfg1) do
	for k, v in ipairs(cfg1.list) do
		local cur_data = {name = v.name,name_path = v.name_path, type = r_index, index = 10, child_index = k, child = {}}
		cur_data.child = self:InitChildList(v.itemList,  10, k, circle, level, open_day, sex)
		table.insert(self.compose_data[1], cur_data)
		r_index = r_index + 1
	end
	--end

	-- for k, v in pairs(ItemSynthesisConfig[12]) do
		local cfg = ItemSynthesisConfig[12]
		local r_index1 = 1
		if circle >= cfg.openlimit.circle  and level >= cfg.openlimit.level and open_day >= cfg.openlimit.serverday then
			for k, v in ipairs(cfg.list) do
				local cur_data = {name = v.name, name_path = v.name_path, type = r_index1, index = 12, child_index = k, child = {}}
				cur_data.child = self:InitChildList(v.itemList, 12, k, circle, level, open_day, sex)
				table.insert(self.compose_data[2], cur_data)
				r_index1 = r_index1 + 1
			end
			
		end
		-- PrintTable(self.compose_data[2])
	--end
	--战宠合成
	local cfg3 = ItemSynthesisConfig[16]
	local r_index2 = 1
	if circle >= cfg3.openlimit.circle  and level >= cfg3.openlimit.level and open_day >= cfg3.openlimit.serverday then
		for k, v in ipairs(cfg3.list) do
			local cur_data = {name = v.name, name_path = v.name_path, type = r_index2, index =16, child_index = k, child = {}}
			cur_data.child = self:InitChildList(v.itemList, 16, k, circle, level, open_day, sex)
			table.insert(self.compose_data[3], cur_data)
			r_index2 = r_index2 + 1
		end
		
	end

	--翅膀合成

	local cfg4 = ItemSynthesisConfig[15]
	local r_index3 = 1
	if circle >= cfg4.openlimit.circle  and level >= cfg4.openlimit.level and open_day >= cfg4.openlimit.serverday then
		for k, v in ipairs(cfg4.list) do
			local cur_data = {name = v.name, name_path = v.name_path, type = r_index3, index =15, child_index = k, child = {}}
			cur_data.child = self:InitChildList(v.itemList, 16, k, circle, level, open_day, sex)
			table.insert(self.compose_data[4], cur_data)
			r_index3 = r_index3 + 1
		end
	end
end

function ReXueGodEquipData:InitChildList(list, tree_index, child_type, circle, level, open_day, sex)
	
	local data = {}
	for i, v in ipairs(list) do
		--if v.child_index == child_type then

			if level >= (v.openlimit.level or 0) and  
				circle >= (v.openlimit.circle or 0) and 
				open_day >= (v.openlimit.serverday or 0) and( level >= (v.openlimit.minlevel or 0) and level <= (v.openlimit.maxlevel or 9999))
				and (sex == v.openlimit.sex or v.openlimit.sex == -1 or v.openlimit.sex == nil) then
				local item_cfg = ItemData.Instance:GetItemConfig(v.award[1].id)
				local name = item_cfg.name
				local color = Str2C3b(string.format("%06x", item_cfg.color))
				local cur_data = {name = name, type = i, tree_index = tree_index, remin_data = v , child_index = child_type, index = i, color = color, award = v.award, consume = v.consume, isClient = v.openlimit.isClient, is_need_shouchong = v.openlimit.is_need_shouchong}
				table.insert(data,cur_data)
			end
		--end
	end
	return data
end


function ReXueGodEquipData:GetComspoeData(index)
	return self.compose_data[index]
end


function ReXueGodEquipData:GetReXueUpPoint()
	for k, v in pairs(COMPOSE_DEF) do
		if self:SingleCanPoint(v) then
			return 1
		end
	end
	return 0
end



function ReXueGodEquipData:SingleCanPoint(index)
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local open_day = OtherData.Instance:GetOpenServerDays()
	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	local cfg = ItemSynthesisConfig[index]
	if circle >= cfg.openlimit.circle  and level >= cfg.openlimit.level and open_day >= cfg.openlimit.serverday then
		for k,v in pairs(cfg.list or{}) do
			if self:SetTreepoint(index, k, sex) then
				return true
			end
		end
		
		
	end
	--end
	return false
end

function ReXueGodEquipData:SetTreepoint(tree_index, child_index, sex)
	
	--print(">>>>>>>>>>>>>", tree_index,ItemSynthesisConfig[tree_index])
	local config = ItemSynthesisConfig[tree_index] and ItemSynthesisConfig[tree_index].list[child_index] or {}
	for k, v in pairs(config.itemList or {}) do
		if v.sex == sex or v.sex == nil then
			local child_point =self:SetSecondPoint(v)

			if child_point then
				return true
			end
		end
	end
	return false
end


---战神配置==----

function ReXueGodEquipData:GetConfiByTypeEquipPos(type, equip_pos, item_id)
	local config_data = EquipTakeOnSynthesisCfg[type] or {}
	local config = config_data.list and config_data.list[equip_pos] or {}
	local cur_config = nil
	if item_id == nil then
		virtula_item_id = ReXueGodEquipShow[equip_pos]
		cur_config = config[virtula_item_id]
	else
		cur_config = config[item_id]
	end
	return cur_config
end
ReXueGodEquipData_Pos = {
		{equip_slot = EquipData.EquipSlot.itGodWarHelmetPos, cell_pos = 1, cell_img = ResPath.GetEquipImg("cs_bg_3")},	-- 战神_头盔	45
		{equip_slot = EquipData.EquipSlot.itGodWarNecklacePos, cell_pos = 2,cell_img = ResPath.GetEquipImg("cs_bg_4")},	-- 战神_项链
		{equip_slot = EquipData.EquipSlot.itGodWarLeftBraceletPos, cell_pos = 3, cell_img = ResPath.GetEquipImg("cs_bg_5")},	-- 衣战神_左手镯
		{equip_slot = EquipData.EquipSlot.itGodWarRightBraceletPos, cell_pos = 4, cell_img = ResPath.GetEquipImg("cs_bg_5")},	-- 战神_右手镯
		{equip_slot = EquipData.EquipSlot.itGodWarLeftRingPos, cell_pos = 5, cell_img = ResPath.GetEquipImg("cs_bg_6")},	-- 战神_左戒指
		{equip_slot = EquipData.EquipSlot.itGodWarRightRingPos, cell_pos = 6, cell_img = ResPath.GetEquipImg("cs_bg_6")},	-- 战神_右戒指
		{equip_slot = EquipData.EquipSlot.itGodWarGirdlePos, cell_pos =7,cell_img = ResPath.GetEquipImg("cs_bg_7")},	-- 战神_腰带
		{equip_slot = EquipData.EquipSlot.itGodWarShoesPos,  cell_pos =8,cell_img = ResPath.GetEquipImg("cs_bg_8")},	-- 战神_鞋子 52
}
--身上装备可合成
function ReXueGodEquipData:GetZhanShenCanCompose()
	for k, v in pairs(ReXueGodEquipData_Pos) do
		local equip = EquipData.Instance:GetEquipDataBySolt(v.equip_slot)
		local data = self:SetReXueCanBestData(v.equip_slot)  --战神装备可替换
		if data ~= nil then
			return 1
		end
		if equip then
			if self:GetCanCompose(equip, 2, v.equip_slot) then
				return 1
			end
		end
	end
	return 0
end

function ReXueGodEquipData:GetCanCompose(equip, type, equip_pos)
	local config  = self:GetConfiByTypeEquipPos(type,equip_pos, equip.item_id)
	if config ~= nil then
		if self:SetSecondPoint(config) then
			return true
		end
	end
	return false
end



function ReXueGodEquipData:SetSecondPoint(data, is_other)

	if data and data.openlimit and data.openlimit.isClient then
		return false
	end

	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local open_day = OtherData.Instance:GetOpenServerDays()
	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	if level >= (data.openlimit and data.openlimit.level or 0) and  
			circle >= (data.openlimit and data.openlimit.circle or 0) and 
			open_day >= (data.openlimit and data.openlimit.serverday or 0) and( level >= (data.openlimit and data.openlimit.minlevel or 0) and level <= (data.openlimit and data.openlimit.maxlevel or 9999)) 
			and (data.openlimit and data.openlimit.sex == sex or (data.openlimit and data.openlimit.sex or -1) == -1) then

		local num = 0
		for k, v in pairs(data.consume or {}) do
			if v.type > 0 then
				if RoleData.Instance:GetMainMoneyByType(v.type) >= v.count then
					num = num + 1
				end
			else
				local count = v.count
				if #data.consume >=2 then
					if data.consume[1].id == (data.consume[2] and data.consume[2].id or -1)  then -- ID
						count = data.consume[1].count + data.consume[2].count
					end
				end
				if BagData.Instance:GetItemNumInBagById(v.id, nil) >= count then
					num = num + 1
				end
			end
		end
		if num >= #data.consume  then
			return true
		end
	end

	return false
end


ReXueGodEquipData_ShaShenEquipPos =   {
		{equip_slot = EquipData.EquipSlot.itKillArrayShaPos, cell_pos = 1, cell_img = ResPath.GetEquipImg("cs_bg_3")},	-- 战神_头盔	45
		{equip_slot = EquipData.EquipSlot.itKillArrayMostPos, cell_pos = 2,cell_img = ResPath.GetEquipImg("cs_bg_4")},	-- 战神_项链
		{equip_slot = EquipData.EquipSlot.itKillArrayRobberyPos, cell_pos = 3, cell_img = ResPath.GetEquipImg("cs_bg_5")},	-- 衣战神_左手镯
		{equip_slot = EquipData.EquipSlot.itKillArrayLifePos, cell_pos = 4, cell_img = ResPath.GetEquipImg("cs_bg_5")},	-- 战神_右手镯
		
	}
--杀神装备可合成
function ReXueGodEquipData:GetShaShenCanCompose()
	for k,v in pairs(ReXueGodEquipData_ShaShenEquipPos) do
		local equip = EquipData.Instance:GetEquipDataBySolt(v.equip_slot)
		local data = self:SetReXueCanBestData(v.equip_slot)  --杀神装备可替换
		if data ~= nil then
			return 1
		end
		if equip then
			if self:GetCanCompose(equip, 1, v.equip_slot) then
				return 1
			end
		end
	end
	return 0
end

function ReXueGodEquipData:SetReXueCanBestData(equip_pos)
	local equip = EquipData.Instance:GetEquipDataBySolt(equip_pos)
	local data = BagData.Instance:GetReXueData()
	local type =  EquipData.Instance:GetTypeByEquipSlot(equip_pos)
	local best_data = nil
	local max_score = ItemData.Instance:GetItemScoreByData(equip)
	for k, v in pairs(data) do
		local itemConfig = ItemData.Instance:GetItemConfig(v.item_id)
		if itemConfig.type == type then
			local cur_score = ItemData.Instance:GetItemScoreByData(v)
			if  EquipData.CanEquip(v) then  --如果是可穿戴的
				if cur_score > max_score then
					max_score = cur_score 
					best_data  = v
				end
			end
		end
	end
	
	return best_data
end


--热血神装套装属性显示
function ReXueGodEquipData:GetTextByTypeData(suitlevel, suitType, level_data,is_not_show, not_show_special, not_show_skill)
	local config = SuitPlusConfig[suitType]
	not_show_special = not_show_special or false
	not_show_skill = not_show_skill or false

	local cur_suit_level_data = level_data[suitlevel] or level_data[1]
	

	--local name_cfg = Language.ReXueGodEquip.SuitLevelName[suitType]

	local attr_config = config.list[suitlevel] or config.list[1]

	local text1 = ""
	if suitlevel <= 0 then
		text1 = string.format(Language.Role.ChuanshiShowTip1, "a6a6a6",attr_config.name, "ff0000", cur_suit_level_data.count, cur_suit_level_data.need_count, "a6a6a6", Language.HaoZhuang.active[1]).."\n"
	else
		local text6 = cur_suit_level_data.bool > 0 and Language.HaoZhuang.active[2] or Language.HaoZhuang.active[1]
		local color1 = cur_suit_level_data.bool > 0 and "00ff00" or "a6a6a6"
		local color2 = cur_suit_level_data.bool > 0 and "00ff00" or "ff0000"
		text1 = string.format(Language.Role.ChuanshiShowTip1, color1, attr_config.name, color2, cur_suit_level_data.count, cur_suit_level_data.need_count, color1, text6).."\n"
	end
	local type_data = RexueSuitEquipName[suitType]
	local text2 = "" 
	local text21 = ""
	local text22 = ""
	for k,v in pairs(type_data) do
		local item_type = EquipData.Instance:GetTypeByEquipSlot(v)
		local name = Language.EquipTypeName[item_type]
		local equip =  EquipData.Instance:GetEquipDataBySolt(v)
		local color = "a6a6a6"
		if equip then
			local itemm_config = ItemData.Instance:GetItemConfig(equip.item_id)
		
			if itemm_config.suitId ~= 0 and itemm_config.suitId >= suitlevel then
				color = "00ff00"
			end
		end
		if k <= 4 then
			text21 = text21 .. string.format(Language.HaoZhuang.active2, color, name) .. " "
		else
			text22 = text22 .. string.format(Language.HaoZhuang.active2, color, name) .. " "
		end
	end
	local text23 = text22 ~= "" and (text22 .."\n") or ""
	local text2 = text21 .. "\n"..text23
	
	local attr = attr_config.attrs
	local normat_attrs, special_attr =  RoleData.Instance:GetSpecailAttr(attr)

	local bool_color = cur_suit_level_data.bool > 0 and "ffffff" or "a6a6a6"
	local bool_color1 = cur_suit_level_data.bool > 0 and "ff0000" or "a6a6a6"
	local text7 = is_not_show and "" or string.format("{color;%s;%s}", "dcb73d", "基础属性：") .. "\n" 
	local text4 =  text7.. string.format("{color;%s;%s}", bool_color, RoleData.FormatAttrContent(normat_attrs)) .."\n"
	local text5 = ""
	local text6 = ""
	if 	not not_show_special then
		if (#special_attr > 0) then
			local special_content = RoleData.FormatRoleAttrStr(special_attr, nil, prof_ignore)
			text5 = string.format("{color;%s;%s}", "dcb73d", "特殊属性：") .. "\n" .. string.format("{color;%s;%s}", bool_color, RoleData.FormatAttrContent(special_attr)) .."\n"
		end
		if not not_show_skill then
			if attr_config.skillid ~= nil and attr_config.skillid > 0 then
				
				local index = string.format("s%dL%dDesc", attr_config.skillid,attr_config.skillLv)
				text6 = string.format("{color;%s;%s}", "dcb73d", "特殊技能：").."\n" .. Lang.Skill[index].."\n"
			end
		end
	end
	local text = text1..text2..text4..text5..text6
	return text
end



local rexue_equip_list = {
	EquipData.EquipSlot.itWarmBloodDivineswordPos,  	 --热血神剑 10
	EquipData.EquipSlot.itWarmBloodGodNailPos,			 --热血神甲 10
	EquipData.EquipSlot.itWarmBloodElbowPadsPos,		 --热血面甲 10
	EquipData.EquipSlot.itWarmBloodShoulderPadsPos,		 --热血护肩 10
	EquipData.EquipSlot.itWarmBloodPendantPos,			 --热血吊坠 10
	EquipData.EquipSlot.itWarmBloodKneecapPos,			 --热血护膝 10
	EquipData.EquipSlot.itKillArrayShaPos,				 --杀阵_天煞 10
	EquipData.EquipSlot.itKillArrayMostPos,				 --杀阵_天绝 10
	EquipData.EquipSlot.itKillArrayRobberyPos,			 --杀阵_天劫 10
	EquipData.EquipSlot.itKillArrayLifePos,				 --杀阵_天命 10
	EquipData.EquipSlot.itGodWarHelmetPos,				 --战神_头盔 10
	EquipData.EquipSlot.itGodWarNecklacePos,			 --战神_项链 10
	EquipData.EquipSlot.itGodWarLeftBraceletPos,		 --战神_左手镯 10
	EquipData.EquipSlot.itGodWarRightBraceletPos,		 --战神_右手镯 10
	EquipData.EquipSlot.itGodWarLeftRingPos,			 --战神_左戒指 10
	EquipData.EquipSlot.itGodWarRightRingPos,			 --战神_右戒指 10
	EquipData.EquipSlot.itGodWarGirdlePos,				 --战神_腰带 10
	EquipData.EquipSlot.itGodWarShoesPos,				 --战神_鞋子 10
}

function ReXueGodEquipData:GetIsCanWear()
	if not ViewManager.Instance:CanOpen(ViewDef.Role.RoleInfoList.NewReXueEquip) then
		return false
	end
	for k,v in pairs(rexue_equip_list) do
		local data = self:SetReXueCanBestData(v)
		if data ~= nil then
			return true
		end
	end
	return false
end

------------------------------------------------------------
-- 热血装备-神铸
------------------------------------------------------------

function ReXueGodEquipData:InitReXueShenzhu()
	self.all_shenzhu_data = {}
	self.all_shenge_data = {}

	self.all_shenzhu_slot_list = {
		[1] = EquipData.EquipSlot.itWeaponPos,						-- 武器 0
		[2] = EquipData.EquipSlot.itDressPos,						-- 衣服 1
		[3] = EquipData.EquipSlot.itHelmetPos,						-- 头盔 2
		[4] = EquipData.EquipSlot.itNecklacePos,					-- 项链 3
		[5] = EquipData.EquipSlot.itLeftBraceletPos,				-- 左边的手镯 4
		[6] = EquipData.EquipSlot.itRightBraceletPos,				-- 右边的手镯 5
		[7] = EquipData.EquipSlot.itLeftRingPos,					-- 左边的戒指 6
		[8] = EquipData.EquipSlot.itRightRingPos,					-- 右边的戒指 7
		[9] = EquipData.EquipSlot.itGirdlePos,						-- 腰带 8
		[10] = EquipData.EquipSlot.itShoesPos,						-- 鞋子	9

		[11] = EquipData.EquipSlot.itWarmBloodDivineswordPos,		-- 热血_神剑 10
		[12] = EquipData.EquipSlot.itWarmBloodGodNailPos,			-- 热血_神甲 11
		[13] = EquipData.EquipSlot.itGodWarHelmetPos,				-- 战神_头盔	45
		[14] = EquipData.EquipSlot.itGodWarNecklacePos,				-- 战神_项链 46
		[15] = EquipData.EquipSlot.itGodWarLeftBraceletPos,			-- 战神_左手镯 47
		[16] = EquipData.EquipSlot.itGodWarRightBraceletPos,		-- 战神_右手镯 48
		[17] = EquipData.EquipSlot.itGodWarLeftRingPos,				-- 战神_左戒指 49
		[18] = EquipData.EquipSlot.itGodWarRightRingPos,			-- 战神_右戒指 50
		[19] = EquipData.EquipSlot.itGodWarGirdlePos,				-- 战神_腰带 51
		[20] = EquipData.EquipSlot.itGodWarShoesPos,				-- 战神_鞋子 52
		[21] = EquipData.EquipSlot.itWarmBloodElbowPadsPos,			-- 热血_面甲 12
		[22] = EquipData.EquipSlot.itWarmBloodShoulderPadsPos,		-- 热血_护肩 13
		[23] = EquipData.EquipSlot.itWarmBloodPendantPos,			-- 热血_吊坠 14
		[24] = EquipData.EquipSlot.itWarmBloodKneecapPos,			-- 热血_护膝 15
		[25] = EquipData.EquipSlot.itKillArrayShaPos,				-- 杀阵_天煞 41
		[26] = EquipData.EquipSlot.itKillArrayMostPos,				-- 杀阵_天绝 42
		[27] = EquipData.EquipSlot.itKillArrayRobberyPos,			-- 杀阵_天劫 43
		[28] = EquipData.EquipSlot.itKillArrayLifePos,				-- 杀阵_天命 44

		[29] = EquipData.EquipSlot.itSubmachineGunPos,				-- 冲锋枪 29
		[30] = EquipData.EquipSlot.itOpenCarPos,					-- 敞篷车 30
		[31] = EquipData.EquipSlot.itAnCrownPos,					-- 皇冠 31
		[32] = EquipData.EquipSlot.itGoldenSkullPos,				-- 金骷髅 32
		[33] = EquipData.EquipSlot.itGoldChainPos,					-- 金链子 33
		[34] = EquipData.EquipSlot.itGoldPipePos,					-- 金烟斗 34
		[35] = EquipData.EquipSlot.itGoldDicePos,					-- 金骰子 35
		[36] = EquipData.EquipSlot.itGlobeflowerPos,				-- 金莲花 36
		[37] = EquipData.EquipSlot.itJazzHatPos,					-- 爵士帽 37
		[38] = EquipData.EquipSlot.itRolexPos,						-- 劳力士 38
		[39] = EquipData.EquipSlot.itDiamondRingPos,				-- 钻戒 39
		[40] = EquipData.EquipSlot.itGentlemenBootsPos,				-- 绅士靴 40
	}

	self.shenzhu_slot_list = {[1] = {}, [2] = {}, [3] = {},}
	for shenzhu_slot, equip_slot in ipairs(self.all_shenzhu_slot_list) do
		if shenzhu_slot <= 10 then
			self.shenzhu_slot_list[1][equip_slot] = shenzhu_slot -- 1~10
		elseif shenzhu_slot > 10 and shenzhu_slot <= 28 then
			self.shenzhu_slot_list[2][equip_slot] = shenzhu_slot -- 11~28
		else
			self.shenzhu_slot_list[3][equip_slot] = shenzhu_slot -- 29~40
		end
	end

	self.shenzhu_slot_cfg = {}
	self.shenzhu_consume_id = {}
	local shenzhu_slot = 0 -- 配置文件名的槽位是从0开始
	local path = "scripts/config/server/config/item/GodCasting/GodCastingSlot%d.lua"
	local path2 = "item/GodCasting/GodCastingSlot%d"
	while(cc.FileUtils:getInstance():isFileExist(string.format(path, shenzhu_slot)))
	do
		local cur_slot_cfg = ConfigManager.Instance:GetServerConfig(string.format(path2, shenzhu_slot))
		shenzhu_slot = shenzhu_slot + 1
		self.shenzhu_slot_cfg[shenzhu_slot] = cur_slot_cfg and cur_slot_cfg[1]
		for i, v in ipairs(self.shenzhu_slot_cfg[shenzhu_slot] or {}) do
			-- 神铸的消耗
			local consumes = v.consumes or {}
			for i, consume in ipairs(consumes) do
				local consume_id = consume.id or 0
				self.shenzhu_consume_id[consume_id] = true
			end
			-- 增加神铸概率的消耗
			local consumes = v.addRate and v.addRate.consumes or {}
			for i, consume in ipairs(consumes) do
				local consume_id = consume.id or 0
				self.shenzhu_consume_id[consume_id] = true
			end

			-- 神铸失败不掉级的消耗
			local consumes = v.insureCost or {}
			for i, consume in ipairs(consumes) do
				local consume_id = consume.id or 0
				self.shenzhu_consume_id[consume_id] = true
			end
		end
	end

	self.shenge_slot_cfg = {}
	local shenzhu_slot = 0 -- 配置文件名的槽位是从0开始
	local path = "scripts/config/server/config/item/GodQuality/GodQualitySlot%d.lua"
	local path2 = "item/GodQuality/GodQualitySlot%d"
	while(cc.FileUtils:getInstance():isFileExist(string.format(path, shenzhu_slot)))
	do
		local cur_slot_cfg = ConfigManager.Instance:GetServerConfig(string.format(path2, shenzhu_slot))
		shenzhu_slot = shenzhu_slot + 1
		self.shenge_slot_cfg[shenzhu_slot] = cur_slot_cfg and cur_slot_cfg[1]

		for i, v in ipairs(self.shenge_slot_cfg[shenzhu_slot] or {}) do
			local consumes = v.consumes or {}
			for i, consume in ipairs(consumes) do
				local consume_id = consume.id or 0
				self.shenzhu_consume_id[consume_id] = true
			end
		end
	end

	self.shenzhu_type = 1
end

function ReXueGodEquipData:GetReXueShenzhuSlotList(_type)
	if _type then
		return self.shenzhu_slot_list[_type] or {}
	else
		return self.shenzhu_slot_list or {}
	end
end

function ReXueGodEquipData:GetReXueShenzhuEquipList(_type)
	local list = {}

	local equip_data = EquipData.Instance:GetEquipData()
	local shenzhu_level_list = self:GetShenzhuLevel()
	local shenge_level_list = self:GetShengeLevel()
	if _type then
		local slot_list = self:GetReXueShenzhuSlotList(_type)
		for slot, shenzhu_slot in pairs(slot_list) do
			local equip = equip_data[slot]
			if equip then
				local data = {equip = equip, slot = slot, shenzhu_slot = shenzhu_slot}
				table.insert(list, data)
			end
		end
	else
		for _type, slot_list in pairs(self:GetReXueShenzhuSlotList()) do
			for slot, shenzhu_slot in pairs(slot_list) do
				local equip = equip_data[slot]
				if equip then
					local data = {equip = equip, slot = slot, shenzhu_slot = shenzhu_slot}
					table.insert(list, data)
				end
			end
		end
	end

	table.sort(list, function(a, b)
		return a.shenzhu_slot < b.shenzhu_slot
	end)

	return list
end

-- 设置所有神铸数据(7, 52)
function ReXueGodEquipData:SetAllShenzhuData(protocol)
	self.all_shenzhu_data = protocol.data
	GlobalEventSystem:Fire(OtherEventType.STRENGTH_INFO_CHANGE)
end

-- 设置所有神格数据(7, 53)
function ReXueGodEquipData:SetAllShengeData(protocol)
	self.all_shenge_data = protocol.data
	GlobalEventSystem:Fire(OtherEventType.STRENGTH_INFO_CHANGE)
end

-- 设置神铸结果(7, 54)
function ReXueGodEquipData:SetShenzhuResult(protocol)
	local old_lv = self.all_shenzhu_data[protocol.slot] or 0
	self.all_shenzhu_data[protocol.slot] = protocol.level
	self:DispatchEvent(ReXueGodEquipData.SHENZHU_RESULT, protocol.slot, protocol.level, protocol.level > old_lv)

	GlobalEventSystem:Fire(OtherEventType.STRENGTH_INFO_CHANGE, self.all_shenzhu_slot_list[protocol.slot])
end

-- 设置神格结果(7, 55)
function ReXueGodEquipData:SetShengeResult(protocol)
	self.all_shenge_data[protocol.slot] = protocol.level
	self:DispatchEvent(ReXueGodEquipData.SHENGE_RESULT, protocol.slot, protocol.level)

	GlobalEventSystem:Fire(OtherEventType.STRENGTH_INFO_CHANGE, self.all_shenzhu_slot_list[protocol.slot])
end

-- 获取神铸等级
function ReXueGodEquipData:GetShenzhuLevel(shenzhu_slot)
	if shenzhu_slot then
		return self.all_shenzhu_data[shenzhu_slot] or 0
	else
		return self.all_shenzhu_data
	end
end

-- 获取神格等级
function ReXueGodEquipData:GetShengeLevel(shenzhu_slot)
	if shenzhu_slot then
		return self.all_shenge_data[shenzhu_slot] or 0
	else
		return self.all_shenge_data
	end
end

-- 获取神铸槽位配置
function ReXueGodEquipData:GetShenzhuSlotCfg(shenzhu_slot)
	if shenzhu_slot then
		return self.shenzhu_slot_cfg[shenzhu_slot] or {}
	else
		return self.shenzhu_slot_cfg
	end
end

-- 获取神铸槽位等级配置
function ReXueGodEquipData:GetShenzhuLevelCfg(shenzhu_slot, level, is_next)
	local cfg = {}
	if shenzhu_slot then
		level = level or self:GetShenzhuLevel(shenzhu_slot) -- 默认获取当前槽位等级
		level = is_next and (level + 1) or level -- 下一级
		local cur_cfg = self:GetShenzhuSlotCfg(shenzhu_slot) -- 当前槽位配置
		cfg = cur_cfg[level] or {}
	end

	return cfg, level
end

-- 获取神格槽位配置
function ReXueGodEquipData:GetShengeSlotCfg(shenzhu_slot)
	if shenzhu_slot then
		return self.shenge_slot_cfg[shenzhu_slot] or {}
	else
		return self.shenge_slot_cfg
	end
end

-- 获取神格槽位等级配置
function ReXueGodEquipData:GetShengeLevelCfg(shenzhu_slot, level, is_next)
	local cfg = {}
	if shenzhu_slot then
		level = level or self:GetShengeLevel(shenzhu_slot) -- 默认获取当前槽位等级
		level = is_next and (level + 1) or level --下一级
		local cur_cfg = self:GetShengeSlotCfg(shenzhu_slot) -- 当前槽位配置
		cfg = cur_cfg[level] or {}
	end

	return cfg, level
end

-- 神铸和神格消耗物品ID列表
function ReXueGodEquipData:GetShenzhuLevelConsumeId()
	return self.shenzhu_consume_id
end

-- 
function ReXueGodEquipData:SetShenzhuType(_type)
	self.shenzhu_type = _type
end

function ReXueGodEquipData:GetShenzhuType()
	return self.shenzhu_type
end

function ReXueGodEquipData:SetShenzhuSelectData(select_data)
	self.shenzhu_select_data = select_data
end

function ReXueGodEquipData:GetShenzhuSelectData()
	return self.shenzhu_select_data
end

-- 可神铸的最大等级 (key=神格等级 value=最大神铸等级)
function ReXueGodEquipData:GetShenzhuLevelMax(shenzhu_slot)
	local list = {}
	local cur_slot_cfg = self:GetShenzhuSlotCfg(shenzhu_slot)
	for cur_shenzhu_lv, cur_cfg in ipairs(cur_slot_cfg) do
		local god_quality_lv = cur_cfg.godQualityLv or 999
		local shenzhu_lv = list[god_quality_lv] or 0
		list[god_quality_lv] = math.max(shenzhu_lv, cur_shenzhu_lv)
	end

	return list
end

-- 当前神铸是否开放
function ReXueGodEquipData.ReXueShenzhuIsOpen(_type)
	local role_lv = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local open_server_day = OtherData.Instance:GetOpenServerDays()
	local combined_server_day = OtherData.Instance:GetCombindDays()
	local cfg = GodCastingCfg or {}
	local open_limit = cfg[_type] and cfg[_type].openLimit or {opendays = 999, combindays = 999, level = 9999, circle = 99}

	local bool = role_lv >= open_limit.level and circle >= open_limit.circle and open_server_day >= open_limit.opendays and combined_server_day >= open_limit.combindays

	return bool
end

-- _type = 1-神装 2-热血 3-豪装
function ReXueGodEquipData:ReXueShenzhuStarSuitIndex(_type)
	local cur_index = 0
	local total_level = 0

	if type(_type) == "number" then
		total_level = self:ReXueShenzhuTotalLevel(_type)

		local cfg = GodCastingPlusConfig and GodCastingPlusConfig[_type] or {}
		for suit_index, v in ipairs(cfg) do
			local need_total_level = v.totalLevel
			if total_level >= need_total_level then
				cur_index = math.max(cur_index, suit_index)
			end
		end
	end

	return cur_index, total_level
end

function ReXueGodEquipData:GetReXueShenzhuStarSuitAttr(_type, index)
	local cfg = GodCastingPlusConfig or {}
	local cur_cfg = cfg[_type] and cfg[_type][index] or {}

	return cur_cfg
end

-- 获取神铸总等级
function ReXueGodEquipData:ReXueShenzhuTotalLevel(_type)
	local total_level = 0

	local shenzhu_slot_list = self:GetReXueShenzhuSlotList(_type)
	for equip_slot, shenzhu_slot in pairs(shenzhu_slot_list) do
		local shenzhu_level = self:GetShenzhuLevel(shenzhu_slot)
		total_level = total_level + shenzhu_level
	end

	return total_level
end

function ReXueGodEquipData:GetShenzhuSlotByEquipSlot(equip_slot)
	local shenzhu_slot = -1
	local shenzhu_slot_list = self:GetReXueShenzhuSlotList()
	for _type, slot_list in ipairs(shenzhu_slot_list) do
		shenzhu_slot = slot_list[equip_slot] or shenzhu_slot
	end

	return shenzhu_slot
end

-- 用装备槽位获取"神铸"等级 用于装备Tips显示
function ReXueGodEquipData:GetShenzhuLevelByEquipSlot(equip_slot)
	local shenzhu_slot = self:GetShenzhuSlotByEquipSlot(equip_slot)
	local shenzhu_level = self:GetShenzhuLevel(shenzhu_slot)

	return shenzhu_level, shenzhu_slot
end

-- 用装备槽位获取"神格"等级 用于装备Tips显示
function ReXueGodEquipData:GetShengeLevelByEquipSlot(equip_slot)
	local shenzhu_slot = self:GetShenzhuSlotByEquipSlot(equip_slot)
	local shenge_level = self:GetShengeLevel(shenzhu_slot)

	return shenge_level
end

-- 获取神铸属性和属性文本 用于装备Tips显示
function ReXueGodEquipData.GetShenzhuText(shenzhu_slot, shenzhu_level)
	local cur_cfg = ReXueGodEquipData.Instance:GetShenzhuLevelCfg(shenzhu_slot, shenzhu_level)
	local cur_attr = cur_cfg.attrs or {} -- 当前槽位属性

	local attr_data = RoleData.FormatRoleAttrStr(cur_attr)
	local attr_content = "" -- 属性内容
	local line = 0	-- 行数
	if attr_data then
		for i,v in ipairs(attr_data) do
			if line ~= 0 then
				attr_content = attr_content .. "\n"
			end

			local type_str = v.type_str or ""
			type_str = "{color;" .. COLORSTR.BLUE .. ";" .. type_str .. "：}"

			local value_str = v.value_str or ""
			value_str = "{color;" .. COLORSTR.BLUE .. ";" .. value_str .. "}"

			attr_content = attr_content .. type_str .. value_str
			line = line + 1
		end
	end

	return attr_content, cur_attr, line
end

-- 获取神格属性和属性文本 用于装备Tips显示
function ReXueGodEquipData.GetShengeText(shenzhu_slot, shenge_level)
	local cur_cfg = ReXueGodEquipData.Instance:GetShengeLevelCfg(shenzhu_slot, shenge_level)
	local cur_attr = cur_cfg.attrs or {} -- 当前槽位属性

	local attr_data = RoleData.FormatRoleAttrStr(cur_attr)
	local attr_content = "" -- 属性内容
	local line = 0	-- 行数
	if attr_data then
		for i,v in ipairs(attr_data) do
			if line ~= 0 then
				attr_content = attr_content .. "\n"
			end

			local type_str = v.type_str or ""
			type_str = "{color;" .. COLORSTR.BLUE .. ";" .. type_str .. "：}"

			local value_str = v.value_str or ""
			value_str = "{color;" .. COLORSTR.BLUE .. ";" .. value_str .. "}"

			attr_content = attr_content .. type_str .. value_str
			line = line + 1
		end
	end

	return attr_content, cur_attr, line
end

-- 获取神铸红点提示
function ReXueGodEquipData:GetShenzhuRemindNum()
	local index = 0
	local def = ViewDef.MainGodEquipView.RexueShenzhu
	if not ViewManager.Instance:CanOpen(def) then return index end

	local equip_list = EquipData.Instance:GetEquipData() or {}
	for _type, slot_list in ipairs(self:GetReXueShenzhuSlotList()) do
		-- 是否开放
		if ReXueGodEquipData.ReXueShenzhuIsOpen(_type) then
			for equip_slot, shenzhu_slot in pairs(slot_list) do
				-- 是否穿戴装备
				if equip_list[equip_slot] then
					-- 是否可神格
					local bool = false
					local next_shenge_cfg, next_shenge_lv = self:GetShengeLevelCfg(shenzhu_slot, nil, true)
					if next(next_shenge_cfg) then
						local consumes = next_shenge_cfg.consumes or {}
						bool = BagData.CheckConsumesCount(consumes)
						if bool then
							index = 1
							break
						end
					end

					-- 是否可神铸
					local next_shenzhu_cfg = self:GetShenzhuLevelCfg(shenzhu_slot, nil, true)
					local god_quality_lv = next_shenzhu_cfg.godQualityLv or 99
					if next(next_shenzhu_cfg) and next_shenge_lv > god_quality_lv then
						local consumes = next_shenzhu_cfg.consumes or {}
						bool = BagData.CheckConsumesCount(consumes)
						if bool then
							index = 1
							break
						end
					end
				end
			end
		end
	end

	return index
end
