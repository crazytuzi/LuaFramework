--[[
    文件名: SocketClient.lua
    描述：socket服务器连接类，可以使用该类构造多个socket连接对象，并且每个对象的生命周期可以自动维护。
    创建人：liaoyuangang
    创建时间：2016.4.1
--]]

SocketClient = class("SocketClient", {})

--- socket状态码
SocketClient.MSG_TYPE_NOT_INIT                 = 0
SocketClient.MSG_TYPE_SOCKET_OPEN              = 1
SocketClient.MSG_TYPE_RECEIVE_NEW_MESSAGE      = 2
SocketClient.MSG_TYPE_SOCKET_ERROR             = 3
SocketClient.MSG_TYPE_SOCKET_CLOSE             = 4
SocketClient.MSG_TYPE_SEND_NEW_MESSAGE         = 5
SocketClient.MSG_TYPE_SOCKET_RECONNECT_OPEN    = 6
SocketClient.MSG_TYPE_SOCKET_RECONNECT_ERROR   = 7
SocketClient.MSG_TYPE_RECEIVE_HEART_BEAT       = 100
SocketClient.MSG_TYPE_SEND_HEART_BEAT          = 101


--[[
-- 参数 params 中的各项为
	{
		serverUrl: 连接的服务器地址, 必传参数
		maxReconnCount: 最大重连次数, 默认为: 20
		isChatSocket: 是否连接的聊天服务器, 默认为: false
		recvCallback: 接收消息的回调函数
		connChangeCb: 连接状态改变的回调函数
	}
]]
function SocketClient:ctor(params)
	params = params or {}


    -- 发送消息的Id，数值在游戏期间唯一
    self.globalID = 1
	self.mServerUrl = params.serverUrl
	self.mMaxReconnCount = params.maxReconnectCount or 20
	self.mIsChatSocket = params.isChatSocket
	self.recvCallback = params.recvCallback
	self.connChangeCb = params.connChangeCb

	--
	local tempList = string.splitBySep(params.serverUrl, ":")
	self.mIp = tempList[1]  -- socket服务器地址
	self.mPort = tempList[2] -- socket服务器端口

	self.mConnStatus = false -- 当前是否连接
	self.mReconConnt = 0 -- 当前重连次数
	self.mCallbackMap = {} -- 发送消息Id与接收到消息回调的映射表
	self.mLastRecvTime = Player:getCurrentTime()

	-- 检查辅助layer是否存在，如果不存在则创建并添加到当前scene上
	self:checkHelperLayer()
end

-- 创建该类的辅助layer
function SocketClient:checkHelperLayer()
	if not tolua.isnull(self.mHelperLayer) then
		return
	end

	-- 辅助layer的 onCleanup 函数
	local function onCleanup()
		if self.mSocketMng then
			if self.socketReconnect then
                self.mSocketMng:destroy()
            else
                -- 不做任何事，重置之前的回调
                self.mListener:setExtFuncID(function (msgType, value, valueEx)
                end)
            end
			self.mSocketMng = nil
			self.mListener = nil
		end
	end

	-- 创建socket连接对象
	self.mSocketMng = SocketManager:create()
	self.mListener = self.mSocketMng:getListener()
	if self.mIsChatSocket then
		self.mListener:setFuncID(handler(self, self.onRecvMessage))
	else
		self.mListener:setExtFuncID(handler(self, self.onRecvMessage))
	end


	-- 登录IP
    local result = self.mSocketMng:init("", self.mPort, self.mIp)
    if not result then -- 初始化失败
    	onCleanup()
    	print("self.mSocketMng:init result:", result)
    	return
    end
    self.mSocketMng:setUnzip(true)--self.mIsChatSocket)

    -- 创建连接对象声明周期管理辅助对象, 当切换 scene 时该对象会被释放，目前游戏中会切换 scene的情况有
	--[[
		1、游戏中切换到登录页面
	    ...
	]]
    self.mHelperLayer = display.newLayer()
	-- self.mHelperLayer.onEnterTransitionFinish = onEnterTransitionFinish
	-- self.mHelperLayer.onExit = onExit
	self.mHelperLayer.onCleanup = onCleanup
	--
	local currScene = LayerManager.getMainScene()
	currScene:addChild(self.mHelperLayer)

	-- 给辅助对象添加 action 用于发送心跳包
	Utility.schedule(self.mHelperLayer, function()
		if not self.mConnStatus then
			return
		end

		if self.mIsChatSocket then
			-- self.mSocketMng:addMessageToSendQueue("")
		else
			self:sendMessage({ModuleName = "Player", MethodName = "Beat", Parameters = {}})
		end
	end, 30)

	-- 聊天服务器检查物理连接是否已断开，如果其他socket服务器需要检查，去掉判断即可
	if self.mIsChatSocket then
		Utility.schedule(self.mHelperLayer, function()
			if not self.mConnStatus then
				return
			end

			-- 如果指定时间内没有收到服务器的数据，认为物理连接已经断开，需要重新连接
			local timeCount = Player:getCurrentTime() - self.mLastRecvTime
			if timeCount >= 5 then
				print("Last receive data out time:", timeCount)
				self:reconnect()
		        if self.connChangeCb then
		        	self.connChangeCb(SocketClient.MSG_TYPE_SOCKET_RECONNECT_ERROR)
		        end
			end
		end, 2)
	end

    -- 聊天socket需要重连
    self.socketReconnect = self.mIsChatSocket
end

-- 登录socket服务器
function SocketClient:login()
	-- 登录聊天服务器
	local function loginChatSocket()
		local playerInfo = PlayerAttrObj:getPlayerInfo()
		local extendInfo = self:getExtendInfo()
		local signStr = string.format("%s-%s-7DE9DAA1-E87C-FF51-BCE3-15946DBE9462", playerInfo.PlayerId, extendInfo)
	    local partnerID = IPlatform:getInstance():getConfigItem("PartnerID")
	    local serverInfo = Player:getSelectServer()

	    self:sendMessage({
	    	MethodName = "Login",
	    	Parameters = {
	    		playerInfo.PlayerId, -- id
	    		extendInfo, -- extendInfo
	    		string.md5Content(signStr), -- sign
	    		tonumber(Player:getUserLoginInfo().PartnerId or partnerID), -- partnerId
	    		serverInfo.ServerID, -- serverId
	    	}
	    })
	end

	-- 从服务器获取公会信息
	local function requestGuildInfo(callback)
		HttpClient:request({
	        svrType = HttpSvrType.eGame,
	        moduleName = "Guild",
	        methodName = "GetGuildInfo",
	        svrMethodData = {},
	        callback = function(response)
	            -- 把数据设置到公会缓存对象中去
	            GuildObj:updateGuildInfo(response.Value)
	            --
	            callback()
	        end,
	    })
	end

	if self.mIsChatSocket then
		-- 有公会
		local guildId = (GuildObj:getGuildInfo() or {}).Id
		if Utility.isEntityId(guildId) then
			requestGuildInfo(function()
				loginChatSocket()
			end)
		else
			loginChatSocket()
		end
	else
		self:sendMessage({
			ModuleName = "Player",
			MethodName = "Login",
			Parameters = {PlayerAttrObj:getPlayerAttrByName("PlayerId")},
		})
	end
end

-- 自动生成需要传递的游戏数据
function SocketClient:getExtendInfo()
	local playerInfo = PlayerAttrObj:getPlayerInfo()
	--
	local guildId = (GuildObj:getGuildInfo() or {}).Id or EMPTY_ENTITY_ID
	local guildName = (GuildObj:getGuildInfo() or {}).Name
	local unionPostId = (GuildObj:getPlayerGuildInfo() or {}).PostId
	--
    local guideId = guideObj and guideObj:getGuideID() or EMPTY_ENTITY_ID
    local guideInfo = guideObj and guideObj:getguideInfo() or {}

    local extTable = {
    	-- 必要信息
    	Version = 1, -- 额外信息的版本号,
    	Name 	= playerInfo.PlayerName,
    	Lv 		= playerInfo.Lv,
    	Vip 	= playerInfo.Vip,
    	GuildId 		= guildId,
    	guideId 		= guideId,

    	-- 非必要信息，如果发布版本后，增删改这些信息后，需要更新 Version 字段的值，否则服务器不会刷新这些字段内容
        HeadImageId     = PlayerAttrObj:getPlayerAttrByName("HeadImageId"), --
        FashionModelId  = PlayerAttrObj:getPlayerAttrByName("FashionModelId") or 0,
        PVPInterLv      = PlayerAttrObj:getPlayerAttrByName("PVPInterLv") or 0,
        DesignationId      = PlayerAttrObj:getPlayerAttrByName("DesignationId") or 0,
        FAP             = PlayerAttrObj:getPlayerAttrByName("FAP"),

        -- 公会信息
        GuildName       = guildName,
    	UnionPostId 	= unionPostId,  -- 公会职位Id
    	-- 帮派信息
        guideName		= guideInfo.Name,
    	guidePostId 	= guideInfo.MemberRank, -- 帮派职位Id
    }
    -- dump(extTable, "SocketClient:getExtendInfo extTable:")
    return json.encode(extTable)
end

-- 删除 socket服务器连接
function SocketClient:destroy()
	if not tolua.isnull(self.mHelperLayer) then
		self.mHelperLayer:removeFromParent()
		self.mHelperLayer = nil
	end
end


-- 获取socket服务器的连接状态
function SocketClient:isConnected()
    return self.mConnStatus
end

-- 重连socket服务器
function SocketClient:reconnect()
	self.mConnStatus = false
    if self.mReconConnt < self.mMaxReconnCount then
        print("连接断开，尝试重连" .. self.mReconConnt)
        self.mReconConnt = self.mReconConnt + 1

        Utility.performWithDelay(self.mHelperLayer, function()
        	self.mSocketMng:reconnect()
        end, 2)
    else -- 30秒后再尝试重连
    	Utility.performWithDelay(self.mHelperLayer, function()
    		print("再次尝试重连 ....")
    		self.mReconConnt = 1 -- 重置重连次数
        	self.mSocketMng:reconnect()
        end, 30)
    end
end

-- 处理接收到的数据
function SocketClient:dealRecvData(value, valueEx)
	-- 收到消息，刷新最后一次接受数据时间
	self.mLastRecvTime = Player:getCurrentTime()

	local msgId, retValue = nil, {}
	if self.mIsChatSocket then
		retValue = cjson.decode(value)
	else
		msgId = value
		retValue = cjson.decode(valueEx)
	end

	-- dump(retValue, "收到新消息:")

	if self.recvCallback then
    	self.recvCallback(retValue)
    end
    if not self.mIsChatSocket and self.mCallbackMap[msgId] then
    	self.mCallbackMap[msgId](retValue)
    	self.mCallbackMap[msgId] = nil
    end
end

-- 处理网络状态
--[[
-- 参数
	msgType: 消息类型Id
	value: 消息数据，如果是聊天服务器，该自断为消息内容，否则为消息Id
	valueEx: 如果是聊天服务器没有该参数，否则为消息内容
]]
function SocketClient:onRecvMessage(msgType, value, valueEx)
	-- print("SocketClient:onRecvMessage msgType:", msgType)
    if msgType == SocketClient.MSG_TYPE_SOCKET_ERROR then
        print("创建连接失败")
        self.mConnStatus = false
        self:destroy()
        if self.connChangeCb then
        	self.connChangeCb(msgType)
        end
    elseif msgType == SocketClient.MSG_TYPE_SOCKET_OPEN then
        print("连接建立成功")
        self.mConnStatus = true
        self.mLastRecvTime = Player:getCurrentTime()

        -- 发送登录信息
		self:login()
		
        if self.connChangeCb then
        	self.connChangeCb(msgType)
        end
    elseif msgType == SocketClient.MSG_TYPE_SOCKET_CLOSE then
    	print("连接关闭")
        self.mConnStatus = false
        if not self.socketReconnect then
            -- 收到服务器的断开连接，则自动释放(圣渊下适用)
            self:destroy()
        else
            -- 重连失败会继续重连，聊天不再需要
            -- self:reconnect()
        end
        if self.connChangeCb then
        	self.connChangeCb(msgType)
        end
    elseif msgType == SocketClient.MSG_TYPE_SOCKET_RECONNECT_OPEN then
        print("重连成功")
        self.mReconConnt = 0
        self.mConnStatus = true
        self.mLastRecvTime = Player:getCurrentTime()

        -- 发送登录信息
		self:login()

        if self.connChangeCb then
        	self.connChangeCb(msgType)
        end
    elseif msgType == SocketClient.MSG_TYPE_SOCKET_RECONNECT_ERROR then
    	print("重连失败")
        self:reconnect()

        if self.connChangeCb then
        	self.connChangeCb(msgType)
        end
    elseif msgType == SocketClient.MSG_TYPE_RECEIVE_NEW_MESSAGE then
    	self:dealRecvData(value, valueEx)
    end
end

-- 发送消息
--[[
-- 参数
	sendData 中各项为：
	    {
	        ModuleName: 模块名
	        MethodName: 方法名
	        Parameters: 传递的内容，与NetworkRequest类似
	    }
    callback: 发送消息得到结果后的回调
--]]
function SocketClient:sendMessage(sendData, callback)
	self:checkHelperLayer()
	if not self.mSocketMng then
		print("SocketClient:sendMessage not mSocketMng, so return")
		return
	end

    local cmdStr = json.encode(sendData or {})
    -- print("SocketClient:sendMessage: " .. cmdStr)

    if self.mIsChatSocket then
    	self.mSocketMng:addMessageToSendQueue(cmdStr)
    else
    	self.mSocketMng:addIdMessageToSendQueue(tostring(self.globalID), cmdStr)

    	-- 保存回调函数
	    if callback then
	        self.mCallbackMap[self.globalID] = callback
	    end
    	self.globalID = self.globalID + 1
    end
end

return SocketClient
