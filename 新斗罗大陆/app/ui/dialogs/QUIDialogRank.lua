local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogRank = class("QUIDialogRank", QUIDialog)
local QListView = import("...views.QListView")
local QUIViewController = import("..QUIViewController")
local QUIWidgetSelectBtn = import("..widgets.QUIWidgetSelectBtn")
local QUIWidgetSelectSubBtn = import("..widgets.QUIWidgetSelectSubBtn")

QUIDialogRank.rank_config = {}

QUIDialogRank.TYPE_CHILD = "child"
QUIDialogRank.TYPE_PARENT = "parent"

function QUIDialogRank:ctor(options) 
    local ccbFile = "ccb/Dialog_Rank.ccbi";
    local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogRank._onTriggerClose)},
        {ccbCallbackName = "onTriggerFamousPerson", callback = handler(self, QUIDialogRank._onTriggerFamousPerson)},
        {ccbCallbackName = "onTriggerHelp", callback = handler(self, self._onTriggerHelp)},
    }
    QUIDialogRank.super.ctor(self,ccbFile,callBacks,options)
    self.isAnimation = true
    self._ccbOwner.frame_tf_title:setString("排行榜")
    
    self._data = {}
    self._contentDatas = {}
    self._configs = {}
    table.insert(self._configs, {rankName = "famousPerson", btnName = "名人堂", dataProxyClass = "QFamousPersonRank"})
    table.insert(self._configs, {rankName = "battleForce", btnName = "战力", dataProxyClass = "QTeamFightCapacityRank", awardType = 1001, redTip = true})
    table.insert(self._configs, {rankName = "Instance", btnName = "副本", redTip = true})
    table.insert(self._configs, {rankName = "InstanceNormalStar", parentNode = "Instance", btnName = "普通星级排行", dataProxyClass = "QNormalStarRank", awardType = 1002, redTip = true})
    table.insert(self._configs, {rankName = "InstanceEliteStar", parentNode = "Instance", btnName = "精英星级排行", dataProxyClass = "QEliteStarRank", unlock = app.unlock:getUnlockElite()})   
    table.insert(self._configs, {rankName = "speedFamousPerson", btnName = "竞速名人堂", unlock = app.unlock:checkLock("UNLOCK_COLLEGE_TRAIN_3")})
    table.insert(self._configs, {rankName = "speedFamousPersonAll", parentNode = "speedFamousPerson", btnName = "全服排行", dataProxyClass = "QCollegeTrainFamousPersonRankAll"})
    table.insert(self._configs, {rankName = "speedFamousPersonLocal", parentNode = "speedFamousPerson", btnName = "本服排行", dataProxyClass = "QCollegeTrainFamousPersonRankLocal"})        
    table.insert(self._configs, {rankName = "collegeTrain", btnName = "史莱克学院", unlock = app.unlock:checkLock("UNLOCK_COLLEGE_TRAIN_3")})
    local insertFun = function(collegeChapeterInfo)
        for _,chapterInfo in pairs(collegeChapeterInfo) do
            table.insert(self._configs, {rankName = "collegeTrainGroupRealTime"..chapterInfo.id, chapterId = chapterInfo.id, parentNode = "collegeTrain", btnName = (chapterInfo.name or "").."(全服)", dataProxyClass = "QCollegeTrainHallTopRank"})
            table.insert(self._configs, {rankName = "collegeTrainServerRealTime"..chapterInfo.id, chapterId = chapterInfo.id, parentNode = "collegeTrain", btnName = (chapterInfo.name or "").."(本服)", dataProxyClass = "QCollegetTrainRank"})
        end
    end
    if app.unlock:checkLock("UNLOCK_COLLEGE_TRAIN_3") then
        insertFun(remote.collegetrain:getChapterInfoByType(3))
    end
    table.insert(self._configs, {rankName = "thunder", btnName = "杀戮之都", dataProxyClass = "QThunderRank", unlock = app.unlock:getUnlockThunder(), awardType = 1003, redTip = true})
    table.insert(self._configs, {rankName = "invasion", btnName = "魂兽入侵", unlock = app.unlock:getUnlockInvasion(), redTip = true})
    table.insert(self._configs, {rankName = "invasionMaxHurt", parentNode = "invasion", btnName = "伤害排行(实时)", dataProxyClass = "QInvasionDamageRank", awardType = 1005, redTip = true})
    table.insert(self._configs, {rankName = "invasionMeritorious", parentNode = "invasion", btnName = "积分排行(实时)", dataProxyClass = "QInvasionMeritoriousRank"})
    table.insert(self._configs, {rankName = "sunwell", btnName = "海神岛", dataProxyClass = "QSunWarRank", unlock = app.unlock:getUnlockSunWar(), awardType = 1004, redTip = true})
    table.insert(self._configs, {rankName = "level", btnName = "等级", dataProxyClass = "QLevelRank"})
    table.insert(self._configs, {rankName = "arena", btnName = "斗魂场", unlock = app.unlock:getUnlockArena()})
    table.insert(self._configs, {rankName = "arenaRealtime", parentNode = "arena", btnName = "斗魂场(实时)", dataProxyClass = "QRealtimeArenaRank"})
    table.insert(self._configs, {rankName = "arenaEveryDay", parentNode = "arena", btnName = "斗魂场(每日)", dataProxyClass = "QArenaRank"})
    table.insert(self._configs, {rankName = "union", btnName = "宗门", unlock = app.unlock:getUnlockUnion()})
    table.insert(self._configs, {rankName = "unionLevel", parentNode = "union", btnName = "宗门等级排行", dataProxyClass = "QRealtimeUnionRank"})
    table.insert(self._configs, {rankName = "unionDungeon", parentNode = "union", btnName = "宗门副本排行", dataProxyClass = "QUnionDungeonRank"})
    table.insert(self._configs, {rankName = "consortiaWar", parentNode = "union", btnName = "宗门战斗排行", dataProxyClass = "QConsortiaWarRank", unlock = app.unlock:checkLock("UNLOCK_CONSORTIA_WAR")})
    if remote.user.userConsortia and remote.user.userConsortia.consortiaId and remote.user.userConsortia.consortiaId ~= "" and ENABLE_UNION_DUNGEON then
        table.insert(self._configs, {rankName = "unionDamage", parentNode = "union", btnName = "今日成员战绩", dataProxyClass = "QUnionDamageRank"})
    end
    table.insert(self._configs, {rankName = "unionDragonLevel", parentNode = "union", btnName = "武魂等级排行", dataProxyClass = "QUnionDragonRank", unlock = app.unlock:checkLock("SOCIATY_DRAGON")})
    table.insert(self._configs, {rankName = "unionDragonRank", parentNode = "union", btnName = "武魂争霸排行", dataProxyClass = "QUnionDragonRankWar", unlock = remote.unionDragonWar:checkDragonWarUnlock()})
    table.insert(self._configs, {rankName = "unionRedPacketOutput", parentNode = "union", btnName = "发包排行(每周)", dataProxyClass = "QUnionRedPacketOutput"})
    table.insert(self._configs, {rankName = "unionRedPacketInput", parentNode = "union", btnName = "手气排行(每周)", dataProxyClass = "QUnionRedPacketInput"})
    -- table.insert(self._configs, {rankName = "nightmareRank", btnName = "噩梦副本", unlock = app.unlock:getUnlockNightmare()})
    table.insert(self._configs, {rankName = "realtimeNightmare", parentNode = "nightmareRank", btnName = "全区排行(实时)", dataProxyClass = "QRealtimeNightmareRank"})
    table.insert(self._configs, {rankName = "realtimeAreaNightmare", parentNode = "nightmareRank", btnName = "本服排行(实时)", dataProxyClass = "QRealtimeAreaNightmareRank"})
    table.insert(self._configs, {rankName = "combination", btnName = "宿命", dataProxyClass = "QCombinationRank"})
    table.insert(self._configs, {rankName = "worldBoss", btnName = "魔鲸来袭", unlock = app.unlock:getUnlockWorldBoss()})
    table.insert(self._configs, {rankName = "worldBossPerson", parentNode = "worldBoss", btnName = "个人排行(全服)", dataProxyClass = "QWorldBossPersonRank"})
    table.insert(self._configs, {rankName = "worldBossUnion", parentNode = "worldBoss", btnName = "宗门排行(全服)", dataProxyClass = "QWorldBossUnionRank"})
    table.insert(self._configs, {rankName = "metalCity", btnName = "金属之城", dataProxyClass = "QMetalCityEnvRank", unlock = remote.metalCity:checkMetalCityUnlock()})
    table.insert(self._configs, {rankName = "metalAbyss", btnName = "金属深渊", unlock = remote.metalAbyss:checkMetalAbyssIsUnLock()})
    table.insert(self._configs, {rankName = "metalAbyssLocal",parentNode = "metalAbyss", btnName = "金属深渊（本服）", dataProxyClass = "QMetalAbyssEnvRank"})
    -- table.insert(self._configs, {rankName = "metalAbyssWorld",parentNode = "metalAbyss", btnName = "金属深渊（全区）", dataProxyClass = "QMetalAbyssWorldEnvRank"})

    table.insert(self._configs, {rankName = "gloryTower", btnName = "魂师段位赛", unlock = app.unlock:getUnlockGloryTower()})
    table.insert(self._configs, {rankName = "gloryTowerGroupRealTime", parentNode = "gloryTower", btnName = "全区排行(实时)", dataProxyClass = "QRealtimeTowerRank"})
    table.insert(self._configs, {rankName = "gloryTowerGroupWeek", parentNode = "gloryTower", btnName = "全区排行(每周)", dataProxyClass = "QTowerRank"})
    table.insert(self._configs, {rankName = "gloryTowerServerRealTime", parentNode = "gloryTower", btnName = "本服排行(实时)", dataProxyClass = "QRealtimeAreaTowerRank"})
    table.insert(self._configs, {rankName = "gloryTowerServerWeek", parentNode = "gloryTower", btnName = "本服排行(每周)", dataProxyClass = "QTowerAreaRank"})
    table.insert(self._configs, {rankName = "gloryArena", btnName = "魂师争霸赛", unlock = app.unlock:getUnlockGloryTower()})
    table.insert(self._configs, {rankName = "gloryArenaGroupRealTime", parentNode = "gloryArena", btnName = "全区排行(每周)", dataProxyClass = "QRealtimeTowerRank2"})
    table.insert(self._configs, {rankName = "gloryArenaGroupWeek", parentNode = "gloryArena", btnName = "本服排行(每周)", dataProxyClass = "QTowerAreaRank2"})
    table.insert(self._configs, {rankName = "fightClubRank", btnName = "地狱杀戮场", unlock = app.unlock:checkLock("UNLOCK_FIGHT_CLUB")})
    table.insert(self._configs, {rankName = "allFightClubRank", parentNode = "fightClubRank", btnName = "全区排行", dataProxyClass = "QFightClubAllServerRank"})
    table.insert(self._configs, {rankName = "curFightClubRank", parentNode = "fightClubRank", btnName = "本服排行", dataProxyClass = "QFightClubCurServerRank"})
    table.insert(self._configs, {rankName = "stormArena", btnName = "索托斗魂场", unlock = app.unlock:getUnlockStormArena()})
    table.insert(self._configs, {rankName = "stormArenaGroupRealTime", parentNode = "stormArena", btnName = "全区排行", dataProxyClass = "QStormArenaAllServerRank"})
    table.insert(self._configs, {rankName = "stormArenaServerRealTime", parentNode = "stormArena", btnName = "本服排行", dataProxyClass = "QStormArenaCurServerRank"})
    table.insert(self._configs, {rankName = "sliverMine", btnName = "魂兽森林", dataProxyClass = "QRealtimeSilverMineRank", unlock = app.unlock:getUnlockSilverMine()})
    table.insert(self._configs, {rankName = "sanctuary", btnName = "全大陆精英赛", dataProxyClass = "QSanctuaryRank", unlock = app.unlock:checkLock("UNLOCK_SANCTRUARY")})
    table.insert(self._configs, {rankName = "sotoTeam", btnName = "云顶之战", unlock = app.unlock:checkLock("UNLOCK_SOTO_TEAM")})
    table.insert(self._configs, {rankName = "sotoTeamRealtime", parentNode = "sotoTeam", btnName = "全区排行", dataProxyClass = "QSotoTeamRank"})
    table.insert(self._configs, {rankName = "sotoTeamEveryDay", parentNode = "sotoTeam", btnName = "本服排行", dataProxyClass = "QRealtimeSotoTeamRank"})
    table.insert(self._configs, {rankName = "silvesArena", btnName = "西尔维斯斗魂场", unlock = app.unlock:checkLock("UNLOCK_SILVES_ARENA")})
    table.insert(self._configs, {rankName = "silvesArenaGroupRealTime", parentNode = "silvesArena", btnName = "海选赛排行", dataProxyClass = "QSilvesArenaRank"})
    table.insert(self._configs, {rankName = "silvesArenaPeak", parentNode = "silvesArena", btnName = "巅峰赛排行", dataProxyClass = "QSilvesArenaPeakRank"})
    -- table.insert(self._configs, {rankName = "stormArenaUnionRealTime", parentNode = "stormArena", btnName = "军团排行(实时)", dataProxyClass = "QStormArenaUnionRealtimeRank"})
    -- table.insert(self._configs, {rankName = "stormArenaUnionLastWeek", parentNode = "stormArena", btnName = "军团排行(上周)", dataProxyClass = "QStormArenaUnionRank"})
    -- table.insert(self._configs, {rankName = "stormArenaSeasonRealTime", parentNode = "stormArena", btnName = "赛季排行(实时)", dataProxyClass = "QStormArenaSeasonRank"})
    table.insert(self._configs, {rankName = "blackRock", btnName = "传灵塔", unlock = app.unlock:checkLock("UNLOCK_BLACKROCK")})
    table.insert(self._configs, {rankName = "blackRockServerRealTime", parentNode = "blackRock", btnName = "本服排行(实时)", dataProxyClass = "QBlackRockAreaRank"})
    table.insert(self._configs, {rankName = "blackRockGroupRealTime", parentNode = "blackRock", btnName = "全区排行(实时)", dataProxyClass = "QBlackRockRank"})
    -- table.insert(self._configs, {rankName = "sparField", btnName ="晶石幻境", dataProxyClass = "QSparFieldRank", unlock = app.unlock:checkLock("SPAR_UNLOCK")})
    -- table.insert(self._configs, {rankName = "teamArena", btnName = "组队竞技", unlock = app.unlock:getUnlockTeamArena()})
    -- table.insert(self._configs, {rankName = "teamArenaScoreEveryDay", parentNode = "teamArena", btnName = "每日积分排行", dataProxyClass = "QPersonalTeamArenaRank"})
    -- table.insert(self._configs, {rankName = "teamArenaUnionScore", parentNode = "teamArena", btnName = "军团积分排行", dataProxyClass = "QSocietyTeamArenaRank"})
    -- table.insert(self._configs, {rankName = "holyLightRank", btnName = "圣光试炼", unlock = app.unlock:checkLock("UNLOCK_HOLY_LIGHT")})
    -- table.insert(self._configs, {rankName = "allHolyLightRank", parentNode = "holyLightRank", btnName = "全区排行(本周)", dataProxyClass = "QHolyLightAllServerWeekRank"})
    -- table.insert(self._configs, {rankName = "curHolyLightRank", parentNode = "holyLightRank", btnName = "本服排行(本周)", dataProxyClass = "QHolyLightCurServerWeekRank"})
    table.insert(self._configs, {rankName = "soulTower", btnName = "升灵台", unlock = app.unlock:checkLock("UNLOCK_SOUL_TOWER")})
    table.insert(self._configs, {rankName = "allsoulTowerRank", parentNode = "soulTower", btnName = "本服排行", dataProxyClass = "QSoulTowerCurServerRank"})
    table.insert(self._configs, {rankName = "cursoulTowerRank", parentNode = "soulTower", btnName = "全区排行", dataProxyClass = "QSoulTowerAllServerRank"})
    for _,v in ipairs(self._configs) do
        if v.parentNode ~= nil then
            v.oType = QUIDialogRank.TYPE_CHILD
        else
            v.oType = QUIDialogRank.TYPE_PARENT
        end
    end
    self._selectName = "famousPerson"
    if options ~= nil and options.initRank ~= nil then
        self._selectName = options.initRank
    end

    self._bgSize = self._ccbOwner.sp_bg:getContentSize()
    self._contentSize = self._ccbOwner.sheet_content:getContentSize()
    self:selectButton(self._selectName)
end

function QUIDialogRank:viewDidAppear()
    QUIDialogRank.super.viewDidAppear(self)

    self._rankEventProxy = cc.EventProxy.new(remote.rank)
    self._rankEventProxy:addEventListener(remote.rank.EVENT_UPDATE_RANK_DIALOG, handler(self, self._rankEvent))
end

function QUIDialogRank:viewWillDisappear()
    QUIDialogRank.super.viewWillDisappear(self)

    self._rankEventProxy:removeAllEventListeners()
    self._rankEventProxy = nil
end

function QUIDialogRank:viewAnimationInHandler()
    if self._rankList ~= nil then
        self._rankList:resetTouchRect()
    end
end

function QUIDialogRank:_rankEvent(event)
    if event.name == remote.rank.EVENT_UPDATE_RANK_DIALOG then
        self:_renderContent()
        
        self:initBtnListView()
    end
end

--选择一个按钮
function QUIDialogRank:selectButton(rankName,touchIndex)
    if self._selectInfo ~= nil and (self._selectInfo.rankName == rankName or self._selectInfo.parentNode == rankName) then
        return
    end
    local options = self:getOptions()
    options.initRank = rankName
    self:setOptions(options)
    self._selectInfo = nil
    self:_clearSelectInfo()

    --获取父级的节点名称
    local parentName = nil
    for _,v in ipairs(self._configs) do
        if v.rankName == rankName then
            if v.parentNode ~= nil then
                parentName = v.parentNode
            else
                parentName = v.rankName
            end
        end
    end
    --如果是父级节点且下面有子节点则选中第一个子节点
    if parentName == rankName then
        for _,v in ipairs(self._configs) do
            if v.parentNode == parentName then
                rankName = v.rankName
                break
            end
        end
    end

    self._selectIndex = 1
    self._data = {}
    for _,v in ipairs(self._configs) do
        if v.unlock ~= false and (v.parentNode == nil or v.parentNode == parentName) then
            table.insert(self._data, v)
        end
        if v.rankName == parentName then
            self._selectIndex = #self._data
            v.isSelected = true
        end
        if v.rankName == rankName then
            self._selectInfo = v
            v.isSelected = true
        end
    end

    self:_renderContent()

    self:initBtnListView()
end

--清除所有的选中状态
function QUIDialogRank:_clearSelectInfo()
    for _,v in ipairs(self._configs) do
        v.isSelected = false
    end
end

function QUIDialogRank:initBtnListView()
    local headIndex = self._selectIndex
    if self._btnList == nil then
        local cfg = {
            renderItemCallBack = function( list, index, info )
                local isCacheNode = true
                local data = self._data[index]
                local item = list:getItemFromCache(data.oType)
                if not item then
                    isCacheNode = false
                    if data.oType == QUIDialogRank.TYPE_PARENT then
                        item = QUIWidgetSelectBtn.new()
                        item.tag = data.oType
                    else
                        item = QUIWidgetSelectSubBtn.new()
                        item.tag = data.oType
                    end
                end

                item:setInfo(data)
                if data.redTip then
                    item:isShowTips(self:checkRedTips(data.rankName))
                else
                    item:isShowTips(false)
                end

                --回传的参数
                info.item = item
                info.size = item:getContentSize()
                list:registerBtnHandler(index, "btn_click", handler(self, self.mainButtonHandler))

                return isCacheNode
            end,
            curOriginOffset = 0,
            curOffset = 5,
            spaceY = 5,
            headIndex = headIndex,
            enableShadow = false,
            totalNumber = #self._data,
            cacheCond = 1,
        }
        self._btnList = QListView.new(self._ccbOwner.nav_sheet_layer, cfg)
    else
        self._btnList:reload({totalNumber = #self._data, headIndex = headIndex})
    end
end

--点击左侧按钮
function QUIDialogRank:mainButtonHandler( x, y, touchNode, listView )
    app.sound:playSound("common_switch")
    local touchIndex = listView:getCurTouchIndex()
    if self._data[touchIndex] ~= nil then
        self:selectButton(self._data[touchIndex].rankName,touchIndex)
    end
end

--显示右侧内容
function QUIDialogRank:_renderContent()
    if self._selectInfo ~= nil then
        if self._selectInfo.dataProxy == nil and self._selectInfo.dataProxyClass ~= nil then
            self:createDataProxy(self._selectInfo)
        end
        if self._selectInfo.dataProxy ~= nil and self._selectInfo.dataProxy:needsUpdate() then
            if self._selectInfo.dataProxy._unpdateChapterInfo then
                self._selectInfo.dataProxy:_unpdateChapterInfo(self._selectInfo)
            end
            self._selectInfo.dataProxy:update(function ()
                self:_rendContentItems()
                self:_rendSelfItem()
            end,function ()
                self:_rendContentItems()
                self:_rendSelfItem()
            end)
        else
            self:_rendContentItems()
            self:_rendSelfItem()
        end
    end
end

function QUIDialogRank:initRankListView()
    if self._rankList == nil then
        local cfg = {
            renderItemCallBack = function( list, index, info )
                local isCacheNode = true
                local data = self._contentDatas[index]
                local item = list:getItemFromCache(self._selectInfo.rankName)
                if not item then
                    isCacheNode = false
                    item = self._selectInfo.dataProxy:getRankItem()
                    item.tag = self._selectInfo.rankName
                end

                item:setInfo(data)
                self._selectInfo.dataProxy:renderItem(item, index)
                --回传的参数
                info.item = item
                info.size = item:getContentSize()
                self._selectInfo.dataProxy:registerClick(list, index)
                
                return isCacheNode
            end,
            spaceY = 0,
            curOriginOffset = 5,
            contentOffsetX = 10,
            curOffset = 5,
            headIndex = 1,
            enableShadow = true,
            totalNumber = #self._contentDatas,
        }
        self._rankList = QListView.new(self._ccbOwner.sheet_content, cfg)
    else
        self._rankList:reload({totalNumber = #self._contentDatas})
    end
end

--显示右边的UI列表内容
function QUIDialogRank:_rendContentItems()
    self._contentDatas = {}
    local addHeight = -90
    if self._selectInfo.dataProxy ~= nil then
        self._contentDatas = self._selectInfo.dataProxy:getList() or {}
        local myInfo = self._selectInfo.dataProxy:getMyInfo()
        if myInfo == nil then
            addHeight = 0
        end
    end
    self._ccbOwner.sheet_content:setContentSize(CCSize(self._contentSize.width, self._contentSize.height + addHeight))
    self._ccbOwner.sp_bg:setPreferredSize(CCSize(self._bgSize.width, self._bgSize.height + addHeight))
    if self._rankList ~= nil then
        self._rankList:resetTouchRect()
    end
    self:initRankListView()

    self._ccbOwner.node_empty:setVisible(false)
    if #self._contentDatas == 0 and self._selectInfo.dataProxy ~= nil then
        self._selectInfo.dataProxy:setTips(self._ccbOwner.tf_tips)
        self._ccbOwner.node_empty:setVisible(true)
    end
end

--显示自己的内容
function QUIDialogRank:_rendSelfItem()
    self._ccbOwner.myRankBar:removeAllChildren()
    local selfItem = nil
    if self._selectInfo.dataProxy ~= nil then
        selfItem = self._selectInfo.dataProxy:getSelfItem()
        if selfItem ~= nil then
            self._ccbOwner.myRankBar:addChild(selfItem)
        end
    end
end

function QUIDialogRank:checkRedTips(rankName)
    if rankName == nil then return end

    local getChildRank = function(name)
        local data = {}
        for _, v in ipairs(self._configs) do
            if v.parentNode == name then
                data[#data+1] = v
            end
        end
        return data
    end

    local redTip = false
    for _, v in ipairs(self._configs) do
        if v.rankName == rankName then
            if v.dataProxyClass then
                if v.dataProxy == nil then
                    self:createDataProxy(v)
                end
                redTip = v.dataProxy:checkRedTips()
                break
            else
                local datas = getChildRank(rankName)
                for _, child in ipairs(datas) do
                    if child.dataProxy == nil then
                        self:createDataProxy(child)
                    end
                    redTip = child.dataProxy:checkRedTips()
                    if redTip then
                        break
                    end
                end
            end
        end
    end

    return redTip
end

function QUIDialogRank:createDataProxy(config)
    if config.dataProxy == nil then
        local class = import(app.packageRoot .. ".rank." .. config.dataProxyClass)
        config.dataProxy = class.new({config = config})
    end
end

function QUIDialogRank:_backClickHandler()
    self:_close()
end

function QUIDialogRank:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_close) == false then return end
    self:_close()
end

function QUIDialogRank:_onTriggerFamousPerson()
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogFamousPerson", 
        options = {}})
end

function QUIDialogRank:_onTriggerHelp()
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogFamousPersonRule"})
end

function QUIDialogRank:_close()
    app.sound:playSound("common_cancel")
    self:playEffectOut()
end

return QUIDialogRank