--
-- Kumo.Wang
-- 圣柱跳关奖励弹脸
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogTotemChallengeSkipAward = class("QUIDialogTotemChallengeSkipAward", QUIDialog)

local QRichText = import("...utils.QRichText")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIDialogTotemChallengeSkipAward:ctor(options) 
 	local ccbFile = "ccb/Dialog_totemChallenge_skip_award.ccbi"
	local callBacks = {}
	QUIDialogTotemChallengeSkipAward.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true

	if options then
		self._callback = options.callback
		self._awards = options.awards or {}
		self._text = options.text
	end

	self._ccbOwner.tf_txt:setString(self._text)

	local itemBoxs = {}
	local index = 1
	local width = 0
	local gap = 30
	local contentSize
	for _, award in pairs(self._awards) do
		itemBoxs[index] = QUIWidgetItemsBox.new()
		if award.id then
			itemBoxs[index]:setGoodsInfo(tonumber(award.id), award.typeName, tonumber(award.count))
		else
			itemBoxs[index]:setGoodsInfo(nil, award.typeName, tonumber(award.count))
		end
		itemBoxs[index]:setPromptIsOpen(true)
		-- itemBoxs[index]:showEffect()
		self._ccbOwner.node_item:addChild( itemBoxs[index] )

		contentSize = itemBoxs[index]:getContentSize()
		itemBoxs[index]:setPositionX(width)
		width = width + contentSize.width + gap
		index = index + 1
	end
	
	local posX = self._ccbOwner.node_item:getPositionX()
	self._ccbOwner.node_item:setPositionX(posX - width/2 + (contentSize.width + gap)/2)
end

function QUIDialogTotemChallengeSkipAward:setDesc(desc)
	self._ccbOwner.tf_txt:setString(desc)
end

function QUIDialogTotemChallengeSkipAward:_backClickHandler()
	self:playEffectOut()
end

function QUIDialogTotemChallengeSkipAward:viewAnimationOutHandler()
	self:popSelf()

	if self._callback then
		self._callback()
	end
end

return QUIDialogTotemChallengeSkipAward