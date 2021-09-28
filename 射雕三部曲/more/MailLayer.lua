--[[
    文件名：MailLayer.lua
    描述：邮件界面
    创建人：suntao
    创建时间：2016.5.18
    修改人：wukun
    修改时间：2016.9.12
-- ]]

-- 预定义量
local TabsConfig = {
    {   
        name = TR("系统邮件"),
        moduleId = ModuleSub.eEmailSystem,
    },
    {   
        name = TR("好友邮件"),
        moduleId = ModuleSub.eEmailFriend,
    },
    {   
        name = TR("战斗邮件"),
        moduleId = ModuleSub.eEmailBattle,
    },
}

-- "类"
local MailLayer = class("MailLayer", function()
    return display.newLayer(cc.c4b(0, 0, 0, 100))
end)

--- ==================== 主要显示界面相关 =======================
-- 构造函数
--[[
-- 参数 params 中的各项为:
    {
        pageType: 默认显示子页面的类型，取值为 ModuleSub.eEmailSystem/eEmailFriend/eEmailBattle
    }
]]
function MailLayer:ctor(params)
    -- 当前显示子页面类型
    self.mSubPageType = params.pageType or ModuleSub.eEmailSystem

    self.mPages = {}
    self.mCurPage = 0

    self:createLayer()
end

-- 初始化界面
function MailLayer:createLayer()
    -- 创建该页面的父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 创建背景
    local sprite = ui.newSprite("c_34.jpg")
    sprite:setPosition(320, 568)
    self.mParentLayer:addChild(sprite)

    -- 子背景
    -- local subBgSprite = ui.newScale9Sprite("c_124.png", cc.size(640, 142))
    -- subBgSprite:setAnchorPoint(cc.p(0.5, 1))
    -- subBgSprite:setPosition(cc.p(self.mParentLayer:getContentSize().width * 0.5, self.mParentLayer:getContentSize().height))
    -- self.mParentLayer:addChild(subBgSprite)
    local bottomBgSprite = ui.newScale9Sprite("c_19.png", cc.size(640, 990))
    bottomBgSprite:setAnchorPoint(0.5, 0)
    bottomBgSprite:setPosition(320, 10)
    self.mParentLayer:addChild(bottomBgSprite)

    local darkBgSprite = ui.newScale9Sprite("c_17.png",cc.size(606, 845))
    darkBgSprite:setPosition(320, 538)
    self.mParentLayer:addChild(darkBgSprite)

    self:initUI()
end


-- 创建UI
function MailLayer:initUI()
    -- 创建顶部资源栏和底部导航栏
    local topResource = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {
            ResourcetypeSub.eVIT,  
            ResourcetypeSub.eDiamond, 
            ResourcetypeSub.eGold
        }
    })
    self:addChild(topResource)

    -- 创建退出按钮
    local button = ui.newButton({
            normalImage = "c_29.png",
            anchorPoint = cc.p(0.5, 0.5),
            position = Enums.StardardRootPos.eCloseBtn,
            clickAction = function()
                LayerManager.removeLayer(self)
            end
        })
    self.mParentLayer:addChild(button, Enums.ZOrderType.eDefault + 5)
    self.mCloseBtn = button

    -- 创建标签
    self:createTabs()
end

--- ==================== 标签相关 =======================
-- 创建标签
function MailLayer:createTabs()
    local buttonInfos = {}

    -- 初始化按钮信息
    for i=1, #TabsConfig do
        buttonInfos[i] = {
            text = TR(TabsConfig[i].name),
            tag = TabsConfig[i].moduleId,
        }
    end

    -- 创建标签
    local tabLayer = ui.newTabLayer({
        btnInfos = buttonInfos,
        onSelectChange = function (tag)
            if self.mTabs then
                self:changePage(tag)
                self:changeBadgeState(self.mTabs:getTabBtnByTag(tag), false)
            end
        end,
        allowChangeCallback = function (pageIndex) return true end      
    })
    -- tabLayer:setAnchorPoint(cc.p(0, 0))
    tabLayer:setPosition(Enums.StardardRootPos.eTabView)

    self.mParentLayer:addChild(tabLayer)
    self.mTabs = tabLayer

    -- 添加"小红点"
    self.mButtonsData = {}
    --self.mNeedAutoRefresh = false
    local buttons = self.mTabs:getTabBtns()
    self:addBadges(buttons)

    self.mKeepBadge = true
    self:changePage(self.mTabs:getCurrTag())
    self.mNeedAutoRefresh = true
end

-- 添加"小红点"
function MailLayer:addBadges(nodes)
    for tag, node in pairs(nodes) do
        local badgeSprite = ui.createBubble({})
        badgeSprite:setPosition(115, 44)
        badgeSprite:setVisible(false)
        node:addChild(badgeSprite)

        node.badge = badgeSprite
        node.moduleId = tag

        local eventsName = {EventsName.eRedDotPrefix .. tostring(tag)}
        -- 微信红包
        if tag == ModuleSub.eEmailSystem then
            -- 创建红包标识
            -- table.insert(eventsName, EventsName.eWeChatRedBagChange)
        end

        Notification:registerAutoObserver(node, function(node)
            self:changeBadgeState(node)
        end, eventsName)
        self:changeBadgeState(node, false)
    end
end

-- 改变小红点状态
function MailLayer:changeBadgeState(node, needAutoRefresh)
    if node == nil then return end

    if needAutoRefresh == nil then
        needAutoRefresh = self.mNeedAutoRefresh
    end

    -- 微信红包
    local needRefresh = false
    if node.moduleId == ModuleSub.eEmailSystem then
        local isEmailRedBag = RedDotInfoObj:isValid(ModuleSub.eEmailRedBag)
        if not self.mKeepBadge then
            -- node.redBagSprite:setVisible(isEmailRedBag > 0)
        end
        needRefresh = isEmailRedBag
    end

    -- 小红点
    if not needRefresh then
        local state = RedDotInfoObj:isValid(node.moduleId)
        if not self.mKeepBadge then
            node.badge:setVisible(state)
        end
        needRefresh = state
    end

    -- 是否需要刷新
    local tag = self.mTabs:getCurrTag()
    if needRefresh and self.mTabs:getTabBtnByTag(tag) == node then
        if needAutoRefresh then
            self:changePage(tag)
        end
    end 
end

-- 跳转到分页
function MailLayer:changePage(tag)
    if self.mTabs == nil then
        return
    end

    -- 隐藏当前分页
    if self.mPages[self.mCurPage] ~= nil then
        self.mPages[self.mCurPage]:setVisible(false)
    end

    self.mCurPage = tag
    if self.mPages[tag] ~= nil and self.mTabs:getTabBtnByTag(tag).badge:isVisible() == false then
        -- 页面存在
        self.mPages[tag]:setVisible(true)
    else
        -- 页面不存在
        if tag == ModuleSub.eEmailSystem then
            self:requestGetEmailsByPage(1)
        elseif tag == ModuleSub.eEmailBattle then
            self:requestGetEmailsByPage(2)
        elseif tag == ModuleSub.eEmailFriend then
            self:requestGetFriendMessageByPage()
        end
    end
end

--- ==================== 单个Page相关 =======================
-- 预定义常量
local Page = {
    width = 598,
    height = 810,
    x = 320,
    y = 140,
}

local Item = {
    width = 598,
    height = 126,
    headerWidth = 116,
    textWidth = 340,
    buttonsWidth = 150,
}

-- 添加新分页(如果对应的页面已经存在，先移除后添加)
function MailLayer:addPage(tag, value)
    if  #value == 0 then
        self:removePage(tag)
        local nothingSprite = ui.createEmptyHint(TR("暂时没有邮件哟！"))
        nothingSprite:setPosition(320, 1136 / 2)
        self.mParentLayer:addChild(nothingSprite)
        self.mPages[tag] = nothingSprite
    else
        local listView = ccui.ListView:create()
        listView:setDirection(ccui.ScrollViewDir.vertical)
        listView:setBounceEnabled(true)
        listView:setContentSize(cc.size(Page.width, Page.height))
        listView:setGravity(ccui.ListViewGravity.centerVertical)
        listView:setItemsMargin(5)
        listView:setAnchorPoint(cc.p(0.5, 0))
        listView:setPosition(Page.x, Page.y)
        listView:setScrollBarEnabled(false)
        listView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)

        -- 添加Item
        for i=1, #value do
            local item = self:createItem(tag, value[i])
            listView:pushBackCustomItem(item)
        end

        self:removePage(tag)

        self.mParentLayer:addChild(listView)
        self.mPages[tag] = listView
    end
    -- 更新“小红点”状态
    --self:changeBadgeState(self.mTabs:getTabBtnByTag(tag))
end

-- 删除分页
function MailLayer:removePage(tag)
    if self.mPages[tag] ~= nil then
        self.mParentLayer:removeChild(self.mPages[tag])
        self.mPages[tag] = nil
    end
end

--- ==================== 单个Item相关 =======================
-- 创建新Item
function MailLayer:createItem(moduleId, data)
    -- 创建Item容器
    local item = ccui.Layout:create()
    item:setContentSize(Item.width, Item.height)

    -- 添加背景
    local background = ui.newScale9Sprite("c_18.png", cc.size(Item.width-5, Item.height))
    -- background:setAnchorPoint(0, 0)
    background:setPosition(Item.width/2, Item.height/2)
    item:addChild(background)

    -- 显示左方头部
    local header = nil
    if moduleId == ModuleSub.eEmailFriend then
        header = CardNode.createCardNode({
            resourceTypeSub = ResourcetypeSub.eHero,
            modelId = data.HeadImageId,
            IllusionModelId = data.IllusionModelId,
            cardShowAttrs = {CardShowAttr.eBorder},
            --allowClick = false,
            onClickCallback = function ()
                Utility.showPlayerTeam(data.SendPlayerId, false)
            end,
        })
    else
        if data.Type == 1 then
            header = cc.Sprite:create("yxxt_2.png")
        else
            header = cc.Sprite:create("yxxt_1.png")
        end
    end
    header:setPosition(Item.headerWidth / 2, Item.height / 2)
    item:addChild(header)

    -- 显示文字信息
    local textLayout = self:createTextLayout(moduleId, data)
    textLayout:setAnchorPoint(0, 0)
    textLayout:setPosition(Item.headerWidth, 0)
    item:addChild(textLayout)

    -- 显示按钮
    local buttons = self:createButtons(moduleId, data)
    buttons:setAnchorPoint(0, 0)
    buttons:setPosition(Item.width, 0)
    item:addChild(buttons)

    return item
end

-- 创建信息显示容器（包括标题，时间，内容）
function MailLayer:createTextLayout(moduleId, data)
    local textWidth = Item.textWidth
    if moduleId == ModuleSub.eEmailFriend then
        textWidth = Item.textWidth - 120
    end

    local textLayout = ccui.Layout:create()
    textLayout:setContentSize(textWidth, Item.height)

    -- 创建标题
    local subject = data.Subject
    if moduleId == ModuleSub.eEmailFriend then
        if data.Type == 1 then
            subject = TR("%s的请求",data.SendPlayerName)
        else
            subject = TR("%s的留言",data.SendPlayerName)
        end
    end

    local subjectCount = math.ceil(textWidth / 26)
    if string.utf8len(subject) > subjectCount then
        subject = string.utf8sub(subject, 1, subjectCount) .. "..."
    end

    local textView = ui.newLabel({
        text = subject,
        font = Enums.Font.eHelveticaBlod,
        color = Enums.Color.eNormalYellow,
        size = 23,
        anchorPoint = cc.p(0, 1),
        x = 0,
        y = 120,
    })
    textLayout:addChild(textView)

    -- 创建日期
    local time = os.date("%Y/%m/%d %H:%M", data.SendTime)
    if moduleId ~= ModuleSub.eEmailFriend and data.EndTime ~= nil then
        time = time .. TR("至") .. os.date("%Y/%m/%d %H:%M", data.EndTime)
    end

    local textView = ui.newLabel({
        text = time,
        font = Enums.Font.eHelveticaBlod,
        color = Enums.Color.eNormalYellow,
        size = 20,
        anchorPoint = cc.p(1, 1),
        x = 450,
        y = 30,
    })
    textLayout:addChild(textView)

    -- 创建邮件内容
    local contentCount = math.ceil(textWidth / 10)
    local content = string.gsub(data.Content, "\n", "")
    if string.utf8len(content) > contentCount then
        content = string.utf8sub(content, 1, contentCount) .. "..."
    end

    local label = cc.Label:createWithSystemFont(
        content,
        Enums.Font.eDefault, 
        21, 
        cc.size(textWidth + 20, 55), 
        ui.TEXT_ALIGN_LEFT, 
        ui.TEXT_VALIGN_CENTER
    )
    label:setColor(Enums.Color.eNormalYellow)
    label:setAnchorPoint(cc.p(0, 1))
    label:setPosition(0, 86)
    textLayout:addChild(label)

    return textLayout
end

-- 创建按钮
function MailLayer:createButtons(moduleId, data)
    -- 创建容器
    local buttonLayout = ccui.Layout:create()

    local buttonInfo = {
        normalImage = "c_28.png",
        anchorPoint = cc.p(1, 0.5),
    }

    if moduleId ~= ModuleSub.eEmailFriend then
        -- 普通邮件
        buttonLayout:setContentSize(Item.buttonsWidth, Item.height)
        buttonInfo.text = TR("详情")
        buttonInfo.position = cc.p(-6, Item.height / 2)
        buttonInfo.clickAction = function ()
            require("more.MailDetailLayer").newLayer(moduleId, data)
        end
        buttonLayout:addChild(ui.newButton(buttonInfo))

    elseif data.Type == 2 then
        -- 好友留言邮件
        buttonLayout:setContentSize(Item.buttonsWidth + 100, Item.height)
        -- 回复按钮
        buttonInfo.text = TR("回复")
        buttonInfo.position = cc.p(-6, Item.height / 2)
        buttonInfo.clickAction = function ()
            require("more.MailAnswerLayer").new(data.SendPlayerId)
        end
        buttonLayout:addChild(ui.newButton(buttonInfo))

        -- 详情按钮
        buttonInfo.text = TR("详情")
        buttonInfo.position = cc.p(-135, Item.height / 2)
        buttonInfo.clickAction = function ()
            require("more.MailDetailLayer").newLayer(moduleId, data)
        end
        buttonLayout:addChild(ui.newButton(buttonInfo))

    else
        -- 好友申请邮件
        buttonLayout:setContentSize(Item.buttonsWidth + 100, Item.height)
        -- 同意按钮
        buttonInfo.text = TR("同意")
        buttonInfo.normalImage = "c_28.png"
        buttonInfo.position = cc.p(-6, Item.height / 2)
        buttonInfo.clickAction = function ()
            self:requestFriendApplyResponse(data.SendPlayerId, true)
        end
        buttonLayout:addChild(ui.newButton(buttonInfo))

        -- 拒绝按钮
        buttonInfo.text = TR("拒绝")
        buttonInfo.normalImage = "c_28.png"
        buttonInfo.position = cc.p(-135, Item.height / 2)
        buttonInfo.clickAction = function ()
            self:requestFriendApplyResponse(data.SendPlayerId, false)
        end
        buttonLayout:addChild(ui.newButton(buttonInfo))
    end
        local temp = buttonLayout:getChildren()
        for k,v in pairs(temp) do
            v:setScale(0.9)
        end
    return buttonLayout
end

--- ==================== 服务器数据请求相关 =======================
-- 默认值
local PgaeNum = 0
local ItemCount = 10

-- 获取系统/战斗邮件的数据请求
function MailLayer:requestGetEmailsByPage(type)
    HttpClient:request({
        moduleName = "PlayerEmail", 
        methodName = "GetEmailsByPage", 
        svrMethodData = {type, PgaeNum, ItemCount}, 
        callback = function(response)
            if response.Status ~= 0 then return end

            local value = response.Value

            --local moduleId = ModuleSub.eEmailSystem
            if type == 1 then
                --moduleId = ModuleSub.eEmailSystem
                self:addPage(ModuleSub.eEmailSystem, value)
            elseif type == 2 then
                --moduleId = ModuleSub.eEmailBattle
                self:addPage(ModuleSub.eEmailBattle, value)
            end

            --self:addPage(moduleId, value)

            self.mKeepBadge = false
        end
    })
end

-- 获取好友邮件的数据请求
function MailLayer:requestGetFriendMessageByPage()
    HttpClient:request({
        moduleName = "FriendMessage", 
        methodName = "GetFriendMessageByPage", 
        svrMethodData = {PgaeNum, ItemCount}, 
        callback = function(response)
            if response.Status ~= 0 then return end

            local value = response.Value
            self:addPage(ModuleSub.eEmailFriend, value)
        end
    })
end

-- 网络数据处理
function MailLayer:requestFriendApplyResponse(palyerId, isAgree)
    HttpClient:request({
        moduleName = "Friend", 
        methodName = "FriendApplyResponse",
        svrMethodData = {palyerId, isAgree}, 
        callback = function(response)
            if response.Status == 0 then
                local hintStr = TR("同意成为好友成功")
                if not isAgree then
                    hintStr = TR("已拒绝成为好友")
                end
                ui.showFlashView(hintStr)

                self:requestGetFriendMessageByPage()

                FriendObj:clearFriendList()
                FriendObj:requestGetFriendList()
            else
                local errorCode = response.Status
                if errorCode == -3013 or errorCode == -12 or errorCode == -3012 or errorCode == -3005 then
                    self:requestGetFriendMessageByPage()
                end
            end
        end
    })
end


return MailLayer
