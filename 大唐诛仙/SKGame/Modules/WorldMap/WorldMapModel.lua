WorldMapModel = BaseClass(LuaModel)

function WorldMapModel:__init()
	self:Config()
	self:InitEvent()
	self:AddEvent()
end

function WorldMapModel:InitEvent()

end

function WorldMapModel:AddEvent()
	self.handler0 = GlobalDispatcher:AddEventListener(EventName.SCENE_LOAD_FINISH, function()
		self.NpcPosList = {}
		self.transferPosList = {}
		self.bossList = {}
		self:GetPos()
		self:GetMapUrl()
		self:GetTeam()
		self.isRemoveBoss = true
	end)
	self.handler1 = GlobalDispatcher:AddEventListener(EventName.TEAM_CHANGED, function()
		self:GetTeam()
	end)
	--[[self.handler2 = GlobalDispatcher:AddEventListener(EventName.BOSS_OUTTER, function(vo)
		if self.sceneModel.sceneId >= 2001 and self.sceneModel.sceneId <= 2009 then
			self.isRemoveBoss = true
		end
	end)]]--
	self.handler3 = GlobalDispatcher:AddEventListener(EventName.BOSS_ENTER, function(vo)
		if self.sceneModel.sceneId >= 2001 and self.sceneModel.sceneId <= 2009 then
			self.isRemoveBoss = false
		end
	end)
	self.handler4 = GlobalDispatcher:AddEventListener(EventName.MONSTER_ADDED, function(guid)
		if self.sceneModel.sceneId >= 2001 and self.sceneModel.sceneId <= 2009 then
			self.isRemoveBoss = false
		end
	end)
end

function WorldMapModel:Config()
	self.NpcPosList = {}
	self.playerPos = nil
	self.playerDir = nil
	self.bossList = {}
	self.bossState = {}
	self.transferPosList = {}
	self.mapRoadURL = ""
	self.teamPlayerList = {}
	self.teamPosList = {}
	self.isRemoveBoss = true
	self.sceneModel = SceneModel:GetInstance()
end

function WorldMapModel:RemoveEvent()
	GlobalDispatcher:RemoveEventListener(self.handler0)
	GlobalDispatcher:RemoveEventListener(self.handler1)
	GlobalDispatcher:RemoveEventListener(self.handler3)
	GlobalDispatcher:RemoveEventListener(self.handler4)
end

function WorldMapModel:GetMapUrl()
	local curMap = self.sceneModel.mapResId
	self.mapRoadURL = "Icon/Map/"..curMap
end

function WorldMapModel:GetPos()
	local curMap = self.sceneModel.sceneId
	if not curMap or curMap == 0 then print(curMap, "!!!!场景不存!!!!") return end
	local cfg = GetLocalData( "map/SceneCfg/"..curMap )
	local transferData = GetCfgData("transfer")
	local npcData = GetCfgData("npc")
	if cfg.transfer then
		for k, v in pairs(cfg.transfer) do
			table.insert(self.transferPosList, {transferData:Get(v.id).name, v.location})
		end
	end
	if cfg.npcs then
		for k, v in pairs(cfg.npcs) do
			table.insert(self.NpcPosList, {npcData:Get(k).type, npcData:Get(k).name, v.location})
		end
	end
	if curMap >= 2001 and curMap <= 2009 then
		for k,v in pairs(cfg.monsterSpawn) do
		 	table.insert(self.bossList, {v.id , v.location})
		 end 
	end
end

function WorldMapModel:GetTeam()
	for i = #self.teamPlayerList, 1, -1 do
		if self.teamPlayerList[i] ~= nil then 
			table.remove(self.teamPlayerList, i)
		end
	end
	self.teamPlayerList = {}
	local team = ZDModel:GetInstance():GetMember()
	for k,v in pairs(team) do
		table.insert(self.teamPlayerList, v)
	end
end

function WorldMapModel:GetInstance()
	if WorldMapModel.inst == nil then
		WorldMapModel.inst = WorldMapModel.New()
	end
	return WorldMapModel.inst
end

function WorldMapModel:__delete()
	self:RemoveEvent()
	self.playerPos = nil
	self.playerDir = nil
	self.bossList = nil
	self.bossState = nil
	self.NpcPosList = nil
	self.transferPosList = nil
	self.teamPlayerList = nil
	self.teamPosList = nil
	self.isRemoveBoss = true
	WorldMapModel.inst = nil
end