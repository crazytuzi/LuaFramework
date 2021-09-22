GameConst={
	WIN_WIDTH=1136,
	WIN_HEIGHT=640,
	VISIBLE_X		= cc.Director:getInstance():getVisibleOrigin().x,
	VISIBLE_Y		= cc.Director:getInstance():getVisibleOrigin().y,
	VISIBLE_WIDTH	= cc.Director:getInstance():getVisibleSize().width,
	VISIBLE_HEIGHT	= cc.Director:getInstance():getVisibleSize().height,
	
	SHOW_R_MENU		= 1,
	SHOW_R_VIP		= 2,
	SHOW_R_ACTIVE	= 3,
	SHOW_R_BOSS_	= 4,
	SHOW_R_TASK		= 5,

	MOVE_TO_POS		= 0,
	WAKL_TO_POS		= 1,
	MOVE_TO_NPC		= 2,
	WAKL_TO_NPC		= 3,
	MOVE_TO_GHOST	= 4,
	MOVE_TO_FIGHT	= 5,

	GHOST_NPC		= 500,
	GHOST_PLAYER	= 501,
	GHOST_MONSTER	= 502,
	GHOST_ITEM		= 503,
	GHOST_SLAVE		= 504,
	GHOST_NEUTRAL	= 505,
	GHOST_DART		= 508,
	GHOST_THIS		= 999,

	ITEM_BAG_BEGIN		= 0,
	ITEM_BAG_SIZE		= 120,
	ITEM_BAG_END		= 120,
	ITEM_BAG_MAX		= 120,
	ITEM_DEPOT_BEGIN	= 1000,
	ITEM_DEPOT_SIZE		= 40,
	ITEM_DEPOT_END		= 1080,
	ITEM_XUANJING_BEGIN	= 3500,
	ITEM_XUANJING_SIZE	= 140,


	ITEM_LOTTERYDEPOT_BEGIN =3000,
	ITEM_LOTTERYSIZE =300,

	ITEM_FASHIONDEPOT_BEGIN = 5000,
	ITEM_FASHIONSIZEE = 100,

	ITEM_FLAG_BIND = 0x1,
	ITEM_FLAG_USE_BIND = 0x2,
	ITEM_FLAG_JIPING = 0x4,
	ITEM_FLAG_JIANDING= 0x8,

	-- ITEM_WEAPON_POSITION	= -2 * 2,
	-- ITEM_CLOTH_POSITION		= -3 * 2,
	-- ITEM_HAT_POSITION		= -4 * 2,
	-- ITEM_RING1_POSITION		= -5 * 2,
	-- ITEM_RING2_POSITION		= -5* 2 - 1,
	-- ITEM_GLOVE1_POSITION	= -6 * 2,
	-- ITEM_GLOVE2_POSITION	= -6* 2 - 1,
	-- ITEM_NICKLACE_POSITION	= -7 * 2,
	-- ITEM_HUIZHANG_POSITION	= -8 * 2,
	-- ITEM_BELT_POSITION		= -9 * 2,
	-- ITEM_BOOT_POSITION		= -10 * 2,

	ITEM_WEAPON_POSITION 	= (-1*2),
	ITEM_CLOTH_POSITION 	= (-2*2),
	ITEM_HAT_POSITION 		= (-3*2),
	ITEM_NICKLACE_POSITION 	= (-4*2),
	ITEM_GLOVE1_POSITION 	= (-5*2),
	ITEM_GLOVE2_POSITION 	= (-5*2-1),
	ITEM_RING1_POSITION 	= (-6*2),
	ITEM_RING2_POSITION 	= (-6*2-1),
	ITEM_BELT_POSITION 		= (-7*2),
	ITEM_BOOT_POSITION 		= (-8*2),
	
	ITEM_XUEFU_POSITION 		= (-101*2),
	ITEM_FABAO_POSITION 		= (-102*2),
	ITEM_LINGFU_POSITION 		= (-103*2),
	ITEM_YINGHUN_POSITION 		= (-104*2),
	ITEM_BAODING_POSITION 		= (-105*2),
	ITEM_ZHANQI_POSITION 		= (-106*2),
	ITEM_SHOUHU_POSITION 		= (-107*2),
	ITEM_ZHANDUN_POSITION 		= (-108*2),
	ITEM_ZHUZHUANGPLUS1_POSITION 		= (-109*2),
	ITEM_ZHUZHUANGPLUS2_POSITION 		= (-110*2),
	
	ITEM_FUZHUANGPLUS1_POSITION 		= (-201*2),
	ITEM_FUZHUANGPLUS2_POSITION 		= (-202*2),
	ITEM_FUZHUANGPLUS3_POSITION 		= (-203*2),


	ITEM_SRSX1_POSITION 		= (-351*2),
	ITEM_SRSX2_POSITION 		= (-352*2),
	ITEM_SRSX3_POSITION 		= (-353*2),
	ITEM_SRSX4_POSITION 		= (-354*2),
	ITEM_SRSX5_POSITION 		= (-355*2),
	ITEM_SRSX6_POSITION 		= (-356*2),
	ITEM_SRSX7_POSITION 		= (-357*2),
	ITEM_SRSX8_POSITION 		= (-358*2),
	ITEM_SRSX9_POSITION 		= (-359*2),
	ITEM_SRSX10_POSITION 		= (-360*2),
	ITEM_SRSX11_POSITION 		= (-361*2),
	ITEM_SRSX12_POSITION 		= (-362*2),
	
	--玉佩
	ITEM_JADE_PENDANT_POSITION = (-11*2),
	--护盾
	ITEM_SHIELD_POSITION = (-12*2),
	--护心镜
	ITEM_MIRROR_ARMOUR_POSITION = (-13*2),
	--面巾
	ITEM_FACE_CLOTH_POSITION = (-14*2),
	--龙心
	ITEM_DRAGON_HEART_POSITION = (-15*2),
	--狼牙
	ITEM_WOLFANG_POSITION = (-16*2),
	--龙骨
	ITEM_DRAGON_BONE_POSITION = (-17*2),
	--虎符
	ITEM_CATILLA_POSITION = (-18*2),
	--勋章
	ITEM_ACHIEVE_MEDAL_POSITION = (-19*2),

	--时装武器
	ITEM_FASHION_WEAPON_POSITION = (-31*2),
	--时装衣服
	ITEM_FASHION_CLOTH_POSITION = (-32*2),
	--时装翅膀
	ITEM_FASHION_WING_POSITION = (-33*2),
	--时装翅膀
	ITEM_FASHION_WING_SHOUSHI1 = (-34*2),
	--时装翅膀
	ITEM_FASHION_WING_SHOUSHI2 = (-35*2),
	--时装翅膀
	ITEM_FASHION_WING_SHOUSHI3 = (-36*2),
	--时装翅膀
	ITEM_FASHION_WING_SHOUSHI4 = (-37*2),
	--时装翅膀
	ITEM_FASHION_WING_SHOUSHI5 = (-38*2),
	--时装翅膀
	ITEM_FASHION_WING_SHOUSHI6 = (-39*2),

	-- ITEM_GUANZHI_POSITION	= -11 * 2,
	-- ITEM_XUESHI_POSITION	= -12 * 2,
	-- ITEM_WING_POSITION		= -13 * 2,
	-- ITEM_FASHION_POSITION	= -15 * 2,
	-- ITEM_TEJIE_POSITION		= -17 * 2,

	-- ITEM_XUEFU_POSITION		= -41 * 2,
	-- ITEM_HUDUN_POSITION		= -42 * 2,
	-- ITEM_BAOSHI_POSITION	= -43 * 2,
	-- ITEM_HUNZHU_POSITION	= -44 * 2,

	SKILL_TYPE_YiBanGongJi		= 100,
	SKILL_TYPE_JiChuJianShu		= 101,
	SKILL_TYPE_GongShaJianShu	= 102,
	SKILL_TYPE_CiShaJianShu		= 103,
	SKILL_TYPE_BanYueWanDao		= 104,
	SKILL_TYPE_YeManChongZhuang	= 105,
	SKILL_TYPE_LieHuoJianFa		= 106,
	SKILL_TYPE_PoTianZhan		= 107,
	SKILL_TYPE_ZhuRiJianFa		= 109,

	SEX_MALE	= 200,
	SEX_FEMALE	= 201,

	AVATAR_ID				= 0,
	AVATAR_TYPE				= 1,
	AVATAR_STATE			= 2,
	AVATAR_X				= 3,
	AVATAR_Y				= 4,
	AVATAR_DIR				= 5,
	AVATAR_TARGET_X			= 6,
	AVATAR_TARGET_Y			= 7,
	AVATAR_DEADANIM			= 8,
	AVATAR_DISABLE_MAGIC	= 9,
	AVATAR_DISABLE_PRE		= 10,
	AVATAR_DISABLE_RUN		= 11,
	AVATAR_AUTOMOVE_FLAG	= 12,
	AVATAR_ATTR_MAX			= 13,
	
	SKILL_TYPE_HuoQiuShu		= 401,
	SKILL_TYPE_KangJuHuoHuan	= 402,
	SKILL_TYPE_YouHuoZhiGuang	= 403,
	SKILL_TYPE_DiYuHuo			= 404,
	SKILL_TYPE_LeiDianShu		= 405,
	SKILL_TYPE_ShunJianYiDong	= 406,
	SKILL_TYPE_DaHuoQiu			= 407,
	SKILL_TYPE_BaoLieHuoYan		= 408,
	SKILL_TYPE_HuoQiang			= 409,
	SKILL_TYPE_JiGuangDianYing	= 410,
	SKILL_TYPE_DiYuLeiGuang		= 411,
	SKILL_TYPE_MoFaDun			= 412,
	SKILL_TYPE_ShengYanShu		= 413,
	SKILL_TYPE_BingPaoXiao		= 414,
	SKILL_TYPE_HuoLongQiYan		= 416,
	SKILL_TYPE_LiuXingHuoYu		= 417,

	SKILL_TYPE_ZhiYuShu				= 501,
	SKILL_TYPE_JinShenLiZhanFa		= 502,
	SKILL_TYPE_ShiDuShu				= 503,
	SKILL_TYPE_LingHunHuoFu			= 504,
	SKILL_TYPE_ZhaoHuanKuLou		= 505,
	SKILL_TYPE_YinShenShu			= 506,
	SKILL_TYPE_JiTiYinShenShu		= 507,
	SKILL_TYPE_YouLingDun			= 508,
	SKILL_TYPE_ShenShengZhanJiaShu	= 509,
	SKILL_TYPE_XinLingQiShi			= 510,
	SKILL_TYPE_KunMoZhou			= 511,
	SKILL_TYPE_QunTiZhiLiao			= 512,
	SKILL_TYPE_ZhaoHuanShenShou		= 513,
	SKILL_TYPE_QiGongBo				= 514,
	SKILL_TYPE_ZhaoHuanYueLing		= 518,			
	SKILL_TYPE_KaiTianZhan = 519,
	SKILL_TYPE_HuTiShenGong = 520,
	SKILL_TYPE_SiWangZhiYan = 521,
	SKILL_TYPE_ShiBuYiSha = 522,
	SKILL_TYPE_DanTiShiDuShu = 523,
	SKILL_TYPE_QunTiLeiDianShu = 524,
	
	SKILL_TYPE_JiuJieJianFa = 525,
	SKILL_TYPE_GuiYouZhan = 526,
	SKILL_TYPE_ShenXuanJianFa = 527,
	SKILL_TYPE_ZhanLongJianFa = 528,
	SKILL_TYPE_PoKongJianFa = 529,


	SKILL_TYPE_MonArrow	= 601,
	SKILL_TYPE_LevelUp	= 602,
	SKILL_TYPE_Jump		= 614,

	-- 技能释放方式
	SKILL_CASTWAW_Null = 0, -- 无
	SKILL_CASTWAY_Manul = 1, -- 玩家选择后释放
	SKILL_CASTWAY_Auto = 2, -- 玩家选择开启后自动释放
	SKILL_CASTWAY_Pasv = 3, -- 玩家学习后释放
	SKILL_CASTWAY_Delay = 4, -- 玩家选择后在下次攻击时释放
	-- 目标选择方式
	SKILL_TARGETING_Null = 0, -- 无
	SKILL_TARGETING_Object = 1, -- 单位
	SKILL_TARGETING_Grid = 2, -- 格子
	SKILL_TARGETING_Dir = 3, -- 方向

	JOB_ZS	= 100,
	JOB_FS	= 101,
	JOB_DS	= 102,

	GENDER_MALE		= 200,
	GENDER_FEMALE	= 201,

	ITEM_BETTER_SELF	= 0,
	ITEM_WORSE_SELF		= 1,
	ITEM_UNUSE_SELF		= 2,
	ITEM_NONE_SELF		= 3,

	RecycleRedLimit = 10,
	
	EQUIP_TAG = {
		WEAPON = 1,
		CLOTH = 2,
		HAT = 3,
		NECKLACE = 4,
		GLOVE = 5,
		RING = 6,
		BELT = 7,
		BOOT = 8,
		JADE_PENDANT= 11,
		SHIELD = 12,
		MIRROR_ARMOUR = 13,
		FACE_CLOTH = 14,
		DRAGON_HEART = 15,
		WOLFANG = 16,
		DRAGON_BONE = 17,
		CATILLA = 18,
		XUEFU = 101,
		FABAO = 102,
		LINGFU = 103,
		YINGHUN = 104,
		BAODING = 105,
		ZHANQI = 106,
		SHOUHU = 107,
		ZHANDUN = 108,		
		ZHUZHUANGPLUS1 = 109,		
		ZHUZHUANGPLUS2 = 110,	
		FUZHUANGPLUS1 = 201,	
		FUZHUANGPLUS2 = 202,	
		FUZHUANGPLUS3 = 203,	
		SRSX1 = 351,	
		SRSX2 = 352,	
		SRSX3 = 353,	
		SRSX4 = 354,	
		SRSX5 = 355,	
		SRSX6 = 356,	
		SRSX7 = 357,	
		SRSX8 = 358,	
		SRSX9 = 359,	
		SRSX10 = 360,	
		SRSX11 = 361,	
		SRSX12 = 362,	
	},

	STATUS_DUN = "法灵神盾",
	STATUS_EXP = "双倍经验",
	STATUS_WLD = "武力丹",
	STATUS_MLD = "魔力丹",
	STATUS_DLD = "道力丹",
	STATUS_ADD_EXP = "泡点状态",
	STATUS_XUE = "魔血石",
	STATUS_WLMZ = "武林盟主",
	STATUS_VIP = "VIP",
	STATUS_GUILD = "帮会",
	STATUS_ZS = "转生",
	STATUS_MOUNT = "坐骑",
	STATUS_WING = "翅膀",
	STATUS_GUILD_ATTR = "帮会属性",
	STATUS_YS = "元神",
	STATUS_YSTP = "元神突破",
	DESP_DUN = "魔法护盾，可以抵挡伤害",
	DESP_EXP1 = "打怪获得",
	DESP_EXP2 = "倍经验",
	DESP_WLD = "物理攻击+300",
	DESP_MLD = "魔法攻击+300",
	DESP_DLD = "道术攻击+300",
	DESP_ADD_EXP = "持续获得经验",
	DESP_XUE1 = "拥有",
	DESP_XUE2 = "万恢复值",
	DESP_WLMZ = "攻击力+300,杀怪经验增加50%",
	SKILL_DESP = {
	[100] = "造成普通伤害",--普通伤害
	[101] = "增加攻击命中率",--战士剑术
	[102] = "增加攻击伤害",--强攻剑术
	[103] = "增加攻击距离",--刺杀剑气
	[104] = "造成范围性攻击",--雷霆莲月
	[105] = "可以撞晕敌人",--战神冲撞
	[106] = "增加下次攻击伤害",--战圣烈焰
	[107] = "增加下次攻击伤害",--破天斩
	[109] = "增加下次攻击伤害",--奔雷剑法
	[401] = "造成单体伤害",--火焰之球
	[402] = "推开附近敌人",--法师威严
	[403] = "",
	[404] = "造成范围伤害",--黑狱之火
	[405] = "造成单体伤害",--天雷之术
	[406] = "可进行随机移动",--空间穿梭
	[407] = "造成单体伤害",--火焰飞轮
	[408] = "造成单体伤害",--爆焰火球
	[409] = "造成持续范围伤害",--烈焰火墙
	[410] = "造成直线范围伤害",--黑狱雷电
	[411] = "造成范围伤害",--雷光风暴
	[412] = "减少自身受到的伤害",--神灵法盾
	[413] = "",
	[414] = "造成范围伤害",--冰雪咆哮
	[416] = "造成范围伤害并附带灼伤效果",--龙息气焰
	[417] = "造成范围伤害并附带灼伤效果",--烈焰火雨
	[501] = "治疗单体单位",--回春之术
	[502] = "增加攻击命中率",--精神冥想
	[503] = "单体减防持续伤害",--天尊之毒
	[504] = "造成单体伤害",--天魂灵符
	[505] = "召唤骷髅辅助作战",--亡灵召唤
	[506] = "隐身单体单位",--隐身之术
	[507] = "隐身区域单位",--天尊隐身
	[508] = "增加魔法防御",--魔神庇护
	[509] = "增加物理防御",--斗神庇护
	[510] = "",
	[511] = "",
	[512] = "治疗群体单位",--天尊灵疗
	[513] = "召唤一只强大的神兽作为自己的随从",--无极召唤
	[514] = "用强大的气功把周围目标全部推开",--气功波
	[518] = "召唤一只强大的神龙作为自己的随从",--炎龙召唤
	[601] = "",
	[602] = "",
	[614] = "",
	},

	ddarr	= "☆★○●◎◇◆■△▲♂♀↑↓→←",
	xarr	= "赵钱孙李周吴郑王冯陈褚卫蒋沈韩杨朱秦尤许何吕施张孔曹严华金魏陶姜戚谢邹喻柏水窦章云苏潘葛奚范彭郎鲁韦马苗凤花方俞任袁柳鲍史唐费廉岑薛雷贺倪汤滕殷罗毕郝邬安常于时傅皮卞齐康伍余元卜顾孟黄和穆萧尹姚邵汪祁毛禹狄米贝明臧伏成戴谈宋茅庞熊纪舒屈项祝董梁杜阮蓝闵席季麻贾路娄危江童颜郭梅盛林刁钟徐邱骆高夏蔡田樊胡凌霍虞万支柯管卢莫房裘解应丁宣邓郁单杭洪包诸左石崔吉龚程嵇邢裴陆荣翁荀羊惠甄曲封储靳松井段巫乌焦巴牧山谷车侯班秋仲伊宫宁仇栾甘厉祖武符刘景詹龙叶司郜黎蓟薄印宿白怀蒲台丛索咸赖卓蔺屠蒙池乔阴佟苍闻党翟谭贡劳姬申扶宰郦雍桑濮牛寿扈燕尚农温庄晏柴瞿阎慕连习宦艾容向古易廖庚步都耿满弘匡文寇广殴越隆师巩厍聂勾敖冷辛那简饶空曾沙鞠关蒯荆游桓公晋楚闫法鄢涂钦岳帅况琴商伯赏墨年阳",
	fxarr	= "司马上官欧阳夏侯诸葛闻人东方赫连皇甫尉迟澹台公冶宗政濮阳淳于单于太叔申屠公孙仲孙轩辕令狐钟离宇文长孙慕容鲜于闾丘司徒司空司寇端木拓跋百里东郭南门呼延左丘西门南宫",
	mfarr	= "昂宾彬斌滨波博才承德飞风丰刚光国冠晗涵瀚翰昊浩皓鹤宏鸿嘉坚建健锦瑾经靖君俊峻开凯乐力立良理茂敏朋鹏溥璞浦奇祺琪庆锐睿绍升圣晟思斯泰天同巍伟翔晓心欣新信兴星修旭炫学雪雅炎烨逸毅宜意英熠懿永咏勇宇雨玉煜远苑蕴展哲振正志致智子自作",
	msarr	= "昂奥拔邦宝本弼璧彬斌滨冰秉炳波勃博才材采彩灿藏策昌长昶畅唱超朝尘沉辰宸晨诚澄驰畴初春慈赐聪存达澹宕德笛典定栋恩发飞丰风峰锋夫福复富赋罡歌格亘工光国果海涵寒汉翰瀚航豪好昊浩河翮赫虹鸿厚虎化寰焕晖辉火基济霁骥家嘉甲剑健骄教杰洁捷津谨进精驹举觉军钧筠俊峻浚骏凯可旷魁鹍鲲阔阑澜朗乐磊礼力立利良亮量临霖禄略纶迈漫茂萌淼渺邈民旻敏名鸣茗漠默木纳男楠能鸥朋鹏平魄奇琪祺启气乾强勤青卿清庆穹全泉群然人仁忍日儒锐瑞睿叡润赡韶深生胜圣识实适书树澍双爽顺烁朔铄硕思颂邃泰堂涛腾天通同图旺望为伟玮蔚悟希熙羲曦禧侠仙贤祥翔心昕欣新歆馨鑫信兴星行雄修旭煦轩煊旋学雪勋延言衍彦焱扬尧曜耀业晔宜怡义艺怿奕益谊逸意毅熠翼颖映庸永咏勇用友佑瑜宇羽雨语玉育昱裕煜誉豫渊原源远玥悦跃允运韵蕴载藻泽湛兆哲喆真祯阵振正知志致智中忠州舟洲珠竹专资纵",
	wmfarr	= "傲碧冰采初从翠代丹冬尔凡访飞孤海含涵寒幻寄靖静乐怜灵绿曼梦觅妙南念凝盼沛平绮千巧青如若诗书思天听宛问惜香小晓笑新雪寻雅雁夜依以忆亦迎映友又雨语之芷紫醉",
	wmsarr	= "波春翠丹蝶冬儿凡菲风枫芙海寒菡荷槐卉筠兰岚蓝蕾莲灵菱露绿曼梦南凝萍琪巧芹青晴蓉柔蕊珊双霜丝桃天彤薇香萱旋雪烟雁瑶亦玉珍真之竹",

	rdmTransReelId		= 10001,
	rdmTransStoneId		= 15002,
	homeTransReelId		= 10002,
	homeTransStoneId	= 15001,

	sunWaterId		= 10052,
	superSunWaterId	= 10053,
	hpDrugSmallId	= 10040,
	hpDrugMediumId	= 10041,

	DIR_UP			= 0,
	DIR_UP_RIGHT	= 1,
	DIR_RIGHT		= 2,
	DIR_DOWN_RIGHT	= 3,
	DIR_DOWN		= 4,
	DIR_DOWN_LEFT	= 5,
	DIR_LEFT		= 6,
	DIR_UP_LEFT		= 7,

	GUILD_LEADER	= 1000,--会长
	GUILD_PRESBYTER	= 200,--长老
	GUILD_MEMBER	= 102,--会员

	expressions_item = {[1] = {"/ps","pretty_smile"},
					  	[2] = {"/se","smile"},
					  	[3] = {"/be","big_smile"},
					  	[4] = {"/de","bad_smile"},
					  	[5] = {"/ge","greeding"},
					  	[6] = {"/er","beyond_endurance"},
					  	[7] = {"/wc","wicked"},
					  	[8] = {"/wh","what"},
					  	[9] = {"/uh","unhappy"},
					  	[10] = {"/ua","unbelievable"},
					  	[11] = {"/ms","misdoubt"},
					  	[12] = {"/js","just_out"},
					  	[13] = {"/na","i_have_no_idea"},
					  	[14] = {"/ed","embarrassed"},
					  	[15] = {"/cy","cry"},
					  	[16] = {"/dv","the_devil"},
					  	[17] = {"/su","surprise"},
					  	[18] = {"/si","sigh"},
					  	[19] = {"/sh","shame"},
					  	[20] = {"/ro","rockn_roll"},
	},

	CHANNEL_TAG = {
		WORLD	= 1,
		GUILD	= 2,
		GROUP	= 3,
		FRIEND	= 4,
		PRIVATE	= 5,
		CURRENT	= 6,
		SYSTEM	= 7,
		HORN	= 8,
	},

	ChatChannelColor = {
		[1]	= "DAA520", --WORLD = 1,
		[2]	= "D2B48C", --GUILD = 2,
		[3]	= "7081FF", --GROUP = 3,
		[4]	= "6B8E23", --FRIEND = 4,
		[5]	= "75AA0D", --PRIVATE = 5,
		[6]	= "7B68EE", --CURRENT = 6,
		[7]	= "A09696", --SYSTEM = 7,
		[8]	= "C8C8C8", --HORN = 8,
	},

	stateKey = {
		[100]	= "全体",
		[101]	= "和平",
		[102]	= "组队",
		[103]	= "帮会",
		[104]	= "善恶",
		[105]	= "阵营",
	},

	friendRelation = {
		[0]	= "img_msr",
		[100]	= "img_hy",
		[101]	= "img_cr",
		[102]	= "img_hmd",
	},

	ICONTYPE = {
		POS		= 1,
		UPGRADE	= 2,
		BAG = 3,
		AVATAR = 4,
		DEPOT = 5,
		SOUL = 6,
		COMPO = 7,
		TRANSFER = 8,
		UPGRADEING = 9,
		NOTIP=10,
	},
	tabHColor = {0xD2B48C,0x735F55},
	tabVColor = {0xD2B48C,0x735F55},

	-- tabHColorS = {"0xD2B48C","0x735F55"},
	-- tabVColorS = {"0xD2B48C","0x735F55"},

	SOUND={
		give_gole_coin="sound/shiqumoney.mp3",
		medicine="sound/heyao.mp3",
		convey="sound/convey.mp3",
		die_male="sound/die_m.mp3",
		die_female="sound/die_f.mp3",
		injure_male="sound/injure_m.mp3",
		injure_female="sound/injure_w.mp3",
		walk="sound/walk3.mp3",
		run="sound/walking.mp3",		
	},

	SHORT_BEGIN		= 1,
	SHORT_SIZE		= 16,
	SHORT_SKILL_END = 8,

	-- buff相关
	STATUS_TYPE_MOFADUN = 0,
	-- STATUS_TYPE_YINGSHEN = 1,
	-- STATUS_TYPE_YOULINGDUN = 2,-- mMACMax
	-- STATUS_TYPE_SHENSHENGZHANJIASHU = 3,-- mACMax
	STATUS_TYPE_POSION_HP = 4,
	-- STATUS_TYPE_POSION_ARMOR = 5,
	-- STATUS_TYPE_HP_RECOVER = 6,
	-- STATUS_TYPE_ADD_EXP = 7,
	-- STATUS_TYPE_ADD_AC = 8,-- mACMax
	-- STATUS_TYPE_ADD_MAC = 9,-- mMACMax
	-- STATUS_TYPE_ADD_DC = 10,-- mDCMax
	-- STATUS_TYPE_ADD_MC = 11,-- mMCMax
	-- STATUS_TYPE_ADD_SC = 12,-- mSCMax
	-- STATUS_TYPE_ADD_DROP_ITEMADD_PROB = 13,
	-- STATUS_TYPE_AUTO_ADD_EXP = 14,
	-- STATUS_TYPE_NO_DAMAGE = 15,
	-- STATUS_TYPE_ALL_YINGSHEN = 16,
	-- STATUS_TYPE_NO_DROP = 17,
	-- STATUS_TYPE_SHUT_PK_VALUE = 18,
	-- STATUS_TYPE_SEVEN_COLOR_DAN = 19,-- mAC mACMax mMAC mMACMax mDC mDCMax mMC mMCMax mSC mSCMax mMaxHp mMaxMp
	-- STATUS_TYPE_MABI = 20,
	-- STATUS_TYPE_YUANSHENHUTI = 21,-- mAC mACMax mMAC mMACMax mDC mDCMax mMC mMCMax mSC mSCMax
	-- STATUS_TYPE_BAQIHUTI = 22,-- mAC mACMax mMAC mMACMax mDC mDCMax mMC mMCMax mSC mSCMax
	-- STATUS_TYPE_ADD_HP = 23,-- mMaxHp
	-- STATUS_TYPE_ADD_MP = 24,-- mMaxMp
	-- STATUS_TYPE_TIANSHENHUTI = 25,-- mMaxHp mDC mDCMax mMC mMCMax mSC mSCMax mDixiao_pres mFuyuan_cd
	-- STATUS_TYPE_SHENWEI = 26,-- mMaxHp mDC mDCMax mMC mMCMax mSC mSCMax mDixiao_pres mFuyuan_cd
	-- STATUS_TYPE_ZHIZUN = 27,-- mMaxHp mDC mDCMax mMC mMCMax mSC mSCMax mDixiao_pres mFuyuan_cd
	-- STATUS_TYPE_FUQITONGXIN = 28,-- mAC mACMax mMAC mMACMax 
	-- STATUS_TYPE_XUANTIANZHENQI=29,
	-- -- STATUS_TYPE_XINFA1 = 30,
	-- -- STATUS_TYPE_XINFA2 = 31,
	-- STATUS_TYPE_WLMZ = 32,
	-- -- STATUS_TYPE_ZHUANSHEN = 33,
	-- STATUS_TYPE_VIP = 34,
	-- STATUS_TYPE_ZUOQI = 35,
	-- STATUS_TYPE_GUANZHI = 36,
	-- STATUS_TYPE_ZUAN = 37,
	-- STATUS_TYPE_XINFA_XIN = 38,
	-- STATUS_TYPE_ZUNQI_XIN = 55,
	-- STATUS_TYPE_BURNING = 70,
	-- STATUS_TYPE_SHOULING=74,
	-- STATUS_TYPE_NUMBER = 110,

	-----------任务状态-----------
	TSN    =10,
	TSNULL =0,
	TSUNAC =1,
	TSACCE =2,
	TSACED =3,
	TSCOMP =4,

	-----------宝石相关-----------
	ITEM_GEM_BEGIN = 25010000,
	ITEM_GEM_END = 25999999,

	ITEM_GEM_ATTACK_BEGIN = 25010000,
	ITEM_GEM_ATTACK_END = 25019999,

	ITEM_GEM_AC_BEGIN = 25020000,
	ITEM_GEM_AC_END = 25029999,

	ITEM_GEM_MAC_BEGIN = 25030000,
	ITEM_GEM_MAC_END = 25039999,

	ITEM_GEM_HP_BEGIN = 25040000,
	ITEM_GEM_HP_END = 25049999,

	ITEM_GEM_MP_BEGIN = 25050000,
	ITEM_GEM_MP_END = 25059999,

	ITEM_GEM_SPECIAL_BEGIN = 25060000,
	ITEM_GEM_SPECIAL_END = 25089999,

	ITEM_GEM_HOLY_BEGIN = 25060000,
	ITEM_GEM_HOLY_END = 25069999,
	---暴击宝石
	ITEM_GEM_CRI_PROB_BEGIN = 25070000,
	ITEM_GEM_CRI_PROB_END = 25079999,
	---暴伤宝石
	ITEM_GEM_CRI_BEGIN = 25080000,
	ITEM_GEM_CRI_END = 25089999,

	GEM_TYPE_HOLY = 1,
	GEM_TYPE_CRI_PROB = 2,
	GEM_TYPE_CRI = 3,
	GEM_TYPE_ATTACK = 4,
	GEM_TYPE_AC = 5,
	GEM_TYPE_MAC = 6,
	GEM_TYPE_HP = 7,
	GEM_TYPE_MP = 8,

	GEM_ATTACK_OFFSET_POSITION = 500,
	GEM_AC_OFFSET_POSITION = 530,
	GEM_MAC_OFFSET_POSITION = 560,
	GEM_HP_OFFSET_POSITION = 590,
	GEM_MP_OFFSET_POSITION = 620,
	GEM_SPECIAL_OFFSET_POSITION = 650,

	-- tips类型
	TIPS_TYPE = {
		GENERAL = 1,
		BAG = 2,
		DEPOT = 3,
		TRADE = 4,
		CONSIGN = 5,
		GEM = 6,
		UPGRADE = 7,
		REFINE = 8,
		GUILD = 9,
		TREASURE = 10,
	},

	ITEM_TYPE_EQUIP = 1,
	ITEM_TYPE_MONEY = 2,
	ITEM_TYPE_DRUG = 3,
	ITEM_TYPE_MATERIAL = 4,
	ITEM_TYPE_SKILLBOOK = 5,
	ITEM_TYPE_GEM = 6,
	ITEM_TYPE_GIFT = 7,
	ITEM_TYPE_CHEST = 8,
	ITEM_TYPE_BUFF = 9,
	ITEM_TYPE_FASHION = 10,
	ITEM_TYPE_SCROLL = 11,
	ITEM_TYPE_OTHER = 12,

	EQUIP_TYPE_WEAPON = 1,
	EQUIP_TYPE_CLOTH = 2,
	EQUIP_TYPE_HAT = 3,
	EQUIP_TYPE_NICKLACE = 4,
	EQUIP_TYPE_GLOVE = 5,
	EQUIP_TYPE_RING = 6,
	EQUIP_TYPE_BELT = 7,
	EQUIP_TYPE_BOOT = 8,
	
	EQUIP_TYPE_XUEFU 		= 101,
	EQUIP_TYPE_FABAO 		= 102,
	EQUIP_TYPE_LINGFU 		= 103,
	EQUIP_TYPE_YINGHUN 		= 104,
	EQUIP_TYPE_BAODING 		= 105,
	EQUIP_TYPE_ZHANQI 		= 106,
	EQUIP_TYPE_SHOUHU 		= 107,
	EQUIP_TYPE_ZHANDUN 		= 108,
	
	EQUIP_TYPE_ZHUZHUANGPLUS1 = 109,		
	EQUIP_TYPE_ZHUZHUANGPLUS2 = 110,
	
	EQUIP_TYPE_FUZHUANGPLUS1 = 201,	
	EQUIP_TYPE_FUZHUANGPLUS2 = 202,	
	EQUIP_TYPE_FUZHUANGPLUS3 = 203,	
	
	EQUIP_TYPE_SRSX1 = 301,	
	EQUIP_TYPE_SRSX2 = 302,	
	EQUIP_TYPE_SRSX3 = 303,	
	EQUIP_TYPE_SRSX4 = 304,	
	EQUIP_TYPE_SRSX5 = 305,	
	EQUIP_TYPE_SRSX6 = 306,	
	EQUIP_TYPE_SRSX7 = 307,	
	EQUIP_TYPE_SRSX8 = 308,	
	EQUIP_TYPE_SRSX9 = 309,	
	EQUIP_TYPE_SRSX10 = 310,	
	EQUIP_TYPE_SRSX11 = 311,	
	EQUIP_TYPE_SRSX12 = 312,	

	-- 副装
	-- 玉佩
	EQUIP_TYPE_JADE_PENDANT = 11,
	-- 护盾
	EQUIP_TYPE_SHIELD = 12,
	-- 护心镜
	EQUIP_TYPE_MIRROR_ARMOUR = 13,
	-- 面巾
	EQUIP_TYPE_FACE_CLOTH = 14,
	-- 龙心
	EQUIP_TYPE_DRAGON_HEART = 15,
	-- 狼牙
	EQUIP_TYPE_WOLFANG = 16,
	-- 龙骨
	EQUIP_TYPE_DRAGON_BONE = 17,
	-- 虎符
	EQUIP_TYPE_CATILLA = 18,
	-- 勋章
	EQUIP_TYPE_ACHIEVE_MEDAL = 19,
}

GameConst.GUILD_DEPOT_LENGTH = 375

GameConst.SCALE_X = GameConst.VISIBLE_WIDTH / GameConst.WIN_WIDTH
GameConst.SCALE_Y = GameConst.VISIBLE_HEIGHT / GameConst.WIN_HEIGHT
GameConst.SCALE = nil

GameConst.WING_TEXTURE_START_ID = 1001


GameConst.UI_SIMPLIFIED = 100
GameConst.UI_COMPLETE = 101

function GameConst.gameScale()
	if not GameConst.SCALE then
		if GameConst.SCALE_X < GameConst.SCALE_Y then
			GameConst.SCALE = GameConst.SCALE_X
		else
			GameConst.SCALE = GameConst.SCALE_Y
		end
	end
	return GameConst.SCALE
end

function GameConst.left(x,y)
	if not x then x = 0 end
	if not y then y = 0 end
	return cc.p(GameConst.VISIBLE_X + x, GameConst.VISIBLE_Y + GameConst.VISIBLE_HEIGHT/2 + y)
end
function GameConst.right(x,y)
	if not x then x = 0 end
	if not y then y = 0 end
    return cc.p(GameConst.VISIBLE_X+GameConst.VISIBLE_WIDTH + x, GameConst.VISIBLE_Y + GameConst.VISIBLE_HEIGHT/2 + y)
end
function GameConst.top(x,y)
	if not x then x = 0 end
	if not y then y = 0 end
    return cc.p(GameConst.VISIBLE_X + GameConst.VISIBLE_WIDTH/2 + x, GameConst.VISIBLE_Y + GameConst.VISIBLE_HEIGHT + y)
end
function GameConst.bottom(x,y)
	if not x then x = 0 end
	if not y then y = 0 end
    return cc.p(GameConst.VISIBLE_X + GameConst.VISIBLE_WIDTH/2 + x, GameConst.VISIBLE_Y + y)
end
function GameConst.center(x,y)
	if not x then x = 0 end
	if not y then y = 0 end
	return cc.p(GameConst.WIN_WIDTH/2 + x,GameConst.WIN_HEIGHT/2 + y)
end
function GameConst.leftTop(x,y)
	if not x then x = 0 end
	if not y then y = 0 end
    return cc.p(GameConst.VISIBLE_X + x, GameConst.VISIBLE_Y + GameConst.VISIBLE_HEIGHT + y)
end
function GameConst.rightTop(x,y)
	if not x then x = 0 end
	if not y then y = 0 end
    return cc.p(GameConst.VISIBLE_X + GameConst.VISIBLE_WIDTH + x, GameConst.VISIBLE_Y + GameConst.VISIBLE_HEIGHT + y)
end
function GameConst.leftBottom(x,y)
	if not x then x = 0 end
	if not y then y = 0 end
	return cc.p(GameConst.VISIBLE_X + x,GameConst.VISIBLE_Y + y)  
end
function GameConst.rightBottom(x,y)
	if not x then x = 0 end
	if not y then y = 0 end
    return cc.p(GameConst.VISIBLE_X + GameConst.VISIBLE_WIDTH + x, GameConst.VISIBLE_Y + y)  
end
function GameConst.color( index )
	local color = {
		[1] = cc.c3b(255,255,240),
		[2] = cc.c3b(205,133,63),
		[3] = cc.c3b(250,250,210),
		[4] = cc.c3b(138,105,89),
		[5] = cc.c3b(169,169,169),
		[6] = cc.c3b(224,164,96),
		[7] = cc.c3b(105,105,105),
		[8] = cc.c3b(255,0,0),
		[9] = cc.c3b(20,160,20),
	}
	return color[index]
end

-------------------------------人物属性-----------------------------------
local i=0

GameConst.net_id=i;i=i+1
GameConst.net_type=i;i=i+1
GameConst.net_cloth=i;i=i+1
GameConst.net_weapon=i;i=i+1
GameConst.net_mount=i;i=i+1
GameConst.net_wing=i;i=i+1
GameConst.net_exp=i;i=i+1
GameConst.net_x=i;i=i+1
GameConst.net_y=i;i=i+1
GameConst.net_dir=i;i=i+1
GameConst.net_speed=i;i=i+1
GameConst.net_hp=i;i=i+1
GameConst.net_maxhp=i;i=i+1
GameConst.net_mp=i;i=i+1
GameConst.net_maxmp=i;i=i+1
GameConst.net_burden=i;i=i+1
GameConst.net_state=i;i=i+1
GameConst.net_show=i;i=i+1
GameConst.net_fabao=i;i=i+1
GameConst.net_fashion=i;i=i+1
GameConst.net_createtime=i;i=i+1
GameConst.net_level=i;i=i+1
GameConst.net_zslevel=i;i=i+1
GameConst.net_job=i;i=i+1
GameConst.net_gender=i;i=i+1
GameConst.net_dead=i;i=i+1
GameConst.net_teamid=i;i=i+1
GameConst.net_pkstate=i;i=i+1
GameConst.net_pkvalue=i;i=i+1
GameConst.net_fabaolv=i;i=i+1
GameConst.net_collecttime=i;i=i+1
GameConst.net_isboss=i;i=i+1

GameConst.net_name=i;i=i+1
GameConst.net_seedname=i;i=i+1
GameConst.net_love_name=i;i=i+1
GameConst.net_team_name=i;i=i+1
GameConst.net_guild_name=i;i=i+1
GameConst.net_guild_title=i;i=i+1
GameConst.net_guild_id=i;i=i+1
GameConst.net_name_pre=i;i=i+1
GameConst.net_name_pro=i;i=i+1
GameConst.net_item_owner=i;i=i+1
GameConst.net_itemtype=i;i=i+1
GameConst.net_fight_point=i;i=i+1
GameConst.net_show_head=i;i=i+1
GameConst.net_show_count=i;i=i+1
GameConst.net_disapear_time=i;i=i+1
GameConst.net_power=i;i=i+1
GameConst.net_maxpower=i;i=i+1
GameConst.net_bemonster=i;i=i+1
GameConst.net_attacked_time=i;i=i+1
GameConst.net_touch=i;i=i+1
GameConst.net_low=i;i=i+1
GameConst.net_attack_speed=i;i=i+1
GameConst.net_shadow_id=i;i=i+1

GameConst.net_attr_num=i;i=i+1

local j = 0
GameConst.avatar_id = j; j = j + 1
GameConst.avatar_type = j; j = j + 1
GameConst.avatar_state = j; j = j + 1
GameConst.avatar_x = j; j = j + 1
GameConst.avatar_y = j; j = j + 1
GameConst.avatar_dir = j; j = j + 1
GameConst.avatar_target_x = j; j = j + 1
GameConst.avatar_target_y = j; j = j + 1
GameConst.avatar_deadanim = j; j = j + 1
GameConst.avatar_disable_magic = j; j = j + 1
GameConst.avatar_disable_pre = j; j = j + 1
GameConst.avatar_disable_run = j; j = j + 1
GameConst.avatar_attr_max = j; j = j + 1

j=0
GameConst.STATE_IDLE = j; j = j + 1
GameConst.STATE_WALK = j; j = j + 1
GameConst.STATE_RUN = j; j = j + 1
GameConst.STATE_PREPARE = j; j = j + 1
GameConst.STATE_ATTACK = j; j = j + 1
GameConst.STATE_MAGIC = j; j = j + 1
GameConst.STATE_INJURY = j; j = j + 1
GameConst.STATE_DIE = j; j = j + 1
GameConst.STATE_DAZUO = j; j = j + 1
GameConst.STATE_CAIKUANG = j; j = j + 1
GameConst.STATE_MIDLE = j; j = j + 1
GameConst.STATE_MWALK = j; j = j + 1
GameConst.STATE_MRUN = j; j = j + 1
GameConst.STATE_JUMP = j; j = j + 1
GameConst.STATE_COUNT = j; j = j + 1

j=0
GameConst.map_runplayer = j; j = j + 1
GameConst.map_runmonster = j; j = j + 1
GameConst.map_pkprohibit = j; j = j + 1
GameConst.map_pkallow = j; j = j + 1
GameConst.map_autoalive = j; j = j + 1
GameConst.map_nointeract = j; j = j + 1
GameConst.map_lockaction = j; j = j + 1
GameConst.map_wanderfight = j; j = j + 1
GameConst.map_fightstate = j; j = j + 1
GameConst.map_count = j; j = j + 1

GameConst.MODEL_WING_ID = 1
GameConst.MODEL_MOUNT_JIE_ID = 2
GameConst.MODEL_MOUNT_XING_ID = 3
-------------------------------引导相关-----------------------------------

-------------------------------layerAlert-----------------------------------
GameConst.str_titletext_alert = "朕知道了"
GameConst.str_titletext_confirm = "是"
GameConst.str_titletext_cancel = "否"
GameConst.str_cancel = "取消"


-------------------------------职业介绍-----------------------------------

GameConst.str_info_zs = "以强有力的体格为基础，特殊的地方在于用剑法及道法等技术，魔法防御较低。"
GameConst.str_info_fs = "以长时间锻炼的内功为基础，能发挥强大的攻击型魔法，魔法攻击卓越，体力较弱。"
GameConst.str_info_ds = "以强大的精神力作为基础，治疗术起死回生，施毒术闻名天下，召唤术出神入化，攻防均衡。"
-------------------------------人物属性文字描述-----------------------------------
GameConst.str_mDC 	= "物理攻击:"
GameConst.str_sDC 	= "物攻:"
GameConst.str_mMC 	= "魔法攻击:"
GameConst.str_sMC 	= "魔攻:"
GameConst.str_mSC 	= "道术攻击:"
GameConst.str_sSC 	= "道攻:"
GameConst.str_mAC 	= "物理防御:"
GameConst.str_sAC 	= "物防:"
GameConst.str_mMAC	= "魔法防御:"
GameConst.str_sMAC	= "魔防:"
GameConst.str_mHp 	= "血量上限:"
GameConst.mHp 		= "生　　命:"
GameConst.str_sHp 	= "生命:"
GameConst.str_mMp 	= "魔法上限:"
GameConst.mMp 		= "魔　　法:"
GameConst.str_sMp 	= "魔法:"
GameConst.mAccuracy	= "准  确:"
GameConst.mDodge	= "闪  避:"
GameConst.mLuck		= "幸  运:"
GameConst.mCurse	= "诅　　咒:"
GameConst.tenacity	= "韧  性:"
GameConst.Xishou	= "物理免疫:"
GameConst.mXishou	= "魔法免疫:"
GameConst.mPKValue	= "PK　  值:"
GameConst.mHonor	= "荣　　誉:"
GameConst.str_attr  = "属\n性"
GameConst.str_special = "特殊"
GameConst.str_mountup = "进阶"
GameConst.str_moveSpeed = "移动速度:"
GameConst.str_powerUp = "战力提升:"
GameConst.str_ignoremAC = "无视物防:"
GameConst.str_ignoremMAC = "无视魔防:"
GameConst.str_free = "免费"
GameConst.str_times = "次"
GameConst.mAntiMagic = "魔法闪避"
GameConst.mAntiPoison = "中毒闪避"
GameConst.mHpRecover = "生命恢复"
GameConst.mMpRecover = "魔法恢复"
GameConst.mPoisonRecover = "中毒恢复"
GameConst.mGfAdd="攻防加成："

GameConst.holyAttack = "神圣攻击:"
GameConst.holyDefence = "神圣防御:"
GameConst.CA = "暴击力:"
GameConst.CAProb = "暴击率:"
----------角色----------
GameConst.str_name = "姓名"
GameConst.str_level= "等级"
GameConst.str_guild= "帮会"
GameConst.str_job  = "职业"
GameConst.str_zslevel  = "转生等级"

GameConst.str_gender = "性别"
GameConst.str_state = "状态"

GameConst.str_unknown = "未知"

GameConst.str_male = "男"
GameConst.str_female = "女"

GameConst.str_zs   = "战士"
GameConst.str_fs   = "法师"
GameConst.str_ds   = "道士"
GameConst.str_fight= "战斗力"

GameConst.job_name = {
	[100] = GameConst.str_zs,
	[101] = GameConst.str_fs,
	[102] = GameConst.str_ds,
	["warrior"] = GameConst.str_zs,
	["wizard"] = GameConst.str_fs,
	["taoist"] = GameConst.str_ds,
}
GameConst.gender_name = {
	[200] = GameConst.str_male,
	[201] = GameConst.str_female,
}

GameConst.nums = {
	[1] = "一",
	[2] = "二",
	[3] = "三",
	[4] = "四",
	[5] = "五",
	[6] = "六",
	[7] = "七",
	[8] = "八",
	[9] = "九",
	[10] = "十",
	[11] = "十一",
	[12] = "十二",
	[13] = "十三",
	[14] = "十四",
	[15] = "十五",
	[16] = "十六",
}

GameConst.str_goto = "前往"
GameConst.str_use  = "使用"

GameConst.str_official = "官职"
GameConst.str_title = "称号"
GameConst.str_reborn = "转生"


----------背包----------
GameConst.str_bag = "背包"
-- GameConst.str_vessel = "龙王鼎"
GameConst.str_money  = "元宝"
GameConst.str_moneyb = "绑定元宝"
GameConst.str_vcoin  = "钻石"
GameConst.str_vcoinb = "绑定钻石"
-- GameConst.str_grid	 = "网格显示"
-- GameConst.str_list	 = "列表显示"
GameConst.str_recycle= "装备回收"
GameConst.str_filter = "装备筛选"
GameConst.str_split  = "物品拆分"
GameConst.str_pack   = "包裹整理"
-- GameConst.str_recycle_exp = "可回收经验："
-- GameConst.str_recycle_bmoney = "可回收金币："
GameConst.str_onekey_putin = "一键放入"
GameConst.str_putin_confirm = "确定回收"
GameConst.str_title_recycle = "可回收"
GameConst.str_title_bag = "包裹"
GameConst.str_tidy = "整理"
GameConst.str_kz = "扩展仓库"
GameConst.str_getall = "全部取出"
GameConst.str_drop = "丢弃"
GameConst.str_cancel_drop = "取消丢弃"
GameConst.str_confirm_drop = "确认丢弃"
GameConst.str_destory = "摧毁"
GameConst.str_huishou = "物品回收"
GameConst.str_sssd = "商店"
GameConst.str_cancel_destory = "取消摧毁"
GameConst.str_confirm_destory = "确认摧毁"
GameConst.str_split_short = "拆分"
GameConst.str_input_splitnum = "请输入拆分数量"
GameConst.str_input_price	 = "请输入价格..."
GameConst.str_legal_price	 = "请输入合法价格"
----------仓库----------
GameConst.str_title_depot = "仓库"


----------装备----------
GameConst.str_weapon	= "武器"
GameConst.str_cloth		= "衣服"
GameConst.str_hat		= "帽子"
GameConst.str_ring		= "戒指"
GameConst.str_glove		= "手套"
GameConst.str_necklace	= "项链"
GameConst.str_belt		= "腰带"
GameConst.str_boot		= "鞋子"
GameConst.str_wing		= "翅膀"
GameConst.str_fashion	= "时装"
GameConst.str_soul		= "魂器"
GameConst.str_all		= "所有"
GameConst.str_detail	= "详细信息"
GameConst.str_goback	= "返回"

----------排行榜----------
GameConst.str_power			= "攻击"
GameConst.str_wealth		= "财富"
GameConst.str_richlist		= "富豪榜"
GameConst.str_guildlist		= "帮会榜"
GameConst.str_herolist		= "综合"
GameConst.str_warriorlist	= "战士"
GameConst.str_wizardlist	= "法师"
GameConst.str_taoistlist	= "道士"
GameConst.str_guild_name	= "帮会名称"
GameConst.str_guild_number	= "人数"
GameConst.str_guild_level	= "等级"
GameConst.str_search		= "查 找"
GameConst.str_clear			= "清 除"
GameConst.str_not_in_rank	= "未入榜"

----------商城----------------
-- GameConst.str_all		= "全部"
GameConst.str_equip		= "装备"
GameConst.str_pet		= "宠物"
GameConst.str_artifact	= "神器"
GameConst.str_jewel		= "宝石"
GameConst.str_other		= "其他"
GameConst.str_buyLimit	= "限购%d次（%d/%d）"
----------聊天----------
GameConst.str_chat_common	= "【普通】"
GameConst.str_chat_horn		= "【喇叭】"
GameConst.str_chat_world	= "【世界】"
GameConst.str_chat_guild	= "【帮会】"
GameConst.str_chat_group	= "【队伍】"
GameConst.str_chat_shout	= "【喊话】"
GameConst.str_chat_private	= "【私聊】"
GameConst.str_chat_system	= "【系统】"
GameConst.str_chat_all		= "【综合】"
GameConst.str_chat_near		= "【附近】"

GameConst.str_channel_common= "当前"
GameConst.str_channel_world	= "世界"
GameConst.str_channel_guild	= "帮会"
GameConst.str_channel_group	= "组队"
GameConst.str_channel_friend = "好友"
GameConst.str_channel_private= "私聊"
GameConst.str_channel_system = "系统"
GameConst.str_channel_all	= "系统"

GameConst.str_expression = "表情"
GameConst.str_voice = "语音"
GameConst.str_send = "发送"

GameConst.str_input = "点击这里输入"
GameConst.str_input2 = "请输入查找目标"

GameConst.str_you = "您"
GameConst.str_change_voice_model1 = "切换语音模式为【自由说话】！"
GameConst.str_change_voice_model2 = "切换语音模式为【会长说话】！"
GameConst.str_change_voice_model3 = "切换语音模式为【队长说话】！"

----------好友----------
GameConst.online = {
	[0] = "离线",
	[1] = "在线",
}
GameConst.onlineColor = {
	[0] = 0xb2a58b,
	[1] = 0x30FF00,
}
GameConst.str_online = "在线"
GameConst.str_offline = "离线"
GameConst.str_frdList = "好友列表"
GameConst.str_blacklist = "黑名单"
GameConst.str_enemy = "仇人"
GameConst.str_searchP = "查找玩家"

GameConst.str_setPrivate = "设为私聊"
GameConst.str_delFrd = "删除好友"
GameConst.str_addFrd = "加为好友"
GameConst.str_addRec = "添加"
GameConst.str_addRecAllorfresh = {"更换一批","全部添加"}
GameConst.str_delP = "删除玩家"
GameConst.str_invGroup = "邀请组队"
GameConst.str_chkInfo = "查看信息"
GameConst.str_defriend = "拉黑"

GameConst.str_onlineNum = "在线人数："
GameConst.str_inputPName = "请输入玩家姓名："

----------帮会----------
GameConst.str_guild_view = "帮会总览"
GameConst.str_guild_member ="帮会成员"
GameConst.str_donate="贡献"
GameConst.str_guild_wealth = "财富"
GameConst.str_guild_leader = "会长"
GameConst.str_guild_fuben_Text1 = "群体副本需要本帮会人员组队参与，由队长带领大家进入副本"
GameConst.str_guild_fuben_Text2 = "群体副本开启半小时后关闭，爆出的物品无归属，可争抢"
GameConst.str_guild_fuben_group= "群体副本(最少3人)"

-----------组队------------
GameConst.str_groupInfo = "队伍信息"
GameConst.str_nearbyP = "附近玩家"
GameConst.str_nearbyG = "附近队伍"

GameConst.str_dismissG = "解散队伍"
GameConst.str_leaveG = "离开队伍"
GameConst.str_kickoutG = "踢出队伍"
GameConst.str_follow = "发起跟随"
GameConst.str_musterG = "召集队伍"

GameConst.str_applyG = "申请加入"
GameConst.str_createG = "创建队伍"

GameConst.str_gPlace = "职务"
GameConst.str_gLeader = "队长"
GameConst.str_gMember = "队员"
GameConst.str_guildinfo = "欢迎加入本帮会,共同争霸传奇！"
GameConst.str_locateMap = "所在地图"
----------菜单----------
GameConst.str_game_set		= "游戏设定"
GameConst.str_avatar		= "角色"
GameConst.str_bag			= "背包"
GameConst.str_skill 		= "技能"
GameConst.str_friend		= "好友"
GameConst.str_upgrade		= "强化"
GameConst.str_mount			= "坐骑"
GameConst.str_feather		= "羽毛"
GameConst.str_task			= "任务"
GameConst.str_npc_shop		= "NPC商店"
GameConst.str_store			= "商城"
GameConst.str_group			= "组队"
GameConst.str_guild			= "帮会"
GameConst.str_ranking		= "排行"
GameConst.str_yuanshen		= "元神"
GameConst.str_activity		= "活动"
GameConst.str_button_set	= "按钮设置"
GameConst.str_out_set		= "退出设置"
GameConst.str_more			= "更多"
GameConst.str_escort		= "押镖"

GameConst.str_dayfree		= "每日免费升级"
GameConst.str_mountname		= "坐骑名字"
GameConst.str_jie			= "阶"
GameConst.str_xing			= "星"
GameConst.str_yes			= "是"
GameConst.str_no			= "否"
----------地图----------
GameConst.str_target		= "目标"
GameConst.str_current		= "当前"
GameConst.str_transfer		= "传送"
GameConst.str_goto			= "前往"
GameConst.str_npc 			= "NPC"
GameConst.str_transfer_point= "传送点"
GameConst.str_player 		= "玩家"

----------坐骑----------
GameConst.str_promote_medicine	= "使用坐骑丹"
GameConst.str_promote_vcoin		= "元宝升级"
GameConst.str_promote_onekey	= "一键升级"
GameConst.str_mount_zhuangbei	= "骑装"
GameConst.str_mount_hujia		= "护甲"
GameConst.str_mount_maan		= "马鞍"
GameConst.str_mount_titie		= "蹄铁"
GameConst.str_mount_jiangshen	= "缰绳"
GameConst.str_mount_hecheng		= "合成"
GameConst.str_mount_getMountDan	= "获得坐骑丹"
GameConst.str_moun_title = "玩法说明"
GameConst.str_moun_info1 = "1、每日首次登陆时有免费的三次升级机会。"
GameConst.str_moun_info2 = "2、坐骑当阶经验值升级至MAX时，坐骑升阶。"
GameConst.str_moun_info3 = "3、坐骑当阶所有星级升满时，坐骑升级。"
----------NPC商店----------
GameConst.str_boss_iron		="铁匠铺老板"
GameConst.str_boss_medicine	="药店老板"
GameConst.str_boss_jewelry	="首饰店老板"
GameConst.str_boss_armor	="防具店老板"
GameConst.str_boss_sundry	="杂货铺老板"
GameConst.str_boss_book		="书店老板"

----------技能----------
GameConst.str_skill_passive   		= "被动技能"
GameConst.str_skill_assist	  		= "辅助技能"
GameConst.str_skill_nitiative 		= "主动技能"
GameConst.str_skill_lv 				= "Lv."
GameConst.str_skill_quickupgrade 	= "升级"
GameConst.str_skill_lvmax		 	= "满级"
GameConst.str_skill_lvnow			= "当前属性"
GameConst.str_skill_lvnext			= "下阶属性"
GameConst.str_skill_lvc				= "等级"
GameConst.str_skill_power			= "攻击力"



----------任务----------
-- GameConst.str_white		= "白色"
-- GameConst.str_green		= "绿色"
-- GameConst.str_blue		= "蓝色"
-- GameConst.str_purple	= "紫色"
-- GameConst.str_orange	= "橙色"
-- GameConst.str_abandon	= "放弃"
GameConst.str_accept_task	= "接受任务"
GameConst.str_finish_task	= "完成任务"

GameConst.str_injury_physical = "物理伤害"
GameConst.str_injury_magical  = "魔法伤害"
GameConst.str_injury_taoist	  = "法术伤害"
GameConst.str_hp_ceiling	  = "生命加成"
GameConst.str_attack		  = "攻击力"
GameConst.str_mp_taoist	  	  = "魔法上限"
GameConst.str_injury_crit	  = "暴击伤害"
GameConst.str_s_injury_crit	  = "暴击:"
GameConst.str_absorb_injury	  = "吸收伤害"
GameConst.str_injury_prob	  = "暴击几率"
GameConst.str_s_injury_prob	  = "暴率:"

GameConst.str_tobe_vip = "升级 VIP"
GameConst.str_equip_up = "强化装备"
GameConst.str_mount_up = "升级坐骑"
GameConst.str_wing_up = "强化翅膀"
GameConst.str_fabao_up = "升级法宝"
GameConst.str_xuanj_up = "镶嵌玄晶"
GameConst.str_shoul_up ="强化翼灵"
GameConst.str_xinfa_up = "强化心法"
GameConst.str_zhuans_up ="转   生"
GameConst.str_guanz_up ="加官进爵"
GameConst.str_xunz_up ="升级勋章"
GameConst.str_shop_up = "商城购买"
GameConst.str_chat_trade_buy = "购买"
GameConst.str_chat_trade_sell = "定价"
GameConst.str_chat_trade_getBack = "取消出售"
----------翅膀----------
GameConst.str_wing_upgrade = "翅膀升级"
GameConst.str_wing_open = "升级翅膀"
GameConst.str_wing_advance = "翅膀进阶"
GameConst.str_wing_getLY = "获得灵羽"
GameConst.str_wing_info = "翅膀预览"
GameConst.str_wing_next_level_info = "下阶预览"
GameConst.str_curWing_info = "当前"
GameConst.str_nexWing_info = "下阶"
GameConst.str_vcoin_upgrade = "元宝升级"
GameConst.str_vcoin_advance = "元宝进阶"
GameConst.str_zhufuzhi	="祝福值"
GameConst.str_bless_title = "翅膀升级说明"
GameConst.str_suoxuyumao = "所需羽毛"
GameConst.str_bless_info = "翅膀每升10级时,可以突破全新翅膀外观和属性,但需要消耗灵翼骨和灵羽。"

----------坐骑----------
GameConst.lbl_cur_ew 	="当前环额外加成属性:"
GameConst.lbl_cur_dc	="当前攻击:"
GameConst.lbl_cur_ac	="当前防御:"
GameConst.lbl_cur_exp	="当前拥有翼灵经验:"
GameConst.lbl_cur_1		="当前坐骑属性"
GameConst.lbl_next_2	="下阶属性"
GameConst.lbl_cur_sl	="蛮力翼灵LV1"
GameConst.lbl_manli		="蛮力翼灵LV"
GameConst.lbl_shashang	="杀伤翼灵LV"
GameConst.lbl_zhenfen	="震愤翼灵LV"
GameConst.lbl_shengyuan	="生源翼灵LV"
GameConst.lbl_wuwei		="无畏翼灵LV"
GameConst.lbl_jianren	="坚韧翼灵LV"
GameConst.lbl_cur_jc	="当前加成:"
GameConst.lbl_next_jc	="下阶加成:"
GameConst.btn_lingzhu	="灵珠使用"
GameConst.btn_yijian	="一键使用"
GameConst.btn_slsj		="灵兽升级"
GameConst.btn_ybsl		="元宝修炼"
GameConst.str_beastInfo ="说明:六大灵兽同时点满一层后,获得一个额外属性。"
----------功勋----------
GameConst.str_medal_title = "玩法说明"
GameConst.str_medal_info1 = "1、每日完成降妖除魔时可获得功勋值。"
GameConst.str_medal_info2 = "2、功勋当阶经验值升级至MAX时，功勋升阶。"
GameConst.str_medal_getmedal = "获得功勋"

----------元神----------
GameConst.str_xinmota	="心魔塔"
-- GameConst.str_yuanshen 	="元神"
GameConst.str_xiulian	="元神修炼"
GameConst.str_promote_yuanshen ="提升元神"
GameConst.str_auto_promote = "自动提升"
GameConst.str_enjoyTower	="开始闯塔"
GameConst.str_getAward	="领取元神珠"
GameConst.str_yuansheninfo = "注:修为值满即可升阶,修为值不会回退！"
GameConst.str_shuxing = "属性"

----------设置----------
GameConst.str_fight_config = "战斗"
GameConst.str_game_config = "系统"

----------个人Boss----------
GameConst.str_boss_title = "玩法说明"
GameConst.str_boss_info1 = "1、BOSS副本分为简单、困难、噩梦三个难度。"
GameConst.str_boss_info2 = "2、达到指定的等级并且击杀前一个BOSS即可挑战副本。"
GameConst.str_boss_info3 = "3、每天5次击杀次数，未击杀不扣次数。"
GameConst.str_boss_info4 = "4、首次击杀BOSS不扣次数。"
GameConst.str_boss_info5 = "5、所有BOSS可一键扫荡获得BOSS积分，击杀BOSS时不获得积分。"
----------设置面板----------

GameConst.str_autoFight	= "挂机"
GameConst.str_support	= "辅助"
GameConst.str_system	= "系统"

GameConst.str_changeRole	= "更换角色"
GameConst.str_changeAccount	= "更换账号"
GameConst.str_exitGame		= "退出游戏"

GameConst.str_protectConfig = "保护设置"
GameConst.str_HPLessThen = "生命值低于"
GameConst.str_MPLessThen = "法力值低于"
GameConst.str_smartEatHP = "喝红"
GameConst.str_smartEatMP = "喝蓝"
GameConst.str_smartGoHome = "回城"
GameConst.str_autoPickConfig = "拾取设置"
GameConst.str_drug = "药品"
GameConst.str_staff = "材料"
GameConst.str_autoRetrieve = "自动回收"

GameConst.str_set_warrior	= "战士设置"
GameConst.str_autoBanYue	= "自动半月"
GameConst.str_autoLieHuo	= "自动烈火"
GameConst.str_autoCiSha	    = "隔位刺杀"
GameConst.str_set_wiazrd	= "法师设置"
GameConst.str_autoShield	= "自动上盾"
GameConst.str_autoRoar		= "自动咆哮"
GameConst.str_autofire		= "自动火墙"
GameConst.str_set_taoist	= "道士设置"
GameConst.str_autoCall		= "自动召唤"
GameConst.str_set_basic		= "基本设置"
GameConst.str_autoLock		= "智能锁定"
GameConst.str_autoFightBack	= "自动反击"


GameConst.str_screenConfig	= "画面设置"
GameConst.str_shieldEffect	= "屏蔽特效"
GameConst.str_shieldWing	= "屏蔽翅膀"
GameConst.str_shieldGuild	= "屏蔽帮会"
GameConst.str_shieldTitle	= "屏蔽称号"
GameConst.str_shieldPet		= "屏蔽宠物"
GameConst.str_shieldGSM		= "流量下载"
GameConst.str_ShieldGoHome	= "屏蔽回城"
GameConst.str_soundConfig	= "音乐特效"
GameConst.str_turnOffSound	= "关闭音乐"
GameConst.str_turnOffEffect	= "关闭音效"
GameConst.str_otherConfig = "其他设置"
GameConst.str_closeTrade = "关闭交易"
GameConst.str_performanceMode = "性能模式"

GameConst.str_switchMusic = "音乐"
GameConst.str_switchEffect = "音效"
GameConst.str_sure	= "确认"
-----------活动---------------
GameConst.str_fastReceive = "一键领取"
GameConst.str_joinActivity = "参加活动"
GameConst.str_activity2 = "活   动"

----------押镖----------
GameConst.str_escort			= "押镖"
GameConst.str_robescort 		= "劫镖"
GameConst.str_escort_tips1		= "提示：VIP等级越高，押送镖车奖励就越高。"
GameConst.str_escort_tips2		= "提示：镖车等级越高，截获奖励就越高。"
GameConst.str_remain_escort		= "剩余押镖次数:%d次"
GameConst.str_remain_robescort	= "剩余劫镖次数:%d次"
GameConst.str_reward_escort		= "押镖奖励:"
GameConst.str_my_power			= "我的战斗力:"

----------工会----------
GameConst.str_guild_list		= "工会列表"
GameConst.str_guild_member 		= "工会成员"
GameConst.str_guild_building 	= "工会建筑"

----------PanelBoss-----
GameConst.str_yeWaiBoss			= "野外BOSS"
GameConst.str_puTongMap			= "普通地图"
GameConst.str_bossZhiJiaMap		= "BOSS之家"
GameConst.str_maYaMap			= "玛雅神殿"
GameConst.str_bossChuChu		= "BOSS出处:"
GameConst.str_refreshTime		= "刷新时间:"
GameConst.str_minute			= "分钟"
----------交易-----
GameConst.str_confirmed			= "已确认"
GameConst.str_unconfirmed		= "未确认"
GameConst.str_trade_record		= "交易记录"
GameConst.str_close				= "关闭"
GameConst.str_confirm 			= "确定"
GameConst.str_other_trade 		= "对方交易"
GameConst.str_self_trade 		= "己方交易"
GameConst.str_my_bag 			= "我的背包"
GameConst.str_trade 			= "交易"

----------tips----------
GameConst.str_get_out           = "提取"
GameConst.str_put_in			= "放入"
GameConst.str_put_in_canceled	= "取消放入"
GameConst.str_undress			= "卸下"
GameConst.str_take_out			= "取出"
GameConst.str_dress 			= "装备"
GameConst.str_use 				= "使用"
GameConst.str_attr				= "[基础属性]"
GameConst.str_attr_upd 			= "[强化属性]"
GameConst.str_attr_curzl 		= "[注灵属性]"
GameConst.str_attr_active 		= "[强化激活属性]"
GameConst.str_attr_zl 			= "[可激活注灵属性]"
GameConst.str_dressed 			= "已装备"
GameConst.str_undressed 		= "未装备"
GameConst.str_sell				= "出售:"
GameConst.str_need_lv			= "等级:"
GameConst.str_need_zslv			= "转生等级:"
GameConst.str_back				= "返回"
GameConst.str_insert			= "镶嵌"

----------副本----------
GameConst.str_copy_exp			= "经验副本"
GameConst.str_copy_mount		= "坐骑副本"
GameConst.str_copy_wing			= "灵羽副本"
GameConst.str_enter_copy		= "进入副本"
GameConst.str_get_award			= "领取奖励"

-----------------邮件---------------------
GameConst.str_receive	= "领取"
GameConst.str_delete	= "删除"

----------------成就-------------------
GameConst.str_achieve_JF = "成就积分:"
GameConst.str_achieve_DQJF = "当前总成就积分:"

GameConst.str_achieve_btnfirst	    = "初入江湖"
GameConst.str_achieve_btnboss 	    = "消灭BOSS"
GameConst.str_achieve_btnupgrade 	= "强化等级"
GameConst.str_achieve_btnlevel 	    = "等级达到"
GameConst.str_achieve_btnspirit 	= "元神等级"
GameConst.str_achieve_btnlogin  	= "累计登陆"
GameConst.str_achieve_btnrecycle 	= "累计回收"

GameConst.str_achieve_firsthead				= "第一次%s"
GameConst.str_achieve_firstclothingequip 	= "穿戴装备"
GameConst.str_achieve_firstgroup		 	= "组队"
GameConst.str_achieve_firstaddguild			= "创建/加入帮会"
GameConst.str_achieve_firstaddfriend		= "加好友"
GameConst.str_achieve_firstupgrade			= "强化"
GameConst.str_achieve_firstrecycle			= "回收"

GameConst.str_achieve_bosshead			= "消灭BOSS:%s"
GameConst.str_achieve_bossADXEQC		= "【暗殿】邪恶钳虫"
GameConst.str_achieve_bossADBZY			= "【暗殿】白猪妖"
GameConst.str_achieve_bossADJXZZ		= "【暗殿】赤月双头魔"
GameConst.str_achieve_bossADJPMMWS		= "【暗殿】极品猛犸卫士"
GameConst.str_achieve_bossADSHSJ		= "【暗殿】深海守将"
GameConst.str_achieve_bossADMHJS		= "【暗殿】蛮荒巨兽"
GameConst.str_achieve_bossADHLYH		= "【暗殿】皇陵幽魂"
GameConst.str_achieve_bossADXYLS		= "【暗殿】雪域灵兽"
GameConst.str_achieve_bossWELS			= " 万恶龙神"
GameConst.str_achieve_bossBZW			= " 白猪王"
GameConst.str_achieve_bossMMJH			= " 猛犸教皇"
GameConst.str_achieve_bossQNZW			= " 赤月大恶魔"
GameConst.str_achieve_bossMHJZ			= " 蛮荒教主"
GameConst.str_achieve_bossHLDJJ			= " 皇陵大将军"
GameConst.str_achieve_bossHYNJ			= " 海妖娜迦"
GameConst.str_achieve_bossXYSL 			= " 雪域神龙"

GameConst.str_achieve_upgradehead 	= "将 %d 件装备强化至 +%d"

GameConst.str_achieve_levelhead 	= "等级达到 %d 级"
GameConst.str_achieve_levelzshead 	= "转生等级达到 %d 级"

GameConst.str_achieve_spirithead 	= "元神等级达到 %d 级"

GameConst.str_achieve_loginhead 	= "累计登陆 %d 天"

GameConst.str_achieve_recyclehead 	= "回收获得 %s 经验"
GameConst.str_upgrading_introduce	={
	[1]="强化规则说明",
	[2]="1、所有装备最高可强化12级,强化等级越高，属性越强",
	[3]="2、强化装备需使用金币，金币不足不能使用强化功能",
	[4]="3、装备强化失败属性不变并失去一次强化机会,使用元宝购买强化次数",
	[5]="4、使用元宝可保证100%成功，推荐强化高等级装备使用此功能",
}

GameConst.str_push_to_start 	= "按住说话"
GameConst.str_loosen_to_send	= "松开发送"
GameConst.str_upglide_to_cancel	= "上滑取消"
GameConst.chat_open_trade_level = 45
GameConst.str_trade_limit		= "聊天交易功能"..GameConst.chat_open_trade_level.."级开放！"
GameConst.chat_open_voice_level = 45
GameConst.str_voice_limit		= "聊天语音功能"..GameConst.chat_open_voice_level.."级开放！"
GameConst.chat_open_show_level = 50
GameConst.str_show_limit		= "聊天展示功能"..GameConst.chat_open_show_level.."级开放！"
GameConst.str_close_trade		= "您已关闭交易"
GameConst.str_msg_too_long		= "消息太长，无法发送！"

GameConst.str_soul_info = "请在右侧选择您要注灵的装备"
GameConst.str_soul_reinfo = "请在右侧选择您要回收灵力的装备"
GameConst.str_has_upgraded = "消耗装备中存在星级或灵力，合成之后将会消失。您确定继续吗？"
GameConst.str_has_upgraded_recycle = "回收装备中存在星级或灵力，回收之后将会消失。您确定继续吗？"
--------------转生--------------
GameConst.str_exchange_cultivation = "兑换修为"
GameConst.str_exchange_title = "玩法说明"
GameConst.str_exchange_info1 = "1、等级达到80级时，可通过经验炼制获得转生经验，等级不足80时不可炼制转生经验。"
GameConst.str_exchange_info2 = "2、通过转生丹可获得转生经验。"
GameConst.str_exchange_info3 = "3、转生当阶经验值满足升级需求时，可进行转生升级。"
GameConst.str_exchange_getmedal = "获得功勋"
--------------回收界面--------------
GameConst.str_onekey_add		= "一键添加"
GameConst.str_onekey_recycle	= "一键回收"
GameConst.str_canget_exp		= "可获经验:"
GameConst.str_canget_money		= "可获金币:"
GameConst.str_canget_bvcoin		= "可获绑定元宝:"
GameConst.str_canget_zsjy		= "可获转生经验:"
--------------boss积分-------------------
GameConst.str_hasjifen 	= "拥有积分:"
GameConst.str_needjifen = "消耗积分:"
GameConst.str_needLevel = "需要等级:"
-------------寻宝-------------------
GameConst.str_lottery_NumOfTimes	= {
		{"寻宝1次",		"需200元宝",	},
		{"寻宝5次",		"需1000元宝",	},
		{"寻宝10次",	"需2000元宝",	},
	}

GameConst.str_huishouHint		= "为您自动清理包裹中药水，节省空间%d格"
GameConst.str_huishouHint_none	= "包裹中不存在药水，请选择其他方式清理！"
-------------主界面右中-------------
GameConst.hardLvName = {"简单","普通","困难","高手","大师","噩梦","炼狱"}

----------主界面右下角----------
GameConst.str_price_transfer 	= "1元宝"
GameConst.str_price_drug 		= "1元宝"

----------新装备提示----------
GameConst.str_better_equip = "有新装备可穿戴"
GameConst.str_continue_wabao = "继续挖宝？"
GameConst.str_soon_relive = "即将复活"
GameConst.str_hour = "时"
GameConst.str_minute = "分"
GameConst.str_second = "秒"
GameConst.str_relive = "后复活"
GameConst.str_paste_to_chat = "粘贴至聊天"
----------背包满时提示-------------
GameConst.str_bag_full_text = {
	"您背包满了，选择以下方式可快速清理",
	"快速传送到装备回收使者",
	"为您手动销毁药品类道具",
	"点击您要销毁的装备直接销毁",
}

---------------限时操作---------
GameConst.BagTidyIntrval = 5 --背包整理间隔
GameConst.ChatTradeIntrval = 10 --聊天交易间隔

----------通用提示（技能和强12装备）----------
GameConst.str_click_get 	= "点击获得"
GameConst.str_click_dress 	= "点击装备"
----------批量使用面板----------
GameConst.str_batch_use 	= "批量使用"
----------传送相关----------
GameConst.str_warm_prompt = "温馨提示"
GameConst.str_transfer_now	= "立即传送"
GameConst.str_transfer_tips1= "接下来的路途非常遥远，让我们直接传送到目的地吧！"
GameConst.str_transfer_tips2= "免费飞行还有"
GameConst.str_transfer_tips3= "成为VIP可无限传送"
GameConst.str_transfer_tips4= "您是尊贵的VIP，可享受无限传送特权！"

GameConst.str_total_recharge = "充值元宝数量达到指定数量时，即可获得充值豪礼！"
----------称号----------
GameConst.str_attr_title = "属 性"
GameConst.str_get_title = "领 取"

----------赠送装备---------
GameConst.str_get_dress = "领取并穿戴"


GameConst.min_mount_open_level = 65

GameConst.familyName = {
        "赵", "席", "滕", "米", "梅", "鲁", "孔", "蒋", "和", "樊", 
        "柏", "郁", "程", "甄", "井", "车", "宁", "景", "印", "卓", 
        "闻", "冉", "边", "柴", "向", "都", "欧", "晁", "曾", "查", 
        "钟离", "禾", "南宫", "百里", "钱", "纪", "季", "殷", "卞", "贝", 
        "盛", "韦", "曹", "房", "沈", "穆", "鲍", "胡", "单", "嵇", 
        "段", "侯", "仇", "詹", "蔺", "莘", "宰", "扈", "瞿", "古", 
        "耿", "司马", "公冶", "宇文", "章佳", "范姜", "费莫", "邗", "钟", "粟", 
        "舒", "麻", "罗", "齐", "明", "林", "昌", "严", "裘", "韩", 
        "萧", "史", "凌", "窦", "杭", "邢", "富", "党", "郦", "燕", 
        "阎", "易", "满", "敖", "荆", "上官", "宗政", "长孙", "皇", "马", 
        "杨", "尹", "唐", "霍", "章", "洪", "巫", "龙", "翟", "欧阳", 
        "慕容", "周", "项", "贾", "郝", "伍", "计", "苗", "金", "朱", 
        "姚", "费", "虞", "云", "裴", "芮", "乌", "全", "甘", "叶", 
        "蒲", "池", "谭", "冷", "游", "夏侯", "司徒", "第五", "佘", "徐", 
        "凤", "魏", "解", "秦", "邵", "廉", "万", "苏", "诸", "陆", 
        "羿", "焦", "幸", "邰", "乔", "贡", "浦", "连", "廖", "国", 
        "越", "诸葛", "司空", "闫", "端木", "瑞", "王", "梁", "常", "西门", 
        "海", "晋", "子车", "泥", "郑", "董", "娄", "安", "元", "成", 
        "邱", "陶", "应", "尤", "岑", "支", "潘", "左", "荣", "太史", 
        "陈", "阮", "童", "于", "孟", "宋", "夏", "任", "谢", "宣", 
        "吕", "毛", "贺", "管", "范", "吉", "呼延", "郭", "傅", "黄", 
        "庞", "田", "柳", "喻", "邓", "张", "狄", "汤", "莫", "令狐", 
        "岳", "东郭", "拓跋", "尉迟", "轩辕",
}

GameConst.firstName = {
    [1] = {
        "晓山", "向山", "绮山", "雁山", "夜山", "忆山", "雅山", "夏山", "丹山", "紫山", "恨山", "思山", "觅山", "以山", "沛山", "盼山", "若山", 
        "涵山", "怀山", "醉山", "梦山", "之山", "语山", "慕山", "谷山", "白山", "千山", "映之", "梦之", "飞之", "如之", "新之", "妙之", "凡之", 
        "念之", "海之", "夏之", "冷之", "傲之", "谷之", "忆之", "初之", "小之", "乐之", "含之", "恨之", "冰之", "靖之", "从南", "丹南", "紫南", 
        "若南", "听南", "谷南", "初南", "忆南", "向南", "书南", "幼南", "如南", "傲南", "以南", "雨南", "笑南", "绮南", "寄南", "寻南", "怜南", 
        "迎南", "夜南", "采南", "涵易", "醉易", "书易", "梦易", "映易", "白易", "友易", "青易", "曼易", "千易", "冬易", "又易", "靖易", "盼易", 
        "雁易", "紫易", "傲易", "思枫", "乐枫", "幻枫", "听枫", "采枫", "忆枫", "芷枫", "元枫", "静枫", "幼枫", "若枫", "青枫", "冰枫", "访枫", 
        "雪枫", "问枫", "白枫", "灵枫", "雁枫", "谷枫", "春枫", "夜云", "以云", "寒云", "含云", "念云", "亦云", "从云", "恨云", "诗云", "访云", 
        "尔云", "之云", "孤云", "海云", "冬云", "寻云", "代云", "谷云", "傲云", "紫云", "以寒", "映寒", "听寒", "凌寒", "念寒", "紫寒", "青寒", 
        "雨寒", "从寒", "曼寒", "恨寒", "秋寒", "亦寒", "灵寒", "忆寒", "夏寒", "安寒", "梦寒", "笑寒", "冬寒", "丹寒", "问寒", "怀寒", "白曼", 
        "沛白", "书白", "采白", "尔白", "安白", "听白", "凡白", "幼白", "海白", "山白", "宛白", "秋白", "白柏", "傲白", "碧白", "笑白", "白卉", 
        "白凡", "白容", "白风", "白翠", "依白", "夜白", "白竹", "白秋", "白亦", "白玉", "白晴", "南烟", "含烟", "飞烟", "念烟", "依烟", "秋烟", 
        "绮烟", "寒烟", "依风", "访风", "尔风", "寄风", "问风", "雁风", "飞风", "觅风", "语风", "初风", "元风", "沛风", "孤风", "巧风", "忆风", 
        "翠风", "千风", "映风", "南风", "如风", "恨风", "海风", "书文", "紫文", "寄文", "雨文", "从文", "沛文", "平文", "念文", "访文", "青文", 
        "忆文", "采文", "凌文", "寻文", "曼文", "芷文", "易文", "惜文", "春文", "新波", "如波", "醉波", "香波", "灵波", "幻波", "凡波", "依波", 
        "从波", "寄波", "迎波", "采波", "映波", "谷波", "觅波", "芷波", "访波", "念波", "绮波", "凌波", "盼波", "凌春", "凌旋", "凌青", "凌柏", 
        "凌珍", "凌晴", "凌翠", "凌丝", "凌双", "凝阳", "雅阳", "孤阳", "从阳", "初阳", "翠阳", "尔阳", "以阳", "安阳", "飞阳", "采阳", "凡阳", 
        "怜阳", "涵阳", "灵阳", "笑阳", "书阳", "代秋", "灵秋", "映秋", "依秋", "宛秋", "海秋", "盼秋", "千秋", "谷秋", "向秋", "忆秋", "丹秋", 
        "海露", "觅海", "凝海", "绿海", "海雪", "沛海", "海安", "海蓝", "春海", "惜海", "冷海", "海冬", "痴海", "海亦", "盼海", "迎海", "海菡", 
        "冰海", "语海", "海凡", "妙海", "宛海", "含海", "又亦", "亦巧", "天亦", "青亦", "亦丝", "冬亦", "亦竹", "采亦", "代亦", "丹亦", "亦梅", 
        "秋亦", "亦旋", "宛亦", "怀亦", "千亦", "以亦", "亦绿", "晓亦", "亦凝", "冷亦", "碧凡", "南松", "雅松", "以松", "又松", "绿松", "寒松", 
        "平松", "乐松", "如松", "傲松", "迎松", "妙松", "向松", "觅松", "孤松", "冷松", "灵松", "思松", "梦松", "恨松", "飞松", "寄松", "恨真", 
        "向真", "尔真", "代真", "雨真", "思真", "映真", "天真", "安真", "迎真", "寄真", "念真", "易真", "寻真", "访真", "笑真", "绿真", "紫真", 
        "冰真", "平蓝", "代蓝", "又蓝", "紫蓝", "醉蓝", "晓蓝", "芷蓝", "冰蓝", "尔蓝", "初蓝", "笑蓝", "以蓝", "天蓝", "寄蓝", "谷蓝", "忆蓝", 
        "沛蓝", "采蓝", "问旋", "青旋", "灵槐", "灵雁", "寄灵", "若灵", "雨灵", "之灵", "幻灵", "秋灵", "寒灵", "灵冬", "平灵", "碧灵", "元灵", 
        "慕灵", "山灵", "沛灵", "安筠", "以冬", "醉冬", "曼冬", "春冬", "寻冬", "谷冬", "冬卉", "飞柏", "静柏", "梦柏", "念柏", "涵柏", "青柏", 
        "幻柏", "妙柏", "傲柏", "如柏", "靖柏", "绿柏", "痴柏", "秋柏", "春柏", "翠柏", "幼柏", "香柏", "山柏", "元柏", "雨柏", "作人", "自珍", 
        "自强", "子濯", "子真", "子瑜", "子轩", "子实", "子石", "子琪", "子默", "子墨", "子晋", "子昂", "子安", "卓君", "中震", "智志", "智渊", 
        "智宇", "智勇", "智鑫", "智杰", "智刚", "志专", "志泽", "志用", "志勇", "志义", "志业", "志学", "志文", "志尚", "志国", "志诚", "职君", 
        "正谊", "正业", "正阳", "正信", "正卿", "正青", "正奇", "正诚", "震轩", "振荣", "振强", "振平", "振华", "振海", "振国", "振翱", "哲彦", 
        "哲圣", "哲瀚", "长运", "长旭", "长兴", "长星", "泽语", "泽雨", "泽洋", "泽民", "蕴藉", "运珧", "运盛", "运晟", "运升", "运良", "运莱", 
        "运凯", "运华", "运鸿", "运恒", "运浩", "运锋", "耘志", "耘涛", "耘豪", "越泽", "越彬", "苑杰", "苑博", "远骞", "远航", "元洲", "元勋", 
        "元武", "元纬", "元思", "元青", "元亮", "元良", "元魁", "元凯", "元驹", "元甲", "元嘉", "元化", "煜祺", "玉韵", "玉轩", "玉石", "玉山", 
        "玉泉", "玉成", "玉宸", "雨泽", "雨星", "雨信", "雨华", "宇荫", "宇寰", "宇达", "勇毅", "勇锐", "勇男", "勇军", "咏思", "咏德", "永长", 
        "永元", "永怡", "永言", "永望", "永寿", "永宁", "永年", "永嘉", "永丰", "永昌", "永安", "英纵", "英资", "英卓", "英喆", "英哲", "英逸", 
        "英奕", "英耀", "英彦", "英勋", "英韶", "英睿", "英锐", "英杰", "英光", "英发", "英达", "英博", "英飙", "胤运", "胤骞", "熠彤", "毅然", 
        "毅君", "意智", "意致", "意蕴", "逸春", "宜修", "宜人", "宜然", "宜民", "烨煜", "烨熠", "烨烨", "烨然", "烨磊", "烨赫", "曜瑞", "曜坤", 
        "曜栋", "阳州", "阳泽", "阳云", "阳羽", "阳曜", "阳焱", "阳炎", "阳旭", "阳曦", "阳文", "阳舒", "阳平", "阳嘉", "阳辉", "阳华", "阳德", 
        "阳伯", "阳冰", "阳飇", "彦君", "彦昌", "雅志", "雅懿", "雅惠", "雅达", "雅昶", "雪松", "雪风", "学义", "学民", "学林", "学海", "学博", 
        "宣朗", "轩昂", "旭尧", "旭炎", "旭鹏", "旭东", "旭彬", "修雅", "修贤", "修伟", "修能", "修明", "修筠", "修杰", "修德", "修诚", "兴业", 
        "兴言", "兴修", "兴贤", "兴文", "兴为", "兴旺", "兴腾", "兴生", "兴庆", "兴平", "兴发", "兴德", "兴朝", "兴昌", "兴安", "星洲", "星泽", 
        "星雨", "星宇", "星阑", "星津", "星火", "星华", "星汉", "星海", "星驰", "星辰", "信瑞", "新知", "新曦", "新觉", "欣悦", "欣怿", "欣荣", 
        "心思", "项禹", "项明", "向阳", "向荣", "向笛", "向晨", "翔宇", "曦之", "曦哲", "文耀", "文曜", "文山", "文瑞", "文敏", "文乐", "文康", 
        "文景", "文华", "文虹", "文光", "文栋", "文成", "文昌", "文斌", "文彬", "文昂", "温瑜", "温文", "温韦", "温茂", "伟兆", "伟泽", "伟彦", 
        "伟祺", "伟懋", "伟茂", "伟才", "伟博", "巍奕", "巍然", "巍昂", "同济", "同和", "同方", "天纵", "天元", "天宇", "天佑", "天逸", "天瑞", 
        "天路", "天禄", "天空", "天和", "天干", "天赋", "天成", "天材", "腾逸", "腾骏", "腾骞", "泰平", "泰宁", "泰华", "泰河", "泰初", "斯年", 
        "斯伯", "思远", "思博", "圣杰", "绍元", "绍祺", "绍钧", "绍辉", "绍晖", "睿思", "睿明", "睿好", "睿广", "睿范", "睿达", "睿诚", "睿博", 
        "锐智", "锐志", "锐阵", "锐泽", "锐藻", "锐利", "锐立", "锐精", "锐进", "锐达", "荣轩", "庆生", "起运", "祺祥", "祺瑞", "祺然", "祺福", 
        "琪睿", "奇致", "奇志", "奇正", "奇逸", "奇文", "奇玮", "奇伟", "奇思", "奇胜", "奇略", "溥心", "浦泽", "浦和", "濮存", "璞玉", "澎湃", 
        "鹏云", "鹏翼", "鹏天", "鹏涛", "鹏鹍", "鹏鲸", "鹏海", "鹏赋", "鹏飞", "鹏池", "彭祖", "彭泽", "彭勃", "彭薄", "朋义", "朋兴", "铭晨", 
        "明智", "明志", "明知", "明喆", "明哲", "明煦", "明旭", "明亮", "明朗", "明俊", "明辉", "明达", "明诚", "敏学", "敏叡", "敏才", "孟君", 
        "茂彦", "茂学", "茂实", "茂典", "茂德", "茂材", "茂才", "令飒", "令秋", "令锋", "良骏", "良俊", "良吉", "良畴", "良材", "良弼", "立人", 
        "立果", "立诚", "力言", "力勤", "力强", "力行", "力夫", "理群", "理全", "礼骞", "黎昕", "黎明", "乐正", "乐章", "乐悦", "乐语", "乐游", 
        "乐意", "乐逸", "乐欣", "乐心", "乐童", "乐天", "乐水", "乐山", "乐容", "乐人", "乐康", "乐家", "乐和", "乐池", "乐成", "乐邦", "昆宇", 
        "昆谊", "昆雄", "昆纬", "昆锐", "昆琦", "昆鹏", "昆明", "昆纶", "昆颉", "昆峰", "康震", "康泰", "康顺", "康适", "康胜", "康平", "康宁", 
        "康乐", "康复", "康德", "康成", "康伯", "康安", "恺乐", "凯乐", "凯康", "凯凯", "凯捷", "凯歌", "凯定", "开宇", "开朗", "开霁", "开济", 
        "开诚", "开畅", "骏喆", "骏哲", "骏逸", "骏奇", "骏年", "骏俊", "骏桀", "峻熙", "俊智", "俊哲", "俊远", "俊语", "俊友", "俊英", "俊逸", 
        "俊彦", "俊贤", "俊侠", "俊晤", "俊悟", "俊爽", "俊人", "俊明", "俊民", "俊美", "俊茂", "俊迈", "俊良", "俊郎", "俊杰", "俊晖", "俊豪", 
        "俊风", "俊德", "俊达", "俊楚", "俊材", "俊才", "俊拔", "君之", "君浩", "君昊", "君豪", "君博", "靖琪", "景中", "景逸", "景天", "景铄", 
        "景山", "景明", "景辉", "景焕", "景澄", "经义", "经纶", "经国", "经亘", "经赋", "晋鹏", "锦程", "金鹏", "健柏", "建章", "建元", "建业", 
        "建修", "建同", "建树", "建木", "建德", "建弼", "建柏", "建白", "骞仕", "骞魁", "骞北", "坚诚", "坚白", "嘉志", "嘉珍", "嘉悦", "嘉誉", 
        "嘉玉", "嘉谊", "嘉言", "嘉勋", "嘉歆", "嘉祥", "嘉禧", "嘉澍", "嘉树", "嘉实", "嘉石", "嘉瑞", "嘉容", "嘉荣", "嘉庆", "嘉平", "嘉慕", 
        "嘉木", "嘉茂", "嘉良", "嘉德", "嘉赐", "家骏", "稷骞", "季同", "季萌", "吉星", "华容", "华荣", "华辉", "华晖", "华翰", "华彩", "华奥", 
        "鸿卓", "鸿志", "鸿振", "鸿祯", "鸿哲", "鸿运", "鸿云", "鸿远", "鸿羽", "鸿雪", "鸿煊", "鸿信", "鸿禧", "鸿羲", "鸿文", "鸿朗", "鸿骞", 
        "鸿晖", "鸿光", "鸿风", "鸿飞", "鸿达", "鸿畴", "鸿畅", "鸿彩", "鸿博", "鸿波", "鸿宝", "宏远", "宏逸", "宏义", "宏伟", "宏硕", "宏爽", 
        "宏胜", "宏深", "宏儒", "宏朗", "宏阔", "宏旷", "宏恺", "宏浚", "宏放", "宏畅", "宏才", "弘毅", "弘益", "弘义", "弘业", "弘扬", "弘文", 
        "弘伟", "弘盛", "弘深", "弘量", "弘亮", "弘阔", "弘济", "弘和", "弘光", "弘大", "弘博", "鹤轩", "鹤骞", "和正", "和泽", "和悦", "和豫", 
        "和裕", "和玉", "和宜", "和怡", "和通", "和泰", "和颂", "和硕", "和洽", "和平", "和光", "和风", "和畅", "和昶", "和璧", "和安", "和蔼", 
        "皓轩", "浩言", "浩皛", "浩思", "浩壤", "浩穰", "浩然", "浩气", "浩邈", "浩渺", "浩淼", "浩阔", "浩旷", "浩慨", "浩瀚", "浩广", "浩荡", 
        "浩宕", "浩大", "浩初", "浩博", "浩波", "昊英", "昊伟", "昊天", "昊硕", "昊然", "昊穹", "昊乾", "昊磊", "昊空", "昊嘉", "昊东", "昊苍", 
        "瀚玥", "瀚文", "瀚漠", "瀚海", "翰藻", "翰学", "翰林", "翰翮", "翰飞", "翰采", "涵映", "涵意", "涵衍", "涵蓄", "涵润", "涵亮", "涵畅", 
        "晗昱", "晗日", "海阳", "海超", "海昌", "国源", "国兴", "广君", "光远", "光誉", "光耀", "光熙", "光启", "光临", "光亮", "光济", "光华", 
        "光赫", "冠宇", "高卓", "高韵", "高远", "高懿", "高逸", "高谊", "高义", "高扬", "高雅", "高轩", "高爽", "高旻", "高峻", "高杰", "高翰", 
        "高寒", "高峰", "高芬", "高飞", "高澹", "高达", "高超", "高畅", "高昂", "刚毅", "刚捷", "飞舟", "飞雨", "飞宇", "飞翼", "飞扬", "飞星", 
        "飞翔", "飞文", "飞鸾", "飞龙", "飞捷", "飞虎", "飞鸿", "飞翮", "飞翰", "飞光", "飞驰", "飞沉", "飞掣", "德泽", "德运", "德宇", "德业", 
        "德曜", "德馨", "德水", "德惠", "德辉", "德昌", "驰逸", "驰轩", "驰鸿", "驰翰", "承志", "承泽", "承载", "承允", "承宣", "承天", "承嗣", 
        "承福", "承德", "承弼", "承安", "成荫", "成业", "成文", "成天", "成仁", "成龙", "成济", "成化", "晨涛", "晨朗", "辰钊", "辰宇", "辰阳", 
        "辰龙", "辰骏", "辰皓", "昌盛", "昌淼", "昌茂", "昌黎", "昌翰", "曾琪", "才哲", "才良", "才俊", "才捷", "博耘", "博远", "博艺", "博学", 
        "博文", "博涛", "博实", "博涉", "博赡", "博明", "博简", "博厚", "博达", "博超", "波峻", "波光", "炳君", "滨海", "斌蔚", "斌斌", "彬炳", 
        "宾实", "宾白", "昂熙", "安志", "安易", "安宜", "安晏", "安顺", "安宁", "安民", "安澜", "安和", "安国", "安歌", "安福", "祖彭", "纵天", 
        "资英", "濯子", "卓英", "卓鸿", "卓高", "壮弘", "竹修", "珠明", "周成", "舟飞", "智意", "智锐", "智明", "智俊", "致意", "致奇", "致嘉", 
        "致弘", "志正", "志雅", "志伟", "志锐", "志明", "志嘉", "志鸿", "志和", "志承", "志安", "知新", "知明", "之君", "正元", "正乐", "正和", 
        "震康", "振鸿", "阵锐", "祯嘉", "祯鸿", "真子", "真正", "珍嘉", "贞永", "喆英", "喆明", "哲曦", "哲明", "哲骏", "哲俊", "哲鸿", "哲才", 
        "兆伟", "钊辰", "长永", "章飞", "湛乐", "泽志", "泽阳", "泽星", "泽伟", "泽天", "泽锐", "泽浦", "泽彭", "泽凯", "泽骞", "泽嘉", "泽德", 
        "蕴意", "韵玉", "韵和", "运佑", "运胤", "运维", "运起", "运鹏", "运嘉", "运德", "运承", "云鸿", "玥瀚", "远意", "远修", "远心", "远鸿", 
        "远宏", "远光", "远高", "远博", "源思", "元永", "元天", "元绍", "元建", "元德", "渊智", "渊星", "渊瑞", "豫和", "誉俊", "誉嘉", "煜烨", 
        "裕博", "昱晗", "郁彬", "玉璞", "玉和", "玉冠", "语泽", "语俊", "语飞", "羽令", "羽鸿", "羽丰", "宇振", "宇泽", "宇玉", "宇翔", "宇天", 
        "宇开", "宇昊", "宇飞", "宇辰", "瑜温", "佑嘉", "佑德", "勇志", "咏乐", "永修", "庸德", "映涵", "颖嘉", "英俊", "英昊", "荫宇", "荫成", 
        "懿雅", "懿嘉", "懿高", "翼鹏", "翼飞", "熠烨", "毅勇", "毅英", "毅伟", "毅宏", "毅弘", "毅刚", "意锐", "意乐", "意涵", "逸长", "逸英", 
        "逸雅", "逸天", "逸腾", "逸锐", "逸奇", "逸俊", "逸景", "逸海", "逸高", "逸驰", "谊正", "谊昆", "谊高", "益弘", "益成", "奕英", "怿欣", 
        "易安", "艺经", "艺才", "艺博", "义志", "义朋", "义经", "义宏", "义弘", "义高", "宜和", "宜安", "怡自", "晔伟", "业志", "业正", "业经", 
        "业建", "业弘", "业承", "耀英", "耀文", "耀光", "曜阳", "曜文", "曜德", "尧旭", "尧骞", "阳正", "阳向", "阳海", "扬宏", "扬弘", "扬高", 
        "扬飞", "焱阳", "焱昊", "晏安", "彦英", "彦茂", "彦俊", "衍涵", "颜承", "炎旭", "言永", "言力", "延博", "雅修", "雅俊", "雅高", "勋元", 
        "勋茂", "雪令", "雪鸿", "学志", "学兴", "学敏", "旋凯", "煊鹏", "煊鸿", "宣文", "宣承", "轩震", "轩玉", "轩文", "轩荣", "轩明", "轩鸿", 
        "轩鹤", "轩晨", "煦阳", "煦明", "煦和", "煦涵", "旭阳", "旭明", "许嘉", "修宜", "修建", "雄昆", "雄俊", "雄昂", "兴长", "兴朋", "兴国", 
        "兴高", "星文", "星吉", "星飞", "信正", "信骞", "信鸿", "鑫智", "歆嘉", "新志", "新永", "新弘", "心溥", "翔飞", "祥祺", "祥骏", "贤修", 
        "贤兴", "贤乐", "侠俊", "禧嘉", "禧鸿", "曦曜", "曦新", "羲鸿", "熙峻", "熙嘉", "熙鸿", "熙光", "熙昂", "希奇", "悟俊", "武元", "武英", 
        "武经", "文志", "文正", "文宇", "文学", "文修", "文兴", "文星", "文温", "文鸿", "文弘", "文瀚", "文博", "蔚斌", "玮奇", "纬元", "纬星", 
        "纬昆", "纬经", "伟智", "伟烨", "伟修", "伟奇", "伟骏", "伟宏", "伟弘", "伟昊", "为修", "为兴", "韦温", "望承", "图弘", "彤熠", "同景", 
        "通和", "天云", "天景", "天昊", "天承", "悌和", "腾兴", "腾星", "涛耘", "涛鹏", "涛晨", "涛博", "堂玉", "泰康", "泰和", "邃奇", "颂和", 
        "松雪", "嗣承", "思元", "思永", "思兴", "思心", "思睿", "思浩", "硕宏", "硕和", "硕昊", "朔阳", "铄景", "烁烨", "顺康", "水心", "水奇", 
        "爽宏", "爽高", "双成", "澍嘉", "树玉", "树建", "树嘉", "舒阳", "书温", "寿永", "寿德", "适康", "实子", "实宾", "识睿", "时康", "石子", 
        "石玉", "石雨", "石文", "石嘉", "盛运", "盛康", "盛宏", "盛弘", "晟运", "胜景", "胜宏", "圣哲", "圣乐", "生乐", "深宏", "韶英", "赡博", 
        "山乐", "山景", "飒令", "润德", "叡英", "叡敏", "睿英", "睿星", "睿天", "睿晟", "睿琪", "瑞信", "瑞文", "锐勇", "锐英", "锐昆", "儒宏", 
        "容乐", "容嘉", "容涵", "容博", "荣振", "荣阳", "荣向", "荣华", "荣海", "日晗", "忍涵", "仁成", "人宜", "人俊", "壤浩", "穰浩", "然烨", 
        "然修", "然信", "然欣", "然泰", "然昊", "然昂", "群立", "群理", "全理", "秋令", "庆兴", "清泰", "卿正", "勤力", "惬和", "强自", "强志", 
        "强振", "强力", "乾运", "启光", "祺煜", "祺伟", "琦昆", "琪子", "琪靖", "奇骏", "平振", "平长", "平阳", "平兴", "平泰", "平景", "平嘉", 
        "平和", "平承", "鹏运", "鹏旭", "鹏星", "鹏鑫", "鹏昆", "鹏晋", "彭瀚", "朋良", "沛辰", "湃澎", "鸥信", "宁泰", "宁康", "宁安", "年永", 
        "年斯", "年骏", "年嘉", "能修", "楠俊", "慕嘉", "木建", "木嘉", "漠瀚", "铭辰", "茗建", "鸣飞", "明自", "明元", "明逸", "明炫", "明修", 
        "明向", "明昆", "明景", "明建", "明昊", "明光", "明范", "明德", "敏智", "旻高", "民子", "民学", "民俊", "民安", "邈宏", "邈浩", "邈高", 
        "淼思", "淼昌", "萌季", "懋伟", "茂哲", "茂温", "茂俊", "茂嘉", "茂华", "茂宏", "茂昌", "漫浩", "迈俊", "略奇", "略经", "纶温", "纶昆", 
        "鸾飞", "路天", "禄天", "龙景", "龙成", "临光", "林学", "林文", "量弘", "亮元", "亮弘", "亮涵", "良才", "利锐", "丽高", "礼成", "磊烨", 
        "磊昊", "乐文", "乐恺", "乐凯", "朗英", "朗宣", "朗明", "朗开", "朗鸿", "朗宏", "朗高", "朗晨", "郎俊", "澜安", "阑星", "莱运", "阔弘", 
        "阔浩", "鲲鹏", "魁骞", "旷宏", "旷浩", "空天", "康永", "康文", "恺元", "恺宏", "凯运", "凯元", "骏寅", "骏腾", "骏良", "骏家", "骏辰", 
        "峻宏", "峻高", "俊骏", "筠修", "钧绍", "君卓", "君毅", "君彦", "君书", "君孟", "君皓", "君炳", "军勇", "举鹏", "驹元", "景文", "鲸鹏", 
        "精锐", "晋子", "颉昆", "捷勇", "捷刚", "捷才", "桀骏", "洁高", "洁刚", "杰运", "杰苑", "杰英", "杰修", "杰明", "杰昆", "杰俊", "杰高", 
        "教承", "觉新", "健俊", "骞侠", "骞礼", "骞鸿", "甲元", "嘉永", "嘉昊", "家乐", "骥良", "霁新", "霁开", "济开", "济弘", "济光", "基元", 
        "基承", "惠德", "辉绍", "辉明", "辉立", "辉景", "辉华", "辉光", "辉德", "晖智", "晖阳", "晖星", "晖绍", "晖俊", "晖华", "晖鸿", "焕景", 
        "寰宇", "怀兴", "化同", "化弘", "化成", "华运", "华文", "华建", "华风", "华德", "虎飞", "厚信", "厚博", "鸿泰", "鸿驰", "鸿宾", "赫烨", 
        "翮翰", "翮飞", "和天", "和浦", "和乐", "和弘", "皓昆", "皓华", "皓驰", "浩正", "浩君", "浩浩", "好睿", "豪正", "豪耘", "豪英", "豪俊", 
        "豪君", "豪刚", "航飞", "行志", "行力", "行景", "瀚哲", "瀚浩", "瀚博", "翰新", "翰文", "翰天", "翰锐", "翰华", "翰驰", "翰昌", "涆浩", 
        "汉星", "寒高", "海振", "海学", "海星", "海鹏", "海瀚", "海翰", "海德", "海滨", "果立", "国志", "国振", "国安", "广浩", "光星", "光鸿", 
        "光弘", "光飞", "光波", "工天", "亘经", "歌咏", "歌恺", "歌安", "刚智", "干天", "富宏", "赋文", "赋天", "复康", "复凯", "甫同", "福永", 
        "福祺", "福景", "福嘉", "福鸿", "福承", "福安", "锋运", "锋锐", "锋令", "峰雪", "峰高", "峯高", "枫令", "风雪", "风凯", "风俊", "风鸿", 
        "风和", "芬高", "飞鹏", "飞高", "放宏", "方同", "方弘", "范英", "范睿", "凡运", "发运", "发英", "发俊", "东旭", "东昊", "定凯", "典茂", 
        "笛向", "德正", "德元", "德文", "德睿", "德茂", "德俊", "德鸿", "荡浩", "宕浩", 
    },
    [2] = {
        "依珊", "秋珊", "静珊", "笑珊", "幼珊", "寒珊", "元珊", "代珊", "友珊", "芷珊", "诗珊", "惜珊", "怜珊", "安珊", "以珊", "从珊", "傲珊", 
        "沛珊", "采珊", "幻珊", "雪珊", "向珊", "痴珊", "灵珊", "书蕾", "怜蕾", "新蕾", "含蕾", "念蕾", "寄蕾", "傲蕾", "寒蕾", "半蕾", "诗蕾", 
        "涵蕾", "芷蕾", "晓蕾", "春蕾", "南蕾", "从蕾", "夜蕾", "凡蕾", "安蕾", "小蕾", "南琴", "友琴", "丹琴", "绮琴", "碧琴", "依琴", "雅琴", 
        "访琴", "翠琴", "寄琴", "凝琴", "千琴", "语琴", "雨琴", "又琴", "书琴", "尔琴", "书兰", "盼兰", "绿兰", "涵兰", "初兰", "凌兰", "问兰", 
        "雁兰", "飞兰", "山兰", "夏兰", "诗兰", "含兰", "雨兰", "谷兰", "半兰", "冰兰", "晓兰", "绮兰", "语兰", "雪兰", "千兰", "听兰", "孤兰", 
        "巧兰", "千青", "雅青", "平青", "诗青", "慕青", "凌青", "巧青", "半青", "曼青", "忆青", "安青", "又青", "天青", "雪青", "紫青", "雨青", 
        "夏青", "碧蓉", "从蓉", "雁蓉", "尔蓉", "易蓉", "语蓉", "迎蓉", "乐蓉", "绿蓉", "夜蓉", "如蓉", "幻蓉", "夏蓉", "幼蓉", "寄蓉", "天蓉", 
        "山芙", "尔芙", "雁芙", "翠芙", "语芙", "盼芙", "醉芙", "问芙", "代芙", "初蝶", "元蝶", "凌蝶", "怀蝶", "香蝶", "平蝶", "醉蝶", "孤蝶", 
        "书蝶", "乐儿", "问儿", "慕儿", "访儿", "友儿", "靖儿", "千儿", "新儿", "凡儿", "冬儿", "语儿", "春儿", "傲儿", "宛儿", "觅儿", "盼儿", 
        "水儿", "幻儿", "以儿", "如彤", "雅彤", "以彤", "夏彤", "访彤", "从彤", "翠彤", "平彤", "香彤", "安彤", "丹彤", "碧彤", "初彤", "雅柔", 
        "新柔", "觅柔", "依柔", "靖柔", "寄柔", "春柔", "千柔", "语柔", "傲柔", "秋柔", "沛柔", "傲蕊", "诗蕊", "访蕊", "小蕊", "芷蕊", "友蕊", 
        "绿蕊", "慕蕊", "恨蕊", "乐蕊", "若蕊", "问蕊", "惜蕊", "含蕊", "巧蕊", "语蕊", "香寒", "香薇", "香萱", "雅香", "香波", "香菱", "香莲", 
        "香卉", "曼香", "梦香", "香旋", "寒香", "香巧", "香岚", "盼香", "忆香", "香春", "问香", "香天", "又香", "元香", "痴香", "夜香", "香桃", 
        "香露", "香柳", "醉香", "凌香", "香梅", "冰香", "香之", "香柏", "青香", "巧香", "幻香", "半香", "惜香", "香凝", "香芹", "凌春", "绿春", 
        "碧春", "春竹", "春海", "巧春", "春雁", "采春", "春冬", "寻春", "天春", "听春", "秋春", "安春", "春翠", "妙春", "春梅", "平春", "春绿", 
        "春柏", "寄春", "南春", "夜春", "沛春", "初瑶", "元瑶", "晓瑶", "雪瑶", "恨瑶", "寄瑶", "痴瑶", "书瑶", "海瑶", "新瑶", "友瑶", "乐瑶", 
        "凌瑶", "涵瑶", "飞瑶", "念瑶", "依瑶", "采萱", "碧萱", "雅萱", "白萱", "丹萱", "映萱", "惜萱", "乐萱", "小萱", "思萱", "凌萱", "紫萱", 
        "平萱", "如萱", "幼萱", "灵萱", "安萱", "冷萱", "翠萱", "代萱", "书萱", "冬萱", "天荷", "曼荷", "代荷", "寒荷", "冷荷", "飞荷", "采荷", 
        "巧荷", "幼荷", "乐荷", "秋荷", "芷荷", "恨荷", "听荷", "迎荷", "安荷", "雁荷", "靖荷", "翠荷", "雨荷", "听芹", "半芹", "书芹", "沛芹", 
        "惜芹", "代芹", "谷芹", "念芹", "怀芹", "冰芹", "元芹", "寻芹", "语芹", "秋双", "秋柳", "之薇", "念薇", "向薇", "冰薇", "怀薇", "若薇", 
        "天薇", "问薇", "傲薇", "语薇", "飞薇", "白薇", "白曼", "曼凡", "曼雁", "又曼", "巧曼", "乐曼", "访曼", "曼菱", "青曼", "曼梅", "迎曼", 
        "曼冬", "曼易", "晓曼", "曼卉", "雪曼", "碧曼", "曼安", "如曼", "怀曼", "曼岚", "静曼", "盼曼", "尔曼", "曼寒", "曼容", "忆曼", "惜曼", 
        "初曼", "曼云", "曼文", "代曼", "曼珍", "梦曼", "曼凝", "水曼", "翠曼", "天曼", "绿竹", "凝绿", "采绿", "平绿", "友绿", "静绿", "雅绿", 
        "元绿", "绿松", "翠绿", "晓绿", "夜柳", "以柳", "采柳", "初柳", "笑柳", "千柳", "靖巧", "雪巧", "亦巧", "晓巧", "念巧", "巧云", "凡巧", 
        "醉巧", "冰巧", "翠巧", "碧巧", "从凝", "小凝", "凝冬", "凝莲", "千凝", "书凝", "凝旋", "翠桃", "书桃", "水桃", "代桃", "幻桃", "寻桃", 
        "念桃", "诗桃", "海桃", "涵桃", "盼晴", "又晴", "笑晴", "以晴", "孤晴", "雪晴", "绮晴", "凌晴", "怜晴", "山晴", "幼晴", "之桃", "希月", 
        "秀媛", "黛娥", "雪容", "明洁", "贤惠", "飞燕", "浩丽", "惜梦", "娟妍", "秀越", "林楠", "新洁", "蓝尹", "闲静", "痴灵", "飞莲", "新美", 
        "诗霜", "清雅", "英卫", "仪文", "芷烟", "好慕", "书竹", "元柳", "清卓", "妍妍", "淑慧", "隽美", "宏邈", "小萍", "芷天", "玉英", "莞然", 
        "晶瑶", "流婉", "琛丽", "姣丽", "飞昂", "佩杉", "云岚", "嘉懿", "斯文", "瑜敏", "晓旋", "安妮", "韵梅", "水悦", "晗琴", "思语", "丽玉", 
        "兰芝", "虹颖", "良哲", "夜绿", "芷蝶", "萌阳", "水蓝", "夏真", "意远", "彭丹", "木兰", "绿蝶", "贤淑", "梦槐", "晴曦", "紫丝", "宛菡", 
        "怀绿", "含灵", "梅青", "希慕", "芷雪", "丝琪", "冰莹", "嘉佑", "良骥", "燕妮", "寒梅", "飞雪", "晶滢", "晓彤", "星晴", "慧丽", "馨欣", 
        "长逸", "依辰", "心愫", "新竹", "笑雯", "怜云", "英华", "杏儿", "新雪", "长娟", "雪翎", "忆雪", "叶丰", "忻愉", "新文", "骊蓉", "琳瑜", 
        "怀柔", "秋露", "多思", "茵茵", "芬馥", "星瑶", "颐和", "雪卉", "觅云", "思萌", "向卉", "怀梦", "慕诗", "兰芳", "嘉运", "霞文", "秋玉", 
        "沈思", "雅逸", "文漪", "雅畅", "蔓蔓", "慧君", "妙菡", "雪绿", "惜雪", "熙星", "忻欢", "婉娜", "翠岚", "雨竹", "春燕", "瑞锦", "蕴涵", 
        "洋洋", "雯君", "南晴", "映阳", "雅艳", "昕妤", "歆美", "婷婷", "锦凡", "菁英", "友卉", "芝英", "顺慈", "馨兰", "雁梅", "希蓉", "思楠", 
        "含玉", "致萱", "慕卉", "靓影", "璇玑", "孤丹", "惜筠", "怜雪", "夜梅", "思嫒", "云亭", "牧歌", "云露", "孟乐", "韶容", "清芬", "慕雁", 
        "秀婉", "博敏", "修洁", "音韵", "岚彩", "晶辉", "映雪", "冬莲", "觅夏", "颖秀", "乐芸", "清润", "秀慧", "月桂", "安柏", "若云", "涵涵", 
        "惜灵", "蓉城", "淑兰", "田田", "庄静", "昂雄", "奇希", "运虹", "妙芙", "世英", "熙熙", "丝祺", "月怡", "玲珑", "珺琦", "沛凝", "凝丝", 
        "又儿", "梦菲", "易槐", "曼衍", "飞槐", "清逸", "美华", "凝蕊", "欣艳", "凝丹", "熙怡", "歌云", "山蝶", "梦凡", "叶农", "湘君", "友桃", 
        "夏雪", "冷珍", "晓君", "安波", "千凡", "怀蕾", "雅容", "雁凡", "丁兰", "新林", "凝静", "绿旋", "怀桃", "华芝", "婉丽", "春晓", "笑天", 
        "善和", "敏丽", "水彤", "娇然", "冰彦", "叶飞", "天骄", "翠丝", "凯唱", "敬曦", "昊焱", "易云", "心香", "芳洁", "柔煦", "文滨", "悠逸", 
        "燕桦", "骊雪", "雨梅", "桐华", "欢悦", "丝琦", "晓燕", "秀妮", "痴旋", "安琪", "元冬", "卓然", "思菱", "奇颖", "丽姿", "小珍", "元彤", 
        "蒙雨", "秋英", "幻巧", "寒梦", "湘灵", "月朗", "紫菱", "曜儿", "清馨", "诗丹", "清漪", "寻凝", "梦丝", "山槐", "孤菱", "芳润", "幻露", 
        "醉柳", "海儿", "清霁", "友容", "芷琪", "夜梦", "伟志", "若骞", "丽文", "清嘉", "寻绿", "端丽", "柔怀", "冰心", "怜容", "霞雰", "梦露", 
        "碧螺", "彤云", "子楠", "谷蕊", "晓莉", "向梦", "唱月", "娜兰", "梦琪", "兰蕙", "若雁", "慧婕", "寒凝", "新筠", "秀雅", "韵诗", "初晴", 
        "艳蕙", "以蕊", "雪萍", "学名", "莎莎", "琦珍", "月杉", "雍恬", "璇子", "子珍", "悠馨", "谷菱", "茗雪", "平卉", "悦爱", "芊芊", "沈靖", 
        "智敏", "芳华", "冰双", "依美", "莎莉", "静丹", "星星", "梓楠", "秀艾", "愉心", "润丽", "文君", "淑华", "痴春", "晨菲", "正平", "蕙若", 
        "向雁", "清昶", "芳茵", "白梅", "佳晨", "芸馨", "清华", "梅花", "智美", "尔槐", "芮澜", "乐英", "娟巧", "怡君", "歌飞", "彤蕊", "惜玉", 
        "幼霜", "从冬", "雅歌", "凝荷", "思烟", "含景", "南霜", "婉静", "哲妍", "代柔", "昭懿", "安南", "隽雅", "灵凡", "思迪", "红雪", "一凡", 
        "曼妮", "元槐", "丽雅", "凝云", "清韵", "宵月", "晓骞", "月悦", "施诗", "燕舞", "湘云", "芳芳", "思美", "鸿才", "芳菲", "小瑜", "晨欣", 
        "雨莲", "甜恬", "晴霞", "鑫鹏", "从霜", "家美", "清淑", "文静", "雪帆", "丹蝶", "丽思", "雅宁", "半雪", "惜寒", "乐然", "晴画", "秋蝶", 
        "慕思", "晴照", "忆彤", "静慧", "代双", "芊丽", "梦竹", "乐安", "醉卉", "梓云", "瑛瑶", "芳蔼", "彦红", "诗筠", "朵儿", "彦慧", "弘懿", 
        "荌荌", "雁菱", "竹月", "子辰", "初柔", "忻忻", "蔓菁", "暄莹", "宛丝", "平安", "雅云", "恨桃", "谷雪", "闳丽", "思天", "映菡", "娴婉", 
        "夏柳", "子萱", "绢子", "慈心", "问梅", "珠佩", "燕珺", "依霜", "如冰", "从雪", "盼夏", "恬谧", "白雪", "云蔚", "筠心", "清怡", "恬然", 
        "幼丝", "寄翠", "晶晶", "芮欣", "夏瑶", "璎玑", "和暖", "慧语", "听然", "觅丹", "淳静", "依丝", "慧英", "笑萍", "静槐", "雨筠", "建本", 
        "晓筠", "玄雅", "从筠", "昕月", "春英", "紫安", "曜曦", "雅安", "欣怡", "高洁", "雅霜", "尔蝶", "夜天", "知慧", "曼语", "恬畅", "绿凝", 
        "樱花", "文丽", "湛霞", "清心", "倩丽", "秀华", "平莹", "康盛", "碧菡", "又槐", "若菱", "清妍", "妞妞", "恬欣", "歌韵", "梦菡", "灵慧", 
        "伟毅", "子芸", "玄清", "姣姣", "忆远", "以莲", "冉冉", "晗蕾", "优扬", "秀英", "蕴和", "静涵", "兰娜", "佁然", "宜春", "曼婉", "运洁", 
        "丹雪", "安娜", "沛容", "韦曲", "灵秀", "怡乐", "雨雪", "凌雪", "闲华", "会欣", "亦玉", "芸姝", "依凝", "瑞灵", "依云", "贝丽", "雅丽", 
        "碧莹", "妮子", "楠楠", "雁桃", "筠溪", "寻芳", "子宁", "迎夏", "正清", "秋阳", "嘉音", "幻丝", "初夏", "婉容", "小雯", "如容", "慧巧", 
        "天菱", "艳卉", "若兰", "和美", "向露", "代巧", "轶丽", "灵卉", "清绮", "蕴秀", "秀媚", "幼仪", "芮美", "颖初", "梓菱", "清佳", "代天", 
        "凝竹", "一瑾", "燕楠", "滢渟", "平良", "映天", "和悌", "芮佳", "善思", "晴虹", "欣跃", "晶燕", "心远", "凡桃", "梦玉", "雅健", "曼彤", 
        "清宁", "贞芳", "夏菡", "从安", "梦旋", "静逸", "慧晨", "慧雅", "静秀", "囡囡", "秀逸", "姝艳", "凝思", "巧夏", "悦喜", "雅韵", "乐双", 
        "怀玉", "曼丽", "凝雪", "妙双", "沙雨", "婉然", "子凡", "依薇", "清舒", "可嘉", "天玉", "雁卉", "秀竹", "博丽", "语诗", "芦雪", "琴轩", 
        "可可", "清婉", "湛芳", "虹影", "如云", "童童", "夏旋", "丹云", "玟丽", "端敏", "梦泽", "熹微", "云孤", "白依", "珊从", "白幼", "彤山", 
        "竹亦", "影虹", "心冰", "桃寻", "柔依", "薇香", "芸乐", "艳绮", "悦子", "华振", "芹代", "薇向", "翠丹", "欣芸", "天芷", "兰书", "梓绣", 
        "巧秋", "晓平", "仪献", "虹晴", "之谷", "豆红", "霜冷", "凝白", "风南", "欣布", "桃雁", "照晴", "凝沛", "爱悦", "楠梓", "琴书", "宜心", 
        "露南", "荷凝", "柳夏", "春叶", "蓝谷", "媚雅", "吉叶", "欢忻", "天月", "瑶晓", "云静", "佳清", "然凝", "画晴", "岚冰", "凝问", "霁清", 
        "萱灵", "然蔚", "工良", "静晏", "梅新", "易靖", "芳艳", "馨芳", "槐又", "韵莺", "媛悦", "美俏", "春听", "玉白", "兰馨", "智添", "霜念", 
        "枫若", "君昭", "寒问", "巧醉", "槐尔", "玉婷", "菱冰", "悦慕", "竹绿", "槐灵", "巧盼", "玑璇", "真迎", "荷芷", "方舒", "柳元", "罡天", 
        "芹沛", "顺安", "竹凝", "珊安", "冬春", "雯彤", "冬水", "雅静", "洁秀", "淑清", "枫春", "雁映", "蓝冰", "明月", "彤晓", "舒清", "香醉", 
        "夏盼", "骞旻", "韵歌", "云逸", "婷暄", "珊惜", "钰长", "蓝芷", "霞骊", "筠白", "慧婉", "蓉乐", "美慧", "瑞嘉", "寒怀", "梅韵", "美婷", 
        "蝶芷", "彤梓", "美韶", "烟夏", "文芷", "曼静", "雅秀", "薇紫", "雪春", "瑶寄", "意书", "君惠", "凝小", "安灵", "杰秀", "岚翠", "欣童", 
        "彤丹", "蕾南", "菱谷", "人悦", "之小", "丽晴", "婉悠", "翠秋", "彤迎", "曲韦", "香馨", "涵梓", "梦惜", "月松", "嘉宜", "愫心", "霜晓", 
        "芙翠", "荷冷", "岚浩", "易冬", "吹歌", "艺书", "烟思", "女海", "绮清", "朗月", "瑶雪", "韵情", "珊秋", "晨妍", "巧凡", "菲芳", "梅夜", 
        "淑娴", "卉雁", "易梦", "海凝", "夏白", "安静", "寒雅", "寒安", "逸卓", "槐之", "倩梓", "梅曼", "华英", "晨雨", "安听", "丽雯", "莘莘", 
        "春小", "馨香", "梦兰", "敏忆", "菡山", "阳翠", "茹韦", "玉夜", "素悠", "星蔚", "玥晗", "雅季", "雁念", "春凌", "华莹", "乐优", "雁冷", 
        "柔春", "淑柔", "伦海", "丹以", "寒映", "荣欣", "恬甜", "瑶恨", "佳芮", "月希", "丽美", "雪向", "瑶海", "灵瑞", "玉代", "柔傲", "漪文", 
        "苒荏", "莹琇", "灵痴", "菱涵", "惠姝", "湃彭", "然安", "烟新", "玟吉", "心乐", "松以", "思慕", "菲芬", "云霓", "秋千", "云慧", "雁书", 
        "月慧", "卉白", "雪映", "槐梦", "玉傲", "溪云", "双寻", "璇夏", "然怡", "滢晶", "露绮", "丝幼", "风千", "飞歌", "媛秀", "云丹", "秋宛", 
        "丽曼", "洁骊", "真雨", "萱思", "帆子", "媛仙", "蕊谷", "嘉叶", "楠雅", "丽玟", "涵静", "青又", "润涵", "雪半", "柔初", "楠林", "容易", 
        "宁雅", "烟绮", "深弘", "琴南", "柏翠", "良嘉", "芳丽", "珍子", "瑜琳", "真映", "云卿", "风寄", "慧静", "蝶书", "琪安", "丽姝", "云雅", 
        "蓉绿", "秋迎", "惠淑", "颖骊", "婉清", "婧令", "雪初", "珍凝", "雪紫", "易盼", "儿沛", "月吉", "凝慕", "思敏", "烟怜", "竹水", "翎雪", 
        "亭云", "云觅", "瑶飞", "萱子", "君辰", "君湘", "彤叶", "华秀", "翠幻", "娴雅", "莲含", "春碧", "风尔", "凡子", "懿清", "馨悠", "然嫔", 
        "红帅", "薇若", "兰春", "嫣暄", "怡清", "怡心", "静淳", "易书", "娇春", "远凝", "丝语", "安安", "晨琳", "楚华", "巧翠", "芹半", "慧彦", 
        "曦晨", "巧易", "薇天", "天夜", "然瑜", "妮秀", "婧骊", "冬寻", "琇莹", "菱思", "慕望", "彦冰", "君翊", "舒望", "然婉", "雨昕", "娟娟", 
        "柔靖", "晨鸣", "风晨", "海冰", "娥黛", "荷雁", "蝶尔", "兰秀", "河银", "蓝代", "真冰", "霏岚", "媛驰", "南书", "灵洛", "丹孤", "洁梓", 
        "巧含", "扬优", "容笑", "超博", "双飞", "然陶", "之如", "蕾小", "莲半", "妙柔", "文紫", "立新", "兰半", "文易", "波凌", "然苇", "亦宛", 
        "绿冰", "俐伶", "晶琇", "容曼", "筠雨", "云傲", "美骊", "霜凌", "绿亦", "岚晴", "蓝采", "双觅", "诗语", "冬新", "然恬", "华月", "柔秋", 
        "容婉", "月华", "海春", "丽芊", "润清", "逸清", "璇一", "柳醉", "寒秋", "童依", "文采", "竹新", "梅寒", "静安", "容雪", "菲格", "煦柔", 
        "丝傲", "蝶香", "蝶凝", "珍初", "秀杰", "莉莎", "莲安", "夏初", "泽甘", "槐半", "凡冰", "花樱", "素雅", "玉天", "英琼", "珠璇", "和善", 
        "春平", "蕊含", "泽芳", "美绮", "丽秀", "翠笑", "安雨", "韵竹", "露从", "婉曼", "蕾诗", "山夏", "兰诗", "菱心", "歌雅", "静芸", "云之", 
        "雅博", "思密", "慕希", "丝问", "蕊艳", "静湛", "芳寻", "跃欣", "梦访", "菡寻", "欣欢", "星若", "馥芬", "暖和", "华秋", "之含", "瑶痴", 
        "阳怜", "韵天", "荷巧", "英霞", "柔寄", "筠听", "文奇", "梅梅", "蕊晗", "双听", "丽庄", "菱孤", "筠诗", "芝桂", "萱致", "寒曼", "珊沛", 
        "悦欣", "寒笑", "衣布", "晴天", "儿溪", "白采", "华西", "美恬", "歌高", "然玲", "合欣", "雅望", "珺彦", "旎旎", "语倩", "翠觅", "亦千", 
        "梅忆", "雪丹", "雨沙", "芹听", "林新", "春安", "雁曼", "槐谷", "松平", "琅玲", "风问", "珍觅", "玟娅", "瑾一", "乐孟", "斐斐", "丝凌", 
        "奕悠", "之梦", "亦又", "莉森", "萱书", "丝迎", "蕊语", "念念", "兰雪", "美令", "燕飞", "寒夏", "辉霞", "菀菀", "梅雁", "唱雅", "媛英", 
        "瑜璠", "蔓柔", "懿思", "姗三", "星晨", "琴雅", "素韫", "英春", "芹元", "南绮", "华棠", "灵元", "蓉寄", "易涵", "桃之", "芸暮", "语新", 
        "芹惜", "南夜", "妍清", "槐向", "祺丝", "姗姗", "雁向", "洁芳", "云茹", "蝶初", "旋以", "云怜", "桃春", "蕾蓓", "雅慧", "瑶星", "玉嘉", 
        "惠贤", "洁皓", "波晴", "枫问", "珍妙", "菡梦", "蓝寄", "瑾玉", "寒念", "洁雅", "松向", "蓝水", "翠诗", "思绮", "绚柔", "磬韵", "琴雨", 
        "墨文", "涤涵", "艳雪", "心文", "寒以", "荷翠", "丽柔", "珊以", "露幻", "香盼", "怡和", "松寄", "烟南", "山醉", "玉玟", "风白", "馨清", 
        "敏文", "云紫", "彤以", "骄天", "如密", "嘉清", "华梦", "萍沛", "梦语", "风如", "仪书", "晴以", "霜翠", "天笑", "曼晓", "琳子", "素玄", 
        "悦乐", "露晓", "双妙", "巧靖", "瑶依", "蓉馨", "嫒思", "州阳", "云嘉", "畅欣", "珊幼", "蓉碧", "洁好", "美晴", "静婉", "琴依", "松如", 
        "山晓", "嘉思", "芙醉", "彤语", "然宜", "怡熙", "菱幼", "蝶醉", "柳诗", "华美", "清玄", "云梦", "晗雅", "之妙", "云依", "夏小", "瑞珍", 
        "桃书", "凡千", "枫静", "云夏", "霜雅", "雪从", "之忆", "珠曼", "琰琬", "睿知", "梦凝", "秋依", "彩瑞", "卉香", "烟寒", "冬元", "兰绮", 
        "淑若", "薇子", "灵忆", "霞云", "巧冰", "琳思", "菡又", "露梦", "阳笑", "君慧", "雨梦", "凝依", "娜骊", "儿水", "芙静", "静恬", "亦丹", 
        "彤若", "南雨", "之新", "波映", "雅萍", "燕骊", "珊代", "曼初", "娟湛", "之靖", "辉晶", "璐梓", "柏幼", "容雅", "蝶元", "丽润", "雅淳", 
        "星小", "芳秋", "晴妙", "榆梓", "玉惜", "蕊小", "天思", "飞云", "香心", "梦夜", "波香", "吟曼", "丽典", "欣馨", "雪惜", "歌薇", "桃念", 
        "蓉骊", "冬映", "巧隽", "美逸", "子璇", "岚云", "曼宛", "丽芮", "绮霞", "英兰", "柔沛", "心清", "桃恨", "宜悦", "信雨", "安忆", "彤曼", 
        "绿飞", "山觅", "韵萍", "梅幻", "晴又", "子妮", "泽兰", "香夜", "婉流", "瑶文", "安尔", "艳雅", "蕊绿", "航宇", "彤绮", "飞霞", "思琼", 
        "萍惜", "云夜", "暄和", "枫冰", "帆林", "卉冬", "桃香", "凡平", "筠安", "然忆", "秀蕴", "兰若", "安曼", "玲玲", "若思", "白沛", "灵晓", 
        "萱映", "琪米", "玉幻", "云以", "珊芷", "丝翠", "绿怀", "兰玉", "章乐", "晗晗", "心语", "菡夏", "蓉尔", "灵寄", "山雁", "秋清", "慧知", 
        "兰晓", "冬访", "莲又", "秀静", "波芷", "绿巧", "致逸", "珊诗", "语心", "美淳", "悦嘉", "曼巧", "易傲", "梦向", "筠惜", "然莞", "雅俨", 
        "燕令", "华淑", "筠从", "玉双", "乐宁", "文霞", "平正", "梦怀", "懿弘", "音嘉", "文念", "娜安", "婷驰", "雅雍", "旋梦", "易千", "夏又", 
        "双凡", "之念", "枫忆", "红丹", "枫听", "秋梦", "妍暄", "慧秀", "女媛", "真念", "玉鸣", "天映", "琴寻", "媛骊", "芹怀", "蕾寄", "兰绿", 
        "柔又", "琬梓", "玑璎", "柏秋", "莉茉", "灵湘", "彤忆", "琴碧", "烟芷", "卉艳", "艳慧", "然依", "林语", "澜芮", "月昕", "奕奕", "旋妙", 
        "晨慧", "灵雨", "阳萌", "秋向", "俐珺", "雨新", "雁若", "儿访", "华桐", "惠佳", "蕾半", "竹恨", "美嘉", "平子", "简博", "梦采", "蓝天", 
        "怡琳", "凝从", "韵品", "慕怀", "夏迎", "丽琛", "红骊", "兰初", "波鸿", "炳彬", "秉坚", "冰阳", "斌文", "彬炎", "彬文", "飙英", "飙飞", 
        "弼俊", "弼建", "弼承", "本建", "本德", "北骞", "宝鸿", "薄彭", "邦兴", "邦乐", "邦安", "柏建", "白元", "白建", "白飞", "白宾", "拔俊", 
        "奥良", "翱振", "昂子", "昂文", "昂高", "安康", "安凯", "安建", "蔼和", "大浩", "达宇", "达英", "达锐", "达博", "聪思", "赐嘉", "慈睿", 
        "春永", "春逸", "楚俊", "初正", "初浩", "畴鸿", "驰星", "驰俊", "池华", "池翰", "程鹏", "诚志", "诚正", "诚运", "诚修", "诚伟", "诚睿", 
        "诚明", "诚坚", "成玉", "成阳", "成康", "成坚", "晨曦", "宸玉", "沉飞", "辰子", "掣飞", "超海", "超高", "唱凯", "畅开", "畅鸿", "畅和", 
        "畅涵", "畅高", "昶雅", "昶和", "昌永", "昌彦", "昌海", "昌德", "岑高", "策良", "藏华", "苍昊", "灿曜", "彩华", "彩鸿", "采华", "采翰", 
        "材天", "材茂", "材良", "材俊", "才英", "才伟", "才睿", "才敏", "才茂", "才鸿", "才宏", "博震", "博振", "博思", "博君", "博鸿", "博宏", 
        "博弘", "博浩", "勃彭", "伯阳", "伯斯", "伯康", "伯宏", "波阳", "波星", "大宏", 
    }
}

GameConst.LoadingTips = {
	[1] = "切勿轻信他人，线下交易易上当受骗，不转账不汇款！",
	[2] = "适当游戏，勿沉迷，合理安排让游戏更有趣！",
	[3] = "若长时间无法进入游戏，请关闭游戏或更换网络重进！",
}

