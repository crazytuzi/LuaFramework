GuildData = GuildData or BaseClass()

CREATE_GUILD_LIMIT_LEVEL = 80
GUILD_SKILL_MAX_LEVEL = 100
MAX_GUILD_BOX_COUNT = 8
GUILD_SKILL_COUNT = 4
GUILD_MAX_EXCHANGE_ITEM_COUNT = 30

ADD_GUILD_EXP_TYPE = {
	ADD_GUILD_EXP_TYPE_INVALID = 0,
	ADD_GUILD_EXP_TYPE_GOLD = 1,                            -- 元宝捐献
	ADD_GUILD_EXP_TYPE_COIN = 2,                            -- 铜币捐献
	ADD_GUILD_EXP_TYPE_MAX = 3,
}

GUILD_STORGE_OPERATE =
{
	GUILD_STORGE_OPERATE_PUTON_ITEM = 1,            -- 放入
	GUILD_STORGE_OPERATE_TAKE_ITEM = 2,             -- 取出
	GUILD_STORGE_OPERATE_REQ_INFO = 3,              -- 查询
	GUILD_STORGE_OPERATE_DISCARD_ITEM = 4,          -- 销毁
}

GUILD_STORGE_ONE_KEY_OPERATE =
{
	GUILD_STORGE_OPERATE_PUTON_ITEM_ONE_KEY = 1,    -- 批量放入
	GUILD_STORGE_OPERATE_DISCARD_ITEM_ONE_KEY = 2,  -- 批量销毁
}

GHILD_BOSS_OPER_TYPR = {
	GUILD_BOSS_UPLEVEL = 0,
	GUILD_BOSS_CALL = 1,
	GUILD_BOSS_INFO_REQ = 2,
}

GHILD_OPERA_TYPE = {
	OPERA_TYPE_INVALID = 0,
	OPERA_TYPE_APPLY_SET = 1,
	OPERA_TYPE_CALL_IN = 2,
}

Guild_PANEL = {
	information = 1,
	member = 2,
	box = 3,
	altar = 4,
	totem = 5,
	territory = 6,
	list = 7,
	boss = 8,
}

GUILD_BOX_OPERATE_TYPE =
{
	GBOT_QUERY_SELF = 0,
	GBOT_UPLEVEL = 1,
	GBOT_OPEN = 2,
	GBOT_FETCH = 3,
	GBOT_QUERY_NEED_ASSIST = 4,
	GBOT_ASSIST = 5,
	GBOT_CLEAN_ASSIST_CD = 6,
}

GUILD_STORGE_LEVEL =
{
	480, 450, 420, 390, 1000
}

-- 领地站奖励
GUID_TERRITORY_WELF_OPERATE_TYPE =
{
	GTW_FETCH_REWARD = 0,           -- 普通奖励
	GTW_FETCH_EXTRA_REWARD = 1,     -- 会长奖励
}

-- 扩展成员请求
GUILD_EXTEND_OPERATE_TYPE =
{
	EXTEND_MEMBER = 0,              -- 扩展成员
	MEMBER_MAX_COUNT_INFO = 1,      -- 请求最大成员信息
}

GuildData.SinginRewardState = {
	CanNotGetReward = 1,    -- 不能领取
	CanGetReward = 2,       -- 可以领取
	HasGetReward = 3,       -- 已领取
}

GUILD_MAX_BOX_LEVEL = 4

GuildData.HasOpenGuild = false

GuildData.SigninRewardNum = 3

function GuildData:__init()
	if GuildData.Instance then
		print_error("[GuildData] Attempt to create singleton twice!")
		return
	end
	GuildData.Instance = self
	self.guild_id = -1

	self.guild_skill_config = nil

	self.role_info = {skill_level_list = {}, territorywar_reward_flag = {}, daily_guild_gongxian = 0}

	self.guild_total_gongxian = 0

	self.red_point_list = {}
	self.member_num_list = {}
	self.guild_info_list = {}

	self.box_info = {
		uplevel_count = 0,
		assist_count = 0,
		assist_cd_end_time = 0,
		info_list = {},
	}

	self.assist_info = {
		box_count = 0,
		info_list = {},
	}

	self.boss_info = {
		boss_normal_call_count = 0,
		boss_super_call_count = 0,
		boss_level = 0,
		boss_exp = 0,
		boss_super_call_uid = 0,
		boss_super_call_name = "",
	}

	self.signin_data = {
		is_signin_today = 999,                      -- 今天是否已签到
		signin_count_month = 0,                     -- 月签到次数
		guild_signin_fetch_reward_flag = 0,         -- 公会总签到
		guild_signin_count_today = 0,               -- 公会总签到次
	}

	self.guild_post = {
		"PuTong",
		"ZhangLao",
		"FuMengZhu",
		"MengZhu",
		"JingYing",
		"HuFa"
	}
	self.guild_storge_info = {storge_item_list = {}}
	self.fu_li_count = 0
	self.last_leave_guild_time = 0
	self.is_can_assist = false
	self.is_guild_box_start = false
	self.other_guild_info = {}
	self.territory_rank = 0

	self.gong_xian_config = {}
	self.territory_welf_config = nil
	local guild_config = self:GetGuildConfig()
	if guild_config then
		self.territory_welf_config = guild_config.territory_welf_config
		if self.territory_welf_config then
			self.gong_xian_config[1] = self.territory_welf_config[1].banggong_one_limit
			self.gong_xian_config[2] = self.territory_welf_config[1].banggong_two_limit
			self.gong_xian_config[3] = self.territory_welf_config[1].banggong_three_limit
			self.gong_xian_config[4] = self.territory_welf_config[1].banggong_four_limit
		end
	end

	self.bon_fire_openstatus = 0
	self.mi_jing_openstatus = 0
	self.reward_seq = 0

	self.boss_activity_info = {
		boss_id = 0,
		boss_level = 0,
		boss_obj_id = 0,
		is_surper_boss = 0,
		totem_exp = 0,
	}
	self.last_callin_time = -10

	self.max_skill_level = 0
	local other_config = self:GetOtherConfig()
	if other_config then
		self.max_skill_level = other_config.max_skill_level or 0
	end

	self.daily_use_guild_relive_times = 0
	self.daily_boss_redbag_reward_fetch_flag = 0
	self.day_richang_task = 0

	RemindManager.Instance:Register(RemindName.NoGuild, BindTool.Bind(self.GetNoGuildRemind, self))
	self.event_list = {}
	self.add_guild_exp_type_coin = 0
	self.add_guild_exp_type_gold = 0

	RemindManager.Instance:Register(RemindName.GuildRoleInfoDonate, BindTool.Bind(self.GetGuildNewRemindId, self))
	RemindManager.Instance:Register(RemindName.GuildOperation, BindTool.Bind(self.GetOperationRemindId, self))
	RemindManager.Instance:Register(RemindName.GuildRoleSkill, BindTool.Bind(self.GetGuildRoleSkill, self))
	RemindManager.Instance:Register(RemindName.GuildTabBoss, BindTool.Bind(self.GetGuildTabBoss, self))
	RemindManager.Instance:Register(RemindName.GuildTabBox, BindTool.Bind(self.GetGuildTabBox, self))
	RemindManager.Instance:Register(RemindName.GuildTabBoxWaBao, BindTool.Bind(self.GetGuildTabBoxWaBao, self))
	RemindManager.Instance:Register(RemindName.GuildTabBoxXieZu, BindTool.Bind(self.GetGuildTabBoxXieZu, self))
	RemindManager.Instance:Register(RemindName.GuildDonate, BindTool.Bind(self.GetGuildDonate, self))
	RemindManager.Instance:Register(RemindName.SignIn, BindTool.Bind(self.GetSigninRedPoint, self))

	self.event_list = {}
end

function GuildData:__delete()
	RemindManager.Instance:UnRegister(RemindName.NoGuild)
	RemindManager.Instance:UnRegister(RemindName.GuildRoleInfoDonate)
	RemindManager.Instance:UnRegister(RemindName.GuildOperation)
	RemindManager.Instance:UnRegister(RemindName.GuildRoleSkill)
	RemindManager.Instance:UnRegister(RemindName.GuildTabBoss)
	RemindManager.Instance:UnRegister(RemindName.GuildTabBox)
	RemindManager.Instance:UnRegister(RemindName.GuildTabBoxWaBao)
	RemindManager.Instance:UnRegister(RemindName.GuildTabBoxXieZu)
	RemindManager.Instance:UnRegister(RemindName.GuildDonate)
	RemindManager.Instance:UnRegister(RemindName.SignIn)
	GuildData.Instance = nil
end

GuildDataConst = {
	GUILDVO = {                                                     -- 公会信息
		guild_id = 0,
		guild_name = "",
		guild_post = 0,
		guild_level = 0,
		guild_exp = 10,
		guild_max_exp = 100,
		guild_totem_level = 0,
		guild_totem_exp = 0,
		cur_member_count = 0,
		max_member_count = 0,
		tuanzhang_uid = 0,
		tuanzhang_name = "",
		create_time = 0,
		camp = 0,
		vip_level = 0,
		applyfor_setup = 0,
		guild_notice = "",
		auto_kickout_setup = 0,
		applyfor_need_capability = 0,
		applyfor_need_level = 0,
		guild_callin_times = 0,
		my_lucky_color = 1,
		active_degree = 0,
		total_capability = 0,
		rank = 0,
		totem_exp_today = 0,
		daily_relive_times = 0,
		daily_kill_boss_times = 0,
	},
	GUILD_INFO_LIST = {                                             -- 所有公会信息列表
		free_create_guild_times = 0,                                -- 免费创建次数
		is_first = 0,
		count = 0,
		list = {},
		is_server_backed = false
	},
	GUILD_MEMBER_LIST = {                                          -- 所有公会成员信息
		count = 0,
		list = {},
	},
	GUILD_POST = {
		CHENG_YUAN = 1,                                                 -- 成员
		ZHANG_LAO = 2,                                                  -- 长老
		FU_TUANGZHANG = 3,                                              -- 副团长
		TUANGZHANG = 4,                                                 -- 团长
		JINGYING = 5,                                                   -- 精英成员
		HUFA = 6,                                                       -- 护法
	},
	GUILD_POST_WEIGHT = {
		1, 4, 5, 6, 2, 3,
	},
	GUILD_APPLYFOR_LIST = {                                         -- 申请加入公会列表请求
		count = 0,
		list = {},
	},
	GUILD_SETTING_MODEL = {                                         -- 设置公会方式
		APPROVAL = 0,
		FORBID = 1,
		AUTOPASS = 2,
	},
	GUILD_NOTIFY_TYPE = {                                           -- 消息通知类型
		INVALID = 0,
		APPLYFOR = 1,                                               -- 有人申请加入
		UNION_APPLYFOR = 2,                                         -- 有军团申请结盟
		UNION_JOIN = 3,                                             -- 加入联盟
		UNION_QUIT = 4,                                             -- 退出联盟
		UNION_REJECT = 5,                                           -- 拒绝联盟
		UNION_APPLYFOR_SUCC = 6,                                    -- 申请军团联盟成功
		MEMBER_ADD = 7,                                             -- 成员加入
		MEMBER_REMOVE = 8,                                          -- 成员退出
		MEMBER_SOS = 9,                                             -- 成员求救
		MEMBER_HUNYAN = 10,                                         -- 成员有婚宴
		REP_PAPER = 11,                                             -- 红包相关
		GUILD_PARTY = 12,                                           -- 仙盟酒会
		GUILD_FB = 13,                                              -- 仙盟副本
		GUILD_LUCKY = 14,                                           -- 仙盟运势
		GUILD_ACTIVE_DEGREE = 15,                                   -- 仙盟活跃度
		GUILD_DONATE = 17,                                          -- 仙盟捐献

		MAX = 99,
	},
}

GUILD_POST_NAME = {
		[GuildDataConst.GUILD_POST.CHENG_YUAN] = Language.Guild.PuTong,
		[GuildDataConst.GUILD_POST.ZHANG_LAO] = Language.Guild.ZhangLao,
		[GuildDataConst.GUILD_POST.FU_TUANGZHANG] = Language.Guild.FuMengZhu,
		[GuildDataConst.GUILD_POST.TUANGZHANG] = Language.Guild.MengZhu,
		[GuildDataConst.GUILD_POST.JINGYING] = Language.Guild.JingYing,
		[GuildDataConst.GUILD_POST.HUFA] = Language.Guild.HuFa,
	}
function GuildData:GetGuildConfig()
	if not self.guild_config then
		self.guild_config = ConfigManager.Instance:GetAutoConfig("guildconfig_auto")
	end
	return self.guild_config
end

-- 获取日常任务抽奖信息
function GuildData:GetGuildShangXiangCfg()
	return ConfigManager.Instance:GetAutoConfig("guildconfig_auto").guild_shangxiang_config
end

function GuildData:SetPlayAni(is_playani)
	self.is_playani = is_playani
end

function GuildData:ISPlayAni()
	if not self.is_playani then return false end
	return self.is_playani
end

-- 获取日常任务抽奖信息
function GuildData:GetRiChangTaskRewardCfg()
	return ConfigManager.Instance:GetAutoConfig("other_config_auto").daily_task_draw
end

-- 设置日常任务抽奖Seq
function GuildData:SetRewardSeq(protocol)
	self.reward_seq = protocol
end

function GuildData:GetRewardSeq()
	return self.reward_seq
end

function GuildData:GetSigninCfg()
	local signin_cfg = ConfigManager.Instance:GetAutoConfig("guild_active_auto").signin_cfg
	return signin_cfg
end

function GuildData:SetSigninData(protocol)
	self.signin_data.is_signin_today = protocol.is_signin_today                                 -- 今天是否已签到
	self.signin_data.signin_count_month = protocol.signin_count_month                           -- 月签到次数
	self.signin_data.guild_signin_fetch_reward_flag = protocol.guild_signin_fetch_reward_flag   -- 公会总签到
	self.signin_data.guild_signin_count_today = protocol.guild_signin_count_today               -- 公会总签到次
end

function GuildData:GetSigninTitleOneCfg(signin_count)
	local signin_title = ConfigManager.Instance:GetAutoConfig("guild_active_auto").signin_title
	for k,v in pairs(signin_title) do
		if signin_count >= v.min and signin_count <= v.max then
			return v
		end
	end

	return {}
end

function GuildData:GetSigninRewardState(reward_index)
	local reward_flag = self.signin_data.guild_signin_fetch_reward_flag
	local flag_t = bit:d2b(reward_flag)
	local has_get_reward = flag_t[#flag_t - reward_index] == 1
	-- 已领取
	if has_get_reward then
		return GuildData.SinginRewardState.HasGetReward
	else
		local signin_cfg = self:GetSigninCfg()[reward_index] or {}
		local need_count = signin_cfg.need_count or 0
		local guild_signin_count_today = self.signin_data.guild_signin_count_today

		-- 可领取
		if guild_signin_count_today >= need_count then
			return GuildData.SinginRewardState.CanGetReward
		end
		-- 不可领
		return GuildData.SinginRewardState.CanNotGetReward
	end
end

-- 当前和上一个签到阶段配置
function GuildData:GetCurAndLastSigninGrade()
	local signin_cfg = self:GetSigninCfg()
	local guild_signin_count_today = self.signin_data.guild_signin_count_today
	for i=0,#signin_cfg do
		local grade_cfg = signin_cfg[i]
		if grade_cfg then
			if guild_signin_count_today < grade_cfg.need_count then
				return grade_cfg, signin_cfg[i - 1] or {}
			end
		end
	end
	return {}, {}
end

function GuildData:GetPersonalSigninReward()
	return ConfigManager.Instance:GetAutoConfig("guild_active_auto").other[1].signin_item[0]
end

function GuildData:GetSigninRemind()
	if IS_ON_CROSSSERVER then
		return 0
	end
	-- 先判断有没有仙盟
	if GameVoManager.Instance:GetMainRoleVo().guild_id <= 0 then
		return 0
	end
	-- 可签到
	if self.signin_data.is_signin_today <= 0 then
		return 1
	end

	-- 公会总签到有可领取奖励
	-- 减1是因为现在可领取奖励客户端少了一个
	for i=1,GuildData.SigninRewardNum - 1 do
		local data_index = i - 1
		local state = self:GetSigninRewardState(data_index)
		if state == GuildData.SinginRewardState.CanGetReward then
			return 1
		end
	end

	return 0
end

function GuildData:GetSigninData()
	return self.signin_data or {}
end

function GuildData:GetSkillConfig(skill_index, skill_level)
	local data = {}
	if not skill_index or not skill_level then return end
	if not self.skill_config then
		self.skill_config = self:GetGuildConfig().skill_config
	end
	-- if self.skill_config then
	--     return self.skill_config[(GUILD_SKILL_MAX_LEVEL + 1) * (skill_index - 1) + skill_level + 1]
	-- end
	for k, v in pairs(self.skill_config) do
		if v.skill_idx == skill_index - 1 and v.level == skill_level then
			data = v
		end
	end

	return data
end

function GuildData:SetGuildRoleGuildInfo(protocol)
	self.role_info = {}
	for k,v in pairs(protocol) do
		self.role_info[k] = v
	end
end

function GuildData:SetGuildInfoList(protocol)
	self.guild_info_list = protocol.info_list
end

function GuildData:GetGuildInfoList()
	return self.guild_info_list
end

function GuildData:SetMemberNumList(protocol)
	self.member_num_list = protocol.member_list
end

function GuildData:GetMemberNumList()
	return self.member_num_list
end

function GuildData:GetGuildRoleGuildInfo()
	return self.role_info
end

function GuildData:GetSkillLevel(index)
	return self.role_info.skill_level_list[index]
end

function GuildData:SetGuildGongxian(gongxian)
	self.role_info.guild_gongxian = gongxian
end

function GuildData:SetGuildTotalGongxian(gongxian)
	self.guild_total_gongxian = gongxian
end

function GuildData:GetGuildGongxian()
	return self.role_info.guild_gongxian or 0
end

function GuildData:GetGuildTotalGongxian()
	return self.guild_total_gongxian
end

function GuildData:GetTotemConfig(level)
	if not self.totem_config then
		self.totem_config = self:GetGuildConfig().totem_config
	end
	local totem_level = level or GuildDataConst.GUILDVO.guild_totem_level
	return self.totem_config[totem_level + 1]
end

-- 得到成员在自己公会中的信息
function GuildData:GetGuildMemberInfo(role_id)
	if self.guild_id < 1 then return end
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local id = role_id or main_role_vo.role_id
	if GuildDataConst.GUILD_MEMBER_LIST.count > 0 then
		for _, v in pairs(GuildDataConst.GUILD_MEMBER_LIST.list) do
			if v.uid == id then
				return v
			end
		end
	end
	return nil
end

-- 得到成员在自己公会中的职位
function GuildData:GetGuildPost(role_id)
	local info = self:GetGuildMemberInfo(role_id)
	if info then
		return info.post
	end
	return -1
end

-- 获得弹劾令牌id
function GuildData:GetGuildDeleteId()
	local config = self:GetOtherConfig()
	if config then
		return config.delate_item_id
	end
end

-- 获得建设物资id
function GuildData:GetGuildJianSheId()
	local config = self:GetOtherConfig()
	if config then
		return config.jianshe_item_id
	end
end

-- 获得建盟令id
function GuildData:GetGuildCreatId()
	local config = self:GetOtherConfig()
	if config then
		return config.create_item_id
	end
end

-- 需要的绑钻数量
function GuildData:GetGuildCreatBindGoldCount()
	local num = 0
	local config = self:GetOtherConfig()
	if config then
		num = config.create_coin_bind
	end
	return num
end

-- 获得扩展公会成员物品ID
function GuildData:GetGuildExtendId()
	local config = self:GetOtherConfig()
	if config then
		return config.extend_member_item
	end
end

-- 获得扩展公会成员物品所需要的数量
function GuildData:GetGuildExtendCountByNum(cur_max_member_count)
	if nil == cur_max_member_count then
		cur_max_member_count = GuildDataConst.GUILDVO.max_member_count or 0
	end
	local need_item_count = 0
	local config = self:GetGuildConfig()
	if config then
		local extend_member_cfg = config.extend_member_cfg
		if extend_member_cfg then
			for i = #extend_member_cfg, 1, -1 do
				local cfg = extend_member_cfg[i]
				if cfg.member_count <= cur_max_member_count then
					need_item_count = cfg.need_item_count
					break
				end
			end
		end
	end
	return need_item_count
end

---------------------------------------------------------------红点提示------------------------------------------------------

-- 是否需要红点标记
function GuildData:GetReminder(index)
	-- self:CalculateRedPoint()
	if index then
		if self.red_point_list[index] == nil then
			return false
		end
		return self.red_point_list[index]
	end
	return self.red_point_list
end

-- function GuildData:CalculateRedPoint()
	-- if self.guild_id < 1 then
	--     self.red_point_list = {}
	--    RemindManager.Instance:Fire(RemindName.Guild)
	--     return
	-- end
	-- local guild_level = GuildDataConst.GUILDVO.guild_level or 0
	-- local post = self:GetGuildPost()
	--  -- 图腾界面
	-- if not OpenFunData.Instance:CheckIsHide("guild_totem") then
	--     self.red_point_list[Guild_PANEL.totem] = false
	-- else
	--     local totem_config = self:GetTotemConfig()
	--     if totem_config then
	--         local exp = totem_config.max_exp
	--         if GuildDataConst.GUILDVO.guild_totem_exp >= exp and self:GetTotemConfig(GuildDataConst.GUILDVO.guild_totem_level + 1) then
	--             if post == GuildDataConst.GUILD_POST.TUANGZHANG or post == GuildDataConst.GUILD_POST.FU_TUANGZHANG then
	--                 self.red_point_list[Guild_PANEL.totem] = true
	--             else
	--                 self.red_point_list[Guild_PANEL.totem] = false
	--             end
	--         else
	--             self.red_point_list[Guild_PANEL.totem] = false
	--         end
	--     else
	--         self.red_point_list[Guild_PANEL.totem] = false
	--     end
	-- end

	-- -- 信息界面
	-- self.red_point_list[Guild_PANEL.information] = false
	-- if OpenFunData.Instance:CheckIsHide("guild_info") then
	--     local card = 0
	--     local card_id = GuildData.Instance:GetGuildJianSheId()
	--     if card_id then
	--         card = ItemData.Instance:GetItemNumInBagById(card_id)
	--     end
	--     if (GuildDataConst.GUILD_APPLYFOR_LIST.count > 0 and (post == GuildDataConst.GUILD_POST.TUANGZHANG or post == GuildDataConst.GUILD_POST.FU_TUANGZHANG))
	--         or (self.fu_li_count < 1 and not self:IsGuildCD()) then
	--         self.red_point_list[Guild_PANEL.information] = true
	--     elseif card > 0 then
	--         self.red_point_list[Guild_PANEL.information] = true
	--     end
	-- end

	-- -- 技能界面
	-- local temp = false
	-- if OpenFunData.Instance:CheckIsHide("guild_altar") then
	--     local gongxian = GuildData.Instance:GetGuildGongxian()
	--     for i = 1, GUILD_SKILL_COUNT do
	--         local skill_level = GuildData.Instance:GetSkillLevel(i) or 0
	--         local config = GuildData.Instance:GetSkillConfig(i, skill_level)
	--         local uplevel_gongxian = config.uplevel_gongxian
	--         local guild_level_limit = config.guild_level_limit or 0
	--         if skill_level < GUILD_SKILL_MAX_LEVEL and gongxian >= uplevel_gongxian and guild_level >= guild_level_limit then
	--             temp = true
	--             break
	--         end
	--     end
	-- end
	-- self.red_point_list[Guild_PANEL.altar] = temp

	-- -- 宝箱界面
	-- self.red_point_list[Guild_PANEL.box] = false
	-- if OpenFunData.Instance:CheckIsHide("guild_box") then
	--     local other_config = self:GetOtherConfig()
	--     local info = self:GetBoxInfo()
	--     local rest_assist_count = 0
	--     if info and other_config then
	--         rest_assist_count = other_config.box_assist_max_count - info.assist_count
	--     end
	--     if self.assist_info.box_count > 0 and rest_assist_count > 0 and self.is_can_assist then
	--         self.red_point_list[Guild_PANEL.box] = true
	--     elseif self:GetRestOpenBoxCount() > 0 and not self:IsGuildCD() and self:IsGuildBoxStart()--[[ and self:IsCanWaQuBox() ]] then
	--         self.red_point_list[Guild_PANEL.box] = true
	--     elseif self.box_info.info_list then
	--         self.red_point_list[Guild_PANEL.box] = false
	--         for k,v in pairs(self.box_info.info_list) do
	--             if v.is_reward == 0 and v.open_time ~= 0 and v.open_time <= TimeCtrl.Instance:GetServerTime() then
	--                 self.red_point_list[Guild_PANEL.box] = true
	--                 break
	--             end
	--         end
	--     else
	--         self.red_point_list[Guild_PANEL.box] = false
	--     end
	-- end

	-- -- Boss界面
	-- self.red_point_list[Guild_PANEL.boss] = false
	-- if OpenFunData.Instance:CheckIsHide("guild_boss") then
	--     local feed_id = self:GetBossFeedItemId()
	--     local number = 0
	--     if feed_id then
	--         number = ItemData.Instance:GetItemNumInBagById(feed_id)
	--     end
	--     local boss_config = self:GetGuildActiveConfig().guild_boss
	--     local boss_info = GuildData.Instance:GetBossInfo()
	--     if boss_config and boss_info then
	--         local next_config = boss_config[boss_info.boss_level + 2]
	--         if next_config then
	--             if number > 0 and boss_info.boss_normal_call_count <= 0 then
	--                 self.red_point_list[Guild_PANEL.boss] = true
	--             end
	--         end
	--     end
	-- end

	-- 领地界面
	-- self.red_point_list[Guild_PANEL.territory] = false
	-- if OpenFunData.Instance:CheckIsHide("guild_territory") then
	--     if post == GuildDataConst.GUILD_POST.TUANGZHANG and self.territory_rank > 0 then
	--         if not self.role_info.territorywar_reward_flag[5] and self.has_territory then
	--             self.red_point_list[Guild_PANEL.territory] = true
	--         end
	--     end
	--     if not self.red_point_list[Guild_PANEL.territory] then
	--         for i = 1, 4 do
	--             if not self.role_info.territorywar_reward_flag[i] then
	--                 if self.role_info.daily_guild_gongxian >= self.gong_xian_config[i] then
	--                     if i == 1 or self.has_territory then
	--                         self.red_point_list[Guild_PANEL.territory] = true
	--                         break
	--                     end
	--                 end
	--             end
	--         end
	--     end
	-- end
	-- -- 领地界面
	-- self.red_point_list[Guild_PANEL.territory] = false
	-- if OpenFunData.Instance:CheckIsHide("guild_territory") then
	--     if post == GuildDataConst.GUILD_POST.TUANGZHANG and self.territory_rank > 0 then
	--         if not self.role_info.territorywar_reward_flag[5] and self.has_territory then
	--             self.red_point_list[Guild_PANEL.territory] = true
	--         end
	--     end
	--     if not self.red_point_list[Guild_PANEL.territory] then
	--         for i = 1, 4 do
	--             if not self.role_info.territorywar_reward_flag[i] then
	--                 if self.role_info.daily_guild_gongxian >= self.gong_xian_config[i] then
	--                     if i == 1 or self.has_territory then
	--                         self.red_point_list[Guild_PANEL.territory] = true
	--                         break
	--                     end
	--                 end
	--             end
	--         end
	--     end
	-- end

	-- RemindManager.Instance:Fire(RemindName.Guild)
-- end

-- 通知主界面
function GuildData:GetGuildRemind()
	local num = 0
	for _,v in pairs(self.red_point_list) do
		if v then
		   num = num + 1
		end
	end
	if self.guild_id <= 0 and OpenFunData.Instance:CheckIsHide("guild") then
		num = num + 1
	end
	return num
end

-- 通知主界面
function GuildData:GetNoGuildRemind()
	local guild_id = PlayerData.Instance.role_vo.guild_id
	if not OpenFunData.Instance:CheckIsHide("guild") then
		return 0
	end
	if guild_id and guild_id > 0 then
		return 0
	end
	return GuildData.HasOpenGuild and 0 or 1
end

function GuildData:GetRedPocketDistributeInfo()
	local fetch_info_list = {}
	local index = 1
	for k,v in pairs(self.red_pocket_distribute) do
		fetch_info_list[index] = v
		index = index + 1
	end
	return fetch_info_list
end


-- 得到成员在公会中的红点信息
function GuildData:GetRedPointInfo()
	for _,v in pairs(self.red_point_list) do
		if v then
			return true
		end
	end
	return false
end

function GuildData:SetIsCanAssistBox(switch)
	self.is_can_assist = switch
	-- self:CalculateRedPoint()
end

-- 设置宝箱信息
function GuildData:SetBoxInfo(info)
	self.box_info.uplevel_count = info.uplevel_count
	self.box_info.assist_count = info.assist_count
	self.box_info.assist_cd_end_time = info.assist_cd_end_time
	self.box_info.info_list = info.info_list
	for k,v in pairs(self.box_info.info_list) do
		v.index = k - 1
	end
end

function GuildData:GetBoxInfo()
	return self.box_info
end

-- 设置宝箱协助信息
function GuildData:SetAssistInfo(info)
	self.assist_info.box_count = info.box_count
	self.assist_info.info_list = info.info_list
end

function GuildData:GetAssistInfo()
	return self.assist_info
end

function GuildData:GetOtherConfig()
	if not self.other_config then
		self.other_config = self:GetGuildConfig().other_config[1]
	end
	return self.other_config
end

function GuildData:GetBoxConfig()
	if not self.box_config then
		self.box_config = self:GetGuildConfig().box_config
	end
	return self.box_config
end

function GuildData:GetOpenBoxCountByVip(vip_level)
	local vip_config = VipData.Instance:GetVipLevelCfg()
	if vip_config then
		local vip_box_info = vip_config[VIPPOWER.GUILD_BOX_COUNT]
		if vip_box_info then
			return vip_box_info["param_" .. vip_level]
		end
	end
end

function GuildData:GetRestOpenBoxCount()
	local count = 0
	for i = 1, MAX_GUILD_BOX_COUNT do
		if self.box_info.info_list[i] then
			if self.box_info.info_list[i].open_time ~= 0 then
				count = count + 1
			end
		end
	end
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local open_count = self:GetOpenBoxCountByVip(main_role_vo.vip_level)
	if open_count then
		return math.max(open_count - count, 0)
	end
end

function GuildData:SetBossInfo(protocol)
	for k,v in pairs(protocol) do
		self.boss_info[k] = v
	end
end

function GuildData:GetBossInfo()
	return self.boss_info
end

function GuildData:GetGuildActiveConfig()
	if not self.boss_config then
		self.boss_config = ConfigManager.Instance:GetAutoConfig("guild_active_auto")
	end
	return self.boss_config
end

function GuildData:GetActivityConfig()
	local config = self:GetGuildActiveConfig().guild_activity
	if config then
		local guild_activity_config = TableCopy(config)
		table.sort(guild_activity_config, function(a, b)
			local a_id = a.activity_id
			local b_id = b.activity_id
			local a_is_open = ActivityData.Instance:GetActivityIsOpen(a_id) and 1 or 0
			local b_is_open = ActivityData.Instance:GetActivityIsOpen(b_id) and 1 or 0
			if a_is_open == b_is_open then
				local a_today_is_open = ActivityData.Instance:GetActivityIsInToday(a_id) and 1 or 0
				local b_today_is_open = ActivityData.Instance:GetActivityIsInToday(b_id) and 1 or 0
				if a_today_is_open == b_today_is_open then
					local a_is_over = ActivityData.Instance:GetActivityIsOver(a_id) and 1 or 0
					local b_is_over = ActivityData.Instance:GetActivityIsOver(b_id) and 1 or 0
					if a_is_over == b_is_over then
						local a_next_time = ActivityData.Instance:GetNextOpenTime(a_id)
						local b_next_time = ActivityData.Instance:GetNextOpenTime(b_id)
						return a_next_time < b_next_time
					else
						return a_is_over < b_is_over
					end
				else
					return a_today_is_open > b_today_is_open
				end
			else
				return a_is_open > b_is_open
			end
			return true
		 end)
		return guild_activity_config
	end
end

function GuildData:GetBossFeedItemId()
	return ConfigManager.Instance:GetAutoConfig("guild_active_auto").other[1].boss_uplevel_item_id
end

function GuildData:GetGuildInfoById(guild_id)
	if not guild_id or guild_id == 0 then return end
	for k,v in pairs(GuildDataConst.GUILD_INFO_LIST.list) do
		if v.guild_id == guild_id then
			return v
		end
	end
end

--通过boss_id得到公会boss信息
function GuildData:GetGuildBossInfo(boss_id)
	local boss_config = self:GetGuildActiveConfig().boss_cfg
	if boss_config and boss_id then
		for k,v in pairs(boss_config) do
			if v.boss_id == boss_id then
				return v
			end
		end
	end
end

-- 通过Post得到职位名称
function GuildData:GetGuildPostNameByPostId(post)
	return Language.Guild[self.guild_post[post]]
end

function GuildData:SetGuildFuLiCount(count)
	self.fu_li_count = count
	-- self:CalculateRedPoint()
end

function GuildData:SetGuildNewFuLiCount(count)
	self.fuli_count = count
end

function GuildData:GetGuildNewFuLiCount()
	return self.fuli_count
end

-- 是否有公会福利
function GuildData:GetGuildNewRemindId()
	local num = self:GetGuildNewFuLiCount()
	if num ~= 1 then
		return 1 
	end
	return 0
end

-- 公会操作
function GuildData:GetOperationRemindId()
	local post = self:GetGuildPost()
	if GuildDataConst.GUILD_APPLYFOR_LIST.count > 0 and (post == GuildDataConst.GUILD_POST.TUANGZHANG or post == GuildDataConst.GUILD_POST.FU_TUANGZHANG) then
		return 1
	else
		return 0       
	end
end


-- 公会技能
function GuildData:GetGuildRoleSkill()
	if self.guild_id < 1 then
		return 0
	end
	local guild_level = GuildDataConst.GUILDVO.guild_level or 0
	if OpenFunData.Instance:CheckIsHide("guild_altar") then
		local gongxian = self:GetGuildGongxian()
		for i = 1, GUILD_SKILL_COUNT do
			local skill_level = self:GetSkillLevel(i) or 0
			local config = self:GetSkillConfig(i, skill_level)
			local uplevel_gongxian = config.uplevel_gongxian
			local guild_level_limit = config.guild_level_limit or 0
			if skill_level < GUILD_SKILL_MAX_LEVEL and gongxian >= uplevel_gongxian and guild_level >= guild_level_limit then
				return 1              
			end
		end
	end
	return 0
end

-- 公会Boss
function GuildData:GetGuildTabBoss()
	if self.guild_id < 1 then
		return 0
	end
	-- Boss界面
	if OpenFunData.Instance:CheckIsHide("guild_boss") then
		local feed_id = self:GetBossFeedItemId()
		local number = 0
		if feed_id then
			number = ItemData.Instance:GetItemNumInBagById(feed_id)
		end
		local boss_config = self:GetGuildActiveConfig().guild_boss
		local boss_info = self:GetBossInfo()
		local post = self:GetGuildPost()
		if post ~= GuildDataConst.GUILD_POST.TUANGZHANG and post ~= GuildDataConst.GUILD_POST.FU_TUANGZHANG then
			return 0
		end
		if boss_config and boss_info then
			local next_config = boss_config[boss_info.boss_level + 2]
			if next_config then
				if number > 0 and boss_info.boss_normal_call_count <= 0 then
					return 1
				end
			end
		end
	end
	return 0
end

--公会宝箱
function GuildData:GetGuildTabBox()
	if self.guild_id < 1 then
		return 0
	end
	-- 宝箱界面
	if OpenFunData.Instance:CheckIsHide("guild_box") then
		local other_config = self:GetOtherConfig()
		local info = self:GetBoxInfo()
		local rest_assist_count = 0
		if info and other_config then
			rest_assist_count = other_config.box_assist_max_count - info.assist_count
		end
		--协助
		if self.assist_info.box_count > 0 and rest_assist_count > 0 and self.is_can_assist then
			return 1

		--挖宝
		elseif self:GetRestOpenBoxCount() > 0 and not self:IsGuildCD() and self:IsGuildBoxStart() and self:IsCanWaQuBox() then
			return 1
		elseif self.box_info.info_list then
			--是否有可领取宝箱
			for k,v in pairs(self.box_info.info_list) do
				if v.is_reward == 0 and v.open_time ~= 0 and v.open_time <= TimeCtrl.Instance:GetServerTime() then
					return 1
				end
			end
		else
			return 0
		end

	end
end

function GuildData:GetRewardBoxIsActive()
	local box_info = self:GetBoxInfo()
	if box_info then
		if box_info.info_list then
			for i = 1, MAX_GUILD_BOX_COUNT do
				if box_info.info_list[i] then
					if box_info.info_list[i].open_time ~= 0 and box_info.info_list[i].is_reward == 0 then
						return true
					end
				end
			end
		end
	end
	return false
end

--公会宝箱挖宝
function GuildData:GetGuildTabBoxWaBao()
	if self.guild_id < 1 then
		return 0
	end

	local rest_count = self:GetRestOpenBoxCount()
	if rest_count then
		if rest_count > 0 and not self:IsGuildCD() and self:IsGuildBoxStart() and self:IsCanWaQuBox() then
			return 1
		else
			return 0  
		end
	end
	return 0  
end

-- 公会宝箱协助
function GuildData:GetGuildTabBoxXieZu()
	if self.guild_id < 1 then
		return 0
	end
	local now_time = TimeCtrl.Instance:GetServerTime()
	local info = self:GetBoxInfo()
	local assist_info = self:GetAssistInfo()
	local other_config = self:GetOtherConfig()
	if info then
		if info.assist_cd_end_time > now_time then
			if assist_info then
				if assist_info.box_count > 0 then
					if other_config then
						local rest_assist_count = other_config.box_assist_max_count - info.assist_count
						if rest_assist_count > 0 then
							local box_assist_cd_limit = other_config.box_assist_cd_limit
							if box_assist_cd_limit then
								if info.assist_cd_end_time - now_time <= box_assist_cd_limit then
									return 1
								end
							end
						end
					end
				end 
			end
		else
			if assist_info then
				if assist_info.box_count > 0 then
					if other_config then
						local rest_assist_count = other_config.box_assist_max_count - info.assist_count
						if rest_assist_count > 0 then
							return 1
						end
					end
				end
			end
		end
	end
	return 0  
end

function GuildData:GetGuildFuLiCount()
	return self.fu_li_count
end

function GuildData:GetGuildDonate()
	local role_vo = GameVoManager.Instance:GetMainRoleVo()
	local coin_cfg = GuildData.Instance:GetShangXiangCfgByType(ADD_GUILD_EXP_TYPE.ADD_GUILD_EXP_TYPE_COIN)
	if role_vo and coin_cfg and role_vo.coin >= coin_cfg.cost then
		local type_coin, _ = self:GetGuildExpType()
		if type_coin == 0 then
			return 1
		end
	end
	return 0
end

function GuildData:SetLastLeaveGuildTime(last_leave_guild_time)
	self.last_leave_guild_time = last_leave_guild_time
	-- self:CalculateRedPoint()
end

function GuildData:GetLastLeaveGuildTime()
	return self.last_leave_guild_time
end

function GuildData:GetBoxLimitTime()
	local config = self:GetOtherConfig()
	if config then
		return config.box_limit_time
	end
end

function GuildData:SetGuildStorgeInfo(info)
	self.guild_storge_info = {}
	self.guild_storge_info.open_grid_count = info.open_grid_count
	self.guild_storge_info.count = info.count
	self.guild_storge_info.storage_score = info.storage_score
	self.guild_storge_info.storge_item_list = {}
	for k,v in pairs(info.item_list) do
		self.guild_storge_info.storge_item_list[k] = v
	end
end

function GuildData:SetGuildStorgeChange(info)
	self.guild_storge_info.storge_item_list[info.index] = info.item_datawrapper
end

-- 得到公会仓库信息
function GuildData:GetGuildStorgeInfo()
	if self.guild_storge_info then
		return self.guild_storge_info
	end
end

-- 得到公会仓库格子数
function GuildData:GetGuildStorgeSize()
	return self:GetGuildStorgeInfo().open_grid_count
end

-- 得到公会仓库积分
function GuildData:GetGuildStorgeScore()
	return self:GetGuildStorgeInfo().storage_score
end

--通过item_id得到公会仓库item信息
function GuildData:GetGuildStorgeItemInfo(item_id)
	local storge_info = self:GetGuildStorgeInfo().storge_item_list
	if storge_info and item_id then
		for k,v in pairs(storge_info) do
			if v.item_id == item_id then
				return v
			end
		end
	end
end

-- 是否在离开公会的限制时间中
function GuildData:IsGuildCD()
	local limit_time = TimeCtrl.Instance:GetServerTime() - self.last_leave_guild_time
	-- local box_limit_time = self:GetBoxLimitTime() or 0
	local box_limit_time = 0
	return limit_time < box_limit_time
end

function GuildData:SetGuildBoxStart(switch)
	self.is_guild_box_start = switch
end

-- 宝箱活动是否开始
function GuildData:IsGuildBoxStart()
	-- local now_time = TimeCtrl.Instance:GetServerTime()
	-- if now_time then
	--  now_time = now_time % 86400
	--  local other_config = GuildData.Instance:GetOtherConfig()
	--  if other_config then
	--      local box_start_time = other_config.box_start_time
	--      if box_start_time then
	--          if now_time >= box_start_time then
	--              return true
	--          end
	--      end
	--  end
	-- end
	-- return false

	return self.is_guild_box_start
end

-- 宝箱是否可以挖下一个
function GuildData:IsCanWaQuBox()
	local flag = true
	for k,v in pairs(self.box_info.info_list) do
		if v.open_time > 0 and v.is_reward == 0 then
			flag = false
			break
		end
	end
	return flag
end

function GuildData:GetOtherGuildInfo()
	return self.other_guild_info
end

function GuildData:GetGuildTerritoryGongXian()
	return self.gong_xian_config
end

function GuildData:SetTerritoryRank(rank, has_territory)
	if rank == nil then
		rank = 0
		has_territory = false
	end
	self.territory_rank = rank
	self.has_territory = has_territory
	-- self:CalculateRedPoint()
end

function GuildData:GetTerritoryRank()
	return self.territory_rank, self.has_territory
end

function GuildData:GetTerritoryConfig(index)
	if self.territory_welf_config then
	   for k,v in pairs(self.territory_welf_config) do
			if v.territory_index == index then
				return v
			end
	   end
	end
end

function GuildData:SetBonFireState(openstatus)
	self.bon_fire_openstatus = openstatus
end

function GuildData:SetMiJingState(openstatus)
	self.mi_jing_openstatus = openstatus
end

function GuildData:GetBonFireState()
	return self.bon_fire_openstatus
end

function GuildData:GetMiJingState()
	return self.mi_jing_openstatus
end

function GuildData:SetBossActivityInfo(protocol)
	self.boss_activity_info.boss_level = protocol.boss_level
	self.boss_activity_info.boss_id = protocol.boss_id
	self.boss_activity_info.boss_obj_id = protocol.boss_obj_id
	self.boss_activity_info.is_surper_boss = protocol.is_surper_boss
	self.boss_activity_info.totem_exp = protocol.totem_exp

	self.boss_activity_info = protocol
end

function GuildData:GetBossActivityInfo()
	return self.boss_activity_info
end

-- 是否有公会邀请权力
function GuildData:GetInvitePower()
	local flag = false
	local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
	if guild_id > 0 then
		local post = self:GetGuildPost()
		if post == GuildDataConst.GUILD_POST.TUANGZHANG or post == GuildDataConst.GUILD_POST.FU_TUANGZHANG then
			flag = true
		end
	end
	return flag
end

-- 得到旗帜的模型ID
function GuildData:GetQiZhiResId(level)
	local res_id = 15001
	local totem_level = level or GuildDataConst.GUILDVO.guild_totem_level
	local cfg = self:GetTotemConfig(totem_level)
	if cfg then
		res_id = res_id + cfg.image
	end
	return res_id
end

function GuildData:GetQiZhiHeadId(level)
	local head_id = 0
	local totem_level = level or GuildDataConst.GUILDVO.guild_totem_level
	local cfg = self:GetTotemConfig(totem_level)
	if cfg then
		head_id = cfg.headid or 0
	end
	return head_id
end

-- 是否拥有免费招募次数
function GuildData:GetCanCallinFree()
	local guild_call_in_free_time = 0
	local config = self:GetOtherConfig()
	if config then
		guild_call_in_free_time = config.guild_call_in_free_time or 0
	end
	if guild_call_in_free_time > GuildDataConst.GUILDVO.guild_callin_times then
		return true
	else
		return false
	end
end

-- 公会招募花费
function GuildData:GetCallinPrice()
	local guild_call_in_cost_gold = 0
	local config = self:GetOtherConfig()
	if config then
		guild_call_in_cost_gold = config.guild_call_in_cost_gold or 0
	end
	return guild_call_in_cost_gold
end

function GuildData:SetLastCallinTime(time)
	self.last_callin_time = time
end

function GuildData:GetLastCallinTime()
	return self.last_callin_time
end

-- 是否可以免费创建公会
function GuildData:IsCreateFree()
	local free_create_guild_times = self:CreateFreeNum()
	return GuildDataConst.GUILD_INFO_LIST.free_create_guild_times < free_create_guild_times
end

-- 免费创建公会数量
function GuildData:CreateFreeNum()
	local other_config = self:GetOtherConfig() or {}
	return other_config.free_create_guild_times or 0
end

function GuildData:ClearCache()
	self.box_info = {
		uplevel_count = 0,
		assist_count = 0,
		assist_cd_end_time = 0,
		info_list = {},
	}

	self.assist_info = {
		box_count = 0,
		info_list = {},
	}
end

-- 得到公会技能等级上限
function GuildData:GetMaxGuildSkillLevel()
	return self.max_skill_level or 0
end

-- 得到公会人数上限
function GuildData:GetMaxGuildMemberCount()
	-- 服务端写死的50
	return 50
end

-- 得到公会红包配置
function GuildData:GetGuildRedBagCfg()
	local config = self:GetGuildConfig()
	if config then
		return config.boss_guild_redbag_cfg
	end
end

-- 根据职位得到对应的复活次数
function GuildData:GetGuildReviveCountByPost(post)
	local count = 0
	if nil == post then
		post = self:GetGuildPost()
	end
	local config = self:GetGuildConfig()
	if config then
		local post_relive_times = config.post_relive_times
		if post_relive_times then
			for k,v in pairs(post_relive_times) do
				if v.guild_post == post then
					count = v.daily_relive_times or 0
					break
				end
			end
		end
	end
	return count
end

-- 得到剩余的个人公会复活次数
function GuildData:GetRestPersonalGuildReviveCount()
	local max_revive_count = self:GetGuildReviveCountByPost()
	return math.max(0, max_revive_count - self.daily_use_guild_relive_times)
end

-- 得到剩余的公会总复活次数
function GuildData:GetRestGuildTotalReviveCount()
	return GuildDataConst.GUILDVO.daily_relive_times
end

-- 得到公会Boss红包最大击杀数量
function GuildData:GetMaxGuildBossCount()
	local count = 0
	local boss_guild_redbag_cfg = self:GetGuildRedBagCfg()
	if boss_guild_redbag_cfg then
		for k,v in pairs(boss_guild_redbag_cfg) do
			if v.kill_boss_times > count then
				count = v.kill_boss_times
			end
		end
	end
	return count
end

-- 得到公会Boss红包是否已经领取
function GuildData:IsGetGuildHongBao(index)
	local bit_list = bit:d2b(self.daily_boss_redbag_reward_fetch_flag)
	for k, v in pairs(bit_list) do
		if v == 1 and (32 - k) == index then
			return true
		end
	end
	return false
end

-- 得到公会Boss红包是否达到领取条件
function GuildData:IsCanGetGuildHongBao(index)
	local need_num = self:GetGuildHongBaoKillCount(index)
	return need_num <= GuildDataConst.GUILDVO.daily_kill_boss_times
end

-- 得到当天已经使用了多少次公会复活次数
function GuildData:GetDailyUseGuildReliveTimes()
	return self.daily_use_guild_relive_times
end

function GuildData:SetDailyUseGuildReliveTimes(daily_use_guild_relive_times)
	self.daily_use_guild_relive_times = daily_use_guild_relive_times
end

function GuildData:SetDailyBossRedbagFlag(daily_boss_redbag_reward_fetch_flag)
	self.daily_boss_redbag_reward_fetch_flag = daily_boss_redbag_reward_fetch_flag
end

function GuildData:GetMaxHongBaoCount()
	local count = 0
	local cfg = self:GetGuildRedBagCfg()
	if cfg then
		count = #cfg
	end
	return count
end

-- 得到公会Boss红包需要击杀数量
function GuildData:GetGuildHongBaoKillCount(index)
	local need_num = 0
	local boss_guild_redbag_cfg = self:GetGuildRedBagCfg()
	if boss_guild_redbag_cfg then
		for k,v in pairs(boss_guild_redbag_cfg) do
			if v.index == index then
				need_num = v.kill_boss_times or 0
				break
			end
		end
	end
	return need_num
end

------------家族上香---------------------------------------------------------------
function GuildData:GetShangXiangCfgByType(shangxiang_type)
	local shangxiang_config = self:GetGuildConfig().guild_shangxiang_config
	if nil == shangxiang_config or nil == next(shangxiang_config) then return end
	for k, v in pairs(shangxiang_config) do
		if shangxiang_type == v.type then
			return v
		end
	end
	return nil
end

function GuildData:SetGuildEventList(info)
	self.event_list = {}
	for _, v in pairs(info.event_list) do
		for k, v1 in pairs(v) do
			if k == "event_type" and v1 == GuildDataConst.GUILD_NOTIFY_TYPE.GUILD_DONATE then
				table.insert(self.event_list, v)
			end
		end
	end
	table.sort(self.event_list, SortTools.KeyUpperSorter("event_time"))

	self.add_guild_exp_type_coin = info.add_guild_exp_type_coin
	self.add_guild_exp_type_gold = info.add_guild_exp_type_gold
end

function GuildData:GetGuildEventList()
	return self.event_list or {}
end

function GuildData:GetGuildExpType()
	return self.add_guild_exp_type_coin, self.add_guild_exp_type_gold
end

--家族boss出生事件
function GuildData:SetGuildBossEvent(protocol)
	self.boss_event = protocol.event
end

function GuildData:GetGuildBossEvent()
	return self.boss_event
end


----------批量操作装备阶数显示-------------------------------------------------------
function GuildData:GetBatchOpLevelLimitByLv(average_level)
	local batch_level = 0
	local level_limit_config = self:GetGuildConfig().limit_level
	if nil == level_limit_config or nil == next(level_limit_config) then return end
	for k, v in pairs(level_limit_config) do
		if average_level >= v.limit_level then
			batch_level = v.order
		end
	end

	return batch_level <= 7 and 2 or batch_level - 5
end

-------仓库固定用品-----------------------------------------------------------------
function GuildData:GetStorageFixedItemCfg()
	return self:GetGuildConfig().storage_fixed_item[1] or {}
end

-- 帮派成员我的信息
function GuildData:GuildMemberMyInfo()
	local guild_member_list = self:GetMemberNumList()
	for i,v in ipairs(guild_member_list) do
	   if v.uid == GameVoManager.Instance:GetMainRoleVo().role_id then
			return v
		end
	end
end

-- 帮派列表我的帮派信息
function GuildData:GuildListMyInfo()
	local guild_list = self:GetGuildInfoList()
	for i,v in ipairs(guild_list) do
	   if v.guild_id == GameVoManager.Instance:GetMainRoleVo().guild_id then
			return v , i
		end
	end
end

function GuildData:SetCurIndex(index)
	self.cur_index = index
end

function GuildData:GetCurIndex()
	return self.cur_index
end

function GuildData:GetBossZhaoHuanRes()
   local boss_peizi = self:GetGuildActiveConfig()
   local boss_info = self:GetBossActivityInfo()
   for k,v in pairs(boss_peizi.boss_cfg) do
	   if boss_info.boss_id == v.boss_id then
			return v
	   end
   end
end

-- 日常任务每日次数
function GuildData:SetRiChangTask(num)
	self.day_richang_task = num
end

function GuildData:GetRiChangTask()
	return self.day_richang_task
end

-- 根据公会成员前三名等级获取公会Boss res  (0普通BOSS 1 超级BOSS)
function GuildData:GetGuildBossRse(boss_type)
	local guild_member_info = self:GetMemberNumList()
	local boss_config = self:GetGuildActiveConfig()
	local level = 1
	if guild_member_info then
		-- if guild_member_info[1] and guild_member_info[2] and guild_member_info[3] then
		-- 	level = (guild_member_info[1].level + guild_member_info[2].level + guild_member_info[3].level) / 3
		-- elseif guild_member_info[1] and guild_member_info[2] and nil == guild_member_info[3] then
		-- 	level = (guild_member_info[1].level + guild_member_info[2].level) / 2
		-- elseif guild_member_info[1] and nil == guild_member_info[2] then
		-- 	level = guild_member_info[1].level
		-- end
		local num = 0
		for i = 1, 3 do
			if guild_member_info[i] ~= nil then
				num = num + 1
				level = level + guild_member_info[i].level
			end
		end

		if num ~= 0 then
			level = math.ceil(level / num)
		end
	end


	for k,v in pairs(boss_config.boss_cfg) do
		if level >= v.min_level and level <= v.max_level and boss_type == v.boss_type then
			return v
		end
	end
end

function GuildData:GetGuildId()
	if self.guild_id then
		return self.guild_id
	end
end

-- 设置日常任务转盘是否延迟显示物品
function GuildData:SetGuildRollShowNow(value)
	self.is_item_show_now = value or false
end

function GuildData:GetGuildRollShowNow()
	return self.is_item_show_now or false
end

--签到红点
function GuildData:GetSigninRedPoint()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_role_vo.guild_id <= 0 then
		return 0
	end

	local falg = 0 
	if self.signin_data ~= nil and self.signin_data.is_signin_today <= 0 then
		falg = 1
	end
	return falg
end

function GuildData:SetOpenValue(value)
	self.is_open_value = value
end

function GuildData:GetOpenValue()
	return self.is_open_value or false
end