--[[liyuan
--]]

_G.UIDungeonStory = BaseUI:new("UIDungeonStory");

UIDungeonStory.stepId = nil
UIDungeonStory.dungeonId = nil
UIDungeonStory.countDownTime = nil
UIDungeonStory.timeId = nil
UIDungeonStory.lastUpdateTime = 0
UIDungeonStory.updateDelay = 100
UIDungeonStory.lastUpdateCheckTime = 0
UIDungeonStory.bianyiId = 0
UIDungeonStory.bianyiStar = 0
UIDungeonStory.isAutoBattle = true
function UIDungeonStory:Create()
	self:AddSWF("dungeonStoryPanel.swf",true,"center")
end

function UIDungeonStory:OnLoaded(objSwf, name)
	-- 初始化
	objSwf.panel.btnOpen.click = function() self:OnBtnOpenClick(e) end
	objSwf.panel.btnBack.click = function() self:OnBtnBackClick() end
	objSwf.btnCloseState.click = function() self:OnBtnCloseClick() end
	objSwf.panel.btnAuto.click = function() 
		self.isAutoBattle = not self.isAutoBattle
		if self.isAutoBattle then
			self:DoAutoBattle()
			objSwf.panel.btnAuto.labelID = 'dungeon8'
		else
			MainPlayerController:StopMove()
			AutoBattleController:CloseAutoHang()
			objSwf.panel.btnAuto.labelID = 'dungeon7'
		end
	end
	objSwf.panel.btnGuild.click = function() self:ResetCheckState() self:OnBtnGuildClick() end
	objSwf.panel.labTotalTime.text = UIStrConfig['dungeon3']
	objSwf.panel.mcBianyi.labName.text = StrConfig['dungeon6']
	objSwf.panel.mcBianyi._visible = false
	objSwf.panel.mcBianyi.hitTestDisable = true
	objSwf.panel.mcBianyi.btnJiangjie.click = function() 
		if not self.bianyiId or self.bianyiId ==0 then return end 
		DungeonController:ReqBossBianyi(self.bianyiId) 
	end
	
	--objSwf.panel.labProcess.text = '0%'
	--objSwf.panel.labWanchengdu.text = UIStrConfig['dungeon5']
	
	objSwf.panel.mcBianyi.btnJiangjie.rollOver = function(e) TipsManager:ShowBtnTips(UIStrConfig["dungeon6"]); end
	objSwf.panel.mcBianyi.btnJiangjie.rollOut = function(e) TipsManager:Hide(); end

	objSwf.panel.btnRule.rollOver = function() 
		TipsManager:ShowBtnTips( StrConfig['dungeon310'], TipsConsts.Dir_RightDown )
	 end
	objSwf.panel.btnRule.rollOut = function() TipsManager:Hide(); end
end

function UIDungeonStory:GetWidth(szName)
	return 378 
end

function UIDungeonStory:GetHeight(szName)
	return 325
end

--打开面板
function UIDungeonStory:Open(dungeonId,stepId,countDownTime, bianyiId, bianyiStar)
	--- 副本id，进行到哪一步,副本剩余时间,boss变异，boss星级
	self.dungeonId = dungeonId
	self.countDownTime = toint(countDownTime/1000)
	self.stepId = stepId
	self.bianyiId = bianyiId or 0
	self.bianyiStar = bianyiStar or 0
	self:Show()   ---调用基类的方法打开UI
end

--服务器返回更新当前步骤的显示  
function UIDungeonStory:UpdateStepInfo(dungeonId, stepId)
	local objSwf = self.objSwf
	if not objSwf then return end
	self:ResetCheckState()
	self.stepId = stepId
	local stepCfg = nil
	if self.stepId then stepCfg = t_dunstep[self.stepId] end

	if stepCfg then
		DungeonModel.currentMonsterId = stepCfg.monsterId or 0
		objSwf.panel.labInfo.text = stepCfg.trackInfo						--描述
		DungeonModel:ResetKillNum(UIDungeonStory:GetGoal(stepCfg))
		local trackStr = stepCfg.trackInfo2 or ""
		objSwf.panel.btnGuild.labGuild.htmlText = "<u>" .. trackStr .. "</u>";	--指引
		self:UpdateKillNum()
		--self:UPdateProcessBar(stepCfg.process)
	end
end

---获取目标
function UIDungeonStory:GetGoal(stepCfg)
	local diffi = DungeonModel:GetDungeonDifficulty()   --取得副本的难度等级
	-- WriteLog(LogType.Normal,true,'-------------houxudongdiffi',diffi)
	-- local diffi = self.dungeonId % 100;	   
	local list = split(stepCfg.targetNum, "#")
	
	if list and #list > 0 then   --	if list and #list > 0 and diffi > 0 then
		return list[diffi]       --取得对应数量的怪物id和怪物数量
	end
	
	return nil
end

--更新杀怪数量
function UIDungeonStory:UpdateKillNum()
	local objSwf = self.objSwf
	if not objSwf then return end
	
	local stepCfg = nil
	if self.stepId then stepCfg = t_dunstep[self.stepId] end

	if stepCfg and stepCfg.targetNum and stepCfg.targetNum ~= "" then

		local targetStr = UIDungeonStory:GetGoal(stepCfg)   ---目前根据副本难易度选择怪物数量，后期取消难易度
		if targetStr and targetStr ~= "" then
			local targetList = split(targetStr, ",")
			if targetList and #targetList > 0 then
				local cfgmonster = t_monster[toint(targetList[1])]
				local monsterName = "杀怪数量"
				if cfgmonster then
					monsterName = cfgmonster.name
				end
				local trackStr = stepCfg.trackInfo2 or ""
				local maxTargetNum = toint(targetList[2])       --当前阶段怪物的总数量
				local targetNum = DungeonModel.currentKillNum   --当前杀死的怪物数量
				if targetNum >= maxTargetNum then
					targetNum = maxTargetNum
				end
				local killStr = "("..targetNum.."/"..targetList[2]..")"
				objSwf.panel.btnGuild.labGuild.htmlText = "<u>" .. trackStr .. "</u>".."<font color='#00ff00'>"..killStr.."</font>";	--指引
			end
		end
	end
end

--更新进度条显示 just by times
function UIDungeonStory:UPdateProcessBar(process,totalNum)
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.panel.processBar.maximum = toint(totalNum)
	objSwf.panel.processBar.value = process or 0
	local hour, min, sec = CTimeFormat:sec2format(process);
	self:BreakDownStar(process,hour,min,sec,totalNum)
end

function UIDungeonStory:BreakDownStar(process,hour,min,sec,totalNum)
	local objSwf = self.objSwf
	if not objSwf then return; end
	if process == totalNum*0.7 then
		objSwf.panel.starPfx5:play()
	elseif process == totalNum*0.5 then
		objSwf.panel.starPfx4:play()
	elseif process == totalNum*0.3 then
		objSwf.panel.starPfx3:play()
	elseif process == totalNum*0.1 then
		objSwf.panel.starPfx2:play()
	elseif process >= totalNum then
		objSwf.panel.starPfx1:play()
	end
	--[[
	if hour == 0 and min == totalNum*0.7 and sec == 0 then
		objSwf.panel.starPfx5:play()		
	elseif hour == 0 and min == totalNum*0.5 and sec == 0 then
		objSwf.panel.starPfx4:play()
	elseif hour == 0 and min == totalNum*0.3 and sec == 0 then
		objSwf.panel.starPfx3:play()
	elseif hour == 0 and min == totalNum*0.1 and sec == 0 then
		objSwf.panel.starPfx2:play()
	elseif hour == 0 and min <= 0 and sec == 0 then
		objSwf.panel.starPfx1:play()
	end
	--]]
end

-- 检测自动完成
function UIDungeonStory:Update()
	if not self.bShowState then return end
	if not DungeonModel.isInDungeon then return end
	if not self.isAutoBattle then return end

	local NowTime = GetCurTime()
	local mplayer = MainPlayerController:GetPlayer()
	if not mplayer then
		self:ResetCheckState()
		return
	end

	if not self.stepId then
		self:ResetCheckState()
		-- FPrint('stepId false')
		return
	else
		local stepCfg = t_dunstep[self.stepId]
		if not stepCfg then 
			self:ResetCheckState()
			--FPrint('stepCfg false')
			return
		end
	end
	
	if not self:IsLeisureState() then
		--FPrint('mplayer:IsLeisureState() false')
		self:ResetCheckState()
		return
	end
	
	if NowTime - self.lastUpdateTime > self.updateDelay then
		self.lastUpdateTime = NowTime
		if NowTime - self.lastUpdateCheckTime > DungeonConsts.AUTO_NEXT_WAIT_TIME then
			self.lastUpdateCheckTime = NowTime			
			self:DoAutoBattle()
		end
	end
	
end

--改变挂机按钮文本
function UIDungeonStory:OnChangeAutoText(state)
	local objSwf = self.objSwf;
	if not objSwf then return end
	-- self.isAutoBattle = state
	-- if state then    			--state为true的话自动挂机，为false的话取消挂机
		
	-- 	-- self.isAutoBattle = not self.isAutoBattle
	-- 	if self.isAutoBattle then
	-- 		-- self:DoAutoBattle()  --自动战斗
	-- 		objSwf.panel.btnAuto.labelID = 'dungeon8'   --取消副本
	-- 	end
	-- else
	-- 	objSwf.panel.btnAuto.labelID = 'dungeon7'   --自动副本
	-- end
	if self.isAutoBattle then
		objSwf.panel.btnAuto.labelID = 'dungeon8'   --取消副本
	else
		objSwf.panel.btnAuto.labelID = 'dungeon7'   --自动副本
	end
end

--自动挂机找怪
function UIDungeonStory:DoAutoBattle()
	if UIDungeonDialogBox:IsShow() then
		UIDungeonDialogBox:AutoCompleteDialog()
	else
		self:OnBtnGuildClick()		
	end
end

function UIDungeonStory:IsLeisureState()
	local mplayer = MainPlayerController:GetPlayer()

	if not mplayer:GetAvatar() then
		--FPrint('1')
		return false
	end
	if mplayer:IsDead() then
		--FPrint('2')
		return false
	end
	if mplayer:IsSkillPlaying() then
		--FPrint('3')
		return false
	end
	if not mplayer:IsPunish() then
		--FPrint('4')
		return false
	end
	if mplayer:IsChanState() == true then
        return false
    end
    if mplayer:IsPrepState() == true then
        return false
    end
	if mplayer:IsMoveState() then
		--FPrint('5')
		return false
	end
	if mplayer:IsSitState() then
		--FPrint('6')
		return false
	end
	-- if mplayer:IsOnHorse() then	
		--FPrint('7')
		-- return false
	-- end
	if mplayer:GetStateInfoByType(PlayerState.UNIT_BIT_GOD) == 1 then
		--FPrint('8')
		return false
	end
	-- if mplayer:GetStateInfoByType(PlayerState.UNIT_BIT_INCOMBAT) == 1 then
		-- --FPrint('9')
		-- return false
	-- end
	if mplayer:GetStateInfoByType(PlayerState.UNIT_BIT_STIFF) == 1 then
		--FPrint('10')
		return false
	end
	
	if StoryController:IsStorying() then
		--FPrint('11')
		return false
	end 

	if mplayer:Leisure() then
		return false
	end
	return true
end

-- 重置检测状态
function UIDungeonStory:ResetCheckState()
	local NowTime = GetCurTime()
	self.lastUpdateTime = NowTime
	self.lastUpdateCheckTime = NowTime
end

-- 关闭
function UIDungeonStory:OnHide()
	if self.timeId then
		TimerManager:UnRegisterTimer(self.timeId)
	end
	--关闭掉当前的NPC对话窗口
	if UINpcDialogBox:IsShow() then
		UINpcDialogBox:Hide()
	end
	self:CancelQuitConfirm()
	
	self.stepId = nil
	self.dungeonId = nil
	self.countDownTime = nil
	self.timeId = nil
	self.lastUpdateTime = 0
	self.updateDelay = 100
	self.lastUpdateCheckTime = 0
	self.bianyiId = 0
	self.bianyiStar = 0
end

-- 打开操作
function UIDungeonStory:OnShow()
	local objSwf = self:GetSWF("UIDungeonStory")
	if not objSwf then return end
	
	MainMenuController:HideRight()   ---隐藏右侧活动视图
	local stepCfg = nil
	if self.stepId then stepCfg = t_dunstep[self.stepId] end

	if stepCfg then
		objSwf.panel.labInfo.text = stepCfg.trackInfo					--追踪描述
		DungeonModel:ResetKillNum(UIDungeonStory:GetGoal(stepCfg))--
		local trackStr = stepCfg.trackInfo2 or ""
		objSwf.panel.btnGuild.labGuild.htmlText = "<u>" .. trackStr .. "</u>";	--指引
		self:UpdateKillNum()
		
		objSwf.panel.processBar.maximum = 100
		objSwf.panel.processBar.value = stepCfg.process or 0
		--objSwf.panel.labProcess.text = (stepCfg.process or 0)..'%'
	end
	-- 临时屏蔽星星和进度条
	for i=1,5 do
		objSwf.panel['starPfx'..i]._visible = false
		if i < 5 then
			objSwf.panel['star'..i]._visible = false
		end
	end
	objSwf.panel.processBar._visible = false
	local dungeonCfg = t_dungeons[self.dungeonId]
	if not dungeonCfg then 
		WriteLog(LogType.Normal,true,'--------error dungeonId:',self.dungeonId) 
	end
	if dungeonCfg then
		objSwf.panel.labName.text = dungeonCfg.name						--副本名
	end
	if self.countDownTime > 0 then
		if self.countDownTime > 0.7 *dungeonCfg.limit_time* 60 then
			for i = 1, 5 do
				objSwf.panel['starPfx' ..i]:gotoAndStop(1)
			end
		end
		if self.countDownTime <= 0.7 *dungeonCfg.limit_time* 60 then
			objSwf.panel.starPfx5:play()
		end
		if self.countDownTime <= 0.5 *dungeonCfg.limit_time* 60 then
			objSwf.panel.starPfx4:play()
		end
		if self.countDownTime <= 0.3 *dungeonCfg.limit_time* 60 then
			objSwf.panel.starPfx3:play()
		end
		if self.countDownTime <= 0.1 *dungeonCfg.limit_time* 60 then
			objSwf.panel.starPfx2:play()
		end
		-- for i = 1, 5 do
		-- 	if self.countDownTime <= (0.2 *i -1) *dungeonCfg.limit_time* 60 then
		-- 		objSwf.panel["starPfx" ..i]:play()
		-- 	else
		-- 		if self.countDownTime > 0.7 *dungeonCfg.limit_time* 60 then
		-- 			objSwf.panel["starPfx" ..i]:gotoAndStop(1)
		-- 		end
		-- 	end
		-- end
	end
	objSwf.panel.processBar.maximum = dungeonCfg.limit_time * 60;
	objSwf.panel.processBar.value =  self.countDownTime;

	objSwf.panel.labCountDown.text = ''									--倒计时
	if self.countDownTime > 0 then
		self.timeId = TimerManager:RegisterTimer(function()
													if self.countDownTime <= 0 then 
														TimerManager:UnRegisterTimer(self.timeId) 
														return;
													end
													self.countDownTime = self.countDownTime - 1		
													self:UPdateProcessBar(self.countDownTime,dungeonCfg.limit_time*60)   ---更新进度条
													objSwf.panel.labCountDown.text = DungeonUtils:ParseTime(self.countDownTime)
													if self.countDownTime <= 3 then
														self:PickUpItemAll()
													end
												end,1000,0)
	end
	self:ResetCheckState()
	self:OnBianyiUpdate()
	self.isAutoBattle = true
	objSwf.panel.btnAuto.labelID = 'dungeon8' 
	objSwf.btnCloseState._visible = false
	objSwf.panel._visible = true
end

function UIDungeonStory:OnBianyiUpdate()
	local objSwf = self.objSwf
	if not objSwf then return end
	-- 变异
	if self.bianyiId and self.bianyiId > 0 then
		objSwf.panel.mcBianyi._visible = false
		objSwf.panel.mcBianyi.hitTestDisable = true
		if self.bianyiStar > 0 then
			for i=1,3 do
				if i <= self.bianyiStar then
					objSwf.panel.mcBianyi['star'..i]._visible = false
				else
					objSwf.panel.mcBianyi['star'..i]._visible = false
				end
			end
			
			local monsterCfg =  t_monster[self.bianyiId];
			if monsterCfg then
				local modelCfg = t_model[ monsterCfg.modelId ];
				local iconName = modelCfg and modelCfg.icon;
				if iconName and iconName ~= "" then
					local iconURL = ResUtil:GetMonsterIconName(iconName);
					if objSwf.panel.mcBianyi.iconLoader.source ~= iconURL then
						objSwf.panel.mcBianyi.iconLoader.source = iconURL; --头像
					end
				end
			end
		else
			for i=1,3 do
				objSwf.panel.mcBianyi['star'..i]._visible = false
			end	
		end
	else
		objSwf.panel.mcBianyi._visible = false	
		objSwf.panel.mcBianyi.hitTestDisable = true
	end
	
end

--点击展开按钮
function UIDungeonStory:OnBtnOpenClick(e)
	local objSwf = self:GetSWF("UIDungeonStory")
	if not objSwf then return end
	objSwf.panel._visible = false
	objSwf.btnCloseState._visible = true
	--objSwf.panel.hitTestDisable = not objSwf.panel._visible;
end

--点击展开按钮
function UIDungeonStory:OnBtnCloseClick()
	local objSwf = self:GetSWF("UIDungeonStory")
	if not objSwf then return end
	objSwf.panel._visible = true;
	objSwf.btnCloseState._visible = false;
end

-- 点击退出
function UIDungeonStory:OnBtnBackClick()
	local content = StrConfig["dungeon501"];
	local confirmFunc = function() self:AbstainDungeon(); end
	local confirmLabel = StrConfig["dungeon503"];
	local cancelLabel  = StrConfig["dungeon504"];
	self.quitConfirm = UIConfirm:Open( content, confirmFunc, nil, confirmLabel, cancelLabel );
end



function UIDungeonStory:CancelQuitConfirm()
	if self.quitConfirm then
		UIConfirm:Close(self.quitConfirm)
		self.quitConfirm = nil
	end
end

-- 退出副本
function UIDungeonStory:AbstainDungeon()
	self:PickUpItemAll()
	DungeonController:ReqLeaveDungeon( self.dungeonId );
end

-- 副本指引
function UIDungeonStory:OnBtnGuildClick()
	-- Debug(debug.traceback())
	-- FPrint('副本指引')
	local stepCfg = t_dunstep[self.stepId]
	if not stepCfg then return end
	if stepCfg.type == DungeonConsts.Type_Find_Path then 
		DungeonController:goToTarget(stepCfg)
		-- WriteLog(LogType.Normal,true,'-------------寻路,任务id&任务标题',self.stepId,stepCfg.trackInfo)
	elseif stepCfg.type == DungeonConsts.Type_Kill_Monster then   -- 2
		DungeonController:goToKillMonster(stepCfg) 
		-- WriteLog(LogType.Normal,true,'-------------杀怪,任务id&任务标题:',self.stepId,stepCfg.trackInfo)
	elseif stepCfg.type == DungeonConsts.Type_Npc_Talk then 
		DungeonController:goToTalk(stepCfg) 
		-- WriteLog(LogType.Normal,true,'-------------对话,任务id&任务标题:',self.stepId,stepCfg.trackInfo)
	elseif stepCfg.type == DungeonConsts.Type_Conllection then   --4
		DungeonController:gotoCollect(stepCfg) 
		-- WriteLog(LogType.Normal,true,'-------------采集,任务id&任务标题:',self.stepId,stepCfg.trackInfo)
	elseif stepCfg.type == DungeonConsts.Type_Use_Item then 
		DungeonController:useItem(stepCfg) 
		-- WriteLog(LogType.Normal,true,'-------------使用物品,任务id&任务标题:',self.stepId,stepCfg.trackInfo)
	end
end

---------------------------------消息处理------------------------------------
--监听消息
function UIDungeonStory:ListNotificationInterests()
	return {
		NotifyConsts.DungeonBossBianyi,
		NotifyConsts.AutoHangStateChange,
	} 
end

--处理消息
function UIDungeonStory:HandleNotification(name, body)
	if not self.bShowState then return end
	local objSwf = self.objSwf
	if not objSwf then return end
	
	if name == NotifyConsts.DungeonBossBianyi then
		self.bianyiId = body.bianyiId or 0
		self.bianyiStar = body.bianyiStar or 0
		self:OnBianyiUpdate()
	elseif name == NotifyConsts.AutoHangStateChange then
		self:OnChangeAutoText(body.state);
	end
end

function UIDungeonStory:PickUpItemAll()
	local list, ret = self:GetPickUpItem()
	if #list >= 1 then
		DropItemController:SendPickUpItem(list)	
	end
end

function UIDungeonStory:GetPickUpItem()
	local result = {}
	local ret = false
	local pos = MainPlayerController:GetPlayer():GetPos()
	for cid, item in pairs(MainPlayerModel.allDropItem) do
		local itemPos = item:GetPos()
		local itemId = item:GetItemId()
		if GetDistanceTwoPoint(itemPos, pos) <=  100 then
			ret = true
			if BagModel:CheckCanPutItem(itemId, 1) then
				table.insert(result, {id = cid})
			end
		end
	end
	return result, ret
end

--------------------------------以下是功能引导相关接口-------------------
function UIDungeonStory:GetGuildBtn()
	if not self:IsShow() then return; end
	return self.objSwf.panel.btnGuild;
end

