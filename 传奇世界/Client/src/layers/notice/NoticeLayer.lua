--[[ 公告界面 ]]--
local M = class("NoticeLayer", function() return cc.Node:create() end)

local width, height = 520, 280 
function M:ctor(params, action)
	params = params or { }
	self.data = DATA_Notice:getData()
	dump(self.data)
	self.PATH = "res/layers/notice/"
	-- if not self.data then return end
	-- if #self.data == 0 then return end
	DATA_Notice:setFlag()

	self.curItem = nil
	-- 当前选中item
	self.activityID = 1
	-- 活动ID
	self.base_node, self.view_node = nil, nil

	local parentLayer = params.parentLayer or cc.Director:getInstance():getRunningScene()
	parentLayer:addChild(self, 299)

	local bg = LoginUtils.createSprite(self, "res/layers/notice/bg_min.png", cc.p(g_scrSize.width / 2, g_scrSize.height / 2 + 20))
	LoginUtils.createSprite(bg, "res/layers/notice/notice_title.png", cc.p(bg:getContentSize().width / 2, bg:getContentSize().height - 50), cc.p(0.5, 0.5))

	-- local delLine = cc.LayerColor:create( cc.c4b( 112 , 61 , 20 , 100 ) )
	-- delLine:setContentSize( cc.size( width , 2 ) )
	-- LoginUtils.setNodeAttr( delLine , cc.p( 180 , 150 ) )
	-- bg:addChild( delLine )

	local closeFunc = function()
		bg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 0), cc.CallFunc:create( function() self:removeFromParent() end)))
	end
	local closeBtn = LoginUtils.createTouchItem(bg, "res/component/button/x2.png", cc.p(bg:getContentSize().width - 70, bg:getContentSize().height - 65), closeFunc)


	if action then
		bg:setScale(0.01)
		bg:runAction(cc.ScaleTo:create(0.1, 1))
	end

	local bbox = bg:getBoundingBox()
	bbox.y = bbox.y + 50
	bbox.height = bbox.height - 50
	LoginUtils.registerOutsideCloseFunc(bg, closeFunc, true, nil, bbox)

	self.view_node = cc.Node:create()
	LoginUtils.setNodeAttr(self.view_node, cc.p(20, 0), cc.p(0, 0))
	bg:addChild(self.view_node)

	self:updateCell()

end

function M:createLayout()
	local tempNode = cc.Node:create()
	local group = cc.Node:create()
	local itemSpace = 20
	-- 间隔
	local addY = 0

	if self.data then
		local item = self:createNewItem(self.data[self.activityID])
		LoginUtils.setNodeAttr(item, cc.p(0, addY), cc.p(0, 1))
		addY = addY - item:getContentSize().height - itemSpace
		group:addChild(item)
	end

	addY = math.abs(addY)
	addY = addY < height and height or addY
	tempNode:addChild(group)

	LoginUtils.setNodeAttr(group, cc.p(0, addY < height and height or addY), cc.p(0, 0))
	tempNode:setContentSize(cc.size(width, addY))

	return tempNode
end


-- 统计文字体积
function M:countVolume(_tempStr, fontSize)
	-- 统计实际文字长度
	local tempStr, tempPos = _tempStr, 0
	tempStr, tempPos = string.gsub(tempStr, "[%^]c[%(][a-z]*[%)]", "")
	tempStr, tempPos = string.gsub(tempStr, "[%^]", "")
	local tempText = LoginUtils.createLabel(cc.Node:create(), tempStr, cc.p(0, 0), cc.p(0, 0), fontSize)
	tempText:setDimensions(width - 40, 0)
	local tempSize = tempText:getContentSize()

	return tempSize
end


-- 生成单项
function M:createNewItem(tempData)

	local tempNode = cc.Node:create()
	local addY = 0
	local group = cc.Node:create()

	local space = 10

	if tempData.content then
		for i = 1, #tempData.content do

			local fontSize = 20
			local text = require("src/RichText").new(group, cc.p(0, addY), cc.size(width, 0), cc.p(0, 1), fontSize + 10, fontSize, MColor.yellow_gray)
			text:addText(tempData.content[i], MColor.brown, false)
			text:format()

			addY = addY - text:getContentSize().height - space
		end
	end

	tempNode:addChild(group)
	LoginUtils.setNodeAttr(group, cc.p(0, math.abs(addY)), cc.p(0, 0))
	tempNode:setContentSize(cc.size(width, math.abs(addY)))

	return tempNode
end

function M:updateCell()

	local function refreshCell()

		if self.view_node then self.view_node:removeAllChildren() end
		-- 清除可视内容

		local scrollView1 = cc.ScrollView:create()

		local function scrollView1DidScroll() end
		local function scrollView1DidZoom() end
		scrollView1:setViewSize(cc.size(width, height))
		scrollView1:setPosition(cc.p(100, 55 + 100))
		scrollView1:setScale(1.0)
		scrollView1:ignoreAnchorPointForPosition(true)
		scrollView1:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
		-- cc.SCROLLVIEW_DIRECTION_NONE = -1
		-- cc.SCROLLVIEW_DIRECTION_HORIZONTAL = 0  左右
		-- cc.SCROLLVIEW_DIRECTION_VERTICAL = 1     上下
		-- cc.SCROLLVIEW_DIRECTION_BOTH = 2 左右上下
		scrollView1:setClippingToBounds(true)
		scrollView1:setBounceable(true)
		scrollView1:setDelegate()
		scrollView1:registerScriptHandler(scrollView1DidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
		scrollView1:registerScriptHandler(scrollView1DidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
		self.view_node:addChild(scrollView1)

		local updateData = function()
			local layer = self:createLayout()
			scrollView1:setContainer(layer)
			scrollView1:updateInset()
			local layerSize = layer:getContentSize()
			if layerSize.height > height then
				scrollView1:setContentOffset(cc.p(0, height - layerSize.height))
			end
		end
		updateData()

	end

	refreshCell()

end

return M