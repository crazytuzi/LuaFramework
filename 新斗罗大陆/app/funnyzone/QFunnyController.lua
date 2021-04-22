local QFunnyController = class("QFunnyController")
local QAssist = import("..modules.assist.QAssist")
local QReplayUtil = import("..utils.QReplayUtil")

QFunnyController.GOD_KEY = "/gameissofunny#"
QFunnyController.PRINT_ACTOR = "printActor"
QFunnyController.ASSIST = "assist"
QFunnyController.CURRENT_BATTLE_RECORD = "battleRecord"

QFunnyController.Commands = {}

QFunnyController.password = 123

function QFunnyController:ctor(options)
	self._isActivited = false
	table.insert(QFunnyController.Commands, {command = QFunnyController.GOD_KEY, handlerFun = handler(self, self.activite)})
	table.insert(QFunnyController.Commands, {command = QFunnyController.PRINT_ACTOR, handlerFun = handler(self, self.printActor)})
	table.insert(QFunnyController.Commands, {command = QFunnyController.ASSIST, handlerFun = handler(self, self.runAssist)})
	table.insert(QFunnyController.Commands, {command = QFunnyController.CURRENT_BATTLE_RECORD, handlerFun = handler(self, self.printBattleRecord)})
end

function QFunnyController:getIsActivite()
	return self._isActivited
end

function QFunnyController:run(msg)
	self._msg = msg
	if self:execute() == false then
		return self._msg
	elseif #self._msg > 0 then
		local state = pcall(load(self._msg))
		if state == false then
			print(self._msg)
			print("输入的代码行有错误，请检查！")
		end
		self._msg = ""
	end
	return self._msg
end

function QFunnyController:execute()
	for _,v in ipairs(QFunnyController.Commands) do
		local len = #v.command
		if #self._msg >= len and string.sub(self._msg,1,len) == v.command then
			self._msg = string.sub(self._msg,len+1)
			if self:getIsActivite() == false and v.command ~= QFunnyController.GOD_KEY then
				return false
			end
			v.handlerFun()
		end
	end
	if self:getIsActivite() == false then
		return false
	end
	return true
end

function QFunnyController:activite()
	self._isActivited = not self._isActivited
	if self._isActivited then
		app.tip:floatTip("you like god now ！")
	else
		app.tip:floatTip("god like egg ! ")
		self._msg = ""
	end
end

function QFunnyController:printActor()
	local x,y = string.find(self._msg,"([(0-9)]*)")
	if x > 0 and y > 0 and y-1 > x+1 then
		local actorId = string.sub(self._msg,x+1,y-1)
		ACTOR_PRINT_ID = tonumber(actorId)
		local hero = remote.herosUtil:createSelfHeroByActorId(ACTOR_PRINT_ID)
		trace(hero:getBattleForce(),"DEBUG_PROP")
		trace(hero:getBattleForce(true),"DEBUG_PROP")

		self._msg = string.sub(self._msg,y+1)
	end
end

function QFunnyController:runAssist()
	local x,y = string.find(self._msg,"([(%w)]*)")
	if x > 0 and y > 0 then
		local command = nil
		if y > x+1 then
			command = string.sub(self._msg,x+1,y-1)
		end
		print(command)
		QAssist:getInstance():run(command)
		self._msg = string.sub(self._msg,y+1)
	end
end

function QFunnyController:printBattleRecord()
    local logContent = ""
    local connectionStr = function(srcStr)
    	if srcStr == nil then return end

    	if device.platform == "windows" then
    		logContent = logContent..srcStr.."\r"
    	else
    		logContent = logContent..srcStr.."\n"
    	end
    end

    local createHero = function(heros, addotionalInfo, extraProp, tip)
    	if tip then 
    		connectionStr(tip) 
    	end
		for _, value in ipairs(heros) do
			local config = db:getCharacterByID(value.actorId)
			connectionStr(string.format("~~~~~~~~~~ %s ~~~~~~~~~~~~", config.name))
	        local actor = app:createHeroWithoutCache(value, nil, addotionalInfo, nil, nil, nil, nil, nil, extraProp)
	        local actorProp = actor:getActorPropInfo()
		    actorProp.setLogFunc(function (msg)
		        connectionStr(msg)
		    end)
	        actorProp:setPrint(true)
	        actorProp:_handleAllPropWithoutCount()
	    end
    end

    local content = readFromBinaryFile("last.reppb")
    if content == nil then
    	app.tip:floatTip("当前没有战报文件！")
        return
    end
    local record = app:parseBinaryBattleRecord(content)
    if record then
    	local dungeonConfig = record.dungeonConfig or {}
		local attackAdditionalInfo = QReplayUtil:getAdditionalInfoByDungeon(dungeonConfig, true)
		local attackExtraProp = dungeonConfig.extraProp or {}
		local defenseAdditionalInfo = QReplayUtil:getAdditionalInfoByDungeon(dungeonConfig, false)
		local defenseExtraProp = dungeonConfig.enemyExtraProp or {}
		connectionStr(string.format("~~~~~~~~~~~ 对战进攻方为 %s, 防守方为 %s ~~~~~~~~~~~~~", dungeonConfig.team1Name, dungeonConfig.team2Name))
    	if dungeonConfig.pvpMultipleTeams then
    		connectionStr("~~~~~~~~~~~ 战报为两小队战报 ~~~~~~~~~~~~~")
    		for i, value in ipairs(dungeonConfig.pvpMultipleTeams) do
    			if value.hero.heroes then
	    			createHero(value.hero.heroes, attackAdditionalInfo, attackExtraProp, string.format("~~~~~~~~~~ 第%s队 进攻方主力魂师属性 ~~~~~~~~~~~~", i))
	    		end
    			if value.hero.supports then
	    			createHero(value.hero.supports, attackAdditionalInfo, attackExtraProp, string.format("~~~~~~~~~~ 第%s队 进攻方援助魂师属性 ~~~~~~~~~~~~", i))
	    		end

    			if value.enemy.heroes then
	    			createHero(value.enemy.heroes, defenseAdditionalInfo, defenseExtraProp, string.format("~~~~~~~~~~ 第%s队 防守方主力魂师属性 ~~~~~~~~~~~~", i))
	    		end
    			if value.enemy.supports then
	    			createHero(value.enemy.supports, defenseAdditionalInfo, defenseExtraProp, string.format("~~~~~~~~~~ 第%s队 防守方援助魂师属性 ~~~~~~~~~~~~", i))
	    		end
    		end
    	else
    		connectionStr("~~~~~~~~~~~ 战报为一小队战报 ~~~~~~~~~~~~~")
    		if dungeonConfig.heroInfos then
    			createHero(dungeonConfig.heroInfos, attackAdditionalInfo, attackExtraProp, "~~~~~~~~~~ 进攻方主力魂师属性 ~~~~~~~~~~~~")
    		end
    		if dungeonConfig.userAlternateInfos then
    			createHero(dungeonConfig.userAlternateInfos, attackAdditionalInfo, attackExtraProp, "~~~~~~~~~~ 进攻方替补魂师属性 ~~~~~~~~~~~~")
    		end
    		if dungeonConfig.supportHeroInfos then
    			createHero(dungeonConfig.supportHeroInfos, attackAdditionalInfo, attackExtraProp, "~~~~~~~~~~ 进攻方援助1魂师属性 ~~~~~~~~~~~~")
    		end
    		if dungeonConfig.supportHeroInfos2 then
    			createHero(dungeonConfig.supportHeroInfos2, attackAdditionalInfo, attackExtraProp, "~~~~~~~~~~ 进攻方援助2魂师属性 ~~~~~~~~~~~~")
    		end
    		if dungeonConfig.supportHeroInfos3 then
    			createHero(dungeonConfig.supportHeroInfos3, attackAdditionalInfo, attackExtraProp, "~~~~~~~~~~ 进攻方援助3魂师属性 ~~~~~~~~~~~~")
    		end

    		if dungeonConfig.pvp_rivals then
    			createHero(dungeonConfig.pvp_rivals, attackAdditionalInfo, attackExtraProp, "~~~~~~~~~~ 防守方主力魂师属性 ~~~~~~~~~~~~")
    		end
    		if dungeonConfig.enemyAlternateInfos then
    			createHero(dungeonConfig.enemyAlternateInfos, attackAdditionalInfo, attackExtraProp, "~~~~~~~~~~ 防守方替补魂师属性 ~~~~~~~~~~~~")
    		end
    		if dungeonConfig.pvp_rivals2 then
    			createHero(dungeonConfig.pvp_rivals2, attackAdditionalInfo, attackExtraProp, "~~~~~~~~~~ 防守方援助1魂师属性 ~~~~~~~~~~~~")
    		end
    		if dungeonConfig.pvp_rivals4 then
    			createHero(dungeonConfig.pvp_rivals4, attackAdditionalInfo, attackExtraProp, "~~~~~~~~~~ 防守方援助2魂师属性 ~~~~~~~~~~~~")
    		end
    		if dungeonConfig.pvp_rivals6 then
    			createHero(dungeonConfig.pvp_rivals6, attackAdditionalInfo, attackExtraProp, "~~~~~~~~~~ 防守方援助3魂师属性 ~~~~~~~~~~~~")
    		end
    	end
    end

    if logContent then
    	writeToBinaryFile("battleRecordLog.txt", logContent)
    end
end

function QFunnyController:_triggerCheck()
	if self._triggerLastTime == nil then
		self._triggerTimes = 1
	elseif q.serverTime() - self._triggerLastTime < 1 then
		self._triggerTimes = self._triggerTimes + 1
	elseif q.serverTime() - self._triggerLastTime < 3 then
		self._triggerTimes = self._triggerTimes + 10
	elseif q.serverTime() - self._triggerLastTime < 6 then
		self._triggerTimes = self._triggerTimes + 100
	else
		self._triggerTimes = 1
	end
	self._triggerLastTime = q.serverTime()
	return self._triggerTimes == self.password
end

function QFunnyController:trigger( ... )
	if self:_triggerCheck() then
		if self:getIsActivite() == false then
			self:activite()
		end
		QAssist:getInstance():run()
		return
	end
	-- if self._triggerTimes >= 8 and self._triggerTimes < 8 then
	-- 	app.tip:floatTip("连续点击"..(8-self._triggerTimes).."次开启debug面板")
	-- end
	-- if self._triggerTimes >= 8 then
	-- 	if self:getIsActivite() == false then
	-- 		self:activite()
	-- 	end
	-- 	QAssist:getInstance():run()
	-- 	return
	-- end
end

return QFunnyController