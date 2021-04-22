-- @Author: xurui
-- @Date:   2016-12-14 18:08:51
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-09-21 11:00:00
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogInvasionKillAward = class("QUIDialogInvasionKillAward", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QScrollView = import("...views.QScrollView") 
local QUIWidgetInvasionKillAwardClient = import("..widgets.QUIWidgetInvasionKillAwardClient")
local QListView = import("...views.QListView")

function QUIDialogInvasionKillAward:ctor(options)
	local ccbFile = "ccb/Dialog_panjun_jishajiangli.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerGetAll", callback = handler(self, self._onTriggerGetAll)},
	}
	QUIDialogInvasionKillAward.super.ctor(self, ccbFile, callBack, options)
	self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._ccbOwner.frame_tf_title:setString("击杀奖励")
	self._callback = options.callBack
end

function QUIDialogInvasionKillAward:viewDidAppear()
	QUIDialogInvasionKillAward.super.viewDidAppear(self)

	self:_initClient()
end

function QUIDialogInvasionKillAward:viewWillDisappear()
	QUIDialogInvasionKillAward.super.viewWillDisappear(self)
end

function QUIDialogInvasionKillAward:viewAnimationInHandler()
	self:_initScrollView()
end

function QUIDialogInvasionKillAward:_initScrollView()
    if not self._contentListView then
        local cfg = {
            renderItemCallBack = handler(self,self._reandFunHandler),
            ignoreCanDrag = true,
            totalNumber = #self._awards,
            spaceY = 0,
	        curOffset = 6,
	        enableShadow = false,
        }  
        self._contentListView = QListView.new(self._ccbOwner.sheet_layout, cfg)
    else
        self._contentListView:reload({totalNumber = #self._awards})
    end
end

function QUIDialogInvasionKillAward:_reandFunHandler( list, index, info )
    local isCacheNode = true
    local masterConfig = self._awards[index]
    local item = list:getItemFromCache()
    if not item then
        item = QUIWidgetInvasionKillAwardClient.new()
        isCacheNode = false
    end
    item:setInfo({award = masterConfig, index = index, parent = self}) 
    item:addEventListener(QUIWidgetInvasionKillAwardClient.GET_AWARD, handler(self, self._clickAwards))
    item:setPositionX(10)
    info.item = item
    info.size = item:getContentSize()
    list:registerTouchHandler(index, "onTouchListView")
    list:registerBtnHandler(index, "btn_get", "_onTriggerGet",nil,true)

    return isCacheNode
end

function QUIDialogInvasionKillAward:_initClient()
	self._awards = remote.invasion:getInvasionKillAwards()
	if self._awards == nil or next(self._awards) == nil then 
		self:getView():setVisible(false)
		self:enableTouchSwallowTop()
		scheduler.performWithDelayGlobal(function ()
			self:_onTriggerClose()
		end,0)
		remote.invasion:setKillAwardTipState(false)
		if self._callback then
			self._callback()
		end
		return 
	else
		if self._contentListView then
        	self._contentListView:reload({totalNumber = #self._awards})
    	end
	end
end

function QUIDialogInvasionKillAward:getContentListView()
    return self._contentListView
end

function QUIDialogInvasionKillAward:_clickAwards(event)
	if event == nil or event.awardId == nil then return end

	self:_getAwards(event.awardId, event.award, event.title)
end

function QUIDialogInvasionKillAward:_getAwards(awardId, award, title)
	local awards = clone(award)
	remote.invasion:getIntrusionKillAwardRequest(awardId,false, function()
			if self:safeCheck() then
				remote.invasion:deleteKillAward(awardId)

		  		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
		    		options = {awards = awards, callBack = function ()
		    			if self:safeCheck() then
							self:_initClient()
						end
		    		end}},{isPopCurrentDialog = false} )
		   		dialog:setTitle(title)
			end
		end)
end

function QUIDialogInvasionKillAward:_onTriggerGetAll(event)
	if q.buttonEventShadow(event, self._ccbOwner.Button_Receive) == false then return end
	app.sound:playSound("common_small")
	local award = {}

	for i = 1, #self._awards do
		local awardsInfo = string.split(self._awards[i].awardStr, ";")
		for i = 1, #awardsInfo do
			if awardsInfo[i] then
				local data = string.split(awardsInfo[i], "^")
				local itemType = ITEM_TYPE.ITEM
				if tonumber(data[1]) == nil then
					itemType = data[1]
				end
				table.insert(award, {id = tonumber(data[1]), typeName = itemType, count = tonumber(data[2])})
			end
		end
	end

	self:_getAwards(nil, award, "奖励")
end

function QUIDialogInvasionKillAward:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogInvasionKillAward:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.button_cloose) == false then return end
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogInvasionKillAward:viewAnimationOutHandler()
	self:popSelf()
end


return QUIDialogInvasionKillAward