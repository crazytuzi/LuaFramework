--[[
文件名: ChatHintLayer.lua
描述: 屏幕顶部的聊天提示页面
创建人: liaoyuangang
创建时间: 2017.05.31
--]]

local ChatHintLayer = class("ChatHintLayer", function(params)
    return display.newLayer()
end)

-- 不需要显示提示信息的页面
local CloseHintList = {
    ["teamcopy.TeamCopyBattleRoomLayer"] = true, -- 战斗页面
}

--
function ChatHintLayer:ctor()
	-- 显示一条聊天消息的背景大小
	self.mBgSize = cc.size(634, 165)

	-- 当前是否正在聊天页面
	self.mInChatLayer = false

	-- 初始化页面控件
	self:initUI()
end

-- 初始化页面控件
function ChatHintLayer:initUI()
	self.mBgBtn = ui.newButton({
		normalImage = "lt_40.png",
		size = self.mBgSize
	})
	self.mBgBtn:setScale(Adapter.MinScale)
	self.mBgBtn:setAnchorPoint(cc.p(0.5, 0))
	self.mBgBtn:setPosition(display.cx, display.cy + 568 * Adapter.AutoScaleY)
	self.mBgBtn:setPressedActionEnabled(false)
	self:addChild(self.mBgBtn)
	-- 注册触摸事件
	self.mBgBtn:addTouchEventListener(function(sender, event)
        if event == ccui.TouchEventType.began then
            self.mBgBtn.mBeginPos = sender:getTouchBeganPosition()
        elseif event == ccui.TouchEventType.moved then
        	-- todo
        elseif event == ccui.TouchEventType.ended or event == ccui.TouchEventType.canceled then
            self.mGmShowing = false

            local beginPos = self.mBgBtn.mBeginPos
            local endPos = sender:getTouchEndPosition()
            local distance = math.sqrt(math.pow(endPos.x - beginPos.x, 2) + math.pow(endPos.y - beginPos.y, 2))
            if distance < (40 * Adapter.MinScale) then
            	local lastMsg = ChatMng:getLastRecData()
            	local tempData = {
                    chatChanne = (lastMsg.ChannelType == Enums.ChatChanne.eGM) and Enums.ChatChanne.eSystem or lastMsg.ChannelType,
                    privateId = lastMsg.FromPlayer and lastMsg.FromPlayer.Id
                }

                local _, _, eventID = Guide.manager:getGuideInfo()
                -- 引导时，不可点击
                if not eventID then
                    LayerManager.addLayer({
                        name = "Chat.ChatLayer",
                        cleanUp = false,
                        data = tempData,
                    })
                end
            end
            self.mBgBtn:stopAllActions()
            self.mBgBtn:runAction(cc.MoveTo:create(0.5, cc.p(display.cx, display.cy + 568 * Adapter.AutoScaleY)))
        end
    end)

	-- 注册新消息
	Notification:registerAutoObserver(self.mBgBtn, function()
        local lastMsg = ChatMng:getLastRecData()
        if not next(lastMsg) then
            return 
        end

        -- 判断是不是红包信息
        local isRedMsg = lastMsg.ExObj and (lastMsg.ExObj.Type == Enums.ChatSystemType.eWorldRedPack or lastMsg.ExObj.Type == Enums.ChatSystemType.eGuildRedPack)

        -- 在聊天中，GM消息正在显示, 聊天中设置提示框不显示，页面不需要提示
        local isNeedShow = self.mInChatLayer or self.mGmShowing or 
            ClosePrivateChatHint or CloseHintList[LayerManager.getTopCleanLayerName()]
        if not isNeedShow and ((lastMsg.ChannelType == Enums.ChatChanne.ePrivate) or 
            (lastMsg.ChannelType == Enums.ChatChanne.eSystem and 
                lastMsg.MessageType == Enums.ChatSystemType.eOnline and
                OnlineNotifyObj:isOnlineNotifyPlayer(lastMsg.FromPlayer.Id)) or isRedMsg) then
            -- 显示私聊和好友上线提示，红包信息
            self:showChatMessage(lastMsg, lastMsg.ChannelType == Enums.ChatChanne.eSystem)
        elseif lastMsg.ChannelType == Enums.ChatChanne.eGM then
            self:showGmMessage(lastMsg)
        end
	end, EventsName.eChatNewMsg)
end

-- 开始提示动画
-- isGM: 是否是GM消息
function ChatHintLayer:startHintActions(isGM)
    -- 向上滑动关闭提示
    local hintLabel = ui.newLabel({
        text = TR("向上滑动关闭"),
        size = 18,
        color = cc.c3b(0x3d, 0x83, 0x21),
        align = cc.TEXT_ALIGNMENT_RIGHT,
    })
    hintLabel:setAnchorPoint(cc.p(1, 0.5))
    hintLabel:setPosition(self.mBgSize.width - 35, 34)
    self.mBgBtn:addChild(hintLabel)

    if not isGM then isGM = false end
    self.mBgBtn:stopAllActions()
    self.mGmShowing = isGM -- GM消息标识
    self.mBgBtn:runAction(cc.Sequence:create({
        cc.MoveTo:create(0.3, cc.p(display.cx, display.cy + (568 - self.mBgSize.height) * Adapter.AutoScaleY)),
        cc.DelayTime:create(5),
        cc.MoveTo:create(0.5, cc.p(display.cx, display.cy + 568 * Adapter.AutoScaleY)),
        cc.CallFunc:create(function()
            self.mGmShowing = false -- GM消息结束
        end),
    }))
end

-- 显示后天GM消息
function ChatHintLayer:showGmMessage(msgItem)
    self.mBgBtn:removeAllChildren()

    -- 消息到标题
    local titleLabel = ui.newLabel({
        text = TR("GM消息"),
        size = 24,
        color = cc.c3b(0x72, 0x45, 0x1e),
    })
    titleLabel:setAnchorPoint(cc.p(0, 0.5))
    titleLabel:setPosition(35, self.mBgSize.height - 50)
    self.mBgBtn:addChild(titleLabel)

    -- 消息背景
    local msgBgSize = cc.size(self.mBgSize.width*0.9, 70)
    local msgBg = ui.newScale9Sprite("lt_36.png", msgBgSize)
    msgBg:setAnchorPoint(cc.p(0.5, 0))
    msgBg:setPosition(self.mBgSize.width * 0.5, 23)
    self.mBgBtn:addChild(msgBg)

    -- 消息内容
    local msgLabel = ui.newLabel({
        text = msgItem.Message,
        size = 22,
        color = cc.c3b(0x6d, 0x4a, 0x2d),
        dimensions = msgBgSize,
        align = cc.TEXT_ALIGNMENT_CENTER,
    })
    msgLabel:setImageElementScale(0.3)
    msgLabel:setPosition(msgBgSize.width / 2, msgBgSize.height / 2)
    msgBg:addChild(msgLabel)

    -- 开始显示动画
    self:startHintActions(true)
end

-- 显示聊天消息或好友上线提示
function ChatHintLayer:showChatMessage(msgItem, isSys)
    self.mBgBtn:removeAllChildren()
    -- 对方信息
    local fromPlayer = msgItem.FromPlayer.ExtendInfo

    -- 发送消息的玩家头像
    local headCard = CardNode:create({
        allowClick = false,
        onClickCallback = function()
            -- todo
        end
    })
    headCard:setScale(0.4)
    headCard:setPosition(self.mBgSize.width*0.1, self.mBgSize.height * 0.7)
    headCard:setHero({ModelId = fromPlayer.HeadImageId, FashionModelID = fromPlayer.FashionModelId, IllusionModelId = fromPlayer.IllusionModelId}, {CardShowAttr.eBorder})
    self.mBgBtn:addChild(headCard)

    -- 发送消息的玩家名字
    local tempList = {}
    table.insert(tempList, {
        text = fromPlayer.Name .. " ",
        formatInfo = {
            color = cc.c3b(0x72, 0x45, 0x1e),
        },
    })
    -- 玩家Vip等级
    if fromPlayer.Vip and fromPlayer.Vip > 0 then
        table.insert(tempList, {
            customCb = function( ... )
                local vipNode = ui.createVipNode(fromPlayer.Vip)
                vipNode:setScale(0.8)
                return vipNode
            end
        })
    end
    local nameLabel = ui.newLabel({
        text = "",
        size = 24,
        color = cc.c3b(0x72, 0x45, 0x1e),
    })
    nameLabel:setAnchorPoint(cc.p(0, 0.5))
    nameLabel:setPosition(self.mBgSize.width*0.14, self.mBgSize.height * 0.7)
    nameLabel:setContent(tempList)
    self.mBgBtn:addChild(nameLabel)

    -- 消息的时间
    local timeLabel = ui.newLabel({
        text = MqTime.toDownFormat(Player:getCurrentTime() - msgItem.TimeStamp),
        size = 20,
        color = cc.c3b(0xce, 0x8e, 0x55),
        align = cc.TEXT_ALIGNMENT_RIGHT,
    })
    timeLabel:setAnchorPoint(cc.p(1, 0.5))
    timeLabel:setPosition(self.mBgSize.width - 60, self.mBgSize.height - 47)
    self.mBgBtn:addChild(timeLabel)

    -- 消息背景
    local isRedMsg = msgItem.ExObj and (msgItem.ExObj.Type == Enums.ChatSystemType.eWorldRedPack or msgItem.ExObj.Type == Enums.ChatSystemType.eGuildRedPack)
    local redImageText = isRedMsg and "{xn_85.png}" or ""
    local Bgpic = isRedMsg and "lt_46.png" or "lt_36.png" --判断是否是红包消息，改变背景
    local msgBgSize = cc.size(self.mBgSize.width*0.9, 70)
    local msgBg = ui.newScale9Sprite(Bgpic, msgBgSize)
    msgBg:setAnchorPoint(cc.p(0.5, 0))
    msgBg:setPosition(self.mBgSize.width * 0.5, 23)
    self.mBgBtn:addChild(msgBg)
    -- 最近一条消息内容
    local tempStr = msgItem.Message
    if ChatMng:getMsgLength(tempStr) > 45 then
        tempStr = ChatMng:getSubMsg(tempStr, 42, false) .. "..."
    end
    local msgLabel = ui.newLabel({
        text = redImageText .. ChatMng:faceStrUnpack(tempStr),
        size = 22,
        color = cc.c3b(0x6d, 0x4a, 0x2d),
        align = isSys and cc.TEXT_ALIGNMENT_CENTER,
        dimensions = msgBgSize,
    })
    msgLabel:setImageElementScale(0.3)
    msgLabel:setPosition(msgBgSize.width / 2, msgBgSize.height / 2)
    msgBg:addChild(msgLabel)

    -- 开始显示动画
    self:startHintActions()
end

-- 设置当前是否正在聊天页面
function ChatHintLayer:setInChatLayer(inChatLayer)
	self.mInChatLayer = inChatLayer
end

return ChatHintLayer