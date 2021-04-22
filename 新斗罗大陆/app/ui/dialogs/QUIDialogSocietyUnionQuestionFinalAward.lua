local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSocietyUnionQuestionFinalAward = class("QUIDialogSocietyUnionQuestionFinalAward", QUIDialog)
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetSocirtyUnionQuestion = import("..widgets.question.QUIWidgetSocirtyUnionQuestion")
local QUIViewController = import("...ui.QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIDialogSocietyUnionQuestionFinalAward:ctor(options)
	local ccbFile = "ccb/Dialog_wenjuandati_jiangli.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose",callback = handler(self, QUIDialogSocietyUnionQuestionFinalAward._backClickHandler)},
	}
	QUIDialogSocietyUnionQuestionFinalAward.super.ctor(self,ccbFile,callBacks,options)
	self._ccbOwner.node_item1:setVisible(true)
	self._ccbOwner.node_item1Sprite:setVisible(false)
	self._ccbOwner.node_item2:setVisible(false)
	self._ccbOwner.node_sp:setVisible(false)

	self:setInfo(options.correctCount, options.awards, options.multipleCount)
end

function QUIDialogSocietyUnionQuestionFinalAward:setInfo(rightCount, awardString, multipleCount)
	local config = QStaticDatabase:sharedDatabase():getConfiguration()
	local topWords = nil
	if tonumber(rightCount) then
		local rightCountTemp = tonumber(rightCount)
		if rightCountTemp == 1 or rightCountTemp == 2 then
			topWords = config.GHDT_WORD_1.value
		elseif rightCountTemp == 3 or rightCountTemp == 4 then
			topWords = config.GHDT_WORD_2.value
		elseif rightCountTemp == 5 then
			topWords = config.GHDT_WORD_3.value
		else
			topWords = config.GHDT_WORD_2.value
		end
	end
	self._ccbOwner.TitleLabel:setString(topWords)

	if tonumber(multipleCount) then
		local doubleCountTemp = tonumber(multipleCount)
		if doubleCountTemp > 1 then
			local buttomWords = "人品爆发，触发了"..doubleCountTemp.."倍暴击奖励"
			self._ccbOwner.ButtomLable:setString(buttomWords)
			self._ccbOwner.lable_baoji1:setZOrder(2)
			self._ccbOwner.discountStr1:setZOrder(2)
			self._ccbOwner.discountStr_not:setZOrder(2)
			self._ccbOwner.discountStr1:setString("x"..doubleCountTemp)
			self._ccbOwner.lable_baoji2:setZOrder(2)
			self._ccbOwner.discountStr2:setZOrder(2)
			self._ccbOwner.discountStr_not2:setZOrder(2)
			self._ccbOwner.discountStr2:setString("x"..doubleCountTemp)
		else
			local buttomWords = "奖励已放入您的背包"
			self._ccbOwner.ButtomLable:setString(buttomWords)
			self._ccbOwner.ButtomLable:setVisible(true)
			self._ccbOwner.lable_baoji1:setVisible(false)
			self._ccbOwner.discountStr_not:setVisible(false)
			self._ccbOwner.discountStr1:setVisible(false)
			self._ccbOwner.lable_baoji2:setVisible(false)
			self._ccbOwner.discountStr2:setVisible(false)
			self._ccbOwner.discountStr_not2:setVisible(false)
		end
	end

	local awards = {}
	if awardString == "timeout" then
		local awardStringTemp = QStaticDatabase:sharedDatabase():getConfiguration().GHDT_REWARD_GOLD.value
		awards = string.split(awardStringTemp, ";")
	else
		awards = string.split(awardString, ";")
	end
	self._itemBoxNowAwards = {}
	local index = 0
	for _,value in ipairs(awards) do
		if value == "" then
			break
		end
		local awardCell = string.split(value, "^")
		local item = awardCell[1]
		local count = tonumber(awardCell[2]) or 0
		local itemType = nil
		if tonumber(item) then
			itemType = ITEM_TYPE.ITEM
		else
			itemType = item
		end

		local itemBox = QUIWidgetItemsBox.new()
		if awardString == "timeout" then
			itemBox:setGoodsInfo(item, itemType, count*rightCount)
		else
			itemBox:setGoodsInfo(item, itemType, count)
		end
		itemBox:setPositionX(index * 103)
		index = index + 1
		if self._itemBoxNowAwards and self._itemBoxNowAwards[index] then
			self._itemBoxNowAwards[index]:removeFromParent()
		end
		self._itemBoxNowAwards[index] = itemBox
		self._ccbOwner.node_item1:addChild(self._itemBoxNowAwards[index])
	end
end

function QUIDialogSocietyUnionQuestionFinalAward:_backClickHandler()
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

return QUIDialogSocietyUnionQuestionFinalAward