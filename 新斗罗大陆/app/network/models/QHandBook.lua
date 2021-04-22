--
-- Author: Kumo.Wang
-- 图鉴数据管理
--

local QBaseModel = import("...models.QBaseModel")
local QHandBook = class("QHandBook", QBaseModel)

local QUIViewController = import("...ui.QUIViewController")
local QActorProp = import("...models.QActorProp")

QHandBook.NEW_DAY = "QHANDBOOK_NEW_DAY"
QHandBook.UPDATE_INFO = "QHANDBOOK_UPDATE_INFO"
QHandBook.EVENT_COMPLETED = "QHANDBOOK_EVENT_COMPLETED"
QHandBook.AUTO_GO = "QHANDBOOK_AUTO_GO"
QHandBook.MOVE_END = "QHANDBOOK_MOVE_END"
QHandBook.NEW_MAP = "QHANDBOOK_NEW_MAP"
QHandBook.EVENT_HANDBOOK_TEAM_PROP_UPDATE = "QHANDBOOK_EVENT_HANDBOOK_TEAM_PROP_UPDATE"
QHandBook.EVENT_HANDBOOK_TEAM_PROP_UPDATE_HERO = "QHANDBOOK_EVENT_HANDBOOK_TEAM_PROP_UPDATE_HERO"

QHandBook.MINE_HERO = 0
QHandBook.THEIR_HERO = 1
QHandBook.OFFLINE_HERO = 2

QHandBook.STATE_NONE = "STATE_NONE" -- 不可激活
QHandBook.STATE_ACTIVATION = "STATE_ACTIVATION" -- 可激活
QHandBook.STATE_GRADE_UP = "STATE_GRADE_UP" -- 可升星
QHandBook.STATE_BREAK_THROUGH = "STATE_BREAK_THROUGH" -- 可突破
QHandBook.STATE_DONE = "STATE_DONE" -- 满级

QHandBook.TYPE_ALL_PROP = "TYPE_ALL_PROP" -- 已激活属性预览
QHandBook.TYPE_EPIC_PROP = "TYPE_EPIC_PROP" -- 史诗属性预览
QHandBook.TYPE_GRADE_PROP = "TYPE_GRADE_PROP" -- 升星属性预览
QHandBook.TYPE_BT_PROP = "TYPE_BT_PROP" -- 界限突破属性预览

function QHandBook:ctor()
    QHandBook.super.ctor(self)
end

function QHandBook:init()
    self._userEventProxy = cc.EventProxy.new(remote.user)
    self._userEventProxy:addEventListener(remote.user.EVENT_TIME_REFRESH, handler(self, self.refreshTimeHandler))

    self._remoteProxy = cc.EventProxy.new(remote)
    self._remoteProxy:addEventListener(remote.HERO_UPDATE_EVENT, handler(self, self.heroUpdateEventHandler))

    self._dispatchTBl = {}
    self._mineHerosID = {} -- 我拥有的
    self._theirHerosID = {} -- 他们拥有的，即我还没拥有的
    self._offlineHerosID = {} -- 还没有推出的
    self._onlineHerosID = {} -- 已经推出的
    self._allHerosID = {} -- 所有的

    self._heroAdmireDic = {}
    self._heroCommentList = {}

    self._isNeedSort = true -- 是否需要对英雄进行排序
    self.isCommentRefreshing = false

    self.handbookEpicPoint = 0 -- 新版魂师图鉴的图鉴点

    self.battlePropKey = {}
    self.battlePropKey["physical_damage_percent_attack"] = {preName = "主力"}
    self.battlePropKey["magic_damage_percent_attack"] = {preName = "主力"}
    self.battlePropKey["physical_damage_percent_beattack_reduce"] = {preName = "主力"}
    self.battlePropKey["magic_damage_percent_beattack_reduce"] = {preName = "主力"}
end

function QHandBook:disappear()
    if self._remoteProexy ~= nil then
        self._remoteProexy:removeAllEventListeners()
        self._remoteProexy = nil
    end

    if self._userEventProxy ~= nil then
        self._userEventProxy:removeAllEventListeners()
        self._userEventProxy = nil
    end
end

function QHandBook:loginEnd(success)
    self:_analysisConfig()
    if success then
        success()
    end
end

-- 进入英雄图鉴列表界面
function QHandBook:openDialog(actorId)
    self:_updateAllHandBookHerosID()
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHandBookClientNew", options = {selectedActorId = actorId}})
end

-- 进入单个英雄图鉴详细界面（该直接返回是英雄个人信息界面，并且该界面不支持图鉴的左右切换）
function QHandBook:openMainDialog(actorId)
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHandBookMain", options = {actorId = actorId}})
end

-- 打开激活、升星、突破界面
function QHandBook:openHandbookDialog(actorId, callback)
    if not actorId then return end

    local uiClass = "QUIDialogHandbookGrade"    -- 激活和升星
    local state = self:getHandbookStateByActorID(actorId)
    if state == self.STATE_BREAK_THROUGH then
        uiClass = "QUIDialogHandbookBT"         -- 突破
    end

    app:getNavigationManager():pushViewController(app.middleLayer, {
        uiType=QUIViewController.TYPE_DIALOG, 
        uiClass=uiClass, 
        options = {
            actorId = actorId, 
            callback = callback
        }
    })
end

function QHandBook:refreshTimeHandler(event)
    if event.time == nil or event.time == 0 then
        -- 针对可能自动解锁新英雄做处理
        self:_analysisConfig()
        self._isNeedSort = true
        remote.user.handBookCommentCount = 0
        self:dispatchEvent( { name = QHandBook.NEW_DAY } )
    end

    if event.time == nil or event.time == 5 then
        -- self:monopolyGetMyInfoRequest()
    end
end

function QHandBook:heroUpdateEventHandler(event)
    self._isNeedSort = true
end

--------------数据储存.KUMOFLAG.--------------

function QHandBook:getAllHerosID()
    return self._allHerosID
end

function QHandBook:getOnlineHerosID()
    return self._onlineHerosID
end

function QHandBook:getHeroHandBookConfigByActorID( actorID )
    return self._config[tostring(actorID)]
end

function QHandBook:getAdmireInfoByActorID( actorID )
    return self._heroAdmireDic[tostring(actorID)]
end

function QHandBook:getCommentInfoArrByActorIDAndIndex( actorID, index )
    return self._heroCommentList
end

function QHandBook:getCommentInfoByActorIDAndCommentID( actorID, commentID )
    for index, value in ipairs(self._heroCommentList) do
        if value.actor_id == actorID and value.comment_id == commentID then
            return value, index
        end
    end
end

--------------调用素材.KUMOFLAG.--------------

function QHandBook:getSketchByBoo( isFemale )
    if isFemale then
        return "ui/dl_wow_pic/sp_qidai_xiaowu.jpg"
    else
        return "ui/dl_wow_pic/sp_qidai_tangsan.jpg"
    end
end

function QHandBook:getFrameByAptitude( aptitude )
    local aptitude = aptitude or -1
    if aptitude >= 12 and aptitude < 15 then
        -- B 蓝
        return "ui/dl_wow_pic/handbook_blue.png"
    elseif aptitude >= 15 and aptitude < 20 then
        -- A、A+ 紫
        return "ui/dl_wow_pic/handbook_purple.png"
    elseif aptitude >= 20 then
        -- S、S+ 橙
        return "ui/dl_wow_pic/handbook_orange.png"
    else
        -- 无
        return "ui/dl_wow_pic/handbook_normal.png"
    end 
end

function QHandBook:getNameBgByAptitude( aptitude )
    local aptitude = aptitude or -1
    if aptitude >= 12 and aptitude < 15 then
        -- B 蓝
        return "ui/dl_wow_pic/handbook_downblue.png"
    elseif aptitude >= 15 and aptitude < 20 then
        -- A、A+ 紫
        return "ui/dl_wow_pic/handbook_downpurple.png"
    elseif aptitude >= 20 then
        -- S、S+ 橙
        return "ui/dl_wow_pic/handbook_downorange.png"
    else
        -- 无
        return "ui/dl_wow_pic/handbook_downorange.png"
    end 
end

function QHandBook:getHeartAnimation()
    return "ccb/effects/mobai.ccbi"
end

--------------便民工具.KUMOFLAG.--------------

function QHandBook:checkRedTips() 
    -- dldl-37343
    -- if app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.HANDBOOK) then
    --     return true
    -- end

    if self:isRedTipsForHeroHandbook() then
        return true
    end

    return false
end

-- 新版魂师图鉴的小红点
function QHandBook:isRedTipsForHeroHandbook(actorId)
    local isRedTips = false
    local isShowRedTips = false
    --策划优化，不要小箭头了，全部用小红点
    local isShowArrowTips = false

    if not q.isEmpty(self._onlineHerosID) then
        for _, heroId in ipairs(self._onlineHerosID) do
            if not actorId or tostring(heroId) == tostring(actorId) then
                local state = self:getHandbookStateByActorID(heroId)
                if state ~= self.STATE_NONE and state ~= self.STATE_DONE then
                    if state == self.STATE_ACTIVATION then
                        isRedTips = true
                        isShowRedTips = true
                        break
                    else
                        if state == self.STATE_GRADE_UP then
                            if self:isReadyGradeUpByActorId(heroId) then
                                isRedTips = true
                                -- isShowArrowTips = true
                                isShowRedTips = true
                                break
                            end
                        elseif state == self.STATE_BREAK_THROUGH then
                            if self:isReadyBreakthroughByActorId(heroId) then
                                isRedTips = true
                                -- isShowArrowTips = true
                                isShowRedTips = true
                                break
                            end
                        end
                    end
                end
            end
        end
    end

    return isRedTips, isShowRedTips, isShowArrowTips
end

function QHandBook:getHandBookTypeByActorID( actorId )
    if not actorId then return QHandBook.OFFLINE_HERO end

    local actorId = tostring(actorId)

    if self._mineHerosID[actorId] then
        return QHandBook.MINE_HERO
    elseif self._theirHerosID[actorId] then
        return QHandBook.THEIR_HERO
    else
        return QHandBook.OFFLINE_HERO
    end
end

function QHandBook:getHeroInfoByActorID( actorId )
    if not actorId then return nil end
    return db:getCharacterByID(actorId)
end

function QHandBook:getHeroAptitudeInfoByActorID( actorId )
    if not actorId then return nil end
    return db:getActorSABC(actorId)
end

function QHandBook:getDialogDisplayByActorID( actorId )
    if not actorId then return nil end
    return db:getDialogDisplay()[tostring(actorId)]
end

function QHandBook:getDoCommentFuncSwitch()
    return true
    -- return tonumber(db:getConfigurationValue("handbook_doComment")) == 1
end

function QHandBook:getTotalAdmireCount( totalAdmireCount )
    if not totalAdmireCount then return 0 end
    if tonumber(totalAdmireCount) > 999999 then
        return "999999+"
    else
        return totalAdmireCount
    end
end

-- 获取图鉴升星等级
function QHandBook:getHandbookLevelByActorID( actorId )
    if q.isEmpty(self.heroHandbookList) then 
        return -1
    else
        if not actorId then return -1 end
        for _, value in ipairs(self.heroHandbookList or {}) do
            if tostring(value.actorId) == tostring(actorId) then
                return tonumber(value.level)
            end
        end
    end
    return -1
end

-- 获取图鉴突破等级
function QHandBook:getHandbookBreakthroughLevelByActorID( actorId )
    if q.isEmpty(self.heroHandbookList) then 
        return -1
    else
        if not actorId then return -1 end
        for _, value in ipairs(self.heroHandbookList or {}) do
            if tostring(value.actorId) == tostring(actorId) then
                return tonumber(value.breakthroughLevel)
            end
        end
    end
    return -1
end

-- 《不可激活》《可激活》《可升星》《可突破》《已满级》是线性关系
function QHandBook:getHandbookStateByActorID( actorId )
    if q.isEmpty(self.heroHandbookList) then 
        if self:isOnceOwnedByActorID(actorId) then
            return self.STATE_ACTIVATION
        end
    else
        for _, value in ipairs(self.heroHandbookList or {}) do
            if tostring(value.actorId) == tostring(actorId) then
                -- 已激活
                if self:isGradeNotMaxByActorID(actorId, value.level) then
                    -- 可升星
                    return self.STATE_GRADE_UP
                elseif self:isBreakthroughNotMaxByActorID(actorId, value.breakthroughLevel) then
                    -- 可突破
                    return self.STATE_BREAK_THROUGH
                else
                    -- 已满级
                    return self.STATE_DONE
                end
            end
        end

        -- 未激活
        if self:isOnceOwnedByActorID(actorId) then
            return self.STATE_ACTIVATION
        end
    end

    return self.STATE_NONE
end

-- 曾经拥有
function QHandBook:isOnceOwnedByActorID( actorId )
    local collectedHeros = remote.user.collectedHeros or {}
    for _, heroId in ipairs(collectedHeros) do
        if tostring(heroId) == tostring(actorId) then
            return true
        end
    end
    return false
end

-- 英雄图鉴升星还没到顶
function QHandBook:isGradeNotMaxByActorID( actorId, level )
    if not actorId then return false end

    local aptitudeInfo = self:getHeroAptitudeInfoByActorID(actorId)
    local aptitude = aptitudeInfo.aptitude
    local handbookGradeConfig = db:getStaticByName("hero_handbook")
    if not q.isEmpty(handbookGradeConfig) then
        local curAptitudeHandbookGradeConfig = handbookGradeConfig[tostring(aptitude)]
        if not q.isEmpty(curAptitudeHandbookGradeConfig) then
            for _, config in pairs(curAptitudeHandbookGradeConfig) do
                if tonumber(config.handbook_level) > tonumber(level) then
                    return true
                end
            end
        end
    end

    return false
end

-- 可升星
function QHandBook:isReadyGradeUpByActorId( actorId )
    local curLevel = self:getHandbookLevelByActorID(actorId)
    if curLevel >= 0 then
        local godSkillLevel = remote.herosUtil:getGodSkillLevelByActorId(actorId)
        if godSkillLevel > curLevel then
            return true
        end
    end
    return false
end

-- 图鉴突破还没到顶
function QHandBook:isBreakthroughNotMaxByActorID( actorId, level )
    if not actorId then return false end

    
    local aptitudeInfo = self:getHeroAptitudeInfoByActorID(actorId)
    local aptitude = aptitudeInfo.aptitude
    local handbookBTConfig = db:getStaticByName("hero_handbook_jiexiantupo")
    if not q.isEmpty(handbookBTConfig) then
        local curAptitudeHandbookBTConfig = handbookBTConfig[tostring(aptitude)]
        if not q.isEmpty(curAptitudeHandbookBTConfig) then
            for _, config in pairs(curAptitudeHandbookBTConfig) do
                if tonumber(config.level) > tonumber(level) then
                    return true
                end
            end
        end
    end

    return false
end

-- 可突破
function QHandBook:isReadyBreakthroughByActorId( actorId )
    local curBTLevel = self:getHandbookBreakthroughLevelByActorID(actorId)
    local notEnough = nil
    local godSkillLevel, maxGodSkillLevel = remote.herosUtil:getGodSkillLevelByActorId(actorId)
    local heroInfo = remote.herosUtil:getHeroByID(actorId)
    local curGodSkillLevel = heroInfo and heroInfo.godSkillGrade or 0
    
    if curGodSkillLevel < maxGodSkillLevel then
        curBTLevel = -1
        notEnough = "godSkill"
    end
    if curBTLevel >= 0 then
        local characterConfig = db:getCharacterByID(actorId)
        if not q.isEmpty(characterConfig) then
            local handbookBTConfig = db:getStaticByName("hero_handbook_jiexiantupo")
            local curHandbookBTConfig = handbookBTConfig[tostring(characterConfig.aptitude)]
            if not q.isEmpty(curHandbookBTConfig) then
                for _, config in pairs(curHandbookBTConfig) do
                    if tonumber(config.level) == curBTLevel + 1 then
                        local gradeConfig = db:getStaticByName("grade")
                        local curGradeConfig = gradeConfig[tostring(actorId)]
                        if not q.isEmpty(curGradeConfig) then
                            local itemId = curGradeConfig[1].soul_gem
                            local itemCount = remote.items:getItemsNumByID(itemId)
                            if itemCount >= tonumber(config.consume_item_num) and remote.user.money >= tonumber(config.consume_money_num) then
                                return true
                            else
                                if itemCount < tonumber(config.consume_item_num) then
                                    notEnough = itemId
                                else
                                    notEnough = "money"
                                end
                                break
                            end
                        end
                    end
                end
            end
        end
    end
    return false, notEnough
end

-- 获取当前的图鉴点量表（已经生效)
function QHandBook:getCurAndOldEpicPropConfig()
    local curConfig = {epic_level = 0}
    local oldConfig = nil

    if not self.handbookEpicPoint then return curConfig end

    self:getEpicPropConfigList()

    for _, config in ipairs(self.epicPropConfig) do
        if tonumber(config.handbook_score_num) > tonumber(self.handbookEpicPoint) then
            return curConfig, oldConfig
        else
            oldConfig = curConfig
            curConfig = config
        end
    end

    return curConfig
end

function QHandBook:getNextEpicPropConfig()
    self:getEpicPropConfigList()

    for _, config in ipairs(self.epicPropConfig) do
        if tonumber(config.handbook_score_num) > tonumber((self.handbookEpicPoint or 0)) then
            return config
        end
    end

    -- 满级
    return {}
end

-- 获取指定等级的图鉴量表
function QHandBook:getEpicPropConfigByLevel(level)
    self:getEpicPropConfigList()
    for _, config in ipairs(self.epicPropConfig) do
        if tonumber(config.epic_level) == level then
            return config
        end
    end
    -- 满级
    return {}
end

function QHandBook:getEpicPropConfigList()
    if q.isEmpty(self.epicPropConfig) then
        self.epicPropConfig = {}
        local epicPropConfig = db:getStaticByName("hero_handbook_epic")
        for _, config in pairs(epicPropConfig) do
            table.insert(self.epicPropConfig, config)
        end
        table.sort(self.epicPropConfig, function(a, b)
            return a.epic_level < b.epic_level
        end)
    end

    return self.epicPropConfig
end

function QHandBook:getHandbookGradeConfigListByActorId(actorId)
    if q.isEmpty(self.handbookGradeConfig) then
        self.handbookGradeConfig = {}
    end

    local aptitudeInfo = self:getHeroAptitudeInfoByActorID(actorId)
    local aptitude = aptitudeInfo.aptitude
    if q.isEmpty(self.handbookGradeConfig[tostring(aptitude)]) then
        self.handbookGradeConfig[tostring(aptitude)] = {}
        local handbookGradeConfig = db:getStaticByName("hero_handbook")
        if not q.isEmpty(handbookGradeConfig) then
            local curAptitudeHandbookGradeConfig = handbookGradeConfig[tostring(aptitude)]
            if not q.isEmpty(curAptitudeHandbookGradeConfig) then
                for _, config in pairs(curAptitudeHandbookGradeConfig) do
                    table.insert(self.handbookGradeConfig[tostring(aptitude)], config)
                end
            end
        end
        table.sort(self.handbookGradeConfig[tostring(aptitude)], function(a, b)
            return a.handbook_level < b.handbook_level
        end)
    end

    return self.handbookGradeConfig[tostring(aptitude)]
end

function QHandBook:getHandbookBTConfigListByActorId(actorId)
    if q.isEmpty(self.handbookBTConfig) then
        self.handbookBTConfig = {}
    end

    local aptitudeInfo = self:getHeroAptitudeInfoByActorID(actorId)
    local aptitude = aptitudeInfo.aptitude
    if q.isEmpty(self.handbookBTConfig[tostring(aptitude)]) then
        self.handbookBTConfig[tostring(aptitude)] = {}
        local handbookBTConfig = db:getStaticByName("hero_handbook_jiexiantupo")
        if not q.isEmpty(handbookBTConfig) then
            local curAptitudeHandbookBTConfig = handbookBTConfig[tostring(aptitude)]
            if not q.isEmpty(curAptitudeHandbookBTConfig) then
                for _, config in pairs(curAptitudeHandbookBTConfig) do
                    table.insert(self.handbookBTConfig[tostring(aptitude)], config)
                end
            end
        end
        table.sort(self.handbookBTConfig[tostring(aptitude)], function(a, b)
            return a.level < b.level
        end)
    end

    return self.handbookBTConfig[tostring(aptitude)]
end

function QHandBook:getActivatedHandbookPropList()
    local tbl = {}

    local analysisPropFunc = function (propList, title)
        local propFields = QActorProp:getPropFields()
        local _tbl = {}
        _tbl["title"] = title
        for _, config in ipairs(propList) do
            for key, value in pairs(config) do
                if propFields[key] then
                    if _tbl[key] then
                        _tbl[key] = _tbl[key] + value
                    else
                        _tbl[key] = value
                    end
                end
            end
        end
        table.insert(tbl, _tbl)
    end
    
    local propList = self:getActivatedGradePropList()
    analysisPropFunc(propList, "升星")

    local propList = self:getCurAndOldEpicPropConfig()
    table.insert(tbl, propList)

    local propList = self:getActivatedBTPropList()
    analysisPropFunc(propList, "突破")

    -- QKumo(tbl)
    return tbl
end

function QHandBook:getActivatedGradePropList()
    local tbl = {}

    for _, heroInfo in ipairs(self.heroHandbookList or {}) do
        local aptitudeInfo = self:getHeroAptitudeInfoByActorID(heroInfo.actorId)
        local aptitude = aptitudeInfo.aptitude
        local handbookGradeConfig = db:getStaticByName("hero_handbook")
        if not q.isEmpty(handbookGradeConfig) then
            local curAptitudeHandbookGradeConfig = handbookGradeConfig[tostring(aptitude)]
            if not q.isEmpty(curAptitudeHandbookGradeConfig) then
                for _, config in pairs(curAptitudeHandbookGradeConfig) do
                    if tonumber(config.handbook_level) == tonumber(heroInfo.level) then
                        table.insert(tbl, config)
                    end
                end
            end
        end
    end

    return tbl
end

function QHandBook:getActivatedBTPropList()
    local tbl = {}

    for _, heroInfo in ipairs(self.heroHandbookList or {}) do
        local aptitudeInfo = self:getHeroAptitudeInfoByActorID(heroInfo.actorId)
        local aptitude = aptitudeInfo.aptitude
        local handbookBTConfig = db:getStaticByName("hero_handbook_jiexiantupo")
        if not q.isEmpty(handbookBTConfig) then
            local curAptitudeHandbookBTConfig = handbookBTConfig[tostring(aptitude)]
            if not q.isEmpty(curAptitudeHandbookBTConfig) then
                for _, config in pairs(curAptitudeHandbookBTConfig) do
                    if tonumber(config.level) == tonumber(heroInfo.breakthroughLevel) then
                        table.insert(tbl, config)
                    end
                end
            end
        end
    end

    return tbl
end

function QHandBook:getCurHandbookPoint(heroHandbookList)
    local handbookPoint = 0

    if heroHandbookList then
        for _, heroInfo in ipairs(heroHandbookList) do
            local aptitudeInfo = self:getHeroAptitudeInfoByActorID(heroInfo.actorId)
            local aptitude = aptitudeInfo.aptitude
            local handbookGradeConfig = db:getStaticByName("hero_handbook")
            if not q.isEmpty(handbookGradeConfig) then
                local curAptitudeHandbookGradeConfig = handbookGradeConfig[tostring(aptitude)]
                if not q.isEmpty(curAptitudeHandbookGradeConfig) then
                    for _, config in pairs(curAptitudeHandbookGradeConfig) do
                        if tonumber(config.handbook_level) <= tonumber(heroInfo.level) then
                            handbookPoint = handbookPoint + config.handbook_score
                        end
                    end
                end
            end
        end
    else
        handbookPoint = self.handbookEpicPoint
    end

    return handbookPoint
end

function QHandBook:getCurHandbookGradeConfigByActorId(actorId, level)
    local aptitudeInfo = self:getHeroAptitudeInfoByActorID(actorId)
    local aptitude = aptitudeInfo.aptitude
    local handbookGradeConfig = db:getStaticByName("hero_handbook")
    if not q.isEmpty(handbookGradeConfig) then
        local curAptitudeHandbookGradeConfig = handbookGradeConfig[tostring(aptitude)]
        if not q.isEmpty(curAptitudeHandbookGradeConfig) then
            for _, config in pairs(curAptitudeHandbookGradeConfig) do
                if tonumber(config.handbook_level) == tonumber(level) then
                    return config
                end
            end
        end
    end
end

function QHandBook:getCurHandbookBTConfigByActorId(actorId, level)
    local aptitudeInfo = self:getHeroAptitudeInfoByActorID(actorId)
    local aptitude = aptitudeInfo.aptitude
    local handbookGradeConfig = db:getStaticByName("hero_handbook_jiexiantupo")
    if not q.isEmpty(handbookGradeConfig) then
        local curAptitudeHandbookGradeConfig = handbookGradeConfig[tostring(aptitude)]
        if not q.isEmpty(curAptitudeHandbookGradeConfig) then
            for _, config in pairs(curAptitudeHandbookGradeConfig) do
                if tonumber(config.level) == tonumber(level) then
                    return config
                end
            end
        end
    end
end

function QHandBook:getCurStatePropIncreaseByActorId(actorId, state)
    local propFields = QActorProp:getPropFields()
    if state == self.STATE_ACTIVATION then
        local aptitudeInfo = self:getHeroAptitudeInfoByActorID(actorId)
        if aptitudeInfo.lower == "ss+" then
            return self:getCurHandbookGradeConfigByActorId(actorId, 0)
        else
            return self:getCurHandbookGradeConfigByActorId(actorId, 1)
        end
    elseif state == self.STATE_GRADE_UP then
        local curGrade = self:getHandbookLevelByActorID(actorId)
        local oldConfig = self:getCurHandbookGradeConfigByActorId(actorId, curGrade - 1)
        local newConfig = self:getCurHandbookGradeConfigByActorId(actorId, curGrade)
        if q.isEmpty(oldConfig) then
            return newConfig 
        end

        local tbl = {}
        for key, value in pairs(newConfig) do
            if propFields[key] then
                local increaseValue = value - (oldConfig[key] or 0)
                if increaseValue > 0 then
                    tbl[key] = increaseValue
                end
            end
        end
        return tbl
    elseif state == self.STATE_BREAK_THROUGH then
        local curBT = self:getHandbookBreakthroughLevelByActorID(actorId)
        local oldConfig = self:getCurHandbookBTConfigByActorId(actorId, curBT - 1)
        local newConfig = self:getCurHandbookBTConfigByActorId(actorId, curBT)
        if q.isEmpty(oldConfig) then
            return newConfig 
        end
        local tbl = {}
        for key, value in pairs(newConfig) do
            if propFields[key] then
                local increaseValue = value - (oldConfig[key] or 0)
                if increaseValue > 0 then
                    tbl[key] = increaseValue
                end
            end
        end
        return tbl
    elseif state == "handbook_point" then
        local curBT = self:getCurHandbookPoint()
        local newConfig, oldConfig = self:getCurAndOldEpicPropConfig()
        if q.isEmpty(oldConfig) then
            return newConfig 
        end
        local tbl = {}
        for key, value in pairs(newConfig) do
            if propFields[key] then
                local increaseValue = value - (oldConfig[key] or 0)
                if increaseValue > 0 then
                    tbl[key] = increaseValue
                end
            end
        end
        return tbl
    else
        return {}
    end
end
--------------数据处理.KUMOFLAG.--------------

-- 新魂师图鉴
--[[
/**
 * 魂师图鉴
 */
message HeroHandbook {
  optional int32 actorId   = 1 ;  // 英雄ID
  optional int32 level     = 2 ;   // 图鉴等级 ssr激活的时候是0级、ssr以下激活的时候是1级
  optional int32 breakthroughLevel  = 3 ;   // 界限突破等级
}
]]
function QHandBook:updateHeroHandbookList(heroHandbookList)
    self.heroHandbookList = heroHandbookList
    self:dispatchEvent( { name = QHandBook.EVENT_HANDBOOK_TEAM_PROP_UPDATE, heroHandbookList = heroHandbookList } )
    self:dispatchEvent( { name = QHandBook.EVENT_HANDBOOK_TEAM_PROP_UPDATE_HERO} )
end

function QHandBook:responseHandler( response, successFunc, failFunc )
    -- QPrintTable( response )
    -- if response.userExtension and response.userExtension.handBookCommentCount then
    --     remote.user.handBookCommentCount = response.userExtension.handBookCommentCount
    -- end

    if response.handBookInfoResponse and response.error == "NO_ERROR" then
        if response.api == "HAND_BOOK_ADMIRE" and response.handBookInfoResponse.handBookCommentInfo then
            self:_changeHandBookInfo(response.handBookInfoResponse)
        else
            self:_saveHandBookInfo(response.handBookInfoResponse, response.api)
        end
        -- table.insert(self._dispatchTBl, QHandBook.UPDATE_INFO)
    end

    if response.api == "HAND_BOOK_GET_COMMENT_INFO" then
        self.isCommentRefreshing = false
    end

    if successFunc then 
        successFunc(response) 
        self:_dispatchAll()
        return
    end

    if failFunc then 
        failFunc(response)
    end

    self:_dispatchAll()
end

function QHandBook:pushHandler( data )
    -- QPrintTable(data)
end

--[[
    //魂师图鉴
    HAND_BOOK_GET_HERO_INFO                     = 9701;                     // 魂师图鉴--获取所有英雄点赞集合 HandBookInfoResponse
    HAND_BOOK_GET_COMMENT_INFO                  = 9702;                     // 魂师图鉴--获取评论集合 HandBookGetCommentRequest HandBookInfoResponse
    HAND_BOOK_ADMIRE                            = 9703;                     // 魂师图鉴--点赞 HandBookAdmireRequest HandBookInfoResponse
    HAND_BOOK_COMMENT                           = 9704;                     // 魂师图鉴--评论 HandBookDoCommentRequest HandBookInfoResponse

    //新图鉴
    HERO_HANDBOOK_BREAKTHROUGH    = 10207;  // 界限突破       HeroHandbookBreakthroughRequest HeroHandbookResponse
    HERO_HANDBOOK_UPGRADE = 10208;          // 激活/升星      HeroHandbookUpgradeRequest HeroHandbookResponse
]]


function QHandBook:handBookInfoRequest(success, fail, status)
    local request = { api = "HAND_BOOK_GET_HERO_INFO" }
    app:getClient():requestPackageHandler("HAND_BOOK_GET_HERO_INFO", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional int32 actorId = 1; //评论对应的英雄id
-- optional int32 index = 2; //评论对应的索引Id  等于0说明需要热评 等于其他就是页数索引
function QHandBook:handBookGetCommentRequest(actorId, index, success, fail, status)
    local handBookGetCommentRequest = {actorId = actorId, index = index}
    local request = { api = "HAND_BOOK_GET_COMMENT_INFO", handBookGetCommentRequest = handBookGetCommentRequest }
    self.isCommentRefreshing = true
    app:getClient():requestPackageHandler("HAND_BOOK_GET_COMMENT_INFO", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional string admireId = 1; //点赞对应的id
-- optional int32 index = 2;     //点赞对应的index  英雄的就是0，评论的就给对应index
-- optional int32 actorId = 3; //评论对应的英雄Id
function QHandBook:handBookAdmireRequest(admireId, index, actorId, success, fail, status)
    local handBookAdmireRequest = {admireId = tostring(admireId), index = tonumber(index), actorId = tonumber(actorId)}
    local request = { api = "HAND_BOOK_ADMIRE", handBookAdmireRequest = handBookAdmireRequest }
    app:getClient():requestPackageHandler("HAND_BOOK_ADMIRE", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional int32 actorId = 1; //评论对应的id
-- optional string content = 2; //评论内容
function QHandBook:handBookDoCommentRequest(actorId, content, success, fail, status)
    local handBookDoCommentRequest = {actorId = actorId, content = content}
    local request = { api = "HAND_BOOK_COMMENT", handBookDoCommentRequest = handBookDoCommentRequest }
    app:getClient():requestPackageHandler("HAND_BOOK_COMMENT", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

function QHandBook:requestHandBookRank(kind, userId, actorId, success, fail, status)
    local rankingsRequest = {kind = kind, userId = userId, actorId = tonumber(actorId)}
    local request = {api = "RANKINGS", rankingsRequest = rankingsRequest}
    app:getClient():requestPackageHandler("RANKINGS", request, function(response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

function QHandBook:requestHandBookRankHeroInfo(targetUserId, actorId, success, fail, status)
    local handBookGetTargetUserHeroInfoRequest = {targetUserId = targetUserId, actorId = tonumber(actorId)}
    local request = {api = "HAND_BOOK_TARGET_HERO_INFO", handBookGetTargetUserHeroInfoRequest = handBookGetTargetUserHeroInfoRequest}
    app:getClient():requestPackageHandler("HAND_BOOK_TARGET_HERO_INFO", request, function(response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- repeated int32 actorId = 1; // 英雄ID
function QHandBook:heroHandbookBreakthroughRequest(actorId, success, fail, status)
    local heroHandbookBreakthroughRequest = {actorId = actorId}
    local request = {api = "HERO_HANDBOOK_BREAKTHROUGH", heroHandbookBreakthroughRequest = heroHandbookBreakthroughRequest}
    app:getClient():requestPackageHandler("HERO_HANDBOOK_BREAKTHROUGH", request, function(response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- repeated int32 actorId = 1; // 英雄ID
-- optional bool oneClick = 2; // 是否一键激活
function QHandBook:heroHandbookUpgradeRequest(actorId, oneClick, success, fail, status)
    local heroHandbookUpgradeRequest = {actorId = actorId, oneClick = oneClick}
    local request = {api = "HERO_HANDBOOK_UPGRADE", heroHandbookUpgradeRequest = heroHandbookUpgradeRequest}
    app:getClient():requestPackageHandler("HERO_HANDBOOK_UPGRADE", request, function(response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end


--------------本地工具.KUMOFLAG.--------------

function QHandBook:_dispatchAll()
    if not self._dispatchTBl or table.nums(self._dispatchTBl) == 0 then return end
    local tbl = {}
    for _, name in pairs(self._dispatchTBl) do
        if not tbl[name] then
            self:dispatchEvent({name = name})
            tbl[name] = 0
        end
    end
    self._dispatchTBl = {}
end

function QHandBook:_analysisConfig()
    self._allHerosID = {}
    self._onlineHerosID = {}
    self._offlineHerosID = {}
    self._config = db:getHandBookConfig()
    for actorId, actorInfo in pairs(self._config) do
        if not db:checkHeroShields(actorId) then
            table.insert(self._allHerosID, actorId)
            if actorInfo.is_online == 1 then
                table.insert(self._onlineHerosID, actorId)
            else
                self._offlineHerosID[actorId] = true
            end
        end
    end
end

function QHandBook:_updateAllHandBookHerosID()
    if self._isNeedSort then
        self._isNeedSort = false
        self._mineHerosID = {}
        self._theirHerosID = {}

        for _, actorId in pairs(self._onlineHerosID) do
            local isHave = remote.herosUtil:checkHeroHavePast(actorId)
            if isHave then
                self._mineHerosID[actorId] = true
            else
                self._theirHerosID[actorId] = true
            end
        end

        local sortFunc = function(a, b)
            local characherA = db:getCharacterByID(a)
            local characherB = db:getCharacterByID(b)
            if characherA ~= nil and characherB ~= nil then
                if characherA.aptitude > characherB.aptitude then
                    return true
                elseif characherA.aptitude < characherB.aptitude then
                    return false
                else
                    if self._mineHerosID[a] and not self._mineHerosID[b]  then
                        return true
                    elseif not self._mineHerosID[a] and self._mineHerosID[b]  then
                        return false
                    elseif self._offlineHerosID[a] and not self._offlineHerosID[b] then
                        return false
                    elseif not self._offlineHerosID[a] and self._offlineHerosID[b] then
                        return true
                    else
                        return tonumber(a) < tonumber(b)
                    end
                end
            else
                return tonumber(a) < tonumber(b)
            end
        end

        table.sort(self._allHerosID, sortFunc)
        table.sort(self._onlineHerosID, sortFunc)
    end
end

function QHandBook:_saveHandBookInfo(data, api)
    if data.handBookHeroInfo then
        for _, value in ipairs(data.handBookHeroInfo) do
            local key = tostring(value.actor_id)
            self._heroAdmireDic[key] = value
        end
        -- QPrintTable(self._heroAdmireDic)
    end

    if data.handBookCommentInfo then
        self._heroCommentList = data.handBookCommentInfo
    elseif api == "HAND_BOOK_GET_COMMENT_INFO" then
        self._heroCommentList = {}
    end
end

function QHandBook:_changeHandBookInfo(data)
    if data.handBookCommentInfo then
        for _, value in ipairs(data.handBookCommentInfo) do
            local info, index = self:getCommentInfoByActorIDAndCommentID(value.actor_id, value.comment_id)
            if info then
                if not value.sum_count then
                    -- 这里是专门处理，前端请求评论点赞之时，后端已经没有这条评论数据的情况，这时，后端只会返回前端请求时的actor_id和comment_id
                    info.isAdmire = not info.isAdmire
                    if info.isAdmire then
                        info.sum_count = info.sum_count + 1
                    else
                        info.sum_count = info.sum_count - 1
                    end
                else
                    self._heroCommentList[index] = value
                end
            else
                table.insert(self._heroCommentList, value)
            end
        end
    end
end

return QHandBook
