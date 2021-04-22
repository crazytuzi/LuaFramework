-- 
-- Kumo.Wang
-- 鼠年春节活动
--

local QActivityRoundsBaseChild = import(".QActivityRoundsBaseChild")
local QActivityRatFestival = class("QActivityRatFestival", QActivityRoundsBaseChild)

local QActivity = import(".QActivity")
local QNavigationController = import("..controllers.QNavigationController")
local QUIViewController = import("..ui.QUIViewController")

function QActivityRatFestival:ctor( ... )
	QActivityRatFestival.super.ctor(self,...)

	self._serverRatFestivalInfo = {}
	self._luckyCardDataList = {
			{id = 1000467, card = "icon/hero_card/card_cntangsan.jpg", name = "ui/update_ratFestival/sp_tangsanfu.png"},
			{id = 1000469, card = "icon/hero_card/card_cnxiaowu.jpg", name = "ui/update_ratFestival/sp_xiaowufu.png"},
			{id = 1000465, card = "icon/hero_card/card_zsdaimubai.jpg", name = "ui/update_ratFestival/sp_daimubaifu.png"},
			{id = 1000471, card = "icon/hero_card/card_sszhuzhuqing.jpg", name = "ui/update_ratFestival/sp_zhuzhuqingfu.png"},
			{id = 1000466, card = "icon/hero_card/card_shishenaosika.jpg", name = "ui/update_ratFestival/sp_aosikafu.png"},
			{id = 1000470, card = "icon/hero_card/card_ningrongrong.jpg", name = "ui/update_ratFestival/sp_ningrongrongfu.png"},
			{id = 1000468, card = "icon/hero_card/card_fhmahongjun.jpg", name = "ui/update_ratFestival/sp_mahongjunfu.png"},
		}

	self._luckyCardFragmentItemId = 1000472 -- 福卡碎片的id

	self._tavernPreviewKey = 33 -- 福卡抽卡界面奖励预览的tavern_preview量表的key
end

-- 活动界面关闭
function QActivityRatFestival:activityShowEndCallBack()
	self:handleOffLine()
end

-- 活动结束（界面未必关闭）
function QActivityRatFestival:activityEndCallBack()
	self:_handleEvent()
end

function QActivityRatFestival:handleOnLine()
	if self.isOpen then
		self:_loadActivity()
		self:ratFestivalMyInfoRequest()
	end
end

function QActivityRatFestival:handleOffLine()
	remote.activity:removeActivity(self.activityId)
	remote.activity:refreshActivity(true)
    self.isOpen = false
	self:_handleEvent()
end

function QActivityRatFestival:getActivityInfoWhenLogin()
	if self.isOpen then
		self:_loadActivity()
		self:ratFestivalMyInfoRequest()
	end
end

function QActivityRatFestival:timeRefresh( event )
	if event.time and event.time == 0 then
		self:_handleEvent()
	end
end

function QActivityRatFestival:checkActivityComplete()
    if not self.isOpen then
		return false
	end

	if self:checkTavernBuyRedTips() then
		return true
	end

	if self:checkTavernScoreRedTips() then
		return true
	end

	if self:checkFinalRewardRedTips() then
		return true
	end

    return false
end

function QActivityRatFestival:checkTavernBuyRedTips()
	if not self.isOpen then
		return false
	end

	if self:isActivityClickedToday() then
		-- 點擊過
		return false
	end

	local startTime = self.startAt or 0
    local luckyDrawEndTime = self.endAt or 0 -- 收集福卡結束時間
    local curTime = q.serverTime()
    if curTime >= startTime and curTime <= luckyDrawEndTime then
    	-- 集卡期間
    	local moneyCount = remote.user[ITEM_TYPE.RAT_FESTIVAL_MONEY] or 0
    	if moneyCount > 0 then
    		-- 有新春福券，可前往集卡
    		return true
    	end
    end

    return false
end

function QActivityRatFestival:checkTavernScoreRedTips()
	if not self.isOpen then
		return false
	end

	local startTime = self.startAt or 0
    local luckyDrawEndTime = self.endAt or 0 -- 收集福卡結束時間
    local curTime = q.serverTime()
    if curTime < startTime or curTime > luckyDrawEndTime then
    	-- 非集卡期間
    	return false
    end

	local serverInfo = self:getServerInfo()
	local currentScore = serverInfo.score or 0

	if currentScore == 0 then return false end

	local scoreInfo = db:getStaticByName("activity_rat_festival_rewards")
	local index = 1
	while true do
		local curInfo = scoreInfo[tostring(index)]
		if curInfo then
			if curInfo.points and curInfo.rewards and currentScore >= curInfo.points and not self:checkAwardIsRecived(index) then
				-- 積分獎勵可領取
				return true	
			end
			index = index + 1
		else
			break
		end
	end

	return false 
end

function QActivityRatFestival:checkFinalRewardRedTips()
	if not self.isOpen then
		return false
	end

    local luckyDrawEndTime = self.endAt or 0 -- 收集福卡結束時間
    local endTime = self.showEndAt or 0 -- 整個活動結束時間
    local curTime = q.serverTime()
    if curTime > luckyDrawEndTime and curTime <= endTime then
    	-- 瓜分大奖期間
    	local serverInfo = self:getServerInfo()
    	if not serverInfo.getFinalReward then
    	end
		return not serverInfo.getFinalReward
    end

    return false
end

function QActivityRatFestival:setActivityClickedToday()
	if not self.isOpen or not self.activityId then return end

	if app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(self.activityId) then
		app:getUserOperateRecord():recordeCurrentTime(self.activityId)
	end
end

function QActivityRatFestival:isActivityClickedToday()
	if not self.isOpen or not self.activityId then return end
	
	return not app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(self.activityId)
end

--------------数据储存.KUMOFLAG.--------------

--------------對外工具.KUMOFLAG.--------------

-- 界面福卡顯示順序，如果有需要排序的話，也在這裡排序，並且，修改_luckyCardDataList的順序
function QActivityRatFestival:getLuckyCradDataList()
	return self._luckyCardDataList
end

function QActivityRatFestival:getLuckyCardFragmentItemId()
	return self._luckyCardFragmentItemId
end

function QActivityRatFestival:getTavernPreviewKey()
	return self._tavernPreviewKey
end

function QActivityRatFestival:getServerInfo()
	return self._serverRatFestivalInfo
end

function QActivityRatFestival:getNowHadLuckyCradIdsList()
	local tbl = {}
	for _, value in ipairs(self._luckyCardDataList) do
		local count = remote.items:getItemsNumByID(value.id)
		if count > 0 then
			table.insert(tbl, value.id)
		end
	end

	return tbl
end

function QActivityRatFestival:isLuckyCardId( id )
	if id == self._luckyCardFragmentItemId then return false end

	if not self._luckyCardIdDic then
		self._luckyCardIdDic = {}
	end
	if self._luckyCardIdDic[tostring(id)] then
		return true
	end

	for _, value in ipairs(self._luckyCardDataList) do
		if value.id == id then
			self._luckyCardIdDic[tostring(id)] = true
			return true
		end
	end

	return false
end

-- 在抽卡的时候，根据获得的碎片数量判断是否是重复的福卡整卡转成的碎片，如果是，返回福卡的id
function QActivityRatFestival:isLuckyCardReplaceByItemCount(itemCount)
	if not self._fragmentToCard then
		self._fragmentToCard = {}
		for _, value in ipairs(self._luckyCardDataList) do
			local config = db:getItemByID(value.id)
			if config.material_recycle then
				local tbl = string.split(config.material_recycle, "^")
				if tbl and #tbl > 0 then
					if tonumber(tbl[1]) == self._luckyCardFragmentItemId then
						if not self._fragmentToCard[tostring(tbl[2])] then 
							self._fragmentToCard[tostring(tbl[2])] = {}
						end
						table.insert(self._fragmentToCard[tostring(tbl[2])], value.id)
					end
				end
			end
		end
	end

	if not self._fragmentToCard[tostring(itemCount)] then return false end

	local tbl = {}
	for _, id in ipairs(self._fragmentToCard[tostring(itemCount)]) do
		local count = remote.items:getItemsNumByID(id)
		if count > 0 then
			table.insert(tbl, id)
		end
	end

	if #tbl == 0 then return false end
	
	local index = math.random(1, #tbl)
	return true, tbl[index], itemCount
end

-- 根据福卡id，获得兑换所需要的碎片数量
function QActivityRatFestival:getLuckyCardConvertPriceById(luckyCardId)
	local config = db:getItemByID(luckyCardId)
	if config.material_money then
		local tbl = string.split(config.material_money, "^")
		if tbl and #tbl > 0 then
			if tonumber(tbl[1]) == self._luckyCardFragmentItemId then
				return tonumber(tbl[2])
			end
		end
	end
end

-- 根据积分奖励序列号确定奖励是否已经领取
function QActivityRatFestival:checkAwardIsRecived(index)
	local serverInfo = self:getServerInfo()
	local recivedAwards = serverInfo.getScorePrize or {}

	for _, value in pairs(recivedAwards) do
		if value == index then
			return true
		end
	end

	return false
end

function QActivityRatFestival:getRatFestivalRewardItemsTips(items, lastLuckyCardIds, againCallback,confirmCallback, isAgain)
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if dialog.class.__cname == "QUIDialogRatFestivalTavernAchieve" and not isAgain then
		app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
	end

	local options = {}
	options.items = items
	options.lastLuckyCardIds = lastLuckyCardIds
	options.againCallback = againCallback
	options.confirmCallback = confirmCallback

	if isAgain then
		remote.activityRounds:dispatchEvent({name = remote.activityRounds.EVENT_RAT_FESTIVAL_TAVERN_UPDATE, options = options})
	else
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRatFestivalTavernAchieve", 
			options = options}, {isPopCurrentDialog = false})
	end
end

--------------数据处理.KUMOFLAG.--------------

function QActivityRatFestival:responseHandler( response, successFunc, failFunc )
    -- QKumo( response )
    -- optional string activityId = 1; // 活动id
    -- optional int32 score = 2; // 积分
    -- repeated int32 getScorePrize = 3; // 已经领取的积分奖励
    -- optional bool getFinalReward = 4; //是否领取了最终的奖励
    -- optional int32 totalCompleteCount = 5; //已经集齐的玩家数量
    -- optional int32 finalRewardCount=6;//获取最终奖励的钻石数量
    if response.ratFestivalInfoResponse and response.error == "NO_ERROR" then
    	self._serverRatFestivalInfo = response.ratFestivalInfoResponse.userInfo or {}
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

function QActivityRatFestival:pushHandler( data )
    -- QPrintTable(data)
end

-- RAT_FESTIVAL_GET_MY_INFN                        = 10094;                    //  鼠年新春活动--登录信息获取 reponse RatFestivalInfoResponse
-- RAT_FESTIVAL_GET_MAIN_INFN                      = 10095;                    //  鼠年新春活动--主界面信息 reponse RatFestivalInfoResponse
-- RAT_FESTIVAL_LUCKY_DRAW                         = 10096;                    //  鼠年新春活动--抽奖 request RatFestivalLuckyDrawRequest reponse RatFestivalInfoResponse
-- RAT_FESTIVAL_GET_SCORE_REWARD                   = 10097;                    //  鼠年新春活动--领取积分奖励 request RatFestivalGetScoreRewardRequest reponse RatFestivalInfoResponse
-- RAT_FESTIVAL_GET_FINAL_PRIZE                    = 10098;                    //  鼠年新春活动--领取最终的奖励 reponse RatFestivalInfoResponse
-- RAT_FESTIVAL_COMBINE                            = 10099;                    //  鼠年新春活动--福卡碎片合成福卡 request RatFestivalCombineFokaRequest reponse RatFestivalInfoResponse

function QActivityRatFestival:ratFestivalMyInfoRequest(success, fail, status)
    local request = { api = "RAT_FESTIVAL_GET_MY_INFN"}
    app:getClient():requestPackageHandler("RAT_FESTIVAL_GET_MY_INFN", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

function QActivityRatFestival:ratFestivalMainInfoRequest(success, fail, status)
    local request = { api = "RAT_FESTIVAL_GET_MAIN_INFN"}
    app:getClient():requestPackageHandler("RAT_FESTIVAL_GET_MAIN_INFN", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional int32 drawCount = 1; // 抽奖数量
function QActivityRatFestival:ratFestivalLuckyDrawRequest(drawCount, success, fail, status)
	local ratFestivalLuckyDrawRequest  = {drawCount = drawCount}
    local request = { api = "RAT_FESTIVAL_LUCKY_DRAW", ratFestivalLuckyDrawRequest = ratFestivalLuckyDrawRequest}
    app:getClient():requestPackageHandler("RAT_FESTIVAL_LUCKY_DRAW", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- repeated int32 rewardIds = 1; // 奖励id
function QActivityRatFestival:ratFestivalGetScoreRewardRequest(rewardIds, success, fail, status)
	local ratFestivalGetScoreRewardRequest  = {rewardIds = rewardIds}
    local request = { api = "RAT_FESTIVAL_GET_SCORE_REWARD", ratFestivalGetScoreRewardRequest = ratFestivalGetScoreRewardRequest}
    app:getClient():requestPackageHandler("RAT_FESTIVAL_GET_SCORE_REWARD", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

function QActivityRatFestival:ratFestivalFinalPrizeRequest(success, fail, status)
    local request = { api = "RAT_FESTIVAL_GET_FINAL_PRIZE"}
    app:getClient():requestPackageHandler("RAT_FESTIVAL_GET_FINAL_PRIZE", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional int32 fokaId = 1; // 要合成福卡的id
function QActivityRatFestival:ratFestivalCombineFokaRequest(fokaId, success, fail, status)
	local ratFestivalCombineFokaRequest = {fokaId = fokaId}
    local request = { api = "RAT_FESTIVAL_COMBINE", ratFestivalCombineFokaRequest = ratFestivalCombineFokaRequest}
    app:getClient():requestPackageHandler("RAT_FESTIVAL_COMBINE", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--------------本地工具.KUMOFLAG.--------------

function QActivityRatFestival:_handleEvent()
    remote.activityRounds:dispatchEvent({name = remote.activityRounds.RAT_FESTIVAL_UPDATE})
end

-- 加入到活動數據裡，讓主界面顯示icon
function QActivityRatFestival:_loadActivity()
    if self.isOpen then
        local activities = {}
        local themeInfo = db:getActivityThemeInfoById(QActivity.THEME_ACTIVITY_RAT_FESTIVAL_2) or {}
        table.insert(activities, {
        	activityId = self.activityId, 
        	title = (themeInfo.title or "瓜分10亿"), 
        	roundType = "RAT_FESTIVAL",
        	start_at = self.startAt * 1000, 
        	end_at = self.endAt * 1000,
        	award_at = self.startAt * 1000, 
        	award_end_at = self.showEndAt * 1000, 
        	weight = 20, 
        	targets = {}, 
        	subject = QActivity.THEME_ACTIVITY_RAT_FESTIVAL_2})
        remote.activity:setData(activities)
    else
        remote.activity:removeActivity(self.activityId)
    end
end

return QActivityRatFestival