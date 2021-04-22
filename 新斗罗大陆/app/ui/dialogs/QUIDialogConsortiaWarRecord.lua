-- @Author: zhouxiaoshu
-- @Date:   2019-04-29 11:50:40
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-12-16 20:30:20

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogConsortiaWarRecord = class("QUIDialogConsortiaWarRecord", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetConsortiaWarRecordReport = import("..widgets.consortiaWar.QUIWidgetConsortiaWarRecordReport")
local QUIWidgetConsortiaWarRecordLog = import("..widgets.consortiaWar.QUIWidgetConsortiaWarRecordLog")
local QUIViewController = import("...ui.QUIViewController")
local QReplayUtil = import("...utils.QReplayUtil")
local QListView = import("...views.QListView")

QUIDialogConsortiaWarRecord.TAB_REPORT = "TAB_REPORT"
QUIDialogConsortiaWarRecord.TAB_LOG = "TAB_LOG"

function QUIDialogConsortiaWarRecord:ctor(options)
	local ccbFile = "ccb/Dialog_plunder_zhanbao.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerPersonalReport", callback = handler(self, self._onTriggerPersonalReport)},		
		{ccbCallbackName = "onTriggerUnionReport", callback = handler(self, self._onTriggerUnionReport)},		
	}
	QUIDialogConsortiaWarRecord.super.ctor(self, ccbFile, callBack, options)
	self.isAnimation = true

	self._logList = nil
	self._reportList = nil
	self._data = {}
	
	self._ccbOwner.btn_personal_report:setTitleForState(CCString:create("个人战报"), CCControlStateNormal)
	self._ccbOwner.btn_union_report:setTitleForState(CCString:create("宗门战报"), CCControlStateNormal)
	self._ccbOwner.award_tips:setVisible(false)
	
	self._tab = options.tab or QUIDialogConsortiaWarRecord.TAB_REPORT
	self:initListView()
end

function QUIDialogConsortiaWarRecord:viewDidAppear()
	QUIDialogConsortiaWarRecord.super.viewDidAppear(self)
    self:selectTab(self._tab)
end

function QUIDialogConsortiaWarRecord:viewWillDisappear()
  	QUIDialogConsortiaWarRecord.super.viewWillDisappear(self)
end

function QUIDialogConsortiaWarRecord:resetUI()
	self._ccbOwner.btn_union_report:setHighlighted(false)
	self._ccbOwner.btn_union_report:setEnabled(true)
	self._ccbOwner.btn_personal_report:setHighlighted(false)
	self._ccbOwner.btn_personal_report:setEnabled(true)

	self._ccbOwner.node_no:setVisible(false)
end

function QUIDialogConsortiaWarRecord:selectTab(tab)
	self._tab = tab
	self:getOptions().tab = tab
	self:resetUI()

	if tab == QUIDialogConsortiaWarRecord.TAB_LOG then
		self._ccbOwner.btn_union_report:setHighlighted(true)
		self._ccbOwner.btn_union_report:setEnabled(false)
		self:selectDetailTab()
	elseif tab == QUIDialogConsortiaWarRecord.TAB_REPORT then
		self._ccbOwner.btn_personal_report:setHighlighted(true)
		self._ccbOwner.btn_personal_report:setEnabled(false)
		self:selectReportTab()
	end
end

function QUIDialogConsortiaWarRecord:selectDetailTab()
	if self._logList then
		self._data = self._logList
		self:initListView()
	else
		remote.consortiaWar:consortiaWarGetBattleEventListRequest(function (data)
			if self:safeCheck() then
				self._logList = data.consortiaWarGetBattleEventListResponse.eventList or {}
				self._data = self._logList
				self:initListView()
			end
		end)
	end
end

function QUIDialogConsortiaWarRecord:selectReportTab()
	if self._reportList then
		self._data = self._reportList
		self:initListView()
	else
		remote.consortiaWar:consortiaWarGetBattleListRequest(function (data)
			if self:safeCheck() then
				self._reportList = data.consortiaWarGetBattleListResponse.reportList or {}
				self._data = self._reportList
				self:initListView()
			end
		end)
	end
end
function QUIDialogConsortiaWarRecord:initListView()
	self._ccbOwner.node_no:setVisible(not next(self._data))
	if not self._listView then
		local cfg = {
			renderItemCallBack = handler(self, self._renderItemFunc),
	        curOriginOffset = 0,
	        isVertical = true,
	        enableShadow = true,
	      	ignoreCanDrag = true,
	      	spaceY = 27,
	        totalNumber = #self._data,
	        curOffset = 30,
		}
		self._listView = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else
		self._listView:reload({totalNumber = #self._data})
	end
end

function QUIDialogConsortiaWarRecord:_renderItemFunc( list, index, info )
    -- body
    local isCacheNode = true
    local itemData = self._data[index]
    local item = list:getItemFromCache(self._tab)
    if not item then
    	if self._tab == QUIDialogConsortiaWarRecord.TAB_REPORT then
	    	item = QUIWidgetConsortiaWarRecordReport.new()
			--item:addEventListener(QUIWidgetConsortiaWarRecordReport.EVENT_CLICK_HEAD, handler(self, self.itemClickHandler))
			item:addEventListener(QUIWidgetConsortiaWarRecordReport.EVENT_CLICK_RECORDE, handler(self, self.itemClickHandler))
			item:addEventListener(QUIWidgetConsortiaWarRecordReport.EVENT_CLICK_SHARED, handler(self, self.itemClickHandler))
			item:addEventListener(QUIWidgetConsortiaWarRecordReport.EVENT_CLICK_REPLAY, handler(self, self.itemClickHandler))
		else
			item = QUIWidgetConsortiaWarRecordLog.new()
		end
    	isCacheNode = false
    end
    item:setInfo(itemData, index)
    info.item = item
    info.size = item:getContentSize()

    if self._tab == QUIDialogConsortiaWarRecord.TAB_REPORT then 
	    list:registerBtnHandler(index, "btn_head", "_onTriggerHead",nil,true)
	    list:registerBtnHandler(index, "btn_record", "_onTriggerDetail",nil,true)
	    list:registerBtnHandler(index, "btn_share", "_onTriggerShare",nil,true)
	    list:registerBtnHandler(index, "btn_replay", "_onTriggerReplay",nil,true)
	end

    return isCacheNode
end

function QUIDialogConsortiaWarRecord:itemClickHandler(event)
	if not event.name then
		return
	end

	local info = event.info
	local userId = info.fighter.userId
	local reportType = REPORT_TYPE.CONSORTIA_WAR
	local reportId = info.reportId
	if event.name == QUIWidgetConsortiaWarRecordReport.EVENT_CLICK_HEAD then
		remote.consortiaWar:consortiaWarQueryFighterRequest(userId, function(data)
			local fighter = data.consortiaWarQueryFighterResponse.fighter or {}
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlayerInfo",
    			options = {fighter = fighter, forceTitle1 = "防守战力：", model = GAME_MODEL.NORMAL, isPVP = true}}, {isPopCurrentDialog = false})
		end)
	elseif event.name == QUIWidgetConsortiaWarRecordReport.EVENT_CLICK_SHARED then
		local rivalName = info.fighter.name
		QReplayUtil:getReplayInfo(reportId, function (data)
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogReplayShare", 
				options = {rivalName = rivalName, myNickName = remote.user.nickname, replayId = reportId, replayType = reportType}}, {isPopCurrentDialog = false})
		end, nil, reportType)

	elseif event.name == QUIWidgetConsortiaWarRecordReport.EVENT_CLICK_REPLAY then
		QReplayUtil:getReplayInfo(reportId, function (data)
			QReplayUtil:downloadReplay(reportId, function (replay)
				QReplayUtil:play(replay, data.scoreList, data.fightReportStats, true)
			end, nil, reportType)
		end, nil, reportType)

	elseif event.name == QUIWidgetConsortiaWarRecordReport.EVENT_CLICK_RECORDE then
		QReplayUtil:getReplayInfo(reportId, function (data)
	        QReplayUtil:downloadReplay(reportId, function (replay, replayInfo)
	            if self:safeCheck() and replayInfo then
	                local fighter = QReplayUtil:getFighterFromReplayInfo(replayInfo, false)
	                local detailInfo = {}
					detailInfo.isInitiative = true
					detailInfo.scoreList = info.scoreList
					detailInfo.fighter = fighter
					detailInfo.replayInfo = data
					app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAgainstRecordDetail",
			    		options = {info = detailInfo}}, {isPopCurrentDialog = false})
	            end
	        end, nil, reportType, true)
	    end, nil, reportType)
	end
end

function QUIDialogConsortiaWarRecord:_onTriggerUnionReport()
    app.sound:playSound("common_switch")
    self:selectTab(QUIDialogConsortiaWarRecord.TAB_LOG)
end

function QUIDialogConsortiaWarRecord:_onTriggerPersonalReport()
    app.sound:playSound("common_switch")
    self:selectTab(QUIDialogConsortiaWarRecord.TAB_REPORT)
end

function QUIDialogConsortiaWarRecord:_backClickHandler()
    app.sound:playSound("common_close")
    self:playEffectOut()
end

function QUIDialogConsortiaWarRecord:_onTriggerClose()
	app.sound:playSound("common_cancel")
    self:playEffectOut()
end

return QUIDialogConsortiaWarRecord