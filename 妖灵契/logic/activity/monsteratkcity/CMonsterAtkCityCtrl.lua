local CMonsterAtkCityCtrl = class("CMonsterAtkCityCtrl", CCtrlBase)

function CMonsterAtkCityCtrl.ctor(self, cb)
	CCtrlBase.ctor(self)
	self:ResetCtrl()
end

function CMonsterAtkCityCtrl.ResetCtrl(self)
	self.m_MonsterInfos = {}
	self.m_MyRankInfo = {} --自己的信息
	self.m_DefendCur = 0
	self.m_DefendMax = 0
	self.m_BossHP = 0
	self.m_BossHPMax = 0
	self.m_NextTime = 0
	self.m_CurWave = 0
	self.m_Open = nil
	self.m_EndTime = 0
	self.m_MSBossWarEnd = nil
	self.m_MaportalEff = nil
	self.m_Yure = nil
	self:ClearMaportalEff()
end

function CMonsterAtkCityCtrl.AddMonsterNpc(self, npcinfo)
	g_MapCtrl:AddMonsterNpc(npcinfo)
end

function CMonsterAtkCityCtrl.DelMonsterNpc(self, npcid)
	g_MapCtrl:DelMonsterNpc(npcid)
end

function CMonsterAtkCityCtrl.RefreshBossNpcBlood(self)
	for k,oMonsterNpc in pairs(g_MapCtrl.m_MonsterNpcs) do
		if oMonsterNpc.m_NpcAoi.npctype == "large" then
			oMonsterNpc:SetBlood(self.m_BossHP / self.m_BossHPMax)
		end
	end
end

function CMonsterAtkCityCtrl.GetMonsterNpc(self, npcid)
	return g_MapCtrl:GetMonsterNpc(npcid)
end

function CMonsterAtkCityCtrl.AddMonsterInfo(self, npcinfo)
	--if self.m_MonsterInfos[npcinfo.npcid] then
	--	printc("怪物攻城NPC已存在, 刷新npc："..npcinfo.npcid)
	--end
	self.m_MonsterInfos[npcinfo.npcid] = npcinfo
	self:CreateMonsterNpc(npcinfo)
	self:OnEvent(define.MonsterAtkCity.Event.AddMonster, npcinfo.npcid)
end

function CMonsterAtkCityCtrl.DelMonsterInfo(self, npcid)
	self:DelMonsterNpc(npcid)
	self.m_MonsterInfos[npcid] = nil
	self:OnEvent(define.MonsterAtkCity.Event.DelMonster, npcid)
end

function CMonsterAtkCityCtrl.DelMonsterInfos(self, idlist)
	for i,npcid in ipairs(idlist) do
		self:DelMonsterInfo(npcid)
	end
end

function CMonsterAtkCityCtrl.GetMonsterInfo(self, npcid)
	return self.m_MonsterInfos[npcid]
end

function CMonsterAtkCityCtrl.GetMonsterInfos(self)
	return self.m_MonsterInfos
end

function CMonsterAtkCityCtrl.GetMonsterAliveTime(self, npcid)
	local disInfo = self:GetMonsterDisInfo(npcid)
	local time = disInfo.time
	return time
end

function CMonsterAtkCityCtrl.LoginMonsterInfo(self, npcinfo)
	local id
	for k,v in pairs(npcinfo) do
		id = v.npcid
		self.m_MonsterInfos[id] = v
	end
	self:RefreshMonsterNpc()
end

function CMonsterAtkCityCtrl.RefreshMonsterNpc(self)
	local function refresh()
		for _,v in pairs(self.m_MonsterInfos) do
			self:CreateMonsterNpc(v)	
		end	
	end
	if g_MapCtrl:IsLoading() or not g_MapCtrl:GetCurMapObj() then
		local function delay()
			if Utils.IsNil(self) then
				return
			end
			if g_MapCtrl:IsLoading() then
				return true
			end
			refresh()
			return
		end
		Utils.AddTimer(delay, 0.5, 0.5)
	else
		refresh()
	end
end

function CMonsterAtkCityCtrl.RefreshMonsterAll(self)
	self:RefreshMaportalEff()
	self:RefreshMonsterNpc()
end

function CMonsterAtkCityCtrl.CreateMonsterNpc(self, npcinfo)
	local oMonsterNpc = self:GetMonsterNpc(npcinfo.npcid)
	if oMonsterNpc then
		oMonsterNpc:SetData(npcinfo)
		oMonsterNpc:SetMonsterAtkCityTag(npcinfo)
		if oMonsterNpc.m_NpcAoi.npctype == "large" then
			oMonsterNpc:SetBlood(self.m_BossHP / self.m_BossHPMax)
		end
	else
		if npcinfo.map_id == g_MapCtrl:GetMapID() and npcinfo.sceneid == g_MapCtrl:GetSceneID() then
			local pathid = npcinfo.path_id
			local dData = data.msattackdata.PathConfig[pathid]
			if not dData then
				return
			end
			local alive_time = dData.alive_time
			if g_TimeCtrl:GetTimeS() - npcinfo.createtime <= alive_time then
				--需要判断有没有超过时间，超过则不需要实例化
				self:AddMonsterNpc(npcinfo)
				self:MonsterWalkTo(npcinfo.npcid)
			end
		end	
	end
end

function CMonsterAtkCityCtrl.MonsterWalkTo(self, npcid)
	local monsterInfo = self:GetMonsterInfo(npcid)
	local pathid = monsterInfo.path_id
	local dData = data.msattackdata.PathConfig[pathid]
	if not dData then
		printc("警告：没有怪物攻城路径：", monsterInfo.map_id)
		return
	end
	local scene_path = dData.scene_path
	local alive_time = dData.alive_time
	local scene_speed = dData.scene_speed
	local interval = g_TimeCtrl:GetTimeS() - monsterInfo.createtime
	if interval < alive_time then
		local startPos, starIdx = self:GetStartPos(scene_path, interval)
		local oMonsterNpc = self:GetMonsterNpc(npcid)
		oMonsterNpc:SetPos(startPos)
		oMonsterNpc:SetMoveSpeed(scene_speed)
		oMonsterNpc.m_IdleActionName = oMonsterNpc.m_WalkActionName --避免WalkTo结束的时候播放idle动画
		self:CheckMonsterWalk(oMonsterNpc, starIdx, scene_path)
	end
end

function CMonsterAtkCityCtrl.CheckMonsterWalk(self, oMonsterNpc, starIdx, scene_path)
	if Utils.IsNil(oMonsterNpc) then
		return
	end
	starIdx = starIdx + 1
	if scene_path[starIdx] then
		self:MonsterWalk(oMonsterNpc, starIdx, scene_path)
	else
		if oMonsterNpc.m_NpcAoi.npctype == "large" then
			--自动徘徊
			starIdx = starIdx - 5
			self:MonsterWalk(oMonsterNpc, starIdx, scene_path)
		else
			self:DelMonsterInfo(oMonsterNpc.m_NpcId)
		end
	end
end

function CMonsterAtkCityCtrl.MonsterWalk(self, oMonsterNpc, starIdx, scene_path)
	local x = scene_path[starIdx].x
	local y = scene_path[starIdx].y
	oMonsterNpc:SetFace(x, y)
	oMonsterNpc:WalkTo(x, y, 
		callback(self, "CheckMonsterWalk", oMonsterNpc, starIdx, scene_path))
end

function CMonsterAtkCityCtrl.GetStartPos(self, l, v)
	local left = 1
	local right = #l
	local mid = math.ceil((left + right)/2)
	while left ~= mid do
		if l[mid].time == v then
			break
		elseif l[mid].time < v then
			left = mid + 1
		else
			right = mid - 1
		end
		mid = math.ceil((left + right)/2)
	end
	--[[
	local idx = mid
	local midabs = math.abs(l[mid].time - v)
	local lastabs = math.abs(l[math.max(mid-1, 1)].time - v)
	local nextabs = math.abs(l[math.min(mid+1, #l)].time - v)
	if midabs < lastabs and midabs < nextabs then
		idx = mid
	elseif lastabs < nextabs then
		idx = math.max(mid-1, 1)
	else
		idx = math.min(mid+1, #l)
	end
	]]
	return l[mid], mid
end

function CMonsterAtkCityCtrl.OnReceiveMsattackMyInfo(self, info)
	self.m_MyRankInfo = info
	self:OnEvent(define.MonsterAtkCity.Event.MyRank)
end

function CMonsterAtkCityCtrl.GetMyRankInfo(self)
	return self.m_MyRankInfo
end

function CMonsterAtkCityCtrl.OnReceiveMsattackInfo(self, type, list)
	--if type == define.MonsterAtkCity.RankType.RankPart then
	--	self:OnEvent(define.MonsterAtkCity.Event.Rank, {type = type, list = list})
	--elseif type == define.MonsterAtkCity.RankType.InfoPart then
	--	self:OnEvent(define.MonsterAtkCity.Event.Rank, {type = type, list = list})
	--end
	self:OnEvent(define.MonsterAtkCity.Event.Rank, {type = type, list = list})
end

function CMonsterAtkCityCtrl.OnReceiveCityDefend(self, open, defend, defend_max, nexttime, wave, endtime)
	local lastDefend = self.m_DefendCur
	self.m_DefendCur = defend or self.m_DefendCur
	self.m_DefendMax = defend_max or self.m_DefendMax
	self.m_NextTime = nexttime or self.m_NextTime
	self.m_EndTime = endtime or 0
	local lastWave = self.m_CurWave
	self.m_CurWave = wave or self.m_CurWave
	if self.m_Open ~= open then
		self.m_Open = open
		self:RefreshMaportalEff()
		if not self:IsOpen() then
			self:ResetCtrl()
		end
		self:OnEvent(define.MonsterAtkCity.Event.Open)
	end
	if lastWave and lastWave ~= self.m_CurWave then
		self:OnEvent(define.MonsterAtkCity.Event.RefreshWave)
	end
	if defend and lastDefend ~= self.m_DefendCur then
		self:OnEvent(define.MonsterAtkCity.Event.CityDefend)
	end
end

function CMonsterAtkCityCtrl.OnReceiveMSBossHP(self, hp_max, hp)
	self.m_BossHP = hp or self.m_BossHP
	self.m_BossHPMax = hp_max or self.m_BossHPMax
	self:RefreshBossNpcBlood()
	self:DelayEvent(define.MonsterAtkCity.Event.RefreshHP)
end

--倒计时结束,客户端自行先清除一次
function CMonsterAtkCityCtrl.ClientClear(self)
	self:ResetCtrl()
	self:OnEvent(define.MonsterAtkCity.Event.Open)
	self:OnEvent(define.MonsterAtkCity.Event.CityDefend)
end

function CMonsterAtkCityCtrl.GetDefendValue(self)
	return self.m_DefendCur, self.m_DefendMax
end

function CMonsterAtkCityCtrl.IsOpen(self)
	return self.m_Open and self.m_Open == 1 and 
	g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.msattack.open_grade and
	data.globalcontroldata.GLOBAL_CONTROL.msattack.is_open == "y"
end

function CMonsterAtkCityCtrl.GetNextTime(self)
	return self.m_NextTime
end

function CMonsterAtkCityCtrl.GetWave(self)
	return self.m_CurWave or 0, tonumber(data.msattackdata.SUMWAVE)
end

function CMonsterAtkCityCtrl.GetLeftTimeTxt(self)
	if self.m_Open then
		local leftTime = self.m_EndTime - g_TimeCtrl:GetTimeS()
		if leftTime <= 0 then
			self:ClientClear()
			return nil
		end
		local hour = math.modf(leftTime / 3600)
		local min = math.modf((leftTime % 3600) / 60)
		local sec = leftTime % 60
		return string.format("%02d:%02d:%02d", hour, min, sec)
	end
end

function CMonsterAtkCityCtrl.OnReceiveMSBossWarEnd(self, hit, all_hit, hit_per, coin)
	--self.m_MSBossWarEnd = true
	local lContent = {
		[1] = string.format("本次讨伐造成伤害:%d", hit),
		[2] = string.format("今日讨伐总伤害:%d", all_hit),
		[3] = string.format("相当于boss血量:%d%%", hit_per),
	}
	g_WarCtrl:SetResultValue("content", lContent)
	g_WarCtrl:SetResultValue("bosscoin", coin)
end

function CMonsterAtkCityCtrl.ShowWarResult(self, oCmd)
	if self.m_MSBossWarEnd then
		if oCmd.win then
			CMonsterAtkCityResultView:ShowView(function(oView)
				oView:SetWarID(oCmd.war_id)
				oView:SetWin(true)
				oView:SetDelayCloseView()
				self.m_MSBossWarEnd = nil
			end)
		else
			CMonsterAtkCityResultView:ShowView(function(oView)
				oView:SetWarID(oCmd.war_id)
				oView:SetWin(false)
				oView:SetDelayCloseView()
				self.m_MSBossWarEnd = nil
			end)
		end
	else
		CWarResultView:ShowView(function(oView)
			oView:SetWarID(oCmd.war_id)
			oView:SetWin(oCmd.win)
			oView:SetDelayCloseView()
		end)
	end
end

function CMonsterAtkCityCtrl.RefreshMaportalEff(self)
	self:ClearMaportalEff()
	if self:IsOpen() then
		local dData = data.msattackdata.PathConfig
		local map_id = g_MapCtrl:GetMapID()
		local path
		for k,v in pairs(dData) do
			if v.map_id == map_id then
				path = v.scene_path
			end
		end
		local one = path and path[1]
		if one then
			local function localcb(oEffect)
				if Utils.IsExist(oEffect) then
					oEffect:SetPos(Vector3.New(one.x, one.y, 0))
				else
					oEffect:Destroy()
				end
			end
			self.m_MaportalEff = CEffect.New("Effect/Scene/portal/Prefabs/Maportal_01.prefab", 
				UnityEngine.LayerMask.NameToLayer("Default"), 
				false, 
				localcb)
		end
	end
end

function CMonsterAtkCityCtrl.ClearMaportalEff(self)
	if self.m_MaportalEff then
		self.m_MaportalEff:Destroy()
		self.m_MaportalEff = nil
	end
end

function CMonsterAtkCityCtrl.SetYure(self, starttime, endtime)
	self.m_Yure = {
		starttime = starttime,
		endtime = endtime,
	}
	self:OnEvent(define.MonsterAtkCity.Event.Yure)
end

function CMonsterAtkCityCtrl.IsYure(self)
	local b = false
	if self.m_Yure then
		local starttime = self.m_Yure.starttime
		local endtime = self.m_Yure.endtime
		local curtime = g_TimeCtrl:GetTimeS()
		b = curtime < starttime and not self:IsOpen()
	end
	return b
end

function CMonsterAtkCityCtrl.GetYureTxt(self)
	if self.m_Yure then
		local starttime = self.m_Yure.starttime
		local endtime = self.m_Yure.endtime
		local leftTime = starttime - g_TimeCtrl:GetTimeS()
		if leftTime <= 0 then
			self:ClientClear()
			return nil
		end
		local hour = math.modf(leftTime / 3600)
		local min = math.modf((leftTime % 3600) / 60)
		local sec = leftTime % 60
		return string.format("%02d:%02d:%02d", hour, min, sec)
	end
end

--region 方便策划导表

function CMonsterAtkCityCtrl.TestDaoBiao(self,x1,y1,x2,y2,speed)
	self.m_DaoBiao = {}
	x1 = x1 or 0
	y1 = y1 or 0
	x2 = x2 or 0
	y2 = y2 or 0
	local sceneid = g_MapCtrl:GetSceneID()
	local map_id = g_MapCtrl:GetMapID()
	local npcinfo = {
	    createtime = 1514465454,
	    map_id = map_id,
	    model_info = {
	      scale = 1,
	      shape = 404,
	    },
	    name = "怪物攻城",
	    npcid = 10000,
	    npctype = 63001,
	    pos_info = {
	      x = x1,
	      y = y1,
	    },
	    sceneid = sceneid,
	}
	self:AddMonsterNpc(npcinfo)
	local monster = self:GetMonsterNpc(npcinfo.npcid)
	monster:SetMoveSpeed(speed or define.Walker.Move_Speed)--(define.Walker.Move_Speed * 0.1)
	monster:SetPos(Vector3.New(x1, y1, 0))
	local startCb = function (oMonster)
		self:SyncPosQueue(table.copy(oMonster:GetPath()), oMonster, npcinfo.npcid, speed)
		--oMonster:SetActive(false)
	end
	monster:WalkTo(x2, y2, nil, startCb)
end

function CMonsterAtkCityCtrl.SyncPosQueue(self, pathlist, oMonster, npcid, speed)
	if not pathlist then
		return
	end
	local iLen = #pathlist
	if iLen <0 then
		return
	end
	local vLastPos = nil
	local vStartPos = nil
	local lPosQueue = {}
	local iTotalDis = 0
	local iSumDis = 0 	--总路程
	local iSumTime = 0 	--总时间
	local iDefaultSpeed = speed 	--初速度
	local i = 1
	while i <= iLen do
		local vPos = pathlist[i]
		vPos.z = 0
		if vLastPos then
			local iPosDistance = Vector3.DistanceXY(vPos,vLastPos) --两点距离
			local iMorePosDis = iTotalDis + iPosDistance --相邻两点距离
			iSumDis = iSumDis + iPosDistance
			iSumTime = iSumDis / iDefaultSpeed
			if iMorePosDis > iDefaultSpeed then --define.Walker.Move_Speed
				local vLerpPos = Vector3.Lerp(vLastPos, vPos, (define.Walker.Move_Speed-iTotalDis)/iPosDistance)
				table.insert(lPosQueue, self:GetPosQueueInfo(vStartPos, iSumTime))
				vStartPos, vLastPos = vLerpPos, vLerpPos
				table.insert(pathlist, i, vLerpPos)
				iLen = iLen + 1
				iTotalDis = 0
			else
				iTotalDis = iTotalDis + iPosDistance
				vLastPos = vPos
				if i == iLen then
					table.insert(lPosQueue, self:GetPosQueueInfo(vStartPos, iSumTime))
					iTotalDis = 0
				end
			end
		else
			vStartPos, vLastPos = vPos, vPos
		end
		i = i + 1
	end
	local disInfo = {
		path = lPosQueue,
		time = iSumTime,
		dis = iSumDis,
	}
	self.m_DisInfo = disInfo
	table.print(disInfo,"路程信息：")
	for i,v in ipairs(disInfo.path) do
		self:AddTmpNpc(v.pos.x, v.pos.y, v.time, i)
	end
	--[[
	local dData = {}
	for _,v in pairs(disInfo.path) do
		v.pos.face_x = nil
		v.pos.face_y = nil
		v.pos.x = v.pos.x / 1000
		v.pos.y = v.pos.y / 1000
	end
	]]
	self:SaveFile(disInfo)
end

function CMonsterAtkCityCtrl.SaveFile(self, disInfo)
	local alive_time = "alive_time="..disInfo.time.."\n"
	local scene_dic = "scene_dic="..disInfo.dis.."\n"
	local spath = ""
	for i,v in ipairs(disInfo.path) do
		spath = spath..
			string.format("%0.3f", v.pos.x / 1000)
			.."|"..
			string.format("%0.3f", v.pos.y / 1000)
			.."|"..
			string.format("%0.3f", v.time)
			..","
	end
	local scene_path = "scene_path="..spath
	local s = "module(...)\n--MonsterAtkCity path build\n"..alive_time..scene_dic..scene_path
	local savePath = IOTools.GetAssetPath("/MonsterAtkCity/scene_path_"..g_MapCtrl:GetMapID())
	IOTools.SaveTextFile(savePath, s)
end

function CMonsterAtkCityCtrl.GetPosQueueInfo(self, vPos, time)
	return	{
			pos = netscene.EncodePos({
					x = vPos.x,
					y = vPos.y,
					face_x = 0,
					face_y = 0,
				}),
			time = time,
		}
end

function CMonsterAtkCityCtrl.AddTmpNpc(self, x, y, time, i)
	local sceneid = g_MapCtrl:GetSceneID()
	local map_id = g_MapCtrl:GetMapID()
	local npc = {
		idx = i,
	    createtime = time,
	    map_id = map_id,
	    model_info = {
	      scale = 1,
	      shape = 404,
	    },
	    name = "怪物攻城",
	    npcid = 10000*i,
	    npctype = 63001,
	    pos_info = {
	      x = x,
	      y = y,
	    },
	    sceneid = sceneid,
	}
	self.m_DaoBiao[npc.npcid] = npc
	self:AddMonsterNpc(npc)
	local oMonster = g_MapCtrl:GetMonsterNpc(npc.npcid)
	oMonster:SetPos(Vector3.New(x/1000, y/1000, 0))
end

--endregion 方便策划导表

return CMonsterAtkCityCtrl