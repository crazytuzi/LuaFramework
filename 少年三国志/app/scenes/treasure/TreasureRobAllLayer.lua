local TreasureRobAllLayer = class("TreasureRobAllLayer", UFCCSNormalLayer)

require("app.cfg.treasure_compose_info")
local TreasureConst = require("app.const.TreasureConst")
local ItemConst = require("app.const.ItemConst")
local RobCell = require("app.scenes.treasure.TreasureRobAllCell")

local ROB_INTERVAL = 0.01 -- 每0.01秒夺一次

function TreasureRobAllLayer.create(treasureID, autoUseEnergy)
	local layer = TreasureRobAllLayer.new("ui_layout/treasure_TreasureRobAllLayer.json", treasureID, autoUseEnergy)
	return layer
end

function TreasureRobAllLayer:ctor(json, treasureID, autoUseEnergy)
	self._treasureID 		= treasureID
	self._autoUseEnergy 	= autoUseEnergy
	self._curRobFragment	= 0		-- 当前正在夺的碎片ID
	self._robCount			= 0		-- 总共抢夺的次数
	self._robStopped 		= false	-- 是否人为停止了夺宝
	self._needFragmentList 	= {} 	-- 合成该宝物的所有碎片ID和当前数量table
	self._scrollCellList	= {}	-- 抢夺战报cell table
	self._scrollTotalHeight	= 0		-- 滑动区域的总长度
	self._scrollView		= nil

	self._upgradeList		= {} 	-- 夺宝途中有可能升级，用于存储临时升级数据

	-- initialize the number of fragments we need
	self:_initData()

	self.super.ctor(self)
end

function TreasureRobAllLayer:onLayerLoad()
	self._scrollView = self:getScrollViewByName("ScrollView_RobReport")
	self._scrollView:setScrollEnable(false)

	-- initialize original spirit info
	self:enableLabelStroke("Label_RemainSprit", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_SpiritNum", Colors.strokeBrown, 1)

	self:_updateSpiritNum()

	-- register button events
	self:registerBtnClickEvent("Button_StopRob", handler(self, self._onClickStopRob))
	self:registerBtnClickEvent("Button_RobFinish", handler(self, self.onBackKeyEvent))
	self:registerBtnClickEvent("Button_Back", handler(self, self.onBackKeyEvent))
end

function TreasureRobAllLayer:onLayerEnter()
	self:registerKeypadEvent(true)

	-- initialize the size and position of the scroll view
	self:adapterWidgetHeight("Image_ScrollBg", "Image_TitleBg", "Panel_SpiritInfo", 10, 10)
	local scrollBg = self:getImageViewByName("Image_ScrollBg")
	local bgHeight = scrollBg:getSize().height
	local initHeight = bgHeight * 0.9
	local initY = -initHeight * 0.5
	local oldSize = self._scrollView:getSize()

	self._scrollView:setPositionY(initY)
	self._scrollView:setSize(CCSize(oldSize.width, initHeight))
	self._scrollView:setInnerContainerSize(CCSize(oldSize.width, initHeight))

	-- register event listener
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TREASURE_ONE_KEY_ROB, self._onRcvOneKeyRob, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVNET_BAG_USE_ITEM, self._onRcvUseSpirit, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_USER_LEVELUP, self._onRcvLevelUpdate, self)

	-- rob next fragment
	self:_robNextFragment()
end

function TreasureRobAllLayer:onLayerExit()
	self:stopAllActions()
	uf_eventManager:removeListenerWithTarget(self)
end

function TreasureRobAllLayer:_initData()
	-- traverse the compose info, and get the fragment IDs and their current number
	local composeInfo = treasure_compose_info.get(self._treasureID)
	for i = 1, TreasureConst.COMPOSE_FRAGMENT_MAX_TYPES do
		local fragmentID = composeInfo[TreasureConst.COMPOSE_FRAGMENT_ID_PREFIX .. i]
		if fragmentID ~= 0 then
			local fragmentNum = G_Me.bagData:getTreasureFragmentNumById(fragmentID)
			self._needFragmentList[fragmentID] = fragmentNum or 0
		end
	end
end

function TreasureRobAllLayer:_updateSpiritNum()
	local spiritNum = G_Me.bagData:getItemCount(ItemConst.ITEM_ID.JING_LI_DAN)
	self:showTextWithLabel("Label_SpiritNum", tostring(spiritNum))
end

-- @param data: passed in from the protocol ACK package
function TreasureRobAllLayer:_addRobReport(type, data)
	-- create a cell and attach it to the scroll view
	local cellIndex = #self._scrollCellList + 1
	local newCell = RobCell.new(type, self._treasureID, self._curRobFragment, self._robCount, data)
	self._scrollCellList[cellIndex] = newCell
	self._scrollView:getInnerContainer():addChild(newCell)

	-- if the scroll height is not enough, then extend it
	local curScrollSize = self._scrollView:getInnerContainerSize()
	local cellHeight = newCell:getRealHeight()
	self._scrollTotalHeight = self._scrollTotalHeight + cellHeight + RobCell.GAP * (cellIndex > 1 and 1 or 0)

	local viewExtended = false
	if self._scrollTotalHeight > curScrollSize.height then
		viewExtended = true
		self._scrollView:setInnerContainerSize(CCSize(curScrollSize.width, self._scrollTotalHeight))
	end

	-- adjust the position of the cells
	if viewExtended then
		local curY = self._scrollTotalHeight
		for i, v in ipairs(self._scrollCellList) do
			local cellHeight = v:getRealHeight()
			local y = curY - cellHeight - RobCell.GAP * (i > 1 and 1 or 0)
			v:setPositionY(y)
			curY = y
		end

		self._scrollView:jumpToBottom()
	else
		local y = curScrollSize.height - self._scrollTotalHeight
		newCell:setPositionY(y)
	end
end

function TreasureRobAllLayer:_isAllFragmentsRobbed()
	for k, v in pairs(self._needFragmentList) do
		if v == 0 then
			return false
		end
	end

	return true
end

function TreasureRobAllLayer:_robNextFragment()
	if self._robStopped then 
		return
	end

	-- check if spirit is enough
	if G_Me.userData.spirit >= TreasureConst.SPIRITS_COST_PER_ROB then
		-- spirit enough, rob
		for fragmentID, fragmentNum in pairs(self._needFragmentList) do
			if fragmentNum == 0 then
				self._curRobFragment = fragmentID
				G_HandlersManager.treasureRobHandler:sendOneKeyRob(fragmentID)
				break
			end
		end
	elseif self._autoUseEnergy and G_Me.bagData:getItemCount(ItemConst.ITEM_ID.JING_LI_DAN) > 0 then
		-- spirit not enough, but the player agreed to use spirit item automatically
		G_HandlersManager.bagHandler:sendUseItemInfo(ItemConst.ITEM_ID.JING_LI_DAN, nil, 1)
	else
		self:_addRobReport(RobCell.LACK_SPIRIT)
		self:_robFinished()
	end
end

function TreasureRobAllLayer:_onRcvOneKeyRob(data)
	-- increase rob count
	self._robCount = self._robCount + 1

	-- attach a rob-result cell
	self:_addRobReport(RobCell.ROB_DETAIL, data)

	if data.rob_result == true then
		self._needFragmentList[self._curRobFragment] = 1
	end

	-- if we get a fragment as an extra reward, check if this fragment is what we need
	local extraReward = rawget(data, "turnover_reward")
	if extraReward and extraReward.type == G_Goods.TYPE_TREASURE_FRAGMENT then
		local fragID = extraReward.value
		if self._needFragmentList[fragID] then
			self._needFragmentList[fragID] = self._needFragmentList[fragID] + 1
		end
	end

	-- check if all fragments have been got
	local gotAllFragments = self:_isAllFragmentsRobbed()
	if gotAllFragments then
		-- if all fragments have been got，attach "rob finished" hint and finish
		self:_addRobReport(RobCell.ROB_FINISH)
		self:_robFinished()
	else
		-- wait a moment and rob next fragment
		uf_funcCallHelper:callAfterDelayTimeOnObj(self, ROB_INTERVAL, nil, handler(self, self._robNextFragment))
	end
end

function TreasureRobAllLayer:_onRcvUseSpirit(data)
	local usedItemID = rawget(data, "id")
	if usedItemID == ItemConst.ITEM_ID.JING_LI_DAN then
		self:_addRobReport(RobCell.USE_SPIRIT)
		self:_updateSpiritNum()
		self:_robNextFragment()
	else
		self:_robFinished()
	end
end

function TreasureRobAllLayer:_onRcvLevelUpdate(oldLevel, newLevel)
	if type(oldLevel) ~= "number" or type(newLevel) ~= "number" then 
        return 
    end

    self._upgradeList = self._upgradeList or {}
    table.insert(self._upgradeList, 1, {level1 = oldLevel, level2 = newLevel})
end

function TreasureRobAllLayer:_robFinished()
	-- show the "rob finished" button and hide the "stop rob" button
	self:showWidgetByName("Button_RobFinish", true)
	self:showWidgetByName("Button_StopRob", false)
	self._scrollView:setScrollEnable(true)
end

function TreasureRobAllLayer:_checkLevelUp()
	if not self._upgradeList or #self._upgradeList < 1 then 
        return 
    end

    local upgradePair = self._upgradeList[1]
    if type(upgradePair) == "table" then 
    	uf_funcCallHelper:callAfterFrameCount(2, function ( ... )
    		require("app.scenes.common.CommonLevelupLayer").show(upgradePair.level1, upgradePair.level2)
    		 uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_FINISH_PLAY_FIGHTEND)
    	end)        
    end
    self._upgradeList = {}
end

function TreasureRobAllLayer:_onClickStopRob()
	self:stopAllActions()

	self._robStopped = true
	self:_robFinished()
end

function TreasureRobAllLayer:onBackKeyEvent()
	self:_checkLevelUp()
	uf_sceneManager:replaceScene(require("app.scenes.treasure.TreasureComposeScene").new(nil,nil,self._treasureID))
    return true
end

return TreasureRobAllLayer