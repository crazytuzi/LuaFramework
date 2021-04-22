local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogBlackRockChoose = class("QUIDialogBlackRockChoose", QUIDialog)
local QUIWidgetBlackRockChoose = import("..widgets.blackrock.QUIWidgetBlackRockChoose")
local QListView = import("...views.QListView")
local QUIViewController = import("..QUIViewController")
local QNavigationController = import("...controllers.QNavigationController")

function QUIDialogBlackRockChoose:ctor(options)
	local ccbFile = "ccb/Dialog_Black_mountain_choose.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerAutoFind", callback = handler(self, self._onTriggerAutoFind)}, 
        {ccbCallbackName = "onTriggerCreate", callback = handler(self, self._onTriggerCreate)},
        {ccbCallbackName = "onTriggerSearch", callback = handler(self, self._onTriggerSearch)},
        {ccbCallbackName = "onTriggerHidePassWord", callback = handler(self, self._onTriggerHidePassWord)},
        {ccbCallbackName = "onTriggerHideFull", callback = handler(self, self._onTriggerHideFull)},
	}
	QUIDialogBlackRockChoose.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true

	self._ccbOwner.node_no:setVisible(false)

	self._teams = {}
	self._info = {}
	if options then
		self._teams = self:_handleTeamsDataByTime(options.teams )
		self._allTeams = options.teams or {}
		self._info = options.info
	end

	self:initButtonState()
	local teamSelectSet = app:getUserOperateRecord():getBlackRockTeamSetInfo()
	self._selectHideState = teamSelectSet and (teamSelectSet.hidePassWord or false) or false
	self._selectHideFullState = teamSelectSet and (teamSelectSet.hideFull or false) or false
	self:setChooseState()
	-- self._teams = {}
	self:initListView()
end

function QUIDialogBlackRockChoose:initButtonState( )
	q.setButtonEnableShadow(self._ccbOwner.btn_serach)
	q.setButtonEnableShadow(self._ccbOwner.btn_creat)
	q.setButtonEnableShadow(self._ccbOwner.btn_autoPipei)
	q.setButtonEnableShadow(self._ccbOwner.btn_close)
end

function QUIDialogBlackRockChoose:viewDidAppear()
    QUIDialogBlackRockChoose.super.viewDidAppear(self)

    self:setInfo()
end

function QUIDialogBlackRockChoose:viewWillDisappear()
    QUIDialogBlackRockChoose.super.viewWillDisappear(self)

end

function QUIDialogBlackRockChoose:setChooseState()
	self._ccbOwner.sp_select_1:setVisible(self._selectHideState)
	self._ccbOwner.sp_no_select_1:setVisible(not self._selectHideState)

	self._ccbOwner.sp_select_2:setVisible(self._selectHideFullState)
	self._ccbOwner.sp_no_select_2:setVisible(not self._selectHideFullState)

	local setting = {}
	setting.hidePassWord = self._selectHideState
	setting.hideFull = self._selectHideFullState
	app:getUserOperateRecord():setBlackRockTeamSetInfo(setting)

	self:sortTeamInfo(self._selectHideState,self._selectHideFullState)
end
function QUIDialogBlackRockChoose:setInfo()
	if next(self._info) ~= nil then
		self._ccbOwner.frame_tf_title:setString(self._info[1].name or "")
	end
end

function QUIDialogBlackRockChoose:initListView( ... )
	-- body
	if not self._listViewLayout then
		local cfg = {
			renderItemCallBack = handler(self, self.renderItemHandler),
	      	ignoreCanDrag = true,
	        totalNumber = #self._teams,
	        spaceY = 3,
	        curOriginOffset = 3,
	        curOffset = 3,
	        topShadow = self._ccbOwner.sp_top,
	        bottomShadow = self._ccbOwner.sp_bottom,
		}
		self._listViewLayout = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else
		self._listViewLayout:reload({totalNumber = #self._teams})
	end
	self._ccbOwner.node_no:setVisible(#self._teams == 0)
end

function QUIDialogBlackRockChoose:renderItemHandler(list, index, info )
    local isCacheNode = true
    local itemData = self._teams[index]

    local item = list:getItemFromCache()
    if not item then
    	item = QUIWidgetBlackRockChoose.new()
        isCacheNode = false
    end

    item:setInfo(itemData)
    info.item = item
    info.size = item:getContentSize()

    list:registerBtnHandler(index,"btn_join", handler(self, self.clickHandler),nil,true)

    return isCacheNode
end

function QUIDialogBlackRockChoose:checkHaveAwardsCount(callbackHandler)
	if remote.blackrock:getAwardCount() > 0 then
		callbackHandler()
	else

		local content = "魂师大人，您当前已无领奖次数，战斗结束将无法获得奖励，是否继续？"
		app:alert({content = content, colorful = true, title = "系统提示", callback = function (type)
			if type == ALERT_TYPE.CONFIRM then
				callbackHandler()
			end
		end}, false)
	end
end

function QUIDialogBlackRockChoose:clickHandler(x, y, touchNode, listView )
	-- body
	app.sound:playSound("common_switch")
    local touchIndex = listView:getCurTouchIndex()

    local callFun = function ()
    	local teamInfo = self._teams[touchIndex] or {}
    	if teamInfo.password == nil or teamInfo.password == "" then
			remote.blackrock:blackRockJoinTeamRequest(self._teams[touchIndex].teamId, self._info[1].id, nil,0,function()
					if self:safeCheck() then
						self:popSelf()
						app:getServerChatData():refreshTeamChatInfo()
						app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBlackRockTeam"})
					end
				end)
		else
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBlackRockJoinTeam", 
				options = {teamInfo = self._teams[touchIndex], chapterId = self._info[1].id, callback = function ()
					if self:safeCheck() then
						self:popSelf()
					end
				end}},{isPopCurrentDialog = false})
		end
    end
	self:checkHaveAwardsCount(callFun)
end

function QUIDialogBlackRockChoose:_onTriggerSearch(event)
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBlackRockSearchRoom", 
		options = {chapterId = self._info[1].id, callBack = function (teams)
			if self:safeCheck() then
				if teams ~= nil and next(teams) ~= nil then
					self._teams = self:_handleTeamsDataByTime({teams})or {}
				else
					app.tip:floatTip("魂师大人，没有找到对应的队伍")
				end
				self:initListView()
			end
		end}},{isPopCurrentDialog = false})
end

function QUIDialogBlackRockChoose:sortTeamInfo(passwordState,fullState)
	if next(self._allTeams) == nil then return end
	local noPassTeams = {}
	if passwordState then
		for _,teamsInfo in pairs(self._allTeams) do
			if teamsInfo.password == nil or teamsInfo.password == "" then
				table.insert( noPassTeams, teamsInfo )
			end
		end
	else
		noPassTeams = self._allTeams
	end

	local notFullTeams = {}
	if fullState then
		if fullState then
			if next(noPassTeams) ~= nil then
				for _,notFullTeamInfo in pairs(noPassTeams) do
					if notFullTeamInfo.memberCnt and notFullTeamInfo.memberCnt < 3 then
						table.insert( notFullTeams, notFullTeamInfo )
					end
				end
			end
		end
	else
		notFullTeams = noPassTeams
	end

	if passwordState == false and fullState == false then
		-- self._teams = self._allTeams
		self._teams = self:_handleTeamsDataByTime(self._allTeams)
	else
		-- self._teams = notFullTeams
		self._teams = self:_handleTeamsDataByTime(notFullTeams)
	end

	self:initListView()
end

function QUIDialogBlackRockChoose:_handleTeamsDataByTime(teamsData)
    local notHotTeams = {}
    local teams = {}
    local curTimeSvr = q.serverTime()*1000

    for i,v in ipairs(teamsData or {}) do
        local leaderLastActiveAt = v.leaderLastActiveAt
        if leaderLastActiveAt and curTimeSvr >= leaderLastActiveAt + remote.blackrock.noActiveTimeForMsec then
        	print("Not--Hot")
        	QPrintTable(v)
            table.insert(notHotTeams,v)
        else
        	QPrintTable(v)
            table.insert(teams,v)
        end
    end
    for i,v in ipairs(notHotTeams) do
        table.insert(teams,v)
    end

    return teams
end

function QUIDialogBlackRockChoose:_onTriggerHidePassWord(event)
	self._selectHideState = not self._selectHideState
	-- self._ccbOwner.sp_select_1:setVisible(self._selectHideState)
	-- self._ccbOwner.sp_no_select_1:setVisible(not self._selectHideState)
	self:setChooseState()
	-- self:sortTeamInfo(self._selectHideState,self._selectHideFullState)
end

function QUIDialogBlackRockChoose:_onTriggerHideFull(event)
	self._selectHideFullState = not self._selectHideFullState
	-- self._ccbOwner.sp_select_2:setVisible(self._selectHideFullState)
	-- self._ccbOwner.sp_no_select_2:setVisible(not self._selectHideFullState)
	self:setChooseState()
	-- self:sortTeamInfo(self._selectHideState,self._selectHideFullState)
end

function QUIDialogBlackRockChoose:_onTriggerAutoFind(event) 
	app.sound:playSound("common_switch")
	local callFun = function ()
		remote.blackrock:blackRockAutoJoinTeamRequest(self._info[1].id, function ()
			--xurui: 更新组队聊天信息
			if self:safeCheck() then
				app:getServerChatData():refreshTeamChatInfo()

				self:popSelf()
				app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBlackRockTeam"})
			end
		end)
	end
	self:checkHaveAwardsCount(callFun)
end

function QUIDialogBlackRockChoose:_onTriggerCreate(event)
	app.sound:playSound("common_switch")
	local callFun = function ()
		remote.blackrock:blackRockCreateTeamRequest(self._info[1].id, function ()
			if self:safeCheck() then
				--xurui: 更新组队聊天信息
				app:getServerChatData():refreshTeamChatInfo()

				self:popSelf()
				app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBlackRockTeam", options = {isCreat = true}})
			end
		end)
	end
	self:checkHaveAwardsCount(callFun)
end

function QUIDialogBlackRockChoose:_backClickHandler()
	-- body
	self:_onTriggerClose()
end

function QUIDialogBlackRockChoose:_onTriggerClose()
    app.sound:playSound("common_cancel")
	self:playEffectOut()
end

return QUIDialogBlackRockChoose