

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetWordsPrompt = class("QUIWidgetWordsPrompt", QUIWidget)

local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIWidgetWordsPrompt:ctor(options)
	local ccbFile = "ccb/Widget_DialySignIn_GlodPrompt.ccbi"
	local callBacks = {}
	QUIWidgetWordsPrompt.super.ctor(self, ccbFile, callBacks, options)
	self.word = options.words or""

	self._ccbOwner.content:setString(self.word or "")
	local wordSize = self._ccbOwner.content:getContentSize()

	local oldSize = self._ccbOwner.itme_bg:getContentSize()
	self._ccbOwner.itme_bg:setContentSize(CCSize(wordSize.width + 30, oldSize.height))
	local contentSzie = self._ccbOwner.itme_bg:getContentSize()
	self.size = CCSize(wordSize.width + 30, contentSzie.height)
end


return QUIWidgetWordsPrompt