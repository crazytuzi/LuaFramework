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
		MainUICtrl,
		ActivityCtrl,
		BossCtrl,
		ChatCtrl,
		CoolChatCtrl,
		AutoVoiceCtrl,
		HongBaoCtrl,
		PlayPawnCtrl,
		BaoJuCtrl,
		FashionCtrl,
		WingCtrl,
		FootCtrl,
		FootHuanHuaCtrl,
		TitleCtrl,
		SkillCtrl,
		MojieCtrl,
		ExchangeCtrl,
		ForgeCtrl,
		KuaFuXiuLuoTowerCtrl,
		GoddessCtrl,
		WelfareCtrl,
		AchieveCtrl,
		ArenaCtrl,
		ZhiBaoCtrl,
		MedalCtrl,
		AdvanceCtrl,
		CampCtrl,
		MountCtrl,
		MountHuanHuaCtrl,
		GuildCtrl,
		GoddessHuanHuaCtrl,
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
		CheckCtrl,
		ComposeCtrl,
		LeiJiRechargeCtrl,
		FreeGiftCtrl,
		FriendExpBottleCtrl,
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
		SpiritCtrl,
		RechargeCtrl,
		VipCtrl,
		KuaFu1v1Ctrl,
		CrossCrystalCtrl,
		CrossServerCtrl,
		YunbiaoCtrl,
		JingHuaHuSongCtrl,
		DayCounterCtrl,
		SkyMoneyCtrl,
		FlowersCtrl,
		FlowerRemindCtrl,
		AncientRelicsCtrl,
		ZhuaGuiCtrl,
		KaifuActivityCtrl,
		HotStringChatCtrl,
		ClothespressCtrl,
		LoginGift7Ctrl,
		DailyChargeCtrl,
		RebateCtrl,
		InvestCtrl,
		DailyTaskFbCtrl,
		MarryGiftCtrl,
		TombExploreCtrl,
		FirstChargeCtrl,
		GoddessShouhuCtrl,
		GuildBonfireCtrl,
		GuildMijingCtrl,
		HuashenCtrl,
		ZhuanShengCtrl,
		FightMountCtrl,
		ReincarnationCtrl,
		HpBagCtrl,
		FightMountHuanHuaCtrl,
		ExpresionFuBenCtrl,
		WelcomeCtrl,
		TianshenhutiCtrl,
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
		ShenGeAdvanceCtrl,
		WaBaoCtrl,
		CardCtrl,
		RelicCtrl,
		HunQiCtrl,
		LianhunCtrl,
		PuzzleCtrl,
		XianzunkaCtrl,
		ShengXiaoCtrl,
		JinJieRewardCtrl,
		MiJiComposeCtrl,
		LeiJiRDailyCtrl,
		ConsumeDiscountCtrl,
		RollingBarrageCtrl,
		KillRoleCtrl,
		GoldHuntCtrl,
		TouxianCtrl,
		YewaiGuajiCtrl,
		CongratulationCtrl,
		MarryNoticeCtrl,
		YuLeCtrl,
		ScreenShotCtrl,
		ShenShouCtrl,
		CloakCtrl,
		LingChongCtrl,
		IllustratedHandbookCtrl,
		CloakHuanHuaCtrl,
		TeamFbCtrl,
		RedNameCtrl,
		HappyHitEggCtrl,
		KuaFuMiningCtrl,
		FishingCtrl,
		--KuaFuTuanZhanCtrl,
		RedEquipCtrl,

		--外观
		AppearanceCtrl,
		MultiMountCtrl,
		WaistCtrl,
		TouShiCtrl,
		QilinBiCtrl,
		MaskCtrl,
		LingZhuCtrl,
		XianBaoCtrl,
		LingGongCtrl,
		LingQiCtrl,

		--封神殿
		GodTempleCtrl,
		GodTemplePataCtrl,
		GodTempleShenQiCtrl,

		-- 随机活动专用
		ServerActivityCtrl,
		ActiviteHongBaoCtrl,
		RechargeRankCtrl,
		LimitedFeedbackCtrl,
		JuHuaSuanCtrl,
		FastChargingCtrl,
		GoldMemberCtrl,
		DisCountCtrl,
		ExpRefineCtrl,
		CollectiveGoalsCtrl,
		JuBaoPenCtrl,
		YiZhanDaoDiCtrl,
		WorldQuestionCtrl,
		TreasureLoftCtrl,
		TreasureBusinessmanCtrl,
		FanFanZhuanCtrl,
		RepeatRechargeCtrl,
		MiningController,
		JinYinTaCtrl,
		HefuActivityCtrl,
		ZhuanZhuanLeCtrl,
		SingleRechargeCtrl,
		TimeLimitSaleCtrl,
		LuckyChessCtrl,
		LuckyDrawCtrl,
		IncreaseSuperiorCtrl,
		IncreaseCapabilityCtrl,
		RechargeCapacityCtrl,
		HappyRechargeCtrl,
		ImageFuLingCtrl,
		BlackMarketCtrl,
		ThreePieceCtrl,
		MapFindCtrl,
		LongXingCtrl,
		RareDialCtrl,
		EquipmentShenCtrl,
		KuafuGuildBattleCtrl,
		TulongEquipCtrl,
		HuanzhuangShopCtrl,
		KuaFuChongZhiRankCtrl,
		TimeLimitGiftCtrl,
		LittlePetCtrl,
		LoopChargeCtrl,
		FamousGeneralCtrl,
		SecretTreasureHuntingCtrl,
		ShenqiCtrl,
		KaiFuDegreeRewardsCtrl,
		HappyErnieCtrl,
		SecretrShopCtrl,
		FestivalActivityBianShenCtrl,

		SlaughterDevilCtrl,

		CrazyMoneyTreeCtrl,
		SingleRebateCtrl,

		ResetDoubleChongzhiCtrl,
		ScratchTicketCtr,
        ConsumeRewardCtrl,
        RechargeReturnRewardCtrl,

		ConsunmForGiftCtrl,
		BuyOneGetOneCtrl,

		TimeLimitBigGiftCtrl,
		TianShenGraveCtrl,

		OneYuanSnatchCtrl,
		--版本活动
		FestivalActivityCtrl,
		FestivalHappyErnieActivityCtrl,
		FestivalActivityQiQiuCtrl,

		--单笔充值
		ActivityOnLineCtrl,
		KuanHuanActivityPanelDanBiChongZhiCtrl,
		KuanHuanActivityTotalChargeCtrl,
		ActivityPanelLoginRewardCtrl, 					--登录有礼
        LandingRewardCtrl,                               --登陆奖励
        CrazyGiftCtrl,                                  --疯狂礼包
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
			if nil ~= self.push_list[self.cur_index] then
				table.insert(self.ctrl_list, self.push_list[self.cur_index].New())
			end
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
	GVoiceManager.New()
	TimeCtrl.New()
	ClientCmdCtrl.New()
	TimeScaleService.New()
	OpenFunCtrl.New()
end

function ModulesController:CreateLoginModule()
	LoginCtrl.New()
end

function ModulesController:CreateGameModule()
	self.ctrl_list = {}
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
