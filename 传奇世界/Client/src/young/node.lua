local Myoung = require "src/young/young"; local M = Myoung.beginModule(...)

beginNode = function(node)
	local M = {}
	
	setmetatable(M, M)
	
	M.__index = function(t, k)
		return _G[k]
	end
	
	M.__newindex = function(t, k, v)
		node[k] = v
	end
	
	setfenv(2, M)
	
	return M
end
----------------------------------------------------------------
-- 判断一个触摸点是否在一个node的范围内
-- AABB Axis-Aligned Bounding Box
isTouchInNodeAABB = function(node, touch, range)
	local aabb = range or node:getContentSize()
	local touchPointInNode = node:convertTouchToNodeSpace(touch)
	if touchPointInNode.x >= 0 and touchPointInNode.x < aabb.width and
	   touchPointInNode.y >= 0 and touchPointInNode.y < aabb.height then
		return true
	else
		return false
	end
end

-- 判断一个点是否在一个范围内
isPointInNodeAABB = function(node, point, range)
	local aabb = range or node:getContentSize()
	if point.x >= 0 and point.x < aabb.width and
	   point.y >= 0 and point.y < aabb.height then
		return true
	else
		return false
	end
end

-- node 监听触摸事件
listenTouchEvent = function(parameter)
	if type(parameter) ~= "table" then error("只接受一个 'table' 作为参数", 2) end
	
	local touchBeginHandler = parameter.begin
	local touchMovedHandler = parameter.moved
	local touchEndedHandler = parameter.ended
	local swallow = parameter.swallow
	local priority = parameter.priority
	local node = parameter.node
	
	local  listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches( (swallow == nil) and true or swallow )
    
    listener:registerScriptHandler(function(touch, event)
		--dump( event:getCurrentTarget() )
		if touchBeginHandler then
			return touchBeginHandler(touch, event)
		else
			return false
		end
	end, cc.Handler.EVENT_TOUCH_BEGAN)
	
    listener:registerScriptHandler(function(touch, event)
		if touchMovedHandler then
			touchMovedHandler(touch, event)
		end
	end, cc.Handler.EVENT_TOUCH_MOVED)
	
    listener:registerScriptHandler(function(touch, event)
		if touchEndedHandler then
			touchEndedHandler(touch, event)
		end
	end, cc.Handler.EVENT_TOUCH_ENDED)
	
	local director = cc.Director:getInstance()
	local eventDispatcher = director:getRunningScene():getEventDispatcher()

	if priority then
		eventDispatcher:addEventListenerWithFixedPriority(listener, priority)
	else
		eventDispatcher:addEventListenerWithSceneGraphPriority(listener, node)
	end
	
    return listener
end

-- node 取消监听触摸事件
unregisterListener = function(listener)
	local director = cc.Director:getInstance()
	local eventDispatcher = director:getRunningScene():getEventDispatcher()
	eventDispatcher:removeEventListener(listener)
end

swallowTouchEvent = function(node)
	return Mnode.listenTouchEvent(
	{
		node = node,
		swallow = true,
		begin = function(touch, event)
			local node = event:getCurrentTarget()
			if node.catch then return true end
			
			local touchOutside = not Mnode.isTouchInNodeAABB(node, touch)
			if touchOutside then
				node.catch = touch
				--node.moved = false
			end
			--dump("begin")
			return true
		end,
		
		-- moved = function(touch, event)
			-- local node = event:getCurrentTarget()
			-- if node.catch == touch then
				-- node.moved = true
				-- dump("moved")
			-- end
		-- end,
		
		ended = function(touch, event)
			local node = event:getCurrentTarget()
			if node.catch == touch then
				--dump("ended")
				node.catch = nil
				--if not node.moved then
					--dump("removeFromParent")
					removeFromParent(node)
					AudioEnginer.playTouchPointEffect()
				--else
					--dump("removeFromParent:no")
				--end
			end
		end,
	})
end
----------------------------------------------------------------
reset = function(node)
	node:ignoreAnchorPointForPosition(false)
	node:setAnchorPoint( cc.p(0, 0) )
	node:setPosition(0, 0)
end

setAnchorAndPosition = function(node, anchor, pos)

	-- 设置参数默认值
	if not anchor then anchor = cc.p(0.5, 0.5) end
	if not pos then pos = cc.p(0, 0) end
	
	node:ignoreAnchorPointForPosition(false)
	node:setAnchorPoint(anchor)
	node:setPosition(pos.x, pos.y)
	
end

setScale = function(node, scale)
	if type(scale) == "number" then
		node:setScale(scale)
	elseif type(scale) == "table" then
		if scale.x then node:setScaleX(scale.x) end
		if scale.y then node:setScaleY(scale.y) end
	end
end

addChild = function(parameter)
	if type(parameter) ~= "table" then error("只接受一个 'table' 作为参数", 2) end
	
	local parent = parameter.parent
	local child = parameter.child
	local zOrder = parameter.zOrder
	local scale = parameter.scale
	local contentSize = parameter.cSize
	local tag = parameter.tag
	local hide = parameter.hide
	local swallow = parameter.swallow
	local maskTouch = parameter.maskTouch
	local opacity = parameter.opacity
	
	if not child then return nil end
	
	-- 设置参数默认值
	if not zOrder then zOrder = 0 end
	
	setAnchorAndPosition(child, parameter.anchor, parameter.pos)
	
	if scale then Mnode.setScale(child, scale) end
	if contentSize then child:setContentSize(contentSize) end
	if hide then child:setVisible(false) end
	if opacity then child:setOpacity(opacity) end
	
	if swallow then
		local Mnode = require "src/young/node"
		Mnode.swallowTouchEvent(child)
	elseif maskTouch then
		-- 吞噬触摸
		local Mnode = require "src/young/node"
		Mnode.listenTouchEvent(
		{
			node = child,
			begin = function(touch)
				return true
			end,
		})
	end
	
	if parent then
		if tag then
			parent:addChild(child, zOrder, tag)
		else
			parent:addChild(child, zOrder)
		end
	end
	
	return child
end
----------------------------------------------------------------
-- 创建一个空node
createNode = function(parameter)
	if type(parameter) ~= "table" then error("只接受一个 'table' 作为参数", 2) end
	
	parameter.child = cc.Node:create()
	
	return addChild(parameter)
end
----------------------------------------------------------------
-- 创建 ColorLayer
createColorLayer = function(parameter)
	if type(parameter) ~= "table" then error("只接受一个 'table' 作为参数", 2) end
	
	local src = parameter.src or cc.c4b(0, 0, 0, 255)
	parameter.child = cc.LayerColor:create(src)
	return addChild(parameter)
end
----------------------------------------------------------------
-- 创建精灵
createSprite = function(parameter)
	if type(parameter) ~= "table" then error("只接受一个 'table' 作为参数", 2) end
	
	local sprite = nil
	
	local src = parameter.src
	if type(src) == "string" then
		sprite = cc.Sprite:create(src)
	elseif type(src) == "userdata" then
		sprite = cc.Sprite:createWithSpriteFrame(src)
	end
	
	parameter.child = sprite
	
	return addChild(parameter)
end
----------------------------------------------------------------
-- 创建可缩放的精灵
createScale9Sprite = function(parameter)
	if type(parameter) ~= "table" then error("只接受一个 'table' 作为参数", 2) end
	
	local rect = parameter.rect
	
	local sprite = nil
	
	if rect then
		sprite = cc.Scale9Sprite:create(parameter.src, rect)
	else 
		sprite = cc.Scale9Sprite:create(parameter.src)
	end

	parameter.child = sprite
	
	return addChild(parameter)
end
----------------------------------------------------------------
-- 创建文本控件
createLabel = function(parameter)
	if type(parameter) ~= "table" then error("只接受一个 'table' 作为参数", 2) end
	
	-- 设置参数默认值
	local src = parameter.src or "未设置"
	if type(src) ~= "string" then src = tostring(src) end
	
	local fontFilePath = parameter.path or g_font_path
	local fontSize = parameter.size or 18
	local fontColor = parameter.color or cc.c3b(255, 255, 255)
	local fontBound = parameter.bound or cc.size(0, 0)
	local fontHAlign = parameter.HAlign or cc.TEXT_ALIGNMENT_LEFT
	local fontVAlign = parameter.VAlign or cc.VERTICAL_TEXT_ALIGNMENT_TOP
	local outline = true
	local isOutline = parameter.isOutline
	if parameter.outline ~= nil then
		outline = parameter.outline
	end
	--local label = cc.LabelTTF:create(src, fontFilePath, fontSize, fontBound, fontHAlign, fontVAlign)
	--local label = cc.Label:createWithTTF(src, fontFilePath, fontSize, fontBound, fontHAlign, fontVAlign)
	local label = _G.createLabel(nil,src,nil,nil, fontSize,outline)

	if not label then
	 return nil 
	else
		label:setDimensions(fontBound.width,0)
	end

	if isOutline then
		label:enableOutline( cc.c4b(0, 0, 0, 255) , 2 )
	end
	label:setColor(fontColor)
	
    -- label:runAction(cc.Sequence:create(cc.DelayTime:create(0), cc.CallFunc:create(function()
		-- --label:enableOutline(cc.c4b(10, 10, 10, 255), 1)
		-- --label:enableStroke(cc.c3b(10, 10, 10), 1)
		-- --label:enableShadow(cc.size(10, 10), 255, 1)
	-- end)))
	
	parameter.child = label
	
	return addChild(parameter)
end

-- 创建滚动控件
createScrollView = function(parameter)
	if type(parameter) ~= "table" then error("只接受一个 'table' 作为参数", 2) end
	
	local Mnode = require "src/young/node"
	
	local vertical = parameter.ori == "|"
	local container = parameter.src
	
	local containerSize = container:getContentSize()
	local w, h = containerSize.width, containerSize.height
	local clip = parameter.clip or (vertical and h or w)
	
	local viewSize = vertical and cc.size(w, clip) or cc.size(clip, h)
	
	local scroll = YScrollView:create(viewSize, container)
	
	scroll:setDirection(vertical and YScrollView.VERTICAL or YScrollView.HORIZONTAL)
	scroll:setContentOffset( cc.p(0, viewSize.height - h) )
	
	parameter.child = scroll
	
	if parameter.debug then
		Mnode.addChild(
		{
			parent = container,
			child = cc.LayerColor:create(cc.c4b(225, 137, 67, 100),  viewSize.width, viewSize.height),
			anchor = cc.p(0, 1),
			pos = cc.p(0, h),
		})
	end
	
	return addChild(parameter)
end

-- 创建可编辑控件
createEditBox = function(parameter)
	if type(parameter) ~= "table" then error("只接受一个 'table' 作为参数", 2) end
	
	local src = parameter.src
	local cSize = parameter.cSize
	
	if src then
		local texture = cc.Director:getInstance():getTextureCache():addImage(src)
		local textureSize = texture:getContentSize()
		cSize = cSize or textureSize
		if not cSize.width then cSize.width = textureSize.width end
		if not cSize.height then cSize.width = textureSize.height end
	end
	local placeholder = parameter.hint
	local fontColor = parameter.color or cc.c3b(255, 255, 255)
	local editBox = _G.createEditBox(nil,src,nil,cSize,fontColor,parameter.fontSize,placeholder)
    
	parameter.child = editBox
	parameter.cSize = nil
	
	return addChild(parameter)
end
----------------------------------------------------------------
-- 创建 ListView 
createListView = function(params)
	if type(params) ~= "table" then error("只接受一个 'table' 作为参数", 2) end
	
	----------------------------------------------------------------
	-- 背景
	local bg = params.bg
	----------------------------------------------------------------
	-- item size
	local iSize = params.iSize
	if type(iSize) == "string" then
		iSize = TextureCache:addImage(iSize):getContentSize()
		iSize.height = iSize.height + 2 * (params.iPadding or 0)
	end
	----------------------------------------------------------------
	-- 行数(可以为小数)
	local row = params.row
	if type(row) ~= "number" then row = 1 end
	row = math.max(row, 1)
	----------------------------------------------------------------
	-- 左右的间隙
	local marginLR = params.marginLR or 5

	-- 上下的间隙
	local marginUD = params.marginUD or 5
	----------------------------------------------------------------
	local viewSize = cc.size(iSize.width, iSize.height * row)
	local listViewBgSize = cc.size(viewSize.width + 2 * marginLR, viewSize.height + 2 * marginUD)
	----------------------------------------------------------------
	local root = nil
	if bg then 
		root = Mnode.createScale9Sprite({ src = bg, cSize = listViewBgSize, })
	else
		root = Mnode.createNode({ cSize = listViewBgSize })
	end

	local gv = YGirdView:create(viewSize)
	Mnode.addChild(
	{
		parent = root,
		child = gv,
		pos = cc.p(listViewBgSize.width/2, listViewBgSize.height/2),
	})
	local M = Mnode.beginNode(gv)
	----------------------------------------------------------------
	getRootNode = function(self)
		return self:getParent()
	end
	----------------------------------------------------------------
	-- 每个网格是否一样大小
	local IS_CELLSIZE_IDENTICAL = function(gv)
		return true
	end
	----------------------------------------------------------------
	-- 每个网格的大小
	local SIZE_FOR_CELL = function(gv, idx)
		return iSize.width, iSize.height
	end

	----------------------------------------------------------------
	-- 网格退出视野范围
	local CELL_WILL_RECYCLE = function(gv, cell)
		cell:removeAllChildren()
	end
	----------------------------------------------------------------
	-- 构建标号为idx的网格
	local CELL_AT_INDEX = function(gv, idx)
		--cclog("-----------idx = " .. idx .. "--------")
		
		local createContent = function(cell)
			local handler = gv.onCreateCell
			if handler then handler(gv, idx, cell) end
		end
		
		local cell = gv:dequeueCell()
		if not cell then
			cell = YGirdViewCell:create()
			cell:setContentSize(iSize)
			createContent(cell)
		else
			createContent(cell)
		end
		
		return cell
	end
	----------------------------------------------------------------
	gv:registerEventHandler(CELL_WILL_RECYCLE, YGirdView.CELL_WILL_RECYCLE)
	gv:registerEventHandler(IS_CELLSIZE_IDENTICAL, YGirdView.IS_CELLSIZE_IDENTICAL)
	gv:registerEventHandler(SIZE_FOR_CELL, YGirdView.SIZE_FOR_CELL)
	gv:registerEventHandler(CELL_AT_INDEX, YGirdView.CELL_AT_INDEX)
	gv:setDelegate()
	----------------------------------------------------------------
	return gv
end
----------------------------------------------------------------
-- 排列 nodes, 合并 nodes 为一个 node
combineNode = function(params)
	local Mnode = require "src/young/node"
	
	-- 设置参数默认值
	local params = type(params) ~= "table" and {} or params
	
	local orientation = type(params.ori) ~= "string" and "-" or (params.ori ~= "-" and "|" or "-")
	local horizontal = orientation == "-"
	local vertical = not horizontal
	
	local alignMode = { l = "l", r = "r", t = "t", b = "b", c = "c", }
	local align = type(params.align) ~= "string" and "c" or alignMode[params.align] or "c"
	
	-- 用户提供 nodes 和 margins 的顺序: 水平排列从左到右, 垂直排列从下到上
	local nodes = type(params.nodes) ~= "table" and {} or params.nodes
	local margins = (type(params.margins) ~= "table") and (type(params.margins) == "number" and params.margins or 0) or params.margins
	
	
	-- 计算 nodes 的大小
	local sizes = {}
	local maxWidth, maxHeight = 0, 0
	for i, v in ipairs(nodes) do
		local size
		--if type(v) == type(ccui.RichText:create()) then
		if v.getSize ~= nil then
			size = v:getSize()
		else
			size = v:getContentSize()
			size.width = size.width * v:getScaleX()
			size.height = size.height * v:getScaleY()
		end	
		--log("combineNode size.width"..size.width)
		--log("combineNode size.height"..size.height)
		sizes[i] = size
		if size.width > maxWidth then maxWidth = size.width end
		if size.height > maxHeight then maxHeight = size.height end
	end
	
	local ret = params.root or cc.Node:create()
	
	local ht = function()
	end
	
	local hc = function()
		local x = 0
		local margin = 0
		local total = 0
		for i, v in ipairs(nodes) do
			Mnode.addChild({
				parent = ret,
				child = v,
				pos = cc.p(x + sizes[i].width/2, maxHeight/2),
			})
			
			if i ~= #nodes then
				margin = type(margins) == "table" and margins[i] or margins
				x = x + sizes[i].width + margin
			else
				total = x + sizes[i].width
			end
		end
		ret:setContentSize( cc.size(total, maxHeight) )
	end
	
	local hb = function()
	end
	
	local vl = function()
		local y = 0
		local margin = 0
		local total = 0
		for i, v in ipairs(nodes) do
			Mnode.addChild({
				parent = ret,
				child = v,
				pos = cc.p(sizes[i].width/2, y + sizes[i].height/2),
			})
			
			if i ~= #nodes then
				margin = type(margins) == "table" and margins[i] or margins
				y = y + sizes[i].height + margin
			else
				total = y + sizes[i].height
			end
		end
		ret:setContentSize( cc.size(maxWidth, total) )
	end
	
	local vc = function()
		local y = 0
		local margin = 0
		local total = 0
		for i, v in ipairs(nodes) do
			Mnode.addChild({
				parent = ret,
				child = v,
				pos = cc.p(maxWidth/2, y + sizes[i].height/2),
			})
			
			if i ~= #nodes then
				margin = type(margins) == "table" and margins[i] or margins
				y = y + sizes[i].height + margin
			else
				total = y + sizes[i].height
			end
		end
		ret:setContentSize( cc.size(maxWidth, total) )
	end
	
	local vr = function()
		local y = 0
		local margin = 0
		local total = 0
		for i, v in ipairs(nodes) do
			Mnode.addChild({
				parent = ret,
				child = v,
				pos = cc.p(sizes[i].width/2, y),
			})
			
			if i ~= #nodes then
				margin = type(margins) == "table" and margins[i] or margins
				y = y - sizes[i].height - margin
			else
				total = y - sizes[i].height
			end
		end
		ret:setContentSize( cc.size(maxWidth, -1*total) )
	end
	
	if horizontal and align == "t" then ht()
	elseif horizontal and align == "c" then hc()
	elseif horizontal and align == "b" then hb()
	elseif vertical and align == "l" then vl()
	elseif vertical and align == "c" then vc()
	elseif vertical and align == "r" then vr()
	else error("导向和对齐方式不匹配", 2) end
	
	return ret
end

-- 叠加 nodes, 返回第一个 node
local originType = { 
	lt = "lt", lb = "lb", rt = "rt", rb = "rb",
	c = "c", t = "t", b = "b", l = "l", r = "r",
	lo = "lo", ro = "ro", to = "to", bo = "bo",
	rto = "rto", rbo = "rbo", tlo = "tlo", tro = "tro",
	tc = "tc", lto = "lto",
}

local tOverlaySwitch = {
	lt = function(center, csize, size, offset)
		return cc.p(size.width/2 + offset.x, csize.height - size.height/2 + offset.y)
	end,
	
	lb = function(center, csize, size, offset)
		return cc.p(size.width/2 + offset.x, size.height/2 + offset.y)
	end,
	
	rt = function(center, csize, size, offset)
		return cc.p(csize.width - size.width/2 + offset.x, csize.height - size.height/2 + offset.y)
	end,
	
	rb = function(center, csize, size, offset)
		return cc.p(csize.width - size.width/2 + offset.x, size.height/2 + offset.y)
	end,
	
	c = function(center, csize, size, offset)
		return cc.p(center.x + offset.x, center.y + offset.y)
	end,
	
	t = function(center, csize, size, offset)
		return cc.p(center.x + offset.x, csize.height - size.height/2 + offset.y)
	end,
	
	b = function(center, csize, size, offset)
		return cc.p(center.x + offset.x, size.height/2 + offset.y)
	end,
	
	l = function(center, csize, size, offset)
		return cc.p(size.width/2 + offset.x, center.y + offset.y)
	end,
	
	r = function(center, csize, size, offset)
		return cc.p(csize.width - size.width/2 + offset.x, center.y + offset.y)
	end,
	
	lo = function(center, csize, size, offset)
		return cc.p(-(size.width/2) + offset.x, center.y + offset.y)
	end,
	
	ro = function(center, csize, size, offset)
		return cc.p(csize.width + size.width/2 + offset.x, center.y + offset.y)
	end,
	
	to = function(center, csize, size, offset)
		return cc.p(center.x + offset.x, csize.height + size.height/2 + offset.y)
	end,
	
	bo = function(center, csize, size, offset)
		return cc.p(center.x + offset.x, -(size.height/2) + offset.y)
	end,
	
	rbo = function(center, csize, size, offset)
		return cc.p(csize.width + size.width/2 + offset.x, size.height/2 + offset.y)
	end,
	
	tro = function(center, csize, size, offset)
		return cc.p(csize.width - size.width/2 + offset.x, csize.height + size.height/2 + offset.y)
	end,
	
	tlo = function(center, csize, size, offset)
		return cc.p(size.width/2 + offset.x, csize.height + size.height/2 + offset.y)
	end,
	
	tc = function(center, csize, size, offset)
		return cc.p(center.x + offset.x, csize.height + offset.y)
	end,
	
	rto = function(center, csize, size, offset)
		return cc.p(csize.width + size.width/2 + offset.x, csize.height -size.height/2 + offset.y)
	end,
	
	lto = function(center, csize, size, offset)
		return cc.p(-size.width/2 + offset.x, csize.height -size.height/2 + offset.y)
	end,
}

-- 叠加 node
overlayNode = function(params)
	local Mnode = require "src/young/node"
	
	-- 设置参数默认值
	local params = type(params) ~= "table" and {} or params
	local parent = params.parent; if not parent then error("没有提供字段 'parent'") end
	
	local parentSize = parent:getContentSize()
	parentSize.width = parentSize.width * parent:getScaleX()
	parentSize.height = parentSize.height * parent:getScaleY()
		
	local center = cc.p(parentSize.width/2, parentSize.height/2)
	local zero = cc.p(0, 0)
	
	-- 用户提供 nodes 的顺序: 索引越大, 越后加入 parent
	local nodes = type(params.nodes) ~= "table" and {} or params.nodes
	if #nodes == 0 and type(params[1]) == "table" then nodes[1] = params[1] end

	local offset = nil
	local origin = nil
	local node = nil
	local scaleX, scaleY = nil, nil
	local childSize = nil
	for i, v in ipairs(nodes) do
		node = v.node
		origin = v.origin or "c"
		offset = v.offset or zero
		if not offset.x then offset.x = 0 end
		if not offset.y then offset.y = 0 end
		
		if v.scale then Mnode.setScale(node, v.scale) end
		childSize = node:getContentSize()
		childSize.width = childSize.width * node:getScaleX()
		childSize.height = childSize.height * node:getScaleY()
		
		Mnode.addChild(
		{
			parent = parent,
			child = node,
			pos = tOverlaySwitch[origin](center, parentSize, childSize, offset),
			tag = v.tag,
			zOrder = v.zOrder,
			cSize = v.cSize,
		})
		
	end
	
	return parent
end
----------------------------------------------------------------
-- 扩展 node 边框
extendNode = function(parameter)
	if type(parameter) ~= "table" then error("只接受一个 'table' 作为参数", 2) end
	
	local Mnode = require "src/young/node"
	
	local child = parameter.child
	local childSize = child:getContentSize()
	
	local marginH = parameter.marginH or 0
	local marginV = parameter.marginV or 0
	local parentSize = cc.size(childSize.width + 2 * marginH, childSize.height + 2 * marginV)
	
	
	local src = parameter.src
	local parent = nil
	if type(src) == "string" then
		parent = cc.Scale9Sprite:create(src)
	else
		parent = cc.Node:create()
	end
	
	parent:setContentSize(parentSize)
	
	Mnode.addChild(
	{
		parent = parent,
		child = child,
		pos = cc.p(parentSize.width/2, parentSize.height/2),
	})
	
	return parent
end
----------------------------------------------------------------
-- 创建键值对
createSpriteAndLabel = function(params)
    local k = params.k
	local v = params.v
    local isStringValue = type(v) == "table"
	if isStringValue then v = Mnode.createLabel(v) end
    local node = cc.Node:create()
    node:addChild(k)
    node:addChild(v)
    v:setAnchorPoint(cc.p(0,0.5))
    v:setPosition(cc.p(25,0))
    return node
end

createKVP = function(params)
	local Mnode = require "src/young/node"

	local k = params.k
	local v = params.v
	
	local isStringValue = type(v) == "table"
	if isStringValue then v = Mnode.createLabel(v) end
	
	local vSize = v:getContentSize()
	local vertical = params.ori == "|"
	
	local nodes = vertical and { v, k, } or { k, v, }
	
	local ret = Mnode.combineNode(
	{
		nodes = nodes,
		margins = params.margin,
		ori = params.ori,
	})
	
	local x, y = v:getPosition()
	
	local anchor, pos = nil
	if vertical then
		anchor = cc.p(0.5, 1)
		pos = cc.p(x, y + vSize.height/2)
	else
		anchor = cc.p(0, 0.5)
		pos = cc.p(x - vSize.width/2, y)
	end
	
	v:setAnchorPoint(anchor)
	v:setPosition(pos)
	
	ret.v = v
	
	ret.setValue = function(self, value, effect, color)
		local v = self.v
		
		if isStringValue then
			if type(value) == "string" or type(value) == "number" then
				v:setString( tostring(value) )
			elseif type(value) == "table" then
				local text = value.text
				if text then v:setString( tostring(value.text) ) end
				local color = value.color
				if color then v:setColor(color) end
			end
			
			if effect then
				local Blink = cc.Blink:create(1, 3)
				v:runAction(Blink)
			end

			if color then
				v:setTextColor(color)
			end
		else
			if type(value) == "string" then
				v:setTexture(value)
			elseif type(value) == "userdata" then
				removeFromParent(v)
				v = nil
				self.v = Mnode.addChild(
				{
					parent = self,
					child = value,
					anchor = anchor,
					pos = pos,
				})
			end
		end
	end
	
	return ret
end
----------------------------------------------------------------
-- 创建选项卡
createTabControl = function(params)
	local Mnode = require "src/young/node"
	local MColor = require "src/config/FontColor"

	local params = type(params) ~= "table" and {} or params
	
	local titles = params.titles or {"存在", "错误"}
	local map = {}
	for i, v in ipairs(titles) do map[v] = i end
	
	local color = params.color or {MColor.lable_black, MColor.lable_yellow}
	local size = params.size or 20
	local nodes = {}
	for i = 1, #titles do
		local item = cc.MenuItemImage:create(params.src[1], params.src[2])
		local item_size = item:getContentSize()
		
		local title = Mnode.createLabel(
		{
			src = tostring(titles[i]),
			color = color[1],
			size = size,
		})
		if params.side_title then
			title:setMaxLineWidth(item_size.width/2)
			title:setLineSpacing(-7)
			title:setPosition(item_size.width/2+2, item_size.height/2)
		else
			title:setPosition(item_size.width/2, item_size.height/2)
		end
		item:addChild(title)
		item.title = title
		
		nodes[i] = item
	end
	
	params.nodes = nodes
	params.root = cc.Menu:create()
	local ret = Mnode.combineNode(params)
	
	params.child = ret
	Mnode.addChild(params)
	
	local focused = params.selected
	if type(focused) == "string" then focused = map[focused] end
	
	local cb = params.cb or function(tag) end
	
	local callback = function(_, node)
		--dump(_, "_______________________")
		if focused and focused ~= node.mTag and nodes[focused] then
			nodes[focused]:unselected()
			nodes[focused].title:setColor(color[1])
		end
		
		if focused ~= node.mTag then
			focused = node.mTag
			if _ then AudioEnginer.playTouchPointEffect() end
			cb(node, focused)
		end
		if  nodes[focused] then
			nodes[focused]:selected()
			nodes[focused].title:setColor(color[2])
		end
	end
	
	for i, v in ipairs(nodes) do
		v.mTag = i
		v:registerScriptTapHandler(callback)
		
		if i == focused then
            v:selected()
			v.title:setColor(color[2])
			cb(v, focused)
        end
	end
	
	local M = Mnode.beginNode(ret)
	
	focus = function(self, tag)
		if type(tag) == "string" then tag = map[tag] end
		callback(nil, nodes[tag])
	end
	
	tabAtIdx = function(self, idx)
		return nodes[idx]
	end
	
	tabAtTitle = function(self, title)
		return map[title] and nodes[map[title]]
	end
	
	return ret
end
---------------------------------------------------------
-- 创建单选框
createRadioBox = function(params,shouldNotCall)
	local Mnode = require "src/young/node"
	local MColor = require "src/config/FontColor"

	local params = type(params) ~= "table" and {} or params
	local src =  type(params.src) ~= "table" and {"res/component/checkbox/2.png", "res/component/checkbox/2-1.png"} or params.src
	
	local cb = params.cb or function() end
	
	local choice = params.choice
	
	local config = params.config or {}
	local titles = config.titles
	--dump(params, "params")
	if type(titles) ~= "table" or #titles < 1 then return end
	local nodes = {}
	
	local focus = nil
	local ret = nil
	for i, v in ipairs(titles) do
		local bg = cc.Sprite:create(src[1])
		local bgSize = bg:getContentSize()
		
		if choice == i then
			focus = Mnode.createSprite(
			{
				src = src[2],
				parent = bg,
				pos = cc.p(bgSize.width/2, bgSize.height/2),
			})
			
            if not shouldNotCall then
                cb(bg, titles, i)
            end
		end
		
		Mnode.listenTouchEvent(
		{
			node = bg,
			swallow = true,
			begin = function(touch, event)
                    if not ret:isVisible() then
                        return false
                    end
					local node = event:getCurrentTarget()
					
					if node.catch then return false end
					
					local inside = Mnode.isTouchInNodeAABB(node, touch)
					if inside then 
						node.catch = true
					end
					
					return inside
				end,
				
				ended = function(touch, event)
					local node = event:getCurrentTarget()
					node.catch = false
					
					choice = i
					
					local old = tolua.cast(focus, "cc.Node")
					if old then old:removeFromParent() end
					
					local nodeSize = node:getContentSize()
					
					focus = Mnode.createSprite(
					{
						src = src[2],
						parent = node,
						pos = cc.p(nodeSize.width/2, nodeSize.height/2),
					})
					
					cb(node, titles, i)
				end,
		})
		
		local node = Mnode.combineNode(
		{
			nodes = {
				bg,
				Mnode.createLabel(
				{
					src = v.title,
					size = config.size,
					color = config.color
				}),
			},
			margins = config.margin,
			ori = config.ori,
		})
		
		node.bg = bg
		
		nodes[#nodes+1] = node
	end
	
	ret = Mnode.combineNode(
	{
		nodes = nodes,
		margins = params.margins,
		ori = params.ori,
		align = params.align,
	})
	
	local M = Mnode.beginNode(ret)
	
	value = function(this)
		return titles, choice
	end
	
    setChoice = function(choice)
        local node = nodes[choice]
        node.catch = false
					
		local old = tolua.cast(focus, "cc.Node")
		if old then old:removeFromParent() end
					
		local nodeSize = node:getContentSize()
					
		focus = Mnode.createSprite(
		{
			src = src[2],
			parent = node,
			pos = cc.p(nodeSize.width/2-27, nodeSize.height/2),
		})
    end

	return ret
end
---------------------------------------------------------
-- 创建选择器
createSelector = function(params)
	local params = type(params) ~= "table" and {} or params
	local config = params.config or { sp = 1, ep = 1, cur = 1 }
	local onValueChanged = params.onValueChanged or function() end
    -- 拖动条背景
    local barBgPath = params.barBgPath or "res/common/progress/jd13.png";
    -- 滑动单位
    local unit = params.unit or 1;
	---------------------------------------------------------
	local Mnode = require "src/young/node"
	local MMenuButton = require "src/component/button/MenuButton"
	------------------------------------------------------------
	
	local root = Mnode.createNode({ cSize = cc.size(370, 150) })
	--local root = Mnode.createScale9Sprite({ src = "res/common/scalable/2.png", cSize = cc.size(370, 150) })
	local rootSize = root:getContentSize()
	
	local update = nil
	
	-- 输入框
	local texture = TextureCache:addImage("res/common/bg/inputBg3.png")
	local textureSize = texture:getContentSize()
	local inputEditbox = Mnode.createEditBox(
	{
		hint = game.getStrByKey("hint"),
		cSize = cc.size(textureSize.width-10, textureSize.height-6),
	})

	inputEditbox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
	inputEditbox:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
	inputEditbox:registerScriptEditBoxHandler(function(strEventName, pSender)
		local edit = tolua.cast(pSender,"ccui.EditBox") 

		--dump(strEventName, "editbox event")
		
		if strEventName == "began" then --编辑框开始编辑时调用
			print("strEventName==began");
		elseif strEventName == "ended" then --编辑框完成时调用
            print("strEventName==ended");
		elseif strEventName == "return" then --编辑框return时调用
			local num = edit:getText()
			--dump(num, "num")
			local number = tonumber(num)
			if number ~= nil then
				edit:setText(tostring(number))
				
				local save = number
				--dump(save, "save")
				number = math.ceil(number)
				if number > config.ep then number = config.ep end
				if number < config.sp then number = config.sp end
				--dump(number, "number")
				
				if number ~= save then edit:setText(tostring(number)) end
				if number == config.cur then return end
				
				update((number-config.sp+1)/(config.ep-config.sp+1), number)
			else
				TIPS({ type = 1, str = game.getStrByKey("invalid_input_tips") })
				edit:setText(tostring(config.cur))
			end
		
		elseif strEventName == "changed" then --编辑框内容改变时调用
			print("strEventName==changed");
		end
	end)

	local inputBg = cc.Sprite:createWithTexture(texture)

	Mnode.addChild(
	{
		parent = inputBg,
		child = inputEditbox,
		pos = cc.p(textureSize.width/2, textureSize.height/2),
	})

	Mnode.addChild(
	{
		parent = root,
		child = inputBg,
		pos = cc.p(rootSize.width/2, 105),
	})
	
	-- 数字选择
	local decBtn = MMenuButton.new(
	{
		src = {"res/component/button/53_left.png", "res/component/button/53_left_sel.png"},
		cb = function()
			if config.cur > config.sp then
				local next_value = config.cur-unit
				update((next_value-config.sp+1)/(config.ep-config.sp+1), next_value)
			end
		end,
	})

	Mnode.addChild(
	{
		parent = root,
		child = decBtn,
		pos = cc.p(42, 105),
	})

	local incBtn = MMenuButton.new(
	{
		src = {"res/component/button/53_right.png", "res/component/button/53_right_sel.png"},
		cb = function()
			if config.cur < config.ep then
				local next_value = config.cur+unit
				update((next_value-config.sp+1)/(config.ep-config.sp+1), next_value)
			end
		end,
	})

	Mnode.addChild(
	{
		parent = root,
		child = incBtn,
		pos = cc.p(324, 105),
	})
	
	-- 拖动条
	local SeekBarBg = cc.Sprite:create(barBgPath)
	local SeekBarBgSize = SeekBarBg:getContentSize()

	Mnode.addChild(
	{
		parent = root,
		child = SeekBarBg,
		pos = cc.p(rootSize.width/2, 30),
	})

	local SeekBar = cc.ProgressTimer:create(cc.Sprite:create("res/common/progress/jd13-1.png"))
	SeekBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	SeekBar:setBarChangeRate(cc.p(1, 0))
	SeekBar:setMidpoint(cc.p(0, 1))

	local DragPoint = cc.Sprite:create("res/common/progress/jdButton.png")

	Mnode.addChild(
	{
		parent = SeekBarBg,
		child = SeekBar,
		zOrder = 1,
		pos = cc.p(SeekBarBgSize.width/2, SeekBarBgSize.height/2+1),
	})

	Mnode.addChild(
	{
		parent = SeekBarBg,
		child = DragPoint,
		zOrder = 2,
		pos = cc.p(SeekBarBgSize.width/2, SeekBarBgSize.height/2),
	})

	Mnode.listenTouchEvent(
	{
		node = SeekBarBg,
		swallow = true,
		begin = function(touch, event)
				local node = event:getCurrentTarget()
				
				if node.catch then return false end
				
				local inside = Mnode.isTouchInNodeAABB(DragPoint, touch)
				if inside then 
					node.catch = true
				end
				
				return inside
			end,
			
			moved = function(touch, event)
				local node = event:getCurrentTarget()
				local pos =  node:convertTouchToNodeSpace(touch)
				local cSize = node:getContentSize()
				--if pos.x < -10 or pos.x > (cSize.width+10) then return end
				local percentage = pos.x/cSize.width
				--dump(percentage, "percentage")
				update(percentage)
			end,
			
			ended = function(touch, event)
				local node = event:getCurrentTarget()
				node.catch = false
				
				local pos =  node:convertTouchToNodeSpace(touch)
				local cSize = node:getContentSize()
				--if pos.x < -10 or pos.x > (cSize.width+10) then return end
				local percentage = pos.x/cSize.width
				--dump(percentage, "percentage")
				update(percentage)
			end,
	})

	update = function(percentage, value)
		if value == nil then
			if percentage < -0.03 or percentage > 1.03 then return end
			value = config.sp+((config.ep-config.sp+1)*percentage)-1
            -- 小数
            if( math.floor(unit) < unit ) then
                value = GetPreciseDecimal(value, 10*unit);
            else
			    value = math.ceil(value)
            end
			if value > config.ep then value = config.ep end
			if value < config.sp then value = config.sp end
		end
		value=math.abs(value)
		config.cur = value
		inputEditbox:setText(tostring(value))
		SeekBar:setPercentage(percentage*100)
		DragPoint:setPosition(SeekBarBgSize.width*percentage, SeekBarBgSize.height/2)
		
		onValueChanged(root, value)
	end

	update((config.cur-config.sp+1)/(config.ep-config.sp+1), config.cur)
	------------------------------------------------------------------
	root.value = function(this)
		return config.cur
	end
	
	root.reloadData = function(this, cfg)
		config = cfg
		update((config.cur-config.sp+1)/(config.ep-config.sp+1), config.cur)
	end

    -- 重置
    root.reset = function(this)
        update(1/(config.ep-config.sp+1), config.sp)
    end
	
	-- 设置成最大值
	root.setToMax = function()
		update(1, config.ep)
	end

    -- 获取Editbox
    root.GetInputEditbox = function(this)
        return inputEditbox;
    end
	------------------------------------------------------------------
	return root
end
---------------------------------------------------------
_G.Mnode = M
---------------------------------------------------------