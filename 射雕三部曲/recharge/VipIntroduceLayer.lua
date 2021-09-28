--[[
    文件名：VipIntroduceLayer.lua
    描述：VIP会员介绍页面
    创建人：libowen
    修改人：chenqiang
    创建时间：2016.5.17
-- ]]

-- 该页面由LayerManager直接添加，需要适配
local VipIntroduceLayer = class("VipIntroduceLayer", function(params)
    return display.newLayer()
end)

-- 构造函数
function VipIntroduceLayer:ctor(params)
    -- 屏蔽底层触摸事件
    ui.registerSwallowTouch({node = self})

    -- 参数
    --父节点
    self.mParent = params.parent
    -- 玩家所能达到的最大的Vip等级
    self.mMaxVipLv = VipModel.items_count - 1
    -- 初始化UI元素
    self:initUI()
end

-- 添加UI相关元素
function VipIntroduceLayer:initUI()
    -- UI元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    --- 页面背景图
    -- self.mBgSpr = ui.newScale9Sprite("cz_03.png", cc.size(640, 720))
    self.mBgSpr = ui.newSprite("xshd_05.png")
    self.mBgSpr:setPosition(320, 568)
    self.mParentLayer:addChild(self.mBgSpr)
    self.mBgSize = self.mBgSpr:getContentSize()

    -- 创建分页滑动控件
    self.mSliderView = ui.newSliderTableView({
        width = self.mBgSize.width,
        height = self.mBgSize.height,
        isVertical = false,
        selectIndex = 0,
        selItemOnMiddle = true,
        itemCountOfSlider = function(sliderView)
            return VipLvIntroRelation.items_count
        end,
        itemSizeOfSlider = function(sliderView)
            return self.mBgSize.width, self.mBgSize.height
        end,
        sliderItemAtIndex = function(sliderView, itemNode, index, isSelected)
            self:addVipDescAndRewardView(itemNode, index)
        end,
        selectItemChanged = function(sliderView, selectIndex)
        end
    })
    self.mSliderView:setPosition(self.mBgSize.width * 0.5, self.mBgSize.height * 0.5)
    self.mBgSpr:addChild(self.mSliderView)
    -- 不可通过左右滑动来翻页，只能通过点击左右按钮来翻页
    self.mSliderView:setTouchEnabled(false)
    self.mSliderView:setSelectItemIndex(PlayerAttrObj:getPlayerAttrByName("Vip") + 1)

    -- 底部进度条
    self:addProgressBar()

    -- 关闭按钮
    self.mCloseBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(610, 1085),
        clickAction = function()
            -- 恢复父界面的组件
            self.mParent.mChildLayer:setVisible(true)
            self.mParent.mBottomRechargeListView:setVisible(true)
            self.mParent.mCloseBtn:setVisible(true)

            self:removeFromParent()
        end
    })
    self.mParentLayer:addChild(self.mCloseBtn)

    -- 左翻页按钮
    local btnLeft =  ui.newButton({
        normalImage = "c_26.png",
        clickAction = function()
            local index = self.mSliderView:getSelectItemIndex()
            if index - 1 >= 0 then 
                self.mSliderView:setSelectItemIndex(index - 1) 
            end
        end
    })
    btnLeft:setAnchorPoint(cc.p(0, 0.5))
    btnLeft:setPosition(40, self.mBgSize.height * 0.35 + 110)
    btnLeft:setFlippedX(true)
    self.mBgSpr:addChild(btnLeft)

    -- 右翻页按钮
    local btnRight = ui.newButton({
        normalImage = "c_26.png",
        clickAction = function()
            local index = self.mSliderView:getSelectItemIndex()
            if index + 1 <= self.mMaxVipLv then 
                self.mSliderView:setSelectItemIndex(index + 1) 
            end   
        end
    })
    btnRight:setAnchorPoint(cc.p(0, 0.5))
    btnRight:setPosition(self.mBgSize.width - 40, self.mBgSize.height * 0.35 + 110)
    self.mBgSpr:addChild(btnRight)
    -- btnRight:setFlippedX(true)
end

-- 添加Vip会员描述及奖励列表
function VipIntroduceLayer:addVipDescAndRewardView(itemNode, itemIndex)
    --标题背景
    local titleBgSpite = ui.newScale9Sprite("c_25.png", cc.size(550, 54))
    titleBgSpite:setPosition(self.mBgSize.width * 0.5,self.mBgSize.height * 0.925)
    itemNode:addChild(titleBgSpite)
    -- Vip标题
    local vipLvTitle = ui.newLabel({
        text = TR("#FFE569VIP#FFFFFF%d#FFE569特权", itemIndex),
        outlineColor = Enums.Color.eWineRed,
        x = self.mBgSize.width * 0.5,
        y = self.mBgSize.height * 0.925,
        align = ui.TEXT_ALIGN_CENTER
    })
    itemNode:addChild(vipLvTitle)

    -- 背景框
    local bg = ui.newScale9Sprite("xshd_27.png", cc.size(586, 365))
    bg:setPosition(self.mBgSize.width * 0.5, self.mBgSize.height * 0.73)
    bg:setOpacity(200)
    itemNode:addChild(bg)
    
    -- VIP会员内容列表
    local vipIntroItem = VipLvIntroRelation.items[itemIndex]
    local lvSize = cc.size(535, 340)
    local tempListView = ccui.ListView:create()
    tempListView:setDirection(ccui.ScrollViewDir.vertical)
    tempListView:setBounceEnabled(true)
    tempListView:setContentSize(lvSize)
    tempListView:setItemsMargin(15)
    tempListView:setPosition(bg:getContentSize().width * 0.5, bg:getContentSize().height*0.96)
    tempListView:setAnchorPoint(cc.p(0.5, 1.0))
    tempListView:setChildrenActionType(0) 
    bg:addChild(tempListView)

    for index = 1, #vipIntroItem do
        -- 创建cell
        local cell = ccui.Layout:create()
        cell:setAnchorPoint(cc.p(0, 1))
        cell:setContentSize(cc.size(535, 0))
        
        -- 文字描述标签
        local introLabel = ui.newLabel({
            text = vipIntroItem[index].intro,
            dimensions = cc.size(520, 0),
            color = Enums.Color.eNormalWhite
        })
        local cellHeight = introLabel:getContentSize().height
        cell:setContentSize(cc.size(535, cellHeight))

        introLabel:setAnchorPoint(cc.p(0.5, 1))
        introLabel:setPosition(cell:getContentSize().width * 0.5, cellHeight)
        cell:addChild(introLabel)
        tempListView:pushBackCustomItem(cell)
    end

    -- "每日领取"标签
    local centerLabel = ui.createAttrTitle({
        leftImg = "xct_03.png",
        titleStr = TR("每日领取"),
        color = Enums.Color.eNormalWhite,
        outlineColor = Enums.Color.eBlack
    })
    centerLabel:setPosition(self.mBgSize.width * 0.5, self.mBgSize.height * 0.53)
    itemNode:addChild(centerLabel)

    -- 奖品滑动窗体
    local rewardList = Utility.analysisStrResList(VipWelfareModel.items[itemIndex].resourceList)
    local listView = ui.createCardList({
        maxViewWidth = 520, 
        space = 10, 
        cardDataList = rewardList,
        cardShape = Enums.CardShape.eCircle
    })
    listView:setAnchorPoint(cc.p(0.5, 0.5))
    listView:setPosition(self.mBgSize.width * 0.5, self.mBgSize.height * 0.43)
    itemNode:addChild(listView)

    --下方展示图片1
    local tjlShowSprite = ui.newSprite("cz_13.png")
    tjlShowSprite:setPosition(self.mBgSize.width * 0.3, self.mBgSize.height * 0.2)
    itemNode:addChild(tjlShowSprite)
    local tjlShowLabel = ui.newLabel({
        text = TR("测试文字\n+%s%%",151),
        size = 20,
        color = Enums.Color.eNormalWhite,
        })
    tjlShowLabel:setPosition(tjlShowSprite:getContentSize().width * 0.5, tjlShowSprite:getContentSize().height * 0.2)
    tjlShowSprite:addChild(tjlShowLabel)
    --下方展示图片2
    local xhbShowSprite = ui.newSprite("cz_12.png")
    xhbShowSprite:setPosition(self.mBgSize.width * 0.7, self.mBgSize.height * 0.2)
    itemNode:addChild(xhbShowSprite)
    local xhbShowLabel = ui.newLabel({
        text = TR("测试文字\n+%s%%",31),
        size = 20,
        color = Enums.Color.eNormalWhite,
        })
    xhbShowLabel:setPosition(xhbShowSprite:getContentSize().width * 0.5, xhbShowSprite:getContentSize().height * 0.2)
    xhbShowSprite:addChild(xhbShowLabel)




end

-- 添加Vip经验进度条
function VipIntroduceLayer:addProgressBar()
    -- Vip等级标签
    local vipLvLabel = ui.newLabel({
        text = TR("%sVIP%d", Enums.Color.eNormalWhiteH,PlayerAttrObj:getPlayerAttrByName("Vip")),
        outlineColor = Enums.Color.eBlack,
        align = ui.TEXT_ALIGN_CENTER,
    })
    vipLvLabel:setPosition(self.mBgSize.width * 0.12, self.mBgSize.height * 0.97)
    self.mBgSpr:addChild(vipLvLabel)

    -- Vip经验进度条
    local curExp, maxExp
    if PlayerAttrObj:getPlayerAttrByName("Vip") < self.mMaxVipLv then
        curExp = PlayerAttrObj:getPlayerAttrByName("VipEXP")
        local nextVipLv = PlayerAttrObj:getPlayerAttrByName("Vip") + 1
        maxExp = VipModel.items[nextVipLv].expTotal
    else
        curExp = 100
        maxExp = 100
    end
    local vipProgressBar = require("common.ProgressBar").new({
        bgImage = "cz_10.png",
        barImage = "cz_11.png",
        currValue = curExp,
        maxValue = maxExp,
        barType = ProgressBarType.eHorizontal,
        needLabel = true,
        contentSize = cc.size(425, 25),
        color = Enums.Color.eNormalWhite,
        outlineColor = Enums.Color.eBlack
    })
    vipProgressBar:setPosition(self.mBgSize.width * 0.55, self.mBgSize.height * 0.97)
    self.mBgSpr:addChild(vipProgressBar)
end

return VipIntroduceLayer