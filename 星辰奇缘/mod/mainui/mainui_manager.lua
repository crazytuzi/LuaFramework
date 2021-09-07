-- 主界面管理
MainUIManager = MainUIManager or BaseClass()

function MainUIManager:__init()
	if MainUIManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end

	MainUIManager.Instance = self

	self.MainUICanvasView = nil
	self.MainUIIconView = nil
    self.mainuitracepanel = nil
    self.roleInfoView = nil
    self.petInfoView = nil
    self.mapInfoView = nil
    self.expInfoView = nil
    self.playerInfoView = nil
    self.noticeView = nil
    self.systemView = nil
    self.clicknpcView = nil
    self.backView = nil

    self.treasuremapCompassView = nil
    self.marryBarView = nil

    -- self.dialogModel = DialogModel.New()
    self.dialogModel = DialogModelDrama.New()

    self.ativeicon_cache = {}
    self.ativeicon_cache2 = {}
    self.ativeicon_cache3 = {}

    self.OnUpdateIcon = EventLib.New()
    self.isMainUIShow = true
    self.isMainUIInconInit = false

    self.listener = function() self:OnSceneLoad() end
    self.priority = 0

end

function MainUIManager:__delete()
    self.OnUpdateIcon:DeleteMe()
    self.OnUpdateIcon = nil
end

function MainUIManager:initMainUICanvas()
    self.adaptIPhoneX = BaseUtils.IsIPhoneX()

	if self.MainUICanvasView == nil then
        self.MainUICanvasView = MainUICanvasView.New()
        self:Switch()
    else
        -- self:ShowMainUICanvas(true)
    end

    BaseUtils.NewPlayerImport(KvData.newPlayerImportStepType.enter_game, LoginManager.Instance.curPlatform)
end

function MainUIManager:ShowMainUICanvas(show)
    if self.MainUICanvasView ~= nil and self.MainUICanvasView.gameObject ~= nil then
        -- self.MainUICanvasView.gameObject:SetActive(show)
        self.isMainUIShow = show
        if show then
            self.MainUICanvasView.rect.anchoredPosition = Vector2.zero

            -- BaseUtils.ChangeLayersRecursively(self.MainUICanvasView.gameObject.transform, "UI")
            -- if self.raycaster == nil then
            --     self.raycaster = self.MainUICanvasView.gameObject:GetComponent(GraphicRaycaster)
            -- end
            -- self.raycaster.enabled = true
        else
            self.MainUICanvasView.rect.anchoredPosition = Vector2(4000, -4000)

            -- BaseUtils.ChangeLayersRecursively(self.MainUICanvasView.gameObject.transform, "Water")
            -- if self.raycaster == nil then
            --     self.raycaster = self.MainUICanvasView.gameObject:GetComponent(GraphicRaycaster)
            -- end
            -- self.raycaster.enabled = false
        end
    end

    -- if self.MainUIIconView ~= nil then
    --     self.MainUIIconView:ShowCanvas(show)
    -- end

    -- if self.mainuitracepanel ~= nil then
    --     self.mainuitracepanel:ShowCanvas(show)
    -- end

    -- if self.mapInfoView ~= nil then
    --     self.mapInfoView:ShowCanvas(show)
    -- end

    -- if self.expInfoView ~= nil then
    --     self.expInfoView:ShowCanvas(show)
    -- end
end

function MainUIManager:initBaseFunctionIconArea()
	if self.MainUIIconView == nil then
        self.MainUIIconView = MainUIIconView.New()
        self.MainUIIconView:Show()
    end
end

function MainUIManager:initRoleInfoView()
    if self.roleInfoView == nil then
        self.roleInfoView = RoleInfoView.New()
    end
end

function MainUIManager:SetWorldLevVisible(bo)
    if self.roleInfoView ~= nil then
        self.roleInfoView:SetWorldLevVisible(bo)
    end
end

function MainUIManager:initPetInfoView()
    if self.petInfoView == nil then
        self.petInfoView = PetInfoView.New()
    end
end

function MainUIManager:initMapInfoView()
    if self.mapInfoView == nil then
        self.mapInfoView = MapInfoView.New()
    end
end

function MainUIManager:initExpInfoView()
    if self.expInfoView == nil then
        self.expInfoView = ExpInfoView.New()
    end
end

function MainUIManager:initSystemView()
    if self.systemView == nil then
        self.systemView = SystemView.New()
    end
end

function MainUIManager:initPlayerInfoView()
    if self.playerInfoView == nil then
        self.playerInfoView = PlayerInfoView.New()
    end
end

function MainUIManager:initClicknpcView()
    if self.clicknpcView == nil then
        self.clicknpcView = ClicknpcView.New()
    end
end

function MainUIManager:initDialog()
    self.dialogModel.dramaTalk:Show()
end

-- 初始化主UI显示
function MainUIManager:InitPanels()
    -- 任务追踪块
    if self.mainuitracepanel == nil then
        self.mainuitracepanel = MainuiTracePanel.New()
    end
    self.mainuitracepanel:Show()
end

-- 打开对话框
function MainUIManager:OpenDialog(npcData, extra, notask, special, isPlant)
    self.dialogModel:Open(npcData, extra, notask, special, isPlant)
end

-- 隐藏对话框
function MainUIManager:HideDialog()
    self.dialogModel:Hide()
end

function MainUIManager:OpenTreasuremapCompassView()
    if self.treasuremapCompassView == nil then
        self.treasuremapCompassView = TreasuremapCompassView.New()
    end
    self.mainuitracepanel:TweenHiden()
end

function MainUIManager:CloseTreasuremapCompassView()
    if self.treasuremapCompassView ~= nil then
        self.treasuremapCompassView:DeleteMe()
        self.treasuremapCompassView = nil
    end
end

function MainUIManager:OpenMarryBarView()
    if self.marryBarView == nil then
        self.marryBarView = MarryBarView.New()
    end
end

function MainUIManager:CloseMarryBarView()
    if self.marryBarView ~= nil then
        self.marryBarView:DeleteMe()
        self.marryBarView = nil
    end
end

-- 初始化主界面通知栏
function MainUIManager:initNoticeView()
    -- 主界面通知栏
    if self.noticeView == nil then
        self.noticeView = MainuiNoticeView.New()
    end
end

--打开挑战面板
function MainUIManager:OpenChallengePanel()
    if self.ChallengeView == nil then
        self.ChallengeView = MainuiChallangeView.New(self)
    end
    self.ChallengeView:Show()
end

function MainUIManager:CloseChallengePanel()
    if self.ChallengeView ~= nil then
        self.ChallengeView:DeleteMe()
        self.ChallengeView = nil
    end
end
--设置12星座 星座分布信息
function MainUIManager:SetConstellationArea(data)
    if self.ChallengeView ~= nil then
        self.ChallengeView:SetConstellationArea(data)
    end
end


-- 每秒Tick一次
function MainUIManager:OnTick()
    if self.mapInfoView ~= nil then self.mapInfoView:update_coords() end-- 更新地图坐标
    if self.systemView ~= nil then self.systemView:OnTick() end-- 更新系统信息
end

-- 按钮点击事件 Mark
function MainUIManager:btnOnclick(id)
    if id == 1 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.backpack, {1,1})
        -- OpensysManager.Instance:Show({ gain = { {id = 15, value = 1} }})
    elseif id == 2 then
        --公会
        -- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guildwindow)
        GuildManager.Instance.model:OpenGuildUI()
    elseif id == 3 then --技能
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.skill)
        -- SceneManager.Instance.MainCamera:Screenshot_AndAlpha()
    elseif id == 4 then --宠物
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.pet)
    elseif id == 5 then --锻造
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.eqmadvance)
    elseif id == 6 then
        if BaseUtils.IsVerify then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, { 3 })
        else
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop)
        end
    elseif id == 7 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ui_rank, { 1 })
        -- FishManager.Instance:OpenMainUI({1})
        -- FishManager.Instance:send19801(1)
        -- RoleManager.Instance:send10035()
        -- if Application.platform == RuntimePlatform.WindowsEditor or Application.platform == RuntimePlatform.WindowsPlayer then
        --     WindowManager.Instance:OpenWindowById(WindowConfig.WinID.auction_window)
        -- else
        --     WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ui_rank, { 1 })
        -- end
        -- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.glory_window, {})
        -- GmManager.Instance:OpenGmWindow()
        -- DemoManager.Instance:OpenPoolWindow()
        -- DemoManager.Instance:OpenPreviewWindow()
        -- DemoManager.Instance:OpenPageWindow()
        -- Demo2Manager.Instance:OpenWindow()
    elseif id == 8 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.setting_window,{1})
    elseif id == 11 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guardian)
    elseif id == 18 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.market)
    elseif id == 17 then
        ImproveManager.Instance.model:OpenMyWindow()
    elseif id == 14 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.agendamain)
    elseif id == 20 then
        CombatManager.Instance:OnCombatTest()
    elseif id == 22 then
        -- ZoneManager.Instance:OpenSelfZone()
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.biblemain, {1, 1})
    elseif id == 23 then
        -- SceneManager.Instance.sceneElementsModel:Self_RideChange()
        -- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.treasureexchangewindow)
        PetManager.Instance.model:OpenPetQuickShowWindow()
    elseif id == 24 then
        DungeonManager.Instance.model:OpenTowerReward()
    elseif id == 25 then
        -- DungeonManager.Instance:ExitDungeon()
        -- FriendManager.Instance.model:OpenWindow()
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.friend)
    elseif id == 26 then

    elseif id == 27 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.glory_window, {})
    elseif id == 28 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.arena_window)
        --self:OpenChallengePanel()
    elseif id == 29 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.autofarmwin)
    elseif id == 30 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ui_rank, { 2 })
    elseif id == 31 then
        -- if RoleManager.Instance.RoleData.lev < 30 then
        --     WindowManager.Instance:OpenWindowById(WindowConfig.WinID.biblemain, { 2, 1 })
        -- else
        --     WindowManager.Instance:OpenWindowById(WindowConfig.WinID.biblemain, { 3, 1 })
        -- end
        -- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.strategy_window)
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.seven_day_window, { 1 })

    elseif id == 32 then
        CombatManager.Instance.WatchLogmodel:OpenWindow()
    elseif id == 33 then
        SdkManager.Instance:OpenFacebook()
    elseif id == 34 then
        HomeManager.Instance:EnterHome()
    elseif id == 35 then
        if RideManager.Instance.rideStatus ~= 2 and RideManager.Instance.model.myRideData.pre_egg == 0 and RoleManager.Instance.RoleData.lev <75 then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.rideChooseEndWindow, {})
        else
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ridewindow, {1,1})
        end
    elseif id == 36 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.handbook_main)
    elseif id == 37 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.reward_back_window)
    end
end

-- 获取主线任务追踪 对象
function MainUIManager:GetMainTraceObj()
    if self.mainuitracepanel ~= nil then
        return self.mainuitracepanel.traceQuest.mainObj
    end
    return nil
end

function MainUIManager:HideEffect(type)
    self.mainuitracepanel.traceQuest:HideEffect(type)
end

-- 显示某个追踪按钮上的红点
function MainUIManager:RedMainTrace(index, bool)
    self.mainuitracepanel.tabGroup:ShowRed(index, bool)
end

function MainUIManager:ShowMainUI(bool)
    self.MainUICanvasView.gameObject:SetActive(bool)
end

--将段位赛按钮添加到 self.MainUICanvasView
function MainUIManager:AddQualifyBtn2CanvasView(qualifyBtn)
    qualifyBtn.name = "qualifyBtn"
    UIUtils.AddUIChild(self.MainUICanvasView.gameObject, qualifyBtn)
end

function MainUIManager:SetPlayerData(data)
    if self.playerInfoView ~= nil then
        self.playerInfoView:SetData(data)
    end
end

function MainUIManager:HideSelectIcon()
    if self.playerInfoView ~= nil then
        self.playerInfoView:hide()
    end
end

function MainUIManager:SetClicknpcData(data)
    if self.clicknpcView ~= nil then
        self.clicknpcView:SetData(data)
    end
end

function MainUIManager:HideClicknpcData()
    if self.clicknpcView ~= nil then
        self.clicknpcView:hide()
    end
end

function MainUIManager:HideOrShowQuest(id, bool)
    self.mainuitracepanel.traceQuest:ShowOne(id, bool)
end

function MainUIManager:HideTreasuremap()
    if self.mainuitracepanel ~= nil and self.mainuitracepanel.traceQuest ~= nil then
        self.mainuitracepanel.traceQuest:HideTreasuremap()
    end
end

-- 增加动态活动图标
function MainUIManager:AddAtiveIcon(data)
    if self.MainUIIconView ~= nil and self.MainUIIconView.newicon_gameobject ~= nil then
        return self.MainUIIconView:AddAtiveIcon(data)
    else
        self.ativeicon_cache[data.id] = data
        return nil
    end
end

-- 删除动态活动图标 删除图标不会触发 clickCallBack timeoutCallBack 回调
function MainUIManager:DelAtiveIcon(id)
    if self.MainUIIconView ~= nil then
        self.MainUIIconView:DelAtiveIcon(id)
    else
        self.ativeicon_cache[id] = nil
    end
end

-- 增加动态活动图标 2
function MainUIManager:AddAtiveIcon2(data)
    if self.MainUIIconView ~= nil and self.MainUIIconView.newicon_gameobject ~= nil then
        return self.MainUIIconView:AddAtiveIcon2(data)
    else
        self.ativeicon_cache2[data.id] = data
        return nil
    end
end

-- 删除动态活动图标 删除图标不会触发 clickCallBack timeoutCallBack 回调
function MainUIManager:DelAtiveIcon2(id)
    if self.MainUIIconView ~= nil then
        self.MainUIIconView:DelAtiveIcon2(id)
    else
        self.ativeicon_cache2[id] = nil
    end
end

-- 增加动态活动图标 3
function MainUIManager:AddAtiveIcon3(data)
    if self.MainUIIconView ~= nil and self.MainUIIconView.newicon_gameobject ~= nil then
        return self.MainUIIconView:AddAtiveIcon3(data)
    else
        self.ativeicon_cache3[data.id] = data
        return nil
    end
end

-- 删除动态活动图标 删除图标不会触发 clickCallBack timeoutCallBack 回调
function MainUIManager:DelAtiveIcon3(id)
    if self.MainUIIconView ~= nil then
        self.MainUIIconView:DelAtiveIcon3(id)
    else
        self.ativeicon_cache3[id] = nil
    end
end

function MainUIManager:ClearAll()
    if self.mainuitracepanel ~= nil then
        self.mainuitracepanel:Clear()

        if self.mainuitracepanel.traceQuest ~= nil then
            self.mainuitracepanel.traceQuest:ClearAll()
        end
    end

    if self.MainUIIconView ~= nil then
        local ativeicon = BaseUtils.copytab(self.MainUIIconView.ativeicon1)
        for i=1,#ativeicon do
            self:DelAtiveIcon(ativeicon[i])
        end
        ativeicon = BaseUtils.copytab(self.MainUIIconView.ativeicon2)
        for i=1,#ativeicon do
            self:DelAtiveIcon2(ativeicon[i])
        end
        ativeicon = BaseUtils.copytab(self.MainUIIconView.ativeicon3)
        for i=1,#ativeicon do
            self:DelAtiveIcon3(ativeicon[i])
        end
        self.MainUIIconView:refreshicon()
    end

    if self.mapInfoView then
        self.mapInfoView:cleanText()
    end
end

function MainUIManager:ShowBackView()
    if self.backView == nil then
        self.backView = MainuiBackView.New()
    end
    self.backView:Show()
end

function MainUIManager:HideBackView()
    if self.backView ~= nil then
        self.backView:Hiden()
    end
end

-- ----------------------------
-- 显示隐藏任务追踪
-- ----------------------------
function MainUIManager:ShowTracePanel()
    if self.mainuitracepanel ~= nil then
        self.mainuitracepanel:TweenShow()
    end
end

function MainUIManager:HideTracePanel()
    if self.mainuitracepanel ~= nil then
        self.mainuitracepanel:TweenHiden()
    end
end

-- -----------------------------
-- 显示隐藏功能图标
-- -----------------------------
function MainUIManager:ShowIconPanel()
    if self.MainUIIconView ~= nil then
        self.MainUIIconView:TweenShow()
    end
end

function MainUIManager:HideIconPanel()
    if self.MainUIIconView ~= nil then
        self.MainUIIconView:TweenHide()
    end
end

-- -------------------------------
-- 显示隐藏人物头像
-- -----------------------------
function MainUIManager:ShowRoleInfo()
    if self.roleInfoView ~= nil then
        self.roleInfoView:TweenShow()
    end
end

function MainUIManager:HideRoleInfo()
    if self.roleInfoView ~= nil then
        self.roleInfoView:TweenHide()
    end
end

-- --------------------------------
-- 显示隐藏宠物头像
-- -----------------------------
function MainUIManager:ShowPetInfo()
    if self.petInfoView ~= nil then
        self.petInfoView:TweenShow()
    end
end

function MainUIManager:HidePetInfo()
    if self.petInfoView ~= nil then
        self.petInfoView:TweenHide()
    end
end

-- --------------------------------
-- 显示隐藏地图
-- --------------------------------
function MainUIManager:ShowMapInfo()
    if self.mapInfoView ~= nil then
        self.mapInfoView:TweenShow()
    end
end

function MainUIManager:HideMapInfo()
    if self.mapInfoView ~= nil then
        self.mapInfoView:TweenHide()
    end
end

-- --------------------------------
-- 显示隐藏系统信息
-- --------------------------------
function MainUIManager:ShowSysInfo()
    if self.systemView ~= nil then
        self.systemView:TweenShow()
    end
end

function MainUIManager:HideSysInfo()
    if self.systemView ~= nil then
        self.systemView:TweenHide()
    end
end

function MainUIManager:ShowWorldLev(bool)
    if self.roleInfoView ~= nil then
        self.roleInfoView:ShowWorldLev(bool)
    end
end

-- 任务追踪栏隐藏显示改变图标位置
function MainUIManager:TraceQuestSwitch(isShow)
    if self.playerInfoView ~= nil then
        self.playerInfoView:TraceSwitch(isShow)
    end
    if self.noticeView ~= nil then
        self.noticeView:TraceSwitch(isShow)
    end
end

function MainUIManager:DeleteTracePanel(type)
    if self.mainuitracepanel ~= nil and self.mainuitracepanel.gameObject ~= nil then
        self.mainuitracepanel:DeletePanel(type)
    end
end

function MainUIManager:Switch()
    EventMgr.Instance:Fire(event_name.adapt_iphonex)
end

function MainUIManager:ToAdaptIPhoneX()
    local confirmData = NoticeConfirmData.New()
    if self.adaptIPhoneX then
        confirmData.content = "是否关闭iPhoneX适配模式(测试版)？"
    else
        confirmData.content = "是否开启iPhoneX适配模式(测试版)？"
    end
    confirmData.sureCallback = function() self.adaptIPhoneX = not self.adaptIPhoneX self:Switch() end
    NoticeManager.Instance:ConfirmTips(confirmData)
end

function MainUIManager:FixedUpdate()
    if self.orientation ~= Screen.orientation then
        self:Switch()
        self.orientation = Screen.orientation
    end
end

