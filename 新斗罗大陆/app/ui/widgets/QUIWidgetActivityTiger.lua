--
-- Author: wkwang
-- Date: 2015-06-19 17:40:31
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActivityTiger = class("QUIWidgetActivityTiger", QUIWidget)

local QUIWidgetActivityTigerNum = import("..widgets.QUIWidgetActivityTigerNum")
local QQuickWay = import("...utils.QQuickWay")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

function QUIWidgetActivityTiger:ctor(options)
	local ccbFile = "ccb/Widget_DragonMine.ccbi"
  	local callBacks = {
  		{ccbCallbackName = "onTriggerClick", callback = handler(self, QUIWidgetActivityTiger._onTriggerClick)},
  	}
	QUIWidgetActivityTiger.super.ctor(self,ccbFile,callBacks,options)

	self._localData = remote.activity:getOtherData(remote.activity.TYPE_ACTIVITY_FOR_TIGER)
	if self._localData == nil then
		app:getClient():tigerOpenRequest()
	end

	self:_initAnimationView()

    self._pageWidth = self._ccbOwner.node_mask:getContentSize().width
    self._pageHeight = self._ccbOwner.node_mask:getContentSize().height
    self._pageContent = self._ccbOwner.node_num
    local layerColor = CCLayerColor:create(ccc4(0,0,0,150),self._pageWidth,self._pageHeight)
    local ccclippingNode = CCClippingNode:create()
    layerColor:setPositionX(self._ccbOwner.node_mask:getPositionX())
    layerColor:setPositionY(self._ccbOwner.node_mask:getPositionY())
    ccclippingNode:setStencil(layerColor)
    self._pageContent:removeFromParent()
    ccclippingNode:addChild(self._pageContent)
    self._ccbOwner.node_mask:getParent():addChild(ccclippingNode)
    -- self._ccbOwner.dragon_node:removeAllChildren()
    self._animationManager = tolua.cast(self._ccbOwner.dragon_node:getUserObject(), "CCBAnimationManager")

    self._handlers = {}
end

function QUIWidgetActivityTiger:onEnter()
	QUIWidgetActivityTiger.super.onEnter(self)
	self._eventProxy = cc.EventProxy.new(remote.activity)
	self._eventProxy:addEventListener(remote.activity.EVENT_OTHER_CHANGE, handler(self, self._updateHandler))
end

function QUIWidgetActivityTiger:onExit()
	QUIWidgetActivityTiger.super.onExit(self)
	self._eventProxy:removeAllEventListeners()
	self:removeAllScheduler()
	self._animationManager = nil
	if self._moneyAnimation ~= nil then
		self._moneyAnimation:disappear()
		self._moneyAnimation = nil
	end
end

function QUIWidgetActivityTiger:setInfo(info)
	self._info = info
	self:infoUpdate()
end

function QUIWidgetActivityTiger:infoUpdate()
	if self._isRuning == true then
		local offsetTime = q.serverTime() - self._startTime
		offsetTime = 1 - offsetTime
		if offsetTime < 0 then offsetTime = 0 end
		table.insert(self._handlers, scheduler.performWithDelayGlobal(function ()
			if self._localData.curRewardCount == nil then return end
			local num = self._localData.curRewardCount or 0
			local count = 0
			for index,numWidget in pairs(self._nums) do
				local value = num%10
				if self._localData.curRewardCount > count*10 then
					table.insert(self._handlers,scheduler.performWithDelayGlobal(function ()
							numWidget:setTargetNum(value)
						end, count*0.1+1))
					count = count + 1
				else
					numWidget:setTargetNum(value)
				end
				num = math.floor(num/10)
			end
			table.insert(self._handlers, scheduler.performWithDelayGlobal(function ()
					self:showPanel()
					self:removeAllScheduler()
					self._isRuning = false
				end, count*0.1+1))
		end, offsetTime))
	else
		self:showPanel()
	end
end

function QUIWidgetActivityTiger:showPanel()
	--解析后台活动配置
	self._totalCount = 0 
	self._currCount = 0
	local awards = {}
	if self._info ~= nil then
		if self._info.params ~= nil then
			local awardInfos = string.split(self._info.params, "#")
			for _,value in pairs(awardInfos) do
				if value ~= "" then
					local infos = string.split(value, ",")
					table.insert(awards, infos)
				end
			end
		end
		self._totalCount = #awards
	end

	--计算已经抽奖
	totalToken = 0
	if self._localData ~= nil then
		self._currCount = self._localData.count
		totalToken = self._localData.rewardCount
		if self._localData.logs ~= nil then
			-- for i=1,3,1 do
			-- 	if self._ccbOwner["tf_"..i] ~= nil then
			-- 		self._ccbOwner["tf_"..i]:setString("")
			-- 	end
			-- end
			for index,value in pairs(self._localData.logs) do
				if self._ccbOwner["tf_"..index] ~= nil then
					self._ccbOwner["tf_"..index]:setString("恭喜 "..value.nickname.." 获得 "..value.reward.." 钻石")
				end
			end
		end
	end
	self._ccbOwner.tf_token:setString(remote.user.token)
	self._ccbOwner.tf_award:setString(totalToken)
	if self._currCount < self._totalCount then
		self._award = awards[self._currCount+1]
		self._ccbOwner.tf_awards_expect:setString(self._award[2].."~"..self._award[3])
		self._ccbOwner.tf_token_pay:setString(self._award[1])
		makeNodeFromGrayToNormal(self._ccbOwner.node_btn)
	else
		self._ccbOwner.tf_awards_expect:setString("0")
		self._ccbOwner.tf_token_pay:setString("0")
		-- self._ccbOwner.node_btn:setVisible(false)
		makeNodeFromNormalToGray(self._ccbOwner.node_btn)
	end
	self._ccbOwner.tf_count:setString(self._totalCount-self._currCount.."/"..self._totalCount)
end

function QUIWidgetActivityTiger:_updateHandler(event)
	self._localData = remote.activity:getOtherData(remote.activity.TYPE_ACTIVITY_FOR_TIGER)
	self:infoUpdate()
end

function QUIWidgetActivityTiger:_initAnimationView()
	local index = 1
    self._nums = {}
	while true do
		if self._ccbOwner["node_num"..index] ~= nil then
			self._ccbOwner["node_num"..index]:removeAllChildren()
			local numWidget = QUIWidgetActivityTigerNum.new()
			self._ccbOwner["node_num"..index]:addChild(numWidget)
			table.insert(self._nums, numWidget)
			index = index + 1
		else
			break
		end
	end
end

function QUIWidgetActivityTiger:removeAllScheduler()
	for _,handler in pairs(self._handlers) do
		scheduler.unscheduleGlobal(handler)
	end
	self._handlers = {}
end

function QUIWidgetActivityTiger:_startRuning()
	self._isRuning = true
    self._animationManager:runAnimationsForSequenceNamed("Default Timeline")
    if self._moneyAnimation == nil then
    	self._moneyAnimation = QUIWidgetAnimationPlayer.new()
    	self._ccbOwner.node_money:addChild(self._moneyAnimation)
    end
	self._moneyAnimation:playAnimation("ccb/effects/DragonMine2.ccbi", nil, function ()
    		self._moneyAnimation = nil
    	end)
	for index,numWidget in pairs(self._nums) do
		table.insert(self._handlers,scheduler.performWithDelayGlobal(function ()
			numWidget:runAnimation()
			end, index/20)) 
	end
end

function QUIWidgetActivityTiger:_onTriggerClick()
	if self._isRuning == true then return end
	if self._currCount >= self._totalCount then
		app.tip:floatTip("次数已用完")
		return 
	end
	if tonumber(self._award[1]) > remote.user.token then
    	QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
		return
	end
	self._startTime = q.serverTime()
	self:removeAllScheduler()
	self:_startRuning()
	app:getClient():tigerStartRequest()
end

return QUIWidgetActivityTiger