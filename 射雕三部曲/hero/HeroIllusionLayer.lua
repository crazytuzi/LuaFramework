--[[
    文件名：HeroIllusionLayer.lua
    描述：角色幻化界面
    创建人：yanghongsheng
    创建时间：2018.3.13
-- ]]

local HeroIllusionLayer = class("HeroIllusionLayer", function()
    return  display.newLayer()
end)


--[[
    params:
    {
        parent              父节点
        heroId              角色模型id
    }
--]]
function HeroIllusionLayer:ctor(params)
    -- 传入参数
    self.mParent = params.parent
    self.mHeroId = params.heroId

    -- 初始化界面
    self:initLayer()

    self:showInfo()
end


-- 初始化界面
function HeroIllusionLayer:initLayer()
    -- 父容器（Tab显示的可见区域）
    local layout = ccui.Layout:create()
    layout:setContentSize(640, 435)
    layout:setAnchorPoint(0.5, 0)
    layout:setPosition(320, 80)
    self:addChild(layout)
    self.mPanelLayout = layout

    -- 延时刷新
    Utility.performWithDelay(self.mPanelLayout, function () 
            self:refreshUI()
        end, 0.1)
end
-- 创建幻化页签ui
function HeroIllusionLayer:createBottomUI()
    local heroInfo = clone(HeroObj:getHero(self.mHeroId))
    -- 幻化表中数据
    local illusionData = IllusionModel.items[heroInfo.IllusionModelId]
    if not illusionData then return end
    -- 幻化卡片
    local illusionCard = CardNode.createCardNode({
            resourceTypeSub = ResourcetypeSub.eHero,
            instanceData = heroInfo,
            cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eName},
        })
    illusionCard:setPosition(320, 320)
    self.mPanelLayout:addChild(illusionCard)
    -- 简介
    local illusionIntro = ui.newLabel({
            text = illusionData.intro,
            color = cc.c3b(0x46, 0x22, 0x0d),
            size = 22,
            dimensions = cc.size(450, 0)
        })
    illusionIntro:setAnchorPoint(cc.p(0.5, 1))
    illusionIntro:setPosition(320, 220)
    self.mPanelLayout:addChild(illusionIntro)

    -- 切换幻化按钮
    local changeBtn = ui.newButton({
            normalImage = "c_28.png",
            text = TR("幻化更换"),
            clickAction = function ()
                self:changeIllusion()
            end,
        })
    changeBtn:setPosition(320, 80)
    self.mPanelLayout:addChild(changeBtn)

    -- 幻化重生按钮
    local rebirthBtn = ui.newButton({
            normalImage = "tb_262.png",
            clickAction = function ()
                self:rebirthBox()
                
            end,
        })
    rebirthBtn:setPosition(100, 80)
    self.mPanelLayout:addChild(rebirthBtn)
end

-- 切换幻化
function HeroIllusionLayer:changeIllusion()
    LayerManager.addLayer({name = "fashion.IllusionHomeLayer", data = {HeroId = self.mHeroId, callback = function ()
            self:refreshUI()
        end}, cleanUp = false,})
end

-- 幻化重生
function HeroIllusionLayer:rebirthBox()
    -- 计算重生花费
    local heroInfo = clone(HeroObj:getHero(self.mHeroId))
    local stepPoor = heroInfo.Step - IllusionConfig.items[1].illusionStepNeedHeroStep
    local useResList = Utility.analysisStrResList(IllusionConfig.items[1].rebirthBaseResources)
    local useResText = ""
    for _, resInfo in ipairs(useResList) do
        useResText = useResText .. string.format("{%s}%d", Utility.getDaibiImage(resInfo.resourceTypeSub, resInfo.modelId),
            resInfo.num * (stepPoor > 0 and stepPoor or 0))
    end
    -- 计算资源返还
    local illusionModelId = heroInfo.IllusionModelId
    local stepCount = clone(heroInfo.Step)
    local getResList = {}
    while (stepCount > IllusionConfig.items[1].illusionStepNeedHeroStep) do
        local needResStr = IllusionTalRelation.items[illusionModelId][stepCount-1].upUse
        local needResList = Utility.analysisStrResList(needResStr)
        for _, resInfo in pairs(needResList) do
            if getResList[resInfo.modelId] then
                getResList[resInfo.modelId].num = getResList[resInfo.modelId].num + resInfo.num
            else
                getResList[resInfo.modelId] = resInfo
            end
        end

        stepCount = stepCount - 1
    end
    -- 加一个上阵的幻化将
    if getResList[illusionModelId] then
        getResList[illusionModelId].num = getResList[illusionModelId].num + 1
    else
        getResList[illusionModelId] = {resourceTypeSub = ResourcetypeSub.eIllusion, modelId = illusionModelId, num = 1}
    end
    
    local function createHintBox(parent, bgSprite, bgSize)
        -- 花费提示
        local useLabel = ui.newLabel({
                text = TR("是否花费%s返还以下物品?", useResText),
                color = Enums.Color.eWhite,
                outlineColor = cc.c3b(0x46, 0x22, 0x0d),
            })
        useLabel:setAnchorPoint(0.5, 0.5)
        useLabel:setPosition(bgSize.width*0.5, bgSize.height-90)
        bgSprite:addChild(useLabel)
        -- 黑背景
        local blackBg = ui.newScale9Sprite("c_17.png", cc.size(bgSize.width-50, 150))
        blackBg:setPosition(bgSize.width*0.5, bgSize.height*0.5)
        bgSprite:addChild(blackBg)
        -- 列表
        local listView = ccui.ListView:create()
        listView:setDirection(ccui.ScrollViewDir.horizontal)
        -- listView:setBounceEnabled(true)
        listView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
        listView:setAnchorPoint(cc.p(0.5, 0.5))
        listView:setPosition(blackBg:getContentSize().width*0.5, blackBg:getContentSize().height*0.5)
        blackBg:addChild(listView)

        local cellSize = cc.size(100, blackBg:getContentSize().height)
        -- 添加返还角色
        local itemCell = ccui.Layout:create()
        itemCell:setContentSize(cellSize)
        listView:pushBackCustomItem(itemCell)
        -- 创建角色卡牌
        local heroInfo = clone(HeroObj:getHero(self.mHeroId))
        heroInfo.Step = heroInfo.Step > 20 and 20 or heroInfo.Step
        heroInfo.IllusionModelId = 0
        local heroCard = CardNode.createCardNode({
            resourceTypeSub = ResourcetypeSub.eHero,
            instanceData = heroInfo,
            cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eName, CardShowAttr.eLevel, CardShowAttr.eStep},
            allowClick = false,
        })
        heroCard:setPosition(cellSize.width*0.5, cellSize.height*0.55)
        itemCell:addChild(heroCard)

        -- 列表宽度
        local listWidth = cellSize.width

        -- 添加其他返还
        for _, resInfo in pairs(getResList) do
            local itemCell = ccui.Layout:create()
            itemCell:setContentSize(cellSize)
            listView:pushBackCustomItem(itemCell)

            resInfo.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eName, CardShowAttr.eNum}
            local resCard = CardNode.createCardNode(resInfo)
            resCard:setPosition(cellSize.width*0.5, cellSize.height*0.55)
            itemCell:addChild(resCard)

            listWidth = listWidth + cellSize.width
        end

        -- 设置列表大小
        local maxWidth = blackBg:getContentSize().width-10
        listView:setContentSize(cc.size(listWidth < maxWidth and listWidth or maxWidth, cellSize.height))
    end
    
    self.rebirthBoxLayer = LayerManager.addLayer({
        name = "commonLayer.MsgBoxLayer",
        cleanUp = false,
        data = {
            notNeedBlack = true,
            bgSize = cc.size(600, 400),
            title = TR("重生"),
            btnInfos = {
                {
                    text = TR("确定"),
                    normalImage = "c_28.png",
                    clickAction = function ()
                        self:requestRebirth()
                    end,
                },
                {
                    text = TR("取消"),
                    normalImage = "c_28.png",
                    clickAction = function ()
                        LayerManager.removeLayer(self.rebirthBoxLayer)
                    end,
                },
            },
            DIYUiCallback = createHintBox,
            closeBtnInfo = {}
        }
    })
end

-- 刷新界面
function HeroIllusionLayer:refreshUI()
    -- 刷新父页面
    self.mParent:refreshCurrHeroFigure()
    self:showInfo()

    -- 清空父节点
    self.mPanelLayout:removeAllChildren()

    -- 人物信息
    local heroInfo = clone(HeroObj:getHero(self.mHeroId))
    local heroModel = HeroModel.items[heroInfo.ModelId]

    -- 限制提示
    local hintLabel = ""
    if heroModel.quality < IllusionConfig.items[1].needHeroQuality then
        hintLabel = TR("需要%s品质的侠客才能幻化", Utility.getHeroColorName(IllusionConfig.items[1].needHeroQuality))
    elseif heroInfo.Step < IllusionConfig.items[1].needHeroStep then
        hintLabel = TR("只有突破到武尊+5的传说侠客才能幻化哦")
    elseif heroInfo.IllusionModelId == nil or heroInfo.IllusionModelId == 0 then
        hintLabel = TR("暂未幻化")
    end

    -- 显示提示
    if hintLabel ~= "" then
        local emptyHintSprite = ui.createEmptyHint(hintLabel)
        emptyHintSprite:setPosition(380, 270)
        self.mPanelLayout:addChild(emptyHintSprite)

        local getBtn = ui.newButton({
            text = TR("去幻化"),
            normalImage = "c_28.png",
            clickAction = function ()
                self:changeIllusion()
            end
        })
        getBtn:setPosition(320, 80)
        self.mPanelLayout:addChild(getBtn, 10)
    -- 显示幻化
    else
        self:createBottomUI()
    end
end

--- ==================== 数据显示相关 =======================
-- 显示所有信息
function HeroIllusionLayer:showInfo()
    local data = HeroObj:getHero(self.mHeroId)
    self.mParent.mNameNode:refreshName(data)
end

--==================== 网络相关 =======================
-- 重生
function HeroIllusionLayer:requestRebirth()
    HttpClient:request({
        moduleName = "Hero",
        methodName = "HeroIllusionRebirth",
        svrMethodData = {{self.mHeroId}},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            -- 获取重生前幻化信息
            local illusionId = HeroObj:getHero(self.mHeroId).IllusionId
            local illusionInfo = IllusionObj:getIllusion(illusionId)

            -- 修改学员信息
            HeroObj:modifyHeroItem(response.Value.HeroInfo[1])

            -- 添加角色
            response.Value.BaseGetGameResourceList[1] = response.Value.BaseGetGameResourceList[1] or {}
            response.Value.BaseGetGameResourceList[1].Hero = response.Value.BaseGetGameResourceList[1].Hero or {}
            -- 添加角色信息
            local heroInfo = clone(response.Value.HeroInfo[1])
            table.insert(response.Value.BaseGetGameResourceList[1].Hero, 1, heroInfo)

            -- 添加一个下阵幻化将
            response.Value.BaseGetGameResourceList[1].Illusion = response.Value.BaseGetGameResourceList[1].Illusion or {}
            if illusionInfo then
                table.insert(response.Value.BaseGetGameResourceList[1].Illusion, 1, illusionInfo)
            end

            -- 返还资源
            MsgBoxLayer.addGameDropLayer(response.Value.BaseGetGameResourceList, nil, nil, TR("返还"))
            -- 刷新界面
            self:refreshUI()
        end
    })
end


return HeroIllusionLayer