CurrentSceneScript = {}
CurrentSceneScript.Humans = {}
CurrentSceneScript.Scene = nil

--突破成功
CurrentSceneScript.RealmBoss = 0
CurrentSceneScript.RealmBreak = false

--突破超时
CurrentSceneScript.RealmBreakTimeOut = false

--限时时间
CurrentSceneScript.LimitSecs = 5*60

--Boss出生点
CurrentSceneScript.BossPos = {
	x = -12;
	y = -1;
}
-----------------------------------------------------------

function CurrentSceneScript:Startup()
	self.SModScript = self.Scene:GetModScript()
	_RegSceneEventHandler(SceneEvents.HumanKilled,"OnHumanKilled")
	_RegSceneEventHandler(SceneEvents.MonsterKilled,"OnBossKilled")
	_RegSceneEventHandler(SceneEvents.HumanEnterWorld,"OnHumanEnter")
	_RegSceneEventHandler(SceneEvents.HumanLeaveWorld, "OnHumanLeave")
	_RegSceneEventHandler(SceneEvents.RealmBreakEvent,"OnRealmBreakEvent")
end

function CurrentSceneScript:Cleanup() 
	
end

function CurrentSceneScript:OnRealmBreakEvent(bossid)
	-- body
	self.RealmBoss = bossid
	self.Scene:GetModSpawn():Spawn(bossid, self.BossPos.x, self.BossPos.y, 0)
	--print("OnRealmBreakEvent Spawn" .. bossid)
end

function CurrentSceneScript:OnBossKilled(boss, killer,id)
	if self.RealmBreakTimeOut then return end

	if id == 10231001 or id == 10231002 or id == 10231003
		or id == 10231004 or id == 10231005 or id == 10231006
		or id == 10231007 or id == 10231008 or id == 10231009 then

		--突破成功
		self:BreakResult(0)
		self.RealmBreak = true
	end
end	

function CurrentSceneScript:OnHumanKilled(human, killer)
	
end

function CurrentSceneScript:OnHumanEnter(human)
	human:GetModRealm():GoBreakResult()
	self.SModScript:CreateTimer(self.LimitSecs, "OnBackRealmBreak")
end

function CurrentSceneScript:OnBackRealmBreak()
	--强制踢出境界突破
	if self.RealmBreak then return end
	
	self:BreakResult(1)
	self.RealmBreakTimeOut = true
	self.SModScript:SecKillMonster(self.RealmBoss)
end

function CurrentSceneScript:OnHumanLeave(human)

end

function CurrentSceneScript:BreakResult(result)
	--突破结果
	for k,v in pairs(self.Humans) do
		v:GetModRealm():SendBreakBoss(result)
	end
end
