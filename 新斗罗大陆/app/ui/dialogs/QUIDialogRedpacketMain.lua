--
-- Author: Kumo.Wang
-- 宗门红包主场景
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogRedpacketMain = class("QUIDialogRedpacketMain", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QListView = import("...views.QListView")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QActorProp = import("...models.QActorProp")
local QRichText = import("...utils.QRichText")

local QUIWidgetRedpacketCell = import("..widgets.QUIWidgetRedpacketCell")
local QUIWidgetRedpacketAchievementCell = import("..widgets.QUIWidgetRedpacketAchievementCell")

function QUIDialogRedpacketMain:ctor(options)
	local ccbFile = "ccb/Dialog_Society_Redpacket_Main.ccbi"
	local callBack = {
        {ccbCallbackName = "onTriggerGain", callback = handler(self, self._onTriggerGain)},
        {ccbCallbackName = "onTriggerSend", callback = handler(self, self._onTriggerSend)},
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
        {ccbCallbackName = "onTriggerRule", callback = handler(self, self._onTriggerRule)},
        {ccbCallbackName = "onTriggerAchievement", callback = handler(self, self._onTriggerAchievement)},
        {ccbCallbackName = "onTriggerAchieveItem", callback = handler(self, self._onTriggerAchieveItem)},
        {ccbCallbackName = "onTriggerAchieveToken", callback = handler(self, self._onTriggerAchieveToken)},
        {ccbCallbackName = "onTriggerActivate", callback = handler(self, self._onTriggerActivate)},
	}
	QUIDialogRedpacketMain.super.ctor(self, ccbFile, callBack, options)
    -- local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    -- page:setAllUIVisible(false)
    -- page:setScalingVisible(false)

    ui.tabButton(self._ccbOwner.btn_gain, "领赏")
    ui.tabButton(self._ccbOwner.btn_send, "打赏")
    ui.tabButton(self._ccbOwner.btn_achievement, "成就")
    local tabs = {}
    table.insert(tabs, self._ccbOwner.btn_gain)
    table.insert(tabs, self._ccbOwner.btn_send)
    table.insert(tabs, self._ccbOwner.btn_achievement)
    self._tabManager = ui.tabManager(tabs)

    q.setButtonEnableShadow(self._ccbOwner.btn_achieveActivate)
    q.setButtonEnableShadow(self._ccbOwner.btn_rule)

    self._selectedTab = options and options.selectedTab or remote.redpacket.GAIN
    self._selectedAchieveTab = options and options.selectedAchieveTab or remote.redpacket.ITEM_REDPACKET
    self._redpacketData = {}
    self._isListCanNotTouchMove = false 
end

function QUIDialogRedpacketMain:viewDidAppear()
	QUIDialogRedpacketMain.super.viewDidAppear(self)

    self._redpacketProxy = cc.EventProxy.new(remote.redpacket)
    self._redpacketProxy:addEventListener(remote.redpacket.NEW_DAY, handler(self, self._updateUI))
    self._redpacketProxy:addEventListener(remote.redpacket.UPDATE_REDPACKET, handler(self, self._updateRedTips))


    if self:getOptions().selectedTab and self:getOptions().selectedTab ~= self._selectedTab then
        self._selectedTab = self:getOptions().selectedTab
    end
    if self:getOptions().selectedAchieveTab and self:getOptions().selectedAchieveTab ~= self._selectedAchieveTab then
        self._selectedAchieveTab = self:getOptions().selectedAchieveTab
    end
    self:_selectTab(self._selectedTab, self._selectedAchieveTab)

    if self:getOptions().lastSendConfig then
        self:_showEffect( self:getOptions().lastSendConfig )
        self:getOptions().lastSendConfig = nil
    end
end

function QUIDialogRedpacketMain:viewWillDisappear()
	QUIDialogRedpacketMain.super.viewWillDisappear(self)

    self._redpacketProxy:removeAllEventListeners()
    remote.redpacket.showAchievementConfigId = 0
end

-- 选择tab
function QUIDialogRedpacketMain:_selectTab(tab, achieveTab, isSound)
    if isSound == true then
        app.sound:playSound("common_switch")
    end

    if tab then
        self:getOptions().selectedTab = tab
        self._selectedTab = tab
    end

    if achieveTab then
        self:getOptions().selectedAchieveTab = achieveTab
        self._selectedAchieveTab = achieveTab
    end

    remote.redpacket.showAchievementConfigId = remote.redpacket:getRedpacketCurAchievementConfigIdByTab(self._selectedAchieveTab)

    self:setButtonState()
    self:_updateUI()
    self:_updateData()
    self:_updateRedTips()
end

function QUIDialogRedpacketMain:setButtonState()
    self._ccbOwner.ccb_btn_effect:setVisible(false)

    if self._selectedTab == remote.redpacket.GAIN then
        self._tabManager:selected(self._ccbOwner.btn_gain)
    elseif self._selectedTab == remote.redpacket.SEND then
        self._tabManager:selected(self._ccbOwner.btn_send)
    elseif self._selectedTab == remote.redpacket.ACHIEVEMENT then
        self._tabManager:selected(self._ccbOwner.btn_achievement)

        local tabAchieveItem = self._selectedAchieveTab == remote.redpacket.ITEM_REDPACKET
        self._ccbOwner.btn_achieveItem:setHighlighted(tabAchieveItem)
        self._ccbOwner.btn_achieveItem:setEnabled(not tabAchieveItem)

        local tabAchieveToken = self._selectedAchieveTab == remote.redpacket.TOKEN_REDPACKET
        self._ccbOwner.btn_achieveToken:setHighlighted(tabAchieveToken)
        self._ccbOwner.btn_achieveToken:setEnabled(not tabAchieveToken)

        if remote.user.userConsortia then
            local id = remote.redpacket:getRedpacketCurAchievementConfigIdByTab(self._selectedAchieveTab)
            local maxId = 0
            if self._selectedAchieveTab == remote.redpacket.ITEM_REDPACKET then
                maxId = remote.redpacket.unionRedpacketAchievementMaxItemId
            elseif self._selectedAchieveTab == remote.redpacket.TOKEN_REDPACKET then
                maxId = remote.redpacket.unionRedpacketAchievementMaxTokenId
            end
            if id > maxId then
                self._ccbOwner.node_achieveActivate_btn:setVisible(false)
            elseif id == maxId then
                if remote.redpacket:checkAchieveDoneByTypeAndId(self._selectedAchieveTab, id) then
                    self._ccbOwner.node_achieveActivate_btn:setVisible(false)
                else
                    self._ccbOwner.node_achieveActivate_btn:setVisible(true)
                end
            else
                self._ccbOwner.node_achieveActivate_btn:setVisible(true)
            end

            if self._ccbOwner.node_achieveActivate_btn:isVisible() then
                local config = remote.redpacket:getRedpacketAchieveConfigById(id)
                local count = remote.redpacket:getAchieveSendCountByType(self._selectedAchieveTab)
                if count < tonumber(config.condition) then
                    makeNodeFromNormalToGray(self._ccbOwner.btn_achieveActivate)
                    self._ccbOwner.btn_achieveActivate:setEnabled(false)
                    self._ccbOwner.tf_btn_achieveActivate:disableOutline()
                else
                    makeNodeFromGrayToNormal(self._ccbOwner.btn_achieveActivate)
                    self._ccbOwner.btn_achieveActivate:setEnabled(true)
                    self._ccbOwner.ccb_btn_effect:setVisible(true)
                    self._ccbOwner.tf_btn_achieveActivate:enableOutline(true)
                end
            end
        else
            self._ccbOwner.node_achieveActivate_btn:setVisible(false)
        end
    end
end

function QUIDialogRedpacketMain:_updateUI()
    local tbl = {}

    if self._selectedTab == remote.redpacket.GAIN then
        self._ccbOwner.node_title:setVisible(true)
        self._ccbOwner.tf_title:setString("选择你要领取的福袋")
        self._ccbOwner.node_achievement:setVisible(false)
        local maxCount = remote.redpacket:getMaxGainCount()
        local curCount = maxCount - remote.redpacket:getCurGainCount()
        -- self._ccbOwner.tf_limitInfoTitle:setString("今日剩余可抢钻石福袋数量："..curCount.."/"..maxCount)
        -- self._ccbOwner.tf_limitInfoValue:setString("（活动福袋，宗门福袋不受限）")
        if not q.isEmpty(remote.user.userConsortia)  and not q.isEmpty(remote.union.consortia) 
            and remote.user.userConsortia.consortiaId and remote.user.userConsortia.consortiaId ~= "" 
            and tonumber(remote.union.consortia.level) >= 6 then

            local unionWarsMaxCount = remote.redpacket:getMaxGainCountForUnionWars()
            local curUnionWarCount = unionWarsMaxCount - remote.redpacket:getCurGainCountForUnionWars()
            table.insert(tbl, {oType = "font", content = "今日剩余可抢钻石福袋数量: "..curCount.."/"..maxCount.."，宗门福袋数量: "..curUnionWarCount.."/"..unionWarsMaxCount, size = 22, color = COLORS.k})
        else
            table.insert(tbl, {oType = "font", content = "今日剩余可抢钻石福袋数量: "..curCount.."/"..maxCount, size = 22, color = COLORS.k})
        end
        table.insert(tbl, {oType = "font", content = "（活动福袋不受限）", size = 22, color = COLORS.m})
    elseif self._selectedTab == remote.redpacket.SEND then
        self._ccbOwner.node_title:setVisible(true)
        self._ccbOwner.tf_title:setString("选择发放福袋类型")
        self._ccbOwner.node_achievement:setVisible(false)
        local maxCount = remote.redpacket:getMaxSendCount()
        local curCount = maxCount - remote.redpacket:getCurSendCount()
        -- self._ccbOwner.tf_limitInfoTitle:setString("今日剩余可发钻石福袋数量："..curCount.."/"..maxCount)
        -- self._ccbOwner.tf_limitInfoValue:setString("（活动福袋，宗门福袋不受限）")
        table.insert(tbl, {oType = "font", content = "今日剩余可发钻石福袋数量："..curCount.."/"..maxCount, size = 22, color = COLORS.k})
        table.insert(tbl, {oType = "font", content = "（活动福袋，宗门福袋不受限）", size = 22, color = COLORS.m})
    elseif self._selectedTab == remote.redpacket.ACHIEVEMENT then
        self._ccbOwner.node_title:setVisible(false)
        self._ccbOwner.node_achievement:setVisible(true)
        -- 头像
        -- self._ccbOwner.node_heroHead:removeAllChildren()
        -- local head = QUIWidgetAvatar.new(remote.user.avatar)
        -- self._ccbOwner.node_heroHead:addChild(head)
        -- 属性
        self:_showAchieveProp() 
        -- 当前额度
        local count = remote.redpacket:getAchieveSendCountByType(self._selectedAchieveTab)
        local num, unit = q.convertLargerNumber(count)
        -- self._ccbOwner.tf_now:setString("(当前额度"..num..(unit or "")..")")
        table.insert(tbl, {oType = "font", content = "发放对应福袋额度达到对应值可获得稀有称号", size = 22, color = COLORS.k})
        table.insert(tbl, {oType = "font", content = "(当前额度"..num..(unit or "")..")", size = 22, color = COLORS.m})
    end

    self._ccbOwner.node_tips_rt:removeAllChildren()
    local richTextNode = QRichText.new(nil, 750)
    richTextNode:setString(tbl)
    richTextNode:setAnchorPoint(ccp(0, 0.5))
    self._ccbOwner.node_tips_rt:addChild(richTextNode)
end

function QUIDialogRedpacketMain:_showAchieveProp()
    local achievePropDic = remote.redpacket:getAchieveDoneAchievementProps(self._selectedAchieveTab)
    local keyList = remote.redpacket.unionRedpacketAchievePropKeyDic[self._selectedAchieveTab]
    local tbl = {}
    for index, key in ipairs(keyList) do
        if achievePropDic[key] then
            local numStr = achievePropDic[key].num
            if achievePropDic[key].isPercent then
                numStr = (achievePropDic[key].num * 100).."%"
            end
            table.insert(tbl, {oType = "font", content = achievePropDic[key].name.."：", size = 18, color = COLORS.a})
            table.insert(tbl, {oType = "font", content = "+"..numStr.."  ", size = 18, color = COLORS.c})
        else
            table.insert(tbl, {oType = "font", content = (QActorProp._field[key].uiName or QActorProp._field[key].name).."：", size = 18, color = COLORS.a})
            table.insert(tbl, {oType = "font", content = "+0".."  ", size = 18, color = COLORS.c})
        end
    end

    self._ccbOwner.node_prop_rt:removeAllChildren()
    local richTextNode = QRichText.new(nil, 750)
    richTextNode:setString(tbl)
    richTextNode:setAnchorPoint(ccp(0, 1))
    self._ccbOwner.node_prop_rt:addChild(richTextNode)
end

function QUIDialogRedpacketMain:_updateData()
    if self._listView then
        self._listView:clear()
        self._listView:unscheduleUpdate()
        self._listView = nil
    end
    self._isListCanNotTouchMove = false
    if self._selectedTab == remote.redpacket.GAIN then
        remote.redpacket:unionRedpacketListRequest(self:safeHandler(function()
                self._redpacketData = clone(remote.redpacket.unionRedpacketList)
                while #self._redpacketData < 4 do
                    self._isListCanNotTouchMove = true
                    table.insert(self._redpacketData, {})
                end
                self:_initListView()
            end))
    elseif self._selectedTab == remote.redpacket.SEND then
        self._redpacketData =  remote.redpacket:getSendTabData()
        self:_initListView()
    elseif self._selectedTab == remote.redpacket.ACHIEVEMENT then
        self._redpacketData =  remote.redpacket:getAchieveTabDataByType(self._selectedAchieveTab)
        self:_initListView()
    end
end

function QUIDialogRedpacketMain:_initListView()
    local _ignoreCanDrag = true
    local _autoCenter = false
    local _spaceX = 30
    if self._selectedTab == remote.redpacket.SEND then
        _ignoreCanDrag = false
        _autoCenter = true
        _spaceX = 58
    elseif self._selectedTab == remote.redpacket.ACHIEVEMENT then
        _spaceX = 0
    end
    local _pos = 0
    if self._selectedTab == remote.redpacket.ACHIEVEMENT then
        local configId = tonumber(remote.redpacket.showAchievementConfigId)
        for i, config in ipairs(self._redpacketData) do
            if config.id == configId then
                _pos = i
                break
            end
        end
    end
    if not self._listView then
        local cfg = {
            renderItemCallBack = function( list, index, info )
                local isCacheNode = true
                local itemData = self._redpacketData[index]
                -- QPrintTable(itemData)
                local item = list:getItemFromCache()
                if not item then
                    if self._selectedTab == remote.redpacket.ACHIEVEMENT then
                        item = QUIWidgetRedpacketAchievementCell.new()
                    else
                        item = QUIWidgetRedpacketCell.new()
                        item:addEventListener(QUIWidgetRedpacketCell.OPEN_EFFECT_START, handler(self, self._fcaOpenEffectHandler))
                        item:addEventListener(QUIWidgetRedpacketCell.OPEN_EFFECT_END, handler(self, self._fcaOpenEffectHandler))
                    end
                    isCacheNode = false
                end
                if self._selectedTab == remote.redpacket.ACHIEVEMENT then
                    item:setInfo({itemData = itemData, selectedAchieveTab = self._selectedAchieveTab})
                else
                    item:setInfo({itemData = itemData, selectedTab = self._selectedTab})
                end
                info.item = item
                info.size = item:getContentSize()
                -- if self._selectedTab == remote.redpacket.ACHIEVEMENT then
                --     if index%2 == 0 then
                --         info.offsetPos = ccp(0, -230)
                --     else
                --         info.offsetPos = ccp(0, -90)
                --     end
                -- end

                if self._selectedTab == remote.redpacket.ACHIEVEMENT then
                    list:registerBtnHandler(index, "btn_click", handler(self, self._clickRedpacketAchievementCellHandler))
                else
                    list:registerBtnHandler(index, "btn_click", handler(self, self._clickRedpacketCellHandler))
                end
                
                return isCacheNode
            end,
            headIndex = _pos,
            curOriginOffset = 0,
            spaceX = _spaceX,
            spaceY = 0,
            isVertical = false,
            multiItems = 1,
            enableShadow = false,
            curOffset = 0,
            ignoreCanDrag = _ignoreCanDrag,
            autoCenter = _autoCenter,
            -- topShadow = self._ccbOwner.sp_topShadow,
            -- bottomShadow = self._ccbOwner.sp_bottomShadow,
            totalNumber = #self._redpacketData,
        }
        self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
    else
        self._listView:reload({totalNumber = #self._redpacketData})
    end
    -- print(" self._isListCanNotTouchMove = ", self._isListCanNotTouchMove)
    self._listView:setCanNotTouchMove(self._isListCanNotTouchMove)

    -- dldl-29454 去掉滑动的效果
    -- self:_startScrollByConfigId()
end

function QUIDialogRedpacketMain:_startScrollByConfigId( configId )
    if self._selectedTab == remote.redpacket.ACHIEVEMENT then
        local curIndex = self._listView:getCurTouchIndex()
        print("curIndex = ", curIndex)
        if curIndex == nil then
            local configId = tonumber(configId or remote.redpacket.showAchievementConfigId)
            local pos = 0
            -- QPrintTable(self._redpacketData)
            for i, config in ipairs(self._redpacketData) do
                if config.id == configId then
                    pos = i
                    break
                end
            end
            -- print("QUIDialogRedpacketMain:_startScrollById() configId = ", configId, pos, remote.redpacket.showAchievementConfigId)
            if pos > 0 then
                self._listView:startScrollToIndex(pos, false, 100)
            end
        end
    end
end

function QUIDialogRedpacketMain:_updateRedTips()
    self._ccbOwner.sp_send_tips:setVisible(remote.redpacket:checkRedpacketSendRedTip())
    self._ccbOwner.sp_achievement_tips:setVisible(remote.redpacket:checkRedpacketAchievementRedTip())
    self._ccbOwner.sp_gain_tips:setVisible(remote.redpacket:checkRedpacketGainRedTip())
    self._ccbOwner.sp_achieveItem_tips:setVisible(remote.redpacket:checkRedpacketAchievementItemRedTip())
    self._ccbOwner.sp_achieveToken_tips:setVisible(remote.redpacket:checkRedpacketAchievementTokenRedTip())
end

function QUIDialogRedpacketMain:_fcaOpenEffectHandler(event)
    if event.name == QUIWidgetRedpacketCell.OPEN_EFFECT_START then
        self._tmpRewardData = nil
        self._tmpOpenEffectEnd = nil
        remote.redpacket:unionRedpacketOpenRequest(event.param.itemData.redpacketId, self:safeHandler(function(response)
                if response and response.error == "NO_ERROR" then
                    self._tmpRewardData = response.redpacketList.consortiaRedpacket[1]
                    for _, log in ipairs(self._tmpRewardData.receiveDetailLogList or {}) do
                        if log.userId == remote.user.userId then
                            local num = log.item_num or 0
                            remote.activity:updateLocalDataByType(704, num)
                        end
                    end
                    if self._tmpOpenEffectEnd then
                        app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogRedpacketGain", options = {data = self._tmpRewardData}})
                        self:_updateUI()
                        self._tmpRewardData = nil
                        self._tmpOpenEffectEnd = nil
                    end
                end
            end), self:safeHandler(function()
                self:_selectTab(remote.redpacket.GAIN)
                self._tmpRewardData = nil
                self._tmpOpenEffectEnd = nil
            end))
    elseif event.name == QUIWidgetRedpacketCell.OPEN_EFFECT_END then
        if self._tmpRewardData then
            app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogRedpacketGain", options = {data = self._tmpRewardData}})
            self:_updateUI()
            self._tmpRewardData = nil
            self._tmpRefreshData = nil
            self._tmpOpenEffectEnd = nil
        else
            self._tmpOpenEffectEnd = true
        end
    end
end

function QUIDialogRedpacketMain:_clickRedpacketAchievementCellHandler( x, y, touchNode, listView )
    app.sound:playSound("common_others")
    local touchIndex = listView:getCurTouchIndex()
    local selectData = self._redpacketData[touchIndex]
    app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass="QUIDialogRedpacketAchievementInfo", options = {config = selectData}})
end

function QUIDialogRedpacketMain:_clickRedpacketCellHandler( x, y, touchNode, listView )
    app.sound:playSound("common_others")
    local touchIndex = listView:getCurTouchIndex()
    local selectData = self._redpacketData[touchIndex]
    -- QPrintTable(selectData)
    if self._selectedTab == remote.redpacket.GAIN then
        local redpacketData = remote.redpacket:getUnionRedpacketListByRedpacketId(selectData.redpacketId)
        if next(redpacketData) then
            if redpacketData.isOpened then
                -- app.tip:floatTip("已领过")
                app:getNavigationManager():pushViewController(app.topLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogRedpacketRecord", options = {data = redpacketData}})
                return
            end
            if redpacketData.redpacketNum == 0 then
                -- app.tip:floatTip("已领完")
                app:getNavigationManager():pushViewController(app.topLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogRedpacketRecord", options = {data = redpacketData}})
                return
            end
            local isOvertime = remote.redpacket:updateTime(redpacketData.offAt)
            if isOvertime then
                -- app.tip:floatTip("已过期")
                app:getNavigationManager():pushViewController(app.topLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogRedpacketRecord", options = {data = redpacketData}})
                return
            end
            
            local config = remote.redpacket:getRedpacketConfigById(selectData.id)
            if config and config.type == remote.redpacket.TOKEN_REDPACKET then
                local maxCount = remote.redpacket:getMaxGainCount()
                local curCount = maxCount - remote.redpacket:getCurGainCount()
                if curCount < 1 then
                    app.tip:floatTip("领奖次数不足")
                    return
                end
            end

            local item = listView:getItemByIndex(touchIndex)
            item:showOpenEffect()
        end
    elseif self._selectedTab == remote.redpacket.SEND then
        -- if selectData == remote.redpacket.TOKEN_REDPACKET then
            app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogRedpacketSend", 
                options = {redpacketType = selectData, superOptions = self:getOptions()}})
        -- elseif selectData == remote.redpacket.ITEM_REDPACKET then
            -- app.tip:floatTip("敬请期待")
        -- end
    end
end

function QUIDialogRedpacketMain:_showEffect( config )
    local path = remote.redpacket:getSendEffectPath()
    local effect = QUIWidgetAnimationPlayer.new()
    self:getView():addChild(effect)
    effect:playAnimation(path, function(ccbOwner)
            if config then
                local index = 1
                if config.consortia_money then
                    ccbOwner["tf_title_"..index]:setString("宗门贡献")
                    ccbOwner["tf_value_"..index]:setString("+"..config.consortia_money)
                    index = index + 1
                end
                if config.consortia_exp then
                    ccbOwner["tf_title_"..index]:setString("宗门经验")
                    ccbOwner["tf_value_"..index]:setString("+"..config.consortia_exp)
                    index = index + 1
                end
                while true do
                    local tfTitle = ccbOwner["tf_title_"..index]
                    local tfValue = ccbOwner["tf_value_"..index]
                    if tfTitle then
                        tfTitle:setVisible(false)
                    end
                    if tfValue then
                        tfValue:setVisible(false)
                    end
                    if not tfTitle and not tfValue then
                        break
                    end
                    index = index + 1
                end
            end
        end, function()
            effect:removeFromParent()
            -- effect:release()
            effect = nil
        end)
end

function QUIDialogRedpacketMain:_onTriggerGain()
    if self._selectedTab == remote.redpacket.GAIN then return end
    self:_selectTab(remote.redpacket.GAIN, nil, true)
end

function QUIDialogRedpacketMain:_onTriggerSend()
    if self._selectedTab == remote.redpacket.SEND then return end
    self:_selectTab(remote.redpacket.SEND, nil, true)
end

function QUIDialogRedpacketMain:_onTriggerAchievement()
    if self._selectedTab == remote.redpacket.ACHIEVEMENT then return end
    self:_selectTab(remote.redpacket.ACHIEVEMENT, nil, true)
end

function QUIDialogRedpacketMain:_onTriggerAchieveItem()
    if self._selectedAchieveTab == remote.redpacket.ITEM_REDPACKET then return end
    self:_selectTab(nil, remote.redpacket.ITEM_REDPACKET, true)
end

function QUIDialogRedpacketMain:_onTriggerAchieveToken()
    if self._selectedAchieveTab == remote.redpacket.TOKEN_REDPACKET then return end
    self:_selectTab(nil, remote.redpacket.TOKEN_REDPACKET, true)
end

function QUIDialogRedpacketMain:_onTriggerActivate()
    app.sound:playSound("common_small")
    local id = remote.redpacket:getRedpacketCurAchievementConfigIdByTab(self._selectedAchieveTab)
    if id > 0 then
        local config = remote.redpacket:getRedpacketAchieveConfigById(id)
        local count = remote.redpacket:getAchieveSendCountByType(self._selectedAchieveTab)
        if count < tonumber(config.condition) then
            return
        end

        remote.redpacket:unionRedpacketGetTaskRewardRequest(config.type, id, self:safeHandler(function()
                if config.lucky_draw then
                    app:getNavigationManager():pushViewController(app.topLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogRedpacketAchievementReward", options = {config = config}})
                elseif config.head_default then
                    app:getNavigationManager():pushViewController(app.topLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogRedpacketAchievementRewardTitle", options = {config = config}})
                end
                self:_selectTab()
            end))
    end
end

function QUIDialogRedpacketMain:_onTriggerClose(e)
    if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
    app.sound:playSound("common_small")
    self:_onClose()
end

function QUIDialogRedpacketMain:onTriggerBackHandler()
    self:_onClose()
end

function QUIDialogRedpacketMain:_onTriggerRule()
    app.sound:playSound("common_small")
    -- 点击查看帮助
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogRedpacketRule"})
end

function QUIDialogRedpacketMain:_onClose()
	self:popSelf()
end

function QUIDialogRedpacketMain:_onTriggerBack()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogRedpacketMain:_onTriggerHome()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogRedpacketMain