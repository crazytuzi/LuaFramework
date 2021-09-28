local item = import("..common.item")
local itemInfo = import("..common.itemInfo")
local smelting = class("smelting", function ()
	return display.newNode()
end)
local common = import("..common.common")
local forgingData = def.forging

table.merge(slot2, {
	forgingPage = 1,
	meltingPage = 1,
	maxHisSize = 100,
	forgingItems = {},
	forgingColors = {},
	meltingItems = {},
	weaponCheck = {},
	btnCheck = {},
	helpPage = {},
	handler = {},
	data = {}
})

ccui.TouchEventType = {
	moved = 1,
	began = 0,
	canceled = 3,
	ended = 2
}

local function createWeapon(name)
	for index, stditem in ipairs(_G.def.items) do
		if type(index) == "number" and stditem.name == name then
			local baseItem = {
				FIndex = index
			}

			if 150 < stditem.stdMode then
				baseItem.FDura = v.Fdura
			else
				baseItem.FDura = stditem.duraMax
			end

			baseItem.FDuraMax = stditem.duraMax
			baseItem.FItemValueList = {}
			baseItem.FItemIdent = 1

			setmetatable(baseItem, {
				__index = gItemOp
			})
			baseItem.decodedCallback(baseItem)

			return baseItem
		end
	end

	return 
end

smelting.refreshStone = function (self)
	local StoneNum = g_data.bag:getItemCount("½ð¸ÕÊ¯")
	local lblStoneNum = ccui.Helper:seekWidgetByName(self.rootPanel, "lbl_stone_detail4")

	lblStoneNum.setString(lblStoneNum, StoneNum)

	self.StoneNum = StoneNum

	return 
end
smelting.createHelp = function (self, str, page)
	if self.helpPage[page] and self.helpPage[page].isMsgbox then
		self.helpPage[page]:removeSelf()

		self.helpPage[page] = nil

		return 
	end

	local function parseStr(str)
		local contentT = {}
		local lines = string.split(str, "$$")

		for k, v in pairs(lines) do
			local part = string.split(v, "|")
			contentT[k] = {}

			for i, j in pairs(part) do
				contentT[k][i] = string.split(j, "#")
			end
		end

		return contentT
	end

	local function parseColor(colorStr)
		if string.len(colorStr) ~= 6 then
			return display.COLOR_WHITE
		end

		return cc.c3b(tonumber("0x" .. string.sub(colorStr, 1, 2)), tonumber("0x" .. string.sub(colorStr, 3, 4)), tonumber("0x" .. string.sub(colorStr, 5, 6)))
	end

	self.helpPage[page] = an.newMsgbox("", nil)
	local content = {
		w = 370,
		h = 150,
		x = 25,
		y = 74
	}
	self.helpPage[page].isMsgbox = true
	local scroll = an.newScroll(content.x, content.y, content.w, content.h, {
		labelM = {
			18,
			1
		}
	}).add2(slot6, self.helpPage[page].bg)
	local label = scroll.labelM
	local strTable = parseStr(str)

	label.nextLine(label)

	for i = 1, #strTable, 1 do
		for j = 1, #strTable[i], 1 do
			if strTable[i][j][1] then
				if strTable[i][j][2] then
					label.addLabel(label, strTable[i][j][2], parseColor(strTable[i][j][1]))
				else
					label.addLabel(label, strTable[i][j][1], parseColor(""))
				end
			end
		end

		label.nextLine(label)
	end

	return 
end
smelting.ctor = function (self, params)
	params = params or {}
	params.openLevel = tonumber(params.openLevel) or 1
	params.pageType = tonumber(params.pageType) or 1
	self.openLevel = params.openLevel
	self._scale = self.getScale(self)
	self._supportMove = true

	self.setNodeEventEnabled(self, true)
	self.setTouchSwallowEnabled(self, true)

	self.rootPanel = ccs.GUIReader:getInstance():widgetFromBinaryFile("ui/smelting/smelting.csb")
	local bg = self.rootPanel

	self.size(self, bg.getw(bg), bg.geth(bg)):anchor(0.5, 0.5):pos(display.cx, display.cy)
	bg.add2(bg, self)

	local function clickClose(sender, eventType)
		if eventType ~= ccui.TouchEventType.ended then
			return 
		end

		self:hidePanel()

		return 
	end

	local btnClose = ccui.Helper.seekWidgetByName(slot4, self.rootPanel, "btn_close")

	btnClose.addTouchEventListener(btnClose, clickClose)
	btnClose.setSwallowTouches(btnClose, false)

	local btnPageForging = ccui.Helper:seekWidgetByName(self.rootPanel, "btn_page_forging")
	local btnPageMelting = ccui.Helper:seekWidgetByName(self.rootPanel, "btn_page_melting")
	local btnPageBatch = ccui.Helper:seekWidgetByName(self.rootPanel, "btn_page_batch")
	self.chk_selected = ccui.Helper:seekWidgetByName(self.rootPanel, "chk_selected")

	self.chk_selected:setSelected(true)

	local btns = {
		btnPageForging,
		btnPageMelting,
		btnPageBatch
	}

	btnPageForging.removeAllChildren(btnPageForging)
	btnPageMelting.removeAllChildren(btnPageMelting)
	btnPageBatch.removeAllChildren(btnPageBatch)
	an.newLabel("¶Í\nÔì", 20, 1, {
		color = def.colors.Ca6a197
	}):add2(btnPageForging):anchor(0, 0):pos(7, 25)
	an.newLabel("ÈÛ\nÁ¶", 20, 1, {
		color = def.colors.Ca6a197
	}):add2(btnPageMelting):anchor(0, 0):pos(7, 25)
	an.newLabel("Åú\nÁ¿", 20, 1, {
		color = def.colors.Ca6a197
	}):add2(btnPageBatch):anchor(0, 0):pos(7, 25)

	local pageType = {
		"Forging",
		"Melting",
		"Batch"
	}
	local lightPic = "pic/panels/smelting/btn_light.png"
	local darkPic = "pic/panels/smelting/btn_dark.png"
	local bgForging = ccui.Helper:seekWidgetByName(self.rootPanel, "img_bg")
	local btnForging = ccui.Helper:seekWidgetByName(self.rootPanel, "btn_forging")
	local btnHistory = ccui.Helper:seekWidgetByName(self.rootPanel, "btn_history")
	local bgMelting = ccui.Helper:seekWidgetByName(self.rootPanel, "img_bg_melting")
	local bgBatch = ccui.Helper:seekWidgetByName(self.rootPanel, "img_bg_batch")
	local bgs = {
		bgForging,
		bgMelting,
		bgBatch
	}
	local group_ctrl = ccui.Helper:seekWidgetByName(self.rootPanel, "group_ctrl")
	self.meltingItems = {}

	local function loadpage(page)
		if page ~= 1 then
			btnForging:hide()
			btnHistory:hide()
			group_ctrl:hide()
		else
			btnForging:show()
			btnHistory:show()
			group_ctrl:show()
		end

		for i = 1, 3, 1 do
			local lb = btns[i]:getChildren()[1]

			if i == page then
				btns[i]:loadTextures(lightPic, lightPic)
				btns[i]:setLocalZOrder(3)

				if bgs[i] then
					bgs[i]:show()
				end

				lb.setColor(lb, def.colors.Cf0c896)
			else
				btns[i]:loadTextures(darkPic, darkPic)
				btns[i]:setLocalZOrder(#btns - i)

				if bgs[i] then
					bgs[i]:hide()
				end

				lb.setColor(lb, def.colors.Ca6a197)
			end
		end

		if page == 2 then
			self.inMelting = true
		else
			self.inMelting = false

			if self.weaponInfo then
				self.weaponInfo:removeSelf()

				self.weaponInfo = nil
			end
		end

		self["loadPage" .. pageType[page]](self)

		return 
	end

	local function clickPageForging(sender, eventType)
		if eventType ~= ccui.TouchEventType.ended then
			return 
		end

		loadpage(1)

		return 
	end

	btnPageForging.addTouchEventListener(slot5, clickPageForging)

	local function clickPageMelting(sender, eventType)
		if eventType ~= ccui.TouchEventType.ended then
			return 
		end

		loadpage(2)

		return 
	end

	btnPageMelting.addTouchEventListener(slot6, clickPageMelting)

	local function clickPageBatch(sender, eventType)
		if eventType ~= ccui.TouchEventType.ended then
			return 
		end

		loadpage(3)

		return 
	end

	btnPageBatch.addTouchEventListener(slot7, clickPageBatch)
	loadpage(tonumber(params.pageType))

	local moneyType = ccui.Helper:seekWidgetByName(self.rootPanel, "lbl_gain_type_melting")
	local moneyVal = ccui.Helper:seekWidgetByName(self.rootPanel, "lbl_gain_val_melting")

	moneyType.setString(moneyType, "")
	moneyVal.setString(moneyVal, "")
	self.addNodeEventListener(self, cc.NODE_EVENT, function (event)
		if event.name == "cleanup" then
			for i = 1, 4, 1 do
				if self.handler[i] then
					scheduler.unscheduleGlobal(self.handler[i])

					self.handler[i] = nil
				end
			end
		end

		return 
	end)

	self.data = cache.getSmelting(g_data.player.roleid)

	return 
end
smelting.loadPageForging = function (self)
	local num = self.openLevel
	local forgingWeapons = string.split(forgingData[tonumber(self.openLevel)].weaponNames, "|")

	local function showPage(page)
		if #forgingWeapons < (page - 1)*8 or page < 1 then
			return 
		end

		for k, v in pairs(self.forgingItems) do
			if v and v.isItem then
				v.removeSelf(v)

				self.forgingItems[k] = nil
			end
		end

		for k, v in pairs(self.forgingColors) do
			if v and v.isPic then
				v.removeSelf(v)

				self.forgingColors[k] = nil
			end
		end

		local colorT = {
			purple = {
				"¿ªÌì",
				"ÐþÌì",
				"ÕòÌì",
				"ÍÀÁú",
				"ÊÈ»ê·¨ÕÈ",
				"ÒÐÌì½£"
			},
			blue = {
				"Å­Õ¶",
				"ÁúÑÀ",
				"åÐÒ£ÉÈ",
				"°ÔÕßÖ®ÈÐ",
				"²Ã¾öÖ®ÕÈ",
				"¹ÇÓñÈ¨ÕÈ",
				"ÁúÎÆ½£"
			},
			green = {
				"¾®ÖÐÔÂ",
				"ÑªÒû",
				"ÎÞ¼«¹÷",
				"ÂÞÉ²",
				"Æíµ»Ö®ÈÐ",
				"Á¶Óü",
				"Ä§ÕÈ",
				"ÒøÉß"
			},
			grey = {
				"ÐÞÂÞ",
				"ÙÈÔÂ",
				"½µÄ§",
				"ÄýËª"
			}
		}
		slot2 = (page - 1)*8 + 1
		slot3 = (page*8 < #forgingWeapons and page*8) or #forgingWeapons

		for i = slot2, slot3, 1 do
			local index = i%8

			if index == 0 then
				index = 8
			end

			local image_box = ccui.Helper:seekWidgetByName(self.rootPanel, "img_box" .. index)

			if createWeapon(forgingWeapons[i]) then
				local tempItem = item.new(createWeapon(forgingWeapons[i]), self, {
					donotMove = true
				}):add2(image_box):anchor(0.5, 0.5):pos(27, 27)
				self.forgingItems[#self.forgingItems + 1] = tempItem
				self.forgingItems[#self.forgingItems].isItem = true

				for color, names in pairs(colorT) do
					for k, weaponName in pairs(names) do
						if weaponName == forgingWeapons[i] then
							local tmpPic = res.get2("pic/panels/smelting/" .. color .. ".png"):add2(image_box):anchor(0.5, 0.5):pos(27, 27)
							tmpPic.isPic = true
							self.forgingColors[i] = tmpPic

							break
						end
					end
				end
			end
		end

		return 
	end

	local btnUppage = ccui.Helper.seekWidgetByName(slot4, self.rootPanel, "btn_uppage")
	local btnDownpage = ccui.Helper:seekWidgetByName(self.rootPanel, "btn_downpage")

	local function checkUppage()
		if self.forgingPage == 1 then
			btnUppage:hide()
		else
			btnUppage:show()
		end

		return 
	end

	local function checkDownpage(max)
		if self.forgingPage == max then
			btnDownpage:hide()
		else
			btnDownpage:show()
		end

		return 
	end

	local function clickUppage(sender, eventType)
		if eventType ~= ccui.TouchEventType.ended then
			return 
		end

		checkUppage()

		local maxPage = math.modf(#forgingWeapons/8)

		checkDownpage(maxPage)

		if self.forgingPage <= 1 then
			return 
		end

		self.forgingPage = self.forgingPage - 1

		showPage(self.forgingPage)

		return 
	end

	btnUppage.addTouchEventListener(slot4, clickUppage)
	btnUppage.setSwallowTouches(btnUppage, false)

	local function clickDownpage(sender, eventType)
		if eventType ~= ccui.TouchEventType.ended then
			return 
		end

		local maxPage = math.modf(#forgingWeapons/8)

		checkDownpage(maxPage)

		if maxPage < self.forgingPage then
			return 
		end

		self.forgingPage = self.forgingPage + 1

		showPage(self.forgingPage)
		checkUppage()

		return 
	end

	btnDownpage.addTouchEventListener(slot5, clickDownpage)
	btnDownpage.setSwallowTouches(btnDownpage, false)
	showPage(self.forgingPage)

	local function clickHelp(sender, eventType)
		if eventType ~= ccui.TouchEventType.ended then
			return 
		end

		local str = forgingData[self.openLevel].helpText

		self:createHelp(str, 3)

		return 
	end

	local btnHelp = ccui.Helper.seekWidgetByName(slot11, self.rootPanel, "btn_help")

	btnHelp.addTouchEventListener(btnHelp, clickHelp)
	self.refreshStone(self)

	local function meltingFunc()
		local weaponNames = {
			"ÄýËª",
			"ÐÞÂÞ",
			"ÙÈÔÂ",
			"½µÄ§"
		}
		local weapons = ""

		for i = 1, 4, 1 do
			if g_data.bag:getItemWithName(weaponNames[i]) then
				if weapons == "" then
					weapons = weapons .. weaponNames[i]
				else
					weapons = weapons .. "|" .. weaponNames[i]
				end
			end
		end

		if weapons ~= "" then
			local rsb = DefaultClientMessage(CM_NPC_Action)
			rsb.FNPCId = 0
			rsb.FAction = 203
			rsb.FParams1 = weapons
			rsb.FParams2 = ""

			MirTcpClient:getInstance():postRsb(rsb)
		end

		return 
	end

	local btnForging = ccui.Helper.seekWidgetByName(slot13, self.rootPanel, "btn_forging")

	local function clickForging(sender, eventType)
		if eventType ~= ccui.TouchEventType.ended then
			return 
		end

		local selected = self.chk_selected:isSelected()

		if selected then
			meltingFunc()
		end

		if self.StoneNum < 10 then
			main_scene.ui:tip("½ð¸ÕÊ¯²»×ã£¬ÎÞ·¨¶ÍÔì£¡")

			return 
		end

		local rsb = DefaultClientMessage(CM_NPC_Action)
		rsb.FNPCId = 0
		rsb.FAction = 201
		rsb.FParams1 = ""
		rsb.FParams2 = ""

		MirTcpClient:getInstance():postRsb(rsb)

		return 
	end

	btnForging.addTouchEventListener(slot13, clickForging)
	btnForging.setSwallowTouches(btnForging, false)

	local btnHistory = ccui.Helper:seekWidgetByName(self.rootPanel, "btn_history")

	local function clickHistory(sender, eventType)
		if eventType ~= ccui.TouchEventType.ended then
			return 
		end

		local content = self.data

		an.newMsgbox(content, nil)

		return 
	end

	btnHistory.addTouchEventListener(slot15, clickHistory)
	btnHistory.setSwallowTouches(btnHistory, false)

	if self.forgingPage == 1 then
		btnUppage.hide(btnUppage)
	end

	if #forgingWeapons <= 8 then
		btnDownpage.hide(btnDownpage)
	else
		btnDownpage.show(btnDownpage)
	end

	return 
end
smelting.loadPageMelting = function (self)
	local function clickHelp(sender, eventType)
		if eventType ~= ccui.TouchEventType.ended then
			return 
		end

		local str = forgingData[self.openLevel].helpText2

		self:createHelp(str, 2)

		return 
	end

	local btnHelp = ccui.Helper.seekWidgetByName(slot2, self.rootPanel, "btn_help_melting")

	btnHelp.addTouchEventListener(btnHelp, clickHelp)

	local weaponMap = {}

	for k, v in pairs(forgingData) do
		if v.weaponForMelting and tostring(v.weaponForMelting) ~= "" then
			local weapons = string.split(v.weaponForMelting, "|")
			local money = string.split(v.MeltingOutput, "*")

			for key, name in pairs(weapons) do
				weaponMap[name] = money
			end
		end
	end

	self.weaponMap = weaponMap
	local weaponDataMap = {}

	local function refreshWeaponFromBag()
		weaponDataMap = {}

		for k, v in pairs(g_data.bag.items) do
			for name, money in pairs(weaponMap) do
				if v.getVar(v, "name") == name then
					local temp = {
						name = name,
						data = v
					}
					weaponDataMap[#weaponDataMap + 1] = temp
				end
			end
		end

		return 
	end

	local function showPage(page)
		if self.meltingEquip and self.meltingEquip.isItem then
			self.meltingEquip:removeSelf()

			self.meltingEquip = nil

			if self.weaponInfo then
				self.weaponInfo:removeSelf()

				self.weaponInfo = nil
			end
		end

		refreshWeaponFromBag()

		if #weaponDataMap < (page - 1)*8 or page < 1 then
			return 
		end

		for k, v in pairs(self.meltingItems) do
			p2("other", "for v in meltingItems")
			dump(v)

			if v and v.isItem then
				p2("other", "remove meltingItems")
				v.removeSelf(v)

				self.meltingItems[k] = nil
			end
		end

		slot1 = (page - 1)*8 + 1
		slot2 = (page*8 < #weaponDataMap and page*8) or #weaponDataMap

		for i = slot1, slot2, 1 do
			local index = i%8

			if index == 0 then
				index = 8
			end

			local image_box = ccui.Helper:seekWidgetByName(self.rootPanel, "img_box" .. index .. "_melting")
			local tmpItem = item.new(weaponDataMap[i].data, self, {
				donotMove = true
			}):add2(image_box):anchor(0.5, 0.5):pos(27, 27)
			self.meltingItems[#self.meltingItems + 1] = tmpItem
			self.meltingItems[#self.meltingItems].isItem = true
		end

		return 
	end

	local btnUppage = ccui.Helper.seekWidgetByName(slot7, self.rootPanel, "btn_uppage_melting")
	local btnDownpage = ccui.Helper:seekWidgetByName(self.rootPanel, "btn_downpage_melting")

	local function checkUppage()
		if self.meltingPage == 1 then
			btnUppage:hide()
		else
			btnUppage:show()
		end

		return 
	end

	local function checkDownpage(max)
		if self.meltingPage == max then
			btnDownpage:hide()
		else
			btnDownpage:show()
		end

		return 
	end

	local function clickUppage(sender, eventType)
		if eventType ~= ccui.TouchEventType.ended then
			return 
		end

		checkUppage()

		local maxPage = math.modf(#weaponDataMap/8)

		checkDownpage(maxPage)

		if self.meltingPage <= 1 then
			return 
		end

		self.meltingPage = self.meltingPage - 1

		showPage(self.meltingPage)

		return 
	end

	btnUppage.addTouchEventListener(slot7, clickUppage)
	btnUppage.setSwallowTouches(btnUppage, false)

	local function clickDownpage(sender, eventType)
		if eventType ~= ccui.TouchEventType.ended then
			return 
		end

		local maxPage = math.modf(#weaponDataMap/8)

		checkDownpage(maxPage)

		if maxPage < self.meltingPage then
			return 
		end

		if self.meltingPage == maxPage and maxPage*8 == #weaponDataMap then
			return 
		end

		self.meltingPage = self.meltingPage + 1

		showPage(self.meltingPage)
		checkUppage()

		return 
	end

	btnDownpage.addTouchEventListener(slot8, clickDownpage)
	btnDownpage.setSwallowTouches(btnDownpage, false)
	showPage(self.meltingPage)

	local btnMelting = ccui.Helper:seekWidgetByName(self.rootPanel, "btn_melting")

	local function clickMelting(sender, eventType)
		if eventType ~= ccui.TouchEventType.ended then
			return 
		end

		if not self.meltingEquip then
			main_scene.ui:tip("Çë·ÅÈëÐèÒªÈÛÁ¶µÄÎäÆ÷")

			return 
		end

		local rsb = DefaultClientMessage(CM_NPC_Action)
		rsb.FNPCId = 0
		rsb.FAction = 202
		rsb.FParams1 = tostring(self.meltingEquip.data.FItemIdent)
		rsb.FParams2 = ""

		MirTcpClient:getInstance():postRsb(rsb)

		return 
	end

	btnMelting.addTouchEventListener(slot13, clickMelting)
	btnMelting.setSwallowTouches(btnMelting, false)

	if self.meltingPage == 1 then
		btnUppage.hide(btnUppage)
	end

	if #weaponDataMap <= 8 then
		btnDownpage.hide(btnDownpage)
	else
		btnDownpage.show(btnDownpage)
	end

	return 
end
smelting.setMeltingResult = function (self, name)
	local moneyType = ccui.Helper:seekWidgetByName(self.rootPanel, "lbl_gain_type_melting")
	local moneyVal = ccui.Helper:seekWidgetByName(self.rootPanel, "lbl_gain_val_melting")

	moneyType.setString(moneyType, self.weaponMap[name][1])
	moneyVal.setString(moneyVal, self.weaponMap[name][2])

	return 
end
smelting.putItem = function (self, data, flag)
	if flag then
		return 
	end

	if self.meltingEquip and self.meltingEquip.isItem and data.FItemIdent == self.meltingEquip.data.FItemIdent then
		self.putBackItem(self, self.meltingEquip.data)
		self.meltingEquip:removeSelf()

		self.meltingEquip = nil

		if self.weaponInfo then
			self.weaponInfo:removeSelf()

			self.weaponInfo = nil
		end

		return 
	end

	if self.weaponInfo then
		self.weaponInfo:removeSelf()

		self.weaponInfo = nil
	end

	self.weaponInfo = itemInfo.show(data, {
		x = 230,
		y = 327
	}, {
		fromSmelting = true,
		parent = self
	})

	self.setMeltingResult(self, data.getVar(data, "name"))

	if self.meltingEquip and self.meltingEquip.isItem then
		self.putBackItem(self, self.meltingEquip.data)
		self.meltingEquip:removeSelf()

		self.meltingEquip = nil
	end

	local imgMeltingEqui = ccui.Helper:seekWidgetByName(self.rootPanel, "Image_123")
	self.meltingEquip = item.new(data, self, {
		donotMove = true
	}):add2(imgMeltingEqui):anchor(0.5, 0.5):pos(60, 60)
	self.meltingEquip.isItem = true

	for k, v in pairs(self.meltingItems) do
		if v.data == data and v.isItem then
			v.removeSelf(v)

			self.meltingItems[k] = nil
		end
	end

	return 
end
smelting.putBackItem = function (self, data)
	for i = 1, 8, 1 do
		if not self.meltingItems[i] or not self.meltingItems[i].isItem then
			local image_box = ccui.Helper:seekWidgetByName(self.rootPanel, "img_box" .. i .. "_melting")
			self.meltingItems[i] = item.new(data, self, {
				donotMove = true
			}):add2(image_box):anchor(0.5, 0.5):pos(27, 27)
			self.meltingItems[i].isItem = true

			return 
		end
	end

	return 
end
smelting.resetMoney = function (self)
	local weaponNames = {
		"ÄýËª",
		"ÐÞÂÞ",
		"ÙÈÔÂ",
		"½µÄ§",
		"Á¶Óü",
		"Ä§ÕÈ",
		"ÒøÉß",
		"¾®ÖÐÔÂ",
		"ÑªÒû",
		"ÎÞ¼«¹÷"
	}
	local weaponMap = {}

	for k, v in pairs(forgingData) do
		if v.weaponForMelting and tostring(v.weaponForMelting) ~= "" then
			local weapons = string.split(v.weaponForMelting, "|")
			local money = string.split(v.MeltingOutput, "*")

			for key, name in pairs(weapons) do
				weaponMap[name] = money
			end
		end
	end

	local lblMoneyType1 = ccui.Helper:seekWidgetByName(self.rootPanel, "Label_84")
	local lblMoneyValue1 = ccui.Helper:seekWidgetByName(self.rootPanel, "Label_85")
	local lblMoneyType2 = ccui.Helper:seekWidgetByName(self.rootPanel, "Label_86")
	local lblMoneyValue2 = ccui.Helper:seekWidgetByName(self.rootPanel, "Label_87")
	local goldNum = 0
	local stoneNum = 0

	for k, v in pairs(g_data.bag.items) do
		for i = 1, 10, 1 do
			if self.weaponCheck[i] and self.weaponCheck[i].isCheck and v.getVar(v, "name") == weaponNames[i] then
				if weaponMap[weaponNames[i]][1] == "½ð¸ÕÊ¯" then
					stoneNum = stoneNum + weaponMap[weaponNames[i]][2]
				end

				if weaponMap[weaponNames[i]][1] == "½ð±Ò" then
					goldNum = goldNum + weaponMap[weaponNames[i]][2]
				end
			end
		end
	end

	lblMoneyValue1.setString(lblMoneyValue1, stoneNum)
	lblMoneyValue2.setString(lblMoneyValue2, goldNum)

	return 
end
smelting.loadPageBatch = function (self)
	local weaponNames = {
		"ÄýËª",
		"ÐÞÂÞ",
		"ÙÈÔÂ",
		"½µÄ§",
		"Á¶Óü",
		"Ä§ÕÈ",
		"ÒøÉß",
		"¾®ÖÐÔÂ",
		"ÑªÒû",
		"ÎÞ¼«¹÷"
	}
	local weaponMap = {}

	for k, v in pairs(forgingData) do
		if v.weaponForMelting and tostring(v.weaponForMelting) ~= "" then
			local weapons = string.split(v.weaponForMelting, "|")
			local money = string.split(v.MeltingOutput, "*")

			for key, name in pairs(weapons) do
				weaponMap[name] = money
			end
		end
	end

	local function clickHelp(sender, eventType)
		if eventType ~= ccui.TouchEventType.ended then
			return 
		end

		local str = forgingData[self.openLevel].helpText2

		self:createHelp(str, 1)

		return 
	end

	local btnHelp = ccui.Helper.seekWidgetByName(slot4, self.rootPanel, "btn_help_batch")

	btnHelp.addTouchEventListener(btnHelp, clickHelp)

	local function select(i)
		if self.weaponCheck[i] and self.weaponCheck[i].isCheck then
			self.weaponCheck[i]:removeSelf()

			self.weaponCheck[i] = nil
		else
			local tmpCheck = display.newSprite(res.gettex2("pic/panels/smelting/check.png")):anchor(0.5, 0.5):add2(self.btnCheck[i]):pos(27, 27)
			tmpCheck.isCheck = true
			self.weaponCheck[i] = tmpCheck
		end

		self:resetMoney()

		return 
	end

	for i = 1, 10, 1 do
		self.btnCheck[i] = ccui.Helper.seekWidgetByName(slot11, self.rootPanel, "btn_box" .. i .. "_batch")

		local function clickCheck(sender, eventType)
			if eventType ~= ccui.TouchEventType.ended then
				return 
			end

			select(i)

			return 
		end

		self.btnCheck[i].addTouchEventListener(slot11, clickCheck)
	end

	local function clickMeltingBatch(sender, eventType)
		if eventType ~= ccui.TouchEventType.ended then
			return 
		end

		local weapons = ""
		local hasCheck = nil

		for i = 1, 10, 1 do
			if self.weaponCheck[i] and self.weaponCheck[i].isCheck then
				hasCheck = true

				if g_data.bag:getItemWithName(weaponNames[i]) then
					if weapons == "" then
						weapons = weapons .. weaponNames[i]
					else
						weapons = weapons .. "|" .. weaponNames[i]
					end
				end
			end
		end

		if not hasCheck then
			main_scene.ui:tip("ÇëÑ¡ÔñÐèÒªÅúÁ¿ÈÛÁ¶µÄÎäÆ÷", 6)
		elseif weapons == "" then
			main_scene.ui:tip("±³°üÀïÃ»ÓÐ¿ÉÒÔÈÛÁ¶µÄÎäÆ÷", 6)
		else
			local rsb = DefaultClientMessage(CM_NPC_Action)
			rsb.FNPCId = 0
			rsb.FAction = 203
			rsb.FParams1 = weapons
			rsb.FParams2 = ""

			MirTcpClient:getInstance():postRsb(rsb)
		end

		return 
	end

	local btnMeltingBatch = ccui.Helper.seekWidgetByName(slot7, self.rootPanel, "btn_melting_batch")

	btnMeltingBatch.addTouchEventListener(btnMeltingBatch, clickMeltingBatch)

	local function clickSelectAll(sender, eventType)
		if eventType ~= ccui.TouchEventType.ended then
			return 
		end

		for i = 1, 10, 1 do
			if not self.weaponCheck[i] or not self.weaponCheck[i].isCheck then
				self.weaponCheck[i] = display.newSprite(res.gettex2("pic/panels/smelting/check.png")):anchor(0.5, 0.5):add2(self.btnCheck[i]):pos(27, 27)
				self.weaponCheck[i].isCheck = true
			end
		end

		self:resetMoney()

		return 
	end

	local btnSelectAll = ccui.Helper.seekWidgetByName(slot9, self.rootPanel, "btn_selectall_batch")

	btnSelectAll.addTouchEventListener(btnSelectAll, clickSelectAll)

	for i = 1, 4, 1 do
		if self.weaponCheck[i] and self.weaponCheck[i].isCheck then
			self.weaponCheck[i]:removeSelf()

			self.weaponCheck[i] = nil
		end

		self.weaponCheck[i] = display.newSprite(res.gettex2("pic/panels/smelting/check.png")):anchor(0.5, 0.5):add2(self.btnCheck[i]):pos(27, 27)
		self.weaponCheck[i].isCheck = true
	end

	self.resetMoney(self)

	return 
end
smelting.onSM_NPC_Action = function (self, result, protoId)
	if not result then
		return 
	end

	if tonumber(result.FAction) == 201 then
		if not tonumber(result.FParams2) then
			local imgWeaponBox = ccui.Helper:seekWidgetByName(self.rootPanel, "img_weapon_box")

			if self.forgingResult then
				self.forgingResult:removeSelf()

				self.forgingResult = nil
			end

			self.forgingResult = item.new(createWeapon(result.FParams2), self, {
				donotMove = true
			}):add2(imgWeaponBox):anchor(0.5, 0.5):pos(60, 60)
			local serverName = g_data.login.localLastSer.name
			local content = {
				"[" .. serverName .. "]" .. common.getPlayerName() .. "»ñµÃÁË" .. result.FParams2 .. "\n"
			}

			if self.maxHisSize <= #self.data then
				self.data[#self.data] = nil
			end

			table.insert(self.data, 1, content)
			ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("animation/jewelryCheckupCheck/jewelryCheckupCheck.csb")

			local checkAni = ccs.Armature:create("jewelryCheckupCheck")

			checkAni.add2(checkAni, imgWeaponBox, 9):pos(60, 60)
			checkAni.getAnimation(checkAni):play("check")

			checkAni.isAni = true
			self.handler[1] = scheduler.performWithDelayGlobal(function ()
				if not checkAni or not checkAni.isAni then
					return 
				end

				sound.playSound("qianghua_success")

				if checkAni and checkAni.isAni then
					checkAni:removeSelf()
				end

				ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("animation/jewelryCheckUpSu/jewelryCheckUpSu.csb")

				local suAni = ccs.Armature:create("jewelryCheckUpSu")

				suAni.add2(suAni, imgWeaponBox, 999):pos(60, 60)
				suAni.getAnimation(suAni):play("success")

				suAni.isAni = true
				self.handler[2] = scheduler.performWithDelayGlobal(function ()
					if suAni and suAni.isAni then
						suAni:removeSelf()
					end

					return 
				end, 0.667)

				return 
			end, 0.667)
		end

		self.resetMoney(item)
	end

	if tonumber(result.FAction) == 202 and tonumber(result.FParams2) == 0 then
		if self.meltingEquip then
			self.meltingEquip:removeSelf()

			self.meltingEquip = nil
		end

		if self.weaponInfo then
			self.weaponInfo:removeSelf()

			self.weaponInfo = nil
		end

		local imgWeaponBox = ccui.Helper:seekWidgetByName(self.rootPanel, "Image_123")

		ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("animation/jewelryCheckupCheck/jewelryCheckupCheck.csb")

		local checkAni = ccs.Armature:create("jewelryCheckupCheck")

		checkAni.add2(checkAni, imgWeaponBox):pos(60, 60)
		checkAni.getAnimation(checkAni):play("check")

		checkAni.isAni = true
		self.handler[3] = scheduler.performWithDelayGlobal(function ()
			if not checkAni or not checkAni.isAni then
				return 
			end

			sound.playSound("qianghua_fail")

			if checkAni and checkAni.isAni then
				checkAni:removeSelf()
			end

			ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("animation/jewelryCheckupFail/jewelryCheckupFail.csb")

			local failAni = ccs.Armature:create("jewelryCheckupFail")

			failAni.add2(failAni, imgWeaponBox):pos(60, 60)
			failAni.getAnimation(failAni):play("fail")

			failAni.isAni = true
			self.handler[4] = scheduler.performWithDelayGlobal(function ()
				if failAni and failAni.isAni then
					failAni:removeSelf()
				end

				return 
			end, 0.5)

			return 
		end, 0.667)
	end

	if tonumber(result.FAction) == 203 then
		self.resetMoney(item)
	end

	return 
end
smelting.onExit = function (self)
	cache.saveSmelting(g_data.player.roleid, self.data)

	return 
end

return smelting
