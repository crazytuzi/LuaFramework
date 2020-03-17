CurrentSceneScript = {}
CurrentSceneScript.Humans = {}
CurrentSceneScript.MainHuman = nil
CurrentSceneScript.Scene = nil

CurrentSceneScript.TreasureTimeID = nil
CurrentSceneScript.TreasureOverTimeID = nil
CurrentSceneScript.Interal = 30 * 60
CurrentSceneScript.TreasureID = 40009	
CurrentSceneScript.TreasureNum = 100
CurrentSceneScript.TreasureInteral = 30
CurrentSceneScript.CurTreasurePos = {}
-----------------------------------------------------------

function CurrentSceneScript:Startup()
	self.SModScript = self.Scene:GetModScript()
	_RegSceneEventHandler(SceneEvents.HumanEnterWorld,"OnHumanEnter")
    _RegSceneEventHandler(SceneEvents.HumanLeaveWorld,"OnHumanLeave")
	_RegSceneEventHandler(SceneEvents.StartRobTreasureBox, "StartRobTreasureBox")
end

function CurrentSceneScript:Cleanup()
end

function CurrentSceneScript:OnHumanEnter(human)
end

function CurrentSceneScript:OnHumanLeave(human)
end

function CurrentSceneScript:StartRobTreasureBox()
	self.TreasureOverTimeID = self.SModScript:CreateTimer(self.Interal, "Over")
	self.TreasureTimeID = self.SModScript:CreatePeriodTimer(self.TreasureInteral, self.TreasureInteral, "RefreshTreasure")
	self:RefreshTreasure(0)
end

function CurrentSceneScript:RefreshTreasure(tid)
	self.Scene:RemoveAllCollections()
	self.SModScript:SendTreasureBox(self.TreasureID, self.TreasureNum)
end

function CurrentSceneScript:Over(tid)
	self.TreasureOverTimeID = nil
	
	if self.TreasureTimeID ~= nil then
		self.Scene:RemoveAllCollections()
		self.SModScript:CancelTimer(self.TreasureTimeID)
		self.TreasureTimeID = nil
	end
end