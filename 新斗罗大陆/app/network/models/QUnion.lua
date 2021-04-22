--
-- Author: Your Name
-- Date: 2015-07-27 11:07:01
--
local QBaseModel = import("...models.QBaseModel")
local QUnion = class("QUnion",QBaseModel)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QVIPUtil = import("...utils.QVIPUtil")
local QUIViewController = import("...ui.QUIViewController")
local QNavigationController = import("...controllers.QNavigationController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QActorProp = import("...models.QActorProp")
local QUnionActive = import("...network.models.QUnionActive")
local QTutorialEvent = import("...tutorial.event.QTutorialEvent")
QUnion.SOCIETY_BUY_FIGHT_COUNT_SUCCESS = "SOCIETY_BUY_FIGHT_COUNT_SUCCESS"
QUnion.SOCIETY_RECEIVED_AWARD_SUCCESS = "SOCIETY_RECEIVED_AWARD_SUCCESS"
QUnion.SOCIETY_RECEIVED_CHEST_SUCCESS = "SOCIETY_RECEIVED_CHEST_SUCCESS"
QUnion.SOCIETY_BOSS_DEAD = "SOCIETY_BOSS_DEAD"
QUnion.NEW_DAY = "NEW_DAY"
QUnion.SOCIETY_EXIT_ROBOT = "SOCIETY_EXIT_ROBOT"

QUnion.DEPUTY_RIGHT_TIPS = "DEPUTY_RIGHT_TIPS"
QUnion.FREE_TOKEN_REDPACKET_TIPS = "FREE_TOKEN_REDPACKET_TIPS"

QUnion.UPDATE_DRAGON_TRAIN_BUFF = "UPDATE_DRAGON_TRAIN_BUFF"
QUnion.FORCE_LIMIT = 900000000000 -- 玩家设置的宗门战力条件的上限值（主要是限于显示位数）
QUnion.HEAD_TYPE_DRAGON = 12

QUnion.DUNGEON_MAX_CHAPTER = 40    --宗门副本最大章节
QUnion.DUNGEON_MAX_WAVE = 7    --宗门副本最大章节中的最大关卡
QUnion.FINAL_DUNGEON_BOSS_TYPE = 1    --宗门副本通关后无限血量boss类型
QUnion.FOCUSED_TIME = 631123200000 -- 公会副本未设置集火的时间

QUnion.ACTIVITY_MODULE_TYPE = "ACTIVITY_MODULE_TYPE" -- 公會活躍排行模塊

function QUnion:ctor()
	QUnion.super.ctor(self)
    
    self.consortia = {}
    self._consortiaBossList = {} -- 宗门副本BOSS列表
    self._fightChapter = 0 -- 宗门副本战斗中的章节
    self._showChapter = 0 -- 宗门副本展示在当前页面的章节
    self._minChapter = 99999999 -- 宗门副本当天可以返回到的最小的章节
    self._fightWave = 0 --记录个人正在击杀的BOSS的wave，进入战斗准备的时候记录
    self._isInBattle = false
    self._inBattleWave = 0
    self._inBattleChapter = 0
    self._fightDefaultCount = 9 --小舞助手开启后宗门副本次数
    self._consortiaBossSpecAward  = nil
    self._societyUnlockData = {} -- 保存了已经通关的章节信息（包括昨天之前通关的）

    -- 初始化一个宗门活跃的数据类
    self.unionActive = QUnionActive.new()

    self.recruit = "邀请玩家加入，一起共创美好未来！"
    self.isDefault = true
end

function QUnion:init()
    self:_analyseConsortiaConfiguration()
end

function QUnion:loginEnd()
    if self.unionActive then
        self.unionActive:didappear()
    end
end

function QUnion:disappear()
    if self.unionActive then
        self.unionActive:disappear()
    end
end

function QUnion:openDialog(callFunc,isTutoria)
    self:unionOpenRequest(function (data)
        if next(data.consortia) then
            app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSocietyUnionMain", options = {info = data.consortia, callFunc = callFunc}})
            if isTutoria then
                QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QTutorialEvent.EVENT_ENTER_UNION_MAIN_PAGE})
            end
        else
            app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnion", options = {initButton = "onTriggerJoin"}})
            if isTutoria then
                QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QTutorialEvent.EVENT_ENTER_NOTHAVE_UNION})
            end
        end
    end)
end

function QUnion:getUnionBossWhenLogin(success, fail, status)
    if remote.user.userConsortia and remote.user.userConsortia.consortiaId and remote.user.userConsortia.consortiaId ~= "" and ENABLE_UNION_DUNGEON and self.consortia.level >= self._societyNeedLevel then 
        self:unionGetBossListRequest(function(response)
                if response.consortiaBossList then
                    if #response.consortiaBossList > 0 then
                        self._consortiaBossList = self:_analyseConsortiaBossList(response.consortiaBossList)
                    end
                end
                if success then
                    success()
                end
            end,function ()
                if fail then
                    fail()
                end
            end)
    else
        if success then
            success()
        end
    end
end

function QUnion:getUnionInfoWhenLogin( success, fail, status )
    if remote.user.userConsortia and remote.user.userConsortia.consortiaId and remote.user.userConsortia.consortiaId ~= "" then 
        self:unionOpenRequest(function ( ... )
            if success then
                success()
            end
            remote.unionDragonWar:loginEnd(nil, false)
        end, fail, status)
    else
        if success then
            success()
        end
    end
end

function QUnion:checkHaveUnion()
    if remote.user.userConsortia and remote.user.userConsortia.consortiaId and remote.user.userConsortia.consortiaId ~= "" then 
        return true
    end

    return false
end

function QUnion:checkUnionShopRedTips( )
    if remote.stores:checkCanRefreshShop(SHOP_ID.consortiaShop) or remote.stores:checkAwardsShopCanBuyByShopId(SHOP_ID.consortiaAwardsShop) then
        return true
    end
    return false
end

function QUnion:checkBuildingRedTips(  )
    if remote.mark:checkIsMark(remote.mark.MARK_CONSORTIA_SACRIFICE) then
        return true
    end

    if remote.user.userConsortia.sacrificeCount and remote.user.userConsortia.sacrificeCount < tonumber(QStaticDatabase:sharedDatabase():getConfiguration()["FETE_TIME"].value) then
       return true
    end

    local fete_config = QStaticDatabase:sharedDatabase():getSocietyFeteReward(self.consortia.level or 1)
    for k, v in ipairs(fete_config) do
       if self.consortia.sacrifice and v.fete_schedule and v.fete_schedule <= self.consortia.sacrifice and not remote.user.userConsortia["draw" .. k] then
            return true
       end
    end
    return false
end

function QUnion:checkUnionManageRedTips(  )
    return remote.mark:checkIsMark(remote.mark.MARK_CONSORTIA_APPLY) 
end

function QUnion:checkUnionSkillRedTips( )
    local openLevel = QStaticDatabase.sharedDatabase():getConfigurationValue("SOCIATY_SKILL") or 0
    if openLevel > (self.consortia.level or 0) then
        return false
    end

    -- if remote.user.consortiaMoney < 50000 then
    --     return false
    -- end

    local getSkillLevel = function(skillId)
        local list = remote.user.userConsortiaSkill or {}
        for i = 1, #list do
            if tonumber(skillId) == tonumber(list[i].skillId) then
                return list[i].skillLevel
            end
        end
        return 0
    end

    if self.consortia and self.consortia.consortiaSkillList then
        local list = self.consortia.consortiaSkillList 
        for i = 1, #list do
            local skillLevel = getSkillLevel(list[i].skillId)
            local nextConfig = QStaticDatabase.sharedDatabase():getUnionSkillConfigByLevel(list[i].skillId, skillLevel + 1)
            if tonumber(skillLevel) < tonumber(list[i].skillMaxLevel) and nextConfig and next(nextConfig) then
                if tonumber(nextConfig.contribution_require or 0) <= remote.user.consortiaMoney then
                    return true
                end
            end
        end
    end

    return false
end

function QUnion:checkAllSocietyDungeonRedTips()
    local needLevel = self:getSocietyNeedLevel()
    if not ENABLE_UNION_DUNGEON or not needLevel or not self.consortia or not self.consortia.level or (self.consortia.level or 0) < needLevel then return false end
    if self:checkSocietyDungeonAwardRedTips() then return true end
    if self:checkSocietyDungeonChestRedTips() then return true end
    if self:checkUnionShopRedTips() then return true end

    return false
end

function QUnion:checkSocietyDungeonRedTips()
    local curTimeTbl = q.date("*t", q.serverTime())
    local startTime = self:getSocietyDungeonStartTime()
    local endTime = self:getSocietyDungeonEndTime()
    if curTimeTbl.hour < startTime or curTimeTbl.hour > endTime - 1 then return false end
    local userConsortia = remote.user:getPropForKey("userConsortia")
    if (userConsortia.consortia_boss_fight_count or 0) > 0 then return true end
    return false
end

function QUnion:checkSocietyDungeonAwardRedTips()
    if not self.consortia or not self.consortia.max_chapter or (self.consortia.max_chapter or 0) < 2 then return false end 
    local maxChapter = self.consortia.max_chapter - 1 -- consortia.max_chapter记录的是最高到过的章节，但没有通关
    local userConsortia = remote.user:getPropForKey("userConsortia")
    local tbl = userConsortia.consortia_chapter_reward
    local isFind = false
    if tbl and table.nums(tbl) >0 then
        for c = 1, maxChapter, 1 do
            isFind = true
            for _, a in pairs(tbl) do
                if c == a then
                    isFind = false
                end
            end
            if isFind then
                return true
            end
        end
    else
        return true
    end
    
    return false
end

function QUnion:checkSocietyDungeonChestRedTips( chapter )
    if not self._consortiaBossList or table.nums(self._consortiaBossList) == 0 then return false end
    if chapter then
        if not self._consortiaBossList[chapter] or table.nums(self._consortiaBossList[chapter]) == 0 then return false end
        for _, value in pairs(self._consortiaBossList[chapter]) do
            if value.bossHp == 0 then
                if not self:isReceived(value.wave, chapter) then
                    return true
                end
            end
        end
    else
        for _, chapterBossList in pairs(self._consortiaBossList) do
            for _, value in pairs(chapterBossList) do
                if value.bossHp == 0 then
                    if not self:isReceived(value.wave, value.chapter) then
                        return true
                    end
                end
            end
        end
    end
    return false
end

function QUnion:isReceived( wave, chapter )
    local scoietyWaveConfig = QStaticDatabase.sharedDatabase():getScoietyWave(wave, chapter)
    if not scoietyWaveConfig or not scoietyWaveConfig.sociaty_box then 
        return true
    end
    local userConsortia = remote.user:getPropForKey("userConsortia")
    local tbl = userConsortia.consortia_boss_reward
    -- QPrintTable(tbl)
    if not tbl or #tbl == 0 then return false end

    for _, value in pairs(tbl) do
        if value.chapter == chapter and value.wave == wave then
            return true
        end
    end

    return false
end

function QUnion:checkUnionRedTip()
    if remote.user.userConsortia.consortiaId == nil or remote.user.userConsortia.consortiaId == "" then
        return true
    elseif self:checkBuildingRedTips() then
        return true
    elseif self:checkUnionShopRedTips() then
        return true
    elseif self:checkUnionManageRedTips() then
        return true
    elseif self:checkUnionSkillRedTips() then
        return true
    elseif self:checkAllSocietyDungeonRedTips() then
        return true
    elseif remote.union.unionActive:checkRedTip() then
        return true
    elseif remote.plunder:checkPlunderRedTip() then 
        return true 
    elseif remote.dragonTotem:checkAllTotemTips() then
        return true
    elseif remote.dragon:checkDragonRedTip() then
        return true
    elseif remote.unionDragonWar:checkDragonWarRedTip() then
        return true
    elseif remote.question:checkQuestionRedTip() then
        return true
    elseif remote.redpacket:checkRedpacketRedTip() then
        return true
    elseif remote.offerreward:checkRedTips() then 
        return true 
    else
        return false
    end
end

function QUnion:resetUnionData(  )
    self.consortia = {}
    remote.dragon:resetData()
    remote.unionDragonWar:resetData()
end


function QUnion:checkUnionDungeonIsOpen(isTip)
    local curTimeTbl = q.date("*t", q.serverTime())
    local startTime = self:getSocietyDungeonStartTime()
    local endTime = self:getSocietyDungeonEndTime()
    local tipStr = "开启时间为"..startTime..":00至"..endTime..":00"
    if curTimeTbl.hour > endTime - 1 or curTimeTbl.hour < startTime then
        if isTip then
            app.tip:floatTip(tipStr)
        end
        return false, tipStr
    end

    return true
end

function QUnion:checkIsFinalWave(chapter, wave)
    if chapter == nil or wave == nil then return false end

    if chapter == QUnion.DUNGEON_MAX_CHAPTER and wave == QUnion.DUNGEON_MAX_WAVE then
        return true
    end

    return false
end

-------------------------------request Handler------------------------------
function QUnion:updateDragonTrainBuff( response, isDispatchEvent )
    if response and response.consortia and response.consortia.dragon_task_reward_buff_start_at and response.error == "NO_ERROR" then
        local preTime = self.consortia.dragon_task_reward_buff_start_at or FOUNDER_TIME
        self.consortia.dragon_task_reward_buff_start_at = response.consortia.dragon_task_reward_buff_start_at
        if isDispatchEvent and preTime < response.consortia.dragon_task_reward_buff_start_at then
            self:dispatchEvent({name = self.UPDATE_DRAGON_TRAIN_BUFF})
        end
    end
end

-- 宗门
function QUnion:unionResponse(response, success, fail)
    if response.api == "CONSORTIA_SACRIFICE" and response.error == "NO_ERROR" then
        app.taskEvent:updateTaskEventProgress(app.taskEvent.UNION_SACRIFICE_COUNT_EVENT, 1)
    elseif response.api == "LUCKY_DRAW_CONSORTIA_SACRIFICE" and response.error == "NO_ERROR" then
        app.taskEvent:updateTaskEventProgress(app.taskEvent.UNION_SACRIFICE_REWARD_COUNT_EVENT, 1)
    end

    self:updateDragonTrainBuff(response, true)

    if success then 
        if response.consortia then
            if self.consortia.sid == nil then
                self.unionActive:updateActiveInfo()
            end
            for k, v in pairs(response.consortia) do
                self.consortia[k] = v
            end
        end

        if response.consortiaBossList then
            if #response.consortiaBossList > 0 then
                self._consortiaBossList = self:_analyseConsortiaBossList(response.consortiaBossList)
            end
        end

        if response.userConsortia and response.userConsortia.isAwardQualified and self.unionActive then
            self.unionActive:setCanTakenChestAward(response.userConsortia.isAwardQualified)
        end

        if response.consortiaDragonTask then
            remote.dragon:setDragonTaskInfo(response.consortiaDragonTask)
        end

        if response.consortiaDragon then
            remote.dragon:setDragonInfo(response.consortiaDragon)
        end

        if response.consortiaBillboardList then
            if response.consortiaBillboardList.main_message_author then
                self.consortia.main_message_author = response.consortiaBillboardList.main_message_author
            end
        end

        success(response) 
        return
    end

    if fail then 
        fail(response)
    else
        print("Pop to main page")
        --app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TO_CURRENT_PAGE)
    end
end

function QUnion:_analyseConsortiaBossList(bossList)
    local tbl = {}
    for _, value in pairs(bossList) do
        if not tbl[value.chapter] then
            tbl[value.chapter] = {}
            if value.chapter > self._fightChapter then
                self._fightChapter = value.chapter
            end
            if value.chapter > (self.consortia.max_chapter or 0) then
                self.consortia.max_chapter = value.chapter
            end
            if value.chapter < self._minChapter then
                self._minChapter = value.chapter
            end
        end
        table.insert(tbl[value.chapter], value)
    end
    for _, value in pairs(tbl) do
        table.sort(value, function(a, b) return a.wave < b.wave end)
    end

    return tbl
end

-- 宗门推荐列表
function QUnion:unionRecommendListRequest(page, size, success, fail, status)
    local consortiaRecommendListRequest = {page = page, size = size}
    local request = {api = "CONSORTIA_RECOMMEND_LIST", consortiaRecommendListRequest = consortiaRecommendListRequest}
    app:getClient():requestPackageHandler("CONSORTIA_RECOMMEND_LIST", request, function (response)
        self:unionResponse(response, success)
    end, function (response)
        self:unionResponse(response, nil, fail)
    end)
end

-- 创建宗门
function QUnion:unionFoundRequest(name, icon, success, fail, status)
    local consortiaCreateRequest = {name = name, icon = icon}
    local request = {api = "CONSORTIA_CREATE", consortiaCreateRequest = consortiaCreateRequest}
    app:getClient():requestPackageHandler("CONSORTIA_CREATE", request, function (response)
        self:unionResponse(response, success)
        app:getClient():refreshForce()
        --通知工会技能战力变化
        if remote.user.userConsortiaSkill and #remote.user.userConsortiaSkill >=1 then
            --战力发生变化 拉取战力变化
            -- app:getClient():refreshForce()
            QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QNotificationCenter.UNION_SKILL_CHANGE})
        end
    end, function (response)
        self:unionResponse(response, nil, fail)
    end)
end

-- 查找宗门
function QUnion:unionSearchRequest(key, success, fail, status)
    local consortiaSearchRequest = {key = key}
    local request = {api = "CONSORTIA_SEARCH", consortiaSearchRequest = consortiaSearchRequest}
    app:getClient():requestPackageHandler("CONSORTIA_SEARCH", request, function (response)
        self:unionResponse(response, success)
    end, function (response)
        self:unionResponse(response, nil, fail)
    end,nil,nil,false)
end

-- 查询宗门
function QUnion:unionGetRequest(consortiaId, success, fail, status)
    local consortiaGetRequest = {consortiaId = consortiaId}
    local request = {api = "CONSORTIA_GET", consortiaGetRequest = consortiaGetRequest}
    app:getClient():requestPackageHandler("CONSORTIA_GET", request, success, fail)
end

-- 查询本宗门
function QUnion:unionOpenRequest(success, fail, status)
    local request = {api = "CONSORTIA_OPEN"}
    local isHavaUnion = remote.user.userConsortia.consortiaName and true or false

    app:getClient():requestPackageHandler("CONSORTIA_OPEN", request, function (response)
        self:unionResponse(response, success)
        app:getClient():refreshForce()
        if not isHavaUnion and remote.user.userConsortiaSkill and #remote.user.userConsortiaSkill >=1 then 
            --战力发生变化 拉取战力变化
            -- app:getClient():refreshForce()    
            QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QNotificationCenter.UNION_SKILL_CHANGE})  
        end
    end, function (response)
        self:unionResponse(response, nil, fail)
    end)
end

-- 查询本宗门成员列表
function QUnion:unionMemberListRequest(success, fail, status)
    local request = {api = "CONSORTIA_MEMBER_LIST"}
    app:getClient():requestPackageHandler("CONSORTIA_MEMBER_LIST", request, function (response)
        self:unionResponse(response, success)
    end, function (response)
        self:unionResponse(response, nil, fail)
    end)
end

-- 查询本宗门成员详细信息
function QUnion:unionMemberGetRequest(userId, success, fail, status)
    local consortiaMemberGetRequest = {userId = userId}
    local request = {api = "CONSORTIA_MEMBER_GET", consortiaMemberGetRequest = consortiaMemberGetRequest}
    app:getClient():requestPackageHandler("CONSORTIA_MEMBER_GET", request, function (response)
        self:unionResponse(response, success)
    end, function (response)
        self:unionResponse(response, nil, fail)
    end)
end

-- 申请加入宗门
function QUnion:unionApplyRequest(consortiaId, success, fail, status)
    local userConsortiaApplyRequest = {consortiaId = consortiaId}
    local request = {api = "CONSORTIA_APPLY", userConsortiaApplyRequest = userConsortiaApplyRequest}
    app:getClient():requestPackageHandler("CONSORTIA_APPLY", request, function (response)
        self:unionResponse(response, success)
    end, function (response)
        self:unionResponse(response, nil, fail)
    end)
end

-- 撤销申请加入宗门
function QUnion:unionApplyCancelRequest(consortiaId, success, fail, status)
    local consortiaApplyCancelRequest = {consortiaId = consortiaId}
    local request = {api = "CONSORTIA_APPLY_CANCEL", consortiaApplyCancelRequest = consortiaApplyCancelRequest}
    app:getClient():requestPackageHandler("CONSORTIA_APPLY_CANCEL", request, function (response)
        self:unionResponse(response, success)
    end, function (response)
        self:unionResponse(response, nil, fail)
    end)
end

-- 主动离开宗门
function QUnion:unionAutoLeaveRequest(success, fail, status)
    local request = {api = "CONSORTIA_AUTO_LEAVE"}
    app:getClient():requestPackageHandler("CONSORTIA_AUTO_LEAVE", request, function (response)
        self:unionResponse(response, success)
    end, function (response)
        self:unionResponse(response, nil, fail)
    end)
end

-- 让玩家离开宗门
function QUnion:unionKickLeaveRequest(userId, success, fail, status)
    local consortiaKickLeaveRequest = {userId = userId}
    local request = {api = "CONSORTIA_KICK_LEAVE", consortiaKickLeaveRequest = consortiaKickLeaveRequest}
    app:getClient():requestPackageHandler("CONSORTIA_KICK_LEAVE", request, function (response)
        self:unionResponse(response, success)
    end, function (response)
        self:unionResponse(response, nil, fail)
    end)
end

-- 修改宗门准入等级
function QUnion:unionChangeLevelRequest(level, success, fail, status)
    local consortiaApplyLevelUpdateRequest = {level = level}
    local request = {api = "CONSORTIA_APPLY_LEVEL_UPDATE", consortiaApplyLevelUpdateRequest = consortiaApplyLevelUpdateRequest}
    app:getClient():requestPackageHandler("CONSORTIA_APPLY_LEVEL_UPDATE", request, function (response)
        self:unionResponse(response, success)
    end, function (response)
        self:unionResponse(response, nil, fail)
    end)
end

-- 宗门申请列表
function QUnion:unionApplyListRequest(success, fail, status)
    local request = {api = "CONSORTIA_APPLY_LIST"}
    app:getClient():requestPackageHandler("CONSORTIA_APPLY_LIST", request, function (response)
        self:unionResponse(response, success)
    end, function (response)
        self:unionResponse(response, nil, fail)
    end)
end

-- 批准拒绝申请
function QUnion:unionApproveRequest(userId, flag, success, fail, status)
    local consortiaApplyRatifyRequest = {userId = userId, flage = flag}
    local request = {api = "CONSORTIA_APPLY_RATIFY", consortiaApplyRatifyRequest = consortiaApplyRatifyRequest}
    app:getClient():requestPackageHandler("CONSORTIA_APPLY_RATIFY", request, function (response)
        self:unionResponse(response, success)
    end, function (response)
        self:unionResponse(response, nil, fail)
    end)
end

-- 修改公告 宣言
function QUnion:unionChangeNoticeRequest(notice, success, fail, status)
    local consortiaNoticeUpdateRequest = {notice = notice}
    local request = {api = "CONSORTIA_NOTICE_UPDATE", consortiaNoticeUpdateRequest = consortiaNoticeUpdateRequest}
    app:getClient():requestPackageHandler("CONSORTIA_NOTICE_UPDATE", request, function (response)
        self:unionResponse(response, success)
    end, function (response)
        self:unionResponse(response, nil, fail)
    end)
end

-- 解散宗门
function QUnion:unionDismissRequest(success, fail, status)
    local request = {api = "CONSORTIA_DISMISS"}
    app:getClient():requestPackageHandler("CONSORTIA_DISMISS", request, function (response)
        self:unionResponse(response, success)
    end, function (response)
        self:unionResponse(response, nil, fail)
    end)
end

-- 宗门日志
function QUnion:unionLogRequest(success, fail, status)
    local request = {api = "CONSORTIA_LOG_LIST"}
    app:getClient():requestPackageHandler("CONSORTIA_LOG_LIST", request, function (response)
        self:unionResponse(response, success)
    end, function (response)
        self:unionResponse(response, nil, fail)
    end)
end

-- 设置权限
function QUnion:unionRoleUpdateRequest(userId, role, success, fail, status)
    local consortiaRankUpdateRequest = {userId = userId, rank = role}
    local request = {api = "CONSORTIA_RANK_UPDATE", consortiaRankUpdateRequest = consortiaRankUpdateRequest}
    app:getClient():requestPackageHandler("CONSORTIA_RANK_UPDATE", request, function (response)
        self:unionResponse(response, success)
    end, function (response)
        self:unionResponse(response, nil, fail)
    end)
end

-- 宗门邮件
function QUnion:unionMailRequest(title, content, success, fail, status)
    local consortiaMailSendRequest = {title = title, content = content}
    local request = {api = "CONSORTIA_MAIL_SEND", consortiaMailSendRequest = consortiaMailSendRequest}
    app:getClient():requestPackageHandler("CONSORTIA_MAIL_SEND", request, function (response)
        self:unionResponse(response, success)
    end, function (response)
        self:unionResponse(response, nil, fail)
    end)
end

-- 宗门个人邮件
function QUnion:unionMemberMailRequest(userId, title, content, success, fail, status)
    local consortiaPersonalMailSendRequest = {userId = userId, title = title, content = content}
    local request = {api = "CONSORTIA_PERSONAL_MAIL_SEND", consortiaPersonalMailSendRequest = consortiaPersonalMailSendRequest}
    app:getClient():requestPackageHandler("CONSORTIA_PERSONAL_MAIL_SEND", request, function (response)
        self:unionResponse(response, success)
    end, function (response)
        self:unionResponse(response, nil, fail)
    end)
end

-- 宗门建设
-- optional int32 type                            = 1;                        // 祭祀类型（1普通，2高级，3神赐）
-- optional bool  isSecretary  = 2;                                           // 是否是小秘书
function QUnion:unionFeteRequest(type, isSecretary, success, fail, status)
    local consortiaSacrificeRequest = {type = type, isSecretary = isSecretary}
    local request = {api = "CONSORTIA_SACRIFICE", consortiaSacrificeRequest = consortiaSacrificeRequest}
    app:getClient():requestPackageHandler("CONSORTIA_SACRIFICE", request, function (response)
        self:unionResponse(response, success)
    end, function (response)
        self:unionResponse(response, nil, fail)
    end)
end

-- 领取宗门建设奖励
-- repeated int32 drawNo                     = 1;                             // 开启的序号(祭祀度从低到高 1，2，3，4)
-- optional bool  isSecretary  = 2;                                           // 是否是小秘书
function QUnion:unionFeteRewardRequest(type, isSecretary, success, fail, status)
    local luckyDrawConsortiaSacrificeRequest = {drawNo = type, isSecretary = isSecretary}
    local request = {api = "LUCKY_DRAW_CONSORTIA_SACRIFICE", luckyDrawConsortiaSacrificeRequest = luckyDrawConsortiaSacrificeRequest}
    app:getClient():requestPackageHandler("LUCKY_DRAW_CONSORTIA_SACRIFICE", request, function (response)
        self:unionResponse(response, success)
    end, function (response)
        self:unionResponse(response, nil, fail)
    end)
end

-- 领取宗门升级奖励
function QUnion:unionFeteLevelUpRewardRequest(level, success, fail, status)
    local luckyDrawConsortiaLevelRequest = {level = level}
    local request = {api = "LUCKY_DRAW_CONSORTIA_LEVEL", luckyDrawConsortiaLevelRequest = luckyDrawConsortiaLevelRequest}
    app:getClient():requestPackageHandler("LUCKY_DRAW_CONSORTIA_LEVEL", request, function (response)
        self:unionResponse(response, success)
    end, function (response)
        self:unionResponse(response, nil, fail)
    end)
end

-- 宗门设置
function QUnion:unionUpdateSettingRequest(level, authorize, name, icon,limitForce,success, fail, status)
    local consortiaRuleUpdateRequest = {level = level, authorize = authorize, name = name, icon = icon,power = limitForce }
    local request = {api = "CONSORTIA_RULE_UPDATE", consortiaRuleUpdateRequest = consortiaRuleUpdateRequest}
    app:getClient():requestPackageHandler("CONSORTIA_RULE_UPDATE", request, function (response)
        self:unionResponse(response, success)
    end, function (response)
        self:unionResponse(response, nil, fail)
    end)
end

--七日建设
function QUnion:unionFeteRankRequest(success, fail, status)
    local request = {api = "CONSORTIA_SEVEN_DAYS_SACRIFICE_RANK"}
    app:getClient():requestPackageHandler("CONSORTIA_SEVEN_DAYS_SACRIFICE_RANK", request, function (response)
        self:unionResponse(response, success)
    end, function (response)
        self:unionResponse(response, nil, fail)
    end)
end

--最后上线时间
function QUnion:unionLastLoginRankRequest(success, fail, status)
    local request = {api = "CONSORTIA_UPDATED_AT_RANK"}
    app:getClient():requestPackageHandler("CONSORTIA_UPDATED_AT_RANK", request, function (response)
        self:unionResponse(response, success)
    end, function (response)
        self:unionResponse(response, nil, fail)
    end)
end


--工会一键加入
function QUnion:unionOneKeyEnterRequest(success, fail, status)
    local request = {api = "CONSORTIA_QUICK_ENTER"}
    app:getClient():requestPackageHandler("CONSORTIA_QUICK_ENTER", request, function (response)
        self:unionResponse(response, success)
    end, function (response)
        self:unionResponse(response, nil, fail)
    end)
end

-- 弹劾宗主
function QUnion:unionImpeachRequest( success, fail )
    local request = {api = "CONSORTIA_IMPEACH"}
    app:getClient():requestPackageHandler("CONSORTIA_IMPEACH", request, function (response)
        self:unionResponse(response, success)
    end, function (response)
        self:unionResponse(response, nil, fail)
    end)
end


-- 弹劾宗主
function QUnion:unionInfoRequest( success, fail )
    local request = {api = "GET_SELF_CONSORTIA"}
    app:getClient():requestPackageHandler("GET_SELF_CONSORTIA", request, function (response)
        self:unionResponse(response, success)
    end, function (response)
        self:unionResponse(response, nil, fail)
    end)
end
--升级技能
function QUnion:unionSkillLevelUpRequest( skillId, success, fail )
    local consortiaSkillLevelUpRequest = {skillId = skillId}
    local request = {api = "CONSORTIA_SKILL_LEVEL_UP",consortiaSkillLevelUpRequest = consortiaSkillLevelUpRequest}
    app:getClient():requestPackageHandler("CONSORTIA_SKILL_LEVEL_UP", request, function (response)
        self:unionResponse(response, success)
    end, function (response)
        self:unionResponse(response, nil, fail)
    end)
end
--升级技能上限
function QUnion:unionSkillLimitLevelUpRequest( skillId, success, fail )
    local consortiaSkillMaximumLevelUpRequest = {skillId = skillId}
    local request = {api = "CONSORTIA_SKILL_MAXIMUM_LEVEL_UP",consortiaSkillMaximumLevelUpRequest = consortiaSkillMaximumLevelUpRequest}
    app:getClient():requestPackageHandler("CONSORTIA_SKILL_MAXIMUM_LEVEL_UP", request, function (response)
        self:unionResponse(response, success)
    end, function (response)
        self:unionResponse(response, nil, fail)
    end)
end
--拉取公告牌 界面数据
function QUnion:unionNotifyBoardRequest(success, fail )
    local request = {api = "CONSORTIA_GET_BILLBOARD"}
    app:getClient():requestPackageHandler("CONSORTIA_GET_BILLBOARD", request, function (response)
        self:unionResponse(response, success)
    end, function (response)
        self:unionResponse(response, nil, fail)
    end)
end

--留言
function QUnion:unionLeaveMessageRequest( str, success, fail )
    local consortiaLeaveMessageRequest = {content = str}
    local request = {api = "CONSORTIA_LEAVE_MESSAGE",consortiaLeaveMessageRequest = consortiaLeaveMessageRequest}
    app:getClient():requestPackageHandler("CONSORTIA_LEAVE_MESSAGE", request, function (response)
        self:unionResponse(response, success)
    end, function (response)
        self:unionResponse(response, nil, fail)
    end)
end

--留言置顶
function QUnion:unionMessageSetTopRequest( str, success, fail )
    local consortiaSetTopRequest = {messageId = str}
    local request = {api = "CONSORTIA_SET_TOP",consortiaSetTopRequest = consortiaSetTopRequest}
    app:getClient():requestPackageHandler("CONSORTIA_SET_TOP", request, function (response)
        self:unionResponse(response, success)
    end, function (response)
        self:unionResponse(response, nil, fail)
    end)
end

--删除留言
function QUnion:unionMessageDeleteRequest( str, success, fail )
    local consortiaDelMessageRequest = {messageId = str}
    local request = {api = "CONSORTIA_DEL_MESSAGE",consortiaDelMessageRequest = consortiaDelMessageRequest}
    app:getClient():requestPackageHandler("CONSORTIA_DEL_MESSAGE", request, function (response)
        self:unionResponse(response, success)
    end, function (response)
        self:unionResponse(response, nil, fail)
    end)
end

--宗门公告修改
function QUnion:unionChangeAnnouncementRequest( str, success, fail )
    local consortiaMainMessageUpdateRequest = {mainMessage = str}
    local request = {api = "CONSORTIA_MAIN_MESSAGE_UPDATE",consortiaMainMessageUpdateRequest = consortiaMainMessageUpdateRequest}
    app:getClient():requestPackageHandler("CONSORTIA_MAIN_MESSAGE_UPDATE", request, function (response)
        self:unionResponse(response, success)
    end, function (response)
        self:unionResponse(response, nil, fail)
    end)
end

--群发邮件
function QUnion:unionSendMassMailRequest( str, mailType, success, fail )
    local consortiaSendGroupMailRequest = {content = str, mailType = "3"}
    local request = {api = "CONSORTIA_SEND_GROUP_MAIL",consortiaSendGroupMailRequest = consortiaSendGroupMailRequest}
    app:getClient():requestPackageHandler("CONSORTIA_SEND_GROUP_MAIL", request, function (response)
        app.tip:floatTip("发送成功")
        self:unionResponse(response, success)
    end, function (response)
        self:unionResponse(response, nil, fail)
    end)
end

-- 拉取宗门BOSS信息
function QUnion:unionGetBossListRequest(success, fail, status)

    if remote.union:checkHaveUnion() == false then
        return
    end

    local request = {api = "CONSORTIA_GET_BOSS_LIST"}
    app:getClient():requestPackageHandler("CONSORTIA_GET_BOSS_LIST", request, function (response)
        self:unionResponse(response, success)
    end, function (response)
        self:unionResponse(response, nil, fail)
    end)
end

-- 设置宗门副本重置信息
function QUnion:unionSetBossResetTypeRequest(resetType, success, fail, status)
    local consortiaSetBossResetTypeRequest = { resetType = resetType }
    local request = { api = "CONSORTIA_SET_BOSS_RESET_TYPE",consortiaSetBossResetTypeRequest = consortiaSetBossResetTypeRequest }
    app:getClient():requestPackageHandler("CONSORTIA_SET_BOSS_RESET_TYPE", request, function (response)
        self:unionResponse(response, success)
    end, function (response)
        self:unionResponse(response, nil, fail)
    end)
end

-- 购买宗门副本的挑战次数
-- optional int32 buyCount                     = 1;                        // 购买次数
-- optional bool  isSecretary                  = 2;                        // 是否是小秘书
function QUnion:unionBuyFightCountRequest(buyCount, isSecretary, success, fail, status)
    local consortiaBossBuyFightCountRequest = {buyCount = buyCount, isSecretary = isSecretary}
    local request = { api = "CONSORTIA_BUY_BOSS_FIGHT_COUNT", consortiaBossBuyFightCountRequest = consortiaBossBuyFightCountRequest }
    app:getClient():requestPackageHandler("CONSORTIA_BUY_BOSS_FIGHT_COUNT", request, function (response)
        self:unionResponse(response, success)
    end, function (response)
        self:unionResponse(response, nil, fail)
    end)
end

-- 宗门副本领取boss宝箱
function QUnion:unionGetWaveRewardRequest(wave, boxId, chapter, success, fail, status)
    local consortiaGetWaveRewardRequest = { wave = wave, boxId = boxId, chapter = chapter }
    local request = { api = "CONSORTIA_GET_WAVE_REWARD",consortiaGetWaveRewardRequest = consortiaGetWaveRewardRequest }
    app:getClient():requestPackageHandler("CONSORTIA_GET_WAVE_REWARD", request, function (response)
        self:unionResponse(response, success)
    end, function (response)
        self:unionResponse(response, nil, fail)
    end)
end
-- 宗门副本一键开箱
-- optional bool  isSecretary                    = 1;                        // 是否是小秘书
function QUnion:unionBossGetAllWaveRewardRequest(isSecretary, success, fail, status)
    local consortiaGetAllWaveRewardRequest = {isSecretary = isSecretary}
    local request = { api = "CONSORTIA_BOOS_GET_ALL_WAVE_REWARD", consortiaGetAllWaveRewardRequest = consortiaGetAllWaveRewardRequest}
    app:getClient():requestPackageHandler("CONSORTIA_BOOS_GET_ALL_WAVE_REWARD", request, function (response)
        self:unionResponse(response, success)
    end, function (response)
        self:unionResponse(response, nil, fail)
    end)
end

-- 宗门副本领取通关奖励
function QUnion:unionGetChapterRewardRequest(chapter, success, fail, status)
    local consortiaGetChapterRewardRequest = { chapter = chapter }
    local request = { api = "CONSORTIA_GET_CHAPTER_REWARD",consortiaGetChapterRewardRequest = consortiaGetChapterRewardRequest }
    app:getClient():requestPackageHandler("CONSORTIA_GET_CHAPTER_REWARD", request, function (response)
        self:unionResponse(response, success)
    end, function (response)
        self:unionResponse(response, nil, fail)
    end)
end



-- 宗门副本战斗开始
function QUnion:unionFightStartRequest(wave, chapter, battleFormation, success, fail, status)
    local consortiaFightStartRequest = { wave = wave, chapter = chapter }
    local gfStartRequest = {battleType = BattleTypeEnum.CONSORTIA_BOSS, battleFormation = battleFormation, consortiaFightStartRequest = consortiaFightStartRequest}
    local request = {api = "GLOBAL_FIGHT_START", gfStartRequest = gfStartRequest}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_START", request, function (response)
        self:unionResponse(response, success)
    end, function (response)
        self:unionResponse(response, nil, fail)
    end)
end

-- 宗门副本战斗结束 普通版
function QUnion:unionFightEndRequest(wave, bossHp, battleVerify, chapter, success, fail, status)
    local consortiaFightEndRequest = { wave = wave, bossHp = bossHp, battleVerify = battleVerify, chapter = chapter }
    local content = readFromBinaryFile("last.reppb")
    local battleVerify = q.battleVerifyHandler(battleVerify)

    local fightReportData = crypto.encodeBase64(content)
    local gfEndRequest = {battleType = BattleTypeEnum.CONSORTIA_BOSS, battleVerify = battleVerify, isQuick = false, isWin = nil,
     fightReportData = fightReportData, consortiaFightEndRequest = consortiaFightEndRequest}
    local request = { api = "GLOBAL_FIGHT_END",gfEndRequest = gfEndRequest}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_END", request, function (response)
        remote.activity:updateLocalDataByType(718, 1)
        self:unionResponse(response, success)
    end, function (response)
        self:unionResponse(response, nil, fail)
    end)
end

-- 宗门副本战斗结束 扫荡版
-- required int32 wave                           = 1;                        // 关卡ID
-- required int32 chapter                        = 2;                        // 章节ID
-- optional int32 fightCount                     = 3;                        // 扫荡次数
-- optional bool  isSecretary                    = 4;                        // 是否是小秘书
function QUnion:unionQuickFightEndRequest(wave, chapter, fightCount, isSecretary, battleVerify, success, fail, status)
    local consortiaBossQuickFightRequest = { wave = wave, chapter = chapter, fightCount = fightCount, isSecretary = isSecretary }
    local content = readFromBinaryFile("last.reppb")
    local battleVerify = q.battleVerifyHandler(battleVerify)

    local fightReportData = crypto.encodeBase64(content)
    local gfEndRequest = {battleType = BattleTypeEnum.CONSORTIA_BOSS, battleVerify = battleVerify, isQuick = true, isWin = nil,
     fightReportData = fightReportData, consortiaBossQuickFightRequest = consortiaBossQuickFightRequest}
    local request = { api = "GLOBAL_FIGHT_END", gfEndRequest = gfEndRequest}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_END", request, function (response)
        remote.activity:updateLocalDataByType(718, fightCount)
        self:unionResponse(response, success)
    end, function (response)
        self:unionResponse(response, nil, fail)
    end)
end

-- 公会设置集火目标
-- required bool isReset                         = 1;                         // true:重置激活目标 false:添加或者修改激活目标
-- optional int32 wave                           = 2;                         // 关卡ID
-- optional int32 chapter                        = 3;                         // 章节ID
function QUnion:consortiaBossSetFocusedGoalRequest(isReset, wave, chapter, success, fail, status)
    local consortiaBossSetFocusedGoalRequest = { isReset = isReset, wave = wave, chapter = chapter }
    local request = { api = "CONSORTIA_BOSS_SET_FOCUSED_GOAL" ,consortiaBossSetFocusedGoalRequest = consortiaBossSetFocusedGoalRequest }
    app:getClient():requestPackageHandler("CONSORTIA_BOSS_SET_FOCUSED_GOAL", request, function (response)
        self:unionResponse(response, success)
    end, function (response)
        self:unionResponse(response, nil, fail)
    end)
end

-- 宗门建设信息拉取
function QUnion:getUnionSacrificeInfoRequest(success, fail, status)
    local request = { api = "CONSORTIA_SACRIFICE_MEMBER_LIST"}
    app:getClient():requestPackageHandler("CONSORTIA_SACRIFICE_MEMBER_LIST", request, function (response)
        self:unionResponse(response, success)
    end, function (response)
        self:unionResponse(response, nil, fail)
    end)
end

-- // 获取公会活跃排行榜
function QUnion:consortiaGetMemberActiveListRequest(success, fail, status)
    local request = { api = "CONSORTIA_MEMBER_ACITVE_LIST" }
    app:getClient():requestPackageHandler("CONSORTIA_MEMBER_ACITVE_LIST", request, function (response)
        self:unionResponse(response, success)
    end, function (response)
        self:unionResponse(response, nil, fail)
    end)
end

-- // 获取目标人物周活跃信息 参考参数 ConsortiaGetTargetUserActiveInfoRequest ConsortiaGetTargetUserActiveInfoResponse
-- optional string userId = 1;                             // 玩家id
function QUnion:consortiaGetTargetUserActiveInfoRequest(userId, success, fail, status)
    local consortiaGetTargetUserActiveInfoRequest = { userId = userId }
    local request = { api = "CONSORTIA_GET_TARGET_USER_ACTIVE", consortiaGetTargetUserActiveInfoRequest = consortiaGetTargetUserActiveInfoRequest}
    app:getClient():requestPackageHandler("CONSORTIA_GET_TARGET_USER_ACTIVE", request, function (response)
        self:unionResponse(response, success)
    end, function (response)
        self:unionResponse(response, nil, fail)
    end)
end

function QUnion:handleUnionPush( data )
    if data.op_type == "CONSORTIA_RANK_UPDATE" then
        local rank = tonumber(data.vale) 
        if rank then
            local oldRank = remote.user.userConsortia.rank
            remote.user.userConsortia.rank = rank
            QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QNotificationCenter.UNION_JOB_CHANGE,oldRank = oldRank, newRank = rank})
        end
    elseif data.op_type == "CONSORTIA_KICK" then
        remote.user:update({userConsortia = {}})
        self:resetUnionData()
        QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QNotificationCenter.UNION_CONSORTIA_KICKED})
    elseif data.op_type == "CONSORTIA_APPLY_RATIFY" then
        self:unionOpenRequest(function()
                QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QNotificationCenter.UNION_CONSORTIA_APPLY_RATIFY})
            end)
    elseif data.op_type == "CONSORTIA_APPLY_NOT_EXISTS" then
        remote.mark:cleanMark(remote.mark.MARK_CONSORTIA_APPLY) 
    elseif data.op_type == "CONSORTIA_APPLY_EXISTS" then
        remote.mark:analysisMark(remote.mark.MARK_CONSORTIA_APPLY) 
    elseif data.op_type == "CONSORTIA_BOSS_DEAD" then
        if self._isInBattle then
            for _, value in pairs(self:getConsortiaBossList(self._inBattleChapter)) do
                if tonumber(value.wave) == tonumber(data.vale) then
                    value.bossHp = 0
                end
            end
            if tonumber(self._inBattleWave) == tonumber(data.vale) then
                return 
            end
        end
        -- print("QUnion:handleUnionPush()", self._isInBattle, self._inBattleWave, data.vale)
        self:unionGetBossListRequest(function()
                self:dispatchEvent({ name = QUnion.SOCIETY_BOSS_DEAD })
            end)
    end
end


function QUnion:getUnionSkillDescribe( skillConfig )
    if type(skillConfig) ~= "table" then
        return
    end
    local str = ""
    local isFirst = true
    for name,filed in pairs(QActorProp._field) do
        if skillConfig[name] ~= nil then
            str = str..skillConfig.skill_name.."+"..skillConfig[name]
            if isFirst then
                isFirst = false
            else
                str = str..";"
            end
        end
    end
    return str
end

function QUnion:getUnionSkillProp( consortiaSkillList )
    local unionSkillProp = {}
    if consortiaSkillList then
        --计算他人战斗力
        for k,v in pairs(consortiaSkillList) do
            local curConfig = QStaticDatabase.sharedDatabase():getUnionSkillConfigByLevel(v.skillId, v.skillLevel)
            if curConfig then
                for name,filed in pairs(QActorProp._field) do
                    if curConfig[name] ~= nil then
                        if unionSkillProp[name] == nil then
                            unionSkillProp[name] = curConfig[name]
                        else
                            unionSkillProp[name] = curConfig[name] + unionSkillProp[name]
                        end
                    end
                end
            end
        end
    else
        if remote.user.userConsortia and remote.user.userConsortia.consortiaId and remote.user.userConsortia.consortiaId ~= "" then
             --计算自己
            for k,v in pairs(remote.user.userConsortiaSkill or {} ) do
                local curConfig = QStaticDatabase.sharedDatabase():getUnionSkillConfigByLevel(v.skillId, v.skillLevel)
                if curConfig then
                    for name,filed in pairs(QActorProp._field) do
                        if curConfig[name] ~= nil then
                            if unionSkillProp[name] == nil then
                                unionSkillProp[name] = curConfig[name]
                            else
                                unionSkillProp[name] = curConfig[name] + unionSkillProp[name]
                            end
                        end
                    end
                end
            end
        end
    end
    return unionSkillProp 
end

function QUnion:getConsortiaBossList(chapter)
    if chapter == nil then return nil end


    local bossList = {}
    local config = self._consortiaBossList[chapter] or {}
    for _, value in ipairs(config) do
        local config = self:getSocietyDataByChapterAndWave(value.chapter, value.wave)
        if config.endless_level ~= QUnion.FINAL_DUNGEON_BOSS_TYPE then
            table.insert(bossList, value)
        end
    end
    return bossList
end


function QUnion:setConsortiaBossSpecAward(items)
    self._consortiaBossSpecAward = items
end

function QUnion:getConsortiaBossSpecAward()
    return self._consortiaBossSpecAward 

end

function QUnion:getConsortiaFinalBossInfo()
    local bossInfo = {}
    local bossConfig = self:getSocietyDataByChapterAndWave(QUnion.DUNGEON_MAX_CHAPTER, QUnion.DUNGEON_MAX_WAVE)
    local config = self._consortiaBossList[QUnion.DUNGEON_MAX_CHAPTER] or {}
    for _, value in ipairs(config) do
        local config = self:getSocietyDataByChapterAndWave(value.chapter, value.wave)
        if config.endless_level == QUnion.FINAL_DUNGEON_BOSS_TYPE then
            bossInfo = value
        end
    end

    return bossInfo, bossConfig
end

function QUnion:getBossHpByChapterAndWave(chapter, wave)
    if self._consortiaBossList then
        local bossList = self:getConsortiaBossList(chapter)
        if bossList then
            for _, boss in ipairs(bossList) do
                if boss.wave == wave then
                    return boss.bossHp
                end
            end
        end
    end

    return nil
end

function QUnion:getFightChapter()
    return self._fightChapter
end

function QUnion:setShowChapter(chapter)
    self._showChapter = chapter
end

function QUnion:getShowChapter()
    return self._showChapter
end

function QUnion:getMinChapter()
    return self._minChapter
end

function QUnion:setFightWave(wave)
    self._fightWave = wave
end

function QUnion:getFightWave()
    return self._fightWave
end

function QUnion:resetSocietyDungeonData()
    self._consortiaBossList = {} -- 宗门副本BOSS列表
    self._fightChapter = 0 -- 宗门副本战斗中的章节
    self._showChapter = 0 -- 宗门副本展示在当前页面的章节
    self._minChapter = 99999999 -- 宗门副本当天可以返回到的最小的章节
    self._fightWave = 0 --记录个人正在击杀的BOSS的wave，进入战斗准备的时候记录
end

function QUnion:sendBuyFightCountSuccess()
    self:dispatchEvent({ name = QUnion.SOCIETY_BUY_FIGHT_COUNT_SUCCESS })
end

function QUnion:sendReceivedAwardSuccess()
    self:dispatchEvent({ name = QUnion.SOCIETY_RECEIVED_AWARD_SUCCESS })
end

function QUnion:sendReceivedChestSuccess()
    self:dispatchEvent({ name = QUnion.SOCIETY_RECEIVED_CHEST_SUCCESS })
end

function QUnion:newDayUpdate()
    self.unionActive:updateActiveInfo()

    if (remote.user.userConsortia and not remote.user.userConsortia.consortiaId or remote.user.userConsortia.consortiaId == "") 
        or not ENABLE_UNION_DUNGEON 
        or (self.consortia and self.consortia.level < self._societyNeedLevel) then return end
    self:resetSocietyDungeonData()
    self:unionGetBossListRequest(function()
            self:dispatchEvent( { name = QUnion.NEW_DAY } )
        end)
end

function QUnion:_analyseConsortiaConfiguration()
    local time = QStaticDatabase.sharedDatabase():getConfigurationValue("GONGHUIFUBEN_SHIJIANDUAN")
    local str = string.gsub(time, ":00", "")
    local tbl = string.split(str, "-")
    self._societyDungeonStartTime = tonumber(tbl[1]) or 10
    self._societyDungeonEndTime = tonumber(tbl[2]) or 24
    self._societyCount = QStaticDatabase.sharedDatabase():getConfigurationValue("GONGHUIFUBEN_CISHU") or 3
    self._societyCD = QStaticDatabase.sharedDatabase():getConfigurationValue("GONGHUIFUBEN_CISHU_CD") or 2
    self._societyNeedLevel = QStaticDatabase.sharedDatabase():getConfigurationValue("GONGHUIFUBEN") or 2
end

function QUnion:getSocietyDungeonStartTime()
    return self._societyDungeonStartTime
end

function QUnion:getSocietyDungeonEndTime()
    return self._societyDungeonEndTime
end

function QUnion:getSocietyCount()
    local config = app.unlock:getConfigByKey("UNLOCK_ZONGMENFUBEN_CD")
    if remote.user.dailyTeamLevel < config.team_level then
        return self._societyCount
    else
        return self._fightDefaultCount
    end
end

function QUnion:getSocietyFreeCount()
    local startTime = self:getSocietyDungeonStartTime()
    local endTime = self:getSocietyDungeonEndTime()
    local cd = self:getSocietyCD()
    local freeCount = self:getSocietyCount()
    local config = app.unlock:getConfigByKey("UNLOCK_ZONGMENFUBEN_CD")
    if remote.user.dailyTeamLevel < config.team_level then
        freeCount = freeCount + math.floor((endTime - startTime)/cd)
    end

    return freeCount
end

function QUnion:getSocietyCD()
    return self._societyCD
end

function QUnion:getSocietyNeedLevel()
    return self._societyNeedLevel
end

-- 宗门权限
function QUnion:checkUnionRight()
    if self:checkPositiveRight() then
        return true
    end
    if self:checkDeputyRight() then
        return true
    end
    return false
end

-- 宗主权限
function QUnion:checkPositiveRight()
    if not remote.user.userConsortia then
        return false
    end
    local rank = remote.user.userConsortia.rank or 0
    return rank == SOCIETY_OFFICIAL_POSITION.BOSS
end

-- 副宗主权限
function QUnion:checkDeputyRight()
    if not remote.user.userConsortia then
        return false
    end
    local rank = remote.user.userConsortia.rank or 0
    return rank == SOCIETY_OFFICIAL_POSITION.ADJUTANT
end

-- 副宗主限时权限
function QUnion:checkDeputyLimitRight()
    if not remote.user.userConsortia then
        return false
    end
    local rank = remote.user.userConsortia.rank or 0
    if rank == SOCIETY_OFFICIAL_POSITION.ADJUTANT then
        local leaderOffLineAt = (self.consortia.leaderOffLineAt or 0)/1000
        if q.serverTime() >= leaderOffLineAt + 3*DAY then
            return true
        end
    end
    return false
end

-- 副宗主限时权限提示
function QUnion:checkDeputyLimitRightTips()
    if not remote.user.userConsortia then
        return false
    end
    local rank = remote.user.userConsortia.rank or 0
    if rank ~= SOCIETY_OFFICIAL_POSITION.ADJUTANT then
        return false
    end
    local oldRight = app:getUserOperateRecord():getRecordByType(QUnion.DEPUTY_RIGHT_TIPS)
    local newRight = self:checkDeputyLimitRight()
    if oldRight == nil then
        if newRight == true then
            app:getUserOperateRecord():setRecordByType(QUnion.DEPUTY_RIGHT_TIPS, newRight)
            return true, newRight
        end
    elseif oldRight ~= newRight then
        app:getUserOperateRecord():setRecordByType(QUnion.DEPUTY_RIGHT_TIPS, newRight)
        return true, newRight
    end
    return false
end

-- 免费钻石红包提示
function QUnion:checkFreeTokenRedPacketTips()
    if not remote.user.userConsortia then
        return false
    end

    local redPacketTips = remote.redpacket:checkRedpacketSendRedTip()
    local isNewDay = app:getUserOperateRecord():checkNewDayCompareWithRecordeTime(QUnion.FREE_TOKEN_REDPACKET_TIPS, 5) or false
    if redPacketTips and isNewDay then
        app:getUserOperateRecord():recordeCurrentTime(QUnion.FREE_TOKEN_REDPACKET_TIPS)
        return true
    end
    return false
end

function QUnion:setSocietyDungeonFightInfo(isInBattle, wave, chapter)
    self._isInBattle = isInBattle
    self._inBattleWave = wave
    self._inBattleChapter = chapter
end

function QUnion:getSocietyDungeonFightInfo()
    return self._isInBattle, self._inBattleWave, self._inBattleChapter
end

function QUnion:analyseAwards(wave, chapter)
    local tbl = {}
    local awardList = {}
    local scoietyWaveConfig = QStaticDatabase.sharedDatabase():getScoietyWave(wave, chapter)
    local a = string.split(scoietyWaveConfig.sociaty_box, ";") -- {id^itemCount:chestCount}
    for _, i in pairs(a) do
        local b = string.split(i, ":") -- {id^itemCount} {chestCount}
        tbl = {}
        for _, j in pairs(b) do
            local s, e = string.find(j, "%^")
            if s then
                local idOrType = string.sub(j, 1, s - 1)
                local itemCount = string.sub(j, e + 1)
                tbl["idOrType"] = idOrType
                tbl["itemCount"] = itemCount
            else
                tbl["chestCount"] = j
            end
        end
        table.insert(awardList, tbl)
    end
    return awardList
end

function QUnion:analyseLuckAwards(wave, chapter)
    local tbl = {}
    local awardList = {}
    local scoietyWaveConfig = QStaticDatabase.sharedDatabase():getScoietyWave(wave, chapter)
    local a = string.split(scoietyWaveConfig.islucky, ";") -- {id^itemCount:chestCount}
    for _, i in pairs(a) do
        local b = string.split(i, ":") -- {id^itemCount} {chestCount}
        tbl = {}
        for _, j in pairs(b) do
            local s, e = string.find(j, "%^")
            if s then
                local idOrType = string.sub(j, 1, s - 1)
                local itemCount = string.sub(j, e + 1)
                tbl["idOrType"] = idOrType
                tbl["itemCount"] = itemCount
            else
                tbl["chestCount"] = j
            end
        end
        table.insert(awardList, tbl)
    end
    return awardList
end

function QUnion:getSocietyUnlockData()
    local fightChapter = self:getFightChapter()
    if not fightChapter or fightChapter < 1 then return {} end

    local config = QStaticDatabase.sharedDatabase():getAllScoietyChapter()
    local tbl = {}
    for _, value in pairs(config) do
        if value[1].chapter <= fightChapter then
            table.insert(tbl, value)
        end
    end

    table.sort(tbl, function(a, b)
            return a[1].chapter < b[1].chapter
        end)
    return tbl
end

function QUnion:getSocietyDataByChapter( chapter )
    if self._dungeonChapterWaveDict == nil then
        local config = QStaticDatabase.sharedDatabase():getAllScoietyChapter()
        self._dungeonChapterWaveDict = {}
        for _, value in pairs(config) do
            for _, v in pairs(value) do
                if self._dungeonChapterWaveDict[v.chapter] == nil then
                    self._dungeonChapterWaveDict[v.chapter] = {}
                end
                self._dungeonChapterWaveDict[v.chapter][v.wave] = v
            end
        end
    end

    return self._dungeonChapterWaveDict[chapter]
end

function QUnion:getSocietyDataByChapterAndWave( chapter, wave )
    local chapterConfig = self:getSocietyDataByChapter(chapter)
    if chapterConfig == nil then return nil end

    return chapterConfig[wave]
end

function QUnion:getTotalBossHpByChapter( chapter )
    local config = QStaticDatabase.sharedDatabase():getScoietyChapter( chapter )
    if not config or table.nums(config) == 0 then return 0 end
    local totalHp = 0
    for _, value in pairs(config) do
        if value.endless_level ~= QUnion.FINAL_DUNGEON_BOSS_TYPE then
            local characterData = QStaticDatabase.sharedDatabase():getCharacterDataByID( value.boss, value.levels )
            totalHp = totalHp + characterData.hp_value + characterData.hp_grow * characterData.npc_level
        end
    end
    
    return totalHp
end

function QUnion:getCurBossHpByChapter( chapter )
    local bossList = self:getConsortiaBossList( chapter )
    if not bossList or table.nums(bossList) == 0 then return 0 end
    local curHp = 0

    local config = self:getSocietyDataByChapter()
    for i, boss in pairs(bossList) do
        local config = self:getSocietyDataByChapterAndWave(boss.chapter, boss.wave)
        if config.endless_level ~= QUnion.FINAL_DUNGEON_BOSS_TYPE then
            curHp = curHp + boss.bossHp
        end
    end

    return curHp
end

function QUnion:hasUnion()
    return not not (remote.user.userConsortia and remote.user.userConsortia.consortiaId and remote.user.userConsortia.consortiaId ~= "")
end

function QUnion:setRecruit( str )
    self.recruit = str
    self.isDefault = false
end

function QUnion:getRecruit()
    local str = ""
    if self.isDefault then
        str = string.format("《%s》%s", self.consortia.name or "", self.recruit)
    else
        str = self.recruit
    end

    return str, self.isDefault
end

function QUnion:dispathExitRobotForSociety()
    self:dispatchEvent({ name = QUnion.SOCIETY_EXIT_ROBOT })
end

function QUnion:isDragonTrainBuff()
    -- local isBuff = false

    -- local _dragonTrainBuffEndAt = 0
    -- if self.consortia.dragon_task_reward_buff_start_at then
    --     local continueDay = tonumber( db:getConfigurationValue("sociaty_dragon_buff_time") )
    --         if continueDay then
    --             _dragonTrainBuffEndAt = self.consortia.dragon_task_reward_buff_start_at + continueDay * DAY * 1000
    --         end
    -- end
    -- if _dragonTrainBuffEndAt and q.serverTime() * 1000 < _dragonTrainBuffEndAt then
    --     isBuff = true
    -- end

    local isBuff , dragonTrainBuffEndAt = self:isDragonTrainBuffAndEndAt()

    return isBuff 

    -- if self.consortia.dragon_task_reward_buff_start_at then
    --     if not self._dragonTrainBuffEndAt or self.consortia.dragon_task_reward_buff_start_at > self._dragonTrainBuffEndAt then
    --         local continueDay = tonumber( db:getConfigurationValue("sociaty_dragon_buff_time") )
    --         if continueDay then
    --             self._dragonTrainBuffEndAt = self.consortia.dragon_task_reward_buff_start_at + continueDay * DAY * 1000
    --         end
    --     end
    -- end
    -- if self._dragonTrainBuffEndAt and q.serverTime() * 1000 < self._dragonTrainBuffEndAt then
    --     isBuff = true
    -- end
    -- return isBuff
end


function QUnion:isDragonTrainBuffAndEndAt()
    local isBuff = false

    local _dragonTrainBuffEndAt = 0
    if self.consortia.dragon_task_reward_buff_start_at then
        local continueDay = tonumber( db:getConfigurationValue("sociaty_dragon_buff_time") )
            if continueDay then
                _dragonTrainBuffEndAt = self.consortia.dragon_task_reward_buff_start_at + continueDay * DAY * 1000
            end
    end
    if _dragonTrainBuffEndAt and q.serverTime() * 1000 < _dragonTrainBuffEndAt then
        isBuff = true
    end
    return isBuff ,_dragonTrainBuffEndAt
end


function QUnion:getDragonTrainBuffCountdown()
    local countdownStr = "--:--:--"
    local isBuff , dragonTrainBuffEndAt = self:isDragonTrainBuffAndEndAt()
    if isBuff then
        local time = dragonTrainBuffEndAt - q.serverTime() * 1000
        if time > 0 then
            countdownStr = self:_formatSecTime(time/1000)
        end
    end

    return countdownStr
end

-- 将秒为单位的数字转换成 0天 00：00：00格式
function QUnion:_formatSecTime( sec )
    local d = math.floor(sec/DAY)
    local h = math.floor((sec%DAY)/HOUR)
    -- local h = math.floor(sec/HOUR)
    local m = math.floor((sec%HOUR)/MIN)
    local s = math.floor(sec%MIN)

    if d > 0 then
        return string.format("%d天 %02d:%02d:%02d", d, h, m, s)
    else
        return string.format("%02d:%02d:%02d", h, m, s)
    end
end

return QUnion
