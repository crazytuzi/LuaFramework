--[[
    文件名: DlgDiceRewardLogLayer.lua
    创建人: peiyaoqiang
    创建时间: 2017-09-24
    描述: 国庆活动——掷骰子——获奖记录
--]]

local DlgDiceRewardLogLayer = class("DlgDiceRewardLogLayer", function()
    return display.newLayer()
end)

function DlgDiceRewardLogLayer:ctor(params)
    -- 添加弹出框层
    local parentLayer = require("commonLayer.PopBgLayer").new({
        bgSize = cc.size(598, 650),
        title = TR("获奖记录"),
        closeAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self:addChild(parentLayer)
    self.mBgSprite = parentLayer.mBgSprite
    self.mBgSize = self.mBgSprite:getContentSize()

    -- 解析数据(获奖记录表)
    self.rewardList = self:anlaysisData(params.rewardStr)
    -- 初始化界面
    self:initUI()
end

function DlgDiceRewardLogLayer:anlaysisData(rewardStr)
    if rewardStr == nil or rewardStr == "" then
        return {}
    end
    local itemsList = string.split(rewardStr, ",")

    local rewardList = {}

    for _, v in pairs(itemsList) do
        table.insert(rewardList, tonumber(v))
    end
    dump(rewardList, "itemsList")
    return rewardList
end

-- 初始化页面控件
function DlgDiceRewardLogLayer:initUI()
    -- 提示
    local hintLabel = ui.newLabel({
            text = TR("最近%d条记录", #self.rewardList),
            color = cc.c3b(0x46, 0x22, 0x0d),
            size = 24,
        })
    hintLabel:setPosition(self.mBgSize.width*0.5, self.mBgSize.height*0.85)
    self.mBgSprite:addChild(hintLabel)
    -- 列表大小
    local listSize = cc.size(self.mBgSize.width*0.9, self.mBgSize.height*0.75)
    -- 列表背景
    local listBg = ui.newScale9Sprite("c_17.png", listSize)
    listBg:setPosition(self.mBgSize.width*0.5, self.mBgSize.height*0.43)
    self.mBgSprite:addChild(listBg)
    -- 奖励记录列表
    local rewardListView = ccui.ListView:create()
    rewardListView:setDirection(ccui.ScrollViewDir.vertical)
    rewardListView:setBounceEnabled(true)
    rewardListView:setContentSize(cc.size(listSize.width, listSize.height*0.95))
    rewardListView:setItemsMargin(5)
    rewardListView:setGravity(ccui.ListViewGravity.centerHorizontal)
    rewardListView:setAnchorPoint(cc.p(0.5, 0.5))
    rewardListView:setPosition(listSize.width*0.5, listSize.height*0.5)
    listBg:addChild(rewardListView)
    -- 填充列表
    for key, v in pairs(self.rewardList) do
        local item = self:createItem(key, DiceRewardModel.items[v])
        rewardListView:pushBackCustomItem(item)
    end
end

-- 创建一项
function DlgDiceRewardLogLayer:createItem(index, data)
    local itemSize = cc.size(self.mBgSize.width*0.88, 140)
    local layout = ccui.Layout:create()
    layout:setContentSize(itemSize)

    -- 背景
    local itemBg = ui.newScale9Sprite("c_18.png", itemSize)
    itemBg:setPosition(itemSize.width*0.5, itemSize.height*0.5)
    layout:addChild(itemBg)

    -- 第i次奖励
    local orderSprite = ui.newNumberLabel({
            text = tostring(index),
            imgFile = "c_81.png",
        })
    orderSprite:setAnchorPoint(cc.p(0, 0.5))
    orderSprite:setPosition(itemSize.width*0.1, itemSize.height*0.5)
    itemBg:addChild(orderSprite)

    -- 奖励物品
    local rewardList = Utility.analysisStrResList(data.reward)
    local cardList = ui.createCardList({
            maxViewWidth = itemSize.width*0.55,
            cardDataList = rewardList,
        })
    cardList:setAnchorPoint(cc.p(0, 0.5))
    cardList:setPosition(itemSize.width*0.4, itemSize.height*0.5)
    itemBg:addChild(cardList)

    return layout
end

return DlgDiceRewardLogLayer