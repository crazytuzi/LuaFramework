local QBaseAssist = import(".QBaseAssist")
local QEnterAssist = class("QEnterAssist", QBaseAssist)

function QEnterAssist:ctor(options)
	QEnterAssist.super.ctor(self, options)
end

function QEnterAssist:run(callback)
	QEnterAssist.super.run(self, callback)
	self:backToMainPage()
	self:complete()
end

return QEnterAssist