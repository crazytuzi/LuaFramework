--[[
    文件名: DlgFashionStepUpLayer.lua
    创建人: peiyaoqiang
    创建时间: 2018-05-03
    描述: 绝学进阶对话框
--]]

local DlgFashionStepUpLayer = class("DlgFashionStepUpLayer", function()
    return display.newLayer()
end)

function DlgFashionStepUpLayer:ctor(params)
    -- 屏蔽下层触摸事件
    ui.registerSwallowTouch({node = self})

    -- 读取参数
    self.closeCallback = params.callback
    self.fashionItem = params.item or {}

    -- 是否使用外功参悟丹
    self.isSelMedicine = true
    
    -- 添加弹出框层
    local parentLayer = require("commonLayer.PopBgLayer").new({
        bgSize = cc.size(620, 880),
        title = TR("绝学进阶"),
        closeAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self:addChild(parentLayer)
    self.mBgSprite = parentLayer.mBgSprite
    self.mBgSize = self.mBgSprite:getContentSize()

    -- 
    self:initUI()
    self:refreshUI()
end

-- 初始化页面
function DlgFashionStepUpLayer:initUI()
    local centerX = self.mBgSize.width / 2
    local commonWidth = self.mBgSize.width - 60
    
    -- 进阶信息
    local infoBgSprite = ui.newScale9Sprite("c_25.png", cc.size(commonWidth, 54))
    infoBgSprite:setPosition(centerX, self.mBgSize.height - 100)
    self.mBgSprite:addChild(infoBgSprite)
    self.mInfoSprite = infoBgSprite
    self.mInfoSprite.refreshNode = function (target)
        target:removeAllChildren()

        -- 显示箭头
        local arrowSprite = ui.newSprite("c_66.png")
        arrowSprite:setPosition(140, 27)
        target:addChild(arrowSprite)

        -- 显示当前进阶和下一进阶
        local function addLabel(strText, anchor, pos)
            local label = ui.newLabel({
                text = strText,
                color = Enums.Color.eWhite,
                outlineColor = cc.c3b(0x72, 0x25, 0x13),
            })
            label:setAnchorPoint(anchor)
            label:setPosition(pos)
            target:addChild(label)
        end
        if (self.nextConfig ~= nil) then
            local strColorH = (PlayerAttrObj:getPlayerAttrByName("Lv") >= self.currConfig.needPlayerLv) and "#9BFF6A" or Enums.Color.eRedH
            addLabel(TR("进阶%s+%d", "#9BFF6A", self.nextConfig.step), cc.p(0, 0.5), cc.p(170, 27))
            addLabel(TR("需要玩家等级:%s%s", strColorH, self.currConfig.needPlayerLv), cc.p(1, 0.5), cc.p(510, 27))
        else
            addLabel(TR("已到最高"), cc.p(0, 0.5), cc.p(170, 27))
        end
        addLabel(TR("进阶%s+%d", "#FF974A", self.currConfig.step), cc.p(0, 0.5), cc.p(30, 27))
    end

    -- 属性提升
    local attrBgSprite = ui.newScale9Sprite("c_17.png", cc.size(commonWidth, 475))
    attrBgSprite:setAnchorPoint(cc.p(0.5, 0))
    attrBgSprite:setPosition(centerX, 270)
    self.mBgSprite:addChild(attrBgSprite)
    self.mAttrSprite = attrBgSprite
    self.mAttrSprite.refreshNode = function (target)
        target:removeAllChildren()

        -- 创建列表
        local listWidth = commonWidth - 20
        local listView = ccui.ListView:create()
        listView:setDirection(ccui.ScrollViewDir.vertical)
        listView:setBounceEnabled(true)
        listView:setContentSize(cc.size(listWidth, 455))
        listView:setGravity(ccui.ListViewGravity.centerVertical)
        listView:setItemsMargin(5)
        listView:setAnchorPoint(cc.p(0.5, 0))
        listView:setPosition(commonWidth / 2, 10)
        listView:setScrollBarEnabled(false)
        listView:setTouchEnabled(false)
        listView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
        target:addChild(listView)
        self.listWidth = listWidth

        -- 添加基础属性和穿戴属性
        listView:pushBackCustomItem(self:createAttrLayout(true))
        listView:pushBackCustomItem(self:createAttrLayout(false))
        -- 添加技能
        listView:pushBackCustomItem(self:createSkillLayout(true))
        listView:pushBackCustomItem(self:createSkillLayout(false))
    end

    -- 材料消耗
    local resBgSprite = ui.newScale9Sprite("c_37.png", cc.size(commonWidth, 160))
    resBgSprite:setAnchorPoint(0.5, 0)
    resBgSprite:setPosition(centerX, 100)
    self.mBgSprite:addChild(resBgSprite)
    self.mResSprite = resBgSprite
    self.mResSprite.refreshNode = function (target)
        target:removeAllChildren()

        -- 标题
        local titleLabel = ui.newLabel({
            text = TR("进阶消耗"),
            size = 24,
            color = Enums.Color.eWhite,
            outlineColor = cc.c3b(0x72, 0x25, 0x13),
        })
        titleLabel:setPosition(commonWidth / 2, 140)
        target:addChild(titleLabel)

        -- 是否已进阶到最高
        if (self.nextConfig == nil) then
            local label = ui.newLabel({
                text = TR("已进阶到最高"),
                color = Enums.Color.eRed,
                size = 25,
            })
            label:setPosition(cc.p(commonWidth / 2, 62))
            target:addChild(label)
            return
        end

        local useFashion = 1    -- 消耗碎片
        local useMedicine = 2   -- 消耗参悟丹
        self.beforeSel = {}     -- 当前选择框节点列表

        -- 创建消耗卡牌
        local function ceateUse(posXList, useStr, tag)
            -- 读取消耗需求
            for i,v in ipairs(Utility.analysisStrResList(useStr)) do
                local selecSprite = ui.newSprite("c_31.png")
                selecSprite:setPosition(cc.p(posXList[i], 62))
                target:addChild(selecSprite)
                selecSprite:setVisible(tag == self.curTag)

                self.beforeSel[tag] = self.beforeSel[tag] or {}
                table.insert(self.beforeSel[tag], selecSprite)

                local tmpCard, cardShowAttrs = CardNode.createCardNode({
                    resourceTypeSub = v.resourceTypeSub,
                    modelId = v.modelId,
                    num = v.num,
                    cardShape = Enums.CardShape.eSquare,
                    cardShowAttrs = {CardShowAttr.eNum, CardShowAttr.eBorder},
                    onClickCallback = function()
                        if self.curTag == tag then
                            Utility.showResLackLayer(v.resourceTypeSub, v.modelId)
                        else
                            for _, temSel in pairs(self.beforeSel[self.curTag]) do
                                temSel:setVisible(false)
                            end

                            self.curTag = tag
                            self.isSelMedicine = self.curTag == useMedicine

                            for _, temSel in pairs(self.beforeSel[self.curTag]) do
                                temSel:setVisible(true)
                            end
                        end
                    end
                })
                tmpCard:setPosition(cc.p(posXList[i], 62))
                target:addChild(tmpCard)

                -- 显示当前拥有数量
                local numLabel = cardShowAttrs[CardShowAttr.eNum].label
                local holdNum = Utility.getOwnedGoodsCount(v.resourceTypeSub, v.modelId)
                local color = (holdNum >= v.num) and Enums.Color.eGreenH or Enums.Color.eRedH
                numLabel:setString(color .. string.format("%s/%s", Utility.numberWithUnit(holdNum), Utility.numberWithUnit(v.num)))
            end
        end

        -- 或者
        local orLabel = ui.newLabel({
            text = TR("或者"),
            size = 24,
            color = cc.c3b(0x46, 0x22, 0x0d),
        })
        orLabel:setPosition(commonWidth / 2, 62)
        target:addChild(orLabel)

        -- 判断参悟丹是否充足
        local isMedicEnough = true
        for _,v in ipairs(Utility.analysisStrResList(self.currConfig.backUpUse)) do
            local holdNum = Utility.getOwnedGoodsCount(v.resourceTypeSub, v.modelId)
            if (holdNum < v.num) then
                isMedicEnough = false
                break
            end
        end

        -- 判断时装碎片是否充足
        local isFashionEnough = true
        for _,v in ipairs(Utility.analysisStrResList(self.currConfig.upUse)) do
            local holdNum = Utility.getOwnedGoodsCount(v.resourceTypeSub, v.modelId)
            if (holdNum < v.num) then
                isFashionEnough = false
                break
            end
        end

        self.curTag = isFashionEnough and useFashion or useMedicine

        self.isSelMedicine = self.curTag == useMedicine

        local posXList = {commonWidth * 0.15, commonWidth * 0.35}
        ceateUse(posXList, self.currConfig.upUse, useFashion)

        local posXList = {commonWidth * 0.65, commonWidth * 0.85}
        ceateUse(posXList, self.currConfig.backUpUse, useMedicine)
    end

    -- 进阶按钮
    local button = ui.newButton({
        normalImage = "c_28.png",
        text = TR("进阶"),
        position = cc.p(self.mBgSize.width * 0.7, 60),
        clickAction = function()
            self:requestStepUp()
        end
    })
    self.mBgSprite:addChild(button)

    -- 预览按钮
    local button = ui.newButton({
        normalImage = "c_33.png",
        text = TR("预览"),
        position = cc.p(self.mBgSize.width * 0.3, 60),
        clickAction = function()
            LayerManager.addLayer({name = "fashion.DlgFashionPreviewLayer", data = {modelId = self.fashionItem.baseInfo.ID}, cleanUp = false,})
        end
    })
    self.mBgSprite:addChild(button)
end

-- 刷新界面
function DlgFashionStepUpLayer:refreshUI()
    local stepConfig = FashionStepRelation.items[self.fashionItem.baseInfo.ID]
    self.fashionStep = FashionObj:getOneItemStep(self.fashionItem.baseInfo.ID)
    self.currConfig = stepConfig[self.fashionStep]
    self.nextConfig = stepConfig[self.fashionStep + 1]
    
    -- 刷新显示
    self.mInfoSprite:refreshNode()
    self.mAttrSprite:refreshNode()
    self.mResSprite:refreshNode()
end

-- 显示基本属性和穿戴属性
function DlgFashionStepUpLayer:createAttrLayout(isNormal)
    local layout = ccui.Layout:create()
    local cellWidth, cellHeight = self.listWidth, 120
    layout:setContentSize(cellWidth, cellHeight)

    -- 背景图片
    local itemBg = ui.newScale9Sprite("c_18.png", cc.size(cellWidth, cellHeight))
    itemBg:setPosition(cellWidth * 0.5, cellHeight * 0.5)
    layout:addChild(itemBg)

    -- 属性图标
    local cellCenterX = 95 + (cellWidth - 100) / 2
    local cellCenterY = cellHeight / 2
    local iconImg = isNormal and "zr_68.png" or "zr_67.png"
    local iconSprite = ui.newSprite(iconImg)
    iconSprite:setPosition(50, cellCenterY)
    layout:addChild(iconSprite)

    -- 进阶不会引起穿戴属性的变化
    local function addAttrLabel(attrList, xOffset, strColor)
        local ySpace = cellHeight/#attrList
        for i,v in ipairs(attrList) do
            local label = ui.newLabel({
                text = FightattrName[tonumber(v[1])] .. strColor .. "+" .. v[2],
                color = cc.c3b(0x46, 0x22, 0x0d),
                size = 20,
            })
            label:setAnchorPoint(cc.p(0, 0.5))
            label:setPosition(cc.p(xOffset, ySpace*i-ySpace/2))
            layout:addChild(label)
        end
    end
    if (isNormal == true) then
        -- 进阶前的属性
        addAttrLabel(ConfigFunc:getBaseAttrByStep(self.fashionItem.baseInfo.ID, self.currConfig.step), 150, "#D38212")

        -- 箭头
        local arrowSprite = ui.newSprite("zdjs_11.png")
        arrowSprite:setPosition(cellCenterX, cellCenterY)
        layout:addChild(arrowSprite)
        
        -- 进阶后的属性
        if (self.nextConfig == nil) then
            local label = ui.newLabel({
                text = TR("已到最高"),
                color = Enums.Color.eRed,
                size = 25,
            })
            label:setPosition(cc.p(cellCenterX + 100, cellCenterY))
            layout:addChild(label)
        else
            addAttrLabel(ConfigFunc:getBaseAttrByStep(self.fashionItem.baseInfo.ID, self.nextConfig.step), cellCenterX + 50, Enums.Color.eNormalGreenH)
        end
    else
        local label = ui.newLabel({
            text = TR("进阶不影响穿戴属性"),
            color = Enums.Color.eRed,
            size = 25,
        })
        label:setPosition(cc.p(cellCenterX, cellCenterY))
        layout:addChild(label)
    end

    return layout
end

-- 显示普攻和技攻的技能
function DlgFashionStepUpLayer:createSkillLayout(isNormal)
    local layout = ccui.Layout:create()
    local cellWidth, cellHeight = self.listWidth, 100
    layout:setContentSize(cellWidth, cellHeight)

    -- 背景图片
    local itemBg = ui.newScale9Sprite("c_18.png", cc.size(cellWidth, cellHeight))
    itemBg:setPosition(cellWidth * 0.5, cellHeight * 0.5)
    layout:addChild(itemBg)

    -- 技能图标
    local cellCenterX = 95 + (cellWidth - 100) / 2
    local cellCenterY = cellHeight / 2
    local iconImg = isNormal and self.fashionItem.baseInfo.attackIcon or self.fashionItem.baseInfo.skillIcon
    local iconSprite = ui.newSprite(iconImg .. ".png")
    iconSprite:setPosition(50, cellHeight / 2)
    layout:addChild(iconSprite)

    -- 进阶前的描述
    local attrType = isNormal and "NAID" or "RAID"
    local function showSkillIntro(str, posX)
        local introLabel = ui.newLabel({
            text = str,
            color = cc.c3b(0x73, 0x43, 0x0d),
            size = 18,
            align = ui.TEXT_ALIGN_LEFT,
            valign = ui.TEXT_VALIGN_CENTER,
            dimensions = cc.size(200, 90)
        })
        introLabel:setAnchorPoint(cc.p(0, 1))
        introLabel:setPosition(posX, cellHeight - 5)
        layout:addChild(introLabel)
    end
    showSkillIntro(AttackModel.items[self.currConfig[attrType]].intro, 105)

    -- 箭头
    local arrowSprite = ui.newSprite("zdjs_11.png")
    arrowSprite:setPosition(cellCenterX, cellCenterY)
    layout:addChild(arrowSprite)

    -- 进阶后的描述
    if (self.nextConfig == nil) then
        local label = ui.newLabel({
            text = TR("已到最高"),
            color = Enums.Color.eRed,
            size = 25,
        })
        label:setPosition(cc.p(cellCenterX + 100, cellCenterY))
        layout:addChild(label)
    else
        showSkillIntro(AttackModel.items[self.nextConfig[attrType]].intro, cellCenterX + 30)
    end

    return layout
end

-- 绝学进阶
function DlgFashionStepUpLayer:requestStepUp()
    -- 判断是否已到最高
    if (self.nextConfig == nil) then
        ui.showFlashView(TR("该绝学已经进阶到最高"))
        return
    end
    
    -- 判断等级是否达到
    if (PlayerAttrObj:getPlayerAttrByName("Lv") < self.currConfig.needPlayerLv) then
        ui.showFlashView(TR("需要玩家达到%d级才能继续进阶", self.currConfig.needPlayerLv))
        return
    end

    -- 判断材料是否充足
    for _,v in ipairs(Utility.analysisStrResList(self.isSelMedicine and self.currConfig.backUpUse or self.currConfig.upUse)) do
        local holdNum = Utility.getOwnedGoodsCount(v.resourceTypeSub, v.modelId)
        if (holdNum < v.num) then
            Utility.showResLackLayer(v.resourceTypeSub, v.modelId)
            return
        end
    end
    
    -- 请求接口
    HttpClient:request({
        moduleName = "Fashion",
        methodName = "StepUp",
        svrMethodData = {self.fashionItem.Id, self.isSelMedicine},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            
            -- 修改进阶
            FashionObj:setOneItemStep(self.fashionItem.Id, self.fashionStep + 1, response.Value.BackUpUseSteps)

            -- 刷新界面
            self:refreshUI()

            -- 通知上层刷新
            if self.closeCallback then
                self.closeCallback()
            end
        end,
    })
end

return DlgFashionStepUpLayer