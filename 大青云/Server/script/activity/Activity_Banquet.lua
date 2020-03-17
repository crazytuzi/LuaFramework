CurrentSceneScript = {}
CurrentSceneScript.Humans = {}
CurrentSceneScript.MainHuman = nil
CurrentSceneScript.Scene = nil

CurrentSceneScript.DeskID = 20106002
CurrentSceneScript.ChairID = 40010

CurrentSceneScript.NORMAL = 1
CurrentSceneScript.VIP = 2

CurrentSceneScript.DeskList = 
{
	{},
	{}
}

CurrentSceneScript.DesksPostion = 
{
	{x = -249, z = 23, dir = 0},
	{x = 59, z = 23, dir = 0},
}

CurrentSceneScript.ChairsPostion = 
{
	{
		{x = -1, z = 21, dir = 0},
		{x = -18, z = 8, dir = 1.5418602228164673},
		{x = -17, z = -7, dir = 1.5789923667907715},
		{x = -1, z = -20, dir = 3.1367337703704834},
		{x = 16, z = -6, dir = 4.7125878969775599},
		{x = 16, z = 8, dir = 4.7177462021457117},
	},
	{
		{x = -1, z = 21, dir = 0},
		{x = -18, z = 8, dir = 1.5418602228164673},
		{x = -17, z = -7, dir = 1.5789923667907715},
		{x = -1, z = -20, dir = 3.1367337703704834},
		{x = 16, z = -6, dir = 4.7125878969775599},
		{x = 16, z = 8, dir = 4.7177462021457117},
	}
}

CurrentSceneScript.DesksVerticalOffset =
{
	{x = 0, z = -71},
	{x = 0, z = -71},
} 

CurrentSceneScript.DesksHorizontalOffset =
{
	{x = -60, z = 0},
	{x = 60, z = 0},
} 

CurrentSceneScript.DesksCount = 9
CurrentSceneScript.ChairsCount = {6, 6}
CurrentSceneScript.DeskLine = {0, 0}

CurrentSceneScript.BanquetTimeID = nil
CurrentSceneScript.BanquetInteral = 10
-----------------------------------------------------------

function CurrentSceneScript:Startup()
	self.SModScript = self.Scene:GetModScript()
	_RegSceneEventHandler(SceneEvents.HumanEnterWorld,"OnHumanEnter")
    _RegSceneEventHandler(SceneEvents.HumanLeaveWorld,"OnHumanLeave")
	_RegSceneEventHandler(SceneEvents.HumanGatherMushroom, "OnHumanGatherMushroom")
	_RegSceneEventHandler(SceneEvents.StartBanquet, "StartBanquet")
	_RegSceneEventHandler(SceneEvents.ActivityClose,"OnActivityClose")
end

function CurrentSceneScript:Cleanup()
end

function CurrentSceneScript:OnHumanEnter(human)
	if human == nil then
		return
	end
	
	local mealType = human:GetModBanquet():GetMealType()
	
	if mealType == 2 then
		self:leaveSeat(self.NORMAL, human)
	elseif mealType == 3 then
		self:leaveSeat(self.VIP, human)
	end
	
	self:SendShortestChair()
end

function CurrentSceneScript:OnHumanLeave(human)
	if human == nil then
		return
	end
	
	local mealType = human:GetModBanquet():GetMealType()
	
	if mealType == 2 then
		self:leaveSeat(self.NORMAL, human)
		human:GetModBanquet():SetLunchState(0,0)
		human:GetModBanquet():SendMealAction(40, 0, 0)
	elseif mealType == 3 then
		self:leaveSeat(self.VIP, human)
		human:GetModBanquet():SetLunchState(0,0)
		human:GetModBanquet():SendMealAction(40, 0, 0)
	end
end

function CurrentSceneScript:CreateDesks(deskType)
	if self.DeskLine[deskType] == 2 then
		return
	end
	
	self.DeskLine[deskType] = self.DeskLine[deskType] + 1
	self.DeskList[deskType][self.DeskLine[deskType]] = {}
	-- 5张桌子 
	for i = 1, self.DesksCount do
		local x = self.DesksPostion[deskType].x + self.DesksVerticalOffset[deskType].x * (i-1) + self.DesksHorizontalOffset[deskType].x * (self.DeskLine[deskType]-1)
		local z = self.DesksPostion[deskType].z + self.DesksVerticalOffset[deskType].z * (i-1) + self.DesksHorizontalOffset[deskType].z * (self.DeskLine[deskType]-1)
		local dir = self.DesksPostion[deskType].dir
		self.Scene:GetModSpawn():SpawnNpc(self.DeskID, x, z, dir)
		
		self.DeskList[deskType][self.DeskLine[deskType]][i] = {}
		-- N个椅子
		for j = 1, self.ChairsCount[deskType] do
			local x1 = x + self.ChairsPostion[deskType][j].x
			local z1 = z + self.ChairsPostion[deskType][j].z
			local dir1 = self.ChairsPostion[deskType][j].dir
			local collectionID = self.Scene:GetModSpawn():SpawnCollection(self.ChairID, x1, z1, dir1)
			for k, v in pairs(self.Humans) do
				if v ~= nil then
					v:GetModBanquet():SetLunchInfo(self.ChairID, deskType)
				end
			end
			local chair = {id = collectionID, x = 0, z = 0, human = nil, dirID = j}
			self.DeskList[deskType][self.DeskLine[deskType]][i][j] = chair	
			self.DeskList[deskType][self.DeskLine[deskType]][i][j].x = x1
			self.DeskList[deskType][self.DeskLine[deskType]][i][j].z = z1
		end
	end
end

function CurrentSceneScript:takeSeat(deskType, chairID, human)
	if human == nil then
		return
	end
	
	for i = 1, self.DeskLine[deskType] do
		for j = 1, self.DesksCount do
			for k = 1, self.ChairsCount[deskType] do
				local id = self.DeskList[deskType][i][j][k].id
				
				if id == chairID then
					self.DeskList[deskType][i][j][k].ownerid = human:GetID()	
					self:SendShortestChair()
					return self.DeskList[deskType][i][j][k].dirID
				end
			end
		end
	end
end

function CurrentSceneScript:leaveSeat(deskType, human)
	if human == nil then
		return
	end
	
	for i = 1, self.DeskLine[deskType] do
		for j = 1, self.DesksCount do
			for k = 1, self.ChairsCount[deskType] do
				local ownerid = self.DeskList[deskType][i][j][k].ownerid
				
				if ownerid ~= nil then
					if ownerid == human:GetID() then
						self.DeskList[deskType][i][j][k].ownerid = nil
						self:SendShortestChair()
						return
					end
				end
			end
		end
	end
end

function CurrentSceneScript:isSeat(deskType, chairID)
	for i = 1, self.DeskLine[deskType] do
		for j = 1, self.DesksCount do
			for k = 1, self.ChairsCount[deskType] do
				local id = self.DeskList[deskType][i][j][k].id
				
				if id == chairID then
					if self.DeskList[deskType][i][j][k].ownerid ~= nil then
						return true
					end			
				end
			end
		end
	end
	
	return false
end

function CurrentSceneScript:isNewLine(deskType)
	local nullSeats = 0
	
	for i = 1, self.DeskLine[deskType] do
		for j = 1, self.DesksCount do
			for k = 1, self.ChairsCount[deskType] do
				local ownerid = self.DeskList[deskType][i][j][k].ownerid
				
				if ownerid == nil then
					nullSeats = nullSeats + 1
				end
			end
		end
	end
	
	if nullSeats == self.ChairsCount[deskType] then
		return true
	else
		return false
	end
end

function CurrentSceneScript:SendShortestChair()
	local deskTypeArray = {self.NORMAL, self.VIP}

	for id = 1, 2 do
		local deskType = deskTypeArray[id]
		
		for i = 1, self.DeskLine[deskType] do
			for j = 1, self.DesksCount do
				for k = 1, self.ChairsCount[deskType] do
					local ownerid = self.DeskList[deskType][i][j][k].ownerid
				
					if ownerid == nil then
						x = self.DeskList[deskType][i][j][k].x
						z = self.DeskList[deskType][i][j][k].z
					
						for k, v in pairs(self.Humans) do
							local mealType = v:GetModBanquet():GetMealType()
	
							if deskType == self.NORMAL and mealType == 2 then
								v:GetModBanquet():SendShortestChair(x, z)
							elseif deskType == self.VIP and mealType == 3 then
								v:GetModBanquet():SendShortestChair(x, z)
							end
						end
					
						return
					end
				end
			end
		end
	end
end

function CurrentSceneScript:OnHumanGatherMushroom(human, gatherObject)
	if human == nil or gatherObject == nil then
		return
	end
	
	local mealType = human:GetModBanquet():GetMealType()
	
	if mealType == 1 then
		return
	end
		
	local id = gatherObject:GetID()
	
	if self:isSeat(mealType-1, id) then
		return
	end
		
	local dirID = self:takeSeat(mealType-1, id, human)	
	
	if dirID == nil then
		return
	end
	
	if self:isNewLine(mealType-1) then
		self:CreateDesks(mealType)
	end
	human:GetModBanquet():SetLunchState(2, id)
	human:GetModBanquet():SendMealAction(38, id, dirID)
end

function CurrentSceneScript:StartBanquet()
	-- 5张普通桌子
	self:CreateDesks(self.NORMAL)
	-- 5张vip桌子
	self:CreateDesks(self.VIP)
	self.BanquetTimeID = self.SModScript:CreatePeriodTimer(self.BanquetInteral, self.BanquetInteral, "OnReward")
end

function CurrentSceneScript:OnReward()
	for k, v in pairs(self.Humans) do
		v:GetModBanquet():OnReward()
	end
end

function CurrentSceneScript:OnActivityClose()
	for k, v in pairs(self.Humans) do
		v:GetModBanquet():SetLunchState(0,0)
		v:GetModBanquet():OnActivityClose()
	end
	
	if self.BanquetTimeID ~= nil then
		self.SModScript:CancelTimer(self.BanquetTimeID)
		self.BanquetTimeID = nil
	end
end