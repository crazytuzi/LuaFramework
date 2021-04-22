local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogQuickChangeThreeTeam = class("QUIDialogQuickChangeThreeTeam", QUIDialog)
local QUIWidgetQuickChange = import("..widgets.QUIWidgetQuickChange")
local QBaseArrangementWithDataHandle = import("...arrangement.QBaseArrangementWithDataHandle")



function QUIDialogQuickChangeThreeTeam:ctor(options)
	local ccbFile = "ccb/Dialog_TeamChange3_OneKey.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogQuickChangeThreeTeam.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._teamTotalInfo = options.teamTotalInfo
        self._callBack = options.callBack
        self._detailFunc = options.detailFunc
        self._enemyFighter = options.enemyFighter
    end
    self:handleData()
    self._ccbOwner.frame_tf_title:setString("一键换队")
	self:setTeamInfo()
end


function QUIDialogQuickChangeThreeTeam:viewDidAppear()
	QUIDialogQuickChangeThreeTeam.super.viewDidAppear(self)
end

function QUIDialogQuickChangeThreeTeam:viewWillDisappear()
  	QUIDialogQuickChangeThreeTeam.super.viewWillDisappear(self)
end

function QUIDialogQuickChangeThreeTeam:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogQuickChangeThreeTeam:handleData()
	self._maxNumTbl = {}
	for trialNum,groupInfo in ipairs(self._teamTotalInfo or {}) do
		if self._maxNumTbl[trialNum] == nil then -- 队伍
			self._maxNumTbl[trialNum] = {}
		end

		for i,v in ipairs(groupInfo) do

			local teamIdx = v.index
			local oType =  v.oType % 100
			if self._maxNumTbl[trialNum][teamIdx] == nil then
				self._maxNumTbl[trialNum][teamIdx] ={}
			end
			if self._maxNumTbl[trialNum][teamIdx][oType] == nil then
				self._maxNumTbl[trialNum][teamIdx][oType] = {i}
			else
				table.insert(self._maxNumTbl[trialNum][teamIdx][oType] ,i)
			end
		end

	end
end

--封装拆解数据

--对象互换规则
--[[
	单个对象 判断 类型oType相同
	组 ：存储对象 判断 判断是否满足特殊需求 排位置
]]


function QUIDialogQuickChangeThreeTeam:setTeamInfo()
	local height = 0
	for i=1,3 do
		local data = self._teamTotalInfo[i]
		if self["_teamClient"..i] == nil then
			self["_teamClient"..i]  = QUIWidgetQuickChange.new()
			self["_teamClient"..i] :addEventListener(QUIWidgetQuickChange.EVENT_CLICK_DETAIL, handler(self, self._onClickDetail))
			self["_teamClient"..i] :addEventListener(QUIWidgetQuickChange.EVENT_CLICK_TEAM_CHANGE, handler(self, self._onClickTeamChange))
			self["_teamClient"..i] :addEventListener(QUIWidgetQuickChange.EVENT_CLICK_HERO_HEAD, handler(self, self._onClickHeroHead))
			self._ccbOwner.sheet:addChild(self["_teamClient"..i] )
			self["_teamClient"..i] :setPositionY(-height)
			height = height + self["_teamClient"..i] :getContentSize().height
			local _fighterInfo = self._enemyFighter[i]
			self["_teamClient"..i]:setInfo(data , i ,_fighterInfo)
		else
			self["_teamClient"..i]:updateHeroHead(data)
		end
		
	end

end


function QUIDialogQuickChangeThreeTeam:_onClickDetail(event)


	if self._detailFunc then
		self._detailFunc(event)
	end
end

function QUIDialogQuickChangeThreeTeam:_onClickTeamChange(event)
	if event == nil or self._isExchange then return end
	self:removeSelectEffect()
	local trialNum = event.trialNum
	if self._selectTrialNum ~= nil and self._selectTrialNum ~= trialNum then
		self._isExchange = true

		self["_teamClient"..trialNum]:showAllHeroHeadEffect()
		self["_teamClient"..self._selectTrialNum]:showAllHeroHeadEffect()

		--全队互换
		for i,v in ipairs(self._teamTotalInfo[self._selectTrialNum]) do
			self:exchangeHead(self._selectTrialNum ,trialNum ,i,i)
		end
		for i = 1, 3 do
			if self["_teamClient"..i] then
				self["_teamClient"..i]:setChangeButton(true, true)
			end
		end
		RunActionDelayTime(self:getView(), function()
				self:removeExchangeButton()
				self:setTeamInfo()
				self._isExchange = false
			end, 0.9)
	else
		for i = 1, 3 do
			if self["_teamClient"..i] then
				self["_teamClient"..i]:setChangeButton(i == trialNum, true)
			end
		end
		self._selectTrialNum = trialNum
	end

end

function QUIDialogQuickChangeThreeTeam:_onClickHeroHead(event)
	if event == nil or self._isExchange then return end
	local trialNum = event.trialNum
	local idx = event.idx
	if trialNum ==nil  or idx == nil then return end

	if self._selectInfo ~= nil then



		if self._selectInfo.trialNum == trialNum and self._selectInfo.idx == idx then
			if self["_teamClient"..trialNum] then
				self["_teamClient"..trialNum]:hideSelectEffect()
				self["_teamClient"..trialNum]:showChangeEffect(idx)
			end
			self:removeExchangeButton()
			self._selectInfo = nil
			return
		end

		local isExchange , tips , isRefreshCur = self:exchangeHead(self._selectInfo.trialNum,trialNum,self._selectInfo.idx,idx)
		if not isExchange then
			app.tip:floatTip(tips) 

			if isRefreshCur then
				if self["_teamClient"..self._selectInfo.trialNum] then
					self["_teamClient"..self._selectInfo.trialNum]:hideSelectEffect()
				end
				self:removeExchangeButton()
				if self["_teamClient"..trialNum] then
					self["_teamClient"..trialNum]:hideSelectEffect()
					self["_teamClient"..trialNum]:showSelectEffect(idx)
				end
				self._selectInfo = {idx = idx , trialNum = trialNum}
			end

			return
		end

		if self["_teamClient"..self._selectInfo.trialNum] then
			self["_teamClient"..self._selectInfo.trialNum]:hideSelectEffect()
			self["_teamClient"..self._selectInfo.trialNum]:showChangeEffect(self._selectInfo.idx)
		end
		if self["_teamClient"..trialNum] then
			self["_teamClient"..trialNum]:hideSelectEffect()
			self["_teamClient"..trialNum]:showChangeEffect(idx)
		end

		self._isExchange = true
		self:removeExchangeButton()
		RunActionDelayTime(self:getView(), function()
				self:removeSelectEffect()
				self:setTeamInfo()
				self._isExchange = false
			end, 0.9)
	else
		local newInfo = self._teamTotalInfo[trialNum][idx]
		if newInfo.oType > QBaseArrangementWithDataHandle.ELEMENT_TYPE.LOCK_ELE_TYPE  then
			app.tip:floatTip("未解锁，无法选择交换") 
			return
		end	

		self:removeExchangeButton()
		if self["_teamClient"..trialNum] then
			self["_teamClient"..trialNum]:hideSelectEffect()
			self["_teamClient"..trialNum]:showSelectEffect(idx)
		end
		self._selectInfo = {idx = idx , trialNum = trialNum}
	end
end

function QUIDialogQuickChangeThreeTeam:exchangeHead(oldTrialNum,newTrialNum,oldIdx,newIdx)
	local oldData = self._teamTotalInfo[oldTrialNum][oldIdx]
	local newData = self._teamTotalInfo[newTrialNum][newIdx]

	if oldData == nil or newData == nil then return end

	if oldData.oType > QBaseArrangementWithDataHandle.ELEMENT_TYPE.LOCK_ELE_TYPE or newData.oType > QBaseArrangementWithDataHandle.ELEMENT_TYPE.LOCK_ELE_TYPE then
		return false , "未解锁，无法选择交换" ,false
	end

	local oldtype = oldData.oType % 100
	local newtype = newData.oType % 100
	if oldtype ~= newtype then
		return false , "选择类型不一致，无法交换" , true
	end
	
	if oldtype == QBaseArrangementWithDataHandle.ELEMENT_TYPE.GODARM_ELE_TYPE and newtype == QBaseArrangementWithDataHandle.ELEMENT_TYPE.GODARM_ELE_TYPE then
		if not self:checkGodArmLabel(oldTrialNum,newTrialNum,oldIdx,newIdx) then
			return false ,"同类型神器太多，无法交换" , false
		end
	end


	local teamInfo1 = {index = oldData.index ,trialNum = oldData.trialNum , pos =  oldData.trialNum }
	local teamInfo2 = {index = newData.index ,trialNum = newData.trialNum , pos =  newData.trialNum }


	local tempNew  = clone(newData)
	tempNew.index = teamInfo1.index 
	tempNew.trialNum = teamInfo1.trialNum 
	tempNew.pos = teamInfo1.pos 
	local tempOld  = clone(oldData)
	tempOld.index = teamInfo2.index 
	tempOld.trialNum = teamInfo2.trialNum 
	tempOld.pos = teamInfo2.pos 	

	self._teamTotalInfo[oldTrialNum][oldIdx] = tempNew
	self._teamTotalInfo[newTrialNum][newIdx] = tempOld


	return true
end

function QUIDialogQuickChangeThreeTeam:checkGodArmLabel(oldTrialNum,newTrialNum,oldIdx,newIdx)
	if oldTrialNum == newTrialNum then return true end

	local oldData = self._teamTotalInfo[oldTrialNum][oldIdx]
	local newData = self._teamTotalInfo[newTrialNum][newIdx]
	local oldlabel = oldData.label
	local newlabel = newData.label
	local oldtype = oldData.oType % 100
	local newtype = newData.oType % 100
	if oldlabel == newlabel then return true end

	local godArmIds = self._maxNumTbl[oldData.trialNum][oldData.index][oldtype] or {}
	local num = 0
	for i,v in ipairs(godArmIds) do
		if num >= 2 then
			return false
		end
		-- if oldData.pos ~= i then
			local data = self._teamTotalInfo[oldTrialNum][v]
			QPrintTable(data)
			if data.label and data.label == newlabel then
				num = num + 1
			end
		-- end
	end

	godArmIds = self._maxNumTbl[newData.trialNum][newData.index][newtype] or {}
	num = 0
	for i,v in ipairs(godArmIds) do
		if num >= 2 then
			return false
		end
		-- if newData.pos ~= i then
			local data = self._teamTotalInfo[newTrialNum][v]
			if data.label and data.label == oldlabel then
				QPrintTable(data)
				num = num + 1
			end
		-- end
	end

	return true
end

function QUIDialogQuickChangeThreeTeam:removeSelectEffect()
	for i = 1, 3 do
		if self["_teamClient"..i] then
			self["_teamClient"..i]:hideSelectEffect()
		end
	end
	self._selectInfo = nil
end

function QUIDialogQuickChangeThreeTeam:removeExchangeButton()
	for i = 1, 3 do
		if self["_teamClient"..i] then
			self["_teamClient"..i]:setChangeButton(false, false)
		end
	end
	self._selectTrialNum = nil
end

function QUIDialogQuickChangeThreeTeam:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_close) == false then return end
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogQuickChangeThreeTeam:viewAnimationOutHandler()
	local callback = self._callBack
	self:popSelf()
	if callback then
		scheduler.performWithDelayGlobal(callback, 0)
	end
end

return QUIDialogQuickChangeThreeTeam