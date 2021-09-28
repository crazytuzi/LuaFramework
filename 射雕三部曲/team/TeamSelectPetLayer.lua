--[[
    文件名: TeamSelectPetLayer.lua
	描述: 队伍选择秘籍页面
	创建人: peiyaoqiang
    创建时间: 2017.03.08
--]]

local TeamSelectPetLayer = class("TeamSelectPetLayer", function(params)
    return display.newLayer()
end)

--[[
-- 参数 params中的每项为：
    {
        slotId: 需要上阵的卡槽Id，必选参数（0:表示出战秘籍卡槽；1-6:表示上阵人物卡槽）
        alwaysIdList: 始终包含的条目Id列表
        excludeModelIds = {}, -- 需要排除的模型Id
    }
--]]
function TeamSelectPetLayer:ctor(params)
    -- 需要上阵的卡槽Id
    self.mSlotId = params.slotId
    -- 始终包含的条目Id列表
    self.mAlwaysIdList = params.alwaysIdList
    --  需要排除的模型Id
    self.mExcludeModelIds = params.excludeModelIds or {}
    -- 卡槽上原来的秘籍
    self.mOldPet = FormationObj:getSlotPet(self.mSlotId)
    -- 所有已上阵的外功
    self.petSlotModelIdList = {}
    for i=1,6 do
        local tmpPet = FormationObj:getSlotPet(i)
        if (tmpPet ~= nil) and (tmpPet.Id ~= nil) then
            local tmpInfo = PetObj:getPet(tmpPet.Id)
            table.insert(self.petSlotModelIdList, tmpInfo.ModelId)
        end
    end

    -- 是否隐藏已上阵的外功秘籍
    self.mHideInFormation = true
    self.mPetInfos = {}

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
function TeamSelectPetLayer:initUI()
    -- 背景图片
	local bgSprite = ui.newSprite("c_34.jpg")
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)

    local tempSprite = ui.newScale9Sprite("c_17.png", cc.size(620, 890))
    tempSprite:setAnchorPoint(cc.p(0.5, 1))
    tempSprite:setPosition(320, 1000)
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
function TeamSelectPetLayer:createListView()
    -- 空列表提示
    self.mEmptyHintSprite = ui.createEmptyHint(TR("没有可以选择的外功秘籍"))
    self.mEmptyHintSprite:setPosition(320, 568)
    self.mParentLayer:addChild(self.mEmptyHintSprite)
    self.mToGetBtn = ui.newButton({
        text = TR("去获取"),
        normalImage = "c_28.png",
        fontSize = 21,
        clickAction = function ()
            if not ModuleInfoObj:moduleIsOpen(ModuleSub.eExpedition, true) then
                return
            end
            LayerManager.showSubModule(ModuleSub.eExpedition)
        end
        })
    self.mToGetBtn:setPosition(320, 400)
    self.mParentLayer:addChild(self.mToGetBtn, 10)

    --
    self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setContentSize(cc.size(640, 880))
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
        text = TR("隐藏已上阵的外功秘籍"),
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
function TeamSelectPetLayer:refreshList()
    self.mListView:removeAllItems()

    self.mPetInfos = clone(PetObj:getPetList({
        notInFormation = self.mHideInFormation, -- 是否需要过滤掉上阵的人物，默认为false
        alwaysIdList = self.mAlwaysIdList, -- 始终包含的条目Id列表
    }))

    -- 整理秘籍的其他信息
    local statusMap = {}
    for _, petInfo in ipairs(self.mPetInfos) do
        local tempModelId = petInfo.ModelId
        -- 秘籍模型信息
        if not petInfo.modelData then
            petInfo.modelData = PetModel.items[tempModelId]
        end
        -- 可激活的状态, 已获取过的就不在计算了
        petInfo.relationStatus = statusMap[tempModelId]
        if not petInfo.relationStatus then
            petInfo.relationStatus = FormationObj:getRelationStatus(tempModelId, ResourcetypeSub.ePet, self.mSlotId)
            statusMap[tempModelId] = petInfo.relationStatus
        end

        -- 秘籍上阵状态
        if not petInfo.status then
            local inFormation, slotId = FormationObj:petInFormation(petInfo.Id)
            petInfo.status = {
                inFormation = inFormation,
                slotId = slotId
            }
        end
    end
    -- 排序
    local oldPetId = self.mOldPet and self.mOldPet.Id
    if (oldPetId == nil) then
        oldPetId = ""
    end
    table.sort(self.mPetInfos, function(item1, item2)
        if (item1.Id == oldPetId) then
            return true
        elseif (item2.Id == oldPetId) then
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
        if item1.status.inFormation ~= item2.status.inFormation then
            if item1.status.inFormation then
                return true
            else
                return false
            end
        end

        -- 比较等级
        if item1.Lv ~= item2.Lv then
            return item1.Lv > item2.Lv
        end

        return item1.modelData.ID < item2.modelData.ID
    end)

    -- 是否有同名的外功秘籍
    local function isHaveSameModel(modelid)
        local retHave = false
        for _,v in ipairs(self.petSlotModelIdList) do
            if (v == modelid) then
                retHave = true
                break
            end
        end
        return retHave
    end

    -- 指定外功秘籍是否已经上阵
    local function isPetInSlot(petId)
        local haveSlot = false
        for i=1,6 do
            local tmpPet = FormationObj:getSlotPet(i)
            if (tmpPet ~= nil) and (tmpPet.Id ~= nil) and (tmpPet.Id == petId) then
                haveSlot = true
                break
            end
        end
        return haveSlot
    end

    --
    local cellSize = cc.size(640, 128)
    for index, petInfo in ipairs(self.mPetInfos) do
        local lvItem = ccui.Layout:create()
        lvItem:setContentSize(cellSize)
        self.mListView:pushBackCustomItem(lvItem)
        --
        local tempSprite = ui.newScale9Sprite("c_18.png", cc.size(600, 120))
        tempSprite:setPosition(cellSize.width / 2, cellSize.height / 2)
        lvItem:addChild(tempSprite)

        -- 秘籍的模型
        local tempModel = PetModel.items[petInfo.ModelId]

        -- 创建秘籍头像
        local tempCard = CardNode.createCardNode({
            cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eLevel, CardShowAttr.eStep},
            resourceTypeSub = ResourcetypeSub.ePet,
            instanceData = petInfo,
            allowClick = true, --是否可点击
        })
        tempCard:setPosition(80, cellSize.height / 2)
        lvItem:addChild(tempCard)

        -- 秘籍的名字
        local tempLabel = ui.newLabel({
            text = tempModel.name,
            color = Utility.getQualityColor(tempModel.quality, 1),
            size = 24,
            outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
            outlineSize = 2,
            align = cc.TEXT_ALIGNMENT_LEFT,
            valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
        })
        tempLabel:setAnchorPoint(cc.p(0, 0.5))
        tempLabel:setPosition(140, cellSize.height / 2 + 30)
        lvItem:addChild(tempLabel)


        local petAttrInfo = Utility.getPetAttrs(PetObj:getPet(petInfo.Id))
        local tempToPercent = {}
        for k,v in pairs(petAttrInfo) do
            table.insert(tempToPercent, k , v)
            local needPercent = ConfigFunc:fightAttrIsPercentByValue(k)
            if needPercent then
                local tempV = tostring(tonumber(v) / 100) .. "%"
                table.insert(tempToPercent, k , tempV)
            end
        end

        local attrLabelList = {}
        local startPosX = 140
        local startPosY = 60
        for i,v in pairs(tempToPercent) do
            local attrLabel = ui.newLabel({
                text = string.format("%s +%s%s",FightattrName[i], Enums.Color.eDarkGreenH, v),
                color = Enums.Color.eBlack,
                size = 18,
                })
            attrLabel:setAnchorPoint(0, 0.5)
            table.insert(attrLabelList, attrLabel)
            lvItem:addChild(attrLabel)
        end

        for i,v in ipairs(attrLabelList) do
            if i%3 == 1 then
                startPosX  = 140
                if i ~= 1 then
                    startPosY =  startPosY - 25*(math.floor(i/3))
                end
            elseif i%3 == 2 then
                startPosX  = startPosX + 120
            elseif i%3 == 0 then
                startPosX  = startPosX + 120
            end
            v:setPosition(startPosX, startPosY)
        end

        local inFormation = petInfo.status.inFormation
        if inFormation and (petInfo.status.slotId ~= 0) then
            local slotInfo = FormationObj:getSlotInfoBySlotId(petInfo.status.slotId)
            local tempHero = HeroObj:getHero(slotInfo.HeroId)
            local tempName = ConfigFunc:getHeroName(slotInfo.ModelId, {IllusionModelId = tempHero.IllusionModelId, heroFashionId = tempHero.CombatFashionOrder})
            local tempStr = TR("[装备于%s%s%s]", Enums.Color.eNormalGreenH, tempName, Enums.Color.eBrownH)
            local tempLabel = ui.newLabel({
                text = tempStr,
                color = Enums.Color.eBrown,
                align = cc.TEXT_ALIGNMENT_CENTER,
            })
            tempLabel:setAnchorPoint(cc.p(0.5, 0.5))
            tempLabel:setPosition(530, cellSize.height / 2 + 30)
            lvItem:addChild(tempLabel)
        end

        -- 判断是否可以激活
        if petInfo.relationStatus == Enums.RelationStatus.eTriggerPr then
            local tempSprite = ui.createStrImgMark("c_62.png", TR("可激活"), Enums.Color.eWhite)
            local tempSize = tempSprite:getContentSize()
            tempSprite:setPosition(620 - tempSize.width / 2 - 1, 124 - tempSize.height / 2 - 1)
            tempSprite:setRotation(90)
            lvItem:addChild(tempSprite, 1)
        end

        -- 选择按钮
        local oldPetId = self.mOldPet and self.mOldPet.Id
        local tempBtn = ui.newButton({
            text = (oldPetId == petInfo.Id) and TR("卸下") or TR("选择"),
            normalImage = (oldPetId == petInfo.Id) and "c_33.png" or "c_28.png",
            clickAction = function()
                if (oldPetId ~= petInfo.Id) and (isHaveSameModel(petInfo.ModelId) == true) and (isPetInSlot(petInfo.Id) == false) then
                    ui.showFlashView(TR("同名的外功秘籍已经上阵"))
                    return
                end
                self:requestPetCombat(petInfo)
            end
        })
        tempBtn:setPosition(545, inFormation and (cellSize.height / 2 - 15) or (cellSize.height / 2))
        lvItem:addChild(tempBtn)
    end

    self.mEmptyHintSprite:setVisible(next(self.mPetInfos) == nil)
    self.mToGetBtn:setVisible(next(self.mPetInfos) == nil)
end

-- ================= 服务器请求相关函数 =================
-- 上阵秘籍
function TeamSelectPetLayer:requestPetCombat(petInfo)
    -- 空字符串的卡槽表示不变；EMPTY_ENTITY_ID的卡槽表示卸下；有有效Id的卡槽标上上阵
    local oldPetId = self.mOldPet and self.mOldPet.Id
    local commbatId = oldPetId == petInfo.Id and EMPTY_ENTITY_ID or petInfo.Id
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Pet",
        methodName = "PetCombat",
        svrMethodData = {self.mSlotId, commbatId},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then --
                return
            end

            LayerManager.removeLayer(self)
        end,
    })
end

return TeamSelectPetLayer
