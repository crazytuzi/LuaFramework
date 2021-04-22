


local QUIDialog = import(".QUIDialog")
local QUIDialogMockBattleScore = class("QUIDialogMockBattleScore", QUIDialog)
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QScrollContain = import("..QScrollContain")
local QUIViewController = import("..QUIViewController")
local QVIPUtil = import("...utils.QVIPUtil")
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetJifenAward = import("..widgets.QUIWidgetJifenAward")
local QListView = import("...views.QListView")

QUIDialogMockBattleScore.TAB_NORMAL = "TAB_NORMAL"
QUIDialogMockBattleScore.TAB_FIRST = "TAB_FIRST"

function QUIDialogMockBattleScore:ctor(options)

    local ccbFile = "ccb/Dialog_MockBattle_Score.ccbi"

    local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
        {ccbCallbackName = "onTriggerOneGet", callback = handler(self, self._onTriggerOneGet)},
        {ccbCallbackName = "onTriggerNormal", callback = handler(self, self._onTriggerNormal)},
        {ccbCallbackName = "onTriggerFirst", callback = handler(self, self._onTriggerFirst)},
    }
    QUIDialogMockBattleScore.super.ctor(self, ccbFile, callBacks, options)

    self._ccbOwner.frame_tf_title:setString("大师赛积分")

    self._leftX = -340 -- 左側距離邊框線15像素的x座標
    self._bottomY = -240 -- 底部距離邊框線15像素的y座標
    self._s9sBgWidth = 680 -- s9s_bg的寬度（距離兩邊15像素）
    self._selectTab = QUIDialogMockBattleScore.TAB_NORMAL
    self.isShowBtnOneGet = true
    self.score = 0
    self.isVertical = true
    self.enableShadow = true
    self.spaceY = -6
    self._listView = nil
    self._seasonType = remote.mockbattle:getMockBattleSeasonType()
end

function QUIDialogMockBattleScore:viewAnimationInHandler()
    QUIDialogMockBattleScore.super.viewAnimationInHandler(self)
    -- 正式显示列表
    self._lastSheetY = nil
    self:selectTabs()
end

function QUIDialogMockBattleScore:viewDidAppear()
    QUIDialogMockBattleScore.super.viewDidAppear(self)
    self.mockBattleEventProxy = cc.EventProxy.new(remote.mockbattle)
    self.mockBattleEventProxy:addEventListener(remote.mockbattle.EVENT_MOCK_BATTLE_MY_INFO, handler(self, self.selectTabs))
end

function QUIDialogMockBattleScore:viewWillDisappear()
    QUIDialogMockBattleScore.super.viewWillDisappear(self)
    self.mockBattleEventProxy:removeAllEventListeners()
end


function QUIDialogMockBattleScore:resetAll()
    self._ccbOwner.btn_normal:setEnabled(true)
    self._ccbOwner.btn_normal:setHighlighted(false)
    self._ccbOwner.btn_first:setEnabled(true)
    self._ccbOwner.btn_first:setHighlighted(false)
    self._ccbOwner.sp_normal_tips:setVisible(false)
    self._ccbOwner.sp_first_tips:setVisible(false)
    self._ccbOwner.node_btn_oneGet:setVisible(false)
end

function QUIDialogMockBattleScore:selectTabs()
    self:resetAll()
    self.data = {}
    if self._selectTab == QUIDialogMockBattleScore.TAB_NORMAL then
        self._ccbOwner.btn_normal:setEnabled(false)
        self._ccbOwner.btn_normal:setHighlighted(true)
        self:updateNormalData()
        self._ccbOwner.node_btn_oneGet:setVisible(true)
    elseif self._selectTab == QUIDialogMockBattleScore.TAB_FIRST then
        self._ccbOwner.btn_first:setEnabled(false)
        self._ccbOwner.btn_first:setHighlighted(true)
        self:updateFirstData()
    end
end

function QUIDialogMockBattleScore:updateNormalData()
    local configs = {}
    local reward_table = db:getStaticByName("mock_battle_reward")
    local index_ = 1
    for k, value in pairs(reward_table) do
        if value.type == 2 and  self._seasonType == value.season_type then
            value.isGet = remote.mockbattle:checkIntegralRewardInfoIsGet(value.id)
            local item_table = string.split(value.rewards, "^")
            if next(item_table) ~= nil then
                local num = #item_table
                num = num / 2
                for i=1,num do
                    value.awardList = {{id = nil, typeName = item_table[2* i -1], count = tonumber(item_table[2* i])}}
                end
            end
            configs[index_] = value
            configs[index_].widgetTitleStr = "本赛季达到%d积分"
            index_ = index_ +1
        end
    end

    table.sort( configs, function (a,b)
        if a.isGet ~= b.isGet  then
            return a.isGet == false
        end
        return a.id < b.id
    end )

    self.data = configs
    local curScore = remote.mockbattle:getMockBattleUserInfo().totalScore or 0 
    self.score = curScore
    if self._listView then
        self._listView:clear()
    end
    self:initListView()
end

function QUIDialogMockBattleScore:updateFirstData()
    local configs = {}
    local reward_table = db:getStaticByName("mock_battle_reward")
    local index_ = 1
    local top_win_num = remote.mockbattle:getMockBattleUserInfo().topWinCount or 0

    for k, value in pairs(reward_table) do
        if value.type == 3 and  self._seasonType == value.season_type then
            value.isGet = value.condition <= top_win_num
            local item_table = string.split(value.rewards, "^")
            if next(item_table) ~= nil then
                local num = #item_table
                num = num / 2
                for i=1,num do
                    value.awardList = {{id = nil, typeName = item_table[2* i -1], count = tonumber(item_table[2* i])}}
                end
            end
            configs[index_] = value
            configs[index_].widgetTitleStr = "本赛季单轮达到%d胜"
            index_ = index_ +1
        end
    end

    table.sort( configs, function (a,b)
        if a.isGet ~= b.isGet  then
            return a.isGet == false
        end
        return a.id < b.id
    end )

    self.data = configs

    self.score = top_win_num
    if self._listView then
        self._listView:clear()
    end
    self:initListView()
end


function QUIDialogMockBattleScore:initListView()
    if self._isResetListView and self._listView ~= nil then
        self._listView:clear()
        self._listView = nil
    end

    self._listViewCfg = {
            renderItemCallBack = handler(self, self.renderItemCallBack),
            isVertical = self.isVertical,
            enableShadow = self.enableShadow,
            spaceY = self.spaceY,
            totalNumber = #self.data
        }
    if self._listView == nil then
        self._listView = QListView.new(self._ccbOwner.sheet_layout, self._listViewCfg)
    else
        self._listView:reload({totalNumber = #self.data})
    end
end



function QUIDialogMockBattleScore:renderItemCallBack(list, index, info)
    local isCacheNode = true
    local data = self.data[index]
    local item = list:getItemFromCache()
    if not item then            
        item = QUIWidgetJifenAward.new()
        item:addEventListener(QUIWidgetJifenAward.EVENT_CLICK, handler(self, self.cellClickHandler))
        isCacheNode = false
    end
    item:setInfo(data, self.score)
    info.item = item
    info.size = item:getContentSize()

    list:registerTouchHandler(index, "onTouchListView")
    list:registerBtnHandler(index, "btn_award", "_onTriggerClickAwards", nil, true)

    return isCacheNode
end


-- function QUIDialogMockBattleScore:updateView()
--     -- 根據常見情況，自適應排版界面

--     if not self._lastSheetY or self._lastSheetY ~= self._ccbOwner.sheet:getPositionY() then
--         self._isResetListView = true
--         self._lastSheetY = self._ccbOwner.sheet:getPositionY()
--     end

--     self._ccbOwner.sheet_layout:setAnchorPoint(ccp(0, 1))
--     self._ccbOwner.sheet_layout:setPosition(ccp(0, 0))

--     self._ccbOwner.s9s_bg:setAnchorPoint(ccp(0.5, 1))
--     self._ccbOwner.s9s_bg:setPosition(ccp(0, self._ccbOwner.sheet:getPositionY()))

--     self._ccbOwner.screen_bottom:setAnchorPoint(ccp(0.5, 1))
--     self._ccbOwner.screen_bottom:setPreferredSize(CCSize(self._s9sBgWidth, 300))
--     self._ccbOwner.screen_top:setAnchorPoint(ccp(0.5, 0))
--     self._ccbOwner.screen_top:setPreferredSize(CCSize(self._s9sBgWidth, 300))
--     self._ccbOwner.screen_top:setPosition(ccp(0, self._ccbOwner.sheet:getPositionY()))

--     if self.isShowBtnOneGet then
--         self._ccbOwner.node_btn_oneGet:setVisible(true)
--         local btnH = self._ccbOwner.btn_oneGet:getContentSize().height
--         self._ccbOwner.node_btn_oneGet:setPosition(ccp(0, self._bottomY + btnH/2))

--         self._ccbOwner.s9s_bg:setPreferredSize(CCSize(self._s9sBgWidth, self._ccbOwner.s9s_bg:getPositionY() - (self._bottomY + btnH + 10)))
--         self._ccbOwner.screen_bottom:setPosition(ccp(0, self._bottomY + btnH + 10))
--     else
--         self._ccbOwner.node_btn_oneGet:setVisible(false)
--         self._ccbOwner.s9s_bg:setPreferredSize(CCSize(self._s9sBgWidth, self._ccbOwner.s9s_bg:getPositionY() - self._bottomY))
--         self._ccbOwner.screen_bottom:setPosition(ccp(0, self._bottomY))
--     end
--     self._ccbOwner.sheet_layout:setContentSize(CCSize(self._ccbOwner.s9s_bg:getContentSize()))
-- end


----------------------------------------------------------------------------------------




function QUIDialogMockBattleScore:_onTriggerNormal(event)
    if self._selectTab == QUIDialogMockBattleScore.TAB_NORMAL then return end
    app.sound:playSound("common_switch")
    self._selectTab = QUIDialogMockBattleScore.TAB_NORMAL
    self:selectTabs()
end

function QUIDialogMockBattleScore:_onTriggerFirst(event)
    if self._selectTab == QUIDialogMockBattleScore.TAB_FIRST then return end
    app.sound:playSound("common_switch")
    self._selectTab = QUIDialogMockBattleScore.TAB_FIRST
    self:selectTabs()
end


function QUIDialogMockBattleScore:cellClickCallback(event)
    local info = event.info
    local awards = event.awards
    remote.mockbattle:mockBattleIntegralRewardRequest({info.id}, function (data)
        app.tip:awardsTip(awards,"恭喜您获得积分奖励")
    end)
end

--一键领取
function QUIDialogMockBattleScore:onGetCallBack(event)
    local configs = db:getStaticByName("mock_battle_reward")
    local score = remote.mockbattle:getMockBattleUserInfo().totalScore or 0 
    local ids = {}

    for _,value in pairs(configs) do
        if remote.mockbattle:checkIntegralRewardInfoIsGet(value.id) == false and score >= value.condition and value.type == 2 and  self._seasonType == value.season_type   then 
            table.insert(ids, value.id)          
        end
    end
    if #ids == 0 then
        app.tip:floatTip("没有可领取的奖励")
        return
    end
    remote.mockbattle:mockBattleIntegralRewardRequest(ids, function (data)
        local awards = {}
        for _,value in ipairs(data.prizes) do
            table.insert(awards, {id = value.id, typeName = value.type, count = value.count})
        end
        app:alertAwards({awards = awards, title = "恭喜您获得积分奖励"})
    end,function ()
    end)
end

function QUIDialogMockBattleScore:cellClickHandler(event)
    self:cellClickCallback(event)
end

function QUIDialogMockBattleScore:_onTriggerOneGet(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_oneGet) == false then return end
    app.sound:playSound("common_small")
    self:onGetCallBack()
end

function QUIDialogMockBattleScore:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogMockBattleScore:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_close) == false then return end
    app.sound:playSound("common_close")
    self:playEffectOut()
end

function QUIDialogMockBattleScore:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end


return QUIDialogMockBattleScore