local CTraceNpc = class("CTraceNpc", CMapWalker)

CTraceNpc.Trace_Distance = 1
CTraceNpc.Trace_Distance_Max = 2
CTraceNpc.Rest_Time_Max = 30

CTraceNpc.State = 
{
	Wait = 1,
	Trace = 2,
}

function CTraceNpc.ctor(self)
	CMapWalker.ctor(self)
	self.m_ClientNpc = nil
	self.m_Follower = nil
	self.m_TraceTimer = nil
	self.m_NextDo = nil

	self.m_LastSendTime = 0
	self.m_State = CTraceNpc.State.Wait
end

function CTraceNpc.SetData(self, clientNpc)
	self.m_ClientNpc = clientNpc
	local taskNpc = g_TaskCtrl:GetTaskNpc(clientNpc.npctype)
	self.m_Actor:SetLocalRotation(Quaternion.Euler(0, taskNpc.rotateY or 150, 0))
	local oHero = g_MapCtrl:GetHero()
	if oHero then
		if g_TaskCtrl:IsDoingTraceTask() == self.m_ClientNpc.npctype then
			local function wrap()			
				if not Utils.IsNil(self) then
					self:SetFollow(true)	
				end
			end
			Utils.AddTimer(wrap,0, 0.5)
		else
			local function wrap()
				local oView = CDialogueMainView:GetView()
				if not Utils.IsNil(self) and oView then
					if oView.m_DialogData.npc_name == self.m_ClientNpc.name then
						self:FaceToHero()
					end			
				end
			end
			Utils.AddTimer(wrap,0, 0)
		end
	else
		self:DoNext()	
	end 	
	local cb = function ()
		if not Utils.IsNil(self) then
			self:CheckSyncPos(true)	
		end		
	end
	Utils.AddTimer(cb, 0, 0)
end

function CTraceNpc.DoNext(self)
	if self.m_State == CTraceNpc.State.Wait then
		if self.m_Follower then
			self.m_State = CTraceNpc.State.Trace
		end
	elseif self.m_State == CTraceNpc.State.Trace then
		if not self.m_Follower then
			self:CheckSyncPos(true)
			self.m_State = CTraceNpc.State.Wait
		end
	end

	if self.m_TraceTimer then
		Utils.DelTimer(self.m_TraceTimer)
		self.m_TraceTimer = nil
	end

	if self.m_State == CTraceNpc.State.Trace then
		local nextDo = self:GetNextDo()
		if nextDo then
			if nextDo.type == "walk" then
				self.m_TraceTimer = Utils.AddTimer(callback(self, "TraceUpdate"), 0.1, 0)		
				self:WalkTo(nextDo.pos_info.x , nextDo.pos_info.y, callback(self, "DoNext"))
				printc(" 开始移动", nextDo.pos_info.x, nextDo.pos_info.y)

			elseif nextDo.type == "switch_map" then
				local function wrap()	
					local oHero = g_MapCtrl:GetHero()	
					if not Utils.IsNil(self) and oHero then
						netscene.C2GSTransfer(g_MapCtrl:GetSceneID(), oHero.m_Eid, nextDo.transfer.id)
					end
				end
				g_TaskCtrl:SetTraceSwitchMap(true)
				Utils.AddTimer(wrap, 0, 0.5)
				printc(" 切换地图")
			elseif nextDo.type == "fly_switch_map" then
				local mapId = nextDo.transfer.map_id
				local function wrap()	
					local oHero = g_MapCtrl:GetHero()	
					if not Utils.IsNil(self) and oHero then
						netscene.C2GSClickWorldMap(g_MapCtrl:GetSceneID(), oHero.m_Eid, mapId)						
					end
				end
				g_TaskCtrl:SetTraceSwitchMap(true)
				Utils.AddTimer(wrap, 0, 0.5)
				printc(" 飞行地图")

			elseif nextDo.type == "compelete" then
				--提交任务
				printc(" 提交任务")
				if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSClickTask"]) then
					nettask.C2GSClickTask(self.m_ClientNpc.taskId)
				end
				self:FaceToHero()
			end
		end
	end
end

function CTraceNpc.TraceUpdate(self, dt)
	local isJoinTeam = g_TeamCtrl:IsJoinTeam()
	local isInTeam = g_TeamCtrl:IsInTeam()
	local isLeader = g_TeamCtrl:IsLeader()

	if isJoinTeam and isInTeam and not isLeader then
		self.m_Follower = nil
		self.m_State = CTraceNpc.State.Wait
		self:StopWalk()
		g_TaskCtrl:SetDoingTraceTask()
		self:SyncPos()
		return false		
	else
		self:CheckSyncPos()
		return true
	end		
end

function CTraceNpc.GetNextDo(self)
	local t = {}
	local curMap = g_MapCtrl:GetMapID()
	local pos = self:GetPos()
	local target = self.m_ClientNpc.target	
	if curMap == target.map_id then	
		local tPos = {}	
		tPos.x = (target.pos_info.x / 1000)
		tPos.y = (target.pos_info.y / 1000)	
		if UITools.CheckInDistanceXY(pos, tPos, 0.2) then
			t.type = "compelete"
			self:SetFollow(false)
			self:SyncPos()
		else			
			t.type = "walk"
			t.pos_info = {}
			t.pos_info.x = tPos.x
			t.pos_info.y = tPos.y
		end
	else
		local oTask = g_TaskCtrl:GetTaskById(self.m_ClientNpc.taskId) 
		if oTask then
			--暂时屏蔽走传
			if false and oTask:GetValue("autotype") == 2 then
				local info = g_MapCtrl:GetMapAToMapBPath(curMap, target.map_id)
				if #info > 1 then
					local tPos = {}
					tPos.x = info[1].x
					tPos.y = info[1].y
					if UITools.CheckInDistanceXY(pos, tPos, 0.2) then
						t.type = "switch_map"
						t.transfer = {}
						t.transfer.id = info[1].transferId
						t.transfer.map_id = info[2].map_id
						t.transfer.target_x = info[1].target_x
						t.transfer.target_y = info[1].target_y
						self:SyncPos(t.transfer)
					else
						t.type = "walk"
						t.pos_info = {}
						t.pos_info.x = tPos.x
						t.pos_info.y = tPos.y				
					end					
				end				
			else
				t.type = "fly_switch_map"
				local info = data.mapdata.MAP_SCENEFLY[target.map_id]
				if info then
					t.transfer = {}
					t.transfer.map_id = target.map_id
					t.transfer.target_x = info.pos[1]
					t.transfer.target_y = info.pos[2]
					self:SyncPos(t.transfer)
				end				
			end
		end
	end
	return t
end


function CTraceNpc.OnTouch(self)
	CMapWalker.OnTouch(self, self.m_ClientNpc.npcid)
end

function CTraceNpc.Trigger(self)
	self:SetFollow(true)
end

function CTraceNpc.SetFollow(self, isFollow)
	local oHero = g_MapCtrl:GetHero()
	if not oHero then
		return
	end
	if isFollow then
		if oHero:IsCanWalk() then
			oHero:ChangeFollow(self, CTraceNpc.Trace_Distance)
			self.m_Follower = oHero
			g_TaskCtrl:SetDoingTraceTask(self.m_ClientNpc.npctype)
		end
	else
		oHero:ChangeFollow()
		self.m_Follower = nil
		oHero:StopWalk()
		self:StopWalk()
		g_TaskCtrl:SetDoingTraceTask()
	end
	self:DoNext()
end

function CTraceNpc.CheckSyncPos(self, bForceSync)
	if bForceSync or self.m_LastSendTime >= 20 then
		self:SyncPos()
		self.m_LastSendTime = 0
	else
		self.m_LastSendTime = self.m_LastSendTime + 1
	end
end

function CTraceNpc.SyncPos(self, tPos)	
	if self.m_ClientNpc and self.m_ClientNpc.taskId then
		local curPos = {}
		local curMap 
		if tPos then			
			curMap = tPos.map_id 
			curPos.x = tPos.target_x
			curPos.y = tPos.target_y
		else
			local pos = self:GetPos()
			local map = g_MapCtrl:GetMapID()
			curMap = map
			curPos.x = math.floor(pos.x * 10) / 10
			curPos.y = math.floor(pos.y * 10) / 10 
		end
		nettask.C2GSSyncTraceInfo(self.m_ClientNpc.taskId, curMap, curPos.x * 1000, curPos.y * 1000)
		local oTask = g_TaskCtrl:GetTaskById(self.m_ClientNpc.taskId)
		if oTask then
			local traceinfo = oTask:GetValue("traceinfo")
			traceinfo.cur_mapid = curMap
			traceinfo.cur_posx = curPos.x
			traceinfo.cur_posy = curPos.y
		end
		-- table.print(curPos)
		-- table.print(oTask)
	end	
end

function CTraceNpc.Destroy(self)
	if self.m_TraceTimer then
		Utils.DelTimer(self.m_TraceTimer)
		self.m_TraceTimer = nil
	end
	CMapWalker.Destroy(self)
end

function CTraceNpc.SendMessage(self, msg)
	local oMsg = CChatMsg.New(1,  {channel = 4, text = msg})
	self:ChatMsg(oMsg)
end

--异常切换地图时，保存坐标
function CTraceNpc.SyncPosWhenOtherSwitchMap(self)
	if self.m_ClientNpc and self.m_ClientNpc.taskId then
		local oTask = g_TaskCtrl:GetTaskById(self.m_ClientNpc.taskId)
		if oTask then
			local traceinfo = oTask:GetValue("traceinfo")
			if traceinfo and traceinfo.cur_mapid then
				local curMap = traceinfo.cur_mapid
				local curPos = {}
				local pos = self:GetPos()
				curPos.x = math.floor(pos.x * 10) / 10
				curPos.y = math.floor(pos.y * 10) / 10 
				nettask.C2GSSyncTraceInfo(self.m_ClientNpc.taskId, curMap, curPos.x * 1000, curPos.y * 1000)
				traceinfo.cur_posx = curPos.x
				traceinfo.cur_posy = curPos.y
			end
		end
	end	
end

return CTraceNpc