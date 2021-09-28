local weChatRedPacket = class("weChatRedPacket", function ()
	return display.newNode()
end)
local item = import("..common.item")

table.merge(slot0, {
	selectedChargeBtnIndex = 0,
	selectedBtnIndex = 0,
	tableGradeRP = {},
	tableLoginRP = {},
	tableChargeRP = {},
	tableLuckyRP = {},
	showingTable = {},
	infoCell = {},
	bgCell = {},
	subTable = {}
})

weChatRedPacket.ctor = function (self, btnPageIndex)
	self.tableGradeRP = {}
	self.tableLoginRP = {}
	self.tableChargeRP = {}
	self.tableLuckyRP = {}
	self.showingTable = {}
	self.infoCell = {}
	self.bgCell = {}
	self.subTable = {}
	self._supportMove = true
	self.bg = display.newSprite(res.gettex2("pic/common/black_2.png")):anchor(0, 0):addTo(self)

	self.size(self, self.bg:getw(), self.bg:geth()):anchor(0.5, 0.5):center()
	display.newScale9Sprite(res.getframe2("pic/common/black_5.png"), 0, 0, cc.size(136, 389)):addTo(self.bg):pos(12, 405):anchor(0, 1)

	self.rightFrame = display.newScale9Sprite(res.getframe2("pic/common/black_5.png"), 0, 0, cc.size(470, 389)):addTo(self.bg):pos(156, 405):anchor(0, 1)

	an.newLabel("微信红包", 20, 0, {
		color = def.colors.labelTitle
	}):anchor(0.5, 0.5):pos(self.bg:getw()/2, self.bg:geth() - 23):addTo(self.bg)
	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		self:hidePanel()

		return 
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}).anchor(slot2, 1, 1):pos(self.getw(self) - 9, self.geth(self) - 9):addTo(self)
	self.bindMsg(self)

	local rsbGetInfo = DefaultClientMessage(CM_MicroCGiftSendAll)

	MirTcpClient:getInstance():postRsb(rsbGetInfo)

	local test = {}

	return 
end
weChatRedPacket.bindMsg = function (self)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_MicroCGiftSendAll, self, self.onSM_MicroCGiftSendAll)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_MicroCGiftGetCode, self, self.onSM_MicroCGiftGetCode)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_MicroCGiftSendStarList, self, self.onSM_MicroCGiftSendStarList)

	return 
end
weChatRedPacket.onSM_MicroCGiftSendAll = function (self, result, protoId)
	for i, v in ipairs(result.Fgiftlist) do
		print(i, v.Fgtype, v.Fcurval, v.Fval, v.Fcurval2, v.Fval2)

		if v.Fgtype == 1 then
			self.tableGradeRP[#self.tableGradeRP + 1] = v
		elseif v.Fgtype == 2 then
			self.tableLoginRP[#self.tableLoginRP + 1] = v
		elseif v.Fgtype == 3 or v.Fgtype == 4 then
			self.tableChargeRP[#self.tableChargeRP + 1] = v
		elseif v.Fgtype == 5 then
			self.tableLuckyRP[#self.tableLuckyRP + 1] = v
		end
	end

	local btnPageNames = {}

	if 0 < #self.tableGradeRP then
		btnPageNames[1] = "等级红包"
	end

	if 0 < #self.tableLoginRP then
		btnPageNames[#btnPageNames + 1] = "累计登录"
	end

	if 0 < #self.tableChargeRP then
		btnPageNames[#btnPageNames + 1] = "首充红包"
	end

	if 0 < #self.tableLuckyRP then
		btnPageNames[#btnPageNames + 1] = "普天同庆"
	end

	self.pageBtns = {}

	local function btnPageCB(btn)
		sound.playSound("103")

		for i, v in ipairs(self.pageBtns) do
			if v == btn then
				v.select(v)
			else
				v.unselect(v)
			end
		end

		if btn.btnName ~= self.selectedBtnNames then
			self.selectedBtnNames = btn.btnName

			self:showPageContent(self.selectedBtnNames)
		end

		return 
	end

	for i, v in ipairs(slot3) do
		self.pageBtns[i] = an.newBtn(res.gettex2("pic/common/btn60.png"), btnPageCB, {
			label = {
				btnPageNames[i],
				20,
				0,
				{
					color = def.colors.Cf0c896
				}
			},
			select = {
				res.gettex2("pic/common/btn61.png"),
				manual = true
			}
		}):add2(self.bg):anchor(0, 0.5):pos(26, (i - 1)*54 - 370)
		self.pageBtns[i].btnName = btnPageNames[i]
	end

	if 0 < #self.pageBtns then
		btnPageCB(self.pageBtns[1])
	end

	return 
end
weChatRedPacket.onSM_MicroCGiftGetCode = function (self, result, protoId)
	if result.Fretcode == 1 then
		main_scene.ui:tip("微信红包初始化失败")
	elseif result.Fretcode == 2 then
		main_scene.ui:tip("未正确打开微信红包界面")
	elseif result.Fretcode == 3 then
		main_scene.ui:tip("未达成领取条件")
	elseif result.Fretcode == 4 then
		main_scene.ui:tip("系统繁忙，请耐心等待")
	elseif result.Fretcode == 5 then
		main_scene.ui:tip("兑换码发完了，领取已达上限")
	elseif result.Fretcode == 0 then
		main_scene.ui:tip("领取成功")

		local labelCode = nil

		if self.selectedBtnNames ~= "普天同庆" then
			for i, v in ipairs(self.subTable) do
				if result.Fid == self.subTable[i].Fid then
					self.subTable[i].Fcode = result.Fcode

					self.infoCell[i].getBtn:setVisible(false)
					self.infoCell[i].codeLabel:setVisible(false)
					self.infoCell[i].input:setText(result.Fcode)

					if self.selectedBtnNames == "累计登录" then
						self.infoCell[i].remainingNumLabel:setString(tostring(v.Fmaxcnt - v.Fcurcnt - 1))
					end

					break
				end
			end
		else
			self.btnGetLuckyPrize.label:setString("已领取")

			self.tableLuckyRP[1].Fcode = result.Fcode
		end
	end

	return 
end
weChatRedPacket.onSM_MicroCGiftSendStarList = function (self, result, protoId)
	for i, v in ipairs(result.Fgiftlist) do
		an.newLabel(v.Fname, 20, 0, {
			color = def.colors.text
		}):anchor(0.5, 0.5):pos(110, (i - 1)*25 - 165):addTo(self.scrollStar)
	end

	return 
end
weChatRedPacket.createCell = function (self, showingTable, chargeNum)
	local moneyMin = {}
	local moneyMax = {}
	self.subTable = {}

	if chargeNum == 9800 then
		moneyMin = {
			5,
			10,
			10
		}
		moneyMax = {
			15,
			30,
			30
		}
	elseif chargeNum == 19800 then
		moneyMin = {
			10,
			15,
			15
		}
		moneyMax = {
			30,
			45,
			45
		}
	elseif chargeNum == 29800 then
		moneyMin = {
			15,
			20,
			30
		}
		moneyMax = {
			45,
			60,
			90
		}
	elseif chargeNum == 64800 then
		moneyMin = {
			30,
			40,
			50
		}
		moneyMax = {
			90,
			120,
			150
		}
	end

	if chargeNum ~= nil then
		for i, v in ipairs(showingTable) do
			if chargeNum == v.Fval2 then
				self.subTable[#self.subTable + 1] = v
			end
		end
	elseif self.selectedBtnNames == "累计登录" then
		self.subTable = self.tableLoginRP
	elseif self.selectedBtnNames == "首充红包" then
		self.subTable = self.tableChargeRP
	elseif self.selectedBtnNames == "普天同庆" then
		self.subTable = self.tableLuckyRP
	end

	self.input = {}

	for i, v in ipairs(self.subTable) do
		self.infoCell[i] = {}

		if self.selectedBtnNames == "等级红包" then
			self.bgCell[i] = display.newScale9Sprite(res.getframe2("pic/scale/edit.png"), 0, 0, cc.size(458, 110)):addTo(self.scroll):pos(4, (i - 1)*113 - 95):anchor(0, 0)
		else
			self.bgCell[i] = display.newScale9Sprite(res.getframe2("pic/scale/edit.png"), 0, 0, cc.size(458, 110)):addTo(self.scroll):pos(4, (i - 1)*113 - 127):anchor(0, 0)

			if showingTable == self.tableChargeRP[2] then
				self.bgCell[i]:setPositionY(14)
			end
		end

		if self.selectedBtnNames == "等级红包" or self.selectedBtnNames == "首充红包" then
			an.newLabel("长按聊天框以复制兑换码", 18, 0, {
				color = def.colors.labelGray
			}):anchor(0.5, 0.5):pos(350, 90):addTo(self.bgCell[i])
		elseif self.selectedBtnNames == "累计登录" then
			an.newLabel("剩余:", 16, 0, {
				color = def.colors.text
			}):anchor(0.5, 0.5):pos(390, 90):addTo(self.bgCell[i])

			self.infoCell[i].remainingNumLabel = an.newLabel(tostring(v.Fmaxcnt - v.Fcurcnt), 16, 0, {
				color = cc.c3b(0, 191, 96)
			}):anchor(0.5, 0.5):pos(430, 90):addTo(self.bgCell[i])

			an.newLabel("长按聊天框以复制兑换码", 18, 0, {
				color = def.colors.labelGray
			}):anchor(0.5, 0.5):pos(265, 90):addTo(self.bgCell[i])
		end

		self.bgCell[i]:retain()

		if showingTable == self.tableChargeRP and i == 1 then
			an.newLabel(v.Ftitle .. "(" .. v.Fcurval/100 .. "/" .. v.Fval .. ")", 20, 0, {
				color = def.colors.Cf0c896
			}):anchor(0, 0):pos(8, 80):addTo(self.bgCell[i])
		else
			an.newLabel(v.Ftitle .. "(" .. v.Fcurval .. "/" .. v.Fval .. ")", 20, 0, {
				color = def.colors.Cf0c896
			}):anchor(0, 0):pos(8, 80):addTo(self.bgCell[i])
		end

		an.newLabel(v.Fdesc, 16, 0, {
			color = def.colors.text
		}):anchor(0, 0):pos(8, 55):addTo(self.bgCell[i])

		local bgCode = display.newScale9Sprite(res.getframe2("pic/scale/edit.png"), 0, 0, cc.size(310, 41)):addTo(self.bgCell[i]):pos(8, 8):anchor(0, 0)
		self.infoCell[i].input = an.newInputNew(175, 20, 200, 30, 50, {
			return_call = function ()
				self.infoCell[i].input:setText(v.Fcode)

				return 
			end
		}).anchor(slot12, 0.5, 0.5):addto(bgCode)
		local tipString = ""

		if i <= 3 and self.selectedBtnNames == "等级红包" then
			tipString = "微信红包兑换码(" .. moneyMin[i] .. "-" .. moneyMax[i] .. "元)"
		else
			tipString = "微信红包兑换码(1-100元)"
		end

		self.infoCell[i].codeLabel = an.newLabel(tipString, 16, 0, {
			color = def.colors.text
		}):anchor(0.5, 0.5):pos(150, 21):addTo(bgCode)

		if v.Fcode ~= "" then
			self.infoCell[i].codeLabel:setVisible(false)
			self.infoCell[i].input:setText(v.Fcode)
		end

		local function btnCB(btn)
			sound.playSound("103")

			if v.Fcurval < v.Fval then
				main_scene.ui:tip("未达成领取条件")
			elseif v.Fcode ~= "" then
				main_scene.ui:tip("已领取")
			else
				local rsbGetPrize = DefaultClientMessage(CM_MicroCGiftGetCode)
				rsbGetPrize.Fid = v.Fid

				MirTcpClient:getInstance():postRsb(rsbGetPrize)
			end

			return 
		end

		self.infoCell[i].getBtn = an.newBtn(res.gettex2("pic/common/btn20.png"), slot12, {
			label = {
				"未完成",
				20,
				0,
				{
					color = def.colors.Cf0c896
				}
			},
			pressImage = res.gettex2("pic/common/btn21.png")
		}):addTo(self.bgCell[i]):anchor(0.5, 0.5):pos(390, 28)

		self.infoCell[i].getBtn:retain()

		if self.selectedBtnNames == "累计登录" or self.selectedBtnNames == "首充红包" then
			if v.Fval <= v.Fcurval and v.Fcode == "" then
				self.infoCell[i].getBtn.label:setString("领取")
			elseif v.Fcode ~= "" then
				self.infoCell[i].getBtn:setVisible(false)
			end
		elseif self.selectedBtnNames == "等级红包" then
			if i == 1 then
				print("Fcurval=" .. v.Fcurval .. "Fval=" .. v.Fval)
				print("Fcurval2=" .. v.Fcurval2 .. "Fval2=" .. v.Fval2)
				print("Fcode=" .. v.Fcode)
			end

			if v.Fval <= v.Fcurval and v.Fcurval2 == v.Fval2 and v.Fcode == "" then
				self.infoCell[i].getBtn.label:setString("领取")
			elseif v.Fcode ~= "" then
				self.infoCell[i].getBtn:setVisible(false)
			end
		end
	end

	return 
end
weChatRedPacket.showPageContent = function (self, pageName)
	if self.nodePageContent then
		self.nodePageContent:removeSelf()
	end

	self.nodePageContent = display.newNode():addTo(self.rightFrame)

	self.nodePageContent:size(470, 389):anchor(0, 0):pos(2, 2)

	if pageName ~= "普天同庆" then
		self.scroll = an.newScroll(0, 0, 470, 386):addTo(self.nodePageContent)

		res.get2("pic/panels/activity/everyday.png"):anchor(0, 0):addto(self.scroll):pos(4, 240)

		if pageName == "等级红包" then
			res.get2("pic/panels/weChatRP/gradeRP.png"):anchor(0, 0):addto(self.scroll):pos(20, 285)

			self.showingTable = self.tableGradeRP
			local btnsCharge = {}
			local chargeNums = {
				64800,
				29800,
				19800,
				9800
			}
			local zorder = #chargeNums + 1

			local function btnChargePageCB(btn)
				sound.playSound("103")

				for i, v in ipairs(btnsCharge) do
					if v == btn then
						v.select(v)
						v.setLocalZOrder(v, zorder)
					else
						v.unselect(v)
						v.setLocalZOrder(v, zorder - i)
					end
				end

				if btn.btnIndex ~= self.selectedChargeBtnIndex then
					self.selectedChargeBtnIndex = btn.btnIndex

					for i, v in ipairs(self.bgCell) do
						v.removeSelf(v)
					end

					self:createCell(self.showingTable, chargeNums[btn.btnIndex])
				end

				return 
			end

			local chargeTexts = {
				"单笔充648",
				"单笔充298",
				"单笔充198",
				"单笔充98"
			}

			for i, v in ipairs(slot6) do
				btnsCharge[i] = an.newBtn(res.gettex2("pic/panels/weChatRP/btnUnselect.png"), btnChargePageCB, {
					label = {
						chargeTexts[i],
						20,
						0,
						{
							color = def.colors.Cf0c896
						}
					},
					select = {
						res.gettex2("pic/panels/weChatRP/btnSelect.png"),
						manual = true
					}
				}):add2(self.scroll):anchor(0.5, 0.5):pos((i - 1)*106 - 395, 223)
				btnsCharge[i].btnIndex = i

				btnsCharge[i].label:pos(50, 15)
			end

			for i, v in ipairs(chargeNums) do
				for m, n in ipairs(self.showingTable) do
					if v == n.Fcurval2 then
						res.get2("pic/panels/weChatRP/click.png"):anchor(0, 0):addto(btnsCharge[i]):pos(95, 3)
					end
				end
			end

			btnChargePageCB(btnsCharge[4])
		elseif pageName == "累计登录" then
			self.selectedChargeBtnIndex = 0

			res.get2("pic/panels/weChatRP/loginRP.png"):anchor(0, 0):addto(self.scroll):pos(20, 285)

			self.showingTable = self.tableLoginRP

			self.createCell(self, self.tableLoginRP, nil)
		elseif pageName == "首充红包" then
			self.selectedChargeBtnIndex = 0

			res.get2("pic/panels/weChatRP/chargeRP.png"):anchor(0, 0):addto(self.scroll):pos(20, 285)

			self.showingTable = self.tableChargeRP

			self.createCell(self, self.tableChargeRP, nil)
		end

		local beginTime = self.showingTable[1].Fopenfrom
		local endTime = self.showingTable[1].Fopento
		local activityTime = "活动时间:" .. os.date("%m-%d %H:%M", beginTime) .. " 至 " .. os.date("%m-%d %H:%M", endTime)

		an.newLabel(activityTime, 20, 0, {
			color = def.colors.text
		}):pos(185, 260):addTo(self.scroll):anchor(0.5, 0.5)

		local function helpBtnCB()
			sound.playSound("103")

			local texts = {}

			if pageName == "等级红包" then
				texts[1] = {
					"1.活动时间内单次充值达到对应档次并且达到指定等级即可获得微信红包兑换码奖励。\n"
				}
			elseif pageName == "累计登录" then
				texts[1] = {
					"1.活动时间内累积登录指定天数即可获得微信红包兑换码奖励。\n"
				}
			elseif pageName == "首充红包" then
				texts[1] = {
					"1.活动时间内任意充值即可获得微信红包兑换码奖励。\n"
				}
			end

			texts[2] = {
				"2.点击领取后显示微信红包兑换码。\n"
			}
			texts[3] = {
				"3.长按或点击激活码可复制激活码。\n"
			}
			texts[4] = {
				"4.激活码可至“fgcq39”微信公众号中使用。\n"
			}
			local msgbox = an.newMsgbox(texts)

			return 
		end

		an.newBtn(res.gettex2("pic/common/question.png"), slot5, {
			pressBig = true,
			pressImage = res.gettex2("pic/common/question.png")
		}):pos(435, 355):addTo(self.scroll)
	elseif pageName == "普天同庆" then
		self.selectedChargeBtnIndex = 0

		display.newScale9Sprite(res.getframe2("pic/common/black_5.png"), 0, 0, cc.size(450, 140)):addTo(self.nodePageContent):pos(10, 10):anchor(0, 0)
		res.get2("pic/panels/weChatRP/luckyRP.png"):anchor(0, 0):addto(self.nodePageContent):pos(0, 0)

		local bgIntroduction = display.newScale9Sprite(res.getframe2("pic/common/black_5.png"), 0, 0, cc.size(220, 210)):addTo(self.nodePageContent):pos(10, 10):anchor(0, 0)
		local text1 = "1.活动期间单笔充值"
		local text2 = "648 "
		local text3 = "元宝"
		local text4 = [[
，即可领取以上奖励及绝版称
号(限1次)。
2.同时，全服玩家会收到一封
微信红包兑换码邮件，每个兑
换码仅限前100名玩家领取。
(每人仅触发一次)
3.领取方式:关注"fgcq39"微信
公众号，输入兑换码即可领取
红包。]]

		an.newLabel(text1, 16, 0, {
			color = def.colors.text
		}):anchor(0, 0):pos(5, 188):addTo(bgIntroduction)
		an.newLabel(text2, 16, 0, {
			color = def.colors.labelYellow
		}):anchor(0, 0):pos(148, 188):addTo(bgIntroduction)
		an.newLabel(text3, 16, 0, {
			color = def.colors.text
		}):anchor(0, 0):pos(175, 188):addTo(bgIntroduction)
		an.newLabel(text4, 16, 0, {
			color = def.colors.text
		}):anchor(0, 0):pos(5, 1):addTo(bgIntroduction)

		local bgStar = display.newScale9Sprite(res.getframe2("pic/common/black_5.png"), 0, 0, cc.size(220, 210)):addTo(self.nodePageContent):pos(237, 10):anchor(0, 0)
		self.scrollStar = an.newScroll(0, 0, 220, 210):addTo(bgStar)

		res.get2("pic/panels/weChatRP/starTop.png"):anchor(0.5, 0.5):addto(self.scrollStar):pos(105, 193)
		self.scrollStar:retain()

		local rsbGetStarList = DefaultClientMessage(CM_MicroCGiftSendStarList)

		MirTcpClient:getInstance():postRsb(rsbGetStarList)

		if self.tableLuckyRP[1].Fgetawards and self.tableLuckyRP[1].Fgetawards ~= "" and self.tableLuckyRP[1].Fgetawards ~= "0" then
			local awards = string.split(self.tableLuckyRP[1].Fgetawards, "/")

			for i, v in ipairs(awards) do
				local value = string.split(v, "|")

				if value[1] ~= "称号:闪耀之星" then
					local awardFrame = res.get2("pic/panels/shop/frame.png"):anchor(0, 0):pos((i - 1)*75 + 25, 225):add2(self.nodePageContent)

					for index, stditem in ipairs(_G.def.items) do
						if stditem.name == value[1] then
							local baseItem = {
								FIndex = index
							}

							if 150 < stditem.stdMode then
								baseItem.FDura = value[2]
							else
								baseItem.FDura = stditem.duraMax
							end

							baseItem.FDuraMax = stditem.duraMax
							baseItem.FItemValueList = {}
							baseItem.FItemIdent = 1

							setmetatable(baseItem, {
								__index = gItemOp
							})
							baseItem.decodedCallback(baseItem)
							item.new(baseItem, self, {
								donotMove = true
							}):addTo(awardFrame):anchor(0.5, 0.5):pos(39, 35)

							if not baseItem.isPileUp(baseItem) and value[2] and 1 < tonumber(value[2]) then
								an.newLabel(value[2], 12, 1, {
									color = cc.c3b(0, 255, 0)
								}):anchor(1, 0):pos(60, 10):add2(awardFrame)
							end

							break
						end
					end
				end
			end
		end

		local function btnGetPrizeCB(btn)
			if self.tableLuckyRP[1].Fcode ~= "" then
				main_scene.ui:tip("已领取")
			elseif self.tableLuckyRP[1].Fval <= self.tableLuckyRP[1].Fcurval then
				local rsbGetPrize = DefaultClientMessage(CM_MicroCGiftGetCode)
				rsbGetPrize.Fid = self.tableLuckyRP[1].Fid

				MirTcpClient:getInstance():postRsb(rsbGetPrize)
			else
				main_scene.ui:tip("未达成领取条件")
			end

			return 
		end

		self.btnGetLuckyPrize = an.newBtn(res.gettex2("pic/common/btn20.png"), slot9, {
			label = {
				"未完成",
				20,
				0,
				{
					color = def.colors.Cf0c896
				}
			},
			pressImage = res.gettex2("pic/common/btn21.png")
		}):addTo(self.nodePageContent):anchor(0.5, 0.5):pos(386, 260)

		if self.tableLuckyRP[1].Fval <= self.tableLuckyRP[1].Fcurval and self.tableLuckyRP[1].Fcode == "" then
			self.btnGetLuckyPrize.label:setString("领取")
		elseif self.tableLuckyRP[1].Fcode ~= "" then
			self.btnGetLuckyPrize.label:setString("已领取")
		end

		self.btnGetLuckyPrize:retain()
	end

	return 
end

return weChatRedPacket
