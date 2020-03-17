--[[
任务常量
lizhuangzhuang
2014年8月8日17:22:05
]]

_G.QuestConsts = {};

--任务类型
QuestConsts.Type_Trunk       = 1;--主线
QuestConsts.Type_Branch      = 2;--支线
QuestConsts.Type_Day         = 3;--日环
QuestConsts.Type_Random      = 4;--奇遇(随机任务)
QuestConsts.Type_Level       = 5;--等级任务
QuestConsts.Type_Achievement = 6;--成就任务
QuestConsts.Type_WaBao		 = 7;--挖宝
QuestConsts.Type_FengYao	 = 8;--斩妖屠魔 悬赏
QuestConsts.Type_Super		 = 9;--卓越
QuestConsts.Type_HuoYueDu	 = 10;--活跃度即当前仙阶
QuestConsts.Type_EXP_Dungeon = 11;--经验副本
QuestConsts.Type_ZhuanZhi    = 12;--转职任务 ,飞升
QuestConsts.Type_Single_Dungeon    	= 13;--单人副本 变形副本
QuestConsts.Type_Team_Dungeon    	= 14;--组队副本 封妖试炼
QuestConsts.Type_Team_EXP_Dungeon   = 15;--组队经验副本 妖域幻界
QuestConsts.Type_TaoFa			    = 16;--讨伐任务
QuestConsts.Type_Agora			    = 17;--集会所任务 新屠魔 新悬赏 yanghongbin/yaochunlong
QuestConsts.Type_XianYuanCave		= 18;--打宝地宫
QuestConsts.Type_Babel				= 19; --封神试炼
QuestConsts.Type_GodDynasty			= 20; --诛仙阵
QuestConsts.Type_BXDG				= 21; --变形地宫
QuestConsts.Type_SGZC				= 22; --上古战场
QuestConsts.Type_LieMo         		= 23;--猎魔
QuestConsts.Type_UnionJoin			= 24;--加入帮派
QuestConsts.Type_Makion				= 25;--牧野之战
QuestConsts.Type_Arena				= 26;--竞技场
QuestConsts.Type_Hang				= 27;--推荐挂机
--等级任务奖励类型
QuestConsts.Level_Reward_Exp	= 1;
QuestConsts.Level_Reward_Gold	= 2;
QuestConsts.Level_Reward_ZhenQi	= 3;
QuestConsts.Level_Reward_Item_Other	= 4;
--任务状态
QuestConsts.State_UnAccept     = 0;--未接
QuestConsts.State_Going        = 1;--进行中
QuestConsts.State_CanFinish    = 2;--可完成
QuestConsts.State_Finished     = 3;--已完成
--这两个是客户端状态 QuestConsts.State_UnAccept 子状态
QuestConsts.State_CannotAccept = 4;--未接,不可接 
QuestConsts.State_CanAccept    = 5;--未接,可接


--任务栏排序索引
QuestConsts.MainPageQuestOrder = {
	QuestConsts.Type_Trunk,					--主线
	QuestConsts.Type_ZhuanZhi,				--转职任务，飞升
	QuestConsts.Type_Day,					--日环
	QuestConsts.Type_LieMo,					--猎魔
	QuestConsts.Type_TaoFa,					--讨伐	
	QuestConsts.Type_Random,				--历练	
	QuestConsts.Type_Agora,					--集会所任务 新屠魔 新悬赏
	QuestConsts.Type_FengYao,				--斩妖屠魔 封妖 悬赏
	QuestConsts.Type_EXP_Dungeon,			--经验副本
	QuestConsts.Type_Team_EXP_Dungeon, 		--组队经验副本 妖域幻界
	QuestConsts.Type_Single_Dungeon,		--单人副本
	QuestConsts.Type_Team_Dungeon,			--封妖试炼  组队副本
	QuestConsts.Type_WaBao,					--挖宝
	QuestConsts.Type_Super,					--卓越
	QuestConsts.Type_HuoYueDu,				--活跃度仙阶
	QuestConsts.Type_XianYuanCave,			--打宝地宫
	QuestConsts.Type_Babel,					--封神试炼
	QuestConsts.Type_GodDynasty,			--诛仙阵
	QuestConsts.Type_BXDG,					--变形地宫
	QuestConsts.Type_SGZC,					--上古战场
	QuestConsts.Type_Makion,				--牧野之战
	QuestConsts.Type_Arena,					--竞技场
	QuestConsts.Type_UnionJoin,				--加入帮派
	QuestConsts.Type_Hang,					--推荐挂机
}
QuestConsts.MainPageQuestIndex = {
}

--任务id前缀
QuestConsts.RandomQuestPrefix = "qiyu";--奇遇
QuestConsts.WaBaoQuestPrefix = "wabao";--挖宝
QuestConsts.FengYaoQuestPrefix = "fengyao";--封妖
QuestConsts.SuperQuestPrefix = "super";--卓越
QuestConsts.HuoYueDuQuestPrefix = "huoyuedu";--活跃度即当前仙阶
QuestConsts.ExpDungeonQuestPrefix = "expdungeon";--经验副本
QuestConsts.SingleDungeonQuestPrefix = "singledungeon";--单人副本
QuestConsts.TeamDungeonQuestPrefix = "teamdungeon";--组队副本
QuestConsts.TeamExpDungeonQuestPrefix = "teamExpdungeon";--组队经验副本
QuestConsts.TaoFaQuestPrefix = "taofa";--讨伐
QuestConsts.AgoraQuestPrefix = "agora";--集会所任务 新屠魔 新悬赏
QuestConsts.XianYuanCaveQuestPrefix = "xianyuancave";--打宝地宫
QuestConsts.BabelQuestPrefix = "babel";--封神试炼
QuestConsts.GodDynastyQuestPrefix = "goddynasty"--诛仙阵
QuestConsts.BXDGQuestPrefix = "bxdg"--变形地宫
QuestConsts.SGZCQuestPrefix = "sgzc"--上古战场
QuestConsts.UnionJoinQuestPrefix = "unionjoin"--加入帮派
QuestConsts.MakionQuestPrefix = "makion"--牧野之战
QuestConsts.ArenaQuestPrefix = "arena"--竞技场
QuestConsts.HangQuestPrefix = "hang"--推荐挂机

--------------------------------任务目标类型------------------------------------
QuestConsts.GoalType_Talk               = 1;--对话
QuestConsts.GoalType_KillMonster        = 2;--杀怪
QuestConsts.GoalType_KillMonsterCollect = 3;--杀怪收集
QuestConsts.GoalType_CollectItem        = 4;--地面采集
QuestConsts.GoalType_GetItem            = 5;--获取道具
QuestConsts.GoalType_PutOnEquip         = 6;--装备武器
QuestConsts.GoalType_UseItem            = 7;--使用道具
QuestConsts.GoalType_SendMail           = 8;--送信
QuestConsts.GoalType_GoPos              = 9;--到达目标
QuestConsts.GoalType_FuBen              = 10;--打怪副本
QuestConsts.GoalType_Potral             = 11;--传送门任务
QuestConsts.GoalType_Click              = 12;--点击任务
QuestConsts.GoalType_SpecialMonster     = 13;--特殊杀怪任务
QuestConsts.GoalType_CompleteDungenon     = 14;--通关副本任务
-- 等级任务
QuestConsts.GoalType_Dungeon          = 101;--通关副本
QuestConsts.GoalType_Activity         = 102;--参加活动
QuestConsts.GoalType_Babel            = 103;--参加斗破苍穹
QuestConsts.GoalType_TimeDugeon       = 104;--参与灵光界次数
QuestConsts.GoalType_ExDungeon        = 105;--参与极限挑战
QuestConsts.GoalType_RewardQuest      = 106;--完成悬赏任务次数
QuestConsts.GoalType_EquipPro         = 107;--装备升品N次
QuestConsts.GoalType_Strengthen       = 108;--强化装备次数
QuestConsts.GoalType_MountLvlUp       = 109;--升阶坐骑次数
QuestConsts.GoalType_SpiritsLvlUp     = 110;--升阶灵兽次数
QuestConsts.GoalType_MagicWeaponLvlUp = 111;--升阶神兵次数
-- QuestConsts.GoalType_RealmInject      = 112;--境界灌注次数
QuestConsts.GoalType_SkillLvlUp       = 113;--技能升级次数
QuestConsts.GoalType_SuperPeel        = 114;--卓越属性剥离
QuestConsts.GoalType_SuperInlay       = 115;--卓越属性镶嵌
QuestConsts.GoalType_SuperAwaken      = 116;--卓越觉醒次数
QuestConsts.GoalType_GemLvlUp         = 117;--宝石升级次数
QuestConsts.GoalType_EquipRefin       = 118;--装备炼化次数
QuestConsts.GoalType_FeedLingshou     = 119;--灵兽喂养次数
QuestConsts.GoalType_EquipBuild       = 120;--打造装备次数
QuestConsts.GoalType_DominateRoad     = 121;--主宰之路次数
QuestConsts.GoalType_WaterDugeon      = 122;--流水副本次数
QuestConsts.GoalType_DailyTurn		  = 123;--完成日环任务环数
QuestConsts.GoalType_AllRefinTo		  = 124;--全身强化等级达到
QuestConsts.GoalType_RandomQuest	  = 125;--完成奇遇次数
QuestConsts.GoalType_BabelFloor		  = 126;--斗破苍穹层数达到
QuestConsts.GoalType_WaBaoTimes		  = 127;--完成寻宝次数
QuestConsts.GoalType_SkillLvlTo		  = 128;--任意技能等级达到
QuestConsts.GoalType_SkillAllLvlTo	  = 129;--全身技能等级达到 目前应该是最小等级
QuestConsts.GoalType_DominateRoadFloor= 130;--主宰之路层数达到
-- QuestConsts.GoalType_LingshoumudiFloor= 131;--灵兽墓地层数达到
QuestConsts.GoalType_MagicWeaponLvlTo = 132;--神兵阶数达到
QuestConsts.GoalType_ZhuanshengTimes  = 133;--转生次数达到
QuestConsts.GoalType_FightTo		  = 134;--战斗力达到
QuestConsts.GoalType_ChargeTo		  = 135;--充值达到

-- 等级任务VENUS
QuestConsts.GoalType_CharLevelTo	 = 150;--人物等级
QuestConsts.GoalType_EquipUpStar     = 151;--装备升星
QuestConsts.GoalType_XingtuStar      = 152;--星图星数
QuestConsts.GoalType_SmithingTimes   = 153;--装备洗练次数
QuestConsts.GoalType_GetFabao        = 154;--获取法宝
QuestConsts.GoalType_JoinUnion       = 155;--加入帮派
QuestConsts.GoalType_HuoYueDuLevelTo = 156;--仙阶达到等级
QuestConsts.GoalType_UseDanyaoTimes  = 157;--使用丹药次数
QuestConsts.GoalType_BaoJiaLevelTo   = 158;--宝甲等级
QuestConsts.GoalType_XuanBingLevelTo = 159;--玄兵等级
QuestConsts.GoalType_MingYuLevelTo   = 160;--玉佩等级
QuestConsts.GoalType_WorldBoss       = 161;--世界BOSS
QuestConsts.GoalType_PersonalBoss    = 162;--个人BOSS
QuestConsts.GoalType_DiGongBoss      = 163;--地宫BOSS
QuestConsts.GoalType_YeWaiBoss       = 164;--野外BOSS
QuestConsts.GoalType_GoldBoss        = 165;--金币BOSS
QuestConsts.GoalType_JinJiChang      = 166;--竞技场
QuestConsts.GoalType_DaBaoTa         = 167;--打宝塔
QuestConsts.GoalType_RingLvUp	     = 168;--戒指
QuestConsts.GoalType_SkillTotalLvTo  = 169;--全身技能总和等级达到
QuestConsts.GoalType_DressEquipByID  = 170;--穿戴某一个ID装备
QuestConsts.GoalType_DressEquipByNumQuality  = 171;--穿戴X件 品质为Y的装备
QuestConsts.GoalType_XingTuXTo9  		= 172;--x个星图达到9重
QuestConsts.GoalType_UnionPray 			= 174;--帮派祈福
QuestConsts.GoalType_UnionDonation		= 175;--帮派捐赠
QuestConsts.GoalType_UnionAid			= 176;--帮派加持
QuestConsts.GoalType_UnionExchange		= 177;--帮派商店兑换
QuestConsts.GoalType_NewTianShenLvUp		= 178;--新天神升级
QuestConsts.GoalType_NewTianShenUpStar		= 179;--新天神升星
QuestConsts.GoalType_NewTianShenFight		= 180;--新天神上阵紫色天神
-- 成就任务
QuestConsts.GoalType_Achievement      = 1000;--成就任务
-- 随机任务
QuestConsts.GoalType_RandomTalk       = 2001;--奇遇任务对话
QuestConsts.GoalType_RandomGoPos      = 2002;--奇遇任务到达坐标
-- 新奇遇任务 yanghongbin/guyingnan 2016-9-3
QuestConsts.GoalType_RandomNone 	  = 2100;--奇遇任务未接取
QuestConsts.GoalType_RandomKillMonster= 2102;--奇遇任务刷怪
-- 挖宝
QuestConsts.GoalType_WaBao			  = 3000;--挖宝
--封妖
QuestConsts.GoalType_FengYao		  = 4000;--封妖
--卓越
QuestConsts.GoalType_Super			  = 5000;--卓越
--活跃度
QuestConsts.GoalType_HuoYueDu		  = 6000;--活跃度
-- 经验副本
QuestConsts.GoalType_EXP_Dungeon	  = 7000;--经验副本
-- 转职任务
QuestConsts.GoalType_ZhuanZhi		  = 8000;
-- 组队副本
QuestConsts.GoalType_Team_Dungeon		  = 9000;--组队副本
-- 组队经验副本
QuestConsts.GoalType_Team_Exp_Dungeon		  = 10000;--组队经验副本
-- 集会所 新屠魔 新悬赏
QuestConsts.GoalType_AgoraNone			= 17000;--没接取agora
QuestConsts.GoalType_AgoraKillMonster	= 17001;--新悬赏杀怪
QuestConsts.GoalType_AgoraCollection	= 17002;--新悬赏采集
QuestConsts.GoalType_TaoFaQuestTalk		= 17003;--新悬赏讨伐
QuestConsts.GoalType_AgoraQuestTalk		= 17005;--新悬赏NPC对话
------------------------------------------------------------

QuestConsts.RecommendType_Hang         = 1 -- 推荐挂机
QuestConsts.RecommendType_Dungeon      = 2 -- 普通副本
QuestConsts.RecommendType_TimeDugeon   = 3 -- 灵光封魔
QuestConsts.RecommendType_Cave         = 4 -- 仙缘洞府
QuestConsts.RecommendType_WaterDungeon = 5 -- 流水副本  经验副本
QuestConsts.RecommendType_RandomQuest  = 6 -- 奇遇
QuestConsts.RecommendType_Wabao        = 7 -- 挖宝
QuestConsts.RecommendType_Fengyao      = 8 -- 封妖
QuestConsts.RecommendType_HuoYueDu     = 9 -- 活跃度
QuestConsts.RecommendType_XianYuanCave = 10 -- 锁妖塔
QuestConsts.RecommendType_TaoFa        = 11 -- 讨伐
QuestConsts.RecommendType_Daily        = 12 -- 日环
QuestConsts.RecommendType_Hone         = 13 -- 历练
QuestConsts.RecommendType_Agora        = 14 -- 悬赏
QuestConsts.RecommendType_TeamExp	   = 15 -- 组队经验
QuestConsts.RecommendType_Team		   = 16 -- 组队挑战
QuestConsts.RecommendType_Babel		   = 17 -- 封神试炼
QuestConsts.RecommendType_GodDynasty   = 18 -- 诛仙阵
QuestConsts.RecommendType_BXDG   	   = 19 -- 变形地宫
QuestConsts.RecommendType_SGZC   	   = 20 -- 上古战场
QuestConsts.RecommendType_LieMo		   = 21 -- 猎魔任务
--支线任务数量上限
QuestConsts.QuestBranchCeiling = 20;

--日环任务每日总环数
QuestConsts.QuestDailyTotal = 20;

--自动进行任务的等级  自动进行任务的最大等级
QuestConsts.AutoLevel = 120;
--是否是新手主线期间 大概前48一直是true，如果不是主界面任务追踪面板从新手模式变成正常模式
QuestConsts.IsNewPlayerTrunk = false;
--主动拉回主线任务的等级
QuestConsts.AutoTrunkLevel = 10;
--日环引导的最大等级
QuestConsts.MaxDayGuideLvl = 50;

--停下来后自动进行任务时间
QuestConsts.Auto_S_Time = 10000;
--任务断档时自动拉到日环的时间
QuestConsts.Auto_Day_Time = 10000;
--任务断档时自动去挂机的时间
QuestConsts.Auto_Battle_time = 60000;

--获取不同状态的显示文本
function QuestConsts:GetStateLabel(state)
	if state == QuestConsts.State_CanAccept then
		return UIStrConfig["quest5"];
	elseif state == QuestConsts.State_Going then
		return UIStrConfig["quest6"];
	elseif state == QuestConsts.State_CannotAccept then
		return UIStrConfig["quest17"];
	elseif state == QuestConsts.State_CanFinish then
		return UIStrConfig["quest7"];
	elseif state == QuestConsts.State_Finished then
		return UIStrConfig["quest19"];
	end
end

--获取不同状态的文本颜色
function QuestConsts:GetStateLabelColor(state)
	if state == QuestConsts.State_CanAccept then
		return QuestColor.COLOR_GREEN;
	elseif state == QuestConsts.State_Going then
		return QuestColor.COLOR_RED;
	elseif state == QuestConsts.State_CannotAccept then
		return QuestColor.COLOR_RED;
	elseif state == QuestConsts.State_CanFinish then
		return QuestColor.COLOR_GREEN;
	end
end

--获取NPC对话面板的文本颜色
function QuestConsts:GetNPCQuestLabelColor(state)
	if state == QuestConsts.State_CanAccept then
		return "#29cc00";
	elseif state == QuestConsts.State_Going then
		return "#6b6e74";
	elseif state == QuestConsts.State_CannotAccept then
		return "#ffcc33";
	elseif state == QuestConsts.State_CanFinish then
		return "#29cc00";
	end
end

--获取任务类型文本
function QuestConsts:GetTypeLabel(questType)
	if questType == QuestConsts.Type_Trunk then
		return StrConfig['quest10'];
	elseif questType == QuestConsts.Type_Branch then
		return StrConfig['quest12'];
	elseif questType == QuestConsts.Type_Day then
		return StrConfig['quest11'];
	elseif questType == QuestConsts.Type_Random then
		return StrConfig['quest13'];
	elseif questType == QuestConsts.Type_Level then
		return StrConfig['quest14'];
	elseif questType == QuestConsts.Type_Achievement then
		return StrConfig['quest15'];
	elseif questType == QuestConsts.Type_ZhuanZhi then
		return StrConfig['quest21'];
	elseif questType == QuestConsts.Type_FengYao then
		return StrConfig['quest22'];
	end
end
--获取任务标题的类型文字字符，策划新制定的规则 yanghongbin/jianghaoran 2016-7-20
function QuestConsts:GetTitleTypeLabel(questType)
	local result = "";
	if questType == QuestConsts.Type_Trunk then --【主线】
		result = StrConfig['quest30'];
	elseif questType == QuestConsts.Type_Branch then --【支线】
		result = StrConfig['quest31'];
	elseif questType == QuestConsts.Type_Day then --日环【经验】
		result = StrConfig['quest32'];
	elseif questType == QuestConsts.Type_Random then --【历练】【银两】【经验】
		result = StrConfig['quest33'];
	elseif questType == QuestConsts.Type_Super then --【神装】
		result = StrConfig['quest34'];
	elseif questType == QuestConsts.Type_FengYao then --屠魔【经验】
		result = StrConfig['quest35'];
	elseif questType == QuestConsts.Type_ZhuanZhi then --飞升 转职【飞升】
		result = StrConfig['quest36'];
	elseif questType == QuestConsts.Type_Level then	--等级任务 【目标】 已经废弃
		result = StrConfig['quest37'];
	elseif questType == QuestConsts.Type_EXP_Dungeon then --经验副本【经验】
		result = StrConfig['quest38'];
	elseif questType == QuestConsts.Type_Single_Dungeon then --单人副本【道具】
		result = StrConfig['quest39'];
	elseif questType == QuestConsts.Type_Team_Dungeon then --组队副本 组队挑战【道具】
		result = StrConfig['quest40'];
	elseif questType == QuestConsts.Type_Team_EXP_Dungeon then --组队经验副本 组队升级  天神战场【天神】
		result = StrConfig['quest41'];
	elseif questType == QuestConsts.Type_TaoFa then --讨伐 【经验】
		result = StrConfig['quest42'];
	elseif questType == QuestConsts.Type_Agora then	--任务集会所 新屠魔 【战力】
		result = StrConfig['quest43'];
	elseif questType == QuestConsts.Type_XianYuanCave then	--打宝地宫 【经验】
		result = StrConfig['quest44'];
	elseif questType == QuestConsts.Type_Babel then	--封神试炼  【装备】
		result = StrConfig['quest45'];
	elseif questType == QuestConsts.Type_GodDynasty then	--诛仙阵  【道具】
		result = StrConfig['quest46'];
	elseif questType == QuestConsts.Type_BXDG then	--变形地宫  【道具】
		result = StrConfig['quest47'];
	elseif questType == QuestConsts.Type_SGZC then	--上古战场  【道具】
		result = StrConfig['quest48'];
	elseif questType == QuestConsts.Type_LieMo then --猎魔 或者 讨伐 【经验】
		result = StrConfig['quest49'];
	elseif questType == QuestConsts.Type_UnionJoin then --加入帮派 【帮派】
		result = StrConfig['quest50'];
	elseif questType == QuestConsts.Type_Makion then --牧野之战 【道具】
		result = StrConfig['quest51'];
	elseif questType == QuestConsts.Type_Arena then --竞技场 【荣誉】
		result = StrConfig['quest52'];
	elseif questType == QuestConsts.Type_Hang then --推荐挂机 【挂机】
		result = StrConfig['quest53'];
	end
	result = string.format("<font size='14' color='"..QuestColor.TITLE_TYPE_COLOR.."'>%s</font>", result);
	return result;
end

function QuestConsts:GetLvQuestRewardType(cfg)
	local exp    = cfg.expReward or 0
	if exp > 0 then
		return QuestConsts.Level_Reward_Exp;
	end
	local money  = cfg.moneyReward or 0
	if money > 0 then
		return QuestConsts.Level_Reward_Gold;
	end
	local zhenqi = cfg.zhenqiReward or 0
	if zhenqi > 0 then
		return QuestConsts.Level_Reward_ZhenQi;
	end
	local item = cfg.otherReward or ""
	if item ~= "" then
		return QuestConsts.Level_Reward_Item_Other;
	end
	return 0;
end
function QuestConsts:GetLvQuestRewardIconURL(cfg)
	local exp    = cfg.expReward or 0
	if exp > 0 then
		return "";
	end
	local money  = cfg.moneyReward or 0
	if money > 0 then
		return ResUtil:GetGoldSmallIcon();
	end
	local zhenqi = cfg.zhenqiReward or 0
	if zhenqi > 0 then
		return "";
	end
	local yuanbao = cfg.yuanbao_binding or 0
	if yuanbao > 0 then
		return ResUtil:GetMoneySmallIcon();
	end
	return "";
end
function QuestConsts:GetLvQuestRewardNumStr(cfg)
	local exp    = cfg.expReward or 0
	if exp > 0 then
		return cfg.expReward;
	end
	local money  = cfg.moneyReward or 0
	if money > 0 then
		return _G.getNumShow2(cfg.moneyReward);
	end
	local zhenqi = cfg.zhenqiReward or 0
	if zhenqi > 0 then
		return cfg.zhenqiReward;
	end
	local yuanbao = cfg.yuanbao_binding or 0
	if yuanbao > 0 then
		return _G.getNumShow2(cfg.yuanbao_binding);
	end
	return "";
end
--已经废弃
function QuestConsts:GetLvQuestTitleTypeLabel(lvQuestRewardType)
	local result = "";
	if lvQuestRewardType == QuestConsts.Level_Reward_Exp then
		result = StrConfig["quest60"];
	elseif lvQuestRewardType == QuestConsts.Level_Reward_Gold then
		result = StrConfig["quest61"];
	elseif lvQuestRewardType == QuestConsts.Level_Reward_ZhenQi then
		result = StrConfig["quest62"];
	elseif lvQuestRewardType == QuestConsts.Level_Reward_Item_Other then
		result = StrConfig["quest63"];
	end
	result = string.format("<font size='14' color='"..QuestColor.TITLE_TYPE_COLOR.."'>%s</font>", result);
	return result;
end

--根据任务ID获取其所属章节
function QuestConsts:GetChapter( questId )
	local cfg = t_quest[questId];
	return cfg and cfg.chapter
end

--获取章节任务总数
function QuestConsts:GetChapterQuestCount( chapterIndex )
	local count = 0;
	for questId, quest in pairs(t_quest) do
		if quest.chapter == chapterIndex then
			count = count + 1;
		end
	end
	return count;
end

--获取任务在其所属章节中是第几个
function QuestConsts:GetQuestIndex( questId )
	local cfg = t_quest[questId]
	return cfg and cfg.chapterIndex
end

--获取某章第一个任务id
function QuestConsts:GetChapter1stQuest(chapterIndex)
	for questId, questCfg in pairs(t_quest) do
		if questCfg.chapter == chapterIndex and questCfg.chapterIndex == 1 then
			return questId;
		end
	end
end

--日环单个任务奖励面板/暴击奖励面板 倒计时 s
QuestConsts.QuestDailyRewardCountDown = 15;

--日环抽奖转盘面板，*秒无操作自动抽取 倒计时 s
QuestConsts.QuestDailyDrawCountDown = 15;

--日环抽奖转盘面板, 滚动最小时间 s
QuestConsts.QuestDailyDrawRollTime = 2;

--日环抽奖转盘面板中“跳环”奖励的索引
QuestConsts.QuestDailyDrawSkipIndex = 4;

--一件完成奖励面板停留时间
QuestConsts.QuestDaily1KeyFinishCountDown = 15;

--任务装备提升面板停留时间
QuestConsts.QuestEquipCountDown = 5;

-- 日环任务状态
QuestConsts.QuestDailyStateNone = 0; --日环任务未开启
QuestConsts.QuestDailyStateGoing = 1; --进行中
QuestConsts.QuestDailyStateDrawing = 2; --抽奖中
QuestConsts.QuestDailyStateFinish = 3; --日环完成

-- 每日日环任务数
QuestConsts.QuestDailyNum = 20;
-- 日环抽奖转盘一圈摆多少个奖品
QuestConsts.QuestDailyDrawItemNum = 8;
-- 日环任务开放等级
local dqOpenLevel = nil
function QuestConsts:GetDQOpenLevel()
	if not dqOpenLevel then
		dqOpenLevel = _G.t_consts[42].val1
	end
	return dqOpenLevel
end
-- 日环任务最高星级
QuestConsts.QuestDailyMaxStar = 5;
-- 日环抽奖环数(numric increase)
QuestConsts.QuestDailyDrawRounds = {5, 10, 15, 20};

-- 日环一键完成单环花费 元宝
local oneKeyFinishCost;
function QuestConsts:Get1KeyFinishCost()
	if not oneKeyFinishCost then
		oneKeyFinishCost = t_consts[22].val1;
	end
	return oneKeyFinishCost;
end

-- 日环一键完成需vip等级
local oneKeyFinishVip;
function QuestConsts:Get1KeyFinishVip()
	if not oneKeyFinishVip then
		oneKeyFinishVip = t_consts[22].val2;
	end
	return oneKeyFinishVip;
end

-- 日环升星花费 银两
local addStarCost;
function QuestConsts:GetAddStarCost()
	if not addStarCost then
		addStarCost = t_consts[21].val1;
	end
	return addStarCost;
end

-- 日环任务自动升星VIP等级
local dqAutoStarVip;
function QuestConsts:GetDQAutoStarVip()
	if not dqAutoStarVip then
		dqAutoStarVip = t_consts[21].val2;
	end
	return dqAutoStarVip;
end

-- 日环加倍1领取所需银两数
-- local multiple2Cost;
function QuestConsts:GetMultiple2Cost(isNumShow)
	-- if not multiple2Cost then
		-- multiple2Cost = t_consts[42].val2;
	-- end
	local level = MainPlayerModel.humanDetailInfo.eaLevel
	local cfg = _G.t_dailygroup[level]
	local multiple2Cost = cfg and cfg.double_rewad or 0
	if isNumShow then
		return multiple2Cost;
	else
		return getNumShow(multiple2Cost);
	end
end

-- 日环加倍2领取所需元宝数
local multiple3Cost;
function QuestConsts:GetMultiple3Cost()
	if not multiple3Cost then
		multiple3Cost = t_consts[42].val3;
	end
	return multiple3Cost;
end

-- data structure : dqMultipleRewardMap[multipleType] = { multiple = multiple, label = label }
function QuestConsts:GetDQMultipleRewardMap()
	local dqMultipleRewardMap = {}
	local str = t_consts[74].param
	local table = split( str, "#" )
	for i = 1, #table do
		local multipleInfo = split( table[i], "," )
		local multipleType = i
		local multiple     = tonumber( multipleInfo[1] )
		local label        = ""
		if multipleType == 1 then
			label = StrConfig["quest504"]
		elseif multipleType == 2 then
			local url = ResUtil:GetMoneyIconURL( _G.enAttrType.eaUnBindGold )
			label = string.format( StrConfig["quest505"], multiple, QuestConsts:GetMultiple2Cost(), url )
		elseif multipleType == 3 then
			local url = ResUtil:GetMoneyIconURL( _G.enAttrType.eaUnBindMoney )--优先消耗绑元，然后再消耗元宝
			label = string.format( StrConfig["quest506"], 1.2, 10, url )
		end
		dqMultipleRewardMap[multipleType] = { multiple = multiple, label = label }
	end
	return dqMultipleRewardMap
end

-- 主线断档等级
local trunkBreakLevel;
function QuestConsts:GetTrunkBreakLevel()
	if not trunkBreakLevel then
		trunkBreakLevel = t_consts[43].val2;
	end
	return trunkBreakLevel;
end

-- 任务追踪最多显示成就任务个数
local maxAchievementQNum;
function QuestConsts:GetMaxAchievementQNum()
	if not maxAchievementQNum then
		maxAchievementQNum = t_consts[72].val1;
	end
	return maxAchievementQNum;
end

-- 是否屏蔽主线任务面板
QuestConsts.IsOpenTrunk = false;

-- 各种点击任务id
QuestConsts.MountLvlUpClick    = 1001057  -- 坐骑升阶
QuestConsts.EquipProductClick  = 1001058  -- 装备升品
QuestConsts.GetLingliClick     = 1001197  -- 收获灵力
QuestConsts.EquipRefinClick    = 1001198  -- 装备强化
QuestConsts.WuhunCoalesceClick = 1001199  -- 兽魄合体
QuestConsts.EquipBuildClick1   = 1001205  -- 装备打造1
QuestConsts.EquipBuildClick2   = 1001207  -- 装备打造2
QuestConsts.EquipBuildClick3   = 1001209  -- 装备打造3
QuestConsts.DominateRoadClick1 = 1001206  -- 主宰之路1
QuestConsts.DominateRoadClick2 = 1001208  -- 主宰之路2
QuestConsts.EnterCity = 1100020;--进主城的任务   --changer:houxudong date:2016/8/29 23:05  [1]
QuestConsts.EnterXSC = 1100001;--进新手村任务 [1]
QuestConsts.ExitDungeon = 1001086;--退出副本的任务
QuestConsts.EnterBH = 1001107;--进八荒的任务
QuestConsts.TransfoBuff    = 1100013  -- 变身任务
--------------------------------------------------------
--------------------------------------------------------
-- adder:houxudong
-- 兽魄副本任务id
QuestConsts.LastDungeonQuest = 1401001
QuestConsts.EnterWuhunDungeonQuest = 1401002   -- 进入兽魄副本任务questid  
QuestConsts.ExitWuhunDungeonQuest = 1401003    -- 退出兽魄副本任务questid 
-- 兽魄副本地图id
QuestConsts.WuhunDungeonMap = 11301002         -- 兽魄副本地图id


-- 第二个独立副本任务id
QuestConsts.LastDungeonQuestTwo = 1310001
QuestConsts.EnterDungeonQuestTwo = 1310002  
QuestConsts.ExitWuhunDungeonQuestTwo = 1310003  
-- 兽魄副本2地图id
QuestConsts.WuhunDungeonMapTwo = 11301003       


-- 第三个独立副本任务id
QuestConsts.LastDungeonQuestThree = 1410001
QuestConsts.EnterWuhunDungeonQuestThree = 1410002  
QuestConsts.ExitWuhunDungeonQuestThree = 1410003   
-- 兽魄副本3地图id
QuestConsts.WuhunDungeonMapThree = 11301005 


-- 第四个独立副本任务id
QuestConsts.LastDungeonQuestFour = 1410004
QuestConsts.EnterWuhunDungeonQuestFour = 1410005  
QuestConsts.ExitWuhunDungeonQuestFour = 1410006   
-- 兽魄副本4地图id
QuestConsts.WuhunDungeonMapFour = 11301006


-- 第五个独立副本任务id
QuestConsts.LastDungeonQuestFive = 1410007
QuestConsts.EnterWuhunDungeonQuestFive = 1410008  
QuestConsts.ExitWuhunDungeonQuestFive  = 1410009   
-- 兽魄副本5地图id
QuestConsts.WuhunDungeonMapFive = 11301004

--------------------------------------------------------
--------------------------------------------------------

--第一个任务
QuestConsts.FirstQuest = 1100001;

--获得兵魂的任务
QuestConsts.BingHunGet = 1001018;
--失去兵魂的任务
QuestConsts.BingHunUnGet = 1001109;

--[[ 2015年7月21日15:49:53
--飞行剧情后的任务
QuestConsts.FlyStunkQuest = 1001031
--飞行剧情下线上限卡住的position坐标
QuestConsts.FlyStunkPosition = 3009
--]]
