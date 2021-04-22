--
-- Author: Qinyuanji
-- Date: 2016-05-20
-- This class is the base resource loader.

local QBaseLoader = class("QBaseLoader")

QBaseLoader.PROGRESSING = "QBaseLoader_PROGRESSING"
QBaseLoader.END = "QBaseLoader_END"

function QBaseLoader:ctor()
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QBaseLoader:start( ... )
	assert(false, "Please implement start function")
end

function QBaseLoader:setPercent(percent)
	assert(percent >= 0 and percent <= 100, "You must set valid percent between 0 and 100")
	self:dispatchEvent({name = QBaseLoader.PROGRESSING, percent = percent})
end

function QBaseLoader:finish()
	self:dispatchEvent({name = QBaseLoader.END})
end


return QBaseLoader
