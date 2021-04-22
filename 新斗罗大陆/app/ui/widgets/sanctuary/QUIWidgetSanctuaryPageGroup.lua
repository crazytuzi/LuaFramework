--
-- zxs
-- 精英赛组
--

local QUIWidget = import("..QUIWidget")
local QUIWidgetSanctuaryPageGroup = class("QUIWidgetSanctuaryPageGroup", QUIWidget)

QUIWidgetSanctuaryPageGroup.EVENT_GROUP_CLICK = "EVENT_GROUP_CLICK"

function QUIWidgetSanctuaryPageGroup:ctor(options)
	local ccbFile = "ccb/Widget_Sanctuary_Group.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
	}
	QUIWidgetSanctuaryPageGroup.super.ctor(self,ccbFile,callBacks,options)

	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetSanctuaryPageGroup:setIndex(index)
	self._index = index
	self._ccbOwner.tf_group:setString("第"..self._index.."组")
end

function QUIWidgetSanctuaryPageGroup:setSpecialIndex(index)
	self._index = index
	if index == 1 then
		self._ccbOwner.tf_group:setString("冠军赛")
	else
		self._ccbOwner.tf_group:setString("季军赛")
	end
end

function QUIWidgetSanctuaryPageGroup:setIsSelf(isSelf)
	self._ccbOwner.sp_self:setVisible(isSelf)
end

function QUIWidgetSanctuaryPageGroup:setIsSelected(isSelected)
	self._ccbOwner.btn_group:setHighlighted(isSelected)
	if isSelected then
		self._ccbOwner.tf_group:setColor(ccc3(255, 255, 255))
	else
		self._ccbOwner.tf_group:setColor(ccc3(255, 240, 150))
	end
end

function QUIWidgetSanctuaryPageGroup:_onTriggerClick()
	app.sound:playSound("common_small")
	self:dispatchEvent({name = QUIWidgetSanctuaryPageGroup.EVENT_GROUP_CLICK, index = self._index})
end

return QUIWidgetSanctuaryPageGroup