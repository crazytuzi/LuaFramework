-- @Author: xurui
-- @Date:   2017-01-03 19:15:35
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-12-04 12:10:36

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMaritimeAwards = class("QUIDialogMaritimeAwards", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetMaritimeAwardsClient = import("..widgets.QUIWidgetMaritimeAwardsClient")
local QUIWidgetMaritimeReplayClient = import("..widgets.QUIWidgetMaritimeReplayClient")
local QListView = import("...views.QListView")
local QReplayUtil = import("...utils.QReplayUtil")
local QScrollView = import("...views.QScrollView")
local QUIWidgetHands = import("..widgets.QUIWidgetHands")

QUIDialogMaritimeAwards.TAB_AWARDS = "TAB_AWARDS"
-- QUIDialogMaritimeAwards.TAB_PERSONAL_REPLAY = "TAB_PERSONAL_REPLAY"
-- QUIDialogMaritimeAwards.TAB_PROTECT_REPLAY = "TAB_PROTECT_REPLAY"

local REPLAY_CD_LIMIT = "%d分钟内只允许发送%d条战报，%s后可以发送"
local REPLAY_CD = 5 -- 5m
local REPLAY_COUNT = 5

function QUIDialogMaritimeAwards:ctor(options)
	local ccbFile = "ccb/Dialog_Haishang_xpjl.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerGetAll", callback = handler(self, self._onTriggerGetAll)},
	}
	QUIDialogMaritimeAwards.super.ctor(self, ccbFile, callBack, options)
	if options.isQuick ~= true then
		self.isAnimation = true
	end

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	if options then
		self._tab = options.tab or QUIDialogMaritimeAwards.TAB_AWARDS
		self._callBack = options.callBack
	end
	self._replayClient = {}

	self._ccbOwner.node_hands:setVisible(false)

    q.setButtonEnableShadow(self._ccbOwner.btn_get_all)
    q.setButtonEnableShadow(self._ccbOwner.btn_close)
    
    self._ccbOwner.frame_tf_title:setString("仙品奖励")
	self:initScrollView()
end

function QUIDialogMaritimeAwards:viewDidAppear()
	QUIDialogMaritimeAwards.super.viewDidAppear(self)

	self:selectTab()
end

function QUIDialogMaritimeAwards:viewWillDisappear()
	QUIDialogMaritimeAwards.super.viewWillDisappear(self)

	if self._hands then
		self._hands:removeFromParent()
		self._hands = nil
	end
end

function QUIDialogMaritimeAwards:initScrollView()
	self._itemWidth = self._ccbOwner.sheet_layout:getContentSize().width
	self._itemHeight = self._ccbOwner.sheet_layout:getContentSize().height

	self._scrollView = QScrollView.new(self._ccbOwner.sheet, CCSize(self._itemWidth, self._itemHeight), {bufferMode = 2, sensitiveDistance = 10})
	self._scrollView:setVerticalBounce(true)

    self._scrollView:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._onScrollViewMoving))
    self._scrollView:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self._onScrollViewBegan))
end

function QUIDialogMaritimeAwards:setClentInfo()
	local node = self._ccbOwner.sheet_layout
	-- if self._tab == QUIDialogMaritimeAwards.TAB_AWARDS then
	-- 	node = self._ccbOwner.sheet_layout1
	-- end

    if not self._contentListView then
        local cfg = {
            renderItemCallBack = handler(self,self._reandFunHandler),
            ignoreCanDrag = true,
            totalNumber = #self._data,
            spaceY = 0,
	        curOffset = 20,
	        enableShadow = false,
        }  
        self._contentListView = QListView.new(node, cfg)
    else
        self._contentListView:reload({totalNumber = #self._data})
    end

    self:checkRedTips()
end

function QUIDialogMaritimeAwards:checkRedTips()
	-- self._ccbOwner.sp_award_tips:setVisible(remote.maritime:checkAwardsTips())
	-- self._ccbOwner.sp_personal_record_tips:setVisible(remote.maritime:checkReplayTips())
end

function QUIDialogMaritimeAwards:_reandFunHandler( list, index, info )
    local isCacheNode = true
    local masterConfig = self._data[index]
    local item = list:getItemFromCache()
    if not item then
       	item = QUIWidgetMaritimeAwardsClient.new()
        isCacheNode = false
    end
    item:setInfo({info = masterConfig, index = index, parent = self}) 
    item:setPositionX(10)
    info.item = item
    info.size = item:getContentSize()

    item:addEventListener(QUIWidgetMaritimeAwardsClient.CLICK_AWARD, handler(self, self._clickAwards))
    list:registerTouchHandler(index, "onTouchListView")
    list:registerBtnHandler(index, "btn_click1", "_onTriggerClickAwards", nil, true)

    return isCacheNode
end

function QUIDialogMaritimeAwards:selectTab()
	self:getOptions().tab = self._tab

	self:_setButtonState()

	if self._contentListView ~= nil then
		self._contentListView:clear(true)
	end
	self._scrollView:clear()
	self._replayClient = {}
	self:_checkTutorialHands(false)

	self._ccbOwner.node_no:setVisible(false)
	-- self._ccbOwner.sp_long_bg:setVisible(true)
	-- self._ccbOwner.sp_short_bg:setVisible(false)
	self._ccbOwner.node_btn_get_all:setVisible(false)
	self._ccbOwner.node_hands:setVisible(false)

	remote.maritime:requestGetMaritimeRewardList(function(data)
			if self:safeCheck() == false then return end

			self._data = data.maritimeShipRewardListResponse.rewardInfos
			
			self:checkRedTips()
			if self._data == nil or next(self._data) == nil then
				self._ccbOwner.node_no:setVisible(true)
				self._ccbOwner.tf_no_content:setString("魂师大人，当前还没有仙品奖励哦～")
				return
			end

			table.sort( self._data, function(a, b)
					if a.status ~= b.status then
						return a.status < b.status
					else
						return a.shipInfoId > b.shipInfoId
					end
				end )
			-- self._ccbOwner.sp_long_bg:setVisible(false)
			self._ccbOwner.node_btn_get_all:setVisible(true)
			-- self._ccbOwner.sp_short_bg:setVisible(true)

			self:setClentInfo()
		end)
end

function QUIDialogMaritimeAwards:_checkTutorialHands(isCreat)
	if isCreat == false then
		if self._hands then
			self._hands:removeFromParent()
			self._hands = nil
		end
		return
	end
	local position = nil
	if self._replayClient and next(self._replayClient) then
		for i = 1, #self._replayClient do
			local data = self._replayClient[i]:getReplayInfo()
			if data.shipInfoId == self._infoReplay.shipInfoId then
				position = self._replayClient[i]._ccbOwner.ly_bg:convertToWorldSpaceAR(ccp(0,0))
				break
			end
		end

		if position then
			self._hands = QUIWidgetHands.new()
			self._hands:setPosition(position.x+295, position.y)
			app.tutorialNode:addChild(self._hands)
		end
	end
end

function QUIDialogMaritimeAwards:_clickInfo(event)
	if event.info then
		self._infoReplay = event.info
	end
end

function QUIDialogMaritimeAwards:_clickAwards(event)
	if event and event.info then
		self:getAwards({event.info.shipInfoId}, event.awards)
	end
end

function QUIDialogMaritimeAwards:getAwards(ids, awards)
	remote.maritime:requestGetMaritimeReward(ids, function()
			if self:safeCheck() then
		  		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
		    		options = {awards = awards, callBack = function ()
		    			if self:safeCheck() then
							self:selectTab()
						end
		    		end}},{isPopCurrentDialog = false} )
		   		dialog:setTitle("恭喜您获得仙品奖励")
			end
		end)
end

function QUIDialogMaritimeAwards:getContentListView()
    return self._contentListView
end

function QUIDialogMaritimeAwards:_setButtonState()
	-- local awardTab = self._tab == QUIDialogMaritimeAwards.TAB_AWARDS
	-- self._ccbOwner.btn_award:setHighlighted(awardTab)
	-- self._ccbOwner.btn_award:setEnabled(not awardTab)

	-- local personalTab = self._tab == QUIDialogMaritimeAwards.TAB_PERSONAL_REPLAY
	-- self._ccbOwner.btn_personal_record:setHighlighted(personalTab)
	-- self._ccbOwner.btn_personal_record:setEnabled(not personalTab)

	-- local protectTab = self._tab == QUIDialogMaritimeAwards.TAB_PROTECT_REPLAY
	-- self._ccbOwner.btn_protect_record:setHighlighted(protectTab)
	-- self._ccbOwner.btn_protect_record:setEnabled(not protectTab)
end

function QUIDialogMaritimeAwards:_onScrollViewMoving()
	self._isMove = true
end

function QUIDialogMaritimeAwards:_onScrollViewBegan()
	self._isMove = false
	self:_checkTutorialHands(false)
end

function QUIDialogMaritimeAwards:_onTriggerGetAll()
    app.sound:playSound("common_menu")

	local ids = {}
	local awards = {}
	for i = 1, #self._data do
		if self._data[i].status == 2 then
			ids[#ids+1] = self._data[i].shipInfoId
			local data = string.split(self._data[i].rewards, ";")
			for i = 1, #data do
				data[i] = string.split(data[i], "^")
				local itemType = ITEM_TYPE.ITEM
				if tonumber(data[i][1]) == nil then
					itemType = data[i][1]
				end
				awards[#awards+1] = {id = tonumber(data[i][1]), typeName = itemType, count = tonumber(data[i][2])}
			end
		end
	end
	if next(ids) then
		self:getAwards(ids, awards)
	else
		app.tip:floatTip("奖励已领完")
	end
end

function QUIDialogMaritimeAwards:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogMaritimeAwards:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogMaritimeAwards:viewAnimationOutHandler()
	local callback = self._callBack
	self:popSelf()
	if callback then
		callback()
	end
end


return QUIDialogMaritimeAwards