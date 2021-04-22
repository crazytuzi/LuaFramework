-- @Author: xurui
-- @Date:   2018-08-16 19:40:11
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-09-27 11:26:18
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMetalCityRecord = class("QUIDialogMetalCityRecord", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetMetalCityRcordClient = import("..widgets.QUIWidgetMetalCityRcordClient")
local QListView = import("...views.QListView")
local QReplayUtil = import("...utils.QReplayUtil")

function QUIDialogMetalCityRecord:ctor(options)
	local ccbFile = "ccb/Dialog_tower_tongguanjilu.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogMetalCityRecord.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callBack = options.callBack
    	self._info = options.info or {}
        self._reportType = options.reportType or REPORT_TYPE.METAL_CITY
    end

    self._records = {}

	self._ccbOwner.node_no:setVisible(false)
    self._ccbOwner.frame_tf_title:setString("通关记录")
    self:initListView()
    self:updateInfo(self._info)
end

function QUIDialogMetalCityRecord:viewDidAppear()
	QUIDialogMetalCityRecord.super.viewDidAppear(self)
end

function QUIDialogMetalCityRecord:viewWillDisappear()
  	QUIDialogMetalCityRecord.super.viewWillDisappear(self)
end

function QUIDialogMetalCityRecord:updateInfo(data)
	-- self._records = data.metalCityResponse.reports or {}
    self._records = data
	
	if q.isEmpty(self._records) then
		self._ccbOwner.node_no:setVisible(true)
	end

    self:initListView()
end

function QUIDialogMetalCityRecord:initListView()
    if not self._contentListView then
	    local cfg = {
            renderItemCallBack = handler(self,self._reandFunHandler),
            ignoreCanDrag = true,
            isVertical = true,
            spaceY = -2,
            enableShadow = false,
            totalNumber = #self._records,
            curOriginOffset = 5,
            contentOffsetX = -7,
	    }  
	    self._contentListView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._contentListView:reload({totalNumber = #self._records})
	end
end

function QUIDialogMetalCityRecord:_reandFunHandler(list, index, info)
    local isCacheNode = true
    local record = self._records[index]
    local item = list:getItemFromCache()
    if not item then
    	item = QUIWidgetMetalCityRcordClient.new()
    	item:addEventListener(QUIWidgetMetalCityRcordClient.EVENT_CLICK_REPLAY, handler(self, self._onClickEvent))
        isCacheNode = false
    end
    item:setInfo(record, index,self._reportType) 
    info.item = item
    info.size = item:getContentSize()

    list:registerBtnHandler(index, "btn_replay", "_onTriggerReplay", nil, true)
    list:registerBtnHandler(index, "btn_trail_1", "_onShowTeam1Heros")
    list:registerBtnHandler(index, "btn_trail_2", "_onShowTeam2Heros")

	return isCacheNode
end

function QUIDialogMetalCityRecord:_onClickEvent(event)
	if event == nil then return end
	if event.name == QUIWidgetMetalCityRcordClient.EVENT_CLICK_REPLAY then
		local replayId = event.recordId
		QReplayUtil:downloadReplay(replayId, function (replay, response)
			-- QReplayUtil:play(replay)
            if self._reportType == REPORT_TYPE.METAL_CITY then 
                app:loadBattleRecordFromProtobuf(replay)
                if #app:getBattleRecordList() < 2 then
                    app.tip:floatTip(VERSION_NOT_COMPATIBLE)
                else
                    QReplayUtil:playRecord()
                end
            else
                QReplayUtil:play(replay)
            end
		end, nil, self._reportType)
	end
end

function QUIDialogMetalCityRecord:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogMetalCityRecord:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_close) == false then return end
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogMetalCityRecord:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogMetalCityRecord
