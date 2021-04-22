--
-- zxs
-- 七日登录
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogActivitySevenDay = class("QUIDialogActivitySevenDay", QUIDialog)

local QUIViewController = import("..QUIViewController")
local QActivity = import("...utils.QActivity")
local QListView = import("...views.QListView")
local QUIWidgetActivitySevenDay = import("..widgets.QUIWidgetActivitySevenDay")
local QUIDialogDynamicValue = import("..dialogs.QUIDialogDynamicValue")

QUIDialogActivitySevenDay.LOGIN_SEVEN = 1
QUIDialogActivitySevenDay.LOGIN_FOURTEEN = 2
QUIDialogActivitySevenDay.LOGIN_SEVEN_SVR = 3
QUIDialogActivitySevenDay.LOGIN_FOURTEEN_SVR = 4

function QUIDialogActivitySevenDay:ctor(options)
    self._callback = options.callback
   	self._loginType = options.loginType or QUIDialogActivitySevenDay.LOGIN_SEVEN
    local ccbFile = "ccb/Dialog_Activity_sevenday_new.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogActivitySevenDay._onTriggerClose)},
        -- {ccbCallbackName = "onTriggerPlay", callback = handler(self, QUIDialogActivitySevenDay._onTriggerPlay)},
    }
    QUIDialogActivitySevenDay.super.ctor(self, ccbFile, callBacks, options)

    self.isAnimation = true --是否动画显示
    self._isGetLocalAwards = false
   	if self._loginType == QUIDialogActivitySevenDay.LOGIN_SEVEN then
   		-- self._loginConfig = db:getEntryRewardConfig(QActivity.TYPE_SEVEN_ENTRY1)
   		self._loginConfig = remote.activity:getEntryRewardConfig(QActivity.TYPE_ACTIVITY_TYPE_1_7_DAY_NEW)
		-- self._totalConfig = db:getEntryRewardConfig(QActivity.TYPE_SEVEN_ENTRY2)
   	else
   		self._loginConfig = remote.activity:getEntryRewardConfig(QActivity.TYPE_ACTIVITY_TYPE_8_14_DAY_NEW)
		-- self._totalConfig = db:getEntryRewardConfig(QActivity.TYPE_FOURTEEN_ENTRY2)
   	end
	if q.isEmpty(self._loginConfig) then
		self._isGetLocalAwards = true
		if self._loginType == QUIDialogActivitySevenDay.LOGIN_SEVEN then
			self._loginConfig = db:getEntryRewardConfig(QActivity.TYPE_SEVEN_ENTRY1)
		else
			self._loginConfig = db:getEntryRewardConfig(QActivity.TYPE_FOURTEEN_ENTRY1)
		end
	end

   	self:_changeHeroCard()
	self:updateSevenData()
end

function QUIDialogActivitySevenDay:viewDidAppear()
    QUIDialogActivitySevenDay.super.viewDidAppear(self)
    self._userEventProxy = cc.EventProxy.new(remote.user)
   	self._userEventProxy:addEventListener(remote.user.EVENT_TIME_REFRESH, handler(self, self.updateSevenData))
end

function QUIDialogActivitySevenDay:viewWillDisappear()
    QUIDialogActivitySevenDay.super.viewWillDisappear(self)
    self._userEventProxy:removeAllEventListeners()
end

function QUIDialogActivitySevenDay:updateSevenData()
	self:_initSevenData()
   	self:_initListView()
end

function QUIDialogActivitySevenDay:_changeHeroCard()
	-- local shadowPath
	if self._loginType == QUIDialogActivitySevenDay.LOGIN_SEVEN then
		local changeIcon, isShowTime , day = remote.activity:checkSevenEntryPageMainViewIcon(remote.activity.TYPE_ACTIVITY_TYPE_1_7_DAY_NEW)
		if changeIcon then

			if day == 2 then

				QSetDisplayFrameByPath(self._ccbOwner.sp_heroImage, "icon/hero_card/art_cnxiaowu.png")
				QSetDisplayFrameByPath(self._ccbOwner.sp_awardInterduce, "ui/update_7_14_activity/sp_words_ciri_Sxiaowu.png")
				self._ccbOwner.sp_heroImage:setScale(0.8)
				self._ccbOwner.sp_heroImage:setPosition(ccp(-362, -105))

			else
				QSetDisplayFrameByPath(self._ccbOwner.sp_heroImage, "icon/hero_card/art_ningrongrong.png")
				QSetDisplayFrameByPath(self._ccbOwner.sp_awardInterduce, "ui/update_7_14_activity/sp_words_wuri_Sningrongrong.png")
				self._ccbOwner.sp_heroImage:setScale(0.8)
				self._ccbOwner.sp_heroImage:setPosition(ccp(-362, -105))
			end

		else
			QSetDisplayFrameByPath(self._ccbOwner.sp_heroImage, "ui/update_7_14_activity/art_pf_xiaowu02.png")
			QSetDisplayFrameByPath(self._ccbOwner.sp_awardInterduce, "ui/update_7_14_activity/sp_words_7ri_yijianzhongxing.png")
			self._ccbOwner.sp_heroImage:setScale(1.1)
			self._ccbOwner.sp_heroImage:setPosition(ccp(-245, 0))
		end
		QSetDisplayFrameByPath(self._ccbOwner.sp_title, "ui/update_7_14_activity/sp_words_denglu7rijiangli.png")
		-- 灰色图改色方案不用了，用直接切图
		-- self._ccbOwner.sp_bg:setColor(ccc3(68, 87, 120))
		QSetDisplayFrameByPath(self._ccbOwner.sp_bg, "ui/update_7_14_activity/sp_bluebg.png")
		self._ccbOwner.tf_denglu_1:setColor(ccc3(166, 178, 211))
		self._ccbOwner.tf_denglu_2:setColor(ccc3(166, 178, 211))

		-- shadowPath = "ui/update_7_14_activity/sp_jianbian_blue.png"
	else
		QSetDisplayFrameByPath(self._ccbOwner.sp_heroImage, "ui/update_7_14_activity/sp_daimubai.png")
		QSetDisplayFrameByPath(self._ccbOwner.sp_awardInterduce, "ui/update_7_14_activity/sp_words_14ri_SSdaimubai.png")
		self._ccbOwner.sp_heroImage:setScale(0.8)
		self._ccbOwner.sp_heroImage:setPosition(ccp(-325, -50))
		QSetDisplayFrameByPath(self._ccbOwner.sp_title, "ui/update_7_14_activity/sp_words_denglu14rijiangli.png")
		-- 灰色图改色方案不用了，用直接切图
		self._ccbOwner.tf_denglu_1:setColor(ccc3(200, 92, 35))
		self._ccbOwner.tf_denglu_2:setColor(ccc3(200, 92, 35))
		QSetDisplayFrameByPath(self._ccbOwner.sp_bg, "ui/update_7_14_activity/sp_yellowbg.png")
		
		-- shadowPath = "ui/update_7_14_activity/sp_jianbian_zi.png"
	end

	--切圖
	local size = self._ccbOwner.sp_heroImage:getContentSize()
	local lyHeroImageMask = CCLayerColor:create(ccc4(0,0,0,150), size.width, size.height)
	local ccclippingNode = CCClippingNode:create()
	lyHeroImageMask:setPositionX(self._ccbOwner.sp_heroImage:getPositionX())
	lyHeroImageMask:setPositionY(-285)
	lyHeroImageMask:ignoreAnchorPointForPosition(false)
	lyHeroImageMask:setAnchorPoint(ccp(0.5, 0))
	ccclippingNode:setStencil(lyHeroImageMask)
	self._ccbOwner.sp_heroImage:retain()
	self._ccbOwner.sp_heroImage:removeFromParent()
	ccclippingNode:addChild(self._ccbOwner.sp_heroImage)
	self._ccbOwner.node_heroImage:addChild(ccclippingNode)
	self._ccbOwner.sp_heroImage:release()

	--生成漸變條
	-- if shadowPath then
	-- 	self._topShadow = CCScale9Sprite:create(shadowPath)
	-- 	self._bottomShadow = CCScale9Sprite:create(shadowPath)
	-- 	local height = self._ccbOwner.sheet_layout:getContentSize().height
	-- 	local width = self._ccbOwner.sheet_layout:getContentSize().width
	-- 	if self._topShadow then
	-- 		self._topShadow:setAnchorPoint(ccp(1, 0))
 --            self._topShadow:setRotation(180)
 --            self._topShadow:setPosition(ccp(0, height))
 --            self._topShadow:setPreferredSize(CCSize(width, 18))
 --            self._ccbOwner.sheet_layout:getParent():addChild(self._topShadow)
 --            self._topShadow:setPosition(ccp(self._ccbOwner.sheet_layout:getPositionX(), self._ccbOwner.sheet_layout:getPositionY() + height))
	-- 		self._topShadow:setVisible(false)
	-- 	end
	-- 	if self._bottomShadow then
	-- 		self._bottomShadow:setAnchorPoint(ccp(0, 0))
 --            self._bottomShadow:setRotation(0)
 --            self._bottomShadow:setPosition(ccp(0, 0))
 --            self._bottomShadow:setPreferredSize(CCSize(width, 18))
 --            self._ccbOwner.sheet_layout:getParent():addChild(self._bottomShadow)
	-- 		self._bottomShadow:setPosition(self._ccbOwner.sheet_layout:getPosition())
	-- 		self._bottomShadow:setVisible(false)
	-- 	end
	-- end
end

function QUIDialogActivitySevenDay:_initSevenData()
	local recivedAwards = remote.user.gotEnterRewards or {}
	local loginDaysCount = remote.user.loginDaysCount or 0
	if loginDaysCount == 0 then
		loginDaysCount = 1
	end
	self._loginReward = {}

	local checkFunc
	checkFunc = function(targetInfo)
		if self._isGetLocalAwards then
			for _, value in pairs(recivedAwards) do
				if value == targetInfo.activityTargetId then
					return true
				end
			end
		else
			local isGet = remote.activity:checkCompleteByTargetId(targetInfo)
			return isGet 
		end
		return false
	end

	for i, entryDay in pairs(self._loginConfig) do
		local info = clone(entryDay)
		local isGet = checkFunc(entryDay)
		local isComplete = loginDaysCount >= entryDay.value
		info.isGet = isGet
		info.isComplete = isComplete
		self._loginReward[#self._loginReward+1] = info
	end

	-- for i, entryDay in pairs(self._totalConfig) do
	-- 	local info = clone(entryDay)
	-- 	local isGet = checkFunc(entryDay.activityTargetId)
	-- 	local isComplete = loginDaysCount >= entryDay.value
	-- 	info.isGet = isGet
	-- 	info.isComplete = isComplete
	-- 	local awardsTbl = remote.items:analysisServerItem(entryDay.awards)
	-- 	info.awards = awardsTbl[1]
	-- end

	table.sort( self._loginReward, function(a, b)
			if a.isGet ~= b.isGet then
				return b.isGet
			end
			return a.index < b.index
		end)

	self._ccbOwner.tf_day:setString(loginDaysCount)
end

function QUIDialogActivitySevenDay:_initListView()
	local targetIndex = 1
	for i, v in ipairs(self._loginReward) do
		if v.isComplete and not v.isGet then
			targetIndex = i
			break
		end
	end
	if not self._listView then
	    local cfg = {
	        renderItemCallBack = handler(self, self.renderItemHandler),
	        headIndex = targetIndex,
	        enableShadow = false,
	        ignoreCanDrag = true,
	        spaceY = 4,
	        -- topShadow = self._topShadow,
	        -- bottomShadow = self._bottomShadow,
	        totalNumber = #self._loginReward,
	    }  
	    self._listView = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else
		self._listView:reload({totalNumber = #self._loginReward, headIndex = targetIndex})
	end
end

function QUIDialogActivitySevenDay:getContentListView()
	return self._listView
end

function QUIDialogActivitySevenDay:renderItemHandler(list, index, info )
    local isCacheNode = true
    local itemData = self._loginReward[index]
    local item = list:getItemFromCache()
    if not item then
    	item = QUIWidgetActivitySevenDay.new()
        isCacheNode = false
    end

    item:setIsSevenDay(self._loginType)
    item:setInfo(itemData, self,self._isGetLocalAwards)
    
    info.item = item
    info.size = item:getContentSize()

    list:registerBtnHandler(index, "btn_get", handler(self, self._onTriggerConfirm), nil, true)
	list:registerTouchHandler(index, "onTouchListView")

    return isCacheNode
end

function QUIDialogActivitySevenDay:_onTriggerConfirm( x, y, touchNode, listView )
	app.sound:playSound("common_switch")
    local touchIndex = listView:getCurTouchIndex()
    local item = listView:getItemByIndex(touchIndex)
    if item then
    	local itemData = self._loginReward[touchIndex]
		if remote.user.loginDaysCount ~= 0 and (remote.user.loginDaysCount + 1) == itemData.value then
			app.tip:floatTip("明日上线即可领取精彩福利，千万不要错过呦！")
			return
		end
		if not itemData.isComplete then
			app.tip:floatTip("暂未达到领取条件！")
			return			
		end
    	local activityId = itemData.activityId
    	local activityTargetId = itemData.activityTargetId
    	if self._isGetLocalAwards then
        	app:getClient():getSevenLoginEntryActivityReward(activityTargetId, self:safeHandler(function(data)
	  			local awards = data.prizes or {}
	            local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert", options = {awards = awards,callBack = function()
	            	self:_checkBombFace(self._loginType,itemData.value)
	            	self:_changeHeroCard()
	            end}},{isPopCurrentDialog = false} )
	            dialog:setTitle("恭喜获得奖励")
	            remote.activity:dispatchEvent({name = QActivity.EVENT_CHANGE})
		  		self:updateSevenData()
			end))
    	else
	       app:getClient():activityCompleteRequest(activityId, activityTargetId, nil, nil,self:safeHandler(function(data)
	  			local awards = self:switchAwards(itemData.awards)
	  			QPrintTable(awards)
	            local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert", options = {awards = awards,callBack = function()
	            	self:_checkBombFace(self._loginType,itemData.value)
	            	self:_changeHeroCard()
	            end}},{isPopCurrentDialog = false} )
	            dialog:setTitle("恭喜获得奖励")
	            remote.activity:dispatchEvent({name = QActivity.EVENT_CHANGE})
	            remote.activity:setCompleteDataById(activityId, activityTargetId)
		  		self:updateSevenData()
			end))    		
    	end
    end
end

function QUIDialogActivitySevenDay:switchAwards(awardsInfo)
	local awards = {}
    local awardsTbl = string.split(awardsInfo, ";")
    for i, v in pairs(awardsTbl) do
        if v ~= "" then
            local reward = string.split(v, "^")
            local itemType = ITEM_TYPE.ITEM
            if tonumber(reward[1]) == nil then
                itemType = remote.items:getItemType(reward[1])
            end
            table.insert(awards, {id = reward[1], typeName = itemType, count = tonumber(reward[2]),specialAwards = specialAwards})
        end
    end
    return awards
end
function QUIDialogActivitySevenDay:_checkBombFace(loginType,day)
	if loginType == QUIDialogActivitySevenDay.LOGIN_SEVEN then
		-- if remote.user.loginDaysCount == 1 and day == 1 then  --弹胡列娜
		-- 	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogDynamicValue", options = {heroName = QUIDialogDynamicValue.HERO_HULIENA}})
		-- elseif remote.user.loginDaysCount == 2 and day == 2 then -- 弹唐三
		-- 	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogDynamicValue", options = {heroName = QUIDialogDynamicValue.HERO_TANGSAN}})
		-- end
		if remote.user.loginDaysCount == 1 and day == 1 then  --弹小舞
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogDynamicValue", options = {heroName = QUIDialogDynamicValue.HERO_XIAOWU}})
		elseif remote.user.loginDaysCount == 2 and day == 2 then -- 弹宁荣荣
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogDynamicValue", options = {heroName = QUIDialogDynamicValue.HERO_NINGRONGRONG}})
		elseif remote.user.loginDaysCount == 5 and day == 5 then -- 弹宋轶
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogDynamicValue", options = {heroName = QUIDialogDynamicValue.HERO_SONGYI}})
		end
	end
end

function QUIDialogActivitySevenDay:_backClickHandler()
    self:playEffectOut()
end

function QUIDialogActivitySevenDay:_onTriggerClose(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_close) == false then return end
	app.sound:playSound("common_cancel")
    self:playEffectOut()
end

function QUIDialogActivitySevenDay:viewAnimationOutHandler()
	self:popSelf()
	if self._callback then
    	self._callback()
    end
end

function QUIDialogActivitySevenDay:_onGetReward(event)
	local info = event.info
	if not info then
		return
	end
	local activityTargetId = info.activityTargetId
    app:getClient():getSevenLoginEntryActivityReward(activityTargetId, function(data)
  		local awards = data.prizes or {}
  		app:alertAwards({awards = awards})
  		
    	remote.activity:dispatchEvent({name = QActivity.EVENT_CHANGE})
  		if self:safeCheck() then
			self:updateSevenData()
  		end
  	end)
end

-- function QUIDialogActivitySevenDay:_onTriggerPlay()
-- 	local bossId = 1007
-- 	local enemyTips = 1001
-- 	if self._loginType == QUIDialogActivitySevenDay.LOGIN_FOURTEEN then
-- 		bossId = 1016
-- 		enemyTips = 1002
-- 	end

-- 	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBossIntroduce",
-- 		options = {bossId = bossId, enemyTips = enemyTips}})
-- end

return QUIDialogActivitySevenDay
