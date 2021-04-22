-- 
-- Kumo.Wang
-- 资源夺宝活动数据类
--

local QActivityRoundsBaseChild = import(".QActivityRoundsBaseChild")
local QActivityTreasures = class("QActivityTreasures", QActivityRoundsBaseChild)

local QActivity = import(".QActivity")
local QNavigationController = import("..controllers.QNavigationController")
local QUIViewController = import("..ui.QUIViewController")

QActivityTreasures.SENIOR_THEME = 1
QActivityTreasures.PRIMARY_THEME = 2

QActivityTreasures.STEP_INTERVAL = 0.01 -- 秒

QActivityTreasures.RESOURCE_TREASURES_LOTTERY = "QACTIVITYTREASURES.RESOURCE_TREASURES_LOTTERY"
QActivityTreasures.RESOURCE_TREASURES_THEME_UPDATE = "QACTIVITYTREASURES.RESOURCE_TREASURES_THEME_UPDATE"
QActivityTreasures.RESOURCE_TREASURES_OFFLINE = "QACTIVITYTREASURES.RESOURCE_TREASURES_OFFLINE"
QActivityTreasures.RESOURCE_TREASURES_NEW_DAY = "QACTIVITYTREASURES.RESOURCE_TREASURES_NEW_DAY"

function QActivityTreasures:ctor( ... )
	QActivityTreasures.super.ctor(self,...)

    self._serverInfo = {}

    self.allRewards = {}
    self.prizes = {}
end

-- 活动界面关闭
function QActivityTreasures:activityShowEndCallBack()
	self:handleOffLine()
end

-- 活动结束（界面未必关闭）
function QActivityTreasures:activityEndCallBack()
end

function QActivityTreasures:handleOnLine()
	if self.isOpen then
		self:_loadActivity()
		self:treasureMainInfoRequest()
	end
end

function QActivityTreasures:handleOffLine()
	remote.activity:removeActivity({self.activityId})
	remote.activity:refreshActivity(true)
    self.isOpen = false
    remote.activityRounds:dispatchEvent({name = self.RESOURCE_TREASURES_OFFLINE})
    self:_handleEvent()
end

function QActivityTreasures:getActivityInfoWhenLogin()
	if self.isOpen then
		self:_loadActivity()
		self:treasureMainInfoRequest()
	end
end

function QActivityTreasures:timeRefresh( event )
	if event.time and event.time == 0 then
		if self.isOpen then
			self:treasureMainInfoRequest(function()
                remote.activityRounds:dispatchEvent({name = self.RESOURCE_TREASURES_NEW_DAY})
            end)
		end
	end
end

function QActivityTreasures:checkActivityComplete()
    if not self.isOpen or not self.isActivityNotEnd then
		return false
	end

    if not self:isActivityClickedToday() then
        -- 今日未进入过功能
        return true
    end

    return false
end

function QActivityTreasures:setActivityClickedToday()
	if not self.isOpen or not self.activityId then return end
	if app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(self.activityId) then
		app:getUserOperateRecord():recordeCurrentTime(self.activityId)
	end
end

function QActivityTreasures:isActivityClickedToday()
	if not self.isOpen or not self.activityId then return end
	return not app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(self.activityId)
end

--------------数据储存.KUMOFLAG.--------------

function QActivityTreasures:getServerInfo()
	return self._serverInfo
end

function QActivityTreasures:updateRewards(items)
    if not items then return end
    self.allRewards = {}

    local tbl = string.split(items, ";")
    for _, value in ipairs(tbl) do
        if value ~= "nil" and value ~= "" then
            local rtbl = string.split(value, "^")
            if not q.isEmpty(rtbl) then
                local key = rtbl[1]
                if key then
                    self.allRewards[key] = (self.allRewards[key] or 0) + (rtbl[2] or 0)
                end
            end
        end
    end
end

--------------對外工具.KUMOFLAG.--------------

function QActivityTreasures:getMapConfigByThemeId(themeId) 
    local themeConfigs = db:getStaticByName("treasure_theme")
    if not q.isEmpty(themeConfigs) and themeConfigs[tostring(themeId)] then
        local mapId = themeConfigs[tostring(themeId)].gride_map_id
        local mapConfigs = db:getStaticByName("treasure_map")
        if not q.isEmpty(mapConfigs) and mapConfigs[tostring(mapId)] then
            return mapConfigs[tostring(mapId)]
        end
    end
end

function QActivityTreasures:isBonusGrideByGrideIndex(index)
    local config = db:getConfigurationValue("bilibili_box")
    local tbl = string.split(config, ",")
    if not q.isEmpty(tbl) then
        for _, value in ipairs(tbl) do
            if tostring(index) == tostring(value) then
                return true
            end
        end
    end
                
    return false
end

function QActivityTreasures:isTokenGrideByGrideIndex(index)
    local config = db:getConfigurationValue("token_box")
    local tbl = string.split(config, ";")
    if not q.isEmpty(tbl) then
        local tokenMapId = tonumber(tbl[2])
        local _tbl = string.split(tbl[1], ",")
        if not q.isEmpty(_tbl) then
            for _, value in ipairs(_tbl) do
                if tostring(index) == tostring(value) then
                    return true, tokenMapId
                end
            end
        end
    end
                
    return false
end

function QActivityTreasures:isSeniorGrideByGrideIndex(index)
    local config = db:getConfigurationValue("super_box")
    local tbl = string.split(config, ",")
    if not q.isEmpty(tbl) then
        for _, value in ipairs(tbl) do
            if tostring(index) == tostring(value) then
                return true
            end
        end
    end
                
    return false
end

function QActivityTreasures:isPrimaryGrideByGrideIndex(index)
    local config = db:getConfigurationValue("high_box")
    local tbl = string.split(config, ",")
    if not q.isEmpty(tbl) then
        for _, value in ipairs(tbl) do
            if tostring(index) == tostring(value) then
                return true
            end
        end
    end
                
    return false
end

function QActivityTreasures:getBonusGrideByIndexList(indexList)
    if q.isEmpty(indexList) then return end
    local config = db:getConfigurationValue("bilibili_box")
    local tbl = string.split(config, ",")
    if not q.isEmpty(tbl) then
        for _, value in ipairs(tbl) do
            for _, index in ipairs(indexList) do
                if tostring(index) == tostring(value) then
                    return index
                end
            end
        end
    end
end

function QActivityTreasures:getCountdown()
    local curServerTime = q.serverTime()
    local cd = self.endAt - curServerTime
    if cd < 0 then
        return false, "--:--:--"
    end

    local cdStr = self:_formatSecTime(cd)
    return true, cdStr
end

--------------数据处理.KUMOFLAG.--------------

function QActivityTreasures:responseHandler( response, successFunc, failFunc )
    -- QKumo( response )
    if response and response.error == "ACTIVITY_NOT_FOUND" then
        remote.activityRounds:dispatchEvent({name = self.RESOURCE_TREASURES_OFFLINE})
    end

    if response and response.error == "NO_ERROR" then
        self._serverInfo = response
        if response.treasureInfoResponse then
            if response.treasureInfoResponse.radioGrid then
                -- 三连格的中心位置（不可缺省）
                self.radioGrid = response.treasureInfoResponse.radioGrid
            end
            if response.treasureInfoResponse.theme1 then
                self.theme1 = response.treasureInfoResponse.theme1
            end
            if response.treasureInfoResponse.theme2 then
                self.theme2 = response.treasureInfoResponse.theme2
            end
            if response.treasureInfoResponse.free ~= nil then
                self.free = response.treasureInfoResponse.free
            end
            if response.treasureInfoResponse.items then
                self:updateRewards(response.treasureInfoResponse.items)
            end
        end

        if response.lotteryResponse then
            self.prizes = {}
            if response.lotteryResponse.radioGrid then
                -- 三连格的中心位置（不可缺省）
                self.radioGrid = response.treasureInfoResponse.radioGrid
            end
            if response.lotteryResponse.theme1 then
                self.theme1 = response.lotteryResponse.theme1
            end
            if response.lotteryResponse.theme2 then
                self.theme2 = response.lotteryResponse.theme2
            end
            if response.lotteryResponse.lotteryInfo then
                self.lotteryInfo = response.lotteryResponse.lotteryInfo
            end
            if #self.lotteryInfo == 1 then
                self.free = false
            end
            self.prizes = response.prizes
        end

        if response.api == "TREASURE_LOTTERY" then
            remote.activityRounds:dispatchEvent({name = self.RESOURCE_TREASURES_LOTTERY})
        end

        if response.api == "TREASURE_CHOOSE_THEME" then
            remote.activityRounds:dispatchEvent({name = self.RESOURCE_TREASURES_THEME_UPDATE})
        end
    end

    if successFunc then 
        successFunc(response) 
        return
    end

    if failFunc then 
        failFunc(response)
    end
end

function QActivityTreasures:pushHandler( data )
    -- QPrintTable(data)
end

-- API
-- TREASURE_MAIN_INFO = 10250; //资源夺宝-主界面 TreasureInfoResponse
-- TREASURE_CHOOSE_THEME = 10251; //资源夺宝-选取主题 TreasureChooseThemeRequest
-- TREASURE_LOTTERY = 10252;//资源夺宝-抽奖 TreasureLotteryRequest TreasureLotteryResponse

function QActivityTreasures:treasureMainInfoRequest(success, fail, status)
    local request = { api = "TREASURE_MAIN_INFO"}
    app:getClient():requestPackageHandler("TREASURE_MAIN_INFO", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--[[
    /**
    * 资源夺宝-选取主题请求
    */
    message TreasureChooseThemeRequest {
        optional int32 type       = 1; // 主题类型(1:表示主题1,2:表示主题2)
        optional int32 id          = 2; // id
    }
]]
function QActivityTreasures:treasureChooseThemeRequest(type, id, success, fail, status)
	local treasureChooseThemeRequest = {type = type, id = id}
    local request = { api = "TREASURE_CHOOSE_THEME", treasureChooseThemeRequest = treasureChooseThemeRequest}
    app:getClient():requestPackageHandler("TREASURE_CHOOSE_THEME", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--[[
    /**
    * 资源夺宝-抽奖请求
    */
    message TreasureLotteryRequest {
        optional int32 lotteryCount   = 1; // 抽奖次数,目前只有1和10
    }
]]
function QActivityTreasures:treasureLotteryRequest(lotteryCount, success, fail, status)
    local treasureLotteryRequest = {lotteryCount = lotteryCount}
    local request = { api = "TREASURE_LOTTERY", treasureLotteryRequest = treasureLotteryRequest}
    app:getClient():requestPackageHandler("TREASURE_LOTTERY", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end
--[[
message TreasureInfoResponse {
    optional string activityId     = 1; // 活动ID
    repeated int32 radioGrid         = 2; // 三连格位置
    optional int32 theme1          = 3; // 主题1
    optional int32 theme2          = 4; // 主题2
    optional bool free             = 5; // 是否可以免费抽
    optional string items          = 6; // 已获得物品字符串
}
message TreasureLotteryInfo {
     optional int32 grid  =1 ;  // 随机的格子位置
     optional string reward = 2; //奖励(如果有)
     repeated TreasureLotteryInfo lotteryInfoList = 3; // 暴击(闪电)才有
}
message TreasureLotteryResponse {
    optional int32 theme1          = 1; // 主题1
    optional int32 theme2          = 2; // 主题2
    optional TreasureLotteryInfo lotteryInfo = 3;
    repeated int32 radioGrid = 4; //全部三连格中心点位置
}
]]

--------------本地工具.KUMOFLAG.--------------

function QActivityTreasures:_handleEvent()
    remote.activityRounds:dispatchEvent({name = remote.activityRounds.RESOURCE_TREASURES_OFF_LINE})
end

-- 加入到活動數據裡，讓主界面顯示icon
function QActivityTreasures:_loadActivity()
    if self.isOpen then
        local activities = {}
        local themeInfo = db:getActivityThemeInfoById(QActivity.THEME_ACTIVITY_RESOURCE_TREASURES) or {}
        table.insert(activities, {
            activityId = self.activityId, 
            title = (themeInfo.title or "尚未配表"), 
            roundType = "RESOURCE_TREASURES",
            start_at = self.startAt * 1000, 
            end_at = self.endAt * 1000,
            award_at = self.startAt * 1000, 
            award_end_at = self.showEndAt * 1000, 
            -- banner = "ui/update_zhangbichen/formal/sp_quanfuyinlang_title.png",
            -- background = "activity_zbc_bg.jpg",
            -- description = "听主题曲，玩小游戏，领丰厚奖励~",
            weight = 20, 
            targets = {}, 
            subject = QActivity.THEME_ACTIVITY_RESOURCE_TREASURES})
        QKumo(activities)
        remote.activity:setData(activities)
    else
        remote.activity:removeActivity(self.activityId)
    end
end


-- 将秒为单位的数字转换成 0天 00：00：00格式
function QActivityTreasures:_formatSecTime( sec )
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

-- 一个闪电触发两个闪电，然后再触发一个闪电的数据
-- QActivityTreasures._response = 
-- {
--     error = "NO_ERROR",
--     api = "TREASURE_LOTTERY",
--     prizes = 
--     {
--         {
--             type = "ITEM",
--             count = 6,
--             id = 190000021,
--         },
--         {
--             type = "ITEM",
--             count = 5,
--             id = 1000239,
--         },
--         {
--             type = "TOKEN",
--             count = 2,
--             id = 0,
--         }
--     },
--     serverTime = 1603097092185,
--     lotteryResponse = 
--     {
--         theme2 = 2,
--         theme1 = 3,
--         lotteryInfo = 
--         {
--             {
--                 lotteryInfoList = 
--                 {
--                     {
--                         reward = "190000021^1;190000021^1",
--                         lotteryInfoList = 
--                         {
--                             {
--                                 lotteryInfoList = 
--                                 {
--                                     {
--                                         reward = "190000021^1;token^1;190000021^1",
--                                         radioGrid = 
--                                         {
--                                             6,
--                                         },
--                                         grid = 6,
--                                     },
--                                     {
--                                         grid = 22,
--                                         reward = "1000239^1",
--                                     },
--                                     {
--                                         grid = 18,
--                                         reward = "1000239^1",
--                                     }
--                                 },
--                                 radioGrid = 
--                                 {
--                                     6,
--                                 },
--                                 grid = 21,
--                             },
--                             {
--                                 grid = 22,
--                                 reward = "1000239^1",
--                             },
--                             {
--                                 grid = 18,
--                                 reward = "1000239^1",
--                             }
--                         },
--                         radioGrid = 
--                         {
--                             2,
--                             6
--                         },
--                         grid = 2
--                     },
--                     {
--                         grid = 11,
--                         reward = "190000021^1",
--                     },
--                     {
--                         lotteryInfoList = 
--                         {
--                             {
--                                 grid = 8,
--                                 reward = "190000021^1",
--                             },
--                             {
--                                 grid = 14,
--                                 reward = "token^1",
--                             },
--                             {
--                                 grid = 22,
--                                 reward = "1000239^1",
--                             }
--                         },
--                         grid = 9,
--                     }
--                 },
--                 radioGrid = 
--                 {
--                     6,
--                     2
--                 },
--                 grid = 13,
--             }
--         }
--     }
-- }

return QActivityTreasures