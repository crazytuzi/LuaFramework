CurrentSceneScript = {}
CurrentSceneScript.Humans = {}
CurrentSceneScript.MainHuman = nil
CurrentSceneScript.Scene = nil
-----------------------------------------------------------

-- BOSS任务
CurrentSceneScript.QuestBornInfo = {
	[1300013] = {x=-685, y=-653, num=14, id=10020011},
	[1300015] = {x=-648, y=-695, num=14, id=10020012},
	[1300017] = {x=-600, y=-648, num=14, id=10020013},
	[1300019] = {x=-648, y=-605, num=14, id=10020014},
	[1300002] = {x=477, y=720, num=10, id=10020015},
	[1300006] = {x=315, y=707, num=10, id=10020016},
	[1300010] = {x=-649, y=701, num=14, id=10020017},
	[1300022] = {x=-649, y=701, num=16, id=10020018},
	[1300031] = {x=825, y=-631, num=18, id=10020019},
	[1300038] = {x=276, y=-646, num=20, id=10020020},
	[1300040] = {x=227, y=-688, num=20, id=10020021}
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
