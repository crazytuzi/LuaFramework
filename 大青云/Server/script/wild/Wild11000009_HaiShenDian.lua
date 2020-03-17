CurrentSceneScript = {}
CurrentSceneScript.Humans = {}
CurrentSceneScript.MainHuman = nil
CurrentSceneScript.Scene = nil
-----------------------------------------------------------

-- BOSS任务
CurrentSceneScript.QuestBornInfo = {
	[1600007] = {x=253, y=196, num=1, id=10050012},
	[1600025] = {x=-278, y=-382, num=1, id=10050007},
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
