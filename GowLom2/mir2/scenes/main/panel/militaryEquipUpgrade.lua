local militaryEquipUpgrade = class("militaryEquipUpgrade", import(".panelBase"))
local item = import("..common.item")
local menuList = {
	"佩剑",
	"战旗",
	"官印",
	"兵书"
}
militaryEquipUpgrade.ctor = function (self, params)
	self.super.ctor(self)
	self.setMoveable(self, true)

	self.job = g_data.player.job

	self.initPanelUI(self, {
		title = "军衔装备",
		bg = "pic/common/black_2.png"
	})
	self.anchor(self, 0.5, 0.5):pos(display.width/2 - 100, display.height/2)
	self.setupUI(self)
	self.bindNetEvent(self, SM_UpRankEquip, self.onSM_UpRankEquip)

	return 
end
militaryEquipUpgrade.setupUI = function (self)
	local leftNode = display.newScale9Sprite(res.getframe2("pic/common/black_5.png")):anchor(0, 0):pos(14, 14):size(125, 390):addTo(self.bg, 1)
	local rightNode = display.newScale9Sprite(res.getframe2("pic/common/black_5.png")):anchor(0, 0):pos(139, 14):size(275, 390):addTo(self.bg)

	rightNode.setName(rightNode, "rightNode")

	local tabs = {}
	local posi = 0
	self.nodeActType = display.newNode():addTo(self, 10)
	local infoView = an.newScroll(6, 18, 140, 384):add2(self.nodeActType, 2)

	for i = 1, #menuList, 1 do
		posi = posi + 1
		tabs[i] = an.newBtn(res.gettex2("pic/common/btn60.png"), function (btn)
			local clickedIndex = 1

			for i, v in ipairs(tabs) do
				if v == btn then
					v.select(v)

					clickedIndex = i
				else
					v.unselect(v)
				end
			end

			self:onTabClick(i)

			return 
		end, {
			support = "scroll",
			label = {
				menuList[i],
				20,
				0,
				def.colors.Cf0c896
			},
			select = {
				res.gettex2("pic/common/btn61.png"),
				manual = true
			}
		}).add2(slot10, infoView):pos(70, (posi - 1)*50 - 355)

		tabs[i].label:setColor(def.colors.Cf0c896)

		tabs[i].title = menuList[i]
	end

	local equipType = 1

	self.onTabClick(self, equipType)
	tabs[equipType]:select()

	local tipStr_upgrade = {
		{
			"1、开服50天，且服务器达到1阶段，角色提升至50级，开启军衔装备升级。\n"
		},
		{
			"2、佩剑、战旗、官印、兵书，共4件军衔装备可升级。\n"
		},
		{
			"3、军衔装备升级消耗对应的装备灵魄。\n"
		},
		{
			"4、不同等级阶段的军衔装备，具备不同的外形。\n"
		},
		{
			"5、“战旗”提升至20级，可放置在跨服沙巴克的攻城区域。\n"
		},
		{
			"6、战旗无阻挡，不能被攻击。且无法拔除其他玩家的战旗。\n"
		},
		{
			"7、军衔装备的灵魄，均由跨服活动产出。\n"
		}
	}

	an.newBtn(res.gettex2("pic/common/question.png"), function ()
		sound.playSound("103")
		an.newMsgbox(tipStr_upgrade, nil, {
			contentLabelSize = 20,
			title = "提示"
		})

		return 
	end, {
		pressBig = true,
		pressImage = res.gettex2("pic/common/question.png")
	}).pos(slot8, 170, 365):addto(self.bg, 20)

	local function onHorsePreview()
		main_scene.ui:togglePanel("militaryEquipPreview", {
			equipType = self.currentSelectType,
			menu = menuList,
			job = self.job
		})

		return 
	end

	display.newSprite(res.gettex2("pic/panels/wingUpgrade/button_search.png")).anchor(slot9, 0.5, 0.5):pos(303, 175):add2(self.bg)
	an.newLabel("升级预览", 20, nil, {
		color = cc.c3b(240, 200, 150)
	}):addTo(self.bg):pos(318, 176):anchor(0, 0.5):addUnderline():enableClick(onHorsePreview)

	return 
end
militaryEquipUpgrade.refreshView = function (self)
	self.onTabClick(self, self.currentSelectType)

	return 
end
militaryEquipUpgrade.onTabClick = function (self, equipType)
	local rightNode = self.bg:getChildByName("rightNode")

	if rightNode then
		rightNode.removeAllChildren(rightNode)
	end

	local militaryEquipInfo = g_data.player:getMilitaryEquipListById(equipType)
	self.currentSelectType = equipType
	local title = menuList[equipType]
	local midNode = display.newSprite(res.gettex2("pic/panels/solider/gemstone_bg.png")):anchor(0, 0):pos(3, 2):add2(rightNode)

	an.newLabel(title, 22, 0, {
		color = def.colors.Cdcd2be
	}):anchor(0.5, 0.5):pos(midNode.getw(midNode)/2, midNode.geth(midNode) - 15):addTo(midNode)
	an.newLabel(militaryEquipInfo.FLevel .. "级" .. title, 20, 0, {
		color = def.colors.labelTitle
	}):anchor(0.5, 0.5):pos(midNode.getw(midNode)/2, midNode.geth(midNode)/2 - 90):addTo(midNode)

	local curEquip = def.militaryEquip.getEquipPropertyByLevel(equipType, militaryEquipInfo.FLevel)
	local nextEquip = def.militaryEquip.getEquipPropertyByLevel(equipType, militaryEquipInfo.FLevel + 1)

	def.militaryEquip.getEquipIcon(curEquip):add2(midNode):pos(midNode.getw(midNode)/2 + 5, 275)

	if def.militaryEquip.isCanLevelUp(equipType, militaryEquipInfo.FLevel + 1) then
		local upNeedArr = string.split(nextEquip.NeedStuff, "&")
		local tipLabel = an.newLabel("消耗，", 20, 0, {
			color = def.colors.labelTitle
		}):anchor(0.5, 0.5):pos(midNode.getw(midNode)/2 - 80, midNode.geth(midNode)/2 - 120):addTo(midNode)
		local arr = string.split(upNeedArr[2], "|")
		local itemIdx = def.items.getItemIdByName(arr[1])
		local itemData = def.items.getStdItemById(itemIdx)
		itemData.FDura = ""
		local m1 = item.new(itemData, self, {
			scroll = true,
			donotMove = true,
			idx = idx
		}):add2(midNode, 2):pos(tipLabel.getPositionX(tipLabel) + 30, tipLabel.getPositionY(tipLabel)):scale(0.7)
		local lblNeedCount = an.newLabel("*" .. arr[2], 17, 1, {
			color = def.colors.title
		}):anchor(0, 0.5):pos(m1.getPositionX(m1) + 15, m1.getPositionY(m1)):add2(midNode)

		an.newLabel("和", 20, 1, {
			color = cc.c3b(240, 200, 150)
		}):anchor(0, 0.5):pos(lblNeedCount.getPositionX(lblNeedCount) + lblNeedCount.getw(lblNeedCount) + 5, 73):add2(midNode)

		local id = def.items.getItemIdByName("金币1")
		local gold = def.items.getStdItemById(id)

		item.new(gold, self, {
			isGold = true,
			donotMove = true,
			tex = res.gettex2("pic/panels/bag/gold.png")
		}):add2(midNode):pos(lblNeedCount.getPositionX(lblNeedCount) + lblNeedCount.getw(lblNeedCount) + 50, 73)

		slot17 = an.newLabel(nextEquip.NeedGoldNum/10000 .. "万", 17, 1, {
			color = def.colors.labelTitle
		}):anchor(0, 0.5):pos(lblNeedCount.getPositionX(lblNeedCount) + lblNeedCount.getw(lblNeedCount) + 70, 73):add2(midNode)
	end

	local btnLabel = "升级"

	if militaryEquipInfo.FLevel == 0 then
		btnLabel = "激活"
	end

	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")
		self:doUpgrade()

		return 
	end, {
		clickSpace = 1,
		pressImage = res.gettex2("pic/common/btn21.png"),
		label = {
			btnLabel,
			18,
			0,
			{
				color = def.colors.Cf0c896
			}
		}
	}).add2(slot9, midNode):pos(midNode.getw(midNode)/2, 30)

	local propNode = display.newScale9Sprite(res.getframe2("pic/common/black_5.png")):anchor(0, 0):pos(276, 0):size(215, 390):addTo(rightNode)
	local posX = 10
	local posY = 380

	display.newScale9Sprite(res.getframe2("pic/scale/scale29.png")):anchor(0, 1):pos(10, 350):size(200, 150):addTo(propNode)
	display.newSprite(res.gettex2("pic/panels/wingUpgrade/flag.png")):anchor(0, 0.5):pos(8, posY - 15):add2(propNode)
	display.newSprite(res.gettex2("pic/panels/wingUpgrade/dqsx.png")):anchor(0, 0.5):pos(26, posY - 15):add2(propNode)

	local curScroll = an.newScroll(10, 350, 200, 150, {
		labelM = {
			0,
			0
		}
	}):addTo(propNode):anchor(0, 1)
	posY = curScroll.geth(curScroll)

	if militaryEquipInfo.FLevel == 0 then
		an.newLabel("装备未激活", 18, 0, {
			color = def.colors.Cf0c896
		}):anchor(0, 0.5):pos(posX, posY - 40):addTo(curScroll)
	else
		for i, k in ipairs(def.militaryEquip.dumpPropStr(curEquip.PropertyStr, self.job)) do
			local property = (k[3] ~= nil and k[2] .. "-" .. k[3]) or "+" .. k[2]
			local m1 = an.newLabel(k[1] .. ":", 18, 0, {
				color = def.colors.Cf0c896
			}):anchor(0.5, 0.5):pos(posX, posY - i*25):addTo(curScroll):anchor(0, 0.5)

			an.newLabel(property, 18, 0, {
				color = def.colors.Cdcd2be
			}):anchor(0.5, 0.5):pos(m1.getPositionX(m1) + m1.getw(m1), posY - i*25):addTo(curScroll):anchor(0, 0.5)
		end
	end

	posY = propNode.geth(propNode)/2
	local posY2 = 0

	display.newScale9Sprite(res.getframe2("pic/scale/scale29.png")):anchor(0, 1):pos(10, 160):size(200, 150):addTo(propNode)
	display.newSprite(res.gettex2("pic/panels/wingUpgrade/flag.png")):anchor(0, 0.5):pos(8, (posY + posY2) - 15):add2(propNode)
	display.newSprite(res.gettex2("pic/panels/wingUpgrade/xjsx.png")):anchor(0, 0.5):pos(26, (posY + posY2) - 15):add2(propNode)

	local nextScroll = an.newScroll(10, 160, 200, 150, {
		labelM = {
			0,
			0
		}
	}):addTo(propNode):anchor(0, 1)
	posY = nextScroll.geth(nextScroll)

	local function addlabelFunc(text1, cor1, text2, cor2, index)
		local m1 = an.newLabel(text1, 18, 0, {
			color = cor1
		}):anchor(0.5, 0.5):pos(posX, posY - index*25):addTo(nextScroll):anchor(0, 0.5)

		an.newLabel(text2, 18, 0, {
			color = cor2
		}):anchor(0.5, 0.5):pos(m1.getPositionX(m1) + m1.getw(m1), m1.getPositionY(m1)):addTo(nextScroll):anchor(0, 0.5)

		return 
	end

	local num = 1

	if def.militaryEquip.isCanLevelUp(item, militaryEquipInfo.FLevel + 1) then
		local numMap = {
			"一",
			"二",
			"三",
			"四",
			"五",
			"六",
			"七",
			"八",
			"九"
		}

		if g_data.client.serverState < nextEquip.NeedServerStep then
			addlabelFunc("需要服务阶段:", def.colors.Cf0c896, tostring(numMap[nextEquip.NeedServerStep]) .. "阶", def.colors.Cdcd2be, num)

			num = num + 1
		end

		if g_data.client.openDay < nextEquip.NeedOpenDays then
			addlabelFunc("需要开区天数:", def.colors.Cf0c896, nextEquip.NeedOpenDays .. "天", def.colors.Cdcd2be, num)

			num = num + 1
		end

		if g_data.player.ability.FLevel < nextEquip.NeedPlayerLevel then
			addlabelFunc("需要人物等级:", def.colors.Cf0c896, common.getLevelText(nextEquip.NeedPlayerLevel) .. "级", def.colors.Cdcd2be, num)

			num = num + 1
		end

		if g_data.player.militaryRank < nextEquip.NeedMRLv then
			addlabelFunc("需要军衔等级:", def.colors.Cf0c896, nextEquip.NeedMRLv .. "级", def.colors.Cdcd2be, num)

			num = num + 1
		end

		for i, k in ipairs(def.militaryEquip.dumpPropStr(nextEquip.PropertyStr, self.job)) do
			local property = (k[3] ~= nil and k[2] .. "-" .. k[3]) or "+" .. k[2]

			addlabelFunc(k[1] .. ":", def.colors.Cf0c896, property, def.colors.Cdcd2be, num)

			num = num + 1
		end
	else
		an.newLabel("装备已满级", 18, 0, {
			color = def.colors.Cf0c896
		}):anchor(0, 0.5):pos(posX, posY - 40):addTo(nextScroll)
	end

	main_scene.ui:hidePanel("militaryEquipPreview")

	return 
end
militaryEquipUpgrade.doUpgrade = function (self)
	local rsb = DefaultClientMessage(CM_UpRankEquip)
	rsb.FREID = self.currentSelectType

	MirTcpClient:getInstance():postRsb(rsb)
	main_scene.ui.waiting:show(3, "CM_UpRankEquip")

	return 
end
militaryEquipUpgrade.onSM_UpRankEquip = function (self, result)
	main_scene.ui.waiting:close("CM_UpRankEquip")
	dump(result)
	self.refreshView(self)

	return 
end
militaryEquipUpgrade.onCloseWindow = function (self)
	main_scene.ui:hidePanel("militaryEquipPreview")

	return self.super.onCloseWindow(self)
end

return militaryEquipUpgrade
