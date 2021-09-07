CampData = CampData or BaseClass()

CampData.JinYanGuanLi = 1 			-- 禁言管理
CampData.NeiJianBiaoJi = 2 			-- 内奸标记
CampData.JieChuNeiJian = 3 			-- 解除内奸

function CampData:__init()
	if CampData.Instance ~= nil then
		print_error("[CampData] attempt to create singleton twice!")
		return
	end
	CampData.Instance = self

	-- 根据国家获取对应国家的场景ID
	self.camp_scene = {
		[GameEnum.ROLE_CAMP_1] = 2002,		-- 齐国
		[GameEnum.ROLE_CAMP_2] = 2102,		-- 楚国
		[GameEnum.ROLE_CAMP_3] = 2202,		-- 秦国
	}

	-- 国家配置
	self.camp_cfg = nil						-- 请调用 GetCampCfg() 来使用
	self.camp_other_cfg = nil				-- 请调用 GetCampOtherCfg() 来使用

	-- 国家拍卖配置
	self.campsalecfg = nil					-- 请调用 GetCampSaleCfg() 来使用
	self.campsale_other_cfg = nil			-- 请调用 GetCampSaleOtherCfg() 来使用
	self.campsale_items_cfg = nil			-- 请调用 GetCampSaleItemsCfg() 来使用
	self.campsale_monster_drop_cfg = nil	-- 请调用 GetCampSaleMonsterDropCfg() 来使用
	self.camp_level_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("campconfg_auto").camp_level, "level")
	self.camp_level_exp_add = ListToMap(ConfigManager.Instance:GetAutoConfig("campconfg_auto").camp_level_exp_add, "reason")
	self.camp_tower_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("campconfg_auto").monster_siege_tower, "seq")

	self.camp_info = {						-- 阵营(国家)信息
		camp_item_list = {},
		my_camp_type = 0,
		king_guild_id = 0,
		king_guild_name = "",
		officer_list = {},
		notice = "",
		reborn_dan_num = 0,
	}

	self.camp_mem_info = {					-- 阵营(国家)成员信息
		page = 0,
		total_page = 0,
		order_type = 0,
		count = 0,
		mem_info_item_list = {},
		oneself_mem_info = {}				-- 自己的信息
	}

	self.camp_common_info = {				-- 阵营(国家)通用信息
		result_type = 0,
		param1 = 0,
		param2 = 0,
		param3 = 0,
		param4 = 0,
	}

	self.reborn_time = {					-- 分配复活次数
		king_reborn_times_idx = 0,
		officer_reborn_times_idx = 0,
		jingying_reborn_times_idx = 0,
		guomin_reborn_times_idx = 0,
	}

	self.role_camp_rank_list = {			-- 角色阵营排行信息
		camp = 0,
		rank_type = 0,
		my_rank = 0,
		my_rank_val = 0,
		ignore_camp_post = 0,
		count = 0,
		rank_list = {},
	}

	self.camp_saleitem_list = {				-- 阵营(国家)拍卖物品列表
		order_type = 0,
		page = 0,
		total_page = 0,
		camo_gold = 0,
		count = 0,
		item_info_list = {},
	}
	
	self.camp_sale_result_list = {			-- 上架物品的售卖结果项(日志)
		count = 0,
		sale_result_item_list = {},
	}

	self.camp_search_mem_list = {			-- 查询玩家列表
		count = 0,
		item_info_list = {},
	}

	self.camp_role_info = {					-- 角色的国家信息
		camp_type = 0,						-- 国家类型
		camp_post = 0,						-- 国家官职
		neizheng_yunbiao_times = 0,			-- 内政-运镖次数
		neizheng_officer_welfare_times = 0,	-- 内政-官员福利次数
		neizheng_guomin_welfare_times = 0,	-- 内政-国民福利次数
		neizheng_set_neijian_times = 0,		-- 内政-设置内奸次数
		neizheng_unset_neijian_times = 0,	-- 内政-取消内奸次数
		neizheng_callin_times = '',			-- 内政-已使用召集次数

	}

	self.day_counter_list = {				-- 内政功能里面的次数
		[CAMP_AFFAIRS_TYPE.YUNBIAO] = 1,
		[CAMP_AFFAIRS_TYPE.BANZHUAN] = 1,
		[CAMP_AFFAIRS_TYPE.GUOMINFULI] = 1,
		[CAMP_AFFAIRS_TYPE.JINYANWANJIA] = 1,
		[CAMP_AFFAIRS_TYPE.NEIJIANBIAOJI] = 1,
		[CAMP_AFFAIRS_TYPE.SHEMIANNEIJIAN] = 1,
		[CAMP_AFFAIRS_TYPE.GUANYUANFULI] = 1,
		[CAMP_AFFAIRS_TYPE.FUHUOFENPEI] = 1,
	}

	self.fate_tower = {						-- 气运塔
		is_xiuzhan = 0,						-- 当前加成速率
		item_list = {},
	}

	self.fate_war = {						-- 气运战报
		attack_report_list = {},			-- 攻方
		defend_report_list = {},			-- 防守方
	}

	self.appoint_camp_post = 0
	self.member_list_type = 1				-- 成员面板的类型(1禁言 2内奸 3解除内奸)

	self.neizheng_yunbiao_end_time = 0

	self.report_list = {}
	self.camp_last_info = {}
	self.camp_score_list = {}

	self.camp_team_info = {}
	self.camp_team_reward_info = {
		login_reward = 0,
		zhanshi_reward = 0,
		zhanshi_count = 0,
	}

	RemindManager.Instance:Register(RemindName.Camp, BindTool.Bind(self.GetPlayerPackageRemind, self))
	RemindManager.Instance:Register(RemindName.CampTeam, BindTool.Bind(self.GetCampTeamRemind, self))
end

function CampData:__delete()
	CampData.Instance = nil
	self.camp_last_info = {}
	RemindManager.Instance:UnRegister(RemindName.Camp)
	RemindManager.Instance:UnRegister(RemindName.CampTeam)
end

function CampData:SetCampInfo(protocol)
	self.camp_info.camp_item_list = protocol.camp_item_list
	self.camp_info.my_camp_type = protocol.my_camp_type
	self.camp_info.king_guild_id = protocol.king_guild_id
	self.camp_info.king_guild_name = protocol.king_guild_name
	self.camp_info.officer_list = protocol.officer_list
	self.camp_info.notice = protocol.notice
	self.camp_info.reborn_dan_num = protocol.reborn_dan_num
	self.camp_info.alliance_camp = protocol.alliance_camp
end

function CampData:GetCampInfo()
	return self.camp_info
end

function CampData:KeepCampInfoNotice()
	self.camp_last_info = TableCopy(self.camp_info)
end

function CampData:GetKeepCampInfoNotice()
	return self.camp_last_info 
end

-- 获取复活丹数量
function CampData:GetCampRebornDanNum()
	return self.camp_info.reborn_dan_num
end

-----------------------------------------------------------------------------------------------------
-- 下面框住部分的东西以前老的，以后有空删了

function CampData.IsCampEquip(sub_type)
	if sub_type == GameEnum.E_TYPE_CAMP_TOUKUI or
		sub_type == GameEnum.E_TYPE_CAMP_YIFU or
		sub_type == GameEnum.E_TYPE_CAMP_HUTUI or
		sub_type == GameEnum.E_TYPE_CAMP_XIEZI or
		sub_type == GameEnum.E_TYPE_CAMP_HUSHOU or
		sub_type == GameEnum.E_TYPE_CAMP_XIANGLIAN or
		sub_type == GameEnum.E_TYPE_CAMP_WUQI or
		sub_type == GameEnum.E_TYPE_CAMP_JIEZHI then
		return true
	end
	return false
end

function CampData:GetEquipMonsterExp(item_id_in_client)
	local exp = 0
	local item = ItemData.Instance:GetItemConfig(item_id_in_client)
	if item == nil then
		return exp
	end

	if nil ~= item.search_type and item.search_type == 104 then
		if item_id_in_client ~= nil then
			local cfg = ConfigManager.Instance:GetAutoConfig("campconfg_auto").camp_equip_recyle
			for k1, v1 in pairs (cfg) do
				if item.limit_level == v1.limit_level and item.color == v1.color then
					exp = exp + v1.experience
				end
			end
		end
	end
	return exp
end

function CampData:GetStatueSceneId(camp)
	local other_cfg = ConfigManager.Instance:GetAutoConfig("campconfg_auto").other[1]
	return other_cfg["dx_sceneid" .. camp] or 0
end

function CampData:GetOtherByStr(str)
	if str == nil then
		return
	end
	
	return ConfigManager.Instance:GetAutoConfig("campconfg_auto").other[1][str]
end

function CampData.ShowCampStatueFollow()
	local scene_id = Scene.Instance:GetSceneId()
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.CAMP_DEFEND1) and scene_id == CampData.Instance:GetStatueSceneId(1) then
		return true
	elseif ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.CAMP_DEFEND2) and scene_id == CampData.Instance:GetStatueSceneId(2) then
		return true
	elseif ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.CAMP_DEFEND3) and scene_id == CampData.Instance:GetStatueSceneId(3) then
		return true
	end
	return false
end

-----------------------------------------------------------------------------------------------------

function CampData:SetCampMemInfo(protocol)
	self.camp_mem_info.page = protocol.page
	self.camp_mem_info.total_page = protocol.total_page
	self.camp_mem_info.order_type = protocol.order_type
	self.camp_mem_info.count = protocol.count
	self.camp_mem_info.mem_info_item_list = protocol.mem_info_item_list
	self.camp_mem_info.oneself_mem_info = protocol.oneself_mem_info
end

function CampData:GetCampMemInfo()
	return self.camp_mem_info
end

function CampData:SetCampCommonInfo(protocol)
	self.camp_common_info.result_type = protocol.result_type
	self.camp_common_info.param1 = protocol.param1
	self.camp_common_info.param2 = protocol.param2
	self.camp_common_info.param3 = protocol.param3
	self.camp_common_info.param4 = protocol.param4
end

function CampData:GetCampCommonInfo()
	return self.camp_common_info
end

function CampData:SetCampRebornInfo(protocol)
	self.reborn_time.king_reborn_times_idx = protocol.king_reborn_times_idx
	self.reborn_time.officer_reborn_times_idx = protocol.officer_reborn_times_idx
	self.reborn_time.jingying_reborn_times_idx = protocol.jingying_reborn_times_idx
	self.reborn_time.guomin_reborn_times_idx = protocol.guomin_reborn_times_idx
end

function CampData:GetCampRebornInfo()
	return self.reborn_time
end

function CampData:SetGetRoleCampRankListAck(protocol)
	self.role_camp_rank_list.camp = protocol.camp
	self.role_camp_rank_list.rank_type = protocol.rank_type
	self.role_camp_rank_list.my_rank = protocol.my_rank
	self.role_camp_rank_list.my_rank_val = protocol.my_rank_val
	self.role_camp_rank_list.ignore_camp_post = protocol.ignore_camp_post
	self.role_camp_rank_list.count = protocol.count
	self.role_camp_rank_list.rank_list = protocol.rank_list
end

function CampData:GetGetRoleCampRankListAck()
	return self.role_camp_rank_list
end

function CampData:SetCampSaleItemList(protocol)
	self.camp_saleitem_list.order_type = protocol.order_type
	self.camp_saleitem_list.page = protocol.page
	self.camp_saleitem_list.total_page = protocol.total_page
	self.camp_saleitem_list.camo_gold = protocol.camo_gold
	self.camp_saleitem_list.count = protocol.count
	self.camp_saleitem_list.item_info_list = protocol.item_info_list
end

-- 获取国家拍卖物品列表
function CampData:GetCampSaleItemList()
	return self.camp_saleitem_list
end


function CampData:SetCampSaleResultList(protocol)
	self.camp_sale_result_list.count = protocol.count
	self.camp_sale_result_list.sale_result_item_list = protocol.sale_result_item_list
end

-- 获取上架物品的售卖结果项
function CampData:GetCampSaleResultList()
	return self.camp_sale_result_list
end


function CampData:SetCampSearchMemList(protocol)
	self.camp_search_mem_list.count = protocol.count
	self.camp_search_mem_list.item_info_list = protocol.item_info_list
end

-- 获取查询玩家列表
function CampData:GetCampSearchMemList()
	return self.camp_search_mem_list
end

-- 清理查询列表
function CampData:ClearCampSearchMemList()
	self.camp_search_mem_list = {			-- 查询玩家列表
		count = 0,
		item_info_list = {},
	}
end

-- 保存角色的国家信息
function CampData:SetCampRoleInfo(protocol)
	self.camp_role_info.camp_type = protocol.camp_type
	self.camp_role_info.camp_post = protocol.camp_post

	self.camp_role_info.neizheng_yunbiao_times = protocol.neizheng_yunbiao_times
	self.camp_role_info.neizheng_banzhuang_times = protocol.neizheng_banzhuang_times
	self.camp_role_info.neizheng_officer_welfare_times = protocol.neizheng_officer_welfare_times
	self.camp_role_info.neizheng_guomin_welfare_times = protocol.neizheng_guomin_welfare_times
	self.camp_role_info.neizheng_set_neijian_times = protocol.neizheng_set_neijian_times
	self.camp_role_info.neizheng_unset_neijian_times = protocol.neizheng_unset_neijian_times
	--已使用的次数
	self.camp_role_info.neizheng_callin_times = protocol.neizheng_callin_times

	self.day_counter_list = {
		[CAMP_AFFAIRS_TYPE.YUNBIAO] = self.camp_role_info.neizheng_yunbiao_times,					-- 内政-运镖次数
		[CAMP_AFFAIRS_TYPE.BANZHUAN] = self.camp_role_info.neizheng_banzhuang_times,				-- 内政-搬砖次数
		[CAMP_AFFAIRS_TYPE.GUOMINFULI] = self.camp_role_info.neizheng_guomin_welfare_times,			-- 内政-国民福利次数
		[CAMP_AFFAIRS_TYPE.JINYANWANJIA] = 1,
		[CAMP_AFFAIRS_TYPE.NEIJIANBIAOJI] = self.camp_role_info.neizheng_set_neijian_times,			-- 内政-设置内奸次数
		[CAMP_AFFAIRS_TYPE.SHEMIANNEIJIAN] = self.camp_role_info.neizheng_unset_neijian_times,		-- 内政-取消内奸次数
		[CAMP_AFFAIRS_TYPE.GUANYUANFULI] = self.camp_role_info.neizheng_officer_welfare_times,		-- 内政-官员福利次数
		[CAMP_AFFAIRS_TYPE.FUHUOFENPEI] = 1,
	}
end

-- 获取查询玩家列表
function CampData:GetCampRoleInfo()
	return self.camp_role_info
end

-- 获取次数
function CampData:GetDayCounterList(btn_type)
	return self.day_counter_list[btn_type] or 1
end

-- 保存气运塔数据
function CampData:SetCampQiyunTowerStatus(protocol)
	self.fate_tower.is_xiuzhan = protocol.is_xiuzhan
	self.fate_tower.item_list = protocol.item_list
end

function CampData:GetCampQiyunTowerStatus()
	return self.fate_tower
end

-- 保存气运战报数据
function CampData:SetCampQiyunBattleReport(protocol)
	self.fate_war.attack_report_list = protocol.attack_report_list
	self.fate_war.defend_report_list = protocol.defend_report_list
end

function CampData:GetCampQiyunBattleReport()
	return self.fate_war
end

function CampData:GetQiYunRemind()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local fate_tower = self:GetCampQiyunTowerStatus()
	if fate_tower.is_xiuzhan == 1 then
		return false
	end
	for k, v in pairs(fate_tower.item_list) do
		if k ~= vo.camp then
			if v.is_alive == 1 then
				return true
			end
		end
	end

	return false
end

----------------------------------------------------------------------------------
-- 读配置区段
----------------------------------------------------------------------------------
function CampData:GetCampCfg()
	if not self.camp_cfg then
		self.camp_cfg = ConfigManager.Instance:GetAutoConfig("campconfg_auto")
	end
	return self.camp_cfg
end

function CampData:GetCampOtherCfg()
	if not self.camp_other_cfg then
		self.camp_other_cfg = self:GetCampCfg().other[1] or {}
	end
	return self.camp_other_cfg
end


function CampData:GetCampSaleCfg()
	if not self.campsalecfg then
		self.campsalecfg = ConfigManager.Instance:GetAutoConfig("campsaleconfig_auto")
	end
	return self.campsalecfg
end

function CampData:GetCampSaleOtherCfg()
	if not self.campsale_other_cfg then
		self.campsale_other_cfg = self:GetCampSaleCfg().other[1] or {}
	end
	return self.campsale_other_cfg
end

function CampData:GetCampSaleItemsCfg()
	if not self.campsale_items_cfg then
		self.campsale_items_cfg = self:GetCampSaleCfg().sale_items or {}
	end
	return self.campsale_items_cfg
end

function CampData:GetCampSaleMonsterDropCfg()
	if not self.campsale_monster_drop_cfg then
		self.campsale_monster_drop_cfg = self:GetCampSaleCfg().monster_drop or {}
	end
	return self.campsale_monster_drop_cfg
end

----------------------------------------------------------------------------------
-- 其他逻辑
----------------------------------------------------------------------------------

-- 获取对应国家的场景ID
function CampData:GetCampScene(camp)
	return self.camp_scene[camp] or 0
end

function CampData:GetCurCampSceneIndex()
	local scene_id = Scene.Instance:GetSceneId()
	for k, v in pairs(self.camp_scene) do
		if v == scene_id then
			return k
		end
	end

	return 1
end

-- 设置任命官职
function CampData:SetAppointCampPost(post)
	self.appoint_camp_post = post
end

-- 获取任命官职
function CampData:GetAppointCampPost()
	return self.appoint_camp_post
end

-- 设置打开成员面板的类型(1禁言 2内奸 3解除内奸 )
function CampData:SetMemberListType(open_type)
	self.member_list_type = open_type
end

-- 获取成员面板的类型
function CampData:GetMemberListType()
	return self.member_list_type
end

-- 设置运镖时间
function CampData:SetCampYunbiaoStatus(end_time)
	self.neizheng_yunbiao_end_time = end_time
end

-- 获取运镖时间
function CampData:GetCampYunbiaoStatus()
	return self.neizheng_yunbiao_end_time
end

-- 获取运镖是否开启
function CampData:GetCampYunbiaoIsOpen()
	return self.neizheng_yunbiao_end_time >= TimeCtrl.Instance:GetServerTime()
end
function CampData:CheckRedPoint()
	 RemindManager.Instance:Fire(RemindName.Camp)
end
function CampData:GetPlayerPackageRemind()
	return self:IsShowRedPoint() and 1 or 0
end
function CampData:IsShowRedPoint()
	if CampData.Instance:GetDayCounterList(CAMP_AFFAIRS_TYPE.GUOMINFULI) > 0 or CampData.Instance:GetDayCounterList(CAMP_AFFAIRS_TYPE.GUANYUANFULI) > 0 then
		return true
	end
end

-- 人物模型位置
function CampData:GetRoleModelPos(prof)
	local cfg_pos = {
		[1] = {
			position = Vector3(-0.06, 0, 0),
			rotation = Vector3(0, 0, 0),
			scale = Vector3(1, 1, 1)
		},
		[2] = {
			position = Vector3(-0.12, 0, 0),
			rotation = Vector3(0, 0, 0),
			scale = Vector3(1, 1, 1)
		},
		[3] = {
			position = Vector3(0.2, 0, 0),
			rotation = Vector3(0, 0, 0),
			scale = Vector3(1, 1, 1)
		},
		[4] = {
			position = Vector3(0.1, 0, 0),
			rotation = Vector3(0, 0, 0),
			scale = Vector3(1, 1, 1)
		},
	}
	return cfg_pos[prof] or cfg_pos[4]
end

-- 获取本国信息
function CampData:GetCampItemList(role_vo)
	local vo = role_vo or GameVoManager.Instance:GetMainRoleVo()
	local item_list = {}
	local info = self:GetCampInfo()
	for k, v in pairs(info.camp_item_list) do
		if vo.camp == v.camp_type then
			item_list = v
			break
		end
	end

	return item_list
end

-- 修改国号更改冷却时间
function CampData:SetCampNameCoolingTime(protocol)
	self.camp_name_cooling_time = protocol
end

function CampData:GetCampNameCoolingTime()
	return self.camp_name_cooling_time or 0
end

-- 根据国家等级获取配置
function CampData:GetCampLevelCfgByCampLevel(level)
	return self.camp_level_cfg[level] or {}
end

function CampData:SetQueryCampBuildReport(protocol)
	self.report_list = protocol.report_list
end

function CampData:GetQueryCampBuildReport()
	return self.report_list or {}
end

function CampData:GetCampLevelExpAdd(reason)
	return self.camp_level_exp_add[reason] or {}
end

function CampData:GetCampNameList()
	local name_list = {}
	local info = self:GetCampInfo()
	for k, v in pairs(info.camp_item_list) do
		table.insert(name_list, v.camp_name)
	end

	return name_list
end

--通过国家编号获取国家信息
function CampData:GetCampInfoByCampType(camp_type)
	local camp_item_list = self:GetCampInfo().camp_item_list
	local item_list = nil
	for k, v in pairs(camp_item_list) do
		if camp_type == v.camp_type then
			item_list = v
			break
		end
	end
	return item_list
end

-- 通过国家编号获取国家名字
function CampData:GetCampNameByCampType(camp_type, is_bracket, is_chinese, is_two_char)
	local camp_info = self:GetCampInfoByCampType(camp_type)
	if camp_info == nil then
		return ""
	end
	local camp_name = camp_info.camp_name ~= "" and camp_info.camp_name or Language.Common.ScnenCampNameAbbr[camp_type]
	local bracket = is_chinese and Language.Common.CampNameAddition[1] or Language.Common.CampNameAddition[2]
	camp_name = (is_bracket and bracket[1] or "") .. camp_name .. (is_two_char and Language.Common.CampNameAddition[3] or "") .. (is_bracket and bracket[2] or "")

	return camp_name
end

---------怪物攻城------------------------
function CampData:SetMonsterSiegeFbInfo(protocol)
	self.monster_siege_fb_info = protocol
end

function CampData:GetMonsterSiegeFbInfo(str)
	if self.monster_siege_fb_info == nil then
		return nil
	end

	return self.monster_siege_fb_info[str]
end

function CampData:GetMonsterSiegeFbAllInfo()
	return self.monster_siege_fb_info
end

function CampData:SetMonsterSiegeInfo(protocol)
	-- self.monster_siege_camp = protocol.monster_siege_camp
	-- self.monster_siege_tower_build_flag = protocol.monster_siege_tower_build_flag
	-- self.monster_siege_is_pass = protocol.is_pass
	self.monster_siege_info = protocol
end

function CampData:GetMonsterSiegeInfo()
	return self.monster_siege_info
end

function CampData:GetMonsterSiegeIsPass()
	return self.monster_siege_is_pas
end

function CampData:GetMonsterSiegeCamp()
	return self.monster_siege_camp or 0
end

function CampData:GetMonsterSiegeTowerBuildFlag()
	return self.monster_siege_tower_build_flag or 0
end

function CampData:GetTowerCfgBySeq(seq)
	if seq == nil then
		return {}
	end

	return self.camp_tower_cfg[seq] or {}
end

function CampData:GetTowerId()
	local tab = {}

	for k,v in pairs(self.camp_tower_cfg) do
		if v ~= nil then
			tab[v.monster_id] = v.monster_id
		end
	end

	return tab
end

function CampData:CheckIsChangeCampItem(item_id)
	if self.change_camp_cfg == nil then
		self.change_camp_cfg = {}

		local cfg = ConfigManager.Instance:GetAutoConfig("campconfg_auto").other[1]
		if cfg ~= nil then
			local data = cfg.change_camp_need_limit_item_weak
			if data ~= nil and next(data) ~= nil then
				self.change_camp_cfg[data.item_id] = data
			end

			data = cfg.change_camp_need_item_weak
			if data ~= nil and next(data) ~= nil then
				self.change_camp_cfg[data.item_id] = data
			end

			data = cfg.change_camp_need_limit_item_stronge
			if data ~= nil and next(data) ~= nil then
				self.change_camp_cfg[data.item_id] = data
			end

			data = cfg.change_camp_need_item_stronge
			if data ~= nil and next(data) ~= nil then
				self.change_camp_cfg[data.item_id] = data
			end
		end	
	end

	if item_id == nil then
		return false, nil
	end

	local item_data = self.change_camp_cfg[item_id]
	return item_data ~= nil, item_data
end

function CampData:SetCampScoreInfo(protocol)
	self.camp_score_list.camp_list = protocol.camp_list

	local my_score = 0
	local max_index = nil
	local check_score = nil
	local role_vo = GameVoManager.Instance:GetMainRoleVo()
	for k,v in pairs(self.camp_score_list.camp_list) do
		if v ~= nil then
			if v.camp == role_vo.camp then
				my_score = v.score
			end
			
			if max_index == nil then
				max_index = v.camp
				check_score = v.score
			else
				if check_score < v.score then
					max_index = v.camp
					check_score = v.score
				end
			end
		end
	end

	for k,v in pairs(self.camp_score_list.camp_list) do
		if v ~= nil then
			v.consume = v.score < check_score and 0 or 1
			if max_index == nil or max_index ~= v.camp then
				v.is_max = false
			else
				v.is_max = true
			end
		end
	end
end

function CampData:GetCampScoreInfoByCamp(camp)
	local score_info = {}
	if self.camp_score_list.camp_list == nil or camp == nil then
		return score_info
	end

	for k,v in pairs(self.camp_score_list.camp_list) do
		if v ~= nil and v.camp == camp then
			score_info = v
			break
		end
	end

	return score_info
end

function CampData:SetCampOtherInfo(protocol)
	MainUICtrl.Instance:ChangeMainUiChatIconList(string.lower(ViewName.CampBuilding), MainUIViewChat.IconList.IS_CAMP_BUILDING, true)
end

function CampData:GetMonsterSenceCfg()
	local sense_id = self:GetCampOtherCfg().monster_siege_scene_id or 3001
	local i = 1
	local item_list = {}
	local t = Split(self:GetCampOtherCfg().monster_siege_bother_target_pos, "|") or {}
	for k,v in pairs(t) do
		item_list[i] = tonumber(v)
		i = i + 1
	end
	return sense_id,item_list
end


-------------------国家同盟-------------------
function CampData:SetCampAllianceRankList(protocol)
	self.camp_team_info = protocol.rank_list
end

function CampData:GetCampAllianceRankList()
	return self.camp_team_info
end

function CampData:SetYesterdayQiyunRankInfo(protocol)
	self.camp_team_reward_info.login_reward = protocol.yesterday_qiyun_rank_is_fetch_login_reward
	self.camp_team_reward_info.zhanshi_reward = protocol.yesterday_qiyun_rank_is_fetch_zhanshi_reward
	self.camp_team_reward_info.zhanshi_count = protocol.war_even_complete_count
end

function CampData:GetYesterdayQiyunRankInfo()
	return self.camp_team_reward_info
end

-- 根据气运排序
function CampData:GetSortCampQiYunRankList()
	local info = self:GetCampAllianceRankList()
	if info then
		SortTools.SortDesc(info, "qiyun_value")
	end
	return info
end

function CampData:GetQiYunRankRewardByCamp()
	local main_role_vo = PlayerData.Instance:GetRoleVo()
	local info = self:GetSortCampQiYunRankList()
	local camp_cfg = self:GetCampCfg()
	local rank = 0
	if camp_cfg and info and camp_cfg.qiyun_rank_reward and main_role_vo then
		for i = 1, 3 do
			if info[i] and info[i].camp_type == main_role_vo.camp then
				rank = i
				break
			end
		end
		return camp_cfg.qiyun_rank_reward[rank]
	end
	return nil
end

function CampData:GetCampTeamSoldierList(camp, team_camp)
	local info = CampData.Instance:GetCampAllianceRankList()
	local rank_list = {}
	local other_rank_list = {}
	if info then
		for i = 1, 3 do
			if info[i] and info[i].rank_list then
				for j = 1, 5 do
					if info[i].rank_list[j] and info[i].rank_list[j].level > 0 and info[i].rank_list[j].kill_role_num > 0 then
						info[i].rank_list[j].camp_type = info[i].camp_type or 0
						if info[i].rank_list[j].camp_type == camp or info[i].rank_list[j].camp_type == team_camp then
							table.insert(rank_list, info[i].rank_list[j])
						else
							table.insert(other_rank_list, info[i].rank_list[j])
						end
					end
				end
			end
		end
	end
	SortTools.SortDesc(rank_list, "kill_role_num")
	SortTools.SortDesc(other_rank_list, "kill_role_num")
	return rank_list, other_rank_list
end

-- 国家同盟红点
function CampData:GetCampTeamRemind()
	if not OpenFunData.Instance:CheckIsHide("camp_team") then
		return 0
	end
	local data = self:GetYesterdayQiyunRankInfo()
	local other_cfg = self:GetCampOtherCfg()
	if data and other_cfg then
		if data.zhanshi_reward == 0 and data.zhanshi_count >= other_cfg.need_zhanshi_count then
			return 1
		end
		if data.login_reward == 0 then
			return 1
		end
	end
	return 0
end