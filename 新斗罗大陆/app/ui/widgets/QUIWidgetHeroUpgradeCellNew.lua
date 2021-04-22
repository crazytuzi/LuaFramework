--
-- Author: wkwang
-- Date: 2014-10-13 18:02:20
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHeroUpgradeCellNew = class("QUIWidgetHeroUpgradeCellNew", QUIWidget)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QHerosUtils = import("...utils.QHerosUtils")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QQuickWay = import("...utils.QQuickWay")
local QUIViewController = import("..QUIViewController")

QUIWidgetHeroUpgradeCellNew.CLICK_NONE = "CLICK_NONE"
QUIWidgetHeroUpgradeCellNew.CLICK_DOWN = "CLICK_DOWN"
QUIWidgetHeroUpgradeCellNew.BATTLEFORCE_UPDATE = "BATTLEFORCE_UPDATE"

function QUIWidgetHeroUpgradeCellNew:ctor(options)
	local ccbFile = "ccb/Widget_HeroUpgrade_client_new.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClick", callback = handler(self, QUIWidgetHeroUpgradeCellNew._onTriggerClick)},
	}
	QUIWidgetHeroUpgradeCellNew.super.ctor(self, ccbFile, callBacks, options)    
	self._isEating = false -- 是否在连续吃卡
	self._eatNum = 0
	self._delayTime = 0.1
	self._addNum = 1
	
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	self._eatEffectLayer = CCNode:create()
	page:getView():addChild(self._eatEffectLayer)
	self._numEffectLayer = CCNode:create()
	page:getView():addChild(self._numEffectLayer)
	self._reportEffectLayer = CCNode:create()
	page:getView():addChild(self._reportEffectLayer)
	self._ccbOwner.node_btn_state_down:setVisible(false)

	self._ccbOwner.tf_num:setVisible(false)
end

function QUIWidgetHeroUpgradeCellNew:onEnter()
	self._isEnter = true
end

function QUIWidgetHeroUpgradeCellNew:onExit()
	self._isEnter = false
	if self._eatEffectLayer ~= nil then
		self._eatEffectLayer:removeFromParentAndCleanup(true)
	end
	if self._numEffectLayer ~= nil then
		self._numEffectLayer:removeFromParentAndCleanup(true)
	end
	if self._reportEffectLayer ~= nil then
		self._reportEffectLayer:removeFromParentAndCleanup(true)
	end
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end
	if self._effectScheduler2 ~= nil then
		scheduler.unscheduleGlobal(self._effectScheduler2)
		self._effectScheduler2 = nil
	end
	if self._showReportSchedulers  ~= nil then
		for _,value in ipairs(self._showReportSchedulers) do
			scheduler.unscheduleGlobal(value)
		end
		self._showReportSchedulers = nil
	end
	if self._itemEffectTexture ~= nil then
		self._itemEffectTexture:release()
		self._itemEffectTexture = nil
	end
end

function QUIWidgetHeroUpgradeCellNew:_initReport()
	self._isShowReport = false -- 未展示报告
	self._lastIndex = -1

	self._reportEffectLayer:setVisible(false)
	self._reportEffectLayer:removeAllChildren()
	self._reportEffectLayer:setScale(1)
	self._reportEffectLayer:setPosition(self._targetPosition.x, self._targetPosition.y)
	if self._showReportSchedulers then
		while true do
			local es = table.remove(self._showReportSchedulers, 1)
			if es then 
				scheduler.unscheduleGlobal(es) 
				es = nil
			else
				self._showReportSchedulers = nil
				self._showReportSchedulers = {}
				break
			end
		end
	else
		self._showReportSchedulers = {}
	end
	
end

function QUIWidgetHeroUpgradeCellNew:setTargetPosition(p)
	self._targetPosition = p
end

function QUIWidgetHeroUpgradeCellNew:setTfBattlePosition(p)
	self._tfBattlePosition = p
end

function QUIWidgetHeroUpgradeCellNew:setInfo(value, actorId)
	self._item = value
	self._actorId = actorId
	self._heroUIModel = remote.herosUtil:getUIHeroByID(self._actorId)
	self._ccbOwner.tf_exp:setString("经验+"..self._item.exp)

	self._ccbOwner.node_icon:removeAllChildren()
	self._itemBox = QUIWidgetItemsBox.new()
	self._itemBox:setGoodsInfo(self._item.id, ITEM_TYPE.ITEM, 0)
	self._ccbOwner.node_icon:addChild(self._itemBox)
	self:updateItemNum()

	self._itemTexture = CCTextureCache:sharedTextureCache():addImage(self._item.icon)
	if self._itemEffectTexture ~= nil then
		self._itemEffectTexture:release()
		self._itemEffectTexture = nil
	end
	
	local path = QResPath("icon_url")["ITEM_ID_"..self._item.id]
	if path then
		self._itemEffectTexture = CCTextureCache:sharedTextureCache():addImage(path)
		self._itemEffectTexture:retain()
	end
end

function QUIWidgetHeroUpgradeCellNew:updateItemNum()
	local itemNum = remote.items:getItemsNumByID(self._item.id)
	self._ccbOwner.tf_num:setString("拥有:"..itemNum.."个")
	self._itemBox:setGoodsInfo(self._item.id, ITEM_TYPE.ITEM, itemNum)

	-- if itemNum >= 10000 then
	-- 	local tmp = math.floor(math.log10(itemNum / 10000) + 1)
	-- 	local tf_num = self._ccbOwner.tf_num
	-- 	tf_num:setScale(4 / (4 + tmp))
	-- end
	if itemNum == 0 then
		makeNodeFromNormalToGray(self._ccbOwner.node_icon)
		-- self._ccbOwner.node_btn:setEnabled(false)            -- 注释原因：没有经验道具的时候需要弹出快捷途径
	end
end

function QUIWidgetHeroUpgradeCellNew:_onTriggerClick(event)
	if tonumber(event) == CCControlEventTouchDown then
		self:_onDownHandler()
	else
		self:_onUpHandler()
	end
end

function QUIWidgetHeroUpgradeCellNew:_onDownHandler()
	self._isEating = false
	
	self._ccbOwner.node_btn_state_down:setVisible(true)
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end

	self._delayTime = 0.1
	self._addNum = 1
	-- 延时一秒 如果一秒内未up或者移动则连续吃经验
	-- print("[Kump] QUIWidgetHeroUpgradeCellNew:_onDownHandler() ", self._item.id)
	if self._item.id == 3 then
		self._delayTime = self._delayTime / 2
	elseif self._item.id == 4 then
		self._delayTime = self._delayTime / 1.8
	elseif self._item.id == 5 then
		self._delayTime = self._delayTime / 1.4
	elseif self._item.id == 6 then
		
	else

	end
	self._timeHandler = scheduler.performWithDelayGlobal(handler(self, self._eatExpItemsForEach), self._delayTime)
end

function QUIWidgetHeroUpgradeCellNew:_onUpHandler()
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end
	-- if self._numEffect ~= nil then
	-- 	self._numEffect:disappear()
	-- 	self._numEffect = nil
	-- end
	if self._ccbOwner.node_btn_state_down:isVisible() == false then
		return 
	end
	if self._isEating == false then
		self:_eatExpItem()
	else
		self._isEating = false
	end
	self._ccbOwner.node_btn_state_down:setVisible(false)

	local attribute = remote.herosUtil:getAttribute()
	local len = table.nums(attribute)
	if not len or len == 0 or self._isShowReport then return end
	self:_initReport()
	remote.herosUtil:cleanAttribute()	
	self._isShowReport = true
	self._reportEffectLayer:setVisible(true)

	local keys = remote.herosUtil:getAttributeKeys()
	local index = 0
	-- printTable(keys, "#")
	-- printTable(attribute, "$")
	for i=1,#keys do
		if attribute[keys[i]] ~= nil then
			index = index + 1
			local str = keys[i] .. " + " .. math.floor(attribute[keys[i]])
			self:_showOnceReport(str, index, 0.1*(index-1))
		end

		if i == #keys then 
			self._isEndReport = true 
			self._lastIndex = index
		end
	end
end

function QUIWidgetHeroUpgradeCellNew:showReport()
	local attribute = remote.herosUtil:getAttribute()
	local len = table.nums(attribute)
	-- if not len or len == 0 or self._isShowReport then return end
	if not len or len == 0  then return end
	self:_initReport()
	remote.herosUtil:cleanAttribute()	
	self._isShowReport = true
	self._reportEffectLayer:setVisible(true)

	local keys = {"等级 ", "生命 ", "攻击 ", "命中 ", "闪避 ", "暴击 ", "抗暴 ", "格挡 ", "攻速 ", "物理防御 ", 
		"法术防御 ", "物理穿透 ", "法术穿透 "}
	local index = 0
	for i=1,#keys do
		if attribute[keys[i]] ~= nil then
			index = index + 1
			local str = keys[i] .. " + " .. math.floor(attribute[keys[i]])
			self:_showOnceReport(str, index, 0.1*(index-1))
		end

		if i == #keys then 
			self._isEndReport = true 
			self._lastIndex = index
		end
	end
end

function QUIWidgetHeroUpgradeCellNew:_showOnceReport( str, index, delayTime )
	-- 当玩家结束吃经验的时候，展示报告
	local effectFun = function ()
		local effect = QUIWidgetAnimationPlayer.new()
		local offsetHeight = 51
		self._reportEffectLayer:addChild(effect)
		effect:setPosition(0, 0 - offsetHeight * (index - 1))
		effect:playAnimation("ccb/effects/Buff_up_1.ccbi", 
			function(ccbOwner) 
				ccbOwner.tf_report:setString(str)
			end, function()
				if self._isEndReport then
					if self._lastIndex == index then
						-- print(index, str)
						self._isEndReport = false
						-- effect:removeFromParentAndCleanup(true)
						self:_closeAllReport()
						-- remote.herosUtil:dispacthBattleforceUpdate(self._actorId)
					end
				end
			end, false)
	end
	local es = scheduler.performWithDelayGlobal(effectFun, delayTime)
	table.insert(self._showReportSchedulers, es)
end

function QUIWidgetHeroUpgradeCellNew:_closeAllReport()
	local fun = function() remote.herosUtil:dispacthBattleforceUpdate(self._actorId) end
	local time = 0.1
	self._reportEffectLayer:moveTo(time, self._tfBattlePosition.x, self._tfBattlePosition.y)
	self._reportEffectLayer:scaleTo(time, 0)
	scheduler.performWithDelayGlobal(fun, time)
end

function QUIWidgetHeroUpgradeCellNew:_eatExpItemsForEach()
	scheduler.unscheduleGlobal(self._timeHandler)
	self._timeHandler = nil
	self._timeHandler = scheduler.performWithDelayGlobal(handler(self, self._eatExpItem), self._delayTime)
end

function QUIWidgetHeroUpgradeCellNew:_eatExpItem()
	if self._ccbOwner.node_btn_state_down:isVisible() == false then
		if self._timeHandler ~= nil then
			scheduler.unscheduleGlobal(self._timeHandler)
			self._timeHandler = nil
		end
		return 
	end
	self._isEating = true
	local itemNum = remote.items:getItemsNumByID(self._item.id)
	if itemNum > 0 then
		if itemNum < self._addNum then
			self._addNum = itemNum
		end
		self._addNum = self._heroUIModel:checkEatItem(self._item.exp, self._addNum) --检查吃的经验是否超标
		if self._heroUIModel:heroCanUpgrade() == true then
			self._isShowReport = false 
			self:addEatNum(self._addNum)
			remote.herosUtil:heroEatExp(self._item.exp*self._addNum, self._actorId)
			self:_showEatNum()
			self:updateItemNum()
			self:_showEffect()
			if self._isEating == true then
				self._addNum = self._addNum + 2 
				self._addNum = self._addNum >= 10 and 10 or self._addNum
				self._timeHandler = scheduler.performWithDelayGlobal(handler(self, self._eatExpItem), self._delayTime)
			end
		else
		  app.tip:floatTip("魂师等级不能超过战队等级")
		end
	else
    	QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, self._item.id)
	end
end

--[[
	1.5秒之内不添加新的经验道具 则保存到后台
]]
function QUIWidgetHeroUpgradeCellNew:addEatNum(addNum)
	if remote.items:removeItemsByID(self._item.id, addNum) == false then
		return false
	end
	self._eatNum = self._eatNum + addNum
	return true
end

--[[
	获取吃卡数据
]]
function QUIWidgetHeroUpgradeCellNew:getEatExp()
	local eatNum = self._eatNum
	self._eatNum = 0
	return self._item.id, eatNum
	-- if self._eatNum > 0 then
	-- 	local eatNum = self._eatNum
	-- 	app:getClient():intensify(self._actorId, self._item.id, self._eatNum, function()
	-- 		remote.user:addPropNumForKey("todayHeroExpCount", eatNum)
	-- 	end)
	-- 	self._eatNum = 0
	-- end
end

function QUIWidgetHeroUpgradeCellNew:_showEatNum()
	if self._numEffect == nil then
		self._numEffect = QUIWidgetAnimationPlayer.new()
		local p = self._ccbOwner.node_eat_num:convertToWorldSpaceAR(ccp(0,0))
		self._numEffect:setPosition(p.x, p.y)
		self._numEffectLayer:addChild(self._numEffect)
	end
	local timeLine = "Default Timeline"
	-- if self._eatNum > 1 then
	-- 	timeLine = "2"
	-- end
	self._numEffect:playAnimation("ccb/Widget_Upgarde_tips.ccbi", function(ccbOwner)
				ccbOwner.tf_num:setString("×"..self._eatNum)
            end, nil, nil, timeLine)
end

function QUIWidgetHeroUpgradeCellNew:_showEffect(callBack)
	if self._targetPosition == nil then return end
	local effectFun1 = function ()
		if self._isEnter == nil or self._isEnter == false then return end
    	local effect = QUIWidgetAnimationPlayer.new()
    	effect:setPosition(self._targetPosition.x, self._targetPosition.y)
    	self._eatEffectLayer:addChild(effect)
    	effect:playAnimation("ccb/effects/UseItem2.ccbi", nil, function()
                effect:removeFromParentAndCleanup(true)
				if self._isEnter == nil or self._isEnter == false then return end
                if callBack ~= nil then callBack() end
            end)
	end
	local effectFun2 = function ()
		self._effectScheduler2 = nil
		if self._isEnter == nil or self._isEnter == false then return end
		local icon = CCSprite:create()
		icon:setTexture(self._itemEffectTexture)
		local p = self._ccbOwner.node_icon:convertToWorldSpaceAR(ccp(0,0))
		icon:setPosition(p.x, p.y)
		self._eatEffectLayer:addChild(icon)
		local arr = CCArray:create()
		arr:addObject(CCMoveTo:create(0.2, self._targetPosition))
		arr:addObject(CCCallFunc:create(function()
				icon:removeFromParentAndCleanup(true)
				effectFun1()
			end))
		local seq = CCSequence:create(arr)
		icon:runAction(seq)
	end
	local effectFun3 = function ()
		if self._isEnter == nil or self._isEnter == false then return end
		local effect = QUIWidgetAnimationPlayer.new()
		local p = self._ccbOwner.node_icon:convertToWorldSpaceAR(ccp(0,0))
    	effect:setPosition(p.x, p.y)
    	self._eatEffectLayer:addChild(effect)
    	effect:playAnimation("ccb/effects/UseItem.ccbi", function(ccbOwner)
    			ccbOwner.node_icon:setTexture(self._itemEffectTexture)
    		end, function()
                effect:removeFromParentAndCleanup(true)
            end)
	end
	effectFun3()
	self._effectScheduler2 = scheduler.performWithDelayGlobal(effectFun2, 0.1)
end

return QUIWidgetHeroUpgradeCellNew