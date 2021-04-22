local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetActorDisplay = import("...widgets.actorDisplay.QUIWidgetActorDisplay")
local QUIWidgetActorActivityDisplay = class("QUIWidgetActorActivityDisplay", QUIWidgetActorDisplay)
local QStaticDatabase = import("....controllers.QStaticDatabase")
local QUIWidgetAnimationPlayer = import("...widgets.QUIWidgetAnimationPlayer")
local QChatDialog = import("....utils.QChatDialog")

QUIWidgetActorActivityDisplay.EVENT_CLICK = "EVENT_CLICK"

function QUIWidgetActorActivityDisplay:ctor(actorId, options)
	QUIWidgetActorActivityDisplay.super.ctor(self, actorId, options)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._touchLayer = CCLayerColor:create(ccc4(128, 128, 128, 0), 100, 120)
	self._touchLayer:setCascadeBoundingBox(CCRect(0,0,0,0))
	self._touchLayer:setPositionX(-50)
	self:addChild(self._touchLayer)
    self._touchLayer:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    self._touchLayer:setTouchEnabled(true)
    self._touchLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QUIWidgetActorActivityDisplay._onTouch))
end

function QUIWidgetActorActivityDisplay:onExit()
	QUIWidgetActorActivityDisplay.super.onExit(self)
end

function QUIWidgetActorActivityDisplay:_onTouch(event)
	if event.name == "began" then 
		return true
	elseif event.name == "ended" or event.name == "cancelled" then 
		self:_onTriggerClick()
	end
end

function QUIWidgetActorActivityDisplay:_onTriggerClick()
	self:dispatchEvent({name = QUIWidgetActorActivityDisplay.EVENT_CLICK, actor = self})
end

function QUIWidgetActorActivityDisplay:playVictory()
	self:stopWalking()
	self:stopDisplay()
	self:displayWithBehavior(ANIMATION_EFFECT.VICTORY)
	self:showWord()
end

function QUIWidgetActorActivityDisplay:walkto(point)
	QUIWidgetActorActivityDisplay.super.walkto(self, point)
	self:wordScale()
end

function QUIWidgetActorActivityDisplay:wordScale()
	if self._wordWidget and self._actor then
		local scaleX = 1
		if self._actor:getScaleX() == 1 then
			scaleX = -1
		end
		self._wordWidget:setScaleX(scaleX)
	end
end

function QUIWidgetActorActivityDisplay:showWord(str)
	if self._isGag == true then return end --禁言状态不准说话
	self:removeWord()
	local word = "啦啦啦！啦啦啦！我是卖报的小行家！"
	if str ~= nil then
		word = str
	else
		local wordArr = QStaticDatabase.sharedDatabase():getDialogue(1)
		local index = 1
		local randomIndex = math.random(1,table.nums(wordArr))
		for _,value in pairs(wordArr) do
			if index == randomIndex then
				word = value.description
				break
			end
			index = index + 1
		end
	end

	if self._wordWidget == nil then
		self._wordWidget = QChatDialog.new()
		self._wordWidget:setPositionY(120)
		self:addChild(self._wordWidget)

		local character = QStaticDatabase.sharedDatabase():getCharacterByID(self._actorId)
		if character.selected_rect_height and character.actor_scale then
			self._wordWidget:setPositionY(character.selected_rect_height * character.actor_scale)
		end
	end
	self._wordWidget:setString(word)
	self:wordScale()
end

function QUIWidgetActorActivityDisplay:removeWord()
	if self._wordWidget ~= nil then
		self._wordWidget:removeFromParent()
		self._wordWidget = nil
	end
end

function QUIWidgetActorActivityDisplay:getActor()
	return self._actor
end

return QUIWidgetActorActivityDisplay