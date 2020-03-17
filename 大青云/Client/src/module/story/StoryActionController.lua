--[[主角剧情动作
liyuan
2014年10月18日10:32:23
]]

_G.StoryActionController = {}

-- 一组动作
StoryActionController.animation_index = 1
StoryActionController.isPlayActGroup = true

-- 场景特效
StoryActionController.SceneEffectStr = 'StorySceneEffect_'
StoryActionController.StorySceneEffectDic = {}

-- 人物特效
StoryActionController.RoleEffectStr = 'StoryRoleEffect_'
StoryActionController.StoryRoleEffectDic = {}

--动态添加的npc
StoryActionController.StoryNpcIdList = {}  

StoryActionController.curTalkNpc = nil
StoryActionController.needResetOffsetPos = nil
---------------播主角的一组动作---------------------------------------------------

--计算动作ID
function StoryActionController:GetStoryAnimaFile(actId, profId)
	local result = tonumber(profId*100 + actId)
	-- FPrint('剧情动作id:'..result)
	
	if t_juqing_action[result] then
		return t_juqing_action[result].san
	end	
	
	return nil
end

--计算动作ID
function StoryActionController:GetStoryAnimaFileOld(actId, profId)
	local result = tonumber(profId*100 + actId)
	-- FPrint('剧情动作id:'..result)
	
	if t_juqing_actionOld[result] then
		-- FPrint(t_juqing_actionOld[result].san)
		return t_juqing_actionOld[result].san
	end	
	
	return nil
end

StoryActionController.delayActionDic = {}
StoryActionController.delayActionIndex = 1
StoryActionController.delayActionTimer = nil
function StoryActionController:ParseMainPlayerAction(actCfgId)
	local roleActCfg = NpcActConfig[actCfgId]
	self.delayActionDic = {}
	self.delayActionIndex = 1
	if roleActCfg then
		if #roleActCfg >= 1 then
			for k,v in pairs(roleActCfg) do
				local mainPlayer = nil
				if GameController.loginState then
					if v.loginPlayer then
						mainPlayer = CLoginScene:GetLoginPlayer(v.loginPlayer)
						
						if v.delay then
							table.push(self.delayActionDic, v)
						else
							if v.needIdle then
								self:ParsePlayerAction(mainPlayer,v,function()
								mainPlayer:GetAvatar():ExecIdleAction()
								end)
							elseif v.needHide then
								self:ParsePlayerAction(mainPlayer,v,function()
									mainPlayer:SetPlayVisible(false)
								end)		
							else
								self:ParsePlayerAction(mainPlayer,v)
							end							
						end
					end
				else
					mainPlayer = MainPlayerController:GetPlayer()
					self:ParsePlayerAction(mainPlayer,v)					
				end
				
			end
			if #self.delayActionDic > 0 then
				if GameController.loginState then
					self:DelayParsePlayerAction()
				end
			end
		else
			local mainPlayer = nil
			if GameController.loginState then
				if roleActCfg.loginPlayer then
					mainPlayer = CLoginScene:GetLoginPlayer(roleActCfg.loginPlayer)
				end
			else
				mainPlayer = MainPlayerController:GetPlayer()
				self:ParsePlayerAction(mainPlayer,roleActCfg)
			end
		end
	end
end


function StoryActionController:DelayParsePlayerAction()
	self:ClearDelayPlayerAction() 
	local actionCfg
	local playAct = function() 
		actionCfg = self.delayActionDic[self.delayActionIndex]
		if not actionCfg then 
			self:ClearDelayPlayerAction()
			return
		end
		
		local mainPlayer = CLoginScene:GetLoginPlayer(actionCfg.loginPlayer)
		mainPlayer:GetAvatar():StopAllAction()
		if actionCfg.needHide then
			self:ParsePlayerAction(mainPlayer,actionCfg,function()
				
				-- mainPlayer:SetPlayVisible(false)
			end)		
		else	
			self:ParsePlayerAction(mainPlayer,actionCfg,nil)
		end
		self.delayActionIndex = self.delayActionIndex + 1
	end
	playAct()
	self.delayActionTimer = TimerManager:RegisterTimer(function()
		playAct()
    end, actionCfg.delay, 3)
end

function StoryActionController:ClearDelayPlayerAction()
	if self.delayActionTimer then
		TimerManager:UnRegisterTimer(self.delayActionTimer)
		self.delayActionTimer = nil
	end
end

function StoryActionController:ParsePlayerAction(mainPlayer,roleActCfg,actEndFunc)
	local roleAvatar = mainPlayer:GetAvatar()
	
	if roleActCfg.AddCollection then
		local AddCollectionStr = roleActCfg.AddCollectionStr or ""
		UIMainZhuanshengProgress:Open(AddCollectionStr,roleActCfg.AddCollection)
	end	
	
	if roleActCfg.RemoveCollection then
		if UIMainZhuanshengProgress:IsShow() then 
			UIMainZhuanshengProgress:Hide();
		end;
	end	
	
	if roleActCfg.AddWing then
		StoryActionController:AddWing()
	end	

	if roleActCfg.RemoveWing then
		StoryActionController:RemoveWing()
	end		
	
	if roleActCfg.AddBinghun then
		StoryActionController:AddBinghun(roleActCfg.AddBinghun)
	end

	if roleActCfg.DeleteBinghun then
		StoryActionController:DeleteBinghun()
	end

	if roleActCfg.appSpeed then
		_app.speed = roleActCfg.appSpeed
	end

	if not roleActCfg.ShowWeapon then
		roleActCfg.ShowWeapon = true;
	end

	self:ShowWeapon(roleActCfg.ShowWeapon);

	if roleActCfg.acttype == StoryConsts.Offset then
		--FPrint('玩家剧情位移')
		if roleActCfg.playerActId then
			self:DoStoryAction(roleActCfg.playerActId, mainPlayer, roleActCfg.bActLoop, actEndFunc)
		end
		if roleActCfg.movoToDir then 
			roleAvatar:SetPlayerDirValue(roleActCfg.movoToDir)
		end
		self:DoMainPlayOffset(roleActCfg, mainPlayer)
	else
		-- FPrint('玩家剧情动作Id：'..roleActCfg.playerActId)
		if roleActCfg.movoToPos then 
			local posQiangzhi = QuestUtil:GetQuestPos(roleActCfg.movoToPos)
			roleAvatar:SetPlayerPosValue(posQiangzhi)
		end
		
		if roleActCfg.movoToDir then 
			roleAvatar:SetPlayerDirValue(roleActCfg.movoToDir)
		end
		
		if roleActCfg.mountID then
			local mountId = toint(roleActCfg.mountID[MainPlayerModel.sMeShowInfo.dwProf])
			if mountId and mountId > 0 then
				roleAvatar:SetMount(mountId);
			end
		end
		
		if roleActCfg.playerActId then
			self:DoStoryAction(roleActCfg.playerActId, mainPlayer, roleActCfg.bActLoop, actEndFunc)		
		end
		if roleActCfg.leisure then
			roleAvatar:PlayLeisureAction()
		end
		-- 主角的特效
		if roleActCfg.roleEffect then
			--FPrint('剧情主角的特效')
			self:PlayStoryRoleEffect(roleActCfg.roleEffect, roleAvatar)
		end
		
		-- FPrint('机关机关')
		-- FTrace(roleActCfg)
		if roleActCfg.jiguanId then
			-- FPrint('机关')
			if roleActCfg.jiguanId1 then
				local jiguan2Func = function()
					CPlayerMap.objSceneMap:PlayTaskAnima(roleActCfg.jiguanId1,roleActCfg.jiguanSan1,nil,roleActCfg.loop1)
				end
			
				CPlayerMap.objSceneMap:PlayTaskAnima(roleActCfg.jiguanId,roleActCfg.jiguanSan,jiguan2Func)
			else
				-- FPrint('机关1')
				CPlayerMap.objSceneMap:PlayTaskAnima(roleActCfg.jiguanId,roleActCfg.jiguanSan)
			end
		end
	end
	if roleActCfg.talk then
		local talkCfg = TalkStringConfig[roleActCfg.talk]
		if talkCfg then
			UIRoleChat:Set(talkCfg, mainPlayer)
		end
	end
	
	if roleActCfg.AddSpeedUpEffect then
		-- StorySpeedUpEffect:Show()
	end
	
	if roleActCfg.DelSpeedUpEffect then
		-- StorySpeedUpEffect:Hide()
	end
	
	-- if roleActCfg.loadAllLocalNpc then
		-- NpcController:LoadAllLocalNpc()
	-- end
end

-- 播放主角动作
function StoryActionController:DoStoryAction(actId, mainPlayer, isLoop, actEndFunc)
	if not mainPlayer then FPrint('找不到要播放动作的主角'..actId) return end
	local roleAvatar = mainPlayer:GetAvatar()
	if not roleAvatar then FPrint('找不到要播放动作的主角'..actId) return end
	if actId == StoryConsts.RoleIdleAct then
		roleAvatar:ExecIdleAction()
		return
	end

	local actFile = self:GetStoryAnimaFile(actId, roleAvatar.dwProfID)
	if actFile then
		--FPrint('播放主角动作')
		self.isPlayActGroup = false
		local animation = split(actFile, '#')
		if #animation > 1 then
			self.animation_index = 1
			self.isPlayActGroup = true
			self:PlayStoryActGroup(animation, roleAvatar, isLoop)
		else
			roleAvatar:PlaySkillAnima(actFile,isLoop,actEndFunc)
			if mainPlayer.SetPlayVisible then
				TimerManager:RegisterTimer(function()
					mainPlayer:SetPlayVisible(true)
				end, 200, 1)
			end

		end
	end
end

--播放主角一组动作
function StoryActionController:PlayStoryActGroup(animation, roleAvatar, isLoop)
	if self.animation_index > #animation then
		if isLoop then self.animation_index = 1	else return	end
	end
	
	local animaFile = animation[self.animation_index]
    roleAvatar:PlaySkillAnima(animaFile, false, function()
		-- print(debug.traceback())
		--FPrint('播放主角一组动作')
		if self.isPlayActGroup then
			self:PlayStoryActGroup(animation, roleAvatar, isLoop)
		end
	end)
	
	self.animation_index = self.animation_index + 1
end

---------------播NPC动作---------------------------------------------------

function StoryActionController:ParseStoryNpcAction(ActCfgId)
	-- npc动作
	local npcActCfg = NpcActConfig[ActCfgId]
	if npcActCfg then
		for k,v in pairs(npcActCfg) do
			local npc = nil
			if v.gid then
				npc = NpcModel:GetStoryNpc(v.gid)
			else
				npc = NpcModel:GetCurrNpcByNpcId(v.npc)
			end
			
			if npc then
				if v.acttype == StoryConsts.Offset then
					self:DoNPCOffset(v, npc)
				else
					if v.gid and v.isDelete then
						self:RemoveNpcByGid(v.gid)
					else
						if v.actId then
							npc:StoryAction(v.actId,v.bActLoop)
						end
						
						-- NPC的特效
						if v.roleEffect then
							self:PlayStoryRoleEffect(v.roleEffect, npc:GetAvatar())
						end
						
					end
				end
				if v.talk then
					local talkCfg = TalkStringConfig[v.talk]
					if talkCfg then
						UIRoleChat:Set(talkCfg, npc)
					end
				end
			else
				FTrace(v, 'npc不在范围内')
			end
		end
	end
end

---------------播放场景特效---------------------------------------------------
function StoryActionController:ParseSceneEffect(sceneEffectId)
	local sceneEffectCfg = StorySceneEffect[sceneEffectId]
	if sceneEffectCfg then
		for k,v in pairs (sceneEffectCfg) do
			self:PlayStorySceneEffect(v.effectName, {v.posX,v.posY,v.posZ}, k)
			-- FPrint('播放场景特效'..k)
		end
	else
		--FPrint('没有找到场景特效配置文件：'..sceneEffectId)
	end
	
end

local mat =_Matrix3D.new()

function StoryActionController:PlayStorySceneEffect(effectName, pos, index)
	local eName = self.SceneEffectStr .. effectName..index
	if GameController.loginState then
		local offsetZ = CLoginScene.objSceneMap:getSceneHeight(pos[1], pos[2])
		mat:setTranslation(_Vector3.new(pos[1], pos[2], pos[3] + offsetZ))
		local scenePfx = CLoginScene.objSceneMap:PlayerPfxByMat(eName, effectName, mat)
		if scenePfx then 
			 FPrint('播放场景特效成功'..eName) 
			 FTrace(pos)
			self.StorySceneEffectDic[eName] = scenePfx 
		end	
	else
		local offsetZ = CPlayerMap:GetSceneMap():getSceneHeight(pos[1], pos[2])
		mat:setTranslation(_Vector3.new(pos[1], pos[2], pos[3] + offsetZ))
		local scenePfx = CPlayerMap:GetSceneMap():PlayerPfxByMat(eName, effectName, mat)
		if scenePfx then 
			 FPrint('播放场景特效成功'..eName) 
			 FTrace(pos)
			self.StorySceneEffectDic[eName] = scenePfx 
		end
	end
	
end

function StoryActionController:StopStorySceneEffect(eName)
	if GameController.loginState then
		CLoginScene.objSceneMap:StopPfxByName(eName)
	else
		CPlayerMap:GetSceneMap():StopPfxByName(eName)
	end
end

function StoryActionController:StopAllStorySceneEffect()
	for k,v in pairs(self.StorySceneEffectDic) do
		self:StopStorySceneEffect(k)
		self.StorySceneEffectDic[k] = nil
	end
	
	self.StorySceneEffectDic = {}
end

---------------播放人物特效---------------------------------------------------

function StoryActionController:PlayStoryRoleEffect(effectName, roleAvatar)
	local eName = self.RoleEffectStr .. effectName
	local rolePfx = roleAvatar:PlayerPfxOnSkeleton(effectName)
	
	if rolePfx then 
		self.StoryRoleEffectDic[eName] = roleAvatar 
	end
end

function StoryActionController:StopStoryRoleEffect(eName, roleAvatar)
	roleAvatar:StopPfxByName(eName)
end

function StoryActionController:stopStoryRoleEffectByRoleAvatar(roleAvatar)
	for k,v in pairs(self.StoryRoleEffectDic) do
		if roleAvatar == v then
			self:StopStoryRoleEffect(k, v)
			self.StoryRoleEffectDic[k] = nil
			return
		end
	end
end

function StoryActionController:StopAllStoryRoleEffect()
	for k,v in pairs(self.StoryRoleEffectDic) do
		self:StopStoryRoleEffect(k, v)
		self.StoryRoleEffectDic[k] = nil
	end
	
	self.StoryRoleEffectDic = {}
end

------------------------------------刷Npc------------------------------------

--剧情npc
function StoryActionController:GetStoryNpc(npcId,NpcGId, bornX, bornY, faceto, bornZ)
	local npc = nil
	npc = NpcModel:GetStoryNpc(NpcGId)
	if npc then
		return npc
	end
	npc = NpcModel:GetCurrNpcByNpcId(npcId)
	if npc then
		return npc
	end
	
	if not NpcGId then return nil end
	
	local npcCfg = t_npc[npcId]
	-- FTrace(npcCfg)
	if npcCfg and npcCfg.type == StoryConsts.StoryNpcType then
		local npcInfo = {}
		npcInfo.configId = npcCfg.id
		npcInfo.gid = NpcGId
		npcInfo.x = bornX or 0
		npcInfo.y = bornY or 0
		npcInfo.offsetZ = bornZ or 0
		npcInfo.faceto = faceto or 0
		-- FPrint('添加npc'..NpcGId)
		NpcController:AddStoryNpc(npcInfo)
		self.StoryNpcIdList[npcInfo.gid] = npcInfo.gid
		return NpcModel:GetStoryNpc(npcInfo.gid)
	end

	return nil
end

function StoryActionController:RemoveNpc(key, gid)
	local Npc = NpcModel:GetStoryNpc(gid)
	local roleAvatar = Npc:GetAvatar()
	self:stopStoryRoleEffectByRoleAvatar(roleAvatar)
	
	if UIRoleChat.npcRole == Npc then
		UIRoleChat:Hide()
	end
	--FPrint('执行删除npc'..gid)
	NpcController:DeleteStoryNpc(gid)
	self.StoryNpcIdList[key] = nil
end

function StoryActionController:RemoveNpcByGid(gid)
	--FTrace(self.StoryNpcIdList, '删除npc前'..gid)
	if self.StoryNpcIdList then
		for i,v in pairs(self.StoryNpcIdList ) do
			if v == gid then
				self:RemoveNpc(i,v)
				--FTrace(self.StoryNpcIdList, '删除npc后'..gid)
				return
			end
		end
	end
end

function StoryActionController:RemoveAllStoryNpc()
	if self.StoryNpcIdList then
		for i,v in pairs(self.StoryNpcIdList ) do
			self:RemoveNpc(i,v)
		end
	end
	FTrace(self.StoryNpcIdList, '清空所有剧情NPC')
	NpcController:DeleteAllLocalNpc()
	self.StoryNpcIdList = {}
end

-------------------------------刷怪--------------------------------------------------
function StoryActionController:ParseRefreshMonster(monsterCfgId)
	local monsterIdList = StoryMonster[monsterCfgId]
	local cMapId = CPlayerMap:GetCurMapID()
	if monsterIdList and type(monsterIdList)=="table" and #monsterIdList > 0 then
		local monsteDic = MapPoint[cMapId].monster
		if monsteDic then
			for k,v in pairs(monsterIdList) do
				for mk,mv in pairs(monsteDic) do
					if v == mv.id then
						self:CreateSceneViewMonster(mk,mv.id, mv.x, mv.y, mv.dir)
					end
				end
			end
		end
	end
end

function StoryActionController:CreateSceneViewMonster(mId,configId, mX, mY, mDir)
	local monsterInfo = {}
	monsterInfo.configId = configId
	monsterInfo.mid = mId
	monsterInfo.x = mX or 0
	monsterInfo.y = mY or 0
	monsterInfo.dir = mDir or 0
	MonsterController:AddStoryMonster(monsterInfo)
end

function StoryActionController:DelSceneViewMonster()
	MonsterController:DeleteAllStoryMondter()
	--FPrint('清空所有剧情怪'..MonsterModel:GetStoryMonsterNum())
end

------------------------------位移-------------------------------------------------------
-- 主角位移
function StoryActionController:DoMainPlayOffset(offsetCfg, mainPlayer)
	local roleAvatar = mainPlayer:GetAvatar()
	-- 位移前动作
	if offsetCfg.offsetActStart then
		self:DoStoryAction(offsetCfg.offsetActStart, mainPlayer, offsetCfg.offsetActStartLoop)
	end
	
	-- 位移前人物特效
	if offsetCfg.offsetRoleEffectStart then
		self:PlayStoryRoleEffect(offsetCfg.offsetRoleEffectStart, roleAvatar)
	end
	
	self.needResetOffsetPos = true
	roleAvatar.objNode.transform:mulTranslationRight(offsetCfg.offsetPos[1], offsetCfg.offsetPos[2], offsetCfg.offsetPos[3], offsetCfg.offsetTime)
    TimerManager:RegisterTimer(function()
    	if not roleAvatar then return end
    	-- 位移后朝向
		if offsetCfg.dir then
			roleAvatar:SetDirValue(offsetCfg.dir)
		end
	
		-- 位移后动作
		if offsetCfg.offsetActEnd then
			self:DoStoryAction(offsetCfg.offsetActEnd, mainPlayer, offsetCfg.offsetActEndLoop)
		else
			-- roleAvatar:ExecIdleAction()
		end
		
		-- 位移后场景特效
        if offsetCfg.offsetSceneEffectEnd then
        	self:PlayStorySceneEffect(offsetCfg.offsetSceneEffectEnd, offsetCfg.offsetSceneEffectPos)
        end
    end, offsetCfg.offsetTime, 1)
end

function StoryActionController:ClearPlayerOffset()
	if not self.needResetOffsetPos then return end
	self.needResetOffsetPos = nil
	local selfPlayer = MainPlayerController:GetPlayer()
	local roleAvatar = nil
	if selfPlayer then 
		roleAvatar = selfPlayer:GetAvatar()
		if roleAvatar then
			roleAvatar.objNode.transform:identity()
		end
	end
	
	-- if GameController.loginState then
		-- for i = 1, 4 do
			-- local mainPlayer = CLoginScene:GetLoginPlayer(i)
			-- if mainPlayer then
				-- roleAvatar = mainPlayer:GetAvatar()
				-- if roleAvatar and roleAvatar.objNode then
					-- roleAvatar.objNode.transform:identity()
				-- end
			-- end
		-- end
	-- end
end

-- npc位移
function StoryActionController:DoNPCOffset(offsetCfg, npc)
	-- 位移前动作
	if offsetCfg.offsetActStart then
		--FPrint('播放Npc位移前动作动作')
		npc:StoryAction(offsetCfg.offsetActStart,offsetCfg.offsetActStartLoop)
	end
	
	-- 位移前人物特效
	if offsetCfg.offsetRoleEffectStart then
		self:PlayStoryRoleEffect(offsetCfg.offsetRoleEffectStart, npc:GetAvatar())
	end
	
	npc:GetAvatar().objNode.transform:mulTranslationRight(offsetCfg.offsetPos[1], offsetCfg.offsetPos[2], offsetCfg.offsetPos[3], offsetCfg.offsetTime)
    TimerManager:RegisterTimer(function()
    	if not npc then return end
    	if not npc:GetAvatar() then return end
		-- 位移后朝向
		if offsetCfg.dir then
			npc:GetAvatar():SetDirValue(offsetCfg.dir)
		end
	
		-- 位移后动作
		if offsetCfg.offsetActEnd then
			-- FPrint('播放Npc位移后动作')
			npc:StoryAction(offsetCfg.offsetActEnd,offsetCfg.offsetActEndLoop)
		else
			-- npc:GetAvatar():ExecIdleAction()
		end
		
		-- 位移后场景特效
        if offsetCfg.offsetSceneEffectEnd then
        	self:PlayStorySceneEffect(offsetCfg.offsetSceneEffectEnd, offsetCfg.offsetSceneEffectPos)
        end
    end, offsetCfg.offsetTime, 1)
end

function StoryActionController:AddWing()
	local selfPlayer = MainPlayerController:GetPlayer()
	local roleAvatar = selfPlayer:GetAvatar()
	local wingAvatar = WingAvatar:new(1)
    roleAvatar.objMesh:addSubMesh(wingAvatar.objMesh)
    roleAvatar.spiritsAvatar = wingAvatar
    wingAvatar:SetDefAction(roleAvatar)
end

function StoryActionController:RemoveWing()
	local selfPlayer = MainPlayerController:GetPlayer()
	if not selfPlayer then return end
	local roleAvatar = selfPlayer:GetAvatar()
	if roleAvatar.spiritsAvatar then
		roleAvatar.objMesh:delSubMesh(roleAvatar.spiritsAvatar.objMesh)
		roleAvatar.spiritsAvatar = nil
	end
end

function StoryActionController:Clear()
	self:DelSceneViewMonster()
	self:RemoveWing()
	self:DeleteBinghun()
	self:RemoveAllStoryNpc()
	self:ClearDelayPlayerAction()
	self:StopAllStorySceneEffect()
	self:StopAllStoryRoleEffect()
	if UIMainZhuanshengProgress:IsShow() then 
		UIMainZhuanshengProgress:Hide();
	end;
end

function StoryActionController:AddBinghun(binghunId)
	StoryActionController.binghunId = binghunId
	MainPlayerController:AddBinghun(binghunId)
end

function StoryActionController:DeleteBinghun()
	if not StoryActionController.binghunId then
		return
	end
	StoryActionController.binghunId = nil
	MainPlayerController:DeleteBinghun()
end

function StoryActionController:ShowWeapon(value)
	MainPlayerController:GetPlayer():GetAvatar():ChangeArms(not value);
end







