--
-- Author: Kumo.Wang
-- 图鉴列表cell
--

local QUIWidget = import(".QUIWidget")
local QUIWidgetHandBookBBSCell = class("QUIWidgetHandBookBBSCell", QUIWidget)

function QUIWidgetHandBookBBSCell:ctor(options)
	local ccbFile = "ccb/Widget_HandBook_BBSCell.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerAdmire", callback = handler(self, self._onTriggerAdmire)},
		{ccbCallbackName = "onTriggerRefresh", callback = handler(self, self._onTriggerRefresh)},
		{ccbCallbackName = "onTriggerTop", callback = handler(self, self._onTriggerTop)},
	}
	QUIWidgetHandBookBBSCell.super.ctor(self,ccbFile,callBacks,options)
end

function QUIWidgetHandBookBBSCell:onEnter()
end

function QUIWidgetHandBookBBSCell:onExit()
end

function QUIWidgetHandBookBBSCell:refreshAdmireInfo()
	if self._info.isBtnView then return end

	local actor_id = self._info.actor_id
	local comment_id = self._info.comment_id
	local info = remote.handBook:getCommentInfoByActorIDAndCommentID(actor_id, comment_id)
	-- QPrintTable(info)
	self._info = info
	self:_setAdmireInfo()
end

function QUIWidgetHandBookBBSCell:setInfo(info, index)
	self._info = info
	self._index = index or 0

	self._ccbOwner.node_line:setVisible(self._index > 1)

	if self._info.isBtnView then
		self._ccbOwner.node_btn:setVisible(true)
		self._ccbOwner.node_bbs:setVisible(false)

	else
		self._ccbOwner.node_btn:setVisible(false)
		self._ccbOwner.node_bbs:setVisible(true)

		self._ccbOwner.tf_name:setString(self._info.nickname.."("..self._info.game_area..")")
		self._ccbOwner.tf_output:setString(self._info.content)

		self:_setAdmireInfo()
	end
end

function QUIWidgetHandBookBBSCell:_setAdmireInfo()
	self._ccbOwner.tf_admire_count:setString(self._info.sum_count)
	self._ccbOwner.sp_admire_on:setVisible(self._info.isAdmire)
	self._ccbOwner.sp_admire_off:setVisible(not self._info.isAdmire)
end

function QUIWidgetHandBookBBSCell:getContentSize()
	if self._info.isBtnView then
		self._ccbOwner.node_size:getContentSize().height = 125
	else
		local posY = self._ccbOwner.tf_output:getPositionY()
		local height = self._ccbOwner.tf_output:getContentSize().height
		local tmpHeight = posY + height
		if tmpHeight > self._ccbOwner.node_size:getContentSize().height then
			self._ccbOwner.node_size:getContentSize().height = tmpHeight
		end
	end

	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetHandBookBBSCell:_onTriggerAdmire()
end
function QUIWidgetHandBookBBSCell:_onTriggerRefresh()
end
function QUIWidgetHandBookBBSCell:_onTriggerTop()
end
return QUIWidgetHandBookBBSCell
