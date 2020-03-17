CurrentSceneScript = {}
CurrentSceneScript.Humans = {}
CurrentSceneScript.Scene = nil

-----------------------------------------------------------
CurrentSceneScript.BirthPos = {					-- 出生点
	[FactionTypes.FactionCampA] = {553, 627},
	[FactionTypes.FactionCampB] = {-576, -609},
}
CurrentSceneScript.RevivePos = {				-- 复活点
	[FactionTypes.FactionCampA] = {553, 627},
	[FactionTypes.FactionCampB] = {-576, -609},
}
CurrentSceneScript.FlagPos = {					-- 普通旗帜
	[FactionTypes.FactionCampA] = {{-366, -184}, {348, -163}},--A采A,前北后南
	[FactionTypes.FactionCampB] = {{-368, 120}, {351, 146}},
}
CurrentSceneScript.SpecialFlagPos = {			-- 特殊旗帜
	[1] = {-462, 476},--北
	[2] = {374, -444},--南
}

CurrentSceneScript.FlagsHome = {				-- 交旗点
	[FactionTypes.FactionCampA] = {-3, 600, 40},
	[FactionTypes.FactionCampB] = {18, -581, 40},
}
CurrentSceneScript.TimerCounter = 30*60			-- 战场持续时间(s)
-----------------------------------------------------------
CurrentSceneScript.ActivityClose = false
CurrentSceneScript.FlagTimer = 0
CurrentSceneScript.WinCamp = nil
CurrentSceneScript.HumanIdx = 0
CurrentSceneScript.FirstBlood = true
CurrentSceneScript.FirstFlag = true

CurrentSceneScript.Camp_A = FactionTypes.FactionCampA
CurrentSceneScript.Camp_B = FactionTypes.FactionCampB

CurrentSceneScript.Records = {}
CurrentSceneScript.Flags = {}
CurrentSceneScript.SpecialFlags = {}

CurrentSceneScript.KillRank = {}
CurrentSceneScript.ContriRank = {}
CurrentSceneScript.MultiKillRank = {}

CurrentSceneScript.Scores = {
	[FactionTypes.FactionCampA] = 0,
	[FactionTypes.FactionCampB] = 0,
}

CurrentSceneScript.MonCount = {
	[FactionTypes.FactionCampA] = 0,
	[FactionTypes.FactionCampB] = 0,
}

CurrentSceneScript.FlagNone = 0
CurrentSceneScript.FlagCanPick = 1
CurrentSceneScript.FlagCarry = 2
-----------------------------------------------------------

function CurrentSceneScript:Startup()
	self.SModScript = self.Scene:GetModScript()
    _RegSceneEventHandler(SceneEvents.SceneCreated,"OnSceneCreated")
    _RegSceneEventHandler(SceneEvents.SceneDestroy,"OnSceneDestroy")
    _RegSceneEventHandler(SceneEvents.ActivityClose,"OnActivityClose")
	_RegSceneEventHandler(SceneEvents.HumanEnterWorld,"OnHumanEnter")
    _RegSceneEventHandler(SceneEvents.HumanLeaveWorld,"OnHumanLeave")
	_RegSceneEventHandler(SceneEvents.HumanKilled,"OnHumanKilled")
	_RegSceneEventHandler(SceneEvents.TimerExpired,"OnTimerExpired")
	_RegSceneEventHandler(SceneEvents.MonsterKilled,"OnMonsterKilled")
	_RegSceneEventHandler(SceneEvents.HumanRelive, "OnHumanRelive")
end

function CurrentSceneScript:Cleanup() 
	
end

function CurrentSceneScript:OnSceneCreated()
	-- 场景创建后 todo:
	for camp=6,7 do
		for idx=1,2 do
			local flag = {}
			flag.idx = camp*10+idx
			flag.camp = camp
			flag.pos = self.FlagPos[camp][idx]
			flag.can_pick = self.FlagCanPick

			self.Flags[flag.idx] = flag
		end
	end
	for idx=1,2 do
		local flag = {}
		flag.camp = 0
		flag.idx = idx
		flag.pos = self.SpecialFlagPos[idx]
		flag.can_pick = self.FlagNone

		self.SpecialFlags[flag.idx] = flag
	end
	self.WinCamp = math.random(self.Camp_A, self.Camp_B)
end

function CurrentSceneScript:OnSceneDestroy()
	-- 场景销毁后 todo:
	self.Records = {}
	self.Flags = {}
	self.SpecialFlags = {}
end

function CurrentSceneScript:OnActivityClose()
	self.ActivityClose = true
	if self.Scores[self.Camp_A] > self.Scores[self.Camp_B] then
		self.WinCamp = self.Camp_A
	elseif self.Scores[self.Camp_A] == self.Scores[self.Camp_B] then
		if self.Scores[self.Camp_A] == 0 then
			local change = true
			for k,v in pairs(self.Humans) do
				if v:GetFaction() ==  self.WinCamp then
					change = false
					break
				end
			end
			if change then
				if self.WinCamp == self.Camp_A then
					self.WinCamp = self.Camp_B
				else
					self.WinCamp = self.Camp_A
				end
			end
		end
	else
		self.WinCamp = self.Camp_B
	end
	
	self:SortKillRank(true)
	self:SortMultiKillRank(true)
	self:SortContriRank(self.WinCamp)

	self:SendTopPlayerID()
end

function CurrentSceneScript:OnActivityClear()
	
end

function CurrentSceneScript:OnTimerExpired(curr)
	if self.ActivityClose then return end
	-- 每秒触发一次
	self.TimerCounter = self.TimerCounter - 1
	if self.TimerCounter < 0 then self.TimerCounter  = 0 end
	if self.FlagTimer >= 2*60 then
		self:RefreshFlags()
		self:SendUpdateInfo(CampTypes.CampFlagCounter, 2*60)
		self.FlagTimer = 0
	else
		self.FlagTimer = self.FlagTimer + 1
	end
end

function CurrentSceneScript:ChooseCamp(human)
	local record = {}
	record.kill_num = 0
	record.multi_kill = 0
	record.max_multi_kill = 0
	record.contribute = 0
	record.humanID = human:GetID()
	record.flagIdx = 0
	record.humanIdx = self.HumanIdx
	self.HumanIdx = self.HumanIdx + 1

	record.old_pk = {human:GetModPK():GetPKMod(), human:GetModPK():GetPKFlag()}

	human:GetModPK():SetPKMod(4, 0)
	record.camp = self:SelectCamp()
	human:ChangeFaction(record.camp)
	human:LuaChangePos(self.BirthPos[record.camp][1], self.BirthPos[record.camp][2])
	
	self.Records[human:GetID()] = record
end

function CurrentSceneScript:OnHumanEnter(human)
	self:ChooseCamp(human)

	self:SendCampInfo(human:GetID())
	self:SendHumanFlagList(human:GetID())

	if #self.KillRank < 5 then 
		self:SortKillRank() 
	else
		self:SendKillRank(human:GetID())
	end

	if #self.MultiKillRank < 5 then
		self:SortMultiKillRank()
	else
		self:SendMultikillRank(human:GetID())
	end

	if #self.ContriRank < 5 then 
		self:SortContriRank() 
	else
		self:SendContriRank(human:GetID())
	end
end

function CurrentSceneScript:OnHumanLeave(human) 
	human:ChangeFaction(FactionTypes.FactionPlayer)
	local record = self.Records[human:GetID()]
	if record == nil then 
		human:GetModPK():SetPKMod(0, 0)
		
		return 
	end
	human:GetModPK():SetPKMod(record.old_pk[1], record.old_pk[2])

	if record.flagIdx ~= 0 then
		local flag = self:GetFlagByIdx(record.flagIdx)
		if flag.can_pick == self.FlagCarry then
			flag.can_pick = self.FlagCanPick
			self:UpdateFlag({flag})
		end 
		record.flagIdx = 0
	end

	self.Records[human:GetID()] = nil
	if self:CheckInRank(1, human:GetID()) > 0 then self:SortKillRank() end
	if self:CheckInRank(2, human:GetID()) > 0 then self:SortContriRank() end
	if self:CheckInRank(3, human:GetID()) > 0 then self:SortMultiKillRank() end
end

function CurrentSceneScript:OnHumanKilled(human,killer)
	if self.ActivityClose then return end

	if self.FirstBlood then
		self:SendCampNotice(10108, killer, human)
		self.FirstBlood = false
	end

	local record = self.Records[human:GetID()]
	if record ~= nil then
		if record.multi_kill ~= 0 then
			self:CheckKilled(human, killer, record.multi_kill)
			record.multi_kill = 0
			self:SendUpdateInfo(CampTypes.CampMultiKill, 0, human:GetID())
		end	
		if record.flagIdx ~= 0 then
			local flag = self:GetFlagByIdx(record.flagIdx)
			if flag.can_pick == self.FlagCarry then
				flag.can_pick = self.FlagCanPick
				self:UpdateFlag({flag})
			end
			record.flagIdx  = 0
			self:SendCampNotice(10157, killer, human)
		end
	end
	-- to-do check killer type
	if killer:GetObjType() ~= 4 then
		return
	end 

	local killer_kill_num = 0
	local killer_multi_kill = 0
	if killer:GetFaction() == self.Camp_A or killer:GetFaction() == self.Camp_B then
		local killer_record = self.Records[killer:GetID()]
		if killer_record ~= nil then
			killer_record.kill_num = killer_record.kill_num + 1
			killer_kill_num = killer_record.kill_num
			killer_record.multi_kill = killer_record.multi_kill + 1

			self:CheckMultiKill(killer, human, killer_record.multi_kill)
			self:CheckTotalKill(killer, killer_record.kill_num)

			if killer_record.multi_kill > killer_record.max_multi_kill then
				killer_record.max_multi_kill = killer_record.multi_kill
				killer_multi_kill = killer_record.max_multi_kill
				self:SendUpdateInfo(CampTypes.CampMaxMulti, killer_record.max_multi_kill, killer:GetID())
			end

			self:SendUpdateInfo(CampTypes.CampMultiKill, killer_record.multi_kill, killer:GetID())
			self:SendUpdateInfo(CampTypes.CampKillNum, killer_record.kill_num, killer:GetID())
		end
	end
	
	if self:CheckInRank(1, killer:GetID()) > 0 or self.KillRank[5]~= nil or killer_kill_num > self.KillRank[5].kill_num then
		self:SortKillRank()
	end
	if self:CheckInRank(3, killer:GetID()) > 0 or self.MultiKillRank[5] == nil or killer_multi_kill > self.MultiKillRank[5].max_multi_kill then
		self:SortMultiKillRank()
	end
end

function CurrentSceneScript:SelectCamp()
	local power = {
		[self.Camp_A] = 0,
		[self.Camp_B] = 0,
	}
	for k,v in pairs(self.Humans) do
		if v:GetFaction() == self.Camp_A or v:GetFaction() == self.Camp_B then
			power[v:GetFaction()] = v:GetPower() + power[v:GetFaction()]
		end
	end
	
	if power[self.Camp_A] > power[self.Camp_B] then
		return self.Camp_B
	end
	return self.Camp_A
end

function CurrentSceneScript:OnMonsterKilled(monster, killer) 
	if self.ActivityClose then return end

	local monCamp = monster:GetFaction()
	if monCamp == self.Camp_A or monCamp == self.Camp_B then
		return
	end
	local camp = killer:GetFaction()
	if camp ~= self.Camp_A and camp ~= self.Camp_B then
		return
	end

	self.MonCount[camp] = self.MonCount[camp] + 1
	if self.MonCount[camp] >= 5 then
		self:SpwanSpecialFlag(camp)
		self.MonCount[camp] = 0
	else
		self:SendCampNotice(10601, killer, nil, 5-self.MonCount[camp])
	end
	if camp == self.Camp_A then
		self:SendUpdateInfo(CampTypes.CampAKillMon, self.MonCount[camp])
	else
		self:SendUpdateInfo(CampTypes.CampBKillMon, self.MonCount[camp])
	end
end

function CurrentSceneScript:SpwanSpecialFlag(camp)
	local idx = math.random(1, 2)
	local flag = self.SpecialFlags[idx]
	if idx ~= nil then
		flag.camp = camp
		flag.can_pick = self.FlagCanPick

		if flag.camp == self.Camp_A then
			self:SendCampNotice(10107)
		else
			self:SendCampNotice(10106)
		end
		self:UpdateFlag({flag})
	end
end

function CurrentSceneScript:RefreshFlags()
	local  data = {}
	local  needUpdate = false
	for i,v in pairs(self.Flags) do
		if v.can_pick ~= self.FlagCanPick then
			v.can_pick = self.FlagCanPick
			table.insert(data, v)
			needUpdate = true
		end
	end
	if needUpdate then
		self:SendCampNotice(10105)
		self:UpdateFlag(data) 
	end	
end

function CurrentSceneScript:UpdateFlag(data)
	if #data < 1 then return end
	local userFlags = {}
	for i,v in pairs(data) do
		local uFlag = {}
		uFlag.idx = v.idx
		uFlag.camp = v.camp
		uFlag.can_pick = v.can_pick
		table.insert(userFlags, uFlag)
	end
	self.Scene:GetModScript():SendFlagUpdate(userFlags, 0)
end

function CurrentSceneScript:SendCampInfo(humanid)
	local record = self.Records[humanid]
	local data = {}
	data[1] = self.Scores[self.Camp_A]
	data[2] = self.Scores[self.Camp_B]
	data[3] = 2*60 -self.FlagTimer
	data[4] = self.MonCount[record.camp]
	data[5] = record.contribute
	data[6] = record.kill_num
	data[7] = record.multi_kill
	data[8] = record.max_multi_kill
	data[9] = self.TimerCounter
	self.Scene:GetModScript():SendCampInfo(data, humanid)
end

function CurrentSceneScript:SendHumanFlagList(humanid)
	local userFlags = {}
	for i,v in pairs(self.Flags) do
		local uFlag = {}
		uFlag.idx = v.idx
		uFlag.camp = v.camp
		uFlag.can_pick = v.can_pick
		table.insert(userFlags, uFlag)
	end
	for i,v in pairs(self.SpecialFlags) do
		local uFlag = {}
		uFlag.idx = v.idx
		uFlag.camp = v.camp
		uFlag.can_pick = v.can_pick
		table.insert(userFlags, uFlag)
	end
	self.Scene:GetModScript():SendFlagUpdate(userFlags, humanid)
end

function CurrentSceneScript:GetFlagByIdx(idx)
	if idx == 1 or idx == 2 then
		return self.SpecialFlags[idx]
	else
		return self.Flags[idx]
	end
end

function CurrentSceneScript:GetFlagPos(idx)
	if idx == 1 or idx == 2 then
		return self.SpecialFlagPos[idx]
	else
		return self.FlagPos[math.floor(idx/10)][idx%10]
	end
end

function CurrentSceneScript:OnFlagHandle(human, oper, flagIdx)
	if self.ActivityClose then return -1 end

	if oper == 1 then
		return self:CarrybackFlag(human)
	elseif oper == 0 then
	 	return self:PickFlag(human, flagIdx)
	end
	return 0
end

function CurrentSceneScript:CarrybackFlag(human)
	if human == nil then return 0 end
	local record = self.Records[human:GetID()]
	if record == nil then
		return 0
	end

	if record.flagIdx == 0 then 
		return 4
	end

	if self:CheckFlagHome(human, record.camp) == false then 
		return 3
	end

	local flag = self:GetFlagByIdx(record.flagIdx)
	if flag == nil then return 5 end
	if flag.can_pick == self.FlagCarry then
		flag.can_pick = self.FlagNone
		self:UpdateFlag({flag})
	end

	record.flagIdx = 0
	record.contribute = record.contribute + 1
	self.Scores[record.camp] = self.Scores[record.camp] + 1
	if self.Scores[record.camp] > self.Scores[self.WinCamp] then
		self.WinCamp = record.camp
	end 

	if self.FirstFlag then
		self:SendCampNotice(10109, human)
		self.FirstFlag = false
	elseif record.camp == self.Camp_A then
		self:SendCampNotice(10104, human)
	elseif record.camp == self.Camp_B then
		self:SendCampNotice(10103, human)
	end

	if record.camp == self.Camp_A then
		self:SendUpdateInfo(CampTypes.CampAScore, self.Scores[record.camp])
	elseif record.camp == self.Camp_B then
		self:SendUpdateInfo(CampTypes.CampBScore, self.Scores[record.camp])	
	end
	self:SendUpdateInfo(CampTypes.CampContribute, record.contribute, record.humanID)
	self:SortContriRank()
	if self:CheckInRank(2, human:GetID()) > 0 or 
		self.ContriRank[5] == nil or record.contribute >  self.ContriRank[5].contribute then
	end
	return 1
end

function CurrentSceneScript:PickFlag(human, flagIdx)
	if human == nil then return 0 end
	local record = self.Records[human:GetID()]
	if record == nil then
		return 0
	end

	if record.flagIdx ~= 0 then
		return 4
	end
	
	local flag = self:GetFlagByIdx(flagIdx)
	if flag == nil then return 0 end 

	if	flag.can_pick ~= self.FlagCanPick or flag.camp ~= record.camp then
		return 2
	end

	local pos = human:GetPos()
	local flagPos = self:GetFlagPos(flagIdx)
	if pos == nil or flagPos == nil then return 3 end
	if math.abs(pos[1] - flagPos[1]) > 30 or math.abs(pos[3] - flagPos[2]) > 30 then
		return 3
	end
	if flag.camp == self.Camp_A then
		self:SendCampNotice(10102, human)
	elseif flag.camp == self.Camp_B then
		self:SendCampNotice(10101, human)
	end
	flag.can_pick = self.FlagCarry
	record.flagIdx = flagIdx
	self:UpdateFlag({flag})
	return 1
end

function CurrentSceneScript:SendUpdateInfo(type, value, humanid)
	local data = {}
	data[1] = type
	data[2] = value
	self.Scene:GetModScript():SendUpdateInfo(data, humanid or 0)
end

function CurrentSceneScript:SendKillRank(humanid)
	local rank = {}
	for k,v in ipairs(self.KillRank) do
		if k > 5 then break end
		local data = {}
		data[1] = v.humanID
		data[2] = v.camp
		data[3] = v.kill_num
		rank[k] = data
	end
	self.Scene:GetModScript():SendKillRankInfo(rank, humanid or 0)
end

function CurrentSceneScript:SendContriRank(humanid)
	local rank = {}
	for k,v in ipairs(self.ContriRank) do
		if k > 5 then break end
		local data = {}
		data[1] = v.humanID
		data[2] = v.camp
		data[3] = v.contribute
		rank[k] = data
	end
	self.Scene:GetModScript():SendContriRankInfo(rank, humanid or 0)
end

function CurrentSceneScript:SendMultikillRank(humanid)
	local rank = {}
	for k,v in ipairs(self.MultiKillRank) do
		if k > 5 then break end
		local data = {}
		data[1] = v.humanID
		data[2] = v.camp
		data[3] = v.max_multi_kill
		rank[k] = data
	end
	self.Scene:GetModScript():SendMultiKillInfo(rank, humanid or 0)
end

function CurrentSceneScript:SortKillRank(final)
	local rankNum = 5
	if final == nil then
		if self.ActivityClose then return end
	else
		rankNum = 10
	end
	self.KillRank = {}
	for k,v in pairs(self.Records) do
		if not self.KillRank[1] then
			self.KillRank[1] = v
		else
			local num = #self.KillRank
			for i=1,rankNum do
				if i <= num then
					if v.kill_num > self.KillRank[i].kill_num or 
						(v.kill_num == self.KillRank[i].kill_num and v.humanIdx < self.KillRank[i].humanIdx) then
						table.insert(self.KillRank, i, v)
						break
					end
					if i == num and i < rankNum then self.KillRank[i+1] = v end
				end
			end
		end
	end
	if final == nil then self:SendKillRank() end
end

function CurrentSceneScript:SortMultiKillRank(final)
	local rankNum = 5
	if final == nil then
		if self.ActivityClose then return end
	end
	self.MultiKillRank = {}
	for k,v in pairs(self.Records) do
		if not self.MultiKillRank[1] then
			self.MultiKillRank[1] = v
		else
			local num = #self.MultiKillRank
			for i=1,rankNum do
				if i <= num then
					if v.max_multi_kill > self.MultiKillRank[i].max_multi_kill or 
						(v.max_multi_kill == self.MultiKillRank[i].max_multi_kill and v.humanIdx < self.MultiKillRank[i].humanIdx) then
						table.insert(self.MultiKillRank, i, v)
						break
					end
					if i == num and i < rankNum then self.MultiKillRank[i+1] = v end
				end
			end
		end
	end
	if final == nil then self:SendMultikillRank() end
end

function CurrentSceneScript:SortContriRank(winCamp)
	local rankNum = 5
	if winCamp == nil then
		if self.ActivityClose then return end
	else
		rankNum = 10
	end
	
	self.ContriRank = {}
	for k,v in pairs(self.Records) do
		--if winCamp == nil or v.camp == winCamp then
			if not self.ContriRank[1] then
				self.ContriRank[1] = v
			else
				local num = #self.ContriRank
				for i=1,rankNum do
					if i <= num then
						if v.contribute > self.ContriRank[i].contribute or 
							(v.contribute == self.ContriRank[i].contribute and v.humanIdx < self.ContriRank[i].humanIdx) then
							table.insert(self.ContriRank, i, v)
							break
						end
						if i == num and i < rankNum then self.ContriRank[i+1] = v end
					end
				end
			end
		--end
	end
	self:SendContriRank()
end

function CurrentSceneScript:SendAllRecord(humanid)
	local aList = {}
	local bList = {}
	for k,v in pairs(self.Records) do
		local data = {}
		data[1] = v.humanID
		data[2] = v.contribute
		data[3] = v.kill_num
		data[4] = v.multi_kill

		if v.camp == self.Camp_A then
			table.insert(aList, data)
		elseif v.camp == self.Camp_B then
			table.insert(bList, data)
		end
	end
	self.Scene:GetModScript():SendAllCampRecord(aList, self.Camp_A, humanid)
	self.Scene:GetModScript():SendAllCampRecord(bList, self.Camp_B, humanid)
end

function CurrentSceneScript:CheckInRank(type, humanid)
	if type == 1 then
		for i,v in ipairs(self.KillRank) do
			if v.humanID == humanid then return i end
		end
	elseif type == 2 then
		for i,v in ipairs(self.ContriRank) do
			if v.humanID == humanid then return i end
		end
	elseif type == 3 then
		for i,v in ipairs(self.MultiKillRank) do
			if v.humanID == humanid then return i end
		end
	end
	return 0
end

function CurrentSceneScript:OnReward(human)
	if human == nil then return 0 end
	local record = self.Records[human:GetID()]
	if record == nil  or record.reward then
		return 0
	end
	record.reward = true

	local sever_lv = tostring(_GetServerLvl())
	local award = CampAwardConfig[sever_lv]

	if award == nil then return 0 end
	local data = {}
	-- win
	if self.WinCamp == record.camp then
		table.insert(data, {award['win']})
	else
		table.insert(data, {award['join']})
	end
	-- contri
	local crank = self:CheckInRank(2, human:GetID())
	if crank > 0  and crank <= 5 then
		table.insert(data, {award['contri'][crank]})
	end
	-- kill
	local krank = self:CheckInRank(1, human:GetID())
	if krank > 0 and krank <= 10 then
		table.insert(data, {award['kill'][krank]})
	end

	self.Scene:GetModScript():OnActReward(data, human:GetID())
end

function CurrentSceneScript:CheckFlagHome(human, camp)
	local pos = human:GetPos()
	local flagPos = self.FlagsHome[camp]
	if pos == nil or flagPos == nil then return false end
	if math.abs(pos[1] - flagPos[1]) > flagPos[3] or math.abs(pos[3] - flagPos[2]) > flagPos[3] then
		return false
	end
	return true
end

function CurrentSceneScript:SendTopPlayerID()
	local data = {{0,0},{0,0},{0,0}}
	local kill = self.KillRank[1]
	if kill ~= nil then
		data[1] = {kill.humanID, kill.kill_num}
	end
	local multi = self.MultiKillRank[1]
	if multi ~= nil then
		data[2] = {multi.humanID, multi.max_multi_kill}
	end
	local contri = self.ContriRank[1]
	if contri ~= nil then
		data[3] = {contri.humanID, contri.contribute}
	end

	self.Scene:GetModScript():SendCampTopInfo(data, self.WinCamp)
end

function CurrentSceneScript:CheckMultiKill(human, killed, multi)
	if multi > 10 then
		self:SendCampNotice(10126, human, killed, multi)
	elseif multi >= 3 then
		self:SendCampNotice(10118+multi-3, human)
	end
end

function CurrentSceneScript:CheckTotalKill( human, num )
	local notice = 0
	if num == 5 then
		notice = 10110
	elseif num == 10 then
		notice = 10111
	elseif num == 15 then
		notice = 10112
	elseif num == 20 then
		notice = 10113
	elseif num == 25 then
		notice = 10114
	elseif num == 30 then
		notice = 10115
	elseif num == 40 then
		notice = 10116
	elseif num == 50 then
		notice = 10117
	end
	if notice ~= 0 then
		self:SendCampNotice(notice, human)
	end
end

function CurrentSceneScript:CheckKilled(human, killer, num)
	if num > 10 then
		self:SendCampNotice(10133, killer, human)
	elseif num >= 5 then
		self:SendCampNotice(10127+num-5, killer, human)
	end
end

function CurrentSceneScript:SendCampNotice(notice, humanA, humanB, num)
	local str = ""
	if humanA ~= nil then
		local type = humanA:GetObjType()
		if  type == 4 then
			str = str .. "1," .. humanA:GetID() .. "," .. humanA:GetName() .. "#"
		elseif type == 2 then
			str = str .. "5," .. humanA:GetName() .. "#"
		end
	end
	if humanB ~= nil then
		str = str .. "1," .. humanB:GetID() .. "," .. humanB:GetName() .. "#"
	end
	if num ~= nil then
		str = str .. "5," .. num
	end
	print("Camp Notice [" ..notice.. "]:" .. str)
	_SendNotice(notice, str, self.Scene:GetGameMapID())
end

function CurrentSceneScript:OnHumanRelive(human)
	local pos = self.RevivePos[human:GetFaction()]
	human:LuaChangePos(pos[1], pos[2])
end

