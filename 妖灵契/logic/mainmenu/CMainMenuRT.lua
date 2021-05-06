local CMainMenuRT = class("CMainMenuRT", CBox)

function CMainMenuRT.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_ArenaBox = self:NewUI(1, CBox)
	self.m_ArenaBtn = self.m_ArenaBox:NewUI(1, CButton)
	self.m_ArenaLeftTimeLabel = self.m_ArenaBox:NewUI(2, CLabel)

	self.m_EqualArenaBox = self:NewUI(2, CBox)
	self.m_EqualArenaBtn = self.m_EqualArenaBox:NewUI(1, CButton)
	self.m_EqualArenaBox.m_TimeLabel = self.m_EqualArenaBox:NewUI(2, CLabel)
	self.m_TeamPvpBox = self:NewUI(3, CBox)
	self.m_TeamPvpBox.m_TimeLabel = self.m_TeamPvpBox:NewUI(2, CLabel)

	self.m_TopGrid = self:NewUI(4, CGrid)
	self.m_PowerGuideBtn = self:NewUI(5, CButton)
	self.m_LoginRewardBtn = self:NewUI(6, CButton)
	self.m_DailyCultivateBtn = self:NewUI(7, CButton)
	self.m_WorldBossBtn = self:NewUI(8, CButton)
	self.m_WorldBossLeftTimeLabel = self:NewUI(9, CLabel)
	self.m_ForetellBtn = self:NewUI(10, CBox)
	self.m_ForetellBtn.m_Label = self.m_ForetellBtn:NewUI(1, CLabel)
	self.m_ForetellBtn.m_DescLabel = self.m_ForetellBtn:NewUI(2, CLabel)
	self.m_ForetellBtn.m_Sprite = self.m_ForetellBtn:NewUI(3, CButton)
	self.m_ForetellBtn.m_UIEffect = self.m_ForetellBtn:NewUI(4, CUIEffect)
	self.m_ForetellBtn.m_UIEffect:Above(self.m_ForetellBtn.m_Sprite)
	
	self.m_PosLabel = self:NewUI(11, CLabel)
	self.m_MapNameLabel = self:NewUI(12, CLabel)
	self.m_WorldMapBtn = self:NewUI(13, CSprite, true, false)
	self.m_MiniMapBtn = self:NewUI(14, CSprite, true, false)
	self.m_TimeLabel = self:NewUI(15, CLabel)
	self.m_BatterySlider = self:NewUI(16, CSlider)
	self.m_NetBox = self:NewUI(17, CBox)

	self.m_OnlineGiftBtn = self:NewUI(18, CBox)
	self.m_OnlineGiftBtn.m_Icon = self.m_OnlineGiftBtn:NewUI(1, CSprite)
	self.m_OnlineGiftBtn.m_Time = self.m_OnlineGiftBtn:NewUI(2, CLabel)
	self.m_OnlineGiftBtn.m_Btn = self.m_OnlineGiftBtn:NewUI(3, CButton)

	self.m_AnLeiNpcBox = self:NewUI(19, CBox)
	self.m_AnLeiNpcBox.m_Time = self.m_AnLeiNpcBox:NewUI(1, CLabel)
	self.m_AnLeiNpcBox.m_Icon = self.m_AnLeiNpcBox:NewUI(2, CSprite)
	self.m_AnLeiNpcBox.m_Name = self.m_AnLeiNpcBox:NewUI(3, CLabel)
	self.m_AnLeiBoxBox = self:NewUI(20, CBox)
	self.m_AnLeiBoxBox.m_Time = self.m_AnLeiBoxBox:NewUI(1, CLabel)
	self.m_AnLeiBoxBox.m_Icon = self.m_AnLeiBoxBox:NewUI(2, CSprite)
	self.m_AnLeiBoxBox.m_Name = self.m_AnLeiBoxBox:NewUI(3, CLabel)	
	self.m_AnLeiBtn = self:NewUI(21, CButton)
	self.m_FieldBossBox = self:NewUI(22, CButton)
	self.m_TerrwarBox = self:NewUI(23, CBox)
	self.m_TerrwarBox.m_Btn = self.m_TerrwarBox:NewUI(1, CButton)
	self.m_TerrwarBox.m_Time = self.m_TerrwarBox:NewUI(2, CLabel)
	self.m_SevenDayTargetBtn = self:NewUI(24, CButton)
	self.m_TimeLimitRankBtn = self:NewUI(25, CButton)
	self.m_FirstChargeBox = self:NewUI(26, CBox)
	self.m_FirstChargeBox.m_Btn = self.m_FirstChargeBox:NewUI(1, CButton)
	self.m_FirstChargeBox.m_UIEffect = self.m_FirstChargeBox:NewUI(2, CUIEffect)
	self.m_FirstChargeBox.m_UIEffect:Above(self.m_FirstChargeBox.m_Btn)
	self.m_ChapterFuBenBtn = self:NewUI(27, CButton)
	self.m_RankBtn = self:NewUI(28, CButton)
	self.m_MonsterAtkCityBox = self:NewUI(29, CBox)
	self.m_MonsterAtkCityBox.m_Btn = self.m_MonsterAtkCityBox:NewUI(1, CButton)
	self.m_MonsterAtkCityBox.m_Time = self.m_MonsterAtkCityBox:NewUI(2, CLabel)
	self.m_LimitRewardBtn = self:NewUI(30, CButton)
	self.m_WelfareBtn = self:NewUI(31, CButton)
	self.m_OrgWarBtn = self:NewUI(32, CBox)
	self.m_OrgWarBtn.m_Btn = self.m_OrgWarBtn:NewUI(1, CButton)
	self.m_OrgWarBtn.m_Time = self.m_OrgWarBtn:NewUI(2, CLabel)
	self.m_GradeGriftBtn = self:NewUI(33, CBox)
	self.m_GradeGriftBtn.m_Btn = self.m_GradeGriftBtn:NewUI(1, CButton)
	self.m_GradeGriftBtn.m_Time = self.m_GradeGriftBtn:NewUI(2, CLabel)
	self.m_GradeGriftBtn.m_UIEffect = self.m_GradeGriftBtn:NewUI(3, CUIEffect)
	self.m_GradeGriftBtn.m_Label = self.m_GradeGriftBtn:NewUI(4, CLabel)
	self.m_GradeGriftBtn.m_UIEffect:Above(self.m_GradeGriftBtn.m_Btn)
	self.m_ChargeBtn = self:NewUI(34, CButton)
	self.m_TestWelfareBtn = self:NewUI(35, CButton)

	self.m_YybBbsBtn = self:NewUI(36, CButton)
	self.m_VPlusBtn = self:NewUI(37, CButton)
	self.m_QQVipBtn = self:NewUI(38, CButton)

	local bQQLogin = g_QQPluginCtrl:IsQQLogin()
	self.m_YybBbsBtn:SetActive(bQQLogin)
	self.m_VPlusBtn:SetActive(bQQLogin)
	self.m_QQVipBtn:SetActive(bQQLogin)
	self.m_AnLeiBoxTimer = nil
	self.m_AnLeiNpcTimer = nil

	self.m_PowerGuideBtn.m_IgnoreCheckEffect = true
	self.m_LoginRewardBtn.m_IgnoreCheckEffect = true
	self.m_SevenDayTargetBtn.m_IgnoreCheckEffect = true
	self.m_LimitRewardBtn.m_IgnoreCheckEffect = true
	self.m_FirstChargeBox.m_IgnoreCheckEffect = true
	self.m_WelfareBtn.m_IgnoreCheckEffect = true
	self.m_TestWelfareBtn.m_IgnoreCheckEffect = true
	self.m_EqualArenaBox.m_IgnoreCheckEffect = true
	self.m_ArenaBox.m_IgnoreCheckEffect = true
	self.m_WorldBossBtn.m_IgnoreCheckEffect = true
	self.m_WorldMapBtn.m_IgnoreCheckEffect = true
	self.m_OrgWarBtn.m_IgnoreCheckEffect = true
	self.m_MonsterAtkCityBox.m_IgnoreCheckEffect = true
	self.m_TeamPvpBox.m_IgnoreCheckEffect = true

	self:RefreshButton()
	self:CheckRedDot()
	self:CheckWelfare()
	self:CheckLimitReward()
	self:InitContent()
	self:RefreshMinMap()
	self:InitNetWork()
	self:InitTopGrid()
	self:ShowEffectFire()
	self.m_Timer = Utils.AddTimer(callback(self, "Update"), 0.5, 0)
	self.m_DeviceTimer = Utils.AddTimer(callback(self, "RefreshDeviceStatus"), 5, 1)
end

function CMainMenuRT.InitContent(self)
	self.m_TimeLimitRankBtn:AddUIEvent("click", callback(self, "OnTimeLimitRank"))
	self.m_PowerGuideBtn:AddUIEvent("click", callback(self, "OnPowerGuide"))
	self.m_LoginRewardBtn:AddUIEvent("click", callback(self, "OpenLoginRewardView"))
	self.m_DailyCultivateBtn:AddUIEvent("click", callback(self, "OpenDailyCultivateView"))
	self.m_WorldBossBtn:AddUIEvent("click", callback(self, "OnWorldBossBtn"))
	self.m_ForetellBtn:AddUIEvent("click", callback(self, "OnForeTell"))
	self.m_WorldMapBtn:AddUIEvent("click", callback(self, "OnOpenMapView", 1))
	self.m_MiniMapBtn:AddUIEvent("click", callback(self, "OnOpenMapView", 2))
	self.m_AnLeiBtn:AddUIEvent("click", callback(self, "OnAnLeiBtn"))
	self.m_AnLeiBoxBox:AddUIEvent("click", callback(self, "OnFindAnLeiBox"))
	self.m_AnLeiNpcBox:AddUIEvent("click", callback(self, "OnFindAnLeiNpc"))	
	self.m_ArenaBtn:AddUIEvent("click", callback(self, "OnArenaBtn"))
	self.m_TeamPvpBox:AddUIEvent("click", callback(self, "OnTeamPvpBtn"))
	self.m_EqualArenaBox:AddUIEvent("click", callback(self, "OnEqualArenaBtn"))
	self.m_FieldBossBox:AddUIEvent("click", callback(self, "OnOpenFieldBoss"))
	self.m_TerrwarBox.m_Btn:AddUIEvent("click", callback(self, "OnTerrwar"))
	self.m_SevenDayTargetBtn:AddUIEvent("click", callback(self, "OnSevenDayTarget"))
	self.m_OnlineGiftBtn:AddUIEvent("click", callback(self, "OnOnlineGiftBtn"))
	self.m_FirstChargeBox:AddUIEvent("click", callback(self, "OnFirstChargeBtn"))
	self.m_ChargeBtn:AddUIEvent("click", callback(self, "OnChargeBtn"))
	self.m_ChapterFuBenBtn:AddUIEvent("click", callback(self, "OnChapterFuBenBtn"))
	self.m_RankBtn:AddUIEvent("click", callback(self, "OnRankBtn"))
	self.m_MonsterAtkCityBox.m_Btn:AddUIEvent("click", callback(self, "OnMonsterAtkCity"))
	self.m_LimitRewardBtn:AddUIEvent("click", callback(self, "OnOpenLimieReward"))
	self.m_WelfareBtn:AddUIEvent("click", callback(self, "OnOpenWelfare"))
	self.m_TestWelfareBtn:AddUIEvent("click", callback(self, "OnOpenTestWelfare"))
	self.m_OrgWarBtn.m_Btn:AddUIEvent("click", callback(self, "OnOpenOrgWar"))
	self.m_GradeGriftBtn.m_Btn:AddUIEvent("click", callback(self, "OnOpenGradeGift"))
	self.m_YybBbsBtn:AddUIEvent("click", callback(self, "OnOpenYybBbs"))
	self.m_VPlusBtn:AddUIEvent("click", callback(self, "OnOpenVPlus"))
	self.m_QQVipBtn:AddUIEvent("click", callback(self, "OnOpenQQVip"))

	g_RankCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnRankEvent"))
	g_TaskCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTaskEvent"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent"))
	g_LoginRewardCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnLoginRewardEvent"))
	g_ActivityCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlActivityEvent"))
	g_EquipFubenCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEquipFbEvent"))
	g_MapCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlMapEvent"))
	g_AnLeiCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlAnLeilEvent"))	
	g_ArenaCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnArenaEvent"))
	g_TeamPvpCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTeamPvpEvent"))
	g_EqualArenaCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnEqualArenaEvent"))
	g_FieldBossCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnFieldBossEvent"))
	g_TerrawarCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTerrawarEvent"))
	g_OnlineGiftCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnOnlineGiftEvent"))
	g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWelfareEvent"))
	g_ChapterFuBenCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnChapterFuBenEvent"))
	g_MonsterAtkCityCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnMonsterAtkCityEvnet"))
	g_OrgWarCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnOrgWarCtrlEvent"))
	g_ConvoyCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnConvoyEvent"))
	g_GradeGiftCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnGradeGiftEvent"))
	self.m_MapNameLabel:SetText(g_MapCtrl.m_SceneName)
	self.m_MapNameLabel:ReActive()
end

function CMainMenuRT.CheckGradeGift(self)
	if g_GradeGiftCtrl:GetStatus() == define.GradeGift.Status.Foretell then
		self.m_GradeGriftBtn:SetActive(g_ActivityCtrl:IsActivityVisibleBlock("grade_gift"))
		self.m_GradeGriftBtn.m_Time:SetText(string.format("%s级开启", g_GradeGiftCtrl.m_Grade))
		self.m_GradeGriftBtn.m_Label:SetText("限时礼包")
		self.m_GradeGriftBtn.m_UIEffect:SetActive(false)
	elseif g_GradeGiftCtrl:GetStatus() == define.GradeGift.Status.Buying then
		self.m_GradeGriftBtn:SetActive(g_ActivityCtrl:IsActivityVisibleBlock("grade_gift"))
		self.m_GradeGriftBtn.m_UIEffect:SetActive(g_GradeGiftCtrl.m_ShowEffect)
		if self.m_GradeGriftTimer == nil then
			self.m_GradeGriftTimer = Utils.AddTimer(callback(self, "CheckGradeGift"), 1, 0)
		end
		self.m_GradeGriftBtn.m_Label:SetText(string.format("%s级礼包", g_GradeGiftCtrl.m_Grade))
		self.m_GradeGriftBtn.m_Time:SetText(g_TimeCtrl:GetLeftTime(g_GradeGiftCtrl:GetRestTime()))
		return true
	else
		self.m_GradeGriftBtn:SetActive(false)
	end
	self.m_GradeGriftTimer = nil
	return false
end

function CMainMenuRT.OnGradeGiftEvent(self, oCtrl)
	if oCtrl.m_EventID == define.GradeGift.Event.UpdateInfo then
		self:DelayCall(0, "RefreshButton")
	end
end

function CMainMenuRT.OnOpenGradeGift(self)
	if g_ActivityCtrl:ActivityBlockContrl("grade_gift") then
		g_GradeGiftCtrl.m_ShowEffect = false
		self.m_GradeGriftBtn.m_UIEffect:SetActive(false)
		CGradeGiftView:ShowView()
	end
end

function CMainMenuRT.OnAttrEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self:DelayCall(0, "RefreshButton")
	end
end

function CMainMenuRT.OnOrgWarCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Org.Event.UpdateOrgWarTime then
		self:CheckOrgWar()
	end
end

function CMainMenuRT.OnConvoyEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Convoy.Event.UpdateConvoyInfo then
		self:DelayCall(0, "RefreshButton")
	end
end

function CMainMenuRT.OnTeamPvpEvent(self, oCtrl)
	if oCtrl.m_EventID == define.TeamPvp.Event.OnRrefshLeftTime then
		self:CheckTeamPvp()
	end
end

function CMainMenuRT.OnEqualArenaEvent(self, oCtrl)
	if oCtrl.m_EventID == define.EqualArena.Event.OnReceiveLeftTime then
		self:DelayCall(0, "RefreshButton")
	end
end

function CMainMenuRT.OnTimeLimitRank(self)
	-- printc("OnTimeLimitRank")
	g_RankCtrl:OpenRank(nil, nil, define.Rank.SubType.TimeLimit)
end

function CMainMenuRT.OnOpenOrgWar(self)
	g_OrgWarCtrl:WalkToOrgWar()
end

function CMainMenuRT.OnOnlineGiftBtn(self)
	if g_ActivityCtrl:ActivityBlockContrl("OnlineGift") then
		COnlineGiftView:ShowView()
	end
end

function CMainMenuRT.OnPowerGuide(self)
	if g_ActivityCtrl:ActivityBlockContrl("powerguide") then
		g_PowerGuideCtrl.m_IsShowMainMenuRedDot = true
		self.m_PowerGuideBtn:DelEffect("RedDot")
		g_GuideCtrl:ReqTipsGuideFinish("mainmenu_powerguide_btn")
		CPowerGuideMainView:ShowView()
	end
end

function CMainMenuRT.OnOnlineGiftEvent(self, oCtrl)
	if oCtrl.m_EventID == define.OnlineGift.Event.UpdateStatus then
		self:CheckOnlineGift()
	elseif oCtrl.m_EventID == define.OnlineGift.Event.UpdateTime then
		self:CheckOnlineGift()
	end
end

function CMainMenuRT.OnTaskEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Task.Event.RefreshAllTaskBox then
		self:DelayCall(0, "RefreshButton")
	end
end

function CMainMenuRT.OpenLoginRewardView(self)
	if g_ActivityCtrl:ActivityBlockContrl("loginreward") then
		g_TaskCtrl.m_IsOpenLoginRewardView = true
		g_GuideCtrl:ReqTipsGuideFinish("mainmenu_loginreward_btn")
		CLoginRewardView:ShowView()
	end	
end

function CMainMenuRT.CheckRedDot(self)
	--七天登陆
	self:LoginRewardRedDot()
	self:SevenDayTargetRedDot()
end

function CMainMenuRT.OnLoginRewardEvent(self, oCtrl)
	if oCtrl.m_EventID == define.LoginReward.Event.LoginReward then
		self:DelayCall(0, "RefreshButton")
		self:DelayCall(0, "LoginRewardRedDot")
	end 
end

function CMainMenuRT.CheckLoginReward(self)
	local b = (g_LoginRewardCtrl:IsHasLoginReward() and
		g_ActivityCtrl:IsActivityVisibleBlock("loginreward") and
		g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.loginreward.open_grade and 
		data.globalcontroldata.GLOBAL_CONTROL.loginreward.is_open == "y" )
	self.m_LoginRewardBtn:SetActive(b)
	if b then
		g_GuideCtrl:StartTipsGuide("Tips_LoginSevenDay")
	end
end

function CMainMenuRT.LoginRewardRedDot(self)
	if g_LoginRewardCtrl:HasCanGetReward() then
		self.m_LoginRewardBtn:AddEffect("RedDot")
	else
		self.m_LoginRewardBtn:DelEffect("RedDot")
	end
end

function CMainMenuRT.RefreshButton(self)	
	--七天登录
	self:CheckLoginReward()

	--每日修行
	--self.m_DailyCultivateBtn:SetActive(g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.dailytrain.open_grade and g_ActivityCtrl:IsActivityVisibleBlock("lilian"))
	self.m_DailyCultivateBtn:SetActive(false)

	--暗雷按钮
	self:RefreshAnLeiBtn()
	--暗雷宝箱和稀有怪
	self:RefreshAnLeiTips()

	--野外boss
	self:CheckFieldBoss()

	--比武场
	self:CheckArena()
	--协同比武
	self:CheckTeamPvp()
	--公平比武场
	self:CheckEqualArena()

	--世界boss
	self:CheckWorldBoss()

	--预告
	self:CheckForetell()

	--游戏精灵
	self:CheckPowerGuide()

	--据点战
	self:CheckTerrawar()

	--七天目标
	self:CheckSevenDayTarget()

	--首冲奖励
	self:CheckFirstCharge()
	--剧情副本
	self:CheckChapterFuBen()

	--在线奖励
	self:CheckOnlineGift()

	--限时充榜
	self:CheckTimeLimitRank()

	--排行榜
	self.m_RankBtn:SetActive(g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.rank.open_grade and g_ActivityCtrl:IsActivityVisibleBlock("rank") )

	--福利	
	self.m_WelfareBtn:SetActive(main.g_AppType  ~= "shenhe" and data.globalcontroldata.GLOBAL_CONTROL.welfare.is_open == "y" and g_ActivityCtrl:IsActivityVisibleBlock("welfare") and g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.welfare.open_grade)
	self.m_TestWelfareBtn:SetActive(Utils.IsYunYingOpen() and main.g_AppType  ~= "shenhe" and data.globalcontroldata.GLOBAL_CONTROL.test_fuli.is_open == "y" and g_ActivityCtrl:IsActivityVisibleBlock("test_welfare") and g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.test_fuli.open_grade)

	--怪物攻城
	self:CheckMonsterAtkCity()
	self.m_LimitRewardBtn:SetActive(g_WelfareCtrl:IsOpenLimitReward() and g_ActivityCtrl:IsActivityVisibleBlock("LimitReward") )

	--刷新答题，学霸学渣去哪了
	self:CheckQuestion()
	--工会战
	self:CheckOrgWar()
	--限时礼包
	self:CheckGradeGift()

	self:TopGridReposition()
end

function CMainMenuRT.OnRankEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Rank.Event.UpdateTimeLimitRankInfo then
		self:CheckTimeLimitRank()
		self:TopGridReposition()
	end
end

function CMainMenuRT.CheckTimeLimitRank(self)
	self.m_TimeLimitRankBtn:SetActive(g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.rushrank.open_grade and g_RankCtrl:HasTimeLimitRank() and g_ActivityCtrl:IsActivityVisibleBlock("TimeLimitRank"))
end

function CMainMenuRT.CheckOnlineGift(self)
	local giftData = g_OnlineGiftCtrl:GetMainGiftData()
	if giftData and g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.onlinegift.open_grade then
		self.m_OnlineGiftBtn:SetActive(g_ActivityCtrl:IsActivityVisibleBlock("OnlineGift"))
		self:TopGridReposition()
		self.m_OnlineGiftBtn.m_Icon:SpriteItemShape(giftData.icon)
		local leftTime = giftData.online_time - (g_TimeCtrl:GetTimeS() - g_OnlineGiftCtrl:GetStartTime())
		if leftTime <= 0 then
			self.m_OnlineGiftBtn.m_Time:SetText("可领取")
			self.m_OnlineGiftBtn:AddEffect("RedDot")
		else
			if self.m_OnlineTimer == nil then
				self.m_OnlineTimer = Utils.AddTimer(callback(self, "CheckOnlineGift"), 1, 0)
			end
			self.m_OnlineGiftBtn:DelEffect("RedDot")
			self.m_OnlineGiftBtn.m_Time:SetText(g_TimeCtrl:GetLeftTime(leftTime))
		end
	else
		self.m_OnlineGiftBtn:SetActive(false)
		self:TopGridReposition()
		self.m_OnlineTimer = nil
		return false
	end
	return true
end

function CMainMenuRT.OnCtrlActivityEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Activity.Event.DCAddTeam then
		self:DelayCall(0, "RefreshButton")
	elseif oCtrl.m_EventID == define.Activity.Event.DCLeaveTeam then
		self:DelayCall(0, "RefreshButton")

	elseif oCtrl.m_EventID == define.Activity.Event.DCUpdateTeam then
		self:DelayCall(0, "RefreshButton")

	elseif oCtrl.m_EventID == define.Activity.Event.DCRefreshTask then
		self:DelayCall(0, "RefreshButton")
	elseif oCtrl.m_EventID == define.Activity.Event.WolrdBossLeftTime then
		self:DelayCall(0, "RefreshButton")
	end
end

function CMainMenuRT.OnCtrlEquipFbEvent(self, oCtrl)
	if oCtrl.m_EventID == define.EquipFb.Event.BeginFb then
		self:DelayCall(0, "RefreshButton")

	elseif oCtrl.m_EventID == define.EquipFb.Event.EndFb then
		self:DelayCall(0, "RefreshButton")

	elseif oCtrl.m_EventID == define.EquipFb.Event.CompleteFB then
		self:DelayCall(0, "RefreshButton")
	end
end

function CMainMenuRT.OnCtrlMapEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Map.Event.ShowScene then
		self.m_MapNameLabel:SetText(oCtrl.m_SceneName)
		self.m_MapNameLabel:ReActive()
		self:DelayCall(0, "RefreshButton")		
	elseif oCtrl.m_EventID == define.Map.Event.MapLoadDone then
		self:DelayCall(0, "RefreshButton")
	elseif oCtrl.m_EventID == define.Map.Event.EnterScene then
	 	self:DelayCall(0, "RefreshButton")
	end
	self:RefreshMinMap()
end

function CMainMenuRT.OnCtrlAnLeilEvent( self, oCtrl)
	if oCtrl.m_EventID == define.AnLei.Event.BeginPatrol then
		self:DelayCall(0, "RefreshButton")
	elseif oCtrl.m_EventID == define.AnLei.Event.EndPatrol then
		self:DelayCall(0, "RefreshButton")	
	elseif oCtrl.m_EventID == define.AnLei.Event.UpdateInfo then
		self:DelayCall(0, "RefreshButton")	
	end
end

function CMainMenuRT.OnFieldBossEvent(self, oCtrl)
	if oCtrl.m_EventID == define.FieldBoss.Event.UpadteBossList then
		self:DelayCall(0, "RefreshButton")
	end
end

function CMainMenuRT.CheckFieldBoss(self)
	local list = g_FieldBossCtrl:GetBossList()
	if list and #list > 0 and g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.fieldboss.open_grade 
		and g_ActivityCtrl:IsActivityVisibleBlock("fieldboss") then
		self.m_FieldBossBox:SetActive(true)
	else
		self.m_FieldBossBox:SetActive(false)
	end
	--self:TopGridReposition()
end

function CMainMenuRT.OnOpenFieldBoss(self)
	if g_ActivityCtrl:ActivityBlockContrl("fieldboss") then
		nethuodong.C2GSOpenFieldBossUI()
	end
end

function CMainMenuRT.OpenDailyCultivateView(self)
	g_GuideCtrl:ReqTipsGuideFinish("mainmenu_dailycultivate_btn")
	if g_ActivityCtrl:ActivityBlockContrl("lilian") then
		g_OpenUICtrl:WalkToDailyTrainNpc()
	end
end

function CMainMenuRT.CheckWorldBoss(self)
	if g_ActivityCtrl:IsOpen(1001) and g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.worldboss.open_grade and g_ActivityCtrl:IsActivityVisibleBlock("worldboss") then
		local wolrdBossLeftTime = g_ActivityCtrl:GetWolrdBossLeftTimeText()
		if wolrdBossLeftTime == nil then
			self.m_WorldBossBtn:SetActive(false)
			self:TopGridReposition()
		else
			if self.m_WorldBossTimerID == nil then
				self.m_WorldBossTimerID = Utils.AddTimer(callback(self, "CheckWorldBoss"), 1, 0)
			end
			if not self.m_WorldBossBtn:GetActive() then
				self.m_WorldBossBtn:SetActive(true)
				self:TopGridReposition()
			end
			self.m_WorldBossLeftTimeLabel:SetText(wolrdBossLeftTime)
			return true
		end
	else
		self.m_WorldBossBtn:SetActive(false)
		self:TopGridReposition()
	end
	self.m_WorldBossTimerID = nil
	return false
end

function CMainMenuRT.Destroy(self)
	self:DelArenaTimer()
	self:DelAnleiTimer()
	self:DelWorldBossTimer()
	self:DelOnlineTimer()
	CViewBase.Destroy(self)
end

function CMainMenuRT.DelWorldBossTimer(self)
	if self.m_WorldBossTimerID ~= nil then
		Utils.DelTimer(self.m_WorldBossTimerID)
		self.m_WorldBossTimerID = nil
	end
end

function CMainMenuRT.OnForeTell(self)
	CForetellView:ShowView(function (oView)
		oView:SetData(self.m_ForetellBtn.m_Data)
	end)
end

function CMainMenuRT.CheckForetell(self)
	local oData = g_ForetellCtrl:GetCurrentData()
	if oData and g_ActivityCtrl:IsActivityVisibleBlock("foretell") then
		self.m_ForetellBtn.m_Data = oData
		self.m_ForetellBtn:SetActive(true)
		self.m_ForetellBtn.m_Sprite:SetSpriteName(oData.icon)
		self.m_ForetellBtn.m_Label:SetText(oData.name)
		self.m_ForetellBtn.m_DescLabel:SetText(oData.desc)
	else
		self.m_ForetellBtn:SetActive(false)
	end
end

function CMainMenuRT.Update(self)
	local oHero = g_MapCtrl:GetHero()
	if Utils.IsExist(oHero) then
		local pos = oHero:GetLocalPos()
		local sText = string.format("(%d,%d)", math.floor(pos.x), math.floor(pos.y))
		self.m_PosLabel:SetText(sText)
	end
	self:RefreshTime()
	return true
end

function CMainMenuRT.RefreshTime(self)
	local seconds = g_TimeCtrl:GetTimeS()
	self.m_TimeLabel:SetText(os.date("%H:%M", seconds))
end

function CMainMenuRT.RefreshDeviceStatus(self)
	self:RefreshNetWork()
	self:RefreshBattery()
	return true
end

function CMainMenuRT.RefreshNetWork(self)
	local status = 1
	if C_api.Utils.GetNetworkType() == "WIFI" then
		status = math.ceil((C_api.Utils.GetWifiSignal()/40)) + 1
	else
		status = 1
	end

	local netTable = {{1},{2},{2,3},{2,3,4}}
	if not self.m_NetWorkSpr then
		return
	end

	if self.m_CurNetWork ~= status then
		self.m_CurNetWork = status
		local showSprTable = netTable[status]
		for i,spr in ipairs(self.m_NetWorkSpr) do
			if table.index(showSprTable, i) then
				spr:SetActive(true)
			else
				spr:SetActive(false)
			end
		end
	end
end

function CMainMenuRT.RefreshBattery(self)
	local iBattery = C_api.Utils.GetBatteryLevel()
	-- print("电量："..iBattery)
	self.m_BatterySlider:SetValue(iBattery/100)
end

function CMainMenuRT.OnOpenMapView(self, idx)
	if g_ActivityCtrl:ActivityBlockContrl("map") then
		CMapMainView:ShowView(function (oView)
			oView:ShowSpecificPage(idx)
		end)
	end	
end

function CMainMenuRT.RefreshMinMap(self)
	local mapId = g_MapCtrl:GetMapID()
	local mapData = DataTools.GetMapData(mapId)
	local sprName = ""
	if mapData then
		mapId = mapData.resource_id * 100
		if mapId == 102000 then
			mapId = 101000
		end
	end
	if mapId then
		sprName = string.format("btn_mainmenu_map_%d_h", mapId)
	end
	if sprName then
		self.m_MiniMapBtn:SetSpriteName(sprName)
		self.m_MiniMapBtn:MakePixelPerfect()
	end

	--新手村，隐藏地图按钮
	self.m_MiniMapBtn:SetActive(mapId ~= 200100 or g_MapCtrl:IsVirtualScene())
end

function CMainMenuRT.InitNetWork(self)
	self.m_CurNetWork = 0
	local normalspr = self.m_NetBox:NewUI(1, CSprite)
	local wifispr1 = self.m_NetBox:NewUI(2, CSprite)
	local wifispr2 = self.m_NetBox:NewUI(3, CSprite)
	local wifispr3 = self.m_NetBox:NewUI(4, CSprite)
	self.m_NetWorkSpr = {normalspr, wifispr1, wifispr2, wifispr3}
end

function CMainMenuRT.TopGridReposition(self)
	local w, h = self.m_TopGrid:GetCellSize()
	local colm = self.m_TopGrid:GetColummLimit()
	local t = {}
	for i, v in ipairs(self.m_TopGrid:GetChildList()) do
		if v:GetActive() == true then
			table.insert(t, v)
		end
	end
	for i, v in ipairs(t) do
		local _w = ((i - 1)% colm) * (-w)
		local _h = math.floor((( i - 1) / colm)) * (-h)
		v:SetLocalPos(Vector3.New(_w, _h, 0))
	end
end

function CMainMenuRT.OnWorldBossBtn(self)
	if g_ActivityCtrl:ActivityBlockContrl("worldboss") then
		nethuodong.C2GSOpenBossUI()
	end	
end

--暗雷怪tips刷新
function CMainMenuRT.DelAnleiTimer(self)
	if self.m_AnLeiBoxTimer ~= nil then
		Utils.DelTimer(self.m_AnLeiBoxTimer)
		self.m_AnLeiBoxTimer = nil
	end
	if self.m_AnLeiNpcTimer ~= nil then
		Utils.DelTimer(self.m_AnLeiNpcTimer)
		self.m_AnLeiNpcTimer = nil
	end
end

function CMainMenuRT.RefreshAnLeiTips(self)
	self.m_AnLeiBoxBox:SetActive(false)
	self.m_AnLeiNpcBox:SetActive(false)
	self:DelAnleiTimer()
	if g_AnLeiCtrl:IsHaveNpc() and g_ActivityCtrl:IsActivityVisibleBlock("trapmine") then
		local time = g_AnLeiCtrl:GetMonsterLeftTime(1)
		if time ~= "" then
			self.m_AnLeiBoxBox:SetActive(true)
			local function cb()
				if Utils.IsNil(self) then
					return false
				end							
				local cbTime = g_AnLeiCtrl:GetMonsterLeftTime(1)
				if cbTime ~= "" then
					self.m_AnLeiBoxBox.m_Time:SetText(cbTime)
					return true
				else
					self.m_AnLeiBoxBox:SetActive(false)
					return false
				end
			end
			local shape = g_AnLeiCtrl:GetMonsterShape(1)
			if shape ~= 0 then
				self.m_AnLeiBoxBox.m_Icon:SpriteAvatar(shape)
			end			
			local name = g_AnLeiCtrl:GetMonsterName(1)
			if name and name ~= "" then
				self.m_AnLeiBoxBox.m_Name:SetText(name)
			end	
			self.m_AnLeiBoxBox.m_Time:SetText(time)
			self.m_AnLeiBoxTimer = Utils.AddTimer(cb, 1, 0)
		end

		time = g_AnLeiCtrl:GetMonsterLeftTime(2)
		if time ~= "" then
			self.m_AnLeiNpcBox:SetActive(true)
			local function cb()
				if Utils.IsNil(self) then
					return false
				end							
				local cbTime = g_AnLeiCtrl:GetMonsterLeftTime(2)
				if cbTime ~= "" then
					self.m_AnLeiNpcBox.m_Time:SetText(cbTime)
					return true
				else
					self.m_AnLeiNpcBox:SetActive(false)						
					return false
				end
			end
			local shape = g_AnLeiCtrl:GetMonsterShape(2)
			if shape ~= 0 then
				self.m_AnLeiNpcBox.m_Icon:SpriteAvatar(shape)
			end			
			local name = g_AnLeiCtrl:GetMonsterName(2)
			if name and name ~= "" then
				self.m_AnLeiNpcBox.m_Name:SetText(name)
			end	
			self.m_AnLeiNpcBox.m_Time:SetText(time)
			self.m_AnLeiNpcTimer = Utils.AddTimer(cb, 1, 0)
		end		
	end
	--self:TopGridReposition()
end

function CMainMenuRT.RefreshAnLeiBtn(self)  		
	self.m_AnLeiBtn:SetActive(false)	
	-- if g_AnLeiCtrl:IsInAnLei() or not g_ActivityCtrl:IsActivityVisibleBlock("trapmine")
	-- 	or g_AttrCtrl.grade < data.globalcontroldata.GLOBAL_CONTROL.trapmine.open_grade then
	-- 	self.m_AnLeiBtn:SetActive(false)
	-- end
	--self:TopGridReposition()
end

function CMainMenuRT.OnAnLeiBtn(self)
	if g_ActivityCtrl:ActivityBlockContrl("trapmine") then
		g_MainMenuCtrl:OpenWoldMap({key = "anlei"})
	end	
end

function CMainMenuRT.OnFindAnLeiBox(self)
	if g_ActivityCtrl:ActivityBlockContrl("trapmine") then
		if g_AnLeiCtrl:IsInAnLei() then
			g_NotifyCtrl:FloatMsg("请退出探索后进行。")
		else
			g_AnLeiCtrl:WalkToNpcByType(1)
		end
	end
end

function CMainMenuRT.OnFindAnLeiNpc(self)
	if g_ActivityCtrl:ActivityBlockContrl("trapmine") then
		if g_AnLeiCtrl:IsInAnLei() then
			g_NotifyCtrl:FloatMsg("请退出探索后进行。")
		else
			g_AnLeiCtrl:WalkToNpcByType(2)
		end
	end
end

function CMainMenuRT.OnArenaBtn(self)
	if g_ActivityCtrl:ActivityBlockContrl("arenagame") then
		g_ArenaCtrl:ShowArena()
	end
end
function CMainMenuRT.OnTeamPvpBtn(self)
	if g_ActivityCtrl:ActivityBlockContrl("teampvp") then
		g_TeamPvpCtrl:ShowArena()
	end
end
function CMainMenuRT.OnEqualArenaBtn(self)
	if g_ActivityCtrl:ActivityBlockContrl("equalarena") then
		g_EqualArenaCtrl:ShowArena()
	end
end

function CMainMenuRT.CheckArena(self)
	if g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.arenagame.open_grade and g_ActivityCtrl:IsActivityVisibleBlock("arenagame") then
		local arenaLeftTime = g_ArenaCtrl:GetLeftTimeText()
		if arenaLeftTime == nil then
			self.m_ArenaBtn:SetActive(false)
			self:TopGridReposition()
		else
			if self.m_ArenaTimerID == nil then
				self.m_ArenaTimerID = Utils.AddTimer(callback(self, "CheckArena"), 1, 0)
			end
			if not self.m_ArenaBtn:GetActive() then
				self.m_ArenaBtn:SetActive(true)
				self:TopGridReposition()
			end
			self.m_ArenaLeftTimeLabel:SetText(arenaLeftTime)
			return true
		end
	else
		self.m_ArenaBtn:SetActive(false)
		self:TopGridReposition()
	end
	self.m_ArenaTimerID = nil
	return false
end

function CMainMenuRT.CheckEqualArena(self)
	if g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.equalarena.open_grade and g_ActivityCtrl:IsActivityVisibleBlock("equalarena") then
		local arenaLeftTime = g_EqualArenaCtrl:GetLeftTimeText()
		if arenaLeftTime == nil then
			self.m_EqualArenaBox:SetActive(false)
			self:TopGridReposition()
		else
			if self.m_EqualArenaTimerID == nil then
				self.m_EqualArenaTimerID = Utils.AddTimer(callback(self, "CheckEqualArena"), 1, 0)
			end
			if not self.m_EqualArenaBox:GetActive() then
				self.m_EqualArenaBox:SetActive(true)
				self:TopGridReposition()
			end
			self.m_EqualArenaBox.m_TimeLabel:SetText(arenaLeftTime)
			return true
		end
	else
		self.m_EqualArenaBox:SetActive(false)
		self:TopGridReposition()
	end
	self.m_EqualArenaTimerID = nil
	return false
end

function CMainMenuRT.CheckOrgWar(self)
	self.m_OrgWarBtn:SetActive(g_OrgWarCtrl:IsInWar() and g_ActivityCtrl:IsActivityVisibleBlock("orgwar"))
	if g_OrgWarCtrl:IsPreParing() then
		self.m_OrgWarBtn.m_Time:SetText(string.format("%s开启", g_TimeCtrl:GetLeftTime(g_OrgWarCtrl:GetPrepareTime())))
	elseif g_OrgWarCtrl:IsFighting() then
		self.m_OrgWarBtn.m_Time:SetText(g_TimeCtrl:GetLeftTime(g_OrgWarCtrl:GetRestTime()))
	end
	self:TopGridReposition()
end

function CMainMenuRT.CheckTeamPvp(self)
	if g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.teampvp.open_grade and g_ActivityCtrl:IsActivityVisibleBlock("teampvp") then
		local iOpenTime = g_TeamPvpCtrl:GetStartLeftTime()
		local iLeftTime = g_TeamPvpCtrl:GetEndLeftTime()
		if iLeftTime < 0 then
			self.m_TeamPvpBox:SetActive(false)
			self:TopGridReposition()
		else
			if self.m_TeamPvpTimerID == nil then
				self.m_TeamPvpTimerID = Utils.AddTimer(callback(self, "CheckTeamPvp"), 1, 0)
			end
			if not self.m_TeamPvpBox:GetActive() then
				self.m_TeamPvpBox:SetActive(true)
				self:TopGridReposition()
			end
			if iOpenTime >= 0 then
				self.m_TeamPvpBox.m_TimeLabel:SetText(string.format("%s开启", g_TimeCtrl:GetLeftTime(iOpenTime)))
			else
				self.m_TeamPvpBox.m_TimeLabel:SetText(g_TimeCtrl:GetLeftTime(iLeftTime))
			end
			return true
		end
	else
		self.m_TeamPvpBox:SetActive(false)
		self:TopGridReposition()
	end
	self.m_TeamPvpTimerID = nil
	return false
end

function CMainMenuRT.DelArenaTimer(self)
	if self.m_ArenaTimerID ~= nil then
		Utils.DelTimer(self.m_ArenaTimerID)
		self.m_ArenaTimerID = nil
	end
end

function CMainMenuRT.DelOnlineTimer(self)
	if self.m_OnlineTimer ~= nil then
		Utils.DelTimer(self.m_OnlineTimer)
		self.m_OnlineTimer = nil
	end
end

function CMainMenuRT.OnArenaEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Arena.Event.OnReceiveLeftTime then
		self:DelayCall(0, "RefreshButton")
	end
end

function CMainMenuRT.InitTopGrid(self)
	self.m_TopGrid:InitChild(function (obj, idx)
		local oBox = CBox.New(obj)
		return oBox
	end)
	self:TopGridReposition()
end

function CMainMenuRT.CheckPowerGuide(self)
	self.m_PowerGuideBtn:SetActive(g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.powerguide.open_grade and g_ActivityCtrl:IsActivityVisibleBlock("powerguide"))	 
	local b = g_PowerGuideCtrl:IsPowerHeroRedDot() or g_PowerGuideCtrl:IsPowerPartnerRedDot()
	if b and not g_PowerGuideCtrl.m_IsShowMainMenuRedDot then
		self.m_PowerGuideBtn:AddEffect("RedDot")
	else
		self.m_PowerGuideBtn:DelEffect("RedDot")
	end
end

function CMainMenuRT.OnTerrawarEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Terrawar.Event.State then
		self:DelayCall(0, "RefreshButton")
	end
end

function CMainMenuRT.CheckTerrawar(self)
	if g_ActivityCtrl:IsActivityVisibleBlock("terrawars") then
		local txt = g_TerrawarCtrl:GetTerrawarTipsTxt()
		if txt and g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.terrawars.open_grade then
			self.m_TerrwarBox:SetActive(true)
			self.m_TerrwarBox.m_Time:SetText(txt)
			if self.m_TerrawarTimerID == nil then
				self.m_TerrawarTimerID = Utils.AddTimer(callback(self, "CheckTerrawar"), 1, 0)
			end
			return true
		else
			self.m_TerrwarBox:SetActive(false)
		end
	else
		self.m_TerrwarBox:SetActive(false)
	end
	self.m_TerrawarTimerID = nil
	return false
end

function CMainMenuRT.OnTerrwar(self)
	if g_ActivityCtrl:ActivityBlockContrl("terrawars") then
		if g_AttrCtrl.org_id == 0 then
	   		g_NotifyCtrl:FloatMsg("请先加入公会")
	   	else
			g_TerrawarCtrl:C2GSTerrawarMain()
		end
	end
end

function CMainMenuRT.OnWelfareEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Welfare.Event.OnSevenDayTargetRedDot then
		self:DelayCall(0, "SevenDayTargetRedDot")
	elseif oCtrl.m_EventID == define.Welfare.Event.OnSevenDayTarget then
		self:DelayCall(0, "RefreshButton")
	elseif oCtrl.m_EventID == define.Welfare.Event.OnFirstCharge then
		self:DelayCall(0, "CheckFirstCharge")
	elseif oCtrl.m_EventID == define.Welfare.Event.UpdateDrawCnt then
		self:DelayCall(0, "CheckLimitReward")
	elseif oCtrl.m_EventID == define.Welfare.Event.UpdateCostPoint then
		self:DelayCall(0, "CheckLimitReward")
	elseif oCtrl.m_EventID == define.Welfare.Event.OnHistoryRecharge then
		self:DelayCall(0, "CheckLimitReward")
	elseif oCtrl.m_EventID == define.Welfare.Event.UpdateLimitPay then
		self:DelayCall(0, "CheckLimitReward")
	elseif oCtrl.m_EventID == define.Welfare.Event.UpdateLoopPay then
		self:DelayCall(0, "CheckLimitReward")
	end
	self:DelayCall(0, "CheckWelfare")
end

function CMainMenuRT.CheckWelfare(self)
	if g_WelfareCtrl:IsNeedRedDot() then
		self.m_WelfareBtn:AddEffect("RedDot")
	else
		self.m_WelfareBtn:DelEffect("RedDot")
	end
	if not g_WelfareCtrl.m_IsShowTestWelfareRedDot then
		self.m_TestWelfareBtn:AddEffect("circle")
	end
end

function CMainMenuRT.CheckSevenDayTarget(self)
	if g_ActivityCtrl:IsActivityVisibleBlock("sevendaytarget") then
		self.m_SevenDayTargetBtn:SetActive(g_WelfareCtrl:IsOpenSevenDayTarget())
		return true
	end
	self.m_SevenDayTargetBtn:SetActive(false)
	return false
end

function CMainMenuRT.SevenDayTargetRedDot(self)
	if g_WelfareCtrl:IsSevenDayTargetRedDot() then
		self.m_SevenDayTargetBtn:AddEffect("RedDot")
	else
		self.m_SevenDayTargetBtn:DelEffect("RedDot")
	end
end

function CMainMenuRT.OnSevenDayTarget(self, obj)
	if g_ActivityCtrl:ActivityBlockContrl("sevendaytarget") then
		g_WelfareCtrl:ForceSelect(define.Welfare.ID.SevenDayTarget)
	end
end

function CMainMenuRT.CheckFirstCharge(self)
	if g_WelfareCtrl:IsOpenFirstCharge() and g_ActivityCtrl:IsActivityVisibleBlock("FirstCharge") then		
		self.m_FirstChargeBox:SetActive(true) 
		self.m_FirstChargeBox.m_Btn:SetText("首充")
		self.m_FirstChargeBox.m_UIEffect:SetActive(g_WelfareCtrl:IsFirstChargeEff())
		if g_WelfareCtrl:IsFirstChargeRedDot() then
			self.m_FirstChargeBox:AddEffect("RedDot")
		else
			self.m_FirstChargeBox:DelEffect("RedDot")
		end
	elseif g_WelfareCtrl:IsOpenNeiChong() and g_ActivityCtrl:IsActivityVisibleBlock("FirstCharge") then		
		self.m_FirstChargeBox.m_Btn:SetText("累充")
		local lData = {}
		for k,v in pairs(data.welfaredata.TotalRecharge) do
			table.insert(lData, v)
		end
		local function sortFunc(v1, v2)
			return v1.condition < v2.condition
		end
		table.sort(lData, sortFunc)
		local value = g_WelfareCtrl.m_HistoryChargeDegree
		for i,v in ipairs(lData) do
			local bGot = g_WelfareCtrl.m_HistoryGotList[v.id]
			if value >= v.condition and not bGot then
				self.m_FirstChargeBox:AddEffect("RedDot")
				break
			else
				self.m_FirstChargeBox:DelEffect("RedDot")
			end
		end
		self.m_FirstChargeBox.m_UIEffect:SetActive(false)
		self.m_FirstChargeBox:SetActive(true)
	else
		self.m_FirstChargeBox:SetActive(false)		
	end
	local isViewShow = true
	local oView = CMainMenuView:GetView()
	if oView then
		isViewShow = oView.m_IsShowView
	end
	self.m_ChargeBtn:SetActive(isViewShow and (g_WelfareCtrl:IsOpenNeiChong() or g_WelfareCtrl:IsOpenFirstCharge()))

end

function CMainMenuRT.OnFirstChargeBtn(self, obj)
	if g_WelfareCtrl:IsOpenFirstCharge() and g_ActivityCtrl:ActivityBlockContrl("FirstCharge") then
		CFirstChargeView:ShowView()
		g_WelfareCtrl:SetFirstChargeEff(true)
	else
		CLimitRewardView:ShowView(function (oView)
			oView:OnSwitchPage(2)
		end)
	end
end

function CMainMenuRT.OnChargeBtn(self, obj)
	if g_ActivityCtrl:ActivityBlockContrl("FirstCharge") then
		g_SdkCtrl:ShowPayView()
	end
end

function CMainMenuRT.OnChapterFuBenBtn(self, obj)
	if g_ActivityCtrl:ActivityBlockContrl("chapterfuben") then
		CChapterFuBenMainView:ShowView(function (oView)
			oView:DefaultChapterInfo()
		end)
	end	
end

function CMainMenuRT.OnChapterFuBenEvent(self, oCtrl)
	if oCtrl.m_EventID == define.ChapterFuBen.Event.OnChapterOpen then
		self:DelayCall(0, "CheckChapterFuBen")
	end
end

function CMainMenuRT.CheckChapterFuBen(self)
	self.m_ChapterFuBenBtn:SetActive(false)
	--self.m_ChapterFuBenBtn:SetActive(g_ChapterFuBenCtrl:IsOpenChapterFuBen() and g_ActivityCtrl:IsActivityVisibleBlock("chapterfuben") )
end

function CMainMenuRT.OnMonsterAtkCity(self, obj)
	if g_ActivityCtrl:ActivityBlockContrl("MonsterAtk") then
		CMonsterAtkCityMainView:ShowView()
	end
end

function CMainMenuRT.OnMonsterAtkCityEvnet(self, oCtrl)
	if oCtrl.m_EventID == define.MonsterAtkCity.Event.Open then
		self:DelayCall(0, "RefreshButton")
	elseif oCtrl.m_EventID == define.MonsterAtkCity.Event.Yure then
		self:DelayCall(0, "RefreshButton")
	end
end

function CMainMenuRT.CheckMonsterAtkCity(self)
	if g_ActivityCtrl:IsActivityVisibleBlock("MonsterAtk") then
		local txt
		if g_MonsterAtkCityCtrl:IsYure() then
			txt = g_MonsterAtkCityCtrl:GetYureTxt()
		elseif g_MonsterAtkCityCtrl:IsOpen() then
			txt = g_MonsterAtkCityCtrl:GetLeftTimeTxt()
		end
		if txt then
			self.m_MonsterAtkCityBox:SetActive(true)
			self.m_MonsterAtkCityBox.m_Time:SetText(txt)
			if self.m_MonsterAtkTimerID == nil then
				self.m_MonsterAtkTimerID = Utils.AddTimer(callback(self, "CheckMonsterAtkCity"), 1, 0)
			end
			return true
		else
			self.m_MonsterAtkCityBox:SetActive(false)
		end
	else
		self.m_MonsterAtkCityBox:SetActive(false)
	end
	self.m_MonsterAtkTimerID = nil
	return false
end

function CMainMenuRT.OnShowView(self)
	g_GuideCtrl:AddGuideUI("mainmenu_minimap_btn", self.m_MiniMapBtn)
	g_GuideCtrl:AddGuideUI("mainmenu_powerguide_btn", self.m_PowerGuideBtn)
	g_GuideCtrl:AddGuideUI("mainmenu_loginreward_btn", self.m_LoginRewardBtn)
	g_GuideCtrl:AddGuideUI("mainmenu_anlei_btn", self.m_AnLeiBtn)
	g_GuideCtrl:AddGuideUI("mainmenu_dailycultivate_btn", self.m_DailyCultivateBtn)
	g_GuideCtrl:AddGuideUI("operate_welfare_btn", self.m_WelfareBtn)

	local guide_ui = {"mainmenu_loginreward_btn", "mainmenu_powerguide_btn", "mainmenu_dailycultivate_btn"}
	g_GuideCtrl:LoadTipsGuideEffect(guide_ui)	
end

function CMainMenuRT.OnRankBtn(self)
	g_RankCtrl:OpenRank()
end

function CMainMenuRT.CheckLimitReward(self)
	if CLimitRewardView:IsHasRedDot() then
		self.m_LimitRewardBtn:AddEffect("RedDot")
	else
		self.m_LimitRewardBtn:DelEffect("RedDot")
	end
end

function CMainMenuRT.OnOpenLimieReward(self)
	if g_ActivityCtrl:ActivityBlockContrl("LimitReward") then
		CLimitRewardView:ShowView()
	end
end

function CMainMenuRT.OnOpenWelfare(self)
	if main.g_AppType  == "shenhe" then
		g_NotifyCtrl:FloatMsg("该功能暂未开放")
		return
	end
	if g_ActivityCtrl:ActivityBlockContrl("welfare") then
		CWelfareView:ShowView(function (oView)
			oView:ShowDefaultPage()
		end)
	end
end

function CMainMenuRT.OnOpenTestWelfare(self)
	if main.g_AppType  == "shenhe" then
		g_NotifyCtrl:FloatMsg("该功能暂未开放")
		return
	end
	if g_ActivityCtrl:ActivityBlockContrl("test_welfare") then
		g_WelfareCtrl.m_IsShowTestWelfareRedDot = true
		self.m_TestWelfareBtn:DelEffect("circle")
		CWelfareView:ShowView(function (oView)
			oView:ShowTestDefalutPage()
		end)
	end
end

function CMainMenuRT.CheckQuestion(self)
	local oView = CMainMenuView:GetView()
	if oView and oView.m_LB and oView.m_LB.CheckUI then
		oView.m_LB:CheckUI()
	end
end

function CMainMenuRT.ShowEffectFire(self)
	self.m_EqualArenaBox:AddEffect("fire")
	self.m_ArenaBox:AddEffect("fire")
	self.m_WorldBossBtn:AddEffect("fire")
	self.m_OrgWarBtn:AddEffect("fire")
	self.m_MonsterAtkCityBox:AddEffect("fire")
	self.m_TeamPvpBox:AddEffect("fire")
end

function CMainMenuRT.OnOpenYybBbs(self)
	g_AndroidCtrl:StartYsdkBbs()
end

function CMainMenuRT.OnOpenVPlus(self)
	g_AndroidCtrl:StartYsdkVip()
end

function CMainMenuRT.OnOpenQQVip(self)
	CWelfareView:ShowView(function (oView)
		oView:ForceSelect(18)
	end)
end

return CMainMenuRT