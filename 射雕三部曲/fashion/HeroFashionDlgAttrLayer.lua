--[[
    文件名: HeroFashionDlgAttrLayer.lua
    创建人: yanghongsheng
    创建时间: 2019-06-18
    描述: 时装属性总览界面
--]]

local HeroFashionDlgAttrLayer = class("HeroFashionDlgAttrLayer", function()
    return display.newLayer()
end)

--[[
params:
    heroId  侠客id
]]

function HeroFashionDlgAttrLayer:ctor(params)
    self.mHeroId = params.heroId
    -- 屏蔽下层触摸事件
    ui.registerSwallowTouch({node = self})

    -- 添加弹出框层
    local parentLayer = require("commonLayer.PopBgLayer").new({
        bgSize = cc.size(598, 427),
        title = TR("属性总览"),
        closeAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self:addChild(parentLayer)
    self.mBgSprite = parentLayer.mBgSprite
    self.mBgSize = self.mBgSprite:getContentSize()

    self:initUI()
end

-- 计算加成属性
function HeroFashionDlgAttrLayer:calcAttrs()
    -- 激活时装id列表
    local heroInfo = HeroObj:getHero(self.mHeroId)
    local activelist = {}
    if heroInfo.ActivatedFashionStr ~= "" then
        activelist = string.splitBySep(heroInfo.ActivatedFashionStr, ",")
    end

    local attrList = {}
    for _, fashionId in pairs(activelist) do
        local tempAttrList = Utility.analysisStrAttrList(HeroFashionRelation.items[tonumber(fashionId)].openAttrStr)
        for _, attrInfo in pairs(tempAttrList) do
            attrList[attrInfo.fightattr] = attrList[attrInfo.fightattr] or 0
            attrList[attrInfo.fightattr] = attrList[attrInfo.fightattr] + attrInfo.value
        end
    end

    local tempList = {}
    for fightattr, value in pairs(attrList) do
        local tempItem = {fightattr = fightattr, value = value}
        table.insert(tempList, tempItem)
    end

    return tempList
end

-- 初始化页面控件
function HeroFashionDlgAttrLayer:initUI()
    -- 添加背景
    local bgSprite = ui.newScale9Sprite("c_17.png", cc.size(540, 325))
    bgSprite:setAnchorPoint(cc.p(0.5, 0))
    bgSprite:setPosition(self.mBgSize.width * 0.5, 30)
    self.mBgSprite:addChild(bgSprite)

    -- 添加白背景
    local bgSprite2 = ui.newScale9Sprite("c_18.png", cc.size(520, 305))
    bgSprite2:setAnchorPoint(cc.p(0.5, 0))
    bgSprite2:setPosition(self.mBgSize.width * 0.5, 40)
    self.mBgSprite:addChild(bgSprite2)

    -- 添加属性
    local col = 3
    local posXList = {40, 190, 340}
    local attrList = self:calcAttrs()
    for i = 1, math.ceil(#attrList/col) do
        for j = 1, col do
            local index = (i-1)*col+j
            local attrInfo = attrList[index]
            local label = ui.newLabel({
                text = FightattrName[attrInfo.fightattr].."#D38212"..Utility.getAttrViewStr(attrInfo.fightattr, attrInfo.value, true),
                color = cc.c3b(0x46, 0x22, 0x0d),
                size = 24,
            })
            label:setAnchorPoint(cc.p(0, 0.5))
            label:setPosition(cc.p(posXList[j], 305-i*30))
            bgSprite2:addChild(label)
        end
    end
end

return HeroFashionDlgAttrLayer