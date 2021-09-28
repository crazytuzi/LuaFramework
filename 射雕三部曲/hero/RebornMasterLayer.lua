--[[
    文件名：RebornMasterLayer.lua
    描述：英雄经脉共鸣界面(队伍转生加成)
    创建人：zouhuajie
    创建时间：2017.8.31
-- ]]

local RebornMasterLayer = class("RebornMasterLayer", function()
    return display.newLayer()
end)

--[[
    params:
    {
        parent: 父节点
    }
]]
function RebornMasterLayer:ctor(params)
    self.mParentNode = params.parent
    
    -- 上阵人物信息
    self.mSlotHeroList = {}
    for _, item in ipairs(FormationObj:getSlotInfos()) do
        if Utility.isEntityId(item.HeroId) then
            local heroData = HeroObj:getHero(item.HeroId)
            table.insert(self.mSlotHeroList, heroData)
        end
    end
    -- 当前触发的经脉共鸣等级
    self.mCurrActiveLv = Utility.getActiveRebornLv()

    self:initUI()
end

-- 初始化
function RebornMasterLayer:initUI()
    self.mBgSize = cc.size(640, 740)

    local bgLayer = require("commonLayer.PopBgLayer").new({
        title = TR("经脉共鸣"),
        bgSize = self.mBgSize,
        closeImg = "c_29.png",
        closeAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self:addChild(bgLayer)
    self.mBgSprite = bgLayer.mBgSprite

    -- 创建上阵人物的列表
    self:createHeroList()
    -- 创建当前经脉共鸣的属性
    self:createMasterAttr()
end

-- 创建上阵人物的列表
function RebornMasterLayer:createHeroList()
    -- 人物列表的背景大小
    local listBgSize = cc.size(585, 370)
    -- 列表cell的大小
    self.mCeilSize = cc.size(570, 110)

    -- listview黑色背景框
    local listBgSprite = ui.newScale9Sprite("c_17.png", listBgSize)
    listBgSprite:setAnchorPoint(0.5, 1)
    listBgSprite:setPosition(self.mBgSize.width / 2, 670)
    self.mBgSprite:addChild(listBgSprite)

    -- 列表控件
    self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setContentSize(cc.size(listBgSize.width, listBgSize.height - 10))
    self.mListView:setItemsMargin(5)
    self.mListView:setGravity(ccui.ListViewGravity.centerHorizontal)
    self.mListView:setAnchorPoint(cc.p(0.5, 0.5))
    self.mListView:setPosition(listBgSize.width / 2, listBgSize.height / 2)
    listBgSprite:addChild(self.mListView)

    self:refreshListView()
end

-- 创建当前经脉共鸣的属性
function RebornMasterLayer:createMasterAttr()
    -- 属性背景框的大小
    local masterBgSize = cc.size(585, 265)

    -- 加成属性框
    local masterBgSprite = ui.createLabelWithBg({
        bgFilename = "c_37.png",
        bgSize = masterBgSize,
        labelStr = TR("经脉大师%d重", self.mCurrActiveLv),
        fontSize = 24,
        outlineColor = cc.c3b(0x5d, 0x28, 0x11),
        alignType = ui.TEXT_ALIGN_CENTER,
        offsetY = 112,
    })
    masterBgSprite:setAnchorPoint(0.5, 1)
    masterBgSprite:setPosition(self.mBgSize.width / 2, 292)
    self.mBgSprite:addChild(masterBgSprite)

    -- 创建当前等级和下一等级属性的背景
    local tempBgSize = cc.size(570, 175)
    local tempSprite = ui.newScale9Sprite("c_17.png", tempBgSize)
    tempSprite:setAnchorPoint(0.5, 1)
    tempSprite:setPosition(masterBgSize.width / 2, masterBgSize.height - 45)   
    masterBgSprite:addChild(tempSprite)

    -- 创建当前等级的共鸣属性
    self:createCurrLvView(tempSprite)
    -- 创建下一等级的共鸣属性
    self:createNextLvView(tempSprite)
    -- 箭头
    local arrowSprite = ui.newSprite("c_67.png")
    arrowSprite:setPosition(tempBgSize.width / 2 - 3, tempBgSize.height / 2)
    tempSprite:addChild(arrowSprite)

    -- 提示
    local hintLabel = ui.newLabel({
        text = TR("属性加成对全体有效"),
        color = Enums.Color.eBrown,
        size = 24,
    })
    hintLabel:setAnchorPoint(0.5, 1)
    hintLabel:setPosition(masterBgSize.width / 2, 37)
    masterBgSprite:addChild(hintLabel)
end

-- 刷新listview
function RebornMasterLayer:refreshListView()
    local function createItems(index)
        local layout = ccui.Layout:create()
        layout:setContentSize(self.mCeilSize)
        self.mListView:pushBackCustomItem(layout)

        for idx = index * 2 - 1, index * 2 do
            if idx > #self.mSlotHeroList then
                return
            end

            -- 英雄信息
            local heroData = self.mSlotHeroList[idx]
            -- 是否可以转身
            local allowReborn = heroData.RebornId and heroData.RebornId > 0 or false

            -- 是否是奇数
            local isOdd = (idx % 2 == 1)

            -- 条目中单个元素背景
            local halfCeilSize = cc.size((self.mCeilSize.width - 9) / 2, self.mCeilSize.height)
            local cellBgSprite = ui.newButton({
                    normalImage = "c_18.png", 
                    size = halfCeilSize,
                    clickAction = function ()
                        -- if heroData and heroData.RebornId then
                            -- 切换回父页面的指定人物界面
                            self:JumpToRebornLayerByIdx(idx)
                        -- end
                    end
                })
            cellBgSprite:setAnchorPoint(0, 0.5)
            if isOdd then
                cellBgSprite:setPosition(0, self.mCeilSize.height / 2 - 10)
            else
                cellBgSprite:setPosition((self.mCeilSize.width - 9) /2 + 7, self.mCeilSize.height / 2 - 10)
            end
            layout:addChild(cellBgSprite)

            -- 头像
            local cardSp = CardNode.createCardNode({
                instanceData = heroData,
                allowClick = true, --是否可点击
                fashionModelID = PlayerAttrObj:getPlayerAttrByName("FashionModelId"),
                cardShowAttrs = {CardShowAttr.eBorder},
                needGray = false,
                onClickCallback = function ()
                    if heroData and heroData.RebornId then
                        -- 切换回父页面的指定人物界面
                        self:JumpToRebornLayerByIdx(idx)
                    end
                end
            })
            cardSp:setAnchorPoint(0, 0.5)
            cardSp:setPosition(5, self.mCeilSize.height / 2)
            cellBgSprite:addChild(cardSp)

            -- 名字
            local nameStr = ConfigFunc:getHeroName(heroData.ModelId, {IllusionModelId = heroData.IllusionModelId, heroFashionId = heroData.CombatFashionOrder})
            local tempColor = Utility.getQualityColor(HeroModel.items[heroData.ModelId].quality, 1)
            local nameLabel = ui.newLabel({
                text = nameStr,
                color = tempColor,
                size = 22,
                anchorPoint = cc.p(0, 0.5),
            })
            nameLabel:setPosition(115, allowReborn and 70 or 80)
            cellBgSprite:addChild(nameLabel)

            --进度条
            if allowReborn then
                local tempLvModel = RebornLvModel.items[heroData.RebornId]
                local progressBar = require("common.ProgressBar").new({
                    bgImage = "kfdj_09.png",
                    barImage = "kfdj_08.png",
                    currValue = tempLvModel.rebornNum,  -- 当前进度
                    maxValue = math.min(self.mCurrActiveLv + 1, RebornLvActiveModel.items_count),
                    contentSize = cc.size(150, 25),
                    barType = ProgressBarType.eHorizontal, 
                    needLabel = true,  
                    needHideBg = false, 
                    percentView = false,
                    size = 19,
                    color = Enums.Color.eWhite,
                    outlineColor = Enums.Color.eBlack,
                })
                progressBar:setAnchorPoint(0, 0.5)
                progressBar:setPosition(113, 30)
                cellBgSprite:addChild(progressBar)
            else
                local tempLabel = ui.newLabel({
                    text = TR("橙色%s及以上品质侠客才能激活经脉.", Enums.Color.eCoffeeH),
                    color = Enums.Color.eOrange,
                    size = 18,
                    anchorPoint = cc.p(0, 0.5),
                    valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
                    dimensions = cc.size(150, 0),
                })
                tempLabel:setPosition(115, 40)
                cellBgSprite:addChild(tempLabel)
            end
        end
    end

    -- 移除所有条目并重新添加
    self.mListView:removeAllItems()
    for index = 1, math.ceil(#self.mSlotHeroList / 2) do
        createItems(index)
    end
end

-- 创建当前等级的经脉共鸣属性
function RebornMasterLayer:createCurrLvView(parentNode)
    -- 父节点的大小
    local parentSize = parentNode:getContentSize()
    -- 属性背景框的大小
    local attrBgSize = cc.size(250, 150)

    -- 创建属性背景
    local attrBgSprite = ui.createLabelWithBg({
        bgFilename = "c_54.png",
        bgSize = attrBgSize,
        labelStr = TR("目前等级"),
        fontSize = 24,
        outlineColor = cc.c3b(0x5d, 0x28, 0x11),
        alignType = ui.TEXT_ALIGN_CENTER,
        offsetY = 55,
    })
    attrBgSprite:setAnchorPoint(1, 0.5)
    attrBgSprite:setPosition(parentSize.width / 2 - 30, parentSize.height / 2)
    parentNode:addChild(attrBgSprite)

    if self.mCurrActiveLv == 0 then
        local tempLabel = ui.newLabel({
            text = TR("无加成"),
            size = 18,
            color = Enums.Color.eCoffee
        })
        tempLabel:setAnchorPoint(cc.p(0.5, 0.5))
        tempLabel:setPosition(attrBgSize.width / 2, attrBgSize.height / 2 - 10)
        attrBgSprite:addChild(tempLabel)
    else
        local viewCount = math.min(3, self.mCurrActiveLv) -- 最多显示3条
        local startLv = self.mCurrActiveLv - viewCount + 1
        local spaceY = 30
        local startPosY = 40 + (viewCount / 2) * spaceY
        for index = 1, viewCount do
            local tempLv = self.mCurrActiveLv - index + 1
            local intro = TR(RebornLvActiveModel.items[tempLv].intro)
            local i ,j = string.find(intro, "+")
            if i and j then
                intro = string.sub(intro, 1, i - 1) .. "#348032" .. string.sub(intro, j, #intro)
            end
            local tempLabel = ui.newLabel({
                text = intro,
                size = 18,
                color = Enums.Color.eCoffee
            })
            tempLabel:setAnchorPoint(cc.p(0, 0.5))
            tempLabel:setPosition(10, startPosY - (index - 1) * spaceY)
            attrBgSprite:addChild(tempLabel)
        end
    end
end

-- 创建下一等级的经脉共鸣属性
function RebornMasterLayer:createNextLvView(parentNode)
    -- 父节点的大小
    local parentSize = parentNode:getContentSize()
    -- 属性背景框的大小
    local attrBgSize = cc.size(250, 150)

    -- 创建属性背景
    local attrBgSprite = ui.createLabelWithBg({
        bgFilename = "c_54.png",
        bgSize = attrBgSize,
        labelStr = TR("下一等级"),
        fontSize = 24,
        outlineColor = cc.c3b(0x5d, 0x28, 0x11),
        alignType = ui.TEXT_ALIGN_CENTER,
        offsetY = 55,
    })
    attrBgSprite:setAnchorPoint(0, 0.5)
    attrBgSprite:setPosition(parentSize.width / 2 + 30, parentSize.height / 2)
    parentNode:addChild(attrBgSprite)

    -- 下一等级加成信息
    if self.mCurrActiveLv < RebornLvActiveModel.items_count then
        local activeModel = RebornLvActiveModel.items[self.mCurrActiveLv + 1]
        -- 
        local infoLabel = ui.newLabel({
            text = TR("6人经脉共鸣达到%s%s%s重", Enums.Color.eNormalGreenH, self.mCurrActiveLv + 1, Enums.Color.eCoffeeH),
            size = 18,
            color = Enums.Color.eCoffee
        })
        infoLabel:setPosition(120, 80)
        attrBgSprite:addChild(infoLabel)

        -- 
        local intro = TR(activeModel.intro)
        local i ,j = string.find(intro, "+")
        if i and j then
            intro = string.sub(intro, 1, i - 1) .. "#348032" .. string.sub(intro, j, #intro)
        end
        local introLabel = ui.newLabel({
            text = intro,
            size = 18,
            color = Enums.Color.eCoffee
        })
        introLabel:setPosition(120, 40)
        attrBgSprite:addChild(introLabel)
    else
        -- 已满级
        local tempLabel = ui.newLabel({
            text = TR("已满级"),
            size = 18,
            color = Enums.Color.eCoffee
        })
        tempLabel:setPosition(120, 80)
        attrBgSprite:addChild(tempLabel)
    end
end

-- 根据sliderview的索引, 切换到父页面的指定角色页面
function RebornMasterLayer:JumpToRebornLayerByIdx(index)
    local sliderView = self.mParentNode.mParent and self.mParentNode.mParent.mSliderView
    if tolua.isnull(sliderView) then
        return
    end
    print(string.format("sliderView %d to %d\r\n", sliderView.mSelectIndex, index - 1))
    sliderView.setSelectItemIndex(sliderView, index - 1, true)
    LayerManager.removeLayer(self)
end

return RebornMasterLayer
