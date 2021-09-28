--[[
    文件名: RewardPreviewPopLayer.lua
	描述: 奖励预览弹窗
	创建人: yanghongsheng
	创建时间: 2017.11.16
-- ]]
local RewardPreviewPopLayer = class("RewardPreviewPopLayer", function (params)
	return display.newLayer()
end)

--[[
-- 参数 params中的每项为：
    {
    	title:题目
    	itemsData = {	 项数据列表
    		[1] = {
    			title:				每项标题
				resourceList = {	资源列表
					[1] = {
						resourceTypeSub	资源类型
						modelId, -- 模型Id，
						num,  -- 数量
					}
					......
				}
				
    		}
			......
    	}
    	hint:没有数据的提示
    }
--]]

function RewardPreviewPopLayer:ctor(params)
	params = params or {}
	-- 参数
	self.itemsData = params.itemsData
	self.hint = params.hint
	-- 弹窗
    local parentLayer = require("commonLayer.PopBgLayer").new({
        bgSize = cc.size(586, 730),
        title = params.title,
    })
    self:addChild(parentLayer)

    -- 保存弹框控件信息
    self.mBgSprite = parentLayer.mBgSprite
    self.mBgSize = self.mBgSprite:getContentSize()

	-- 创建页面控件
	self:initUI()
end

function RewardPreviewPopLayer:initUI()
	-- 列表背景
	local listBgSize = cc.size(534, 570)
	local listBgSprite = ui.newScale9Sprite("c_17.png", listBgSize)
	listBgSprite:setPosition(self.mBgSize.width*0.5, self.mBgSize.height*0.52)
	self.mBgSprite:addChild(listBgSprite)

	-- 列表
	if self.itemsData and next(self.itemsData) then
		local listView = ccui.ListView:create()
	    listView:setDirection(ccui.ScrollViewDir.vertical)
	    listView:setBounceEnabled(true)
	    listView:setContentSize(cc.size(listBgSize.width-20, listBgSize.height-20))
	    listView:setItemsMargin(5)
	    listView:setGravity(ccui.ListViewGravity.centerHorizontal)
	    listView:setAnchorPoint(cc.p(0.5, 0.5))
	    listView:setPosition(listBgSize.width*0.5, listBgSize.height*0.5)
	    listBgSprite:addChild(listView)
	    self.rewardListView = listView

	    self:refreshList()
	else
		local emptyHint = ui.createEmptyHint(self.hint or TR("暂无数据"))
		emptyHint:setPosition(self.mBgSize.width*0.5, self.mBgSize.height*0.52)
		self.mBgSprite:addChild(emptyHint)
	end

    -- 确定按钮
	local closeBtn = ui.newButton({
			normalImage = "c_28.png",
			text = TR("确定"),
			clickAction = function ()
				LayerManager.removeLayer(self)
			end
		})
	closeBtn:setPosition(self.mBgSize.width*0.5, self.mBgSize.height*0.08)
	self.mBgSprite:addChild(closeBtn)

	
end

-- 刷新列表
function RewardPreviewPopLayer:refreshList()
	for _, info in pairs(self.itemsData) do
		local item = self:createCell(info)
		self.rewardListView:pushBackCustomItem(item)
	end
end

-- 创建项
function RewardPreviewPopLayer:createCell(info)
	-- 项大小
	local cellSize = cc.size(self.rewardListView:getContentSize().width, 175)

	local layout = ccui.Layout:create()
	layout:setContentSize(cellSize)
	-- 背景
	local bgSprite = ui.newScale9Sprite("c_54.png", cellSize)
	bgSprite:setPosition(cellSize.width*0.5, cellSize.height*0.5)
	layout:addChild(bgSprite)
	-- 题目
	local titleLabel = ui.newLabel({
			text = info.title,
			color = Enums.Color.eWhite,
			size = 24,
			outlineColor = Enums.Color.eBlack,
		})
	titleLabel:setAnchorPoint(cc.p(0.5, 0.5))
	titleLabel:setPosition(cellSize.width*0.5, cellSize.height-20)
	layout:addChild(titleLabel)
	-- 资源
	local cardList = ui.createCardList({
			maxViewWidth = cellSize.width*0.9,
			cardDataList = info.resourceList,
		})
	cardList:setAnchorPoint(cc.p(0.5, 0.5))
	cardList:setPosition(cellSize.width*0.5, cellSize.height*0.4)
	layout:addChild(cardList)

	return layout
end
return RewardPreviewPopLayer