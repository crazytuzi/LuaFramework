local CMainMenuRB = class("CMainMenuRB", CBox)

function CMainMenuRB.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_HBtnGrid = self:NewUI(1, CGrid)
	self.m_SwitchBtn = self:NewUI(2, CButton)
	self.m_ItemBtn = self:NewUI(3, CBox)
	self.m_ShopBtn = self:NewUI(4, CButton)
	self.m_PartnerBtn = self:NewUI(5, CButton)
	self.m_HouseBtn = self:NewUI(6, CButton)
	self.m_ScheduleBtn = self:NewUI(7, CButton)
	self.m_OrgBtn = self:NewUI(8, CButton)
	self.m_ChapterFuBenBtn = self:NewUI(9, CButton)
	self.m_LeftGrid = self:NewUI(10, CGrid)
	self.m_RightGrid = self:NewUI(11, CGrid)
	self.m_ScheduleBtnUITips = self:NewUI(12, CLabel)
	self.m_HuntBtn = self:NewUI(13, CButton)
	self.m_DardCardBtn = self:NewUI(14, CButton)
	self.m_ForgeBtn = self:NewUI(15, CButton)
	self.m_SwitchTipsBox = self:NewUI(16, CBox)
	self.m_IsOpen = false
	self:InitContent()
	self:DelayCall(0, "RefreshRedDot")
end

function CMainMenuRB.InitContent(self)
	self.m_TipsBoxDic = {}
	self.m_SwitchTipsBox:SetActive(false)
	self.m_HuntBtn:AddUIEvent("click", callback(self, "OnHuntBtn"))
	self.m_SwitchBtn:AddUIEvent("click", callback(self, "Switch"))
	-- self.m_HouseBtn:SetActive(false)
	self.m_ItemBtn:AddUIEvent("click", callback(self, "OnItem"))
	self.m_HouseBtn:AddUIEvent("click", callback(self, "OnHouseBtn"))
	self.m_ShopBtn:AddUIEvent("click", callback(self, "OpenShopView"))
	self.m_ScheduleBtn:AddUIEvent("click", callback(self, "OpenScheduleView"))
	self.m_ScheduleBtnUITips:AddUIEvent("click", callback(self, "OpenScheduleView"))
	self.m_ChapterFuBenBtn:AddUIEvent("click", callback(self, "OnChapterFuBenBtn", "chapterfuben"))
	self.m_OrgBtn:AddUIEvent("click", callback(self, "OnOrgBtn", "org"))
	self.m_PartnerBtn:AddUIEvent("click", callback(self, "OnShowPartner"))

	self.m_DardCardBtn:AddUIEvent("click", callback(self, "OnDrawCard"))
	self.m_ForgeBtn:AddUIEvent("click", callback(self, "OnForge"))

	self.m_SwitchBtn.m_IgnoreCheckEffect = true
	self.m_ScheduleBtn.m_IgnoreCheckEffect = true
	self.m_ItemBtn.m_IgnoreCheckEffect = true
	self.m_OrgBtn.m_IgnoreCheckEffect = true
	self.m_HouseBtn.m_IgnoreCheckEffect = true
	self.m_ForgeBtn.m_IgnoreCheckEffect = true
	self.m_PartnerBtn.m_IgnoreCheckEffect = true
	self.m_ChapterFuBenBtn.m_IgnoreCheckEffect = true
	self.m_HuntBtn.m_IgnoreCheckEffect = true

	g_ActivityCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlActivityEvent"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemlEvent"))	
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent"))
	g_MapCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlMapEvent"))
	g_AnLeiCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlAnLeilEvent"))	
	g_ScheduleCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnSchduleEvent"))	
	g_OrgCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnOrgEvent"))	
	g_TaskCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTaskEvent"))
	g_EquipFubenCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEquipFbEvent"))	
	g_FieldBossCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnFieldBossEvent"))
	g_TravelCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTravelEvent"))
	g_AchieveCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAchieveEvent"))
	g_HouseCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnHouseEvent"))
	g_MapBookCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnMapBookEvent"))
	g_PartnerCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnPartnerEvent"))
	g_ChapterFuBenCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnChapterFuBenEvent"))
	g_HuntPartnerSoulCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnHuntEvent"))
	self:RefreshButton()
	self:CheckRedDot()
	self:CheckOrgRedDot()
	self:CheckScheduleRedDot()
	self:RefreshScheduleBtnUITip()
	self:CheckHouseRedDot()
	self:CheckChapterFuBenRedDot()
	self:RefreshRedDot()
	self:CheckHuntRedDot()
	self:CheckPartnerRedPoint()
	self:CheckPartnerHireRedPoint()
end

function CMainMenuRB.CheckHouseRedDot(self)
	if g_HouseCtrl:IsMainNeedRedDot() then
		self.m_HouseBtn:AddEffect("RedDot")
	else
		self.m_HouseBtn:DelEffect("RedDot")
	end
end

function CMainMenuRB.OnHouseEvent(self, oCtrl)
	if oCtrl.m_EventID == define.House.Event.TouchRefresh 
		or oCtrl.m_EventID == define.House.Event.WorkDeskRefresh 
		or oCtrl.m_EventID == define.House.Event.GiveCntRefresh 
		or oCtrl.m_EventID == define.House.Event.HouseItemAdd 
		or oCtrl.m_EventID == define.House.Event.HouseItemDel 
		or oCtrl.m_EventID == define.House.Event.GiftRerfesh 
		or oCtrl.m_EventID == define.House.Event.PartnerRefresh 
		or oCtrl.m_EventID == define.House.Event.RefreshMainRedDot then
		
		self:DelayCall(0, "CheckHouseRedDot")
	end
end

function CMainMenuRB.Switch(self)
	g_GuideCtrl:ReqTipsGuideFinish("mainmenu_operate_btn")
	self.m_IsOpen = not self.m_IsOpen
	if not self.m_SwitchBtn.m_BgSpr then
		self.m_SwitchBtnBox = self:NewUI(2, CBox)
		self.m_SwitchBtn.m_BgSpr = self.m_SwitchBtnBox:NewUI(1, CSprite)		
	end
	local sSpriteName = self.m_IsOpen and "btn_zjm_tubia_zuozhan_2" or "btn_zjm_tubia_zuozhan_1"
	self.m_SwitchBtn.m_BgSpr:SetSpriteName(sSpriteName)
	if self.m_IsOpen then
		CMainMenuOperateView:ShowView(function(oView)
			oView:SetHideCB(function() self:Switch() end)
		end)
	end
	g_GuideCtrl:StopDelayClick()
end

function CMainMenuRB.OnAttrEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then		
		self:DelayCall(0, "RefreshButton")
		self:DelayCall(0, "CheckOrgRedDot")		
		if oCtrl.m_EventData["dAttr"]["grade"] or oCtrl.m_EventData["dAttr"]["skill_point"] then
			self:DelayCall(0, "CheckRedDot")
		end
	end
end

function CMainMenuRB.OnHouseBtn(self)
	if g_ActivityCtrl:ActivityBlockContrl("house") then
		local oHero = g_MapCtrl:GetHero()
		if oHero then
			oHero:StopWalk()
		end
		g_GuideCtrl:ReqTipsGuideFinish("mainmenu_house_btn")
		g_GuideCtrl:CheckHouseOpenGuide()
		nethouse.C2GSEnterHouse(g_AttrCtrl.pid)
	end
end

function CMainMenuRB.OnItem(self)
	if CItemQuickUseView:GetView() ~= nil then
		CItemQuickUseView:CloseView()
	end	
	CItemBagMainView:ShowView()
end

function CMainMenuRB.OnHuntBtn(self)
	g_GuideCtrl:ReqTipsGuideFinish("mainmenu_hunt_btn")
	g_OpenUICtrl:OpenHuntPartnerSoul()
end

function CMainMenuRB.OnCtrlItemlEvent( self, oCtrl)
	-- if oCtrl.m_EventID == define.Item.Event.RefreshItemGetRedDot then
		
	-- end
	self:DelayCall(0, "RefreshRedDot")
	local eventData = oCtrl.m_EventData
	if oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem then
		if eventData and eventData:IsPartnerChip() then
			self:DelayCall(0, "CheckPartnerRedPoint")
			self:DelayCall(0, "CheckPartnerHireRedPoint")
		end
	elseif oCtrl.m_EventID == define.Item.Event.DelItem then
		local oItem = g_ItemCtrl:GetItem(eventData)
		if oItem and oItem:IsPartnerChip() then
			self:DelayCall(0, "CheckPartnerRedPoint")
			self:DelayCall(0, "CheckPartnerHireRedPoint")
		end
	elseif oCtrl.m_EventID == define.Item.Event.AddItem then
		if eventData and eventData:IsPartnerChip() then
			self:DelayCall(0, "CheckPartnerRedPoint")
			self:DelayCall(0, "CheckPartnerHireRedPoint")
		end
	end
end

function CMainMenuRB.RefreshRedDot(self)
	self.m_ItemBtn:DelEffect("RedDot")
	if g_ItemCtrl.m_RedDotIdTable and next(g_ItemCtrl.m_RedDotIdTable) then
		for type, list in pairs(g_ItemCtrl.m_RedDotIdTable) do
			if next(list) then
				self.m_ItemBtn:AddEffect("RedDot")
				break
			end
		end
	end
	if g_ItemCtrl:ShowForgeRedDotByType() then
		self.m_ForgeBtn:AddEffect("RedDot")
	else
		self.m_ForgeBtn:DelEffect("RedDot")
	end
end

function CMainMenuRB.OnCtrlMapEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Map.Event.ShowScene or 
		oCtrl.m_EventID == define.Map.Event.MapLoadDone or 
		oCtrl.m_EventID == define.Map.Event.EnterScene then
		self:DelayCall(0, "RefreshButton")			
	end
end

function CMainMenuRB.OnCtrlAnLeilEvent( self, oCtrl)
	if oCtrl.m_EventID == define.AnLei.Event.BeginPatrol then
		self:DelayCall(0, "RefreshButton")	
	elseif oCtrl.m_EventID == define.AnLei.Event.EndPatrol then
		self:DelayCall(0, "RefreshButton")	
	end
end

function CMainMenuRB.RefreshButton(self)
	local SetActive = function (obj, b)
		if not Utils.IsNil(obj) then
			obj:SetActive(b)
			obj:SetLocalScale(Vector3.New(1, 1, 1))
		end
	end
	
	SetActive(self.m_ChapterFuBenBtn, g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.chapterfuben.open_grade and g_ActivityCtrl:IsActivityVisibleBlock("chapterfuben"))
	SetActive(self.m_OrgBtn, g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.org.open_grade and g_ActivityCtrl:IsActivityVisibleBlock("org"))
	SetActive(self.m_ScheduleBtn, g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.schedule.open_grade  and g_ActivityCtrl:IsActivityVisibleBlock("schedule"))
	SetActive(self.m_PartnerBtn, g_ActivityCtrl:IsActivityVisibleBlock("partner"))
	SetActive(self.m_ShopBtn, g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.shop.open_grade and g_ActivityCtrl:IsActivityVisibleBlock("shop"))
	SetActive(self.m_HouseBtn, (g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.house.open_grade) and g_ActivityCtrl:IsActivityVisibleBlock("house"))		
	SetActive(self.m_DardCardBtn, g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.draw_card.open_grade and g_ActivityCtrl:IsActivityVisibleBlock("draw_card"))
	SetActive(self.m_ForgeBtn, g_ActivityCtrl:IsActivityVisibleBlock("forge") and g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.forge.open_grade)
	SetActive(self.m_HuntBtn, g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.huntpartnersoul.open_grade)
	if g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.huntpartnersoul.open_grade then
		g_GuideCtrl:StartTipsGuide("Tips_HuntPartnerSoulView")
	end

	self.m_RightGrid:Reposition()
	self.m_LeftGrid:Reposition()
end

function CMainMenuRB.OpenShopView(self)
	if g_ActivityCtrl:ActivityBlockContrl("shop") then
		g_NpcShopCtrl:OpenShop()
	end	
end

function CMainMenuRB.OpenScheduleView(self)
	if g_ActivityCtrl:ActivityBlockContrl("schedule") then
		local guide_type = g_GuideCtrl:ReqTipsGuideFinish("mainmenu_schedule_btn")
		local guideOpenId = g_GuideCtrl:IsInTipsGuide("schedule_allday_go_btn")
		if guide_type == "Tips_HuoyueduGuide" then
			g_ScheduleCtrl:C2GSOpenScheduleUI(define.Schedule.Tag.Right1, define.Schedule.Tag.Top5)	
		elseif guideOpenId ~= nil then 
			g_ScheduleCtrl:C2GSOpenScheduleUI(define.Schedule.Tag.Right1, g_ScheduleCtrl:GetTag(guideOpenId)[1], guideOpenId)
		else
			local last = g_ScheduleCtrl:GetLastSchedule()
			g_ScheduleCtrl:C2GSOpenScheduleUI(last.iRightTag, last.iTopTag, last.IDTag)
		end		
		self:ClearScheduleBtnUITips()
	end	
end

function CMainMenuRB.ClearScheduleBtnUITips(self)
	self.m_ScheduleBtnUITips:SetActive(false)
end

function CMainMenuRB.CheckScheduleRedDot(self)
	if g_ScheduleCtrl:IsHasScheduleReward() then
		self.m_ScheduleBtn:AddEffect("RedDot")
	else
		self.m_ScheduleBtn:DelEffect("RedDot")
	end
end

function CMainMenuRB.OnSchduleEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Schedule.Event.RefreshUITip then
		self:RefreshScheduleBtnUITip(oCtrl.m_EventData)
	elseif oCtrl.m_EventID == define.Schedule.Event.Refresh then
		self:DelayCall(0, "CheckScheduleRedDot")
	end
end

function CMainMenuRB.OnCtrlActivityEvent(self, oCtrl)
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

function CMainMenuRB.RefreshScheduleBtnUITip(self, eventData)
	if self.m_ScheduleTimer then
		Utils.DelTimer(self.m_ScheduleTimer)
		self.m_ScheduleTimer = nil
	end
	self:ClearScheduleBtnUITips()
	local txt, countdown
	if eventData then
		txt = eventData.txt
		countdown = eventData.countdown
	end
	if not txt or txt == "" or not countdown or countdown <= 0 then
		return
	end
	self.m_ScheduleBtnUITips:SetActive(true)
	local function schedulebtnuitips()
		if Utils.IsNil(self) then
			return 
		end
		if countdown >= 0 then
			self.m_ScheduleBtnUITips:SetText(txt)
			countdown = countdown - 1
			return true
		else
			self.m_ScheduleBtnUITips:SetActive(false)
			return false
		end
	end
	self.m_ScheduleTimer = Utils.AddTimer(schedulebtnuitips, 1, 0)
end

function CMainMenuRB.OnMapBookEvent(self, oCtrl)
	if oCtrl.m_EventID == define.MapBook.Event.UpdateRedPoint then
		self:DelayCall(0, "CheckRedDot")
	end
end

function CMainMenuRB.OnChapterFuBenBtn(self, key)
	if self:CheckOpenCondition(key) then
		g_GuideCtrl:ReqTipsGuideFinish("mainmenu_chapterfb_btn")		
		g_ChapterFuBenCtrl.m_WarAfterReshow = true
		g_OpenUICtrl:OpenChapterFubenMainView()
	end
end

function CMainMenuRB.CheckOpenCondition(self, key)
	local b = true
	if g_EquipFubenCtrl:IsInEquipFB() or g_TreasureCtrl:IsInChuanshuoScene() then
		local ForbidTable = 
		{
			["chapterfuben"] = false,
			["pata"] = false,
			["worldboss"] = false,
			["org"] = false,	
			["equalarena"] = false,
		}
		if ForbidTable[key] == false then
			g_NotifyCtrl:FloatMsg("请先通关当前副本")
			b = false
		end		
	else
		b = g_ActivityCtrl:ActivityBlockContrl(key)
	end
	return b
end

function CMainMenuRB.CheckOrgRedDot(self)
	if g_OrgCtrl:IsMainNeedRedDot() then
		self.m_OrgBtn:AddEffect("RedDot")
	else
		self.m_OrgBtn:DelEffect("RedDot")
	end
end

function CMainMenuRB.OnOrgEvent(self, oCtrl)
	self:DelayCall(0, "CheckOrgRedDot")
end

function CMainMenuRB.OnOrgBtn(self, key)
	if self:CheckOpenCondition(key) then
		g_GuideCtrl:ReqTipsGuideFinish("operate_org_btn")
		g_OrgCtrl:OpenOrg()
	end
end

function CMainMenuRB.OnShowPartner(self)
	if not g_ActivityCtrl:ActivityBlockContrl("partner") then
		return
	end
	g_GuideCtrl:ReqTipsGuideFinish("mainmenu_partner_btn")
	local guideOpenId = g_GuideCtrl:IsInTipsGuide("partner_chip_compose_show_btn")
	local oView = CGuideView:GetView()
	local Guidetype = 0
	if g_GuideCtrl:IsInTargetGuide("Partner_FWCD_One_MainMenu") then
		Guidetype = 1
	elseif g_GuideCtrl:IsInTargetGuide("Partner_FWCD_Two_MainMenu") then
		Guidetype = 2
	elseif g_GuideCtrl:IsInTargetGuide("Partner_FWCD_Three_MainMenu") then							
		Guidetype = 3
	elseif g_GuideCtrl:IsInTargetGuide("Partner_FWQH_MainMenu") then							
		Guidetype = 4	
	elseif g_GuideCtrl:IsInTargetGuide("Partner_HBPY_MainMenu") then	
		-- Guidetype = 5	
	elseif g_GuideCtrl:IsInTargetGuide("Partner_HBJN_MainMenu") then						
		Guidetype = 6	
	elseif g_GuideCtrl:IsInTargetGuide("Partner_HBSX_MainMenu") then
		Guidetype = 7
	end		
	--伙伴符文快速装备引导
	if oView and Guidetype ~= 0 then
		local targetPartner = nil
		if Guidetype == 5 then
			targetPartner = g_PartnerCtrl:GetPartnerByName("阿坊")
		elseif Guidetype == 7 then
			targetPartner = g_GuideCtrl:GetHBSXPartner()
		else
			targetPartner = g_PartnerCtrl:GetPartnerByName("重华")
		end		
		if not targetPartner then
			targetPartner = g_PartnerCtrl:GetMainFightPartner()
		end
		if targetPartner then
			local parid = targetPartner:GetValue("parid")
			CPartnerMainView:ShowView( function (oView)
				oView.m_CurParID = parid
				oView:ShowMainPage()			
			end)
		else
			CPartnerMainView:ShowView()
		end
	---伙伴合成引导			
	elseif guideOpenId == 9999 then		
		CPartnerMainView:ShowView( function (oView)				
				oView:ShowMainPage()
				--oView.m_PartnerScroll:HideCard()
			end)
	elseif oView and g_GuideCtrl:IsInTargetGuide("PartnerFightMainmenuView") then
		CPartnerMainView:ShowView(function (oView)
			oView:ShowMainPage()
		end)
	else
		CPartnerMainView:ShowView(function (oView)
			oView:ShowFirstPage()
		end)
	end	
end

function CMainMenuRB.OnTaskEvent(self, oCtrl)	
	if oCtrl.m_EventID == define.Task.Event.RefreshAllTaskBox then
		self:DelayCall(0, "RefreshButton")
	end	
end

function CMainMenuRB.OnCtrlEquipFbEvent(self, oCtrl)
	if oCtrl.m_EventID == define.EquipFb.Event.BeginFb then
		self:DelayCall(0, "RefreshButton")

	elseif oCtrl.m_EventID == define.EquipFb.Event.EndFb then
		self:DelayCall(0, "RefreshButton")

	elseif oCtrl.m_EventID == define.EquipFb.Event.CompleteFB then
		self:DelayCall(0, "RefreshButton")
	end
end

function CMainMenuRB.OnFieldBossEvent(self, oCtrl)
	if oCtrl.m_EventID == define.FieldBoss.Event.UpadteBossList then
		self:DelayCall(0, "RefreshButton")
	end
end

function CMainMenuRB.CheckRedDot(self)
	local lcheck = {
		g_TravelCtrl:HasRedDot(),
		g_AchieveCtrl:HasAchieveRedDot(),
		g_SkillCtrl:IsCanLevelUp(),
		g_MapBookCtrl:IsHasAward(),
		g_PataCtrl:IsPataRedDot(),
	}
	for i,v in ipairs(lcheck) do
		if v then
			self.m_SwitchBtn:AddEffect("RedDot")
			return
		end
	end
	self.m_SwitchBtn:DelEffect("RedDot")
end

function CMainMenuRB.OnTravelEvent(self, oCtrl)
	self:DelayCall(0, "CheckRedDot")
end

function CMainMenuRB.OnAchieveEvent(self, oCtrl)
	self:DelayCall(0, "CheckRedDot")
end

function CMainMenuRB.OnPartnerEvent(self, oCtrl)
	local t = {
		define.Partner.Event.LoginInit,
		define.Partner.Event.UpdatePartner,
		define.Partner.Event.PartnerAdd,
		define.Partner.Event.UpdateRedPoint,
	}

	if table.index(t, oCtrl.m_EventID) then
		self:DelayCall(0, "CheckPartnerRedPoint")
	end
end

function CMainMenuRB.OnHuntEvent(self, oCtrl)
	if oCtrl.m_EventID == define.HuntPartnerSoul.Event.UpdateHuntInfo or
	oCtrl.m_EventID == define.HuntPartnerSoul.Event.OnUpdateTime then
		self:DelayCall(0, "CheckHuntRedDot")
	end
end

function CMainMenuRB.OnChapterFuBenEvent(self, oCtrl)
	if oCtrl.m_EventID == define.ChapterFuBen.Event.OnLogin or 
	oCtrl.m_EventID == define.ChapterFuBen.Event.OnUpdateChapterExtraReward or
	oCtrl.m_EventID == define.ChapterFuBen.Event.OnUpdateChapterTotalStar then
		self:DelayCall(0, "CheckChapterFuBenRedDot")
	end
end

function CMainMenuRB.CheckHuntRedDot(self)
	if g_HuntPartnerSoulCtrl:HasRedDot() then
		self.m_HuntBtn:AddEffect("RedDot")
	else
		self.m_HuntBtn:DelEffect("RedDot")
	end
end

function CMainMenuRB.CheckChapterFuBenRedDot(self)
	if g_ChapterFuBenCtrl:HasRedDot() then
		self.m_ChapterFuBenBtn:AddEffect("RedDot")	
	else
		self.m_ChapterFuBenBtn:DelEffect("RedDot")
	end
end

function CMainMenuRB.CheckPartnerRedPoint(self)
	local bRed = false
	for _, oPartner in pairs(g_PartnerCtrl:GetPartners()) do
		if oPartner:IsHasUpStarRedPoint() then
			bRed = true
			break
		end
	end
	if bRed then
		self.m_PartnerBtn:AddEffect("RedDot")
	else
		self.m_PartnerBtn:DelEffect("RedDot")
	end
end

function CMainMenuRB.CheckPartnerHireRedPoint(self)
	local dItemList = g_PartnerCtrl:GetChipByRare(0)
	local bRedDot = false
	for _, oItem in ipairs(dItemList) do
		local iAmount =  oItem:GetValue("amount")
		if oItem:GetValue("amount") > 0 then
			local iPartnerType = oItem:GetValue("partner_type")
			if not g_PartnerCtrl:IsHavePartner(iPartnerType) then
				local iComposeAmount = oItem:GetValue("compose_amount")
				if not oItem.m_RedFlag and iComposeAmount <= iAmount then
					bRedDot = true
					break
				end
			end
		end
	end
	if bRedDot then
		self.m_DardCardBtn:AddEffect("RedDot")
	else
		self.m_DardCardBtn:DelEffect("RedDot")
	end
end

function CMainMenuRB.OnDrawCard(self)
	if g_ActivityCtrl:ActivityBlockContrl("draw_card") then
		g_GuideCtrl:ReqTipsGuideFinish("mainmenu_drawcard_btn")
		--g_ChoukaCtrl:StartChouka()
		CPartnerHireView:ShowView()
	end
end

function CMainMenuRB.OnForge(self)
	if g_ActivityCtrl:ActivityBlockContrl("forge") then
		local oView = CGuideView:GetView()
		if oView and g_GuideCtrl:IsInTargetGuide("Forge_Gem_Open") then
			CForgeMainView:ShowView(function (oView)
				oView:ShowGemPage()
				oView:OnEquipClick(define.Equip.Pos.Necklace)									
			end)
		else
			CForgeMainView:ShowView()
		end
	end
end

function CMainMenuRB.OnShowView(self)
	g_GuideCtrl:AddGuideUI("mainmenu_chapterfb_btn", self.m_ChapterFuBenBtn)
	g_GuideCtrl:AddGuideUI("mainmenu_drawcard_btn", self.m_DardCardBtn)
	g_GuideCtrl:AddGuideUI("mainmenu_operate_btn", self.m_SwitchBtn)
	g_GuideCtrl:AddGuideUI("mainmenu_house_btn", self.m_HouseBtn)
	g_GuideCtrl:AddGuideUI("mainmenu_schedule_btn", self.m_ScheduleBtn)
	--g_GuideCtrl:AddGuideUI("operate_arena_btn", self.m_ArenaBtn)
	g_GuideCtrl:AddGuideUI("operate_org_btn", self.m_OrgBtn)
	g_GuideCtrl:AddGuideUI("mainmenu_partner_btn", self.m_PartnerBtn)
	g_GuideCtrl:AddGuideUI("mainmenu_forge_btn", self.m_ForgeBtn)
	g_GuideCtrl:AddGuideUI("mainmenu_hunt_btn", self.m_HuntBtn)

	local guide_ui = {"mainmenu_chapterfb_btn", "mainmenu_house_btn", "mainmenu_operate_btn", "mainmenu_hunt_btn", "operate_arena_btn", "operate_org_btn", "mainmenu_partner_btn", "mainmenu_schedule_btn", "mainmenu_drawcard_btn"}
	g_GuideCtrl:LoadTipsGuideEffect(guide_ui)
end

function CMainMenuRB.ShowSwitchTipsBox(self, bShow, key, tips)
	if bShow then
		local oBox = self.m_TipsBoxDic[key]
		if not oBox then
			oBox = self.m_SwitchTipsBox:Clone()
			oBox.m_LabelTips = oBox:NewUI(1, CLabel)
			oBox.m_LabelTips:SetText(tips)
		end
		oBox:SetActive(true)
		oBox:SetParent(self.m_SwitchTipsBox:GetParent())
		oBox:SetLocalPos(self.m_SwitchTipsBox:GetLocalPos())
		self.m_TipsBoxDic[key] = oBox
	else
		if self.m_TipsBoxDic[key] then
			self.m_TipsBoxDic[key]:Destroy()
			self.m_TipsBoxDic[key] = nil
		end
	end
end

return CMainMenuRB
