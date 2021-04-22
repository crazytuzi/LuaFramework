-- 
-- Kumo.Wang
-- 张碧晨主题器曲预热活动数据类
--

local QActivityRoundsBaseChild = import(".QActivityRoundsBaseChild")
local QActivityHighTea = class("QActivityHighTea", QActivityRoundsBaseChild)

local QActivity = import(".QActivity")
local QNavigationController = import("..controllers.QNavigationController")
local QUIViewController = import("..ui.QUIViewController")

QActivityHighTea.GET_FREE_AWARD = "GET_FREE_AWARD"

function QActivityHighTea:ctor( ... )
	QActivityHighTea.super.ctor(self,...)

	self._highTeaData = {}
end

-- 活动界面关闭
function QActivityHighTea:activityShowEndCallBack()
	self:handleOffLine()
end

-- 活动结束（界面未必关闭）
function QActivityHighTea:activityEndCallBack()
	self:_handleEvent()
end

function QActivityHighTea:handleOnLine()
	if self.isOpen and self:checkHighTeaIsUnLock() then
		self:_loadActivity()
		self:weeklyGameHighTeaMainInfoRequest()
	end
end

function QActivityHighTea:handleOffLine()
	remote.activity:removeActivity(self.activityId)
	remote.activity:refreshActivity(true)
    self.isOpen = false
	self:_handleEvent()
end

function QActivityHighTea:getActivityInfoWhenLogin()
	if self.isOpen and self:checkHighTeaIsUnLock() then
		self:_loadActivity()
		self:weeklyGameHighTeaMainInfoRequest()
	end
end

function QActivityHighTea:timeRefresh( event )
	if event.time and event.time == 0 then
		if self.isOpen and self:checkHighTeaIsUnLock()  then
			self:weeklyGameHighTeaMainInfoRequest()
		end
	end
end

function QActivityHighTea:checkActivityComplete()
    if not self.isOpen or not self.isActivityNotEnd or not self:checkHighTeaIsUnLock() then
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


function QActivityHighTea:checkHighTeaIsUnLock()

    if not app.unlock:checkLock("UNLOCK_HIGHTEA", false)  then
        return false
    end
    return true
end


function QActivityHighTea:checkRewardCanGet()
    if q.isEmpty(self._highTeaData) then return false end

    local rewardDataList = self:getHighTeaLevelRewardLevels()

    if q.isEmpty(rewardDataList) then return false end

    return true
end


function QActivityHighTea:setActivityClickedToday()
    if not self.isOpen or not self.activityId or not self:checkHighTeaIsUnLock() then return end

    if app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(self.activityId) then
        app:getUserOperateRecord():recordeCurrentTime(self.activityId)
    end
end

function QActivityHighTea:isActivityClickedToday()
    if not self.isOpen or not self.activityId or not self:checkHighTeaIsUnLock()  then return end
    
    return not app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(self.activityId)
end



--获取下午茶好感度等级
function QActivityHighTea:getHighTeaLevel()
    if self._highTeaData and self._highTeaData.level then
        return self._highTeaData.level
    end
    return 0
end

--获取下午茶现在心情
function QActivityHighTea:getHighTeaMood()
    if self._highTeaData and self._highTeaData.nowMood then
        return self._highTeaData.nowMood
    end
    return 1
end

--获取下午茶总好感度值
function QActivityHighTea:getHighTeaTotalExp()
    if self._highTeaData and self._highTeaData.exp then
        return self._highTeaData.exp
    end
    return 0
end

--获取是否领取过每期活动的免费奖励
function QActivityHighTea:getHighTeaFreeAward( )
    QPrintTable(self._highTeaData)
    if self._highTeaData and self._highTeaData.freeAwardGot then
        return self._highTeaData.freeAwardGot
    end

    return false
end
--获取下午茶当前等级剩余好感度值
function QActivityHighTea:getHighTeaCurExp()
    local myTotalExp = self:getHighTeaTotalExp()
    local mycurLevel = self:getHighTeaLevel()
    local levelExp = 0
    if mycurLevel > 0 then
        for i=1,mycurLevel  do
            local config = remote.activity:getHighTeaRewardConfigByLevel(i)
            if config.exp then
                levelExp = levelExp + tonumber(config.exp)
            end
        end
    end
    levelExp = myTotalExp - levelExp
    return levelExp
end


--获取下午茶吃的奖励
function QActivityHighTea:getHighTeaEatPrizes()
    if self._highTeaData and self._highTeaData.eatPrizes then
        return self._highTeaData.eatPrizes or {}
    end
    return {}
end

function QActivityHighTea:setHighTeaEatPrizes()
    if self._highTeaData and self._highTeaData.eatPrizes then
        self._highTeaData.eatPrizes = {}
    end
end


--获取下午茶等级的奖励
function QActivityHighTea:getHighTeaLevelPrizes()
    if self._highTeaData and self._highTeaData.levelUpPrizes then
        return self._highTeaData.levelUpPrizes or {}
    end
    return {}
end

function QActivityHighTea:setHighTeaLevelPrizes()
    if self._highTeaData and self._highTeaData.levelUpPrizes then
        self._highTeaData.levelUpPrizes = {}
    end
end

--获取下午茶目标的奖励
function QActivityHighTea:getHighTeaProjectPrizes()
    if self._highTeaData and self._highTeaData.projectPrizes then
        return self._highTeaData.projectPrizes or {}
    end
    return {}
end

function QActivityHighTea:setHighTeaProjectPrizes()
    if self._highTeaData and self._highTeaData.projectPrizes then
        self._highTeaData.projectPrizes = {}
    end
end

function QActivityHighTea:checkIsGetHighTeaLoginReward()
    if self._highTeaData and self._highTeaData.loginReward then
        return self._highTeaData.loginReward
    end
    return false
end

function QActivityHighTea:checkGettenProjectRewardByLevel(level)
    if self._highTeaData then
        for k,v in pairs(self._highTeaData.levelReward or {}) do
            if v == level then
                return true
            end
        end
    end
    return false
end


function QActivityHighTea:getHighTeaLevelRewardLevels()
    local result = {}

    if self._highTeaData then
        local targetLv = self:getHighTeaLevel()
        if targetLv > 0 then
            for i=1,targetLv do
                local lvConfig =  remote.activity:getHighTeaRewardConfigByLevel(i)
                if lvConfig.project_reward then
                    local isGetten = self:checkGettenProjectRewardByLevel(i)
                    if not isGetten then
                        table.insert(result,i)
                    end
                end
            end
        end
    end

    return result
end

function QActivityHighTea:checkCanCookFoodRedTips()
    local foodConfigs = remote.activity:getHighTeaFoodConfig()

    for k,v in pairs(foodConfigs or {}) do
        local awardsTbl  = string.split(v.source_item, ";")
        local canCook = 1
        local itemNeedTable = {}
        for i,itemId in ipairs(awardsTbl) do

            if itemNeedTable[itemId] then
                itemNeedTable[itemId] = itemNeedTable[itemId] + 1
            else
                itemNeedTable[itemId] = 1
            end
        end

        for k,v in pairs(itemNeedTable or {}) do
            local num = remote.items:getItemsNumByID(k) or 0
            if num < v then
                canCook = 0
                break
            end         
        end
        if canCook == 1 then
            return true
        end
    end

    return false
end

---


function QActivityHighTea:responseHandler( response, successFunc, failFunc )
    
    --下午茶的返回
    if response.weekPlayTeaResponse ~= nil then
        self._highTeaData = response.weekPlayTeaResponse
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

function QActivityHighTea:pushHandler( data )
    -- QPrintTable(data)
end


function QActivityHighTea:getHighTeaLastTime()
    local currTime = q.serverTime()
    local endTime = self.endAt or 0
   
    endTime = endTime - currTime
    return endTime
end

--下午茶主信息请求
function QActivityHighTea:weeklyGameHighTeaMainInfoRequest(success, fail)
    local request = {api = "WEEK_PLAY_TEA_MAIN_INFO"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--下午茶吃食物请求
function QActivityHighTea:weeklyGameHighTeaEatRequest(itemId , count,success, fail)
    local weekPlayTeaEatFoodRequest = {itemId = itemId , count = count }
    local request = {api = "WEEK_PLAY_TEA_EAT" , weekPlayTeaEatFoodRequest = weekPlayTeaEatFoodRequest }


    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--下午茶合成食物请求
function QActivityHighTea:weeklyGameHighTeaCraftFoodRequest(itemId , count , success, fail)
    local weekPlayTeaCraftFoodRequest = {itemId = itemId , count = count }
    local request = {api = "WEEK_PLAY_TEA_CRAFT_FOOD", weekPlayTeaCraftFoodRequest = weekPlayTeaCraftFoodRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--下午茶领取目标等级奖励
function QActivityHighTea:weekGameHighTeaProjectRewardRequest(levels, success, fail)
    local weekPlayTeaProjectRewardRequest = {level = levels}
    local request = {api = "WEEK_PLAY_TEA_GET_PROJECT_REWARD", weekPlayTeaProjectRewardRequest = weekPlayTeaProjectRewardRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--下午茶领取登录奖励
function QActivityHighTea:weeklyGameHighTeaLoginRewardRequest(success, fail)
    local request = {api = "WEEK_PLAY_TEA_GET_LOGIN_REWARD"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--下午茶领取免费奖励
function QActivityHighTea:weeklyGameHighTeaGetFreeAwardRequest(success, fail)
    local request = {api = "WEEK_PLAY_TEA_GET_FREE_AWARD"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--------------本地工具.KUMOFLAG.--------------

function QActivityHighTea:_handleEvent()
    remote.activityRounds:dispatchEvent({name = remote.activityRounds.HIGHTEA_UPDATE})
end

-- 加入到活動數據裡，讓主界面顯示icon
function QActivityHighTea:_loadActivity()
    if self.isOpen and self:checkHighTeaIsUnLock()  then
        local activities = {}
        local themeInfo = db:getActivityThemeInfoById(QActivity.THEME_ACTIVITY_HIGHTEA) or {}
        table.insert(activities, {
        	activityId = self.activityId, 
        	title = (themeInfo.title or "下午茶"), 
        	roundType = "WEEK_PLAY_TEA",
        	start_at = self.startAt * 1000, 
        	end_at = self.endAt * 1000,
        	award_at = self.startAt * 1000, 
        	award_end_at = self.showEndAt * 1000, 
        	weight = 20, 
        	targets = {}, 
        	subject = QActivity.THEME_ACTIVITY_HIGHTEA
            })
        remote.activity:setData(activities)
    else
        remote.activity:removeActivity(self.activityId)
    end
end

return QActivityHighTea