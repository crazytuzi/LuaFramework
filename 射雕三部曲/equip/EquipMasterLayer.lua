--[[
    文件名:EquipMasterLayer.lua
    描述：装备培养共鸣页面
    创建人：peiyaoqiang
    创建时间：2017.03.15
--]]
local EquipMasterLayer = class("EquipMasterLayer", function(params)
    return display.newLayer()
end)

local EquipSelectTabChange = "EquipSelectTabChange"  -- 选中Tab改变的事件名称

--[[
-- 参数 params 中各项为：
	{
		defaultTag: 默认显示子页面类型, 取值为EnumsConfig.lua文件中ModuleSub的 eEquipStarUp\eEquipStepUp, 默认为 eEquipStepUp
	}
]]
function EquipMasterLayer:ctor(params)
    -- 屏蔽下层事件
	ui.registerSwallowTouch({node = self})
	
	-- 处理参数
	self.defaultTag = params.defaultTag
    self.mResourcetypeSub = params.resourcetypeSub or ResourcetypeSub.eClothes

	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer) 

    -- 显示背景图
    local bgSprite = ui.newSprite("c_34.jpg")
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)

    -- 显示UI
    self:initUI()

    -- 创建底部导航信息部分
    local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
    })
    self:addChild(tempLayer)
end

-- 初始化UI
function EquipMasterLayer:initUI()
    local tabPos = Enums.StardardRootPos.eTabView
    local tabBtnInfos = {}
    if ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eEquipStepUpMaster, false) then
        table.insert(tabBtnInfos, {
            tag = ModuleSub.eEquipStepUp,
            text = TR("锻造"),
            moduleId = ModuleSub.eEquipStepUpMaster,
        })
        if (self.defaultTag == nil) then
            self.defaultTag = ModuleSub.eEquipStepUp
        end
    end
    if ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eEquipStarUpMaster, false) then
        table.insert(tabBtnInfos, {
            tag = ModuleSub.eEquipStarUp,
            text = TR("升星"),
            moduleId = ModuleSub.eEquipStarUpMaster,
        })
        if (self.defaultTag == nil) then
            self.defaultTag = ModuleSub.eEquipStarUp
        end
    end
    
    -- 显示Tab背景
    local tabBgSize = cc.size(640, tabPos.y + 30)
    local tabBgSprite = ui.newScale9Sprite("c_19.png", tabBgSize)
    tabBgSprite:setAnchorPoint(0.5, 0)
    tabBgSprite:setPosition(320, 0)
    self.mParentLayer:addChild(tabBgSprite, 1)

    --------------------------------------------------------------------------------
    -- 显示顶部背景
    local topBgSize = cc.size(620, 110)
    local topBgNode = self:createTopInfo(topBgSize)
    topBgNode:setAnchorPoint(0.5, 1)
    topBgNode:setPosition(320, tabBgSize.height - 40)
    tabBgSprite:addChild(topBgNode)

    --------------------------------------------------------------------------------
    -- 中间背景
    local centerBgSize = cc.size(620, 460)
    local centerBgSprite = self:createCenterInfo(centerBgSize)
    centerBgSprite:setAnchorPoint(0.5, 1)
    centerBgSprite:setPosition(320, tabBgSize.height - 160)
    tabBgSprite:addChild(centerBgSprite)
    
    self.centerBgSprite = centerBgSprite
    self.centerBgSprite:refreshNode()

    --------------------------------------------------------------------------------
    -- 底部背景
    local bottomBgSize = cc.size(612, 300)
    local bottomBgSprite = self:createBottomInfo(bottomBgSize)
    bottomBgSprite:setAnchorPoint(0.5, 0)
    bottomBgSprite:setPosition(320, 120)
    tabBgSprite:addChild(bottomBgSprite)
    
    self.bottomBgSprite = bottomBgSprite
    self.bottomBgSprite:refreshNode()

    --------------------------------------------------------------------------------
    local tabLayer = ui.newTabLayer({
        btnInfos = tabBtnInfos,
        btnSize = cc.size(122, 56), 
        defaultSelectTag = self.defaultTag,
        needLine = false,
        onSelectChange = function (tag)
            self.defaultTag = tag
            self.centerBgSprite:refreshNode()
            self.bottomBgSprite:refreshNode()
            -- 通知选中Tab改变
            Notification:postNotification(EquipSelectTabChange)
        end
    })
    tabLayer:setAnchorPoint(cc.p(0.5, 0))
    tabLayer:setPosition(tabPos.x, tabPos.y + 10)
    self.mParentLayer:addChild(tabLayer)
    -- 保存按钮，引导使用
    self.equipTabLayer = tabLayer

    -- 添加标签小红点
    for i,v in ipairs(tabBtnInfos) do
        local eventNames = RedDotInfoObj:getEvents(v.moduleId)
        table.insert(eventNames, EventsName.eRedDotPrefix .. tostring(ModuleSub.eFormation))
        local function dealRedDotVisible(redDotSprite)
            redDotSprite:setVisible(RedDotInfoObj:isValid(v.moduleId))
        end
        ui.createAutoBubble({parent = tabLayer:getTabBtnByTag(v.tag), eventName = eventNames, refreshFunc = dealRedDotVisible})
    end

    -- 关闭按钮
    local mCloseBtn = ui.newButton({
        normalImage = "c_29.png",
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    local closeBtnPos = Enums.StardardRootPos.eCloseBtn
    mCloseBtn:setPosition(closeBtnPos.x, closeBtnPos.y + 50)
    self.mParentLayer:addChild(mCloseBtn)

    -- 规则按钮
    local ruleBtn = ui.newButton({
        normalImage = "c_72.png",
        position = cc.p(590, 400),
        clickAction = function()
            if self.defaultTag == ModuleSub.eEquipStarUp then
                MsgBoxLayer.addRuleHintLayer(TR("升星共鸣规则"),
                {
                    TR("1.橙色及橙色品质以上的装备才能触发升星共鸣"),
                    TR("2.所有上阵角色的同一部位装备都升星到特殊等级可以触发对应的升星共鸣"),
                    TR("3.红色0星的装备可被视为橙色5星，金色0星的装备可被视为红色5星"),
                    TR("4.装备可升星的最大等级受限于当前装备的强化等级"),
                })
            else
                MsgBoxLayer.addRuleHintLayer(TR("锻造共鸣规则"),
                {
                    TR("1.蓝色及蓝色品质以上的装备才能进行锻造"),
                    TR("2.所有上阵角色的同一部位装备都锻造到特殊等级时可以触发对应的锻造共鸣，每5级触发一次"),
                    TR("3.装备可锻造的最大等级受限于当前装备的强化等级"),
                })
            end
        end})
    self.mParentLayer:addChild(ruleBtn, 1)
end

-- 创建顶部的显示
function EquipMasterLayer:createTopInfo(topBgSize)
    local topBgNode = cc.Node:create()
    topBgNode:setContentSize(topBgSize)

    -- 显示装备按钮列表
    local equipConfigs = {
        {typeId = ResourcetypeSub.eClothes, posX = 50, image = "zb_20.png"},
        {typeId = ResourcetypeSub.eHelmet, posX = 154, image = "zb_19.png"},
        {typeId = ResourcetypeSub.ePants, posX = 258, image = "zb_15.png"},
        {typeId = ResourcetypeSub.eWeapon, posX = 362, image = "zb_17.png"},
        {typeId = ResourcetypeSub.eShoe, posX = 466, image = "zb_16.png"},
        {typeId = ResourcetypeSub.eNecklace, posX = 570, image = "zb_18.png"},
    }
    local tmpEquipButtons = {}
    for _,v in ipairs(equipConfigs) do
        -- 显示装备图片
        local btnEquip = ui.newButton({
            normalImage = v.image,
            scale = 0.95,
            clickAction = function()
                self.mResourcetypeSub = v.typeId
                for k,v in pairs(tmpEquipButtons) do
                    v.selectSprite:setVisible((k == self.mResourcetypeSub))
                end
                self.centerBgSprite:refreshNode()
                self.bottomBgSprite:refreshNode()
            end
        })
        btnEquip:setPosition(v.posX, topBgSize.height / 2)
        topBgNode:addChild(btnEquip)
        tmpEquipButtons[v.typeId] = btnEquip
        -- 添加按钮小红点
        local eventNames = {EquipSelectTabChange, EventsName.eRedDotPrefix .. tostring(ModuleSub.eFormation)}
        local function dealRedDotVisible(redDotSprite)
            local typeName = Utility.getEquipTypeString(v.typeId)
            if self.defaultTag == ModuleSub.eEquipStarUp then
                local starList = SlotPrefObj:haveSlotEquipCanStar()
                for k,v in pairs(starList) do
                    if k == typeName then
                        redDotSprite:setVisible(true)
                        return
                    end
                end
                redDotSprite:setVisible(false)
            elseif self.defaultTag == ModuleSub.eEquipStepUp then
                redDotSprite:setVisible(next(SlotPrefObj:haveSlotEquipCanStep()) == typeName)
            end
        end
        local sprite = ui.createAutoBubble({parent = btnEquip, eventName = eventNames, refreshFunc = dealRedDotVisible})
        sprite:setLocalZOrder(2)

        -- 添加选中框
        local btnSize = btnEquip:getContentSize()
        btnEquip.selectSprite = ui.newSprite("zb_03.png")
        btnEquip.selectSprite:setPosition(btnSize.width * 0.5, btnSize.height * 0.5)
        btnEquip.selectSprite:setVisible((self.mResourcetypeSub == v.typeId))
        btnEquip:addChild(btnEquip.selectSprite)

        -- 显示装备名字
        local titleLabel = ui.newLabel({
            text = ResourcetypeSubName[v.typeId],
            size = 22,
            color = cc.c3b(0xff, 0xff, 0xff),
            outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
            outlineSize = 2,
        })
        titleLabel:setPosition(btnSize.width * 0.5, 15)
        btnEquip:addChild(titleLabel)
    end

    return topBgNode
end

-- 创建中间的显示
function EquipMasterLayer:createCenterInfo(centerBgSize)
    local centerBgSprite = ui.newScale9Sprite("c_17.png", centerBgSize)
    local centerCellSize = cc.size(290, 130)
    local tmpCellPosList = {cc.p(160, 378), cc.p(460, 378), cc.p(160, 230), cc.p(460, 230), cc.p(160, 83), cc.p(460, 83)}

    -- 刷新接口
    centerBgSprite.refreshNode = function (target)
        target:removeAllChildren()
        target.nodeList = {}

        -- 构造数据
        for i=1,6 do
            local cellBgSprite = ui.newScale9Sprite("c_18.png", centerCellSize)
            cellBgSprite:setPosition(tmpCellPosList[i])
            target:addChild(cellBgSprite)
            target.nodeList[i] = cellBgSprite

            -- 显示头像
            local isSlotOpen = (FormationObj:getSlotInfoBySlotId(i) ~= nil)
            local isEquipEmpty = FormationObj:slotEquipIsEmpty(i, self.mResourcetypeSub)
            local tempEquip = FormationObj:getSlotEquip(i, self.mResourcetypeSub) or {}
            local cardClickFunc = nil
            if isEquipEmpty then
                cardClickFunc = function ()
                     if not isSlotOpen then
                        return
                    end
                    LayerManager.addLayer({name = "team.TeamSelectEquipLayer", data = {
                        slotId = i,
                        resourcetypeSub = self.mResourcetypeSub,
                        alwaysIdList = {},
                    }})
                end
            end
            local equipValueLv = nil
            local tempCard = CardNode:create({
                allowClick = true,
                onClickCallback = cardClickFunc
            })
            local tempSize = tempCard:getContentSize()
            tempCard:setPosition(60, 70)

            if isEquipEmpty then
                tempCard:setEmptyEquip({}, self.mResourcetypeSub)

                -- 判断是否显示锁定符号
                if not isSlotOpen then
                    local tempSprite = ui.newSprite("c_35.png")
                    tempSprite:setPosition(tempSize.width / 2, tempSize.height / 2)
                    tempCard:addChild(tempSprite)
                end
                
                -- 判断是否有可用装备
                local prefEquip = SlotPrefObj:havePreferableEquip(i)
                local havePref = (prefEquip and prefEquip[self.mResourcetypeSub]) and true or false
                if isSlotOpen and havePref then
                    tempCard:showGlitterAddMark("c_22.png", 1.2)
                end
            else
                local showAttrs = {CardShowAttr.eBorder}
                local equipBaseInfo = EquipModel.items[tempEquip.modelId] or {}
                equipValueLv = equipBaseInfo.valueLv

                if (self.defaultTag == ModuleSub.eEquipStarUp) then
                    table.insert(showAttrs, CardShowAttr.eStar)
                else
                    table.insert(showAttrs, CardShowAttr.eStep)
                end
                tempCard:setEquipment(EquipObj:getEquip(tempEquip.Id), showAttrs)
                if (self.defaultTag == ModuleSub.eEquipStarUp) then
                    local starCtrl = tempCard.mShowAttrControl[CardShowAttr.eStar]
                    if (starCtrl ~= nil) and (starCtrl.node ~= nil) then
                        starCtrl.node:setScale(0.6)
                        starCtrl.node:setLocalZOrder(99)
                    end
                end
            end
            cellBgSprite:addChild(tempCard)

            -- 显示装备人物
            local strHeroName = isSlotOpen and TR("暂未装备") or TR("卡槽未解锁")
            if not isEquipEmpty then
                local tempSlot = FormationObj:getSlotInfoBySlotId(i)
                local tempModel = HeroModel.items[tempSlot.ModelId]
                local tempHeroInfo = HeroObj:getHero(tempSlot.HeroId)
                local tempName = ConfigFunc:getHeroName(tempSlot.ModelId, {IllusionModelId = tempHeroInfo.IllusionModelId, heroFashionId = tempHeroInfo.CombatFashionOrder})
                strHeroName = TR("%s%s%s装备", Utility.getQualityColor(tempModel.quality, 2), tempName, "#46220D")
            end
            local nameLabel = ui.newLabel({
                text = strHeroName,
                size = 20,
                color = cc.c3b(0x46, 0x22, 0x0d),
            })
            nameLabel:setAnchorPoint(cc.p(0, 0.5))
            nameLabel:setPosition(120, 100)
            cellBgSprite:addChild(nameLabel)

            -- 判断条件
            if (self.defaultTag == ModuleSub.eEquipStarUp) and (equipValueLv ~= nil) and (equipValueLv < 4) then
                -- 如果是升星，且装备品质小于橙色
                local nameLabel = ui.newLabel({
                    text = TR("紫色或更高的装备才能升星"),
                    size = 18,
                    color = Enums.Color.eRed,
                    align = cc.TEXT_ALIGNMENT_LEFT,
                    valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
                    dimensions = cc.size(150, 0)
                })
                nameLabel:setAnchorPoint(cc.p(0, 1))
                nameLabel:setPosition(120, 70)
                cellBgSprite:addChild(nameLabel)
            elseif (self.defaultTag == ModuleSub.eEquipStepUp) and (equipValueLv ~= nil) and (equipValueLv < 3) then
                -- 如果是锻造，且装备品质小于蓝色
                local nameLabel = ui.newLabel({
                    text = TR("蓝色或更高的装备才能锻造"),
                    size = 18,
                    color = Enums.Color.eRed,
                    align = cc.TEXT_ALIGNMENT_LEFT,
                    valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
                    dimensions = cc.size(150, 0)
                })
                nameLabel:setAnchorPoint(cc.p(0, 1))
                nameLabel:setPosition(120, 70)
                cellBgSprite:addChild(nameLabel)
            else
                -- 显示操作按钮
                local btnTitle = TR("穿戴")
                if not isEquipEmpty then
                    btnTitle = (self.defaultTag == ModuleSub.eEquipStepUp) and TR("锻造") or TR("升星")
                end
                local tempBtn = ui.newButton({
                    normalImage = isEquipEmpty and "c_33.png" or "c_28.png",
                    text = btnTitle,
                    scale = 0.8,
                    clickAction = function()
                        if isEquipEmpty then
                            cardClickFunc()
                        else
                            local tempData = LayerManager.getRestoreData("team.TeamEquipLayer")
                            if (tempData ~= nil) then
                                -- 修改恢复参数
                                tempData.showIndex = i
                                tempData.defaultTag = self.defaultTag
                                tempData.resourcetypeSub = self.mResourcetypeSub
                                LayerManager.setRestoreData(tempData)
                                LayerManager.removeLayer(self)
                            else
                                -- 直接进入
                                LayerManager.addLayer({name = "team.TeamEquipLayer", data = {
                                    defaultTag = self.defaultTag,
                                    showIndex = i,
                                    resourcetypeSub = self.mResourcetypeSub,
                                }})
                            end
                        end
                    end
                })
                tempBtn:setAnchorPoint(cc.p(0, 0.5))
                tempBtn:setPosition(120, 30)
                tempBtn:setEnabled(isSlotOpen)
                cellBgSprite:addChild(tempBtn)

                -- 添加按钮小红点
                local eventNames = {EquipSelectTabChange, EventsName.eRedDotPrefix .. tostring(ModuleSub.eFormation)}
                local function dealRedDotVisible(redDotSprite)
                    local isFind = false
                    if not isEquipEmpty then
                        local typeName = Utility.getEquipTypeString(self.mResourcetypeSub)
                        if self.defaultTag == ModuleSub.eEquipStarUp then
                            local retList = SlotPrefObj:haveSlotEquipCanStar()
                            local retId = retList[typeName] or ""
                            if (retId == tempEquip.Id) then
                                isFind = true
                            end
                        elseif self.defaultTag == ModuleSub.eEquipStepUp then
                            local retList = SlotPrefObj:haveSlotEquipCanStep()
                            local retId = retList[typeName] or ""
                            if (retId == tempEquip.Id) then
                                isFind = true
                            end
                        end
                    end
                    redDotSprite:setVisible(isFind)
                end
                ui.createAutoBubble({parent = tempBtn, eventName = eventNames, refreshFunc = dealRedDotVisible})
            end
        end
    end
    
    -- 刷新状态的接口
    centerBgSprite.refreshStatus = function (target, list)
        -- 清空以前的状态
        for i=1,6 do
            local cell = target.nodeList[i]
            if (cell.statusLabel ~= nil) then
                cell.statusLabel:removeFromParent()
                cell.statusLabel = nil
            end
        end
        if (list == nil) then
            return
        end

        -- 显示新的状态
        for i=1,6 do
            local cell = target.nodeList[i]
            local str = list[i]
            if (str ~= nil) and (#str > 0) then
                local tempSprite = ui.createStrImgMark("c_57.png", str, Enums.Color.eWhite)
                local tempSize = tempSprite:getContentSize()
                tempSprite:setPosition(centerCellSize.width - tempSize.width / 2 - 1, centerCellSize.height - tempSize.height / 2 - 1)
                tempSprite:setRotation(90)
                cell:addChild(tempSprite, 1)
                cell.statusLabel = tempSprite
            end
        end
    end

    -- 刷新进度条
    centerBgSprite.refreshProgress = function (target, list)
        -- 清空以前的进度
        for i=1,6 do
            local cell = target.nodeList[i]
            if (cell.progressBar ~= nil) then
                cell.progressBar:removeFromParent()
                cell.progressBar = nil
            end
        end
        if (list == nil) then
            return
        end

        -- 显示新的进度
        for i=1,6 do
            local cell = target.nodeList[i]
            local item = list[i]
            if (item ~= nil) and (item.currValue ~= nil) then
                local progressBar = require("common.ProgressBar").new({
                    bgImage = "zb_21.png",
                    barImage = "zb_22.png",
                    currValue = item.currValue,
                    maxValue = item.maxValue,
                    needLabel = true,
                    percentView = false,
                    color = Enums.Color.eNormalWhite,
                    outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
                    barType = ProgressBarType.eHorizontal,
                    })
                progressBar:setAnchorPoint(cc.p(0, 0.5))
                progressBar:setPosition(115, 70)
                cell:addChild(progressBar)
                cell.progressBar = progressBar
            end
        end
    end

    return centerBgSprite
end

-- 创建底部的显示
function EquipMasterLayer:createBottomInfo(bottomBgSize)
    local bottomBgSprite = ui.newScale9Sprite("c_37.png", bottomBgSize)
    local bottomCellSize = cc.size(240, 180)

    -- 辅助接口：显示标题
    local function addTitle(parent, backSize, textSize, outColor, titleText)
        local titleLabel = ui.newLabel({
            text = titleText,
            size = textSize or 24,
            color = cc.c3b(0xfa, 0xf6, 0xf1),
            outlineColor = outColor,
            outlineSize = 2,
        })
        titleLabel:setPosition(backSize.width / 2, backSize.height - 22)
        parent:addChild(titleLabel)
    end
    
    -- 辅助接口：显示错误提示
    local function addErrorText(parent, pos, fontSize, errorText)
        local errorLabel = ui.newLabel({
            text = errorText,
            size = fontSize or 30,
            color = Enums.Color.eRed,
        })
        errorLabel:setPosition(pos)
        parent:addChild(errorLabel)
    end
    
    -- 辅助接口：显示属性框
    local function addBottomCell(xPos, title, level, config)
        local tmpBgSprite = ui.newScale9Sprite("c_54.png", bottomCellSize)
        tmpBgSprite:setAnchorPoint(cc.p(0, 0.5))
        tmpBgSprite:setPosition(xPos, 135)
        bottomBgSprite:addChild(tmpBgSprite)

        -- 显示标题
        addTitle(tmpBgSprite, bottomCellSize, 22, cc.c3b(0x8c, 0x48, 0x41), title)

        -- 判断是否已满级或尚未激活
        if (config == nil) then
            addErrorText(tmpBgSprite, cc.p(bottomCellSize.width * 0.5, 75), 25, ((level > 0) and TR("已满级") or TR("未激活")))
            return
        end

        -- 解析加成属性
        for _,v in ipairs(Utility.analyzeAttrAddString(config.totalAttrStr)) do
            local tempPosY = 40     -- 血量>攻击>防御
            if (v.attrKey == Fightattr.eHP) or (v.attrKey == Fightattr.eHPR) then
                tempPosY = 110
            elseif (v.attrKey == Fightattr.eAP) or (v.attrKey == Fightattr.eAPR) then
                tempPosY = 75
            end
            local tempLabel = ui.newLabel({
                text = TR("全体%s%s+%s", v.name, "#087E05", v.value) ,
                color = cc.c3b(0x46, 0x22, 0x0d),
                size = 22,
            })
            tempLabel:setAnchorPoint(cc.p(0, 0.5))
            tempLabel:setPosition(45, tempPosY)
            tmpBgSprite:addChild(tempLabel)
        end
    end

    -- 辅助接口：显示箭头
    local function addArrow(parent, pos)
        local arrowSprite = ui.newSprite("c_67.png")
        arrowSprite:setPosition(pos)
        parent:addChild(arrowSprite)
    end
    
    -- 临时的错误处理类
    local errorClass = {}
    errorClass.init = function (target)
        target.errorText = nil
        target.statusList = {}
    end
    errorClass.set = function (target, i, statusText, errText)
        target.statusList[i] = statusText
        if (target.errorText == nil) then
            target.errorText = errText
        end
    end
    errorClass.show = function (target)
        self.centerBgSprite:refreshStatus(target.statusList)
        if (target.errorText ~= nil) then
            addErrorText(bottomBgSprite, cc.p(bottomBgSize.width / 2, 135), 30, target.errorText)
            return true
        end
        return false
    end

    -- 刷新接口
    bottomBgSprite.refreshNode = function (target)
        target:removeAllChildren()

        -- 显示灰色背景图
        local tmpGraySprite = ui.newScale9Sprite("c_17.png", cc.size(bottomBgSize.width - 20, bottomBgSize.height - 70))
        tmpGraySprite:setAnchorPoint(0.5, 0.5)
        tmpGraySprite:setPosition(bottomBgSize.width * 0.5, 135)
        target:addChild(tmpGraySprite)

        -- 先判断是否上阵了6人
        errorClass:init()
        for i=1,6 do
            local slotInfo = FormationObj:getSlotInfoBySlotId(i)
            if (slotInfo == nil) or (not Utility.isEntityId(slotInfo.HeroId)) then
                errorClass:set(i, TR("未上阵"), TR("您上阵的侠客不足6人，无法共鸣"))
            end
        end
        if (errorClass:show()) then
            return
        end
        
        -- 判断是否穿戴了6件装备
        local equipTypeName = ResourcetypeSubName[self.mResourcetypeSub]
        errorClass:init()
        for i=1,6 do
            if FormationObj:slotEquipIsEmpty(i, self.mResourcetypeSub) then
                errorClass:set(i, TR("未穿戴"), TR("您穿戴的%s不足6件，无法共鸣", equipTypeName))
            end
        end
        if (errorClass:show()) then
            return
        end

        -- 读取6件装备的信息
        local allEquipInfos = {}
        for i=1,6 do
            local tmpEquipInfo = {}
            local equipSlotInfo = FormationObj:getSlotEquip(i, self.mResourcetypeSub)
            tmpEquipInfo.itemInfo = clone(EquipObj:getEquip(equipSlotInfo.Id))
            tmpEquipInfo.baseInfo = clone(EquipModel.items[equipSlotInfo.modelId])
            table.insert(allEquipInfos, tmpEquipInfo)
        end

        -- 判断品质是否满足
        errorClass:init()
        if (self.defaultTag == ModuleSub.eEquipStepUp) then
            for i,v in ipairs(allEquipInfos) do
                if (v.baseInfo.valueLv < 3) then
                    errorClass:set(i, nil, TR("激活锻造共鸣的装备品质不能低于蓝色"))
                end
            end
        else
            for i,v in ipairs(allEquipInfos) do
                if (v.baseInfo.valueLv < 5) then
                    errorClass:set(i, nil, TR("激活升星共鸣的装备品质不能低于橙色"))
                end
            end
        end
        if (errorClass:show()) then
            return
        end

        -- 处理属性显示
        local tmpTitle = ""
        local currLv, nextLv = 0, 0
        local currTitle, nextTitle = "", ""
        local currConfig, nextConfig = nil, nil
        local progressList = {}
        if (self.defaultTag == ModuleSub.eEquipStepUp) then
            -- 锻造共鸣
            local stepConfigs = {}
            for _,v in pairs(EquipStepTeamRelation.items) do
                table.insert(stepConfigs, clone(v))
            end
            table.sort(stepConfigs, function (a, b)
                    return a.Lv < b.Lv
                end)
            
            -- 找出当前最小的Step
            local maxNum = table.maxn(EquipStepTeamRelation.items)
            local minStep = EquipStepTeamRelation.items[maxNum].needStep
            for _,v in ipairs(allEquipInfos) do
                if (minStep > v.itemInfo.Step) then
                    minStep = v.itemInfo.Step
                end
            end

            -- 读取当前共鸣和下一共鸣
            currLv = 0
            for _,v in ipairs(stepConfigs) do
                if (minStep >= v.needStep) then
                    currLv = v.Lv
                end
            end
            nextLv = currLv + 1
            
            -- 显示标题
            currTitle, nextTitle = TR("锻造共鸣%d级", currLv), TR("锻造共鸣%d级", nextLv)
            currConfig, nextConfig = stepConfigs[currLv], stepConfigs[nextLv]
            if (nextConfig == nil) then
                nextTitle = TR("锻造共鸣已满级")
                tmpTitle = TR("%s的锻造共鸣已到最高", equipTypeName)
            else
                tmpTitle = TR("6件%s锻造到%d阶", equipTypeName, nextConfig.needStep)
            end

            -- 计算进度
            for i,v in ipairs(allEquipInfos) do
                if (nextConfig == nil) then
                    progressList[i] = {currValue=v.itemInfo.Step, maxValue=currConfig.needStep}
                else
                    local tmpMaxValue = nextConfig.needStep
                    local tmpCurValue = v.itemInfo.Step
                    progressList[i] = {currValue=tmpCurValue, maxValue=tmpMaxValue}
                end
            end
        else
            -- 读取配置
            local starConfigs = {}
            for _,v in pairs(EquipStarTeamRelation.items) do
                table.insert(starConfigs, clone(v))
            end
            table.sort(starConfigs, function (a, b)
                    return a.Lv < b.Lv
                end)

            -- 找出当前最小的ID
            local minId = table.maxn(EquipStarTeamRelation.items)
            for _,v in ipairs(allEquipInfos) do
                local tmpId = (v.baseInfo.valueLv * 100) + v.itemInfo.Star
                if (minId > tmpId) then
                    minId = tmpId
                end
            end

            -- 读取当前等级和下一等级
            currLv = 0
            for _,v in ipairs(starConfigs) do
                if (minId >= v.ID) then
                    currLv = v.Lv
                end
            end
            nextLv = currLv + 1

            -- 显示标题
            currTitle, nextTitle = TR("升星共鸣%d级", currLv), TR("升星共鸣%d级", nextLv)
            currConfig, nextConfig = starConfigs[currLv], starConfigs[nextLv]
            if (nextConfig == nil) then
                nextTitle = TR("升星共鸣已满级")
                tmpTitle = TR("%s的升星共鸣已到最高", equipTypeName)
            else
                tmpTitle = TR("6件%s%s%s品质的%s升到%d星", Utility.getColorValue(nextConfig.needValueLv, 2), Utility.getColorName(nextConfig.needValueLv), "#FAF6F1", equipTypeName, nextConfig.needStar)
            end

            -- 计算进度
            for i,v in ipairs(allEquipInfos) do
                if (nextConfig == nil) then
                    progressList[i] = {currValue=5, maxValue=5}
                else
                    local tmpCurValue = 0
                    local tmpMaxValue = 0
                    if (nextConfig.needValueLv == v.baseInfo.valueLv) then
                        tmpCurValue = v.itemInfo.Star
                        tmpMaxValue = nextConfig.needStar
                    elseif (nextConfig.needValueLv > v.baseInfo.valueLv) then
                        -- 这种情况说明当前装备已满星了，所以需求才会是下一阶段的品质
                        tmpCurValue = v.itemInfo.Star
                        tmpMaxValue = v.itemInfo.Star
                    else
                        -- 这种情况说明当前装备的品质较高，肯定满足当前的共鸣需求
                        local offset = (currConfig ~= nil) and currConfig.needValueLv or starConfigs[1].needValueLv
                        tmpCurValue = (v.baseInfo.valueLv - offset) * 5 + v.itemInfo.Star
                        tmpMaxValue = 1
                    end
                    progressList[i] = {currValue=tmpCurValue, maxValue=tmpMaxValue}
                end
            end
        end

        -- 显示标题、箭头、升级前后的属性、各个装备的状态
        addTitle(bottomBgSprite, bottomBgSize, nil, cc.c3b(0x47, 0x50, 0x54), tmpTitle)
        addArrow(target, cc.p(bottomBgSize.width * 0.5 - 5, 125))
        addBottomCell(25, currTitle, currLv, currConfig)
        addBottomCell(bottomBgSize.width - 265, nextTitle, nextLv, nextConfig)
        self.centerBgSprite:refreshProgress(progressList)
    end

    return bottomBgSprite
end

--- ============================ 页面恢复相关 ==========================
-- 获取恢复该页面的参数
function EquipMasterLayer:getRestoreData()
    local retData = {}
    retData.defaultTag = self.defaultTag
    retData.resourcetypeSub = self.mResourcetypeSub

    return retData
end

-- ========================== 新手引导 ===========================
function EquipMasterLayer:onEnterTransitionFinish()
    self:executeGuide()
end

function EquipMasterLayer:executeGuide()
    Guide.helper:executeGuide({
        -- 点击锻造按钮
        [11808]  = {clickNode = self.equipTabLayer:getTabBtnByTag(ModuleSub.eEquipStepUp)},
    })
end

return EquipMasterLayer