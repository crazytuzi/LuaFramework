local CDynamicNpc = class("CDynamicNpc", CMapWalker)

function CDynamicNpc.ctor(self)
	CMapWalker.ctor(self)

	self.m_ClientNpc = nil

	self.m_TipsDialogueTime = 0
	self.m_TipsDialogueIntervalTime = 0
	self.m_DialogAnimationData = nil
	self.m_IsGroupNpc = false
	self.m_GroupNpcList = nil
	self.m_IsReady = false
	self.m_DoingDialogAni = false
	self.m_AddEffData = nil
	self.m_IsAddDone = true
	self.m_FadeTimer = nil
	self.m_IsHide = false
	self.m_NpcId = nil
	self:SetCheckInScreen(true)
end

function CDynamicNpc.SetData(self, clientNpc)
	self.m_ClientNpc = clientNpc
	self.m_NpcId = self.m_ClientNpc.npcid
	if clientNpc.targetType then
		self.m_TargetType = CMapWalker.TARGET_TYPE.DAILY_TRAIN
	end
	local taskNpc = g_TaskCtrl:GetTaskNpc(clientNpc.npctype)
	self.m_Actor:SetLocalRotation(Quaternion.Euler(0, taskNpc.rotateY or 150, 0))
	if clientNpc and clientNpc.npctype then
		local d = data.npcdata.NPC.TEMP_NPC[clientNpc.npctype]
		if d and d.dialogAnimationId and data.npcdata.DIALOG_ANIMATION_CONFIG[d.dialogAnimationId] then
			self.m_DialogAnimationData = data.npcdata.DIALOG_ANIMATION_CONFIG[d.dialogAnimationId]
			self.m_DialogAnimationData.cmdList = g_DialogueCtrl:GetDialogAnimationCommand(self.m_DialogAnimationData.command)
			--下一帧，检测该NPC的组合剧情动画	
			local function cb()
				if not Utils.IsNil(self) then
					self:InitGroupNpc()
					self:CheckGroupNpc()
				end
			end
			Utils.AddTimer(cb, 0, 0)	
		else

		end			
		self.m_AddEffData = g_DialogueCtrl:GetDynamicNpcAddEffectData(clientNpc.npctype)	
		if self.m_AddEffData then			
			self.m_IsAddDone = false			
			if self.m_AddEffData.addEffectType ~= 4 then
				self:SetIgnoreUpdateTransparent(true)
				local cb = function ()
					self:SetVisible(false)
					if self.m_AddEffData.addEffectType == 3 then
						self:SetFadeIn()
					end
				end			
				Utils.AddTimer(cb, 0, 0)	
			end
		end
	end
end

function CDynamicNpc.OnTouch(self)
	-- TODO >>> 点到DynamicNpc
	CMapWalker.OnTouch(self, self.m_ClientNpc.npcid)
	self:SetTouchTipsTag(1)
end

function CDynamicNpc.Trigger(self)
	printc(" Trigger............ ", self.m_ClientNpc.npcid)
	table.print(self.m_ClientNpc)

	local npcid = self.m_ClientNpc.npcid
	local flag = self.m_ClientNpc.flag 

	if flag == 3 then
		g_ActivityCtrl:OpenReadyFightGuideMingLei()
	else
		local taskList = g_TaskCtrl:GetNpcAssociatedTaskList(npcid)
		if taskList and #taskList > 0 then			
			if #taskList == 1 and (taskList[1]:GetValue("tasktype") == define.Task.TaskType.TASK_PICK 
				or taskList[1]:GetValue("type") == define.Task.TaskCategory.SHIMEN.ID) then
				if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSClickTask"]) then
					nettask.C2GSClickTask(taskList[1]:GetValue("taskid"))
				end
			else
				-- 默认直接给他第一个任务的id
				if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSClickNpc"]) then
					netnpc.C2GSClickNpc(npcid)
				end
			end
		else
			--(贪玩童子，传说伙伴)
			if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSClickNpc"]) then
				netnpc.C2GSClickNpc(self.m_ClientNpc.npcid)
			end
		end	
	end
end

function CDynamicNpc.ReSetFace(self)
	if self.m_ClientNpc and self.m_Actor then
		local taskNpc = g_TaskCtrl:GetTaskNpc(self.m_ClientNpc.npctype)
		self.m_Actor:SetLocalRotation(Quaternion.Euler(0, taskNpc.rotateY or 150, 0))
	end	
end

 function CDynamicNpc.CheckTipsDialgue(self, dt)
 	local d = self.m_DialogAnimationData
 	if d then
 		if d.type == 1 then

			self.m_TipsDialogueTime = self.m_TipsDialogueTime + define.Walker.Npc_Dialogue_Dalta_Time
	 		if self.m_TipsDialogueTime > d.total_time + d.delay then 			
	 			self.m_TipsDialogueTime = 0
	 			if d.loop == 0 then
	 				self.m_DialogAnimationData = nil
	 				return
	 			end
	 		end
	 		if d.cmdList[self.m_TipsDialogueTime] then
	 			for k, cmd in pairs(d.cmdList[self.m_TipsDialogueTime]) do
	 				self:DialogNpcDoAnimation(k, cmd)
	 			end
	 		end

 		elseif d.type == 2 then
	 		local oHero = g_MapCtrl:GetHero()
	 		if oHero then

	 			local function CheckHeroPos()
	 				local b = false
	 				local oHero = g_MapCtrl:GetHero()
	 				if oHero then
	 					local HeroPos = oHero:GetPos()
			 			HeroPos.z = 0
			 			local MyPos = self:GetPos()
			 			MyPos.z = 0
			 			if UITools.CheckInDistanceXY(HeroPos, MyPos, d.distance) then
			 				b = true
			 			end
	 				end
	 				return b
	 			end

	 			if self.m_DoingDialogAni == false then
		 			self.m_DoingDialogAni = CheckHeroPos()
	 			end
	 				
	 			if self.m_DoingDialogAni == true then	 				
	 				self.m_TipsDialogueTime = self.m_TipsDialogueTime + define.Walker.Npc_Dialogue_Dalta_Time	 				
	 				self.m_TipsDialogueIntervalTime = self.m_TipsDialogueIntervalTime + define.Walker.Npc_Dialogue_Dalta_Time

	 				if self.m_TipsDialogueIntervalTime > d.total_time + d.interval_time then 			
			 			self.m_TipsDialogueTime = 0
			 			self.m_TipsDialogueIntervalTime = 0
			 			self.m_DoingDialogAni = CheckHeroPos() 
			 			if not self.m_DoingDialogAni then
			 				self:ReSetFace()
			 			end
			 			if d.loop == 0 then
			 				self.m_DialogAnimationData = nil
			 				return
			 			end
		 			end

	 				if d.cmdList[self.m_TipsDialogueTime] then
			 			for k, cmd in pairs(d.cmdList[self.m_TipsDialogueTime]) do
			 				self:DialogNpcDoAnimation(k, cmd)
			 			end
	 				end

	 				if d.alway_feceto_hero == 1 then
	 					self:FaceToHero()
	 				end
	 			end
	 		end
 		end 	
 	end
 end

 --初始化组合剧情动画
function CNpc.InitGroupNpc(self)
	local d = self.m_DialogAnimationData
	if d then
		if d.group and d.group ~= "" then
			self.m_IsGroupNpc = true
			self.m_GroupNpcList = {}
			local list = string.split(d.group, "|")
			if list and #list > 0 then
				for i = 1, #list do
					local info = string.split(list[i], ",")
					if info and #info == 2 then
						if info[1] == "g" then
							self.m_GroupNpcList.global = self.m_GroupNpcList.global or {}
							table.insert(self.m_GroupNpcList.global, tonumber(info[2]))
						elseif info[1] == "d" then
							self.m_GroupNpcList.dynamic = self.m_GroupNpcList.dynamic or {}
							table.insert(self.m_GroupNpcList.dynamic, tonumber(info[2]))
						end
					end
				end
			end
		else
			self.m_IsGroupNpc = false
		end
	end
end

--若NPC是组合动画NPC，每当NPC被加载或则被释放时，重置动画状态
function CDynamicNpc.CheckGroupNpc(self)
	if self.m_IsGroupNpc == true then
		local isLoadDone = true
		local npcList = {}
		local global = self.m_GroupNpcList.global or {}
		local dynamic = self.m_GroupNpcList.dynamic or {}
		
		if #global > 0 then
			for i = 1, #global do				
				local npc = nil
				local gNpcPid = g_MapCtrl:GetNpcIdByNpcType(global[i])
				if gNpcPid then
					npc = g_MapCtrl:GetNpc(gNpcPid)
				end				
				if npc == nil then
					isLoadDone = false
					break
				else
					table.insert(npcList, npc) 
				end				
			end
		end

		if #dynamic > 0 then
			for i = 1, #dynamic do				
				local npc = nil
				local dNpcPid = g_MapCtrl:GetNpcIdByNpcType(dynamic[i])
				if dNpcPid then
					npc = g_MapCtrl:GetDynamicNpc(gNpcPid)
				end				
				if npc == nil then
					isLoadDone = false
					break
				else
					table.insert(npcList, npc) 
				end				
			end
		end

		if isLoadDone == true then
			--printc("  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  所有的演员已经准备完毕")
			if npcList and next(npcList) then
				for i = 1, #npcList do
					npcList[i]:SetReadyAni(true)
				end
			end
		else
			--printc("  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  等待其他演员准备就绪")			
			if npcList and next(npcList) then
				for i = 1, #npcList do
					npcList[i]:SetReadyAni(false)
				end
			end
		end	
	else
		self:SetReadyAni(true)
	end
end

--激活/暂停组合动画
function CDynamicNpc.SetReadyAni(self, isStart)
	if isStart == true then
		self.m_IsReady = true		
	else
		self.m_IsReady = false	
	end
	self.m_TipsDialogueTime = 0
	self.m_TipsDialogueIntervalTime = 0
end

function CDynamicNpc.Destroy(self)
	if self.m_FadeTimer then
		Utils.DelTimer(self.m_FadeTimer)
		self.m_FadeTimer = nil
	end	
	self:CheckGroupNpc()
	---self:SetFadeOutDestroy()
	--淡出后再删除
	CMapWalker.Destroy(self)
end

function CDynamicNpc.SetVisible(self, b, ignoreName)
	if not self.m_Actor then
		return
	end
	self.m_Actor:SetActive(b)
	self.m_Actor:SetColliderEnbled(b)	
	self:SetNeedShadow(b)	
	if b == false or ignoreName == true then
		self:SetSocialEmoji()
		self:SetTaskMark()
		self:SetNameHud("")
	else
		self:SetNameHud(string.format("[FF00FF]%s", self.m_Name))
	end
end

function CDynamicNpc.SetTransparent(self, alpha)
	if not Utils.IsNil(self) then
		self.m_Walker:SetTransparent(alpha)
	end
end

function CDynamicNpc.SetFadeIn(self, config)
	if not config then
		if self.m_IsAddDone == true then		
			return
		else
			self.m_IsAddDone = true
		end
	end
	self.m_IsHide = false
	self:SetVisible(true, true)
	self:SetTransparent(0)
	if self.m_FadeTimer then
		Utils.DelTimer(self.m_FadeTimer)
		self.m_FadeTimer = nil
	end
	local time = 1
	local fadeTime = 0
	local cb = function (dt)
		if Utils.IsNil(self) then
			return false
		end
		fadeTime = fadeTime + dt
		local a = fadeTime / time 
		a = math.floor(a * 10) / 10 
		if a > 1 then
			a = 1
		end
		self:SetTransparent(a)
		if fadeTime >= time then
			self:SetIgnoreUpdateTransparent(false)
			self:SetNameHud(string.format("[FF00FF]%s", self.m_Name))
			if config and config.m_Cb1 then
				config.m_Cb1()
			end
			return false
		end
		return true	
	end
	self.m_FadeTimer = Utils.AddTimer(cb, 0, 0)
end

function CDynamicNpc.SetFadeOutDestroy(self)	
	if self.m_Actor:GetActive() == false then
		CMapWalker.Destroy(self)
		return
	end
	if self.m_FadeTimer then
		Utils.DelTimer(self.m_FadeTimer)
		self.m_FadeTimer = nil
	end		
	self:SetVisible(true, true)
	self:SetIgnoreUpdateTransparent(true)
	self:SetTransparent(1)
	local time = 1
	local fadeTime = 0
	local cb = function (dt)
		if Utils.IsNil(self) then
			return false
		end
		fadeTime = fadeTime + dt
		local a = 1 - fadeTime / time 
		a = math.floor(a * 10) / 10 
		if a < 0 then
			a = 0
		end
		self:SetTransparent(a)
		if fadeTime >= time then			
			CMapWalker.Destroy(self)
			return false
		end
		return true	
	end
	self.m_FadeTimer = Utils.AddTimer(cb, 0, 0)
	g_DialogueCtrl:DestroyDynamicEffect(self)
end


function CDynamicNpc.AddWalkEffect(self )
	if not self.m_AddEffData or self.m_AddEffData.addEffectConfig == "" then
		return
	end

	local list = string.split(self.m_AddEffData.addEffectConfig, ",")
	if #list < 5 then
		return
	end
	if self.m_IsAddDone == true then
		return
	end
	self.m_IsAddDone = true

	local x1 = tonumber(list[1])
	local y1 = tonumber(list[2])
	local x2 = tonumber(list[3])
	local y2 = tonumber(list[4])
	local rotateY = tonumber(list[5])
	self:SetLocalPos(Vector3.New(x1, y1, 0))
	local cb2 = function ()
		if not Utils.IsNil(self) then
			self.m_Actor:SetLocalRotation(Quaternion.Euler(0, rotateY or 150, 0))
		end
	end
	local cb1 = function ()
		if not Utils.IsNil(self) then
			self:WalkTo(x2, y2, cb2)
		end
	end
	local config = {}
	config.m_Cb1 = cb1
	config.m_Cb2 = cb2
	self:SetFadeIn(config)
end

function CDynamicNpc.SetIgnoreUpdateTransparent(self, b)
	self.m_Walker:SetIgnoreUpdateTransparent(b)
end

function CDynamicNpc.SetFadeOutUnActive(self)	
	if self.m_Actor:GetActive() == false then
		CMapWalker.Destroy(self)
		return
	end
	if self.m_FadeTimer then
		Utils.DelTimer(self.m_FadeTimer)
		self.m_FadeTimer = nil
	end		
	self:SetVisible(true, true)
	self:SetIgnoreUpdateTransparent(true)
	self:SetTransparent(1)
	local time = 1
	local fadeTime = 0
	local cb = function (dt)
		if Utils.IsNil(self) then
			return false
		end
		fadeTime = fadeTime + dt
		local a = 1 - fadeTime / time 
		a = math.floor(a * 10) / 10 
		if a < 0 then
			a = 0
		end
		self:SetTransparent(a)
		if fadeTime >= time then			
			self.m_IsHide = true
			self:SetVisible(false, true)
			return false
		end
		return true	
	end
	self.m_FadeTimer = Utils.AddTimer(cb, 0, 0)
	g_DialogueCtrl:DestroyDynamicEffect(self)
end

function CDynamicNpc.DoSocialAction(self)
	if self.m_AddEffData and self.m_AddEffData.addEffectType == 4 and self.m_IsAddDone == false then
		local id = tonumber(self.m_AddEffData.addEffectConfig) 
		if id then
			local socialData = data.socialitydata.DATA[id]
			if socialData then
				self.m_SocialTarget1 = g_MapCtrl:GetHero()
				self.m_SocialTarget2 = self
				local oTarget1 = self.m_SocialTarget1
				local oTarget2 = self.m_SocialTarget2
				if not Utils.IsNil(oTarget1) and not Utils.IsNil(oTarget2) and not Utils.IsNil(oTarget1.m_Actor) and not Utils.IsNil(oTarget2.m_Actor) then										
					local taskNpc = g_TaskCtrl:GetTaskNpc(self.m_ClientNpc.npctype)
					g_DialogueCtrl:CaCheSocialDialogue({oRotaY = oTarget1.m_Actor:GetRotation().eulerAngles.y, tPid = self.m_NpcId, tRotaY = taskNpc.rotateY or 150, tPos = oTarget2:GetPos() })					
					if socialData.target_action ~= "" then
						oTarget2:SetPos(oTarget1:GetPos())	
					end					
					Utils.AddTimer(callback(self, "DoSocial"), 0, 0.3)
				end
			end
		end
	end
end

function CDynamicNpc.DoSocial(self)
	local oTarget1 = self.m_SocialTarget1
	local oTarget2 = self.m_SocialTarget2	
	if self.m_AddEffData and not Utils.IsNil(oTarget1) and not Utils.IsNil(oTarget2) and not Utils.IsNil(oTarget1.m_Actor) and not Utils.IsNil(oTarget2.m_Actor) then
		local socialData = data.socialitydata.DATA[tonumber(self.m_AddEffData.addEffectConfig) 	]
		if socialData then				
			self.m_IsAddDone = true
			if socialData.target_action ~= "" then
				oTarget1.m_Actor:SetLocalRotation(Quaternion.Euler(0, socialData.rotate_y, 0))
				oTarget2.m_Actor:SetLocalRotation(Quaternion.Euler(0, socialData.rotate_y, 0))													
				oTarget1:PlaySociaty(socialData.action, 0, oTarget2.m_Pid)
				oTarget2:PlaySociaty(socialData.target_action, 0, oTarget1.m_Pid)	
			else				
				oTarget2:PlaySociaty(socialData.target_action, 0, 0)	
			end			
		end
	end
end

return CDynamicNpc