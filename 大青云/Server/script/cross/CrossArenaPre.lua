CurrentSceneScript = {}

CurrentSceneScript.LastTime = 1800			--持续时间
CurrentSceneScript.RobbPerc = 0.3			--掠夺比例
CurrentSceneScript.InitScore = 1000			--初始积分
CurrentSceneScript.UnRobbScore = 500		--不可抢夺积分

CurrentSceneScript.ModScript = nil
CurrentSceneScript.LastTid = nil
CurrentSceneScript.Close = false

CurrentSceneScript.Score = {}

function CurrentSceneScript:Startup()
	_RegSceneEventHandler(SceneEvents.HumanEnterWorld, "OnHumanEnter")
	_RegSceneEventHandler(SceneEvents.HumanKilled,"OnHumanKilled")
	_RegSceneEventHandler(SceneEvents.HumanLeaveWorld, "OnHumanLeave")
	self.ModScript = self.Scene:GetModScript()
	self.LastTid = self.ModScript:CreateTimer(self.LastTime, "OnEndTimer");
end

function CurrentSceneScript:Cleanup() 
	self.Score = nil
end

function CurrentSceneScript:OnHumanEnter(human)
	local nRemain = self.Scene:GetModScript():GetTimerRemain(self.LastTid)
	nRemain = nRemain or 0
	human:GetModCrossArena():OnPreEnter(nRemain)

	local score = self.Score[human:GetID()]
	if score ~= nil then
		human:GetModCrossArena():SetScore(score)
	else
		human:GetModCrossArena():SetScore(self.InitScore)
	end
end

function CurrentSceneScript:OnHumanKilled(human, killer)
	local killerPlayer = self.ModScript:Unit2Human(killer)
	if killerPlayer == nil then return end

	local curscore = human:GetModCrossArena():GetScore()
	if curscore <= self.UnRobbScore then return end

	local killscore = killerPlayer:GetModCrossArena():GetScore()
	local nRobScore = math.ceil(self.RobbPerc * curscore)

	if curscore - nRobScore < self.UnRobbScore then
		nRobScore = curscore - self.UnRobbScore
	end

	killerPlayer:GetModCrossArena():SetScore(killscore + nRobScore)
	human:GetModCrossArena():SetScore(curscore - nRobScore)
end

function CurrentSceneScript:OnHumanLeave(human)
	
	self.Score[human:GetID()] = human:GetModCrossArena():GetScore()

	human:GetModCrossArena():OnPreLeave()
end

function CurrentSceneScript:OnEndTimer(tid)
	self:OnEnd()
end

function CurrentSceneScript:OnEnd()
	if self.Close then return end

	self.ModScript:OnCrossPreArenaEnd()

	self.ModScript:CreateTimer(30, "OnLeaveTimer")

	self.Close = true
end

function CurrentSceneScript:OnLeaveTimer(tid)
	self.ModScript:OnCrossLeave()
end

