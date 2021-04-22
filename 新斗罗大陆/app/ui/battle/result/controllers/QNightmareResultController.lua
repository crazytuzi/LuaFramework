
local QBaseResultController = import(".QBaseResultController")
local QNightmareResultController = class("QNightmareResultController", QBaseResultController)

local QNightmareDialogWin = import("..dialogs.QNightmareDialogWin")
local QBattleDialogLose = import("..dialogs.QBattleDialogLose")

function QNightmareResultController:ctor(options)
end

function QNightmareResultController:requestResult(isWin)
    self._isWin = isWin
    local battleScene = self:getScene()
    local dungeonConfig = battleScene:getDungeonConfig()
    if self._isWin then
	    remote.nightmare:nightmareFightEndRequest(dungeonConfig.int_id, dungeonConfig.verifyKey, self._isWin,
	        function(data)
	            self:setResponse(data)
		    end,function(data)
		        self:requestFail(data)
		    end)
	else
		self:setResponse({})
	end
end

function QNightmareResultController:fightEndHandler()
    local battleScene = self:getScene()
    local dungeonConfig = battleScene:getDungeonConfig()
    remote.user:addPropNumForKey("todayNightmareDungeonFightCount")
    if self._isWin then
        local info = {}
        info.heros = {}
        local attackTeam = remote.teamManager:getActorIdsByKey(remote.teamManager.INSTANCE_TEAM, 1)
        for _,actorId in pairs(attackTeam) do
            table.insert(info.heros, remote.herosUtil:getHeroByID(actorId))
        end

        battleScene.curModalDialog = QNightmareDialogWin.new({info=info, isWin = true, awards = self.response.gfEndResponse.nightmareDungeonFightEndResponse},self:getCallTbl())
    else
        battleScene.curModalDialog = QBattleDialogLose.new(nil,self:getLoseCallTbl())
    end
end

return QNightmareResultController