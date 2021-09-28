--[[
文件名: ChatSelectLayer.lua
描述: 选择聊天的私聊玩家页面
创建人: liaoyuangang
创建时间: 2017.03.06
-- ]]

local ChatSelectLayer = class("ChatSelectLayer", function(params)
    return display.newLayer(cc.c4b(0, 0, 0, 128))
end)

--[[
-- 参数 params中的各项为
	{
		forbidCleanUp = false, -- 是否禁止该页面跳转到其他页面时LayerManager.addLayer函数的cleanUp参数为true, 默认为false
		selectCb = nil, -- 选中玩家的回调函数,参数为: (layerObj, selectPlayerId)
		playerList = {
			{
				HeadImageId:玩家头像模型Id,
	            PlayerId:  好友的PlayerId,
	            Name:      好友的名字,
	            LV:        好友等级,
	            Vip:玩家等级
	            FAP:       好友战斗力      
	            IsActive:  是否在线,
	            CanSendSTA:能否赠送耐力
			},
			...
		}
	}
]]
function ChatSelectLayer:ctor(params)
	params = params or {}
	-- 屏蔽下层点击事件
    ui.registerSwallowTouch({node = self})

    -- 是否禁止该页面跳转到其他页面时LayerManager.addLayer函数的cleanUp参数为true, 默认为false
    self.mForbidCleanUp = params.forbidCleanUp
    -- 
    self.selectCb = params.selectCb

    -- 好友数据列表
    self.mFriendList = FriendObj:getFriendList()

    -- 页面背景的大小
    self.mBgSize = cc.size(604, 816)

    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer) 

    -- 初始化页面控件
	self:initUI()

	-- 请求好友列表
	FriendObj:requestGetFriendList()
end

-- 初始化页面控件
function ChatSelectLayer:initUI()
	-- 创建界面背景
    self.mBgSprite = ui.newScale9Sprite("mrjl_02.png", self.mBgSize)
    self.mBgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(self.mBgSprite)

    -- 触摸结束事件函数
    local function onEndedEvent(touch, event)
    	if not ui.touchInNode(touch, self.mBgSprite) then
            LayerManager.removeLayer(self)
        end
    end
    ui.registerSwallowTouch({
    	node = self.mBgSprite, 
    	endedEvent = onEndedEvent
    })

    -- 标题
    local bgSize = self.mBgSprite:getContentSize()
    local titleLabel = ui.newLabel({
        text = TR("好友选择"),
        size = Enums.Fontsize.eTitleDefault,
        color = cc.c3b(0xff, 0xee, 0xd0),
        outlineColor = cc.c3b(0x42, 0x2d, 0x25),
    })
    titleLabel:setAnchorPoint(cc.p(0.5, 0.5))
    titleLabel:setPosition(bgSize.width*0.5, bgSize.height - 36)
    self.mBgSprite:addChild(titleLabel)

    -- 关闭按钮
    self.mCloseBtn = ui.newButton({
        normalImage = "c_29.png",
        clickAction = function()
            LayerManager.removeLayer(self)
        end,
    })
    self.mCloseBtn:setPosition(self.mBgSize.width - 38, self.mBgSize.height - 35)
    self.mBgSprite:addChild(self.mCloseBtn)

    -- 创建玩家的列表控件
    self:createListView()
end

-- 创建显示玩家的列表控件
function ChatSelectLayer:createListView()
    -- 列表背景
    local listBg = ui.newScale9Sprite("c_17.png", cc.size(550, 700))
    listBg:setPosition(self.mBgSize.width*0.5, self.mBgSize.height*0.48)
    self.mBgSprite:addChild(listBg)
    -- 聊天列表
    self.mListView = ccui.ListView:create()
    self.mListView:setContentSize(cc.size(550, 690))
    self.mListView:setItemsMargin(10)
    self.mListView:setBounceEnabled(true)
    self.mListView:setAnchorPoint(cc.p(0.5, 0.5))
    self.mListView:setPosition(self.mBgSize.width*0.5, self.mBgSize.height*0.48)
    self.mBgSprite:addChild(self.mListView)

    Notification:registerAutoObserver(self.mListView, function()
        self.mFriendList = FriendObj:getFriendList()
        self:refreshListView()
    end, {EventsName.eFriendChanged})
end

-- 刷新玩家列表
function ChatSelectLayer:refreshListView()
	self.mListView:removeAllItems()
	-- 
	for index, item in ipairs(self.mFriendList) do
		self:refreshOneFriendItem(index)
	end
end

-- 刷新一条好友信息
function ChatSelectLayer:refreshOneFriendItem(index)
	local cellData = self.mFriendList[index] 
	if not cellData then
		return 
	end

	-- 列表条目的大小
	local cellSize = cc.size(550, 130)
	-- 获取或创建列表条目父对象
	local lvItem = self.mListView:getItem(index - 1)
    if not lvItem then
        lvItem = ccui.Layout:create()
        lvItem:setContentSize(cellSize)
        self.mListView:insertCustomItem(lvItem, index - 1)
    end
    lvItem:removeAllChildren()

    -- 列表条目背景
    local cellBgSprite = ui.newScale9Sprite("c_18.png", cc.size(cellSize.width - 20, cellSize.height))
    cellBgSprite:setPosition(cellSize.width / 2, cellSize.height / 2)
    lvItem:addChild(cellBgSprite)

    -- 头像
    local headCard = CardNode:create({
        allowClick = true,
        onClickCallback = function()
            if self.mForbidCleanUp then
                -- ui.showFlashView(TR("当前正在组队或战斗中，不能查看其他玩家阵容"))
                return 
            end

            -- Todo
        end
    })
    headCard:setHero({ModelId = cellData.HeadImageId, FashionModelID = cellData.FashionModelId, IllusionModelId = cellData.IllusionModelId, pvpInterLv = cellData.DesignationId}, {CardShowAttr.eBorder})
    headCard:setPosition(cc.p(70, cellSize.height / 2))
    lvItem:addChild(headCard)

    -- -- 结缘的标识
    -- if cellData.MarryPlayerId ==  PlayerAttrObj:getPlayerInfo().PlayerId then
    --     --添加玩家关系logo
    --     local tempSprite = ui.newSprite("c_26.png")
    --     tempSprite:setAnchorPoint(cc.p(0, 1))
    --     tempSprite:setPosition(0, 100)
    --     headCard:addChild(tempSprite)
    -- end

    -- 名字
    local nameLabel = ui.newLabel({
        text = TR("%s  %s%d级", cellData.Name, "#d17b00", cellData.Lv),
        size = 24,
        color = cc.c3b(0x46, 0x22, 0x0d),
    })
    nameLabel:setAnchorPoint(cc.p(0, 0.5))
    nameLabel:setPosition(130, 90)
    lvItem:addChild(nameLabel)

    -- 战斗力
    local FAPStr = Utility.numberFapWithUnit(cellData.FAP)
    local FAPLabel = ui.newLabel({
        text = TR("战斗力:%s%s","#20781b", FAPStr),
        size = 24,
        color = cc.c3b(0x46, 0x22, 0x0d),
    })
    FAPLabel:setAnchorPoint(cc.p(0, 0.5))
    FAPLabel:setPosition(130, 40)
    lvItem:addChild(FAPLabel)

    -- -- 离线时间
    -- local timeStr = MqTime.toFormat(cellData.LeaveTime - Player:getCurrentTime())
    -- local activeLabel = ui.newLabel({
    --     text = cellData.IsActive and TR("在线") or TR("已离线%s", timeStr),
    --     size = 20,
    --     color = cellData.IsActive and cc.c3b(0x46, 0x22, 0x0d) or cc.c3b(0x46, 0x22, 0x0d),
    -- })
    -- activeLabel:setPosition(350, 65)
    -- lvItem:addChild(activeLabel)

    -- 添加私聊按钮
    local agreeBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("私聊"),
        fontSize = 24,
        clickAction = function()
            if self.selectCb then
                self.selectCb(self, cellData.PlayerId)
            else
                LayerManager.removeLayer(self)
                LayerManager.addLayer({
                    name = "Chat.ChatLayer",
                    data = {
                        chatChanne = Enums.ChatChanne.ePrivate,
                        privateId = cellData.PlayerId,
                    },
                    cleanUp = false
                })
            end
        end
    })
    agreeBtn:setPosition(cellSize.width - 80, cellSize.height / 2)
    lvItem:addChild(agreeBtn)
end

return ChatSelectLayer