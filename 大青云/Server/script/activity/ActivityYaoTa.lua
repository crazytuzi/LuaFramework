CurrentSceneScript = {}
CurrentSceneScript.Humans = {}
CurrentSceneScript.MainHuman = nil
CurrentSceneScript.Scene = nil

----------------------------------------------------------
CurrentSceneScript.BaseMap = 11400001  --第一层地图配置ID
CurrentSceneScript.MaxFloor = 40	   --最大40层

CurrentSceneScript.BornInfo = {
	{x=-41, y=-9, r=150, num=50},
}

CurrentSceneScript.BornSpawnIds = {
	11001001,11001002,11001003,11001004,11001005,11001006,11001007,11001008,11001009,11001010,11001011,
	11001012,11001013,11001014,11001015,11001016,11001017,11001018,11001019,11001020,11001021,11001022,
	11001023,11001024,11001025,11001026,11001027,11001028,11001029,11001030,11001031,11001032,11001033,
	11001034,11001035,11001036,11001037,11001038,11001039,11001040,
}

----------------------------------------------------------

function CurrentSceneScript:Startup()
	self.SModScript = self.Scene:GetModScript()
	self.CurrFloor = self.Scene:GetBaseMapID() - self.BaseMap + 1
	if self.CurrFloor < 1 or self.CurrFloor > self.MaxFloor then self.CurrFloor = 1 end
	_RegSceneEventHandler(SceneEvents.SceneCreated,"OnSceneCreated")
	_RegSceneEventHandler(SceneEvents.SceneDestroy,"OnSceneDestroy")
end

function CurrentSceneScript:Cleanup() 
	
end

function CurrentSceneScript:OnSceneCreated()
	local info = self.BornInfo[1]
	local id = self.BornSpawnIds[self.CurrFloor]
	if id ~= null then
		self.Scene:GetModSpawn():SpawnBatch(id, info.num, info.x, info.y, info.r)
	end
end

function CurrentSceneScript:OnSceneDestroy()

end
