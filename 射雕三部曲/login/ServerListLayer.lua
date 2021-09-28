--[[
    文件名：ServerListLayer.lua
    描述：服务器选择界面
    创建人：heguanghui
    创建时间：2017.3.6
-- ]]

local ServerListLayer = class("ServerListLayer", function(params)
    return display.newLayer()
end)

--[[
-- params = {
        srvInfoList = nil
        historyServerIdList = nil
        callback = nil
    }
]]
function ServerListLayer:ctor(params)
    self.mServerInfoList = clone(params.srvInfoList)
    self.mSelectCallback = params.callback
    self:updateHistoryList(params.historyServerIdList)
    -- 屏蔽下层事件
    ui.registerSwallowTouch({node=self})
    -- 创建该页面的父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 显示初始界面
    self:initUI()
end

-- 显示初始界面
function ServerListLayer:initUI()
    -- 显示背景
    local bgSprite = ui.newSprite("xf_01.png")
    bgSprite:setAnchorPoint(0.5, 1)
    bgSprite:setPosition(320, 1136)
    self.mParentLayer:addChild(bgSprite)
    self.mBgSize = bgSprite:getContentSize()

    -- 关闭按钮
    local btnClose = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(self.mBgSize.width - 20, self.mBgSize.height - 130),
        clickAction = function ()
            LayerManager.removeLayer(self)
        end,
    })
    btnClose:setAnchorPoint(1, 0.5)
    bgSprite:addChild(btnClose)

    --标题
    local titleLabel = ui.newLabel({
        text = TR("最近登陆"),
        size = 24,
        color = cc.c3b(0x7a, 0x57, 0x49),
        x = self.mBgSize.width / 2,
        y = self.mBgSize.height - 170,
    })
    bgSprite:addChild(titleLabel)

    local titleLabel1 = ui.newLabel({
        text = TR("服务器列表"),
        size = 24,
        color = cc.c3b(0x7a, 0x57, 0x49),
        x = self.mBgSize.width / 2,
        y = self.mBgSize.height - 380,
    })
    bgSprite:addChild(titleLabel1)



    --最近登陆服务器列表
    self.mListViewLod = ccui.ListView:create()
    self.mListViewLod:setDirection(ccui.ScrollViewDir.vertical)
    self.mListViewLod:setBounceEnabled(true)
    self.mListViewLod:setContentSize(cc.size(self.mBgSize.width, 150))
    self.mListViewLod:setAnchorPoint(cc.p(0.5,1))
    self.mListViewLod:setPosition(cc.p(self.mBgSize.width / 2, self.mBgSize.height - 190))
    bgSprite:addChild(self.mListViewLod)

    -- 显示服务器列表
    self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setContentSize(cc.size(self.mBgSize.width - 215, self.mBgSize.height - 640))
    self.mListView:setAnchorPoint(cc.p(0.5,1))
    self.mListView:setPosition(cc.p(self.mBgSize.width / 2 + 57.5, self.mBgSize.height - 410))
    bgSprite:addChild(self.mListView)

    -- 刷新历史服务器列表
    self:refreshHistoryListView()

    --服务器状态提示
    local stateGray = ui.createSpriteAndLabel({
        imgName = "xf_05.png",
        labelStr = TR("维护"),
        fontSize = 25,
        fontColor = Enums.Color.eWhite,
        outlineColor = Enums.Color.eBlack,
        outlineSize = 2,
        alignType = ui.TEXT_ALIGN_RIGHT,
    })
    stateGray:setPosition(cc.p(self.mBgSize.width * 0.5 - 150, 65))
    bgSprite:addChild(stateGray)

    local stateYellow = ui.createSpriteAndLabel({
        imgName = "xf_06.png",
        labelStr = TR("新服"),
        fontSize = 25,
        fontColor = Enums.Color.eWhite,
        outlineColor = Enums.Color.eBlack,
        outlineSize = 2,
        alignType = ui.TEXT_ALIGN_RIGHT,
    })
    stateYellow:setPosition(cc.p(self.mBgSize.width * 0.5, 65))
    bgSprite:addChild(stateYellow)

    local stateRed = ui.createSpriteAndLabel({
        imgName = "xf_07.png",
        labelStr = TR("推荐"),
        fontSize = 25,
        fontColor = Enums.Color.eWhite,
        outlineColor = Enums.Color.eBlack,
        outlineSize = 2,
        alignType = ui.TEXT_ALIGN_RIGHT,
    })
    stateRed:setPosition(cc.p(self.mBgSize.width * 0.5 + 150, 65))
    bgSprite:addChild(stateRed)

    -- 分组按钮选中状态
    local normalBtnImage, selectBtnImage = "xf_08.png", "xf_09.png"
    local function selectServerGroupAction(index)
        for i,btn in ipairs(self.groupBtnList) do
            btn:loadTextureNormal(index == i and selectBtnImage or normalBtnImage)
        end
    end
    -- 创建分组服务器信息self.mServerInfoList
    local groupTopY = 602
    local groupServerInfo = {{name=TR("射鵰群英"), list={}, startId = 22000}, {name=TR("倚天屠龙"), list={}, startId = 21000}, {name=TR("神鵰侠侣"), list={}, startId = 1}}
    for _,server in ipairs(self.mServerInfoList) do
        for _,info in ipairs(groupServerInfo) do
            if server.ServerGroupID >= info.startId then
                table.insert(info.list, server)
                break
            end
        end
    end
    -- 删除空的列表项
    local i = 1
    while #groupServerInfo >= i do
        local info = groupServerInfo[i]
        if #info.list == 0 then
            table.remove(groupServerInfo, i)
        else
            i = i + 1
        end
    end
    self.groupBtnList = {}
    for i,v in ipairs(groupServerInfo) do
        local btnGroup = ui.newButton({
            text = v.name,
            fontSize = 20,
            textColor = cc.c3b(0x63, 0x31, 0x2c),
            outlineSize = 0,
            normalImage = normalBtnImage,
            position = cc.p(104, groupTopY - (i - 1) * 66),
            clickAction = function ()
                self:refreshListView(v.list)
                selectServerGroupAction(i)
            end,
        })
        bgSprite:addChild(btnGroup)
        table.insert(self.groupBtnList, btnGroup)
    end
    -- 默认选中第一个group
    if #self.groupBtnList > 0 then
        self.groupBtnList[1].mClickAction()
    end
end

-- 刷新历史服务器信息
function ServerListLayer:updateHistoryList(historyServerIdList)
    -- 组织最近访问的服务器
    self.mHistoryServerList = {}
    if self.mServerInfoList and historyServerIdList then
        for _, serverId in ipairs(historyServerIdList) do
            local tempId = type(serverId) == "string" and tonumber(serverId) or serverId
            for _, serverInfo in pairs(self.mServerInfoList) do
                if serverInfo.ServerID == tempId then
                    table.insert(self.mHistoryServerList, clone(serverInfo))
                    break
                end
            end
        end
    end
end

-- 创建服务器项
function ServerListLayer:createListItem(serverList, isHistoryItem)
    local normalImage = "xf_02.png"
    local scrollWidth = self.mBgSize.width - 215
    local scrollStartX = 107
    local scrollIntervalX = 215
    local scrollCellWidth = 15
    if isHistoryItem then
        normalImage = "xf_03.png"
        scrollWidth = self.mBgSize.width
        scrollStartX = 190
        scrollIntervalX = 265
        scrollCellWidth = 130
    end
    local itemCount = math.ceil(table.maxn(serverList) / 2)
    for i = 1, itemCount do
        local lvItem = ccui.Layout:create()
        lvItem:setContentSize(cc.size(scrollWidth / 2, 65))
        for k = 1, 2 do
            local index = (i - 1) * 2 + k
            local server = serverList[index]
            if server then
                local lvItemButton = ui.newButton({
                    normalImage = normalImage,
                    --text = server.ServerName,
                    position = cc.p(scrollStartX + (k - 1) * scrollIntervalX, 35),
                    --textColor = Enums.Color.ePrColor,
                    size = cc.size((scrollWidth - scrollCellWidth) / 2, 60),
                    --outlineColor = Enums.Color.ePrColorH,
                    clickAction = function()
                        if server.ServerState ~= 1 then
                            local hintStr = server.MaintainMessage
                            if not hintStr or hintStr == "" then
                                hintStr = TR("服务器正在维护, 请稍候再试！")
                            end
                            ui.showFlashView({text = hintStr})
                            return
                        end
                        if self.mSelectCallback then
                            self.mSelectCallback(server)
                        end
                        LayerManager.removeLayer(self)
                    end
                })

                local severName = ui.newLabel({
                    text = server.ServerName,
                    size = 26,
                    color = cc.c3b(0x63, 0x31, 0x2c),
                    x = lvItemButton:getContentSize().width / 1.85,
                    y = lvItemButton:getContentSize().height / 2,
                })
                lvItemButton:addChild(severName)

                lvItem:addChild(lvItemButton)

                local image, pos = self:getImageByHeat(server)
                if image then
                    if isHistoryItem then
                        pos.x = pos.x + 35
                    end
                    local statusImage = cc.Sprite:create(image)
                    statusImage:setPosition(pos)
                    lvItemButton:addChild(statusImage)
                end
            end
        end
        if isHistoryItem then
            self.mListViewLod:pushBackCustomItem(lvItem)
        else
            self.mListView:pushBackCustomItem(lvItem)
        end
    end
end

-- 刷新服务器列表
function ServerListLayer:refreshListView(serverList)
    self.mListView:removeAllChildren()
    -- 全部服务器列表
    if table.maxn(self.mServerInfoList) > 0 then
        self:createListItem(serverList)
    end
end

-- 刷新历史服务器列表
function ServerListLayer:refreshHistoryListView()
    -- 最近登录的服务器
    if table.maxn(self.mHistoryServerList) > 0 then
        self:createListItem(self.mHistoryServerList, true)
    end
end

-- 获取服务器的显示状态
--[[
    ServerState: 服务器状态（1：正常，2：维护）
    ServerHeat: 服务器热度 （1: 正常, 2: 新服, 3: 推荐）
--]]
function ServerListLayer:getImageByHeat(server)
    if server.ServerState == 2 then
        return "xf_05.png", cc.p(10, 30)
    end
    -- 正常状态下的热度状态
     if server.ServerHeat == 2 then
         return "xf_06.png", cc.p(10, 30)
     end
    if server.ServerHeat == 3 then
         return "xf_07.png", cc.p(10, 30)
    end
end

return ServerListLayer
