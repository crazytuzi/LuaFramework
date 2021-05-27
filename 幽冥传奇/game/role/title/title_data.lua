-- -------------------------------------------
-- --主角称号数据
-- --------------------------------------------

-- TitleData = TitleData or BaseClass()

-- TITLE_TYPE = {
-- 	TEMPORARY = 0,
-- 	FOREVER = 1,
-- 	TIME_LIMIT = 2,
-- }

-- TITLE_CLIENT_CONFIG = {
-- 	[1] = {effect_id = 301},				-- 第一战士(临时称号)
-- 	[2] = {effect_id = 302},				-- 第一法师(临时称号)
-- 	[3] = {effect_id = 303},				-- 第一道士(临时称号)
-- 	[4] = {effect_id = 304},				-- 天下第一战力(临时称号)
-- 	[5] = {effect_id = 305},				-- 不差钱 (有充值元宝)
-- 	[6] = {effect_id = 306},				-- 壕 (开服7天内, 累计充值达到500000元宝)	
-- 	[7] = {effect_id = 307},				-- 一掷萬金 (开服7天内, 累计消费达到100000元宝)
-- 	[8] = {effect_id = 308},				-- 有品味的VIP (VIP等级达到 n/6 VIP)
-- 	[9] = {effect_id = 309},				-- 万人斩 (阵营战(活动)中累计击杀达到1000人)
-- 	[10] = {effect_id = 310},				-- 大富翁 (累计获得500000绑定元宝)
-- 	[11] = {effect_id = 335},				-- 不给糖果就捣乱 (累积登陆游戏7天)
-- 	[12] = {effect_id = 312},				-- 寻宝不归路 (探索宝藏累计消费达到1000000元宝)
-- 	[13] = {effect_id = 336},				-- 厉害了我的哥, 累计登陆游戏15天
-- 	[14] = {effect_id = 338},				-- 传世新兵(天关第1重天第10关)
-- 	[15] = {effect_id = 339},				-- 传世勇者(天关第2重天第10关)
-- 	[16] = {effect_id = 340},				-- 传世豪杰(天关第3重天第10关)
-- 	[17] = {effect_id = 341},				-- 传世宗师(天关第4重天第10关)
-- 	[18] = {effect_id = 342},				-- 传世王者(天关第5重天第10关)
-- 	[19] = {effect_id = 343},				-- 传世君者(天关第6重天第10关)
-- 	[20] = {effect_id = 344},				-- 传世圣者(天关第7重天第10关)
-- 	[21] = {effect_id = 345},				-- 传世皇者(天关第8重天第10关)
-- 	[22] = {effect_id = 346},				-- 传世尊者(天关第9重天第10关)
-- 	[23] = {effect_id = 347},				-- 传世帝皇(天关第10重天第10关)
-- 	[24] = {effect_id = 348},				-- 传世主宰(天关第11重天第10关)
-- 	[25] = {effect_id = 349},				-- 传世无双(天关第12重天第10关)
-- 	[26] = {effect_id = 326},				-- 武林争霸(活动)中胜利的玩家(临时称号)
-- 	[27] = {effect_id = 337},				-- 装备全靠打
-- 	[28] = {effect_id = 332},				-- 持宝人
-- 	[29] = {effect_id = 329},				-- 王城大战(活动)中胜利的行会成员(临时称号)
-- 	[30] = {effect_id = 330},				-- 王城大战(活动)中胜利的行会会长(临时称号)	
-- 	[31] = {effect_id = 1227},				-- 神起平台称号，战地记者
-- 	[32] = {effect_id = 1228},				-- 贵族特权
-- 	[33] = {effect_id = 1229},				-- 王者特权
-- 	[34] = {effect_id = 1230},				-- 至尊特权
-- 	[35] = {effect_id = 1242},				-- 名人堂-名人(红色-第一)
-- 	[36] = {effect_id = 1243},				-- 名人堂-名人(第二)
-- 	[37] = {effect_id = 1244},				-- 名人堂-名人(第三)
-- 	-- [38] = {effect_id = 400},				-- 特权1
-- 	-- [39] = {effect_id = 401},				-- 特权2
-- 	-- [40] = {effect_id = 402},				-- 特权3
-- }

-- TITLE_REQ = {
-- 	INFO = 1,
-- 	SELECT = 2
-- }
-- function TitleData:__init()
-- 	if TitleData.Instance then
-- 		ErrorLog("[TitleData] Attemp to create a singleton twice !")
-- 	end
-- 	TitleData.Instance = self
	
-- 	self.all_title_list = {}
-- 	self.tem_title_list = {} 			--临时称号
-- 	self.for_title_list = {}			--永久称号
-- 	self.tianguan_title_list = {}			--天关称号
-- 	self.title_over_times = {}
-- 	self.title_info = {
-- 		title_sign = 0,    --称号标记
-- 		loading_days = 0, 
-- 		xunbao_add_consume_gold = 0,  --探索宝藏累计消费达到多少元宝
-- 		get_gold_50000 = 0,   --累计获得500000绑定元宝
-- 		faction_battle_kill_people = 0,  --阵营战击杀人数
-- 		consume_gold_count = 0,  --消耗元宝数
-- 	}
-- 	self.title_act_t = {}
-- 	self:InitAllTitlelist()
-- end

-- function TitleData:__delete()
-- 	TitleData.Instance = nil
-- 	self.all_title_list = nil
-- end

-- function TitleData:InitAllTitlelist()
-- 	print("cd------------>InitAllTitlelist",what) 
-- 	self.all_title_list = {}
-- 	self.tem_title_list = {}
-- 	self.for_title_list = {}
-- 	self.tianguan_title_list = {}
-- 	for i = 1, 100 do
-- 		if TITLE_CLIENT_CONFIG[i] then
-- 			local title_cfg = TitleData.GetHeadTitleConfig(i)
-- 			print("cd------------>title_cfg",title_cfg, i) 
-- 			if nil ~= title_cfg then
-- 				if not title_cfg.Spid or title_cfg.Spid == AgentAdapter:GetSpid() then
-- 					table.insert(self.all_title_list, title_cfg)
-- 					if title_cfg.titleType == TITLE_TYPE.TEMPORARY or title_cfg.titleType == TITLE_TYPE.TIME_LIMIT then
-- 						table.insert(self.tem_title_list, title_cfg)
-- 					elseif title_cfg.titleType == TITLE_TYPE.FOREVER then
-- 						if 12 == title_cfg.paramType then
-- 							table.insert(self.tianguan_title_list, title_cfg)
-- 						else
-- 							table.insert(self.for_title_list, title_cfg)
-- 						end
-- 					end
-- 				end
-- 			end
-- 		end
-- 	end
-- end

-- function TitleData:TitleSort()
-- 	return function (a, b)
-- 		local off_a = 100
-- 		local off_b = 100

-- 		if self:GetTitleActive(a.titleId) ~= 0 then
-- 			off_a = off_a + 10
-- 		end
-- 		if self:GetTitleActive(b.titleId) ~= 0 then
-- 			off_b = off_b + 10
-- 		end
		
-- 		if a.titleId < b.titleId then
-- 			off_a = off_a + 1
-- 		elseif a.titleId > b.titleId then
-- 			off_b = off_b + 1
-- 		end

-- 		return off_a > off_b
-- 	end	
-- end

-- function TitleData:SortTitle()
-- 	table.sort(self.tem_title_list, self:TitleSort())
-- 	table.sort(self.for_title_list, self:TitleSort())
-- 	table.sort(self.tianguan_title_list, self:TitleSort())
-- end

-- function TitleData:GetTitleInfo()
-- 	return self.title_info
-- end

-- function TitleData:GetTitleActive(title_id)
-- 	return self.title_act_t[title_id] or 0
-- end

-- function TitleData:GetAllActiveTitleAttr()
-- 	local staitcAttrs = {
-- 		{ type = 9, value = 0 },--最小物理攻击
-- 		{ type = 11, value = 0 },--最大物理攻击
-- 		{ type = 13, value = 0 },--最小魔法攻击
-- 		{ type = 15, value = 0 },--最大魔法攻击
-- 		{ type = 17, value = 0 },--最小道术攻击
-- 		{ type = 19, value = 0 },--最大道术攻击
-- 	}
-- 	for k,v in pairs(TITLE_CLIENT_CONFIG) do
-- 		if self:GetTitleActive(k) ~= 0 and TitleData.GetHeadTitleConfig(k) then
-- 			local cfg = TitleData.GetHeadTitleConfig(k)
-- 			staitcAttrs = CommonDataManager.AddAttr(staitcAttrs, cfg.staitcAttrs)
-- 		end
-- 	end
-- 	return staitcAttrs
-- end

-- function TitleData:SetTitleInfo(protocol)
-- 	self.title_info.title_sign = protocol.title_sign
-- 	self.title_info.loading_days = protocol.loading_days
-- 	self.title_info.xunbao_add_consume_gold = protocol.xunbao_add_consume_gold
-- 	self.title_info.get_gold_50000 = protocol.get_gold_50000
-- 	self.title_info.faction_battle_kill_people = protocol.faction_battle_kill_people
-- 	self.title_info.consume_gold_count = protocol.consume_gold_count
-- end

-- --1表示累积登陆天数 2表示累积获得绑定元宝 3充值元宝 4阵营战累积击杀人数 
--  --5翅膀进阶 6宝石装备进阶 7圣珠装备提升 8累积消费元宝 9单笔充值元宝 10vip等级 11 寻宝累积消费 12天关 13人物等级
-- function TitleData:GetTitleParam(paramType)
-- 	if paramType == 1 then
-- 		return self.title_info.loading_days
-- 	elseif paramType == 2 then
-- 		return self.title_info.get_gold_50000
-- 	elseif paramType == 3 then
-- 		return 0
-- 	elseif paramType == 4 then
-- 		return self.title_info.faction_battle_kill_people
-- 	elseif paramType == 5 then
-- 		return 0
-- 	elseif paramType == 6 then
-- 		local equip = EquipData.Instance:GetGridData(EquipData.EquipIndex.EquipDiamond)
-- 		if equip then
-- 			local k, _ = ComposeData.ReadEquipStoveCfg(equip.item_id, EquipStoveCfg.GemUpgrade)
-- 			return k or 0
-- 		else
-- 			return 0
-- 		end
-- 	elseif paramType == 7 then
-- 		local equip = EquipData.Instance:GetGridData(EquipData.EquipIndex.Seal)
-- 		if equip then
-- 			local k, _ = ComposeData.ReadEquipStoveCfg(equip.item_id, EquipStoveCfg.MagicalOrb)
-- 			return k or 0
-- 		else
-- 			return 0
-- 		end
-- 	elseif paramType == 8 then
-- 		return self.title_info.consume_gold_count
-- 	elseif paramType == 9 then
-- 		return 0
-- 	elseif paramType == 10 then
-- 		return RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_VIP_GRADE)
-- 	elseif paramType == 11 then
-- 		return self.title_info.xunbao_add_consume_gold
-- 	else
-- 		return 0
-- 	end
-- end

-- function TitleData:GetAllTitlelist()
-- 	return self.all_title_list
-- end

-- function TitleData:GetTemTitlelist()
-- 	return self.tem_title_list
-- end

-- function TitleData:GetForTitlelist()
-- 	return self.for_title_list
-- end

-- function TitleData:GetTianguanTitlelist()
-- 	return self.tianguan_title_list
-- end

-- function TitleData:GetTilteActList()
-- 	return self.title_act_t
-- end

-- function TitleData:SetTilteActList(list)
-- 	self.title_act_t = list
-- 	self:SortTitle()
-- end

-- function TitleData.GetHeadTitleConfig(title_id)
-- 	if cc.FileUtils:getInstance():isFileExist("scripts/config/server/config/rank/headTitle/headTitle" .. title_id .. ".lua") then
-- 		return ConfigManager.Instance:GetServerConfig("rank/headTitle/headTitle" .. title_id)[1]
-- 	end
-- end

-- function TitleData.GetTitleEffId(title_id)
-- 	return TITLE_CLIENT_CONFIG[title_id] and TITLE_CLIENT_CONFIG[title_id].effect_id or 0
-- end

-- -- 根据天关重数获取可获得的称号id
-- function TitleData.GetTianguanTitleId(index)
-- 	return 13 + index
-- end

-- function TitleData.GetTitleAttrCfg(title_id)
-- 	local title_cfg = TitleData.GetHeadTitleConfig(title_id)
-- 	return title_cfg and title_cfg.staitcAttrs
-- end

-- function TitleData:SetTitleOverTime(title_id, over_time)
-- 	self.title_over_times[title_id] = over_time
-- end

-- function TitleData:GetTitleOverTime(title_id)
-- 	return self.title_over_times[title_id] or -1
-- end
