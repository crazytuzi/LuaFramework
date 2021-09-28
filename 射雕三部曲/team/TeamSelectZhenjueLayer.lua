--[[
    文件名: TeamSelectZhenjueLayer.lua
	描述: 队伍选择内功心法页面
	创建人: peiyaoqiang
	创建时间: 2017.4.4
--]]

local TeamSelectZhenjueLayer = class("TeamSelectZhenjueLayer", function(params)
    return display.newLayer()
end)

--[[
-- 参数 params中的每项为：
    {
        slotId: 需要上阵的卡槽Id，必选参数
        zhenjueSlotId: 内功心法卡槽Id
        alwaysIdList: 始终包含的条目Id列表
    }
--]]
function TeamSelectZhenjueLayer:ctor(params)
    -- 需要上阵的卡槽Id
    self.mSlotId = params.slotId
    -- 内功心法卡槽Id
    self.mZhenjueSlotId = params.zhenjueSlotId
    -- 始终包含的条目Id列表
    self.mAlwaysIdList = params.alwaysIdList

    -- 卡槽上原来的内功心法
    self.mOldZhenjue = FormationObj:getSlotZhenjue(self.mSlotId, self.mZhenjueSlotId)
    -- 需要排除的模型Id
    self.mExcludeModelIdList = {}
    for zhenjueSlotId, item in pairs(FormationObj:getSlotZhenjue(self.mSlotId)) do
        if zhenjueSlotId ~= self.mZhenjueSlotId and Utility.isEntityId(item.Id) then
            table.insert(self.mExcludeModelIdList, item.ModelId)
        end
    end

    -- 是否隐藏已上阵内功心法
    self.mHideInFormation = true
    -- 需要显示的内功心法列表
    self.mZhenjueInfos = {}

	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

	-- 初始化页面控件
	self:initUI()

	-- 创建底部导航和顶部玩家信息部分
	local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(tempLayer)
end

-- 初始化页面控件
function TeamSelectZhenjueLayer:initUI()
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
function TeamSelectZhenjueLayer:createListView()
    -- 空列表提示
    self.mEmptyHintSprite = ui.createEmptyHint(TR("没有可以选择的内功心法"))
    self.mEmptyHintSprite:setPosition(320, 568)
    self.mParentLayer:addChild(self.mEmptyHintSprite)
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
        text = TR("隐藏已上阵的内功心法"),
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

-- 刷新内功心法数据
function TeamSelectZhenjueLayer:refreshZhenjueData()
    -- 获取需要显示的内功心法
    self.mZhenjueInfos = clone(ZhenjueObj:getZhenjueList({
    	alwaysIdList = self.mAlwaysIdList,
        excludeModelIdList = self.mExcludeModelIdList,
        notInFormation = self.mHideInFormation,
        typeId = FormationObj:getZhenjueSlotType(self.mZhenjueSlotId)
    }))

    -- 整理内功心法的其他信息
    local statusMap = {}
    for _, item in ipairs(self.mZhenjueInfos) do
        local tempModelId = item.ModelId
        -- 装备模型信息
        if not item.modelData then
            item.modelData = ZhenjueModel.items[tempModelId]
        end
        -- 可激活的状态, 已获取过的就不在计算了
        item.relationStatus = statusMap[tempModelId]
        if not item.relationStatus then
            item.relationStatus = FormationObj:getRelationStatus(tempModelId, ResourcetypeSub.eNewZhenJue, self.mSlotId)
            statusMap[tempModelId] = item.relationStatus
        end

        -- 内功心法上阵状态
        if not item.status then
            local inFormation, slotId = FormationObj:zhenjueInFormation(item.Id)
            item.status = {
                inFormation = inFormation,
                slotId = slotId
            }
        end
    end

    -- 排序
    local oldZhenjueId = self.mOldZhenjue and self.mOldZhenjue.Id
    if (oldZhenjueId == nil) then
        oldZhenjueId = ""
    end
    table.sort(self.mZhenjueInfos, function(item1, item2)
        if (item1.Id == oldZhenjueId) then
            return true
        elseif (item2.Id == oldZhenjueId) then
            return false
        end

        -- 已进阶的最前
        local nStep1 = item1.Step or 0
        local nStep2 = item2.Step or 0
        if (nStep1 ~= nStep2) then
            return nStep1 > nStep2
        end

        -- 比较资质
        if item1.modelData.colorLV ~= item2.modelData.colorLV then
            return item1.modelData.colorLV > item2.modelData.colorLV
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

        -- 比较模型ID
        if item1.ModelId ~= item2.ModelId then
            return item1.ModelId < item2.ModelId
        end

        return false
    end)
end

-- 重新刷新列表数据显示
function TeamSelectZhenjueLayer:refreshList()
    self.mListView:removeAllItems()
    --
    self:refreshZhenjueData()

    local cellSize = cc.size(640, 128)
    for index, item in ipairs(self.mZhenjueInfos) do
        local lvItem = ccui.Layout:create()
        lvItem:setContentSize(cellSize)
        self.mListView:pushBackCustomItem(lvItem)
        --
        local tempSprite = ui.newScale9Sprite("c_18.png", cc.size(600, 120))
        tempSprite:setPosition(cellSize.width / 2, cellSize.height / 2)
        lvItem:addChild(tempSprite)

        -- 创内功心法备头像
        local tempCard = CardNode.createCardNode({
            cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eStep},
            resourceTypeSub = ResourcetypeSub.eNewZhenJue,
            instanceData = item,
            allowClick = true, --是否可点击
        })
        tempCard:setPosition(100, cellSize.height / 2)
        lvItem:addChild(tempCard)

        -- 内功心法的名字
        local tempLabel = ui.newLabel({
            text = item.modelData.name,
            color = Utility.getColorValue(item.modelData.colorLV, 1),
            outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
            size = 24,
            align = cc.TEXT_ALIGNMENT_LEFT,
            valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
        })
        tempLabel:setAnchorPoint(cc.p(0, 0.5))
        tempLabel:setPosition(165, cellSize.height / 2 + 25)
        lvItem:addChild(tempLabel)

        -- 内功心法的资质
        local tempLabel = ui.newLabel({
            text = TR("资质: %s%d", Enums.Color.eDarkGreenH, item.modelData.colorLV),
            color = Enums.Color.eBrown,
            align = cc.TEXT_ALIGNMENT_LEFT,
        })
        tempLabel:setAnchorPoint(cc.p(0, 0.5))
        tempLabel:setPosition(165, cellSize.height / 2 - 25)
        lvItem:addChild(tempLabel)

        -- 内功心法的类型
        local tempInfo = Utility.getZhenjueViewInfo(item.modelData.typeID)
        local tempLabel = ui.newLabel({
            text = TR("类型: %s%s", Enums.Color.eDarkGreenH, tempInfo.typeName),
            color = Enums.Color.eBrown,
            align = cc.TEXT_ALIGNMENT_LEFT,
        })
        tempLabel:setAnchorPoint(cc.p(0, 0.5))
        tempLabel:setPosition(300, cellSize.height / 2 - 25)
        lvItem:addChild(tempLabel)

        if item.status.inFormation then
            local slotInfo = FormationObj:getSlotInfoBySlotId(item.status.slotId)
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
        if item.relationStatus == Enums.RelationStatus.eTriggerPr then
            local tempSprite = ui.createStrImgMark("c_62.png", TR("可激活"), Enums.Color.eWhite)
            local tempSize = tempSprite:getContentSize()
            tempSprite:setPosition(620 - tempSize.width / 2 - 1, 124 - tempSize.height / 2 - 1)
            tempSprite:setRotation(90)
            lvItem:addChild(tempSprite, 1)
        end

        -- 选择按钮
        local oldZhenjueId = self.mOldZhenjue and self.mOldZhenjue.Id
        local tempBtn = ui.newButton({
            text = (oldZhenjueId == item.Id) and TR("卸下") or TR("选择"),
            normalImage = (oldZhenjueId == item.Id) and "c_33.png" or "c_28.png",
            clickAction = function()
                self:requestOneKeyZhenjueCombat(item)
            end
        })
        tempBtn:setPosition(510, item.status.inFormation and (cellSize.height / 2 - 15) or (cellSize.height / 2))
        lvItem:addChild(tempBtn)
    end

    self.mEmptyHintSprite:setVisible(next(self.mZhenjueInfos) == nil)
end

-- ======================== 服务器数据请求相关函数 =======================
-- 更换装备数据请求
function TeamSelectZhenjueLayer:requestOneKeyZhenjueCombat(newZhenjue)
    local oldZhenjueId = self.mOldZhenjue and self.mOldZhenjue.Id
    local tempData = {
    	self.mSlotId,
    	{[tostring(self.mZhenjueSlotId)] = (oldZhenjueId == newZhenjue.Id) and EMPTY_ENTITY_ID or newZhenjue.Id}
	}
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Slot",
        methodName = "OneKeyZhenjueCombat",
        svrMethodData = tempData,
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then --
                return
            end

            --
            LayerManager.removeLayer(self)
        end,
    })
end

return TeamSelectZhenjueLayer
