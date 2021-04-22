-- @Author: liaoxianbo
-- @Date:   2020-08-10 11:16:34
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-08-12 19:56:01

local QBattleDialogBaseFightEnd = import(".QBattleDialogBaseFightEnd")
local QMazeExploreDialogWin = class(".QMazeExploreDialogWin", QBattleDialogBaseFightEnd)

local QStaticDatabase = import(".....controllers.QStaticDatabase")
local QUIWidgetItemsBox = import("....widgets.QUIWidgetItemsBox")
local QUIWidgetHeroHead = import("....widgets.QUIWidgetHeroHead")
local QTextFiledScrollUtils = import(".....utils.QTextFiledScrollUtils")
local QUIWidgetAnimationPlayer = import("....widgets.QUIWidgetAnimationPlayer")


function QMazeExploreDialogWin:ctor(options, owner)
	print("<<<QMazeExploreDialogWin>>>")
	--设置该节点启用enter事件
	self:setNodeEventEnabled(true)
	QMazeExploreDialogWin.super.ctor(self, options, owner)
	self._audioHandler = app.sound:playSound("battle_complete")
	
	local isWin = options.isWin
	self._proxyClass = remote.activityRounds:getMazeExplore()
	if isWin then
		local addScore = options.addScore
		local dungeonId = options.dungeonId
		local passTime = options.passTime
		local awardsTbl = options.awardsTbl or {}
		local exp = options.exp
		local star = options.star or 0
		self._schedulerHandlers = {}
		self._ccbOwner.node_bg_win:setVisible(true)

	    self._ccbOwner.node_win_client:setVisible(true)
	    -- self._ccbOwner.node_win_text_title:setVisible(true)
	    -- self:setWinTextTitle({"zhan", "dou", "jie", "shu"})

		local tips = "怪物已被击杀"
    	self._ccbOwner.tf_win_title:setString(tips)


		self._ccbOwner.node_win_star_title:setVisible(true)
		local handler = scheduler.performWithDelayGlobal(function()
			app.sound:preloadSound("common_star")
			local common_star_hdl = nil
			local additional_latency = (device.platform == "android") and 0.23 or 0
			for i=1, 3, 1 do
				if i <= star then
					self._ccbOwner["sp_star_done_"..i]:setVisible(true)
					if i == 1 then
						common_star_hdl = app.sound:playSound("common_star")
					else
						local timeHandler = scheduler.performWithDelayGlobal(function ()
								if common_star_hdl then
									app.sound:stopSound(common_star_hdl)
								end
								common_star_hdl = app.sound:playSound("common_star")
							end, additional_latency + 0.60 * ( i - 1 ))
						self._schedulerHandlers[timeHandler] = timeHandler
					end
				else
					self._ccbOwner["sp_star_done_"..i]:setVisible(false)
				end
			end
		end, 20/30)
		self._schedulerHandlers[handler] = handler

		if star == 3 then
			local titleStr = self._proxyClass:getMazeExploreFightDesByStar(3)
			self._ccbOwner.tf_win_title:setString("三星（"..titleStr.."）")
		elseif star == 2 then
			local titleStr = self._proxyClass:getMazeExploreFightDesByStar(2)
			self._ccbOwner.tf_win_title:setString("二星（"..titleStr.."）")
		else
			local titleStr = self._proxyClass:getMazeExploreFightDesByStar(1)
			self._ccbOwner.tf_win_title:setString("一星（"..titleStr.."）")
		end


		-- 打三星的时候，相应的震动
	    if self._donotShakeScreen == false then
	    	if star == 3 then
				scheduler.performWithDelayGlobal(function()
					q.shakeScreen(8, 0.1)
				end, 20/30)
				scheduler.performWithDelayGlobal(function()
					q.shakeScreen(8, 0.1)
				end, 35/30)
				scheduler.performWithDelayGlobal(function()
					q.shakeScreen(8, 0.1)
				end, 51/30)
			elseif star == 2 then
				scheduler.performWithDelayGlobal(function()
					q.shakeScreen(8, 0.1)
				end, 20/30)
				scheduler.performWithDelayGlobal(function()
					q.shakeScreen(8, 0.1)
				end, 35/30)
			elseif star == 1 then
				scheduler.performWithDelayGlobal(function()
					q.shakeScreen(8, 0.1)
				end, 20/30)
			end
	    end

	    -- hero head
		-- self._ccbOwner.ly_hero_head_size:setVisible(false)
		self._ccbOwner.node_hero_head:setVisible(true)
		self:setHeroInfo(exp)
	   	-- hero head 中心对齐
	    local teamHero = remote.teamManager:getActorIdsByKey(self.teamName, 1)
	    local heroHeadCount = #teamHero
		if heroHeadCount > 0 then
			local heroTotalWidth = self.heroHeadWidth * (heroHeadCount - 1) + (self.heroBox[1]:getSize().width * 1.5)
			self._ccbOwner.node_hero_head:setPositionX( self._ccbOwner.node_hero_head:getPositionX() + (self._ccbOwner.ly_hero_head_size:getContentSize().width - heroTotalWidth) / 2 )
		end
		-- award title
		self._ccbOwner.tf_award_title:setString("战斗奖励")
    	self._ccbOwner.node_award_title:setVisible(true)
    	-- award normal
    	self._ccbOwner.node_award_normal:setVisible(true)
		self._ccbOwner.node_award_normal_client:setVisible(true)
		local itemsBox = {}
	 	local boxWidth = 0
	 	local betAwardCountList = {}
	    local i = 1
	    local awards = {}
		for _, value in pairs(awardsTbl) do
			local node = self._ccbOwner["node_award_normal_item_"..i]
			if node then
				if value.type ~= ITEM_TYPE.TEAM_EXP and value.type ~= ITEM_TYPE.MONEY and value.type ~= "TOKEN" then
					itemsBox[i] = QUIWidgetItemsBox.new()
			    	itemsBox[i]:setVisible(false)
			    	itemsBox[i]:setPromptIsOpen(true)
			    	itemsBox[i]:resetAll()
			    	betAwardCountList[i] = math.ceil(value.count)
					self:setBoxInfo(itemsBox[i], value.id, value.type, betAwardCountList[i])
					if boxWidth == 0 then
			    		boxWidth = itemsBox[i]:getContentSize().width
			    	end
					node:addChild(itemsBox[i])
					i = i + 1
				end
			else
				break
			end
		end
		local awardsNum = i - 1
		if addScore ~= nil and addScore > 0 then
			awardsNum = awardsNum + 1
			local item = QUIWidgetItemsBox.new()
			if self._ccbOwner["node_award_normal_item_"..awardsNum] ~= nil then
				self._ccbOwner["node_award_normal_item_"..awardsNum]:addChild(item)
			end
			item:setColor("orange")
	        item:setPromptIsOpen(true)
			item:setGoodsInfo(nil, ITEM_TYPE.MAZE_EXPLORE_MEROY, addScore)
		end

		-- award normal 中心对齐
		if awardsNum > 0 then
			local posX = self._ccbOwner.node_award_normal_client:getPositionX() + 10
			self._ccbOwner.node_award_normal_client:setPositionX(posX + ((6 - awardsNum) * 79 / 2))
		end

		local maxBetAwardCountIndex = table.nums(betAwardCountList)


	else
		makeNodeFromNormalToGray(self._ccbOwner.node_bg_mvp)

		self._ccbOwner.node_bg_lost:setVisible(true)
		self._ccbOwner.node_lost_client:setVisible(true)

		self:hideAllPic()
		if not (FinalSDK.isHXShenhe()) then
			self:chooseBestGuide()
		end
	end
end

function QMazeExploreDialogWin:onEnter()
    self.prompt = app:promptTips()
    self.prompt:addItemEventListener(self)
end

function QMazeExploreDialogWin:onExit()
   	if self.prompt ~= nil then
   		self.prompt:removeItemEventListener()
   	end
   	if self._updateScheduler ~= nil then
		scheduler.unscheduleGlobal(self._updateScheduler)
		self._updateScheduler = nil
   	end
   	if self._schedulerHandlers ~= nil then
	   	for _,v in pairs(self._schedulerHandlers) do
	   		scheduler.unscheduleGlobal(v)
	   	end
   	end
   	   	
end

function QMazeExploreDialogWin:_onTriggerNext()
  	app.sound:playSound("common_item")
  	self:_onClose()
end

return QMazeExploreDialogWin