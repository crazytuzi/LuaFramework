--
-- Author: wkwang
-- 仙品养成穿戴界面
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMagicHerbDetailInfo = class("QUIDialogMagicHerbDetailInfo", QUIDialog)
local QUIWidgetMagicHerbDetail = import("..widgets.QUIWidgetMagicHerbDetail")
local QUIWidgetMagicHerbAdvance = import("..widgets.QUIWidgetMagicHerbAdvance")
local QUIWidgetMagicHerbUpLevel = import("..widgets.QUIWidgetMagicHerbUpLevel")
local QUIWidgetMagicHerbRefine = import("..widgets.QUIWidgetMagicHerbRefine")
local QUIViewController = import("..QUIViewController")

QUIDialogMagicHerbDetailInfo.TAB_DETAIL = 1 -- 详细
QUIDialogMagicHerbDetailInfo.TAB_ADVANCE = 2 -- 升星
QUIDialogMagicHerbDetailInfo.TAB_UPLEVEL = 3 -- 升级
QUIDialogMagicHerbDetailInfo.TAB_REFINE = 4 -- 转生

function QUIDialogMagicHerbDetailInfo:ctor(options)
    local ccbFile = "ccb/Dialog_MagicHerb_xiangqing.ccbi"
    local callBack = {
        {ccbCallbackName = "onTriggerClose",   callback = handler(self, self._onTriggerClose)},
        {ccbCallbackName = "onTriggerDetail",  callback = handler(self, self._onTriggerDetail)},
        {ccbCallbackName = "onTriggerAdvance",  callback = handler(self, self._onTriggerAdvance)},
        {ccbCallbackName = "onTriggerUpLevel",    callback = handler(self, self._onTriggerUpLevel)},
        {ccbCallbackName = "onTriggerRefine",    callback = handler(self, self._onTriggerRefine)},
    }
    QUIDialogMagicHerbDetailInfo.super.ctor(self, ccbFile, callBack, options)
    self.isAnimation = true

    if options ~= nil then
        self._tabType = options.tabType
        self.actorId = options.actorId
        self.pos = options.pos
        self.sid = options.sid
    end
    if self._tabType == nil then
        self._tabType = QUIDialogMagicHerbDetailInfo.TAB_DETAIL
    end
    self:init()
end

function QUIDialogMagicHerbDetailInfo:init( ... )
    self._ccbOwner.node_content:removeAllChildren()
end

function QUIDialogMagicHerbDetailInfo:viewAnimationInHandler( ... )
    self:_switchTab()
end

function QUIDialogMagicHerbDetailInfo:_switchTab( ... )
    self._options.tabType = self._tabType
    if self._currentWidget ~= nil then
        self._currentWidget:setVisible(false)
    end
    self:_resetBtn()
    if self._tabType == QUIDialogMagicHerbDetailInfo.TAB_DETAIL then
        self:_initDetailWidget()
        self._currentWidget = self._detailWidget
        self._currentWidget:setVisible(true)
        self._ccbOwner.btn_detail:setHighlighted(true)
        self._ccbOwner.btn_detail:setEnabled(false)
        self._currentWidget:setInfo()
        return
    end
    if self._tabType == QUIDialogMagicHerbDetailInfo.TAB_ADVANCE then
        self:_initAdvanceWidget()
        self._currentWidget = self._advanceWidget
        self._currentWidget:setVisible(true)
        self._ccbOwner.btn_advance:setHighlighted(true)
        self._ccbOwner.btn_advance:setEnabled(false)
        return
    end
    if self._tabType == QUIDialogMagicHerbDetailInfo.TAB_UPLEVEL then
        self:_initUpLevelWidget()
        self._currentWidget = self._upLevelWidget
        self._currentWidget:setVisible(true)
        self._ccbOwner.btn_upLevel:setHighlighted(true)
        self._ccbOwner.btn_upLevel:setEnabled(false)
        return
    end
    if self._tabType == QUIDialogMagicHerbDetailInfo.TAB_REFINE then
        self:_initRefineWidget()
        self._currentWidget = self._refineWidget
        self._currentWidget:setVisible(true)
        self._ccbOwner.btn_refine:setHighlighted(true)
        self._ccbOwner.btn_refine:setEnabled(false)
        return
    end
end

function QUIDialogMagicHerbDetailInfo:_initDetailWidget( ... )
    if self._detailWidget == nil then
        self._detailWidget = QUIWidgetMagicHerbDetail.new({actorId = self.actorId, pos = self.pos})
        self._detailWidget:addEventListener(QUIWidgetMagicHerbDetail.EVENT_UNWEAR, handler(self, self._magicHerbUnwearHandler))
        self._detailWidget:addEventListener(QUIWidgetMagicHerbDetail.EVENT_WEAR, handler(self, self._magicHerbwearHandler))
        self._ccbOwner.node_content:addChild(self._detailWidget)
    end
end

function QUIDialogMagicHerbDetailInfo:_initAdvanceWidget( ... )
    if self._advanceWidget == nil then
        self._advanceWidget = QUIWidgetMagicHerbAdvance.new({actorId = self.actorId, pos = self.pos})
        self._ccbOwner.node_content:addChild(self._advanceWidget)
    end
end

function QUIDialogMagicHerbDetailInfo:_initUpLevelWidget( ... )
    if self._upLevelWidget == nil then
        self._upLevelWidget = QUIWidgetMagicHerbUpLevel.new({actorId = self.actorId, pos = self.pos})
        self._ccbOwner.node_content:addChild(self._upLevelWidget)
    end
end

function QUIDialogMagicHerbDetailInfo:_initRefineWidget( ... )
    if self._refineWidget == nil then
        self._refineWidget = QUIWidgetMagicHerbRefine.new({actorId = self.actorId, pos = self.pos})
        self._ccbOwner.node_content:addChild(self._refineWidget)
    end
end

function QUIDialogMagicHerbDetailInfo:_resetBtn( ... )
    self._ccbOwner.btn_detail:setHighlighted(false)
    self._ccbOwner.btn_advance:setHighlighted(false)
    self._ccbOwner.btn_upLevel:setHighlighted(false)
    self._ccbOwner.btn_refine:setHighlighted(false)
    self._ccbOwner.btn_detail:setEnabled(true)
    self._ccbOwner.btn_advance:setEnabled(true)
    self._ccbOwner.btn_upLevel:setEnabled(true)
    self._ccbOwner.btn_refine:setEnabled(true)
end

function QUIDialogMagicHerbDetailInfo:_magicHerbUnwearHandler( ... )
    remote.magicHerb:magicHerbLoadRequest(self.sid, 2, self.actorId, self.pos, self:safeHandler(function ()
        self:popSelf()
        remote.magicHerb:dispatchEvent({name = remote.magicHerb.EVENT_REFRESH_MAGIC_HERB, sid = self.sid, isOnWear = false})
    end))
end

function QUIDialogMagicHerbDetailInfo:_magicHerbwearHandler( ... )
    self:popSelf()
    -- 未穿戴
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMagicHerbCheckroom", 
        options = {actorId = self.actorId, pos = self.pos}})
end

function QUIDialogMagicHerbDetailInfo:_onTriggerDetail( ... )
    if self._tabType ~= QUIDialogMagicHerbDetailInfo.TAB_DETAIL then
        app.sound:playSound("common_switch")
        self._tabType = QUIDialogMagicHerbDetailInfo.TAB_DETAIL
        self:_switchTab()
    end 
end

function QUIDialogMagicHerbDetailInfo:_onTriggerAdvance( ... )
    if self._tabType ~= QUIDialogMagicHerbDetailInfo.TAB_ADVANCE then
        app.sound:playSound("common_switch")
        self._tabType = QUIDialogMagicHerbDetailInfo.TAB_ADVANCE
        self:_switchTab() 
    end 
end

function QUIDialogMagicHerbDetailInfo:_onTriggerUpLevel( ... )
    if self._tabType ~= QUIDialogMagicHerbDetailInfo.TAB_UPLEVEL then
        app.sound:playSound("common_switch")
        self._tabType = QUIDialogMagicHerbDetailInfo.TAB_UPLEVEL
        self:_switchTab()
    end 
end

function QUIDialogMagicHerbDetailInfo:_onTriggerRefine( ... )
    if self._tabType ~= QUIDialogMagicHerbDetailInfo.TAB_REFINE then
        app.sound:playSound("common_switch")
        self._tabType = QUIDialogMagicHerbDetailInfo.TAB_REFINE
        self:_switchTab()
    end 
end

function QUIDialogMagicHerbDetailInfo:_onTriggerClose( ... )
    app.sound:playSound("common_cancel")
    self:playEffectOut()
end

return QUIDialogMagicHerbDetailInfo