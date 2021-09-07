ModulesController = ModulesController or BaseClass()

function ModulesController:__init(is_quick_login)
	if ModulesController.Instance ~= nil then
		print_error("[ModulesController] attempt to create singleton twice!")
		return
	end
	ModulesController.Instance = self

	self:CreateCoreModule()
	self.is_quick_login = is_quick_login
	if not is_quick_login then
		self:CreateLoginModule()
	end

	self.ctrl_list = {}
	self.push_list = {}
	self.cur_index = 0

	if is_quick_login then
		self:Start()
		for k,v in ipairs(self.push_list) do
			table.insert(self.ctrl_list, v.New())
		end
	end
end

function ModulesController:__delete()
	self:DeleteLoginModule()
	self:DeleteGameModule()

	ClientCmdCtrl.Instance:DeleteMe()
	TimeCtrl.Instance:DeleteMe()
	ChatRecordMgr.Instance:DeleteMe()
	AudioService.Instance:DeleteMe()
	LoadingPriorityManager.Instance:DeleteMe()
	AvatarManager.Instance:DeleteMe()
	RemindManager.Instance:DeleteMe()
	ViewManager.Instance:DeleteMe()
	GameVoManager.Instance:DeleteMe()

	ModulesController.Instance = nil
	self.state_callback = nil
end

function ModulesController:Start(call_back)
	self.state_callback = call_back
	self.ctrl_list = {}
	self.cur_index = 0
	-- 把需要创建的Ctrl加在这里
	self.push_list = {
		SettingCtrl,
		Scene,
		PrefabPreload,
		QueueLoader,
		RenderBudget,
		SysMsgCtrl,
		OtherCtrl,
		GuideCtrl,
		TipsCtrl,
		FightCtrl,
		GuajiCtrl,
		StoryCtrl,
		TaskCtrl,
		PackageCtrl,
		PlayerCtrl,
		MojieCtrl,
		MainUICtrl,
		UpdateAfficheCtrl,
		ActivityCtrl,
		BossCtrl,
		ChatCtrl,
		CoolChatCtrl,
		AutoVoiceCtrl,
		HongBaoCtrl,
		BaoJuCtrl,
		FashionCtrl,
		WingCtrl,
		TitleCtrl,
		SkillCtrl,
		ExchangeCtrl,
		SpiritCtrl,
		ForgeCtrl,
		KuaFuXiuLuoTowerCtrl,
		KuaFuMiningCtrl,
		KuafuGuildBattleCtrl,
		GoddessCtrl,
		WelfareCtrl,
		AchieveCtrl,
		ZhiBaoCtrl,
		MedalCtrl,
		AdvanceCtrl,
		CampCtrl,
		PlayPawnCtrl,
		MountCtrl,
		MountHuanHuaCtrl,
		BeautyHaloHuanHuaCtrl,
		HalidomHuanHuaCtrl,
		GuildCtrl,
		MarketCtrl,
		MarriageCtrl,
		BaobaoCtrl,
		WingHuanHuaCtrl,
		RankCtrl,
		FuBenCtrl,
		HaloCtrl,
		HaloHuanHuaCtrl,
		ScoietyCtrl,
		TreasureBowlCtrl,

		ShengongCtrl,
		CityCombatCtrl,
		ShengongHuanHuaCtrl,
		ShenyiCtrl,
		ShenyiHuanHuaCtrl,
		BeautyHaloCtrl,
		HalidomCtrl,
		CheckCtrl,
		ComposeCtrl,
		LeiJiRechargeCtrl,
		FreeGiftCtrl,

		GuildFightCtrl,
		ClashTerritoryCtrl,
		ElementBattleCtrl,
		DaFuHaoCtrl,
		ShopCtrl,
		TreasureCtrl,
		TipsTriggerCtrl,
		TradeCtrl,
		MapCtrl,
		ReviveCtrl,
		VipCtrl,
		KuaFu1v1Ctrl,
		CrossCrystalCtrl,
		CrossServerCtrl,
		GoPawnCtrl,
		HelperCtrl,
		YunbiaoCtrl,
		DayCounterCtrl,
		SkyMoneyCtrl,
		FlowersCtrl,
		AncientRelicsCtrl,
		ZhuaGuiCtrl,
		KaifuActivityCtrl,
		HefuActivityCtrl,
		SecretrShopCtrl,
		HotStringChatCtrl,
		SevenLoginGiftCtrl,
		RebateCtrl,
		InvestCtrl,
		DailyTaskFbCtrl,
		TombExploreCtrl,
		FirstChargeCtrl,
		MoLongCtrl,
		GuildBonfireCtrl,
		GuildMijingCtrl,
		HuashenCtrl,
		ZhuanShengCtrl,
		FightMountCtrl,
		ReincarnationCtrl,
		OpenFunCtrl,
		FightMountHuanHuaCtrl,
		ExpresionFuBenCtrl,
		WelcomeCtrl,
		MolongMibaoCtrl,
		TempMountCtrl,
		MarryMeCtrl,
		CompetitionActivityCtrl,
		PersonalGoalsCtrl,
		RuneCtrl,
		GuaJiTaCtrl,
		RandSystemCtrl,
		ShenBingCtrl,
		ShenGeCtrl,
		RelicCtrl,
		HunQiCtrl,
		ShengXiaoCtrl,
		MiJiComposeCtrl,
		LeiJiRDailyCtrl,
		WarReportCtrl,
		MilitaryRankCtrl,
		NationalWarfareCtrl,
		BeautyCtrl,
		PlayerForgeCtrl,
		FishingCtrl,
		FamousGeneralCtrl,
		KaiFuChargeCtrl,
		HappyBargainCtrl,
		QiXiActivityCtrl,
		KillTipCtrl,
		RoleSkillCtrl,
		ShenqiCtrl,
		RechargeCtrl,
		DailyChargeCtrl,
		CallCtrl,
		WorldQuestionCtrl,
		FaZhenCtrl,
		FaZhenHuanHuaCtrl,
		MiningController,
		RollingBarrageCtrl,
		RedEquipCtrl,
		LuckyDrawCtrl,
		TimeLimitSaleCtrl,
		SingleRechargeCtrl,
		DeitySuitCtrl,
		DiMaiCtrl,
		AdvanceSkillCtrl,
		TouXianCtrl,
		RoyalTombCtrl,
		MultiMountCtrl,
		DressUpCtrl,
		HeadwearCtrl,
		HeadwearHuanHuaCtrl,
		MaskCtrl,
		MaskHuanHuaCtrl,
		WaistCtrl,
		WaistHuanHuaCtrl,
		BeadCtrl,
		BeadHuanHuaCtrl,
		FaBaoCtrl,
		FaBaoHuanHuaCtrl,
		KirinArmCtrl,
		KirinArmHuanHuaCtrl,
		LittlePetCtrl,
		PetCtrl,
		SuperVipCtrl,
		SymbolCtrl,
		TeamFbCtrl,
		

		-- 随机活动专用
		ServerActivityCtrl,
		ActiviteHongBaoCtrl,
		GoldMemberCtrl,
		DisCountCtrl,
		ExpRefineCtrl,
		CollectiveGoalsCtrl,
		JuBaoPenCtrl,
		FastChargingCtrl,
		JinYinTaCtrl,
		RechargeRankCtrl,
		TreasureLoftCtrl,
		IncreaseSuperiorCtrl,
		RechargeCapacityCtrl,
		RepeatRechargeCtrl,
		ZhuanZhuanLeCtrl,
		LuckyBoxCtrl,
		DaSheTianXiaCtrl,
		LuckyChessCtrl,
		LuckyTurnEggCtrl,
		JuHuaSuanCtrl,
		HuanzhuangShopCtrl,
		IncreaseCapabilityCtrl,
		FanFanZhuanCtrl,
		GoldHuntCtrl,
		RareDialCtrl,
		MapFindCtrl,
		BuffProgressCtrl,
		LuckyTurntableCtrl,
		MoonLightLandingCtrl,
		SendFlowerCtrl,
		GodDropGiftCtrl,
		DressShopCtrl,
		LianFuDailyCtrl,
		KuaFuFlowerRankCtrl,
		QiXiMarriageCtrl,
		BrothelCtrl,
		RebirthCtrl,
		HonourCtrl,
		SupremacyCtrl,
		TipsAchieveCfgLevelCtrl,
		AdventureShopCtrl,
		TallPriceLotteryCtrl,
		RareTreasureCtrl,
		MoonGiftCtrl, 
		MidAutumnLotteryCtrl,  
		MidAutumnTaskCtrl,
		MidAutumnExchangeCtrl, 
		MuseumCardCtrl,
		DiedMailCtrl,
		CupMoonActivityCtrl,
		ActSpecialRebateCtrl,
	}
	if not self.is_quick_login then
		PushCtrl(self)
	end
end

function ModulesController:Update(now_time, elapse_time)
	local total_count = #self.push_list
	for i = 1, 12 do
		if self.cur_index < total_count then
			self.cur_index = self.cur_index + 1
			table.insert(self.ctrl_list, self.push_list[self.cur_index].New())
		end
		if self.cur_index >= total_count then
			PopCtrl(self)
			break
		end
	end

	if self.state_callback then
		self.state_callback(self.cur_index / total_count)
	end
end

function ModulesController:Stop()

end

function ModulesController:CreateCoreModule()
	GameVoManager.New()
	ViewManager.New()
	RemindManager.New()
	AvatarManager.New()
	LoadingPriorityManager.New()
	AudioService.New()
	ChatRecordMgr.New()
	TimeCtrl.New()
	ClientCmdCtrl.New()
end

function ModulesController:CreateLoginModule()
	LoginCtrl.New()
end

function ModulesController:CreateGameModule()
	for k, v in pairs(self.push_list) do
		if nil == v.Instance then
			table.insert(self.ctrl_list, v.New())
		end
	end
end

function ModulesController:DeleteLoginModule()
	if nil ~= LoginCtrl.Instance then
		LoginCtrl.Instance:DeleteMe()
	end
end

function ModulesController:DeleteGameModule()
	local count = #self.ctrl_list
	for i = count, 1, -1 do
		self.ctrl_list[i]:DeleteMe()
	end
	self.ctrl_list = {}
end
