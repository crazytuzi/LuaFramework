local CHero = class("CHero", CMapWalker)
local tinsert = table.insert

function CHero.ctor(self)
	CMapWalker.ctor(self)
	self.m_Actor:SetPriorLoad(true)
	self.m_Pid = nil --角色ID
	self.m_Eid = nil --场景中唯一的ID
	self.m_Path = {}
	self.m_SavePath = {}
	self.m_WayPoint = Vector2.zero
	self.m_SyncPosTime = nil
	self.m_LastCheckTransferPos = nil
	self.m_IsPatroling = false
	self.m_PatrolIdleTime = 0
	self.m_Followers = {}
	self.m_SyncPosList = {}
	self.m_NextSyncPosQueue = nil
	self.m_LastSyncPos = nil
	self.m_CheckTimer = Utils.AddTimer(callback(self, "Check"), 0, 0)
	self.m_NormalSpeed = define.Walker.Move_Speed
	self.m_FastSpeed = self.m_NormalSpeed * 1.5
	self.m_FastTime = 2
	self:AddInitHud("patrol")
end

function CHero.Destroy(self)
	if self.m_CheckTimer then
		Utils.DelTimer(self.m_CheckTimer)
		self.m_CheckTimer = nil
	end
	CMapWalker.Destroy(self)
end

function CHero.OnTouch(self)
	--printc("点到自己")
end

function CHero.OnStartPath(self)
	CMapWalker.OnStartPath(self)
	self:SetMoveSpeed(self.m_NormalSpeed)
	self:StopDelayCall("FastSpeed")
	if not self:IsPatroling() and not g_TeamCtrl:IsJoinTeam() and not g_ConvoyCtrl:IsConvoying() then
		self:DelayCall(self.m_FastTime, "FastSpeed")
	end
end

function CHero.FastSpeed(self)
	self:SetMoveSpeed(self.m_FastSpeed)
end

function CHero.ClearPath(self)
	self:StopDelayCall("FastSpeed")
	self.m_SavePath = {}
end

function CHero.SyncCurPos(self)
	if not g_LoginCtrl:HasLoginRole() then
		print("SyncCurPos err: not login")
		return
	end
	local curHeroPos = self:GetPos()
	if curHeroPos.x > 0 and curHeroPos.y > 0 then	
		if self.m_LastSyncPos and self.m_LastSyncPos == curHeroPos then
			print("same sync pos")
			return
		end
		self.m_LastSyncPos = curHeroPos
		local curAngles = self.m_Actor:GetLocalEulerAngles()
		local dPosQueueInfo = {
				pos = netscene.EncodePos({
						x = curHeroPos.x,
						y = curHeroPos.y,
						face_x = curAngles.x < 0 and (curAngles.x+360) or curAngles.x,
						face_y = curAngles.y < 0 and (curAngles.y+360) or curAngles.y,
					}),
				time = 0,
			}
		if not g_AnLeiCtrl:IsTrust() then
			netscene.C2GSSyncPosQueue(g_MapCtrl:GetSceneID(), self.m_Eid, {dPosQueueInfo})
		end
	end
end

function CHero.SetSyncPosList(self, list)
	local pathlist = table.copy(list)
	self.m_SyncPosList = pathlist
	-- self:SyncPosQueue()
	
	if not self.m_NextSyncPosQueue then
		self.m_NextSyncPosQueue = g_TimeCtrl:GetTimeMS() + 1000
	end
end

function CHero.WalkToAndSyncPos(self, x, y, completeCb, startCb, walkconfig)
	self:WalkTo(x, y, completeCb, function(oHero)
		oHero:SetSyncPosList(oHero:GetPath())
		if startCb then
			startCb()
		end
	end, walkconfig)
end

function CHero.SyncPosQueue(self)
	if not g_LoginCtrl:HasLoginRole() then
		print("SyncPosQueue err: not login")
		return
	end
	if not self.m_SyncPosList then
		return
	end
	local iLen = #self.m_SyncPosList
	if iLen <0 then
		return
	end
	local vLastPos = nil
	local vStartPos = nil
	local lPosQueue = {}
	local iTotalDis = 0
	local iNextTime = 0
	local iRemoveCnt = 0
	local i = 1
	local iSpeed = self.m_Speed
	while i <= iLen do
		local vPos = self.m_SyncPosList[i]
		vPos.z = 0
		if vLastPos then
			local iPosDistance = Vector3.DistanceXY(vPos,vLastPos)
			if (iTotalDis + iPosDistance) > iSpeed then
				iNextTime = iNextTime + 1000
				local vLerpPos = Vector3.Lerp(vLastPos, vPos, (iSpeed-iTotalDis)/iPosDistance)
				tinsert(lPosQueue, self:GetPosQueueInfo(vStartPos, 1000))
				vStartPos, vLastPos = vLerpPos, vLerpPos
				tinsert(self.m_SyncPosList, i, vLerpPos)
				iLen = iLen + 1
				iTotalDis = 0
				iRemoveCnt = i - 1
			else
				iTotalDis = iTotalDis + iPosDistance
				vLastPos = vPos
				if i == iLen then
					local iTime = (iTotalDis/iSpeed * 1000)
					if iTime > 100 then
						tinsert(lPosQueue, self:GetPosQueueInfo(vStartPos, iTime))
					end
					if #lPosQueue > 0 then
						tinsert(lPosQueue, self:GetPosQueueInfo(vPos, 0))
					end
					iTotalDis = 0
					iNextTime = 0
				end
				iRemoveCnt = i
			end
		else
			vStartPos, vLastPos = vPos, vPos
			iRemoveCnt = i
		end
		i = i + 1
		if #lPosQueue >= 3 then
			if iNextTime ~= 0 then
				local dEndPos = lPosQueue[#lPosQueue].pos
				if Vector3.DistanceXY(Vector3.New(dEndPos.x, dEndPos.y, 0), vLastPos*1000) > 100 then
					tinsert(lPosQueue, self:GetPosQueueInfo(vLastPos, 0))
				end
			end
			break
		end
	end
	for j=1, iRemoveCnt do
		table.remove(self.m_SyncPosList, 1)
	end
	if iNextTime > 0 then
		self.m_NextSyncPosQueue = g_TimeCtrl:GetTimeMS() + iNextTime
	end
	if not g_AnLeiCtrl:IsTrust() then
		netscene.C2GSSyncPosQueue(g_MapCtrl:GetSceneID(), self.m_Eid, lPosQueue)
	end
end

function CHero.GetPosQueueInfo(self, vPos, time)
	return	{
			pos = netscene.EncodePos({
					x = math.max(0, vPos.x),
					y = math.max(0, vPos.y),
					face_x = 0,
					face_y = 0,
				}),
			time = time,
		}
end

function CHero.CheckTransfer(self)
	local curPos = self:GetPos()
	if self.m_LastCheckTransferPos == curPos then
		return
	end
	self.m_LastCheckTransferPos = curPos
	local id = g_MapCtrl:CheckTranserArea(curPos)
	if self.m_TransferID == id then
		return
	end
	self.m_TransferID = id
	if self.m_TransferID then
		self.m_LastCheckTransferPos = nil
		self:SyncPosQueue()
		--如果在修行中，则不会地图传送
		if g_ActivityCtrl:IsDailyCultivating() then
			return	
		end
		netscene.C2GSTransfer(g_MapCtrl.m_SceneID, self.m_Eid, self.m_TransferID)
	end
end

function CHero.ChangeFollow(self, oWalker, distance)
	CWalker.ChangeFollow(self, oWalker, distance)
	if oWalker then
		self.m_SyncPosTime = g_TimeCtrl:GetTimeMS() + 1000
	else
		self.m_SyncPosTime = nil
	end
	self:SetMoveSpeed(self.m_NormalSpeed)
	self:StopDelayCall("FastSpeed")
	self.m_SyncPosList = {}
	self.m_NextSyncPosQueue = nil
end

function CHero.Check(self, dt)
	if self.m_SyncPosTime and g_TimeCtrl:GetTimeMS() >= self.m_SyncPosTime then
		self.m_SyncPosTime = g_TimeCtrl:GetTimeMS() + 1000
		self:SyncCurPos()
	elseif self.m_NextSyncPosQueue and g_TimeCtrl:GetTimeMS() >= self.m_NextSyncPosQueue then
		self.m_NextSyncPosQueue = nil
		self:SyncPosQueue()
	end

	if not(self:IsCanWalk() and self:IsPatroling()) then
		self:CheckTransfer()
	end
	self:CheckPatrol(dt)
	return true
end

function CHero.CheckFlyMode(self)
	-- local oMainCam = g_CameraCtrl:GetMainCamera()
	-- local iSize = self.m_Actor:IsFly() and 4 or 3
	-- if oMainCam:GetOrthographicSize() ~= iSize then
	-- 	oMainCam:SetOrthographicSize(iSize)
	-- 	-- g_MapCtrl:ResetCameraMap()
	-- 	local iTag = self.m_Actor:IsFly() and enum.Seeker.TraversableTag.Sky or enum.Seeker.TraversableTag.BasicGround
	-- 	self.m_Walker:SetTraversableTags(iTag)
	-- end
end

function CHero.IsPatroling(self)
	return self.m_IsPatroling
end

function CHero.StartPatrol(self, isPatrolFree)
	if self:IsCanWalk() and not self:IsPatroling() then
		if isPatrolFree or g_MapCtrl:IsPatrolMap() then
			self:StopWalk()
			self.m_PatrolIdleTime = nil
			self.m_IsPatroling = true
			if g_AnLeiCtrl:IsInAnLei() then
				if not g_TeamCtrl:IsJoinTeam() or g_TeamCtrl:IsLeader() then
					self:AddBindObj("anleipatrol")
				end
			else
				self:AddBindObj("patrol")
			end
			g_MapCtrl:OnEvent(define.Map.Event.HeroPatrol, {bPatrol=true})
		end
	end
end

function CHero.StopPatrol(self)
	if self:IsPatroling() then
		self.m_IsPatroling = false
		self:DelBindObj("patrol")
		self:DelBindObj("anleipatrol")
		g_TaskCtrl:StopPatrolTask()
		g_MapCtrl:OnEvent(define.Map.Event.HeroPatrol, {bPatrol=false})
	end
end

function CHero.CheckPatrol(self, dt)
	if not self.m_IsPatroling then
		return
	end
	if not self:IsWalking() then 
		if self.m_PatrolIdleTime then
			self.m_PatrolIdleTime = self.m_PatrolIdleTime + dt
			if self.m_PatrolIdleTime >= define.MapWalker.Patrol_Idle_Time then
				self:PatrolNext()
			end
		else
			self:PatrolNext()
		end
	end
end

function CHero.PatrolNext(self)
	self.m_PatrolIdleTime = nil
	local pos = g_MapCtrl:GetPatrolPos()
	if not pos and not g_MapCtrl:IsPatrolMap() then
		pos = g_MapCtrl:GetRandomPos()
	end
	self:WalkToAndSyncPos(pos.x, pos.y)
end

function CHero.OnStopPath(self)
	self:SyncCurPos()
	self.m_PatrolIdleTime = 0
	self.m_SyncPosList = {}
	self.m_NextSyncPosQueue = nil
	g_GuideCtrl:CheckTaskNvGuide(true, false)
	CMapWalker.OnStopPath(self)
	self:SetMoveSpeed(self.m_NormalSpeed)
	self:StopDelayCall("FastSpeed")
end

function CHero.StopWalk(self)
	self:SyncCurPos()
	self.m_SyncPosList = {}
	self.m_NextSyncPosQueue = nil
	self:SetMoveSpeed(self.m_NormalSpeed)
	self:StopDelayCall("FastSpeed")
	g_TaskCtrl:StopWalingTask()
	CMapWalker.StopWalk(self)
end

function CHero.GetAoiState(self)
	local iState = 0
	if g_StateCtrl:GetState(1004) then
		iState = MathBit.orOp(iState, 1)
	end
	return iState
end

--PlayerAoiBlock中的state状态
function CHero.UpdateAoiState(self)
	local iState = self:GetAoiState()
	self:SetStateTag(iState)
end

function CHero.ShowLevelUpEffect(self)
	local function localcb(oEffect)
		if Utils.IsExist(self) then
			oEffect:SetParent(self.m_Actor.m_Transform)
		end
	end
	local oEffect = CEffect.New("Effect/Game/game_eff_1168/Prefabs/game_eff_1168.prefab", self.m_Layer, true, localcb)
	oEffect:AutoDestroy(2)
end

function CHero.SetLocalPos(self, v)
	CMapWalker.SetLocalPos(self, v)
	if not self.m_Is3D then
		g_MapCtrl:ResetMapCamera()
	end
end

function CHero.OnStartWalk(self, walkConfig)
	g_TaskCtrl:ReCheckGoToDoStoryTask()
	g_DialogueCtrl:ResetSocialDialogue()
	g_ActivityCtrl:CheckHeroStartWalk(walkConfig)
	CWalker.OnStartWalk(self)
end

function CHero.PlayAnim(self, sAnim, iNormaized)
	self.m_Actor:Play(sAnim, iNormaized)
end

return CHero