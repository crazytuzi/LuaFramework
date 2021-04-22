-- @Author: liaoxianbo
-- @Date:   2019-12-18 15:58:33
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-12-26 11:45:18
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogCollegeTrainFamousPerson = class("QUIDialogCollegeTrainFamousPerson", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetFamousPerson = import("..widgets.QUIWidgetFamousPerson")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")


QUIDialogCollegeTrainFamousPerson.QUANFU_RANK = 1
QUIDialogCollegeTrainFamousPerson.BENGFU_RANK = 2

function QUIDialogCollegeTrainFamousPerson:ctor(options)
	local ccbFile = "ccb/Dialog_CollegeTrainRank_mingrentang.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerTabQuanFu", callback = handler(self,self._onTriggerTabQuanFu)},
		{ccbCallbackName = "onTriggerTabBenFu", callback = handler(self,self._onTriggerTabBenFu)},
		{ccbCallbackName = "onTriggerHelp", callback = handler(self,self._onTriggerHelp)},
    }
    QUIDialogCollegeTrainFamousPerson.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    ui.tabButton(self._ccbOwner.btn_tab_quanfu, "全服")
    ui.tabButton(self._ccbOwner.btn_tab_benfu, "本服")
    self._ccbOwner.node_right_center:setVisible(false)
	self._tabManager = ui.tabManager({self._ccbOwner.btn_tab_quanfu, self._ccbOwner.btn_tab_benfu})

	self._chapterId = options.chapterId
	self._curtentTab = options.tabType or QUIDialogCollegeTrainFamousPerson.QUANFU_RANK
	self._rankApi = "CELEBRITY_HALL_INTEGRAL_TOP_50"
    self._fighter = {}
    self:_resetAll()

    self:selectTab(self._curtentTab)
end

function QUIDialogCollegeTrainFamousPerson:viewDidAppear()
	QUIDialogCollegeTrainFamousPerson.super.viewDidAppear(self)
	
end

function QUIDialogCollegeTrainFamousPerson:viewWillDisappear()
  	QUIDialogCollegeTrainFamousPerson.super.viewWillDisappear(self)

	self:removeBackEvent()
end

function QUIDialogCollegeTrainFamousPerson:selectTab(tablType)
	if tablType == QUIDialogCollegeTrainFamousPerson.QUANFU_RANK then
		self._rankApi = "COLLEGE_TRAIN_HALL_TOP_3"
		self._ccbOwner.frame_tf_title:setString("全服名人堂")
		self._tabManager:selected(self._ccbOwner.btn_tab_quanfu)
	else
		self._rankApi = "COLLEGE_TRAIN_ENV_HALL_TOP_3"
		self._ccbOwner.frame_tf_title:setString("本服名人堂")
		self._tabManager:selected(self._ccbOwner.btn_tab_benfu)
	end
	self:_update()
end

function QUIDialogCollegeTrainFamousPerson:_resetAll()
	for i = 1, 3 do
		if self._fighter[i] ~= nil then
			self._fighter[i]:removeFromParent()
			self._fighter[i] = nil
		end

		if self._fighter[i] == nil then
			self._fighter[i] = QUIWidgetFamousPerson.new({index = i})
			self._fighter[i]:resetAll()
			self._ccbOwner["node_fighter_"..i]:addChild(self._fighter[i])
		end
	end
end

function QUIDialogCollegeTrainFamousPerson:_update()
	app:getClient():top50RankCollegeTrainRequest(self._rankApi, remote.user.userId,self._chapterId, function (data)
		if data.rankings == nil or data.rankings.top50 == nil then 
			return 
		end
		self._list = nil
		self._list = clone(data.rankings.top50)
		table.sort(self._list, function (x, y)
			return x.rank < y.rank
		end)
		self:setInfo(true)
	end)
end

function QUIDialogCollegeTrainFamousPerson:setInfo(refresh)
	if refresh then
		self:_resetAll()
		for i = 1, 3 do		
	        local effect = QUIWidgetAnimationPlayer.new()
	        self._fighter[i]:addChild(effect)
	        -- effect:retain()
	        effect:playAnimation("effects/ChooseHero.ccbi",nil,function ()
	            effect:removeFromParent()
	            -- effect:release()
	            effect = nil
	        end)
			self._fighter[i]:setFighterInfo(self._list[i], i,true,self._curtentTab)
		end
	else
		for index, value in ipairs(self._list) do
			if index > 3 then return end
			self._fighter[index]:setFighterInfo(value, index,true)
		end
	end
end 

function QUIDialogCollegeTrainFamousPerson:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogCollegeTrainFamousPerson:_onTriggerTabQuanFu( )
	if self._curtentTab == QUIDialogCollegeTrainFamousPerson.QUANFU_RANK then return end
	self._curtentTab = QUIDialogCollegeTrainFamousPerson.QUANFU_RANK
	self:selectTab(self._curtentTab)
end

function QUIDialogCollegeTrainFamousPerson:_onTriggerTabBenFu(  )
	if self._curtentTab == QUIDialogCollegeTrainFamousPerson.BENGFU_RANK then return end
	self._curtentTab = QUIDialogCollegeTrainFamousPerson.BENGFU_RANK
	self:selectTab(self._curtentTab)
end

function QUIDialogCollegeTrainFamousPerson:_onTriggerHelp()
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDailogCollegeTrainRule"})
end

function QUIDialogCollegeTrainFamousPerson:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_close) == false then return end
	if event then
    	app.sound:playSound("common_cancel")
    end
    self:playEffectOut()
    if self._callBack and self._selectName then
    	self._callBack(self._selectName)
    end
end

function QUIDialogCollegeTrainFamousPerson:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogCollegeTrainFamousPerson
