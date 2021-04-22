--
-- Author: Kumo
-- Date: 2015-01-15 
-- 

local QBaseArrangement = import(".QBaseArrangement")
local QUnionDragonTaskArrangement = class("QUnionDragonTaskArrangement", QBaseArrangement)

local QUIViewController = import("..ui.QUIViewController")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QNavigationController = import("..controllers.QNavigationController")
local QDungeonResourceLoader = import("..loader.QDungeonResourceLoader")

function QUnionDragonTaskArrangement:ctor(options)
	QUnionDragonTaskArrangement.super.ctor(self)

	self._taskId = options.taskId
	self:setIsLocal(true)
end

function QUnionDragonTaskArrangement:startBattle()
	local config = QStaticDatabase:sharedDatabase():getDungeonConfigByID("dragon_task")
	config = q.cloneShrinkedObject(config)
    config.isInDragon = true
    config.taskId = self._taskId
	self:_initDungeonConfig(config)

	-- app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)

	local loader = QDungeonResourceLoader.new(config)
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_PAGE, uiClass = "QUIPageLoadResources", options = {dungeon = config, isKeepOldPage = true, loader = loader}})
end

return QUnionDragonTaskArrangement
