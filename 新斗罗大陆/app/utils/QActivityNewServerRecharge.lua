
local QActivityRoundsBaseChild = import(".QActivityRoundsBaseChild")
local QActivityNewServerRecharge = class("QActivityNewServerRecharge",QActivityRoundsBaseChild)


function QActivityNewServerRecharge:ctor(luckType)
    QActivityNewServerRecharge.super.ctor(self,luckType)
    cc.GameObject.extend(self)
    self._newServerRechargeConfigs = db:getStaticByName("new_server_recharge")
	self:resetData()
end

function QActivityNewServerRecharge:resetData( )
    self._newServerRechargeData = {}
    self._newServerRechargePromptRecord = {}

end


function QActivityNewServerRecharge:getNewServerRechargePromptRecordByThemeId( themeId )
    return self._newServerRechargePromptRecord[themeId] or false
end

function QActivityNewServerRecharge:setNewServerRechargePromptRecordByThemeId( themeId )
    self._newServerRechargePromptRecord[themeId] = true
end

function QActivityNewServerRecharge:getNewServerRechargeConfigsByRowNum( rowNum )
	local atyConfig = {}
	for _,v in pairs(self._newServerRechargeConfigs or {}) do
		if rowNum == tonumber(v.row_num) then
			table.insert(atyConfig,v)
		end
	end

	return atyConfig
end

function QActivityNewServerRecharge:getNewServerRechargeConfigByRowNum( activityId )
	for _,v in pairs(self._newServerRechargeConfigs or {}) do
		if self.rowNum == tonumber(v.row_num) and activityId == tonumber(v.activity_id)  then
			return v
		end
	end
	return nil
end

function QActivityNewServerRecharge:getNewServerRechargeConfigByThemeId( themeId )

    for _,v in pairs(self._newServerRechargeConfigs or {}) do
        if self.rowNum == tonumber(v.row_num) and themeId == tonumber(v.theme_id)  then
            return v
        end
    end
    return nil
end

function QActivityNewServerRecharge:checkNeedPromptByThemeId( themeId )
    local showed = self:getNewServerRechargePromptRecordByThemeId(themeId)
    if not showed then
        local svrData = self:getNewServerRechargeSvrDataByThemeId(themeId)
        if svrData and svrData.completeCount and  svrData.completeCount > 0 and  svrData.awardCount  and  svrData.awardCount <= 0 then
            local curTime = q.serverTime()
            local endTime = svrData.endAt / 1000
            if curTime > endTime then
                return false
            end
            return true
        end
    end

    return false
end


-----------------------------------------------------------------------------------------------------------
function QActivityNewServerRecharge:timeRefresh( event )
	-- body
	if event.time and event.time == 0 then
		remote.activityRounds:dispatchEvent({name = remote.activityRounds.NEW_SERVER_RECHARGE_UPDATE})
	end
end

function QActivityNewServerRecharge:activityShowEndCallBack(  )
	-- body
	remote.activityRounds:dispatchEvent({name = remote.activityRounds.NEW_SERVER_RECHARGE_UPDATE})
end

function QActivityNewServerRecharge:activityEndCallBack(  )
	-- body
	remote.activityRounds:dispatchEvent({name = remote.activityRounds.NEW_SERVER_RECHARGE_UPDATE})
end

function QActivityNewServerRecharge:handleOnLine( )
	-- body
	if self:checkIsOpen() then
		self:_loadActivity()
	end
	remote.activityRounds:dispatchEvent({name = remote.activityRounds.NEW_SERVER_RECHARGE_UPDATE})
end

function QActivityNewServerRecharge:handleOffLine( )
	-- body
	remote.activityRounds:dispatchEvent({name = remote.activityRounds.NEW_SERVER_RECHARGE_UPDATE})
end

function QActivityNewServerRecharge:removeSelf( )
	QActivityNewServerRecharge.super.removeSelf(self)
	self:resetData()
end

function QActivityNewServerRecharge:getActivityInfoWhenLogin( success, fail )
	if self:checkIsOpen() then
		self:newServerRechargeGetMainInfoRequest(function ( )
            -- body
            self:_loadActivity()
        end)
	end	
end


function QActivityNewServerRecharge:checkIsOpen()
	-- return true
	return self.isOpen
end

function QActivityNewServerRecharge:checkRewardCanGet()
    if q.isEmpty(self._newServerRechargeData) then return false end

    for k,v in pairs(self._newServerRechargeData or {} ) do
        if v.buyCount > v.awardCount then
            return true
        end
    end

    return false
end

function QActivityNewServerRecharge:checkRedTips(themeId)
    if self:checkIsOpen() then
        local info = self:getNewServerRechargeConfigByThemeId(themeId)
        if info then
            local svrData = self:getNewServerRechargeSvrDataByAtyId(info.activity_id)
            if svrData then
                if svrData.awardCount and svrData.awardCount < svrData.buyCount then
                    return true
                end
            end
        end
    end
    return false
end


function QActivityNewServerRecharge:_handleEvent()
    remote.activityRounds:dispatchEvent({name = remote.activityRounds.NEW_SERVER_RECHARGE_UPDATE})
end

-- 加入到活動數據裡，讓主界面顯示icon
function QActivityNewServerRecharge:_loadActivity()
    if self.isOpen  then
        local activities = {}
        local configs = self:getNewServerRechargeConfigsByRowNum(self.rowNum)
        for k,v in pairs(configs or {}) do
            -- QPrintTable(v)
            local svrData = self:getNewServerRechargeSvrDataByAtyId(v.activity_id)
            -- QPrintTable(svrData)
            if svrData and svrData.completeCount and svrData.completeCount >= 1 then
                local themeInfo = db:getActivityThemeInfoById(v.theme_id) or {}
                    table.insert(activities, {
                        activityId = v.activity_id, 
                        title = (themeInfo.title or "超值活动"), 
                        start_at = self.startAt * 1000, 
                        end_at = svrData.endAt ,
                        award_at = self.startAt * 1000, 
                        award_end_at = svrData.endAt , 
                        weight = 20, 
                        targets = {}, 
                        subject = v.theme_id
                        })
            end
        end
        QPrintTable(activities)
        remote.activity:setData(activities)
    else
        local configs = self:getNewServerRechargeConfigsByRowNum(self.rowNum)
        for k,v in pairs(configs or {}) do
            remote.activity:removeActivity(v.activity_id)
        end
    end
end


function QActivityNewServerRecharge:getNewServerRechargeSvrDataByThemeId( themeId )
    local info = self:getNewServerRechargeConfigByThemeId(themeId)
    if info then
        return self:getNewServerRechargeSvrDataByAtyId(info.activity_id)
    end
    return nil
end

function QActivityNewServerRecharge:getNewServerRechargeSvrDataByAtyId( activityId )
    return self._newServerRechargeData[activityId] or nil 
end


function QActivityNewServerRecharge:updateDataBySvr( data )
    for k,v in pairs(data or {}) do
        self._newServerRechargeData[v.activityId] = v
    end
end

-- 	NEW_SERVER_RECHARGE_GET_MAIN_INFO = 10232; //新服充值主界面信息 无request response NewServerRechargeResponse
--	NEW_SERVER_RECHARGE_GET_REWARD = 10233; //新服充值领取奖励 NewServerRechargeGetRewardRequest response NewServerRechargeResponse


function QActivityNewServerRecharge:updateSvrData( response )
    if response.newServerRechargeResponse and response.newServerRechargeResponse.userInfoList then
        self:updateDataBySvr(response.newServerRechargeResponse.userInfoList)
    end
    self:_loadActivity()
end

function QActivityNewServerRecharge:responseHandler( response, successFunc, failFunc )
    
	if response.newServerRechargeResponse and response.newServerRechargeResponse.userInfoList then
        self:updateDataBySvr(response.newServerRechargeResponse.userInfoList)
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


-- /*********************************新服直冲活动 start*******************/
-- /**
--   * 获取主界面信息
--   */
-- message NewServerRechargeGetMainInfoRequest {
-- }

-- /**
--   * 领取奖励
--   */
-- message NewServerRechargeGetRewardRequest {
--     optional int32 activityId = 1; //活动id
--     optional int32 index = 2; //哪一个奖励，如果不是单选的不需要传 1 2 3 4
-- }

-- /**
--   * 信息
--   */
-- message NewServerRechargeUserInfo {
--     optional string activityId = 1; //活动Id
--     optional int32 completeCount = 2; //完成次数（这里是目标的完成逻辑）
--     optional int32 completeProgress = 3; //完成进度（这里是目标的完成逻辑）
--     optional int32 buyCount = 4; //激活588的次数
--     optional int32 awardCount = 5; //领取588奖励的次数
--     optional int64 endAt = 6; //结束时间
-- }

-- /**
-- * 响应
-- */
-- message NewServerRechargeResponse {
--     repeated NewServerRechargeUserInfo userInfoList = 1; //玩家所有的活动完成情况
-- }
-- /*********************************新服直冲活动 end*****************/

function QActivityNewServerRecharge:newServerRechargeGetMainInfoRequest(success, fail)
    local request = {api = "NEW_SERVER_RECHARGE_GET_MAIN_INFO"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end


function QActivityNewServerRecharge:newServerRechargeGetRewardRequest(activityId,index,success, fail)
    local newServerRechargeGetRewardRequest = {activityId = activityId , index = index }
    QPrintTable(newServerRechargeGetRewardRequest)
    local request = {api = "NEW_SERVER_RECHARGE_GET_REWARD" , newServerRechargeGetRewardRequest = newServerRechargeGetRewardRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

return QActivityNewServerRecharge

