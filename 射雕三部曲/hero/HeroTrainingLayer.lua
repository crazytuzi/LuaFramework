--[[
    文件名：HeroTrainingLayer.lua
    描述：英雄培养界面
    创建人：peiyaoqiang
    创建时间：2017.3.11
-- ]]

-- 功能开放配置
local trainOpenConfig = {
    eOnlyMainHero = 1,      -- 仅主角开放
    eOnlyNormalHero = 2,    -- 仅其他侠客开放
    eAllHero = 3,           -- 所有侠客都开放
}

-- 开放功能定义
local TabsConfig = {
    {
        name = TR("升级"),
        moduleId = ModuleSub.eHeroLvUp,
        openConfig = trainOpenConfig.eOnlyNormalHero,
        filename = "hero.HeroLevelUpLayer",
    },
    {
        name = TR("突破"),
        moduleId = ModuleSub.eHeroStepUp,
        openConfig = trainOpenConfig.eAllHero,
        filename = "hero.HeroStepUpLayer",
    },
    {
        name = TR("经脉"),
        moduleId = ModuleSub.eReborn,
        openConfig = trainOpenConfig.eAllHero,
        filename = "hero.HeroRebornLayer",
    },
    {
        name = TR("招式"),
        moduleId = ModuleSub.eHeroChoiceTalent,
        openConfig = trainOpenConfig.eOnlyMainHero,
        filename = "hero.HeroBookLayer",
    },
    {
        name = TR("绝学"),
        moduleId = ModuleSub.eFashion,
        openConfig = trainOpenConfig.eOnlyMainHero,
        filename = "hero.HeroFashionLayer",
    },
    {
        name = TR("淬体"),
        moduleId = ModuleSub.eHeroQuench,
        openConfig = trainOpenConfig.eAllHero,
        filename = "hero.HeroQuenchLayer",
    },
    {
        name = TR("幻化"),
        moduleId = ModuleSub.eIllusion,
        openConfig = trainOpenConfig.eOnlyNormalHero,
        filename = "hero.HeroIllusionLayer",
    },
}

-- 模块内部消息
local SelectSlotChange = "eTeamLayerSelectSlotChange"  -- 选中卡槽改变的事件名称


----------------------------------------------------------------------------------------------------
--
local HeroTrainingLayer = class("HeroTrainingLayer", function()
    return display.newLayer(cc.c4b(0, 0, 0, 100))
end)

--[[
    params:
    {
        heroesData:hero列表，如果不传，则自动读取阵容里的所有人物
        originalTag:初始选中页面的子模块id
        originalId:初始选中的人物ID
        selectTalentIdx:
    }
--]]
function HeroTrainingLayer:ctor(params)
    -- 要显示的人物列表原始数据
    self.rawHeroList = {}
    if params.heroesData then
        -- 删除不存在的人物
        for _,v in ipairs(params.heroesData) do
            local vItem = HeroObj:getHero(v.Id)
            if (vItem ~= nil) then
                table.insert(self.rawHeroList, clone(vItem))
            end
        end
    else
        -- 自动读取所有已上阵人物
        for _, slotItem in ipairs(FormationObj:getSlotInfos()) do
            local data = HeroObj:getHero(slotItem.HeroId)
            if (data ~= nil) then
                table.insert(self.rawHeroList, data)
            end
        end
    end
    
    -- 控制参数并处理数据 
    self.mCurrHeroId = params.originalId or self.rawHeroList[1].Id
    self.mOriginalTag = params.originalTag or ModuleSub.eHeroLvUp   -- 默认显示的模块
    if (self.mOriginalTag == ModuleSub.eHeroLvUp) and (HeroModel.items[HeroObj:getHero(self.mCurrHeroId).ModelId].specialType == Enums.HeroType.eMainHero) then
        -- 如果是主角，则默认Tab修改为突破
        self.mOriginalTag = ModuleSub.eHeroStepUp
    end
    self.showHeroList = self:getDataByModule(self.mOriginalTag)     -- 需要显示的人物，方便列表刷新
    
    -- 其他参数（一般用于各个分页面）
    self.selectTalentIdx = params.selectTalentIdx or 1
    
    -- 创建顶部资源栏和底部导航栏
    local topResource = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        currentLayerType = Enums.MainNav.eFormation,
        topInfos = {
            ResourcetypeSub.eDiamond,
            ResourcetypeSub.eGold,
            ResourcetypeSub.eHeroExp,
        }
    })
    self:addChild(topResource, 1)
    self.mCommonLayer_ = topResource

    -- 创建该页面的父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 创建层
    self:initUI()

    -- 设置小红点
    for _, item in pairs({ModuleSub.eHeroStepUp, ModuleSub.eReborn, ModuleSub.eHeroChoiceTalent}) do
        local eventNames = {SelectSlotChange, EventsName.eRedDotPrefix .. tostring(ModuleSub.eFormation)}
        local function dealStepUpRedDotVisible(redDotSprite)
            local slotIndex = self:getCurrSlotId()
            redDotSprite:setVisible(RedDotInfoObj:isValid(item, nil, slotIndex))
        end
        local tabBtn = self.mTabView:getTabBtnByTag(item)
        if tabBtn then
            ui.createAutoBubble({
                parent = tabBtn, 
                eventName = eventNames, 
                refreshFunc = dealStepUpRedDotVisible
            })
        end
    end
end

-- 创建UI
function HeroTrainingLayer:initUI()
    -- 背景图
    local bgSprite = ui.newSprite("zr_18.jpg")
    bgSprite:setAnchorPoint(cc.p(0.5, 1))
    bgSprite:setPosition(320, 1136)
    self.mParentLayer:addChild(bgSprite)

    -- 经脉的专用背景图
    local rebornBgSprite = ui.newSprite("jm_51.jpg")
    rebornBgSprite:setAnchorPoint(cc.p(0.5, 1))
    rebornBgSprite:setPosition(320, 1136)
    self.mParentLayer:addChild(rebornBgSprite)
    self.mRebornBgSprite = rebornBgSprite

    -- 退出按钮
    local btnClose = ui.newButton({
        normalImage = "c_29.png",
        anchorPoint = cc.p(0.5, 0.5),
        position = Enums.StardardRootPos.eCloseBtn,
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(btnClose, 5)
    self.mCloseBtn = btnClose

    -- 左箭头
    local leftArrowSprite = ui.newSprite("c_26.png")
    leftArrowSprite:setPosition(32, 780)
    leftArrowSprite:setScale(-1)
    self.mParentLayer:addChild(leftArrowSprite, 1)
    self.mLeftArrow = leftArrowSprite

    -- 右箭头
    local rightArrowSprite = ui.newSprite("c_26.png")
    rightArrowSprite:setPosition(608, 780)
    self.mParentLayer:addChild(rightArrowSprite, 1)
    self.mRightArrow = rightArrowSprite

    -- 操作面板
    local sprite = ui.newScale9Sprite("c_19.png", cc.size(640, 530))
    sprite:setAnchorPoint(0.5, 0)
    sprite:setPosition(320, 0)
    self.mParentLayer:addChild(sprite, 1)

    -- 创建人物名字
    local nameNode, _, nameLabel = Figure.newNameAndStar({
        parent = self.mParentLayer,
        position = cc.p(320, 1120),
        })
    nameNode:setLocalZOrder(5)
    self.mNameNode = nameNode

    -- 幻化来源名字
    local illusionNameLabel = ui.newLabel({
        text = "",
        color = cc.c3b(0xff, 0xfb, 0xde),
        outlineColor = cc.c3b(0x37, 0x30, 0x2c),
        size = 24,
    })
    illusionNameLabel:setAnchorPoint(cc.p(0, 0.5))
    illusionNameLabel:setPosition(10, -435)
    nameNode:addChild(illusionNameLabel)

    -- 名字刷新接口
    nameNode.illusionNameLabel = illusionNameLabel
    nameNode.nameLabel = nameLabel
    nameNode.refreshName = function (target, newHeroData)
        target.nameLabel:setString("")
        target.illusionNameLabel:setVisible(false)
        if (newHeroData == nil) then
            return
        end

        -- 构造名字
        local newHeroBase = HeroModel.items[newHeroData.ModelId]
        local strName, tempStep = ConfigFunc:getHeroName(newHeroData.ModelId, {heroStep = newHeroData.Step, IllusionModelId = newHeroData.IllusionModelId, heroFashionId = newHeroData.CombatFashionOrder})
        local text = TR("等级") .. newHeroData.Lv .. "  " .. Utility.getQualityColor(newHeroBase.quality, 2) .. strName
        if (tempStep > 0) then
            text = text .. " " .. Enums.Color.eYellowH .. "+" .. tempStep
        end
        target.nameLabel:setString(text)

        -- 幻化名字
        if (newHeroData.IllusionModelId ~= nil) and (newHeroData.IllusionModelId > 0) then
            local heroBase = HeroModel.items[newHeroData.ModelId]
            target.illusionNameLabel:setString(TR("幻化于%s%s", Utility.getQualityColor(heroBase.quality, 2), heroBase.name))
            target.illusionNameLabel:setVisible(true)
        end
    end
    
    -- 显示人物列表
    self:createSlider()

    -- 显示标签页
    self:refreshTabs()

    -- 内力入口按钮
    local neiliBtn = ui.newButton({
        normalImage = "nl_24.png",
        anchorPoint = cc.p(0.5, 0.5),
        position = cc.p(590, 650),
        clickAction = function()
            if not ModuleInfoObj:moduleIsOpen(ModuleSub.eNeili, true) then
                return
            end

            LayerManager.addLayer({
                    name = "hero.HeroNeiliHomeLayer",
                    data = {
                        heroId = self.mCurrHeroId,
                    }
                })
        end
    })
    self.mParentLayer:addChild(neiliBtn, 5)
end

-- 创建Slider列表
function HeroTrainingLayer:createSlider()
    local function refreshArrow(index)
        self.mLeftArrow:setVisible(index ~= 1)
        self.mRightArrow:setVisible(index ~= #self.showHeroList)
    end
    local defaultSelectIndex = self:getIndexByHero(self.mCurrHeroId) - 1
    refreshArrow(defaultSelectIndex + 1)

    -- 创建人物列表
    local slider = ui.newSliderTableView({
        width = 640,
        height = 1136,
        isVertical = false,
        selItemOnMiddle = true,
        selectIndex = defaultSelectIndex,
        itemCountOfSlider = function(sliderView)
            return #self.showHeroList
        end,
        itemSizeOfSlider = function(sliderView)
            return 640, 1136
        end,
        sliderItemAtIndex = function(sliderView, itemNode, index)
            local isRebornLayer = (self.mOriginalTag == ModuleSub.eReborn)
            local oldData = self.showHeroList[index + 1]
            local newData = HeroObj:getHero(oldData.Id)
            local heroFigure = Figure.newHero({
                parent = itemNode,
                heroModelID = newData.ModelId,
                fashionModelID = PlayerAttrObj:getPlayerAttrByName("FashionModelId"),
                IllusionModelId = newData.IllusionModelId,
                heroFashionId = newData.CombatFashionOrder,
                position = cc.p(320, 620 + (isRebornLayer and 50 or 0)),
                scale = isRebornLayer and 0.28 or self.mPreScale or 0.3,
                needRace = not isRebornLayer,
                rebornId = newData.RebornId,
            })
            if not isRebornLayer then
                heroFigure.raceSprite:setPosition(-510, 1150)
            end
            itemNode.figure = heroFigure

            -- 当前是否是经脉页面
            if isRebornLayer then
                if tolua.isnull(heroFigure.effect) and newData.RebornId then
                    heroFigure.effect = ui.newEffect({
                        parent = heroFigure,
                        effectName = "effect_ui_jingmaibeijing",
                        position = cc.p(0, 0),
                        loop = true,
                        endRelease = true,
                        scale = 3.5
                    })
                end
                heroFigure:setColor(cc.c3b(30, 30, 30))
            end
        end,
        selectItemChanged = function(sliderView, selectIndex)
            local index = (selectIndex + 1)
            refreshArrow(index)
            
            -- 读取数据
            local newHeroId = self.showHeroList[index].Id
            local isNeedRefreshTab = (HeroModel.items[HeroObj:getHero(newHeroId).ModelId].specialType ~= HeroModel.items[HeroObj:getHero(self.mCurrHeroId).ModelId].specialType)
            self.mCurrHeroId = newHeroId
            if isNeedRefreshTab then
                self:refreshTabs()
            end

            -- 刷新子页面
            self:refreshSubLayer(self.mOriginalTag)

            -- 通知选中卡槽改变
            Notification:postNotification(SelectSlotChange)
        end
    })
    slider:setPosition(320, 568)
    self.mParentLayer:addChild(slider)
    self.mSliderView = slider
end

-- 刷新Tab列表
function HeroTrainingLayer:refreshTabs()
    -- 删除以前的Tab
    if (self.mTabView ~= nil) then
        self.mTabView:removeFromParent()
        self.mTabView = nil
    end

    -- 重新创建标签
    local tmpTabConfig = self:getTabsByHero(self.mCurrHeroId)
    local tabLayer = ui.newTabLayer({
        btnInfos = tmpTabConfig,
        btnSize = cc.size(122, 56), 
        defaultSelectTag = self.mOriginalTag,
        needLine = false,
        onSelectChange = function(tag)
            -- 切换背景图
            self.mRebornBgSprite:setVisible(tag == ModuleSub.eReborn)

            -- 刷新人物列表
            local newHeroList = self:getDataByModule(tag)
            local isNeedRefreshSlider = (self.mOriginalTag == ModuleSub.eReborn) or (tag == ModuleSub.eReborn)
            self.mOriginalTag = tag     -- 不保存的话，后面的reloadData刷新有问题

            if (#self.showHeroList ~= #newHeroList) then
                isNeedRefreshSlider = true
            else
                local function isFind(heroId)
                    for _,v in ipairs(self.showHeroList) do
                        if (v.Id == heroId) then
                            return true
                        end
                    end
                    return false
                end
                for _,v in ipairs(newHeroList) do
                    if (isFind(v.Id) == false) then
                        isNeedRefreshSlider = true
                        break
                    end
                end
            end
            if isNeedRefreshSlider then
                self.showHeroList = newHeroList
                self.mSliderView:reloadData()
                self.mSliderView:setSelectItemIndex(self:getIndexByHero(self.mCurrHeroId) - 1, false)
            end

            -- 刷新子页面
            self:refreshSubLayer(tag)
        end,
    })
    tabLayer:setAnchorPoint(cc.p(0, 0))
    tabLayer:setPosition(cc.p(0, 514))
    self.mParentLayer:addChild(tabLayer, 1)
    self.mTabView = tabLayer
end

----------------------------------------------------------------------------------------------------

-- 读取模块对应的人物数据
function HeroTrainingLayer:getDataByModule(moduleId)
    local tmpOpenConfig = 0
    for _,v in pairs(TabsConfig) do
        if (v.moduleId == moduleId) then
            tmpOpenConfig = v.openConfig
            break
        end
    end
    if (tmpOpenConfig == 0) then
        return {}
    end

    -- 读取人物数据
    local retList = {}
    for _,v in ipairs(self.rawHeroList) do
        local baseInfo = HeroModel.items[v.ModelId] or {}
        local isAdd = true
        if (tmpOpenConfig == trainOpenConfig.eOnlyMainHero) then
            -- 仅主角开放
            if (baseInfo.specialType ~= Enums.HeroType.eMainHero) then
                isAdd = false
            end
        elseif (tmpOpenConfig == trainOpenConfig.eOnlyNormalHero) then
            -- 仅其他侠客开放
            if (baseInfo.specialType == Enums.HeroType.eMainHero) then
                isAdd = false
            end
        end
        if (isAdd == true) then
            table.insert(retList, clone(v))
        end
    end

    return retList
end

-- 根据人物获取对应的Tab列表
function HeroTrainingLayer:getTabsByHero(heroId)
    local baseHero = HeroModel.items[HeroObj:getHero(heroId).ModelId] or {}

    local retList = {}
    for _,v in ipairs(TabsConfig) do
        local isAdd = true
        if (v.openConfig == trainOpenConfig.eOnlyMainHero) then
            -- 仅主角开放
            if (baseHero.specialType ~= Enums.HeroType.eMainHero) then
                isAdd = false
            end
        elseif (v.openConfig == trainOpenConfig.eOnlyNormalHero) then
            -- 仅其他侠客开放
            if (baseHero.specialType == Enums.HeroType.eMainHero) then
                isAdd = false
            end
        end
        if (isAdd == true) and (ModuleInfoObj:moduleIsOpen(v.moduleId, false) == true) then
            table.insert(retList, {text = v.name, tag = v.moduleId})
        end
    end

    return retList
end

-- 根据人物获取对应的列表索引
function HeroTrainingLayer:getIndexByHero(heroId)
    local retIdx = 0
    for i,v in ipairs(self.showHeroList) do
        if (v.Id == heroId) then
            retIdx = i
            break
        end
    end
    return retIdx
end

-- 获取当前人物所在的卡槽ID
function HeroTrainingLayer:getCurrSlotId()
    local retSlotId = 0
    for i=1,6 do
        local slotInfo = FormationObj:getSlotInfoBySlotId(i)
        if (slotInfo ~= nil) and (slotInfo.HeroId ~= nil) and (slotInfo.HeroId == self.mCurrHeroId) then
            retSlotId = i
            break
        end
    end
    
    return retSlotId
end

-- 刷新当前对应的页面
function HeroTrainingLayer:refreshSubLayer(tag)
    -- 添加背景
    if (self.subLayerNode == nil) then
        local tmpLayer = cc.LayerColor:create(cc.c4b(255, 0, 0, 0))
        tmpLayer:setContentSize(cc.size(640, 1136))
        tmpLayer:setIgnoreAnchorPointForPosition(false)
        tmpLayer:setAnchorPoint(cc.p(0.5, 0))
        tmpLayer:setPosition(cc.p(320, 0))
        self.mParentLayer:addChild(tmpLayer, 2)
        self.subLayerNode = tmpLayer
    end
    self.subLayerNode:removeAllChildren()

    -- 显示/隐藏名字
    self.mNameNode:setVisible(tag ~= ModuleSub.eReborn)

    -- 加载页面
    local strFilename = nil
    for _,v in ipairs(TabsConfig) do
        if (v.moduleId == tag) then
            strFilename = v.filename
            break
        end
    end
    local page = require(strFilename).new({
        parent = self,
        heroId = self.mCurrHeroId,
        selectTalentIdx = self.selectTalentIdx,
    })
    self.subLayerNode:addChild(page)
end

----------------------------------------------------------------------------------------------------

-- 返回当前对应的人物
function HeroTrainingLayer:getCurrHeroFigure()
    return self.mSliderView:getItemNode(self:getIndexByHero(self.mCurrHeroId) - 1)
end

-- 刷新当前对应的人物
function HeroTrainingLayer:refreshCurrHeroFigure()
    return self.mSliderView:refreshItem(self:getIndexByHero(self.mCurrHeroId) - 1)
end

-- 数据恢复
function HeroTrainingLayer:getRestoreData()
    local retData = {
        heroesData = self.rawHeroList,
        originalTag = self.mOriginalTag,
        originalId = self.mCurrHeroId,
        selectTalentIdx = self.selectTalentIdx,
    }
    return retData
end

return HeroTrainingLayer

