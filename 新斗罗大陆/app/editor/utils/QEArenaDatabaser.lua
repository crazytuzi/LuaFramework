
local QEArenaDatabaser = class("QEArenaDatabaser")

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QEArenaViewer = import("..scenes.QEArenaViewer")

function QEArenaDatabaser:ctor()
	self._helper = app.editor.helper
	self._heroIds = self._helper:getHeroIds()
	self._heroCombines = {}

	local inexTable = math.combine(#self._heroIds, 4)
	for _, indices in ipairs(inexTable) do
		local heroIds = {}
		for _, index in ipairs(indices) do
			table.insert(heroIds, self._heroIds[index])
		end
		table.insert(self._heroCombines, heroIds)
	end

	local index = 1
	while index <= #self._heroCombines do
		local heroIds = self._heroCombines[index]
		local t = 0
		local dps = 0
		local health = 0
		for _, heroId in ipairs(heroIds) do
			local characterInfo = QStaticDatabase:sharedDatabase():getCharacterByID(heroId)
			if characterInfo.func == "t" then
				t = t + 1
			elseif characterInfo.func == "dps" then
				dps = dps + 1
			elseif characterInfo.func == "health" then
				health = health + 1
			end
		end
		if t == 1 and dps == 2 and health == 1 then
			index = index + 1
		else
			table.remove(self._heroCombines, index)
		end
	end
	printInfo("size:" .. tostring(#self._heroCombines))

	self._combatTeam = {}
	local count = #self._heroCombines
	for i = 1, count do
		for j = 1, count do
			table.insert(self._combatTeam, {self._heroCombines[i], self._heroCombines[j]})
		end
	end

	printInfo("size:" .. tostring(#self._combatTeam))

	self._countLeft = ARENA_BATTLE_COUNT - 1
end

function QEArenaDatabaser:start()
	self._fileName = CCFileUtils:sharedFileUtils():getWritablePath() .. "/arena_data.csv"
	if SKIP_BATTLE_PHASE == true and CCFileUtils:sharedFileUtils():isFileExist(self._fileName) == true then
		self:_calculateDatas()
	else
		local csvFile = io.open(self._fileName, "w")
		csvFile:write("index,level,break,grage,team1_member1,team1_member2,team1_member3,team1_member4,team2_member1,team2_member2,team2_member3,team2_member4,result")
	    csvFile:close() 

		app.editor.databaser = self
		self._currentIndex = 0
		if SKIP_BATTLE_DRAW == true then
			CCDirector:sharedDirector():setIsSkipDraw(true)
		end
		CCDirector:sharedDirector():setIsNoIntervalLoop(true)
		CCDirector:sharedDirector():setAnimationInterval(0)
		self:_onStart()
	end
end

function QEArenaDatabaser:_onStart()
	if self._countLeft == ARENA_BATTLE_COUNT - 1 then
		self._currentIndex = self._currentIndex + 1
	end

	if self._currentIndex > #self._combatTeam then
		return
	end

	self._startTime = q.time()

	local team1HeroIds = self._combatTeam[self._currentIndex][1]
	local team2HeroIds = self._combatTeam[self._currentIndex][2]

	local message = {}
	message.message = "battle_arena"

	local team1 = {}
	table.insert(team1, {id = team1HeroIds[1], level = ARENA_HERO_LEVEL, grade = ARENA_HERO_GRADE, equipment = "all", skill = "max"}) 
	team1[1]["break"] = ARENA_HERO_BREAK_THROUGH
	table.insert(team1, {id = team1HeroIds[2], level = ARENA_HERO_LEVEL, grade = ARENA_HERO_GRADE, equipment = "all", skill = "max"}) 
	team1[2]["break"] = ARENA_HERO_BREAK_THROUGH
	table.insert(team1, {id = team1HeroIds[3], level = ARENA_HERO_LEVEL, grade = ARENA_HERO_GRADE, equipment = "all", skill = "max"}) 
	team1[3]["break"] = ARENA_HERO_BREAK_THROUGH
	table.insert(team1, {id = team1HeroIds[4], level = ARENA_HERO_LEVEL, grade = ARENA_HERO_GRADE, equipment = "all", skill = "max"}) 
	team1[4]["break"] = ARENA_HERO_BREAK_THROUGH
	message.team1 = team1

	local team2 = {}
	table.insert(team2, {id = team2HeroIds[1], level = ARENA_HERO_LEVEL, grade = ARENA_HERO_GRADE, equipment = "all", skill = "max"}) 
	team2[1]["break"] = ARENA_HERO_BREAK_THROUGH
	table.insert(team2, {id = team2HeroIds[2], level = ARENA_HERO_LEVEL, grade = ARENA_HERO_GRADE, equipment = "all", skill = "max"}) 
	team2[2]["break"] = ARENA_HERO_BREAK_THROUGH
	table.insert(team2, {id = team2HeroIds[3], level = ARENA_HERO_LEVEL, grade = ARENA_HERO_GRADE, equipment = "all", skill = "max"}) 
	team2[3]["break"] = ARENA_HERO_BREAK_THROUGH
	table.insert(team2, {id = team2HeroIds[4], level = ARENA_HERO_LEVEL, grade = ARENA_HERO_GRADE, equipment = "all", skill = "max"}) 
	team2[4]["break"] = ARENA_HERO_BREAK_THROUGH
	message.team2 = team2

	self._current = QEArenaViewer.new()

	if self._current ~= nil then
		display.replaceScene(self._current)
		self._current:onReceiveData(message)
	end

	self._current._message = nil
end

function QEArenaDatabaser:onBattleEnd(isWin)
	-- Todo
	printInfo("battle finished:" .. tostring(isWin))
	printInfo("cost time:" .. tostring(q.time() - self._startTime))

	if self._countLeft <= 0 then
		self._countLeft = ARENA_BATTLE_COUNT - 1
	else
		self._countLeft = self._countLeft - 1
	end

	local team1HeroIds = self._combatTeam[self._currentIndex][1]
	local team2HeroIds = self._combatTeam[self._currentIndex][2]

	local csvFile = io.open(self._fileName, "a")
	local writeString = "\n" .. tostring(self._currentIndex) .. "," .. tostring(ARENA_HERO_LEVEL) .. "," .. tostring(ARENA_HERO_BREAK_THROUGH) .. "," .. tostring(ARENA_HERO_GRADE) .. "," .. team1HeroIds[1] .. "," .. team1HeroIds[2] .. "," .. team1HeroIds[3] .. "," .. team1HeroIds[4] .. "," .. team2HeroIds[1] .. "," .. team2HeroIds[2] .. "," .. team2HeroIds[3] .. "," .. team2HeroIds[4] .. ","
	if isWin == true then
		writeString = writeString .. "victory"
	else
		writeString = writeString .. "defeated"
	end
	csvFile:write(writeString)
    csvFile:close() 

	if self._currentIndex >= #self._combatTeam then
		printInfo("battle finished yet")
		self:_calculateDatas()
		return
	end
	self:_onStart()
end

function QEArenaDatabaser:_calculateDatas()
	local dataLine = {}
	local dataLine2 = {}

	local csvFile = io.open(self._fileName, "r")
	local isFirstLine = true
	for line in csvFile:lines() do 
		if isFirstLine == true then
			self._fileName2 = CCFileUtils:sharedFileUtils():getWritablePath() .. "/arena_data2.csv"
			local csvFile2 = io.open(self._fileName2, "w")
			csvFile2:write("index,team_member1,team_member2,team_member3,team_member4,victory,victory_%,defeated,defeated_%")
		    csvFile2:close() 

		    self._fileName3 = CCFileUtils:sharedFileUtils():getWritablePath() .. "/arena_data3.csv"
			local csvFile3 = io.open(self._fileName3, "w")
			csvFile3:write("index,heroId,victory,victory_%,defeated,defeated_%")
		    csvFile3:close() 

		    isFirstLine = false
		else
			local strings = string.split(line, ",")
			local isWin = (strings[13] == "victory")

			local key = strings[5] .. "," .. strings[6] .. "," .. strings[7] .. "," .. strings[8]
			local value = dataLine[key]
			if value == nil then
				value = {victory = 0, defeated = 0}
				dataLine[key] = value
			end
			if isWin == true then
				value.victory = value.victory + 1
			else
				value.defeated = value.defeated + 1
			end

			key = strings[9] .. "," .. strings[10] .. "," .. strings[11] .. "," .. strings[12]
			value = dataLine[key]
			if value == nil then
				value = {victory = 0, defeated = 0}
				dataLine[key] = value
			end
			if isWin == true then
				value.defeated = value.defeated + 1
			else
				value.victory = value.victory + 1
			end

			key = strings[5]
			value = dataLine2[key]
			if value == nil then
				value = {victory = 0, defeated = 0}
				dataLine2[key] = value
			end
			if isWin == true then
				value.victory = value.victory + 1
			else
				value.defeated = value.defeated + 1
			end

			key = strings[6]
			value = dataLine2[key]
			if value == nil then
				value = {victory = 0, defeated = 0}
				dataLine2[key] = value
			end
			if isWin == true then
				value.victory = value.victory + 1
			else
				value.defeated = value.defeated + 1
			end

			key = strings[7]
			value = dataLine2[key]
			if value == nil then
				value = {victory = 0, defeated = 0}
				dataLine2[key] = value
			end
			if isWin == true then
				value.victory = value.victory + 1
			else
				value.defeated = value.defeated + 1
			end

			key = strings[8]
			value = dataLine2[key]
			if value == nil then
				value = {victory = 0, defeated = 0}
				dataLine2[key] = value
			end
			if isWin == true then
				value.victory = value.victory + 1
			else
				value.defeated = value.defeated + 1
			end

			key = strings[9]
			value = dataLine2[key]
			if value == nil then
				value = {victory = 0, defeated = 0}
				dataLine2[key] = value
			end
			if isWin == true then
				value.defeated = value.defeated + 1
			else
				value.victory = value.victory + 1
			end

			key = strings[10]
			value = dataLine2[key]
			if value == nil then
				value = {victory = 0, defeated = 0}
				dataLine2[key] = value
			end
			if isWin == true then
				value.defeated = value.defeated + 1
			else
				value.victory = value.victory + 1
			end

			key = strings[11]
			value = dataLine2[key]
			if value == nil then
				value = {victory = 0, defeated = 0}
				dataLine2[key] = value
			end
			if isWin == true then
				value.defeated = value.defeated + 1
			else
				value.victory = value.victory + 1
			end

			key = strings[12]
			value = dataLine2[key]
			if value == nil then
				value = {victory = 0, defeated = 0}
				dataLine2[key] = value
			end
			if isWin == true then
				value.defeated = value.defeated + 1
			else
				value.victory = value.victory + 1
			end

		end 
	end

	local index = 0
	for key, value in pairs(dataLine) do
		index = index + 1
		local strings = string.split(key, ",")
		local percent_v = value.victory / (value.victory + value.defeated) * 100
		local percent_d = value.defeated / (value.victory + value.defeated) * 100
		local writeString = "\n" .. tostring(index) .. "," .. strings[1] .. "," .. strings[2] .. "," .. strings[3] .. "," .. strings[4] .. "," .. tostring(value.victory) .. "," .. tostring(percent_v) .. "%," .. tostring(value.defeated) .. "," .. tostring(percent_d) .. "%"
		local csvFile2 = io.open(self._fileName2, "a")
		csvFile2:write(writeString)
	    csvFile2:close() 
	end

	index = 0
	for key, value in pairs(dataLine2) do
		index = index + 1
		local percent_v = value.victory / (value.victory + value.defeated) * 100
		local percent_d = value.defeated / (value.victory + value.defeated) * 100
		local writeString = "\n" .. tostring(index) .. "," .. key .. "," .. tostring(value.victory) .. "," .. tostring(percent_v) .. "%," .. tostring(value.defeated) .. "," .. tostring(percent_d) .. "%"
		local csvFile3 = io.open(self._fileName3, "a")
		csvFile3:write(writeString)
	    csvFile3:close() 
	end

	printInfo("Done!")
end

return QEArenaDatabaser