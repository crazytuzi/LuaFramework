-- 
-- zxs
-- 宗门武魂
-- 
local QUIDialogBaseUnion = import(".QUIDialogBaseUnion")
local QUIDialogUnionDragonTrain = class("QUIDialogUnionDragonTrain", QUIDialogBaseUnion)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetUnionDragonTrainTask = import("..widgets.dragon.QUIWidgetUnionDragonTrainTask")
local QUIWidgetUnionDragonTrainAvatar = import("..widgets.dragon.QUIWidgetUnionDragonTrainAvatar")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

function QUIDialogUnionDragonTrain:ctor(options)
	local ccbFile = "ccb/Dialog_society_dragontrain_main.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerGrade", callback = handler(self, self._onTriggerGrade)},
		{ccbCallbackName = "onTriggerProp", callback = handler(self, self._onTriggerProp)},
		{ccbCallbackName = "onTriggerRank", callback = handler(self, self._onTriggerRank)},
		{ccbCallbackName = "onTriggerChange", callback = handler(self, self._onTriggerChange)},
		{ccbCallbackName = "onTriggerRule", callback = handler(self, self._onTriggerRule)},
	}
	QUIDialogUnionDragonTrain.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    CalculateUIBgSize(self._ccbOwner.sp_bg)
	
	self._taskClient = QUIWidgetUnionDragonTrainTask.new()
	self._ccbOwner.node_client:addChild(self._taskClient)
	self._isAni = false
end

function QUIDialogUnionDragonTrain:viewDidAppear()
	QUIDialogUnionDragonTrain.super.viewDidAppear(self)
	self:addBackEvent(false)
	
	self._dragonProxy = cc.EventProxy.new(remote.dragon)
    self._dragonProxy:addEventListener(remote.dragon.TASK_REWARD_SHOW_END, handler(self, self._update))
    self._dragonProxy:addEventListener(remote.dragon.CHANGE_UPDATE, handler(self, self._update))

	self:setDragonInfo()
	self:checkDragonLevel()
end

function QUIDialogUnionDragonTrain:viewWillDisappear()
	QUIDialogUnionDragonTrain.super.viewWillDisappear(self)
	self:removeBackEvent()
	self._dragonProxy:removeAllEventListeners()
end

function QUIDialogUnionDragonTrain:checkDragonLevel()
	local callback
	callback = function()
		remote.dragon:checkDragonLevelUp(callback)
	end
	callback()
end

function QUIDialogUnionDragonTrain:_update(event)
	if event.name == remote.dragon.TASK_REWARD_SHOW_END then
		self:showExpUpAni()
	elseif event.name == remote.dragon.CHANGE_UPDATE then
		self:setDragonInfo()
	end
end

function QUIDialogUnionDragonTrain:showExpUpAni()
	local exp = remote.dragon:getDragonUpExp()
	if exp <= 0 then
		return
	end
	
	local effectName = "effects/Tips_add.ccbi"
	local content = "+" .. exp
	self._isAni = true
	self._taskClient:setIsAnimation(self._isAni)
	self._effect = QUIWidgetAnimationPlayer.new()
	self._ccbOwner.node_effect:removeAllChildren()
	self._ccbOwner.node_effect:addChild(self._effect)
	self._effect:playAnimation(effectName, function(ccbOwner)
			ccbOwner.content:setString(content)
		end, function()
	    	self._effect:disappear()
			self:setDragonInfo()
	    	self:checkLevelUp()
	    	self._isAni = false
	    	self._taskClient:setIsAnimation(self._isAni)
	    end)
end

function QUIDialogUnionDragonTrain:checkLevelUp()
	remote.dragon:checkDragonLevelByAddExp()
end

function QUIDialogUnionDragonTrain:setDragonInfo()
	local dragonInfo = remote.dragon:getDragonInfo()
	local levelConfig = db:getUnionDragonInfoByLevel(dragonInfo.level)
	local dragonConfig = db:getUnionDragonConfigById(dragonInfo.dragonId)
	self._dragonInfo = dragonInfo

	local color = remote.dragon:getDragonColor(dragonInfo.dragonId, dragonInfo.level)
    setShadowByFontColor(self._ccbOwner.tf_dragon_name, color)
    local exp = dragonInfo.exp/levelConfig.exp
    if exp > 1 then
    	exp = 1
    end
	self._ccbOwner.tf_dragon_name:setColor(color)
	self._ccbOwner.tf_dragon_name:setString(dragonConfig.dragon_name.." LV."..dragonInfo.level)
	self._ccbOwner.tf_exp:setString("经验值："..dragonInfo.exp.."/"..levelConfig.exp)
	self._ccbOwner.sp_exp_bar:setScaleX(exp)

	-- set dragon avatar
	if self._avatar == nil then
		self._avatar = QUIWidgetUnionDragonTrainAvatar.new()
		self._ccbOwner.node_dragon:removeAllChildren()
		self._ccbOwner.node_dragon:addChild(self._avatar)
	end
	self._avatar:setInfo(dragonInfo)
	self._avatar:setEffectVisible(true)
end

function QUIDialogUnionDragonTrain:_onTriggerGrade(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_grade) == false then return end
	if self._isAni then return end
    app.sound:playSound("common_small")

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogUnionDragonTrainSkill"})
end

function QUIDialogUnionDragonTrain:_onTriggerProp(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_prop) == false then return end
	if self._isAni then return end
    app.sound:playSound("common_small")

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogUnionDragonTrainProp"})
end

function QUIDialogUnionDragonTrain:_onTriggerChange(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_change) == false then return end
	if self._isAni then return end
    app.sound:playSound("common_small")

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnionDragonTrainChange"})
end

function QUIDialogUnionDragonTrain:_onTriggerRank()
	if self._isAni then return end
    app.sound:playSound("common_small")

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnionDragonTrainRank"})
end

function QUIDialogUnionDragonTrain:_onTriggerRule()
	if self._isAni then return end
    app.sound:playSound("common_small")

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogUnionDragonTrainHelp"})
end

function QUIDialogUnionDragonTrain:onTriggerBackHandler(tag)
	if self._isAni then return end
		
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogUnionDragonTrain