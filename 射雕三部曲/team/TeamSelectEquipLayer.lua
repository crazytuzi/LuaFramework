--[[
    文件名: TeamSelectEquipLayer.lua
	描述: 队伍选择装备和神兵页面
	创建人: peiyaoqiang
    创建时间: 2017.03.08
--]]

local TeamSelectEquipLayer = class("TeamSelectEquipLayer", function(params)
    return display.newLayer()
end)

--[[
-- 参数 params中的每项为：
    {
        slotId: 需要上阵的卡槽Id，必选参数
        resourcetypeSub: 装备的类型
        alwaysIdList: 始终包含的条目Id列表
    }
--]]
function TeamSelectEquipLayer:ctor(params)
    -- 需要上阵的卡槽Id
    self.mSlotId = params.slotId
    -- 是否是小伙伴卡槽Id
    self.mResourcetypeSub = params.resourcetypeSub
    -- 始终包含的条目Id列表
    self.mAlwaysIdList = params.alwaysIdList
    -- 卡槽上原来的装备
    self.mOldEquip = FormationObj:getSlotEquip(self.mSlotId, self.mResourcetypeSub)

    -- 是否隐藏已上阵装备
    self.mHideInFormation = false
    self.mEquipInfos = {}

	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

	-- 初始化页面控件
	self:initUI()

	-- 创建底部导航和顶部玩家信息部分
	local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        currentLayerType = Enums.MainNav.eFormation,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(tempLayer)
end

-- 初始化页面控件
function TeamSelectEquipLayer:initUI()
    -- 背景图片
	local bgSprite = ui.newSprite("c_34.jpg")
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)

    local tempSprite = ui.newScale9Sprite("c_17.png", cc.size(630, 900))
    tempSprite:setAnchorPoint(cc.p(0.5, 1))
    tempSprite:setPosition(320, 1010)
    self.mParentLayer:addChild(tempSprite)

    -- 创建选择列表
    self:createListView()

    -- 关闭按钮
    self.mCloseBtn = ui.newButton({
        normalImage = "c_29.png",
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self.mCloseBtn:setPosition(Enums.StardardRootPos.eCloseBtn)
    self.mParentLayer:addChild(self.mCloseBtn)
end

-- 创建选择列表
function TeamSelectEquipLayer:createListView()
    -- 空列表提示
    if Utility.isTreasure(self.mResourcetypeSub) then
        self:refreshTreasureData()
    else
        self:refreshEquipData()
    end
    local emptyHintText = Utility.isTreasure(self.mResourcetypeSub) and TR("没有可以选择的神兵") or TR("没有可以选择的装备")
    local mEmptyHintSprite = ui.createEmptyHint(emptyHintText)
    mEmptyHintSprite:setPosition(320, 568)
    self.mParentLayer:addChild(mEmptyHintSprite)
    self.mEmptyHintSprite = mEmptyHintSprite

    local grabBtn = ui.newButton({
        text = Utility.isTreasure(self.mResourcetypeSub) and TR("去锻造") or TR("去获取"),
        normalImage = "c_28.png",
        clickAction = function()
            if Utility.isTreasure(self.mResourcetypeSub) then
                LayerManager.showSubModule(ModuleSub.eChallengeGrab)
            else
                LayerManager.showSubModule(ModuleSub.ePracticeBloodyDemonDomain)
            end
        end
        })
    grabBtn:setPosition(320, 420)
    self.mParentLayer:addChild(grabBtn, 100)
    self.guideForgeBtn = grabBtn    -- 保存新手引导使用


    --
    self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setContentSize(cc.size(640, 890))
    self.mListView:setPosition(cc.p(0, 115))
    self.mParentLayer:addChild(self.mListView)
    --
    self:refreshList()

    -- 显示隐藏开关的背景
    local bgCheckBox = ui.newSprite("c_41.png")
    bgCheckBox:setAnchorPoint(cc.p(0, 0.5))
    bgCheckBox:setPosition(cc.p(0, 1045))
    self.mParentLayer:addChild(bgCheckBox)

    -- 是否显示上阵人物开关按钮
    local checkBox = ui.newCheckbox({
        normalImage = "c_60.png",
        selectImage = "c_61.png",
        isRevert = false,
        text = Utility.isTreasure(self.mResourcetypeSub) and TR("隐藏已上阵神兵") or TR("隐藏已上阵装备"),
        textColor = Enums.Color.eNormalWhite,
        outlineColor = Enums.Color.eBlack,
        outlineSize = 2,
        callback = function(isSelected)
            self.mHideInFormation = isSelected
            self:refreshList()
        end
    })
    checkBox:setCheckState(self.mHideInFormation)
    checkBox:setAnchorPoint(cc.p(0, 0.5))
    checkBox:setPosition(cc.p(20, 1045))
    self.mParentLayer:addChild(checkBox)
end

-- 刷新装备数据
function TeamSelectEquipLayer:refreshEquipData()
    -- 如果当前类型不是装备类型，则直接返回
    if not Utility.isEquip(self.mResourcetypeSub) then
        return
    end

    self.mEquipInfos = clone(EquipObj:getEquipList({
        resourcetypeSub = self.mResourcetypeSub,
        notInFormation = self.mHideInFormation, -- 是否需要过滤掉上阵的装备，默认为false
        alwaysIdList = self.mAlwaysIdList, -- 始终包含的条目Id列表
    }))

    -- 整理装备的其他信息
    local statusMap = {}
    for _, equipInfo in ipairs(self.mEquipInfos) do
        local tempModelId = equipInfo.ModelId
        -- 装备模型信息
        if not equipInfo.modelData then
            equipInfo.modelData = EquipModel.items[tempModelId]
        end

        -- 可激活的状态, 已获取过的就不在计算了
        equipInfo.relationStatus = statusMap[tempModelId]
        if not equipInfo.relationStatus then
            equipInfo.relationStatus = FormationObj:getRelationStatus(tempModelId, equipInfo.modelData.typeID, self.mSlotId)
            statusMap[tempModelId] = equipInfo.relationStatus
        end

        -- 装备上阵状态
        if not equipInfo.equipStatus then
            local inFormation, slotId = FormationObj:equipInFormation(equipInfo.Id)
            equipInfo.equipStatus = {
                inFormation = inFormation,
                slotId = slotId
            }
        end
    end

    -- 排序
    local oldEquipId = self.mOldEquip and self.mOldEquip.Id
    if (oldEquipId == nil) then
        oldEquipId = ""
    end
    table.sort(self.mEquipInfos, function(item1, item2)
        if (item1.Id == oldEquipId) then
            return true
        elseif (item2.Id == oldEquipId) then
            return false
        end

        -- 比较资质
        if item1.modelData.quality ~= item2.modelData.quality then
            return item1.modelData.quality > item2.modelData.quality
        end
        -- 比较激活状态
        if item1.relationStatus ~= item2.relationStatus then
            return item1.relationStatus > item2.relationStatus
        end
        -- 比较主将状态
        if item1.equipStatus.inFormation ~= item2.equipStatus.inFormation then
            if item1.equipStatus.inFormation then
                return true
            else
                return false
            end
        end
        -- 比较等级
        if item1.Lv ~= item2.Lv then
            return item1.Lv > item2.Lv
        end
        -- 比较进阶
        if item1.Step ~= item2.Step then
            return item1.Step > item2.Step
        end

        return false
    end)
end

-- 刷新神兵数据
function TeamSelectEquipLayer:refreshTreasureData()
    -- 如果当前类型不是神兵类型，则直接返回
    if not Utility.isTreasure(self.mResourcetypeSub) then
        return
    end

    self.mEquipInfos = clone(TreasureObj:getTreasureList({
        resourcetypeSub = self.mResourcetypeSub,
        notInFormation = self.mHideInFormation, -- 是否需要过滤掉上阵的装备，默认为false
        notExpTreasure = true,
        alwaysIdList = self.mAlwaysIdList, -- 始终包含的条目Id列表
    }))

    -- 整理装备的其他信息
    local statusMap = {}
    for _, treasureInfo in ipairs(self.mEquipInfos) do
        local tempModelId = treasureInfo.ModelId
        -- 人物模型信息
        if not treasureInfo.modelData then
            treasureInfo.modelData = TreasureModel.items[tempModelId]
        end

        -- 可激活的状态, 已获取过的就不在计算了
        treasureInfo.relationStatus = statusMap[tempModelId]
        if not treasureInfo.relationStatus then
            treasureInfo.relationStatus = FormationObj:getRelationStatus(tempModelId, treasureInfo.modelData.typeID, self.mSlotId)
            statusMap[tempModelId] = treasureInfo.relationStatus
        end

        -- 人物上阵状态
        if not treasureInfo.equipStatus then
            local inFormation, slotId = FormationObj:equipInFormation(treasureInfo.Id)
            treasureInfo.equipStatus = {
                inFormation = inFormation,
                slotId = slotId
            }
        end
    end

    -- 排序
    local oldEquipId = self.mOldEquip and self.mOldEquip.Id
    if (oldEquipId == nil) then
        oldEquipId = ""
    end
    table.sort(self.mEquipInfos, function(item1, item2)
        if (item1.Id == oldEquipId) then
            return true
        elseif (item2.Id == oldEquipId) then
            return false
        end

        -- 比较资质
        if item1.modelData.quality ~= item2.modelData.quality then
            return item1.modelData.quality > item2.modelData.quality
        end
        -- 比较激活状态
        if item1.relationStatus ~= item2.relationStatus then
            return item1.relationStatus > item2.relationStatus
        end
        -- 比较上阵状态
        if item1.equipStatus.inFormation ~= item2.equipStatus.inFormation then
            if item1.equipStatus.inFormation then
                return true
            else
                return false
            end
        end
        -- 比较等级
        if item1.Lv ~= item2.Lv then
            return item1.Lv > item2.Lv
        end
        -- 比较进阶
        if item1.Step ~= item2.Step then
            return item1.Step > item2.Step
        end

        return false
    end)
end

-- 重新刷新列表数据显示
function TeamSelectEquipLayer:refreshList()
    self.mListView:removeAllItems()

    if Utility.isTreasure(self.mResourcetypeSub) then
        self:refreshTreasureData()
    else
        self:refreshEquipData()
    end

    local cellSize = cc.size(640, 128)
    for index, equipInfo in ipairs(self.mEquipInfos) do
        local lvItem = ccui.Layout:create()

        lvItem:setContentSize(cellSize)
        self.mListView:pushBackCustomItem(lvItem)

        --
        local tempSprite = ui.newScale9Sprite("c_18.png", cc.size(600, 120))
        tempSprite:setPosition(cellSize.width / 2, cellSize.height / 2)
        lvItem:addChild(tempSprite)
        -- 创建装备头像
        local tempCard = CardNode.createCardNode({
            cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eStep},
            instanceData = equipInfo,
            allowClick = true, --是否可点击
        })

        tempCard:setPosition(100, cellSize.height / 2)
        lvItem:addChild(tempCard)

        -- 装备的名字
        local tempLabel = ui.newLabel({
            text = equipInfo.modelData.name,
            color = Utility.getQualityColor(equipInfo.modelData.quality, 1),
            size = 22,
            outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
            outlineSize = 2,
            align = cc.TEXT_ALIGNMENT_LEFT,
            valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
        })
        tempLabel:setAnchorPoint(cc.p(0, 0.5))
        tempLabel:setPosition(165, cellSize.height / 2 + 25)
        lvItem:addChild(tempLabel)

        -- 装备的资质
        local tempLabel = ui.newLabel({
            text = TR("资质: %s%d", "#D77600", equipInfo.modelData.quality),
            color = cc.c3b(0x41, 0x1c, 0x00),
            align = cc.TEXT_ALIGNMENT_LEFT,
            valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
        })
        tempLabel:setAnchorPoint(cc.p(0, 0.5))
        tempLabel:setPosition(165, cellSize.height / 2 - 25)
        lvItem:addChild(tempLabel)

        -- 装备的等级
        local tempLabel = ui.newLabel({
            text = TR("等级: %s%d",  "#D77600", equipInfo.Lv),
            color = cc.c3b(0x41, 0x1c, 0x00),
            align = cc.TEXT_ALIGNMENT_LEFT,
            valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
        })
        tempLabel:setAnchorPoint(cc.p(0, 0.5))
        tempLabel:setPosition(300, cellSize.height / 2 - 25)
        lvItem:addChild(tempLabel)

        local inFormation = equipInfo.equipStatus.inFormation
        if inFormation then
            local slotInfo = FormationObj:getSlotInfoBySlotId(equipInfo.equipStatus.slotId)
            local tempHero = HeroObj:getHero(slotInfo.HeroId)
            local tempName = ConfigFunc:getHeroName(slotInfo.ModelId, {IllusionModelId = tempHero.IllusionModelId, heroFashionId = tempHero.CombatFashionOrder})
            local tempLabel = ui.newLabel({
                text = TR("[装备于%s%s%s]", Enums.Color.eNormalGreenH, tempName, Enums.Color.eBrownH),
                color = Enums.Color.eBrown,
                align = cc.TEXT_ALIGNMENT_CENTER,
                valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
            })
            tempLabel:setAnchorPoint(cc.p(0.5, 0.5))
            tempLabel:setPosition(510, cellSize.height / 2 + 30)
            lvItem:addChild(tempLabel)
        end

        -- 判断是否可以激活
        if equipInfo.relationStatus == Enums.RelationStatus.eTriggerPr then
            local tempSprite = ui.createStrImgMark("c_62.png", TR("可激活"), Enums.Color.eWhite)
            local tempSize = tempSprite:getContentSize()
            tempSprite:setPosition(620 - tempSize.width / 2 - 1, 124 - tempSize.height / 2 - 1)
            tempSprite:setRotation(90)
            lvItem:addChild(tempSprite, 1)
        end

        -- 选择按钮
        local oldEquipId = self.mOldEquip and self.mOldEquip.Id
        local tempBtn = ui.newButton({
            text = (oldEquipId == equipInfo.Id) and TR("卸下") or TR("选择"),
            normalImage = (oldEquipId == equipInfo.Id) and "c_33.png" or "c_28.png",
            clickAction = function()
                self:requestOneKeyEquipCombat(equipInfo)
            end
        })
        tempBtn:setPosition(510, inFormation and (cellSize.height / 2 - 15) or (cellSize.height / 2))
        lvItem:addChild(tempBtn)

        if not self.mSelectBtn_ then
            self.mSelectBtn_ = tempBtn
        end
    end

    self.mEmptyHintSprite:setVisible(next(self.mEquipInfos) == nil)
    self.guideForgeBtn:setVisible(next(self.mEquipInfos) == nil)
end

-- 整理请求服务器接口需要的参数
function TeamSelectEquipLayer:getEquipCombatParam(newEquip)
    -- 空字符串的卡槽表示不变；EMPTY_ENTITY_ID的卡槽表示卸下；有有效Id的卡槽标上上阵
    local oldEquipId = self.mOldEquip and self.mOldEquip.Id
    local commbatId = oldEquipId == newEquip.Id and EMPTY_ENTITY_ID or newEquip.Id
    -- 装备和神兵资源类型
    local resTypeList = {
        ResourcetypeSub.eWeapon,  -- "武器"
        ResourcetypeSub.eHelmet,  -- "头部"
        ResourcetypeSub.eClothes, -- "衣服"
        ResourcetypeSub.eNecklace,-- "项链"
        ResourcetypeSub.ePants,   -- "裤子"
        ResourcetypeSub.eShoe,    -- "鞋子"
        ResourcetypeSub.eBook,    -- "兵书"
        ResourcetypeSub.eHorse,   -- "徽章"
    }
    local ret = {self.mSlotId}
    for _, resType in ipairs(resTypeList) do
        if resType == self.mResourcetypeSub then
            table.insert(ret, commbatId)
        else
            table.insert(ret, "")
        end
    end
    return ret
end

-- ======================== 服务器数据请求相关函数 =======================
-- 更换装备数据请求
function TeamSelectEquipLayer:requestOneKeyEquipCombat(newEquip)
    HttpClient:request({
        svrType       = HttpSvrType.eGame,
        moduleName    = "Slot",
        methodName    = "OneKeyEquipCombat",
        guideInfo = Guide.helper:tryGetGuideSaveInfo(11210),
        svrMethodData = self:getEquipCombatParam(newEquip),
        callbackNode  = self,
        callback      = function(response)
            if not response or response.Status ~= 0 then --
                return
            end
            --[[--------新手引导--------]]--
            local _, _, eventID = Guide.manager:getGuideInfo()
            if eventID == 11210 then
                Guide.manager:nextStep(eventID)
                Guide.manager:removeGuideLayer()
            end

            LayerManager.removeLayer(self)
        end,
    })
end

-- ========================== 新手引导 ===========================
function TeamSelectEquipLayer:onEnterTransitionFinish()
    self:executeGuide()
end

function TeamSelectEquipLayer:executeGuide()
    local _, _, eventID = Guide.manager:getGuideInfo()
    if eventID == 11210 then
        self.mListView:setTouchEnabled(false)
        Guide.manager:showGuideLayer({})
        -- 神兵选择上阵时，有动画
        Utility.performWithDelay(self.mSelectBtn_, function()
            Guide.helper:executeGuide({
                [11210] = {clickNode = self.mSelectBtn_},
            })
        end, 0.5)
    end
end

return TeamSelectEquipLayer
