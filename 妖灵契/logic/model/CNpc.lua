local CNpc = class("CNpc", CMapWalker)

function CNpc.ctor(self)
	CMapWalker.ctor(self)

	self.m_Eid = nil --场景中唯一的ID
	self.m_NpcAoi = nil	
	self.m_Actor:SetLocalRotation(Quaternion.Euler(0, 150, 0))
	self:SetCheckInScreen(true)	

	--常驻NPc动画相关
	self.m_TipsDialogueTime = 0
	self.m_TipsDialogueIntervalTime = 0
	self.m_DialogAnimationData = nil
	self.m_IsGroupNpc = false
	self.m_GroupNpcList = nil
	self.m_IsReady = false
	self.m_DoingDialogAni = false
	self.m_NpcId = nil

	--普通剧场动画相关
	self.m_DialogAnimationId = nil
end

function CNpc.OnTouch(self)
	-- TODO >>> 点到Npc
	CMapWalker.OnTouch(self, self.m_Eid)
	self:SetTouchTipsTag(1)
end

function CNpc.Trigger(self)
	if g_ConvoyCtrl:IsConvoying() then
		netnpc.C2GSClickConvoyNpc(self.m_NpcAoi.npcid)
	elseif g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSClickNpc"]) then
		netnpc.C2GSClickNpc(self.m_NpcAoi.npcid)	
	end
end

function CNpc.SetData(self, d)
	self.m_NpcAoi = d
	self.m_NpcId = self.m_NpcAoi.npcid	

	--魂匣npc，没到等级前先隐藏
	self:CheckHeroBoxNpc(self.m_NpcAoi.npctype)

	--刷新暗雷怪的时间
	if d.block and d.block.trapmine and next(d.block.trapmine) then
		self:SetAnLeiTimeHud(true, d.block.trapmine.create_time, d.block.trapmine.end_time)
	end

	local globalNpc = g_MapCtrl:GetGlobalNpc(self.m_NpcAoi.npctype)
	if globalNpc and  globalNpc.rotateY then
		self.m_Actor:SetLocalRotation(Quaternion.Euler(0, globalNpc.rotateY or 150, 0))
	else
		self.m_Actor:SetLocalRotation(Quaternion.Euler(0, 150, 0))
	end
	if globalNpc and globalNpc.dialogAnimationId and globalNpc.dialogAnimationId ~= "" then
		local id = 0
		local list = string.split(tostring(globalNpc.dialogAnimationId), ";")
		if list and #list > 0 then
			id = tonumber(table.randomvalue(list)) 
			g_DialogueAniCtrl:SetDialugeAniGroup(list)
		end
		local d = g_DialogueAniCtrl:GetFileData(id)
		if d and next(d.CONFIG) then
			--普通剧场
			if d.CONFIG.isStroy == 0 then
				self.m_DialogAnimationId = id
				g_DialogueAniCtrl:PlayDialgueAni(self.m_DialogAnimationId, self.m_NpcAoi.npctype)
				--下一帧，检测该NPC的剧情动画	
				local function cb()
					if not Utils.IsNil(self) then
						self.m_Actor:SetPos(Vector3.New(9999, 9999, 0))
						--self:SetSpecialTitleHud()
						self:DelHud("name")
						self:SetNeedShadow(false)
						self.m_Actor:SetColliderEnbled(false)
					end
				end
				Utils.AddTimer(cb, 0, 0)					

			--常驻NPC剧场
			elseif d.CONFIG.isStroy == 2 then
				--目前只支持冒泡说话，需要在加
				self.m_DialogAnimationData = g_DialogueAniCtrl:SpawnGlobalNpcDialogueAni(d)					
				--下一帧，检测该NPC的组合剧情动画	
				local function cb()
					if not Utils.IsNil(self) then
						self.m_IsReady = true
					end
				end
				Utils.AddTimer(cb, 0, 1)	
			end				
		end
	end
end

function CNpc.ReSetFace(self)
	if self.m_Actor then
		local globalNpc = g_MapCtrl:GetGlobalNpc(self.m_NpcAoi.npctype)
		if globalNpc and  globalNpc.rotateY then
			DOTween.DOLocalRotate(self.m_Actor.m_Transform, Vector3.New(0, globalNpc.rotateY, 0), 0.15)
		else
			DOTween.DOLocalRotate(self.m_Actor.m_Transform, Vector3.New(0, 150, 0), 0.15)
		end
	end
end

 function CNpc.CheckTipsDialgue(self, dt)
 	local d = self.m_DialogAnimationData
 	if d and self.m_IsReady == true then
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
	 				if d.cmdList[self.m_TipsDialogueTime] then
			 			for k, cmd in pairs(d.cmdList[self.m_TipsDialogueTime]) do			 				
			 				self:DialogNpcDoAnimation(cmd)
			 			end
	 				end
	 				self.m_TipsDialogueTime = self.m_TipsDialogueTime + define.Walker.Npc_Dialogue_Dalta_Time	 				
	 				self.m_TipsDialogueIntervalTime = self.m_TipsDialogueIntervalTime + define.Walker.Npc_Dialogue_Dalta_Time

	 				if self.m_TipsDialogueIntervalTime > d.interval_time then 			
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
function CNpc.CheckGroupNpc(self)
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
function CNpc.SetReadyAni(self, isStart)
	if isStart == true then
		self.m_IsReady = true		
	else
		self.m_IsReady = false	
	end
	self.m_TipsDialogueTime = 0
	self.m_TipsDialogueIntervalTime = 0
end

function CNpc.Destroy(self)
	if self.m_DialogAnimationId then
		g_DialogueAniCtrl:StopDialgueAni(self.dialogAnimationId, self.m_NpcAoi.npctype)
	end	
	CMapWalker.Destroy(self)
end

function CNpc.CheckHeroBoxNpc(self, npctype)
	if npctype == 70001 then
		if g_AttrCtrl.grade < data.globalcontroldata.GLOBAL_CONTROL.herobox.open_grade then
			self:SetActive(false)
			g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent"))
		end
	end
end

function CNpc.OnAttrEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		if oCtrl.m_EventData["dAttr"]["grade"] then
			self:SetActive(g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.herobox.open_grade)
		end
	end
end

return CNpc
