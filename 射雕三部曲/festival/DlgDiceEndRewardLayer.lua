--[[
    文件名: DlgDiceEndRewardLayer.lua
    创建人: peiyaoqiang
    创建时间: 2017-09-24
    描述: 国庆活动——掷骰子——终极大奖
--]]

local DlgDiceEndRewardLayer = class("DlgDiceEndRewardLayer", function()
    return display.newLayer(cc.c4b(0, 0, 0, 128))
end)

function DlgDiceEndRewardLayer:ctor(params)
    local tempCallBack = params.callback

    -- 注册屏蔽下层页面事件
    ui.registerSwallowTouch({
        node = self,
        allowTouch = true,
        beganEvent = function(touch, event)
            return true
        end,
        endedEvent = function(touch, event)
            LayerManager.removeLayer(self)
            if tempCallBack then
                tempCallBack()
            end
        end,
    })

    -- 创建背景图片
    local mBgSprite = ui.newSprite("mrjl_02.png")
    local mBgSize = mBgSprite:getContentSize()
    mBgSprite:setPosition(cc.p(display.cx, display.cy))
    mBgSprite:setScale(Adapter.MinScale)
    self:addChild(mBgSprite)

    -- 标题
    local titleLabel = ui.newLabel({
        text = TR("终极大奖"),
        size = 30,
        color = cc.c3b(0xff, 0xee, 0xd0),
        outlineColor = cc.c3b(0x3a, 0x24, 0x18),
        outlineSize = 2,
    })
    titleLabel:setAnchorPoint(cc.p(0.5, 0.5))
    titleLabel:setPosition(cc.p(mBgSize.width / 2, mBgSize.height - 35))
    mBgSprite:addChild(titleLabel)

    -- 列表背景
    local listBgSize = cc.size(mBgSize.width - 60, 160)
    local listBgSprite = ui.newScale9Sprite("c_17.png", listBgSize)
    listBgSprite:setAnchorPoint(cc.p(0.5, 0))
    listBgSprite:setPosition(mBgSize.width * 0.5, 85)
    mBgSprite:addChild(listBgSprite)

    -- 奖励列表
    local rewardList = Utility.analysisStrResList(params.rewardStr)
    for _, item in pairs(rewardList) do
        item.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum, CardShowAttr.eName}
    end
    local cardList = ui.createCardList({
        cardDataList = rewardList,
        allowClick = true,
        maxViewWidth = listBgSize.width - 10,
        viewHeight = listBgSize.height - 10,
        space = 15,
    })
    cardList:setAnchorPoint(cc.p(0.5, 0.5))
    cardList:setPosition(listBgSize.width * 0.5, 65)
    listBgSprite:addChild(cardList)

    -- 奖励文字
    local rewardLabel = ui.newLabel({
        text = TR("奖励已发放到#D17B00领奖中心"),
        size = 22,
        color = cc.c3b(0x46, 0x22, 0x0d),
    })
    rewardLabel:setAnchorPoint(cc.p(0.5, 0.5))
    rewardLabel:setPosition(cc.p(mBgSize.width * 0.5, 55))
    mBgSprite:addChild(rewardLabel)

    -- 提示文字
    local infoLabel = ui.newLabel({
        text = TR("点击任意位置继续"),
        size = 24,
        color = Enums.Color.eNormalWhite,
    })
    infoLabel:setAnchorPoint(cc.p(0.5, 1))
    infoLabel:setPosition(mBgSize.width * 0.5, -10)
    mBgSprite:addChild(infoLabel)

    -- 显示弹出动画
    mBgSprite:setScale(0)
    mBgSprite:runAction(cc.ScaleTo:create(0.2, Adapter.MinScale))
end

return DlgDiceEndRewardLayer