-- 
-- zxs
-- 玩法日历每天的每个任务
-- 

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetStrongerHelp = class("QUIWidgetStrongerHelp", QUIWidget)

QUIWidgetStrongerHelp.EVENT_GO_CLICK = "EVENT_GO_CLICK"

QUIWidgetStrongerHelp.NEW_SPRITE_GAP = 20  --new标志到功能名称的间距

function QUIWidgetStrongerHelp:ctor(options)
	local ccbFile = "ccb/Widget_stronger_help.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerGo", callback = handler(self, self._onTriggerGo)},
	}
	QUIWidgetStrongerHelp.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	local progress = q.newPercentBarClippingNode(self._ccbOwner.sp_bar_progress)
	self._progressWidth = self._ccbOwner.sp_bar_progress:getContentSize().width
	self._progressStencil = progress:getStencil()

	self._oldSpNewPositionX = self._ccbOwner.sp_new:getPositionX()
end

function QUIWidgetStrongerHelp:resetAll()
	self._ccbOwner.tf_name:setString("")
	self._ccbOwner.tf_progress:setString("")
	self._ccbOwner.node_icon:removeAllChildren()
	self._ccbOwner.node_word:removeAllChildren()
end

function QUIWidgetStrongerHelp:setInfo(info)
	self:resetAll()

	self._info = info
	self._ccbOwner.tf_name:setString(info.name or "")

	-- icon
	local icon = CCSprite:create(info.icon)
	icon:setScale(86/icon:getContentSize().width)
    self._ccbOwner.node_icon:addChild(icon)
	self._ccbOwner.sp_new:setVisible(info.isNew)
	self._ccbOwner.sp_new:setPositionX(self._oldSpNewPositionX + self._ccbOwner.tf_name:getContentSize().width + self.NEW_SPRITE_GAP)

	-- 评价
	local value, picPath = remote.strongerUtil:getStageByStandard(info)
	if picPath then
		local wordIcon = CCSprite:create(picPath)
		self._ccbOwner.node_word:addChild(wordIcon)
	end

	-- 进度
	if value > 1 then
		value = 1
	end
	local progressStr = string.format("%d%%", math.floor(value*100))
    self._progressStencil:setPositionX(value*self._progressWidth - self._progressWidth)
    self._ccbOwner.tf_progress:setString(progressStr)
end

function QUIWidgetStrongerHelp:getContentSize()
	local size = self._ccbOwner.sp_bg:getContentSize()
	size.height = size.height + 8
	return size
end

function QUIWidgetStrongerHelp:_onTriggerGo()
    app.sound:playSound("common_switch")
	self:dispatchEvent({name = QUIWidgetStrongerHelp.EVENT_GO_CLICK, id = self._info.id})
end

return QUIWidgetStrongerHelp