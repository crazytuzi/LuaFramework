local PanelBase = class("PanelBase", function ()
	return display.newNode()
end)
PanelBase.ctor = function (self)
	print("PanelBase:ctor")

	self.__nets = {}
	self.__notifys = {}
	self.__controls = {}
	self._supportMove = true

	self.setNodeEventEnabled(self, true)

	return 
end
PanelBase.initPanelUI = function (self, params)
	params = params or {}
	params.titleOffsetY = params.titleOffsetY or 0
	params.closeOffsetY = params.closeOffsetY or 0
	local type = type
	local bgImage = params.bg or "pic/common/black_2.png"
	local titleText = params.title or ""
	self.bg = display.newScale9Sprite(res.getframe2(bgImage)):anchor(0, 0):addTo(self)

	if params.size then
		self.bg:setContentSize(params.size)
	end

	if params.modalView then
		self.bg:anchor(0.5, 0.5)
		self.bg:pos(display.cx, display.cy)
		self.setMoveable(self, false)
		self.size(self, display.width, display.height):anchor(0.5, 0.5):center()
	else
		self.size(self, self.bg:getContentSize()):anchor(0.5, 0.5):center()
	end

	local lbl_title = an.newLabel("", 20, 0, {
		color = def.colors.labelTitle
	}):anchor(0.5, 0.5):pos(self.bg:getw()/2, self.bg:geth() - 23 + params.titleOffsetY):addTo(self.bg)
	self.__controls.lbl_title = lbl_title

	if params.title then
		self.setTitle(self, params.title)
	end

	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")

		if self:onCloseWindow() then
			self:hidePanel()
		else
			print("×èÖ¹ÁË´°¿Ú¹Ø±Õ")
		end

		return 
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}).anchor(slot6, 1, 1):pos(self.bg:getw() - 9, self.bg:geth() - 9 + params.closeOffsetY):addTo(self.bg)

	if params.tab and type(params.tab) == "table" then
		local tabOptions = params.tab
		self.tabs = common.tabs(self.bg, {
			strokeSize = 1,
			strs = tabOptions.strs,
			size = tabOptions.fontsize or 20,
			lc = {
				normal = cc.c3b(166, 161, 151),
				select = cc.c3b(249, 237, 215)
			},
			ox = tabOptions.lableOffestX or 4,
			oy = tabOptions.lableOffestY or 8
		}, handler(self, self.onTabClick), {
			tabTp = 1,
			file = tabOptions.file,
			pos = {
				offset = 70,
				x = tabOptions.leftmargin or 0,
				y = self.bg:geth() - (tabOptions.topmargin or 38),
				anchor = cc.p(1, 1)
			},
			default = {
				var = tabOptions.default or 1
			}
		})
	end

	return 
end
PanelBase.setTitle = function (self, title)
	local lbl_title = self.__controls.lbl_title
	local def_str = ""
	local def_fontsize = 20
	local def_pos = cc.p(self.bg:getw()/2, self.bg:geth() - 23)

	if type(title) == "string" then
		lbl_title.setString(lbl_title, title)
	else
		lbl_title.setString(lbl_title, title.str or def_str)
		lbl_title.setPosition(lbl_title, title.pos or def_pos)
	end

	return 
end
PanelBase.setMoveable = function (self, moveable)
	self._supportMove = moveable

	return 
end
PanelBase.onCloseWindow = function (self)
	return true
end
PanelBase.bindNetEvent = function (self, protoId, method, category)
	category = category or "all"
	local handler = MirTcpClient:getInstance():subscribeMemberOnProtocol(protoId, self, method)
	self.__nets[category] = self.__nets[category] or {}

	table.insert(self.__nets[category], handler)

	return 
end
PanelBase.bindNotify = function (self, notifyId, method)
	g_data.eventDispatcher:addListener(notifyId, self, method)

	return 
end
PanelBase.onTabClick = function (self, idx, btn)
	return 
end
PanelBase.newListView = function (self, x, y, w, h, itemMargin, params)
	local listView = an.newScroll(x, y, w, h)
	listView.lastPos = h - 3
	listView._lastPos = params.topMargin or listView.lastPos
	listView.itemMargin = itemMargin or 0

	if params.lightBox then
		local lightBox = display.newScale9Sprite(res.getframe2("pic/common/light.png"), 0, 0, cc.size(217, 67)):anchor(0, 1):add2(listView, 2):pos(3, 0)

		lightBox.setVisible(lightBox, false)

		listView.lightBox = lightBox
	end

	return listView
end
PanelBase.listViewPushBack = function (self, listView, item, params)
	local params = params or {}

	item.anchor(item, 0, 1):pos(params.left or 5, listView.lastPos)
	item.add2(item, listView)

	listView.lastPos = listView.lastPos - listView.itemMargin - item.geth(item)

	return 
end

return PanelBase
