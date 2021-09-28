--[[
    文件名: ChatMng.lua
    描述：聊天数据管理对象
    创建人：liaoyuangang
    创建时间：2016.11.1
--]]


-- 缓存的聊天信息数据结构
--[[
    {
        [playerId] = {
            [ChatChanne] = {  -- 世界、帮派、公会、系统、组队
                item1,
                item2,
                ...
            }
            ...
            ...
            ...
            [Enums.ChatChanne.ePrivate] = { -- 私聊
                [privatePlayerId] = {
                    item1,
                    item2,
                    ....
                }
            }
        }
        ...
    }
]]

-- 频道聊天数据的格式为:
--[[
    {
        {
            Id: 消息Id
            ChannelType: 聊天频道类型
            Message: 聊天消息内容
            Voice: 语音信息，json字符串格式
            FromPlayerId: 发送人Id
            FromPlayer = {  --发送人详细信息
                Id = "cf34437d-683d-4967-b6ae-ea9a0fbc3e37",
                ServerGroupId = 20050,
                ServerName = "新还珠-开发2",
                ExtendInfo = {
                    Name = "lyg102",
                    HeadImageId = 12010001,
                    PVPInterLv = 0,
                    DesignationId = 0,
                    Lv = 60,
                    Vip = 20,
                    Fap = 21081,
                    FashionModelId = 0,
                    GuildId = "b06facd2-d2e4-4104-b054-bddccab422a6",
                    GuildName = "lyg101",
                    UnionPostId = 34001004,

                    MarryPlayerName = ""
                }
            }
            ToPlayerId: 接收人Id
            ToPlayer = { -- 接收人详细信息

            }
            TimeStamp: 消息的发生时间

            -- =========== 客户端
            InvalidTime: 消息过期时间，目前是客户端针对模型特殊消息添加的字段，以后可以考虑由服务器传回
        }

        ...
    }
]]

-- 聊天标识信息数据结构
--[[
-- 标识信息中的字段有
    {
        [playerId] = {
            [ChatChanne] = { -- 世界、帮派、公会、系统、组队
                maxId: 最大消息Id, 连接聊天服务器时从服务器获取
                readMaxId: 已读的最大消息Id,记录在本地文件中的数据
                clearId: 清空历史记录的Id
                hadHistory: 是否已获取过历史记录
                isTop: 是否已置顶，默认为false
            }
            ...
            ...

            [Enums.ChatChanne.ePrivate] = { -- 私聊
                [privatePlayerId] = {
                    maxId: 最大消息Id, 连接聊天服务器时从服务器获取
                    readMaxId: 已读的最大消息Id,记录在本地文件中的数据
                    clearId: 清空历史记录的Id
                    hadHistory: 是否已获取过历史记录
                    isTop: 是否已置顶，默认为false
                }
                ...
                ...
            }
        }
        ...
    }
]]

ChatMng = {
    mChatInfo = {}, -- 参看文件头处的“缓存的聊天信息数据结构”
    mAvatarChatInfo = {}, -- 通过 avatar 频道传回的聊天信息，结构与 mChatInfo 一致
    mMarkInfo = {}, -- 参看文件头处的“聊天标识信息数据结构”
}

-- 聊天页面不能跳转的页面列表
ChatForbidCleanUpList = {
    ["ComBattle.BattleLayer"] = true,       -- 战斗页面
    ["challenge.ExpediMapLayer"] = true,    -- 组队副本走路
    ["challenge.ExpediFightLayer"] = true,  -- 组队副本对掌
}

-- 创建 socket 连接对象
function ChatMng:new()
    -- 记录最后收到的数据信息
    self.mLastRecData = {}

    -- 删除原来的连接
    if self.mSocketObj then
        self.mSocketObj:destroy()
        self.mSocketObj = nil
    end

    -- 创建连接对象
    local serverInfo = Player:getSelectServer()
    self.mSocketObj = require("network.SocketClient"):create({
        serverUrl = serverInfo.ChatServerUrl, --  "10.1.0.22:10011", -- "10.1.0.21:10074", --
        isChatSocket = true,
        recvCallback = function(response)
            self:dealRecvData(response)
        end,
        connChangeCb = function(msgType)
            -- todo
        end
    })

    -- 聊天分组信息
    self.chatGroupList = {}
    local chatGroupStr = PlayerAttrObj:getPlayerAttrByName("ChatPartnerIdStr")
    local chatGroups = string.split(chatGroupStr, ";")
    for i,v in ipairs(chatGroups) do
        local chatPList = string.split(v, ",")
        table.insert(self.chatGroupList, chatPList)
    end
    -- 判断自己组信息
    local partnerID = IPlatform:getInstance():getConfigItem("PartnerID")
    self.playerGroupIndex = self:_inChatGroupIndex(partnerID)
end

-- 判断玩家所处的聊天群组
function ChatMng:_inChatGroupIndex(pId)
    local inIndex = 999
    for i,list in ipairs(self.chatGroupList) do
        if table.indexof(list, pId) then
            inIndex = i
            break
        end
    end
    return inIndex
end

-- 判断玩家消息是否需要屏蔽
function ChatMng:_isPIdNeedShield(pId)
    local pIndex = self:_inChatGroupIndex(tostring(pId))
    return self.playerGroupIndex ~= pIndex
end

-- 删除过期的消息
local function deleteInvalidMsg(msgList)
    if not msgList then
        return
    end

    local currTime = Player:getCurrentTime()
    for index = #msgList, 1, -1 do
        local tempItem = msgList[index]
        if tempItem.InvalidTime and tempItem.InvalidTime > 0 and tempItem.InvalidTime < currTime then
            table.remove(msgList, index)
        end
    end

end

-- 获取聊天信息
--[[
-- 参数
    channeType: 聊天频道类型，取值为“Eenums.lua”中“Enums.ChatChanne”的枚举定义, 默认为：Enums.ChatChanne.eWorld
    privatePlayerId: 私聊的玩家Id
]]
function ChatMng:getTypeChatData(channeType, privatePlayerId)
    --
    channeType = channeType or Enums.ChatChanne.eWorld
    local playerId = PlayerAttrObj:getPlayerInfo().PlayerId
    local retList = self.mChatInfo[playerId] and self.mChatInfo[playerId][channeType] or {}
    if channeType == Enums.ChatChanne.ePrivate then
        if privatePlayerId then
            retList = retList[privatePlayerId] or {}
            if not next(retList) then
                -- 是否需要自动获取历史消息
                self:setDefMarkInfo(channeType, privatePlayerId)
                local markInfo = self.mMarkInfo[playerId][channeType][privatePlayerId]
                if not markInfo.hadHistory then
                    self:getNextHistory(channeType, privatePlayerId)
                end
            end

            deleteInvalidMsg(retList)
            return retList
        end
    else
        if not next(retList) then
            -- 是否需要自动获取历史消息
            local markInfo = self.mMarkInfo[playerId] and self.mMarkInfo[playerId][channeType] or {}
            if not markInfo.hadHistory then
                self:getNextHistory(channeType)
            end
        end
        deleteInvalidMsg(retList)
        return retList
    end

    return {}
end

-- 获取avater频道返回的聊天信息
function ChatMng:getTypeChatDataAvatar(channeType, privatePlayerId)
    channeType = channeType or Enums.ChatChanne.eWorld
    local playerId = PlayerAttrObj:getPlayerInfo().PlayerId
    local retList = self.mAvatarChatInfo[playerId] and self.mAvatarChatInfo[playerId][channeType] or {}

    if channeType == Enums.ChatChanne.ePrivate then
        if privatePlayerId then
            retList = retList[privatePlayerId] or {}
        else
            retList = {}
        end
    end
    deleteInvalidMsg(retList)
    return retList
end

-- 获取某频道的最后一条消息
--[[
-- 参数
    channeType: 聊天频道类型，取值为“Eenums.lua”中“Enums.ChatChanne”的枚举定义, 默认为：Enums.ChatChanne.eWorld
    privatePlayerId: 私聊的玩家Id
]]
function ChatMng:getTypeLastData(channeType, privatePlayerId)
    channeType = channeType or Enums.ChatChanne.eWorld
    local playerId = PlayerAttrObj:getPlayerInfo().PlayerId
    local retList = self.mChatInfo[playerId] and self.mChatInfo[playerId][channeType] or {}

    if channeType == Enums.ChatChanne.ePrivate then
        retList = privatePlayerId and retList[privatePlayerId] or {}
        return retList[#retList]
    else
        for index = #retList, 1, -1 do
            local tempItem = retList[index]
            if not tempItem.FromPlayer or not tempItem.FromPlayer.Id or not EnemyObj:isEnemyPlayer(tempItem.FromPlayer.Id) then
                return tempItem
            end
        end
    end
end

-- 获取收到的最后一条信息
function ChatMng:getLastRecData()
    return self.mLastRecData or {}
end

-- 获取服务器当前是否已连接
function ChatMng:isConnected()
    return self.mSocketObj and self.mSocketObj:isConnected()
end

-- 发送聊天信息
--[[
-- 参数
    channel: 频道Id, 取值为 Eenums.lua文件Enums.ChatChanne 中的枚举定义
    text: 消息内容
    playerId: 私聊的目标玩家Id（如果是私聊才发此数据，反之则不发）
]]
function ChatMng:sendMessage(channel, text, voice, playerId)
    local toPlayerId = channel == Enums.ChatChanne.ePrivate and playerId or nil
    local tempData = {
        MethodName = "SendMessage",
        Parameters = {
            channel, -- 发送的频道
            text, -- 发送的消息
            voice or "", -- 语音信息
            toPlayerId or "", -- 私聊玩家的 playerId, 非私聊不需要该参数
        }
    }
    self.mSocketObj:sendMessage(tempData)
end

-- 举报玩家
--[[
--参数
    targetId: 被举报玩家的Id
    targetName: 被举报玩家的名称
    reportType: 举报类型
    reason: 举报原因
]]
function ChatMng:report(targetId, targetName, reportType, reason)
    local tempData = {
        MethodName = "Report",
        Parameters = {targetId, targetName, reportType, reason},
    }
    self.mSocketObj:sendMessage(tempData)
end

-- 获取聊天历史记录, 由于客户端需要对未读的消息进行小红点提醒，所以需要永久保存已经读取过的消息的最大Id
--[[
-- 参数
    channelTypeValue: 聊天频道
    messageId: 消息Id（获取消息时，要取Id<messageId的数据，初始传一个int的最大值，之后再传客户端的最小值）
    count: 获取的消息数量
    privatePlayerId: 私聊的玩家Id
]]
function ChatMng:getHistory(channelType, messageId, count, privatePlayerId)
    local tempData = {
        MethodName = "GetHistory",
        Parameters = {channelType, messageId, count, privatePlayerId or ""},
    }
    self.mSocketObj:sendMessage(tempData)
end

-- 删除私聊历史记录
--[[
-- 参数
    channelType: 频道类型
    privatePlayerId: 私聊的玩家Id
]]
function ChatMng:deleteHistory(channelType, privatePlayerId)
    if channelType == Enums.ChatChanne.ePrivate then
        local tempData = {
            MethodName = "DeletePrivateHistory",
            Parameters = {privatePlayerId},
        }
        self.mSocketObj:sendMessage(tempData)
    else
        local playerId = PlayerAttrObj:getPlayerInfo().PlayerId
        local tempInfo = self.mChatInfo[playerId]
        if tempInfo and tempInfo[channelType] and next(tempInfo[channelType]) then
            local msgList = tempInfo[channelType]
            -- 先更新清空历史消息Id
            self:setClearMsgId(channelType)
            -- 设置已读消息为最大Id
            self:setReadMsgId(channelType, msgList[#msgList].Id)
            -- 再清空数据列表
            tempInfo[channelType] = {}

            -- 消息通知私聊玩家列表改变
            Notification:postNotification(EventsName.eChatPrivateChanged)
        end
    end
end

-- 解析表情字符为 {bq_1.png} 格式
--[[
-- 参数
    str: 解析前的字符串
-- 返回值
    第一个: 解析后的字符串
    第二个: 占用字符个数，这个值不等于字符串长度
]]
function ChatMng:faceStrUnpack(str)
    local faceLen = 0
    local retStr = string.gsub(str or "", "@%d+ ?", function(pattern)
        local tempStr = pattern:sub(pattern:find("%d+"))
        if tonumber(tempStr) <= 40 then
            tempStr = string.format(" {bq_%s.png}", tempStr)
            faceLen = faceLen + tempStr:utf8len() - 1
        end

        return tempStr
    end)

    return retStr, retStr:utf8len() - faceLen
end

-- 获取指定字符数的消息字符串（一个表情符号算3个字符）
--[[
-- 参数
    str: 原始的消息字符串
    maxLen: 需要的最大显示字符
    needBreak: 是否需要回车换行符，默认为true
]]
function ChatMng:getSubMsg(str, maxLen, needBreakChar)
    local faceUseChar = 3 -- 每个表情符号占用3个字符
    if needBreak == false then
        str = string.gsub(str or "", "[\r\n]+", "")
    end

    local retStr = ""
    local freeCount = maxLen or 0
    while string.len(str or "") > 0 and freeCount > 0 do
        local i, j = string.find(str, "@%d+ ?")
        if not i then
            local tempStr = string.utf8sub(str, 1, freeCount)
            retStr = retStr .. tempStr
            break
        end

        local tempStr = string.sub(str, 1, i - 1)
        local tempLen = string.utf8len(tempStr)
        retStr = retStr .. string.utf8sub(tempStr, 1, freeCount)
        freeCount = freeCount - math.min(tempLen, freeCount)
        if freeCount < faceUseChar then
            break
        end
        retStr = retStr .. string.sub(str, i, j)
        freeCount = freeCount - faceUseChar

        str = string.sub(str, j + 1, string.len(str))
    end

    return retStr
end

-- 获取消息字的字符数（一个表情符号算3个字符）
--[[
-- 参数
    str: 原始的消息字符串
    needBreak: 是否计算回车换行符，默认为true
]]
function ChatMng:getMsgLength(str, needBreak)
    local ret = 0
    local faceUseChar = 3 -- 每个表情符号占用3个字符
    if needBreak == false then
        str = string.gsub(str or "", "[\r\n]+", "")
    end

    -- 计算所有表情占用的长度
    str = string.gsub(str or "", "@%d+ ?", function (s)
        ret = ret + faceUseChar
        return ""
    end)
    -- 添加字符原生长度
    ret = ret + string.utf8len(str)
    return ret
end

-- 获取某频道未读消息的数量
--[[
-- 参数
    channelType: 需要获取未读消息的频道Id, 如果为nil，表示获取所有的频道
    privatePlayerId: 私聊的玩家Id, 如果为nil，并且 channelType 为私聊频道是，表示获取所有的私聊玩家
-- 返回值
    如果有未读消息，返回true，否则返回false
]]
function ChatMng:getUnreadCount(channelType, privatePlayerId)
    local playerId = PlayerAttrObj:getPlayerInfo().PlayerId
    if not self.mMarkInfo[playerId] then
        return 0
    end

    -- 获取一个频道的未读消息数量
    local function getOneChanneUnreadCount(channel)
        local maxSaveCount = self:getSaveMaxCount(channel)

        if channel == Enums.ChatChanne.ePrivate then
            local tempCount = 0
            local privateIdList = privatePlayerId and {privatePlayerId} or self:getPrivateIdList()
            for _, privateId in pairs(privateIdList) do
                -- 如果还没有该频道相关的信息
                self:setDefMarkInfo(channel, privateId)

                local markInfo = self.mMarkInfo[playerId][channel][privateId]

                tempCount = tempCount + math.min(markInfo.maxId - markInfo.readMaxId, maxSaveCount)
            end

            return tempCount
        else
            -- 如果还没有该频道相关的信息
            self:setDefMarkInfo(channel)

            local markInfo = self.mMarkInfo[playerId][channel]
            local tempCount = math.min(markInfo.maxId - markInfo.readMaxId, maxSaveCount)
            return tempCount > 0 and tempCount or 0
        end
    end

    if channelType then
        return getOneChanneUnreadCount(channelType)
    else
        local retCount = 0
        for key, item in pairs(self.mMarkInfo[playerId]) do
            retCount = retCount + getOneChanneUnreadCount(key)
        end
        return retCount
    end
end

-- 判断某频道的某条消息是否为未读消息
--[[
-- 参赛
    channelType: 频道类型Id
    msgId: 消息Id
    privatePlayerId: 私聊的玩家Id,
]]
function ChatMng:msgIsUnread(channelType, msgId, privatePlayerId)
    local playerId = PlayerAttrObj:getPlayerInfo().PlayerId

    -- 如果还没有该频道相关的信息，设置该频道默认的聊天信息和标识信息
    self:setDefMarkInfo(channelType, privatePlayerId)
    self:setDefChatInfo(channelType, privatePlayerId)

    if channel == Enums.ChatChanne.ePrivate then
        if privatePlayerId then
            local markInfo = self.mMarkInfo[playerId][channelType][privatePlayerId]
            return msgId > markInfo.readMaxId
        end

        return true
    else
        local markInfo = self.mMarkInfo[playerId][channelType]
        print("msgId, readMaxId:", msgId, markInfo.readMaxId)
        return msgId > markInfo.readMaxId
    end
end

-- 设置频道消息的最大Id
function ChatMng:setMsgMaxId(channelType, msgId, privatePlayerId)
    local playerId = PlayerAttrObj:getPlayerInfo().PlayerId

    -- 如果还没有该频道相关的信息，设置该频道默认的聊天信息和标识信息
    self:setDefMarkInfo(channelType, privatePlayerId)

    -- 频道消息列表
    if channelType == Enums.ChatChanne.ePrivate then
        if privatePlayerId then
            local markInfo = self.mMarkInfo[playerId][channelType][privatePlayerId]
            markInfo.maxId = math.max(markInfo.maxId or 0, msgId or 0)
        end
    else
        local markInfo = self.mMarkInfo[playerId][channelType]
        markInfo.maxId = math.max(markInfo.maxId or 0, msgId or 0)
    end
end

-- 设置已读的最大消息Id
--[[
-- 参数
    channelType: 频道类型Id
    msgId: 消息Id, 如果为nil，表示设置到已获取消息的最后一条
    privatePlayerId: 私聊的玩家Id,
]]
function ChatMng:setReadMsgId(channelType, msgId, privatePlayerId)
    local playerId = PlayerAttrObj:getPlayerInfo().PlayerId

    -- 如果还没有该频道相关的信息，设置该频道默认的聊天信息和标识信息
    self:setDefMarkInfo(channelType, privatePlayerId)
    self:setDefChatInfo(channelType, privatePlayerId)

    -- 保存到文件中的数据
    local saveData = LocalData:getReadMaxInfo(playerId) or {}

    -- 频道消息列表
    if channelType == Enums.ChatChanne.ePrivate then
        if privatePlayerId then
            local chatInfo = self.mChatInfo[playerId][channelType][privatePlayerId]
            local markInfo = self.mMarkInfo[playerId][channelType][privatePlayerId]

            --
            local endChatItem = chatInfo[#chatInfo]
            -- 先修改到内存缓存
            markInfo.readMaxId = math.max(markInfo.readMaxId or 0, msgId or endChatItem and endChatItem.Id or 0)
            -- 再修改保存到文件中
            saveData[channelType] = saveData[channelType] or {}
            saveData[channelType][privatePlayerId] = saveData[channelType][privatePlayerId] or {}
            saveData[channelType][privatePlayerId].readMaxId = markInfo.readMaxId
        end
    else
        local chatInfo = self.mChatInfo[playerId][channelType]
        local markInfo = self.mMarkInfo[playerId][channelType]

        --
        local endChatItem = chatInfo[#chatInfo]
        -- 先修改到内存缓存
        markInfo.readMaxId = math.max(markInfo.readMaxId or 0, msgId or endChatItem and endChatItem.Id or 0)

        -- 再修改保存到文件中
        saveData[channelType] = saveData[channelType] or {}
        saveData[channelType].readMaxId = markInfo.readMaxId
    end

    LocalData:saveReadMaxInfo(playerId, saveData)

    -- 消息通知聊天标识信息修改
    Notification:postNotification(EventsName.eChatUnreadPrefix .. tostring(channelType))
    Notification:postNotification(EventsName.eChatUnreadPrefix)
end

-- 设置已清空的消息Id
--[[
-- 参数
    channelType: 频道类型Id
    msgId: 消息Id, 如果为nil，表示设置到已获取消息的最后一条
    privatePlayerId: 私聊的玩家Id,
]]
function ChatMng:setClearMsgId(channelType, msgId, privatePlayerId)
    local playerId = PlayerAttrObj:getPlayerInfo().PlayerId

    -- 如果还没有该频道相关的信息，设置该频道默认的聊天信息和标识信息
    self:setDefMarkInfo(channelType, privatePlayerId)
    self:setDefChatInfo(channelType, privatePlayerId)

    -- 保存到文件中的数据
    local saveData = LocalData:getReadMaxInfo(playerId) or {}

    -- 频道消息列表
    if channelType == Enums.ChatChanne.ePrivate then
        if privatePlayerId then
            local chatInfo = self.mChatInfo[playerId][channelType][privatePlayerId]
            local markInfo = self.mMarkInfo[playerId][channelType][privatePlayerId]

            --
            local endChatItem = chatInfo[#chatInfo]
            -- 先修改到内存缓存
            markInfo.clearId = math.max(markInfo.clearId or 0, msgId or endChatItem and endChatItem.Id or 0)

            -- 再修改保存到文件中
            saveData[channelType] = saveData[channelType] or {}
            saveData[channelType][privatePlayerId] = saveData[channelType][privatePlayerId] or {}
            saveData[channelType][privatePlayerId].clearId = markInfo.clearId
        end
    else
        local chatInfo = self.mChatInfo[playerId][channelType]
        local markInfo = self.mMarkInfo[playerId][channelType]

        --
        local endChatItem = chatInfo[#chatInfo]
        -- 先修改到内存缓存
        markInfo.clearId = math.max(markInfo.clearId or 0, msgId or endChatItem and endChatItem.Id or 0)

        -- 再修改保存到文件中
        saveData[channelType] = saveData[channelType] or {}
        saveData[channelType].clearId = markInfo.clearId
    end

    LocalData:saveReadMaxInfo(playerId, saveData)
end

-- 设置某频道的置顶状态
function ChatMng:setIsTop(channelType, privatePlayerId, isTop)
    local playerId = PlayerAttrObj:getPlayerInfo().PlayerId

    -- 如果还没有该频道相关的信息，设置该频道默认的聊天信息和标识信息
    self:setDefMarkInfo(channelType, privatePlayerId)

    -- 保存到文件中的数据
    local saveData = LocalData:getReadMaxInfo(playerId) or {}

    -- 频道消息列表
    if channelType == Enums.ChatChanne.ePrivate then
        if privatePlayerId then
            local markInfo = self.mMarkInfo[playerId][channelType][privatePlayerId]
            -- 先修改到内存缓存
            markInfo.isTop = isTop

            -- 再修改保存到文件中
            saveData[channelType] = saveData[channelType] or {}
            saveData[channelType][privatePlayerId] = saveData[channelType][privatePlayerId] or {}
            saveData[channelType][privatePlayerId].isTop = markInfo.isTop
        end
    else
        local markInfo = self.mMarkInfo[playerId][channelType]
        -- 先修改到内存缓存
        markInfo.isTop = isTop

        -- 再修改保存到文件中
        saveData[channelType] = saveData[channelType] or {}
        saveData[channelType].isTop = markInfo.isTop
    end

    LocalData:saveReadMaxInfo(playerId, saveData)
end

-- 获取某频道是否已置顶
function ChatMng:getIsTop(channelType, privatePlayerId)
    local playerId = PlayerAttrObj:getPlayerInfo().PlayerId

    -- 如果还没有该频道相关的信息，设置该频道默认的聊天信息和标识信息
    self:setDefMarkInfo(channelType, privatePlayerId)

    if channelType == Enums.ChatChanne.ePrivate then
        if privatePlayerId then
            local markInfo = self.mMarkInfo[playerId][channelType][privatePlayerId]
            return markInfo.isTop
        end

        return false
    else
        local markInfo = self.mMarkInfo[playerId][channelType]
        return markInfo.isTop
    end
end

-- 获取下一组聊天历史记录
--[[
-- 参数
    channelType: 聊天频道
    privatePlayerId: 私聊的玩家Id
]]
function ChatMng:getNextHistory(channelType, privatePlayerId)
    local playerId = PlayerAttrObj:getPlayerInfo().PlayerId
    -- 如果还没有该频道相关的信息，设置该频道默认的聊天信息和标识信息
    self:setDefMarkInfo(channelType, privatePlayerId)
    self:setDefChatInfo(channelType, privatePlayerId)

    local chatInfo, markInfo = {}, {}
    if channelType == Enums.ChatChanne.ePrivate then -- 私聊频道
        if privatePlayerId then
            chatInfo = self.mChatInfo[playerId][channelType][privatePlayerId]
            markInfo = self.mMarkInfo[playerId][channelType][privatePlayerId]
        else
            chatInfo = {}
            markInfo = {readMaxId = 0, clearId = 0, maxId = 0, hadHistory = false, isTop = false}
        end
    else
        chatInfo = self.mChatInfo[playerId][channelType]
        markInfo = self.mMarkInfo[playerId][channelType]
    end

    -- 查找读取位置
    if markInfo.maxId <= 0 then -- 没有历史聊天记录
        return false
    end

    -- 频道缓存消息的最大条目数
    local maxSaveCount =  self:getSaveMaxCount(channelType)
    -- 该频道已有的条目数
    local chatCount = #chatInfo

    -- 如果已有条目超过了显示的最大条目数，则不需要获取历史记录
    if chatCount >= maxSaveCount then
        return false
    end

    --
    local messageId, count = markInfo.maxId + 1, math.min(10, markInfo.maxId)
    if chatCount > 0 then
        local beginMsgId = chatInfo[1].Id
        local endMsgId = chatInfo[chatCount].Id
        if endMsgId < markInfo.maxId then -- 最近的未读消息
            count = markInfo.maxId - endMsgId
        elseif beginMsgId > markInfo.readMaxId then -- 以前的未读消息
            messageId = beginMsgId
            count = math.min(10, beginMsgId - markInfo.readMaxId)
        else -- 历史消息
            messageId = beginMsgId
        end
    else
        count = math.max(math.min(markInfo.maxId - markInfo.readMaxId, maxSaveCount), count)
    end

    count = math.min(count, messageId - (markInfo.clearId > 0 and (markInfo.clearId + 1) or 0))
    if count <= 0 then
        return false
    end

    -- 记录是否已获取过历史消息
    markInfo.hadHistory = true

    -- 组队频道没有历史消息
    if channelType ~= Enums.ChatChanne.eTeam then
        self:getHistory(channelType, messageId, math.min(count, maxSaveCount), privatePlayerId)
    end
end

-- 获取有聊天记录的好友的玩家Id列表
function ChatMng:getPrivateIdList()
    local retList = {}
    local playerId = PlayerAttrObj:getPlayerInfo().PlayerId

    local tempList = self.mChatInfo[playerId] and self.mChatInfo[playerId][Enums.ChatChanne.ePrivate] or {}
    -- local tempList = self.mMarkInfo[playerId] and self.mMarkInfo[playerId][Enums.ChatChanne.ePrivate] or {}
    for key, item in pairs(tempList) do
        if Utility.isEntityId(key) then
            table.insert(retList, key)
        end
    end

    return retList
end

-- 添加一个私聊玩家
function ChatMng:addPrivateId(privateId)
    self:setDefMarkInfo(Enums.ChatChanne.ePrivate, privateId)
end

-- 根据玩家Id获取玩家信息
function ChatMng:getChatPlayerInfo(playerId)
    local myPlayerId = PlayerAttrObj:getPlayerInfo().PlayerId
    local chatInfo = self.mChatInfo[myPlayerId] or {}

    local channeList = {
        Enums.ChatChanne.eWorld,
        Enums.ChatChanne.eCrossServer,
        Enums.ChatChanne.eHorn,
        Enums.ChatChanne.eTeam,
        Enums.ChatChanne.eUnion,
        Enums.ChatChanne.ePrivate
    }
    for _, channeType in pairs(channeList) do
        local dataList = chatInfo[channeType] or {}
        if channeType == Enums.ChatChanne.ePrivate then
            for toPlayerId, itemList in pairs(dataList) do
                if toPlayerId == playerId and #itemList > 0 then
                    local msgItem = itemList[#itemList]
                    if msgItem.FromPlayer.Id == myPlayerId then -- 玩家自己发的聊天消息
                        return msgItem.ToPlayer
                    else
                        return msgItem.FromPlayer
                    end
                end
            end
        else
            for _, item in pairs(dataList) do
                if item.FromPlayer.Id == playerId then
                    return item.FromPlayer
                end
            end
        end
    end
end

-- ============================= 私有函数区域 ============================

-- 设置默认的标识信息
--[[
-- 参数
    channelType: 频道Id
    privatePlayerId: 私聊玩家Id，如果是私聊频道，该参数有效
    defMarkInfo: 默认的标识信息，如果没有该参数，该函数体内还会自定一个默认值： {readMaxId = 0, maxId = 0, hadHistory = false, isTop}
]]
function ChatMng:setDefMarkInfo(channelType, privatePlayerId, defMarkInfo)
    local playerId = PlayerAttrObj:getPlayerInfo().PlayerId
    self.mMarkInfo[playerId] = self.mMarkInfo[playerId] or {}
    --
    if channelType == Enums.ChatChanne.ePrivate then -- 私聊频道
        self.mMarkInfo[playerId][channelType] = self.mMarkInfo[playerId][channelType] or {}
        if privatePlayerId then
            local tempInfo = self.mMarkInfo[playerId][channelType]
            defMarkInfo = defMarkInfo or {readMaxId = 0, clearId = 0, maxId = tempInfo.maxId or 0, hadHistory = false, isTop = false}
            tempInfo[privatePlayerId] = tempInfo[privatePlayerId] or defMarkInfo
        end
    else
        defMarkInfo = defMarkInfo or {readMaxId = 0, clearId = 0, maxId = 0, hadHistory = false, isTop = false}
        self.mMarkInfo[playerId][channelType] = self.mMarkInfo[playerId][channelType] or defMarkInfo
    end
end

-- 设置默认的聊天信息
--[[
-- 参数
    channelType: 频道Id
    privatePlayerId: 私聊玩家Id，如果是私聊频道，该参数有效
]]
function ChatMng:setDefChatInfo(channelType, privatePlayerId)
    local playerId = PlayerAttrObj:getPlayerInfo().PlayerId
    --
    self.mChatInfo[playerId] = self.mChatInfo[playerId] or {}
    self.mChatInfo[playerId][channelType] = self.mChatInfo[playerId][channelType] or {}
    if channelType == Enums.ChatChanne.ePrivate and privatePlayerId then -- 私聊频道
        self.mChatInfo[playerId][channelType][privatePlayerId] = self.mChatInfo[playerId][channelType][privatePlayerId] or {}
    end
end

-- 通知游戏服务器聊天服务器连接成功
function ChatMng:requestChatSuccess()
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Player",
        methodName = "ChatSuccess",
        svrMethodData = {},
        needWait = false,
        callback = function(response)
            if not response or response.Status ~= 0 then
                ChatMng:requestChatSuccess()
            end
        end,
    })
end

-- 获取历史记录信息
function ChatMng:getHistoryInfo()
    local tempData = {
        MethodName = "GetHistoryInfo",
        Parameters = {},
    }
    self.mSocketObj:sendMessage(tempData)
end

-- 解析玩家json字符串
--[[
-- 参数
    jsonStr: 玩家信息的json字符串
-- 返回值
    玩家信息的lua表结构
]]
function ChatMng:analysisPlayerJson(jsonStr)
    if not jsonStr or jsonStr == "" then
        return
    end
    local ret = cjson.decode(jsonStr)
    if ret.ExtendInfo then
        ret.ExtendInfo = cjson.decode(ret.ExtendInfo)
    end
    return ret
end

-- 获取频道保留的最大消息数量
function ChatMng:getSaveMaxCount(channelType)
    local tempList = {
        [Enums.ChatChanne.eWorld] = 50,
        [Enums.ChatChanne.eCrossServer] = 50,
        [Enums.ChatChanne.eHorn] = 50,
        [Enums.ChatChanne.eTeam] = 50,
        [Enums.ChatChanne.eUnion] = 50,
        [Enums.ChatChanne.ePrivate] = 50,
        [Enums.ChatChanne.eSystem] = 50,
        [Enums.ChatChanne.eAvatar] = 50,
        [Enums.ChatChanne.eGuide] = 50,
    }

    return tempList[channelType or Enums.ChatChanne.eWorld] or 0
end

-- 处理接收到的数据
--[[
-- 接收到的聊天数据格式为：
    {
        ChannelType: 聊天频道，取值为 Eenums.lua文件Enums.ChatChanne 中的枚举定义
        Message: 消息内容
        FromId:发送消息的玩家的Id
        FromName:发送消息的玩家的名称
        extraMsg:附加信息 如红包等
    }
]]
function ChatMng:dealRecvData(response)
    if response.Code ~= 0 then
        self:dealErrorData(response)
        return
    end

    if response and response.Data then
        if type(response.Data) == "userdata" then
            return
        end
    end

    local methodName = response.MethodName -- 方法名称
    if methodName == "SendMessage" then -- 处理推送消息
        if not response.Data then -- 如果没有数据部分，则不需要处理
            return
        end
        self:responseSendMessage(response.Data)
    elseif methodName == "Login" then -- 登陆聊天服务器
        -- 通知游戏服务器聊天服务器登陆成功
        self:requestChatSuccess()
        -- 获取历史记录信息
        self:getHistoryInfo()
    elseif methodName == "GetHistory" then -- 获取历史消息
        self:responseHistory(response.Data)
    elseif methodName == "GetHistoryInfo" then -- 获取聊天的基本信息
        self:responseHistoryInfo(response.Data)
    elseif methodName == "DeletePrivateHistory" then
        self:responseDeletePrivateHistory(response.Data)
    end
end

-- 处理聊天错误消息
function ChatMng:dealErrorData(response)
    local tempStr = SocketStates.chatCode[response.Code] or TR("未知错误, 错误码(%d)", response.Code)
    if response.MethodName == "Login" then
        tempStr = TR("登陆聊天服务器时，") .. tempStr
    end
    local hintStr = TR("提示:%s", tempStr)

    -- 需要弹出游戏的错误码
    local jumpCode = {
        -- [-11] = true,  -- 玩家被封号 PlayerIsForbidden
        [-18] = true,  -- 在另一台设备上登录 LoginOnAnotherDevice
    }
    if jumpCode[response.Code] or response.MethodName == "Login" then
        -- 删除socket连接对象
        self.mSocketObj:destroy()

        -- 弹出游戏的提示
        local okBtnInfo = {
            text = TR("确定"),
            clickAction = function(layerObj, btnObj)
                -- 通知渠道已登出游戏
                IPlatform:getInstance():logout()
                -- 跳转到登录页面
                LayerManager.addLayer({name = "login.GameLoginLayer", data = {}})
            end,
        }
        LayerManager.addLayer({
            name = "commonLayer.MsgBoxLayer",
            data = {
                title = TR("提示"),
                msgText = hintStr,
                btnInfos = {okBtnInfo},
            },
            zOrder = Enums.ZOrderType.eNetErrorMsg,
            cleanUp = false
        })
    else
        ui.showFlashView(hintStr)
    end
end

-- 处理 Avatar 频道返回的聊天信息
function ChatMng:dealAvatarChatInfo(msgData)
    msgData = msgData or {}
    local playerId = PlayerAttrObj:getPlayerInfo().PlayerId
    self.mAvatarChatInfo[playerId] = self.mAvatarChatInfo[playerId] or {}
    for index, item in ipairs(msgData) do
        local channelType = item.ChannelType
        local maxSaveCount =  self:getSaveMaxCount(channelType)

        self.mAvatarChatInfo[playerId][channelType] = self.mAvatarChatInfo[playerId][channelType] or {}
        local tempList = self.mAvatarChatInfo[playerId][channelType]

        if channelType == Enums.ChatChanne.ePrivate then
            local privatePlayerId = (item.FromPlayer.Id == playerId) and item.ToPlayer.Id or item.FromPlayer.Id
            tempList[privatePlayerId] = tempList[privatePlayerId] or {}

            table.insert(tempList[privatePlayerId], item)
            -- 超过最大条目数后需要删除掉比较早的消息
            if #tempList[privatePlayerId] > maxSaveCount then
                table.remove(tempList[privatePlayerId], 1)
            end
        else
            table.insert(tempList, item)

            -- 超过最大条目数后需要删除掉比较早的消息
            if #tempList > maxSaveCount then
                table.remove(tempList, 1)
            end
        end
    end
end

-- 处理聊天推送消息
function ChatMng:responseSendMessage(msgData)
    local playerId = PlayerAttrObj:getPlayerInfo().PlayerId
    local channelType = msgData.ChannelType
    local maxSaveCount =  self:getSaveMaxCount(channelType)
    if channelType == Enums.ChatChanne.eAvatar then  -- Avatar频道
        local avatarInfo = cjson.decode(msgData.Message)
        -- avatar频道返回的聊天信息  -- todo
        if avatarInfo.ChatInfo then
            self:dealAvatarChatInfo(avatarInfo.ChatInfo)
        end

        Player:updateSocketAvatar(avatarInfo)
    elseif channelType == Enums.ChatChanne.eGM then -- GM频道
        -- 该频道的消息，需要添加到系统频道，并且需要及时通知玩家
        self:setDefChatInfo(channelType)
        local dataList = self.mChatInfo[playerId][channelType]
        msgData.Voice = msgData.Voice ~= "" and msgData.Voice and cjson.decode(msgData.Voice) or {}

        table.insert(dataList, msgData)
        -- 超过最大条目数后需要删除掉比较早的消息
        if #dataList > maxSaveCount then
            table.remove(dataList, 1)
        end

        -- 添加到系统系统频道中
        self:setDefChatInfo(Enums.ChatChanne.eSystem)
        local systemList = self.mChatInfo[playerId][Enums.ChatChanne.eSystem]
        local copyData = clone(msgData)
        -- copyData.InvalidTime = Player:getCurrentTime() + (5 * 60)
        table.insert(systemList, copyData)
        Notification:postNotification(EventsName.eChatMsgChangePrefix .. tostring(Enums.ChatChanne.eSystem))

        -- 还需要在其他频道中显示吗？
        -- todo

        self.mLastRecData = msgData
        -- 通知收到新消息
        Notification:postNotification(EventsName.eChatNewMsg)
    elseif channelType == Enums.ChatChanne.eSystem then -- 系统频道
        self:setDefChatInfo(channelType)
        local dataList = self.mChatInfo[playerId][channelType]

        local temString = cjson.decode(msgData.Message)

        if not temString.Content then
            msgData.Message = temString.Msg
            msgData.ExObj = temString.ExObj
        end
        msgData.Voice = msgData.Voice ~= "" and msgData.Voice and cjson.decode(msgData.Voice) or {}

        if temString.ExObj and temString.ExObj.Type == Enums.ChatSystemType.eOnline then
            -- Notification:postNotification(EventsName.eChatMsgChangePrefix .. tostring(Enums.ChatChanne.eWorld))
            msgData.MessageType = temString.ExObj.Type
            msgData.FromPlayer = temString.ExObj.PlayerInfo
            msgData.Msg = temString.Msg
        elseif temString.ExObj and (temString.ExObj.Type == Enums.ChatSystemType.eWorldRedPack or temString.ExObj.Type == Enums.ChatSystemType.eGuildRedPack) then
            -- 拼装红包聊天消息(转换红包系统消息为普通消息，并标记红包)
            local chatInfo = clone(msgData)
            chatInfo.FromPlayerId = temString.ExObj.FromPlayer.Id
            chatInfo.Voice = ""
            chatInfo.FromPlayer = cjson.encode(temString.ExObj.FromPlayer)
            chatInfo.Message = temString.ExObj.Remark
            chatInfo.ExObj = {Type = temString.ExObj.Type, RedId = temString.ExObj.Id}
            if temString.ExObj.Type == Enums.ChatSystemType.eWorldRedPack then
                chatInfo.ChannelType = Enums.ChatChanne.eWorld
            else
                chatInfo.ChannelType = Enums.ChatChanne.eUnion
            end
            self:responseSendMessage(chatInfo)
            return
        elseif temString.ExObj and temString.ExObj.Type == Enums.ChatSystemType.eJHkInvite then 
            --江湖杀邀请
            local chatInfo = clone(msgData)
            -- chatInfo.FromPlayerId = temString.ExObj.FromPlayer.Id
            chatInfo.Voice = ""
            chatInfo.Message = temString.Msg
            chatInfo.ExObj = {Type = temString.ExObj.Type, TeamId = temString.ExObj.TeamId, ForceId = temString.ExObj.ForceId}
            chatInfo.ChannelType = Enums.ChatChanne.eTeam
            self:responseSendMessage(chatInfo)
            return
        else
            table.insert(dataList, msgData)
        end

        -- 超过最大条目数后需要删除掉比较早的消息
        if #dataList > maxSaveCount then
            table.remove(dataList, 1)
        end
        self.mLastRecData = msgData
        -- dump(msgData, "msgDatamsgData")

        -- 通知收到新消息
        Notification:postNotification(EventsName.eChatNewMsg)
    else  -- 其他频道的消息
        local tempData = {}
        for key, value in pairs(msgData or {}) do
            if key == "FromPlayer" or key == "ToPlayer" then
                tempData[key] = self:analysisPlayerJson(value)
            elseif key == "Voice" then
                tempData[key] = value ~= "" and value and cjson.decode(value) or {}
            else
                tempData[key] = value
            end
        end
        -- 判断消息是否在同一个群组
        if tempData.FromPlayer and tempData.FromPlayer.PartnerId and self:_isPIdNeedShield(tempData.FromPlayer.PartnerId) then
            return
        end
        self.mLastRecData = tempData

        if channelType == Enums.ChatChanne.ePrivate then
            local privatePlayerId = (tempData.FromPlayer.Id == playerId) and tempData.ToPlayer.Id or tempData.FromPlayer.Id
            self:setDefChatInfo(channelType, privatePlayerId)
            local dataList = self.mChatInfo[playerId][channelType][privatePlayerId]

            -- 设置默认的标识信息
            self:addPrivateId(privatePlayerId)

            table.insert(dataList, tempData)
            self:setMsgMaxId(channelType, tempData.Id, privatePlayerId)

            -- 超过最大条目数后需要删除掉比较早的消息
            if #dataList > maxSaveCount then
                table.remove(dataList, 1)
                self:setReadMsgId(channelType, dataList[1].Id - 1, privatePlayerId)
            end
            -- 通知收到新消息
            Notification:postNotification(privatePlayerId, tempData)
        else
            self:setDefChatInfo(channelType)
            local dataList = self.mChatInfo[playerId][channelType]

            table.insert(dataList, tempData)
            -- 如果当前频道之前没有未读条目，需要判断该玩家是否被屏蔽
            if self:getUnreadCount(channelType) == 0 then
                self:setMsgMaxId(channelType, tempData.Id)
                if tempData.FromPlayer and EnemyObj:isEnemyPlayer(tempData.FromPlayer.Id) then
                    self:setReadMsgId(channelType, tempData.Id)
                end
            else
                self:setMsgMaxId(channelType, tempData.Id)
            end

            -- 超过最大条目数后需要删除掉比较早的消息
            if #dataList > maxSaveCount then
                table.remove(dataList, 1)
                self:setReadMsgId(channelType, dataList[1].Id - 1)
            end

            if channelType == Enums.ChatChanne.eHorn then -- 跨服走马灯频道
                -- 被屏蔽的玩家小喇叭信息不显示
                if not EnemyObj:isEnemyPlayer(tempData.FromPlayer.Id) then
                    local fromPlayer = tempData.FromPlayer or {}
                    local extInfo = fromPlayer.ExtendInfo or {}
                    local tempStr = string.format("#44AC06[%s] %s: #49381F%s", fromPlayer.ServerName, extInfo.Name, tempData.Message)
                    local tempItem = {
                        TemplateName = "CrossServerMarquee",
                        Weight = 1,
                        AriseNum = 1,
                        StarTime = Player:getCurrentTime(),
                        EndTime = Player:getCurrentTime() + 60 * 10, -- 十分钟
                        Content = {
                            {
                                ResourceTypeSub = 0,
                                Count = 0,
                                Value = tempStr,
                            }
                        },
                    }

                    MarqueeObj:updateMarquee({tempItem})
                end

                -- 喇叭频道不需要小红点
                self:setReadMsgId(channelType, tempData.Id)
            end
        end

        -- 通知收到新消息
        Notification:postNotification(EventsName.eChatNewMsg)
    end
end

-- 处理聊天历史消息
function ChatMng:responseHistory(msgData)
    if not next(msgData or {}) then
        return
    end
    local playerId = PlayerAttrObj:getPlayerInfo().PlayerId
    local channelType = msgData[1].ChannelType

    -- 该历史消息的频道消息
    self.mChatInfo[playerId] = self.mChatInfo[playerId] or {}
    self.mChatInfo[playerId][channelType] = self.mChatInfo[playerId][channelType] or {}

    if channelType == Enums.ChatChanne.ePrivate then
        -- 判断消息是否在同一个群组
        local fromPlayerTable = msgData[1].FromPlayer and self:analysisPlayerJson(msgData[1].FromPlayer)
        if fromPlayerTable and self:_isPIdNeedShield(fromPlayerTable.PartnerId) then
            return
        end
        -- 该频道缓存消息中已有的消息Id
        local msgIdList = {}

        local channelData = self.mChatInfo[playerId][channelType]
        for _, itemList in pairs(channelData) do
            for _, item in pairs(itemList) do
                if item.Id then
                    msgIdList[item.Id] = true
                end
            end
        end

        local haveAddList = {}
        for _, item in pairs(msgData or {}) do
            if not msgIdList[item.Id] then -- 缓存数据中没有该条目
                local tempData = {
                    Id = item.Id,
                    ChannelType = item.ChannelType,
                    Message = item.Message,
                    TimeStamp = item.TimeStamp,
                    FromPlayerId = item.FromPlayerId,
                    FromPlayer = self:analysisPlayerJson(item.FromPlayer),
                    ToPlayerId = item.ToPlayerId,
                    ToPlayer = self:analysisPlayerJson(item.ToPlayer),
                    Voice = item.Voice ~= "" and item.Voice and cjson.decode(item.Voice) or {}
                }

                local privatePlayerId = (tempData.FromPlayer.Id == playerId) and tempData.ToPlayer.Id or tempData.FromPlayer.Id
                self:setDefChatInfo(channelType, privatePlayerId)
                table.insert(self.mChatInfo[playerId][channelType][privatePlayerId], 1, tempData)

                haveAddList[privatePlayerId] = true
            end
        end

        -- 对有添加的私聊信息进行排序
        for privateId, _ in pairs(haveAddList) do
            local msgList = self.mChatInfo[playerId][channelType][privateId]

            table.sort(msgList, function(item1, item2)
                if item1.Id ~= item2.Id then
                    return item1.Id < item2.Id
                end

                return item1.TimeStamp < item2.TimeStamp
            end)

            -- 超过最大条目数后需要删除掉比较早的消息
            local maxSaveCount =  self:getSaveMaxCount(channelType)
            if #msgList > maxSaveCount then
                for index = 1, #msgList - maxSaveCount do
                    table.remove(msgList, 1)
                end
                self:setReadMsgId(channelType, msgList[1].Id - 1, privateId)
            end

            Notification:postNotification(EventsName.eChatMsgChangePrefix .. tostring(channelType) .. privateId)
        end

        -- 通知收到新消息
        if next(haveAddList) then
            Notification:postNotification(EventsName.eChatMsgChangePrefix .. tostring(channelType))
        end
    else
        -- 该频道缓存消息中已有的消息Id
        local msgIdList = {}
        local msgList = self.mChatInfo[playerId][channelType]
        for _, item in pairs(msgList) do
            if item.Id then
                msgIdList[item.Id] = true
            end
        end

        -- 把历史消息添加到该频道的缓存消息中
        local haveAdd = false
        for _, item in pairs(msgData or {}) do
            if not msgIdList[item.Id] then -- 缓存数据中没有该条目
                -- 判断消息是否在同一个群组
                local fromPlayerTable = item.FromPlayer and self:analysisPlayerJson(item.FromPlayer)
                if not (fromPlayerTable and self:_isPIdNeedShield(fromPlayerTable.PartnerId)) then
                    local tempData = {
                        Id = item.Id,
                        ChannelType = item.ChannelType,
                        Message = item.Message,
                        TimeStamp = item.TimeStamp,
                        FromPlayerId = item.FromPlayerId,
                        FromPlayer = fromPlayerTable,
                        ToPlayerId = item.ToPlayerId,
                        ToPlayer = self:analysisPlayerJson(item.ToPlayer),
                        Voice = item.Voice ~= "" and item.Voice and cjson.decode(item.Voice) or {}
                    }
                    table.insert(msgList, 1, tempData)
                    haveAdd = true
                end
            end
        end

        -- 如果添加了历史条目，需要对缓存数据重新排序
        if haveAdd then
            table.sort(msgList, function(item1, item2)
                if item1.Id ~= item2.Id then
                    return item1.Id < item2.Id
                end

                return item1.TimeStamp < item2.TimeStamp
            end)

            -- 超过最大条目数后需要删除掉比较早的消息
            local maxSaveCount =  self:getSaveMaxCount(channelType)
            if #msgList > maxSaveCount then
                for index = 1, #msgList - maxSaveCount do
                    table.remove(msgList, 1)
                end
                self:setReadMsgId(channelType, msgList[1].Id - 1)
            end

            -- 通知收到新消息
            Notification:postNotification(EventsName.eChatMsgChangePrefix .. tostring(channelType))
        end
    end
end

-- 处理聊天的基本信息
function ChatMng:responseHistoryInfo(historyInfo)
    -- 频道名称与频道Id对应表
    local channeMap = {
        World = Enums.ChatChanne.eWorld,
        CrossServer = Enums.ChatChanne.eCrossServer,
        Union = Enums.ChatChanne.eUnion,
        Private = Enums.ChatChanne.ePrivate,
        Team = Enums.ChatChanne.eTeam,
    }

    historyInfo = historyInfo or {}
    local playerId = PlayerAttrObj:getPlayerInfo().PlayerId

    self.mMarkInfo[playerId] = self.mMarkInfo[playerId] or {}
    local localData = LocalData:getReadMaxInfo(playerId) or {}
    for channeName, channeId in pairs(channeMap) do
        self.mMarkInfo[playerId][channeId] = self.mMarkInfo[playerId][channeId] or {}
        if channeId == Enums.ChatChanne.ePrivate then
            local tempInfo = historyInfo[channeName]
            for key, value in pairs(type(tempInfo) == "table" and tempInfo or {}) do
                -- 判断玩家是否在同一个群组
                if not self:_isPIdNeedShield(value.PartnerId) then
                    self.mMarkInfo[playerId][channeId][key] = self.mMarkInfo[playerId][channeId][key] or {}
                    local tempMark = self.mMarkInfo[playerId][channeId][key]
                    tempMark.maxId = value.Id
                    tempMark.readMaxId = localData[channeId] and localData[channeId][key] and localData[channeId][key].readMaxId or 0
                    tempMark.clearId = localData[channeId] and localData[channeId][key] and localData[channeId][key].clearId or 0
                    tempMark.isTop = localData[channeId] and localData[channeId][key] and localData[channeId][key].isTop

                    -- 获取该私聊的历史数据
                    self:getNextHistory(Enums.ChatChanne.ePrivate, key)
                end
            end
        else
            local tempMark = self.mMarkInfo[playerId][channeId]
            tempMark.maxId = historyInfo[channeName] or 0
            tempMark.readMaxId = localData[channeId] and localData[channeId].readMaxId or 0
            tempMark.clearId = localData[channeId] and localData[channeId].clearId or 0
            tempMark.isTop = localData[channeId] and localData[channeId].isTop
        end
    end

    -- 消息通知聊天标识信息修改
    Notification:postNotification(EventsName.eChatUnreadPrefix)
end

-- 处理删除私聊信息
function ChatMng:responseDeletePrivateHistory(deletePlayerId)
    if not deletePlayerId or deletePlayerId == "" then
        return
    end
    local channelType = Enums.ChatChanne.ePrivate
    local playerId = PlayerAttrObj:getPlayerInfo().PlayerId

    -- 删除缓存中该玩家的私聊信息
    if self.mChatInfo[playerId] and self.mChatInfo[playerId][channelType] then
        self.mChatInfo[playerId][channelType][deletePlayerId] = nil
    end

    -- 删除缓存中该玩家的私聊标识信息
    if self.mMarkInfo[playerId] or self.mMarkInfo[playerId][Enums.ChatChanne.ePrivate] then
        self.mMarkInfo[playerId][channelType][deletePlayerId] = nil
    end

    -- 删除本地文件中该条信息
    local saveData = LocalData:getReadMaxInfo(playerId) or {}
    if saveData[channelType] then
        saveData[channelType][deletePlayerId] = nil
    end
    LocalData:saveReadMaxInfo(playerId, saveData)

    -- 消息通知私聊玩家列表改变
    Notification:postNotification(EventsName.eChatPrivateChanged)
end

--清除组队聊天的缓存
function ChatMng:deleteTeamChatInfo()
    local playerId = PlayerAttrObj:getPlayerAttrByName("PlayerId")
    if self.mChatInfo[playerId] then
        self.mChatInfo[playerId][Enums.ChatChanne.eTeam] = {}
        if self.mMarkInfo[playerId][Enums.ChatChanne.eTeam] and self.mMarkInfo[playerId][Enums.ChatChanne.eTeam].maxId then
            self.mMarkInfo[playerId][Enums.ChatChanne.eTeam].maxId = 0
        end
    end

    Notification:postNotification(EventsName.eChatUnreadPrefix .. tostring(Enums.ChatChanne.eTeam))
end