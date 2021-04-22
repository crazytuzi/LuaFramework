--
-- Kumo.Wang
-- zhangbichen主题曲活动——结算界面
--

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogZhangbichenMusicGameEnd = class("QUIDialogZhangbichenMusicGameEnd", QUIDialog)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIDialogZhangbichenMusicGameEnd:ctor(options) 
 	local ccbFile = "ccb/Dialog_Music_Game_End.ccbi"
	local callBacks = {
	    {ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
	    {ccbCallbackName = "onTriggerAbort", callback = handler(self, self._onTriggerAbort)},
	}
	QUIDialogZhangbichenMusicGameEnd.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = false
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page then
	    if page.setAllUIVisible then page:setAllUIVisible(false) end
	    if page.setScalingVisible then page:setScalingVisible(false) end
	    if page.topBar then page.topBar:hideAll() end
		if page.setBackBtnVisible then page:setBackBtnVisible(false) end
		if page.setHomeBtnVisible then page:setHomeBtnVisible(false) end
	end
	
	CalculateUIBgSize(self._ccbOwner.sp_bg)

	self._zhangbichenModel = remote.activityRounds:getZhangbichen()
	if not self._zhangbichenModel then
		self._isEnd = true 
	else
		q.setButtonEnableShadow(self._ccbOwner.btn_abort)
	    q.setButtonEnableShadow(self._ccbOwner.btn_ok)
		if options then
			self._callback = options.callback
			self._scoreLevel = tonumber(options.scoreLevel) or 0
			self._combo = tonumber(options.combo) or 0
			self._perfect = tonumber(options.perfect) or 0
			self._great = tonumber(options.great) or 0
			self._good = tonumber(options.good) or 0
			self._bad = tonumber(options.bad) or 0
			self._miss = tonumber(options.miss) or 0
			self._none = tonumber(options.none) or 0
		end

		self._ccbOwner.pingzhi_a:setVisible(false)
		self._ccbOwner.pingzhi_b:setVisible(false)
		self._ccbOwner.pingzhi_c:setVisible(false)
		self._ccbOwner["pingzhi_a+"]:setVisible(false)
		self._ccbOwner.pingzhi_s:setVisible(false)
		self._ccbOwner.pingzhi_ss:setVisible(false)
		self._ccbOwner["pingzhi_ss+"]:setVisible(false)
		if self._scoreLevel == 4 then
			self._ccbOwner.pingzhi_ss:setVisible(true)
		elseif self._scoreLevel == 3 then
			self._ccbOwner.pingzhi_s:setVisible(true)
		elseif self._scoreLevel == 2 then
			self._ccbOwner.pingzhi_a:setVisible(true)
		elseif self._scoreLevel == 1 then
			self._ccbOwner.pingzhi_b:setVisible(true)
		else
			self._ccbOwner.pingzhi_c:setVisible(true)
		end

		if self._ccbOwner.tf_combo then
			self._ccbOwner.tf_combo:setString(self._combo)
		end
		if self._ccbOwner.tf_perfect then
			self._ccbOwner.tf_perfect:setString(self._perfect)
		end
		if self._ccbOwner.tf_great then
			self._ccbOwner.tf_great:setString(self._great)
		end
		if self._ccbOwner.tf_good then
			self._ccbOwner.tf_good:setString(self._good)
		end
		if self._ccbOwner.tf_bad then
			self._ccbOwner.tf_bad:setString(self._bad)
		end
		if self._ccbOwner.tf_miss then
			self._ccbOwner.tf_miss:setString(self._miss + self._none)
		end

		local gameConfig = self._zhangbichenModel:getGameConfig()
		local rewardStr = gameConfig["reward_"..self._scoreLevel]
		self._ccbOwner.node_item:removeAllChildren()
		if rewardStr then
			local tbl = string.split(rewardStr, "^")
			if tbl and #tbl > 0 then
				local id = tonumber(tbl[1])
				local count = tonumber(tbl[2])
				local itembox = QUIWidgetItemsBox.new()
				if id then
					itembox:setGoodsInfo(id, ITEM_TYPE.ITEM, count)
				else
					itembox:setGoodsInfo(nil, tbl[1], count)
				end
				self._ccbOwner.node_item:addChild(itembox)
			end
		end

		if self._ccbOwner.pingzhi_c:isVisible() then
			self._ccbOwner.node_btn_ok:setVisible(false)
			self._ccbOwner.node_btn_abort:setPositionX(0)
			self._ccbOwner.tf_btn_abort:setString("再试一次")
		else
			self._ccbOwner.node_btn_ok:setVisible(true)
			self._ccbOwner.node_btn_abort:setPositionX(-80)
			self._ccbOwner.tf_btn_abort:setString("放弃领取")

			-- local serverInfo = self._zhangbichenModel:getServerInfo()
			-- if not self._zhangbichenModel.isActivityNotEnd then
			-- 	makeNodeFromNormalToGray(self._ccbOwner.node_btn_ok)
			-- 	self._ccbOwner.tf_btn_ok:disableOutline()
			-- elseif serverInfo.remainCount and serverInfo.remainCount <= 0 then
			-- 	makeNodeFromNormalToGray(self._ccbOwner.node_btn_ok)
			-- 	self._ccbOwner.tf_btn_ok:disableOutline()
			-- else
			-- 	makeNodeFromGrayToNormal(self._ccbOwner.node_btn_ok)
			-- 	self._ccbOwner.tf_btn_ok:enableOutline()
			-- end
		end

		self._chooseType = 1 -- 1，退出游戏；2，重新开始
	end

	self:setMvpActorId()
	app.sound:playSound("battle_complete")
end

function QUIDialogZhangbichenMusicGameEnd:setMvpActorId()
	local skinId = 71
	
	local card = "icon/hero_card/art_snts.png"
	local x = 0
	local y = 0
	local scale = 1
	local rotation = 0
	local turn = 1
	local cheerDialog
	local skinConfig = db:getHeroSkinConfigByID(skinId)

	if not self._skipLocal and not self._isCollegeTrain then
        if skinConfig.fightEnd_card then
        	card = skinConfig.fightEnd_card
			if skinConfig.fightEnd_display then
				local skinDisplaySetConfig = remote.heroSkin:getSkinDisplaySetConfigById(skinConfig.fightEnd_display)
				x = skinDisplaySetConfig.x or 0
				y = skinDisplaySetConfig.y or 0
				scale = skinDisplaySetConfig.scale or 1
				rotation = skinDisplaySetConfig.rotation or 0
				turn = skinDisplaySetConfig.isturn or 1
			end
        end
        cheerDialog = skinConfig.cheer_dialog
	end

	local frame = QSpriteFrameByPath(card)
	if frame then
		self._ccbOwner.sp_bg_mvp:setDisplayFrame(frame)
		self._ccbOwner.sp_bg_mvp:setPosition(x, y)
		self._ccbOwner.sp_bg_mvp:setScaleX(scale*turn)
		self._ccbOwner.sp_bg_mvp:setScaleY(scale)
		self._ccbOwner.sp_bg_mvp:setRotation(rotation)
	else
		assert(false, "<<<"..card..">>>not exist!")
	end

	if not cheerDialog then
        cheerDialog = info.cheer_dialog
    end
    if cheerDialog then
		self._ccbOwner.tf_hero_tip:setString(cheerDialog)
		self._ccbOwner.node_hero_tip:setVisible(true)
	else
		self._ccbOwner.node_hero_tip:setVisible(false)
	end

	local info = db:getCharacterByID(tostring(skinConfig.character_id))
	self._ccbOwner.label_name_title:setString(info.title or "")
	self._ccbOwner.label_name:setString(info.name or "")
end

function QUIDialogZhangbichenMusicGameEnd:viewAnimationInHandler()
end

function QUIDialogZhangbichenMusicGameEnd:viewDidAppear()
    QUIDialogZhangbichenMusicGameEnd.super.viewDidAppear(self)
    if self._isEnd then
    	self:playEffectOut()
    end
end

function QUIDialogZhangbichenMusicGameEnd:viewAnimationOutHandler()
	self:popSelf()

	if self._callback then
		self._callback(self._chooseType)
	end
end

function QUIDialogZhangbichenMusicGameEnd:viewWillDisappear()
    QUIDialogZhangbichenMusicGameEnd.super.viewWillDisappear(self)
end

function QUIDialogZhangbichenMusicGameEnd:_onTriggerOK(e)
    app.sound:playSound("common_small")

    self._chooseType = 1
    local serverInfo = self._zhangbichenModel:getServerInfo()
	if not self._zhangbichenModel.isActivityNotEnd then
		app.tip:floatTip("活动已结束")
    	self:playEffectOut()
	elseif serverInfo.remainCount and serverInfo.remainCount <= 0 then
		app.tip:floatTip("没有剩余领奖次数，无法获得任何奖励")
    	self:playEffectOut()
	else
		-- 确定，领奖
		if self._zhangbichenModel and self._scoreLevel > 0 then
			self._zhangbichenModel:zhangbichenPreheatExpectRequest(tonumber(self._scoreLevel), function()
				if self:safeCheck() then
			  		self:playEffectOut()
				end
			end)
		end
	end
end

function QUIDialogZhangbichenMusicGameEnd:_onTriggerAbort(e)
    app.sound:playSound("common_small")
    if self._ccbOwner.pingzhi_c:isVisible() then
    	self._chooseType = 2
    else
    	self._chooseType = 1
    end
	self:playEffectOut()
end

return QUIDialogZhangbichenMusicGameEnd