--[[
    文件名: TeamSelectHeroLayer.lua
	描述: 队伍选择人物页面
	创建人: peiyaoqiang
    创建时间: 2017.03.08
--]]

local TeamSelectHeroLayer = class("TeamSelectHeroLayer", function(params)
    return display.newLayer()
end)

--[[
-- 参数 params中的每项为：
    {
        slotId: 需要上阵的卡槽Id，必选参数
        isMateSlot: 是否是小伙伴卡槽Id，默认为false
        alwaysIdList: 始终包含的条目Id列表
        excludeModelIds = {}, -- 需要排除的模型Id
    }
--]]
function TeamSelectHeroLayer:ctor(params)
    -- 需要上阵的卡槽Id
    self.mSlotId = params.slotId
    -- 始终包含的条目Id列表
    self.mAlwaysIdList = params.alwaysIdList
    -- 是否是小伙伴卡槽Id
    self.mIsMateSlot = params.isMateSlot
    -- 需要排除的模型Id
    --self.mExcludeModelIds = FormationObj:getExcludeHeroModelIds(self.mSlotId, self.mIsMateSlot)
    self.mExcludeModelIds = params.excludeModelIds
    -- 当前上阵的人物ID
    -- self.oldHeroId = nil
    -- if self.mIsMateSlot then
    --     local mateInfo = FormationObj:getMateSlotInfo(self.mSlotId) or {}
    --     self.oldHeroId = mateInfo.HeroId
    -- else
    --     local slotInfo = FormationObj:getSlotInfoBySlotId(self.mSlotId) or {}
    --     self.oldHeroId = slotInfo.HeroId
    -- end
    -- if (self.oldHeroId == nil) then
    --     self.oldHeroId = ""
    -- end

    -- 是否隐藏已上阵人物
    self.mHideInFormation = true
    self.mHeroInfos = {}

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
function TeamSelectHeroLayer:initUI()
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
function TeamSelectHeroLayer:createListView()
    -- 空列表提示
    self.mEmptyHintSprite = ui.createEmptyHint(TR("没有可以选择的侠客，先去招募吧！"))
    self.mEmptyHintSprite:setPosition(320, 568)
    self.mParentLayer:addChild(self.mEmptyHintSprite)
    --
    self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setContentSize(cc.size(640, 890))
    self.mListView:setPosition(cc.p(0, 115))
    self.mParentLayer:addChild(self.mListView)
    -- 去获取按钮
    local getBtn = ui.newButton({
           normalImage = "c_28.png",
           text = TR("去获取"),
           clickAction = function ()
               LayerManager.addLayer({
                       name = "shop.ShopLayer"
                   })
           end
       })
    getBtn:setPosition(320, 300)
    self.mParentLayer:addChild(getBtn)
    self.getBtn = getBtn
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
        text = TR("隐藏已上阵侠客"),
        textColor = Enums.Color.eNormalWhite,
        outlineColor = Enums.Color.eBlack,
        outlineSize = 2,
        callback = function(isSelected)
            self.mHideInFormation = isSelected
            self:refreshList()
        end
    })
    checkBox:setCheckState(true)
    checkBox:setAnchorPoint(cc.p(0, 0.5))
    checkBox:setPosition(cc.p(20, 1045))
    self.mParentLayer:addChild(checkBox)
end

-- 重新刷新列表数据显示
function TeamSelectHeroLayer:refreshList()
    self.mListView:removeAllItems()

    self.mHeroInfos = clone(HeroObj:getHeroList({
        notInFormation = self.mHideInFormation, -- 是否需要过滤掉上阵的人物，默认为false
        alwaysIdList = self.mAlwaysIdList, -- 始终包含的条目Id列表
        excludeModelIds = self.mExcludeModelIds, --  需要排除的模型Id
    }))

    -- 整理人物的其他信息
    local statusMap = {}
    for _, heroInfo in ipairs(self.mHeroInfos) do
        -- 人物模型信息
        if not heroInfo.modelData then
            heroInfo.modelData = HeroModel.items[heroInfo.ModelId]
        end

        -- 可激活的状态, 已获取过的就不在计算了
        heroInfo.relationStatus = statusMap[heroInfo.ModelId]
        if not heroInfo.relationStatus then
            heroInfo.relationStatus = FormationObj:getRelationStatus(heroInfo.ModelId, ResourcetypeSub.eHero, self.mSlotId, self.mIsMateSlot)
            statusMap[heroInfo.ModelId] = heroInfo.relationStatus
        end

        -- 人物上阵状态
        if not heroInfo.heroStatus then
            local inFormation, isMate, slotId = FormationObj:heroInFormation(heroInfo.Id)
            heroInfo.heroStatus = {
                inFormation = inFormation,
                isMate = isMate,
                slotId = slotId
            }
        end
    end

    -- 排序
    table.sort(self.mHeroInfos, function(item1, item2)
        -- 当前人物排在最前
        -- if (item1.Id == self.oldHeroId) then
        --     return true
        -- elseif (item2.Id == self.oldHeroId) then
        --     return false
        -- end
        -- 比较上阵状态
        if item1.heroStatus.inFormation ~= item2.heroStatus.inFormation then
            if item1.heroStatus.inFormation then
                return true
            else
                return false
            end
        end

        -- 判断激活状态
        if item1.relationStatus ~= item2.relationStatus then
            -- 相同侠客排到最后
            if item1.relationStatus == Enums.RelationStatus.eSame then
                return false
            elseif item2.relationStatus == Enums.RelationStatus.eSame then
                return true
            end

            -- 有缘分或可激活的最前
            return item1.relationStatus > item2.relationStatus
        end

        -- 比较资质
        if item1.modelData.quality ~= item2.modelData.quality then
            return item1.modelData.quality > item2.modelData.quality
        end

        -- 比较等级
        if item1.Lv ~= item2.Lv then
            return item1.Lv > item2.Lv
        end
        -- 比较进阶
        if item1.Step ~= item2.Step then
            return item1.Step > item2.Step
        end

        return item1.ModelId < item2.ModelId
    end)

    local cellSize = cc.size(640, 128)
    for index, heroInfo in ipairs(self.mHeroInfos) do
        local lvItem = ccui.Layout:create()
        lvItem:setContentSize(cellSize)
        self.mListView:pushBackCustomItem(lvItem)
        -- 子条目背景
        local tempSprite = ui.newScale9Sprite("c_18.png", cc.size(600, 120))
        tempSprite:setPosition(cellSize.width / 2, cellSize.height / 2)
        lvItem:addChild(tempSprite)

        -- 人物的模型
        local tempModel = HeroModel.items[heroInfo.ModelId]
        -- 创建人物头像
        local tempCard = CardNode.createCardNode({
            cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eStep},
            instanceData = heroInfo,
            allowClick = true, --是否可点击
        })
        tempCard:setPosition(100, cellSize.height / 2)
        lvItem:addChild(tempCard)

        -- 人物的名字
        local tempName = tempModel.name
        if (heroInfo.IllusionModelId ~= nil) and (heroInfo.IllusionModelId > 0) then
            tempName = TR("%s%s（幻化于%s%s%s）", IllusionModel.items[heroInfo.IllusionModelId].name, Enums.Color.eNormalWhiteH, Utility.getQualityColor(tempModel.quality, 2), tempModel.name, Enums.Color.eNormalWhiteH)
        end
        local tempLabel = ui.newLabel({
            text = tempName,
            color = Utility.getQualityColor(tempModel.quality, 1),
            outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
            size = 24,
            align = cc.TEXT_ALIGNMENT_LEFT,
            valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
        })
        tempLabel:setAnchorPoint(cc.p(0, 0.5))
        tempLabel:setPosition(165, cellSize.height / 2 + 25)
        lvItem:addChild(tempLabel)

        -- 人物的资质
        local tempLabel = ui.newLabel({
            text = TR("资质: %s%d", "#D77600", tempModel.quality),
            color = cc.c3b(0x41, 0x1c, 0x00),
            align = cc.TEXT_ALIGNMENT_LEFT,
            valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
        })
        tempLabel:setAnchorPoint(cc.p(0, 0.5))
        tempLabel:setPosition(165, cellSize.height / 2 - 25)
        lvItem:addChild(tempLabel)

        -- 人物的等级
        local tempLabel = ui.newLabel({
            text = TR("等级: %s%d", "#D77600", heroInfo.Lv),
            color = cc.c3b(0x41, 0x1c, 0x00),
            align = cc.TEXT_ALIGNMENT_LEFT,
            valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
        })
        tempLabel:setAnchorPoint(cc.p(0, 0.5))
        tempLabel:setPosition(325, cellSize.height / 2 - 25)
        lvItem:addChild(tempLabel)

        -- 状态信息
        local statusStr, statusImg = "", "c_62.png"
        if heroInfo.heroStatus.inFormation then  -- 已上阵
            statusStr = TR("已上阵")
        else
            if heroInfo.relationStatus == Enums.RelationStatus.eSame then  -- 表示和阵容里某个人物相同
                statusStr = TR("相同侠客")
            elseif heroInfo.relationStatus == Enums.RelationStatus.eTriggerPr then -- 表示可以激活
                statusStr = TR("可激活")
                statusImg = "c_58.png"
            elseif heroInfo.relationStatus == Enums.RelationStatus.eIsMember then -- 表示有搭配，但没有激活
                statusStr = TR("有缘份")
            end
        end
        if statusStr ~= "" then
            local tempSprite = ui.createStrImgMark(statusImg, statusStr, Enums.Color.eNormalWhite)
            local tempSize = tempSprite:getContentSize()
            tempSprite:setPosition(620 - tempSize.width / 2 - 1, 124 - tempSize.height / 2 - 1)
            tempSprite:setRotation(90)
            lvItem:addChild(tempSprite, 1)
        end

        -- 选择按钮
        local tempBtn = ui.newButton({
            text = TR("选择"),
            normalImage = "c_28.png",
            clickAction = function()
                if heroInfo.heroStatus.inFormation then
                    ui.showFlashView(TR("该侠客已上阵"))
                    return
                end
                if heroInfo.relationStatus == Enums.RelationStatus.eSame then -- 阵容里有相同的人物
                    ui.showFlashView(TR("已有相同的侠客上阵"))
                    return
                end

                if self.mIsMateSlot then
                    self:requestMateinfoCombat(heroInfo)
                else
                    self:requestHeroCombat(heroInfo)
                end
            end
        })
        tempBtn:setPosition(530, cellSize.height / 2)
        lvItem:addChild(tempBtn)

        -- 已上阵的人物和相同人物不能上阵
        if heroInfo.heroStatus.inFormation or (heroInfo.relationStatus == Enums.RelationStatus.eSame) then
            tempBtn:setBright(false)
        end

        if not self.mSelectBtn_ then
            self.mSelectBtn_ = tempBtn
        end
    end

    self.mEmptyHintSprite:setVisible(next(self.mHeroInfos) == nil)
    self.getBtn:setVisible(next(self.mHeroInfos) == nil)
end

-- 上阵人物
function TeamSelectHeroLayer:requestHeroCombat(heroInfo)
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Slot",
        methodName = "HeroCombat",
        guideInfo = Guide.helper:tryGetGuideSaveInfo(10208),
        svrMethodData = {self.mSlotId, heroInfo.Id},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            --[[--------新手引导--------]]--
            local _, _, eventID = Guide.manager:getGuideInfo()
            if eventID == 10208 then
                Guide.manager:nextStep(eventID)
                Guide.manager:removeGuideLayer()
            end

            LayerManager.removeLayer(self)
        end,
    })
end

-- 上阵小伙伴
function TeamSelectHeroLayer:requestMateinfoCombat(heroInfo)
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Slot",
        methodName = "MateinfoCombat",
        svrMethodData = {self.mSlotId, heroInfo.Id},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then --
                return
            end
            -- 更新小伙伴卡槽信息
            FormationObj:updateMateInfos(response.Value.MateInfo)

            LayerManager.removeLayer(self)
        end,
    })
end

----[[---------------------新手引导---------------------]]--
function TeamSelectHeroLayer:onEnterTransitionFinish()
    self:executeGuide(0.5)
end

-- 执行新手引导
function TeamSelectHeroLayer:executeGuide(delay)
    local _, _, eventID = Guide.manager:getGuideInfo()
    if eventID == 10208 and self.mSelectBtn_  then
        self.mListView:setTouchEnabled(false)
        Guide.manager:showGuideLayer({})
        Utility.performWithDelay(self.mSelectBtn_, function()
            Guide.helper:executeGuide({
                [10208] = {clickNode = self.mSelectBtn_},
            })
        end, delay)
    end
end


return TeamSelectHeroLayer
