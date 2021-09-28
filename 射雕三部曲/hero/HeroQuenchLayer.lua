--[[
    文件名：HeroQuenchLayer.lua
    描述：英雄淬体界面
    创建人：peiyaoqiang
    创建时间：2017.12.04
-- ]]
local HeroQuenchLayer = class("HeroQuenchLayer", function()
    return display.newLayer()
end)

-- 读取突破名
local function getStepName(nStep)
    local nTemp = nStep or 0
    local heroTals = HeroTalRelation.items[12010003]    -- 主角通常能突破最高，名字最齐全
    return heroTals[nTemp].TALName
end

--[[
    params:
    {
        parent              父节点
        heroId              hero id
    }
--]]
function HeroQuenchLayer:ctor(params)
    -- 传入参数
    self.mParent = params.parent
    self.mHeroId = params.heroId
    self.mHeroData = HeroObj:getHero(self.mHeroId)

    local model = HeroModel.items[self.mHeroData.ModelId]
    self.heroValueLv = (model.specialType == Enums.HeroType.eMainHero) and 255 or model.valueLv
    self.isCanQuench = (QuenchModelRelation.items[self.heroValueLv * 1000 + 0] ~= nil)
    
    -- 创建显示层
    self:createLayer()

    -- 显示内容
    self:showInfo()
end

-- 初始化界面
function HeroQuenchLayer:createLayer()
    -- 父容器（Tab显示的可见区域）
    local layout = ccui.Layout:create()
    layout:setContentSize(640, 435)
    layout:setAnchorPoint(0.5, 0)
    layout:setPosition(320, 80)
    self:addChild(layout)
    self.mPanelLayout = layout

    -- 判断是否可以突破
    if not self.isCanQuench then
        local label = ui.newLabel({
            text = TR("该侠客不能淬体"),
            size = 35,
            color = Enums.Color.eRed,
            anchorPoint = cc.p(0.5, 0.5),
            x = 320,
            y = 250,
            align = cc.TEXT_ALIGNMENT_CENTER,
        })
        self.mPanelLayout:addChild(label)
        return
    end

    -- 属性信息背景框
    local tempBgSprite = ui.newScale9Sprite("c_17.png", cc.size(620, 190))
    tempBgSprite:setAnchorPoint(cc.p(0.5, 1))
    tempBgSprite:setPosition(320, 360)
    self.mPanelLayout:addChild(tempBgSprite)

    local attrBgSprite = ui.newScale9Sprite("c_18.png", cc.size(600, 170))
    attrBgSprite:setAnchorPoint(cc.p(0.5, 1))
    attrBgSprite:setPosition(320, 350)
    self.mPanelLayout:addChild(attrBgSprite)
    self.attrBgSprite = attrBgSprite

    -- 显示箭头
    local function createArrowSprite(pos)
        local sprite = ui.newSprite("c_66.png")
        sprite:setAnchorPoint(0.5, 0.5)
        sprite:setPosition(pos)
        self.mPanelLayout:addChild(sprite)
    end
    createArrowSprite(cc.p(180, 390))
    createArrowSprite(cc.p(320, 270))

    -- 需求物品显示控件
    local layout = ccui.Layout:create()
    layout:setPosition(320, 175)
    self.mPanelLayout:addChild(layout)
    self.mUseLayout = layout

    -- 创建UI
    self:initUI()
end

-- 创建UI
function HeroQuenchLayer:initUI()
    -- 显示当前淬体，下次淬体，所需进阶
    local function addLabel(xPos, anchor)
        local label = ui.newLabel({
            text = "",
            size = 24,
            color = cc.c3b(0x46, 0x22, 0x0d),
            anchorPoint = anchor or cc.p(0, 0.5),
            x = xPos,
            y = 390,
        })
        self.mPanelLayout:addChild(label)
        return label
    end
    self.currQuenchLabel = addLabel(40)
    self.nextQuenchLabel = addLabel(220)
    self.needStepLabel = addLabel(610, cc.p(1, 0.5))

    -- 淬体按钮
    local button = ui.newButton({
        normalImage = "c_28.png",
        position = cc.p(550, 83),
        text = TR("淬体"),
        clickAction = function()
            -- 判断突破等级是否达到要求
            if (self.mHeroData.Step < self.nNeedStepLv) then
                ui.showFlashView(TR("需要达到%s%s%s才能继续淬体", Enums.Color.eRedH, getStepName(self.nNeedStepLv), Enums.Color.eNormalWhiteH))
                return
            end
            
            -- 判断材料是否足够
            for i, resInfo in ipairs(self.mUseList) do
                if not resInfo.isMatch then
                    Utility.showResLackLayer(resInfo.resourceTypeSub, resInfo.modelId)
                    return
                end
            end

            -- 请求服务器
            self:requestHeroQuenchUp()
        end
    })
    self.mPanelLayout:addChild(button)
    self.mBreakButton = button

    -- 刷新属性显示
    self.attrBgSprite.refreshAttr = function (target, currConfig, nextConfig)
        target:removeAllChildren()

        -- 显示属性加成
        local yPosList1 = {135, 85, 35}
        local yPosList2 = {145, 105, 65, 25}
        local currTextList, nextTextList = {}, {}
        local function addAttrList(config, textList, strColor)
            for i,v in ipairs({"HPR", "APR", "DEFR"}) do
                local attrValue = "??"
                if (config ~= nil) then
                    attrValue = (tonumber(config[v])/100) .. "%"
                end
                table.insert(textList, string.format("%s%s +%s", ConfigFunc:getViewNameByFightName(v), strColor, attrValue))
            end
        end
        addAttrList(currConfig, currTextList, "#C27000")
        addAttrList(nextConfig, nextTextList, "#258711")
        
        -- 真元位是否开启
        if (nextConfig ~= nil) and (nextConfig.step > 0) then
            local preSlotConfig = ZhenyuanSlotRelation.items[nextConfig.step - 1]
            local curSlotConfig = ZhenyuanSlotRelation.items[nextConfig.step]
            if (curSlotConfig.slotNum > preSlotConfig.slotNum) then
                -- 大于上一个淬体的格子数量才说明有新开启的格子
                table.insert(nextTextList, TR("开启真元位: %s%s", "#258711", curSlotConfig.slotNum))
            end
        end

        -- 显示构造好的字符串
        local function showTextList(textList, xPos)
            local yPosList = (#textList == 3) and yPosList1 or yPosList2
            for i,v in ipairs(textList) do
                 local label = ui.newLabel({
                    text = v,
                    color = cc.c3b(0x46, 0x22, 0x0d),
                    anchorPoint = cc.p(0, 0.5),
                    x = xPos,
                    y = yPosList[i],
                })
                target:addChild(label)
            end
        end
        showTextList(currTextList, 80)
        showTextList(nextTextList, 380)
    end

    -- 刷新需求显示
    self.mUseLayout.refreshUse = function (target)
        target:removeAllChildren()

        -- 铜钱单独显示处理
        local tmpUseList = {}
        for _, resInfo in ipairs(self.mUseList) do
            if resInfo.resourceTypeSub == ResourcetypeSub.eGold then
                local tmpView = ui.createDaibiView({resourceTypeSub = resInfo.resourceTypeSub, number = resInfo.num})
                tmpView:setAnchorPoint(0, 0.5)
                tmpView:setPosition(160, -40)
                target:addChild(tmpView)

                -- 标记数量是否充足
                resInfo.isMatch = (PlayerAttrObj:getPlayerAttr(resInfo.resourceTypeSub) >= resInfo.num)
            else
                table.insert(tmpUseList, resInfo)
            end
        end

        -- 显示其他道具资源
        local startPosXList = {[1] = 0, [2] = 55, [3] = 55, [4] = 80}
        local startPosX = startPosXList[#tmpUseList]
        for i, resInfo in ipairs(tmpUseList) do
            local tmpCard, cardShowAttrs = CardNode.createCardNode({
                resourceTypeSub = resInfo.resourceTypeSub,
                modelId = resInfo.modelId,
                num = resInfo.num,
                cardShape = Enums.CardShape.eSquare,
                cardShowAttrs = {CardShowAttr.eNum, CardShowAttr.eBorder},
                onClickCallback = function()
                    Utility.showResLackLayer(resInfo.resourceTypeSub, resInfo.modelId)
                end
            })
            tmpCard:setPosition(startPosX - (i - 1) * 110, -70)
            target:addChild(tmpCard)

            -- 显示当前拥有数值
            local numLabel = cardShowAttrs[CardShowAttr.eNum].label
            local holdNum = Utility.getOwnedGoodsCount(resInfo.resourceTypeSub, resInfo.modelId)
            -- 英雄个数修正：未上阵则去除自身
            if Utility.isHero(resInfo.resourceTypeSub) then
                holdNum = HeroObj:getCountByModelId(resInfo.modelId, {
                    notInFormation = true,
                    excludeIdList = {self.mHeroId},
                })
            elseif Utility.isTreasure(resInfo.resourceTypeSub) then
                holdNum = TreasureObj:getCountByModelId(resInfo.modelId, {
                    notInFormation = true,
                    maxLv = 0, 
                    maxStep = 0,
                    })
            end

            local text = Utility.numberWithUnit(holdNum, 0).."/"..Utility.numberWithUnit(resInfo.num, 0)
            if holdNum >= resInfo.num then
                resInfo.isMatch = true
                numLabel:setString(Enums.Color.eGreenH .. text)
            else
                resInfo.isMatch = false
                numLabel:setString(Enums.Color.eRedH .. text)
            end
        end
    end
end

--- ==================== 数据显示相关 =======================
-- 显示所有信息
function HeroQuenchLayer:showInfo()
    local data = self.mHeroData
    self.mParent.mNameNode:refreshName(data)
    if not self.isCanQuench then
        return
    end

    -- 读取数据
    local heroModel = HeroModel.items[data.ModelId]
    local currQuench = data.QuenchStep or 0
    local nextQuench = currQuench + 1
    local currConfig = QuenchModelRelation.items[self.heroValueLv * 1000 + currQuench]
    local nextConfig = QuenchModelRelation.items[self.heroValueLv * 1000 + nextQuench]
    local isTopLv = (nextConfig == nil)     -- 是否达到最高

    -- 读取需求进阶等级
    self.nNeedStepLv = 0
    if (nextConfig ~= nil) and (nextConfig.needStepLv ~= nil) then
        self.nNeedStepLv = nextConfig.needStepLv
    end
    
    -- 读取突破消耗
    self.mUseList = clone(Utility.analysisStrResList(currConfig.upUse))
    if currConfig.useNum and currConfig.useNum > 0 then
        table.insert(self.mUseList, {resourceTypeSub = ResourcetypeSub.eHero, modelId = data.ModelId, num = currConfig.useNum})
    end
    
    -- 显示突破进阶信息
    if isTopLv then
        self.nextQuenchLabel:setString(TR("未知"))
        self.needStepLabel:setString(TR("需要: %s未知", "#258711"))
    else
        self.nextQuenchLabel:setString(Utility.getQuenchName(nextQuench))
        self.needStepLabel:setString(TR("需要: %s%s", ((data.Step >= self.nNeedStepLv) and "#258711" or Enums.Color.eRedH), getStepName(self.nNeedStepLv)))
    end
    self.currQuenchLabel:setString(Utility.getQuenchName(currQuench))
    
    -- 显示属性信息
    self.attrBgSprite:refreshAttr(currConfig, nextConfig)
    
    -- 显示消耗
    if isTopLv then
        self.mBreakButton:setVisible(false)
        self.mUseLayout:removeAllChildren()
        
        -- 满级提示
        local topSprite = ui.newSprite("zb_26.png")
        topSprite:setPosition(0, -65)
        self.mUseLayout:addChild(topSprite)
    else
        self.mBreakButton:setVisible(true)
        self.mUseLayout:refreshUse()
    end
end

--- ==================== 特效相关 =======================
-- 突破特效
function HeroQuenchLayer:playHeroStepUpEffect()
    local itemNode = self.mParent:getCurrHeroFigure()
    local x, y = itemNode.figure:getPosition()
    local playAnimation = function(name, zorder)
        return ui.newEffect({
            parent = itemNode,
            effectName = "effect_ui_ruwutupo",
            position = cc.p(x, y + 60),
            loop = false,
            zorder = zorder or 1,
        })
    end

    playAnimation("renwujinjie")

    -- 音乐
    MqAudio.playEffect("renwu_tupo.mp3")
end

--- ==================== 服务器数据请求相关 =======================
-- 英雄进阶请求
function HeroQuenchLayer:requestHeroQuenchUp()
    -- 从item列表里读出指定数量的ID
    local function getSomeIds(idArray, idNum)
        local tmpList = {}
        local num = idNum
        for _, item in pairs(idArray) do
            table.insert(tmpList, item.Id)
            num = num - 1
            if (num <= 0) then 
                break 
            end
        end
        return tmpList
    end

    -- 读取需要使用的侠客ID
    local tmpIdList = {}
    for _, resInfo in ipairs(self.mUseList) do
        if Utility.isHero(resInfo.resourceTypeSub) then
            -- 过滤当前英雄
            local tmpArray = HeroObj:findHeroByModelId(resInfo.modelId, {
                notInFormation = true,
                maxStep = 0,
                maxLv = 1,
                excludeIdList = {self.mHeroId},
            }) or {}
            
            -- 取出指定数量的侠客ID
            tmpIdList = getSomeIds(tmpArray, resInfo.num)
        end
    end

    -- 发送请求
    HttpClient:request({
        moduleName = "QuenchInfo",
        methodName = "Quench",
        svrMethodData = {self.mHeroId, tmpIdList},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return 
            end
            
            -- 修正缓存数据
            HeroObj:modifyHeroItem(response.Value)

            -- 从缓存里删除使用过的侠客
            for _,v in pairs(tmpIdList) do
                HeroObj:deleteHeroById(v)
            end

            -- 刷新界面
            self.mHeroData = HeroObj:getHero(self.mHeroId)
            self:showInfo()

            -- 播放特效
            self:playHeroStepUpEffect()
        end
    })
end

return HeroQuenchLayer
