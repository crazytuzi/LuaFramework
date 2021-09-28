--[[
	文件名：PvpConFightResultLayer.lua
	描述：豪侠榜连战5次返回结果界面
	创建人：chenqiang
	创建时间：2016.09.23
--]]

local PvpConFightResultLayer = class("PvpConFightResultLayer", function()
	return display.newLayer()
end)

-- 构造函数
--[[
	params:{
		data: 战斗返回结果信息
	}
]]
function PvpConFightResultLayer:ctor(params)
	-- 参数
	self.mData = params.data
	-- 战斗次数
	self.mCount = 5

	-- 动画
	self.mNeedAction = true
	self.mAddAction = nil
	self.mCurIndex = 1

	-- 创建层
	self:createLayer()

	-- 提取数据
	self:extractData()

	self:showFightResult()
end

-- 创建背景层
function PvpConFightResultLayer:createLayer()
	-- 创建背景框
	local bgLayer = require("commonLayer.PopBgLayer").new({
		title = TR("连战"),
		bgSize = cc.size(620, 975),
		closeAction = function()
			LayerManager.removeLayer(self)
		end
	})
	self:addChild(bgLayer)

	-- 保存背景框的相关数据
	self.mBgSprite = bgLayer.mBgSprite
	self.mBgSize = bgLayer.mBgSprite:getContentSize()
	self.mCloseButton = bgLayer.mCloseButton
	self.mCloseButton:setLocalZOrder(1)

	self:initUI()
end

-- 初始化UI
function PvpConFightResultLayer:initUI()
	local listBgLayer = ui.newScale9Sprite("c_17.png",cc.size(self.mBgSize.width - 60, self.mBgSize.height - 170))
	listBgLayer:setAnchorPoint(0.5,0.5)
	listBgLayer:setPosition(self.mBgSize.width / 2, self.mBgSize.height / 2 + 20)
	self.mBgSprite:addChild(listBgLayer)

	-- 创建listView
	local listViewSize = cc.size(self.mBgSize.width - 70, self.mBgSize.height - 180)
	self.mListView = ccui.ListView:create()
	self.mListView:setDirection(ccui.ScrollViewDir.vertical)
	self.mListView:setContentSize(cc.size(540, 785))
	self.mListView:setGravity(ccui.ListViewGravity.centerVertical)
	self.mListView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
	self.mListView:setItemsMargin(5)
	self.mListView:setBounceEnabled(true)
	self.mListView:setScrollBarEnabled(false)
	self.mListView:setAnchorPoint(cc.p(0.5, 0))
	self.mListView:setPosition(self.mBgSize.width * 0.5, 115)
	self.mBgSprite:addChild(self.mListView)

	-- 确定按钮
	local button = ui.newButton({
		normalImage = "c_28.png",
		text = TR("确定"),
		anchorPoint = cc.p(0.5, 0.5),
		position = cc.p(self.mBgSize.width * 0.5, 60),
		clickAction = function()
			LayerManager.removeLayer(self)
		end
	})
	self.mBgSprite:addChild(button)
end

--============================显示相关==============================
local Item = {
	width = 540,
	height = 130
}

-- 显示战斗结果列表
function PvpConFightResultLayer:showFightResult()
	if self.mNeedAction then
		self.mCurIndex = 1
		self.mAddAction = Utility.schedule(self, function()
			local item = self:createItem(self.mCurIndex)
			self.mListView:pushBackCustomItem(item)

			-- 动画
			self.mListView:jumpToBottom()
			self:playResultAppear(item)

			self.mCurIndex = self.mCurIndex + 1
			-- 判断所有item都创建完成后，停止动画
			if self.mCurIndex > self.mCount then
				self:stopAction(self.mAddAction)
			end
		end, 0.5)
	else
		-- 添加所有item
		for i = 1, self.mCount do
			local item = self:createItem(i)
			self.mListView:pushBackCustomItem(item)
		end
		self.mListView:jumpToBottom()
	end
end

-- 创建单个条目信息
function PvpConFightResultLayer:createItem(index)
	local data = self.mItemData[index]

	-- 创建item容器
	local item = ccui.Layout:create()
	item:setContentSize(cc.size(Item.width, Item.height))
	item:setAnchorPoint(0.5, 0.5)

	-- 添加背景
	local bgSprite = ui.newScale9Sprite("c_18.png", cc.size(Item.width, Item.height))
	bgSprite:setAnchorPoint(0, 0)
	item:addChild(bgSprite)

	local labelInfo = {
		color = Enums.Color.eBlack,
        anchorPoint = cc.p(0, 0.5),
        x = 38,
        y = Item.height/2 + 27,
	}

	-- 添加战斗结果
	labelInfo.text = TR("第%d次挑战:  %s成功", index, Enums.Color.eNormalGreenH)
	item:addChild(ui.newLabel(labelInfo))

	-- 消耗的耐力
	labelInfo.text = string.format("{%s}%s",
    	Utility.getDaibiImage(ResourcetypeSub.eSTA),
    	"-2"
    )
    labelInfo.x = 330
    item:addChild(ui.newLabel(labelInfo))

	-- 添加基础掉落
	labelInfo.text = ""
	labelInfo.x = 38
	labelInfo.y = labelInfo.y - 55
	for i, attr in ipairs(data.attr) do
		local str = string.format("{%s}%-13s",
	    	Utility.getDaibiImage(attr.ResourceTypeSub),
	    	Utility.numberWithUnit(attr.Num, 0)
	    )
		labelInfo.text = labelInfo.text .. str
	end
	item:addChild(ui.newLabel(labelInfo))

	-- 添加翻牌资源掉落
	if data.choice then
		local card = CardNode.createCardNode({
	        resourceTypeSub = data.choice.ResourceTypeSub,
	        modelId = data.choice.ModelId,
	        cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eName, CardShowAttr.eNum},
	        num = data.choice.Num,
	        cardShape = Enums.CardShape.eSquare,
	    })
	    card:setPosition(Item.width - 90, Item.height / 2 + 13)
	    item:addChild(card)
	end

	return item
end

--===========================数据相关==========================
-- 提取数据
function PvpConFightResultLayer:extractData()
	-- 每次的数据
	self.mItemData = {}
	for i = 1, self.mCount do
		local data = {}
		data.choice = self.mData.ChoiceGetGameResource[i]
		data.attr = self.mData.BaseGetGameResourceList[i].PlayerAttr

		self.mItemData[i] = data
	end
end

--=======================动画相关==========================
-- 每个条目的动画
function PvpConFightResultLayer:playResultAppear(node)
	node:setScale(0)

	local scale = cc.ScaleTo:create(0.3, 1)
	local sequence = cc.Sequence:create( cc.EaseSineOut:create(scale) )
    node:runAction(sequence)
end

return PvpConFightResultLayer
