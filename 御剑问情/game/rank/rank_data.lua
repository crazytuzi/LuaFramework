MAX_RANK_COUNT = 13

RANK_KIND = {
	PERSON = 1,										-- 个人排行
	GUILD = 2,										-- 仙盟排行
	TEAM = 3,										-- 队伍排行榜
}
-- ranktag
PERSON_RANK_TYPE =
{
	PERSON_RANK_TYPE_CAPABILITY_ALL = 0,						-- 综合战力榜
	PERSON_RANK_TYPE_LEVEL = 1,									-- 等级榜
	PERSON_RANK_TYPE_EQUIP = 3,									-- 装备战力榜
	PERSON_RANK_TYPE_ALL_CHARM = 4,								-- 魅力总榜
	PERSON_RANK_TYPE_MOUNT = 8,									-- 坐骑战力榜
	PERSON_RANK_TYPE_WING = 11,									-- 羽翼战力榜
	PERSON_RANK_TYPE_RAND_RECHARGE = 19,						-- 充值排行
	PERSON_RANK_TYPE_HALO = 44,									-- 光环战力榜
	PERSON_RANK_TYPE_FIGHT_MOUNT = 52,                 			-- 战骑战力榜
	PERSON_RANK_TYPE_SHENGONG = 45,								-- 神弓战力榜
	PERSON_RANK_TYPE_SHENYI = 46,								-- 神翼战力榜
	PERSON_RANK_TYPE_XIANNV_CAPABILITY = 2,						-- 女神战力榜
	PERSON_RANK_TYPE_CAPABILITY_JINGLING = 48,                  -- 精灵战力榜
	PERSON_RANK_TYPE_EQUIP_STRENGTH_LEVEL = 50,					-- 全身装备强化总等级榜
	PERSON_RANK_TYPE_STONE_TOTAL_LEVEL = 51,					-- 全身宝石总等级榜
	PERSON_RANK_TYPE_WORLD_RIGHT_ANSWER = 53, 					-- 世界题目对题榜
	PERSON_RANK_TYPE_FIGHTING_CHALLENGE = 54,					-- 挖矿里的挑衅排行榜
	PERSON_RANK_TYPE_DAY_CHARM = 55,							-- 每日魅力榜
	PERSON_RANK_TYPE_DAY_QingYuan = 57,							-- 每日情缘榜
	PERSON_RANK_TYPE_FOOTPRINT = 56,							-- 足迹战力榜
	PERSON_RANK_TYPE_BAOBAO = 58,								-- 宝宝
	PERSON_RANK_TYPE_RA_DAY_CHONGZHI_NUM = 42,					-- 随机活动每日充值
	PERSON_RANK_TYPE_RA_DAY_XIAOFEI_NUM = 43,					-- 随机活动每日消费
	PERSON_RANK_TYPE_WAIST = 59,								-- 腰饰
	PERSON_RANK_TYPE_HEAD = 60,									-- 头饰
	PERSON_RANK_TYPE_ARM = 61,									-- 麒麟臂
	PERSON_RANK_TYPE_MASK = 62,									-- 面具
	PERSON_RANK_TYPE_LINGZHU = 64,								-- 灵珠
	PERSON_RANK_TYPE_XIANBAO = 63,								-- 仙宝
	PERSON_RANK_TYPE_LITTLEPET = 65,							-- 小宠物
	PERSON_RANK_TYPE_LINGCHONG = 66,							-- 灵宠
	PERSON_RANK_TYPE_LINGGONG = 67,								-- 灵弓
	PERSON_RANK_TYPE_LINGQI = 68,								-- 灵骑
	PERSON_RANK_TYPE_RA_CHONGZHI_RANK_2 = 71,					-- 充值排行榜2
	PERSON_RANK_TYPE_RA_CONSUME_GOLD_RANK_2 = 72,				-- 消费排行榜2
	PERSON_RANK_TYPE_GOD_TEMPLE = 73,							-- 封神殿排行榜
}

RANK_TAB_TYPE =
{
	ZHANLI = 1,
	LEVEL = 2,
	EQUIP = 3,
	MOUNT = 4,
	WING = 5,
	HALO = 6,
	FIGHT_MOUNT = 7,
	SPIRIT = 8,
	GODDESS = 9,
	SHENGONG = 10,
	SHENYI = 11,
	FORGE = 12,
	BAOSHI = 13,
}

ROLE_MODEL_1 = 1001001
ROLE_MODEL_2 = 1002001
ROLE_MODEL_3 = 1003001
ROLE_MODEL_1 = 1001001
ROLE_MODEL_2 = 1002001
ROLE_MODEL_3 = 1003001

ROLE_MODEL_1_WEAPON = 900100101
ROLE_MODEL_2_WEAPON = 910100101
ROLE_MODEL_3_WEAPON = 920100101
ROLE_MODEL_WING = 8001001

RankData = RankData or BaseClass()

function RankData:__init()
	if RankData.Instance then
		print_error("[RankData] Attemp to create a singleton twice !")
	end
	RankData.Instance = self
	self.last_snapshot_time = 0
	self.rank_type = 0
	self.rank_list = {}
	self.couple_rank_list = {}
	self.user_id = 0
	self.user_name =""
	self.sex = 0
	self.prof = 0
	self.camp = 0
	self.reserved = 0
	self.level = 0
	self.rank_value = 0
	self.world_level = 0
	self.top_user_level = 0
	self.name_list = {}
	self.world_level = 0
	self.top_user_level = 0
	self.check_return_flag = false -- 从角色查看返回排行榜的标记
	self.rank_type_list =
	{
		-- ranktag
		PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_ALL ,			--战力榜
		PERSON_RANK_TYPE.PERSON_RANK_TYPE_LEVEL,					--等级榜
		PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP,					--装备榜
		PERSON_RANK_TYPE.PERSON_RANK_TYPE_MOUNT, 					--坐骑榜
		PERSON_RANK_TYPE.PERSON_RANK_TYPE_WING, 					--羽翼榜
		PERSON_RANK_TYPE.PERSON_RANK_TYPE_HALO, 					--光环榜
		PERSON_RANK_TYPE.PERSON_RANK_TYPE_FOOTPRINT, 				--足迹榜
		PERSON_RANK_TYPE.PERSON_RANK_TYPE_FIGHT_MOUNT,				--战骑榜
		PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_JINGLING, 		--精灵榜（仙宠）
		PERSON_RANK_TYPE.PERSON_RANK_TYPE_XIANNV_CAPABILITY, 		--女神榜（伙伴）
		PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENGONG, 				--神弓榜（光环）
		PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENYI, 					--神翼榜（法阵）
		PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP_STRENGTH_LEVEL,		--强化榜
		PERSON_RANK_TYPE.PERSON_RANK_TYPE_STONE_TOTAL_LEVEL,		--宝石榜
		PERSON_RANK_TYPE.PERSON_RANK_TYPE_WAIST,					--腰饰
		PERSON_RANK_TYPE.PERSON_RANK_TYPE_HEAD,						--头饰
		PERSON_RANK_TYPE.PERSON_RANK_TYPE_ARM,						--麒麟臂
		PERSON_RANK_TYPE.PERSON_RANK_TYPE_MASK,
		PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGZHU,
		PERSON_RANK_TYPE.PERSON_RANK_TYPE_XIANBAO,
		PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGCHONG,
		PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGGONG,
		PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGQI,
	}

	self.charm_rank_type_list =
	{
		PERSON_RANK_TYPE.PERSON_RANK_TYPE_DAY_CHARM,				--魅力总榜
		PERSON_RANK_TYPE.PERSON_RANK_TYPE_WORLD_RIGHT_ANSWER,		--答题排行榜
	}

	self.qingyuan_rank_type_list =
	{
		PERSON_RANK_TYPE.PERSON_RANK_TYPE_DAY_QingYuan,				--情缘
		PERSON_RANK_TYPE.PERSON_RANK_TYPE_BAOBAO,					--宝宝
		PERSON_RANK_TYPE.PERSON_RANK_TYPE_LITTLEPET,				--小宠物
	}

	self.mingren_info_list = {}
	self.mingren_index_flag = {}
	self.mingren_id_list = {}
	self.red_point_flag = true
	self.famous_list = {}
	self.best_rank_list = {}
	RemindManager.Instance:Register(RemindName.Rank, BindTool.Bind(self.GetRemind, self))
end

function RankData:__delete()
	RemindManager.Instance:UnRegister(RemindName.Rank)
	RankData.Instance = nil
	for i,v in pairs(self.name_list) do
		self.name_list[i] = nil
	end
	self.name_list = nil
end

-- 个人排行返回
function RankData:OnGetPersonRankListAck(protocol)
	self.last_snapshot_time = protocol.last_snapshot_time

	self.rank_list[RANK_KIND.PERSON] = self.rank_list[RANK_KIND.PERSON] or {}
	self.rank_list[RANK_KIND.PERSON][protocol.rank_type] = protocol.rank_list

	self.rank_type = protocol.rank_type
	self:SetNameList(protocol.rank_list)
	if self.rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_RA_DAY_CHONGZHI_NUM then
		local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
		if #protocol.rank_list > 0 then
			for k,v in pairs(protocol.rank_list) do
				if v.user_id == role_id then
					KaifuActivityData.Instance:SetRank(k)
					break
				end
			end
		else
			KaifuActivityData.Instance:SetRank(0)
		end
		ViewManager.Instance:FlushView(ViewName.KaifuActivityView)
		for k, v in pairs(protocol.rank_list) do
		--记录头像参数
			AvatarManager.Instance:SetAvatarKey(v.user_id, v.avatar_key_big, v.avatar_key_small)
		end
		KaifuActivityData.Instance:SetDailyChongZhiRank(self.rank_list[RANK_KIND.PERSON][PERSON_RANK_TYPE.PERSON_RANK_TYPE_RA_DAY_CHONGZHI_NUM])
		KaifuActivityCtrl.Instance:FlushKaifuView()
	elseif self.rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_RA_DAY_XIAOFEI_NUM then
		local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
		for k,v in pairs(self.rank_list[RANK_KIND.PERSON][protocol.rank_type]) do
			if v.user_id == role_id then
				KaifuActivityData.Instance:SetRankLevel(k)
			end
		end
		for k, v in pairs(protocol.rank_list) do
		--记录头像参数
			AvatarManager.Instance:SetAvatarKey(v.user_id, v.avatar_key_big, v.avatar_key_small)
		end
		KaifuActivityData.Instance:SetDailyXiaoFeiRank(self.rank_list[RANK_KIND.PERSON][PERSON_RANK_TYPE.PERSON_RANK_TYPE_RA_DAY_XIAOFEI_NUM])
		KaifuActivityCtrl.Instance:FlushKaifuView()
	end

	self:SortRank(RANK_KIND.PERSON, protocol.rank_type)
end

function RankData:OnGetCoupleRankListAck(protocol)
	self.couple_rank_list[protocol.rank_type] = protocol.rank_item_list
end

function RankData:GetCoupleRankList(rank_type)
	-- local test =  function ()
	-- 	self.couple_rank_list[57] = {}
	-- 	for i=1,10 do
	-- 		table.insert(self.couple_rank_list[57], {user_name_1 = "fsf",user_name_2 = "fsf",user_id_1 = 5, user_id_2 = 5, prof_1 = 3, prof_2 = 3, rank_value_1 = i, rank_value_2 = i})
	-- 	end
	-- 	self.couple_rank_list[57][2].user_id_1 = GameVoManager.Instance:GetMainRoleVo().role_id
	-- 	self.couple_rank_list[56] = self.couple_rank_list[57]
	-- end
	-- test()

	return self.couple_rank_list[rank_type]
end

-- 仙盟排行返回
function RankData:OnGetGuildRankListAck(protocol)
	self.rank_list[RANK_KIND.GUILD] = self.rank_list[RANK_KIND.GUILD] or {}
	self.rank_list[RANK_KIND.GUILD][protocol.rank_type] = protocolend.rank_list
end

-- 仙盟排行返回
function RankData:OnGetGuildWarRankListAck(protocol)
	self.guildwar_rank_list = protocol.rank_list
end

function RankData:GetGetGuildWarRankListAck()
	return self.guildwar_rank_list
end

--队伍排行返回
function RankData:OnGetTeamRankListAck(protocol)
	self.rank_list[RANK_KIND.TEAM] = self.rank_list[RANK_KIND.TEAM] or {}
	self.rank_list[RANK_KIND.TEAM][protocol.rank_type] = protocolend.rank_list
end

function RankData:SetNameList(data)
	for i,v in pairs(data) do
		self.name_list[i] = {user_name,user_id}
		self.name_list[i].user_name = data[i].user_name
		self.name_list[i].user_id = data[i].user_id
	end
end

function RankData:GetNameList()
	return self.name_list
end

function RankData:GetRankType()
	return self.rank_type
end

function RankData:GetIdByIndex(index)
	return self.mingren_id_list[index]
end

function RankData:SetMingrenData(data)
	local remove_key = 0
	local flag = false
	for k,v in pairs(self.mingren_id_list) do
		if v == data.role_id then
			self.mingren_info_list[k] = TableCopy(data)
			remove_key = k
			flag = true
			-- Scene.Instance:FlushMingRenList()
			break
		end
	end

	self.mingren_id_list[remove_key] = nil
	return flag
end

function RankData:GetMingrenData()
	return self.mingren_info_list
end

function RankData:SetFamousList(famous_list)
	self.famous_list = famous_list
	if self.red_point_flag == true then
		RemindManager.Instance:Fire(RemindName.Rank)
	end
end

function RankData:SetMingrenIdList(famous_list)
	for k, v in ipairs(famous_list) do
		self.mingren_id_list[k] = v
	end
end

function RankData:GetRemind()
	return self:GetRedPoint() and 1 or 0
end

function RankData:ClearMingrenData()
	self.mingren_info_list = {}
	self.mingren_index_flag = {}
end

function RankData:SetRedPointFlag(flag)
	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	local get_time = UnityEngine.PlayerPrefs.GetInt("rank_mingren_redpoint_time"..role_id, -1)
	local s_time = TimeCtrl.Instance:GetServerTime()
	UnityEngine.PlayerPrefs.SetInt("rank_mingren_redpoint_time"..role_id, s_time)
	-- self.red_point_flag = flag
end

function RankData:GetRedPointFlag()
	local level = GameVoManager.Instance:GetMainRoleVo().level
	if level < GameEnum.MINGREN_REMINDER_LEVEL then
		self.red_point_flag = false
		return false
	end

	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	local s_time = TimeCtrl.Instance:GetServerTime()
	local get_time = UnityEngine.PlayerPrefs.GetInt("rank_mingren_redpoint_time"..role_id, -1)

	if get_time == -1 then
		self.red_point_flag = true
		return self.red_point_flag
	end
	local get_time_table = os.date('*t', get_time)
	local sever_time_table = os.date('*t', s_time)

	if sever_time_table.day - get_time_table.day > 0
		or sever_time_table.month - get_time_table.month > 0
		or sever_time_table.year - get_time_table.year > 0 then

		self.red_point_flag = true
		return self.red_point_flag
	end

	self.red_point_flag = false
	return false
end

--顶级玩家信息返回
function RankData:OnGetPersonRankTopUserAck(protocol)
	self.rank_type = protocol.rank_type
	self.user_id = protocol.user_id
	self.user_name = protocol.user_name
	self.sex = protocol.sex
	self.prof = protocol.prof
	self.camp = protocol.camp
	self.reserved = protocol.reserved
	self.level = protocol.level
	self.rank_value = protocol.rank_value

	--记录顶级玩家信息
	local rank_info = {}
	rank_info.rank_type = self.rank_type
	rank_info.user_id = self.user_id
	rank_info.user_name = self.user_name
	rank_info.sex = self.sex
	rank_info.prof = self.prof
	rank_info.camp = self.camp
	rank_info.level = self.level
	rank_info.rank_value = self.rank_value
	self.best_rank_list[self.rank_type] = rank_info
end

function RankData:GetBestRankInfo(rank_type)
	rank_type = rank_type or 0
	return self.best_rank_list[rank_type]
end

--世界等级信息返回
function RankData:OnGetWorldLevelAck(protocol)
	self.world_level = protocol.world_level
	self.top_user_level = protocol.top_user_level
end

function RankData:GetWordLevel()
	return self.world_level
end

function RankData:GetRankList(rank_kind, rank_type)
	if self.rank_list[rank_kind] and self.rank_list[rank_kind][rank_type] then
		return self.rank_list[rank_kind][rank_type]
	end
	return {}
end

function RankData:MyRankOverTen()
	if self.rank_list[RANK_KIND.PERSON] and self.rank_list[RANK_KIND.PERSON][0] then
		local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
		local list = self.rank_list[RANK_KIND.PERSON][0]
		for i = 1, 10 do
			if list[i] and list[i].user_id == role_id then
				TipsCtrl.Instance:SendMyRankInfo(i)
				return true
			end
		end
	end

	return false
end

--获取目前需要的排行榜类型
function RankData:GetRankTypeList()
	return self.rank_type_list
end

function RankData:GetCharmRankTypeList()
	return self.charm_rank_type_list
end

function RankData:GetMyInfoList()
	local my_rank = -1
	for k,v in pairs(self:GetRankList(RANK_KIND.PERSON, PERSON_RANK_TYPE.PERSON_RANK_TYPE_FIGHTING_CHALLENGE)) do
		if GameVoManager.Instance:GetMainRoleVo().role_id == v.user_id then
			return k
		end
	end
	return my_rank
end

function RankData:SortRank(rank_kind, rank_type)
	function sortfun_capability(a, b)  --战力
		if a.rank_value > b.rank_value then
			return true
		elseif a.rank_value == b.rank_value then
			return a.level > b.level
		else
			return false
		end
	end

	function sortfun_level(a, b)  --等级
		if a.level > b.level then
			return true
		elseif a.level == b.level then
			return a.exp > b.exp
		else
			return false
		end
	end

	function sortfun_other(a, b) --其他
		if a.rank_value > b.rank_value then
			return true
		else
			return false
		end
	end

	function sortfun_advance(a, b) --坐骑
		if a.flexible_int > b.flexible_int then
			return true
		elseif  a.flexible_int == b.flexible_int then
			return a.rank_value > b.rank_value
		else
			return false
		end
	end


	if rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LEVEL then
		table.sort(self.rank_list[rank_kind][rank_type], sortfun_level)
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_DAY_CHARM then
		table.sort(self.rank_list[rank_kind][rank_type], sortfun_other)
	else
		table.sort(self.rank_list[rank_kind][rank_type], sortfun_capability)
	end
end

function RankData:GetRankTitleDes(rank_type)
	local title = ""
	local img = ""
	-- ranktag
	if rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_ALL
		or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP
		or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_XIANNV_CAPABILITY
		or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_MOUNT
		or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_WING
		or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_HALO
		or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_FIGHT_MOUNT
		or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENGONG
		or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENYI
		or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_FOOTPRINT
		or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_JINGLING
		or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_DAY_QingYuan
		or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_BAOBAO
		or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_ARM
		or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_HEAD
		or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_WAIST
		or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_MASK
		or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_XIANBAO
		or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGZHU
		or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LITTLEPET
		or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGQI
		or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGGONG
		or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGCHONG then
		title = Language.Rank.RankTitleName[1]
		img = "capabillity"
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LEVEL
		or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP_STRENGTH_LEVEL
		or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_STONE_TOTAL_LEVEL then
		title = Language.Rank.RankTitleName[2]
		img = "level"
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_DAY_CHARM then
		title = Language.Rank.RankTitleName[3]
		img = "charm"
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_WORLD_RIGHT_ANSWER then
		title = Language.Rank.RankTitleName[5]
		img = "currentNum"
	else
		title = Language.Rank.RankTitleName[4]
		img = "levelnum"
	end
	return title,img
end



function RankData:GetRankValue(rank_kind, rank_type, rank)
	if not (self.rank_list[rank_kind] and self.rank_list[rank_kind][rank_type] and self.rank_list[rank_kind][rank_type][rank]) then
		return
	end
	-- ranktag
	if rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_ALL
		and rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_LEVEL
		and rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP
		and rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_DAY_CHARM
		and rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_XIANNV_CAPABILITY
		and rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_JINGLING
		and rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP_STRENGTH_LEVEL
		and rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_STONE_TOTAL_LEVEL
		and rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_WORLD_RIGHT_ANSWER
		and rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_WAIST
		and rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_HEAD
		and rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_ARM
		and rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGZHU
		and rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_MASK
		and rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_XIANBAO
		and rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGCHONG
		and rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGGONG
		and rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGQI then
		if self.rank_list[rank_kind][rank_type][rank].flexible_int == 0 then
			return Language.Rank.NotActive
		end
		if MountData.Instance:GetGradeCfg(self.rank_list[rank_kind][rank_type][rank].flexible_int)[self.rank_list[rank_kind][rank_type][rank].flexible_int] == nil then
			return Language.Rank.NotActive
		else
			return self.rank_list[rank_kind][rank_type][rank].rank_value
			-- return MountData.Instance:GetGradeCfg(self.rank_list[rank_kind][rank_type][rank].flexible_int)[self.rank_list[rank_kind][rank_type][rank].flexible_int].gradename
		end
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LEVEL then
		local level = PlayerData.GetLevelString(self.rank_list[rank_kind][rank_type][rank].rank_value)
		return level
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP_STRENGTH_LEVEL or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_STONE_TOTAL_LEVEL then
		return self.rank_list[rank_kind][rank_type][rank].rank_value
	end
	return self.rank_list[rank_kind][rank_type][rank].rank_value
end

function RankData:GetCoupleRankValue(rank_type, rank)
	if not (self.couple_rank_list[rank_type] and self.couple_rank_list[rank_type][rank]) then
		return
	end
	-- local test =  function ()
	-- 	self.couple_rank_list[57] = {}
	-- 	for i=1,10 do
	-- 		table.insert(self.couple_rank_list[57], {user_name_1 = "fsf",user_name_2 = "fsf",user_id_1 = 5, user_id_2 = 5, prof_1 = 3, prof_2 = 3, rank_value_1 = i, rank_value_2 = i})
	-- 	end
	-- 	self.couple_rank_list[57][2].user_id_1 = GameVoManager.Instance:GetMainRoleVo().role_id
	-- 	self.couple_rank_list[56] = self.couple_rank_list[57]
	-- end
	local data = self.couple_rank_list[rank_type][rank]
	return data.rank_value_1 + data.rank_value_2
end

function RankData:GetGradeNumName(grade)
	if grade == 0 then
		return Language.Rank.NotActive
	end
	return MountData.Instance:GetGradeCfg(grade)[grade].gradename
end

function RankData:GetTabName(rank_type)
	local title = ""
	if Language.Rank.RankTabName[rank_type] then
		title = Language.Rank.RankTabName[rank_type]
	end
	return title
end

function RankData:GetModelId(prof, sex)
	local job_cfg = ConfigManager.Instance:GetAutoConfig("rolezhuansheng_auto").job
	local modle_list = {}
	for k,v in pairs(job_cfg) do
		if v.id == prof then
			modle_list.model = v["model" .. sex]
			modle_list.right_weapon = v["right_weapon" .. sex]
			modle_list.left_weapon = v["left_weapon" .. sex]
			return modle_list
		end

	end
end

function RankData:GetMyPowerValue(rank_type)
	local helper_data = HelperData.Instance
	local power = ""
	if rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_ALL then
		power = GameVoManager.Instance:GetMainRoleVo().capability
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LEVEL then
		local level = GameVoManager.Instance:GetMainRoleVo().level
		power = PlayerData.GetLevelString(level)
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP then
		power = PlayerData.Instance:GetCapByType(CAPABILITY_TYPE.CAPABILITY_TYPE_EQUIPMENT)  -- 装备
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_DAY_CHARM then
		power = GameVoManager.Instance:GetMainRoleVo().day_charm
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_MOUNT then
		power = PlayerData.Instance:GetCapByType(CAPABILITY_TYPE.CAPABILITY_TYPE_MOUNT)
		local attr = MountData.Instance:GetMountAttrSum()
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_WING then
		power = PlayerData.Instance:GetCapByType(CAPABILITY_TYPE.CAPABILITY_TYPE_WING)
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_HALO then
		local attr = HaloData.Instance:GetHaloAttrSum()
		if attr then
			local capability = CommonDataManager.GetCapabilityCalculation(attr)
			power = capability
		else
			power = Language.Rank.NotActive
		end
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENGONG then
		local attr = ShengongData.Instance:GetShengongAttrSum()
		if attr then
			local capability = CommonDataManager.GetCapabilityCalculation(attr)
			power = capability
		else
			power = Language.Rank.NotActive
		end
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENYI then
		local attr = ShenyiData.Instance:GetShenyiAttrSum()
		if attr then
			local capability = CommonDataManager.GetCapabilityCalculation(attr)
			power = capability
		else
			power = Language.Rank.NotActive
		end
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_FIGHT_MOUNT then
		power = PlayerData.Instance:GetCapByType(CAPABILITY_TYPE.CAPABILITY_TYPE_FIGHT_MOUNT)
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_XIANNV_CAPABILITY then   				 -- 伙伴
		power = PlayerData.Instance:GetCapByType(CAPABILITY_TYPE.CAPABILITY_TYPE_XIANNV)
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP_STRENGTH_LEVEL then
		power = ForgeData.Instance:GetTotalStrengthLevel()
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_STONE_TOTAL_LEVEL then
		local level = ForgeData.Instance:GetTotalGemCfg()
		power = level
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_WORLD_RIGHT_ANSWER then
		power = WorldQuestionData.Instance:GetMyQustionNum(WORLD_GUILD_QUESTION_TYPE.WORLD)
	elseif
		rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_JINGLING then    				 -- 精灵
		power = PlayerData.Instance:GetCapByType(CAPABILITY_TYPE.CAPABILITY_TYPE_JINGLING)
	elseif
		rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_FOOTPRINT then    				         -- 足迹
		power = PlayerData.Instance:GetCapByType(CAPABILITY_TYPE.CAPABILITY_TYPE_FOOTPRINT)
	elseif
		rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_DAY_QingYuan then
		power = PlayerData.Instance:GetCapByType(CAPABILITY_TYPE.CAPABILITY_TYPE_QINGYUAN)
		local power_2 = PlayerData.Instance:GetCapByType(CAPABILITY_TYPE.CAPABILITY_TYPE_LOVE_TREE)
		if power_2 == nil then
			power_2 = 0
		end
		if power == nil then
			power = 0
		end
		power = power + power_2
	elseif
		rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_BAOBAO then
		power = PlayerData.Instance:GetCapByType(CAPABILITY_TYPE.CAPABILITY_TYPE_BABY)
		if power == nil then
			power = 0
		end
	elseif
		rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_WAIST then
		power = PlayerData.Instance:GetCapByType(CAPABILITY_TYPE.CAPABILITY_TYPE_YAOSHI)
	elseif
		rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_HEAD then
		power = PlayerData.Instance:GetCapByType(CAPABILITY_TYPE.CAPABILITY_TYPE_TOUSHI)
	elseif
		rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_ARM then
		power = PlayerData.Instance:GetCapByType(CAPABILITY_TYPE.CAPABILITY_TYPE_QILINBI)
	elseif
		rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_MASK then
		power = PlayerData.Instance:GetCapByType(CAPABILITY_TYPE.CAPABILITY_TYPE_MASK)
	elseif
		rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_XIANBAO then
		power = PlayerData.Instance:GetCapByType(CAPABILITY_TYPE.CAPABILITY_TYPE_XIANBAO)
	elseif
		rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGZHU then
		power = PlayerData.Instance:GetCapByType(CAPABILITY_TYPE.CAPABILITY_TYPE_LINGZHU)
	elseif
		rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGGONG then
		power = PlayerData.Instance:GetCapByType(CAPABILITY_TYPE.CAPABILITY_TYPE_LINGGONG)
	elseif
		rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGCHONG then
		power = PlayerData.Instance:GetCapByType(CAPABILITY_TYPE.CAPABILITY_TYPE_LINGCHONG)
	elseif
		rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGQI then
		power = PlayerData.Instance:GetCapByType(CAPABILITY_TYPE.CAPABILITY_TYPE_LINGQI)
		-- ranktag
	elseif
		-- 小宠物的当前战力读自己的总战力
		rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LITTLEPET then
		power = LittlePetData.Instance:GetAllFightPower()
	end
	return power
end

function RankData:GetJingLingPower(id, level)
	local power = 0
	local attr = SpiritData.Instance:GetSpiritUpLevelCfg(id, level)
	if attr then
		power = CommonDataManager.GetCapability(attr)
	end
	return power
end

function RankData:GetRedPoint()
	local temp_list = {}
	for k,v in pairs(self.famous_list) do
		if v > 0 then
			table.insert(temp_list, v)
		end
	end
	return #temp_list < 6 and self:GetRedPointFlag()
end

function RankData:CheckInRank(role_id)
	for k,v in pairs(self.rank_list) do
		if v.user_id == role_id then
			return true, k
		end
	end
	return false
end

--获得respath name
function RankData:GetRankResName(rank_type)
	if rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_DAY_CHARM then
		return "meili"
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_WORLD_RIGHT_ANSWER then
		return "answer"
	end
	return ""
end

function RankData:SetRankToggleType(toggle_type)
	self.rank_toggle_type = toggle_type
end

function RankData:GetRankToggleType()
	return self.rank_toggle_type or 0
end

function RankData:GetQingYuanRankTypeList()
	return self.qingyuan_rank_type_list
end
