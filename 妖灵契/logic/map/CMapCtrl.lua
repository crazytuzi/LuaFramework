local CMapCtrl = class("CMapCtrl", CCtrlBase, CDelayCallBase)

function CMapCtrl.ctor(self)
	CCtrlBase.ctor(self)
	CDelayCallBase.ctor(self)
	self.m_SameScreenHandler = CSameScreenHandler.New() --处理同屏人数
	self.m_LoadDoneCbList = {}
	self.m_HeroBoxRecords = {}
	self.m_ResID = nil
	self.m_LightID = nil
	self.m_Timer = Utils.AddTimer(callback(self, "Update"), 0.2, 0)

	--专门用来计算路径的walker
	local obj = UnityEngine.GameObject.Find("GameRoot/SeekWalker2D")
	self.m_SeekerWalker2DObj = CObject.New(obj)
	self.m_SeekerWalker2D = obj:GetComponent(classtype.Map2DWalker)
	self.m_SeekerWalker2D.moveTransform = self.m_SeekerWalker2DObj.m_Transform
	self.m_SeekerWalker2D:SetWalkStartCallback(callback(self, "OnStartPath"))

	local obj = UnityEngine.GameObject.Find("GameRoot/SeekWalker3D")
	self.m_SeekerWalker3DObj = CObject.New(obj)
	self.m_SeekerWalker3D = obj:GetComponent(classtype.Map3DWalker)
	self.m_SeekerWalker3D.moveTransform = self.m_SeekerWalker3DObj.m_Transform
	self.m_SeekerWalker3D:SetWalkStartCallback(callback(self, "OnStartPath"))
	self:InitValue()
end

function CMapCtrl.InitValue(self)
	self.m_SceneID = nil
	self.m_MapID = nil
	self.m_SceneName = ""
	self.m_Hero = nil
	self.m_LoadingInfo = {map = nil, light=nil}
	self.m_Players = {}
	self.m_Npcs = {}
	self.m_DynamicNpcs = {}
	self.m_EscortNpcs = {}
	self.m_DialogueNpcs = {}
	self.m_TraceNpcs = {}
	self.m_SubTalkerNpcs = {}
	self.m_TaskChapterFbNpcs = {}
	self.m_TaskPickItems = {}
	self.m_MonsterNpcs = {}
	self.m_Walkers = {}
	self.m_IntanceID2Walker = {}
	self.m_LoadDoneCB = nil
	self.m_Teams = {}
	self.m_TeamMissPlayers = {}
	self.m_PatrolLists = {}
	self.m_ClientNpcList = {}
	self.m_NpcSetFaceTimer = {}
	self.m_MiniMapData = {}
	self.m_AoiBlockCache = {}
	self.m_IsPatrol = false
	self.m_IsPatrolFree = false
	self.m_EnterSceneFinish = nil
	self.m_AutoFindData = nil
	self.m_SameScreenHandler:Clear()
	self:StopDelay()
	if self.m_NpcTipsDialogueTimer ~= nil then
		Utils.DelTimer(self.m_NpcTipsDialogueTimer)
		self.m_NpcTipsDialogueTimer = nil
	end
end

function CMapCtrl.OnStartPath(self)
	if self.m_GetPathInfo then
		local path = self.m_GetPathInfo.walker:GetPath()
		self.m_GetPathInfo.cb(path)
		self.m_GetPathInfo = nil
	end
end

function CMapCtrl.GetPath(self, vStart, vEnd, doneCb)
	if self.m_CurMapObj then
		self.m_GetPathInfo = {}
		local x = vEnd.x
		local yorz = 0
		if self.m_Is3D then
			self.m_GetPathInfo.obj = self.m_SeekerWalker3DObj
			self.m_GetPathInfo.walker = self.m_SeekerWalker3D
			yorz = vEnd.z

		else
			self.m_GetPathInfo.obj = self.m_SeekerWalker2DObj
			self.m_GetPathInfo.walker = self.m_SeekerWalker2D
			yorz = vEnd.y
		end
		self.m_GetPathInfo.obj:SetPos(vStart)
		self.m_GetPathInfo.walker:WalkTo(x, yorz, true)
		self.m_GetPathInfo.cb = doneCb
		return
	end
	cb({})
	self.m_GetPathInfo = nil
end

function CMapCtrl.GetPosQueue(self, pathlist)
	local function getposinfo(vPos)
		return vPos
	end
	local iLen = #pathlist
	local vLastPos = nil
	local vStartPos = nil
	local lPosQueue = {}
	local iTotalDis = 0
	local iNextTime = 0
	local tinsert = table.insert
	local i = 1
	while i <= iLen do
		local vPos = pathlist[i]
		vPos.z = 0
		if vLastPos then
			local iPosDistance = Vector3.DistanceXY(vPos,vLastPos)
			if (iTotalDis + iPosDistance) > define.Walker.Move_Speed then
				iNextTime = iNextTime + 1000
				local vLerpPos = Vector3.Lerp(vLastPos, vPos, (define.Walker.Move_Speed-iTotalDis)/iPosDistance)
				tinsert(lPosQueue, getposinfo(vStartPos))
				vStartPos, vLastPos = vLerpPos, vLerpPos
				tinsert(pathlist, i, vLerpPos)
				iLen = iLen + 1
				iTotalDis = 0
			else
				iTotalDis = iTotalDis + iPosDistance
				vLastPos = vPos
				if i == iLen then
					local iTime = (iTotalDis/define.Walker.Move_Speed * 1000)
					tinsert(lPosQueue, getposinfo(vPos))
					iTotalDis = 0
					iNextTime = 0
				end
			end
		else
			vStartPos, vLastPos = vPos, vPos
		end
		i = i + 1
	end
	return lPosQueue
end


function CMapCtrl.Update(self, dt)
	if self.m_Hero then
		self.m_SameScreenHandler:CheckAddPlayer()
	end
	return true
end

function CMapCtrl.SaveResotreInfo(self)
	if self.m_ResID then
		local oHero = self:GetHero()
		local vPos = oHero~=nil and oHero:GetLocalPos() or Vector3.zero
		self.m_RestoreInfo = {resid=self.m_ResID , pos_info = vPos}
	end
end

function CMapCtrl.ResotreMap(self)
	if self.m_RestoreInfo then
		self:Load(self.m_RestoreInfo.resid, self.m_RestoreInfo.pos_info)
	end
	self.m_RestoreInfo = nil
end

function CMapCtrl.Is3DMap(self, resid)
	if not resid then
		return true
	end
	return resid >= 5000
end

function CMapCtrl.IsWalkMap(self, resid)
	if not resid then
		return false
	end
	return resid < 5000 or resid >= 6000
end

function CMapCtrl.IsNavMap(self, resid)
	if not resid then
		return false
	end
	return resid < 5000 or resid == 6000
end

function CMapCtrl.IsVirtualScene(self)
	return self.m_SceneType == 1
end

function CMapCtrl.ReleaseMap(self)
	if self.m_CurMapObj then
		local mapobj = self.m_CurMapObj
		local resid = self.m_ResID 
		printc("删除地图:", resid)
		mapobj:SetName("delete"..resid)
		mapobj.m_MapCompnent:Release()
		if self:Is3DMap(resid) then
			g_ResCtrl:PutMapInCache(resid, mapobj)
		else
			mapobj:Destroy()
		end
	end
	self.m_CurMapObj = nil
	self.m_ResID = nil
	self.m_LightID = nil
end

function CMapCtrl.Clear(self, bReleaseMap)
	--保存上一个地图id
	self.m_LastMapID = self.m_MapID

	for i, oWalker in pairs(self.m_Walkers) do
		oWalker:Destroy()
		if oWalker.m_Followers then
			for j,c in pairs(oWalker.m_Followers) do
				c:Destroy()
			end
		end
	end

	--清除不是存在 m_walker 中的，客户端创建的NPC(没有npcid)
	self:DelAllEscortNpc()
	self:DelAllTraceNpc()
	self:DelAllSubTalkerNpc()
	self:DelAllDialogueNpc()
	self:DelAllFollowWalker()
	self:DelAllTaskChapterFbNpc()
	self:ClearClientNpc() 
	if bReleaseMap then
		self:ReleaseMap()
	end
	self:InitValue()
end

function CMapCtrl.GetCurMapObj(self)
	return self.m_CurMapObj
end

function CMapCtrl.ShowScene(self, sceneid, mapid, scenename, isnewman, scenetype)
	if g_HouseCtrl:IsHouseOnly() then
		return
	end
	g_ResCtrl:MoveToSecondary()
	self:Clear(false)
	self.m_SceneID = sceneid
	self.m_MapID = mapid
	self.m_SceneName = scenename
	--是否新手场景
	self.m_IsNewMan = isnewman
	--是否是虚拟场景
	self.m_SceneType = scenetype or 0
	self.m_AoiBlockCache = {}
	self:OnEvent(define.Map.Event.ShowScene)
end

function CMapCtrl.EnterScene(self, eid, pPosInfo)
	if g_HouseCtrl:IsHouseOnly() then
		return
	end
	local mapData = DataTools.GetMapData(self.m_MapID)
	self.m_EnterSceneFinish = true
	if self:IsWalkMap(mapData.resource_id) then
		self:AddHero(eid, pPosInfo)
		if self.m_AutoFindData then
			self:AutoFindPath(self.m_AutoFindData)
		end
	end
	g_ResCtrl:ResetCloneDynamicLevel()  --清除动态人物加载顺序
	g_ViewCtrl:SwitchScene()
	self:Load(mapData.resource_id, pPosInfo)
	self:OnEvent(define.Map.Event.EnterScene)
end

function CMapCtrl.GetWalkerRoot(self)
	if not self.m_WalkerRoot then
		self.m_WalkerRoot = CObject.New(UnityEngine.GameObject.New("WalkerRoot"))
	end
	return self.m_WalkerRoot
end

function CMapCtrl.GetMapSize(self)
	local map = self.m_CurMapObj.m_MapCompnent
	if map then
		return map.width, map.height
	else
		return 1, 1
	end
	
end

function CMapCtrl.IsLoading(self)
	return self.m_MapLoding
end

function CMapCtrl.LoadDoneCallback(self)
	self:LocalMapLoadDone()
	self:CheckNpcTipsDialogue()
	self.m_MapLoding = false
end

function CMapCtrl.HideRenderTexture(self)
	local oView = CBottomView:GetView()
	if oView then
		oView:SetBottomTexture(nil)
	end
end

function CMapCtrl.ShowRenderTexture(self)
	-- if self.m_ResID and not self:Is3DMap(self.m_ResID) then
	-- 	local oView = CB ottomView:GetView()
	-- 	if oView then
	-- 		local w, h = oView.m_Contanier:GetSize()
	-- 		local oCam = g_CameraCtrl:GetMainCamera()
	-- 		if not oCam:GetEnabled() then
	-- 			oCam = g_CameraCtrl:GetWarCamera()
	-- 			if not oCam:GetEnabled() then
	-- 				oCam = g_CameraCtrl:GetHouseCamera()
	-- 			end
	-- 		end
	-- 		oCam = oCam:GetRenderCam()
	-- 		local oMapTexture = Utils.ScreenShoot(oCam, w/2, h/2)
	-- 		oView:SetBottomTexture(oMapTexture)
	-- 	end
	-- end
end

function CMapCtrl.StopDelay(self)
	if self.m_DelayTimer then
		Utils.DelTimer(self.m_DelayTimer)
		self.m_MapLoding = false
		self.m_DelayTimer = nil
	end
end

function CMapCtrl.Load(self, resid, pPosInfo)
	local lightid = 1
	if (self.m_ResID == resid) then
		printc("同一地图", resid)
		self:StopDelay()
		self:MapLoadDone(resid, self.m_CurMapObj, true)
		return
	elseif (self.m_LoadingInfo.res == resid) then
		printc("正在读取同一地图", resid)
		return
	end
	self:StopDelay()
	local oCam = g_CameraCtrl:GetMapCamera()
	local oCache = g_ResCtrl:GetMapFromCache(resid)
	if oCache  then
		printc("使用缓存的地图", resid)
		if self:Is3DMap(resid) then -- 2D地图不做缓存
			local bLoadNav = self:IsNavMap(resid)
			oCache.m_MapCompnent:LoadData(resid, lightid, bLoadNav)
		-- else
		-- 	--立刻设置相机位置
		-- 	oCam:SetCurMap(oCache.m_MapCompnent)
		-- 	oCam:SyncTargetPos()
		-- 	oCache.m_MapCompnent:LoadData(resid)
		end
		oCache:SetParent(nil)
		self:MapLoadDone(resid, oCache, true)
		return true
	else
		self:ShowRenderTexture()
	end

	self.m_MapLoding = true
	self.m_LoadingInfo = {res = resid, light= lightid}
	self.m_LastLoadTime = g_TimeCtrl:GetTimeMS()
	local function delay()
		self.m_DelayTimer = nil
		if not self.m_MapLoding then
			return
		end
		g_MapTouchCtrl:SetLockTouch(true)
		printc("读取地图：", resid)
		local mapgo = CObject.New(UnityEngine.GameObject.New("map_loading_"..tostring(resid)))
		mapgo:SetLocalScale(Vector3.zero)
		mapgo:SetLayer(define.Layer.MapTerrain)
		if self:Is3DMap(resid) then
			local map3d = mapgo:AddComponent(classtype.Map3D)
			mapgo.m_MapCompnent = map3d
			local bLoadNav = self:IsNavMap(resid)
			map3d:LoadAsync(resid, lightid, bLoadNav, callback(self, "MapLoadDone", resid, mapgo))
		else
			mapgo:SetPos(Vector3.New(1.28, 1.28, 100))
			local map2d = mapgo:AddComponent(classtype.Map2D)
			mapgo.m_MapCompnent = map2d
			local oMap = self:LoadMap2d(map2d, resid, Vector3.New(pPosInfo.x, pPosInfo.y, pPosInfo.z))
			--立刻设置相机位置
			oCam:SetCurMap(mapgo.m_MapCompnent)
			self:MapLoadDone(resid, mapgo)
		end
	end
	self.m_DelayTimer = Utils.AddTimer(delay, 0, 0)
end

function CMapCtrl.LoadMap2d(self, map2d, resid, pos)
	--特殊地图对应特殊的阻挡
	local iNavID = data.mapconfigdata.Map2Nav[self.m_MapID]
	if iNavID then
		return map2d:Load(resid, iNavID, pos)
	else
		return map2d:Load(resid, pos)
	end
end

function CMapCtrl.AutoFindPath(self, pbdata)
	local npcid = pbdata.npcid
	local map_id = pbdata.map_id
	local pos_x = pbdata.pos_x
	local pos_y = pbdata.pos_y
	local autotype = pbdata.autotype
	local system = pbdata.system
	local function endCb()
		netother.C2GSCallback(pbdata.callback_sessionidx)
	end
	local walkconfig = {}
	walkconfig.m_WalkTarget = system or 0
	if autotype == 1 then
		if map_id ~= self.m_MapID then
			return
		end

		if not self.m_EnterSceneFinish then
			self.m_AutoFindData = pbdata
			return
		end
		local function find()
			local pos = Vector3.New(pos_x, pos_y, 0)
			g_MapTouchCtrl:WalkToPos(netscene.DecodePos(pos), npcid, define.Walker.Npc_Talk_Distance + g_DialogueCtrl:GetTalkDistanceOffset(), endCb, walkconfig)
		end

		if self.m_LoadingInfo.res ~= nil then
			self:AddLoadDoneCb(find)
		else
			find()
		end
	elseif autotype == 2 then
	end
end

function CMapCtrl.GetMapID(self)
	return self.m_MapID
end

function CMapCtrl.GetLastMapID(self)
	return self.m_LastMapID
end

function CMapCtrl.GetSceneID(self)
	return self.m_SceneID
end

function CMapCtrl.GetResID(self)
	return self.m_ResID
end

function CMapCtrl.IsWarMap(self)
	local map = {5010, 5000, 5020}
	for _, mapId in pairs(map) do
		if self.m_ResID == mapId then
			return true
		end
	end
	return false
end

function CMapCtrl.GetSceneName(self)
	return self.m_SceneName
end

function CMapCtrl.AddLoadDoneCb(self, func)
	table.insert(self.m_LoadDoneCbList, func)
end

function CMapCtrl.CheckMusic(self, resid)
	if resid == 6200 or resid == 6300 then
		return
	end
	if g_WarCtrl:IsWar() then
		local dData = data.audiodata.WAR[g_WarCtrl:GetWarType()]
		if dData and dData.filename then
			g_AudioCtrl:PlayWarMusic(table.randomvalue(dData.filename))
		else
			g_AudioCtrl:PlayWarMusic("bgm_pve")
		end
	else
		local dData = data.audiodata.NORMAL[resid]
		if dData and dData.filename then
			g_AudioCtrl:PlayNormalMusic(dData.filename)
		else
			if not g_CreateRoleCtrl:IsInCreateRole() then
				g_AudioCtrl:PlayMusic("bgm_1010.ogg")
			end
		end
	end
end

function CMapCtrl.CheckCamTarget(self)
	if self.m_Hero then
		local oCam = g_CameraCtrl:GetMapCamera()
		oCam:Follow(self.m_Hero.m_Transform)
		oCam:SyncTargetPos()
	end
end

function CMapCtrl.MapLoadDone(self, resid, mapobj, bCache)
	g_TaskCtrl:TaskProcressWhenMapLoadDone()
	g_LoginCtrl:LoginRoleHide()
	mapobj:SetName("map_loaddone_"..tostring(resid))
	self.m_MapLoding = false
	self:HideRenderTexture()
	if self.m_FloatTime and self.m_LastLoadTime then
		g_NotifyCtrl:FloatMsg(string.format("load地图%d时间: %dms", resid, g_TimeCtrl:GetTimeMS()-self.m_LastLoadTime))
	end
	if not bCache then --不是缓存的
		if not self.m_LoadingInfo.res or
		(self.m_LoadingInfo.res and self.m_LoadingInfo.res and self.m_LoadingInfo.res ~= resid) then
			
			if self.m_ResID ~= resid then
				mapobj.m_MapCompnent:Release()
				print("与最后load信息不符, 删除", self.m_LoadingInfo.res, resid)
			else
				print("与最后load信息不符, 与当前地图相同", self.m_LoadingInfo.res, resid)
			end
			mapobj:Destroy()
			return 
		end
	end
	g_MapTouchCtrl:SetLockTouch(false)
	printc("地图加载完成:", resid, ",当前地图:", self.m_ResID)
	if self.m_CurMapObj and self.m_CurMapObj:GetInstanceID() ~= mapobj:GetInstanceID() then
		self:ReleaseMap()
	end
	mapobj:SetName("map_"..tostring(resid))
	mapobj:SetLocalScale(Vector3.one)
	self.m_ResID = resid
	-- self.m_LightID = self.m_LoadingInfo.light
	self.m_LoadingInfo = {map = nil, light=nil}
	self.m_CurMapObj = mapobj
	self:CheckMusic(resid)
	self:CheckCamTarget()
	--检测那种，需要延时切换镜头的剧情
	g_DialogueAniCtrl:DelayCheckDialogueAniCamera()		
	if not g_HouseCtrl:IsInHouse() then
		g_CameraCtrl:AutoActive()
	end

	--检测是否显示传送点
	self:CheckShowTransfer()
	self:CheckUIEffect()
	if not self:Is3DMap(resid) then
		local pos = self.m_CurMapObj:GetPos()
		self.m_CurMapObj:SetPos(Vector3.New(pos.x, pos.y, 100))
	end
	
	if self:IsWalkMap(resid) then
		self:DelayUpdateFollow()
		self:ResetMapCamera()
		self:DelAllDynamicNpc()
		self:DelAllEscortNpc()
		self:DelAllTraceNpc()
		self:DelAllSubTalkerNpc()
		self:DelAllTaskChapterFbNpc()
		self:ResetFollowPartner()
		self:UpdateFollowPartner()
		g_DialogueAniCtrl:CheckAllAniWhenMapLoadDone()		
		self:LoadClientNpc()
		g_TaskCtrl:CheckNpcMark()
		g_TaskCtrl:CheckTaskThing()
		g_AnLeiCtrl:RefreshNpc()
		g_ActivityCtrl:RefreshMingLeiNpc()
		g_ActivityCtrl:RefreshDTNpc()
		g_TreasureCtrl:RefreshNpc()
		g_MonsterAtkCityCtrl:RefreshMonsterAll()
		if self.m_IsPatrol and not self.m_IsPatrolFree and not g_MapCtrl:IsPatrolMap() then
			g_NotifyCtrl:FloatMsg("该场景非暗雷场景，无法自动巡逻")
			self.m_IsPatrol = false
		else
			self:CheckPatrol()
		end
		for eid, oWalker in pairs(self.m_Walkers) do
			oWalker:SetMapID(g_MapCtrl:GetResID())
		end
	end
	if next(self.m_LoadDoneCbList) then
		for i, cb in ipairs(self.m_LoadDoneCbList) do
			cb(mapobj)
		end
		self.m_LoadDoneCbList = {}
	end
	--地图加载完成触发引导  暂时注释
	--g_GuideCtrl:TriggerWar1()
	
	g_AnLeiCtrl:HeroPatrolCheck()
	g_EquipFubenCtrl:ShowMapGuideEffect()
	self:CheckNpcTipsDialogue()
	g_GuideCtrl:MapLoadDownTriggerGuide()
	g_ConvoyCtrl:BeginConvoy()
	g_OrgWarCtrl:CheckView()
	self:OnEvent(define.Map.Event.MapLoadDone, mapobj)
	self:CheckGC()

	--生成暗雷巡逻路径
	--self:GetPartolData()
end

function CMapCtrl.CheckGC(self)
	-- g_ResCtrl:UnloadAtlas(false)
	--进战斗gc
	if g_WarCtrl:IsWar() then
		g_ResCtrl:GC(true)
	--超过时间没gc,则切图gc
	elseif g_TimeCtrl:GetTimeS() -  g_ResCtrl.m_LastGCTime > data.resdata.MapGCTime then
		g_ResCtrl:GC(true)
	end
end

--如果切换地图和原来地图一样，则重新加载动态生成的实例
function CMapCtrl.LocalMapLoadDone(self)
	if self:IsWalkMap(self.m_ResID) then
		self:DelAllDynamicNpc()
		self:DelAllEscortNpc()
		self:DelAllTraceNpc()
		self:DelAllSubTalkerNpc()
		self:DelAllTaskChapterFbNpc()
		g_DialogueAniCtrl:CheckAllAniWhenMapLoadDone()
		g_TaskCtrl:CheckNpcMark()
		g_TaskCtrl:CheckTaskThing()
		g_AnLeiCtrl:RefreshNpc()
		g_ActivityCtrl:RefreshMingLeiNpc()
		g_ActivityCtrl:RefreshDTNpc()
		g_TreasureCtrl:RefreshNpc()
		g_MonsterAtkCityCtrl:RefreshMonsterAll()
	end
end

function CMapCtrl.ResetMapCamera(self)
	local oCam = g_CameraCtrl:GetMapCamera()
	if not self:Is3DMap(self.m_ResID) then
		oCam:SetCurMap(self.m_CurMapObj.m_MapCompnent)
		oCam:SyncTargetPos()
	end
end

function CMapCtrl.GetHero(self)
	return self.m_Hero
end

function CMapCtrl.GetWalker(self, eid)
	return self.m_Walkers[eid]
end

function CMapCtrl.GetPlayer(self, pid)
	return self.m_Players[pid]
end

function CMapCtrl.GetInSceenPlayer(self)
	local playerList = {}
	for k,v in pairs(self.m_Players) do
		if v:IsInScreen() then
			table.insert(playerList, v)
		end
	end
	return playerList
end

function CMapCtrl.GetNpc(self, npcid)
	return self.m_Npcs[npcid]
end

function CMapCtrl.GetDynamicNpc(self, npcid)
	return self.m_DynamicNpcs[npcid]
end

function CMapCtrl.GetMonsterNpc(self, npcid)
	return self.m_MonsterNpcs[npcid]
end

function CMapCtrl.GetEscortNpc(self, npcid)
	return self.m_EscortNpcs[npcid]
end

function CMapCtrl.GetDialogueNpc(self, npcid)
	return self.m_DialogueNpcs[npcid]
end

function CMapCtrl.GetTraceNpc(self, npcType)
	return self.m_TraceNpcs[npcType]
end

function CMapCtrl.GetTaskChapterFbNpc(self, npcType)
	return self.m_TaskChapterFbNpcs[npcType]
end

function CMapCtrl.GetTaskPickItem(self, pickid)
	return self.m_TaskPickItems[pickid]
end

function CMapCtrl.UpdateByPosInfo(self, oWalker, posInfo, rotateY)
	local posx, posy = posInfo.x, posInfo.y
	if oWalker.m_Is3D then
		if oWalker.m_IsHouseWalker then
			oWalker:SetTempPos(Vector3.New(posx, 0, posy))
			oWalker:SetTempRotate(rotateY)
			if oWalker:CanPlayDialogueAni() then
				oWalker:SetLocalPos(Vector3.New(posx, 0, posy))
			end
		else
			oWalker:SetLocalPos(Vector3.New(posx, 0, posy))
		end
	else
		oWalker:SetLocalPos(Vector3.New(posx, posy, 0))
		if (oWalker.classtype == CPlayer or oWalker.classtype == CHero) and not oWalker:IsPlayingSociaty() then
			oWalker.m_Actor:SetLocalEulerAngles(Vector3.New(posInfo.face_x, posInfo.face_y, 0))
		end
	end
end

function CMapCtrl.CheckRotation(self, oWalker, posInfo)
	-- 旋转
	--table.print(posInfo)
	--printc(posInfo.face_y)
	if posInfo.face_y then
		oWalker.m_Actor:SetLocalRotation(Quaternion.Euler(0, posInfo.face_y, 0))
	end
end

--更新当前角色
function CMapCtrl.UpdateHero(self)
	if self.m_Hero == nil then
		return
	end
	local name = string.format("[00ff00]%s", g_AttrCtrl.name)
	local titleID = g_AttrCtrl.title_info
	self.m_Hero.m_Title = titleID
	self.m_Hero:UpdateName(g_AttrCtrl.name, name, g_AttrCtrl.camp)
	self.m_Hero:UpdateTitle(titleID)
	self.m_Hero:UpdateAoiState()
	local model_info = g_AttrCtrl.model_info
	if model_info.shape then
		self.m_Hero:ChangeShape(model_info.shape, model_info)
	end
end

function CMapCtrl.AddHero(self, eid, pPosInfo)
	if self.m_Players[g_AttrCtrl.pid] and self.m_Players[g_AttrCtrl.pid].m_Eid then
		self:DelWalker(self.m_Players[g_AttrCtrl.pid].m_Eid)
	end
	local oHero = CHero.New()
	oHero.m_Eid = eid
	oHero.m_Pid = g_AttrCtrl.pid
	if g_AttrCtrl.model_info.shape then
		oHero:ChangeShape(g_AttrCtrl.model_info.shape, g_AttrCtrl.model_info, nil, true)
	end
	local name = string.format("[00ff00]%s", g_AttrCtrl.name)
	oHero:UpdateName(g_AttrCtrl.name, name, g_AttrCtrl.camp)
	local titleID = g_AttrCtrl.title_info
	oHero.m_TitleInfo = titleID
	oHero:UpdateTitle(titleID)
	oHero:UpdateAoiState()
	CObject.SetName(oHero, string.format("e%d-p%d-%s",eid,g_AttrCtrl.pid, g_AttrCtrl.name))
	self.m_Walkers[eid] = oHero
	self.m_Players[g_AttrCtrl.pid] = oHero
	self.m_IntanceID2Walker[oHero:GetInstanceID()] = weakref(oHero)
	self:UpdateByPosInfo(oHero, pPosInfo)
	self.m_Hero = oHero
	g_AnLeiCtrl:HeroPatrolCheck()
	self:CheckPatrol()
	local v3 = oHero:GetLocalPos()
	g_MapCtrl:DelAllFollowWalker()
	for k,v in pairs(g_AttrCtrl.followers) do
		v3.x = v3.x + 0.5
		local objName = string.format("e%d-p%d-%s-%s", eid, g_AttrCtrl.pid, g_AttrCtrl.name,v.name)
		self:AddFollowPartner(v,eid,objName,pPosInfo)
	end
	
	g_TaskCtrl:CheckStartStoryTask()
	self:OnEvent(define.Map.Event.HeroLoadDone)
end

--scene.proto playerAoi
function CMapCtrl.AddPlayer(self, eid, pPlayerAoi)
	local oPlayer = self.m_Players[pPlayerAoi.pid]
	if not oPlayer then
		oPlayer = CPlayer.New()
		oPlayer.m_Eid = eid
		oPlayer.m_Pid = pPlayerAoi.pid
		local model_info = pPlayerAoi.block.model_info
		if model_info then
			oPlayer:ChangeShape(model_info.shape, model_info)
		end

		local iWarTag = pPlayerAoi.block.war_tag
		if iWarTag then
			oPlayer:SetWarTag(iWarTag)
		end
		oPlayer:SetStateTag(pPlayerAoi.block.state)
		if pPlayerAoi.block.trapmine then
			oPlayer:SetAnLeiTag(pPlayerAoi.block.trapmine)
		end
		local name = string.format("[00ff00]%s", pPlayerAoi.block.name or "")
		local titleInfo = {}
		if pPlayerAoi.block.title_info then
			for k,v in pairs(pPlayerAoi.block.title_info) do
				table.insert(titleInfo, v)
			end
		end
		oPlayer.m_TitleID = titleInfo
		oPlayer:UpdateName(pPlayerAoi.block.name ,name, pPlayerAoi.block.camp)
		oPlayer:UpdateTitle(oPlayer.m_TitleID)
		CObject.SetName(oPlayer, string.format("e%d-p%d-%s",eid,pPlayerAoi.pid, pPlayerAoi.block.name))
		self.m_Players[pPlayerAoi.pid] = oPlayer
		self.m_Walkers[eid] = oPlayer
		self.m_IntanceID2Walker[oPlayer:GetInstanceID()] = weakref(oPlayer)
		g_MapCtrl:DelAllFollowWalker(eid)
		local follows = pPlayerAoi.block.followers
		oPlayer.m_FollowersList = follows
		if follows then
			for k,v in pairs(follows) do
				local objName = string.format("e%d-p%d-%s-%s",oPlayer.m_Eid, oPlayer.m_Pid, pPlayerAoi.block.name,v.name)
				self:AddFollowPartner(v, eid, objName, pPlayerAoi.pos_info)
			end
		end
		if pPlayerAoi.block.social_display then
			-- table.print(pPlayerAoi.block.social_display, "block.social_display------>")
			g_SocialityCtrl:Play(pPlayerAoi.block.social_display, oPlayer)
		end
		self:DelayUpdateFollow()
		self.m_SameScreenHandler:ChangePlayerCnt(1)
	end
	oPlayer:DoOtherSet()
	self:UpdateByPosInfo(oPlayer, pPlayerAoi.pos_info)
	return oPlayer
end

--scene.proto npcAoi
function CMapCtrl.AddNpc(self, eid, pNpcAoi)
	if self:CheckHeroBoxRecord(pNpcAoi.npcid) then
		return
	end
	if pNpcAoi and pNpcAoi.block and pNpcAoi.block.model_info and pNpcAoi.block.model_info.shape then
		local shape = pNpcAoi.block.model_info.shape
		local path = string.format("Model/Character/%d/Prefabs/model%d.prefab", shape, shape)
		g_ResCtrl:ChangeCloneDynamicLevel("Npc", path)
	end
	local oNpc = self.m_Npcs[pNpcAoi.npcid]
	if not oNpc then
		oNpc = CNpc.New()
		oNpc.m_Eid = eid
		oNpc:SetData(pNpcAoi)
		local model_info = pNpcAoi.block.model_info

		if model_info then
			if pNpcAoi.mode == 2 or pNpcAoi.mode == 3 then
				model_info.shape = 3009
			end
			oNpc:ChangeShape(model_info.shape, model_info)
		end
		local iWarTag = pNpcAoi.block.war_tag
		if iWarTag then
			oNpc:SetWarTag(iWarTag)
		end
		oNpc:SetStateTag(pNpcAoi.block.state)
		local oEffect
		if pNpcAoi.mode == 2 then
			oEffect = CEffect.New("Effect/UI/ui_eff_terrawar/Prefabs/ui_eff_terrawar_c_002_03.prefab", oNpc.m_Layer, false)
		elseif pNpcAoi.mode == 3 then
			oEffect = CEffect.New("Effect/UI/ui_eff_terrawar/Prefabs/ui_eff_terrawar_c_003_03.prefab", oNpc.m_Layer, false)
		else
			self:SetTaskMark(oNpc, pNpcAoi.npctype, pNpcAoi.mode)
		end
		if oEffect then
			oEffect:SetParent(oNpc.m_Transform)
			oEffect:SetActive(true)
			g_EffectCtrl:AddEffect(oEffect)
		end
		local name = string.format("[FF7D00]%s", pNpcAoi.block.name or "")
		if pNpcAoi.titlename and pNpcAoi.titlename ~= "" then
			name = string.format("[ADE6D8]%s[FF7D00]\n%s", pNpcAoi.titlename, pNpcAoi.block.name or "")
		else
			local globalNpc = self:GetGlobalNpc(pNpcAoi.npctype)
			if globalNpc then
				if globalNpc.shortName and string.len(globalNpc.shortName) > 0 then
					name = "[ADE6D8]" .. globalNpc.shortName .. "[-]\n" .. name
				end
				if globalNpc.title and string.len(globalNpc.title) > 0 then
					local titleSpr = nil
					local titleName = nil
					local colonIndex = string.find(globalNpc.title, "%:")
					local titleStrs = string.split(globalNpc.title, "%:")
					if colonIndex and colonIndex > 0 then
						if colonIndex == 1 then
							titleName = titleStrs[1]
						else
							if titleStrs[1] and string.len(titleStrs[1]) > 0 then
								titleSpr = titleStrs[1]
							end
							if titleStrs[2] and string.len(titleStrs[2]) > 0 then
								titleName = titleStrs[2]
							end
						end
					else
						if tonumber(globalNpc.title) then
							titleSpr = globalNpc.title
						else
							titleName = globalNpc.title
						end
					end
					oNpc:SetSpecialTitleHud(titleName, titleSpr)
				end
			end
		end
		oNpc:UpdateName(pNpcAoi.block.name ,name)
		oNpc:SetName()
		if pNpcAoi.block.ownerid and pNpcAoi.block.ownerid > 0 and  pNpcAoi.block.orgid 
			and pNpcAoi.block.orgid > 0 and pNpcAoi.block.orgflag and pNpcAoi.block.owner then
			oNpc:SetTerraWarHud(pNpcAoi.block.orgid, pNpcAoi.block.orgflag, pNpcAoi.block.owner)
		else
			oNpc:DelTerraWarHud()
		end
		CObject.SetName(oNpc, string.format("e%d-%s", eid, pNpcAoi.block.name or ""))
		self.m_Npcs[pNpcAoi.npcid] = oNpc
		self.m_Walkers[eid] = oNpc
		self.m_IntanceID2Walker[oNpc:GetInstanceID()] = weakref(oNpc)
	end
	self:UpdateByPosInfo(oNpc, pNpcAoi.pos_info)
	self:CheckRotation(oNpc, pNpcAoi.pos_info)
end

function CMapCtrl.AddDynamicNpc(self, dynamicNnpc)
	--print(string.format("<color=#00FF00> >>> .%s | %s | Table:%s </color>", "AddDynamicNpc", "实例一个动态Npc", "dynamicNnpc"))
	-- table.print(dynamicNnpc)
	if dynamicNnpc and dynamicNnpc.model_info and dynamicNnpc.model_info.shape then
		local shape = dynamicNnpc.model_info.shape
		local path = string.format("Model/Character/%d/Prefabs/model%d.prefab", shape, shape)
		g_ResCtrl:ChangeCloneDynamicLevel("TaskNpc", path)
	end	
	local clientnpc = table.copy(dynamicNnpc)
	clientnpc.pos_info = netscene.DecodePos(clientnpc.pos_info)
	if clientnpc then
		local npcid = clientnpc.npcid
		local oDynamicNpc = self.m_DynamicNpcs[npcid]
		if not oDynamicNpc then
			oDynamicNpc = CDynamicNpc.New()
			oDynamicNpc:SetData(clientnpc)
			local model_info = clientnpc.model_info
			if model_info then
				--模型特殊转换
				model_info.shape = g_DialogueCtrl:GetSpecialShape(model_info.shape)
				oDynamicNpc:ChangeShape(model_info.shape, model_info)
			end
			self:SetTaskMark(oDynamicNpc, clientnpc.npctype)

			local name = string.format("[FF00FF]%s", clientnpc.name)
			local taskNpc = g_TaskCtrl:GetTaskNpc(clientnpc.npctype)
			if taskNpc and taskNpc.shortName and string.len(taskNpc.shortName) > 0 then
				name = string.format("[ADE6D8]%s[FF00FF]\n%s", taskNpc.shortName, clientnpc.name)
			end
			oDynamicNpc:UpdateName(clientnpc.name, name)
			CObject.SetName(oDynamicNpc, string.format("n%d-%s", npcid, clientnpc.name))
			self.m_DynamicNpcs[npcid] = oDynamicNpc
			self.m_Walkers[npcid] = oDynamicNpc
			self.m_IntanceID2Walker[oDynamicNpc:GetInstanceID()] = weakref(oDynamicNpc)
		end

		self:UpdateByPosInfo(oDynamicNpc, clientnpc.pos_info)
	end
end

function CMapCtrl.AddEscortNpc(self, EscortNpc)
	--print(string.format("<color=#00FF00> >>> .%s | %s | Table:%s </color>", "AddEscortNpc", "实例一个护送Npc", "AddEscortNpc"))

	if EscortNpc and EscortNpc.model_info and EscortNpc.model_info.shape then
		local shape = EscortNpc.model_info.shape
		local path = string.format("Model/Character/%d/Prefabs/model%d.prefab", shape, shape)
		g_ResCtrl:ChangeCloneDynamicLevel("TaskNpc", path)
	end
	local clientnpc = table.copy(EscortNpc)
	clientnpc.pos_info = netscene.DecodePos(clientnpc.pos_info)
	if clientnpc then
		local oHero = self:GetHero()
		local followNow = false
		clientnpc.pos_info.z = clientnpc.pos_info.z or 0			
		--如果护送对象的坐标与主角的距离大于 2  则直接在主角附近创建
		if oHero and not UITools.CheckInDistanceXY(oHero:GetPos(), clientnpc.pos_info, 2) then
			clientnpc.pos_info = oHero:GetPos()
			followNow = true
		--如果主角未创建，则说明可能是切换地图，护送npc等待主角加载完后，跟随主角
		elseif not oHero then
			followNow = true
		end

		local npctype = clientnpc.npctype		
		local oEscortNpc = self.m_EscortNpcs[npctype]
		if not oEscortNpc then
			oEscortNpc = CEscortNpc.New()
			oEscortNpc:SetData(clientnpc)
			local model_info = clientnpc.model_info
			if model_info then
				oEscortNpc:ChangeShape(model_info.shape, model_info)
			end
			--self:SetTaskMark(oDynamicNpc, clientnpc.npctype)
			local name = string.format("[FF00FF]%s", clientnpc.name)
			oEscortNpc:UpdateName(clientnpc.name, name)
			CObject.SetName(oEscortNpc, string.format("n%d-%s", npctype, clientnpc.name))
			self.m_EscortNpcs[npctype] = oEscortNpc
			self.m_IntanceID2Walker[oEscortNpc:GetInstanceID()] = weakref(oEscortNpc)
		end

		self:UpdateByPosInfo(oEscortNpc, clientnpc.pos_info)
		

		if followNow == true then
			oEscortNpc:FollowHero()		
		else
			oEscortNpc.m_IsCanFollowHero = false
			oEscortNpc:FaceToHero()			 
			oEscortNpc:DelayCheckFollow()
		end 
	end
	self:ResetFollowPartner()
end

function CMapCtrl.AddDialogueNpc(self, dialogueNpc, unitId, idx, isStory)
	if dialogueNpc and dialogueNpc.model_info and dialogueNpc.model_info.shape then
		local shape = dialogueNpc.model_info.shape
		local path = string.format("Model/Character/%d/Prefabs/model%d.prefab", shape, shape)
		g_ResCtrl:ChangeCloneDynamicLevel("TaskNpc", path)
	end	
	local clientnpc = table.copy(dialogueNpc)
	clientnpc.pos_info = netscene.DecodePos(clientnpc.pos_info)
	if clientnpc then
		local oDialogueNpc = nil
		if self.m_DialogueNpcs[dialogueNpc.npcid] then
			oDialogueNpc = self.m_DialogueNpcs[dialogueNpc.npcid]
		end
		if not oDialogueNpc then
			if g_HouseCtrl:IsInHouse() then
				if clientnpc.model_info then
					local dData = g_HouseCtrl:GetPartnerDataByFace(clientnpc.model_info.shape)


					local house = g_HouseCtrl:GetCurHouse()
					if dData then
						local dInfo = g_HouseCtrl:GetPartnerInfo(dData.id)
						if dInfo then
							oDialogueNpc = CHousePartner.New()
							oDialogueNpc:SetData(clientnpc)
							house:AddPartner(dInfo, oDialogueNpc)
						end
					elseif clientnpc.model_info.shape == g_AttrCtrl.model_info.shape then
						oDialogueNpc = CHousePartner.New()
						oDialogueNpc:SetData(clientnpc)
						house:AddPlayer(oDialogueNpc)
						oDialogueNpc:ChangeShape(clientnpc.model_info.shape, clientnpc.model_info)
						local name = string.format("[FF00FF]%s", clientnpc.name)
						-- oDialogueNpc:SetNameHud(name)
						CObject.SetName(oDialogueNpc, string.format("n%d-%s", dialogueNpc.npcid, clientnpc.name))
					end

					if clientnpc.model_info.shape and oDialogueNpc then						
						g_GuideCtrl:AddGuideUI("house_walker_1001", oDialogueNpc)
						local guide_ui = {"house_walker_1001"}
						oDialogueNpc.m_TipsGuideEnum = "house_walker_1001"
						Utils.AddTimer(function ()
							g_GuideCtrl:LoadTipsGuideEffect(guide_ui)
						end, 0 , 1)											
					end
				end
			else
				oDialogueNpc = CDialogueNpc.New()
				oDialogueNpc:SetData(clientnpc)
				oDialogueNpc.m_IsStoryNpc = isStory
				local model_info = clientnpc.model_info
				if model_info then
					oDialogueNpc:ChangeShape(model_info.shape, model_info)
				end
				local name = string.format("[FF00FF]%s", clientnpc.name)
				oDialogueNpc:UpdateName(clientnpc.name, "")
				if oDialogueNpc.m_IsStoryNpc then
					oDialogueNpc:SetMoveSpeed(define.Walker.Move_Speed * g_DialogueAniCtrl:GetAniPlaySpeed())
				end				
				CObject.SetName(oDialogueNpc, string.format("n%d-%s", dialogueNpc.npcid, clientnpc.name))
			end
			--self.m_Walkers[dialogueNpc.npcid] = oDynamicNpc
			if oDialogueNpc then
				self.m_DialogueNpcs[dialogueNpc.npcid] = oDialogueNpc
				self.m_IntanceID2Walker[oDialogueNpc:GetInstanceID()] = weakref(oDialogueNpc)
			end
		end
		if oDialogueNpc then
			self:UpdateByPosInfo(oDialogueNpc, clientnpc.pos_info, clientnpc.rotateY)
		end
		--检测那种，需要延时切换镜头的剧情
		g_DialogueAniCtrl:DelayCheckDialogueAniCamera()		
	end
end

function CMapCtrl.AddTraceNpc(self, TraceNpc)
	--print(string.format("<color=#00FF00> >>> .%s | %s | Table:%s </color>", "AddTraceNpc", "实例一个跟踪Npc", "AddTraceNpc"))
	-- table.print(TraceNpc)
	local clientnpc = table.copy(TraceNpc)
	clientnpc.pos_info = netscene.DecodePos(clientnpc.pos_info)
	if clientnpc then
		local npctype = clientnpc.npctype
		local oTraceNpc = self.m_TraceNpcs[npctype]
		if not oTraceNpc then
			oTraceNpc = CTraceNpc.New()
			oTraceNpc:SetData(clientnpc)
			local model_info = clientnpc.model_info
			if model_info then
				oTraceNpc:ChangeShape(model_info.shape, model_info)
			end
			local name = string.format("[FF00FF]%s", clientnpc.name)
			oTraceNpc:UpdateName(clientnpc.name, name)
			CObject.SetName(oTraceNpc, string.format("n%d-%s", npctype, clientnpc.name))
			self.m_TraceNpcs[npctype] = oTraceNpc	
			--self.m_Walkers[npcid] = oDynamicNpc
			self.m_IntanceID2Walker[oTraceNpc:GetInstanceID()] = weakref(oTraceNpc)
		end		
		self:UpdateByPosInfo(oTraceNpc, clientnpc.pos_info)
	end
end

function CMapCtrl.AddTaskChapterNpcNpc(self, CharacterNpc)
	print(string.format("<color=#00FF00> >>> .%s | %s | Table:%s </color>", "AddTaskChapterNpcNpc", "实例一个跟踪Npc", "AddTraceNpc"))
	-- table.print(TraceNpc)
	local clientnpc = table.copy(CharacterNpc)
	clientnpc.pos_info = netscene.DecodePos(clientnpc.pos_info)
	if clientnpc then
		local npctype = clientnpc.npctype
		local oTaskNpc = self.m_TaskChapterFbNpcs[npctype]
		if not oTaskNpc then
			oTaskNpc = CTaskChapterFbNpc.New()
			oTaskNpc:SetData(clientnpc)
			local model_info = clientnpc.model_info
			if model_info then
				oTaskNpc:ChangeShape(model_info.shape, model_info)
			end
			local name = string.format("[FF00FF]%s", clientnpc.name .. "123")
			oTaskNpc:UpdateName(clientnpc.name, name)
			CObject.SetName(oTaskNpc, string.format("n%d-%s", npctype, clientnpc.name))
			self.m_TaskChapterFbNpcs[npctype] = oTaskNpc	
			--self.m_Walkers[npcid] = oDynamicNpc
			self.m_IntanceID2Walker[oTaskNpc:GetInstanceID()] = weakref(oTaskNpc)
		end		
		self:UpdateByPosInfo(oTaskNpc, clientnpc.pos_info)
	end
end

function CMapCtrl.AddSubTaskerNpc(self, subTalkerNnpc)
	local clientnpc = table.copy(subTalkerNnpc)
	clientnpc.pos_info = netscene.DecodePos(clientnpc.pos_info)
	
	if clientnpc then		
		local oHero = self:GetHero()
		if oHero then
			clientnpc.face_pos = clientnpc.pos_info
			clientnpc.pos_info = oHero:GetPos()
		end		
		local npctype = clientnpc.npctype		
		local oSubTalkerNpc = self.m_SubTalkerNpcs[npctype]
		if not oSubTalkerNpc then
			oSubTalkerNpc = CSubTalkerNpc.New()
			oSubTalkerNpc:SetData(clientnpc)
			local model_info = clientnpc.model_info
			if model_info then
				oSubTalkerNpc:ChangeShape(model_info.shape, model_info)
			end
			local name = string.format("[FF00FF]%s", clientnpc.name)
			oSubTalkerNpc:UpdateName(clientnpc.name, name)
			oSubTalkerNpc:TalkBegin()	
			CObject.SetName(oSubTalkerNpc, string.format("n%d-%s", npctype, clientnpc.name))
			self.m_SubTalkerNpcs[npctype] = oSubTalkerNpc	
			--self.m_Walkers[npcid] = oSubTalkerNpc	
			self.m_IntanceID2Walker[oSubTalkerNpc:GetInstanceID()] = weakref(oSubTalkerNpc)
		end
		self:UpdateByPosInfo(oSubTalkerNpc, clientnpc.pos_info)
	end
end

function CMapCtrl.AddTerrawarNpc(self, eid, pNpcAoi)
	if pNpcAoi and pNpcAoi.block and pNpcAoi.block.model_info and pNpcAoi.block.model_info.shape then
		local shape = pNpcAoi.block.model_info.shape
		local path = string.format("Model/Character/%d/Prefabs/model%d.prefab", shape, shape)
		g_ResCtrl:ChangeCloneDynamicLevel("Npc", path)
	end
	local oNpc = self.m_Npcs[pNpcAoi.npcid]
	if not oNpc then
		oNpc = CTerrawarNpc.New()
		oNpc.m_Eid = eid
		oNpc:SetData(pNpcAoi)
		local model_info = pNpcAoi.block.model_info
		if model_info then
			oNpc:Setblock(pNpcAoi.block)
			oNpc:ChangeShape(model_info.shape, model_info)
		else
			oNpc:Setblock(pNpcAoi.block, true)
		end
		local iWarTag = pNpcAoi.block.war_tag
		if iWarTag then
			oNpc:SetWarTag(iWarTag)
		end
		oNpc:SetStateTag(pNpcAoi.block.state)
		--self:SetTaskMark(oNpc, pNpcAoi.npctype, pNpcAoi.mode)
		-- oNpc.m_Name = pNpcAoi.block.name
		local name = string.format("[FF7D00]%s", pNpcAoi.block.name or "")
		local globalNpc = self:GetGlobalNpc(pNpcAoi.npctype)
		if globalNpc then
			if globalNpc.shortName and string.len(globalNpc.shortName) > 0 then
				name = "[ADE6D8]" .. globalNpc.shortName .. "[-]\n" .. name
			end
			if globalNpc.title and string.len(globalNpc.title) > 0 then
				local titleSpr = nil
				local titleName = nil
				local colonIndex = string.find(globalNpc.title, "%:")
				local titleStrs = string.split(globalNpc.title, "%:")
				if colonIndex and colonIndex > 0 then
					if colonIndex == 1 then
						titleName = titleStrs[1]
					else
						if titleStrs[1] and string.len(titleStrs[1]) > 0 then
							titleSpr = titleStrs[1]
						end
						if titleStrs[2] and string.len(titleStrs[2]) > 0 then
							titleName = titleStrs[2]
						end
					end
				else
					if tonumber(globalNpc.title) then
						titleSpr = globalNpc.title
					else
						titleName = globalNpc.title
					end
				end
				oNpc:SetSpecialTitleHud(titleName, titleSpr)
			end
		end
		oNpc:UpdateName(pNpcAoi.block.name ,name)
		oNpc:SetName()
		if pNpcAoi.block.ownerid and pNpcAoi.block.ownerid > 0 and  pNpcAoi.block.orgid 
			and pNpcAoi.block.orgid > 0 and pNpcAoi.block.orgflag and pNpcAoi.block.owner then
			oNpc:SetTerraWarHud(pNpcAoi.block.orgid, pNpcAoi.block.orgflag, pNpcAoi.block.owner)
		else
			oNpc:DelTerraWarHud()
		end
		CObject.SetName(oNpc, string.format("e%d-%s", eid, pNpcAoi.block.name or ""))
		self.m_Npcs[pNpcAoi.npcid] = oNpc
		self.m_Walkers[eid] = oNpc
		self.m_IntanceID2Walker[oNpc:GetInstanceID()] = weakref(oNpc)
	end
	self:UpdateByPosInfo(oNpc, pNpcAoi.pos_info)
	self:CheckRotation(oNpc, pNpcAoi.pos_info)
end

function CMapCtrl.AddMonsterNpc(self, monsterNnpc)
	if monsterNnpc and monsterNnpc.model_info and monsterNnpc.model_info.shape then
		local shape = monsterNnpc.model_info.shape
		local path = string.format("Model/Character/%d/Prefabs/model%d.prefab", shape, shape)
		g_ResCtrl:ChangeCloneDynamicLevel("TaskNpc", path)
	end	
	local clientnpc = table.copy(monsterNnpc)
	clientnpc.pos_info = {x = 0, y = 0}--netscene.DecodePos(clientnpc.pos_info)
	if clientnpc then
		local npcid = clientnpc.npcid
		local oMonsterNpc = self.m_MonsterNpcs[npcid]
		if not oMonsterNpc then
			oMonsterNpc = CMonsterNpc.New()
			oMonsterNpc:SetData(clientnpc)
			local model_info = clientnpc.model_info
			if model_info then
				oMonsterNpc:ChangeShape(model_info.shape, model_info)
			end
			--self:SetTaskMark(oMonsterNpc, clientnpc.npctype)

			local name = string.format("[FF00FF]%s", clientnpc.name)
			local taskNpc = g_TaskCtrl:GetTaskNpc(clientnpc.npctype)
			if taskNpc and taskNpc.shortName and string.len(taskNpc.shortName) > 0 then
				name = string.format("[ADE6D8]%s[FF00FF]\n%s", taskNpc.shortName, clientnpc.name)
			end
			oMonsterNpc:UpdateName(clientnpc.name, name)
			oMonsterNpc:SetMonsterAtkCityTag(clientnpc)
			if oMonsterNpc.m_NpcAoi.npctype == "large" then
				oMonsterNpc:SetBlood(g_MonsterAtkCityCtrl.m_BossHP / g_MonsterAtkCityCtrl.m_BossHPMax)
			end
			CObject.SetName(oMonsterNpc, string.format("n%d-%s", npcid, clientnpc.name))
			self.m_MonsterNpcs[npcid] = oMonsterNpc
			self.m_Walkers[npcid] = oMonsterNpc
			self.m_IntanceID2Walker[oMonsterNpc:GetInstanceID()] = weakref(oMonsterNpc)
		end
		self:UpdateByPosInfo(oMonsterNpc, clientnpc.pos_info)
	end
end

function CMapCtrl.AddTaskPickItem(self, taskPickThing)
	--print(string.format("<color=#00FF00> >>> .%s | %s | Table:%s </color>", "AddTaskPickItem", "实例一个任务采集Model", "taskPickThing"))
	--table.print(taskPickThing)
	local pickThing = table.copy(taskPickThing)
	if pickThing then
		local pickInfo = {
			mapid = pickThing.map_id,
			pickid = pickThing.pickid,
			pos_info = {x = pickThing.pos_x, y = pickThing.pos_y},
		}

		local pickid = pickInfo.pickid
		local pickItem = DataTools.GetTaskPick(pickid)
		local modelid = pickItem.modelid
		local oTaskPickItem = self.m_TaskPickItems[pickid]
		if not oTaskPickItem then
			oTaskPickItem = CTaskPickItem.New()
			oTaskPickItem.m_PickInfo = pickInfo
			oTaskPickItem:ChangeShape(pickItem.modelid)

			local name = string.format("[FF00FF]%s", pickItem.name)
			oTaskPickItem:UpdateName(pickItem.name, name)
			CObject.SetName(oTaskPickItem, string.format("n%d-%s", modelid, pickInfo.name))
			self.m_TaskPickItems[pickid] = oTaskPickItem
			self.m_Walkers[pickid] = oTaskPickItem
			self.m_IntanceID2Walker[oTaskPickItem:GetInstanceID()] = weakref(oTaskPickItem)
		end

		self:UpdateByPosInfo(oTaskPickItem, pickInfo.pos_info)
	end
end

function CMapCtrl.SyncPos(self, eid, pPosInfo)
	if not self:IsWalkMap(self:GetResID()) then
		return
	end
	local oWalker = self:GetWalker(eid)
	if not oWalker then
		return
	end
	oWalker:WalkTo(pPosInfo.x, pPosInfo.y)
end

function CMapCtrl.SetTaskMark(self, oWalker, npctype, mode)
	local npcMark = nil
	local isEuqipTipsGuide = false
	if mode then
		if mode == define.Map.NpcMarkMode.EquipFb then
			npcMark = g_EquipFubenCtrl.m_NpcMarkSprName[1]
			isEuqipTipsGuide = not g_GuideCtrl:IsCompleteEquipTipsGuide()

		elseif mode == define.Map.NpcMarkMode.TaskChapterFb then
			npcMark = g_EquipFubenCtrl.m_NpcMarkSprName[1]
		end
	else
		npcMark = g_TaskCtrl:GetNpcAssociatedTaskMark(npctype)
	end
	oWalker:SetGuideTipsHud(isEuqipTipsGuide)
	oWalker:SetTaskMark(npcMark)
end

function CMapCtrl.RefreshTaskNpcMark(self)
	for _,v in pairs(self.m_Npcs) do
		self:SetTaskMark(v, v.m_NpcAoi.npctype, v.m_NpcAoi.mode)
	end
	for _,v in pairs(self.m_DynamicNpcs) do
		if v.m_IsHide == false then
			self:SetTaskMark(v, v.m_ClientNpc.npctype)
		end		
	end
	for _,v in pairs(self.m_TaskChapterFbNpcs) do
		if v.m_ClientNpc.IsMain then
			self:SetTaskMark(v, v.m_ClientNpc.npctype, define.Map.NpcMarkMode.TaskChapterFb)
		end
	end
end

function CMapCtrl.RefreshSpecityTaskNpcMark(self, npctype, markID)
	local npcMark = g_TaskCtrl:GetNpcMarkSprName(markID)
	if npcMark then
		for _,v in pairs(self.m_Npcs) do
			if npctype == v.m_NpcAoi.npctype then
				v:SetTaskMark(npcMark)
				return
			end
		end
		for _,v in pairs(self.m_DynamicNpcs) do			
			if npctype == v.m_ClientNpc.npctype then

				v:SetTaskMark(npcMark)
				return
			end
		end
	end
end

function CMapCtrl.LoadClientNpc(self)
	for _, obj in ipairs(self.m_ClientNpcList) do
		obj:Destroy()
	end
	self.m_ClientNpcList = {}
	
	-- local obj = CChoukaNpc.CreateNpc()
	-- table.insert(self.m_ClientNpcList, obj)

	for _, oNpc in ipairs(self.m_ClientNpcList) do
		self.m_IntanceID2Walker[oNpc:GetInstanceID()] = weakref(oNpc)
	end
end

function CMapCtrl.DelAllDynamicNpc(self)
	if self.m_DynamicNpcs and #self.m_DynamicNpcs then
		for k,v in pairs(self.m_DynamicNpcs) do
			self:DelDynamicNpc(k)
		end
	end
end

function CMapCtrl.DelDynamicNpc(self, npcid)
	local oWalker = self.m_Walkers[npcid]
	if oWalker then
		if oWalker.classname == "CDynamicNpc" then
			self.m_DynamicNpcs[npcid] = nil
			self.m_Walkers[npcid] = nil
			self.m_IntanceID2Walker[oWalker:GetInstanceID()] = nil
			oWalker:Destroy()
		else
			printerror("警告：不是动态Npc，请检查流程是否错误")
		end
	end
end

function CMapCtrl.DelAllEscortNpc(self)
	if self.m_EscortNpcs and next(self.m_EscortNpcs) then
		for k,v in pairs(self.m_EscortNpcs) do
			self:DelEscortNpc(k)
		end
	end
end

function CMapCtrl.DelAllDialogueNpc(self)
	if self.m_DialogueNpcs and next(self.m_DialogueNpcs) then
		for k,v in pairs(self.m_DialogueNpcs) do
			self:DelDialogueNpc(k)
		end
	end
end

function CMapCtrl.DelUnitDialogueNpc(self, unitId)
	if self.m_DialogueNpcs and next(self.m_DialogueNpcs) then
		for k,v in pairs(self.m_DialogueNpcs) do		
			if math.floor(k / 100) == unitId then
				self:DelDialogueNpc(k)
			end			
		end
	end
end

function CMapCtrl.DelEscortNpc(self, npctype)
	--local oWalker = self.m_Walkers[npcid]
	local oWalker = self.m_EscortNpcs[npctype]
	if oWalker then
		if oWalker.classname == "CEscortNpc" then			
			self.m_EscortNpcs[npctype] = nil
			--self.m_Walkers[npcid] = nil
			self.m_IntanceID2Walker[oWalker:GetInstanceID()] = nil			
			oWalker:Destroy()
		else
			printerror("警告：不是护送Npc，请检查流程是否错误")
		end
	end
	self:ResetFollowPartner()
end

function CMapCtrl.DelDialogueNpc(self, npcid)
	local oWalker = self.m_DialogueNpcs[npcid]
	if oWalker then
		if oWalker.classname == "CDialogueNpc" or oWalker.classname == "CHousePartner" then			
			self.m_DialogueNpcs[npcid] = nil
			self.m_IntanceID2Walker[oWalker:GetInstanceID()] = nil 					
			oWalker:Destroy()
		else
			printerror("警告：不是剧情Npc，请检查流程是否错误")
		end
	end
end

function CMapCtrl.DelAllTraceNpc(self)
	if self.m_TraceNpcs and #self.m_TraceNpcs then
		for k,v in pairs(self.m_TraceNpcs) do
			self:DelTraceNpc(k)
		end
	end
end

function CMapCtrl.DelTraceNpc(self, npctype)
	local oWalker = self.m_TraceNpcs[npctype]
	if oWalker then
		if oWalker.classname == "CTraceNpc" then
			self.m_TraceNpcs[npctype] = nil
			self.m_IntanceID2Walker[oWalker:GetInstanceID()] = nil
			oWalker:Destroy()
		else
			printerror("警告：不是跟踪Npc，请检查流程是否错误")
		end
	end
end

function CMapCtrl.DelAllTaskChapterFbNpc(self)
	if self.m_TaskChapterFbNpcs and next(self.m_TaskChapterFbNpcs) then
		for k,v in pairs(self.m_TaskChapterFbNpcs) do
			self:DelTaskChapterFbNpc(k)
		end
	end
end

function CMapCtrl.DelTaskChapterFbNpc(self, npctype)
	local oWalker = self.m_TaskChapterFbNpcs[npctype]
	if oWalker then
		if oWalker.classname == "CTaskChapterFbNpc" then
			self.m_TaskChapterFbNpcs[npctype] = nil
			self.m_IntanceID2Walker[oWalker:GetInstanceID()] = nil
			oWalker:Destroy()
		else
			printerror("警告：不是任务战役Npc，请检查流程是否错误")
		end
	end
end

function CMapCtrl.DelAllSubTalkerNpc(self)
	if self.m_SubTalkerNpcs and next(self.m_SubTalkerNpcs) then
		for k,v in pairs(self.m_SubTalkerNpcs) do
			self:DelSubTalkerNpc(k)
		end
	end
end

function CMapCtrl.DelSubTalkerNpc(self, npctype)
	local oWalker = self.m_SubTalkerNpcs[npctype]
	if oWalker then
		if oWalker.classname == "CSubTalkerNpc" then
			self.m_SubTalkerNpcs[npctype] = nil	
			self.m_IntanceID2Walker[oWalker:GetInstanceID()] = nil			
			oWalker:Destroy()
		else
			printerror("警告：不是辅助对话NPC，请检查流程是否错误")
		end
	end
end

function CMapCtrl.DelayDelSubTalkerNpc(self)
	if self.m_SubTalkerNpcs and #self.m_SubTalkerNpcs then
		for k,v in pairs(self.m_SubTalkerNpcs) do			
			v:TalkEnd()			
		end
	end
end

function CMapCtrl.DelTaskPickItem(self, pickid)
	local oWalker = self.m_Walkers[pickid]
	if oWalker then
		if oWalker.classname == "CTaskPickItem" then
			self.m_TaskPickItems[pickid] = nil
			self.m_Walkers[pickid] = nil
			self.m_IntanceID2Walker[oWalker:GetInstanceID()] = nil
			oWalker:Destroy()
		else
			printerror("警告：不是动态采集物品，请检查流程是否错误")
		end
	end
end

function CMapCtrl.ClearClientNpc(self)
	for _, obj in ipairs(self.m_ClientNpcList) do
		self.m_IntanceID2Walker[obj:GetInstanceID()] = nil
		obj:Destroy()
	end
	self.m_ClientNpcList = {}
end

function CMapCtrl.DelMonsterNpc(self, npcid)
	local oWalker = self.m_MonsterNpcs[npcid]
	if oWalker then
		if oWalker.classname == "CMonsterNpc" then
			self.m_MonsterNpcs[npcid] = nil
			self.m_Walkers[npcid] = nil
			self.m_IntanceID2Walker[oWalker:GetInstanceID()] = nil
			oWalker:Destroy()
		else
			printerror("警告：不是怪物攻城npc，请检查流程是否错误")
		end
	end
end

function CMapCtrl.DelAllMonsterNpc(self)
	for k,v in pairs(self.m_MonsterNpcs) do
		self.m_MonsterNpcs[obj:GetInstanceID()] = nil
		obj:Destroy()
	end
	self.m_MonsterNpcs = {}
end

function CMapCtrl.DelWalker(self, eid)
	local oWalker = self.m_Walkers[eid]
	if oWalker then
		if oWalker.m_Pid then
			self.m_Players[oWalker.m_Pid] = nil
			self.m_SameScreenHandler:ChangePlayerCnt(-1)
			local iTeam = oWalker.m_TeamID
			self.m_TeamMissPlayers[oWalker.m_Pid] = iTeam
			--table.print(self.m_TeamMissPlayers)
		elseif oWalker.classname == "CNpc" then
			local npcid = oWalker.m_NpcAoi.npcid
			self.m_Npcs[npcid] = nil
		elseif oWalker.classname == "CDynamicNpc" then
			local npcid = oWalker.m_ClientNpc.npcid
			self.m_DynamicNpcs[npcid] = nil
		elseif oWalker.classname == "CEscortNpc" then		
			local npcid = oWalker.m_ClientNpc.npcid
			self.m_EscortNpcs[npcid] = nil
		elseif oWalker.classname == "CDialogueNpc" then		
			local npcid = oWalker.m_ClientNpc.npcid
			self.m_DialogueNpcs[npcid] = nil			
		elseif oWalker.classname == "CTraceNpc" then		
			local npcid = oWalker.m_ClientNpc.npcid
			self.m_TraceNpcs[npcid] = nil
		elseif oWalker.classname == "CTaskChapterFbNpc" then		
			local npcid = oWalker.m_ClientNpc.npcid
			self.m_TaskChapterFbNpcs[npcid] = nil			
		elseif oWalker.classname == "CTaskPickItem" then
			local pickid = oWalker.m_PickInfo.pickid
			self.m_TaskPickItems[pickid] = nil
		elseif oWalker.classname == "CTerrawarNpc" then
			local npcid = oWalker.m_NpcAoi.npcid
			self.m_Npcs[npcid] = nil
		elseif oWalker.classname == "CMonsterNpc" then
			local npcid = oWalker.m_NpcAoi.npcid
			self.m_MonsterNpcs[npcid] = nil
		end
		if self.m_Walkers[eid] then
			self.m_Walkers[eid] = nil
		end		
		self.m_IntanceID2Walker[oWalker:GetInstanceID()] = nil
		oWalker:Destroy()
		if oWalker.m_Followers ~= nil then 
			for k,v in pairs(oWalker.m_Followers) do
				v:Destroy()
			end
		end
		self:DelayUpdateFollow()
	end
end

function CMapCtrl.IsInTeam(self, eid)
	local oWalker = self.m_Walkers[eid]
	if not oWalker then
		return false
	end
	if oWalker.m_TeamID or g_TeamCtrl:IsInTeam(oWalker.m_Pid) then
		return true
	end
	return false
end

function CMapCtrl.AddFollowPartner(self, v, eid, objName, v3)
	if table.count(self.m_EscortNpcs) > 0 and not eid then
		return
	end
	
	if eid == nil then
		if not self.m_Hero then
			return 
		end
		eid = self.m_Hero.m_Eid
		objName =  string.format("e%d-p%d-%s-%s",eid,g_AttrCtrl.pid, g_AttrCtrl.name,v.name)
		v3 = self.m_Hero:GetLocalPos()
	end
	if self:IsInTeam(eid) then
		return
	end
	local oWalker = self.m_Walkers[eid]
	if not oWalker then
		return
	end
	
	oWalker.m_Followers = oWalker.m_Followers or {}
	if not v.model_info then
		return
	end
	local oSummon = oWalker.m_Followers[v.model_info.shape]
	if oSummon then
		oSummon:UpdateName(v.name)
		oSummon:ChangeShape(v.model_info.shape, {})
		oSummon:UpdateTitle(v.title_info or {})
		return
	end
	for iShape, _ in pairs(oWalker.m_Followers) do    --现在默认只有一个跟随宠物
		self:DelFollowPartner(iShape, eid)
	end
	if v.model_info.shape == 0  then
		return
	end
	
	local function setFollow()
		oSummon:Follow(oWalker)
		oWalker.m_Followers[v.model_info.shape] = oSummon
	end
	
	oSummon = CFollowPartner.New()
	oSummon:UpdateName(v.name)
	CObject.SetName(oSummon, objName)
	oSummon:ChangeShape(v.model_info.shape, {})
	oSummon:UpdateTitle(v.title_info or {})
	if v3 then
		self:CheckFollowPosArea(oSummon, v3)
	end
	setFollow()
end

function CMapCtrl.GetHeroFollower(self, iShape)
	if not self.m_Hero or not self.m_Hero.m_Followers then
		return nil
	end
	return self.m_Hero.m_Followers[iShape]
end

function CMapCtrl.ResetFollowPartner(self, eid)
	if eid == nil or (self.m_Hero and eid == self.m_Hero.m_Eid) then
		if table.count(self.m_EscortNpcs) > 0 then
			g_MapCtrl:DelAllFollowWalker()
		else
			g_MapCtrl:DelAllFollowWalker(eid)
			for j,c in pairs(g_AttrCtrl.followers) do
				g_MapCtrl:AddFollowPartner(c)
			end
		end
	else
		local oWalker = self.m_Walkers[eid]
		if oWalker then
			local follows = oWalker.m_FollowersList or {}
			if follows then
				for k,v in pairs(follows) do
					local objName = string.format("e%d-p%d-%s-%s",oWalker.m_Eid, oWalker.m_Pid, oWalker.m_Name, v.name)
					local pos = oWalker:GetLocalPos()
					self:AddFollowPartner(v, eid, objName, Vector3.New(pos.x, pos.y, 0))
				end
			end
		end
	end
end

function CMapCtrl.UpdateFollowPartner(self)
	for eid, oWalker in pairs(self.m_Walkers) do
		local follows = oWalker.m_Followers or {}
		for _, followObj in pairs(follows) do
			followObj:SetMapID(g_MapCtrl:GetResID())
		end
	end
end

function CMapCtrl.CheckFollowPosArea(self, oWalker, posInfo)
	local posx, posy = 12, 12
	if posInfo and posInfo.x and posInfo.x > 0 and posInfo.x < 100 then
		posx, posy = posInfo.x, posInfo.y
	else
		print("服务端设置的位置超出范围！")
	end
	oWalker:SetLocalPos(Vector3.New(posx+0.5, posy, 0))
end

function CMapCtrl.DelFollowPartner(self, shape, eid)
	if eid == nil then 
		eid = self.m_Hero.m_Eid
	end
	local oWalker =self.m_Walkers[eid] 
	if oWalker then
		local followObj = self.m_Walkers[eid].m_Followers[shape]
		if followObj then
			local pid = followObj.m_Pid
			if pid and self.m_Players[pid].m_Followers then
				self.m_Players[pid].m_Followers[shape] = nil
			end
			if oWalker.m_Followers then 
				oWalker.m_Followers[shape] = nil
			end
			followObj:Destroy()
		end
	end	
end

function CMapCtrl.DelAllFollowWalker(self, eid)
	if eid == nil then 
		if self.m_Hero then
			eid = self.m_Hero.m_Eid
		end
		if not eid then
			return
		end
	end
	local oWalker =self.m_Walkers[eid] 
	if not oWalker then
		return
	end
	if oWalker.m_Followers then
		for k, followObj in pairs(oWalker.m_Followers) do
			local pid = followObj.m_Pid
			if pid and self.m_Players[pid].m_Followers then
				self.m_Players[pid].m_Followers = {}
			end
			followObj:Destroy()
		end
	end
	oWalker.m_Followers = {}
end

function CMapCtrl.CheckShowTransfer(self)
	self.m_HasTransfer = true
	if not self.m_SceneID or 
		self:IsVirtualScene() or  
		g_TreasureCtrl:IsInChuanshuoScene() then
		self.m_HasTransfer = false
	end
	
	if self.m_CurMapObj then
	local oEffectParent = self.m_CurMapObj.m_MapCompnent:GetTransferEffectParent()
		if oEffectParent then
			oEffectParent:SetActive(self.m_HasTransfer)
			self.m_TransferAreas = self.m_CurMapObj.m_MapCompnent:GetTransfer()
		end
	end
end

function CMapCtrl.CheckUIEffect(self)
	--新手村，显示梦境特效
	local mapId = self:GetMapID()
	if mapId == 200100 and not self:IsVirtualScene() then
		if not self.m_UIMengJingEffect then
			local oRoot
			local oView = CBottomView:GetView()
			if oView then
				oRoot = oView.m_DialogueAniEffctBottomRoot
			end					
			if oRoot then
				local localPath = string.format("Effect/UI/ui_eff_story/Prefabs/%s.prefab", "ui_eff_story_11_mengjing")

				local cb = function (obj)
					if not Utils.IsNil(obj) then
						local w, h = UITools.GetRootSize()	
						local offesetScale = 1
						if w > 1334 then
							offesetScale = w / 1334
						end
						local adjustScale = 1334 / 750 *  h / w
						local scale = {x=125,y=132}
						obj:SetLocalScale(Vector3.New(scale.x * offesetScale , scale.y * adjustScale * offesetScale, 1))	
					end
				end			
				self.m_UIMengJingEffect = CUIDialogueAniEffect.New(oRoot, localPath, cb)		
				self.m_UIMengJingEffect:SetName("UIMengJingEffect")
				self.m_UIMengJingEffect:SetParent(oRoot.m_Transform)	
			end	
		end
	else
		if self.m_UIMengJingEffect then
			self.m_UIMengJingEffect:Destroy()
			self.m_UIMengJingEffect = nil
		end
	end
end

function CMapCtrl.CheckTranserArea(self, pos)
	if not self.m_HasTransfer then
		return
	end
	if self.m_TransferAreas then
		for k, v in pairs(self.m_TransferAreas) do
			if pos.x >= v[1] and pos.x <= v[2] and pos.y >= v[3] and pos.y <= v[4] then
				return k
			end
		end
	end
end

function CMapCtrl.UpdateTeam(self, iTeamID, lPid)
	local list = self.m_Teams[iTeamID]
	if list then
		-- self:RemoveTeam(iTeamID)
		--需要去掉离队的成员
		local tTemp = {}
		local bIsUpdateLeader = list[1] ~= lPid[1]

		if not bIsUpdateLeader then
			for k, pid in pairs(lPid) do
				tTemp[pid] = true
			end
			for index, pid in ipairs(list) do
				if not tTemp[pid] then
					self:DelTeamMember(pid)
				end
			end
		else
			self:RemoveTeam(iTeamID)
		end
	end
	self.m_Teams[iTeamID] = lPid
	local iHeroTeam
	for i, pid in ipairs(lPid) do
		if self.m_Hero and self.m_Hero.m_Pid == pid then
			iHeroTeam = iTeamID
		end
		self.m_TeamMissPlayers[pid] = iTeamID
	end
	if iHeroTeam then
		self.m_Hero.m_TeamID = iHeroTeam
		self.m_SameScreenHandler:AddTeamPlayers()
	end
	self:DelayUpdateFollow()
	self:SysCtrlCheckHidePlayer()
end

function CMapCtrl.DelTeamMember(self, iPid)
	printc("删除队员ID："..iPid)
	local oPlayer = self.m_Players[iPid]
	if oPlayer then
		oPlayer.m_TeamID = nil
		oPlayer:DelBindObj("team_leader")
		oPlayer:Follow(nil)
		self:ResetFollowPartner(oPlayer.m_Eid)
	end
	self.m_TeamMissPlayers[iPid] = nil
end

function CMapCtrl.RemoveTeam(self, iTeamID)
	printc("队伍移除"..iTeamID)
	local list = self.m_Teams[iTeamID]
	if list then
		for i, pid in pairs(list) do
			self:DelTeamMember(pid)
		end
	end
	self.m_Teams[iTeamID] = nil
end

function CMapCtrl.DelayUpdateFollow(self)
	self:DelayCall(0.1, "UpdateFollow")
end

function CMapCtrl.UpdateFollow(self)
	if not self.m_CurMapObj then
		return
	end
	local dNeedUpdate = {}
	for pid, iTeamID in pairs(self.m_TeamMissPlayers) do
		if self.m_Players[pid] then
			dNeedUpdate[iTeamID] = true
			self.m_TeamMissPlayers[pid] = nil
		end
	end
	for iTeamID,_ in pairs(dNeedUpdate) do
		local followPlayer = nil
		local lPid = self.m_Teams[iTeamID]
		for i, pid in ipairs(lPid) do
			local oPlayer = self.m_Players[pid]
			if oPlayer then
				self:DelAllFollowWalker(oPlayer.m_Eid)
				oPlayer.m_TeamID = iTeamID
				if followPlayer then
					oPlayer:ChangeFollow(followPlayer)
					followPlayer = oPlayer
				else
					followPlayer = oPlayer
					if (i == 1) then
						oPlayer:AddBindObj("team_leader")
					end
				end
			end
		end
	end
end

function CMapCtrl.HideFightPlayer(self)
	for pid, oPlayer in pairs(self.m_Players) do
		if pid ~= g_AttrCtrl.pid and oPlayer.m_IsFight then
			oPlayer:HidePlayer("hidefight")
		end
	end
end

function CMapCtrl.ShowFightPlayer(self)
	for pid, oPlayer in pairs(self.m_Players) do
		if oPlayer.m_HideKey == "hidefight" then
			oPlayer:ShowPlayer()
			oPlayer.m_HideKey = nil
		end
	end
end

function CMapCtrl.SysCtrlCheckHidePlayer(self, bHide)
	if bHide == nil then
		bHide = g_SysSettingCtrl:GetHidePlayerEnabled() == true
	end
	bHide = bHide and not self:IsVirtualScene()
	local lTeam = {}
	if g_TeamCtrl:IsJoinTeam() then
		lTeam = self.m_Teams[g_TeamCtrl.m_TeamID]
	else
		lTeam = {g_AttrCtrl.pid}
	end
	if bHide then
		for pid, oPlayer in pairs(self.m_Players) do
			if not table.index(lTeam, pid) then
				oPlayer:HidePlayer("sysctrlhide")
			else
				if oPlayer.ShowPlayer then
					oPlayer:ShowPlayer()
					oPlayer.m_HideKey = nil
				end
			end
		end
	else
		for pid, oPlayer in pairs(self.m_Players) do
			if oPlayer.m_HideKey == "sysctrlhide" then
				oPlayer:ShowPlayer()
				oPlayer.m_HideKey = nil
			end
		end
	end
end

function CMapCtrl.GetPatrolPos(self)
	if not next(self.m_PatrolLists) then
		local t = data.patroldata.DATA[self.m_ResID]
		if t then
			t = table.copy(t)
			self.m_PatrolLists = table.shuffle(t)
		end
	end
	if self.m_PatrolLists and next(self.m_PatrolLists) then
		local pos = self.m_PatrolLists[1]
		table.remove(self.m_PatrolLists, 1)
		return pos
	end
end

function CMapCtrl.IsPatrolMap(self)
	return data.patroldata.DATA[self.m_ResID] ~= nil
end

function CMapCtrl.SetPatrol(self, bPatrol, bFree)
	self.m_IsPatrol = bPatrol
	self.m_IsPatrolFree = bFree
	self:CheckPatrol()
end

function CMapCtrl.CheckPatrol(self)
	local oHero = self:GetHero()
	if oHero then
		if oHero:IsPatroling() ~= self.m_IsPatrol then
			if self.m_IsPatrol then
				oHero:StartPatrol(self.m_IsPatrolFree)
			else
				oHero:StopPatrol()
			end
		end
	end
end

function CMapCtrl.GetRandomPos(self)
	local pos = {}
	pos.x = Mathf.Random(0, 50)
	pos.y = Mathf.Random(0, 50)
	return pos
end

function CMapCtrl.OnEventNpcList(self, npcInfoList)
	self:OnEvent(define.Map.Event.MapNpcList, npcInfoList)
end

--通过Npc的动态id得到Npc的导表Id
function CMapCtrl.GetNpcTypeByNpcId(self, npcId)
	local npcType = nil 
	local npc = nil
	npc = self:GetNpc(npcId)
	if npc then
		npcType = npc.m_NpcAoi.npctype
	end

	if not npc then
		npc = self:GetDynamicNpc(npcId) 
		if npc then
			npcType = npc.m_ClientNpc.npctype 
		end
	end

	if not npc then
		npc = self:GetEscortNpc(npcId) 
		if npc then
			npcType = npc.m_ClientNpc.npctype 
		end
	end

	if not npc then
		npc = self:GetTraceNpc(npcId)
		if npc then
			npcType = npc.m_ClientNpc.npctype 
		end
	end

	return npcType
end

function CMapCtrl.GetDynamicNpcByNpcType(self, npcType)
	local npc 
	for _, v in pairs(self.m_DynamicNpcs) do
		if v.m_ClientNpc.npctype == npcType then
			npc = v
			break
		end
	end
	return npc
end

--根据Npc导表id获取Npc动态id(只有在当前场景，才能获取到)
function CMapCtrl.GetNpcIdByNpcType(self, npcType)
	local npcId = nil 
	for id, npc in pairs(self.m_Npcs) do
		if npc.m_NpcAoi.npctype == npcType then
			npcId = id 
			break
		end
	end

	if not npcId then
		for id, npc in pairs(self.m_DynamicNpcs) do
			if npc.m_ClientNpc.npctype == npcType then
				npcId = id 
				break
			end
		end
	end

	if not npcId then
		for id, npc in pairs(self.m_EscortNpcs) do
			if npc.m_ClientNpc.npctype == npcType then
				npcId = id 
				break
			end
		end
	end

	if not npcId then
		for id, npc in pairs(self.m_TraceNpcs) do
			if npc.m_ClientNpc.npctype == npcType then
				npcId = id 
				break
			end
		end
	end

	return	npcId
end

--是否是全局NPC
function CMapCtrl.IsGlobalNpc(self, npcType)
	local b = false
		if data.npcdata.NPC.GLOBAL_NPC[npcType] ~= nil then
			b = true
		end
	return b
end

--获取全局NPC信息
function CMapCtrl.GetGlobalNpc(self, npcType)
	local t = nil 
	if npcType and npcType > 0 then
		t = data.npcdata.NPC.GLOBAL_NPC[npcType]
	end
	return t
end

-- 是否当前地图
function CMapCtrl.IsCurMap(self, mapID)
	local curMapID = g_MapCtrl:GetMapID()
	return mapID == curMapID
end

--设置自朝向主角
function CMapCtrl.FaceToHeroById(self, npcId)
	local npc = self.m_Npcs[npcId]
	
	if not npc then
		npc = self.m_DynamicNpcs[npcId]	
	end

	if npc then
		npc:FaceToHero()
		if self.m_NpcSetFaceTimer[npcId] then
			Utils.DelTimer(self.m_NpcSetFaceTimer[npcId])
			self.m_NpcSetFaceTimer[npcId] = nil
		end
	end
end

--重置NPC,动态NPC,临时NPC的朝向(对话完以后)
function CMapCtrl.ResetNPCRotionById(self, npcId)
	local npc = self.m_Npcs[npcId]

	if not npc then
		npc = self.m_DynamicNpcs[npcId]
	end

	if npc then		
		local function cb()
			if self.m_NpcSetFaceTimer[npcId] then
				Utils.DelTimer(self.m_NpcSetFaceTimer[npcId])
				self.m_NpcSetFaceTimer[npcId] = nil
			end			
			npc:ReSetFace()
		end	
	 self.m_NpcSetFaceTimer[npcId] = Utils.AddTimer(cb, 0, 0.5)	
	end
end

--对话时主角位置矫正
function CMapCtrl.HeroDialoguePosReset(self, npcid, cb)
	local npc = self.m_Npcs[npcid]
	if not npc then
		npc = self.m_DynamicNpcs[npcid]
	end
	local hero = self:GetHero()
	if npc and hero then
		local pos1 = npc:GetPos()
		pos1.z = 0
		local pos2 = hero:GetPos()
		pos2.z = 0
		local dir = pos2 - pos1
		if UITools.CheckInDistanceXY(pos1, pos2, 0.8 ) then
			local pos3 = dir:SetNormalize() * 0.8 + pos1			
			local function warp()
				hero:FaceToPos(pos1)
				if cb then
					cb()
				end
			end
			hero:WalkTo(pos3.x, pos3.y)
			Utils.AddTimer(warp, 0, 0.1)
		else
			hero:FaceToPos(pos1)
			if cb then
				cb()
			end
		end
	end
end

--对话时主角位置矫正
function CMapCtrl.HeroDialoguePosResetByWalker(self, oWalker, cb)
	local npc = oWalker
	local hero = self:GetHero()
	if npc and hero then
		local pos1 = npc:GetPos()
		pos1.z = 0
		local pos2 = hero:GetPos()
		pos2.z = 0
		local dir = pos2 - pos1
		if UITools.CheckInDistanceXY(pos1, pos2, 0.8 ) then
			local pos3 = dir:SetNormalize() * 0.8 + pos1			
			local function warp()
				hero:FaceToPos(pos1)
				if cb then
					cb()
				end
			end
			hero:WalkTo(pos3.x, pos3.y)
			Utils.AddTimer(warp, 0, 0.1)
		else
			hero:FaceToPos(pos1)
			if cb then
				cb()
			end
		end
	end
end

function CMapCtrl.CheckNpcTipsDialogue(self)
	if self.m_NpcTipsDialogueTimer ~= nil then
		Utils.DelTimer(self.m_NpcTipsDialogueTimer)
		self.m_NpcTipsDialogueTimer = nil
	end
 	self.m_NpcTipsDialogueTimer = Utils.AddTimer(callback(self, "NpcTipsDialogueUpdate"), define.Walker.Npc_Dialogue_Dalta_Time, 0)
end

function CMapCtrl.NpcTipsDialogueUpdate(self, dt)
	if self.m_Walkers and next(self.m_Walkers) then
		for k, oWalker in pairs(self.m_Walkers) do	
			if oWalker:IsInScreen() then
				if oWalker.classname == "CDynamicNpc" or oWalker.classname == "CNpc" then
					oWalker:CheckTipsDialgue()
				end
			end		
		end
	end
	return true
end

function CMapCtrl.IsAllNpcLoadDone(self, str)
	local b = true
	if str and str ~= "" then
		local list = string.split(str, "")
		if #list > 0 then
			for i = 1, #list do 
				local info = string.split(list[i], ",")
				if #info == 2 then
					local type = info[1]
					local npctype = tonumber(info[2])
					local npc = self:GetNpcIdByNpcType(npctype)
					if not npc then
						return false
					else
						printc(" is find npc ", npctype)
					end
				end
			end
		end
	end
	return b
end

function CMapCtrl.ClearTouchNpcTips(self)
	local function ClearTips(t)
		if t and next(t) ~= nil then
			for k, v in pairs(t) do
				v:SetTouchTipsTag(0)
			end
		end
	end
	ClearTips(g_MapCtrl.m_Npcs)
	ClearTips(g_MapCtrl.m_DynamicNpcs)
	ClearTips(g_MapCtrl.m_MonsterNpcs)
	ClearTips(g_MapCtrl.m_TaskChapterFbNpcs)
end

--断线重连
function CMapCtrl.ResetCtrl(self)
	--重新加载模型
	self:LocalMapLoadDone()
end

--从地图1 到 地图2 所经地图
function CMapCtrl.FindMapPath(self, s_map, e_map)
	local map_pool = {}
	for k, v in pairs(data.scenedata.DATA) do
		if next(v.transfers) then
			map_pool[v.map_id] = v
		end
	end
	local open = {}
	local close = {}
	local d = {}
	d.map_id = s_map
	d.step = 0
	d.parent = 0

	if s_map == e_map then
		return d
	end
	local isFind = false
	table.insert(open, d)

	local function get_weight_map(open_list)
		local m = nil
		local w = 0
		for k, v in pairs(open_list) do
			if m == nil then
				m = v
				w = v.step
			elseif w < v.step then
				m = v
				w = v.step				
			end			
		end
		return m
	end
	
	local function del_open_list(map, open_list)
		for k, v in pairs(open_list) do
			if map.map_id == v.map_id then
				table.remove(open_list, k)				
				break
			end
		end
	end
	local function add_close_list(map, close_list)
		table.insert(close_list, map)
	end
	local function get_map_id_form_scene_id(scene_id)		
		return data.scenedata.DATA[scene_id].map_id
	end
	local function is_not_in_open_and_close(map, open_list, close_list)
		local b = false
		for k, v in pairs(open_list) do
			if v.map_id == map then
				b = true
				break
			end
		end
		for k, v in pairs(close_list) do
			if v.map_id == map then
				b = true
				break
			end
		end
		return b
	end
	local end_map_d = nil
	repeat
		local cur_map = get_weight_map(open)
		del_open_list(cur_map, open)
		add_close_list(cur_map, close)		
		local t = map_pool[cur_map.map_id].transfers
		if not t then
			break
		end
		for k, v in pairs(t) do			
			local map_id = get_map_id_form_scene_id(v.target_scene)
			if not is_not_in_open_and_close(map_id, open, close) then
				local d = {}
				d.map_id = map_id
				d.step = cur_map.step + 1
				d.parent = cur_map.map_id
				table.insert(open, d)
				if d.map_id == e_map then
					isFind = true
					end_map_d = d
					break
				end					
			end
		end		
	until isFind == true	
	
	local way_path = {}
	table.insert(way_path, end_map_d)
	local is_start_map = false					
	local cur_d = end_map_d
	repeat
		local id = cur_d.parent
		local d = nil
		for k, v in pairs(close) do
			if v.map_id == id then
				d = v
				break
			end
		end		
		table.insert(way_path, d)
		if id == s_map then
			is_start_map = true				
		end	
		cur_d = d
	until (is_start_map == true)

	table.sort(way_path, function (a, b)
		return a.step < b.step
	end)	

	return way_path
end

function CMapCtrl.GetMapAToMapBPath(self, map_a, map_b)
	printc(string.format("GetMapAToMapBPath:%s/%s ", map_a, map_b))
	local function GetSceneIdByMapId(mapId)
		for k, v in pairs(data.scenedata.DATA) do
			if v.map_id == mapId then
				return v.id
			end
		end
	end

	local t = self:FindMapPath(map_a, map_b)

	if #t > 1 then
		for i = 1, #t do
			local targetMap = t[i + 1]
			if targetMap then
				local targetSceneId = GetSceneIdByMapId(targetMap.map_id)
				local curSceneId = GetSceneIdByMapId(t[i].map_id)				
				local d = data.scenedata.DATA[curSceneId]
				if d and next(d.transfers) then
					for k = 1, #d.transfers do
						if d.transfers[k].target_scene == targetSceneId then
							t[i].x = d.transfers[k].x
							t[i].y = d.transfers[k].y
							t[i].target_x = d.transfers[k].target_x
							t[i].target_y = d.transfers[k].target_y
							t[i].transferId = k
							break
						end
					end
				end
			end		
		end
	end
	return t
end

function CMapCtrl.UpdateMiniMapData(self, dData)
	local mdata = self.m_MiniMapData
	for mapid, hddata in pairs(dData) do
		mdata[mapid] = mdata[mapid] or {} 
		for hdname, npcdlist in pairs(hddata) do
			mdata[mapid][hdname] = npcdlist
		end
	end
end

function CMapCtrl.GetMiniMapData(self)
	return self.m_MiniMapData[self.m_MapID]
end

function CMapCtrl.GetPartolData(self)
	local mapId = self:GetMapID()
	if not mapId or g_MapCtrl.m_IsInGetPartolData == nil then
		return
	end
	mapId = mapId / 100
	local function gettable(otable)
		local d = otable
		local t = {}
		if d and next(d) and #d > 1 then
			for i = 1, #d, 2 do	
				local x = math.floor(d[i] * 10) / 10
				local y = math.floor(d[i+1] * 10) / 10	
				if i == 1 then			
					table.insert(t, {x=x, y=y})
				elseif i == #d - 1 then
					table.insert(t, {x=x, y=y})
				elseif i == #d then
					break
				else
					table.insert(t, {x=x, y=y})
				end
			end
		end
		return t
	end

	local pathTable = {}
	printc(" map id ", mapId)
	if mapId then
		local PosTable = data.patroldata.DATA[mapId]
		local update = function ()
			--printc(">>>>> update")
			if PosTable and next(PosTable) then
				local sPos
				local ePos 
				pathTable[mapId] = pathTable[mapId] or {}			
				for i = 1 , #PosTable do
					local str = ""
					if i == 1 then
						--printc(" >>>>>>>> 11  0" )
						str = string.format("%d,%d,%d,%d",  PosTable[i].x,  PosTable[i].y,  PosTable[i+1].x,  PosTable[i+1].y)
						sPos = Vector3.New(PosTable[i].x, PosTable[i].y, 0)
						ePos = Vector3.New(PosTable[i+1].x, PosTable[i+1].y, 0)
						if pathTable[mapId][str] == nil then
							g_MapCtrl:GetPath(sPos, ePos, function(list)
								table.insert(list, PosTable[i+1].x)
								table.insert(list, PosTable[i+1].y)
								pathTable[mapId][str] = self:GetPosQueue(gettable(list)) 
							end)
							return true
						end

					elseif i == #PosTable then
						str = string.format("%d,%d,%d,%d",  PosTable[i].x,  PosTable[i].y,  PosTable[i-1].x,  PosTable[i-1].y)
						if pathTable[mapId][str] == nil then
							sPos = Vector3.New(PosTable[i].x, PosTable[i].y, 0)
							ePos = Vector3.New(PosTable[i-1].x, PosTable[i-1].y, 0)
							g_MapCtrl:GetPath(sPos, ePos, function(list)
								table.insert(list, PosTable[i-1].x)
								table.insert(list, PosTable[i-1].y)								
								pathTable[mapId][str] = self:GetPosQueue(gettable(list)) 
							end)
							return true
						end

					else
						str = string.format("%d,%d,%d,%d",  PosTable[i].x,  PosTable[i].y,  PosTable[i+1].x,  PosTable[i+1].y)
						sPos = Vector3.New(PosTable[i].x, PosTable[i].y, 0)
						ePos = Vector3.New(PosTable[i+1].x, PosTable[i+1].y, 0)
						if pathTable[mapId][str] == nil then
							g_MapCtrl:GetPath(sPos, ePos, function(list)
								table.insert(list, PosTable[i+1].x)
								table.insert(list, PosTable[i+1].y)								
								pathTable[mapId][str] = self:GetPosQueue(gettable(list)) 
							end)	
							return true
						end

										
						str = string.format("%d,%d,%d,%d",  PosTable[i].x,  PosTable[i].y,  PosTable[i-1].x,  PosTable[i-1].y)
						sPos = Vector3.New(PosTable[i].x, PosTable[i].y, 0)
						ePos = Vector3.New(PosTable[i-1].x, PosTable[i-1].y, 0)
						if pathTable[mapId][str] == nil then
							g_MapCtrl:GetPath(sPos, ePos, function(list)
								table.insert(list, PosTable[i-1].x)
								table.insert(list, PosTable[i-1].y)									
								pathTable[mapId][str] = self:GetPosQueue(gettable(list)) 
							end)							
							return true
						end

					end
				end

				local cb = function ()
					printc(">>>>>生成成功 ", self.m_MydataTempMap)
					table.print(pathTable)
					self.m_Mydata[self.m_MydataTempMap] = pathTable[self.m_MydataTempMap]			
					self.m_MydataTempMap = nil
					self.m_IsInGetPartolData = false
				end
				Utils.AddTimer(cb, 0, 1)
				return false
			end	
		end



		Utils.AddTimer(update, 0.2, 0)
	end
end

function CMapCtrl.GetPosList(self, posList)
	if not posList then
		return
	end
	local iLen = #posList
	if iLen <0 then
		return
	end
	printc(" >>>>>>>>> posList start ", posList)
	table.print(posList)
	local function GetPosQueueInfo(vPos, time)
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
	local vLastPos = nil
	local vStartPos = nil
	local lPosQueue = {}
	local iTotalDis = 0
	local iNextTime = 0
	local iSafeFlag = 0
	local iRemoveCnt = 0
	local i = 1
	while i <= iLen do
		local vPos = Vector3.New(posList[i].x, posList[i].y, 0) 
		if vLastPos then
			local iPosDistance = Vector3.DistanceXY(vPos,vLastPos)
			if (iTotalDis + iPosDistance) > define.Walker.Move_Speed then
				iNextTime = iNextTime + 1000
				local vLerpPos = Vector3.Lerp(vLastPos, vPos, (define.Walker.Move_Speed-iTotalDis)/iPosDistance)
				table.insert(lPosQueue, GetPosQueueInfo(vStartPos, 1000))
				vStartPos, vLastPos = vLerpPos, vLerpPos
				table.insert(posList, i, vLerpPos)
				iLen = iLen + 1
				iTotalDis = 0
				iRemoveCnt = i - 1
			else
				iTotalDis = iTotalDis + iPosDistance
				vLastPos = vPos
				if i == iLen then
					local iTime = (iTotalDis/define.Walker.Move_Speed * 1000)
					if iTime > 100 then
						table.insert(lPosQueue, GetPosQueueInfo(vStartPos, iTime))
					end
					if #lPosQueue > 0 then
						table.insert(lPosQueue, GetPosQueueInfo(vPos, 0))
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
					table.insert(lPosQueue, GetPosQueueInfo(vLastPos, 0))
				end
			end
			break
		end
	end
	for j=1, iRemoveCnt do
		table.remove(posList, 1)
	end

	printc(" >>>>>>>>> posList end ", iRemoveCnt)
	table.print(posList)

	return posList
end

function CMapCtrl.StopHeroWalk(self, cls)
	local oHero = self:GetHero()
	if oHero and oHero:IsWalking() and not g_ActivityCtrl:IsDailyCultivating() then
		local needStop = false
		if g_TeamCtrl:IsJoinTeam() then
			if g_TeamCtrl:IsLeader() or not g_TeamCtrl:IsInTeam() then
				needStop = true
			end
		else
			needStop = true
		end
		if not needStop then
			return			
		end
		local customTable = 
		{
			 COrgMainView = true, 
			 CChapterFuBenMainView = true,
			 CDialogueStoryStartView = true,
			 CTravelView = true,
		}

		if customTable[cls] or (cls == "CLoginRewardView" and g_TaskCtrl.m_IsOpenLoginRewardView == false) then
			oHero:StopWalk()

		end		
	end
end

function CMapCtrl.GetMapInfo(self, mapId)
	local t
	local d = data.scenedata.DATA
	for k, v in pairs(d) do
		if v.map_id == mapId then
			t = v
		end
	end
	return t
end

--隐藏被开过的魂匣宝箱
function CMapCtrl.HeroBoxRecord(self, lNpcid)
	self.m_HeroBoxRecords = lNpcid
	for i,npcid in ipairs(lNpcid) do
		self:DestroyHeroBox(npcid)
	end
end

function CMapCtrl.DestroyHeroBox(self, npcid)
	local oNpc = self:GetNpc(npcid)
	if oNpc then
		self.m_Walkers[oNpc.m_Eid] = nil
		self.m_Npcs[npcid] = nil
		oNpc:Destroy()
	end
	for eid,dData in pairs(self.m_AoiBlockCache) do
		if dData.aoi_npc and dData.aoi_npc.npcid == npcid then
			self.m_AoiBlockCache[eid] = nil
			return
		end
	end
end

function CMapCtrl.CheckHeroBoxRecord(self, npcid)
	return table.index(self.m_HeroBoxRecords, npcid)
end

function CMapCtrl.AddAoiBlockCache(self, eid, dData)
	if table.count(self.m_AoiBlockCache) > 30 then
		self.m_AoiBlockCache = {}
	end
	self.m_AoiBlockCache[eid] = dData
end

function CMapCtrl.GetAoiBlockCache(self, eid)
	return self.m_AoiBlockCache[eid]
end

function CMapCtrl.ClearAoiBlockCache(self, eid)
	self.m_AoiBlockCache[eid] = nil
end

return CMapCtrl