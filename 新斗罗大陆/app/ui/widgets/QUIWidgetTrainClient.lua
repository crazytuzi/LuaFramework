-- @Author: liaoxianbo
-- @Date:   2019-12-16 14:33:34
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-12-16 16:29:03
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetTrainClient = class("QUIWidgetTrainClient", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QQuickWay = import("...utils.QQuickWay")
local QUIHeroModel = import("...models.QUIHeroModel")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

QUIWidgetTrainClient.CLICK_TRAIN_MASTER = "CLICK_TRAIN_MASTER"

local savedTrainingType = nil

function QUIWidgetTrainClient:ctor(options)
	local ccbFile = "ccb/Widget_HeroDevelop_client.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerTraining", callback = handler(self, self._onTriggerTraining)},
		{ccbCallbackName = "onTriggerApply", callback = handler(self, self._onTriggerApply)},
		{ccbCallbackName = "onTriggerNormalCheck", callback = handler(self, self._onTriggerNormalCheck)},
		{ccbCallbackName = "onTriggerMoneyCheck", callback = handler(self, self._onTriggerMoneyCheck)},
		{ccbCallbackName = "onTriggerTokenCheck", callback = handler(self, self._onTriggerTokenCheck)},
		{ccbCallbackName = "onTriggerTrainMaster", callback = handler(self, self._onTriggerTrainMaster)},
    }
    QUIWidgetTrainClient.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	q.setButtonEnableShadow(self._ccbOwner.btn_training)
	q.setButtonEnableShadow(self._ccbOwner.btn_change)

	self:initPercentBarProcess()
end

function QUIWidgetTrainClient:initPercentBarProcess( ... )
    local function addMaskLayer(ccb, mask)
    	local width = ccb:getContentSize().width
    	local height = ccb:getContentSize().height
    	local maskLayer = CCLayerColor:create(ccc4(0,0,0,150), width, height)
    	maskLayer:setAnchorPoint(ccp(0, 0.5))
    	maskLayer:setPosition(ccp(-width/2, -height/2))

		local ccclippingNode = CCClippingNode:create()
		ccclippingNode:setStencil(maskLayer)
		ccb:retain()
		ccb:removeFromParent()
		ccclippingNode:addChild(ccb)
		ccb:release()

		mask:addChild(ccclippingNode)
		return maskLayer
    end

    -- add mask on progress bar
    self._hpMask = addMaskLayer(self._ccbOwner.hp_bar, self._ccbOwner.hp_mask)
    self._attackMask = addMaskLayer(self._ccbOwner.attack_bar, self._ccbOwner.attack_mask)
    self._pdMask = addMaskLayer(self._ccbOwner.pd_bar, self._ccbOwner.pd_mask)
    self._mdMask = addMaskLayer(self._ccbOwner.md_bar, self._ccbOwner.md_mask)

    self._trainingType = 1 -- 1 普通培养 2 金魂币培养 3 钻石培养
    if savedTrainingType then
    	self._trainingType = savedTrainingType
    end

end
function QUIWidgetTrainClient:onEnter()
end

function QUIWidgetTrainClient:onExit()
	if self.effectTips ~= nil then
		self.effectTips:stopAnimation()
		self.effectTips:removeFromParent()
		self.effectTips = nil
	end	
end

-- attributes: {"hp" = 100, "attack" = 120, "pd" = 80, "md" = 60}
-- attr_changes: {"hp" = 8, "attack" = 7, "pd" = 5, "md" = 2}
function QUIWidgetTrainClient:update(actorId)
	local oldActorID = self._actorId
    self._actorId = actorId
    local train_id = db:getCharacterByID(self._actorId).train_id

	local attributes = remote.herosUtil:getHeroByID(actorId).trainAttr or {}
	local level = remote.herosUtil:getHeroByID(actorId).level
    local attr_changes = {hp = 0, attack = 0, armorPhysical = 0, armorMagic = 0}
    for k, v in ipairs(remote.herosUtil:getHeroByID(actorId).trainAttrPres or {}) do 
    	attr_changes.hp = (v.hp or 0) + attr_changes.hp
    	attr_changes.attack = (v.attack or 0) + attr_changes.attack
    	attr_changes.armorPhysical = (v.armorPhysical or 0) + attr_changes.armorPhysical
    	attr_changes.armorMagic = (v.armorMagic or 0) + attr_changes.armorMagic
    end

	self._ccbOwner.stone:setString(remote.user.trainMoney or 0)
	local forceChanged = app.master:getForceChanges(actorId, attributes)

	self._forceChanged = forceChanged
	local config = db:getTrainingBonus(self._actorId)
	local trainLevel, masterForce, curObj, nextObj = 0, 0, nil, nil
	for _, obj in ipairs(config) do
		nextObj = obj
		if obj.standard > forceChanged then
			break
		else
			trainLevel = trainLevel + 1
			curObj = obj
			masterForce = masterForce + app.master:getTrainMasterForce(curObj, self._actorId)
		end
	end
	local oldTrainLevel = self._trainLevel
	local oldExtraConfig = self._extraConfig
	local oldCurObj = q.cloneShrinkedObject(self._curObj)
	self._trainLevel = trainLevel
	self._extraConfig = config
	self._curObj = curObj

	if nextObj then
		self._ccbOwner.force:setString(tostring(forceChanged+masterForce) .. "/" .. tostring(nextObj.standard+masterForce))
	else
		self._ccbOwner.force:setString("0/0")
	end
	if trainLevel ~= oldTrainLevel or oldTrainLevel == nil or oldActorID == nil or oldActorID ~= actorId then
		self._ccbOwner.tf_icon_level:setVisible(trainLevel > 0)
		self._ccbOwner.tf_icon_level:setString("LV" .. tostring(trainLevel))
	end

	self:_updateAttribute(attributes, train_id, level)
	self:_updateAttributeChanges(attr_changes)
	self:_updateCost()
	self:_updateCheckbox(self._trainingType)

	self._ccbOwner.stone:setString(remote.user.trainMoney or 0)

	-- train level up animation
	if trainLevel ~= oldTrainLevel and oldTrainLevel ~= nil and trainLevel ~= nil and trainLevel > oldTrainLevel and oldActorID == actorId then
		app.master:upGradeGemstoneMaster(oldTrainLevel, trainLevel, QUIHeroModel.HERO_TRAIN_MASTER, self._actorId, oldCurObj)
	end
end

-- update training bar
function QUIWidgetTrainClient:_updateAttribute(attributes, index, level)
	local hp_string = (attributes["hp"] or 0) .. "/" .. self:_hpUpperLimit(index, level)
	local attack_string = (attributes["attack"] or 0) .. "/" .. self:_attackUpperLimit(index, level)
	local pd_string = (attributes["armorPhysical"] or 0) .. "/" .. self:_physicalDefendUpperLimit(index, level)
	local md_string = (attributes["armorMagic"] or 0) .. "/" .. self:_magicalDefendUpperLimit(index, level)

	local hp_ratio = (attributes["hp"] or 0)/self:_hpUpperLimit(index, level)
	local attack_ratio = (attributes["attack"] or 0)/self:_attackUpperLimit(index, level)
	local pd_ratio = (attributes["armorPhysical"] or 0)/self:_physicalDefendUpperLimit(index, level)
	local md_ratio = (attributes["armorMagic"] or 0)/self:_magicalDefendUpperLimit(index, level)

	self._ccbOwner.hp_string:setString(hp_string)
	self._ccbOwner.attack_string:setString(attack_string)
	self._ccbOwner.pd_string:setString(pd_string)
	self._ccbOwner.md_string:setString(md_string)

	self._hpMask:setScaleX(hp_ratio > 0 and hp_ratio or 0)
	self._attackMask:setScaleX(attack_ratio > 0 and attack_ratio or 0)
	self._pdMask:setScaleX(pd_ratio > 0 and pd_ratio or 0)
	self._mdMask:setScaleX(md_ratio > 0 and md_ratio or 0)

	if (attributes["hp"] or 0) >= self:_hpUpperLimit(index, level) and (attributes["attack"] or 0) >= self:_attackUpperLimit(index, level)
		and (attributes["armorPhysical"] or 0) >= self:_physicalDefendUpperLimit(index, level) and (attributes["armorMagic"] or 0) >= self:_magicalDefendUpperLimit(index, level) then
		makeNodeFromNormalToGray(self._ccbOwner.btn_develop)
		self._trainingImpl = function ( ... )
			app.tip:floatTip("这个魂师培养已达到上限，升级魂师能提升培养上限")
		end
	else
		makeNodeFromGrayToNormal(self._ccbOwner.btn_develop)
		self._trainingImpl = function ( data )
			local trainNum = data.num
			app:getClient():heroTrainRequest(self._actorId, self._trainingType, trainNum, function()
				self:update(self._actorId)
				remote.user:addPropNumForKey("todayHeroTrainCount", trainNum)

				self:nodeEffect(self._ccbOwner.hp_green)
				self:nodeEffect(self._ccbOwner.hp_red)
				self:nodeEffect(self._ccbOwner.attack_green)
				self:nodeEffect(self._ccbOwner.attack_red)
				self:nodeEffect(self._ccbOwner.pd_green)
				self:nodeEffect(self._ccbOwner.pd_red)
				self:nodeEffect(self._ccbOwner.md_green)
				self:nodeEffect(self._ccbOwner.md_red)
			end)
		end
	end
end

-- update attribute change value and arrow
function QUIWidgetTrainClient:_updateAttributeChanges(attr_changes)
	self._ccbOwner.hp_green:setVisible(attr_changes["hp"] > 0)
	self._ccbOwner.hp_arrow_green:setVisible(attr_changes["hp"] > 0)
	self._ccbOwner.hp_red:setVisible(attr_changes["hp"] < 0)
	self._ccbOwner.hp_arrow_red:setVisible(attr_changes["hp"] < 0)

	self._ccbOwner.attack_green:setVisible(attr_changes["attack"] > 0)
	self._ccbOwner.attack_arrow_green:setVisible(attr_changes["attack"] > 0)
	self._ccbOwner.attack_red:setVisible(attr_changes["attack"] < 0)
	self._ccbOwner.attack_arrow_red:setVisible(attr_changes["attack"] < 0)

	self._ccbOwner.pd_green:setVisible(attr_changes["armorPhysical"] > 0)
	self._ccbOwner.pd_arrow_green:setVisible(attr_changes["armorPhysical"] > 0)
	self._ccbOwner.pd_red:setVisible(attr_changes["armorPhysical"] < 0)
	self._ccbOwner.pd_arrow_red:setVisible(attr_changes["armorPhysical"] < 0)

	self._ccbOwner.md_green:setVisible(attr_changes["armorMagic"] > 0)
	self._ccbOwner.md_arrow_green:setVisible(attr_changes["armorMagic"] > 0)
	self._ccbOwner.md_red:setVisible(attr_changes["armorMagic"] < 0)
	self._ccbOwner.md_arrow_red:setVisible(attr_changes["armorMagic"] < 0)

	self._ccbOwner.hp_green:setString(attr_changes["hp"])
	self._ccbOwner.attack_green:setString(attr_changes["attack"])
	self._ccbOwner.pd_green:setString(attr_changes["armorPhysical"])
	self._ccbOwner.md_green:setString(attr_changes["armorMagic"])
	self._ccbOwner.hp_red:setString(attr_changes["hp"])
	self._ccbOwner.attack_red:setString(attr_changes["attack"])
	self._ccbOwner.pd_red:setString(attr_changes["armorPhysical"])
	self._ccbOwner.md_red:setString(attr_changes["armorMagic"])



	-- set train button infos
	if not app.unlock:checkLock("UNLOCK_TRAIN_100", false) then
		self._ccbOwner.tf_ten:setString("培养10次")
		self._ccbOwner.tf_one:setString("培养1次")
	else
		self._ccbOwner.tf_ten:setString("培养100次")
		self._ccbOwner.tf_one:setString("培养10次")
	end

	
	self._ccbOwner.node_btn_develop:setVisible(true)
	self._ccbOwner.node_btn_change:setVisible(true)
	self._ccbOwner.node_reduce_effect:setVisible(false)

	if attr_changes["hp"] ~= 0 or attr_changes["attack"] ~= 0  
		or attr_changes["armorPhysical"] ~= 0 or attr_changes["armorMagic"] ~= 0 then
		self._ccbOwner.tf_ten:setString("替换")
		self._ccbOwner.tf_one:setString("取消")

		if attr_changes["hp"] <= 0 and attr_changes["attack"] <= 0
			and attr_changes["armorPhysical"] <= 0 and attr_changes["armorMagic"] <= 0 then
			self._ccbOwner.node_btn_change:setVisible(false)
		elseif attr_changes["hp"] >= 0 and attr_changes["attack"] >= 0
			and attr_changes["armorPhysical"] >= 0 and attr_changes["armorMagic"] >= 0 then
			self._ccbOwner.node_btn_develop:setVisible(false)
		end
	else
		--xurui:检查扫荡功能解锁提示
		self._ccbOwner.node_reduce_effect:setVisible(app.tip:checkReduceUnlokState("train10"))
	end
end

function QUIWidgetTrainClient:_updateCost()
	local train_money = self:_getTrainingCost(1)
	self._ccbOwner.normal_stone:setString(train_money)

	local train_money, money, token = self:_getTrainingCost(2)
	self._ccbOwner.money_stone:setString(train_money)
	self._ccbOwner.money:setString(money)

	local train_money, money, token = self:_getTrainingCost(3)
	self._ccbOwner.token_stone:setString(train_money)
	self._ccbOwner.token:setString(token)
end

function QUIWidgetTrainClient:_getTrainingCost(costType)
	local cost = db:getTrainingCost(tostring(costType))
	for k, v in ipairs(cost) do
		if v.train_level == self._trainLevel then
			return v.train_money, v.money, v.token
		end
	end

	return cost[#cost].train_money, cost[#cost].money, cost[#cost].token
end

function QUIWidgetTrainClient:nodeEffect(node)
	if node ~= nil then
	    local actionArrayIn = CCArray:create()
        actionArrayIn:addObject(CCScaleTo:create(0.23, 1.5))
        actionArrayIn:addObject(CCScaleTo:create(0.23, 0.75))
	    local ccsequence = CCSequence:create(actionArrayIn)
		node:runAction(ccsequence)
	end
end

function QUIWidgetTrainClient:trainingImplByNum(peiyangNum)
	local trainMoney, money, token = self:_getTrainingCost(self._trainingType)
	local realPyNum = peiyangNum or 1
	local trainMoneyNum, moneyNum, tokenNum = realPyNum,realPyNum,realPyNum

	if remote.user.trainMoney < trainMoney * peiyangNum then
		trainMoneyNum = math.floor(remote.user.trainMoney / trainMoney)
	end
	if remote.user.money < money * peiyangNum then
		moneyNum = math.floor(remote.user.money / money)
	end
	if remote.user.token < token * peiyangNum then
		tokenNum = math.floor(remote.user.token / token)
	end
	realPyNum = math.min(trainMoneyNum,moneyNum)
	realPyNum = math.min(realPyNum,tokenNum)
	if realPyNum > 0 then
		self._trainingImpl({num = realPyNum})
	else
		if trainMoneyNum <= 0 then
			QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.TRAIN_MONEY)
			return
		end

		if moneyNum <= 0 then
			QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.MONEY)
			return
		end

		if tokenNum <= 0 then
			QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
			return
		end
	end
end

function QUIWidgetTrainClient:_onTriggerTraining(event)

    app.sound:playSound("common_small")
	if self._ccbOwner.tf_one:getString() == "取消" then
		app:getClient():heroTrainClearRequest(self._actorId, function()
				self:update(self._actorId)
			end)
		return
	end

	local peiyangNum = 1 
	if self._ccbOwner.tf_one:getString() == "培养10次" then
		if app.unlock:checkLock("UNLOCK_TRAIN_100") == false then
			app.unlock:tipsLock("UNLOCK_TRAIN_100", nil, true)
			return
		end
		peiyangNum = 10
	end

	self:trainingImplByNum(peiyangNum)
end

function QUIWidgetTrainClient:_onTriggerApply(event)
	if self._isMoving then return end
    app.sound:playSound("common_small")

	if self._ccbOwner.tf_ten:getString() == "培养10次" then
		if app.unlock:checkLock("UNLOCK_TRAIN_10") == false then
			app.unlock:tipsLock("UNLOCK_TRAIN_10", nil, true)
			return
		end

		--xurui:设置扫荡功能解锁提示
		if app.tip:checkReduceUnlokState("train10") then
			app.tip:setReduceUnlockState("train10", 2)
			self._ccbOwner.node_reduce_effect:setVisible(false)
		end

		self:trainingImplByNum(10)
		return
	elseif self._ccbOwner.tf_ten:getString() == "培养100次" then
		if app.unlock:checkLock("UNLOCK_TRAIN_100") == false then
			app.unlock:tipsLock("UNLOCK_TRAIN_100", nil, true)
			return
		end

		--xurui:设置扫荡功能解锁提示
		if app.tip:checkReduceUnlokState("train10") then
			app.tip:setReduceUnlockState("train10", 2)
			self._ccbOwner.node_reduce_effect:setVisible(false)
		end

		self:trainingImplByNum(100)
		return		
	end

	local function playTrainingAnimation(attrChanges, attribute)
		if attrChanges[attribute] > 0 then
			local effect = QUIWidgetAnimationPlayer.new()
			self._ccbOwner[attribute.."_light"]:addChild(effect)
			effect:playAnimation("effects/Peiyang_bar_light.ccbi", nil, function ()
				effect:removeFromParent()
			end)
		end
	end

	local function playForceEffect()
		local array = CCArray:create()
		array:addObject(CCScaleTo:create(0.23, 1.5))
		array:addObject(CCScaleTo:create(0.23, 1))
		self._ccbOwner.force:runAction(CCSequence:create(array))
	end

    local attr_changes = {hp = 0, attack = 0, armorPhysical = 0, armorMagic = 0}
    for k, v in ipairs(remote.herosUtil:getHeroByID(self._actorId).trainAttrPres or {}) do 
    	attr_changes.hp = (v.hp or 0) + attr_changes.hp
    	attr_changes.attack = (v.attack or 0) + attr_changes.attack
    	attr_changes.armorPhysical = (v.armorPhysical or 0) + attr_changes.armorPhysical
    	attr_changes.armorMagic = (v.armorMagic or 0) + attr_changes.armorMagic
    end

	app:getClient():heroTrainApplyRequest(self._actorId, function()
		if self._ccbView then
			playTrainingAnimation(attr_changes, "hp")
			playTrainingAnimation(attr_changes, "attack")
			playTrainingAnimation(attr_changes, "armorPhysical")
			playTrainingAnimation(attr_changes, "armorMagic")
			playForceEffect()
			self:update(self._actorId)
		end
	end)
end

function QUIWidgetTrainClient:_onTriggerNormalCheck()
    app.sound:playSound("common_menu")
	savedTrainingType = 1
	self._trainingType = 1
	self:_updateCheckbox(self._trainingType)
end

function QUIWidgetTrainClient:_onTriggerMoneyCheck()
    app.sound:playSound("common_menu")
	savedTrainingType = 2
	self._trainingType = 2
	self:_updateCheckbox(self._trainingType)
	self:_showTrainingEffect(self._trainingType)
end

function QUIWidgetTrainClient:_onTriggerTokenCheck()
    app.sound:playSound("common_menu")
	savedTrainingType = 3
	self._trainingType = 3
	self:_updateCheckbox(self._trainingType)
	self:_showTrainingEffect(self._trainingType)
end

function QUIWidgetTrainClient:_updateCheckbox(type)
	self._ccbOwner.normal_check:setVisible(type == 1)
	self._ccbOwner.money_check:setVisible(type == 2)
	self._ccbOwner.token_check:setVisible(type == 3)
end

function QUIWidgetTrainClient:_showTrainingEffect(trainType)
	if trainType == 2 then
		app.tip:floatTip("高级培养获得的属性是普通培养的1.5倍")
	elseif trainType == 3 then
		app.tip:floatTip("豪华培养获得的属性是普通培养的2倍")
	end
end 

function QUIWidgetTrainClient:_hpUpperLimit(index, level)
	return db:getTrainingAttribute(index, level)["hp_value"] or 0
end

function QUIWidgetTrainClient:_attackUpperLimit(index, level)
	return db:getTrainingAttribute(index, level)["attack_value"] or 0
end

function QUIWidgetTrainClient:_physicalDefendUpperLimit(index, level)
	return db:getTrainingAttribute(index, level)["armor_physical"] or 0
end

function QUIWidgetTrainClient:_magicalDefendUpperLimit(index, level)
	return db:getTrainingAttribute(index, level)["armor_magic"] or 0
end

function QUIWidgetTrainClient:_onTriggerTrainMaster()
    app.sound:playSound("common_small")
	self:dispatchEvent({name = QUIWidgetTrainClient.CLICK_TRAIN_MASTER, masterType = QUIHeroModel.HERO_TRAIN_MASTER})
end

function QUIWidgetTrainClient:getContentSize()
end

return QUIWidgetTrainClient
