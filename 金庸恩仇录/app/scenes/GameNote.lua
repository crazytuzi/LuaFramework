require("game.Biwu.BiwuFuc")
require("game.GameConst")
require("utility.richtext.richText")

local Item = class("Item", function()
	return display.newNode()
end)

function Item:ctor(param)
	self.open = false
	local contentSizeHeight = 0
	self.itemData = param.itemData
	self.index = self.itemData.index
	local callFunc = param.callFunc
	local proxy = CCBProxy:create()
	self.rootnode = {}
	local node = CCBuilderReaderLoad("ccbi/gamenote/noteItem_sys.ccbi", proxy, self.rootnode)
	self:setContentSize(node:getContentSize())
	self:addChild(node)
	local item_bg = self.rootnode.item_bg
	
	addNodeTouchListener(item_bg, function(event)
		if event.name == EventType.ended and callFunc ~= nil then
			callFunc(self.index)
		end
	end)
	
	if self.itemData.title then
		local textNode = self.rootnode.text_node
		local title_color = cc.c3b(checkint(string.format("%s", "0x" .. string.sub(self.itemData.tcolor, 1, 2))), checkint(string.format("%s", "0x" .. string.sub(self.itemData.tcolor, 3, 4))), checkint(string.format("%s", "0x" .. string.sub(self.itemData.tcolor, 5, 6))))
		local titleLable = ui.newTTFLabel({
		text = self.itemData.title,
		font = FONTS_NAME.font_fzcy,
		align = ui.TEXT_ALIGN_LEFT,
		size = tonumber(self.itemData.tsize),
		color = title_color
		})
		titleLable:setAnchorPoint(0, 0.5)
		titleLable:setPosition(0, textNode:getContentSize().height / 2)
		textNode:addChild(titleLable)
	end
	local timeLabel = self.rootnode.timeLabel
	--timeLabel:setFontName(FONTS_NAME.font_fzcy)
	local stateSprite = self.rootnode.stateSprite
	stateSprite:setVisible(false)
	timeLabel:setVisible(false)
	if self.itemData.status == "normal" then
		stateSprite:setVisible(false)
		timeLabel:setVisible(true)
		timeLabel:setString(self.itemData.showtime)
	elseif self.itemData.status == "hot" then
		stateSprite:setVisible(true)
		timeLabel:setVisible(false)
	elseif self.itemData.status == "new" then
		stateSprite:setVisible(true)
		timeLabel:setVisible(false)
	end
	if self.itemData.index == 1 then
		self.open = true
	end
	self:setContentVisible()
	if self.itemData.description ~= nil then
		local contentNode = self.rootnode.contentLabel
		local hrefHandler = function(url)
			if #url > 0 then
				device.openURL(url)
			end
		end
		local contentLabel = getRichText(self.itemData.description, contentNode:getContentSize().width - 10, hrefHandler, 10)
		contentLabel:setPosition(10, contentLabel:getContentSize().height - contentLabel.offset)
		contentNode:addChild(contentLabel)
		contentNode:setContentSize(cc.size(contentNode:getContentSize().width, contentLabel:getContentSize().height + 15))
		contentNode:setVisible(false)
		if self.itemData.index == 1 then
			contentSizeHeight = contentNode:getContentSize().height
			contentNode:setVisible(true)
		end
	end
end

function Item:getContentSizeHeight()
	if self.open == true then
		local contentNode = self.rootnode.contentLabel
		return contentNode:getContentSize().height
	else
		return 0
	end
end

function Item:setContentVisible()
	local contentNode = self.rootnode.contentLabel
	local stateSprite = self.rootnode.stateSprite
	if self.open == true then
		contentNode:setVisible(true)
		if self.itemData.status == "new" then
			stateSprite:setDisplayFrame(display.newSprite("#gamenote_new01.png"):getDisplayFrame())
		else
			stateSprite:setDisplayFrame(display.newSprite("#gamenote_hot01.png"):getDisplayFrame())
		end
	else
		contentNode:setVisible(false)
		if self.itemData.status == "new" then
			stateSprite:setDisplayFrame(display.newSprite("#gamenote_new02.png"):getDisplayFrame())
		else
			stateSprite:setDisplayFrame(display.newSprite("#gamenote_hot02.png"):getDisplayFrame())
		end
	end
end


local GameNote = class("GameNote", function(...)
	return require("utility.ShadeLayer").new()
end)

function GameNote:ctor(param)
	self.callFunc = nil
	local itemNodes = {}
	local proxy = CCBProxy:create()
	local rootnode = rootnode or {}
	local ccb_mm_name = "ccbi/gamenote/gamenote.ccbi"
	local node = CCBuilderReaderLoad(ccb_mm_name, proxy, rootnode)
	self.layer = node--tolua.cast(node, "cc.Layer")
	node:setTouchEnabled(false)
	self.layer:setPosition(display.cx, display.cy)
	self:addChild(self.layer)
	local titleSprite = rootnode.titleSprite
	titleSprite:setDisplayFrame(display.newSprite("#gamenote_title02.png"):getDisplayFrame())
	rootnode.content_bg:setVisible(true)
	rootnode.note_bg_2:setVisible(false)
	rootnode.note_bg:setVisible(true)
	local okBtn = rootnode.btn_ok
	okBtn:setVisible(false)
	local btn_know = rootnode.btn_know
	btn_know:setVisible(true)
	btn_know:setZOrder(1000)
	btn_know:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if self.callFunc ~= nil then
			self.callFunc()
		end
		self:removeSelf()
	end,
	CCControlEventTouchUpInside)
	
	local scrollView = rootnode.scrollView
	local contentViewSize = rootnode.contentView:getContentSize()
	local function itemOnclick(index)
		local height = 0
		local tempItemHeight = 0
		for k, v in pairs(itemNodes) do
			local item = v
			if item.index == index then
				if item.open == true then
					item.open = false
				else
					item.open = true
				end
			else
				item.open = false
			end
			item:setPositionY(-height)
			item:setContentVisible()
			tempItemHeight = item:getContentSize().height
			height = height + item:getContentSize().height + item:getContentSizeHeight()
		end
		local sz = cc.size(contentViewSize.width, contentViewSize.height + height)
		rootnode.descView:setContentSize(sz)
		rootnode.contentView:setPosition(ccp(sz.width / 2, sz.height))
		local scrollViewheight = scrollView:getViewSize().height
		local offset = 0
		if index * tempItemHeight > scrollViewheight / 2 then
			offset = index * tempItemHeight - scrollViewheight / 2
		end
		scrollView:setContentOffset(cc.p(0, -sz.height + scrollView:getViewSize().height + offset), false)
	end
	
	local height = 0
	for i, v in ipairs(param.data) do
		v.index = i
		local item = Item.new({itemData = v, callFunc = itemOnclick})
		item:setPosition(contentViewSize.width / 2, -height)
		rootnode.contentView:addChild(item)
		height = height + item:getContentSize().height + item:getContentSizeHeight()
		table.insert(itemNodes, item)
	end
	local sz = cc.size(contentViewSize.width, contentViewSize.height + height)
	rootnode.descView:setContentSize(sz)
	rootnode.contentView:setPosition(cc.p(sz.width / 2, sz.height))
	scrollView:updateInset()
	scrollView:setContentOffset(cc.p(0, -sz.height + scrollView:getViewSize().height), false)
	
end

function GameNote:setCallBackFun(func)
	self.callFunc = func
end

return GameNote