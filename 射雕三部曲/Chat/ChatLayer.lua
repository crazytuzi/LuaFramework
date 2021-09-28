--[[
文件名: ChatLayer.lua
描述: 聊天页面
创建人: liaoyuangang
创建时间: 2017.05.21
-- ]]

local ChatLayer = class("ChatLayer", function(params)
    return display.newLayer()
end)

-- 模块内通知刷新聊天消息列表的事件名
local RefrishMessagList = "EventsName_ChatLayer_RefrishMessagList"
-- 模块内通知刷新频道列表的事件名
local RefrishChanneList = "EventsName_ChatLayer_RefrishChanneList"

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

--[[
-- 参数
	params 中的各项为：
	{
		chatChanne: 默认显示的聊天频道，取值在"Enums.lua"文件中的“Enums.ChatChanne”枚举
        privateId: 当初始显示页面为私聊时，初始显示的私聊的玩家Id
        isSmall: 是否是小窗体模式，默认为false
	}
]]
function ChatLayer:ctor(params)
	-- 屏蔽下层点击事件
    ui.registerSwallowTouch({node=self})

    -- 保存传入参数
	params = params or {}
    -- 当前显示的聊天频道
    self.mChatChanne = params.chatChanne
    -- 当前私聊的玩家Id
    self.mPrivateId = params.privateId
    -- 是否是小窗体模式
    self.mIsSmall = params.isSmall == true

    -- 好友列表
    self.mFriendList = {}

    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 初始化页面控件
	self:initUI()
    -- 请求好友列表
    FriendObj:requestGetFriendList()
    -- 刚进入该页面时需要删除语音异步任务列表和删除语音播放列表
    VoiceMsgTaskObj:clearTask()

    --
    self:setBgSize(cc.size(635, 1130))

    -- 好友信息改变的事件通知
    Notification:registerAutoObserver(self.mParentLayer, function()
        self.mFriendList = FriendObj:getFriendList()
        -- 通知刷新频道列表
        Notification:postNotification(RefrishChanneList)
    end, {EventsName.eFriendChanged})
end

function ChatLayer:onEnterTransitionFinish()
    ChatBtnLayer:setChatVisible(false)
    -- 如是战斗进入则设置为true
    local _, _, eventID = Guide.manager:getGuideInfo()
    local layerName = LayerManager.getTopCleanLayerName()
    if ChatForbidCleanUpList[layerName] or eventID then
        self.mForbidCleanUp = true
    end

    --
    if not tolua.isnull(ChatMsgHintObj) then
        ChatMsgHintObj:setInChatLayer(true)
    end
end

function ChatLayer:onExit()
    ChatBtnLayer:setChatVisible(true)
    if not tolua.isnull(ChatMsgHintObj) then
        ChatMsgHintObj:setInChatLayer(false)
    end
end

-- 初始化页面控件
function ChatLayer:initUI()
    -- 创建界面背景
    self.mBgSprite = ui.newScale9Sprite("lt_01.png", cc.size(640, 1120))
    self.mBgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(self.mBgSprite)

    -- 拖动窗体的触摸控件
    self.mMoveBtn = ui.newButton({
        normalImage = "c_83.png",
        size = cc.size(640, 100)
    })
    self.mMoveBtn:setAnchorPoint(cc.p(0.5, 1))
    self.mBgSprite:addChild(self.mMoveBtn)
    self:setMoveLayerTouch()
    -- 大标题
    local titleLabel = ui.newLabel({
        text = TR("聊天"),
        size = Enums.Fontsize.eDefault + 2,
        color = cc.c3b(0x4e, 0x15, 0x0c)
    })
    titleLabel:setAnchorPoint(cc.p(0.5, 0.5))
    self.mParentLayer:addChild(titleLabel)
    self.mTitleLabel = titleLabel

    -- 关闭按钮
    self.mCloseBtn = ui.newButton({
        normalImage = "c_29.png",
        clickAction = function()
            LayerManager.removeLayer(self)
        end,
    })
    self.mBgSprite:addChild(self.mCloseBtn)

    -- 小窗体切换按钮
    --[[
    self.mChangeBtn = ui.newButton({
        normalImage = self.mIsSmall and "lt_17.png" or "lt_16.png",
        clickAction = function()
            if self.mIsSmall then
                self:setBgSize(cc.size(635, 1130))
            else
                self:setBgSize(cc.size(635, 600))
            end

            self.mIsSmall = not self.mIsSmall
            local tempImg = self.mIsSmall and "lt_17.png" or "lt_16.png"
            self.mChangeBtn:loadTextures(tempImg, tempImg)
        end,
    })
    self.mBgSprite:addChild(self.mChangeBtn)
    --]]

    -- 创建一个父控件layer
    local function createParentLayer(contentSize)
        contentSize = contentSize or cc.size(640, 1136)

        local retLayer = cc.Layer:create()
        retLayer:setContentSize(contentSize)
        retLayer:setIgnoreAnchorPointForPosition(false)
        retLayer:setAnchorPoint(cc.p(0.5, 0.5))
        retLayer:setCascadeOpacityEnabled(true)

        return retLayer
    end

    -- 系统消息mini窗口的父节点
    self.mMiniMsgLayer = createParentLayer(self.mMiniSize)
    self.mBgSprite:addChild(self.mMiniMsgLayer)

    -- 频道列表的父节点
    self.mChanneLayer = createParentLayer()
    self.mBgSprite:addChild(self.mChanneLayer)

    -- 消息列表的父节点
    self.mMsgLayer = createParentLayer()
    self.mBgSprite:addChild(self.mMsgLayer)

    -- 输入内容的父节点
    self.mEditLayer = createParentLayer(self.mEditSize)
    self.mBgSprite:addChild(self.mEditLayer)

    -- 注册等级变化事件，关闭聊天界面(档住了升级界面和引导)
    Notification:registerAutoObserver(titleLabel, function ()
        LayerManager.removeLayer(self)
    end, {EventsName.eLvChanged})
end

-- 重新设置页面大小
function ChatLayer:setBgSize(bgSize)
    self.mBgSize = bgSize or cc.size(635, 1130)

    -- 顶部mini消息部分的大小
    self.mMiniSize = cc.size(self.mBgSize.width, 180)
    -- 底部输入部分的大小
    self.mEditSize = cc.size(self.mBgSize.width, 65)

    -- 设置背景图片的大小和位置
    self.mBgSprite:setContentSize(self.mBgSize)
    self.mBgSprite:setPosition(320, 568)

    -- 调整页面title的位置
    self.mTitleLabel:setPosition(self.mBgSize.width / 2, self.mBgSize.height - 20)
    -- 调整关闭按钮的位置
    self.mCloseBtn:setPosition(self.mBgSize.width - 38, self.mBgSize.height - 35)
    -- 调整窗体大小切换按钮的位置
    -- self.mChangeBtn:setPosition(self.mBgSize.width - 120, self.mBgSize.height - 35)
    -- 设置窗体拖动触摸按钮的位置
    self.mMoveBtn:setPosition(self.mBgSize.width / 2, self.mBgSize.height)

    -- 设置mini消息控件的位置
    self.mMiniMsgLayer:setContentSize(self.mMiniSize)
    self.mMiniMsgLayer:setAnchorPoint(cc.p(0.5, 1))
    self.mMiniMsgLayer:setPosition(self.mBgSize.width / 2, self.mBgSize.height - 80)

    -- 输入框空间的位置设置
    self.mEditLayer:setContentSize(self.mEditSize)
    self.mEditLayer:setAnchorPoint(cc.p(0.5, 0))
    self.mEditLayer:setPosition(self.mEditSize.width / 2, 12)

    -- 设置频道列表的父节点位置
    self.mChanneLayer:setAnchorPoint(cc.p(0.5, 0))
    self.mChanneLayer:setPosition(self.mBgSize.width / 2, 0)

    -- 消息列表的父节点
    self.mMsgLayer:setAnchorPoint(cc.p(0.5, 0))
    self.mMsgLayer:setPosition(self.mBgSize.width / 2, 0)

    if not self.mChatChanne or self.mChatChanne == Enums.ChatChanne.ePrivate and not self.mPrivateId then
        -- 创建频道信息页面
        self:createChanneInfo()
    else
        -- 创建频道消息页面
        self:createChanneMsg(self.mChatChanne, self.mPrivateId)
    end
end

-- 设置拖动窗体的触摸事件
function ChatLayer:setMoveLayerTouch()
    local offset = nil
    self.mMoveBtn:addTouchEventListener(function(sender, eventType)
        -- 只有在小窗体时才能拖动
        if not self.mIsSmall then
            return false
        end

        -- 点击时鼠标和卡槽的坐标偏移距离
        if eventType == ccui.TouchEventType.began then -- 触摸开始
            -- 先结束窗体的action动作
            self.mBgSprite:stopAllActions()
            -- 获取点击位置与背景图位置的偏移
            local bgSpritePos = cc.p(self.mBgSprite:getPosition())
            local beginPos = sender:getTouchBeganPosition()
            offset = cc.pSub(bgSpritePos, beginPos)

            return true
        elseif eventType == ccui.TouchEventType.moved then -- 触摸
            local touchPos = cc.p(sender:getTouchMovePosition())
            self.mBgSprite:setPosition(cc.pAdd(touchPos, offset))
        else
            local touchPos = sender:getTouchEndPosition()
            local endPos = cc.pAdd(touchPos, offset)
            endPos.x = math.max(0, math.min(endPos.x, 640))
            endPos.y = math.max(0, math.min(endPos.y, 1136 - self.mBgSize.height / 2))

            self.mBgSprite:runAction(cc.MoveTo:create(0.3, endPos))
        end
    end)
end

-- 创建频道消息页面
--[[
-- 参数
	chaneType: 频道类型，取值在“Enums.lua”文件的“Enums.ChatChanne” 中定义
	playerId: 如果是私聊频道，需要传入私聊的玩家Id
]]
function ChatLayer:createChanneMsg(chaneType, playerId)
	--
	self.mChanneLayer:removeAllChildren()

	-- 设置当前显示的聊天频道
	self.mChatChanne = chaneType
	-- 设置当前私聊的玩家Id
	self.mPrivateId = playerId

	-- 创建系统消息的mini显示区域
	self:createMiniMsgView()
	-- 创建消息内容列表
	self:createMsgListView()
	-- 创建输入框相关控件
	self:createEditView()

    -- 保存当前频道的已读消息的最大Id
    self:saveChanneMaxReadId()
end

-- 创建频道信息页面
function ChatLayer:createChanneInfo()
	--
	self.mMsgLayer:removeAllChildren()

	-- 当前显示的聊天频道设置为nil
	self.mChatChanne = Enums.ChatChanne.ePrivate
	-- 当前私聊的玩家Id设置为nil
	self.mPrivateId = nil

	-- 创建系统消息的mini显示区域
	self:createMiniMsgView()
	-- 创建私聊玩家列表
	self:createPrivateListView()
	-- 创建输入框相关控件
	self:createEditView()
end

-- 创建mini消息显示区域
--[[
-- 参数
    needTabView:是否需要频道导航页签
]]
function ChatLayer:createMiniMsgView(needTabView)
	-- 系统频道不需要显示mini消息窗口
	if self.mChatChanne == Enums.ChatChanne.eSystem or self.mChatChanne == Enums.ChatChanne.eGM then
		self.mMiniMsgLayer:removeAllChildren()
		return
	end

	-- 如果已经创建了mini消息窗口，则直接返回
	local childrenCount = self.mMiniMsgLayer:getChildrenCount()
	if childrenCount > 0 then
        if not tolua.isnull(self.mTabView) then
            self.mTabView:activeTabBtnByTag(self.mChatChanne)
        end
		return
	end

	-- mini消息背景图大小
	local miniBgSize = cc.size(480, 120)

	-- mini消息的背景图
	local miniBgSprite = ui.newScale9Sprite("lt_18.png", miniBgSize)
	miniBgSprite:setAnchorPoint(cc.p(0, 1))
	miniBgSprite:setPosition(30, self.mMiniSize.height+20)
	self.mMiniMsgLayer:addChild(miniBgSprite)

    if needTabView == false then
        local lineSprite = ui.newScale9Sprite("lt_03.png", cc.size(self.mMiniSize.width, 8))
        lineSprite:setPosition(self.mMiniSize.width / 2, 3)
        self.mMiniMsgLayer:addChild(lineSprite)
    else
        -- todo
    end

	-- 显示消息内容的滑动控件
    local scrollView = ccui.ScrollView:create()
    scrollView:setContentSize(miniBgSize)
    scrollView:setPosition(miniBgSize.width / 2, miniBgSize.height / 2)
    scrollView:setAnchorPoint(cc.p(0.5, 0.5))
    scrollView:setBounceEnabled(true)
    miniBgSprite:addChild(scrollView)

    scrollView:addTouchEventListener(function(sender, event)
        if event == ccui.TouchEventType.began then
            scrollView.mBeginPos = sender:getTouchBeganPosition()
        elseif event == ccui.TouchEventType.ended then
            local beginPos = scrollView.mBeginPos
            local endPos = sender:getTouchEndPosition()
            local distance = math.sqrt(math.pow(endPos.x - beginPos.x, 2) + math.pow(endPos.y - beginPos.y, 2))
            if math.abs(endPos.x - beginPos.x) < (40 * Adapter.MinScale) and math.abs(endPos.y - beginPos.y) < (20 * Adapter.MinScale) then
            	-- 需要延迟1帧执行，不然会闪退
                Utility.performWithDelay(self.mMiniMsgLayer, function( ... )
                    self:createChanneMsg(Enums.ChatChanne.eSystem)
                end, 0.01)
            end
        end
    end)

	-- 显示消息内容的label
	local msgLablePos = cc.p(miniBgSize.width / 2, miniBgSize.height / 2)
	local msgLabel = ui.newLabel({
        text = TR("[系统]:欢迎来到金庸武侠世界,快和好友一起闯荡江湖吧!"),
        size = 22,
        color = cc.c3b(0x25, 0x87, 0x11),
        dimensions = cc.size(miniBgSize.width - 12, 0)
    })
    msgLabel:setPosition(msgLablePos)
    msgLabel:setImageElementScale(0.3)
    scrollView:addChild(msgLabel)

	-- mini区域需要显示频道列表
	local viewChanneList = {
		Enums.ChatChanne.eSystem, -- 系统频道
	}
	-- 需要显示的消息列表
	local msgItemList = self:getMiniMsgData(viewChanneList)
    -- 注册聊天新消息信息事件
    Notification:registerAutoObserver(miniBgSprite, function()
        -- 如果未读消息列表中只有一条消息，则有可能这一条消息可能也阅读过了
        if #msgItemList <= 1 then
            msgItemList = self:getMiniMsgData(viewChanneList)
        else
        	table.insert(msgItemList, ChatMng:getLastRecData())
        end
    end, {EventsName.eChatNewMsg})
    -- 注册聊天未读消息事件
    local eventNameList = {EventsName.eChatUnreadPrefix}
    for _, channe in pairs(viewChanneList) do
        table.insert(eventNameList, EventsName.eChatUnreadPrefix .. tostring(channe))
        table.insert(eventNameList, EventsName.eChatMsgChangePrefix .. tostring(channe))
    end
    Notification:registerAutoObserver(miniBgSprite, function()
        msgItemList = self:getMiniMsgData(viewChanneList)
    end, eventNameList)

    -- 刷新新收到的聊天记录
    local function setMiniMsg(msgItem)
    	if not next(msgItem or {}) then
	        return
	    end

	    -- 消息内容
	    local msgStr = ChatMng:faceStrUnpack(msgItem.Message)
	    local tempLen = msgStr:len()
	    if msgStr:byte(tempLen) == string.byte('#') then
	        msgStr = msgStr:sub(1, tempLen - 1)
	    end
	    local playerName = msgItem.FromPlayer and msgItem.FromPlayer.ExtendInfo and msgItem.FromPlayer.ExtendInfo.Name or ""
	    -- 设置消息内容
	    msgLabel:setString(playerName == "" and (" " .. msgStr) or string.format(" %s:%s", playerName, msgStr))
	    -- 频道类型标签
        msgLabel:insertElement(function()
            local tempSprite = ui.createSpriteAndLabel({
                imgName = ChanneBgImage[msgItem.ChannelType] or "lt_14.png",
                labelStr = "",
                fontSize = 18,
                outlineColor = Enums.Color.eOutlineColor,
                alignType = ui.TEXT_ALIGN_LEFT,
            })
            return tempSprite
        end, 0)
    end

    local viewIndex = 0
    local msgCount = #msgItemList
	local array = {
        cc.MoveTo:create(0.5, cc.p(msgLablePos.x, msgLablePos.y + ((msgCount > 1) and 100 or 0))),
        cc.CallFunc:create(function()
        	msgCount = #msgItemList
        	viewIndex = viewIndex < msgCount and math.min(viewIndex + 1, msgCount) or 1

			local msgItem = msgItemList[viewIndex]
			if msgItem then
				setMiniMsg(msgItem)
            	msgLabel:setPosition(msgLablePos.x, ((msgCount > 1) and -100) or msgLablePos.y)
			end
        end),
        cc.MoveTo:create(0.5, msgLablePos),
        cc.DelayTime:create(4),
    }
    msgLabel:runAction(cc.RepeatForever:create(cc.Sequence:create(array)))

    -- 创建频道切换tabview
    self:createChanneTabView()

    -- 联系人按钮
    local contactsBtn = ui.newButton({
        normalImage = "lt_08.png",
        clickAction = function()
            LayerManager.addLayer({
                name = "Chat.ContactsLayer",
                zOrder = self.mForbidCleanUp and Enums.ZOrderType.ePopLayer or nil,
                data = {
                    forbidCleanUp = self.mForbidCleanUp,
                    selectCb = function(selectLayerObj, selectPlayerId)
                        if not tolua.isnull(self) then -- 聊天页面没有被销毁
                            -- 调整到私聊频道
                            self:gotoPrivate(selectPlayerId)
                        else -- 否则需要通过恢复聊天页面的方式重新打开
                            local tempStr = "Chat.ChatLayer"
                            local tempData = LayerManager.getRestoreData(tempStr)
                            tempData.privateId = selectPlayerId
                            LayerManager.setRestoreData(tempStr, tempData)
                        end

                        LayerManager.removeLayer(selectLayerObj)
                    end
                },
                cleanUp = false,
            })
        end
    })
    contactsBtn:setPosition(self.mMiniSize.width - 70, 140)
    self.mMiniMsgLayer:addChild(contactsBtn)
    -- 联系人按钮的小红点
    local tempSize = contactsBtn:getContentSize()
    -- 联系人按钮的小红点
    local redDotSprite = ui.createBubble({})
    redDotSprite:setPosition(tempSize.width * 0.9, tempSize.height * 0.8)
    redDotSprite:setVisible(RedDotInfoObj:isValid(ModuleSub.eEmailFriend))
    contactsBtn:addChild(redDotSprite)
    local eventsName = {EventsName.eRedDotPrefix .. tostring(ModuleSub.eEmailFriend)}
    Notification:registerAutoObserver(redDotSprite, function()
        local redDotData = RedDotInfoObj:isValid(ModuleSub.eEmailFriend)
        redDotSprite:setVisible(redDotData)
    end, eventsName)
end

-- 创建频道切换tabview
function ChatLayer:createChanneTabView()
    local tabBtnInfos = {
        {
            text = Enums.ChatChanneName[Enums.ChatChanne.eWorld],
            tag = Enums.ChatChanne.eWorld,
            orderTag = 1,
        },
        {
            text = Enums.ChatChanneName[Enums.ChatChanne.eUnion],
            tag = Enums.ChatChanne.eUnion,
            orderTag = 3,
        },
        {
            text = TR("私聊"), -- Enums.ChatChanneName[Enums.ChatChanne.ePrivate],
            tag = Enums.ChatChanne.ePrivate,
            orderTag = 4,
        },

        -- {
        --     text = Enums.ChatChanneName[Enums.ChatChanne.eGuide], --
        --     tag = Enums.ChatChanne.eGuide,
        --     orderTag = 2,
        -- },
    }
    -- 当前在队伍中，开启组队
    local teamId = PlayerAttrObj:getPlayerAttrByName("TeamId")
    if Utility.isEntityId(teamId) then
        table.insert(tabBtnInfos, {
            text = Enums.ChatChanneName[Enums.ChatChanne.eTeam],
            tag = Enums.ChatChanne.eTeam,
            orderTag = 5,
        }) -- 组队频道
    end

    --在江湖杀中开启势力频道
    local JianghuKillChannel = PlayerAttrObj:getPlayerAttrByName("JianghuKillChannel")
    if JianghuKillChannel then
        if ModuleInfoObj:moduleIsOpen(ModuleSub.eShili) then
            table.insert(tabBtnInfos, {
                text = Enums.ChatChanneName[Enums.ChatChanne.eGuide],
                tag = Enums.ChatChanne.eGuide,
                orderTag = 2,
            }) -- 势力频道
        end
    end

    table.sort(tabBtnInfos, function(a, b)
        if a.orderTag ~= b.orderTag then
            return a.orderTag < b.orderTag
        end
    end)

    self.mTabView = ui.newTabLayer({
        btnInfos = tabBtnInfos,
        needLine = true,
        btnSize = cc.size(95, 53),
        space = 22,
        viewSize = cc.size(590, 80),
        normalImage = "lt_05.png",
        lightedImage = "lt_04.png",
        normalTextColor = Enums.Color.eNormalWhite,
        lightedTextColor = Enums.Color.eTitle,
        defaultSelectTag = self.mChatChanne,
        allowChangeCallback = function(btnTag)
            if btnTag == Enums.ChatChanne.eUnion then
                local guildId = (GuildObj:getGuildInfo() or {}).Id
                if not Utility.isEntityId(guildId) then
                    ui.showFlashView(TR("请先加入帮派"))
                    return false
                end
            end

            return true
        end,
        onSelectChange = function(selectBtnTag)
            if self.mChatChanne == selectBtnTag then
                return
            end

            if selectBtnTag == Enums.ChatChanne.ePrivate then
                self:createChanneInfo()
            else
                self:createChanneMsg(selectBtnTag)
            end
        end,
    })
    self.mTabView:setAnchorPoint(cc.p(0.5, 0))
    self.mTabView:setPosition(self.mMiniSize.width / 2, 0)
    self.mMiniMsgLayer:addChild(self.mTabView)

    -- 监听频道消息改变的事件
    for key, btnObj in pairs(self.mTabView:getTabBtns() or {}) do
        -- 频道小红点
        local function dealRedDotVisible(redDotSprite)
            local tempCount = ChatMng:getUnreadCount(key)
            redDotSprite:setVisible(tempCount > 0)
        end
        local tempSize = btnObj:getContentSize()
        local tempSprite = ui.createBubble({position = cc.p(tempSize.width * 0.8, tempSize.height * 0.8)})
        btnObj:addChild(tempSprite)

        local eventNames = {EventsName.eChatUnreadPrefix .. tostring(key), EventsName.eChatNewMsg}
        Notification:registerAutoObserver(tempSprite, dealRedDotVisible, eventNames)
        dealRedDotVisible(tempSprite)
    end
end

-- 创建消息内容列表
function ChatLayer:createMsgListView()
	self.mMsgLayer:removeAllChildren()

    -- 监控离开消息列表的控件
    local tempNode = cc.Node:create()
    self.mMsgLayer:addChild(tempNode)
    tempNode:registerScriptHandler(function(eventType)
        if eventType == "cleanup" then
            -- 需要删除语音异步任务列表和删除语音播放列表
            VoiceMsgTaskObj:clearTask()
        end
    end)

	local isViewSystem = self.mChatChanne == Enums.ChatChanne.eSystem or self.mChatChanne == Enums.ChatChanne.eGM
	-- 当前聊天频道title的位置
	local titlePos = isViewSystem and cc.p(self.mBgSize.width / 2, self.mBgSize.height - 100) or
        cc.p(self.mBgSize.width / 2, self.mBgSize.height - self.mMiniSize.height - 105)
    -- 列表的大小
	local listViewSize = isViewSystem and cc.size(583, self.mBgSize.height - 155) or
        cc.size(583, self.mBgSize.height - self.mMiniSize.height - 225)

	-- 创建当前聊天频道的title
	local titleNode, titleLabel = ui.createSpriteAndLabel({
		imgName = "lt_06.png",
        labelStr = "",
        fontSize = 24,
        -- fontColor = cc.c3b(0xde, 0x6e, 0x00),
	})
	titleNode:setPosition(titlePos)
	self.mMsgLayer:addChild(titleNode)

	-- 注册刷新频道信息的事件
	local function setMsgListTitle()
		local channeInfo = self:getChanneName(self.mChatChanne, self.mPrivateId)
		if type(channeInfo) == "table" then
			titleLabel:setContent(channeInfo)
		else
			titleLabel:setString(channeInfo)
		end
	end
	Notification:registerAutoObserver(titleNode, setMsgListTitle, {RefrishChanneList})
	setMsgListTitle()

    if isViewSystem or self.mChatChanne == Enums.ChatChanne.ePrivate then
        -- 返回按钮
        local backBtn = ui.newButton({
            normalImage = "lt_20.png",
            clickAction = function()
                -- 创建频道信息页面
                self:createChanneInfo()
            end
        })
        backBtn:setPosition(570, titlePos.y)
        self.mMsgLayer:addChild(backBtn)

        -- 频道小红点
        local function dealRedDotVisible(redDotSprite)
            local tempCount = ChatMng:getUnreadCount()
            redDotSprite:setVisible(tempCount > 0)
        end
        local tempSize = backBtn:getContentSize()
        local tempSprite = ui.createBubble({position = cc.p(tempSize.width * 0.8, tempSize.height * 0.8)})
        backBtn:addChild(tempSprite)
        Notification:registerAutoObserver(tempSprite, dealRedDotVisible, {EventsName.eChatUnreadPrefix, EventsName.eChatNewMsg})
        dealRedDotVisible(tempSprite)
    end

	-- 聊天列表的背景
    local bgImgList = {
        [Enums.ChatChanne.eWorld] = "lt_02.png",
        [Enums.ChatChanne.eUnion] = "lt_02.png",
        [Enums.ChatChanne.ePrivate] = "lt_02.png",
    }
    local msgBgSprite = ui.newScale9Sprite(bgImgList[self.mChatChanne] or "lt_02.png", listViewSize)
    msgBgSprite:setAnchorPoint(cc.p(0.5, 1))
    msgBgSprite:setPosition(320, titlePos.y - 30)
    self.mMsgLayer:addChild(msgBgSprite)

    local chatListView = require("Chat.chatSubView.ChatListView"):create({
        viewSize = cc.size(listViewSize.width, listViewSize.height - 10),
        forbidCleanUp = self.mForbidCleanUp,
        chatChanne = self.mChatChanne,
        onGetNextHistory = function( ... )
            ChatMng:getNextHistory(self.mChatChanne, self.mPrivateId)
        end,
        privateCb = function(selectLayerObj, selectPlayerId)
            if not tolua.isnull(self) then -- 聊天页面没有被销毁
                -- 调整到私聊频道
                self:gotoPrivate(selectPlayerId)
            else -- 否则需要通过恢复聊天页面的方式重新打开
                local tempStr = "Chat.ChatLayer"
                local tempData = LayerManager.getRestoreData(tempStr)
                tempData.privateId = selectPlayerId
                LayerManager.setRestoreData(tempStr, tempData)
            end

            LayerManager.removeLayer(selectLayerObj)
        end
    })
    chatListView:setPosition(listViewSize.width / 2, listViewSize.height / 2)
    msgBgSprite:addChild(chatListView)

    -- 注册关注新消息事件
    Notification:registerAutoObserver(msgBgSprite, function()
    	-- 处理新消息
    	local newMsg = ChatMng:getLastRecData()
        local fromPlayerId = newMsg.FromPlayer and newMsg.FromPlayer.Id
        local toPlayerId = newMsg.ToPlayer and newMsg.ToPlayer.Id

        local isMyMsg = fromPlayerId == PlayerAttrObj:getPlayerInfo().PlayerId
        local isPrivate = self.mChatChanne == Enums.ChatChanne.ePrivate
        local tempPlayerId = isPrivate and isMyMsg and toPlayerId or fromPlayerId
        -- 系统消息添加到本服消息中
        local isNeesSys = (self.mChatChanne == Enums.ChatChanne.eWorld and newMsg.ChannelType == Enums.ChatChanne.eSystem)

        if (newMsg.ChannelType == self.mChatChanne and (isPrivate and tempPlayerId == self.mPrivateId or not isPrivate)) or isNeesSys then
            local fromPlayerId = newMsg.FromPlayer and newMsg.FromPlayer.Id
            if fromPlayerId == PlayerAttrObj:getPlayerInfo().PlayerId then -- 玩家自己发送的消息需要移动到列表的最后
                chatListView:addOneMsgItem(newMsg)
                chatListView:jumpToBottom()
            else
                chatListView:addOneMsgItem(newMsg, true)
            end

            -- 保存当前频道的已读消息的最大Id
            self:saveChanneMaxReadId()
        end
    end, {EventsName.eChatNewMsg})

    -- 注册刷新聊天消息列表的事件
    local eventNameList = {
        RefrishMessagList,
        EventsName.eChatMsgChangePrefix .. tostring(self.mChatChanne) .. (self.mPrivateId or "")
    }
    Notification:registerAutoObserver(msgBgSprite, function()
    	self:refreshMsgListView(chatListView, false)
    end, eventNameList)

    -- 刷新消息列表
    self:refreshMsgListView(chatListView, true)


    if self.mChatChanne == Enums.ChatChanne.eTeam then
        local teamId = PlayerAttrObj:getPlayerAttrByName("TeamId")
        local tempStart, tempEnd = string.find(teamId, "-0000-0000-0000-")
        if teamId ~= EMPTY_ENTITY_ID then
            if tempStart ~= nil and tempEnd ~= nil then
                local quitBtn = ui.newButton({
                    normalImage = "c_28.png",
                    text = TR("退出频道"),
                    clickAction = function()
                        HttpClient:request({
                            moduleName = "Jianghukill",
                            methodName = "ExistNodeChat",
                            svrMethodData = {},
                            callbackNode = self,
                            needWait = false,
                            callback = function(response)
                                -- dump(response, "ssss")
                                ui.showFlashView(TR("已关闭江湖杀聊天"))
                                LayerManager.removeLayer(self)
                            end
                        })
                    end,
                })
                quitBtn:setPosition(cc.p(self.mBgSize.width / 2 + 200, self.mBgSize.height - self.mMiniSize.height - 105))
                self.mMsgLayer:addChild(quitBtn, 11)

                local nodeId = string.sub(teamId, -2, -1) --TeamId最后两位为江湖杀节点ID
                local nodeName = JianghukillMapModel.items[tonumber(nodeId)].name
                titleLabel:setString(TR("%s江湖杀#de6e00[%s]", Enums.Color.eBlackH, nodeName))
            end
        end
    end
end

-- 创建输入框相关控件
function ChatLayer:createEditView()
	self.mEditLayer:removeAllChildren()
    -- 频道列表和系统频道消息不需要显示输入框
    if not self.mChatChanne or self.mChatChanne == Enums.ChatChanne.eSystem or self.mChatChanne == Enums.ChatChanne.eGM or
        self.mChatChanne == Enums.ChatChanne.ePrivate and not self.mPrivateId then
        return
    end
    --
    local chatEditView = require("Chat.chatSubView.ChatEditView"):create({
        viewSize = self.mEditSize,
        channeType = self.mChatChanne,
        sendMsgCb = function(msgStr, voiceStr)
            self:sendMsg(msgStr, voiceStr)
        end,
        getChatCD = function(channeType)
            return self:getChatCD(channeType)
        end
    })
    chatEditView:setPosition(self.mEditSize.width / 2, self.mEditSize.height / 2)
    self.mEditLayer:addChild(chatEditView)
end

-- 创建私聊玩家列表
function ChatLayer:createPrivateListView()
	self.mChanneLayer:removeAllChildren()

    -- 添加按钮的Y坐标
    local addChannePosY = self.mBgSize.height - self.mMiniSize.height - 118
	-- 创建添加聊天按钮
	-- local addChanneBtn = ui.newButton({
	-- 	normalImage = "lt_19.png",
	-- 	clickAction = function()
	-- 		-- 选择私聊玩家
	-- 		self:selectChatPlayer()
	-- 	end
	-- })
	-- addChanneBtn:setPosition(90, addChannePosY)
	-- self.mChanneLayer:addChild(addChanneBtn)

    -- 私聊提示的开关
    --[[
    local hintCheckBox  = ui.newCheckbox({
        normalImage = "c_60.png",
        selectImage = "c_61.png",
        text = TR("关闭私聊提示"),
        textColor = Enums.Color.eLabelText,
        fontSize  = 24,
        imageScale = 0.6,
        callback = function(isSelected)
            ClosePrivateChatHint = isSelected

            local miniChatLayer = ChatBtnLayer.MiniLayer
            if tolua.isnull(miniChatLayer) then
                return
            end
            if ClosePrivateChatHint then
                miniChatLayer:addViewChanne(Enums.ChatChanne.ePrivate)
            else
                miniChatLayer:deleteViewChanne(Enums.ChatChanne.ePrivate)
            end
        end
    })
    hintCheckBox:setPosition(self.mBgSize.width - 120, addChannePosY)
    hintCheckBox:setCheckState(ClosePrivateChatHint)
    self.mChanneLayer:addChild(hintCheckBox) --]]

	-- 频道列表显示区域的大小
	local listViewSize = cc.size(self.mBgSize.width,self.mBgSize.height - self.mMiniSize.height - 100)

	-- 创建频道列表
	local msgListView = ccui.ListView:create()
    msgListView:setContentSize(listViewSize)
    msgListView:setItemsMargin(10)
    msgListView:setBounceEnabled(true)
    msgListView:setAnchorPoint(cc.p(0.5, 0))
    msgListView:setPosition(self.mBgSize.width / 2, 10)
    self.mChanneLayer:addChild(msgListView)

    -- 不在频道列表中显示频道
    local excludeChanneList = {
    	Enums.ChatChanne.eSystem, -- 系统频道
	}

    -- 频道信息数据、置顶频道的个数
    local channeInfoList, topChanneCount = self:getChanneInfoList(excludeChanneList)

    -- 刷新一条频道信息函数前向声明
    local refreshOneChanneItem = nil
    -- 刷新频道信息列表
    local function refreshChanneList()
        -- 更新频道列表数据
        channeInfoList, topChanneCount = self:getChanneInfoList(excludeChanneList)
        -- 列表原来的位置
        local oldInnerSize = msgListView:getInnerContainerSize()
        local oldInnerPos = cc.p(msgListView:getInnerContainerPosition())

        --
        msgListView:removeAllItems()

        for index, item in ipairs(channeInfoList or {}) do
            refreshOneChanneItem(index)
        end

        -- 恢复列表原来的位置
        if math.abs(listViewSize.height - oldInnerSize.height) > 5 then
            ui:restoreListViewPos(msgListView, oldInnerSize, oldInnerPos)
        end
    end

    -- 刷新一条频道信息
    refreshOneChanneItem = function(index)
	    local cellSize = cc.size(listViewSize.width, 131)
	    --
	    local cellData = channeInfoList[index]
        -- 是否已置顶
        local isSetTop = ChatMng:getIsTop(cellData.channeType, cellData.playerId)

	    --
    	local lvItem = msgListView:getItem(index - 1)
	    if not lvItem then
	        lvItem = ccui.Layout:create()
	        lvItem:setContentSize(cellSize)
	        msgListView:insertCustomItem(lvItem, index - 1)
	    end
	    lvItem:removeAllChildren()

	    -- 条目的背景
        local cellBgBtn = ui.newButton({
            normalImage = "c_65.png",
            size = cc.size(582, cellSize.height),
            clickAction = function()
                if cellData.channeType == Enums.ChatChanne.eUnion then
                    local guildId = (GuildObj:getGuildInfo() or {}).Id
                    if not Utility.isEntityId(guildId) then
                        ui.showFlashView(TR("请先加入帮派"))
                        return false
                    end
                end

                -- 创建频道消息页面
                self:createChanneMsg(cellData.channeType, cellData.playerId)
            end
        })
        cellBgBtn:setPressedActionEnabled(false)
        cellBgBtn:setPosition(cellSize.width / 2, cellSize.height / 2)
        lvItem:addChild(cellBgBtn)

	    -- 注册该频道消息改变的事件
	    local eventName = EventsName.eChatMsgChangePrefix .. tostring(cellData.channeType) .. (cellData.playerId or "")
	    Notification:registerAutoObserver(cellBgBtn, function()
	    	local lastItem = ChatMng:getTypeLastData(cellData.channeType, cellData.playerId)

            -- 如果之前还没有消息记录，或之前不在第一个位置，需要刷新整个列表, 否则只需要刷新该条目就可以了
            if not cellData.lastMsg or (index > (cellData.isTop and 1 or (topChanneCount + 1))) then
                cellData.lastMsg = lastItem
                refreshChanneList()
            else
                cellData.lastMsg = lastItem
                refreshOneChanneItem(index)
            end

	    end, {eventName})

	    -- 频道头像
        local headCardPos = cc.p(95, cellSize.height / 2)
	    local headCard = CardNode:create({
	    	allowClick = true,
            onClickCallback = function()
                local worldPos = lvItem:convertToWorldSpace(cc.p(headCardPos.x + 50, headCardPos.y))
                self:createChanneOption(worldPos, cellData.channeType, cellData.playerId, function()
                    -- todo
                end)
            end
	    })
	    headCard:setPosition(headCardPos)
	    lvItem:addChild(headCard)
	    local headImage = self:getChanneHeadImg(cellData.channeType, cellData.playerId)
	    if type(headImage) == "string" then
	    	headCard:setEmpty({}, "c_07.png", headImage)
	    else
	    	headCard:setHero({ModelId = headImage}, {CardShowAttr.eBorder})
	    end
        if isSetTop then
            local tempSprite = ui.newSprite("lt_25.png")
            tempSprite:setAnchorPoint(cc.p(0, 1))
            tempSprite:setPosition(25, cellSize.height + 4)
            lvItem:addChild(tempSprite)
        end

        -- 头像的大小
        local headSize = headCard:getContentSize()

        -- 频道操作标识
        local optionSprite = ui.newSprite("lt_22.png")
        optionSprite:setAnchorPoint(cc.p(1, 0))
        optionSprite:setPosition(headCardPos.x + headSize.width / 2, headCardPos.y - headSize.height / 2)
        lvItem:addChild(optionSprite)

        -- 频道小红点
        local function dealRedDotVisible(redDotSprite)
            local tempCount = ChatMng:getUnreadCount(cellData.channeType, cellData.playerId)
            redDotSprite:setVisible(tempCount > 0)
        end
        local tempSprite = ui.createBubble({position = cc.p(headSize.width * 0.8, headSize.height * 0.8)})
        headCard:addChild(tempSprite)
        local eventNameList = {
            EventsName.eChatUnreadPrefix .. tostring(cellData.channeType),
            EventsName.eChatMsgChangePrefix .. tostring(cellData.channeType) .. (cellData.playerId or "")
        }
        Notification:registerAutoObserver(tempSprite, dealRedDotVisible, eventNameList)
        dealRedDotVisible(tempSprite)

        -- 频道描述信息的位置
	    local nameLabelPos = cc.p(160, 90)
	    -- 频道名字
	    local nameLabel = ui.newLabel({
	        text = "",
            size = 24,
	        -- color = cc.c3b(0x46, 0x22, 0x0d),
	    })
	    nameLabel:setAnchorPoint(cc.p(0, 0.5))
	    nameLabel:setPosition(nameLabelPos)
	    lvItem:addChild(nameLabel)
	    local channeInfo = self:getChanneName(cellData.channeType, cellData.playerId, true)
		if type(channeInfo) == "table" then
			nameLabel:setContent(channeInfo)
		else
			nameLabel:setString(channeInfo)
		end

	    -- 最近一条消息的时间
	    local lastTimeLabel = ui.newLabel({
	        text = cellData.lastMsg and MqTime.getTimeViewStr(cellData.lastMsg.TimeStamp) or "",
	        size = 18,
            color = cc.c3b(0x80, 0x4c, 0x2a),
	        align = cc.TEXT_ALIGNMENT_RIGHT,
	    })
	    lastTimeLabel:setAnchorPoint(cc.p(1, 0.5))
	    lastTimeLabel:setPosition(cellSize.width - 35, nameLabelPos.y)
	    lvItem:addChild(lastTimeLabel)

	    -- 最近一条消息内容
        local tempStr = cellData.lastMsg and self:getMsgDescribe(cellData.lastMsg, 38) or TR("暂无消息")
	    local lastMsgLabel = ui.newLabel({
	        text = ChatMng:faceStrUnpack(tempStr),
            size = 22,
            color = cc.c3b(0x80, 0x4c, 0x2a),
            dimensions = cc.size(cellSize.width - 190, 0),
	    })
	    lastMsgLabel:setImageElementScale(0.3)
	    lastMsgLabel:setAnchorPoint(cc.p(0, 0.5))
	    lastMsgLabel:setPosition(nameLabelPos.x, 40)
	    lvItem:addChild(lastMsgLabel)
    end

	-- 注册刷新频道列表的事件
    local eventNameList = {
        RefrishChanneList,
        EventsName.eChatPrivateChanged,
    }
	Notification:registerAutoObserver(msgListView, refreshChanneList, eventNameList)
    refreshChanneList()

    -- 注册关注新消息事件
    Notification:registerAutoObserver(msgListView, function()
    	-- 处理新消息
    	local newMsg = ChatMng:getLastRecData()
    	if table.indexof(excludeChanneList, newMsg.ChannelType) then
    		return
    	end

    	local newIsPrivate = newMsg.ChannelType == Enums.ChatChanne.ePrivate
        if not newIsPrivate then  -- 只处理私聊消息
            return
        end

    	local playerId = PlayerAttrObj:getPlayerInfo().PlayerId
        local msgPlayerId = newIsPrivate and (newMsg.FromPlayer.Id ~= playerId and newMsg.FromPlayer.Id or newMsg.ToPlayer.Id)

    	-- 查找在频道信息中的index
    	local channeIndex = nil
    	for index, item in pairs(channeInfoList) do
    		if item.channeType == newMsg.ChannelType and (not newIsPrivate or msgPlayerId == item.playerId) then
    			channeIndex = index
    			break
    		end
    	end

    	-- 添加新的频道
    	if not channeIndex then
    		-- 刷新频道列表
    		refreshChanneList()
    	else
            local channeData = channeInfoList[channeIndex]
            if not channeData.lastMsg or (channeIndex > (channeData.isTop and 1 or (topChanneCount + 1))) then
                -- 刷新频道列表
                refreshChanneList()
            else
                if not self:isEnemyMsg(newMsg) then
                    -- 刷新列表中的一条
                    channeData.lastMsg = newMsg
                    refreshOneChanneItem(channeIndex)
                end
            end
    	end
    end, {EventsName.eChatNewMsg})
end

-- 获取一条消息的概要
function ChatLayer:getMsgDescribe(msgItem, viewMax)
    -- 是否是玩家自己发的消息
    local isSelf = msgItem.FromPlayer and msgItem.FromPlayer.Id == PlayerAttrObj:getPlayerInfo().PlayerId
    -- 发送玩家和接收玩家的信息
    local fromExt = msgItem.FromPlayer and msgItem.FromPlayer.ExtendInfo

    local msgStr = msgItem.Message
    local msgLength = ChatMng:getMsgLength(msgStr)
    if msgLength > viewMax then
        msgStr = ChatMng:getSubMsg(msgStr, viewMax - 3, false) .. "..."
    end

    if msgItem.ChannelType == Enums.ChatChanne.eSystem or msgItem.ChannelType == Enums.ChatChanne.eGM then
        return msgStr
    elseif isSelf then
        local toExt = msgItem.ToPlayer and msgItem.ToPlayer.ExtendInfo
        return TR("我说：") .. msgStr
    else
        return TR("%s说：", fromExt.Name) .. msgStr
    end
end

-- 获取Mini消息区域需要显示的消息数据列表
function ChatLayer:getMiniMsgData(viewChanneList)
	local retList = {}
	-- mini区域需要显示频道列表
	local defaultData = nil
	for _, channe in pairs(viewChanneList) do
        local tempList = ChatMng:getTypeChatData(channe)

        -- 如果沒有未读消息，mini窗口中默认显示的消息
        local tempCount = #tempList
        if (tempCount > 0) and (not defaultData or defaultData.TimeStamp < tempList[tempCount].TimeStamp) then
            defaultData = tempList[tempCount]
        end

        for _, item in ipairs(tempList or {}) do
            if ChatMng:msgIsUnread(channe, item.Id) and not self:isEnemyMsg(item) then
                table.insert(retList, item)
            end
        end
    end

    if defaultData and #retList == 0 and not self:isEnemyMsg(defaultData) then
    	table.insert(retList, defaultData)
    end

    table.sort(retList, function(item1, item2)
        return item1.TimeStamp < item2.TimeStamp
    end)

    return retList
end

-- 刷新当前选中频道的聊天信息
--[[
-- 参数
	chatListView: 显示聊天内容的 ChatListView 对象
    jumpToBottom: 是否需要跳到列表的末尾, 默认为true
]]
function ChatLayer:refreshMsgListView(chatListView, jumpToBottom)
    local tempChanneList = {self.mChatChanne}
    -- 本服消息同时显示系统消息
    if self.mChatChanne == Enums.ChatChanne.eWorld then
        table.insert(tempChanneList, Enums.ChatChanne.eSystem)
    end
    local infoList = {}
    for _, channeType in pairs(tempChanneList) do
        local tempList = ChatMng:getTypeChatData(channeType, self.mPrivateId)
        table.insertto(infoList, tempList)

        -- 添加通过avater频道返回的聊天信息
        local tempList = ChatMng:getTypeChatDataAvatar(channeType, self.mPrivateId)
        table.insertto(infoList, tempList)
    end
    table.sort(infoList, function(item1, item2)
        return item1.TimeStamp < item2.TimeStamp
    end)

    chatListView:refreshMsgListView(infoList, jumpToBottom ~= false)
end

-- 创建频道列表条目操作页面
function ChatLayer:createChanneOption(worldPos, channeType, playerId, closeCallback)
    -- 页面元素父节点
    local tempLayer = ui.newStdLayer()
    self:addChild(tempLayer)
    --
    local tempPos = cc.p(tempLayer:convertToNodeSpace(worldPos))
    local btnSize = ui.getImageSize("lt_23.png")

    -- 是否已置顶
    local isSetTop = ChatMng:getIsTop(channeType, playerId)

    -- 上面按钮
    local topOptBtn = ui.newButton({
        normalImage = isSetTop and "lt_30.png" or "lt_23.png",
        text = "",
        titlePosRateX = 0.51,
        clickAction = function()
            closeCallback()
            tempLayer:removeFromParent()

            ChatMng:setIsTop(channeType, playerId, not isSetTop)
            Notification:postNotification(RefrishChanneList)
        end
    })
    topOptBtn:setPressedActionEnabled(false)
    topOptBtn:setPosition(tempPos.x + btnSize.width / 2, tempPos.y + btnSize.height / 2 + 1)
    tempLayer:addChild(topOptBtn)

    -- 下面按钮
    local bottomOptBtn = ui.newButton({
        normalImage = channeType == Enums.ChatChanne.eTeam and "lt_24.png" or "lt_31.png",
        text = "",
        titlePosRateX = 0.51,
        clickAction = function()
            closeCallback()
            tempLayer:removeFromParent()

            ChatMng:deleteHistory(channeType, playerId)
        end
    })
    bottomOptBtn:setPressedActionEnabled(false)
    bottomOptBtn:setPosition(tempPos.x + btnSize.width / 2, tempPos.y - btnSize.height / 2 - 1)
    tempLayer:addChild(bottomOptBtn)

    ui.registerSwallowTouch({
        node = tempLayer,
        allowTouch = true,
        beganEvent = function(touch, event)
            return true
        end,
        endedEvent = function (touch, event)
            if not ui.touchInNode(touch, topOptBtn) and not ui.touchInNode(touch, bottomOptBtn) then
                closeCallback()
                tempLayer:removeFromParent()
            end
        end,
    })
end

-- 选择私聊玩家
function ChatLayer:selectChatPlayer()
    local tempOrder = self.mForbidCleanUp and Enums.ZOrderType.ePopLayer
    LayerManager.addLayer({
        name = "Chat.ChatSelectLayer",
        zOrder = self.mForbidCleanUp and Enums.ZOrderType.ePopLayer or nil,
        cleanUp = false,
        data = {
            forbidCleanUp = self.mForbidCleanUp,
            playerList = self.mFriendList,
            selectCb = function(selectLayerObj, selectPlayerId)
                if not tolua.isnull(self) then -- 聊天页面没有被销毁
                    -- 调整到私聊频道
                    self:gotoPrivate(selectPlayerId)
                else -- 否则需要通过恢复聊天页面的方式重新打开
                    local tempStr = "Chat.ChatLayer"
                    local tempData = LayerManager.getRestoreData(tempStr)
                    tempData.privateId = selectPlayerId
                    LayerManager.setRestoreData(tempStr, tempData)
                end

                LayerManager.removeLayer(selectLayerObj)
            end
        },
    })
end

-- 获取频道信息数据
--[[
-- 参数
	excludeChanne:不在频道列表中显示频道
-- 第一个返回值的数据结构为
	{
		{
			channeType: 频道类型
			playerId: 私聊频道的玩家Id
			lastMsg: 最近一条消息
		}
	}
-- 第二个返回值，置顶频道的个数
]]
function ChatLayer:getChanneInfoList(excludeChanne)
	local retList, topCount = {}, 0

	local tempList = {
	    -- Enums.ChatChanne.eWorld, -- 世界频道
	    -- Enums.ChatChanne.eCrossServer, -- 跨服频道
	    -- Enums.ChatChanne.eUnion, -- 帮派频道
	    -- Enums.ChatChanne.eSystem, -- 系统频道
	    Enums.ChatChanne.ePrivate, -- 私聊频道
	}
    -- if PlayerAttrObj:getPlayerInfo().IsInTeam then
    --     table.insert(tempList, Enums.ChatChanne.eTeam) -- 组队频道
    -- end

	for _, channe in ipairs(tempList) do
		if not table.indexof(excludeChanne, channe) then
			if channe == Enums.ChatChanne.ePrivate then
				for _, privateId in pairs(ChatMng:getPrivateIdList()) do
					local lastItem = ChatMng:getTypeLastData(channe, privateId)
					if not lastItem or not next(lastItem) then
						ChatMng:getNextHistory(channe, privateId)
					end
                    local isTop = ChatMng:getIsTop(channe, privateId)
                    topCount = topCount + (isTop and 1 or 0)
					table.insert(retList, {
						channeType = channe,
						playerId = privateId,
						lastMsg = lastItem,
                        isTop = isTop,
					})
				end
			else
				local lastItem = ChatMng:getTypeLastData(channe)
				if not lastItem or not next(lastItem) then
					ChatMng:getNextHistory(channe)
				end
                local isTop = ChatMng:getIsTop(channe)
                topCount = topCount + (isTop and 1 or 0)
				table.insert(retList, {
					channeType = channe,
					playerId = nil,
					lastMsg = lastItem,
                    isTop = isTop,
				})
			end
		end
	end

	-- 排序
	table.sort(retList, function(item1, item2)
        -- 置顶的频道显示在最前面面
        local itemIsTop1 = item1.isTop == true
        local itemIsTop2 = item2.isTop == true
        if itemIsTop1 ~= itemIsTop2 then
            return itemIsTop1
        end

		-- 根据最后一条消息的时间排序
		local timeStamp1 = item1.lastMsg and item1.lastMsg.TimeStamp or 0
		local timeStamp2 = item2.lastMsg and item2.lastMsg.TimeStamp or 0

        return timeStamp1 > timeStamp2
    end)

	return retList, topCount
end

-- 获取频道名称信息
function ChatLayer:getChanneName(chatChanne, privateId, channeListUse)
	if chatChanne == Enums.ChatChanne.ePrivate then
		local retList = {}
		local playerInfo = self:getPlayerInfo(privateId)

		-- 玩家名
		table.insert(retList, {
            text = (playerInfo.Name or TR("陌生人")) .. " ",
            formatInfo = {
                color = cc.c3b(0x46, 0x22, 0x0d),
            },
        })


        -- 公会名字
        if playerInfo.GuildName and  playerInfo.GuildName ~= "" then
            table.insert(retList, {
                text = string.format(" [%s] ", playerInfo.GuildName),
                formatInfo = {
                    color = cc.c3b(0xde, 0x6e, 0x00),
                },
            })
        end

		-- 玩家Vip等级
        if playerInfo.Vip and playerInfo.Vip > 0 then
            table.insert(retList, {
                customCb = function( ... )
                    local vipNode = ui.createVipNode(playerInfo.Vip)
                    vipNode:setScale(0.8)
                    return vipNode
                end
            })
	    end
	    return retList
	else
		local channeName = Enums.ChatChanneName[chatChanne]
		local extInfo = ""
		if chatChanne == Enums.ChatChanne.eWorld then
			extInfo = TR("世界频道") -- Player:getSelectServer().ServerName
		elseif chatChanne == Enums.ChatChanne.eUnion then
			extInfo = (GuildObj:getGuildInfo() or {}).Name or TR("暂无帮派")
		end

        local retList = {}
        if channeListUse or extInfo == "" then
            table.insert(retList, {
                text = extInfo ~= "" and extInfo or channeName,
                formatInfo = {
                    color = cc.c3b(0x46, 0x22, 0x0d),
                },
            })
        else
            -- 帮派势力标志
            local forceId = (GuildObj:getGuildInfo() or {}).ForceId
            if Enums.JHKSamllPic[forceId] and chatChanne == Enums.ChatChanne.eUnion then
                table.insert(retList, {
                    customCb = function( ... )
                        local forceSprite = ui.newSprite(Enums.JHKSamllPic[forceId])
                        return forceSprite
                    end
                })
            end
            
            table.insert(retList, {
                text = channeName,
                formatInfo = {
                    color = cc.c3b(0x46, 0x22, 0x0d),
                },
            })

            table.insert(retList, {
                text = string.format(" [%s] ", extInfo),
                formatInfo = {
                    color = cc.c3b(0xde, 0x6e, 0x00),
                },
            })
        end

        return retList
	end
end

-- 获取频道的头像
--[[
]]
function ChatLayer:getChanneHeadImg(chatChanne, privateId)
	if chatChanne == Enums.ChatChanne.ePrivate then
		local playerInfo = self:getPlayerInfo(privateId)
		return playerInfo.HeadImageId or 12010001
	else
        local tempList = {
            [Enums.ChatChanne.eWorld] = "lt_14.png", -- 世界频道
            [Enums.ChatChanne.eTeam] = "lt_14.png", -- 组队频道
            [Enums.ChatChanne.eUnion] = "lt_14.png", -- 帮派频道
            [Enums.ChatChanne.eSystem] = "lt_15.png", -- 系统频道
            [Enums.ChatChanne.eCrossServer] = "lt_15.png", -- 跨服频道
        }
		return tempList[chatChanne] or "lt_15.png"
	end
end

-- 获取当前频道的冷却时间
function ChatLayer:getChatCD(channelType)
    local tempList = {
        [Enums.ChatChanne.eWorld] = 10, -- 世界频道
        [Enums.ChatChanne.eCrossServer] = 10, -- 跨服频道
        [Enums.ChatChanne.eHorn] = 30, -- 跨服频道
        [Enums.ChatChanne.eTeam] = 2, -- 组队频道
        [Enums.ChatChanne.eUnion] = 2, -- 帮派频道
        [Enums.ChatChanne.ePrivate] = 2, -- 私聊频道
        [Enums.ChatChanne.eSystem] = 2, -- 系统频道
    }

    local ret = tempList[channelType or self.mChatChanne] or 10

    return ret
end

-- 发送消息函数
function ChatLayer:sendMsg(msgStr, voiceStr)
    if self.mChatChanne == Enums.ChatChanne.ePrivate then
        if self.mPrivateId then
            ChatMng:sendMessage(self.mChatChanne, msgStr, voiceStr or "", self.mPrivateId)
        else
            ui.showFlashView(TR("请选择一个好友私聊吧。"))
            return
        end
    else
        ChatMng:sendMessage(self.mChatChanne, msgStr, voiceStr or "")
    end
end

-- 保存当前频道的已读消息的最大Id
function ChatLayer:saveChanneMaxReadId()
    -- 切换页签前修改已读消息的最大Id
    local lastData = ChatMng:getTypeLastData(self.mChatChanne, self.mPrivateId)

    if lastData then
        ChatMng:setReadMsgId(self.mChatChanne, lastData.Id, self.mPrivateId)
    end
end

-- 根据玩家Id获取玩家信息
--[[
-- 参数
	playerId: 玩家Id
-- 返回值
	{
		HeadImageId:玩家头像模型Id,
        PlayerId:  	玩家的PlayerId,
        Name:      	玩家的名字,
        LV:        	玩家等级,
        Vip:		玩家Vip等级
        FAP:       	玩家战斗力
	}
]]
function ChatLayer:getPlayerInfo(playerId)
	-- 查找私聊频道消息
	local lastMsgItem = ChatMng:getTypeLastData(Enums.ChatChanne.ePrivate, playerId)
	if not lastMsgItem or not next(lastMsgItem) then
        local playerInfo = FriendObj:getPlayerInfo(playerId)
        return playerInfo or {}
	end

	-- 是否是玩家自己发的消息
    local isSelf = lastMsgItem.FromPlayer and lastMsgItem.FromPlayer.Id == PlayerAttrObj:getPlayerInfo().PlayerId

    local tempData = isSelf and lastMsgItem.ToPlayer or lastMsgItem.FromPlayer
    local retData = {
    	HeadImageId = tempData.ExtendInfo.HeadImageId,
        PlayerId = tempData.Id,
        Name = tempData.ExtendInfo.Name,
        LV = tempData.ExtendInfo.Lv,
        Vip = tempData.ExtendInfo.Vip,
        FAP = tempData.ExtendInfo.Fap,
        FashionModelId = tempData.ExtendInfo.FashionModelId,
        GuildId = tempData.ExtendInfo.GuildId,
        GuildName = tempData.ExtendInfo.GuildName,
        guideId = tempData.ExtendInfo.guideId,
        guideName = tempData.ExtendInfo.guideName,
        guidePostId = tempData.ExtendInfo.guidePostId,
	}

	return retData
end

-- 跳转到私聊频道
function ChatLayer:gotoPrivate(playerId)
    ChatMng:addPrivateId(playerId)
    self:createChanneMsg(Enums.ChatChanne.ePrivate, playerId)
end

-- 是否是黑名单玩家的消息
function ChatLayer:isEnemyMsg(msgItem)
    local channelType = msgItem and msgItem.ChannelType
    local playerId = msgItem and msgItem.FromPlayer and msgItem.FromPlayer.Id
    if not playerId then
        return
    end

    return EnemyObj:isEnemyPlayer(playerId)
end

return ChatLayer
