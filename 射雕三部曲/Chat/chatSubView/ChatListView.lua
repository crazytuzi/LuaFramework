--[[
文件名: ChatListView.lua
描述: 显示聊天信息的列表控件
创建人: liaoyuangang
创建时间: 2017.06.14
-- ]]

local ChatListView = class("ChatListView", function(params)
    return display.newLayer()
end)

-- 频道标签背景图列表
local ChanneBgImage = {
    [Enums.ChatChanne.eWorld] = "lt_14.png",
    [Enums.ChatChanne.eCrossServer] = "lt_14.png",
    [Enums.ChatChanne.eHorn] = "lt_14.png",
    [Enums.ChatChanne.eTeam] = "lt_14.png",
    [Enums.ChatChanne.eUnion] = "lt_14.png",
    [Enums.ChatChanne.eSystem] = "lt_14.png",
    [Enums.ChatChanne.ePrivate] = "lt_14.png",  -- Todo
    [Enums.ChatChanne.eAvatar] = "lt_14.png",  -- Todo
}

-- 公会职位标签背景图列表
local UnionPostBgImgae = {
    [34001001] = "lt_32.png", -- 会长
    [34001002] = "lt_33.png", -- 副会长
    [34001003] = "lt_34.png", -- 精英
    [34001004] = "lt_15.png", -- 成员
}

-- 帮派职位标签背景图列表
local guidePostBgImgae = {
    [0] = "lt_32.png",  -- 师尊
    [1] = "lt_33.png",  -- 大徒弟
    [2] = "lt_34.png",  -- 二徒弟
    [3] = "lt_15.png",  -- 三徒弟
    [4] = "lt_15.png",  -- 小徒弟
}

-- 帮派职位名称列表
local guideNameList = {
    [0] = TR("师尊"),
    [1] = TR("大徒弟"),
    [2] = TR("二徒弟"),
    [3] = TR("三徒弟"),
    [4] = TR("小徒弟"),
}

--[[
-- 参数
	params 中的各项为：
	{
		viewSize: 显示区域的大小
		forbidCleanUp: 是否禁止该页面跳转到其他页面时LayerManager.addLayer函数的cleanUp参数为true, 默认为false
		onGetNextHistory: 获取更多历史消息的回调, onGetNextHistory()
		privateCb: 创建私聊的回调函数, privateCb(selectLayerObj, selectPlayerId)
		chatChanne:频道
	}
]]
function ChatListView:ctor(params)
	params = params or {}
	-- 显示区域的大小
	self.mViewSize = params.viewSize
--	self.mForbidCleanUp = params.forbidCleanUp (有bug)

    local _, _, eventID = Guide.manager:getGuideInfo()
    local layerName = LayerManager.getTopCleanLayerName()
    if ChatForbidCleanUpList[layerName] or eventID then
        self.mForbidCleanUp = true
    end

	-- 获取更多历史消息的回调
	self.onGetNextHistory = params.onGetNextHistory
	-- 创建私聊的回调函数
	self.privateCb = params.privateCb
    --频道
    self.mChatChanne = params.chatChanne

    -- 聊天消息数据列表
    self.mMsgDataList = {}

	self:setIgnoreAnchorPointForPosition(false)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self.mViewSize)

    -- 初始化页面控件
    self:initUI()
end

-- 初始化页面控件
function ChatListView:initUI()
	-- 聊天列表
    self.mListView = ccui.ListView:create()
    self.mListView:setContentSize(self.mViewSize)
    self.mListView:setItemsMargin(5)
    self.mListView:setBounceEnabled(true)
    self.mListView:setAnchorPoint(cc.p(0.5, 0.5))
    self.mListView:setPosition(self.mViewSize.width / 2, self.mViewSize.height / 2)
    self:addChild(self.mListView)

    --listview添加监听
    if self.onGetNextHistory then
	    local triggerTime
	    self.mListView:addScrollViewEventListener(function(sender, eventType)
	        if eventType == ccui.ScrollviewEventType.scrollToTop then
	            local currTime = Player:getCurrentTime()
	            if not triggerTime or currTime - triggerTime > 3 then
	                triggerTime = currTime

	                -- 通知获取更多历史消息
	                self.onGetNextHistory()
	            end
	        end
	    end)
    end
end

-- 刷新列表中的所有消息
--[[
-- 参数
	msgDataList: 消息数据列表
	jumpToBottom: 刷新后是否需要跳转到列表最下面, 默认为 false
]]
function ChatListView:refreshMsgListView(msgDataList, jumpToBottom)
    self.mMsgDataList = msgDataList or {}
    --
	local oldInnerSize = self.mListView:getInnerContainerSize()
    local oldInnerPos = cc.p(self.mListView:getInnerContainerPosition())

    self.mListView:stopAllActions()
	self.mListView:removeAllItems()
    local createIndex = 1
    self.mListView:runAction(cc.Repeat:create(cc.Sequence:create({
        cc.CallFunc:create(function()
            local tempItem = msgDataList[createIndex]
            if tempItem then
                if tempItem.ChannelType == Enums.ChatChanne.eHorn then
                    self:createMarqueeChatItem(tempItem)
                else
                    self:createChatItem(tempItem)
                end
            end
            if createIndex == #msgDataList then -- 创建最后一条
                if jumpToBottom then
                    self.mListView:jumpToBottom()
                else
                    ui:restoreListViewPos(self.mListView, oldInnerSize, oldInnerPos)
                end
            end
            createIndex = createIndex + 1
        end),
        cc.DelayTime:create(0.01),
    }), #msgDataList))
end

-- 添加一条消息
--[[
-- 参数
	msgItemData: 需要添加到消息数据
	needRestorePos: 添加消息后是否需要恢复列表原来的位置, 默认为false
]]
function ChatListView:addOneMsgItem(msgItemData, needRestorePos)
    --
    table.insert(self.mMsgDataList, msgItemData)

	local oldInnerSize, oldInnerPos
	if needRestorePos then
		oldInnerSize = self.mListView:getInnerContainerSize()
    	oldInnerPos = cc.p(self.mListView:getInnerContainerPosition())
	end

    if msgItemData.ChannelType == Enums.ChatChanne.eHorn then
        self:createMarqueeChatItem(msgItemData)
    else
        self:createChatItem(msgItemData)
    end

	if needRestorePos then
		ui:restoreListViewPos(self.mListView, oldInnerSize, oldInnerPos)
	end
end

-- 跳转到列表的最下面
function ChatListView:jumpToBottom()
	self.mListView:jumpToBottom()
end

-- ========================= 私有函数区域 ==========================

-- 创建聊天信息纪录的一个条目
--[[
-- 参数
    cellInfo: 聊天数据
]]
function ChatListView:createChatItem(cellInfo)
	-- 判断是否是黑名单玩家对消息
    if not cellInfo or self:isEnemyMsg(cellInfo) then
        return
    end
    if cellInfo.ExObj and cellInfo.ExObj.Type == Enums.ChatSystemType.eJHkInvite then
        local playerForceId = PlayerAttrObj:getPlayerAttrByName("JianghuKillForceId")
        if cellInfo.ExObj.ForceId ~= playerForceId then
            return
        end 
    end

    -- 容错处理
    if cellInfo.Voice and type(cellInfo.Voice) == "string" then
        cellInfo.Voice = cellInfo.Voice ~= "" and cjson.decode(cellInfo.Voice) or {}
    end

    -- 判断是否有过期时间
    local invalidTime = nil
    if cellInfo.InvalidTime and cellInfo.InvalidTime > 0 then
        invalidTime = cellInfo.InvalidTime - Player:getCurrentTime()
    end
    if invalidTime and invalidTime <= 0 then
        return
    end

    -- 是否是玩家自己发的消息
    local isSelf = cellInfo.FromPlayer and cellInfo.FromPlayer.Id == PlayerAttrObj:getPlayerInfo().PlayerId
    -- 发送玩家和接收玩家的信息
    local fromExt = cellInfo.FromPlayer and cellInfo.FromPlayer.ExtendInfo
    -- 是否是系统消息
    local isSystem = cellInfo.ChannelType == Enums.ChatChanne.eSystem or cellInfo.ChannelType == Enums.ChatChanne.eGM
    -- 是否是赛马战场系统消息
    local isGodDomain = (cellInfo.ChannelType == Enums.ChatChanne.eGodDomain) and (cellInfo.Type == 2)
    -- 是否有语音消息
    local haveVoice = next(cellInfo.Voice or {}) ~= nil
    local voiceViewWidth = haveVoice and (cellInfo.Voice.Seconds * 14) or 0
    voiceViewWidth = math.max(63, math.min(voiceViewWidth, self.mViewSize.width - 200))

    -- 聊天内容显示的最大宽度
    local msgMaxWidth = (isSystem or isGodDomain) and (self.mViewSize.width - 30) or (self.mViewSize.width - 180)

    -- 聊天内容label
    local msgLabel = self:createMsgLabel(cellInfo, msgMaxWidth)
    -- 聊天内容的显示大小
    local msgViewSize = msgLabel:getContentSize()
    -- 如果有语音信息
    msgViewSize.height = math.max(msgViewSize.height, 24) + 42
    msgViewSize.width = math.max(180, msgViewSize.width)
    if haveVoice then
        msgViewSize.height = msgViewSize.height + 40
        msgViewSize.width = math.max(msgViewSize.width, voiceViewWidth + 40)
    end

    -- 聊天条目的高度 根据显示内容的显示高度获得
    local cellHeight = msgViewSize.height + 35
    if not (isSystem or isGodDomain) then
        cellHeight = cellHeight + 30
    end

    -- 该聊天条目的parent
    local cellNode = ccui.Widget:create()
    cellNode:setContentSize(cc.size(self.mViewSize.width, cellHeight))
    self.mListView:pushBackCustomItem(cellNode)

    -- 如果该条消息有过期时间，则需要定时清空该条数据
    if invalidTime then
        Utility.performWithDelay(cellNode, function()
            local oldInnerSize = self.mListView:getInnerContainerSize()
            local oldInnerPos = cc.p(self.mListView:getInnerContainerPosition())
            local itemIndex = self.mListView:getIndex(cellNode)
            self.mListView:removeItem(itemIndex)
            ui:restoreListViewPos(self.mListView, oldInnerSize, oldInnerPos)
        end, invalidTime)
    end

    -- 聊天记录的时间
    local timeLabel = ui.newLabel({
        text = MqTime.getTimeViewStr(cellInfo.TimeStamp),
        size = 18,
        color = cc.c3b(0x8d, 0x5d, 0x3d),
    })
    cellNode:addChild(timeLabel)

    if isSystem or isGodDomain then  -- 系统消息或则赛马战场资源状态信息
        local msgAnchor = cc.p(0.5, 0)
        local cellBgSize = cc.size(msgMaxWidth + 12, msgViewSize.height)
        local cellBgSprite = ui.newScale9Sprite("lt_18.png", cellBgSize)
        cellBgSprite:setAnchorPoint(msgAnchor)
        cellBgSprite:setPosition(self.mViewSize.width / 2, 20)
        cellNode:addChild(cellBgSprite)

        -- 条目的按钮控件
        local tempBtn = ui.newButton({
            normalImage = "c_83.png",
            size = cellBgSize,
            clickAction = function()
                self:onMsgListSystemClick(cellInfo, cellBgSprite, cellBgSize)
            end
        })
        tempBtn:setAnchorPoint(msgAnchor)
        tempBtn:setPosition(cellBgSprite:getPosition())
        cellNode:addChild(tempBtn)

        -- 设置聊天内容parent 和位置
        cellBgSprite:addChild(msgLabel)

        msgLabel:setAnchorPoint(cc.p(0, 0.5))
        msgLabel:setPosition((cellBgSize.width - msgMaxWidth) / 2, cellBgSize.height / 2)

        -- 设置是时间的位置
        timeLabel:setAnchorPoint(cc.p(1, 0))
        timeLabel:setPosition((self.mViewSize.width + cellBgSize.width) / 2, 0)

        if cellInfo.IsRushThisRedPacket then
            local sprite = ui.newSprite("lt_15.png")
            sprite:setPosition(cc.p(cellBgSize.width * 0.9, cellBgSize.height * 0.5))
            cellBgSprite:addChild(sprite, 1)
        end
    else
        local msgAnchor = cc.p(isSelf and 1 or 0, 1)
        local msgPosX = isSelf and (self.mViewSize.width - 90) or 90

        local cellBgSize = cc.size(msgViewSize.width + 40, msgViewSize.height)
        local cellBgImage = isSelf and "lt_12.png" or "lt_11.png"
        -- 红包的背景特殊处理
        if cellInfo.ExObj and (cellInfo.ExObj.Type == Enums.ChatSystemType.eWorldRedPack or cellInfo.ExObj.Type == Enums.ChatSystemType.eGuildRedPack) then
            cellBgImage = isSelf and "xn_84.png" or "xn_86.png"
        end
        local cellBgSprite = ui.newScale9Sprite(cellBgImage, cellBgSize)
        cellBgSprite:setAnchorPoint(msgAnchor)
        cellBgSprite:setPosition(msgPosX, cellHeight - 40)
        cellNode:addChild(cellBgSprite)

        -- 创建语音消息信息
        if haveVoice then
            local voiceIdMd5 = string.md5Content(cellInfo.Voice.VoiceId)
            -- 语音播放的喇叭
            local trumpetSprite = self:createVoiceTrumpet(cellInfo.Voice.VoiceId)
            trumpetSprite:setPosition(isSelf and (cellBgSize.width - 35) or 35, cellBgSize.height - 35)
            trumpetSprite:setScaleX(isSelf and 1 or -1)
            cellBgSprite:addChild(trumpetSprite)

            -- 喇叭的状态
            Notification:registerAutoObserver(trumpetSprite, function( ... )
                trumpetSprite:stopPlay()
            end, {EventsName.eVoiceStopPlay, EventsName.eVoicePlayEndPrefix .. voiceIdMd5})
            Notification:registerAutoObserver(trumpetSprite, function( ... )
                trumpetSprite:startPlay()
            end, {EventsName.eVoiceStopPlay, EventsName.eVoicePlayBeginPrefix .. voiceIdMd5})

            -- 语音时长的
            local voiceSprite = ui.createSpriteAndLabel({
                imgName = "lt_44.png",
                scale9Size = cc.size(voiceViewWidth, 30),
                labelStr = TR("%d秒", cellInfo.Voice.Seconds),
                fontSize = 22,
                fontColor = Enums.Color.eBlack,
            })
            voiceSprite:setAnchorPoint(cc.p(isSelf and 1 or 0, 0.5))
            voiceSprite:setPosition(isSelf and (cellBgSize.width - 60) or 60, cellBgSize.height - 35)
            cellBgSprite:addChild(voiceSprite)

            -- 语音是否已播放的小红点
            local function dealRedDotVisible(nodeObj)
                if VoiceMsgTaskObj:isSupportVoice() then
                    local isPlayed = CloudVoiceMng:voiceIsPlayedById(cellInfo.Voice.VoiceId)
                    nodeObj:setVisible(not isSelf and isPlayed ~= true)
                else
                    nodeObj:setVisible(false)
                end
            end
            local tempSprite = ui.createBubble({
                position = cc.p(isSelf and 3 or voiceViewWidth - 3, 28)
            })
            voiceSprite:addChild(tempSprite)
            Notification:registerAutoObserver(tempSprite, dealRedDotVisible, {EventsName.eVoiceIsPlayedPrefix .. voiceIdMd5})
            dealRedDotVisible(tempSprite)
        end

        -- 条目的按钮控件
        local tempBtn = ui.newButton({
            normalImage = "c_83.png",
            size = cellBgSize,
            clickAction = function()
            	self:onMsgListChatClick(cellInfo, cellBgSprite, cellBgSize)
            end
        })
        tempBtn:setAnchorPoint(msgAnchor)
        tempBtn:setPosition(cellBgSprite:getPosition())
        cellNode:addChild(tempBtn)

        -- 设置聊天内容parent 和位置
        cellBgSprite:addChild(msgLabel)
        msgLabel:setAnchorPoint(cc.p(isSelf and 1 or 0, 0.5))
        msgLabel:setPosition(isSelf and (cellBgSize.width - 20) or 20, (haveVoice and cellBgSize.height - 40 or cellBgSize.height) / 2)

        -- 设置是时间的位置
        timeLabel:setAnchorPoint(cc.p(isSelf and 0 or 1, 0))
        local tempWidth = 91 + cellBgSize.width
        timeLabel:setPosition(isSelf and (self.mViewSize.width - tempWidth) or tempWidth, 0)

        
        if cellInfo.ExObj and cellInfo.ExObj.Type == Enums.ChatSystemType.eJHkInvite then
            -- 创建特殊江湖杀系统头像
            local headCard = CardNode:create({})
            headCard:setEmpty({}, "c_04.png", "jhs_137.png")
            headCard:setAnchorPoint(cc.p(0, 1))
            headCard:setPosition(10, cellHeight - 20)
            headCard:setScale(0.8)
            cellNode:addChild(headCard)
        else
            -- 创建头像
            local headCard = CardNode:create({
                onClickCallback = function()
                	self:showPlayerInfo(cellInfo)
                end
            })
            -- 幻化或者hero的modelId是一个字段
            local headType = math.floor(fromExt.HeadImageId / 10000)
            if Utility.isIllusion(headType) then 
                headCard:setIllusion({ModelId = fromExt.HeadImageId, FashionModelID = fromExt.FashionModelId, pvpInterLv = fromExt.DesignationId}, {CardShowAttr.eBorder}, "", fromExt.FashionModelId, fromExt.DesignationId)
            else 
                headCard:setHero({ModelId = fromExt.HeadImageId, FashionModelID = fromExt.FashionModelId, pvpInterLv = fromExt.DesignationId}, {CardShowAttr.eBorder}, "", fromExt.FashionModelId, fromExt.DesignationId)
            end 
            headCard:setAnchorPoint(cc.p(isSelf and 1 or 0, 1))
            headCard:setPosition(isSelf and self.mViewSize.width - 10 or 10, cellHeight - 10)
            headCard:setScale(0.8)
            cellNode:addChild(headCard)

            -- 创建玩家信息（聊天类型，所在公会，玩家名，会员等级）
            local infoLabel = self:createPlayerInfoLabel(cellInfo, isSelf)
            infoLabel:setAnchorPoint(msgAnchor)
            infoLabel:setPosition(isSelf and msgPosX-7 or msgPosX+7, cellHeight - 10)
            cellNode:addChild(infoLabel)
        end
    end
end

-- 创建喇叭信息条目
function ChatListView:createMarqueeChatItem(cellInfo)
    -- 判断是否是黑名单玩家对消息
    if not cellInfo or self:isEnemyMsg(cellInfo) then
        return
    end

    -- 发送玩家和接收玩家的信息
    local fromExt = cellInfo.FromPlayer and cellInfo.FromPlayer.ExtendInfo

    -- 聊天内容显示的最大宽度
    local msgMaxWidth = self.mViewSize.width - 40
    -- 聊天内容label
    local msgLabel = self:createMsgLabel(cellInfo, msgMaxWidth)

    -- 聊天内容的显示大小
    local msgViewSize = msgLabel:getContentSize()

    -- 如果有语音信息
    msgViewSize.height = math.max(msgViewSize.height, 75)
    msgViewSize.width = math.max(180, msgViewSize.width)

    -- 条目显示区域的大小
    local cellSize = cc.size(self.mViewSize.width, msgViewSize.height + 149)

    -- 该聊天条目的parent
    local cellNode = ccui.Widget:create()
    cellNode:setContentSize(cellSize)
    self.mListView:pushBackCustomItem(cellNode)

    -- 创建条目的背景
    local cellBgSize = cc.size(cellSize.width - 18, cellSize.height)
    local cellBgSprite = ui.newScale9Sprite("lt_29.png", cellBgSize)
    cellBgSprite:setPosition(cellSize.width / 2, cellSize.height / 2)
    cellNode:addChild(cellBgSprite)

    -- 聊天内容的位置
    cellBgSprite:addChild(msgLabel)
    msgLabel:setAnchorPoint(cc.p(0, 0.5))
    msgLabel:setPosition(20, 36 + msgViewSize.height / 2)

    -- 聊天记录的时间
    local timeLabel = ui.newLabel({
        text = MqTime.getTimeViewStr(cellInfo.TimeStamp),
        size = 18,
        color = cc.c3b(0x8d, 0x5d, 0x3d),
    })
    timeLabel:setAnchorPoint(cc.p(1, 0))
    timeLabel:setPosition(cellBgSize.width - 20, 13)
    cellBgSprite:addChild(timeLabel)

    -- 创建头像
    local headCard = CardNode:create({
        onClickCallback = function()
            self:showPlayerInfo(cellInfo)
        end
    })
    -- 幻化或者hero的modelId是一个字段
    local headType = math.floor(fromExt.HeadImageId / 10000)
    if Utility.isIllusion(headType) then 
        headCard:setIllusion({ModelId = fromExt.HeadImageId, FashionModelID = fromExt.FashionModelId, pvpInterLv = fromExt.DesignationId}, {CardShowAttr.eBorder}, "", fromExt.FashionModelId, fromExt.DesignationId)
    else 
        headCard:setHero({ModelId = fromExt.HeadImageId, FashionModelID = fromExt.FashionModelId, pvpInterLv = fromExt.DesignationId}, {CardShowAttr.eBorder}, "", fromExt.FashionModelId, fromExt.DesignationId)
    end
    headCard:setPosition(70, cellSize.height - 60)
    headCard:setScale(0.8)
    cellBgSprite:addChild(headCard)

    -- 玩家名+VIP
    local nameVipLabel = self:createPlayerInfoLabel(cellInfo)
    nameVipLabel:setAnchorPoint(cc.p(0, 0.5))
    nameVipLabel:setPosition(130, cellSize.height - 30)
    cellBgSprite:addChild(nameVipLabel)

    -- 帮派
    local tempStr = fromExt.GuildName ~= "" and fromExt.GuildName or TR("暂无帮派")
    local unionLabel = ui.newLabel({
        text = TR("帮派: %s%s", Enums.Color.eGreenH, tempStr),
        color = cc.c3b(0x46, 0x22, 0x0d),
        size = 20,
    })
    unionLabel:setAnchorPoint(cc.p(0, 0.5))
    unionLabel:setPosition(130, cellSize.height - 60)
    cellBgSprite:addChild(unionLabel)

    -- 服务器
    local serverLabel = ui.newLabel({
        text = TR("来自 %s[%s]%s 服的小喇叭", Enums.Color.eGreenH, cellInfo.FromPlayer.ServerName, Enums.Color.eLabelTextH),
        color = cc.c3b(0x46, 0x22, 0x0d),
        size = 20,
    })
    serverLabel:setAnchorPoint(cc.p(0, 0.5))
    serverLabel:setPosition(130, cellSize.height - 90)
    cellBgSprite:addChild(serverLabel)
end

-- 创建显示聊天消息内容的lable
function ChatListView:createMsgLabel(msgInfo, msgMaxWidth)
	-- 是否是系统消息
    local isSystem = msgInfo.ChannelType == Enums.ChatChanne.eSystem or msgInfo.ChannelType == Enums.ChatChanne.eGM
    -- 是否是赛马战场系统消息
    local isGodDomain = msgInfo.ChannelType == Enums.ChatChanne.eGodDomain and msgInfo.Type == 2

	local msgStr = msgInfo.Message
    --找到 msg里面的特殊信息 删除最后一个#,
    local msgLen = msgStr:len()
    if msgStr:byte(msgLen) == string.byte('#') then
        msgStr = msgStr:sub(1, msgLen - 1)
    end

    -- 聊天内容label
    local retLabel = ui.newLabel({
        text = ChatMng:faceStrUnpack((isSystem or isGodDomain) and (" " .. msgStr) or msgStr),  -- 显示的内容
        size = 22,
        color = cc.c3b(0x46, 0x22, 0x0d),
    })
    retLabel:setImageElementScale(0.3)
    if isSystem or isGodDomain then
        -- 在消息前添加“系统消息或组队消息的标识”
        retLabel:insertElement(function()
            local tempSprite = ui.createSpriteAndLabel({
            	imgName = ChanneBgImage[msgInfo.ChannelType] or "lt_14.png",
                labelStr = "",
                scale9Size = isGodDomain and cc.size(85, 29) or nil,
                fontSize = 18,
                outlineColor = Enums.Color.eOutlineColor,
                alignType = ui.TEXT_ALIGN_CENTER,
            })
            return tempSprite
        end, 0)
    end
    -- 如果单行显示宽度大于最大宽度，则需要设置label的最大显示宽度
    local tempSize = retLabel:getContentSize()
    if tempSize.width > msgMaxWidth then
        retLabel:setContentSize(cc.size(msgMaxWidth, 0))
    end

    return retLabel
end

-- 创建语音消息的喇叭
function ChatListView:createVoiceTrumpet(voiceId)
    local retSprite = ui.newSprite("lt_43.png")

    local imageList = {
        "lt_41.png",
        "lt_42.png",
        "lt_43.png",
    }

    -- 开始播放动画
    local viewIndex = 3
    retSprite.startPlay = function()
        retSprite:stopAllActions()
        retSprite:setTexture("lt_43.png")

        local array = {
            cc.DelayTime:create(0.3),
            cc.CallFunc:create(function()
                viewIndex = math.max(1, viewIndex)
                viewIndex = (viewIndex > #imageList) and 1 or viewIndex
                retSprite:setTexture(imageList[viewIndex])

                viewIndex = viewIndex + 1
            end)
        }
        retSprite:runAction(cc.RepeatForever:create(cc.Sequence:create(array)))
    end

    -- 结束播放动画
    retSprite.stopPlay = function()
        retSprite:stopAllActions()
        retSprite:setTexture("lt_43.png")
    end

    return retSprite
end

-- 创建进入复制页面
function ChatListView:createCopyLayer(copyStr, worldPos, closeCallback)
    -- 页面元素父节点
    local tempLayer = ui.newStdLayer()
    self:addChild(tempLayer)

    --
    local tempPos = cc.p(tempLayer:convertToNodeSpace(worldPos))
    local tempBtn = ui.newButton({
        normalImage = "lt_35.png",
        -- text = TR("复制"),
        titlePosRateY = 0.5,
        clickAction = function()
            IPlatform:getInstance():copyWords(copyStr)
            closeCallback()
            tempLayer:removeFromParent()
        end
    })
    tempBtn:setPosition(tempPos.x, tempPos.y + tempBtn:getContentSize().height / 2 + 5)
    tempLayer:addChild(tempBtn)

    ui.registerSwallowTouch({
        node = tempLayer,
        allowTouch = false,
        beganEvent = function(touch, event)
            return true
        end,
        endedEvent = function (touch, event)
            if not ui.touchInNode(touch, tempBtn) then
                closeCallback()
                tempLayer:removeFromParent()
            end
        end,
    })
end

-- 创建显示聊天消息玩家信息
function ChatListView:createPlayerInfoLabel(msgInfo, isSelf)
	-- 发送玩家的玩家的信息
    local fromExt = msgInfo.FromPlayer and msgInfo.FromPlayer.ExtendInfo
    -- 显示内容列表
    local contentList = {}

    -- 势力
    if fromExt and fromExt.JianghuKillForceId and self.mChatChanne ~= Enums.ChatChanne.eUnion then
        table.insert(contentList, {
            customCb = function( ... )
                local forceTexture = Enums.JHKSamllPic[fromExt.JianghuKillForceId]
                if forceTexture then
                    local forceSprite = ui.newSprite(forceTexture)
                    forceSprite:setAnchorPoint(cc.p(0, 0))
                    -- forceSprite:setScale(0.6)
                    return forceSprite
                else
                    return cc.Node:create()
                end
            end
        })
    end
    -- 称号
    if fromExt and fromExt.TitleId then
        table.insert(contentList, {
            customCb = function( ... )
                local titleSprite = ui.createTitleNode(fromExt.TitleId)

                if titleSprite then
                    titleSprite:setAnchorPoint(cc.p(0, 0))
                else
                    titleSprite = cc.Node:create()
                end

                return titleSprite
            end
        })
    end
    -- 发送玩家的玩家名
    if fromExt then
        table.insert(contentList, {
            text = fromExt.Name or "",
            formatInfo = {
                color = cc.c3b(0x46, 0x22, 0x0d),
            },
        })
    end
    -- 本服和私聊需要显示所在公会
    if fromExt and self.mChatChanne == Enums.ChatChanne.eWorld then
        -- 所在服务器信息
        local guildName = fromExt.GuildName
        if guildName and guildName ~= "" then
            -- 插入到最前面
            table.insert(contentList, {
                text = " [" .. guildName .. "] ",
                formatInfo = {
                    color = cc.c3b(0xde, 0x6e, 0x00),
                },
            })
        end
    end


    -- 发送玩家的Vip信息
    if fromExt and fromExt.Vip and fromExt.Vip > 0 then
        table.insert(contentList, {
            customCb = function( ... )
                local vipNode = ui.createVipNode(fromExt.Vip)
                vipNode:setScale(0.8)
                return vipNode
            end
        })
    end

    -- 跨服频道 显示服务器信息
    if fromExt and self.mChatChanne == Enums.ChatChanne.eCrossServer then
    	-- 所在服务器信息
        local serverName = msgInfo.FromPlayer.ServerName

        local subBeg, subEnd = string.find(serverName, ".%s+")
        if subBeg and subEnd then
            serverName = string.sub(serverName, subEnd + 1, string.len(serverName))
        end
        -- 插入到最前面
        table.insert(contentList, 1, {
            text = "[" .. serverName .. "]",
            formatInfo = {
                color = cc.c3b(0xde, 0x6e, 0x00),
            },
        })
    end

    -- 帮派频道 显示职位信息
    if fromExt and self.mChatChanne == Enums.ChatChanne.eUnion then
    	-- 插入到最前面
        table.insert(contentList, 1, {
            customCb = function()
                local postId = fromExt.UnionPostId or 34001004
                local tempSprite = ui.createSpriteAndLabel({
                    imgName = UnionPostBgImgae[postId] or "lt_15.png",
                    labelStr = "",
                    fontSize = 18,
                    alignType = ui.TEXT_ALIGN_CENTER,
                })
                return tempSprite
            end
        })
    end

    -- 玩家自己要反过来显示
    if isSelf then
        local tempList = {}
        for _, node in ipairs(contentList) do
            table.insert(tempList, 1, node)
        end
        contentList = tempList
    end

    --
    local retLabel = ui.newLabel({
        text = "",
        size = 18,
    })
    retLabel:setContent(contentList)

    return retLabel
end

-- 消息列表中系统消息点击事件
function ChatListView:onMsgListSystemClick(cellInfo, cellBgSprite, cellBgSize)
    local infoType = cellInfo.ExObj and cellInfo.ExObj.Type
    if infoType == Enums.ChatSystemType.eExpedition then --组队副本邀请信息
        local teamId = PlayerAttrObj:getPlayerAttrByName("TeamId")
        -- 挂机战斗过程中，不能跳转
        if Utility.isEntityId(teamId) or self.mForbidCleanUp then
            return
        end
        self:requestInterTeam(cellInfo)
    elseif infoType == Enums.ChatSystemType.eBattleTeam then --守卫襄阳
        -- 挂机战斗过程中，不能跳转
        if self.mForbidCleanUp then
            return
        end
        Utility.showTeambattleInvitedLayer()
    else
        local msgAnchor = cc.p(cellBgSprite:getAnchorPoint())
        local tempPosX, tempPosY = cellBgSprite:getPosition()
        tempPosX = tempPosX + (0.5 - msgAnchor.x) * cellBgSize.width
        tempPosY = tempPosY + (1 - msgAnchor.y) * cellBgSize.height
        local worldPos = cellBgSprite:getParent():convertToWorldSpace(cc.p(tempPosX, tempPosY))
        self:createCopyLayer(cellInfo.Message, worldPos, function()
            -- todo
        end)
    end
end

-- 聊天消息条目的点击事件
function ChatListView:onMsgListChatClick(cellInfo, cellBgSprite, cellBgSize)
	-- 是否有语音消息
    local haveVoice = next(cellInfo.Voice or {}) ~= nil

	if haveVoice then
        if not VoiceMsgTaskObj:isSupportVoice() then
            ui.showFlashView(TR("该版本不支持语音聊天"))
            return
        end

        VoiceMsgTaskObj:initGVoice(function(hadVoiceKey)
            if not hadVoiceKey then
                return
            end

            if CloudVoiceMng:haveLocalFile(cellInfo.Voice.VoiceId) then
                VoiceMsgTaskObj:addVoicePlay("", cellInfo.Voice.VoiceId, true)
            else
                -- 添加下载任务
                VoiceMsgTaskObj:addDownloadTask(cellInfo.Voice.VoiceId)
            end
        end)
    else
        if cellInfo.ExObj and (cellInfo.ExObj.Type == Enums.ChatSystemType.eWorldRedPack or cellInfo.ExObj.Type == Enums.ChatSystemType.eGuildRedPack) then
            -- 点击进行抢红包，红包ID为cellInfo.ExObj.RedId
            if ModuleInfoObj:moduleIsOpen(ModuleSub.eRedPurse, true) then
                self:requestRewardRedPacket(cellInfo.ExObj.RedId)
            end
        elseif cellInfo.ExObj and cellInfo.ExObj.Type == Enums.ChatSystemType.eJHkInvite then
            print("eJHkInvite")
        else
            -- 是否是玩家自己发的消息
            local isSelf = cellInfo.FromPlayer and cellInfo.FromPlayer.Id == PlayerAttrObj:getPlayerInfo().PlayerId
    
            cellBgSprite:setTexture(isSelf and "lt_12.png" or "lt_11.png")
            cellBgSprite:setContentSize(cellBgSize)
    
            local msgAnchor = cc.p(cellBgSprite:getAnchorPoint())
            local tempPosX, tempPosY = cellBgSprite:getPosition()
            tempPosX = tempPosX + (0.5 - msgAnchor.x) * cellBgSize.width
            tempPosY = tempPosY + (1 - msgAnchor.y) * cellBgSize.height
            local worldPos = cellBgSprite:getParent():convertToWorldSpace(cc.p(tempPosX, tempPosY))
            self:createCopyLayer(cellInfo.Message, worldPos, function()
                cellBgSprite:setTexture(isSelf and "lt_12.png" or "lt_11.png")
                cellBgSprite:setContentSize(cellBgSize)
            end)
        end
    end
end

-- 查看玩家信息
function ChatListView:showPlayerInfo(cellInfo)
	-- 是否是玩家自己发的消息
	if not cellInfo.FromPlayer or cellInfo.FromPlayer.Id == PlayerAttrObj:getPlayerInfo().PlayerId then
		return
    end
    -- 组队、势力频道不能点击（跨服频道，不能获取玩家数据）
    if self.mChatChanne == Enums.ChatChanne.eTeam or self.mChatChanne == Enums.ChatChanne.eGuide then
        return
    end

    -- 创建人物信息界面
    LayerManager.addLayer({
        name = "Chat.ChatPlayerInfoLayer",
        zOrder = self.mForbidCleanUp and Enums.ZOrderType.ePopLayer or nil,
        cleanUp = false,
        data = {
            playerId = cellInfo.FromPlayer.Id,
            forbidCleanUp = self.mForbidCleanUp,
            isStudy = self.mChatChanne == Enums.ChatChanne.eWorld or self.mChatChanne == Enums.ChatChanne.eUnion,
            selectCb = function(selectLayerObj, selectPlayerId)
            	if self.privateCb then
            		self.privateCb(selectLayerObj, selectPlayerId)
            	else
            		LayerManager.removeLayer(selectLayerObj)
            	end
            end
        },
    })
end

-- 是否是黑名单玩家的消息（私聊除外）
function ChatListView:isEnemyMsg(msgItem)
    local channelType = msgItem and msgItem.ChannelType
    if not channelType or channelType == Enums.ChatChanne.ePrivate then
        return
    end
    local playerId = msgItem and msgItem.FromPlayer and msgItem.FromPlayer.Id
    if not playerId then
        return
    end

    return EnemyObj:isEnemyPlayer(playerId)
end

-- ========================= 服务器数据请求相关函数 ==========================

-- 加入组队数据请求
function ChatListView:requestInterTeam(info)
    HttpClient:request({
        moduleName = "TeamHall",
        methodName = "EnterTeam",
        svrMethodData = {info.ExObj.TeamId, info.ExObj.NodeId, true},
        callback = function(data)
            -- 判断返回数据
            if not data or data.Status ~= 0 then
                return
            end
            -- 进入组队副本
            local data = data.Value
            LayerManager.addLayer({
                name = "challenge.ExpediTeamLayer",
                data = {nodeInfo = data.NodeInfo, teamInfo = data.TeamInfo},
            })
        end,
    })

end

-- 抢红包数据请求
function ChatListView:requestRewardRedPacket(id)
	HttpClient:request({
        moduleName = "Redpurse",
        methodName = "Reward",
        svrMethodData = {id},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            if response.Value.BaseGetGameResourceList then
                ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
            else
                local isSelf = false
                for i,v in ipairs(response.Value.PlayerList) do
                    if PlayerAttrObj:getPlayerAttrByName("PlayerId") == v.Id then
                        isSelf = true
                    end
                end
                if isSelf then
                    ui.showFlashView(TR("您已经领取过该红包了"))
                else
                    ui.showFlashView(TR("您来晚了，红包已经被抢完了！"))
                end
            end

            LayerManager.addLayer({
                name = "Chat.ChatGetRedPackageLayer",
                data = response.Value,
                zOrder = Enums.ZOrderType.ePopLayer,
                cleanUp = false,
            })

        end,
    })
end

return ChatListView
