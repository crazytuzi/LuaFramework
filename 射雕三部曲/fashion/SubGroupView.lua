--[[
	文件名:SubFashionView.lua
	描述：绝学列表的子页面
	创建人：peiyaoqiang
	创建时间：2017.09.15
--]]

local SubGroupView = class("SubGroupView", function()
    return display.newLayer()
end)

--[[
-- 参数 params 中各项为：
	{
		viewSize: 显示大小，必选参数
	}
]]
function SubGroupView:ctor(params)
    -- 读取参数
	self.viewSize = params.viewSize

	-- 初始化
	self:setContentSize(self.viewSize)

    -- 成员变量
    self.mCurIndex = self.mModelId or 1
    self.mCurButtonIndex = 1
    -- 计算数据
    self.mConfigs = self.calcConfigs()
    self.mCount = #self.mConfigs
    self.mActivationStates = self.calcCombinationStates()
    self.mTotalAddition = self.calcTotalAddition(self.mActivationStates)
    --存放切换按钮（前排 后排）
    self.mButtons = {}
    -- 界面初始化
    self:initUI()
end

local ButtonsConfig = {
    {x = 80, text = TR("前排"), target = 6},
    {x = 210, text = TR("后排"), target = 7},
}
-- 初始化UI
function SubGroupView:initUI()

    -- 滑动背景
    self.mPanelBg = ui.newSprite("zr_55.jpg")
    self.mPanelBg:setAnchorPoint(cc.p(0.5, 1))
    self.mPanelBg:setPosition(self.viewSize.width * 0.5, self.viewSize.height - 5)
    self:addChild(self.mPanelBg)
    self.mBgSize = self.mPanelBg:getContentSize()

    -- 前排后排
	local attrBgSize = cc.size(self.viewSize.width - 20, 130)
	self.mAttrBgSprite = ui.newScale9Sprite("c_65.png", attrBgSize)
	self.mAttrBgSprite:setAnchorPoint(cc.p(0.5, 0))
	self.mAttrBgSprite:setPosition(cc.p(self.viewSize.width * 0.5, 15))
	self:addChild(self.mAttrBgSprite)

    -- 文字提示
    local infoLabel = ui.newSprite("zr_52.png")
    infoLabel:setAnchorPoint(cc.p(1, 0.5))
    infoLabel:setPosition(self.viewSize.width - 15, 170)
    self:addChild(infoLabel)

    -- 选中按钮
    local function selectButton(newIndex)
        if self.mCurButtonIndex == newIndex then
            return
        end

        -- 把上次选中的状态取消
        for _,v in ipairs(self.mButtons) do
            if (v.index == self.mCurButtonIndex) then
                v:loadTextures("gd_26.png", "gd_26.png")
                break
            end
        end

        -- 设置这次选中的按钮状态
        for _,v in ipairs(self.mButtons) do
            if (v.index == newIndex) then
                v:loadTextures("gd_25.png", "gd_25.png")
                break
            end
        end
        self.mCurButtonIndex = newIndex

        self:showTotalAddition(self.mCurButtonIndex)
     end

    --将切换按钮存放到表中
    local tempButton = ui.newButton({
        normalImage = "gd_25.png",
        text = TR("前排"),
        titlePosRateY = 0.55,
        position = cc.p(85, 165),
        clickAction = function(sender)
            selectButton(sender.index)
        end
    })
    self:addChild(tempButton)
    tempButton.index = 1
    self.mButtons[tempButton.index] = tempButton

    -- 未选中按钮
    local tempButton = ui.newButton({
        normalImage = "gd_26.png",
        text = TR("后排"),
        titlePosRateY = 0.55,
        position = cc.p(205, 165),
        clickAction = function(sender)
            selectButton(sender.index)
        end
    })
    self:addChild(tempButton)
    tempButton.index = 2
    self.mButtons[tempButton.index] = tempButton


    self:showInfo()
end

-- 新建滑动列表
function SubGroupView:createSliderView()
    if self.mSliderView then
        self.mSliderView:reloadData()
        return
    end

    self.mSliderView = ui.newSliderTableView({
        width = self.mBgSize.width,
        height = self.mBgSize.height,
        isVertical = false,
        selItemOnMiddle = true,
        selectIndex = self.mCurIndex - 1,
        itemCountOfSlider = function(sliderView)
            return self.mCount
        end,
        itemSizeOfSlider = function(sliderView)
            return 640, 1136
        end,
        sliderItemAtIndex = function(sliderView, itemNode, selectIndex)
            local index = selectIndex + 1
            local item = self:createCombination(index)
            itemNode:addChild(item)
        end,
        selectItemChanged = function(pSender, selectItemIndex)
            local index = selectItemIndex + 1
            --控制左右按钮的显示隐藏
            self.mLeftButton:setVisible(index ~= 1)
            self.mRightButton:setVisible(index ~= self.mCount)
            --刷新下半部分的信息
            self:showTotalAddition(self.mCurButtonIndex)
        end
    })
    self.mSliderView:setPosition(self.mBgSize.width / 2, self.mBgSize.height - 100)
    self:addChild(self.mSliderView)

    -- 左滑按钮
    self.mLeftButton = ui.newButton({
        normalImage = "c_26.png",
        position = cc.p(0, 500),
        clickAction = function()
            local index = self.mSliderView:getSelectItemIndex()
            self.mSliderView:setSelectItemIndex(index - 1, true)
        end
    })
    self.mLeftButton:setScaleX(-1)
    self:addChild(self.mLeftButton)

    -- 右滑按钮
    self.mRightButton = ui.newButton({
        normalImage = "c_26.png",
        position = cc.p(580, 500),
        clickAction = function()
            local index = self.mSliderView:getSelectItemIndex()
            self.mSliderView:setSelectItemIndex(index + 1, true)
        end
    })
    self:addChild(self.mRightButton)

    local index = self.mCurIndex
    self.mLeftButton:setVisible(index ~= 1)
    self.mRightButton:setVisible(index ~= self.mCount)

end

-- 创建绝学
function SubGroupView:createCombination(index)
    local config = self.mConfigs[index]

    -- 容器
    local layout = ccui.Layout:create()
    local layout = ui.newScale9Sprite("c_83.png", cc.size(self.mBgSize.width, self.mBgSize.height))
    layout:setPosition(self.mBgSize.width / 2 + 45, self.mBgSize.height - 60)

    -- 单个绝学
    local members = string.splitBySep(config.memberS, ",")
    local fashionModel = FashionModel.items[tonumber(members[1])]
    
    --绝学名称背景
    local nameBg = ui.newSprite("zr_50.png")
    nameBg:setPosition(self.mBgSize.width / 2, self.mBgSize.height - 40)
    layout:addChild(nameBg)

    -- 绝学名称
    local tempLabel = ui.newLabel({
        text = config.name,
        size = 25,
        color = cc.c3b(0x51, 0x18, 0x0d),
    })
    tempLabel:setPosition(nameBg:getContentSize().width / 2, nameBg:getContentSize().height / 2)
    nameBg:addChild(tempLabel)

    -- 创建英雄
    local function createFigure(order, pos)
        local fashionModelId = tonumber(members[order])
        -- 已知绝学
        if fashionModelId > 0 then
            -- 绝学形象
            local fashionModel = FashionModel.items[fashionModelId]
            local figure = Figure.newHero({
                fashionModelID = fashionModelId,
                figureName = fashionModel.actionPic,
                scale = 0.25
            })
            figure:setPosition(pos)
            layout:addChild(figure)

            --绝学名背景
            local namebg = ui.newScale9Sprite("jsxy_08.png", cc.size(60, 220))
            namebg:setPosition(pos.x - 100, 350)
            layout:addChild(namebg)

            -- 绝学名称
            local nameLabel = ui.newLabel({
                text = fashionModel.name,
                size = 22,
                color = Enums.Color.eNormalWhite,
                color = cc.c3b(0x54, 0x22, 0x1d),
                dimensions = cc.size(30, 200)
            })
            nameLabel:setPosition(35, namebg:getContentSize().height / 2)
            namebg:addChild(nameLabel)

            --判断是否拥有
            if not FashionObj:getOneItemOwned(fashionModelId) then
                local tempSprite = ui.newSprite("zr_66.png")
                tempSprite:setPosition(pos.x, 500)
                layout:addChild(tempSprite, 1)
            end
        else
            -- 未知
            local tempLabel = ui.newLabel({
                text = TR("敬请期待"),
                color = Enums.Color.eNormalWhite,
                size = 24,
                dimensions = cc.size(10, 0),
                shadowColor = Enums.Color.eShadowColor,
            })
            tempLabel:setPosition((order % 2 == 0) and 500 or 50, 400)
            layout:addChild(tempLabel, 1)
        end

    end
    -- 左英雄
    createFigure(1, cc.p(150, 140))
    -- 右英雄
    createFigure(2, cc.p(450, 140))

    -- 显示属性加成
    local attrBg = ui.newSprite("hslj_04.png")
    attrBg:setPosition(self.viewSize.width / 2, 40)
    attrBg:setScaleX(2.7)
    layout:addChild(attrBg)

    -- 显示激活提示
    local tempLabel = ui.newLabel({
        text = self.mActivationStates[config.ID] and TR("属性加成对全体上阵成员有效") or TR("暂未激活绝学属性"),
        size = 22,
        color = self.mActivationStates[config.ID] and Enums.Color.eNormalGreen or Enums.Color.eRed,
    })
    tempLabel:setPosition(self.viewSize.width / 2, 65)
    layout:addChild(tempLabel)

    -- 当前加成属性
    local attrLabel = ui.newLabel({
        text = config.intro,
        size = 22,
    })
    attrLabel:setPosition(self.mBgSize.width / 2, 20)
    layout:addChild(attrLabel)

    return layout
end

-- 显示下半部分信息
function SubGroupView:showInfo()
    self:createSliderView()
    -- 显示总加成
    self:showTotalAddition(self.mCurButtonIndex)
end

-- 显示总加成
function SubGroupView:showTotalAddition(buttonIndex)
    self.mAttrBgSprite:removeAllChildren()

    local attrs = self.mTotalAddition[ButtonsConfig[buttonIndex].target]
    if attrs then
        -- 有加成
        local text = ""
        for fightattr, value in pairs(attrs) do
            local viewStr = string.format("#46220b%s%s%s",
                FightattrName[fightattr],
                "#249029", Utility.getAttrViewStr(fightattr, value, true)
            )
            text = text .. viewStr .. "    "
        end

        local hintLabel = ui.newLabel({
            text = text,
            size = 24,
            color = cc.c3b(0x46, 0x22, 0x0b),
        })
        hintLabel:setAnchorPoint(cc.p(0.5, 0.5))
        hintLabel:setPosition(self.mAttrBgSprite:getContentSize().width / 2, self.mAttrBgSprite:getContentSize().height / 2)
        self.mAttrBgSprite:addChild(hintLabel)
    else
        local tempLabel = ui.newLabel({
          text = TR("当前没有激活任何组合搭配"),
          color = cc.c3b(0x46, 0x22, 0x0b),
          size = 24,
        })
        tempLabel:setAnchorPoint(cc.p(0.5, 0.5))
        tempLabel:setPosition(self.mAttrBgSprite:getContentSize().width / 2, self.mAttrBgSprite:getContentSize().height / 2)
        self.mAttrBgSprite:addChild(tempLabel)
    end

end

-- 计算配置
function SubGroupView.calcConfigs()
    local configs = {}
    local hasCombination = {}
    for i, config in ipairs(FashionPrRelation.items) do
        table.insert(configs, config)
        -- 成员
        local members = string.splitBySep(config.memberS, ",")
        for i, member in pairs(members) do
            local fashionModelId = tonumber(member)
            hasCombination[fashionModelId] = true
        end
    end
    return configs
end

-- 计算组合状态
function SubGroupView.calcCombinationStates()
    local states = {}
    for i, config in pairs(FashionPrRelation.items) do
        local actived = true
        -- 成员
        local members = string.splitBySep(config.memberS, ",")
        for i, member in pairs(members) do
            local fashionModelId = tonumber(member)
            if not FashionObj:getOneItemOwned(fashionModelId) then
                actived = false
                break
            end
        end

        -- 保存
        states[config.ID] = actived
    end

    return states
end

-- 计算单个组合加成
function SubGroupView.calcAddition(index)
    local config = FashionPrRelation.items[index]
    local addition = {}

    local attrsList = string.splitBySep(config.allAttr, ",")
    for index, attrsStr in pairs(attrsList) do
        -- 加成目标
        local tempList = string.splitBySep(attrsStr, "||")
        local target = tonumber(tempList[1])
        -- 加成属性
        local tempList = string.splitBySep(tempList[2], "|")
        local fightattr = tonumber(tempList[1])
        local value = tonumber(tempList[2])

        -- 合并
        addition[target] = addition[target] or {}
        addition[target][fightattr] = addition[target][fightattr]
                and addition[target][fightattr] + value or value
    end

    return addition
end

-- 计算总加成
function SubGroupView.calcTotalAddition(activationStates)
    local totalAddition = {}

    for i, config in pairs(FashionPrRelation.items) do
        if activationStates[config.ID] then -- 已激活的
            local addition = SubGroupView.calcAddition(i)
            -- 合并
            for target, attrs in pairs(addition) do
                for fightattr, value in pairs(attrs) do
                    totalAddition[target] = totalAddition[target] or {}
                    totalAddition[target][fightattr] = totalAddition[target][fightattr]
                            and totalAddition[target][fightattr] + value or value
                end
            end
        end
    end

    return totalAddition
end

return SubGroupView
