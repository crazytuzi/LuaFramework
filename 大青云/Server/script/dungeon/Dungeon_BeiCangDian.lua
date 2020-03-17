
CurrentSceneScript = {}
CurrentSceneScript.Humans = {}
CurrentSceneScript.Scene = nil

-----------------------------------------------------------
--BOSSID
CurrentSceneScript.BossID = 10500001
--BOSS出生点
CurrentSceneScript.BossPos = {x=50, z=50}

--限时时间
CurrentSceneScript.LimitSecs = 300

--BOSS 属性 倍率
CurrentSceneScript.BossAttr = 
{
	{id=28, value=0.02},
	{id=29, value=0.32},
	{id=20, value=40},
	{id=32, value=0.144},
	
	{id=31, value=0.456},
	{id=33, value=2.322},
	{id=30, value=2.191},
	{id=48, value=0},
		
	{id=39, value=0},
	{id=42, value=0},
	{id=36, value=1.02},
	{id=37, value=1},
		
	{id=38, value=0},
}
-----------------------------------------------------------

function CurrentSceneScript:Startup()
	self.SModScript = self.Scene:GetModScript()
	_RegSceneEventHandler(SceneEvents.HumanEnterWorld,"OnHumanEnter")
	_RegSceneEventHandler(SceneEvents.HumanLeaveWorld, "OnHumanLeave")
	_RegSceneEventHandler(SceneEvents.MonsterKilled,"OnMonsterKilled")
	_RegSceneEventHandler(SceneEvents.HumanKilled,"OnHumanKilled")
	_RegSceneEventHandler(SceneEvents.MonsterEnterWorld,"OnMonsterEnterWorld")	
	self.SModScript:CreateTimer(self.LimitSecs, "OnGameEnd")
end

function CurrentSceneScript:Cleanup() 
end

function CurrentSceneScript:OnHumanEnter(human)
	--刷怪
	print("OnHumanEnter")
	self.Scene:GetModSpawn():Spawn(self.BossID, self.BossPos.x,self.BossPos.z,0)
end

function CurrentSceneScript:OnHumanLeave(human)

end

function CurrentSceneScript:OnMonsterKilled(monster,killer,tid)
	for k,v in pairs(self.Humans) do
		v:GetModBeiCangJie():OnKillBoss()
		v:GetModBeiCangJie():OnActivityClose(2)
	end
end

function CurrentSceneScript:OnHumanKilled(human,killer)  

end

function CurrentSceneScript:OnMonsterEnterWorld(monster)  
	for k,v in pairs(self.Humans) do
		for attrk,attrv in pairs(self.BossAttr) do
			v:GetModBeiCangJie():OnSetMonsterAttr(monster:GetID(),attrv.id,attrv.value)
		end 
		v:GetModBeiCangJie():OnInitMonsterAttr(monster:GetID())
	end
end

function CurrentSceneScript:OnGameEnd()
	for k,v in pairs(self.Humans) do
		v:GetModBeiCangJie():OnActivityClose(2)
	end
end