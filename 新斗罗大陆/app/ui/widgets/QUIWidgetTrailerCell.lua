--
-- Kumo.Wang
-- 新功能預告任務詳細
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetTrailerCell = class("QUIWidgetTrailerCell", QUIWidget)

local QRichText = import("...utils.QRichText")

function QUIWidgetTrailerCell:ctor(options)
	local ccbFile = "ccb/Widget_Trailer_Cell.ccbi"
	local callBacks = {}
	QUIWidgetTrailerCell.super.ctor(self, ccbFile, callBacks, options)
end

function QUIWidgetTrailerCell:onEnter()
end

function QUIWidgetTrailerCell:onExit()

end

function QUIWidgetTrailerCell:setInfo(taskId)
	local taskConfig = remote.trailer:getTaskConfigByTaskId(taskId)

	-- name
	if taskConfig.name then
		local richText = QRichText.new(taskConfig.name, 280, {stringType = 1, defaultColor = COLORS.j, defaultSize = 20, fontName = global.font_default})
	    richText:setAnchorPoint(ccp(0, 0.5))
	    self._ccbOwner.node_task_name:removeAllChildren()
		self._ccbOwner.node_task_name:addChild(richText)
		self._ccbOwner.node_task_name:setVisible(true)
	else
		self._ccbOwner.node_task_name:setVisible(false)
	end

	-- progress
	if taskConfig.num then
		local curNum = remote.trailer:getTaskProgressByTaskId(taskId)
		if curNum >= tonumber(taskConfig.num) then
			self._ccbOwner.tf_progress:setColor(COLORS.l)
			curNum = tonumber(taskConfig.num)
		else
			self._ccbOwner.tf_progress:setColor(COLORS.m)
		end
		self._ccbOwner.tf_progress:setString(curNum.."/"..taskConfig.num)
		self._ccbOwner.tf_progress:setVisible(true)
	else
		self._ccbOwner.tf_progress:setVisible(false)
	end
end

function QUIWidgetTrailerCell:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

return QUIWidgetTrailerCell