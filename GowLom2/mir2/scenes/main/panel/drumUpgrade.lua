local drumUpgrade = class("drumUpgrade", function ()
	return display.newNode()
end)
local drumInfo = import(".drumInfo")
local drumCfg = def.drumCfg
local drumStrengthenCfg = def.drumStrengthenCfg

table.merge(slot0, {
	pageBtns = {},
	currentPropertyValue = {},
	nextLevelPropertyValue = {},
	drumSprites = {},
	labelsCurProperty = {},
	labelsNextPropertyName = {},
	labelsNextPropertyValue = {},
	labelStrePropName = {},
	labelStrePropValue = {},
	nextStrengthenPropertyName = {},
	nextStrengthenPropertyValue = {},
	curStrengthenPropertyName = {},
	curStrengthenPropertyValue = {},
	tableDiamondList = {}
})

local maxDrumLevel = #drumCfg
local maxDrumStrengthenLevel = #drumStrengthenCfg
drumUpgrade.ctor = function (self, params)
	self.pageBtns = {}
	self.drumSprites = {}
	self.labelsCurProperty = {}
	self.labelsNextPropertyName = {}
	self.labelsNextPropertyValue = {}
	self.labelStrePropName = {}
	self.labelStrePropValue = {}
	self.nextStrengthenPropertyName = {}
	self.nextStrengthenPropertyValue = {}
	self.curStrengthenPropertyName = {}
	self.curStrengthenPropertyValue = {}
	self.bg = nil
	self.strengthenBtn = nil
	self.diamondLabel = nil
	self.reqDrumLevelLabel = nil
	self.title = nil
	self.nodePageContent = nil
	self.currentPropertyValue = {}
	self.nextLevelPropertyValue = {}
	self.tableDiamondList = {}

	self.setTouchSwallowEnabled(self, true)

	self.job = g_data.player.job
	self._supportMove = true
	self.bg = display.newSprite(res.gettex2("pic/panels/drumUpgrade/bg.png")):anchor(0, 0):addTo(self)

	self.size(self, self.bg:getw(), self.bg:geth()):anchor(0.5, 0.5):center()

	local innerBg = display.newScale9Sprite(res.getframe2("pic/panels/drumUpgrade/bgInnerScale9.png"), 0, 0, cc.size(346, 395)):pos(self.bg:getw()/2, self.bg:geth()/2 - 17):addTo(self.bg)
	local propertyBg = display.newScale9Sprite(res.getframe2("pic/panels/drumUpgrade/bgProperty.png"), 0, 0, cc.size(328, 135)):pos(174, 206):addTo(innerBg)
	self.title = an.newLabel("军鼓升级", 20, 0, {
		color = def.colors.labelTitle
	}):anchor(0.5, 0.5):pos(self.bg:getw()/2, self.bg:geth() - 27):addTo(self.bg)

	res.get2("pic/panels/drumUpgrade/line.png"):addTo(innerBg):pos(174, 62):setScaleX(0.7)
	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		self:hidePanel()

		return 
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}).anchor(slot4, 1, 1):pos(self.getw(self) - 9, self.geth(self) - 9):addTo(self)

	local btnLabelNames = {
		"升\n级",
		"启\n封"
	}

	local function btnPageCB(btn)
		sound.playSound("103")

		for i, v in ipairs(self.pageBtns) do
			if v == btn then
				v.select(v)
				v.setLocalZOrder(v, 10)
				v.label:setColor(cc.c3b(249, 237, 215))
			else
				v.unselect(v)
				v.setLocalZOrder(v, i - 10)
				v.label:setColor(cc.c3b(166, 161, 151))
			end
		end

		if btn.btnIndex ~= self.selectedBtnIndex then
			self.selectedBtnIndex = btn.btnIndex

			self:showPageInfo(self.selectedBtnIndex)
		end

		return 
	end

	for i, v in ipairs(slot4) do
		self.pageBtns[i] = an.newBtn(res.gettex2("pic/common/btn110.png"), btnPageCB, {
			clickSpace = 2,
			label = {
				btnLabelNames[i],
				20,
				1,
				{
					color = cc.c3b(249, 237, 215)
				}
			},
			select = {
				res.gettex2("pic/common/btn111.png"),
				manual = true
			}
		}):add2(self):pos(5, (i - 1)*75 - 326):anchor(1, 0)
		self.pageBtns[i].btnIndex = i

		self.pageBtns[i].label:pos(21, 55)
	end

	if not g_data.player.drumLevel or g_data.player.drumLevel < 1 then
		main_scene.ui:tip("当前军鼓等级小于1，提升军鼓等级至少1级后再重试!")
	else
		self.updateDrumProperty(self)
		self.updateDrumStrengthenProperty(self)

		if params == nil then
			btnPageCB(self.pageBtns[1])
		else
			btnPageCB(self.pageBtns[params.pageIndex])
		end
	end

	local rsb = DefaultClientMessage(CM_QueryDrumLevel)

	MirTcpClient:getInstance():postRsb(rsb)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_DrumLevel, self, self.onSM_DrumLevel)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_UpdateDrum, self, self.onSM_UpdateDrum)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_UnSealDrum, self, self.onSM_UnSealDrum)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_QUERYDIAMONDLIST, self, self.onSM_QUERYDIAMONDLIST)

	return 
end
drumUpgrade.onSM_DrumLevel = function (self, result, protoId)
	g_data.player.drumLevel = result.FDrumLevel
	g_data.player.drumStrengthenLevel = result.FDrumUnSealLv

	return 
end
drumUpgrade.onSM_UpdateDrum = function (self, result, protoId)
	if result.FBackValue == 0 then
		main_scene.ui:tip("军鼓升级成功！")

		g_data.player.drumLevel = g_data.player.drumLevel + 1
		local currentDrumLevel = g_data.player.drumLevel

		self.updatePropertyAndRequirement(self, currentDrumLevel)
		self.removeDrums(self)

		local curLvPos = {
			x = 35,
			y = 36
		}
		local nextLvPos = {
			x = 58,
			y = 60
		}

		self.addDrumToFrame(self, currentDrumLevel, g_data.player.drumStrengthenLevel, self.job, self.leftFrame, curLvPos)

		if currentDrumLevel < maxDrumLevel then
			self.addDrumToFrame(self, currentDrumLevel + 1, g_data.player.drumStrengthenLevel, self.job, self.rightFrame, nextLvPos)
		end
	end

	return 
end
drumUpgrade.onSM_QUERYDIAMONDLIST = function (self, result, protoId)
	if main_scene.ui.requestFromDrumUpgrade == false then
		return 
	end

	g_data.player:setGemstonesInfo(result)

	self.tableDiamondList = result.FDiamondList

	print("------------")

	for i, v in ipairs(self.tableDiamondList) do
		print(v.FLevel)
	end

	self.refreshDrumStrengthenBtn(self, self.tableDiamondList)

	return 
end
drumUpgrade.onSM_UnSealDrum = function (self, result, protoId)
	if result.FBackValue == 0 then
		main_scene.ui:tip("军鼓启封成功！")

		g_data.player.drumStrengthenLevel = g_data.player.drumStrengthenLevel + 1

		self.updateStrengthenUI(self, g_data.player.drumStrengthenLevel)
		self.removeDrums(self)

		local pos = {
			x = 35,
			y = 36
		}

		self.addDrumToFrame(self, g_data.player.drumLevel, g_data.player.drumStrengthenLevel, self.job, self.drumStrengthenFrame, pos)
	end

	return 
end
drumUpgrade.refreshDrumStrengthenBtn = function (self, diamondList)
	if self.strengthenBtn then
		self.strengthenBtn:removeSelf()

		self.strengthenBtn = nil
	end

	if self.diamondLabel then
		self.diamondLabel:removeSelf()

		self.diamondLabel = nil
	end

	if self.reqDrumLevelLabel then
		self.reqDrumLevelLabel:removeSelf()

		self.reqDrumLevelLabel = nil
	end

	if g_data.player.drumStrengthenLevel == maxDrumStrengthenLevel then
		return 
	end

	local currentDrumLevel = g_data.player.drumLevel
	local currentDrumStrengthenLevel = g_data.player.drumStrengthenLevel
	local valueReqDiamond = 0
	local curDiamondLevel = 0
	local nameReqDiamond = ""

	if drumStrengthenCfg[currentDrumStrengthenLevel + 1].NeedDiamondLvStr ~= "" then
		local strReqDiamond = drumStrengthenCfg[currentDrumStrengthenLevel + 1].NeedDiamondLvStr

		print(strReqDiamond)

		local tableReqDiamond = string.split(strReqDiamond, "=")
		nameReqDiamond = tableReqDiamond[1]

		print(nameReqDiamond)

		valueReqDiamond = tableReqDiamond[2]
		local diamondID = 0

		if string.find(nameReqDiamond, "暴击") then
			diamondID = 0
		elseif string.find(nameReqDiamond, "强攻") then
			diamondID = 1
		elseif string.find(nameReqDiamond, "血玉") then
			diamondID = 2
		elseif string.find(nameReqDiamond, "回复") then
			diamondID = 3
		elseif string.find(nameReqDiamond, "守护") then
			diamondID = 4
		elseif string.find(nameReqDiamond, "麻痹") then
			diamondID = 5
		end

		for i, v in ipairs(diamondList) do
			if v.FID == tostring(diamondID) then
				curDiamondLevel = v.FLevel

				break
			end
		end
	end

	if drumStrengthenCfg[currentDrumStrengthenLevel + 1].NeedDrumLv <= currentDrumLevel and tonumber(valueReqDiamond) <= tonumber(curDiamondLevel) then
		local function btnStrengthenCB()
			sound.playSound("103")

			if maxDrumStrengthenLevel <= currentDrumStrengthenLevel then
				main_scene.ui:tip("已完全启封")
			elseif currentDrumLevel < drumStrengthenCfg[currentDrumStrengthenLevel + 1].NeedDrumLv then
				main_scene.ui:tip("军鼓等级不足")
			elseif g_data.player.ability.FMeritValue < drumStrengthenCfg[currentDrumStrengthenLevel + 1].NeedMeritNum then
				main_scene.ui:tip("你的功勋不足")
			elseif g_data.player.ability.FSpringValue < drumStrengthenCfg[currentDrumStrengthenLevel + 1].NeedSpringNum then
				main_scene.ui:tip("你的泉水不足")
			else
				local rsb = DefaultClientMessage(CM_UnSealDrum)

				MirTcpClient:getInstance():postRsb(rsb)
			end

			return 
		end

		self.strengthenBtn = an.newBtn(res.gettex2("pic/common/btn20.png"), slot7, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			label = {
				"启封",
				18,
				0,
				{
					color = def.colors.Cf0c896
				}
			}
		}):pos(self.bg:getw()/2, 54):addTo(self.nodePageContent)
	else
		diamondLabelColor = (tonumber(valueReqDiamond) <= tonumber(curDiamondLevel) and display.COLOR_WHITE) or display.COLOR_RED

		if valueReqDiamond ~= 0 then
			self.diamondLabel = an.newLabel(nameReqDiamond .. "达到" .. math.floor(valueReqDiamond/10 + 1) .. "阶" .. valueReqDiamond%10 .. "星", 18, 0, {
				color = diamondLabelColor
			}):anchor(0.5, 0.5):pos(self.bg:getw()/2, 65):addTo(self.nodePageContent)
		end

		local reqDrumLevelLabelColor = (drumStrengthenCfg[currentDrumStrengthenLevel + 1].NeedDrumLv <= currentDrumLevel and display.COLOR_WHITE) or display.COLOR_RED
		self.reqDrumLevelLabel = an.newLabel("军鼓达到" .. drumStrengthenCfg[currentDrumStrengthenLevel + 1].NeedDrumLv .. "级可启封", 18, 0, {
			color = reqDrumLevelLabelColor
		}):anchor(0.5, 0.5):pos(self.bg:getw()/2, 40):addTo(self.nodePageContent)
	end

	return 
end
drumUpgrade.updateStrengthenUI = function (self, nextStrengthenLevel)
	self.updateDrumStrengthenProperty(self)

	if g_data.player.drumStrengthenLevel < maxDrumStrengthenLevel then
		self.labelDrumStrenLevel:setString(g_data.player.drumStrengthenLevel + 1 .. "阶启封")
	else
		self.labelDrumStrenLevel:removeSelf()

		self.labelDrumStrenLevel = nil
	end

	for i, v in ipairs(self.labelStrePropName) do
		if v then
			v.removeSelf(v)

			v = nil
		end
	end

	self.labelStrePropName = {}

	for i, v in ipairs(self.labelStrePropValue) do
		if v then
			v.removeSelf(v)

			v = nil
		end
	end

	self.labelStrePropValue = {}

	if g_data.player.drumStrengthenLevel < maxDrumStrengthenLevel then
		for i = 1, #self.nextStrengthenPropertyValue, 1 do
			local propertyName = ""
			local propertyValue = ""
			propertyName = string.sub(self.nextStrengthenPropertyName[i], 7, #self.nextStrengthenPropertyName[i])
			propertyValue = "+" .. self.nextStrengthenPropertyValue[i]
			self.labelStrePropName[i] = an.newLabel(propertyName .. ":", 18, 0, {
				color = def.colors.labelTitle
			}):anchor(0, 0.5):pos(140, (i - 1)*22 - 275):addto(self.nodePageContent)
			self.labelStrePropValue[i] = an.newLabel(propertyValue, 18, 0):anchor(0, 0.5):pos(230, (i - 1)*22 - 275):addto(self.nodePageContent)
		end

		local requiredMerit = drumStrengthenCfg[g_data.player.drumStrengthenLevel + 1].NeedMeritNum

		self.labelStrengthenMerit:setString(requiredMerit)

		local requiredWater = drumStrengthenCfg[g_data.player.drumStrengthenLevel + 1].NeedSpringNum

		self.labelStrengthenWater:setString(requiredWater)
		self.labelCurrentMerit:setString(g_data.player.ability.FMeritValue)
		self.labelCurrentWater:setString(g_data.player.ability.FSpringValue)
		self.refreshDrumStrengthenBtn(self, self.tableDiamondList)
	else
		an.newLabel("已完全启封", 18, 0, {
			color = def.colors.labelTitle
		}):anchor(0.5, 0.5):pos(self.bg:getw()/2, 240):addTo(self.nodePageContent)
		self.labelReqStrenMeritName:removeSelf()

		self.labelReqStrenMeritName = nil

		self.labelReqStrenWaterName:removeSelf()

		self.labelReqStrenWaterName = nil

		self.labelStrengthenMerit:removeSelf()

		self.labelStrengthenMerit = nil

		self.labelStrengthenWater:removeSelf()

		self.labelStrengthenWater = nil

		self.labelCurrentMerit:removeSelf()
		self.labelCurrentWater:removeSelf()
		self.labelCurStrenMeritName:removeSelf()
		self.labelCurStrenWaterName:removeSelf()

		if self.strengthenBtn then
			self.strengthenBtn:removeSelf()

			self.strengthenBtn = nil
		end
	end

	return 
end
drumUpgrade.updatePropertyAndRequirement = function (self, curLevel)
	self.updateDrumProperty(self)

	for i = 1, #self.currentPropertyValue - 1, 1 do
		local propertyValue = ""

		if i == 1 then
			propertyValue = self.currentPropertyValue[1] .. "-" .. self.currentPropertyValue[2]
		else
			propertyValue = "+" .. self.currentPropertyValue[i + 1]
		end

		self.labelsCurProperty[i]:setString(propertyValue)
	end

	local curMerit = g_data.player.ability.FMeritValue

	self.label9:setString(curMerit)

	if g_data.player.drumLevel < maxDrumLevel then
		for i = 1, #self.nextLevelPropertyValue - 1, 1 do
			local propertyValue = ""

			if i == 1 then
				propertyValue = self.nextLevelPropertyValue[1] .. "-" .. self.nextLevelPropertyValue[2]
			else
				propertyValue = "+" .. self.nextLevelPropertyValue[i + 1]
			end

			self.labelsNextPropertyValue[i]:setString(propertyValue)
		end

		local requiredLevel = drumCfg[curLevel + 1].UpNeedPlayerLevel
		local level = common.getLevelText(requiredLevel)

		self.label7:setString(level .. "级")

		local requiredMerit = drumCfg[curLevel + 1].UpNeedMeritNum

		self.label8:setString(tostring(requiredMerit))
	else
		for i, v in ipairs(self.labelsNextPropertyName) do
			if v then
				v.removeSelf(v)

				v = nil
			end
		end

		for i, v in ipairs(self.labelsNextPropertyValue) do
			if v then
				v.removeSelf(v)

				v = nil
			end
		end

		self.labelReqLvl:removeSelf()

		self.labelReqLvl = nil

		self.labelReqMerit:removeSelf()

		self.labelReqLvl = nil

		self.label7:removeSelf()

		self.label7 = nil

		self.label8:removeSelf()

		self.label8 = nil

		an.newLabel("已满级", 18, 0, {
			color = def.colors.labelTitle
		}):anchor(0.5, 0.5):pos(220, 252):addTo(self.nodePageContent)
		self.labelCurLvl:pos(68, 133)
		self.labelCurMerit:pos(68, 110)
		self.myLevel:pos(145, 133)
		self.label9:pos(140, 110)
	end

	return 
end
drumUpgrade.showPageInfo = function (self, selectedBtnIndex)
	print(selectedBtnIndex)

	if self.nodePageContent then
		self.nodePageContent:removeSelf()

		self.nodePageContent = nil
	end

	self.nodePageContent = display.newNode():addTo(self.bg)

	self.nodePageContent:size(self.bg:getw(), self.bg:geth()):anchor(0, 0):pos(0, 0)

	self.drumSprites = {}
	self.tableDiamondList = {}
	self.strengthenBtn = nil
	self.diamondLabel = nil
	self.reqDrumLevelLabel = nil

	if selectedBtnIndex == 1 then
		self.title:setString("军鼓升级")

		local currentDrumLevel = g_data.player.drumLevel
		local nextDrumLevel = currentDrumLevel + 1

		if g_data.player.drumLevel < maxDrumLevel then
			local requiredLevel = drumCfg[nextDrumLevel].UpNeedPlayerLevel
			local requiredMerit = drumCfg[nextDrumLevel].UpNeedMeritNum
			self.labelReqLvl = an.newLabel("所需等级:", 18, 0, {
				color = def.colors.labelTitle
			}):anchor(0.5, 0.5):pos(68, 133):addTo(self.nodePageContent)
			self.labelReqMerit = an.newLabel("所需功勋:", 18, 0, {
				color = def.colors.labelTitle
			}):anchor(0.5, 0.5):pos(68, 110):addTo(self.nodePageContent)
			local level = common.getLevelText(requiredLevel)
			self.label7 = an.newLabel(level .. "级", 18, 0):anchor(0.5, 0.5):pos(142, 133):addTo(self.nodePageContent)
			self.label8 = an.newLabel(tostring(requiredMerit), 18, 0):anchor(0.5, 0.5):pos(140, 110):addTo(self.nodePageContent)
		end

		self.labelCurLvl = an.newLabel("当前等级:", 18, 0, {
			color = def.colors.labelTitle
		}):anchor(0.5, 0.5):pos(240, 133):addTo(self.nodePageContent)
		self.labelCurMerit = an.newLabel("当前功勋:", 18, 0, {
			color = def.colors.labelTitle
		}):anchor(0.5, 0.5):pos(240, 110):addTo(self.nodePageContent)
		local curLevel = g_data.player.ability.FLevel
		local level = common.getLevelText(curLevel)
		self.myLevel = an.newLabel(level .. "级", 18, 0):anchor(0.5, 0.5):pos(324, 133):addTo(self.nodePageContent)
		local curMerit = g_data.player.ability.FMeritValue
		self.label9 = an.newLabel(tostring(curMerit), 18, 0):anchor(0.5, 0.5):pos(318, 110):addTo(self.nodePageContent)

		if g_data.player.drumLevel == maxDrumLevel then
			self.labelCurLvl:pos(68, 133)
			self.labelCurMerit:pos(68, 110)
			self.myLevel:pos(145, 133)
			self.label9:pos(140, 110)
		end

		local attackName = {
			"攻击",
			"魔法",
			"道术"
		}
		local myAttackName = attackName[self.job + 1]

		res.get2("pic/panels/drumUpgrade/tip.png"):addTo(self.nodePageContent):pos(39, 275)
		an.newLabel("当前属性", 18, 0, {
			color = def.colors.labelTitle
		}):anchor(0.5, 0.5):pos(85, 275):addTo(self.nodePageContent)

		for i = 1, #self.currentPropertyValue - 1, 1 do
			local propertyName = ""
			local propertyValue = ""

			if i == 1 then
				propertyName = myAttackName
				propertyValue = self.currentPropertyValue[1] .. "-" .. self.currentPropertyValue[2]
			else
				propertyName = string.sub(self.drumPropertyName[i + 1], 7, #self.drumPropertyName[i + 1])
				propertyValue = "+" .. self.currentPropertyValue[i + 1]
			end

			an.newLabel(propertyName .. ":", 18, 0, {
				color = def.colors.labelTitle
			}):anchor(0, 0.5):pos(35, (i - 1)*22 - 252):addto(self.nodePageContent)

			self.labelsCurProperty[i] = an.newLabel(propertyValue, 18, 0):anchor(0, 0.5):pos(105, (i - 1)*22 - 252):addto(self.nodePageContent)
		end

		local offsetX = 150

		res.get2("pic/panels/drumUpgrade/tip.png"):addTo(self.nodePageContent):pos(220, 275)
		an.newLabel("升级属性", 18, 0, {
			color = def.colors.labelTitle
		}):anchor(0.5, 0.5):pos(266, 275):addTo(self.nodePageContent)

		if g_data.player.drumLevel < maxDrumLevel then
			for i = 1, #self.nextLevelPropertyValue - 1, 1 do
				local propertyName = ""
				local propertyValue = ""

				if i == 1 then
					propertyName = myAttackName
					propertyValue = self.nextLevelPropertyValue[1] .. "-" .. self.nextLevelPropertyValue[2]
				else
					propertyName = string.sub(self.drumPropertyName[i + 1], 7, #self.drumPropertyName[i + 1])
					propertyValue = "+" .. self.nextLevelPropertyValue[i + 1]
				end

				self.labelsNextPropertyName[i] = an.newLabel(propertyName .. ":", 18, 0, {
					color = def.colors.labelTitle
				}):anchor(0, 0.5):pos(offsetX + 35 + 15, (i - 1)*22 - 252):addto(self.nodePageContent)
				self.labelsNextPropertyValue[i] = an.newLabel(propertyValue, 18, 0):anchor(0, 0.5):pos(offsetX + 105 + 15, (i - 1)*22 - 252):addto(self.nodePageContent)
			end
		else
			an.newLabel("已满级", 18, 0, {
				color = def.colors.labelTitle
			}):anchor(0.5, 0.5):pos(offsetX + 70 + 15, 252):addTo(self.nodePageContent)
		end

		self.leftFrame = res.get2("pic/panels/drumUpgrade/drumBgLeft.png"):addTo(self.nodePageContent):pos(101, 356)
		self.rightFrame = res.get2("pic/panels/drumUpgrade/drumBgRight.png"):addTo(self.nodePageContent):pos(290, 356)

		res.get2("pic/panels/drumUpgrade/arrow.png"):addTo(self.nodePageContent):pos(195, 356)

		local pos = {
			x = 35,
			y = 36
		}

		self.addDrumToFrame(self, currentDrumLevel, g_data.player.drumStrengthenLevel, self.job, self.leftFrame, pos)

		if currentDrumLevel < maxDrumLevel then
			pos = {
				x = 58,
				y = 60
			}

			self.addDrumToFrame(self, nextDrumLevel, g_data.player.drumStrengthenLevel, self.job, self.rightFrame, pos)
		end

		local function btnUpgradeCB()
			sound.playSound("103")

			local currentDrumLevel = g_data.player.drumLevel
			local nextDrumLevel = currentDrumLevel + 1

			if maxDrumLevel <= g_data.player.drumLevel then
				main_scene.ui:tip("当前军鼓已经达到最高等级")
			elseif g_data.player.ability.FLevel < drumCfg[nextDrumLevel].UpNeedPlayerLevel then
				main_scene.ui:tip("角色当前等级未达到要求")
			elseif g_data.player.ability.FMeritValue < drumCfg[nextDrumLevel].UpNeedMeritNum then
				main_scene.ui:tip("你的功勋不足")
			else
				local rsb = DefaultClientMessage(CM_UpdateDrum)

				MirTcpClient:getInstance():postRsb(rsb)
			end

			return 
		end

		an.newBtn(res.gettex2("pic/common/btn20.png"), slot11, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			label = {
				"开始升级",
				18,
				0,
				{
					color = def.colors.Cf0c896
				}
			}
		}):pos(self.bg:getw()/2, 54):addTo(self.nodePageContent)

		local function helpBtnCB()
			sound.playSound("103")

			local texts = {
				{
					"1.每次升级都需要消耗一定量的功勋，军鼓的等级越高升级所需的功勋越多。\n"
				},
				{
					"2.达到升级军鼓需要的角色等级要求才可以升级军鼓。\n"
				},
				{
					"3.升级后相应属性加成也会得到提升。\n"
				},
				{
					"4.军鼓满级为七十级军鼓。\n"
				}
			}
			local msgbox = an.newMsgbox(texts)

			return 
		end

		an.newBtn(res.gettex2("pic/common/question.png"), slot12, {
			pressBig = true,
			pressImage = res.gettex2("pic/common/question.png")
		}):pos(43, 394):addto(self.nodePageContent)
	elseif selectedBtnIndex == 2 then
		self.title:setString("军鼓启封")

		self.drumStrengthenFrame = res.get2("pic/panels/drumUpgrade/drumBgLeft.png"):addTo(self.nodePageContent):pos(self.bg:getw()/2, 365)
		local pos = {
			x = 35,
			y = 36
		}

		self.addDrumToFrame(self, g_data.player.drumLevel, g_data.player.drumStrengthenLevel, self.job, self.drumStrengthenFrame, pos)
		res.get2("pic/panels/drumUpgrade/tip.png"):addTo(self.nodePageContent):pos(39, 275)
		an.newLabel("启封属性:", 18, 0, {
			color = def.colors.labelTitle
		}):anchor(0.5, 0.5):pos(85, 275):addTo(self.nodePageContent)

		if g_data.player.drumStrengthenLevel < maxDrumStrengthenLevel then
			self.labelDrumStrenLevel = an.newLabel(g_data.player.drumStrengthenLevel + 1 .. "阶启封", 20, 0, {
				color = cc.c3b(255, 255, 0)
			}):anchor(0.5, 0.5):pos(self.bg:getw()/2, 315):addTo(self.nodePageContent)

			for i = 1, #self.nextStrengthenPropertyValue, 1 do
				local propertyName = ""
				local propertyValue = ""
				propertyName = string.sub(self.nextStrengthenPropertyName[i], 7, #self.nextStrengthenPropertyName[i])
				propertyValue = "+" .. self.nextStrengthenPropertyValue[i]
				self.labelStrePropName[i] = an.newLabel(propertyName .. ":", 18, 0, {
					color = def.colors.labelTitle
				}):anchor(0, 0.5):pos(140, (i - 1)*22 - 275):addto(self.nodePageContent)
				self.labelStrePropValue[i] = an.newLabel(propertyValue, 18, 0):anchor(0, 0.5):pos(230, (i - 1)*22 - 275):addto(self.nodePageContent)
			end
		end

		if g_data.player.drumStrengthenLevel < maxDrumStrengthenLevel then
			self.labelReqStrenMeritName = an.newLabel("所需功勋:", 18, 0, {
				color = def.colors.labelTitle
			}):anchor(0.5, 0.5):pos(68, 133):addTo(self.nodePageContent)
			local requiredMerit = drumStrengthenCfg[g_data.player.drumStrengthenLevel + 1].NeedMeritNum
			self.labelStrengthenMerit = an.newLabel(requiredMerit, 18, 0):anchor(0.5, 0.5):pos(135, 133):addTo(self.nodePageContent)
			self.labelReqStrenWaterName = an.newLabel("所需泉水:", 18, 0, {
				color = def.colors.labelTitle
			}):anchor(0.5, 0.5):pos(68, 110):addTo(self.nodePageContent)
			local requiredWater = drumStrengthenCfg[g_data.player.drumStrengthenLevel + 1].NeedSpringNum
			self.labelStrengthenWater = an.newLabel(requiredWater, 18, 0):anchor(0.5, 0.5):pos(130, 110):addTo(self.nodePageContent)
		end

		self.labelCurStrenMeritName = an.newLabel("当前功勋:", 18, 0, {
			color = def.colors.labelTitle
		}):anchor(0.5, 0.5):pos(240, 133):addTo(self.nodePageContent)
		self.labelCurrentMerit = an.newLabel(g_data.player.ability.FMeritValue, 18, 0):anchor(0.5, 0.5):pos(307, 133):addTo(self.nodePageContent)
		self.labelCurStrenWaterName = an.newLabel("当前泉水:", 18, 0, {
			color = def.colors.labelTitle
		}):anchor(0.5, 0.5):pos(240, 110):addTo(self.nodePageContent)
		self.labelCurrentWater = an.newLabel(g_data.player.ability.FSpringValue, 18, 0):anchor(0.5, 0.5):pos(307, 110):addTo(self.nodePageContent)

		if g_data.player.drumStrengthenLevel == maxDrumStrengthenLevel then
			self.labelCurStrenMeritName:removeSelf()
			self.labelCurrentMerit:removeSelf()
			self.labelCurStrenWaterName:removeSelf()
			self.labelCurrentWater:removeSelf()
			an.newLabel("已完全启封", 18, 0, {
				color = def.colors.labelTitle
			}):anchor(0.5, 0.5):pos(self.bg:getw()/2, 240):addTo(self.nodePageContent)
		end

		local function helpBtnCB()
			sound.playSound("103")

			local texts = {
				{
					"1.当军鼓达到一定等级后，可消耗材料进行启封。\n"
				},
				{
					"2.启封后军鼓将附加启封属性。\n"
				}
			}
			local msgbox = an.newMsgbox(texts)

			return 
		end

		an.newBtn(res.gettex2("pic/common/question.png"), drumStrengthenCfg, {
			pressBig = true,
			pressImage = res.gettex2("pic/common/question.png")
		}):pos(43, 394):addto(self.nodePageContent)

		if g_data.player.drumStrengthenLevel < maxDrumStrengthenLevel then
			local rsb = DefaultClientMessage(CM_QUERYDIAMONDLIST)
			main_scene.ui.requestFromDrumUpgrade = true
			g_data.heroEquip.gemstoneRequestFromEquip = false

			MirTcpClient:getInstance():postRsb(rsb)
		end
	end

	return 
end
drumUpgrade.addDrumToFrame = function (self, drumLevel, drumStrengthenLevel, job, frame, pos)
	local curDrumPicIndex = 0

	if 0 < drumLevel and drumLevel <= 5 then
		curDrumPicIndex = 3472
	elseif 5 < drumLevel and drumLevel <= 10 then
		curDrumPicIndex = 3473
	elseif 10 < drumLevel and drumLevel <= 15 then
		curDrumPicIndex = 3474
	elseif 15 < drumLevel and drumLevel <= 35 then
		curDrumPicIndex = 3899
	elseif 35 < drumLevel and drumLevel <= 49 then
		curDrumPicIndex = 4253
	elseif 49 < drumLevel and drumLevel <= 69 then
		curDrumPicIndex = 4660
	elseif drumLevel == 70 then
		curDrumPicIndex = 5000
	else
		return 
	end

	local drum = nil
	self.drumSprites[#self.drumSprites + 1] = res.get("items", curDrumPicIndex):addto(frame):pos(frame.getw(frame)*0.5, frame.geth(frame)*0.5)
	local posNode = display.newNode()

	posNode.add2(posNode, frame)

	local function clickDrumCurrentLevelCB()
		posNode:pos(pos.x, pos.y)

		local p = posNode:convertToWorldSpace(cc.p(0, 0))
		self.infoLayer = drumInfo.show(drumLevel, drumStrengthenLevel, job, p, {})

		return 
	end

	self.drumSprites[#self.drumSprites].enableClick(slot10, clickDrumCurrentLevelCB, {
		ani = false
	})

	return self.drumSprites[#self.drumSprites]
end
drumUpgrade.removeDrums = function (self)
	for i, v in ipairs(self.drumSprites) do
		if v then
			v.removeSelf(v)

			v = nil
		end
	end

	self.drumSprites = {}

	return 
end
drumUpgrade.updateDrumProperty = function (self)
	local curLevel = g_data.player.drumLevel
	local strCurrentProperty = drumCfg[curLevel].PropertyStr
	local propertyItems = string.split(strCurrentProperty, ";")
	local selfJobProperty = {
		propertyItems[self.job*2 + 1],
		propertyItems[self.job*2 + 2],
		propertyItems[self.job + 7],
		propertyItems[self.job + 10],
		propertyItems[self.job + 13]
	}
	self.drumPropertyName = {}
	self.currentPropertyValue = {}

	for i, v in ipairs(selfJobProperty) do
		local itemNameAndValue = string.split(v, "=")
		self.drumPropertyName[#self.drumPropertyName + 1] = itemNameAndValue[1]
		self.currentPropertyValue[#self.currentPropertyValue + 1] = itemNameAndValue[2]
	end

	if curLevel < maxDrumLevel then
		local nextLevel = curLevel + 1
		local strCurrentProperty = drumCfg[nextLevel].PropertyStr
		local propertyItems = string.split(strCurrentProperty, ";")
		local selfJobProperty = {
			propertyItems[self.job*2 + 1],
			propertyItems[self.job*2 + 2],
			propertyItems[self.job + 7],
			propertyItems[self.job + 10]
		}
		self.nextLevelPropertyValue = {}

		for i, v in ipairs(selfJobProperty) do
			local itemNameAndValue = string.split(v, "=")
			self.nextLevelPropertyValue[#self.nextLevelPropertyValue + 1] = itemNameAndValue[2]
		end
	end

	return 
end
drumUpgrade.updateDrumStrengthenProperty = function (self)
	if g_data.player.drumStrengthenLevel < maxDrumStrengthenLevel then
		local nextStrengthenLevel = g_data.player.drumStrengthenLevel + 1
		local strNextStrengthenProperty = drumStrengthenCfg[nextStrengthenLevel].AddedPropertyStr
		local propertyItems = string.split(strNextStrengthenProperty, ";")
		local selfJobProperty = {
			propertyItems[self.job + 1],
			propertyItems[self.job + 4],
			propertyItems[self.job + 7],
			propertyItems[self.job + 10],
			propertyItems[self.job + 13]
		}
		self.nextStrengthenPropertyName = {}
		self.nextStrengthenPropertyValue = {}

		for i, v in ipairs(selfJobProperty) do
			local itemNameAndValue = string.split(v, "=")
			self.nextStrengthenPropertyName[#self.nextStrengthenPropertyName + 1] = itemNameAndValue[1]
			self.nextStrengthenPropertyValue[#self.nextStrengthenPropertyValue + 1] = itemNameAndValue[2]
		end
	end

	if 1 <= g_data.player.drumStrengthenLevel then
		local strCurStrengthenProperty = drumStrengthenCfg[g_data.player.drumStrengthenLevel].PropertyStr
		local propertyItems = string.split(strCurStrengthenProperty, ";")
		local selfJobProperty = {
			propertyItems[self.job + 1],
			propertyItems[self.job + 4],
			propertyItems[self.job + 7],
			propertyItems[self.job + 10],
			propertyItems[self.job + 13],
			propertyItems[self.job + 16],
			propertyItems[self.job + 19]
		}
		self.curStrengthenPropertyName = {}
		self.curStrengthenPropertyValue = {}

		for i, v in ipairs(selfJobProperty) do
			local itemNameAndValue = string.split(v, "=")
			self.curStrengthenPropertyName[#self.curStrengthenPropertyName + 1] = itemNameAndValue[1]
			self.curStrengthenPropertyValue[#self.curStrengthenPropertyValue + 1] = itemNameAndValue[2]
		end
	end

	return 
end

return drumUpgrade
