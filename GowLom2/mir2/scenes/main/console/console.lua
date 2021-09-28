local current = ...
local common = import("..common.common")
local replaceAsk = import(".replaceAsk")
local widgetDelegate = import(".widget._delegate")
local console = class("console", function ()
	return display.newNode()
end)
local widgetDef = g_data.widgetDef

table.merge(slot4, {
	widgets,
	editting,
	controller,
	skills,
	btnCallbacks,
	editBg,
	btnBg,
	btnAreaMaxLine = 6,
	btnAreaBeginX = 23,
	saveList = "_list",
	btnAreaSpace = 75,
	saveCurrent = "_current",
	btnAreaBeginY = 40,
	btnAreaLineNum = (80 < display.width - 960 and 4) or 3,
	z = {
		btnAreaBg = 2,
		editBg = 1,
		widget = 10
	}
})

console.ctor = function (self, params)
	local sdef = ".widget._def"

	if g_data.login:isCheckServer() then
		sdef = ".widget._testdef"
	end

	g_data.widgetDef = nil
	g_data.widgetDef = import(sdef, current)
	widgetDef = g_data.widgetDef

	if game.deviceFix then
		self.btnAreaBeginX = self.btnAreaBeginX + game.deviceFix
	end

	g_data.mark.playerName = common.getPlayerName()
	local datas = cache.getDiy(common.getPlayerName(), self.saveCurrent)

	if g_data.login:isCheckServer() then
		datas = nil
	end

	datas = datas or clone(widgetDef.default)

	if WIN32_OPERATE then
		for _, info in ipairs(widgetDef.default_pc) do
			local exist = false

			for _, v in ipairs(datas) do
				if info.key == v.key then
					exist = true
				end
			end

			if not exist then
				table.insert(datas, info)
			end
		end

		g_data.bag.customs = cache.getCustoms(common.getPlayerName())
	end

	local timeLimitWidgets = nil

	if params and params.timeLimitWidgets then
		timeLimitWidgets = params.timeLimitWidgets

		print("--==【限时组件配置】==--")
		print_r(timeLimitWidgets)

		function addData(key)
			for k, v in pairs(datas) do
				if v.key == key then
					return 
				end
			end

			local data = widgetDef.getData(key)

			table.insert(datas, data)

			return 
		end

		for k, v in pairs(slot4) do
			if v.enable then
				addData(k)
			end
		end
	end

	self.widgets = {}
	local notShowRecharge = g_data.login:showShopAndRechargeBtn() == false

	print("--==【加载组件】==--")

	for i, v in ipairs(datas) do
		local config = widgetDef.getConfig(v)

		if config and (config.btntype ~= "custom" or WIN32_OPERATE) and (config.key ~= "btnPanelTop" or not g_data.serConfig or g_data.serConfig.rankClose ~= 1 or false) and (v.key ~= "btnPanelShop" or not notShowRecharge or false) and (v.key ~= "btnRecharge" or not notShowRecharge or false) then
			if not config.timeLimit then
				print(v.key)
				self.addWidget(self, v)
			elseif timeLimitWidgets and timeLimitWidgets[v.key].enable then
				print(v.key)
				self.addWidget(self, v)
			elseif timeLimitWidgets and not timeLimitWidgets[v.key].enable then
				timeLimitWidgets[v.key].data = v
			end
		end
	end

	self.size(self, display.width, display.height)

	self.controller = import(".controller", current).new(self)
	self.skills = import(".skills", current).new(self)
	self.btnCallbacks = import(".btnCallbacks", current).new(self)
	self.autoRat = import(".autoRat", current).new(self)

	g_data.eventDispatcher:addListener("FLYSHOE_COUNTS", self, self.handleShoe)
	g_data.eventDispatcher:addListener("SELECT_HOSTILITY", self, self.selectHostility)

	return 
end
console.resetAutoRat = function (self)
	self.autoRat = import(".autoRat", current).new(self)

	return 
end
console.get = function (self, key)
	return self.widgets[key]
end
console.setWidgetSelect = function (self, key, select)
	local wid = self.get(self, key)

	if wid and wid.btn.setIsSelect then
		wid.btn:setIsSelect(select)
	end

	return 
end
console.call = function (self, key, method, ...)
	local inst = self.get(self, key)

	if inst and inst[method] then
		inst[method](inst, ...)
	end

	return 
end
console.selectHostility = function (self)
	local map = main_scene.ground.map

	local function sortHostility(target)
		table.sort(target, function (l, r)
			local lx = math.abs(map.player.x - l.x)
			local ly = math.abs(map.player.y - l.y)
			local rx = math.abs(map.player.x - r.x)
			local ry = math.abs(map.player.y - r.y)
			local dl = lx*lx + ly*ly
			local dr = rx*rx + ry*ry

			if dl == dr then
				return tonumber(l.roleid) < tonumber(r.roleid)
			else
				return dl < dr
			end

			return 
		end)

		return 
	end

	local target = {}
	local lock = self.get(slot0, "lock")
	local ho_color = {
		{
			69,
			253,
			254,
			5
		},
		{
			249
		},
		{
			47
		},
		{
			221
		},
		{
			255,
			251
		}
	}

	if map then
		if g_data.player.attackMode == "[和平攻击模式]" then
			target[#target + 1] = map.findNearMon(map)

			if #target == 0 then
				main_scene.ui:tip("敌对已是自己目标或附近没有敌对目标")
			else
				lock.setSelectTarget(lock, target[1])
			end
		else
			for _, colors in ipairs(ho_color) do
				if #target == 0 then
					for _, c in ipairs(colors) do
						tmp = map.findRoleByNameColor(map, c)

						for _, role in pairs(tmp) do
							target[#target + 1] = role
						end
					end
				else
					break
				end
			end

			if #target == 0 then
				main_scene.ui:tip("敌对已是自己目标或附近没有敌对目标")

				return 
			end

			if 1 <= #target then
				for i = #target, 1, -1 do
					if target[i].roleid == lock.target.select then
						table.remove(target, i)
					end
				end

				if #target == 0 then
					main_scene.ui:tip("敌对已是自己目标或附近没有敌对目标")

					return 
				else
					sortHostility(target)
					lock.setSelectTarget(lock, target[1])
				end
			end
		end
	end

	return 
end
console.handleShoe = function (self, shoeCounts)
	local node = self.get(self, "btnFlyShoe")

	if node and node.btn:getChildByTag(111) then
		node.btn:getChildByTag(111):setString(shoeCounts)
	end

	return 
end
console.addWidget = function (self, data, ani, config)
	local existWideget = self.get(self, data.key) ~= nil

	if existWideget then
		return 
	end

	config = config or widgetDef.getConfig(data)

	if config then
		if config.fixedX then
			data.x = config.fixedX

			if game.deviceFix then
				if data.x < game.deviceFix then
					data.x = data.x + game.deviceFix
				end

				if display.width - game.deviceFix < data.x then
					data.x = data.x - game.deviceFix
				end
			end
		end

		if config.fixedY then
			data.y = config.fixedY
		end

		local node = import(".widget." .. config.class, current).new(config, data):add2(self, config.z or self.z.widget)
		node.data = data
		node.config = config
		btn = node.btn or node

		if config.key == "btnSkillTemp" then
			btn:setName("diy_" .. data.key)
		elseif config.key == "btnFlyShoe" then
			local count = ""

			if g_data.player.ability then
				count = g_data.player.ability.FFlyShoeCounts
			end

			an.newLabel(count, 18, 0, {
				color = cc.c3b(0, 255, 0)
			}):anchor(1, 1):pos(btn:getw(), btn:geth()):add2(btn, 0, 111)
		else
			btn:setName("diy_" .. config.name)
		end

		self.widgets[data.key] = widgetDelegate.extend(node, self)

		self.resetBtnAreaBtnPos(self, node, ani)

		if self.editting then
			node._startEdit(node)
		end
	end

	if main_scene.ui and main_scene.ui.panels.diy then
		main_scene.ui.panels.diy:checkSelect(data.key, self)
	end

	if data.key == "btnTask" then
		local taskData = widgetDef.getData("task")

		self.addWidget(self, taskData)
		self.call(self, "task", "updateOnce")
	end

	return 
end
console.addWidgetByPanel = function (self, data, form)
	if self.get(self, data.key) then
		return "exist"
	end

	local config = widgetDef.getConfig(data)

	if not config then
		return 
	end

	if config.class == "btnMove" then
		local btnpos = self.pos2btnpos(self, data.x, data.y)

		if btnpos then
			local existBtn = self.findWidgetWithBtnpos(self, btnpos)

			if existBtn then
				replaceAsk.new(existBtn, function (operator)
					if operator == "replace" then
						self:removeWidget(existBtn.data.key)

						data.btnpos = btnpos

						self:addWidget(data, true)
					end

					return 
				end, slot2):setName("replaceAskNode")
			else
				data.btnpos = btnpos

				self.addWidget(self, data, true)
			end
		else
			self.addWidget(self, data)
		end

		return 
	end

	self.addWidget(self, data)
end
console.removeWidget = function (self, key)
	if self.widgets[key] then
		self.widgets[key]:removeSelf()

		self.widgets[key] = nil
	end

	if main_scene.ui and main_scene.ui.panels.diy then
		main_scene.ui.panels.diy:checkSelect(key, self)
	end

	if key == "btnTask" then
		self.removeWidget(self, "task")
	end

	if string.find(key, "skill") then
		local mid = string.sub(key, 6, string.len(key))
		local autoMagic = {
			"atkMagic",
			"areaMagic"
		}

		for k, v in ipairs(autoMagic) do
			if g_data.setting.autoRat[v].magicId and g_data.setting.autoRat[v].magicId == tonumber(mid) then
				g_data.setting.autoRat[v].magicId = nil
				g_data.setting.autoRat[v].enable = nil

				cache.saveSetting(common.getPlayerName(), "autoRat")

				if self.autoRat.enableRat then
					g_data.isSkillBegan = false

					common.stopAuto()
				end
			end
		end
	end

	return 
end
console.btnpos2pos = function (self, pos)
	pos = string.split(pos, "-")
	local x = display.width - (pos[2] - 0.5)*self.btnAreaSpace - self.btnAreaBeginX
	local y = (pos[1] - 0.5)*self.btnAreaSpace + self.btnAreaBeginY

	return x, y
end
console.pos2btnpos = function (self, x, y)
	local rect = self.getBtnAreaRect(self)

	if not cc.rectContainsPoint(rect, cc.p(x, y)) then
		return 
	end

	x = x - rect.x
	x = self.btnAreaLineNum - math.modf(x/self.btnAreaSpace)
	x = math.max(1, math.min(x, self.btnAreaLineNum))
	y = y - self.btnAreaBeginY
	y = math.modf(y/self.btnAreaSpace) + 1
	y = math.max(1, math.min(y, self.btnAreaMaxLine))

	return y .. "-" .. x
end
console.findWidgetWithBtnpos = function (self, pos)
	for k, v in pairs(self.widgets) do
		if v.__cname == "btnMove" and v.data.btnpos and v.data.btnpos == pos then
			return v
		end
	end

	return 
end
console.resetBtnAreaBtnPos = function (self, v, ani)
	if v.__cname == "btnMove" and v.data.btnpos then
		local x, y = self.btnpos2pos(self, v.data.btnpos)

		if x ~= v.getPositionX(v) or y ~= v.getPositionY(v) then
			if ani then
				v.moveTo(v, 0.1, x, y)
			else
				v.pos(v, x, y)
			end
		end
	end

	return 
end
console.resetAllBtnAreaBtnPos = function (self, ani)
	for k, v in pairs(self.widgets) do
		self.resetBtnAreaBtnPos(self, v, ani)
	end

	return 
end
console.startEdit = function (self)
	self.call(self, "btnMode", "showModeSelect")

	for k, v in pairs(self.widgets) do
		v._startEdit(v)
		v.show(v)
	end

	self.editting = true

	return 
end
console.endEdit = function (self)
	for k, v in pairs(self.widgets) do
		v._endEdit(v)
	end

	self.editting = false

	self.saveEdit(self)

	return 
end
console.saveEdit = function (self, filename)
	local datas = {}
	local nodes = sortNodes(table.values(self.widgets))

	for i, v in ipairs(nodes) do
		table.insert(datas, 1, v.data)
	end

	cache.saveDiy(common.getPlayerName(), filename or self.saveCurrent, datas)

	return 
end
console.showRect = function (self, widget, key)
	self.hideAllRect(self)

	widget = widget or self.get(self, key)

	if not widget then
		return 
	end

	widget._showRect(widget)

	return 
end
console.hideAllRect = function (self)
	for k, v in pairs(self.widgets) do
		v._hideRect(v)
	end

	return 
end
console.showEditBg = function (self, b)
	if not self.editBg then
		self.editBg = cc.LayerColor:create(cc.c4b(0, 0, 0, 128)):size(display.width, display.height):add2(self, self.z.editBg)

		display.newNode():size(self.editBg:getContentSize()):add2(self.editBg):enableClick(function ()
			self:hideAllRect()

			return 
		end)
	end

	self.editBg.setVisible(slot2, b)

	return 
end
console.getBtnAreaRect = function (self)
	return cc.rect(display.width - self.btnAreaSpace*self.btnAreaLineNum - self.btnAreaBeginX, 0, self.btnAreaSpace*self.btnAreaLineNum + self.btnAreaBeginX, self.btnAreaSpace*self.btnAreaMaxLine + self.btnAreaBeginY)
end
console.checkBtnAreaShow = function (self, p, isHide)
	local rect = self.getBtnAreaRect(self)

	if p then
		isHide = isHide or not cc.rectContainsPoint(rect, p)
	end

	if not self.btnBg then
		self.btnBg = display.newScale9Sprite(res.getframe2("pic/scale/scale6.png"), rect.x, rect.y, cc.size(rect.width, rect.height)):anchor(0, 0):add2(self, self.z.btnAreaBg)
	end

	self.btnBg:setVisible(not isHide)

	return 
end
console.fillPropTest = function (self)
	for k, v in pairs(self.widgets) do
		if v.config.btntype == "prop" then
			v.prop_fill_test(v)
		end

		if v.config.btntype == "custom" then
			v.custom_fill_test(v)
		end
	end

	return 
end
console.update = function (self, dt)
	for k, v in pairs(self.widgets) do
		if v.update then
			v.update(v, dt)
		end
	end

	self.controller:update(dt)

	return 
end
console.hidePet = function (self)
	if g_data.player.job == 0 and self.widgets.btnPet then
		self.widgets.btnPet:hide()
	end

	return 
end

return console
