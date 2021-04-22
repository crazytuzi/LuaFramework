--
-- zxs
-- 精英赛64强
--
local QUIWidget = import("..QUIWidget")
local QUIWidgetSanctuaryEliminateMap = class("QUIWidgetSanctuaryEliminateMap", QUIWidget)
local QUIWidgetSanctuaryPageGroup = import("..sanctuary.QUIWidgetSanctuaryPageGroup")
local QUIWidgetSanctuaryHead = import("..sanctuary.QUIWidgetSanctuaryHead")
local QReplayUtil = import("....utils.QReplayUtil")
local QUIViewController = import("...QUIViewController")

function QUIWidgetSanctuaryEliminateMap:ctor(options)
	local ccbFile = "ccb/Widget_Sanctuary_Eliminate.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerReplay1", callback = handler(self, self._onTriggerReplay1)},
        {ccbCallbackName = "onTriggerReplay2", callback = handler(self, self._onTriggerReplay2)},
        {ccbCallbackName = "onTriggerReplay3", callback = handler(self, self._onTriggerReplay3)},
        {ccbCallbackName = "onTriggerReplay4", callback = handler(self, self._onTriggerReplay4)},
        {ccbCallbackName = "onTriggerReplay5", callback = handler(self, self._onTriggerReplay5)},
        {ccbCallbackName = "onTriggerReplay6", callback = handler(self, self._onTriggerReplay6)},
        {ccbCallbackName = "onTriggerReplay7", callback = handler(self, self._onTriggerReplay7)},
        {ccbCallbackName = "onTriggerLeft", callback = handler(self, self._onTriggerLeft)},
        {ccbCallbackName = "onTriggerRight", callback = handler(self, self._onTriggerRight)},
	}
	QUIWidgetSanctuaryEliminateMap.super.ctor(self,ccbFile,callBacks,options)
	self._options = options or {}

	self._heads = {}
	self._heads[1] = {{pos = 1, camera = 1}, {pos = 9, line = 1, camera = 5}, {pos = 13, line = 9, camera = 7}, {pos = 15, line = 13}}
	self._heads[2] = {{pos = 2, camera = 1}, {pos = 9, line = 2, camera = 5}, {pos = 13, line = 9, camera = 7}, {pos = 15, line = 13}}
	self._heads[3] = {{pos = 3, camera = 2}, {pos = 10, line = 3, camera = 5}, {pos = 13, line = 10, camera = 7}, {pos = 15, line = 13}}
	self._heads[4] = {{pos = 4, camera = 2}, {pos = 10, line = 4, camera = 5}, {pos = 13, line = 10, camera = 7}, {pos = 15, line = 13}}
	self._heads[5] = {{pos = 5, camera = 3}, {pos = 11, line = 5, camera = 6}, {pos = 14, line = 11, camera = 7}, {pos = 15, line = 14}}
	self._heads[6] = {{pos = 6, camera = 3}, {pos = 11, line = 6, camera = 6}, {pos = 14, line = 11, camera = 7}, {pos = 15, line = 14}}
	self._heads[7] = {{pos = 7, camera = 4}, {pos = 12, line = 7, camera = 6}, {pos = 14, line = 12, camera = 7}, {pos = 15, line = 14}}
	self._heads[8] = {{pos = 8, camera = 4}, {pos = 12, line = 8, camera = 6}, {pos = 14, line = 12, camera = 7}, {pos = 15, line = 14}}
	
	self:switchState()
end

function QUIWidgetSanctuaryEliminateMap:onEnter()
	QUIWidgetSanctuaryEliminateMap.super.onEnter(self)
end

function QUIWidgetSanctuaryEliminateMap:onExit()
	QUIWidgetSanctuaryEliminateMap.super.onExit(self)
end

function QUIWidgetSanctuaryEliminateMap:setOptions(options)
	QUIWidgetSanctuaryEliminateMap.super.onExit(self)
end

--隐藏有线
function QUIWidgetSanctuaryEliminateMap:resetAll()
	local index = 1
	while self._ccbOwner["line_"..index] do
		self._ccbOwner["line_"..index]:setVisible(false)
		index = index + 1
	end

	index = 1
	while self._ccbOwner["head_"..index] do
		self._ccbOwner["head_"..index]:removeAllChildren()
		index = index + 1
	end

	index = 1
	while self._ccbOwner["camera_"..index] do
		self._ccbOwner["camera_"..index]:setVisible(false)
		index = index + 1
	end
end

--刷新数据
function QUIWidgetSanctuaryEliminateMap:switchState()
	local totalPage = remote.sanctuary:getTotalPage()
	local myIndex = remote.sanctuary:getMyPageIndex()
	self._totalPage = totalPage
	self._currentIndex = myIndex

	if self._options.currentIndex then
		self._currentIndex = self._options.currentIndex
	end
	if self._currentIndex == 0 then
		self._currentIndex = 1
	end
	if self._currentIndex > self._totalPage then
		self._currentIndex = self._totalPage
	end

	self._groupBtn = {}
	self._ccbOwner.node_group:removeAllChildren()
	local width = 65
	local startPosX = -self._totalPage*width/2 - width/2
	for index = 1, self._totalPage do
		self._groupBtn[index] = QUIWidgetSanctuaryPageGroup.new()
		self._groupBtn[index]:addEventListener(QUIWidgetSanctuaryPageGroup.EVENT_GROUP_CLICK, handler(self, self._groupClickHandler))
		self._groupBtn[index]:setPositionX(startPosX+index*width)
		self._groupBtn[index]:setIndex(index)
		self._groupBtn[index]:setIsSelf(myIndex == index)
		self._ccbOwner.node_group:addChild(self._groupBtn[index])
	end

	self:showInfo()
end

--显示界面的信息
function QUIWidgetSanctuaryEliminateMap:showInfo()
	self._options.currentIndex = self._currentIndex
	self:resetAll()

	self._players = remote.sanctuary:getInfoByPage(self._currentIndex)

	self._topLocalRound = remote.sanctuary.POS_1
	local maxForce = 0
	for i, player in pairs(self._players) do
		if player.localRound > self._topLocalRound then
			self._topLocalRound = player.localRound
		end
		if player.fighter.force > maxForce then
			maxForce = player.fighter.force
		end
	end
	for i, player in pairs(self._players) do
		local isTopForce = player.fighter.force == maxForce
		self:showHeadByInfo(player, isTopForce)
	end

	for index = 1, self._totalPage do
		self._groupBtn[index]:setIsSelected(index == self._currentIndex)
	end
end

--根据单个信息显示头像
function QUIWidgetSanctuaryEliminateMap:showHeadByInfo(player, isTopForce)
	if player == nil or player.fighter == nil then
		return 
	end
	local state = remote.sanctuary:getState()
	local headFun = function (player, headConfig, posId, index)
		local head = QUIWidgetSanctuaryHead.new()
		self._ccbOwner["head_"..headConfig.pos]:addChild(head)
		
		local isFail = nil
		if self._topLocalRound > posId then
			if posId == player.localRound and not player.ifNextRound then
				isFail = true
			else
				isFail = false
			end
		end
		head:setInfo(player, isFail, true)
		if posId < remote.sanctuary.POS_4 then
			head:setIsTopForce(isTopForce)
		end
		
		if index > 4 then
			head:setHeadFlipX()
		end

		if headConfig.line then
			self._ccbOwner["line_"..headConfig.line]:setVisible(true)
		end

		-- 标记对应放大镜
		player.camera = 0
		if isFail and headConfig.camera then
			player.camera = headConfig.camera
			self._ccbOwner["camera_"..headConfig.camera]:setVisible(true)
		end
	end

	local index = (player.position-1)%8+1
	if player.localRound >= remote.sanctuary.POS_1 then
		headFun(player, self._heads[index][1], remote.sanctuary.POS_1, index)
	end
	if player.localRound >= remote.sanctuary.POS_2 then
		headFun(player, self._heads[index][2], remote.sanctuary.POS_2, index)
	end
	if player.localRound >= remote.sanctuary.POS_3 then
		headFun(player, self._heads[index][3], remote.sanctuary.POS_3, index)
	end
	if player.localRound >= remote.sanctuary.POS_4 then
		headFun(player, self._heads[index][4], remote.sanctuary.POS_4, index)
	end	
end

--播放战斗回放通过index
function QUIWidgetSanctuaryEliminateMap:playBattleByIndex(index)
	-- 对应放大镜
	local battleInfo = nil
	for i, player in pairs(self._players) do
		if player.camera == index then
			battleInfo = player
			break
		end
	end
	if battleInfo ~= nil then
		remote.sanctuary:sanctuaryWarGetReportRequest(battleInfo.currRound, battleInfo.fighter.userId, false, false, false, function (data)
			local reports = data.sanctuaryWarGetReportResponse.reports or {}
			if #reports > 0 then
				local report = reports[1]
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSanctuaryRecordDetail", 
					options = {report = report}}, {isPopCurrentDialog = false})
			end
		end)
	else
		app.tip:floatTip("没有可用的战报~")
	end
end

function QUIWidgetSanctuaryEliminateMap:_onTriggerReplay1(event)
    if q.buttonEventShadow(event, self._ccbOwner.camera_1) == false then return end
	self:playBattleByIndex(1)
end

function QUIWidgetSanctuaryEliminateMap:_onTriggerReplay2(event)
    if q.buttonEventShadow(event, self._ccbOwner.camera_2) == false then return end
	self:playBattleByIndex(2)
end

function QUIWidgetSanctuaryEliminateMap:_onTriggerReplay3(event)
    if q.buttonEventShadow(event, self._ccbOwner.camera_3) == false then return end
	self:playBattleByIndex(3)
end

function QUIWidgetSanctuaryEliminateMap:_onTriggerReplay4(event)
    if q.buttonEventShadow(event, self._ccbOwner.camera_4) == false then return end
	self:playBattleByIndex(4)
end

function QUIWidgetSanctuaryEliminateMap:_onTriggerReplay5(event)
    if q.buttonEventShadow(event, self._ccbOwner.camera_5) == false then return end
	self:playBattleByIndex(5)
end

function QUIWidgetSanctuaryEliminateMap:_onTriggerReplay6(event)
    if q.buttonEventShadow(event, self._ccbOwner.camera_6) == false then return end
	self:playBattleByIndex(6)
end

function QUIWidgetSanctuaryEliminateMap:_onTriggerReplay7(event)
    if q.buttonEventShadow(event, self._ccbOwner.camera_7) == false then return end
	self:playBattleByIndex(7)
end

function QUIWidgetSanctuaryEliminateMap:_onTriggerLeft(e)
	self._currentIndex = self._currentIndex - 1
	if self._currentIndex < 1 then
		self._currentIndex = self._totalPage
	end
	self:showInfo()
end

function QUIWidgetSanctuaryEliminateMap:_onTriggerRight(e)
	self._currentIndex = self._currentIndex + 1
	if self._currentIndex > self._totalPage then
		self._currentIndex = 1
	end
	self:showInfo()
end

function QUIWidgetSanctuaryEliminateMap:_groupClickHandler(event)
	self._currentIndex = event.index
	self:showInfo()
end


return QUIWidgetSanctuaryEliminateMap