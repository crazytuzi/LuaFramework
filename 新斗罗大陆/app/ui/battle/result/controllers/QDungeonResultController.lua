local QBaseResultController = import(".QBaseResultController")
local QDungeonResultController = class("QDungeonResultController", QBaseResultController)

local QBattleDialogWin = import("..dialogs.QBattleDialogWin")
local QBattleDialogLose = import("..dialogs.QBattleDialogLose")
local QBattleDialogFightEnd = import("..dialogs.QBattleDialogFightEnd")


function QDungeonResultController:ctor(options)
end

function QDungeonResultController:requestResult(isWin)
    self._isWin = isWin
    local battleScene = self:getScene()
    local dungeonConfig = battleScene:getDungeonConfig()

	local activeDungeonInfo = remote.activityInstance:getDungeonById(dungeonConfig.id)
    if self._isWin or (activeDungeonInfo ~= nil and (activeDungeonInfo.dungeon_type == DUNGEON_TYPE.ACTIVITY_TIME or activeDungeonInfo.dungeon_type == DUNGEON_TYPE.ACTIVITY_CHALLENGE)) then
    	self._handler = scheduler.performWithDelayGlobal(function ()
    		local oldUser = remote.user:clone()
    		self.teamName = dungeonConfig.teamName
		    local teamHero = remote.teamManager:getActorIdsByKey(dungeonConfig.teamName, 1)
		    local heroTotalCount = #teamHero

			self._heroInfo = {}
			for i = 1, heroTotalCount, 1 do
			  self._hero = remote.herosUtil:getHeroByID(teamHero[i])
			  self._heroInfo[i] = self._hero 
			end
			local star, completedId = 0, ""

			self._passInfo = remote.instance:getPassInfoForDungeonID(dungeonConfig.id)
			if self._passInfo ~= nil and self._passInfo.lastPassAt > 0 then
	        	remote.instance:setLastPassId(nil)
	        else
	        	remote.instance:setLastPassId(dungeonConfig.id)
	        end
		        
			if self._passInfo ~= nil and self._passInfo.star ~= nil and self._passInfo.star >= 3 then
			    star = 3
			    completedId = "1;2;3"
			elseif app.missionTracer ~= nil then
			    star, completedId = app.missionTracer:getCompleteMissionCount()
			end
			local killEnemyCount, bossMinimumHp = dungeonConfig.killEnemyCount or 0, dungeonConfig.bossMinimumHp or 0
			-- nzhang: 活动副本如果杀完了所有的小怪，算3星
			if app.battle:isActiveDungeon() and app.battle:getDungeonDeadEnemyCount() == app.battle:getDungeonEnemyCount() then
			    star = 3
			    completedId = "1;2;3"
			end
			--检查之前是否通关
			local dungeonData = remote.instance:getDungeonById(dungeonConfig.id)
			if dungeonData then
				self._isFirst = not remote.instance:checkIsPassByDungeonId(dungeonData.dungeon_id)
				-- self._isFirst = true
			end

			local m_dungeonInfo = remote.instance:getDungeonById(dungeonConfig.id)
			local battleType = BattleTypeEnum.DUNGEON_NORMAL
			if dungeonInfo ~= nil and dungeonInfo.dungeon_type == DUNGEON_TYPE.NORMAL then
				battleType = BattleTypeEnum.DUNGEON_NORMAL
			elseif m_dungeonInfo ~= nil and m_dungeonInfo.dungeon_type == DUNGEON_TYPE.ELITE then
				battleType = BattleTypeEnum.DUNGEON_ELITE
			else
				if activeDungeonInfo ~= nil and (activeDungeonInfo.dungeon_type == DUNGEON_TYPE.ACTIVITY_TIME or activeDungeonInfo.dungeon_type == DUNGEON_TYPE.ACTIVITY_CHALLENGE) then
					battleType = BattleTypeEnum.DUNGEON_ACTIVITY
				end
			end

			if dungeonConfig.battleType then
				-- 魂力试炼专用，强制改写，不通过dungeonType判断(3/3)
				battleType = dungeonConfig.battleType
			end
			app:getClient():dungeonFightSucceed(battleType, app.battle:getBattleLog(), star, completedId, dungeonConfig.verifyKey, killEnemyCount, bossMinimumHp,
			    function(data)
			    	-- if data.soulTrial then
			    	-- 	remote.user.soulTrial = data.soulTrial
			    	-- end
			        data = {result = data, oldUser = oldUser}
			        self:setResponse(data)
			        local mapInfo = remote.instance:getDungeonById(dungeonConfig.id)
			        if mapInfo ~= nil then
			            if mapInfo.dungeon_type == DUNGEON_TYPE.NORMAL then
			                remote.activity:updateLocalDataByType(540, 1)
			            elseif mapInfo.dungeon_type == DUNGEON_TYPE.ELITE then
			                remote.activity:updateLocalDataByType(541, 1)
			            end
			        end
			end,function(data)
			    self:requestFail(data)
			end)
    	end, 0)
	else
        local id = dungeonConfig.id
        local m_dungeonInfo = remote.instance:getDungeonById(dungeonConfig.id)
			local battleType = BattleTypeEnum.DUNGEON_NORMAL
			if dungeonInfo ~= nil and dungeonInfo.dungeon_type == DUNGEON_TYPE.NORMAL then
				battleType = BattleTypeEnum.DUNGEON_NORMAL
			elseif m_dungeonInfo ~= nil and m_dungeonInfo.dungeon_type == DUNGEON_TYPE.ELITE then
				battleType = BattleTypeEnum.DUNGEON_ELITE
			else
				local activeDungeonInfo = remote.activityInstance:getDungeonById(dungeonConfig.id)
				if activeDungeonInfo ~= nil and (activeDungeonInfo.dungeon_type == DUNGEON_TYPE.ACTIVITY_TIME or activeDungeonInfo.dungeon_type == DUNGEON_TYPE.ACTIVITY_CHALLENGE) then
					battleType = BattleTypeEnum.DUNGEON_ACTIVITY
				end
			end 
		if dungeonConfig.battleType then
			-- 魂力试炼专用，强制改写，不通过dungeonType判断(3/3)
			battleType = dungeonConfig.battleType
		end
        app:getClient():fightFailRequest(battleType, id, dungeonConfig.verifyKey, function ()
        	remote.instance:addLostCountById(id)
        end)
        dungeonConfig.lostCount = (dungeonConfig.lostCount or 0) + 1
		local oldUser = remote.user:clone()
        self:setResponse({result = {}, oldUser = oldUser})
    end
end

function QDungeonResultController:fightEndHandlerxxx()
    local battleScene = self:getScene()
    local dungeonConfig = battleScene:getDungeonConfig()
    local star = 0
    if self._isWin then
	    local energy = 6
	    local dungeonInfo = remote.instance:getDungeonById(dungeonConfig.id)
	    if dungeonInfo ~= nil and dungeonInfo.dungeon_type == DUNGEON_TYPE.NORMAL then
	        remote.user:addPropNumForKey("addupDungeonPassCount")
	    elseif dungeonInfo ~= nil and dungeonInfo.dungeon_type == DUNGEON_TYPE.ELITE then
	        remote.user:addPropNumForKey("addupDungeonElitePassCount")
	        energy = 12
	    else
	        local activeDungeonInfo = remote.activityInstance:getDungeonById(dungeonConfig.id)
	        if activeDungeonInfo ~= nil and (activeDungeonInfo.dungeon_type == DUNGEON_TYPE.ACTIVITY_TIME or activeDungeonInfo.dungeon_type == DUNGEON_TYPE.ACTIVITY_CHALLENGE) then
	            remote.user:addPropNumForKey("allActivityDungeonFightCount")
	            remote.activity:updateLocalDataByType(555, 1)
	        end
	    end
	    
	    --xurui: 更新每日军团副本活跃任务
	    remote.union.unionActive:updateActiveTaskProgress(20004, energy)

	    local shops = nil
	    if self.response.result.shops ~= nil then
	      shops = self.response.result.shops
	    end
	    if battleScene.curModalDialog ~= nil and battleScene.curModalDialog.close ~= nil then
	        battleScene.curModalDialog:close()
	        battleScene.curModalDialog = nil
	    end
	    star = 3
	    if app.missionTracer ~= nil then
	        star = app.missionTracer:getCompleteMissionCount()
	    end
	    -- battleScene.curModalDialog = QBattleDialogWin.new({config=dungeonConfig, star = star, oldUser = self.response.oldUser, 
	    --     heroInfo = self._heroInfo, shops = shops, invasion = self.response.result.userIntrusionResponse,extAward = self.response.result.extraExpItem}, self:getCallTbl())
		battleScene.curModalDialog = QBattleDialogFightEnd.new({config = dungeonConfig, 
			teamName = self.teamName,
			isWin = true, 
			timeType = "2",
			star = star, text = "", 
			isExpMoneyScore = true, exp = 0, money = 0, score = 0, 
			isHero = true, isMatch = false, isFightData = false, 
			isAward = true, isEquation = false,
			oldTeamLevel = self.response.oldUser.level, heroOldInfo = self._heroInfo, 
			stores = shops, invasion = self.response.result.userIntrusionResponse, 
			extAward = self.response.result.extraExpItem}, self:getCallTbl())
	else
        -- battleScene.curModalDialog = QBattleDialogLose.new(nil,self:getLoseCallTbl())
        battleScene.curModalDialog = QBattleDialogFightEnd.new({
			isWin = false, 
			star = 0, text = "", 
			isExpMoneyScore = false, exp = 0, money = 0, score = 0, 
			isHero = false, isMatch = false, isFightData = false, 
			isAward = false, isEquation = false}, self:getLoseCallTbl())
	end
	
end
function QDungeonResultController:fightEndHandler()
    local battleScene = self:getScene()
    local dungeonConfig = battleScene:getDungeonConfig()
    -- QPrintTable(dungeonConfig)
   
    local star = 0
    local activeDungeonInfo = remote.activityInstance:getDungeonById(dungeonConfig.id)

    if self._isWin then
	    local energy = 6
	    local dungeonInfo = remote.instance:getDungeonById(dungeonConfig.id)
	    if dungeonInfo ~= nil and dungeonInfo.dungeon_type == DUNGEON_TYPE.NORMAL then
	        remote.user:addPropNumForKey("addupDungeonPassCount")
	    elseif dungeonInfo ~= nil and dungeonInfo.dungeon_type == DUNGEON_TYPE.ELITE then
	        remote.user:addPropNumForKey("addupDungeonElitePassCount")
	        energy = 12
	    else
	        local activeDungeonInfo = remote.activityInstance:getDungeonById(dungeonConfig.id)
	        -- QPrintTable(dungeonConfig)
	        print(" bossMinimumHp = ", dungeonConfig.bossMinimumHp)
		    print(" killEnemyCount = ", dungeonConfig.killEnemyCount)
		    print(" id = ", dungeonConfig.id)
	        if activeDungeonInfo ~= nil and (activeDungeonInfo.dungeon_type == DUNGEON_TYPE.ACTIVITY_TIME or activeDungeonInfo.dungeon_type == DUNGEON_TYPE.ACTIVITY_CHALLENGE) then
	            remote.user:addPropNumForKey("allActivityDungeonFightCount")
	            remote.activity:updateLocalDataByType(555, 1)
        		app.taskEvent:updateTaskEventProgress(app.taskEvent.TIMEMACHINE_TASK_EVENT, 1, false, true)
	            self._bossMinimumHp = dungeonConfig.bossMinimumHp
			    self._killEnemyCount = dungeonConfig.killEnemyCount
			    if activeDungeonInfo.int_instance_id == 110101 then
			    	-- 金魂币
			    	self._totalKillEnemyCount = 44
			    	self._bossMinimumHp = -1
		    	elseif activeDungeonInfo.int_instance_id == 110201 then
		    		-- 经验
		    		self._totalKillEnemyCount = 34
		    		self._bossMinimumHp = -1
		    	end
	        end
	    end
	    
	    --xurui: 更新每日军团副本活跃任务
	    remote.union.unionActive:updateActiveTaskProgress(20004, energy)

	    local shops = nil
	    if self.response.result.shops ~= nil then
	      shops = self.response.result.shops
	    end
	    if battleScene.curModalDialog ~= nil and battleScene.curModalDialog.close ~= nil then
	        battleScene.curModalDialog:close()
	        battleScene.curModalDialog = nil
	    end
	    star = 3
	    if app.missionTracer ~= nil then
	        star = app.missionTracer:getCompleteMissionCount()
	    end
	    local isNeedTutorial = false
	    if self._isFirst and (dungeonConfig.id == "wailing_caverns_1" 
	    	or dungeonConfig.id == "wailing_caverns_2" 
	    	or dungeonConfig.id == "wailing_caverns_3" 
	    	or dungeonConfig.id == "wailing_caverns_4"
	    	or dungeonConfig.id == "wailing_caverns_5") then
	    	isNeedTutorial = true
	    end
	    -- battleScene.curModalDialog = QBattleDialogWin.new({config=dungeonConfig, star = star, oldUser = self.response.oldUser, 
	    --     heroInfo = self._heroInfo, shops = shops, invasion = self.response.result.userIntrusionResponse,extAward = self.response.result.extraExpItem}, self:getCallTbl())
		battleScene.curModalDialog = QBattleDialogFightEnd.new({config = dungeonConfig, 
			teamName = self.teamName,
			isWin = true, 
			timeType = "2",
			star = star, text = "", 
			isExpMoneyScore = true, exp = 0, money = 0, score = 0, 
			isHero = true, isMatch = false, isFightData = false, 
			isAward = true, isEquation = false,
			oldTeamLevel = self.response.oldUser.level, heroOldInfo = self._heroInfo, 
			stores = shops, invasion = self.response.result.userIntrusionResponse, 
			bossMinimumHp = self._bossMinimumHp, killEnemyCount = self._killEnemyCount, totalKillEnemyCount = self._totalKillEnemyCount,
			oldPassInfo = self._passInfo,
			isFirst = self._isFirst,
			isNeedTutorial = isNeedTutorial,
			extAward = self.response.result.extraExpItem}, self:getCallTbl())
	elseif activeDungeonInfo ~= nil and (activeDungeonInfo.dungeon_type == DUNGEON_TYPE.ACTIVITY_TIME or activeDungeonInfo.dungeon_type == DUNGEON_TYPE.ACTIVITY_CHALLENGE) then
		remote.user:addPropNumForKey("allActivityDungeonFightCount")
        remote.activity:updateLocalDataByType(555, 1)
        app.taskEvent:updateTaskEventProgress(app.taskEvent.TIMEMACHINE_TASK_EVENT, 1, false, true)
        self._bossMinimumHp = dungeonConfig.bossMinimumHp
	    self._killEnemyCount = dungeonConfig.killEnemyCount
	    print(" bossMinimumHp = ", dungeonConfig.bossMinimumHp)
	    print(" killEnemyCount = ", dungeonConfig.killEnemyCount)
	    print(" id = ", dungeonConfig.id)
	    if activeDungeonInfo.int_instance_id == 110101 then
	    	-- 金魂币
	    	self._totalKillEnemyCount = 44
	    	self._bossMinimumHp = -1
    	elseif activeDungeonInfo.int_instance_id == 110201 then
    		-- 经验
    		self._totalKillEnemyCount = 34
    		self._bossMinimumHp = -1
    	end

    	battleScene.curModalDialog = QBattleDialogFightEnd.new({config = dungeonConfig, 
			teamName = self.teamName,
			isWin = true, 
			timeType = "2",
			star = star, text = "", 
			isExpMoneyScore = true, exp = 0, money = 0, score = 0, 
			isHero = true, isMatch = false, isFightData = false, 
			isAward = true, isEquation = false,
			oldTeamLevel = self.response.oldUser.level, heroOldInfo = self._heroInfo, 
			stores = shops, invasion = self.response.result.userIntrusionResponse, 
			bossMinimumHp = self._bossMinimumHp, killEnemyCount = self._killEnemyCount, totalKillEnemyCount = self._totalKillEnemyCount,
			extAward = self.response.result.extraExpItem}, self:getCallTbl())
	else
        -- battleScene.curModalDialog = QBattleDialogLose.new(nil,self:getLoseCallTbl())
        battleScene.curModalDialog = QBattleDialogFightEnd.new({config = dungeonConfig, 
			isWin = false, 
			star = 0, text = "", 
			isExpMoneyScore = false, exp = 0, money = 0, score = 0, 
			isHero = false, isMatch = false, isFightData = false, 
			isFirst = self._isFirst,
			isAward = false, isEquation = false}, self:getLoseCallTbl())
	end
	
end

function QDungeonResultController:removeAll()
	QDungeonResultController.super.removeAll(self)
	if self._handler then
		scheduler.unscheduleGlobal(self._handler)
		self._handler = nil
	end
end

return QDungeonResultController