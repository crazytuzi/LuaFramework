--[[
    文件名: DropWayLayer.lua
    描述：获取途径页面
    创建人：peiyaoqiang
    创建时间：2017.03.11
--]]

local DropWayLayer = class("DropWayLayer", function(params)
    return display.newLayer()
end)

-- 构造函数
--[[
-- 参数结构：
	{
		resourceTypeSub  		资源类型
	    modelId   				资源模型Id
        isTeacherGift           是否拜师礼物，默认为false，如果为true，则忽略上面两个参数
	}
--]]
function DropWayLayer:ctor(params)
    -- 变量
    self.isTeacherGift = (params.isTeacherGift ~= nil) and (params.isTeacherGift == true)
    if (self.isTeacherGift == false) then
        self.mResourceTypeSub = params.resourceTypeSub
        self.mModelId = params.modelId
    end

    -- 创建层
    self:createLayer()

    -- 获取数据
    if (self.isTeacherGift == true) then
        self.mItemsData = {
            {
                moduleID = 2202,
                moduleName = TR("武林谱"),
            },
            {
                moduleID = 2502,
                moduleName = TR("华山论剑")
            },
            {
                moduleID = 2002,
                moduleName = TR("道具商城"),
            },
        }
        self:showInfo()
    else
        Utility.getResourceDropWay(self.mResourceTypeSub, self.mModelId, function(itemsData)
            self.mItemsData = itemsData
            self:showInfo()
        end)
    end
end

local Width = 600
local Height = 505

-- 初始化界面
function DropWayLayer:createLayer()
    -- 创建背景
    local bgLayer = require("commonLayer.PopBgLayer").new({
        title = TR("获取途径"),
        bgSize = cc.size(Width, Height),
        closeAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self:addChild(bgLayer, -1)
    self.mBgSprite = bgLayer.mBgSprite

    -- 父节点
    local node = cc.Node:create()
    node:setPosition(0, Height)
    bgLayer.mBgSprite:addChild(node)
    self.mParentLayer = node

    -- 初始化控件
    self:initUI()
end

local HeadPosY = -110
local itemWidth = Width - 40
local itemHeight = 100
local offset = 5
-- 创建UI
function DropWayLayer:initUI()
    if (self.isTeacherGift == true) then
        local label = ui.newLabel({
            text = TR("拜师礼物%s可以通过以下途径获取", "#46220D"),
            size = 25,
            color = Enums.Color.eGreenInWhite,
            anchorPoint = cc.p(0.5, 1),
            x = itemWidth / 2,
            y = HeadPosY,
        })
        self.mParentLayer:addChild(label)
    else
        local cardShowAttrs = {CardShowAttr.eBorder}
        if Utility.isDebris(self.mResourceTypeSub) then
            table.insert(cardShowAttrs, CardShowAttr.eNum)
            table.insert(cardShowAttrs, CardShowAttr.eDebris)
        end
        -- 头像
        local x = 115
        local card = CardNode.createCardNode({
            resourceTypeSub = self.mResourceTypeSub,
            modelId = self.mModelId,
            cardShowAttrs = cardShowAttrs,
            cardShape = Enums.CardShape.eSquare,
            onClickCallback = function () end,
        })
        card:setPosition(x, HeadPosY - 5)
        self.mParentLayer:addChild(card)

        -- 名字
        x = x + 60
        local label = ui.newLabel({
            text = Utility.getGoodsName(self.mResourceTypeSub, self.mModelId),
            color = Utility.getColorValue(Utility.getColorLvByModelId(self.mModelId, self.mResourceTypeSub), 1),
            outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
            outlineSize = 2,
            anchorPoint = cc.p(0, 0),
            x = x,
            y = HeadPosY + 3,
        })
        self.mParentLayer:addChild(label)

        -- 提示
        local label = ui.newLabel({
            text = TR("可以通过以下途径获取"),
            color = cc.c3b(0x46, 0x22, 0x0d),
            anchorPoint = cc.p(0, 1),
            x = x,
            y = HeadPosY - 16,
        })
        self.mParentLayer:addChild(label)
    end

    -- 分割线
    local underSprite = ui.newScale9Sprite("c_17.png", cc.size(Width - 60, Height - 200))
    underSprite:setAnchorPoint(0.5, 1)
    underSprite:setPosition(Width * 0.5, HeadPosY - 65)
    self.mParentLayer:addChild(underSprite)

    -- 创建列表容器
    local listView = ccui.ListView:create()
    listView:setDirection(ccui.ScrollViewDir.vertical)
    listView:setBounceEnabled(true)
    listView:setContentSize(cc.size(itemWidth, Height - 220))
    listView:setGravity(ccui.ListViewGravity.centerVertical)
    listView:setItemsMargin(offset)
    listView:setAnchorPoint(cc.p(0.5, 1))
    listView:setPosition(Width/2, HeadPosY - 75)
    listView:setScrollBarEnabled(false)
    listView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
    self.mParentLayer:addChild(listView)
    self.mListView = listView
end

--- ==================== 显示相关 =======================
-- 显示信息
function DropWayLayer:showInfo()
    -- 添加控件
    table.sort(self.mItemsData, function (a, b)
        local isFbA = a.chapterModelId and true or false
        local isFbB = b.chapterModelId and true or false

        if isFbA and not isFbB then
            return false
        end
        if not isFbA and isFbB then
            return true
        end
        if isFbA and isFbB then
            if a.chapterModelId ~= b.chapterModelId then
                return a.chapterModelId < b.chapterModelId
            end
        end
        return a.moduleID > b.moduleID
    end)
    for i, data in ipairs(self.mItemsData) do
        local item = self:createItemLayout(data)
        self.mListView:pushBackCustomItem(item)
    end
end

-- 创建Item
function DropWayLayer:createItemLayout(data)
    -- 创建Item容器
    local layout = ccui.Layout:create()
    layout:setContentSize(itemWidth, itemHeight + 1)

    -- item背景
    local itemBg = ui.newScale9Sprite("c_18.png", cc.size(itemWidth - 30, itemHeight))
    itemBg:setPosition(itemWidth * 0.5, itemHeight * 0.5)
    layout:addChild(itemBg)

    -- 模块名字
    local x = 28
    local y = itemHeight/2 + 17

    local label = ui.newLabel({
        text = data.moduleName,
        color = cc.c3b(0x46, 0x22, 0x0d),
        anchorPoint = cc.p(0, 0.5),
        x = x,
        y = y,
    })
    layout:addChild(label)

    if not data.chapterModelId then
        y = itemHeight / 2
        label:setPosition(x, y)
    else
        -- 章节名字
        y = itemHeight/2 - 17
        local label = ui.newLabel({
            text =TR("第%s章 %s", data.chapterModelId - 10, BattleChapterModel.items[data.chapterModelId].name),
            color = cc.c3b(0x46, 0x22, 0x0d),
            anchorPoint = cc.p(0, 0.5),
            x = x,
            y = y,
        })
        layout:addChild(label)
    end

    -- 前往按钮
    x = itemWidth - 88
    y = itemHeight / 2
    local button = ui.newButton({
        text = TR("前往"),
        normalImage = "c_28.png",
        position = cc.p(x, y),
        clickAction = function()
            if data.chapterModelId then
                LayerManager.addLayer({
                    name = "battle.BattleNormalNodeLayer",
                    data = {chapterId = data.chapterModelId, nodeId = data.nodeModelId}
                })
            elseif data.moduleID == ModuleSub.eTimedRecruit then
                -- 如果是限时神将
                local activityData = ActivityObj:getActivityItem(data.moduleID)
                if activityData then
                    LayerManager.showSubModule(data.moduleID)
                else
                    ui.showFlashView({text = TR("活动暂未开启")})
                end
            elseif (data.moduleID == ModuleSub.eWorldBoss) or (data.moduleID == ModuleSub.eWorldBossAuction) then
                -- 如果是门派boss
                ui.showFlashView({text = TR("每日中午12点参加魔教入侵活动后，到拍卖行获取")})
            elseif data.moduleID == -1 then
                -- 单独通过活动产出的
                ui.showFlashView({text = TR("请关注运营活动")})
            else
                local paramsList = {
                    -- 跳转到锻造
                    [ModuleSub.eChallengeGrab] = {modelId = self.mModelId},
                }

                LayerManager.showSubModule(data.moduleID, paramsList[data.moduleID])
            end
        end
    })
    layout:addChild(button)

    -- 更改按钮状态
    if data.chapterIsOpen == false then
        button:setBright(false)
        button:setEnabled(false)
    end

    return layout
end

return DropWayLayer
