--[[
    文件名: ConFightResultLayer.lua
    创建人: liaoyuangang
    创建时间: 2016-06-15
    描述: 扫荡页面结果展示页面
--]]

local ConFightResultLayer = class("ConFightResultLayer", function(params)
    return display.newLayer()
end)

--[[
    参数:
    {
        dropBaseInfo,  -- 奖励列表, 网络请求返回的 Value.BaseGetGameResourceList
    }
--]]
function ConFightResultLayer:ctor(params)
    -- 获得的物品列表
	self.mDropBaseInfo = params.dropBaseInfo
	-- 解析后的掉落列表
	self.mDropList = Utility.analysisBaseDrop(params.dropBaseInfo)

	-- 列表中每个条目的大小
    self.mListCellSize = cc.size(564, 200)

    -- 添加弹出框层
    local bgLayer = require("commonLayer.PopBgLayer").new({
        title = TR("扫荡结果"),
        bgSize = cc.size(640, 944),
        closeImg = "", -- 不需要关闭按钮
        closeAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self:addChild(bgLayer)

    -- 保存弹窗控件信息
    self.mBgSprite = bgLayer.mBgSprite
    self.mBgSize = bgLayer.mBgSprite:getContentSize()

    -- 显示中间背景
    local tmpBgSprite = ui.newScale9Sprite("c_17.png", cc.size(576, 770))
    tmpBgSprite:setAnchorPoint(cc.p(0.5, 0))
    tmpBgSprite:setPosition(self.mBgSize.width * 0.5, 100)
    self.mBgSprite:addChild(tmpBgSprite)

    -- 动作助手
    -- 初始化页面控件
    self:initUI()
end

-- 初始化页面控件
function ConFightResultLayer:initUI()
    --创建列表
    self.mListView = ccui.ListView:create()
    self.mListView:setContentSize(cc.size(self.mListCellSize.width, 750))
    self.mListView:setItemsMargin(10)
    self.mListView:setDirection(ccui.ListViewDirection.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setAnchorPoint(cc.p(0.5, 0))
    self.mListView:setPosition(self.mBgSize.width * 0.5, 110)
    self.mBgSprite:addChild(self.mListView)

    -- 刷新内容
    self:refreshListView()

    -- 创建返回按钮
    local mCloseBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("确定"),
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    mCloseBtn:setPosition(self.mBgSize.width * 0.5, 60)
    self.mBgSprite:addChild(mCloseBtn)
    -- 初始不显示关闭按钮
    self.mCloseBtn = mCloseBtn
    self.mCloseBtn:setVisible(false)
end

-- 获取恢复数据
function ConFightResultLayer:getRestoreData()
    local retData = {
    	dropBaseInfo = self.mDropBaseInfo,
    }

    return retData
end

-- 刷新扫荡节点信息列表
function ConFightResultLayer:refreshListView()
    self.mListView:removeAllChildren()
	for index = 1, #self.mDropList do
        local lvItem = ccui.Layout:create()
        lvItem:setAnchorPoint(cc.p(0.5, 0.5))
        lvItem:setIgnoreAnchorPointForPosition(false)
        lvItem:setContentSize(self.mListCellSize)
        self.mListView:pushBackCustomItem(lvItem)

        self:refreshListViewItem(index)
    end

    -- 设置动画效果
    self.mListView:forceDoLayout()

	local innerNode = self.mListView:getInnerContainer()
	local listSize = self.mListView:getContentSize()
	local innerHeight = #self.mDropList * (self.mListCellSize.height + 10) - 10
	for index = 1, #self.mDropList do
		local tempNode = self.mListView:getItem(index - 1)
		tempNode:setVisible(false)
		tempNode:setScale(1.3)
        local actionList = {
        	cc.DelayTime:create((index - 1) * 0.5),
        	cc.CallFunc:create(function()
        		-- 如果条目没在显示区域内，这需要设置Inner的位置
        		local tempHeight = index * (self.mListCellSize.height + 10) - 10
        		local offSetY = tempHeight - listSize.height
        		if offSetY > 0 then
        			innerNode:setPositionY(listSize.height - innerHeight + offSetY)
        		end

        		tempNode:setVisible(true)
        	end),
            cc.ScaleTo:create(1/30 * 7, 0.9),
            cc.ScaleTo:create(1/30 * 2, 1.0),
            cc.CallFunc:create(function()
                if index > 10 then
                    self.mCloseBtn:setVisible(true)
                end
                if index == #self.mDropList then
                    self.mCloseBtn:setVisible(true)
                	-- 检查是否升级
                    PlayerAttrObj:showUpdateLayer()
                end
            end)
        }
        tempNode:runAction(cc.Sequence:create(actionList))
	end
end

-- 刷新扫荡节点信息中的一个条目
function ConFightResultLayer:refreshListViewItem(index)
	local lvItem = self.mListView:getItem(index - 1)
    if not lvItem then
        lvItem = ccui.Layout:create()
        lvItem:setContentSize(self.mListCellSize)
        self.mListView:insertCustomItem(lvItem, index - 1)
    end
    lvItem:removeAllChildren()

    local itemData = clone(self.mDropList[index])
    local resTypeList = {ResourcetypeSub.eGold, ResourcetypeSub.eEXP, ResourcetypeSub.eHeroExp}
	local attrList = Utility.splitDropPlayerAttr(itemData, resTypeList)
    table.sort(itemData, function(item1, item2)
        -- 比较品质
        local colorLv1 = Utility.getColorLvByModelId(item1.modelId, item1.resourceTypeSub)
        local colorLv2 = Utility.getColorLvByModelId(item2.modelId, item2.resourceTypeSub)
        if colorLv1 ~= colorLv2 then
            return colorLv1 > colorLv2
        end

        return (item1.modelId or 0) > (item2.modelId or 0)
    end)

    -- 条目的背景
    local cellBgSprite = ui.newScale9Sprite("c_54.png", self.mListCellSize)
    cellBgSprite:setPosition(self.mListCellSize.width / 2, self.mListCellSize.height / 2)
    lvItem:addChild(cellBgSprite)

    -- 标题
    local titleLabel = ui.newLabel({
        text = TR("第%d次战斗", index),
        size = 24,
        color = Enums.Color.eWhite,
        outlineColor = cc.c3b(0x8c, 0x4a, 0x39),
        outlineSize = 2,
    })
    titleLabel:setPosition(self.mListCellSize.width / 2, self.mListCellSize.height - 22)
    cellBgSprite:addChild(titleLabel)

    -- 显示玩家获得属性
    local yPosList = {130, 80, 30}
    for attrIndex, item in ipairs(attrList) do
        local daibiBgSprite = ui.newScale9Sprite("c_24.png", cc.size(150, 38))
        daibiBgSprite:setAnchorPoint(cc.p(0, 0.5))
        daibiBgSprite:setPosition(cc.p(30, yPosList[attrIndex]))
        cellBgSprite:addChild(daibiBgSprite)

        local tempItem = clone(item)
        tempItem.fontColor = cc.c3b(0x46, 0x22, 0x0d)

        local tempNode = ui.createDaibiView(tempItem)
        tempNode:setAnchorPoint(cc.p(0, 0.5))
        tempNode:setPosition(20, yPosList[attrIndex])
        cellBgSprite:addChild(tempNode)
    end

    -- 显示其他掉落物品
    if (itemData ~= nil) and (#itemData > 0) then
        local cardListNode = ui.createCardList({
            maxViewWidth = self.mListCellSize.width - 205,
            cardDataList = itemData,
            allowClick = true
        })
        cardListNode:setAnchorPoint(cc.p(0, 0.5))
        cardListNode:setPosition(190, 80)
        cellBgSprite:addChild(cardListNode)
    else
        local infoLabel = ui.newLabel({
            text = TR("本次无物品掉落"),
            size = 24,
            color = Enums.Color.eRed,
            outlineColor = Enums.Color.eBlack,
            outlineSize = 2,
        })
        infoLabel:setPosition(370, 80)
        cellBgSprite:addChild(infoLabel)
    end
end

return ConFightResultLayer
