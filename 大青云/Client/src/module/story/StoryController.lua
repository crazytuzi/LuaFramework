--[[剧情
liyuan
2014年10月18日10:32:23
]]

_G.StoryController = setmetatable({},{__index = IController});
StoryController.name = "StoryController";
------------------------
StoryController.timeId = nil
StoryController.completeCallBack = nil
StoryController.isZoomPlaying = false
StoryController.isUseStoryCamera = false
--当前剧情完成回调
StoryController.currFinishCallBack = {};
StoryController.questDelay = 1000
StoryController.NpcId = nil
StoryController.isArena = false
StoryController.isShowCountDown = false
StoryController.endTimeId = nil
StoryController.revordFov = nil
StoryController.noResetPos = nil
StoryController.isHideUI = false
function StoryController:Create()
	self.Story = CStory:new()
	self.dwStoryId = ''
	self.bOnStory = false;

	return true
end

function StoryController:OnEnterGame()
	local mapId = CPlayerMap:GetCurMapID()
	if 10100001 == mapId or 10100000 == mapId then
		-- StorySpeedUpEffect:Show()
		-- StorySpeedUpEffect:Hide()
	end
end

--切换场景完成后的回调
function StoryController:OnChangeSceneMap()
	local mapId = CPlayerMap:GetCurMapID()
	if 10100001 == mapId or 10100000 == mapId then
		-- StorySpeedUpEffect:Show()
		-- StorySpeedUpEffect:Hide()
	end
end

function StoryController:Update(dwInterval)
	if not self.bOnStory then return end
	self.Story:Update(dwInterval)
	return true
end

function StoryController:Destroy()
	return true
end

-- 是否正在播放剧情
function StoryController:IsStorying()
	return self.bOnStory
end

-- 切换地图时检测剧情触发
function StoryController:OnChangeSceneMap()
	self:OnNeedCheck()
end

function StoryController:OnLeaveSceneMap()
	StoryController:ResetCameraOldPos()
end

function StoryController:OnNeedCheck()

end

--注册当前剧情完成后的回调
function StoryController:RegisterCurrCallBack(func)
	table.push(self.currFinishCallBack,func);
end

function StoryController:StoryStartArena(dwStoryId, onCompletedFunc)
	self.isArena = true
	self:StoryStartMsg(dwStoryId, onCompletedFunc)
end

-- 播放剧情
-- @剧情id
-- @播放完回调
-- @npcid
-- @sShowCountDown
-- @isFirst
function StoryController:StoryStartDoupocangqiong(dwStoryId, onCompletedFunc, npcId, isShowCountDown, isFirst)
	-- if isShowCountDown then
		-- FPrint('要倒计时')
	-- else
		-- FPrint('不要要倒计时')
	-- end
	self.isShowCountDown = isShowCountDown
	self.noResetPos = isFirst
	self.isDoupocangqiong = true
	self:StoryStartMsg(dwStoryId, onCompletedFunc, nil, nil, npcId)
end

-- 播放剧情
-- @剧情id
-- @播放完回调
-- @是否是预览
-- @是否多个连续播放
-- @斗破苍穹npcid
StoryController.defaultFov = 0
function StoryController:StoryStartMsg(dwStoryId, onCompletedFunc, isPreview, isMulti, npcId)
	FPrint("收到播放剧情消息"..dwStoryId)

	if dwStoryId == "juqinglayuan" then
		-- FPrint('juqinglajin')
		-- StoryController:ResetCamera()
		return
	end

	if dwStoryId == "juqinglajin" then
		-- FPrint('juqinglajin')
		TimerManager:RegisterTimer(function()
			StoryController:ResetCamera(1000)
		end,2000,1)

		return
	end

	if StoryChapterCfg[dwStoryId] then
		UIStoryChapter:ShowChapter(StoryChapterCfg[dwStoryId], nil)
	end

	_sys.skeletonPick = true
	-- self.noResetPos = false
	-- UIStartBalckDialog:PlayStoryDialog(1)
	-- if true then return end
	StoryController:ResetQuestCamera()
	if self.questDelayTimeId then
		TimerManager:UnRegisterTimer(self.questDelayTimeId);
	end
	if self.endTimeId then
		TimerManager:UnRegisterTimer(self.endTimeId);
	end
	if dwStoryId:find("teshu") then
		StoryController:PlayNpcPatrolStory(dwStoryId)
		return
	end

	if string.sub(dwStoryId,1,4) == StoryConsts.ProfPrefix and not isPreview then
		local dwProf = MainPlayerModel.humanDetailInfo.eaProf
		-- FPrint('不同职业的不同剧情'..dwStoryId..':'..dwStoryId .. dwProf)
		dwStoryId = dwStoryId .. dwProf
	end

	self.dwStoryId = dwStoryId
	self.completeCallBack = onCompletedFunc
	if self.Story:LoadStory(dwStoryId) then
		for k,v in pairs(_G.NoStoryUICfg) do
			if dwStoryId == v then
				self.isHideUI = true
				break
			end
		end

		AutoBattleController:CloseAutoHang()
		self.bOnStory = true;
		self.isUseStoryCamera = true
		self.isMulti = isMulti
		self.NpcId = npcId
		self.revordFov = _rd.camera.fov
		UIStoryDialog:Hide()
		StoryActionController.needResetOffsetPos = nil
		MainPlayerController:StopSelfPfx()
		CControlBase:SetControlDisable(true)
		--如果正在打坐，取消
		if SitModel:GetSitState() ~= SitConsts.NoneSit then
			SitController:ReqCancelSit();
		end
		--如果在马上 先下马
		if MountModel:isRideState() then
			MountController:RideMount()
		end
		--锁玩家操作
		local player = MainPlayerController:GetPlayer()
		if player then
			MainPlayerController:StopMove()
			--隐藏主玩家神兵
			local wavatar = player:GetMagicWeaponFigure()
			if wavatar and wavatar.objNode then
				wavatar.objNode.visible = false
			end
			--隐藏主玩家灵器
			local lavatar = player:GetLingQiFigure()
			if lavatar and lavatar.objNode then
				lavatar.objNode.visible = false
			end
			--隐藏主玩家玉佩
			local lavatar = player:GetMingYuFigure()
			if lavatar and lavatar.objNode then
				lavatar.objNode.visible = false
			end
			--隐藏主玩家小跟宠
			local pet = player.pet
			if pet and pet.objNode then
				pet.objNode.visible = false
			end
		end
		--SoundManager:StopSfx()
		CharController:HideMapScriptNode()
		ClickLog:Send(ClickLog.T_Story_Enter,dwStoryId)--剧情进入,param:剧情id
		self.Story:NextStory()
	end
end

-- 播放完一段剧情
function StoryController:OnStoryFinish()
	StoryActionController:DelSceneViewMonster()
	if self.Story:IsStory() then
		-- SpiritsUtil:Print("OnStoryFinish self.Story:NextStory()")
		self.Story:Clear()
		self.Story:NextStory()
	else
		-- SpiritsUtil:Print("OnStoryFinish NONONONextStory()")
		self.Story:Clear()
		self.Story:End()
		UIStory:Clear()
		self:StoryFinishMsg(self.dwStoryId)
	end
end

-- 下一步
function StoryController:OnStoryNext()
	self.Story:Clear()
	self:OnStoryFinish()
end

-- 跳过直接结束
function StoryController:OnStorySkip()
	if not self.bOnStory then
		return
	end
	if not self.isDoupocangqiong then
		self.noResetPos = false
	end
	ClickLog:Send(ClickLog.T_Story_Skip,self.dwStoryId)--剧情跳过,param:剧情id
	self.Story:Clear()
	self.Story:End()
	UIStory:Clear()
	self:StoryFinishMsg(self.dwStoryId)
end

-- 结束后回调
local endFunc = function()
	-- SpiritsUtil:Print("SetControlDisable(false)")
	UIStory:Hide()
	if ArenaBattle.inArenaScene == 0 then
		CControlBase:SetControlDisable(false)
	end
end

-- 结束时的处理
function StoryController:StoryFinishMsg(dwStoryId)
	FPrint("剧情结束")
	_app.speed = 1.0
	-- CTimer:AddTimer( 1000, false, endFunc )
	if self.endTimeId then
		TimerManager:UnRegisterTimer(self.endTimeId);
	end

	self.endTimeId = TimerManager:RegisterTimer(function()
		TimerManager:UnRegisterTimer(self.endTimeId);
		endFunc();
	end,1000,1)

	-- CPlayerControl:ResetCameraPos(1000)
	self.noResetPos = false
	self.NpcId = nil
	self.isShowCountDown = false
	self.isHideUI = false
	-- StorySpeedUpEffect:Hide()

	if not self.isMulti then
		CharController:ShowPlayerAndMonster()
		CharController:ShowDropItem()
	end
	if self.isMulti then
		if not _rd.screenBlender then _rd.screenBlender = _Blender.new(); end
		_rd.screenBlender:fade(0, 0.99, 1, 0)
	end

	local player =  MainPlayerController:GetPlayer()
	if player then
		local Avatar = player:GetAvatar()
		Avatar.bZCSStop = nil
		if _G.isEtitStoryTiao or not _G.IsCameraToolsShow then
			if self.dwStoryId ~= StoryConsts.kanyuanfangStoryId then
				Avatar:SetCameraFollow()
			end
		end
		Avatar:SetMount(0);
		Avatar:SetAttackAction(Avatar.bIsAttack)
		Avatar:StopAllAction()
		Avatar:ExecIdleAction()
	end
	StoryActionController:Clear()
	--特殊剧情
	if self.dwStoryId == StoryConsts.LinshouStoryId then
		LingshouAction:ExeAction()
	end
	if StoryChangePosCfg[self.dwStoryId] then
		local msg = ReqTeleportMsg:new();
		msg.type = 3;
		msg.mapId = CPlayerMap:GetCurMapID();
		msg.x = StoryChangePosCfg[self.dwStoryId].x  or 0;
		msg.y = StoryChangePosCfg[self.dwStoryId].y or 0;
		-- FTrace(msg,'直接改变坐标')
		MsgManager:Send(msg);
	end

	if not self.isMulti then
		self.bOnStory = false;
		-- if self.questDelayTimeId then
			-- TimerManager:UnRegisterTimer(self.questDelayTimeId);
		-- end

		-- self.questDelayTimeId = TimerManager:RegisterTimer(function()
			-- TimerManager:UnRegisterTimer(self.questDelayTimeId);
			-- print('333333333333333333333333');
			for i,func in ipairs(self.currFinishCallBack) do
				func();
			end
			self.currFinishCallBack = {};
		-- end,self.questDelay,1)
		if _rd.screenBlender then _rd.screenBlender = _Blender.new(); end
		-- FPrint('清空黑片')
	end
	if not GameController.loginState then
		SoundManager:StopStoryBackSfx()
	end
	CharController:ShowMapScriptNode()
	if player then
		--显示主玩家神兵
		local wavatar = player:GetMagicWeaponFigure()
		if wavatar and wavatar.objNode then
			wavatar.objNode.visible = true
		end
		--显示主玩家灵器
		local lavatar = player:GetLingQiFigure()
		if lavatar and lavatar.objNode then
			lavatar.objNode.visible = true
		end
		--显示主玩家玉佩
		local lavatar = player:GetMingYuFigure()
		if lavatar and lavatar.objNode then
			lavatar.objNode.visible = true
		end
		--显示主玩家小跟宠
		local pet = player.pet
		if pet and pet.objNode then
			pet.objNode.visible = true
		end
	end
	-- if not self.noResetPos then
		MagicWeaponFigureController:ResetMagicWeaponPos(player, true)
	-- end
		LingQiFigureController:ResetMagicWeaponPos(player, true)
	MingYuFigureController:ResetMagicWeaponPos(player, true)
	self.isDoupocangqiong = false
	ClickLog:Send(ClickLog.T_Stroy_Finish,self.dwStoryId)--剧情完成,param:剧情id
	if self.completeCallBack then
		--FPrint("剧情结束回调函数")
		self.completeCallBack()
		-- self.completeCallBack = nil
	end

	if UIStoryChapter:IsShow() then
		UIStoryChapter:Hide()
	end
	FPrint("剧情结束1")
	TimerManager:RegisterTimer(function()
		if dwStoryId == StoryConsts.juqinglayuanStoryId then
			-- FPrint('juqinglayuan')
			StoryController:ZoomOutCamera(50,500)
			return
		end
	end,3000,1)
end


----------------------------------------------------------------------------------
function StoryController:SetNpcState(dwStoryID,dwType)
	local cfg = self:GetStoryCfg(dwStoryID)
	if not cfg then return end;
	if dwType==3 then
		CNpcManager:Story(dwStoryID)
		CNpcManager:SpeedUpStory(true)
		return
	end

	if dwType==1 then
		if self.Story:LoadStory(dwStoryID) then
			self.Story:Clear()
		end
		return
	end
end
function StoryController:ResetNpcState(dwStoryID,dwType)
	local cfg = self:GetStoryCfg(dwStoryID)
	if not cfg then return end;
	for k,v in pairs(cfg) do
		if v.Patrol then
			self:ResetNpcByPatrol(v.Patrol)
		end
		if v.mNpcId then
			local npc = CNpcManager:GetNpcInfoByConfigId(v.mNpcId)
			if npc then
				npc:BackToBorn()
			end
		end
	end
end

function StoryController:ResetNpcByPatrol(Patrol)
	for k,v in pairs(Patrol) do
		local npc = CNpcManager:GetNpcInfoByConfigId(v.npc)
		if npc then
			npc:BackToBorn()
		end
	end
end
----------------------------------------------------------------------------------
function StoryController:GetStoryCfg(sID)
	local StoryCfg = StoryConfig[CPlayerMap:GetCurMapID()]
	if not StoryCfg[sID] then
		SpiritsUtil:Print('没有找到剧情配置文件'..dwStoryId)
		return false
	end
	return StoryCfg[sID]
end


function StoryController:StopPfx()
end


function StoryController:SetNpc(dwTaskID,dwState)
	if CTaskSystem.AcceptTasks[1001] then return end;
	local cfg = TaskMoveConfig[dwTaskID]
	if not cfg then return end;
	local Info;
	local dwFirstID,dwType1;
	local dwSecondID,dwType2;
	local dwProf = MainPlayerController:GetPlayer():GetInfo().dwProf
	if dwState == TaskStateConfig.Accept then
		Info = cfg[1]
	elseif dwState == TaskStateConfig.Done then
		Info = cfg[2]
	end
	if Info then
		if type(Info[1])=="table" then
			Info = Info[dwProf]
		end
	end
	if Info then
		dwFirstID,dwType1 = Info[1],Info[2]
		dwSecondID,dwType2 = Info[3],Info[4]
	end
	if dwFirstID and dwType1 then
		self:SetNpcState(dwFirstID,dwType1)
	end
	if dwSecondID and dwType2 then
		self:SetNpcState(dwSecondID,dwType2)
	end
end

function StoryController:ResetNpc(dwTaskID)
	local cfg = TaskMoveConfig[dwTaskID]
	if not cfg then return end;
	local Info1,Info2;
	local dwFirstID,dwType1;
	local dwSecondID,dwType2;
	local dwProf = MainPlayerController:GetPlayer():GetInfo().dwProf
	Info1 = cfg[1]
	Info2 = cfg[2]
	if Info1 then
		if type(Info1[1])=="table" then
			Info1 = Info1[dwProf]
		end
	end
	if Info1 then
		dwFirstID,dwType1 = Info1[1],Info1[2]
		dwSecondID,dwType2 = Info1[3],Info1[4]
	end
	if dwFirstID and dwType1 then
		self:ResetNpcState(dwFirstID,dwType1)
	end
	if dwSecondID and dwType2 then
		self:ResetNpcState(dwSecondID,dwType2)
	end
	if Info2 then
		if type(Info2[1])=="table" then
			Info2 = Info2[dwProf]
		end
	end
	if Info2 then
		dwFirstID,dwType1 = Info2[1],Info2[2]
		dwSecondID,dwType2 = Info2[3],Info2[4]
	end
	if dwFirstID and dwType1 then
		self:ResetNpcState(dwFirstID,dwType1)
	end
	if dwSecondID and dwType2 then
		self:ResetNpcState(dwSecondID,dwType2)
	end
end

------------------------------------------------------------------------
--							摄像机拉近动画
------------------------------------------------------------------------

local tLookPos = _Vector3.new()
local tEyePos = _Vector3.new()
local storyZoomInDis = 20
local storyZoomInTime = 300
local storyZoomOutTime = 500
local storyZoomPauseTime = 2200
--[[
--摄像机拉近动画
@para zoomInDis拉近距离20,
@para zoomInTime拉近时间300,
@para zoomOutTime暂停2200,
@para zoomPauseTime返回500
--]]
function StoryController:ZoomInCamera(zoomInDis,zoomInTime,zoomOutTime,zoomPauseTime)
	if self.isZoomPlaying then return end
	self.isZoomPlaying = true

	storyZoomInDis = zoomInDis or 20
	storyZoomInTime = zoomInTime or 300
	storyZoomOutTime = zoomOutTime or 500
	storyZoomPauseTime = zoomPauseTime or 2200

	tLookPos.x = _rd.camera.look.x
	tLookPos.y = _rd.camera.look.y
	tLookPos.z = _rd.camera.look.z

	tEyePos.x = _rd.camera.eye.x - storyZoomInDis
	tEyePos.y = _rd.camera.eye.y - storyZoomInDis
	tEyePos.z = _rd.camera.eye.z - storyZoomInDis

	CPlayerControl:MoveCameraPos(tLookPos, tEyePos, storyZoomInTime,
		function()
			self.timeId = TimerManager:RegisterTimer(function() self:ResetCamera()
												end,storyZoomPauseTime,1)
		end)
end

function StoryController:ZoomOutCamera(zoomInDis,zoomInTime)
	if self.isZoomPlaying then return end
	self.isZoomPlaying = true

	storyZoomInDis = zoomInDis or 20
	storyZoomInTime = zoomInTime or 300

	tLookPos.x = _rd.camera.look.x
	tLookPos.y = _rd.camera.look.y
	tLookPos.z = _rd.camera.look.z

	tEyePos.x = _rd.camera.eye.x + storyZoomInDis
	tEyePos.y = _rd.camera.eye.y + storyZoomInDis
	tEyePos.z = _rd.camera.eye.z + storyZoomInDis

	CPlayerControl:MoveCameraPos(tLookPos, tEyePos, storyZoomInTime)
end

function StoryController:ResetCamera(playTime)
	if self.timeId then
		TimerManager:UnRegisterTimer(self.timeId)
	end
	local ztime = playTime or storyZoomOutTime
	CPlayerControl:ResetCameraPos(ztime, function() self.isZoomPlaying = false end)
end

function StoryController:ResetCameraOldPos()
	if self.timeId then
		TimerManager:UnRegisterTimer(self.timeId)
	end
	CPlayerControl:ResetCameraOldPos()
	self.isZoomPlaying = false
end

------------------------------------------------------------------------
--							播放头顶冒泡
------------------------------------------------------------------------

function StoryController:ShowBubble(talkId, npc)
	if not talkId then
		UIRoleChat:Hide()
		return
	end
	local talkCfg = TalkStringConfig[toint(talkId)]
	if talkCfg then
		UIRoleChat:Set(talkCfg, npc)
	end
end

function StoryController:RemoveBubble()
	UIRoleChat:Hide()
end


------------------------------------------------------------------------
--							播放对话框类型的剧情
------------------------------------------------------------------------
function StoryController:ShowStoryDialog(dialogId)
	-- FPrint('剧情对话框'..dialogId)
	local playList = StoryDialogPlayList[toint(dialogId)]
	if not playList then return end
	if not playList[1] then return end
	local cfg = StoryDialogConfig[playList[1]]
	if not cfg then return end
	if cfg.isFloat then
		-- FPrint("播放对话框类型的剧情"..dialogId)
		UIFloat:ShowStoryActivity(cfg.talk)
	else
		UIStoryDialog:PlayStoryDialog(dialogId)
	end


end

function StoryController:ShowStartStoryDialog(dialogId, callBackFunc)
	-- FPrint('剧情对话框1')
	-- self.bOnStory = true;
	-- if self.questDelayTimeId then
		-- TimerManager:UnRegisterTimer(self.questDelayTimeId);
	-- end
	--锁玩家操作
	-- local player = MainPlayerController:GetPlayer()
	-- if player then
		-- MainPlayerController:StopMove()
	-- end
	-- UIStoryChapter:ShowChapter('createChapter', nil)
end
------------------------------------------------------------------------
--							播放场景中的寻路的剧情
------------------------------------------------------------------------
function StoryController:PlayNpcPatrolStory(storyId)
	-- FPrint('播放场景中的寻路的剧情')

	local StoryCfg = StoryConfig[CPlayerMap:GetCurMapID()]
	if not StoryCfg then
		FPrint('没有找到剧情配置文件'..storyId)
		return
	end
	if not StoryCfg[storyId] then
		FPrint('没有找到剧情配置文件'..storyId)
		return
	end

	if #StoryCfg[storyId] <= 0 then
		FPrint('剧情长度为0')
		return
	end

	local patrolID = StoryCfg[storyId][1].Patrol--npc移动
	if patrolID then
		-- NPC巡逻脚本
		local Patrol = PatrolConfig[patrolID]
		self.LastNpcPatrol = Patrol
		-- FTrace(Patrol)
		if Patrol and type(Patrol)=="table" then
			-- FPrint('NPC巡逻脚本')
			for k,v in pairs(Patrol) do
				-- FPrint('NPC巡逻脚本1')
				local NpcCfgId = v.npc
				local patrolIndex = v.index
				local NpcGId = v.gid
				-- FPrint('创建NPC巡逻'..NpcCfgId)
				local npc = StoryActionController:GetStoryNpc(NpcCfgId,NpcGId,v.bornX,v.bornY,v.dir,v.bornZ)
				if npc and v.index then
					npc:SetPatrol(StoryScriptManager:GetScript(NpcCfgId), patrolIndex, function()
						self:PlayNpcPatrolEnd()
					end)

					if v.talk then
						local talkCfg = TalkStringConfig[v.talk]
						if talkCfg then
							--FPrint('npc说话')
							UIRoleChat:Set(talkCfg, npc)
						end
					end
				end
				if npc and v.bornAct then
					npc:StoryAction(v.bornAct,v.bLoop)
				end
			end
		end
	end
end

function StoryController:PlayNpcPatrolEnd()
	StoryActionController:RemoveAllStoryNpc()
end

function StoryController:ResetQuestCamera()
	if not CPlayerMap.useBornCamera then
		return
	end
	local subVec = _Vector3.new()
	subVec.x = 80 subVec.y = 80 subVec.z = 100
	local mEye = _Vector3.add(_rd.camera.look, subVec)
	_rd.camera.eye = mEye
	CPlayerMap.useBornCamera = nil
end

function StoryController:IsStoryCamera()
	if self:IsStorying() then return true end
	if self.isZoomPlaying then return true end
	if self.isUseStoryCamera then return true end
	return false
end