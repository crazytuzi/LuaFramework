--[[
文件名: ChatMiniLayer.lua
描述: 聊天Mini窗口页面
创建人: heguanghui
创建时间: 2017.5.6
--]]

local ChatMiniLayer = class("ChatMiniLayer", function(params)
    return display.newLayer()
end)

--[[
-- 参数
	params 中的各项为：
	{
        chatBtnImage: 聊天按钮图片
        chatChanne: 默认显示的聊天频道，取值在"Enums.lua"文件中的“Enums.ChatChanne”枚举
        labelOffset = cc.p --聊天字体偏移
	}
]]
function ChatMiniLayer:ctor(params)
    params = params or {}
    self.mBgNameImage = params.bgSprite -- 聊天背景图片
    self.mDefautChanne = params.chatChanne -- 默认显示的聊天频道，
    self.mLabelOffset = params.labelOffset or cc.p(0, 0)

    -- 获取消息的频道列表
    if self.mDefautChanne then
        self.mViewChanneList = {self.mDefautChanne}
    else
        self.mViewChanneList = {
            Enums.ChatChanne.eWorld,
            Enums.ChatChanne.eTeam,
            Enums.ChatChanne.eUnion,
            Enums.ChatChanne.eSystem,
            Enums.ChatChanne.ePrivate,
        }
        if ClosePrivateChatHint then
            table.insert(self.mViewChanneList, Enums.ChatChanne.ePrivate)
        end
    end



    -- 需要显示的聊天记录列表
    self.mMsgStrList = {}

	-- 初始化页面控件
	self:initUI()
end

-- 初始化页面控件
function ChatMiniLayer:initUI(params)
	-- 内容的背景图
    local bgName =  "sy_27.png"
	local bgSprite = ui.newSprite(bgName)
	bgSprite:setPosition(0, 163 * Adapter.MinScale)
    bgSprite:setAnchorPoint(cc.p(0, 0.5))
    bgSprite:setScale(Adapter.MinScale)
	self:addChild(bgSprite)
    self.mBgSprite = bgSprite

	-- 内容背景的大小
	self.mBgSize = ui.getImageSize(bgName)

    local labelOffsetX = 95
    -- 裁剪结点，label超出时自动裁剪
    self.mBgSize = bgSprite:getContentSize()
    self.mScrollSize = cc.size(self.mBgSize.width - labelOffsetX, self.mBgSize.height)
    local clippingNode = cc.ClippingNode:create()
    clippingNode:setAlphaThreshold(1.0)
    local stencilNode = cc.LayerColor:create(cc.c4b(255, 255, 255, 255))
    stencilNode:setContentSize(self.mScrollSize)
    clippingNode:setPosition(cc.p(5 + labelOffsetX, 0))
    clippingNode:setStencil(stencilNode)
    clippingNode:setAnchorPoint(cc.p(0, 0))
    bgSprite:addChild(clippingNode)

    -- 显示最新聊天消息的label
    self.mMsgLabels = {}
    for i=1,2 do
        local msgLabel = ui.newLabel({
            text = self.mMsgStrList[1] or TR("[系统]:欢迎来到金庸武侠世界,快和好友一起闯荡江湖吧!"),
            dimensions = cc.size(self.mScrollSize.width - 5, 0)
        })
        msgLabel:setPosition(self.mScrollSize.width / 2 - 3, self.mScrollSize.height / 2 - self.mScrollSize.height * (i - 1))
        msgLabel:setImageElementScale(0.3)
        clippingNode:addChild(msgLabel)
        table.insert(self.mMsgLabels, msgLabel)
    end
    self.mViewIndex = 1

    -- 注册聊天新消息信息事件
    Notification:registerAutoObserver(bgSprite, function()
        -- 如果未读消息列表中只有一条消息，则有可能这一条消息可能也阅读过了
        if #self.mMsgStrList <= 1 then
            self:refreshUnreadItem()
        else
            self:addChatItem(ChatMng:getLastRecData())
        end
    end, {EventsName.eChatNewMsg})
    -- 定时刷新显示消息的控件
    Utility.schedule(bgSprite, function()
        self:refreshMsgLabel()
    end, 4) 

    -- 进入聊天页面的函数
    local function openChatLayer()
        if not ModuleInfoObj:moduleIsOpen(ModuleSub.eChat, true) then
            return
        end
        LayerManager.addLayer({
            name = "Chat.ChatLayer",
            data = {chatChanne = self.mDefautChanne or Enums.ChatChanne.eWorld},
            cleanUp = false,
            needRestore = true,
        })
    end
    -- 点击预览内容区域也可以进入聊天页面的按钮
    local previewBtn = ui.newButton({
        normalImage = bgName,
        clickAction = openChatLayer
    })
    previewBtn:setPosition(self.mBgSize.width / 2, self.mBgSize.height / 2)
    previewBtn:setOpacity(0)
    bgSprite:addChild(previewBtn)
end

-- 整理未读消息
function ChatMiniLayer:refreshUnreadItem()
    self.mMsgStrList = {}

    local unreadList = {}
    local defaultData
    for _, channe in pairs(self.mViewChanneList) do
        local tempList = ChatMng:getTypeChatData(channe)
        -- 如果沒有未读消息，mini窗口中默认显示的消息
        local tempCount = #tempList
        if (tempCount > 0) and (not defaultData or defaultData.TimeStamp < tempList[tempCount].TimeStamp) then
            defaultData = tempList[tempCount]
        end

        for _, item in ipairs(tempList or {}) do
            if ChatMng:msgIsUnread(channe, item.Id) then
                table.insert(unreadList, item)
            end
        end
    end
    if next(unreadList) then
        table.sort(unreadList, function(item1, item2)
            return item1.TimeStamp < item2.TimeStamp
        end)

        for _, item in ipairs(unreadList) do
            self:addChatItem(item)
        end
    elseif defaultData then
        self:addChatItem(defaultData)
    end

    if next(self.mMsgStrList) then
        self:refreshMsgLabel()
    end
end

-- 添加聊天记录到缓存数据
function ChatMiniLayer:addChatItem(chatData)
    if not next(chatData or {}) or not table.indexof(self.mViewChanneList, chatData.ChannelType) or
        (chatData.FromPlayer and EnemyObj:isEnemyPlayer(chatData.FromPlayer.Id)) then
        return false
    end

    -- 消息内容
    local msgStr = ChatMng:faceStrUnpack(chatData.Message)
    local tempLen = msgStr:len()
    if msgStr:byte(tempLen) == string.byte('#') then
        msgStr = msgStr:sub(1, tempLen - 1)
    end
    -- 显示文本
    local tempStr = string.format("[%s]%s:%s",
        Enums.ChatChanneName[chatData.ChannelType],
        chatData.FromPlayer and chatData.FromPlayer.ExtendInfo and chatData.FromPlayer.ExtendInfo.Name or "",
        msgStr)
    table.insert(self.mMsgStrList, tempStr)

    -- 最多保留10条
    if #self.mMsgStrList > 10 then
        table.remove(self.mMsgStrList, 1)
    end
    return true
end

-- 刷新新收到的聊天记录
function ChatMiniLayer:refreshMsgLabel()
    local msgCount = #self.mMsgStrList
    if msgCount == 0 then
        return
    end

    local function getIndexString(index)
        local vIndex = (index > msgCount) and 1 or index
        return vIndex, self.mMsgStrList[vIndex]
    end

    if msgCount == 1 then  -- 只有一条就不执行动画
        self.mMsgLabels[1]:setString(self.mMsgStrList[1])
    else
        -- 计算当前和下一条需要显示的内容
        self.mViewIndex = self.mViewIndex + 1
        local msgIndex1, nextStr = getIndexString(self.mViewIndex)
        self.mViewIndex = msgIndex1 -- 下一条index矫正
        
        local offsetY = self.mScrollSize.height
        for i, msgLabel in ipairs(self.mMsgLabels) do
            msgLabel:stopAllActions()
            -- 设置下面label的显示内容，然后它滚上来
            local posX, posY = msgLabel:getPosition()
            if posY < 0 then
                msgLabel:setString(nextStr)
            end
            -- 执行动画效果
            msgLabel:runAction(cc.Sequence:create(
                cc.MoveBy:create(0.5, cc.p(0, offsetY)),
                cc.CallFunc:create(function()
                    local posX, posY = msgLabel:getPosition()
                    if posY > offsetY then
                        msgLabel:setPosition(posX, posY - offsetY * 2)
                    end
                end)))
        end
    end
end

-- 添加需要显示消息的频道
function ChatMiniLayer:addViewChanne(channelType)
    for _, value in pairs(self.mViewChanneList) do
        if value == channelType then
            return
        end
    end

    table.insert(self.mViewChanneList, channelType)
end

-- 删除需要显示消息的频道
function ChatMiniLayer:deleteViewChanne(channelType)
    for index = #self.mViewChanneList, 1, -1 do
        if self.mViewChanneList[index] == channelType then
            table.remove(self.mViewChanneList, index)
        end
    end
end

return ChatMiniLayer
