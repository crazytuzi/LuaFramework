--[[
    文件名：HeroRecruitShowAllLayer.lua
    描述：英雄招募之全部英雄预览页面
    创建人：libowen
    修改人：chenqiang
    创建时间：2016.5.5
--]]

-- 此页面由LayerManager添加，需适配
local HeroRecruitShowAllLayer = class("HeroRecruitShowAllLayer", function(params)
    return cc.LayerColor:create()
end)

-- 构造函数
--[[
    params:
    Table params:
    {
        heroList                    -- 必须的参数，英雄列表，元素为英雄的modelId
    }
--]]
function HeroRecruitShowAllLayer:ctor(params)
    -- 原始英雄列表
    self.mHeroList = params and params.heroList

    -- 英雄星级由高到低，配置新表
    self:configHeroCategoryList()

    -- 添加UI元素
    self:initUI()
end

-- UI相关
function HeroRecruitShowAllLayer:initUI()
    -- 添加弹出框层
    local bgLayer = require("commonLayer.PopBgLayer").new({
        title = TR("招募预览"),
        bgSize = cc.size(640, 930),
        closeImg = "c_29.png",
        closeAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self:addChild(bgLayer)

    -- 保存弹窗控件信息
    self.mBgSprite = bgLayer.mBgSprite
    self.mBackSize = bgLayer.mBgSprite:getContentSize()

    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 背景框
    local backSprite = ui.newScale9Sprite("c_17.png", cc.size(580, 840))
    backSprite:setAnchorPoint(0.5, 0)
    backSprite:setPosition(self.mBackSize.width * 0.5, 25)
    self.mBgSprite:addChild(backSprite)

    -- 创建listView
    self:createListView()
end

-- 按照英雄星级分类获得新表
function HeroRecruitShowAllLayer:configHeroCategoryList()
    -- local maxColorLv = 0
    -- -- 获取预览英雄列表中的最高ColorLv
    -- for i, v in ipairs(self.mHeroList) do
    --     local colorLv = Utility.getColorLvByModelId(v)
    --     if colorLv >= maxColorLv then
    --         maxColorLv = colorLv
    --     end
    -- end

    -- 将同一星级的放入同一列表中，最后再放入一个总表中
    self.mCategoryList = {}
    for _, modelId in ipairs(self.mHeroList) do
        local tmpQuality = HeroModel.items[modelId].quality
        if (self.mCategoryList[tmpQuality] == nil) then
            self.mCategoryList[tmpQuality] = {}
        end
        table.insert(self.mCategoryList[tmpQuality], modelId)
    end



    -- for colorLv = maxColorLv, 1, -1 do
    --     local tempList = {}
    --     for index, modelId in ipairs(self.mHeroList) do
    --         if colorLv == Utility.getColorLvByModelId(modelId) then
    --             table.insert(tempList, modelId)
    --         end
    --     end

    --     if #tempList > 0 then
    --         table.insert(self.mCategoryList, tempList)
    --     end
    -- end
end

-- 创建listView
function HeroRecruitShowAllLayer:createListView()
    -- 创建listView
    local listView = ccui.ListView:create()
    listView:setDirection(ccui.ScrollViewDir.vertical)
    listView:setBounceEnabled(true)                             -- 设置弹力
    listView:setContentSize(cc.size(570, 820))
    listView:setGravity(ccui.ListViewGravity.centerVertical)    -- 设置重力
    listView:setItemsMargin(10)                                 -- 改变两个cell之间的边界
    listView:setAnchorPoint(cc.p(0.5, 0))
    listView:setPosition(self.mBackSize.width * 0.5, 35)
    self.mBgSprite:addChild(listView)
    -- 设置取消listView动画
    listView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)

    -- 向listView添加数据
    -- for index, list in ipairs(self.mCategoryList) do
    --     listView:pushBackCustomItem(self:createCell(index, list))
    -- end

    -- 倒序遍历所有品质
    for i=table.maxn(QualityModel.items),1,-1 do
        local tmpList = self.mCategoryList[i]
        if (tmpList ~= nil) then
            listView:pushBackCustomItem(self:createCell(i, tmpList))
        end
    end
end

--[[
params:
    quality     -- cell的索引号
    list        -- 每一个类别的英雄表
return:
    custom      -- 返回自定义cell
--]]
function HeroRecruitShowAllLayer:createCell(quality, list)
    -- cell的宽高，每4个为1行
    local row = math.ceil(#list / 5)
    local cellWidth = 570
    local cellHeight = (70 + row * 130)

    -- 创建layout
    local customCell = ccui.Layout:create()
    customCell:setContentSize(cc.size(cellWidth, cellHeight))
    customCell:setAnchorPoint(cc.p(0.5, 1))

    -- 背景框
    local bgSprite = ui.newScale9Sprite("c_54.png", cc.size(cellWidth, cellHeight))
    bgSprite:setPosition(cellWidth * 0.5, cellHeight * 0.5)
    customCell:addChild(bgSprite)

    -- 等级名字
    local nameLabel = ui.newLabel({
        text = Utility.getHeroColorName(quality),
        size = 24,
        outlineColor = cc.c3b(0x83, 0x49, 0x38),
        outlineSize = 2
    })
    nameLabel:setPosition(cellWidth * 0.5, cellHeight - 20)
    customCell:addChild(nameLabel)

    -- 头像X坐标
    local posX = {cellWidth * 0.11, cellWidth * 0.305, cellWidth * 0.5, cellWidth * 0.695, cellWidth * 0.89}
    -- 英雄头像
    for i = 1, #list do
        local heroCard = CardNode.createCardNode({
            modelId = list[i],
            resourceTypeSub = ResourcetypeSub.eHero,
            cardShowAttrs = {
                CardShowAttr.eBorder,
                CardShowAttr.eName
            }
        })
        local x = posX[i % 5 == 0 and 5 or i % 5]
        local y = cellHeight - 105 - (math.ceil(i / 5) - 1) * 130
        heroCard:setPosition(cc.p(x, y))
        customCell:addChild(heroCard)
    end

    return customCell
end

return HeroRecruitShowAllLayer
