local current = ...
local guide = class("guide")
guide.SWALLOW_PRIORITY = -10000000
guide.TIP_ZORDER = 1000000
guide.current = current
guide.ctor = function (self)
	self.dragGuideImage_ = {}
	self.twinkleNodeStops_ = {}
	self.widgetCheckers_ = {}
	self.hightLights_ = {}
	self.preTouchPosition = {}
	self.tipTexts_ = {}
	self.currentFocus = nil
	self.evtCallback_ = nil
	local handler = nil

	local function createGuideLayer()
		if main_scene then
			self.guideLayer = display.newNode()

			if not tolua.isnull(self.guideLayer) then
				self.guideLayer:removeFromParent()
			end

			self.guideLayer:add2(main_scene)
			self.guideLayer:setNodeEventEnabled(true)

			self.guideLayer.onCleanup = function (self)
				handler = scheduler.scheduleUpdateGlobal(createGuideLayer, 0)

				return 
			end

			scheduler.unscheduleGlobal(handler)
		end

		return 
	end

	handler = scheduler.scheduleUpdateGlobal(slot2)

	return 
end
guide.getEventNodesByPos = function (self, pos)
	local nodes = {}

	traversalNodeTree(main_scene, function (n)
		if cc.Node.hitTest(n, pos, false) and n.getName(n) ~= "" and n.getName(n) ~= "nameLabel_byGuide" then
			table.insert(nodes, n)
		end

		return true
	end)

	return nodes
end
guide.setEvtCallback = function (self, func)
	self.evtCallback_ = func

	return 
end

if 0 < DEBUG then
	guide.debug = function (self)
		self.debug = true
		self._mouseEventListener = cc.EventListenerMouse:create()

		self._mouseEventListener:registerScriptHandler(handler(self, self.onMouseMove), cc.Handler.EVENT_MOUSE_MOVE)
		self._mouseEventListener:registerScriptHandler(handler(self, self.onMouseDown), cc.Handler.EVENT_MOUSE_DOWN)

		local eventDispatcher = cc.Director:getInstance():getEventDispatcher()

		eventDispatcher.addEventListenerWithFixedPriority(eventDispatcher, self._mouseEventListener, 1000)

		return 
	end
	guide.disDebug = function (self)
		local eventDispatcher = cc.Director:getInstance():getEventDispatcher()

		eventDispatcher.removeEventListener(eventDispatcher, self._mouseEventListener)

		return 
	end
	local oleListenerAdder = cc.Node.addNodeEventListener
	cc.Node.addNodeEventListener = function (self, evt, hdl, tag, priority)
		local stack = debug.traceback()
		local node = self

		if evt == cc.NODE_TOUCH_EVENT then
			scheduler.performWithDelayGlobal(function ()
				if not tolua.isnull(node) and main_scene and main_scene.ui and node:getName() == "" then
					for k, v in pairs(main_scene.ui.panels) do
						if isChildOf(node, v) then
							local pos = node:convertToWorldSpace(cc.p(0, 0))
							pos = v.convertToNodeSpace(v, pos)

							node:setName(k .. string.format("(%s,%s)", math.floor(pos.x), math.floor(pos.y)))

							break
						end
					end
				end

				return 
			end, 0)
		end

		return oleListenerAdder(oleListenerAdder, evt, hdl, tag, priority)
	end
	guide.onMouseMove = function (self, event)
		if self.__handler then
			scheduler.unscheduleGlobal(self.__handler)
		end

		local mousePos = cc.p(event.getCursorX(event), event.getCursorY(event))
		self.__handler = scheduler.performWithDelayGlobal(function ()
			local nodes = self:getEventNodesByPos(mousePos)
			slot1 = pairs
			slot2 = self.preNodes or {}

			for k, v in slot1(slot2) do
				if not tolua.isnull(v) then
					local nlb = v.getChildByName(v, "nameLabel_byGuide")

					if nlb then
						nlb.removeFromParent(nlb)
					end
				end
			end

			self.preNodes = nodes

			for k, v in pairs(nodes) do
				if not tolua.isnull(v) then
					local lb = an.newLabel(v.getName(v), 22, 1):add2(v):pos(v.centerPos(v)):anchor(0.5, 0.5)

					lb.setName(lb, "nameLabel_byGuide")
					lb.setGlobalZOrder(lb, 9999)
				end
			end

			return 
		end, 0.1)

		return 
	end
	guide.onMouseDown = function (self, event)
		local common = import("..common", current)

		if event.getMouseButton(event) == 1 then
			local mousePos = cc.p(event.getCursorX(event), event.getCursorY(event))

			if not tolua.isnull(self.pre) and not tolua.isnull(self.preMenu) then
				local pos = self.pre:convertToNodeSpace(cc.p(mousePos.x - self.pre:getw()/2, mousePos.y - self.pre:geth()/2))

				print(string.format("curPos :x:%d,y:%d", pos.x, pos.y))

				return 
			end

			print(not tolua.isnull(self.pre) and not tolua.isnull(self.preMenu))

			local nodes = self.getEventNodesByPos(self, mousePos)
			local cells = {}

			for k, v in pairs(nodes) do
				local cell = {
					w = 250,
					h = 25,
					cellCls = function ()
						local lb = v:getName()

						if not lb or lb == "" then
							lb = v.listener_id__
						end

						cell.stack = cell.node.stack__
						cell.lb = lb

						print(lb)

						return an.newLabel(lb, 22, 1):anchor(0.5, 0.5)
					end,
					node = v
				}

				table.insert(slot5, cell)
			end

			if #cells <= 0 then
				return 
			end

			local menu = common.createOperationMenu(cells, 5, function (pnl, cell)
				if not tolua.isnull(cell.node) then
					self.pre = cell.node
				end

				local data = self:createTouchData("began", mousePos.x, mousePos.y)

				cell.node:EventDispatcher(cc.NODE_TOUCH_EVENT, data)

				local data = self:createTouchData("ended", mousePos.x, mousePos.y)

				cell.node:EventDispatcher(cc.NODE_TOUCH_EVENT, data)

				return true
			end).add2(slot6, self.guideLayer):center():anchor(0.5, 0.5)

			traversalNodeTree(menu, function (n)
				n.setGlobalZOrder(n, 999999999999.0)

				return true
			end)

			if not tolua.isnull(self.preMenu) then
				self.preMenu.removeSelf(slot7)
			end

			self.preMenu = menu
		end

		return 
	end
end

guide.getNodeByName = function (self, name)
	local c = nil

	traversalNodeTree(main_scene, function (child)
		if child.getName(child) == name then
			c = child

			return false
		end

		return true
	end)

	return c
end
guide.getNodeByNames = function (self, names, checkScroll)
	local nodes = {}

	traversalNodeTree(main_scene, function (child)
		local name = child.getName(child)

		for k, v in pairs(names) do
			if v == name then
				nodes[v] = child
			end
		end

		return true
	end)

	if checkScroll then
		for k, v in pairs(slot3) do
			if v.__cname == "an.scroll" then
				nodes[k] = v.scrollView.touchNode_
			end
		end
	end

	return nodes
end
guide.createTouchData = function (self, evt, x, y)
	local data = {}

	if evt == "began" then
		data.x = x
		data.y = y
		data.prevX = x
		data.prevY = y
	else
		data.x = x
		data.y = y
		data.prevX = self.preTouchPosition[1]
		data.prevY = self.preTouchPosition[2]
	end

	self.preTouchPosition = {
		x,
		y
	}
	data.name = evt
	data.phase = "capturing"

	return data
end
guide.touchSwallower = function (self, touchCb, priority)
	local listener = cc.EventListenerTouchOneByOne:create()

	listener.setSwallowTouches(listener, true)
	listener.registerScriptHandler(listener, function (touch, event)
		local pos = touch.getLocation(touch)

		if touchCb("began", event, pos) then
			print("swallow touch by helper-guide")

			return true
		end

		return 
	end, cc.Handler.EVENT_TOUCH_BEGAN)
	listener.registerScriptHandler(slot3, function (touch, event)
		local pos = touch.getLocation(touch)

		touchCb("moved", event, pos)

		return 
	end, cc.Handler.EVENT_TOUCH_MOVED)
	listener.registerScriptHandler(slot3, function (touch, event)
		local pos = touch.getLocation(touch)

		touchCb("ended", event, pos)

		return 
	end, cc.Handler.EVENT_TOUCH_ENDED)

	local eventDispatcher = cc.Director.getInstance(slot4):getEventDispatcher()

	eventDispatcher.addEventListenerWithFixedPriority(eventDispatcher, listener, priority or guide.SWALLOW_PRIORITY)

	return listener
end
guide.talkWithNPC = function (self, name)
	local npc = main_scene.ground.map:findNPCWithName(name)

	if npc then
		print("talk with ", npc.roleid)
		scheduler.performWithDelayGlobal(function ()
			local rsb = DefaultClientMessage(CM_CLICKNPC)
			rsb.FNpcId = npc.roleid
			rsb.FnpcTag = 0

			MirTcpClient:getInstance():postRsb(rsb)

			return 
		end, 0)

		return true
	end

	return 
end
guide.showTipText = function (self, name, tipParams, offset)
	local tip = an.newLabel(unpack(tipParams))
	local lbsz = tip.getContentSize(tip)
	lbsz.width = lbsz.width + 30
	lbsz.height = lbsz.height + 30
	local node = display.newScale9Sprite(res.getframe2("pic/helperScript/guide/frame.png"), 0, 0, lbsz)
	local arrow = res.get2("pic/helperScript/guide/frame_arrows.png"):add2(node, 10):anchor(0, 0.5)

	tip.add2(tip, node):pos(15, 15)
	node.setVisible(node, false)

	local function schedulerCallBack()
		node:setVisible(true)

		local pos = self:calcWorldPos(name, offset)

		if not pos then
			return 
		end

		local lbsz = tip:getContentSize()
		lbsz.width = lbsz.width + 30
		lbsz.height = lbsz.height + 30

		node:setContentSize(lbsz)

		if tipParams.align then
			if tipParams.align == "left" then
				node:anchor(0, 0.5)
				arrow:pos(6, lbsz.height/2)
				arrow:setRotation(180)

				pos.x = pos.x + 60
			elseif tipParams.align == "top" then
				node:anchor(0.5, 1)
				arrow:pos(lbsz.width/2, lbsz.height - 6)
				arrow:setRotation(-90)

				pos.y = pos.y - 60
			elseif tipParams.align == "right" then
				node:anchor(1, 0.5)
				arrow:pos(lbsz.width - 6, lbsz.height/2)
				arrow:setRotation(0)

				pos.x = pos.x - 60
			elseif tipParams.align == "bottom" then
				node:anchor(0.5, 0)
				arrow:pos(lbsz.width/2, 6)
				arrow:setRotation(90)

				pos.y = pos.y + 60
			end
		end

		node:pos(pos.x, pos.y)

		return 
	end

	node.schedule(slot6, schedulerCallBack, 0)
	node.add2(node, self.guideLayer)
	setGlobalZOrderCascade(node, guide.TIP_ZORDER + 1)
	node.setLocalZOrder(node, guide.TIP_ZORDER)
	table.insert(self.tipTexts_, node)

	return node
end
guide.removeTipText = function (self, tip)
	for k, v in pairs(self.tipTexts_) do
		if v == tip then
			table.remove(self.tipTexts_, k)

			break
		end
	end

	if not tolua.isnull(tip) then
		tip.removeFromParent(tip)
	end

	return 
end
guide.hightLightNode = function (self, names)
	local nodes = nil

	if type(names) == "string" then
		names = {
			names
		}
	end

	nodes = self.getNodeByNames(self, names, true)
	local zorders = {}
	local sp = nil

	if not tolua.isnull(self.grayPanel) then
		self.grayPanel:removeSelf()
	end

	local base = display.newNode():add2(self.guideLayer)
	sp = cc.NVGDrawNode:create():add2(base)

	sp.drawSolidRect(sp, cc.p(0, 0), cc.p(display.cx*2, display.cy*2), cc.c4b(0, 0, 0, 0.5))

	self.grayPanel = base

	for k, v in ipairs(names) do
		local node = nodes[v]

		if tolua.isnull(node) then
			if string.find(v, "panel_") == 1 then
				node = main_scene.ui.panels[string.sub(v, string.find(v, "_") + 1)]
			end

			nodes[v] = node
		end

		if node then
			local function zsetter(n)
				if not zorders[n] then
					zorders[n] = n.getGlobalZOrder(n)

					n.setGlobalZOrder(n, guide.TIP_ZORDER - 3)
				end

				return true
			end

			traversalNodeTree(slot11, zsetter)
		end
	end

	local function resume()
		for k, v in pairs(zorders) do
			if not tolua.isnull(k) then
				k.setGlobalZOrder(k, v)
			end
		end

		if #self.hightLights_ <= 0 and not tolua.isnull(self.grayPanel) then
			self.grayPanel:removeSelf()

			self.grayPanel = nil
		end

		return 
	end

	table.insert(self.hightLights_, slot6)

	return resume
end
guide.disableHightLight = function (self, resumer)
	for k, v in pairs(self.hightLights_) do
		if v == resumer then
			table.remove(self.hightLights_, k)

			break
		end
	end

	resumer()

	return 
end
guide.setScrollOffsetX = function (self, name, x)
	local scroll = self.getNodeByName(self, name)

	if scroll and scroll.__cname == "an.scroll" then
		local ox, oy = scroll.getScrollOffset(scroll)

		scroll.setScrollOffset(scroll, x, oy)
	end

	return 
end
guide.setScrollOffsetY = function (self, name, y)
	local scroll = self.getNodeByName(self, name)

	if scroll and scroll.__cname == "an.scroll" then
		local ox, oy = scroll.getScrollOffset(scroll)

		scroll.setScrollOffset(scroll, ox, y)
	end

	return 
end
guide.getScrollOffsetX = function (self, name)
	local scroll = self.getNodeByName(self, name)

	if scroll and scroll.__cname == "an.scroll" then
		local ox, oy = scroll.getScrollOffset(scroll)

		return ox
	end

	return 
end
guide.getScrollOffsetY = function (self, name)
	local scroll = self.getNodeByName(self, name)

	if scroll and scroll.__cname == "an.scroll" then
		local ox, oy = scroll.getScrollOffset(scroll)

		return oy
	end

	return 
end
guide.stopBounce = function (self, name)
	local scroll = self.getNodeByName(self, name)

	if scroll and scroll.__cname == "an.scroll" then
		local tn = scroll.scrollView.touchNode_
		local pos = tn.convertToWorldSpace(tn, cc.p(tn.getw(tn)/2, tn.geth(tn)/2))
		local data = self.createTouchData(self, "began", pos.x, pos.y)

		tn.EventDispatcher(tn, cc.NODE_TOUCH_EVENT, data)

		local data = self.createTouchData(self, "ended", pos.x, pos.y)

		tn.EventDispatcher(tn, cc.NODE_TOUCH_EVENT, data)
	end

	return 
end
guide.focusNodeByName = function (self, names, evtCb, lockAll, swallowAnyway)
	if self.currentFocus then
		self.stopCurrentFocus(self)
	end

	local nodes = nil

	if type(names) == "string" then
		names = {
			names
		}
	end

	nodes = self.getNodeByNames(self, names, true)
	local evtCallback = self.evtCallback_

	for k, v in pairs(nodes) do
		local n = display.newNode()

		v.addChild(v, n)
		n.setNodeEventEnabled(n, true)

		n.onCleanup = function (self)
			evtCallback("clean," .. k)

			return 
		end
	end

	local listener = nil
	slot8 = self.touchSwallower(slot0, function (evtName, event, pos)
		local hited = nil

		if evtName == "moved" then
			return 
		end

		if evtName == "began" then
			for k, name in ipairs(names) do
				local node = nodes[name]

				if node and node.hitTest(node, pos, true) then
					hited = node

					break
				end
			end

			self.curNode = hited
		else
			hited = self.curNode
		end

		if hited then
			if evtName == "ended" and not hited.hitTest(hited, pos, true) then
				evtName = "canceled"
			end

			if evtCb(evtName, pos, hited.getName(hited)) then
				local data = self:createTouchData(evtName, pos.x, pos.y)

				print("swallowAnyway", not not swallowAnyway)
				listener:setSwallowTouches(not not swallowAnyway)

				return true
			end
		end

		listener:setSwallowTouches(true)

		if evtName == "ended" or evtName == "canceled" then
			self.curNode = nil
		end

		if lockAll then
			return true
		end

		return 
	end)
	listener = slot8
	self.currentFocus = {
		listener_ = listener,
		focus = node,
		guider_ = self,
		stop = function (self)
			local eventDispatcher = cc.Director:getInstance():getEventDispatcher()

			eventDispatcher.removeEventListener(eventDispatcher, listener)

			self.guider_.currentFocus = nil

			if grayOther then
				traversalNodeTree(node, function (n)
					n.setGlobalZOrder(n, zorders[n] or 0)

					return true
				end)
				sp.removeFromParent(slot2)
			end

			return 
		end
	}

	return self.currentFocus
end
guide.stopCurrentFocus = function (self)
	if self.currentFocus then
		self.currentFocus:stop()
	end

	return 
end
guide.calcWorldPos = function (self, name, offset)
	assert(name, "get world position faild. not name spacify")

	local function nodePos(node, name, off)
		local n = node or self:getNodeByNames({
			name
		})[name]
		local pos = nil

		if n then
			pos = n.convertToWorldSpace(n, cc.p(n.getw(n)/2, n.geth(n)/2))

			if off then
				pos = cc.pAdd(pos, off)
			end
		else
			print("calcWolrdPos, target not exist", name, pos)
		end

		return pos
	end

	local pos = slot1

	if type(name) == "string" then
		pos = nodePos(nil, name, offset)
	elseif not tolua.isnull(name) then
		pos = nodePos(name, nil, offset)
	end

	return pos
end
guide.useOnceAct = function (self, idx)
	scheduler.performWithDelayGlobal(function ()
		net.send({
			CM_EXEC_FRESHMAN_TASK_CMD,
			recog = idx
		})

		return 
	end, 0)

	return 
end
guide.dragGuide = function (self, start, goal, params)
	params = params or {
		finger = {}
	}
	params.finger = params.finger or {}
	local img = res.get2(params.image or "pic/helperScript/guide/finger.png"):add2(self.guideLayer):anchor(1, 1)

	img.setRotation(img, params.finger.r or 0)
	img.setScaleY(img, (params.finger.flipX and 1) or -1)
	img.setScaleX(img, (params.finger.flipY and 1) or -1)

	local startPos = self.calcWorldPos(self, start, params.startOffset or cc.p(0, 0))
	local goalPos = self.calcWorldPos(self, goal, params.goalOffset or cc.p(0, 0))
	local dis = cc.pGetDistance(startPos, goalPos)
	local arrow = display.newScale9Sprite(res.getframe2("pic/helperScript/guide/arrows_translucence02.png"), (startPos.x + goalPos.x)/2, (startPos.y + goalPos.y)/2, cc.size(28, dis))

	arrow.add2(arrow, self.guideLayer):rotation(math.deg(cc.pGetAngle(startPos, goalPos)) + 90):anchor(0.5, 0.5)

	local function runActs()
		img:setGlobalZOrder(guide.TIP_ZORDER)
		img:setPosition(startPos)
		img:runs({
			cca.place(startPos.x, startPos.y),
			cca.delay(params.interval or 0),
			cca.fadeIn(0.2),
			cca.moveTo(params.duration or 1.3, goalPos.x, goalPos.y),
			cca.fadeOut(1),
			cca.callFunc(runActs)
		})

		return 
	end

	slot9()
	table.insert(self.dragGuideImage_, img)
	img.setNodeEventEnabled(img, true)

	img.onCleanup = function ()
		arrow:removeSelf()

		return 
	end

	return img
end
guide.stopDragGuide = function (self, img)
	for k, v in pairs(self.dragGuideImage_) do
		if v == img then
			table.remove(self.dragGuideImage_, k)

			break
		end
	end

	if not tolua.isnull(img) then
		img.removeFromParent(img)
	end

	return 
end
guide.isNodeExist = function (self, name)
	if string.find(name, "panel_") == 1 then
		local panel = main_scene.ui.panels[string.sub(name, string.find(name, "_") + 1)]

		if panel then
			return true
		end
	end

	return not not self.getNodeByName(self, name)
end
guide.isNodeVisible = function (self, node)
	local p = node

	while p do
		p = p.getParent(p)

		if tolua.type(p) == "cc.ClippingRectangleNode" then
			p = p.getParent(p)

			break
		end
	end

	if not p then
		return true
	end

	return cc.rectIntersectsRect(node.getCascadeBoundingBox(node), p.getBoundingBox(p))
end
guide.checkUntilNodeExist = function (self, name, cb, timeout)
	local timeoutHandler, updateHandler = nil
	slot6 = scheduler.scheduleUpdateGlobal(function ()
		if self:isNodeExist(name) then
			if timeoutHandler then
				scheduler.unscheduleGlobal(timeoutHandler)
			end

			cb("ok")
			scheduler.unscheduleGlobal(updateHandler)
		end

		return 
	end)
	updateHandler = slot6

	local function stopCheck()
		scheduler.unscheduleGlobal(updateHandler)
		cb("timeout")

		return 
	end

	if timeout then
		scheduler.performWithDelayGlobal(slot6, timeout)
	end

	table.insert(self.widgetCheckers_, stopCheck)

	return stopCheck
end
guide.scrollNodeToCenter = function (self, name, scrollName, offset)
	offset = offset or cc.p(0, 0)
	local scroll = self.getNodeByName(self, scrollName)

	if iskindof(scroll, "an.scroll") then
		scroll = scroll.scrollView
	end

	if not iskindof(scroll, "UIScrollView") then
		error(scrollName .. " is not a scroll node")
	end

	local node = self.getNodeByName(self, name)

	if not node then
		error(name .. " is not exist!")
	end

	local wp = node.convertToWorldSpace(node, cc.p(0, 0))
	local n = scroll.getScrollNode(scroll)
	local np = n.convertToNodeSpace(n, wp)
	np.x = scroll.getViewRect(scroll).width/2 + np.x + offset.x
	np.y = np.y - scroll.getViewRect(scroll).height/2 + offset.y
	local dir = scroll.getDirection(scroll)

	if dir == cc.ui.UIScrollView.DIRECTION_VERTICAL then
		n.run(n, cca.moveTo(0.5, 0, np.y))
	elseif dir == cc.ui.UIScrollView.DIRECTION_VERTICAL then
		scroll.scrollTo(scroll, np.x, 0)
	else
		scroll.scrollTo(scroll, np)
	end

	return 
end
guide.twinkleNodeWidthName = function (self, name, params)
	speed = speed or 1

	if not name then
		error("未指定控件名")

		return 
	end

	local node = self.getNodeByNames(self, {
		name
	})
	node = node[name]

	if not node then
		error("指定的控件不存在" .. name)

		return 
	end

	local drawNodes = {}
	local vst = nil
	local borderColor = params.boderColor or {
		g = 0.27058823529411763,
		a = 0,
		b = 0,
		r = 0.9333333333333333
	}
	local innner = cc.c4f(borderColor.r*4, borderColor.g*4, borderColor.b*4, borderColor.a)

	for k = 1, 5, 1 do
		local dn = cc.NVGDrawNode:create():add2(self.guideLayer)
		dn.dn2 = cc.NVGDrawNode:create():add2(self.guideLayer)

		dn.setLineWidth(dn, 5)
		dn.dn2:setLineWidth(3)
		table.insert(drawNodes, dn)

		dn.per = (k - 1)*20 - 100

		dn.setLocalZOrder(dn, guide.TIP_ZORDER - 1)
		dn.dn2:setLocalZOrder(guide.TIP_ZORDER - 1)
	end

	local function stopTwinkle()
		if not tolua.isnull(drawNodes[1]) then
			for k, v in pairs(drawNodes) do
				v.dn2:removeFromParent()
				v.removeFromParent(v)
			end
		end

		return 
	end

	local function update()
		if tolua.isnull(node) then
			stopTwinkle()

			return 
		end

		local pos = self:calcWorldPos(node, params.offset)

		for k, drawNode in pairs(drawNodes) do
			if tolua.isnull(drawNode) then
				return 
			end

			local per = drawNode.per - 1.6

			if per < 0 then
				per = 100
			end

			drawNode.per = per

			if per < 10 then
				borderColor.a = (per*0.7)/10
			else
				borderColor.a = (per/100 - 1)*0.7
			end

			if per < 10 then
				per = 10
			end

			if params.circle then
				drawNode.clear(drawNode)
				drawNode.drawCircle(drawNode, pos, (params.radio + per) - 10, borderColor)

				innner.a = borderColor.a

				drawNode.dn2:clear()
				drawNode.dn2:drawCircle(pos, (params.radio + per) - 10, innner)
			else
				per = per - 10
				local w = params.w*(per/50 + 1)
				local h = params.h*(per/50 + 1)
				local cx = pos.x + ((display.cx - pos.x)*(w - params.w))/(display.size.width - params.w)
				local cy = pos.y + ((display.cy - pos.y)*(h - params.h))/(display.size.height - params.h)

				drawNode.clear(drawNode)
				drawNode.drawRect(drawNode, cc.p(cx - w/2, cy - h/2), cc.p(cx + w/2, cy - h/2), cc.p(cx + w/2, cy + h/2), cc.p(cx - w/2, cy + h/2), borderColor)

				innner.a = borderColor.a

				drawNode.dn2:clear()
				drawNode.dn2:drawRect(cc.p(cx - w/2, cy - h/2), cc.p(cx + w/2, cy - h/2), cc.p(cx + w/2, cy + h/2), cc.p(cx - w/2, cy + h/2), innner)
			end
		end

		return 
	end

	drawNodes[1].schedule(slot10, update, 0)
	table.insert(self.twinkleNodeStops_, stopTwinkle)

	return stopTwinkle
end
guide.stopTwinkleNode = function (self, stoper)
	for k, v in pairs(self.twinkleNodeStops_) do
		if v == stoper then
			table.remove(self.twinkleNodeStops_, k)

			break
		end
	end

	stoper()

	return 
end
guide.getNodePositionRelative = function (self, name, relative)
	local node = self.getNodeByName(self, name)
	local relative = self.getNodeByName(self, relative)
	local pos = node.convertToWorldSpace(node, cc.p(0, 0))

	return relative.convertToNodeSpace(relative, pos)
end
guide.focusToNode = function (self, names, lockOther, stopEvt, params)
	local handler = nil
	local swallowAnyway = false

	if params then
		if type(params) == "table" then
			timeout = params.timeout
			swallowAnyway = params.swallowAnyway
		else
			timeout = params
		end

		if timeout then
			slot7 = scheduler.performWithDelayGlobal(function ()
				self.evtCallback_("timeout")

				return 
			end, timeout)
			handler = slot7
		end
	end

	return self.focusNodeByName(self, names, function (evt, pos, widName)
		self.evtCallback_(string.format("%s,%s", evt, widName))

		if evt == stopEvt then
			self:stopCurrentFocus()
		end

		if handler then
			scheduler.unscheduleGlobal(handler)
		end

		return true
	end, slot2, swallowAnyway)
end
guide.tip = function (self, text)
	main_scene.ui:tip(text)

	return 
end
guide.showGuideBoard = function (self, text, hightLight, btns)
	local n = display.newNode():add2(self.guideLayer)

	n.setContentSize(n, display.size.width, display.size.height)
	n.setLocalZOrder(n, 999)

	if hightLight then
		local layer = display.newColorLayer(cc.c4b(0, 0, 0, 128)):size(display.size.width*2, display.size.width*2):pos(-display.size.width/2, -display.size.width/2):add2(n)

		layer.setLocalZOrder(layer, -1)
	end

	local spr = res.get2("pic/helperScript/guide/guideBoard.png"):add2(n):anchor(0.5, 0.5):pos(display.cx - 70, display.cy)

	spr.setLocalZOrder(spr, 1)

	local label = an.newLabelM(310, 20, 1):add2(spr):pos(330, 210):anchor(0, 1)

	label.nextLine(label):addLabel(text, cc.c3b(255, 255, 255))

	if btns then
		local confirm = true
		local cancel = true

		if type(btns) == "table" then
			confirm = btns.confirm
			cancel = btns.cancel
		end

		if confirm then
			an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
				self.evtCallback_("GuideBoardEvt_confirm")

				return 
			end, {
				pressImage = res.gettex2("pic/common/btn21.png"),
				sprite = res.gettex2("pic/common/confirm.png")
			}).pos(slot9, 370, 15):addto(spr)
		end

		if cancel then
			an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
				self.evtCallback_("GuideBoardEvt_cancel")

				return 
			end, {
				pressImage = res.gettex2("pic/common/btn21.png"),
				sprite = res.gettex2("pic/common/cancel.png")
			}).pos(slot9, 480, 15):addto(spr)
		end
	end

	return n
end
guide.stop = function (self)
	local t = self.widgetCheckers_
	self.widgetCheckers_ = {}

	for k, v in pairs(t) do
		v()
	end

	local t = self.twinkleNodeStops_
	self.twinkleNodeStops_ = {}

	for k, v in pairs(t) do
		v()
	end

	local t = self.dragGuideImage_
	self.dragGuideImage_ = {}

	for k, v in pairs(t) do
		if not tolua.isnull(v) then
			v.removeSelf(v)
		end
	end

	local t = self.tipTexts_
	self.tipTexts_ = {}

	for k, v in pairs(t) do
		if not tolua.isnull(v) then
			v.removeSelf(v)
		end
	end

	local t = self.hightLights_
	self.hightLights_ = {}

	for k, v in pairs(t) do
		v()
	end

	self.stopCurrentFocus(self)

	return 
end
guide.testTouchSwallower = function (self)
	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	local l10000 = nil
	slot3 = self.touchSwallower(self, function (evt)
		print(evt, "func10000")

		if evt == "ended" then
			eventDispatcher:removeEventListener(l10000)
		end

		return 
	end, -10000)
	l10000 = slot3
	local l100000 = nil
	slot4 = self.touchSwallower(self, function (evt)
		print(evt, "func100000")

		if evt == "ended" then
			eventDispatcher:removeEventListener(l100000)
		end

		return 
	end, -100000)
	l100000 = slot4

	return 
end
guide.testFocus = function (self)
	self.focusNodeByName(self, "relation(-43,22)", function (evtName, pos, hited)
		if evtName == "ended" and hited then
			self:stopCurrentFocus()
		end

		return true
	end)

	return 
end
guide.testDrag = function (self)
	self.dragGuide(self, "rocker_walk", "rocker_run")
	scheduler.performWithDelayGlobal(function ()
		self:stopDragGuide()

		return 
	end, 10)

	return 
end
guide.testFocusDynamic = function (self)
	self.focusNodeByName(self, {
		"diy_tmpIcon",
		"diyPanel_btnPanelBag",
		"diy(20,82)"
	}, function (evtName, pos, hited)
		return true
	end, true)
	self.checkUntilNodeExist(slot0, "diy_背包", function (evt)
		print(evt)
		self:stopCurrentFocus()

		return 
	end)

	return 
end
guide.testCheckWidget = function (self)
	print(self.isNodeExist(self, "diy_挖取"))
	self.checkUntilNodeExist(self, "diy_小助手", function (state)
		print(state)

		return 
	end, 10)

	return 
end
guide.testHightLight = function (self)
	local resume = self.hightLightNode(self, {
		"diy_下属"
	})

	scheduler.performWithDelayGlobal(function ()
		self:disableHightLight(resume)

		return 
	end, 10)

	return 
end
guide.testTwinkle = function (self)
	self.twinkleNodeWidthName(self, "diy_下属", {
		w = 35,
		circle = false,
		h = 65,
		radio = 40
	})

	return 
end

return guide
