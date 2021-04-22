-- @Author: xurui
-- @Date:   2019-03-01 10:50:11
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-09-22 10:40:12
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMonopolyFlowerUpgrade = class("QUIDialogMonopolyFlowerUpgrade", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")

function QUIDialogMonopolyFlowerUpgrade:ctor(options)
	local ccbFile = "ccb/effects/Widget_monopoly_cultivate.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerContinue", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogMonopolyFlowerUpgrade.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	q.setButtonEnableShadow(self._ccbOwner.btn_continue)

    if options then
    	self._callBack = options.callBack
    	self._actionType = options.actionType 
    	self._newImmortalInfo = options.newImmortalInfo
    	self._oldImmortalInfo = options.oldImmortalInfo
    	self._flowerId = tonumber(options.flowerId)
    end

	if q.isEmpty(self._oldImmortalInfo) then
		self._oldImmortalInfo = self._newImmortalInfo
	end

    self._totalBarWidth = self._ccbOwner.sp_exp_bar:getContentSize().width * self._ccbOwner.sp_exp_bar:getScaleX()
    self._totalBarPosX = self._ccbOwner.sp_exp_bar:getPositionX()

    self._percentBarClippingNode = q.newPercentBarClippingNode(self._ccbOwner.sp_exp_bar)
end

function QUIDialogMonopolyFlowerUpgrade:viewDidAppear()
	QUIDialogMonopolyFlowerUpgrade.super.viewDidAppear(self)

    if not self._expBarScheduler then
		self._expBarScheduler = scheduler.scheduleGlobal(function()
				if self and self._ccbOwner and self._ccbOwner.sp_exp_bar then
					self:_setExpBarScaleX(self._ccbOwner.sp_exp_bar:getScaleX())
				end
			end, 0)
	end
	self:setInfo()
end

function QUIDialogMonopolyFlowerUpgrade:viewWillDisappear()
  	QUIDialogMonopolyFlowerUpgrade.super.viewWillDisappear(self)

	if self._expBarScheduler then
		scheduler.unscheduleGlobal(self._expBarScheduler)
		self._expBarScheduler = nil
	end
	if self._animationScheduler then
		scheduler.unscheduleGlobal(self._animationScheduler)
		self._animationScheduler = nil
	end
end

function QUIDialogMonopolyFlowerUpgrade:setInfo()
    local addLevel = (self._newImmortalInfo.level or 0) - (self._oldImmortalInfo.level or 0)

	local curConfig = remote.monopoly:getFlowerConfigByIdAndLevel(self._flowerId, self._newImmortalInfo.level)
	local nextConfig = remote.monopoly:getFlowerConfigByIdAndLevel(self._flowerId, self._newImmortalInfo.level + 1)
	local preConfig = remote.monopoly:getFlowerConfigByIdAndLevel(self._flowerId, self._newImmortalInfo.level - 1)
	self._ccbOwner.tf_flowerName:setString(curConfig.name)
	self._ccbOwner.tf_level:setString(self._oldImmortalInfo.level or 1) 

	local isMaxLevel = q.isEmpty(nextConfig)
	--award
	if isMaxLevel then
		self._ccbOwner.tf_yeild_title:setVisible(false)
		local curLuckyDrawConfig = remote.monopoly:getLuckyDrawByKey(curConfig.good)
		self._ccbOwner.tf_output1:setString(math.floor(curLuckyDrawConfig.num_1 * curConfig.num * 60).."/小时")
		self._ccbOwner.tf_output2:setVisible(false)
		self._ccbOwner.tf_yeild_title:setVisible(false)
		self:setWalletIcon(self._ccbOwner.sp_icon, curLuckyDrawConfig)
	else
		self._ccbOwner.node_next_yield:setVisible(true)
		local curLuckyDrawConfig = remote.monopoly:getLuckyDrawByKey(curConfig.good)
		local nextLuckyDrawConfig = remote.monopoly:getLuckyDrawByKey(nextConfig.good)
		self:setWalletIcon(self._ccbOwner.sp_icon, curLuckyDrawConfig)

    	if self._actionType == 1 then
			self._ccbOwner.tf_output1:setString(string.format("%0.1f",(curLuckyDrawConfig.num_1 * curConfig.num * 60)).."/小时")
			self._ccbOwner.tf_output2:setVisible(false)
			self._ccbOwner.tf_yeild_title:setVisible(false)
		else
    		if addLevel > 0 then
				self._ccbOwner.tf_output1:setString(string.format("%0.1f",(curLuckyDrawConfig.num_1 * preConfig.num * 60)).."/小时")
				self._ccbOwner.tf_output2:setString(string.format("%0.1f",(nextLuckyDrawConfig.num_1 * curConfig.num * 60)).."/小时")
    		else
				self._ccbOwner.tf_output1:setString(string.format("%0.1f",(curLuckyDrawConfig.num_1 * curConfig.num * 60)).."/小时")
				self._ccbOwner.tf_output2:setString(string.format("%0.1f",(nextLuckyDrawConfig.num_1 * nextConfig.num * 60)).."/小时")
			end
			self._ccbOwner.tf_output2:setPositionX(93 + self._ccbOwner.tf_output2:getContentSize().width + 24)
		end
	end

	self._ccbOwner.node_achieve:setVisible(false)
	self._ccbOwner.node_level:setVisible(false)
	self._ccbOwner.node_success:setVisible(false)
    if self._actionType == 1 then
    	self._ccbOwner.node_achieve:setVisible(true)
    	self._ccbOwner.node_exp:setVisible(false)
    	self._ccbOwner.node_yeild_cur:setPositionY(70)
    	self._ccbOwner.node_flower_info:setPositionY(-60)
    elseif self._actionType == 2 then
    	if addLevel > 0 then
    		self._ccbOwner.node_level:setVisible(true)
			self._ccbOwner.tf_exp2:setString((curConfig.exp or 0))
    	else
    		self._ccbOwner.node_success:setVisible(true)
			self._ccbOwner.tf_exp2:setString((self._newImmortalInfo.exp or 0))
    	end

		--exp
		self._ccbOwner.tf_exp1:setString(self._oldImmortalInfo.exp or 0)
		local scaleX = (self._newImmortalInfo.exp or 0)/(nextConfig.exp or 0)
		if isMaxLevel then
			self._ccbOwner.tf_exp_desc:setString("(已满级)")
		else
    		if addLevel > 0 then
				self._ccbOwner.tf_exp_desc:setString(string.format("(升级需要%s)", (curConfig.exp or 0)))
    			scaleX = (self._newImmortalInfo.exp or 0)/(curConfig.exp or 0)
    		else
				self._ccbOwner.tf_exp_desc:setString(string.format("(升级需要%s)", (nextConfig.exp or 0)))
			end
		end
		self._ccbOwner.sp_exp_bar:setScaleX((self._oldImmortalInfo.exp or 0)/(nextConfig.exp or 0))
		if addLevel > 0 and isMaxLevel == false then
			self._ccbOwner.sp_exp_bar:setScaleX((self._oldImmortalInfo.exp or 0)/(curConfig.exp or 0))
		end
		self._animationScheduler = scheduler.performWithDelayGlobal(function()
				local time = 0.2
				local array = CCArray:create()
				if addLevel > 0 then
					array:addObject(CCScaleTo:create(time, 1, 1))
					array:addObject(CCCallFunc:create(function()
							if isMaxLevel then
								self._ccbOwner.sp_exp_bar:setScaleX(1)
							else
								self._ccbOwner.sp_exp_bar:setScaleX(0)
							end
						end))
				end
				if isMaxLevel == false then
					array:addObject(CCScaleTo:create(time, scaleX, 1))
				end
				array:addObject(CCCallFunc:create(function()
						self._ccbOwner.tf_level:setString(self._newImmortalInfo.level or 1) 
					end))

				self._ccbOwner.sp_exp_bar:runAction(CCSequence:create(array))
			end, 1)
    end
    self._ccbOwner.plant1:setVisible(self._flowerId == 1)
    self._ccbOwner.plant2:setVisible(self._flowerId == 2)
    self._ccbOwner.plant3:setVisible(self._flowerId == 3)
    self._ccbOwner.plant4:setVisible(self._flowerId == 4)
    self._ccbOwner.plant5:setVisible(self._flowerId == 5)
end

function QUIDialogMonopolyFlowerUpgrade:_setExpBarScaleX()
	local scaleX = self._ccbOwner.sp_exp_bar:getScaleX()
	if scaleX == self._oldScaleX then
		return
	else
		self._oldScaleX = scaleX
	end

	local posX = 0
	local stencil = self._percentBarClippingNode:getStencil()
	if progress == 4 then
		posX = 0
	else
		posX = -self._totalBarWidth + scaleX*self._totalBarWidth
	end
	stencil:setPositionX(posX)
end

function QUIDialogMonopolyFlowerUpgrade:setWalletIcon(sp, config)
	local setIcon = function( path)
		local frame = QSpriteFrameByPath(path)
		if frame then
			sp:setDisplayFrame(frame)
		end
	end

	local resourceConfig = remote.items:getWalletByType(config.type_1)
	if q.isEmpty(resourceConfig) == false then
		setIcon(resourceConfig.alphaIcon)
	else
		local itemInfo = db:getItemByID(config.id_1)
		if itemInfo then
			setIcon(itemInfo.icon_1)
		end
		
	end

end

function QUIDialogMonopolyFlowerUpgrade:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogMonopolyFlowerUpgrade:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogMonopolyFlowerUpgrade
