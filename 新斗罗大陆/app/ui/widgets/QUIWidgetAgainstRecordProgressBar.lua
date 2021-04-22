
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetAgainstRecordProgressBar = class("QUIWidgetAgainstRecordProgressBar", QUIWidget)

local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIWidgetAgainstRecordProgressBar:ctor(options)
	local ccbFile = "ccb/Widget_AgainstRecod_ProgressBar.ccbi"
	QUIWidgetAgainstRecordProgressBar.super.ctor(self,ccbFile,callBacks,options)

	self._red_scale_original = self._ccbOwner.sprite_red:getScaleX()
	self._green_scale_original = self._ccbOwner.sprite_green:getScaleX()
end

function QUIWidgetAgainstRecordProgressBar:setColor(color)
	self._color = color

	local owner = self._ccbOwner
	if color == "green" then
		owner.node_green:setVisible(true)
		owner.node_red:setVisible(false)
	elseif color == "red" then
		owner.node_red:setVisible(true)
		owner.node_green:setVisible(false)
	end
end

function QUIWidgetAgainstRecordProgressBar:hideText()
	local owner = self._ccbOwner
	owner.label_greentext:setVisible(false)
	owner.label_redtext:setVisible(false)
end

function QUIWidgetAgainstRecordProgressBar:setCurValue(value, maxValue)
	self:setColor("green")
	local progress = math.max(value/maxValue, 0.005)
	local hpBarClippingNode = q.newPercentBarClippingNode(self._ccbOwner.sprite_green)
    local stencil = hpBarClippingNode:getStencil()
    local totalStencilWidth = stencil:getContentSize().width * stencil:getScaleX()
    local posX = - totalStencilWidth + progress*totalStencilWidth
	stencil:setPositionX(posX)
end

function QUIWidgetAgainstRecordProgressBar:setValue(start_value, end_value, start_progress, end_progress, prefix)
	local color = self._color

	if self._scheduler_id or (color ~= "green" and color ~= "red") then
		return
	end

	local owner = self._ccbOwner
	local bar = color == "green" and owner.sprite_green or owner.sprite_red
	local label = color == "green" and owner.label_greentext or owner.label_redtext
	local scale_original = color == "green" and self._green_scale_original or self._red_scale_original
	-- label:setString(string.format(prefix .. "%d", end_value))
	-- bar:setScaleX(scale_original * end_progress)
	label:setString("")
	-- bar:setScaleX(0)
	local coefficient = color == "green" and 1 or -1
	local hpBarClippingNode = q.newPercentBarClippingNode(bar)
    local stencil = hpBarClippingNode:getStencil()
    local totalStencilWidth = stencil:getContentSize().width * stencil:getScaleX()
    stencil:setPositionX((-totalStencilWidth + 0*totalStencilWidth) * coefficient )

	local start_scale = scale_original * start_progress
	local end_scale = scale_original * end_progress

	local procedure_time = 0.5
	local start_time
	
	self._scheduler_id = scheduler.scheduleGlobal(function()
		if not start_time then
			start_time = q.time()
		end

		local current = (q.time() - start_time) / procedure_time
		current = math.min(current, 1.0)

		local current_value = math.sampler(start_value, end_value, current)
		local current_scale = math.sampler(start_scale, end_scale, current)
		local force, unit = q.convertLargerNumber(math.floor(current_value))
		label:setString(prefix..force..unit)
		-- bar:setScaleX(current_scale)
		stencil:setPositionX((-totalStencilWidth + current_scale/scale_original*totalStencilWidth) * coefficient)
		if current == 1.0 then
			scheduler.unscheduleGlobal(self._scheduler_id)
			self._scheduler_id = nil
		end
	end, 0)
end

function QUIWidgetAgainstRecordProgressBar:onCleanup()
	if self._scheduler_id then
		scheduler.unscheduleGlobal(self._scheduler_id)
		self._scheduler_id = nil
	end
end

return QUIWidgetAgainstRecordProgressBar