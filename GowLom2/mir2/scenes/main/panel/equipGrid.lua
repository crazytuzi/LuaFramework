local equipGrid = class("equipGrid", import(".panelBase"))
local common = import("..common.common")
local item = import("..common.item")
local tipStr = "1、开服100天，且服务器达到三阶段开启强化装备格功能。\n" .. "2、可强化的装备格有武器、头盔、衣服、腰带、靴子、项链、左手镯、右手镯、左戒指、右戒指，共10个装备格。\n" .. "3、头盔、腰带、靴子、项链、手镯、戒指的装备格开服100天可强化。武器、衣服的装备格开服120天可强化.\n" .. "4、装备格可强化至+50，需要佩戴对应位置和相应等级的装备才能发挥全部效果。\n" .. "5、8个或以上的装备格，强化至+13/+18/+35/+45的属性生效时，可获得额外属性。\n" .. "6、强化装备格需要消耗炼体符和金币。炼体符可通过购买和炼体伏魔任务获得。"
equipGrid.ctor = function (self, param)
	self.super.ctor(self)
	self.setMoveable(self, true)

	self.page = param.page or 1
	self.select = param.select or -1

	for k, v in pairs(g_data.equipGrid.equipGridKind) do
		local config = g_data.equipGrid:findEquipGridCfgByIdAndLvl(k, 0)

		if config and config.UpNeedOpenDays and config.UpNeedOpenDays <= g_data.client.openDay then
			self.select = k

			break
		end
	end

	self.tabCallbacks = {}

	return 
end
equipGrid.onEnter = function (self)
	local tabstr = {}
	local tabcb = {}
	tabstr[#tabstr + 1] = "强\n化"
	tabcb[#tabcb + 1] = self.loadStrengthenPage
	self.tabCallbacks = tabcb

	self.initPanelUI(self, {
		title = "装备格",
		bg = "pic/common/black_2.png",
		tab = {
			topmargin = 10,
			strs = tabstr,
			default = self.page or 1
		}
	})
	self.pos(self, display.cx - 102, display.cy)
	self.bindNetEvent(self, SM_UpEquipBar, self.onSM_UpEquipBar)

	return 
end
equipGrid.clearContentNode = function (self)
	if self.contentNode then
		self.contentNode:removeAllChildren()
	end

	self.contentNode = display.newNode():addTo(self.bg)
	self.contentNode.controls = {}
	self.contentNode.data = {}

	return 
end
equipGrid.onTabClick = function (self, idx, btn)
	self.clearContentNode(self)

	self.curTab = self.tabCallbacks[idx]
	self.curIdx = idx

	self.tabCallbacks[idx](self)

	return 
end
equipGrid.loadStrengthenPage = function (self)
	local leftNode = display.newScale9Sprite(res.getframe2("pic/common/black_5.png")):anchor(0, 0):pos(14, 14):size(157, 394):addTo(self.contentNode, 1)
	self.contentNode.controls.leftNode = leftNode
	local rightNode = display.newScale9Sprite(res.getframe2("pic/common/black_5.png")):anchor(0, 0):pos(171, 14):size(457, 394):addTo(self.contentNode)

	display.newSprite(res.gettex2("pic/panels/equipGrid/midbg.png")):anchor(0, 0):pos(1, 0):add2(rightNode)

	self.contentNode.controls.rightNode = rightNode
	local propNode = display.newScale9Sprite(res.getframe2("pic/common/black_4.png")):anchor(0, 0):pos(276, 2):size(180, 391):addTo(rightNode)
	self.contentNode.controls.propNode = propNode

	an.newBtn(res.gettex2("pic/common/question.png"), function ()
		sound.playSound("103")
		an.newMsgbox(tipStr, nil, {
			contentLabelSize = 20,
			title = "提示"
		})

		return 
	end, {
		pressBig = true,
		pressImage = res.gettex2("pic/common/question.png")
	}).pos(slot4, 25, 365):addto(rightNode)

	local lblTitle = an.newLabel("", 22, 1, {
		color = def.colors.Cf0c896
	}):anchor(0.5, 0.5):pos(146, 377):add2(rightNode)
	self.contentNode.controls.lblTitle = lblTitle
	self.contentNode.controls.rightNode = rightNode
	local lblLevel = an.newLabel("", 20, 1, {
		color = def.colors.Cf0c896
	}):anchor(0.5, 0.5):pos(146, 230):add2(rightNode)
	self.contentNode.controls.lblLevel = lblLevel
	local lblNeedStuff = an.newLabel("", 18, 1):anchor(0.5, 0.5):pos(146, 95):add2(rightNode)
	self.contentNode.controls.lblNeedStuff = lblNeedStuff

	display.newSprite(res.gettex2("pic/common/button_search.png")):anchor(0.5, 0.5):pos(210, 160):add2(rightNode)
	an.newLabel("查看", 20, 1, {
		color = def.colors.Cf0c896
	}):anchor(0.5, 0.5):pos(248, 155):add2(rightNode):addUnderline(def.colors.Cf0c896):enableClick(handler(self, self.onEquipGridPreview))

	if 0 <= self.select then
		self.fillEquieListView(self, self.select)
	end

	local activeNode = display.newNode():add2(rightNode)
	local btnStr = "开始强化"

	if not g_data.equipGrid:getEquipBarLvlById(id) then
		btnStr = "激活"
	end

	local strengthenBtn = an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")

		if g_data.client:checkLastTime("equipBarStrengthen", 0.5) then
			g_data.client:setLastTime("equipBarStrengthen", true)

			if -1 < self.select then
				local rsb = DefaultClientMessage(CM_UpEquipBar)
				rsb.FIDx = self.select

				MirTcpClient:getInstance():postRsb(rsb)
			end
		end

		return 
	end, {
		label = {
			btnStr,
			18,
			1,
			{
				color = def.colors.Cf0c896
			}
		},
		pressImage = res.gettex2("pic/common/btn21.png")
	}).pos(slot9, 146, 55):addto(rightNode)
	self.contentNode.controls.strengthenBtn = strengthenBtn
	self.contentNode.controls.activeNode = activeNode

	if 0 <= self.select then
		self.onListSelect(self, self.select)
	end

	return 
end
equipGrid.testStrengthen = function (self, selIdx)
	local ret = {
		FOK = 1,
		FEquipBarList = clone(g_data.equipGrid.FEquipBarList),
		FEquipExtralType = clone(g_data.equipGrid.FEquipBarList)
	}

	for k, v in pairs(ret.FEquipBarList) do
		if selIdx == v.FIDx then
			v.FLevel = v.FLevel + 1

			break
		end
	end

	self.onSM_UpEquipBar(self, ret)

	return 
end
equipGrid.equipBarSelected = function (self, idx)
	local listItems = self.contentNode.controls.listItems

	for i = 1, #listItems, 1 do
		local selectBg = listItems[i]:getChildByName("selectBg")

		if selectBg then
			if listItems[i].idx == idx then
				selectBg.show(selectBg)
			else
				selectBg.hide(selectBg)
			end
		end
	end

	return 
end
equipGrid.fillEquieListView = function (self, selIdx)
	local leftNode = self.contentNode.controls.leftNode

	if not leftNode then
		return 
	end

	local listView = self.newListView(self, 0, 0, 168, 390, 15, {}):add2(leftNode)
	local listItems = {}
	local img_nor = "pic/panels/equipGrid/grid.png"
	local img_prs = "pic/scale/scale4.png"
	local w = 0
	local h = 0
	local id = 0
	local lvl = 0
	local i = 1

	for k, v in pairs(g_data.equipGrid.equipGridKind) do
		lvl = g_data.equipGrid:getEquipBarLvlById(k)
		local config = g_data.equipGrid:findEquipGridCfgByIdAndLvl(k, 0)

		if config and config.UpNeedOpenDays and config.UpNeedOpenDays <= g_data.client.openDay then
			local sprite = nil
			local itemData = g_data.equip:getEquipByPos(k)

			if itemData then
				sprite = res.gettex("items", itemData.getVar(itemData, "looks") or 0)
			else
				sprite = res.gettex2("pic/panels/equipGrid/" .. v[1] .. ".png")
			end

			local selectBg = nil
			local grid = an.newBtn(res.gettex2(img_nor), function ()
				sound.playSound("103")
				self:equipBarSelected(k)
				selectBg:show()
				self:onListSelect(k)

				return 
			end, {
				support = "scroll",
				sprite = sprite
			})

			if lvl and 0 < lvl then
				an.newLabel("+" .. slot10, 14, 1, {
					color = g_data.equipGrid:getTipColorById(lvl)
				}):anchor(0, 1):pos(4, grid.geth(grid) - 1):add2(grid)
			end

			w = 10
			h = listView.lastPos - 10

			if i%2 == 0 then
				w = grid.getw(grid) + 30
				listView.lastPos = listView.lastPos - listView.itemMargin - grid.geth(grid)
			end

			i = i + 1
			selectBg = res.get2("pic/common/light.png"):anchor(0.5, 0.5):pos(grid.getw(grid)/2, grid.geth(grid)/2):scale(1.5):addto(grid)

			selectBg.setName(selectBg, "selectBg")

			if selIdx ~= k then
				selectBg.hide(selectBg)
			end

			grid.anchor(grid, 0, 1):pos(w, h)
			grid.add2(grid, listView)

			grid.idx = k
			listItems[#listItems + 1] = grid
		end

		self.contentNode.controls.listItems = listItems
	end

	return 
end
equipGrid.onListSelect = function (self, selIdx)
	local lastBtn = self.contentNode.controls.lastBtn

	if lastBtn then
		lastBtn.unselect(lastBtn)
		lastBtn.setTouchEnabled(lastBtn, true)
	end

	self.select = selIdx

	if self.curTab == self.loadStrengthenPage then
		self.onStrengthenSelect(self, selIdx)
	end

	return 
end
equipGrid.onStrengthenSelect = function (self, selIdx)
	local rightNode = self.contentNode.controls.rightNode
	local lblTitle = self.contentNode.controls.lblTitle
	local lblLevel = self.contentNode.controls.lblLevel
	local lblNeedStuff = self.contentNode.controls.lblNeedStuff
	local activeNode = self.contentNode.controls.activeNode
	local leftNode = self.contentNode.controls.leftNode
	local strengthenBtn = self.contentNode.controls.strengthenBtn

	if leftNode then
		leftNode.removeAllChildren(leftNode)
	end

	self.fillEquieListView(self, selIdx)
	lblTitle.setString(lblTitle, g_data.equipGrid:getCfgName(selIdx))

	local lvl = g_data.equipGrid:getEquipBarLvlById(selIdx)
	local lvlBarStr = ""

	if lvl and 0 < lvl then
		lvlBarStr = "强化+" .. lvl
	end

	lblLevel.setString(lblLevel, lvlBarStr)

	local boActStr = g_data.equipGrid:getBoActLvlById(selIdx)

	if boActStr then
		boActStr = "生效装备: " .. boActStr .. "级"
	else
		boActStr = ""
	end

	local btnStr = "开始强化"

	if lvl and lvl == 0 then
		btnStr = "激活"
	end

	strengthenBtn.label:setString(btnStr)

	if activeNode then
		activeNode.removeAllChildren(activeNode)

		local itemData = g_data.equip:getEquipByPos(selIdx)

		if itemData then
			item.new(itemData, self, {
				donotClick = true,
				donotMove = true
			}):anchor(0.5, 0.5):pos(146, 280):add2(activeNode)
		else
			display.newSprite(res.gettex2("pic/panels/equipGrid/" .. g_data.equipGrid:getCfgImgName(selIdx) .. ".png")):anchor(0.5, 0.5):pos(146, 280):add2(activeNode)
		end

		local stuffStr = g_data.equipGrid:getNeedStuff(selIdx, lvl + 1)

		lblNeedStuff.setString(lblNeedStuff, stuffStr)
	end

	self.fillPropView(self, selIdx)

	return 
end
equipGrid.fillPropView = function (self, selIdx)
	local function addPropLine(name, value, parent, y)
		local lblProp = an.newLabel(name, 18, 1, {
			color = cc.c3b(240, 200, 150)
		}):anchor(0, 0.5):pos(13, y):add2(parent)

		an.newLabel(value, 18, 1, {
			color = cc.c3b(220, 210, 190)
		}):anchor(0, 0.5):pos(lblProp.getPositionX(lblProp) + lblProp.getw(lblProp), lblProp.getPositionY(lblProp)):add2(parent)

		return 
	end

	local propNode = self.contentNode.controls.propNode

	if propNode then
		propNode.removeAllChildren(slot3)
	end

	local propH = propNode.geth(propNode)

	display.newSprite(res.gettex2("pic/panels/wingUpgrade/flag.png")):anchor(0, 0.5):pos(8, propH - 20):add2(propNode)
	display.newSprite(res.gettex2("pic/panels/wingUpgrade/dqsx.png")):anchor(0, 0.5):pos(26, propH - 20):add2(propNode)
	display.newScale9Sprite(res.getframe2("pic/scale/scale29.png")):anchor(0.5, 1):pos(propNode.getw(propNode)/2, propH - 30):size(170, 160):addTo(propNode)

	local rect = cc.rect(0, 0, 170, 150)
	local scrollCur = an.newScroll(0, 0, rect.width, rect.height):add2(propNode):anchor(0.5, 1):pos(propNode.getw(propNode)/2, propH - 36)
	local nodeCur = display.newNode()
	local poxY = 0
	local nameProps = {
		"攻击:",
		"魔法:",
		"道术:"
	}
	local textCur = {
		"需求等级:",
		"服务器阶段:",
		"装备:",
		"开服天数:",
		nameProps[g_data.player.job + 1],
		"生命:"
	}
	local lvl = g_data.equipGrid:getEquipBarLvlById(selIdx)

	if lvl and 1 <= lvl then
		local dataCur = g_data.equipGrid:getPropValue(selIdx, lvl, g_data.player.job)

		for i = 1, #dataCur, 1 do
			if dataCur[i] ~= "" then
				addPropLine(textCur[i], dataCur[i], nodeCur, -poxY)

				poxY = poxY + 25
			end
		end
	else
		addPropLine("装备格没有被强化", "", nodeCur, -poxY)
	end

	if poxY < rect.height then
		poxY = rect.height - 20
	end

	nodeCur.pos(nodeCur, 0, poxY):add2(scrollCur)
	scrollCur.setScrollSize(scrollCur, rect.width, poxY)
	scrollCur.setScrollOffset(scrollCur, 0, 0)
	display.newSprite(res.gettex2("pic/panels/wingUpgrade/flag.png")):anchor(0, 0.5):pos(8, propH - 210):add2(propNode)
	display.newSprite(res.gettex2("pic/panels/wingUpgrade/xjsx.png")):anchor(0, 0.5):pos(26, propH - 210):add2(propNode)
	display.newScale9Sprite(res.getframe2("pic/scale/scale29.png")):anchor(0.5, 1):pos(propNode.getw(propNode)/2, propH - 225):size(170, 160):addTo(propNode)

	local scrollNext = an.newScroll(0, 0, rect.width, rect.height):add2(propNode):anchor(0.5, 1):pos(propNode.getw(propNode)/2, propH - 226)
	local nodeNext = display.newNode()
	poxY = 0
	local textNext = {
		"下级等级:",
		"服务器阶段:",
		"装备:",
		"开服天数:",
		nameProps[g_data.player.job + 1],
		"生命:"
	}
	lvl = lvl or 0

	if lvl + 1 <= g_data.equipGrid.maxEquipGridLvl then
		local dataNext = g_data.equipGrid:getPropValue(selIdx, lvl + 1, g_data.player.job)

		for i = 1, #dataNext, 1 do
			if dataNext[i] ~= "" then
				addPropLine(textNext[i], dataNext[i], nodeNext, -poxY)

				poxY = poxY + 25
			end
		end
	else
		addPropLine("该装备格已强\n  化至最大值", "", nodeNext, -poxY)
	end

	if poxY < rect.height then
		poxY = rect.height - 20
	end

	nodeNext.pos(nodeNext, 0, poxY):add2(scrollNext)
	scrollNext.setScrollSize(scrollNext, rect.width, poxY)
	scrollNext.setScrollOffset(scrollNext, 0, 0)

	return 
end
equipGrid.onEquipGridPreview = function (self)
	main_scene.ui:togglePanel("equipGridPreview", {
		page = 1
	})

	return 
end
equipGrid.onSM_UpEquipBar = function (self, result, protoId)
	print("panel.equipGrid: 强化结果")

	if result.FOK == 1 then
		print("成功")
		g_data.equipGrid:setEquipBarInfo(result)
		self.onListSelect(self, self.select)
		self.updateBarTip(self)
	elseif result.FOK == 2 then
		print("失败" .. self.select)

		local ret, lvl = g_data.equipGrid:checkSpecialNeed(self.select)

		if ret then
			local msg = ""

			for i = 1, #ret - 1, 1 do
				msg = msg .. ret[i] .. "、"
			end

			msg = msg .. ret[#ret] .. "装备格需强化至+" .. lvl

			main_scene.ui:tip(msg)
		end
	end

	return 
end
equipGrid.updateBarTip = function (self)
	local equip = main_scene.ui.panels.equip

	if equip and equip.page and equip.page == "equip" and equip.lblEquipBarTips then
		equip.showContent(equip, "equip")
	end

	return 
end

return equipGrid
