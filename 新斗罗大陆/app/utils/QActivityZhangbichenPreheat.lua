-- 
-- Kumo.Wang
-- 张碧晨主题器曲预热活动数据类
--

local QActivityRoundsBaseChild = import(".QActivityRoundsBaseChild")
local QActivityZhangbichenPreheat = class("QActivityZhangbichenPreheat", QActivityRoundsBaseChild)

local QActivity = import(".QActivity")
local QNavigationController = import("..controllers.QNavigationController")
local QUIViewController = import("..ui.QUIViewController")

function QActivityZhangbichenPreheat:ctor( ... )
	QActivityZhangbichenPreheat.super.ctor(self,...)

	self._serverInfo = {}
end

-- 活动界面关闭
function QActivityZhangbichenPreheat:activityShowEndCallBack()
	self:handleOffLine()
end

-- 活动结束（界面未必关闭）
function QActivityZhangbichenPreheat:activityEndCallBack()
	self:_handleEvent()
end

function QActivityZhangbichenPreheat:handleOnLine()
	if self.isOpen then
		self:_loadActivity()
		self:zhangbichenPreheatMainInfoRequest()
	end
end

function QActivityZhangbichenPreheat:handleOffLine()
	remote.activity:removeActivity(self.activityId)
	remote.activity:refreshActivity(true)
    self.isOpen = false
	self:_handleEvent()
end

function QActivityZhangbichenPreheat:getActivityInfoWhenLogin()
	if self.isOpen then
		self:_loadActivity()
		self:zhangbichenPreheatMainInfoRequest()
	end
end

function QActivityZhangbichenPreheat:timeRefresh( event )
	if event.time and event.time == 0 then
		if self.isOpen then
			self:zhangbichenPreheatMainInfoRequest()
		end
	end
end

function QActivityZhangbichenPreheat:checkActivityComplete()
    if not self.isOpen or not self.isActivityNotEnd then
		return false
	end

    if not self:isActivityClickedToday() then
        -- 今日未进入过功能
        return true
    end

    if self:checkRewardCanGet() then
        -- 有奖励待领取
        return true
    end

    return false
end

function QActivityZhangbichenPreheat:checkRewardCanGet()
    if q.isEmpty(self._serverInfo) then return end

    local rewardDataList = self:getRewardDataList()
    local tbl = {}
    for _, id in ipairs(self._serverInfo.rewardIds or {}) do
        tbl[tostring(id)] = true
    end

    for _, data in ipairs(rewardDataList) do
        if tonumber(data.expectation) <= self._serverInfo.currExpectation and not tbl[tostring(data.id)] then
            -- 可领取，并未领取
            return true
        end
    end

    return false
end

function QActivityZhangbichenPreheat:setActivityClickedToday()
	if not self.isOpen or not self.activityId then return end

	if app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(self.activityId) then
		app:getUserOperateRecord():recordeCurrentTime(self.activityId)
	end
end

function QActivityZhangbichenPreheat:isActivityClickedToday()
	if not self.isOpen or not self.activityId then return end
	
	return not app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(self.activityId)
end

--------------数据储存.KUMOFLAG.--------------

function QActivityZhangbichenPreheat:getServerInfo()
	return self._serverInfo
end

--------------對外工具.KUMOFLAG.--------------

function QActivityZhangbichenPreheat:getCountdownTime()
	-- 开售时间 2020年4月30日0点0分0秒
    -- local onSaleTime = q.OSTime({day=30, month=4, year=2020, hour=0, minute=0, second=0}) * 1000
    -- dldl-30146
	local onSaleTime = (self.endAt or q.OSTime({day=30, month=4, year=2020, hour=0, minute=0, second=0})) * 1000
	local curTime = q.serverTime() * 1000
	local countdownTime = onSaleTime - curTime

	return countdownTime
end

function QActivityZhangbichenPreheat:getRewardDataList()
	if self._rewardDataList then return self._rewardDataList end

	self._rewardDataList = {}
	local config = db:getStaticByName("theme_preheat_reward")
	for _, value in pairs(config) do
		table.insert(self._rewardDataList, value)
	end
	table.sort(self._rewardDataList, function(a, b)
			return a.expectation < b.expectation
		end)

	return self._rewardDataList
end

--------------数据处理.KUMOFLAG.--------------

function QActivityZhangbichenPreheat:responseHandler( response, successFunc, failFunc )
    -- QKumo( response )

    -- optional bool alreadyExpected = 1; //true表示已期待
    -- optional int32 currExpectation = 2; //当前期待值
    -- repeated int32 rewardIds = 3; //已经领取奖励的id
    if response.themePreActivityExpectResponse and response.error == "NO_ERROR" then
    	self._serverInfo = response.themePreActivityExpectResponse or {}
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

function QActivityZhangbichenPreheat:pushHandler( data )
    -- QPrintTable(data)
end

-- THEME_PREHEAT_GET_MAIN_INFO                 =10127;                    //张碧晨主题器曲预热活动--主界面信息reponse  ThemePreActivityExpectResponse
-- THEME_PREHEAT_GET_REWARD                    =10128;                    //张碧晨主题器曲预热活动--领取奖励 request ThemePreActivityExpectRequest  reponse ThemePreActivityExpectResponse
-- THEME_PREHEAT_EXPECT                        =10129;                    //张碧晨主题器曲预热活动--期待主题曲  reponse ThemePreActivityExpectResponse

function QActivityZhangbichenPreheat:zhangbichenPreheatMainInfoRequest(success, fail, status)
    local request = { api = "THEME_PREHEAT_GET_MAIN_INFO"}
    app:getClient():requestPackageHandler("THEME_PREHEAT_GET_MAIN_INFO", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional int32 id = 1; //领奖进度id
function QActivityZhangbichenPreheat:zhangbichenPreheatGetRewardRequest(id, success, fail, status)
	local themePreActivityExpectRequest = {id = id}
    local request = { api = "THEME_PREHEAT_GET_REWARD", themePreActivityExpectRequest = themePreActivityExpectRequest}
    app:getClient():requestPackageHandler("THEME_PREHEAT_GET_REWARD", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

function QActivityZhangbichenPreheat:zhangbichenPreheatExpectRequest(success, fail, status)
    local request = { api = "THEME_PREHEAT_EXPECT"}
    app:getClient():requestPackageHandler("THEME_PREHEAT_EXPECT", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--------------本地工具.KUMOFLAG.--------------

function QActivityZhangbichenPreheat:_handleEvent()
    remote.activityRounds:dispatchEvent({name = remote.activityRounds.ZHANGBICHEN_PREHEAT_UPDATE})
end

-- 加入到活動數據裡，讓主界面顯示icon
function QActivityZhangbichenPreheat:_loadActivity()
    if self.isOpen then
        local activities = {}
        local themeInfo = db:getActivityThemeInfoById(QActivity.THEME_ACTIVITY_ZHANGBICHEN_PREHEAT) or {}
        table.insert(activities, {
        	activityId = self.activityId, 
        	title = (themeInfo.title or ""), 
        	roundType = "THEME_PREHEAT",
        	start_at = self.startAt * 1000, 
        	end_at = self.endAt * 1000,
        	award_at = self.startAt * 1000, 
        	award_end_at = self.showEndAt * 1000, 
        	weight = 20, 
        	targets = {}, 
        	subject = QActivity.THEME_ACTIVITY_ZHANGBICHEN_PREHEAT})
        remote.activity:setData(activities)
    else
        remote.activity:removeActivity(self.activityId)
    end
end

return QActivityZhangbichenPreheat