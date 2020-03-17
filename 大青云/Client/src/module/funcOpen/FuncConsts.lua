--[[
功能常量
lizhuangzhuang
2014年11月3日16:57:20
]]

_G.FuncConsts = {};

FuncConsts.Role           = 1100;
FuncConsts.Bag            = 1101;
FuncConsts.Mall           = 1102;             
FuncConsts.Pick           = 1201;
FuncConsts.AutoBattle     = 1202;
FuncConsts.Skill          = 1;
FuncConsts.Team           = 2;
FuncConsts.Friend         = 3;
FuncConsts.FaBao        = 4; --现在的法宝， 原来的灵兽
FuncConsts.Horse          = 5; --坐骑
FuncConsts.Guild          = 6; --帮派
FuncConsts.Ride           = 7;--骑乘
FuncConsts.Sit            = 8;--打坐
FuncConsts.TP             = 9;--回城
-- FuncConsts.ZhanBaoGe      = 10;--珍宝阁
-- FuncConsts.ShiHun         = 11;--噬魂
FuncConsts.Smithing      = 12;--炼化炉
FuncConsts.Dungeon        = 13;--副本 --单人副本
FuncConsts.FengYao        = 14;--封妖 --斩妖屠魔 --废弃了，改为使用FuncConsts.Agora = 124了 但这个不要删除
FuncConsts.WorldBoss      = 15;--世界Boss
FuncConsts.Activity       = 16;--活动
FuncConsts.Arena          = 17;--竞技场
FuncConsts.XianYuanCave   = 18;--打宝塔
FuncConsts.Babel          = 19;--通天塔
FuncConsts.TimeDugeon     = 20;--猴子时间
FuncConsts.MagicWeapon 	  = 21;--神兵
FuncConsts.RewardLobby    = 22;--福利大厅
FuncConsts.HuoYueDu       = 23;--活跃度
FuncConsts.ExDungeon      = 24;--极限副本  
FuncConsts.Realm          = 25;--境界
FuncConsts.SuperGlory     = 26;--至尊王城
FuncConsts.KillVal        = 27;--每日杀戮
FuncConsts.DropVal        = 28;--天赐机缘
FuncConsts.JinRiBiZuo     = 29;--今日必做
FuncConsts.EquipStren     = 30;--强化
FuncConsts.EquipInherit   = 31;--传承
FuncConsts.EquipProduct   = 32;--升品
FuncConsts.EquipGem       = 33;--宝石
FuncConsts.DaBaoMiJing	  = 34;--打宝秘境
FuncConsts.EquipSuper     = 35;--觉醒
FuncConsts.BaoJia         = 36;--战铠宝甲
FuncConsts.Fashions       = 37;--时装衣柜
FuncConsts.HeCheng        = 38;--道具合成
FuncConsts.LiuShui        = 39;--流水副本 经验副本
FuncConsts.HuiZhang       = 40;--灵力徽章
-- FuncConsts.LianTi         = 41;--炼体
FuncConsts.EquipBuildMain = 42;--打造主界面
FuncConsts.EquipDecomp    = 43;--装备分解
FuncConsts.DominateRoute  = 44;--主宰之路
FuncConsts.Achievement    = 46;--成就
FuncConsts.EquipRefin     = 47;--炼化
FuncConsts.EquipBuild     = 48;--装备打造
FuncConsts.EquipSuperUp   = 49;--卓越铭刻
-- FuncConsts.Lingzhen   	  = 50;--灵阵
-- FuncConsts.LingShouMuDi   = 51;--灵兽墓地
FuncConsts.LovelyPet   	  = 52;--萌宠
FuncConsts.SignWeek   	  = 53;--七日登录
FuncConsts.qiyuanWish     = 54;--祈愿
FuncConsts.WingHeCheng    = 55;--翅膀合成
FuncConsts.Consignment	  = 56;--寄售行
FuncConsts.WaBao		  = 57;--寻宝
FuncConsts.RandomQuest    = 58;--奇遇
FuncConsts.Homestead      = 59;--家园
FuncConsts.equipCollect   = 60;--装备收集
FuncConsts.MagicSkill     = 61;--绝学
FuncConsts.BingHun	      = 62;--兵魂
FuncConsts.Vip	          = 63;--vip
FuncConsts.KuaFuPVP	      = 64;--兵魂
FuncConsts.Smelt	      = 65;--熔炼
FuncConsts.MountLingShou  = 67;--灵兽坐骑
FuncConsts.ZhuanShen3 	  = 69;--三转
FuncConsts.Deal     	  = 70;--交易
FuncConsts.GroupPanel 	  = 71;--套装
FuncConsts.PersonalBoss   = 72;--个人BOSS
FuncConsts.QiZhan   	  = 73;--骑战兵器
FuncConsts.QiZhanDungeon  = 74;--骑战副本
FuncConsts.BossHuizhang   = 75;--屠魔
FuncConsts.personalCaveBoss   = 76;--地宫BOSS
FuncConsts.EquipSuperWash   = 77;--卓越重铸
-- FuncConsts.ShiHunHuizhang   = 78;--噬魂徽章
FuncConsts.EquipSuperValWash= 80; -- 卓越精炼
-- FuncConsts.ShenLing       = 82; -- 神灵
FuncConsts.WingStarUp       = 83; -- 战翼强化
FuncConsts.Marry       = 85; -- 结婚
FuncConsts.BingLing       = 86; -- 兵灵
FuncConsts.ShenWu       = 87; -- 神武
FuncConsts.LingYin       = 88; -- 灵印
-- FuncConsts.YuanLing       = 89; -- 元灵
FuncConsts.Hallows       = 90; -- 圣器镶嵌
FuncConsts.GroupYangc	 = 91; -- 套装养成
-- FuncConsts.Wuxinglingmai = 92; -- 五行灵脉
-- FuncConsts.LunPan       = 93; -- 天命轮盘
FuncConsts.EquipSeniorJinglian   = 94; -- 高级精炼
FuncConsts.EquipLianHua = 95;--装备炼化
FuncConsts.DekaronDungeon = 96;--挑战副本
-- FuncConsts.ZhanNu         = 97;--战弩
FuncConsts.ShouHun = 98;--灵兽魂魄(血脉)
FuncConsts.QiYin = 99;--骑兵拓展
FuncConsts.ShenLingYin = 100;--神灵拓展
FuncConsts.Fumo =  103; --宝鉴
FuncConsts.ZhuanZhi = 104;--转职
FuncConsts.Xingtu = 105; --星图
FuncConsts.BaoJia = 107; --神炉 宝甲
FuncConsts.MingYu = 108; --神炉 玉佩
FuncConsts.EquipRonghe = 101 --装备融合
FuncConsts.SmithingWash   = 109 --装备洗练
FuncConsts.SmithingResp = 31 --装备传承
FuncConsts.SmithingRing = 111 --左戒
FuncConsts.LianQi = 112 --炼器
FuncConsts.LingBao = 113 --灵宝FuncConsts.LianQi的子功能
FuncConsts.XinfaSkill = 114;--心法
--FuncConsts.Tianshen=115;--天神附体
FuncConsts.NewTianshen = 115; --新天神
FuncConsts.FieldBoss = 116 --野外BOSS
FuncConsts.QuestRandom = 117;--历练 奇遇任务
FuncConsts.XiuweiPool = 118;--修为池
FuncConsts.LieMo = 119;--猎魔
FuncConsts.LingQi = 120;--灵器
FuncConsts.MingYuDZZ = 122;--玉佩DZZ
FuncConsts.Agora = 124;--任务集会所 新屠魔 新悬赏
FuncConsts.Armor = 125;--新宝甲
FuncConsts.PalaceBoss=126;--地宫boss

--[[
-- FuncConsts中定义的这些常量ID，应该是与functionopen.xlxs中的ID一列一一对应的。为的是判断功能开启取配表信息的时候作为常量使用。
-- 所以不再functionopen.xlxs表中的ID，最好不要写在这里，容易造成歧义。自定义的功能子面板ID最好写在各个系统中
-- ]]
------------------NEW------------------
-----------------VENUS-----------------
---**法宝**----
FuncConsts.FabaoInfo = 10001;--法宝信息
FuncConsts.FabaoHecheng = 10002;--法宝合成
FuncConsts.FabaoRonghe = 10003;--法宝融合
FuncConsts.FabaoChongsheng = 10004;--法宝重生
FuncConsts.FabaoLianshu = 10005;--法宝炼书
---**锻造**----
FuncConsts.SmithingInlay = 10101;--镶嵌
FuncConsts.SmithingStren = 10102;--强化
FuncConsts.SmithingStar = 10103;--升星
FuncConsts.SmithingAppend = 10104;--附加
FuncConsts.SmithingFusion = 10105;--融合
-- FuncConsts.SmithingClear = 10105;--洗练
FuncConsts.SmithingSplit = 10106;--分解

---技能&绝学(被动技能-主动技能)----    adder:houxudong date:2016/6/1 12:23:25
FuncConsts.singleDungeon = 13;      ---单人副本
FuncConsts.experDungeon = 39;       ---经验副本
FuncConsts.teamDungeon = 74;        ---组队爬塔	封妖试炼  组队爬塔
FuncConsts.teamExper = 20;          ---组队刷怪	妖域幻境
-- FuncConsts.singlePataDungeon = 19;  ---单人爬塔
FuncConsts.zhuxianDungeon = 121;    ---朱仙阵副本
FuncConsts.muyeDungeon = 123;       ---牧野之战副本
-------------------------------------------

--功能映射要打开的UI(子功能不要在这里定义UI类)
FuncConsts.UIMap = {
	[FuncConsts.Role]         = 'UIRole',
	[FuncConsts.Bag]          = 'UIBag',
	[FuncConsts.Mall]         = 'UIShoppingMall',
	[FuncConsts.AutoBattle]   = "UIAutoBattle",
	[FuncConsts.Skill]        = "UISkill",
	[FuncConsts.Team]         = 'UITeam',
	[FuncConsts.Friend]       = "UIFriend",
	[FuncConsts.FaBao]      = "UIFabao",
	[FuncConsts.Horse]        = "UIMount",                             --坐骑关闭
	-- [FuncConsts.ZhanBaoGe]    = "UIJewellPanel",
	-- [FuncConsts.ShiHun]       = "UIShihun",
	[FuncConsts.Smithing]    = "UISmithing",
	[FuncConsts.Guild]        = "UIUnionManager",
	[FuncConsts.Dungeon]      = "UIDungeonMain",    ---changer:hxd
--	[FuncConsts.FengYao]      = "UIFengYao",
	[FuncConsts.FengYao]      = "UIAgoraView",
	[FuncConsts.WorldBoss]    = "UIBossBasic",      --从聊天窗口打开boss的面板会报错，因为之前写的是UIWorldBoss 现在改为UIBossBasic了
	[FuncConsts.Activity]     = "UIActivity",
	[FuncConsts.Arena]        = "UIArena",
	[FuncConsts.XianYuanCave] = "UIYaota",
	[FuncConsts.DaBaoMiJing]  = "UIXianYuanCave",
	[FuncConsts.Babel]        = "UIBabelMainView",   --改改 UIBabelMainView  UIBabel
	[FuncConsts.TimeDugeon]   = "UITimerDungeon",
	[FuncConsts.RewardLobby]  = "UIRegisterAward",
	[FuncConsts.HuoYueDu]     = "UIHuoYueDuView",
	[FuncConsts.ZhuanZhi]     ="UIZhuanZhiView",
	[FuncConsts.Realm]        = "UIRealmMainView",
	[FuncConsts.ExDungeon]    = "UIExtremitChallenge",
	[FuncConsts.SuperGlory]   = "UISuperGloryView",
	[FuncConsts.JinRiBiZuo]   = "UIDailyMustDoView",
	[FuncConsts.BaoJia]       = "UIBaoJia",
	[FuncConsts.Fashions]     = "UIFashionsMainView",
	[FuncConsts.HeCheng]      = "UIToolHeCheng",
	[FuncConsts.experDungeon]      = "UIWaterDungeon",
	[FuncConsts.HuiZhang]     = "UIHomesteadMainView",
	-- [FuncConsts.LianTi]       = "UILianTiView",
	[FuncConsts.EquipBuildMain]= "UIEquipBuildMain",
	[FuncConsts.Achievement]  = "UIAchievement",
	[FuncConsts.DominateRoute]  = "UIDominateRoute",
	-- [FuncConsts.LingShouMuDi] = "UILingShouMuDiMainView",
	[FuncConsts.KuaFuPVP] = "MainInterServiceUI",
	-- [FuncConsts.Lingzhen] = "LingZhenMainUI",
	[FuncConsts.LovelyPet] 	  = "UILovelyPetMainView",
	[FuncConsts.WingHeCheng]    = "MainWingUI",
	[FuncConsts.qiyuanWish]   = "UIWishPanel",
	[FuncConsts.Homestead]    = "UIHomesteadMainView",
	[FuncConsts.MagicSkill]   = "UIMagicSkill",  --单独打开-UIMagicSkill  页签打开-UIMagicSkillBasic
	[FuncConsts.Consignment]    = "UIConsigmentMain",
	[FuncConsts.equipCollect] = "UISmithingCollect",
	[FuncConsts.BingHun]      = "BingHunMainUI",
	[FuncConsts.Smelt]        = "UIEquipSmelting",
	[FuncConsts.GroupPanel]   = "UIEquipGroupMain",
	[FuncConsts.PersonalBoss] = 'UIBossBasic',
	[FuncConsts.QiZhan]         = 'QiZhanMainUI',
	[FuncConsts.QiZhanDungeon]= 'UIQiZhanDungeon',
	[FuncConsts.BossHuizhang] = 'UIBossMedal',
	-- [FuncConsts.ShiHunHuizhang]= "UIShiHunMedal",
	-- [FuncConsts.ShenLing]     = "MainShenLingUI",
	-- [FuncConsts.YuanLing]     = "MainYuanLingUI",
	[FuncConsts.ShenWu]     = "UIShenWu",
	-- [FuncConsts.LunPan]     = "UILunPan",
	[FuncConsts.EquipLianHua] = "UIEquipLianHua",
	-- [FuncConsts.Wuxinglingmai] = "MainWuxinglingmaiUI",
	[FuncConsts.DekaronDungeon] = "UIDekaronDungeon",
	-- [FuncConsts.ZhanNu]       = 'MainZhanNuUI',
	[FuncConsts.Fumo]       = "UIFumo",
	[FuncConsts.Xingtu]		= "UIXingtu",  
	[FuncConsts.XinfaSkill] = "UIXinfaSkillBasic",
	[FuncConsts.LianQi]		= "UILianQiMainPanelView";
	[FuncConsts.SignWeek]		= "UIWeekSign";
	[FuncConsts.QuestRandom]	= "UIHoneView";
	--[FuncConsts.Tianshen]       = "UITianShenView";
	[FuncConsts.NewTianshen]   = "UINewTianshenBasic",
	[FuncConsts.XiuweiPool]     = "UIXiuweiPool";
	[FuncConsts.LieMo]			= "UILieMoView";
	[FuncConsts.MagicWeapon]	= "MainMagicWeaponUI";
	[FuncConsts.Vip]	= "UIVip";
	[FuncConsts.LingQi]	= "MainLingQiUI";
	[FuncConsts.MingYuDZZ]	= "MainMingYuUI";
	[FuncConsts.Agora]			= "UIAgoraView";
	[FuncConsts.Armor]	= "MainArmorUI";
	[FuncConsts.PalaceBoss] ="UIPalaceBoss";
}
--图标按钮排列
FuncConsts.bottomOpen=1    --下
FuncConsts.centerOpen=2    -- 中

--自动开启时间
FuncConsts.AutoOpenTime = 5000;

--功能状态

FuncConsts.State_UnOpen = 0;--未开启
FuncConsts.State_ReadyOpen = 1;--预开启
FuncConsts.State_Open = 2;--开启
FuncConsts.State_OpenPrompt = 3;--显示开启天数提示
FuncConsts.State_OpenClick = 4;--显示点击开启功能
FuncConsts.State_FunOpened = 5;--功能通过点击已开启

