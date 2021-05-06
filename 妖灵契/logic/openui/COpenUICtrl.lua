local COpenUICtrl = class("COpenUICtrl", CCtrlBase)

COpenUICtrl.IDXS = {
	OPEN = 1,
	GRADE = 2,
	ITEM = 3,
}

function COpenUICtrl.ctor(self)
	CCtrlBase.ctor(self)

	self.m_Tips = {
		[COpenUICtrl.IDXS.OPEN] = "#R%s 未开放", --globalcontroldata
		[COpenUICtrl.IDXS.GRADE] = "#R%d 级开启", --globalcontroldata
		[COpenUICtrl.IDXS.ITEM] = "缺少物品 #R%s",
	}
end

function COpenUICtrl.OpenUI(self, index, cbSuccess, cbFail)
	local data = data.openuidata.DATA[index]
	if g_WarCtrl:IsWar() and data.go_inwar and data.go_inwar == 1 then
		g_NotifyCtrl:FloatMsg("战斗中无法进行此操作")
		return
	end
	if not g_ActivityCtrl:ActivityBlockContrl(data.block) then
		return
	end
	if data then
		local func = data.func
		local name = data.name
		local args = data.args
		if func and self[func] then
			local b = self[func](self, name, args)
			if b then
				if cbSuccess then
					cbSuccess()
				end
			else
				if cbFail then
					cbFail()
				end
			end
		end
	end
end

function COpenUICtrl.OpenAttrMainView(self, name, args)
	CAttrMainView:ShowView()
	return true
end

function COpenUICtrl.OpenSkillMainView(self, name, args)
	CSkillMainView:ShowView()
	return true
end

function COpenUICtrl.OpenPartnerMainPage(self, name, args)
	CPartnerMainView:ShowView(function (oView)
		oView:ShowMainPage()
	end)
	return true
end

function COpenUICtrl.OpenPartnerLineupPage(self, name, args)
	CPartnerMainView:ShowView(function (oView)
		oView:ShowLineupPage()
	end)
	return true
end

function COpenUICtrl.OpenPartnerEquipPage(self, name, args)
	CPartnerMainView:ShowView(function (oView)
		oView:ShowEquipPage()
	end)
	return true
end

function COpenUICtrl.OpenPartnerAwakePage(self, name, args)
	local oPartner = g_PartnerCtrl:GetMainFightPartner()
	if oPartner then
		CPartnerImproveView:ShowView(function(oView)
			oView:OnChangePartner(oPartner:GetValue("parid"))
			oView:ShowAwakePage()
		end)
	end
	return true
end

function COpenUICtrl.OpenPartnerUpGradePage(self, name, args)
	local oPartner = g_PartnerCtrl:GetMainFightPartner()
	if oPartner then
		CPartnerImproveView:ShowView(function(oView)
			oView:OnChangePartner(oPartner:GetValue("parid"))
			oView:ShowUpGradePage()
		end)
	end
	return true
end

function COpenUICtrl.OpenPartnerUpSkillPage(self, name, args)
	local oPartner = g_PartnerCtrl:GetMainFightPartner()
	if oPartner then
		CPartnerImproveView:ShowView(function(oView)
			oView:OnChangePartner(oPartner:GetValue("parid"))
			oView:ShowUpSkillPage()
		end)
	end
	return true
end

function COpenUICtrl.OpenPartnerShowSoulPage(self, name, args)
	CPartnerMainView:ShowView(function (oView)
		oView:ShowSoulPage()
	end)
	return true
end

function COpenUICtrl.OpenStrengthPage(self, name, args)
	CForgeMainView:ShowView(function (oView)
		oView:ShowIntensifyPage()
	end)
	return true
end

function COpenUICtrl.OpenFuWenPage(self, name, args)
	CForgeMainView:ShowView(function (oView)
		oView:ShowRunePage()
	end)
	return true
end

function COpenUICtrl.OpenGemPage(self, name, args)
	CForgeMainView:ShowView(function (oView)
		oView:ShowGemPage()
	end)
	return true
end

function COpenUICtrl.OpenItemBagMainView(self, name, args)
	if CItemQuickUseView:GetView() ~= nil then
		CItemQuickUseView:CloseView()
	end	
	CItemBagMainView:ShowView()
	return true
end

function COpenUICtrl.OpenNpcShopView(self, name, args)
	g_NpcShopCtrl:OpenShop(define.Store.Page.LiBaoShop)
	return true
end

function COpenUICtrl.OpenPartnerLuckyDrawView(self, name, args)
	if g_ActivityCtrl:ActivityBlockContrl("draw_card") then
		-- g_ChoukaCtrl:StartChouka()
		CPartnerHireView:ShowView()
		return true
	end
end

function COpenUICtrl.OpenArenaView(self, name, args)
	local isOpen = data.globalcontroldata.GLOBAL_CONTROL.arenagame.is_open == "y"
	if not isOpen then
		g_NotifyCtrl:FloatMsg(string.format(self.m_Tips[COpenUICtrl.IDXS.OPEN], name))
		return false
	end
	local openGrade = data.globalcontroldata.GLOBAL_CONTROL.arenagame.open_grade
	if openGrade > g_AttrCtrl.grade then
		g_NotifyCtrl:FloatMsg(string.format(self.m_Tips[COpenUICtrl.IDXS.GRADE], openGrade))
		return false
	end
	g_ArenaCtrl:ShowArena()
	return true
end

function COpenUICtrl.OpenPaTaView(self, name, args)
	local isOpen = data.globalcontroldata.GLOBAL_CONTROL.pata.is_open == "y"
	if not isOpen then
		g_NotifyCtrl:FloatMsg(string.format(self.m_Tips[COpenUICtrl.IDXS.OPEN], name))
		return false
	end
	local openGrade = data.globalcontroldata.GLOBAL_CONTROL.pata.open_grade
	if openGrade > g_AttrCtrl.grade then
		g_NotifyCtrl:FloatMsg(string.format(self.m_Tips[COpenUICtrl.IDXS.GRADE], openGrade))
		return false
	end
	g_PataCtrl:PaTaEnterView()
	return true
end

function COpenUICtrl.OpenWorldBossView(self, name, args)
	local isOpen = data.globalcontroldata.GLOBAL_CONTROL.worldboss.is_open == "y" 
	if not isOpen then
		g_NotifyCtrl:FloatMsg(string.format(self.m_Tips[COpenUICtrl.IDXS.OPEN], name))
		return false
	end
	local openGrade = data.globalcontroldata.GLOBAL_CONTROL.worldboss.open_grade
	if openGrade > g_AttrCtrl.grade then
		g_NotifyCtrl:FloatMsg(string.format(self.m_Tips[COpenUICtrl.IDXS.GRADE], openGrade))
		return false
	end
	local dSchedule = g_ScheduleCtrl:GetSchedule(define.Schedule.ID.Worldboss)
	if not g_ActivityCtrl:IsOpen(1001) then
		g_NotifyCtrl:FloatMsg(dSchedule:GetValue("notopentips"))
		return false
	end
	nethuodong.C2GSOpenBossUI()
	return true
end

function COpenUICtrl.OpenEndlessPVEView(self, name, args)
	local isOpen = data.globalcontroldata.GLOBAL_CONTROL.endless_pve.is_open == "y"
	if not isOpen then
		g_NotifyCtrl:FloatMsg(string.format(self.m_Tips[COpenUICtrl.IDXS.OPEN], name))
		return false
	end
	local openGrade = data.globalcontroldata.GLOBAL_CONTROL.endless_pve.open_grade
	if openGrade > g_AttrCtrl.grade then
		g_NotifyCtrl:FloatMsg(string.format(self.m_Tips[COpenUICtrl.IDXS.GRADE], openGrade))
		return false
	end
	local itemamount = g_ItemCtrl:GetBagItemAmountBySid(10022)
	if itemamount <= 0 then
		g_NotifyCtrl:FloatMsg("镜花水月可从活跃度奖励获得")
		return false
	end
	g_EndlessPVECtrl:GetChipList()
	return true
end

function COpenUICtrl.OpenAnswerMainView(self, name, args)
	local isOpen = data.globalcontroldata.GLOBAL_CONTROL.question.is_open == "y"
	if not isOpen then
		g_NotifyCtrl:FloatMsg(string.format(self.m_Tips[COpenUICtrl.IDXS.OPEN], name))
		return false
	end
	local openGrade = data.globalcontroldata.GLOBAL_CONTROL.question.open_grade
	if openGrade > g_AttrCtrl.grade then
		g_NotifyCtrl:FloatMsg(string.format(self.m_Tips[COpenUICtrl.IDXS.GRADE], openGrade))
		return false
	end
	local dSchedule = g_ScheduleCtrl:GetSchedule(define.Schedule.ID.Question)
	if not g_ScheduleCtrl:IsOpen(define.Schedule.ID.Question) then
		g_NotifyCtrl:FloatMsg(dSchedule:GetValue("notopentips"))
		return false
	end
	local oView = CMainMenuView:GetView()
	if oView then
		local olb = oView.m_LB
		if olb then
			olb:OnShowQAView()
		end
	end
	return true
end

function COpenUICtrl.OpenSceneExamMainView(self, name, args)
	local isOpen = data.globalcontroldata.GLOBAL_CONTROL.question.is_open == "y"
	if not isOpen then
		g_NotifyCtrl:FloatMsg(string.format(self.m_Tips[COpenUICtrl.IDXS.OPEN], name))
		return false
	end
	local openGrade = data.globalcontroldata.GLOBAL_CONTROL.question.open_grade
	if openGrade > g_AttrCtrl.grade then
		g_NotifyCtrl:FloatMsg(string.format(self.m_Tips[COpenUICtrl.IDXS.GRADE], openGrade))
		return false
	end
	local dSchedule = g_ScheduleCtrl:GetSchedule(define.Schedule.ID.SceneExam)
	if not g_ScheduleCtrl:IsOpen(define.Schedule.ID.SceneExam) then
		g_NotifyCtrl:FloatMsg(dSchedule:GetValue("notopentips"))
		return false
	end
	local oView = CMainMenuView:GetView()
	if oView then
		local olb = oView.m_LB
		if olb then
			olb:OnShowSceneExam()
		end
	end
	return true
end

function COpenUICtrl.OpenExchangeCoinView(self, name, args)
	g_NpcShopCtrl:ShowGold2CoinView()
	return true
end

function COpenUICtrl.CheckOpenOrg(self)
	local openGrade = data.globalcontroldata.GLOBAL_CONTROL.org.open_grade
	if openGrade > g_AttrCtrl.grade then
		g_NotifyCtrl:FloatMsg(string.format(self.m_Tips[COpenUICtrl.IDXS.GRADE], openGrade))
		return true
	end
end

function COpenUICtrl.OpenOrgBuildPage(self, name, args)
	if self:CheckOpenOrg() then
		return false
	end

	local orginfo = g_OrgCtrl:GetMyOrgInfo()
	if g_OrgCtrl:HasOrg() then
		COrgMainView:SetShowCB(function ()
			COrgChamberView:ShowView(function (oView)
				oView:OnSelectPage(oView.m_BtnBoxArr[2])
			end)
			COrgMainView:ClearShowCB()
		end)
		if not orginfo then
			netorg.C2GSOrgMainInfo()
		else
			COrgMainView:ShowView()
		end
	else
		netorg.C2GSOrgList()
	end
	return true
end

function COpenUICtrl.OpenOrgRedBagPage(self, name, args)
	if self:CheckOpenOrg() then
		return false
	end
	local orginfo = g_OrgCtrl:GetMyOrgInfo()
	if g_OrgCtrl:HasOrg() then
		COrgMainView:SetShowCB(function ()
			COrgChamberView:ShowView(function (oView)
				oView:OnSelectPage(oView.m_BtnBoxArr[3])
			end)
			COrgMainView:ClearShowCB()
		end)
		if not orginfo then
			netorg.C2GSOrgMainInfo()
		else
			COrgMainView:ShowView()
		end
	else
		netorg.C2GSOrgList()
	end
	return true
end

function COpenUICtrl.OpenOrgFubenPage(self, name, args)
	if self:CheckOpenOrg() then
		return false
	end
	local orginfo = g_OrgCtrl:GetMyOrgInfo()
	if g_OrgCtrl:HasOrg() then
		COrgMainView:SetShowCB(function ()
			COrgActivityCenterView:ShowView()
			COrgMainView:ClearShowCB()
		end)
		if not orginfo then
			netorg.C2GSOrgMainInfo()
		else
			COrgMainView:ShowView()
		end
	else
		netorg.C2GSOrgList()
	end
	return true
end

function COpenUICtrl.OpenOrgWarPage(self, name, args)
	if self:CheckOpenOrg() then
		return false
	end
	local orginfo = g_OrgCtrl:GetMyOrgInfo()
	if g_OrgCtrl:HasOrg() then
		COrgMainView:SetShowCB(function ()
			COrgActivityCenterView:ShowView(function (oView)
				oView:SelectTag(COrgActivityCenterView.TAGS.ORGWAR)
			end)
			COrgMainView:ClearShowCB()
		end)
		if not orginfo then
			netorg.C2GSOrgMainInfo()
		else
			COrgMainView:ShowView()
		end
	else
		netorg.C2GSOrgList()
	end
	return true
end

function COpenUICtrl.OpenOrgWish(self, name, args)
	local openGrade = data.globalcontroldata.GLOBAL_CONTROL.org_wish.open_grade
	if openGrade > g_AttrCtrl.grade then
		g_NotifyCtrl:FloatMsg(string.format(self.m_Tips[COpenUICtrl.IDXS.GRADE], openGrade))
		return false
	end
	local orginfo = g_OrgCtrl:GetMyOrgInfo()
	if g_OrgCtrl:HasOrg() then
		COrgMainView:SetShowCB(function ()
			netorg.C2GSOrgWishList()
			COrgMainView:ClearShowCB()
		end)
		if not orginfo then
			netorg.C2GSOrgMainInfo()
		else
			COrgMainView:ShowView()
		end
	else
		netorg.C2GSOrgList()
	end
	return true
end

function COpenUICtrl.OpenOrgShop(self, name, args)
	local openGrade = data.globalcontroldata.GLOBAL_CONTROL.org.open_grade
	if openGrade > g_AttrCtrl.grade then
		g_NotifyCtrl:FloatMsg(string.format(self.m_Tips[COpenUICtrl.IDXS.GRADE], openGrade))
		return false
	end

	local orginfo = g_OrgCtrl:GetMyOrgInfo()
	if g_OrgCtrl:HasOrg() then
		printc("HasOrg")
		COrgMainView:SetShowCB(function ()
			g_NpcShopCtrl:OpenShop(define.Store.Page.OrgFuLiShop)
			COrgMainView:ClearShowCB()
		end)
		if not orginfo then
			netorg.C2GSOrgMainInfo()
		else
			COrgMainView:ShowView()
		end
	else
		printc("C2GSOrgList")
		netorg.C2GSOrgList()
	end
	return true
end


function COpenUICtrl.OpenHouseExchangeView(self, name, args)
	if not self:CheckHouseOpen() then
		return false
	end
	nethouse.C2GSEnterHouse(g_AttrCtrl.pid)
	return true
end

function COpenUICtrl.OpenHouseFriend(self, name, args)
	if not self:CheckHouseOpen() then
		return false
	end
	g_HouseCtrl.m_ShowFirstFriendEffect = true
	CHouseMainView:SetShowCB(function ()
		nethouse.C2GSFriendHouseProfile()
		CHouseMainView:ClearShowCB()
	end)
	nethouse.C2GSEnterHouse(g_AttrCtrl.pid)
	return true
end

function COpenUICtrl.CheckHouseOpen(self, name, args)
	if not g_ActivityCtrl:ActivityBlockContrl("house") then
		return false
	end
	local openGrade = data.globalcontroldata.GLOBAL_CONTROL.house.open_grade
	if openGrade > g_AttrCtrl.grade then
		g_NotifyCtrl:FloatMsg(string.format(self.m_Tips[COpenUICtrl.IDXS.GRADE], openGrade))
		return false
	end
	return true
end

function COpenUICtrl.OpenTreasureDescView(self, name, args)
	if not g_ItemCtrl:CheckOpenCondition(10024) then
		return false
	end
	local openGrade = data.globalcontroldata.GLOBAL_CONTROL.treasure.open_grade
	if openGrade > g_AttrCtrl.grade then
		g_NotifyCtrl:FloatMsg(string.format(self.m_Tips[COpenUICtrl.IDXS.GRADE], openGrade))
		return false
	end
	local itemamount = g_ItemCtrl:GetBagItemAmountBySid(10024)
	if itemamount <= 0 then
		g_NotifyCtrl:FloatMsg(string.format(self.m_Tips[COpenUICtrl.IDXS.ITEM], data.itemdata.OTHER[10024].name))
		return false
	end
	local list = g_ItemCtrl:GetBagItemListBySid(10024)
	g_TreasureCtrl:OpenTreasureDescView(list[1].m_ID)
	return true
end

function COpenUICtrl.OpenAnLeiMainView(self, name, args)
	if g_ActivityCtrl:ActivityBlockContrl("trapmine") then
		g_MainMenuCtrl:OpenWoldMap({key = "anlei"})
		return true
	end	
end

function COpenUICtrl.OpenMedalShop(self, name, args)
	g_NpcShopCtrl:OpenShop(define.Store.Page.MedalShop)
	return true
end

function COpenUICtrl.OpenLiBaoShop(self, name, args)
	g_NpcShopCtrl:OpenShop(define.Store.Page.LiBaoShop)
	return true
end

function COpenUICtrl.OpenScheduleAllDayPage(self, name, args)
	if g_ActivityCtrl:ActivityBlockContrl("schedule") then
		g_ScheduleCtrl:C2GSOpenScheduleUI(define.Schedule.Tag.Right1)
		return true
	end
end

function COpenUICtrl.OpenScheduleEveryDayPage(self, name, args)
	if g_ActivityCtrl:ActivityBlockContrl("schedule") then
		g_ScheduleCtrl:C2GSOpenScheduleUI(define.Schedule.Tag.Right1)
		return true
	end
end

function COpenUICtrl.OpenTaskMainView(self, name, args)
	CTaskMainView:ShowView(function (oView)
		oView:ShowDefaultTask()
	end)
	return true
end

function COpenUICtrl.OpenTravelView(self, name, args)
	CTravelView:ShowView()
	return true
end

function COpenUICtrl.OpenPartnerGuideView(self, name, args)
	local openGrade = data.globalcontroldata.GLOBAL_CONTROL.mapbook.open_grade
	if openGrade > g_AttrCtrl.grade then
		g_NotifyCtrl:FloatMsg(string.format(self.m_Tips[COpenUICtrl.IDXS.GRADE], openGrade))
		return false
	end
	CMapBookView:ShowView()
	return true
end

function COpenUICtrl.OpenOrgView(self, name, args)
	if self:CheckOpenOrg() then
		return false
	end

	local orginfo = g_OrgCtrl:GetMyOrgInfo()
	if g_OrgCtrl:HasOrg() then
		if not orginfo then
			netorg.C2GSOrgMainInfo()
		else
			COrgMainView:ShowView()
		end
	else
		netorg.C2GSOrgList()
	end
	return true
end

function COpenUICtrl.OpenTeaArtMainView(self, name, args)
	local openGrade = data.globalcontroldata.GLOBAL_CONTROL.house.open_grade
	if openGrade > g_AttrCtrl.grade then
		g_NotifyCtrl:FloatMsg(string.format(self.m_Tips[COpenUICtrl.IDXS.GRADE], openGrade))
		return false
	end
	self:OpenHouseExchangeView()
	local function checkloop()
		if g_HouseCtrl.m_OwnerPid then
			nethouse.C2GSOpenWorkDesk(g_HouseCtrl.m_OwnerPid)
			return false
		else
			return true
		end
	end
	Utils.AddTimer(checkloop, 0.1, 0.1)
	return true
end

function COpenUICtrl.OpenEqualArenaView(self, name, args)
	local openGrade = data.globalcontroldata.GLOBAL_CONTROL.equalarena.open_grade
	if openGrade > g_AttrCtrl.grade then
		g_NotifyCtrl:FloatMsg(string.format(self.m_Tips[COpenUICtrl.IDXS.GRADE], openGrade))
		return false
	end
	g_EqualArenaCtrl:ShowArena()
	return true
end

function COpenUICtrl.OpenClubArenaView(self, name, args)
	local openGrade = data.globalcontroldata.GLOBAL_CONTROL.clubarena.open_grade
	if openGrade > g_AttrCtrl.grade then
		g_NotifyCtrl:FloatMsg(string.format("达到%s级开启此功能", openGrade))
		return false
	end
	g_ClubArenaCtrl:ShowArena()
	return true
end

function COpenUICtrl.OpenJijin(self, name, args)
	g_WelfareCtrl:ForceSelect(define.Welfare.ID.Czjj)
	return true
end

function COpenUICtrl.OpenAchieveMainView(self, name, args)
	local openGrade = data.globalcontroldata.GLOBAL_CONTROL.achieve.open_grade
	if openGrade > g_AttrCtrl.grade then
		g_NotifyCtrl:FloatMsg(string.format(self.m_Tips[COpenUICtrl.IDXS.GRADE], openGrade))
		return false
	end
	g_AchieveCtrl:C2GSAchieveMain()
	return true
end

function COpenUICtrl.OpenExchangeCoinView(self, name, args)
	-- local openGrade = data.globalcontroldata.GLOBAL_CONTROL.shop.open_grade
	-- if openGrade > g_AttrCtrl.grade then
	-- 	g_NotifyCtrl:FloatMsg(string.format(self.m_Tips[COpenUICtrl.IDXS.GRADE], openGrade))
	-- 	return false
	-- end
	g_NpcShopCtrl:ShowGold2CoinView()
	return true
end

function COpenUICtrl.OpenExchangeGoldCoinView(self, name, args)
	g_SdkCtrl:ShowPayView()
	return true
end

function COpenUICtrl.OpenTerrawar(self, name, args)
	local openGrade = data.globalcontroldata.GLOBAL_CONTROL.terrawars.open_grade
	if openGrade > g_AttrCtrl.grade then
		g_NotifyCtrl:FloatMsg(string.format(self.m_Tips[COpenUICtrl.IDXS.GRADE], openGrade))
		return false
	end
	--[[
	local dSchedule = g_ScheduleCtrl:GetSchedule(define.Schedule.ID.Terrawar)
	if not g_ScheduleCtrl:IsOpen(define.Schedule.ID.Terrawar) then
		g_NotifyCtrl:FloatMsg(dSchedule:GetValue("notopentips"))
		return false
	end
	]]
	if g_TerrawarCtrl:IsYure() or g_TerrawarCtrl:IsKaiqi() then
		if g_ActivityCtrl:ActivityBlockContrl("terrawars") then
			if g_AttrCtrl.org_id == 0 then
		   		g_NotifyCtrl:FloatMsg("请先加入公会")
		   		return false
		   	else
				g_TerrawarCtrl:C2GSTerrawarMain()
				return true
			end
		end
	else
		local dSchedule = g_ScheduleCtrl:GetSchedule(define.Schedule.ID.Terrawar)
		if dSchedule then
			g_NotifyCtrl:FloatMsg(dSchedule:GetDesc())
		end
		return false
	end
end

function COpenUICtrl.OpenYueKa(self, name, args)
	g_WelfareCtrl:ForceSelect(define.Welfare.ID.Yk)
	return true
end

function COpenUICtrl.OpenChaHui(self, name, args)
	g_ScheduleCtrl:C2GSOpenScheduleUI(define.Schedule.Tag.Right1, define.Schedule.Tag.Top4, define.Schedule.ID.MingLei)
	return true
end

function COpenUICtrl.OpenYunYing(self, name, args)
	g_NotifyCtrl:FloatMsg("该功能暂未开放")
	return false
end

function COpenUICtrl.OpenHouseTrain(self, name, args)
	if not self:CheckHouseOpen() then
		return false
	end
	if g_HouseCtrl:IsHouseOnly() then
		CHouseMainView:SetShowCB(function ()
			CHouseExchangeTestView:ShowView(function (oView)
				oView:SetPartnerInfo(1001)
				oView:SetMode("train")
			end)
			CHouseMainView:ClearShowCB()
		end)
	else
		CHouseMainView:SetShowCB(function ()
			CHouseExchangeView:ShowView(function (oView)
				oView:SetPartnerInfo(1001)
				oView:SetMode("train")
			end)
			CHouseMainView:ClearShowCB()
		end)
	end
	
	nethouse.C2GSEnterHouse(g_AttrCtrl.pid)
	return true
end

function COpenUICtrl.OpenHouseGift(self, name, args)
	if not self:CheckHouseOpen() then
		return false
	end
	if g_HouseCtrl:IsHouseOnly() then
		CHouseMainView:SetShowCB(function ()
			CHouseExchangeTestView:ShowView(function (oView)
				oView:SetPartnerInfo(1001)
				oView:SetMode("gift")
			end)
			CHouseMainView:ClearShowCB()
		end)
	else
		CHouseMainView:SetShowCB(function ()
			CHouseExchangeView:ShowView(function (oView)
				oView:SetPartnerInfo(1001)
				oView:SetMode("gift")
			end)
			CHouseMainView:ClearShowCB()
		end)
	end
	
	nethouse.C2GSEnterHouse(g_AttrCtrl.pid)
	return true
end

function COpenUICtrl.OpenInfoSetting(self, name, args)
	CFriendMainView:ShowView(function (oView)
		oView:OpenInfoPage()
	end)
	return true
end

function COpenUICtrl.OpenPersonBook(self, name, args)
	CMapBookView:ShowView(function (oView)
		oView:ShowPersonBookPage()
	end)
	return true
end

function COpenUICtrl.OpenEquipFubenMainView(self, name, args)
	return self:WalkToEquipFubenNpc()
end

function COpenUICtrl.OpenYJMainView(self, name, args)
	return self:WalkToYJFb()
end

function COpenUICtrl.OpenPartnerEquipComposeView(self, name, args)
	CPartnerEquipComposeView:ShowView()
	return true
end

function COpenUICtrl.OpenWorldBook(self, name, args)
	CMapBookView:ShowView(function (oView)
		oView.m_MainPage:ShowWorldPage()
	end)
	return true
end

function COpenUICtrl.OpenRechargeShop(self, name, args)
	CNpcShopView:ShowView(function (oView)
		oView:OpenRecharge()
	end)
	return true
end

function COpenUICtrl.WalkToTeamPvp(self, name, args)
	nethuodong.C2GSFindHuodongNpc("teampvp", 1002)
	return true
end

function COpenUICtrl.OpenChapterFubenMainView(self, name, args)
	if not g_ChapterFuBenCtrl:IsOpenChapterFuBen() then
		g_NotifyCtrl:FloatMsg("战役未开启")
		return false
	elseif not g_ActivityCtrl:IsActivityVisibleBlock("chapterfuben") then
		return false
	elseif not g_ActivityCtrl:ActivityBlockContrl("chapterfuben") then
		return false
	end
	if args == "" or args == nil then
		CChapterFuBenMainView:ShowView(function (oView)
			oView:DefaultChapterInfo()
		end)
	else
		local lArg = string.split(args, "_")

		local chapter = tonumber(lArg[1]) or 999
		local level = lArg[2]
		local isHard = lArg[3] == "hard"
		local iType = define.ChapterFuBen.Type.Simple
		if isHard then
			iType = define.ChapterFuBen.Type.Difficult
		end
		local maxLevel = g_ChapterFuBenCtrl:GetCurMaxChapter(iType)
		if chapter > maxLevel then
			chapter = maxLevel
		end
		if level then
			g_ChapterFuBenCtrl:ForceChapterLevel(iType, chapter, tonumber(level))
		else
			CChapterFuBenMainView:ShowView(function (oView)
				oView:ForceChapterInfo(iType, chapter)
			end)
		end
	end
	return true
end

function COpenUICtrl.OpenMonsterAtkCityMainView(self, name, args)
	if g_ActivityCtrl:ActivityBlockContrl("MonsterAtk") then
		local openGrade = data.globalcontroldata.GLOBAL_CONTROL.msattack.open_grade
		if g_AttrCtrl.grade >= openGrade then
			CMonsterAtkCityMainView:ShowView()
		else
			g_NotifyCtrl:FloatMsg(string.format(self.m_Tips[COpenUICtrl.IDXS.GRADE], openGrade))
		end
		return true
	end
	return false
end

function COpenUICtrl.WalkToConvoy(self, name, args)
	local taskData = 
	{
		acceptnpc = 5019,
	}
	local oTask = CTask.NewByData(taskData)
	g_TaskCtrl:ClickTaskLogic(oTask)
	return true
end

function COpenUICtrl.OpenTeamPvp(self, name, args)
	g_TeamPvpCtrl:ShowArena()
	return true
end

function COpenUICtrl.WalkToShiMen(self, name, args)
	local taskData =  
	{
		acceptnpc = 5001,
	}
	local taskDataList = g_TaskCtrl:GetTaskDataListWithSort() or {}
	for i,oTask in ipairs(taskDataList) do
		if oTask:GetValue("type") == define.Task.TaskCategory.SHIMEN.ID then
			g_TaskCtrl:ClickTaskLogic(oTask)
			return true
		end
	end
	local oTask = CTask.NewByData(taskData)
	g_TaskCtrl:ClickTaskLogic(oTask)
	return true
end

function COpenUICtrl.WalkToPEFb(self, name, args)
	local taskData = 
	{
		acceptnpc = 5006,
	}
	local oTask = CTask.NewByData(taskData)
	g_TaskCtrl:ClickTaskLogic(oTask)
	return true
end

function COpenUICtrl.WalkToYJFb(self, name, args)
	local taskData = 
	{
		acceptnpc = 5008,
	}
	local oTask = CTask.NewByData(taskData)
	g_TaskCtrl:ClickTaskLogic(oTask)
	return true
end

function COpenUICtrl.OpenFriend(self, name, args)
	CFriendMainView:ShowView()
	return true
end

function COpenUICtrl.OpenOnlineGift(self, name, args)
	COnlineGiftView:ShowView()
	return true
end

function COpenUICtrl.OpenPowerGuide(self, name, args)
	if g_AttrCtrl.grade < data.globalcontroldata.GLOBAL_CONTROL.powerguide.open_grade then
		g_NotifyCtrl:FloatMsg(string.format("角色需要达到%d级可开启", data.globalcontroldata.GLOBAL_CONTROL.powerguide.open_grade))
		return
	end
	if g_WarCtrl:IsWar() then
		g_NotifyCtrl:FloatMsg("战斗中无法进行此操作")
		return
	end
	if g_ActivityCtrl:ActivityBlockContrl("powerguide", true) then
		CPowerGuideMainView:ShowView()
		return true
	end
end

function COpenUICtrl.OpenFieldBoss(self, name, args)
	local list = g_FieldBossCtrl:GetBossList()
	if list and #list > 0 and g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.fieldboss.open_grade then
		nethuodong.C2GSOpenFieldBossUI()
	else
		g_NotifyCtrl:FloatMsg("人形怪物暂无刷新，请留意系统广播")
	end
end

function COpenUICtrl.OpenLimitDraw(self, name, args)
	if data.welfaredata.WelfareControl[define.Welfare.ID.LimitReward].open == 0 then
		g_NotifyCtrl:FloatMsg("该功能暂未开放")
		return false
	elseif g_AttrCtrl.grade < tonumber(data.welfaredata.WelfareControl[define.Welfare.ID.LimitReward].grade) then
		g_NotifyCtrl:FloatMsg(string.format("主角需达到%d级开启功能", tonumber(data.welfaredata.WelfareControl[define.Welfare.ID.LimitReward].grade)))
		return false
	else
		CLimitRewardView:ShowView(function (oView)
			oView:OnSwitchPage(1)
		end)
	end
	return true
end

function COpenUICtrl.OpenCostScore(self, name, args)
	if data.welfaredata.WelfareControl[define.Welfare.ID.LimitReward].open == 0 then
		g_NotifyCtrl:FloatMsg("该功能暂未开放")
		return false
	elseif g_AttrCtrl.grade < tonumber(data.welfaredata.WelfareControl[define.Welfare.ID.LimitReward].grade) then
		g_NotifyCtrl:FloatMsg(string.format("主角需达到%d级开启功能", tonumber(data.welfaredata.WelfareControl[define.Welfare.ID.LimitReward].grade)))
		return false
	else
		CLimitRewardView:ShowView(function (oView)
			oView:OnSwitchPage(3)
		end)
	end
	return true
end

function COpenUICtrl.OpenTotalPay(self, name, args)
	if data.welfaredata.WelfareControl[define.Welfare.ID.LimitReward].open == 0 then
		g_NotifyCtrl:FloatMsg("该功能暂未开放")
		return false
	elseif g_AttrCtrl.grade < tonumber(data.welfaredata.WelfareControl[define.Welfare.ID.LimitReward].grade) then
		g_NotifyCtrl:FloatMsg(string.format("主角需达到%d级开启功能", tonumber(data.welfaredata.WelfareControl[define.Welfare.ID.LimitReward].grade)))
		return false
	else
		CLimitRewardView:ShowView(function (oView)
			oView:OnSwitchPage(2)
		end)
	end
	return true
end

function COpenUICtrl.WalkToEquipFubenNpc(self)
	local taskData = 
	{
		acceptnpc = 5002,
	}
	local oTask = CTask.NewByData(taskData)
	g_TaskCtrl:ClickTaskLogic(oTask)
	return true
end

function COpenUICtrl.WalkToEquipFubenMainViewOne(self, name, args)
	local taskData = 
	{
		acceptnpc = 5002,
		findPathCb = function ()
			g_EquipFubenCtrl:CtrlC2GSOpenEquipFBMain(1)
		end,
	}
	local oTask = CTask.NewByData(taskData)
	g_TaskCtrl:ClickTaskLogic(oTask)
	return true
end

function COpenUICtrl.WalkToEquipFubenMainViewTwo(self, name, args)
	local taskData = 
	{
		acceptnpc = 5002,
		findPathCb = function ()
			g_EquipFubenCtrl:CtrlC2GSOpenEquipFBMain(2)
		end,
	}
	local oTask = CTask.NewByData(taskData)
	g_TaskCtrl:ClickTaskLogic(oTask)
	return true
end

function COpenUICtrl.WalkToEquipFubenMainViewThree(self, name, args)
	local taskData = 
	{
		acceptnpc = 5002,
		findPathCb = function ()
			g_EquipFubenCtrl:CtrlC2GSOpenEquipFBMain(3)
		end,
	}
	local oTask = CTask.NewByData(taskData)
	g_TaskCtrl:ClickTaskLogic(oTask)
	return true
end

function COpenUICtrl.WalkToDailyTrainNpc(self, name, args)
	local taskData = 
	{
		acceptnpc = 5040,
	}
	local oTask = CTask.NewByData(taskData)
	g_TaskCtrl:ClickTaskLogic(oTask)
	return true
end

function COpenUICtrl.OpenHuntPartnerSoul(self, name, args)
	g_HuntPartnerSoulCtrl:OpenHuntView()
	return true
end

function COpenUICtrl.WalkToSkillTask(self, name, args)
	local oTask = g_TaskCtrl:GetPracticeTask()
	if not oTask then
		local taskData = 
		{
			acceptnpc = 5012,
		}
		oTask = CTask.NewByData(taskData)
	end
	g_TaskCtrl:ClickTaskLogic(oTask)
	return true
end

function COpenUICtrl.OpenDailyTrainMainView(self, name, args)
	if g_ActivityCtrl:ActivityBlockContrl("lilian") then
		CDailyTrainMainView:ShowView()
	end
	return true
end

function COpenUICtrl.WalkToMarryNpc(self, name, args)
	local taskData = 
	{
		acceptnpc = 5004,
	}
	local oTask = CTask.NewByData(taskData)
	g_TaskCtrl:ClickTaskLogic(oTask)
	return true
end

function COpenUICtrl.WalkToHeroBox(self)
	if g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.herobox.open_grade then
		nethuodong.C2GSFindHuodongNpc("herobox")
		return true
	else
		g_NotifyCtrl:FloatMsg(string.format("主角需达到%d级开启功能", data.globalcontroldata.GLOBAL_CONTROL.herobox.open_grade))
	end
	return false
end

function COpenUICtrl.OpenWorldMap(self)
	CMapMainView:ShowView(function (oView)
		oView:ShowSpecificPage(1)
	end)
end

return COpenUICtrl