local QUIWidget = import("..QUIWidget")
local QUIWidgetBaseMyRank = class("QUIWidgetBaseMyRank", QUIWidget)

local QUIViewController = import("...QUIViewController")

QUIWidgetBaseMyRank.BIG_SIZE = CCSize(726, 106)
QUIWidgetBaseMyRank.NORMAL_SIZE = CCSize(726, 106)

function QUIWidgetBaseMyRank:ctor(options)
	local ccbFile = "ccb/Widget_ArenaRank_MyBase.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerAward", callback = handler(self, self._onTriggerAward)},
	}
	QUIWidgetBaseMyRank.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._ccbOwner.node_rank_award:setVisible(false)

	if options then
		self._config = options.config
	end
end

function QUIWidgetBaseMyRank:setInfo(info)
end

function QUIWidgetBaseMyRank:setStyle(style)
	if self._style ~= nil then
		self._style:removeFromParent()
		self._style = nil
	end
	self._style = style
	self._ccbOwner.node_content:addChild(self._style)
end

function QUIWidgetBaseMyRank:getStyle()
	return self._style
end

function QUIWidgetBaseMyRank:setRank(rank, lastRank)
	self._ccbOwner.tf_myRank:setVisible(false)
	self._ccbOwner.tf_noRank:setVisible(false)
	if rank ~= nil then
		self._ccbOwner.tf_myRank:setString(rank)
		self._ccbOwner.tf_myRank:setVisible(true)
	else
		self._ccbOwner.tf_noRank:setVisible(true)
	end
	self._ccbOwner.node_lastRank:setVisible(lastRank ~= nil)
	self._ccbOwner.yesterday:setVisible(false)
	self._ccbOwner.green_flag:setVisible(false)
	self._ccbOwner.red_flag:setVisible(false)
	local rankChanged = 0
	if lastRank and rank then rankChanged = lastRank - rank end
	self._ccbOwner.yesterday:setVisible(rankChanged ~= 0)
	if rankChanged > 0 then
		self._ccbOwner.green_flag:setVisible(true)
		self._ccbOwner.green_rankChanged:setVisible(true)
		self._ccbOwner.green_rankChanged:setString(tostring(math.abs(rankChanged)))
	elseif rankChanged < 0 then
		self._ccbOwner.red_flag:setVisible(true)
		self._ccbOwner.red_rankChanged:setVisible(true)
		self._ccbOwner.red_rankChanged:setString(tostring(math.abs(rankChanged)))
	else
		self._ccbOwner.node_content:setPositionX(-50)
	end
end

function QUIWidgetBaseMyRank:showAwardButton()
	self._ccbOwner.node_rank_award:setVisible(false)
	if self._config.awardType and remote.rank:checkAwardIsOpen() then
		self._ccbOwner.node_rank_award:setVisible(true)
	end

	self._ccbOwner.sp_award_tips:setVisible(remote.rank:checkAwardTipByType(self._config.awardType))
end

function QUIWidgetBaseMyRank:_onTriggerAward(event)
	if q.buttonEventShadow(event, self._ccbOwner.sp_rank_award) == false then return end

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRankAward", 
    	options = {config = self._config}}, {isPopCurrentDialog = false})
end

function QUIWidgetBaseMyRank:getContentSize()
	return self._ccbOwner.sp_bg:getContentSize()
end
return QUIWidgetBaseMyRank