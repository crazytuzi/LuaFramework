local QUIWidget = import(".QUIWidget")
local QUIWidgetTraining = class("QUIWidgetTraining", QUIWidget)

local QUIViewController = import("..QUIViewController")
local QNavigationController = import("...controllers.QNavigationController")
local QUIHeroModel = import("...models.QUIHeroModel")
local QUIWidgetTrainClient = import("..widgets.QUIWidgetTrainClient")

QUIWidgetTraining.CLICK_TRAIN_MASTER = "CLICK_TRAIN_MASTER"


function QUIWidgetTraining:ctor(options)
	local ccbFile = "ccb/Widget_HeroDevelop.ccbi"
	local callBacks = {
	}
	QUIWidgetTraining.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetTraining:onEnter()
end

function QUIWidgetTraining:onExit()
    if self._trainingWidget then
        self._trainingWidget:removeAllEventListeners()
        self._trainingWidget = nil
    end
end

function QUIWidgetTraining:update( actorId )
	if self._trainingWidget == nil then 
		self._trainingWidget = QUIWidgetTrainClient.new()
		self._ccbOwner.sheet:addChild(self._trainingWidget)
		self._trainingWidget:addEventListener(QUIWidgetTraining.CLICK_TRAIN_MASTER, handler(self, self._onTriggerTrainMaster))
	end
	self._trainingWidget:update(actorId)
end


function QUIWidgetTraining:_onTriggerTrainMaster()
	self:dispatchEvent({name = QUIWidgetTraining.CLICK_TRAIN_MASTER, masterType = QUIHeroModel.HERO_TRAIN_MASTER})
end


return QUIWidgetTraining