
-- @Author: liaoxianbo
-- @Date:   2019-11-13 15:25:38
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-12-05 19:30:51

local QBaseTrainArrangement = import(".QBaseTrainArrangement")
local QCollegeTrainArrangement = class("QCollegeTrainArrangement", QBaseTrainArrangement)

local QUIViewController = import("..ui.QUIViewController")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QNavigationController = import("..controllers.QNavigationController")
local QDungeonResourceLoader = import("..loader.QDungeonResourceLoader")


function QCollegeTrainArrangement:ctor(options)

-- {chapterId = chapterId,heroList = allHeroList,chapterId = chapterId,spritList = allSpritList,teamKey = "colleget_team"}

	QCollegeTrainArrangement.super.ctor(self, options.chapterId,options.heroList, options.spritList, remote.collegetrain, options.teamKey)
	self._heroes = options.heroList
	self._chapterId = options.chapterId
	self._spritList = options.spritList or {}
	self._teamName = options.teamKey
end

function QCollegeTrainArrangement:showHeroState()
	return true
end

function QCollegeTrainArrangement:getBackPagePath(index)
	return QSpriteFrameByKey("collegeTrain_arrangement_bg", 1)
end

function QCollegeTrainArrangement:getEffectPagePath(index)
	return QSpriteFrameByKey("collegeTrain_arrangement_bg", 2)
end

function QCollegeTrainArrangement:startBattle(force,heroIdList)
    app:getUserOperateRecord():setCollegeTrainTeam(heroIdList,self._chapterId)
    local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)
    remote.collegetrain:startCollegeTrainFightBattle(self._chapterId, battleFormation, function (data)

        local chapterInfo = db:getCollegeTrainConfigById(self._chapterId)
        local strDungeonId = db:convertDungeonID(chapterInfo.dungeon_config)
        local config = db:getDungeonConfigByID(strDungeonId)

        config = q.cloneShrinkedObject(config)
        config.isCollegeTrain = true
        config.teamName = self._teamName
        config.verifyKey = data.gfStartResponse.battleVerify

        config.heroRecords = remote.herosUtil:getShowHerosKey() or {}
        config.isRecommend = self._isRecommend

        config.force = force

        config.battleFormation = battleFormation
    

        self:_initDungeonConfig(config,heroIdList)

        app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
        
        local loader = QDungeonResourceLoader.new(config)
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_PAGE, uiClass = "QUIPageLoadResources", options = {dungeon = config, isKeepOldPage = true, loader = loader}})
    end)
end

return QCollegeTrainArrangement
