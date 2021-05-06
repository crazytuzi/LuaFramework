module(..., package.seeall)

--由顺序决定优先级
Trigger_Check = {
	--测试
	-- grade = {},
	-- custom = {},
	-- view = {},
	-- war = {},
	-- custom = {}, 

--[[---------------
	新加的引导要放最后 
---------------]]
	grade = {"Partner_FWCD_One_MainMenu", "Partner_FWCD_Two_MainMenu", "Open_ZhaoMu", "Open_ZhaoMu_Two", "Open_ZhaoMu_Three", "Open_Skill_Three", "Open_Skill_Four", "Open_Shimen", "Open_House", "Open_Achieve", "Open_Lilian",
	 "Open_Org", "Open_Forge", "Open_Equipfuben", "Open_Arena", "Open_MingLei", "Open_Trapmine", "Open_Pefuben", "Open_Convoy", "Open_Travel", "Open_Pata", "Open_MapBook", "Open_Forge_composite", "Open_YJFuben", "Open_FieldBoss", "Open_EqualArena", "OpenChapterFuBenMainView",
	 "OpenChapterDialogueView"},
	war = {"War1", "War2", "warCommand", "War4", "War5", "WarAutoWar"},
	view = {"ChapterFuBenMainView", "Partner_FWCD_One_PartnerMain", "Partner_FWCD_Two_PartnerMain", "Partner_FWQH_MainMenu", "Partner_FWQH_PartnerMain", "DrawCard", "DrawCardLineUp_MainMenu", "DrawCardLineUp_PartnerMain",
			"DrawCard_Two", "DrawCardLineUp_Two_MainMenu", "DrawCardLineUp_Two_PartnerMain", "DrawCard_Three", "DrawCardLineUp_Three_PartnerMain", "Partner_HBPY_MainMenu", "Partner_HPPY_PartnerMain", "Skill_Three", "MapSwitchMainmenu", "MapSwitchMapView",
			"Skill_Four", "Dialogue_Shimen", "Skill", "TeamMainView_HandyBuild", "HuntPartnerSoulView", "Open_Yuling", "Yuling_PartnerMain", "HouseView", "HouseTwoView", "HouseTeaartView", "ClubArenaView", "Partner_HBSX_MainMenu", "Partner_HBSX_PartnerMain", "ChapterFuBen_Hard"},
	custom = {},

	-- grade = {"Open_Lilian", "Open_House","Open_ZhaoMu", "Open_ZhaoMu_Two", "Open_ZhaoMu_Three", "Open_Schedule", "Open_Org",
	--   		 "Open_Trapmine", "Open_Pata", "Open_MingLei", "Forge_Strength_Open", "Forge_Gem_Open", "Open_Convoy",
	--   		 "Open_Skill_Two", "Open_Skill_Three", "Open_Skill_Four", "Open_Pvp", "Open_Shimen", "Open_YJHJ",
	--   		 "Open_Travel", "Open_YJFuben", "Open_EqualArena", "Open_FieldBoss", "Open_MapBook", "Open_Pefuben"},

	-- war = {"War1", "War2", "War3", "WarReplace", "warCommand", "WarSpeed"}, 

	-- view = {"HouseView", "HouseTwoView", "HouseExchangeView", "HouseTeaartView", "DrawCard", "DrawCard_Two", "DrawCard_Three", "Pata", 
	--  		"TaskNv", "War3MainMenu", "ScheduleView", "Get_Two_WZQY", "Skill", "Skill_Two", "Skill_Three", "Skill_Four", "ShiBaiMainmenuView",
	--  		 "LilianView", "PartnerFightMainmenuView", "PartnerFightLineupView", "PartnerFightChooseView",
	--  		"TeamMainView_HandyBuild", "ChapterFuBenMainView", "Forge_Strength_View", "Forge_Gem_View", "Convoy_SchduleView", "Convoy_View", "QuickUse_View",
	--  		"FirstCharge_MainMenu", "Partner_FWCD_One_MainMenu", "Partner_FWCD_One_PartnerMain", "Partner_FWCD_Two_MainMenu", "Partner_FWCD_Two_PartnerMain", "Partner_FWCD_Three_MainMenu", "Partner_FWCD_Three_PartnerMain",
	--  		"Partner_FWQH_MainMenu", "Partner_FWQH_PartnerMain", "Partner_HBPY_MainMenu", "Partner_HPPY_PartnerMain", "Partner_HBPY_LineUp_PartnerMain", "Partner_HBHC_MainMenu", "Partner_HBJN_MainMenu", "Partner_HBJN_PartnerMain",
	-- 		"Equipfuben_SchduleView", "EquipFuben_View", "Partner_HBSX_MainMenu", "Partner_HBSX_PartnerMain", "Dialogue_Shimen", "PEFuben_MainMenu", "PEFuben_SchduleView", "PEFbView",
	--  		},	 		

	-- custom = { "HuoyueduGuide_Open", "PickView", "ArenaPowerGuide", "War4", "welcome_two", "rename_one", "YueJian_Before_Open"},
}


--提示型引导  
Tips_Trigger = {"Tips_JQFB", "Tips_JQFB_1_3", "Tips_LoginSevenDay", "Tips_Skill", "Tips_TeamHandyBuild", "Tips_House", "Tips_Org", "Tips_HuntPartnerSoulView", "Tips_ArneaClub", "Tips_HBSX", "Tips_Lilian", "Tips_HardChapterFb"}

-- Tips_Trigger = {"Tips_WZQY", "Tips_LoginSevenDay", "Tips_EquipFuben", "Tips_YueJian", "Tips_War_Faild", "Tips_PEFuben",
-- 				"Tips_XiaoMengQingQiu", "Tips_PartnerChip_Compose", "Tips_PowerGuide", "Tips_HuoyueduGuide", "Tips_Lilian", "Tips_Skill",
-- 				"Tips_TeamHandyBuild", "Tips_JQFB", "Tips_Convoy", "Tips_Brach_FightNpc", "Tips_Brach_CHFM", "Tips_Brach_CHYL"}



--任务标记引导类型
Task_Guide = {10002, 10033}

--其他引导放这里,所有使用新手保存的标记
Other_Guide = {"welcome_one", "welcome_two", "welcome_three", "welcome_three_start", "welcome_three_end", "GetPartner302", "Get3Item14001", "AutoWar", "Complete_Task_ChaterFb_1_4", "Refresh_Minglei", "FirstEnterEquipFb"}

-- Other_Guide = {"welcome_one", "welcome_two", "welcome_three", "welcome_three_start", "welcome_three_end", "PassEquipWarGuide", "Complete_Task_ChaterFb_1_4", "Complete_Task_ChaterFb_1_6", "GetYZCard1", "GetYZCard2", "GetThreeGem", "GetNCard", "GetFourBaoZi",
-- 				"Complete_War_Faild", "Refresh_Minglei", "show_YJFB_enter_effect", "ArenaPowerGuide", "FinishYueJianWar", "FirstEnterEquip", "ChapterFuBenLevelView", "PEWar", "PEWar_Floor_1", "PEWar_Floor_2", "FirstEnterEquipFb", "ChapterFuBenLevelView_1", "Task_Stroy_10014", 
-- 				"FirstQuitEquipFb"}				

FuncMap = {
	test = function()
		return true 
	end,
	pata_open = function()
		return g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.pata.open_grade and g_MainMenuCtrl:GetMainmenuViewActive() and g_ViewCtrl:NoBehideLayer()
	end,
	luckdraw_open = function()   
		local targetPartner = g_PartnerCtrl:GetPartnerByName("马面面")
		if targetPartner then
			g_GuideCtrl:JumpTargetGuideList("Open_ZhaoMu")		
			return false
		end
		return g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.draw_card.open_grade and g_MainMenuCtrl:GetMainmenuViewActive() and g_ViewCtrl:NoBehideLayer()
	end,
	DrawCardLineUp_MainMenu_open = function()   
		return g_MainMenuCtrl:GetMainmenuViewActive() and g_GuideCtrl:IsCustomGuideFinishByKey("DrawCard") and g_ViewCtrl:NoBehideLayer() and g_GuideCtrl:NoLoginRewardView()
	end,
	luckdraw_open_two = function()   
		local targetPartner = g_PartnerCtrl:GetPartnerByName("蛇姬")
		if targetPartner then
			g_GuideCtrl:JumpTargetGuideList("Open_ZhaoMu_Two")				
			return false
		end	
		return g_AttrCtrl.grade >= 9 and g_MainMenuCtrl:GetMainmenuViewActive() and g_ViewCtrl:NoBehideLayer() 
	end,
	DrawCardLineUp_Two_MainMenu_open = function()   
		return g_MainMenuCtrl:GetMainmenuViewActive() and g_GuideCtrl:IsCustomGuideFinishByKey("DrawCard_Two") and g_ViewCtrl:NoBehideLayer() and g_GuideCtrl:NoLoginRewardView()
	end,
	luckdraw_open_three = function()  
	 	local targetPartner = g_PartnerCtrl:GetPartnerByName("阿坊")
		if targetPartner then
			g_GuideCtrl:JumpTargetGuideList("Open_ZhaoMu_Three")				
			return false
		end	
		return g_AttrCtrl.grade >= 12 and g_MainMenuCtrl:GetMainmenuViewActive() and g_ViewCtrl:NoBehideLayer()
	end,	
	org_open = function()
		return g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.org.open_grade and g_MainMenuCtrl:GetMainmenuViewActive() and g_ViewCtrl:NoBehideLayer() 
	end,
	welfare_open = function()
		return g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.welfare.open_grade and g_MainMenuCtrl:GetMainmenuViewActive() and g_ViewCtrl:NoBehideLayer()
	end,
	schedule_open = function()
		return g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.schedule.open_grade and g_MainMenuCtrl:GetMainmenuViewActive() and g_ViewCtrl:NoBehideLayer()
	end,	
	arena_open = function()
		return g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.arenagame.open_grade and g_MainMenuCtrl:GetMainmenuViewActive() and g_ViewCtrl:NoBehideLayer()
	end,
	equal_arena_open = function()
		return g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.equalarena.open_grade and g_MainMenuCtrl:GetMainmenuViewActive() and g_ViewCtrl:NoBehideLayer()
	end,
	pvp_open = function()
		return g_AttrCtrl.grade >= 13 and g_MainMenuCtrl:GetMainmenuViewActive() and g_ViewCtrl:NoBehideLayer({"CItemTipsConfirmWindowView"})
	end,
	shimen_open = function()
		return g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.shimen.open_grade and g_MainMenuCtrl:GetMainmenuViewActive() and g_ViewCtrl:NoBehideLayer()
	end,
	Dialogue_Shimen_open = function()
		local oView = CDialogueMainView:GetView()
		local npcId = g_MapCtrl:GetNpcIdByNpcType(5001)		
		return g_GuideCtrl:NoLoginRewardView() and npcId and g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.shimen.open_grade and oView and oView.m_NormalPage and oView.m_NormalPage.m_DialogData and oView.m_NormalPage.m_DialogData.npcid == npcId
	end,
	Open_Yuling = function()
		return g_MainMenuCtrl:GetMainmenuViewActive() and g_ViewCtrl:NoBehideLayer() and g_GuideCtrl:IsCustomGuideFinishByKey("HuntPartnerSoulView")
	end,
	yikong_open = function()
		return g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.pefuben.open_grade and g_MainMenuCtrl:GetMainmenuViewActive() and g_ViewCtrl:NoBehideLayer()
	end,
	trapmine_open = function()
		return g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.trapmine.open_grade and g_MainMenuCtrl:GetMainmenuViewActive() and g_ViewCtrl:NoBehideLayer()
	end,
	minglei_open = function()
		return g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.minglei.open_grade and g_MainMenuCtrl:GetMainmenuViewActive() and g_ViewCtrl:NoBehideLayer()
	end,
	forge_strength_open = function()
		return g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.forge_strength.open_grade and g_MainMenuCtrl:GetMainmenuViewActive() and g_ViewCtrl:NoBehideLayer() 
		and (g_GuideCtrl:IsCustomGuideFinishByKey("QuickUse_View")) and CItemQuickUseView:GetView() == nil
	end,	
	forge_gem_open = function()
		return g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.forge_gem.open_grade and g_MainMenuCtrl:GetMainmenuViewActive() and g_ViewCtrl:NoBehideLayer()
	end,
	convoy_open = function()
		return g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.convoy.open_grade and g_MainMenuCtrl:GetMainmenuViewActive() and g_ViewCtrl:NoBehideLayer()
	end,	
	equipfuben_open = function()
		return g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.equipfuben.open_grade and g_MainMenuCtrl:GetMainmenuViewActive() and g_ViewCtrl:NoBehideLayer()
	end,
	OpenChapterFuBenMainView_open = function()
		return g_GuideCtrl:IsCustomGuideFinishByKey("Complete_Task_10002") and not g_ChapterFuBenCtrl:CheckChapterLevelPass(define.ChapterFuBen.Type.Simple, 1, 1)
	end,		
	OpenChapterDialogueView_open = function()
		local oUI = g_GuideCtrl:GetGuideUI("dialogue_right_10003_btn_1")
		return g_GuideCtrl:IsCustomGuideFinishByKey("OpenChapterFuBenMainView") and oUI and g_GuideCtrl:IsCustomGuideFinishByKey("Complete_Task_10002") and not g_ChapterFuBenCtrl:CheckChapterLevelPass(define.ChapterFuBen.Type.Simple, 1, 1)
	end,
	travel_open = function()
		return g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.travel.open_grade and g_MainMenuCtrl:GetMainmenuViewActive() and g_ViewCtrl:NoBehideLayer()
	end,	
	yjfuben_open = function()
		return g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.yjfuben.open_grade and g_MainMenuCtrl:GetMainmenuViewActive() and g_ViewCtrl:NoBehideLayer()
	end,	
	field_boss_open = function()
		return g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.fieldboss.open_grade and g_MainMenuCtrl:GetMainmenuViewActive() and g_ViewCtrl:NoBehideLayer()
	end,	
	lilian_open = function () 
		return g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.dailytrain.open_grade and g_MainMenuCtrl:GetMainmenuViewActive() and g_ViewCtrl:NoBehideLayer()
	end,
	house_open = function()
		return g_MainMenuCtrl:GetMainmenuViewActive() and g_ViewCtrl:NoBehideLayer() and g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.house.open_grade
	end,
	achieve_open = function()
		return g_MainMenuCtrl:GetMainmenuViewActive() and g_ViewCtrl:NoBehideLayer() and g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.achieve.open_grade
	end,
	map_book_open = function()
		return g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.mapbook.open_grade and g_MainMenuCtrl:GetMainmenuViewActive() and g_ViewCtrl:NoBehideLayer()
	end,
	forge_open = function()
		return g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.forge.open_grade and g_MainMenuCtrl:GetMainmenuViewActive() and g_ViewCtrl:NoBehideLayer()
	end,
	Open_Forge_composite_open = function()
		return g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.forge_composite.open_grade and g_MainMenuCtrl:GetMainmenuViewActive() and g_ViewCtrl:NoBehideLayer()
	end,			
	Open_YJHJ_open = function()
		return g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.endless_pve.open_grade and g_MainMenuCtrl:GetMainmenuViewActive() and g_ViewCtrl:NoBehideLayer()
	end,
	get_two_wzqy_open = function()
		return g_GuideCtrl:IsCustomGuideFinishByKey("get_two_wzqy_open") and g_MainMenuCtrl:GetMainmenuViewActive() and g_ViewCtrl:NoBehideLayer()
	end,	
	skill_two_open = function()
		return g_AttrCtrl.grade >= 3 and g_MainMenuCtrl:GetMainmenuViewActive() and g_ViewCtrl:NoBehideLayer()
	end,	
	skill_three_open = function()
		return g_AttrCtrl.grade >= 10 and g_MainMenuCtrl:GetMainmenuViewActive() and g_ViewCtrl:NoBehideLayer()
	end,
	skill_four_open = function()
		return g_AttrCtrl.grade >= 13 and g_MainMenuCtrl:GetMainmenuViewActive() and g_ViewCtrl:NoBehideLayer()
	end,	
	war3_after_main_menu_view_show = function()
		local oView = CMainMenuView:GetView()		
		return (not g_WarCtrl:IsWar() and oView ~= nil and oView:GetActive() == true and g_GuideCtrl:IsCustomGuideFinishByKey("Open_Pvp") and g_GuideCtrl:IsCustomGuideFinishByKey("War3") )
	end,
	Partner_FWCD_One_MainMenu_show = function()
		return (not g_WarCtrl:IsWar() and g_MainMenuCtrl:GetMainmenuViewActive() and g_ViewCtrl:NoBehideLayer() and g_AttrCtrl.grade >= 3)
	end,
	Partner_FWCD_Two_MainMenu_show = function()
		local b = false
		--暂时隐藏符文穿戴二（暂时不删除）
		-- if (not g_WarCtrl:IsWar() and g_MainMenuCtrl:GetMainmenuViewActive() and g_ViewCtrl:NoBehideLayer() and g_AttrCtrl.grade >= 5) then
		-- 	b = true
		-- 	local targetPartner = g_PartnerCtrl:GetPartnerByName("重华")
		-- 	if targetPartner then
		-- 		local info = targetPartner:GetCurEquipInfo()			
		-- 		if info and info[2] then
		-- 			g_GuideCtrl:ReqCustomGuideFinish("Partner_FWCD_Two_MainMenu")
		-- 			g_GuideCtrl:ReqCustomGuideFinish("Partner_FWCD_Two_PartnerMain")
		-- 			b = false
		-- 		end			
		-- 	end
		-- end
		return b
	end,
	Partner_FWCD_Three_MainMenu_show = function()
		return (not g_WarCtrl:IsWar() and g_MainMenuCtrl:GetMainmenuViewActive() and g_ViewCtrl:NoBehideLayer() and g_GuideCtrl:IsCustomGuideFinishByKey("Complete_Task_ChaterFb_1_4"))
	end,
	Partner_FWQH_MainMenu_show = function()
		local b = false
		if (not g_WarCtrl:IsWar() and g_MainMenuCtrl:GetMainmenuViewActive() and g_ViewCtrl:NoBehideLayer() and g_GuideCtrl:IsCustomGuideFinishByKey("Complete_Task_ChaterFb_1_4")) then
			local targetPartner = g_PartnerCtrl:GetPartnerByName("重华")
			if targetPartner then
				local info = targetPartner:GetCurEquipInfo()			
				if info and info[1] then
					b = true
				else
					g_GuideCtrl:ReqCustomGuideFinish("Partner_FWQH_MainMenu")
					g_GuideCtrl:ReqCustomGuideFinish("Partner_FWQH_PartnerMain")						
				end			
			end
		end
		return b
	end,
	Partner_HBPY_MainMenu_show = function()
		return (not g_WarCtrl:IsWar() and g_MainMenuCtrl:GetMainmenuViewActive() and g_ViewCtrl:NoBehideLayer() and g_GuideCtrl:IsCustomGuideFinishByKey("DrawCard_Three"))
	end,
	Partner_HBSX_MainMenu_show = function()
		return (not g_GuideCtrl:IsCustomGuideFinishByKey("Partner_HBSX_MainMenu") and not g_WarCtrl:IsWar() and g_MainMenuCtrl:GetMainmenuViewActive() and g_ViewCtrl:NoBehideLayer() and g_GuideCtrl:IsCanPartnerHBSXMainMenu())
	end,	
	Partner_HBHC_MainMenu_show = function()
		return (not g_WarCtrl:IsWar() and g_MainMenuCtrl:GetMainmenuViewActive() and g_ViewCtrl:NoBehideLayer() and g_GuideCtrl:IsCanPartnerHBHCMainMenu())
	end,
	Partner_HBJN_MainMenu_show = function()
		return (not g_WarCtrl:IsWar() and g_MainMenuCtrl:GetMainmenuViewActive() and g_ViewCtrl:NoBehideLayer() and g_GuideCtrl:IsCanPartnerHBJNMainMenu())
	end,	
	partner_equip_menu_view_after_show = function()
		return (g_GuideCtrl:IsCustomGuideFinishByKey("PartnerEquip")) and g_MainMenuCtrl:GetMainmenuViewActive() and g_ViewCtrl:NoBehideLayer()
	end,
	Partner_FWCD_One_PartnerMain_show = function()		
		return (g_GuideCtrl:IsCustomGuideFinishByKey("Partner_FWCD_One_MainMenu") and g_GuideCtrl:NoLoginRewardView())
	end,
	Partner_FWCD_Two_PartnerMain_show = function()
		local b = false
		if (not g_WarCtrl:IsWar() and g_GuideCtrl:IsCustomGuideFinishByKey("DrawCardLineUp_PartnerMain") and CPartnerMainView:GetView() ) then
			b = true
			local targetPartner = g_PartnerCtrl:GetPartnerByName("马面面")
			if targetPartner then
				local info = targetPartner:GetCurEquipInfo()			
				if info and info[1] then
					g_GuideCtrl:ReqCustomGuideFinish("Partner_FWCD_Two_PartnerMain")
					b = false
				end			
			end
		end			
		return b
	end,
	Partner_FWCD_Three_PartnerMain_show = function()
		return (g_GuideCtrl:IsCustomGuideFinishByKey("Partner_FWCD_Three_MainMenu"))
	end,
	Partner_FWQH_PartnerMain_show = function()
		return (g_GuideCtrl:IsCustomGuideFinishByKey("Partner_FWQH_MainMenu") and g_GuideCtrl:NoLoginRewardView())
	end,
	Partner_HPPY_PartnerMain_show = function()
		return (g_GuideCtrl:IsCustomGuideFinishByKey("Partner_HBPY_MainMenu")) and g_GuideCtrl:NoLoginRewardView()
	end,
	DrawCardLineUp_PartnerMain_show = function()
		local oView = CPartnerMainView:GetView()
		return g_GuideCtrl:IsCustomGuideFinishByKey("DrawCardLineUp_MainMenu") and oView and oView:GetActive() == true and g_GuideCtrl:NoLoginRewardView()
	end,
	DrawCardLineUp_Two_PartnerMain_show = function()
		local oView = CPartnerMainView:GetView()
		return g_GuideCtrl:IsCustomGuideFinishByKey("DrawCardLineUp_Two_MainMenu") and oView and oView:GetActive() == true and g_GuideCtrl:NoLoginRewardView()
	end,	
	Yuling_PartnerMain_show = function()
		local oView = CPartnerMainView:GetView()
		return g_GuideCtrl:NoLoginRewardView() and g_GuideCtrl:IsCustomGuideFinishByKey("Open_Yuling") and oView and oView:GetActive() == true
	end,	
	DrawCardLineUp_Three_PartnerMain_show = function()
		local oView = CPartnerMainView:GetView()
		local oView2 = CPartnerImproveView:GetView()
		return g_GuideCtrl:IsCustomGuideFinishByKey("Partner_HPPY_PartnerMain") and oView and oView:GetActive() == true and g_GuideCtrl:NoLoginRewardView() and oView2 == nil
	end,
	Partner_HBJN_PartnerMain_show = function()
		return (g_GuideCtrl:IsCustomGuideFinishByKey("Partner_HBJN_MainMenu"))
	end,
	Partner_HBSX_PartnerMain_show = function()		
		local oUI = g_GuideCtrl:GetGuideUI("partner_up_star_confirm_302_btn")
		local oView = CPartnerImproveView:GetView()
		return (not g_GuideCtrl:IsCompleteTipsGuideByKey("Tips_HBSX") and g_GuideCtrl:IsCustomGuideFinishByKey("Tips_HBSX_1") and oView and oView.m_UpStarPage and oView.m_UpStarPage:GetActive() == true and g_GuideCtrl:IsCustomGuideFinishByKey("Partner_HBSX_MainMenu") and oUI ~= nil)
	end,	
	yujian_war_menu_view_after_show = function()
	local oView = CMainMenuView:GetView()
		return (not g_WarCtrl:IsWar() and oView ~= nil and oView:GetActive() == true and g_GuideCtrl:IsCustomGuideFinishByKey("FinishYueJianWar"))
	end,		
	arena_power_guide = function()
		return false
	end,
	rename_ani = function()
		return false
	end,
	huoyueduguide_open = function()
		return false
	end,
	welcome_ani = function()
		return false
	end,	
	yuejian_before_open = function()
		return false
	end,	
	skill_view_show = function()
		return (CSkillMainView:GetView() ~= nil) and g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.switchschool.open_grade and g_GuideCtrl:NoLoginRewardView()
	end,
	skill_two_view_show = function()
		return (CSkillMainView:GetView() ~= nil) and g_GuideCtrl:IsCustomGuideFinishByKey("Open_Skill_Two")
	end,
	skill_three_view_show = function()
		return (CSkillMainView:GetView() ~= nil) and g_GuideCtrl:IsCustomGuideFinishByKey("Open_Skill_Three") and g_GuideCtrl:NoLoginRewardView()
	end,	
	skill_four_view_show = function()
		return (CSkillMainView:GetView() ~= nil) and g_GuideCtrl:IsCustomGuideFinishByKey("Open_Skill_Four") and g_GuideCtrl:NoLoginRewardView()
	end,	
	forge_gem_view_show = function()
		return (CForgeMainView:GetView() ~= nil) and g_GuideCtrl:IsCustomGuideFinishByKey("Forge_Gem_Open")
	end,	
	FirstCharge_MainMenu_show = function()
		return g_MainMenuCtrl:GetMainmenuViewActive() and g_ViewCtrl:NoBehideLayer() and g_ChapterFuBenCtrl:CheckChapterLevelPass(define.ChapterFuBen.Type.Simple, 1,8)
	end,	
	forge_strength_view_show = function()
		return (CForgeMainView:GetView() ~= nil) and g_GuideCtrl:IsCustomGuideFinishByKey("Forge_Strength_Open")
	end,	
	convoy_view_show = function()
		local oView = CLoginRewardView:GetView()
		return (CConvoyView:GetView() ~= nil) and oView == nil and g_GuideCtrl:IsCustomGuideFinishByKey("Open_Convoy")
	end,
	EquipFuben_View_show = function()
		return CLoginRewardView:GetView() == nil and CEquipFubenMainView:GetView() ~= nil and g_GuideCtrl:IsCustomGuideFinishByKey("Open_Schedule")
	end,	
	quickuse_view_show = function()
		return (CItemQuickUseView:GetView() ~= nil) and g_GuideCtrl:IsCustomGuideFinishByKey("EquipFuben_View")
	end,	
	drawcard_show = function()
		local oView = CPartnerHireView:GetView()
		return oView ~= nil and (g_GuideCtrl:IsCustomGuideFinishByKey("Open_ZhaoMu") and g_GuideCtrl:NoLoginRewardView() )
	end,
	drawcard_two_show = function()
		local oView = CPartnerHireView:GetView()
		return oView ~= nil and g_GuideCtrl:IsCustomGuideFinishByKey("Open_ZhaoMu_Two") and g_GuideCtrl:NoLoginRewardView()
	end,
	drawcard_three_show = function()
		local oView = CPartnerHireView:GetView()
		return oView ~= nil and g_GuideCtrl:IsCustomGuideFinishByKey("Open_ZhaoMu_Three") and g_GuideCtrl:NoLoginRewardView()
	end,	
	drawcard_main_show = function()
		local oView = CLuckyDrawView:GetView()
		return (oView and not oView.m_IsInResult)
	end,
	drawcard_result_show = function()
		local oView = CLuckyDrawView:GetView()
		return (oView and oView.m_IsInResult)
	end,
	yuejian_before_show = function()
		return g_MainMenuCtrl:GetMainmenuViewActive() and g_ViewCtrl:NoBehideLayer() and g_GuideCtrl:IsCustomGuideFinishByKey("YueJian_Before_Open")
	end,	
	yuejian_view_show = function()
		local oView = CEndlessPVEView:GetView()
		return (oView ~= nil)
	end,
	pata_view_show = function()
		local oView = CPaTaView:GetView()
		return (oView ~= nil and oView.m_IsOpenAni == false)
	end,
	arena_view_show = function()
		local oView = CArenaView:GetView()
		return (oView ~= nil)
	end,
	teach_view_hide = function()
		-- local oView = CTeachGuideView:GetView()
		-- return (oView == nil)
		return true
	end,
	teach_view_show = function()
		-- local oView = CTeachGuideView:GetView()
		-- return (oView ~= nil)
		return false
	end,
	partner_view_show = function()
		local oView = CPartnerMainView:GetView()
		return (oView ~= nil)
	end,
	stroydlg_show = function()
		local oView = CDialogueMainView:GetView()
		return oView ~= nil
	end,
	first_stroydlg_show = function()
		return false
	end,
	taskNv_show = function()	
		return false
	end,	
	first_taskNv_show = function()
		local b = false 
		local oTask = g_TaskCtrl:GetTaskById(10001)
		if oTask then
			b = true
		end
		return b
	end,	
	house_view_show = function()
		return g_HouseCtrl:IsInHouse() and  CTeaartView:GetView() == nil and CHouseBuffView:GetView() == nil
	end,
	HouseTwoView_show = function()
		local oView = CHouseBuffView:GetView()
		if oView then
			g_GuideCtrl:ReqCustomGuideFinish("HouseTwoView_1")
		end
		return g_GuideCtrl:IsCustomGuideFinishByKey("HouseTeaartView") or oView ~= nil and g_HouseCtrl:IsInHouse()
	end,
	HouseTeaartView_show = function ()
		return g_HouseCtrl:IsInHouse() and CTeaartView:GetView() ~= nil
	end,
	HouseView_step_two_continue = function()
		local b = false
		if g_GuideCtrl.m_HouseViewStepTwoAnyTouch then
			b = true
		end
		return b
	end,	
	HouseView_step_two_start_condition = function()
		return CHouseExchangeView:GetView() ~= nil
	end,
	HouseView_step_four_start_condition = function()
		local oView = CHouseExchangeView:GetView()
		return oView == nil
	end,
	HouseView_step_four_continue = function()
		return true
	end,
	HouseView_step_five_continue = function()
		return CTeaartView:GetView() ~= nil
	end,	
	HouseView_step_five_start_condition = function()
		return CHouseExchangeView:GetView() ~= nil
	end,			
	Dialogue_Shimen_step_one_continue = function()
		return true
	end,				
	HouseTwoView_step_one_before = function()
		if not CHouseBuffView:GetView() and (g_GuideCtrl:IsCustomGuideFinishByKey("HouseView") or g_GuideCtrl:IsCustomGuideFinishByKey("HouseView_2") ) then			
			g_GuideCtrl:AddGuideUIEffect("house_main_buff_btn", "Finger")
		end
	end,			
	HouseTwoView_step_one_after = function()
		g_GuideCtrl:DelGuideUIEffect("house_main_buff_btn", "Finger")
	end,	
	HouseTeaartView_step_three_before = function ()
		local oHousePartner = g_HouseCtrl:GetCurHouse():GetPartner(1001)
		if oHousePartner then
			oHousePartner:SetTrain(true)
		end
	end,
	HouseView_step_one_before = function()
		g_GuideCtrl.m_HouseViewStepTwoAnyTouch = false
	end,
	HouseView_step_one_after = function()
		g_GuideCtrl:AddGuideUIEffect("house_walker_1001")
	end,	
	HouseView_step_two_before = function()
		g_GuideCtrl:DelGuideUIEffect("house_walker_1001")
		g_GuideCtrl:AddGuideUIEffect("house_touch_btn", "Finger")
	end,
	HouseView_step_three_before = function()
		g_GuideCtrl:DelGuideUIEffect("house_touch_btn", "Finger")
	end,
	HouseView_step_three_after = function()
		g_GuideCtrl:DelGuideUIEffect("house_touch_btn", "Finger")
		g_GuideCtrl:AddGuideUIEffect("house_back_btn", "Finger", true)
	end,
	HouseView_step_five_before = function()
		if not g_GuideCtrl:IsCustomGuideFinishByKey("HouseTeaartView") then
			if g_HouseCtrl:GetCurHouse() then
				g_HouseCtrl:GetCurHouse():ShowTearArtFinger(true)
			end						
		else
			g_GuideCtrl:ReqCustomGuideFinish("HouseView_5")
			g_GuideCtrl:ReqCustomGuideFinish("HouseView")
			g_GuideCtrl:ResetUpdateInfo()
			CGuideView:CloseView()
			g_GuideCtrl:TriggerAll()
		end
		g_GuideCtrl:DelGuideUIEffect("house_back_btn", "Finger")
	end,
	HouseView_step_five_after = function()
		if g_HouseCtrl:GetCurHouse() then
			g_HouseCtrl:GetCurHouse():ShowTearArtFinger(false)
		end
	end,
	HouseTeaartView_step_one_before = function()
		g_GuideCtrl:AddGuideUIEffect("house_cooker_idx_1_btn", "Finger")
		local oHousePartner = g_HouseCtrl:GetCurHouse():GetPartner(1001)
		if oHousePartner then
			oHousePartner:SetTrain(true)
		end		
	end,
	HouseTeaartView_step_one_after = function()
		g_GuideCtrl:DelGuideUIEffect("house_cooker_idx_1_btn", "Finger")
	end,
	HouseTeaartView_step_three_before = function ()
		local oHousePartner = g_HouseCtrl:GetCurHouse():GetPartner(1001)
		if oHousePartner then
			oHousePartner:SetTrain(true)
		end
	end,
	HouseTeaartView_step_three_after = function()
		g_GuideCtrl:DelGuideUIEffect("house_cooker_work_1_btn", "Finger")
	end,
	house_exchange_view_show = function()
		return CHouseExchangeView:GetView() ~= nil
	end,
	chapter_fuben_main_view_show = function()
		return false
		--return CChapterFuBenMainView:GetView() ~= nil and g_GuideCtrl:NoLoginRewardView()
	end,
	ClubArenaView_show = function()
		local oView = CArenaView:GetView()
		if oView and g_GuideCtrl:IsInTargetGuide("ClubArenaView", 2) then
			if oView.m_CurPage ~= oView.m_ClubArenaPage then
				CGuideView:CloseView()
				g_GuideCtrl:ResetUpdateInfo()
				return false
			end
		end
		return oView ~= nil and g_GuideCtrl:NoLoginRewardView()
	end,
	ChapterFuBen_Hard_show = function()
		local oView	 = CChapterFuBenMainView:GetView()
		return oView ~= nil and oView:GetActive() == true and oView.m_ChapterType == 2 and oView.m_ChapterID == 1 and 
		oView.m_ChapterBox.m_ChapterFuBenLavelPart:GetActive() == false
	end,		
	chapter_fuben_main_view_level_part_show = function()
		local oView = CChapterFuBenMainView:GetView()
		return oView ~= nil and oView.m_ChapterBox.m_ChapterFuBenLavelPart and oView.m_ChapterBox.m_ChapterFuBenLavelPart.m_IsOpenAni == false
	end,
	map_book_view_show = function()
		return CMapBookView:GetView() ~= nil
	end,
	WorldMapBook_show = function ()
		return CWorldMapBookView:GetView() ~= nil and g_GuideCtrl:IsCustomGuideFinishByKey("MapBook")
	end,
	LilianView_show = function ()
		return CDailyCultivateMainView:GetView() ~= nil
	end,	
	TeamMainView_HandyBuild = function ()
		return false
		-- local oView = CTeamMainView:GetView()
		-- local UI = g_GuideCtrl:GetGuideUI("teamtarget_minglei_btn") 
		-- return g_GuideCtrl:NoLoginRewardView() and oView and oView.m_HandyBuildPage == oView.m_CurPage and CTeamTargetSetView:GetView() ~= nil and g_GuideCtrl:IsCustomGuideFinishByKey("Refresh_Minglei") and (UI and UI:GetActiveHierarchy())
	end,	
	CPEFbView_show = function()
		return CPEFbView:GetView() ~= nil and g_GuideCtrl:IsCustomGuideFinishByKey("Open_Pefuben")
	end,
	HuntPartnerSoulView_show = function()
		return CHuntPartnerSoulView:GetView() ~= nil and g_GuideCtrl:NoLoginRewardView()
	end,
	ShiBaiMainmenuView_show = function()
		return g_MainMenuCtrl:GetMainmenuViewActive() and g_ViewCtrl:NoBehideLayer() and (g_GuideCtrl:IsCustomGuideFinishByKey("Complete_War_Faild"))
	end,
	PartnerFightMainmenuView_show = function()
		return g_MainMenuCtrl:GetMainmenuViewActive() and g_ViewCtrl:NoBehideLayer() and (g_GuideCtrl:IsCustomGuideFinishByKey("DrawCard_Two"))
	end,
	PartnerFightLineupView_show = function()
		return CPartnerMainView:GetView() ~= nil and (g_GuideCtrl:IsCustomGuideFinishByKey("PartnerFightMainmenuView"))
	end,
	PartnerFightChooseView_show = function()
		return CPartnerChooseView:GetView() ~= nil and (g_GuideCtrl:IsCustomGuideFinishByKey("PartnerFightLineupView"))
	end,	
	MapSwitchMainmenu_show = function()		
		local b = true 
		if g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.equipfuben.open_grade then
			b = g_GuideCtrl:IsCustomGuideFinishByKey("Forge_Strength_View")
		end
		return b and g_MainMenuCtrl:GetMainmenuViewActive() and g_ViewCtrl:NoBehideLayer() and (g_GuideCtrl:IsCustomGuideFinishByKey("Complete_Task_10033"))
	end,
	MapSwitchMapView_show = function()
		local oView = CMapMainView:GetView()
		return oView and (g_GuideCtrl:IsCustomGuideFinishByKey("MapSwitchMainmenu")) and g_GuideCtrl:NoLoginRewardView()
	end,
	ShiBaiMainmenuView_step_one_before = function()
		g_GuideCtrl:StartTipsGuide("Tips_War_Faild")	
	end,
	Open_ZhaoMu_Two_step_one_before = function()
		g_GuideCtrl:ReqCustomGuideFinish("GetYZCard1")	
	end,
	Open_ZhaoMu_Three_step_one_before = function()
		g_GuideCtrl:ReqCustomGuideFinish("GetYZCard2")	
	end,			
	operate_view_show = function()
		local oView = CMainMenuOperateView:GetView()
		if oView  and oView.m_Container.m_TweenPos.tweenFactor == 1 then
			return true
		end
		return false
	end,
	pick_show = function()		
		return false
	end,	
	schedule_view_show = function()	
		local oView = CScheduleMainView:GetView()
		return oView and oView:GetActive() == true and g_GuideCtrl:IsCustomGuideFinishByKey("HuoyueduGuide_Open")
	end,	
	
	yuejian_schedule_view_show = function()	
		local oView = CScheduleMainView:GetView()		
		return oView and oView:GetActive() == true and g_GuideCtrl:IsCustomGuideFinishByKey("YueJian_Before") and (not g_GuideCtrl:IsCustomGuideFinishByKey("YueJian"))
	end,	
	PEFuben_SchduleView_view_show = function()	
		local oView = CScheduleMainView:GetView()		
		return oView and oView:GetActive() == true and g_GuideCtrl:IsCustomGuideFinishByKey("Open_Pefuben") and (not g_GuideCtrl:IsCustomGuideFinishByKey("PEFbView"))
	end,	
	PEFuben_MainMenu_show = function()		
		return g_MainMenuCtrl:GetMainmenuViewActive()  and g_GuideCtrl:IsCustomGuideFinishByKey("Open_Pefuben") and (not g_GuideCtrl:IsCustomGuideFinishByKey("PEFbView"))
	end,		
	Convoy_SchduleView_view_show = function()	
		local oView = CScheduleMainView:GetView()		
		return oView and oView:GetActive() == true and g_GuideCtrl:IsCustomGuideFinishByKey("Open_Convoy") and (not g_GuideCtrl:IsCustomGuideFinishByKey("Convoy_View"))
	end,
	Equipfuben_SchduleView_view_show = function()	
		local oView = CScheduleMainView:GetView()		
		return oView and oView:GetActive() == true and g_GuideCtrl:IsCustomGuideFinishByKey("Open_Schedule") and (not g_GuideCtrl:IsCustomGuideFinishByKey("EquipFuben_View"))
	end,			
	--战斗
	war_skill = function()
		local ovew = CWarFloatView:GetView()
		if g_WarCtrl:IsWar() and ovew and ovew.m_BoutTimeBox and ovew.m_BoutTimeBox.m_NumberGrid and ovew.m_BoutTimeBox.m_NumberGrid:GetActive() == true then
			return true
		end
	end,
	war_seltarget = function()
		return g_WarOrderCtrl:IsInSelTarget()
	end,
	war_start_show = function()
		local oView = CWarMainView:GetView()		
		return oView and oView.m_RB and oView.m_RB:GetActive() == true and WarTools.GetWarriorByCampPos(false, 1) and g_WarCtrl.m_IsReceiveDone == true
	end,	
	open_partner_main_view = function()
		local oView	= CPartnerMainView:GetView()
		return oView and oView.m_IsDoingOpenEffect == false 
	end,
	MapSwitchMapView_view_show_end = function()
		local oView	= CMapMainView:GetView()
		return oView and oView.m_IsDoingOpenEffect == false 
	end,
	partner_upgrade_view_open = function()
		local oView	= CPartnerUpGradeView:GetView()
		return oView and oView.m_IsDoingOpenEffect == false 
	end,		
	open_partner_choose_view = function()
		local oView	= CPartnerChooseView:GetView()
		return oView and oView.m_IsOpenAni == false 
	end,	
	war_not_seltarget = function()
		return not g_WarOrderCtrl:IsInSelTarget()
	end,
	war_can_order = function()
		return g_WarOrderCtrl:IsCanOrder()
	end,
	before_war_guide = function()
		if g_GuideCtrl.m_IsJiHuo == true then
			g_GuideCtrl.m_IsJiHuo = false
		end
		g_WarTouchCtrl:SetLock(true)
		netwar.C2GSWarStop(g_WarCtrl:GetWarID())
	end,
	after_war_guide = function()
		g_WarTouchCtrl:SetLock(false)
		netwar.C2GSWarStart(g_WarCtrl:GetWarID())
	end,
	war_necessary1 = function()		
		return g_WarCtrl:IsWar() and (g_WarCtrl:GetWarType() == define.War.Type.Guide1)
	end,
	war_necessary2 = function()		
		return g_WarCtrl:IsWar() and (g_WarCtrl:GetWarType() == define.War.Type.Guide2)
	end,
	war_necessary3 = function()		
		return g_WarCtrl:IsWar() and (g_WarCtrl:GetWarType() == define.War.Type.Guide3)
	end,	
	war_necessary4 = function()	
		return false
	end,
	war_necessary5 = function()		
		return g_WarCtrl:IsWar() and g_GuideCtrl.m_War5JiHuo == true
	end,
	WarAutoWar_necessary = function()		
		return g_GuideCtrl.m_AutoWarGuide == true
	end,
	war_replace = function()	
		return g_GuideCtrl.m_ShowIngWarReplaceGuide and g_WarCtrl:IsWar()
	end,
	war_command = function()		
		local b = false
		local oView = CWarMainView:GetView()	
		if oView and oView.m_RT and oView.m_RT.m_OrderMenu and oView.m_RT.m_OrderMenu:GetActive() == true 
			and g_TeamCtrl:IsLeader() and not g_WarCtrl:IsGuideWar() then
			b = true
		end
		return b
	end,	
	war_speed = function()					
		return g_GuideCtrl.m_WarSpeedGuide == true and g_WarCtrl:IsWar() and g_WarCtrl:GetWarType() == define.War.Type.ChapterFuBen 
	end,	
	war_pos_enemy1 = function()
		local oWarrior = WarTools.GetWarriorByCampPos(false, 1)
		return WarTools.WarToViewportPos(oWarrior.m_WaistTrans.position)
	end,
	war_skill_box1_pos = function()
		local viewPos = Vector2.New(0.5 , 0.5)
		local oUI = g_GuideCtrl:GetGuideUI("war_skill_box1")
		if oUI then
			local p = oUI:GetPos()
			local oUICam = g_CameraCtrl:GetUICamera()
			viewPos = oUICam:WorldToViewportPoint(p)
			viewPos.x = viewPos.x * oUICam.m_Camera.rect.size.x + oUICam.m_Camera.rect.position.x
			viewPos.y = viewPos.y * oUICam.m_Camera.rect.size.y + oUICam.m_Camera.rect.position.y	
		end		
		return viewPos
	end,
	war_orderdone_ally1 = function()
		local oWarrior = WarTools.GetWarriorByCampPos(true, 1)		
		return not g_WarOrderCtrl:IsWaitOrder(oWarrior.m_ID)
	end,
	war_orderdone_ally2 = function()
		local oWarrior = WarTools.GetWarriorByCampPos(true, 2)
		return not g_WarOrderCtrl:IsWaitOrder(oWarrior.m_ID)
	end,
	war_orderdone_ally5 = function()
		local oWarrior = WarTools.GetWarriorByCampPos(true, 5)
		if oWarrior then
			return not g_WarOrderCtrl:IsWaitOrder(oWarrior.m_ID)
		else
			return
		end		
	end,		
	war_2_step_one_condtion = function()
		local b = true
		-- for i = 1, 5 do
		-- 	local oWarrior = WarTools.GetWarriorByCampPos(true, i)
		-- 	if oWarrior and g_WarOrderCtrl:IsWaitOrder(oWarrior.m_ID) == true then
		-- 		b = false
		-- 		break
		-- 	end		
		-- end
		return b
	end,	

	war_3_step_two_1_after = function()
		g_GuideCtrl.m_war3_step_two_1_click = false
	end,
	war_3_step_two_1_before = function()
		g_GuideCtrl.m_war3_step_two_1_click = false
	end,		
	war_3_step_two_1_condtion = function()
		return g_GuideCtrl.m_war3_step_two_1_click == true
	end,
	war_3_step_two_condtion = function()
		local b = false
		for i = 1, 5 do
			local oWarrior = WarTools.GetWarriorByCampPos(true, i)
			if oWarrior and g_WarOrderCtrl:IsWaitOrder(oWarrior.m_ID) == false then
				b = true
				break
			end		
		end
		return b
	end,			
	war_3_step_three_0_condtion = function()		
		return g_GuideCtrl:War3StepThree0Continue()
	end,	
	war_3_step_three_condtion = function()
		local b = true
		for i = 1, 5 do
			local oWarrior = WarTools.GetWarriorByCampPos(true, i)
			if oWarrior and g_WarOrderCtrl:IsWaitOrder(oWarrior.m_ID) == true then
				b = false
				break
			end		
		end
		return b or g_WarCtrl.m_ProtoBout > 1
	end,		
	war_pos_ally1 = function()
		local oWarrior = WarTools.GetWarriorByCampPos(true, 1)
		if oWarrior then
			return WarTools.WarToViewportPos(oWarrior.m_WaistTrans.position)
		else
			return
		end
	end,
	war_pos_ally2 = function()
		local oWarrior = WarTools.GetWarriorByCampPos(true, 2)
		if oWarrior then
			return WarTools.WarToViewportPos(oWarrior.m_WaistTrans.position)
		else
			return
		end
	end,
	war_pos_ally3 = function()
		local oWarrior = WarTools.GetWarriorByCampPos(true, 3)
		if oWarrior then
			return WarTools.WarToViewportPos(oWarrior.m_WaistTrans.position)
		else
			return
		end
	end,
	war_pos_ally4 = function()
		local oWarrior = WarTools.GetWarriorByCampPos(true, 4)
		if oWarrior then
			return WarTools.WarToViewportPos(oWarrior.m_WaistTrans.position)
		else
			return
		end
	end,
	war_pos_ally5 = function()
		local oWarrior = WarTools.GetWarriorByCampPos(true, 5)
		if oWarrior then
			return WarTools.WarToViewportPos(oWarrior.m_WaistTrans.position)
		else
			return
		end
	end,
	war_pos_ally_not_cur_1 = function()
		local oWarrior = WarTools.GetWarriorByCampPos(true, 1)
		if oWarrior and g_WarOrderCtrl:GetOrderWid() ~= 1 then
			return WarTools.WarToViewportPos(oWarrior.m_WaistTrans.position)
		else
			return
		end
	end,
	war_pos_ally_not_cur_2 = function()
		local oWarrior = WarTools.GetWarriorByCampPos(true, 2)
		if oWarrior and g_WarOrderCtrl:GetOrderWid() ~= 2 then
			return WarTools.WarToViewportPos(oWarrior.m_WaistTrans.position)
		else
			return
		end
	end,
	war_pos_ally_not_cur_3 = function()
		local oWarrior = WarTools.GetWarriorByCampPos(true, 3)
		if oWarrior and g_WarOrderCtrl:GetOrderWid() ~= 3 then
			return WarTools.WarToViewportPos(oWarrior.m_WaistTrans.position)
		else
			return
		end
	end,
	war_pos_ally_not_cur_4 = function()
		local oWarrior = WarTools.GetWarriorByCampPos(true, 4)
		if oWarrior and g_WarOrderCtrl:GetOrderWid() ~= 4 then
			return WarTools.WarToViewportPos(oWarrior.m_WaistTrans.position)
		else
			return
		end
	end,
	war_pos_ally_not_cur_5 = function()
		local oWarrior = WarTools.GetWarriorByCampPos(true, 5)
		if oWarrior and g_WarOrderCtrl:GetOrderWid() ~= 5 then
			return WarTools.WarToViewportPos(oWarrior.m_WaistTrans.position)
		else
			return
		end
	end,

	war_order_ally2 = function()
		if g_WarOrderCtrl.m_CurOrderWid then
			local oWarrior = WarTools.GetWarriorByCampPos(true, 2)
			return oWarrior.m_ID == g_WarOrderCtrl.m_CurOrderWid
		end
	end,
	war_target_ally2 = function()
		local oWarrior = WarTools.GetWarriorByCampPos(true, 2)
		return oWarrior:IsOrderTarget()
	end,
	war_order_ally5 = function()
		if g_WarOrderCtrl.m_CurOrderWid then
			local oWarrior = WarTools.GetWarriorByCampPos(true, 5)
			return oWarrior.m_ID == g_WarOrderCtrl.m_CurOrderWid
		end
	end,
	war_lock_touch = function(bAlly, iPos)
		for i, oWarrior in pairs(g_WarCtrl:GetWarriors()) do
			local bTouch = (oWarrior:IsAlly() == bAlly) and (oWarrior.m_CampPos == iPos)
			oWarrior:SetTouchEnabled(bTouch)
		end
	end,
	war_unlock_touch = function()
		for i, oWarrior in pairs(g_WarCtrl:GetWarriors()) do
			oWarrior:SetTouchEnabled(true)
		end
	end,
	OpenChapterFuBenMainView_step_one_before = function()
		g_TaskCtrl:RefreshUI()
	end,		
	OpenChapterFuBenMainView_step_one_continue = function ()
		return CDialogueMainView:GetView() ~= nil
	end,
	Forge_Gem_Open_step_one_before = function()
		g_GuideCtrl:ReqCustomGuideFinish("GetThreeGem")
	end,	
	war_1_step_three_condtion = function()
		return g_GuideCtrl.m_IsJiHuo == true
	end,	
	war_1_step_one_before = function()
		local oUI = g_GuideCtrl:GetGuideUI("war_speed_tips_bg")
		if oUI then
			oUI:AddEffect("bordermove", Vector4.New(-25, 25, -220, 220))					
		end
		netwar.C2GSWarAutoFight(g_WarCtrl:GetWarID(), 0)
		netwar.C2GSWarStop(g_WarCtrl:GetWarID())
	end,	
	war_1_step_one_after = function()
		local oUI = g_GuideCtrl:GetGuideUI("war_speed_tips_bg")
		if oUI then
			oUI:DelEffect("bordermove")					
		end		
		netwar.C2GSWarStart(g_WarCtrl:GetWarID())
	end,		
	war_1_step_two_before = function ()
	
	end,	
	war_1_step_two_after = function ()
		--g_GuideCtrl:StopDelayClose()
	end,
	war_1_step_three_after = function()	
		netwar.C2GSWarStart(g_WarCtrl:GetWarID())
	end,		
	war_1_step_four_before = function()
		g_GuideCtrl.m_IsJiHuo = false
		netwar.C2GSWarStop(g_WarCtrl:GetWarID())
	end,
	war_1_step_four_start_condition = function()
		return g_WarCtrl:GetBout() == 2
	end,
	war_1_step_five_after = function()	
		netwar.C2GSWarStart(g_WarCtrl:GetWarID())
	end,
	war_1_step_five_condtion = function()
		return g_GuideCtrl.m_IsJiHuo == true
	end,							
	war_2_step_one_before = function ()
		local oUI = g_GuideCtrl:GetGuideUI("war_fore_bg_sprite")
		if oUI then
			oUI:AddEffect("bordermove", Vector4.New(-200, 200, -20, 20))					
		end
		netwar.C2GSWarStop(g_WarCtrl:GetWarID())	
		g_GuideCtrl.m_IsJiHuo = false	
	end,	


	war_2_step_one_after = function ()
		local oUI = g_GuideCtrl:GetGuideUI("war_fore_bg_sprite")
		if oUI then
			oUI:DelEffect("bordermove")						
		end
	end,
	war_2_step_one_start_condition = function ()
		local b = false
		local oUI = g_GuideCtrl:GetGuideUI("war_skill_box2")
		if oUI and oUI.m_ID == 30202 then
			b = true
		end
		return b
	end,
	war_2_step_two_after = function ()
	end,	
	war_2_step_three_continue_condition = function ()		
		return g_GuideCtrl.m_IsJiHuo == true
	end,	
	war_2_step_three_after = function ()
		netwar.C2GSWarStart(g_WarCtrl:GetWarID())
	end,
	war_3_step_three_before = function ()
		g_GuideCtrl.m_War3GuideAnyTouchTime = nil
		g_GuideCtrl.m_War3GuideAnyTouchInGuide = nil
		g_GuideCtrl.m_War3RemainTime = nil
		g_GuideCtrl:War3StepThreeBefore()
	end,
	war_3_step_three_1_before = function ()
		g_GuideCtrl:War3StepThreeBefore()
	end,
	war_3_step_three_after = function ()
		g_GuideCtrl:War3StepThreeAfter()
	end,	
	war_3_step_four_before = function ()
		g_GuideCtrl:War3StepFourBefore()
	end,
	war_3_step_four_continue = function ()
		return g_GuideCtrl:War3StepFourContinue()
	end,
	war_3_main_menu_step_one_before = function ()
		g_GuideCtrl:StarDelayClose()
	end,
	war_3_main_menu_step_one_after = function ()
		g_GuideCtrl:StartTipsGuide("Tips_PowerGuide")
		g_GuideCtrl:StopDelayClose()
	end,
	war_5_step_one_before = function ()
		local oWarrior = WarTools.GetWarriorByCampPos(false, 1)		
		if oWarrior then
			oWarrior:SetGuideTips(true)
		end
	end,	
	WarReplace_step_one_after = function ()
		g_GuideCtrl.m_ShowIngWarReplaceGuide = false
	end,
	WarReplace_step_one_before = function ()
		g_GuideCtrl:AddGuideUIEffect("war_replace_btn", "round")
	end,	
	partner_equip_main_menu_after_step_one_before = function ()
		g_GuideCtrl:StarDelayClose()
	end,
	ChapterFuBenMainView_one_start_condition = function ()
		local b = false
		local oView = CChapterFuBenMainView:GetView()
		if oView and oView.m_ChapterBox and oView.m_ChapterBox.m_IsDoingOpenEffect == false then
			return true
		end
		return b
	end,		
	get_two_wzqy_step_one_before = function ()
		g_GuideCtrl:StartTipsGuide("Tips_WZQY")
	end,	
	partner_equip_main_menu_after_step_one_after = function ()
		g_TaskCtrl:OnEvent(define.Task.Event.RefreshAllTaskBox)
		g_GuideCtrl:StopDelayClose()
	end,	
	Partner_HBHC_MainMenu_step_one_after = function ()
		g_GuideCtrl:StartTipsGuide("Tips_PartnerChip_Compose")
	end,
	Partner_HBSX_MainMenu_step_one_before = function ()
		g_GuideCtrl:StartTipsGuide("Tips_HBSX")
		g_GuideCtrl:ReqCustomGuideFinish("Partner_HBSX_MainMenu")
	end,	
	Partner_HBPY_MainMenu_step_one_after = function ()
		g_GuideCtrl:ReqCustomGuideFinish("Get3Item14001")
	end,				
	delay_open_mainmenu_operate = function ()
		g_GuideCtrl:DelayClick("mainmenu_operate_btn", 0.5)
	end,
	stop_open_mainmenu_operate = function ()
		g_GuideCtrl:StopDelayClick("mainmenu_operate_btn")
	end,		
	MapBook_step_one_before = function ()
		g_GuideCtrl.m_ClickMapBookReward = false
		local oView = CMapBookView:GetView()		
		if oView and oView.m_MainPage then			
			oView.m_MainPage:ShowChatMsg("月见岛的资料吗？应该保存在“世界之源”里。\n（点击任意位置继续）")
		end
	end,
	MapBook_step_two_before = function ()
		local oView = CMapBookView:GetView()		
		if oView and oView.m_MainPage then			
			oView.m_MainPage:ShowChatMsg()
		end
	end,	
	WorldMapBook_step_three_continue = function ()
		return g_GuideCtrl.m_ClickMapBookReward == true
	end,
	Partner_HBSX_PartnerMain_step_one_continue = function ()
		return g_GuideCtrl:IsCompleteTipsGuideByKey("Tips_HBSX")
	end,	
	LilianView_step_one_before = function ()
		g_GuideCtrl:AddGuideUIEffect("linlianview_go_btn", "round")
	end,	
	WorldMapBook_step_three_after = function ()
		g_GuideCtrl:AddGuideUIEffect("mapbook_main_close_lb", "round")
		g_GuideCtrl:AddGuideUIEffect("mapbook_world_main_close", "round")
		g_GuideCtrl:AddGuideUIEffect("mapbook_world_main_city_close", "round")
	end,
	WorldMapBook_step_one_condition = function ()
		local oView = CWorldMapBookView:GetView()		
		return oView and oView.m_WorldMainPage and oView.m_WorldMainPage:GetActive() == true			
	end,
	drawcard_step_four_condition = function ()
		local oView = CLuckyDrawView:GetView()	
		return oView and oView.m_DrawMainPage and oView.m_DrawMainPage:GetActive() == true
	end,
	EquipFuben_View_open = function ()
		local oView = CEquipFubenMainView:GetView()	
		return oView and oView.m_IsOpenAni == false
	end,
	Forge_View_open = function ()
		local oView = CForgeMainView:GetView()	
		return oView and oView.m_IsDoingOpenEffect == false
	end,
	skill_view_show_end = function ()
		local oView = CSkillMainView:GetView()	
		return oView and oView.m_IsDoingOpenEffect == false
	end,
	EquipFuben_Detail_View_open = function ()
		local oView = CEquipFubenDetailView:GetView()	
		return oView and oView.m_IsDoingOpenEffect == false
	end,	
	drawcard_step_three_after = function ()
		g_GuideCtrl:AddGuideUIEffect("close_wh_result_lb", "circle")
	end,	
	drawcard_step_five_after = function ()
		g_GuideCtrl:ReqCustomGuideFinish("DrawCard")
	end,	
	drawcard_step_six_after = function ()
		g_GuideCtrl:AddGuideUIEffect("close_wl_result_lb", "circle")
	end,
	DrawCard_Two_step_one_after = function ()
		g_GuideCtrl:ReqCustomGuideFinish("DrawCard_Two")
	end,	
	DrawCard_Three_step_one_after = function ()
		g_GuideCtrl:ReqCustomGuideFinish("DrawCard_Three")
	end,	
	yuejian_after_step_one_before = function ()
		g_GuideCtrl:StartTipsGuide("Tips_YueJian")
	end,	
	Skill_step_one_before = function ()
		g_GuideCtrl:AddGuideUIEffect("skill_switch_btn", "circle")
	end,	
	org_open_step_one_after = function()
		g_GuideCtrl:StartTipsGuide("Tips_Org")
	end,
	equipfuben_open_step_one_after = function()
		g_GuideCtrl:StartTipsGuide("Tips_EquipFuben")
	end,
	Open_Pvp_step_one_before = function()		
		local oView = CGuideView:GetView()
		if oView and oView.m_Contanier then
			oView.m_Contanier:SetActive(false)
		end
		local args = 
		{
			title = "手动战斗教学邀请",
			msg = string.format("是否需要进行手动战斗模式教学？"),
			okCallback = function ( )
				CGuideView:CloseView()
				local t = {"Open_Pvp", "War3MainMenu", "War3", "ArenaPowerGuide"}
				if g_GuideCtrl.m_Flags then
					for i,v in ipairs(t) do
						g_GuideCtrl.m_Flags[v] = true
					end
				end
				g_GuideCtrl:ResetUpdateInfo()						
				g_GuideCtrl:CtrlCC2GSFinishGuidance(t)
			end,
			cancelCallback = function ()
				CGuideView:CloseView()
				if g_GuideCtrl.m_Flags then					
					g_GuideCtrl.m_Flags["Open_Pvp"] = true					
				end		
				g_GuideCtrl:ResetUpdateInfo()			
				g_GuideCtrl:CtrlCC2GSFinishGuidance({"Open_Pvp"})
				if g_TeamCtrl:IsJoinTeam() then
					if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSLeaveTeam"]) then
						netteam.C2GSLeaveTeam()
					end
				end			
				netarena.C2GSGuaidArenaWar()
			end,
			okStr = "不需要",
			cancelStr = "需要",
			forceConfirm = true,
		}
		g_WindowTipCtrl:SetWindowConfirm(args)

	end,
	Open_Shimen_step_one_before = function()	
		g_TaskCtrl:RefreshUI()
	end,	
	Open_Arena_step_one_after = function()	
		g_GuideCtrl:StartTipsGuide("Tips_ArneaClub")
	end,	
	FirstCharge_MainMenu_step_one_before = function()
		CGuideView:CloseView()
		if g_GuideCtrl.m_Flags then					
			g_GuideCtrl.m_Flags["FirstCharge_MainMenu"] = true					
		end			
		g_GuideCtrl:CtrlCC2GSFinishGuidance({"FirstCharge_MainMenu"})	
		if g_WelfareCtrl:IsOpenFirstCharge() then
			CFirstChargeView:ShowView()
		end
	end,	
	Partner_HBSX_PartnerMain_step_one_before = function()
		g_GuideCtrl:ReqCustomGuideFinish("GetNCard")	
	end,
	Partner_FWCD_One_PartnerMain_step_two_before = function()
	end,
	Partner_HPPY_PartnerMain_step_one_before = function()
		local oUI = g_GuideCtrl:GetGuideUI("partner_left_list_501_partner")
		if oUI then
			oUI.m_Dragscrollview = oUI:GetComponent(classtype.UIDragScrollView)
			oUI.m_Dragscrollview.enabled = false
		end
	end,
	Partner_HPPY_PartnerMain_step_two_after = function()
		local oUI = g_GuideCtrl:GetGuideUI("partner_left_list_501_partner")
		if oUI then
			oUI.m_Dragscrollview = oUI:GetComponent(classtype.UIDragScrollView)
			oUI.m_Dragscrollview.enabled = true
		end		
	end,
	Partner_HPPY_PartnerMain_step_one_continue = function()
		local b = false
		local oUI = g_GuideCtrl:GetGuideUI("partner_left_list_501_partner")
		if oUI and oUI.m_SelSpr then
			return oUI.m_SelSpr:GetActive() == true
		end
		return b
	end,
	Partner_FWCD_Two_PartnerMain_step_three_before = function()
		local oUI = g_GuideCtrl:GetGuideUI("partner_left_list_502_partner")
		if oUI then
			oUI.m_Dragscrollview = oUI:GetComponent(classtype.UIDragScrollView)
			oUI.m_Dragscrollview.enabled = false
		end
	end,
	Partner_FWCD_Two_PartnerMain_step_three_after = function()
		local oUI = g_GuideCtrl:GetGuideUI("partner_left_list_502_partner")
		if oUI then
			oUI.m_Dragscrollview = oUI:GetComponent(classtype.UIDragScrollView)
			oUI.m_Dragscrollview.enabled = true
		end		
	end,
	Partner_FWCD_Two_PartnerMain_step_three_continue = function()
		local b = false
		local oUI = g_GuideCtrl:GetGuideUI("partner_left_list_502_partner")
		if oUI and oUI.m_SelSpr then
			return oUI.m_SelSpr:GetActive() == true
		end
		return b
	end,	
	DrawCardLineUp_PartnerMain_step_two_before = function()
		local oUI = g_GuideCtrl:GetGuideUI("partner_lineup_pos_2_btn")
		if oUI then
			local boxCollider = oUI:GetComponent(classtype.BoxCollider)
			if boxCollider then
				boxCollider.enabled = true
			end			
		end
	end,
	DrawCardLineUp_Three_PartnerMain_step_two_before = function()
		local oUI = g_GuideCtrl:GetGuideUI("partner_lineup_pos_4_btn")
		if oUI then
			local boxCollider = oUI:GetComponent(classtype.BoxCollider)
			if boxCollider then
				boxCollider.enabled = true
			end			
		end
	end,
	DrawCardLineUp_PartnerMain_step_two_after = function()
		local oUI = g_GuideCtrl:GetGuideUI("partner_lineup_pos_2_btn")
		if oUI then
			local boxCollider = oUI:GetComponent(classtype.BoxCollider)
			if boxCollider then
				boxCollider.enabled = false
			end			
		end
	end,
	DrawCardLineUp_Three_PartnerMain_step_two_after = function()
		local oUI = g_GuideCtrl:GetGuideUI("partner_lineup_pos_4_btn")
		if oUI then
			local boxCollider = oUI:GetComponent(classtype.BoxCollider)
			if boxCollider then
				boxCollider.enabled = false
			end			
		end
	end,
	DrawCardLineUp_Two_PartnerMain_step_two_before = function()
		local oUI = g_GuideCtrl:GetGuideUI("partner_lineup_pos_3_btn")
		if oUI then
			local boxCollider = oUI:GetComponent(classtype.BoxCollider)
			if boxCollider then
				boxCollider.enabled = true
			end			
		end
	end,
	DrawCardLineUp_Two_PartnerMain_step_two_after = function()
		local oUI = g_GuideCtrl:GetGuideUI("partner_lineup_pos_3_btn")
		if oUI then
			local boxCollider = oUI:GetComponent(classtype.BoxCollider)
			if boxCollider then
				boxCollider.enabled = false
			end			
		end
	end,
	Yuling_PartnerMain_step_two_before = function()
		local oUI = g_GuideCtrl:GetGuideUI("partner_soul_type_1_box_btn")
		if oUI then
			local boxCollider = oUI:GetComponent(classtype.BoxCollider)
			if boxCollider then
				boxCollider.enabled = false
			end			
		end
	end,
	Yuling_PartnerMain_step_two_after = function()
		local oUI = g_GuideCtrl:GetGuideUI("partner_soul_type_1_box_btn")
		if oUI then
			local boxCollider = oUI:GetComponent(classtype.BoxCollider)
			if boxCollider then
				boxCollider.enabled = true
			end			
		end
	end,			
	yuejian_step_one_before = function()
		local oView = CEndlessPVEView:GetView()
		if oView then
			oView:ShowGuideBox()
		end
	end,
	yuejian_step_one_after = function()
		local oView = CEndlessPVEView:GetView()
		local oUI = g_GuideCtrl:GetGuideUI("yuejian_monster_2")
		if oView then
			oView:OnSelect(oUI)
		end
	end,
	yuejian_war_mainmenu_after_step_one_before = function()
		--g_GuideCtrl:StartTipsGuide("Tips_PartnerChip_Compose")
	end,		
	yuejian_war_mainmenu_after_step_one_after = function()
		nethuodong.C2GSYJGuidanceReward()
	end,		
	Partner_FWCD_One_PartnerMain_step_one_after = function ()
		local oView = CPartnerMainView:GetView()
		if oView and oView.m_PartnerEquipPage and oView.m_PartnerEquipPage.m_EquipSelectPart then
			oView.m_PartnerEquipPage.m_EquipSelectPart:ShowListPart()
		end
	end,	
	open_minglei_step_two_after = function()	
		--g_GuideCtrl:StartTipsGuide("Tips_MingLei")
	end,	
	open_convoy_step_one_after = function()	
		g_GuideCtrl:StartTipsGuide("Tips_Convoy")
	end,	
	Open_Schedule_step_one_after = function()	
		g_GuideCtrl:StartTipsGuide("Tips_EquipFuben")
	end,		
	tips_ming_lei_step_one_process = function()	
		g_ActivityCtrl:MingLeiCreateGuideNpc()
	end,			
	open_pefuben_step_one_after = function()	
		g_GuideCtrl:StartTipsGuide("Tips_PEFuben")
	end,		
	open_house_step_one_before = function()	
	
	end,
	Open_Lilian_step_two_before = function()	
		g_GuideCtrl:StartTipsGuide("Tips_Lilian")
	end,
	open_house_step_one_after = function()	
		g_GuideCtrl:StartTipsGuide("Tips_House")
	end,	
	Open_Lilian_step_one_after = function()	
		--g_GuideCtrl:StartTipsGuide("Tips_Lilian")
	end,	
	house_walker_1_pos = function()	
		local rootw, rooth =  UITools.GetRootSize()	
		return Vector2.New(0.51 , 0.5)
	end,	
	huo_yue_du_guide_step_one_after = function()	
		g_GuideCtrl:StartTipsGuide("Tips_HuoyueduGuide")
	end,	
	ClubArenaView_step_two_before = function()	
		g_GuideCtrl:AddGuideUIEffect("clubarnea_club_2_btn", "Finger")
	end,	
	ClubArenaView_step_two_after = function()
		g_GuideCtrl:DelGuideUIEffect("clubarnea_club_2_btn", "Finger")
	end,		
	ChapterFuBen_Hard_step_one_before = function()	
		g_GuideCtrl:AddGuideUIEffect("chapter_fuben_btn_1", "Finger", true)
	end,	
	ChapterFuBen_Hard_step_one_after = function()
		g_GuideCtrl:DelGuideUIEffect("chapter_fuben_btn_1", "Finger")
	end,		
	cumstom_huo_yue_du_guide = function()		
		return g_GuideCtrl:IsCustomGuideFinishByKey("HuoyueduGuide_Open")
	end,
	cumstom_huo_yue_du_guide_close_cb_func = function()
		local oView = CMainMenuView:GetView()		
		if oView and oView.m_LT and oView.m_LT.m_TopGrid then			
			oView.m_LT.m_TopGrid:Reposition()
		end
	end,	
	before_mask_process = function (time)		

	end,	
	after_mask_process = function (time)
		CGuideMaskView:ShowView(function (oView)
			oView:DelayClose(time)
		end)
	end,
	warSpeed_step_one_before = function ( )
		g_GuideCtrl:AddGuideUIEffect("war_speed_btn", "circle")
	end,
	warSpeed_step_one_after = function ( )
		g_GuideCtrl:DelGuideUIEffect("war_speed_btn", "circle")
	end,	
	warCommand_step_one_before = function ( )
		local oWarrior = WarTools.GetWarriorByCampPos(false, 1)		
		if oWarrior then
			oWarrior:SetGuideTips(true)
		end
		g_GuideCtrl:ReqCustomGuideFinish("warCommand")
	end,
	warCommand_step_one_after = function ( )
		local oWarrior = WarTools.GetWarriorByCampPos(false, 1)		
		if oWarrior then
			oWarrior:SetGuideTips(false)
		end
	end,	
}

Test = {
	{
		sub_key="test", 
		start_condition = "test1",
		-- continue_condition = "not g_WarOrderCtrl:IsInSelTarget()",
		click_continue = false,
		necessary_ui_list = {"click_ui_test", },
		guide_list={ 
			-- {effect_type="func", funcname="WarPrepareGuide"},
			-- {effect_type="click_ui", ui_key="click_ui_test", ui_effect = "Finger"},
			-- {effect_type="focus_common", x=0.3, y=0.6, w=0.3, h=0.3},
			-- {effect_type="focus_ui", w=300 ,h=148, ui_key="click_ui_test"},
			-- {effect_type="focus_pos", w=0.2,h=0.1, pos_func=war_pos1 ,ui_effect="Finger"}
			-- {effect_type="dlg", text_list= {"测试教学描述1", "测试教学描述2"}},
			-- {effect_type="texture", text="点这里", texture_name="guide_1.png", near_pos = {x=-1, y=0},
			-- 	ui_key="click_ui_test"}
		},
	}
}

War1={
	after_guide=[[after_war_guide]],
	before_guide=[[before_war_guide]],
	complete_type=1,
	guide_list={
		[1]={
			after_process={args={},func_name=[[war_1_step_one_after]],},
			before_process={args={},func_name=[[war_1_step_one_before]],},
			click_continue=true,
			effect_list={
				[1]={
					aplha=150,
					dlg_is_left=true,
					dlg_sprite=[[pic_zhiying_ditu_1]],
					dlg_tips_sprite=[[guide_3]],
					effect_type=[[bigdlg]],
					fixed_pos={x=0.19,y=0.01,},
					near_pos={x=0,y=0,},
					play_tween=true,
					text_list={[1]=[[这里显示#R所有单位#n的#R行动顺序#n]],},
				},
				[2]={
					effect_tips_enum=1,
					effect_type=[[focus_ui]],
					h=0.4,
					ui_key=[[war_speed_tips_bg]],
					w=0.05,
				},
			},
			necessary_ui_list={[1]=[[war_speed_tips_bg]],},
		},
		[2]={
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					dlg_is_flip=false,
					dlg_is_left=true,
					effect_type=[[dlg]],
					fixed_pos={x=-0.12,y=-0.244,},
					near_pos={x=0,y=0,},
					play_tween=true,
					text_list={[1]=[[轮到主角行动了，#R点击技能#n]],},
				},
				[2]={
					effect_type=[[click_ui]],
					near_pos={x=0,y=0,},
					ui_key=[[war_skill_box1]],
				},
				[3]={
					effect_tips_enum=1,
					effect_type=[[focus_ui]],
					ui_effect=[[Finger]],
					effect_offset_pos={x=0,y=20,},
					focus_ui_size=1,
					ui_key=[[war_skill_box1]],
				},
			},
			necessary_ui_list={[1]=[[war_skill_box1]],},
		},
		[3]={
			after_process={args={},func_name=[[war_1_step_three_after]],},
			click_continue=false,
			continue_condition=[[war_1_step_three_condtion]],
			effect_list={
				[1]={
					aplha=100,
					dlg_is_flip=false,
					dlg_is_left=true,
					effect_type=[[dlg]],
					fixed_pos={x=-0.19,y=0,},
					near_pos={x=0,y=0,},
					play_tween=true,
					text_list={[1]=[[选择#R技能作用目标#n]],},
				},
				[2]={
					aplha=100,
					effect_type=[[focus_pos]],
					h=0.12,
					pos_func=[[war_pos_enemy1]],
					ui_effect=[[Finger]],
					w=0.07,
				},
			},
			necessary_ui_list={},
		},
		[4]={
			before_process={args={},func_name=[[war_1_step_four_before]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					dlg_is_left=true,
					dlg_sprite=[[pic_zhiying_ditu_1]],
					dlg_tips_sprite=[[guide_3]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.025,y=-0.244,},
					near_pos={x=0,y=0,},
					play_tween=true,
					text_list={[1]=[[尝试下其他技能]],},
				},
				[2]={
					effect_type=[[click_ui]],
					near_pos={x=0,y=0,},
					ui_key=[[war_skill_box2]],
				},
				[3]={
					effect_tips_enum=1,
					effect_type=[[focus_ui]],
					ui_effect=[[Finger]],
					focus_ui_size=1,
					ui_key=[[war_skill_box2]],
				},
			},
			necessary_ui_list={[1]=[[war_skill_box2]],},
			start_condition=[[war_1_step_four_start_condition]],
		},
		[5]={
			after_process={args={},func_name=[[war_1_step_five_after]],},
			click_continue=false,
			continue_condition=[[war_1_step_five_condtion]],
			effect_list={
				[1]={
					aplha=100,
					dlg_is_flip=false,
					dlg_is_left=true,
					effect_type=[[dlg]],
					fixed_pos={x=-0.19,y=0,},
					near_pos={x=0,y=0,},
					play_tween=true,
					text_list={[1]=[[选择#R技能作用目标#n]],},
				},
				[2]={
					aplha=100,
					effect_type=[[focus_pos]],
					h=0.12,
					pos_func=[[war_pos_enemy1]],
					ui_effect=[[Finger]],
					w=0.07,
				},
			},
			necessary_ui_list={},
		},
	},
	necessary_condition=[[war_necessary1]],
}

War2={
	complete_type=1,
	guide_list={
		[1]={
			after_process={args={},func_name=[[war_2_step_one_after]],},
			before_process={args={},func_name=[[war_2_step_one_before]],},
			click_continue=true,
			effect_list={
				[1]={
					aplha=150,
					dlg_is_left=true,
					dlg_sprite=[[pic_zhiying_ditu_1]],
					dlg_tips_sprite=[[guide_3]],
					effect_type=[[dlg]],
					fixed_pos={x=0.08,y=-0.32,},
					near_pos={x=0,y=0,},
					play_tween=true,
					text_list={[1]=[[这是#R怒气条#n]],},
				},
				[2]={
					effect_tips_enum=1,
					effect_type=[[focus_ui]],
					h=0.08,
					ui_key=[[war_fore_bg_sprite]],
					w=0.25,
				},
			},
			necessary_ui_list={[1]=[[war_fore_bg_sprite]],},
			start_condition=[[war_2_step_one_start_condition]],
		},
		[2]={
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					dlg_is_left=true,
					dlg_sprite=[[pic_zhiying_ditu_1]],
					dlg_tips_sprite=[[guide_3]],
					effect_type=[[dlg]],
					fixed_pos={x=0.16,y=-0.25,},
					near_pos={x=0,y=0,},
					play_tween=true,
					text_list={[1]=[[重华#R怒气技#n是#R群体#n技能，还有机率#R眩晕#n目标]],},
				},
				[2]={
					effect_type=[[click_ui]],
					near_pos={x=0,y=0,},
					ui_effect=[[Finger]],
					ui_key=[[war_skill_box2]],
				},
				[3]={
					effect_tips_enum=1,
					effect_type=[[focus_ui]],
					focus_ui_size=1,
					ui_key=[[war_skill_box2]],
				},
			},
			necessary_ui_list={[1]=[[war_skill_box2]],},
		},
		[3]={
			after_process={args={},func_name=[[war_2_step_three_after]],},
			click_continue=false,
			continue_condition=[[war_2_step_three_continue_condition]],
			effect_list={
				[1]={
					aplha=100,
					dlg_is_left=true,
					dlg_sprite=[[pic_zhiying_ditu_1]],
					dlg_tips_sprite=[[guide_3]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.19,y=0,},
					near_pos={x=0,y=0,},
					play_tween=true,
					text_list={[1]=[[选择#R技能作用目标#n]],},
				},
				[2]={
					aplha=100,
					effect_type=[[focus_pos]],
					h=0.12,
					pos_func=[[war_pos_enemy1]],
					ui_effect=[[Finger]],
					w=0.07,
				},
			},
			force_hide_continue_label=true,
			necessary_ui_list={},
			need_guide_view=true,
		},
	},
	necessary_condition=[[war_necessary2]],
}

War3={
	after_guide=[[after_war_guide]],
	before_guide=[[before_war_guide]],
	complete_type=1,
	guide_list={
		[1]={
			click_continue=true,
			effect_list={
				[1]={
					aplha=1,
					dlg_is_left=true,
					dlg_sprite=[[pic_zhiying_ditu_1]],
					dlg_tips_sprite=[[guide_3]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.25,y=-0.24,},
					near_pos={x=0,y=0,},
					play_tween=true,
					text_list={
						[1]=[[ 在#R40秒操作时间#n内对我方单位
下达指令，之后双方单位#R根据指
令#n进行行动。]],
					},
				},
			},
			force_hide_continue_label=true,
			necessary_ui_list={},
			start_condition=[[war_skill]],
		},
		[2]={
			after_process={args={},func_name=[[war_3_step_two_1_after]],},
			before_process={args={},func_name=[[war_3_step_two_1_before]],},	
			continue_condition=[[war_3_step_two_1_condtion]],				
			click_continue=false,
			effect_list={
				[1]={
					aplha=1,
					effect_type=[[focus_pos]],
					h=0.09,
					pos_func=[[war_skill_box1_pos]],
					ui_effect=[[Finger]],
					w=0.09,
				},
				[2]={
					aplha=1,
					dlg_is_left=true,
					dlg_sprite=[[pic_zhiying_ditu_1]],
					dlg_tips_sprite=[[guide_3]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.25,y=-0.24,},
					near_pos={x=0,y=0,},
					play_tween=true,
					text_list={[1]=[[ 点击#R选择#n该伙伴的#R技能#n。]],},
				},
				[3]={effect_type=[[hide_click_event]]},
			},
			necessary_ui_list={[1]=[[war_skill_box1]],},
			start_condition=[[war_skill]],
		},
		[3]={
			click_continue=false,
			continue_condition=[[war_3_step_two_condtion]],
			effect_list={
				[1]={effect_type=[[focus_common]],h=0.4,w=0.4,x=0.2,y=0.6,},
				[2]={
					aplha=100,
					dlg_is_left=true,
					dlg_sprite=[[pic_zhiying_ditu_1]],
					dlg_tips_sprite=[[guide_3]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.25,y=-0.24,},
					near_pos={x=0,y=0,},
					play_tween=true,
					text_list={[1]=[[ #R选择#n该技能的#R施放目标#n~喵]],},
				},
			},
			necessary_ui_list={},
			start_condition=[[war_seltarget]],
		},
		[4]={
			before_process={args={},func_name=[[war_3_step_three_before]],},
			click_continue=false,
			continue_condition=[[war_3_step_three_0_condtion]],
			effect_list={
				[1]={
					aplha=1,
					dlg_is_left=true,
					dlg_sprite=[[pic_zhiying_ditu_1]],
					dlg_tips_sprite=[[guide_3]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.25,y=-0.24,},
					near_pos={x=0,y=0,},
					play_tween=true,
					text_list={[1]=[[继续操作，选择技能或者攻击对象。]],},
				},
				[2]={effect_type=[[hide_click_event]],},
			},
			necessary_ui_list={},
			start_condition=[[war_seltarget]],
		},
		[5]={
			after_process={args={},func_name=[[war_3_step_three_after]],},
			before_process={args={},func_name=[[war_3_step_three_1_before]],},
			click_continue=false,
			continue_condition=[[war_3_step_three_condtion]],
			effect_list={
				[1]={
					aplha=1,
					dlg_is_left=true,
					dlg_sprite=[[pic_zhiying_ditu_1]],
					dlg_tips_sprite=[[guide_3]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.25,y=-0.24,},
					near_pos={x=0,y=0,},
					play_tween=true,
					text_list={
						[1]=[[“#R指令完成#n”可提前结束指令，
 #R未操作#n的单位将自动#R使用默认技能#n。]],
					},
				},
				[2]={effect_type=[[hide_click_event]],},
			},
			necessary_ui_list={},
			start_condition=[[war_seltarget]],
		},
		[6]={
			before_process={args={},func_name=[[war_3_step_four_before]],},
			click_continue=false,
			continue_condition=[[war_3_step_four_continue]],
			effect_list={
				[1]={effect_type=[[focus_common]],h=0.5,w=0.25,x=0.66,y=0.46,},
				[2]={
					aplha=100,
					dlg_is_left=true,
					dlg_sprite=[[pic_zhiying_ditu_1]],
					dlg_tips_sprite=[[guide_3]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.25,y=-0.24,},
					near_pos={x=0,y=0,},
					play_tween=true,
					text_list={[1]=[[ #R点击模型#n可切换操作单位。]],},
				},
			},
			necessary_ui_list={},
			start_condition=[[war_seltarget]],
		},
	},
	necessary_condition=[[war_necessary3]],
}

War4={
	complete_type=0,
	guide_list={
		[1]={click_continue=false,effect_list={},necessary_ui_list={},},
		[2]={
			effect_list={
				[1]={
					aplha=1,
					dlg_sprite=[[pic_zhiying_ditu_2]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.13,y=-0.24,},
					near_pos={x=0,y=0,},
					text_list={
						[1]=[[点击#R切换#n怒气技          
怒气#R不足#n自动使用普攻。        ]],
					},
				},
				[2]={effect_type=[[hide_click_event]],},
				[3]={effect_type=[[hide_focus_box]],},
			},
			necessary_ui_list={},
		},
	},
	necessary_condition=[[war_necessary4]],
}

War5={
	complete_type=0,
	guide_list={		
		[1]={
			before_process={args={},func_name=[[war_5_step_one_before]],},
			effect_list={
				[1]={
					aplha=1,
					dlg_sprite=[[pic_zhiying_ditu_2]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.25,y=-0.24,},
					near_pos={x=0,y=0,},
					text_list={
						[1]=[[自动战斗时，#R点击怪物#n可进行集火喵~]],
					},
				},
				[2]={effect_type=[[hide_click_event]],},
				[3]={effect_type=[[hide_focus_box]],},
			},
			necessary_ui_list={[1]=[[war_speed_tips_bg]]},
		},
	},
	necessary_condition=[[war_necessary5]],
}

WarAutoWar={
	complete_type=0,
	guide_list={
		[1]={
			effect_list={
				[1]={
					aplha=1,
					dlg_sprite=[[pic_zhiying_ditu_2]],
					effect_type=[[dlg]],
					fixed_pos={x=0.27,y=-0.24,},
					near_pos={x=0,y=0,},
					text_list={[1]=[[点击这里即可#R自动战斗#n]],},
				},
				[2]={effect_type=[[hide_click_event]],},
				[3]={effect_type=[[hide_focus_box]],},
			},
			necessary_ui_list={},
		},
	},
	necessary_condition=[[WarAutoWar_necessary]],
}

WarReplace={
	guide_list={
		[1]={
			click_continue=true,
			after_process={args={},func_name=[[WarReplace_step_one_after]],},
			before_process={args={},func_name=[[WarReplace_step_one_before]],},
			effect_list={
				[1]={
					aplha=1,
					dlg_sprite=[[pic_zhiying_ditu_2]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.25,y=-0.24,},
					near_pos={x=0,y=0,},
					text_list={
						[1]=[[组队战斗中可替换伙伴，但个人可出战替补上场伙伴总数为4个。]],
					},
				},
			},
			necessary_ui_list={},
		},
		[2]={
			click_continue=false,			
			effect_list={
				[1]={effect_type=[[hide_click_event]],},
			},
			necessary_ui_list={},
		},		
	},
	necessary_condition=[[war_replace]],
}

warCommand={
	guide_list={
		[1]={
			before_process={args={},func_name=[[warCommand_step_one_before]],},
			after_process={args={},func_name=[[warCommand_step_one_after]],},	
			click_continue=true,
			effect_list={
				[1]={
		
					aplha=1,
					dlg_sprite=[[pic_zhiying_ditu_2]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.25,y=-0.24,},
					near_pos={x=0,y=0,},
					text_list={
						[1]=[[#R长按#n目标可打开指挥界面，方便#R指挥队友#n]],
					},
				},			
			},
			necessary_ui_list={},
		},	
	},
	necessary_condition=[[war_command]],
}

WarSpeed={
	guide_list={
		[1]={			
			before_process={args={},func_name=[[warSpeed_step_one_before]],},
			after_process={args={},func_name=[[warSpeed_step_one_after]],},			
			effect_list={
				[1]={
					aplha=1,
					dlg_sprite=[[pic_zhiying_ditu_2]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.25,y=-0.24,},
					near_pos={x=0,y=0,},
					text_list={
						[1]=[[点击右下角#R加速#n按钮，可加快战斗速度。]],
					},
				},
				[2]={effect_type=[[hide_click_event]],},
			},
			necessary_ui_list={[1]=[[war_speed_btn]]},
		},	
	},
	necessary_condition=[[war_speed]],
}

Partner_FWCD_One_MainMenu={
	complete_type=0,
	guide_list={
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=true,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[spine]],
					guide_voice_list_1=[[guide_mxm_001_0]],
					guide_voice_list_2=[[0]],
					side_list={[1]=[[0]],},
					spine_left_motion=[[dazhaohu]],
					spine_left_shape=[[1752]],
					spine_right_motion=[[idle]],
					spine_right_shape=[[ ]],
					text_list={[1]=[[给小伙伴#R穿戴符文#n可以提升伙伴的战斗能力。]],},
				},
			},
			necessary_ui_list={},
			stop_walk=true,
		},
		[2]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_partner_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_partner_btn]],},
			pass=true,
		},
	},
	necessary_condition=[[Partner_FWCD_One_MainMenu_show]],
}

Partner_FWCD_Two_MainMenu={
	complete_type=0,
	guide_list={
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=true,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[spine]],
					guide_voice_list_1=[[guide_mxm_003_1]],
					guide_voice_list_2=[[0]],
					side_list={[1]=[[0]],},
					spine_left_motion=[[chashou]],
					spine_left_shape=[[1752]],
					spine_right_motion=[[idle]],
					spine_right_shape=[[ ]],
					text_list={[1]=[[再给重华再戴一个#R符文#n吧，能让战斗更轻松哦。]],},
				},
			},
			necessary_ui_list={},
			stop_walk=true,
		},
		[2]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_partner_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_partner_btn]],},
			pass=true,
		},
	},
	necessary_condition=[[Partner_FWCD_Two_MainMenu_show]],
}

Partner_FWCD_Three_MainMenu={
	complete_type=0,
	guide_list={
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=true,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[spine]],
					guide_voice_list_1=[[house_mxm_001_1]],
					guide_voice_list_2=[[0]],
					side_list={[1]=[[0]],},
					spine_left_motion=[[jushou]],
					spine_left_shape=[[1752]],
					spine_right_motion=[[idle]],
					spine_right_shape=[[ ]],
					text_list={[1]=[[有新符文啦。去给重华穿个#R4件套#n吧~喵]],},
				},
			},
			necessary_ui_list={},
			stop_walk=true,
		},
		[2]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_partner_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_partner_btn]],},
			pass=true,
		},
	},
	necessary_condition=[[Partner_FWCD_Three_MainMenu_show]],
}

Partner_FWQH_MainMenu={
	complete_type=0,
	guide_list={
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=true,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[spine]],
					guide_voice_list_1=[[guide_mxm_001_4]],
					guide_voice_list_2=[[0]],
					side_list={[1]=[[0]],},
					spine_left_motion=[[dazhaohu]],
					spine_left_shape=[[1752]],
					spine_right_motion=[[idle]],
					spine_right_shape=[[ ]],
					text_list={[1]=[[#R深蓝琥珀#n可以#R升级#n符文喵~]],},
				},
			},
			necessary_ui_list={},
			stop_walk=true,
		},
		[2]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_partner_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_partner_btn]],},
			pass=true,
		},
	},
	necessary_condition=[[Partner_FWQH_MainMenu_show]],
}

Partner_HBPY_MainMenu={
	complete_type=0,
	guide_list={
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			after_process={args={},func_name=[[Partner_HBPY_MainMenu_step_one_after]],},
			click_continue=true,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[spine]],
					guide_voice_list_1=[[guide_mxm_002_3]],
					guide_voice_list_2=[[0]],
					side_list={[1]=[[0]],},
					spine_left_motion=[[chashou]],
					spine_left_shape=[[1752]],
					spine_right_motion=[[idle]],
					spine_right_shape=[[ ]],
					text_list={[1]=[[阿坊等级较低，先去#R提升等级#n吧喵]],},
				},
			},
			necessary_ui_list={},
			stop_walk=true,
		},
		[2]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_partner_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_partner_btn]],},
			pass=true,
		},
	},
	necessary_condition=[[Partner_HBPY_MainMenu_show]],
}

Partner_HBSX_MainMenu={
	complete_type=0,
	guide_list={
		[1]={
			before_process={args={},func_name=[[Partner_HBSX_MainMenu_step_one_before]],},
			click_continue=true,
			effect_list={
			},
			necessary_ui_list={},
		},
	},
	necessary_condition=[[Partner_HBSX_MainMenu_show]],
}

Partner_HBHC_MainMenu={
	complete_type=0,
	guide_list={
		[1]={
			click_continue=true,
			after_process={args={},func_name=[[Partner_HBHC_MainMenu_step_one_after]],},
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[spine]],
					spine_left_motion=[[chashou]],
					spine_left_shape=[[1752]],
					spine_right_motion=[[idle]],
					spine_right_shape=[[ ]],
					guide_voice_list_1=[[guide_mxm_002_0]],
					guide_voice_list_2=[[0]],
					side_list={[1]=[[0]],},
					text_list={
						[1]=[[伙伴也可以通过#R碎片合成#n获得~喵]],
					},
				},
			},
			necessary_ui_list={},
		},
	},
	necessary_condition=[[Partner_HBHC_MainMenu_show]],
}

Partner_HBJN_MainMenu={
	complete_type=0,
	guide_list={
		[1]={
			click_continue=true,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[spine]],
					spine_left_motion=[[chashou]],
					spine_left_shape=[[1752]],
					spine_right_motion=[[idle]],
					spine_right_shape=[[ ]],
					guide_voice_list_1=[[guide_mxm_002_0]],
					guide_voice_list_2=[[0]],
					side_list={[1]=[[0]],},
					text_list={
						[1]=[[培育时消耗#R同名伙伴#n，可以随机#R提升一个技能#n]],
					},
				},
			},
			necessary_ui_list={},
		},
		[2]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},			
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_partner_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_partner_btn]],},
			pass=true,
		},		
	},
	necessary_condition=[[Partner_HBJN_MainMenu_show]],
}

PartnerEquipMainMenuAfter={
	complete_type=0,
	guide_list={
		[1]={
			after_process={args={},func_name=[[partner_equip_main_menu_after_step_one_after]],},
			before_process={args={},func_name=[[partner_equip_main_menu_after_step_one_before]],},
			click_continue=true,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[spine]],
					spine_left_motion=[[chashou]],
					spine_left_shape=[[1752]],
					spine_right_motion=[[idle]],
					spine_right_shape=[[ ]],
					guide_voice_list_1=[[guide_mxm_002_0]],
					guide_voice_list_2=[[0]],
					side_list={[1]=[[0]],},
					text_list={
						[1]=[[ #R符文#n主要在流放之地中掉落，
详情可在#R冒险#n的#R符文副本#n页签
查看~喵]],
					},
				},
			},
			necessary_ui_list={},
			pass=true,
		},
	},
	necessary_condition=[[partner_equip_menu_view_after_show]],
}

YueJianWarMainMenuAfter={
	complete_type=0,
	guide_list={
		[1]={
			after_process={args={},func_name=[[yuejian_war_mainmenu_after_step_one_after]],},
			before_process={args={},func_name=[[yuejian_war_mainmenu_after_step_one_before]],},
			click_continue=true,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[spine]],
					spine_left_motion=[[jushou]],
					spine_left_shape=[[1752]],
					spine_right_motion=[[idle]],
					spine_right_shape=[[ ]],
					guide_voice_list_1=[[guide_mxm_003_1]],
					guide_voice_list_2=[[0]],
					side_list={[1]=[[0]],},
					text_list={[1]=[[#R伙伴碎片#n可以通过#R合成#n获得该伙伴完全体~喵]],},
				},
			},
			necessary_ui_list={},
		},
	},
	necessary_condition=[[yujian_war_menu_view_after_show]],
}

Partner_FWCD_One_PartnerMain={
	complete_type=0,
	guide_list={
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			after_process={args={},func_name=[[Partner_FWCD_One_PartnerMain_step_one_after]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					ui_effect=[[Finger]],
					ui_key=[[partner_equip_tab_btn]],
				},
				[2]={
					effect_tips_enum=1,
					effect_type=[[focus_ui]],
					focus_ui_size=1,
					ui_key=[[partner_equip_tab_btn]],
				},
			},
			necessary_ui_list={[1]=[[partner_equip_tab_btn]],},
			start_condition=[[open_partner_main_view]],
		},
		[2]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			before_process={args={},func_name=[[Partner_FWCD_One_PartnerMain_step_two_before]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					ui_effect=[[Finger]],
					ui_key=[[partner_equip_left_pos_1_add_btn]],
				},
				[2]={
					effect_tips_enum=1,
					effect_type=[[focus_ui]],
					focus_ui_size=1,
					ui_key=[[partner_equip_left_pos_1_add_btn]],
				},
			},
			necessary_ui_list={[1]=[[partner_equip_left_pos_1_add_btn]],},
		},
		[3]={			
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					ui_effect=[[Finger]],
					ui_key=[[partner_cost_buy_fuwen_btn]],
				},
			},
			necessary_ui_list={[1]=[[partner_cost_buy_fuwen_btn]],},
		},
	},
	necessary_condition=[[Partner_FWCD_One_PartnerMain_show]],
}

Partner_FWCD_Two_PartnerMain={
	complete_type=0,
	guide_list={
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=true,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[spine]],
					guide_voice_list_1=[[guide_mxm_003_1]],
					guide_voice_list_2=[[0]],
					side_list={[1]=[[0]],},
					spine_left_motion=[[chashou]],
					spine_left_shape=[[1752]],
					spine_right_motion=[[idle]],
					spine_right_shape=[[ ]],
					text_list={[1]=[[不要忘记给马面面穿戴#R符文#n了喵！]],},
				},
			},
			necessary_ui_list={},
			stop_walk=true,
		},	
		[2]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			after_process={args={},func_name=[[Partner_FWCD_One_PartnerMain_step_one_after]],},
			click_continue=false,
			effect_list={
				[1]={effect_type=[[click_ui]],ui_effect=[[Finger]],ui_key=[[partner_equip_tab_btn]],aplha=100,},
				[2]={
					effect_tips_enum=1,
					effect_type=[[focus_ui]],
					focus_ui_size=1,
					ui_effect=[[]],
					ui_key=[[partner_equip_tab_btn]],
				},
			},
			necessary_ui_list={[1]=[[partner_equip_tab_btn]],},
		},
		[3]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			before_process={args={},func_name=[[Partner_FWCD_Two_PartnerMain_step_three_before]],},
			after_process={args={},func_name=[[Partner_FWCD_Two_PartnerMain_step_three_after]],},			
			click_continue=false,
			continue_condition=[[Partner_FWCD_Two_PartnerMain_step_three_continue]],
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[focus_ui]],
					ui_effect=[[Finger]],
					mode=2,
					focus_ui_size=1,
					ui_key=[[partner_left_list_502_partner]],
				},
			},
			necessary_ui_list={[1]=[[partner_left_list_502_partner]],},			
		},
		[4]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[click_ui]],
					ui_effect=[[Finger]],
					ui_key=[[partner_equip_left_pos_1_add_btn]],
					aplha=100,
				},
				[2]={
					effect_tips_enum=1,
					effect_type=[[focus_ui]],
					focus_ui_size=1.5,
					ui_key=[[partner_equip_left_pos_1_add_btn]],
				},					
			},
			necessary_ui_list={[1]=[[partner_equip_left_pos_1_add_btn]],},
		},
		[5]={			
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[click_ui]],
					ui_effect=[[Finger]],
					ui_key=[[partner_cost_buy_fuwen_btn]],
					aplha=100,
				},
			},
			necessary_ui_list={[1]=[[partner_cost_buy_fuwen_btn]],},
		},		
	},
	necessary_condition=[[Partner_FWCD_Two_PartnerMain_show]],
}

Partner_FWCD_Three_PartnerMain={
	complete_type=0,
	guide_list={
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			after_process={args={},func_name=[[Partner_FWCD_One_PartnerMain_step_one_after]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					ui_effect=[[Finger]],
					ui_key=[[partner_equip_tab_btn]],
				},
				[2]={
					effect_tips_enum=1,
					effect_type=[[focus_ui]],
					focus_ui_size=1,
					ui_key=[[partner_equip_tab_btn]],
				},
			},
			necessary_ui_list={[1]=[[partner_equip_tab_btn]],},
			start_condition=[[open_partner_main_view]],
		},
		[2]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					ui_effect=[[Finger]],
					ui_key=[[partner_equip_type_list_Box_1_equip_btn]],
				},
			},
			necessary_ui_list={[1]=[[partner_equip_type_list_Box_1_equip_btn]],},
		},
		[3]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					ui_effect=[[Finger]],
					ui_key=[[partner_equip_rightpage_btn]],
				},
			},
			end_pass_guide=true,
			necessary_ui_list={[1]=[[partner_equip_rightpage_btn]],},
		},
		[4]={
			click_continue=true,
			effect_list={
				[1]={effect_type=[[focus_ui]],h=0.1,ui_key=[[partner_equip_type_label]],w=0.2,},
				[2]={
					aplha=100,
					effect_type=[[spine]],
					guide_voice_list_1=[[guide_mxm_003_2]],
					guide_voice_list_2=[[0]],
					side_list={[1]=[[1]],},
					spine_left_motion=[[idle]],
					spine_left_shape=[[ ]],
					spine_right_motion=[[dazhaohu]],
					spine_right_shape=[[1752]],
					text_list={[1]=[[4件同套装的符文可额外激活#R4件套效果#n]],},
				},
			},
			necessary_ui_list={[1]=[[partner_equip_type_label]],},
		},
	},
	necessary_condition=[[Partner_FWCD_Three_PartnerMain_show]],
}

Partner_FWQH_PartnerMain={
	complete_type=0,
	guide_list={
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			after_process={args={},func_name=[[Partner_FWCD_One_PartnerMain_step_one_after]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					ui_effect=[[Finger]],
					ui_key=[[partner_equip_tab_btn]],
				},
				[2]={
					effect_tips_enum=1,
					effect_type=[[focus_ui]],
					focus_ui_size=1,
					ui_key=[[partner_equip_tab_btn]],
				},
			},
			necessary_ui_list={[1]=[[partner_equip_tab_btn]],},
			start_condition=[[open_partner_main_view]],
		},	
		[2]={
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					ui_effect=[[Finger]],
					ui_key=[[partner_equip_strong_page_upgrade]],
				},
				[2]={
					aplha=100,
					effect_type=[[spine]],
					guide_voice_list_1=[[house_mxm_002_3]],
					guide_voice_list_2=[[0]],
					side_list={},
					spine_left_motion=[[jushou]],
					spine_left_shape=[[1752]],
					spine_right_motion=[[idle]],
					spine_right_shape=[[ ]],
					text_list={[1]=[[#R升级符文#n可提升属性]],},
				},
			},
			necessary_ui_list={[1]=[[partner_equip_strong_page_upgrade]],},
		},
	},
	necessary_condition=[[Partner_FWQH_PartnerMain_show]],
}

Partner_HPPY_PartnerMain={
	complete_type=0,
	guide_list={
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			before_process={args={},func_name=[[Partner_HPPY_PartnerMain_step_one_before]],},
			after_process={args={},func_name=[[Partner_HPPY_PartnerMain_step_two_after]],},			
			click_continue=false,
			continue_condition=[[Partner_HPPY_PartnerMain_step_one_continue]],
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[focus_ui]],
					ui_effect=[[Finger]],
					mode=2,
					focus_ui_size=1,
					ui_key=[[partner_left_list_501_partner]],
				},
			},
			necessary_ui_list={[1]=[[partner_left_list_501_partner]],},
			start_condition=[[open_partner_main_view]],
		},
		[2]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					ui_effect=[[Finger]],
					ui_key=[[partner_main_breed_btn]],
				},
			},
			necessary_ui_list={[1]=[[partner_main_breed_btn]],},
		},
		[3]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=1,
					effect_type=[[click_ui]],
					ui_effect=[[Finger]],
					ui_key=[[partner_upgrade_5_btn]],
				},
			},
			necessary_ui_list={[1]=[[partner_upgrade_5_btn]],},
		},
		[4]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=1,
					effect_type=[[click_ui]],
					ui_effect=[[Finger]],
					ui_key=[[partner_upgrade_close_btn]],
				},
			},
			end_pass_guide=true,
			necessary_ui_list={[1]=[[partner_upgrade_close_btn]],},
		},
	},
	necessary_condition=[[Partner_HPPY_PartnerMain_show]],
}

DrawCardLineUp_PartnerMain={
	complete_type=0,
	guide_list={		
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},			
			start_condition=[[open_partner_main_view]],
			click_continue=false,
			effect_list={
				[1]={effect_type=[[click_ui]],ui_effect=[[Finger]],ui_key=[[partner_lineup_tab_btn]],aplha=100,},
				[2]={
					effect_tips_enum=1,
					effect_type=[[focus_ui]],
					focus_ui_size=1,
					ui_effect=[[]],
					ui_key=[[partner_lineup_tab_btn]],
				},
			},
			necessary_ui_list={[1]=[[partner_lineup_tab_btn]],},
		},	
		[2]={	
			before_process={args={},func_name=[[DrawCardLineUp_PartnerMain_step_two_before]],},
			after_process={args={},func_name=[[DrawCardLineUp_PartnerMain_step_two_after]],},			
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},					
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[click_ui]],
					ui_effect=[[Finger]],
					ui_key=[[partner_lineup_pos_2_btn]],
					aplha=100,
				},
			},
			necessary_ui_list={[1]=[[partner_lineup_pos_2_btn]],},
		},						
		[3]={
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					ui_effect=[[Finger]],
					ui_key=[[partner_choose_partner_502]],
				},
			},
			start_condition=[[open_partner_choose_view]],
			necessary_ui_list={[1]=[[partner_choose_partner_502]],},
			need_guide_view=true,
		},

	},
	necessary_condition=[[DrawCardLineUp_PartnerMain_show]],
}

DrawCardLineUp_Two_PartnerMain={
	complete_type=0,
	guide_list={		
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},			
			start_condition=[[open_partner_main_view]],
			click_continue=false,
			effect_list={
				[1]={effect_type=[[click_ui]],ui_effect=[[Finger]],ui_key=[[partner_lineup_tab_btn]],aplha=100,},
				[2]={
					effect_tips_enum=1,
					effect_type=[[focus_ui]],
					focus_ui_size=1,
					ui_effect=[[]],
					ui_key=[[partner_lineup_tab_btn]],
				},
			},
			necessary_ui_list={[1]=[[partner_lineup_tab_btn]],},
		},	
		[2]={	
			before_process={args={},func_name=[[DrawCardLineUp_Two_PartnerMain_step_two_before]],},
			after_process={args={},func_name=[[DrawCardLineUp_Two_PartnerMain_step_two_after]],},			
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},					
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[click_ui]],
					ui_effect=[[Finger]],
					ui_key=[[partner_lineup_pos_3_btn]],
					aplha=100,
				},
			},
			necessary_ui_list={[1]=[[partner_lineup_pos_3_btn]],},
		},						
		[3]={
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					ui_effect=[[Finger]],
					ui_key=[[partner_choose_partner_403]],
				},
			},
			start_condition=[[open_partner_choose_view]],
			necessary_ui_list={[1]=[[partner_choose_partner_403]],},
			need_guide_view=true,
		},

	},
	necessary_condition=[[DrawCardLineUp_Two_PartnerMain_show]],
}

Yuling_PartnerMain={
	complete_type=0,
	guide_list={		
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},			
			start_condition=[[open_partner_main_view]],
			click_continue=false,
			effect_list={
				[1]={effect_type=[[click_ui]],ui_effect=[[Finger]],ui_key=[[partner_yuling_tab_btn]],aplha=100,},
				[2]={
					effect_tips_enum=1,
					effect_type=[[focus_ui]],
					focus_ui_size=1,
					ui_effect=[[]],
					ui_key=[[partner_yuling_tab_btn]],
				},
			},
			necessary_ui_list={[1]=[[partner_yuling_tab_btn]],},
		},	
		[2]={	
			before_process={args={},func_name=[[Yuling_PartnerMain_step_two_before]],},
			after_process={args={},func_name=[[Yuling_PartnerMain_step_two_after]],},							
			click_continue=false,
			effect_list={
				[1]={
					effect_tips_enum=1,
					effect_type=[[focus_ui]],					
					w=0.2,h=0.1,
					ui_key=[[partner_soul_type_1_fast_bg]],
				},				
				[2]={
					effect_type=[[click_ui]],
					ui_effect=[[Finger]],
					ui_key=[[partner_soul_type_1_fast_equip_btn]],
					aplha=100,
				},
				
			},
			necessary_ui_list={[1]=[[partner_soul_type_1_fast_equip_btn]],},
		},						

	},
	necessary_condition=[[Yuling_PartnerMain_show]],
}

DrawCardLineUp_Three_PartnerMain={
	complete_type=0,
	guide_list={
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=true,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[spine]],
					guide_voice_list_1=[[guide_mxm_003_1]],
					guide_voice_list_2=[[0]],
					side_list={[1]=[[0]],},
					spine_left_motion=[[jushou]],
					spine_left_shape=[[1752]],
					spine_right_motion=[[idle]],
					spine_right_shape=[[ ]],
					text_list={[1]=[[阿坊的等级已经提升了，赶紧让她#R上阵#n战斗吧。]],},
				},
			},
			necessary_ui_list={},
			stop_walk=true,
		},
		[2]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					ui_effect=[[Finger]],
					ui_key=[[partner_lineup_tab_btn]],
				},
				[2]={
					effect_tips_enum=1,
					effect_type=[[focus_ui]],
					focus_ui_size=1,
					ui_key=[[partner_lineup_tab_btn]],
				},
			},
			necessary_ui_list={[1]=[[partner_lineup_tab_btn]],},
			start_condition=[[open_partner_main_view]],
		},
		[3]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			after_process={args={},func_name=[[DrawCardLineUp_Three_PartnerMain_step_two_after]],},
			before_process={args={},func_name=[[DrawCardLineUp_Three_PartnerMain_step_two_before]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					ui_effect=[[Finger]],
					ui_key=[[partner_lineup_pos_4_btn]],
				},
			},
			necessary_ui_list={[1]=[[partner_lineup_pos_4_btn]],},
		},
		[4]={
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					ui_effect=[[Finger]],
					ui_key=[[partner_choose_partner_501]],
				},
			},
			necessary_ui_list={[1]=[[partner_choose_partner_501]],},
			need_guide_view=true,
			start_condition=[[open_partner_choose_view]],
		},
	},
	necessary_condition=[[DrawCardLineUp_Three_PartnerMain_show]],
}

Partner_HBJN_PartnerMain={
	complete_type=0,
	guide_list={
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			start_condition=[[open_partner_main_view]],
			after_process={args={},func_name=[[Partner_FWCD_One_PartnerMain_step_one_after]],},
			click_continue=false,
			effect_list={
				[1]={effect_type=[[click_ui]],ui_effect=[[Finger]],ui_key=[[partner_main_breed_btn]],aplha=100,},
			},
			necessary_ui_list={[1]=[[partner_main_breed_btn]],},
		},
		[2]={	
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},					
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[click_ui]],
					ui_effect=[[Finger]],
					offset_pos={x=37,y=-37},
					ui_key=[[partner_upgrade_list_302_partner_btn]],
					aplha=100,
				},
			},
			necessary_ui_list={[1]=[[partner_upgrade_list_302_partner_btn]],},
		},	
		[3]={	
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},					
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[click_ui]],
					ui_effect=[[Finger]],
					ui_key=[[partner_upgrade_ok_btn]],
					aplha=100,
				},
			},
			necessary_ui_list={[1]=[[partner_upgrade_ok_btn]],},
		},		
	},
	necessary_condition=[[Partner_HBJN_PartnerMain_show]],
}

Partner_HBSX_PartnerMain={
	complete_type=0,
	guide_list={		
		[1]={
			continue_condition=[[Partner_HBSX_PartnerMain_step_one_continue]],
			click_continue=false,
			effect_list={
				[1]={
					aplha=1,
					effect_type=[[spine]],
					guide_voice_list_1=[[guide_mxm_001_4]],
					guide_voice_list_2=[[0]],
					side_list={[1]=[[0]],},
					spine_left_motion=[[dazhaohu]],
					spine_left_shape=[[1752]],
					spine_right_motion=[[idle]],
					spine_right_shape=[[ ]],
					text_list={[1]=[[培育时消耗#R碎片#n，可以大幅度提升属性喵~]],},
				},
				[2]={effect_type=[[hide_click_event]],},
			},			
			necessary_ui_list={},
		},
	},
	necessary_condition=[[Partner_HBSX_PartnerMain_show]],
}

ChapterFuBen_Hard={
	complete_type=0,
	guide_list={		
		[1]={
			before_process={args={},func_name=[[ChapterFuBen_Hard_step_one_before]],},
			after_process={args={},func_name=[[ChapterFuBen_Hard_step_one_after]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=1,
					effect_type=[[spine]],
					spine_left_motion=[[chashou]],
					spine_left_shape=[[ ]],
					spine_right_motion=[[chashou]],
					spine_right_shape=[[1752]],
					guide_voice_list_1=[[0]],
					guide_voice_list_2=[[guide_mxm_002_0]],
					side_list={[1]=[[1]],},
					text_list={[1]=[[挑战#R困难战役#n，可以获得#R伙伴碎片#n喵]],},
				},		
				[2]={effect_type=[[hide_click_event]]},		
			},
			force_hide_continue_label=true,
			necessary_ui_list={[1]=[[chapter_fuben_btn_1]]},
			need_guide_view=true,
		},	
	},
	necessary_condition=[[ChapterFuBen_Hard_show]],
}

War3MainMenu={
	complete_type=0,
	guide_list={
		[1]={
			end_pass_guide=true,
			after_process={args={},func_name=[[war_3_main_menu_step_one_after]],},
			before_process={args={},func_name=[[war_3_main_menu_step_one_before]],},
			click_continue=true,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[spine]],
					spine_left_motion=[[jushou]],
					spine_left_shape=[[1752]],
					spine_right_motion=[[idle]],
					spine_right_shape=[[ ]],
					guide_voice_list_1=[[guide_mxm_003_2]],
					guide_voice_list_2=[[0]],
					side_list={[1]=[[0]],},
					text_list={[1]=[[更多#R战斗操作#n技巧可在“#R成长手册#n”中查看。]],},
				},
			},
			necessary_ui_list={},
		},
	},
	necessary_condition=[[war3_after_main_menu_view_show]],
}

ArenaPowerGuide={
	necessary_condition=[[arena_power_guide]],	
}

welcome_two={
	necessary_condition=[[welcome_ani]],	
}
rename_one={
	necessary_condition=[[rename_ani]],	
}

HuoyueduGuide_Open={
	necessary_condition=[[huoyueduguide_open]],	
}

YueJian_Before_Open={
	necessary_condition=[[yuejian_before_open]],	
}


Skill={
	complete_type=0,
	guide_list={
		[1]={
			before_process={args={},func_name=[[Skill_step_one_before]],},
			click_continue=true,
			effect_list={
				[1]={
					aplha=1,
					effect_type=[[spine]],
					spine_left_motion=[[idle]],
					spine_left_shape=[[ ]],
					spine_right_motion=[[jushou]],
					spine_right_shape=[[1752]],
					guide_voice_list_1=[[guide_mxm_003_2]],
					guide_voice_list_2=[[0]],
					side_list={[1]=[[1]],},
					text_list={
						[1]=[[可零成本#R随时切换流派#n，使用不同技能，搭配不同阵容。]],
					},
				},
			},
			necessary_ui_list={},
		},
	},
	necessary_condition=[[skill_view_show]],
}

Skill_Two={
	complete_type=0,
	guide_list={
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=false,
			start_condition=[[skill_view_show_end]],
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					near_pos={x=0,y=0,},
					ui_effect=[[Finger]],
					ui_key=[[skill_skillbtn_3]],
				},
			},
			necessary_ui_list={[1]=[[skill_skillbtn_3]],},
		},
		[2]={
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					near_pos={x=0,y=0,},
					ui_effect=[[Finger]],
					ui_key=[[skill_learn_btn]],
				},
			},
			necessary_ui_list={[1]=[[skill_learn_btn]],},
		},		
	},
	necessary_condition=[[skill_two_view_show]],
}

Skill_Three={
	complete_type=0,
	guide_list={
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=false,
			start_condition=[[skill_view_show_end]],
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					near_pos={x=0,y=0,},
					ui_effect=[[Finger]],
					ui_key=[[skill_skillbtn_5]],
				},
			},
			necessary_ui_list={[1]=[[skill_skillbtn_5]],},
		},
		[2]={
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					near_pos={x=0,y=0,},
					ui_effect=[[Finger]],
					ui_key=[[skill_learn_btn]],
				},
			},
			necessary_ui_list={[1]=[[skill_learn_btn]],},
		},				
	},
	necessary_condition=[[skill_three_view_show]],
}

Skill_Four={
	complete_type=0,
	guide_list={
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					near_pos={x=0,y=0,},
					ui_effect=[[Finger]],
					ui_key=[[skill_skillbtn_6]],
				},
			},
			necessary_ui_list={[1]=[[skill_skillbtn_6]],},
			start_condition=[[skill_view_show_end]],
		},
		[2]={
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					near_pos={x=0,y=0,},
					ui_effect=[[Finger]],
					ui_key=[[skill_learn_btn]],
				},
			},
			necessary_ui_list={[1]=[[skill_learn_btn]],},
		},
		[3]={
			click_continue=true,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[spine]],
					guide_voice_list_1=[[guide_mxm_003_3]],
					guide_voice_list_2=[[0]],
					side_list={[1]=[[0]],},
					spine_left_motion=[[jushou]],
					spine_left_shape=[[1752]],
					spine_right_motion=[[chashou]],
					spine_right_shape=[[ ]],
					text_list={[1]=[[技能提升至一定等级，可获得#R额外效果#n。]],},
				},
				[2]={
					effect_tips_enum=1,
					effect_type=[[focus_ui]],
					h=0.1,
					ui_key=[[skill_des_other_label]],
					w=0.2,
				},
			},
			end_pass_guide=true,
			necessary_ui_list={[1]=[[skill_des_other_label]],},
			need_guide_view=true,
		},
	},
	necessary_condition=[[skill_four_view_show]],
}

Forge_Gem_View={
	complete_type=0,
	guide_list={
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			start_condition=[[Forge_View_open]],
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					near_pos={x=0,y=0,},
					ui_effect=[[Finger]],
					ui_key=[[forge_equip_pos_1]],
				},
			},
			necessary_ui_list={[1]=[[forge_equip_pos_1]],},
		},
		[2]={
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					near_pos={x=0,y=0,},
					ui_effect=[[Finger]],
					ui_key=[[forge_gem_fast_mix_btn]],
				},
			},
			necessary_ui_list={[1]=[[forge_gem_fast_mix_btn]],},
		},	
		[3]={
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					near_pos={x=0,y=0,},
					ui_effect=[[Finger]],
					ui_key=[[confirm_ok_btn]],
				},
			},
			necessary_ui_list={[1]=[[confirm_ok_btn]],},
		},				
	},
	necessary_condition=[[forge_gem_view_show]],
}

FirstCharge_MainMenu={
	complete_type=3,
	guide_list={
		[1]={
			before_process={args={},func_name=[[FirstCharge_MainMenu_step_one_before]],},
			click_continue=false,
			effect_list={[1]={effect_type=[[none]],},},
			necessary_ui_list={},
		},
	},
	necessary_condition=[[FirstCharge_MainMenu_show]],
}
Forge_Strength_View={
	complete_type=0,
	guide_list={
		[1]={
			click_continue=false,
			start_condition=[[Forge_View_open]],
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					near_pos={x=0,y=0,},
					ui_effect=[[Finger]],
					ui_key=[[forge_strength_fast_strength_btn]],
				},
			},
			necessary_ui_list={[1]=[[forge_strength_fast_strength_btn]],},
		},	
		[2]={
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					near_pos={x=0,y=0,},
					ui_effect=[[Finger]],
					ui_key=[[confirm_ok_btn]],
				},
			},
			necessary_ui_list={[1]=[[confirm_ok_btn]],},
		},			
	},
	necessary_condition=[[forge_strength_view_show]],
}

Convoy_View={
	complete_type=0,
	guide_list={
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=true,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[spine]],
					guide_voice_list_1=[[guide_mxm_003_2]],
					guide_voice_list_2=[[guide_mxm_003_2]],
					side_list={[1]=[[0]],},
					spine_left_motion=[[jushou]],
					spine_left_shape=[[1752]],
					spine_right_motion=[[daiji]],
					spine_right_shape=[[ ]],
					text_list={[1]=[[恩，你身手不错，来接取更高报酬的委托吧。]],},
				},
			},
			necessary_ui_list={},
		},
		[2]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					near_pos={x=0,y=0,},
					ui_effect=[[Finger]],
					ui_key=[[convoy_refresh_btn]],
				},
			},
			necessary_ui_list={[1]=[[convoy_refresh_btn]],},
		},
		[3]={
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					near_pos={x=0,y=0,},
					ui_effect=[[Finger]],
					ui_key=[[convoy_start_btn]],
				},
			},
			necessary_ui_list={[1]=[[convoy_start_btn]],},
		},
	},
	necessary_condition=[[convoy_view_show]],
}

EquipFuben_View={
	complete_type=0,
	guide_list={
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=false,
			start_condition=[[EquipFuben_View_open]],
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					near_pos={x=0,y=0,},
					ui_effect=[[Finger]],
					ui_key=[[equipfuben_main_enter_btn]],
				},
			},
			necessary_ui_list={},
		},	
		[2]={
			click_continue=false,
			start_condition=[[EquipFuben_Detail_View_open]],
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					near_pos={x=0,y=0,},
					ui_effect=[[Finger]],
					ui_key=[[equipfuben_detail_enter_btn]],
				},
			},
			necessary_ui_list={[1]=[[equipfuben_detail_enter_btn]],},
		},	
	},
	necessary_condition=[[EquipFuben_View_show]],
}

QuickUse_View={
	complete_type=0,
	guide_list={		
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					near_pos={x=0,y=0,},
					ui_effect=[[Finger]],
					ui_key=[[quickusew_use_btn]],
				},
			},
			necessary_ui_list={[1]=[[quickusew_use_btn]],},
		},		
	},
	necessary_condition=[[quickuse_view_show]],
}

Partner={
	complete_type=0,
	guide_list={
		[1]={
			click_continue=true,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.32,y=-0.33,},
					flip_y=false,
					near_pos={x=0,y=0,},
					play_tween=true,
					texture_name=[[guide_2.png]],
				},
				[2]={
					dlg_sprite=[[pic_zhiying_ditu_1]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.2,y=-0.1,},
					near_pos={x=0,y=0,},
					next_tip=false,
					play_tween=true,
					text_list={
						[1]=[[ /(ㄒoㄒ)/~嗷呜~宝宝委屈，
最近被师傅训斥，说我没教
你伙伴快速升级的方法。]],
					},
				},
			},
			necessary_ui_list={},
		},
	},
	necessary_condition=[[partner_view_show]],
}


DrawCard={
	complete_type=0,
	guide_list={
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					offset_pos={x=62,y=-73,},
					ui_effect=[[Finger]],
					ui_key=[[partner_draw_partner_1_1_btn]],
				},
			},
			necessary_ui_list={[1]=[[partner_draw_partner_1_1_btn]],},
		},
		[2]={
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					ui_effect=[[Finger]],
					ui_key=[[partner_draw_partner_confirm_btn]],
				},
			},
			necessary_ui_list={[1]=[[partner_draw_partner_confirm_btn]],},
		},
	},
	necessary_condition=[[drawcard_show]],
}

DrawCard_Two={
	complete_type=0,
	guide_list={
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					offset_pos={x=62,y=-73,},
					ui_effect=[[Finger]],
					ui_key=[[partner_draw_partner_1_1_btn]],
				},
			},
			necessary_ui_list={[1]=[[partner_draw_partner_1_1_btn]],},
		},
		[2]={
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					ui_effect=[[Finger]],
					ui_key=[[partner_draw_partner_confirm_btn]],
				},
			},
			necessary_ui_list={[1]=[[partner_draw_partner_confirm_btn]],},
		},
	},
	necessary_condition=[[drawcard_two_show]],
}

DrawCard_Three={
	complete_type=0,
	guide_list={
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					offset_pos={x=62,y=-73,},
					ui_effect=[[Finger]],
					ui_key=[[partner_draw_partner_1_1_btn]],
				},
			},
			necessary_ui_list={[1]=[[partner_draw_partner_1_1_btn]],},
		},
		[2]={
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					ui_effect=[[Finger]],
					ui_key=[[partner_draw_partner_confirm_btn]],
				},
			},
			necessary_ui_list={[1]=[[partner_draw_partner_confirm_btn]],},
		},
		[3]={
			click_continue=false,
			effect_list={
				[1]={
					aplha=1,
					effect_type=[[click_ui]],
					ui_effect=[[Finger]],
					ui_key=[[partner_gain_close_btn]],
				},
			},
			end_pass_guide=true,
			necessary_ui_list={[1]=[[partner_gain_close_btn]],},
		},
		[4]={
			click_continue=false,
			effect_list={
				[1]={
					aplha=1,
					effect_type=[[click_ui]],
					ui_effect=[[Finger]],
					ui_key=[[partner_draw_partner_close_btn]],
				},
			},
			end_pass_guide=true,
			necessary_ui_list={[1]=[[partner_draw_partner_close_btn]],},
		},
	},
	necessary_condition=[[drawcard_three_show]],
}

MapBook={
	complete_type=0,
	guide_list={
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			before_process={args={},func_name=[[MapBook_step_one_before]],},
			click_continue=true,
			effect_list={},
			force_hide_continue_label=true,
			necessary_ui_list={},
			need_guide_view=true,
		},
		[2]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			before_process={args={},func_name=[[MapBook_step_two_before]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					ui_effect=[[Finger]],
					ui_key=[[mapbook_world_box]],
				},
			},
			necessary_ui_list={[1]=[[mapbook_world_box]],},
			need_guide_view=true,
		},
	},
	necessary_condition=[[map_book_view_show]],
}

WorldMapBook={
	complete_type=0,
	guide_list={
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=true,
			effect_list={
				[1]={
					aplha=130,
					effect_type=[[spine]],
					spine_left_motion=[[chashou]],
					spine_left_shape=[[1752]],
					spine_right_motion=[[idle]],
					spine_right_shape=[[ ]],
					guide_voice_list_1=[[guide_mxm_002_0]],
					guide_voice_list_2=[[0]],
					side_list={[1]=[[0]],},
					text_list={
						[1]=[[这里记载着世界起源的秘密。
多摸索，更多惊喜等你发现哦~喵]],
					},
				},
			},
			necessary_ui_list={},
			need_guide_view=true,
			start_condition=[[WorldMapBook_step_one_condition]],
		},
		[2]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=130,
					effect_type=[[click_ui]],
					ui_effect=[[Finger]],
					ui_key=[[mapbook_world_city_1_btn]],
				},
			},
			necessary_ui_list={[1]=[[mapbook_world_city_1_btn]],},
			need_guide_view=true,
		},
		[3]={
			after_process={args={},func_name=[[WorldMapBook_step_three_after]],},
			click_continue=false,
			continue_condition=[[WorldMapBook_step_three_continue]],
			effect_list={
				[1]={
					aplha=130,
					effect_tips_enum=1,
					effect_type=[[focus_ui]],
					focus_ui_size=1,
					ui_effect=[[Finger]],
					ui_key=[[mapbook_world_city_award_btn]],
				},
			},
			necessary_ui_list={[1]=[[mapbook_world_city_award_btn]],},
			need_guide_view=true,
		},
	},
	necessary_condition=[[WorldMapBook_show]],
}

LilianView={
	complete_type=0,
	guide_list={
		[1]={
			before_process={args={},func_name=[[LilianView_step_one_before]],},
			click_continue=true,
			effect_list={
				[1]={
					aplha=1,
					dlg_is_left=true,
					dlg_sprite=[[pic_zhiying_ditu_1]],
					dlg_tips_sprite=[[guide_3]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.07,y=-0.35,},
					near_pos={x=0,y=0,},
					play_tween=true,
					text_list={
						[1]=[[  没时间解释了， 
 #R大量主角经验#n和#R鲜肉包 #n（伙伴升级素材）        
正等待你的驾临，快上车！喵~
]],
					},
				},
			},
			necessary_ui_list={},
		},
	},
	necessary_condition=[[LilianView_show]],
}

TeamMainView_HandyBuild={
	complete_type=0,
	guide_list={
		[1]={
			before_process={args={},func_name=[[LilianView_step_one_before]],},
			click_continue=true,
			effect_list={
				[1]={
					aplha=1,
					effect_type=[[spine]],
					spine_left_motion=[[idle]],
					spine_left_shape=[[ ]],
					spine_right_motion=[[jushou]],
					spine_right_shape=[[1752]],
					guide_voice_list_1=[[guide_mxm_001_0]],
					guide_voice_list_2=[[0]],
					side_list={[1]=[[1]],},
					text_list={
						[1]=[[茶会开始拉，快来#R寻找#n基友一起#R挑战#n茶会嘉宾们吧]],
					},
				},
			},
			necessary_ui_list={},
		},
	},
	necessary_condition=[[TeamMainView_HandyBuild]],
}

PEFbView={
	complete_type=0,
	guide_list={
		[1]={
			click_continue=true,
			effect_list={
				[1]={
					aplha=1,
					effect_type=[[spine]],
					guide_voice_list_1=[[guide_mxm_003_2]],
					guide_voice_list_2=[[0]],
					side_list={[1]=[[1]],},
					spine_left_motion=[[idle]],
					spine_left_shape=[[ ]],
					spine_right_motion=[[jushou]],
					spine_right_shape=[[1752]],
					text_list={[1]=[[挑战#R符文副本#n可以获得#R高星级符文#n。]],},
				},
			},
			end_pass_guide=true,
			leave_team=[[pefuben]],
			necessary_ui_list={},
		},
	},
	necessary_condition=[[CPEFbView_show]],
}

HuntPartnerSoulView={
	complete_type=0,
	guide_list={
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=true,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[spine]],
					guide_voice_list_1=[[guide_mxm_001_0]],
					guide_voice_list_2=[[0]],
					side_list={[1]=[[0]],},
					spine_left_motion=[[dazhaohu]],
					spine_left_shape=[[1752]],
					spine_right_motion=[[idle]],
					spine_right_shape=[[ ]],
					text_list={[1]=[[#R使用金币#n可以快速获得御灵。]],},
				},
			},
			necessary_ui_list={},
			stop_walk=true,
		},
		[2]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					near_pos={x=0,y=0,},
					ui_effect=[[Finger]],
					ui_key=[[hunt_partner_soul_list_1_btn]],
				},
			},
			necessary_ui_list={[1]=[[hunt_partner_soul_list_1_btn]],},
			need_guide_view=true,
		},
		[3]={
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					near_pos={x=0,y=0,},
					ui_effect=[[Finger]],
					ui_key=[[hunt_partner_soul_1_1_btn]],
				},
				[2]={
					aplha=100,
					effect_type=[[spine]],
					guide_voice_list_1=[[house_mxm_002_1]],
					guide_voice_list_2=[[0]],
					side_list={[1]=[[1]],},
					spine_left_motion=[[idle]],
					spine_left_shape=[[ ]],
					spine_right_motion=[[chashou]],
					spine_right_shape=[[1752]],
					text_list={[1]=[[#R直接点击#n已获得的御灵，即可拾取]],},
				},				
			},
			necessary_ui_list={[1]=[[hunt_partner_soul_1_1_btn]],},
			need_guide_view=true,
		},
	},
	necessary_condition=[[HuntPartnerSoulView_show]],
}

ShiBaiMainmenuView={
	complete_type=0,
	guide_list={
		[1]={
			before_process={args={},func_name=[[ShiBaiMainmenuView_step_one_before]],},
			click_continue=true,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[spine]],
					spine_left_motion=[[chashou]],
					spine_left_shape=[[1752]],
					spine_right_motion=[[idle]],
					spine_right_shape=[[ ]],
					guide_voice_list_1=[[guide_mxm_002_0]],
					guide_voice_list_2=[[0]],
					side_list={[1]=[[0]],[2]=[[0]],},
					text_list={[1]=[[想要#R提升实力#n，可以多看看“#R成长手册#n”哦~喵]],},
				},
			},
			necessary_ui_list={},
			need_guide_view=true,
		},
	},
	necessary_condition=[[ShiBaiMainmenuView_show]],
}

PartnerFightMainmenuView={
	complete_type=0,
	guide_list={
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_partner_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_partner_btn]],},
			need_guide_view=true,
		},
	},
	necessary_condition=[[PartnerFightMainmenuView_show]],
}

PartnerFightLineupView={
	complete_type=0,
	guide_list={
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},			
			start_condition=[[open_partner_main_view]],
			click_continue=false,
			effect_list={
				[1]={effect_type=[[click_ui]],ui_effect=[[Finger]],ui_key=[[partner_lineup_tab_btn]],aplha=100,},
				[2]={
					effect_tips_enum=1,
					effect_type=[[focus_ui]],
					focus_ui_size=1,
					ui_effect=[[]],
					ui_key=[[partner_lineup_tab_btn]],
				},
			},
			necessary_ui_list={[1]=[[partner_lineup_tab_btn]],},
		},
		[2]={
			before_process={args={},func_name=[[PartnerFightLineupView_step_two_before]],},
			after_process={args={},func_name=[[PartnerFightLineupView_step_two_after]],},			
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					ui_effect=[[Finger]],
					ui_key=[[partner_lineup_pos_3_btn]],
				},
			},
			necessary_ui_list={[1]=[[partner_lineup_pos_3_btn]],},
			need_guide_view=true,
		},
	},
	necessary_condition=[[PartnerFightLineupView_show]],
}

PartnerFightChooseView={
	complete_type=0,
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					ui_effect=[[Finger]],
					ui_key=[[partner_choose_partner_403]],
				},
			},
			start_condition=[[open_partner_choose_view]],
			necessary_ui_list={[1]=[[partner_choose_partner_403]],},
			need_guide_view=true,
		},
	},
	necessary_condition=[[PartnerFightChooseView_show]],
}


MapSwitchMainmenu={
	complete_type=0,
	guide_list={
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=true,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[spine]],
					guide_voice_list_1=[[guide_mxm_001_0]],
					guide_voice_list_2=[[0]],
					side_list={[1]=[[0]],[2]=[[0]],},
					spine_left_motion=[[dazhaohu]],
					spine_left_shape=[[1752]],
					spine_right_motion=[[idle]],
					spine_right_shape=[[ ]],
					text_list={[1]=[[可通过#R地图传送#n快速到各地。]],},
				},
			},
			necessary_ui_list={},
			need_guide_view=true,
		},
		[2]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_minimap_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_minimap_btn]],},
			need_guide_view=true,
		},
	},
	necessary_condition=[[MapSwitchMainmenu_show]],
}

MapSwitchMapView={
	complete_type=0,
	guide_list={
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=false,
			start_condition=[[MapSwitchMapView_view_show_end]],
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					ui_effect=[[Finger]],
					ui_key=[[map_world_map_btn]],
				},
			},
			necessary_ui_list={[1]=[[map_world_map_btn]],},
			need_guide_view=true,
		},
		[2]={			
			click_continue=false,
			effect_list={
				[1]={
					aplha=1,
					effect_type=[[click_ui]],
					ui_effect=[[Finger]],
					ui_key=[[map_world_map_city_2_btn]],
				},
			},
			necessary_ui_list={[1]=[[map_world_map_city_2_btn]],},
			need_guide_view=true,
		},
	},
	necessary_condition=[[MapSwitchMapView_show]],
}

Pata={
	complete_type=0,
	guide_list={
		[1]={
			click_continue=false,			
			effect_list={
				[1]={effect_type=[[focus_ui]],w=0.1,h=0.2,ui_key=[[pata_monster_texture]],},
				[2]={effect_type=[[click_ui]],ui_effect=[[Finger]],ui_key=[[pata_monster_texture]],},
				[3]={
					aplha=100,
					dlg_is_left=true,
					dlg_sprite=[[pic_zhiying_ditu_1]],
					dlg_tips_sprite=[[guide_3]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.08,y=0.2,},
					near_pos={x=0,y=0,},
					play_tween=true,
					text_list={
						[1]=[[ (颤音)欢迎……来到可怕的地牢
 #R直接点击#n要挑战的对象即可进入战斗。]],
					},
				},
			},
			necessary_ui_list={[1]=[[pata_monster_texture]],},
		},
	},
	necessary_condition=[[pata_view_show]],
}

YueJian_Before={
	complete_type=0,
	guide_list={
		[1]={
			stop_walk=true,
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			leave_team="yjhj",
			after_process={args={},func_name=[[yuejian_after_step_one_before]],},
			click_continue=true,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[spine]],
					spine_left_motion=[[jushou]],
					spine_left_shape=[[1752]],
					spine_right_motion=[[idle]],
					spine_right_shape=[[ ]],
					guide_voice_list_1=[[house_mxm_001_1]],
					guide_voice_list_2=[[0]],
					side_list={[1]=[[0]],},
					text_list={
						[1]=[[月见幻境已经开启，  
“#R冒险#n”中可找到“#R月见幻境#n”]],
					},
				},
			},
			necessary_ui_list={},
		},
		[2]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					near_pos={x=0,y=0,},
					ui_effect=[[round]],
					ui_key=[[mainmenu_schedule_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_schedule_btn]],},
		},
	},
	necessary_condition=[[yuejian_before_show]],
}

YueJian_SchduleView={
	complete_type=0,
	guide_list={
		[1]={			
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					near_pos={x=0,y=0,},
					ui_effect=[[Finger]],
					ui_key=[[schedule_allday_go_btn]],
				},
			},
			necessary_ui_list={[1]=[[schedule_allday_go_btn]],},
		},
	},
	necessary_condition=[[yuejian_schedule_view_show]],
}

YueJian={
	complete_type=0,
	guide_list={
		[1]={
			after_process={args={},func_name=[[yuejian_step_one_after]],},
			before_process={args={},func_name=[[yuejian_step_one_before]],},
			click_continue=true,
			effect_list={
				[1]={
					effect_type=[[spine]],
					spine_left_motion=[[dazhaohu]],
					spine_left_shape=[[1752]],
					spine_right_motion=[[chashou]],
					spine_right_shape=[[ ]],
					guide_voice_list_1=[[guide_mxm_001_0]],
					guide_voice_list_2=[[guide_mxm_001_0]],
					side_list={[1]=[[0]],[2]=[[0]],},
					text_list={
						[1]=[[以“#R镜花水月#n”作为媒介，
可以打开月见幻境的通道。]],
						[2]=[[#R选择#n要击退的黑化伙伴，
击退可获得对应的#R伙伴碎片#n。]],
					},
				},
			},
			necessary_ui_list={},
			pass=true,
		},
	},
	necessary_condition=[[yuejian_view_show]],
}

Arena={
	complete_type=0,
	guide_list={
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=true,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[spine]],
					spine_left_motion=[[dazhaohu]],
					spine_left_shape=[[1752]],
					spine_right_motion=[[dazhaohu]],
					spine_right_shape=[[ ]],
					guide_voice_list_1=[[guide_mxm_001_0]],
					guide_voice_list_2=[[0]],
					side_list={[1]=[[0]],},
					text_list={
						[1]=[[#R比武场#n是验证实力的重要场所。
我们先来一场模拟战热身吧。]],
					},
				},
			},
			necessary_ui_list={},
		},
		[2]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					near_pos={x=0,y=0,},
					ui_effect=[[Finger]],
					ui_key=[[arena_fight_btn]],
				},
			},
			necessary_ui_list={[1]=[[arena_fight_btn]],},
		},
	},
	necessary_condition=[[arena_view_show]],
}


PEFuben_MainMenu={
	complete_type=0,
	guide_list={
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=false,
			effect_list={
				[1]={
					effect_tips_enum=1,
					aplha=100,
					effect_type=[[click_ui]],
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_schedule_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_schedule_btn]],},
			need_guide_view=true,
		},
	},
	necessary_condition=[[PEFuben_MainMenu_show]],
}

PEFuben_SchduleView={
	complete_type=0,
	guide_list={
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					near_pos={x=0,y=0,},
					ui_effect=[[Finger]],
					ui_key=[[schedule_allday_go_btn]],
				},
			},
			necessary_ui_list={[1]=[[schedule_allday_go_btn]],},
		},
	},
	necessary_condition=[[PEFuben_SchduleView_view_show]],
}

Equipfuben_SchduleView={
	complete_type=0,
	guide_list={
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					near_pos={x=0,y=0,},
					ui_effect=[[Finger]],
					ui_key=[[schedule_allday_go_btn]],
				},
			},
			necessary_ui_list={[1]=[[schedule_allday_go_btn]],},
		},
	},
	necessary_condition=[[Equipfuben_SchduleView_view_show]],
}

Convoy_SchduleView={
	complete_type=0,
	guide_list={
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					near_pos={x=0,y=0,},
					ui_effect=[[Finger]],
					ui_key=[[schedule_allday_go_btn]],
				},
			},
			necessary_ui_list={[1]=[[schedule_allday_go_btn]],},
		},
	},
	necessary_condition=[[Convoy_SchduleView_view_show]],
}

StoryDlg={
	complete_type=0,
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={effect_type=[[focus_common]],h=1,w=1,x=0.5,y=0.5,},
				[2]={
					effect_type=[[click_ui]],
					near_pos={x=-10.0,y=0,},
					ui_effect=[[Finger]],
					ui_key=[[dlg_sel_btn]],
				},
			},
			necessary_ui_list={[1]=[[dlg_sel_btn]],},
			start_condition=[[first_stroydlg_show]],
		},
	},
	necessary_condition=[[stroydlg_show]],
}

TaskNv={
	complete_type=0,
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={effect_type=[[focus_common]],h=1,w=1,x=0.5,y=0.5,},
				[2]={
					effect_type=[[click_ui]],
					near_pos={x=0,y=0,},
					ui_effect=[[Finger]],
					ui_key=[[task_nv_btn]],
				},
			},
			necessary_ui_list={[1]=[[task_nv_btn]],},
			start_condition=[[first_taskNv_show]],
		},
	},
	necessary_condition=[[taskNv_show]],
}

PickView={
	complete_type=0,
	guide_list={
		[1]={
			click_continue=false,
			effect_list={[1]={effect_type=[[click_ui]],near_pos={x=0,y=0,},ui_effect=[[Finger1]],},},
			necessary_ui_list={},
			pass=true,
		},
	},
	necessary_condition=[[pick_show]],
}

Open_ZhaoMu={
	complete_type=0,
	guide_list={
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			effect_list={
				[1]={
					effect_type=[[open]],
					open_text=[[招募]],
					sprite_name=[[pic_zhaomu_tubiao_2]],
					ui_key=[[mainmenu_drawcard_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_drawcard_btn]],},
			stop_walk=true,
		},
		[2]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=true,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[spine]],
					guide_voice_list_1=[[guide_mxm_001_0]],
					guide_voice_list_2=[[0]],
					side_list={[1]=[[0]],},
					spine_left_motion=[[dazhaohu]],
					spine_left_shape=[[1752]],
					spine_right_motion=[[idle]],
					spine_right_shape=[[ ]],
					text_list={[1]=[[可以通过多种途径#R直接兑换#n想要的伙伴。]],},
				},
			},
			necessary_ui_list={},
			stop_walk=true,
		},
		[3]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					near_pos={x=0,y=0,},
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_drawcard_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_drawcard_btn]],},
			need_guide_view=true,
		},
	},
	necessary_condition=[[luckdraw_open]],
}

DrawCardLineUp_MainMenu={
	complete_type=1,
	guide_list={
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=true,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[spine]],
					guide_voice_list_1=[[guide_mxm_003_1]],
					guide_voice_list_2=[[0]],
					side_list={[1]=[[0]],},
					spine_left_motion=[[jushou]],
					spine_left_shape=[[1752]],
					spine_right_motion=[[idle]],
					spine_right_shape=[[ ]],
					text_list={[1]=[[马面面摩拳擦掌要#R上阵#n啦喵~]],},
				},
			},
			necessary_ui_list={},
			stop_walk=true,
		},
		[2]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					near_pos={x=0,y=0,},
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_partner_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_partner_btn]],},
			need_guide_view=true,
		},
	},
	necessary_condition=[[DrawCardLineUp_MainMenu_open]],
}

DrawCardLineUp_Two_MainMenu={
	complete_type=1,
	guide_list={
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=true,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[spine]],
					guide_voice_list_1=[[guide_mxm_003_1]],
					guide_voice_list_2=[[0]],
					side_list={[1]=[[0]],},
					spine_left_motion=[[dazhaohu]],
					spine_left_shape=[[1752]],
					spine_right_motion=[[idle]],
					spine_right_shape=[[ ]],
					text_list={[1]=[[让蛇姬小迷妹也#R上阵#n吧喵~~]],},
				},
			},
			necessary_ui_list={},
			stop_walk=true,
		},
		[2]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					near_pos={x=0,y=0,},
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_partner_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_partner_btn]],},
			need_guide_view=true,
		},
	},
	necessary_condition=[[DrawCardLineUp_Two_MainMenu_open]],
}

Open_ZhaoMu_Two={
	complete_type=1,
	guide_list={
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=true,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[spine]],
					guide_voice_list_1=[[guide_mxm_002_3]],
					guide_voice_list_2=[[0]],
					side_list={[1]=[[0]],},
					spine_left_motion=[[chashou]],
					spine_left_shape=[[1752]],
					spine_right_motion=[[idle]],
					spine_right_shape=[[ ]],
					text_list={[1]=[[可以#R招募#n蛇姬了。]],},
				},
			},
			necessary_ui_list={},
			stop_walk=true,
		},
		[2]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			after_process={args={},func_name=[[Open_ZhaoMu_Two_step_one_before]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					near_pos={x=0,y=0,},
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_drawcard_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_drawcard_btn]],},
			need_guide_view=true,
		},
	},
	necessary_condition=[[luckdraw_open_two]],
}

Open_ZhaoMu_Three={
	complete_type=1,
	guide_list={
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=true,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[spine]],
					guide_voice_list_1=[[house_mxm_002_1]],
					guide_voice_list_2=[[0]],
					side_list={[1]=[[0]],},
					spine_left_motion=[[jushou]],
					spine_left_shape=[[1752]],
					spine_right_motion=[[idle]],
					spine_right_shape=[[ ]],
					text_list={[1]=[[可以#R招募#n阿坊了。]],},
				},
			},
			necessary_ui_list={},
			stop_walk=true,
		},
		[2]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			after_process={args={},func_name=[[Open_ZhaoMu_Two_step_one_before]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					near_pos={x=0,y=0,},
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_drawcard_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_drawcard_btn]],},
			need_guide_view=true,
		},
	},
	necessary_condition=[[luckdraw_open_three]],
}


Open_Org={
	complete_type=0,
	guide_list={
		[1]={
			after_process={args={},func_name=[[org_open_step_one_after]],},	
			effect_list={
				[1]={
					effect_type=[[open]],
					open_text=[[公会]],
					sprite_name=[[pic_gonghui_tubiao_2]],
					ui_key=[[operate_org_btn]],
				},
			},
			necessary_ui_list={[1]=[[operate_org_btn]],},
		},
	},
	necessary_condition=[[org_open]],
}

Open_Welfare={
	complete_type=0,
	guide_list={
		[1]={
			effect_list={
				[1]={
					effect_type=[[open]],
					open_text=[[福利]],
					sprite_name=[[guild]],
					ui_key=[[operate_welfare_btn]],
				},
			},
			necessary_ui_list={[1]=[[operate_welfare_btn]],},
		},
	},
	necessary_condition=[[welfare_open]],
}

Open_Pata={
	complete_type=0,
	guide_list={
		[1]={
			stop_walk=true,			
			leave_team="pata",
			effect_list={
				[1]={
					effect_type=[[open]],
					open_text=[[地牢]],
					sprite_name=[[btn_dlrk2017]],
					ui_key=[[mainmenu_operate_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_operate_btn]],},
		},
	},
	necessary_condition=[[pata_open]],
}

Open_Skill_Two={
	complete_type=1,
	guide_list={
		[1]={
			stop_walk=true,
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			leave_team="pata",
			click_continue=true,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[spine]],
					spine_left_motion=[[dazhaohu]],
					spine_left_shape=[[1752]],
					spine_right_motion=[[idle]],
					spine_right_shape=[[ ]],
					guide_voice_list_1=[[guide_mxm_001_0]],
					guide_voice_list_2=[[0]],
					side_list={[1]=[[0]],[2]=[[0]],},
					text_list={[1]=[[#R学习#n更多的#R技能#n可以#R提升#n你的个人实力。]],},
				},
			},
			necessary_ui_list={[1]=[[mainmenu_operate_btn]],},
		},
		[2]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			after_process={args={},func_name=[[stop_open_mainmenu_operate]],},
			before_process={args={},func_name=[[delay_open_mainmenu_operate]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					near_pos={x=-0.0044,y=0.006,},
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_operate_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_operate_btn]],},
			need_guide_view=true,
		},
		[3]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					near_pos={x=0,y=0,},
					ui_effect=[[Finger]],
					ui_key=[[operate_skill_btn]],
				},
			},
			necessary_ui_list={[1]=[[operate_skill_btn]],},
			need_guide_view=true,
			start_condition=[[operate_view_show]],
		},
	},
	necessary_condition=[[skill_two_open]],
}

Open_Skill_Three={
	complete_type=1,
	guide_list={
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=true,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[spine]],
					guide_voice_list_1=[[guide_mxm_003_1]],
					guide_voice_list_2=[[0]],
					side_list={[1]=[[0]],[2]=[[0]],},
					spine_left_motion=[[jushou]],
					spine_left_shape=[[1752]],
					spine_right_motion=[[idle]],
					spine_right_shape=[[ ]],
					text_list={[1]=[[学习更多的#R技能#n可以#R提升#n你的个人实力。]],},
				},
			},
			leave_team=[[pata]],
			necessary_ui_list={},
			stop_walk=true,
		},
		[2]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			after_process={args={},func_name=[[stop_open_mainmenu_operate]],},
			before_process={args={},func_name=[[delay_open_mainmenu_operate]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					near_pos={x=-0.0044,y=0.006,},
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_operate_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_operate_btn]],},
			need_guide_view=true,
		},
		[3]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					near_pos={x=0,y=0,},
					ui_effect=[[Finger]],
					ui_key=[[operate_skill_btn]],
				},
			},
			necessary_ui_list={[1]=[[operate_skill_btn]],},
			need_guide_view=true,
			start_condition=[[operate_view_show]],
		},
	},
	necessary_condition=[[skill_three_open]],
}

Open_Skill_Four={
	complete_type=1,
	guide_list={
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=true,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[spine]],
					guide_voice_list_1=[[guide_mxm_002_0]],
					guide_voice_list_2=[[0]],
					side_list={[1]=[[0]],[2]=[[0]],},
					spine_left_motion=[[chashou]],
					spine_left_shape=[[1752]],
					spine_right_motion=[[idle]],
					spine_right_shape=[[ ]],
					text_list={[1]=[[有#R新技能#n可以学习了。]],},
				},
			},
			leave_team=[[pata]],
			necessary_ui_list={},
			stop_walk=true,
		},
		[2]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			after_process={args={},func_name=[[stop_open_mainmenu_operate]],},
			before_process={args={},func_name=[[delay_open_mainmenu_operate]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					near_pos={x=-0.0044,y=0.006,},
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_operate_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_operate_btn]],},
			need_guide_view=true,
		},
		[3]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					near_pos={x=0,y=0,},
					ui_effect=[[Finger]],
					ui_key=[[operate_skill_btn]],
				},
			},
			necessary_ui_list={[1]=[[operate_skill_btn]],},
			need_guide_view=true,
			start_condition=[[operate_view_show]],
		},
	},
	necessary_condition=[[skill_four_open]],
}

Open_Travel={
	complete_type=0,
	guide_list={
		[1]={
			effect_list={
				[1]={
					effect_type=[[open]],
					open_text=[[游历]],
					sprite_name=[[pic_youli]],
					ui_key=[[mainmenu_operate_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_operate_btn]],},
		},
	},
	necessary_condition=[[travel_open]],
}

Open_YJFuben={
	complete_type=0,
	guide_list={
		[1]={
			effect_list={
				[1]={
					effect_type=[[open]],
					open_text=[[梦魇狩猎]],
					sprite_name=[[pic_mengyan_diyu]],
					ui_key=[[mainmenu_schedule_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_schedule_btn]],},
		},
	},
	necessary_condition=[[yjfuben_open]],
}

Open_FieldBoss={
	complete_type=0,
	guide_list={
		[1]={
			effect_list={
				[1]={
					effect_type=[[open]],
					open_text=[[人形讨伐]],
					sprite_name=[[btn_renxingtaofa2017]],
					ui_key=[[mainmenu_schedule_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_schedule_btn]],},
		},
	},
	necessary_condition=[[field_boss_open]],
}

Open_Arena={
	complete_type=0,
	guide_list={
		[1]={
			after_process={args={},func_name=[[Open_Arena_step_one_after]],},
			effect_list={
				[1]={
					effect_type=[[open]],
					open_text=[[竞技]],
					sprite_name=[[btn_bwcrk2017]],
					ui_key=[[mainmenu_operate_btn]],
				},
			},
			leave_team=[[arena]],
			necessary_ui_list={[1]=[[mainmenu_operate_btn]],},
			stop_walk=true,
		},
	},
	necessary_condition=[[arena_open]],
}

Open_EqualArena={
	complete_type=0,
	guide_list={
		[1]={
			effect_list={
				[1]={
					effect_type=[[open]],
					open_text=[[公平比武]],
					sprite_name=[[btn_bwcrk2017]],
					ui_key=[[mainmenu_operate_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_operate_btn]],},
		},
	},
	necessary_condition=[[equal_arena_open]],
}

Open_Pvp={
	complete_type=3,
	guide_list={
		[1]={
			leave_team=[[pvp]],
			before_process={args={},func_name=[[Open_Pvp_step_one_before]],},
			click_continue=false,
			effect_list={[1]={effect_type=[[none]],},},
			necessary_ui_list={},
		},
	},
	necessary_condition=[[pvp_open]],
}

Open_Shimen={
	complete_type=0,
	guide_list={
		[1]={
			effect_list={
				[1]={
					effect_type=[[open]],
					open_text=[[杂务巡查]],
					sprite_name=[[pic_jiaoxue]],
					ui_key=[[mainmenu_schedule_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_schedule_btn]],},
		},
		[2]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			before_process={args={},func_name=[[Open_Shimen_step_one_before]],},
			click_continue=true,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[spine]],
					guide_voice_list_1=[[guide_mxm_001_0]],
					guide_voice_list_2=[[0]],
					side_list={[1]=[[0]],},
					spine_left_motion=[[jushou]],
					spine_left_shape=[[1752]],
					spine_right_motion=[[idle]],
					text_list={
						[1]=[[杂务巡查可以获得#R大量主角经验#n和#R伙伴经验#n，记得每天来跑腿喵~]],
					},
				},
			},
			leave_team=[[shimen]],
			necessary_ui_list={},
			need_guide_view=true,
		},
		[3]={
			after_process={args={},func_name=[[Open_Shimen_step_one_before]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					near_pos={x=0,y=0,},
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_shimen_accept_task_nv_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_shimen_accept_task_nv_btn]],},
		},
	},
	necessary_condition=[[shimen_open]],
}

Open_Yuling={
	complete_type=0,
	guide_list={
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=true,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[spine]],
					guide_voice_list_1=[[guide_mxm_003_3]],
					guide_voice_list_2=[[0]],
					side_list={[1]=[[0]],},
					spine_left_motion=[[jushou]],
					spine_left_shape=[[1752]],
					spine_right_motion=[[idle]],
					spine_right_shape=[[ ]],
					text_list={
						[1]=[[#R御灵#n的力量凭依到伙伴身上，
可以#R大幅度提升伙伴能力#n~]],
					},
				},
			},
			necessary_ui_list={},
			stop_walk=true,
		},
		[2]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					near_pos={x=0,y=0,},
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_partner_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_partner_btn]],},
			need_guide_view=true,
		},
	},
	necessary_condition=[[Open_Yuling]],
}
Dialogue_Shimen={
	complete_type=0,
	guide_list={
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=true,
			continue_condition=[[Dialogue_Shimen_step_one_continue]],
			effect_list={[1]={effect_type=[[none]],},},
			necessary_ui_list={},
		},
		[2]={
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					near_pos={x=0,y=0,},
					ui_effect=[[Finger]],
					ui_key=[[dialogue_right_btn_1]],
				},
			},
			necessary_ui_list={[1]=[[dialogue_right_btn_1]],},
		},				
	},
	necessary_condition=[[Dialogue_Shimen_open]],
}

Open_Equipfuben={
	complete_type=0,
	guide_list={
		[1]={
			after_process={args={},func_name=[[equipfuben_open_step_one_after]],},
			effect_list={
				[1]={
					effect_type=[[open]],
					open_text=[[装备副本]],
					sprite_name=[[pic_maigu]],
					ui_key=[[mainmenu_schedule_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_schedule_btn]],},
			stop_walk=true,
		},
	},
	necessary_condition=[[equipfuben_open]],
}

OpenChapterFuBenMainView={
	complete_type=0,
	guide_list={
		[1]={
			before_process={args={},func_name=[[OpenChapterFuBenMainView_step_one_before]],},
			continue_condition=[[OpenChapterFuBenMainView_step_one_continue]],
			after_mask={args={[1]=5,},func_name=[[after_mask_process]],},
			effect_list={
				[1]={effect_type=[[focus_ui]],aplha = 1, h=0.05,ui_key=[[mainmenu_nv_task_10003_btn]],w=0.05,},
			},
			necessary_ui_list={[1]=[[mainmenu_nv_task_10003_btn]],},
			stop_walk=true,
		},
	},
	necessary_condition=[[OpenChapterFuBenMainView_open]],
}

OpenChapterDialogueView={
	complete_type=0,
	guide_list={
		[1]={
			effect_list={
				[1]={
					aplha=1,
					effect_type=[[click_ui]],
					near_pos={x=0,y=0,},
					ui_effect=[[Finger]],
					ui_key=[[dialogue_right_10003_btn_1]],
				},
			},
			necessary_ui_list={[1]=[[dialogue_right_10003_btn_1]],},
			stop_walk=true,
		},
	},
	necessary_condition=[[OpenChapterDialogueView_open]],
}

Open_Trapmine={
	complete_type=0,
	guide_list={
		[1]={
			stop_walk=true,
			effect_list={
				[1]={
					effect_type=[[open]],
					open_text=[[探索]],
					sprite_name=[[pic_tansuo_1]],
					ui_key=[[mainmenu_operate_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_operate_btn]],},
		},
	},
	necessary_condition=[[trapmine_open]],
}

Open_Schedule={
	complete_type=0,
	guide_list={
		[1]={
			after_process={args={},func_name=[[Open_Schedule_step_one_after]],},
			stop_walk=true,
			effect_list={
				[1]={
					effect_type=[[open]],
					open_text=[[活动]],
					sprite_name=[[pic_richang_tubiao]],
					ui_key=[[mainmenu_schedule_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_schedule_btn]],},
		},
		[2]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					near_pos={x=0,y=0,},
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_schedule_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_schedule_btn]],},
		},			
	},
	necessary_condition=[[schedule_open]],
}

Open_MingLei={
	complete_type=0,
	guide_list={
		[1]={
			effect_list={
				[1]={
					effect_type=[[open]],
					open_text=[[喵萌茶会]],
					sprite_name=[[pic_mibaolieren]],
					ui_key=[[mainmenu_schedule_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_schedule_btn]],},
			stop_walk=true,
		},
	},
	necessary_condition=[[minglei_open]],
}

Forge_Gem_Open={
	complete_type=1,
	guide_list={
		[1]={
			leave_team=[[forge_gem]],
			before_process={args={},func_name=[[Forge_Gem_Open_step_one_before]],},
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					near_pos={x=0,y=0,},
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_forge_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_forge_btn]],},
		},
	},
	necessary_condition=[[forge_gem_open]],
}

Forge_Strength_Open={
	complete_type=0,
	guide_list={
		[1]={
			leave_team=[[forge_strength]],
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=true,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[spine]],
					spine_left_motion=[[dazhaohu]],
					spine_left_shape=[[1752]],
					spine_right_motion=[[daiji]],
					spine_right_shape=[[ ]],
					guide_voice_list_1=[[guide_mxm_001_0]],
					guide_voice_list_2=[[guide_mxm_001_0]],
					side_list={[1]=[[0]],},
					text_list={
						[1]=[[装备副本掉落的#R星梦矿#n可以提升装备的突破等级，#R更换#n装备#R不影响#n突破等级]],					
					},
				},
			},
			necessary_ui_list={},
		},	
		[2]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					near_pos={x=0,y=0,},
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_forge_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_forge_btn]],},
		},
	},
	necessary_condition=[[forge_strength_open]],
}

Open_Convoy={
	complete_type=0,
	guide_list={
		[1]={
			after_process={args={},func_name=[[open_pefuben_step_one_after]],},
			effect_list={
				[1]={
					effect_type=[[open]],
					open_text=[[帝都宅急便]],
					sprite_name=[[pic_husong]],
					ui_key=[[mainmenu_schedule_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_schedule_btn]],},
			stop_walk=true,
		},
	},
	necessary_condition=[[convoy_open]],
}

Open_Pefuben={
	complete_type=0,
	guide_list={
		[1]={
			after_process={args={},func_name=[[open_pefuben_step_one_after]],},
			effect_list={
				[1]={
					effect_type=[[open]],
					open_text=[[御灵副本]],
					sprite_name=[[pic_yikongliufang]],
					ui_key=[[mainmenu_schedule_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_schedule_btn]],},
			stop_walk=true,
		},
	},
	necessary_condition=[[yikong_open]],
}

Open_Lilian={
	complete_type=0,
	guide_list={
		[1]={			
			effect_list={
				[1]={
					effect_type=[[open]],
					open_text=[[每日修行]],
					sprite_name=[[pic_meirixiuxing]],
					ui_key=[[mainmenu_operate_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_operate_btn]],},
			stop_walk=true,
		},	
		[2]={
			click_continue=true,
			after_process={args={},func_name=[[Open_Lilian_step_two_before]],},			
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[spine]],
					spine_left_motion=[[dazhaohu]],
					spine_left_shape=[[1752]],
					spine_right_motion=[[daiji]],
					spine_right_shape=[[ ]],
					guide_voice_list_1=[[guide_mxm_001_0]],
					guide_voice_list_2=[[guide_mxm_001_0]],
					side_list={[1]=[[0]],},
					text_list={
						[1]=[[每日修行可获得#R大量经验和金币#n，快加入修行大军，组队开车了喵！]],					
					},
				},			
			},
			necessary_ui_list={},
		},		
	},
	necessary_condition=[[lilian_open]],
}

Open_House={
	complete_type=1,
	guide_list={
		[1]={					
			stop_walk=true,
			before_process={args={},func_name=[[open_house_step_one_before]],},
			after_process={args={},func_name=[[open_house_step_one_after]],},			
			effect_list={
				[1]={
					effect_type=[[open]],
					open_text=[[宅邸]],
					sprite_name=[[pic_zhaidi_tubiao_2]],
					ui_key=[[mainmenu_house_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_house_btn]],},
		},
	},
	necessary_condition=[[house_open]],
}

Open_Achieve={
	complete_type=0,
	guide_list={
		[1]={
			effect_list={
				[1]={
					effect_type=[[open]],
					open_text=[[成就]],
					sprite_name=[[pic_huodong]],
					ui_key=[[mainmenu_operate_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_operate_btn]],},
		},
	},
	necessary_condition=[[achieve_open]],
}

Open_MapBook={
	complete_type=1,
	guide_list={
		[1]={
			stop_walk=true,
			effect_list={
				[1]={
					effect_type=[[open]],
					open_text=[[图鉴]],
					sprite_name=[[tujian]],
					ui_key=[[mainmenu_operate_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_operate_btn]],},
		},
	},
	necessary_condition=[[map_book_open]],
}

Open_Forge={
	complete_type=1,
	guide_list={
		[1]={
			effect_list={
				[1]={
					effect_type=[[open]],
					open_text=[[装备]],
					sprite_name=[[pic_zhuangbei_tubiao_2]],
					ui_key=[[mainmenu_forge_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_forge_btn]],},
			stop_walk=true,
		},
	},
	necessary_condition=[[forge_open]],
}

Open_Forge_composite={
	complete_type=1,
	guide_list={
		[1]={
			effect_list={
				[1]={
					effect_type=[[open]],
					open_text=[[装备打造]],
					sprite_name=[[pic_zhuangbei_tubiao]],
					ui_key=[[mainmenu_forge_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_forge_btn]],},
			stop_walk=true,
		},
	},
	necessary_condition=[[Open_Forge_composite_open]],
}

Open_YJHJ={
	complete_type=1,
	guide_list={
		[1]={
			effect_list={
				[1]={
					effect_type=[[open]],
					open_text=[[月见幻境]],
					sprite_name=[[pic_richang_tubiao]],
					ui_key=[[mainmenu_schedule_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_schedule_btn]],},
		},
	},
	necessary_condition=[[Open_YJHJ_open]],
}


HouseView={
	complete_type=0,
	guide_list={
		[1]={
			after_process={args={},func_name=[[HouseView_step_one_after]],},
			before_process={args={},func_name=[[HouseView_step_one_before]],},
			click_continue=true,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[spine]],
					guide_voice_list_1=[[guide_mxm_001_4]],
					guide_voice_list_2=[[0]],
					side_list={[1]=[[0]],},
					spine_left_motion=[[dazhaohu]],
					spine_left_shape=[[1752]],
					spine_right_motion=[[idle]],
					spine_right_shape=[[ ]],
					text_list={
						[1]=[[ 欢迎回家。
 #R宅邸#n的小伙伴都很挂念你，快去安抚安抚，不然该炸毛了。]],
					},
				},
			},
			necessary_ui_list={},
			need_guide_view=true,
			pass=true,
		},
		[2]={
			before_process={args={},func_name=[[HouseView_step_two_before]],},
			click_continue=false,
			continue_condition=[[HouseView_step_two_continue]],
			effect_list={
				[1]={
					aplha=1,
					dlg_is_left=true,
					effect_type=[[textdlg]],
					fixed_pos={x=-0.115,y=0.13,},
					near_pos={x=0,y=0,},
					play_tween=false,
					text_list={[1]=[[欢迎回家。]],},
				},
				[2]={effect_type=[[hide_click_event]],},
			},
			necessary_ui_list={},
			need_guide_view=true,
			start_condition=[[HouseView_step_two_start_condition]],
		},
		[3]={
			after_process={args={},func_name=[[HouseView_step_three_after]],},
			before_process={args={},func_name=[[HouseView_step_three_before]],},
			click_continue=true,
			effect_list={
				[1]={
					aplha=1,
					dlg_is_left=true,
					effect_type=[[textdlg]],
					fixed_pos={x=-0.115,y=0.13,},
					near_pos={x=0,y=0,},
					play_tween=false,
					text_list={[1]=[[我有点饿了。
					可以帮我去#R厨房#n看看吗？]],},
				},
			},
			necessary_ui_list={},
			need_guide_view=true,
		},
		[4]={
			before_process={args={},func_name=[[HouseView_step_four_before]],},
			continue_condition=[[HouseView_step_four_continue]],
			effect_list={[1]={effect_type=[[none]],},},
			necessary_ui_list={},
			need_guide_view=true,
			start_condition=[[HouseView_step_four_start_condition]],
		},
		[5]={
			after_process={args={},func_name=[[HouseView_step_five_after]],},
			before_process={args={},func_name=[[HouseView_step_five_before]],},
			continue_condition=[[HouseView_step_five_continue]],
			effect_list={[1]={effect_type=[[none]],},[2]={effect_type=[[hide_click_event]],},},
			necessary_ui_list={},
			need_guide_view=true,
		},
	},
	necessary_condition=[[house_view_show]],
}

HouseTwoView={
	complete_type=0,
	guide_list={
		[1]={
			after_process={args={},func_name=[[HouseTwoView_step_one_after]],},
			before_process={args={},func_name=[[HouseTwoView_step_one_before]],},
			click_continue=false,
			effect_list={[1]={effect_type=[[none]],},[2]={effect_type=[[hide_click_event]],},},
			necessary_ui_list={},
			need_guide_view=true,
		},
		[2]={
			click_continue=true,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[spine]],
					guide_voice_list_1=[[guide_mxm_003_2]],
					guide_voice_list_2=[[0]],
					side_list={[1]=[[0]],},
					spine_left_motion=[[dazhaohu]],
					spine_left_shape=[[1752]],
					spine_right_motion=[[idle]],
					spine_right_shape=[[ ]],
					text_list={
						[1]=[[提高宅邸伙伴们的#R总亲密度#n，
可以激活永久的#R伙伴属性#n。]],
					},
				},
				[2]={effect_type=[[focus_ui]],h=0.1,ui_key=[[house_main_buff_sprite]],w=0.2,},
			},
			necessary_ui_list={[1]=[[house_main_buff_sprite]],},
			need_guide_view=true,
		},
	},
	necessary_condition=[[HouseTwoView_show]],
}

HouseTeaartView={
	complete_type=0,
	guide_list={
		[1]={
			click_continue=true,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[spine]],
					guide_voice_list_1=[[guide_mxm_002_0]],
					guide_voice_list_2=[[0]],
					side_list={[1]=[[1]],},
					spine_left_motion=[[idle]],
					spine_left_shape=[[ ]],
					spine_right_motion=[[chashou]],
					spine_right_shape=[[1752]],
					text_list={
						[1]=[[这里可以#R制作料理#n.
						#R料理#n作为#R礼物#n送给宅邸伙伴，能增加和她的#R亲密度#n.]],
					},
				},
			},
			necessary_ui_list={},
			need_guide_view=true,
		},
		[2]={
			after_process={args={},func_name=[[HouseTeaartView_step_one_after]],},
			before_process={args={},func_name=[[HouseTeaartView_step_one_before]],},
			click_continue=false,
			effect_list={[1]={effect_type=[[none]],},[2]={effect_type=[[hide_click_event]],},},
			necessary_ui_list={},
			need_guide_view=true,
		},
		[3]={
			click_continue=true,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[spine]],
					guide_voice_list_1=[[house_mxm_002_1]],
					guide_voice_list_2=[[0]],
					side_list={[1]=[[1]],},
					spine_left_motion=[[idle]],
					spine_left_shape=[[ ]],
					spine_right_motion=[[jushou]],
					spine_right_shape=[[1752]],
					text_list={
						[1]=[[时间到了再来领取#R料理#n和#R金币#n。
 ~\(≧▽≦)/~啦啦啦]],
					},
				},
			},
			end_pass_guide=true,
			necessary_ui_list={},
			need_guide_view=true,
		},
	},
	necessary_condition=[[HouseTeaartView_show]],
}

HouseExchangeView={
	complete_type=0,
	guide_list={
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=false,
			continue_condition=[[house_exchange_view_show]],
			effect_list={[1]={effect_type=[[none]],},},
			necessary_ui_list={},
		},
		[2]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=1,
					dlg_is_left=true,
					effect_type=[[textdlg]],
					fixed_pos={x=-0.115,y=0.13,},
					near_pos={x=0,y=0,},
					play_tween=false,
					text_list={
						[1]=[[欢迎回家。⁄(⁄ ⁄•⁄ω⁄•⁄ ⁄)⁄
好怕你把我忘记了。 ]],
					},
				},
				[2]={
					effect_type=[[click_ui]],
					near_pos={x=0,y=0,},
					ui_effect=[[Finger]],
					ui_key=[[house_touch_btn]],
				},
			},
			necessary_ui_list={[1]=[[house_touch_btn]],},
		},
		[3]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=true,
			effect_list={
				[1]={
					aplha=1,
					dlg_is_left=true,
					effect_type=[[textdlg]],
					fixed_pos={x=-0.227,y=0.13,},
					near_pos={x=0,y=0,},
					play_tween=true,
					text_list={
						[1]=[[虽然很不好意思，但重华饿了。
可以去#R料理台#n做一点食物给我吗？]],
					},
				},
			},
			necessary_ui_list={},
		},
		[4]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[click_ui]],					
					offset_pos={x=52,y=41},
					ui_effect=[[Finger]],
					ui_key=[[house_back_btn]],
				},
			},
			necessary_ui_list={[1]=[[house_back_btn]],},
		},
	},
	necessary_condition=[[house_exchange_view_show]],
}

ChapterFuBenMainView={
	complete_type=0,
	guide_list={
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			start_condition=[[ChapterFuBenMainView_one_start_condition]],
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=80,},
					ui_effect=[[Finger]],
					ui_key=[[chapter_fuben_btn_1]],
				},
			},
			necessary_ui_list={[1]=[[chapter_fuben_btn_1]]},
			need_guide_view=true,
		},
		[2]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[click_ui]],
					near_pos={x=0,y=0,},
					ui_effect=[[Finger]],
					ui_key=[[chapter_fuben_fight_btn]],
				},
			},
			start_condition=[[chapter_fuben_main_view_level_part_show]],
			necessary_ui_list={[1]=[[chapter_fuben_fight_btn]]},
			need_guide_view=true,
		},		
	},
	necessary_condition=[[chapter_fuben_main_view_show]],
}

ClubArenaView={
	complete_type=0,
	guide_list={
		[1]={			
			click_continue=true,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[spine]],
					spine_left_motion=[[chashou]],
					spine_left_shape=[[1752]],
					spine_right_motion=[[idle]],
					spine_right_shape=[[ ]],
					guide_voice_list_1=[[guide_mxm_002_0]],
					guide_voice_list_2=[[0]],
					side_list={[1]=[[0]],},
					text_list={[1]=[[欢迎来到武馆喵，新人馆的菜鸟~]],},
				},
			},
			necessary_ui_list={},
			need_guide_view=true,
		},
		[2]={
			before_process={args={},func_name=[[ClubArenaView_step_two_before]],},
			after_process={args={},func_name=[[ClubArenaView_step_two_after]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=1,
					effect_type=[[spine]],
					spine_left_motion=[[chashou]],
					spine_left_shape=[[1752]],
					spine_right_motion=[[idle]],
					spine_right_shape=[[ ]],
					guide_voice_list_1=[[guide_mxm_002_0]],
					guide_voice_list_2=[[0]],
					side_list={[1]=[[0]],},
					text_list={[1]=[[挑战#R更高级别#n的武馆，拿#R更多奖励#n]],},
				},		
				[2]={effect_type=[[hide_click_event]]},		
			},
			force_hide_continue_label=true,
			necessary_ui_list={[1]=[[clubarnea_club_2_btn]]},
			need_guide_view=true,
		},		
	},
	necessary_condition=[[ClubArenaView_show]],
}


HuoyueduGuide={
	complete_type=1,
	guide_list={
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			after_process={args={},func_name=[[huo_yue_du_guide_step_one_after]],},
			click_continue=true,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[spine]],
					spine_left_motion=[[chashou]],
					spine_left_shape=[[1752]],
					spine_right_motion=[[idle]],
					spine_right_shape=[[ ]],
					guide_voice_list_1=[[guide_mxm_002_0]],
					guide_voice_list_2=[[0]],
					side_list={[1]=[[0]],},
					text_list={[1]=[[#R活跃度奖励#n是#R人物经验#n的重要产出途径。]],},
				},
			},
			necessary_ui_list={},
		},
		[2]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					near_pos={x=0,y=0,},
					ui_effect=[[round]],
					ui_key=[[mainmenu_schedule_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_schedule_btn]],},
		},
	},
	necessary_condition=[[cumstom_huo_yue_du_guide]],
}

ScheduleView={
	complete_type=1,
	guide_list={
		[1]={
			after_mask={args={[1]=3,},func_name=[[after_mask_process]],},
			click_continue=false,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[click_ui]],
					near_pos={x=0,y=0,},
					ui_effect=[[Finger]],
					ui_key=[[schedule_award_box_1_btn]],
				},
			},
			necessary_ui_list={[1]=[[schedule_award_box_1_btn]],},
		},
		[2]={
			click_continue=true,
			effect_list={
				[1]={
					aplha=1,
					effect_type=[[spine]],
					spine_left_motion=[[idle]],
					spine_left_shape=[[ ]],
					spine_right_motion=[[jushou]],
					spine_right_shape=[[1752]],
					guide_voice_list_1=[[guide_mxm_003_2]],
					guide_voice_list_2=[[0]],
					side_list={[1]=[[1]],},
					text_list={
						[1]=[[除了丰厚的#R经验#n和宝物，
#R积攒活跃度#n还可以到活跃度商店#R兑换礼物#n~喵]],
					},
				},
			},
			necessary_ui_list={},
		},
	},
	necessary_condition=[[schedule_view_show]],
}

Get_Two_WZQY={
	complete_type=0,
	guide_list={
		[1]={
			after_process={args={},func_name=[[get_two_wzqy_step_one_before]],},
			click_continue=true,
			effect_list={
				[1]={
					aplha=100,
					effect_type=[[spine]],
					spine_left_motion=[[jushou]],
					spine_left_shape=[[1752]],
					spine_right_motion=[[idle]],
					spine_right_shape=[[ ]],
					guide_voice_list_1=[[guide_mxm_003_2]],
					guide_voice_list_2=[[0]],
					side_list={[1]=[[0]],},
					text_list={
						[1]=[[送你一张#R王者契约#n，再#R招募#n个伙伴教小混混做人吧]],
					},
				},
			},
			necessary_ui_list={},
			pass=true,
		},
	},
	necessary_condition=[[get_two_wzqy_open]],
}

Tips_Org={
	guide_list={
		[1]={
			ui_effect=[[circle]],	
			necessary_ui=[[operate_org_btn]],			
		},		
	}
}

--王者契约
Tips_WZQY={
	guide_list={
		[1]={
			ui_effect=[[Finger]],
			necessary_ui=[[mainmenu_drawcard_btn]],		
		},	
		[2]={
			ui_effect=[[Finger]],	
			necessary_ui=[[draw_wh_card]],			
		},			
	}
}

Tips_LoginSevenDay={
	guide_list={
		[1]={
			ui_effect=[[circle]],
			necessary_ui=[[mainmenu_loginreward_btn]],		
		},		
	}
}

Tips_PartnerChip_Compose={
	guide_list={
		[1]={
			ui_effect=[[circle]],
			necessary_ui=[[mainmenu_partner_btn]],	
		},	
		[2]={
			ui_effect=[[circle]],
			necessary_ui=[[partner_chip_compose_show_btn]],		
			open_id=9999,
		},	
		[3]={
			ui_effect=[[circle]],
			necessary_ui=[[partner_chip_compose_tips_btn]],		
		},	
	}
}

Tips_EquipFuben={
	open_priority=data.globalcontroldata.GLOBAL_CONTROL.equipfuben.open_grade,
	guide_list={
		[1]={
			ui_effect=[[]],
			necessary_ui=[[mainmenu_schedule_btn]],			
		},
		[2]={
			ui_effect=[[]],	
			necessary_ui=[[schedule_allday_go_btn]],
			open_id=1003,
		},			
	}
}

Tips_PEFuben={
	open_priority=data.globalcontroldata.GLOBAL_CONTROL.pefuben.open_grade,
	guide_list={
		[1]={
			ui_effect=[[]],
			necessary_ui=[[mainmenu_schedule_btn]],				
		},
		[2]={
			ui_effect=[[]],	
			necessary_ui=[[schedule_allday_go_btn]],
			open_id=1005,	
		},			
	}
}

Tips_House={
	open_priority=data.globalcontroldata.GLOBAL_CONTROL.house.open_grade,
	guide_list={
		[1]={
			ui_effect=[[circle]],
			necessary_ui=[[mainmenu_house_btn]],				
		},			
	}
}

Tips_Convoy={
	open_priority=data.globalcontroldata.GLOBAL_CONTROL.convoy.open_grade,
	guide_list={
		[1]={
			ui_effect=[[]],
			necessary_ui=[[mainmenu_schedule_btn]],				
		},
		[2]={
			ui_effect=[[]],	
			necessary_ui=[[schedule_allday_go_btn]],
			open_id=1018,	
		},			
	}
}

Tips_YueJian={
	open_priority=data.globalcontroldata.GLOBAL_CONTROL.endless_pve.open_grade,
	guide_list={
		[1]={
			ui_effect=[[round]],
			necessary_ui=[[mainmenu_schedule_btn]],			
		},
		[2]={
			ui_effect=[[]],	
			necessary_ui=[[schedule_allday_go_btn]],
			open_id=1002,
		},			
	}
}

Tips_MingLei={
	open_priority=data.globalcontroldata.GLOBAL_CONTROL.minglei.open_grade,
	guide_list={
		[1]={
			ui_effect=[[round]],
			necessary_ui=[[mainmenu_schedule_btn]],	
			func_process={args={},func_name=[[tips_ming_lei_step_one_process]],},
			open_id=1006,
			condition_pass=true,			
		},
		[2]={
			ui_effect=[[Finger]],	
			necessary_ui=[[schedule_allday_go_btn]],
			open_id=1006,
			condition_pass=true,
		},			
	}
}

Tips_XiaoMengQingQiu={
	guide_list={
		[1]={
			ui_effect=[[round]],
			necessary_ui=[[mainmenu_xmqq_task_nv_btn]],				
		},		
	}
}

Tips_PowerGuide={
	guide_list={
		[1]={
			ui_effect=[[circle]],
			necessary_ui=[[mainmenu_powerguide_btn]],				
		},		
	}
}

Tips_War_Faild={
	guide_list={
		[1]={
			ui_effect=[[circle]],
			necessary_ui=[[mainmenu_powerguide_btn]],				
		},		
	}
}

Tips_HuoyueduGuide={
	open_priority=999,
	guide_list={
		[1]={
			ui_effect=[[]],
			necessary_ui=[[mainmenu_schedule_btn]],				
		},		
	}
}

Tips_Lilian={
	open_priority=data.globalcontroldata.GLOBAL_CONTROL.dailytrain.open_grade,	
	guide_list={
		[1]={
			ui_effect=[[circle]],
			necessary_ui=[[mainmenu_operate_btn]],				
		},		
		[2]={
			ui_effect=[[circle]],
			necessary_ui=[[operate_lilian_btn]],				
		},		
	}
}

Tips_Skill={
	open_priority=data.globalcontroldata.GLOBAL_CONTROL.switchschool.open_grade,	
	guide_list={
		[1]={
			ui_effect=[[circle]],
			necessary_ui=[[mainmenu_operate_btn]],				
		},	
		[2]={
			ui_effect=[[circle]],
			necessary_ui=[[operate_skill_btn]],				
		},	
	}
}

Tips_ArneaClub={
	open_priority=data.globalcontroldata.GLOBAL_CONTROL.clubarena.open_grade,	
	guide_list={
		[1]={
			ui_effect=[[circle]],
			necessary_ui=[[mainmenu_operate_btn]],				
		},	
		[2]={
			ui_effect=[[circle]],
			necessary_ui=[[operate_arnea_btn]],				
		},	
	}
}

Tips_HBSX={
	open_priority=10,	
	guide_list={
		[1]={
			ui_effect=[[circle]],
			necessary_ui=[[mainmenu_partner_btn]],				
		},	
		[2]={
			ui_effect=[[Finger3]],
			necessary_ui=[[partner_left_list_302_partner]],		
			showFinishForward=true,		
		},	
		[3]={
			ui_effect=[[Finger3]],
			necessary_ui=[[partner_main_breed_302_btn]],				
			showFinishForward=true,
		},	
		[4]={
			ui_effect=[[Finger3]],
			necessary_ui=[[partner_improve_star_tab_302_btn]],				
			showFinishForward=true,			
		},	
		[5]={
			ui_effect=[[Finger3]],
			necessary_ui=[[partner_up_star_confirm_302_btn]],
			showFinishForward=true,				
		},					
	}
}

Tips_JQFB={
	open_priority=5,	
	guide_list={
		[1]={
			ui_effect=[[Finger3]],
			necessary_ui=[[chapter_fuben_btn_2]],	
			condition_pass=true,			
		},	
		[2]={
			ui_effect=[[Finger3]],
			necessary_ui=[[chapter_fuben_fight_btn]],				
			condition_pass=true,
		},					
	}
}


Tips_JQFB_1_3={
	open_priority=5,	
	guide_list={
		[1]={
			ui_effect=[[Finger3]],
			necessary_ui=[[chapter_fuben_btn_3]],	
			condition_pass=true,			
		},	
		[2]={
			ui_effect=[[Finger3]],
			necessary_ui=[[chapter_fuben_fight_btn]],				
			condition_pass=true,
		},					
	}
}

Tips_TeamHandyBuild={
	open_priority=data.globalcontroldata.GLOBAL_CONTROL.minglei.open_grade,	
	guide_list={
		[1]={
			ui_effect=[[round]],
			necessary_ui=[[mainmenu_team_btn]],				
		},	
		[2]={
			ui_effect=[[Finger]],
			necessary_ui=[[teammain_handybuild_btn]],				
		},	
		[3]={
			ui_effect=[[Finger]],
			necessary_ui=[[teamhandybuild_target_btn]],				
		},	
		[4]={
			ui_effect=[[round]],
			necessary_ui=[[teamtarget_minglei_btn]],				
		},					
	}
}

Tips_HuntPartnerSoulView={
	open_priority=data.globalcontroldata.GLOBAL_CONTROL.huntpartnersoul.open_grade,	
	guide_list={
		[1]={
			ui_effect=[[circle]],
			necessary_ui=[[mainmenu_hunt_btn]],				
		},					
	}
}



Tips_Brach_FightNpc={
	open_priority=40,	
	guide_list={
		[1]={
			ui_effect=[[Finger]],
			necessary_ui=[[mainmenu_nv_task_31024_btn]],	
		},	
		[2]={
			ui_effect=[[Finger]],
			necessary_ui=[[mapbook_person_1007_reward_btn]],				
		},	
		[3]={
			ui_effect=[[Finger]],
			necessary_ui=[[mapbook_reward_view_1007_go_btn]],				
		},						
	}
}

Tips_Brach_CHFM={
	open_priority=41,	
	guide_list={
		[1]={
			ui_effect=[[Finger]],
			necessary_ui=[[mainmenu_nv_task_31515_btn]],	
		},	
		[2]={
			ui_effect=[[Finger]],
			necessary_ui=[[house_walker_1001]],				
		},	
		[3]={
			ui_effect=[[Finger]],
			necessary_ui=[[house_touch_btn]],				
		},						
	}
}

Tips_Brach_CHYL={
	open_priority=42,	
	guide_list={
		[1]={
			ui_effect=[[Finger]],
			necessary_ui=[[mainmenu_nv_task_31516_btn]],	
		},	
		[2]={
			ui_effect=[[Finger]],
			necessary_ui=[[house_walker_1001]],				
		},	
		[3]={
			ui_effect=[[Finger]],
			necessary_ui=[[house_train_btn]],				
		},						
		[4]={
			ui_effect=[[Finger]],
			necessary_ui=[[house_train_box_1_btn]],				
		},	
	}
}
 
Tips_HardChapterFb={
	open_priority=30,
	guide_list={
		[1]={
			ui_effect=[[circle]],
			necessary_ui=[[mainmenu_chapterfb_btn]],				
		},		
		[2]={
			ui_effect=[[circle]],
			necessary_ui=[[chaterfb_switch_btn]],				
		},		
	}
}


Tips_Guide_UI_NearPos = {
	operate_drawcard_btn = {x=0, y=0},
	chapter_fuben_btn_1 = {x=0, y=65},
	chapter_fuben_btn_2 = {x=0, y=65},
	chapter_fuben_btn_3 = {x=0, y=65},
	house_back_btn = {x=52, y=41},
	partner_left_list_302_partner = {x=0, y=-72},
}