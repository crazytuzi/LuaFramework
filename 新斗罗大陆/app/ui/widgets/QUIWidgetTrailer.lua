--
-- Kumo.Wang
-- 新功能預告任務icon 
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetTrailer = class("QUIWidgetTrailer", QUIWidget)

local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QActorProp = import("..models.QActorProp")

function QUIWidgetTrailer:ctor(options)
	local ccbFile = "ccb/Widget_Trailer.ccbi"
	local callBacks = {}
	QUIWidgetTrailer.super.ctor(self, ccbFile, callBacks, options)

	self._isUnlock = false
	self._isComplete = false
	self._isDone = false
end

function QUIWidgetTrailer:onEnter()
end

function QUIWidgetTrailer:onExit()

end

function QUIWidgetTrailer:setInfo(info)
	self._isUnlock = false
	self._isComplete = false
	self._isDone = false

	self._info = info
	-- icon
	if info and info.icon then
		QSetDisplaySpriteByPath(self._ccbOwner.sp_icon, "ui/"..info.icon)
	end

	-- name
	if info and info.name then
		self._ccbOwner.tf_name:setString(info.name)
		self._ccbOwner.tf_name:setVisible(true)
	else
		self._ccbOwner.tf_name:setVisible(false)
	end

	self:updateInfo()
end

function QUIWidgetTrailer:updateInfo()
	if not self._info then return end

	local info = self._info
	-- level
	if info and info.closing_condition then
		self._ccbOwner.tf_unlock_level:setString(info.closing_condition.."级")
		self._ccbOwner.tf_unlock_level:setVisible(true)
		if remote.user.level >= info.closing_condition then
			self._isUnlock = true
			makeNodeFromGrayToNormal(self._ccbOwner.node_task_icon)
		else
			self._isUnlock = false
			makeNodeFromNormalToGray(self._ccbOwner.node_task_icon)
		end
	else
		self._isUnlock = false
		self._ccbOwner.tf_unlock_level:setVisible(false)
	end

	if not info then
		self._isUnlock = false
		self._isComplete = false
		self._isDone = false
	elseif self._isUnlock then
		self._isDone = remote.trailer:isDoneByConfigId(info.id)
		if self._isDone then
			self._isComplete = true
		else
			if info.unlock_task then
				-- 解鎖型任務
				self._isComplete = app.unlock:checkLock(info.unlock_task)
			elseif info.tasks then
				-- 多任務列表
				local taskDetailData = string.split(info.tasks, ";")
				for _, taskId in ipairs(taskDetailData) do
					local progress = remote.trailer:getTaskProgressByTaskId(taskId)
					local config = remote.trailer:getTaskConfigByTaskId(taskId)
					if progress >= tonumber(config.num) then
						self._isComplete = true
					else
						self._isComplete = false
						break
					end
				end
			else
				self._isComplete = false
			end
		end
	else
		self._isComplete = false
		self._isDone = false
	end

	self._ccbOwner.sp_tips:setVisible(self._isUnlock and self._isComplete and not self._isDone)
	self._ccbOwner.sp_done:setVisible(self._isDone)
end

function QUIWidgetTrailer:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetTrailer:isUnlock()
	return self._isUnlock
end

function QUIWidgetTrailer:isShowEffect(boo)
	self._ccbOwner.node_effect:removeAllChildren()
	if not boo then return end
	local ccbFile = "effects/tx_ygiconglow_effect.ccbi"
	local effect = QUIWidget.new(ccbFile)
	self._ccbOwner.node_effect:addChild(effect)
end

return QUIWidgetTrailer