local QBaseAssist = import(".QBaseAssist")
local QExitAssist = class("QExitAssist", QBaseAssist)

function QExitAssist:ctor(options)
	QExitAssist.super.ctor(self, options)
end

function QExitAssist:run(callback)
	QExitAssist.super.run(self, callback)
	self.assist:complete()
	self:complete()
end

return QExitAssist