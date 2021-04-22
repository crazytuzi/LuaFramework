--
-- Author: Your Name
-- Date: 2014-05-19 10:58:04
--
local QBattleDialogBaseFightEnd = import(".QBattleDialogBaseFightEnd")
local QBlackRockDialogWin = class("QBlackRockDialogWin", QBattleDialogBaseFightEnd)

local QStaticDatabase = import(".....controllers.QStaticDatabase")
local QUIViewController = import("....QUIViewController")

local QUIWidgetItemsBox = import("....widgets.QUIWidgetItemsBox")

function QBlackRockDialogWin:ctor(options,owner)
	print("<<<QBlackRockDialogWin>>>")
	--设置该节点启用enter事件
	self:setNodeEventEnabled(true)
	options.dialogType = "blackRock"
	QBlackRockDialogWin.super.ctor(self,options,owner)
	
	-- {info=info, awards = awards, score = score, isWin = self._isWin}
	local isWin = options.isWin
	if isWin then
		local exp = options.exp or 0
		local score = options.score
		local money = options.money
		local awards = options.awards
		local yield = options.yield
		local activityYield = options.activityYield
		local herosList = options.info.heros
		self._ccbOwner.node_bg_win:setVisible(true)

	    self._ccbOwner.node_win_client:setVisible(true)

	    self._ccbOwner.node_win_text_title:setVisible(true)
	    self:setWinTextTitle({"zhan", "dou", "sheng", "li"})

		self._ccbOwner.node_hero_head:setVisible(true)
	   	self:setHeroInfo(exp)
	   	
	   	local teams = remote.teamManager:getActorIdsByKey(self.teamName, index) 
	   	local heroHeadCount = #teams or 0
		if heroHeadCount > 0 then
			local heroTotalWidth = self.heroHeadWidth * (heroHeadCount - 1) + (self.heroBox[1]:getSize().width * 1.5)
			self._ccbOwner.node_hero_head:setPositionX( self._ccbOwner.node_hero_head:getPositionX() + (self._ccbOwner.ly_hero_head_size:getContentSize().width - heroTotalWidth) / 2 )
		end
		-- award title
		self._ccbOwner.tf_award_title:setString("战斗奖励")
    	self._ccbOwner.node_award_title:setVisible(true)
    	self._ccbOwner.node_no_tips:setVisible(true)
    	-- award normal
    	self._ccbOwner.node_award_normal:setVisible(true)
		self._ccbOwner.node_award_normal_client:setVisible(true)
		local itemsBox = {}
	 	local boxWidth = 0

		local totalCount = 0
		if next(awards) ~= nil then
			for index,award in ipairs(awards) do
				local item = QUIWidgetItemsBox.new()
		        item:setPromptIsOpen(true)
				item:setGoodsInfo(award.id, award.typeName, award.count)
				if self._ccbOwner["node_award_normal_item_"..index] ~= nil then
					self._ccbOwner["node_award_normal_item_"..index]:addChild(item)
				end
			end
			totalCount = #awards
			if score ~= nil and score > 0 then
				totalCount = totalCount + 1
				local item = QUIWidgetItemsBox.new()
				if self._ccbOwner["node_award_normal_item_"..totalCount] ~= nil then
					self._ccbOwner["node_award_normal_item_"..totalCount]:addChild(item)
				end
				item:setColor("orange")
		        item:setPromptIsOpen(true)
				item:setGoodsInfo(nil, ITEM_TYPE.BLACKROCK_INTEGRAL, score)
			end
		end
		-- award normal 中心对齐
		local awardsNum = totalCount
		if awardsNum > 0 then
			local posX = self._ccbOwner.node_award_normal_client:getPositionX() + 10
			self._ccbOwner.node_award_normal_client:setPositionX(posX + ((6 - awardsNum) * 79 / 2))
		end
	else
		makeNodeFromNormalToGray(self._ccbOwner.node_bg_mvp)

		self._ccbOwner.node_bg_lost:setVisible(true)
		self._ccbOwner.node_lost_client:setVisible(true)

		self:hideAllPic()
		self:chooseBestGuide()
	end

end

function QBlackRockDialogWin:onEnter()
    self.prompt = app:promptTips()
    self.prompt:addItemEventListener(self)
end

function QBlackRockDialogWin:onExit()
   	if self.prompt ~= nil then
   		self.prompt:removeItemEventListener()
   	end
   	
    if self._yieldScheduler ~= nil then
    	scheduler.unscheduleGlobal(self._yieldScheduler)
    	self._yieldScheduler = nil
    end   	
end

-- function QBlackRockDialogWin:_backClickHandler()
-- 	if q.time() - self._openTime > 3.5 then
-- 		self._ccbOwner:onChoose()
--   	end
-- end

function QBlackRockDialogWin:_onTriggerNext()
  	app.sound:playSound("common_item")
	self:_onClose()
end

-- function QBlackRockDialogWin:onClose()
-- 	self._ccbOwner:onChoose()
-- 	if self._audioHandler ~= nil then
-- 		audio.stopSound(self._audioHandler)
-- 	end
-- end

return QBlackRockDialogWin