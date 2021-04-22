-- @Author: xurui
-- @Date:   2019-08-30 10:08:17
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-11-02 10:13:17
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogRankAward = class("QUIDialogRankAward", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView")
local QUIWidgetRankAward = import("..widgets.QUIWidgetRankAward")

function QUIDialogRankAward:ctor(options)
	local ccbFile = "ccb/Dialog_rank_service.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
        {ccbCallbackName = "onTriggerHelp", callback = handler(self, self._onTriggerHelp)},
    }
    QUIDialogRankAward.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callBack = options.callBack
    	self._rankConfig = options.config
    end

    self._awardList = {}
	self._ccbOwner.frame_tf_title:setString("本服进度")

    self:initListView()
end

function QUIDialogRankAward:viewDidAppear()
	QUIDialogRankAward.super.viewDidAppear(self)

    self._rankEventProxy = cc.EventProxy.new(remote.rank)
    self._rankEventProxy:addEventListener(remote.rank.EVENT_UPDATE_RANK_RECORD, handler(self, self._rankEvent))

	self:setAwardsInfo()
end

function QUIDialogRankAward:viewWillDisappear()
  	QUIDialogRankAward.super.viewWillDisappear(self)

    self._rankEventProxy:removeAllEventListeners()
    self._rankEventProxy = nil
end

function QUIDialogRankAward:_rankEvent()
	self:setAwardsInfo()
end

function QUIDialogRankAward:setAwardsInfo()
	self._awardList = remote.rank:getRankAwardsByType(self._rankConfig.awardType)
	
	table.sort( self._awardList, function(a, b)
			local aRecord = remote.rank:getRecordById(a.index)
			local bRecord = remote.rank:getRecordById(b.index)

			local aCanRecive = aRecord.completeUsersInfo ~= nil
			local bCanRecive = bRecord.completeUsersInfo ~= nil

			local aIsReward = aRecord.isReward
			if aIsReward == nil then aIsReward = false end
			local bIsReward = bRecord.isReward
			if bIsReward == nil then bIsReward = false end

			if aIsReward ~= bIsReward then
				return aIsReward == false
			else
				return a.index < b.index
			end
		end )

	self:initListView()
end

function QUIDialogRankAward:initListView()
    local totalNumber = #self._awardList
    if not self._listView then
        local cfg = {
            renderItemCallBack = handler(self, self._renderItemCallBack),
            enableShadow = false,
            ignoreCanDrag = true,
            curOriginOffset = 5,
            curOffset = 0,
            spaceY = 6,
            totalNumber = totalNumber,
        }
        self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
    else
        self._listView:reload({totalNumber = totalNumber})
    end
end

function QUIDialogRankAward:_renderItemCallBack(list, index, info )
    local isCacheNode = true
    local itemData = self._awardList[index]

    local item = list:getItemFromCache()
    if not item then
        item = QUIWidgetRankAward.new()
        item:addEventListener(QUIWidgetRankAward.EVENT_CLICK_RECIVED, handler(self, self._onClickRecive))
        item:addEventListener(QUIWidgetRankAward.EVENT_CLICK_RECORD, handler(self, self._onClickRecord))
        isCacheNode = false
    end
    item:setInfo(itemData)
    info.item = item
    info.size = item:getContentSize()

	list:registerBtnHandler(index, "btn_recive", "_onTriggerRecive", nil, "true")
	list:registerBtnHandler(index, "btn_record", "_onTriggerRecord", nil, "true")

    return isCacheNode
end

function QUIDialogRankAward:_onClickRecive(event)
	if event == nil then return end

	local info = event.info
	remote.rank:requestRankAwardIsComplete({info.index}, function (request)
		local record = remote.rank:getRecordById(info.index)
		record.isReward = true
		if self:safeCheck() then
			self:setAwardsInfo()
		end

		local awards = {}
		table.insert(awards, {id = info.id_1, typeName = info.type_1, count = info.num_1})
		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
            options = {awards = awards}},{isPopCurrentDialog = false} )
        dialog:setTitle("恭喜你获得进度任务奖励")
	end)
end

function QUIDialogRankAward:_onClickRecord(event)
	if event == nil then return end

	local info = event.info
	remote.rank:requestRankTop5Record(info.index, function (request)
		local record = {}
		if request.serverGoalGetTaskInfoResponse then
			record = request.serverGoalGetTaskInfoResponse.serverGoalUserInfos or {}
		end
	    app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRankAwardRecord",
	    	options = {info = info, record = record}}, {isPopCurrentDialog = false})
	end)
end

function QUIDialogRankAward:_onTriggerHelp()
    app.sound:playSound("common_small")

  	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogRankAwardHelp",
    options = {}}, {isPopCurrentDialog = false})
end

function QUIDialogRankAward:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogRankAward:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_close) == false then return end
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogRankAward:viewAnimationOutHandler()
	local callback = self._callBack

	remote.rank:updateEvent(remote.rank.EVENT_UPDATE_RANK_DIALOG)

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogRankAward
