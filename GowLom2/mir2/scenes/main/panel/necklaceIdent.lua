local item = import("..common.item")
local itemInfo = import("..common.itemInfo")
local necklaceIdent = class("necklaceIdent", function ()
	return display.newNode()
end)

table.merge(slot2, {
	effects = {}
})

ccui.TouchEventType = {
	moved = 1,
	began = 0,
	canceled = 3,
	ended = 2
}
local necklaceData = nil
local labels = {}

local function getData(k)
	return necklaceData:getVar(k)
end

local function getDataStd(k)
	return necklaceData:getStd():get(k)
end

local function add(text, color)
	text = text or ""
	labels[#labels + 1] = an.newLabel(text, 16, 1, {
		color = color
	})

	return 
end

local function addAttr(text, key)
	local front = getData(key) or 0
	local after = getData("max" .. key) or 0

	if 0 < front or 0 < after then
		local normalAfter = getDataStd("max" .. key)

		if normalAfter and normalAfter < after then
			add(text .. front .. "-" .. after .. "  (+" .. after - normalAfter .. ")", display.COLOR_GREEN)
		else
			add(text .. front .. "-" .. after)
		end
	end

	return 
end

local function addAttr2(text, value, normalValue, color, attachText)
	attachText = attachText or ""

	if normalValue and normalValue < value then
		add(text .. value .. attachText .. "  (+" .. value - normalValue .. attachText .. ")", display.COLOR_GREEN)
	else
		add(text .. value .. attachText, color)
	end

	return 
end

necklaceIdent.necklaceInfo = function (self, data, bg)
	if self.necInfo then
		self.necInfo:removeSelf()

		self.necInfo = nil
		labels = {}
	end

	self.necInfo = res.get2("res/public/empty.png"):anchor(0, 0):addto(bg):size(150, 150)

	if data or false then
		if data.itemData then
			necklaceData = data.itemData
			local maxAC = getData("maxAC")
			local maxMAC = getData("maxMAC")
			local maxACN = getDataStd("maxAC")
			local maxMACN = getDataStd("maxMAC")

			if 0 < maxAC then
				addAttr2("魔法躲避: +", maxAC, maxACN, display.COLOR_WHITE, "0％")
			end

			addAttr("攻击: ", "DC")
			addAttr("道术: ", "SC")
			addAttr("魔法: ", "MC")

			if 0 < maxMAC then
				addAttr2("幸运: +", maxMAC, maxMACN, display.COLOR_WHITE)
			end

			local h = bg.geth(bg)*0.5 + 40

			for i = 1, #labels, 1 do
				h = h - labels[i]:geth() - 2

				labels[i]:addto(self.necInfo):pos(bg.getw(bg)*0.5, h):anchor(0.5, 0)
			end
		end

		if data.gold then
			an.newLabel(data.gold, 16, 1, {
				color = cc.c3b(162, 78, 54)
			}):add2(self.necInfo):anchor(0.5, 0.5):pos(bg.getw(bg)*0.5 + 40, bg.geth(bg)*0.5 - 120)
		end
	end

	return 
end
necklaceIdent.updateResult = function (self, addTypeText, addNum)
	self.lblresultVal:setString(addTypeText)
	self.lblresultValextra:setString("+" .. addNum)

	local positionK = 0

	if addTypeText == "魔法躲避" then
		positionK = 1
	end

	self.lblresultValextra:setPosition(self.lblresultValextra:getPositionX() + positionK*30, self.lblresultValextra:getPositionY())

	return 
end
necklaceIdent.getNecklaceData = function (self, data)
	return 
end
necklaceIdent.fillValue = function (self, uiData)
	if not uiData or not uiData.gold or not uiData.itemData then
		return 
	end

	if self.lblgoldVal then
		self.lblgoldVal:setString(uiData.gold)
	end

	local attrTable = {
		luck = "maxMAC",
		taoism = "SC",
		escape = "maxAC",
		attack = "DC",
		magic = "MC"
	}

	local function getAttr(key)
		if key == "DC" or key == "SC" or key == "MC" then
			local front = uiData.itemData:getVar(key) or 0
			local after = uiData.itemData:getVar("max" .. key) or 0
			local normalAfter = uiData.itemData:getStd():get("max" .. key)

			if normalAfter and normalAfter < after then
				return front .. "-" .. after, "(+" .. after - normalAfter .. ")"
			else
				return front .. "-" .. after
			end
		end

		if key == "maxAC" or key == "maxMAC" then
			local value = uiData.itemData:getVar(key) or 0
			local normalValue = uiData.itemData:getStd():get(key)

			if normalValue and normalValue < value then
				return "+" .. value, "(+" .. value - normalValue .. ")"
			else
				return "+" .. value
			end
		end

		return 
	end

	for k, v in pairs(slot2) do
		local name = "lblAttr" .. k .. "Val"
		local extra = "lblAttr" .. k .. "Valextra"
		local val, valExtra = getAttr(v)

		if self[name] then
			self[name]:setString(val)
		end

		if self[extra] then
			self[extra]:setString(valExtra or "")
		end
	end

	self.lblresultVal:setString("")
	self.lblresultValextra:setString("")

	return 
end
necklaceIdent.resetVal = function (self)
	self.lblgoldVal:setString("")

	local attrTable = {
		"escape",
		"attack",
		"taoism",
		"magic",
		"luck"
	}

	for k, v in pairs(attrTable) do
		local name = "lblAttr" .. v .. "Val"
		local extra = "lblAttr" .. v .. "Valextra"

		if self[name] then
			self[name]:setString("")
		end

		if self[extra] then
			self[extra]:setString("")
		end
	end

	self.lblresultVal:setString("")
	self.lblresultValextra:setString("")

	return 
end
necklaceIdent.ctor = function (self)
	self.setNodeEventEnabled(self, true)

	self._supportMove = true
	self.rootPanel = ccs.GUIReader:getInstance():widgetFromBinaryFile("ui/necklaceIdent/necklaceIdent.csb")
	self.lblgoldVal = ccui.Helper:seekWidgetByName(self.rootPanel, "lbl_goldval")
	local attrTable = {
		"escape",
		"attack",
		"taoism",
		"magic",
		"luck"
	}

	for k, v in pairs(attrTable) do
		local name = "lblAttr" .. v .. "Val"
		local extra = "lblAttr" .. v .. "Valextra"
		self[name] = ccui.Helper:seekWidgetByName(self.rootPanel, "lbl_attr_" .. v .. "_val")
		self[extra] = ccui.Helper:seekWidgetByName(self.rootPanel, "lbl_attr_" .. v .. "_val_extra")
	end

	self.lblresultVal = ccui.Helper:seekWidgetByName(self.rootPanel, "lbl_result_val")
	self.lblresultValextra = ccui.Helper:seekWidgetByName(self.rootPanel, "lbl_result_val_extra")
	local bg = self.rootPanel

	self.size(self, bg.getw(bg), bg.geth(bg)):anchor(0, 1):pos(10, display.height - 80)
	bg.add2(bg, self)
	self.showBag(self)

	local function clickClose(sender, eventType)
		if eventType ~= ccui.TouchEventType.ended then
			return 
		end

		self:hidePanel()

		return 
	end

	local btnClose = ccui.Helper.seekWidgetByName(slot4, self.rootPanel, "btn_close")

	btnClose.addTouchEventListener(btnClose, clickClose)

	local function clickHelp(sender, eventType)
		if eventType ~= ccui.TouchEventType.ended then
			return 
		end

		local msgbox = an.newMsgbox("", nil, {
			center = true
		})
		local label = an.newLabelM(365, 15, 1):add2(msgbox.bg):anchor(0.5, 0.5):pos(msgbox.bg:getw()*0.5, msgbox.bg:geth()/2 + 15)

		label.nextLine(label):addLabel("可以鉴定的装备：", display.COLOR_WHITE)
		label.addLabel(label, "白色虎齿项链、灯笼项链。", display.COLOR_RED)
		label.nextLine(label):addLabel("鉴定成功有几率增加以下属性：", display.COLOR_WHITE)
		label.addLabel(label, "攻击、魔法、道术、魔法躲避、幸运", display.COLOR_RED)
		label.nextLine(label):addLabel("每次消耗一定数量的金币：", display.COLOR_WHITE)
		label.addLabel(label, "普通白色虎齿项链：50000，普通灯笼项链：40000，待鉴定装备属性越高，鉴定消耗的金币越多。", display.COLOR_RED)
		label.nextLine(label)
		label.nextLine(label):addLabel("注意：鉴定可能导致项链破碎", display.COLOR_RED)

		return 
	end

	local btnHelp = ccui.Helper.seekWidgetByName(slot6, self.rootPanel, "btn_help")

	btnHelp.addTouchEventListener(btnHelp, clickHelp)

	local function clickIdent(sender, eventType)
		if eventType ~= ccui.TouchEventType.began then
			return 
		end

		if not self.item then
			main_scene.ui:tip("请放入项链", 6)

			return 
		end

		if g_data.player.gold < self.needGold then
			main_scene.ui:tip("你的金币不足,请确认带够金币再鉴定")

			return 
		end

		local rsb = DefaultClientMessage(CM_ENHANCE_NECKLACE)
		rsb.FNecklace_ItemIdent = self.item.data.FItemIdent

		MirTcpClient:getInstance():postRsb(rsb)

		return 
	end

	local btnIdent = ccui.Helper.seekWidgetByName(slot8, self.rootPanel, "btn_identification")

	btnIdent.addTouchEventListener(btnIdent, clickIdent)

	local function clickLoadoff(sender, eventType)
		if eventType ~= ccui.TouchEventType.began then
			return 
		end

		self:itemsBack2bag()
		self:resetVal()

		return 
	end

	local btnLoadoff = ccui.Helper.seekWidgetByName(slot10, self.rootPanel, "btn_loadoff")

	btnLoadoff.addTouchEventListener(btnLoadoff, clickLoadoff)
	self.addNodeEventListener(self, cc.NODE_EVENT, function (event)
		if event.name == "cleanup" then
			self:itemsBack2bag()
		end

		return 
	end)

	return 
end
necklaceIdent.showResult = function (self)
	sound.playSound("ronglian_effect")
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("animation/jewelryCheckupCheck/jewelryCheckupCheck.csb")

	local checkAni = ccs.Armature:create("jewelryCheckupCheck")

	checkAni.add2(checkAni, self, 9):pos(191, 319)
	checkAni.getAnimation(checkAni):play("check")
	scheduler.performWithDelayGlobal(function ()
		sound.playSound("qianghua_success")
		checkAni:removeSelf()
		ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("animation/jewelryCheckUpSu/jewelryCheckUpSu.csb")

		local suAni = ccs.Armature:create("jewelryCheckUpSu")

		suAni.add2(suAni, self, 999):pos(191, 319)
		suAni.getAnimation(suAni):play("success")
		scheduler.performWithDelayGlobal(function ()
			suAni:removeSelf()

			return 
		end, 0.667)

		return 
	end, 0.667)

	return 
end
necklaceIdent.showBag = function (self)
	if main_scene.ui.panels then
		if main_scene.ui.panels.bag then
			main_scene.ui.panels.bag:pos(self.getw(self) + 10, display.height - 80):anchor(0, 1)
		else
			main_scene.ui:togglePanel("bag")
			main_scene.ui.panels.bag:pos(self.getw(self) + 10, display.height - 80)
		end
	end

	return 
end
necklaceIdent.showEffect = function (self, bShow)
	for i = 1, 4, 1 do
		if bShow then
			self.effects[i]:show()
		else
			self.effects[i]:hide()
		end
	end

	return 
end
necklaceIdent.uptItem = function (self, makeIndex)
	local item = g_data.bag:getItemNecklaceIdent(makeIndex)

	if not item then
		return 
	end

	if self.item.data.FItemIdent == makeIndex then
		self.item.data = item
	end

	self.resetVal(self)

	local uiData = {
		itemData = item
	}
	local attris = {
		"maxAC",
		"maxDC",
		"maxSC",
		"maxMC",
		"maxMAC"
	}
	local totalAttri = 0

	for k, v in pairs(attris) do
		totalAttri = (totalAttri + (item.getVar(item, v) or 0)) - (item.getStd(item):get(v) or 0)
	end

	local set = nil

	if item.getVar(item, "name") == "白色虎齿项链" then
		set = 1
	else
		set = 2
	end

	local goldMap = {
		[0] = {
			50000,
			40000
		},
		{
			150000,
			120000
		},
		{
			450000,
			360000
		},
		{
			1350000,
			1080000
		},
		{
			4050000,
			3240000
		},
		{
			12150000,
			9720000
		},
		{
			36450000,
			29160000
		}
	}
	uiData.gold = goldMap[totalAttri][set]
	self.needGold = uiData.gold

	self.fillValue(self, uiData)

	return 
end
necklaceIdent.putItem = function (self, item, x, y)
	local form = item.formPanel.__cname
	local tmpX = 191
	local tmpY = 319

	if (tmpX - x)*(tmpX - x) < 800 and (tmpY - y)*(tmpY - y) < 800 then
		target = true
	end

	if not target then
		return 
	end

	if form == "bag" and g_data.client:checkLastTime("necklaceIdent", 2) then
		local data = item.data

		self.getItemFromBg(self, data)
	end

	return 
end
necklaceIdent.getBackItem = function (self, item)
	local data = item.data

	if not data then
		return 
	end

	g_data.bag:addItem(data)

	if main_scene.ui.panels.bag then
		main_scene.ui.panels.bag:addItem(data.FItemIdent)
	end

	if self.item and self.item.isItems and self.item.data.FItemIdent == data.FItemIdent then
		self.item:removeSelf()

		self.item = nil
		g_data.bag.necklaceIdent = nil
	end

	return 
end
necklaceIdent.getItemFromBg = function (self, data)
	local tmpItem = self.item

	g_data.bag:delItem(data.FItemIdent)

	if main_scene.ui.panels.bag then
		main_scene.ui.panels.bag:delItem(data.FItemIdent)
	end

	g_data.client:setLastTime("necklaceIdent", true)
	self.addItem(self, data)

	return 
end
necklaceIdent.delItem = function (self, itemIndex)
	if self.item and self.item.isItems and self.item.data.FItemIdent == itemIndex then
		self.item:removeSelf()

		self.item = nil
		g_data.bag.necklaceIdent = nil
	end

	return 
end
necklaceIdent.rebackBag = function (self, data)
	g_data.bag:addItem(data)

	if main_scene.ui.panels.bag then
		main_scene.ui.panels.bag:addItem(data.FItemIdent)
	end

	return 
end
necklaceIdent.itemsBack2bag = function (self)
	local makeIndex = nil

	if self.item and self.item.isItems then
		g_data.bag:addItem(self.item.data)

		makeIndex = self.item.data.FItemIdent

		self.item:removeSelf()
	end

	self.item = nil

	if makeIndex and main_scene.ui.panels.bag then
		main_scene.ui.panels.bag:addItem(makeIndex)
	end

	g_data.bag.necklaceIdent = nil

	return 
end
local goldMap = {
	[0] = {
		50000,
		40000
	},
	{
		150000,
		120000
	},
	{
		450000,
		360000
	},
	{
		1350000,
		1080000
	},
	{
		4050000,
		3240000
	},
	{
		12150000,
		9720000
	},
	{
		36450000,
		29160000
	}
}
necklaceIdent.addItem = function (self, data)
	sound.play("item", data)

	if data.getVar(data, "name") ~= "白色虎齿项链" and data.getVar(data, "name") ~= "灯笼项链" then
		main_scene.ui:tip("请放入正确项链")
		self.rebackBag(self, data)

		return 
	end

	local uiData = {
		itemData = data
	}
	local attris = {
		"maxAC",
		"maxDC",
		"maxSC",
		"maxMC",
		"maxMAC"
	}
	local totalAttri = 0

	for k, v in pairs(attris) do
		totalAttri = (totalAttri + (data.getVar(data, v) or 0)) - (data.getStd(data):get(v) or 0)
	end

	if 7 <= totalAttri then
		main_scene.ui:tip("项链属性过高，不可鉴定")
		self.rebackBag(self, data)

		return 
	end

	local set = nil

	if data.getVar(data, "name") == "白色虎齿项链" then
		set = 1
	else
		set = 2
	end

	uiData.gold = goldMap[totalAttri][set]
	self.needGold = uiData.gold

	self.fillValue(self, uiData)

	local tmpItem = self.item

	if tmpItem then
		if tmpItem.isItems then
			g_data.bag:addItem(tmpItem.data)

			if main_scene.ui.panels.bag then
				main_scene.ui.panels.bag:addItem(tmpItem.data.FItemIdent)
			end
		end

		tmpItem.removeSelf(tmpItem)
	end

	self.item = item.new(data, self):addto(self, 3):pos(191, 319)
	self.item.isItems = true
	g_data.bag.necklaceIdent = data

	return 
end
necklaceIdent.isNeedNecklace = function (self, data)
	local stdModes = {
		19,
		20,
		21
	}

	for k, v in pairs(stdModes) do
		if data.getVar(data, "stdMode") == v then
			return true
		end
	end

	return false
end
necklaceIdent.showError = function (self, errorCode)
	sound.playSound("ronglian_effect")
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("animation/jewelryCheckupCheck/jewelryCheckupCheck.csb")

	local checkAni = ccs.Armature:create("jewelryCheckupCheck")

	checkAni.add2(checkAni, self):pos(191, 319)
	checkAni.getAnimation(checkAni):play("check")
	scheduler.performWithDelayGlobal(function ()
		sound.playSound("qianghua_fail")
		checkAni:removeSelf()
		ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("animation/jewelryCheckupFail/jewelryCheckupFail.csb")

		local failAni = ccs.Armature:create("jewelryCheckupFail")

		failAni.add2(failAni, self):pos(191, 319)
		failAni.getAnimation(failAni):play("fail")
		scheduler.performWithDelayGlobal(function ()
			failAni:removeSelf()

			return 
		end, 0.5)

		return 
	end, 0.667)
	self.resetVal(slot0)

	return 
end
necklaceIdent.updateInfo = function (self, errorCode)
	return 
end

return necklaceIdent
