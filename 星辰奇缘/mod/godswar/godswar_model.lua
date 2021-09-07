-- -----------------------------
-- 诸神之战
-- hosr
-- -----------------------------
GodsWarModel = GodsWarModel or BaseClass(BaseModel)

function GodsWarModel:__init()
	self.mainWindow = nil

	self.effectPath = "prefabs/effect/20197.unity3d"
	self.effect = nil
	self.assetWrapper = nil
	self.effectTime = nil

	self.cooldownTime = nil
	self.cooldownUpdateCall = nil
	self.cooldownEndCall = nil
	self.cooldownCount = 0

	self.eventListener = function(event, old_event) self:RoleEventChange(event, old_event) end
	self.mainuiload = function() self:MainUiLoaded() end
	self.beginfight = function() self:OnBeginFight() end
	self.endfight = function(type, result) self:OnEndFight(type, result) end
	EventMgr.Instance:AddListener(event_name.mainui_btn_init, self.mainuiload)
end

function GodsWarModel:__delete()
end

function GodsWarModel:Clear()
	self:CloseMainUiTop()
	self:CloseFightShow()
	self:CloseTopPanel()
end

function GodsWarModel:MainUiLoaded()
	EventMgr.Instance:RemoveListener(event_name.mainui_btn_init, self.mainuiload)
	self:RoleEventChange(RoleManager.Instance.RoleData.event)
	EventMgr.Instance:AddListener(event_name.role_event_change, self.eventListener)
end

function GodsWarModel:RoleEventChange(event, old_event)
	if event == RoleEumn.Event.GodsWar then
		self:OpenMainUiTop()
		GodsWarManager.Instance:Send17922()
		EventMgr.Instance:AddListener(event_name.begin_fight, self.beginfight)
		EventMgr.Instance:AddListener(event_name.end_fight, self.endfight)
	elseif event == RoleEumn.Event.GodsWarChallenge then
		if MainUIManager.Instance.MainUIIconView ~= nil then
			MainUIManager.Instance.MainUIIconView:hidebaseicon5()
            MainUIManager.Instance.MainUIIconView:Set_ShowTop(false,{17})
		end
	elseif old_event ~= nil then
		if old_event == RoleEumn.Event.GodsWar or old_event == RoleEumn.Event.GodsWarChallenge then
			EventMgr.Instance:RemoveListener(event_name.begin_fight, self.beginfight)
			EventMgr.Instance:RemoveListener(event_name.end_fight, self.endfight)
			self:CloseMainUiTop()
			if MainUIManager.Instance.MainUIIconView ~= nil then
				MainUIManager.Instance.MainUIIconView:Set_ShowTop(true,{})
			    MainUIManager.Instance.MainUIIconView:showbaseicon5()
			end
		end
	end
end

function GodsWarModel:OnBeginFight()
	GodsWarManager.Instance.myCurrentResult = nil
	self:CloseFightShow()
	self:CloseMainUiTop()
end

function GodsWarModel:OnEndFight(type, result)
	if RoleManager.Instance.RoleData.event == RoleEumn.Event.GodsWar then
		self:OpenMainUiTop()
	end
end

function GodsWarModel:OpenMain(args)
	if self.mainWindow == nil then
		self.mainWindow = GodsWarMainWindow.New(self)
	end
	self.mainWindow:Open(args)
end

function GodsWarModel:OpenJiFenShowWin(args)
	if self.showWindow == nil then
		self.showWindow = GodsWarsJiFenShowWindow.New(self)
	end
	self.showWindow:Open(args)
end

function GodsWarModel:CloseMain()
	if self.mainWindow ~= nil then
		WindowManager.Instance:CloseWindow(self.mainWindow)
	end
end

function GodsWarModel:OpenVote(args)
	if GodsWarManager.Instance.status <= GodsWarEumn.Step.Elimination16 then
		NoticeManager.Instance:FloatTipsByString(TI18N("当前状态无法投票"))
		return
	end

	if self.voteWindow == nil then
		self.voteWindow = GodsWarVoteWindow.New(self)
	end
	self.voteWindow:Open(args)
end

function GodsWarModel:CloseVote()
	if self.voteWindow ~= nil then
		WindowManager.Instance:CloseWindow(self.voteWindow)
		self.voteWindow = nil
	end
end

function GodsWarModel:OpenVideo(args)
	if self.videoWindow == nil then
		self.videoWindow = GodsWarVideoWindow.New(self)
	end
	self.videoWindow:Open(args)
end

function GodsWarModel:CloseVideo(noCheck)
	if self.videoWindow ~= nil then
		WindowManager.Instance:CloseWindow(self.videoWindow, noCheck)
	end
end

function GodsWarModel:OpenVoteDetail(args)
	if self.voteDetail == nil then
		self.voteDetail = GodsWarVoteDetailPanel.New(self)
	end
	self.voteDetail:Show(args)
end

function GodsWarModel:CloseVoteDetail()
	if self.voteDetail ~= nil then
		self.voteDetail:DeleteMe()
		self.voteDetail = nil
	end
end

function GodsWarModel:OpenCreate()
	if self.createPanel == nil then
		self.createPanel = GodsWarCreatePanel.New(self)
	end
	self.createPanel:Show()
end

function GodsWarModel:CloseCreate()
	if self.createPanel ~= nil then
		self.createPanel:DeleteMe()
		self.createPanel = nil
	end
end

function GodsWarModel:OpenApply()
	if self.applyPanel == nil then
		self.applyPanel = GodsWarApplyPanel.New(self)
	end
	self.applyPanel:Show()
end

function GodsWarModel:CloseApply()
	if self.applyPanel ~= nil then
		self.applyPanel:DeleteMe()
		self.applyPanel = nil
	end
end

function GodsWarModel:OpenNotice()
	if self.noticePanel == nil then
		self.noticePanel = GodsWarNoticePanel.New(self)
	end
	self.noticePanel:Show()
end

function GodsWarModel:CloseNotice()
	if self.noticePanel ~= nil then
		self.noticePanel:DeleteMe()
		self.noticePanel = nil
	end
end

function GodsWarModel:OpenTeam(args)
	if self.teamPanel == nil then
		self.teamPanel = GodsWarOtherTeamPanel.New(self)
	end
	self.teamPanel:Show(args)
end

function GodsWarModel:CloseTeam()
	if self.teamPanel ~= nil then
		self.teamPanel:DeleteMe()
		self.teamPanel = nil
	end
end

function GodsWarModel:OpenRename()
	if self.renamePanel == nil then
		self.renamePanel = GodsWarRenamePanel.New(self)
	end
	self.renamePanel:Show()
end

function GodsWarModel:CloseRename()
	if self.renamePanel ~= nil then
		self.renamePanel:DeleteMe()
		self.renamePanel = nil
	end
end

function GodsWarModel:OpenDetail(args)
	if self.detailPanel == nil then
		self.detailPanel = GodsWarFightDetailPanel.New(self)
	end
	self.detailPanel:Show(args)
end

function GodsWarModel:CloseDetail()
	if self.detailPanel ~= nil then
		self.detailPanel:DeleteMe()
		self.detailPanel = nil
	end
end

function GodsWarModel:OpenSelect(type)
	if self.selectPanel == nil then
		if type == 2 then
			self.selectPanel = GodsWarFightSelectPanel.New(self, self.videoWindow, type)
		elseif type == 4 then
            self.selectPanel = GodsWarSelectSeasonPanel.New(self.mainWindow)
        else
			self.selectPanel = GodsWarFightSelectPanel.New(self, self.mainWindow, type)
		end
	end
	self.selectPanel:Show()
end

function GodsWarModel:CloseSelect()
	if self.selectPanel ~= nil then
		self.selectPanel:DeleteMe()
		self.selectPanel = nil
	end
end

function GodsWarModel:OpenFightShow(args)
	WindowManager.Instance:ShowUI(false)
	if self.fightShow == nil then
		self.fightShow = GodsWarFightShowPanel.New(self)
	end
	self.fightShow:Show(args)
end

function GodsWarModel:CloseFightShow()
	if not CombatManager.Instance.isFighting then
		WindowManager.Instance:ShowUI(true)
	end
	if self.fightShow ~= nil then
		self.fightShow:DeleteMe()
		self.fightShow = nil
	end
end

function GodsWarModel:OpenMainUiTop()
	if self.mainuiTop == nil then
		self.mainuiTop = GodsWarMainUiTopPanel.New(self)
	end
	self.mainuiTop:Show()
end

function GodsWarModel:CloseMainUiTop()
	if self.mainuiTop ~= nil then
		self.mainuiTop:DeleteMe()
		self.mainuiTop = nil
	end
end

-- 显示战队胜利或失败
function GodsWarModel:OpenFightResult(args)
	if self.fightResult == nil then
		self.fightResult = GodsWarResultPanel.New(self)
	end
	self.fightResult:Show(args)
end

function GodsWarModel:CloseFightResult()
	if self.fightResult ~= nil then
		self.fightResult:DeleteMe()
		self.fightResult = nil
	end

	if GodsWarManager.Instance.summaryData ~= nil then
		self:OpenSummary(GodsWarManager.Instance.summaryData)
	end
end

function GodsWarModel:OpenSummary(args)
	if self.summary == nil then
		self.summary = GodsWarSummaryPanel.New(self)
	end
	self.summary:Show(args)
end

function GodsWarModel:CloseSummary()
	if self.summary ~= nil then
		self.summary:DeleteMe()
		self.summary = nil
	end
end

function GodsWarModel:OpenSettlement(args)
	if self.settlementPanel == nil then
		self.settlementPanel = GodsWarSettlementPanel.New(self)
	end
	self.settlementPanel:Show(args)
end

function GodsWarModel:CloseSettlement()
	if self.settlementPanel ~= nil then
		self.settlementPanel:DeleteMe()
		self.settlementPanel = nil
	end
end

function GodsWarModel:PlayCreateEffect()
	if self.assetWrapper == nil then
		self.assetWrapper = AssetBatchWrapper.New()
	    self.resList = {{file = self.effectPath, type = AssetType.Main}}
	    self.assetWrapper:LoadAssetBundle(self.resList, function () self:OnEffectLoaded() end)
	end
end

function GodsWarModel:OnEffectLoaded()
	if self.assetWrapper ~= nil then
	    self.effect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.effectPath))
	    self.effect.name = "GodsWarEffect"
	    local trans = self.effect.transform
	    trans:SetParent(ctx.CanvasContainer.transform)
	    trans.localScale = Vector3.one
	    trans.localPosition = Vector3(0, 0, -500)
	    Utils.ChangeLayersRecursively(trans, "UI")
	    self.effect:SetActive(true)
	    self.effectTime = LuaTimer.Add(4000, function() self:RemoveEffect() end)

	    self.assetWrapper:DeleteMe()
	    self.assetWrapper = nil
	end
end

function GodsWarModel:RemoveEffect()
	if self.effectTime ~= nil then
		LuaTimer.Delete(self.effectTime)
		self.effectTime = nil
	end

	if self.effect ~= nil then
        GameObject.DestroyImmediate(self.effect)
        self.effect = nil
	end
end

-- 创建冷却30秒
function GodsWarModel:CreateCoolDown()
	if self.cooldownCount == 0 then
		self.cooldownCount = 30
		self.cooldownTime = LuaTimer.Add(0, 1000, function() self:LoopCoolDown() end)
	end
end

function GodsWarModel:LoopCoolDown()
	self.cooldownCount = self.cooldownCount - 1
	if self.cooldownUpdateCall ~= nil then
		self.cooldownUpdateCall()
	end

	if self.cooldownCount == 0 then
		self:EndCoolDown()
	end
end

function GodsWarModel:EndCoolDown()
	if self.cooldownTime ~= nil then
		LuaTimer.Delete(self.cooldownTime)
		self.cooldownTime = nil
	end

	if self.cooldownEndCall ~= nil then
		self.cooldownEndCall()
	end
end

function GodsWarModel:Test()
	-- self:OpenFightResult({result = 1})
	self:OpenFightShow()
end

function GodsWarModel:OpenTopPanel()
	  if self.topPanel == nil then
		    self.topPanel = GodsWarMainTop.New(self, ChatManager.Instance.model.chatCanvas)
    end
		self.topPanel:Show()
		
		-- if MainUIManager.Instance.MainUIIconView ~= nil then
		-- 	  MainUIManager.Instance.MainUIIconViewSet_ShowTop(false, {17, 107})
		-- end
end

function GodsWarModel:CloseTopPanel()
		if self.topPanel ~= nil then
				self.topPanel:DeleteMe()
				self.topPanel = nil

				-- if MainUIManager.Instance.MainUIIconView ~= nil ~= nil then
				-- 		t:Set_ShowTop(true, {17, 107})
				-- end
		end
end

-- function GodsWarModel:StartCheck()
--     if self.timerId == nil then
--         self.timerId = LuaTimer.Add(0, 500,
--                 self:CheckTips()
--         )
--     end
--     self:EnterScene()
-- end


-- function GodsWarModel:EndCheck()
--     if self.timerId ~= nil then
--         LuaTimer.Delete(self.timerId)
--         self.timerId = nil
--     end
--     self:ExitScene()
--     MainUIManager.Instance:DeleteTracePanel(TraceEumn.BtnType.GuildDragon)
-- end

-- function GodsWarModel:CloseMainUI()
--     if self.mainuiPanel ~= nil then
--         self.mainuiPanel:DeleteMe()
--         self.mainuiPanel = nil


--         local t = MainUIManager.Instance.MainUIIconView
--         if t ~= nil then
--             t:Set_ShowTop(true, {17, 107})
--         end
--     end

--     self:CloseDamakuSetting()
-- end


-- function GodsWarModel:EnterScene()
--     if GuildDragonManager.Instance.state == GuildDragonEnum.State.First
--         or GuildDragonManager.Instance.state == GuildDragonEnum.State.Second
--         or GuildDragonManager.Instance.state == GuildDragonEnum.State.Third
--         then
--         self:OpenMainUI()
--     end

--     local t = MainUIManager.Instance.MainUIIconView

--     if t ~= nil then
--         t:Set_ShowTop(false, {17, 107})
--     end
-- end

-- function GodsWarModel:CheckTips()
--     if GuildDragonManager.Instance.state == GuildDragonEnum.State.Ready then
--         self:OpenMainUI(string.format(TI18N("<color='#00ff00'>%s</color>后才进入巨龙峡谷挑战巨龙！"), BaseUtils.formate_time_gap(GuildDragonManager.Instance.end_time - BaseUtils.BASE_TIME, ":", 1, BaseUtils.time_formate.MIN)))
--     elseif GuildDragonManager.Instance.state == GuildDragonEnum.State.Close then
--         self:CloseMainUI()
--     elseif GuildDragonManager.Instance.state == GuildDragonEnum.State.Reward then
--         self:OpenMainUI(TI18N("恭喜挑战成功！"))
--     else
--         if (not self.hasNotified) and GuildDragonManager.Instance.state == GuildDragonEnum.State.First and BaseUtils.BASE_TIME - GuildDragonManager.Instance.start_time == 5 then
--             NoticeManager.Instance:FloatTipsByString(TI18N("巨龙已经苏醒，快去挑战吧！"))
--             self.hasNotified = true
--         end
--         if self.myData ~= nil and self.myData.challenge_time > BaseUtils.BASE_TIME then
--             self.noTips = true
--             self:OpenMainUI(string.format(TI18N("受龙威影响，<color='#ffff00'>%s</color>后才能进入巨龙峡谷！"), BaseUtils.formate_time_gap(self.myData.challenge_time - BaseUtils.BASE_TIME, ":", 1, BaseUtils.time_formate.MIN)))
--         else
--             if self.noTips then
--                 NoticeManager.Instance:FloatTipsByString(TI18N("体力已经恢复，可继续挑战巨龙！"))
--                 self.noTips = false
--             end
--             self:OpenMainUI(TI18N("挑战巨龙可获得<color='#ffff00'>大量龙币</color>！"))
--         end
--     end
-- end

