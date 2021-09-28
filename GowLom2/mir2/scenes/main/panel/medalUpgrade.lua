local item = import("..common.item")
local itemInfo = import("..common.itemInfo")
local medalUpgrade = class("medalUpgrade", function ()
	return display.newNode()
end)

table.merge(slot2, {})

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

local function requestMedalInfo(itemIdent)
	if not itemIdent then
		print("requestMedalInfo itemIdent is nil")

		return 
	end

	local rsb = DefaultClientMessage(CM_MedalInfo)
	rsb.FItemIdent = itemIdent

	MirTcpClient:getInstance():postRsb(rsb)

	return 
end

local function upgradeMedal(itemIdent)
	if not itemIdent then
		print("upgradeMedal itemIdent is nil")

		return 
	end

	local rsb = DefaultClientMessage(CM_UpdateMedal)
	rsb.FItemIdent = itemIdent

	MirTcpClient:getInstance():postRsb(rsb)

	return 
end

medalUpgrade.ctor = function (self, params)
	self.setNodeEventEnabled(self, true)

	self._scale = self.getScale(self)
	self._supportMove = true
	self.rootPanel = ccs.GUIReader:getInstance():widgetFromBinaryFile("ui/MedalUpgrade/MedalUpgrade.csb")
	local bg = self.rootPanel

	self.size(self, bg.getw(bg), bg.geth(bg)):anchor(0, 1):pos(10, display.height - 81)
	bg.add2(bg, self)

	self.panel_property_before = ccui.Helper:seekWidgetByName(self.rootPanel, "panel_property_before")
	self.panel_property_after = ccui.Helper:seekWidgetByName(self.rootPanel, "panel_property_after")
	self.panel_down = ccui.Helper:seekWidgetByName(self.rootPanel, "panel_down")
	self.img_medal_before = ccui.Helper:seekWidgetByName(self.rootPanel, "img_medal_before")
	self.img_medal_after = ccui.Helper:seekWidgetByName(self.rootPanel, "img_medal_after")
	self.img_full = ccui.Helper:seekWidgetByName(self.rootPanel, "img_full")

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

		local msgbox = an.newMsgbox("1.每次升级都需要消耗一定量的声望点数，勋章的等级越高升级所需的声望点数越多。\n2.达到升级勋章需要的角色等级要求才可以升级勋章。\n3.升级后会得到新的勋章，相应的属性加成也会得到提升。", nil, {
			center = false
		})

		return 
	end

	local btnHelp = ccui.Helper.seekWidgetByName(slot6, self.rootPanel, "btn_help")

	btnHelp.addTouchEventListener(btnHelp, clickHelp)

	local function clickUpgrade(sender, eventType)
		if eventType ~= ccui.TouchEventType.ended then
			return 
		end

		if not self.itemData then
			return 
		end

		if not self.nextGradeInfo then
			tip("当前勋章已经达到最高等级")

			return 
		end

		local needLvl = self.nextGradeInfo.FNeedLevel
		local curLvl = g_data.player.ability.FLevel

		if curLvl < needLvl then
			tip("角色当前等级未达到要求")

			return 
		end

		local needSw = self.nextGradeInfo.FNeedSheWang
		local curSw = g_data.player.ability.FPrestige

		if curSw < needSw then
			tip("你的声望点数不足")

			return 
		end

		print("升级勋章")
		upgradeMedal(self.itemData.FItemIdent)
		sender.setTouchEnabled(sender, false)

		return 
	end

	local btn_upgrade = ccui.Helper.seekWidgetByName(slot8, self.rootPanel, "btn_upgrade")

	btn_upgrade.addTouchEventListener(btn_upgrade, clickUpgrade)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_MedalInfo, self, self.onSM_MedalInfo)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_UpdateMedal, self, self.onSM_UpdateMedal)
	self.addNodeEventListener(self, cc.NODE_EVENT, function (event)
		if event.name == "cleanup" then
			self:rebackBag(self.itemData)
			self:clearPanelData()
		end

		return 
	end)
	self.showBag(tip)
	self.showMedalNull(self)

	return 
end
medalUpgrade.showBag = function (self)
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
medalUpgrade.getItemFromBg = function (self, data)
	if not data then
		return 
	end

	g_data.bag:delItem(data.FItemIdent)

	if main_scene.ui.panels.bag then
		main_scene.ui.panels.bag:delItem(data.FItemIdent)
	end

	return 
end
medalUpgrade.clearData = function (self)
	self.itemData = nil
	self.nextGradeInfo = nil
	self.nextItemData = nil

	return 
end
medalUpgrade.clearPanel = function (self)
	self.bg = nil
	self.rootPanel = nil
	self.panel_property_before = nil
	self.panel_property_after = nil
	self.panel_down = nil
	self.img_medal_before = nil
	self.img_medal_after = nil
	self.btn_upgrade = nil
	self.img_full = nil

	return 
end
medalUpgrade.clearPanelData = function (self)
	self.clearPanel(self)
	self.clearData(self)

	return 
end
medalUpgrade.rebackBag = function (self, data)
	if not data then
		return 
	end

	g_data.bag:addItem(data)

	self.itemData = nil

	if main_scene.ui.panels.bag then
		main_scene.ui.panels.bag:addItem(data.FItemIdent)
	end

	return 
end
local property_name = {
	"DC",
	"MC",
	"SC"
}
local property_name2text = {
	DC = "攻击 : ",
	MC = "魔法 : ",
	SC = "道术 : "
}

local function getPropertyTitle(key)
	return property_name2text[key]
end

local function getPropertyText(data, key)
	function getData(k)
		return data:getVar(k)
	end

	function getDataStd(k)
		return data:getStd():get(k)
	end

	local front = getData(slot1) or 0
	local after = getData("max" .. key) or 0
	local text = ""

	if 0 < front or 0 < after then
		text = front .. "-" .. after
	end

	return text
end

medalUpgrade.uptPropertyPanelByData = function (self, panel, data)
	panel.setVisible(panel, true)

	local lbl_property = {}
	local lbl_property_title = {}
	local valLbl, titleLbl = nil
	local lblName = ""
	local propertyText = ""
	local titleText = ""

	for i = 1, 3, 1 do
		lblName = "lbl_property_" .. i
		lbl_property[i] = ccui.Helper:seekWidgetByName(panel, lblName)

		lbl_property[i]:setVisible(false)

		lbl_property_title[i] = ccui.Helper:seekWidgetByName(panel, lblName .. "_title")

		lbl_property_title[i]:setVisible(false)
	end

	local lbl_index = 1

	for i = 1, 3, 1 do
		propertyText = getPropertyText(data, property_name[i])
		titleText = getPropertyTitle(property_name[i])

		if propertyText ~= "" then
			valLbl = lbl_property[lbl_index]
			titleLbl = lbl_property_title[lbl_index]

			valLbl.setString(valLbl, propertyText)
			valLbl.setVisible(valLbl, true)
			titleLbl.setString(titleLbl, titleText)
			titleLbl.setVisible(titleLbl, true)

			lbl_index = lbl_index + 1
		end
	end

	return 
end
medalUpgrade.showMedalNull = function (self)
	self.rebackBag(self, self.itemData)
	self.clearData(self)
	self.panel_down:setVisible(false)
	self.panel_property_before:setVisible(false)
	self.panel_property_after:setVisible(false)

	local lbl_desc = ccui.Helper:seekWidgetByName(self.rootPanel, "lbl_desc_nomedal")

	lbl_desc.setVisible(lbl_desc, true)
	self.img_medal_before:removeAllChildren()
	self.img_medal_after:removeAllChildren()

	return 
end
medalUpgrade.showMedalFull = function (self)
	self.panel_down:setVisible(false)
	self.panel_property_after:setVisible(false)
	self.img_full:setVisible(true)
	item.new(self.itemData, self.img_medal_before, {
		donotMove = true
	}):addto(self.img_medal_before):pos(self.img_medal_before:getw()*0.5, self.img_medal_before:geth()*0.5)
	self.uptPropertyPanelByData(self, self.panel_property_before, self.itemData)
	item.new(self.itemData, self.img_medal_after, {
		donotMove = true
	}):addto(self.img_medal_after):pos(self.img_medal_after:getw()*0.5, self.img_medal_after:geth()*0.5)
	self.panel_property_after:setVisible(false)

	return 
end
medalUpgrade.showMedalUpgrade = function (self, nextId)
	self.img_full:setVisible(false)

	local lbl_desc = ccui.Helper:seekWidgetByName(self.rootPanel, "lbl_desc_nomedal")

	lbl_desc.setVisible(lbl_desc, false)
	item.new(self.itemData, self.img_medal_before, {
		donotMove = true
	}):addto(self.img_medal_before):pos(self.img_medal_before:getw()*0.5, self.img_medal_before:geth()*0.5)
	self.uptPropertyPanelByData(self, self.panel_property_before, self.itemData)

	self.nextItemData = def.items.getStdItemById(nextId)

	if self.nextItemData then
		item.new(self.nextItemData, self.img_medal_after, {
			donotMove = true
		}):addto(self.img_medal_after):pos(self.img_medal_after:getw()*0.5, self.img_medal_after:geth()*0.5)
		self.uptPropertyPanelByData(self, self.panel_property_after, self.nextItemData)
	else
		print("self.nextItemData is nil")
	end

	return 
end
medalUpgrade.showMedalDownPanel = function (self)
	if not self.nextGradeInfo then
		return 
	end

	local val_cur = {}
	local val_need = {}
	local value_cur = {
		common.getLevelText(g_data.player.ability.FLevel) .. "级",
		g_data.player.ability.FPrestige
	}
	local value_need = {
		common.getLevelText(self.nextGradeInfo.FNeedLevel) .. "级",
		self.nextGradeInfo.FNeedSheWang
	}
	local widgetName = ""

	for i = 1, 2, 1 do
		widgetName = "val_cur_" .. i
		val_cur[i] = ccui.Helper:seekWidgetByName(self.panel_down, widgetName)

		val_cur[i]:setString(tostring(value_cur[i]))

		widgetName = "val_need_" .. i
		val_need[i] = ccui.Helper:seekWidgetByName(self.panel_down, widgetName)

		val_need[i]:setString(tostring(value_need[i]))
	end

	self.panel_down:setVisible(true)

	return 
end
medalUpgrade.putItem = function (self, itemIn, posx, posy)
	local form = itemIn.formPanel.__cname

	if form ~= "bag" then
		return 
	end

	self.clearData(self)

	if not itemIn or not itemIn.data or itemIn.data:getVar("stdMode") ~= 30 then
		return 
	end

	self.itemData = itemIn.data

	requestMedalInfo(itemIn.data.FItemIdent)

	return 
end
local upt_msg = {
	"角色当前等级未达到要求",
	"你的声望点数不足",
	"非法勋章",
	"当前勋章已经达到最高等级",
	"下一级勋章有错误",
	"背包已满"
}
medalUpgrade.onSM_UpdateMedal = function (self, result, protoId)
	local btn_upgrade = ccui.Helper:seekWidgetByName(self.rootPanel, "btn_upgrade")

	btn_upgrade.setTouchEnabled(btn_upgrade, true)

	if result.FRet == 0 then
		tip("勋章升级成功！")
		self.showMedalNull(self)
	elseif result.FRet <= #upt_msg then
		tip(upt_msg[result.FRet])
	else
		tip("未知错误")
	end

	return 
end
medalUpgrade.onSM_MedalInfo = function (self, result, protoId)
	if result.FItemID ~= -1 then
		if result.FNextItemID ~= -1 then
			self.nextGradeInfo = result

			self.showMedalUpgrade(self, result.FNextItemID)
			self.showMedalDownPanel(self)
			self.getItemFromBg(self, self.itemData)
		else
			self.showMedalFull(self)
			print("勋章已满级")
		end
	else
		print("物品错误")
		self.showMedalNull(self)
	end

	return 
end

return medalUpgrade
