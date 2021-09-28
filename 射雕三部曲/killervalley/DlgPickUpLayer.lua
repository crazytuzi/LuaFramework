--[[
	文件名：DlgPickUpLayer.lua
	描述：绝情谷的物品拾取对话框
	创建人：peiyaoqiang
	创建时间：2018.1.25
--]]

local DlgPickUpLayer = class("DlgPickUpLayer", function(params)
	return display.newLayer()
end)

--[[
{
	propItemList		可拾取的道具列表
}
--]]
function DlgPickUpLayer:ctor(params)
    --dump(params, "params")
    -- 初始化数据
    self.packageInfo = params.packageInfo
    self.propItemList = {}
    self.selectPropList = {}    -- 已经选择的道具
    for i,v in ipairs(self.packageInfo.GoodsId) do
        local modelId = tonumber(v)
        local tmpItem = clone(KillervalleyGoodsModel.items[modelId])
        tmpItem.Id = modelId * 100 + i  -- 为了区分相同类型的道具，生成唯一ID
        tmpItem.ModelId = modelId
        table.insert(self.propItemList, tmpItem)
    end
    
	-- 创建背景框
	local bgLayer = require("commonLayer.PopBgLayer").new({
		title = TR("拾取道具"),
		bgSize = cc.size(510, 470),
		closeImg = "c_29.png",
		closeAction = function()
			LayerManager.removeLayer(self)
		end
	})
	self:addChild(bgLayer)

    self.mBgLayer = bgLayer.mBgSprite
    self.mBgSize = self.mBgLayer:getContentSize()

    -- 初始化UI
    self:initUI()
end

-- 刷新显示
function DlgPickUpLayer:initUI()
    -- 提示文字
    local infoLabel = ui.newLabel({
        text = TR("请选择您要拾取的道具:"),
        color = cc.c3b(0x46, 0x22, 0x0d),
    })
    infoLabel:setPosition(self.mBgSize.width * 0.5, self.mBgSize.height - 80)
    self.mBgLayer:addChild(infoLabel)

	-- 半透明背景
    local grayBgSize = cc.size(self.mBgSize.width - 60, 278)
    local grayBgSprite = ui.newScale9Sprite("c_17.png", grayBgSize)
	grayBgSprite:setPosition(self.mBgSize.width * 0.5, self.mBgSize.height - 235)
	self.mBgLayer:addChild(grayBgSprite)

    -- 道具列表
    -- 用一个list保存所有道具，点击可以选中，选中后把Id放到一个单独的列表里
    local mListView = ccui.ListView:create()
    mListView:setDirection(ccui.ScrollViewDir.vertical)
    mListView:setBounceEnabled(true)
    mListView:setTouchEnabled(false)
    mListView:setContentSize(grayBgSize)
    mListView:setPosition(0, 0)
    grayBgSprite:addChild(mListView)

    -- 显示所有道具
    local nCount = table.nums(self.propItemList)
    local nLine = math.ceil(nCount / 3)
    local cellSize = cc.size(grayBgSize.width, 137)
    local perWidth = cellSize.width / 6
    for i=1,nLine do
        local lvItem = ccui.Layout:create()
        lvItem:setContentSize(cellSize)
        mListView:pushBackCustomItem(lvItem)

        local yPos = cellSize.height / 2 + 13
        self:createPropNode(lvItem, cc.p(perWidth * 1, yPos), (i-1)*3+1)
        self:createPropNode(lvItem, cc.p(perWidth * 3, yPos), (i-1)*3+2)
        self:createPropNode(lvItem, cc.p(perWidth * 5, yPos), (i-1)*3+3)
    end

    -- 确定按钮
	local button = ui.newButton({
		normalImage = "c_28.png",
    	text = TR("拾取"),
        position = cc.p(self.mBgSize.width * 0.5, 55),
        clickAction = function()
            local selectModelList = {}
            for _,v in ipairs(self.propItemList) do
                if self:isChecked(v.Id) then
                    table.insert(selectModelList, v.ModelId)
                end
            end
            local nCount = #selectModelList
            if (nCount == 0) then
                ui.showFlashView(TR("请选择您要拾取的道具"))
                return
            end
            local emptyCount = KillerValleyHelper:getBagEmptyCount()
            if (nCount > emptyCount) then
                ui.showFlashView(TR("您的包裹只剩%d个空闲格子", emptyCount))
                return
            end
            local strSelect = self:getSelectString(selectModelList)
            KillerValleyHelper:pickupProp(self.packageInfo.UniqueId, selectModelList, function (retValue)
                    if retValue.Code == 0 then
                        for _,v in ipairs(selectModelList) do
                            KillerValleyHelper:addOneProp(v)
                        end
                        ui.showFlashView(strSelect)
                        LayerManager.removeLayer(self)
                    end
                end)
        end
    })
    self.mBgLayer:addChild(button)

    -- 剩余空位
    local gridCount = KillerValleyHelper:getBagEmptyCount()
    local countColorH = (gridCount == 0) and Enums.Color.eRedH or Enums.Color.eNormalGreenH
    local countLabel = ui.newLabel({
        text = TR("包裹剩余空位:%s%d", countColorH, gridCount),
        color = cc.c3b(0x46, 0x22, 0x0d),
        size = 20,
    })
    countLabel:setAnchorPoint(cc.p(0, 0.5))
    countLabel:setPosition(self.mBgSize.width * 0.5 + 70, 55)
    self.mBgLayer:addChild(countLabel)
end

----------------------------------------------------------------------------------------------------

-- 创建可选择的道具
function DlgPickUpLayer:createPropNode(parent, pos, index)
    local item = self.propItemList[index]
    if (item == nil) or (item.Id == nil) then
        return nil
    end

    local node = KillerValleyUiHelper:createPropHeader({
        ModelId = item.ModelId,
        showName = true,
        showSelected = false,
        onClickCallback = function (target)
            if self:isChecked(item.Id) then
                target:setChecked(false)
                self:cancelItem(item.Id)
            else
                target:setChecked(true)
                self:checkItem(item.Id)
            end
        end
    })
    local nodeSize = node:getContentSize()
    node:setAnchorPoint(cc.p(0.5, 0.5))
    node:setPosition(pos)
    parent:addChild(node)

    -- 选中函数
    node.setChecked = function (target, state)
        if (node.checkSprite ~= nil) then
            node.checkSprite:removeFromParent()
            node.checkSprite = nil
        end
        local tmpSprite = ui.newSprite((state == true) and "c_61.png" or "c_60.png")
        tmpSprite:setAnchorPoint(cc.p(0, 0))
        tmpSprite:setPosition(nodeSize.width - 32, nodeSize.height - 32)
        target:addChild(tmpSprite, 1)
        target.checkSprite = tmpSprite
    end
    -- 如果包裹未满，则默认勾选
    if (index <= KillerValleyHelper:getBagEmptyCount()) then
        node:setChecked(true)
        self:checkItem(item.Id)
    else
        node:setChecked(false)
        self:cancelItem(item.Id)
    end
    
    return node
end

-- 判断某个道具是否已选中
function DlgPickUpLayer:isChecked(itemId)
    return (self.selectPropList[itemId] ~= nil)
end

-- 选中某个道具
function DlgPickUpLayer:checkItem(itemId)
    self.selectPropList[itemId] = 1
end

-- 取消某个道具
function DlgPickUpLayer:cancelItem(itemId)
    self.selectPropList[itemId] = nil
end

-- 构造提示字符串
function DlgPickUpLayer:getSelectString(selectModelList)
    -- 构造带数量的列表
    local selectTypeList = {}
    for _,modelId in ipairs(selectModelList) do
        local typeCount = selectTypeList[modelId] or 0
        selectTypeList[modelId] = (typeCount + 1)
    end

    -- 整合成字符串列表
    local selectStrList = {}
    for modelId,num in pairs(selectTypeList) do
        local tmpName = KillervalleyGoodsModel.items[modelId].name
        if (num > 1) then
            table.insert(selectStrList, tmpName .. "x" .. num)
        else
            table.insert(selectStrList, tmpName)
        end
    end

    -- 整合成最终字符串
    local strSelectType = TR("恭喜您捡到了") .. "#FF3333"
    local typeCount = #selectStrList
    for i,v in ipairs(selectStrList) do
        strSelectType = " " .. strSelectType .. v
        if (i < typeCount) then
            strSelectType = strSelectType .. ","
        end
    end
    return strSelectType
end

----------------------------------------------------------------------------------------------------

return DlgPickUpLayer