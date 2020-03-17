CurrentSceneScript = {}
CurrentSceneScript.mems = {}
CurrentSceneScript.isend = false

CurrentSceneScript.BronPos = {
	[FactionTypes.FactionCrossA] = {x = 8, y = 111, dir = 6.25},
	[FactionTypes.FactionCrossB] = {x = 2, y = -135, dir = 2.83}
}

CurrentSceneScript.CheckTime = 10
CurrentSceneScript.CheckTid = nil

CurrentSceneScript.Times = 300
CurrentSceneScript.Tid = nil

function CurrentSceneScript:Startup()
	_RegSceneEventHandler(SceneEvents.HumanEnterWorld, "OnHumanEnter")
	_RegSceneEventHandler(SceneEvents.HumanKilled,"OnHumanKilled")
	_RegSceneEventHandler(SceneEvents.HumanLeaveWorld, "OnHumanLeave")

	self.Tid = self.Scene:GetModScript():CreateTimer(self.Times, "OnEndTimer");
	self.CheckTid = self.Scene:GetModScript():CreateTimer(self.CheckTime, "OnCheckTimer");
end

function CurrentSceneScript:Cleanup() 
	
end

function CurrentSceneScript:OnHumanEnter(human)
	local nRemain = self.Scene:GetModScript():GetTimerRemain(self.Tid)
	nRemain = nRemain or 0
	
	human:GetModCrossArena():OnEnter(nRemain)

	self.mems[human:GetID()] = human

	local pos = self.BronPos[human:GetFaction()]
	if pos ~= nil then
		human:LuaChangePos(pos.x, pos.y)
		human:LuaChangeDir(pos.dir)
	end
end

function CurrentSceneScript:OnHumanKilled(human, killer)
	self:OnEnd(killer:GetID())
end

function CurrentSceneScript:OnHumanLeave(human)
	self.mems[human:GetID()] = nil

	if self.isend then return end

	self:OnEnd()
end

function CurrentSceneScript:OnEndTimer(tid)
	self:OnEnd()
end

function CurrentSceneScript:OnCheckTimer(tid)
	local memcnt = 0  
	for id,human in pairs(self.mems) do
		memcnt = memcnt + 1
	end

	if memcnt <= 1 then
		self:OnEnd()
	end
end

function CurrentSceneScript:OnEnd(winid)
	if self.isend then return end

	if winid == nil then
		local record = {}

		for id,human in pairs(self.mems) do
			local hp = human:GetStat(19)
			local maxHp = human:GetStat(20)

			local hpper = 0
			if maxHp ~= 0 then
				hpper = hp / maxHp
			end

			local info = {}
			info.id = id
			info.hpper = hpper
			info.power = human:GetPower()

			table.insert(record, info)
		end

		table.sort(record, function(a, b)
			if a.hpper ~= b.hpper then
				return a.hpper > b.hpper
			else
				return a.power > b.power
			end
		end)

		if #record > 0 then
			winid = record[1].id
		end
	end
	
	winid = winid or 0

	for id,human in pairs(self.mems) do
		if winid == human:GetID() then
			human:GetModCrossArena():OnEnd(0)
		else
			human:GetModCrossArena():OnEnd(1)
		end
	end

	self.isend = true

	self.Scene:GetModScript():OnCrossArenaEnd(winid)

	self.Scene:GetModScript():CreateTimer(30, "OnLeaveTimer");
end

function CurrentSceneScript:OnLeaveTimer(tid)
	for id,human in pairs(self.mems) do
		human:GetModCrossArena():OnLeave()
	end
end

