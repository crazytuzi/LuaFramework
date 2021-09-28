--[[
    文件名：GuildSearchLayer
    描述：查找帮派页面
    创建人：chenzhong
    创建时间：2017.03.6
-- ]]

local GuildSearchLayer = class("GuildSearchLayer", function()
	return display.newLayer(cc.c4b(0, 0, 0, 150))
end)

function GuildSearchLayer:ctor()
	-- 屏蔽下层点击事件
    ui.registerSwallowTouch({node = self})

    -- 帮派信息的总页数
    self.mTotalPage = 0
    -- 获取帮派信息当前页的Index
    self.mPagIndex = 0
    -- 查询信息
    self.mSearchInfo = ""
    -- 是否屏蔽满员帮派
    self.mHideFull = false

    -- 判断是否可以滑动
    self.mIsScroll = false

    -- 是否首次显示listview数据
    self.mIsFirstGetData = true

    -- 帮派信息列表
    self.mGuildListInfo = {}
    -- 已申请的帮派信息列表
    self.mApplyGuildListInfo = {}
    -- 玩家的帮派信息
    self.mPlayerGuildInfo = {}

    -- 列表的显示大小
    self.mListViewSize = cc.size(610, 730)
    -- 列表中单个条目的大小
    self.mCellSize = cc.size(594, 160)

    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 初始化页面控件
    self:initUI()

    -- 获取帮派申请信息
    self:requestApplyGuildInfo()
end

-- 初始化页面控件
function GuildSearchLayer:initUI()
    -- 创建页面背景
    local bgSprite = ui.newScale9Sprite("c_34.jpg", cc.size(640, 1136))
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)

    -- 关闭按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    closeBtn:setPosition(600, 1050)
    self.mParentLayer:addChild(closeBtn)

    -- 提示信息
    local hintNode = ui.createSpriteAndLabel({
        imgName = "c_25.png",
        scale9Size = cc.size(538, 80),
        labelStr = TR("只能同时申请3个帮派。\n每日第二次退出帮派需24小时后才能重新申请。"),
        fontColor = Enums.Color.eNormalWhite,
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        fontSize = 20
    })
    hintNode:setPosition(310, 1040)
    self.mParentLayer:addChild(hintNode)

    --创建帮派按钮
    local createBtn = ui.newButton({
        normalImage = "tb_13.png",
        position = cc.p(80, 950),
        clickAction = function()
            LayerManager.addLayer({
                name = "guild.GuildCreateLayer",
                cleanUp = false
            })
        end
    })
    self.mParentLayer:addChild(createBtn)

    --查找输入框
    self.nameEditBox = ui.newEditBox({
        image = "c_38.png",
        size = cc.size(316, 58),
        fontColor = cc.c3b(0x46, 0x22, 0x0d),
        fontSize = 24
    })
    self.nameEditBox:setPosition(300, 950)
    self.nameEditBox:setPlaceHolder(TR("输入帮派名字"))
    self.mParentLayer:addChild(self.nameEditBox)

    -- 搜索按钮的点击事件和屏蔽满员帮派选择框事件函数
    local function searchClickFunc(isHide)
        local tempStr = string.trim(self.nameEditBox:getText())
        if tempStr ~= self.mSearchInfo or isHide then
            self.mSearchInfo = tempStr
            -- 帮派信息的总页数
            self.mTotalPage = 0
            -- 获取帮派信息当前页的Index
            self.mPagIndex = 0
            -- 帮派信息列表
            self.mGuildListInfo = {}
            self.mListView:removeAllItems()

            --由于不能传入空字符串  所以要处理传入空字符串时获取全部数据
            if self.mSearchInfo ~= "" then
                self:requestGuildQuery()
            else
                self:requestApplyGuildInfo()
            end
        end
    end

    --查找按钮
    local searchBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("查找"),
        position = cc.p(540, 950),
        clickAction = function ()
            searchClickFunc()
        end
    })
    self.mParentLayer:addChild(searchBtn)
    --[[
    -- 屏蔽满员帮派 选择框
    local checkBox = ui.newCheckbox({
        normalImage = "c_56.png",
        selectImage = "c_57.png",
        isRevert = true,
        text = TR("屏蔽满员帮派"),
        textColor = Enums.Color.eYellow,
        callback = function(state)
            self.isHideFull = state

            searchClickFunc(true)
        end
    })
    checkBox:setCheckState(false)
    checkBox:setPosition(cc.p(480, 120))
    self.mParentLayer:addChild(checkBox)
    --]]

    local listBg = ui.newScale9Sprite("c_17.png", cc.size(610, 758))
    listBg:setAnchorPoint(cc.p(0.5, 0))
    listBg:setPosition(320, 135)
    self.mParentLayer:addChild(listBg)
    -- 创建帮派列表
    self.mListView = ccui.ListView:create()
    self.mListView:setContentSize(self.mListViewSize)
    self.mListView:setItemsMargin(10)
    self.mListView:setDirection(ccui.ListViewDirection.vertical)
    self.mListView:setGravity(ccui.ListViewGravity.centerHorizontal)
    self.mListView:setBounceEnabled(true)
    self.mListView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
    self.mListView:setAnchorPoint(cc.p(0.5, 0))
    self.mListView:setPosition(cc.p(320, 144))
    self.mParentLayer:addChild(self.mListView)

    --listview添加监听
    self.mListView:addScrollViewEventListener(function(sender, eventType)
        if eventType == 6 then  --BOUNCE_BOTTOM
            if self.mPagIndex >= self.mTotalPage then
                return
            end

            if self.mIsScroll == false then
                return
            end
            self.mIsScroll = false
            if self.mSearchInfo ~= "" then
                self:requestGuildQuery()
            else
                self:requestApplyGuildInfo()
            end
        end
    end)
    -- 创建顶部区域
    local topResource = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        needFAP = false,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eSTA, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(topResource)
end

-- 刷新列表
function GuildSearchLayer:refreshListView()
    -- 最后一个为说明条目，不包含实际帮派信息
    local scrollPos = self.mListView:getInnerContainerPosition()
    self.mListView:removeLastItem()
    local itemNodeList = self.mListView:getItems() or {}
    -- print("#itemNodeList", #itemNodeList)
    --dump(self.mGuildListInfo, "self.mGuildListInfo:")

    self.applyBtnList = {}
    -- 刷新listview
    local cellSize = self.mCellSize
    for index = #itemNodeList + 1, #self.mGuildListInfo do
        local lvItem = ccui.Layout:create()
        lvItem:setContentSize(cellSize)
        self.mListView:pushBackCustomItem(lvItem)

        self:refreshListItem(index)
    end

    -- 加上说明条目
    local lvItem = ccui.Layout:create()
    lvItem:setContentSize(cc.size(self.mCellSize.width, 60))
    self.mListView:pushBackCustomItem(lvItem)
    local tempLabel = ui.newLabel({
        text = (self.mPagIndex >= self.mTotalPage) and TR("没有更多帮派") or TR("下拉加载更多帮派"),
        color = cc.c3b(0x4a, 0x49, 0x49),
    })
    tempLabel:setAnchorPoint(cc.p(0.5, 0.5))
    tempLabel:setPosition(self.mCellSize.width / 2, 30)
    lvItem:addChild(tempLabel)

    -- 重新设置，需要延时才有效果
    Utility.performWithDelay(self, function()
        -- 首次显示数据不做坐标调整，规避条目过少而发生显示不出来的BUG
        if self.mIsFirstGetData  == true then
            self.mIsFirstGetData = false
            return
        end
        self.mListView:setInnerContainerPosition(scrollPos)
    end,0)

    -- 增加一个延时，避免快速滑动导致网络请求过快
    Utility.performWithDelay(self, function ()
        self.mIsScroll = true
    end, 1.0)
end

-- 刷新列表中的一个Cell
function GuildSearchLayer:refreshListItem(index)
    local lvItem = self.mListView:getItem(index - 1)
    local cellSize = self.mCellSize
    if not lvItem then
        lvItem = ccui.Layout:create()
        lvItem:setContentSize(cellSize)
        self.mListView:insertCustomItem(lvItem, index - 1)
    end
    lvItem:removeAllChildren()

    -- 帮派信息
    local guildInfo = self.mGuildListInfo[index]

    -- 条目的背景图
    local cellBgSprite = ui.newScale9Sprite("c_37.png", cc.size(600, 149))
    cellBgSprite:setPosition(cellSize.width / 2, cellSize.height / 2)
    lvItem:addChild(cellBgSprite)

    local desireBg = ui.newSprite("bp_13.png")
    desireBg:setPosition(cc.p(67, 18))
    desireBg:setAnchorPoint(0, 0)
    lvItem:addChild(desireBg)

    -- 帮派名称
    local nameLabel = ui.newLabel({
        text = guildInfo.Name,
        size = 25,
        outlineColor = Enums.Color.eBlack,
    })
    nameLabel:setAnchorPoint(0.5, 1)
    nameLabel:setPosition(cellSize.width / 2, cellSize.height - 10)
    lvItem:addChild(nameLabel)

    -- 帮派帮主
    local leaderLabel = ui.newLabel({
        size = 19,
        text = TR("#411e05帮主:     #d17e00%s", guildInfo.LeaderName),
    })
    leaderLabel:setAnchorPoint(cc.p(0, 0.5))
    leaderLabel:setPosition(10, 85)
    lvItem:addChild(leaderLabel)

    -- 帮派等级
    local lvLabel = ui.newLabel({
        size = 19,
        text = TR("#411e05等级:    #d17e00%d", guildInfo.Lv),
    })
    lvLabel:setAnchorPoint(cc.p(0, 0.5))
    lvLabel:setPosition(225, 85)
    lvItem:addChild(lvLabel)

    -- 帮派资金
    local fundLabel = ui.newLabel({
        text = TR("#411e05帮派资金:    #d17e00%d", guildInfo.GuildFundTotal),
        size = 19,
    })
    fundLabel:setAnchorPoint(cc.p(0, 0.5))
    fundLabel:setPosition(225, 58)
    lvItem:addChild(fundLabel)

    -- 帮派成员数
    local memberNumMax = GuildLvRelation.items[guildInfo.Lv].memberNumMax -- 该帮派的总人数
    local memberLabel = ui.newLabel({
        size = 19,
        text = TR("#411e05成员:     #d17e00%d/%d", guildInfo.MemberCount, memberNumMax+(guildInfo.ExtendCount or 0)),
    })
    memberLabel:setAnchorPoint(cc.p(0, 0.5))
    memberLabel:setPosition(10, 58)
    lvItem:addChild(memberLabel)

    -- 帮派宣言
    local tempStr = guildInfo.Declaration
    -- local needDetailBtn = false
    if string.utf8len(tempStr) > 12  then
        -- needDetailBtn = true
        tempStr = string.utf8sub(tempStr, 1, 12).."..."
    elseif string.find(tempStr, "\n") then
        -- needDetailBtn = true
        local sStart, sEnd =  string.find(tempStr, "\n")
        tempStr = string.sub(tempStr, 1, sStart -1 ).."..."
    end
    local declarationLabel = ui.newLabel({
        size = 19,
        text = TR("#411e05宣言:     #d17e00%s", tempStr),
    })
    declarationLabel:setAnchorPoint(cc.p(0, 0.5))
    declarationLabel:setPosition(10, 28)
    lvItem:addChild(declarationLabel)

    -- 查看帮派宣言详情按钮
    -- if needDetailBtn then
    --     local tempBtn = ui.newButton({
    --         normalImage = "c_28.png",
    --         text = TR("详情"),
    --         clickAction = function()
    --             MsgBoxLayer.addOKLayer(guildInfo.Declaration, TR("帮派宣言"))
    --         end
    --     })
    --     tempBtn:setPosition(500, 40)
    --     lvItem:addChild(tempBtn)
    -- end

    -- 帮派势力标志
    local forceTexture = Enums.JHKBigPic[guildInfo.ForceId]
    if forceTexture then
        local forceSprite = ui.newSprite(forceTexture)
        forceSprite:setPosition(20, cellSize.height-30)
        lvItem:addChild(forceSprite)
    end

    -- 加入 或 取消 或 申请 按钮
    local tempStr = guildInfo.IsAutoApply and TR("加入") or TR("申请")
    local needStateBg = self.mApplyGuildListInfo[guildInfo.Id] and true or false   -- 是否显示已经申请图片
    if needStateBg then -- 已申请过的帮派
        tempStr = TR("取消")
        local spr = ui.newSprite("c_76.png")
        --spr:setRotation(25)
        spr:setPosition(500, 35)
        lvItem:addChild(spr)
        spr:setScale(0.8)
    end
    local tempBtn = ui.newButton({
        normalImage = "c_28.png",
        text = tempStr,
        clickAction = function()
                -- 势力是否相同
                local forceId = PlayerAttrObj:getPlayerAttrByName("JianghuKillForceId")
                if forceId ~= guildInfo.ForceId then
                    MsgBoxLayer.addOKCancelLayer(TR("加入该帮派需要选择%s，是否前往更换势力", Enums.JHKCampName[guildInfo.ForceId]), TR("重选势力"), {
                            text = TR("前往"),
                            clickAction = function (layerObj)
                                LayerManager.addLayer({name = "jianghuKill.JianghuKillSelectForceLayer"})
                            end,
                        })
                    return
                end
                if self.mApplyGuildListInfo[guildInfo.Id] then
                    self:requestGuildCancelApply(guildInfo, index)
                else
                    self:requestGuildApply(guildInfo, index)
                end
            end
        })
    tempBtn:setAnchorPoint(0.5, 0)
    tempBtn:setPosition(500, (needStateBg and 100 or 85) - 40)
    lvItem:addChild(tempBtn)

    -- 保存申请按钮，引导使用
    table.insert(self.applyBtnList, tempBtn)
end

-- =============================== 请求服务器数据相关函数 ===================

-- 获取帮派申请信息
function GuildSearchLayer:requestApplyGuildInfo()
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Guild",
        methodName = "GetApplyGuildInfo",
        svrMethodData = {self.mPagIndex, self.mHideFull},
        callbackNode = self,
        callback = function(response)
            if response.Status ~= 0 then
                if response.Status == -3404 then  -- 已经加入帮派了，直接进入帮派首页
                    LayerManager.addLayer({
                        name = "guild.GuildHomeLayer"
                    })
                end
                self.mIsScroll = true
                return
            end

            local value = response.Value

            -- 帮派信息的总页数
            self.mTotalPage = value.TotalPage
            -- 获取帮派信息当前页的Index
            self.mPagIndex = self.mPagIndex + 1

            -- 帮派信息列表
            for _, item in ipairs(value.GuildListInfo or {}) do
                table.insert(self.mGuildListInfo, item)
            end
            -- 已申请帮派信息列表
            for _, item in pairs(value.ApplyGuildListInfo or {}) do
                self.mApplyGuildListInfo[item.Id] = item
            end
            -- 玩家的帮派信息
            if value.PlayerGuildInfo then
                self.mPlayerGuildInfo = value.PlayerGuildInfo
            end

            --dump(value.PlayerGuildInfo, "玩家帮派信息")
            --dump(value.ApplyGuildListInfo[1], "已经申请的帮派")
            --dump(value.GuildListInfo[1], "所有帮派信息")

            -- 刷新列表
            self:refreshListView()

            -- 执行新手引导
            Utility.performWithDelay(self.mListView, handler(self, self.executeGuide), 0)
        end,
    })
end

-- 帮派查询
function GuildSearchLayer:requestGuildQuery()
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Guild",
        methodName = "GuildQuery",
        svrMethodData = {self.mSearchInfo, self.mPagIndex},
        callbackNode = self,
        callback = function(response)
            if response.Status ~= 0 then
                self.mIsScroll = true
                return
            end
            local value = response.Value

            -- 帮派信息的总页数
            self.mTotalPage = value.TotalPage

            -- 获取帮派信息当前页的Index
            self.mPagIndex = self.mPagIndex + 1

            -- 帮派信息列表
            for _, item in ipairs(value.GuildListInfo or {}) do
                table.insert(self.mGuildListInfo, item)
            end

            -- 刷新列表
            self:refreshListView()
        end,
    })
end

-- 玩家帮派申请
function GuildSearchLayer:requestGuildApply(guildInfo, index)
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Guild",
        methodName = "GuildApply",
        svrMethodData = {guildInfo.Id},
        guideInfo = Guide.helper:tryGetGuideSaveInfo(903),
        callbackNode = self,
        callback = function(response)
            if response.Status ~= 0 then
                return
            end
            local value = response.Value

            --[[--------新手引导--------]]--
            local _, _, eventID = Guide.manager:getGuideInfo()
            if eventID == 903 then
                -- 引导完成
                Guide.manager:nextStep(eventID)
                Guide.manager:removeGuideLayer()
            end

            -- 免审批的帮派
            if guildInfo.IsAutoApply and next(value.GuildInfo or {}) then
                if next(value.GuildInfo or {}) then
                    GuildObj:updateGuildAvatar({Id = guildInfo.Id, Name = guildInfo.Name})
                    -- 跳转到帮派主页
                    LayerManager.addLayer({
                        name = "guild.GuildHomeLayer",
                    })
                    return
                else
                    ui.showFlashView(TR("尚未加入帮派"))
                end
            end

            -- 更新已申请帮派信息列表
            self.mApplyGuildListInfo = {}
            for _, item in pairs(value.ApplyGuildListInfo or {}) do
                self.mApplyGuildListInfo[item.Id] = item
            end

            -- 刷新列表的当前条目
            self:refreshListItem(index)
        end,
    })
end

-- 玩家取消帮派申请
function GuildSearchLayer:requestGuildCancelApply(guildInfo, index)
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Guild",
        methodName = "GuildCancelApply",
        svrMethodData = {guildInfo.Id},
        callbackNode = self,
        callback = function(response)
            if response.Status ~= 0 then
                return
            end
            local value = response.Value

            -- 移除申请列表中的该条目
            self.mApplyGuildListInfo[guildInfo.Id] = nil

            -- 刷新列表的当前条目
            self:refreshListItem(index)
        end,
    })
end

-- ========================== 新手引导 ===========================
-- 执行新手引导
function GuildSearchLayer:executeGuide()
    -- 引导时屏蔽萌动
    local _, _, eventID = Guide.manager:getGuideInfo()
    if eventID == 903 then
        self.mListView:setTouchEnabled(false)
    end
    Guide.helper:executeGuide({
        -- 点击闯荡江湖
        [903] = {clickNode = self.applyBtnList[1]},
    })
end

return GuildSearchLayer
