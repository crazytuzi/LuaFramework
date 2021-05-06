local CMainMenuOperateView = class("CMainMenuOperateView", CViewBase)

function CMainMenuOperateView.ctor(self, cb)
	CViewBase.ctor(self, "UI/MainMenu/MainMenuOperateView.prefab", cb)

	self.m_ExtendClose = "ClickOut"
	
end

function CMainMenuOperateView.OnCreateView(self)
	self.m_BtnGrid = self:NewUI(1, CGrid)
	self.m_PartnerBtn = self:NewUI(2, CButton)
	self.m_SkillBtn = self:NewUI(3, CButton)
	self.m_Container = self:NewUI(4, CWidget)
	self.m_SystemSettingsBtn = self:NewUI(5, CButton)
	self.m_ForgeBtn = self:NewUI(6, CButton)
	self.m_CardBtn = self:NewUI(7, CButton)
	self.m_ArenaBtn = self:NewUI(8, CButton)
	self.m_RankBtn = self:NewUI(9, CButton)
	self.m_WorldBossBtn = self:NewUI(10, CButton)
	self.m_PaTaBtn = self:NewUI(11, CButton)
	self.m_OrgBtn = self:NewUI(12, CButton)
	self.m_MapBookBtn = self:NewUI(13, CButton)
	self.m_LeiTaiBtn = self:NewUI(14, CButton)
	self.m_AchieveBtn = self:NewUI(15, CButton)
	self.m_AnLeiBtn = self:NewUI(16, CButton)
	self.m_TerrwarBtn = self:NewUI(17, CButton)
	self.m_TravelBtn = self:NewUI(18, CButton)
	self.m_ChapterFuBenBtn = self:NewUI(19, CButton)
	self.m_LiLianBtn = self:NewUI(20, CButton)
	self.m_ToggleTimer = nil

	self.m_Container.m_TweenPos = self.m_Container:GetComponent(classtype.TweenPosition)
	self:IntContent()
end

function CMainMenuOperateView.IntContent(self)
	self.m_PartnerBtn:AddUIEvent("click", callback(self, "OnPartner", "partner"))
	self.m_SkillBtn:AddUIEvent("click", callback(self, "OnSkill", "skill"))
	self.m_ForgeBtn:AddUIEvent("click", callback(self, "OnForge", "forge"))
	self.m_CardBtn:AddUIEvent("click", callback(self, "OnCardBtn", "draw_card"))
	self.m_ArenaBtn:AddUIEvent("click", callback(self, "OnArenaBtn", "arenagame"))
	self.m_RankBtn:AddUIEvent("click", callback(self, "OnRankBtn", "rank"))
	self.m_WorldBossBtn:AddUIEvent("click", callback(self,"OnWorldBoss", "worldboss"))
	self.m_SystemSettingsBtn:AddUIEvent("click", callback(self, "OnSysSetting", "sys_setting"))
	self.m_PaTaBtn:AddUIEvent("click", callback(self, "OnPaTa", "pata"))
	self.m_OrgBtn:AddUIEvent("click", callback(self, "OnOrgBtn", "org"))
	self.m_MapBookBtn:AddUIEvent("click", callback(self, "OnMapBook", "mapbook"))
	self.m_LeiTaiBtn:AddUIEvent("click", callback(self, "OnLeiTai", "leitai"))
	self.m_AchieveBtn:AddUIEvent("click", callback(self, "OnAchieve", "achieve"))
	self.m_TerrwarBtn:AddUIEvent("click", callback(self, "OnTerrwar", "terrawars"))
	self.m_TravelBtn:AddUIEvent("click", callback(self, "OnTravel", "travel"))
	self.m_AnLeiBtn:AddUIEvent("click", callback(self, "OnTrapmine", "trapmine"))
	self.m_LiLianBtn:AddUIEvent("click", callback(self, "OnLilian", "lilian"))
	self.m_ChapterFuBenBtn:AddUIEvent("click", callback(self, "OnChapterFuBenBtn", "chapterfuben"))
	
	self.m_TravelBtn.m_IgnoreCheckEffect = true
	self.m_ForgeBtn.m_IgnoreCheckEffect = true
	self.m_AchieveBtn.m_IgnoreCheckEffect = true
	self.m_OrgBtn.m_IgnoreCheckEffect = true
	self.m_SkillBtn.m_IgnoreCheckEffect = true
	self.m_ChapterFuBenBtn.m_IgnoreCheckEffect = true
	self.m_LiLianBtn.m_IgnoreCheckEffect = true
	self.m_PaTaBtn.m_IgnoreCheckEffect = true

	--隐藏部分功能 
	self.m_PartnerBtn:SetActive(false)
	self.m_ChapterFuBenBtn:SetActive(false)
	self.m_OrgBtn:SetActive(false)
	self.m_RankBtn:SetActive(false)

	local w, h = UITools.GetRootSize()
	self.m_Container.m_TweenPos.from =  Vector3.New(math.floor(w / 2 + 373 ), 0, 0) 
	self.m_Container.m_TweenPos.to = Vector3.New(math.floor(w / 2 - 100)  , 0, 0) 
	self.m_Container.m_TweenPos:Toggle()
	self:CheckOpenGrade()
	self:RefreshRedDot()
	self:CheckOrgRedDot()
	g_OrgCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnOrgEvent"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnNotify"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))
	g_AchieveCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAchieveCtrl"))
	g_MapBookCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnMapBookCtrlEvent"))
	g_TravelCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTravelCtrl"))
	g_ChapterFuBenCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnChapterFuBenEvent"))
	g_GuideCtrl:AddGuideUI("operate_drawcard_btn", self.m_CardBtn)
	g_GuideCtrl:AddGuideUI("operate_map_book_btn", self.m_MapBookBtn)
	g_GuideCtrl:AddGuideUI("operate_pata_btn", self.m_PaTaBtn)
	g_GuideCtrl:AddGuideUI("operate_skill_btn", self.m_SkillBtn)
	g_GuideCtrl:AddGuideUI("operate_arnea_btn", self.m_ArenaBtn)
	g_GuideCtrl:AddGuideUI("operate_lilian_btn", self.m_LiLianBtn)
	local guide_ui = {"operate_lilian_btn", "operate_drawcard_btn", "operate_map_book_btn", "operate_pata_btn", "operate_skill_btn", "operate_arnea_btn"}
	g_GuideCtrl:LoadTipsGuideEffect(guide_ui)

end

--模块开放等级
function CMainMenuOperateView.CheckOpenGrade(self)
	self.m_RankBtn:SetActive(false)
	--self.m_RankBtn:SetActive(g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.rank.open_grade)
	self.m_ArenaBtn:SetActive(g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.arenagame.open_grade)
	--self.m_OrgBtn:SetActive(g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.org.open_grade)
	self.m_PaTaBtn:SetActive(g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.pata.open_grade)
	--self.m_WorldBossBtn:SetActive(g_ActivityCtrl:IsOpen(1001) and g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.worldboss.open_grade)
	self.m_WorldBossBtn:SetActive(false)
	--self.m_CardBtn:SetActive(g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.draw_card.open_grade)
	self.m_CardBtn:SetActive(false)
	self.m_MapBookBtn:SetActive(g_MapBookCtrl:IsOpen())
	self.m_SkillBtn:SetActive(g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.school_skill.open_grade)
	--self.m_ForgeBtn:SetActive(g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.forge.open_grade)
	self.m_ForgeBtn:SetActive(false)
	self.m_AchieveBtn:SetActive(g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.achieve.open_grade)
	--self.m_TerrwarBtn:SetActive(g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.terrawars.open_grade)
	self.m_TerrwarBtn:SetActive(false)
	self.m_TravelBtn:SetActive(g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.travel.open_grade)
	--self.m_ChapterFuBenBtn:SetActive(g_ChapterFuBenCtrl:IsOpenChapterFuBen() and g_ActivityCtrl:IsActivityVisibleBlock("chapterfuben") )
	self.m_AnLeiBtn:SetActive(g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.trapmine.open_grade)
	self.m_LiLianBtn:SetActive(g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.dailytrain.open_grade)
	self.m_BtnGrid:Reposition()
end

function CMainMenuOperateView.OnNotify(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self:CheckOpenGrade()
		self:CheckOrgRedDot()
	end
end

function CMainMenuOperateView.OnOrgEvent(self, oCtrl)
	self:CheckOrgRedDot()
end

function CMainMenuOperateView.OnCtrlItemEvent( self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshBagItem or
	oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem then		
		self:RefreshRedDot()
	end
end

function CMainMenuOperateView.OnAchieveCtrl(self, oCtrl)
	self:RefreshRedDot()
end

function CMainMenuOperateView.OnMapBookCtrlEvent(self, oCtrl)
	self:RefreshMapBookRedDot()
end

function CMainMenuOperateView.OnTravelCtrl(self, oCtrl)
	self:RefreshRedDot()
end

function CMainMenuOperateView.OnChapterFuBenEvent(self, oCtrl)
	if oCtrl.m_EventID == define.ChapterFuBen.Event.OnLogin or 
	oCtrl.m_EventID == define.ChapterFuBen.Event.OnUpdateChapterExtraReward or
	oCtrl.m_EventID == define.ChapterFuBen.Event.OnUpdateChapterTotalStar then
		self:RefreshChapterFuBenRedDot()
	end
end

function CMainMenuOperateView.OnLeiTai(self, key)
	if self:CheckOpenCondition(key) then		
		g_LeiTaiCtrl:OpenLeitai()
		self:CloseView()
	end
end

function CMainMenuOperateView.OnAchieve(self, key)
	if self:CheckOpenCondition(key) then
		g_AchieveCtrl:C2GSAchieveMain()
		self:CloseView()
	end
end

function CMainMenuOperateView.OnOrgBtn(self, key)
	if self:CheckOpenCondition(key) then
		g_OrgCtrl:OpenOrg()
		self:CloseView()
	end
end

function CMainMenuOperateView.OnWorldBoss(self, key)
	if self:CheckOpenCondition(key) then
		nethuodong.C2GSOpenBossUI()
		self:CloseView()
	end
end

function CMainMenuOperateView.OnSysSetting(self, key)
	if self:CheckOpenCondition(key) then	
		CSysSettingView:ShowView()
		self:CloseView()
	end
end

function CMainMenuOperateView.OnForge(self, key)
	if self:CheckOpenCondition(key) then	
		CForgeMainView:ShowView()
		self:CloseView()
	end		
end

function CMainMenuOperateView.OnCardBtn(self, key)
	if self:CheckOpenCondition(key) then	
		g_GuideCtrl:ReqTipsGuideFinish("operate_drawcard_btn")
		g_ChoukaCtrl:StartChouka()
		self:CloseView()
	end
end

function CMainMenuOperateView.OnPartner(self, key)
	if self:CheckOpenCondition(key) then		
		CPartnerMainView:ShowView(function(oView)
			oView:ShowFirstPage()
		end)
		self:CloseView()
	end
end

function CMainMenuOperateView.OnSkill(self, key)
	g_GuideCtrl:ReqTipsGuideFinish("operate_skill_btn")
	if self:CheckOpenCondition(key) then	
		CSkillMainView:ShowView()
		self:CloseView()
	end
end

function CMainMenuOperateView.OnArenaBtn(self, key)
	g_GuideCtrl:ReqTipsGuideFinish("operate_arnea_btn")
	if self:CheckOpenCondition(key) then		
		g_ClubArenaCtrl:ShowArena()
		self:CloseView()
	end
end

function CMainMenuOperateView.OnTerrwar(self, key)
	if self:CheckOpenCondition(key) then
		if g_AttrCtrl.org_id == 0 then
	   		g_NotifyCtrl:FloatMsg("请先加入公会")
	   	else
			g_TerrawarCtrl:C2GSTerrawarMain()
		end
	end
end

function CMainMenuOperateView.OnTravel(self, key)
	if self:CheckOpenCondition(key) then
		CTravelView:ShowView()
	end
end

function CMainMenuOperateView.OnChapterFuBenBtn(self, key)
	if self:CheckOpenCondition(key) then
		CChapterFuBenMainView:ShowView(function (oView)
			oView:DefaultChapterInfo()
		end)
	end	
end

function CMainMenuOperateView.OnRankBtn(self, key)
	if self:CheckOpenCondition(key) then
		g_RankCtrl:OpenRank()
		self:CloseView()
	end
end

function CMainMenuOperateView.OnPaTa(self, key)
	if self:CheckOpenCondition(key) then
		g_PataCtrl.m_IsClickOpen = true
		g_PataCtrl:PaTaEnterView()
		self:CloseView()
	end
end

function CMainMenuOperateView.OnMapBook(self, key)
	if self:CheckOpenCondition(key) then
		CMapBookView:ShowView()
		self:CloseView()
	end
end

function CMainMenuOperateView.OnToggleClose(self)
	if self.m_ToggleTimer ~= nil then
		Utils.DelTimer(self.m_ToggleTimer)
		self.m_ToggleTimer = nil
	end
	if self.m_BehidLayer then
		self.m_BehidLayer:SetActive(false)
	end
	self.m_Container.m_TweenPos:Toggle()
	Utils.AddTimer(callback(self, "OnClose"), 0.1, 0.4)
end

function CMainMenuOperateView.CloseView(self)
	self:OnToggleClose()
end

function CMainMenuOperateView.Destroy(self)	
	if self.m_ToggleTimer ~= nil then
		Utils.DelTimer(self.m_ToggleTimer)
		self.m_ToggleTimer = nil
	end
	CViewBase.Destroy(self)
end

function CMainMenuOperateView.OnClose(self)
	g_ViewCtrl:CloseView(self)
end

function CMainMenuOperateView.CheckOpenCondition(self, key)
	return g_ActivityCtrl:ActivityBlockContrl(key)
end

function CMainMenuOperateView.CheckOrgRedDot(self)
	if g_OrgCtrl:IsMainNeedRedDot() then
		self.m_OrgBtn:AddEffect("RedDot")
	else
		self.m_OrgBtn:DelEffect("RedDot")
	end
end

function CMainMenuOperateView.RefreshRedDot(self)
	local b = g_ItemCtrl:ShowForgeRedDotByType()
	if b == true then
		self.m_ForgeBtn:AddEffect("RedDot")
	else
		self.m_ForgeBtn:DelEffect("RedDot")
	end

	b = g_AchieveCtrl:HasAchieveRedDot()
	if b then
		self.m_AchieveBtn:AddEffect("RedDot")
	else
		self.m_AchieveBtn:DelEffect("RedDot")
	end

	b = g_SkillCtrl:IsCanLevelUp()
	if b then
		self.m_SkillBtn:AddEffect("RedDot")
	else
		self.m_SkillBtn:DelEffect("RedDot")
	end


	self:RefreshMapBookRedDot()
	self:RefreshTravelRedDot()
	self:RefreshChapterFuBenRedDot()
	self:RefreshPataRedDot()
end

function CMainMenuOperateView.RefreshMapBookRedDot(self)
	if g_MapBookCtrl:IsHasAward() then
		self.m_MapBookBtn:AddEffect("RedDot")
	else
		self.m_MapBookBtn:DelEffect("RedDot")
	end
end

function CMainMenuOperateView.RefreshTravelRedDot(self)
	if g_TravelCtrl:HasRedDot() then
		self.m_TravelBtn:AddEffect("RedDot")
	else
		self.m_TravelBtn:DelEffect("RedDot")
	end
end

function CMainMenuOperateView.RefreshChapterFuBenRedDot(self)
	if g_ChapterFuBenCtrl:HasRedDot() then
		self.m_ChapterFuBenBtn:AddEffect("RedDot")
	else
		self.m_ChapterFuBenBtn:DelEffect("RedDot")
	end		
end

function CMainMenuOperateView.OnTrapmine(self, key)
	if self:CheckOpenCondition(key) then
		g_MainMenuCtrl:OpenWoldMap({key = "anlei"})
		self:CloseView()
	end
end

function CMainMenuOperateView.OnLilian(self, key)
	g_GuideCtrl:ReqTipsGuideFinish("operate_lilian_btn")
	if self:CheckOpenCondition(key) then
		g_OpenUICtrl:WalkToDailyTrainNpc()
	end
end

function CMainMenuOperateView.RefreshPataRedDot(self)
	if g_PataCtrl:IsPataRedDot() then
		self.m_PaTaBtn:AddEffect("RedDot")
	else
		self.m_PaTaBtn:DelEffect("RedDot")
	end
end

return CMainMenuOperateView