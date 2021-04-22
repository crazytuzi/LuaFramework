-- @Author: liaoxianbo
-- @Date:   2020-08-13 10:56:02
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-08-13 15:29:18
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogHighTeaFreeAwards = class("QUIDialogHighTeaFreeAwards", QUIDialog)

local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QNavigationController = import("...controllers.QNavigationController")
local QListView = import("...views.QListView")
local QScrollView = import("...views.QScrollView")
local QUIWidgetHelpDescribe = import("..widgets.QUIWidgetHelpDescribe")
local QRichText = import("...utils.QRichText")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QUIWidgetHeroTitleBox = import("..widgets.QUIWidgetHeroTitleBox")
local QUIViewController = import("..QUIViewController")

local RADIUS = 48

function QUIDialogHighTeaFreeAwards:ctor(options)
	local ccbFile = "ccb/Dialog_HighTea_Email_Content.ccbi"
	local callbacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
        {ccbCallbackName = "onTriggerReceive", callback = handler(self, self._onTriggerReceive)},
        {ccbCallbackName = "onTriggerDelete", callback = handler(self, self._onTriggerDelete)},
	}
	QUIDialogHighTeaFreeAwards.super.ctor(self, ccbFile, callbacks, options)

    self.isAnimation = true
    self._isReceiveEnable = true

    local mail = options.mail or {}
    self._itemList = mail.awards or {}
    local pageWidth = self._ccbOwner.sheet_layout:getContentSize().width
    local pageHeight = self._ccbOwner.sheet_layout:getContentSize().height

    -- WOW-16176 add by Kumo
    if options.mail.readed == true then
        self._ccbOwner.node_btn:setVisible(false)
        self._ccbOwner.node_yilingqu:setVisible(true)
        self._isReceiveEnable = false
    end

    local scrollSize = self._ccbOwner.sheet_layout1:getContentSize()
    self._scrollView = QScrollView.new(self._ccbOwner.sheet1, scrollSize, {nodeAR = ccp(0.5, 1), bufferMode = 1, sensitiveDistance = 10})
    self._scrollView:setHorizontalBounce(true)

    self._data = {}

    local str = options.mail.content or ""
    local strArr  = string.split(str or "","\n") or {}
    local contentConfig = {}
    for k, v in pairs(strArr) do
        table.insert(contentConfig, {oType = "font", size = 22,content = v, dimensions = CCSize(650, 0), hAlignment = kCCTextAlignmentLeft})
    end
    local contentOptions = {defaultColor = ccc3(135,85,55), autoCenter = false, offsetX = 0,defaultSize = 22,lineSpacing = 3,lineHeight = 30, fontName = global.font_zhcn}
    table.insert(self._data, {oType = "content", config = contentConfig, options = {}})
    table.insert(self._data, {oType = "name", cfg = {{oType = "font",size = 22, content = options.mail.from or "", color = COLORS.k, dimensions=CCSizeMake(630, 50),hAlignment = kCCTextAlignmentRight,vAlignment = kCCVerticalTextAlignmentBottom, fontName = global.font_zhcn}}})
    
    self:setInfo(options)
end


function QUIDialogHighTeaFreeAwards:initListView( )
    if not self._listviewLayout then
        local cfg = {
            renderItemCallBack = function( list, index, info )
                local isCacheNode = true
                local data = self._data[index]
                local item = list:getItemFromCache(data.oType)
                if not item then  
                    if data.oType == "content" then              
                        -- item = QUIWidgetHelpDescribe.new({fontName = data.cfg.fontName})
                        item = QRichText.new(nil, 650, data.options)
                        item:setAnchorPoint(0,1)
                    elseif data.oType == "name" then
                        item = QRichText.new()
                        item:setAnchorPoint(0,1)
                    end
                    isCacheNode = false
                end
                if data.oType == "content" then           
                    item:setString(data.config)
                    item:setPosition(ccp(0 , 0))
                elseif data.oType == "name" then  
                    item:setString(data.cfg)
                end
                info.tag = data.oType
                info.item = item
                info.size = item:getContentSize()

                return isCacheNode
            end,
         
            ignoreCanDrag = true,
            curOriginOffset = 20,
            contentOffsetX = 40,
            enableShadow = false,
            totalNumber = #self._data
        }
        self._listviewLayout = QListView.new(self._ccbOwner.sheet_layout,cfg)
        self._listviewLayout:setPosition(ccp(0, 0))
    else
        self._listviewLayout:reload({totalNumber = #self._data})
    end
end

function QUIDialogHighTeaFreeAwards:viewAnimationInHandler()
    QUIDialogHighTeaFreeAwards.super.viewDidAppear(self)

    self:initListView()
end

function QUIDialogHighTeaFreeAwards:viewDidAppear()
	QUIDialogHighTeaFreeAwards.super.viewDidAppear(self)

end

function QUIDialogHighTeaFreeAwards:viewWillDisappear()
	QUIDialogHighTeaFreeAwards.super.viewWillDisappear(self)
end

function QUIDialogHighTeaFreeAwards:setInfo(options)
    self._ccbOwner.title:setString(options.mail.title or "")
    self:setScale(self._ccbOwner.title,280)

    if self._listviewLayout then
        self._listviewLayout:reload({totalNumber = #self._data})
    end
    local itemCount = #self._itemList
    for i = 1, itemCount do
        local award = self._itemList[i]
        local itemBox = QUIWidgetItemsBox.new()
        itemBox:setPromptIsOpen(true)
        itemBox:setGoodsInfo(award.id or award.typeName, award.typeName, award.count)
        itemBox:setPosition(ccp(50+(i-1)*100, -55))
        self._scrollView:addItemBox(itemBox)
    end
    local scrollSize = self._ccbOwner.sheet_layout1:getContentSize()
    self._scrollView:setRect(0, scrollSize.height, 0, 100*itemCount-10)
    self._scrollView:moveTo(0, 0, false)
end

function QUIDialogHighTeaFreeAwards:setScale(_itemname,maxsize)
    if _itemname ~= nil then
        local widthNum = _itemname:getContentSize().width
        if widthNum > maxsize then
            _itemname:setScale(maxsize/widthNum)
        else
            _itemname:setScale(1)
        end
    end
end


function QUIDialogHighTeaFreeAwards:_onTriggerClose()
	self:_backClickHandler()
end

function QUIDialogHighTeaFreeAwards:_onTriggerReceive(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_receive) == false then return end
    if self:getEffectPlay() == true then return end
    app.sound:playSound("common_small")
    self._highTeaDataHandle = remote.activityRounds:getHighTea()
    if self._highTeaDataHandle then
    	self._highTeaDataHandle:weeklyGameHighTeaGetFreeAwardRequest(function(data)
	        local awards = data.prizes or {}
	        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG , uiClass = "QUIDialogAwardsAlert" ,
	            options = {awards = awards ,title = "奥斯卡礼物" , callBack = self:safeHandler(function () 
	            		QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = self._highTeaDataHandle.GET_FREE_AWARD})
	            		if self:safeCheck() then
	            			self:_onTriggerClose()
	            		end
					end)
	            }}, {isPopCurrentDialog = false} )
    	end)
    end
end

function QUIDialogHighTeaFreeAwards:_backClickHandler()
	self:playEffectOut()
end


return QUIDialogHighTeaFreeAwards
