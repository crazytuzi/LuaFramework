local QBaseAssist = import(".QBaseAssist")
local QClearAssist = class("QClearAssist", QBaseAssist)

function QClearAssist:ctor(options)
	QClearAssist.super.ctor(self, options)
end

function QClearAssist:run(callback)
	QClearAssist.super.run(self, callback)
	self.assist:clearLog()
	self:complete()
end

return QClearAssist