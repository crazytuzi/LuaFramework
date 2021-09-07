
-- 模块管理
ModuleManager = ModuleManager or BaseClass()

function ModuleManager:__init()
    if ModuleManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
        return
    end
    ModuleManager.Instance = self

    self.eventManager = nil
    self.assetPoolManager = nil
    self.demoManager = nil
    self.demo2Manager = nil
    self.winMgr = nil
    self.preloadManager = nil

    self.OnTickId = nil
    self.winTickCount = 0

    self.collectCall = nil
    self.autoRunCall = nil
end

function ModuleManager:Activate()
    self.eventManager = EventMgr.New()
    self.demoManager = DemoManager.New()
    self.demo2Manager = Demo2Manager.New()
    self.assetPoolManager = AssetPoolManager.New()
    PrefabdepManager.New()
    SingleIconManager.New()
    self.winMgr = WindowManager.New()
    self.preloadManager = PreloadManager.New()


    Tween.New()
    ActivityManager.New()
    NoticeManager.New()
    CreateRoleManager.New()
    QualifyManager.New()
    RoleManager.New()
    DramaManager.New()
    GuideManager.New()
    GuildManager.New()
    WorldBossManager.New()
    MainUIManager.New()
    ChatManager.New()
    BackpackManager.New()
    QuestManager.New()
    AddPointManager.New()
    TipsManager.New()
    ShouhuManager.New()
    PetManager.New()
    SkillManager.New()
    EquipStrengthManager.New()
    AutoQuestManager.New() -- by 嘉俊 2017/8/29 11:44
    SdkManager.New()

    BaseUtils.NewPlayerImport(KvData.newPlayerImportStepType.flash)
    BaseUtils.NewPlayerImport(KvData.newPlayerImportStepType.notice)
    BaseUtils.NewPlayerImport(KvData.newPlayerImportStepType.loading_start)

    gm_cmd.init()
    ShopManager.New()
    NumberpadManager.New()
    MarketManager.New()
    CombatManager.New()
    PreviewManager.New()
    AgendaManager.New()
    NpcshopManager.New()
    RankManager.New()
    DungeonManager.New()
    TeamManager.New()
    FormationManager.New()
    GmManager.New()
    FriendManager.New()
    WorldMapManager.New()
    ZoneManager.New()
    WingsManager.New()
    ArenaManager.New()
    TrialManager.New()
    ShippingManager.New()
    SummerManager.New()
    CampaignManager.New()
    BibleManager.New()
    GivepresentManager.New()
    TreasuremapManager.New()
    FashionManager.New()
    EffectBrocastManager.New()
    AutoFarmManager.New()
    ExitConfirmManager.New()
    HonorManager.New()
    GloryManager.New()
    ExamManager.New()
    BuyManager.New()
    FairyLandManager.New()
    FuseManager.New()
    GodAnimalManager.New()
    WarriorManager.New()
    FirstRechargeManager.New()
    SoundManager.New()
    ParadeManager.New()
    SceneTalk.New()
    FinishCountManager.New()
    BuffPanelManager.New()
    SatiationManager.New()
    SettingManager.New()
    ExchangeManager.New()
    SleepManager.New()
    ClassesChallengeManager.New()
    AnnounceManager.New()
    AchievementManager.New()
    OpensysManager.New()
    AlchemyManager.New()
    LocalSaveManager.New()
    DanmakuManager.New()
    MarryManager.New()
    TopCompeteManager.New()
    ConstellationManager.New()
    QuestMarryManager.New()
    OpenServerManager.New()
    GuildfightManager.New()
    PrivilegeManager.New()
    PetLoveManager.New()
    ReportManager.New()
    TeacherManager.New()
    DailyHoroscopeManager.New()
    SosManager.New()
    ForceImproveManager.New()
    HeroManager.New()
    GuildFightEliteManager.New()
    GestureManager.New()
    ModelShaderManager.New()
    ShieldManager.New()
    FestivalManager.New()
    RideManager.New()
    DragonBoatManager.New()
    SubpackageManager.New()
    DownLoadManager.New()
    MergeServerManager.New()
    SkillScriptManager.New()
    WorldChampionManager.New()
    HomeManager.New()
    MasqueradeManager.New()
    StrategyManager.New()
    EncyclopediaManager.New()
    SevendayManager.New()
    SingManager.New()
    AuctionManager.New()
    BackendManager.New()
    GoPoolManager.New()
    LotteryManager.New()
    OpenBetaManager.New()
    HandbookManager.New()
    UnlimitedChallengeManager.New()
    MidAutumnFestivalManager.New()
    LevelBreakManager.New()
    GuildLeagueManager.New()
    ShareManager.New()
    PortraitManager.New()
    NationalDayManager.New()
    ClassesChangeManager.New()
    HalloweenManager.New()
    SwornManager.New()
    GodsWarManager.New()
    HalloweenSceneTalk.New()
    DoubleElevenManager.New()
    RegressionManager.New()
    -- SoloEndlessManager.New()
    TeamMatchManager.New()
    ThanksgivingManager.New()
    NewMoonManager.New()
    NotNamedTreasureManager.New()
    NewYearManager.New()
    NewLabourManager.New()
    MatchManager.New()
    SnowBallManager.New()
    -- SkiingManager.New()
    AutoRunManager.New()
    RewardBackManager.New()
    ChildrenManager.New()
    ChildBirthManager.New()
    -- RedBagManager.New()
    RedBagManager.New()
    SpringFestivalManager.New()
    TeamDungeonManager.New()
    ValentineManager.New()
    UnitStateManager.New()
    TreasureMazeManager.New()
    FriendGroupManager.New()
    PetEvaluationManager.New()
    StarParkManager.New()
    -- GuildSiegeManager.New()
    PlayerkillManager.New()
    GuildSiegeManager.New()
    SignRewardManager.New()
    LevelJumpManager.New()

    ToyRewardManager.New()
    MarchEventManager.New()
    LuckeyChestManager.New()
    MayIOUManager.New()
    WorldLevManager.New()
    --LHotfix.New()
    DragonBoatFestivalManager.New()

    FoolManager.New()
    GuildAuctionManager.New()
    TalismanManager.New()
    GuildDungeonManager.New()
    AnimalChessManager.New()
    SpecialItemManager.New()
    RebateRewardManager.New()
    QuestKingManager.New()
    WarmHeartManager.New()
    CampBoxManager.New()
    NewExamManager.New()
    IngotCrashManager.New()
    SummerGiftManager.New()
    StarChallengeManager.New()
    BigSummerManager.New()
    SummerCarnivalManager.New()
    CampaignRedPointManager.New()
    BeginAutumnManager.New()
    IntimacyManager.New()
    QiXiLoveManager.New()
    FaceManager.New()
    ExquisiteShelfManager.New()
    TurntabelRechargeManager.New()
    RechargePackageManager.New()
    NationalSecondManager.New()
    CampaignAutumnManager.New()
    CakeExchangeManager.New()
    DollsRandomManager.New()
    MagicEggManager.New()
    GuildDragonManager.New()
    CampaignInquiryManager.New()
    SalesPromotionManager.New()
    FashionSelectionManager.New()
    FashionDiscountManager.New()
    NewYearTurnableManager.New()
    ArborDayShakeManager.New()
    EventCountManager.New()
    RushTopManager.New()
    GodsWarWorShipManager.New()
    ExperienceBottleManager.New()
    CrossArenaManager.New()
    SignDrawManager.New()
    AprilTreasureManager.New()
    ApocalypseLordManager.New()
    AnniversaryTyManager.New()
    DragonPhoenixChessManager.New()
    CrossVoiceManager.New()
    CanYonManager.New()
    TruthordareManager.New()
    IntegralExchangeManager.New()
    CardExchangeManager.New()
    CampaignProtoManager.New()
    -- 最后执行
    ImproveManager.New()
    LoginManager.New()
    SceneManager.Instance:Init()
    SdkManager.Instance:IosVestSDKInit() -- Ios马甲包的sdk初始化位置调整到这里
    self.OnTickId = LuaTimer.Add(0, 200, function(id) self:OnTick(id) end)
    self.preloadManager:PreLoad(function() self:OnPreloadCompleted() end)
end

-- 预加载完成
function ModuleManager:OnPreloadCompleted()
    BaseUtils.NewPlayerImport(KvData.newPlayerImportStepType.loading_end)

    SceneManager.Instance:InitSceneView()
    ModelShaderManager.Instance:InitShader()
    -- 预加载完成，显示登录界面
    if SdkManager.Instance:RunSdk() and not BaseUtils.IsExperienceSrv() then
        SdkManager.Instance:OnPreloadCompleted()
        if Application.platform == RuntimePlatform.Android then
            local but = ctx.LoadingPage.Panel:GetComponent(Button)
            if but == nil then
                but = ctx.LoadingPage.Panel:AddComponent(Button)
                but.transition = Selectable.Transition.None
                but.onClick:AddListener(function() self:OnClickLoadingPanel() end)
            end
        end
    else
        self:Login()
    end
end

function ModuleManager:OnClickLoadingPanel()
    Log.Debug("wang==>   OnClickLoadingPanel")
    SdkManager.Instance:OnShowLoginView()
end

function ModuleManager:Release()
    self.eventManager:DeleteMe()
    self.eventManager = nil

    self.demoManager:DeleteMe()
    self.demoManager = nil

    self.demo2Manager:DeleteMe()
    self.demo2Manager = nil

    self.assetPoolManager:DeleteMe()
    self.assetPoolManager = nil

    self.winMgr:DeleteMe()
    self.winMgr = nil

    self.preloadManager:DeleteMe()
    self.preloadManager = nil
end

function ModuleManager:FixedUpdate()
    SceneManager.Instance:FixedUpdate()
    TipsManager.Instance:FixedUpdate()
    WorldMapManager.Instance:FixedUpdate()
    GestureManager.Instance:FixedUpdate()
    HomeManager.Instance:FixedUpdate()
    MainUIManager.Instance:FixedUpdate()
    GmManager.Instance:FixedUpdate()
    --LHotfix.Instance:FixUpdate()
    if self.collectCall ~= nil then
        self.collectCall()
    end
end

function ModuleManager:Login()
    -- 显示登录界面
    -- ctx.LoadingPage:Hide()
    LoginManager.Instance.model:InitMainUI()
    NoticeManager.Instance:PreLoad()
end

function ModuleManager:OnTick(id)
    AssetPoolManager.Instance:OnTick()
    SceneManager.Instance:OnTick()
    MainUIManager.Instance:OnTick()
    EffectBrocastManager.Instance:CheckoutEffect()
    NoticeManager.Instance:OnTick()
    -- SceneTalk.Instance:onTick()
    HomeManager.Instance:OnTick()
    SingleIconManager.Instance:OnTick()

    -- ValentineManager.Instance:OnTick()
    self.winTickCount = self.winTickCount + 1
    if self.winTickCount % 3 == 0 then
        QuestManager.Instance:OnTick()
    end

    if self.winTickCount % 5 == 0 then -- 每秒执行一次
        BaseUtils.BASE_TIME = BaseUtils.BASE_TIME + 1 -- 计时
        ChatManager.Instance:OnTick()
        -- CombatManager.Instance.objPool:OnTick()
        AchievementManager.Instance:OnTick()
        HalloweenSceneTalk.Instance:OnTick()
    end
    if self.winTickCount == (5 * 2) then
        -- 2秒执行一次
        WindowManager.Instance:OnTick()
        GoPoolManager.Instance:OnTick()
        GuildSiegeManager.Instance:OnTick()
        BibleManager.Instance:OnTick()
        RankManager.Instance.model:OnTick()
        if self.autoRunCall ~= nil then
            self.autoRunCall()
        end

        BaseUtils.Last_Tick_Time = os.time() -- 上一个tick的时间
        self.winTickCount = 0
    end
end
