local QBaseAssist = class("QBaseAssist")
local QAssist = import(".QAssist")
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("...ui.QUIViewController")

function QBaseAssist:ctor()
	self.assist = QAssist:getInstance()
end

function QBaseAssist:logger(str)
	self.assist:logger(str)
end

function QBaseAssist:run(callback)
	self._callback = callback
end

function QBaseAssist:complete()
	if self._callback then
		self._callback()
	end
end

function QBaseAssist:backToMainPage()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

function QBaseAssist:openDungeonByType(instanceType)
	return app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMap",
		options = {instanceType = instanceType}})
end

function QBaseAssist:step(callback, delay)
	delay = delay or 1
	scheduler.performWithDelayGlobal(callback, delay)
end

return QBaseAssist