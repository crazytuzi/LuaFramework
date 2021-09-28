--[[
	文件名:SubFashionView.lua
	描述：绝学列表的子页面
	创建人：peiyaoqiang
	创建时间：2017.09.15
--]]

local QFashionDebrisView = class("QFashionDebrisView", function()
    return display.newLayer()
end)

--[[
-- 参数 params 中各项为：
	{
		viewSize: 显示大小，必选参数
	}
]]
function QFashionDebrisView:ctor(params)
    -- 读取参数
	self.viewSize = params.viewSize

	-- 初始化
	self:setContentSize(self.viewSize)

    -- 界面初始化
    self:initUI()
end

-- 初始化UI
function QFashionDebrisView:initUI()
	-- 灰背景
	local blackBg = ui.newScale9Sprite("c_17.png", cc.size(self.viewSize.width, 785))
	blackBg:setAnchorPoint(cc.p(0.5, 1))
    blackBg:setPosition(self.viewSize.width*0.5, 943)
    self:addChild(blackBg)

    -- 属性背景
	local introBgSize = cc.size(self.viewSize.width - 20, 144)
	local introBgSprite = ui.newScale9Sprite("c_65.png", introBgSize)
	introBgSprite:setAnchorPoint(cc.p(0.5, 0))
	introBgSprite:setPosition(cc.p(self.viewSize.width * 0.5, 10))
	self:addChild(introBgSprite)
	self.mAttrSprite = introBgSprite

	self:refreshGrid()
end

function QFashionDebrisView:refreshUI()
	self:refreshGrid()
end

--刷新表格
function QFashionDebrisView:refreshGrid()
    -- 清空之前的显示列表
    if self.mGridView then
        self.mGridView:removeFromParent()
        self.mGridView = nil
    end

    self.mAttrSprite:removeAllChildren()

    -- 得到对应包裹里的数据
    self.mDataList = self:getItemData()

    if #self.mDataList > 0 then
        self.mGridView = require("common.GridView"):create({
        viewSize = cc.size(self.viewSize.width, 765),
        colCount = 5,
        celHeight = 114,
        selectIndex = 1,
        needDelay = true,
        getCountCb = function()
            return #self.mDataList
        end,
        createColCb = function(itemParent, colIndex, isSelected)
            local attrs = {CardShowAttr.eBorder, CardShowAttr.eNum}

            if isSelected then
                table.insert(attrs, CardShowAttr.eSelected)
            end

            -- table.insert(attrs, CardShowAttr.eDebris, CardShowAttr.eNum)

            -- if GoodsObj:getNewPetDebrisIdObj():IdIsNew(self.mDataList[colIndex].Id) then
            --     table.insert(attrs, CardShowAttr.eNewCard)
            -- end
            -- 创建显示图片
            local card, Attr = CardNode.createCardNode({
                resourceTypeSub = ResourcetypeSub.ePet,
                instanceData = self.mDataList[colIndex],
                cardShowAttrs = attrs,
                onClickCallback = function()
                    self:showAttrLabel(self.mDataList[colIndex])
                    self.mGridView:setSelect(colIndex)
                    self.mSelectId = self.mDataList[colIndex].Id
                end,
            })

            local needNum = GoodsModel.items[self.mDataList[colIndex].ModelId].maxNum
            local nowNum = self.mDataList[colIndex].Num
            Attr[CardShowAttr.eNum].label:setString(string.format("%d/%d",nowNum,needNum))
            if self.mDataList[colIndex].Num >=
                GoodsModel.items[self.mDataList[colIndex].ModelId].maxNum then
                card:setSyntheticMark()
            end

            card:setPosition(64, 60)
            itemParent:addChild(card)
        end,
        })
        self.mGridView:setAnchorPoint(cc.p(0.5, 1))
        self.mGridView:setPosition(self.viewSize.width*0.5, 933)
        self:addChild(self.mGridView)

        local selIndex = 1
        for index, value in ipairs(self.mDataList) do
            if value.Id == self.mSelectId then
                selIndex = index
            end
        end
        self.mGridView:setSelect(selIndex)
        self:showAttrLabel(self.mDataList[selIndex])
        if selIndex == 1 then
            self.mViewPos = nil
        end
        if self.mViewPos then
            self.mGridView.mScrollView:getInnerContainer():setPosition(self.mViewPos)
        end
    else
    	local emptyHint = ui.createEmptyHint(TR("暂无时装碎片"))
    	emptyHint:setPosition(self.viewSize.width*0.5, self.viewSize.height*0.5)
    	self:addChild(emptyHint)
    end
end

-- 根据所选择的card显示相应的属性
function QFashionDebrisView:showAttrLabel(data)
	self.mAttrSprite:removeAllChildren()

	local needNum = GoodsModel.items[data.ModelId].maxNum
    local nowNum = data.Num

    local canHc = false
    if nowNum >= needNum then
        canHc = true
    end

    local att = {CardShowAttr.eBorder, CardShowAttr.eDebris}
    local card = CardNode.createCardNode({
        instanceData = data,
        cardShowAttrs = att,
    })
    card:setPosition(55, 65)
    self.mAttrSprite:addChild(card)
    if canHc then
        card:setSyntheticMark()
    end

    local nameLab = ui.newLabel({
        text = TR(GoodsModel.items[data.ModelId].name),
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        outlineSize = 2,
        size = 22,
        color = Utility.getQualityColor(GoodsModel.items[data.ModelId].quality, 1),
        anchorPoint = cc.p(0, 1),
        dimensions = cc.size(300, 0),
        valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
    })

    nameLab:setPosition(110, 113)
    self.mAttrSprite:addChild(nameLab)

    -- 数量
    local numLabel = ui.newLabel({
        text = TR("数量: %d/%d", nowNum, needNum)..(canHc and "(已满)" or TR("(数量不足)")),
        size = 20,
        color = canHc and Enums.Color.eDarkGreen or Enums.Color.eDarkGreen,
    })
    numLabel:setAnchorPoint(cc.p(0, 1))
    numLabel:setPosition(120, 70)
    self.mAttrSprite:addChild(numLabel)

    if canHc then
        local upgradeBtn = ui.newButton({
            normalImage = "c_28.png",
            position = cc.p(480, 65),
            text = TR("合 成"),
            clickAction = function ()
                self:requestUpgrade(data, nowNum)
            end
            })
        self.mAttrSprite:addChild(upgradeBtn)
        -- 穿透问题
        upgradeBtn:setPropagateTouchEvents(false)

    else
        -- 去获取
        local getBtn = ui.newButton({
            normalImage = "c_28.png",
            position = cc.p(480, 65),
            text = TR("去获取"),
            clickAction = function ()
                self.mViewPos = cc.p(self.mGridView.mScrollView:getInnerContainer():getPosition())
                ui.showFlashView("请关注运营活动")
            end
            })
        self.mAttrSprite:addChild(getBtn)
        getBtn:setPropagateTouchEvents(false)
    end
end

--得到对应数据和背包控件的类型
function QFashionDebrisView:getItemData()

    local fashionDebrisData = clone(GoodsObj:getShiZhuangDebrisList())

	table.sort(fashionDebrisData, function (a, b)
        local canComposeA = GoodsModel.items[a.ModelId].maxNum == a.Num
        local canComposeB = GoodsModel.items[b.ModelId].maxNum == b.Num

        -- 可以合成的阵诀碎片排在最前面
        if canComposeA ~= canComposeB then
            return canComposeA
        end

		--高品质碎片排前面
       	if GoodsModel.items[a.ModelId].quality ~= GoodsModel.items[b.ModelId].quality then
            return GoodsModel.items[a.ModelId].quality > GoodsModel.items[b.ModelId].quality
        end

        --比较数量
        if a.Num ~= b.Num then
        	return a.Num > b.Num
        end

        --比较模型Id
        if a.ModelId ~= b.ModelId then
        	return a.ModelId < b.ModelId
        end

        return a.Id < b.Id

	end)

	return fashionDebrisData
end

-------------------------------网络请求-------------------------
-- 碎片合成
function QFashionDebrisView:requestUpgrade(data, num)
    HttpClient:request({
        moduleName = "Goods",
        methodName = "GoodsUse",
        svrMethodData = {data.Id, data.ModelId, num},
        callback = function (response)
            if not response or response.Status ~= 0 then
                return
            end
            self:refreshGrid()
            FashionObj:refreshFashionList()
            MsgBoxLayer.addGameDropLayer(response.Value.BaseGetGameResourceList, {}, " ", "合成", {{text = TR("确定")}}, {})
        end
    })
end

return QFashionDebrisView
