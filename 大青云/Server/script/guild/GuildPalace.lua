CurrentSceneScript = {}
CurrentSceneScript.Close = false
CurrentSceneScript.Succ = false
CurrentSceneScript.MapId = 0
CurrentSceneScript.BirthPos = {
	[0] = {x = 525, y = 607},
	[1] = {x = -542, y = -579},
}

CurrentSceneScript.Totems = {
	[0] = {
			id = 10000080,
			x = -265,
			y = 162,
			human = 0,
			guild = 0,
			guildname = "",

		},
	[1] = 
		{
			id = 10000081,
			x = 263,
			y = -200,
			human = 0,
			guild = 0,
			guildname = "",
		}	
}

CurrentSceneScript.QiZhiPos =
		{
			x = 8,
			y = 77,
			human = 0,
			guild = 0,
			isatk = 0,
		}

CurrentSceneScript.GuildAtkScore = 0
CurrentSceneScript.GuildDefScore = 0
CurrentSceneScript.TimerTid = 0


function CurrentSceneScript:Startup()
	self.SModScript = self.Scene:GetModScript()
	self.MapId = self.Scene:GetBaseMapID()
	_RegSceneEventHandler(SceneEvents.SceneCreated, "OnSceneCreated")
	_RegSceneEventHandler(SceneEvents.MonsterKilled,"OnMonsterKilled")
	_RegSceneEventHandler(SceneEvents.GuildActivityClose, "OnGuildWarClosed")
	_RegSceneEventHandler(SceneEvents.HumanEnterWorld,"OnHumanEnterWorld")
	_RegSceneEventHandler(SceneEvents.HumanLeaveWorld, "OnHumanLeaveWorld");
	_RegSceneEventHandler(SceneEvents.HumanKilled,"OnHumanKilled")
	_RegSceneEventHandler(SceneEvents.TimerExpired,"OnTimerExpired")
	_RegSceneEventHandler(SceneEvents.MonsterEnterWorld, "OnMonsterEnter")
end


function CurrentSceneScript:Cleanup() 
	
end

function CurrentSceneScript:OnSceneCreated(scene)

	for i,v in pairs(self.Totems) do
		self.Scene:GetModSpawn():Spawn(v.id, v.x, v.y, 0)
	end
end

function CurrentSceneScript:OnHumanEnterWorld(human)
	local side = 0
	if human:GetModGuildPalace():IsAtk() ~= 0 then
		side = 1
	end
	
	local pos = self.BirthPos[side]
	human:LuaChangePos(pos.x, pos.y)

	 for i,v in pairs(self.Totems) do
		 if v.guild == human:GetModGuild():GetGuildID() then
			human:GetModGuildPalace():AddBuff()
		 end
	 end
	 
	if self.QiZhiPos.guild == 0 then
		human:GetModGuildPalace():SendQiPos(self.QiZhiPos.x,self.QiZhiPos.y)
	end
	
	self:SendKillZhuInfo()
	self:SendScoreInfo()
end

function CurrentSceneScript:OnHumanLeaveWorld(human)
	--if self.Succ then return end

	for i,v in pairs(self.Totems) do
		 if v.guild == human:GetModGuild():GetGuildID() then
			human:GetModGuildPalace():RemoveBuff()
		 end
	 end
	 
	self:OnLostQiZhi(human)
	human:GetModGuildPalace():OnLeave()
	self:SendScoreInfo()
end

function CurrentSceneScript:OnMonsterEnter(monster)
	local monId = monster:GetMonId()
	 for i,v in pairs(self.Totems) do
		 if v.guild ~=0 and v.id == monId then
			monster:SetBelong(MonsterBelongType.Belong_Guild, v.guild, true)
		 end
	end
end

function CurrentSceneScript:OnTimerExpired(curr)
	self.SModScript:OnPalaceSendQiPos(self.MapId,self.QiZhiPos.human,self.QiZhiPos.x,self.QiZhiPos.y)
end

function CurrentSceneScript:OnLostQiZhi(human)

	if human == nil then
		 return 
	end

	if self.QiZhiPos.human == human:GetID() then
		local selfPos = human:GetPos()
		self.QiZhiPos.human = 0
		self.QiZhiPos.guild = 0
		self.QiZhiPos.x = selfPos[1]
		self.QiZhiPos.y = selfPos[3]
		human:GetModGuildPalace():RemoveQiBuff()
		self.SModScript:OnPalaceChangePos(self.MapId,selfPos[1],selfPos[3])
		self.SModScript:CancelTimer(self.TimerTid)
	end
end

function CurrentSceneScript:OnMonsterKilled(monster, killer,id)

 	local killerPlayer = self.SModScript:Unit2Human(killer)
	if killerPlayer == nil then
		 return 
	end
	
	local guild = killerPlayer:GetModGuild():GetGuildID()
	
 	 for i,v in pairs(self.Totems) do
		 if v.id == id then
		 
			local oldguild = v.guild
			if oldguild == guild then
				return
			end
			
			v.human 	= killerPlayer:GetID()
			v.guild		= killerPlayer:GetModGuild():GetGuildID()
			v.guildname = killerPlayer:GetModGuild():GetGuildName()

			self.SModScript:OnPalaceAddBuff(self.MapId,v.guild)
			self.SModScript:OnPalaceRemoveBuff(self.MapId,oldguild)			
		 end
	 end
	 
	self.SModScript:OnPalaceZhuZiNotice(self.MapId,guild,id)
	self:SendKillZhuInfo()
end

function CurrentSceneScript:OnGuildWarClosed()
	self.Close = true
	_UnRegSceneEventHandler(self.Scene, SceneEvents.SceneCreated)
	_UnRegSceneEventHandler(self.Scene, SceneEvents.MonsterKilled)
	_UnRegSceneEventHandler(self.Scene, SceneEvents.HumanKilled)	
	_UnRegSceneEventHandler(self.Scene, SceneEvents.TimerExpired)	
	
	self.SModScript:OnPalaceWarReward(self.MapId,self.GuildAtkScore,self.GuildDefScore)
end

function CurrentSceneScript:OnHumanKilled(human,killer)  
	local killerPlayer = self.SModScript:Unit2Human(killer)
	if killerPlayer == nil then
		 return 
	end
	
	if killerPlayer:GetModGuildPalace():IsAtk() == 0 then
		self.GuildAtkScore = self.GuildAtkScore + 1
	else
		self.GuildDefScore = self.GuildDefScore + 1
	end
	
	if self.QiZhiPos.human == human:GetID() then
	
		human:GetModGuildPalace():RemoveQiBuff()
		self.SModScript:CancelTimer(self.TimerTid)
	
		self.QiZhiPos.human = killerPlayer:GetID()
		self.QiZhiPos.guild = killerPlayer:GetModGuild():GetGuildID()
		self.QiZhiPos.x = 0
		self.QiZhiPos.y = 0
		
		if killerPlayer:GetModGuildPalace():IsAtk() == 0 then
			self.QiZhiPos.isatk = 0
		else
			self.QiZhiPos.isatk = 1
		end
		
		self.TimerTid = self.SModScript:CreateTimer(3, "OnQiTime") 
		killerPlayer:GetModGuildPalace():AddQiBuff()
	end
	self:SendScoreInfo()
end

function CurrentSceneScript:OnFlagHandle(human)
	if self.QiZhiPos.human ~= 0 then
		return -1
	end
	
	self.QiZhiPos.human = human:GetID()
	self.QiZhiPos.guild = human:GetModGuild():GetGuildID()
	self.QiZhiPos.x = 0
	self.QiZhiPos.y = 0
	
	if human:GetModGuildPalace():IsAtk() == 0 then
		self.QiZhiPos.isatk = 0
	else
		self.QiZhiPos.isatk = 1
	end
	
	self.TimerTid = self.SModScript:CreateTimer(3, "OnQiTime") 
	human:GetModGuildPalace():AddQiBuff()
	self:SendScoreInfo()
	return 0
end

function CurrentSceneScript:OnQiTime()
	if self.QiZhiPos.isatk == 0 then
		self.GuildAtkScore = self.GuildAtkScore + 1
	else
		self.GuildDefScore = self.GuildDefScore + 1
	end
	self.TimerTid = self.SModScript:CreateTimer(3, "OnQiTime") 
	self:SendScoreInfo()
end

function CurrentSceneScript:SendKillZhuInfo()
	self.SModScript:OnSendKillZhuZi(self.MapId,self.Totems[0].id,self.Totems[0].guild,self.Totems[1].id,self.Totems[1].guild)
end

function CurrentSceneScript:SendScoreInfo()
	self.SModScript:OnSendScoreInfo(self.MapId,self.QiZhiPos.human,self.GuildAtkScore,self.GuildDefScore)
end
