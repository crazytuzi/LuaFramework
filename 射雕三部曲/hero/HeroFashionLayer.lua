--[[
    文件名：HeroFashionLayer.lua
    描述：绝学页签界面
    创建人：yanghongsheng
    创建时间：2017.9.14
-- ]]

local HeroFashionLayer = class("HeroFashionLayer", function()
    return  display.newLayer()
end)


--[[
    params:
    {
        parent              父节点
        heroData            hero信息
    }
--]]
function HeroFashionLayer:ctor(params)
    -- 传入参数
    self.mParent = params.parent
    self.mHeroId = params.heroId

    -- 初始化界面
    self:initLayer()

    self:showInfo()
end


-- 初始化界面
function HeroFashionLayer:initLayer()
    -- 父容器（Tab显示的可见区域）
    local layout = ccui.Layout:create()
    layout:setContentSize(640, 435)
    layout:setAnchorPoint(0.5, 0)
    layout:setPosition(320, 80)
    self:addChild(layout)
    self.mPanelLayout = layout

    -- 
    Utility.performWithDelay(self.mPanelLayout, function () 
            self:refreshUI()
        end, 0.1)
end
-- 创建绝学页签ui
function HeroFashionLayer:createBottomUI(fashionInfo)
    -- 时装表中数据
    local fashionData = FashionModel.items[fashionInfo.ModelId]
    -- 绝学卡片
    local fashionCard = CardNode.createCardNode({
            instanceData = fashionInfo,
            resourceTypeSub = ResourcetypeSub.eFashionClothes,
            cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eStep},
        })
    fashionCard:setPosition(320, 320)
    self.mPanelLayout:addChild(fashionCard)
    -- 绝学名
    local fashionName = ui.newLabel({
            text = fashionData.name,
            color = cc.c3b(0x46, 0x22, 0x0d),
            size = 24,
        })
    fashionName:setAnchorPoint(cc.p(0.5, 0))
    fashionName:setPosition(320, 240)
    self.mPanelLayout:addChild(fashionName)
    -- 第几重
    if fashionInfo.Step > 0 then
        local fashionStep = ui.newLabel({
            text = TR("第%d重", fashionInfo.Step),
            color = cc.c3b(0xd1, 0x7b, 0x00),
            size = 22,
        })
        fashionStep:setAnchorPoint(cc.p(0, 0))
        fashionStep:setPosition(400, 300)
        self.mPanelLayout:addChild(fashionStep)
    end
    -- 简介
    local fashionIntro = ui.newLabel({
            text = fashionData.intro,
            color = cc.c3b(0x46, 0x22, 0x0d),
            size = 22,
            dimensions = cc.size(450, 0)
        })
    fashionIntro:setAnchorPoint(cc.p(0.5, 1))
    fashionIntro:setPosition(320, 220)
    self.mPanelLayout:addChild(fashionIntro)

    -- 切换武功按钮
    local changeBtn = ui.newButton({
            normalImage = "c_28.png",
            text = TR("切换绝学"),
            clickAction = function ()
                self:changeFashion()
            end,
        })
    changeBtn:setPosition(320, 80)
    self.mPanelLayout:addChild(changeBtn)
end

-- 切换武功
function HeroFashionLayer:changeFashion()
    LayerManager.addLayer({name = "fashion.FashionHomeLayer", data = {callback = function ()
            self.mParent:refreshCurrHeroFigure()
            self:refreshUI()
        end}, cleanUp = false,})
end

-- 刷新界面
function HeroFashionLayer:refreshUI()
    self.mPanelLayout:removeAllChildren()

    -- 获取绝学id
    local fashionId = PlayerAttrObj:getPlayerAttrByName("FashionModelId")
    if fashionId == nil or fashionId == 0 then
        local emptyHintSprite = ui.createEmptyHint(TR("没有任何绝学已上阵"))
        emptyHintSprite:setPosition(380, 270)
        self.mPanelLayout:addChild(emptyHintSprite)

        local getBtn = ui.newButton({
            text = TR("去上阵"),
            normalImage = "c_28.png",
            clickAction = function ()
                self:changeFashion()
            end
        })
        getBtn:setPosition(320, 80)
        self.mPanelLayout:addChild(getBtn, 10)
    else
        local fashionInfo = FashionObj:getStepFashionInfo(fashionId)
        self:createBottomUI(fashionInfo)
    end
end

--- ==================== 数据显示相关 =======================
-- 显示所有信息
function HeroFashionLayer:showInfo()
    local data = HeroObj:getHero(self.mHeroId)
    self.mParent.mNameNode:refreshName(data)
end


return HeroFashionLayer