--[[
	文件名：QuenchBagLayer.lua
	描述：药材包裹界面
	创建人：lengjiazhi
	创建时间： 2017.12.07
--]]
local QuenchBagLayer = class("QuenchBagLayer", function(params)
	return display.newLayer()
end)

function QuenchBagLayer:ctor(params)
    self.mSelectId = params.selectId 
    self.mViewPos = params.viewPos


	-- 该页面的Parent
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

	self:initUI()
end

function QuenchBagLayer:initUI()
	-- 背景图片
    local bgSprite = ui.newSprite("c_128.jpg")
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)

    --标签按钮
    local tagBtn = ui.newButton({
    	normalImage = "c_50.png",
    	text = TR("炼药"),
		clickAction = function()

		end    	
    	})
    tagBtn:setPosition(80, 1015)
    self.mParentLayer:addChild(tagBtn)


    --下方白板背景
    local bottomSprtie = ui.newScale9Sprite("c_19.png", cc.size(640, 1000))
    bottomSprtie:setAnchorPoint(0.5, 0)
    bottomSprtie:setPosition(320, 0)
    self.mParentLayer:addChild(bottomSprtie)

    --灰色底板
    local underGaryBgSprite = ui.newScale9Sprite("c_24.png", cc.size(626, 700))
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

    local emptySprite = ui.createEmptyHint(TR("请前往光明顶获取药材"))
    emptySprite:setPosition(320, 568)
    self.mParentLayer:addChild(emptySprite)
    self.mEmptySprite = emptySprite

    local getBtn = ui.newButton({
        normalImage = "tb_34.png",
        clickAction = function()
            LayerManager.showSubModule(ModuleSub.eExpedition)
        end
        })
    getBtn:setPosition(540, 160)
    self.mParentLayer:addChild(getBtn)
    self.mGetBtn = getBtn

    self:refreshGrid()
    
    -- 播放音效
    MqAudio.playEffect("chuwu_open.mp3")
end

-- 根据所选择的card显示相应的属性
function QuenchBagLayer:showAttrLabel(data)
    if self.mAttrSprite then
        self.mAttrSprite:removeFromParent()
        self.mAttrSprite = nil
    end
    self.mAttrSprite = ui.newScale9Sprite("c_65.png",cc.size(630, 135))
    self.mAttrSprite:setPosition(320, 180)
    self.mParentLayer:addChild(self.mAttrSprite)

    local card = CardNode.createCardNode({
        instanceData = data,
        cardShape = Enums.CardShape.eSquare,
        cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum},
    })
    card:setPosition(55, 65)
    self.mAttrSprite:addChild(card)

    --代金券过期处理
    if math.floor(data.ModelId / 100000) == 169 then
        local voucherStatus = ConfigFunc:getVoucherStatus(data)
        if voucherStatus == 0 or voucherStatus == -1 then
            local passedTipSprite = ui.newSprite("c_150.png")
            passedTipSprite:setPosition(40, 56)
            card:addChild(passedTipSprite)
            local passedTipLabel = ui.newLabel({
                text = TR("过期"),
                size = 22,
                outlineColor = Enums.Color.eBlack,
                })
            passedTipLabel:setPosition(27, 49)
            passedTipLabel:setRotation(-45)
            passedTipSprite:addChild(passedTipLabel)
        end
    end

    local NorGoodsModel = GoodsModel.items[data.ModelId] or GoodsVoucherModel.items[data.ModelId]
    local goodsModel
    if not NorGoodsModel then
        return
    elseif NorGoodsModel then
        goodsModel = NorGoodsModel
    end

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
    if NorGoodsModel then
        if goodsModel.ifUse then
            -- 创建使用按钮
            self.useBtn = ui.newButton({
                normalImage = "c_28.png",
                position = cc.p(550, 65),
                text = TR("使 用"),
                clickAction = function()
                    self.mViewPos = cc.p(self.mGridView.mScrollView:getInnerContainer():getPosition())
                    LayerManager.addLayer({
                    	name = "quench.QuenchEatMedicineLayer"
                    	})
                end
            })
            -- 穿透问题
            self.useBtn:setPropagateTouchEvents(false)
            self.mAttrSprite:addChild(self.useBtn)
        end

        -- 判断是否可以出售

        if goodsModel.sellTypeID > 0 and goodsModel.sellNum > 0 then
            if goodsModel.ifUse then
                self.useBtn:setPosition(550, 97)
            end
            -- 创建出售按钮
            local saleBtn = ui.newButton({
                normalImage = "c_28.png",
                position = goodsModel.ifUse and cc.p(550, 37) or cc.p(550, 65),
                --size = cc.size(135,58),
                text = TR("出 售"),
                clickAction = function(pSender)
                    self.mViewPos = cc.p(self.mGridView.mScrollView:getInnerContainer():getPosition())
                    self:onBtnSellClicked(data)
                end
            })
            -- 穿透问题
            saleBtn:setPropagateTouchEvents(false)
            self.mAttrSprite:addChild(saleBtn)
        end
    end
end

-- 刷新显示列表
function QuenchBagLayer:refreshGrid()

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
            viewSize = cc.size(640, 685),
            colCount = 5,
            celHeight = 114,
            selectIndex = 1,
            -- needDelay = true,
            getCountCb = function()
                return #self.mDataList
            end,
            createColCb = function(itemParent, colIndex, isSelected)

                local attrs = {CardShowAttr.eBorder, CardShowAttr.eNum}

                if isSelected then
                    table.insert(attrs, CardShowAttr.eSelected)
                    if GoodsObj:getNewPropsIdObj():IdIsNew(self.mDataList[colIndex].Id) then
                        GoodsObj:getNewPropsIdObj():clearNewId(self.mDataList[colIndex].Id)
                        Notification:postNotification(EventsName.eNewPrefix .. ModuleSub.eBagProps)
                    end
                end

                if GoodsObj:getNewPropsIdObj():IdIsNew(self.mDataList[colIndex].Id) then
                    table.insert(attrs, CardShowAttr.eNewCard)
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

                --代金券过期处理
                if math.floor(self.mDataList[colIndex].ModelId / 100000) == 169 then
                    local voucherStatus = ConfigFunc:getVoucherStatus(self.mDataList[colIndex])
                    if voucherStatus == 0 or voucherStatus == -1 then
                        local passedTipSprite = ui.newSprite("c_150.png")
                        passedTipSprite:setPosition(40, 56)
                        card:addChild(passedTipSprite)
                        local passedTipLabel = ui.newLabel({
                            text = TR("过期"),
                            size = 22,
                            outlineColor = Enums.Color.eBlack,
                            })
                        passedTipLabel:setPosition(27, 49)
                        passedTipLabel:setRotation(-45)
                        passedTipSprite:addChild(passedTipLabel)
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
function QuenchBagLayer:getItemData()
    local itemData

    itemData = clone(GoodsObj:getQuenchList())
    -- dump(itemData, "pppp")
    table.sort(itemData, function (a, b)
        local modelA = GoodsModel.items[a.ModelId] 
        local modelB = GoodsModel.items[b.ModelId] 

        if not modelA or not modelB then 
            return false
        end

        --排序id
        if modelA.orderNum ~= modelB.orderNum then
            return modelA.orderNum < modelB.orderNum 
        end

        --比较模型id
        if a.ModelId ~= b.ModelId then
            return a.ModelId < b.ModelId
        end

        --比较数量
        if a.Num ~= b.Num then
            return a.Num > b.Num
        end

        return a.Id < b.Id
    end)

    return itemData
end

-- 获取恢复该页面数据
function QuenchBagLayer:getRestoreData()
    local retData = {}
    retData.selectId = self.mSelectId
    retData.viewPos = self.mViewPos

    return retData
end

--========================================网络请求=============================

-- 点击出售
function QuenchBagLayer:onBtnSellClicked(data)
    local function do_request(cnt)
        -- 出售道具
        HttpClient:request({
            moduleName = "Goods",
            methodName = "GoodsSell",
            svrMethodData = {data.Id, data.ModelId, cnt},
            callback = function(value)
                if value.Status ~= 0 then
                    return
                end
                ui.showFlashView(TR("出售完成"))
                self:refreshGrid()
            end,
        })
    end

    -- 获取道具
    local goodsModel = GoodsModel.items[data.ModelId] or GoodsVoucherModel.items[data.ModelId]

    -- 出售确认框
    local function confirm(cnt, price)
        local name = goodsModel.name
        local price = goodsModel.sellNum * cnt
        local selltype = ResourcetypeSubName[goodsModel.sellTypeID]
        -- MsgBoxLayer.addOKCancelLayer(msgText, title, okBtnInfo, cancelBtnInfo, closeBtnInfo, needCloseBtn)
        self.layer = MsgBoxLayer.addOKLayer(
            TR("出售%s个%s?共计%s%s", cnt, name, price, selltype),
            TR("出售"),
            {{
                normalImage = "c_28.png",
                text = TR("确定"),
                clickAction = function()
                    do_request(cnt)
                    LayerManager.removeLayer(self.layer)
                end,
            }},{}
        )
    end

    -- 如果物品数量大于1，点击出售时弹出个数的选择框
    if data.Num > 1 then
        MsgBoxLayer.addSellGoodsCountLayer(TR("出售"), data.ModelId, data.Num,
            function (selCount)
                confirm(selCount)
            end
        )
    else
        confirm(1)
    end
end
return QuenchBagLayer