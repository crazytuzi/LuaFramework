--
-- Author: Qinyuanji
-- Date: 2015-03-20
--
local QUIWidget = import(".QUIWidget")
local QUIWidgetChat = class("QUIWidgetChat", QUIWidget)
local QUIViewController = import("..QUIViewController")
local QFullCircleUiMask = import("..battle.QFullCircleUiMask")
local QColorLabel = import("...utils.QColorLabel")
local QMaskWords = import("...utils.QMaskWords")
local QScrollView = import("...views.QScrollView") 
local QServerChatData = import("...models.chatdata.QServerChatData")
local QChatData = import("...models.chatdata.QChatData")

QUIWidgetChat.ACTION_DURATION = 0.3
QUIWidgetChat.TEXTGAP = 40
QUIWidgetChat.FADE_TIME = 1.0
QUIWidgetChat.DISAPPEAR_TIMEOUT = 60

QUIWidgetChat.STATE_ALL = "STATE_ALL"
QUIWidgetChat.STATE_PRIVATE = "STATE_PRIVATE"
QUIWidgetChat.STATE_UNION = "STATE_UNION"
QUIWidgetChat.STATE_TEAM = "STATE_TEAM"

function QUIWidgetChat:ctor(options)
    local ccbFile = "ccb/Widget_chat.ccbi"
    local callBacks = {
        {ccbCallbackName = "onChatButtonClick", callback = handler(self, QUIWidgetChat._onChatButtonClick)},     
        {ccbCallbackName = "onChatAreaClick", callback = handler(self, QUIWidgetChat._onChatAreaClick)},     
    }
    QUIWidgetChat.super.ctor(self, ccbFile, callBacks, options)

    -- It's hard to use one code for IOS and android to have no side-effect in showing messages
    local sizeAdjustment = 10
    local sharedApplication = CCApplication:sharedApplication()
    local target = sharedApplication:getTargetPlatform()
    if target == kTargetAndroid then
        sizeAdjustment = 5
    end
    if options == nil then options = {} end
    self._isMain = options.isMain or false
    self._ccbOwner.btn_long:setEnabled(self._isMain)
    self._state = options.state
    if self._state == nil then
        self._state = QUIWidgetChat.STATE_ALL
    end
    self.showChatDialog = false
    self.inChannelState = options.inChannelState or CHAT_CHANNEL_INTYPE.CHANNEL_IN_NORMAL

    self._lyImageMask = CCLayerColor:create(ccc4(0,0,0,150), 540, 26)
    local ccclippingNode = CCClippingNode:create()
    self._lyImageMask:setPositionX(self._ccbOwner.node_text_bg_mask:getPositionX())
    self._lyImageMask:setPositionY(self._ccbOwner.node_text_bg_mask:getPositionY())
    self._lyImageMask:ignoreAnchorPointForPosition(self._ccbOwner.node_text_bg_mask:isIgnoreAnchorPointForPosition())
    self._lyImageMask:setAnchorPoint(self._ccbOwner.node_text_bg_mask:getAnchorPoint())
    ccclippingNode:setStencil(self._lyImageMask)
    ccclippingNode:setInverted(false)
    self._ccbOwner.textNode:retain()
    self._ccbOwner.textNode:removeFromParent()
    ccclippingNode:addChild(self._ccbOwner.textNode)
    self._ccbOwner.textNode:setPositionX(0)
    self._ccbOwner.node_mask_text:addChild(ccclippingNode)
    self._ccbOwner.textNode:release()

    self._textWidth = self._ccbOwner.textArea:getContentSize().width
    self._textHeight = self._ccbOwner.textArea:getContentSize().height
    self._scrollView = QScrollView.new(self._ccbOwner.textNode, CCSize(self._textWidth, self._textHeight + sizeAdjustment),
        {moveDuration = 0.6})

    self._scrollView:addEventListener(QScrollView.FREEZE, handler(self, self._onScrollViewFreeze))
end

function QUIWidgetChat:initPage()
    self._chats = {}
    self._index = 1
    self._lastPositionX = 0
    self._lastPositionY = 0
    self._hidden = true

    self._ccbOwner.background:setOpacity(0)
    self._ccbOwner.chatAreaTouch:setVisible(false)
end

function QUIWidgetChat:onEnter( ... )
    self._scrollView:clear()

    if self._state == QUIWidgetChat.STATE_TEAM then
        self._chatDataProxy = cc.EventProxy.new(app:getServerChatData())
        self._chatDataProxy:addEventListener(QServerChatData.REFRESH_TEAM_CHAT_INFO, handler(self, self.refreshTeamChat))
        self._chatDataProxy:addEventListener(QChatData.NEW_MESSAGE_RECEIVED, handler(self, self.refreshTeamChat))
        self._chatDataProxy:addEventListener(QChatData.NEW_MESSAGE_SENT, handler(self, self.refreshTeamChat))
    end

    if self.inChannelState == CHAT_CHANNEL_INTYPE.CHANNEL_IN_SILVES then
        remote:registerPushMessage(SEND_PUSH_MESSAGE_TYPE.SILVES_ARENA_MEMBER_CHAT, self, self._onSilvesMessageReceived)
    end

    self:initPage()
    self:updatePage()
end

function QUIWidgetChat:onExit( ... )

    if self._chatDataProxy then
        self._chatDataProxy:removeAllEventListeners()
        self._chatDataProxy = nil
    end

    if self.inChannelState == CHAT_CHANNEL_INTYPE.CHANNEL_IN_SILVES then
        remote:removePushMessage(SEND_PUSH_MESSAGE_TYPE.SILVES_ARENA_MEMBER_CHAT, self, self._onSilvesMessageReceived)
    end
end

function QUIWidgetChat:setChatInUnion(boo)
    self._isInUnion = boo 
    self._ccbOwner.btn_long:setEnabled(not boo)
end

function QUIWidgetChat:setChatInBlackRock(boo)
    self._isInBlackRock = boo 
    self._ccbOwner.btn_long:setEnabled(false)
end

function QUIWidgetChat:_onSilvesMessageReceived(event)
    local params = event.params
    local messageType = event.messageType

    if messageType == SEND_PUSH_MESSAGE_TYPE.SILVES_ARENA_MEMBER_CHAT then
        if not self.showChatDialog then
            self:checkPrivateChannelRedTips()
        end
    end
end

function QUIWidgetChat:refreshTeamChat(event)
    local lastChat = nil
    if event.name ~= QServerChatData.REFRESH_TEAM_CHAT_INFO then
        lastChat = {channelId = event.channelId, from = event.from or remote.user.userId, message = event.message, delayed = false, misc = event.misc}
    end
    self:updatePage(lastChat)
end

-- If lastChat is not historial message, scroll down the widget
function QUIWidgetChat:updatePage(lastChat)
    self._lastChat = lastChat
    self:checkPrivateChannelRedTips()

    if (not self._isMain and self.inChannelState == CHAT_CHANNEL_INTYPE.CHANNEL_IN_SILVES) or self._isInUnion then
        return
    end
    local channelId = nil
    if self._state == QUIWidgetChat.STATE_TEAM then
        if lastChat and lastChat.channelId ~= app:getServerChatData():teamChannelId() 
            and lastChat.channelId ~= app:getServerChatData():unionChannelId() then
            return
        end
    end
    
    -- If no latest message received, fetch from serverChat
    if not lastChat then
        local chatData = app:getServerChatData():getMsgReceived(channelId)
        if chatData ~= nil then
            for k, v in pairs(chatData) do
                if channelId then
                    lastChat = chatData[#chatData]
                else
                    lastChat = chatData[k][#chatData[k]]
                end 
                if lastChat and lastChat.from then break end
            end
        end
    end
    
    if lastChat and lastChat.from then
        self._hidden = false
        self._ccbOwner.background:stopAllActions()
        self._ccbOwner.background:setOpacity(255)
        self._ccbOwner.chatAreaTouch:setVisible(true)

        if not lastChat.delayed then
            self._lastPositionY = self._lastPositionY + QUIWidgetChat.TEXTGAP 
        else
            if self._chats[self._index] then
                self._chats[self._index]:removeFromParent()
                self._chats[self._index] = nil
            end
        end

        local misc = lastChat.misc
        if not misc.nickName then
            misc = app:getServerChatData():parseMisc(lastChat.misc)
        end
        
        local message = string.format("##w%s##j%s", (misc.nickName or "") .. ": ", lastChat.message)
        if lastChat.channelId and tonumber(lastChat.channelId) == CHANNEL_TYPE.PRIVATE_CHANNEL and lastChat.from ~= remote.user.userId then
            message = string.format("##w%s##j对你说: %s", (misc.nickName or ""), lastChat.message)
        end
        local color = ccc3(253, 234, 183)
        if misc.type == "admin" then
            color = ccc3(255, 239, 133)
            message = string.format("##j%s##j%s", (misc.nickName or "") .. ": ", lastChat.message)
            if misc.channelId and tonumber(misc.channelId) == CHANNEL_TYPE.UNION_CHANNEL then
                message = "##j"..(lastChat.message or "")
            end
        end

        self._index = self._index + 1 

        if device.platform == "android" or device.platform == "windows" then
            message = QReplaceEmoji(message)
        end
        
        local mask = true
        if misc.type == "admin" or misc.type == "dynamic" then
            mask = false
        end

        message = QColorLabel.replaceColorSign(message,true)      
        local richText = QColorLabel:createForChat(message, self._textWidth - 30, 50, mask, 20, color, global.font_name, true,nil,nil,true)
        richText:setPosition(ccp(0, lastChat.delayed and 0 or self._lastPositionY))
        self._chats[self._index] = richText
        self._scrollView:addItemBox(richText)

        self._scrollView:setRect(self._lastPositionY, 0)
        self._scrollView:stopAllActions()
        self._scrollView:runToTop(true)
    end
end

function QUIWidgetChat:setChatAreaVisible(visibility)
    self._ccbOwner.chatArea:setVisible(visibility)
end

function QUIWidgetChat:_onScrollViewFreeze()
    for i = self._index - 1, 1, -1 do
        if self._chats[i] then
            self._chats[i]:removeFromParent()
            self._chats[i] = nil
        end
    end
end

function QUIWidgetChat:_getInitTab()
    if not self._isMain and self.inChannelState == CHAT_CHANNEL_INTYPE.CHANNEL_IN_SILVES then
        if remote.silvesArena:checkCanChat() then
            if remote.silvesArena:getNewMessageState() or remote.silvesArena:getCompleteTeam() then
                return "onTriggerTeam"
            end
            return "onTriggerCrossTeam"
        elseif self._lastChat then
            if self._lastChat.channelId == CHANNEL_TYPE.UNION_CHANNEL then
                return "onTriggerUnion"
            end
            return "onTriggerGlobal"
        else
            return "onTriggerGlobal"
        end
    elseif app:getNavigationManager():getController(app.mainUILayer):getTopPage().inUnionPage or
     app:getNavigationManager():getController(app.mainUILayer):getTopPage().inSilverMinePage then
        return "onTriggerUnion"
    elseif self._state == QUIWidgetChat.STATE_TEAM then
        return "onTriggerTeam"
    elseif self._state == QUIWidgetChat.STATE_ALL and self._lastChat and self._lastChat.channelId then
        if self._lastChat.channelId == CHANNEL_TYPE.UNION_CHANNEL then
            return "onTriggerUnion"
        elseif self._lastChat.channelId == CHANNEL_TYPE.PRIVATE_CHANNEL then
            return "onTriggerPrivate"
        elseif self._lastChat.channelId == CHANNEL_TYPE.USER_DYNAMIC_CHANNEL then
            return "onTriggerDynamic"
        else
            return "onTriggerGlobal"
        end
    else
        return "onTriggerGlobal"
    end
end

function QUIWidgetChat:_onChatButtonClick()
    local isTeamChannel = false
    local haveCrossChannel = false
    if self._state == QUIWidgetChat.STATE_TEAM then
        isTeamChannel = true
    end
    local force = false
    if self._isShowPrivateRedTips then
        force = true
        self._isShowPrivateRedTips = false
    end

    self.showChatDialog = true
    local closeCallback = function ()
        if self._ccbOwner == nil then return end

        self.showChatDialog = false
        self:checkPrivateChannelRedTips()
    end
    return app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogChat", 
        options = {initTab =  self:_getInitTab(), force = force, effectInName = "showDialogLeftSmooth", effectOutName = "hideDialogLeftSmooth", isTeamChannel = isTeamChannel,
        inChannelState = self.inChannelState, isMain = self._isMain, isInUnion = self._isInUnion, isInBlackRock = self._isInBlackRock, closeCallback = closeCallback}})
end

function QUIWidgetChat:_onChatAreaClick()
    if not self._hidden then
        self:_onChatButtonClick()
    end
end

-- http://jira.joybest.com.cn/browse/WOW-15274
function QUIWidgetChat:checkPrivateChannelRedTips()
    if self._ccbOwner == nil then return end

    local isShowPrivateRedTips = false
    if self._state == QUIWidgetChat.STATE_ALL or self._state == QUIWidgetChat.STATE_PRIVATE then
        local lastReadTime, lastOperationTime = 0, 0
        if self._lastChat and self._lastChat.misc and self._lastChat.misc.type == "dynamic" then
            lastReadTime = app:getServerChatData():getLastMessageReadTime(app:getServerChatData():userDynamicChannelId())
            lastOperationTime = app:getServerChatData():getLastMessageReceiveTime(app:getServerChatData():userDynamicChannelId())
        else
            lastReadTime = app:getServerChatData():getLastMessageReadTime(app:getServerChatData():privateChannelId())
            lastOperationTime = app:getServerChatData():getLastMessageReceiveTime(app:getServerChatData():privateChannelId())
        end
        if lastReadTime < lastOperationTime then
            isShowPrivateRedTips = true
        end
    end
    if self._state == QUIWidgetChat.STATE_ALL or self._state == QUIWidgetChat.STATE_UNION or self._state == QUIWidgetChat.STATE_TEAM then
        if remote.user.userConsortia.consortiaId and remote.user.userConsortia.consortiaId ~= "" then
            local lastReadTime = app:getServerChatData():getLastMessageReadTime(app:getServerChatData():unionChannelId())
            local lastReceivedTime = app:getServerChatData():getLastMessageReceiveTime(app:getServerChatData():unionChannelId())
            if lastReadTime < lastReceivedTime then
                isShowPrivateRedTips = true
            end
        end
    end
    if self._state == QUIWidgetChat.STATE_TEAM then
        local lastReadTime1 = app:getServerChatData():getLastMessageReadTime(app:getServerChatData():teamChannelId())
        local lastReceivedTime1 = app:getServerChatData():getLastMessageReceiveTime(app:getServerChatData():teamChannelId())

        if lastReadTime1 < lastReceivedTime1 then
            isShowPrivateRedTips = true
        end
    end

    if self.inChannelState == CHAT_CHANNEL_INTYPE.CHANNEL_IN_SILVES then
        isShowPrivateRedTips = remote.silvesArena:getNewMessageState()
    end

    self._ccbOwner.private_tip:setVisible(isShowPrivateRedTips)

    self._isShowPrivateRedTips = isShowPrivateRedTips
end

return QUIWidgetChat