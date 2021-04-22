--
-- Kumo.Wang
-- 西尔维斯巅峰赛16强展示
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSilvesArenaPeakTop16Poster = class("QUIDialogSilvesArenaPeakTop16Poster", QUIDialog)

local QRichText = import("...utils.QRichText") 
local QUIViewController = import("..QUIViewController")
local QNavigationController = import("...controllers.QNavigationController")
local QListView = import("...views.QListView")

local QUIWidgetSilvesArenaPeakTop16Poster = import("..widgets.QUIWidgetSilvesArenaPeakTop16Poster")

function QUIDialogSilvesArenaPeakTop16Poster:ctor(options)
	local ccbFile = "ccb/Dialog_SilvesArena_Peak_TOP16_Notice.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
	QUIDialogSilvesArenaPeakTop16Poster.super.ctor(self,ccbFile,callBacks,options)

    self.isAnimation = true --是否动画显示

    if options then
        self._callback = options.callback
    end
    
    app:getUserOperateRecord():setRecordByType("SIVES_ARENA_SHOW_ENTER_PEAK_FIGHTING", remote.silvesArena.seasonInfo.seasonStartAt)

    self._ccbOwner.node_rtf:removeAllChildren()
	local rt = QRichText.new()
    local tfTbl = {}
    table.insert(tfTbl, {oType = "font", content = "西尔维斯", size = 20, color = COLORS.k})
    table.insert(tfTbl, {oType = "font", content = "16强", size = 20, color = COLORS.g})
    table.insert(tfTbl, {oType = "font", content = "选手已经诞生！", size = 20, color = COLORS.k})
    table.insert(tfTbl, {oType = "wrap"})
    table.insert(tfTbl, {oType = "font", content = "巅峰赛的大门已经打开，这又", size = 20, color = COLORS.k})
    table.insert(tfTbl, {oType = "wrap"})
    table.insert(tfTbl, {oType = "font", content = "是一场史无前例的较量。", size = 20, color = COLORS.k})
    -- table.insert(tfTbl, {oType = "wrap"})
    -- table.insert(tfTbl, {oType = "font", content = "斗罗大陆最重要的就是团队和", size = 20, color = COLORS.k})
    -- table.insert(tfTbl, {oType = "wrap"})
    -- table.insert(tfTbl, {oType = "font", content = "实力！相信你可以的～", size = 20, color = COLORS.k})
    -- table.insert(tfTbl, {oType = "wrap"})
    rt:setString(tfTbl)
    rt:setAnchorPoint(ccp(0, 1))
    self._ccbOwner.node_rtf:addChild(rt)

    if q.isEmpty(remote.silvesArena.peakTeamInfo) then
        self._ccbOwner.sheet_layout:removeAllChildren()
        return
    end
    
    self._data = clone(remote.silvesArena.peakTeamInfo) or {}
    if not self._data then return end

    table.sort(self._data, function(a, b)
        return a.teamRank < b.teamRank
    end)

    self:_initListView()
end

function QUIDialogSilvesArenaPeakTop16Poster:_initListView()
    if self._listView then 
        self._listView:clear(true)
        self._listView = nil
    end

    if not self._data then return end
    -- QKumo(self._data)
    local cfg = {
        renderItemCallBack = handler(self, self._renderFunHandler),
        ignoreCanDrag = true,
        enableShadow = false,
        totalNumber = #self._data,
    }  
    self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
end

function QUIDialogSilvesArenaPeakTop16Poster:_renderFunHandler(list, index, info)
    local isCacheNode = true
    local itemData = self._data[index]
    local item = list:getItemFromCache()

    if not item then
        item = QUIWidgetSilvesArenaPeakTop16Poster.new()
        isCacheNode = false
    end
    info.item = item
    item:setInfo(itemData)
    info.size = item:getContentSize()

    return isCacheNode
end

function QUIDialogSilvesArenaPeakTop16Poster:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
    app.sound:playSound("common_cancel")
    self:playEffectOut()
end

function QUIDialogSilvesArenaPeakTop16Poster:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogSilvesArenaPeakTop16Poster:viewAnimationOutHandler()
    local callback = self._callback

    self:popSelf()

    if callback then
        callback()
    end
end

return QUIDialogSilvesArenaPeakTop16Poster