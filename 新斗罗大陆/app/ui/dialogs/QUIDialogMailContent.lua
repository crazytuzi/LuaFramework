--
-- Author: wkwang
-- Date: 2014-09-18 14:52:33
--
local QUIDialog = import(".QUIDialog")
local QUIDialogMailContent = class("QUIDialogMailContent", QUIDialog)

local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QNavigationController = import("...controllers.QNavigationController")
local QListView = import("...views.QListView")
local QScrollView = import("...views.QScrollView")
local QUIWidgetHelpDescribe = import("..widgets.QUIWidgetHelpDescribe")
local QRichText = import("...utils.QRichText")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QUIWidgetHeroTitleBox = import("..widgets.QUIWidgetHeroTitleBox")

QUIDialogMailContent.MAIL_EVENT_RECV_AWARD = "MAIL_EVENT_RECV_AWARD"
QUIDialogMailContent.MAIL_EVENT_CLOSE = "MAIL_EVENT_CLOSE"

local RADIUS = 48

function QUIDialogMailContent:ctor(options)
	local ccbFile = "ccb/Dialog_Email_Content.ccbi"
	local callbacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogMailContent._onTriggerClose)},
        {ccbCallbackName = "onTriggerReceive", callback = handler(self, QUIDialogMailContent._onTriggerReceive)},
        {ccbCallbackName = "onTriggerDelete", callback = handler(self, QUIDialogMailContent._onTriggerDelete)},
	}
	QUIDialogMailContent.super.ctor(self, ccbFile, callbacks, options)

    self.isAnimation = true
    self._isReceiveEnable = true

    local mail = options.mail or {}
    local awards = mail.awards or {}
    local items = mail.items or {}
    local pageWidth = self._ccbOwner.sheet_layout:getContentSize().width
    local pageHeight = self._ccbOwner.sheet_layout:getContentSize().height
    -- if table.nums(awards) == 0 and table.nums(items) == 0 then
    --     pageHeight = pageHeight + 130
    --     self._ccbOwner.sheet_layout:setContentSize(CCSizeMake(pageWidth, pageHeight))
    -- end

    -- WOW-16176 add by Kumo
    if options.mail.readed == true and (#awards > 0 or #items > 0) then
        self._ccbOwner.node_btn:setVisible(false)
        self._ccbOwner.node_yilingqu:setVisible(true)
        self._isReceiveEnable = false
    end

    local scrollSize = self._ccbOwner.sheet_layout1:getContentSize()
    self._scrollView = QScrollView.new(self._ccbOwner.sheet1, scrollSize, {nodeAR = ccp(0.5, 1), bufferMode = 1, sensitiveDistance = 10})
    self._scrollView:setHorizontalBounce(true)

    self._data = {}
    self._itemList = {}
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
    self._ccbOwner.node_del_btn:setVisible(options.mail.delete == 1)
end


function QUIDialogMailContent:initListView( )
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

function QUIDialogMailContent:viewAnimationInHandler()
    QUIDialogMailContent.super.viewDidAppear(self)

    self:initListView()
    local mail = self:getOptions().mail
    if mail and mail.readed == false and not ((mail.awards ~= nil and #mail.awards > 0) or (mail.awards~=nil and #mail.items > 0))  then
        remote.mails:mailRead(mail.mailId)
        mail.readed = true
    end
end

function QUIDialogMailContent:viewDidAppear()
	QUIDialogMailContent.super.viewDidAppear(self)
    self.prompt = app:promptTips()
    self.prompt:addItemEventListener(self)
end

function QUIDialogMailContent:viewWillDisappear()
	QUIDialogMailContent.super.viewWillDisappear(self)
    self.prompt:removeItemEventListener()
end

function QUIDialogMailContent:setInfo(options)
    assert(options.mail.content, "Mail content is empty")
    if options.mail.key == "personal_mail" then
        self._ccbOwner.title:setString((options.mail.from or "") .. "的私人邮件")
    else
        self._ccbOwner.title:setString(options.mail.title or "")
    end
    self:setScale(self._ccbOwner.title,280)

    self:_updateAwards(options.mail.awards or {}, options.mail.items or {})

    if self._listviewLayout then
        self._listviewLayout:reload({totalNumber = #self._data})
    end

    local itemCount = #self._itemList
    for i = 1, itemCount do
        local award = self._itemList[i]
        local itemBox = QUIWidgetItemsBox.new()
        itemBox:setPromptIsOpen(true)
        itemBox:setGoodsInfo(award.itemId or award.type, award.type, award.count)
        itemBox:setPosition(ccp(50+(i-1)*100, -55))
        self._scrollView:addItemBox(itemBox)
    end
    local scrollSize = self._ccbOwner.sheet_layout1:getContentSize()
    self._scrollView:setRect(0, scrollSize.height, 0, 100*itemCount-10)
    self._scrollView:moveTo(0, 0, false)
end

function QUIDialogMailContent:setScale(_itemname,maxsize)
    if _itemname ~= nil then
        local widthNum = _itemname:getContentSize().width
        if widthNum > maxsize then
            _itemname:setScale(maxsize/widthNum)
        else
            _itemname:setScale(1)
        end
    end
end


function QUIDialogMailContent:_updateAwards(awards, items)
    local mail = self:getOptions().mail
    local isShowReceive = false

    self._itemList = {}
    local index = 1
    for k, v in ipairs(awards) do
        table.insert(self._itemList, v)
        isShowReceive = true
    end

    for k, v in ipairs(items) do
        table.insert(self._itemList, v)
        isShowReceive = true
    end

    if mail.key == "storm_arena_season" then
        -- 风暴赛季邮件在所有奖励之后，增加头像框，如果有获得的话
        local contents = string.split(mail.oldContent, "#") or {}
        local rank = 0
        for _, value in pairs(contents) do
            if tonumber(value) == 1 or tonumber(value) == 2 or tonumber(value) == 3 then
                rank = tonumber(value)
            end
        end
        if rank > 0 then
            -- 增加头像框
            local frameConfig = nil
            local heads = db:getFrames(remote.headProp.FRAME_STORM_TYPE)
            for _,v in pairs(heads) do
                local condition = string.split(v.condition, ",")
                if tonumber(condition[1]) and rank >= tonumber(condition[1]) and tonumber(condition[2]) and rank <= tonumber(condition[2]) then
                    frameConfig = v
                    break
                end
            end
            if frameConfig then
                -- 增加头像框
                local avatar = QUIWidgetAvatar.new(frameConfig.id)
                avatar:setScale(0.8)
                self._ccbOwner["attach_item_4"]:addChild(avatar)
                self._ccbOwner.buttonText:setString("确 定" or "")
                isShowReceive = true
            end
        end
    end

    if mail.key == "fight_club_reward_quanfu" then
        -- 邮件在所有奖励之后，增加头像框，如果有获得的话
        local contents = string.split(mail.oldContent, "#") or {}
        local rank = tonumber(contents[1]) or 0
        local frameConfig = nil
        local fightFrames = db:getFrames(remote.headProp.FRAME_FIGHT_TYPE)
        for _, v in pairs(fightFrames) do
            local conditions = string.split(v.condition, ",")
            if conditions and tonumber(conditions[1]) <= rank and rank <= tonumber(conditions[2]) then 
                frameConfig = v
                break
            end
        end
        if frameConfig then
            -- 增加头像框
            local avatar = QUIWidgetAvatar.new(frameConfig.id)
            avatar:setScale(0.9)
            avatar:setPositionX(-20)
            self._ccbOwner["attach_item_4"]:addChild(avatar)
            self._ccbOwner.buttonText:setString("确 定" or "")
            isShowReceive = true
        end
    end
    
    if mail.key == "sanctuary_reward" then
        -- 邮件在所有奖励之后，增加头像框，如果有获得的话
        local contents = string.split(mail.oldContent, "#") or {}
        local rank = tonumber(contents[1]) or 0
        local frameConfig = nil
        local fightFrames = db:getFrames(remote.headProp.FRAME_SANCTUARY_TYPE)
        for _, v in pairs(fightFrames) do
            local conditions = string.split(v.condition, ",")
            if conditions and tonumber(conditions[1]) <= rank and rank <= tonumber(conditions[2]) then 
                frameConfig = v
                break
            end
        end
        if frameConfig then
            -- 增加头像框
            local avatar = QUIWidgetAvatar.new(frameConfig.id)
            avatar:setScale(0.9)
            avatar:setPositionX(-20)
            self._ccbOwner["attach_item_4"]:addChild(avatar)
            self._ccbOwner.buttonText:setString("确 定" or "")
            isShowReceive = true
        end
    end

    if mail.key == "soto_team_reward" then
        -- 邮件在所有奖励之后，增加称号，如果有获得的话
        local contents = string.split(mail.oldContent, "#") or {}
        local rank = tonumber(contents[1]) or 0
        local frameConfig = nil
        local fightFrames = db:getFrames(remote.headProp.FRAME_SOTO_TEAM_TYPE)
        for _, v in pairs(fightFrames) do
            local conditions = string.split(v.condition, ",")
            if conditions and tonumber(conditions[1]) <= rank and rank <= tonumber(conditions[2]) then 
                frameConfig = v
                break
            end
        end
        if frameConfig then
            -- 增加头像框
            local avatar = QUIWidgetAvatar.new(frameConfig.id)
            avatar:setScale(0.9)
            avatar:setPositionX(-20)
            self._ccbOwner["attach_item_4"]:addChild(avatar)
            self._ccbOwner.buttonText:setString("确 定" or "")
            isShowReceive = true
        end
    end

    if mail.key == "collegeTrainHallEnvRank" then
        -- 邮件在所有奖励之后，增加称号，如果有获得的话
        local contents = string.split(mail.oldContent, "#") or {}
        local rank = tonumber(contents[1]) or 0
        local frameConfig = nil
        local fightFrames = db:getFramesByindexId(remote.headProp.FRAME_COLLEGETRAIN_TYPE,19)
        for _, v in pairs(fightFrames) do
            local conditions = string.split(v.condition, ",")
            if conditions and tonumber(conditions[1]) <= rank and rank <= tonumber(conditions[2]) then 
                frameConfig = v
                break
            end
        end
        if frameConfig then
            -- 增加头像框
            local avatar = QUIWidgetAvatar.new(frameConfig.id)
            avatar:setScale(0.9)
            avatar:setPositionX(-20)
            self._ccbOwner["attach_item_4"]:addChild(avatar)
            self._ccbOwner.buttonText:setString("确 定" or "")
            isShowReceive = true
        end
    end


    if mail.key == "collegeTrainHallAllRank" then
        -- 邮件在所有奖励之后，增加称号，如果有获得的话
        local contents = string.split(mail.oldContent, "#") or {}
        local rank = tonumber(contents[1]) or 0
        local frameConfig = nil
        local fightFrames = db:getFramesByindexId(remote.headProp.FRAME_COLLEGETRAIN_TYPE,18)
        for _, v in pairs(fightFrames) do
            local conditions = string.split(v.condition, ",")
            if conditions and tonumber(conditions[1]) <= rank and rank <= tonumber(conditions[2]) then 
                frameConfig = v
                break
            end
        end
        if frameConfig then
            -- 增加头像框
            local avatar = QUIWidgetAvatar.new(frameConfig.id)
            avatar:setScale(0.9)
            avatar:setPositionX(-20)
            self._ccbOwner["attach_item_4"]:addChild(avatar)
            self._ccbOwner.buttonText:setString("确 定" or "")
            isShowReceive = true
        end
    end

    if mail.key == "college_train" then
        -- 邮件在所有奖励之后，增加称号，如果有获得的话
        local contents = string.split(mail.oldContent, "#") or {}
        local rank = tonumber(contents[1]) or 0
        local frameConfig = nil
        local fightFrames = db:getFramesByindexId(remote.headProp.FRAME_COLLEGETRAIN_TYPE,20)
        for _, v in pairs(fightFrames) do
            if v then
                frameConfig = v
                break
            end
        end
        if frameConfig then
            -- 增加头像框
            local avatar = QUIWidgetAvatar.new(frameConfig.id)
            avatar:setScale(0.9)
            avatar:setPositionX(-20)
            self._ccbOwner["attach_item_4"]:addChild(avatar)
            self._ccbOwner.buttonText:setString("确 定" or "")
            isShowReceive = true
        end
    end

    if mail.key == "team_arena_peak_season_end" then
        -- 邮件在所有奖励之后，增加头像框，如果有获得的话
        local contents = string.split(mail.oldContent, "#") or {}
        local rank = tonumber(contents[1]) or 0
        local frameConfig = nil
        local fightFrames = db:getFrames(remote.headProp.FRAME_SILVESARENA_PEAK_TYPE)
        for _, v in pairs(fightFrames) do
            local conditions = string.split(v.condition, ",")
            if conditions and tonumber(conditions[1]) <= rank and rank <= tonumber(conditions[2]) then 
                frameConfig = v
                break
            end
        end
        if frameConfig then
            -- 增加头像框
            local avatar = QUIWidgetAvatar.new(frameConfig.id)
            avatar:setScale(0.9)
            avatar:setPositionX(-20)
            self._ccbOwner["attach_item_4"]:addChild(avatar)
            self._ccbOwner.buttonText:setString("确 定" or "")
            isShowReceive = true
        end
    end
    
    self._ccbOwner.node_receive:setVisible(isShowReceive)
end

function QUIDialogMailContent:refresh()
    self:setInfo(self:getOptions())
end

function QUIDialogMailContent:_onTriggerClose()
	self:_backClickHandler()
end

function QUIDialogMailContent:_onTriggerReceive(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_receive) == false then return end
    if self:getEffectPlay() == true then return end
    app.sound:playSound("common_small")
    self.isReceived = true
	self:_backClickHandler()
end

function QUIDialogMailContent:_onTriggerDelete(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_delete) == false then return end
    app:alert({content = "魂师大人，是否删除该邮件~", title = "系统提示",
            callback = function(state)
                if state == ALERT_TYPE.CONFIRM then
                    remote.mails:mailDelRequest(self:getOptions().mail.mailId, function ()
                        app.tip:floatTip("邮件删除成功")
                    end)   
                    self:playEffectOut()
                end
            end}, true, true)       
end

function QUIDialogMailContent:_backClickHandler()
	self:playEffectOut()
end

function QUIDialogMailContent:viewAnimationOutHandler()
    local isPatch = false
    if self.isReceived == true and self:getOptions().mail.items ~= nil and self._isReceiveEnable then
        isPatch = true 
    end
    
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_SPECIFIC_CONTROLLER, nil, self)
    if isPatch == true then
        QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIDialogMailContent.MAIL_EVENT_RECV_AWARD, mail = self:getOptions().mail })
    end
    QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIDialogMailContent.MAIL_EVENT_CLOSE, mail = self:getOptions().mail, isReceive = self.isReceived, isRead = self:getOptions().isRead })
end

return QUIDialogMailContent