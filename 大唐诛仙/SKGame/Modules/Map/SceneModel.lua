SceneModel =BaseClass(LuaModel)

-- 寻找的类型 0 点， 1 npc，2 怪物，3传送门， 4 元素（掉落..）
FindType = {
	POSITION = 0,
	NPC = 1,
	MONSTER = 2,
	DOOR = 3,
	ELEMENT = 4,
}

function SceneModel:__init()
	self._view = nil
	self.sceneId = 0 -- 当前场景id
	self.mapResId = 0 --场景资源id
	self.info = {} -- 场景配置数据
	self.sceneType = 0 --场景类型
	self.sceneName = ""
	self.scene_born_pos_ = nil --场景出生点
	self.mainPlayer = nil -- 主角数据

	self.cacheSceneObjList = {} -- 场景所有对象

	self.playerList = {} -- 玩家
	self.monList = {} -- 怪物
	self.dropList = {} -- 掉落
	self.collectList = {} -- 采集
	self.summonThingList = {} -- 召唤
	self.npcList = {} -- npc

	self.isCollecting = false --正在采集
	self.persistEffectList = {} -- 持续特效数据
	self.doorList = {}
	self.player_auto_fight_ = false --玩家自动战斗开启
	self.city_position_ = Vector3.zero
	self.first_enter_game_ = true  --玩家第一次进入游戏
	self.startSceneTime = 0 --开启时间 
	self.endSceneTime = 0 --结束的时间
	self.lifeTime = 0 --存活的时间

	self.targetPos = nil --目标点
	self.worldMapId = 0  --世界寻路的目标点

	self.buffList = {} --用来保存Syn_BuffList协议回包数据（动态的buff列表

	self.headerId = 0 --守城都护玩家编号（主城展示npc用）
	self.isHasReqShixiang = false -- 是否已经请求了石像

end 

-- 初始加载配置
function SceneModel:GetCurAllMonResMap()
	 if not self.info then return nil end
	local monCfg =  GetCfgData("monster")
	local refreshMonCfg =  GetCfgData("refreshMonster")
	local list = self.info.monsterSpawn
	local result = {}
	for _,v in pairs(list) do
		if v and v.id then
			local sl =refreshMonCfg:Get( v.id)
			if sl and sl.monsterInput and #sl.monsterInput ~= 0 then
				local spawn= sl.monsterInput
				for i=1,#spawn do
					local m = spawn[i]
					if m and m[1] then
						result[monCfg:Get(m[1]).sculptResid]=true
					end
				end
			end
		end
	end
	return result
end

--------------------------玩家----------------------
	function SceneModel:AddMainRole(vo) -- 添加主角
		if not vo then return end
		self.mainPlayer = vo
		self.playerList[vo.guid] = vo
		if self.mainPlayer then
			GlobalDispatcher:DispatchEvent(EventName.ROLE_INITED)
		end
	end

	function SceneModel:AddPlayer(vo) -- 添加玩家
		if vo == nil then return end
		if self:IsTianti() then
			TiantiModel:GetInstance():SetTTPlayerData(vo)
		end
		if self.playerList[vo.guid] then
			self:UpdatePlayer(vo)
			return
		end
		local role = RoleVo.New()
		role:InitVo(vo)
		self.playerList[role.guid] = role
		table.insert(self.cacheSceneObjList, {role, "role"})
		GlobalDispatcher:DispatchEvent(EventName.PLAYER_ADDED, role.guid)
		local playerGuid = TiantiModel:GetInstance():GetPkPlayerGuid()
		if self:IsTianti() and playerGuid and role.guid == playerGuid then
			GlobalDispatcher:DispatchEvent(EventName.TiantiRoleEnter, role)
		end
	end
	function SceneModel:SetTitle( vo )
		local p = self:GetPlayer( vo.guid )
		if player then
			if vo.type == 1 then -- 家族-- 增加家族称谓
				p.familyName = vo.title
				p.familySortId = vo.sortId
				GlobalDispatcher:Fire(EventName.PLAYER_TITLE, vo)
			elseif vo.type == 2 then -- 都护府
				-- p.guildName = vo.title
				-- p.guildPos = vo.sortId
				-- GlobalDispatcher:Fire(EventName.PLAYER_TITLE, vo)
			end
		end
		
	end

	function SceneModel:RemovePlayer( guid )
		if self.playerList[guid] ~= nil then
			local vo = self.playerList[guid]
			if self._view and not self._view.isDestroyed then
				self._view:RemovePlayer(guid)
			end
			vo:Destroy()
			self.playerList[guid] = nil
			GlobalDispatcher:DispatchEvent(EventName.PLAYER_REMOVED, guid)
		end
	end
	function SceneModel:UpdatePlayer(data)
		local roleVo = self:GetPlayer( data.guid )
		if roleVo then
			roleVo:UpateVo( data )
			GlobalDispatcher:DispatchEvent(EventName.PLAYER_UPDATED, data.guid)
		end
	end
	function SceneModel:GetPlayer( guid )
		return self.playerList[guid]
	end
	-- playerId (eid)
	function SceneModel:GetPlayerByPlayerId( playerId )
		if not playerId then return nil end
		for k,v in pairs(self.playerList) do
			if v.playerId == playerId then
				return v
			end
		end
		return nil
	end

	function SceneModel:GetPlayerList()
		return self.playerList or {}
	end
	function SceneModel:IsMainPlayer( guid )
		if self.playerList[guid] then
			return self.playerList[guid].isMainRole
		end
		return false
	end

	function SceneModel:GetMainPlayer()
		return self.mainPlayer
	end

	function SceneModel:GetMainPlayerPos()
		if self.mainPlayer then
			return self.mainPlayer.position
		end
		return Vector3.zero
	end

	function SceneModel:GetPlayerPos( guid )
		if guid then
			local player = self:GetPlayer(guid)
			if player then
				return player.position
			end
		end
		return Vector3.zero
	end

	function SceneModel:GetMainPlayerDir()
		if self.mainPlayer then
			return self.mainPlayer.direction
		end
		return Vector3.zero
	end

	function SceneModel:GetPlayerDir( guid )
		if guid then
			local player = self:GetPlayer(guid)
			if player then
				return player.direction
			end
		end
		return Vector3.zero
	end
--
-------------------------怪物-----------------------
	function SceneModel:GetMonPos( guid )
		if guid then
			local mon = self:GetMon(guid)
			if mon then
				return mon.position
			end
		end
		return Vector3.zero
	end

	function SceneModel:GetMonDir( guid )
		if guid then
			local mon = self:GetMon(guid)
			if mon then
				return mon.direction
			end
		end
		return Vector3.zero
	end

	function SceneModel:AddMon(vo)
		if vo == nil then return end
		if self.monList[vo.guid] then
			self:UpdateMon(vo)
			return
		end
		local monster = MonsterVo.New()
		monster:InitVo(vo)
		self.monList[vo.guid] = monster
		table.insert(self.cacheSceneObjList, {monster,"mon"})
		GlobalDispatcher:Fire(EventName.MONSTER_ADDED, vo.guid)
	end

	function SceneModel:RemoveMon( data )
		if data[2] == 0 then --立即死亡事件
			if self._view and not self._view.isDestroyed then
				self._view:FocusTemp()
			end
		elseif data[2] == 1 then --延时死亡事件
			if self.monList[data[1]] then
				local vo = self.monList[data[1]]
				vo:Destroy()
				self.monList[data[1]] = nil
				if self._view and not self._view.isDestroyed then
					self._view:RemoveMon(data[1])
					self._view:FocusTemp()
				end
				GlobalDispatcher:DispatchEvent(EventName.MONSTER_REMOVED, guid)
			end
		end
	end

	function SceneModel:UpdateMon(vo)
		local monVo = self:GetMon( vo.guid )
		if monVo then
			monVo:UpdateVo(vo)
		-- GlobalDispatcher:DispatchEvent(EventName.MONSTER_UPDATED)
		end
	end
	
	function SceneModel:GetMon( guid )
		return self.monList[guid]
	end
	
	--获取某种怪物的列表
	function SceneModel:GetMonListById(monsterId)
		local rtnMonList = {}
		if monsterId then
			for index, monInfo in pairs(self.monList) do
				if monInfo.eid == monsterId then
					table.insert(rtnMonList, monInfo)
				end
			end
		end
		return rtnMonList
	end
--
--------------------------召唤物--------------------
	function SceneModel:AddSummonThing(vo)
		if vo == nil then return end
		if self.summonThingList[vo.guid] then
			self:UpdateSummon(vo)
			return
		end
		local summonThing = SummonThingVo.New()
		summonThing:InitVo(vo)
		self.summonThingList[vo.guid] = summonThing
		table.insert(self.cacheSceneObjList, {summonThing,"summon"})
		GlobalDispatcher:Fire(EventName.SummonThing_ADDED, vo.guid)
	end

	function SceneModel:RemoveSummonThing( data )
		if data[2] == 0 then --立即死亡事件
			if self._view and not self._view.isDestroyed then
				self._view:FocusTemp(data[1])
			end
		elseif data[2] == 1 then --延时死亡事件
			if self.summonThingList[data[1]] then
				local vo = self.summonThingList[data[1]]
				vo:Destroy()
				self.summonThingList[data[1]] = nil
				if self._view and not self._view.isDestroyed then
					self._view:RemoveSummonThing(data[1])
				end
				GlobalDispatcher:DispatchEvent(EventName.SummonThing_REMOVED, guid)
			end
		end
	end

	function SceneModel:UpdateSummon(vo)
		local summonThingVo = self:GetSummonThing( vo.guid )
		if summonThingVo then
			summonThingVo:UpdateVo(vo)
		-- GlobalDispatcher:DispatchEvent(EventName.MONSTER_UPDATED)
		end
	end

	function SceneModel:GetSummonThing( guid )
		return self.summonThingList[guid]
	end

--------------------------npc-----------eid=guid----
	function SceneModel:GetNpcPos( eid ) -- npc door eid=guid
		if eid then
			local npc = self:GetNpc(eid)
			if npc then
				return npc.position
			end
		end
		return Vector3.zero
	end
	function SceneModel:GetNpcDir( eid )
		if eid then
			local npc = self:GetNpc(eid)
			if npc then
				return npc.direction
			end
		end
		return Vector3.zero
	end
	function SceneModel:AddNpc(vo)
		if vo == nil then return end
		if self.npcList[vo.eid] then
			self:UpdateNpc(vo)
			return
		end
		local npcVo = NpcVo.New()
		npcVo:InitVo(vo)
		self.npcList[vo.eid] = npcVo
		table.insert(self.cacheSceneObjList, {npcVo, "npc"})
		GlobalDispatcher:Fire(EventName.NPC_ADDED, vo.eid)
	end
	function SceneModel:RemoveNpc( eid )
		if self.npcList[eid] then
			local vo = self.npcList[eid]
			vo:Destroy()
			self.npcList[eid] = nil
			if self._view and not self._view.isDestroyed then
				self._view:RemoveNpc(eid)
			end
			GlobalDispatcher:DispatchEvent(EventName.NPC_REMOVED, eid)
		end
	end
	function SceneModel:UpdateNpc(vo)
		local npcVo = self:GetNpc( vo.eid )
		if npcVo then
			npcVo:UpdateVo(vo)
		end
		GlobalDispatcher:DispatchEvent(EventName.NPC_UPDATED)
	end
	function SceneModel:GetNpc( eid )
		return self.npcList[eid]
	end
	function SceneModel:GetNpcByEid( eid )
		for id, npc in pairs(self.npcList) do
			if npc.eid == eid then
				return npc
			end
		end
		return nil
	end

--------------------------传送门-----------eid=guid-
	function SceneModel:GetDoorPos( eid )
		if eid then
			local door = self:GetDoor(eid)
			if door then
				return door.position
			end
		end
		return Vector3.zero
	end
	function SceneModel:AddDoor(vo)
		if vo == nil then return end
		if self.doorList[vo.eid] then return end
		local doorVo = DoorVo.New()
		doorVo:InitVo(vo)
		vo.toLocation = vo.toLocation or {0, 0, 0}
		doorVo.objective = Vector3.New(vo.toLocation[1],vo.toLocation[2], vo.toLocation[3])
		self.doorList[vo.eid] = doorVo
		table.insert(self.cacheSceneObjList, {doorVo, "door"})
		GlobalDispatcher:Fire(EventName.DOOR_ADDED, vo.eid)
	end

	function SceneModel:GetDoor( eid )
		return self.doorList[eid]
	end

	function SceneModel:RemoveDoor( eid )
		if self.doorList[eid] then
			self.doorList[eid]:Destroy()
		end
		self.doorList[eid] = nil
		if self._view and not self._view.isDestroyed then
			self._view:RemoveDoor(eid)
		end
		GlobalDispatcher:DispatchEvent(EventName.DOOR_REMOVED, eid)
	end
--

--------------------------掉落----------------------
	function SceneModel:AddDrop(vo)
		if self.dropList[vo.eid] then return end
		local vo = SceneModel.DropItemInfoMsgToDropVo(vo)
		self.dropList[vo.eid] = vo
		table.insert(self.cacheSceneObjList, {vo, "drop"})
		GlobalDispatcher:Fire(EventName.DROP_ADDED, vo.eid)
	end
	function SceneModel:GetDrop(eid)
		return self.dropList[eid]
	end
	function SceneModel:RemoveDrop(eid)
		if not self.dropList[eid] then return end
		if self._view and not self._view.isDestroyed then
			self._view:RemoveDrop(eid)
		end
		self.dropList[eid] = nil
	end
-------------------------------------------------------

--------------------------地效----------------------
	function SceneModel:AddWigSkill(vo)
		if not vo or self.persistEffectList[vo.guid] then return end
		self.persistEffectList[vo.guid] = vo
		GlobalDispatcher:Fire(EventName.WIGSKILL_ADDED, vo.guid)
	end
	function SceneModel:GetWigSkill(guid)
		return self.persistEffectList[guid]
	end
	function SceneModel:RemoveWigSkill(guid)
		local v = self.persistEffectList[guid]
		if not v then return end
		v:Destroy()
		self.persistEffectList[guid] = nil
		if self._view and not self._view.isDestroyed then
			self._view:RemoveWigSkill(guid)
		end
	end
--------------------------采集----------------------
	function SceneModel:AddCollect(vo)
		if vo == nil then return end
		if self.collectList[vo.playerCollectId] then
			self:UpdateCollect(vo)
			return
		end

		local collectVo = CollectVo.New()

		collectVo:InitVo(vo)
		self.collectList[collectVo.playerCollectId] = collectVo
		GlobalDispatcher:Fire(EventName.AddCollectItem, self.collectList[collectVo.playerCollectId])
	end

	function SceneModel:AddCollectList(voList)
		if voList == nil then return end
		local collectList = {}
		for index = 1, #voList do
			local curCollectMsg = voList[index]
			local curCollectInfo = {}
			curCollectInfo.playerCollectId = curCollectMsg.playerCollectId
			curCollectInfo.collectId = curCollectMsg.collectId

			local curCollectVo = CollectVo.New()
			curCollectVo:InitVo(curCollectInfo)

			table.insert(collectList, curCollectVo)
			self:AddCollect(curCollectInfo)
		end
		GlobalDispatcher:Fire(EventName.AddCollectItemList, collectList)
	end


	function SceneModel:RemoveCollectList(playerCollectIdList)
		if playerCollectIdList == nil then return end
		for index = 1, #playerCollectIdList do
			local curPlayerCollectId = playerCollectIdList[index]
			self:RemoveCollect(curPlayerCollectId)
		end
		
		GlobalDispatcher:DispatchEvent(EventName.RemoveCollectItemList, playerCollectIdList)
	end

	function SceneModel:UpdateCollect(vo)
		if vo == nil then return end
		if self.collectList[vo.playerCollectId] then
			self.collectList[vo.playerCollectId]:UpdateVo(vo)
		end
	end

	function SceneModel:RemoveCollect(playerCollectId)
		if playerCollectId ~= nil then
			if self.collectList[playerCollectId] then
				self.collectList[playerCollectId]:Destroy()
				self.collectList[playerCollectId] = nil
			end
			
		end
	end

	function SceneModel:EndCollectById(playerCollectId)
		if playerCollectId then
			print("采集成功", playerCollectId)
		end
	end


	function SceneModel:IsHasCollectById(playerCollectId)
		local rtnIsHas = false
		for index, curCollectVo in pairs(self.collectList) do
			if index == playerCollectId then
				rtnIsHas = true
				break
			end
		end
		return rtnIsHas
	end

	function SceneModel:GetCollectById(playerCollectId)
		return self.collectList[playerCollectId] or {}
	end

	function SceneModel:GetCollectByCollectId(collectId)
		if collectId then
			for playerCollectId , collectInfo in pairs(self.collectList) do
				if collectInfo.collectId == collectId then
					return collectInfo
				end
			end
		end
		return {}
	end

	function SceneModel:SetCollectState(state)
		if state ~= nil then
			self.isCollecting = state
		end
	end

	function SceneModel:GetCollectState()
		return self.isCollecting
	end



--------------------------场景----------------------
	function SceneModel:GetLivingThing(guid)
		return self:GetPlayer(guid) or self:GetMon(guid) or self:GetSummonThing( guid ) or self:GetNpc(guid)
	end

	function SceneModel:GetThing(guid)
		return self:GetPlayer(guid) or self:GetMon(guid) or self:GetSummonThing( guid ) or self:GetNpc(guid) or self:GetWigSkill(guid)
	end

	-- 当前场景名
	function SceneModel:GetSceneName()
		return self.info.name or ""
	end

	--获取当前地图的pk模式
	function SceneModel:GetPkModel()
		return self.scenePkModel
	end
	
	local MapType = SceneConst.MapType
	-- 主城
	function SceneModel:IsMain()
		return self.sceneType  == MapType.Main
	end
	-- 野外
	function SceneModel:IsOutdoor()
		return self.sceneType  == MapType.Outdoor1 or self.sceneType  == MapType.Outdoor2
	end
	function SceneModel:IsOutdoor1()
		return self.sceneType  == MapType.Outdoor1
	end
	function SceneModel:IsOutdoor2()
		return self.sceneType  == MapType.Outdoor2
	end
	-- 大荒塔
	function SceneModel:IsTower()
		return self.sceneType  == MapType.Tower
	end
	-- 副本
	function SceneModel:IsCopy()
		return self.sceneType == MapType.Copy or  self.sceneType == MapType.Tower
	end
	--天梯
	function SceneModel:IsTianti()
		return self.sceneType == MapType.Tianti
	end

	function SceneModel:GetSceneLifeTime()
		local cfg = GetCfgData("mapManger"):Get(sceneId)
		if cfg then 
			return cfg.lifeTime
		end
		return 0
	end

	-- 当前场景id
	function SceneModel:SetSceneId(sid)
		collectgarbage("collect") -- 回收内存
		-- print("<color=#00ff00>============当前切换的场景id:            "..sid.."================================</color>")
		sid = tonumber(sid)
		if self.sceneId == sid then return end
		self.sceneId = sid
		self.mapResId = self:GetMapResourceBySceneId(sid) -- 设置地图资源id
	end

	function SceneModel:GetSceneId()
		return self.sceneId
	end

	-- 获取指定id的场景配置数据
	function SceneModel:GetSceneCfg(sid)
		
		return GetLocalData( "Map/SceneCfg/"..sid )
	end
	-- 获取当 前场景id的地图数据配置
	function SceneModel:GetCurSceneCfg()
		
		return self:GetSceneCfg( self.sceneId )
	end

	function SceneModel:IsInNewBeeScene()
		if self.sceneId == SceneConst.NewBeeSceneId then
			return true
		else
			return false
		end
	end

	-- 获得所有地图配置
	function SceneModel:GetWaveCfg(wave)
		return GetCfgData( "monsterwave" )[wave]
	end
	-- 视图
	function SceneModel:RegistView( view )
		self._view = view
	end
	--设置地图类型
	function SceneModel:SetMapType(mapType)
		self.sceneType = mapType
	end
	--设置PK类型
	function SceneModel:SetPkModel(pkModel)
		self.scenePkModel = pkModel
	end
	--设置玩家自己出生点
	function SceneModel:SetBornPos(bornPos)
		self.scene_born_pos_ = bornPos
	end


	--获取地图资源
	function SceneModel:GetMapResourceBySceneId(sceneId)
		--如果是大荒塔，就进入大荒塔的专用表读取资源（层数）
		local map_res_id = 0
		local cfg = GetCfgData("mapManger"):Get(sceneId)
		if cfg == nil then logWarn("场景配置不对。。。"..sceneId) return end 
		if soundMgr and cfg.sound and cfg.sound ~= "" then
			soundMgr:PlayBackSound(tostring(cfg.sound))
		end

		local map_type = cfg.mapType 
		local map_PkModel = cfg.pkModel
		self:SetMapType(map_type)
		self:SetPkModel(map_PkModel)
		self:SetBornPos(cfg.clearanceback)
		map_res_id = cfg.mapresid
		local info = self:GetSceneCfg(sceneId)
		info.name = cfg.map_name
		Astar.block = info.block
		self.info = info
		return map_res_id
	end
--
--------------------------寻路----------------------
function SceneModel:IsWayFinding()
	return self.worldMapId ~= 0 or self.targetPos ~= nil
end

--获取怪物刷新点
function SceneModel:GetMonsterRefershPos(mapId, refershId)
	local mapId = mapId
	local refershId = refershId
	if refershId~= -1 and mapId ~= -1 then
		local sceneCfg = self:GetSceneCfg(mapId)
		if sceneCfg then
			for k, v in pairs(sceneCfg.monsterSpawn)  do
				if k == refershId then
					return Vector3.New(v.location[1], v.location[2], v.location[3]) 
				end
			end
		end
	end
	return nil
end

--获取Npc坐标点
function SceneModel:GetNPCPos(npcId)
	local mapId = nil
	if npcId ~= nil and npcId ~= -1 then
		local curNpcCfg =  GetCfgData("npc"):Get(npcId)
		local curNPCInfo = nil
		if curNpcCfg then
			mapId = curNpcCfg.inScene 
			if mapId ~= -1 then
				local mapCfg = self:GetSceneCfg(mapId)
				if mapCfg then
					for npcIdIndex, npcInfo in pairs(mapCfg.npcs) do
						if npcIdIndex == npcId then
							curNPCInfo = npcInfo
							break
						end
					end
				end
			end
		end
		if curNPCInfo then
			return mapId, Vector3.New(curNPCInfo.location[1] or 0, curNPCInfo.location[2] or 0, curNPCInfo.location[3] or 0) 
		end
	end
	return nil
end

--判断某个npc是否存在于主城
function SceneModel:IsInMainCity(npcId)
	if npcId ~= nil and npcId ~= -1 then
		local curNpcCfg =  GetCfgData("npc"):Get(npcId)
		if curNpcCfg then
			mapId = curNpcCfg.inScene
			if mapId == SceneConst.MainCitySceneId then
				return true
			end
		end
	end
	return false
end

function SceneModel:GetInstance()
	if SceneModel.inst == nil then
		SceneModel.inst = SceneModel.New()
	end
	return SceneModel.inst
end

function SceneModel:Clear()
	self.sceneId = 0 -- 当前场景id
	self.headerId = 0
	self.info = {} -- 场景配置数据

	self.startSceneTime = 0 --开启时间 
	self.endSceneTime = 0 --结束的时间
	self.lifeTime = 0 --存活的时间
	self.monAppearTime = 0 --怪物出现的时间
	for k,v in pairs(self.summonThingList) do
		v:Destroy()
		self.summonThingList[k] = nil
	end
	for k,v in pairs(self.playerList) do
		v:Destroy()
		self.playerList[k] = nil
	end
	for k,v in pairs(self.npcList) do
		v:Destroy()
		self.npcList[k] = nil
	end
	for k,v in pairs(self.monList) do
		v:Destroy()
		self.monList[k] = nil
	end
	for k, v in pairs(self.dropList) do
		v:Destroy()
		self.dropList[k] = nil
	end
	for k, v in pairs(self.collectList) do
		v:Destroy()
		self.collectList[k] = nil
	end
	self.cacheSceneObjList = {}

	self.summonThingList = {}
	self.npcList = {}
	self.monList = {}
	self.playerList = {}
	self.dropList = {}
	self.collectList = {}
	self.isCollecting = false
	self.persistEffectList = {}
	self.doorList = {}
	self._view = nil
	self.sceneType = 0
	self.mainPlayer = nil
	self.buffList = {}
end

function SceneModel:__delete()
	self:Clear()
	SceneModel.inst = nil
end

function SceneModel:BuffMsgListToDic(buffVoList)
	if buffVoList then
		SerialiseProtobufList( buffVoList, function (buffVo) 
			local buffVo = SceneModel.BuffMsgToBuffVo(buffVo)
			if not self.buffList[buffVo.targetGuid] then
				self.buffList[buffVo.targetGuid] = {}
			end		
			table.insert(self.buffList[buffVo.targetGuid], buffVo)
		end)
	end
end

function SceneModel:RemoveBuff(data)
	if (not data) or (not self.buffList[data.playerGuid]) then return end
	local playerGuid = data.playerGuid
	for i = #self.buffList[playerGuid], 1, -1 do
		if self.buffList[playerGuid][i].id == data.buffGuid then
			local buff = table.remove(self.buffList[playerGuid], i)
			if buff then
				buff:Destroy()
				buff = nil
			end
		end
	end
end

function SceneModel:GetBuffList()
	return self.buffList
end

function SceneModel:GetBuffListByGUID(guid)
	local rtnBuffList = {}
	if guid then
		for k , v in pairs(self.buffList) do
			if k == guid then
				table.insert(rtnBuffList , v)
			end
		end
	end
	return rtnBuffList
end

function SceneModel.BuffMsgToBuffVo(vo)
	local buffVo = BuffVo.New()
	buffVo.id = vo.id			
	buffVo.targetGuid = vo.targetGuid	
	buffVo.attackGuid = vo.attackGuid	
	buffVo.buffId = vo.buffId		
	buffVo.type = vo.type	
	buffVo.endTime = vo.endTime
	buffVo.dmg = vo.dmg	
	buffVo.hpShow = vo.hpShow
	return buffVo
end

function SceneModel.PlayerPuppetMsgToPlayerVo(vo)
	if not vo then return nil end
	local v = {}
	v.guid = vo.guid
	v.eid = vo.eid
	v.playerId = vo.eid
	v.name = vo.name
	v.type = vo.type
	v.level = vo.level
	v.vipLevel = vo.vipLevel              ---------------------------------------------
	v.dressStyle = vo.dressStyle
	v.position = SceneModel.Vector3MsgToLocation(vo.position)
	v.direction = Vector3.New(0,vo.direction,0)
	v.moveSpeed = vo.moveSpeed
	v.hp = vo.hp
	v.mp = vo.mp
	v.hpMax = vo.hpMax
	v.mpMax = vo.mpMax
	v.state = vo.state
	v.career = vo.career
	v.weaponStyle = vo.weaponStyle -- vo.weaponEquipmentId = vo.weaponStyle
	v.guildId = vo.guildId
	v.guildName = vo.guildName
	-- v.guildPos = vo.guildPos -- 帮会职位
	print("--------帮会信息----------------->>>",vo.guildId, vo.guildName)
	v.teamId = vo.teamId
	v.pkModel = vo.pkModel
	v.pkValue = vo.pkValue
	v.nameColor = vo.nameColor
	v.familyName = vo.familyName
	v.familySortId = vo.familySortId
	if vo.buffList then
		v.buffVoList = {}
		SerialiseProtobufList( vo.buffList, function (buffVo) 
			table.insert(v.buffVoList, SceneModel.BuffMsgToBuffVo(buffVo))
		end)
	end
	v.stage = vo.stage
	v.wingStyle = vo.wingStyle
	v.battleValue = vo.battleValue
	return v
end
function SceneModel.MonsterPuppetMsgToSummonThing(vo)
	if not vo then return nil end
	local v = {}
	v.ownerGuid = vo.ownerGuid
	v.guid = vo.guid
	v.eid = vo.eid
	v.name = vo.name
	v.type = vo.type
	v.level = vo.level
	v.dressStyle = vo.dressStyle
	v.position = SceneModel.Vector3MsgToLocation(vo.position)
	v.direction = Vector3.New(0,vo.direction,0)
	v.moveSpeed = vo.moveSpeed
	v.hp = vo.hp
	v.mp = vo.mp
	v.hpMax = vo.hpMax
	v.mpMax = vo.mpMax
	v.state = vo.state

	if vo.buffList then
		v.buffVoList = {}
		SerialiseProtobufList( vo.buffList, function (buffVo) 
			table.insert(v.buffVoList, SceneModel.BuffMsgToBuffVo(buffVo))
		end)
	end
	return v
end
function SceneModel.MonsterPuppetMsgToMonsterVo(vo)
	if not vo then return nil end
	local v = {}
	v.guid = vo.guid
	v.eid = vo.eid
	v.name = vo.name
	v.type = vo.type
	v.level = vo.level
	v.dressStyle = vo.dressStyle
	v.position = SceneModel.Vector3MsgToLocation(vo.position)
	v.direction = Vector3.New(0,vo.direction,0)
	v.moveSpeed = vo.moveSpeed
	v.hp = vo.hp
	v.mp = vo.mp
	v.hpMax = vo.hpMax
	v.mpMax = vo.mpMax
	v.state = vo.state

	if vo.buffList then
		v.buffVoList = {}
		SerialiseProtobufList( vo.buffList, function (buffVo) 
			table.insert(v.buffVoList, SceneModel.BuffMsgToBuffVo(buffVo))
		end)
	end
	return v
end
function SceneModel.DropItemInfoMsgToDropVo(vo)
	if not vo then return nil end
	local v = DropItemVo.New()
	v.eid = vo.dropId or 0
	v.targetGuid = vo.targetGuid or 0
	v.itemId = vo.itemId or 0
	v.num = vo.num or 0
	v.goodsType = vo.goodsType or GoodsVo.GoodType.none
	v.dropPosition = SceneModel.Vector3MsgToLocation(vo.dropPosition)
	return v
end
function SceneModel.CollectItemInfoMsgToCollectVo(vo)
	if not vo then return nil end
	local v = {}
	v.playerCollectId = vo.playerCollectId
	v.collectId = vo.collectId
	return v
end
function SceneModel.WigSkillInfoMsgToWigSkillVo(vo)
	if not vo then return nil end
	local v = PersistEffectVo.New()
	v.guid = vo.guid
	v.skillId = vo.skillId
	v.releasePoint = SceneModel.Vector3MsgToLocation(vo.targetPoint)
	v.leftTime = vo.leftTime
	v.wigId = vo.wigId
	return v
end
function SceneModel.Vector3MsgToLocation(vo)
	if not vo then return nil end
	return Vector3.New((vo.x or 0)*0.01,(vo.y or 0)*0.01,(vo.z or 0)*0.01)
end

function SceneModel.RemoveGameObject()
	
end

function SceneModel:IsHasBoss()
	local rtnIsHasMon = false
	for key , monInfo in pairs(self.monList) do
		if monInfo.monsterType == MonsterVo.Type.Boss then
			rtnIsHasMon = true
			break
		end
	end
	return rtnIsHasMon
end

function SceneModel:CleanPathingFlag()
	self.worldMapId = 0
	self.targetPos = nil
end

function SceneModel:Reset()
	self.buffList = {}
end

function SceneModel:SetRolePKModel(pkModel)
	if pkModel then
		local mainPlayerVO = self:GetMainPlayer()
		if mainPlayerVO then
			mainPlayerVO:SetPkModel(pkModel)
		end
	end
end