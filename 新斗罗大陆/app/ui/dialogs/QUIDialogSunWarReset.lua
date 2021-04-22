--
-- Author: Kumo.Wang
-- Date: Wed May 18 14:25:43 2016
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSunWarReset = class("QUIDialogSunWarReset", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")


function QUIDialogSunWarReset:ctor( options )
	local ccbFile = "ccb/Dialog_Reset.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerChoose", callback = handler(self, QUIDialogSunWarReset._onTriggerChoose)},
        {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogSunWarReset._onTriggerClose)},
        {ccbCallbackName = "onTriggerOK", callback = handler(self, QUIDialogSunWarReset._onTriggerOK)},
    }
    QUIDialogSunWarReset.super.ctor(self, ccbFile, callBacks, options)
    -- local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()

	self.isAnimation = true

    self._resetMode = options.resetMode or 0

    self._ccbOwner.frame_tf_title:setString("海神岛重置")
    self._ccbOwner.tf_title_3:setString("请选择海神岛重置的方式")

    self._ccbOwner.tf_reset_explain:setString("明日海神岛重置至历史最高章节的第一关")
    self._ccbOwner.tf_back_explain:setString("明日海神岛重置至历史最高章节前一章的第一关")

    local mapID = remote.sunWar:getMapIDWithLastWaveID()
    if remote.sunWar:IsChaptersAwardedByMapID(mapID) and remote.sunWar:checkIsLastPassedWave() == false then
        mapID = mapID + 1
    end
    if not mapID or mapID == 0 then mapID = 1 end
    local resetMapInfo = remote.sunWar:getMapInfoByMapID(mapID)
    if mapID == 1 then
        self._noBack = true
        self._ccbOwner.tf_reset_info:setString("可重置至\nLV."..resetMapInfo.chapter.." "..resetMapInfo.name)
        self._ccbOwner.tf_back_info:setString("未开启")
        makeNodeFromNormalToGray(self._ccbOwner.node_back_title)
    else
        self._noBack = false
        local backMapInfo = remote.sunWar:getMapInfoByMapID(mapID - 1)
        self._ccbOwner.tf_reset_info:setString("可重置至\nLV."..resetMapInfo.chapter.." "..resetMapInfo.name)
        self._ccbOwner.tf_back_info:setString("可重置至\nLV."..backMapInfo.chapter.." "..backMapInfo.name)
        makeNodeFromGrayToNormal(self._ccbOwner.node_back_title)
    end
    
    self._ccbOwner.tf_tips:setString("")

    self:_resetChooseState()

    if self._resetMode == 1 then
    	self._choose = 1
		self._ccbOwner.back_on:setVisible(true)
    else
    	self._choose = 0
		self._ccbOwner.reset_on:setVisible(true)
    end

    self._ccbOwner.node_btn_ok:setVisible(true)
end

function QUIDialogSunWarReset:viewDidAppear()
	QUIDialogSunWarReset.super.viewDidAppear(self)
	self:addBackEvent(false)
end

function QUIDialogSunWarReset:viewWillDisappear()
	QUIDialogSunWarReset.super.viewWillDisappear(self)
	self:removeBackEvent()
end

function QUIDialogSunWarReset:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogSunWarReset:_onTriggerChoose( event, target )
    app.sound:playSound("common_switch")
	self:_resetChooseState()
	if target == self._ccbOwner.btn_reset_choose or self._noBack then
		self._choose = 0
		self._ccbOwner.reset_on:setVisible(true)
        if self._noBack then
            local mapInfo = remote.sunWar:getMapInfoByMapID(1)
            app.tip:floatTip("魂师大人，章节回退功能将在您通过LV."..mapInfo.chapter.." "..mapInfo.name.."后开放。")
        end
	elseif target == self._ccbOwner.btn_back_choose then
		self._choose = 1
		self._ccbOwner.back_on:setVisible(true)
	end
end

function QUIDialogSunWarReset:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
	app.sound:playSound("common_cancel")
   	self:playEffectOut()
end

function QUIDialogSunWarReset:_onTriggerOK(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_ok) == false then return end
	if not self._choose then self._choose = 0 end
    app.sound:playSound("common_confirm")
	app:getClient():sunwarSetResetModeRequest(self._choose, function(response)
			remote.sunWar:responseHandler(response)
			self:playEffectOut()
		end)
end

function QUIDialogSunWarReset:onTriggerBackHandler(tag)
	self:_onTriggerBack()
end

function QUIDialogSunWarReset:onTriggerHomeHandler(tag)
	self:_onTriggerHome()
end

function QUIDialogSunWarReset:_resetChooseState()
    self._ccbOwner.reset_on:setVisible(false)
    self._ccbOwner.back_on:setVisible(false)
end

function QUIDialogSunWarReset:_onTriggerBack()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogSunWarReset:_onTriggerHome()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

----------------------------------------------------- System callbacks --------------------------------------------------

function QUIDialogSunWarReset:_backClickHandler()
	self:_onTriggerClose()
end


return QUIDialogSunWarReset