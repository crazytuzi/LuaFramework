--
-- Author: Kumo.Wang
-- 宗门红包数据管理
--

local QBaseModel = import("...models.QBaseModel")
local QUnionRedPacket = class("QUnionRedPacket", QBaseModel)

local QUIViewController = import("...ui.QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QActorProp = import("...models.QActorProp")

QUnionRedPacket.NEW_DAY = "QUNIONREDPACKET_NEW_DAY"
QUnionRedPacket.UPDATE_REDPACKET = "QUNIONREDPACKET_UPDATE_REDPACKET"

QUnionRedPacket.TOKEN_REDPACKET = 1
QUnionRedPacket.ITEM_REDPACKET = 2
QUnionRedPacket.CONSORTIA_WAR_REDPACKET = 3

QUnionRedPacket.NEW_REDPACKET_STATE = 0
QUnionRedPacket.OPENED_REDPACKET_STATE = 1
QUnionRedPacket.END_REDPACKET_STATE = 2

QUnionRedPacket.ONE_STATE = 1
QUnionRedPacket.LAST_ONE_STATE = -1

QUnionRedPacket.FREE_TOKEN_REDPACKET_ID_1 = 1
QUnionRedPacket.FREE_TOKEN_REDPACKET_ID_2 = 2
QUnionRedPacket.FREE_TOKEN_REDPACKET_ID_3 = 3

QUnionRedPacket.GAIN = "GAIN"
QUnionRedPacket.SEND = "SEND"
QUnionRedPacket.ACHIEVEMENT = "QUNIONREDPACKET_ACHIEVEMENT"

QUnionRedPacket.REDPACKET_ACHIEVEMENT_NOT_COMPLETE_STATE = 0
QUnionRedPacket.REDPACKET_ACHIEVEMENT_COMPLETE_STATE = 1
QUnionRedPacket.REDPACKET_ACHIEVEMENT_DONE_STATE = 2

QUnionRedPacket.DEFAULT_SEND_MESSAGE = "恭喜发财，大吉大利"
QUnionRedPacket.DEFAULT_GAIN_MESSAGE = "谢谢老板"

function QUnionRedPacket:ctor()
    QUnionRedPacket.super.ctor(self)
end

function QUnionRedPacket:init()
    self._userEventProxy = cc.EventProxy.new(remote.user)
    self._userEventProxy:addEventListener(remote.user.EVENT_TIME_REFRESH, handler(self, self.refreshTimeHandler))

    self._dispatchTBl = {}
    self._unionRedpacketConfigDic = {}
    self._unionRedpacketConfigList = {}
    self._unionRedpacketDic = {} -- key: 红包id，value：该红包在_unionRedpacketConfigList里面的index
    self._unionRedpacketAchieveConfigDic = {}
    self._unionRedpacketAchieveConfigList = {}
    self._unionRedpacketAchieveDic = {} -- key: 红包成就id，value：该红包在_unionRedpacketAchieveConfigList里面的index
    self._unionRedpacketAchievhHeroTitleDic = {}

    self.unionRedpacketAchievePropKeyDic = {}
    self.unionRedpacketList = {}
    self.unionRedpacketDic = {} -- key: 红包id，value：该红包在unionRedpacketList里面的index
    self.unionRedpacketAchievementDoneIdDic = {} -- 成就已经完成并且领完奖励的Id。key：成就id，value：true

    self.showRedpacketId = 0
    self.unionRedpacketAchievementMaxTokenId = 0 -- 钻石红包成就的最大id
    self.unionRedpacketAchievementMaxItemId = 0 -- 活动红包成就的最大id
    self.unionRedpacketAchievementMinTokenId = 9999999 -- 钻石红包成就的最小id
    self.unionRedpacketAchievementMinItemId = 9999999 -- 活动红包成就的最小id
    self.showAchievementConfigId = 0 -- 红包成就界面定位显示的configId
    self.sendTokenRedpacketUnlockLevel = 9999999 -- 钻石红包的最低解锁等级

    self._sendRedTips = false -- 发送完红包，不根据list，强行显示红点，by 策划

    self:_analysisConfig()
end

function QUnionRedPacket:disappear()
    if self._remoteProexy ~= nil then
        self._remoteProexy:removeAllEventListeners()
        self._remoteProexy = nil
    end

    if self._userEventProxy ~= nil then
        self._userEventProxy:removeAllEventListeners()
        self._userEventProxy = nil
    end
end

function QUnionRedPacket:loginEnd(callback)
    if self:_checkRedPacketUnlock() then
        self:unionRedpacketListRequest(callback, callback)
    else
        if callback then
            callback()
        end
    end
end

function QUnionRedPacket:openDialog(selectedTab)
    if self:_checkRedPacketUnlock(true) then  
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRedpacketMain", options = {selectedTab = selectedTab}}, {isPopCurrentDialog = true})
    end
end

function QUnionRedPacket:openFreeTimeAlert(callBack, isDailyTask)
    if remote.user.freeRedPacketFlag and self:_checkRedPacketUnlock(true) then 
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnionRedpacketFreeTimeAlert", 
            options = {callBack = callBack, isGo = true, isDailyTask = isDailyTask}}, {isPopCurrentDialog = true})
    else
        if callBack then
            callBack()
        end
    end

    if remote.user.freeRedPacketFlag then
        remote.user.freeRedPacketFlag = false
    end
end

function QUnionRedPacket:refreshTimeHandler(event)
    if event.time == nil or event.time == 5 then
        if remote.user.userConsortia then
            remote.user.userConsortia.redpacket_send_count = 0
            remote.user.userConsortia.redpacket_receive_count = 0
        end
        self:dispatchEvent( { name = QUnionRedPacket.NEW_DAY } )
    end
end

--------------数据储存.KUMOFLAG.--------------


--------------调用素材.KUMOFLAG.--------------

-- 获取红包的图片资源
function QUnionRedPacket:getRedPacketPathByTypeAndState(type, state)
    if not type or not state then return nil end
    local type = tonumber(type)
    local state = tonumber(state)
    if type == self.TOKEN_REDPACKET then
        if state == self.NEW_REDPACKET_STATE then
            return "ui/society_redpacket/diamondpacket0.png"
        elseif state == self.OPENED_REDPACKET_STATE then
            return "ui/society_redpacket/diamondpacket1.png"
        elseif state == self.END_REDPACKET_STATE then
            return "ui/society_redpacket/diamondpacket2.png"
        end
    elseif type == self.ITEM_REDPACKET then
        if state == self.NEW_REDPACKET_STATE then
            return "ui/society_redpacket/redpacket0.png"
        elseif state == self.OPENED_REDPACKET_STATE then
            return "ui/society_redpacket/redpacket1.png"
        elseif state == self.END_REDPACKET_STATE then
            return "ui/society_redpacket/redpacket2.png"
        end
    elseif type == self.CONSORTIA_WAR_REDPACKET then
        if state == self.NEW_REDPACKET_STATE then
            return "ui/society_redpacket/zongmenpacket0.png"
        elseif state == self.OPENED_REDPACKET_STATE then
            return "ui/society_redpacket/zongmenpacket1.png"
        elseif state == self.END_REDPACKET_STATE then
            return "ui/society_redpacket/zongmenpacket2.png"
        end
    end
    return nil
end

-- 获取发送界面红包的图片资源
function QUnionRedPacket:getSendRedPacketPathByType(type)
    if not type then return nil end
    local type = tonumber(type)
    if type == self.TOKEN_REDPACKET then
        return "ui/society_redpacket/redpacket_blue.png"
    elseif type == self.ITEM_REDPACKET then
        return "ui/society_redpacket/redpacket_left.png"
    elseif type == self.CONSORTIA_WAR_REDPACKET then
        return "ui/society_redpacket/redpacket_zongmen.png"
    end
    return nil
end


-- 获取红包的类型名
function QUnionRedPacket:getRedPacketTypePathByType(type)
    if not type then return nil end
    local type = tonumber(type)
    if type == self.TOKEN_REDPACKET then
        -- return "ui/society_redpacket/zi_zuanshihongbao.png"
        return "钻石福袋"
    elseif type == self.ITEM_REDPACKET then
        -- return "ui/society_redpacket/zi_huodonghongbao.png"
        return "活动福袋"
    elseif type == self.CONSORTIA_WAR_REDPACKET then
        -- return "ui/society_redpacket/zi_zongmenfudai.png"
        return "宗门福袋"
    end
    return nil
end

-- 获取最佳标记
function QUnionRedPacket:getNumberOnePathByType(type)
    if not type then return nil end
    local type = tonumber(type)
    if type == self.ONE_STATE then
        return "ui/society_redpacket/sp_luckl1.png"
    elseif type == self.LAST_ONE_STATE then
        return "ui/society_redpacket/sp_luckl0.png"
    end
    return nil
end

-- 发包之后的特效
function QUnionRedPacket:getSendEffectPath()
    return "ccb/effects/Effect_Society_Redpacket.ccbi"
end

-- 背景图
function QUnionRedPacket:getBGPathByType(type)
    if not type then return nil end
    if type == self.GAIN then
        return "ui/society_redpacket/redpacket_di.png"
    elseif type == self.SEND then
        return "ui/society_redpacket/redpacket_di.png"
    elseif type == self.ACHIEVEMENT then
        return "ui/society_redpacket/chenghaokuang.png"
    end
    return nil
end

-- 成就的图片资源
function QUnionRedPacket:getRedPacketAchievementPathByTypeAndState(type, state)
    if not type then return nil end
    local type = tonumber(type)
    if type == self.TOKEN_REDPACKET then
        if state == self.REDPACKET_ACHIEVEMENT_NOT_COMPLETE_STATE then
            return "ui/society_redpacket/packet_zuanshi.png"
        elseif state == self.REDPACKET_ACHIEVEMENT_COMPLETE_STATE then
            return "ui/society_redpacket/packet_zuanshi1.png"
        elseif state == self.REDPACKET_ACHIEVEMENT_DONE_STATE then
            return "ui/society_redpacket/packet_zuanshi2.png"
        end
    elseif type == self.ITEM_REDPACKET then
        if state == self.REDPACKET_ACHIEVEMENT_NOT_COMPLETE_STATE then
            return "ui/society_redpacket/packet_huodong.png"
        elseif state == self.REDPACKET_ACHIEVEMENT_COMPLETE_STATE then
            return "ui/society_redpacket/packet_huodong1.png"
        elseif state == self.REDPACKET_ACHIEVEMENT_DONE_STATE then
            return "ui/society_redpacket/packet_huodong2.png"
        end
    end
    return nil
end

--------------便民工具.KUMOFLAG.--------------

function QUnionRedPacket:checkRedpacketRedTip()
    if not self:_checkRedPacketUnlock() then
        return false
    end
    if self:checkRedpacketSendRedTip() then
        return true
    end
    if self:checkRedpacketGainRedTip() then
        return true
    end
    if self:checkRedpacketAchievementRedTip() then
        return true
    end
    return false
end

function QUnionRedPacket:checkRedpacketSendRedTip()
    if not remote.user.userConsortia then
        return false
    end

    local isRedTip = false
    if self:_checkRedPacketUnlock() then
        -- 有免费可发放额度
        if remote.user.userConsortia.free_red_packet_count and remote.user.userConsortia.free_red_packet_count > 0 then
            isRedTip = true
        end
        if remote.user.userConsortia.free_red_packet2_count and remote.user.userConsortia.free_red_packet2_count > 0 then
            isRedTip = true
        end
        if remote.user.userConsortia.free_red_packet3_count and remote.user.userConsortia.free_red_packet3_count > 0 then
            isRedTip = true
        end
    end
    return isRedTip
end

function QUnionRedPacket:checkRedpacketGainRedTip()
    local isRedTip = false
    if self:_checkRedPacketUnlock() then
        -- 发完红包的强制红点
        isRedTip = self._sendRedTips

        -- 有可领取的红包
        for _, value in ipairs(self.unionRedpacketList) do
            if not value.isOpened and value.redpacketNum > 0 and (value.type == QUnionRedPacket.ITEM_REDPACKET or self:getMaxGainCount() > self:getCurGainCount()) then
                -- 可领取
                local isOvertime = self:updateTime( value.offAt )
                if not isOvertime then
                    isRedTip = true
                    break
                end
            end
        end
    end
    return isRedTip
end

function QUnionRedPacket:checkRedpacketAchievementRedTip()
    local isRedTip = false
    if self:checkRedpacketAchievementItemRedTip() then
        isRedTip = true
    end
    if self:checkRedpacketAchievementTokenRedTip() then
        isRedTip = true
    end
    return isRedTip
end

function QUnionRedPacket:checkRedpacketAchievementItemRedTip()
    local isRedTip = false
    if self:_checkRedPacketUnlock() then
        local typeNum = self.ITEM_REDPACKET
        local id = self:getRedpacketCurAchievementConfigIdByTab(typeNum)
        -- print("QUnionRedPacket:checkRedpacketAchievementItemRedTip(1) ", id)
        if id > 0 then
            if not self:checkAchieveDoneByTypeAndId(typeNum, id) then
                local config = self:getRedpacketAchieveConfigById(id)
                local count = self:getAchieveSendCountByType(typeNum)
                -- QPrintTable(config)
                -- print("QUnionRedPacket:checkRedpacketAchievementItemRedTip(2) ", count, config.condition)
                if config.condition and count >= tonumber(config.condition) then
                    isRedTip = true
                end
            end
        end
    end
    -- print("QUnionRedPacket:checkRedpacketAchievementItemRedTip(3) ", isRedTip)
    return isRedTip
end

function QUnionRedPacket:checkRedpacketAchievementTokenRedTip()
    local isRedTip = false
    if self:_checkRedPacketUnlock() then
        local typeNum = self.TOKEN_REDPACKET
        local id = self:getRedpacketCurAchievementConfigIdByTab(typeNum)
        -- print("QUnionRedPacket:checkRedpacketAchievementTokenRedTip(1) ", id)
        if id > 0 then
            if not self:checkAchieveDoneByTypeAndId(typeNum, id) then
                local config = self:getRedpacketAchieveConfigById(id)
                local count = self:getAchieveSendCountByType(typeNum)
                -- QPrintTable(config)
                -- print("QUnionRedPacket:checkRedpacketAchievementTokenRedTip(2) ", count, config.condition)
                if config.condition and count >= tonumber(config.condition) then
                    isRedTip = true
                end
            end
        end
    end
    -- print("QUnionRedPacket:checkRedpacketAchievementTokenRedTip(3) ", isRedTip)
    return isRedTip
end

function QUnionRedPacket:getSendTabData()
    local returnTbl = {}
    for key, _ in pairs(self._unionRedpacketConfigDic) do
        table.insert(returnTbl, key)
    end
    table.sort(returnTbl, function(a, b)
            return a < b
        end)
    -- QPrintTable(returnTbl)
    return returnTbl
end

function QUnionRedPacket:getCurSendCount()
    -- return self._redpacketSendCount or 0
    return remote.user.userConsortia.redpacket_send_count or 0
end
function QUnionRedPacket:getMaxSendCount()
    local maxSendCount = QStaticDatabase.sharedDatabase():getConfigurationValue("SEND_REDPACKET_COUNT")
    return maxSendCount or 1
end

function QUnionRedPacket:getCurGainCount()
    -- return self._redpacketGainCount or 0
    return remote.user.userConsortia.redpacket_receive_count or 0
end
function QUnionRedPacket:getMaxGainCount()
    local maxGainCount = QStaticDatabase.sharedDatabase():getConfigurationValue("RECEIVE_REDPACKET_COUNT")
    return maxGainCount or 8
end

function QUnionRedPacket:getCurGainCountForUnionWars()
    return remote.user.userConsortia.consortia_red_packet_get_count or 0
end
function QUnionRedPacket:getMaxGainCountForUnionWars()
    local maxGainCount = QStaticDatabase.sharedDatabase():getConfigurationValue("consortia_red_package_day_count")
    return maxGainCount or 16
end

function QUnionRedPacket:updateTime( offAt )
    local timeStr = "--:--:--"
    local isOvertime = true
    if not offAt then return isOvertime, timeStr end

    local endTime = offAt/1000

    if q.serverTime() >= endTime then
        timeStr = "00:00:00"
    else
        local sec = endTime - q.serverTime()
        -- if sec >= 30*60 then
        --     color = ccc3(255, 216, 44)
        -- else
        --     color = ccc3(255, 63, 0)
        -- end
        local h, m, s = self:_formatSecTime( sec )
        -- timeStr = string.format("%02d:%02d:%02d", h, m, s)
        timeStr = string.format("%02d:%02d", h, m)
        isOvertime = false
    end

    return isOvertime, timeStr
end

function QUnionRedPacket:getRedpacketConfigById( id )
    local index = self._unionRedpacketDic[id]
    if index then
        local config = self._unionRedpacketConfigList[index]
        return config
    end
    return nil
end

function QUnionRedPacket:getRedpacketConfigListByType(redpacketType)
    if not redpacketType then return nil end

    local configList = self._unionRedpacketConfigDic[redpacketType]
    return configList
end

function QUnionRedPacket:getUnionRedpacketListByRedpacketId( redpacketId )
    local index = self.unionRedpacketDic[redpacketId]
    if index then
        return self.unionRedpacketList[index]
    end
    return nil
end

function QUnionRedPacket:getAchieveTabDataByType( type )
    local returnTbl = {}
    if not type then return returnTbl end
    local type = tonumber(type)
    if type ~= self.TOKEN_REDPACKET and type ~= self.ITEM_REDPACKET then
        return returnTbl
    end
    returnTbl = self._unionRedpacketAchieveConfigDic[type]
    -- QPrintTable(returnTbl)
    return returnTbl
end

function QUnionRedPacket:getAchieveDoneAchievementProps(typeNum, configId)
    if not next(self._unionRedpacketAchievhHeroTitleDic) then
        self._unionRedpacketAchievhHeroTitleDic = self:_initHeroTitleConfig()
    end
    local achievePropDic = {}
    local configList = {}
    if typeNum then
        configList = self:getAchieveTabDataByType(typeNum)
    else
        configList = self._unionRedpacketAchieveConfigList
    end
    for _, config in ipairs(configList) do
        local isDone = false
        if configId then
            isDone = tonumber(configId) >= tonumber(config.id)
        else
            isDone = self:checkAchieveDoneByTypeAndId(config.type, config.id)
        end
        if config.head_default and isDone then
            local heroTileConfig = self._unionRedpacketAchievhHeroTitleDic[tonumber(config.head_default)]
            if heroTileConfig then
                local keyList = self.unionRedpacketAchievePropKeyDic[config.type]
                for _, key in ipairs(keyList) do
                    if heroTileConfig[key] then
                        if achievePropDic[key] then
                            achievePropDic[key].num = achievePropDic[key].num + tonumber(heroTileConfig[key])
                        else
                            achievePropDic[key] = {name = QActorProp._field[key].uiName or QActorProp._field[key].name, num = tonumber(heroTileConfig[key]), isPercent = QActorProp._field[key].isPercent}
                        end
                    end
                end
            end
        end
    end
    -- QPrintTable(achievePropDic)
    return achievePropDic
end

-- optional int32 total_red_packet_com_send_token = 38;        // 普通公会红包总发放额度
-- optional int32 total_red_packet_com_reward_id = 39;         // 普通公会红包已领取的最大奖励ID
-- optional int32 total_red_packet_act_send_token = 40;        // 活动公会红包总发放额度
-- optional int32 total_red_packet_act_reward_id = 41;         // 活动公会红包已领取的最大奖励ID
function QUnionRedPacket:getAchieveSendCountByType( typeNum )
    local sendCount = 0
    if not typeNum or not remote.user.userConsortia then return sendCount end
    local typeNum = tonumber(typeNum)
    if typeNum == self.TOKEN_REDPACKET then
        sendCount = remote.user.userConsortia.total_red_packet_com_send_token or 0
    elseif typeNum == self.ITEM_REDPACKET then
        sendCount = remote.user.userConsortia.total_red_packet_act_send_token or 0
    end
    
    return sendCount
end

function QUnionRedPacket:checkAchieveDoneByTypeAndId( typeNum, id )
    local id = tonumber(id)
    local isDone = self.unionRedpacketAchievementDoneIdDic[id] or false
    if isDone then return isDone end

    if not typeNum or not id or not remote.user.userConsortia then return isDone end
    local typeNum = tonumber(typeNum)
    local maxDoneId = 0
    if typeNum == self.TOKEN_REDPACKET then
        maxDoneId = remote.user.userConsortia.total_red_packet_com_reward_id or 0
    elseif typeNum == self.ITEM_REDPACKET then
        maxDoneId = remote.user.userConsortia.total_red_packet_act_reward_id or 0
    end

    if id <= maxDoneId then
        isDone = true
        self.unionRedpacketAchievementDoneIdDic[id] = true
    end
    return isDone
end

function QUnionRedPacket:getRedpacketAchievementStateByConfig( config )
    local state = self.REDPACKET_ACHIEVEMENT_NOT_COMPLETE_STATE
    if not config or next(config) == nil then return state end
    if config.type then
        local sendCount = self:getAchieveSendCountByType(config.type)
        if sendCount >= tonumber(config.condition) then
            if self:checkAchieveDoneByTypeAndId(config.type, config.id) then
                state = self.REDPACKET_ACHIEVEMENT_DONE_STATE
            else
                state = self.REDPACKET_ACHIEVEMENT_COMPLETE_STATE
            end
        end
    end

    return state
end

function QUnionRedPacket:getHeadTitlePathById( id )
    local config = QStaticDatabase.sharedDatabase():getHeadInfoById(id)
    return config.icon
end

function QUnionRedPacket:getLuckyDrawItemInfoById( luckyDrawId )
    local id, typeName, count
    local awards = QStaticDatabase.sharedDatabase():getluckyDrawById( luckyDrawId ) 
    -- QPrintTable(awards)
    -- 来自于QStaticDatabase ： table.insert(awards, {id = luckyConfig["id_"..index], typeName = luckyConfig["type_"..index], count = luckyConfig["num_"..index]})
    -- 这里只支持显示一样奖励，所以只取1。
    if #awards > 0 then
        id = awards[1].id
        typeName = awards[1].typeName
        count = awards[1].count
    end
    return id, typeName, count
end

function QUnionRedPacket:getRedpacketAchieveConfigById(id)
    local index = self._unionRedpacketAchieveDic[id] or 0
    if index > 0 then
        return self._unionRedpacketAchieveConfigList[index]
    end

    return {}
end

-- self.unionRedpacketAchievementMaxTokenId = 0 -- 钻石红包成就的最大id
-- self.unionRedpacketAchievementMaxItemId = 0 -- 活动红包成就的最大id
-- self.unionRedpacketAchievementMinTokenId = 9999999 -- 钻石红包成就的最小id
-- self.unionRedpacketAchievementMinItemId = 9999999 -- 活动红包成就的最小id
function QUnionRedPacket:getRedpacketCurAchievementConfigIdByTab( selectedAchieveTab )
    local configId = 0
    if remote.user.userConsortia then
        if selectedAchieveTab == self.ITEM_REDPACKET then
            if not remote.user.userConsortia.total_red_packet_act_reward_id or remote.user.userConsortia.total_red_packet_act_reward_id == 0 then
                configId = self.unionRedpacketAchievementMinItemId
            else
                local configs = self:getAchieveTabDataByType(selectedAchieveTab)
                for i, value in ipairs(configs) do
                    if  value.id == remote.user.userConsortia.total_red_packet_act_reward_id then
                        if configs[i+1] then 
                            configId = configs[i+1].id
                        else
                            configId = self.unionRedpacketAchievementMaxItemId
                        end
                    end
                end
            end
            if configId < self.unionRedpacketAchievementMinItemId then
                configId = self.unionRedpacketAchievementMinItemId
            elseif configId > self.unionRedpacketAchievementMaxItemId then
                configId = self.unionRedpacketAchievementMaxItemId
            end
        elseif selectedAchieveTab == self.TOKEN_REDPACKET then
            if not remote.user.userConsortia.total_red_packet_com_reward_id or remote.user.userConsortia.total_red_packet_com_reward_id == 0 then
                configId = self.unionRedpacketAchievementMinTokenId
            else
                local configs = self:getAchieveTabDataByType(selectedAchieveTab)
                for i, value in ipairs(configs) do
                    if  value.id == remote.user.userConsortia.total_red_packet_com_reward_id then
                        if configs[i+1] then 
                            configId = configs[i+1].id
                        else
                            configId = self.unionRedpacketAchievementMaxTokenId
                        end
                    end
                end
            end
            if configId < self.unionRedpacketAchievementMinTokenId then
                configId = self.unionRedpacketAchievementMinItemId
            elseif configId > self.unionRedpacketAchievementMaxTokenId then
                configId = self.unionRedpacketAchievementMaxTokenId
            end
        end
    end

    return configId
end

--------------数据处理.KUMOFLAG.--------------

function QUnionRedPacket:responseHandler( response, successFunc, failFunc )
    -- QPrintTable( response )
    if response and response.redpacketList and response.error == "NO_ERROR" then
        self._sendRedTips = false
        if response.api == "REDPACKET_LIST" then
            self:_saveRedpacketData(response.redpacketList.consortiaRedpacket)
        elseif response.api == "REDPACKET_OPEN" then
            self:_changeRedpacketData(response.redpacketList.consortiaRedpacket)
        end
        table.insert(self._dispatchTBl, QUnionRedPacket.UPDATE_REDPACKET)
    end

    if response and response.api == "REDPACKET_SEND" and response.error == "NO_ERROR" then
        self._sendRedTips = true
        remote.union.consortia.exp = response.consortia.exp
        remote.union.consortia.level = response.consortia.level
        table.insert(self._dispatchTBl, QUnionRedPacket.UPDATE_REDPACKET)
        QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QNotificationCenter.UNION_WIDGET_NAME_UPDATE})
    end

    if response and response.api == "REDPACKET_GET_TASK_REWARD" and response.error == "NO_ERROR" then
        table.insert(self._dispatchTBl, QUnionRedPacket.UPDATE_REDPACKET)
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

function QUnionRedPacket:pushHandler( data )
    -- QPrintTable(data)
end

--[[
    //宗门红包
    REDPACKET_SEND                              = 4425;                     // 发送红包 RedpacketSendRequest
    REDPACKET_LIST                              = 4426;                     // 红包列表
    REDPACKET_OPEN                              = 4427;                     // 抢红包 RedpacketOpenRequest
    REDPACKET_DETAIL                            = 4428;                     // 红包详情 RedpacketShowDetailRequest
    REDPACKET_SAVE_MASSAGE                      = 4429;                     // 保存领取后玩家发送的红包祝福语 RedpacketSaveMessageRequest
    REDPACKET_GET_TASK_REWARD                   = 4430;                     // 公会红包-领取成就奖励 RedpacketGetTaskRewardRequest
]]

function QUnionRedPacket:unionRedpacketListRequest(success, fail, status)
    local request = { api = "REDPACKET_LIST" }
    app:getClient():requestPackageHandler("REDPACKET_LIST", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional int32 redPacketType = 1;   //红包档次   1 288钻石  2 388钻石 3 888钻石   对应量表 guild_wallet 的 id 字段
-- optional string message = 2;        //红包祝福语
function QUnionRedPacket:unionRedpacketSendRequest(redPacketType, message, success, fail, status)
    local redpacketSendRequest = {redPacketType = redPacketType, message = message}
    local request = { api = "REDPACKET_SEND", redpacketSendRequest = redpacketSendRequest }
    app:getClient():requestPackageHandler("REDPACKET_SEND", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional string redpacketId = 1; //红包id
function QUnionRedPacket:unionRedpacketOpenRequest(redpacketId, success, fail, status)
    local redpacketOpenRequest = {redpacketId = redpacketId}
    local request = { api = "REDPACKET_OPEN", redpacketOpenRequest = redpacketOpenRequest }
    app:getClient():requestPackageHandler("REDPACKET_OPEN", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional string redpacketId = 1; //红包id
function QUnionRedPacket:unionRedpacketShowDetailRequest(redpacketId, success, fail, status)
    local redpacketShowDetailRequest = {redpacketId = redpacketId}
    local request = { api = "REDPACKET_DETAIL", redpacketShowDetailRequest = redpacketShowDetailRequest }
    app:getClient():requestPackageHandler("REDPACKET_DETAIL", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional string redpacketId = 1; //红包id
-- optional string message = 2;        //红包祝福语
function QUnionRedPacket:unionRedpacketSaveMessageRequest(redpacketId, message, success, fail, status)
    local redpacketSaveMessageRequest = {redpacketId = redpacketId, message = message}
    local request = { api = "REDPACKET_SAVE_MASSAGE", redpacketSaveMessageRequest = redpacketSaveMessageRequest }
    app:getClient():requestPackageHandler("REDPACKET_SAVE_MASSAGE", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end
-- optional int32 type = 1;            //红包类型，1：钻石红包，2：活动红包
-- optional int32 taskId = 2;          //成就ID
function QUnionRedPacket:unionRedpacketGetTaskRewardRequest(type, taskId, success, fail, status)
    local redpacketGetTaskRewardRequest = {type = type, taskId = taskId}
    local request = { api = "REDPACKET_GET_TASK_REWARD", redpacketGetTaskRewardRequest = redpacketGetTaskRewardRequest }
    app:getClient():requestPackageHandler("REDPACKET_GET_TASK_REWARD", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--------------本地工具.KUMOFLAG.--------------

function QUnionRedPacket:_checkRedPacketUnlock(isTips)
    return app.unlock:getUnlockUnionRedpacket(isTips)
end

function QUnionRedPacket:_dispatchAll()
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

function QUnionRedPacket:_analysisConfig()
    local unionRedpacketConfig = QStaticDatabase.sharedDatabase():getUnionRedpacketConfig()
    -- QPrintTable(unionRedpacketConfig)
    for _, config in pairs(unionRedpacketConfig) do
        table.insert(self._unionRedpacketConfigList, config)
        if config.type then
            if not self._unionRedpacketConfigDic[config.type] then
                self._unionRedpacketConfigDic[config.type] = {}
            end
            table.insert(self._unionRedpacketConfigDic[config.type], config)
        end
    end
    table.sort(self._unionRedpacketConfigList, function(a, b)
            return a.id < b.id
        end)
    for _, configList in pairs(self._unionRedpacketConfigDic) do
        table.sort(configList, function(a, b)
            return a.id < b.id
        end)
    end
    local tokenConfigList = self._unionRedpacketConfigDic[self.TOKEN_REDPACKET] or {}
    for _, config in ipairs(tokenConfigList) do
        if config.unlock_level and config.unlock_level < self.sendTokenRedpacketUnlockLevel then
            self.sendTokenRedpacketUnlockLevel = config.unlock_level
        end
    end
    for index, value in ipairs(self._unionRedpacketConfigList) do
        self._unionRedpacketDic[value.id] = index
    end

    local unionRedpacketAchieveConfig = QStaticDatabase.sharedDatabase():getUnionRedpacketAchieveConfig()
    -- QPrintTable(unionRedpacketAchieveConfig)
    local tblDic = {}
    for _, config in pairs(unionRedpacketAchieveConfig) do
        table.insert(self._unionRedpacketAchieveConfigList, config)
        if config.type then
            if not self._unionRedpacketAchieveConfigDic[config.type] then
                self._unionRedpacketAchieveConfigDic[config.type] = {}
            end
            table.insert(self._unionRedpacketAchieveConfigDic[config.type], config)
            -- print(self.unionRedpacketAchievementMaxItemId, self.unionRedpacketAchievementMaxTokenId, tonumber(config.id))
            if config.type == self.ITEM_REDPACKET then
                if self.unionRedpacketAchievementMaxItemId < tonumber(config.id) then
                    self.unionRedpacketAchievementMaxItemId = tonumber(config.id)
                end
                if self.unionRedpacketAchievementMinItemId > tonumber(config.id) then
                    self.unionRedpacketAchievementMinItemId = tonumber(config.id)
                end
            elseif config.type == self.TOKEN_REDPACKET then
                if self.unionRedpacketAchievementMaxTokenId < tonumber(config.id) then
                    self.unionRedpacketAchievementMaxTokenId = tonumber(config.id)
                end
                if self.unionRedpacketAchievementMinTokenId > tonumber(config.id) then
                    self.unionRedpacketAchievementMinTokenId = tonumber(config.id)
                end
            end
        end
    end
    table.sort(self._unionRedpacketAchieveConfigList, function(a, b)
            return a.id < b.id
        end)
    for _, configList in pairs(self._unionRedpacketAchieveConfigDic) do
        table.sort(configList, function(a, b)
            return a.id < b.id
        end)
    end
    for index, value in ipairs(self._unionRedpacketAchieveConfigList) do
        self._unionRedpacketAchieveDic[value.id] = index
    end
end

function QUnionRedPacket:_saveRedpacketData(list)
    if not list then 
        self.unionRedpacketList = {}
    else
        self.unionRedpacketList = list
    end

    self:_sortRedpacketList()
    self:_moveOpenedRedpacket()
    self:_updateRedpacketDic()
end

function QUnionRedPacket:_changeRedpacketData(list)
    if not list then return end

    local isChanged = false
    for _, value in ipairs(list) do
        local index = self.unionRedpacketDic[value.redpacketId]
        if index then
            isChanged = true
            self.unionRedpacketList[index] = value
        end
    end

    if isChanged then
        self:_moveOpenedRedpacket()
        self:_updateRedpacketDic()
    end
end

function QUnionRedPacket:_sortRedpacketList()
    -- table.sort(self.unionRedpacketList, function(a, b)
    --         if a.type ~= b.type then
    --             return a.type > b.type
    --         else
    --             if a.item_num ~= b.item_num then
    --                 return a.item_num > b.item_num
    --             else
    --                 return a.offAt < b.offAt
    --             end
    --         end
    --     end)
    table.sort(self.unionRedpacketList, function(a, b)
            if a.item_num > 0 and b.item_num > 0 then
                if a.type ~= b.type then
                    return a.type > b.type
                else
                    if a.item_num ~= b.item_num then
                        return a.item_num > b.item_num
                    else
                        return a.offAt < b.offAt
                    end
                end
            else
                if a.item_num ~= b.item_num then
                    return a.item_num > b.item_num
                else
                    if a.type ~= b.type then
                        return a.type > b.type
                    else
                        return a.offAt < b.offAt
                    end
                end
            end
        end)
    -- QPrintTable(self.unionRedpacketList)
end

function QUnionRedPacket:_moveOpenedRedpacket()
    local openedList = {}
    local removeIndexList = {}
    for index, value in ipairs(self.unionRedpacketList) do
        if value.receiveDetailLogList then
            for _, log in ipairs(value.receiveDetailLogList) do
                if log.userId == remote.user.userId then
                    value.isOpened = true
                    value.rewardNum = log.item_num
                    value.rewardIdOrType = log.item_string
                    table.insert(openedList, value)
                    table.insert(removeIndexList, index)
                end
            end
        end
    end
    table.sort(removeIndexList, function(a, b)
            return a > b
        end)
    -- QPrintTable(removeIndexList)
    for _, removeIndex in ipairs(removeIndexList) do
        table.remove(self.unionRedpacketList, removeIndex)
    end
    for _, openedValue in ipairs(openedList) do
        table.insert(self.unionRedpacketList, openedValue)
    end
    -- QPrintTable(self.unionRedpacketList)
end

function QUnionRedPacket:_updateRedpacketDic()
    if not self.unionRedpacketList or #self.unionRedpacketList == 0 then 
        self.unionRedpacketDic = {}
    else
        for index, value in ipairs(self.unionRedpacketList) do
            self.unionRedpacketDic[value.redpacketId] = index
        end
    end
end

-- 将秒为单位的数字转换成 00：00：00格式
function QUnionRedPacket:_formatSecTime( sec )
    local h = math.floor((sec/3600)%24)
    local m = math.floor((sec/60)%60)
    local s = math.floor(sec%60)

    return h, m, s
end

function QUnionRedPacket:_initHeroTitleConfig()
    local returnDic = {}
    local tblDic = {}
    tblDic[self.TOKEN_REDPACKET] = {}
    tblDic[self.ITEM_REDPACKET] = {}
    local tbl = {}
    tbl[self.TOKEN_REDPACKET] = remote.headProp.TITLE_LUCKYBAG_P_TYPE
    tbl[self.ITEM_REDPACKET] = remote.headProp.TITLE_LUCKYBAG_A_TYPE

    for redpacketType, functionType in ipairs(tbl) do
        local heroTitleConfig = QStaticDatabase.sharedDatabase():getHeroTitle(functionType) or {}
        local redpacketType = tonumber(redpacketType)
        for _, config in pairs(heroTitleConfig) do
            returnDic[tonumber(config.id)] = config
            for key, _ in pairs(config) do
                if QActorProp._field[key] and not tblDic[redpacketType][key] then
                    tblDic[redpacketType][key] = true
                    if not self.unionRedpacketAchievePropKeyDic[redpacketType] then
                        self.unionRedpacketAchievePropKeyDic[redpacketType] = {}
                    end
                    table.insert(self.unionRedpacketAchievePropKeyDic[redpacketType], key)
                end
            end
        end
    end

    -- QPrintTable(self.unionRedpacketAchievePropKeyDic)
    return returnDic
end

return QUnionRedPacket
