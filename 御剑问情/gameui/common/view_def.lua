---------------------
--功能开始的名字是ViewName的小写，这样才能通过ViewName关联到对应的功能开启， 而标签的的功能开启要跟标签名字保持一致
--(已经这样设计了，就按照这样来命名)
------------------------
ViewName = {
	ArenaRankView = "ArenaRewardView",				-- 竞技场统计
	TipsEnterArenaView = "TipsEnterArenaView",		-- 竞技场tips
	ArenaActivityView = "ArenaActivityView",		-- 竞技场主面板
	Agent = "Agent",								-- 登陆SDK
	BagRecycle = "BagRecycle",						-- 装备回收，精灵回收
	-- Compose = "Compose",							-- 炼炉
	Login = "Login",								-- 登录
	Main = "Main",									-- 主界面
	MainUIResIconList = "MainUIResIconList",		-- 主界面图标列表
	AttackMode = "AttackMode",						-- 攻击模式界面
	Chat = "Chat",									-- 聊天面板
	NearPeopleView = "MainUINearPeopleView",		-- 附近的人
	VoiceSetting = "VoiceSetting",					-- 语音设置
	CoolChat = "CoolChat",							-- 炫酷聊天面板
	TaskDialog = "TaskDialog",						-- 任务对话框
	Player = "Player",								-- 角色面板
	Market = "Market",								-- 市场
	Forge = "Forge",								-- 锻造
	EquipmentShen = "EquipmentShen",				-- 神装
	Boss = "Boss",									-- BOSS
	Symbol = "Symbol",								-- 五行之灵
	ShenYinView = "ShenYinView",					-- 神印
	ShenYinQiangHuaAttrView = "ShenYinQiangHuaAttrView", --神印强化属性界面
	TianXiangGroupAttrView = "TianXiangGroupAttrView",		        --天象换珠界面
	ShenYinTianXiangAttrView = "ShenYinTianXiangAttrView",		   	--天象总属性
	ShenYinQuickFlushView = "ShenYinQuickFlushView",--神印一键召印
	MarryGift = "MarryGift",						-- 情缘礼包
	TipsPowerChangeView = "TipsPowerChangeView",	-- 战斗力变化
	Warehouse = "Warehouse",						-- 仓库面板
	BaoJu = "BaoJu",								-- 宝具面板
	ZhiBaoHuanhua = "ZhiBaoHuanhua",				-- 至宝幻化面板
	Advance = "Advance",							-- 进阶面板
	ClearBlessTipView = "ClearBlessTipView",		-- 进阶幸运值清空提示界面
	FullServerSnapView = "FullServerSnapView", 	-- 合服活动--全服抢购
	CombineServerBossView = "CombineServerBossView",	-- 合服boss
	-- AdvanceEquipUp = "AdvanceEquipUp",			-- 进阶装备升级面板
	MountHuanHua = "MountHuanHua",					-- 幻化面板
	WingHuanHua = "WingHuanHua",					-- 羽翼幻化面板
	HaloHuanHua = "HaloHuanHua",					-- 光环幻化面板
	ShengongHuanHua = "ShengongHuanHua",			-- 神弓幻化面板
	ShenyiHuanHua = "ShenyiHuanHua",				-- 神翼幻化面板
	FootHuanHua = "FootHuanHua",					-- 足迹幻化面板
	FightMountHuanHua = "FightMountHuanHua",		-- 战斗坐骑幻化面板
	WaistHuanHua = "WaistHuanHua",					-- 腰饰幻化面板
	TouShiHuanHua = "TouShiHuanHua",				-- 头饰幻化面板
	QilinBiHuanHua = "QilinBiHuanHua",				-- 麒麟臂幻化面板
	MaskHuanHua = "MaskHuanHuaView",				-- 面饰幻化
	LingChongHuanHua = "LingChongHuanHua",			-- 灵宠幻化面板
	ImageFuLing = "ImageFuLing",					-- 形象附灵
	Goddess = "Goddess",							-- 女神面板
	GoddessHuanHua = "GoddessHuanHua",				-- 女神幻化面板
	GoddessSpecialTipView = "GoddessSpecialTipView",-- 特殊伙伴界面
	Answer = "Answer",								-- 答题面板
	Guild = "Guild",								-- 公会面板
	GuildRedPacket = "GuildRedPacket",				-- 公会红包
	Welfare = "Welfare",							-- 福利面板
	SpiritGetSkillView = "SpiritGetSkillView",		-- 精灵技能获取面板
	SpiritGetSkillView = "SpiritGetSkillView",		-- 精灵技能获取面板
	SpiritSpecialView = "SpiritSpecialView",        -- 特殊宠物
	OffLineExp = "OffLineExp",						-- 离线经验面板
	OnLineReward = "OnLineReward",					-- 在线奖励面板
	TipChengZhang = "TipChengZhang",				-- 坐骑成长丹tip
	TipZiZhi = "TipZiZhi",							-- 坐骑资质丹tip
	TipSkillUpgrade = "TipSkillUpgrade",			-- 进阶技能tip
	Ranking = "RankingView",						-- 排行榜面板
	FuBen = "FuBen",								-- 副本面板
	Scoiety = "Scoiety",							-- 社交面板
	FriendRec = "FriendRec",						-- 好友推荐面板
	CheckEquip = "CheckView",						-- 查看面板
	NearTeamView = "NearTeamView",					-- 附近队伍
	XianzunkaView = "XianzunkaView",				-- 仙尊卡
	XianzunkaDecView = "XianzunkaDecView",			-- 仙尊卡详情
	InviteView = "InviteView",						-- 邀请
	Shenqi = "Shenqi", 								-- 神器
	BlackView = "BlackView",						-- 黑名单
	FriendListView = "FriendListView",				-- 好友列表
	GiftRecord = "GiftRecord",						-- 收礼记录
	FriendDeleteView = "FriendDeleteView",			-- 批量删除好友
	CityCombatFirstView = "CityCombatFirstView",	-- 第一次开攻城战
	HeFuCombatFirstView = "HeFuCombatFirstView", 	-- 合服第一次攻城战
	GuildFirstView = "GuildFirstView",				-- 第一次工会争霸
	ApplyView = "ApplyView",						-- 请求列表
	OperateList = "OperateList",					-- 玩家操作列表
	Compose = "ComposeView",						-- 合成面板
	DuihuanView = "DuihuanView",					-- 形象兑换商店
	NewSelectEquipView = "NewSelectEquipView",		-- 选择装备界面(新)
	Activity = "Activity",							-- 活动总面板
	ActivityDetail = "ActivityDetail",				-- 活动详情面板
	GuildFight = "GuildFight",						-- 公会争霸面板
	DaFuHao = "DaFuHao",							-- 富豪转盘面板
	DaFuHaoRoll = "DaFuHaoRoll",					-- 大富豪转盘
	Exchange = "NewExchangeView",					-- 兑换面板
	ExchangeViewBuyTips = "BuyTipsView",			-- 商店购买tips
	FBInfoView = "FBInfoView",						-- 副本信息面板
	FBFinishStarView = "FBFinishStarView",			-- 副本星级胜利
	FBVictoryFinishView = "FBVictoryFinishView",	-- 副本胜利结束面板
	FBFailFinishView = "FBFailFinishView",			-- 副本失败结束面板
	RedTaoZhuangView = "RedTaoZhuangView", 			-- 红装收集
	Shop = "ShopView",								-- 商城面板
	Setting = "SettingView",						-- 设置面板
	Unlock = "UnlockView",							-- 锁屏面板
	Treasure = "Treasure",							-- 寻宝面板
	TreasureReward = "TreasureReward",				-- 寻宝奖励面板
	TradeView = "TradeView",						-- 交易面板
	Map = "Map",									-- 地图面板
	Marriage = "Marriage",							-- 结婚面板
	MarryBaby = "MarryBaby",						-- 结婚宝宝面板
	SuperBaoBaoView = "SuperBaoBaoView",			-- 超级宝宝界面
	WeddingTipsOne = "WeddingTipsOne",				-- 温馨婚礼提示面板
	WeddingTipsTwo = "WeddingTipsTwo",              -- 喜庆婚礼提示面板
	WeddingTipsThree = "WeddingTipsThree",          -- 豪华婚礼提示面板
	MarriageWedding = "MarriageWeddingView",		-- 婚宴面板
	LoveContract = "MarriageLoveContractView",		-- 结婚契约
	LittlePetView = "LittlePetView",							-- 小宠物
	LittlePetHandleBookView = "LittlePetHandleBookView",		-- 小宠物图鉴面板
	LittlePetHomePackageView = "LittlePetHomePackageView",		-- 小宠物家园背包面板
	LittlePetHomeRecycleView = "LittlePetHomeRecycleView",		-- 小宠物家园回收面板
	LittlePetWarehouseView = "LittlePetWarehouseView",			-- 小宠物仓库
	LittlPetPropTipView = "LittlPetPropTipView",				-- 小宠物商店提示框
	LittlePetToyBagView = "LittlePetToyBagView",				-- 小宠物玩具背包
	LittlePetRecycleSelectView = "LittlePetRecycleSelectView",	-- 小宠物回收筛选面板
	LittlePetSpecialItemTips = "LittlePetSpecialItemTips",		-- 超级小宠物提示框
	ClothespressView = "ClothespressView",			-- 衣橱
	SuitAttrTipView = "SuitAttrTipView",			-- 衣橱套装属性面板
	LoveContractFrame = "GetLoveContractView",      -- 爱情契约弹出面板
	WeddingHunShuView = "WeddingHunShuView",		-- 求婚按手印面板
	HuanyanQuestion = "HuanyanQuestion",			-- 婚宴答题
	WeddingYuYueView = "WeddingYuYueView",			-- 婚宴预约面板
	WeddingDemandView = "WeddingDemandView",		-- 进入婚宴面板
	MonomerListView = "MonomerListView",			-- 我要脱单面板
	WeddingEnterView = "WeddingEnterView",			-- 婚宴进入面板
	WeddingInviteView = "WeddingInviteView",		-- 婚宴邀请面板
	MarryEquipSuitView = "MarryEquipSuitView",		-- 夫妻装备(情饰)珍藏面板
	ReclyeInfoView = "MarryEquipReclyeInfoView",	-- 夫妻装备(情饰)回收面板
	Church = "Church",								-- 教堂面板
	Wedding = "Wedding",							-- 求婚面板
	ReviveView = "ReviveView",						-- 复活面板
	CommonTips = "CommonTips",						-- 公共提示
	KuaFuFuBenView = "KuaFuFuBenView",				-- 跨服副本面板
	FuBenPhaseInfoView = "FuBenPhaseInfoView",		-- 进阶副本信息面板
	FuBenExpInfoView = "FuBenExpInfoView",			-- 经验副本信息面板
	FuBenInfoYaoShouView = "FuBenInfoYaoShouView",   -- 组队副本妖兽祭坛信息面板
	FuBenStoryInfoView = "FuBenStoryInfoView",		-- 剧情副本信息面板
	FuBenVipInfoView = "FuBenVipInfoView",			-- VIP副本信息面板
	FuBenTowerInfoView = "FuBenTowerInfoView",		-- 爬塔副本信息面板
	FuBenHunYanInfoView = "FuBenHunYanInfoView",	-- 婚宴副本信息面板
	FuBenQingYuanInfoView = "FuBenQingYuanInfoView",-- 情缘副本信息面板
	FuBenGuardInfoView = "FuBenGuardInfoView",		-- 个人塔防副本信息面板
	FuBenQualityInfoView = "FuBenQualityInfoView",	-- 品质副本信息面板
	FuBenPushInfoView = "FuBenPushInfoView",		-- 推图副本信息面板
	FuBenTeamSpecialInfoView = "FuBenTeamSpecialInfoView",--组队副本(须臾幻境)信息面板
	SpiritView = "SpiritView",						-- 精灵面板
	SpiritHuanHuaView = "SpiritHuanHuaView",		-- 精灵幻化面板
	VipView = "VipView",							-- Vip面板
	KuaFu1v1 = "KuaFu1v1",							-- 跨服1v1
	GoPawnView = "GoPawnView",						-- 幻境寻宝
	HelperView = "HelperView",						-- 小助手
	YunbiaoView = "YunbiaoView",					-- 护送面板
	KuaFuXiuLuoTowerView = "KuaFuXiuLuoTowerView",	-- 跨服修罗塔
	FuXiuLuoTowerBuffView = "FuXiuLuoTowerBuffView",-- 跨服修罗塔buff界面
	SkyMoneyView = "SkyMoneyView",					-- 天降财宝面板
	SkyMoneyFBInfoView = "SkyMoneyFBInfoView",		-- 天将财宝副本信息面板
	Flowers = "Flowers",							-- 送花界面
	BackFlowers = "BackFlowers",					-- 被送花界面
	SkyMoneyRewardView = "SkyMoneyRewardView",		-- 天降财宝结算面板
	KaifuActivityView = "KaifuActivityView",		-- 开服活动面板
	LeiJiRechargeView = "LeiJiRechargeView",		-- 累积充值面板
	RechargeRank = "RechargeRank",					-- 充值排行面板
	ConsumeRank = "ConsumeRank",                    -- 消费排行面板
	LimitedFeedbackView = "LimitedFeedbackView",			-- 充值排行面板
	JuHuaSuan = "JuHuaSuan",						-- 聚划算
	FastCharging = "FastCharging",					-- 急速充战
	ConsumeDiscountView = "ConsumeDiscountView",	-- 连消特惠
	TreasureBowlView = "TreasureBowlView",			-- 聚宝盘
	LoginGift7View = "LoginGift7View",				-- 登录7天送礼
	TipsSpeakerView = "TipsSpeakerView",			-- 喇叭
	DailyChargeView = "DailyChargeView",			-- 每日首充
	RebateView = "RebateView",						-- 百倍返利
	InvestView = "InvestView",						-- 投资计划
	TombExploreView = "TombExploreView",			-- 皇陵探险
	TombExploreFBView = "TombExploreFBView",		-- 皇陵探险副本信息
	ClashTerritory = "ClashTerritory",				-- 领土战
	ClashTerritoryInfo = "ClashTerritoryInfo",		-- 领土战信息面板
	ClashTerritoryShop = "ClashTerritoryShop",		-- 领土战商店面板
	ElementBattleFightView = "ElementBattleFightView",		-- 元素战场信息面板
	DabaoBossInfoView = "DabaoBossInfoView",		-- 打宝秘境信息面板
	ActiveBossInfoView = "ActiveBossInfoView",		-- 活跃秘境信息面板
	BossFamilyInfoView = "BossFamilyInfoView",		-- boss之家信息面板
	SecretBossFightView = "SecretBossFightView",    -- 密藏boss信息面板
	BabyBossFightView = "BabyBossFightView",		-- 宝宝boss信息面板
	CityCombatView = "CityCombatView",				-- 攻城战
	CityCombatFBView = "CityCombatFBView",			-- 攻城战副本信息
	CityReward = "CityReward",						-- 攻城战副本信息
	CityCombatVictoryView = "CityCombatVictoryView",	-- 攻城战胜利面板
	GuildMijingFightView = "GuildMijingFightView",	-- 行会秘境
	CrossCrystalInfoView = "CrossCrystalInfoView",	-- 跨服水晶信息面板
	FirstChargeView = "FirstChargeView",			-- 首充
	SecondChargeView = "SecondChargeView",       	-- 二充
	LeiJiDailyView = "LeiJiDailyView",				-- 每日累充
	DailyTaskFb = "DailyTaskFb",					-- 日常任务副本
	OpenFirstcharge = "open_firstcharge",			-- 首次打开首充
	FbIconView = "FbIconView",						-- 副本图标界面
	QuickSell = "QuickSell",						-- 快速出售
	Mojie = "Mojie",								-- 魔戒
	MojieGift = "MojieGift",						-- 魔戒礼包
	MoLong = "MoLong",								-- 魔龙
	AncientRelics = "AncientRelics",				-- 上古遗迹
	PuzzleView = "PuzzleView",						-- 寻字好礼
	FastFlipView = "FastFlipView",					-- 一键寻字
	LoadingTips = "LoadingTips",					-- 加载提示
	MagicWeaponView = "MagicWeaponView",			-- 魔器面板
	HuashenImageView = "HuashenImageView",			-- 化神形象面板z
	PetView = "PetView",							-- 宠物
	XianzunkaView = "XianzunkaView",				-- 仙尊卡
	XianzunkaDecView = "XianzunkaDecView",			-- 仙尊卡详情
	TianshenhutiView = "TianshenhutiView",			-- 无双装备
	TianshenhutiEquipTips = "TianshenhutiEquipTips",			-- 无双装备tips
	TipTianshenhutiBoxShowView = "TipTianshenhutiBoxShowView",	-- 无双装备抽奖展示tips
	TianshenhutiSelectSlotView = "TianshenhutiSelectSlotView",	-- 无双装备选择部位
	TianshenhutiOnekeyComposeView = "TianshenhutiOnekeyComposeView",	-- 无双装备一键合成
	TianshenhutiAttrView = "TianshenhutiAttrView",	-- 无双装备属性界面
	TianShenHuTiSkillView = "TianShenHuTiSkillView",			--无双装备技能预览
	Reincarnation = "Reincarnation",				-- 转生
	HpBag = "HpBag",								-- 血包
	SpiritFazhenHuanHuaView = "SpiritFazhenHuanHuaView", --精灵法阵幻化
	SpiritHaloHuanHuaView = "SpiritHaloHuanHuaView", --精灵光环幻化
	FunOpenVictoryView = "FunOpenVictoryView",		-- 功能开启副本胜利面板
	MountFuBenView = "MountFuBenView",				-- 功能开启坐骑面板
	WingFuBenView = "WingFuBenView",				-- 功能开启羽翼面板
	JingLingFuBenView = "JingLingFuBenView",		-- 功能开启精灵面板
	TipsRenameView = "TipsRenameView",				-- 改名面板
	GuildBoss = "GuildBossView",					-- 公会BOSS
	GuildApply = "GuildApplyView",					-- 公会招人面板
	BuffPandectTips = "BuffPandectTips",			-- buff总览
	ChatGuild = "ChatGuild",						-- 公会聊天面板
	MolongMibaoView = "MolongMibaoView",			-- 魔龙秘宝
	TipsGuildTransfer = "TipsGuildTransfer",		-- 公会成员职位任命面板
	PlayerFashionHuanhua = "PlayerFashionHuanhua",	-- 角色时装进阶(幻化)面版
	PlayerTitleHuanhua = "PlayerTitleHuanhua",		-- 角色称号进阶（幻化）面板
	WelcomeView = "WelcomeView",					-- 新手欢迎面板
	TipsPetBag = "TipsPetBag",						-- 寻宝抽奖面板（宠物背包）
	TempMount = "tempmount",						-- 临时坐骑
	TempWing = "tempwing",							-- 临时形象
	TipShop = "TipShop",							-- 商城购买Tip
	FBWingStoryView = "FBWingStoryFb",				-- 羽翼剧情副本
	StoryView = "StoryView",						-- 剧情
	StoryEntranceView = "StoryEntranceView",		-- 剧情入口面板
	LineView = "LineView",							-- 分线面板
	ExchangeTip = "ExchangeTip",					-- 兑换Tip
	MarryMe = "MarryMe",							-- 我们结婚吧
	MarryNpcMe = "MarryNpcMe",						-- 月老面板
	ActiviteHongBao = "ActiviteHongBao",			-- 开服红包
	ExpRefine = "ExpRefine",						-- 经验炼制
	BuyExp = "BuyExp",								-- 经验购买
	DisCount = "DisCount",							-- 特惠豪礼
	GoldMemberView = "gold_member",					-- 黄金会员
	GoldMemberShop = "gold_member_shop",			-- 黄金会员商店
	CompetitionActivity = "CompetitionActivity",	-- 比拼活动
	MainUIIconList = "MainUIIconList",				-- 精彩活动选择列表
	MainUIGoddessSkillTip = "MainUIGoddessSkillTip",-- 主界面女神技能提示面板
	TreasureRewardShow = "TreasureRewardShow",		-- 寻宝展示
	PersonalGoals = "PersonalGoals",				-- 个人目标
	PersonalTips = "PersonalTips",					-- 个人挂机tips
	CollectGoals = "CollectGoals",					-- 集体目标
	Rune = "Rune",									-- 符文系统
	RuneBag = "RuneBag",							-- 符文背包
	RuneAwakenView = "RuneAwakenView", 				-- 符文觉醒
	RuneAwakenTipsView = "RuneAwakenTipsView",		-- 符文觉醒tips
	RuneItemTips = "RuneItemTips",					-- 符文tips
	RuneTowerView = "RuneTowerView",				-- 符文塔
	RuneTowerFbInfoView = "RuneTowerFbInfoView",	-- 符文塔副本信息
	RuneTowerOfflineInfoView = "RuneTowerOfflineInfoView", -- 符文塔离线挂机信息面板
	SpecialRuneItemTips = "SpecialRuneItemTips",	-- 特殊符文面板
	RunePreview = "RunePreview", 					-- 符文总览面板
	SceneLoading = "SceneLoading",					-- 场景加载
	RandSystem = "RandSystem",						-- 随机系统公告
	AppearanceView = "AppearanceView",				-- 外观
	GodTempleView = "GodTempleView",				-- 封神殿
	GodTempleActiveTipView = "GodTempleActiveTipView",	-- 封神殿-激活界面
	GodTempleRankView = "GodTempleRankView",		-- 封神殿-排行榜
	GodTempleInfoView = "GodTempleInfoView",		-- 封神殿-场景界面
	LianhunView = "LianhunView",					-- 炼魂
	ShenGeView = "ShenGeView",						-- 神格面板
	ShenGeComposeView = "ShenGeComposeView",		-- 神格合成
	ShenGeSelectView = "ShenGeSelectView",			-- 神格选择
	ShenGeOperateView = "ShenGeOperateView",		-- 神格操作面板
	ShenGeAttrView = "ShenGeAttrView",				-- 神格属性预览面板
	ShenGePreview = "ShenGePreview", 				-- 神格总览面板
	ShenGeUpgradeView = "ShenGeUpgradeView",		-- 神格升级面板
	ShenGeDecomposeView = "ShenGeDecomposeView",	-- 神格分解面板
	ShenGeItemTips = "ShenGeItemTips",				-- 神格tips
	ShenGeDecomposeDetailView = "ShenGeDecomposeDetailView",		-- 神格分解详情面板
	WaBao = "WaBao",									-- 挖宝
	ShenGePropTipView = "ShenGePropTipView",			-- 神格祈福道具预览
	HunQiSkillTips = "HunQiSkillTips",				-- 魂器技能描述界面
	ShengXiaoSkillView = "ShengXiaoSkillView",		-- 生肖技能
	GuildHeJiuView = "GuildHeJiuView",				-- 仙盟喝酒
	JinJieRewardView = "JinJieRewardView",			-- 进阶奖励界面

	MiJiComposeView = "MiJiComposeView",			-- 星座秘籍合成   （暂用）
	MiJiSelectView = "MiJiSelectView",				-- 星座秘籍选择界面

	CardView = "CardView",							-- 卡牌
	Touxian = "Touxian",							-- 头衔

	DaMoExChangeTips = "DaMoExChangeTips",			-- 打磨经验兑换tips
	ShengXiaoBagView = "ShengXiaoBagView",			-- 生肖背包
	ShengXiaoMijiView = "ShengXiaoMijiView",		-- 生肖秘籍
	MijiBagView = "MijiBagView",					-- 秘籍背包
	AllMijiView = "AllMijiView",					-- 秘籍总览
	HunQiView = "HunQiView",						-- 魂器面板
	HunYinSuitView = "HunYinSuitView",				-- 魂印套装面板
	HunYinResolve = "HunYinResolve",				-- 魂印分解
	HunYinExchangView = "HunYinExchangView",		-- 魂印兑换
	HunYinAllView = "HunYinAllView",				-- 魂印总览面板
	HunYinReplaceTipsView = "HunYinReplaceTipsView",-- 魂印替换tips
	HunYinInlayTips = "HunYinInlayTips",			-- 魂印镶嵌tips
	GatherSoulView = "GatherSoulView",				-- 聚魂面板
	FreeGiftView = "FreeGiftView",					-- 0元礼包活动
	ShengXiaoView = "ShengXiaoView",				-- 生肖面板
	SoulAllAttrView = "SoulAllAttrView",			-- 聚魂总属性面板
	AdvanceEquipView = "AdvanceEquipView",			-- 进阶装备
	GoldHuntView = "GoldHuntView", 					--黄金猎场
	HuntQuickView = "HuntQuickView",				--黄金猎场快速刷新面板
	TipsCommonExplainView = "TipsCommonExplainView",		-- 提示说明面板
	PreferredSizeAttrView = "PreferredSizeAttrView",		-- 自适应属性总览面板
	AdvanceEquipSkillView = "AdvanceEquipSkillView",		-- 进阶装备技能面板
	YewaiGuajiView = "YewaiGuajiView",
	SpiritExploreView = "SpiritExploreView", 		-- 精灵家园
	SpiritExpRewardView = "SpiritExpRewardView", 	-- 精灵探险开箱界面
	SpiritExpFightView = "SpiritExpFightView", 		-- 精灵探险战斗界面
	SpiritChooseModelView = "SpiritChooseModelView",-- 精灵探险选择难度界面
	SpiritHomeFightView = "SpiritHomeFightView",	-- 精灵家园战斗界面
	SpiritHomeRevengeView = "SpiritHomeRevengeView",-- 精灵家园复仇界面
	SpiritExploreVictory = "SpiritExploreVictory",  -- 精灵探险胜利界面
	SpiritExploreLose = "SpiritExploreLose", 		-- 精灵探险失败界面
	SoulHandBook="SoulHandBookView",  			--精灵图鉴
	SoulQuickFlushView="SoulQuickFlushView",		-- 精灵自动改命界面
	HunQiXiLianStuffView = "HunQiXiLianStuffView",	-- 魂印洗练材料界面
	YiZhanDaoDiView="YiZhanDaoDiView",  			-- 一战到底
	ShenShou="ShenShou",  							-- 神兽
	ShenShouBag="ShenShouBag",  					-- 神兽背包
	ShenShouSelectEquip = "ShenShouSelectEquip",    -- 神兽装备
	FulingSelectMaterialView = "FulingSelectMaterialView",	-- 神兽装备强化材料选择界面
	FulingTips = "FulingTips",						-- 神兽装备强化提示框
	YuLeView="YuLeView",  							-- 娱乐
	FishPondListView="FishPondListView",  			-- 鱼池玩家列表界面
	YangFishView="YangFishView",  					-- 养鱼界面
	FishingView = "FishingView",					-- 钓鱼面板
	BeStealRecordView="BeStealRecordView",  		-- 鱼被偷记录
	HarvestRecordView="HarvestRecordView",  		-- 收获记录
	WorldQuestionView = "WorldQuestionView",		--世界答题
	ActivityHall = "ActivityHall",					--活动卷轴
	RuneTowerUnlockView = "RuneTowerUnlockView",	--符文塔解锁界面
	RollingBarrageView = "RollingBarrageView",			-- 滚动弹幕界面
	KillRoleView = "KillRoleView",					-- 斩杀人物面板
	LuckyChessView = "LuckyChessView",				-- 幸运棋
	TimeLimitSaleView = "TimeLimitSaleView", 		--限时活动
	CloakHuanHua = "CloakHuanHua",					-- 披风
	KuaFuBattle = "KuaFuBattle",					-- 跨服六界
	KuaFuLiuJiePre = "KuaFuLiuJiePre",				-- 跨服六界预告
	KuaFuFightView = "KuaFuFightView",				-- 跨服六界争霸
	KuafuTaskView = "KuafuTaskView",				-- 跨服六界争霸任务
	KuaFuRecordView = "KuaFuRecordView",			-- 跨服六界争霸记录
	DailyTaskView = "DailyTaskView",
	KuaFuBossSwFightView = "KuaFuBossSwFightView",	--跨服神武Boss信息面板
	KuaFuBossTjFightView = "KuaFuBossTjFightView",	--跨服天将Boss信息面板
	LuckyLogView = "LuckyLogView",					--通用日志
	SecretrShopView = "SecretrShopView",				-- 臻品城/神秘商店
	FestivalequipmentInfoView = "FestivalequipmentInfoView", -- 节日套装
	DailyGiftView = "DailyGiftView",
	KuaFuTuanZhanTaskView = "KuaFuTuanZhanTaskView",		-- 跨服团战任务界面
	KuaFuTuanZhanRankView = "KuaFuTuanZhanRankView",		-- 跨服团战排行榜界面
	KuaFuTuanZhanRewardView = "KuaFuTuanZhanRewardView",	-- 跨服团战排行奖励界面
	KuaFuTuanZhanMapView = "KuaFuTuanZhanMapView", 			-- 跨服团战小地图

	-- 提示框
	TipsPropView = "TipsPropView",					-- 道具提示TIP
	TipsEquipView = "TipsEquipView",				-- 装备TIP
	TipsMojieView = "TipsMojieView",				-- 魔戒装备TIP
	TipsOtherEquipView = "TipsOtherEquipView",		-- 其他装备TIP
	TipsShowProView = "TipsShowProView",			-- 聊天背包TIP
	TipsZhiBaoSkillView = "TipsZhiBaoSkillView",	-- 功勋技能TIP
	TipsItemGetWayView = "TipsItemGetWayView",		-- 道具不足物品提示TIP
	--仙宠专用提示
	ItemSpritSkill = "ItemSpritSkill",
	TipsMijiGetWayView = "TipsMijiGetWayView",		-- 生肖秘籍不足提示TIP
	TipsExpressView = "TipsExpressView",			-- 表情TIP
	TipsPortraitView = "TipsPortraitView",			-- 更换头像TIP
	TipsOtherPortraitView = "TipsOtherPortraitView",-- 查看头像TIP
	TipsCommonBuyView = "TipsCommonBuyView",		-- 快速购买TIP
	TipsCommonAutoView = "TipsCommonAutoView",		-- 自动购买TIP
	TipsInviteView = "TipsInviteView",				-- 邀请TIP
	TipsAddFriendView = "TipsAddFriendView",		-- 添加好友TIP
	TipsCommonInputView = "TipsCommonInputView",	-- 数字输入TIP
	TipExchangeView = "TipExchangeView",			-- 兑换TIP
	TipsRewardView = "TipsRewardView",				-- 奖励TIP
	TipsStarRewardView = "TipsStarRewardView",				-- 奖励TIP2
	TipsGetNewitemView = "TipsGetNewitemView",		-- 获得新物品TIP
	TipsLackDiamondView = "TipsLackDiamondView",	-- 钻石不足TIP
	TipsLockVipView = "TipsLockVipView",			-- Vip不足TIP
	TipsLackJiFenView = "TipsLackJiFenView",		-- 积分不足TIP(金猪召唤/龙神夺宝)
	TipsCommonTwoOptionView = "TipsCommonTwoOptionView",	--
	TipsCommonOneOptionView = "TipsCommonOneOptionView",	--
	TipsCommonPlaneTipsView = "TipsCommonPlaneTipsView",	--
	TipsRingInfoView = "TipsRingInfoView",		--
	TipsHelpView = "TipsHelpView",		--
	TipsAttrView = "TipsAttrView",		--
	TipsAttrAllView = "TipsAttrAllView",		--
	TipsTotalAttrView = "TipsTotalAttrView",		--
	HappyTreeExchangeView = "HappyTreeExchangeView",		--
	TipsSpiritEquipView = "TipsSpiritEquipView",		--
	TipsSpiritShangZhenView = "TipsSpiritShangZhenView",	--
	TipsSpiritZhenFaValueView = "TipsSpiritZhenFaValueView", --
	TipsSpiritZhenFaPromoteView = "TipsSpiritZhenFaPromoteView", --
	TipOpenFunctionView = "TipOpenFunctionView",		--
	TipsChosenFlowerView = "TipsChosenFlowerView",		--
	TipsMissionCompletedView = "TipsMissionCompletedView",		--
	TisDailySelectItemView = "TisDailySelectItemView",		--
	TipsSpiritSoulView = "TipsSpiritSoulView",		--
	TipsSpiritDressSoulView = "TipsSpiritDressSoulView",		--
	TipsMagicItemView = "TipsMagicItemView",		--
	TipsMCAttrView = "TipsMCAttrView",		--
	TipsMCAllAttrView = "TipsMCAllAttrView",		--
	TipsMCView = "TipsMCView",		--
	TipsPetAttributeView = "TipsPetAttributeView",		--
	TipsShowPetView = "TipsShowPetView",		--
	TipsShortCutEquipView = "TipsShortCutEquipView",		--
	TipsPetForgeView = "TipsPetForgeView",		--
	TipsPetReplaceView = "TipsPetReplaceView",		--
	TipsPetYouShanView = "TipsPetYouShanView",		--
	TipsPetExchangeView = "TipsPetExchangeView",		--
	TipPetExchangeBuyView = "TipPetExchangeBuyView",		--
	TipsDisplayPropModleView = "TipsDisplayPropModleView",		--
	TipsOtherRoleEquipView = "TipsOtherRoleEquipView",		--
	TipOpenFunctionFlyView = "TipOpenFunctionFlyView",		--
	TipsAchievementView = "TipsAchievementView",		--
	TipsOtherHelpView = "TipsOtherHelpView",			--
	TipsFashionAttr = "TipsFashionAttr",	--
	TipsWorldLevel = "TipsWorldLevel",	--
	TipSkillView = "TipSkillView",		--
	TipsSpiritSoulChangeView = "TipsSpiritSoulChangeView",		--
	TipsQuickUsePropView = "TipsQuickUsePropView",		--
	TipsTaskRewardView = "TipsTaskRewardView",		--
	TipsTaskRewardRollView = "TipsTaskRewardRollView",		--任务转盘
	TipsReminding = "TipsReminding",		--
	TipsBossInfoView = "TipsBossInfoView",		--
	TipsOtherEquipCompareView = "TipsOtherEquipCompareView",		--
	TipsStandbyMaskView = "TipsStandbyMaskView",		--
	TipsActivityRewardView = "TipsActivityRewardView",		--
	TipsOpenTrailerView = "TipsOpenTrailerView",		--
	TipsDayOpenTrailerView = "TipsDayOpenTrailerView",		--
	TipsKillBossView = "TipsKillBossView",		--
	TipsFocusBossView = "TipsFocusBossView",		--
	TipsFocusTeamFbFullView = "TipsFocusTeamFbFullView",		--
	TipsFocusBossOtherView = "TipsFocusBossOtherView",		--挂机boss和仙缘boss
	TipsFocusXingZuoYiJiView = "TipsFocusXingZuoYiJiView",		--星座遺跡提醒面板
	TipsFocusJingHuaHuSongView = "TipsFocusJingHuaHuSongView",	--精华护送提醒弹窗
	TipsFocusBossEncounterView = "TipsFocusBossEncounterView",	--奇遇boss提醒弹框
	TipsBetterEquipView = "TipsBetterEquipView",		--
	TipsFirstChargeView = "TipsFirstChargeView",		--
	TipsExpFuBenView = "TipsExpFuBenView",			--
	TipsExpInSprieFuBenView = "TipsExpInSprieFuBenView",		--
	PreRewardView = "PreRewardView",  		   				--
	TipNewSystemNoticeView = "TipNewSystemNoticeView",		--
	CheckEquipView = "CheckEquipView",
	TipsDisconnectedView = "TipsDisconnectedView", 			--断线重连
	TipWarmView = "TipWarmView", -- 温馨提示
	TipPaTaView = "TipPaTaView", -- 爬塔
	TipPaTaRewardView = "TipPaTaRewardView", -- 爬塔
	FuBenFinishStarNextView = "FuBenFinishStarNextView", -- 爬塔
	TipGuildRewardView = "TipGuildRewardViFew", 			-- 公会宝箱奖励
	TipsEnterFbView = "TipsEnterFbView", 	   				-- 进入副本
	TipsShowSkillView = "TipsShowSkillView",  				--技能tips2
	TipsBiPingView = "TipsBiPingView",  --
	TipWaBaoView = "TipWaBaoView",  		   				--挖宝tips
	BossSkillWarning = "BossSkillWarning",  		  		--boss技能警告
	ErnieView = "ErnieView",  		   						--摇奖机
	JuBaoPen = "JuBaoPen",  		   						--聚宝盆
	TipsSpiritAptitudeView="TipsSpiritAptitudeView",
	TipsSpiritInviteView = "TipsSpiritInviteView", 			--精灵探险PK邀请框
	TipsSpiritHomeSendView = "TipsSpiritHomeSendView", 		--精灵家园选择精灵框
	TipsSpiritHomeHarvestView = "TipsSpiritHomeHarvestView",--精灵家园收获框
	TipsSpiritHomePreviewView = "TipsSpiritHomePreviewView",--精灵家园收获预览
	TipsSpiritHomeConfirmView = "TipsSpiritHomeConfirmView",--精灵家园掠夺确认
	TipsEneterCommonSceneView = "TipsEneterCommonSceneView",-- 进入普通场景提示
	TipsCompleteChapterView = "TipsCompleteChapterView",	-- 完成章节任务提示
	TipsSpiritExpBuyBuffView = "TipsSpiritExpBuyBuffView",  -- 精灵探险购买BUFF
	TowerRewardInfoShowTips = "TowerRewardInfoShowTips",		-- 爬塔解锁提示
	TipsRecordView = "TipsRecordView",						--跨服修罗塔掉落日志
	TipsLiuJieLogView = "TipsLiuJieLogView",				--跨服六届掉落日志
	TipsMyRank = "TipsMyRank",								--登入前十提示
	TipsMoneyTreeRewardView = "TipsMoneyTreeRewardView",
	TimeLimitTitleView = "TimeLimitTitleView",

	TreasureLoftView = "TreasureLoftView",					--珍宝阁
	IncreaseSuperiorView = "IncreaseSuperiorView",			--单充回馈
	IncreaseCapabilityView = "IncreaseCapabilityView",		--单充豪礼
	FanFanZhuanView = "FanFanZhuanView",					--翻翻转
	RepeatRechargeView = "RepeatRechargeView",				--循环充值
	SingleRechargeView = "SingleRechargeView",				--单返豪礼
	MarryNoticeView = "MarryNoticeView",					--结婚通知
	TipWorldQuestionView = "TipWorldQuestionView",          --世界答题
	GoddessSearchAuraView="GoddessSearchAuraView",			--女神觅灵
	TipsCongratulationView = "TipsCongratulationView",		--好友贺礼
	CongratulationView = "CongratulationView",
	JiFenShopView = "JiFenShopView",
	MarryBlessingView = "MarryBlessingView",				--结婚祝贺
	FriendExpBottleView = "FriendExpBottleView",			--好友经验瓶
	JinYinTaView = "JinYinTaView",				            --金银塔运营活动
	MiningView = "MiningView",								--决斗场
	MiningRecordListView = "MiningRecordListView",			--决斗场 - 记录面板
	MiningSelectedView = "MiningSelectedView",				--决斗场 - 选择矿物面板
	MiningTargetView = "MiningTargetView",					--决斗场 -
	SeaRewardView = "SeaRewardView",						--决斗场 -
	SeaSelectedView = "SeaSelectedView",					--决斗场 -
	MiningRewardView = "MiningRewardView",					--决斗场 -
	KaiFuInvestView = "KaiFuInvestView",
	ZhuangZhuangLe = "ZhuangZhuangLeView",                  -- 转转乐
	KiaFuRisingStarView = "KiaFuRisingStarView",            -- 升星助战
	KaiFuDegreeRewardsView = "KaiFuDegreeRewardsView",      -- 升阶奖励
	FlowerReMindView = "FlowerReMindView",
	LuckyDrawView = "LuckyDrawView",						-- 神隐占卜屋
	LuckyDrawAutoPopView = "LuckyDrawAutoPopView",			-- 神隐占卜屋快速占卜弹框
	RechargeCapacity = "RechargeCapacityView",				-- 单充送好礼
	HappyRechargeView = "HappyRechargeView",				-- 充值乐翻天
	HappyRecordListView = "HappyRecordListView",			-- 充值乐翻天记录
	BlackMarket = "BlackMarketView", 						-- 黑市拍卖
	LongXingView = "LongXingView",							--龙行天下界面
	TimeLimitGiftView = "TimeLimitGiftView",				--限时礼包界面
	SlagughterDevilInfoView = "SlagughterDevilInfoView",	--屠魔副本界面

	TreasureBusinessmanView = "TreasureBusinessmanView",	-- 至尊豪礼
	ThreePiece = "ThreePiece",                              -- 奇珍三重奏
	MapFindView = "MapFindView",							-- 宝藏猎人
	MapFindRewardView = "MapFindRewardView",          		-- 宝藏猎人奖励
	MapfindRushView = "MapfindRushView",             		-- 地图快速刷新
	RareDial = "RareDialView",							    -- 珍稀转盘
	KuafuTaskRecordView = "KuafuTaskRecordView",
	KuafuTaskBattleRecordView = "KuafuGuildBattleRecordView",
	KuafuLiujieRewardTip = "KuafuLiujieRewardTip",
	FuBenShengDiInfoView = "FuBenShengDiInfoView",			-- 圣地副本信息面板
	TipsDoubleHitView = "TipsDoubleHitView",				-- 连击面板
	HuanZhuangShopView = "HuanZhuangShopView",		   		--幻装商城
	TitleShopView = "TitleShopView",						--送称号面板
	TowerSelectView = "TowerSelectView",
	TowerSkillView = "TowerSkillView",
	TeamFuBenInfoView = "TeamFuBenInfoView",
	TipsGongGaoView = "TipsGongGaoView",
	KuaFuChongZhiRank="KuaFuChongZhiRank",					-- 跨服充值排行榜
	RedNameView = "RedNameView",
	LoopChargeView = "LoopChargeView",
	TowerMoJieView = "TowerMoJieView", 						-- 爬塔魔戒面板
	CompetitionTips = "CompetitionTips", 					-- 比拼奖励

	FamousGeneralView = "FamousGeneralView",						-- 名将
	FamousTalentBagView = "FamousTalentBagView",					-- 天赋背包
	FamousTalentUpgradeView = "FamousTalentUpgradeView",			-- 天赋升级界面
	FamousTalentSkillUpgradeView = "FamousTalentSkillUpgradeView",	-- 天赋技能升级界面
	SpecialGeneralView = "SpecialGeneralView",						-- 特殊名将提示面板

	KuaFu1v1RankLevelUp = "KuaFuRankLevelUp",				-- 巅峰竞技段位提升
	WorshipView = "WorshipView",							-- 膜拜按钮面板
	SecretTreasureHuntingView = "SecretTreasureHuntingView",	--秘境寻宝
	FamousGeneralFaZhenView = "FamousGeneralFaZhenView",		-- 名将法阵
	FamousGeneralGuangWuView = "FamousGeneralGuangWuView",   -- 名将光武
	IllustratedHandbookView = "IllustratedHandbookView", 	 --图鉴
	ZhuanLunQucikFlushView = "ZhuanLunQucikFlushView",			-- 珍稀转轮快速刷新
	WakeUpFocusView = "WakeUpFocusView",
	SlaughterDevilTipsView = "SlaughterDevilTipsView",
	HappyErnieView = "HappyErnieView",						-- 欢乐摇奖

	CrazyMoneyTreeView = "CrazyMoneyTreeView",              --疯狂摇钱树
	HappyHitEggView = "HappyHitEggView",	                --欢乐砸蛋
	NoMoneyView = "NoMoneyView",                            --疯狂摇钱树提示面板
	SuoYaoTowerFightView = "SuoYaoTowerFightView",   			--锁妖塔

	SingleRebateView = "SingleRebateView", 					--单笔返利

	TimeLimitBigGiftView = "TimeLimitBigGiftView",		    --限时豪礼界面
	RechargeReturnReward = "RechargeReturnReward",		    --狂返元宝界面

	ResetDoubleChongzhiView = "ResetDoubleChongzhiView",		    --普天同庆界面
    BackQingYuanGiftView = "BackQingYuanGiftView",
	OneYuanSnatchView = "OneYuanSnatchView",				-- 一元夺宝

	BuyOneGetOneView = "BuyOneGetOneView",					--买一送一
	ConsunmForGiftView = "ConsunmForGiftView", 				--消费有礼.
	ConsumeRewardView = "ConsumeRewardView",
	ScratchTicketView = "ScratchTicketView",                --刮刮乐
	ExpenseNiceGiftRewardPool = "ExpenseNiceGiftRewardPool",   --消费好礼（奖励池）面板
	XianMengWarView = "XianMengWarView",                      --合服仙盟争霸面板

	FestivalView = "FestivalView",			--版本活动
	BianShenRank = "BianShenRank",							-- 变身榜
	BeiBianShenRank = "BeiBianShenRank",					-- 被变身榜
	MakeMoonCakeView = "MakeMoonCakeView",

	--线上活动
	OnLineView = "OnLineView",
}

TabIndex = {
	role_intro = 11,					--人物-总览
	role_atr = 12,						--人物-属性
	role_skill = 13,					--人物-技能
	role_rebirth = 14,					--人物-转生
	role_money = 15,					--人物-货币
	role_bag = 20,						--人物-背包
	role_bag_warehouse = 21,			--人物=背包-仓库
	role_wh = 31,						--人物-羽翼幻化
	role_wj = 32,						--人物-羽翼进阶
	role_wf = 33,						--人物-羽翼法阵
	role_wm = 34,						--人物-羽翼附魔
	role_ws = 35,						--人物--特殊羽翼
	role_fashion_wq = 41,				--人物-时装武器
	role_fashion_fz = 42,				--人物-时装服装
	role_fashion_gh = 43,				--人物-时装光环
	role_fashion_zj = 44,				--人物-时装足迹
	role_fashion = 45,					--人物时装(G16现在在用的)
	role_baoshi = 51,					--人物-宝石
	role_xilian = 52,					--人物-洗练
	role_jingmai = 53,					--人物-经脉
	role_gengu = 54,					--人物-根骨
	role_huashen = 55,					--人物-化神
	role_xingxiangjingling = 56,		--文物-星象精灵
	role_title = 57,					--人物称号
	role_shenbing = 58,					--人物神兵
	fashion_clothe_jinjie = 59,			--人物时装服饰进阶
	fashion_weapon_jinjie = 60,			--人物时装武器进阶
	role_tulong_equip = 61,				--人物-屠龙装备
	role_chuanshi_equip = 62,			--人物-传世装备
	role_reincarnation = 63,			--人物-真转生

	shenshou_equip = 71,				--神兽-装备
	shenshou_fuling = 72,				--神兽-附灵
	shenshou_huanling = 73,				--神兽-唤灵
	shenshou_compose = 74,				--神兽-合成

	-- 不要动这个外观的index，有实际用途（这个index必须得是顺序递增的）
	appearance_multi_mount = 81001,		--外观-双人坐骑
	appearance_waist = 81002,			--外观-腰饰
	appearance_toushi = 81003,			--外观-头饰
	appearance_qilinbi = 81004,			--外观-麒麟臂
	appearance_mask = 81005,			--外观-面饰
	appearance_lingzhu = 81006,			--外观-灵珠
	appearance_xianbao = 81007,			--外观-仙宝
	appearance_linggong = 81008,		--外观-灵弓
	appearance_lingqi = 81009,			--外观-灵骑
	appearance_weiyan = 81010,			--外观-尾焰
	-- =====================================================

	-- 不要动这个index，有实际用途（这个index必须得是顺序递增的）
	godtemple_pata = 82001,				--封神殿-爬塔
	godtemple_shenqi = 82002,			--封神殿-神器
	-- =====================================================

	forge_strengthen = 101,				--装备-强化
	forge_quality = 102,				--装备-品质
	forge_cast = 103,					--装备-神铸
	forge_up_star = 104,				--装备-升星
	forge_suit = 105,					--装备-套装
	forge_compose = 106,				--装备-合成
	forge_baoshi = 108,					--装备-宝石
	forge_yongheng = 109,				--装备-永恒
	forge_red_equip = 110,				--装备-红色装备

	lianhun_info = 111,					--炼魂
	fb_slaughter_devil = 112,			--屠魔副本
	suoyao_tower = 113,					--锁妖塔

	tianshenhuti_info = 121,			--无双装备
	tianshenhuti_compose = 122,			--无双装备合成
	tianshenhuti_conversion = 123,		--无双装备转化
	tianshenhuti_box = 124,				--无双装备宝箱
	tianshenhuti_bigboss = 125,			--无双装备领主
	tianshenhuti_boss = 126,			--无双装备boss

	shenbing = 150,						--神器神兵
	baojia = 151,						--神器宝甲
	fenjie = 152,						--神器分解

	shenshou_taozhuang_red = 161, 		--神兽套装-红
	shenshou_taozhuang_yellow = 162, 	--神兽套装-黄

	society_team = 201,					--社交-组队
	society_friend = 202,				--社交-好友
	society_enemy = 203,				--社交-仇人
	society_mail = 204,					--社交-邮件
	write_mail = 205,					--社交-写邮件

	camp_choose = 301,					--军团-选择
	camp_overview = 302,				--军团-军团信息
	camp_statue = 303,					--军团-雕像
	camp_snatch_normal = 304,			--军团-普通夺宝
	camp_snatch_high = 305,				--军团-高级夺宝
	camp_equip = 306,					--军团-装备
	camp_rank = 307,					--军团-排行
	camp_equip_soul = 308,				--军团-魂炼
	camp_equip_monster = 309,			--军团-神兽

	System_setting = 401,				--系统-设置
	System_guaji = 402,					--系统-挂机
	System_reward = 403, 				--系统-更新奖励

	compose_stone = 501, 				--熔炉-宝石
	compose_other = 502, 				--熔炉-其他
	compose_jinjie = 503,				--熔炉-锻造
	compose_fashion = 504,				--熔炉-时装
	compose_equip = 505,				--熔炉-装备

	equipment_shen_shengji = 601,		--神装-升级
	equipment_shen_liujue = 604,		--神装-升仙六决
	equipment_shen_jinjie = 605,		--神装-功法进阶
	equipment_shen_jiefeng = 606,		--神装-解除封印
	equipment_jinjie = 607,				--神装-进阶
	equipment_shenzhu = 608,			--神装-神铸

	chat_compre = 701,					--聊天-综合
	chat_world = 702,					--聊天-世界
	chat_team = 703,					--聊天-组队
	chat_guild = 704,					--聊天-公会
	chat_system = 705,					--聊天-系统
	chat_private = 706,					--聊天-私聊
	chat_question = 707,				--聊天-答题
	chat = 710,							--聊天

	big_face = 801,						--炫酷聊天-大表情
	gold_text = 802,					--炫酷聊天-土豪金
	special_image = 803,				--炫酷聊天-特殊表情
	bubble = 804,						--炫酷聊天-聊天框
	head_frame = 805,					--炫酷聊天-头像框

	mount_huanhua = 901,				--坐骑-幻化
	mount_jinjie = 902,					--坐骑-进阶
	-- mount_flyup = 903,				--坐骑-飞升
	-- mount_minghun = 904,				--坐骑-命魂
	wing_jinjie = 905,					--羽翼进阶
	halo_jinjie = 906,					--光环进阶
	shengong_jinjie = 907,				--神弓进阶
	shenyi_jinjie = 908,				--神翼进阶
	huashen_jinjie = 909,				--化神升级
	huashen_protect = 910,				--化神守护
	fight_mount = 911,					--战斗坐骑
	foot_jinjie = 912,                  --足迹进阶
	cloak_jinjie = 913,					--披风进阶
	lingchong_jinjie = 914,				--灵宠进阶

	img_fuling_content = 1001,			--形象赋灵
	-- advance_equipup_mount = 1001,	--进阶-装备升级-坐骑装备升级
	-- advance_equipup_wing = 1002,		--进阶-装备升级-羽翼装备升级
	-- advance_equipup_halo = 1003,		--进阶-装备升级-光环装备升级
	-- advance_equipup_shengong = 1004,	--进阶-装备升级-神弓装备升级
	-- advance_equipup_shenyi = 1005,	--进阶-装备升级-神翼装备升级

	fb_phase = 1100,					--阶段副本
	fb_exp = 1101,						--经验副本
	fb_vip = 1102,						--VIP副本
	fb_story = 1103,					--剧情副本
	fb_tower = 1104,					--勇者之塔副本
	fb_many_people = 1105,				--多人副本
	fb_quality = 1106,					--品质副本
	fb_guard = 1107,					--品质副本
	fb_push = 1108,				 --推图副本1
	-- fb_push_common = 1108,				 --推图副本1
	fb_push_special = 1109,				 --推图副本2
	fb_team = 1110,						--组队副本

	baoju_zhibao_active = 1200,			--宝具至宝活跃
	baoju_zhibao_upgrade = 1201,		--宝具至宝升级
	baoju_medal = 1202,					--宝具勋章
	baoju_achieve_title = 1203,			--宝具成就头衔
	baoju_achieve_overview = 1204,		--宝具成就总览

	spirit_spirit = 1300,				--精灵的子精灵面板
	spirit_hunt = 1301,					--精灵猎取
	spirit_exchange = 1302,				--精灵兑换
	spirit_warehouse = 1303,			--精灵仓库
	spirit_soul = 1304,					--精灵命魂
	spirit_fazhen = 1305,				--精灵法阵
	spirit_halo = 1306,					--精灵光环
	spirit_skill = 1307,				--精灵技能
	spirit_zhenfa = 1308,               --精灵阵法
	spirit_home = 1309,					--精灵家园
	spirit_lingpo = 1310, 				--精灵灵魄
	spirit_meet = 1312, 				--精灵奇遇

	marriage_honeymoon = 1400,			--结婚蜜月
	-- marriage_lover = 1401,				--结婚对象
	marriage_ring = 1401,				--结婚戒指
	marriage_wedding = 1402,			--结婚婚宴副本
	marriage_love_contract = 1403,		--结婚爱情契约
	-- marriage_equip = 1430,				--结婚装备
	marriage_fuben = 1404,				--结婚情缘副本
	-- marriage_halo = 1405,				--结婚互动
	marriage_baobao = 1405,				--结婚宝宝
	marriage_monomer = 1406,			--结婚单身信息
	marriage_equip = 1460,				--结婚装备
	marriage_equip_suit = 1461,			--结婚装备套装
	marriage_equip_recyle = 1462,		--结婚装备回收
	marriage_shengdi = 1470,			--情缘圣地
	marriage_love_halo = 1480,			--结婚光环

	-- marriage_halo_content = 14031,		--结婚光环
	marriage_love_tree = 14032,			--结婚相思树
	marriage_baobao_bless = 1415,		--结婚宝宝祈福
	marriage_baobao_guard = 1426,		--结婚宝宝守卫
	marriage_baobao_att = 1427,         --结婚宝宝属性
	marriage_baobao_zizhi = 1428,       --结婚宝宝资质

	guild_info = 1500,					--公会信息
	guild_member = 1501,				--公会成员
	guild_box = 1502,					--公会宝箱
	guild_altar = 1503,					--公会祭坛
	guild_totem = 1504,					--公会图腾
	guild_territory = 1505,				--公会领地
	guild_list = 1506,					--公会列表
	guild_activity = 1507,				--公会活动
	guild_storge = 1508,				--公会仓库
	guild_donate = 1509,				--公会捐献
	guild_request = 1510,				--公会申请
	guild_maze = 1511,					--公会迷宫
	guild_war = 1512,					--公会争霸
	guild_member = 1513,				--公会成员

	activity_daily = 1601,				--活动-活动大厅
	activity_battle = 1602,				--活动-战场大厅
	activity_kuafu_battle = 1603,		--活动-跨服战场
	activity_ShushanScuffle = 1604,

	activity_kuafu_boss = 1605,
	activity_kuafu_liujie = 1606,
	activity_kuafu_show = 1607,
	activity_tj_boss = 1608,

	activity_sw_boss = 1609,
	activity_tuanzhan = 1610,

	drop = 20600,						--BOSS-掉落日志
	world_boss = 20601,					--BOSS-世界BOSS
	kf_boss = 20602,						--BOSS-跨服BOSS
	vip_boss = 20603,					--BOSS-VIPBOSS
	miku_boss = 20604,					--BOSS-密窟BOSS
	dabao_boss = 20605,					--BOSS-打宝秘境
	secret_boss = 20606,					--BOSS-秘藏Boss
	active_boss = 20607,                 --Boss-活跃Boss
	xianjie_boss = 20608,                --Boss-仙戒Boss
	baby_boss = 20609,					--Boss-宝宝Boss

	market_buy = 1700,					--市场-购买界面
	market_sell = 1701,					--市场-出售界面
	market_table = 1702,				--市场-货架界面

	helper_zhanli = 1800,				--小助手-战力评估
	helper_upgrade = 1801,				--小助手-升级
	helper_earn = 1802,					--小助手-赚钱
	helper_equip = 1803,				--小助手-装备
	helper_strength= 1804,				--小助手-变强
	helper_energy = 1805,				--小助手-活力

	goddess_info = 1900,				--女神信息
	goddess_camp = 1901,				--女神阵营
	goddess_shouhu = 1902,				--女神守护
	goddess_shengong = 1903,			--女神神弓
	goddess_shenyi = 1904,				--女神神翼
	goddess_shengwu = 1905,				--女神圣物
	goddess_gongming = 1915,			--女神共鸣
	goddess_defense = 1906,				--女神塔防

	yu_hun = 2000,						--御魂
	yu_hun_info = 20010,				--御魂--御魂
	yu_hun_expedition = 20011,			--御魂--远征
	yu_hun_exchange = 20012,			--御魂--兑换

	pet_achieve = 2100,					--宠物抽奖
	pet_forge = 2101,					--宠物强化
	pet_park = 2102,					--宠物公园

	magic_card = 2200,					--魔卡
	magic_lottery = 22010,				--魔卡--抽奖
	magic_exchange = 22011,				--魔卡--兑换

	treasure_choujiang = 2300,			--寻宝抽奖
	treasure_exchange = 2301,			--寻宝兑换
	treasure_warehouse = 2302,			--寻宝仓库
	treasure_compose = 2304,			--寻宝合成
	treasure_equip_exchange = 2305,		--寻宝装备兑换

	card_info = 2400,					--卡牌
	card_recyle = 2401,					--卡牌回收

	sword_art_online = 2500,			--刀剑神域

	rechare_info = 2600,				--充值
	rechare_power = 2601,				--充值--权限
	rechare_level_invest = 2602,		--充值--等级投资
	rechare_month_invest = 2603,		--充值--月卡投资

	exchange_mojing = 2700,				--兑换--魔晶
	exchange_shengwang = 2701,			--兑换--声望
	exchange_rongyao = 2702,			--兑换--荣耀
	exchange_guanghui = 2703,			--兑换--光辉
	exchange_mizang = 2704,            --兑换--秘藏

	kaifu_jizi = 102168,				-- 开服活动集字活动

	rune_inlay = 6100,						-- 符文-符文镶嵌
	rune_analyze = 6101,					-- 符文-符文分解
	rune_exchange = 6102,					-- 符文-符文兑换
	rune_treasure = 6103,					-- 符文-符文寻宝
	rune_compose = 6104,					-- 符文-符文合成
	rune_tower = 6105,						-- 符文-符文塔
	rune_zhuling = 6106,					-- 符文-符文祭炼

	setting_xianshi = 2800,				--设置显示
	setting_system = 2801,				--设置系统
	setting_apperance = 2802,			--设置外观
	setting_notice = 2803,				--设置公告
	setting_custom = 2804,				--设置客服

	seven_login_goddess = 2900,			-- 7天登录女神界面
	seven_login_goddess_2 = 2901,		-- 7天登录女神界面2

	shen_ge_shen_ge = 30000,			-- 神格
	shen_ge_inlay = 30001,				-- 神格镶嵌
	shen_ge_bless = 30002,				-- 神格祈福
	shen_ge_group = 30003,				-- 神格组合
	shen_ge_compose = 30004,			-- 神格合成
	shen_ge_zhangkong = 30005,			-- 神格掌控
	shen_ge_godbody = 30006,			-- 神格玄籍
	shen_ge_advance = 30007,			-- 神格淬炼

	hunqi = 30010,						-- 魂器
	hunqi_content = 30011,				-- 魂器魂器
	hunqi_damo = 30012,					-- 魂器打磨
	hunqi_bao = 30013,					-- 魂器宝藏
	hunqi_hunyin = 30014,				-- 魂器魂印
	hunqi_hunyin_inlay = 30015,			-- 魂器魂印镶嵌
	hunqi_hunyin_upgrade = 30016,		-- 魂器魂印升级
	hunqi_xilian = 30017,	        	-- 魂器洗练

	shengxiao = 30020,					-- 星座
	shengxiao_uplevel = 30021,			-- 星座升级
	shengxiao_equip = 30022,			-- 星座装备
	shengxiao_piece = 30023,			-- 星座星途
	shengxiao_spirit = 30024,			-- 星座星灵
	shengxiao_starsoul = 30025,			-- 星座天相

	shop_chengzhang = 4000,				--商城-·成长
	shop_baoshi = 4001,					--商城--宝石
	shop_bind = 4002,					--商城--绑定
	shop_youhui = 4003,					--商城--优惠
	shop_sprits_skill = 4004,			--商城--技能

	yule_fishing = 5010,				--娱乐-钓鱼
	yule_go_pawn = 5020,				--娱乐-幻境寻宝

	mining_mining = 6001,				--决斗场-挖矿
	mining_sea = 6002,					--决斗场-航海
	mining_challenge = 6003,			--决斗场-挑衅

	kaifu_invest_boss = 7001,			--开服投资-Boss投资
	kaifu_invest_active = 7002,			--开服投资--活跃
	kaifu_invest_competition = 7003,	--开服投资--比拼

	welfare_sign_in = 8001,				--福利-签到
	welfare_level = 8002,				--福利-等级豪礼
	welfare_find = 8003,				--福利-找回
	welfare_exchange = 8004,			--福利-兑换
	welfare_goldturn = 8005,			--福利-钻石转盘

	arena_view = 9001,					--竞技-竞技场
	arena_reward_view = 9002,			--竞技-结算
	arena_tupo_view = 9003,				--竞技-突破
	arena_exchange_view = 9004,			--竞技-兑换

	rank_content = 10001,				--排行-排行榜
	rank_mingren = 10002,				--排行-名人
	rank_meili = 10003,					--排行-魅力
	rank_qingyuan = 10004,				--排行—情缘

	-- 预留10位 10010 ~ 10020
	famous_general_info = 10011,		--名将信息
	famous_general_potential = 10012,	--名将潜能
	famous_general_wakeup = 10014,		--名将苏醒
	famous_general_talent = 10013,		--名将天赋
	famous_general_equip = 10015,		--装备
	famous_general_equip_level = 10016,	--装备格子升级
	famous_general_exchange = 10017,	--兑换
	famous_general_guangwu = 10018,
	famous_general_fazheng = 10019,

	boss_card_info = 10021,				--Boss图鉴

	charge_first_rank = 2001, 			--充值第一档
	charge_second_rank = 2002,			--充值第二档
	charge_thrid_rank = 2003,			--充值第三档

	symbol_intro = 71001,				--五行之灵-喂养
	symbol_fuzhou = 71002,				--五行之灵-附纹
	symbol_yuanhun = 71003,				--五行之灵-元炼
	symbol_mishi = 71004,				--五行之灵-寻元
	symbol_upgrade = 71005,				--五行之灵-进阶

	shenyin_shenyin = 3100,				-- 神印--神印
	shenyin_liehun = 3101,				-- 神印--猎魂
	shenyin_qianghua = 3102,			-- 神印--强化
	shenyin_xilian = 3103,				-- 神印--洗练
	shenyin_tianxiang = 3104,			-- 神印--天象
	shenyin_exchange = 3105,			-- 神印--兑换

	kaifu_panel_one = 3001,
	kaifu_panel_three = 3002,
	kaifu_panel_six = 3003,
	kaifu_panel_seven = 3004,
	kaifu_panel_eight = 3005,
	kaifu_panel_two = 3006,
	kaifu_panel_ten = 3007,
	kaifu_panel_twelve = 3008,
	kaifu_personbuy = 3009,
	kaifu_levelreward = 3010,
	kaifu_7dayredpacket = 3011,
	kaifu_goldenpigcall = 3012,
	kaifu_lianxuchongzhigao = 3013,
	kaifu_lianxuchongzhichu = 3014,
	kaifu_panel_fifteen = 3015,
	kaifu_panel_sixteen = 3016,
	kaifu_dailyactivereward = 3017,
	kaifu_congzhirank = 3018,
	kaifu_xiaofeirank = 3019,
	kaifu_bianshenrank = 3020,
	kaifu_beibianshenrank = 3021,
	kaifu_leijireward = 3022,
	kaifu_danbichongzhi = 3023,
	kaifu_rechargerebate = 3024,
	kaifu_totalcharge = 3025,
	kaifu_fullserversnap = 3026,
	kaifu_totalconsume = 3027,
	kaifu_dayconsume = 3028,
	kaifu_daily_love = 3029,
	kaifu_daychongzhi = 3030,
	kaifu_ZhiZunHuiYuan = 3031,
	kaifu_levelinvest = 3032,
	kaifu_touziplan = 3033,
	expense_nice_gift= 3039,

	little_pet_home = 10031,				--宠物家园
	little_pet_feed = 10032,				--宠物喂养
	little_pet_toy = 10033,					--宠物玩具
	little_pet_shop = 10034,				--宠物商店
	little_pet_exchange = 10035,			--宠物兑换

	clothespress_suit = 10041,				--衣橱套装
	clothespress_looks = 10042,				--衣橱穿搭
	clothespress_dress = 10043,				--衣橱装扮
	clothespress_exchange = 10044,			--衣橱兑换

	------- 一元夺宝
	one_yuan_panel_snatch = 3034,
	one_yuan_panel_integral = 3035,
	one_yuan_panel_log = 3036,
	one_yuan_panel_ticket = 3037,

	--中秋活动
	make_moon_cake = 3088,                  --匠心月饼

}

--一个个小ui名字，用于引导中指向某个ui
GuideUIName = {
	Tab = "tab",									--标签，参数：第几个索引（1开始）
	CloseBtn = "btn_close",							--关闭按钮

	MainUIRoleHead = "menu_icon",						--主界面-菜单按钮
	MainUIRightShrink = "shrink_button",				--主界面-右上收缩按钮
	MainUIRolePlayer = "button_player",					--主界面-人物按钮
	MainUIForge = "button_forge",						--主界面-锻造按钮
	MainUIAdvance = "button_advance",					--主界面-形象按钮
	MainUIGoddress = "button_goddess",					--主界面-女神按钮
	MainUIBaoju = "button_baoju",						--主界面-宝具按钮
	MainUISpirit = "button_spiritview",					--主界面-精灵按钮
	MainUICompose = "button_compose",					--主界面-合成按钮
	MainUIGuild = "button_guild",						--主界面-公会按钮
	MainUIScoiety = "button_scoiety",					--主界面-社交按钮
	MainUIMarriage = "button_marriage",					--主界面-结婚按钮
	MainUIEchange = "button_exchange",					--主界面-兑换按钮
	MainUIMarket = "button_market",						--主界面-市场按钮
	MainUIShop = "button_shop",							--主界面-商城按钮
	MainUISetting = "button_setting",					--主界面-设置按钮
	MainUIDailyCharge = "button_daily_charge",			--主界面-每日首冲按钮
	MainUIFirstCharge = "button_firstchargeview",		--主界面-首冲按钮
	MainUISevenLogin = "button_logingift7view",			--主界面-七天登录按钮
	MainUIInvest = "button_investview",					--主界面-投资计划按钮
	MainUISingleFuBen = "button_fuben",					--主界面-单人副本按钮
	MainUIXunBao = "button_treasure",					--主界面-寻宝按钮
	MainUIZhuanSheng = "button_reincarnation",			--主界面-转生按钮
	MainUIBtnDaily = "btn_daily",						--主界面-每日必做按钮
	MainUIBtnTarget = "button_mieshizhizhan",			--主界面-灭世历练按钮
	MainUIJingCaiHuoDong = "button_kaifuactivityview",	--主界面-精彩活动
	MainUIBossHunter = "btn_boss_hunter",				--主界面-精彩活动列表（boss猎手按钮）
	MainUIExperience = "btn_experience",				--主界面-灭世之战列表（灭世历练按钮）
	MainUIBossIcon = "boss_icon",						--主界面-Boss按钮
	MainUIButtonPackage = "button_package",				--主界面-背包按钮
	MainUIPartnerSkillIcon = "partner_skill_icon",		--主界面-伙伴技能图标
	MainUILeftDownMountBtn = "left_down_mount_btn",		--主界面-上坐骑按钮
	MainUIGuideMati = "guide_mati",						--主界面-上战骑按钮
	MainUINewRankBtn = "new_rank_btn",					--主界面-排行榜按钮

	AdvanceMountUp = "mount_start_up",							--形象进阶-坐骑进阶按钮
	AdvanceWingUp = "wing_start_up",							--形象进阶-羽翼进阶按钮

	GodessUpBtn = "godess_up_btn",								--女神-女神升级按钮
	GodessActiveBtn = "godess_active_btn",						--女神-女神激活按钮
	GodessLineUpFight = "godess_line_up_fight",					--女神-出战按钮
	GodessIcon1 = "godess_icon1",								--女神-第一位女神

	MountAttrBtn = "mount_attr_btn",							--副本-坐骑副本挑战
	ExpSoloBtn = "exp_solo_btn",								--副本-经验副本单人挑战按钮
	StroyFbChangeBtn = "stroyfb_change_btn",					--副本-剧情副本第一个挑战按钮
	TowerChallenge = "tower_challenge",							--副本-勇者之塔挑战按钮
	ToggleYuansu = "toggle_yuansu",								--副本-元素试炼标签按钮
	YuanSuAttackButton = "yuansu_attack_button",				--副本-元素试炼进入副本按钮
	ToggleWujin = "toggle_wujin",								--副本-无尽炼狱标签按钮
	WujinEnterButton = "wujin_enter_button",					--副本-无尽炼狱发起进攻按钮

	FriendLotAdd = "friend_lot_add",							--社交-好友批量添加按钮
	FriendRecAutoAdd = "friend_rec_auto_add",					--社交-好友推荐一键添加按钮

	BaoJuGoToJinJieFuBen = "baoju_goto_jinjie_fuben",			--宝具-活跃前往进阶副本按钮
	BaojuGotoDaily = "baoju_goto_daily",						--宝具-活跃日常任务按钮

	ForgeBtnStrength = "btn_strength",							--锻造-强化按钮
	-- ForgeFristEquipItem = "frist_equip_item",					--锻造-第一个装备格子
	ForgeUpStarBtn = "up_star_btn",								--锻造-升星按钮

	TreasureOneTimesBtn = "one_times_btn",						--寻宝-寻宝一次按钮
	TreasureBackWareHouseBtn = "back_warehouse_btn",			--寻宝-返回仓库按钮
	TreasureGetAllBtn = "get_all_btn",							--寻宝-一键取出按钮

	ZhuanShengBtn = "zs_button",								--转生-转生按钮

	RecycleButton = "recycle_button",							--角色-装备回收按钮
	RecycleAndCloseButton = "recycle_and_closebutton",			--角色-立即回收按钮
	TabEquip = "tab_equip",										--角色-装备标签

	SevenDayRewardBtn = "reward_btn",							--七天登录-领取按钮

	GuildAutoEnter = "guild_auto_enter_btn",					--公会--快速加入

	BossGuideFatigue = "boss_fatigue",							--Boss-引导疲劳值

	PersonalGoalRewardBtn = "target_reward_btn",				--灭世之战-领取奖励按钮

	ExchangeMoJingFirstItem = "mojing_first_item",				--兑换-魔晶第一个物品
	ExchangeTipsBtnBuy = "exchange_btn_buy",					--兑换tips-兑换按钮

	TaskDailyItem = "task_daily_item",							--任务-日常任务
	TaskZhiItem = "task_zhi_item",								--任务-支线任务

	MiningBtnChallenge = "mining_btn_challenge",				--决斗场-挑战按钮

	ArenaFirsRoleStand = "first_role_stand",					--竞技场-最差那个玩家挑战按钮
}

--检查tabIndex是否存在重复
local function CheckTabIndex()
	local error_list = {}
	for k, v in pairs(TabIndex) do
		for i, j in pairs(TabIndex) do
			if k ~= i and v == j then
				if not error_list[k] and not error_list[i] then
					error_list[k] = {i, v}
				end
			end
		end
	end

	for k, v in pairs(error_list) do
		print_error("重复的TabIndex: ", k, v[1], v[2])
	end
end

local develop_mode = require("editor/develop_mode")
local is_develop = develop_mode:IsDeveloper()
if is_develop then
	CheckTabIndex()
end
