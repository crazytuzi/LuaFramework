CurrentSceneScript = {}
CurrentSceneScript.Humans = {}
CurrentSceneScript.MainHuman = nil
CurrentSceneScript.Scene = nil

-- BOSS任务
CurrentSceneScript.QuestBornInfo = {
	[1200006] = {x=-950, y=-316, num=5, id=10060002},
}

-- 职业任务
CurrentSceneScript.QuestBornInfo1200008 = {
	[1] = {x=-880, y=-4, num=1, id=10010006},
	[2] = {x=-880, y=-4, num=1, id=10010106},
	[3] = {x=-880, y=-4, num=1, id=10010206},
	[4] = {x=-880, y=-4, num=1, id=10010306},
}

-----------------------------------------------------------

function CurrentSceneScript:Startup()
	self.SModSpawn = self.Scene:GetModSpawn()
	self.SModLayer = self.Scene:GetModLayer()
	_RegSceneEventHandler(SceneEvents.HumanEnterLayer,"OnHumanEnterLayer")
	_RegSceneEventHandler(SceneEvents.HumanLeaveLayer,"OnHumanLeaveLayer")
end

function CurrentSceneScript:OnHumanEnterLayer(human,reason,param)
	if reason ~= LayerReasonCode.LayerQuest then
		return;
	end
	
	if param == 1200008 then
		local prof = human:GetProf();
		self.SModLayer:SpawnLayerMonster(self.QuestBornInfo1200008[prof].id, self.QuestBornInfo1200008[prof].x, self.QuestBornInfo1200008[prof].y, self.QuestBornInfo1200008[prof].num, human:GetLayerId());
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