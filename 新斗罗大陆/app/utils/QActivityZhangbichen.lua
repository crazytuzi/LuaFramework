-- 
-- Kumo.Wang
-- 张碧晨主题器曲正式活动数据类
--

local QActivityRoundsBaseChild = import(".QActivityRoundsBaseChild")
local QActivityZhangbichen = class("QActivityZhangbichen", QActivityRoundsBaseChild)

local QActivity = import(".QActivity")
local QNavigationController = import("..controllers.QNavigationController")
local QUIViewController = import("..ui.QUIViewController")

local QUIWidgetZhangbichenActivity = import("..ui.widgets.QUIWidgetZhangbichenActivity")
local QUIWidgetZhangbichenActivityGame = import("..ui.widgets.QUIWidgetZhangbichenActivityGame")
local QUIWidgetZhangbichenActivityYinyuehuodong = import("..ui.widgets.QUIWidgetZhangbichenActivityYinyuehuodong")
local QUIWidgetZhangbichenActivityLanyinsedehai = import("..ui.widgets.QUIWidgetZhangbichenActivityLanyinsedehai")

QActivityZhangbichen.SCORE_LEVEL = {
    perfect = 5,
    great = 4,
    good = 3,
    bad = 2,
    miss = 1,
    none = 0,
}

--[[
    music_game_melody表：
    id：是游戏的id，music_game.game_melody_id调用
    index：序号
    start_time：绝对时间（秒)
    perfect_time：相对时间（相对于start_time）
    perfect_offset：所有的offset都是相对时间（相对于perfect_time）
    end_time：相对时间（相对于start_time），可以缺省。缺省时，通过start_time、perfect_time计算得出

    music_game表：
    id：序号
    game_melody_id：指定music_game_melody表的对应配置
    sound_id：音游的背景音乐id
    perfect_coefficient：coefficient类数据为针对每次点击各评级对应计算得分的系数
    combo_condition，combo_coefficient_add：combo的成长条件和成长值
    combo_max_coefficient：最大的combo数值，可以缺省
    score_level_1：score_level为总得分的阶段等级
    reward_1：score_level对应的奖励
]]
function QActivityZhangbichen:ctor( ... )
	QActivityZhangbichen.super.ctor(self,...)

	self._serverInfo = {}
    self._curGameId = 1 -- 游戲id
    self._musicGameDataDic = {}
    self._isIntheGame = false --默认没有在游戏中

    self.quanfuyinlangActivityId = "ZHANGBICHEN_QUAN_FU_YIN_LANG"
    self.yuyinniaoniaoActivityId = "ZHANGBICHEN_YU_YIN_NIAO_NIAO"
    self.yinyuehuodongActivityId = "ZHANGBICHEN_YIN_YUE_HUO_DONG"
    self.lanyinsedehaiActivityId = "ZHANGBICHEN_LAN_YIN_SE_DE_HAI"
end

-- 活动界面关闭
function QActivityZhangbichen:activityShowEndCallBack()
    self._isIntheGame = false
	self:handleOffLine()
end

-- 活动结束（界面未必关闭）
function QActivityZhangbichen:activityEndCallBack()
	self:_handleEvent()
    self._isIntheGame = false
end

function QActivityZhangbichen:handleOnLine()
	if self.isOpen then
		self:_loadActivity()
        remote.activity:registerDataProxy(self.quanfuyinlangActivityId, self)
        remote.activity:registerDataProxy(self.yuyinniaoniaoActivityId, self)
        remote.activity:registerDataProxy(self.yinyuehuodongActivityId, self)
        remote.activity:registerDataProxy(self.lanyinsedehaiActivityId, self)
		self:zhangbichenFormalMainInfoRequest()
	end
    self._isIntheGame = false
end

function QActivityZhangbichen:handleOffLine()
    remote.activity:unregisterDataProxy(self.quanfuyinlangActivityId)
    remote.activity:unregisterDataProxy(self.yuyinniaoniaoActivityId)
    remote.activity:unregisterDataProxy(self.yinyuehuodongActivityId)
    remote.activity:unregisterDataProxy(self.lanyinsedehaiActivityId)
	remote.activity:removeActivity({self.activityId, self.quanfuyinlangActivityId, self.yuyinniaoniaoActivityId, self.yinyuehuodongActivityId, self.lanyinsedehaiActivityId})
	remote.activity:refreshActivity(true)
    self.isOpen = false
	self:_handleEvent()
    self._isIntheGame = false
end

function QActivityZhangbichen:getActivityInfoWhenLogin()
	if self.isOpen then
		self:_loadActivity()
		self:zhangbichenFormalMainInfoRequest()
	end
    self._isIntheGame = false
end

function QActivityZhangbichen:timeRefresh( event )
	if event.time and event.time == 0 then
		if self.isOpen then
			self:zhangbichenFormalMainInfoRequest()
		end
	end
end

function QActivityZhangbichen:checkActivityComplete()
    if not self.isOpen or not self.isActivityNotEnd then
		return false
	end

    if not self:isActivityClickedToday(self.yuyinniaoniaoActivityId) then
        -- 今日未进入过功能
        return true
    end

    if self:checkRewardCanGet() then
        -- 有奖励待领取
        return true
    end

    return false
end

function QActivityZhangbichen:checkRewardCanGet()
    if q.isEmpty(self._serverInfo) then return end

    local rewardDataList = self:getRewardDataList()
    local tbl = {}
    for _, id in ipairs(self._serverInfo.rewardIds or {}) do
        tbl[tostring(id)] = true
    end

    for _, data in ipairs(rewardDataList) do
        if tonumber(data.expectation) <= self._serverInfo.currNum and not tbl[tostring(data.id)] then
            -- 可领取，并未领取
            return true
        end
    end

    return false
end

function QActivityZhangbichen:setActivityClickedToday(activityId)
	if not self.isOpen or not activityId then return end
	if app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(activityId) then
		app:getUserOperateRecord():recordeCurrentTime(activityId)
	end
end

function QActivityZhangbichen:isActivityClickedToday(activityId)
	if not self.isOpen or not activityId then return end
	return not app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(activityId)
end

--------------数据储存.KUMOFLAG.--------------

function QActivityZhangbichen:getServerInfo()
	return self._serverInfo
end

--------------對外工具.KUMOFLAG.--------------

function QActivityZhangbichen:isInTheGame()
    return self._isIntheGame
end

function QActivityZhangbichen:setInthenGame(b )
    self._isIntheGame = b
end
--实现活动的代理方法
function QActivityZhangbichen:getWidget(activityInfo, parent)
    local widget
    if activityInfo.activityId == self.quanfuyinlangActivityId then
        widget = QUIWidgetZhangbichenActivity.new({parent = parent})
    elseif activityInfo.activityId == self.yuyinniaoniaoActivityId then
        widget = QUIWidgetZhangbichenActivityGame.new()
    elseif activityInfo.activityId == self.yinyuehuodongActivityId then
        widget = QUIWidgetZhangbichenActivityYinyuehuodong.new()
    elseif activityInfo.activityId == self.lanyinsedehaiActivityId then
        widget = QUIWidgetZhangbichenActivityLanyinsedehai.new()
    end
    return widget
end

function QActivityZhangbichen:getBtnTips(activityInfo)
    if activityInfo.activityId == self.quanfuyinlangActivityId then
        if self:checkRewardCanGet() then
            -- 有奖励待领取
            return true
        end
    elseif activityInfo.activityId == self.yuyinniaoniaoActivityId then
        if not self:isActivityClickedToday(activityInfo.activityId) then
            -- 今日未进入过功能
            return true
        end
    end
    return false
end

function QActivityZhangbichen:getChatWords( )
    if q.isEmpty(self._musicGameWords) then
        self._musicGameWords = {}
        local musicGameWords = db:getStaticByName("music_game_words")
        for _,v in pairs(musicGameWords) do
            table.insert(self._musicGameWords,v)
        end

        table.sort( self._musicGameWords, function( a,b)
            return a.id < b.id
        end )
    end

    local maxNum = #self._musicGameWords
    
    local randomNum = math.random(1,maxNum)
    if self._musicGameWords[randomNum] then
        return self._musicGameWords[randomNum].word or ""
    end

    return ""
end

function QActivityZhangbichen:getGameConfig(gameId)
    local gameId = gameId or self._curGameId
    
    if not self._musicGameDataDic[tostring(gameId)] then
        local musicGameConfig = db:getStaticByName("music_game")
        for _, config in pairs(musicGameConfig) do
            if tostring(config.id) == tostring(gameId) then
                self._musicGameDataDic[tostring(gameId)] = config
                break
            end
        end
    end
    
    return self._musicGameDataDic[tostring(gameId)]
end

function QActivityZhangbichen:getMusicIconDataList(gameId)
    local returnTbl = {}
    local gameConfig = self:getGameConfig(gameId)

    if not gameConfig then
        return returnTbl
    end

    local musicGameMelodyConfig = db:getStaticByName("music_game_melody")
    local curGameMelodyId = gameConfig.game_melody_id or gameConfig[" game_melody_id"]
    if musicGameMelodyConfig[tostring(curGameMelodyId)] then
        local configs = musicGameMelodyConfig[tostring(curGameMelodyId)] 
        for _, config in pairs(configs) do
            table.insert(returnTbl, config)
        end
    else
        for _, configs in pairs(musicGameMelodyConfig) do
            for _, config in pairs(configs) do
                if tostring(config.id) == tostring(curGameMelodyId) then
                    table.insert(returnTbl, config)
                end
            end
        end
    end

    table.sort(returnTbl, function(a, b) 
        return tonumber(a.start_time) < tonumber(b.start_time)    
    end)
    
    return returnTbl
end

function QActivityZhangbichen:getMaxScore(gameId)
    local gameConfig = self:getGameConfig(gameId)
    local maxScore = 0
    if gameConfig.max_score then
        maxScore = tonumber(gameConfig.max_score)
    else
        local curMusicIconDataList = self:getMusicIconDataList()
        local curCombo = 1
        
        for _, data in ipairs(curMusicIconDataList) do
            maxScore = maxScore + self:getScore(data.base_score, gameConfig.perfect_coefficient, curCombo, gameId)
        end
    end

    return maxScore
end

function QActivityZhangbichen:getScore(baseScore, levelCoefficient, curCombo, gameId)
    local gameConfig = self:getGameConfig(gameId)
    local comboCoefficient = 0
    if gameConfig then
        local comboCondition = gameConfig.combo_condition
        local comboCoefficientAdd = gameConfig.combo_coefficient_add
        comboCoefficient = gameConfig.combo_coefficient
        if comboCondition and comboCoefficientAdd then
            comboCoefficient = comboCoefficient + math.floor(curCombo/comboCondition) * comboCoefficientAdd
        end
        if gameConfig.combo_max_coefficient and comboCoefficient > gameConfig.combo_max_coefficient then
            comboCoefficient = gameConfig.combo_max_coefficient
        end
    end
    
    return baseScore * levelCoefficient * comboCoefficient, comboCoefficient
end

function QActivityZhangbichen:getLevel(config, time)
    local perfectTime = tonumber(config.start_time) + tonumber(config.perfect_time)
    if config.perfect_offset and time >= perfectTime - tonumber(config.perfect_offset) and time <= perfectTime + tonumber(config.perfect_offset) then
        -- perfect level
        return self.SCORE_LEVEL.perfect
    elseif config.great_offset and time >= perfectTime - tonumber(config.great_offset) and time <= perfectTime + tonumber(config.great_offset) then
        -- great level
        return self.SCORE_LEVEL.great
    elseif config.good_offset and time >= perfectTime - tonumber(config.good_offset) and time <= perfectTime + tonumber(config.good_offset) then
        -- good level
        return self.SCORE_LEVEL.good
    elseif config.bad_offset and time >= perfectTime - tonumber(config.bad_offset) and time <= perfectTime + tonumber(config.bad_offset) then
        -- bad level
        return self.SCORE_LEVEL.bad
    elseif config.miss_offset and time >= perfectTime - tonumber(config.miss_offset) and time <= perfectTime + tonumber(config.miss_offset) then
        -- miss level
        return self.SCORE_LEVEL.miss
    end

    return self.SCORE_LEVEL.none
end

function QActivityZhangbichen:getLevelCoefficientByLevel(level, gameId)
    local gameConfig = self:getGameConfig(gameId)
    if not gameConfig then return 0 end

    local levelStr = self:levelToString(level)
    return gameConfig[levelStr.."_coefficient"] or 0
end

function QActivityZhangbichen:levelToString(level)
    if level == self.SCORE_LEVEL.perfect then
        return "perfect"
    elseif level == self.SCORE_LEVEL.great then
        return "great"
    elseif level == self.SCORE_LEVEL.good then
        return "good"
    elseif level == self.SCORE_LEVEL.bad then
        return "bad"
    elseif level == self.SCORE_LEVEL.miss then
        return "miss"
    end
end

function QActivityZhangbichen:getRewardDataList()
    if self._rewardDataList then return self._rewardDataList end

    self._rewardDataList = {}
    local config = db:getStaticByName("theme_formal_activity_reward")
    for _, value in pairs(config) do
        table.insert(self._rewardDataList, value)
    end
    table.sort(self._rewardDataList, function(a, b)
            return a.expectation < b.expectation
        end)

    return self._rewardDataList
end

--------------数据处理.KUMOFLAG.--------------

function QActivityZhangbichen:responseHandler( response, successFunc, failFunc )
    -- QKumo( response )

    -- optional int32 currNum=1;       //量表作假的音浪值
    -- optional int32 remainCount = 2; //剩余可领的音乐游戏奖励的次数
    -- repeated int32 rewardIds = 3;   //已经领取的进度奖励的id
    if response.themeFormalActivityResponse and response.error == "NO_ERROR" then
    	self._serverInfo = response.themeFormalActivityResponse or {}
    end

    if successFunc then 
        successFunc(response) 
        self:_handleEvent()
        return
    end

    if failFunc then 
        failFunc(response)
    end

    self:_handleEvent()
end

function QActivityZhangbichen:pushHandler( data )
    -- QPrintTable(data)
end

-- //主题曲正式活动
-- THEME_FORMAL_GET_MAIN_INFO              =10134;      //主界面信息ThemeFormalActivityResponse
-- THEME_FORMAL_GET_SCORE_REWARD           =10135;      //领取音浪值进度奖励  ThemeFormalScoreRewardRequest   ThemeFormalActivityResponse
-- THEME_FORMAL_PLAY_REWARD                =10136;      //领取游戏评级奖励   ThemeFormalPlayRewardRequest   ThemeFormalActivityResponse

function QActivityZhangbichen:zhangbichenFormalMainInfoRequest(success, fail, status)
    local request = { api = "THEME_FORMAL_GET_MAIN_INFO"}
    app:getClient():requestPackageHandler("THEME_FORMAL_GET_MAIN_INFO", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional int32 id = 1; //领奖进度id
function QActivityZhangbichen:zhangbichenFormalScoreRewardRequest(id, success, fail, status)
	local themeFormalScoreRewardRequest = {id = id}
    local request = { api = "THEME_FORMAL_GET_SCORE_REWARD", themeFormalScoreRewardRequest = themeFormalScoreRewardRequest}
    app:getClient():requestPackageHandler("THEME_FORMAL_GET_SCORE_REWARD", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional int32 grade  = 1; //本次小游戏的评级，领取音乐小游戏评级奖励:1-B;2-A;3-S;4-SS;
function QActivityZhangbichen:zhangbichenPreheatExpectRequest(grade, success, fail, status)
    local themeFormalPlayRewardRequest = { grade = grade }
    local request = { api = "THEME_FORMAL_PLAY_REWARD", themeFormalPlayRewardRequest = themeFormalPlayRewardRequest}
    app:getClient():requestPackageHandler("THEME_FORMAL_PLAY_REWARD", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--------------本地工具.KUMOFLAG.--------------

function QActivityZhangbichen:_handleEvent()
    remote.activityRounds:dispatchEvent({name = remote.activityRounds.ZHANGBICHEN_UPDATE})
end

-- 加入到活動數據裡，讓主界面顯示icon
function QActivityZhangbichen:_loadActivity()
    if self.isOpen then
        local activities = {}
        local themeInfo = db:getActivityThemeInfoById(QActivity.THEME_ACTIVITY_ZHANGBICHEN_FORMAL) or {}
        table.insert(activities, {
            activityId = self.quanfuyinlangActivityId, 
            title = "全服音浪",
            roundType = "THEME_FORMAL",
            start_at = self.startAt * 1000, 
            end_at = self.endAt * 1000,
            award_at = self.startAt * 1000, 
            -- award_end_at = self.showEndAt * 1000, 
            banner = "ui/update_zhangbichen/formal/sp_quanfuyinlang_title.png",
            background = "activity_zbc_bg.jpg",
            description = "听主题曲，玩小游戏，领丰厚奖励~",
            weight = 90, 
            targets = {}, 
            subject = QActivity.THEME_ACTIVITY_ZHANGBICHEN_FORMAL})
        table.insert(activities, {
        	activityId = self.yuyinniaoniaoActivityId, 
        	title = "余音袅袅",
        	roundType = "THEME_FORMAL",
        	start_at = self.startAt * 1000, 
        	end_at = self.endAt * 1000,
        	award_at = self.startAt * 1000, 
        	-- award_end_at = self.showEndAt * 1000, 
            banner = "ui/update_zhangbichen/formal/sp_yuyinniaoniao_title.png",
            background = "ui/update_zhangbichen/formal/sp_yuyinniaoniao_bg.jpg",
            description = "",
        	weight = 89, 
        	targets = {}, 
        	subject = QActivity.THEME_ACTIVITY_ZHANGBICHEN_FORMAL})
        table.insert(activities, {
            activityId = self.yinyuehuodongActivityId, 
            title = "音乐活动",
            roundType = "THEME_FORMAL",
            start_at = self.startAt * 1000, 
            end_at = self.endAt * 1000,
            award_at = self.startAt * 1000, 
            award_end_at = self.showEndAt * 1000, 
            banner = "ui/update_zhangbichen/formal/sp_yinyuehuodong_title.png",
            background = "activity_zbc_bg.jpg",
            description = "",
            weight = 9, 
            targets = {}, 
            subject = QActivity.THEME_ACTIVITY_ZHANGBICHEN_FORMAL})
        table.insert(activities, {
            activityId = self.lanyinsedehaiActivityId, 
            title = "蓝银色的海", 
            roundType = "THEME_FORMAL",
            start_at = self.startAt * 1000, 
            end_at = self.endAt * 1000,
            award_at = self.startAt * 1000, 
            award_end_at = self.showEndAt * 1000, 
            banner = "ui/update_zhangbichen/formal/sp_lanyinsedehai_title.png",
            background = "activity_zbc_bg.jpg",
            description = "",
            weight = 8, 
            targets = {}, 
            subject = QActivity.THEME_ACTIVITY_ZHANGBICHEN_FORMAL})
        remote.activity:setData(activities)
    else
        remote.activity:removeActivity(self.activityId)
    end
end

return QActivityZhangbichen