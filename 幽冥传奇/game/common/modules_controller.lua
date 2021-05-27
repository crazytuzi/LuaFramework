
ModulesController = ModulesController or BaseClass()

function ModulesController:__init()
	if ModulesController.Instance ~= nil then
		ErrorLog("[ModulesController] attempt to create singleton twice!")
		return
	end
	ModulesController.Instance = self

	self.objects_list = {}
	self.ctrl_list = {}

	self:CreateObjects()
	self:CreateControllers()

	LoginController.Instance:StartLogin()			-- 登录
end

function ModulesController:__delete()
	self:DeleteControllers()
	self:DeleteObjects()

	ModulesController.Instance = nil
end

function ModulesController:GetCtrlList()
	return self.ctrl_list
end

function ModulesController:CreateObjects()
	table.insert(self.objects_list, GameVoManager.New())
	table.insert(self.objects_list, ViewManager.New())
	table.insert(self.objects_list, AvatarManager.New())
	table.insert(self.objects_list, UiInstanceMgr.New())
	table.insert(self.objects_list,	RemindManager.New())
end

-- 必须是继承自BaseController的才可以插入到self.ctrl_list
function ModulesController:CreateControllers()
	table.insert(self.ctrl_list, PerloadCtrl.New())
	table.insert(self.ctrl_list, TimeCtrl.New())
	table.insert(self.ctrl_list, ClientCmdCtrl.New())
	table.insert(self.ctrl_list, LoginController.New())
	table.insert(self.ctrl_list, RoleCtrl.New())
	table.insert(self.ctrl_list, BagCtrl.New())
	table.insert(self.ctrl_list, TaskCtrl.New())
	table.insert(self.ctrl_list, GuideCtrl.New())
	table.insert(self.ctrl_list, Scene.New())
	table.insert(self.ctrl_list, MainuiCtrl.New())
	table.insert(self.ctrl_list, OtherCtrl.New())
	table.insert(self.ctrl_list, SysMsgCtrl.New())
	table.insert(self.ctrl_list, TipsCtrl.New())
	table.insert(self.ctrl_list, BrowseCtrl.New())
	table.insert(self.ctrl_list, HelpCtrl.New())
	table.insert(self.ctrl_list, TitleCtrl.New())
	table.insert(self.ctrl_list, EquipmentCtrl.New())
	table.insert(self.ctrl_list, WingCtrl.New())
	table.insert(self.ctrl_list, SkillCtrl.New())
	table.insert(self.ctrl_list, ZhuangShengCtrl.New())
	table.insert(self.ctrl_list, RoleCycleCtrl.New())
	table.insert(self.ctrl_list, InnerCtrl.New())
	table.insert(self.ctrl_list, ChatCtrl.New())
	table.insert(self.ctrl_list, SocietyCtrl.New())
	table.insert(self.ctrl_list, TeamCtrl.New())
	table.insert(self.ctrl_list, AchieveCtrl.New())
	table.insert(self.ctrl_list, SettingCtrl.New())
	table.insert(self.ctrl_list, SettingProtectCtrl.New())
	table.insert(self.ctrl_list, FightCtrl.New())
	table.insert(self.ctrl_list, FuhuoCtrl.New())
	table.insert(self.ctrl_list, MapCtrl.New())
	table.insert(self.ctrl_list, BossCtrl.New())
	table.insert(self.ctrl_list, StrenfthFbCtrl.New())
	table.insert(self.ctrl_list, ZhanjiangCtrl.New())
	table.insert(self.ctrl_list, ComposeCtrl.New())
	
	table.insert(self.ctrl_list, MovieGuideCtrl.New())
	table.insert(self.ctrl_list, ShopCtrl.New())
	table.insert(self.ctrl_list, ExploreCtrl.New())	
	table.insert(self.ctrl_list, MailCtrl.New())	
	table.insert(self.ctrl_list, WelfareCtrl.New())
	table.insert(self.ctrl_list, ActivityCtrl.New())
	table.insert(self.ctrl_list, VipCtrl.New())
	table.insert(self.ctrl_list, GuildCtrl.New())
	table.insert(self.ctrl_list, WorshipCtrl.New())
	table.insert(self.ctrl_list, WangChengZhengBaCtrl.New())
	table.insert(self.ctrl_list, JiFenEquipmentCtrl.New())
	table.insert(self.ctrl_list, ChargeFirstCtrl.New())
	table.insert(self.ctrl_list, ConsignCtrl.New())
	table.insert(self.ctrl_list, RefiningExpCtrl.New())
	table.insert(self.ctrl_list, OpenServiceAcitivityCtrl.New())
	table.insert(self.ctrl_list, ActiveDegreeCtrl.New())
	table.insert(self.ctrl_list, RankingListCtrl.New())
	table.insert(self.ctrl_list, EscortCtrl.New())
	table.insert(self.ctrl_list, ExchangeCtrl.New())
	table.insert(self.ctrl_list, FubenCtrl.New())
	table.insert(self.ctrl_list, PrayCtrl.New())
	table.insert(self.ctrl_list, ChellengeKBossCtrl.New())
	table.insert(self.ctrl_list, HeroGoldBingCtrl.New())
	table.insert(self.ctrl_list, HeroGoldDunCtrl.New())
	table.insert(self.ctrl_list, ChangeJobCtrl.New()) 
	table.insert(self.ctrl_list, CarnivarCtrl.New())  
	table.insert(self.ctrl_list, ExploitCtrl.New())
	table.insert(self.ctrl_list, FoMoCtrl.New())
	-- table.insert(self.ctrl_list, ChargeEveryDayCtrl.New())
	table.insert(self.ctrl_list, LimitDailyChargeCtrl.New())
	-- table.insert(self.ctrl_list, LimitedActivityCtrl.New())
	table.insert(self.ctrl_list, ChargePlatFormCtrl.New())
	-- table.insert(self.ctrl_list, InvestPlanCtrl.New())
	table.insert(self.ctrl_list, OperateActivityCtrl.New())
	table.insert(self.ctrl_list, CombineServerCtrl.New())
	table.insert(self.ctrl_list, FeedbackCtrl.New())
	table.insert(self.ctrl_list, SuperVipCtrl.New())
	table.insert(self.ctrl_list, MagicCityCtrl.New())
	table.insert(self.ctrl_list, ExtremeVipCtrl.New())
	table.insert(self.ctrl_list, CompleteBagCtrl.New())
	table.insert(self.ctrl_list, DesertKillGodCtrl.New())
	table.insert(self.ctrl_list, BossBattleCtrl.New())
	table.insert(self.ctrl_list, RedPackageCtrl.New())
	table.insert(self.ctrl_list, CityPoolFightCtrl.New())
	table.insert(self.ctrl_list, FashionCtrl.New())
	table.insert(self.ctrl_list, GemStoneCtrl.New())
	table.insert(self.ctrl_list, PrivilegeCtrl.New())
	table.insert(self.ctrl_list, BossSportCtrl.New())
	table.insert(self.ctrl_list, VipBossCtrl.New())
	table.insert(self.ctrl_list, WanShouMoPuCtrl.New())
	table.insert(self.ctrl_list, KnightCtrl.New())
	table.insert(self.ctrl_list, OpenSerRaceStandardCtrl.New())
	table.insert(self.ctrl_list, BabelCtrl.New())
	table.insert(self.ctrl_list, HeroWingCtrl.New())
	table.insert(self.ctrl_list, RecycleYBCtrl.New())
	table.insert(self.ctrl_list, CrossServerMatchCtrl.New())
	table.insert(self.ctrl_list, CrossEatChickenCtrl.New())
	table.insert(self.ctrl_list, SupplyContentionAwardCtrl.New())
	table.insert(self.ctrl_list, SupplyContentionScoreCtrl.New())
	table.insert(self.ctrl_list, BossXuanShangCtrl.New())
	table.insert(self.ctrl_list, GuanggaoCtrl.New())
	table.insert(self.ctrl_list, GodWeaponExtremeCtrl.New())
	table.insert(self.ctrl_list, ChargeFashionCtrl.New())
	table.insert(self.ctrl_list, SuperMeVipCtrl.New())
	table.insert(self.ctrl_list, SuperAfterVipCtrl.New())
end

function ModulesController:DeleteObjects()
	local count = #self.objects_list
	for i = count, 1, -1 do
		self.objects_list[i]:DeleteMe()
	end
	self.objects_list = {}
end

function ModulesController:DeleteControllers()
	local count = #self.ctrl_list
	for i = count, 1, -1 do
		self.ctrl_list[i]:DeleteMe()
	end
	self.ctrl_list = {}
end
