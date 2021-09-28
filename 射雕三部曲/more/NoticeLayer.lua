--[[
    文件名：NoticeLayer.lua
    描述：游戏公告
    创建人：peiyaoqiang
    创建时间：2017.6.21
-- ]]

local NoticeLayer = class("NoticeLayer", function(params)
    return display.newLayer(cc.c4b(0, 0, 0, 128))
end)

local OrderOfVersionPreview = -99   -- 版本预览
local OrderOfFashionView = -98      -- 绝学查看

function NoticeLayer:ctor()
    ui.registerSwallowTouch({node = self})

    -- 初始化页面
    self:initUI()
end

function NoticeLayer:initUI()
    local bgSprite = ui.newSprite("gg_02.png")
    bgSprite:setPosition(cc.p(display.cx, display.cy))
    bgSprite:setScale(Adapter.MinScale)
    self:addChild(bgSprite)

    self.mBgSprite = bgSprite
    self.mBgSize = bgSprite:getContentSize()

    -- 标题
    local titleSprite = ui.newSprite("gg_01.png")
    titleSprite:setPosition(self.mBgSize.width * 0.5, self.mBgSize.height)
    self.mBgSprite:addChild(titleSprite, 1)

    -- 线条
    local splitSprite = ui.newSprite("gg_05.png")
    splitSprite:setPosition(self.mBgSize.width * 0.5, self.mBgSize.height - 90)
    self.mBgSprite:addChild(splitSprite, 1)

    -- 开放提示文字
    -- 只在版本预告的时候显示，其他时候隐藏
    local openTimeLabel = ui.newLabel({
        text = TR("请关注更新公告"), 
        size = 16,
        color = cc.c3b(0x8c, 0x7d, 0x7d),
        dimensions = cc.size(120, 0)
        })
    openTimeLabel:setAnchorPoint(cc.p(0, 0))
    openTimeLabel:setPosition(cc.p(self.mBgSize.width / 2 + 80, 40))
    self.mBgSprite:addChild(openTimeLabel)
    self.openTimeLabel = openTimeLabel
    
    -- 确定按钮
    local okBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("确定"),
        clickAction = function()
            -- 关闭webView
            if self.webViewID then
                IPlatform:getInstance():closeWebView(self.webViewID)
                self.webViewID = nil
            end
            -- 关闭本页面
            LayerManager.removeLayer(self)
        end
        })
    okBtn:setPosition(cc.p(self.mBgSize.width / 2, 57))
    self.mBgSprite:addChild(okBtn)

    -- 获取网络数据
    self:requestGetNoticeList()

    -- 平时注释掉即可，不要删除
    -- 方便测试调整 WebView 的大小和位置
    -- local bgSprite = ui.newScale9Sprite("c_73.png", cc.size(460 * Adapter.MinScale, 580 * Adapter.MinScale))
    -- bgSprite:setAnchorPoint(cc.p(0, 0))
    -- bgSprite:setPosition(display.cx - 230 * Adapter.MinScale, display.cy - 290 * Adapter.MinScale)
    -- self:addChild(bgSprite)
end

-- 创建公告 tableview
function NoticeLayer:setUI()
    -- 定义一些变量
    local itemSize, titleList = cc.size(120, 75), {}
    local normalBtnImage, lightBtnImage = "gg_03.png", "gg_04.png"
    local normalTextColor, lightTextColor = cc.c3b(0xbb, 0xbf, 0xc5), cc.c3b(0xfb, 0xf1, 0xeb)
    local normalOutlineColor, lightOutlineColor = cc.c3b(0x28, 0x2a, 0x31), cc.c3b(0x72, 0x21, 0x20)
    
    -- 添加标题
    local function addTitleItem(parent, index)
        local data = self.mNoticeData[index]
        
        -- 按钮图片
        local titleSprite = ui.newSprite(normalBtnImage)
        titleSprite:setAnchorPoint(cc.p(0.5, 0))
        titleSprite:setPosition(cc.p(itemSize.width / 2, 0))
        parent:addChild(titleSprite)

        -- 按钮文字
        local titleLabel = ui.newLabel({
            text = data.Title, 
            size = 22,
            color = normalTextColor,
            outlineColor = normalOutlineColor
            })
        titleLabel:setAnchorPoint(cc.p(0.5, 0))
        titleLabel:setPosition(cc.p(itemSize.width / 2, 6))
        parent:addChild(titleLabel)

        -- 保存按钮
        titleList[index] = {sprite = titleSprite, label = titleLabel}
    end
    -- 加载某个普通页
    local function loadNormalLayer(data)
        local nodeSize = cc.size(460, 580)
        local bgNode = cc.Node:create()
        bgNode:setContentSize(nodeSize)
        bgNode:setIgnoreAnchorPointForPosition(false)
        bgNode:setAnchorPoint(cc.p(0.5, 0.5))
        bgNode:setPosition(self.mBgSize.width / 2, self.mBgSize.height / 2)
        self.mBgSprite:addChild(bgNode)
        self.bgNode = bgNode

        -- 左箭头
        local leftArrowSprite = ui.newSprite("c_26.png")
        leftArrowSprite:setPosition(0, 300)
        leftArrowSprite:setScale(-1)
        bgNode:addChild(leftArrowSprite, 1)

        -- 右箭头
        local rightArrowSprite = ui.newSprite("c_26.png")
        rightArrowSprite:setPosition(nodeSize.width, 300)
        bgNode:addChild(rightArrowSprite, 1)

        -- 刷新箭头
        local autoSliderIndex = 0
        local contentCount = #data.Content
        local function refreshArrow(index)
            leftArrowSprite:setVisible(index ~= 1)
            rightArrowSprite:setVisible(index < contentCount)
        end

        -- 显示图片
        local mSliderView = ui.newSliderTableView({
            width = nodeSize.width,
            height = nodeSize.height,
            isVertical = false,
            selItemOnMiddle = true,
            itemCountOfSlider = function(sliderView)
                return contentCount
            end,
            itemSizeOfSlider = function(sliderView)
                return nodeSize.width, nodeSize.height
            end,
            sliderItemAtIndex = function(sliderView, itemNode, index)
                local tmpData = data.Content[index + 1]
                local tmpSprite = ui.newSprite(tmpData.image)
                tmpSprite:setAnchorPoint(cc.p(0.5, 1))
                tmpSprite:setPosition(nodeSize.width / 2, nodeSize.height)
                itemNode:addChild(tmpSprite)

                -- 显示标题
                if (tmpData.title ~= nil) then
                    local titleLabel = ui.newLabel({
                        text = tmpData.title, 
                        size = 24,
                        color = cc.c3b(0xff, 0xf0, 0xfd),
                        outlineColor = cc.c3b(0x31, 0x20, 0x60),
                        })
                    titleLabel:setAnchorPoint(cc.p(0, 0.5))
                    titleLabel:setPosition(cc.p(7, 242))
                    itemNode:addChild(titleLabel)
                end

                -- 显示正文
                if (tmpData.text ~= nil) and (#tmpData.text > 0) then
                    local listSize = cc.size(nodeSize.width - 20, 200)
                    local listView = ccui.ListView:create()
                    listView:setItemsMargin(5)
                    listView:setDirection(ccui.ListViewDirection.vertical)
                    listView:setBounceEnabled(true)
                    listView:setAnchorPoint(cc.p(0.5, 1))
                    listView:setPosition(nodeSize.width / 2, 210)
                    itemNode:addChild(listView)

                    -- 添加文字
                    local maxHeight = 0
                    for _,v in ipairs(tmpData.text) do
                        local lvItem = ccui.Layout:create()
                        local tempLabel = ui.newLabel({
                            text = v,
                            color = Enums.Color.eNormalWhite,
                            outlineColor = Enums.Color.eBlack,
                            dimensions = cc.size(listSize.width, 0)
                        })
                        local labelSize = tempLabel:getContentSize()
                        tempLabel:setAnchorPoint(cc.p(0, 0.5))
                        tempLabel:setPosition(0, labelSize.height / 2)
                        lvItem:addChild(tempLabel)
                        lvItem:setContentSize(labelSize)
                        listView:pushBackCustomItem(lvItem)
                        -- 
                        maxHeight = maxHeight + labelSize.height + 5
                    end
                    if maxHeight < listSize.height then
                        listView:setTouchEnabled(false)
                    end
                    listView:setContentSize(cc.size(listSize.width, math.min(maxHeight, listSize.height)))
                end
            end,
            selectItemChanged = function(sliderView, selectIndex)
                refreshArrow(selectIndex + 1)
                autoSliderIndex = selectIndex + 1

                -- 玩家触摸以后下次不在自动翻页
                if self.isTouch then
                    bgNode:stopAllActions()
                end
            end,
            -- 监听玩家触摸
            onTouchBegin = function ()
                self.isTouch = true
            end
        })
        mSliderView:setTouchEnabled(true)
        mSliderView:setAnchorPoint(cc.p(0.5, 0.5))
        mSliderView:setPosition(nodeSize.width / 2, nodeSize.height / 2)
        bgNode:addChild(mSliderView)
        refreshArrow(1)

        -- 添加自动滑动的动画
        Utility.schedule(bgNode, function () 
                -- 到最后一页停止播放
                if (autoSliderIndex >= contentCount) then
                    bgNode:stopAllActions()
                    return
                end
                -- 列表切换使用的index是从0开始的，所以这里不用加1就是跳转到下一页
                mSliderView:setSelectItemIndex(autoSliderIndex, true)
            end, 1.5)
    end
    -- 加载某个网页
    local function loadWebLayer(data)
        -- 背景图父节点
        local nodeSize = cc.size(460, 580)
        self.mWebNode = cc.Node:create()
        self.mWebNode:setContentSize(nodeSize)
        self.mWebNode:setIgnoreAnchorPointForPosition(false)
        self.mWebNode:setAnchorPoint(cc.p(0.5, 0.5))
        self.mWebNode:setPosition(self.mBgSize.width / 2, self.mBgSize.height / 2)
        self.mBgSprite:addChild(self.mWebNode)
        -- 背景图列表
        local bgSpriteList = {}
        -- 第一个图片参数
        if data.Pic and data.Pic ~= "" then
            local bgSprite = ui.newSprite(data.Pic)
            if bgSprite then
                table.insert(bgSpriteList, data.Pic)
                bgSprite:removeFromParent()
            end
        end
        -- 第二个图片参数
        if data.SmallPic and data.SmallPic ~= "" then
            local bgSprite = ui.newSprite(data.SmallPic)
            if bgSprite then
                table.insert(bgSpriteList, data.SmallPic)
                bgSprite:removeFromParent()
            end
        end
        -- 只有一张图
        if #bgSpriteList == 1 then
            local sprite = ui.newSprite(bgSpriteList[1])
            sprite:setPosition(nodeSize.width*0.5, nodeSize.height*0.5)
            self.mWebNode:addChild(sprite)
        elseif #bgSpriteList > 1 then
            -- 左箭头
            local leftArrowSprite = ui.newSprite("c_26.png")
            leftArrowSprite:setPosition(0, 300)
            leftArrowSprite:setScale(-1)
            self.mWebNode:addChild(leftArrowSprite, 1)

            -- 右箭头
            local rightArrowSprite = ui.newSprite("c_26.png")
            rightArrowSprite:setPosition(nodeSize.width, 300)
            self.mWebNode:addChild(rightArrowSprite, 1)

            -- 刷新箭头
            local autoSliderIndex = 0
            local contentCount = #bgSpriteList
            local function refreshArrow(index)
                leftArrowSprite:setVisible(index ~= 1)
                rightArrowSprite:setVisible(index < contentCount)
            end
            -- 显示图片
            local webSliderView = ui.newSliderTableView({
                width = nodeSize.width,
                height = nodeSize.height,
                isVertical = false,
                selItemOnMiddle = true,
                itemCountOfSlider = function(sliderView)
                    return contentCount
                end,
                itemSizeOfSlider = function(sliderView)
                    return nodeSize.width, nodeSize.height
                end,
                sliderItemAtIndex = function(sliderView, itemNode, index)
                    local sprite = ui.newSprite(bgSpriteList[index+1])
                    sprite:setPosition(nodeSize.width*0.5, nodeSize.height*0.5)
                    itemNode:addChild(sprite)
                end,
                selectItemChanged = function(sliderView, selectIndex)
                    refreshArrow(selectIndex + 1)
                    autoSliderIndex = selectIndex + 1

                    -- 玩家触摸以后下次不在自动翻页
                    if self.isTouch then
                        self.mWebNode:stopAllActions()
                    end
                end,
                -- 监听玩家触摸
                onTouchBegin = function ()
                    self.isTouch = true
                end
            })
            webSliderView:setTouchEnabled(true)
            webSliderView:setAnchorPoint(cc.p(0.5, 0.5))
            webSliderView:setPosition(nodeSize.width / 2, nodeSize.height / 2)
            self.mWebNode:addChild(webSliderView)

            -- 添加自动滑动的动画
            Utility.schedule(self.mWebNode, function () 
                -- 到最后一页停止播放
                if (autoSliderIndex >= contentCount) then
                    self.mWebNode:stopAllActions()
                    return
                end
                -- 列表切换使用的index是从0开始的，所以这里不用加1就是跳转到下一页
                webSliderView:setSelectItemIndex(autoSliderIndex, true)
            end, 1.5)
        end

        -- 有图片则不创建网页
        if #bgSpriteList == 0 then
            self.webViewID = IPlatform:getInstance():openWebView(
                display.cx - 230 * Adapter.MinScale,
                display.cy - 290 * Adapter.MinScale,
                460 * Adapter.MinScale, 580 * Adapter.MinScale,
                data.Content
                )
        end
    end
    -- 切换显示Tab页面
    local currentTag = 0
    local function showTabLayer(index)
        if (currentTag == index) then
            return
        end

        -- 隐藏以前的内容
        if (self.webViewID ~= nil) then
            IPlatform:getInstance():closeWebView(self.webViewID)
            self.webViewID = nil
        end

        if self.mWebNode and not tolua.isnull(self.mWebNode) then
            self.mWebNode:removeFromParent()
            self.mWebNode = nil
        end

        if (self.bgNode ~= nil) then
            self.bgNode:removeFromParent()
            self.bgNode = nil
        end

        -- 切换标题
        for _,v in ipairs(titleList) do
            v.sprite:setTexture(normalBtnImage)
            v.label:setColor(normalTextColor)
            v.label:enableOutline(normalOutlineColor)
        end
        titleList[index].sprite:setTexture(lightBtnImage)
        titleList[index].label:setColor(lightTextColor)
        titleList[index].label:enableOutline(lightOutlineColor)
        
        -- 读取数据并处理标题
        local itemData = self.mNoticeData[index]
        self.openTimeLabel:setVisible(itemData.Order == OrderOfVersionPreview)

        -- 处理内容的显示
        if (itemData.NoWebView ~= nil) and (itemData.NoWebView == true) then
            loadNormalLayer(itemData)
        else
            loadWebLayer(itemData)
        end
        currentTag = index
    end

    -- 创建滑动tableview
    self.tableView = ui.newSliderTableView({
        width = 460,
        height = 80,
        isVertical = false,
        selItemOnMiddle = false,
        itemCountOfSlider = function()
            return table.maxn(self.mNoticeData)
        end,
        itemSizeOfSlider = function(pSender, itemIndex)
            return itemSize.width, itemSize.height
        end,
        sliderItemAtIndex = function(sliderView, itemNode, index)
            addTitleItem(itemNode, index + 1)
        end,
        onItemClecked = function(sliderView, index)
            showTabLayer(index + 1)
        end,
    })
    self.tableView:setAnchorPoint(cc.p(0, 0.5))
    self.tableView:setPosition(cc.p(47, 714))
    self.mBgSprite:addChild(self.tableView)

    -- 默认打开第一个页面
    if self.mNoticeData and type(self.mNoticeData) == "table" and next(self.mNoticeData) ~= nil then
        showTabLayer(1)
    end
end

-- 生成要显示的内容
function NoticeLayer:makeData(serverData)
    -- 优先添加版本预告和绝学展示
    self.mNoticeData = {
        -- {
        --     Title = TR("遊戲公告"), 
        --     NoWebView = true, 
        --     Order = OrderOfVersionPreview,
        --     Content = {
        --         {image = "gg_91.png"},
        --         {image = "gg_92.jpg"},
        --         {image = "gg_81.png"},
        --         {image = "gg_61.png"},
        --         {image = "gg_71.png"},
        --         {image = "gg_21.png"},
        --         {image = "gg_41.png"},
        --         {image = "gg_51.png"},
        --         {image = "gg_2.jpg"},
        --         {image = "gg_06.jpg"},
        --         -- {
        --             -- image = "gg_2.jpg", 
        --             -- title = TR("规则"),
        --             -- text = {
        --             --     TR("1.侠客幻化只改变侠客的外形、技能、突破天赋，不会改变羁绊属性。"),
        --             --     TR("2.侠客幻化后，原来侠客的所有培养状态全部保留，并且原侠客所有培养消耗的资源不会改变。"),
        --             --     TR("3.只有传说侠客可以进行幻化。"),
        --             -- }
        --         -- },
        --     }
        -- },
        -- {
        --     Title = TR("绝学展示"), 
        --     NoWebView = true,
        --     Order = OrderOfFashionView, 
        --     Content = {
        --         {image = "gg_10.png"},
        --         {image = "gg_11.png"},
        --     }
        -- },
    }
    -- 图片展示页签（版本预告，绝学展示）从服务器返回的数据中读取
    -- 排序
    table.sort(serverData.NoticeTrailInfo, function (noticeInfo1, noticeInfo2)
        return noticeInfo1.OrderId < noticeInfo2.OrderId
    end)
    for _,v in ipairs(serverData.NoticeTrailInfo) do
        local tempList = string.splitBySep(v.Content or "", ",")
        v.Content = {}
        for _, picName in ipairs(tempList) do
            local picItem = {image = picName}
            table.insert(v.Content, picItem)
        end
        v.NoWebView = true
        table.insert(self.mNoticeData, clone(v))
    end

    -- web展示页签（联系客服，更新公告）从服务器返回的数据中读取
    -- 排序
    table.sort(serverData.NoticeInfo, function (noticeInfo1, noticeInfo2)
        return noticeInfo1.Order < noticeInfo2.Order
    end)
    for _,v in ipairs(serverData.NoticeInfo) do
        table.insert(self.mNoticeData, clone(v))
    end

    self:setUI()
end

--[[------------网络请求-----------]]--
function NoticeLayer:requestGetNoticeList()
    HttpClient:request({
        moduleName = "Notice",
        methodName = "GetNoticeList",
        svrMethodData = {},
        callbackNode = self,
        callback = function(data)
            if not tolua.isnull(self) then
                self:makeData(data.Value or {})
            end
        end,
    })
end

return NoticeLayer
