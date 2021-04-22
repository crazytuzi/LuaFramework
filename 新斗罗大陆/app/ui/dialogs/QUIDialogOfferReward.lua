--悬赏任务主界面
--qinsiyang

local QUIDialog = import(".QUIDialog")
local QUIDialogOfferReward = class("QUIDialogOfferReward", QUIDialog)
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QListView = import("...views.QListView")
local QUIWidgetOfferRewardTask = import("..widgets.QUIWidgetOfferRewardTask")
local QQuickWay = import("...utils.QQuickWay")

function QUIDialogOfferReward:ctor(options)
	local ccbFile = "ccb/Dialog_OfferReward.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerBorrow", callback = handler(self, self._onTriggerBorrow)},
		{ccbCallbackName = "onTriggerHelp", callback = handler(self, self._onTriggerHelp)},
		{ccbCallbackName = "onTriggerClickHelpLevel", callback = handler(self, self._onTriggerClickHelpLevel)},
		{ccbCallbackName = "onTriggerRefresh", callback = handler(self, self._onTriggerRefresh)},
		{ccbCallbackName = "onTriggerGetAllAward", callback = handler(self, self._onTriggerGetAllAward)},
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogOfferReward.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._callback = options.callback

    q.setButtonEnableShadow(self._ccbOwner.btn_help)
    q.setButtonEnableShadow(self._ccbOwner.btn_borrow)
    q.setButtonEnableShadow(self._ccbOwner.btn_refresh)
    q.setButtonEnableShadow(self._ccbOwner.btn_helpLevel)
    q.setButtonEnableShadow(self._ccbOwner.frame_btn_close)
    q.setButtonEnableShadow(self._ccbOwner.btn_get_all_award)

    self._totalBarWidth = self._ccbOwner.sp_bar_progress:getContentSize().width * self._ccbOwner.sp_bar_progress:getScaleX()
    self._totalBarPosX = self._ccbOwner.sp_bar_progress:getPositionX()
	self._percentBarClippingNode = q.newPercentBarClippingNode(self._ccbOwner.sp_bar_progress)

	self:refreshData()
	self:_setInfo()
	self:initTaskListView()
	self:_updateRedTips()
	self:_checkOtherBorrowMe()
end

function QUIDialogOfferReward:_updateRedTips()
	local count = remote.offerreward:getBorrowInfosCountNum()
	self._ccbOwner.sp_borrow_tips:setVisible(count > 0)
end

function QUIDialogOfferReward:viewDidAppear()
	QUIDialogOfferReward.super.viewDidAppear(self)
    self._taskProxy = cc.EventProxy.new(remote.offerreward)
    self._taskProxy:addEventListener(remote.offerreward.EVENT_REFRESH, handler(self, self._taskInfoUpdate))
end

function QUIDialogOfferReward:viewAnimationInHandler()
	--代码
	self:initTaskListView()
end


function QUIDialogOfferReward:viewWillDisappear()
	QUIDialogOfferReward.super.viewWillDisappear(self)
    self._taskProxy:removeAllEventListeners()
	-- local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	-- if page and page.setHomeBtnVisible then page:setHomeBtnVisible(false) end
 --    if page and page.topBar and page.topBar.hideAll then
 --        page.topBar:hideAll()
 --    end
end


function QUIDialogOfferReward:_taskInfoUpdate()
	print("QUIDialogOfferReward:_taskInfoUpdate")
	self:refreshData()
	self:_setInfo()
	self:initTaskListView()
end


function QUIDialogOfferReward:_setInfo()
	self._myInfos =remote.offerreward:getMyInfo()
    self._ccbOwner.tf_title:setString("魂师派遣")

    self._ccbOwner.tf_level:setString(self._myInfos.level or 1) -- 当前悬赏任务等级
    -- 悬赏任务刷新消耗


    local cur_score , totalScore = remote.offerreward:getCurProgressNum()

	local stencil = self._percentBarClippingNode:getStencil()
	-- local cur_score = 0
	-- local totalScore = 100
	local posX = 0
	if totalScore ~= nil then
		posX = -self._totalBarWidth + cur_score / totalScore * self._totalBarWidth
		self._ccbOwner.tf_max_progress:setVisible(false)
	else
		self._ccbOwner.tf_max_progress:setVisible(true)
	end 


	stencil:setPositionX(posX)

	local refreshNum = 0
	for k,v in pairs(self._items) do
		if v.isStart == false then
			refreshNum = refreshNum + 1
		end
	end
	local costNum = refreshNum * tonumber(remote.offerreward:getRefreshNum())
	self._ccbOwner.tf_price:setString(costNum)
	local remainingTimes = remote.offerreward:getRemainingRefreshNum()
	self._ccbOwner.tf_refresh_count:setString(remainingTimes.."次")
end

function QUIDialogOfferReward:refreshData()
	local _data = remote.offerreward:getDispatchInfo()
	self._items = {}
	local not_start = {}
	local not_finish = {}
	local currTime = q.serverTime()
	for k,v in pairs(_data or {}) do
		if v.getReward == false then
			if v.isStart == false then
				table.insert(not_start ,  v)
			else
				local offer_reward = remote.offerreward:getOfferRewardTaskById(v.taskId)
				local time_cd = tonumber(offer_reward.time) * 60
				local _startAt = v.startAt or 0
				local endTime = _startAt / 1000
				endTime = endTime + time_cd
				if endTime > currTime then 
					table.insert(not_finish ,  v)
				else
					table.insert(self._items ,  v)
				end
			end
		end
	end
	for k,v in pairs(not_start) do
		table.insert(self._items ,  v)
	end
	for k,v in pairs(not_finish) do
		table.insert(self._items ,  v)
	end

	-- QPrintTable(self._items)
end

function QUIDialogOfferReward:initTaskListView()
	if self._listViewLayout then
		self._listViewLayout:setContentSize(self._ccbOwner.sheet_content:getContentSize())
		self._listViewLayout:resetTouchRect()
	end
	self._ccbOwner.node_no:setVisible(not next(self._items))
	
	if not self._listViewLayout then
		local cfg = {
			renderItemCallBack = handler(self, self._renderTaskCallBack),
	        curOriginOffset = 7,
	        contentOffsetX = 0,
	        curOffset = 0,
	        enableShadow = false,
	      	ignoreCanDrag = true,
	      	spaceY = 0,
	      	spaceX = 10,
	      	isVertical = false,
	        totalNumber = #self._items,
		}
		self._listViewLayout = QListView.new(self._ccbOwner.sheet_content,cfg)
	else
		self._listViewLayout:reload({totalNumber = #self._items})
	end
end

function QUIDialogOfferReward:taskClickGetHandler(event)
	local info = event.info
	if not info then
		return
	end
	remote.offerreward:offerRewardGetRewardRequest({info.dispatchId},function(data)
		local awards = data.prizes or {}
  		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
    		options = {awards = awards, callBack = function ()
    		end}},{isPopCurrentDialog = false} )
    	dialog:setTitle("恭喜您获得魂师派遣任务奖励")
		end,function(  )
			-- body
		end)
end

function QUIDialogOfferReward:taskClickOKHandler(event)
	local info = event.info
	if not info then
		return
	end
    app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogOfferRewardDispatch", 
        options = {taskId = info.taskId ,dispatchId = info.dispatchId }}, {isPopCurrentDialog = true})
end

function QUIDialogOfferReward:_renderTaskCallBack(list, index, info )
    local isCacheNode = true
    local itemData = self._items[index]
    local item = list:getItemFromCache()
    if not item then
		item = QUIWidgetOfferRewardTask.new()
		item:addEventListener(QUIWidgetOfferRewardTask.EVENT_GET_REWARD, handler(self,self.taskClickGetHandler))
		item:addEventListener(QUIWidgetOfferRewardTask.EVENT_CLICK, handler(self, self.taskClickOKHandler))
    	isCacheNode = false
    end
    item:setInfo(itemData)
    info.item = item
    info.size = item:getContentSize()
    list:registerTouchHandler(index, "onTouchListView")
    list:registerBtnHandler(index, "btn_get", "_onTriggerGet", nil, "true")
    list:registerBtnHandler(index, "btn_ok", "_onTriggerOK", nil, "true")
    return isCacheNode
end

function QUIDialogOfferReward:_checkOtherBorrowMe()
	remote.userDynamic:openDynamicDialog(8, function(isConfirm)
			if self:safeCheck() then
				if isConfirm then
				end
			end
		end)
end

function QUIDialogOfferReward:_onTriggerBorrow(event)
    app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroBorrow", 
        options = {}}, {isPopCurrentDialog = true})
end

function QUIDialogOfferReward:_onTriggerHelp(event)
    app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogOfferRewardHelp", 
        options = {}}, {isPopCurrentDialog = true})
end

function QUIDialogOfferReward:_onTriggerClickHelpLevel(event)
    app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogOfferRewardLevel", 
        options = {}}, {isPopCurrentDialog = true})
end

function QUIDialogOfferReward:_onTriggerRefresh(event)
    app.sound:playSound("common_small")
    --请求刷新
    local remainingNum = remote.offerreward:getRemainingRefreshNum()
	if  remainingNum <= 0 then
	 	app.tip:floatTip("魂师派遣任务刷新次数不足~")
		return
	end

	local refreshNum = 0
	for k,v in pairs(self._items) do
		if v.isStart == false then
			refreshNum = refreshNum + 1
		end
	end

	if  refreshNum <= 0 then
	 	app.tip:floatTip("没有可以刷新的魂师派遣任务~")
		return
	end
	local costNum = refreshNum * tonumber(remote.offerreward:getRefreshNum())
	if costNum > remote.user.token then
		QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY)
		return
	end
	remote.offerreward:offerRewardRefreshTaskRequest(function(  )
		end,function(  )
		end)	
end

-- function QUIDialogOfferReward:_backClickHandler()
-- 	app.sound:playSound("common_cancel")
-- 	self:playEffectOut()
-- end

function QUIDialogOfferReward:_onTriggerGetAllAward(event)
    app.sound:playSound("common_small")
    if not self._items or q.isEmpty(self._items) then
	 	app.tip:floatTip("当前没有魂师派遣任务~")
		return
    end

    local dispatchIds = {}
	local currTime = q.serverTime()
    
    for i,v in ipairs(self._items) do
		if v.getReward == false then
			if v.isStart  then
				local offer_reward = remote.offerreward:getOfferRewardTaskById(v.taskId)
				local time_cd = tonumber(offer_reward.time) * 60
				local _startAt = v.startAt or 0
				local endTime = _startAt / 1000
				endTime = endTime + time_cd
				if endTime <=currTime then 
					table.insert(dispatchIds ,  v.dispatchId)
				end
			end
		end
    end
    if q.isEmpty(dispatchIds) then
	 	app.tip:floatTip("没有可以领取奖励的魂师派遣任务~")
		return
    end

	remote.offerreward:offerRewardGetRewardRequest(dispatchIds,function(data)
		local awards = data.prizes or {}
  		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
    		options = {awards = awards, callBack = function ()
    		end}},{isPopCurrentDialog = false} )
    	dialog:setTitle("恭喜您获得魂师派遣任务奖励")
		end,function(  )
			-- body
		end)
end

function QUIDialogOfferReward:_onTriggerClose()
	app.sound:playSound("common_cancel")
	self:playEffectOut()
	if self._callback then
		self._callback()
	end

end

return QUIDialogOfferReward