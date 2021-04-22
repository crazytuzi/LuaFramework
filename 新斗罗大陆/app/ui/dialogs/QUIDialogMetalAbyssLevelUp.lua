--金属深渊探索等级升级
--qsy


local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMetalAbyssLevelUp = class("QUIDialogMetalAbyssLevelUp", QUIDialog)
local QUIWidgetItemsBox = import("....widgets.QUIWidgetItemsBox")

function QUIDialogMetalAbyssLevelUp:ctor(options)
	local ccbFile = "ccb/Dialog_MetalAbyss_LevelUp.ccbi"
	local callBacks = {}
	QUIDialogMetalAbyssLevelUp.super.ctor(self,ccbFile,callBacks,options)

    self.isAnimation = true --是否动画显示
	app.sound:playSound("hero_breakthrough")

    self._animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
    self._animationManager:runAnimationsForSequenceNamed("1")
    self._animationManager:connectScriptHandler(handler(self, self.animationEndHandler))

	if options then
		self._callBack = options.callBack
	end

	self._userInfo = remote.metalAbyss:getAbyssUserInfo()


	if not self._userInfo then 
		self._isEnd = true
		return 
	end
	

	local curStar = self._userInfo.totalStarCount or 0
    local curLevelConfig = remote.metalAbyss:getLevelInfoByExp(curStar)
	if not curLevelConfig  then 
		self._isEnd = true
		return 
	end
    local beforeLevelConfig = remote.metalAbyss:getLevelInfoByExpLevel(curLevelConfig.lev - 1)
	if not beforeLevelConfig then 
		self._isEnd = true
		return 
	end


	self._ccbOwner.new_prop_1:setString(curLevelConfig.lev)
	self._ccbOwner.old_prop_1:setString(beforeLevelConfig.lev)
    self._ccbOwner.new_prop_2:setString("+"..(curLevelConfig.reward_coefficient* 100).."%")
    self._ccbOwner.old_prop_2:setString("+"..(beforeLevelConfig.reward_coefficient* 100).."%")


	local rewards = remote.metalAbyss:getAbyssLevelUpReward()
	local awards = {}
	awards = remote.items:analysisServerItem(rewards, awards)
	if not q.isEmpty(awards) then
		local data = awards[1]
		local itemIcon = QUIWidgetItemsBox.new()
		itemIcon:setPromptIsOpen(true)
		itemIcon:setGoodsInfo(data.id or 0 ,data.typeName ,data.count)
		self._ccbOwner.node_prize:addChild(itemIcon)
	end
	remote.metalAbyss:setAbyssLevelUpReward("")
end


function QUIDialogMetalAbyssLevelUp:viewWillDisappear()
	QUIDialogMetalAbyssLevelUp.super.viewWillDisappear(self)
	
	if self._scheduler then
		scheduler.unscheduleGlobal(self._scheduler)
		self._scheduler = nil
	end

end

function QUIDialogMetalAbyssLevelUp:animationEndHandler(name)
	self._animationStage = name
end


function QUIDialogMetalAbyssLevelUp:_onTriggerClose()
	if self._isEnd == true then
		if self._callBack ~= nil then
			self._callBack()
		end
		if self._scheduler then
			scheduler.unscheduleGlobal(self._scheduler)
			self._scheduler = nil
		end

		self:playEffectOut()
	else
		if self._animationStage == nil then
			self._animationStage = "1"
			self._animationManager:runAnimationsForSequenceNamed("2")
		elseif self._animationStage == "1" then
			return
		else
			scheduler.performWithDelayGlobal(function()
					self._isEnd = true
				end, 1)
		end
	end
end

function QUIDialogMetalAbyssLevelUp:_backClickHandler()
	self:_onTriggerClose()
end

return QUIDialogMetalAbyssLevelUp