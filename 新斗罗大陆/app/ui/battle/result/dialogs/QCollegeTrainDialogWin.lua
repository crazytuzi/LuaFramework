-- @Author: liaoxianbo
-- @Date:   2019-11-25 17:17:50
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-12-13 18:58:41

local QBattleDialogBaseFightEnd = import(".QBattleDialogBaseFightEnd")
local QCollegeTrainDialogWin = class("QCollegeTrainDialogWin", QBattleDialogBaseFightEnd)

local QStaticDatabase = import(".....controllers.QStaticDatabase")
local QUIViewController = import("....QUIViewController")

local QUIWidgetItemsBox = import("....widgets.QUIWidgetItemsBox")
local QUIWidgetBattleWinHeroHead = import("....widgets.QUIWidgetBattleWinHeroHead")

function QCollegeTrainDialogWin:ctor(options,owner)
	print("<<<QCollegeTrainDialogWin>>>")
	--设置该节点启用enter事件
	self:setNodeEventEnabled(true)
	local isWin = options.isWin
	options.isCollegeTrain = true
	QCollegeTrainDialogWin.super.ctor(self,options,owner)
	
	-- {info=info, awards = awards, score = score, isWin = self._isWin}
	if isWin then
		local awards = options.awards
		local chapterId = options.chapterId
		local herosList = options.info.heros
		self._ccbOwner.node_bg_win:setVisible(true)

	    self._ccbOwner.node_win_client:setVisible(true)

	    self._ccbOwner.node_win_text_title:setVisible(true)
	    -- self:setWinTextTitle({"zhan", "dou", "sheng", "li"})
	    self._ccbOwner.sp_li:setVisible(true)
	    self._ccbOwner.sp_zdsb:setVisible(false)

		self._ccbOwner.node_hero_head:setVisible(false)
		
    	self._ccbOwner.tf_collegeTrain_tips:setVisible(true)
    	self._ccbOwner.tf_collegeTrain_tips:setString("有的时候，天才与庸才的区别，就在于意志力是否坚定。挺过一次极限，就意味着一切都会改变。")
    	
		local itemsBox = {}
	 	local boxWidth = 0

		local totalCount = 0
		if next(awards) ~= nil then
			for index,award in ipairs(awards) do
				local item = QUIWidgetItemsBox.new()
		        item:setPromptIsOpen(true)
				item:setGoodsInfo(tonumber(award.id), award.type, tonumber(award.count))
				if self._ccbOwner["node_award_normal_item_"..index] ~= nil then
					self._ccbOwner["node_award_normal_item_"..index]:addChild(item)
				end
			end
			totalCount = #awards
		end
		-- award normal 中心对齐
		local awardsNum = totalCount
		if awardsNum > 0 then
			local posX = self._ccbOwner.node_award_normal_client:getPositionX() + 10
			self._ccbOwner.node_award_normal_client:setPositionX(posX + ((6 - awardsNum) * 79 / 2))

			-- award title
			self._ccbOwner.tf_award_title:setString("首通奖励")
	    	self._ccbOwner.node_award_title:setVisible(true)
	    	-- award normal
			self._ccbOwner.node_award_normal:setVisible(true)
			self._ccbOwner.node_award_normal_client:setVisible(true)	
		else
			self._ccbOwner.tf_collegeTrain_tips:setPositionY(0)    				
		end
	else
		makeNodeFromNormalToGray(self._ccbOwner.node_bg_mvp)

		self._ccbOwner.sp_zhanli_tisheng:setVisible(false)
		self._ccbOwner.sp_shibaiTips:setVisible(false)
		self._ccbOwner.node_bg_lost:setVisible(false)
		self._ccbOwner.node_lost_client:setVisible(false)
		self._ccbOwner.btn_stronger:setVisible(false)

		self._ccbOwner.tf_collegeTrain_tips:setString("有的时候，天才与庸才的区别，就在于意志力是否坚定。挺过一次极限，就意味着一切都会改变。")

		self:hideAllPic()
	end

end

function QCollegeTrainDialogWin:onEnter()
    self.prompt = app:promptTips()
    self.prompt:addItemEventListener(self)
end

function QCollegeTrainDialogWin:onExit()
   	if self.prompt ~= nil then
   		self.prompt:removeItemEventListener()
   	end
   	
    if self._yieldScheduler ~= nil then
    	scheduler.unscheduleGlobal(self._yieldScheduler)
    	self._yieldScheduler = nil
    end   	
end

function QCollegeTrainDialogWin:_onTriggerNext()
  	app.sound:playSound("common_item")
	self:_onClose()
end

return QCollegeTrainDialogWin