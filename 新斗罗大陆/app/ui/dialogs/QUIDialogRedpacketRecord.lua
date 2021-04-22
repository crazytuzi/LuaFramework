--
-- Author: Kumo.Wang
-- 宗门红包领奖记录界面
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogRedpacketRecord = class("QUIDialogRedpacketRecord", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QListView = import("...views.QListView")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QRichText = import("...utils.QRichText")

local QUIWidgetRedpacketRecordCell = import("..widgets.QUIWidgetRedpacketRecordCell")

function QUIDialogRedpacketRecord:ctor(options)
	local ccbFile = "ccb/Dialog_Society_Redpacket_Record.ccbi"
	local callBack = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogRedpacketRecord.super.ctor(self, ccbFile, callBack, options)
	self.isAnimation = false --是否动画显示

	self._data = options.data
    self._callback = options.callback

    self._logList = {}

    self:_init()
end

function QUIDialogRedpacketRecord:viewDidAppear()
	QUIDialogRedpacketRecord.super.viewDidAppear(self)
end


function QUIDialogRedpacketRecord:viewAnimationInHandler()
    QUIDialogRedpacketRecord.super.viewAnimationInHandler(self)
    self:_initListView()
end

function QUIDialogRedpacketRecord:viewWillDisappear()
	QUIDialogRedpacketRecord.super.viewWillDisappear(self)
end

function QUIDialogRedpacketRecord:_resetAll()
	self._ccbOwner.node_head:removeAllChildren()
	self._ccbOwner.node_playerName:removeAllChildren()
	self._ccbOwner.tf_playerWords:setVisible(false)
    self._ccbOwner.node_have:setVisible(false)

    self._ccbOwner.tf_no:setVisible(false)
    self._ccbOwner.node_no:setVisible(true)
end

function QUIDialogRedpacketRecord:_init()
	self:_resetAll()
	if not self._data then return end

    self._logList = self._data.receiveDetailLogList or {}
    local maxLog
    local minLog
    for index, log in ipairs(self._logList) do
        if not maxLog or log.item_num > maxLog.item_num then
            maxLog = log
        end
        if not minLog or log.item_num < minLog.item_num then
            minLog = log
        end
    end
    for _, log in ipairs(self._logList) do
        if log.userId == maxLog.userId then
            log.isMax = true
        end
        if log.userId == minLog.userId then
            log.isMin = true
        end
    end
    if #self._logList > 0 then
        self._logList[#self._logList].isLast = true
    end
    
    if self._data.isOpened then
        self._ccbOwner.node_have:setVisible(true)
        self._ccbOwner.node_no:setVisible(false)
        self:_setHeroHead()
        self:_setInfo()
    else
        self._ccbOwner.node_have:setVisible(false)
        self._ccbOwner.node_no:setVisible(true)
        self._ccbOwner.tf_no:setVisible(true)
    end
end

function QUIDialogRedpacketRecord:_setHeroHead()
    -- local avatarWidget = QUIWidgetAvatar.new()
    -- avatarWidget:setInfo(self._data.avatar)
    -- self._ccbOwner.node_head:addChild(avatarWidget)
    local idOrType = self._data.rewardIdOrType
    if idOrType then
        local itemBox = QUIWidgetItemsBox.new()
        if tonumber(idOrType) then
            -- item
            itemBox:setGoodsInfo(tonumber(idOrType), ITEM_TYPE.ITEM, self._data.rewardNum)
        else
            -- resource
            itemBox:setGoodsInfo(nil, idOrType, self._data.rewardNum)
        end
        self._ccbOwner.node_head:addChild(itemBox)
    end
end

function QUIDialogRedpacketRecord:_setInfo()
    local str = "##j来自 ##w"..(self._data.nickname or "").." ##j的福袋"
    local richText = QRichText.new(str, 500, {autoCenter = true, stringType = 1, defaultSize = 20})
    richText:setAnchorPoint(ccp(0.5, 0.5))
    self._ccbOwner.node_playerName:addChild(richText)
    
    if not self._data.content or self._data.content == "" then
        self._ccbOwner.tf_playerWords:setString(remote.redpacket.DEFAULT_GAIN_MESSAGE)
    else
        self._ccbOwner.tf_playerWords:setString(self._data.content)
    end
    self._ccbOwner.tf_playerWords:setVisible(true)
end

function QUIDialogRedpacketRecord:_initListView()
    if not self._listView then
        local cfg = {
            renderItemCallBack = function( list, index, info )
                local isCacheNode = true
                local itemData = self._logList[index]
                local item = list:getItemFromCache()
                if not item then
                    item = QUIWidgetRedpacketRecordCell.new()
                    isCacheNode = false
                end
                item:setInfo(itemData)
                info.item = item
                info.size = item:getContentSize()
                return isCacheNode
            end,
            curOriginOffset = 0,
            spaceX = 0,
            spaceY = 10,
            isVertical = true,
            multiItems = 1,
            enableShadow = true,
            curOffset = 0,
            ignoreCanDrag = true,
            -- autoCenter = false,
            topShadow = self._ccbOwner.sp_shadow_top,
            bottomShadow = self._ccbOwner.sp_shadow_bottom,
            totalNumber = #self._logList,
        }
        self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
    else
        self._listView:reload({totalNumber = #self._logList})
    end
end

function QUIDialogRedpacketRecord:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogRedpacketRecord:_onTriggerClose(e)
    if e then
    	app.sound:playSound("common_small")
    end
	self:playEffectOut()
end

function QUIDialogRedpacketRecord:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.topLayer, QNavigationController.POP_SPECIFIC_CONTROLLER, nil, self)

    if self._callback then
        self._callback()
    end
end

return QUIDialogRedpacketRecord