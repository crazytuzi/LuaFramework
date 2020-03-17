
CurrentSceneScript = {}
CurrentSceneScript.Humans = {}
CurrentSceneScript.MainHuman = nil
CurrentSceneScript.Scene = nil
-----------------------------------------------------------
CurrentSceneScript.MonPos = {	--boss出生点
	x=22;
	z=41;
	rad= 50;
}

-- 怪物波数
CurrentSceneScript.Waves = 0
-- 怪物总波数
CurrentSceneScript.total_waves = 0
-- 挑战每波怪数量
CurrentSceneScript.kill_monster = 0
-- 战场倒计时
CurrentSceneScript.TimerTid = 0
-- 当前挑战类型
CurrentSceneScript.Type = 0
-- 总波数
CurrentSceneScript.total_waves = 0
-- 本波总怪物数
CurrentSceneScript.total_monster = 0
-- 本波怪ID
CurrentSceneScript.monster_id = 0
-- 挑战时间
CurrentSceneScript.time_limit = 0
-- 挑战状态
CurrentSceneScript.state = 0
-- 玩家等级
CurrentSceneScript.level = 40
-- Boss等级
CurrentSceneScript.BossID = 0
CurrentSceneScript.BossNum = 0
-----------------------------------------------------------
function CurrentSceneScript:Startup()
	self.SModScript = self.Scene:GetModScript()
	_RegSceneEventHandler(SceneEvents.HumanEnterWorld, "OnHumanEnter")
	_RegSceneEventHandler(SceneEvents.HumanLeaveWorld, "OnHumanLeave")
	_RegSceneEventHandler(SceneEvents.MonsterKilled,"OnMonsterKilled")

	self.time_limit = ConstsConfig["120"]["fval"] * 60
	self.state = 1
end

function CurrentSceneScript:Cleanup() 

end

function CurrentSceneScript:OnHumanEnter( human )
	self.Type = math.random(5)
	self.Scene:GetModDoor():SendDiff(self.Type)
	self.TimerTid = self.SModScript:CreateTimer(self.time_limit, "TimeEnd")
	self.Waves = 1
	self.level = human:GetLevel()
	if self.level < 40 then
		self.level = 40
	end
	
	if self.level % 10 == 0 then
		self.levelstep = self.level;
	else
		self.levelstep = math.ceil(self.level / 10) * 10;
	end
	
	self:InitWaveInfo()
	self.delay_tid = self.SModScript:CreateTimer(3, "CreateMonster")
end

function CurrentSceneScript:OnHumanLeave( human )
	self.SModScript:CancelTimer(self.TimerTid)
	self.TimerTid = 0
end

function CurrentSceneScript:OnMonsterKilled()
	if self.state ~= 1 then return end

	self.kill_monster = self.kill_monster + 1
	-- 通知客户端还有多少怪在场上
	self.Scene:GetModDoor():SendWave(self.Waves, self.kill_monster)

	--	全杀光了开始下一波
	if self.kill_monster >= self.total_monster + self.BossNum and  self.delay_tid == 0 then
		self.kill_monster = 0
		self.Waves = self.Waves + 1
		if self.Waves <= self.total_waves then
			self:InitWaveInfo()
			self.delay_tid = self.SModScript:CreateTimer(2, "CreateMonster")
		else
			self:Over(0)
		end
	end
end

function CurrentSceneScript:TimeEnd()
	self.TimerTid = 0
	self:Over(1)
end


function CurrentSceneScript:InitWaveInfo()
	local layer_info = split(SnatchdoorConfig[tostring(self.levelstep)]['number' .. tostring(self.Type)], '#')
	local monster_info = split(tostring(layer_info[self.Waves]), ',')
	self.monster_id = tonumber(monster_info[1])
	self.total_monster = tonumber(monster_info[2])
	self.total_waves = getTableLen(layer_info)

	if self.Waves == self.total_waves then
		local boss_info = split(SnatchdoorConfig[tostring(self.levelstep)]['boss'], ',')
		self.BossID = tonumber(boss_info[1])
		self.BossNum = tonumber(boss_info[2])
	end
end

function CurrentSceneScript:CreateMonster()
	if self.state ~= 1 then return end
	self.Scene:GetModDoor():SendWave(self.Waves, self.kill_monster)
	self.delay_tid = 0
	self.Scene:GetModSpawn():SpawnBatch(self.monster_id, self.total_monster, self.MonPos.x, self.MonPos.z, self.MonPos.rad)
	if self.Waves == self.total_waves then
		self.Scene:GetModSpawn():SpawnBatch(self.BossID, self.BossNum, self.MonPos.x, self.MonPos.z, 0)
	end
end

function CurrentSceneScript:Over(res)
	self.state = 2
	self.Scene:GetModDoor():SendResult(res)
	self.SModScript:CancelTimer(self.TimerTid)
	self.TimerTid = 0
	--移除所有怪
	self.Scene:RemoveAllMonster()
end