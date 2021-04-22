-- @Author: liaoxianbo
-- @Date:   2020-08-10 11:09:08
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-08-19 15:21:15

local QBaseResultController = import(".QBaseResultController")
local QMazeExploreResultController = class("QMazeExploreResultController", QBaseResultController)

local QMazeExploreDialogWin = import("..dialogs.QMazeExploreDialogWin")

function QMazeExploreResultController:ctor(options)
	self._proxyClass = remote.activityRounds:getMazeExplore()
end

function QMazeExploreResultController:requestResult(isWin)
	self._isWin = isWin
    local battleScene = self:getScene()
	local dungeonConfig = battleScene:getDungeonConfig()
	self._chapterId = self._proxyClass:getJoinDungeonId()
    self._proxyClass:MazeExploreFightEndRequest(self._chapterId, dungeonConfig.verifyKey, function (data)
        if data.gfEndResponse and data.gfEndResponse.mazeExploreFightEndResponse then
            self._proxyClass:updateBossFightPassTime(data.gfEndResponse.mazeExploreFightEndResponse.passTime or 0,data.gfEndResponse.mazeExploreFightEndResponse.addScore or 0 )
      	    self._mazeExploreFightEndResponse = data.gfEndResponse.mazeExploreFightEndResponse or {}
        end
        self:setResponse(data)
    end, function(data)
        self:requestFail(data)
    end, false)
end

function QMazeExploreResultController:fightEndHandler()
    local battleScene = self:getScene()
    local dungeonConfig = battleScene:getDungeonConfig()
    self._heroOldInfo = {}
    self._teamName = remote.teamManager.MAZE_EXPLORE_TEAM

    local teamHero = remote.teamManager:getActorIdsByKey(self._teamName, 1)
    local heroTotalCount = #teamHero
    for i = 1, heroTotalCount, 1 do
        self._heroOldInfo[i] = remote.herosUtil:getHeroByID(teamHero[i])
    end
    local passTime = self._mazeExploreFightEndResponse and self._mazeExploreFightEndResponse.passTime or 0
    
    local star = self._proxyClass:getPassStarByDungeonId(self._chapterId)

 	battleScene.curModalDialog = QMazeExploreDialogWin.new(
            {	
            	heroOldInfo = self._heroOldInfo,
            	exp = 0,
            	star = star,
            	timeType = "2",
            	teamName = remote.teamManager.MAZE_EXPLORE_TEAM,
            	addScore = self._mazeExploreFightEndResponse and self._mazeExploreFightEndResponse.addScore or 0,
                passTime = self._mazeExploreFightEndResponse and self._mazeExploreFightEndResponse.passTime or 0,
                isWin = star > 0 and true or false,
            }, self:getCallTbl())
end

return QMazeExploreResultController