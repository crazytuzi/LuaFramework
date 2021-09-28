--[[
    文件名：ShengyuanWarsRewardLayer.lua
    描述：圣渊奖励Layer
    创建人：chenzhong
    创建时间：2016.10.28
-- ]]

local ShengyuanWarsRewardLayer = class("ShengyuanWarsRewardLayer", function(params)
    return cc.Layer:create()
end)

local pageType = {
    ePer = 0,   -- 个人
    eSever = 1,   -- 服务端
}

function ShengyuanWarsRewardLayer:ctor(params)
    self.showTag = params and params.showTag or pageType.ePer
    -- 初始化页面
    self:initUI()
end

function ShengyuanWarsRewardLayer:initUI()
    -- 页面背景
    self.backSprite = ui.newSprite({
        image="ui/c_81.jpg",
        position=cc.p(display.cx, display.cy),
        scale=Adapter.MinScale,
        })
    self:addChild(self.backSprite)
    local titleLabel = ui.newLabel({
        text =  TR("奖励"),
        size = 35,
        x = 320,
        y = 1016,
        outlineSize = 1,
        outlineColor = display.COLOR_BLACK,
        color = Enums.Color.eYellow,
        font = _FONT_PANGWA
    })
    self.backSprite:addChild(titleLabel)

    -- 创建资源栏
    self.backSprite:addChild(createResourceObserverNodes(Enums.ResoureBarType.eFight, ResourcetypeSub.eGodDomainGlory))

    -- 退出按钮
    local closeBtn = ui.newButton({
        normalImage = "ui/c_115.png",
        position = cc.p(580, 1015),
        clickAction = function (sender)
            LayerManager.removeLayer(self)
        end
    })
    self.backSprite:addChild(closeBtn)

    local tabItems = {}
    tabItems[pageType.ePer] = {
        tag          = pageType.ePer,
        titleText    = TR("个 人"),
        titleSize    = 32,
        x            = 120,
        isDefault    = self.showTag == pageType.ePer,
    }
    tabItems[pageType.eSever] = {
        tag          = pageType.eSever,
        titleText    = TR("区 服"),
        titleSize    = 32,
        x            = 320,
        isDefault    = self.showTag == pageType.ePer,
    }

    local function cellOfPage(parent, tag)
        parent:removeAllChildren()
        if tag == pageType.ePer then
           self:showPerReward(parent)
        elseif tag == pageType.eSever then
            self:showSeverReward(parent)
        end
     end

    -- 创建tab
    self.tabLayer = ui.newTabLayer({
        normalImage = "ui/c_35.png",
        selectedImage = "ui/c_34.png",
        size = cc.size(640, 888),
        linePosY = 920,
        point = cc.p(0, 0),
        labelAnchorPoint = cc.p(0, 0),
        config = tabItems,
        cellHandler = cellOfPage,
    })
    self.backSprite:addChild(self.tabLayer)
end

-- 个人奖励
function ShengyuanWarsRewardLayer:showPerReward(parent)
    -- 创建ListView列表
    local listView = ccui.ListView:create()
    listView:setDirection(ccui.ScrollViewDir.vertical)
    listView:setBounceEnabled(true)
    listView:setGravity(ccui.ListViewGravity.centerVertical)
    listView:setContentSize(cc.size(640, 730))
    listView:setAnchorPoint(cc.p(0.5, 1))
    listView:setPosition(cc.p(320, 910))
    parent:addChild(listView)

    local itemCount = ShengyuanwarsPersonalrankRelation.items_count
    local minrank = 1
    for i = 1, itemCount do
        local resetTable
        for j, v in pairs(ShengyuanwarsPersonalrankRelation.items[minrank]) do
            resetTable = v
        end
        local config = {
            index = i,
            resListStr = resetTable.reward,
            minrank = minrank,
            maxrank = resetTable.rankMax
        }
        listView:pushBackCustomItem(self:createRewardView(config))
        minrank = resetTable.rankMax + 1
    end
end

function ShengyuanWarsRewardLayer:showSeverReward(parent)
    -- 创建ListView列表
    local listView = ccui.ListView:create()
    listView:setDirection(ccui.ScrollViewDir.vertical)
    listView:setBounceEnabled(true)
    listView:setGravity(ccui.ListViewGravity.centerVertical)
    listView:setContentSize(cc.size(640, 730))
    listView:setAnchorPoint(cc.p(0.5, 1))
    listView:setPosition(cc.p(320, 910))
    parent:addChild(listView)

    local itemCount = ShengyuanwarsServerrankRelation.items_count
    local minrank = 1
    for i = 1, itemCount do
        local resetTable
        for j, v in pairs(ShengyuanwarsServerrankRelation.items[minrank]) do
            resetTable = v
        end
        local config = {
            index = i,
            resListStr = resetTable.reward,
            minrank = minrank,
            maxrank = resetTable.rankMax
        }
        listView:pushBackCustomItem(self:createRewardView(config))
        minrank = resetTable.rankMax + 1
    end
end

function ShengyuanWarsRewardLayer:createRewardView(config)
    local itemCount = config.index
    local resListStr = config.resListStr
    local minrank = config.minrank
    local maxrank = config.maxrank
    local custom_item = ccui.Layout:create()
    local width = 600
    local height = 140

    custom_item:setContentSize(cc.size(width, height))
    --不同背景图片
    local imageList = {"ui/szds_58.png", "ui/szds_59.png", "ui/szds_60.png"}
    local backImage = ui.newSprite({
        image = imageList[itemCount] or "ui/szds_61.png",
        position = cc.p(320,70),
        })
    custom_item:addChild(backImage)
    local backContentSize = backImage:getContentSize()

    --下面排名
    local rankBgList = {"ui/szds_53.png", "ui/szds_54.png", "ui/szds_55.png"}

    local rankBg,minrankLabel,maxrankLabel,rankSize,conSp = nil, nil, nil, nil, nil
    --前三名来显示的头像，后面就是根据配置来进行加载才对
    if itemCount <= 3 and minrank == maxrank then
        rankBg = ui.newSprite({
            image = rankBgList[itemCount],
            position = cc.p(110,backContentSize.height/2)
        })
        backImage:addChild(rankBg)
    else
        rankBg = ui.newSprite({
            image = "ui/c_143.png",
            position = cc.p(110,backContentSize.height/2)
        })
        backImage:addChild(rankBg)
        rankSize = rankBg:getContentSize()

        if minrank ~= maxrank then
            minrankLabel = ui.newLabel({
                text = string.format("%s", minrank),
                size = 28,
            })
            minrankLabel:setPosition(cc.p(rankSize.width * 0.25,rankSize.height * 0.70))

            maxrankLabel = ui.newLabel({
                text = string.format("%s", maxrank),
                size = 28,
            })
            maxrankLabel:setPosition(cc.p(rankSize.width * 0.75,rankSize.height * 0.30))
            --中间符号
            conSp = ui.newLabel({
                text = string.format(" ~ "),
                size = 36
            })
            conSp:setPosition(cc.p(rankSize.width*0.47,rankSize.height*0.5))

            rankBg:addChild(minrankLabel)
            rankBg:addChild(maxrankLabel)
            rankBg:addChild(conSp)
        else
            minrankLabel = ui.newLabel({
                text = string.format("%s", minrank),
                size = 36,
            })
            minrankLabel:setPosition(cc.p(rankSize.width * 0.45,rankSize.height * 0.5))
            rankBg:addChild(minrankLabel)
        end
    end

    -- 奖励列表
    local listView = ccui.ListView:create()
    listView:setDirection(ccui.ScrollViewDir.horizontal)
    listView:setBounceEnabled(true)
    listView:setGravity(ccui.ListViewGravity.centerVertical)
    listView:setContentSize(cc.size(340, 110))
    listView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
    listView:setAnchorPoint(cc.p(0, 0))
    listView:setPosition(230, 15)
    listView:setSwallowTouches(false)
    backImage:addChild(listView)

    for i = 1, #AnalysisStrResList(resListStr) do
        local custom_item = ccui.Layout:create()
        local width = 105
        local height = 110

        custom_item:setContentSize(cc.size(width, height))

        local headerInfo = AnalysisStrResList(resListStr)[i]

        local header = Figure.newHeader({
            type = headerInfo.resourcetypeSub,
            itemId = headerInfo.modelId,
            count = headerInfo.count,
        })
        if header then
            custom_item:addChild(header)
        end

        listView:pushBackCustomItem(custom_item)
    end

    return custom_item
end

return ShengyuanWarsRewardLayer