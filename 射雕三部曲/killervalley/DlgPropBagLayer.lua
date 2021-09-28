--[[
	文件名：DlgPropBagLayer.lua
	描述：绝情谷的道具包裹界面
	创建人：peiyaoqiang
	创建时间：2018.1.25
--]]

local DlgPropBagLayer = class("DlgPropBagLayer", function(params)
	return display.newLayer(cc.c4b(0, 0, 0, 0))
end)

--[[
{
    propItemList        可拾取的道具列表
}
--]]
function DlgPropBagLayer:ctor(params)
    -- 初始化数据
    self.propItemList = {}
    local function addProp(modelId, num)
        for i=1,num do
            if (table.nums(self.propItemList) < KillerValleyHelper.maxBagCount) then
                local tmpItem = clone(KillervalleyGoodsModel.items[modelId])
                tmpItem.Id = modelId * 100 + i  -- 为了区分相同类型的道具，生成唯一ID
                tmpItem.ModelId = modelId
                table.insert(self.propItemList, tmpItem)
            end
        end
    end
    for strModelId,ownNum in pairs(KillerValleyHelper.bagGoodsList or {}) do
        addProp(tonumber(strModelId), ownNum)
    end
    table.sort(self.propItemList, function (a, b)
            -- 飞刀和银针的ID最小，排在最后显示
            return a.ModelId > b.ModelId
        end)
    
    -- 创建背景框
    self.mBgSize = cc.size(480, 400)
    self.mBgLayer = ui.newScale9Sprite("jqg_4.png", self.mBgSize)
    self.mBgLayer:setPosition(cc.p(display.cx, display.cy))
    self.mBgLayer:setScale(Adapter.MinScale)
    self:addChild(self.mBgLayer)

    -- 触摸图片外面关闭
    ui.registerSwallowTouch({
        node = self,
        allowTouch = true,
        beganEvent = function(touch, event)
            return true
        end,
        endedEvent = function(touch, event)
            if not ui.touchInNode(touch, self.mBgLayer) then
                LayerManager.removeLayer(self)
            end
        end,
    })

    -- 关闭按钮
    local btnClose = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(self.mBgSize.width - 10, self.mBgSize.height - 10),
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self.mBgLayer:addChild(btnClose, 1)

    -- 初始化UI
    self:initUI()
end

-- 刷新显示
function DlgPropBagLayer:initUI()
    local nCount = table.nums(self.propItemList)
    if (nCount == 0) then
        local introLabel = ui.newLabel({
            text = TR("还没捡到任何道具哦~"),
            size = 30,
            x = self.mBgSize.width / 2,
            y = 240,
        })
        self.mBgLayer:addChild(introLabel)
    else
        -- 道具列表
        local listViewSize = cc.size(self.mBgSize.width - 40, 264)
        local mListView = ccui.ListView:create()
        mListView:setDirection(ccui.ScrollViewDir.vertical)
        mListView:setBounceEnabled(true)
        mListView:setTouchEnabled(false)
        mListView:setContentSize(listViewSize)
        mListView:setPosition(20, 120)
        self.mBgLayer:addChild(mListView)

        -- 显示所有道具
        local nLine = math.ceil(nCount / 3)
        local cellSize = cc.size(listViewSize.width, listViewSize.height / 2)
        local perWidth = cellSize.width / 6
        for i=1,nLine do
            local lvItem = ccui.Layout:create()
            lvItem:setContentSize(cellSize)
            mListView:pushBackCustomItem(lvItem)

            local yPos = cellSize.height / 2 + 10
            self:createPropNode(lvItem, cc.p(perWidth * 1, yPos), (i-1)*3+1)
            self:createPropNode(lvItem, cc.p(perWidth * 3, yPos), (i-1)*3+2)
            self:createPropNode(lvItem, cc.p(perWidth * 5, yPos), (i-1)*3+3)
        end
    end

    -- 使用和丢弃按钮
    local btnUse = ui.newButton({
        normalImage = "jqg_39.png",
        text = TR("使用"),
        position = cc.p(self.mBgSize.width * 0.3, 55),
        clickAction = function()
            -- 飞刀和冰魄银针不能在这里使用
            local selectModelId = 0
            for _,v in ipairs(self.propItemList) do
                if (self.selectedId ~= nil) and (self.selectedId == v.Id) then
                    selectModelId = v.ModelId
                    break
                end
            end
            if (selectModelId == 1) or (selectModelId == 2) then
                ui.showFlashView(TR("%s%s%s和%s%s%s需要在战场里直接释放", 
                    "#FF3333", KillervalleyGoodsModel.items[1].name, Enums.Color.eNormalWhiteH, 
                    "#FF3333", KillervalleyGoodsModel.items[2].name, Enums.Color.eNormalWhiteH))
            else
                if (selectModelId > 0) then
                    KillerValleyHelper:useProp(selectModelId, function (retValue)
                        if retValue.Code == 0 then
                            KillerValleyHelper:delOneProp(selectModelId)
                            LayerManager.removeLayer(self)
                        end
                    end)
                end
            end
        end
    })
    local btnDrop = ui.newButton({
        normalImage = "jqg_39.png",
        text = TR("丢弃"),
        position = cc.p(self.mBgSize.width * 0.7, 55),
        clickAction = function()
            local selectModelId = 0
            for _,v in ipairs(self.propItemList) do
                if (self.selectedId ~= nil) and (self.selectedId == v.Id) then
                    selectModelId = v.ModelId
                    break
                end
            end
            if (selectModelId > 0) then
                KillerValleyHelper:dropProp(selectModelId, function (retValue)
                    if retValue.Code == 0 then
                        KillerValleyHelper:delOneProp(selectModelId)
                        LayerManager.removeLayer(self)
                    end
                end)
            end
        end
    })
    self.mBgLayer:addChild(btnUse)
    self.mBgLayer:addChild(btnDrop)
end

----------------------------------------------------------------------------------------------------

-- 创建可选择的道具
function DlgPropBagLayer:createPropNode(parent, pos, index)
    local item = self.propItemList[index]
    if (item == nil) or (item.Id == nil) then
        return nil
    end

    local node = KillerValleyUiHelper:createPropHeader({
        ModelId = item.ModelId,
        showName = true,
        showSelected = false,
        onClickCallback = function (target)
            self:selectOneItem(target, item)
        end
    })
    node:setAnchorPoint(cc.p(0.5, 0.5))
    node:setPosition(pos)
    parent:addChild(node)

    -- 默认选中第一个
    if (index == 1) then
        self:selectOneItem(node, item)
    end
    
    return node
end

-- 选中某个道具
function DlgPropBagLayer:selectOneItem(node, item)
    local propModel = KillervalleyGoodsModel.items[item.ModelId]
    if (propModel == nil) then
        return
    end
    if (self.selectedId ~= nil) and (self.selectedId == item.Id) then
        return
    end

    -- 取消之前的选择
    if (self.selectedNode ~= nil) then
        self.selectedNode:setSelected(false)
        self.selectedNode = nil
    end

    -- 选中当前道具
    if (self.selectedLabel == nil) then
        local introLabel = ui.newLabel({
            text = "",
            size = 18,
            x = self.mBgSize.width / 2,
            y = 90,
        })
        introLabel:setAnchorPoint(cc.p(0.5, 0))
        self.mBgLayer:addChild(introLabel)
        self.selectedLabel = introLabel
    end
    self.selectedLabel:setString(propModel.intro)
    node:setSelected(true)
    
    -- 保存当前的选择
    self.selectedNode = node
    self.selectedId = item.Id
end

----------------------------------------------------------------------------------------------------

return DlgPropBagLayer