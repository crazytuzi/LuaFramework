--[[
    文件名: HeroRebornLayer.lua
    描述: 英雄转生(经脉)界面
    创建人: liaoyuangang
    创建时间: 2017.09.01
-- ]]

-- 转生模型Id列表
local RebornIdList = table.keys(RebornSlotRelation.items)
table.sort(RebornIdList, function(id1, id2)
    return id1 < id2
end)

-- 经脉槽位配置表
local SlotImgInfos = {
    ["jm_06.png"] = {
        positions = {
            cc.p(89, 3), cc.p(48, 102), cc.p(119, 135), cc.p(17, 171), 
            cc.p(6, 268), cc.p(82, 232), cc.p(97, 300), cc.p(23, 376),
        },
        effect = "effect_ui_jingmai_01"
    },
    ["jm_10.png"] = {
        positions = {  
            cc.p(98, 2), cc.p(8, 59), cc.p(91, 121), cc.p(47, 179), 
            cc.p(84, 221), cc.p(8, 236), cc.p(78, 298), cc.p(73, 379),
        },
        effect = "effect_ui_jingmai_02"
    },
    ["jm_11.png"] = {
     positions = {  
            cc.p(7, 6), cc.p(91, 68), cc.p(27, 126), cc.p(111, 163), 
            cc.p(95, 246), cc.p(6, 246), cc.p(21, 307), cc.p(80, 383),
         },
        effect = "effect_ui_jingmai_03"
    },
}

-- 经脉阶数图
local StepImgInfos = {
    -- {isLight = 点亮图， isDark = 熄灭图}
    {isLight = "jm_12.png", isDark = "jm_20.png"},
    {isLight = "jm_13.png", isDark = "jm_21.png"},
    {isLight = "jm_14.png", isDark = "jm_22.png"},
    {isLight = "jm_15.png", isDark = "jm_23.png"},
    {isLight = "jm_16.png", isDark = "jm_24.png"},
    {isLight = "jm_17.png", isDark = "jm_25.png"},
    {isLight = "jm_18.png", isDark = "jm_26.png"},
    {isLight = "jm_19.png", isDark = "jm_27.png"},
}

-- 经脉阶数位置表
local stepImgPositions = {
    -- 总阶数为偶数时
    [0] = {
        [1] = cc.p(135, 780), 
        [2] = cc.p(85, 710), 
        [3] = cc.p(150, 660), 
        [4] = cc.p(255, 630), 
        [5] = cc.p(395, 630), 
        [6] = cc.p(500, 660), 
        [7] = cc.p(565, 710), 
        [8] = cc.p(515, 780), 
        },
    -- 奇数
    [1] = {
        [1] = cc.p(165, 735), 
        [2] = cc.p(125, 665), 
        [3] = cc.p(215, 630), 
        [4] = cc.p(320, 620), 
        [5] = cc.p(415, 630), 
        [6] = cc.p(505, 665), 
        [7] = cc.p(465, 735), 
        }
}

-- 转生次数相关图
local rebornImgInfos = {
    -- 正对面板
    normal = {
        -- 点亮
        isLight = "jm_55.png",
        -- 熄灭
        isDark = "jm_54.png"
    },

    -- 向右倾斜(第2个)
    rightOriented = {
        isLight = "jm_56.png",
        isDark = "jm_53.png",
    },

    leftOriented = {
    -- 向左倾斜(倒数第2个)
        isLight = "jm_58.png",
        isDark = "jm_57.png"
    }
}

-- 默认最大转生重数
local DefaultRebornNumMax = 9

local HeroRebornLayer = class("HeroRebornLayer", function()
    return display.newLayer()
end)

--[[
    params:
    {
        parent              父节点
        heroData            hero信息
    }
--]]
function HeroRebornLayer:ctor(params)
    -- 传入参数
    self.mParent = params.parent
    self.mHeroId = params.heroId

    -- 背景layer
    self.mBgLayer = self.mParent.mRebornBgSprite

    -- 创建UI
    self:initUI()

    --刷新背景图的重数板子
    self:refreshBgSprite()

    -- 刷新页面显示
    -- self:refreshLayer()
    -- 等页面加载完毕，scrollView reload后再刷新
    Utility.performWithDelay(self, handler(self, self.refreshLayer), 0.05)
end

-- 创建UI
function HeroRebornLayer:initUI()
    -- 父容器（Tab显示的可见区域）
    local layout = ccui.Layout:create()
    layout:setContentSize(640, 435)
    layout:setAnchorPoint(0.5, 0)
    layout:setPosition(320, 80)
    self:addChild(layout)
    self.mPanelLayout = layout

    
    -- 属性信息背景框
    local attrBgSprite = ui.newScale9Sprite("c_17.png", cc.size(610, 182))
    attrBgSprite:setAnchorPoint(cc.p(0.5, 1))
    attrBgSprite:setPosition(320, 415)
    self.mPanelLayout:addChild(attrBgSprite)
    self.mAttrBgSprite = attrBgSprite
    -- 当前阶属性背景框
    self.mCurrSlotSprite = ui.newScale9Sprite("c_54.png", cc.size(250, 156))
    self.mCurrSlotSprite:setPosition(135, 91)
    attrBgSprite:addChild(self.mCurrSlotSprite)
    -- 下一阶属性背景框
    self.mNextSlotSprite = ui.newScale9Sprite("c_54.png", cc.size(250, 156))
    self.mNextSlotSprite:setPosition(475, 91)
    attrBgSprite:addChild(self.mNextSlotSprite)
    -- 下一转生属性的parent
    self.mNextRebornNode = ccui.Layout:create()
    self.mNextRebornNode:setPosition(0, 0)
    self.mNextRebornNode:setContentSize(cc.size(610, 182))
    attrBgSprite:addChild(self.mNextRebornNode)
    -- 属性中间的箭头
    self.mArrowSprite = ui.newSprite("c_67.png")
    self.mArrowSprite:setPosition(302, 91)
    attrBgSprite:addChild(self.mArrowSprite)

    -- 显示转生的消耗控件的parent
    self.mUseParent = ccui.Layout:create()
    self.mUseParent:setPosition(360, 140)
    self.mPanelLayout:addChild(self.mUseParent)

    -- 显示需要等级
    self.mNeedLvLabel = ui.newLabel({
        text = TR("需要: %s%d级", "#D17B00", 0),
        color = cc.c3b(0x46, 0x22, 0x0d),
        size = 24,
    })
    self.mNeedLvLabel:setPosition(320, 200)
    self.mPanelLayout:addChild(self.mNeedLvLabel)

    -- 满级图标
    self.fullLevelSprite = ui.newSprite("jm_60.png")
    self.fullLevelSprite:setPosition(320, 180)
    self.mPanelLayout:addChild(self.fullLevelSprite)
    self.fullLevelSprite:setVisible(false)

    -- 创建转生按钮
    self.mRebornBtn = ui.newButton({
        normalImage = "c_28.png",
        position = cc.p(320, 93),
        text = TR("冲脉"),
        clickAction = function()
            local heroData = HeroObj:getHero(self.mHeroId)
            -- 查找需要激活的slot序号列表
            local slotInfo = RebornSlotRelation.items[heroData.RebornId][heroData.RebornNum + 1]
            --
            local rebornLvModel = RebornLvModel.items[heroData.RebornId]
            
            -- 判断是否已达到最大转生等级
            if heroData.RebornNum == 0 and not slotInfo then
                ui.showFlashView(TR("侠客已达到最大经脉等级"))
                return 
            end

            -- 判断等级是否足够
            local nextIndex = table.indexof(RebornIdList, heroData.RebornId)
            local nextClassId = RebornIdList[nextIndex + 1] and RebornLvModel.items[RebornIdList[nextIndex + 1]].classID or nil
            local nextModel = nextClassId == rebornLvModel.classID and RebornLvModel.items[RebornIdList[nextIndex + 1]] or nil
            if nextModel and nextModel.needLv > heroData.Lv then
                ui.showFlashView(TR("侠客%d级后才能继续冲脉.", nextModel.needLv))
                return
            end

            -- 判断消耗的资源是否足够
            if not self:enoughRebornRes(slotInfo and slotInfo.useStr or rebornLvModel.useStr) then
                return 
            end

            if slotInfo then 
                self:requestActivate(heroData.Id)
            else
                self:requestReborn(heroData.Id)
            end
        end
    })
    self.mPanelLayout:addChild(self.mRebornBtn)

    -- 创建一键转生按钮
    local onekeyBtn = ui.newButton({
        normalImage = "jm_04.png",
        position = cc.p(580, 93),
        clickAction = function()
            -- 判断当前有没有需要激活的卡槽
            local heroData = HeroObj:getHero(self.mHeroId)
            -- 查找需要激活的slot序号列表
            local slotInfo = RebornSlotRelation.items[heroData.RebornId][heroData.RebornNum + 1]
            --
            local rebornLvModel = RebornLvModel.items[heroData.RebornId]

            -- 判断是否已达到最大转生等级
            if heroData.RebornNum == 0 and not slotInfo then
                ui.showFlashView(TR("侠客已达到最大经脉等级"))
                return 
            end

            -- 判断等级是否足够
            local nextIndex = table.indexof(RebornIdList, heroData.RebornId)
            local nextClassId = RebornIdList[nextIndex + 1] and RebornLvModel.items[RebornIdList[nextIndex + 1]].classID or nil
            local nextModel = nextClassId == rebornLvModel.classID and RebornLvModel.items[RebornIdList[nextIndex + 1]] or nil
            if nextModel and nextModel.needLv > heroData.Lv then
                ui.showFlashView(TR("侠客%d级后才能继续冲脉.", nextModel.needLv))
                return
            end

            -- 判断消耗的资源是否足够
            if not self:enoughRebornRes(slotInfo and slotInfo.useStr or rebornLvModel.useStr) then
                return 
            end

            local totolStepsList = self:getRebornLvIdList(heroData.RebornId)
            -- step从0开始， 所以加1
            local isLastStep = (rebornLvModel.step + 1) == #totolStepsList

            -- 获取当前进阶数, 如果当前进阶数不为最后一阶,就发一键冲脉请求
            if isLastStep and not slotInfo then
                self:requestReborn(heroData.Id)
            else
                self:requestActivateForOneKey(heroData.Id)
            end
        end
    })
    self.mPanelLayout:addChild(onekeyBtn)
    self.mOneKeyBtn = onekeyBtn

    -- 经脉共鸣按钮
    local mastBtn = ui.newButton({
        normalImage = "jm_03.png",
        position = cc.p(65, 1025),
        clickAction = function()
            -- todo
            LayerManager.addLayer({
                name = "hero.RebornMasterLayer",
                data = { parent = self },
                cleanUp = false,
                })
        end
    })
    self:addChild(mastBtn)

    -- 天赋预览按钮
    local previewBtn = ui.newButton({
        normalImage = "jm_02.png",
        position = cc.p(65, 900),
        clickAction = function()
            local tmpData = HeroObj:getHero(self.mHeroId)
            if tmpData.RebornId then
                LayerManager.addLayer({
                    name = "hero.RebornPreviewLayer",
                    data = tmpData,
                    cleanUp = false
                    })
            else
                ui.showFlashView({text = TR("此侠客没有天赋。")})
            end
        end
    })
    self:addChild(previewBtn)
end

-- 判断转生资源是否足够
function HeroRebornLayer:enoughRebornRes(useStr)
    local useList = Utility.analysisStrResList(useStr)
    for _, item in pairs(useList) do
        if Utility.isPlayerAttr(item.resourceTypeSub) then
            if not Utility.isResourceEnough(item.resourceTypeSub, item.num, true) then
                return false
            end
        else
            local ownedCnt = Utility.getOwnedGoodsCount(item.resourceTypeSub, item.modelId)
            if ownedCnt < item.num then
                LayerManager.addLayer({
                    name = "hero.DropWayLayer",
                    data = {
                        resourceTypeSub = item.resourceTypeSub, 
                        modelId = item.modelId
                    }
                })
                return false
            end
        end
    end

    return true
end

-- 获取人物所在重的转生等级模型列表
function HeroRebornLayer:getRebornLvIdList(rebornLvModelId)
    local tempModel = RebornLvModel.items[rebornLvModelId]
    local rebornNum = tempModel and tempModel.rebornNum or 0
    local classId = tempModel and tempModel.classID or 0

    local retList = {}
    for _, item in pairs(RebornLvModel.items) do
        if classId == item.classID and item.rebornNum == rebornNum then
            table.insert(retList, item.ID)
        end
    end
    table.sort(retList, function(id1, id2)
        return id1 < id2
    end)

    return retList
end

-- 隐藏转生相关ui
function HeroRebornLayer:setHideRebornRelatedUI(isHide)
    if self.mHintSprite then
        self.mHintSprite:removeFromParent()
        self.mHintSprite = nil
    end

    if isHide then
        -- 如果当前是主角，需要特殊提示，并且需要调整到拼酒页面
        local heroData = HeroObj:getHero(self.mHeroId)
        local heroModel = heroData and HeroModel.items[heroData.ModelId]
        local isMainHero = heroModel and heroModel.specialType == Enums.HeroType.eMainHero or false

        -- 提示框  
        local hintStr = TR("橙色及以上品质侠客才能激活经脉.") 
        hintStr = hintStr .. (isMainHero and TR("拼酒可以提升主角品质，是否前往？") or "")
        local hintSprite = ui.createEmptyHint(hintStr)
        hintSprite:setAnchorPoint(0.5, 0.5)
        hintSprite:setPosition(cc.p(320, 290))
        self.mPanelLayout:addChild(hintSprite)
        self.mHintSprite = hintSprite
        if isMainHero then
            local tempSize = hintSprite:getContentSize()
            local tempBtn = ui.newButton({
                normalImage = "c_28.png",
                text = TR("去拼酒"),
                clickAction = function()
                    if not ModuleInfoObj:moduleIsOpen(ModuleSub.ePracticeLightenStar, true) then
                        return
                    end
                    LayerManager.addLayer({name ="practice.LightenStarLayer",})
                end
            })
            tempBtn:setPosition(tempSize.width / 2 - 50, -20)
            hintSprite:addChild(tempBtn)
        end

        -- ui隐藏
        self.mAttrBgSprite:setVisible(false)
        self.mRebornBtn:setVisible(false)
        self.mNeedLvLabel:setVisible(false)
        self.mOneKeyBtn:setVisible(false)
        self.fullLevelSprite:setVisible(false)
        if self.mUseList then
            for _,item in pairs(self.mUseList) do
                item:setVisible(false)
            end
        end
    else
        -- ui显示
        self.mAttrBgSprite:setVisible(true)
        self.mRebornBtn:setVisible(true)
        self.mNeedLvLabel:setVisible(true)
        self.mOneKeyBtn:setVisible(true)
        if self.mUseList then
            for _,item in pairs(self.mUseList) do
                item:setVisible(true)
            end
        end
    end
end

-- 刷新页面显示
function HeroRebornLayer:refreshLayer()
    local heroData = HeroObj:getHero(self.mHeroId)
    --
    local currModel = RebornLvModel.items[heroData.RebornId] or {}
    -- 下个转生等级的model
    local nextIndex = table.indexof(RebornIdList, heroData.RebornId) or 0
    local nextClassId = RebornIdList[nextIndex + 1] and RebornLvModel.items[RebornIdList[nextIndex + 1]].classID or nil
    local nextModel = nextClassId == currModel.classID and RebornLvModel.items[RebornIdList[nextIndex + 1]] or nil
    -- 不能转生
    local slotInfo = RebornSlotRelation.items[heroData.RebornId]
    if not slotInfo then
        self:setHideRebornRelatedUI(true)
        self:refreshBgSprite()
        return 
    end
    
    -- 当前属性值列表
    local currAttrList = {}
    -- 下一个属性值列表
    local nextAttrList = {}
    -- 当前消耗
    local useList = {}
    -- 是否需要激活转生
    local needReborn = false

    if heroData.RebornNum >= #slotInfo and heroData.RebornNum > 0 then -- 需要进阶或激活转生次数
        local tempStr = slotInfo[#slotInfo].allAttrStr
        currAttrList = Utility.analysisStrAttrList(tempStr)
        if nextModel then
            nextAttrList = Utility.analysisStrAttrList(nextModel.allAttrStr)
            -- 是否需要激活转生
            needReborn = currModel.rebornNum < nextModel.rebornNum
            -- 当前消耗
            useList = Utility.analysisStrResList(nextModel.useStr)
        end
    else -- 激活卡槽
        local tempStr = heroData.RebornNum == 0 and currModel.allAttrStr or slotInfo[heroData.RebornNum].allAttrStr
        currAttrList = Utility.analysisStrAttrList(tempStr)

        local nextSlot = slotInfo[heroData.RebornNum + 1]
        local tempStr = nextSlot and nextSlot.allAttrStr
        nextAttrList = Utility.analysisStrAttrList(tempStr)

        -- 当前消耗
        useList = Utility.analysisStrResList(nextSlot and nextSlot.useStr)
    end

    -- 显示转生属性信息
    local function refreshSlotAttr(attrParent, titleStr, viewNext)
        local parentSize = attrParent:getContentSize()

        -- 显示标题
        local titleLabel = ui.newLabel({
            text = titleStr,
            size = 24,
            color = Enums.Color.eWhite,
            outlineColor = cc.c3b(0x72, 0x25, 0x13),
            outlineSize = 2,
        })
        titleLabel:setPosition(parentSize.width / 2, parentSize.height - 22)
        attrParent:addChild(titleLabel)

        -- 判断是否达到最大转生等级
        if viewNext and heroData.RebornNum == 0 and not slotInfo[heroData.RebornNum + 1] then 
            local tempLabel = ui.newLabel({
                text = TR("该侠客已达到最高经脉等级。"),
                color = cc.c3b(0x46, 0x22, 0x0d),
                dimensions = cc.size(parentSize.width - 20, 0),
            })
            tempLabel:setPosition(parentSize.width / 2, (parentSize.height - 35) / 2)
            attrParent:addChild(tempLabel)
            return 
        end

        -- 显示属性
        local currMap, nextMap = {}, {}
        for _, item in pairs(currAttrList) do
            currMap[item.fightattr] = item.value
        end
        for _, item in pairs(nextAttrList) do
            nextMap[item.fightattr] = item.value
        end

        for index, attr in ipairs({Fightattr.eHP, Fightattr.eAP, Fightattr.eDEF}) do
            local tempValue = viewNext and nextMap[attr] or currMap[attr]
            local addValue = viewNext and (nextMap[attr] and (nextMap[attr] - (currMap[attr] or 0)) or 0) or 0
            local attrName = FightattrName[attr]

            local tempPosX, tempPosY = 30, 90 - (index - 1) * 28
            -- 
            local attrLabel = ui.newLabel({
                text = string.format("%s: %s+%s", attrName, "#348032", tempValue or 0),
                color = cc.c3b(0x46, 0x22, 0x0d),
            })
            attrLabel:setAnchorPoint(cc.p(0, 0.5))
            attrLabel:setPosition(tempPosX, tempPosY)
            attrParent:addChild(attrLabel)

            -- 
            if addValue ~= 0 then
                local tempNode = ui.createSpriteAndLabel({
                    imgName = (addValue > 0) and "c_78.png" or "c_77.png",
                    labelStr = "", -- string.format("(%+d)", addValue),
                    fontColor = (addValue > 0) and cc.c3b(0x34, 0x80, 0x32) or cc.c3b(0xfe, 0x1c, 0x46),
                    alignType = ui.TEXT_ALIGN_RIGHT,
                }) 
                tempNode:setAnchorPoint(cc.p(0, 0.5))
                tempNode:setPosition(tempPosX + attrLabel:getContentSize().width + 5, tempPosY)
                attrParent:addChild(tempNode)
            end
        end
    end

    -- 显示转生属性
    local function refreshRebornAttr(attrParent, rebornModel, attrList)
        local parentSize = attrParent:getContentSize()

        -- 
        if rebornModel.talIcon ~= "" then
            local tempCard = CardNode:create({allowClick = false})
            tempCard:setPosition(70, parentSize.height / 2)
            tempCard:setEmpty({}, "c_08.png", rebornModel.talIcon .. ".png")
            attrParent:addChild(tempCard)
        end

        -- 转生描述
        local introLabel = ui.newLabel({
            text = rebornModel.curTalIntro or "",
            color = cc.c3b(0x46, 0x22, 0x0d),
        })
        introLabel:setAnchorPoint(cc.p(0, 0.5))
        introLabel:setPosition(130, 100)
        attrParent:addChild(introLabel)

        -- 属性
        local tempMap = {}
        for _, item in pairs(attrList) do
            local textStr = string.format("#46220d%s: #348032%s", FightattrName[item.fightattr], Utility.getAttrViewStr(item.fightattr, item.value))
            table.insert(tempMap, textStr)
        end
        local attrLabel = ui.newLabel({
                text = table.concat(tempMap, "    "),
                color = cc.c3b(0x46, 0x22, 0x0d),
                dimensions = cc.size(450, 0),
            })
        attrLabel:setAnchorPoint(cc.p(0, 1))
        attrLabel:setPosition(130, 75)
        attrParent:addChild(attrLabel)
    end

    -- 下一转属性的parent
    self.mNextRebornNode:removeAllChildren()
    --
    self.mCurrSlotSprite:removeAllChildren()
    self.mCurrSlotSprite:setVisible(not needReborn)
    -- 
    self.mNextSlotSprite:removeAllChildren()
    self.mNextSlotSprite:setVisible(not needReborn)
    --
    self.mArrowSprite:setVisible(not needReborn)
    --
    self.mUseParent:removeAllChildren()

    -- 刷新属性显示
    if needReborn then
        refreshRebornAttr(self.mNextRebornNode, nextModel, nextAttrList)
    else
        -- 刷新当前的属性
        refreshSlotAttr(self.mCurrSlotSprite, TR("当前等级"), false)
        -- 刷新下一阶的属性
        refreshSlotAttr(self.mNextSlotSprite, TR("下一等级"), true)
    end

    -- 显示下一次转生需要的等级
    local needLv = currModel and currModel.needLv or nil
    needLv = nextModel and nextModel.needLv or nil
    local nextSlot = slotInfo[heroData.RebornNum + 1]
    if needLv or nextSlot then
        self.mNeedLvLabel:setString(TR("需要等级: %s%d级", "#D17B00", needLv or currModel.needLv))
        self.fullLevelSprite:setVisible(false)
    else
    	self.mNeedLvLabel:setString("")
        self.fullLevelSprite:setVisible(true)
    end
    
    -- 消耗列表
    self.mUseList = {}
    -- 显示消耗
    local space = 240
    local startPosX = 0 - (#useList * space) / 2
    for index, item in ipairs(useList) do
        item.showOwned = true
        local tempSprite, tempLabel = ui.createDaibiView(item)
        tempSprite:setAnchorPoint(cc.p(0, 0.5))
        tempSprite:setPosition(startPosX + (index - 1) * space, 0)
        self.mUseParent:addChild(tempSprite)
        table.insert(self.mUseList, tempSprite)
    end

    -- 刷新经脉卡槽
    self:refreshSlotSprite()

    -- 刷新转生背景
    self:refreshBgSprite()
end

-- 刷新经脉卡槽
function HeroRebornLayer:refreshSlotSprite()
    local allImgList = {"jm_06.png", "jm_10.png", "jm_11.png"}
    local heroData = HeroObj:getHero(self.mHeroId)
    local itemNode = self.mParent:getCurrHeroFigure()
    local tempModel = RebornLvModel.items[heroData.RebornId or ""]
    local viewImgName = tempModel and allImgList[math.mod(tempModel.step, #allImgList) + 1] or "jm_06.png"

    -- 经脉阶数相关
    local currSteps = RebornLvModel.items[heroData.RebornId].step
    local lvModelIdList = self:getRebornLvIdList(heroData.RebornId)

    -- 刷新几经几脉
    local rebornSprite = itemNode.figure and itemNode.figure.rebornSprite
    if not tolua.isnull(rebornSprite) then
        rebornSprite.setLevel(heroData.RebornId)
    end

    local stepNode = itemNode.stepNode
    if tolua.isnull(stepSprite) then
        stepNode = cc.Node:create()
        stepNode:setContentSize(640, 1136)
        stepNode:setPosition(320, 558)
        stepNode:setAnchorPoint(0.5, 0.5)
        itemNode:addChild(stepNode)
    end
    stepNode:setVisible(#lvModelIdList > 0)
    stepNode:removeAllChildren()

    for index, item in pairs(lvModelIdList) do
        local tempSprite = ui.newSprite(StepImgInfos[index][index <= currSteps and "isLight" or "isDark"])
        tempSprite:setPosition(stepImgPositions[#lvModelIdList % 2][index + math.floor((8 - #lvModelIdList)/2)])

        tempSprite:setAnchorPoint(0.5, 0.5)
        stepNode:addChild(tempSprite)
    end

    -- 
    local lineSprite = itemNode.lineSprite
    if tolua.isnull(lineSprite) then
        lineSprite = ui.newSprite(viewImgName)
        lineSprite:setPosition(320, 840)
        itemNode:addChild(lineSprite)

        lineSprite.imgName = viewImgName
        itemNode.lineSprite = lineSprite
    elseif viewImgName ~= lineSprite.imgName then
        lineSprite:removeAllChildren()
        lineSprite:setTexture(viewImgName)
        lineSprite.imgName = viewImgName
    end
    
    if lineSprite:getChildrenCount() == 0 then
        local posSpriteList = {}
        local posList = SlotImgInfos[viewImgName].positions
        for index, pos in pairs(posList) do
            local tempName = index > heroData.RebornNum and "jm_08.png" or "jm_07.png"
            local tempSprite = ui.newSprite(tempName)
            tempSprite:setPosition(pos)
            lineSprite:addChild(tempSprite, 0, index) -- 添加标签, 播放特效用
            tempSprite.imgName = tempName

            --点亮特效
            local tempSize = tempSprite:getContentSize()
            if index <= heroData.RebornNum then
                local effect = ui.newEffect({
                    parent = tempSprite,
                    effectName = "effect_ui_jingmai_liang_xuanhuan",
                    position = cc.p(tempSize.width/2, tempSize.height/2),
                    loop = true,
                    endRelease = true,
                })
            end

            table.insert(posSpriteList, tempSprite)
        end
        lineSprite.posSpriteList = posSpriteList

        local selectSprite = ui.newSprite("jm_09.png")
        selectSprite:setPosition(posList[math.min(heroData.RebornNum + 1, #posList)])
        lineSprite:addChild(selectSprite)
        lineSprite.selectSprite = selectSprite
    else
        for index, sprite in pairs(lineSprite.posSpriteList or {}) do
            local tempName = index > heroData.RebornNum and "jm_08.png" or "jm_07.png"
            if tempName ~= sprite.imgName then
                sprite:setTexture(tempName)
                sprite.imgName = tempName

                --点亮特效
                local tempSize = sprite:getContentSize()
                if index <= heroData.RebornNum then
                    local effect = ui.newEffect({
                        parent = sprite,
                        effectName = "effect_ui_jingmai_liang_xuanhuan",
                        position = cc.p(tempSize.width/2, tempSize.height/2),
                        loop = true,
                        endRelease = true,
                    })
                end
            end
        end

        local posList = SlotImgInfos[viewImgName].positions
        local selectPos = posList[math.min(heroData.RebornNum + 1, #posList)]
        lineSprite.selectSprite:setPosition(selectPos)
    end
end

-- 刷新背景中的重数
function HeroRebornLayer:refreshBgSprite()
    if not self.mBgLayer then
        print("HeroRebornLayer:refreshBgSprite() failed")
        return 
    end

    local rebornId = HeroObj:getHero(self.mHeroId).RebornId
    local currRebornNum = rebornId and RebornLvModel.items[rebornId].rebornNum or 0 -- 当前转生次数

    local startPosX = 75
    local startPosY = 555
    local gaps = 70

    local fluctuateY = 2 -- 起伏高低参数

    local startIndex = 1
    if currRebornNum > DefaultRebornNumMax then
        startIndex = currRebornNum - DefaultRebornNumMax + 1
    end
    -- 共9块面板, 第2块和倒数第2块为特殊的倾斜的板子
    for index = 1, DefaultRebornNumMax do
        local imgType = index == 2 and "rightOriented" or index == DefaultRebornNumMax - 1 and "leftOriented" or "normal"
        local isLight = index <= currRebornNum and "isLight" or "isDark"
        local imgStr = rebornImgInfos[imgType][isLight]

        local tempSprite = ui.newSprite(imgStr)
        tempSprite:setAnchorPoint(1, 1)

        tempSprite:setPosition(startPosX, startPosY + (index%2 == 0 and fluctuateY or 0))

        local tempSize = tempSprite:getContentSize()
        -- 数字
        local numberLabel = ui.newNumberLabel({
            text = Utility.getNumPicChar(startIndex),
            imgFile = "jm_62.png",
            charCount = 10,
            startChar = 49,
            })
        numberLabel:setAnchorPoint(0.5, 0.5)
        numberLabel:setPosition(tempSize.width / 2, 140)
        tempSprite:addChild(numberLabel)

        startIndex = startIndex + 1

        self.mBgLayer:addChild(tempSprite)

        startPosX = startPosX + gaps
    end
end

--- ==================== 特效相关 =======================

-- 转生特效
function HeroRebornLayer:playRebornEffect(endCallback)
    local allImgList = {"jm_06.png", "jm_10.png", "jm_11.png"}
    local heroData = HeroObj:getHero(self.mHeroId)
    local tempModel = RebornLvModel.items[heroData.RebornId or ""]
    local viewImgName = tempModel and allImgList[math.mod(tempModel.step, #allImgList) + 1] or "jm_06.png"
    local effectName = SlotImgInfos[viewImgName].effect

    local itemNode = self.mParent:getCurrHeroFigure()
    if not tolua.isnull(itemNode.lineSprite) then
        ui.newEffect({
            parent = itemNode,
            effectName = effectName,
            position = cc.p(itemNode.lineSprite:getPosition()),
            loop = false,
            endRelease = true,
            completeListener = function()
                endCallback()
            end
        })
    else
        endCallback()
    end

    -- 音乐
    MqAudio.playEffect("jingmailiuzhuan.mp3")
end

-- 激活卡槽的特效
function HeroRebornLayer:playActiveEffect(endCallback)
    endCallback()

    -- 音乐
    MqAudio.playEffect("jingmai.mp3")
end

--- ==================== 服务器数据请求相关 =======================
-- 人物转生服务器请求
function HeroRebornLayer:requestReborn(heroId)
    -- 当前是否正在处理转生逻辑
    if self.mRebornDoing then
        return 
    end
    self.mRebornDoing = true

    HttpClient:request({
        moduleName = "RebornInfo",
        methodName = "Reborn",
        svrMethodData = {heroId, {}},
        callback = function(response)
            if not response or response.Status ~= 0 then
                self.mRebornDoing = false
                return 
            end
            
            HeroObj:modifyHeroItem(response.Value)

            -- 先播放转生成功的特效，再改变数据
            self:playRebornEffect(function( ... )
                if self and not tolua.isnull(self) then self:refreshLayer() end
                self.mRebornDoing = false
            end)
        end
    })
end

-- 人物转生服务器请求
function HeroRebornLayer:requestActivate(heroId)
    HttpClient:request({
        moduleName = "RebornInfo",
        methodName = "Activate",
        svrMethodData = {heroId},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return 
            end

            self:playActiveEffect(function()
                HeroObj:modifyHeroItem(response.Value)
                self:refreshLayer()
            end)
        end
    })
end

-- 一键激活转生卡槽 服务器请求
function HeroRebornLayer:requestActivateForOneKey(heroId)
    HttpClient:request({
        moduleName = "RebornInfo",
        methodName = "ActivateForOneKey",
        svrMethodData = {heroId, {}},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return 
            end

            self:playActiveEffect(function()
                HeroObj:modifyHeroItem(response.Value)
                self:refreshLayer()
            end)
        end
    })
end

return HeroRebornLayer