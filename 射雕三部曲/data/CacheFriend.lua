--[[
文件名:CacheFriend.lua
描述：好友数据抽象类型 
创建人：liaoyuangang
创建时间：2017.05.18
--]]

-- 好友数据说明
--[[
-- 服务器返回的好友数据中，每个条目包含的字段如下
	{
        PlayerId = "28f9e37d-c630-4aac-9065-98e9a0561137",
        Name = "羊艳血",
        HeadImageId = 12010004,
        Lv = 50,
        ModelId = 0,
        LeaveTime = 1496226841,
        MarryPlayerId = "00000000-0000-0000-0000-000000000000",
        IsActive = false,
        FAP = 172413,
        CanSendSTA = true,
        Vip = 0,
        PVPInterLv" = 0,
        DesignationId = 0,

        GuildId = "00000000-0000-0000-0000-000000000000",
        GuildName = "",
        UnionPostId = 0,
    },
]]

local CacheFriend = class("CacheFriend", {})

function CacheFriend:ctor()
    -- 好友列表的原始数据
	self.mFriendList = {}

    -- 以玩家Id为key的玩家信息列表（包含好友和陌生人）
    self.mIdList = {}

    -- 新加入好友Id列表对象
    self.mNewIdObj = require("data.NewIdList"):create()
end

-- 清空管理对象中的数据
function CacheFriend:reset()
    self.mFriendList = {}
    self.mIdList = {}
    self.mNewIdObj:clearNewId()
end

-- 清空现在好友列表
function CacheFriend:clearFriendList()
    self.mFriendList = {}
end

-- 刷新好友辅助缓存，主要用于数据获取时效率优化
function CacheFriend:refreshAssistCache()
    for _, item in ipairs(self.mFriendList) do
        self.mIdList[item.PlayerId] = item
    end
end

-- 设置好友列表
function CacheFriend:setFriendList(friendList)
	self.mFriendList = friendList or {}
    self:refreshAssistCache()
end

-- 修改一批玩家数据
function CacheFriend:modifyPlayers(playerList)
	for _, item in pairs(playerList or {}) do
		if self.mIdList[item.PlayerId] then
			self:modifyPlayerItem(item)
		else
            self.mIdList[item.PlayerId] = item
		end
    end
end

-- 添加一个玩家数据
--[[
-- 参数
    friendItem: 需要插入的数据
    onlyInsert: 是否只是插入数据，默认为false，如果设置为true，则需要在适当的地方调用 refreshAssistCache 接口
]]
function CacheFriend:insertPlayerItem(playerItem, onlyInsert)
    if not playerItem or not Utility.isEntityId(playerItem.PlayerId) then
        return
    end

    self.mIdList[playerItem.PlayerId] = playerItem

    -- self.mNewIdObj:insertNewId(friendItem.PlayerId)
end

-- 修改玩家数据
function CacheFriend:modifyPlayerItem(playerItem)
    if not playerItem or not Utility.isEntityId(playerItem.PlayerId) then
        return
    end

    local oldItem = self.mIdList[playerItem.PlayerId]
    if not oldItem then
        return 
    end

    for key, value in pairs(playerItem) do
        oldItem[key] = value
    end
end

-- 删除好友列表中的一批数据
--[[
-- 参数
	friendList: 需要删除的好友数据列表
]]
function CacheFriend:deleteFriends(friendList)
	for _, item in pairs(friendList or {}) do
        self:deleteFriendById(item.PlayerId, true)
    end

    self:refreshAssistCache()
end

-- 根据好友事例Id删除列表中对应的数据
--[[
-- 参数
    playerId: 好友实例Id
    onlyDelete: 是否只是删除装备缓存列表中的数据，默认为false, 外部调用者一般使用默认参数
]]
function CacheFriend:deleteFriendById(playerId, onlyDelete)
	for index, item in pairs(self.mFriendList) do
        if playerId == item.PlayerId then
            table.remove(self.mFriendList, index)
            break
        end
    end
    
    if not onlyDelete then
        self:refreshAssistCache()
    end

    self.mNewIdObj:clearNewId(playerId)
end

--- 返回好友列表数据
--[[
-- 返回值参考文件头部的 “好友数据说明” 
]]
function CacheFriend:getFriendList()
    return self.mFriendList
end

-- 判断玩家是否是好友
function CacheFriend:playerIsFriend(playerId)
    for _, item in pairs(self.mFriendList) do
        if item.PlayerId == playerId then
            return true
        end
    end

    return false
end

--- 获取玩家信息, 如果还没有从服务器获取数据，则请求服务器，所以该函数存在异步返回的情况
--[[
-- 参数：
    playerId: 玩家实例id
    callback: 通过回调函数返回数据，
-- 返回值参考文件头部的 “好友数据说明” 
--]]
function CacheFriend:getPlayerInfo(playerId, callback)
    local retData = self.mIdList[playerId]
    if retData then
        if callback then
            callback(retData)
        end
        return retData
    end

    -- 当前登录的游戏服务器信息
    local currServer = Player:getSelectServer()

    -- 从聊天数据中获取
    local playerInfo = ChatMng:getChatPlayerInfo(playerId)
    if playerInfo and playerInfo.ServerGroupId ~= currServer.ServerGroupID then  -- 跨服玩家
        local tempInfo = self:chatPlayerToFriendInfo(playerInfo)
        if callback then
            callback(tempInfo)
        end
        return tempInfo
    end

    self:requestGetPlayerInfoById(playerId, function(response)
        if not response or response.Status ~= 0 then
            return 
        end
        self.mIdList[playerId] = response.Value

        if callback then
            callback(response.Value)
        end
    end)
end

-- 聊天信息中的玩家信息转化为普通玩家信息格式
function CacheFriend:chatPlayerToFriendInfo(chatPlayerInfo)
    local tempInfo = chatPlayerInfo or {}
    tempInfo.ExtendInfo = tempInfo.ExtendInfo or {}

    local retInfo = {
        PlayerId = tempInfo.Id,
        Name = tempInfo.ExtendInfo.Name,
        HeadImageId = tempInfo.ExtendInfo.HeadImageId,
        Lv = tempInfo.ExtendInfo.Lv,
        LeaveTime = 1496300000,
        IsActive = false,
        FAP = tempInfo.ExtendInfo.FAP or tempInfo.ExtendInfo.Fap,
        Vip = tempInfo.ExtendInfo.Vip,
        PVPInterLv = tempInfo.ExtendInfo.DesignationId,
        FashionModelId = tempInfo.ExtendInfo.FashionModelId,
        MarryPlayerName = tempInfo.ExtendInfo.MarryPlayerName,

        GuildId = tempInfo.ExtendInfo.GuildId,
        GuildName = tempInfo.ExtendInfo.GuildName,
        UnionPostId = tempInfo.ExtendInfo.UnionPostId,
        guideId = tempInfo.ExtendInfo.guideId,
        guideName = tempInfo.ExtendInfo.guideName,
        guidePostId = tempInfo.ExtendInfo.guidePostId,

        ServerName = tempInfo.ServerName,
        ServerGroupId = tempInfo.ServerGroupId,
        MarryProfile = tempInfo.MarryProfile,
    }
    return retInfo
end

-- 获取新好友Id列表对象
--[[
-- 返回值
    返回值提供的接口查看 "data/NewidList.lua" 文件
]]
function CacheFriend:getNewIdObj()
    return self.mNewIdObj
end

-- 对好友列表排序
--[[
    参数：friendList: 好友列表
--]]
function CacheFriend:sortFriendList(friendList)
    table.sort(friendList, function(a, b)
        if a.IsActive and not b.IsActive then
            return true
        elseif not a.IsActive and b.IsActive then
            return false
        end
        if a.OutTime ~= b.OutTime then
            return a.OutTime < b.OutTime
        end
    end)
end

-- ============================= 服务器数据请求相关函数 =========================

-- 获取玩家好友信息列表
function CacheFriend:requestGetFriendList(callback)
    if next(self.mFriendList) then
        if callback then
            callback(self.mFriendList)
        end
    else
        HttpClient:request({
            moduleName = "Friend", 
            methodName = "GetFriendList", 
            svrMethodData = {},
            callback = function(response)
                if response and response.Status == 0 then
                    self.list = response.Value
                    self:sortFriendList(self.list)
                    self:setFriendList(self.list)
                    -- 通知各个模块，好友数据有修改
                    Notification:postNotification(EventsName.eFriendChanged)
                end
    
                if callback then
                    callback(self.list)
                end
            end
        })
    end
end

--添加好友
function CacheFriend:requestFriendApply(playerId)
    HttpClient:request({
        moduleName = "FriendMessage",
        methodName = "FriendApply",
        svrMethodData = {playerId, TR("交个朋友吧")},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            ui.showFlashView({text = TR("发送好友请求成功")})
        end
    })
end

-- 删除好友
function CacheFriend:requestDeleteFriend(playerId, callback)
    HttpClient:request({
        moduleName = "Friend",
        methodName = "DeleteFriend",
        svrMethodData = {playerId},
        callback = function (response)
            if response and response.Status == 0 then
                ui.showFlashView(TR("删除好友成功"))
                self:deleteFriendById(playerId)

                -- 通知各个模块，好友数据有修改
                Notification:postNotification(EventsName.eFriendChanged)
            end

            if callback then
                callback(response)
            end
        end
    })
end

-- 获取陌生人的详细信息
function CacheFriend:requestGetPlayerInfo(playerName, callback)
   HttpClient:request({
        moduleName = "Player",
        methodName = "GetPlayerInfo",
        svrMethodData = {playerName},
        callback = function(response)
            if response and response.Status == 0 then
                self:insertPlayerItem(response.Value)

                -- 通知各个模块，好友数据有修改
                Notification:postNotification(EventsName.eFriendChanged)
            end

            if callback then
                callback(response)
            end
        end
    })
end

-- 通过玩家Id获取玩家的详细信息
function CacheFriend:requestGetPlayerInfoById(playerId, callback)
   HttpClient:request({
        moduleName = "Player",
        methodName = "GetPlayerInfoById",
        svrMethodData = {playerId},
        callback = function(response)
            if response and response.Status == 0 then
                self:insertPlayerItem(response.Value)

                -- 通知各个模块，好友数据有修改
                Notification:postNotification(EventsName.eFriendChanged)
            end

            if callback then
                callback(response)
            end
        end
    })
end

return CacheFriend