local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetSocirtyUnionQuestion = class("QUIWidgetSocirtyUnionQuestion", QUIWidget)

QUIWidgetSocirtyUnionQuestion.EVENT_SELECT = "EVENT_SELECT"

function QUIWidgetSocirtyUnionQuestion:ctor(options)
	local ccbFile = "ccb/Widget_wenjuandati_client.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerSelect", 				callback = handler(self, self._onTriggerSelect)},
	}
	QUIWidgetSocirtyUnionQuestion.super.ctor(self,ccbFile,callBacks,options)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetSocirtyUnionQuestion:setInfo(index, option)
	-- self._ccbOwner.btn_select:setEnabled(true)
	-- self._ccbOwner.btn_select:setHighlighted(false)
	self:showBgState(true)
	self._index = index
	self._option = tostring(option)
	if index == 1 then
		option = "A.  "..self._option
	elseif index == 2 then
		option = "B.  "..self._option
	elseif index == 3 then
		option = "C.  "..self._option
	elseif index == 4 then
		option = "D.  "..self._option
	end
	self._ccbOwner.sp_right:setVisible(false)
	self._ccbOwner.sp_wrong:setVisible(false)
	self._ccbOwner.tf_content:setString(option)
end
function QUIWidgetSocirtyUnionQuestion:showBgState( flag )
	self._ccbOwner.sp_normal:setVisible(flag)
	self._ccbOwner.sp_light:setVisible(not flag)
end
function QUIWidgetSocirtyUnionQuestion:setRightAnswer(rightOption, index)
	local isRight = self._option == tostring(rightOption)
	if isRight == true or index == self._index then
		self._ccbOwner.sp_right:setVisible(isRight)
		self._ccbOwner.sp_wrong:setVisible(not isRight)
	end
	if index == self._index then
		-- self._ccbOwner.btn_select:setEnabled(false)
		-- self._ccbOwner.btn_select:setHighlighted(true)
		self:showBgState(false)
	end
end

function QUIWidgetSocirtyUnionQuestion:getWidgetOption()
	return self._option or ""
end

function QUIWidgetSocirtyUnionQuestion:_onTriggerSelect(event)
	-- if q.buttonEventShadow(event,self._ccbOwner.btn_select) == false then return end
	if tonumber(event) == CCControlEventTouchDown then
		self._ccbOwner.sp_normal:setColor(ccc3(210, 210, 210))
	else
		self._ccbOwner.sp_normal:setColor(ccc3(255, 255, 255))
	end
	if tonumber(event) == CCControlEventTouchUpInside then
		self:dispatchEvent({name = QUIWidgetSocirtyUnionQuestion.EVENT_SELECT, index = self._index, answer = self._option})
	end
end

return QUIWidgetSocirtyUnionQuestion