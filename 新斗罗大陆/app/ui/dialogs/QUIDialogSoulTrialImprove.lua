local QUIDialog = import(".QUIDialog")
local QUIDialogSoulTrialImprove = class("QUIDialogSoulTrialImprove", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QUIWidgetTitelEffect = import("..widgets.QUIWidgetTitelEffect")

function QUIDialogSoulTrialImprove:ctor(options)
	local ccbFile = "ccb/Dialog_SoulTrial_Improve.ccbi"
	local callBacks = {}
	QUIDialogSoulTrialImprove.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true --是否动画显示
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page.topBar:setAllSound(false)

	local titleWidget = QUIWidgetTitelEffect.new()
	self._ccbOwner.node_title_effect:addChild(titleWidget)
	
	-- 头像
	self._ccbOwner.tf_avatarNameOld:setString(options.preConfig.title_name or "无")
	local avatar1 = QUIWidgetAvatar.new(remote.user.avatar)
	avatar1:setSilvesArenaPeak(remote.user.championCount)
    self._ccbOwner.node_avatar_old:addChild(avatar1)

	self._ccbOwner.tf_avatarNameNew:setString(options.config.title_name or "")
    local avatar2 = QUIWidgetAvatar.new(remote.user.avatar)
    avatar2:setSilvesArenaPeak(remote.user.championCount)
    self._ccbOwner.node_avatar_new:addChild(avatar2)

	if options.config and options.config.title_icon1 and options.config.title_icon2 then
		local kuang = CCSprite:create(options.config.title_icon2)
		if kuang then
			self._ccbOwner.node_soulTrial_title:addChild(kuang)
		end
		local sprite = CCSprite:create(options.config.title_icon1)
		if sprite then
			self._ccbOwner.node_soulTrial_title:addChild(sprite)
		end
	end

	if options.config and options.preConfig then
		self._ccbOwner.node_value_all:setVisible(true)
		self._ccbOwner.node_value_all:setPositionY(0)
		local tbl = remote.soulTrial:getImproveProp(options.config, options.preConfig)
		-- QPrintTable(tbl)
		local index = 1
		local isMove = false
		while true do
			local isFind = false
			local node = self._ccbOwner["node_value_"..index]
			if node then
				node:setVisible(false)
				isFind = true
			end

			if tbl[index] then
				node = self._ccbOwner["tf_valueName_"..index]
				if node then
					node:setString(tbl[index].name.."：")
				end

				node = self._ccbOwner["tf_valueOld_"..index]
				if node then
					node:setString(tbl[index].oldValue or 0)
				end

				node = self._ccbOwner["tf_valueNew_"..index]
				if node then
					node:setString(tbl[index].newValue or 0)
				end

				node = self._ccbOwner["node_value_"..index]
				if node then
					node:setVisible(true)
				end
			else
				if not isMove then
					isMove = true
					if index == 3 then
						self._ccbOwner.node_value_all:setPositionY(-55)
					elseif index == 4 then
						self._ccbOwner.node_value_all:setPositionY(-35)
					end
				end
			end

			if isFind then
				index = index + 1
			else
				break
			end
		end
	end
	self._isEnd = false
	self._animationStart = "1"
	self._animationEnd = nil
	self._animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
	self._animationManager:runAnimationsForSequenceNamed(self._animationStart)
	self._animationManager:connectScriptHandler(handler(self, self.viewAnimationEndHandler))
end

function QUIDialogSoulTrialImprove:viewAnimationEndHandler(name)
	print(" QUIDialogSoulTrialImprove:viewAnimationEndHandler() ", name)
	self._animationEnd = name
	if self._animationEnd == "1" then
		self._animationStart = "2"
		self._animationManager:runAnimationsForSequenceNamed(self._animationStart)
	elseif self._animationEnd == "3" then
		self._animationStart = "4"
		self._animationManager:runAnimationsForSequenceNamed(self._animationStart)
		self._isEnd = true
		self._animationManager:disconnectScriptHandler()
	end
end

function QUIDialogSoulTrialImprove:viewDidAppear()
	QUIDialogSoulTrialImprove.super.viewDidAppear(self)
end 

function QUIDialogSoulTrialImprove:viewWillDisappear()
	QUIDialogSoulTrialImprove.super.viewWillDisappear(self)
end 

function QUIDialogSoulTrialImprove:_backClickHandler()
	print(" QUIDialogSoulTrialImprove:_backClickHandler() ", self._animationStart, self._animationEnd)
	if not self._animationEnd then
		-- 1还没播放完，直接跳到2，2是1的静止状态
		self._animationStart = "2"
		self._animationManager:runAnimationsForSequenceNamed(self._animationStart)
	elseif self._animationEnd == "1" and self._animationStart == "1" then
		-- 1播放完，直接播放2
		self._animationStart = "3"
		self._animationManager:runAnimationsForSequenceNamed(self._animationStart)
	elseif self._animationEnd == "3" or self._animationEnd == "4" then
		-- 3或4播放完，全部结束
		self._isEnd = true
	elseif self._animationEnd == "2"  and self._animationStart == "2" then
		-- 1已经被跳过（放完）
		self._animationStart = "3"
		self._animationManager:runAnimationsForSequenceNamed(self._animationStart)
	elseif self._animationStart == "3" then
		-- 2还没播放完，直接跳到4，4是2的静止状态
		self._animationStart = "4"
		self._animationManager:runAnimationsForSequenceNamed(self._animationStart)
	end

	if self._isEnd then
		self:_onTriggerClose()
	end
end

function QUIDialogSoulTrialImprove:_onTriggerClose()
	app.sound:playSound("common_cancel")
   	self:playEffectOut()
end

function QUIDialogSoulTrialImprove:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogSoulTrialImprove
