
MAX_RANK_COUNT = 13

RankKind = {
	Person = 1,										-- 个人排行
	Guild = 2,										-- 仙盟排行
	Cross = 3,										-- 跨服排名
	Peakathletics = 4,								-- 巅峰竞技
	MultiPlayer = 5,								-- 团队竞技
}

PERSON_RANK_TYPE =
{
	COUPLE_RANK_TYPE_HUNYAN_RENQI = 0,							-- 婚宴人气值排名
	PERSON_RANK_TYPE_CAPABILITY_ALL = 0,						-- 综合战力榜
	PERSON_RANK_TYPE_LEVEL = 1,									-- 等级榜
	PERSON_RANK_TYPE_EQUIP = 3,									-- 装备战力榜
	PERSON_RANK_TYPE_ALL_CHARM = 4,								-- 魅力总榜
	PERSON_RANK_TYPE_MOUNT = 8,									-- 坐骑战力榜
	PERSON_RANK_TYPE_WING = 11,									-- 羽翼战力榜
	PERSON_RANK_TYPE_CHARM = 12 , 								-- 魅力榜
	PERSON_RANK_TYPE_CHARM_MALE = 13 , 							-- 魅力榜男
	PERSON_RANK_TYPE_CHARM_FEMALE = 14 , 						-- 魅力榜女
	PERSON_RANK_TYPE_RAND_RECHARGE = 19,						-- 充值排行
	PERSON_RANK_TYPE_RA_DAY_CHONGZHI_NUM = 42,					-- 随机活动每日充值	
	PERSON_RANK_TYPE_RA_DAY_XIAOFEI_NUM = 43,					-- 随机活动每日充值	
	PERSON_RANK_TYPE_HALO = 44,									-- 光环战力榜
	PERSON_RANK_TYPE_FIGHT_MOUNT = 52,                 			-- 战骑战力榜
	PERSON_RANK_TYPE_SHENGONG = 45,								-- 神弓战力榜
	PERSON_RANK_TYPE_SHENYI = 46,								-- 神翼战力榜
	PERSON_RANK_TYPE_XIANNV_CAPABILITY = 2,						-- 女神战力榜
	PERSON_RANK_TYPE_CAPABILITY_JINGLING = 48,                  -- 精灵战力榜
	PERSON_RANK_TYPE_EQUIP_STRENGTH_LEVEL = 50,					-- 全身装备强化总等级榜
	PERSON_RANK_TYPE_STONE_TOTAL_LEVEL = 51,					-- 全身宝石总等级榜
	PERSON_RANK_TYPE_CAMP_KILL_NUM = 53,						-- 国家杀人榜
	PERSON_RANK_TYPE_CAMP_DEAD_NUM = 54,	   					-- 国家死亡榜
	PERSON_RANK_TYPE_PROF1_CAMP1_CAPA = 55, 					-- 国家1-职业1-战力榜
	PERSON_RANK_TYPE_PROF1_CAMP2_CAPA = 56,						-- 国家2-职业1-战力榜
	PERSON_RANK_TYPE_PROF1_CAMP3_CAPA = 57,						-- 国家3-职业1-战力榜
	PERSON_RANK_TYPE_PROF2_CAMP1_CAPA = 58, 					-- 国家1-职业2-战力榜
	PERSON_RANK_TYPE_PROF2_CAMP2_CAPA = 59,						-- 国家2-职业2-战力榜
	PERSON_RANK_TYPE_PROF2_CAMP3_CAPA = 60,						-- 国家3-职业2-战力榜
	PERSON_RANK_TYPE_PROF3_CAMP1_CAPA = 61, 					-- 国家1-职业3-战力榜
	PERSON_RANK_TYPE_PROF3_CAMP2_CAPA = 62,						-- 国家2-职业3-战力榜
	PERSON_RANK_TYPE_PROF3_CAMP3_CAPA = 63,						-- 国家3-职业3-战力榜
	PERSON_RANK_TYPE_PROF4_CAMP1_CAPA = 64, 					-- 国家1-职业4-战力榜
	PERSON_RANK_TYPE_PROF4_CAMP2_CAPA = 65,						-- 国家2-职业4-战力榜
	PERSON_RANK_TYPE_PROF4_CAMP3_CAPA = 66,						-- 国家3-职业4-战力榜
	PERSON_RANK_TYPE_WEEK_CHARM_MALE = 67,						-- 每周魅力榜（男）
	PERSON_RANK_TYPE_WEEK_CHARM_FEMALE = 68,					-- 每周魅力榜（女）
	PERSON_RANK_TYPE_UPGRADE_MOUNT = 69,						-- 坐骑进阶榜
	PERSON_RANK_TYPE_UPGRADE_WING = 70,							-- 羽翼进阶榜
	PERSON_RANK_TYPE_UPGRADE_HALO = 71,							-- 光环进阶榜
	PERSON_RANK_TYPE_UPGRADE_FIGHTMOUNT = 72,					-- 战骑进阶榜(法印)
	PERSON_RANK_TYPE_UPGRADE_JL_HALO = 73,						-- 精灵光环进阶榜(美人光环)
	PERSON_RANK_TYPE_UPGRADE_JL_FAZHEN = 74,					-- 精灵法阵进阶榜(法宝)
	PERSON_RANK_TYPE_UPGRADE_SHENYI = 75,						-- 神翼进阶榜(披风)
	PERSON_RANK_TYPE_UPGRADE_FOOT = 76,							-- 足迹进阶榜
	PERSON_RANK_TYPE_ICE_MASTER = 77,							-- 冰精通
	PERSON_RANK_TYPE_FIRE_MASTER = 78,							-- 火精通
	PERSON_RANK_TYPE_THUNDER_MASTER = 79,						-- 雷精通
	PERSON_RANK_TYPE_POISON_MASTER = 80,						-- 毒精通
	PERSON_RANK_TYPE_MINGZHONG = 81,							-- 命中
	PERSON_RANK_TYPE_SHANBI = 82,								-- 闪避
	PERSON_RANK_TYPE_BAOJI = 83,								-- 暴击
	PERSON_RANK_TYPE_JIANREN = 84,								-- 抗暴
	PERSON_RANK_TYPE_WULI = 85,									-- 武力
	PERSON_RANK_TYPE_ZHILI = 86,								-- 智力
	PERSON_RANK_TYPE_TONGSHUAI = 87,							-- 统帅
	PERSON_RANK_TYPE_WORLD_RIGHT_ANSWER = 88,					-- 世界题目对题榜
	PERSON_RANK_TYPE_FIGHTING_CHALLENGE = 89,					-- 挖矿里的挑衅排行榜
	PERSON_RANK_TYPE_CAPABILITY_FAZHEN = 90,      			    -- 法阵战力榜
  	PERSON_RANK_TYPE_CAPABILITY_JL_HALO = 91,					-- 精灵光环战力榜
 	PERSON_RANK_TYPE_CAPABILITY_JL_FAZHEN = 92,      		    -- 精灵法阵战力榜
 	PERSON_RANK_TYPE_QIYUN_TOWER_KILL_TIMES = 93,				-- 气运塔击杀次数
 	PERSON_RANK_TYPE_FLOWER_MALE = 94,             				-- 本服花榜（男）
 	PERSON_RANK_TYPE_FLOWER_FEMALE = 95,            			-- 本服花榜（女）
}

-- 跨服排行榜类型
CROSS_PERSON_RANK_TYPE = 
{
	CROSS_PERSON_RANK_TYPE_CAPABILITY_ALL = 0,              	-- 跨服战力榜
	CROSS_PERSON_RANK_TYPE_WEEK_ADD_CHARM = 1,            	  	-- 跨服魅力榜
	CROSS_PERSON_RANK_TYPE_XIULUO_TOWER = 2,             	 	-- 跨服修罗塔
	CROSS_PERSON_RANK_TYPE_1V1 = 3,                    			-- 跨服1V1
	CROSS_PERSON_RANK_SERVER_GROUP_CONTRIBUTE = 4,            	-- 服务器阵营贡献
	CROSS_PERSON_RANK_TYPE_CHONGZHI_RANK = 5,              		-- 跨服充值排行
	CROSS_PERSON_RANK_TYPE_FLOWER_RANK_MALE = 6,            	-- 跨服花榜男
	CROSS_PERSON_RANK_TYPE_FLOWER_RANK_FEMALE = 7,            	-- 跨服花榜女                 
	CROSS_PERSON_RANK_SERVER_GROUP_1_CONTRIBUTE = 8,            -- 服务器阵营1贡献
	CROSS_PERSON_RANK_SERVER_GROUP_2_CONTRIBUTE = 9,            -- 服务器阵营2贡献
}

RANK_GUILD_TYPE =
{
	GUILD_RANK_TYPE_GUILD_KILL_NUM = 8,						-- 家族击杀榜
	GUILD_RANK_TYPE_CAPABILITY_CAMP_1 = 9,					-- 国家1的战力排行榜
	GUILD_RANK_TYPE_CAPABILITY_CAMP_2 = 10,					-- 国家2的战力排行榜
	GUILD_RANK_TYPE_CAPABILITY_CAMP_3 = 11,					-- 国家3的战力排行榜
}

LOCAL_RANK_GUILD_TYPE =											-- 客户端用来和形象做区别的
{
	GUILD_LOCAL_RANK_TYPE_GUILD_KILL_NUM = 108,						-- 家族击杀榜
	GUILD_LOCAL_RANK_TYPE_CAPABILITY_CAMP_1 = 109,					-- 国家1的战力排行榜
	GUILD_LOCAL_RANK_TYPE_CAPABILITY_CAMP_2 = 110,					-- 国家2的战力排行榜
	GUILD_LOCAL_RANK_TYPE_CAPABILITY_CAMP_3 = 111,					-- 国家3的战力排行榜
}

RANK_GUILD_SEND =
{
	RANK_GUILD_TYPE.GUILD_RANK_TYPE_CAPABILITY_CAMP_1,      --国家1的战力排行榜
	RANK_GUILD_TYPE.GUILD_RANK_TYPE_CAPABILITY_CAMP_2,		--国家2的战力排行榜
	RANK_GUILD_TYPE.GUILD_RANK_TYPE_CAPABILITY_CAMP_3,		--国家3的战力排行榜
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
	self.world_level = 0
	self.top_user_level = 0
	self.check_return_flag = false -- 从角色查看返回排行榜的标记
	self.marry_rank = {}
	self.title_cfg = nil
	self.to_product_id = {
	index = 0,
	rank_index = 0,
	} 

	self.rank_cap_list =
	{

		[1] =   															-- 国家1
		{
			-- PERSON_RANK_TYPE.PERSON_RANK_TYPE_LEVEL,						-- 等级榜
			PERSON_RANK_TYPE.PERSON_RANK_TYPE_PROF1_CAMP1_CAPA, 			-- 职业1战力榜
			PERSON_RANK_TYPE.PERSON_RANK_TYPE_PROF2_CAMP1_CAPA,				-- 职业2战力榜
			PERSON_RANK_TYPE.PERSON_RANK_TYPE_PROF3_CAMP1_CAPA,				-- 职业3战力榜
			PERSON_RANK_TYPE.PERSON_RANK_TYPE_PROF4_CAMP1_CAPA,				-- 职业4战力榜
		},
		[2] = 																-- 国家2
		{
			-- PERSON_RANK_TYPE.PERSON_RANK_TYPE_LEVEL,						-- 等级榜
			PERSON_RANK_TYPE.PERSON_RANK_TYPE_PROF1_CAMP2_CAPA, 			-- 职业1战力榜
			PERSON_RANK_TYPE.PERSON_RANK_TYPE_PROF2_CAMP2_CAPA,				-- 职业2战力榜
			PERSON_RANK_TYPE.PERSON_RANK_TYPE_PROF3_CAMP2_CAPA,				-- 职业3战力榜
			PERSON_RANK_TYPE.PERSON_RANK_TYPE_PROF4_CAMP2_CAPA,				-- 职业4战力榜
		},
		[3] = 																-- 国家3
		{
			-- PERSON_RANK_TYPE.PERSON_RANK_TYPE_LEVEL,						-- 等级榜
			PERSON_RANK_TYPE.PERSON_RANK_TYPE_PROF1_CAMP3_CAPA, 			-- 职业1战力榜
			PERSON_RANK_TYPE.PERSON_RANK_TYPE_PROF2_CAMP3_CAPA,				-- 职业2战力榜
			PERSON_RANK_TYPE.PERSON_RANK_TYPE_PROF3_CAMP3_CAPA,				-- 职业3战力榜
			PERSON_RANK_TYPE.PERSON_RANK_TYPE_PROF4_CAMP3_CAPA,				-- 职业4战力榜
		},
		[4] = 															-- 形象型
		{
			PERSON_RANK_TYPE.PERSON_RANK_TYPE_MOUNT,						-- 坐骑战力榜
			PERSON_RANK_TYPE.PERSON_RANK_TYPE_WING,							-- 羽翼战力榜
			PERSON_RANK_TYPE.PERSON_RANK_TYPE_HALO,							-- 光环战力榜
			PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_FAZHEN,			-- 战骑战力榜(法阵)
			PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_JL_HALO,			-- 精灵光环战力榜(美人光环)
			PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_JL_FAZHEN,			-- 至宝战力榜(法宝)
			PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENYI,						-- 神翼战力榜(披风)
			PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENGONG,						-- 神弓战力榜(足迹)
		},
		[5] = 															-- 国家1荣誉榜
		{
			PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAMP_KILL_NUM,         	-- 本国杀敌排行
			PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAMP_DEAD_NUM,         	-- 国家死亡榜
			LOCAL_RANK_GUILD_TYPE.GUILD_LOCAL_RANK_TYPE_GUILD_KILL_NUM, 			-- 家族杀人榜
			LOCAL_RANK_GUILD_TYPE.GUILD_LOCAL_RANK_TYPE_CAPABILITY_CAMP_1,         	-- 国家1家族战力榜
		},
		[6] = 		 													-- 国家2荣誉榜													
		{
			PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAMP_KILL_NUM,         	-- 本国杀敌排行
			PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAMP_DEAD_NUM,         	-- 国家死亡榜
			LOCAL_RANK_GUILD_TYPE.GUILD_LOCAL_RANK_TYPE_GUILD_KILL_NUM, 			-- 家族杀人榜
			LOCAL_RANK_GUILD_TYPE.GUILD_LOCAL_RANK_TYPE_CAPABILITY_CAMP_2,         	-- 国家2家族战力榜
		},
		[7] = 															-- 国家3荣誉榜
		{
			PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAMP_KILL_NUM,         	-- 本国杀敌排行
			PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAMP_DEAD_NUM,         	-- 国家死亡榜
			LOCAL_RANK_GUILD_TYPE.GUILD_LOCAL_RANK_TYPE_GUILD_KILL_NUM, 			-- 家族杀人榜
			LOCAL_RANK_GUILD_TYPE.GUILD_LOCAL_RANK_TYPE_CAPABILITY_CAMP_3,         	-- 国家3家族战力榜
		},
		[8] = 															-- 魅力榜
		{
			PERSON_RANK_TYPE.PERSON_RANK_TYPE_WEEK_CHARM_MALE,			-- 每周魅力榜（男）
			PERSON_RANK_TYPE.PERSON_RANK_TYPE_WEEK_CHARM_FEMALE,		-- 每周魅力榜（女）
			PERSON_RANK_TYPE.PERSON_RANK_TYPE_CHARM, 					-- 魅力榜
			PERSON_RANK_TYPE.COUPLE_RANK_TYPE_HUNYAN_RENQI, 			-- 婚宴人气榜 0
			-- PERSON_RANK_TYPE.PERSON_RANK_TYPE_CHARM, 					-- 豪气榜
			-- PERSON_RANK_TYPE.PERSON_RANK_TYPE_CHARM, 					-- 统帅榜
		},
		[9] = 															-- 特殊属性榜类型
		{
			BiPIN_RANK_TYPE.PERSON_RANK_TYPE_ICE_MASTER,         		-- 冰精通
			BiPIN_RANK_TYPE.PERSON_RANK_TYPE_FIRE_MASTER,         		-- 火精通
			BiPIN_RANK_TYPE.PERSON_RANK_TYPE_THUNDER_MASTER, 			-- 雷精通
			BiPIN_RANK_TYPE.PERSON_RANK_TYPE_POISON_MASTER,         	-- 毒精通
			BiPIN_RANK_TYPE.PERSON_RANK_TYPE_WULI,         				-- 武力
			BiPIN_RANK_TYPE.PERSON_RANK_TYPE_ZHILI, 					-- 智力
			BiPIN_RANK_TYPE.PERSON_RANK_TYPE_TONGSHUAI,         		-- 统帅
		},
		[10] = 															-- 属性榜类型
		{
			BiPIN_RANK_TYPE.PERSON_RANK_TYPE_MINGZHONG ,         		-- 命中
			BiPIN_RANK_TYPE.PERSON_RANK_TYPE_SHANBI,         			-- 闪避
			BiPIN_RANK_TYPE.PERSON_RANK_TYPE_BAOJI, 					-- 暴击
			BiPIN_RANK_TYPE.PERSON_RANK_TYPE_JIANREN,         			-- 抗暴
		},
	}

	self.rank_type_list =
	{
		-- PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_ALL ,			--战力榜
		PERSON_RANK_TYPE.PERSON_RANK_TYPE_LEVEL,					--等级榜
		PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP,					--装备榜
		PERSON_RANK_TYPE.PERSON_RANK_TYPE_MOUNT, 					--坐骑榜
		PERSON_RANK_TYPE.PERSON_RANK_TYPE_WING, 					--羽翼榜
		PERSON_RANK_TYPE.PERSON_RANK_TYPE_HALO, 					--光环榜
		PERSON_RANK_TYPE.PERSON_RANK_TYPE_FIGHT_MOUNT,				--战骑
		PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_JINGLING, 		--精灵总榜
		PERSON_RANK_TYPE.PERSON_RANK_TYPE_XIANNV_CAPABILITY, 		--女神总榜
		PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENGONG, 				--神弓榜
		PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENYI, 					--神翼榜
		-- PERSON_RANK_TYPE.PERSON_RANK_TYPE_ALL_CHARM, 				--魅力总榜
		PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP_STRENGTH_LEVEL,		--强化总榜
		PERSON_RANK_TYPE.PERSON_RANK_TYPE_STONE_TOTAL_LEVEL,		--宝石总榜
	}

	-- (show_camp 对应 show_camp)(show_name_text 对应 show_name) (show_guild_name 对应 show_guild_name) (show_campguild_name 对应 show_campguild_name)
	self.rank_cfg = 
	{
		[0] =   -- 等级榜
		{
			[0] = {index = 0,show_camp = true,show_name_text = true,show_guild_name = false,show_campguild_name = false} ,[1] = {index = 1,show_camp = true,show_name_text = true,show_guild_name = false,show_campguild_name = false} ,[2] = {index = 2,show_camp = true,show_name_text = true,show_guild_name = false,show_campguild_name = false} ,[3] = {index = 3,show_camp = true,show_name_text = true,show_guild_name = false,show_campguild_name = false} ,[4] = {index = 4,show_camp = true,show_name_text = true,show_guild_name = false,show_campguild_name = false} 
		},
		[1] = 	-- 战力榜
		{
			[0] = {index = 0,show_camp = true,show_name_text = true,show_guild_name = false,show_campguild_name = false} ,[1] = {index = 1,show_camp = true,show_name_text = true,show_guild_name = false,show_campguild_name = false} ,[2] = {index = 2,show_camp = true,show_name_text = true,show_guild_name = false,show_campguild_name = false} ,[3] = {index = 3,show_camp = true,show_name_text = true,show_guild_name = false,show_campguild_name = false} ,[4] = {index = 4,show_camp = true,show_name_text = true,show_guild_name = false,show_campguild_name = false} 
		},
		[2] = 	-- 形象榜
		{
			[0] = {index = 0,show_camp = true,show_name_text = true,show_guild_name = false,show_campguild_name = false} ,[1] = {index = 1,show_camp = true,show_name_text = true,show_guild_name = false,show_campguild_name = false} ,[2] = {index = 2,show_camp = true,show_name_text = true,show_guild_name = false,show_campguild_name = false} ,[3] = {index = 3,show_camp = true,show_name_text = true,show_guild_name = false,show_campguild_name = false} ,[4] = {index = 4,show_camp = true,show_name_text = true,show_guild_name = false,show_campguild_name = false},
			[5] = {index = 5,show_camp = true,show_name_text = true,show_guild_name = false,show_campguild_name = false}, [6] = {index = 6,show_camp = true,show_name_text = true,show_guild_name = false,show_campguild_name = false}, [7] = {index = 7,show_camp = true,show_name_text = true,show_guild_name = false,show_campguild_name = false}, [8] = {index = 8,show_camp = true,show_name_text = true,show_guild_name = false,show_campguild_name = false}
		},
		[3] = 	-- 荣誉榜
		{
			[0] = {index = 0,show_camp = true,show_name_text = true,show_guild_name = false,show_campguild_name = false} ,[1] = {index = 1,show_camp = true,show_name_text = true,show_guild_name = false,show_campguild_name = false} ,[2] = {index = 2,show_camp = true,show_name_text = true,show_guild_name = false,show_campguild_name = false} ,[3] = {index = 3,show_camp = true,show_name_text = false,show_guild_name = true,show_campguild_name = false} ,[4] = {index = 4,show_camp = true,show_name_text = false,show_guild_name = true,show_campguild_name = false} 
		},
		[4] = 	-- 社交榜
		{
			[0] = {index = 0,show_camp = true,show_name_text = true,show_guild_name = false,show_campguild_name = false} ,[1] = {index = 1,show_camp = true,show_name_text = true,show_guild_name = false,show_campguild_name = false} ,[2] = {index = 2,show_camp = true,show_name_text = true,show_guild_name = false,show_campguild_name = false} ,[3] = {index = 3,show_camp = true,show_name_text = true,show_guild_name = false,show_campguild_name = false} ,[4] = {index = 4,show_camp = true,show_name_text = true,show_guild_name = false,show_campguild_name = false} 
		},
		[5] = 	-- 特殊属性榜
		{
			[0] = {index = 0,show_camp = true,show_name_text = true,show_guild_name = false,show_campguild_name = false} ,[1] = {index = 1,show_camp = true,show_name_text = true,show_guild_name = false,show_campguild_name = false} ,[2] = {index = 2,show_camp = true,show_name_text = true,show_guild_name = false,show_campguild_name = false} ,[3] = {index = 3,show_camp = true,show_name_text = true,show_guild_name = false,show_campguild_name = false} ,[4] = {index = 4,show_camp = true,show_name_text = true,show_guild_name = false,show_campguild_name = false} 
		},
		[6] = 	-- 基础属性榜
		{
			[0] = {index = 0,show_camp = true,show_name_text = true,show_guild_name = false,show_campguild_name = false} ,[1] = {index = 1,show_camp = true,show_name_text = true,show_guild_name = false,show_campguild_name = false} ,[2] = {index = 2,show_camp = true,show_name_text = true,show_guild_name = false,show_campguild_name = false} ,[3] = {index = 3,show_camp = true,show_name_text = true,show_guild_name = false,show_campguild_name = false} ,[4] = {index = 4,show_camp = true,show_name_text = true,show_guild_name = false,show_campguild_name = false} 
		},
	}

	

	self.mingren_info_list = {}
	self.mingren_index_flag = {}
	self.mingren_id_list = {}
	self.red_point_flag = true
	self.famous_list = {}
	self.cross_rank_list = {}
	RemindManager.Instance:Register(RemindName.Rank, BindTool.Bind(self.GetRemind, self))

	self.get_title_cfg = ListToMap(self:GetTitleCfg(), "title_id")
	self.rank_name_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("rankconfig_auto").rank_broadcast, "rank_type") or {}
end

function RankData:__delete()
	RemindManager.Instance:UnRegister(RemindName.Rank)
	RankData.Instance = nil
end
-- 个人排行返回
function RankData:OnGetPersonRankListAck(protocol)
	self.last_snapshot_time = protocol.last_snapshot_time
	self.rank_type = protocol.rank_type
	self.rank_list = protocol.rank_list
	self:SortRank(self.rank_type)
	if self.rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_RA_DAY_CHONGZHI_NUM then
		local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
		for k,v in pairs(self.rank_list) do
			if v.user_id == role_id then
				KaiFuChargeData.Instance:SetRank(k)
			end
		end
		KaiFuChargeData.Instance:SetDailyChongZhiRank(self.rank_list)
		KaiFuChargeCtrl.Instance:Flush("flush_chongzhi_rank_view")
	elseif self.rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_RA_DAY_XIAOFEI_NUM then
		local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
		for k,v in pairs(self.rank_list) do
			if v.user_id == role_id then
				KaiFuChargeData.Instance:SetRankLevel(k)
			end
		end
		KaiFuChargeData.Instance:SetDailyXiaoFeiRank(self.rank_list)
		KaiFuChargeCtrl.Instance:Flush("flush_xiaofei_rank_view")
	end
	  KaiFuChargeCtrl.Instance:FlushBiPin()
end

-- 仙盟排行返回
function RankData:OnGetGuildRankListAck(protocol)
	self.rank_type = protocol.rank_type
	self.rank_list = protocol.rank_list
	self.guild_list = protocol.rank_list               -- 不修改他原来的东西，重新赋值
end

--队伍排行返回
function RankData:OnGetTeamRankListAck(protocol)
	self.rank_type = protocol.rank_type
	self.rank_list = protocol.rank_list
end

function RankData:GetRankType()
	return self.rank_type
end

-- 婚宴排行信息返回
function RankData:SetMarryRankInfo(protocol)
	self.marry_rank = protocol.rank_item_list
end


function RankData:GetMarryRankInfo()
	return self.marry_rank 
end

function RankData:GetGuildRankInfo()
	return self.guild_list 
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

function RankData:GetMingrenListData()
	return self.mingren_id_list
end

function RankData:GetMingrenData()
	return self.mingren_info_list
end

function RankData:GetRankCapList()
	return self.rank_cap_list
end

function RankData:SetFamousList(famous_list)
	self.famous_list = famous_list
	if self.red_point_flag == true then
		RemindManager.Instance:Fire(RemindName.Rank)
	end
end

function RankData:SetMingrenIdList(famous_list)
	for k, v in ipairs(famous_list) do
		self.mingren_id_list[k-1] = v
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
end

--世界等级信息返回
function RankData:OnGetWorldLevelAck(protocol)
	self.world_level = protocol.world_level
	self.top_user_level = protocol.top_user_level
	self.server_level = protocol.server_level
end

function RankData:GetWordLevel()
	return self.world_level
end

function RankData:GetServerLevel()
	return self.server_level
end

function RankData:GetRankList()
	return self.rank_list
end

function RankData:SetRankToProductId(product_id, rank_index)
	self.to_product_id.index = product_id
	self.to_product_id.rank_index = rank_index
end

function RankData:GetRankToProductId()
	return self.to_product_id
end

--获取目前需要的排行榜类型 9种
function RankData:GetRankTypeList()
	return self.rank_type_list
end

function RankData:GetMyInfoList()
	local my_rank = -1
	for k,v in pairs(self:GetRankList()) do
		if GameVoManager.Instance:GetMainRoleVo().role_id == v.user_id then
			return k
		end
	end
	return my_rank
end

function RankData:GetGuildMyNumRank()
	local my_rank = -1
	if self:GetGuildRankInfo() then
		for k,v in pairs(self:GetGuildRankInfo()) do
			if GameVoManager.Instance:GetMainRoleVo().guild_id == v.guild_id then
				return k
			end
		end
	end
	return my_rank
end

function RankData:GetGuildMyInfoList()
	if self:GetGuildRankInfo() then
		for k,v in pairs(self:GetGuildRankInfo()) do
			if GameVoManager.Instance:GetMainRoleVo().guild_id == v.guild_id then
				return v
			end
		end
	end
end


function RankData:SortRank(rank_type)
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


	if self.rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LEVEL then
		table.sort(self.rank_list, sortfun_level)
	elseif self.rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP or self.rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_ALL_CHARM then
		table.sort(self.rank_list, sortfun_other)
	else
		table.sort(self.rank_list, sortfun_capability)
	end
end

function RankData:GetRankTitleDes(rank_type)
	-- local title = ""
	-- if rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_ALL
	-- 	or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP
	-- 	or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_XIANNV_CAPABILITY
	-- 	or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_JINGLING then
	-- 	title = Language.Rank.RankTitleName[1]
	-- elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LEVEL
	-- 	or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP_STRENGTH_LEVEL
	-- 	or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_STONE_TOTAL_LEVEL then
	-- 	title = Language.Rank.RankTitleName[2]
	-- elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_ALL_CHARM then
	-- 	title = Language.Rank.RankTitleName[3]
	-- else
	-- 	title = Language.Rank.RankTitleName[4]
	-- end
	-- return title
	local title = ""
	if rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP
		or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_XIANNV_CAPABILITY
		or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_JINGLING
		or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_PROF1_CAMP1_CAPA 
		or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_PROF2_CAMP1_CAPA 
		or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_PROF3_CAMP1_CAPA 
		or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_PROF4_CAMP1_CAPA
		or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_PROF1_CAMP2_CAPA 
		or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_PROF2_CAMP2_CAPA 
		or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_PROF3_CAMP2_CAPA 
		or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_PROF4_CAMP2_CAPA
		or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_PROF1_CAMP3_CAPA 
		or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_PROF2_CAMP3_CAPA 
		or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_PROF3_CAMP3_CAPA 
		or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_PROF4_CAMP3_CAPA
		or rank_type ==	RANK_GUILD_TYPE.GUILD_RANK_TYPE_CAPABILITY_CAMP_1
		or rank_type ==	RANK_GUILD_TYPE.GUILD_RANK_TYPE_CAPABILITY_CAMP_2
		or rank_type ==	RANK_GUILD_TYPE.GUILD_RANK_TYPE_CAPABILITY_CAMP_3 then
		title = Language.Rank.RankTitleName[1]
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LEVEL   
		or  rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP_STRENGTH_LEVEL  
		or  rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_STONE_TOTAL_LEVEL then 
		title = Language.Rank.RankTitleName[2]
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_ALL_CHARM then
		title = Language.Rank.RankTitleName[3]
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAMP_KILL_NUM or rank_type == LOCAL_RANK_GUILD_TYPE.GUILD_LOCAL_RANK_TYPE_GUILD_KILL_NUM then
		title = Language.Rank.RankTitleName[5]
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_WEEK_CHARM_MALE or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_WEEK_CHARM_FEMALE 
		or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_CHARM then
		title = Language.Rank.RankTitleName[6]
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAMP_DEAD_NUM then
		title = Language.Rank.RankTitleName[7]
	elseif	rank_type == RANK_TOGGLE_TYPE.DENG_JI_BANG then  
		title = Language.Rank.RankTitleName[2]
	elseif	rank_type == BiPIN_RANK_TYPE.PERSON_RANK_TYPE_MINGZHONG then
		title = Language.Rank.RankTitleName[8]
	elseif	rank_type == BiPIN_RANK_TYPE.PERSON_RANK_TYPE_SHANBI then
		title = Language.Rank.RankTitleName[9]
	elseif	rank_type == BiPIN_RANK_TYPE.PERSON_RANK_TYPE_BAOJI then
		title = Language.Rank.RankTitleName[10]
	elseif	rank_type == BiPIN_RANK_TYPE.PERSON_RANK_TYPE_JIANREN then
		title = Language.Rank.RankTitleName[11]
	elseif	rank_type == BiPIN_RANK_TYPE.PERSON_RANK_TYPE_ICE_MASTER then
		title = Language.Rank.RankTitleName[12]
	elseif	rank_type == BiPIN_RANK_TYPE.PERSON_RANK_TYPE_FIRE_MASTER then
		title = Language.Rank.RankTitleName[13]
	elseif	rank_type == BiPIN_RANK_TYPE.PERSON_RANK_TYPE_THUNDER_MASTER then
		title = Language.Rank.RankTitleName[14]
	elseif	rank_type == BiPIN_RANK_TYPE.PERSON_RANK_TYPE_POISON_MASTER then
		title = Language.Rank.RankTitleName[15]
	else
		title = Language.Rank.RankTitleName[4]
	end
	return title
end

function RankData:GetRankValue(rank)
	if self.rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_ALL
		and self.rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_LEVEL
		and self.rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP
		and self.rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_ALL_CHARM
		and self.rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_XIANNV_CAPABILITY
		and self.rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_JINGLING
		and self.rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP_STRENGTH_LEVEL
		and self.rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_STONE_TOTAL_LEVEL 
		and self.rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_PROF1_CAMP1_CAPA 
		and self.rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_PROF2_CAMP1_CAPA 
		and self.rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_PROF3_CAMP1_CAPA 
		and self.rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_PROF4_CAMP1_CAPA
		and self.rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_PROF1_CAMP2_CAPA 
		and self.rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_PROF2_CAMP2_CAPA 
		and self.rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_PROF3_CAMP2_CAPA 
		and self.rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_PROF4_CAMP2_CAPA
		and self.rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_PROF1_CAMP3_CAPA 
		and self.rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_PROF2_CAMP3_CAPA 
		and self.rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_PROF3_CAMP3_CAPA 
		and self.rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_PROF4_CAMP3_CAPA
		and self.rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_WEEK_CHARM_MALE 
		and self.rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_WEEK_CHARM_FEMALE 
		and self.rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_CHARM
		and self.rank_type ~= RANK_GUILD_TYPE.GUILD_RANK_TYPE_CAPABILITY_CAMP_1
		and self.rank_type ~= RANK_GUILD_TYPE.GUILD_RANK_TYPE_CAPABILITY_CAMP_2
		and self.rank_type ~= RANK_GUILD_TYPE.GUILD_RANK_TYPE_CAPABILITY_CAMP_3
		and self.rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAMP_DEAD_NUM 
		and self.rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAMP_KILL_NUM 
		and self.rank_type ~= BiPIN_RANK_TYPE.PERSON_RANK_TYPE_MINGZHONG
		and self.rank_type ~= BiPIN_RANK_TYPE.PERSON_RANK_TYPE_SHANBI
		and self.rank_type ~= BiPIN_RANK_TYPE.PERSON_RANK_TYPE_BAOJI
		and self.rank_type ~= BiPIN_RANK_TYPE.PERSON_RANK_TYPE_JIANREN 
		and self.rank_type ~= BiPIN_RANK_TYPE.PERSON_RANK_TYPE_ICE_MASTER
		and self.rank_type ~= BiPIN_RANK_TYPE.PERSON_RANK_TYPE_FIRE_MASTER
		and self.rank_type ~= BiPIN_RANK_TYPE.PERSON_RANK_TYPE_THUNDER_MASTER
		and self.rank_type ~= BiPIN_RANK_TYPE.PERSON_RANK_TYPE_POISON_MASTER then
		if self.rank_list[rank].flexible_int == 0 then
			return Language.Rank.NotActive
		end
		
		if MountData.Instance:GetGradeCfg(self.rank_list[rank].flexible_int)[self.rank_list[rank].flexible_int] == nil then
			return Language.Rank.NotActive
		else
			return MountData.Instance:GetGradeCfg(self.rank_list[rank].flexible_int)[self.rank_list[rank].flexible_int].gradename
		end
	elseif self.rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LEVEL then
		local lv, zhuan = PlayerData.GetLevelAndRebirth(self.rank_list[rank].level)
		local level = string.format(Language.Common.ZhuanShneng, lv, zhuan)
		return level
	elseif self.rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP_STRENGTH_LEVEL 
		or self.rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_STONE_TOTAL_LEVEL then
		return self.rank_list[rank].rank_value
	elseif self.rank_type == LOCAL_RANK_GUILD_TYPE.GUILD_LOCAL_RANK_TYPE_GUILD_KILL_NUM then
		return self.rank_list[rank].rank_value
	elseif self.rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_WEEK_CHARM_MALE 
		or self.rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_WEEK_CHARM_FEMALE 
		or self.rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_CHARM 
		or self.rank_type == RANK_GUILD_TYPE.GUILD_RANK_TYPE_CAPABILITY_CAMP_1 
		or self.rank_type == RANK_GUILD_TYPE.GUILD_RANK_TYPE_CAPABILITY_CAMP_2 
		or self.rank_type == RANK_GUILD_TYPE.GUILD_RANK_TYPE_CAPABILITY_CAMP_3 
		or self.rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAMP_DEAD_NUM 
		or self.rank_type == BiPIN_RANK_TYPE.PERSON_RANK_TYPE_MINGZHONG
		or self.rank_type == BiPIN_RANK_TYPE.PERSON_RANK_TYPE_SHANBI
		or self.rank_type == BiPIN_RANK_TYPE.PERSON_RANK_TYPE_BAOJI
		or self.rank_type == BiPIN_RANK_TYPE.PERSON_RANK_TYPE_JIANREN
		or self.rank_type == BiPIN_RANK_TYPE.PERSON_RANK_TYPE_ICE_MASTER
		or self.rank_type == BiPIN_RANK_TYPE.PERSON_RANK_TYPE_FIRE_MASTER
		or self.rank_type == BiPIN_RANK_TYPE.PERSON_RANK_TYPE_THUNDER_MASTER
		or self.rank_type == BiPIN_RANK_TYPE.PERSON_RANK_TYPE_POISON_MASTER  then
		return self.rank_list[rank].rank_value
	end
	return self.rank_list[rank].rank_value
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

-- 排行榜Value (rank_title_text)
function RankData:GetRankPowerValue(rank_type,rank)
	local rank_info = self:GetRankList()[rank]
	if rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_MOUNT or 
		rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_WING or
		rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_HALO or 
		rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_FAZHEN or
		rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_JL_HALO or
		rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_JL_FAZHEN or
		rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENYI or
		rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENGONG  then
		return KaiFuChargeData.Instance:ConvertGrade(rank_info.flexible_int)
	else
		return tostring(rank_info.rank_value)
	end
end



-- 我的排行数据
function RankData:GetMyPowerValue(rank_type)
	local helper_data = HelperData.Instance
	local power = ""
	-- if rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_ALL then
	-- 	power = GameVoManager.Instance:GetMainRoleVo().capability
	if rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LEVEL or DENGJIBANG_TYPE then
		local level = GameVoManager.Instance:GetMainRoleVo().level
		local lv, zhuan = PlayerData.GetLevelAndRebirth(level)
		-- power = string.format(Language.Common.ZhuanShneng, lv, zhuan)
		power = level
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP then
		power = helper_data:GetCurrentScore(HELPER_EVALUATE_TYPE.EQUIP)
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_ALL_CHARM then
		power = GameVoManager.Instance:GetMainRoleVo().all_charm
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_MOUNT then
		local cfg = MountData.Instance:GetGradeCfg()[MountData.Instance:GetMountInfo().grade]
		if cfg then
			power = cfg.gradename
		else
			power = Language.Rank.NotActive
		end
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_WING then
		local cfg = MountData.Instance:GetGradeCfg()[WingData.Instance:GetWingInfo().grade]
		if cfg then
			power = cfg.gradename
		else
			power = Language.Rank.NotActive
		end
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_HALO then
		local cfg = MountData.Instance:GetGradeCfg()[HaloData.Instance:GetHaloInfo().grade]
		if cfg then
			power = cfg.gradename
		else
			power = Language.Rank.NotActive
		end
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENGONG then
		local cfg = MountData.Instance:GetGradeCfg()[ShengongData.Instance:GetShengongInfo().grade]
		if cfg then
			power = cfg.gradename
		else
			power = Language.Rank.NotActive
		end
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENYI then
		local cfg = MountData.Instance:GetGradeCfg()[ShenyiData.Instance:GetShenyiInfo().grade]
		if cfg then
			power = cfg.gradename
		else
			power = Language.Rank.NotActive
		end
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_FIGHT_MOUNT then
		local cfg = MountData.Instance:GetGradeCfg()[FaZhenData.Instance:GetFightMountInfo().grade]
		if cfg then
			power = cfg.gradename
		else
			power = Language.Rank.NotActive
		end
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAMP_KILL_NUM then
		local rank, kill = WarReportData.Instance:GetMyRankAndNum()
        power = kill	
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_XIANNV_CAPABILITY then
		power = GoddessData.Instance:GetAllPower()
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP_STRENGTH_LEVEL then
		power = ForgeData.Instance:GetTotalStrengthLevel()
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_STONE_TOTAL_LEVEL then
		local level = ForgeData.Instance:GetTotalGemCfg()
		power = level
	elseif rank_type == BiPIN_RANK_TYPE.PERSON_RANK_TYPE_UPGRADE_MOUNT then	
		local mount_info = MountData.Instance:GetMountInfo()     					-- 坐骑阶数	
		local grade = KaiFuChargeData.Instance:ConvertGrade(mount_info.grade)
		power = grade
	elseif rank_type == BiPIN_RANK_TYPE.PERSON_RANK_TYPE_UPGRADE_WING then
		local wind_info = WingData.Instance:GetWingGrade()        					-- 羽翼阶数
		local grade = KaiFuChargeData.Instance:ConvertGrade(wind_info)
		power = grade
	elseif rank_type == BiPIN_RANK_TYPE.PERSON_RANK_TYPE_UPGRADE_HALO then
		local halo_info = HaloData.Instance:GetHaloInfo() 		  				 	-- 光环阶数
		local grade = KaiFuChargeData.Instance:ConvertGrade(halo_info.star_level)
		power = grade
	elseif rank_type == BiPIN_RANK_TYPE.PERSON_RANK_TYPE_UPGRADE_FIGHTMOUNT then
		local fight_mount_info = FaZhenData.Instance:GetFightMountInfo()  			-- 战骑阶数
		local grade = KaiFuChargeData.Instance:ConvertGrade(fight_mount_info.grade)
		power = grade
	elseif rank_type == BiPIN_RANK_TYPE.PERSON_RANK_TYPE_UPGRADE_JL_HALO then	
		local meiren_guanghuan_info = BeautyHaloData.Instance:GetBeautyHaloInfo()   -- 美人光环
		local grade = KaiFuChargeData.Instance:ConvertGrade(meiren_guanghuan_info.grade)
		power = grade
	elseif rank_type == BiPIN_RANK_TYPE.PERSON_RANK_TYPE_UPGRADE_ZHIBAO then	
		local halidom_info = HalidomData.Instance:GetHalidomInfo() 					-- 圣物法宝
		local grade = KaiFuChargeData.Instance:ConvertGrade(halidom_info.grade)
		power = grade
	elseif rank_type == BiPIN_RANK_TYPE.PERSON_RANK_TYPE_UPGRADE_SHENYI then
		local shenyi_info = ShenyiData.Instance:GetShenyiInfo() 					-- 神翼阶数 （披风）
		local grade = KaiFuChargeData.Instance:ConvertGrade(shenyi_info.grade)
		power = grade
	elseif rank_type == BiPIN_RANK_TYPE.PERSON_RANK_TYPE_UPGRADE_SHENGONG then
		local shengong_info = ShengongData.Instance:GetShengongInfo() 			 	-- 神弓阶数（足迹）
		local grade = KaiFuChargeData.Instance:ConvertGrade(shengong_info.grade)
		power = grade
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

function RankData:GetTabAsset(tab_index)
	local asset, name = "", ""
	if tab_index == RANK_TAB_TYPE.ZHANLI then
		asset = "uis/views/rank_images"
		name = "left_icon_zl"
	elseif tab_index == RANK_TAB_TYPE.LEVEL then
		asset = "uis/views/rank_images"
		name = "left_icon_lv"
	elseif tab_index == RANK_TAB_TYPE.EQUIP then
		asset = "uis/views/rank_images"
		name = "left_icon_equip"
	elseif tab_index == RANK_TAB_TYPE.MOUNT then
		asset = "uis/views/advanceview_images"
		name = "left_icon_mount"
	elseif tab_index == RANK_TAB_TYPE.WING then
		asset = "uis/views/advanceview_images"
		name = "left_icon_wing"
	elseif tab_index == RANK_TAB_TYPE.HALO then
		asset = "uis/views/advanceview_images"
		name = "left_icon_guanghuan"
	elseif tab_index == RANK_TAB_TYPE.FIGHT_MOUNT then
		asset = "uis/views/advanceview_images"
		name = "left_icon_zd_mount"
	elseif tab_index == RANK_TAB_TYPE.SPIRIT then
		asset = "uis/views/spiritview_images"
		name = "left_icon_jingling"
	elseif tab_index == RANK_TAB_TYPE.GODDESS then
		asset = "uis/views/rank_images"
		name = "left_icon_nvshen"
	elseif tab_index == RANK_TAB_TYPE.SHENGONG then
		asset = "uis/views/goddess_images"
		name = "left_icon_gong"
	elseif tab_index == RANK_TAB_TYPE.SHENYI then
		asset = "uis/views/goddess_images"
		name = "left_icon_wing"
	elseif tab_index == RANK_TAB_TYPE.MEILI then
		asset = "uis/views/rank_images"
		name = "left_icon_charm"
	elseif tab_index == RANK_TAB_TYPE.FORGE then
		asset = "uis/views/forgeview_images"
		name = "left_icon_strength"
	elseif tab_index == RANK_TAB_TYPE.BAOSHI then
		asset = "uis/views/forgeview_images"
		name = "left_icon_gem"
	end
	return asset, name
end

function RankData:GetRedPoint()
	local temp_list = {}
	for k,v in pairs(self.famous_list) do
		if v > 0 then
			table.insert(temp_list, v)
		end
	end
	return #temp_list < 6 and self:GetRedPointFlag() and not LoginData.Instance:GetIsMerge()
end

-- 获取自己国家的排行榜List
function RankData:GetMyGuoJiaRankList()
	local role_vo = GameVoManager.Instance:GetMainRoleVo()
	local data = TableCopy(self.rank_cap_list)
	for i = 3, 1, -1 do
		if role_vo.camp ~= i then
			table.remove(data, i)
		end
	end
	return data
end

-- 获取自己国家的排行榜List
function RankData:GetGuoJiaRankListItem()
	local role_vo = GameVoManager.Instance:GetMainRoleVo()
	local data = TableCopy(self:GetMyGuoJiaRankList())
	for i = 5, 3, -1 do
		if role_vo.camp ~= i - 2 then
			table.remove(data, i)
		end
	end
	return data
end


function RankData:GetTitleId(rank_num)
	local title_cfg = ConfigManager.Instance:GetAutoConfig("titleconfig_auto").title_list
	local marry_rank_cfg = ConfigManager.Instance:GetAutoConfig("rankconfig_auto").marry_popularity_rank
	for k,v in ipairs(title_cfg) do
		for k1,v1 in pairs(marry_rank_cfg) do
			if rank_num == v1.rank then
				return v1.title
			end
		end
	end
end

function RankData:GetTitleCfg()
	if  not self.title_cfg then 
		self.title_cfg = ConfigManager.Instance:GetAutoConfig("titleconfig_auto").title_list
	end
	return self.title_cfg
end

function RankData:GetTitleName(title_id)
	for i,v in ipairs(self.title_cfg) do
		if title_id == v.title_id then
			return v.name
		end
	end
end

function RankData:GetCurTitleCfg(index)
	local marry_rank_cfg = ConfigManager.Instance:GetAutoConfig("rankconfig_auto").marry_popularity_rank
	return marry_rank_cfg[index].title
end

function RankData:GetMyMarryRank()
	local game_vo = GameVoManager.Instance:GetMainRoleVo()
	local list = {}
	local marry_rank_info = self:GetMarryRankInfo()
	for i,v in ipairs(marry_rank_info) do
		if game_vo.role_name == v.name_1 or game_vo.role_name == v.name_2 then
			return v , i
		end
	end
end

-- 根据配置排行榜的数据是否显示
function RankData:GetMyRankData(type,index)
	for k,v in pairs(self.rank_cfg) do
		if type == k and index == v[index].index then
			return v[index]
		end
	end
end

-- 根据配置排行榜的数据是否显示
function RankData:GetRankNameByIndex(index)
	return self.rank_name_cfg[index].rank_name
end

function RankData:SetCrossPersonRankList(protocol)
	self.cross_rank_list = protocol.rank_list or {}
end

function RankData:GetCrossPersonRankList()
	return self.cross_rank_list or {}
end