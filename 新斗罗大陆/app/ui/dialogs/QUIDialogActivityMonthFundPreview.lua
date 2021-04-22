--[[	
	文件名称：QUIDialogActivityMonthFundPreview.lua
	创建时间：2017-01-18 11:10:46
	作者：nieming
	描述：QUIDialogActivityMonthFundPreview
]]

local QUIDialog = import(".QUIDialog")
local QUIDialogActivityMonthFundPreview = class("QUIDialogActivityMonthFundPreview", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QListView = import("...views.QListView")
local QUIWidgetActivityMonthFundItem = import("..widgets.QUIWidgetActivityMonthFundItem")

--初始化
function QUIDialogActivityMonthFundPreview:ctor(options)
	local ccbFile = "Dialog_yuejijin_jiangluyulan.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogActivityMonthFundPreview._onTriggerClose)},
	}
	QUIDialogActivityMonthFundPreview.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true
	self._showWidth = self._ccbOwner.listViewLayer:getContentSize().width

	if options then
		self._activityId = options.activityId
	end

	self._ccbOwner.frame_tf_title:setString("奖励预览")
	self:initListView()
end

function QUIDialogActivityMonthFundPreview:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_close) == false then return end
	self:close()
end

function QUIDialogActivityMonthFundPreview:close( )
	app.sound:playSound("common_switch")
	self:playEffectOut()
end

function QUIDialogActivityMonthFundPreview:viewDidAppear()
	QUIDialogActivityMonthFundPreview.super.viewDidAppear(self)
end

function QUIDialogActivityMonthFundPreview:viewWillDisappear()
	QUIDialogActivityMonthFundPreview.super.viewWillDisappear(self)
end

function QUIDialogActivityMonthFundPreview:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogActivityMonthFundPreview:initListView()
	local data = remote.activityMonthFund:getAwardsList(self._activityId)
	self._data = {}
	local itemSequence = {}
	for index,v in ipairs(data or {}) do
		table.insert(itemSequence, v)
		if index%5 == 0 then
			table.insert(self._data, {type = "item", data = itemSequence})
			itemSequence = {}
		end
	end
	if #itemSequence > 0 then
		table.insert(self._data, {type = "item", data = itemSequence})
	end

	local cfg = {
	        renderItemCallBack = function( list, index, info )
	            local isCacheNode = true
	          	local data = self._data[index]

	            local item = list:getItemFromCache(data.type)
          		if item == nil then
		          	if data.type == "title" then
	          			item = self:getTitleNode(data.data)
	          		elseif data.type == "item" then
	          			item = self:getItemNode()
	          		elseif data.type == "empty" then
          				item = CCNode:create()
          				item:setContentSize(CCSize(10,10))
		          	end
                	isCacheNode = false
	          	end
	          	if data.type == "title" or data.type == "item" then
	          		item:setData(data.data)
	          	end
	            info.item = item
	            info.size = item:getContentSize()
	            --注册事件
	            if data.type == "item" then
	                list:registerClickHandler(index,"self", function ( )
	                	return true
	                end, nil, handler(self, self.selectItem))
	            end
	            return isCacheNode
	        end,
	        isVertical = true,
	        spaceY = 0,
	        spaceX = 10,
	        contentOffsetX = 0,
	        totalNumber = #self._data,
	        enableShadow = false,
	        topShadow = self._ccbOwner.top_shadow,
	        bottomShadow = self._ccbOwner.bottom_shadow,

	    }  
    	self._awardListView = QListView.new(self._ccbOwner.listViewLayer,cfg)
end

function QUIDialogActivityMonthFundPreview:selectItem(x , y, touchNode, list )
	local index = list:getCurTouchIndex()
  	local data = self._data[index]
	for i,item in ipairs(touchNode.items) do
		local pos = item:convertToWorldSpace(ccp(0,0))
		if x > (pos.x + 10) and x < (pos.x + 160) and y < (pos.y - 15) and y > (pos.y - 110) then
			local value = data.data[i]
			app.tip:itemTip(value.award.type, value.award.id)
			return
		end
	end
end

function QUIDialogActivityMonthFundPreview:getTitleNode(title)
	title = title or ""
	local node = CCNode:create()

	-- local sp_bg = CCScale9Sprite:create("ui/common3/floor_title_1.png")
	-- sp_bg:setContentSize(CCSize(670, 40))
	-- sp_bg:setPosition(335,-18)
	-- sp_bg:setColor(ccc3(174,102,0))
	-- node:addChild(sp_bg)

	local titleTF = CCLabelTTF:create(title, global.font_default, 26)
	titleTF:setColor(ccc3(253,237,195))
	titleTF:setPosition(self._showWidth/2, -18)
	node:addChild(titleTF)
	node.setData = function (node, title)
		titleTF:setString(title)
	end
	local tfWidth = titleTF:getContentSize().width

	local sp_left = CCScale9Sprite:create("ui/youhua_tupian/line_half.png")
	-- sp_left:setContentSize(CCSize(670, 40))
	sp_left:setColor(ccc3(190,160,116))
	-- sp_left:setAnchorPoint(ccp(1, 0.5))
	sp_left:setPosition(self._showWidth/2 - tfWidth/2 - sp_left:getContentSize().width/2, -18)
	sp_left:setScaleX(0.6)
	node:addChild(sp_left)

	local sp_right = CCScale9Sprite:create("ui/youhua_tupian/line_half.png")
	-- sp_right:setContentSize(CCSize(670, 40))
	sp_right:setColor(ccc3(190,160,116))
	-- sp_left:setAnchorPoint(ccp(1, 0.5))
	sp_right:setPosition(self._showWidth/2 + tfWidth/2 + sp_right:getContentSize().width/2, -18)
	sp_right:setScaleX(-0.6)
	node:addChild(sp_right)

	-- node:setContentSize(CCSize(677, 40))
	node:setContentSize(CCSize(700, 40))
	return node
end

function QUIDialogActivityMonthFundPreview:getItemNode()
	local node = CCNode:create()
	node.setData = function (node, data)
		node:removeAllChildren()
		node.items = {}
		for index,v in ipairs(data) do
			item = QUIWidgetActivityMonthFundItem.new()
			item:setInfo(v, true)
			local posX = (index-1) * 139
			item:setPositionX(posX)
			node:addChild(item)
			table.insert(node.items, item)
		end
	end

	node:setContentSize(700, 164)
	return node
end

--describe：viewAnimationInHandler 
--function QUIDialogActivityMonthFundPreview:viewAnimationInHandler()
	----代码
--end

--describe：点击Dialog外  事件处理 
function QUIDialogActivityMonthFundPreview:_backClickHandler()
	--代码
	self:close()
end

return QUIDialogActivityMonthFundPreview
