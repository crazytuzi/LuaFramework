--[[
	文件名：ShengyuanWarsDlgChatLayer.lua
	描述：据点内的聊天页面
	创建人：peiyaoqiang
	创建时间：2016.10.13
--]]
local ShengyuanWarsDlgChatLayer = class("ShengyuanWarsDlgChatLayer", function(params)
	return cc.Layer:create()
end)


-- 初始化函数
--[[
	params: 参数列表
	{
	}
--]]
function ShengyuanWarsDlgChatLayer:ctor(params)
	-- 屏蔽点击事件
	ui.registerSwallowTouch({node = self})

	-- 创建原始界面
	self:initLayer()
end

-- 初始化界面
--[[
	无参数
--]]
function ShengyuanWarsDlgChatLayer:initLayer()
    local popSprite = require("commonLayer.PopBgLayer").new({
        title = TR("团队交流"),
        bgSize = cc.size(610, 850),
        closeAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self:addChild(popSprite)

    self.bgSprite = popSprite.mBgSprite
    self.bgSize = self.bgSprite:getContentSize()

    -- 添加Tab分页
    local tabItems = {
        {tag = 1, text = TR("快捷")},
        {tag = 2, text = TR("聊天")},
        {tag = 3, text = TR("战绩")},
        {tag = 4, text = TR("神符")},
    }
    self.tabHeight = self.bgSize.height - 150
    self.tabSize = cc.size(self.bgSize.width - 50, self.tabHeight)

    local function cellOfPages(tag)
        if (self.currLayer ~= nil) then
            self.currLayer:removeFromParent()
            self.currLayer = nil
            self.msgEditBox = nil
        end
        
        if (tag == 1) then
            self:createQuickChatLayer(self.bgSprite, self.bgSize)
        elseif (tag == 2) then
            self:createChatLayer(self.bgSprite, self.bgSize)
        elseif (tag == 3) then
            ShengyuanWarsHelper:playerViewBattle(function(data)
                    ShengyuanWarsHelper.reportList = data or {}
                    self:createReportLayer(self.bgSprite, self.bgSize)
                end)
        elseif (tag == 4) then
            self:createBuffLayer(self.bgSprite, self.bgSize)
        end
    end

    local tabLayer = ui.newTabLayer({
        normalImage = "c_51.png",
        lightedImage = "c_50.png",
        viewSize = cc.size(self.tabSize.width, 80),
        needLine = false,
        btnInfos = tabItems,
        defaultSelectTag = 1,
        onSelectChange = cellOfPages,
        })
    tabLayer:setAnchorPoint(cc.p(0.5, 1))
    tabLayer:setPosition(self.bgSize.width * 0.5, self.bgSize.height - 50)
    self.bgSprite:addChild(tabLayer)

    -- 显示线条
    local lineSprite = ui.newSprite("c_20.png")
    lineSprite:setScaleX(0.88)
    lineSprite:setPosition(self.bgSize.width * 0.5, self.bgSize.height - 120)
    self.bgSprite:addChild(lineSprite)

    -- 注册退出界面事件，隐藏输入框
    self:onNodeEvent("exit", function ()
        if self.msgEditBox then
            self.msgEditBox:setVisible(false)
        end
    end)

    ------------------------------------------------------------
    -- 比赛结束后关闭自身
    Notification:registerAutoObserver(ShengyuanWarsUiHelper:getOneEmptyNode(self), 
        function (node, info)
            LayerManager.removeLayer(self)
        end, {ShengyuanWarsHelper.Events.eShengyuanWarsFightResult})
end

----------------------------------------------------------------------------------------------------

-- 创建快捷发言界面
function ShengyuanWarsDlgChatLayer:createQuickChatLayer(parent, parentSize)
    local tmpSize = self.tabSize
    local tmpLayer = cc.LayerColor:create(cc.c4b(255, 0, 0, 0))
    tmpLayer:setContentSize(tmpSize)
    tmpLayer:setIgnoreAnchorPointForPosition(false)
    tmpLayer:setAnchorPoint(cc.p(0.5, 0))
    tmpLayer:setPosition(cc.p(parentSize.width * 0.5, 20))
    parent:addChild(tmpLayer)
    self.currLayer = tmpLayer

    -- 显示列表背景
    local listBgSprite = ui.newScale9Sprite("c_17.png", cc.size(tmpSize.width, tmpSize.height))
    listBgSprite:setAnchorPoint(cc.p(0.5, 0))
    listBgSprite:setPosition(tmpSize.width * 0.5, 0)
    tmpLayer:addChild(listBgSprite)

    -- 添加文字列表
    local listBgSize = cc.size(tmpSize.width - 20, tmpSize.height - 20)
    local listView = ccui.ListView:create()
    listView:setContentSize(listBgSize)
    listView:setPosition(10, 10)
    listView:setItemsMargin(5)
    listView:setBounceEnabled(true)
    --listView:setTouchEnabled(false)     -- 为了减少列表拖动导致误点的问题，这里屏蔽拖动（所有文字暂时没超过一屏）
    tmpLayer:addChild(listView)

    -- 辅助函数：添加聊天信息
    local function createChatItem(strText)
        local widgetWidth = listBgSize.width
        local widgetHeight = 60
        local widget = ccui.Widget:create()
        widget:setContentSize(cc.size(widgetWidth, widgetHeight))

        -- 创建背景图
        local textBgSprite = ui.newScale9Sprite("c_25.png", cc.size(widgetWidth - 60, widgetHeight - 8))
        textBgSprite:setAnchorPoint(cc.p(0.5, 0.5))
        textBgSprite:setPosition(cc.p(widgetWidth / 2, widgetHeight / 2))
        widget:addChild(textBgSprite)

        -- 创建Label
        local talkLabel = ui.newLabel({
            text = strText,
            size = 22,
        })
        talkLabel:setAnchorPoint(cc.p(0.5, 0.5))
        talkLabel:setPosition(cc.p(widgetWidth / 2, widgetHeight / 2))
        widget:addChild(talkLabel, 1)

        -- 发送按钮
        local sendBtn = ui.newButton({
            normalImage = "c_83.png",
            size = cc.size(widgetWidth - 100, widgetHeight - 10),
            position = cc.p(widgetWidth / 2, widgetHeight / 2),
            clickAction = function()
                print(strText)
                ShengyuanWarsHelper:chatToAll(strText, function ()
                        LayerManager.removeLayer(self)
                    end)
            end,
        })
        widget:addChild(sendBtn)

        return widget
    end
    local tmpTextList = {}
    for _,v in pairs(GoddomainChatRelation.items) do
        table.insert(tmpTextList, v)
    end
    table.sort(tmpTextList, function (a, b)
            return a.ID < b.ID
        end)
    for _,v in ipairs(tmpTextList) do
        listView:pushBackCustomItem(createChatItem(v.chatText))
    end
end

-- 创建聊天界面
function ShengyuanWarsDlgChatLayer:createChatLayer(parent, parentSize)
    local tmpSize = self.tabSize
    local tmpLayer = cc.LayerColor:create(cc.c4b(255, 0, 0, 0))
    tmpLayer:setContentSize(tmpSize)
    tmpLayer:setIgnoreAnchorPointForPosition(false)
    tmpLayer:setAnchorPoint(cc.p(0.5, 0))
    tmpLayer:setPosition(cc.p(parentSize.width * 0.5, 20))
    parent:addChild(tmpLayer)
    self.currLayer = tmpLayer

    -- 显示列表背景
    local listBgSprite = ui.newScale9Sprite("c_17.png", cc.size(tmpSize.width, tmpSize.height - 80))
    listBgSprite:setAnchorPoint(cc.p(0.5, 0))
    listBgSprite:setPosition(tmpSize.width * 0.5, 80)
    tmpLayer:addChild(listBgSprite)

    -- 添加文字列表
    local listBgSize = cc.size(tmpSize.width - 20, tmpSize.height - 100)
    local listView = ccui.ListView:create()
    listView:setContentSize(listBgSize)
    listView:setPosition(10, 90)
    listView:setItemsMargin(5)
    listView:setBounceEnabled(true)
    tmpLayer:addChild(listView)

    -- 添加一个空白Node（为了避免后续消息无法显示的问题）
    local spaceNode = ccui.Widget:create()
    spaceNode:setContentSize(cc.size(listBgSize.width, 1))
    listView:pushBackCustomItem(spaceNode)

    -- 辅助函数：添加聊天信息
    local function createChatItem(chatItem)
        local widget = ccui.Widget:create()
        local widgetWidth = listBgSize.width

        local textBgImg, imgX, labelX, labelAp = "lt_11.png", 0, 25, cc.p(0, 1)
        local nameStr = chatItem.name or TR("系统消息")
        if (chatItem.isSelf ~= nil) and (chatItem.isSelf == true) then
            nameStr = TR("我")
            textBgImg, imgX, labelX, labelAp = "lt_12.png", (widgetWidth), (widgetWidth - 25), cc.p(1, 1)
        end
        local labelColor = cc.c3b(0x46, 0x22, 0x0d)
        if (nameStr == TR("系统消息")) then
            labelColor = Enums.Color.eNormalGreen
        end

        -- 创建Label
        local talkLabel = ui.newLabel({
            text = "[" .. nameStr .. "]:" .. chatItem.message,
            color = labelColor,
            size = 22,
            dimensions = cc.size(widgetWidth - 100, 0),
            align = cc.TEXT_ALIGNMENT_LEFT,
            valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
        })
        talkLabel:setAnchorPoint(labelAp)
        talkLabel:setPosition(cc.p(0, 0))
        widget:addChild(talkLabel, 1)

        -- 读取Label的高度，重设背景大小
        local labelH = talkLabel:getContentSize().height
        local widgetHeight = labelH + 40
        widget:setContentSize(cc.size(widgetWidth, widgetHeight))
        talkLabel:setPosition(cc.p(labelX, widgetHeight - 20))

        -- 创建背景图
        local textBgSprite = ui.newScale9Sprite(textBgImg, cc.size(widgetWidth - 60, widgetHeight - 10))
        textBgSprite:setAnchorPoint(labelAp)
        textBgSprite:setPosition(cc.p(imgX, widgetHeight - 5))
        widget:addChild(textBgSprite)

        return widget
    end

    -- 显示文字框
    self.msgEditBox = ui.newEditBox({
        image = "lt_13.png",
        size = cc.size(tmpSize.width - 180, 53),
        maxLength = 50,
    })
    self.msgEditBox:setAnchorPoint(cc.p(0, 0.5))
    self.msgEditBox:setPosition(20, 40)
    tmpLayer:addChild(self.msgEditBox)

    -- 显示发送按钮
    local sendBtn = ui.newButton({
        normalImage = "c_33.png",
        text = TR("发送"),
        position = cc.p(tmpSize.width * 0.85, 40),
        clickAction = function()
            local strText = self.msgEditBox:getText()
            if (strText == nil) or (#strText == 0) then
                ui.showFlashView(TR("消息不能为空"))
                return
            end
            ShengyuanWarsHelper:chatToAll(strText, function ()
                    self.msgEditBox:setText("")
                end)
        end,
    })
    tmpLayer:addChild(sendBtn)

    -- 显示之前的聊天记录
    local chatMsgNum = 0
    for _,v in ipairs(ShengyuanWarsHelper.chatCache) do
        listView:pushBackCustomItem(createChatItem(v))
        chatMsgNum = chatMsgNum + 1
    end
    Utility.performWithDelay(tmpLayer, function ()
            listView:scrollToBottom(0.1, false)
        end, 0)

    -- 注册通知事件
    Notification:registerAutoObserver(tmpLayer, function ()
        -- 收到聊天消息
        local allNum = table.nums(ShengyuanWarsHelper.chatCache)
        for i=(chatMsgNum+1),allNum do
            local item = ShengyuanWarsHelper.chatCache[i]
            listView:pushBackCustomItem(createChatItem(item))
            chatMsgNum = chatMsgNum + 1
        end
        listView:scrollToBottom(0.1, false)
    end, {ShengyuanWarsHelper.Events.eShengyuanWarsChatInfo})
end

-- 创建战绩界面
function ShengyuanWarsDlgChatLayer:createReportLayer(parent, parentSize)
    local tmpSize = self.tabSize
    local tmpLayer = cc.LayerColor:create(cc.c4b(255, 0, 0, 0))
    tmpLayer:setContentSize(tmpSize)
    tmpLayer:setIgnoreAnchorPointForPosition(false)
    tmpLayer:setAnchorPoint(cc.p(0.5, 0))
    tmpLayer:setPosition(cc.p(parentSize.width * 0.5, 20))
    parent:addChild(tmpLayer)
    self.currLayer = tmpLayer

    -- 显示列表背景
    local listBgSprite = ui.newScale9Sprite("c_17.png", cc.size(tmpSize.width, tmpSize.height))
    listBgSprite:setAnchorPoint(cc.p(0.5, 0))
    listBgSprite:setPosition(tmpSize.width * 0.5, 0)
    tmpLayer:addChild(listBgSprite)
    
    -- 辅助函数：快捷添加Label
    local function addLabel(parent, anchor, pos, strText, textSize, textColor)
        local label = ui.newLabel({text = strText, color = textColor or Enums.Color.eWhite, size = textSize, x = pos.x, y = pos.y, outlineColor = Enums.Color.eBlack, })
        label:setAnchorPoint(anchor)
        parent:addChild(label)
    end

    -- 显示标题栏
    addLabel(tmpLayer, cc.p(0, 0.5), cc.p(10, tmpSize.height - 30), TR("玩家名字"), 25)
    addLabel(tmpLayer, cc.p(0, 0.5), cc.p(180, tmpSize.height - 30), TR("区服"), 25)
    addLabel(tmpLayer, cc.p(0, 0.5), cc.p(320, tmpSize.height - 30), TR("等级"), 25)
    addLabel(tmpLayer, cc.p(0, 0.5), cc.p(415, tmpSize.height - 30), TR("击杀"), 25)
    addLabel(tmpLayer, cc.p(0, 0.5), cc.p(490, tmpSize.height - 30), TR("积分"), 25)

    -- 根据荣誉值从高到低排序
    local scoreConfig = ShengyuanwarsConfig.items[1].killsScore or 0
    local sortTable = {}
    for _,v in pairs(ShengyuanWarsHelper.reportList.Data or {}) do
        local tmpV = clone(v)
        tmpV.killScore = tmpV.KillNum * scoreConfig
        table.insert(sortTable, tmpV)
    end
    table.sort(sortTable, function (a, b)
        return a.killScore > b.killScore
    end)

    -- 显示战绩列表
    local cellSize = cc.size(tmpSize.width, 40)
    local reportListView = ui.newSliderTableView({
        width = tmpSize.width,
        height = tmpSize.height - 70,
        isVertical = true,
        selItemOnMiddle = false,
        itemCountOfSlider = function()
            return table.nums(sortTable)
        end,
        itemSizeOfSlider = function(pSender, itemIndex)
            return cellSize.width, cellSize.height
        end,
        sliderItemAtIndex = function(sliderView, itemNode, index)
            local item = sortTable[index + 1]
            if (item == nil) then
                return
            end

            local strColor = Enums.Color.eRed
            if item.TeamName == ShengyuanWarsHelper.myTeamName then
                strColor = Enums.Color.eGreen
            end

            addLabel(itemNode, cc.p(0, 0.5), cc.p(10,   cellSize.height * 0.5), item.Name, 22, strColor)
            addLabel(itemNode, cc.p(0, 0.5), cc.p(180, cellSize.height * 0.5), "["..item.ServerName.."]", 22, strColor)
            addLabel(itemNode, cc.p(0, 0.5), cc.p(320, cellSize.height * 0.5), "Lv." .. item.Lv, 22, strColor)
            addLabel(itemNode, cc.p(0, 0.5), cc.p(415, cellSize.height * 0.5), item.KillNum, 22, strColor)
            addLabel(itemNode, cc.p(0, 0.5), cc.p(490, cellSize.height * 0.5), item.killScore, 22, strColor)
        end,
    })
    reportListView:setAnchorPoint(cc.p(0.5, 0))
    reportListView:setPosition(cc.p(tmpSize.width * 0.5, 10))
    tmpLayer:addChild(reportListView)
end

-- 创建神符界面
function ShengyuanWarsDlgChatLayer:createBuffLayer(parent, parentSize)
    local tmpSize = self.tabSize
    local tmpLayer = cc.LayerColor:create(cc.c4b(255, 0, 0, 0))
    tmpLayer:setContentSize(tmpSize)
    tmpLayer:setIgnoreAnchorPointForPosition(false)
    tmpLayer:setAnchorPoint(cc.p(0.5, 0))
    tmpLayer:setPosition(cc.p(parentSize.width * 0.5, 20))
    parent:addChild(tmpLayer)
    self.currLayer = tmpLayer

    -- 显示列表背景
    local listBgSprite = ui.newScale9Sprite("c_17.png", cc.size(tmpSize.width, tmpSize.height))
    listBgSprite:setAnchorPoint(cc.p(0.5, 0))
    listBgSprite:setPosition(tmpSize.width * 0.5, 0)
    tmpLayer:addChild(listBgSprite)

     -- 辅助函数：快捷添加Label
    local function addBuffItem(buffItem, posY)
        -- 添加图片
        local strEffectName = "effect_ui_taohuadao"
        if (buffItem.Id == 1) then
            strEffectName = "effect_ui_taohua_jing"
        end
        ui.newEffect({
            parent = tmpLayer,
            effectName = strEffectName,
            animation = buffItem.outsideSpine,
            scale = 0.6,
            loop = true,
            endRelease = false,
            position = cc.p(70, posY),
        })

        -- 添加描述文字
        local label = ui.newLabel({
            text = buffItem.intro,
            color = cc.c3b(0x46, 0x22, 0x0d),
            size = 24,
            dimensions = cc.size(tmpSize.width - 200, 0),
            align = cc.TEXT_ALIGNMENT_LEFT,
            valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
        })
        label:setAnchorPoint(cc.p(0, 0.5))
        label:setPosition(cc.p(150, posY))
        tmpLayer:addChild(label)
    end
    for i,v in ipairs(ShengyuanwarsBuffModel.items) do
        addBuffItem(v, tmpSize.height - i * 120 + 30)
    end
end

----------------------------------------------------------------------------------------------------


return ShengyuanWarsDlgChatLayer