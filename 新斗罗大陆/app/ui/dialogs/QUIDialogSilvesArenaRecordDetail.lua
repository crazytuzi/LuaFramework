--
-- dsl
-- 希尔维斯战斗详细
-- 2020-06-03

local QUIDialog = import(".QUIDialog")
local QUIDialogSilvesArenaRecordDetail = class("QUIDialogSilvesArenaRecordDetail", QUIDialog)

local QListView = import("...views.QListView")
local QReplayUtil = import("...utils.QReplayUtil")
local QUIViewController = import("..QUIViewController")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")

local QUIWidgetFightEndDetailClient = import("..widgets.QUIWidgetFightEndDetailClient")

QUIDialogSilvesArenaRecordDetail.EVENT_CLICK_SHARED = "EVENT_CLICK_SHARED"

function QUIDialogSilvesArenaRecordDetail:ctor(options)
    local ccbFile = "ccb/Dialog_SilvesRecord_detail.ccbi"
    local callBack = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
        {ccbCallbackName = "onTriggerShare", callback = handler(self, self._onTriggerShare)},
    }
    QUIDialogSilvesArenaRecordDetail.super.ctor(self, ccbFile, callBack, options)
    self.isAnimation = true

    self._ccbOwner.frame_node_center_top:setVisible(true)
    self._ccbOwner.frame_tf_title:setString("战报详情")

    self._info = options.info
    self._isFight = options.isFight
    self._showShare = options.showShare

    if self._showShare == nil then
        self._showShare = true
    end

     self._data = {}

    self:_initInfo()
    self:_initData()

    self._ccbOwner.node_share:setVisible(self._showShare)
end

function QUIDialogSilvesArenaRecordDetail:_initInfo()
    if q.isEmpty(self._info) or #self._info < 3 then
        self:_onTriggerClose()
        return
    end

    local attackScore = 0
    local defenseScore = 0

    for index, value in ipairs(self._info or {}) do
        if value and value.replayInfo then
            if value.success then
                attackScore = attackScore + 1
            else
                defenseScore = defenseScore + 1
            end
        end
    end

    for i = 1, remote.silvesArena.MAX_TEAM_MEMBER_COUNT, 1 do
        local isFindName1 = false
        local isFindName2 = false
        local myNode = self._ccbOwner["node_my_head"..i]
        if myNode then
            myNode:removeAllChildren()
            if self._info[i] and self._info[i].fighter1 and self._info[i].fighter1.avatar then
                local head = QUIWidgetAvatar.new(self._info[i].fighter1.avatar)
                head:setSilvesArenaPeak(self._info[i].fighter1.championCount)
                myNode:addChild(head)
            end
        end

        local otherNode = self._ccbOwner["node_fight_head"..i]
        if otherNode then
            otherNode:removeAllChildren()
            if self._info[i] and self._info[i].fighter2 and self._info[i].fighter2.avatar then
                local head = QUIWidgetAvatar.new(self._info[i].fighter2.avatar)
                head:setSilvesArenaPeak(self._info[i].fighter2.championCount)
                otherNode:addChild(head)
            end
        end
        if not isFindName1 and self._info[i] and self._info[i].team1Name then
            isFindName1 = true
            self._ccbOwner.tf_name1:setString(self._info[i].team1Name)
        end
        if not isFindName2 and self._info[i] and self._info[i].team2Name then
            isFindName2 = true
            self._ccbOwner.tf_name2:setString(self._info[i].team2Name)
        end
    end

    self._ccbOwner.sp_score1:setDisplayFrame(QSpriteFrameByKey("zhanbao_score", attackScore + 1))
    self._ccbOwner.sp_score2:setDisplayFrame(QSpriteFrameByKey("zhanbao_score", defenseScore + 1))
    
    if self._info.fightAt then
        local timeStr = self:_getTimeDescription(self._info.fightAt or 0)
        self._ccbOwner.tf_time:setString(timeStr)
        self._ccbOwner.tf_time:setVisible(true)
    else
        self._ccbOwner.tf_time:setVisible(false)
    end
end

function QUIDialogSilvesArenaRecordDetail:_getTimeDescription(time)
    local gap = (q.serverTime()*1000 - time)/1000
    if gap > 0 then
        if gap < HOUR then
            return math.floor(gap/MIN) .. "分钟前"
        elseif gap < DAY then
            return math.floor(gap/HOUR) .. "小时前"
        elseif gap < WEEK then
            return math.floor(gap/DAY) .. "天前"
        else
            return "7天前"
        end
    end
    return "7天前"
end

function QUIDialogSilvesArenaRecordDetail:_initData()
    for i, value in ipairs(self._info) do
        if value.replayInfo ~= nil then
            local info = {}
            info.index = i
            info.strSplit = "第%s队"
            info.isWin = value.success

            info.heroSilvesArenaForce = value.fighter1.force

            info.heroFighter = value.replayInfo.fighter1
            info.heroSubFighter = value.replayInfo.sub1Fighter1   -- 援助1
            info.heroSubFighter2 = value.replayInfo.sub2Fighter1  
            info.heroSubFighter3 = value.replayInfo.sub3Fighter1

            info.enemySilvesArenaForce = value.fighter2.force

            info.enemyFighter = value.replayInfo.fighter2
            info.enemySubFighter = value.replayInfo.sub1Fighter2
            info.enemySubFighter2 = value.replayInfo.sub2Fighter2
            info.enemySubFighter3 = value.replayInfo.sub3Fighter2

            info.teamHeroSkillIndex = value.replayInfo.team1HeroSkillIndex
            info.teamHeroSkillIndex2 = value.replayInfo.team1HeroSkillIndex2
            info.teamHeroSkillIndex3 = value.replayInfo.team1HeroSkillIndex3

            info.teamEnemySkillIndex = value.replayInfo.team1EnemySkillIndex
            info.teamEnemySkillIndex2 = value.replayInfo.team1EnemySkillIndex2
            info.teamEnemySkillIndex3 = value.replayInfo.team1EnemySkillIndex3

            info.heroSoulSpirit = value.replayInfo.team1HeroSoulSpirits
            info.enemySoulSpirit = value.replayInfo.team1EnemySoulSpirits
    
            info.heroGodarmList = value.replayInfo.team1GodarmList
            info.enemyGodarmList = value.replayInfo.team1EnemyGodarmList
    
            table.insert(self._data, info)
        end
    end

    self:_initListView()
end

function QUIDialogSilvesArenaRecordDetail:_initListView()
    if not self._listView then
        local cfg = {
            renderItemCallBack = function( list, index, info )
                local isCacheNode = true
                local itemData = self._data[index]
                local item = list:getItemFromCache()

                if not item then
                    item = QUIWidgetFightEndDetailClient.new()
                    -- item:addEventListener(QUIWidgetFightEndDetailClient.EVENT_CLICK_HEAD, handler(self, self.headClickHandler))
                    -- item:addEventListener(QUIWidgetFightEndDetailClient.EVENT_CLICK_ONEREPLAY, handler(self, self.oneReplayClickHandler))
                    isCacheNode = false
                end

                item:setInfo(itemData, true)
                info.item = item
                info.size = item:getContentSize()
                
                list:registerBtnHandler(index, "btn_one_replay", handler(self, self._onTriggerReplay), nil, true)
                -- item:registerItemBoxPrompt(index, list)

                return isCacheNode
            end,
            ignoreCanDrag = true,
            enableShadow = false,
            totalNumber = #self._data,
        }  
        self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
    else
        self._listView:reload({totalNumber = #self._data})
    end
end

-- function QUIDialogSilvesArenaRecordDetail:headClickHandler(event)
--     local actorId = event.actorId
--     local isHero = event.isHero or false
--     local isSoulSpirit = event.isSoulSpirit or false

--     local reportId = self._info.reportId
--     local reportType = self._info.reportType

--     local index = event.index
--     local curInfo = self._info[index]

--     local userId = nil
--     if isHero then
--         userId = curInfo.fighter1.userId
--     else
--         userId = curInfo.fighter2.userId
--     end

--     remote.silvesArena:silvesArenaQueryUserDataRequest(userId, function ( data )
--         local fighter = data.silvesArenaInfoResponse.fighter or {}

--         if self:safeCheck() then
--             self:showHeroInfo(fighter, actorId, isSoulSpirit)
--         end
--     end)
-- end

-- function QUIDialogSilvesArenaRecordDetail:showHeroInfo(fighter, actorId, isSoulSpirit)
--     local actorIds = {}
--     local isNPC = false
--     local isSoulNowHero = false
--     local function getActorIds(heros)
--         if isNPC then
--             return
--         end
--         for i, value in pairs( heros or {} ) do
--             -- 如果是魂灵，则需要从魂师里找有没有护佑的对象，有的话，查看的对象就是该魂师 actorId做个转换
--             if isSoulSpirit then
--                 if value.soulSpirit and value.soulSpirit.id == actorId then
--                     actorId = value.actorId
--                     isSoulNowHero = true
--                 end
--             end
--             if value.actorId == actorId and not value.equipments then
--                 isNPC = true
--                 break
--             end
--             table.insert(actorIds, value.actorId)
--         end
--     end
--     getActorIds(fighter.heros)
--     getActorIds(fighter.alternateHeros)
--     getActorIds(fighter.subheros)
--     getActorIds(fighter.sub2heros)
--     getActorIds(fighter.sub3heros)
--     getActorIds(fighter.main1Heros)
--     getActorIds(fighter.sub1heros)
    
--     if isSoulSpirit and not isSoulNowHero then
--         app.tip:floatTip("该魂灵还没有护佑魂师")
--         return
--     end

--     if isNPC then
--         app.tip:floatTip("该魂师正在闭关修炼，请勿打扰")
--         return
--     end

--     local pos = 0
--     for i, id in ipairs(actorIds) do
--         if id == actorId then
--             pos = i
--             break
--         end
--     end
--     app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroInfo", 
--         options = {hero = actorIds, pos = pos, fighter = fighter or {}}})
-- end

function QUIDialogSilvesArenaRecordDetail:_backClickHandler()
    self:playEffectOut()
end

function QUIDialogSilvesArenaRecordDetail:_onTriggerClose(event)
    if q.buttonEventShadow(event,self._ccbOwner.frame_btn_close) == false then return end
    app.sound:playSound("common_cancel")
    self:playEffectOut()
end

function QUIDialogSilvesArenaRecordDetail:_onTriggerShare(event)
    if q.buttonEventShadow(event,self._ccbOwner.btn_share) == false then return end
    app.sound:playSound("common_cancel")

    local matchingId = self._info.matchingId
    local reportIdList = self._info.reportIdList
    local matchingId = self._info.matchingId
    local reportType = self._info.reportType

    remote.silvesArena:silvesShareFightBatter(reportType,self._isFight,matchingId,reportIdList)
end

-- function QUIDialogSilvesArenaRecordDetail:oneReplayClickHandler(event)
--     print("[QUIDialogSilvesArenaRecordDetail:oneReplayClickHandler(event)]")
--     local info = event.info
--     if not event.info then
--         return
--     end
--     local index = info.index
--     local curInfo = self._info[index]

--     local reportId = curInfo.reportId
--     local reportType = curInfo.reportType
    
--     QReplayUtil:downloadSilvesArenaReplay(reportId, index, function (data, statsDataList, fightEndAddScore)
--         if self.class then
--             QReplayUtil:playSilvesArena(data, statsDataList, fightEndAddScore, index, true)
--         end
--     end, fail,false) 
-- end

function QUIDialogSilvesArenaRecordDetail:_onTriggerReplay(  x, y, touchNode, listView  )
    local touchIndex = listView:getCurTouchIndex()
    local item = listView:getItemByIndex(touchIndex)
    if item and item.getInfo then
        local info = item:getInfo()
        if q.isEmpty(info) then return end

        local index = info.index
        local curInfo = self._info[index]
        if q.isEmpty(curInfo) then return end

        local reportId = curInfo.reportId
        
        if not reportId then return end

        QReplayUtil:downloadSilvesArenaReplay(reportId, index, function (fightReportData)
            QReplayUtil:play(fightReportData)
        end, nil, false) 
    end
end

return QUIDialogSilvesArenaRecordDetail

