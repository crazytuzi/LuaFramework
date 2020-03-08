
Ui.tbRedPointSetting =
{
	BtnTopFold = {
		ItemBoxTop =  -- 主界面 背包红点 因为现在有2个主背包按钮
		{
			"ItemBox",
		},
		Calendar = -- 主界面 活动日历红点
		{
			["Calendar_Daily"] =
			{
				["RankBattle"] = {"RankBattle_FetchAward"},
				["ImperialTomb"] = {"ImperialTomb_FullTime"},
			},
			["Calendar_TimeLimit"] = {},
			["Calendar_EverydayTarget"] = {},
		},
		Activity_Login = {},
		Activity = -- 主界面 活动红点，按照Activity_SummerGift的形式（SummerGift为表中Key）填写
		{
			["Activity_SignInAwards"] 	= {"Act_Sign"},
			["Activity_GrowInvest"] = {},
			["Activity_MoneyTreePanel"] = {"MoneyTree_Free"},
			--["Activity_JuBaoPlate"] = {}, --聚宝盆
			["Activity_OnHook"] = {"OnHook_GetExp"},
			["Activity_WuXunMiLingpanel"] = {"SecretCard_GetAward"},
			["Activity_RechargeGift"] = {"DaysCard1", "DaysCard2", "DaysCard3"},--, "ShowBuyCardRed"},
			["Activity_DailyRechargeGift"] = {"DailyRechargeGift1", "DailyRechargeGift2"},
			"Activity_SupplementPanel",
			"Activity_SummerGift",
			"Activity_NewYearBuyGift",
			"Activity_BuyLevelUp",
			"Activity_PresentBoxPanel",

		},
		KinAuctionRedPoint = {},
		RealNameAuth = {},
		ExpUpRedPoint = {};
		MarketStallTab = {"MarketStallMine"},
		--GameCommunity = {"Restaurant", "QQBuluo", "WxCircle", "XinyueVip", "MicroMainPage", "XMFacebook", "SuperVip", "InviteNew"},
		GameCommunity = {};
		Activity_WLDH = {};
		PandoraPlayerSpace = {};
		PandoraGoodVoice ={};
		Anniversary = { "NewYearLoginAct", "AnniversaryQAAct"};
		PlayerRegression = {};
		BtnRecovery = {};
	},

	BtnTopFold_Battle = {
		"ItemBox_Battle",
	},

	BtnFold = {
		Shop =
		{
			["RechargeTab"] = {
				["VipAward"] = {
					"VipAward0",
					"VipAward1","VipAward2","VipAward3","VipAward4","VipAward5",
					"VipAward6","VipAward7","VipAward8","VipAward9","VipAward10",
					"VipAward11","VipAward12","VipAward13","VipAward14","VipAward15","VipAward16",
				},
			},
			["CommonShopTab"] = {};
		},

		HonorLevel =
		{
			"TitleUpgrade",
		},

		Skill = -- 主界面 技能红点
		{
			["SkillPublicRed"] = { "SkillPublicBook1", "SkillPublicBook2", "SkillPublicBook3", "SkillPublicBook4"},
			["Skill_ZhenFa"] = {},
			["Skill_JueXue"] = { "JueXueBookRP1", "JueXueBookRP2", "JueXueBookRP3", "JueXueBookRP4", "JueXueBookRP5",
								"Skill_JueXue_Item_JX", "Skill_JueXue_Item_DP", "Skill_JueXue_Item_MB"},
		},

		Partner =
		{
			["PartnerMainPanel"] = {},
			["PartnerGralleryPanel"] = {"PartnerExtAttrib"},
			["PartnerCardPickPanel"] = {},
			["PartnerCardPanel"] = {"TabRedPoint1", "TabRedPoint2", "TabRedPoint3", "TabRedPoint4"},
		},

		Relation = -- 主界面 社交红点
		{
			["Friend"] =
			{
				"Friend_Request",
			},
			["Enemy"] = {"Wanted"},
			["TeacherStudent"] = {"TS_Applylist", "TS_Teacher1", "TS_Teacher2", "TS_Report",},
		},

		KinTopButton = {
			["KinBuilding"] = {
				["KinGiftBoxRedPoint"] = {"KinGiftGain"},
				["KinStoreRedPoint"]   = {},
			},
			["KinTabMember"] = {
				"KinRedBagNotify",
			},
		},
	},

	RoleHead = --主界面上的角色头像
	{
		"Achievement_Btn",
		"BindingTXPhone",
	},

	ChatSetting =
	{
		Theme = {},
		ChatSettingDetail = {"ChatNamePrefix"},
	},

	CalendarGuide =					-- 日历提示引导
	{
		"NG_Boss",					--武林盟主20级
		"NG_CommerceTask",			--商会任务30级
		"NG_Battle",				--宋金战场31级
		"NG_CangBaoTu",				--藏宝图12级
		"NG_PunishTask",			--惩恶任务20级
		"NG_TeamFuben",				--组队秘境20级
		"NG_ExplorationFuben",		--关卡探索19级
		"NG_Rank",					--武神殿16级
		"NG_RandomFuben",			--凌绝峰30级
		"NG_FieldBoss",				--历代名将40级
		"NG_FieldLeader",			--野外首领20级
		"NG_ActivityQuestion",		--每日答题11级
		"NG_ChuanGong",				--传功30级
		"NG_KinGather",				--家族篝火15级
		"NG_AdventureFuben",		--山贼秘窟13级
		"NG_HeroChallenge",			--英雄挑战21级
		"NG_KinBattle",				--家族战40级
		"NG_WhiteTigerFuben",		--白虎堂40级
		"NG_TeamBattle",			--通天塔40级
		"NG_FactionBattle",			--门派竞技40级
		"NG_KinEscort",				--家族运镖40级
		"NG_XiuLian",				--野外修炼22级
		-- "NG_KinFuben",				--家族试练20级
		"NG_SeriesFuben",			--江湖试练20级
		"NG_ImperialTomb",			--秦始皇陵80级
		"NG_ImperialTombEmperor",	--始皇降世80级
		"NG_InDifferBattle",		--心魔幻境60级

		NG_EverydayTarget = {
			"NG_EverydayTarget_First",
			"NG_EverydayTarget_Preview",
		},	--每日目标
	},
	ActivityGuide = 	-- 活动提示引导
	{
		"NG_MoneyTreePanel",			--摇钱树10级
		"NG_SignInAwards",				--累计签到9级
		"NG_GrowInvest",				--一本万利23级
		"NG_RechargeGift",				--周月卡
		"NG_DailyRechargeGift",			--每日礼包
	},
	NG_ZhuangXiu = 	-- 装修引导
	{
	},
	KinGuide =
	{
		NG_KinJoin = {},
		NG_Kin =
		{
			NG_KinBuilding =
			{
				NG_ZhuDian = {"NG_KinBuildUpgrade"}
			}
		},
	},
	NG_PkMode =
	{
	},
	FubenGuide =
	{
		"NG_Jingying",
	},
	MiniMapGuide =
	{
		"NG_WorldMap",
	},
	HouseGuide = {
		"NG_BtnHome",
	},	--家园
	PartnerGuide =
	{
		FreePickGuide = {"NG_PickCard"},
		NG_Partner = {},
		NG_PartnerCardTab = {},
	},
	SkillGuide =
	{
		"NG_SkillUpGrade",
	},
	AutoFightGuide =
	{
		"NG_AutoFightSettingGuide",
		"NG_AutoFightGuide",
	},
	RelationGuide =
	{
		"NG_Enemy",
	},

	Fuben =
	{
		"Main_1_1", "Main_1_2", "Main_1_3", "Main_1_4", "Main_1_5", "Main_1_6",
		"Main_2_1", "Main_2_2", "Main_2_3", "Main_2_4", "Main_2_5", "Main_2_6",
	},

	TeamNewApplyer = {"TeamNewApplyer"},
	MyAuction = {"MyAuction"},
	TeamNewInvitor = {"TeamNewInvitor"},
	TeamBtnNew = {"TeamBtnNew"},
	KinTabMember2 = {"KinMemberRedPoint"},

	NG_MountGuide =
	{
	},
	ChanfeName =
	{
		"ChanfeNameInfo",
		"NG_BindingMailGuideAndroid",
		"BtnHomepageMy",

	},
	Task =
	{
		"ValueCompose",
	},
	Feedback =
	{
	},
	IndifferMapRed =
	{
	},

	House =
	{
		Room =
		{
			"Muse",
			"Pray",
		}
	},

	RoomerHouse =
	{
		Room =
		{
			"Muse",
			"Pray",
		}
	},

	PlantHelpCure =
	{
	},

	PlantHelpCure_Land =
	{
	},

	Wedding_BtnInvitation =
	{
		"Wedding_ApplyWelcome";
	},
	ItemBox_HomeScreeFuben =
	{

	},
	QYHCross_Main =
	{
		"QYHCross_GetWin";
		"QYHCross_GetJoin";
	},

	PandoraPlayerSpaceGuide = {

	},

	FurnitureMake = {},
	LingTuZhan = {
		"LingTuZhanCityMaster";
	};
}

function Ui:InitRedPointTree()
	self.tbRedPoint = {}
	for szPoint, tbNode in pairs(self.tbRedPointSetting) do
		self:InitRedPointNode(szPoint, tbNode)
	end
end

function Ui:InitRedPointNode(szPoint, tbNode, szParent)
	self.tbRedPoint[szPoint] = self.tbRedPoint[szPoint] or { bActive = false, nChildrenActive = 0 }
	if szParent then
		self.tbRedPoint[szPoint].tbParent = self.tbRedPoint[szPoint].tbParent or {};
		table.insert(self.tbRedPoint[szPoint].tbParent, szParent)
	end
	if type(tbNode) ~= "table" then
		return;
	end
	for varKey, varValue in pairs(tbNode) do
		if type(varValue) == "string" then
			self:InitRedPointNode(varValue, nil, szPoint)
		elseif type(varValue) == "table" then
			self:InitRedPointNode(varKey, varValue, szPoint)
		end
	end
end
Ui:InitRedPointTree()

function Ui.RegisterRedPoint(nRedPoinId, szPoint)
	if Ui.tbRedPoint[szPoint] then
		if Ui.tbRedPoint[szPoint].nRedPoinId then --防止ui prefab 里同样的红点名重复注册,动态注册的则注册前手动反注册
			Log(szPoint, debug.traceback())
		end
		Ui.tbRedPoint[szPoint].nRedPoinId = nRedPoinId;
		Ui:CheckRedPoint(szPoint);
	else
		Ui.UiManager.SetRedPointActive(nRedPoinId, false);
	end
end

function Ui.UnRegisterRedPoint(szPoint)
	if Ui.tbRedPoint[szPoint] then
		Ui.tbRedPoint[szPoint].nRedPoinId = nil;
	end
end

function Ui:CheckRedPoint(szPoint)
	if self.tbRedPoint[szPoint] and self.tbRedPoint[szPoint].nRedPoinId then
		Ui.UiManager.SetRedPointActive(self.tbRedPoint[szPoint].nRedPoinId, self.tbRedPoint[szPoint].bActive);
	end
end

function Ui:SetRedPointNotify(szPoint, bChildrenNotice)
	if self.tbRedPoint[szPoint] then
		if bChildrenNotice then
			self.tbRedPoint[szPoint].nChildrenActive = self.tbRedPoint[szPoint].nChildrenActive + 1
		end
		if self.tbRedPoint[szPoint].bActive ~= true then
			self.tbRedPoint[szPoint].bActive = true;
			self:CheckRedPoint(szPoint);
			for _, szParent in ipairs(self.tbRedPoint[szPoint].tbParent or {}) do
				self:SetRedPointNotify(szParent, true);
			end
		end
	end
end

function Ui:ClearRedPointNotify(szPoint, bChildrenNotice)
	if self.tbRedPoint[szPoint] then
		if bChildrenNotice then
			self.tbRedPoint[szPoint].nChildrenActive = math.max(0, self.tbRedPoint[szPoint].nChildrenActive - 1)
			if self.tbRedPoint[szPoint].nChildrenActive > 0 then	-- 还有子节点亮着
				return;
			end
		end
		if self.tbRedPoint[szPoint].bActive ~= false then
			self.tbRedPoint[szPoint].bActive = false;
			self:CheckRedPoint(szPoint);
			for _, szParent in ipairs(self.tbRedPoint[szPoint].tbParent or {}) do
				self:ClearRedPointNotify(szParent, true);
			end
		end
		Sdk:ClearCommunityRedPoint(szPoint);
	end
end

function Ui:GetRedPointState(szPoint)
	if self.tbRedPoint[szPoint] then
		return self.tbRedPoint[szPoint].bActive;
	end
end

