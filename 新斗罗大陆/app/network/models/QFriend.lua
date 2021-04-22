--
-- Author: wkwang
-- Date: 2015-10-23 11:07:01
--
local QBaseModel = import("...models.QBaseModel")
local QFriend = class("QFriend",QBaseModel)
local QStaticDatabase = import("...controllers.QStaticDatabase")

QFriend.EVENT_UPDATE_FRIEND = "EVENT_UPDATE_FRIEND"
QFriend.EVENT_UPDATE_FRIEND_INFO = "EVENT_UPDATE_FRIEND_INFO"
QFriend.EVENT_UPDATE_APPLY_FRIEND = "EVENT_UPDATE_APPLY_FRIEND"
QFriend.EVENT_UPDATE_BLACK_FRIEND = "EVENT_UPDATE_BLACK_FRIEND"
QFriend.EVENT_UPDATE_SUGGEST_FRIEND = "EVENT_UPDATE_SUGGEST_FRIEND"

QFriend.TYPE_LIST_FRIEND = "TYPE_LIST_FRIEND"
QFriend.TYPE_LIST_SUGGEST = "TYPE_LIST_SUGGEST"
QFriend.TYPE_LIST_BLACKLIST = "TYPE_LIST_BLACKLIST"
QFriend.TYPE_LIST_APPLY = "TYPE_LIST_APPLY"

--推送的操作类型
QFriend.ACCEPT = "ACCEPT" --接受好友
QFriend.DELETE = "DELETE" --删除好友
QFriend.BLACK  = "BLACK" --删除好友并加入黑名单
QFriend.APPLY  = "APPLY" --推送申请
QFriend.SEND_ENERGY_GIFT = "SEND_ENERGY_GIFT" --推送好友赠送能量

function QFriend:ctor()
	QFriend.super.ctor(self)

    self._friendList = {}
    self._blackFriendList = {}
    self._suggestFriendList = {}
    self._applyFriendList = {}
    self._friendInfo = {}
    self._maxFriend = 0
    self._friendRefreshTime = 0
end

function QFriend:didappear()
	QFriend.super.didappear(self)
    self._userEventProxy = cc.EventProxy.new(remote.user)
    self._userEventProxy:addEventListener(remote.user.EVENT_TIME_REFRESH, handler(self,self.refreshTimeAtFiveHandler))
end

function QFriend:disappear()
    QFriend.super.disappear(self)
    if self._userEventProxy ~= nil then
        self._userEventProxy:removeAllEventListeners()
        self._userEventProxy = nil
    end
end

function QFriend:loginEnd()
    if app.unlock:getUnlockFriend() == true then
        self:initRequest()
    end
    self._maxFriend = QStaticDatabase:sharedDatabase():getConfiguration().FRIEND_NUMBER.value
    self._maxFriendEnergy = QStaticDatabase:sharedDatabase():getConfiguration().FRIEND_ENERGY.value
    self._friendRefreshTime = QStaticDatabase:sharedDatabase():getConfiguration().RECOMMEND_FRIEND_REFRESH.value
end

function QFriend:initRequest()
    self:requestList()
    self:requestBalckList()
    self:requestSuggestList()
    self:requestApplyList()
end

function QFriend:refreshTimeAtFiveHandler(event)
    if app.unlock:getUnlockFriend() == false then
        return
    end
    if event.time == nil or event.time == 5 then
        local friendCtlInfo = self:getFriendCtlInfo()
        friendCtlInfo.today_get_gift_times = 0
        self:updateFriendCtlInfo(friendCtlInfo)
        self:requestList()
    end
end

--获取好友列表
function QFriend:getFriendList()
    local friendList = table.keys(self._friendList)
    table.sort( friendList, function (a,b)
        local friendA = self:getFriendInfoById(a)
        local friendB = self:getFriendInfoById(b)
        if friendA.existGift == true and friendA.alreadySendGift ~= true then
            if friendB.existGift == true and friendB.alreadySendGift ~= true then
                return self:_sortCmmon(friendA, friendB)
            else
                return true
            end
        end
        if friendB.existGift == true and friendB.alreadySendGift ~= true then
            return false
        end
        if friendA.existGift == true and friendB.existGift == false then
            return true
        elseif friendB.existGift == true and friendA.existGift == false then
            return false
        end
        if friendA.alreadySendGift ~= true and friendB.alreadySendGift == true then
            return true
        elseif friendB.alreadySendGift ~= true and friendA.alreadySendGift == true then
            return false
        end
        return self:_sortCmmon(friendA, friendB)
    end )
    return friendList
end

--获取黑名单列表
function QFriend:getBlackFriendList()
    local friendList = table.keys(self._blackFriendList)
    table.sort(friendList, function (a,b)
        local friendA = self:getFriendInfoById(a)
        local friendB = self:getFriendInfoById(b)
        return self:_sortCmmon(friendA, friendB)
    end)
    return friendList
end

--获取推荐好友列表
function QFriend:getSuggestFriendList()
    local friendList = table.keys(self._suggestFriendList)
    table.sort(friendList, function (a,b)
        local friendA = self:getFriendInfoById(a)
        local friendB = self:getFriendInfoById(b)
        return self:_sortCmmon(friendA, friendB)
    end)
    return friendList
end

--获取申请好友列表
function QFriend:getApplyFriendList()
    local friendList = table.keys(self._applyFriendList)
    table.sort(friendList, function (a,b)
        local friendA = self:getFriendInfoById(a)
        local friendB = self:getFriendInfoById(b)
        return self:_sortCmmon(friendA, friendB)
    end)
    return friendList
end

--删除指定列表中的好友信息
function QFriend:deleteFriendByTypeAndId(typeName, id)
    if typeName == QFriend.TYPE_LIST_FRIEND then
        self._friendList[id] = nil
        self:dispatchEvent({name = self.EVENT_UPDATE_FRIEND})
    elseif typeName == QFriend.TYPE_LIST_SUGGEST then
        self._suggestFriendList[id] = nil
        self:dispatchEvent({name = self.EVENT_UPDATE_SUGGEST_FRIEND})
    elseif typeName == QFriend.TYPE_LIST_BLACKLIST then
        self._blackFriendList[id] = nil
        self:dispatchEvent({name = self.EVENT_UPDATE_BLACK_FRIEND})        
    elseif typeName == QFriend.TYPE_LIST_APPLY then
        self._applyFriendList[id] = nil
        self:dispatchEvent({name = self.EVENT_UPDATE_APPLY_FRIEND})
    end
end

--获取好友信息通过ID
function QFriend:getFriendInfoById(userId)
    local friendInfo = self._friendInfo[userId]
    if friendInfo ~= nil then
        if friendInfo.existGift == nil then
            friendInfo.existGift = false
        end
        if friendInfo.alreadySendGift == nil then
            friendInfo.alreadySendGift = false
        end
        if friendInfo.alreadyGetGift == nil then
            friendInfo.alreadyGetGift = true
        end
    end
    return friendInfo
end

--获取好友上限
function QFriend:getMaxCount()
    return self._maxFriend or 0
end

--获取好友能量上限
function QFriend:getMaxEnergy()
    return self._maxFriendEnergy or 0
end

--获取好友能量是否到上限
function QFriend:checkEnergyIsMax()
    if self._friendCtlInfo ~= nil then
        return self._maxFriendEnergy > self._friendCtlInfo.today_get_gift_times
    end
    return true
end

--获取推荐好友刷新间隔时间
function QFriend:getRefreshTime()
    return self._friendRefreshTime or 0
end

--获取friendCtlInfo
function QFriend:getFriendCtlInfo()
    return self._friendCtlInfo or {}
end

--获取好友数量
function QFriend:getFriendCount()
    return table.nums(self._friendList)
end

--获取好友是否有可领取体力
function QFriend:checkFriendCanGetEnergy()
    if app.unlock:getUnlockFriend() == false then
        return false
    end
    if self:checkEnergyIsMax() == false then
        return false
    end
    for _,friendId in pairs(self._friendList) do
        local friendInfo = self:getFriendInfoById(friendId)
        if friendInfo.existGift == true and friendInfo.alreadyGetGift == false then
            return true
        end
    end
    return false
end

--获取好友是否有好友申请
function QFriend:checkFriendHasApply()
    if app.unlock:getUnlockFriend() == false then
        return false
    end
    if self:getMaxCount() <= self:getFriendCount() then
        return false
    end
    return table.nums(self._applyFriendList) > 0
end

--获取friendInfo通过昵称
function QFriend:getFriendByNickName(nickname)
    for _,value in pairs(self._friendInfo) do
        if value.nickname == nickname then
            return value
        end
    end
end

--检测是否是好友通过昵称
function QFriend:checkIsFriendByNickName(nickname)
    local friendInfo = self:getFriendByNickName(nickname)
    if friendInfo == nil then return false end
    if self._friendList[friendInfo.user_id] == nil then return false end
    return true
end

function QFriend:checkIsFriendByUserId(userId)
    return self._friendList[userId] ~= nil
end

function QFriend:checkIsBlackedByUserId(userId)
    return self._blackFriendList[userId] ~= nil
end

--[[
    比较是否在线
    @returned 1 都在线
    @returned 0 都不在线
    @returned true a在线b不在
    @returned false b在线a不在
]]--
function QFriend:_sortOnline(a,b)
    local timeA = (a.passLeaveTime or 0)
    local timeB = (b.passLeaveTime or 0)
    if timeA == 0 and timeB == 0 then
        return 1
    end
    if timeA ~= timeB then
        if timeA == 0 then
            return true
        end
        if timeB == 0 then
            return false
        end
    end
    return 0
end

--[[
    通用的排序规则
    是否在线>等级>离线时间
]]
function QFriend:_sortCmmon(a,b)
    local result = self:_sortOnline(a, b)
    if result ~= 0 and result ~= 1 then
        return result
    end
    if result == 1 then
        if a.teamLevel ~= b.teamLevel then
            return a.teamLevel > b.teamLevel
        end
    end
    if result == 0 then
        if (a.passLeaveTime or 0) ~= (b.passLeaveTime or 0) then
            return a.passLeaveTime < b.passLeaveTime
        end
    end
    return a.user_id < b.user_id
end

--更新friendCtlInfo
function QFriend:updateFriendCtlInfo(friendCtlInfo)
    self._friendCtlInfo = friendCtlInfo
    self:dispatchEvent({name = self.EVENT_UPDATE_FRIEND_INFO})
end

--更新好友列表 删除黑名单列表、申请列表、推荐列表信息
function QFriend:updateFriend(friendList)
	for _,value in ipairs(friendList) do
		self._friendList[value.user_id] = value.user_id
		self._blackFriendList[value.user_id] = nil
		-- self._suggestFriendList[value.user_id] = nil
        self._applyFriendList[value.user_id] = nil
        self._friendInfo[value.user_id] = value
	end
	self:dispatchEvent({name = self.EVENT_UPDATE_FRIEND})
    self:dispatchEvent({name = self.EVENT_UPDATE_FRIEND_INFO})
    self:dispatchEvent({name = self.EVENT_UPDATE_SUGGEST_FRIEND})
    self:dispatchEvent({name = self.EVENT_UPDATE_APPLY_FRIEND})
end

--移除好友列表
function QFriend:deleteFriend(friendIdList, gotoBlack)
	for _,id in ipairs(friendIdList) do
		if gotoBlack == true then
			self._blackFriendList[id] = id
            self._suggestFriendList[id] = nil
		end
		self._friendList[id] = nil
        self._applyFriendList[id] = nil
	end
    self:dispatchEvent({name = self.EVENT_UPDATE_FRIEND})
    self:dispatchEvent({name = self.EVENT_UPDATE_FRIEND_INFO})
    self:dispatchEvent({name = self.EVENT_UPDATE_SUGGEST_FRIEND})
    self:dispatchEvent({name = self.EVENT_UPDATE_APPLY_FRIEND})
    if gotoBlack == true then
        self:dispatchEvent({name = self.EVENT_UPDATE_BLACK_FRIEND})
    end
end

--处理好友请求
function QFriend:acceptFriend(friendIdList, accept)
	for _,id in ipairs(friendIdList) do
		if accept == true then
			self._friendList[id] = self._applyFriendList[id]
            self._blackFriendList[id] = nil
            -- self._suggestFriendList[id] = nil
		end
		self._applyFriendList[id] = nil
	end
	self:dispatchEvent({name = self.EVENT_UPDATE_APPLY_FRIEND})
    self:dispatchEvent({name = self.EVENT_UPDATE_FRIEND_INFO})
end

--更新黑名单列表 删除好友列表和推荐列表信息和好友申请信息
function QFriend:updateBlackFriend(friendList)
	for _,value in ipairs(friendList) do
		self._friendList[value.user_id] = nil
		self._suggestFriendList[value.user_id] = nil
        self._applyFriendList[value.user_id] = nil
		self._blackFriendList[value.user_id] = value.user_id
        self._friendInfo[value.user_id] = value
	end
    self:dispatchEvent({name = self.EVENT_UPDATE_FRIEND})
    self:dispatchEvent({name = self.EVENT_UPDATE_FRIEND_INFO})
    self:dispatchEvent({name = self.EVENT_UPDATE_SUGGEST_FRIEND})
    self:dispatchEvent({name = self.EVENT_UPDATE_APPLY_FRIEND})
	self:dispatchEvent({name = self.EVENT_UPDATE_BLACK_FRIEND})
end

--移除黑名单列表
function QFriend:deleteBlackFriend(friendIdList)
	for _,id in ipairs(friendIdList) do
		self._blackFriendList[id] = nil
	end
	self:dispatchEvent({name = self.EVENT_UPDATE_BLACK_FRIEND})
end

--更新推荐列表 如果在好友列表或者黑名单中则不加入推荐列表
function QFriend:updateSuggestFriend(friendList, is_mannul)
    if friendList == nil or #friendList == 0 then return end
    self._suggestFriendList = {} --清空历史推荐列表
    for _,value in ipairs(friendList) do
        if self._blackFriendList[value.user_id] == nil then
            self._suggestFriendList[value.user_id] = value.user_id
            if self._friendInfo[value.user_id] == nil then
                self._friendInfo[value.user_id] = value
            end
        end
    end
    self:dispatchEvent({name = self.EVENT_UPDATE_SUGGEST_FRIEND, isReset = is_mannul})
end

--删除推荐列表
function QFriend:deleteSuggestFriend(friendList)
    for _,id in ipairs(friendList) do
            self._suggestFriendList[id] = nil
    end
    self:dispatchEvent({name = self.EVENT_UPDATE_SUGGEST_FRIEND})
end

--更新申请列表 如果在好友列表或者黑名单中则不加入推荐列表
function QFriend:updateApplyFriend(friendList)
	for _,value in ipairs(friendList) do
		if self._friendList[value.user_id] == nil and self._blackFriendList[value.user_id] == nil then
			self._applyFriendList[value.user_id] = value.user_id
            self._friendInfo[value.user_id] = value
		end
	end
	self:dispatchEvent({name = self.EVENT_UPDATE_APPLY_FRIEND})
end

--更新好友推送信息
function QFriend:friendChangeResponse(friendChangeResponse)
    if friendChangeResponse.kind == QFriend.ACCEPT then
        self:updateFriend({friendChangeResponse.userFriendCommonInfo})
    elseif friendChangeResponse.kind == QFriend.DELETE or friendChangeResponse.kind == QFriend.BLACK then
        self:deleteFriend({friendChangeResponse.userFriendCommonInfo.user_id})
    elseif friendChangeResponse.kind == QFriend.APPLY then
        self:updateApplyFriend({friendChangeResponse.userFriendCommonInfo})
    elseif friendChangeResponse.kind == QFriend.SEND_ENERGY_GIFT then
        local friendInfo = self:getFriendInfoById(friendChangeResponse.userFriendCommonInfo.user_id)
        if friendInfo ~= nil then
            friendInfo.existGift = true
            friendInfo.alreadyGetGift = false
            self:updateFriend({friendInfo})
        end
    end
end

------------------request area----------------------
--请求获取列表
function QFriend:requestList(success, fail, status)
    local request = {api = "USER_GET_FRIEND_LIST"}
    app:getClient():requestPackageHandler("USER_GET_FRIEND_LIST", request, function (data)
    	if data.apiUserGetFriendListResponse ~= nil then
            if data.apiUserGetFriendListResponse.userFriendInfo ~= nil then
                local friendList = {}
                for _,value in ipairs(data.apiUserGetFriendListResponse.userFriendInfo) do
                    value.common.alreadySendGift = value.alreadySendGift == true
                    value.common.alreadyGetGift = value.alreadyGetGift == true
                    value.common.existGift = value.existGift == true
                    table.insert(friendList, value.common)
                end
                self:updateFriend(friendList)
            end
    	end
        if success ~= nil then
            success()
        end
    end, fail)
end

--请求获取黑名单列表
function QFriend:requestBalckList(success, fail, status)
    local request = {api = "USER_GET_BLACK_LIST"}
    app:getClient():requestPackageHandler("USER_GET_BLACK_LIST", request, function (data)
    	if data.apiUserGetBlackListResponse ~= nil then
            if data.apiUserGetBlackListResponse.userBlackInfo ~= nil then
                local friendList = {}
                for _,value in ipairs(data.apiUserGetBlackListResponse.userBlackInfo) do
                    table.insert(friendList, value.common)
                end
                self:updateBlackFriend(friendList)
            end
    	end
        if success ~= nil then
            success()
        end
    end, fail)
end

--请求获取推荐好友
function QFriend:requestSuggestList(is_mannul, success, fail, status)
    local apiUserGetFriendSuggestListRequest = {is_mannul = is_mannul}
    local request = {api = "USER_GET_FRIEND_SUGGEST_LIST", apiUserGetFriendSuggestListRequest = apiUserGetFriendSuggestListRequest}
    app:getClient():requestPackageHandler("USER_GET_FRIEND_SUGGEST_LIST", request, function (data)
    	if data.apiUserGetFriendSuggestListResponse ~= nil then
    		self:updateSuggestFriend(data.apiUserGetFriendSuggestListResponse.userSuggestInfo, is_mannul)
            if data.apiUserGetFriendSuggestListResponse.friendCtlInfo ~= nil then
                self:updateFriendCtlInfo(data.apiUserGetFriendSuggestListResponse.friendCtlInfo)
            end
    	end
        if success ~= nil then
            success()
        end
    end, fail)
end

--请求获取申请好友
function QFriend:requestApplyList(success, fail, status)
    local request = {api = "USER_GET_APPLY_LIST"}
    app:getClient():requestPackageHandler("USER_GET_APPLY_LIST", request, function (data)
    	if data.apiUserGetApplyListResponse ~= nil then
            if data.apiUserGetApplyListResponse.userApplyInfo ~= nil then
                local friendList = {}
                for _,value in ipairs(data.apiUserGetApplyListResponse.userApplyInfo) do
                    table.insert(friendList, value.common)
                end
                self:updateApplyFriend(friendList)
            end
    	end
        if success ~= nil then
            success()
        end
    end, fail)
end

--请求添加好友
function QFriend:apiUserApplyFriendRequest(apply_user_id, apply_user_name, success, fail, status)
	local apiUserApplyFriendRequest = {apply_user_id = apply_user_id, apply_user_name = apply_user_name}
    local request = {api = "USER_APPLY_FRIEND", apiUserApplyFriendRequest = apiUserApplyFriendRequest}
    app:getClient():requestPackageHandler("USER_APPLY_FRIEND", request, function (data)
        self:deleteSuggestFriend({apply_user_id})
        if success ~= nil then
            success()
        end
    end, fail)
end

--请求移除黑名单
function QFriend:apiUserDeleteBlackFriendRequest(black_user_id, success, fail, status)
	local apiUserDeleteBlackFriendRequest = {black_user_id = black_user_id}
    local request = {api = "USER_DELETE_BLACK_FRIEND", apiUserDeleteBlackFriendRequest = apiUserDeleteBlackFriendRequest}
    app:getClient():requestPackageHandler("USER_DELETE_BLACK_FRIEND", request, function (data)
    	self:deleteBlackFriend({black_user_id})
        if success ~= nil then
            success()
        end
    end, fail)
end

--请求移除好友
function QFriend:apiUserDeleteFriendRequest(friend_user_id, gotoBlack, success, fail, status)
	local apiUserDeleteFriendRequest = {friend_user_id = friend_user_id, gotoBlack = gotoBlack}
    local request = {api = "USER_DELETE_FRIEND", apiUserDeleteFriendRequest = apiUserDeleteFriendRequest}
    app:getClient():requestPackageHandler("USER_DELETE_FRIEND", request, function (data)
        if data.apiUserDeleteFriendResponse ~= nil and data.apiUserDeleteFriendResponse.userFriendCommonInfo ~= nil then
            self._friendInfo[data.apiUserDeleteFriendResponse.userFriendCommonInfo.user_id] = data.apiUserDeleteFriendResponse.userFriendCommonInfo
        end
    	self:deleteFriend({friend_user_id}, gotoBlack)
        if success ~= nil then
            success()
        end
    end, fail)
end

--请求批准好友
function QFriend:apiUserAcceptFriendApplyRequest(apply_user_id, accept, success, fail, status)
	local apiUserAcceptFriendApplyRequest = {apply_user_id = apply_user_id, accept = accept}
    local request = {api = "USER_ACCEPT_FRIEND_APPLY", apiUserAcceptFriendApplyRequest = apiUserAcceptFriendApplyRequest}
    app:getClient():requestPackageHandler("USER_ACCEPT_FRIEND_APPLY", request, function (data)
    	self:acceptFriend({apply_user_id}, accept)
        if success ~= nil then
            success()
        end
    end, fail)
end

--赠送好友
function QFriend:apiUserSendFriendGiftRequest(friend_user_id, success, fail, status)
    local apiUserSendFriendGiftRequest = {friend_user_id = friend_user_id}
    local request = {api = "USER_SEND_FRIEND_GIFT", apiUserSendFriendGiftRequest = apiUserSendFriendGiftRequest}
    app:getClient():requestPackageHandler("USER_SEND_FRIEND_GIFT", request, function (data)
        local friend = self._friendInfo[friend_user_id]
        friend.alreadySendGift = true
        self:updateFriend({friend})
        remote.user:addPropNumForKey("todaySendEnergyCount", 1)
        if success ~= nil then
            success()
        end
    end, fail)
end

--一键赠送好友
function QFriend:apiUserSendAllFriendGiftRequest(isSecretary, success, fail, status)
    local apiUserSendAllFriendGiftRequest = nil--{isSecretary = isSecretary}
    local request = {api = "USER_SEND_ALL_FRIEND_GIFT", apiUserSendAllFriendGiftRequest = apiUserSendAllFriendGiftRequest}
    app:getClient():requestPackageHandler("USER_SEND_ALL_FRIEND_GIFT", request, function (data)
        local friends = {}
        for _,friendId in pairs(self._friendList) do
            local friendInfo = self:getFriendInfoById(friendId)
            if friendInfo.alreadySendGift ~= true then
                friendInfo.alreadySendGift = true
                table.insert(friends, friendInfo)
            end
        end
        self:updateFriend(friends)
        remote.user:addPropNumForKey("todaySendEnergyCount", #friends)
        if success ~= nil then
            success(data)
        end
    end, fail)
end

--收取好友赠送
function QFriend:apiUserGetFriendGiftRequest(friend_user_id, isSecretary, success, fail, status)
    local apiUserGetFriendGiftRequest = {friend_user_id = friend_user_id, isSecretary = nil}
    local request = {api = "USER_GET_FRIEND_GIFT", apiUserGetFriendGiftRequest = apiUserGetFriendGiftRequest}
    app:getClient():requestPackageHandler("USER_GET_FRIEND_GIFT", request, function (data)
        local friends = {}
        for _,friendId in ipairs(friend_user_id) do
            local friend = self._friendInfo[friendId]
            friend.alreadyGetGift = true
            friend.existGift = false
            table.insert(friends, friend)
        end
        if data.apiUserGetFriendGiftResponse.friendCtlInfo ~= nil then
            self:updateFriendCtlInfo(data.apiUserGetFriendGiftResponse.friendCtlInfo)
        end
        remote.user:update(data.apiUserGetFriendGiftResponse)
        self:updateFriend(friends)
        if success ~= nil then
            success(data)
        end
    end, fail)
end

--挑战好友
function QFriend:apiUserFightFriendStartRequest(friend_user_id, success, fail, status)
    local apiUserFightFriendStartRequest = {friend_user_id = friend_user_id}
    local request = {api = "USER_FIGHT_FRIEND_START", apiUserFightFriendStartRequest = apiUserFightFriendStartRequest}
    app:getClient():requestPackageHandler("USER_FIGHT_FRIEND_START", request, success, fail)
end

return QFriend