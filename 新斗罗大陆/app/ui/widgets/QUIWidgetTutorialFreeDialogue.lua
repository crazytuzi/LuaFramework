 
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetTutorialFreeDialogue = class("QUIWidgetTutorialFreeDialogue", QUIWidget)
local QRichText = import("...utils.QRichText")

QUIWidgetTutorialFreeDialogue.LEFT = "left"
QUIWidgetTutorialFreeDialogue.RIGHT = "right"

QUIWidgetTutorialFreeDialogue.ANIMATION_END = "QUIWidgetTutorialFreeDialogue_ANIMATION_END"

function QUIWidgetTutorialFreeDialogue:ctor(options)
	local ccbFile = "ccb/Widget_TutorialFreeDialogue.ccbi"
	local callbacks = {}
	QUIWidgetTutorialFreeDialogue.super.ctor(self, ccbFile, callbacks, options)

	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._options = options or {}
	self._model = self._options.model or QUIWidgetTutorialFreeDialogue.RIGHT
	self._wordList = string.split(self._options.words or "", "#")
	-- QPrintTable(self._wordList)
 	
	self._minWidth = 200
	self._minHeight = 100
	self._baseX = 78
	self._offsetWidth = 20
	self._offsetHeight = 15

	self._ccbOwner.node_text_bg:setPosition(0, 0)
	self._ccbOwner.node_text_bg:setScale(1)
	self._ccbOwner.node_text_bg:setVisible(false)
	self._ccbOwner.s9s_bg:setPosition(self._baseX, 0)
	self._ccbOwner.s9s_bg:setScale(1)

	self._ccbOwner.node_text:setPosition(self._baseX, 3)
	self._ccbOwner.node_text:setScale(1)
	self._ccbOwner.node_text:setVisible(false)

	self._ccbam =  tolua.cast(self._ccbView:getUserObject(), "CCBAnimationManager")
	self._ccbam:connectScriptHandler(function(name)
		if name == "one" then
	        self:dispatchEvent({name = QUIWidgetTutorialFreeDialogue.ANIMATION_END})
	   	end
	   	if self._ccbam ~= nil then
	        self._ccbam:disconnectScriptHandler()
	        self._ccbam = nil
	    end
    end)
    self._ccbam:runAnimationsForSequenceNamed("one")

	self:_init()
end

function QUIWidgetTutorialFreeDialogue:onEnter()
end

function QUIWidgetTutorialFreeDialogue:onExit()
	if self._ccbam ~= nil then
        self._ccbam:disconnectScriptHandler()
        self._ccbam = nil
    end
end

function QUIWidgetTutorialFreeDialogue:_init()
	self._ccbOwner.node_text:removeAllChildren()
	self._richText = nil

	if #self._wordList > 0 and self._wordList[1] ~= ""  then
		local tbl = {}
		local lineNum = 1
		for _, word in ipairs(self._wordList) do
			if #tbl > 0 then
				table.insert(tbl, {oType = "wrap"})
				lineNum = lineNum + 1
			end
			table.insert(tbl, {oType = "font", content = word, size = 22, color = COLORS.k})
		end
		if #tbl > 0 then
			self._richText = QRichText.new(tbl)
	        self._ccbOwner.node_text:addChild(self._richText)
		end
       	if self._richText then
	        local richTextSize = self._richText:getContentSize()
			local width = richTextSize.width <= self._minWidth and self._minWidth or richTextSize.width
	        if self._model == QUIWidgetTutorialFreeDialogue.LEFT then
				self._ccbOwner.node_text_bg:setScaleX(-1)
				self._richText:setPosition(-width, -richTextSize.height/2)
				self._ccbOwner.node_text:setPosition(-(self._baseX + self._offsetWidth), 3)
			else
				self._richText:setPosition(0, -richTextSize.height/2)
				self._ccbOwner.node_text:setPosition(self._baseX + self._offsetWidth, 3)
			end
			
			richTextSize.height = richTextSize.height + lineNum * self._offsetHeight
			local height = richTextSize.height <= self._minHeight and self._minHeight or richTextSize.height
			self._ccbOwner.s9s_bg:setPreferredSize(CCSize(width + self._offsetWidth*2, height))
			
			self._ccbOwner.node_text_bg:setVisible(true)
			self._ccbOwner.node_text:setVisible(true)
		end
	end
end

return QUIWidgetTutorialFreeDialogue