local wingUpgrade = class("wingUpgrade", import(".panelBase"))
local pointTip = import("..common.pointTip")
local item = import("..common.item")
local stateEffectConfig = def.stateEffectCfg
local tipStr1 = [[
1.羽翼系统会在服务器达到二阶段开启，升级羽翼可提升人物属性。
2.使用白色羽毛可随机获得经验，经验达到上限后羽翼等级提升，羽毛会直接从背包中扣除。
3.当羽翼达到一定等级时，可消耗材料激活羽翼属性，材料会直接从背包中扣除。
4.激活后，玩家可永久获得该羽翼的属性加成。
5.满足条件后可消耗材料，永久获得羽翼时装外显，材料会直接从背包中扣除。
1）纯洁之翼：要求羽翼达到一阶十星、并激活纯洁之翼；
2）疯狂之翼：要求羽翼达到三阶五星、并激活疯狂之翼、且获得纯洁之翼时装外显；
3）大天使之翼：要求羽翼达到四阶十星、并激活大天使之翼、且获得纯洁之翼时装外显；
4）大魔神之翼：要求羽翼达到六阶十星、并激活大魔神之翼、且获得疯狂之翼或大天使之翼时装外显；
5）辉煌天使之翼：要求羽翼达到八阶十星、并激活辉煌天使之翼、且获得疯狂之翼或大天使之翼时装外显；
6）傲气魔神之翼：要求羽翼达到十阶十星、并激活傲气魔神之翼、且获得大魔神之翼或辉煌天使之翼时装外显；
6.时装外显无论开启多少、无论是否展示，玩家都可永久获得所有开启时装的属性加成。
7.玩家可以选择是否展示时装外显。]]
local UPGRADE_MATERIAL = "白色羽毛"
local ACTIVE_MATERIAL = "白色羽毛"
local SHOW_MATERIAL = "金色羽毛"
wingUpgrade.ctor = function (self, page)
	self.super.ctor(self)
	self.setMoveable(self, true)

	self.page = page or 1
	self.tabCallbacks = {
		self.loadUpgradePage,
		self.loadActivePage,
		self.loadShowPage
	}

	if def.wingEquip.getIsOpen("毛羽") then
		self.tabCallbacks[#self.tabCallbacks + 1] = self.loadWingEquipPage
	end

	return 
end
wingUpgrade.onEnter = function (self)
	local tabStrs = {
		"升\n级",
		"激\n活",
		"展\n示"
	}

	if def.wingEquip.getIsOpen("毛羽") then
		tabStrs[#tabStrs + 1] = "羽\n装"
	end

	self.initPanelUI(self, {
		title = "羽翼",
		bg = "pic/common/black_2.png",
		tab = {
			strs = tabStrs,
			default = self.page
		}
	})
	self.pos(self, display.cx - 102, display.cy)
	self.bindNetEvent(self, SM_UpWing, self.onSM_UpWing)
	self.bindNetEvent(self, SM_ActivateWing, self.onSM_ActivateWing)
	self.bindNetEvent(self, SM_ShowWing, self.onSM_ShowWing)
	self.bindNetEvent(self, SM_GetWingShow, self.onSM_GetWingShow)
	self.bindNetEvent(self, SM_UnloadWing, self.onSM_UnloadWing)
	self.bindNetEvent(self, SM_UpWingEquip, self.onSM_UpWingEquip)
	self.bindNotify(self, "M_POINTTIP", self.onM_POINTTIP)
	self.bindNotify(self, "M_WINGEQUIP_CHG", self.onM_WINGEQUIP_CHG)
	self.updateTabPointTip(self)

	return 
end
wingUpgrade.onCloseWindow = function (self)
	main_scene.ui:hidePanel("wingPreview")

	return self.super.onCloseWindow(self)
end
wingUpgrade.clearContentNode = function (self)
	if self.contentNode then
		self.contentNode:removeAllChildren()
	end

	self.contentNode = display.newNode():addTo(self.bg)
	self.contentNode.controls = {}
	self.contentNode.data = {}

	return 
end
wingUpgrade.onTabClick = function (self, idx, btn)
	self.clearContentNode(self)

	self.curTab = self.tabCallbacks[idx]

	self.tabCallbacks[idx](self)

	return 
end
wingUpgrade.loadUpgradePage = function (self)
	local wingLevel = g_data.player.wingInfo.FWingLv
	local rightNode = display.newScale9Sprite(res.getframe2("pic/common/black_4.png"), 0, 0, cc.size(174, 390)):anchor(0, 0):pos(458, 14):addTo(self.contentNode)
	local leftNode = display.newScale9Sprite(res.getframe2("pic/common/black_5.png")):anchor(0, 0):pos(14, 14):size(442, 390):addTo(self.contentNode)

	display.newScale9Sprite(res.getframe2("pic/panels/wingUpgrade/node_bg.png")):size(436, 275):anchor(0, 0):pos(3, 2):add2(leftNode)
	display.newSprite(res.gettex2("pic/panels/wingUpgrade/role_wing_bg.png")):anchor(0.5, 0.5):pos(218, 198):add2(leftNode)
	display.newSprite(res.gettex2("pic/panels/wingUpgrade/flag.png")):anchor(0, 0.5):pos(8, 369):add2(rightNode)
	display.newSprite(res.gettex2("pic/panels/wingUpgrade/dqsx.png")):anchor(0, 0.5):pos(26, 369):add2(rightNode)
	display.newSprite(res.gettex2("pic/panels/wingUpgrade/flag.png")):anchor(0, 0.5):pos(8, 153):add2(rightNode)
	display.newSprite(res.gettex2("pic/panels/wingUpgrade/xjsx.png")):anchor(0, 0.5):pos(26, 153):add2(rightNode)
	display.newSprite(res.gettex2("pic/panels/equipforge/irtJT.png")):anchor(0.5, 0.5):pos(80, 203):add2(rightNode):setRotation(90)
	an.newBtn(res.gettex2("pic/common/question.png"), function ()
		sound.playSound("103")
		an.newMsgbox(tipStr1, nil, {
			contentLabelSize = 20,
			title = "提示"
		})

		return 
	end, {
		pressBig = true,
		pressImage = res.gettex2("pic/common/question.png")
	}).pos(slot4, 25, 365):addto(leftNode)
	display.newSprite(res.gettex2("pic/panels/wingUpgrade/title_bg.png")):anchor(0.5, 0.5):pos(leftNode.getw(leftNode)/2, 366):add2(leftNode)

	local lblWingName = an.newLabel(def.wing.level2str(wingLevel) .. "·羽翼", 20, 1, {
		color = cc.c3b(55, 148, 251)
	}):anchor(0.5, 0.5):pos(leftNode.getw(leftNode)/2, 366):add2(leftNode)
	self.contentNode.controls.lblWingName = lblWingName

	display.newSprite(res.gettex2("pic/panels/wingUpgrade/button_search.png")):anchor(0.5, 0.5):pos(338, 168):add2(leftNode)
	an.newLabel("羽翼预览", 20, nil, {
		color = cc.c3b(240, 200, 150)
	}):addTo(leftNode):pos(352, 168):anchor(0, 0.5):addUnderline():enableClick(function ()
		main_scene.ui:togglePanel("wingPreview", self.curItemId)

		return 
	end)

	local wingCfg = def.wing.getUpgradeCfg(UPGRADE_MATERIAL)
	local showCount = 0

	if wingLevel == 0 then
		showCount = 0
	elseif wingLevel%10 ~= 0 then
		showCount = wingLevel%10
	else
		showCount = 10
	end

	for i = 1, 10, 1 do
		local star = an.newBtn(res.gettex2("pic/panels/wingUpgrade/starBg.png"), function ()
			sound.playSound("103")

			return 
		end, {
			select = {
				res.gettex2("pic/panels/wingUpgrade/star.png")
			}
		}).add2(slot11, leftNode):anchor(0.5, 0.5):pos(i*24 + 80, 140)

		star.setTouchEnabled(star, false)

		if i <= showCount then
			star.select(star)
		end
	end

	local curExp = g_data.player.wingInfo.FWingHaveExp
	local processBg = display.newScale9Sprite(res.getframe2("pic/panels/wingUpgrade/pg_bg.png"), 0, 0, cc.size(285, 25)):anchor(0.5, 0.5):add2(leftNode):pos(leftNode.getw(leftNode)/2, 109)
	local wingCfg = def.wing.getUpgradeCfg(wingLevel + 1)
	local processBar = display.newScale9Sprite(res.getframe2("pic/panels/wingUpgrade/pg.png"), 0, 0, cc.size(279, 17)):anchor(0, 0.5):add2(processBg):pos(3, processBg.geth(processBg)/2)

	if not wingCfg or wingCfg.UpNeedExp < curExp then
		processBar.setScaleX(processBar, 1)
	else
		processBar.setScaleX(processBar, curExp/wingCfg.UpNeedExp)
	end

	self.contentNode.controls.processBar = processBar
	local lblProcess = an.newLabel(string.format("%d/%d", curExp, (wingCfg and wingCfg.UpNeedExp) or 0), 18, 1, {
		color = cc.c3b(220, 210, 190)
	}):anchor(0.5, 0.5):pos(leftNode.getw(leftNode)/2, 109):add2(leftNode)

	an.newLabel("消耗：", 20, 1, {
		color = def.colors.title
	}):anchor(0.5, 0.5):pos(70, 70):add2(leftNode)

	local itemIdx = def.items.getItemIdByName(UPGRADE_MATERIAL)
	local itemData = def.items.getStdItemById(itemIdx)
	local m1 = item.new(itemData, self, {
		scroll = true,
		donotMove = true,
		idx = idx
	}):add2(leftNode, 2):pos(128, 73)

	m1.setScale(m1, 0.7)

	if m1.dura then
		m1.dura:removeSelf()

		m1.dura = nil
	end

	an.newLabel("*1", 20, 1, {
		color = def.colors.title
	}):anchor(0, 0.5):pos(30, m1.geth(m1)/2):add2(m1)

	local m2 = item.new(itemData, self, {
		scroll = true,
		donotMove = true,
		idx = idx
	}):add2(leftNode, 2):pos(290, 73)

	m2.setScale(m2, 0.7)

	if m2.dura then
		m2.dura:removeSelf()

		m2.dura = nil
	end

	an.newLabel("*10", 20, 1, {
		color = def.colors.title
	}):anchor(0, 0.5):pos(30, m2.geth(m2)/2):add2(m2)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")
		self:doUpgrade(1)

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		label = {
			"使用1个",
			16,
			0,
			{
				color = def.colors.Cf0c896
			}
		}
	}).add2(slot16, leftNode):anchor(0.5, 0.5):pos(150, 30)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")
		self:doUpgrade(10)

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		label = {
			"使用10个",
			16,
			0,
			{
				color = def.colors.Cf0c896
			}
		}
	}).add2(slot16, leftNode):anchor(0.5, 0.5):pos(300, 30)

	if wingCfg then
		display.newSprite(res.gettex2("pic/panels/wingUpgrade/" .. wingCfg.Img .. ".png")):anchor(0.5, 0.5):pos(leftNode.getw(leftNode)/2, 271):add2(leftNode)
	else
		local cfg = nil

		if wingLevel == 0 then
			cfg = def.wing.getUpgradeCfg(def.wing.getUpgradeMin())
		else
			cfg = def.wing.getUpgradeCfg(def.wing.getUpgradeMax())
		end

		display.newSprite(res.gettex2("pic/panels/wingUpgrade/" .. cfg.Img .. ".png")):anchor(0.5, 0.5):pos(leftNode.getw(leftNode)/2, 271):add2(leftNode)
	end

	local function addPropLine(name, value, line, startY)
		local lblProp = an.newLabel(name, 18, 1, {
			color = cc.c3b(240, 200, 150)
		}):anchor(0, 0.5):pos(5, startY - line*25):add2(rightNode)

		an.newLabel(value, 18, 1, {
			color = cc.c3b(220, 210, 190)
		}):anchor(0, 0.5):pos(lblProp.getPositionX(lblProp) + lblProp.getw(lblProp), lblProp.getPositionY(lblProp)):add2(rightNode)

		return 
	end

	local job = g_data.player.job
	local wingCfg = def.wing.getUpgradeCfg(UPGRADE_MATERIAL)

	if wingCfg then
		local props = def.property.dumpPropertyStr(wingCfg.PropertyStr):clearZero():toStdProp():grepJob(job)
		local idx = 0

		addPropLine("需要等级: ", common.getLevelText(wingCfg.UpNeedPlayerLevel) .. "级", 0, 346)
		addPropLine("服务器阶段:", common.getLevelText(wingCfg.UpNeedServerStep) .. "级", 1, 346)

		idx = 2

		for i, v in ipairs(props.props) do
			local p = props.getPropStrings(props, v[1])

			addPropLine(p[1] .. ": ", (p[3] ~= nil and p[2] .. "-" .. p[3]) or "+" .. p[2], idx, 346)

			idx = idx + 1
		end
	else
		an.newLabel("暂无属性", 20, 1, {
			color = cc.c3b(220, 210, 190)
		}):anchor(0.5, 0.5):pos(84, 296):add2(rightNode)
	end

	local wingCfg = def.wing.getUpgradeCfg(wingLevel + 1)

	if wingCfg then
		local props = def.property.dumpPropertyStr(wingCfg.PropertyStr):clearZero():toStdProp():grepJob(job)
		local idx = 0

		addPropLine("需要等级: ", common.getLevelText(wingCfg.UpNeedPlayerLevel) .. "级", 0, 130)
		addPropLine("服务器阶段:", common.getLevelText(wingCfg.UpNeedServerStep) .. "级", 1, 130)

		idx = 2

		for i, v in ipairs(props.props) do
			local p = props.getPropStrings(props, v[1])

			addPropLine(p[1] .. ": ", (p[3] ~= nil and p[2] .. "-" .. p[3]) or "+" .. p[2], idx, 130)

			idx = idx + 1
		end
	else
		an.newLabel("等级已最大", 20, 1, {
			color = cc.c3b(220, 210, 190)
		}):anchor(0.5, 0.5):pos(84, 86):add2(rightNode)
	end

	return 
end
wingUpgrade.loadActivePage = function (self)
	local leftNode = display.newScale9Sprite(res.getframe2("pic/common/black_5.png")):anchor(0, 0):pos(14, 14):size(157, 390):addTo(self.contentNode, 1)
	local rightNode = display.newScale9Sprite(res.getframe2("pic/common/black_5.png")):anchor(0, 0):pos(171, 14):size(457, 390):addTo(self.contentNode)

	display.newSprite(res.gettex2("pic/panels/wingUpgrade/node_bg.png")):anchor(0, 0):pos(3, 2):add2(rightNode)

	self.contentNode.controls.rightNode = rightNode

	display.newSprite(res.gettex2("pic/panels/wingUpgrade/role_wing_bg.png")):anchor(0.5, 0.5):pos(149, 184):add2(rightNode)
	display.newScale9Sprite(res.getframe2("pic/panels/wingUpgrade/propertyBg.png")):anchor(0, 0):pos(284, 3):size(164, 383):addTo(rightNode)
	display.newSprite(res.gettex2("pic/panels/wingUpgrade/flag.png")):anchor(0, 0.5):pos(295, 370):add2(rightNode)
	display.newSprite(res.gettex2("pic/panels/wingUpgrade/jhjc.png")):anchor(0, 0.5):pos(316, 370):add2(rightNode)

	local wingList = self.newListView(self, 0, 0, 168, 390, 4, {}):add2(leftNode)
	self.contentNode.controls.wingList = wingList

	an.newBtn(res.gettex2("pic/common/question.png"), function ()
		sound.playSound("103")
		an.newMsgbox(tipStr1, nil, {
			contentLabelSize = 20,
			title = "提示"
		})

		return 
	end, {
		pressBig = true,
		pressImage = res.gettex2("pic/common/question.png")
	}).pos(slot4, 25, 365):addto(rightNode)
	display.newSprite(res.gettex2("pic/panels/wingUpgrade/title_bg.png")):anchor(0.5, 0.5):pos(159, 366):add2(rightNode)

	local lblWingName = an.newLabel("", 20, 1, {
		color = def.colors.clBlue
	}):anchor(0.5, 0.5):pos(159, 366):add2(rightNode)
	self.contentNode.controls.lblWingName = lblWingName
	local wingImg = display.newSprite():anchor(0.5, 0.5):pos(149, 271):add2(rightNode)
	self.contentNode.controls.wingImg = wingImg
	local activeNode = display.newNode():add2(rightNode)
	self.contentNode.controls.activeNode = activeNode
	local default = 1

	for i, v in ipairs(def.wing.getAllActivateCfg()) do
		if not g_data.player:isWingActivate(i) and g_data.player:isWingCanActivate(i) then
			default = i

			break
		elseif g_data.player:isWingActivate(i) then
			default = i
		end
	end

	self.fillWingList(self, {
		default = default
	})

	return 
end
wingUpgrade.loadShowPage = function (self)
	local leftNode = display.newScale9Sprite(res.getframe2("pic/common/black_5.png")):anchor(0, 0):pos(14, 14):size(157, 390):addTo(self.contentNode, 1)
	local rightNode = display.newScale9Sprite(res.getframe2("pic/common/black_5.png")):anchor(0, 0):pos(171, 14):size(457, 390):addTo(self.contentNode)

	display.newSprite(res.gettex2("pic/panels/wingUpgrade/node_bg.png")):anchor(0, 0):pos(3, 2):add2(rightNode)

	self.contentNode.controls.rightNode = rightNode

	display.newSprite(res.gettex2("pic/panels/wingUpgrade/role_wing_bg.png")):anchor(0.5, 0.5):pos(149, 104):add2(rightNode)
	display.newScale9Sprite(res.getframe2("pic/panels/wingUpgrade/propertyBg.png")):anchor(0, 0):pos(284, 3):size(164, 383):addTo(rightNode)
	display.newSprite(res.gettex2("pic/panels/wingUpgrade/flag.png")):anchor(0, 0.5):pos(295, 370):add2(rightNode)
	display.newSprite(res.gettex2("pic/panels/wingUpgrade/szjc.png")):anchor(0, 0.5):pos(316, 370):add2(rightNode)

	local wingList = self.newListView(self, 0, 0, 168, 390, 4, {}):add2(leftNode)
	self.contentNode.controls.wingList = wingList

	an.newBtn(res.gettex2("pic/common/question.png"), function ()
		sound.playSound("103")
		an.newMsgbox(tipStr1, nil, {
			contentLabelSize = 20,
			title = "提示"
		})

		return 
	end, {
		pressBig = true,
		pressImage = res.gettex2("pic/common/question.png")
	}).pos(slot4, 25, 365):addto(rightNode)
	display.newSprite(res.gettex2("pic/panels/wingUpgrade/title_bg.png")):anchor(0.5, 0.5):pos(159, 366):add2(rightNode)

	local lblWingName = an.newLabel("", 20, 1, {
		color = def.colors.clBlue
	}):anchor(0.5, 0.5):pos(159, 366):add2(rightNode)
	self.contentNode.controls.lblWingName = lblWingName
	local wingImg = display.newSprite():anchor(0.5, 0.5):pos(149, 271):add2(rightNode)
	self.contentNode.controls.wingImg = wingImg
	local activeNode = display.newNode():add2(rightNode)
	self.contentNode.controls.activeNode = activeNode
	local default = (0 < g_data.player.wingInfo.FCurrWingShowId and g_data.player.wingInfo.FCurrWingShowId) or 1

	for i, v in ipairs(def.wing.getAllShowCfg()) do
		if not g_data.player:isWingHaveFeature(i) and g_data.player:isWingActivate(i) and g_data.player:isWingCanGetFeature(i) then
			default = i

			break
		end
	end

	self.fillWingList(self, {
		default = default
	})

	return 
end
wingUpgrade.fillWingList = function (self, params)
	local wingListView = self.contentNode.controls.wingList
	local wingBtns = {}
	local wings = {}

	if self.curTab == self.loadActivePage then
		wings = def.wing.getAllActivateCfg()
	else
		wings = def.wing.getAllShowCfg()
	end

	for i, wing in ipairs(wings) do
		local item = an.newBtn(res.gettex2("pic/panels/picIdentify/equipTypeUnselect.png"), function (btn)
			sound.playSound("103")
			self:onWingSelect(btn)

			return 
		end, {
			support = "scroll",
			select = {
				res.gettex2("pic/panels/picIdentify/equipTypeSelect.png")
			},
			label = {
				wing.Name,
				16,
				0,
				{
					color = def.colors.Cf0c896
				}
			}
		})
		wingBtns[i] = item
		item.wingInfo = wing
		item.wingInfo.idx = i

		self.listViewPushBack(slot0, wingListView, item)
	end

	self.contentNode.controls.wingBtns = wingBtns
	local default = 1

	if params and params.default and params.default <= #wingBtns then
		default = params.default
	end

	if 0 < #wingBtns then
		self.onWingSelect(self, wingBtns[default])
	end

	return 
end
wingUpgrade.onWingSelect = function (self, btn)
	local wingBtns = self.contentNode.controls.wingBtns
	local lastBtn = self.contentNode.controls.lastBtn

	if lastBtn then
		lastBtn.unselect(lastBtn)
		lastBtn.setTouchEnabled(lastBtn, true)
	end

	btn.select(btn)

	self.contentNode.controls.lastBtn = btn

	btn.setTouchEnabled(btn, false)

	if self.curTab == self.loadActivePage then
		self.onWingActiveSelect(self, btn)
	elseif self.curTab == self.loadShowPage then
		self.onWingShowSelect(self, btn)
	end

	return 
end
wingUpgrade.onWingActiveSelect = function (self, btn)
	local wingInfo = btn.wingInfo
	local rightNode = self.contentNode.controls.rightNode
	local lblWingName = self.contentNode.controls.lblWingName

	lblWingName.setColor(lblWingName, def.wing.getWingNameColor(wingInfo.idx))
	lblWingName.setString(lblWingName, wingInfo.Name)

	local wingImg = self.contentNode.controls.wingImg
	self.contentNode.controls.wingImg = display.newSprite(res.gettex2("pic/panels/wingUpgrade/" .. wingInfo.Img .. ".png")):anchor(0.5, 0.5):pos(149, 271):add2(wingImg.getParent(wingImg))

	wingImg.removeSelf(wingImg)

	local activeNode = self.contentNode.controls.activeNode

	activeNode.removeAllChildren(activeNode)

	if g_data.player:isWingActivate(wingInfo.idx) then
		display.newSprite(res.gettex2("pic/panels/wingUpgrade/prop_split.png")):pos(156, 84):add2(activeNode)
		display.newSprite(res.gettex2("pic/panels/wingUpgrade/prop_split.png")):pos(156, 53):add2(activeNode)
		an.newLabel("已激活", 20, 1, {
			color = cc.c3b(50, 177, 108)
		}):anchor(0.5, 0.5):addto(activeNode):pos(146, 70)
	elseif g_data.player.wingInfo.FWingLv < wingInfo.NeedWingLv then
		display.newSprite(res.gettex2("pic/panels/wingUpgrade/prop_split.png")):pos(156, 84):add2(activeNode)
		display.newSprite(res.gettex2("pic/panels/wingUpgrade/prop_split.png")):pos(156, 53):add2(activeNode)
		an.newLabel(string.format("需要羽翼达到%s", def.wing.level2str(wingInfo.NeedWingLv)), 20, 1, {
			color = cc.c3b(230, 105, 70)
		}):anchor(0.5, 0.5):addto(activeNode):pos(146, 70)
		an.newLabel("激活可永久获得\n      以上属性", 20, 1, {
			color = cc.c3b(230, 105, 70),
			size = cc.size(14, 80)
		}):anchor(0.5, 0.5):addto(activeNode):pos(367, 75)
	else
		an.newLabel("消耗：", 20, 1, {
			color = def.colors.title
		}):anchor(0.5, 0.5):pos(111, 86):add2(activeNode)

		local itemIdx = def.items.getItemIdByName(ACTIVE_MATERIAL)
		local itemData = def.items.getStdItemById(itemIdx)
		local m1 = item.new(itemData, self, {
			scroll = true,
			donotMove = true,
			idx = idx
		}):add2(activeNode):pos(159, 86)

		m1.setScale(m1, 0.7)

		if m1.dura then
			m1.dura:removeSelf()

			m1.dura = nil
		end

		an.newLabel("*" .. wingInfo.NeedWhiteFeatherNum, 20, 1, {
			color = def.colors.title
		}):anchor(0, 0.5):pos(30, m1.geth(m1)/2):add2(m1)

		local btn = an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
			sound.playSound("103")
			self:doActive(wingInfo.idx)

			return 
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			label = {
				"激  活",
				16,
				0,
				{
					color = def.colors.Cf0c896
				}
			}
		}).add2(slot10, activeNode):anchor(0.5, 0.5):pos(150, 40)

		if g_data.player:isWingCanActivate(wingInfo.idx) then
			self.setBtnPointTip(self, btn, true)
		end
	end

	if self.contentNode.controls.propNode then
		self.contentNode.controls.propNode:removeSelf()
	end

	local propNode = display.newNode():add2(rightNode)
	self.contentNode.controls.propNode = propNode

	local function addPropLine(name, value, line, startY)
		local lblProp = an.newLabel(name, 18, 1, {
			color = cc.c3b(240, 200, 150)
		}):anchor(0, 0.5):pos(296, startY - line*25):add2(propNode)

		an.newLabel(value, 18, 1, {
			color = cc.c3b(220, 210, 190)
		}):anchor(0, 0.5):pos(lblProp.getPositionX(lblProp) + lblProp.getw(lblProp), lblProp.getPositionY(lblProp)):add2(propNode)

		return 
	end

	local job = g_data.player.job
	local props = def.property.dumpPropertyStr(wingInfo.PropertyStr).clearZero(slot10):toStdProp():grepJob(job)
	local idx = 0
	local wingLevel = g_data.player.wingInfo.FWingLv

	for i, v in ipairs(props.props) do
		local p = props.getPropStrings(props, v[1])

		addPropLine(p[1] .. ": ", (p[3] ~= nil and p[2] .. "-" .. p[3]) or "+" .. p[2], idx, 346)

		idx = idx + 1
	end

	for i, v in ipairs(self.contentNode.controls.wingBtns) do
		if not g_data.player:isWingActivate(v.wingInfo.idx) then
			self.setWingListItemPointTip(self, v, g_data.player:isWingCanActivate(v.wingInfo.idx))
		else
			self.setWingListItemPointTip(self, v, false)
		end
	end

	return 
end
wingUpgrade.onWingShowSelect = function (self, btn)
	local wingInfo = btn.wingInfo
	local rightNode = self.contentNode.controls.rightNode
	local lblWingName = self.contentNode.controls.lblWingName

	lblWingName.setColor(lblWingName, def.wing.getWingNameColor(wingInfo.idx))
	lblWingName.setString(lblWingName, wingInfo.Name)

	local activeNode = self.contentNode.controls.activeNode

	activeNode.removeAllChildren(activeNode)

	if g_data.player:isWingActivate(wingInfo.idx) then
		if g_data.player.wingInfo.FCurrWingShowId == wingInfo.NeedActivateId then
			an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
				sound.playSound("103")
				self:doUnLoad()

				return 
			end, {
				pressImage = res.gettex2("pic/common/btn21.png"),
				label = {
					"卸  下",
					16,
					0,
					{
						color = def.colors.Cf0c896
					}
				}
			}).pos(slot6, 149, 70):addto(activeNode)
		elseif g_data.player:isWingHaveFeature(wingInfo.idx) then
			an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
				sound.playSound("103")
				self:doShow(wingInfo.NeedActivateId)

				return 
			end, {
				pressImage = res.gettex2("pic/common/btn21.png"),
				label = {
					"展  示",
					16,
					0,
					{
						color = def.colors.Cf0c896
					}
				}
			}).pos(slot6, 149, 70):addto(activeNode)
		else
			an.newLabel("消耗：", 20, 1, {
				color = def.colors.title
			}):anchor(0.5, 0.5):pos(113, 83):add2(activeNode)

			local itemIdx = def.items.getItemIdByName(SHOW_MATERIAL)
			local itemData = def.items.getStdItemById(itemIdx)
			local m1 = item.new(itemData, self, {
				scroll = true,
				donotMove = true,
				idx = idx
			}):add2(activeNode):pos(158, 83)

			m1.setScale(m1, 0.7)

			if m1.dura then
				m1.dura:removeSelf()

				m1.dura = nil
			end

			an.newLabel("*" .. wingInfo.NeedGoldenFeatherNum, 20, 1, {
				color = def.colors.title
			}):anchor(0, 0.5):pos(30, m1.geth(m1)/2):add2(m1)

			local btn = an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
				sound.playSound("103")
				an.newMsgbox(string.format("是否确认消耗%d数量的金色羽毛，获得并展示%s的时装外显？", wingInfo.NeedGoldenFeatherNum, wingInfo.Name), function (isOk)
					if isOk == 1 then
						self:doGetShow(wingInfo.NeedActivateId)
					end

					return 
				end, {
					fontSize = 20,
					title = "提示",
					center = true,
					hasCancel = true
				})

				return 
			end, {
				pressImage = res.gettex2("pic/common/btn21.png"),
				label = {
					"展  示",
					16,
					0,
					{
						color = def.colors.Cf0c896
					}
				}
			}).pos(slot9, 149, 42):addto(activeNode)

			if g_data.player:isWingCanGetFeature(wingInfo.idx) then
				self.setBtnPointTip(self, btn, true)
			end
		end
	else
		display.newSprite(res.gettex2("pic/panels/wingUpgrade/prop_split.png")):pos(156, 84):add2(activeNode)
		display.newSprite(res.gettex2("pic/panels/wingUpgrade/prop_split.png")):pos(156, 53):add2(activeNode)
		an.newLabel(string.format("需要激活%s", wingInfo.Name), 20, 1, {
			color = cc.c3b(230, 105, 70)
		}):anchor(0.5, 0.5):addto(activeNode):pos(146, 70)
		an.newLabel("激活可永久获得\n      以上属性", 20, 1, {
			color = cc.c3b(230, 105, 70),
			size = cc.size(14, 80)
		}):anchor(0.5, 0.5):addto(activeNode):pos(367, 75)
	end

	if self.contentNode.controls.propNode then
		self.contentNode.controls.propNode:removeSelf()
	end

	local propNode = display.newNode():add2(rightNode)
	self.contentNode.controls.propNode = propNode

	local function addPropLine(name, value, line, startY)
		local lblProp = an.newLabel(name, 18, 1, {
			color = cc.c3b(240, 200, 150)
		}):anchor(0, 0.5):pos(296, startY - line*25):add2(propNode)

		an.newLabel(value, 18, 1, {
			color = cc.c3b(220, 210, 190)
		}):anchor(0, 0.5):pos(lblProp.getPositionX(lblProp) + lblProp.getw(lblProp), lblProp.getPositionY(lblProp)):add2(propNode)

		return 
	end

	local job = g_data.player.job
	local props = def.property.dumpPropertyStr(wingInfo.PropertyStr).clearZero(slot9):toStdProp():grepJob(job)
	local idx = 0
	local wingLevel = g_data.player.wingInfo.FWingLv

	if wingLevel < wingInfo.NeedWingLv then
		addPropLine("需要羽翼: ", def.wing.level2str(wingInfo.NeedWingLv), 0, 346)

		idx = 1
	end

	for i, v in ipairs(props.props) do
		local p = props.getPropStrings(props, v[1])

		addPropLine(p[1] .. ": ", (p[3] ~= nil and p[2] .. "-" .. p[3]) or "+" .. p[2], idx, 346)

		idx = idx + 1
	end

	self.drawRole(self, wingInfo)

	for i, v in ipairs(self.contentNode.controls.wingBtns) do
		if not g_data.player:isWingHaveFeature(v.wingInfo.idx) then
			self.setWingListItemPointTip(self, v, g_data.player:isWingActivate(v.wingInfo.idx) and g_data.player:isWingCanGetFeature(v.wingInfo.idx))
		else
			self.setWingListItemPointTip(self, v, false)
		end
	end

	return 
end
wingUpgrade.doUpgrade = function (self, count)
	local total = g_data.bag:getItemCount(UPGRADE_MATERIAL)
	local totalBind = g_data.bag:getItemCount("绑定" .. UPGRADE_MATERIAL)

	if total + totalBind < count then
		main_scene.ui:tip("升级失败，材料不足")

		return 
	end

	local level = g_data.player.ability.FLevel
	local wingLv = g_data.player.wingInfo.FWingLv
	local wingCfg = def.wing.getUpgradeCfg(wingLv + 1)

	if wingCfg then
		if level < wingCfg.UpNeedPlayerLevel then
			main_scene.ui:tip("升级失败，当前角色等级未达到要求")

			return 
		end
	else
		main_scene.ui:tip("已达到满级")

		return 
	end

	if g_data.login.serverLevel < wingCfg.UpNeedServerStep then
		main_scene.ui:tip("升级失败，当前服务器阶段未达到要求")

		return 
	end

	local rsb = DefaultClientMessage(CM_UpWing)
	rsb.FFeatherNum = count

	MirTcpClient:getInstance():postRsb(rsb)
	main_scene.ui.waiting:show(10, "WING_UPGRADE")

	return 
end
wingUpgrade.doActive = function (self, fid)
	local rsb = DefaultClientMessage(CM_ActivateWing)
	rsb.FId = fid

	MirTcpClient:getInstance():postRsb(rsb)
	main_scene.ui.waiting:show(10, "WING_ACTIVE")

	return 
end
wingUpgrade.doGetShow = function (self, fid)
	local rsb = DefaultClientMessage(CM_GetWingShow)
	rsb.FId = fid

	MirTcpClient:getInstance():postRsb(rsb)
	main_scene.ui.waiting:show(10, "WING_SHOW")

	return 
end
wingUpgrade.doShow = function (self, fid)
	local rsb = DefaultClientMessage(CM_ShowWing)
	rsb.FId = fid

	MirTcpClient:getInstance():postRsb(rsb)
	main_scene.ui.waiting:show(10, "WING_SHOW")

	return 
end
wingUpgrade.doUnLoad = function (self)
	local rsb = DefaultClientMessage(CM_UnloadWing)

	MirTcpClient:getInstance():postRsb(rsb)
	main_scene.ui.waiting:show(10, "WING_SHOW")

	return 
end
wingUpgrade.drawRole = function (self, wingInfo)
	local wingInfo = def.wing.getActiveCfg(wingInfo.idx)

	if not wingInfo then
		return 
	end

	if self.contentNode.controls.roleNode then
		self.contentNode.controls.roleNode:removeSelf()
	end

	local roleNode = display.newNode():pos(190, 50):add2(self.contentNode)
	self.contentNode.controls.roleNode = roleNode
	self._scale = 1.1
	local job_name = {
		[0] = "战士",
		"法师",
		"道士"
	}
	local job = g_data.player.job
	local level = common.getLevelText(g_data.player.ability.FLevel)
	local strJobLevel = job_name[job] .. "\n" .. level .. "级"
	local sex = (g_data.player.sex == 0 and 60) or 80
	local equipData = g_data.equip
	local baseData = g_data.player
	local disY = 0
	local roleBgName = string.format("pic/panels/wingUpgrade/%s_%d.png", wingInfo.Img, (g_data.player.sex == 0 and 1) or 0)

	display.newSprite(res.gettex2(roleBgName)):add2(roleNode):pos(143, 204)

	local hair = nil

	if main_scene.ground.player then
		hair = main_scene.ground.player.hair
	end

	if hair and 0 < hair then
		hair = hair + 438

		res.getui(1, hair):addto(roleNode, 10):anchor(0.5, 1):pos(136, 253)
	end

	local items = {}

	for k, v in pairs(equipData.items) do
		if k == U_WEAPON or k == U_MASK then
			local tmpDisY = 0

			if k == 2 or k == 3 or (5 <= k and k <= 8) then
				tmpDisY = disY
			end

			local x, y, z, isSetOffset, attach = self.idx2pos(self, k)
			items[k] = item.new(v, self, {
				img = "stateitem",
				isSetOffset = isSetOffset,
				idx = k
			}):addto(roleNode, z):pos(x, y + tmpDisY)

			if attach then
				items[k .. "_attach"] = item.new(v, self, {
					idx = k
				}):addto(roleNode, attach[3]):pos(attach[1], attach[2])
			end

			if k == 0 then
				self.updateStateEffect(self, v.FIndex)
			end
		end
	end

	return 
end
wingUpgrade.initPosTable = function (self)
	self.itemPosTable = self.itemPosTable or {
		[0] = {
			44,
			240,
			0,
			true,
			130,
			90,
			100,
			160
		},
		{
			26,
			250,
			1,
			true,
			80,
			90,
			45,
			200
		},
		{
			226,
			218,
			2
		},
		{
			226,
			280,
			2
		},
		{
			44,
			242,
			2,
			true,
			160,
			300,
			80,
			60
		},
		{
			50,
			162,
			2
		},
		{
			226,
			162,
			2
		},
		{
			50,
			104,
			2
		},
		{
			226,
			104,
			2
		},
		{
			50,
			44,
			2
		},
		{
			107,
			44,
			2
		},
		{
			165,
			44,
			2
		},
		{
			226,
			44,
			2
		},
		{
			9,
			158,
			2,
			true,
			74,
			140,
			60,
			40,
			attach = {
				-26,
				138,
				2
			}
		}
	}

	return 
end
wingUpgrade.idx2pos = function (self, idx)
	self.initPosTable(self)

	local pos = self.itemPosTable[tonumber(idx)] or {
		0,
		0,
		0,
		0
	}

	return pos[1], pos[2], pos[3], pos[4], pos.attach
end
wingUpgrade.updateStateEffect = function (self, itemIndex)
	local function getClothEffect(idx)
		for k, v in pairs(stateEffectConfig) do
			if k == idx then
				return v
			end
		end

		return 
	end

	if self.effectAnim then
		self.effectAnim.removeSelf(slot3)

		self.effectAnim = nil
	end

	local clothEffect = getClothEffect(itemIndex)

	if clothEffect then
		local xPos = self.bg:getw()/2 - 42 + clothEffect.offsetX
		local yPos = self.bg:geth()/2 - 52 + clothEffect.offsetY
		self.effectAnim = m2spr.playAnimation(clothEffect.atlasName, clothEffect.frameBegin, clothEffect.frames, 0.1, true):add2(self.content, 2):pos(xPos, yPos)
	end

	return 
end
wingUpgrade.onSM_UpWing = function (self, result)
	main_scene.ui.waiting:close("WING_UPGRADE")

	if not result then
		return 
	end

	if result.FBackValue == 0 then
		g_data.player:updateWingInfo({
			FWingLv = result.FWingLv,
			FWingHaveExp = result.FWingHaveExp
		})
		g_data.eventDispatcher:dispatch("WING_UPGRADE_SUCCESS")
	else
		return 
	end

	if self.curTab == self.loadUpgradePage then
		self.clearContentNode(self)
		self.loadUpgradePage(self)
	end

	return 
end
wingUpgrade.onSM_ActivateWing = function (self, result)
	main_scene.ui.waiting:close("WING_ACTIVE")

	if not result then
		return 
	end

	if result.FBackValue == 0 then
		table.insert(g_data.player.wingInfo.FActivateWingList, {
			FId = result.FId
		})
		g_data.player:updateWingInfo({
			FActivateWingList = g_data.player.wingInfo.FActivateWingList
		})
		g_data.eventDispatcher:dispatch("WING_UPGRADE_ACTIVE")
	end

	if self.curTab == self.loadActivePage then
		local lastBtn = self.contentNode.controls.lastBtn

		self.onWingActiveSelect(self, lastBtn)
	end

	return 
end
wingUpgrade.onSM_GetWingShow = function (self, result)
	main_scene.ui.waiting:close("WING_SHOW")

	if not result then
		return 
	end

	if result.FBackValue == 0 then
		table.insert(g_data.player.wingInfo.FShowWingList, {
			FId = result.FId
		})
		g_data.player:updateWingInfo({
			FActivateWingList = g_data.player.wingInfo.FActivateWingList,
			FCurrWingShowId = result.FId
		})
		self.changePlayerFeature(self, result.FFeature)
		g_data.eventDispatcher:dispatch("WING_UPGRADE_TAKEON")
	end

	if self.curTab == self.loadShowPage then
		local lastBtn = self.contentNode.controls.lastBtn

		self.onWingShowSelect(self, lastBtn)
	end

	return 
end
wingUpgrade.onSM_ShowWing = function (self, result)
	main_scene.ui.waiting:close("WING_SHOW")

	if not result then
		return 
	end

	if result.FBackValue == 0 then
		g_data.player.wingInfo.FCurrWingShowId = result.FId

		self.changePlayerFeature(self, result.FFeature)
		g_data.eventDispatcher:dispatch("WING_UPGRADE_TAKEON")
	end

	if self.curTab == self.loadShowPage then
		local lastBtn = self.contentNode.controls.lastBtn

		self.onWingShowSelect(self, lastBtn)
	end

	return 
end
wingUpgrade.onSM_UnloadWing = function (self, result)
	main_scene.ui.waiting:close("WING_SHOW")

	if not result then
		return 
	end

	if result.FBackValue == 0 then
		g_data.player.wingInfo.FCurrWingShowId = 0

		self.changePlayerFeature(self, result.FFeature)
		g_data.eventDispatcher:dispatch("WING_UPGRADE_TAKEOFF")
	end

	if self.curTab == self.loadShowPage then
		local lastBtn = self.contentNode.controls.lastBtn

		self.onWingShowSelect(self, lastBtn)
	end

	return 
end
wingUpgrade.changePlayerFeature = function (self, feature)
	feature = common.convertFeature(feature)

	main_scene.ground.map.player:changeFeature(feature)

	return 
end
wingUpgrade.onM_POINTTIP = function (self, type, visible)
	if type ~= "wing_activate" and type ~= "wing_show" then
		return 
	end

	self.updateTabPointTip(self)

	return 
end
wingUpgrade.updateTabPointTip = function (self)
	local keys = {
		[2.0] = "wing_activate",
		[3.0] = "wing_show"
	}

	for i, v in ipairs(self.tabs.btns) do
		local key = keys[i]

		if key then
			local btn = v
			local visible = g_data.pointTip:isVisible(key)
			local tip = btn.getChildByName(btn, "tip")

			if not visible and tip then
				tip.removeFromParent(tip)
			end

			if not tip and visible then
				tip = pointTip.attach(btn, {
					dir = "left",
					type = 1
				})

				tip.setName(tip, "tip")
			end
		end
	end

	return 
end
wingUpgrade.setWingListItemPointTip = function (self, btn, visible)
	local tip = btn.getChildByName(btn, "tip")

	if not visible then
		if tip then
			tip.removeFromParent(tip)
		end

		return 
	end

	if not tip then
		tip = pointTip.attach(btn, {
			dir = "right",
			type = 1
		})

		tip.setName(tip, "tip")
	end

	return 
end
wingUpgrade.setBtnPointTip = function (self, btn, visible)
	local tip = btn.getChildByName(btn, "tip")

	if not visible then
		if tip then
			tip.removeFromParent(tip)
		end

		return 
	end

	if not tip then
		tip = pointTip.attach(btn, {
			dir = "right",
			type = 1
		})

		tip.setName(tip, "tip")
	end

	return 
end
wingUpgrade.loadWingEquipPage = function (self)
	self.contentNode.controls.leftPanel = display.newSprite(res.gettex2("pic/panels/wingUpgrade/wingEquip/wingEquipBg2.png")):add2(self.contentNode):anchor(0, 0):pos(12, 13)
	self.contentNode.controls.propPanel = display.newScale9Sprite(res.getframe2("pic/scale/scale26.png")):anchor(0, 0):pos(443, 13):size(184, 391):addTo(self.contentNode)
	local texts = {
		{
			"1、开服150天，服务器达到四阶段，开启羽装。\n"
		},
		{
			"2、羽装共三件，依次为毛羽、飞羽、翎羽。\n"
		},
		{
			"3、羽装需要解锁，解锁后即可获得该羽装。\n"
		},
		{
			"4、羽装可升级，升级消耗“羽灵”，升级后羽装属性随之提升。\n"
		},
		{
			"5、羽灵可在庄园羽翼仙子处兑换和购买，获得的羽灵将累计在角色属性中。\n"
		},
		{
			"6、角色死亡时，有几率损失该羽装的升级进度，可能会导致该羽装降级。\n"
		},
		{
			"7、羽装损失的升级进度，将会以羽灵兑换道具的形式爆出。"
		}
	}

	an.newBtn(res.gettex2("pic/common/question.png"), function ()
		sound.playSound("103")
		an.newMsgbox(texts, nil, {
			contentLabelSize = 20,
			title = "提示"
		})

		return 
	end, {
		pressBig = true,
		pressImage = res.gettex2("pic/common/question.png")
	}).pos(slot2, 37, 378):addto(self.contentNode)
	an.newBtn(res.gettex2("pic/common/button_search.png"), function (btn)
		sound.playSound("103")
		main_scene.ui:togglePanel("wingEquipDetail", self.contentNode.data.curWingEquipType)

		return 
	end, {
		select = {
			res.gettex2("pic/common/button_search.png")
		}
	}).add2(slot2, self.contentNode):anchor(0.5, 0.5):pos(369, 142)

	local preViewLabel = an.newLabel("查看", 20, 0, {
		color = cc.c3b(240, 200, 150)
	}):anchor(0.5, 0.5):addTo(self.contentNode):pos(409, 145)

	preViewLabel.addUnderline(preViewLabel)
	preViewLabel.setTouchEnabled(preViewLabel, true)
	preViewLabel.setTouchSwallowEnabled(preViewLabel, true)
	preViewLabel.addNodeEventListener(preViewLabel, cc.NODE_TOUCH_EVENT, function (event)
		local touchInBtn = preViewLabel:getCascadeBoundingBox():containsPoint(cc.p(event.x, event.y))

		if event.name == "began" then
			preViewLabel:scale(1.1, 1.1)

			return true
		elseif event.name == "ended" then
			preViewLabel:scale(1, 1)
			sound.playSound("103")
			main_scene.ui:togglePanel("wingEquipDetail", self.contentNode.data.curWingEquipType)
		end

		return 
	end)

	self.contentNode.data.curWingEquipType = "毛羽"

	self.updateWingEquip(slot0)
	self.updatePropPanel(self)

	return 
end
wingUpgrade.updateWingEquip = function (self)
	local leftPanel = self.contentNode.controls.leftPanel

	if leftPanel then
		leftPanel.removeAllChildren(leftPanel)
	end

	display.newSprite(res.gettex2("pic/panels/wingUpgrade/title_bg.png")):anchor(0.5, 0.5):pos(leftPanel.getw(leftPanel)/2 + 5, 366):add2(leftPanel)

	local titleLabel = an.newLabel(self.contentNode.data.curWingEquipType or "", 20, 1, {
		color = def.colors.labelTitle
	}):anchor(0.5, 0.5):pos(leftPanel.getw(leftPanel)/2, 366):addTo(leftPanel)
	local wingEquipPos = {
		{
			name = "毛羽",
			key = "maoyu",
			y = 310,
			sp = "pic/panels/wingUpgrade/wingEquip/maoyu.png",
			x = 214.5
		},
		{
			name = "飞羽",
			key = "feiyu",
			y = 210,
			sp = "pic/panels/wingUpgrade/wingEquip/feiyu.png",
			x = 314.5
		},
		{
			name = "翎羽",
			key = "lingyu",
			y = 210,
			sp = "pic/panels/wingUpgrade/wingEquip/lingyu.png",
			x = 114.5
		}
	}

	for k, v in ipairs(wingEquipPos) do
		local bOpen, data = def.wingEquip.getWingEquipState(g_data.player.wingEquipInfoList, v.name)
		local level = (data and data.FLevel) or 0
		local itembg = an.newBtn(res.gettex2("pic/panels/horseSoul/hole.png"), function ()
			sound.playSound("103")

			self.contentNode.data.curWingEquipType = v.name

			self:updateWingEquip()
			self:updatePropPanel()

			return 
		end, {
			pressImage = res.gettex2("pic/panels/horseSoul/hole.png")
		}).add2(slot12, leftPanel):pos(v.x, v.y)

		if self.contentNode.data.curWingEquipType == v.name then
			slot13 = display.newSprite(res.gettex2("pic/panels/horseSoul/selBorder.png")):pos(itembg.getw(itembg)/2, itembg.geth(itembg)/2 + 1):addTo(itembg)
		end

		if not bOpen then
			display.newSprite(res.gettex2("pic/common/lock.png")):pos(itembg.getw(itembg)/2, itembg.geth(itembg)/2):addTo(itembg)
			an.newLabel(v.name, 18, 0, {
				color = cc.c3b(230, 105, 70)
			}):anchor(0.5, 0.5):pos(v.x, v.y - 45):addTo(leftPanel)

			if g_data.pointTip:isVisible(v.key .. "_upgrade") then
				self.setTabPointTip(self, itembg, {
					dir = "right",
					custom = true,
					type = 0,
					pos = cc.p(63, 63)
				}, true)
			end
		else
			display.newSprite(res.gettex2(v.sp)):pos(itembg.getw(itembg)/2, itembg.geth(itembg)/2):addTo(itembg)
			an.newLabel(v.name .. "：" .. level .. "级", 18, 0, {
				color = cc.c3b(220, 210, 190)
			}):anchor(0.5, 0.5):pos(v.x, v.y - 45):addTo(leftPanel)
		end
	end

	local bOpen, data = def.wingEquip.getWingEquipState(g_data.player.wingEquipInfoList, self.contentNode.data.curWingEquipType)
	local level = (data and data.FLevel) or 0
	local selName = (bOpen and string.format("%d级", level)) or ""

	an.newLabel(selName, 18, 0, {
		color = cc.c3b(220, 210, 190)
	}):anchor(0.5, 0.5):pos(214.5, 135):addTo(leftPanel)

	local nextWingEquipCfg = def.wingEquip.getWingEquip(self.contentNode.data.curWingEquipType, level + 1)
	local progress = an.newProgress(res.gettex2("pic/common/slider2.png"), res.gettex2("pic/common/sliderBg2.png"), {
		x = 3,
		y = 5
	}):anchor(0.5, 0.5):pos(214.5, 110):add2(leftPanel)
	local progressLabel = an.newLabel("0/0", 18, 1, {
		color = cc.c3b(220, 210, 190)
	}):anchor(0.5, 0.5):addTo(progress, 2):pos(progress.getw(progress)/2, progress.geth(progress)/2 + 2)

	progress.setp(progress, 0)

	if nextWingEquipCfg and bOpen then
		local curSpirit = data.FCurrWingSpirit or 0

		progressLabel.setText(progressLabel, curSpirit .. "/" .. nextWingEquipCfg.UpNeedWingSpirit)

		local p = curSpirit/nextWingEquipCfg.UpNeedWingSpirit

		if 1 < p then
			p = 1
		end

		if p < 0 then
			p = 0
		end

		progress.setp(progress, p)
	elseif bOpen then
		progressLabel.setText(progressLabel, "0/0")
		progress.setp(progress, 1)
	end

	if bOpen and nextWingEquipCfg then
		an.newLabel("消耗：羽灵*" .. nextWingEquipCfg.UpNeedWingSpirit .. "    金币*" .. math.floor(nextWingEquipCfg.UpNeedGoldNum/10000) .. "万", 18, 0, {
			color = cc.c3b(220, 210, 190)
		}):anchor(0.5, 0.5):pos(214.5, 85):addTo(leftPanel)
	end

	if nextWingEquipCfg then
		an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
			sound.playSound("103")

			local curWingEquipType = self.contentNode.data.curWingEquipType
			local rsb = DefaultClientMessage(CM_UpWingEquip)
			rsb.FWEID = def.wingEquip.getWingEquipID(curWingEquipType)

			MirTcpClient:getInstance():postRsb(rsb)
			main_scene.ui.waiting:show(10, "CM_UpWingEquip")

			return 
		end, {
			clickSpace = 0.5,
			pressImage = res.gettex2("pic/common/btn21.png"),
			label = {
				(bOpen and "升 级") or "解 锁",
				18,
				0,
				{
					color = def.colors.Cf0c896
				}
			}
		}).add2(slot11, leftPanel):pos(214.5, 45)
	else
		an.newLabel("已满级", 18, 0, {
			color = cc.c3b(220, 210, 190)
		}):anchor(0.5, 0.5):pos(214.5, 55):addTo(leftPanel)
	end

	return 
end
wingUpgrade.updatePropPanel = function (self)
	local propPanel = self.contentNode.controls.propPanel

	if propPanel then
		propPanel.removeAllChildren(propPanel)
	end

	local rect = cc.rect(0, 0, 186, 387)
	local scroll = an.newScroll(0, 2, rect.width, rect.height):addto(propPanel)
	local type = self.contentNode.data.curWingEquipType
	local bOpen, data = def.wingEquip.getWingEquipState(g_data.player.wingEquipInfoList, type)
	local level = (data and data.FLevel) or 0
	local job = g_data.player.job
	local curWeData = def.wingEquip.getWingEquip(type, level)
	local nextWeData = def.wingEquip.getWingEquip(type, level + 1)
	local curWeProps = def.wingEquip.getWingEquipProps(type, level, job)
	local nextWeProps = def.wingEquip.getWingEquipProps(type, level + 1, job)
	local posY = scroll.getContentSize(scroll).height

	display.newSprite(res.gettex2("pic/panels/wingUpgrade/flag.png")):add2(scroll):anchor(0, 1):pos(5, posY - 8)
	display.newSprite(res.gettex2("pic/panels/wingUpgrade/dqsx.png")):add2(scroll):anchor(0, 1):pos(22, posY - 5)

	posY = posY - 25

	if #curWeProps == 0 then
		posY = posY - 55

		an.newLabel("暂无属性", 18, 0, {
			color = cc.c3b(220, 210, 190)
		}):addto(scroll):pos(83, posY):anchor(0.5, 1)
	else
		for k, v in ipairs(curWeProps) do
			local strs = string.split(v, ":")

			if #strs == 2 then
				local propNameLabel = an.newLabel(strs[1] .. "：", 18, 0, {
					color = cc.c3b(240, 200, 150)
				}):addto(scroll):pos(10, posY):anchor(0, 1)

				an.newLabel(strs[2], 18, 0, {
					color = cc.c3b(220, 210, 190)
				}):addto(scroll):pos(propNameLabel.getw(propNameLabel) + 10, posY):anchor(0, 1)

				posY = posY - 25
			end
		end
	end

	posY = scroll.getContentSize(scroll).height - math.max(180, #curWeProps*25 + 25)

	display.newSprite(res.gettex2("pic/panels/equipforge/irtJT.png")):anchor(0.5, 1):pos(110, posY):add2(scroll):setRotation(90)

	posY = posY - 35

	display.newSprite(res.gettex2("pic/panels/wingUpgrade/flag.png")):add2(scroll):anchor(0, 1):pos(5, posY - 8)
	display.newSprite(res.gettex2("pic/panels/wingUpgrade/xjsx.png")):add2(scroll):anchor(0, 1):pos(22, posY - 5)

	posY = posY - 25

	if nextWeData then
		if 0 < nextWeData.UpNeedPlayerLevel and nextWeData.UpNeedPlayerLevel ~= curWeData.UpNeedPlayerLevel then
			local propNameLabel = an.newLabel("需要等级：", 18, 0, {
				color = cc.c3b(240, 200, 150)
			}):addto(scroll):pos(10, posY):anchor(0, 1)

			an.newLabel(common.getLevelText(nextWeData.UpNeedPlayerLevel) .. "级", 18, 0, {
				color = cc.c3b(220, 210, 190)
			}):addto(scroll):pos(propNameLabel.getw(propNameLabel) + 10, posY):anchor(0, 1)

			posY = posY - 25
		end

		if 0 < nextWeData.UpNeedServerStep and (nextWeData.UpNeedServerStep ~= curWeData.UpNeedServerStep or nextWeData.WELevel == 1) then
			local propNameLabel = an.newLabel("服务器阶段：", 18, 0, {
				color = cc.c3b(240, 200, 150)
			}):addto(scroll):pos(10, posY):anchor(0, 1)

			an.newLabel(nextWeData.UpNeedServerStep .. "阶段", 18, 0, {
				color = cc.c3b(220, 210, 190)
			}):addto(scroll):pos(propNameLabel.getw(propNameLabel) + 10, posY):anchor(0, 1)

			posY = posY - 25
		end

		if 0 < nextWeData.UpNeedOpenDays and (nextWeData.UpNeedOpenDays ~= curWeData.UpNeedOpenDays or nextWeData.WELevel == 1) then
			local propNameLabel = an.newLabel("开服天数：", 18, 0, {
				color = cc.c3b(240, 200, 150)
			}):addto(scroll):pos(10, posY):anchor(0, 1)

			an.newLabel(nextWeData.UpNeedOpenDays .. "天", 18, 0, {
				color = cc.c3b(220, 210, 190)
			}):addto(scroll):pos(propNameLabel.getw(propNameLabel) + 10, posY):anchor(0, 1)

			posY = posY - 25
		end
	end

	if #nextWeProps == 0 then
		posY = posY - 55

		an.newLabel("已满级", 18, 0, {
			color = cc.c3b(220, 210, 190)
		}):addto(scroll):pos(83, posY):anchor(0.5, 1)
	else
		for k, v in ipairs(nextWeProps) do
			local strs = string.split(v, ":")

			if #strs == 2 then
				local propNameLabel = an.newLabel(strs[1] .. "：", 18, 0, {
					color = cc.c3b(240, 200, 150)
				}):addto(scroll):pos(10, posY):anchor(0, 1)

				an.newLabel(strs[2], 18, 0, {
					color = cc.c3b(220, 210, 190)
				}):addto(scroll):pos(propNameLabel.getw(propNameLabel) + 10, posY):anchor(0, 1)

				posY = posY - 25
			end
		end
	end

	return 
end
wingUpgrade.setTabPointTip = function (self, btn, param, visible)
	local tip = btn.getChildByName(btn, "tip")

	if not tip then
		tip = pointTip.attach(btn, param)

		tip.setName(tip, "tip")
	end

	tip.visible(tip, visible == true)

	return 
end
wingUpgrade.onSM_UpWingEquip = function (self, result)
	main_scene.ui.waiting:close("CM_UpWingEquip")

	if not result then
		return 
	end

	if self.curTab == self.loadWingEquipPage and result.FBackValue == 0 then
		local name2Str = {
			翎羽 = "lingyu",
			飞羽 = "feiyu",
			毛羽 = "maoyu"
		}
		local wingEquipName = def.wingEquip.getWingEquipTypeName(result.FWEID)

		if name2Str[wingEquipName] then
			g_data.firstOpen:set(name2Str[wingEquipName], true)
			g_data.pointTip:set(name2Str[wingEquipName] .. "_upgrade", false)
		end
	end

	return 
end
wingUpgrade.onM_WINGEQUIP_CHG = function (self)
	if self.curTab == self.loadWingEquipPage then
		self.updateWingEquip(self)
		self.updatePropPanel(self)
	end

	return 
end

return wingUpgrade
