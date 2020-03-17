--[[剧情
liyuan
]]

_G.CStory = {}

function CStory:new()
	local obj = {}
	for k,v in pairs(CStory) do
		if type(v)=="function" then
			obj[k] = v
		end
	end
	obj.storyId = nil
	obj.Info = {}
	obj.dwLastTime = 0
	obj.eclipsTime = 0
	obj.playerDir = nil
	obj.playerPosX = nil
	obj.playerPosY = nil
	obj.playerPosZ = nil
	obj.needResetPlayerPos = false
	obj.LastNpcPatrol = nil
	obj.LastMyPatrol = nil
	obj.layuanDistance = 0
	obj.layuanSpeed = 0
	
	return obj
end
-- 自动结束

local lastEclipsTime = 0
function CStory:Update(dwInterval)
	if GameController.loginState == false then
		if GameController.currentState ~= enNormalUpdate then return end
	end
	if self.bGotoNextByMoveTime then return end
	if not self.dwLastTime then return end
	-- CameraControl:onUpdate( dwInterval )
	if self.dwLastTime == 0 then
		return
	end
	
	self.eclipsTime = self.eclipsTime + dwInterval
	if self.eclipsTime > self.dwLastTime then
		dwInterval = self.dwLastTime - lastEclipsTime
	end
	lastEclipsTime = lastEclipsTime + dwInterval
	if self.cameraRotateX and self.cameraRotateX ~= 0 then
		-- FPrint(dwInterval)
		local rotatePhi = self.cameraRotateX*dwInterval
		_rd.camera:movePhi(rotatePhi);
		self.Phi = self.Phi + rotatePhi
	end
	if self.cameraRotateY and self.cameraRotateY ~= 0 then
		local rotateTheta = self.cameraRotateY*dwInterval
		_rd.camera:moveTheta(rotateTheta);
		self.Theta = self.Theta + rotateTheta
	end
	
	if self.layuanSpeed and self.layuanSpeed ~= 0 then
		self.layuanDistance = self.layuanDistance + self.layuanSpeed*dwInterval
		_rd.camera.fov = _rd.camera.fov + self.layuanDistance
		-- FPrint('镜头拉远'..self.layuanDistance)
	end
	if self.eclipsTime > self.dwLastTime then
		-- FPrint("超过剧情最大时间")
		self.dwLastTime = 0
		self.eclipsTime = 0
		lastEclipsTime = 0
		StoryController:OnStoryFinish()
	end
end

-----------------------------------------
--载入剧情
local storyNum = 0
function CStory:LoadStory(dwStoryId)
	local StoryCfg = StoryConfig[CPlayerMap:GetCurMapID()]
	if not StoryCfg then
		FPrint('没有找到剧情配置文件1'..dwStoryId)
		return false
	end
	if StoryCfg[dwStoryId] then
		self.storyId = dwStoryId
		
		if #StoryCfg[dwStoryId] <= 0 then 
			FPrint('剧情长度为0')
			return false 
		end
		-- FPrint('载入剧情'..dwStoryId)
		self:SetMyLastPos()
		if self.Phi then
			-- FPrint('载入剧情Phi'..self.Phi)
		end
		if self.Theta then
			-- FPrint('载入剧情Theta'..self.Theta)
		end
		self.Phi = 0
		self.Theta = 0
		self.Info = {}
		storyNum = 0
		for k,v in pairs(StoryCfg[dwStoryId]) do
			self.Info[k] = {}
			self.Info[k].dwNpcId = v.npcId--npcid
			-- --FPrint("npcId"..v.NpcId)
			self.Info[k].dwStrId = v.talkStr--对白id
			self.Info[k].dwPos = v.pos--坐标
			self.Info[k].bCam = v.bCam--是否移动镜头
			self.Info[k].look = v.look--look点
			self.Info[k].eye = v.eye--eye点
			self.Info[k].tm = v.lastTime--移动过程时间
			self.Info[k].last = v.maxTime--最大时间
			self.Info[k].NpcPos = v.playerMovePos--玩家移动到的位置
			self.Info[k].autoCamaraTaget = v.autoCamaraTaget--自动镜头目标
			self.Info[k].dwPlayerActId = v.playerActId--玩家动作id
			self.Info[k].Patrol = v.Patrol--npc移动
			self.Info[k].MyPatrol = v.MyPatrol--npc移动
			self.Info[k].MonsterBorn = v.MonsterBorn--刷怪npc
			self.Info[k].bIsShowUI = v.bIsShowUI
			self.Info[k].NPCActCfg = v.NPCActCfg
			self.Info[k].shakeTime = v.shakeTime
			self.Info[k].shakeMin = v.shakeMin
			self.Info[k].shakeMax = v.shakeMax
			self.Info[k].sceneEffect = v.sceneEffect
			self.Info[k].bGotoNextByMoveTime = v.bGotoNextByMoveTime
			self.Info[k].FadeInTime = v.FadeInTime
			self.Info[k].FadeOutTime = v.FadeOutTime
			self.Info[k].soundID = v.soundID
			self.Info[k].bNext = v.bNext
			self.Info[k].bIsHideMain = v.bIsHideMain
			self.Info[k].bIsLock = v.bIsLock
			self.Info[k].bResetDirect = v.bResetDirect
			self.Info[k].bShowNpc = v.bShowNpc
			self.Info[k].bGensuiShijiao = v.bGensuiShijiao
			self.Info[k].cameraLookDif = v.cameraLookDif
			if v.cameraRotateX then
				self.Info[k].cameraRotateX = v.cameraRotateX/v.maxTime
			end
			if v.cameraRotateY then
				self.Info[k].cameraRotateY = v.cameraRotateY/v.maxTime
			end
			if v.cameraDistanceSpeed then
				self.Info[k].cameraDistanceSpeed = v.cameraDistanceSpeed/v.maxTime
			end
			self.Info[k].isResetRotate = v.isResetRotate
			self.Info[k].isResetDistance = v.isResetDistance
			storyNum = storyNum + 1
		end
		-- SpiritsUtil:Trace(StoryCfg[dwStoryId])
		return true
	else
		FPrint('没有找到剧情配置文件2'..dwStoryId)
		return false
	end
end

--播放下一条剧情
function CStory:NextStory(bNoUI)
	
	--FPrint(#self.Info)
	if self:IsStory() then
	--'--[[
		local storyIndex = storyNum - #self.Info + 1
		FPrint("开始播放剧情"..storyIndex)
		ClickLog:Send(ClickLog.T_Story_Step,self.storyId,storyIndex)--剧情步骤:param:剧情id,step
		CharController:HidePlayerAndMonster(self.Info[1].dwNpcId, self.Info[1].bShowNpc)
		CharController:HideDropItem()
		
		-- FTrace(self.Info[1])
		if storyIndex == 1 then
			-- FPrint("开始播放剧情Phi"..self.Phi)
			-- FPrint('开始播放剧情Theta'..self.Theta)
		end
		
		if self.Info[1].isResetRotate then
			self:ClearCameraRotate()
		end
		if self.Info[1].isResetDistance then
			self:ClearCameraFov()
		end
		
		-- 刷怪脚本
		if self.Info[1].MonsterBorn then
			-- FPrint('刷怪脚本')
			StoryActionController:ParseRefreshMonster(self.Info[1].MonsterBorn)
		end
		
		-- 转向npc并移动到与Npc对话的位置
		if self.Info[1].NpcPos then
			-- FPrint('转向npc并移动到与Npc对话的位置')
			self:TurnToNpc(toint(self.Info[1].NpcPos), toint(self.Info[1].dwNpcId))
		end
		
		
		-- NPC巡逻脚本
		local Patrol = PatrolConfig[self.Info[1].Patrol]
		self.LastNpcPatrol = Patrol
		-- FTrace(Patrol)
		if Patrol and type(Patrol)=="table" then
			-- FPrint('NPC巡逻脚本')
			for k,v in pairs(Patrol) do
				local NpcCfgId = v.npc
				if v.npc == 2031000 then 
					if StoryController.NpcId then
						NpcCfgId = StoryController.NpcId
					else
						NpcCfgId = 20310001
					end
				end
				local patrolIndex = v.index
				local NpcGId = v.gid
				local npc = StoryActionController:GetStoryNpc(NpcCfgId,NpcGId,v.bornX,v.bornY,v.dir,v.bornZ)
				if npc and v.index then
					npc:SetPatrol(StoryScriptManager:GetScript(NpcCfgId), patrolIndex)
				end
				if npc and v.bornAct then
					-- FPrint('NPC巡逻脚本1')
					-- npc:StoryAction('idle',true)
					npc:StoryAction(v.bornAct,v.bLoop)
				end
			end
		end
		
		-- 主角的巡逻脚本
		local MyPatrol = self.Info[1].MyPatrol
		-- FTrace(Patrol)
		if MyPatrol and MyPatrol > 0 then
			self.LastMyPatrol = MyPatrol
			-- FPrint('主角的巡逻脚本'..MyPatrol)
			local player = MainPlayerController:GetPlayer()
			if player then
				player:SetPatrol(StoryScriptManager:GetScript(1), MyPatrol)
			end
		end
		-- npc动作
		if self.Info[1].NPCActCfg then
			-- FPrint('npc动作'..self.Info[1].NPCActCfg)
			StoryActionController:ParseStoryNpcAction(self.Info[1].NPCActCfg)
		end
		
		-- 玩家动作
		if self.Info[1].dwPlayerActId then
			-- FPrint('玩家动作'..self.Info[1].dwPlayerActId)
			StoryActionController:ParseMainPlayerAction(self.Info[1].dwPlayerActId)
		end
		
		
		-- 场景的特效
		if self.Info[1].sceneEffect then
			-- FPrint('剧情场景的特效')
			StoryActionController:ParseSceneEffect(self.Info[1].sceneEffect)
		end
		
		-- 震屏
		if self.Info[1].shakeTime then
			-- FPrint('震屏')
			self:DoShake(self.Info[1])
		end
	
		if self.Info[1].soundID then
			local soundList = split(self.Info[1].soundID, ',')
			for k,v in pairs(soundList) do
				local storySound = toint(v)
				if storySound >= 20000 then
					local dwProf = MainPlayerModel.humanDetailInfo.eaProf
					storySound = storySound + dwProf
				end		
				local soundCfg = t_music[storySound]
				if soundCfg then
					if soundCfg.loop == 1 then
						SoundManager:PlayStoryBackSfx(storySound)
					else										
						FPrint('音效id'..storySound)
						SoundManager:PlaySfx(storySound);
					end
				end
			end
		end
		
		if self.Info[1].bIsHideMain then
			self:HideMainPlayer()
		else
			self:ShowMainPlayer()
		end

		
		-- 剧情UI
		self:SetUIStory(self.Info[1], storyIndex)
		-- FPrint('剧情UI')
	    --]]
		
		--[[
		local function tar( m )
			local playerPos =  MainPlayerController:GetPlayer():GetPos()
			local mat = _Matrix3D.new( )
			-- local _, __, mark = sceneMgr.getMarkerPos( me.sceneID, moviename.marker )
			-- mat:setRotation( mark.rot[1], mark.rot[2], mark.rot[3], mark.rot[4] )
			mat:mulTranslationRight( playerPos.x, playerPos.y, playerPos.z )
			
			return mat
		end
		
		local smcc = C_CameraSan.create( 'mov0_camera.san', tar, function() CameraControl:Clear() end)
		CameraControl:set( smcc )
		--]]
		-- 剧情最长时间 
		self.cameraRotateX = self.Info[1].cameraRotateX
		self.cameraRotateY = self.Info[1].cameraRotateY
		self.layuanSpeed = self.Info[1].cameraDistanceSpeed
		self.bGotoNextByMoveTime = self.Info[1].bGotoNextByMoveTime
		self.dwLastTime = self.Info[1].last
		table.remove(self.Info,1)
		return true
	else
		return false
	end
end

-- 剧情UI
function CStory:SetUIStory(stepVO,index)
	local cfg = t_npc[stepVO.dwNpcId] or {}
	local npcName = cfg.name or "" -- 剧情文字显示
	local npcTalkTxt = ""
	local playerName = ""
	
	local talkCfg = TalkStringConfig[stepVO.dwStrId]
	if talkCfg then
		npcTalkTxt = talkCfg.talk
	end
	
	if npcName == "" and npcTalkTxt ~= "" then
		local player = MainPlayerController:GetPlayer()
		if player then
			local eaZone = '%]'
			npcName = player:GetName()
			
			local startIndex,endIndex = string.find(npcName, eaZone)
			if endIndex then
				npcName = string.sub(npcName, endIndex+1, -1)
			end
		end
	end
	
	UIStory:SetStory(self.storyId, stepVO,npcName,npcTalkTxt,index)
end

-- 主角剧情前位置
function CStory:SetMyLastPos()
	if StoryController.noResetPos then return end

	local player =  MainPlayerController:GetPlayer()
	if not player then
		return
	end

	self.needResetPlayerPos = true
	
	if not self.playerDir then
		self.playerDir = MainPlayerController:GetPlayer():GetAvatar():GetPlayerDirValue()
	end
	local vecPos = MainPlayerController:GetPlayer():GetAvatar():GetPlayerPos()
	--FPrint(vecPos.x..':'..vecPos.y..':'..self.playerDir)
	self.playerPosX = vecPos.x
	self.playerPosY = vecPos.y
	self.playerPosZ = vecPos.z
	
	-- local q = QuestModel:GetTrunkQuest()
	-- if q then
		-- local cfg = q:GetCfg()
		-- local goalType = cfg and cfg.kind;
		-- if goalType == QuestConsts.GoalType_Potral then
			-- local g = q:GetGoal()
			-- local tx,ty = g:GetToPortalPos()
			-- if tx and ty then
				-- self.playerPosX = tx 
				-- self.playerPosY = ty
				-- self.playerPosZ = pos.z 
				-- FPrint(tx..'传送门的坐标'..ty)
			-- end
		-- end
	-- end
	
	if self.storyId and StoryChangePosCfg[self.storyId] then
		-- FPrint(StoryChangePosCfg[self.storyId].x..'直接传送的坐标'..StoryChangePosCfg[self.storyId].y)
		self.playerPosX = StoryChangePosCfg[self.storyId].x 
		self.playerPosY = StoryChangePosCfg[self.storyId].y
		self.playerDir = StoryChangePosCfg[self.storyId].dir
		if StoryChangePosCfg[self.storyId].noChangePos then
			StoryController.noResetPos = true
		end
	end
end

-- 面向npc
function CStory:TurnToNpc(npcPos, npcId)
	local player =  MainPlayerController:GetPlayer()
	if not player then
		return
	end

	local posQiangzhi = QuestUtil:GetQuestPos(npcPos)
	MainPlayerController:GetPlayer():GetAvatar():SetPlayerPosValue(posQiangzhi)
	
	if not npcId then return end
	local npc = NpcModel:GetCurrNpcByNpcId(npcId)
	
	if not npc then FPrint('npc不在范围内！！！') return end
	
    local pos1 = npc:GetPos()
    local pos = MainPlayerController:GetPlayer():GetAvatar():GetPlayerPos()
    local dir = GetDirTwoPoint(pos, pos1)
	
    MainPlayerController:GetPlayer():GetAvatar():SetPlayerDirValue(dir)
end

-- 还原主角位置和朝向
function CStory:ResetPosAndDir()
	if StoryController.noResetPos then 
		StoryController.noResetPos = false 
	else
		StoryActionController:ClearPlayerOffset()
		local player =  MainPlayerController:GetPlayer()
		if not player then
			return
		end

		if self.needResetPlayerPos and self.playerDir and self.playerPosX and self.playerPosY then
			self.needResetPlayerPos = false
			MainPlayerController:GetPlayer():GetAvatar():SetPlayerPosAndDir( _Vector3.new(self.playerPosX,self.playerPosY,self.playerPosZ), self.playerDir)
		end		
	end
	self.playerDir = nil
	self.playerPosX = nil
	self.playerPosY = nil
	self.playerPosZ = nil
end

--震动屏幕
function CStory:DoShake(shakeInfo)
	local shakeMin = shakeInfo.shakeMin or 1
	local shakeMax = shakeInfo.shakeMax or 1

	_rd.camera:shake(shakeMin,shakeMax,shakeInfo.shakeTime)
end

--当前是否有剧情
function CStory:IsStory()
	return (#self.Info > 0)
end

-- 清空
function CStory:Clear()

end

function CStory:End()
	self.dwLastTime = 0
	self.eclipsTime = 0
	self:ClearCameraRotate()
	self:ClearCameraFov()
	self:QuickPatrol()
	self:ShowMainPlayer()
	self:ResetPosAndDir()
end

function CStory:ClearCameraFov()
	self.layuanSpeed = 0 
	self.layuanDistance = 0
	_rd.camera.fov = StoryController.revordFov
end

function CStory:ClearCameraRotate()
	if self.Phi and self.Phi ~= 0 then
		self.cameraRotateX = 0
		_rd.camera:movePhi(-self.Phi);
		-- FPrint('旋转的角度X:'..self.Phi)
		self.Phi = 0
	end
	
	if self.Theta and self.Theta ~= 0 then
		self.cameraRotateY = 0
		_rd.camera:moveTheta(-self.Theta);
		-- FPrint('旋转的角度Y:'..self.Theta)
		self.Theta = 0
	end
end

function CStory:QuickPatrol()
	local Patrol = self.LastNpcPatrol
	if Patrol and type(Patrol)=="table" then
		for k,v in pairs(Patrol) do
			local npc = NpcModel:GetStoryNpc(v.gid)
			if npc and v.index and npc.PatrolController then
				npc.PatrolController:ClearPatrol(v.index)
			end
		end
	end
	
	local player =  MainPlayerController:GetPlayer()	
	if not player then
		return
	end
	local MyPatrol = self.LastMyPatrol
	if MyPatrol and MyPatrol > 0 and MainPlayerController:GetPlayer().PatrolController then
		MainPlayerController:GetPlayer().PatrolController:ClearPatrol(MyPatrol)
		self.LastMyPatrol = nil
	end
end

function CStory:ShowMainPlayer()
	--显示主玩家
	local selfPlayer = MainPlayerController:GetPlayer()
	if selfPlayer then
		local avatar = selfPlayer:GetAvatar()
		if avatar and avatar.objNode then
			avatar.objNode.visible = true
		end
	end
end

function CStory:HideMainPlayer()
	--隐藏主玩家
	local selfPlayer = MainPlayerController:GetPlayer()
	if selfPlayer then
		local avatar = selfPlayer:GetAvatar()
		if avatar and avatar.objNode then
			avatar.objNode.visible = false
		end
	end
	
end















