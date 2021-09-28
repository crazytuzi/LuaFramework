RegistModules("Strong/view/StrongPanel")
RegistModules("Strong/view/ItemStrong")
RegistModules("Strong/StrongConst")
RegistModules("Strong/StrongModel")

StrongCtr = BaseClass(LuaController)

function StrongCtr:GetInstance()
	if StrongCtr.inst == nil then
		StrongCtr.inst = StrongCtr.New()
	end
	return StrongCtr.inst
end

function StrongCtr:__init()
	resMgr:AddUIAB("Strong")
	self.model = StrongModel:GetInstance()
end

function StrongCtr:Open()
	if not self:GetView() then
		self.view = StrongPanel.New()
	end
	--self.view:Open()
	UIMgr.ShowCenterPopup(self.view)
end

function StrongCtr:Close()
	self.model:DispatchEvent(StrongConst.CloseStrong)
	-- if self:GetView() then
	-- 	--self.view:Close()
	-- end
end

function StrongCtr:GetView()
	if self.view and self.view.isInited then
		return self.view
	end
	return nil
end

function StrongCtr:GoLink(i) --类型i 对应不同的 前往寻路或打开界面
	-- 1：秘境  2：限时活动  3：侍魂殿  4：灵石矿洞  5：神印矿洞  
	-- 6：背包分解  7：猎妖任务  8：商店斗神印  9：商店装备  10：大荒塔  11：副本  12:悬赏
	-- 13： 注灵界面  14：技能界面  15：斗神印界面  16：装备界面
	if not i then return end
	if i == 1 then	
	print("jin进入秘境======================")													--
		local pkgModel = PkgModel:GetInstance()
		local id = ShenJingConst.ID_QIANJIEYE
		local data = GetCfgData("item"):Get(id)
		local name = ""
		if data then
			name = data.name
		end
		if pkgModel:IsOnBagByBid(id) then
			data = PkgModel:GetInstance():GetGoodsVoByBid(id)
			local cfg = data:GetCfgData()
			if cfg.useType == 6 then --秘境

				local enterPanel1 = EnterPanel1.New()
				enterPanel1:Update(cfg)
				--UIMgr.ShowCenterPopup(enterPanel1, function()  end)									
				self:Close()
				DelayCall(function ()
					UIMgr.ShowCenterPopup(enterPanel1, function()  end)
					end,0.2)

								
			end
		else
			UIMgr.Win_FloatTip(StringFormat("您缺少进入副本的道具“{0}”", name))
		end
	elseif i == 2 then
		ActivityController:GetInstance():OpenDayActivityPanel()
		self:Close()
	elseif i == 3 then
		TiantiController:GetInstance():Open()
		self:Close()
	elseif i == 4 then --灵石矿洞
		local mainPlayer = SceneController:GetInstance():GetScene():GetMainPlayer()
		if mainPlayer then
			mainPlayer:SetWorldNavigation(2010)
		end
		self:Close()
	elseif i == 5 then --神印矿洞
		local mainPlayer = SceneController:GetInstance():GetScene():GetMainPlayer()
		if mainPlayer then
			mainPlayer:SetWorldNavigation(2011)
		end
		self:Close()
	elseif i == 6 then
		PkgCtrl:GetInstance():OpenByType(PkgConst.PanelType.decomposition)
		self:Close()
	elseif i == 7 then
		local isTask = TaskModel:GetInstance():IsHasHuntingMonsterTask() --是否拥有 猎妖任务
		if isTask then
			UIMgr.Win_FloatTip("请先完成任务列表的猎妖任务")
		else
			local isHadItem = PkgModel:GetInstance():IsOnBagByEffectType(14) --猎妖令 类型14
			if isHadItem then
				self:Close()
				PkgCtrl:GetInstance():Open()
				UIMgr.Win_FloatTip("请使用猎妖令接取任务")
			else
				UIMgr.Win_FloatTip("没有猎妖令")
			end
		end
	elseif i == 8 then --交易行购买斗神印
		TradingController:GetInstance():Open(2, 3, 1)
		self:Close()
	elseif i == 9 then --交易行购买装备
		TradingController:GetInstance():Open(2, 5, 100)
		self:Close()
	elseif i == 10 then
		ShenJingController:GetInstance():OpenShenJingPanel()
		self:Close()
	elseif i == 11 then
		GuideController:GetInstance():GotoFB()
		self:Close()
	elseif i == 12 then
		if TaskModel:GetInstance():IsHasDailyTask() then
			UIMgr.Win_FloatTip("请完成已接取的悬赏任务")
		else
			GuideController:GetInstance():GoToNPC(TaskConst.DailyNPCID)
			self:Close()
		end
	elseif i == 13 then
		SkillController:GetInstance():OpenSkillPanel(1)
		self:Close()
	elseif i == 14 then
		SkillController:GetInstance():OpenSkillPanel()
		GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)
		self:Close()
	elseif i == 15 then
		GodFightRuneController:GetInstance():OpenGodFightRunePanel()
		self:Close()
	elseif i == 16 then
		PlayerInfoController:GetInstance():Open()
		self:Close()
	end
end

function StrongCtr:__delete()
	StrongCtr.inst = nil
	if self.model then
		self.model:Destroy()
	end
	self.model=nil
end