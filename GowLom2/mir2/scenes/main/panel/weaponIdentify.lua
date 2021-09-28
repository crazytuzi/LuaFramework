local weaponIdentify = class("weaponIdentify", function ()
	return display.newNode()
end)
local item = import("..common.item")
local itemInfo = import("..common.itemInfo")
local stateType = {
	done = 2,
	begin = 1,
	ended = 3
}

local function tip(tipstr)
	main_scene.ui:tip(tipstr, 6)

	return 
end

weaponIdentify.ctor = function (self, param)
	self._supportMove = true
	self.bg = display.newSprite(res.gettex2("pic/panels/drumUpgrade/bg.png")):anchor(0, 0):addTo(self)

	self.size(self, self.bg:getw(), self.bg:geth()):anchor(0, 1):pos(10, display.height - 80)
	display.newScale9Sprite(res.getframe2("pic/common/black_4.png"), 0, 0, cc.size(340, 395)):pos(self.bg:getw()/2, self.bg:geth() - 55):addTo(self.bg):anchor(0.5, 1)

	self.title = an.newLabel("装备精炼", 20, 0, {
		color = def.colors.labelTitle
	}):anchor(0.5, 0.5):pos(self.bg:getw()/2, self.bg:geth() - 27):addTo(self.bg)

	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		self:hidePanel()
		main_scene.ui:hidePanel("bag")

		return 
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}).anchor(slot2, 1, 1):pos(self.getw(self) - 9, self.geth(self) - 9):addTo(self)
	res.get2("pic/panels/fusion/equip3.png"):addTo(self.bg):pos(self.bg:getw()/2, 350)

	self.img_weapon = res.get2("pic/panels/drumUpgrade/drumBgLeft.png"):addTo(self.bg):pos(self.bg:getw()/2, 350)
	self.propertyBg = display.newScale9Sprite(res.getframe2("pic/panels/drumUpgrade/bgProperty.png"), 0, 0, cc.size(328, 90), cc.rect(1, 1, 58, 58)):pos(self.bg:getw()/2, self.bg:geth()/2):addTo(self.bg):anchor(0.5, 0.5)

	local function btnUpgradeCB()
		local text = self.btn_identify.label:getString()

		if text == "立即精炼" then
			if self.current_index == stateType.begin or not self.itemData then
				tip("请拖入想要精炼的装备")
			elseif self.current_index == stateType.done then
				if not self.itemData then
					return 
				end

				local rsb = DefaultClientMessage(CM_RefineEquip)
				rsb.FItemIdent = tonumber(self.itemData.FItemIdent)
				rsb.FfunType = 1

				MirTcpClient:getInstance():postRsb(rsb)
			end
		elseif text == "放入背包" then
			self:showPanel(stateType.begin)
			self:rebackBag(self.itemData)
		elseif text == "二阶精炼" then
			if self.current_index == stateType.begin or not self.itemData then
				tip("请拖入想要二阶精炼的装备")
			elseif self.current_index == stateType.done then
				local rsb = DefaultClientMessage(CM_RefineEquip)
				rsb.FItemIdent = tonumber(self.itemData.FItemIdent)
				rsb.FfunType = 2

				MirTcpClient:getInstance():postRsb(rsb)
			end
		elseif text == "立即分解" then
			if self.current_index == stateType.begin or not self.itemData then
				tip("请拖入想要分解的装备")
			elseif self.current_index == stateType.done then
				local function btnCallback(idx)
					if idx == 1 then
						if not self.itemData then
							return 
						end

						local rsb = DefaultClientMessage(CM_RecyleEquip)
						rsb.FItemIdent = tonumber(self.itemData.FItemIdent)

						MirTcpClient:getInstance():postRsb(rsb)
					end

					self.msgbox = nil

					return 
				end

				if not self.msgbox then
					self.msgbox = an.newMsgbox("确认要分解吗？\n分解之后，装备将消失", stateType, {
						disableScroll = true,
						noclose = true,
						center = true,
						hasCancel = true
					})
				end
			end
		end

		return 
	end

	self.btn_identify = an.newBtn(res.gettex2("pic/common/btn20.png"), slot2, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		label = {
			"立即精炼",
			18,
			0,
			{
				color = def.colors.Cf0c896
			}
		}
	}):pos(self.bg:getw()/2, 45):addTo(self.bg)

	self.showBag(self)

	self.panelType = (param and param.panelType) or 1
	local showList = {
		handler(self, self.showIdentify),
		handler(self, self.showRecycle),
		handler(self, self.showReIdentify)
	}
	self.func = showList[self.panelType]

	self.func(stateType.begin)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_RefineEquip, self, self.onSM_RefineEquip)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_RecyleEquip, self, self.onSM_RecyleEquip)

	return 
end

local function equipMode2Name(stdMode)
	local t = {
		nil,
		nil,
		nil,
		nil,
		"武器",
		"武器",
		nil,
		nil,
		nil,
		"衣服",
		"衣服",
		nil,
		nil,
		nil,
		"头盔",
		"面具",
		nil,
		nil,
		"项链",
		"项链",
		"项链",
		"戒指",
		"戒指",
		"手镯",
		nil,
		"护腕",
		"腰带",
		"鞋子"
	}

	return t[stdMode]
end

weaponIdentify.showIdentify = function (self, state)
	state = state or 1

	self.title:setString("装备精炼")
	self.propertyBg:removeAllChildren()
	self.btn_identify.label:setString("立即精炼")

	if state == 1 then
		an.newLabel("  拖入装备可查看\n精炼属性及成功率", 18, 0, {
			color = cc.c3b(230, 105, 70)
		}):anchor(0, 0.5):pos(90, self.propertyBg:geth()/2):addTo(self.propertyBg)
	elseif state == 2 then
		if self.checkIdentify(self, self.itemData) then
			self.showPanel(self, stateType.ended)

			return 
		end

		local prop_name = def.identify.getIdentifyListByIdx(self.itemData.FIndex)
		local property = def.identify.getIdentifyConfigByIdx(self.itemData.FIndex)
		local equipMode = _G.def.items[self.itemData.FIndex].stdMode
		local equipTypeName = equipMode2Name(equipMode)
		local hasProperty = (property and true) or false
		local isServerStateItem = equipTypeName == "衣服"
		local serverState = 1 <= g_data.client.serverState
		local isCanIdentify = false

		if hasProperty then
			if isServerStateItem and not serverState then
				tip("服务器一阶段后可精炼衣服")
			else
				isCanIdentify = true
			end
		else
			tip("该道具不可精炼")
		end

		if isCanIdentify then
			res.get2("pic/panels/drumUpgrade/tip.png"):addTo(self.propertyBg):pos(10, self.propertyBg:geth() - 20):anchor(0, 0.5)
			an.newLabel("精炼后新增的属性", 20, 0, {
				color = def.colors.Cf0c896
			}):anchor(0, 0.5):pos(30, self.propertyBg:geth() - 18):addTo(self.propertyBg)
			self.updateIdentifyProperty(self, property, prop_name)
		else
			self.showPanel(self, stateType.begin)
			self.rebackBag(self, self.itemData)
		end
	elseif state == 3 then
		self.showWeapon(self)
		an.newLabel("该装备已经被精炼过了", 18, 0, {
			color = cc.c3b(230, 105, 70)
		}):anchor(0, 0.5):pos(90, self.propertyBg:geth()/2):addTo(self.propertyBg)
		self.btn_identify.label:setString("放入背包")
	end

	return 
end
weaponIdentify.showRecycle = function (self, state)
	state = state or 1

	self.title:setString("装备分解")
	self.propertyBg:removeAllChildren()

	if state == 1 then
		an.newLabel("  拖入装备可查看\n分解后获得的物品", 18, 0, {
			color = cc.c3b(230, 105, 70)
		}):anchor(0, 0.5):pos(90, self.propertyBg:geth()/2):addTo(self.propertyBg)
	elseif state == 2 then
		res.get2("pic/panels/drumUpgrade/tip.png"):addTo(self.propertyBg):pos(10, self.propertyBg:geth() - 20):anchor(0, 0.5)
		an.newLabel("分解可获得：", 20, 0, {
			color = def.colors.Cf0c896
		}):anchor(0, 0.5):pos(30, self.propertyBg:geth() - 20):addTo(self.propertyBg)

		local property = def.identify.getRecycleConfigByIdx(self.itemData.FIndex)

		if property then
			self.updateRecycleInfo(self, property)
		else
			tip("该道具不可分解")
			self.showPanel(self, stateType.begin)
		end
	end

	self.btn_identify.label:setString("立即分解")

	return 
end
weaponIdentify.showReIdentify = function (self, state)
	state = state or 1

	self.title:setString("二阶精炼")
	self.propertyBg:removeAllChildren()
	self.btn_identify.label:setString("二阶精炼")

	if state == 1 then
		an.newLabel("  拖入装备可查看二\n阶精炼属性及成功率", 18, 0, {
			color = cc.c3b(230, 105, 70)
		}):anchor(0, 0.5):pos(90, self.propertyBg:geth()/2):addTo(self.propertyBg)
	elseif state == 2 then
		local prop_name = def.identify.getSecDefineListByIdx(self.itemData.FIndex)
		local property = def.identify.getSecDefineConfigByIdx(self.itemData.FIndex)

		if not property then
			tip("该道具不可二阶精炼")
			self.showReIdentify(self, stateType.begin)

			return 
		end

		if not self.isCanIdentify(self, self.itemData) then
			self.showWeapon(self)
			an.newLabel("该道具不可精炼", 18, 0, {
				color = cc.c3b(230, 105, 70)
			}):anchor(0, 0.5):pos(90, self.propertyBg:geth()/2):addTo(self.propertyBg)
			self.btn_identify.label:setString("放入背包")

			return 
		end

		if not self.checkIdentify(self, self.itemData) then
			self.showWeapon(self)
			an.newLabel("该道具尚未精炼", 18, 0, {
				color = cc.c3b(230, 105, 70)
			}):anchor(0, 0.5):pos(90, self.propertyBg:geth()/2):addTo(self.propertyBg)
			self.btn_identify.label:setString("放入背包")

			return 
		end

		if self.checkSecIdentify(self, self.itemData) then
			self.showPanel(self, stateType.ended)

			return 
		end

		if property then
			res.get2("pic/panels/drumUpgrade/tip.png"):addTo(self.propertyBg):pos(10, self.propertyBg:geth() - 20):anchor(0, 0.5)
			an.newLabel("可获得的二阶精炼属性", 20, 0, {
				color = def.colors.Cf0c896
			}):anchor(0, 0.5):pos(30, self.propertyBg:geth() - 18):addTo(self.propertyBg)
			self.updateIdentifyProperty(self, property, prop_name)
		end
	elseif state == 3 then
		self.showWeapon(self)
		an.newLabel("该道具已经二阶精炼过了", 18, 0, {
			color = cc.c3b(230, 105, 70)
		}):anchor(0, 0.5):pos(90, self.propertyBg:geth()/2):addTo(self.propertyBg)
		self.btn_identify.label:setString("放入背包")
	end

	return 
end
weaponIdentify.showPanel = function (self, index)
	self.current_index = index

	self.func(index)

	return 
end
weaponIdentify.updateIdentifyProperty = function (self, property, prop_name)
	self.showWeapon(self)

	local posX = self.propertyBg:getw()/2 - 40
	local posY = self.propertyBg:geth() - 24
	local num = 0
	local scroll = an.newScroll(2, 3, self.propertyBg:getw() - 4, self.propertyBg:geth() - 20, {}):add2(self.propertyBg, 1):anchor(0, 0)

	for k, v in pairs(prop_name) do
		num = num + 1
		posY = posY - num%2*24

		if num%2 == 1 then
			posX = 30
		else
			posX = 165
		end

		local valuelabel = an.newLabel(v.value, 20, 0, {
			color = def.colors.Cdcd2be
		}):anchor(0, 0.5):pos(posX, posY):add2(scroll)
		local namelabel = an.newLabel(v.text, 20, 0, {
			color = def.colors.Cf0c896
		}):anchor(0, 0.5):pos(posX, posY):add2(scroll)

		valuelabel.pos(valuelabel, namelabel.getPositionX(namelabel) + namelabel.getw(namelabel), namelabel.getPositionY(namelabel))
	end

	local strNeedStuff = property.NeedStuff
	local need_list = string.split(strNeedStuff, ";")
	local maxw = 300
	local space = 0
	local desc = {}

	res.get2("pic/panels/drumUpgrade/tip.png"):addTo(self.propertyBg):pos(10, self.propertyBg:geth() - 110):anchor(0, 0.5)
	an.newLabel("所需材料:", 20, 0, {
		color = def.colors.Cf0c896
	}):anchor(0, 0.5):pos(30, self.propertyBg:geth() - 110):addTo(self.propertyBg)

	for i = 1, #need_list, 1 do
		num = num + 1
		local p_list = string.split(need_list[i], "=")
		local t_list = string.split(p_list[i], "&")

		if 2 <= #t_list then
			p_list[1] = t_list[2]
		end

		if p_list[1] == "金币" then
			local coinNum = tonumber(p_list[2])

			if 10000 < coinNum then
				desc[#desc + 1] = {
					text = tostring(math.floor(coinNum/10000) .. "万金币"),
					color = def.colors.Cf0c896
				}
			else
				desc[#desc + 1] = {
					text = p_list[2] .. "金币",
					color = def.colors.Cf0c896
				}
			end
		else
			desc[#desc + 1] = {
				text = p_list[1] .. "*" .. p_list[2],
				color = def.colors.Cf0c896
			}
		end
	end

	local posX = self.propertyBg:getw()/2 - 40
	local posY = self.propertyBg:geth() - 110 - 5

	for i, v in ipairs(desc) do
		posY = posY - i%2*24

		if i%2 == 1 then
			posX = 30
		else
			posX = 165
		end

		an.newLabel(desc[i].text, 20, 0, {
			color = def.colors.Cf0c896
		}):anchor(0, 0.5):pos(posX, posY):addTo(self.propertyBg, 1)
	end

	local strChance = property.Chance
	local nChance = tonumber(strChance)/10
	local chanceM = an.newLabelM(maxw - space*2, 20, 1):pos(space, -100):add2(self.propertyBg):anchor(0, 0)

	chanceM.addLabel(chanceM, "成功率 ", def.colors.Cf0c896)
	chanceM.addLabel(chanceM, nChance .. "%", def.colors.Cfad264)
	chanceM.pos(chanceM, self.propertyBg:getw()/2 - 50, -120)

	return 
end
weaponIdentify.updateRecycleInfo = function (self, property)
	self.showWeapon(self)

	local get_list = string.split(property.GetStuff, ";")
	local desc = {}
	local w = self.propertyBg:getw()/2
	local h = (self.propertyBg:geth() - 30)/2
	local descLabel = an.newLabelM(250, 20, 1, {
		center = true
	}):pos(125, h):anchor(0.5, 0.5):add2(self.propertyBg)
	local strGetList = ""

	for i = 1, #get_list, 1 do
		local p_list = string.split(get_list[i], "=")
		desc[#desc + 1] = {
			text = p_list[1],
			color = display.COLOR_RED
		}
		desc[#desc + 1] = {
			text = "*" .. p_list[2]
		}
		desc[#desc + 1] = {
			text = "\n"
		}
	end

	for i, v in ipairs(desc) do
		descLabel.addLabel(descLabel, v.text, v.color)
	end

	return 
end
weaponIdentify.getBackItem = function (self, item)
	local data = item.data

	if not data then
		return 
	end

	g_data.bag:addItem(data)

	if main_scene.ui.panels.bag then
		main_scene.ui.panels.bag:addItem(data.FItemIdent)
	end

	local target = nil

	for i, v in pairs(self.items) do
		if v and v.isItems and v.data.FItemIdent == data.FItemIdent then
			target = i

			v.removeSelf(v)

			self.items[i] = nil
			g_data.bag.upgradeWeapon[i] = nil

			break
		end
	end

	return 
end
weaponIdentify.showWeapon = function (self)
	if self.img_weapon and self.itemData then
		self.img_weapon:removeAllChildren()
		item.new(self.itemData, self.img_weapon, {
			donotMove = true
		}):addto(self.img_weapon):pos(self.img_weapon:getw()*0.5, self.img_weapon:geth()*0.5)
		self.getItemFromBg(self, self.itemData)
	end

	return 
end
weaponIdentify.checkSecIdentify = function (self, data)
	local attributeRefin = data.getVar(data, "vtAttributeSecRefine") and tonumber(data.getVar(data, "vtAttributeSecRefine"))

	if attributeRefin == 2 then
		return true
	end

	return 
end
weaponIdentify.isCanIdentify = function (self, data)
	local property = def.identify.getIdentifyConfigByIdx(self.itemData.FIndex)

	if property then
		return true
	else
		return false
	end

	return 
end
weaponIdentify.checkIdentify = function (self, data)
	local attributeRefin = data.getVar(data, "AttributeRefin") and tonumber(data.getVar(data, "AttributeRefin"))

	if attributeRefin == 2 then
		return true
	end

	return 
end
weaponIdentify.putItem = function (self, itemIn, posx, posy)
	local form = itemIn.formPanel.__cname

	if form ~= "bag" then
		return 
	end

	if self.itemData then
		self.rebackBag(self, self.itemData)
	end

	self.itemData = itemIn.data

	if not self.itemData then
		self.showPanel(self, stateType.begin)
		self.rebackBag(self, self.itemData)
		print("weaponIdentify:putItem(itemIn.data is nil!)")

		return 
	end

	self.showPanel(self, stateType.done)

	return 
end
weaponIdentify.getItemFromBg = function (self, data)
	if not data then
		return 
	end

	if main_scene.ui.panels.bag then
		main_scene.ui.panels.bag:delItem(data.FItemIdent)
	end

	return 
end
weaponIdentify.rebackBag = function (self, data)
	if not data then
		return 
	end

	self.itemData = nil

	if main_scene.ui.panels.bag then
		main_scene.ui.panels.bag:addItem(data.FItemIdent)
	end

	self.img_weapon:removeAllChildren()

	return 
end
weaponIdentify.showBag = function (self)
	if main_scene.ui.panels then
		if main_scene.ui.panels.bag then
			local w = self.getw(self)

			main_scene.ui.panels.bag:pos(395, display.height - 80):anchor(0, 1)
		else
			main_scene.ui:togglePanel("bag")
			main_scene.ui.panels.bag:pos(self.getw(self) + 10, display.height - 80)
		end
	end

	return 
end
weaponIdentify.onSM_RefineEquip = function (self, result)
	if not result then
		return 
	end

	dump(result)

	local tipMsg = {}

	if self.panelType == 1 and result.FfunType == 1 then
		tipMsg = {
			[0] = "精炼失败",
			"精炼成功",
			"精炼失败，背包已满",
			"精炼材料不足",
			"该道具已精炼"
		}
	elseif self.panelType == 3 and result.FfunType == 2 then
		tipMsg = {
			[0] = "二阶精炼失败",
			"二阶精炼成功",
			"二阶精炼失败，背包已满",
			"二阶精炼材料不足",
			"该道具已精炼"
		}
	end

	if tipMsg[result.FRet] then
		tip(tipMsg[result.FRet])
	end

	if result.FRet == 1 then
		self.showPanel(self, stateType.begin)
		self.rebackBag(self, self.itemData)
	elseif result.FRet == 4 then
		self.showPanel(self, stateType.ended)
	end

	return 
end
weaponIdentify.onSM_RecyleEquip = function (self, result)
	if not result then
		return 
	end

	if result.FRet == 0 then
		self.rebackBag(self, self.itemData)
		self.showPanel(self, stateType.begin)
		tip("该道具不可分解")
	elseif result.FRet == 1 then
		tip("分解成功")

		self.itemData = nil

		self.showBag(self)
		self.showPanel(self, stateType.begin)
		self.img_weapon:removeAllChildren()
	elseif result.FRet == 2 then
		tip("分解失败，背包不足")
	end

	return 
end

return weaponIdentify
