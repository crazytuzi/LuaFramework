--[[
    文件名：HeroLevelUpLayer.lua
    描述：英雄升级界面
    创建人：peiyaoqiang
    创建时间：2017.3.11
-- ]]

local TokensConfig = {
    {resourceTypeSub = ResourcetypeSub.eGold},
    {resourceTypeSub = ResourcetypeSub.eHeroExp},
}

local HeroLevelUpLayer = class("HeroLevelUpLayer", function()
    return display.newLayer()
end)

--[[
    params:
    {
        parent              父节点
        heroData    		hero信息
    }
--]]
function HeroLevelUpLayer:ctor(params)
    -- 传入参数
    self.mParent = params.parent
    self.mHeroId = params.heroId
    self.mHeroData = HeroObj:getHero(self.mHeroId)
    
    -- 创建显示层
    self:createLayer()

    -- 显示内容
    self:showInfo()
end

-- 初始化界面
function HeroLevelUpLayer:createLayer()
    -- 父容器（Tab显示的可见区域）
    local layout = ccui.Layout:create()
    layout:setContentSize(640, 435)
    layout:setAnchorPoint(0.5, 0)
    layout:setPosition(320, 80)
    self:addChild(layout)
    self.mPanelLayout = layout

    -- 属性信息背景框
    local tempBgSprite = ui.newScale9Sprite("c_17.png", cc.size(610, 200))
    tempBgSprite:setAnchorPoint(cc.p(0.5, 1))
    tempBgSprite:setPosition(320, 390)
    self.mPanelLayout:addChild(tempBgSprite)

    -- 等级信息背景框
    _, self.currLvLabel = ui.newNodeBgWithTitle(self.mPanelLayout, cc.size(250, 180), TR("当前等级"), cc.p(150, 380), cc.p(0.5, 1))
    _, self.nextLvLabel = ui.newNodeBgWithTitle(self.mPanelLayout, cc.size(250, 180), TR("下一级"), cc.p(490, 380), cc.p(0.5, 1))

    -- 箭头
    local sprite = ui.newSprite("c_67.png")
    sprite:setPosition(315, 283)
    self.mPanelLayout:addChild(sprite)

    -- 创建UI
    self:initUI()
end

-- 创建UI
function HeroLevelUpLayer:initUI()
    -- 创建"升一次"按钮
    local button = ui.newButton({
        normalImage = "c_28.png",
        position = cc.p(480, 93),
        text = TR("升级"),
        clickAction = function()
            self:levelUp(1)
        end
    })
    self.mPanelLayout:addChild(button)

    -- 创建"升十次"按钮
    button = ui.newButton({
        normalImage = "c_33.png",
        position = cc.p(160, 93),
        text = TR("升十次"),
        clickAction = function()
            self:levelUp(10)
        end
    })
    self.mPanelLayout:addChild(button)
    self.tenButton = button

    -- 创建内容信息控件
    self:createInfoViews()
end

-- 创建内容信息控件
function HeroLevelUpLayer:createInfoViews()
    -- 当前等级数据显示控件
    local layout = self:createLvInfoLayout()
    layout:setPosition(50, 205)
    self.mPanelLayout:addChild(layout)
    self.mCurLvLayout = layout

    -- 下一等级数据显示控件
    layout = self:createLvInfoLayout()
    layout:setPosition(390, 205)
    self.mPanelLayout:addChild(layout)
    self.mNextLvLayout = layout

    -- 代币消耗显示控件
    local tmpLayout = ccui.Layout:create()
    tmpLayout:setPosition(380, 130)
    self.mPanelLayout:addChild(tmpLayout)
    self.mTokensLayout = tmpLayout

    tmpLayout.views = {}
    for i, tokenConfig in ipairs(TokensConfig) do
        local tmpView = ui.createDaibiView({
            resourceTypeSub = tokenConfig.resourceTypeSub,
            number = 0,
        })
        tmpView:setAnchorPoint(0, 0)
        tmpView:setPosition((i - 1)*115 + 10, 0)
        tmpLayout:addChild(tmpView)
        tmpLayout.views[i] = tmpView
    end
end

-- 创建等级信息容器
function HeroLevelUpLayer:createLvInfoLayout()
    local textInfo = {
        anchorPoint = cc.p(0, 0),
        x = 20,
        color = cc.c3b(0x46, 0x22, 0x0d),
    }
	local layout = ccui.Layout:create()
	layout:setContentSize(180, 180)
    
    -- HP数值
    textInfo.text = ""
	textInfo.y = 90
    label = ui.newLabel(textInfo)
    layout:addChild(label)
    layout.hpNumLabel = label

    -- AP数值
    textInfo.text = ""
	textInfo.y = 50
    label = ui.newLabel(textInfo)
    layout:addChild(label)
    layout.apNumLabel = label

    -- DEF数值
    textInfo.text = ""
	textInfo.y = 10
    label = ui.newLabel(textInfo)
    layout:addChild(label)
    layout.defNumLabel = label

    return layout
end

--- ==================== 数据显示相关 =======================
-- 显示所有信息
function HeroLevelUpLayer:showInfo()
    -- 显示名字信息
    self.mParent.mNameNode:refreshName(self.mHeroData)

    -- 显示等级属性信息
    self.currLvLabel:setString(self.currLvLabel.rawText .. " " .. "#FF974A" .. self.mHeroData.Lv)
    self.nextLvLabel:setString(self.nextLvLabel.rawText .. " " .. "#9BFF6A" .. (self.mHeroData.Lv + 1))
    self:showLevelInfo(self.mCurLvLayout, self.mHeroData.Lv, self.mHeroData.ModelId, "#C27000")
    self:showLevelInfo(self.mNextLvLayout, self.mHeroData.Lv + 1, self.mHeroData.ModelId, "#258711")

    -- 显示代币信息
    self:showUseInfo(self.mTokensLayout, self.mHeroData.ModelId, self.mHeroData.Lv)
end

-- 显示信息
function HeroLevelUpLayer:showLevelInfo(layout, lv, heroModelId, hColor)
    -- HP
    local attr = ConfigFunc:getHeroLvAttr(heroModelId, lv, true)
    local text = Utility.getAttrViewStr(Fightattr.eHP, attr.HP, false)
    layout.hpNumLabel:setString(string.format("%s: %s+%s", FightattrName[Fightattr.eHP], hColor, text))
    -- AP
    text = Utility.getAttrViewStr(Fightattr.eAP, attr.AP, false)
    layout.apNumLabel:setString(string.format("%s: %s+%s", FightattrName[Fightattr.eAP], hColor, text))
    -- DEF
    text = Utility.getAttrViewStr(Fightattr.eDEF, attr.DEF, false)
    layout.defNumLabel:setString(string.format("%s: %s+%s", FightattrName[Fightattr.eDEF], hColor, text))
end

-- 显示升级消耗
function HeroLevelUpLayer:showUseInfo(layout, heroModelId, heroLv)
    local needNum = ConfigFunc:getHeroEXPTotal(heroModelId, heroLv+1) - ConfigFunc:getHeroEXPTotal(heroModelId, heroLv)
    for i, tokenConfig in ipairs(TokensConfig) do
        layout.views[i].setNumber(needNum)
    end
end

--- ==================== 升级操作相关 =======================
--
function HeroLevelUpLayer:levelUp(times)
    -- 检查人物等级
    if self.mHeroData.Lv >= HeroObj:getMainHero().Lv then
        ui.showFlashView(TR("不能超过主角等级"))
        return
    end

    -- 检查材料是否足够
    local curNum = ConfigFunc:getHeroEXPTotal(self.mHeroData.ModelId, self.mHeroData.Lv)
    local lackResType = nil
    while times > 0 do
        -- 需求数量
        local needNum = ConfigFunc:getHeroEXPTotal(self.mHeroData.ModelId, self.mHeroData.Lv + times) - curNum

        lackResType = nil
        for i, tokenConfig in ipairs(TokensConfig) do
            local holdNum = PlayerAttrObj:getPlayerAttr(tokenConfig.resourceTypeSub)
            if holdNum < needNum then
                lackResType = tokenConfig.resourceTypeSub
                break
            end
        end

        if not lackResType then
            -- 需求数量足够
            self:requestHeroLvUp(self.mHeroData.Id, times)
            return
        end

        times = times - 1
    end

    Utility.showResLackLayer(lackResType)
end

--- ==================== 特效相关 =======================
-- 升级特效
function HeroLevelUpLayer:playHeroLevelUpEffect()
    local itemNode = self.mParent:getCurrHeroFigure()
    local x, y = itemNode.figure:getPosition()
    local function playAnimation(name, zorder)
        return ui.newEffect({
            parent = itemNode,
            effectName = "effect_ui_ruwushengji",
            position = cc.p(x, y + 60),
            loop = false,
            animation = name,
            zorder = zorder or 1,
        })
    end

    --playAnimation("hou", -1)
    --playAnimation("bao")
    playAnimation("animation")

    -- 音乐
    MqAudio.playEffect("renwu_shengji.mp3")
end

--- ==================== 服务器数据请求相关 =======================
-- 英雄进阶请求
function HeroLevelUpLayer:requestHeroLvUp(id, times)
    HttpClient:request({
        moduleName = "Hero",
        methodName = "HeroLvUp",
        guideInfo = Guide.helper:tryGetGuideSaveInfo(10303),
        svrMethodData = {id, times},
        callback = function(response)
            if response.Status == 0 then
                --[[--------新手引导--------]]--
                local _, _, eventID = Guide.manager:getGuideInfo()
                if eventID == 10303 then
                    Guide.manager:nextStep(eventID)
                    self:executeGuide() -- 主引导:继续下一步新手引导
                end

                -- 更新缓存
                HeroObj:modifyHeroItem(response.Value)

                -- 刷新界面
                self.mHeroData = HeroObj:getHero(self.mHeroId)
                self:showInfo()

                -- 播放特效
                self:playHeroLevelUpEffect()
            end
        end
    })
end

-- ========================== 新手引导 ===========================
function HeroLevelUpLayer:onEnterTransitionFinish()
    self:executeGuide()
end

function HeroLevelUpLayer:executeGuide()
    Guide.helper:executeGuide({
        [10303] = {clickNode = self.tenButton},
        [10304] = {clickNode = self.mParent.mCommonLayer_:getNavBtnObj(Enums.MainNav.eBattle)},
    })
end

return HeroLevelUpLayer
