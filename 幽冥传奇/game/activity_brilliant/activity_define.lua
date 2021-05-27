--运营活动id枚举，活动配置，提醒组列表
ACT_ID = {
	YQ = 1,						--摇钱树			
	DL = 2,						--登陆
	LC = 3,						--累冲
	QG = 4,						--抢购
	XF = 5,						--消费
	XB = 6,						--寻宝
	WCZB = 7,					--王城争霸
	DJJJ = 8,					--等级竞技
	CBJJ = 9,					--翅膀竞技
	ZP = 10,					--转盘
	SHIZ = 11,					--时装
	CJXB = 12,	    			--超级寻宝
	LJ = 13,					--累计有礼
	CFCZ = 14,					--重复充值
	BZ = 15,					--宝藏惊喜
	CZRANK = 16,				--充值排行
	CZGIFT =17,					--充值豪礼
	XFGIFT = 18,				--消费豪礼
	ZCJJ = 19,					--战宠竞技
	BSJJ = 20,					--宝石竞技
	HZJJ = 21,					--魂珠竞技
	RXJJ = 22,					--热血竞技
	ZLJJ = 23,					--战力竞技
	JBJJ = 24,					--鉴宝竞技
	LKGIFT = 25,				--幸运有礼
	SHOP = 26,					--商店
	XFZP = 27,					--消费转盘
	QMXF = 28,					--全民消费
	XFHK = 29,					--消费回馈
	SHJJ = 30,					--守护竞技
	KHHD = 31,					--狂欢活动 1-boss狂欢
	LXCZ2 = 32,					--9元连续充值
	GOLDZP = 33,				--元宝转盘
	EGG = 34,					--砸蛋
	DEGREE = 35,				
	BOSS = 36,
	QMQG = 37,
	DOUBLE = 38,				--双倍经验
	JR = 39,		
	DH = 40,		
	GG = 41,
	LXCZ = 42,					--连续充值
	FD = 43,					--超值福袋
	THLB = 44,				    --特惠礼包
	LKDRAW = 45,				--幸运抽奖
	DRAWFL = 46,				--消费返利
	DBCZ = 47,					--单笔充值
	THGIFT = 48,				--特惠礼包
	PTTQ = 49,					--普天同庆
	FLCZ = 50,					--福利重置
	SBCZ = 51,					--双倍重置
	XFGIFTFT = 52,				--52消费有礼
	JQSY = 53,					--53激情兽宴
	CZZP = 54,					--54充值转盘
	JQPD = 55,					--55激情派对
	MSGIFT = 56,				--56秒杀礼包
	XYC = 57,					--57许愿池
	QMCL = 58,					--58全民材料
	QMYB = 59,					--59全民护送
	LQSC = 60,					--60礼券商城
	TSMB = 61, 					--61探索秘宝
	CBG = 62,					--62藏宝阁
	ZBG = 63,					--63珍宝阁
	TTT = 64, 					--64通天塔
	JPDH = 65, 					--65极品兑换
	XYFP = 66,					--66幸运翻牌
	DBFL = 67,					--67多倍返利
	JBXG = 68,					--68绝版限购
	HHDL = 69,					--69豪华大礼
	LCFL = 70,					--70连充返利
	CZLC = 71,					--71超值连充
	LCFD = 72,					--72连充福袋
	CSFS = 73,					--73充三反四
	XSCZ = 74,					--74限时充值
	FHB = 75,					--75发红包
	GZP = 76,					--76元宝转盘
	YBFS = 77,					--77元宝放送
	CZFL = 78,					--78充值返利
	SVZP = 79,					--79超值转盘
	LXFL = 80,					--80连续返利
	XFZF = 81,					--81消费争锋
	CZZF = 82,                  --82充值争锋
	XSZG = 83,                  --83限时直购
	YSJD = 84,                  --84原石鉴定
	HDBP = 85,                  --85欢度大鞭炮
	ZPHL = 86,  				--86转盘好礼
	XFJL = 87,                  --87消费奖励
	JDBS = 88,					--88经典BOSS
	BSJD = 89,                  --89BOSS鉴定
	QMTQ = 90,                  --90全民同庆
	SCFL = 91, 					--91首充返利
	SLLB = 92,					--92神炉炼宝
	LZMB = 93, 					--93灵珠秘宝
	DLJS = 94, 					--94登录就送
	CZLB = 95, 					--95超值礼包

	-- 跨服运营活动
	XFRY = 200,					--消费荣誉
	CZRY = 201,					--充值荣誉
	XBRY = 202,					--寻宝荣誉
	CQRY = 203,					--传奇荣誉
	XYZP = 204,					--幸运转盘
	YBZP = 205,					--元宝转盘
}

OPER_ACT_CLIENT_CFG = {
	[ACT_ID.YQ] = {
		sub_view_class = YaoqianshuView,
		ui_layout_name = "layout_yaoqianshu",
		is_show_top_view = true,
	},
	[ACT_ID.ZP] = {
		sub_view_class = ActZhanPanView,
		ui_layout_name = "layout_turntable",
		is_show_top_view = true,
	},
	[ACT_ID.EGG] = {
		sub_view_class = ZanDangView,
		ui_layout_name = "layout_egg",
		is_show_top_view = false,
		tips_btn_p = {1020, 120}
	},
	[ACT_ID.DL] = {
		sub_view_class = DengLuView,
		ui_layout_name = "layout_denglujiangli",
		is_show_top_view = true,
	},
	[ACT_ID.LC] = {
		sub_view_class = LeiChongView,
		ui_layout_name = "layout_leichong",
		is_show_top_view = true,
	},
	[ACT_ID.QG] = {
		sub_view_class = QiangGouView,
		ui_layout_name = "layout_qianggou",
		is_show_top_view = true,
	},
	[ACT_ID.XF] = {
		sub_view_class = XiaoFeiView,
		ui_layout_name = "layout_xiaofei",
		is_show_top_view = true,
	},
	[ACT_ID.XB] = {
		sub_view_class = XunBaoView,
		ui_layout_name = "layout_xunbao",
		is_show_top_view = true,
	},
	[ACT_ID.CJXB] = {
		sub_view_class = CJXunBaoView,
		ui_layout_name = "layout_cjxunbao",
		is_show_top_view = false,
	},
	[ACT_ID.LJ] = {
		sub_view_class = LeiJiCZView,
		ui_layout_name = "layout_leiji",
		is_show_top_view = true,
	},
	[ACT_ID.CFCZ] = {
		sub_view_class = ChongFuCZView,
		ui_layout_name = "layout_chagre_again",
		is_show_top_view = true,
	},
	[ACT_ID.BZ] = {
		sub_view_class = BaoZanView,
		ui_layout_name = "layout_precious",
		is_show_top_view = true,
	},
	[ACT_ID.CZRANK] = {
		sub_view_class = ChongZhiRankView,
		ui_layout_name = "layout_chager_rank",
		is_show_top_view = true,
	},
	[ACT_ID.WCZB] = {
		sub_view_class = WCZBView,
		ui_layout_name = "layout_WCZB",
		is_show_top_view = true,
	},
	[ACT_ID.DJJJ] = {
		sub_view_class = JingJiView,
		ui_layout_name = "layout_jing_ji",
		is_show_top_view = true,
	},
	[ACT_ID.CBJJ] = {
		sub_view_class = JingJiView,
		ui_layout_name = "layout_jing_ji",
		is_show_top_view = true,
	},
	[ACT_ID.SHIZ] = {
		sub_view_class = ShiZhuangView,
		ui_layout_name = "layout_fashion",
		is_show_top_view = true,
	},
	[ACT_ID.HZJJ] = {
		sub_view_class = JingJiView,
		ui_layout_name = "layout_jing_ji",
		is_show_top_view = true,
	},
	[ACT_ID.BSJJ] = {
		sub_view_class = JingJiView,
		ui_layout_name = "layout_jing_ji",
		is_show_top_view = true,
	},
	[ACT_ID.LXCZ2] = {
		sub_view_class = LianXuCZView,
		ui_layout_name = "layout_charge_lianxu",
		is_show_top_view = true,
	},
	[ACT_ID.CZGIFT] = {
		sub_view_class = GiftView,
		ui_layout_name = "layout_charge_gift",
		is_show_top_view = true,
	},
	[ACT_ID.XFGIFT] = {
		sub_view_class = GiftView,
		ui_layout_name = "layout_xiaofei_gif",
		is_show_top_view = true,
	},
	[ACT_ID.ZCJJ] = {
		sub_view_class = JingJiView,
		ui_layout_name = "layout_jing_ji",
		is_show_top_view = true,
	},
	[ACT_ID.GG] = {
		sub_view_class = GongGaoView,
		ui_layout_name = "layout_notice",
		is_show_top_view = false,
	},
	[ACT_ID.GOLDZP] = {
		sub_view_class = GoldRotaryTableView,
		ui_layout_name = "layout_gold_rotary_table",
		is_show_top_view = false,
	},
	[ACT_ID.RXJJ] = {
		sub_view_class = JingJiView,
		ui_layout_name = "layout_jing_ji",
		is_show_top_view = true,
	},
	[ACT_ID.ZLJJ] = {
		sub_view_class = JingJiView,
		ui_layout_name = "layout_jing_ji",
		is_show_top_view = true,
	},
	[ACT_ID.JBJJ] = {
		sub_view_class = JingJiView,
		ui_layout_name = "layout_jing_ji",
		is_show_top_view = true,
	},
	[ACT_ID.KHHD] = {
		sub_view_class = ActHolidayView,
		ui_layout_name = "layout_act_holiday",
		is_show_top_view = false,
		tips_btn_p = {375, 115},
	},
	[ACT_ID.LKGIFT] = {
		sub_view_class = LuckGiftView,
		ui_layout_name = "layout_luky_gift",
		is_show_top_view = true,
	},
	[ACT_ID.SHOP] = {
		sub_view_class = ActShopView,
		ui_layout_name = "layout_shop",
		is_show_top_view = true,
	},
	[ACT_ID.XFZP] = {
		sub_view_class = XFZhuangPanView,
		ui_layout_name = "layout_xiaofei_zhuanpan",
		is_show_top_view = true,
	},
	[ACT_ID.QMXF] = {
		sub_view_class = QMXiaoFeiView,
		ui_layout_name = "layout_qm_xiaofei",
		is_show_top_view = true,
	},
	[ACT_ID.XFHK] = {
		sub_view_class = XiaoFeiHKView,
		ui_layout_name = "layout_xiaofei_huikui",
		is_show_top_view = false,
	},
	[ACT_ID.SHJJ] = {
		sub_view_class = JingJiView,
		ui_layout_name = "layout_jing_ji",
		is_show_top_view = true,
	},
	[ACT_ID.DEGREE] = {
		sub_view_class = DegreeView,
		ui_layout_name = "layout_degree",
		is_show_top_view = true,
	},
	[ACT_ID.BOSS] = {
		sub_view_class = ActBossView,
		ui_layout_name = "layout_boss",
		is_show_top_view = true,
	},
	[ACT_ID.QMQG] = {
		sub_view_class = QMQiangGouView,
		ui_layout_name = "layout_qm_qianggou",
		is_show_top_view = true,
	},
	[ACT_ID.DOUBLE] = {
		sub_view_class = DoubleEXPView,
		ui_layout_name = "layout_double_exp",
		is_show_top_view = true,
	},
	[ACT_ID.JR] = {
		sub_view_class = JieRiView,
		ui_layout_name = "layout_jieri",
		is_show_top_view = true,
	},
	[ACT_ID.DH] = {
		sub_view_class = DuiHuanView,
		ui_layout_name = "layout_duihuan",
		is_show_top_view = true,
	},
	[ACT_ID.LXCZ] = {
		sub_view_class = LianXuCZView,
		ui_layout_name = "layout_charge_lianxu",
		is_show_top_view = true,
	},
	[ACT_ID.FD] = {
		sub_view_class = FuDaiView,
		ui_layout_name = "layout_fudai",
		is_show_top_view = false,
	},
	[ACT_ID.THLB] = {
		sub_view_class = TeHuiLBView,
		ui_layout_name = "layout_tehui_giftbag",
		is_show_top_view = true,
	},
	[ACT_ID.LKDRAW] = {
		sub_view_class = LkDrawView,
		ui_layout_name = "layout_lucky_draw",
		is_show_top_view = true,
	},
	[ACT_ID.DRAWFL] = {
		sub_view_class = DrawFanliView,
		ui_layout_name = "layout_fanli",
		is_show_top_view = false,
		tips_btn_p = {750, 105},
	},
	[ACT_ID.DBCZ] = {
		sub_view_class = SingleChargeView,
		ui_layout_name = "layout_single_charge",
		is_show_top_view = true,
	},
	[ACT_ID.THGIFT] = {
		sub_view_class = SuperGiftView,
		ui_layout_name = "layout_acitivity_gift",
		is_show_top_view = false,
	},
	[ACT_ID.PTTQ] = {
		sub_view_class = ActPTTQView,
		ui_layout_name = "layout_PTTQ",
		is_show_top_view = true,
	},
	[ACT_ID.FLCZ] = {
		sub_view_class = FashionDrawView,
		ui_layout_name = "layout_fashion_explore",
		is_show_top_view = false,
	},
	[ACT_ID.SBCZ] = {
		sub_view_class = ActExploreView,
		ui_layout_name = "layout_act_51_draw",
		is_show_top_view = false,
	},
	[ACT_ID.XFGIFTFT] = {
		sub_view_class = XFGiftFTView,
		ui_layout_name = "layout_xfgift_52",
		is_show_top_view = true,
	},
	[ACT_ID.JQSY] = {
		sub_view_class = JingqingSYView,
		ui_layout_name = "layout_jingqing_sy_53",
		is_show_top_view = true,
	},
	[ACT_ID.CZZP] = {
		sub_view_class = ChargeZPView,
		ui_layout_name = "layout_turntable_54",
		is_show_top_view = false,
		tips_btn_p = {760, 100},
	},

	[ACT_ID.JQPD] = {
		sub_view_class = JingqingPDView,
		ui_layout_name = "layout_jingqing_pd",
		is_show_top_view = false,
		tips_btn_p = {1040, 230},
	},
	[ACT_ID.MSGIFT]  = {
		sub_view_class = NewMsGiftView,
		ui_layout_name = "layout_ms_gift",
		is_show_top_view = false,
	},
	[ACT_ID.XYC] = {
		sub_view_class = XuYuanChiView,
		ui_layout_name = "layout_xuyuanchi",
		is_show_top_view = false,
	},
	[ACT_ID.QMCL] = {
		sub_view_class = ActQMCLView,
		ui_layout_name = "layout_qm_cl",
		is_show_top_view = true,
	},
	[ACT_ID.QMYB] = {
		sub_view_class = ActQMYBView,
		ui_layout_name = "layout_qm_yb",
		is_show_top_view = true,
	},
	[ACT_ID.ZBG] = {
		sub_view_class = TreasureCabinetView,
		ui_layout_name = "layout_treasure_cabinet",
		is_show_top_view = false,
	},
	[ACT_ID.JPDH] = {
		sub_view_class = SuperExchangeView,
		ui_layout_name = "layout_super_exchange",
		is_show_top_view = true,
	},
	[ACT_ID.XYFP] = {
		sub_view_class = ActFlipCardView,
		ui_layout_name = "layout_flip_cards",
		is_show_top_view = false,
	},
	[ACT_ID.DBFL] = {
		sub_view_class = MagicalComeView,
		ui_layout_name = "layout_magical_come",
		is_show_top_view = true,
	},
	[ACT_ID.JBXG] = {
		sub_view_class = OutOfPrintQuotaView,
		ui_layout_name = "layout_jueban_xiangou",
		is_show_top_view = true,
	},
	[ACT_ID.HHDL] = {
		sub_view_class = LuxuryGiftView,
		ui_layout_name = "layout_luxury_gift",
		is_show_top_view = true,
	},
	[ACT_ID.LCFL] = {
		sub_view_class = ChargeFanliView,
		ui_layout_name = "layout_charge_fanli",
		is_show_top_view = true,
	},
	[ACT_ID.CZLC] = {
		sub_view_class = SupervalueChargeView,
		ui_layout_name = "layout_supervalue_charge",
		is_show_top_view = true,
	},
	[ACT_ID.LCFD] = {
		sub_view_class = ChargeFudaiView,
		ui_layout_name = "layout_charge_fudai",
		is_show_top_view = false,
	},
	[ACT_ID.CSFS] = {
		sub_view_class = ChargeThreeView,
		ui_layout_name = "layout_charge_three",
		is_show_top_view = true,
	},
	[ACT_ID.FHB] = {
		sub_view_class = SendRedPacketView,
		ui_layout_name = "layout_rob_red_packet",
		is_show_top_view = true,
		tips_btn_p = {1030, 574},
	},
	[ACT_ID.GZP] = {
		sub_view_class = ActGoldTurntableView,
		ui_layout_name = "layout_gold_turntable",
		is_show_top_view = false,
		tips_btn_p = {678, 100},
	},
	[ACT_ID.YBFS] = {
		sub_view_class = ActGoldConsumeView,
		ui_layout_name = "layout_consume_gift",
		is_show_top_view = true,
	},
	[ACT_ID.SVZP] = {
		sub_view_class = ChaozhiTurntableView,
		ui_layout_name = "layout_chaozhi_turntable",
		is_show_top_view = false,
		tips_btn_p = {678, 100},
	},
	[ACT_ID.LXFL] = {
		sub_view_class = LianxuFanliView,
		ui_layout_name = "layout_lianxu_fanli",
		is_show_top_view = true,
	},
	[ACT_ID.XFZF] = {
		sub_view_class = ActContendView,
		ui_layout_name = "layout_act_contend",
		is_show_top_view = false,
		--tips_btn_p = {810, 430},
	},
	[ACT_ID.CZZF] = {
		sub_view_class = ActTopupView,
		ui_layout_name = "layout_act_topup",
		is_show_top_view = false,
		--tips_btn_p = {810,430},
	},
	[ACT_ID.XSZG] = {
		sub_view_class = ActLegendView,
		ui_layout_name = "layout_act_legend",
		is_show_top_view = true,
		--tips_btn_p = {810,430},
	},
	[ACT_ID.YSJD] = {
		sub_view_class = AuthenticateView,
		ui_layout_name = "layout_act_authenticate",
		is_show_top_view = false,
	},
	[ACT_ID.HDBP] = {
		sub_view_class = FireCrackeView,
		ui_layout_name = "layout_act_firecrackes",
		is_show_top_view = false,
		tips_btn_p = {1033,598},
	},
	[ACT_ID.ZPHL] = {
		sub_view_class = TurnbleGiftPage,
		ui_layout_name = "layout_act_zphl",
		is_show_top_view = false,
	},
	[ACT_ID.XFJL] = {
		sub_view_class = PieceGoldView,
		ui_layout_name = "layout_piece_gold",
		is_show_top_view = true,
	},
	[ACT_ID.JDBS] = {
		sub_view_class = ClassicBossView,
		ui_layout_name = "layout_classics_boss",
		is_show_top_view = true,
	},
	[ACT_ID.BSJD] = {
		sub_view_class = IdentificationView,
		ui_layout_name = "layout_Identification",
		is_show_top_view = false,
		tips_btn_p = {1000,250},
	},
	[ACT_ID.QMTQ] = {
		sub_view_class = WholeNationView,
		ui_layout_name = "layout_whole_nation",
		is_show_top_view = true,
	},
	[ACT_ID.SLLB] = {
		sub_view_class = HuntTreasureView,
		ui_layout_name = "layout_hunt_treasure",
		is_show_top_view = false,
	},

	[ACT_ID.LQSC] = {
	},

	[ACT_ID.TSMB] = {
		sub_view_class = ExploreTurnblePage,
		ui_layout_name = "layout_turntable_61",
		is_show_top_view = false,
	},

	[ACT_ID.LZMB] = {
		sub_view_class = DragonTreasureView,
		ui_layout_name = "layout_dragon_treasure",
		is_show_top_view = true,
	},

	[ACT_ID.DLJS] = {
		sub_view_class = SignGiveView,
		ui_layout_name = "layout_sign_give",
		is_show_top_view = true,
	},

	[ACT_ID.CZLB] = {
		sub_view_class = SuperValueGiftView,
		ui_layout_name = "layout_super_value_gift",
		is_show_top_view = true,
	},

	-- 跨服运营活动
	[ACT_ID.XFRY] = {
		view_class_path = "scripts/game/activity_brilliant/activity_cross_childer_view/activity_cs_honor_view",
		data_class_path = "scripts/game/activity_brilliant/activity_child_data/activity_cs_honor_data",
		ui_cfg_file_name = "cs_opearate_act_ui_cfg",
		ui_layout_name = "layout_honor",
		remind_param = {{name = RemindName.CSHonorActXFRY}},
	},

	[ACT_ID.CZRY] = {
		view_class_path = "scripts/game/activity_brilliant/activity_cross_childer_view/activity_cs_honor_view",
		data_class_path = "scripts/game/activity_brilliant/activity_child_data/activity_cs_cz_honor_data",
		ui_cfg_file_name = "cs_opearate_act_ui_cfg",
		ui_layout_name = "layout_honor",
		remind_param = {{name = RemindName.CSHonorActXFRY}},
	},

	[ACT_ID.XBRY] = {
		view_class_path = "scripts/game/activity_brilliant/activity_cross_childer_view/activity_cs_honor_view",
		data_class_path = "scripts/game/activity_brilliant/activity_child_data/activity_cs_xb_honor_data",
		ui_cfg_file_name = "cs_opearate_act_ui_cfg",
		ui_layout_name = "layout_honor",
		remind_param = {{name = RemindName.CSHonorActXFRY}},
	},

	[ACT_ID.CQRY] = {
		view_class_path = "scripts/game/activity_brilliant/activity_cross_childer_view/activity_cs_honor_view",
		data_class_path = "scripts/game/activity_brilliant/activity_child_data/activity_cs_cq_honor_data",
		ui_cfg_file_name = "cs_opearate_act_ui_cfg",
		ui_layout_name = "layout_honor",
		remind_param = {{name = RemindName.CSHonorActXFRY}},
	},

	[ACT_ID.XYZP] = {
		view_class_path = "scripts/game/activity_brilliant/activity_cross_childer_view/act_sc_luck_trunble_view",
		data_class_path = "scripts/game/activity_brilliant/activity_child_data/activity_cs_zp_data",
		ui_cfg_file_name = "cs_opearate_act_ui_cfg",
		ui_layout_name = "layout_cs_luck_trunble",
		remind_param = {{name = RemindName.CSHonorActXFRY}},
	},

	[ACT_ID.YBZP] = {
		view_class_path = "scripts/game/activity_brilliant/activity_cross_childer_view/act_sc_gold_trunble_view",
		data_class_path = "scripts/game/activity_brilliant/activity_child_data/activity_cs_gold_zp_data",
		ui_cfg_file_name = "cs_opearate_act_ui_cfg",
		ui_layout_name = "layout_gold_turntable",
		remind_param = {{name = RemindName.CSHonorActXFRY}},
	},
}

--添加到提醒组列表，提醒组相关函数遍历该表
REMIND_ACT_LIST = {
	[ACT_ID.YQ] = RemindName.ActivityBrilliantYaoqian, 
	[ACT_ID.DL] = RemindName.ActivityBrilliantDenglu, 
	[ACT_ID.LC] = RemindName.ActivityBrilliantLeichong,
	[ACT_ID.XB] = RemindName.ActivityBrilliantXunbao, 
	[ACT_ID.DJJJ] = RemindName.ActivityBrilliantDJJJ, 
	[ACT_ID.CBJJ] = RemindName.ActivityBrilliantCBJJ, 
	[ACT_ID.ZP] = RemindName.ActivityBrilliantZhuanpan, 
	[ACT_ID.SHIZ] = RemindName.ActivityBrilliantShizhuang, 
	[ACT_ID.CJXB] = RemindName.ActivityBrilliantCJXunbao, 
	[ACT_ID.LJ] = RemindName.ActivityBrilliantLeiji, 
	[ACT_ID.CFCZ] = RemindName.ActivityBrilliantCfcharge, 
	[ACT_ID.BZ] = RemindName.ActivityBrilliantBaozan, 
	[ACT_ID.RXJJ] = RemindName.ActivityBrilliantRXJJ, 
	[ACT_ID.ZLJJ] = RemindName.ActivityBrilliantZLJJ, 
	[ACT_ID.JBJJ] = RemindName.ActivityBrilliantJBJJ, 
	[ACT_ID.CZGIFT] = RemindName.ActivityBrilliantChargeGF, 
	[ACT_ID.XFGIFT] = RemindName.ActivityBrilliantXiaofeiGF, 
	[ACT_ID.ZCJJ] = RemindName.ActivityBrilliantZCJJ, 
	[ACT_ID.HZJJ] = RemindName.ActivityBrilliantHZJJ, 
	[ACT_ID.BSJJ] = RemindName.ActivityBrilliantBSJJ, 
	[ACT_ID.CZRANK] = RemindName.ActivityBrilliantCZrank, 
	[ACT_ID.XF] = RemindName.ActivityBrilliantXFgift, 
	[ACT_ID.LKGIFT] = RemindName.ActivityBrilliantLCgift, 
	[ACT_ID.XFZP] = RemindName.ActivityBrilliantXFZhuanpan, 
	[ACT_ID.SHJJ] = RemindName.ActivityBrilliantSHJJ, 
	[ACT_ID.KHHD] = RemindName.ActivityBrilliantKHHD, 
	[ACT_ID.LXCZ2] = RemindName.ActivityBrilliantLXCZ2, 
	[ACT_ID.QMXF] = RemindName.ActivityBrilliantQmXiaofei, 
	[ACT_ID.XFHK] = RemindName.ActivityBrilliantXiaofeiHK,
	[ACT_ID.DEGREE] = RemindName.ActivityBrilliantDegree, 
	[ACT_ID.BOSS] = RemindName.ActivityBrilliantBoss, 
	[ACT_ID.EGG] = RemindName.ActivityBrilliantEgg,
	[ACT_ID.TSMB] = RemindName.ActivityBrilliantTSMB,
	[ACT_ID.JR] = RemindName.ActivityBrilliantJieri,
	[ACT_ID.DH] = RemindName.ActivityBrilliantDuihuan,
	[ACT_ID.GG] = RemindName.ActivityBrilliantGGAward,
	[ACT_ID.LXCZ] = RemindName.ActivityBrilliantLXcharge,
	[ACT_ID.FD] = RemindName.ActivityBrilliantCZfudai,
	--[ACT_ID.THLB] = RemindName.ActivityBrilliantTHlibao,
	[ACT_ID.LKDRAW] = RemindName.ActivityBrilliantLKDraw,
	[ACT_ID.DRAWFL] = RemindName.ActivityBrilliantDrawFL,
	[ACT_ID.DBCZ] = RemindName.ActivityBrilliantSingleCharge,
	[ACT_ID.THGIFT] = RemindName.ActivityBrilliantTHGift,
	[ACT_ID.PTTQ] = RemindName.ActivityBrilliantPTTQ,
	-- [ACT_ID.FLCZ] = RemindName.ActivityBrilliantFashionExplore,
	-- [ACT_ID.SBCZ] = RemindName.ActivityBrilliantDrawActivity,
	[ACT_ID.XFGIFTFT] = RemindName.ActivityBrilliantXFGIFTFT,
	[ACT_ID.CZZP] = RemindName.ActivityBrilliantCZZP,
	[ACT_ID.JQPD] = RemindName.ActivityBrilliantJQPD,
	[ACT_ID.XYC] = RemindName.ActivityBrilliantXYC,
	[ACT_ID.ZBG] = RemindName.ActivityBrilliantZBG,
	[ACT_ID.CBG] = RemindName.ActCanbaoge,
	[ACT_ID.JPDH] = RemindName.ActivityBrilliantJPDH,
	[ACT_ID.JDBS] = RemindName.ActivityBrilliantJDBS,
	-- [ACT_ID.CZLC] = RemindName.ActivityBrilliantCZLC,
	[ACT_ID.CSFS] = RemindName.ActivityBrilliantCSFS,
	[ACT_ID.XSCZ] = RemindName.ActivityBrilliantXSCZ,
	[ACT_ID.LXFL] = RemindName.ActivityBrilliantLXFL,
	[ACT_ID.XFZF] = RemindName.ActivityBrilliantXFZF,
	[ACT_ID.CZZF] = RemindName.ActivityBrilliantCZZF,
	-- [ACT_ID.XSZG] = RemindName.ActivityBrilliantXSZG,
	[ACT_ID.YSJD] = RemindName.ActivityBrilliantYSJD,
	[ACT_ID.ZPHL] = RemindName.ActivityBrilliantZPHL,
	[ACT_ID.XFJL] = RemindName.ActivityBrilliantXFJL,
	[ACT_ID.SLLB] = RemindName.ActivityBrilliantSLLB,
	[ACT_ID.LZMB] = RemindName.ActivityBrilliantLZMB,
	[ACT_ID.FHB] = RemindName.ActivityBrilliantFHB,
	[ACT_ID.GZP] = RemindName.ActivityBrilliantGZP,
	[ACT_ID.XYFP] = RemindName.ActivityBrillianXYFP,
	[ACT_ID.HHDL] = RemindName.ActivityBrillianHHDL,
	-- [ACT_ID.LCFL] = RemindName.ActivityBrillianLCFL,
	[ACT_ID.CZLC] = RemindName.ActivityBrillianCZLC,
	[ACT_ID.LCFD] = RemindName.ActivityBrillianLCFD,
	[ACT_ID.SVZP] = RemindName.ActivityBrillianSVZP,
	[ACT_ID.MSGIFT] = RemindName.ActivityBrilliantMsGift,
	[ACT_ID.MSGIFT] = RemindName.ActChagreBack,
	[ACT_ID.DLJS] = RemindName.ActivityBrillianDLJS,
}

ACT_LIST_BY_REMIND = {}
for act_id, remind_name in pairs(REMIND_ACT_LIST) do
	ACT_LIST_BY_REMIND[remind_name] = act_id
end
