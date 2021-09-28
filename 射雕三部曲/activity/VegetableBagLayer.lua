--[[
	文件名:VegetablesBagLayer.lua
	描述：种菜包裹
	创建人：lengjiazhi
    创建时间：2018.03.26
--]]

local VegetablesBagLayer = class("VegetablesBagLayer", function(params)
    return display.newLayer()
end)

function VegetablesBagLayer:ctor(params)
	-- 屏蔽下层事件
	ui.registerSwallowTouch({node = self})

    self.mSelectId = params.selectId or 1
    self.mViewPos = params.viewPos
    self.mScoreLabel = params.scoreLabel

	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer) 

	-- 初始化页面控件
	self:initUI()
	self:requestGetGoodsInfo()
end

function VegetablesBagLayer:initUI()
    --弹窗
    local popLayer = require("commonLayer.PopBgLayer").new({
        bgSize = cc.size(620, 736),
        title = TR("仓库"),
        color4B = cc.c4b(0, 0, 0, 50),
        closeAction = function(pSender)
            LayerManager.removeLayer(self)
        end,
    })
    self:addChild(popLayer)
    self.mPopLayer = popLayer
    self.mPopBgSprite = popLayer.mBgSprite

    --灰色底板
    local grayBgSprite = ui.newScale9Sprite("c_19.png", cc.size(575, 660))
    grayBgSprite:setPosition(310, 350)
    self.mPopBgSprite:addChild(grayBgSprite)

    --空背包提示
    local emptySprite = ui.createEmptyHint(TR("请在矿石商店购买矿石"))
    emptySprite:setPosition(320, 400)
    self.mPopBgSprite:addChild(emptySprite)
    self.mEmptySprite = emptySprite

    -- 提示活动结束清空所有道具
    local hintLabel = ui.newLabel({
            text = TR("活动结束后，仓库中的所有物品都会清空，请及时使用或出售！"),
            size = 20,
            color = Enums.Color.eRed,
            outlineColor = Enums.Color.eOutlineColor,
        })
    hintLabel:setPosition(320, 645)
    self.mPopBgSprite:addChild(hintLabel)

end

-- 刷新显示列表
function VegetablesBagLayer:refreshGrid()

    -- 清空之前的显示列表
    if self.mGridView then
        self.mGridView:removeFromParent()
        self.mGridView = nil
    end

    if self.mAttrSprite then
        self.mAttrSprite:removeFromParent()
        self.mAttrSprite = nil
    end

    self.mEmptySprite:setVisible(#self.mDataList == 0)

    if #self.mDataList > 0 then
        self.mGridView = require("common.GridView"):create({
            viewSize = cc.size(600, 470),
            colCount = 4,
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
                end
                local goodModel = GoodsModel.items[self.mDataList[colIndex].ModelId]
                -- 创建显示图片
                local card, Attr = CardNode.createCardNode({
                	resourceTypeSub = Utility.getTypeByModelId(goodModel.ID),
        			modelId = goodModel.ID, 
			        num = self.mDataList[colIndex].ExchangeCount, 
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

            end,
        })

        self.mGridView:setPosition(320, 390)
        self.mPopBgSprite:addChild(self.mGridView)

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

-- 根据所选择的card显示相应的属性
function VegetablesBagLayer:showAttrLabel(data)
    if self.mAttrSprite then
        self.mAttrSprite:removeFromParent()
        self.mAttrSprite = nil
    end
    self.mAttrSprite = ui.newScale9Sprite("c_65.png",cc.size(560, 120))
    self.mAttrSprite:setPosition(310, 90)
    self.mPopBgSprite:addChild(self.mAttrSprite)

    local card = CardNode.createCardNode({
        instanceData = data,
        cardShape = Enums.CardShape.eSquare,
        cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum},
    })
    card:setPosition(55, 65)
    self.mAttrSprite:addChild(card)

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
        dimensions = cc.size(250, 0),
        valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
    })

    local size = introLab:getContentSize()
    local height = math.min(size.height, 60)
    local scrollView = ccui.ScrollView:create()
    scrollView:setContentSize(cc.size(250, height))
    scrollView:setAnchorPoint(cc.p(0, 1))
    scrollView:setPosition(cc.p(115, 80))
    scrollView:setInnerContainerSize(introLab:getContentSize())
    scrollView:addChild(introLab)

    local sellBtn = ui.newButton({
    	normalImage = "c_28.png",
    	text = TR("出售"),
    	clickAction = function ()
    		self:onBtnSellClicked(data)
    	end
    	})
    sellBtn:setPosition(450, 60)
    self.mAttrSprite:addChild(sellBtn)

    self.mAttrSprite:addChild(scrollView)
end

--排序
function VegetablesBagLayer:getItemData(itemData)

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

        return false
    end)

    return itemData
end

--========================================网络请求=======================================
--获取道具信息
function VegetablesBagLayer:requestGetGoodsInfo()
	HttpClient:request({
        moduleName = "TimedVegetablesInfo",
        methodName = "GetBagInfo",
        callbackNode = self,
        svrMethodData = {},
        callback = function(data)
            if data.Status ~= 0 then
                return
            end
            -- dump(data, "requestInfo")
            self.mDataList = data.Value.VegetablesGoods

            self:getItemData(self.mDataList)
            self:refreshGrid()
        end,
    })
end

-- 点击出售
function VegetablesBagLayer:onBtnSellClicked(item)
    local function do_request(cnt)
        -- 出售道具
        HttpClient:request({
            moduleName = "TimedVegetablesInfo",
            methodName = "Exchange",
            svrMethodData = {item.ModelId, cnt},
            callback = function(data)
                if data.Status ~= 0 then
                    return
                end
                -- dump(data, "sdasdasdas")
            	self.mDataList = data.Value.VegetablesGoods
            	self.mTotalScore = data.Value.TotalScore
            	self:getItemData(self.mDataList)

                ui.showFlashView(TR("出售完成"))
                self.mScoreLabel:setString(TR("我的剑意:%s", self.mTotalScore))
                self:refreshGrid()
            end,
        })
    end

    -- 获取道具
    local goodsModel = GoodsModel.items[item.ModelId]

    -- 出售确认框
    local function confirm(cnt, price)
        local name = goodsModel.name
        local price = item.Score * cnt
        local selltype = TR("剑意")
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
    if item.ExchangeCount > 1 then
        MsgBoxLayer.addSellGoodsCountLayer(TR("出售"), item.ModelId, item.ExchangeCount,
            function (selCount)
                confirm(selCount)
            end
        ,
        item.Score,
        TR("剑意"), true)
    else
        confirm(1)
    end
end

return VegetablesBagLayer