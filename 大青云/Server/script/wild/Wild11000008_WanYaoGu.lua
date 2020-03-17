CurrentSceneScript = {}
CurrentSceneScript.Humans = {}
CurrentSceneScript.MainHuman = nil
CurrentSceneScript.Scene = nil
-----------------------------------------------------------

-- BOSS任务
CurrentSceneScript.QuestBornInfo = {
	[1500015] = {x=1173, y=1587, num=1, id=10040007},
	[1500026] = {x=-58, y=143, num=1, id=10040010},
	[1500032] = {x=278, y=-1314, num=1, id=10040001},
}

function CurrentSceneScript:Startup()
	self.SModScript = self.Scene:GetModScript()
	self.SModSpawn = self.Scene:GetModSpawn()
	self.SModLayer = self.Scene:GetModLayer()
	_RegSceneEventHandler(SceneEvents.HumanEnterLayer,"OnHumanEnterLayer")
	_RegSceneEventHandler(SceneEvents.HumanLeaveLayer,"OnHumanLeaveLayer")
end

function CurrentSceneScript:Cleanup() 
	
end

function CurrentSceneScript:OnHumanEnterLayer(human,reason,param)
	if reason ~= LayerReasonCode.LayerQuest then
		return;
	end
	
	if self.QuestBornInfo[param] == nil then
		return;
	end

	self.SModLayer:SpawnLayerMonster(self.QuestBornInfo[param].id, self.QuestBornInfo[param].x, self.QuestBornInfo[param].y, self.QuestBornInfo[param].num, human:GetLayerId());
end

function CurrentSceneScript:OnHumanLeaveLayer(human,reason,param)
	self.SModLayer:DestroyLayerMonsters(human:GetLayerId());
end
