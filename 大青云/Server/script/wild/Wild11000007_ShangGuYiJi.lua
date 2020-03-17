CurrentSceneScript = {}
CurrentSceneScript.Humans = {}
CurrentSceneScript.MainHuman = nil
CurrentSceneScript.Scene = nil
-----------------------------------------------------------

-- BOSS任务
CurrentSceneScript.QuestBornInfo = {
	[1100006] = {x=-52, y=280, num=1, id=10010008},
	[1100014] = {x=-101, y=-530, num=1, id=10010005},
	[1100017] = {x=64, y=-1089, num=1, id=10010004},
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
