--[[
    文件名: TeamSelectZhenyuanLayer.lua
	描述: 队伍选择真元页面
	创建人: peiyaoqiang
	创建时间: 2017.4.4
--]]

local TeamSelectZhenyuanLayer = class("TeamSelectZhenyuanLayer", function(params)
    return display.newLayer()
end)

--[[
-- 参数 params中的每项为：
    {
        slotId: 需要上阵的卡槽Id，必选参数
        currZhenyuanIndex: 当前的真元位置索引
    }
--]]
function TeamSelectZhenyuanLayer:ctor(params)
    -- 需要上阵的卡槽Id
    self.mSlotId = params.slotId
    -- 当前侠客的真元卡槽ID
    self.mZhenyuanSlotId = params.currZhenyuanIndex
    -- 卡槽上原来的真元
    self.mOldZhenyuan = FormationObj:getSlotZhenyuan(self.mSlotId, self.mZhenyuanSlotId)

    -- 是否隐藏已上阵真元
    self.mHideInFormation = true
    -- 需要显示的真元列表
    self.mZhenyuanInfos = {}

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
function TeamSelectZhenyuanLayer:initUI()
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
function TeamSelectZhenyuanLayer:createListView()
    -- 空列表提示
    local mEmptyHintSprite = ui.createEmptyHint(TR("没有可以选择的真元"))
    mEmptyHintSprite:setPosition(320, 568)
    self.mParentLayer:addChild(mEmptyHintSprite)
    self.mEmptyHintSprite = mEmptyHintSprite

    -- 去获取按钮
    local getBtn = ui.newButton({
           normalImage = "c_28.png",
           text = TR("去获取"),
           clickAction = function ()
               LayerManager.addLayer({name = "zhenyuan.ZhenYuanTabLayer", data = {}})
           end
       })
    getBtn:setPosition(320, 300)
    self.mParentLayer:addChild(getBtn)
    self.getBtn = getBtn

    --
    local mListView = ccui.ListView:create()
    mListView:setDirection(ccui.ScrollViewDir.vertical)
    mListView:setBounceEnabled(true)
    mListView:setContentSize(cc.size(640, 890))
    mListView:setPosition(cc.p(0, 115))
    self.mParentLayer:addChild(mListView)
    self.mListView = mListView
    
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
        text = TR("隐藏已上阵的真元"),
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

-- 刷新真元数据
function TeamSelectZhenyuanLayer:refreshZhenyuanData()
    -- 获取需要显示的真元
    self.mZhenyuanInfos = clone(ZhenyuanObj:getZhenyuanList({
    	alwaysIdList = ((self.mOldZhenyuan ~= nil) and (self.mOldZhenyuan.Id ~= nil)) and {self.mOldZhenyuan.Id} or {},
        notInFormation = self.mHideInFormation,
        minType = self.mZhenyuanSlotId == 7 and 7 or 1,  -- 天命真元type在7-9之间
        maxType = self.mZhenyuanSlotId == 7 and 9 or 6,
    }))

    -- 整理真元的其他信息
    for _, item in ipairs(self.mZhenyuanInfos) do
        local tempModelId = item.ModelId
        -- 装备模型信息
        if not item.modelData then
            item.modelData = ZhenyuanModel.items[tempModelId]
        end

        -- 是否已有同类真元上阵
        item.isCombatInOther = self:isCombatInOterIdx(item.modelData.type, self.mZhenyuanSlotId)
        
        -- 真元上阵状态
        if not item.status then
            local inFormation, slotId = FormationObj:zhenyuanInFormation(item.Id)
            item.status = {
                inFormation = inFormation,
                slotId = slotId
            }
        end
    end
    
    -- 排序
    local oldZhenyuanId = ((self.mOldZhenyuan ~= nil) and (self.mOldZhenyuan.Id ~= nil)) and self.mOldZhenyuan.Id or ""
    table.sort(self.mZhenyuanInfos, function(item1, item2)
        if (item1.Id == oldZhenyuanId) then
            return true
        elseif (item2.Id == oldZhenyuanId) then
            return false
        end

        -- 已有同类上阵的放在最后
        if (item1.isCombatInOther ~= item2.isCombatInOther) then
            return (item1.isCombatInOther == false)
        end

        -- 已上阵的放到后面
        if item1.status.inFormation ~= item2.status.inFormation then
            return (item1.status.inFormation == false)
        end

        -- 比较资质
        if item1.modelData.quality ~= item2.modelData.quality then
            return item1.modelData.quality > item2.modelData.quality
        end

        -- 比较模型ID
        return item1.ModelId < item2.ModelId
    end)
end

-- 重新刷新列表数据显示
function TeamSelectZhenyuanLayer:refreshList()
    -- 刷新显示数据
    self:refreshZhenyuanData()

    -- 刷新列表
    local isEmpty = (next(self.mZhenyuanInfos) == nil)
    self.mListView:removeAllItems()
    self.mListView:setVisible(not isEmpty)
    self.mEmptyHintSprite:setVisible(isEmpty)
    self.getBtn:setVisible(isEmpty)
    
    --
    local cellSize = cc.size(640, 128)
    for index, item in ipairs(self.mZhenyuanInfos) do
        local lvItem = ccui.Layout:create()
        lvItem:setContentSize(cellSize)
        self.mListView:pushBackCustomItem(lvItem)
        
        --
        local tempSprite = ui.newScale9Sprite("c_18.png", cc.size(600, 120))
        tempSprite:setPosition(cellSize.width / 2, cellSize.height / 2)
        lvItem:addChild(tempSprite)

        -- 真元头像
        local tempCard = CardNode.createCardNode({
            cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eLevel},
            resourceTypeSub = ResourcetypeSub.eZhenYuan,
            instanceData = item,
            allowClick = true, --是否可点击
        })
        tempCard:setPosition(100, cellSize.height / 2)
        lvItem:addChild(tempCard)

        -- 真元的名字
        local tempLabel = ui.newLabel({
            text = item.modelData.name,
            color = Utility.getQualityColor(item.modelData.quality, 1),
            outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
            size = 24,
        })
        tempLabel:setAnchorPoint(cc.p(0, 0.5))
        tempLabel:setPosition(165, cellSize.height / 2 + 25)
        lvItem:addChild(tempLabel)

        -- 属性等字符串
        local function addTmpLabel(strText, hColor, pos)
            local label = ui.newLabel({
                text = strText,
                color = hColor or Enums.Color.eBrown,
            })
            label:setAnchorPoint(cc.p(0, 0.5))
            label:setPosition(pos)
            lvItem:addChild(label)
        end

        -- 真元的资质和类型
        addTmpLabel(TR("资质: %s%d", Enums.Color.eDarkGreenH, item.modelData.quality), nil, cc.p(165, cellSize.height / 2 - 7))
        addTmpLabel(TR("类型: %s%s", Enums.Color.eDarkGreenH, item.modelData.type), nil, cc.p(300, cellSize.height / 2 - 7))
        
        -- 显示加成属性
        local tmpList = {}
        local attrList = ConfigFunc:getZhenyuanLvAttr(item.ModelId, item.Lv)
        for _,v in ipairs(attrList) do
            table.insert(tmpList, string.format("%s%s+%s", FightattrName[v.fightattr], Enums.Color.eNormalGreenH, v.value))
        end
        addTmpLabel(table.concat(tmpList, Enums.Color.eBrownH .. ", "), nil, cc.p(165, cellSize.height / 2 - 35))
        
        -- 显示提示文字
        local infoText = nil
        if item.status.inFormation then
            local slotInfo = FormationObj:getSlotInfoBySlotId(item.status.slotId)
            local tempHero = HeroObj:getHero(slotInfo.HeroId)
            local tempName = ConfigFunc:getHeroName(slotInfo.ModelId, {IllusionModelId = tempHero.IllusionModelId, heroFashionId = tempHero.CombatFashionOrder})
            infoText = TR("[装备于%s%s%s]", Enums.Color.eNormalGreenH, tempName, Enums.Color.eBrownH)
        elseif item.isCombatInOther then
            infoText = Enums.Color.eRedH .. TR("[同类型已上阵]")
        end
        if (infoText ~= nil) then
            local tempLabel = ui.newLabel({
                text = infoText,
                color = Enums.Color.eBrown,
            })
            tempLabel:setAnchorPoint(cc.p(0.5, 0.5))
            tempLabel:setPosition(510, cellSize.height / 2 + 30)
            lvItem:addChild(tempLabel)
        end

        -- 选择按钮
        local oldZhenyuanId = ((self.mOldZhenyuan ~= nil) and (self.mOldZhenyuan.Id ~= nil)) and self.mOldZhenyuan.Id or ""
        local tempBtn = ui.newButton({
            text = (oldZhenyuanId == item.Id) and TR("卸下") or TR("选择"),
            normalImage = (oldZhenyuanId == item.Id) and "c_33.png" or "c_28.png",
            clickAction = function()
                if item.isCombatInOther then
                    ui.showFlashView(TR("已有相同类型的真元上阵"))
                    return
                end
                self:requestZhenyuanCombat(item)
            end
        })
        tempBtn:setPosition(510, (cellSize.height / 2 - 15))
        lvItem:addChild(tempBtn)
    end
end

-- 判断某个类型的装备是否在其他位置已经上阵
function TeamSelectZhenyuanLayer:isCombatInOterIdx(currType, currIndex)
    local ret = false
    local slotInfo = FormationObj:getSlotInfoBySlotId(self.mSlotId)
    for i,v in ipairs(slotInfo.ZhenYuan) do
        if (i ~= currIndex) and (v.ModelId ~= nil) and (v.ModelId > 0) and (currType == ZhenyuanModel.items[v.ModelId].type) then
            ret = true
            break
        end
    end
    return ret
end

-- ======================== 服务器数据请求相关函数 =======================
-- 更换装备数据请求
function TeamSelectZhenyuanLayer:requestZhenyuanCombat(newZhenyuan)
    local oldZhenyuanId = ((self.mOldZhenyuan ~= nil) and (self.mOldZhenyuan.Id ~= nil)) and self.mOldZhenyuan.Id or ""
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Slot",
        methodName = "ZhenyuanCombat",
        svrMethodData = {self.mSlotId, self.mZhenyuanSlotId, ((oldZhenyuanId == newZhenyuan.Id) and EMPTY_ENTITY_ID or newZhenyuan.Id)},
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

return TeamSelectZhenyuanLayer
