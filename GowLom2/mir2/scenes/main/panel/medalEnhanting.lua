local item = import("..common.item")
local itemInfo = import("..common.itemInfo")
local medalEnhanting = class("medalEnhanting", function ()
	return display.newNode()
end)

table.merge(slot2, {})

local medalStdMode = 30
ccui.TouchEventType = {
	moved = 1,
	began = 0,
	canceled = 3,
	ended = 2
}

local function tip(tipstr)
	main_scene.ui:tip(tipstr, 6)

	return 
end

local function requestMedalEnhantingInfo()
	local rsb = DefaultClientMessage(CM_QueryMonCrystalLv)

	MirTcpClient:getInstance():postRsb(rsb)

	return 
end

local function upgradeMedalEnhanting()
	local rsb = DefaultClientMessage(CM_UpMonCrystal)

	MirTcpClient:getInstance():postRsb(rsb)

	return 
end

local function requestMedalInfo()
	local rsb = DefaultClientMessage(CM_FindMedal)

	MirTcpClient:getInstance():postRsb(rsb)

	return 
end

medalEnhanting.ctor = function (self, params)
	self.setNodeEventEnabled(self, true)

	self._scale = self.getScale(self)
	self._supportMove = true
	self.rootPanel = ccs.GUIReader:getInstance():widgetFromBinaryFile("ui/MedalEnhanting/MedalEnhanting.csb")
	local bg = self.rootPanel

	self.size(self, bg.getw(bg), bg.geth(bg)):anchor(0, 1):pos(10, display.height - 81)
	bg.add2(bg, self)

	self.panel_property_before = ccui.Helper:seekWidgetByName(self.rootPanel, "panel_property_before")
	self.panel_property_after = ccui.Helper:seekWidgetByName(self.rootPanel, "panel_property_after")
	self.panel_down = ccui.Helper:seekWidgetByName(self.rootPanel, "panel_down")
	self.img_medal_before = ccui.Helper:seekWidgetByName(self.rootPanel, "img_medal_before")
	self.img_full = ccui.Helper:seekWidgetByName(self.rootPanel, "img_full")

	local function clickClose(sender, eventType)
		if eventType ~= ccui.TouchEventType.ended then
			return 
		end

		self:hidePanel()
		main_scene.ui:hidePanel("bag")

		return 
	end

	local btnClose = ccui.Helper.seekWidgetByName(slot4, self.rootPanel, "btn_close")

	btnClose.addTouchEventListener(btnClose, clickClose)

	local function clickHelp(sender, eventType)
		if eventType ~= ccui.TouchEventType.ended then
			return 
		end

		local msgbox = an.newMsgbox("1.每次升级魔晶需消耗一定材料，成功后会增加魔晶属性。\n" .. "2.非红名角色被击败时，魔晶有20%概率降1级并爆出部分碎片；红名角色被击败时，魔晶有80%概率降1级并爆出部分碎片。(非验证角色爆出的魔晶直接消失)\n" .. "3.勋章升级时，魔晶将保留。", nil, {
			center = false
		})

		return 
	end

	local btnHelp = ccui.Helper.seekWidgetByName(slot6, self.rootPanel, "btn_help")

	btnHelp.addTouchEventListener(btnHelp, clickHelp)

	local function enhantingCheck()
		if not self.nextGradeInfo then
			tip("当前魔晶已达到最高等级")

			return 
		end

		local needServerState = self.nextGradeInfo.UpNeedServerStep
		local curServerState = g_data.client.serverState
		local needGold = self.nextGradeInfo.UpNeedGold
		local curGold = g_data.player.gold
		local needDust = self.nextGradeInfo.UpNeedMonDustNum
		local curDustCost = g_data.bag:getItemCount("魔尘")
		local curDustFree = g_data.bag:getItemCount("绑定魔尘")
		local curDust = curDustCost + curDustFree

		if curServerState < needServerState then
			tip("当前服务器阶段尚未开放")

			return 
		end

		if curDust < needDust or curGold < needGold then
			tip("材料不足")

			return 
		end

		return true
	end

	local function clickUpgrade(sender, eventType)
		if eventType ~= ccui.TouchEventType.ended then
			return 
		end

		if not self.itemData then
			return 
		end

		if enhantingCheck() then
			print("升级勋章")
			upgradeMedalEnhanting()
			sender.setTouchEnabled(sender, false)
		end

		return 
	end

	local btn_upgrade = ccui.Helper.seekWidgetByName(slot9, self.rootPanel, "btn_upgrade")

	btn_upgrade.addTouchEventListener(btn_upgrade, clickUpgrade)
	self.addNodeEventListener(self, cc.NODE_EVENT, function (event)
		if event.name == "cleanup" then
			slot1 = self.itemData and self.itemData.fromBag and slot1

			self:clearPanelData()
		end

		return 
	end)
	requestMedalInfo()
	self.showBag(tip)
	self.showMedalNull(self)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_UpMonCrystal, self, self.onSM_UpMonCrystal)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_FindMedal, self, self.onSM_FindMedal)

	return 
end
medalEnhanting.showBag = function (self)
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
medalEnhanting.getItemFromBg = function (self, data)
	if not data then
		return 
	end

	g_data.bag:setItemMedalOperateState(data, true)
	g_data.bag:delItem(data.FItemIdent)

	if main_scene.ui.panels.bag then
		main_scene.ui.panels.bag:delItem(data.FItemIdent)
	end

	return 
end
medalEnhanting.clearData = function (self)
	self.nextGradeInfo = nil
	self.nextItemData = nil

	return 
end
medalEnhanting.clearPanel = function (self)
	self.bg = nil
	self.rootPanel = nil
	self.panel_property_before = nil
	self.panel_property_after = nil
	self.panel_down = nil
	self.img_medal_before = nil
	self.btn_upgrade = nil
	self.img_full = nil

	return 
end
medalEnhanting.clearPanelData = function (self)
	self.clearPanel(self)
	self.clearData(self)

	return 
end
medalEnhanting.rebackBag = function (self, data)
	if not data then
		return 
	end

	g_data.bag:addItem(data)
	g_data.bag:setItemMedalOperateState(data, false)

	self.itemData = nil

	if main_scene.ui.panels.bag then
		main_scene.ui.panels.bag:addItem(data.FItemIdent)
	end

	return 
end
medalEnhanting.putMedalInPanel = function (self, data, isFromBag)
	self.clearData(self)

	if not data or data.getVar(data, "stdMode") ~= medalStdMode then
		return 
	end

	self.itemData = data
	self.itemData.fromBag = isFromBag
	local nextLvl = g_data.player.medalEnhantingLevel + 1
	self.nextGradeInfo = def.medalEnhantingCfg[nextLvl] or nil

	self.showMedalEnhanting(self)
	self.showMedalDownPanel(self)

	isFromBag = isFromBag and isFromBag

	return 
end
local medalPos = 2
medalEnhanting.autoPutMedalInPanel = function (self)
	local data = nil
	local isFromBag = true
	data = g_data.bag:getItemWithstdMode({
		medalStdMode
	})

	if not data then
		data = g_data.equip:getEquipByPos(medalPos)
		isFromBag = false
	end

	if not data then
		tip("尚未获得勋章")
	end

	self.putMedalInPanel(self, data, isFromBag)

	return 
end
local property_name = {
	"DC",
	"MC",
	"SC",
	"HP"
}
local property_name2text = {
	DC = "攻击 : ",
	MC = "魔法 : ",
	HP = "生命值 : ",
	SC = "道术 : "
}
local job2exclude = {
	[0] = {
		"MC",
		"SC"
	},
	{
		"DC",
		"SC"
	},
	{
		"DC",
		"MC"
	}
}

local function getPropertyTitle(key)
	return property_name2text[key]
end

local function getPropertyText(cfg, key)
	local job = g_data.player.job
	local exclude = job2exclude[job]

	for _, v in pairs(exclude) do
		if key == v then
			return ""
		end
	end

	local propertyStr = cfg.PropertyStr
	local data = common.decodePropertyStr(propertyStr)

	function getData(k)
		return data[k]
	end

	local front = getData(slot1) or -1
	local after = getData("max" .. key) or -1
	local text = ""

	if -1 < front and -1 < after then
		text = front .. "-" .. after
	elseif -1 < front then
		text = front
	end

	return text
end

medalEnhanting.uptPropertyPanelByData = function (self, panel, data)
	panel.setVisible(panel, true)

	local lbl_property = {}
	local lbl_property_title = {}
	local valLbl, titleLbl = nil
	local lblName = ""
	local propertyText = ""
	local titleText = ""

	for i = 1, 3, 1 do
		lblName = "lbl_property_" .. i
		lbl_property_title[i] = ccui.Helper:seekWidgetByName(panel, lblName .. "_title")

		lbl_property_title[i]:setVisible(false)
	end

	lblName = "lbl_level"
	lbl_property_title[4] = ccui.Helper:seekWidgetByName(panel, lblName)

	lbl_property_title[4]:setVisible(false)

	lblName = "lbl_null"
	lbl_property_title[5] = ccui.Helper:seekWidgetByName(panel, lblName)

	if data == nil then
		lbl_property_title[5]:setVisible(true)

		return 
	end

	local lbl_index = 1

	for i = 1, #property_name, 1 do
		propertyText = getPropertyText(data, property_name[i])
		titleText = getPropertyTitle(property_name[i])

		if propertyText ~= "" then
			titleLbl = lbl_property_title[lbl_index]
			titleText = titleText .. " " .. propertyText

			titleLbl.setString(titleLbl, titleText)
			titleLbl.setVisible(titleLbl, true)

			lbl_index = lbl_index + 1
		end
	end

	if data.lvl then
		lbl_property_title[4]:setString("[" .. data.lvl .. "级魔晶]")
		lbl_property_title[4]:setVisible(true)
		lbl_property_title[5]:setVisible(false)
	end

	return 
end
medalEnhanting.showMedalNull = function (self)
	slot1 = self.itemData and self.itemData.fromBag and slot1

	self.clearData(self)
	self.panel_down:setVisible(false)
	self.panel_property_before:setVisible(false)
	self.panel_property_after:setVisible(false)

	local lbl_notice = ccui.Helper:seekWidgetByName(self.panel_down, "lbl_notice")

	lbl_notice.setVisible(lbl_notice, false)
	self.img_medal_before:removeAllChildren()

	return 
end
medalEnhanting.showMedalEnhanting = function (self)
	self.img_full:setVisible(false)

	local curLvl = g_data.player.medalEnhantingLevel
	local curData = def.medalEnhantingCfg[curLvl]

	if curData then
		curData.lvl = curLvl
	end

	item.new(self.itemData, self.img_medal_before, {
		fromMdePanel = true,
		donotMove = true
	}):addto(self.img_medal_before):pos(self.img_medal_before:getw()*0.5, self.img_medal_before:geth()*0.5)
	self.uptPropertyPanelByData(self, self.panel_property_before, curData)

	local nextData = def.medalEnhantingCfg[curLvl + 1]

	if nextData then
		nextData.lvl = curLvl + 1
	end

	self.uptPropertyPanelByData(self, self.panel_property_after, nextData)

	return 
end
medalEnhanting.showMedalDownPanel = function (self)
	local str_need = ""
	local lbl_notice = ccui.Helper:seekWidgetByName(self.panel_down, "lbl_notice")

	lbl_notice.setVisible(lbl_notice, false)

	if self.nextGradeInfo then
		local needDust = self.nextGradeInfo.UpNeedMonDustNum
		local needGold = self.nextGradeInfo.UpNeedGold
		local needServerState = self.nextGradeInfo.UpNeedServerStep
		local curServerState = g_data.client.serverState

		if curServerState < needServerState then
			str_need = "服务器" .. needServerState .. "阶段开放"
		else
			str_need = "所需材料: 魔尘*" .. needDust .. "、金币*" .. needGold/10000 .. "万"

			lbl_notice.setVisible(lbl_notice, true)
		end
	end

	local val_need = ccui.Helper:seekWidgetByName(self.panel_down, "val_need_1")

	val_need.setString(val_need, tostring(str_need))
	self.panel_down:setVisible(true)

	return 
end
local upt_msg = {
	[0] = "魔晶升级成功！",
	[-3.0] = "材料不足",
	[-1.0] = "当前勋章已经达到最高等级",
	[-2.0] = "服务器阶段未达到"
}
medalEnhanting.onSM_UpMonCrystal = function (self, result)
	local btn_upgrade = ccui.Helper:seekWidgetByName(self.rootPanel, "btn_upgrade")

	btn_upgrade.setTouchEnabled(btn_upgrade, true)

	if result.FBackValue == 0 then
		g_data.player.medalEnhantingLevel = result.FMonCrystalLv

		if self.itemData then
			local fromBag = g_data.bag:getItem(self.itemData.FItemIdent)

			self.putMedalInPanel(self, self.itemData, fromBag)
		end
	end

	return 
end
local find_msg = {
	[0] = "尚未获得勋章"
}

local function decodeItem(serverData)
	setmetatable(serverData, {
		__index = gItemOp
	})
	serverData.decodedCallback(serverData)

	return serverData
end

medalEnhanting.onSM_FindMedal = function (self, result)
	self.showMedalNull(self)

	if result.FBackValue ~= 1 then
		local msg = find_msg[result.FBackValue] or "勋章附魔未知错误"

		tip(msg)

		return 
	end

	local data = decodeItem(result.FMedalItem)
	local fromBag = g_data.bag:getItem(data.FItemIdent)

	self.putMedalInPanel(self, data, fromBag)

	return 
end

return medalEnhanting
