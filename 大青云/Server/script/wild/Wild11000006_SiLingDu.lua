CurrentSceneScript = {}
CurrentSceneScript.Humans = {}
CurrentSceneScript.MainHuman = nil
CurrentSceneScript.Scene = nil
-----------------------------------------------------------

-- BOSS任务
CurrentSceneScript.QuestBornInfo = {
	[1400021] = {x=701, y=-335, num=1, id=10030005},
	[1400008] = {x=-547, y=-665, num=1, id=10030009},
	[1400025] = {x=950, y=-42, num=1, id=10030010},
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
