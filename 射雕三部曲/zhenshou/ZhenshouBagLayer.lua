--[[
	文件名：ZhenshouBagLayer.lua
	描述：珍兽包裹界面
	创建人：lengjiazhi
	创建时间： 2017.12.07
--]]
local ZhenshouBagLayer = class("ZhenshouBagLayer", function(params)
	return display.newLayer()
end)

function ZhenshouBagLayer:ctor(params)
    self.mSelectId = params.selectId 
    self.mViewPos = params.viewPos

	-- 该页面的Parent
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

	self:initUI()
end

function ZhenshouBagLayer:initUI()
	-- 背景图片
    local bgSprite = ui.newSprite("c_128.jpg")
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)

    --标签按钮
    local tagBtn = ui.newButton({
    	normalImage = "c_50.png",
    	text = TR("珍兽"),
		clickAction = function()

		end    	
    	})
    tagBtn:setPosition(80, 1015)
    self.mParentLayer:addChild(tagBtn)

    -- 包裹空间文字背景图片
    local countBack = ui.newScale9Sprite("c_24.png", cc.size(118, 32))
    countBack:setPosition(540, 955)
    self.mParentLayer:addChild(countBack, 10)

    countWordLabel = ui.newLabel({
        text = TR("包裹空间"),
        color = cc.c3b(0x46, 0x22, 0x0d),
        -- outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        size = 22,
    })
    countWordLabel:setAnchorPoint(cc.p(0, 0.5))
    countWordLabel:setPosition(390, 955)
    self.mParentLayer:addChild(countWordLabel, 10)

    --下方白板背景
    local bottomSprtie = ui.newScale9Sprite("c_19.png", cc.size(640, 1000))
    bottomSprtie:setAnchorPoint(0.5, 0)
    bottomSprtie:setPosition(320, 0)
    self.mParentLayer:addChild(bottomSprtie)

    --灰色底板
    local underGaryBgSprite = ui.newScale9Sprite("c_24.png", cc.size(626, 660))
    underGaryBgSprite:setPosition(320, 598)
    self.mParentLayer:addChild(underGaryBgSprite)

	 -- 退出按钮
    self.mCloseBtn = ui.newButton({
        normalImage = "c_29.png",
        position = Enums.StardardRootPos.eCloseBtn,
        clickAction = function(pSender)
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(self.mCloseBtn, 100)

    -- 创建顶部资源
    local topResource = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        needFAP = false,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eSTA, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(topResource)

    local emptySprite = ui.createEmptyHint(TR("请前往珍兽塔获取珍兽"))
    emptySprite:setPosition(320, 568)
    self.mParentLayer:addChild(emptySprite)
    self.mEmptySprite = emptySprite

    local getBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("去获取"),
        clickAction = function()
            self:createGetPop()
        end
        })
    getBtn:setPosition(320, 430)
    self.mParentLayer:addChild(getBtn, 10)
    self.mGetBtn = getBtn

    self:refreshGrid()
    
    -- 播放音效
    MqAudio.playEffect("chuwu_open.mp3")
end

-- 根据所选择的card显示相应的属性
function ZhenshouBagLayer:showAttrLabel(data)
    if self.mAttrSprite then
        self.mAttrSprite:removeFromParent()
        self.mAttrSprite = nil
    end
    self.mAttrSprite = ui.newScale9Sprite("c_65.png",cc.size(630, 135))
    self.mAttrSprite:setPosition(320, 180)
    self.mParentLayer:addChild(self.mAttrSprite)

    local goodsModel
    local attr = {CardShowAttr.eBorder}
    local isZhenshou = Utility.isZhenshou(Utility.getTypeByModelId(data.ModelId))
    if isZhenshou then
        goodsModel = ZhenshouModel.items[data.ModelId]
        table.insert(attr, CardShowAttr.eLevel)
        table.insert(attr, CardShowAttr.eStep)
    else
        goodsModel = GoodsModel.items[data.ModelId]
    end

    local card = CardNode.createCardNode({
        instanceData = data,
        cardShape = Enums.CardShape.eSquare,
        cardShowAttrs = attr,
        allowClick = false,
    })
    card:setPosition(55, 65)
    self.mAttrSprite:addChild(card)

    local nameLab = ui.newLabel({
        text = TR(goodsModel.name),
        size = 22,
        color = Utility.getQualityColor(goodsModel.quality, 1),
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        outlineSize = 2,
        anchorPoint = cc.p(0, 1),
        dimensions = cc.size(300, 0),
        valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
    })
    nameLab:setPosition(115, 113)
    self.mAttrSprite:addChild(nameLab)

    local introLab = ui.newLabel({
        text = TR(goodsModel.intro),
        size = 20,
        color = cc.c3b(0x46, 0x22, 0x0d),
        anchorPoint = cc.p(0, 0),
        dimensions = cc.size(350, 0),
        valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
    })

    local size = introLab:getContentSize()
    local height = math.min(size.height, 60)
    local scrollView = ccui.ScrollView:create()
    scrollView:setContentSize(cc.size(350, height))
    scrollView:setAnchorPoint(cc.p(0, 1))
    scrollView:setPosition(cc.p(115, 80))
    scrollView:setInnerContainerSize(introLab:getContentSize())
    scrollView:addChild(introLab)

    self.mAttrSprite:addChild(scrollView)

    -- 判断是否可以使用
    if isZhenshou then
        -- 创建使用按钮
        self.useBtn = ui.newButton({
            normalImage = "c_28.png",
            position = cc.p(550, 65),
            text = TR("详 情"),
            clickAction = function()
                self.mViewPos = cc.p(self.mGridView.mScrollView:getInnerContainer():getPosition())
                LayerManager.addLayer({
                    name = "zhenshou.ZhenshouInfoLayer",
                    data = {
                        zhenshouId = data.Id,
                    },
                })
            end
        })
        -- 穿透问题
        self.useBtn:setPropagateTouchEvents(false)
        self.mAttrSprite:addChild(self.useBtn)
    else
        local needNum = GoodsModel.items[data.ModelId].maxNum
        local nowNum = data.Num

        local canHc = false
        if nowNum >= needNum then
            canHc = true
        end
        local color = canHc and "#249029" or Enums.Color.eRedH
        introLab:setString(TR("数量: %s%d/%d", color, nowNum, needNum)..(canHc and TR("(已满)") or TR("(数量不足)")))

        if canHc then
            -- 创建使用按钮
            self.useBtn = ui.newButton({
                normalImage = "c_28.png",
                position = cc.p(550, 65),
                text = TR("合 成"),
                clickAction = function()
                    self:requestUpgrade(data, nowNum)
                end
            })
            -- 穿透问题
            self.useBtn:setPropagateTouchEvents(false)
            self.mAttrSprite:addChild(self.useBtn)
        else
            -- 创建使用按钮
            self.useBtn = ui.newButton({
                normalImage = "c_28.png",
                position = cc.p(550, 65),
                text = TR("去获取"),
                clickAction = function()
                    LayerManager.addLayer({
                        name = "hero.DropWayLayer",
                        data = {
                            resourceTypeSub = Utility.getTypeByModelId(data.ModelId),
                            modelId = data.ModelId,
                        },
                        cleanUp = false,
                    })
                end
            })
            -- 穿透问题
            self.useBtn:setPropagateTouchEvents(false)
            self.mAttrSprite:addChild(self.useBtn)
        end
    end
end

-- 刷新显示列表
function ZhenshouBagLayer:refreshGrid()
    self:showBagCount()

    -- 清空之前的显示列表
    if self.mGridView then
        self.mGridView:removeFromParent()
        self.mGridView = nil
    end

    if self.mAttrSprite then
        self.mAttrSprite:removeFromParent()
        self.mAttrSprite = nil
    end
    -- 得到对应包裹里的数据
    self.mDataList = self:getItemData()
    
    if #self.mDataList ~= 0 then
        self.mEmptySprite:setVisible(false)
        self.mGetBtn:setVisible(false)
    end

    if #self.mDataList > 0 then
        self.mGridView = require("common.GridView"):create({
            viewSize = cc.size(640, 645),
            colCount = 5,
            celHeight = 114,
            selectIndex = 1,
            -- needDelay = true,
            getCountCb = function()
                return #self.mDataList
            end,
            createColCb = function(itemParent, colIndex, isSelected)
                local attrs = {CardShowAttr.eBorder, CardShowAttr.eNum}
                local isZhenshou = Utility.isZhenshou(Utility.getTypeByModelId(self.mDataList[colIndex].ModelId))

                if isSelected then
                    table.insert(attrs, CardShowAttr.eSelected)
                end
                if isZhenshou then
                    table.insert(attrs, CardShowAttr.eLevel)
                    if self.mDataList[colIndex].IsCombat then
                        table.insert(attrs, CardShowAttr.eBattle)
                    end
                end

                -- 创建显示图片
                local card, Attr = CardNode.createCardNode({
                    instanceData = self.mDataList[colIndex],
                    cardShowAttrs = attrs,
                    onClickCallback = function()
                        self:showAttrLabel(self.mDataList[colIndex])
                        self.mGridView:setSelect(colIndex)
                        self.mSelIndex = colIndex
                        self.mSelectId = self.mDataList[colIndex].Id
                    end,
                })
                card:setPosition(64, 60)
                itemParent:addChild(card)
                if not isZhenshou then
                    local needNum = GoodsModel.items[self.mDataList[colIndex].ModelId].maxNum
                    local nowNum = self.mDataList[colIndex].Num
                    Attr[CardShowAttr.eNum].label:setString(string.format("%d/%d",nowNum,needNum))
                    if self.mDataList[colIndex].Num >=
                        GoodsModel.items[self.mDataList[colIndex].ModelId].maxNum then
                        card:setSyntheticMark()
                    end
                end

            end,
        })

        self.mGridView:setPosition(320, 600)
        self.mParentLayer:addChild(self.mGridView)

        local selIndex = 1
        for index, value in ipairs(self.mDataList) do
            if value.Id == self.mSelectId then
                selIndex = index
            end
        end
        if selIndex == 1 then
            self.mViewPos = nil
        end
        self.mGridView:setSelect(selIndex)
        self:showAttrLabel(self.mDataList[selIndex])
        if self.mViewPos then
            self.mGridView.mScrollView:getInnerContainer():setPosition(self.mViewPos)
        end
        self.mSelIndex = selIndex
    end

end

--得到对应数据和背包控件的类型
function ZhenshouBagLayer:getItemData()
    local itemData

    itemData = clone(ZhenshouObj:getZhenshouList())
    local tempZhenshouDebris = clone(GoodsObj:getZhenshouDebrisList())
    table.insertto(itemData, tempZhenshouDebris, -1)

    table.sort(itemData, function (a, b)
        local isGoodsA = Utility.getTypeByModelId(a.ModelId) == ResourcetypeSub.eZhenshouDebris
        local isZhenshouA = Utility.getTypeByModelId(a.ModelId) == ResourcetypeSub.eZhenshou
        local isGoodsB = Utility.getTypeByModelId(b.ModelId) == ResourcetypeSub.eZhenshouDebris
        local isZhenshouB = Utility.getTypeByModelId(b.ModelId) == ResourcetypeSub.eZhenshou
        -- 可以合成的碎片排在最前面
        if isGoodsA and GoodsModel.items[a.ModelId].maxNum == a.Num and (isZhenshouB or GoodsModel.items[b.ModelId].maxNum ~= b.Num) then
            return true
        elseif isGoodsB and GoodsModel.items[b.ModelId].maxNum == b.Num and (isZhenshouA or GoodsModel.items[a.ModelId].maxNum ~= a.Num) then
            return false
        end

        -- 幻化排在幻化碎片前面
        if isZhenshouA and isGoodsB then
            return true
        elseif isZhenshouB and isGoodsA then
            return false
        end

        if isZhenshouA and isZhenshouB then
            --上阵的排前面
            local isCombatA = ZhenshouSlotObj:isCombat(a.Id)
            local isCombatB = ZhenshouSlotObj:isCombat(b.Id)
            if isCombatA and not isCombatB then return true end
            if isCombatB and not isCombatA then return false end

            -- 高品质排在前面
            if ZhenshouModel.items[a.ModelId].quality ~= ZhenshouModel.items[b.ModelId].quality then
                return ZhenshouModel.items[a.ModelId].quality > ZhenshouModel.items[b.ModelId].quality
            end

            if a.Step ~= b.Step then 
                return a.Step > b.Step 
            end

            if a.Lv ~= b.Lv then 
                return a.Lv > b.Lv 
            end

            -- 比较模型id
            return a.ModelId > b.ModelId
        elseif isGoodsA and isGoodsB then
            -- -- 高品质碎片排在前面
            if GoodsModel.items[a.ModelId].quality ~= GoodsModel.items[a.ModelId].quality then
                return GoodsModel.items[a.ModelId].quality > GoodsModel.items[a.ModelId].quality
            end

            -- 比较数量
            if a.Num ~= b.Num then
                return a.Num > b.Num
            end

            -- 比较模型id
            if GoodsModel.items[a.ModelId].ID ~= GoodsModel.items[b.ModelId].ID then
                return GoodsModel.items[a.ModelId].ID < GoodsModel.items[b.ModelId].ID
            end

            return a.Id < b.Id
        end
    end)

    return itemData
end

-- 显示包裹数量
function ZhenshouBagLayer:showBagCount()

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
        -- outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        size = 22,
    })
    -- self.mCountLabel:setAnchorPoint(cc.p(0, 0.5))
    self.mCountLabel:setPosition(540, 955)
    self.mParentLayer:addChild(self.mCountLabel, 10)

    --扩充按钮
    self.mBuyBtn = ui.newButton({
        normalImage = "gd_27.png",
        position = cc.p(600, 955),
        clickAction = function()
            MsgBoxLayer.addExpandBagLayer(BagType.eZhenshouDebrisBag,
                function ()
                    self:showBagCount()
                end)
        end,
    })
    self.mParentLayer:addChild(self.mBuyBtn, 10)
    -- self.mBuyBtn:setScale(0.7)
    local bagTypeInfo = BagModel.items[BagType.eZhenshouDebrisBag]
    local playerTypeInfo = self:getPlayerBagInfo(BagType.eZhenshouDebrisBag)
    local maxBagSize = table.nums(BagExpandUseRelation.items) * bagTypeInfo.perExpandSize + bagTypeInfo.initSize
    self.mCountLabel:setString(TR("%d/%d", self:getItemCount(BagType.eZhenshouDebrisBag), playerTypeInfo.Size))
    self.mBuyBtn:setVisible(playerTypeInfo.Size < maxBagSize)
end

-- 获取对应类的包裹的信息
function ZhenshouBagLayer:getPlayerBagInfo()
    local bagModelId = BagType.eZhenshouDebrisBag
    local playerTypeInfo = {}
    for i, v in ipairs(BagInfoObj:getAllBagInfo()) do
        if v.BagModelId == bagModelId then
            playerTypeInfo = v
            break
        end
    end
    return playerTypeInfo
end

-- 得到对用type的包裹物品的数量
function ZhenshouBagLayer:getItemCount()
    local dataCount = #(GoodsObj:getZhenshouDebrisList()) + #(ZhenshouObj:getZhenshouList())
    return dataCount
end

-- 获取恢复该页面数据
function ZhenshouBagLayer:getRestoreData()
    local retData = {}
    retData.selectId = self.mSelectId
    retData.viewPos = self.mViewPos

    return retData
end

--获取弹窗
function ZhenshouBagLayer:createGetPop()
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

--========================================网络请求=============================
-- 碎片合成
function ZhenshouBagLayer:requestUpgrade(data, num)
    HttpClient:request({
        moduleName = "Goods",
        methodName = "GoodsUse",
        svrMethodData = {data.Id, data.ModelId, num},
        callback = function (response)
            if not response or response.Status ~= 0 then
                return
            end
            self:refreshGrid()
            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
            -- MsgBoxLayer.addGameDropLayer(response.Value.BaseGetGameResourceList, {}, " ", "合成", {{text = TR("确定")}}, {})
        end
    })
end
return ZhenshouBagLayer