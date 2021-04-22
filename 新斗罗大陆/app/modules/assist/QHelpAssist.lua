local QBaseAssist = import(".QBaseAssist")
local QHelpAssist = class("QHelpAssist", QBaseAssist)

function QHelpAssist:ctor(options)
	QHelpAssist.super.ctor(self, options)
end

function QHelpAssist:run(callback)
	QHelpAssist.super.run(self, callback)
	self:logger("----------run assist command at game.")
	self:logger("----------assist([command])")
	self:logger("----------assist()         is enter assist control panel")
	self:logger("----------assist(exit)     is exit assist control panel")
	self:logger("----------assist(help)     is show help")
	self:logger("----------you can run code at here, for example: ")
	self:logger("----------print('hello world!')")
	self:complete()
end

return QHelpAssist