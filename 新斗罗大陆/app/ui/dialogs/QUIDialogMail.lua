
local QUIDialog = import(".QUIDialog")
local QUIDialogMail = class(".QUIDialogMail", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIWidgetMailSheet = import("..widgets.QUIWidgetMailSheet")
local QUIDialogMailContent = import("..dialogs.QUIDialogMailContent")
local QUIViewController = import("..QUIViewController")

local QListView = import("...views.QListView")

-- 邮件对话框
function QUIDialogMail:ctor(options)
	local ccbFile = "ccb/Dialog_Email.ccbi"
    self._mailSheets = {}

	local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
        {ccbCallbackName = "onTriggerOneGet", callback = handler(self, self._onTriggerOneGet)},
        {ccbCallbackName = "onTriggerClearAll", callback = handler(self, self._onTriggerClearAll)},
        {ccbCallbackName = "onTriggerClick1", callback = handler(self, self._onTriggerClick1)},
        {ccbCallbackName = "onTriggerClick2", callback = handler(self, self._onTriggerClick2)},
        {ccbCallbackName = "onTriggerClick3", callback = handler(self, self._onTriggerClick3)},     
        {ccbCallbackName = "onTriggerClick4", callback = handler(self, self._onTriggerClick4)},        
    }
    QUIDialogMail.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示
    q.setButtonEnableShadow(self._ccbOwner.btn_clearAll)

    self._ccbOwner.sp_no:setVisible(false)
    self._ccbOwner.tf_title:setString("邮 件")
    self._ccbOwner.btn_one:setPositionX(0)
    self._ccbOwner.btn_clear:setVisible(false)
    
    self:_initMailScrollView()
    self:_selectTab(options.tab)
end


function QUIDialogMail:viewDidAppear()
	QUIDialogMail.super.viewDidAppear(self)

    self._remoteProxy = cc.EventProxy.new(remote.mails)
    self._remoteProxy:addEventListener(remote.mails.MAILS_UPDATE_EVENT, handler(self, self._onEvent))

    QNotificationCenter.sharedNotificationCenter():addEventListener(QUIDialogMailContent.MAIL_EVENT_RECV_AWARD, self._onEvent,self)
    QNotificationCenter.sharedNotificationCenter():addEventListener(QUIDialogMailContent.MAIL_EVENT_CLOSE, self._onEvent,self)

    self:checkRedTips()
end

function QUIDialogMail:viewWillDisappear()
	QUIDialogMail.super.viewWillDisappear(self)
	self._remoteProxy:removeAllEventListeners()
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIDialogMailContent.MAIL_EVENT_RECV_AWARD, self._onEvent,self)
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIDialogMailContent.MAIL_EVENT_CLOSE, self._onEvent,self)
    
end

function QUIDialogMail:_selectTab(tab)
    if tab == nil then tab = remote.mails.ENUM_ALL end
    self._tab = tab
    self:getOptions().tab = tab
    self:_setSelectByIndex(1,false)
    self:_setSelectByIndex(2,false)
    self:_setSelectByIndex(3,false)
    self:_setSelectByIndex(4,false)
    self._ccbOwner.all_tips:setPositionX(-189)
    self._ccbOwner.awards_tips:setPositionX(-189)
    self._ccbOwner.system_tips:setPositionX(-189)
    self._ccbOwner.union_tips:setPositionX(-189)
    if tab == remote.mails.ENUM_ALL then
        self:_setSelectByIndex(1,true)
        self._ccbOwner.all_tips:setPositionX(-176)
    elseif tab == remote.mails.ENUM_AWARDS then
        self:_setSelectByIndex(2,true)
        self._ccbOwner.awards_tips:setPositionX(-176)
    elseif tab == remote.mails.ENUM_NO_AWARDS then
        self:_setSelectByIndex(3,true)
        self._ccbOwner.system_tips:setPositionX(-176)
    elseif tab == remote.mails.ENUM_UNION_MAIL then
        self:_setSelectByIndex(4,true)
        self._ccbOwner.union_tips:setPositionX(-176)
    end

    self:getData()
    self._listView:reload({totalNumber = #self._data})
end

function QUIDialogMail:_setSelectByIndex(index, isSelect)
    self._ccbOwner["btn_award_"..index]:setHighlighted(isSelect)
    self._ccbOwner["btn_award_"..index]:setEnabled(not isSelect)
    self._ccbOwner["tf_name_"..index.."_1"]:setVisible(not isSelect)
    self._ccbOwner["tf_name_"..index.."_2"]:setVisible(isSelect)
end

-- 初始化邮箱
function QUIDialogMail:_initMailScrollView()

    local clickBtnItemHandler = function ( x, y, touchNode, list)
        app.sound:playSound("common_small")
        local touchIndex = list:getCurTouchIndex()
        self:_showMailContent(self._data[touchIndex])
    end

    self:getData()
    local cfg = {
        renderItemCallBack = function( list, index, info )
            -- body
            local isCacheNode = true
            local item = list:getItemFromCache()
            local data = self._data[index]
            if not item then
                item = QUIWidgetMailSheet.new()
                isCacheNode = false
            end
            -- item:setPositionX(20)
            item:setInfo(data)
            info.item = item
            info.size = item:getContentSize()
            list:registerBtnHandler(index, "btn_click", clickBtnItemHandler)

            return isCacheNode
        end,
        spaceY = -3,
        curOffset = 2,
        curOriginOffset = -2,
        contentOffsetX = -2,
        enableShadow = false,
        totalNumber = #self._data,
        scrollEndCallBack = function ( )
            -- body
        end,

        scrollBeginCallBack = function ( ... )
            -- body
        end
    }  
    self._listView = QListView.new(self._ccbOwner.sheet_layout,cfg)
end

function QUIDialogMail:checkRedTips()
    local readMail = remote.mails:checkSystemMails()
    local awardsMail = remote.mails:checkAwardMail()
    local unionMail = remote.mails:checkUnionMails()

    self._ccbOwner.all_tips:setVisible(false)
    self._ccbOwner.system_tips:setVisible(false)
    self._ccbOwner.awards_tips:setVisible(false)
    self._ccbOwner.union_tips:setVisible(false)
    if readMail or awardsMail or unionMail then
        self._ccbOwner.all_tips:setVisible(true)
    end
    if readMail then
        self._ccbOwner.system_tips:setVisible(true)
    end
    if awardsMail then
        self._ccbOwner.awards_tips:setVisible(true)
    end
    if unionMail then
        self._ccbOwner.union_tips:setVisible(true)
    end
end

function QUIDialogMail:_recvMailAward(mail)
    -- mail.readed为false 说明没有领取过。否则就是已经领取过的  change by Kumo
    if mail.readed then return end

    remote.mails:mailRecvAward(mail.mailId, function ()
        local awards = {}
        if mail.awards ~= nil then
            for _,value in pairs(mail.awards) do
                table.insert(awards, {id = 0, typeName = value.type, count = value.count})
            end
        end
        if mail.items ~= nil then
            for _,value in pairs(mail.items) do
                table.insert(awards, {id = value.itemId, typeName = value.type, count = value.count})
            end
        end

        -- remote.mails:removeMailsForId(mail.mailId)
        
        local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
            options = {awards = awards}},{isPopCurrentDialog = false} )
        dialog:setTitle(self:updateRewardTitle(mail.key))
    end)
end

--一键领取邮件
function QUIDialogMail:_onTriggerOneGet(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_oneget) == false then return end
    app.sound:playSound("common_small")
    local mails = remote.mails:getMails()
    local awardMails = {}
    local awards = {}
    for index,mail in ipairs(mails) do
        local isFind = false
        -- mail.readed为false 说明没有领取过。否则就是已经领取过的  change by Kumo
        if mail.readed == false then
            if mail.awards ~= nil then
                for _,value in pairs(mail.awards) do
                    isFind = true
                    table.insert(awards, {id = 0, typeName = value.type, count = value.count})
                end
            end
            if mail.items ~= nil then
                for _,value in pairs(mail.items) do
                    isFind = true
                    table.insert(awards, {id = value.itemId, typeName = value.type, count = value.count})
                end
            end
        end
        if isFind == true then
            table.insert(awardMails, mail.mailId)
        end
    end
    local totalCount = #awardMails
    if totalCount == 0 then 
        app.tip:floatTip("没有奖励可领取！")
        return 
    end
    remote.mails:oneGetmailAward(function ()
        -- for index,mailId in ipairs(awardMails) do
        --     remote.mails:removeMailsForId(mailId, totalCount == index)
        -- end
        local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
            options = {awards = awards}},{isPopCurrentDialog = false} )
        dialog:setTitle("恭喜您获得邮件奖励")
    end)
end
--一键已读
function QUIDialogMail:_onTriggerClearAll(event)
    app.sound:playSound("common_small")
    local mails = remote.mails:getMails()
    local mailIds = {}
    for index,mail in ipairs(mails) do
        local reward = mail.awards or mail.items
        if mail.readed ~= true and not reward then
            table.insert(mailIds, mail.mailId)
        end
    end

    if q.isEmpty(mailIds) then
        app.tip:floatTip("没有邮件需要一键读取")
        return 
    end
    remote.mails:mailRead(nil)--传空 为一键读取
end



function QUIDialogMail:updateRewardTitle(key)
    if key == nil then return "" end
    if key == "silves_arena_season_end" then
        return "恭喜您获得西尔维斯海选赛奖励"
    elseif key == "team_arena_peak_season_end" then
        return "恭喜您获得西尔维斯巅峰赛奖励"
    elseif key == "team_arena_peak_bet" then
        return "恭喜您获得西尔维斯押注奖励"
    elseif string.find(key, "arena") then
        return "恭喜您获得斗魂场奖励"
    elseif key == "tower_of_glory_rank" then
        return "恭喜您获得大魂师赛奖励"
    elseif string.find(key, "tower") then
        return "恭喜您获得杀戮之都奖励"
    elseif string.find(key, "intrusion") then
        return "恭喜您获得要塞入侵奖励"
    end

    return ""
end

function QUIDialogMail:_showMailContent(mail)

    local isRead = mail.readed
    -- nzhang: 策划希望打开新邮件时不要有额外的卡顿，所以我把这段代码放到了QUIDialogMailContent:viewAnimationInHandler()中执行，也就是等画面稳定的那一帧发送消息
    -- if mail.readed == false then
    --     remote.mails:mailRead(mail.mailId)
    --     mail.readed = true
    -- end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMailContent", options = {isRead = isRead, mail = mail}}, {isPopCurrentDialog = false})
end



-- 处理邮箱事件
function QUIDialogMail:_onEvent(event)
	if event == nil or event.name == nil then
        return
    end

    if event.name == remote.mails.MAILS_UPDATE_EVENT then
        self:getData()
        self._listView:reload({totalNumber = #self._data})
        self:checkRedTips()
    elseif event.name == QUIDialogMailContent.MAIL_EVENT_RECV_AWARD then
        self:_recvMailAward(event.mail)
        self:checkRedTips()
    elseif event.name == QUIDialogMailContent.MAIL_EVENT_CLOSE then
        -- if event.isReceive or (event.isRead == false and event.mail.items == nil) then
        --     if remote.mails:checkSystemMails() == false and remote.mails:checkAwardMail(event.mail) == false then
        --         self:viewAnimationOutHandler()
        --     end
        -- end
    end
end

function QUIDialogMail:_onTriggerClick1(e)
    if self._tab == remote.mails.ENUM_ALL then return end
    app.sound:playSound("common_menu")

    self:_selectTab(remote.mails.ENUM_ALL)
end

function QUIDialogMail:_onTriggerClick2(e)
    if self._tab == remote.mails.ENUM_AWARDS then return end
    app.sound:playSound("common_menu")

    self:_selectTab(remote.mails.ENUM_AWARDS)
end

function QUIDialogMail:_onTriggerClick3(e)
    if self._tab == remote.mails.ENUM_NO_AWARDS then return end
    app.sound:playSound("common_menu")
    
    self:_selectTab(remote.mails.ENUM_NO_AWARDS)
end

function QUIDialogMail:_onTriggerClick4(e)
    if self._tab == remote.mails.ENUM_UNION_MAIL then return end
    app.sound:playSound("common_menu")
    
    self:_selectTab(remote.mails.ENUM_UNION_MAIL)
end

function QUIDialogMail:getData(  )
    -- body
    self._data = remote.mails:getMails(self._tab) 
    self._ccbOwner.sp_no:setVisible(#self._data == 0)
end

function QUIDialogMail:_backClickHandler()
    self:_onTriggerClose()
end

-- 关闭对话框
function QUIDialogMail:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_close) == false then return end
    app.sound:playSound("common_close")
    self:playEffectOut()
end

function QUIDialogMail:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_SPECIFIC_CONTROLLER, nil, self)
end

return QUIDialogMail
