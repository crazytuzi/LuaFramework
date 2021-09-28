local medalImpress = class("medalImpress", import(".panelBase"))
local common = import("..common.common")
local item = import("..common.item")
local tipStr = "1、开服140天，服务器到达三阶段，开启勋章铭刻。\n" .. "2、勋章铭刻可分为青龙、白虎、朱雀三种纹饰。\n" .. "3、勋章铭刻消耗声望，铭刻提升可为角色提供属性加成。\n" .. "4、勋章铭刻存在“普通铭刻”和“快速铭刻”，两种提升方式。\n" .. "5、使用快速铭刻，提升的更快，但存在损耗。消耗的声望只有60%转化为铭刻进度。\n" .. "6、三种纹饰的“普通铭刻”和“快速铭刻”共享每日铭刻10次的限制。\n" .. "7、铭刻每10级突破一次，突破消耗勋章灵印，勋章灵印由部分世界首领掉落产出。"
local typeWZ = {
	{
		"青龙",
		"ql",
		95,
		300,
		100,
		260
	},
	{
		"白虎",
		"bh",
		300,
		300,
		305,
		260
	},
	{
		"朱雀",
		"zq",
		195,
		215,
		200,
		175
	}
}
local msgTuPo = {
	[-9.0] = "突破失败，服务器阶段不足！",
	[-10.0] = "突破失败，角色等级不足！",
	[-7.0] = "突破失败，剩余次数不足！",
	[-31.0] = "突破失败，开服天数不足！",
	[-32.0] = "突破失败，未放入勋章！",
	[-23.0] = "突破失败，勋章灵印不足！"
}
local msgUP = {
	[-9.0] = "铭刻失败，服务器阶段不足！",
	[-10.0] = "铭刻失败，角色等级不足！",
	[-13.0] = "铭刻失败，声望不足！",
	[-7.0] = "铭刻失败，剩余次数不足！",
	[-31.0] = "铭刻失败，开服天数不足！",
	[-32.0] = "铭刻失败，未放入勋章！"
}
local texts = {
	{
		"使用“快速铭刻”，提升速度更快，但消耗的",
		cc.c3b(240, 200, 150)
	},
	{
		"100点声望",
		cc.c3b(255, 0, 0)
	},
	{
		"只有",
		cc.c3b(240, 200, 150)
	},
	{
		"60%",
		cc.c3b(255, 0, 0)
	},
	{
		"转化为铭刻进度。是否确认使用“快速铭刻”？",
		cc.c3b(240, 200, 150)
	}
}
medalImpress.ctor = function (self, param)
	self.super.ctor(self)
	self.setMoveable(self, true)

	if main_scene.ui.panels.npc then
		main_scene.ui:togglePanel("npc")
	end

	return 
end
medalImpress.clearContentNode = function (self)
	if self.contentNode then
		self.contentNode:removeAllChildren()
	end

	self.contentNode = display.newNode():addTo(self.bg)
	self.contentNode.controls = {}
	self.contentNode.data = {}

	return 
end
medalImpress.onEnter = function (self)
	self.selIdx = 1
	self.lastBntSelect = 0

	self.initPanelUI(self, {
		title = "勋章铭刻",
		bg = "pic/common/black_2.png"
	})
	self.pos(self, display.cx - 102, display.cy)
	self.fillEngraveContent(self, self.selIdx)
	self.bindNetEvent(self, SM_ClientUpMILev, self.onSM_ClientUpMILev)
	self.bindNotify(self, "CHANGE_MEDAL", self.onMedalChange)

	return 
end
medalImpress.onMedalChange = function (self)
	self.onSelectWZ(self, self.selIdx or 1)

	return 
end
medalImpress.fillEngraveContent = function (self, selIdx)
	self.clearContentNode(self)

	local leftNode = display.newScale9Sprite(res.getframe2("pic/panels/medalImpress/imbg.png")):anchor(0, 1):pos(12, self.bg:geth() - 50):addTo(self.contentNode, 1)
	self.contentNode.controls.leftNode = leftNode

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
	}).pos(slot3, 20, leftNode.geth(leftNode) - 20):addto(leftNode)

	local lvlTitle = an.newLabel("", 20, 1, {
		color = def.colors.text
	}):anchor(0.5, 1):pos(leftNode.getw(leftNode)/2, leftNode.geth(leftNode) - 4):add2(leftNode)
	self.contentNode.controls.lvlTitle = lvlTitle
	local selectedBg = {}
	local lblLvlTip = {}

	for k, v in pairs(typeWZ) do
		local selBtn = an.newBtn(res.gettex2("pic/panels/horseSoul/hole.png"), function ()
			sound.playSound("103")

			for k2, v2 in pairs(selectedBg) do
				if k2 == k then
					v2.show(v2)
				else
					v2.hide(v2)
				end
			end

			self.selIdx = k

			self:onSelectWZ(self.selIdx)

			return 
		end, {
			sprite = res.gettex2("pic/panels/medalImpress/" .. v[2] .. ".png")
		}).pos(slot11, v[3], v[4]):addto(leftNode)
		local bordBg = display.newScale9Sprite(res.getframe2("pic/panels/horseSoul/selBorder.png")):anchor(0.5, 0.5):pos(selBtn.getw(selBtn)/2, selBtn.geth(selBtn)/2):addTo(selBtn, 1)
		selectedBg[k] = bordBg

		if k ~= selIdx then
			bordBg.hide(bordBg)
		end

		lblLvlTip[k] = an.newLabel("", 18, 1, {
			color = def.colors.Cdcd2be
		}):anchor(0.5, 1):pos(v[5], v[6]):add2(leftNode, 2)
	end

	self.contentNode.controls.selectedBtn = selectedBg
	self.contentNode.controls.lblLvlTip = lblLvlTip
	local showCount = 3
	local starsNode = {}

	for i = 1, 10, 1 do
		local star = an.newBtn(res.gettex2("pic/panels/wingUpgrade/starBg.png"), function ()
			sound.playSound("103")

			return 
		end, {
			select = {
				res.gettex2("pic/panels/wingUpgrade/star.png")
			}
		}).add2(slot12, leftNode):anchor(0.5, 0.5):pos(i*26 + 55, 135)

		star.setTouchEnabled(star, false)

		starsNode[i] = star
	end

	self.contentNode.controls.starsNode = starsNode
	local processBar = an.newProgress(res.gettex2("pic/common/slider2.png"), res.gettex2("pic/common/sliderBg2.png"), {
		x = 4,
		y = 5
	}):anchor(0.5, 0.5):pos(leftNode.getw(leftNode)/2, 110):add2(leftNode):scale(1.1)

	processBar.setp(processBar, 0)

	local lblProcess = an.newLabel("", 16, 1, {
		color = def.colors.text
	}):anchor(0.5, 0.5):pos(processBar.getw(processBar)/2, processBar.geth(processBar)/2):add2(processBar, 10)
	self.contentNode.controls.processBar = processBar
	self.contentNode.controls.lblProcess = lblProcess
	local lblFreeNum = an.newLabel("", 18, 1, {
		color = def.colors.Cdcd2be
	}):anchor(0, 0):pos(70, 75):add2(leftNode)
	local lblCurSW = an.newLabel("", 18, 1, {
		color = def.colors.Cdcd2be
	}):anchor(0, 0):pos(230, 75):add2(leftNode)
	self.contentNode.controls.lblFreeNum = lblFreeNum
	self.contentNode.controls.lblCurSW = lblCurSW
	local activeNode = display.newNode():addto(leftNode)
	self.contentNode.controls.activeNode = activeNode
	local propNode = display.newScale9Sprite(res.getframe2("pic/common/black_4.png")):anchor(1, 0):pos(self.bg:getw() - 10, 12):size(216, leftNode.geth(leftNode)):addTo(self.contentNode)
	self.contentNode.controls.propNode = propNode

	self.onSelectWZ(self, selIdx)

	return 
end
medalImpress.onSelectWZ = function (self, selIdx)
	local miInfo = self.getMIInfo(self, selIdx)
	local lvl = 0
	local curExp = 0
	local needTuPo = 0

	if miInfo then
		lvl = miInfo.FmiLevel or 0
		curExp = miInfo.FmiHaveStuff or 0
		needTuPo = miInfo.FmiNeedTuPo or 0
	end

	local miCfg = self.getMICfg(self, selIdx, lvl + 1)
	local needExp = 0
	local needSW1 = 0
	local needSW2 = 0

	if miCfg then
		needExp = miCfg.miNeedExp or 0
		needSW1 = miCfg.miUpNeedItem1 or 0
		needSW2 = miCfg.miUpNeedItem2 or 0
	end

	local needLY = 0

	if needTuPo == 1 then
		needLY = self.decodeBreakStuff(self, selIdx, lvl + 1)
	end

	local leftNode = self.contentNode.controls.leftNode
	local lvlTitle = self.contentNode.controls.lvlTitle

	lvlTitle.setString(lvlTitle, typeWZ[selIdx][1] .. "纹")

	local lblLvlTip = self.contentNode.controls.lblLvlTip

	for k, v in pairs(lblLvlTip) do
		local info = self.getMIInfo(self, k)

		if info and info.FmiLevel and 0 < info.FmiLevel then
			v.setString(v, typeWZ[k][1] .. "纹+" .. info.FmiLevel)
		else
			v.setString(v, typeWZ[k][1] .. "纹")
		end
	end

	local starsNode = self.contentNode.controls.starsNode
	local starsNum = lvl%10

	if 0 < lvl and starsNum == 0 then
		starsNum = 10
	end

	if starsNode then
		for i = 1, 10, 1 do
			if i <= starsNum then
				starsNode[i]:select()
			else
				starsNode[i]:unselect()
			end
		end
	end

	local processBar = self.contentNode.controls.processBar
	local lblProcess = self.contentNode.controls.lblProcess

	if processBar then
		local scaleExp = 0

		if 0 < needExp then
			scaleExp = curExp/needExp
		end

		if needTuPo == 1 then
			processBar.setp(processBar, 1)
			lblProcess.setColor(lblProcess, def.colors.Cf30302)
			lblProcess.setString(lblProcess, "需突破")
		elseif lvl == 100 then
			processBar.setp(processBar, 1)
			lblProcess.setColor(lblProcess, def.colors.Cf30302)
			lblProcess.setString(lblProcess, "已满级")
		else
			processBar.setp(processBar, scaleExp)
			lblProcess.setColor(lblProcess, def.colors.text)
			lblProcess.setString(lblProcess, curExp .. "/" .. needExp)
		end
	end

	local lblFreeNum = self.contentNode.controls.lblFreeNum
	local lblCurSW = self.contentNode.controls.lblCurSW

	lblFreeNum.setString(lblFreeNum, "剩余次数:" .. g_data.player.medalImpressNum)
	lblCurSW.setString(lblCurSW, "当前声望:" .. g_data.player.ability.FPrestige)

	local leftNode = self.contentNode.controls.leftNode
	local activeNode = self.contentNode.controls.activeNode

	if activeNode then
		activeNode.removeAllChildren(activeNode)
	end

	local medalUpgrade = main_scene.ui.panels.medalUpgrade
	local medal = g_data.equip.items[2] or g_data.bag:getItemWithstdMode({
		30
	}) or (medalUpgrade and medalUpgrade.itemData)

	if medal then
		item.new(medal, self, {
			donotMove = true
		}):anchor(0.5, 0.5):pos(leftNode.getw(leftNode)/2, leftNode.geth(leftNode) - 92):add2(activeNode):scale(1.2)
	end

	function checkMedalImpress(selIdx, t)
		local ok = 1
		local msg = ""

		if not medal then
			ok = 0
			msg = "未放入勋章！"
		end

		if ok == 1 and 100 <= lvl then
			ok = 0
			msg = typeWZ[selIdx][1] .. "纹已满级！"
		end

		if miCfg and needTuPo == 0 then
			if ok == 1 and g_data.client.serverState < miCfg.miNeedSvrStep then
				ok = 0
				msg = "服务器阶段不足！"
			end

			if ok == 1 and g_data.player.ability.FLevel < miCfg.miNeedRoleLv then
				ok = 0
				msg = "角色等级不足！"
			end
		end

		if ok == 1 then
			if t == 1 and g_data.player.ability.FPrestige < needSW1 then
				ok = 0
				msg = "声望不足！"
			elseif t == 2 and g_data.player.ability.FPrestige < needSW2 then
				ok = 0
				msg = "声望不足！"
			elseif t == 3 and g_data.bag:getItemCount("勋章灵印") < needLY then
				ok = 0
				msg = "勋章灵印不足！"
			end
		end

		if ok == 0 and msg ~= "" then
			if t == 3 then
				main_scene.ui:tip("突破失败，" .. msg)
			else
				main_scene.ui:tip("铭刻失败，" .. msg)
			end

			return 
		end

		local rsb = DefaultClientMessage(CM_ClientUpMILev)
		rsb.FmiTypeID = selIdx
		rsb.FmiUpType = t

		MirTcpClient:getInstance():postRsb(rsb)

		return 
	end

	if needTuPo == 0 then
		if curExp <= needExp or lvl == 100 then
			if 0 < needSW1 and lvl < 100 then
				slot24 = an.newLabel("消耗：声望*" .. slot8, 18, 1, {
					color = def.colors.Cdcd2be
				}):anchor(0, 0):pos(60, 52):add2(activeNode)
			end

			if 0 < needSW2 and lvl < 100 then
				slot24 = an.newLabel("消耗：声望*" .. needSW2, 18, 1, {
					color = def.colors.Cdcd2be
				}):anchor(0, 0):pos(230, 52):add2(activeNode)
			end

			an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
				sound.playSound("103")
				checkMedalImpress(selIdx, 1)

				return 
			end, {
				label = {
					"普通铭刻",
					18,
					1,
					{
						color = def.colors.Cf0c896
					}
				},
				pressImage = res.gettex2("pic/common/btn21.png")
			}).pos(slot24, 120, 30):addto(activeNode)
			an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
				sound.playSound("103")
				print(tostring(g_data.setting.other.medalImpress))

				if g_data.setting.other.medalImpress == false then
					an.newMsgbox(texts, function (isOk)
						if isOk == 1 then
							g_data.setting.other.medalImpress = true

							cache.saveSetting(common.getPlayerName(), "other")
							checkMedalImpress(selIdx, 2)
						end

						return 
					end, {
						disableScroll = true,
						fontSize = 20,
						title = "快速铭刻",
						center = true,
						hasCancel = true
					})
				else
					checkMedalImpress(selIdx, 2)
				end

				return 
			end, {
				label = {
					"快速铭刻",
					18,
					1,
					{
						color = def.colors.Cf0c896
					}
				},
				pressImage = res.gettex2("pic/common/btn21.png")
			}).pos(slot24, 290, 30):addto(activeNode)
		else
			an.newLabel("本次铭刻不消耗声望和铭刻次数。", 18, 1, {
				color = def.colors.Cdcd2be
			}):anchor(0.5, 0):pos(leftNode.getw(leftNode)/2, 52):add2(activeNode)
			an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
				sound.playSound("103")

				local rsb = DefaultClientMessage(CM_ClientUpMILev)
				rsb.FmiTypeID = selIdx
				rsb.FmiUpType = 1

				MirTcpClient:getInstance():postRsb(rsb)

				return 
			end, {
				label = {
					"铭刻",
					18,
					1,
					{
						color = def.colors.Cf0c896
					}
				},
				pressImage = res.gettex2("pic/common/btn21.png")
			}).anchor(slot24, 0.5, 0):pos(leftNode.getw(leftNode)/2, 10):addto(activeNode)
		end
	else
		if 0 < needLY then
			slot24 = an.newLabel("勋章灵印*" .. needLY, 18, 1, {
				color = def.colors.Cdcd2be
			}):anchor(0.5, 0):pos(leftNode.getw(leftNode)/2, 52):add2(activeNode)
		end

		an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
			sound.playSound("103")

			self.lastBntSelect = 1

			checkMedalImpress(selIdx, 3)

			return 
		end, {
			label = {
				"突破",
				18,
				1,
				{
					color = def.colors.Cf0c896
				}
			},
			pressImage = res.gettex2("pic/common/btn21.png")
		}).anchor(slot24, 0.5, 0):pos(leftNode.getw(leftNode)/2, 10):addto(activeNode)
	end

	self.fillPropView(self, selIdx, needTuPo)

	return 
end
medalImpress.fillPropView = function (self, selIdx, needTuPo)
	local miInfo = self.getMIInfo(self, selIdx)
	local lvl = 0

	if miInfo and miInfo.FmiLevel then
		lvl = miInfo.FmiLevel
	end

	local function addPropLine(name, value, parent, y)
		local lblProp = an.newLabel(name, 18, 1, {
			color = cc.c3b(240, 200, 150)
		}):anchor(0, 0.5):pos(13, y):add2(parent)

		an.newLabel(value, 18, 1, {
			color = cc.c3b(220, 210, 190)
		}):anchor(0, 0.5):pos(lblProp.getPositionX(lblProp) + lblProp.getw(lblProp), lblProp.getPositionY(lblProp)):add2(parent)

		return lblProp.geth(lblProp)
	end

	local propNode = self.contentNode.controls.propNode

	if propNode then
		propNode.removeAllChildren(slot6)
	end

	local propH = propNode.geth(propNode)
	local rect = cc.rect(0, 0, 192, 150)
	local nameProps = {
		"攻击：",
		"魔法：",
		"道术："
	}
	local job = g_data.player.job

	display.newSprite(res.gettex2("pic/panels/wingUpgrade/flag.png")):anchor(0, 0.5):pos(8, propH - 20):add2(propNode)
	display.newSprite(res.gettex2("pic/panels/wingUpgrade/dqsx.png")):anchor(0, 0.5):pos(26, propH - 20):add2(propNode)
	display.newScale9Sprite(res.getframe2("pic/scale/scale29.png")):anchor(0.5, 1):pos(propNode.getw(propNode)/2, propH - 35):size(210, 160):addTo(propNode)

	local scrollCur = an.newScroll(0, 0, rect.width, rect.height):add2(propNode):anchor(0.5, 1):pos(propNode.getw(propNode)/2, propH - 42)
	local nodeCur = display.newNode()
	local poxY = 0
	local flag = "         "
	local textCur = {
		"开服天数：",
		"服务器：",
		"角色等级：",
		nameProps[job + 1],
		"生命：",
		"突破属性",
		nameProps[job + 1],
		"生命："
	}

	if 0 < lvl then
		local dataCur = self.getPropViewContent(self, selIdx, lvl)

		for i = 1, #dataCur, 1 do
			if dataCur[i] and dataCur[i] ~= "" then
				poxY = poxY + addPropLine(textCur[i], dataCur[i], nodeCur, -poxY)
			end
		end

		local blvl = 0

		if needTuPo == 0 and lvl < 100 then
			blvl = math.floor(lvl/10)*10 + 1
		else
			blvl = (math.floor(lvl/10) - 1)*10 + 1
		end

		local breakCur = self.getBreakUpProp(self, selIdx, blvl)

		if breakCur then
			for i = 1, #breakCur, 1 do
				if breakCur[i] and breakCur[i] ~= "" then
					poxY = poxY + addPropLine(textCur[#dataCur + i], breakCur[i], nodeCur, -poxY)
				end
			end
		end

		if poxY < rect.height then
			poxY = rect.height
		end
	else
		addPropLine(flag .. typeWZ[selIdx][1] .. "纹未铭刻", "", nodeCur, -poxY)

		poxY = rect.height/2 + 10
	end

	nodeCur.pos(nodeCur, 0, poxY - 10):add2(scrollCur)
	scrollCur.setScrollSize(scrollCur, rect.width, poxY)
	scrollCur.setScrollOffset(scrollCur, 0, 0)
	display.newSprite(res.gettex2("pic/panels/wingUpgrade/flag.png")):anchor(0, 0.5):pos(8, propH - 215):add2(propNode)
	display.newSprite(res.gettex2("pic/panels/wingUpgrade/xjsx.png")):anchor(0, 0.5):pos(26, propH - 215):add2(propNode)
	display.newScale9Sprite(res.getframe2("pic/scale/scale29.png")):anchor(0.5, 1):pos(propNode.getw(propNode)/2, propH - 230):size(210, 160):addTo(propNode)

	local scrollNext = an.newScroll(0, 0, rect.width, rect.height):add2(propNode):anchor(0.5, 1):pos(propNode.getw(propNode)/2, propH - 236)
	local nodeNext = display.newNode()
	poxY = 0
	local textNext = {
		"开服天数：",
		"服务器：",
		"角色等级：",
		nameProps[job + 1],
		"生命：",
		"突破属性",
		nameProps[job + 1],
		"生命："
	}

	if lvl < 100 then
		local dataNext = self.getPropViewContent(self, selIdx, lvl + 1)

		for i = 1, #dataNext, 1 do
			if dataNext[i] and dataNext[i] ~= "" then
				poxY = poxY + addPropLine(textNext[i], dataNext[i], nodeNext, -poxY)
			end
		end

		local blvl = math.floor(lvl/10)*10 + 1
		local breakNext = self.getBreakUpProp(self, selIdx, blvl)

		if breakNext then
			for i = 1, #breakNext, 1 do
				if breakNext[i] and breakNext[i] ~= "" then
					poxY = poxY + addPropLine(textNext[#dataNext + i], breakNext[i], nodeNext, -poxY)
				end
			end
		end

		if poxY < rect.height then
			poxY = rect.height
		end
	else
		addPropLine(flag .. typeWZ[selIdx][1] .. "纹铭刻\n" .. flag .. "    已满级", "", nodeNext, -poxY)

		poxY = rect.height/2
	end

	nodeNext.pos(nodeNext, 0, poxY - 10):add2(scrollNext)
	scrollNext.setScrollSize(scrollNext, rect.width, poxY)
	scrollNext.setScrollOffset(scrollNext, 0, 0)

	return 
end
medalImpress.getMIInfo = function (self, id)
	local mIInfo = g_data.player.medalImpressInfo
	local info = nil

	if mIInfo then
		for k, v in pairs(mIInfo) do
			if v.FmiTypeID == id then
				info = v

				break
			end
		end
	end

	return info
end
medalImpress.getMICfg = function (self, id, lvl)
	local mICfgs = def.medalImpressUP
	local cfg = nil

	for k, v in pairs(mICfgs) do
		if v.miType == id and v.miLevel == lvl then
			cfg = v

			break
		end
	end

	return cfg
end
medalImpress.decodeProps = function (self, id, lvl)
	local cfg = self.getMICfg(self, id, lvl)

	if cfg and cfg.miGetProperty and cfg.miGetProperty ~= "" then
		local job = g_data.player.job
		local ret = {}
		local propStrs = string.split(cfg.miGetProperty, ";")
		local tmps = nil
		tmps = string.split(propStrs[job*2 + 1], "=")
		ret.xx = tonumber(tmps[2])
		tmps = string.split(propStrs[job*2 + 2], "=")
		ret.sx = tonumber(tmps[2])

		if propStrs[job + 7] then
			tmps = string.split(propStrs[job + 7], "=")
			ret.hp = tonumber(tmps[2])
		end

		return ret
	end

	return 
end
medalImpress.decodeBreakStuff = function (self, id, lvl)
	local mIBreakCfgs = def.medalImpressBreak
	local cfg = nil

	for k, v in pairs(mIBreakCfgs) do
		if v.miType == id and v.miLevel == lvl then
			cfg = v

			break
		end
	end

	if cfg and cfg.miNeedItems and cfg.miNeedItems ~= "" then
		local tmpStrs = string.split(cfg.miNeedItems, "|")

		if tmpStrs[2] then
			return tonumber(tmpStrs[2])
		end
	end

	return 0
end
medalImpress.getBreakUpProp = function (self, id, blvl)
	local mIBreakCfgs = def.medalImpressBreak

	print("blvl:" .. blvl)

	local cfg = nil

	print(id .. "--:" .. blvl)

	for k, v in pairs(mIBreakCfgs) do
		if v.miType == id and v.miLevel == blvl then
			cfg = v

			print_r(cfg)

			break
		end
	end

	if cfg and cfg.miGetProperty and cfg.miGetProperty ~= "" then
		local job = g_data.player.job
		local propStrs = string.split(cfg.miGetProperty, ";")
		local tmps, xx, sx, hp = nil
		tmps = string.split(propStrs[job*2 + 1], "=")
		xx = tonumber(tmps[2])
		tmps = string.split(propStrs[job*2 + 2], "=")
		sx = tonumber(tmps[2])

		if propStrs[job + 7] then
			tmps = string.split(propStrs[job + 7], "=")
			hp = tonumber(tmps[2])
		end

		local rets = {
			"  ",
			""
		}

		if xx and sx then
			rets[2] = xx .. "-" .. sx
		end

		rets[3] = ""

		if hp then
			rets[3] = "+" .. hp
		end

		return rets
	end

	return 
end
medalImpress.getPropViewContent = function (self, id, lvl)
	local cfg = self.getMICfg(self, id, lvl)
	local result = {}

	if cfg then
		result[1] = ""

		if g_data.client.openDay < cfg.miNeedOpenDay + 1 then
			result[1] = cfg.miNeedOpenDay .. "天"
		end

		result[2] = ""

		if g_data.client.serverState < cfg.miNeedSvrStep then
			result[2] = cfg.miNeedSvrStep .. "阶段"
		end

		local lvlStr = cfg.miNeedRoleLv%99 .. "级"

		if 0 < math.floor(cfg.miNeedRoleLv/99) then
			lvlStr = math.floor(cfg.miNeedRoleLv/99) .. "转" .. lvlStr
		end

		result[3] = lvlStr
		local propVals = self.decodeProps(self, id, lvl)
		result[4] = ""

		if propVals.xx and propVals.sx then
			result[4] = propVals.xx .. "-" .. propVals.sx
		end

		result[5] = ""

		if propVals.hp then
			result[5] = "+" .. propVals.hp
		end
	end

	return result
end
medalImpress.onSM_ClientUpMILev = function (self, result)
	print("铭刻回调(onSM_ClientUpMILev):")

	if result then
		if result.FRetCode == 1 then
			local info = self.getMIInfo(self, result.FmiTypeID)

			if info then
				info.FmiLevel = result.FmiLevel
				info.FmiHaveStuff = result.FmiHaveStuff
				info.FmiNeedTuPo = result.FmiIsNeedTuPo
			else
				local info = {
					FmiTypeID = result.FmiTypeID,
					FmiLevel = result.FmiLevel,
					FmiHaveStuff = result.FmiHaveStuff,
					FmiNeedTuPo = result.FmiIsNeedTuPo
				}

				table.insert(g_data.player.medalImpressInfo, info)
			end

			g_data.player.medalImpressNum = result.FmiHaveCount

			self.onSelectWZ(self, self.selIdx)

			if self.lastBntSelect == 0 then
				main_scene.ui:tip(typeWZ[result.FmiTypeID][1] .. "纹铭刻成功！")
			else
				self.lastBntSelect = 0

				main_scene.ui:tip(typeWZ[result.FmiTypeID][1] .. "纹突破成功！")
			end
		else
			local miInfo = self.getMIInfo(self, self.selIdx)
			local needTuPo = 0

			if miInfo then
				needTuPo = miInfo.FmiNeedTuPo
			end

			if needTuPo == 0 and msgUP[result.FRetCode] then
				main_scene.ui:tip(msgUP[result.FRetCode])
			elseif needTuPo == 1 and msgTuPo[result.FRetCode] then
				main_scene.ui:tip(msgTuPo[result.FRetCode])
			end
		end
	end

	return 
end

return medalImpress
