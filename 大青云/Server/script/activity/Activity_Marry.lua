
CurrentSceneScript = {}
CurrentSceneScript.Scene = nil
CurrentSceneScript.ModScript = nil
CurrentSceneScript.CurTreasurePos = {}
CurrentSceneScript.TreasureTid = nil
CurrentSceneScript.TreasureId = 0
CurrentSceneScript.LastTid = nil

CurrentSceneScript.Interal = 10 * 60					--持续时间
CurrentSceneScript.TreasureId1 = 713					--普通婚礼宝箱ID
CurrentSceneScript.TreasureId2 = 714					--高级婚礼宝箱ID
CurrentSceneScript.TreasureInteral = 60 				--宝箱刷新间隔
CurrentSceneScript.TreasureNum = 10 					--宝箱数量
CurrentSceneScript.TreasurePos = {						--宝箱位置
	{x=22,y=188,dir=0},
	{x=-3,y=315,dir=0},
	{x=-13,y=281,dir=0},
	{x=-14,y=252,dir=0},
	{x=-77,y=159,dir=0},
	{x=20,y=145,dir=0},
	{x=55,y=101,dir=0},
	{x=-142,y=-72,dir=0},
	{x=102,y=-55,dir=0},
	{x=56,y=-146,dir=0},
	{x=-78,y=-108,dir=0},
	{x=-32,y=-81,dir=0},
	{x=1,y=-142,dir=0},
	{x=-63,y=-146,dir=0},
	{x=29,y=-30,dir=0},
	{x=29,y=-110,dir=0},
	{x=-15,y=110,dir=0},
	{x=-66,y=114,dir=0},
	{x=-89,y=-55,dir=0},
	{x=-17,y=197,dir=0},
	{x=-59,y=179,dir=0},
}

function CurrentSceneScript:Startup()
	self.ModScript = self.Scene:GetModScript()
	_RegSceneEventHandler(SceneEvents.HumanEnterWorld, "OnHumanEnter")
	_RegSceneEventHandler(SceneEvents.HumanLeaveWorld, "OnHumanLeave")
	_RegSceneEventHandler(SceneEvents.MarryStart, "StartTreasure")
end

function CurrentSceneScript:Cleanup() 
	self.CurTreasurePos = nil
	self.TreasurePos = nil
end

function CurrentSceneScript:OnHumanEnter( human )	
	if self.LastTid ~= nil then
		local nRemain = self.ModScript:GetTimerRemain(self.LastTid)
		self.ModScript:OnEnterMarry(human, nRemain)
	end
end

function CurrentSceneScript:OnHumanLeave( human )

end

function CurrentSceneScript:StartTreasure(marryType)	
	if self.LastTid ~= nil then
		self.ModScript:CancelTimer(self.LastTid)
		self.LastTid = nil
	end

	if self.TreasureTid ~= nil then
		self.Scene:RemoveAllCollections()
		self.ModScript:CancelTimer(self.TreasureTid)
		self.TreasureTid = nil
	end

	if marryType == 1 then
		self.TreasureId = self.TreasureId1
	elseif marryType == 2 then
		self.TreasureId = self.TreasureId2
	else
		self.TreasureId = 0
	end

	if self.TreasureId ==  0 then return end

	self.LastTid = self.ModScript:CreateTimer(self.Interal, "OnEndTimer")
	self.TreasureTid = self.ModScript:CreatePeriodTimer(self.TreasureInteral, self.TreasureInteral, "RefreshTreasure")

	local nRemain = self.ModScript:GetTimerRemain(self.LastTid)
	for k,v in pairs(self.Humans) do
		self.ModScript:OnEnterMarry(v, nRemain)
	end
	
	--self:RefreshTreasure(0)
end

function CurrentSceneScript:RefreshTreasure(tid)
	self.Scene:RemoveAllCollections()

	self.CurTreasurePos = {}
	for k, v in pairs(self.TreasurePos) do
		table.insert(self.CurTreasurePos, v)
	end

	local getGatherPos = function()
			if #self.CurTreasurePos <=0 then return nil end
			local idx = math.random(1, #self.CurTreasurePos)
			local pos = self.CurTreasurePos[idx]
			table.remove(self.CurTreasurePos, idx)
			return pos
	end

	local modSpawn = self.Scene:GetModSpawn()
	for i = 1, self.TreasureNum do
		local pos = getGatherPos()
		if pos ~= nil then
			modSpawn:SpawnCollection(
				self.TreasureId, 
				pos.x, 
				pos.y,
				pos.dir)
		end
	end
end

function CurrentSceneScript:OnEndTimer(tid)
	self.LastTid = nil
	if self.TreasureTid ~= nil then
		self.Scene:RemoveAllCollections()
		self.ModScript:CancelTimer(self.TreasureTid)
		self.TreasureTid = nil
	end
end