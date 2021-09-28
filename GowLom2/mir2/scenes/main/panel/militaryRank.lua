local militaryRank = class("militaryRank", function ()
	return display.newNode()
end)

local function tip(tipstr)
	main_scene.ui:tip(tipstr, 6)

	return 
end

militaryRank.ctor = function (self)
	self.pageBtns = {}
	self.FMilitaryRankLv = 0
	self._supportMove = true
	self.bg = display.newSprite(res.gettex2("pic/panels/drumUpgrade/bg.png")):anchor(0, 0):addTo(self)

	self.size(self, self.bg:getw(), self.bg:geth()):anchor(0.5, 0.5):center()
	display.newScale9Sprite(res.getframe2("pic/common/black_4.png"), 0, 0, cc.size(340, 395)):pos(self.bg:getw()/2, self.bg:geth() - 55):addTo(self.bg):anchor(0.5, 1)
	an.newLabel("军衔升级", 20, 0, {
		color = def.colors.labelTitle
	}):anchor(0.5, 0.5):pos(self.bg:getw()/2, self.bg:geth() - 27):addTo(self.bg)
	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		self:hidePanel()
		main_scene.ui:hidePanel("militaryRankPreview")

		return 
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}).anchor(slot1, 1, 1):pos(self.getw(self) - 9, self.geth(self) - 9):addTo(self)

	local btnLabelNames = {
		"升\n级"
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

	for i, v in ipairs(slot1) do
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

	btnPageCB(self.pageBtns[1])
	display.newSprite(res.gettex2("pic/panels/wingUpgrade/button_search.png")):anchor(0.5, 0.5):pos(260, 50):add2(self.bg)

	local label = an.newLabel("军衔预览", 20, nil, {
		color = cc.c3b(240, 200, 150)
	}):addTo(self.bg):pos(280, 50):anchor(0, 0.5)

	label.addUnderline(label)
	label.setTouchEnabled(label, true)
	label.setTouchSwallowEnabled(label, false)
	label.addNodeEventListener(label, cc.NODE_TOUCH_EVENT, function (event)
		local touchInBtn = label:getCascadeBoundingBox():containsPoint(cc.p(event.x, event.y))

		if event.name == "began" then
			label:scale(1.1, 1.1)

			return true
		elseif event.name == "ended" then
			label:scale(1, 1)
			main_scene.ui:togglePanel("militaryRankPreview", {
				level = self.FMilitaryRankLv
			})
		end

		return 
	end)
	MirTcpClient.getInstance(slot4):subscribeMemberOnProtocol(SM_UpDateMilitaryRank, self, self.onSM_UpDateMilitaryRank)

	return 
end
militaryRank.showPageInfo = function (self, selectedBtnIndex)
	if selectedBtnIndex == 1 then
		if self.nodePageContent then
			self.nodePageContent:removeSelf()

			self.nodePageContent = nil
		end

		self.nodePageContent = display.newNode():addTo(self.bg)

		self.nodePageContent:size(self.bg:getw(), self.bg:geth()):anchor(0, 0):pos(0, 0)

		local function btnUpgradeCB()
			sound.playSound("103")

			local rsb = DefaultClientMessage(CM_UpDateMilitaryRank)

			MirTcpClient:getInstance():postRsb(rsb)

			return 
		end

		an.newBtn(res.gettex2("pic/common/btn20.png"), slot2, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			label = {
				"升级",
				18,
				0,
				{
					color = def.colors.Cf0c896
				}
			}
		}):pos(self.bg:getw()/2, 54):addTo(self.nodePageContent)
		self.updateUpgradeView(self)
	end

	return 
end
militaryRank.onSM_UpDateMilitaryRank = function (self, result)
	if not result then
		return 
	end

	local errList = {
		[-3.0] = "军功不足",
		[-1.0] = "军衔等级最高",
		[-2.0] = "角色等级不足",
		[-4.0] = "服务器等级不足"
	}

	if result.FBackValue ~= 0 then
		return 
	end

	self.updateUpgradeView(self)

	return 
end
militaryRank.updateUpgradeView = function (self)
	if self.nodeContent then
		self.nodeContent:removeSelf()

		self.nodeContent = nil
	end

	local function getProperty(rank)
		local propertyStr = def.militaryRank.getMilitaryPropertyByRank(rank).PropertyStr
		local job = g_data.player.job
		local props = def.property.dumpPropertyStr("")
		local tmpProps = def.property.dumpPropertyStr(propertyStr)

		props.mergeProp(props, tmpProps)
		props.clearZero(props):toStdProp():grepJob(job)

		return props.props
	end

	self.nodeContent = display.newNode().addTo(slot2, self.nodePageContent)

	self.nodeContent:size(self.bg:getw(), self.bg:geth()):anchor(0, 0):pos(0, 0)
	res.get2("pic/panels/drumUpgrade/arrow.png"):addTo(self.nodeContent):pos(195, 380)
	res.get2("pic/panels/militaryRank/titleBg.png"):addTo(self.nodeContent):pos(100, 380):scale(0.5)
	res.get2("pic/panels/militaryRank/titleBg.png"):addTo(self.nodeContent):pos(295, 380):scale(0.5)

	local rank = g_data.player.militaryRank
	local militaryRank = def.militaryRank.getMilitaryPropertyByRank(rank + 1)
	local MilitaryRankName2 = militaryRank.MilitaryRankName
	local isFullLevel = rank == militaryRank.MilitaryRankLv
	local leftNode = display.newNode():addTo(self.nodeContent):pos(10, 60)

	display.newScale9Sprite(res.getframe2("pic/panels/drumUpgrade/bgProperty.png"), 0, 0, cc.size(150, 165)):anchor(0, 0):add2(leftNode):pos(25, 130)
	res.get2("pic/panels/drumUpgrade/tip.png"):addTo(leftNode):pos(50, 275)
	an.newLabel("当前属性", 18, 0, {
		color = def.colors.Cf0c896
	}):anchor(0.5, 0.5):pos(96, 275):addTo(leftNode)
	res.get2("pic/panels/drumUpgrade/tip.png"):addTo(leftNode):pos(140, 275)

	local xpos = 40
	local ypos = 275

	if rank == 0 then
		an.newLabel("无", 20, 0, {
			color = def.militaryRank.getColorByRank(0)
		}):anchor(0.5, 0.5):pos(100, 380):addTo(self.nodeContent)
		an.newLabel("暂无属性", 18, 0, {
			color = def.colors.Cf0c896
		}):anchor(0.5, 0.5):pos(96, 200):addTo(leftNode)
	else
		local MilitaryRankName = def.militaryRank.getMilitaryPropertyByRank(rank).MilitaryRankName

		an.newLabel(MilitaryRankName, 20, 0, {
			color = def.militaryRank.getColorByRank(rank)
		}):anchor(0.5, 0.5):pos(90, 380):addTo(self.nodeContent)

		for i, k in ipairs(getProperty(rank)) do
			local property = (k[3] ~= nil and k[2] .. "-" .. k[3]) or "+" .. k[2]

			an.newLabel(k[1] .. ":", 18, 0, {
				color = def.colors.Cf0c896
			}):anchor(0.5, 0.5):pos(xpos, ypos - i*25):addTo(leftNode):anchor(0, 0.5)
			an.newLabel(property, 18, 0, {
				color = def.colors.Cdcd2be
			}):anchor(0.5, 0.5):pos(xpos + 80, ypos - i*25):addTo(leftNode):anchor(0, 0.5)
		end
	end

	local rightNode = display.newNode():addTo(self.nodeContent):pos(10, 60)

	display.newScale9Sprite(res.getframe2("pic/panels/drumUpgrade/bgProperty.png"), 0, 0, cc.size(150, 165)):anchor(0, 0):add2(rightNode):pos(195, 130)
	res.get2("pic/panels/drumUpgrade/tip.png"):addTo(rightNode):pos(220, 275)
	an.newLabel("升级属性", 18, 0, {
		color = def.colors.Cf0c896
	}):anchor(0.5, 0.5):pos(266, 275):addTo(rightNode)
	res.get2("pic/panels/drumUpgrade/tip.png"):addTo(rightNode):pos(310, 275)

	local xpos = 210
	local ypos = 275

	if isFullLevel then
		an.newLabel("军衔等级已满", 20, 0, {
			color = def.militaryRank.getColorByRank(rank + 1)
		}):anchor(0.5, 0.5):pos(295, 380):addTo(self.nodeContent)
		an.newLabel("军衔等级已满", 18, 0, {
			color = def.colors.Cf0c896
		}):anchor(0.5, 0.5):pos(266, 200):addTo(rightNode)
	else
		an.newLabel(MilitaryRankName2, 20, 0, {
			color = def.militaryRank.getColorByRank(rank + 1)
		}):anchor(0.5, 0.5):pos(295, 380):addTo(self.nodeContent)

		for i, k in ipairs(getProperty(rank + 1)) do
			local property = (k[3] ~= nil and k[2] .. "-" .. k[3]) or "+" .. k[2]

			an.newLabel(k[1] .. ":", 18, 0, {
				color = def.colors.Cf0c896
			}):anchor(0.5, 0.5):pos(xpos, ypos - i*25):addTo(rightNode):anchor(0, 0.5)
			an.newLabel(property, 18, 0, {
				color = def.colors.Cdcd2be
			}):anchor(0.5, 0.5):pos(xpos + 80, ypos - i*25):addTo(rightNode):anchor(0, 0.5)
		end
	end

	local xpos = 40
	local ypos = 190
	local serverState = common.numToUpperNum(g_data.client.serverState) .. "阶"
	local level = common.getLevelText(g_data.player.ability.FLevel) .. "级"
	local jungong = g_data.player.ability.FJunGongValue

	an.newLabel("当前等级:", 16, 0, {
		color = def.colors.Cf0c896
	}):anchor(0.5, 0.5):pos(xpos, ypos - 25):addTo(self.nodeContent):anchor(0, 0.5)
	an.newLabel(level, 16, 0, {
		color = def.colors.Cdcd2be
	}):anchor(0.5, 0.5):pos(xpos + 90, ypos - 25):addTo(self.nodeContent):anchor(0, 0.5)
	an.newLabel("服务器阶段:", 16, 0, {
		color = def.colors.Cf0c896
	}):anchor(0.5, 0.5):pos(xpos, ypos - 50):addTo(self.nodeContent):anchor(0, 0.5)
	an.newLabel(serverState, 16, 0, {
		color = def.colors.Cdcd2be
	}):anchor(0.5, 0.5):pos(xpos + 90, ypos - 50):addTo(self.nodeContent):anchor(0, 0.5)
	an.newLabel("当前军功:", 16, 0, {
		color = def.colors.Cf0c896
	}):anchor(0.5, 0.5):pos(xpos, ypos - 75):addTo(self.nodeContent):anchor(0, 0.5)
	an.newLabel(jungong, 16, 0, {
		color = def.colors.Cdcd2be
	}):anchor(0.5, 0.5):pos(xpos + 90, ypos - 75):addTo(self.nodeContent):anchor(0, 0.5)

	local xpos = 200
	local ypos = 190
	local military = def.militaryRank.getMilitaryPropertyByRank(rank + 1)
	local serverState = common.numToUpperNum(military.UpNeedServerStep) .. "阶"
	local level = common.getLevelText(military.UpNeedPlayerLevel) .. "级"
	local jungong = military.UpNeedJunGongNum

	if isFullLevel then
		level = "无"
		serverState = "无"
		jungong = "无"
	end

	an.newLabel("所需等级:", 16, 0, {
		color = def.colors.Cf0c896
	}):anchor(0.5, 0.5):pos(xpos, ypos - 25):addTo(self.nodeContent):anchor(0, 0.5)
	an.newLabel(level, 16, 0, {
		color = def.colors.Cdcd2be
	}):anchor(0.5, 0.5):pos(xpos + 90, ypos - 25):addTo(self.nodeContent):anchor(0, 0.5)
	an.newLabel("服务器阶段:", 16, 0, {
		color = def.colors.Cf0c896
	}):anchor(0.5, 0.5):pos(xpos, ypos - 50):addTo(self.nodeContent):anchor(0, 0.5)
	an.newLabel(serverState, 16, 0, {
		color = def.colors.Cdcd2be
	}):anchor(0.5, 0.5):pos(xpos + 90, ypos - 50):addTo(self.nodeContent):anchor(0, 0.5)
	an.newLabel("所需军功:", 16, 0, {
		color = def.colors.Cf0c896
	}):anchor(0.5, 0.5):pos(xpos, ypos - 75):addTo(self.nodeContent):anchor(0, 0.5)
	an.newLabel(jungong, 16, 0, {
		color = def.colors.Cdcd2be
	}):anchor(0.5, 0.5):pos(xpos + 90, ypos - 75):addTo(self.nodeContent):anchor(0, 0.5)
	res.get2("pic/panels/drumUpgrade/line.png"):addTo(self.nodeContent):pos(self.bg:getw()/2, 90):anchor(0.5, 0.5):scaleX(0.7)

	return 
end

return militaryRank
