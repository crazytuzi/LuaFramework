local QBattleResultProxy = class("QBattleResultProxy")
local QSparFieldResultController = import(".controllers.QSparFieldResultController")
local QFriendResultController = import(".controllers.QFriendResultController")
local QSilverMineResultController = import(".controllers.QSilverMineResultController")
local QGloryResultController = import(".controllers.QGloryResultController")
local QMaritimeResultController = import(".controllers.QMaritimeResultController")
local QSunWellResultController = import(".controllers.QSunWellResultController")
local QSocietyDungeonResultController = import(".controllers.QSocietyDungeonResultController")
local QWelfareInstanceResultController = import(".controllers.QWelfareInstanceResultController")
local QInvasionResultController = import(".controllers.QInvasionResultController")
local QDragonWarResultController = import(".controllers.QDragonWarResultController")
local QWorldBossResultController = import(".controllers.QWorldBossResultController")
local QGloryArenaResultController = import(".controllers.QGloryArenaResultController")
local QStormArenaResultController = import(".controllers.QStormArenaResultController")
local QArenaResultController = import(".controllers.QArenaResultController")
local QThunderResultController = import(".controllers.QThunderResultController")
local QNightmareResultController = import(".controllers.QNightmareResultController")
local QBlackRockResultController = import(".controllers.QBlackRockResultController")
local QDungeonResultController = import(".controllers.QDungeonResultController")
local QMetalCityResultController = import(".controllers.QMetalCityResultController")
local QFightClubResultController = import(".controllers.QFightClubResultController")
local QSancruaryResultController = import(".controllers.QSancruaryResultController")
local QConsortiaWarResultController = import(".controllers.QConsortiaWarResultController")
local QUnionDragonTaskResultController = import(".controllers.QUnionDragonTaskResultController")
local QSotoTeamResultController = import(".controllers.QSotoTeamResultController")
local QCollegetTrainResultController = import(".controllers.QCollegetTrainResultController")
local QMockBattleResultController = import(".controllers.QMockBattleResultController")
local QTotemChallengeResultController = import(".controllers.QTotemChallengeResultController")
local QSoulTowerResultController = import(".controllers.QSoulTowerResultController")
local QSilvesArenaResultController = import(".controllers.QSilvesArenaResultController")
local QMazeExploreResultController = import(".controllers.QMazeExploreResultController")

local QDragonWarResultControllerLocal = import(".controllers.QDragonWarResultControllerLocal")

local QMetalAbyssResultController = import(".controllers.QMetalAbyssResultController")


function QBattleResultProxy:ctor(options)
	
end

function QBattleResultProxy:onResult(isWin)
	self._resultController = nil
    if not app.battle:isInEditor() and (not app.battle:isInReplay() or app.battle:isInQuick()) and not app.battle:isInFriend() then
        if app.battle:isPVPMode() == true then
            if app.battle:isInSparField() == true then
            	self._resultController = QSparFieldResultController.new()
            -- elseif app.battle:isInFriend() == true then
            --     self._resultController = QFriendResultController.new()
            elseif app.battle:isInSilverMine() == true then
                self._resultController = QSilverMineResultController.new()
            elseif app.battle:isInGlory() == true then
                self._resultController = QGloryResultController.new()
            elseif app.battle:isInMaritime() == true then
                self._resultController = QMaritimeResultController.new()
            elseif app.battle:isInSunwell() == true then
                self._resultController = QSunWellResultController.new()
            elseif app.battle:isInGloryArena() == true then
                self._resultController = QGloryArenaResultController.new()
            elseif app.battle:isInStormArena() == true then
                self._resultController = QStormArenaResultController.new()
            elseif app.battle:isInFightClub() == true then
                self._resultController = QFightClubResultController.new()
            elseif app.battle:isInSancruary() == true then
                self._resultController = QSancruaryResultController.new()
            elseif app.battle:isInConsortiaWar() == true then
                self._resultController = QConsortiaWarResultController.new()
            elseif app.battle:isInSotoTeam() == true then
                self._resultController = QSotoTeamResultController.new()
            elseif  app.battle:isMockBattle() == true then
                self._resultController = QMockBattleResultController.new()
            elseif  app.battle:isTotemChallenge() == true then
                self._resultController = QTotemChallengeResultController.new()
            elseif app.battle:isInArena() == true then
                self._resultController = QArenaResultController.new()
            elseif app.battle:isInSilvesArena() == true then
                self._resultController = QSilvesArenaResultController.new()
            elseif app.battle:isInMetalAbyss() == true then
                self._resultController = QMetalAbyssResultController.new()
            end
        else
            if app.battle:isInSilverMine() == true then
                -- 魂兽森林
                self._resultController = QSilverMineResultController.new()
            elseif app.battle:isInSocietyDungeon()  == true then
                -- 公会副本
                self._resultController = QSocietyDungeonResultController.new()
            elseif app.battle:isInWelfare() == true then
                -- 史诗副本
                self._resultController = QWelfareInstanceResultController.new()
            elseif app.battle:isInRebelFight() == true then
                -- 要塞入侵
                self._resultController = QInvasionResultController.new()
            elseif app.battle:isInUnionDragonWar() == true then
                -- 巨龙斗场
                if app.battle:isLocalFight() == true then
                    self._resultController = QDragonWarResultControllerLocal.new()
                else
                    self._resultController = QDragonWarResultController.new()
                end
            elseif app.battle:isInWorldBoss() == true then
                -- 世界BOSS
                self._resultController = QWorldBossResultController.new()
            elseif app.battle:isInThunder() == true then
                -- 雷电王座
                self._resultController = QThunderResultController.new()
            elseif app.battle:isInNightmare() == true then
                -- 噩梦
                self._resultController = QNightmareResultController.new()
            elseif app.battle:isInBlackRock() == true then
                -- 溶火组队战
                self._resultController = QBlackRockResultController.new()
            elseif app.battle:isInMetalCity() == true then
                -- 金属之城
                self._resultController = QMetalCityResultController.new()
            elseif app.battle:isInDragon() == true then
                -- 宗门养龙：潮汐炼体
                self._resultController = QUnionDragonTaskResultController.new()
            elseif app.battle:isCollegeTrain() == true then
                -- 训练关
                self._resultController = QCollegetTrainResultController.new()
            elseif  app.battle:isMockBattle() == true then
                self._resultController = QMockBattleResultController.new()
            elseif app.battle:isSoulTower() == true then
                self._resultController = QSoulTowerResultController.new()
            elseif app.battle:isMazeExplore() == true then
                self._resultController = QMazeExploreResultController.new()
            else
                self._resultController = QDungeonResultController.new()
            end
        end
    end
    
    if self._resultController ~= nil then
    	self._resultController:requestResult(isWin)
        return true
    end
    return false
end

function QBattleResultProxy:onMoveCompleted()
	if self._resultController ~= nil then
		self._resultController:onMoveCompleted()
        return true
	end
    return false
end

function QBattleResultProxy:removeAll()
    if self._resultController then
        self._resultController:removeAll()
        self._resultController = nil
    end
end

return QBattleResultProxy