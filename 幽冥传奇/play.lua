
local player = {
	STATE_START = 0,
	STATE_INIT = 1,
	STATE_UPDATE = 2,
	STATE_INIT_FAILD = 3,
	
	update_func = nil,
	state = 0,
	load_total = 0,
	load_done = 0,
	
	-- 预加载纹理
	perload_res_list = {
		"res/xui/common8.png",
		"res/xui/common.png",
		"res/xui/scene.png",
	},
	
	-- 核心模块
	core_module_list = {
		{class = Runner},					-- 循环
		{
			class = EventSystem,
			init_func = function(obj)
				GlobalEventSystem = obj
				Runner.Instance:AddRunObj(GlobalEventSystem, 3)
			end,
			delete_func = function(obj) GlobalEventSystem = nil end
		},									-- 全局事件系统
		{
			class = TimerQuest,
			init_func = function(obj) GlobalTimerQuest = obj end,
			delete_func = function(obj) GlobalTimerQuest = nil end
		},									-- 定时器
		{class = NodeCleaner},				-- 节点清理器
		{class = CountDown},				-- 倒计时
		{class = ConfigManager},			-- 配置管理器
		{class = GameNet},					-- 网络
		{class = AudioManager},				-- 声音
		{class = FpsSampleUtil},			-- 帧频采样
		{class = StepPool},					-- 分步池
		{class = UiDragMgr},				-- 拖动管理
		{class = ResManager},				-- 资源管理器
	},
	
	game_module_list = {
		-- 渲染模块
			{
			class = RenderUnit,
			init_func = function(obj)
				HandleRenderUnit = obj
				HandleRenderUnit:InitAsMainStage()
			end,
			delete_func = function() HandleRenderUnit = nil end,
		},
		-- 地图
			{
			class = GameMapHelper,
			init_func = function(obj)
				HandleGameMapHandler = obj
			end,
			delete_func = function() HandleGameMapHandler = nil end,
		},
		
		-- 管理器
		{class = ParticleEffectSys},
		{class = GameVoManager},
		{class = ViewManager},
		{class = GameCondMgr},
		{class = AvatarManager},
		{class = UiInstanceMgr},
		{class = RemindManager},
		{class = ClientCmdCtrl},
		
		-- 普通模块
		{class = ItemData},
		{class = RoleCtrl},
		{class = BagCtrl},
		{class = EquipCtrl},
		{class = CommonCtrl},
		
		{class = LoginController},
		{class = PerloadCtrl},
		{class = MapLoading},
		{class = TimeCtrl},
		{class = PkCtrl},
		{class = MainuiCtrl},
		{class = OtherCtrl},
		{class = SysMsgCtrl},
		{class = TipCtrl},
		{class = BrowseCtrl},
		{class = HelpCtrl},
		{class = TitleCtrl},
		{class = EquipmentCtrl},
		{class = QianghuaCtrl},
		{class = AffinageCtrl},
		{class = StoneCtrl},
		{class = MoldingSoulCtrl},
		{class = RefineCtrl},
		{class = WingCtrl},
		{class = SkillCtrl},
		{class = ZhuangShengCtrl},
		{class = DeifyCtrl},
		{class = LevelCtrl},
		{class = HoroscopeCtrl},
		{class = FuwenCtrl},
		{class = ChatCtrl},
		{class = SocietyCtrl},
		{class = TeamCtrl},
		{class = SettingCtrl},
		{class = SettingProtectCtrl},
		{class = FightCtrl},
		{class = GuajiCtrl},
		{class = FuhuoCtrl},
		{class = MapCtrl},
		{class = TaskCtrl},
		{class = BossCtrl},
		{class = PersonalBossCtrl},
		{class = WildBossCtrl},
		{class = HouseBossCtrl},
		{class = SecretBossCtrl},
		{class = NewBossCtrl},
		{class = BossIntegralCtrl},
		{class = ZhanjiangCtrl},
		{class = EqComposeCtrl},
		{class = GuideCtrl},
		{class = ShopCtrl},
		{class = ExploreCtrl},
		{class = MailCtrl},
		{class = WelfareCtrl},
		{class = ActivityCtrl},
		{class = VipCtrl},
		{class = GuildCtrl},
		{class = WorshipCtrl},
		{class = WangChengZhengBaCtrl},
		{class = JiFenEquipmentCtrl},
		{class = ChargeRewardCtrl},
		{class = ConsignCtrl},
		{class = RefiningExpCtrl},
		{class = OpenServiceAcitivityCtrl},
		{class = RankingListCtrl},
		{class = EscortCtrl},
		{class = DungeonCtrl},
		{class = ExchangeCtrl},
		{class = FubenCtrl},
		{class = PeerlessEqCtrl},
		{class = ChongzhiCtrl},
		{class = ActivityBrilliantCtrl},
		{class = HutiCtrl},
		{class = GodFurnaceCtrl},
		{class = SuitAdditionCtrl},
		{class = CallBossCtrl},
		{class = OfficeCtrl},
		{class = LunHuiCtrl},
		{class = WeiZhiADCtrl},
		{class = FubenMutilCtrl},
		{class = CrossServerCtrl},
		{class = PrivilegeCtrl},
		{class = CardHandlebookCtrl},
		{class = ActMsGift},
		{class = Scene},
		{class = MeridiansCtrl},
		{class = PracticeCtrl},
		{class = ShenDingCtrl},
		{class = TimeLimitTaskCtrl},
		{class = PrestigeCtrl},
		{class = PrestigeTaskCtrl},
		{class = DailyTasksCtrl},
		{class = BeastPalaceCtrl},
		{class = PengLaiFairylandCtrl},
		{class = FireVisionCtrl},
		{class = RebirthHellCtrl},
		{class = DragonSoulCtrl},
		{class = OpenSerVeGiftCtrl},
		{class = PreviewCtrl},
		{class = BattleFuwenCtrl},
		{class = FindBossCtrl},
		{class = UnknownDarkHouseCtrl},
		{class = CombinedServerActCtrl},
		{class = TreasureAtticCtrl},
		{class = ZhenBaoGeCtrl},
		{class = InvestmentCtrl},
        {class = RewardPreviewCtrl},
        {class = ShenqiCtrl},
        {class = ActCanbaogeCtrl},
        {class = ActBabelTowerCtrl},
		{class = ActLimitChargeCtrl},
		{class = ActChargeFanliCtrl},
		{class = AuthenticateCtrl},
		{class = DiamondBackCtrl},
		{class = BlessingCtrl},
		{class = SpecialRingCtrl},
		{class = MeiBaShouTaoCtrl},
		{class = ChiYouCtrl},
		{class = CrossLandCtrl},
		{class = TemplesCtrl},
		{class = GuardEquipCtrl},
		{class = LuxuryEquipUpgradeCtrl},
		{class = LuxuryEquipTipCtrl},
		{class = FashionCtrl},
		{class = ZsVipCtrl},
		{class = HunHuanCtrl},
		{class = QieGeCtrl},
		{class = ChargeGiftCtrl},
		{class = WelfareTurnbelCtrl},
		{class = ReXueGodEquipCtrl},
		{class = ExperimentCtrl},
		{class = GrabRedEnvelopeCtrl},
		{class = ZsTaskCtrl},
		{class = DiamondPetCtrl},
		{class = NewlyBossCtrl},
		{class = OutOfPrintCtrl},
		{class = BabelCtrl},
		{class = AdvancedLevelCtrl},
		{class = ZsVipRedpackerCtrl},
		{class = EquipmentFusionCtrl},
	},
}

function player:Name()
	return "player"
end

function player:Start()
	print("player:Start!")
	
	InitSearchPath(false)
	self.state = player.STATE_START
end

function player:Stop()
	print("player:Stop!")
	self:StopGame()
end

function player:Restart()
	self:StopGame()
end

function player:Update(elapse_time)
	if self.state == player.STATE_UPDATE then
		XUI.Update()
		Runner.Instance:Update(NOW_TIME, elapse_time)
	elseif self.state == player.STATE_INIT then
		self:UpdateInitGameCor()
	elseif self.state == player.STATE_START then
		self:StartGame()
	end
	
	return MainLoader.TASK_STATUS_FINE
end

function player:StartGame()
	self.state = player.STATE_INIT
	
	-- todo:windows上使用ttf
	if PLATFORM == cc.PLATFORM_OS_WINDOWS then
		COMMON_CONSTS.FONT = "font/SimHei.ttf"
	end

	self.load_total = #self.core_module_list + #self.perload_res_list + #self.game_module_list
	self.load_done = 0
	self:CreateInitGameCor()
end

function player:CreateInitGameCor()
	self.init_game_cor = coroutine.create(self.InitGame)
end

function player:UpdateInitGameCor()
	local status = coroutine.status(self.init_game_cor)
	if "suspended" == status then
		local resume_result, msg = coroutine.resume(self.init_game_cor, self)
		if not resume_result then
			self.state = player.STATE_INIT_FAILD
			ErrorLog("[player] init faild:" .. msg)
		end
	elseif "dead" == status then
		self:GameStartComplete()
	end
end

function player:GameStartComplete()
	self.state = player.STATE_UPDATE
	
	-- 清理游戏启动过程中生成的节点
	MainLoader:CloseView()
	MainProber:CloseView()
	if nil ~= MainLoader.CloseReconnectView then
		MainLoader:CloseReconnectView()
	end
	AdapterToLua:GetGameScene():getRenderGroup(GRQ_UI_UP):removeAllChildren()

	local quick_reconnect = AdapterToLua:getInstance():getDataCache("QUICK_RECONNECT")
	if quick_reconnect == "true" then
		MainLoader:OpenReconnectView()
	end
	
	-- 游戏启动完毕
	GlobalEventSystem:Fire(AppEventType.GAME_START_COMPLETE)
end

function player:InitGame()
	for k, v in pairs(self.core_module_list) do
		v.obj = v.class.New()
		if nil ~= v.init_func then
			v.init_func(v.obj)
		end
		self.load_done = self.load_done + 1
		
		if XCommon:getHighPrecisionTime() - HIGH_TIME_NOW >= 0.012 then
			coroutine.yield(1)
		end
	end
	
	self.load_res_count = #self.perload_res_list
	local function load_callback(path, is_succ, texture)
		self.load_res_count = self.load_res_count - 1
		self.load_done = self.load_done + 1
	end
	for i, v in ipairs(self.perload_res_list) do
		ResourceMgr:getInstance():asyncLoadPlist(v, load_callback)
	end
	
	for k, v in pairs(self.game_module_list) do
		v.obj = v.class.New()
		if nil ~= v.init_func then
			v.init_func(v.obj)
		end
		self.load_done = self.load_done + 1
		
		if XCommon:getHighPrecisionTime() - HIGH_TIME_NOW >= 0.012 then
			coroutine.yield(2)
		end
	end
	
	while self.load_res_count > 0 do
		coroutine.yield(3)
	end
end

function player:StopGame()
	print("player:StopGame")
	MainProber:Step2(MainProber.STEP_SESSION_END, MainProber.user_id, MainProber.server_id, MainProber.role_name, MainProber.role_id)
	
	ObjectPool.ClearAllPool()  		--清空对象池
	
	for i = #self.game_module_list, 1, - 1 do
		local module_obj = self.game_module_list[i]
		module_obj.obj:DeleteMe()
		if nil ~= module_obj.delete_func then
			module_obj.delete_func()
		end
		module_obj.obj = nil
	end
	
	for i = #self.core_module_list, 1, - 1 do
		local module_obj = self.core_module_list[i]
		module_obj.obj:DeleteMe()
		if nil ~= module_obj.delete_func then
			module_obj.delete_func()
		end
		module_obj.obj = nil
	end
end

-- 进入前台
function player:EnterForeground()
	if nil ~= GlobalEventSystem then
		GlobalEventSystem:Fire(AppEventType.ENTER_FOREGROUND)
	end
end

-- 进入后台
function player:EnterBackground()
	if nil ~= GlobalEventSystem then
		print("ssssss")
		GlobalEventSystem:Fire(AppEventType.ENTER_BACKGROUND)
	end
end

-- 网络状态改变
--[[
	1：没有wifi, 使用手机自带网络
	2：有wifi
	0：异常
]]
function player:NetStateChanged(net_state)
	if nil ~= GlobalEventSystem and net_state == 0 then
		GlobalEventSystem:Fire(LoginEventType.GAME_SERVER_DISCONNECTED, GameNet.DISCONNECT_REASON_NORMAL)
	end
end

-- 重新开始
function ReStart()
	AdapterToLua:restart()
end

return player
