-- @Author: xurui
-- @Date:   2016-08-18 14:48:15
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-10-17 17:28:18
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogFamousPerson = class("QUIDialogFamousPerson", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetFamousPerson = import("..widgets.QUIWidgetFamousPerson")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

function QUIDialogFamousPerson:ctor(options)
	local ccbFile = "ccb/Dialog_Rank_mingrentang.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerGotoFamousPerson", callback = handler(self, self._onTriggerGotoFamousPerson)},
		{ccbCallbackName = "onTriggerHelp", callback = handler(self, self._onTriggerHelp)},
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogFamousPerson.super.ctor(self, ccbFile, callBacks, options)

	self.isAnimation = true
    self._callBack = options.callBack
    self._ccbOwner.frame_tf_title:setString("名人堂")

    self._fighter = {}
    self:_resetAll()
end

function QUIDialogFamousPerson:viewDidAppear()
	QUIDialogFamousPerson.super.viewDidAppear(self)
	self:_update()
end

function QUIDialogFamousPerson:viewWillDisappear()
	QUIDialogFamousPerson.super.viewWillDisappear(self)
end

function QUIDialogFamousPerson:_resetAll()
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

function QUIDialogFamousPerson:_update()
	app:getClient():top50RankRequest("CELEBRITY_HALL_INTEGRAL_TOP_50", remote.user.userId, function (data)
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

function QUIDialogFamousPerson:setInfo(refresh)
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
			self._fighter[i]:setFighterInfo(self._list[i], i)
		end
	else
		for index, value in ipairs(self._list) do
			if index > 3 then return end
			self._fighter[index]:setFighterInfo(value, index)
		end
	end
end 

function QUIDialogFamousPerson:_onTriggerGotoFamousPerson(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_back) == false then return end
    app.sound:playSound("common_menu")
    self._selectName = "famousPerson"
    self:_onTriggerClose()
end

function QUIDialogFamousPerson:_onTriggerHelp()
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogFamousPersonRule"})
end

function QUIDialogFamousPerson:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_close) == false then return end
	if event then
    	app.sound:playSound("common_cancel")
    end
    self:playEffectOut()
    if self._callBack and self._selectName then
    	self._callBack(self._selectName)
    end
end

function QUIDialogFamousPerson:onTriggerBackHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogFamousPerson