-- 巡逻控制器
-- ly
_G.PatrolController = {}

function PatrolController:New(player, patrolData, npcId)
	local obj = {}
	setmetatable(obj, {__index = PatrolController})
	
	obj.NpcPatrolIndex = nil
	obj.dwStep = 1
	obj.bIsMoving = false
	obj.dwStopTime = 0
	
	obj.player = player
	obj.avatar = player:GetAvatar()
	obj.Patrol = patrolData
	obj.npcId = npcId
	obj.endCallBackFunc = nil
	return obj
end

--巡逻结束播放动作
function PatrolController:Play(animaID,bPause)
	--FPrint("巡逻结束播放动作Npc:Play(animaID,bPause),  dwAnimaID:"..animaID)
	local bPause = bPause
	local f = nil
	if bPause then
		f = function(avatar,objanim)
			CTimer:AddTimer(1,false,function() 
				avatar.stoping = true
			end)
		end
	else
		f = function(avatar,objanim)
			if avatar.stoping then
				CTimer:AddTimer(1,false,function() avatar:ExecIdleAction() end)
			end
		end
	end
	
	self.avatar:DoAction(animaID,false,f)
end

-- 寻路
function PatrolController:UpdatePatrol()
	if self.NpcPatrolIndex then
		local cfg = self.Patrol[self.NpcPatrolIndex]
		if not cfg then return end
		--FPrint('巡逻脚本执行到步骤2')
		if self.bIsMoving then return end
		--FPrint('巡逻脚本执行到步骤3')
		
		local stepVO = cfg[self.dwStep]
		local MyPos = self.avatar:GetPos()
		if stepVO and stepVO.npcStay then
			if GetCurTime() - self.dwStopTime < stepVO.npcStay then
				return
			end
		end
		if (stepVO.x-MyPos.x)^2 + (stepVO.y-MyPos.y)^2 < 3 then
			self.dwStep = self.dwStep + 1
		end
		if (not stepVO) or (self.dwStep>#cfg) then
			
			if cfg.bLoop then
				self.dwStep = 1
				return
			end
			
			if self.Patrol.bLoop then
				-- self.NpcPatrolIndex = self.Patrol.dwDefault
				-- FPrint("循环播放"..self.NpcPatrolIndex)
				self.dwStep = 1 
				-- if self.endCallBackFunc then
					-- CStory.LastMyPatrol = nil
					-- self.endCallBackFunc()
					-- self.endCallBackFunc = nil
				-- end
				return
			end
			-- FPrint('巡逻脚本执行完')
			-- self.avatar:ExecIdleAction()
			self.NpcPatrolIndex = nil
			self.dwStep = 1 
			if self.endCallBackFunc then
				CStory.LastMyPatrol = nil
				self.endCallBackFunc()
				self.endCallBackFunc = nil
			end
			return
		end
		--FPrint('巡逻脚本执行到步骤4')
		local vecTargetPos = _Vector3.new(stepVO.x,stepVO.y,0)
		self.bIsMoving = true
		self.avatar:ExecMoveAction()
		local curStep = self.dwStep
		self.avatar:MoveTo(vecTargetPos,function() 
			self:Stop(curStep) 
		end,stepVO.speed, nil, true)	
		-- 开始移动时执行的操作
		self:Start(stepVO)
	end
end

-- 巡逻开始时执行的操作
function PatrolController:Start(stepVO)
	-- 停掉所有动作 并朝一个方向
	if stepVO.bstopAllAct then
		if stepVO.dir then
			self.avatar:SetDirValue(stepVO.dir)
		end
	end
end

-- 巡逻停止时执行的操作
function PatrolController:Stop(dwStep)
	-- FPrint("巡逻停止，Step:"..dwStep)
	self.dwStopTime = GetCurTime()
	
	
	local cfg = self.Patrol[self.NpcPatrolIndex]
	if not cfg then return end
	
	local Step = cfg[dwStep]
	-- FTrace(Step, '巡逻停止')
	if not Step then return end
	-- print(debug.traceback())
	-- FPrint(dwStep..":"..#cfg)
	-- if dwStep>=#cfg then
		-- FPrint('巡逻停止时执行待机')
		-- self.avatar:ExecIdleAction()
	-- end
	
	self.avatar.useStoryPosZ = Step.useStoryPosZ
	-- npc动作
	if Step.npcActId and Step.npcActId~='' and self.npcId then
		--FPrint('巡逻停止，播放Npc动作,动作id:'..Step.npcActId)
		if Step.npcActId == 'idle' then
			self.avatar:ExecIdleAction()
		else
			local actionName = self:GetActionIdByName(Step.npcActId, self.npcId)
			if actionName and actionName ~= "" then
				self.avatar:DoAction(actionName, Step.bActLoop, function() self.avatar:ExecIdleAction() end)
			end
		end
	end
	
	-- 玩家动作
	if Step.MyActId then
		--FPrint('巡逻停止，播放玩家动作：'..Step.MyActId)
		self.avatar:StopAllAction()
		StoryActionController:DoStoryAction(Step.MyActId, self.player, Step.bMyActLoop)
	end
	
	-- 玩家朝向
	if Step.dir then
		--FPrint("巡逻停止，Step.dir"..Step.dir)
		self.avatar:SetDirValue(Step.dir)
	end
	
	-- 场景的特效
	if Step.sceneEffect then
		--FPrint('巡逻停止，剧情场景的特效')
		StoryActionController:PlayStorySceneEffect(Step.sceneEffect, Step.sceneEffectPos)
	end
	
	-- 人物的特效
	if Step.playerEffect then
		--FPrint('巡逻停止，剧情主角的特效')
		StoryActionController:PlayStoryRoleEffect(Step.playerEffect, self.avatar)
	end
	self.bIsMoving=false
	
end

--设置巡逻路径
function PatrolController:SetRun(patrolIndex,dwStep,endCallBackFunc)
	
	self.dwStep = dwStep or 1
	local cfg = self.Patrol[patrolIndex]
	if not cfg then FPrint('没有找到巡逻的配置文件'..patrolIndex) return end
	local stepVO = cfg[self.dwStep]
	if stepVO.mountID then
		local mountId = toint(stepVO.mountID[MainPlayerModel.sMeShowInfo.dwProf])
		--FPrint('坐骑id:'..mountId)
		if mountId and mountId > 0 then
			self.avatar:SetMount(mountId);
		end
	end
	
	self.avatar.useStoryPosZ = stepVO.useStoryPosZ
	self.avatar.RotateTime = stepVO.RotateTime or _G.CAvatar.defaultRotateTime
	
	-- 位置动作
	local szMoveAction = self.avatar.szMoveAction
	if szMoveAction and szMoveAction ~= '' then
		self.avatar:ExecMoveAction()
	end
	self.endCallBackFunc = endCallBackFunc
	-- FPrint("设置巡逻路径PatrolIndex"..self.NpcPatrolIndex..'step'..self.dwStep)
	self.dwStep = dwStep or 1
	self.NpcPatrolIndex = patrolIndex
end

--快进巡逻
function PatrolController:ClearPatrol(dwPatrolIndex)
	self.NpcPatrolIndex = nil
	self.bIsMoving=false
	local cfg = self.Patrol[dwPatrolIndex]
	if not cfg then return end
	-- print(debug.traceback())
	local Step = cfg[#cfg]
	local x = Step.x
	local y = Step.y
	--FPrint('快进巡逻')
	self.avatar.useStoryPosZ = nil
	self.avatar.RotateTime = _G.CAvatar.defaultRotateTime
	self.avatar:StopMove(_Vector3.new(x,y,0))
	self.avatar:SetPos(_Vector3.new(x,y,0))
	if Step.dir then
		self.avatar:SetDirValue(Step.dir)
	end
end

function PatrolController:destroy()
	self.NpcPatrolIndex = nil
	self.dwStep = 1
	self.bIsMoving = false
	self.dwStopTime = 0
	self.avatar.useStoryPosZ = nil
	self.avatar.RotateTime = _G.CAvatar.defaultRotateTime
	self.avatar = nil
	self.Patrol = nil
	self.npcId = nil
	self.endCallBackFunc = nil
end

function PatrolController:GetActionIdByName(actionName)
	local cfgNpc = t_npc[self.npcId]
	if not cfgNpc then
		Error("don't exist this npc npcId" .. self.npcId)
		return
	end

	local model = t_model[cfgNpc.look]
	if not model then
		Error("don't exist this npc model" .. cfgNpc.look)
		return
	end

	return model["san_" .. actionName]
end