--
-- Author: Your Name
-- Date: 2014-10-21 18:30:20
--
local QUIDialog = import("..Dialogs.QUIDialog")
local QUIDialogTipsMonsterInfo = class("QUIDialogTipsMonsterInfo", QUIDialog)
local QUIWidgetMonsterPrompt = import("..widgets.QUIWidgetMonsterPrompt")

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIDialogTipsMonsterInfo:ctor(options)
  	local ccbFile = nil
  	local callbacks = {}
  	QUIDialogTipsMonsterInfo.super.ctor(self, ccbFile, callbacks, options)

	local info = options.info
	local config = options.config
	local isHideLevel = options.isHideLevel
	self.prompt = QUIWidgetMonsterPrompt.new({info = info, config = config,isHideLevel = isHideLevel})
	self:getView():addChild(self.prompt)
end

function QUIDialogTipsMonsterInfo:viewDidAppear()
	QUIDialogTipsMonsterInfo.super.viewDidAppear(self)
end

function QUIDialogTipsMonsterInfo:viewWillDisappear()
	QUIDialogTipsMonsterInfo.super.viewWillDisappear(self)
end

function QUIDialogTipsMonsterInfo:_backClickHandler()
	self:popSelf()
end

return QUIDialogTipsMonsterInfo
