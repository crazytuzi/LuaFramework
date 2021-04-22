-- @Author: xurui
-- @Date:   2019-04-15 16:00:38
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-11-02 17:58:00
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActivityForge = class("QUIWidgetActivityForge", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QQuickWay = import("...utils.QQuickWay")
local QRichText = import("...utils.QRichText")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QTextFiledScrollUtils = import("...utils.QTextFiledScrollUtils")

function QUIWidgetActivityForge:ctor(options)
	local ccbFile = "ccb/Widget_Acitivity_Forge.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerCharge", callback = handler(self, self._onTriggerCharge)},
		{ccbCallbackName = "onTriggerForgeOne", callback = handler(self, self._onTriggerForgeOne)}, 
		{ccbCallbackName = "onTriggerForgeTen", callback = handler(self, self._onTriggerForgeTen)},
		{ccbCallbackName = "onTriggerRecive", callback = handler(self, self._onTriggerRecive)},
    }
    QUIWidgetActivityForge.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._consumeItemStr = QStaticDatabase:sharedDatabase():getConfigurationValue("forge_make_need_item")
	self._consumeItemTabl = {}
	remote.items:analysisServerItem(self._consumeItemStr, self._consumeItemTabl)

	self._tSuccessAward = QStaticDatabase:sharedDatabase():getLuckyDraw("forge_lucky_draw2")
	self._tCritAward = QStaticDatabase:sharedDatabase():getLuckyDraw("forge_lucky_draw3")
	self._dRechargeNum = QStaticDatabase:sharedDatabase():getConfigurationValue("forge_sum_recharge")
	self._dForgeProbability = QStaticDatabase:sharedDatabase():getConfigurationValue("forge_begin_probability")

	self._tConsumeItemBoxs = {}
	self._oForgeActivity = remote.activityRounds:getForge()

	self._bShowEffect = false

	self._ccbOwner.node_hammer:setPositionX(display.ui_width/2)
	self._ccbOwner.node_tf_time:setPositionY(-display.height/2)
end

function QUIWidgetActivityForge:onEnter()
end

function QUIWidgetActivityForge:onExit()
    if self._probabiltyUpdate then
        self._probabiltyUpdate:stopUpdate()
        self._probabiltyUpdate = nil
    end
end

function QUIWidgetActivityForge:setInfo(info)
	self._info = info

	self:setAwardItem()

	self:setConsumeItem()

	self:setTitleInfo()

   	self:updateActivityInfo()
end

function QUIWidgetActivityForge:updateActivityInfo()
	local myForgeInfo = self._oForgeActivity:getMyForgeInfo()

	self._ccbOwner.btn_recharge:setVisible(myForgeInfo.activeState == 2)
	self._ccbOwner.node_btn_recive:setVisible(myForgeInfo.activeState == 1)
	self._ccbOwner.sp_ishave:setVisible(myForgeInfo.activeState == 3)
	self._ccbOwner.node_hammer:setVisible(not (myForgeInfo.activeState == 3))

	self._ccbOwner.node_hammer_1:setVisible(not (myForgeInfo.activeState == 3))
	self._ccbOwner.node_hammer_2:setVisible(myForgeInfo.activeState == 3)

	self._probability = (self._dForgeProbability or 0) * 100
	if myForgeInfo.activeState == 3 then
		self._probability = 100
	end
	self:_update(self._probability)
end

function QUIWidgetActivityForge:_update(value)
	local probabilityStr = math.floor(value or 0).."%"
	self._ccbOwner.tf_probability:setString(probabilityStr)
	if probabilityStr == "100%" then
		self._ccbOwner.tf_probability:setColor(COLORS.e)
	end
end

function QUIWidgetActivityForge:setTitleInfo()
    local startTimeTbl = q.date("*t", (self._info.start_at or 0)/1000)
    local endTimeTbl = q.date("*t", (self._info.end_at or 0)/1000)
    local awardEndTimeTbl = q.date("*t", (self._info.award_end_at or 0)/1000)

	local timeStr = string.format("%d月%d日%02d:%02d～%d月%d日%02d:%02d", startTimeTbl.month, startTimeTbl.day, startTimeTbl.hour, startTimeTbl.min, endTimeTbl.month, endTimeTbl.day, endTimeTbl.hour, endTimeTbl.min)
	self._ccbOwner.tf_time:setString(timeStr)
	--活动期间，累充达到98元可获得名匠锤，活动期间锻造成功率提升至100%
	if self._richText == nil then
		self._richText = QRichText.new({
	            {oType = "font", content = "活动期间，累充达到", size = 20, color = COLORS.a},
	            {oType = "font", content = self._dRechargeNum or 0, size = 20, color = COLORS.b},
	            -- {oType = "font", content = "元可获得名匠锤",size = 20, color = COLORS.a},
	            {oType = "font", content = "元可获得名匠锤，活动期间锻造成功率提升至", size = 20, color = COLORS.a},
	            {oType = "font", content = "100%", size = 20, color = COLORS.b},
	        },230)
		self._richText:setAnchorPoint(ccp(0, 1))
		self._ccbOwner.node_tf_pay:addChild(self._richText)
	end
end

function QUIWidgetActivityForge:setAwardItem()
	if self._itemBox1 == nil then
		self._itemBox1 = QUIWidgetItemsBox.new()
		self._ccbOwner.node_reward1:addChild(self._itemBox1)
		self._itemBox1:setPromptIsOpen(true)
	end
	self._itemBox1:setGoodsInfo(self._tSuccessAward.id_1, self._tSuccessAward.type_1)

	if self._itemBox2 == nil then
		self._itemBox2 = QUIWidgetItemsBox.new()
		self._ccbOwner.node_reward2:addChild(self._itemBox2)
		self._itemBox2:setItemTag("小概率")
		self._itemBox2:setPromptIsOpen(true)
    	self._itemBox2:showBoxEffect("effects/Auto_Skill_light.ccbi", true, 0, 0, 1.2)
	end
	self._itemBox2:setGoodsInfo(self._tCritAward.id_1, self._tCritAward.type_1)
end

function QUIWidgetActivityForge:setConsumeItem()
	local index = 1
	local gap = 20
	for _, value in ipairs(self._consumeItemTabl) do
		if self._tConsumeItemBoxs[index] == nil then
			self._tConsumeItemBoxs[index] = QUIWidgetItemsBox.new()
			self._ccbOwner.node_awards:addChild(self._tConsumeItemBoxs[index])
			self._tConsumeItemBoxs[index]:setPromptIsOpen(true)
		end
		self._tConsumeItemBoxs[index]:setGoodsInfo(value.id, value.typeName)
		local contentSize = self._tConsumeItemBoxs[index]:getContentSize()
		self._tConsumeItemBoxs[index]:setPositionX((index - 1) * (contentSize.width + gap))

		local num = 0
		if value.typeName ~= ITEM_TYPE.ITEM then
			num = remote.user[value.typeName] or 0
		else
			num = remote.items:getItemsNumByID(value.id)
		end
		self._tConsumeItemBoxs[index]:setItemCount(string.format("%s/%s", num, value.count))

		index = index + 1
	end
end

function QUIWidgetActivityForge:makeForge(forgeNum)
	if forgeNum == nil then return end

	if self._bShowEffect then return end

	local maxCount, itemInfo = self._oForgeActivity:getCurrentForgeCount(true)
    if maxCount < forgeNum then
    	app.tip:floatTip("锻造所需材料不足", 100)
        return
    end

	local forgeFunc = function()
		self._oForgeActivity:requestForgeMake(forgeNum, function(data)
			if self._ccbView and data then
				self._bShowEffect = true
				self:showSuccessEffect(data, forgeNum)
				self:setInfo(self._info)
			end
		end)
	end

	local myForgeInfo = self._oForgeActivity:getMyForgeInfo()
	if myForgeInfo and myForgeInfo.activeState == 3 then
		forgeFunc()
	elseif myForgeInfo.activeState == 2 then
		local showAlert = app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.FORGE_BEST_HAMMER)
		if showAlert then
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogForgeAlert", 
				options = {callBack = function(btnType)
					if btnType == 1 then
						self:_onTriggerCharge(forgeNum)
					elseif btnType == 2 then
						forgeFunc()
					end
				end}})
		else
			forgeFunc()
		end
	elseif myForgeInfo.activeState == 1 then
		app.tip:floatTip("魂师大人，请先领取名匠锤再进行锻造", 100)
	end
end

function QUIWidgetActivityForge:showSuccessEffect(data)
	local myForgeInfo = self._oForgeActivity:getMyForgeInfo()
	local activeStatus = myForgeInfo.activeState or 2 
	local awards = data.prizes or {}
	local status = data.forgeMakeResponse.states 

	local isSuccess = true
	if #status == 1 then
		isSuccess = status[1] ~= 1
	end

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogForgeActivitySuccess", 
		options = {activeStatus = activeStatus, awards = awards, isSuccess = isSuccess, callBack = function(isAgain, forgeNum)
			self._bShowEffect = false

			if isAgain and forgeNum then
				self:makeForge(forgeNum)
			end
		end}})
end

function QUIWidgetActivityForge:showReciveEffect()
	self._ccbOwner.node_hammer:setVisible(false)

    local proxy = CCBProxy:create()
    local ccbOwner = {}
    local effect = CCBuilderReaderLoad("monday_lizi_fx.ccbi", proxy, ccbOwner)
    self:getCCBView():addChild(effect)

    local speed = 800
    local startPosition = ccp(self._ccbOwner.node_hammer:getPosition())
    startPosition = ccp(startPosition.x - 50, startPosition.y - 90)
    effect:setPosition(startPosition)

    local targetPos = ccp(self._ccbOwner.node_hammer_1:getPosition())
    targetPos = ccp(targetPos.x + 40, targetPos.y - 40)

    local distance = q.distOf2Points(startPosition, targetPos)
    local angle = - q.angleOf2Points(startPosition, targetPos)
    effect:setRotation(angle)

    local effectArray = CCArray:create()
    effectArray:addObject(CCMoveTo:create(distance/speed, targetPos))
    effectArray:addObject(CCCallFunc:create(function()
    		effect:removeFromParent()
    		local frameEffect = QUIWidgetAnimationPlayer.new()
    		frameEffect:playAnimation("effects/forge_chage_hammer.ccbi", function()
				self._ccbOwner.node_hammer_1:setVisible(false)
				self._ccbOwner.node_hammer_2:setVisible(true)
    		end, function()
	    		if self._ccbView then
					if self._probabiltyUpdate == nil then
				    	self._probabiltyUpdate = QTextFiledScrollUtils.new()
					end
					self._probabiltyUpdate:addUpdate(self._probability, 100, handler(self, self._update), 1, function()
						self:updateActivityInfo()
                		self._oForgeActivity:handleEvent()
					end)
	    		end
    		end)
    		frameEffect:setPositionY(30)
    		self._ccbOwner.node_effect:addChild(frameEffect)
		end))

    effect:runAction(CCSequence:create(effectArray))
end


function QUIWidgetActivityForge:_onTriggerCharge(event)
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVIPRecharge"})
end

function QUIWidgetActivityForge:_onTriggerRecive(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_recive) == false then return end
	app.sound:playSound("common_small")

	self._oForgeActivity:requestForgeBestHammer(function(data)
		if self._ccbView then
			self:showReciveEffect()
		end
	end)
end

function QUIWidgetActivityForge:_onTriggerForgeOne(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_2) == false then return end
	app.sound:playSound("common_small")
	self:makeForge(1)
end

function QUIWidgetActivityForge:_onTriggerForgeTen(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_1) == false then return end
	app.sound:playSound("common_small")
	self:makeForge(5)
end

return QUIWidgetActivityForge
