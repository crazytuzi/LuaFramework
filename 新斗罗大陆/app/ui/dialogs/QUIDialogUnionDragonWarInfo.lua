local QUIDialogBaseUnion = import("..dialogs.QUIDialogBaseUnion")
local QUIDialogUnionDragonWarInfo = class("QUIDialogUnionDragonWarInfo", QUIDialogBaseUnion)
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetUnionDragonWarInfoDamage = import("..widgets.dragon.QUIWidgetUnionDragonWarInfoDamage")
local QUIWidgetUnionDragonWarInfoBuff = import("..widgets.dragon.QUIWidgetUnionDragonWarInfoBuff")
local QUIWidgetUnionDragonWarInfoLog = import("..widgets.dragon.QUIWidgetUnionDragonWarInfoLog")
local QUIWidgetUnionDragonWarInfoReport = import("..widgets.dragon.QUIWidgetUnionDragonWarInfoReport")
local QUIWidgetUnionDragonWarInfoTopReport = import("..widgets.dragon.QUIWidgetUnionDragonWarInfoTopReport")

QUIDialogUnionDragonWarInfo.TAB_INFO = "TAB_INFO"
QUIDialogUnionDragonWarInfo.TAB_BUFF = "TAB_BUFF"
QUIDialogUnionDragonWarInfo.TAB_DETAIL = "TAB_DETAIL"
QUIDialogUnionDragonWarInfo.TAB_REPORT = "TAB_REPORT"
QUIDialogUnionDragonWarInfo.TAB_TOP_REPORT = "TAB_TOP_REPORT"

function QUIDialogUnionDragonWarInfo:ctor(options)
	local ccbFile = "ccb/Dialog_society_dragontrain_info.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerDamage", callback = handler(self, self._onTriggerDamage)},
		{ccbCallbackName = "onTriggerBuff", callback = handler(self, self._onTriggerBuff)},
		{ccbCallbackName = "onTriggerDetail", callback = handler(self, self._onTriggerDetail)},		
		{ccbCallbackName = "onTriggerReport", callback = handler(self, self._onTriggerReport)},		
		{ccbCallbackName = "onTriggerTopReport", callback = handler(self, self._onTriggerTopReport)},		
	}
	QUIDialogUnionDragonWarInfo.super.ctor(self, ccbFile, callBack, options)

	self._damageList = nil
	self._buffList = nil
	self._logList = nil
	self._reportList = nil
	self._topReportList = nil

	self._tab = options.tab or QUIDialogUnionDragonWarInfo.TAB_INFO
end

function QUIDialogUnionDragonWarInfo:viewDidAppear()
	QUIDialogUnionDragonWarInfo.super.viewDidAppear(self)
	self:addBackEvent(false)

    self:selectTab(self._tab)
end

function QUIDialogUnionDragonWarInfo:viewWillDisappear()
	QUIDialogUnionDragonWarInfo.super.viewWillDisappear(self)
	self:removeBackEvent()
end

function QUIDialogUnionDragonWarInfo:resetUI()
	self._ccbOwner.btn_buff:setHighlighted(false)
	self._ccbOwner.btn_buff:setEnabled(true)
	self._ccbOwner.btn_damage:setHighlighted(false)
	self._ccbOwner.btn_damage:setEnabled(true)
	self._ccbOwner.btn_detail:setHighlighted(false)
	self._ccbOwner.btn_detail:setEnabled(true)
	self._ccbOwner.btn_report:setHighlighted(false)
	self._ccbOwner.btn_report:setEnabled(true)
	self._ccbOwner.btn_topReport:setHighlighted(false)
	self._ccbOwner.btn_topReport:setEnabled(true)

	self._ccbOwner.sp_no_record:setVisible(false)
end

function QUIDialogUnionDragonWarInfo:selectTab(tab)
	self._tab = tab
	self:getOptions().tab = tab
	self:resetUI()

	if self._infoWidget ~= nil then
		self._infoWidget:setVisible(false)
		self._infoWidget = nil
	end

	if tab == QUIDialogUnionDragonWarInfo.TAB_INFO then
		self._ccbOwner.btn_damage:setHighlighted(true)
		self._ccbOwner.btn_damage:setEnabled(false)
		self:selectInfoTab()
	elseif tab == QUIDialogUnionDragonWarInfo.TAB_BUFF then
		self._ccbOwner.btn_buff:setHighlighted(true)
		self._ccbOwner.btn_buff:setEnabled(false)
		self:selectBuffTab()
	elseif tab == QUIDialogUnionDragonWarInfo.TAB_DETAIL then
		self._ccbOwner.btn_detail:setHighlighted(true)
		self._ccbOwner.btn_detail:setEnabled(false)
		self:selectDetailTab()
	elseif tab == QUIDialogUnionDragonWarInfo.TAB_REPORT then
		self._ccbOwner.btn_report:setHighlighted(true)
		self._ccbOwner.btn_report:setEnabled(false)
		self:selectReportTab()
	elseif tab == QUIDialogUnionDragonWarInfo.TAB_TOP_REPORT then
		self._ccbOwner.btn_topReport:setHighlighted(true)
		self._ccbOwner.btn_topReport:setEnabled(false)
		self:selectTopReportTab()
	end

	if self._infoWidget ~= nil then
		self._infoWidget:setVisible(true)
	end
end

function QUIDialogUnionDragonWarInfo:selectInfoTab()
	local callback = function ()
		if not self._damageWidget then
			self._damageWidget = QUIWidgetUnionDragonWarInfoDamage.new()
			self._ccbOwner.node_content:addChild(self._damageWidget)
		end
		self._damageWidget:setInfo(self._damageList)
		self._infoWidget = self._damageWidget
	end

	if self._damageList then
		callback()
	else
		remote.unionDragonWar:dragonWarGetFightHurtListRequest(function (data)
			self._damageList = data.dragonWarGetFightHurtListResponse.info or {}
			if self:safeCheck() then
				callback()
			end
		end)
	end
end

function QUIDialogUnionDragonWarInfo:selectBuffTab()
	local callback = function ()
		if not self._buffWidget then
			self._buffWidget = QUIWidgetUnionDragonWarInfoBuff.new()
			self._ccbOwner.node_content:addChild(self._buffWidget)
		end
		self._buffWidget:setInfo(self._buffList)
		self._infoWidget = self._buffWidget
	end

	if self._buffList then
		callback()
	else
		remote.unionDragonWar:dragonWarGetHolyStsListRequest(function (data)
			self._buffList = data.dragonWarGetHolyStsListResponse.info or {}
			if self:safeCheck() then
				callback()
			end
		end)
	end
end

function QUIDialogUnionDragonWarInfo:selectDetailTab()
	local callback = function ()
		if not self._logWidget then
			self._logWidget = QUIWidgetUnionDragonWarInfoLog.new()
			self._ccbOwner.node_content:addChild(self._logWidget)
		end
		self._logWidget:setInfo(self._logList)
		self._infoWidget = self._logWidget

		if #self._logList == 0 then
			self._ccbOwner.sp_no_record:setVisible(true)
		end
	end

	if self._logList then
		callback()
	else
		local dragonFighter = remote.unionDragonWar:getDragonFighter()
		remote.unionDragonWar:dragonWarGetBattleEventsRequest(dragonFighter.matchingId, 1, function (data)
			self._logList = data.dragonWarGetBattleEventsResponse.battleEvents or {}
			if self:safeCheck() then
				callback()
			end
		end)
	end
end

function QUIDialogUnionDragonWarInfo:selectReportTab()
	local callback = function ()
		if not self._reportWidget then
			self._reportWidget = QUIWidgetUnionDragonWarInfoReport.new()
			self._ccbOwner.node_content:addChild(self._reportWidget)
		end
		self._reportWidget:setInfo(self._reportList)
		self._infoWidget = self._reportWidget

		if #self._reportList == 0 then
			self._ccbOwner.sp_no_record:setVisible(true)
		end
	end

	if self._reportList then
		callback()
	else
		remote.unionDragonWar:dragonWarGetHistoryBattleListRequest(function (data)
			self._reportList = data.dragonWarGetHistoryBattleListResponse.historyBattles or {}
			if self:safeCheck() then
				callback()
			end
		end)
	end
end

function QUIDialogUnionDragonWarInfo:selectTopReportTab()
	local callback = function ()
		if not self._topReportWidget then
			self._topReportWidget = QUIWidgetUnionDragonWarInfoTopReport.new()
			self._ccbOwner.node_content:addChild(self._topReportWidget)
		end
		self._topReportWidget:setInfo(self._topReportList)
		self._infoWidget = self._topReportWidget

		if #self._topReportList == 0 then
			self._ccbOwner.sp_no_record:setVisible(true)
		end
	end

	if self._topReportList then
		callback()
	else
		app:getClient():globalGetTopFightReportDataRequest(BattleTypeEnum.DRAGON_WAR, function (data)
			self._topReportList = data.globalGetTopFightReportDataResponse.reportDatas or {}
			if self:safeCheck() then
				callback()
			end
		end)
	end
end

function QUIDialogUnionDragonWarInfo:_onTriggerDamage()
	if self._tab == QUIDialogUnionDragonWarInfo.TAB_INFO then return end
    app.sound:playSound("common_switch")
    self:selectTab(QUIDialogUnionDragonWarInfo.TAB_INFO)
end

function QUIDialogUnionDragonWarInfo:_onTriggerBuff()
	if self._tab == QUIDialogUnionDragonWarInfo.TAB_BUFF then return end
    app.sound:playSound("common_switch")
    self:selectTab(QUIDialogUnionDragonWarInfo.TAB_BUFF)
end

function QUIDialogUnionDragonWarInfo:_onTriggerDetail()
	if self._tab == QUIDialogUnionDragonWarInfo.TAB_DETAIL then return end
    app.sound:playSound("common_switch")
    self:selectTab(QUIDialogUnionDragonWarInfo.TAB_DETAIL)
end

function QUIDialogUnionDragonWarInfo:_onTriggerReport()
	if self._tab == QUIDialogUnionDragonWarInfo.TAB_REPORT then return end
    app.sound:playSound("common_switch")
    self:selectTab(QUIDialogUnionDragonWarInfo.TAB_REPORT)
end

function QUIDialogUnionDragonWarInfo:_onTriggerTopReport()
	if self._tab == QUIDialogUnionDragonWarInfo.TAB_TOP_REPORT then return end
    app.sound:playSound("common_switch")
	app:triggerBuriedPoint(21603)
    self:selectTab(QUIDialogUnionDragonWarInfo.TAB_TOP_REPORT)
end

return QUIDialogUnionDragonWarInfo