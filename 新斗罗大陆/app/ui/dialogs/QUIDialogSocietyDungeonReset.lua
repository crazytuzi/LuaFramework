--
-- Author: Kumo.Wang
-- Date: Mon May 23 17:25:13 2016
--
local QUIDialog = import(".QUIDialog")
local QUIDialogSocietyDungeonReset = class("QUIDialogSocietyDungeonReset", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIDialogSocietyDungeonReset:ctor( options )
	local ccbFile = "ccb/Dialog_Reset.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerChoose", callback = handler(self, QUIDialogSocietyDungeonReset._onTriggerChoose)},
        {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogSocietyDungeonReset._onTriggerClose)},
        {ccbCallbackName = "onTriggerOK", callback = handler(self, QUIDialogSocietyDungeonReset._onTriggerOK)},
    }
    QUIDialogSocietyDungeonReset.super.ctor(self, ccbFile, callBacks, options)

	self.isAnimation = true

	self._resetMode = options.resetMode or 0

    self._ccbOwner.frame_tf_title:setString("副本重置")
    self._ccbOwner.tf_title_3:setString("请选择宗门副本重置的方式")

    self._ccbOwner.tf_reset_explain:setString("明日宗门副本重置至历史最高章节")
    self._ccbOwner.tf_back_explain:setString("明日宗门副本重置至历史最高章节前一章")

    local consortia  = remote.union.consortia
    local maxChapter = consortia.max_chapter

    if maxChapter <= 1 then
        self._noBack = true
        local scoietyChapterConfig = 
        -- self._ccbOwner.tf_reset_info:setString("可重置至\nLV."..maxChapter.." "..maxMapInfo[1].chapter_name)
        self._ccbOwner.tf_reset_info:setString("可重置至\n第"..maxChapter.."章")
        self._ccbOwner.tf_back_info:setString("未开启")
        makeNodeFromNormalToGray(self._ccbOwner.node_back_title)
    else
        self._noBack = false
        -- local backMapInfo = QStaticDatabase.sharedDatabase():getScoietyChapter(maxChapter - 1)
        -- self._ccbOwner.tf_reset_info:setString("可重置至\nLV."..maxChapter.." "..maxMapInfo[1].chapter_name)
        self._ccbOwner.tf_reset_info:setString("可重置至\n第"..maxChapter.."章")
        -- self._ccbOwner.tf_back_info:setString("可重置至\nLV."..(maxChapter - 1).." "..backMapInfo[1].chapter_name)
        self._ccbOwner.tf_back_info:setString("可重置至\n第"..(maxChapter - 1).."章")
        makeNodeFromGrayToNormal(self._ccbOwner.node_back_title)
    end
    
    self._ccbOwner.tf_tips:setString("")

    self:_resetChooseState()

    if consortia.bossResetType == 2 then
    	self._choose = 2
		self._ccbOwner.back_on:setVisible(true)
    else
    	self._choose = 1
		self._ccbOwner.reset_on:setVisible(true)
    end
end

function QUIDialogSocietyDungeonReset:viewDidAppear()
	QUIDialogSocietyDungeonReset.super.viewDidAppear(self)
end

function QUIDialogSocietyDungeonReset:viewWillDisappear()
	QUIDialogSocietyDungeonReset.super.viewWillDisappear(self)
end

function QUIDialogSocietyDungeonReset:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogSocietyDungeonReset:_onTriggerChoose( event, target )
    app.sound:playSound("common_switch")
    self:_resetChooseState()
    if target == self._ccbOwner.btn_reset_choose or self._noBack then
        self._choose = 1
        self._ccbOwner.reset_on:setVisible(true)
        if self._noBack then
            app.tip:floatTip("魂师大人，章节回退功能将在您通关第一章后开放。")
        end
    elseif target == self._ccbOwner.btn_back_choose then
        self._choose = 2
        self._ccbOwner.back_on:setVisible(true)
    end
end

function QUIDialogSocietyDungeonReset:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
	app.sound:playSound("common_cancel")
   	self:playEffectOut()
end

function QUIDialogSocietyDungeonReset:_onTriggerOK(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_ok) == false then return end
	if not self._choose or self._choose == 0 then self._choose = 1 end

    if remote.union:checkUnionRight() then
        remote.union:unionSetBossResetTypeRequest(self._choose, function ( response )
                self:playEffectOut()
                app.tip:floatTip("设置成功")
            end, nil)
    else
        app.tip:floatTip("只有宗主可以设置")
    end

    
end

function QUIDialogSocietyDungeonReset:onTriggerBackHandler(tag)
	self:_onTriggerBack()
end

function QUIDialogSocietyDungeonReset:onTriggerHomeHandler(tag)
	self:_onTriggerHome()
end

function QUIDialogSocietyDungeonReset:_resetChooseState()
    self._ccbOwner.reset_on:setVisible(false)
    self._ccbOwner.back_on:setVisible(false)
end

function QUIDialogSocietyDungeonReset:_onTriggerBack()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogSocietyDungeonReset:_onTriggerHome()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

----------------------------------------------------- System callbacks --------------------------------------------------

function QUIDialogSocietyDungeonReset:_backClickHandler()
	self:_onTriggerClose()
end


return QUIDialogSocietyDungeonReset