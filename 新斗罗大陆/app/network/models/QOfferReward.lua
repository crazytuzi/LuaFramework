-- qinsiyang
-- 悬赏任务数据类


local QBaseModel = import("...models.QBaseModel")
local QOfferReward = class("QOfferReward",QBaseModel)

local QUIViewController = import("...ui.QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QNotificationCenter = import("...controllers.QNotificationCenter")


QOfferReward.EVENT_REFRESH="QOFFER_REWARD_EVENT_REFRESH"
QOfferReward.INFO_REFRESH="QOFFER_REWARD_INFO_REFRESH"


function QOfferReward:ctor(options)
	QOfferReward.super.ctor(self)
end

function QOfferReward:init()
    self:resetData()
end


--创建时初始化事件
function QOfferReward:didappear()
    self:resetData()
end

function QOfferReward:resetData()
    self._dispatchList = {}
    self._myInfo = {}
    self._dispatchInfo = {}
    self._borrowInfo = {}
    self._borrowOutInfos = {}
    self._borrowInInfos = {}
    self._rankingHeroInfos = {}
    self._beUsed_HeroIds = {}
    self._actorBorrowCount = 0
    self._applyInfoCount = 0
    self._borrowGenreType = 1

end


function QOfferReward:loginEnd(callback)
   -- --登录时获取一些简单信息

    if self:getUnlockOfferReward(false) 
        and remote.user.userConsortia 
        and remote.user.userConsortia.consortiaId 
        and remote.user.userConsortia.consortiaId ~= ""  then
        self:offerRewardGetMyInfoRequest(callback, callback)
    else
        if callback then
            callback()
        end
    end
end

function QOfferReward:checkOfferRewardInfo()
    -- 进入宗门时判断是否开启魂师派遣玩法，开启且没有数据则请求数据刷新
    if self:getUnlockOfferReward(false) 
        and remote.user.userConsortia 
        and remote.user.userConsortia.consortiaId 
        and remote.user.userConsortia.consortiaId ~= ""  then
        if q.isEmpty(self._myInfo) then
            self:offerRewardGetMyInfoRequest()
        end
    end

end


function QOfferReward:openDialog()
    -- app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogOfferReward", {isPopCurrentDialog = true}})
    if not self:getUnlockOfferReward(true) then
        return
    end

    if not  remote.union:checkHaveUnion() then
        app.tip:floatTip("您未参加宗门，无法开启魂师派遣")
        return
    end

    self:offerRewardGetMainInfoRequest(function(data)
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogOfferReward"
    , {isPopCurrentDialog = true}})
    end)
end


function QOfferReward:openDialogForQuick()
    if not self:getUnlockOfferReward(true) then
        return
    end

    if remote.user.userConsortia and remote.user.userConsortia.consortiaId and remote.user.userConsortia.consortiaId ~= "" then
        
    else
        app.tip:floatTip("您未参加宗门，无法开启魂师派遣")
        return
    end

    self:offerRewardGetMainInfoRequest(function(data)
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogOfferReward"
    ,options = {callback = function ()
            print("EVENT_TASK_UPDATE_BY_DIALOG")
           remote.trailer:dispatchEvent({name = remote.trailer.EVENT_TASK_UPDATE_BY_DIALOG})
        end} , {isPopCurrentDialog = true}})
    end)

end

function QOfferReward:checkBorrowIdCanReturn(_borrowId)
    for k,info in pairs(self._borrowInInfos or {}) do
        if info.borrowId == _borrowId then
            local v =  info.borrowFighter.heros[1]  
            local userId =  info.borrowFighter.userId
            if v and userId and self:checkHeroIsUsed(v.actorId , userId) then
               return false
            end
        end
    end

    return true
end


function QOfferReward:getDispatchHeroInfos()
    local my_have_heros = remote.herosUtil:getHaveHero()
    local heroinfos = {}
    local heroinfosIsUsed = {}

    --租借的
    for k,info in pairs(self._borrowInInfos or {}) do
        local v =  info.borrowFighter.heros[1]  
        local userId =  info.borrowFighter.userId
        if v and userId then
            local info = {}
            info.heroInfo = v
            info.isUsed = self:checkHeroIsUsed(v.actorId , userId)
            info.isMine = false
            info.userId = userId
            info.oType = 1
            info.func = self:getFuncType(v.actorId)
            if info.isUsed then
                table.insert(heroinfosIsUsed ,info)     
            else
                table.insert(heroinfos ,info)     
            end
        end
    end
    --我自己的
    for k,v in pairs(my_have_heros) do
        local heroInfo = remote.herosUtil:getHeroByID(v)
        local info = {}
        info.heroInfo = heroInfo
        info.isUsed = self:checkHeroIsUsed(v , remote.user.userId)
        info.isMine = true
        info.oType = 1
        info.func = self:getFuncType(v)
        info.userId = remote.user.userId
        if info.isUsed then
            table.insert(heroinfosIsUsed ,info)     
        else
            table.insert(heroinfos ,info)     
        end   
    end

    for k,info in ipairs(heroinfosIsUsed) do
        table.insert(heroinfos ,info)     
    end

    return heroinfos
end

function QOfferReward:getFuncType(actorId )
    local characher = db:getCharacterByID(actorId)
    if characher.func_icon == 't' then
        return 2
    elseif characher.func_icon == 'dps_p' then
        return 4
    elseif characher.func_icon == 'dps_m' then
        return 5
    elseif characher.func_icon == 'health' then
        return 3
    end
    return 2
end


function QOfferReward:checkHeroIsUsed(actorId , userId)
    for k,v in pairs(self._beUsed_HeroIds or {}) do
        if v.userId == userId and v.actorId == actorId then
            return true
        end
    end
    return false
end

function QOfferReward:getUnlockOfferReward(isTips)
    return app.unlock:checkLock("UNLOCK_OFFER_REWARD", isTips)
end


--已经发生借用请求的
function QOfferReward:getMyBorrowInHeroNum()
    return self._actorBorrowCount
end

--已经借到的英雄
function QOfferReward:getMyAlreadyBorrowedHeroNum()
    return self._borrowInInfos and #self._borrowInInfos or 0
end

function QOfferReward:getMyBorrowGenreType()
    return self._borrowGenreType or 1
end
function QOfferReward:setMyBorrowGenreType(genreType)
    self._borrowGenreType = genreType
end



function QOfferReward:getCurProgressNum()
    local cur_level = self._myInfo.level or 1
    local next_level = cur_level + 1
    local offerLevel = self:getOfferRewardLevelById(cur_level)
    local progressInfo = self._myInfo.progressInfo  or {}
    if offerLevel == nil then
        return 0,1
    end

    local level_up_table = string.split(offerLevel.level_up, "^")

    local cur_num = 0
    for k,v in pairs(progressInfo) do
        if tonumber(v.quality) == tonumber(level_up_table[1]) then 
            cur_num = v.num
            break
        end
    end

    local max_num = level_up_table[2]

    return cur_num , max_num
end


function QOfferReward:checkRedTips()
    if self:getUnlockOfferReward() then
        if self._applyInfoCount > 0 then
            return true
        end

        if self._borrowInfo and #self._borrowInfo >0  then
            return true
        end


        local currTime = q.serverTime()
        for k1,info in pairs( self._dispatchInfo or {}) do
            if info.isStart == false then
               return true
            else
                local offerRewardTask = remote.offerreward:getOfferRewardTaskById(info.taskId)
                local timeCd = tonumber(offerRewardTask.time) * 60
                local _startAt = info.startAt or 0
                local endTime = _startAt / 1000 + timeCd
                if endTime <= currTime and info.getReward == false then
                    return true
                end
            end
        end
    end

    return false
end

function QOfferReward:setMyInfo(data)
    self._myInfo = data
end

function QOfferReward:getMyInfo()
    return self._myInfo
end

-- message OfferRewardDispatchInfo {
--     optional string dispatchId = 1; //uuid
--     optional int32 taskId = 2; //任务Id
--     repeated Fighter dispatchFighter = 3; //派遣fighter
--     optional int64 startAt = 4; //开始时间
--     optional bool getReward = 6; //是否领取了奖励
-- }

function QOfferReward:setDispatchInfo(data , isCopy)
    if q.isEmpty(self._dispatchInfo) or isCopy then
        self._dispatchInfo = data
    else
        for k,newInfo in pairs(data) do
             for i,oldInfo in ipairs(self._dispatchInfo) do
                if oldInfo.dispatchId == newInfo.dispatchId then
                    self._dispatchInfo[i] = newInfo
                end
             end
         end 
    end
    self._beUsed_HeroIds = {} -- 存储数据结构为 魂师id 与 玩家id
    --存储已经派遣过的英雄
    for k1,info in pairs( self._dispatchInfo or {}) do
        if info.getReward == false then
            for k2,fight in pairs(info.dispatchFighter or {}) do
                table.insert(self._beUsed_HeroIds , {actorId = fight.heros[1].actorId or 0 , userId = fight.userId or "" })
            end
        end
    end
    -- QPrintTable(self._beUsed_HeroIds)
end


--根据id 获得悬赏任务的数据
function QOfferReward:getOfferRewardTaskById(id)
    local  offerRewardTask =  db:getStaticByName("offer_reward_task")
    for _,value in pairs(offerRewardTask or {}) do
        if value.id == id then
            return value
        end
    end
    return nil
end

--根据level 获得悬赏任务的数据
function QOfferReward:getOfferRewardLevelById(level)

    local  offerRewardLevel =  db:getStaticByName("offer_reward_level")

    for _,value in pairs(offerRewardLevel or {}) do
        if value.level == level then
            return value
        end
    end
    return nil
end

-- /**
--  * 魂师悬赏--派遣信息
--  */
-- message OfferRewardDispatchInfo {
--     optional string dispatchId = 1; //uuid
--     optional int32 taskId = 2; //任务Id
--     repeated Fighter dispatchFighter = 3; //派遣fighter
--     optional int64 startAt = 4; //开始时间
--     optional bool isStart = 5; //是否开始了
--     optional bool getReward = 6; //是否领取了奖励
-- }

function QOfferReward:getDispatchInfo()
    return self._dispatchInfo
end

function QOfferReward:setBorrowInfo(data)
    self._borrowInfo = data
end

function QOfferReward:getBorrowInfo()
    return self._borrowInfo
end


function QOfferReward:clearBorrowInfo()
    self._borrowInfo = {}
end

function QOfferReward:updateBorrowInfosCountNum()
    if self._borrowInfo then
        self._applyInfoCount = #self._borrowInfo
    else
        print("self._borrowInfo is NULL")
    end
end

function QOfferReward:getBorrowInfosCountNum()
    return self._applyInfoCount or 0
end

function QOfferReward:clearBorrowInfoByActorId(actorId)
    local new_borrowInfo = {}

    for k,v in pairs(self._borrowInfo or {}) do
        if v.actorId ~= actorId then
            table.insert(new_borrowInfo , v)
        end
    end
    self._borrowInfo = new_borrowInfo
end

function QOfferReward:removeBorrowInfoByBorrowIds(borrowIds)

    local num = #self._borrowInfo
    if num <= 0 or q.isEmpty(borrowIds) then return end
    local size = 0
    for i=1,#self._borrowInfo do
        local info = self._borrowInfo[i]
        if size >= #borrowIds then
            break
        end
        for k,borrowId in pairs(borrowIds or {}) do
            if info.borrowId == borrowId then
                info.borrowId = "0"
                size = size + 1
                break
            end
        end
    end

    local new_borrowInfo = {}
    for k,v in pairs(self._borrowInfo or {}) do
        if v.borrowId ~= "0" then
            table.insert(new_borrowInfo , v)
        end
    end

    self._borrowInfo = new_borrowInfo
end


function QOfferReward:clearBorrowInInfoByBorrowId(borrowId)
    local new_borrowInfo = {}

    for k,v in pairs(self._borrowInInfos or {}) do
        if v.borrowId ~= borrowId then
            table.insert(new_borrowInfo , v)
        end
    end
    self._borrowInInfos = new_borrowInfo
end

function QOfferReward:setBorrowOutInfos(data)
    self._borrowOutInfos = data
end

function QOfferReward:getBorrowOutInfos()
    return self._borrowOutInfos
end

function QOfferReward:setBorrowInInfos(data)
    self._borrowInInfos = data
end

function QOfferReward:getBorrowInInfos()
    return self._borrowInInfos
end

function QOfferReward:setRankingHeroInfos(data)
    self._rankingHeroInfos = data
end

function QOfferReward:getRankingHeroInfos()
    return self._rankingHeroInfos
end

function QOfferReward:getRefreshNum()
    local num = 0
    num = db:getConfigurationValue("OFFER_REWARD_FRESH_TOKEN")
    return num
end

function QOfferReward:getRemainingRefreshNum()
    local num = 0
    local maxNum = db:getConfigurationValue("OFFER_REWARD_DAILY_MAX_REFRESH_COUNT") 
    local usedNum = self._myInfo and self._myInfo.refreshCount or 0
    num = maxNum - usedNum
    return num
end

-- 获取派遣的总次数
function QOfferReward:getCompleteCount()
    return self._myInfo.rewardCount or 0
end

function QOfferReward:_dispatchAll()
    local tbl = {}
    for _, name in pairs(self._dispatchList) do
        if not tbl[name] then
            self:dispatchEvent({name = name})
            tbl[name] = true
        end
    end
    self._dispatchList = {}
end

-------------------------------
-- /**
--  * 魂师悬赏--归还英雄
--  */
-- message OfferRewardCompleteProgressInfo {
--     optional int32 quality = 1; //品质
--     optional int32 num = 2; //数量
-- }
-- /**
--  * 魂师悬赏--我的信息
--  */
-- message OfferRewardMyInfo {
--     optional int32 level = 1;
--     repeated OfferRewardCompleteProgressInfo progressInfo = 2; //任务进度信息
--     repeated OfferRewardDispatchInfo despatchInfo = 3; //派遣信息
--     optional int32 borrowCount = 4; //借用数量
--     optional int32 borrowSuccessCount = 5; //借到的数量
--     optional int32 refreshCount = 6; //刷新次数
-- }
-- /**
--  * 魂师悬赏--派遣信息
--  */
-- message OfferRewardDispatchInfo {
--     optional string dispatchId = 1; //uuid
--     optional int32 taskId = 2; //任务Id
--     repeated Fighter dispatchFighter = 3; //派遣fighter
--     optional int64 startAt = 4; //开始时间
--     optional bool getReward = 6; //是否领取了奖励
-- }
-- /**
--  * 魂师悬赏--租借信息
--  */
-- message OfferRewardBorrowInfo {
--     optional string borrowId = 1; //uuid
--     optional Fighter borrowFighter = 2; //拥有人的Id
--     optional int32 actorId = 3; //英雄Id
-- }
-- /**
--  * 魂师悬赏--response
--  */
-- message OfferRewardInfoResponse {
--     optional OfferRewardMyInfo myInfo = 1; //我的信息
--     repeated OfferRewardDispatchInfo dispatchInfo = 2; //派遣信息
--     repeated OfferRewardBorrowInfo borrowInfo = 3; //借用信息
--     repeated Fighter borrowOutInfos = 4; //所有的fighter信息  借出魂师信息
--     repeated Fighter borrowInInfos = 5; //所有的fighter信息  借用魂师信息
--     repeated Fighter rankingHeroInfos = 6; //所有的fighter信息  排行榜
-- }

function QOfferReward:responseHandler(data, success, fail, succeeded)
	--进游戏拉取简单信息

    if data.api == "OFFER_REWARD_REFUSE"  then
        self:setBorrowInfo({})
        self:updateBorrowInfosCountNum()
    end

    if data.offerRewardInfoResponse then
        if data.offerRewardInfoResponse.myInfo then
            self:setMyInfo(data.offerRewardInfoResponse.myInfo)
        end
        local isCopy = data.api == "OFFER_REWARD_GET_MY_INFO" or data.api == "OFFER_REWARD_GET_MAIN_INFO"

        if data.offerRewardInfoResponse.dispatchInfo then
            self:setDispatchInfo(data.offerRewardInfoResponse.dispatchInfo ,isCopy)
        end

        --清除别人申请我的魂师
        local clearBorrowInfo =  data.api == "OFFER_REWARD_GET_APPLY_INFO" or data.api == "OFFER_REWARD_REFUSE" 
        local clearBorrowInfoByPromissAll = data.offerRewardInfoResponse.isPromissAll or false
        if clearBorrowInfoByPromissAll or clearBorrowInfo then
            self:setBorrowInfo({})
            self:updateBorrowInfosCountNum()
        end
        -- 根据服务器数据清除部分申请信息
        if data.offerRewardInfoResponse.removeBorrowIdList then
            self:removeBorrowInfoByBorrowIds(data.offerRewardInfoResponse.removeBorrowIdList)
            self:updateBorrowInfosCountNum()
        end

        if data.offerRewardInfoResponse.borrowInfo then
            self:setBorrowInfo(data.offerRewardInfoResponse.borrowInfo)
            self:updateBorrowInfosCountNum()
        end
        --清除借出魂师
        if data.api == "OFFER_REWARD_GET_BORROW_OUT_INFO" then
            self:setBorrowOutInfos({})
        end
        if data.offerRewardInfoResponse.borrowOutInfos then
            self:setBorrowOutInfos(data.offerRewardInfoResponse.borrowOutInfos)
        end
        --清除借用宗门信息
        if data.api == "OFFER_REWARD_GET_BORROW_IN_INFO" or data.api == "OFFER_REWARD_RETURN" then
            self:setBorrowInInfos({})
        end
        if data.offerRewardInfoResponse.borrowInInfos then
            self:setBorrowInInfos(data.offerRewardInfoResponse.borrowInInfos)
        end
        --清除单个英雄借用数据
        if data.api == "OFFER_REWARD_GET_TARGET_HERO_INFO" then
            self:setRankingHeroInfos({})
            self._actorBorrowCount = 0
        end
        if data.offerRewardInfoResponse.rankingHeroInfos then
            self:setRankingHeroInfos(data.offerRewardInfoResponse.rankingHeroInfos)
        end
        if data.offerRewardInfoResponse.actorBorrowCount then
            self._actorBorrowCount = data.offerRewardInfoResponse.actorBorrowCount
        end
        --记录玩家被申请信息数据数量用来刷新红点
        if data.offerRewardInfoResponse.applyCount or isCopy then
            self._applyInfoCount = data.offerRewardInfoResponse.applyCount or 0
        end
    end
    --刷新红点使用
    if data.api == "OFFER_REWARD_GET_MY_INFO" 
        or data.api == "OFFER_REWARD_GET_MAIN_INFO" 
        or data.api == "OFFER_REWARD_DISPATCH" 
        or data.api == "OFFER_REWARD_GET_REWARD" 
        or data.api == "OFFER_REWARD_REFUSE" 
        or data.api == "OFFER_REWARD_PROMISS" 
        or data.api == "OFFER_REWARD_GET_APPLY_INFO" 
        or data.api == "OFFER_REWARD_REFRESH_TASK" 
        then
        self:dispatchEvent({name = QOfferReward.EVENT_REFRESH})
    end
    
    self:_dispatchAll()
	if succeeded == true then
        if success ~= nil then
            success(data)
        end
    else
        if fail ~= nil then
            fail(data)
        end
    end
end

--登录信息
function QOfferReward:offerRewardGetMyInfoRequest(success, fail)
    local request = {api = "OFFER_REWARD_GET_MY_INFO"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--主界面信息 
function QOfferReward:offerRewardGetMainInfoRequest(success, fail)
    local request = {api = "OFFER_REWARD_GET_MAIN_INFO"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--刷新任务 
function QOfferReward:offerRewardRefreshTaskRequest(success, fail)
    local request = {api = "OFFER_REWARD_REFRESH_TASK"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--魂师悬赏--领取奖励
function QOfferReward:offerRewardGetRewardRequest(dispatchId , success, fail)
    local offerRewardGetRewardRequest = {dispatchId = dispatchId}
    local request = {api = "OFFER_REWARD_GET_REWARD",offerRewardGetRewardRequest = offerRewardGetRewardRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- message OfferRewardDispatchHeroRequest {
--     repeated OfferRewardDispatchHeroInfo heroInfos = 1;
-- }

-- message OfferRewardDispatchHeroInfo {
--     optional string userId = 1;
--     optional int32 heroId = 2;
-- }

--魂师悬赏--派遣魂师
function QOfferReward:offerRewardDispatchHeroRequest(heroInfos ,dispatchId, success, fail)
    local offerRewardDispatchHeroRequest = {dispatchId = dispatchId ,heroInfos = heroInfos}
    local request = {api = "OFFER_REWARD_DISPATCH",offerRewardDispatchHeroRequest = offerRewardDispatchHeroRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        remote.user:addPropNumForKey("todayOfferRewardCount")
        remote.activity:updateLocalDataByType(716, 1)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- message OfferRewardBorrowHeroRequest {
--     repeated OfferRewardBorrowHeroInfo borrowInfo = 1;
-- }
-- message OfferRewardBorrowHeroInfo {
--     optional string userId = 1;
--     optional int32 actorId = 2;
-- }

--魂师悬赏--借用魂师
function QOfferReward:offerRewardBorrowHeroRequest(borrowInfo , success, fail)
    local offerRewardBorrowHeroRequest = {borrowInfo = borrowInfo}
    local request = {api = "OFFER_REWARD_BORROW",offerRewardBorrowHeroRequest = offerRewardBorrowHeroRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end


--魂师悬赏--查看单个英雄战力排行榜
function QOfferReward:offerRewardGetTargetHeroRankingRequest(actorId , success, fail)
    local offerRewardGetTargetHeroRankingRequest = {actorId = actorId}
    local request = {api = "OFFER_REWARD_GET_TARGET_HERO_INFO",offerRewardGetTargetHeroRankingRequest = offerRewardGetTargetHeroRankingRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--魂师悬赏--获取我的借用信息
function QOfferReward:offerRewardGetBorrowInInfo( success, fail)
    local request = {api = "OFFER_REWARD_GET_BORROW_IN_INFO"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--魂师悬赏--获取我的借出信息
function QOfferReward:offerRewardGetBorrowOutInfo( success, fail)
    local request = {api = "OFFER_REWARD_GET_BORROW_OUT_INFO"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--魂师悬赏--获取申请信息 
function QOfferReward:offerRewardGetApplyInfo( success, fail)
    local request = {api = "OFFER_REWARD_GET_APPLY_INFO"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--魂师悬赏--拒绝别人的申请
function QOfferReward:offerRewardRefuseRequest( borrowId , success, fail)
    local offerRewardRefuseRequest ={borrowId = borrowId}
    local request = {api = "OFFER_REWARD_REFUSE",offerRewardRefuseRequest = offerRewardRefuseRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--魂师悬赏--接受别人的申请
function QOfferReward:offerRewardPromissRequest( borrowId , success, fail)
    local offerRewardPromissRequest ={borrowId = borrowId}
    local request = {api = "OFFER_REWARD_PROMISS",offerRewardPromissRequest = offerRewardPromissRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--魂师悬赏--归还别人的魂师
function QOfferReward:offerRewardReturnHeroRequest( borrowId , success, fail)
    local offerRewardReturnHeroRequest ={ borrowId = borrowId }
    local request = {api = "OFFER_REWARD_RETURN",offerRewardReturnHeroRequest = offerRewardReturnHeroRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

return QOfferReward