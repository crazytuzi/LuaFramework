--[[
    文件名：HeroStepUpLayer.lua
    描述：英雄突破界面
    创建人：peiyaoqiang
    创建时间：2017.3.11
-- ]]

local StepAttrsConfig = {"HP", "AP", "DEF"}

local HeroStepUpLayer = class("HeroStepUpLayer", function()
    return display.newLayer()
end)

--[[
    params:
    {
        parent              父节点
        heroData            hero信息
    }
--]]
function HeroStepUpLayer:ctor(params)
    -- 传入参数
    self.mParent = params.parent
    self.mHeroId = params.heroId
    self.mHeroData = HeroObj:getHero(self.mHeroId)

    local model = HeroModel.items[self.mHeroData.ModelId]
    self.isCanStep = (HeroStepRelation.items[model.stepUpClassID * 1000 + 1] ~= nil)
    
    -- 创建显示层
    self:createLayer()

    -- 显示内容
    self:showInfo()
end

-- 初始化界面
function HeroStepUpLayer:createLayer()
    -- 父容器（Tab显示的可见区域）
    local layout = ccui.Layout:create()
    layout:setContentSize(640, 435)
    layout:setAnchorPoint(0.5, 0)
    layout:setPosition(320, 80)
    self:addChild(layout)
    self.mPanelLayout = layout

    -- 判断是否可以突破
    if not self.isCanStep then
        local label = ui.newLabel({
            text = TR("紫色或更高品质的侠客\n才能进行突破"),
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

    local tempBgSprite = ui.newScale9Sprite("c_18.png", cc.size(600, 170))
    tempBgSprite:setAnchorPoint(cc.p(0.5, 1))
    tempBgSprite:setPosition(320, 350)
    self.mPanelLayout:addChild(tempBgSprite)

    -- 显示箭头
    local function createArrowSprite(pos)
        local sprite = ui.newSprite("c_66.png")
        sprite:setAnchorPoint(0.5, 0.5)
        sprite:setPosition(pos)
        self.mPanelLayout:addChild(sprite)
    end
    createArrowSprite(cc.p(215, 390))
    createArrowSprite(cc.p(215, 313))
    createArrowSprite(cc.p(510, 313))
    createArrowSprite(cc.p(215, 273))

    -- 创建UI
    self:initUI()
end

-- 创建UI
function HeroStepUpLayer:initUI()
    -- 创建"突破"按钮
    local button = ui.newButton({
        normalImage = "c_28.png",
        position = cc.p(550, 83),
        text = TR("突破"),
        clickAction = function()
            for i, resInfo in ipairs(self.mUseList) do
                if not resInfo.isMatch then
                    Utility.showResLackLayer(resInfo.resourceTypeSub, resInfo.modelId)
                    return
                end
            end
            self:requestHeroStepUp()
        end
    })
    self.mPanelLayout:addChild(button)
    self.mBreakButton = button

    -- 创建内容信息控件
    self:createInfoViews()
end

-- 创建内容信息控件
function HeroStepUpLayer:createInfoViews()
    -- 显示当前突破，下次突破，所需等级
    local function addStepLabel(xPos)
        local label = ui.newLabel({
            text = "",
            size = 24,
            color = cc.c3b(0x46, 0x22, 0x0d),
            anchorPoint = cc.p(0, 0.5),
            x = xPos,
            y = 390,
        })
        self.mPanelLayout:addChild(label)
        return label
    end
    self.currStepLabel = addStepLabel(50)
    self.nextStepLabel = addStepLabel(235)
    self.needLvLabel = addStepLabel(450)

    -- 属性显示控件
    self.mAttrLayouts = {}
    local x = 0
    local y = 340
    for i=1, #StepAttrsConfig do
        local layout = self:createAttrInfoLayout(StepAttrsConfig[i])
        if i%2 == 1 then
            x = 50
            y = y - 40
        else
            x = 345
        end
        layout:setPosition(x, y)
        self.mPanelLayout:addChild(layout)
        self.mAttrLayouts[i] = layout
    end

    -- "新天赋"显示控件
    local tmpLabel = ui.createSpriteAndLabel({
        imgName = "c_63.png",
        labelStr = TR("新天赋:"),
        fontColor = cc.c3b(0xc2, 0x70, 0x00),
        alignType = ui.TEXT_ALIGN_RIGHT
    })
    tmpLabel:setAnchorPoint(cc.p(0, 1))
    tmpLabel:setPosition(27, 252)
    self.mPanelLayout:addChild(tmpLabel)

    local infoLabel = ui.newLabel({
        text = "",
        color = cc.c3b(0xc2, 0x70, 0x00),
        align = cc.TEXT_ALIGNMENT_LEFT,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
        dimensions = cc.size(440, 0)
    })
    infoLabel:setAnchorPoint(cc.p(0, 1))
    infoLabel:setPosition(cc.p(155, 245))
    self.mPanelLayout:addChild(infoLabel)
    self.mNewTalLabel = infoLabel

    -- 需求物品显示控件
    local layout = ccui.Layout:create()
    layout:setPosition(320, 175)
    self.mPanelLayout:addChild(layout)
    self.mUseLayout = layout
end

-- 创建属性信息容器
function HeroStepUpLayer:createAttrInfoLayout(attrName)
    local layout = ccui.Layout:create()
    layout:setContentSize(250, 30)

    local function addAttrLabel(strText, xPos, cColor)
        local label = ui.newLabel({
            text = strText or "",
            color = cColor or cc.c3b(0x46, 0x22, 0x0d),
            anchorPoint = cc.p(0, 0),
            x = xPos,
            y = 0,
        })
        layout:addChild(label)
        return label
    end
    addAttrLabel(ConfigFunc:getViewNameByFightName(attrName) .. ":", 0)
    layout.curNumLabel = addAttrLabel("", 55, nil)
    layout.nextNumLabel = addAttrLabel("", 185, cc.c3b(0x25, 0x87, 0x11))

    return layout
end

--- ==================== 数据显示相关 =======================
-- 显示所有信息
function HeroStepUpLayer:showInfo()
    local data = self.mHeroData
    self.mParent.mNameNode:refreshName(data)
    if not self.isCanStep then
        return
    end

    -- 读取突破阶段名
    local heroTals = HeroTalRelation.items[data.ModelId] or {}
    if (data.IllusionModelId ~= nil) and (data.IllusionModelId > 0) then
        heroTals = IllusionTalRelation.items[data.IllusionModelId] or {}
    end
    local function getStepName(nStep)
        return heroTals[nStep] and heroTals[nStep].TALName or TR("突破+%s", nStep)
    end

    -- 显示当前的突破阶段和属性值
    local currStepConfig = ConfigFunc:getHeroStepAttr(data.ModelId, data.Step, data.IllusionModelId)
    for i, attrComfig in ipairs(StepAttrsConfig) do
        local attrId = ConfigFunc:getFightAttrEnumByName(attrComfig)
        self.mAttrLayouts[i].curNumLabel:setString("+" .. Utility.getAttrViewStr(attrId, currStepConfig[attrComfig], false))
    end
    self.currStepLabel:setString(getStepName(data.Step))
    self.mUseList = Utility.analysisStrResList(currStepConfig.stepUpUse or "")  -- 保存突破所需的消耗
    
    -- 判断是否达到最高级
    local nextStepConfig = ConfigFunc:getHeroStepAttr(data.ModelId, data.Step + 1, data.IllusionModelId)
    if (nextStepConfig == nil) then
        -- 下一突破阶段和需求等级
        self.nextStepLabel:setString(TR("未知"))
        self.needLvLabel:setString("")
        
        -- 突破后的属性值
        for i, attrComfig in ipairs(StepAttrsConfig) do
            self.mAttrLayouts[i].nextNumLabel:setString(TR("未知"))
        end

        -- 新天赋
        self.mNewTalLabel:setString(TR("无"))
        self.mUseLayout:removeAllChildren()
        
        -- 显示满级提示
        local label = ui.newSprite("zb_26.png")
        label:setPosition(0, -65)
        self.mUseLayout:addChild(label)
        self.mBreakButton:setVisible(false)
    else
        -- 下一突破阶段和需求等级
        self.nextStepLabel:setString(getStepName(data.Step+1))
        if (currStepConfig.needLV ~= nil) then
            self.needLvLabel:setString(TR("需要等级: %s%s", ((data.Lv >= currStepConfig.needLV) and "#258711" or Enums.Color.eRedH), currStepConfig.needLV))
        else
            self.needLvLabel:setString("")
        end

        -- 突破后的属性值
        for i, attrComfig in ipairs(StepAttrsConfig) do
            local attrId = ConfigFunc:getFightAttrEnumByName(attrComfig)
            self.mAttrLayouts[i].nextNumLabel:setString("+" .. Utility.getAttrViewStr(attrId, nextStepConfig[attrComfig], false))
        end

        -- 显示新天赋
        local text = TR("无")
        local tal = heroTals[data.Step+1]
        if (tal ~= nil) then
            if (tal.TALModelID == 0) then
                text = TR("开启新的【天赋槽】")
            else
                text = TalModel.items[tal.TALModelID].intro
            end
        end
        self.mNewTalLabel:setString(text)

        -- 显示消耗
        self:showUseInfo(self.mUseLayout, data.ModelId, data.Step)
        self.mBreakButton:setVisible(true)
    end
end

-- 显示消耗信息
function HeroStepUpLayer:showUseInfo(layout, heroModelId, step)
    layout:removeAllChildren()

    -- 铜钱单独显示处理
    local tmpUseList = {}
    for _, resInfo in ipairs(self.mUseList) do
        if resInfo.resourceTypeSub == ResourcetypeSub.eGold then
            local tmpView = ui.createDaibiView({resourceTypeSub = resInfo.resourceTypeSub, number = resInfo.num})
            tmpView:setAnchorPoint(0, 0.5)
            tmpView:setPosition(160, -40)
            layout:addChild(tmpView)

            -- 标记铜钱是否足够
            resInfo.isMatch = (PlayerAttrObj:getPlayerAttr(resInfo.resourceTypeSub) >= resInfo.num)
        else
            table.insert(tmpUseList, resInfo)
        end
    end

    -- 显示其他道具资源
    local resourcesNum = #tmpUseList
    local startPosXList = {[1] = 0, [2] = 55, [3] = 55, [4] = 80}
    local startPosX = startPosXList[resourcesNum]
    for i, resInfo in ipairs(tmpUseList) do
        if resInfo.resourceTypeSub ~= ResourcetypeSub.eGold then
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
            layout:addChild(tmpCard)

            -- 显示当前拥有数值
            local numLabel = cardShowAttrs[CardShowAttr.eNum].label
            local holdNum = Utility.getOwnedGoodsCount(resInfo.resourceTypeSub, resInfo.modelId)
            -- 拥有数量修正：未上阵则去除自身
            if Utility.isHero(resInfo.resourceTypeSub) then
                holdNum = HeroObj:getCountByModelId(resInfo.modelId, {notInFormation = true, excludeIdList = {self.mHeroId}})
            elseif Utility.isTreasure(resInfo.resourceTypeSub) then
                holdNum = TreasureObj:getCountByModelId(resInfo.modelId, {notInFormation = true, maxLv = 0, maxStep = 0})
            elseif Utility.isIllusion(resInfo.resourceTypeSub) then
                holdNum = IllusionObj:getCountByModelId(resInfo.modelId, {notInFormation = true})
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

--- ==================== 特效相关 =======================
-- 突破特效
function HeroStepUpLayer:playHeroStepUpEffect()
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

--- ==================== 缓存数据操作 =======================
-- 按ID列表删除资源缓存
function HeroStepUpLayer:deleteResources(resourceTypeSub, idList)
    for _, id in ipairs(idList) do
        if Utility.isTreasure(resourceTypeSub) then
            TreasureObj:deleteTreasureById(id)
        elseif Utility.isHero(resourceTypeSub) then
            HeroObj:deleteHeroById(id)
        elseif Utility.isEquip(resourceTypeSub) then
            EquipObj:deleteEquipById(id)
        elseif Utility.isZhenjue(resourceTypeSub) then
            ZhenjueObj:deleteZhenjueById(id)
        elseif Utility.isIllusion(resourceTypeSub) then
            IllusionObj:deleteIllusion(id)
        end
    end
end

--- ==================== 服务器数据请求相关 =======================
-- 英雄进阶请求
function HeroStepUpLayer:requestHeroStepUp()
    local tmpIdList = {}
    for _, resInfo in ipairs(self.mUseList) do
        local tmpArray = nil
        resInfo.idList = {}

        if Utility.isTreasure(resInfo.resourceTypeSub) then
            tmpArray = TreasureObj:findByModelId(resInfo.modelId, {notInFormation = true, maxLv = 0, maxStep = 0})
        elseif Utility.isHero(resInfo.resourceTypeSub) then
            tmpArray = HeroObj:findHeroByModelId(resInfo.modelId, {notInFormation = true, maxStep = 0, maxLv = 1, excludeIdList = {self.mHeroData.Id}})
        elseif Utility.isEquip(resInfo.resourceTypeSub) then
            tmpArray = EquipObj:findByModelId(resInfo.modelId, {notInFormation = true, maxLv = 0, maxStep = 0})
        elseif Utility.isZhenjue(resInfo.resourceTypeSub) then
            tmpArray = ZhenjueObj:findByModelId(resInfo.modelId, {notInFormation = true, maxStep = 0})
        elseif Utility.isIllusion(resInfo.resourceTypeSub) then
            tmpArray = IllusionObj:getOneTypeIdList(resInfo.modelId, {notInFormation = true})
        end
        if tmpArray ~= nil then
            if (#tmpArray < resInfo.num) then
                ui.showFlashView(TR("含有已经进阶或者强化的") .. Utility.getGoodsName(resInfo.resourceTypeSub, resInfo.modelId))
                return
            end

            local num = resInfo.num
            for _, item in pairs(tmpArray) do
                table.insert(tmpIdList, item.Id)
                table.insert(resInfo.idList, item.Id)
                num = num - 1
                if num <= 0 then 
                    break 
                end
            end
        end
    end

    -- 发送请求
    HttpClient:request({
        moduleName = "Hero",
        methodName = "HeroStepUp",
        guideInfo = Guide.helper:tryGetGuideSaveInfo(10310),
        svrMethodData = {self.mHeroData.Id, tmpIdList},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return 
            end
            --[[--------新手引导--------]]--
            local _, _, eventID = Guide.manager:getGuideInfo()
            if eventID == 10310 then
                Guide.manager:nextStep(eventID)
                -- 屏蔽操作，等待突破特效
                Guide.manager:showGuideLayer({})
                Utility.performWithDelay(self.mBreakButton, handler(self, self.executeGuide), 1.75)
            end

            -- 修正缓存数据
            HeroObj:modifyHeroItem(response.Value)

            -- 删除使用道具（神兵、英雄等）
            for _, resInfo in ipairs(self.mUseList) do
                self:deleteResources(resInfo.resourceTypeSub, resInfo.idList)
            end

            -- 刷新界面
            self.mHeroData = HeroObj:getHero(self.mHeroId)
            self:showInfo()

            -- 播放特效
            self:playHeroStepUpEffect()
            
            -- 显示掉落
            if response.Value.BaseGetGameResourceList and #response.Value.BaseGetGameResourceList > 0 then
                ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
            end
        end
    })
end

-- ========================== 新手引导 ===========================
function HeroStepUpLayer:onEnterTransitionFinish()
    self:executeGuide()
end

function HeroStepUpLayer:executeGuide()
    Guide.helper:executeGuide({
        [10310] = {clickNode = self.mBreakButton},
        [10311] = {nextStep = handler(self, self.executeGuide)},
        [10312] = {clickNode = self.mParent.mCommonLayer_:getNavBtnObj(Enums.MainNav.eBattle)},
    })
end

return HeroStepUpLayer
