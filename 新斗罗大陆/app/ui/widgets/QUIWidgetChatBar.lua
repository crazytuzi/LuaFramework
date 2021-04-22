--
-- Author: Qinyuanji
-- Date: 2015-03-20
--
local QUIWidget = import(".QUIWidget")
local QUIWidgetChatBar = class("QUIWidgetChatBar", QUIWidget)
local QUIViewController = import("..QUIViewController")
local QColorLabel = import("...utils.QColorLabel")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QMaskWords = import("...utils.QMaskWords")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QNavigationController = import("...controllers.QNavigationController")
local QQuickWay = import("...utils.QQuickWay")
local QReplayUtil = import("...utils.QReplayUtil")

QUIWidgetChatBar.MIN_HEIGHT = 88
QUIWidgetChatBar.MIN_CHATHEIGHT = 26
QUIWidgetChatBar.MIN_CHATWIDTH = 20
QUIWidgetChatBar.ADMIN_HEIGHT = 40
QUIWidgetChatBar.FONT_SIZE = 22
QUIWidgetChatBar.MARGIN = 7
QUIWidgetChatBar.FACE_WITH = 52

QUIWidgetChatBar.DETAIL_INFO = "QUIWidgetChatBar_DETAIL_INFO"
QUIWidgetChatBar.CLOSE_DIALOG = "QUIWidgetChatBar_CLOSE_DIALOG"


function QUIWidgetChatBar:ctor(options)
  	local ccbFile = "ccb/Widget_Chat_Client.ccbi"
  	local callBacks = {
        {ccbCallbackName = "onTriggerReplay", callback = handler(self, QUIWidgetChatBar._onTriggerReplay)},
        {ccbCallbackName = "onTriggerApply", callback = handler(self, QUIWidgetChatBar._onTriggerApply)},
        {ccbCallbackName = "onTriggerGoto", callback = handler(self, QUIWidgetChatBar._onTriggerGoto)},
        {ccbCallbackName = "onTriggerAssist", callback = handler(self, QUIWidgetChatBar._onTriggerAssist)},
  	}
  	QUIWidgetChatBar.super.ctor(self, ccbFile, callBacks, options)

    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self._enableHead = true
    self._exit = true
end

function QUIWidgetChatBar:getContentSize( )
    local size = self._ccbOwner.background:getContentSize()
    size.height = self._height+10
    return size
end
function QUIWidgetChatBar:onEnter()
end

function QUIWidgetChatBar:onExit()
    self:removeAllEventListeners()

    self.super.onExit(self)

    if self._gotoLockScheduler then
        scheduler.unscheduleGlobal(self._gotoLockScheduler)
        self._gotoLockScheduler = nil
    end

    self._exit = nil
end

function QUIWidgetChatBar:onTouchListView( event )
    if not event then
        return
    end

    if event.name == "moved" then
        local contentListView = self._parent:getContentListView()
        if contentListView then
            local curGesture = contentListView:getCurGesture() 
            if curGesture then
                if curGesture == QListView.GESTURE_V then
                    self._listView:setCanNotTouchMove(true)
                elseif curGesture == QListView.GESTURE_H then
                    contentListView:setCanNotTouchMove(true)
                end
            end
        end
    elseif  event.name == "ended" then
        local contentListView = self._parent:getContentListView()
        if contentListView then
            contentListView:setCanNotTouchMove(nil)
        end
        self._listView:setCanNotTouchMove(nil)
    end

    self._listView:onTouch(event)
end

function QUIWidgetChatBar:setInfo(channelId, from, to, message, stamp, misc, hide, parent, channelType, isTeamChannel)
    self._parent = parent
    self._channelId = channelId
    self._misc = misc
    self._isTeamChannel = isTeamChannel
    self._ccbOwner.sys:setVisible(misc.type == "admin")
    self._ccbOwner.other:setVisible(misc.type ~= "admin")
    self._ccbOwner.me:setVisible(misc.type ~= "admin")

    self._ccbOwner.btnGoto:setVisible(false)
    self._ccbOwner.btnApply:setVisible(false)
    self._ccbOwner.btn_assist:setVisible(false)
    self._ccbOwner.replay1:setVisible(false)
    self._ccbOwner.replay2:setVisible(false)

    local index = 1 -- 其他人
    if misc.type == "admin" then
        self._ccbOwner.btnApply:setVisible(false)
        self._textWidth = self._ccbOwner["textAreaSys"]:getContentSize().width
        local width = self._textWidth
        if misc.index then
            local noticeInfo = QStaticDatabase:sharedDatabase():getNoticeContentByNoticeIndex(misc.index)
            if noticeInfo.shortcut then
                self._misc.link = noticeInfo.shortcut
                width = self._textWidth - 100
                self._ccbOwner.btnGoto:setVisible(true)
                self._ccbOwner.btnGoto:setPositionY(-15)
            end
        end
        self:showSysMessage(message, self._ccbOwner.msgSys, width, QUIWidgetChatBar.ADMIN_HEIGHT, hide, GAME_COLOR_LIGHT.stress, false)
        if stamp then
            -- self._ccbOwner.timeStampSys:setString(q.date("%H:%M", stamp))
        end
    elseif misc.type == SILVES_ARENA_CHAT_TYPE.SILVERS_ARENA_GLOBAL or misc.type == SILVES_ARENA_CHAT_TYPE.SILVERS_ARENA_TEAM_SHARE or misc.type == SILVES_ARENA_CHAT_TYPE.SILVERS_ARENA_TEAM then 
        --  SILVERS_ARENA_GLOBAL ; // 1是跨服  SILVERS_ARENA_TEAM_SHARE 是队伍分享  SILVERS_ARENA_TEAM是组队聊天
        self._enableHead = false
        local btnTipsPath = nil
        self._ccbOwner.btnGoto:setVisible(misc.type == SILVES_ARENA_CHAT_TYPE.SILVERS_ARENA_TEAM_SHARE and to == nil)
        if misc.type == SILVES_ARENA_CHAT_TYPE.SILVERS_ARENA_TEAM_SHARE and to == nil then
            btnTipsPath = QResPath("chat_btnTips_path")[7]
        end
        self._ccbOwner.me:setVisible(to ~= nil)
        if to ~= nil then
            index = 2 -- 自己
        elseif tostring(misc.name) == tostring(remote.user.name) then
            index = 2
        end            
        self._ccbOwner.other:setVisible(index == 1)
        self._ccbOwner.me:setVisible(index == 2)

        self._ccbOwner["nickName"..index]:setString(misc.nickName)
        -- self._ccbOwner["vip_level"..index]:setString(misc.vip or 0)
        self._textWidth = self._ccbOwner["textArea"..index]:getContentSize().width
        self:showChatMessage(message, self._ccbOwner["msgNode"..index], self._textWidth , QUIWidgetChatBar.MIN_HEIGHT, hide, GAME_COLOR_LIGHT.normal, true, index,btnTipsPath)

        self._ccbOwner["node_headPicture"..index]:removeAllChildren()
        self._avatar = misc.avatar
        local avatar = QUIWidgetAvatar.new(misc.avatar or -1)
        avatar:setSilvesArenaPeak(misc.championCount)
        avatar:addEventListener(QUIWidgetAvatar.CLICK, function ()
            app.tip:floatTip("魂师大人，目前无法查看此人信息哦~")
        end) 
        self._ccbOwner["node_headPicture"..index]:addChild(avatar)
        self._ccbOwner["timeStamp"..index]:setString(q.date("%H:%M", stamp/1000))
        
        self._ccbOwner["channel"..index]:removeAllChildren()
        self._badgeCount = misc.badge or 0
        local config = QStaticDatabase:sharedDatabase():getBadgeByCount(tonumber(self._badgeCount))
        local badge = nil
        if config then
            badge = CCTextureCache:sharedTextureCache():addImage(config.alphaicon)
        end
        if badge then
            self._ccbOwner["channel"..index]:addChild(CCSprite:createWithTexture(badge))
        end
        -- 聊天增加称号显示
        self:setSoulTrial(index)
        self:setVipLevel(misc.vip or 0,index)

    elseif misc.type == "blackrock" then
        self._enableHead = false
        local showMessage = message
        self._ccbOwner.btnGoto:setVisible(true)
        -- self._ccbOwner.me:setVisible(false)
        if tostring(misc.name) == tostring(remote.user.name) then
            index = 2
            showMessage = QColorLabel.blackRockReplaceColorSign(showMessage,true)
        end
        self._ccbOwner.other:setVisible(index == 1)
        self._ccbOwner.me:setVisible(index == 2)

        self._ccbOwner["nickName"..index]:setString(misc.nickName)
        -- self._ccbOwner["vip_level"..index]:setString(misc.vip or 0)
        self._textWidth = self._ccbOwner["textArea"..index]:getContentSize().width
        self:showChatMessage(showMessage, self._ccbOwner["msgNode"..index], self._textWidth , QUIWidgetChatBar.MIN_HEIGHT, hide, GAME_COLOR_LIGHT.normal, true, index,QResPath("chat_btnTips_path")[1])

        self._ccbOwner["node_headPicture"..index]:removeAllChildren()
        self._avatar = misc.avatar
        local avatar = QUIWidgetAvatar.new(misc.avatar or -1)
        avatar:setSilvesArenaPeak(misc.championCount)
        avatar:addEventListener(QUIWidgetAvatar.CLICK, function ()
            app.tip:floatTip("魂师大人，目前无法查看此人信息哦~")
        end) 
        
        if index == 2 then avatar:setScaleX(-1) end

        self._ccbOwner["node_headPicture"..index]:addChild(avatar)
        self._ccbOwner["timeStamp"..index]:setString(q.date("%H:%M", stamp))
        
        self._ccbOwner["channel"..index]:removeAllChildren()
        self._badgeCount = misc.badge or 0
        local config = QStaticDatabase:sharedDatabase():getBadgeByCount(tonumber(self._badgeCount))
        local badge = nil
        if config then
            badge = CCTextureCache:sharedTextureCache():addImage(config.alphaicon)
        end
        if badge then
            self._ccbOwner["channel"..index]:addChild(CCSprite:createWithTexture(badge))
        end
        -- 聊天增加称号显示
        self:setSoulTrial(index)
        self:setVipLevel(misc.vip or 0,index)
        local btnSize = self._ccbOwner["msgBg"..index]:getContentSize()
        self._ccbOwner.btn_goto_btn:setPreferredSize(btnSize)

    elseif misc.type == "dynamic" then
        self._enableHead = false
        self._ccbOwner.btnGoto:setVisible(true)
        self._ccbOwner.me:setVisible(false)

        self._ccbOwner["nickName"..index]:setString(misc.nickName or "")
        -- self._ccbOwner["vip_level"..index]:setString(misc.vip or 0)
        self._textWidth = self._ccbOwner["textArea"..index]:getContentSize().width
        self:showChatMessage(message, self._ccbOwner["msgNode"..index], self._textWidth , QUIWidgetChatBar.MIN_HEIGHT, hide, GAME_COLOR_LIGHT.normal, false, index,QResPath("chat_btnTips_path")[3])

        self._ccbOwner["node_headPicture"..index]:removeAllChildren()
        self._avatar = misc.avatar
        local avatar = QUIWidgetAvatar.new(misc.avatar or -1)
        avatar:setSilvesArenaPeak(misc.championCount)
        avatar:addEventListener(QUIWidgetAvatar.CLICK, function ()
            -- app.tip:floatTip("魂师大人，目前无法查看此人信息哦~")
        end) 
        self._ccbOwner["node_headPicture"..index]:addChild(avatar)
        self._ccbOwner["timeStamp"..index]:setString(q.date("%H:%M", stamp))
        
        self._ccbOwner["channel"..index]:removeAllChildren()
        self._badgeCount = misc.badge or 0
        local config = QStaticDatabase:sharedDatabase():getBadgeByCount(tonumber(self._badgeCount))
        local badge = nil
        if config then
            badge = CCTextureCache:sharedTextureCache():addImage(config.alphaicon)
        end
        if badge then
            self._ccbOwner["channel"..index]:addChild(CCSprite:createWithTexture(badge))
        end

        if self._channelId == 2 then
            self:setSOP(index)
        else
            self:setSoulTrial(index)
        end
        self:setVipLevel(misc.vip or 0,index)

    else
        -- Use index to indiciate which is sent by user or received by others
        if tostring(misc.name) == tostring(remote.user.name) then
            index = 2
        end

        self._ccbOwner.other:setVisible(index == 1)
        self._ccbOwner.me:setVisible(index == 2)

        self._replayId = misc.replay
        self._replayType = misc.replayType
        self._matchingId = misc.matchingId
        self._isFight = misc.isFight
        self._uid = misc.uid
        self._vip = misc.vip or 0
        self._union = misc.union or ""
        self._level = misc.level or 0
        self._assist = misc.assist
        self._seq = misc.seq
        self._ccbOwner["replay"..index]:setVisible(misc.replay ~= nil)
        self._ccbOwner["info"..index]:setVisible(true)
        self._ccbOwner["twoBar"..index]:setVisible(true)

        local widthLimit = 0
        local heightLimit = QUIWidgetChatBar.MIN_HEIGHT
        self._conscribe = misc.conscribe
        self._conscribeUnionName = misc.conscribeUnionName
        self._conscribeUnionLevelLimit = misc.conscribeUnionLevelLimit
        self._conscribeUnionNotice = misc.conscribeUnionNotice

        -- silvermine 相关
        self._silvermineCaveId = misc.caveId
        self._silvermineCaveRegion = misc.caveRegion
        self._silvermineCaveName = misc.caveName
        local btnTipsPath = nil
        if index == 1 and self._conscribe then
            self._ccbOwner.btnApply:setVisible(true)
            self._ccbOwner.btnGoto:setVisible(false)
            widthLimit = 60
            heightLimit = 120
            btnTipsPath = QResPath("chat_btnTips_path")[2]
        elseif index == 1 and self._silvermineCaveId then
            self._ccbOwner.btnGoto:setVisible(true)
            self._ccbOwner.btnApply:setVisible(false)
            widthLimit = 60
            btnTipsPath = QResPath("chat_btnTips_path")[3]
        elseif index == 1 and self._assist then
            widthLimit = 60
            self._ccbOwner.btnApply:setVisible(false)
            self._ccbOwner.btnGoto:setVisible(false)
        else
            self._ccbOwner.btnApply:setVisible(false)
            self._ccbOwner.btnGoto:setVisible(false)
        end

        self._isPlunder = misc.isPlunder
        -- silver mine assist area
        self._ccbOwner.btn_assist:setVisible(self._assist and index == 1)
        if self._assist and index == 1 then
            self._ccbOwner.assist:setVisible(tostring(self._assist) ~= "0" and tostring(self._assist) ~= "-1")
            if tostring(self._assist) ~= "0" and tostring(self._assist) ~= "-1" then
                btnTipsPath = QResPath("chat_btnTips_path")[4]
            elseif tostring(self._assist) == "0" then
                btnTipsPath = QResPath("chat_btnTips_path")[6]
            elseif tostring(self._assist) == "-1" then
                btnTipsPath = QResPath("chat_btnTips_path")[5]
            end
            -- self._ccbOwner.assistDone:setVisible(tostring(self._assist) == "0")
            -- self._ccbOwner.assistFailed:setVisible(tostring(self._assist) == "-1")
        end

        self._textWidth = self._ccbOwner["textArea"..index]:getContentSize().width
        self:showChatMessage(message, self._ccbOwner["msgNode"..index], self._textWidth , heightLimit, hide, GAME_COLOR_LIGHT.normal, true, index,btnTipsPath)

        self._nickName = misc.nickName ~= "" and misc.nickName or ""
        self._ccbOwner["nickName"..index]:setString(self._nickName)
        -- self._ccbOwner["vip_level"..index]:setString(misc.vip or 0)
        self._ccbOwner["node_headPicture"..index]:removeAllChildren()

        self._avatar = misc.avatar
        local avatar = QUIWidgetAvatar.new(misc.avatar or -1)
        avatar:setSilvesArenaPeak(misc.championCount)
        if index == 2 then avatar:setScaleX(-1) end
        self._ccbOwner["node_headPicture"..index]:addChild(avatar)
        if self._isTeamChannel then
            avatar:addEventListener(QUIWidgetAvatar.CLICK, function ()
                app.tip:floatTip("魂师大人，目前无法查看此人信息哦~")
            end) 
        else
            avatar:addEventListener(QUIWidgetAvatar.CLICK, handler(self, self._onAvatarClicked))
        end

        self._ccbOwner["timeStamp"..index]:setString(q.date("%H:%M", stamp))

        self._ccbOwner["channel"..index]:removeAllChildren()
        self._badgeCount = misc.badge or 0
        local config = QStaticDatabase:sharedDatabase():getBadgeByCount(tonumber(self._badgeCount))
        local badge = nil
        if config then
            badge = CCTextureCache:sharedTextureCache():addImage(config.alphaicon)
        end
        if badge then
            self._ccbOwner["channel"..index]:addChild(CCSprite:createWithTexture(badge))
        end        
        if misc.userType and tonumber(misc.userType) == 2 then
            self._ccbOwner["sp_zhidao"..index]:setVisible(true)
            self._ccbOwner.msgBg1:setVisible(false)
            self._ccbOwner.msgBg1:setVisible(true)
        else
            self._ccbOwner["sp_zhidao"..index]:setVisible(false)
            self._ccbOwner.msgBg1:setVisible(true)
        end

        if misc.skinId and misc.heroId then
            self._ccbOwner.replay1:setVisible(true)
            self._ccbOwner.replay2:setVisible(true)
        end        

        -- 聊天增加称号显示
        -- QPrintTable(misc)
        if self._channelId == 2 then
            self:setSOP(index)
        else
            self:setSoulTrial(index)
        end
        self:setVipLevel(misc.vip or 0,index)
    end

    local btnSize = self._ccbOwner["msgBg"..index]:getContentSize()
    self._ccbOwner.btn_apply_btn:setPreferredSize(btnSize)
    self._ccbOwner.btn_goto_btn:setPreferredSize(btnSize)
    self._ccbOwner.btn_assist_btn:setPreferredSize(btnSize)
end

function QUIWidgetChatBar:getAplybtnVisible( )
    return self._ccbOwner.btnApply:isVisible()
end

function QUIWidgetChatBar:getGobtnVisible( )
    return self._ccbOwner.btnGoto:isVisible()
end

function QUIWidgetChatBar:getAssistbtnVisible( )
    return self._ccbOwner.btn_assist:isVisible()
end

function QUIWidgetChatBar:setSOP(index)
    print("function QUIWidgetChatBar:setSOP(index)", self._misc.societyOP)
    local sf = QSpriteFrameByKey("society_op", tonumber(self._misc.societyOP))

    local vipLevel = tonumber(self._misc.vip or 0) 
    local posX1 = -30
    local posX2 = -15
    if index == 1 then
        posX1 = -370
        posX2 = -395
    end
    if vipLevel >= 10 then
        self._ccbOwner["nickName"..index]:setPositionX(posX1)
    else
        self._ccbOwner["nickName"..index]:setPositionX(posX2)
    end  

    if self._misc.societyOP and sf then
        self._ccbOwner["sp_soulTrial"..index]:setDisplayFrame(sf)
        local size = self._ccbOwner["sp_soulTrial"..index]:getContentSize()
        if index == 1 then
            self._ccbOwner["sp_soulTrial"..index]:setPositionY(17)
            q.autoLayerNode({self._ccbOwner["nickName"..index],self._ccbOwner["sp_soulTrial"..index],self._ccbOwner["sp_zhidao"..index]},"x",5)
            -- self._ccbOwner["nickName"..index]:setPositionX(self._ccbOwner["sp_soulTrial"..index]:getPositionX() + size.width + 10)
        elseif index == 2 then
            self._ccbOwner["sp_soulTrial"..index]:setPositionY(29)
            -- self._ccbOwner["nickName"..index]:setPositionX(self._ccbOwner["sp_soulTrial"..index]:getPositionX() - size.width - 10)
            q.turnAutoLayerNode({self._ccbOwner["nickName"..index],self._ccbOwner["sp_soulTrial"..index],self._ccbOwner["sp_zhidao"..index]},"x",0)    
            -- q.turnAutoLayerNode({self._ccbOwner["sp_soulTrial"..index],self._ccbOwner["sp_zhidao"..index]},"x",50)
        end
        self._ccbOwner["sp_soulTrial"..index]:setVisible(true)
    else
        self._ccbOwner["sp_soulTrial"..index]:setVisible(false)
         if index == 1 then
            self._ccbOwner["sp_soulTrial"..index]:setPositionY(17)
            -- self._ccbOwner["nickName"..index]:setPositionX(self._ccbOwner["sp_soulTrial"..index]:getPositionX() + 10)
            q.autoLayerNode({self._ccbOwner["nickName"..index],self._ccbOwner["sp_zhidao"..index]},"x",5)
        elseif index == 2 then
            self._ccbOwner["sp_soulTrial"..index]:setPositionY(29)
            -- self._ccbOwner["nickName"..index]:setPositionX(self._ccbOwner["sp_soulTrial"..index]:getPositionX() - 10)
            q.turnAutoLayerNode({self._ccbOwner["nickName"..index],self._ccbOwner["sp_zhidao"..index]},"x",5)    
        end
    end
end

function QUIWidgetChatBar:setSoulTrial(index)
    print("function QUIWidgetChatBar:setSoulTrial(index)", self._misc.soulTrial)
    local _, frame = remote.soulTrial:getSoulTrialTitleSpAndFrame(self._misc.soulTrial)

    local vipLevel = tonumber(self._misc.vip or 0) 
    
    -- local vipNodePosFunc = function()
    local posX1 = -30
    local posX2 = -15
    if index == 1 then
        posX1 = -370
        posX2 = -395
    end
    if vipLevel >= 10 then
        self._ccbOwner["nickName"..index]:setPositionX(posX1)
    else
        self._ccbOwner["nickName"..index]:setPositionX(posX2)
    end  
    -- end

    if self._misc.soulTrial and frame then
        self._ccbOwner["sp_soulTrial"..index]:setDisplayFrame(frame)
        local size = self._ccbOwner["nickName"..index]:getContentSize()
        if index == 1 then
            self._ccbOwner["sp_soulTrial"..index]:setPositionY(12)
            q.autoLayerNode({self._ccbOwner["nickName"..index],self._ccbOwner["sp_soulTrial"..index],self._ccbOwner["sp_zhidao"..index]},"x",5)
            -- self._ccbOwner["sp_soulTrial"..index]:setPositionX(self._ccbOwner["nickName"..index]:getPositionX() + size.width)
            -- self._ccbOwner["sp_zhidao"..index]:setPositionX(self._ccbOwner["sp_soulTrial"..index]:getPositionX() + self._ccbOwner["sp_soulTrial"..index]:getContentSize().width + 10)
        elseif index == 2 then
            self._ccbOwner["nickName"..index]:setPositionY(24)
            q.turnAutoLayerNode({self._ccbOwner["nickName"..index],self._ccbOwner["sp_soulTrial"..index],self._ccbOwner["sp_zhidao"..index]},"x",5)        
            -- self._ccbOwner["sp_soulTrial"..index]:setPositionX(self._ccbOwner["nickName"..index]:getPositionX() - size.width)
            -- self._ccbOwner["sp_zhidao"..index]:setPositionX(self._ccbOwner["sp_soulTrial"..index]:getPositionX() - self._ccbOwner["sp_soulTrial"..index]:getContentSize().width)
        end
        self._ccbOwner["sp_soulTrial"..index]:setVisible(true)
    else
        self._ccbOwner["sp_soulTrial"..index]:setVisible(false)
         if index == 1 then
            self._ccbOwner["sp_soulTrial"..index]:setPositionY(12)
            q.autoLayerNode({self._ccbOwner["nickName"..index],self._ccbOwner["sp_zhidao"..index]},"x",5)
            -- self._ccbOwner["sp_soulTrial"..index]:setPositionX(self._ccbOwner["nickName"..index]:getPositionX() + 10)
            -- self._ccbOwner["sp_zhidao"..index]:setPositionX(self._ccbOwner["nickName"..index]:getPositionX() + self._ccbOwner["nickName"..index]:getContentSize().width + 10)
        elseif index == 2 then
            self._ccbOwner["nickName"..index]:setPositionY(24)
            q.turnAutoLayerNode({self._ccbOwner["nickName"..index],self._ccbOwner["sp_zhidao"..index]},"x",5)
            -- self._ccbOwner["sp_soulTrial"..index]:setPositionX(self._ccbOwner["nickName"..index]:getPositionX() - 10)
            -- self._ccbOwner["sp_zhidao"..index]:setPositionX(self._ccbOwner["nickName"..index]:getPositionX() - self._ccbOwner["nickName"..index]:getContentSize().width)            
        end
    end
end

function QUIWidgetChatBar:setVipLevel(level,index )
    if level == nil or index == nil then return end
    local vipLevel = tonumber(level)
    local nodes = {}
    local strLen = string.len(level)
    -- if self._ccbOwner["sp_vip"..index] then
    --     table.insert(nodes,self._ccbOwner["sp_vip"..index])
    -- end
    local spVipNum = 2
    local paths = QResPath("chat_vip_path")
    if vipLevel > 9 then
        spVipNum = 3
        for i = 1, strLen, 1 do
            local num = tonumber(string.sub(level, i, i))
            if num == 0 then num = 10 end
            if i>2 then
                break
            end
            local vipSprite = self._ccbOwner["sp_vip_level"..index.."_"..i]
            if vipSprite then
                QSetDisplaySpriteByPath(vipSprite,paths[num])
                table.insert(nodes,vipSprite)
            end
        end 
    else
        if  vipLevel == 0 then
            vipLevel = 10
        end
        if self._ccbOwner["sp_vip_level"..index.."_1"] then
            table.insert(nodes,self._ccbOwner["sp_vip_level"..index.."_1"])
            QSetDisplaySpriteByPath(self._ccbOwner["sp_vip_level"..index.."_1"],paths[vipLevel])
        end
        if self._ccbOwner["sp_vip_level"..index.."_2"] then
            self._ccbOwner["sp_vip_level"..index.."_2"]:setVisible(false)
        end
    end
    if vipLevel >= 20 then
        q.autoLayerNode(nodes,"x",-5) 
        self._ccbOwner["sp_vip_level"..index.."_1"]:setPositionX(22)
    else
        if self._ccbOwner["sp_vip_level"..index.."_1"] then
            self._ccbOwner["sp_vip_level"..index.."_1"]:setPositionX(20)
        end
        q.autoLayerNode(nodes,"x",-8) 
    end
    local size = self._ccbOwner["nickName"..index]:getContentSize()
    if index == 1 then
        self._ccbOwner["node_vip"..index]:setPositionX(-435)
    elseif index == 2 then
        if tonumber(level) >= 10 then
            self._ccbOwner["node_vip"..index]:setPositionX(-20)
        else
            self._ccbOwner["node_vip"..index]:setPositionX(-5)
        end     
    end
end

function QUIWidgetChatBar:showSysMessage(message, node, width, minHeight, hide, color, mask)
    assert(message, "no message for system bulletin")

    if device.platform == "android" or device.platform == "windows" then
        message = QReplaceEmoji(message)
    end

    self._height = minHeight

    local richText = QColorLabel:create(message, width, 0, mask, QUIWidgetChatBar.FONT_SIZE, color, global.font_zhcn)
    if not hide then
        node:removeAllChildren()
        node:addChild(richText)
    end    

    local newHeight = richText:getActualHeight() + QUIWidgetChatBar.MARGIN*2 + 10
    self._height = newHeight < minHeight and minHeight or newHeight
end

function QUIWidgetChatBar:showChatMessage(message, node, width, minHeight, hide, color, mask, index,btnTipsPath)
    assert(message, "no message for chat")

    if device.platform == "android" or device.platform == "windows" then
        message = QReplaceEmoji(message)
    end
    local showBtnTips = btnTipsPath
    if index == 2 then
        showBtnTips = nil
    end
    if self._channelId == CHANNEL_TYPE.GLOBAL_CHANNEL and not self._isTeamChannel and self._misc.type == nil then
        message = app:getServerChatData():checkMessageLength(message)
    end
    
    self._height = minHeight
    local richText = QColorLabel:createForChat(message, width, 0, mask, QUIWidgetChatBar.FONT_SIZE, color, global.font_zhcn,nil,nil,showBtnTips)
    if not hide then
        node:removeAllChildren()
        node:addChild(richText)
    end    

    
    local richTextWidth = richText:getRealWidth()
    local chatHeight = richText:getActualHeight() < QUIWidgetChatBar.MIN_CHATHEIGHT and QUIWidgetChatBar.MIN_CHATHEIGHT or richText:getActualHeight()
    local newHeight = self._ccbOwner["banner"..index]:getContentSize().width + chatHeight + QUIWidgetChatBar.MARGIN*3
    self._height = newHeight < minHeight and minHeight or newHeight

    richTextWidth = richTextWidth < QUIWidgetChatBar.MIN_CHATWIDTH and QUIWidgetChatBar.MIN_CHATWIDTH or richTextWidth
    
    local size = CCSizeMake(richTextWidth + 40, chatHeight + QUIWidgetChatBar.MARGIN)
    if index == 2 then
        richText:setPositionX(richText:getPositionX() - richTextWidth) 
        -- size.width = size.width + 20
    end
    if self._misc.userType and tonumber(self._misc.userType) == 2 then
        self._ccbOwner.msgBg1:setContentSize(size)
    end
    self._ccbOwner["msgBg"..index]:setContentSize(size)
end

function QUIWidgetChatBar:_onTriggerReplay(e)
    if e ~= nil then
        app.sound:playSound("common_common")
    end
    if self._parent._isMoving then return end

    if self._replayType == REPORT_TYPE.DRAGON_WAR then
        remote.unionDragonWar:openUnionDragonWarFightReport(self._replayId)
    elseif self._replayType == REPORT_TYPE.SILVES_ARENA then

        local info = string.split(self._replayId,"$")
        local strInfo = string.split(info[2],";")

        local reportIdList = string.split(info[1],";")
        for i,v in ipairs(reportIdList) do
            reportIdList[i] = tonumber(v)
        end
        local matchingId = strInfo[1]
        local isFight = strInfo[2] == 1
        remote.silvesArena:silvesLookHistoryDetail(self._replayType,reportIdList, matchingId,isFight,false)

    elseif self._misc.skinId and self._misc.heroId then
        remote.heroSkin:openSkinDetailDialog(self._misc.skinId)
    else
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogReplayInfo", 
            options = {replayId = self._replayId, replayType = self._replayType}}, {isPopCurrentDialog = false})
    end
end
 

function QUIWidgetChatBar:_onTriggerApply(event)
    app.sound:playSound("common_small")
    if not self._parent._isMoving then
        local level = tonumber(self._conscribeUnionLevelLimit)
        if level then

            if not app.unlock:getUnlockUnion() then
                app.tip:floatTip("宗门尚未解锁！")
                return
            end
            
            if remote.user.level < level then
                app.tip:floatTip("您当前的等级不符合申请要求！")
                return
            end


            if remote.user.userConsortia.consortiaName and remote.user.userConsortia.consortiaName ~= "" then
                app.tip:floatTip("魂师大人，您已经在一个宗门中了哦~")
                return
            end 
        end

        if not remote.user:checkJoinUnionCdAndTips() then return end

        -- local joinCD = QStaticDatabase.sharedDatabase():getConfigurationValue("ENTER_SOCIETY") * 60 
        -- local leave_at  = 0
        -- if remote.user.userConsortia.leave_at and remote.user.userConsortia.leave_at >0 then
        --     joinCD = remote.user.userConsortia.leave_at/1000 + joinCD - q.serverTime()  
        --     if joinCD > 0 then
        --         app.tip:floatTip(string.format("%d小时%d分钟内无法加入宗门", math.floor(joinCD/(60*60)), math.floor((joinCD/60)%60))) 
        --         return
        --     end
        -- end

        -- app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSocietyZhaomu", 
        --     options = {info = {sid = self._conscribe, name = self._conscribeUnionName, applyTeamLevel = self._conscribeUnionLevelLimit, notice = self._conscribeUnionNotice}}}, {isPopCurrentDialog = false})
        remote.union:unionGetRequest(self._conscribe, function(data)
            app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogUnionPrompt",
                options = {info = data.consortia, sid = self._conscribe, isShenqing = true}}, {isPopCurrentDialog = false})
        end)

    end
end

function QUIWidgetChatBar:_onTriggerGoto(event)
    app.sound:playSound("common_small")
    if self._gotoLock then return end
    self._gotoLock = true
    if self._gotoLockScheduler then
        scheduler.unscheduleGlobal(self._gotoLockScheduler)
        self._gotoLockScheduler = nil
    end
    self._gotoLockScheduler = scheduler.performWithDelayGlobal(function() 
            self._gotoLock = false
        end, 0.5)
    if self._misc ~= nil and self._misc.type == "blackrock" then
        local callFun = function ()
            remote.blackrock:blackRockJoinTeamRequest(self._misc.teamId, self._misc.chapterId, self._misc.password, 2,function ()
                app:getServerChatData():refreshTeamChatInfo()
                app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
                app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TO_CURRENT_PAGE)
                app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBlackRockTeam"})
            end)
        end
        if remote.blackrock:getAwardCount() > 0 then
            callFun()
        else
            local content = "魂师大人，您当前已无领奖次数，战斗结束将无法获得奖励，是否继续？"
            app:alert({content = content, colorful = true, title = "系统提示", callback = function (type)
                if type == ALERT_TYPE.CONFIRM then
                    callFun()
                end
            end}, false)
        end
        return
    end

    if self._misc ~= nil and self._misc.type == "dynamic" then
        remote.userDynamic:gotoDynamicFunction(self._misc.index)
        return
    end

    if self._misc ~= nil and (self._misc.type == SILVES_ARENA_CHAT_TYPE.SILVERS_ARENA_TEAM_SHARE) then
        if self._misc.teamId == nil then
            return
        end
        --  离队申请
        -- remote.silvesArena:silvesArenaQuitTeamRequest(self._misc.teamId,function ( data )
        --     -- 申请入队
        --     app.tip:floatTip("已退出队伍")
        -- end)
        remote.silvesArena:silvesArenaApplyTeamRequest(self._misc.teamId,false,function ( data )
            -- 申请入队
            app.tip:floatTip("队伍申请已发出，请耐心等待!")
        end)
        return
    end

    if self._misc.type == "admin" and self._misc.link then
        QQuickWay:clickGotoByIndex(self._misc.link, {mineId = self._misc.mineId})
        return 
    end

    local targetClass = ""
    if self._isPlunder then
        targetClass = "QUIDialogPlunderMain"
    else
        targetClass = "QUIDialogSilverMine"
    end
    local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
    if dialog == nil or dialog.__cname ~= targetClass then
        if self._isPlunder then
            if remote.plunder:checkPlunderUnlock(true) then
                local _, _, isActive = remote.plunder:updateTime()
                if isActive == false then
                    app.tip:floatTip("魂师大人，本次极北之地已经结束了～")
                    return
                end
                app:getNavigationManager():getController(app.mainUILayer):getTopPage():setAllUIVisible()
                app:getNavigationManager():getController(app.mainUILayer):getTopPage():setScalingVisible(false)
                app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPlunderMain", 
                    options = {caveId = tonumber(self._silvermineCaveId), caveRegion = tonumber(self._silvermineCaveRegion), caveName = self._silvermineCaveName}})
            end
        else
            if app.unlock:getUnlockSilverMine(true) then
                remote.silverMine:silvermineGetCaveListRequest(self._silvermineCaveRegion)
                app:getNavigationManager():getController(app.mainUILayer):getTopPage():setAllUIVisible()
                app:getNavigationManager():getController(app.mainUILayer):getTopPage():setScalingVisible(false)
                app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilverMine", 
                    options = {caveId = tonumber(self._silvermineCaveId), caveRegion = tonumber(self._silvermineCaveRegion), caveName = self._silvermineCaveName}})
            end
        end
    else
        app:getNavigationManager():getController(app.mainUILayer):getTopPage():setAllUIVisible()
        app:getNavigationManager():getController(app.mainUILayer):getTopPage():setScalingVisible(false)
        local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
        page:setAllUIVisible()
        page:setScalingVisible(false)
        page.topBar:showWithSilverMine()
        -- app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
        self:dispatchEvent({name = QUIWidgetChatBar.CLOSE_DIALOG})
        app:getNavigationManager():getController(app.mainUILayer):getTopDialog():gotoMine(tonumber(self._silvermineCaveId), tonumber(self._silvermineCaveRegion))
    end
    -- if not app:getNavigationManager():getController(app.mainUILayer):getTopPage().inSilverMinePage then 
    --     if self._isPlunder then
    --         app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPlunderMain", 
    --             options = {caveId = tonumber(self._silvermineCaveId), caveRegion = tonumber(self._silvermineCaveRegion), caveName = self._silvermineCaveName}})
    --     else
    --         app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilverMine", 
    --             options = {caveId = tonumber(self._silvermineCaveId), caveRegion = tonumber(self._silvermineCaveRegion), caveName = self._silvermineCaveName}})
    --     end
    -- elseif app:getNavigationManager():getController(app.mainUILayer):getTopPage().inSilverMinePage then
    --     local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    --     page:setAllUIVisible()
    --     page:setScalingVisible(false)
    --     page.topBar:showWithSilverMine()
    --     -- app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
    --     self:dispatchEvent({name = QUIWidgetChatBar.CLOSE_DIALOG})
    --     app:getNavigationManager():getController(app.mainUILayer):getTopDialog():gotoMine(tonumber(self._silvermineCaveId), tonumber(self._silvermineCaveRegion))
    -- else
    --     app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
    -- end
end

function QUIWidgetChatBar:_onTriggerAssist(event)
    app.sound:playSound("common_small")
    remote.silverMine:silverMineToAssistCaveRequest(self._uid, self._assist, function( response )
                if not self._exit then return end

                if response.silverMineToAssistCaveResponse then
                    local cave = response.silverMineToAssistCaveResponse.mineCaves
                    local mineId = nil

                    -- Check if silver mine has assisted
                    local assist = 0
                    local assisted = false
                    for k, v in ipairs(cave.occupies) do
                        if v.oriOccupyId == self._assist then
                            mineId = v.mineId
                            if #(v.assistUserInfo or {}) >= remote.silverMine:getAssistTotalCount() then
                                app.tip:floatTip("狩猎者协助人数已达上限~")
                                assist = -1
                                assisted = true
                            else
                                for k1, v1 in ipairs(v.assistUserInfo or {}) do
                                    if v1.userId == remote.user.userId then
                                        assisted = true
                                        break
                                    end
                                end
                            end

                            if assisted then
                                break
                            end
                        end
                    end

                    if assisted then
                        local chatData = app:getServerChatData()
                        chatData:updateLocalReceivedMessage(self._channelId, self._seq, {misc = {assist = assist}})
                        if assist == 0 then
                            self._ccbOwner.assist:setVisible(false)
                            -- self._ccbOwner.assistDone:setVisible(true)
                            -- self._ccbOwner.assistFailed:setVisible(false)
                        elseif assist == -1 then
                            self._ccbOwner.assist:setVisible(false)
                            -- self._ccbOwner.assistDone:setVisible(false)
                            -- self._ccbOwner.assistFailed:setVisible(true)
                        end
                    else
                        app:getNavigationManager():getController(app.mainUILayer):getTopPage():setAllUIVisible()
                        app:getNavigationManager():getController(app.mainUILayer):getTopPage():setScalingVisible(false)
                        if not app:getNavigationManager():getController(app.mainUILayer):getTopPage().inSilverMinePage then 
                            app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilverMine", 
                                options = {caveId = tonumber(cave.caveId), myMineId = tonumber(mineId)}})
                        elseif app:getNavigationManager():getController(app.mainUILayer):getTopPage().inSilverMinePage then
                            local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
                            page:setAllUIVisible()
                            page:setScalingVisible(false)
                            page.topBar:showWithSilverMine()
                            self:dispatchEvent({name = QUIWidgetChatBar.CLOSE_DIALOG})
                            -- app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
                            app:getNavigationManager():getController(app.mainUILayer):getTopDialog():gotoMine(tonumber(cave.caveId), nil, tonumber(mineId))
                        else
                            app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
                        end
                    end
                else
                    app.tip:floatTip("该协助邀请信息已过期")
                    
                    local chatData = app:getServerChatData()
                    chatData:updateLocalReceivedMessage(self._channelId, self._seq, {misc = {assist = -1}})

                    self._ccbOwner.assist:setVisible(false)
                    -- self._ccbOwner.assistDone:setVisible(false)
                    -- self._ccbOwner.assistFailed:setVisible(true)
                end
            end)
end

function QUIWidgetChatBar:_onAvatarClicked(event)
    if self._parent._isMoving or tostring(self._nickName) == tostring(remote.user.nickname) then return end
    if self._enableHead == false then return end
    
    if self._avatar == nil or self._nickName == nil or self._nickName == "" or self._level == nil or self._level == 0 then
        return
    end

    local chatterInfo = remote.friend:getFriendInfoById(self._uid) or {}
    chatterInfo.avatar = self._avatar
    chatterInfo.teamLevel = tonumber(self._level)
    chatterInfo.nickname = self._nickName
    chatterInfo.user_id = self._uid
    
    local consortiaName = self._conscribeUnionName
    if consortiaName == nil or consortiaName == "" then
        consortiaName = self._union
    end
    if consortiaName == nil or consortiaName == "" then
        consortiaName = chatterInfo.consortiaName
    end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogFriendInfo", 
        options = {info = chatterInfo, fromChat = true, vip_level = self._vip, level = self._level, consortiaName = consortiaName,
                    clickCallback = function (type)
                        remote:dispatchEvent({name = QUIWidgetChatBar.DETAIL_INFO, type = type, userId = chatterInfo.user_id, nickName = chatterInfo.nickname, avatar = chatterInfo.avatar})
                    end}}, {isPopCurrentDialog = false})
end

function QUIWidgetChatBar:checkMessageLength(message)
    local messageLen = string.utf8len(message)
    local str = message
    if messageLen > 50 then
        str = utf8.sub(message, 1, 50)
    end

    return str
end

function QUIWidgetChatBar:getHeight()
    return self._height + 20
end

return QUIWidgetChatBar