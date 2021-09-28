--[[
    文件名：ZhenYuanBagLayer.lua
    描述：真元包裹主界面
    创建人：chenzhong
    创建时间： 2017.12.14
--]]

local ZhenYuanBagLayer = class("ZhenYuanBagLayer", function(params)
    return display.newLayer()
end)

function ZhenYuanBagLayer:ctor(params)
    -- package.loaded["zhenYuan.ZhenYuanBagLayer"] = nil
    -- 背景图片
    local bgSprite = ui.newSprite("c_128.jpg")
    bgSprite:setPosition(320, 568)
    self:addChild(bgSprite)
    self.mBgSprite = bgSprite

    --下方白板背景
    local bottomSprtie = ui.newScale9Sprite("c_19.png", cc.size(640, 1015))
    bottomSprtie:setAnchorPoint(0.5, 0)
    bottomSprtie:setPosition(320, 0)
    bgSprite:addChild(bottomSprtie)

    self.mSelectStatus = { --保存菜单选择状态
        [1] = false,
        [2] = false,
        [3] = false,
        [4] = false,
        [5] = false,
        [6] = false,
        -- [7] = false,
    }

    -- 包裹空间文字背景图片
    local countBack = ui.newScale9Sprite("c_24.png", cc.size(118, 32))
    countBack:setPosition(420, 960)
    bgSprite:addChild(countBack)

    countWordLabel = ui.newLabel({
        text = TR("气海容量"),
        color = cc.c3b(0x46, 0x22, 0x0d),
        -- outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        size = 22,
    })
    countWordLabel:setAnchorPoint(cc.p(0, 0.5))
    countWordLabel:setPosition(270, 960)
    bgSprite:addChild(countWordLabel)

    --灰色底板
    local underBgSprite = ui.newScale9Sprite("c_17.png", cc.size(622, 814))
    underBgSprite:setPosition(320, 920)
    underBgSprite:setAnchorPoint(0.5, 1)
    bgSprite:addChild(underBgSprite)

    self:showBagCount()
    self:refreshList()

    --选择菜单按钮
    local selectBtn = ui.newButton({
        normalImage = "bg_01.png",
        text = TR("筛选"),
        fontSize = 22,
        outlineColor = cc.c3b(0x18, 0x7e, 0x6d),
        })
    selectBtn:setPosition(572, 960)
    bgSprite:addChild(selectBtn, 1000)
    local temp = true --控制展示或者关闭菜单
    local offset
    local triangle = ui.newSprite("bg_02.png") --三角形箭头
    triangle:setRotation(90)
    triangle:setPosition(84, 22)
    selectBtn:addChild(triangle)
    selectBtn:setClickAction(function(pSender)
        pSender:setEnabled(false)
        local showAction
        local touchLayer = display.newLayer()
        touchLayer:setPosition(0,0)
        self:addChild(touchLayer, 1000)
        ui.registerSwallowTouch({
            node = touchLayer,
            allowTouch = true,
            endedEvent = function(touch, event)
                offset = 1
                temp = true
                local callfunDelete = cc.CallFunc:create(function()
                    if self.mSelBgSprite then
                        self.mSelBgSprite:removeFromParent()
                        self.mSelBgSprite = nil
                    end
                end)
                local callfunCT = cc.CallFunc:create(function()
                    pSender:setEnabled(true)
                    touchLayer:removeFromParent()
                end)
                local scale = cc.ScaleTo:create(0.3, 1)
                showAction = cc.Sequence:create(scale, callfunDelete, callfunCT)
                triangle:setRotation(offset*90)
                self.mSelBgSprite:runAction(showAction)
            end
        })

        if temp then
            offset = 0
            temp = false
            local callfunCT = cc.CallFunc:create(function()
                pSender:setEnabled(true)
            end)
            local scale = cc.ScaleTo:create(0.3, 2)
            showAction = cc.Sequence:create(scale, callfunCT)
        end
        triangle:setRotation(offset*90)

        if not self.mSelBgSprite then
            --菜单背景
            self.mSelBgSprite = ui.newScale9Sprite("zb_05.png", cc.size(82, 130)) --（82, 150）
            self.mSelBgSprite:setAnchorPoint(0.5, 1)
            self.mSelBgSprite:setPosition(550, 930)
            touchLayer:addChild(self.mSelBgSprite)
            local bgSize = self.mSelBgSprite:getContentSize()
            --菜单列表
            local selectList = ccui.ListView:create()
            selectList:setPosition(bgSize.width * 0.5, bgSize.height)
            selectList:setAnchorPoint(0.5, 1)
            selectList:setContentSize(bgSize.width - 10, bgSize.height - 5)
            selectList:setDirection(ccui.ScrollViewDir.vertical)
            selectList:setBounceEnabled(true)
            self.mSelBgSprite:addChild(selectList)

            for i = 1, #self.mSelectStatus do
                local layout = ccui.Layout:create()
                layout:setContentSize(138, 20)
                local color = Utility.getColorValue(i, 1)
                local checkBtn = ui.newCheckbox({
                    text = TR("%s品质",Utility.getColorName(i)),
                    textColor = color,
                    outlineColor = Enums.Color.eBlack,
                    outlineSize = 2,
                    callback = function(pSenderC)
                        if self.mSelectStatus[i] then
                            self.mSelectStatus[i] = false
                        else
                            self.mSelectStatus[i] = true
                        end
                        self:refreshList()
                    end
                    })
                checkBtn:setPosition(70, 10)
                layout:addChild(checkBtn)
                checkBtn:setCheckState(self.mSelectStatus[i])
                layout:setScale(0.5)
                -- 透明按钮
                local touchBtn = ui.newButton({
                    normalImage = "c_83.png",
                    size = cc.size(138, 20),
                    clickAction = function()
                        if self.mSelectStatus[i] then
                            self.mSelectStatus[i] = false
                        else
                            self.mSelectStatus[i] = true
                        end
                        self:refreshList()
                        checkBtn:setCheckState(self.mSelectStatus[i])
                    end
                })
                touchBtn:setPosition(69, 10)
                layout:addChild(touchBtn)
                selectList:pushBackCustomItem(layout)
            end
        end

        self.mSelBgSprite:runAction(showAction)
    end)
end

--显示包裹空间
function ZhenYuanBagLayer:showBagCount()
    if self.mCountLabel then
        self.mCountLabel:removeFromParent()
        self.mCountLabel = nil
    end

    if self.mBuyBtn then
        self.mBuyBtn:removeFromParent()
        self.mBuyBtn = nil
    end

    -- 添加数量显示
    self.mCountLabel = ui.newLabel({
        text = TR("%d/%d", 0, 0),
        color = cc.c3b(0xd1, 0x7b, 0x00),
        size = 22,
    })
    self.mCountLabel:setPosition(410, 960)
    self.mBgSprite:addChild(self.mCountLabel)
    self.mBuyBtn = ui.newButton({
        normalImage = "gd_27.png",
        position = cc.p(480, 960),
        clickAction = function()
            MsgBoxLayer.addExpandBagLayer(BagType.eZhenyuanBag, function ()
                self:showBagCount()
            end)
        end,
    })
    self.mBgSprite:addChild(self.mBuyBtn)
    
    local haveZhenYuanNum = #ZhenyuanObj:getZhenyuanList()
    local bagTypeInfo = BagModel.items[BagType.eZhenyuanBag]
    local playerTypeInfo = self:getPlayerBagInfo(BagType.eZhenyuanBag)
    local maxBagSize = table.nums(BagExpandUseRelation.items) * bagTypeInfo.perExpandSize + bagTypeInfo.initSize
    self.mCountLabel:setString(TR("%d/%d", haveZhenYuanNum, playerTypeInfo.Size))
    self.mBuyBtn:setVisible(playerTypeInfo.Size < maxBagSize)

    if haveZhenYuanNum == 0 then
        local sp = ui.createEmptyHint(TR("没有真元！"))
        sp:setPosition(320, 550)
        self.mBgSprite:addChild(sp)
    end
end

-- 获取对应类的包裹的信息
function ZhenYuanBagLayer:getPlayerBagInfo(bagModelId)
    local playerTypeInfo = {}
    for i, v in ipairs(BagInfoObj:getAllBagInfo()) do
        if v.BagModelId == bagModelId then
            playerTypeInfo = v
            break
        end
    end
    return playerTypeInfo
end

-- 刷新装备列表
function ZhenYuanBagLayer:refreshList()
    -- 整理数据
    self:getItemData()

    if self.mZhenYuanList then
        self.mZhenYuanList:removeFromParent()
        self.mZhenYuanList = nil
    end

    self.mZhenYuanList = ccui.ListView:create()
    self.mZhenYuanList:setPosition(320, 906)
    self.mZhenYuanList:setAnchorPoint(0.5, 1)
    self.mZhenYuanList:setContentSize(630, 790)
    self.mZhenYuanList:setDirection(ccui.ScrollViewDir.vertical)
    self.mZhenYuanList:setBounceEnabled(true)
    self.mBgSprite:addChild(self.mZhenYuanList)
    -- dump(self.mZhenyuanInfos,"self.mZhenyuanInfos")
    for i,v in ipairs(self.mZhenyuanInfos) do
        self.mZhenYuanList:pushBackCustomItem(self:createItem(i))
    end
end

-- 创建单个装备条目
function ZhenYuanBagLayer:createItem(index)
    local cellSize = cc.size(626, 150)
    local item = self.mZhenyuanInfos[index]
    local lvItem = ccui.Layout:create()
    lvItem:setContentSize(cellSize)
    --背景
    local bgSprite = ui.newScale9Sprite("c_18.png", cc.size(610, 142))
    bgSprite:setPosition(315, 75)
    lvItem:addChild(bgSprite)
    --前往按钮
    local lvUpBtn = ui.newButton({
        text = TR("聚气"),
        normalImage = "c_28.png",
        clickAction = function ()
            LayerManager.addLayer({
                name = "zhenyuan.ZhenYuanLvUpLayer",
                data = {zhenyuanList = {item.Id}},
            })
        end
    })
    lvUpBtn:setPosition(539, 65)
    lvItem:addChild(lvUpBtn)

    -- 真元头像
    local tempCard = CardNode.createCardNode({
        cardShowAttrs = {CardShowAttr.eBorder},
        resourceTypeSub = ResourcetypeSub.eZhenYuan,
        instanceData = item,
        allowClick = true, --是否可点击
    })
    tempCard:setPosition(80, cellSize.height / 2)
    lvItem:addChild(tempCard)

    -- 真元名字
    local nameLabel = ui.newLabel({
        text = item.modelData.name,
        color = Utility.getQualityColor(item.modelData.quality, 1),
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        size = 24,
        align = cc.TEXT_ALIGNMENT_LEFT,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
    })
    nameLabel:setAnchorPoint(cc.p(0, 0.5))
    nameLabel:setPosition(165, cellSize.height / 2 + 30)
    lvItem:addChild(nameLabel)

    -- 真元的资质
    local qualityLabel = ui.newLabel({
        text = TR("资质: %s%d", Enums.Color.eDarkGreenH, item.modelData.quality),
        color = Enums.Color.eBrown,
        align = cc.TEXT_ALIGNMENT_LEFT,
    })
    qualityLabel:setAnchorPoint(cc.p(0, 0.5))
    qualityLabel:setPosition(165, cellSize.height / 2 - 5)
    lvItem:addChild(qualityLabel)

    -- 真元的等级
    local lvLabel = ui.newLabel({
        text = TR("等级: %s%s", Enums.Color.eDarkGreenH, item.Lv),
        color = Enums.Color.eBrown,
        align = cc.TEXT_ALIGNMENT_LEFT,
    })
    lvLabel:setAnchorPoint(cc.p(0, 0.5))
    lvLabel:setPosition(300, cellSize.height / 2 - 5)
    lvItem:addChild(lvLabel)

    -- 属性显示
    local attrStr = self:getZhenyuanAttrStr(item)
    local attrLabel = ui.newLabel({
        text = attrStr,
        color = Enums.Color.eBrown,
        align = cc.TEXT_ALIGNMENT_CENTER,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
    })
    attrLabel:setAnchorPoint(cc.p(0, 0.5))
    attrLabel:setPosition(165, cellSize.height / 2 -40)
    lvItem:addChild(attrLabel)

    -- 显示提示文字
    local infoText = nil
    if item.status.inFormation then
        local slotInfo = FormationObj:getSlotInfoBySlotId(item.status.slotId)
        local heroInfo = FormationObj:getSlotHeroInfo(slotInfo.HeroId)
        local heroModel = HeroModel.items[heroInfo.ModelId]
        local colorValue = Utility.getQualityColor(heroModel.quality, 2)
        local tempName = heroModel.name
        if heroInfo.IllusionModelId and heroInfo.IllusionModelId > 0 then 
            tempName = IllusionModel.items[heroInfo.IllusionModelId] and IllusionModel.items[heroInfo.IllusionModelId].name or ""
        end 
        infoText = TR("[装备于%s%s%s]", colorValue, tempName, Enums.Color.eBrownH)
    end
    if (infoText ~= nil) then
        local tempLabel = ui.newLabel({
            text = infoText,
            color = Enums.Color.eBrown,
            align = cc.TEXT_ALIGNMENT_CENTER,
            valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
        })
        tempLabel:setAnchorPoint(cc.p(0.5, 0.5))
        tempLabel:setPosition(450, cellSize.height / 2 + 30)
        lvItem:addChild(tempLabel)
    end

    return lvItem
end

-- 刷新真元数据
function ZhenYuanBagLayer:getItemData()
    self.mZhenyuanInfos = {}
    -- 获取需要显示的真元
    local zhenyuanInfos = clone(ZhenyuanObj:getZhenyuanList())

    -- 整理真元的其他信息
    for _, item in ipairs(zhenyuanInfos) do
        local tempModelId = item.ModelId
        -- 装备模型信息
        if not item.modelData then
            item.modelData = ZhenyuanModel.items[tempModelId]
        end
        
        -- 真元上阵状态
        if not item.status then
            local inFormation, slotId = FormationObj:zhenyuanInFormation(item.Id)
            item.status = {
                inFormation = inFormation,
                slotId = slotId
            }
        end
    end

    local selectColor = {}
    for i,v in ipairs(self.mSelectStatus) do
        if v then
            table.insert(selectColor, i)
        end
    end
    
    if next(selectColor) == nil then
        for i,v in ipairs(zhenyuanInfos) do
            table.insert(self.mZhenyuanInfos, v)
        end
    else
        for _,v in ipairs(zhenyuanInfos) do
            local colorLv = Utility.getQualityColorLv(ZhenyuanModel.items[v.ModelId].quality)
            for m,n in ipairs(selectColor) do
                if n == colorLv then
                    table.insert(self.mZhenyuanInfos, v)
                end
            end
        end
    end
    
    -- 排序
    table.sort(self.mZhenyuanInfos, function(item1, item2)
        -- 已上阵的放到前面
        if item1.status.inFormation ~= item2.status.inFormation then
            return (item1.status.inFormation == true)
        end

        -- 比较资质
        if item1.modelData.quality ~= item2.modelData.quality then
            return item1.modelData.quality > item2.modelData.quality
        end

        -- 比较模型ID
        return item1.ModelId > item2.ModelId
    end)
end

-- 获取真元的属性列表
--[[
    params:
        zhenyuanInfo                -- 真元信息
    返回：
        属性字符串
--]]
function ZhenYuanBagLayer:getZhenyuanAttrStr(zhenyuanInfo)
    -- 等级
    local curLv = zhenyuanInfo.Lv
    -- 是否满级
    if not ZhenyuanLvUpRelation.items[curLv] then return end

    -- 属性列表
    local attrList = {}

    -- 真元属性信息
    local zhenyuanModel = ZhenyuanModel.items[zhenyuanInfo.ModelId]
    local baseAtrrList = Utility.analysisStrAttrList(zhenyuanModel.basicAttr)
    local upAtrrList = Utility.analysisStrAttrList(zhenyuanModel.attrUP)

    -- 获取属性加入列表
    for _, upAttr in pairs(upAtrrList) do
        upAttr.value = upAttr.value*curLv
        attrList[upAttr.fightattr] = upAttr.value
    end
    for _, baseAtrrList in pairs(baseAtrrList) do
        attrList[baseAtrrList.fightattr] = (attrList[baseAtrrList.fightattr] or 0) + baseAtrrList.value
    end

    -- 将属性信息转化为字符串
    local attrStrList = {}
    for fightattr, value in pairs(attrList) do
        local text = FightattrName[fightattr]..Utility.getAttrViewStr(fightattr, value)
        table.insert(attrStrList, text)
    end

    return table.concat(attrStrList, ",")
end

return ZhenYuanBagLayer
