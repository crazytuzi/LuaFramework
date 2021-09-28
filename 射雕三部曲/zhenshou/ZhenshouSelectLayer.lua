--[[
    文件名: ZhenshouSelectLayer.lua
	描述: 珍兽选择上阵页面
	创建人: lengjiazhi
    创建时间: 2018.11.28
--]]

local ZhenshouSelectLayer = class("ZhenshouSelectLayer", function(params)
    return display.newLayer()
end)

--[[
-- 参数 params中的每项为：
    {
        slotId: 需要上阵的卡槽Id，必选参数
        
    }
--]]
function ZhenshouSelectLayer:ctor(params)
    -- 需要上阵的卡槽Id
    self.mSlotId = params.slotId
   
    -- 是否隐藏已上阵人物
    self.mHideInFormation = true
    self.mZhenshouInfo = {}

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

    -- 执行新手引导
    Utility.performWithDelay(self, function ( ... )
        self:executeGuide()
    end, 0.01)
end

-- 初始化页面控件
function ZhenshouSelectLayer:initUI()
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
function ZhenshouSelectLayer:createListView()
    -- 空列表提示
    self.mEmptyHintSprite = ui.createEmptyHint(TR("没有可以选择的珍兽"))
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
               self:createGetPop()
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
        text = TR("隐藏已上阵珍兽"),
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
function ZhenshouSelectLayer:refreshList()
    self.mListView:removeAllItems()

    self.mZhenshouInfo = clone(ZhenshouObj:getZhenshouList({
        notInFormation = self.mHideInFormation,
        }))

    -- 整理人物的其他信息
    local statusMap = {}
    for _, zhenshouInfo in ipairs(self.mZhenshouInfo) do
        -- 人物模型信息
        if not zhenshouInfo.modelData then
            zhenshouInfo.modelData = ZhenshouModel.items[zhenshouInfo.ModelId]
        end
    end

    -- 排序
    table.sort(self.mZhenshouInfo, function(item1, item2)
        -- 比较上阵状态
        if item1.IsCombat ~= item2.IsCombat then
            if item1.IsCombat then
                return true
            else
                return false
            end
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
    for index, zhenshouInfo in ipairs(self.mZhenshouInfo) do
        local lvItem = ccui.Layout:create()
        lvItem:setContentSize(cellSize)
        self.mListView:pushBackCustomItem(lvItem)
        -- 子条目背景
        local tempSprite = ui.newScale9Sprite("c_18.png", cc.size(600, 120))
        tempSprite:setPosition(cellSize.width / 2, cellSize.height / 2)
        lvItem:addChild(tempSprite)

        -- 人物的模型
        local tempModel = ZhenshouModel.items[zhenshouInfo.ModelId]

        -- 创建人物头像
        local tempCard = CardNode.createCardNode({
            cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eStep},
            instanceData = zhenshouInfo,
            allowClick = true, --是否可点击
        })
        tempCard:setPosition(100, cellSize.height / 2)
        lvItem:addChild(tempCard)

        -- 人物的名字
        local tempName = tempModel.name
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
            text = TR("等级: %s%d", "#D77600", zhenshouInfo.Lv),
            color = cc.c3b(0x41, 0x1c, 0x00),
            align = cc.TEXT_ALIGNMENT_LEFT,
            valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
        })
        tempLabel:setAnchorPoint(cc.p(0, 0.5))
        tempLabel:setPosition(325, cellSize.height / 2 - 25)
        lvItem:addChild(tempLabel)

        -- 状态信息
        local statusStr, statusImg = "", "c_62.png"
        if zhenshouInfo.IsCombat then  -- 已上阵
            statusStr = TR("已上阵")
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
                if ZhenshouSlotObj:isSameZhenshouCombat(zhenshouInfo.ModelId) then
                    ui.showFlashView(TR("不能上阵相同珍兽"))
                    return
                end
                self:requestZhenshouCombat(zhenshouInfo, self.mSlotId)  
            end
        })
        tempBtn:setPosition(530, cellSize.height / 2)
        lvItem:addChild(tempBtn)

        -- 已上阵的人物和相同人物不能上阵
        if ZhenshouSlotObj:isSameZhenshouCombat(zhenshouInfo.ModelId) then
            tempBtn:setBright(false)
        end

        if zhenshouInfo.IsCombat then
            tempBtn:setBright(true)
            tempBtn:setTitleText(TR("下阵"))
            tempBtn:setClickAction(function()
                local slotId = ZhenshouSlotObj:getSlotIdById(zhenshouInfo.Id) 
                self:requestZhenshouCombat(zhenshouInfo, slotId)  
            end)
        end


        if not self.mSelectBtn_ then
            self.mSelectBtn_ = tempBtn
        end

        if index == 1 then
            self.mGuideBtn = tempBtn
        end
    end

    self.mEmptyHintSprite:setVisible(next(self.mZhenshouInfo) == nil)
    self.getBtn:setVisible(next(self.mZhenshouInfo) == nil)
end

--获取弹窗
function ZhenshouSelectLayer:createGetPop()
    local msgLayer = MsgBoxLayer.addDIYLayer({
        bgSize = cc.size(600, 450),
        title = TR("获取珍兽"),
        closeBtnInfo = {},
        btnInfos = {},
        DIYUiCallback = function(layerObj, mBgSprite, mBgSize)
            local grayBg = ui.newScale9Sprite("c_17.png", cc.size(540, 310))
            grayBg:setPosition(300, 185)
            mBgSprite:addChild(grayBg)

            local tipLabel = ui.newLabel({
                text = TR("可以通过以下途径获取珍兽"),
                color = Enums.Color.eBlack,
                -- outlineColor = Enums.Color.eOutlineColor,
                })
            tipLabel:setPosition(300, 360)
            mBgSprite:addChild(tipLabel)

            local listView = ccui.ListView:create()
            listView:setDirection(ccui.ListViewDirection.vertical)
            listView:setBounceEnabled(true)
            listView:setContentSize(cc.size(540, 290))
            listView:setAnchorPoint(0.5, 1)
            listView:setItemsMargin(5)
            listView:setPosition(300, 330)
            mBgSprite:addChild(listView)

            local jumpModel = {
                [1] = {
                    name = TR("珍兽塔"),
                    moduleId = "zsly.ZslyMainLayer",
                },
                [2] = {
                    name = TR("珍兽商店"),
                    moduleId = "zsly.ZslyShopLayer",
                },
            }

            for i = 1, 2 do
                layout = ccui.Layout:create()
                layout:setContentSize(540, 120)

                local bgSprite = ui.newScale9Sprite("c_18.png", cc.size(530, 120))
                bgSprite:setPosition(270, 60)
                layout:addChild(bgSprite)

                local nameLabel = ui.newLabel({
                    text = jumpModel[i].name,
                    color = Enums.Color.eBlack,
                })
                nameLabel:setAnchorPoint(0, 0.5)
                nameLabel:setPosition(40, 60)
                layout:addChild(nameLabel)

                local jumpBtn = ui.newButton({
                    normalImage = "c_28.png",
                    text = TR("前往"),
                    clickAction = function()
                        LayerManager.addLayer({
                            name = jumpModel[i].moduleId
                        })
                    end
                })
                jumpBtn:setPosition(450, 60)
                layout:addChild(jumpBtn)

                listView:pushBackCustomItem(layout)
            end

        end,
        notNeedBlack = true
    })
end

-- 上阵人物
function ZhenshouSelectLayer:requestZhenshouCombat(zhenshouInfo, slotId)
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "ZhenshouSlot",
        methodName = "Combat",
        guideInfo = Guide.helper:tryGetGuideSaveInfo(10065),
        svrMethodData = {slotId, zhenshouInfo.Id},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            ZhenshouSlotObj:setZhenshouSlot(response.Value.ZhenShouSlotInfo)

            local info = {FightZhenshouId = response.Value.ZhenShouSlotInfo.FightZhenshouId}
            PlayerAttrObj:changeAttr(info)

            for i,v in ipairs(response.Value.ZhenShouInfo) do
                ZhenshouObj:modifyZhenshouItem(v)
            end

            LayerManager.removeLayer(self)
        end,
    })
end

-- ========================== 新手引导 ===========================
-- 执行新手引导
function ZhenshouSelectLayer:executeGuide()
    Guide.helper:executeGuide({
        -- 指向选择珍兽界面
        [10065] = {clickNode = self.mGuideBtn},
    })
end

return ZhenshouSelectLayer
