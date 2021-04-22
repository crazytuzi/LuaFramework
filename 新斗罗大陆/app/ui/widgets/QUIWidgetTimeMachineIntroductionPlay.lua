-- @Author: liaoxianbo
-- @Date:   2019-07-26 15:36:11
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-07-26 16:09:25
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetTimeMachineIntroductionPlay = class("QUIWidgetTimeMachineIntroductionPlay", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QRichText = import("...utils.QRichText")

function QUIWidgetTimeMachineIntroductionPlay:ctor(options)
	local ccbFile = "ccb/Widget_Timemachine_skill.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIWidgetTimeMachineIntroductionPlay.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._size = self._ccbOwner.layer_size:getContentSize()
	self._offsetHeight = 0
end

function QUIWidgetTimeMachineIntroductionPlay:init(data ) 
	if not data then return end
	self._ccbOwner.tf_skill_name:setString("【"..data.title.."】")
	if self._richText == nil then
		self._richText = QRichText.new("", 450, {autoCenter = false, stringType = 1, defaultColor = COLORS.j})
		self._richText:setAnchorPoint(0, 1)
		self._ccbOwner.node_textContent:addChild(self._richText)
		self._ccbOwner.node_textContent:setPositionX(-225)
	end
	self._richText:setString(data.content)
	self._offsetHeight = self._richText:getContentSize().height
end

function QUIWidgetTimeMachineIntroductionPlay:onEnter()
end

function QUIWidgetTimeMachineIntroductionPlay:onExit()
end

function QUIWidgetTimeMachineIntroductionPlay:getContentSize()
	return CCSize(self._size.width, self._size.height + self._offsetHeight)
end

return QUIWidgetTimeMachineIntroductionPlay
