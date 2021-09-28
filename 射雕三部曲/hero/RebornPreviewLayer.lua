--[[
    文件名：RebornPreviewLayer.lua
    描述：侠客天赋预览界面(转生预览)
    创建人：zouhuajie
    创建时间：2017.8.31
-- ]]

local RebornIdList = table.keys(RebornLvModel.items)

local RebornPreviewLayer = class("RebornPreviewLayer", function ( ... )
    return display.newLayer()
end)

--[[
    -- params: params中各项为人物缓存数据
]]
function RebornPreviewLayer:ctor( params )
    self.mRebornId = params and params.RebornId or 0
    self.mHeroModelId = params and params.ModelId or 0
    self.mIllusionModelId = params and params.IllusionModelId or nil

    -- 当前转生重数
    self.mRebornNum = RebornLvModel.items[self.mRebornId].rebornNum

    -- 窗体大小
    self.mBgSize = cc.size(550, 500)
    
    -- 初始化UI
    self:initUI()

    --
    self:createListView()
end

-- 初始化ui
function RebornPreviewLayer:initUI()
    -- 创建窗体
    local heroNameStr = ConfigFunc:getHeroName(self.mHeroModelId, {IllusionModelId = self.mIllusionModelId}) .. (self.mRebornNum and self.mRebornNum > 0 and (" +" .. self.mRebornNum) or "")
    local bgLayer = require("commonLayer.PopBgLayer").new({
        title = heroNameStr,
        bgSize = self.mBgSize,
        closeImg = "c_29.png",
        closeAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self:addChild(bgLayer)
    self.mBgSprite = bgLayer.mBgSprite
    
    -- 觉醒sprite
    local tmpSp = ui.newSprite("jm_01.png")
    tmpSp:setPosition(cc.p(110, 410))
    self.mBgSprite:addChild(tmpSp)
end

-- 创建天赋展示控件
function RebornPreviewLayer:createListView()
    if not tolua.isnull(self.mListView) then
        return
    end

    -- listview黑色背景框
    local bgSize = cc.size(490, 350)
    local blackBgSprite = ui.newScale9Sprite("c_17.png", bgSize)
    blackBgSprite:setAnchorPoint(0.5, 0)
    blackBgSprite:setPosition(self.mBgSize.width / 2, 30)   
    self.mBgSprite:addChild(blackBgSprite)

    -- 创建listview
    self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setContentSize(cc.size(bgSize.width - 15, bgSize.height - 10))
    self.mListView:setItemsMargin(5)
    self.mListView:setGravity(ccui.ListViewGravity.centerHorizontal)
    self.mListView:setAnchorPoint(cc.p(0.5, 1))
    self.mListView:setPosition(bgSize.width / 2, 340)
    blackBgSprite:addChild(self.mListView)

    -- 刷新listview数据
    self:refreshListView()
end

-- 刷新listview数据
function RebornPreviewLayer:refreshListView()
    if tolua.isnull(self.mListView) then
        self:createListView()
    end

    local attrInfoList = self:getAttrInfosList()
    local ceilSize = cc.size(470, 110)

    -- 创建天赋条目
    local function createCeil( idx )
        local layout = ccui.Layout:create()
        layout:setContentSize(ceilSize)

        -- 条目背景
        local ceilBgSprite = ui.newScale9Sprite("c_18.png", ceilSize)
        ceilBgSprite:setPosition(ceilSize.width / 2, ceilSize.height / 2)
        layout:addChild(ceilBgSprite)

        -- 可以触发属性
        local enableActiveAttr = self.mRebornNum >= idx

        -- 头像
        local cardSprite = CardNode.createCardNode({
                allowClick = false, --是否可点击
                fashionModelId = - 1,
                cardShowAttrs = {CardShowAttr.eBorder},
            })
        cardSprite:setAnchorPoint(0, 0.5)
        cardSprite:setPosition(20, ceilSize.height / 2)
        cardSprite:setEmpty(nil, attrInfoList[idx].talIcon .. ".png", nil)
        cardSprite:setCardBorder(30)
        cardSprite:setGray(not enableActiveAttr)
        ceilBgSprite:addChild(cardSprite)

        --  提示:
        local tipsLabel = ui.newLabel({
                text = enableActiveAttr and TR("已激活") or TR("%s重激活", idx),
                color = enableActiveAttr and Enums.Color.eNormalGreen or Enums.Color.eGrey,
                size = 22,
                anchorPoint = cc.p(0, 0.5),
                })
        tipsLabel:setPosition(130, ceilSize.height / 2 + 20)
        ceilBgSprite:addChild(tipsLabel)

        -- 突破属性
        local introStr = TR(attrInfoList[idx].curTalIntro)
        local attrLabel = ui.newLabel({
                text = introStr,
                color = enableActiveAttr and Enums.Color.eCoffee or Enums.Color.eGrey,
                size = 18,
                anchorPoint = cc.p(0, 0.5),
                align = cc.TEXT_ALIGNMENT_LEFT,
                -- valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
                dimensions = cc.size(280, 0),

            })
        attrLabel:setPosition(130, ceilSize.height / 2 - 20)
        ceilBgSprite:addChild(attrLabel)

        return layout
    end

    -- 添加ceil
    self.mListView:removeAllItems()
    for i = 1, table.nums(attrInfoList) do
        self.mListView:pushBackCustomItem(createCeil(i))
    end
end

-- 获取天赋信息表
function RebornPreviewLayer:getAttrInfosList()
    local attrInfosList = ConfigFunc:getRebornAttrInfosById(self.mRebornId)
    return attrInfosList
end

return RebornPreviewLayer