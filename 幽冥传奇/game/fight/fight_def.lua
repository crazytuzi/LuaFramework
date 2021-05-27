ATK_WAIT_TIME = 0.4

GAME_ATTRIBUTE_TYPE = {
	UNDEFINED = 0,									-- 未定义属性
	
	HP_ADD = 1,										-- 血增加
	HP_POWER = 2,									-- 血倍率增加
	MP_ADD = 3 ,									-- 蓝增加
	MP_POWER= 4,									-- 蓝倍率增加
	MAX_HP_ADD = 5,									-- 最大血增加
	MAX_HP_POWER = 6,								-- 最大血倍率增加
	MAX_MP_ADD = 7,									-- 最大蓝增加
	MAX_MP_POWER = 8,								-- 最大蓝倍率增加
	PHYSICAL_ATTACK_MIN_ADD = 9,					-- 最小物理攻击增加
	PHYSICAL_ATTACK_MIN_POWER = 10,					-- 最小物理攻击倍率增加（百分比）
	PHYSICAL_ATTACK_MAX_ADD = 11,					-- 最大物理攻击增加万分比）
	PHYSICAL_ATTACK_MAX_POWER = 12,					-- 最大物理攻击倍率增加百分比）
	MAGIC_ATTACK_MIN_ADD = 13,						-- 最小魔法攻击增加
	MAGIC_ATTACK_MIN_POWER = 14,					-- 最小魔法攻击倍率增加
	MAGIC_ATTACK_MAX_ADD = 15,						-- 最大魔法攻击增加
	MAGIC_ATTACK_MAX_POWER = 16,					-- 最大魔法攻击倍率增加
	WIZARD_ATTACK_MIN_ADD = 17,						-- 最小道术攻击增加
	WIZARD_ATTACK_MIN_POWER = 18,					-- 最小道术攻击倍率增加
	WIZARD_ATTACK_MAX_ADD = 19,						-- 最大道术攻击增加
	WIZARD_ATTACK_MAX_POWER = 20,					-- 最大道术攻击倍率增加
	PHYSICAL_DEFENCE_MIN_ADD = 21,					-- 最小物理防御增加
	PHYSICAL_DEFENCE_MIN_POWER = 22,				-- 最小物理防御倍率增加百分比）
	PHYSICAL_DEFENCE_MAX_ADD = 23,					-- 最大物理防御增加
	PHYSICAL_DEFENCE_MAX_POWER = 24,				-- 最大物理防御倍率增加百分比）
	MAGIC_DEFENCE_MIN_ADD = 25,						-- 最小魔法防御增加
	MAGIC_DEFENCE_MIN_POWER = 26,					-- 最小魔法防御倍率增加
	MAGIC_DEFENCE_MAX_ADD = 27,						-- 最大魔法防御增加
	MAGIC_DEFENCE_MAX_POWER = 28,					-- 最大魔法防御倍率增加
	HIT_VALUE_ADD = 29,								-- 准确增加
	HIT_VALUE_POWER = 30,							-- 准确倍率增加
	DOG_VALUE_ADD = 31,								-- 敏捷增加
	DOG_VALUE_POWER = 32,							-- 敏捷倍率增加
	MAGIC_HIT_RATE_ADD = 33,						-- 魔法命中增加
	MAGIC_HIT_RATE_POWER = 34,						-- 魔法命中倍率增加
	MAGIC_DOGERATE_ADD = 35,						-- 魔法闪避增加
	MAGIC_DOGERATE_POWER = 36,						-- 魔法闪避倍率增加
	TOXIC_DOGERATE_ADD = 37,						-- 毒物闪避增加
	TOXIC_DOGERATE_POWER = 38,						-- 毒物闪避倍率增加
	HP_RENEW_ADD = 39,								--  生命恢复增加 --整型
	HP_RENEW_POWER = 40,							--  生命恢复倍率增加
	MP_RENEW_ADD = 41,								-- 魔法恢复增加
	MP_RENEW_POWER = 42,							-- 魔法恢复倍率增加
	TOXIC_RENEW_ADD	= 43,							-- 毒物恢复增加
	TOXIC_RENEW_POWER = 44,							-- 毒物恢复倍率增加
	LUCK_ADD = 45,									-- 幸运 增加
	LUCK_POWER = 46,								-- 幸运倍率增加
	CURSE_ADD = 47,									-- 诅咒增加
	CURSE_POWER = 48,								-- 诅咒倍率增加
	MOVE_SPEED_ADD = 49,							-- 移动速度增加
	MOVE_SPEED_POWER = 50,							-- 移动速度倍率增加
	ATTACK_SPEED_ADD = 51,							-- 攻击速度增加
	ATTACK_SPEED_POWER = 52,						-- 攻击速度倍率增加
	DAMAGE_ABSORB = 53 , 							-- 实体的属性个数,下面的这些不需要进行属性的计算
	DAMAGE_ABSORB_RATE = 54,						-- 按比例吸收伤害,降低一定百分比的所受伤害
	DAMAGE_2_MP = 55,								-- 神圣伤害增加
	Dizzy = 56,										-- 麻痹,不可移动，可释放技能
	CONTROL_SKILL_IMMUNE = 57,						-- 免疫各种控制技能
	EXP_ADD = 58,									-- 经验增加一个数值
	TAUNT = 59,										-- 嘲讽
	SUPER_MAN = 60,									-- 无敌,能攻击，不能被攻击
	RELIVE_PROTECT_STATE = 61,						-- 复活保护状态
	USE_SKILL = 62,									-- 使用一个buff的效果是定时使用技能
	Hide = 63,										-- 隐身
	EXP_POWER = 64,							 		-- 经验的增加的倍率
	PK_VALUE_ADD = 65,						 		-- 杀戮值(pk值)的增减
	KILL_MONSTER_DAMAGE_POWER = 66,					-- 神圣伤害减少
	PK_PROTECT_STATE = 67,							-- pk保护状态
	SELF_ATTACK_APPEND = 68,						-- 技能攻击的时候 攻击伤害追加n点（以固定值的方式影响角色造成的内功与外功攻击伤害）
	DRUNK_EXP_ADD = 69,								-- 篝火喝酒的时候经验的加成,+%n
	SACRED_VALUE_ADD = 70,							-- 增加神圣
	BAG_MAX_WEIGHT_ADD = 71,						-- 破护身(减少比例比例将伤害值转换成消耗魔法值)（万分比 整数）
	BAG_MAX_WEIGHT_POWER = 72,						-- 破护身(减少比例比例将伤害值转换成消耗魔法值)cd（整数 秒)
	EQUIP_MAX_WEIGHT_ADD = 73,						-- 破击几率(有一定几率触发额外的破击伤害（攻击的2倍，固定倍数）（万分比 整数）
	EQUIP_MAX_WEIGHT_POWER = 74,					-- 抗破击 受到破击伤害时，按照比例抵消破击伤害
	ARM_POWER_ADD = 75,						 		-- 内力减伤(整数)
	ARM_POWER_POWER = 76,							-- 复活血量万分比 (整数）
	EQUIP_MAX_DUR_ADD = 77,							-- 致命伤害减少
	HP_DAMAGE_2_MP_DROP_RATE_ADD = 78,				-- 比例将伤害值转换成消耗魔法值
	DIZZY_RATE_ADD = 79,					 		-- 增加物理攻击的时候让对方麻痹的概率，整数型,(万分比)
	DAMAGE_POWER = 80,								-- 伤害输出倍率增加,用于一些加攻击的药水
	ADD_PHYSICAL_DAMAGE_RATE = 81,					-- 物理伤害增加
	ADD_PHYSICAL_DAMAGE_VALUE= 82,					-- 物理伤害减少
	DAMAGE_2_SELF_HP_PRO = 83,						-- 对敌人伤血的时候，有概率给自己加血,整形的，1点表示万分之1
	DAMAGE_2_SELF_HP_RATE =84,						-- 对敌人伤血的时候，伤血的比例转给自己，浮点型,表示百分比
	SKILL_EXP_VALUE = 85,						 	-- 技能熟练度倍率增加
	ALARM_ADD = 86,									-- 被追踪报警
	ON_PRACTICE_MAP = 87,						 	-- 挂机地图中 
	ANGER_ADD = 88,									-- 增加怒气
	IN_MONSTER_MODEL = 89,							-- 变身状态，成了一个怪物
	DIE_REFRESH_HP_PRO = 90,						-- 复活戒指的间隔时间(复活戒指使用)
	ADD_BOLL_ON_HEAD = 91,							-- 杀死战队竞技BOSS的玩家头顶会显示1个球图 (没用今后开发占用它）
	ADD_RIDE_QUEST = 92,							-- 忽视目标防御增加
	NEW_PLAYER_PROTECT = 93,						-- 新手保护BUFF
	HP_2_DAMAGE_ADD = 94,							-- 暴击增加
	GET_ACTIVITY_EXP = 95,							-- 按经验库中给经验
	MOUNT_MIN_ATTACK_RATE_ADD = 96,					-- 神圣一击几率 整数
	MOUNT_MAX_ATTACK_RATE_ADD = 97,					-- 神圣一击伤害 整数
	MOUNT_MIN_PHY_DEFENCE_RATE_ADD = 98,			-- 降低受到神圣一击的几率 整数
	MOUNT_MAX_PHY_DEFENCE_RATE_ADD = 99,			-- 降低受到神圣一击的伤害 整数
	MOUNT_MIN_MAGIC_DEFENCE_RATE_ADD = 100,			-- 降低受到的物理伤害 整数
	MOUNT_MAX_MAGIC_DEFENCE_RATE_ADD = 101,			-- 降低受到的魔法、道术伤害 整数
	MOUNT_HP_RATE_ADD = 102,						-- 物理穿透 整数
	MOUNT_MP_RATE_ADD = 103,						-- 法术穿透 整数

	WEAPON_BASE_ATTR_PLUS = 104,					--武器基础属性加成 (万分比)整数型
	DRESS_BASE_ATTR_PLUS = 105,						--衣服基础属性加成 (万分比)整数型
	HELMET_BASE_ATTR_PLUS = 106,					--头盔基础属性加成 (万分比)整数型
	NECKLACE_BASE_ATTR_PLUS = 107,					--项链基础属性加成 (万分比)整数型
	LEFTBRACELET_BASE_ATTR_PLUS = 108,				--左边的手镯基础属性加成 (万分比)整数型
	RIGHTBRACELET_BASE_ATTR_PLUS = 109,			 	--右边的手镯基础属性加成 (万分比)整数型
	LEFTRING_BASE_ATTR_PLUS = 110,					--左边的戒指基础属性加成 (万分比)整数型
	RIGHTRING_BASE_ATTR_PLUS = 111,					--右边的戒指基础属性加成 (万分比)整数型
	GIRDLE_BASE_ATTR_PLUS = 112,					--腰带基础属性加成 (万分比)整数型 
	SHOES_BASE_ATTR_PLUS = 113,						--鞋子基础属性加成 (万分比)整数型

	FIRE_DEFENSE_RATE = 114,						-- 抗火率 使用1点表示1万分之1
	REDUCE_EQUIP_DROP_RATE = 115,					-- 减少玩家死亡爆装备几率 使用1点表示1万分之1
	DAMAGE_DROP_TIME = 116,							-- 收到伤害以后，状态时间减少，当buff删除的时候使用技能
	FIBID_MOVE = 117,					 			-- 禁止移动
	WARRIOR_DAMAGE_VALUE_DEC = 118,					-- 对战士伤害增加(整数，万分比)
	WARRIOR_DAMAGE_RATE_DEC = 119,					-- 受战士伤害减少(整数，万分比)
	MAGICIAN_DAMAGE_VALUE_DESC = 120,	 			-- 对法师伤害增加(整数，万分比)
	MAGICIAN_DAMAGE_RATE_DESC = 121,				-- 受法师伤害减少(整数，万分比)
	WIZARD_DAMAGE_VALUE_DESC = 122,					-- 对道士伤害增加(整数，万分比)
	WIZARD_DAMAGE_RATE_DESC = 123,					-- 受道士伤害减少(整数，万分比)
	MONSTER_DAMAGE_VALUE_DESC = 124,				-- 暴击伤害增加
	MONSTER_DAMAGE_RATE_DESC = 125,					-- 暴击伤害减少
	DAMAGE_REDUCE_RATE = 126,			 			-- 物理穿透增加
	DAMAGE_REDUCE_VALUE = 127,						-- 物理穿透减少
	DAMAGE_ADD_RATE = 128,			 				-- 触发伤害追加的几率(暴击率)(万分比)
	DAMAGE_ADD_VALUE = 129,							-- 触发伤害追加的值(暴击)
	IGNOR_DEFENCE_RATE = 130,			 			-- 魔法穿透增加
	IGNOR_DEFENCE_VALUE = 131,						-- 魔法穿透减少
	IN_CHG_PET = 132,								-- 变身状态,成了宠物,且属性进行叠加 变身技能使用32 BUFF组
	AARE_ADD_EXP = 133,								-- 指定区域添加经验
	CURSE_MARK_SKILL_RATE = 134,					-- 诅咒印记技能触发几率 1点表示1万分之1
	CURSE_MARK_SKILL_BUFFID = 135,					-- 诅咒印记BUFFID

	DAMAGE_2_SELF_MP_PRO = 137,						-- 致命伤害增加
	DAMAGE_2_SELF_MP_RATE = 138,					-- 伤害反弹减少
	ADD_HP_AND_ADD_MP = 139,						--  回血回蓝(特效BUff) 不按时间去计算，按一个药品的总量计算,想要按时间去同时加血加蓝，参考年糕这个物品配置
	ADD_AVOID_INJURY_MAX = 140,						-- 增加最大免伤值上限
	ADD_RESTORE_AVOID_INJURY = 141,					-- 增加每次恢复免伤的回复值
	ADD_REDUCTION_RATE = 142,						-- 免伤承受值
	ATTACK_BOSS_CRIT_RATE = 143,					-- 攻击BOSS暴击概率
	ATTACK_BOSS_CRIT_VALUE = 144,					-- 攻击BOSS暴击的值
	MAX_INNER_ADD = 145,							-- 最大内力增加
	MAX_INNER_POWER = 146,							-- 最大内力倍率增加
	INNER_RENEW_ADD = 147,							-- 每次恢复内力增加
	INNER_RENEW_POWER = 148,						-- 每次恢复内力倍率增加
	INNER_REDUCE_DAMAGE_ADD = 149,					-- 内力穿透
	INNER_REDUCE_DAMAGE_POWER = 150,				-- 内力减伤倍率增加(百分比)
	INNER_REDUCE_DAMAGE_RATE_ADD = 151,				-- 内力攻击
	INNER_REDUCE_DAMAGE_RATE_POWER = 152,			-- 内力攻击倍率增加(百分比)
	RESISTANC_ECRIT = 153,							--  抗暴力(1抗暴力 = 1暴击力)
	RESISTANCE_CRIT_RATE = 154,						--  红钻防御增加
	BROKEN_RELIVE_RATE = 155,						--  破复活率(万分比)
	DEF_DIZZY_RATE = 156,							--  防麻痹率(万分比)
	CRIT_RESISTANCE_RATE = 157,						--  暴力的抵消比率(万分比)(抗暴比)
	TO_BOSS_DAMAGE_RATE_ADD = 158,       				--  对BOSS伤害增加(整数，万分比)，仅针对怪物类型:4
	BY_BOSS_DAMAGE_RATE_DEC = 159,        				--  受BOSS伤害减少(整数，万分比)，仅针对怪物类型:4
	TO_ALL_DAMAGE_RATE_ADD = 160,         			--  伤害增加(整数，万分比)
	SUCK_BLOOD_RATE = 161,							--  吸血几率：攻击目标时，触发吸血值的几率(整数，万分比)
	ABSORB_HP = 162,								--  吸血值：攻击目标时，给自己增加生命值的值(整数)
	ADD_SKILL_LEVEL = 163,							--  增加技能等级
	RIGGER_REDUCE_ATTACKT_RATE = 164,     --  受到对方攻击时，诅咒几率=触发【降低对方攻击比】的几率    整形的，(万分比)
	REDUCE_OTHER_ATTACKT_VALUE = 165,     --  降低对方攻击比=受到攻击时，万分比减少受到的物理攻击、魔法攻击、道术攻击 整形的，(万分比)
	SUPER_SKILL_DAMAGE_TO_ACTOR = 166,		--  必杀技能对玩家的伤害(万分比)
	SUPER_SKILL_DAMAGE_TO_MONSTER = 167,	--  必杀技能对怪物的伤害(万分比)
	REMISSION_DAMAGE_OF_SUPER_SKILL = 168,	--  必杀伤害减免(万分比)
	FATAL_HIT_RATE = 169,				-- 致命一击几率 整数
	FATAL_HIT_DAMAGE = 170,				-- 致命一击伤害 整数
	REDUCE_FATAL_HIT_RATE = 171,			-- 降低受到致命一击的几率 整数
	RED_DIAMOND_HIT = 172,				-- 红钻攻击 整数
	YELLO_DIAMOND_HIT = 173,				-- 黄钻攻击 整数
	PURPLE_DIAMOND_HIT = 174,			-- 紫钻攻击 整数
	BLUE_DIAMOND_HIT = 175,				-- 蓝钻攻击 整数
	GREEN_DIAMOND_HIT = 176,				-- 绿钻攻击 整数
	RED_DIAMOND_DEFENCE = 177,			-- 红钻防御 整数
	YELLO_DIAMOND_DEFENCE = 178,			-- 黄钻防御 整数
	PURPLE_DIAMOND_DEFENCE = 179,		-- 紫钻防御 整数
	BLUE_DIAMOND_DEFENCE = 180,			-- 蓝钻防御 整数
	GREEN_DIAMOND_DEFENCE = 181,			-- 绿钻防御 整数
	PK_DAMAGE = 182,					-- PK攻击(万分比) 整数
	REDUCE_PK_DAMAGE = 183,				-- 抵消PK攻击伤害 整数
	REDUCE_CRIT_HIT_RATE = 184,			-- 降低被暴击的几率 整数
	REDUCE_FATAL_HIT_DAMAGE = 185,		-- 降低受致命一击的伤害 整数
	REFLECT_RATE = 186,					-- 触发反击伤害的万分比
	INSPIRE_ADD_ATTACK  = 187,			-- 鼓舞加功击力(3职业, 最小攻击-最大攻击) 整数
	HOLY_WORDS = 188,					-- 圣言(万分比) 整数
	HOLY_WORDPOWER = 189,				-- 圣言力(万分比) 整数

	AWARMBLOODELBOWPADSATTRPLUS = 190,	--热血面甲属性加成 (万分比)整数型
	AWARMBLOODSHOULDERPADSATTRPLUS = 191,	--热血护肩属性加成 (万分比)整数型
	AWARMBLOODPENDANTATTRPLUS = 192,		--热血吊坠属性加成 (万分比)整数型
	AWARMBLOODKNEECAPATTRPLUS = 193,		--热血护膝属性加成 (万分比)整数型
	ATTR_194 = 194, -- 暴击减伤
	ATTR_195 = 195, -- 魔法伤害增加
	ATTR_196 = 196, -- 伤害增加增加
	ATTR_197 = 197, -- 圣兽之力增加
	ATTR_198 = 198, -- 万壕增伤增加
	ATTR_199 = 199, -- 金壕增伤增加
	ATTR_200 = 200, -- 雄壕增伤增加
	ATTR_201 = 201, -- 伤害减免增加
	ATTR_202 = 202, -- 圣兽之御增加
	ATTR_203 = 203, -- 万壕减伤增加
	ATTR_204 = 204, -- 金壕减伤增加
	ATTR_205 = 205, -- 雄壕减伤增加
	ATTR_206 = 206, -- 吸血伤害增加
	ATTR_208 = 208, -- 技能追伤增加
	ATTR_209 = 209, -- 切割伤害增加
	ATTR_210 = 210, -- MP抵伤减少
	ATTR_210 = 210, -- 对第一大陆BOSS伤害增加
	ATTR_211 = 211, -- 对第二大陆BOSS伤害增加
	ATTR_212 = 212, -- 对第三大陆BOSS伤害增加
	ATTR_213 = 213, -- 对第四大陆BOSS伤害增加
	ATTR_214 = 214, -- 对第五大陆BOSS伤害增加
	ATTR_215 = 215, -- 对第一大陆BOSS伤害加成
	ATTR_216 = 216, -- 对第二大陆BOSS伤害加成
	ATTR_217 = 217, -- 对第三大陆BOSS伤害加成
	ATTR_218 = 218, -- 对第四大陆BOSS伤害加成
	ATTR_219 = 219, -- 对第四大陆BOSS伤害加成
	ATTR_220 = 220, -- 对第五大陆BOSS伤害加成
	ATTR_221 = 221, -- 对第一大陆BOSS狂暴几率
	ATTR_222 = 222, -- 对第二大陆BOSS狂暴几率
	ATTR_223 = 223, -- 对第三大陆BOSS狂暴几率
	ATTR_224 = 224, -- 对第四大陆BOSS狂暴几率
	ATTR_225 = 225, -- 对第五大陆BOSS狂暴几率
	ATTR_226 = 226, -- 对第一大陆BOSS狂暴伤害
	ATTR_227 = 227, -- 对第二大陆BOSS狂暴伤害
	ATTR_228 = 228, -- 对第三大陆BOSS狂暴伤害
	ATTR_229 = 229, -- 对第四大陆BOSS狂暴伤害
	ATTR_230 = 230, -- 对第五大陆BOSS狂暴伤害
	ATTR_231 = 231, -- 受第一大陆BOSS攻击减少
	ATTR_232 = 232, -- 受第二大陆BOSS攻击减少
	ATTR_233 = 233, -- 受第三大陆BOSS攻击减少
	ATTR_234 = 234, -- 受第四大陆BOSS攻击减少
	ATTR_235 = 235, -- 受第五大陆BOSS攻击减少
	ATTR_236 = 236, -- 破天一击 攻击目标时，触发破天伤害[237]的几率
	ATTR_237 = 237, -- 破天伤害 攻击目标时，在触发破天一击[236]时，增加破天伤害[237] 额外伤害的数值，1点破天伤害[237]，时额外增加1点伤害
	ATTR_238 = 238, -- 破天减伤 受到攻击时，减少破天伤害[237]的数值，1点受 破天减伤[238] 减少减少1点破天伤害[237]
	ATTR_239 = 239, -- 破天抵抗 受到攻击时，减少目标对自己 破天一击[]的几率
	ATTR_240 = 240, -- 破天一击增加 百分比增加破天一击[236]数值，1%破天一击增加[240] 额外增加 1%破天一击[236]
	ATTR_241 = 241, -- 破天伤害增加 百分比增加破天伤害[237]数值，1%破天伤害增加[241] 额外增加 1%破天伤害[237]
	ATTR_242 = 242, -- 破天伤害减少百分比增加破天减伤[238]数值，1%破天伤害增加[242] 额外增加 1%破天减伤[238]
	ATTR_243 = 243, -- 被破天一击减少受攻击时，百分比减少目标对自己的破天一击[236]，1%被破天一击减少[243] 减少 1%目标的破天一击[236]属性
	ATTR_244 = 244, -- 伤害加成减少 伤害加成减少，减少目标对自己的[160.伤害加成]，1%伤害加成减少  减少 1%[160.伤害加成]   ([伤害加成减少]为万分比)

	GAME_ATTRIBUTE_COUNT = 244,
}

-- 特定额外属性
SPECIAL_ATTR_TYPE = {
	ATTACK_SUPPRESS = 6,  				-- 压制（战鼓威望值高低）
}

-- 基础属性
BASE_ATTR_TYPES = {
	[9] = 1,
	[11] = 1,
	[13] = 1,
	[15] = 1,
	[17] = 1,
	[19] = 1,
	[21] = 1,
	[23] = 1,
	[25] = 1,
	[27] = 1,
	[5] = 1,
}

eAttribueTypeDataType = {
	adVoid = 0,			--VOID类型值
	adSmall = 1,		--有符号1字节类型
	adUSmall = 2,		--无符号1字节类型
	adShort = 3,		--有符号2字节类型
	adUShort = 4,		--无符号2字节类型
	adInt = 5,			--有符号4字节类型
	adUInt = 6,			--无符号4字节类型
	adFloat = 7,		--单精度浮点类型值
}

AttrDataTypes = {

	[0] = eAttribueTypeDataType.adInt,				-- 未定义属性
	eAttribueTypeDataType.adInt,-- 血增加
	eAttribueTypeDataType.adFloat,					-- 血倍率增加
	eAttribueTypeDataType.adInt ,					-- 蓝增加
	eAttribueTypeDataType.adFloat,					-- 蓝倍率增加
	eAttribueTypeDataType.adInt,					-- 最大血增加
	eAttribueTypeDataType.adFloat,				-- 最大血倍率增加
	eAttribueTypeDataType.adInt,					-- 最大蓝增加
	eAttribueTypeDataType.adFloat,				-- 最大蓝倍率增加
	eAttribueTypeDataType.adInt,	-- 最小物理攻击增加
	eAttribueTypeDataType.adFloat,	-- 最小物理攻击倍率增加(10)

	eAttribueTypeDataType.adInt,	-- 最大物理攻击增加
	eAttribueTypeDataType.adFloat,	-- 最大物理攻击倍率增加
	eAttribueTypeDataType.adInt,		-- 最小魔法攻击增加
	eAttribueTypeDataType.adFloat,	-- 最小魔法攻击倍率增加
	eAttribueTypeDataType.adInt,		-- 最大魔法攻击增加
	eAttribueTypeDataType.adFloat,	-- 最大魔法攻击倍率增加
	eAttribueTypeDataType.adInt,	-- 最小道术攻击增加
	eAttribueTypeDataType.adFloat,	-- 最小道术攻击倍率增加
	eAttribueTypeDataType.adInt,	-- 最大道术攻击增加
	eAttribueTypeDataType.adFloat,	-- 最大道术攻击倍率增加(20)

	eAttribueTypeDataType.adInt,		-- 最小物理防御增加
	eAttribueTypeDataType.adFloat,	-- 最小物理防御倍率增加
	eAttribueTypeDataType.adInt,		-- 最大物理防御增加
	eAttribueTypeDataType.adFloat,	-- 最大物理防御倍率增加
	eAttribueTypeDataType.adInt,		-- 最小魔法防御增加
	eAttribueTypeDataType.adFloat,		-- 最小魔法防御倍率增加
	eAttribueTypeDataType.adInt,		-- 最大魔法防御增加
	eAttribueTypeDataType.adFloat,		-- 最大魔法防御倍率增加
	eAttribueTypeDataType.adInt,		-- 准确增加
	eAttribueTypeDataType.adFloat,		-- 准确倍率增加(30)

	eAttribueTypeDataType.adInt,		-- 敏捷增加
	eAttribueTypeDataType.adFloat,		-- 敏捷倍率增加
	eAttribueTypeDataType.adFloat,		-- 魔法命中增加
	eAttribueTypeDataType.adFloat,			-- 魔法命中倍率增加
	eAttribueTypeDataType.adFloat,		-- 魔法闪避增加
	eAttribueTypeDataType.adFloat,		-- 魔法闪避倍率增加
	eAttribueTypeDataType.adFloat,		-- 毒物闪避增加
	eAttribueTypeDataType.adFloat,		-- 毒物闪避倍率增加
	eAttribueTypeDataType.adInt,		--  生命恢复增加(整型)
	eAttribueTypeDataType.adFloat,		--  生命恢复倍率增加(40)

	eAttribueTypeDataType.adFloat,		-- 魔法恢复增加
	eAttribueTypeDataType.adFloat,		-- 魔法恢复倍率增加
	eAttribueTypeDataType.adFloat,		-- 毒物恢复增加
	eAttribueTypeDataType.adFloat,		-- 毒物恢复倍率增加
	eAttribueTypeDataType.adInt,		-- 幸运 增加
	eAttribueTypeDataType.adFloat,		-- 幸运倍率增加
	eAttribueTypeDataType.adInt,		-- 诅咒增加
	eAttribueTypeDataType.adFloat,		-- 诅咒倍率增加
	eAttribueTypeDataType.adInt,		-- 移动速度增加
	eAttribueTypeDataType.adFloat,		-- 移动速度倍率增加(50)


	eAttribueTypeDataType.adInt,		-- 攻击速度增加
	eAttribueTypeDataType.adFloat,		-- 攻击速度倍率增加
	eAttribueTypeDataType.adInt ,  		-- 伤害吸收,自己或队友施放护盾，吸收N点伤害
	eAttribueTypeDataType.adFloat,	 -- 按比例吸收伤害,降低一定百分比的所受伤害 -- 为整型
	eAttribueTypeDataType.adFloat,	--  神圣伤害增加
	eAttribueTypeDataType.adInt,							 -- 麻痹,不可移动，不可释放技能
	eAttribueTypeDataType.adInt,				-- 免疫各种控制技能
	eAttribueTypeDataType.adInt,                        -- 经验增加一个数值
	eAttribueTypeDataType.adInt,                          -- 嘲讽
	eAttribueTypeDataType.adInt,                        -- 无敌,能攻击，不能被攻击 (60)

	eAttribueTypeDataType.adInt,                   -- 复活保护状态
	eAttribueTypeDataType.adInt,                          -- 使用一个buff的效果是定时使用技能
	eAttribueTypeDataType.adInt,                               -- 隐身
	eAttribueTypeDataType.adFloat,                           -- 经验的增加的倍率
	eAttribueTypeDataType.adInt,                         -- 杀戮值(pk值)的增减
	eAttribueTypeDataType.adFloat,             -- 神圣伤害减少
	eAttribueTypeDataType.adInt,                    -- pk保护状态
	eAttribueTypeDataType.adInt,					 -- 技能攻击的时候 攻击伤害追加n点（以固定值的方式影响角色造成的内功与外功攻击伤害）
	eAttribueTypeDataType.adFloat,               -- 篝火喝酒的时候经验的加成,+%n
	eAttribueTypeDataType.adInt,                -- 神圣增加 (70)

	eAttribueTypeDataType.adInt,					-- 破护身(减少比例比例将伤害值转换成消耗魔法值)
	eAttribueTypeDataType.adInt,					-- 破护身(减少比例比例将伤害值转换成消耗魔法值)cd
	eAttribueTypeDataType.adInt,                -- 破击几率(有一定几率触发额外的破击伤害（攻击的2倍，固定倍数）
	eAttribueTypeDataType.adInt,              -- 抗破击 受到破击伤害时，按照比例抵消破击伤害
	eAttribueTypeDataType.adFloat,				-- 内力减伤

	eAttribueTypeDataType.adInt,			 -- 复活血量万分比

	eAttribueTypeDataType.adFloat ,             -- 致命伤害减少
	eAttribueTypeDataType.adFloat,            -- 比例将伤害值转换成消耗魔法值
	eAttribueTypeDataType.adInt,           -- 麻痹增加
	eAttribueTypeDataType.adFloat,			-- 伤害输出倍率增加 (80)

	eAttribueTypeDataType.adFloat,              -- 物理伤害增加
	eAttribueTypeDataType.adFloat,              -- 物理伤害减少"
	eAttribueTypeDataType.adInt,               -- 对敌人伤血的时候，有概率给自己加血,整形的，1点表示万分之1
	eAttribueTypeDataType.adFloat,			 -- 对敌人伤血的时候，伤血的比例转给自己，浮点型,表示百分比
	eAttribueTypeDataType.adInt,              -- 技能熟练度倍率增加 
	eAttribueTypeDataType.adInt,				-- 被追踪报警
	eAttribueTypeDataType.adInt,              -- 挂机地图中
	eAttribueTypeDataType.adFloat,              -- 怒气增加
	eAttribueTypeDataType.adInt,				-- 变身状态，成了一个怪物
	eAttribueTypeDataType.adInt,                         -- 死亡以后立刻回复的HP的比例(复活戒指使用) (90)


	eAttribueTypeDataType.adInt,					-- 破护身触发几率(万分比)
	eAttribueTypeDataType.adFloat,					-- 忽视目标防御增加
	eAttribueTypeDataType.adInt,					-- 新手保护BUFF
	eAttribueTypeDataType.adFloat,					-- 暴击增加
	eAttribueTypeDataType.adInt,                  -- 按经验库中给经验


	eAttribueTypeDataType.adInt,			   -- 神圣一击几率(整数,万分比)
	eAttribueTypeDataType.adInt,			   -- 神圣一击伤害
	eAttribueTypeDataType.adInt,			   -- 降低受到神圣一击的几率
	eAttribueTypeDataType.adInt,			   -- 降低受到神圣一击的伤害
	eAttribueTypeDataType.adInt,			   -- 降低受到的物理伤害

	eAttribueTypeDataType.adInt,			   -- 降低受到的魔法、道术伤害
	eAttribueTypeDataType.adInt,			   -- 物理穿透
	eAttribueTypeDataType.adInt,			   -- 法术穿透			

	eAttribueTypeDataType.adInt,                -- 宝石最小攻击增加
	eAttribueTypeDataType.adInt,                -- 宝石最大攻击增加
	eAttribueTypeDataType.adInt,             -- 宝石最小物理防御增加
	eAttribueTypeDataType.adInt,            -- 宝石最大物理防御增加
	eAttribueTypeDataType.adInt,               -- 宝石最小魔法防御增加
	eAttribueTypeDataType.adInt,                -- 宝石最大魔法防御增加
	eAttribueTypeDataType.adInt,							-- 宝石增加的生命的增加 110

	eAttribueTypeDataType.adInt,							-- 宝石增加的魔法的增加

	eAttribueTypeDataType.adInt,					-- 经验玉额外经验加成
	eAttribueTypeDataType.adInt,					-- 英雄杀怪经验加成
	eAttribueTypeDataType.adInt,					-- 抗火率
	eAttribueTypeDataType.adInt,					-- 减少玩家死亡爆装备几率
	eAttribueTypeDataType.adInt,                  -- 收到伤害以后，状态时间减少，当buff删除的时候使用技能
	eAttribueTypeDataType.adInt,                  -- 禁止移动

	eAttribueTypeDataType.adInt,             -- 对战士伤害增加(整数，万分比)
	eAttribueTypeDataType.adInt,             -- 受战士伤害减少(整数，万分比)

	eAttribueTypeDataType.adInt,             -- 对法师伤害增加(整数，万分比)   120
	eAttribueTypeDataType.adInt,			   -- 受法师伤害减少(整数，万分比)

	eAttribueTypeDataType.adInt,             -- 对道士伤害增加(整数，万分比)
	eAttribueTypeDataType.adInt,			   -- 受道士伤害减少(整数，万分比)

	eAttribueTypeDataType.adFloat,             -- 暴击伤害增加
	eAttribueTypeDataType.adFloat,			   -- 暴击伤害减少


	eAttribueTypeDataType.adFloat,             -- 物理穿透增加
	eAttribueTypeDataType.adFloat,			    -- 物理穿透减少

	eAttribueTypeDataType.adInt,             -- 触发伤害追加的几率
	eAttribueTypeDataType.adInt,			   -- 触发伤害追加的值  

	eAttribueTypeDataType.adFloat,             -- 魔法穿透增加  130
	eAttribueTypeDataType.adFloat,			   -- 魔法穿透减少
	eAttribueTypeDataType.adInt,				-- 变身状态,成了宠物,且属性进行叠加
	eAttribueTypeDataType.adInt,				-- 区域增加经验

	eAttribueTypeDataType.adInt,				-- 诅咒印记技能触发几率
	eAttribueTypeDataType.adInt,				-- 诅咒印记BUFFID

	-- 前端136被使用了,是奖励倍数
	eAttribueTypeDataType.adVoid,

	eAttribueTypeDataType.adFloat,				-- 致命伤害增加
	eAttribueTypeDataType.adFloat,				-- 伤害反弹减少

	eAttribueTypeDataType.adInt,				-- 回蓝回血

	eAttribueTypeDataType.adFloat,				-- 攻击伤害减少    140
	eAttribueTypeDataType.adFloat,				-- 攻击伤害增加
	eAttribueTypeDataType.adFloat,				-- 魔法伤害减少

	eAttribueTypeDataType.adInt,				-- 攻击BOSS暴击概率
	eAttribueTypeDataType.adInt,				-- 攻击BOSS暴击的值

	eAttribueTypeDataType.adUInt,				-- 最大内力增加
	eAttribueTypeDataType.adFloat,				-- 最大内力倍率增加

	eAttribueTypeDataType.adInt,				-- 每次恢复内力增加
	eAttribueTypeDataType.adFloat,				-- 每次恢复内力倍率增加
	
	eAttribueTypeDataType.adInt,				-- 内力穿透
	eAttribueTypeDataType.adFloat,				-- 内力穿透倍率增加(百分比)		150

	eAttribueTypeDataType.adInt,				-- 内力攻击
	eAttribueTypeDataType.adFloat,				-- 内力攻击倍率增加(百分比)

	eAttribueTypeDataType.adInt,				--  抗暴力(1抗暴力 = 1暴击力)
	eAttribueTypeDataType.adFloat,				--  红钻防御增加

	eAttribueTypeDataType.adInt,				--  破复活率(万分比)
	eAttribueTypeDataType.adInt,				--  防麻痹率(万分比)

	eAttribueTypeDataType.adInt,				--  暴力的抵消比率(万分比)

	eAttribueTypeDataType.adInt,				--  对BOSS伤害增加(整数，万分比)，仅针对怪物类型:4
	eAttribueTypeDataType.adInt,				--  受BOSS伤害减少(整数，万分比)，仅针对怪物类型:4

	eAttribueTypeDataType.adInt,				--  伤害增加(整数，万分比)			160
	eAttribueTypeDataType.adInt,				--  吸血几率：攻击目标时，触发吸血值的几率(整数，万分比)
	eAttribueTypeDataType.adInt,				--  吸血值：攻击目标时，给自己增加生命值的值(整数)
	eAttribueTypeDataType.adInt,				--  增加技能等级
	eAttribueTypeDataType.adInt,			--  受到对方攻击时，诅咒几率=触发【降低对方攻击比】的几率    整形的，(万分比)
	eAttribueTypeDataType.adInt,			--  降低对方攻击比=受到攻击时，万分比减少受到的物理攻击、魔法攻击、道术攻击 整形的，(万分比)
	eAttribueTypeDataType.adInt,			--  合击技能对玩家的伤害(万分比)
	eAttribueTypeDataType.adInt,			--  合击技能对怪物的伤害(万分比)
	eAttribueTypeDataType.adInt,			--  必杀伤害减免(万分比)
	eAttribueTypeDataType.adInt,			   -- 致命一击几率(整数,万分比)

	eAttribueTypeDataType.adInt,			   -- 致命一击伤害 170
	eAttribueTypeDataType.adInt,			   -- 降低受到致命一击的几率
	eAttribueTypeDataType.adInt,			   -- 红钻攻击
	eAttribueTypeDataType.adInt,			   -- 黄钻攻击
	eAttribueTypeDataType.adInt,			   -- 紫钻攻击
	eAttribueTypeDataType.adInt,			   -- 蓝钻攻击
	eAttribueTypeDataType.adInt,			   -- 绿钻攻击
	eAttribueTypeDataType.adInt,			   -- 红钻防御
	eAttribueTypeDataType.adInt,			   -- 黄钻防御			
	eAttribueTypeDataType.adInt,			   -- 紫钻防御

	eAttribueTypeDataType.adInt,			   -- 蓝钻防御 180
	eAttribueTypeDataType.adInt,			   -- 绿钻防御
	eAttribueTypeDataType.adInt,			   -- PK攻击(万分比)
	eAttribueTypeDataType.adInt,			   -- 抵消PK攻击伤害
	eAttribueTypeDataType.adInt,			   -- 降低被暴击的几率
	eAttribueTypeDataType.adInt,			   -- 降低受致命一击的伤害
	eAttribueTypeDataType.adInt,			  -- 触发反击伤害值
	eAttribueTypeDataType.adInt,			  -- 鼓舞加功击力(3职业, 最小攻击-最大攻击) 整数
	eAttribueTypeDataType.adInt,			  -- 圣言(万分比) 整数
	eAttribueTypeDataType.adInt,			  -- 圣言力(万分比) 整数

	eAttribueTypeDataType.adInt,			  -- 热血面甲属性加成(万分比) 整数 190
	eAttribueTypeDataType.adInt,			  -- 热血护肩属性加成(万分比) 整数
	eAttribueTypeDataType.adInt,			  -- 热血吊坠属性加成(万分比) 整数
	eAttribueTypeDataType.adInt,			  -- 热血护膝属性加成(万分比) 整数
	[194] = eAttribueTypeDataType.adInt,	 -- "暴击减伤", 
	[195] = eAttribueTypeDataType.adFloat,	 -- "魔法伤害增加",
	[196] = eAttribueTypeDataType.adFloat,	 -- "伤害增加增加",
	[197] = eAttribueTypeDataType.adFloat,	 -- "圣兽之力增加",
	[198] = eAttribueTypeDataType.adFloat,	 -- "万壕增伤增加",
	[199] = eAttribueTypeDataType.adFloat,	 -- "金壕增伤增加",

	[200] = eAttribueTypeDataType.adFloat,	 -- "雄壕增伤增加", 200
	[201] = eAttribueTypeDataType.adFloat,	 -- "伤害减免增加",
	[202] = eAttribueTypeDataType.adFloat,	 -- "圣兽之御增加",
	[203] = eAttribueTypeDataType.adFloat,	 -- "万壕减伤增加",
	[204] = eAttribueTypeDataType.adFloat,	 -- "金壕减伤增加",
	[205] = eAttribueTypeDataType.adFloat,	 -- "雄壕减伤增加",
	[206] = eAttribueTypeDataType.adFloat,	 -- "吸血伤害增加",
	[208] = eAttribueTypeDataType.adFloat,	 -- "技能追伤增加",
	[209] = eAttribueTypeDataType.adFloat,	 -- "切割伤害增加",

	[210] = eAttribueTypeDataType.adFloat,	 -- "MP抵伤减少", 210
	[211] = eAttribueTypeDataType.adFloat,	 -- 对第一大陆BOSS伤害增加
	[212] = eAttribueTypeDataType.adFloat,	 -- 对第二大陆BOSS伤害增加
	[213] = eAttribueTypeDataType.adFloat,	 -- 对第三大陆BOSS伤害增加
	[214] = eAttribueTypeDataType.adFloat,	 -- 对第四大陆BOSS伤害增加
	[215] = eAttribueTypeDataType.adFloat,	 -- 对第五大陆BOSS伤害增加
	[216] = eAttribueTypeDataType.adFloat,	 -- 对第一大陆BOSS伤害加成
	[217] = eAttribueTypeDataType.adFloat,	 -- 对第二大陆BOSS伤害加成
	[218] = eAttribueTypeDataType.adFloat,	 -- 对第三大陆BOSS伤害加成
	[219] = eAttribueTypeDataType.adFloat,	 -- 对第四大陆BOSS伤害加成
	[220] = eAttribueTypeDataType.adFloat,	 -- 对第五大陆BOSS伤害加成
	[221] = eAttribueTypeDataType.adFloat,	 -- 对第一大陆BOSS狂暴几率
	[222] = eAttribueTypeDataType.adFloat,	 -- 对第二大陆BOSS狂暴几率
	[223] = eAttribueTypeDataType.adFloat,	 -- 对第三大陆BOSS狂暴几率
	[224] = eAttribueTypeDataType.adFloat,	 -- 对第四大陆BOSS狂暴几率
	[225] = eAttribueTypeDataType.adFloat,	 -- 对第五大陆BOSS狂暴几率
	[226] = eAttribueTypeDataType.adFloat,	 -- 对第一大陆BOSS狂暴伤害
	[227] = eAttribueTypeDataType.adFloat,	 -- 对第二大陆BOSS狂暴伤害
	[228] = eAttribueTypeDataType.adFloat,	 -- 对第三大陆BOSS狂暴伤害
	[229] = eAttribueTypeDataType.adFloat,	 -- 对第四大陆BOSS狂暴伤害
	[230] = eAttribueTypeDataType.adFloat,	 -- 对第五大陆BOSS狂暴伤害
	[231] = eAttribueTypeDataType.adFloat,	 -- 受第一大陆BOSS攻击减少
	[232] = eAttribueTypeDataType.adFloat,	 -- 受第二大陆BOSS攻击减少
	[233] = eAttribueTypeDataType.adFloat,	 -- 受第三大陆BOSS攻击减少
	[234] = eAttribueTypeDataType.adFloat,	 -- 受第四大陆BOSS攻击减少
	[235] = eAttribueTypeDataType.adFloat,	 -- 受第五大陆BOSS攻击减少
	[236] = eAttribueTypeDataType.adFloat,	 -- 破天一击 攻击目标时，触发破天伤害[237]的几率
	[237] = eAttribueTypeDataType.adFloat,	 -- 破天伤害 攻击目标时，在触发破天一击[236]时，增加破天伤害[237] 额外伤害的数值，1点破天伤害[237]，时额外增加1点伤害
	[238] = eAttribueTypeDataType.adFloat,	 -- 破天减伤 受到攻击时，减少破天伤害[237]的数值，1点受 破天减伤[238] 减少减少1点破天伤害[237]
	[239] = eAttribueTypeDataType.adFloat,	 -- 破天抵抗 受到攻击时，减少目标对自己 破天一击[]的几率
	[240] = eAttribueTypeDataType.adFloat,	 -- 破天一击增加 百分比增加破天一击[236]数值，1%破天一击增加[240] 额外增加 1%破天一击[236]
	[241] = eAttribueTypeDataType.adFloat,	 -- 破天伤害增加 百分比增加破天伤害[237]数值，1%破天伤害增加[241] 额外增加 1%破天伤害[237]
	[242] = eAttribueTypeDataType.adFloat,	 -- 破天伤害减少 百分比增加破天减伤[238]数值，1%破天伤害增加[242] 额外增加 1%破天减伤[238]
	[243] = eAttribueTypeDataType.adFloat,	 -- 被破天一击减少 受攻击时，百分比减少目标对自己的破天一击[236]，1%被破天一击减少[243] 减少 1%目标的破天一击[236]属性
	[244] = eAttribueTypeDataType.adInt,	 -- 伤害加成减少 伤害加成减少，减少目标对自己的[160.伤害加成]，1%伤害加成减少  减少 1%[160.伤害加成]   ([伤害加成减少]为万分比)

}

-- 属性格式信息
GAME_ATTRIBUTE_FORMAT = {
	[GAME_ATTRIBUTE_TYPE.DIZZY_RATE_ADD] = {val_rate = 0.0001},
	[GAME_ATTRIBUTE_TYPE.DAMAGE_ADD_RATE] = {val_rate = 0.0001},
	[GAME_ATTRIBUTE_TYPE.INNER_REDUCE_DAMAGE_POWER] = {val_rate = 0.0001},
	[GAME_ATTRIBUTE_TYPE.BROKEN_RELIVE_RATE] = {val_rate = 0.0001},
	[GAME_ATTRIBUTE_TYPE.DEF_DIZZY_RATE] = {val_rate = 0.0001},
	[GAME_ATTRIBUTE_TYPE.CRIT_RESISTANCE_RATE] = {val_rate = 0.0001},
	[GAME_ATTRIBUTE_TYPE.WARRIOR_DAMAGE_VALUE_DEC] = {val_rate = 0.0001},
	[GAME_ATTRIBUTE_TYPE.WARRIOR_DAMAGE_RATE_DEC] = {val_rate = 0.0001},
	[GAME_ATTRIBUTE_TYPE.MAGICIAN_DAMAGE_VALUE_DESC] = {val_rate = 0.0001},
	[GAME_ATTRIBUTE_TYPE.MAGICIAN_DAMAGE_RATE_DESC] = {val_rate = 0.0001},
	[GAME_ATTRIBUTE_TYPE.WIZARD_DAMAGE_VALUE_DESC] = {val_rate = 0.0001},
	[GAME_ATTRIBUTE_TYPE.WIZARD_DAMAGE_RATE_DESC] = {val_rate = 0.0001},
	[GAME_ATTRIBUTE_TYPE.ATTACK_BOSS_CRIT_RATE] = {val_rate = 0.0001},
	[GAME_ATTRIBUTE_TYPE.TO_ALL_DAMAGE_RATE_ADD] = {val_rate = 0.0001},
	[GAME_ATTRIBUTE_TYPE.RIGGER_REDUCE_ATTACKT_RATE] = {val_rate = 0.0001},
	[GAME_ATTRIBUTE_TYPE.REDUCE_OTHER_ATTACKT_VALUE] = {val_rate = 0.0001},
	[GAME_ATTRIBUTE_TYPE.SUPER_SKILL_DAMAGE_TO_ACTOR] = {val_rate = 0.0001},
	[GAME_ATTRIBUTE_TYPE.SUPER_SKILL_DAMAGE_TO_MONSTER] = {val_rate = 0.0001},
	[GAME_ATTRIBUTE_TYPE.REMISSION_DAMAGE_OF_SUPER_SKILL] = {val_rate = 0.0001},
	[GAME_ATTRIBUTE_TYPE.SUCK_BLOOD_RATE] = {val_rate = 0.0001},
	[GAME_ATTRIBUTE_TYPE.ARM_POWER_POWER] = {val_rate = 0.0001},
	[GAME_ATTRIBUTE_TYPE.MOUNT_MIN_ATTACK_RATE_ADD] = {val_rate = 0.0001},
	[GAME_ATTRIBUTE_TYPE.MOUNT_MIN_PHY_DEFENCE_RATE_ADD] = {val_rate = 0.0001},
	[GAME_ATTRIBUTE_TYPE.DAMAGE_2_SELF_HP_PRO] = {val_rate = 0.0001},
	[GAME_ATTRIBUTE_TYPE.WEAPON_BASE_ATTR_PLUS] = {val_rate = 0.0001},
	[GAME_ATTRIBUTE_TYPE.DRESS_BASE_ATTR_PLUS] = {val_rate = 0.0001},
	[GAME_ATTRIBUTE_TYPE.HELMET_BASE_ATTR_PLUS] = {val_rate = 0.0001},
	[GAME_ATTRIBUTE_TYPE.NECKLACE_BASE_ATTR_PLUS] = {val_rate = 0.0001},
	[GAME_ATTRIBUTE_TYPE.LEFTBRACELET_BASE_ATTR_PLUS] = {val_rate = 0.0001},
	[GAME_ATTRIBUTE_TYPE.RIGHTBRACELET_BASE_ATTR_PLUS] = {val_rate = 0.0001},
	[GAME_ATTRIBUTE_TYPE.LEFTRING_BASE_ATTR_PLUS] = {val_rate = 0.0001},
	[GAME_ATTRIBUTE_TYPE.RIGHTRING_BASE_ATTR_PLUS] = {val_rate = 0.0001},
	[GAME_ATTRIBUTE_TYPE.GIRDLE_BASE_ATTR_PLUS] = {val_rate = 0.0001},
	[GAME_ATTRIBUTE_TYPE.EQUIP_MAX_WEIGHT_ADD] = {val_rate = 0.0001},
	[GAME_ATTRIBUTE_TYPE.SHOES_BASE_ATTR_PLUS] = {val_rate = 0.0001},
	[GAME_ATTRIBUTE_TYPE.BAG_MAX_WEIGHT_ADD] = {val_rate = 0.0001},
	[GAME_ATTRIBUTE_TYPE.HOLY_WORDS] = {val_rate = 0.0001},
	[GAME_ATTRIBUTE_TYPE.HOLY_WORDPOWER] = {val_rate = 0.0001},
	-- [GAME_ATTRIBUTE_TYPE.DAMAGE_ABSORB_RATE] = {val_rate = 0.0001},
	--[GAME_ATTRIBUTE_TYPE.PHYSICAL_ATTACK_MIN_POWER] = {val_rate = 0.0001},
	--[GAME_ATTRIBUTE_TYPE.PHYSICAL_ATTACK_MAX_POWER] = {val_rate = 0.0001},
	--[GAME_ATTRIBUTE_TYPE.PHYSICAL_DEFENCE_MIN_POWER] = {val_rate = 0.0001},
	--[GAME_ATTRIBUTE_TYPE.PHYSICAL_DEFENCE_MAX_POWER] = {val_rate = 0.0001},
	[GAME_ATTRIBUTE_TYPE.REFLECT_RATE] = {val_rate = 0.0001},

	[GAME_ATTRIBUTE_TYPE.AWARMBLOODELBOWPADSATTRPLUS] = {val_rate = 0.0001},
	[GAME_ATTRIBUTE_TYPE.AWARMBLOODSHOULDERPADSATTRPLUS] = {val_rate = 0.0001},
	[GAME_ATTRIBUTE_TYPE.AWARMBLOODPENDANTATTRPLUS] = {val_rate = 0.0001},
	[GAME_ATTRIBUTE_TYPE.AWARMBLOODKNEECAPATTRPLUS] = {val_rate = 0.0001},

	[GAME_ATTRIBUTE_TYPE.FATAL_HIT_RATE] = {val_rate = 0.0001},  --致命一击
	[GAME_ATTRIBUTE_TYPE.REDUCE_FATAL_HIT_RATE] = {val_rate = 0.0001}, -- 致命抵抗


	[GAME_ATTRIBUTE_TYPE.PK_DAMAGE] = {val_rate = 0.0001},  -- PK攻击(万分比) 整数
	[GAME_ATTRIBUTE_TYPE.REDUCE_PK_DAMAGE] = {val_rate = 0.0001},  -- 抵消PK攻击伤害 整数

	[GAME_ATTRIBUTE_TYPE.ATTR_244] = {val_rate = 0.0001}, -- 伤害加成减少 伤害加成减少，减少目标对自己的[160.伤害加成]，1%伤害加成减少  减少 1%[160.伤害加成]   ([伤害加成减少]为万分比)
}

	

-- 定义buff的分组归类
BUFF_GROUP = {
	SYSTEM_BUFF = 0,								-- 系统默认的BUFF组
	
	USER_BUFF_MIN = 32,								-- 可以由开发者自定义的BUFF组的起始值
	SKILL_BUFF_MIN = 32, 							-- 技能的最小的group
	SKILL_BUFF_MAX = 80,							-- 技能的最大的group

	PARALYSIS = 81,									-- 麻痹

	ITEM_BUFF_MIN = 81,								-- 物品的最小的组
	MULTI_EXP_ROLLER = 100,							-- 多倍经验卷
	-- MAGIC_SHIELD = 112,								-- 魔法盾
	HUTI_SHIELD = 112,								-- 护体盾
	POISONED = 114,									-- 中毒
	HIDE = 115,										-- 大隐身术
	HUTISHU = 116,									-- 大护体术
	BLOOD_RETURNING = 119,							-- 缓慢回血（天山雪莲）
	USER_BUFF_MAX = 127,							-- 可以由开发者自定义的BUFF组的结束值
	ITEM_BUFF_MAX =127,								-- 物品组的最大值

	VIP_MULTI_EXP = 133,							-- VIP多倍经验组

	GUILD_BUFF_MIN = 128,							-- 行会buff最小的组
	GUILD_BUFF_MAX = 200,							-- 行会buff结束值

	ANY_BUFF_GROUP = -1,							-- 用于匹配任何组中的buff
	MAX_BUFF_GROUP = 255,							-- buff分组最大值
}
