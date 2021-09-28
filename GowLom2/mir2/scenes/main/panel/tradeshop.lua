local common = import("..common.common")
local item = import("..common.item")
local tradeshop = class("tradeshop", function ()
	return display.newNode()
end)
local shopData = g_data.tradeshop

table.merge(slot2, {
	goodKind = 255,
	tab1Index = 1,
	money = 0,
	maxItemNum = 10,
	UITEXT = "",
	lastKey = "",
	sellingCells = {},
	itemCells = {},
	pickCells = {}
})

tradeshop.ctor = function (self, params)
	self._supportMove = true
	self.money = params.type

	if params.type == 0 then
		self.UITEXT = "元宝"
		self.UNITTEXT = "元宝"
	else
		self.UITEXT = "金币"
		self.UNITTEXT = "万金币"
	end

	display.newSprite(res.gettex2("pic/common/black_2.png")):anchor(0, 0):add2(self)

	self.bg = display.newNode():size(625, 400):add2(self)

	self.bg:setTouchSwallowEnabled(true)
	self.size(self, 641, 455):anchor(0.5, 0.5):center()

	shopData = g_data.tradeshop

	an.newLabel(self.UITEXT .. "交易行", 22, 0, {
		color = def.colors.labelTitle
	}):anchor(0.5, 0.5):pos(self.getw(self)*0.5, self.geth(self) - 22):add2(self, 2)
	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		self:hidePanel()

		return 
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}).anchor(slot2, 1, 1):pos(self.getw(self) - 9, self.geth(self) - 9):addto(self, 2)

	local tutorials = {
		{
			{
				"\n1. 每个准点更新交易行所出售的商品",
				def.colors.Cdcd2be
			},
			{
				"\n2. 使用搜索框或点击分类按钮可快速找到想要的商品。",
				def.colors.Cdcd2be
			},
			{
				"\n3. 购买成功的物品在”领取物品”标签下。",
				def.colors.Cdcd2be
			},
			{
				"\n4. 信用分未验证用户在金币交易行不可购买。",
				def.colors.Cdcd2be
			}
		},
		{
			{
				"\n1. 绑定物品及部分非绑定物品无法上架。",
				def.colors.Cdcd2be
			},
			{
				"\n2. 出售物品需要扣除一定数量的金币作为手续费。",
				def.colors.Cdcd2be
			}
		},
		{
			{
				"\n1. 所有自己出售的商品均显示在“正在出售”页签下。 ",
				def.colors.Cdcd2be
			},
			{
				"\n2. 成功下架的商品会显示在“领取物品”页签。",
				def.colors.Cdcd2be
			},
			{
				"\n3. “正在出售”页签下的商品多于5件时会影响商品的正常上架",
				def.colors.Cdcd2be
			}
		},
		{
			{
				"\n1. 所有已购买、已出售、已下架、已退回的商品均显示在“领取物品”页签下。",
				def.colors.Cdcd2be
			},
			{
				"\n2. “领取物品”页签下的商品数量多于5件时会影响商品的正常上架及购买，请及时领取。",
				def.colors.Cdcd2be
			},
			{
				"\n3. 领取\"已出售\"的订单将获得相应的货币，需扣除交易税（优先扣除银锭）。",
				def.colors.Cdcd2be
			},
			{
				"\n4. 验证用户的元宝交易税为3%，金币交易税为5%。 非验证用户的元宝交易税为30%，金币交易税为30%。",
				def.colors.Cdcd2be
			}
		}
	}

	an.newBtn(res.gettex2("pic/common/question.png"), function ()
		an.newMsgbox(tutorials[self.tab1Index], nil, {
			btnTexts = {
				"确  定",
				"取  消"
			}
		})

		return 
	end, {
		pressImage = res.gettex2("pic/common/question.png"),
		label = {
			"",
			20,
			0,
			{
				color = cc.c3b(240, 200, 150)
			}
		}
	}).add2(slot3, self):anchor(0, 0.5):pos(10, self.geth(self) - 22)

	local tabInfo = {
		[[
我
要
购
买]],
		[[
我
要
出
售]],
		[[
正
在
出
售]],
		[[
领
取
物
品]]
	}

	common.tabs(self, {
		ox = 4,
		size = 16,
		strokeSize = 1,
		oy = 8,
		strs = tabInfo,
		lc = {
			normal = def.colors.Ca6a197,
			select = def.colors.Cf0c896
		}
	}, function (idx, btn)
		self.tab1Index = idx

		self.bg:removeAllChildren()

		if idx == 1 then
			if g_data.client:checkLastTime("shopList" .. tostring(self.money), 3) then
				g_data.client:setLastTime("shopList" .. tostring(self.money), true)

				local rsb = DefaultClientMessage(CM_TradeBankGoodList)
				rsb.FBankType = self.money
				rsb.FGoodType = 0
				rsb.FGoodIndex = 0
				rsb.FGoodKind = 255
				rsb.FBoInc = false

				MirTcpClient:getInstance():postRsb(rsb)
				self:shopList()
			elseif shopData.tradeType == self.money then
				self:shopList()
			end
		elseif idx == 2 then
			self:addGoods()
		elseif idx == 3 then
			if g_data.client:checkLastTime("sellingOut" .. tostring(self.money), 3) then
				g_data.client:setLastTime("sellingOut" .. tostring(self.money), true)

				local rsb = DefaultClientMessage(CM_TradeBankGoodList)
				rsb.FBankType = self.money
				rsb.FGoodType = 1
				rsb.FBoInc = false

				MirTcpClient:getInstance():postRsb(rsb)
			else
				self:sellingOut()
			end
		elseif idx == 4 then
			if g_data.client:checkLastTime("pickUp" .. tostring(self.money), 3) then
				g_data.client:setLastTime("pickUp" .. tostring(self.money), true)

				local rsb = DefaultClientMessage(CM_TradeBankGoodList)
				rsb.FBankType = self.money
				rsb.FGoodType = 2

				MirTcpClient:getInstance():postRsb(rsb)
			else
				self:pickUp()
			end
		end

		return 
	end, {
		tabTp = 3,
		pos = {
			offset = 100,
			x = 0,
			y = self.bg.geth(slot10) + 30,
			anchor = cc.p(1, 1)
		},
		default = {
			var = params.default
		}
	})
	self.bingMsg(self)

	local rsb = DefaultClientMessage(CM_TradeBankFetchTip)
	rsb.FBankType = self.money

	MirTcpClient:getInstance():postRsb(rsb)

	if not shopData.config and not shopData.chargeConfig then
		local rsb = DefaultClientMessage(CM_TradeBankReqConfig)

		MirTcpClient:getInstance():postRsb(rsb)
	end

	self.tips = res.get2("pic/common/button_click02.png"):addTo(self, 2):anchor(0, 1):pos(-30, 120)

	self.tips:hide()
	g_data.eventDispatcher:addListener("M_POINTTIP", self, self.onPointTip)
	self.onPointTip(self, "trade" .. params.type, g_data.pointTip:isVisible("trade" .. params.type))

	return 
end
tradeshop.bingMsg = function (self)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_TradeBankGoodList, self, self.onSM_TradeBankGoodList)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_TradeBankOp, self, self.onSM_TradeBankOp)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_TradeBankConfig, self, self.onSM_TradeBankConfig)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_TradeBankServiceChargeList, self, self.onSM_TradeBankServiceChargeList)

	return 
end
tradeshop.onSM_TradeBankConfig = function (self, result, protoId)
	if result then
		shopData:initConfig(result)
	end

	return 
end
tradeshop.onSM_TradeBankServiceChargeList = function (self, result, protoId)
	if result then
		shopData.chargeConfig = result.FConfigList
	end

	return 
end
tradeshop.onSM_TradeBankGoodList = function (self, result, protoId)
	if result and result.FBankType == self.money then
		if result.FGoodType == 0 then
			shopData:setTradeInfo(result)

			if self.tab1Index == 1 then
				if result.FGoodIndex == 0 then
					self.resetScrollView()
					self.refreshItemInfo()
				else
					self.refreshItemInfo()
				end
			end
		elseif result.FGoodType == 1 then
			self.bg:removeAllChildren()
			shopData:setSellingList(result)
			self.sellingOut(self)
		elseif result.FGoodType == 2 then
			self.bg:removeAllChildren()
			shopData:setPickList(result)
			self.pickUp(self)
		end
	end

	return 
end
tradeshop.onPointTip = function (self, type, visible)
	if string.find(type, "trade") then
		if visible then
			self.tips:show()
		else
			self.tips:hide()
		end
	end

	return 
end

local function deleteScrollViewItem(viewList, id, delFunc)
	local index = 1
	local delCellPos = nil

	while viewList[index] do
		local cell = viewList[index]

		if not cell then
			return 
		end

		if delCellPos then
			local old = cc.p(cell.getPosition(cell))

			cell.setPosition(cell, delCellPos.x, delCellPos.y)

			delCellPos = old
		end

		if cell.data and cell.data.FOrderID == id then
			delCellPos = cc.p(cell.getPosition(cell))

			cell.removeSelf(cell)
			table.remove(viewList, index)
			delFunc(id)
		else
			index = index + 1
		end
	end

	return 
end

tradeshop.onSM_TradeBankOp = function (self, result, protoId)
	if result then
		if result.FOpType == 0 then
			shopData.tradeCount = shopData.tradeCount - 1

			shopData:delItem(result.FOrderID, self.goodKind)
			self.resetScrollView()
			self.refreshItemInfo()
		elseif result.FOpType == 1 then
			deleteScrollViewItem(self.sellingCells, result.FOrderID, function (id)
				shopData:delSellingItem(id)

				return 
			end)

			if not tolua.isnull(self.sellOutCountLbl) then
				self.sellOutCountLbl.setText(slot3, tostring(#shopData.sellingList))
			end
		elseif result.FOpType == 2 then
			deleteScrollViewItem(self.pickCells, result.FOrderID, function (id)
				shopData:delPickItem(id)

				return 
			end)

			if not tolua.isnull(self.pickCountLbl) then
				self.pickCountLbl.setText(slot3, tostring(#shopData.pickList))
			end
		elseif result.FOpType == 3 then
			main_scene.ui.waiting:close("tradeshop_wating")
			self.bg:removeAllChildren()
			self.addGoods(self)
		end
	end

	return 
end
tradeshop.ckeckInSafeZone = function (self)
	if g_data.map:isInSafeZone(main_scene.ground.map.mapid, main_scene.ground.player.x, main_scene.ground.player.y) then
		return true
	end

	return 
end
tradeshop.shopList = function (self)
	self.leftPanel = display.newScale9Sprite(res.getframe2("pic/common/black_5.png"), 0, 0, cc.size(127, 342)):addTo(self.bg):pos(12, 405):anchor(0, 1)
	self.rightPanel = display.newScale9Sprite(res.getframe2("pic/common/black_5.png"), 0, 0, cc.size(480, 342)):addTo(self.bg):pos(145, 405):anchor(0, 1)
	self.goodKind = 255
	local texts = {
		"全 部",
		"武器类",
		"首饰类",
		"防具类",
		"服饰类",
		"书籍类",
		"药品类",
		"其 他"
	}
	local tabs = {}
	local curData, filterInput = nil

	local function click(btn)
		sound.playSound("103")

		for i, v in ipairs(tabs) do
			if v == btn then
				v.select(v)
			else
				v.unselect(v)
			end

			if btn.index ~= self.tabIndex then
				self.tabIndex = btn.index

				if self.tabIndex == 1 then
					self.goodKind = 255
				elseif self.tabIndex == 2 then
					self.goodKind = 0
				elseif self.tabIndex == 3 then
					self.goodKind = 1
				elseif self.tabIndex == 4 then
					self.goodKind = 2
				elseif self.tabIndex == 5 then
					self.goodKind = 3
				elseif self.tabIndex == 6 then
					self.goodKind = 4
				elseif self.tabIndex == 7 then
					self.goodKind = 5
				elseif self.tabIndex == 8 then
					self.goodKind = 6
				end

				if g_data.client:checkLastTime("tradetab" .. tostring(self.tabIndex), 2) then
					g_data.client:setLastTime("tradetab" .. tostring(self.tabIndex), true)

					self.priceOrder = false
					local rsb = DefaultClientMessage(CM_TradeBankGoodList)
					rsb.FBankType = self.money
					rsb.FGoodType = 0
					rsb.FGoodIndex = 0
					rsb.FGoodKind = self.goodKind
					rsb.FBoInc = self.priceOrder

					MirTcpClient:getInstance():postRsb(rsb)
				else
					self.resetScrollView()
					self.refreshItemInfo()
				end

				filterInput:setText("")
			end
		end

		return 
	end

	local infoViewL = an.newScroll(4, 4, 127, 340).add2(slot6, self.leftPanel)
	local hl = 55

	infoViewL.setScrollSize(infoViewL, 127, math.max(340, #texts*hl))

	for i, v in ipairs(texts) do
		tabs[i] = an.newBtn(res.gettex2("pic/common/btn60.png"), click, {
			support = "scroll",
			anchor = {
				0.5,
				0.5
			},
			label = {
				v,
				20,
				0,
				{
					color = def.colors.btn
				}
			},
			select = {
				res.gettex2("pic/common/btn61.png"),
				manual = true
			}
		}):add2(infoViewL):anchor(0, 0.5):pos(5, (i - 1)*50 - 405)
		tabs[i].index = i
	end

	local orderPicDown = display.newSprite(res.getframe2("pic/panels/guild/downarrow.png"), 0, 0):anchor(0, 0):add2(self.rightPanel, 2):pos(425, self.rightPanel:geth() - 35)
	local orderPicUp = display.newSprite(res.getframe2("pic/panels/guild/downarrow.png"), 0, 0):anchor(0, 0):add2(self.rightPanel, 2):pos(447, self.rightPanel:geth() - 18):rotation(180)

	orderPicUp.setVisible(orderPicUp, false)

	local titlebg = display.newScale9Sprite(res.getframe2("pic/panels/guild/titlebg.png"), 0, 0, cc.size(474, 42)):anchor(0, 0):pos(4, self.rightPanel:geth() - 44):add2(self.rightPanel)

	display.newScale9Sprite(res.getframe2("pic/panels/guild/split.png"), 0, 0, cc.size(4, 42)):anchor(0, 0):pos(200, 0):add2(titlebg)
	display.newScale9Sprite(res.getframe2("pic/panels/guild/split.png"), 0, 0, cc.size(4, 42)):anchor(0, 0):pos(340, 0):add2(titlebg)
	an.newLabel("物品名称", 20, 0, {
		color = def.colors.labelTitle
	}):anchor(0.5, 0.5):pos(100, self.rightPanel:geth() - 23):add2(self.rightPanel, 2)
	an.newLabel("剩余时间", 20, 0, {
		color = def.colors.labelTitle
	}):anchor(0.5, 0.5):pos(270, self.rightPanel:geth() - 23):add2(self.rightPanel, 2)

	self.priceOrder = false

	an.newLabel("价格", 20, 0, {
		color = def.colors.labelTitle
	}):anchor(0.5, 0.5):pos(405, self.rightPanel:geth() - 23):add2(self.rightPanel, 2)
	display.newNode():size(133, 40):pos(340, 0):add2(titlebg):enableClick(function ()
		self.priceOrder = not self.priceOrder
		local rsb = DefaultClientMessage(CM_TradeBankGoodList)
		rsb.FBankType = self.money
		rsb.FGoodType = 0
		rsb.FGoodIndex = 0
		rsb.FGoodKind = self.goodKind
		rsb.FBoInc = self.priceOrder
		rsb.FItemName = self.lastKey

		MirTcpClient:getInstance():postRsb(rsb)

		return 
	end)

	local infoView = an.newScroll(4, 4, 480, 297).add2(slot11, self.rightPanel)
	local h = 65
	curData = (shopData.tradeList[self.goodKind] and shopData.tradeList[self.goodKind]) or {}
	self.itemCells = {}
	local selectedData, timeLbl, countLbl = nil
	self.resetScrollView = function ()
		curData = (shopData.tradeList[self.goodKind] and shopData.tradeList[self.goodKind]) or {}
		self.maxItemNum = 10
		self.itemIdx = 1

		if tolua.isnull(infoView) then
			return 
		end

		infoView:removeAllChildren()
		infoView:setScrollOffset(0, 0)

		if #curData == 0 then
			infoView:setScrollSize(480, 297)
		else
			local cellNum = 10

			if #curData < self.maxItemNum then
				cellNum = #curData
			end

			infoView:setScrollSize(480, math.max(297, cellNum*h))
		end

		self.itemCells = {}
		selectCell = display.newScale9Sprite(res.getframe2("pic/common/select.png"), 0, 0, cc.size(473, 65)):anchor(0, 0):add2(infoView)

		selectCell:setVisible(false)

		if shopData.tradeOrder then
			orderPicDown:setVisible(false)
			orderPicUp:setVisible(true)
		else
			orderPicDown:setVisible(true)
			orderPicUp:setVisible(false)
		end

		if timeLbl then
			timeLbl:setText(shopData.nextUptTime)
		end

		if countLbl then
			countLbl:setText(tostring(shopData.tradeCount))
		end

		return 
	end
	self.refreshItemInfo = function ()
		if #curData == 0 then
			an.newLabel("当前无相关商品上架", 24, 1, {
				color = def.colors.labelGray
			}):anchor(0.5, 0.5):pos(infoView:getw()/2, infoView:geth()/2):add2(infoView)

			return 
		end

		for i = self.itemIdx, #curData, 1 do
			self.itemIdx = i

			if self.maxItemNum < self.itemIdx then
				return 
			end

			local v = curData[i]
			local nameColor = def.colors.cellNor

			if v.FItemInfo:isGoodItem() then
				nameColor = def.colors.Ccf15e1
			end

			local cell = display.newScale9Sprite(res.getframe2((i%2 == 0 and "pic/panels/guild/joinbg2.png") or "pic/panels/guild/joinbg1.png"), 0, 0, cc.size(470, h)):anchor(0, 0):pos(0, infoView:getScrollSize().height - i*h):add2(infoView)
			cell.data = v

			cell.enableClick(cell, function ()
				selectCell:setVisible(true)
				selectCell:pos(cell:getPositionX(), cell:getPositionY())

				selectedData = v

				return 
			end, {
				support = "scroll"
			})

			self.itemCells[#self.itemCells + 1] = cell
			local ibg = display.newSprite(res.gettex2("pic/panels/bag/itembg.png")).anchor(slot7, 0, 0):pos(4, 4):add2(cell)

			item.new(v.FItemInfo, ibg):addto(ibg):pos(27, 27)
			an.newLabel(v.FItemInfo:getVar("name"), 18, 0, {
				color = nameColor
			}):add2(cell):anchor(0, 0.5):pos(65, h*0.5)

			local timeTips = tostring(v.FExpireTime) .. "小时"

			if v.FExpireTime == 0 then
				timeTips = "小于1小时"
			end

			an.newLabel(timeTips, 18, 0, {
				color = def.colors.cellNor
			}):add2(cell):anchor(0.5, 0.5):pos(265, h*0.5)

			local moneyPic = "pic/console/infobar/yb.png"
			local sprice = tostring(v.FPrice/100)

			if self.money == 1 then
				moneyPic = "pic/console/infobar/gold.png"
				sprice = tostring(v.FPrice/10000)
				sprice = sprice .. "万"
			end

			display.newSprite(res.gettex2(moneyPic)):anchor(0.5, 0.5):pos(375, h*0.5):add2(cell)
			an.newLabel(sprice, 18, 0, {
				color = def.colors.cellNor
			}):add2(cell):anchor(0, 0.5):pos(395, h*0.5)
		end
	end

	self.resetScrollView()
	self.refreshItemInfo()
	infoView.setListenner(slot11, function (event)
		if event.name == "scrollToBottom" then
			self.maxItemNum = self.maxItemNum + 10

			if #curData <= self.itemIdx then
				if #curData < shopData.tradeCount then
					local rsb = DefaultClientMessage(CM_TradeBankGoodList)
					rsb.FBankType = self.money
					rsb.FGoodType = 0
					rsb.FGoodIndex = math.modf(self.maxItemNum/50)
					rsb.FGoodKind = self.goodKind
					rsb.FBoInc = self.priceOrder

					MirTcpClient:getInstance():postRsb(rsb)

					self.itemIdx = self.itemIdx + 1
				end
			else
				self.refreshItemInfo()
			end
		end

		return 
	end)

	filterInput = an.newInput(0, 0, 196, 40, 7, {
		label = {
			self.filterString or "",
			20,
			1
		},
		bg = {
			tex = res.gettex2("pic/scale/edit.png"),
			offset = {
				-10,
				2
			}
		},
		tip = {
			"<输入关键字查找>     ",
			20,
			1,
			{
				color = cc.c3b(128, 128, 128)
			}
		},
		stop_call = function ()
			local key = filterInput:getString()

			if key == "" then
				if self.lastKey ~= "" then
					self.lastKey = ""
					local rsb = DefaultClientMessage(CM_TradeBankGoodList)
					rsb.FBankType = self.money
					rsb.FGoodType = 0
					rsb.FGoodIndex = 0
					rsb.FGoodKind = self.goodKind
					rsb.FBoInc = true
					rsb.FItemName = ""

					MirTcpClient:getInstance():postRsb(rsb)
				end

				return 
			end

			self.lastKey = key
			local rsb = DefaultClientMessage(CM_TradeBankGoodList)
			rsb.FBankType = self.money
			rsb.FGoodType = 0
			rsb.FGoodIndex = 0
			rsb.FGoodKind = self.goodKind
			rsb.FBoInc = true
			rsb.FItemName = key

			MirTcpClient:getInstance():postRsb(rsb)

			return 
		end
	}).add2(slot16, self.bg):anchor(0, 0):pos(25, 10):add(res.get2("pic/common/button_search.png"):pos(170, 20))

	an.newLabel("下次更新: ", 18, 0, {
		color = def.colors.Cf0c896
	}):add2(self.bg):anchor(0, 0.5):pos(225, 35)

	timeLbl = an.newLabel(shopData.nextUptTime, 18, 0, {
		color = def.colors.Cdcd2be
	}):add2(self.bg):anchor(0, 0.5):pos(305, 35)

	an.newLabel("物品数量: ", 18, 0, {
		color = def.colors.Cf0c896
	}):add2(self.bg):anchor(0, 0.5):pos(370, 35)

	countLbl = an.newLabel(tostring(shopData.tradeCount), 18, 0, {
		color = def.colors.Cdcd2be
	}):add2(self.bg):anchor(0, 0.5):pos(452, 35)

	an.newBtn(res.gettex2("pic/panels/guild/btn.png"), function ()
		sound.playSound("103")

		if not selectedData then
			main_scene.ui:tip("未选择任何物品 ")

			return 
		end

		local msgbox = nil
		slot1 = an.newMsgbox({
			{
				"          你确定购买以下物品吗?",
				def.colors.Ca6a197
			}
		}, function (idx)
			if idx == 1 then
				if self.money == 1 and not g_data.player:isAuthen() then
					main_scene.ui:tip("未验证用户不可金币购买，可至各大主城老兵处验证 ")
					msgbox:removeSelf()

					return 
				end

				local rsb = DefaultClientMessage(CM_TradeBankOp)
				rsb.FBankType = self.money
				rsb.FOpType = 0
				rsb.FOrderID = selectedData.FOrderID

				MirTcpClient:getInstance():postRsb(rsb)
				selectCell:setVisible(false)

				selectedData = nil
			end

			msgbox:removeSelf()

			return 
		end, {
			title = "提示",
			disableScroll = true,
			manualRemove = true,
			btnTexts = {
				"确定购买",
				"取 消"
			}
		})
		msgbox = self
		local ibg = res.get2("pic/panels/bag/itembg.png"):anchor(0.5, 0.5):addTo(msgbox.bg):pos(140, 150)
		local cdata = clone(selectedData)

		if selectedData.FItemInfo:isPileUp() then
			cdata.FDura = itemCount
		end

		item.new(cdata.FItemInfo, ibg):addto(ibg):pos(27, 27)
		an.newLabel(cdata.FItemInfo:getVar("name"), 20, 0, {
			color = def.colors.Cdcd2be
		}):anchor(0, 0):add2(msgbox.bg):pos(170, 152)
		an.newLabel("价格: ", 20, 0, {
			color = def.colors.Cf0c896
		}):anchor(0, 0):add2(msgbox.bg):pos(170, 125)

		local sprice = tostring(cdata.FPrice/100)

		if self.money == 1 then
			sprice = tostring(cdata.FPrice/10000)
			sprice = sprice .. "万"
		end

		an.newLabel(sprice .. self.UITEXT, 20, 0, {
			color = def.colors.Cf30302
		}):anchor(0, 0):add2(msgbox.bg):pos(215, 125)

		return 
	end, {
		label = {
			"购  买",
			18,
			0,
			{
				color = def.colors.btn
			}
		},
		pressImage = res.gettex2("pic/panels/guild/btnh.png")
	}).add2(slot16, self.bg):anchor(0, 0):pos(520, 12)

	self.tabIndex = 1

	click(tabs[1])

	return 
end

local function createToggle(cb, default)
	local hasTips, tipContent = nil
	config = config or {}
	local base = display.newNode()
	local selsp = display.newFilteredSprite(res.gettex2("pic/common/toggle12.png")):anchor(0, 0):add2(base)

	base.setContentSize(base, selsp.getContentSize(selsp))

	base.setIsSelect = function (self, enable)
		base.isSelected = enable

		if enable then
			base:select()
		else
			base:unselect()
		end

		return 
	end
	base.isSelect = function (self)
		return base.isSelected
	end
	base.select = function (self)
		base.isSelected = true

		if base.temp then
			base.temp:removeSelf()

			base.temp = nil
		end

		selsp:setTex(res.gettex2(config.selectImg or "pic/common/toggle13.png"))

		return 
	end
	base.unselect = function (self)
		if base.temp then
			base.temp:removeSelf()

			base.temp = nil
		end

		base.isSelected = false

		selsp:setTex(res.gettex2("pic/common/toggle12.png"))

		return 
	end

	if default ~= nil then
		base.setIsSelect(slot4, default)
	end

	selsp.setTouchEnabled(selsp, true)
	selsp.addNodeEventListener(selsp, cc.NODE_TOUCH_EVENT, function (event)
		if event.name == "began" then
			base.offsetBeginY = event.y
			base.offsetBeginX = event.x

			return true
		elseif event.name == "ended" then
			local offsetY = event.y - base.offsetBeginY
			local offsetX = event.x - base.offsetBeginX

			if math.abs(offsetY) <= 20 and math.abs(offsetX) <= 20 then
				base:setIsSelect(not base.isSelected)
				cb(base.isSelected)
			end
		end

		return 
	end)
	selsp.setTouchSwallowEnabled(slot5, false)

	return base
end

tradeshop.addGoods = function (self)
	self.leftPanel = display.newScale9Sprite(res.getframe2("pic/common/black_5.png"), 0, 0, cc.size(300, 342)):addTo(self.bg):pos(15, 404):anchor(0, 1)
	self.rightPanel = display.newScale9Sprite(res.getframe2("pic/common/black_5.png"), 0, 0, cc.size(310, 342)):addTo(self.bg):pos(320, 404):anchor(0, 1)

	self.rightPanel:setVisible(true)

	self.putPanel = display.newScale9Sprite(res.getframe2("pic/common/black_5.png"), 0, 0, cc.size(310, 342)):addTo(self.bg):pos(320, 404):anchor(0, 1)

	self.putPanel:setVisible(false)

	if shopData.chargeConfig == nil or shopData.config == nil then
		return 
	end

	local selectedItem, priceInput, totalPrice, chkbox1, chkbox2, chkbox3 = nil
	local itemCount = 1
	local price_ = 0
	local time = 12
	local charge = shopData.chargeConfig[1].FGold
	local itemframe = res.get2("pic/panels/shop/frame.png"):anchor(0, 0):pos(10, 255):add2(self.putPanel)
	local itemName = an.newLabel("物品名称 ", 20, 0, {
		color = def.colors.Cdcd2be
	}):add2(self.putPanel):anchor(0, 0.5):pos(90, 312)
	local priceLimit = an.newLabel("", 18, 0, {
		color = def.colors.Cdcd2be
	}):anchor(0, 0):add2(self.putPanel):anchor(0, 0.5):pos(90, 274)
	local priceBg = display.newScale9Sprite(res.getframe2("pic/scale/scale26.png"), 0, 0, cc.size(300, 140)):addTo(self.putPanel):pos(4, 245):anchor(0, 1)

	an.newLabel("出售价格 ", 20, 0, {
		color = def.colors.labelTitle
	}):add2(priceBg):anchor(0, 0.5):pos(10, 115)
	an.newLabel("单价: ", 20, 0, {
		color = def.colors.labelTitle
	}):add2(priceBg):anchor(0, 0.5):pos(10, 70)

	priceInput = an.newInput(0, 0, 100, 40, 5, {
		label = {
			"1",
			20,
			1
		},
		bg = {
			tex = res.gettex2("pic/scale/edit.png"),
			offset = {
				-10,
				2
			}
		},
		tip = {
			"",
			20,
			1,
			{
				color = cc.c3b(128, 128, 128)
			}
		},
		stop_call = function ()
			price_ = tonumber(priceInput:getText())

			if not price_ then
				main_scene.ui:tip("只能输入整数", 6)
				priceInput:setText("1")

				price_ = 1
				price_ = price_*itemCount

				return 
			end

			if not selectedItem then
				print("selectedItem is nil")

				return 
			end

			local ret = shopData:getMaxPrice(selectedItem:getVar("name"))
			local MAX_PRICE = (ret and ret[1]/100) or 9999

			if self.money == 1 then
				MAX_PRICE = (ret and ret[2]/10000) or 1000
			end

			if price_ <= 0 then
				main_scene.ui:tip("请输入正确的数字！")
				priceInput:setText("1")

				price_ = 1
			end

			if MAX_PRICE < price_ then
				main_scene.ui:tip("请输入正确的数字！")
				priceInput:setText(tostring(MAX_PRICE))

				price_ = MAX_PRICE
			end

			if string.find(priceInput:getText() or "", "%.") then
				main_scene.ui:tip("只能输入整数", 6)
				priceInput:setText("1")

				price_ = 1
			end

			price_ = price_*itemCount

			totalPrice:setText(tostring(price_) .. self.UNITTEXT)

			if self.maxJBTips then
				self.maxJBTips:pos(totalPrice:getPositionX() + totalPrice:getw() + 5, 30)
			end

			return 
		end
	}).add2(slot15, priceBg):pos(126, 68)

	an.newLabel(self.UNITTEXT, 20, 0, {
		color = def.colors.Cdcd2be
	}):anchor(0, 0.5):add2(priceBg):pos(170, 70)
	an.newLabel("总价: ", 20, 0, {
		color = def.colors.labelTitle
	}):add2(priceBg):anchor(0, 0.5):pos(10, 30)

	totalPrice = an.newLabel("1" .. self.UNITTEXT, 20, 0, {
		color = def.colors.Cdcd2be
	}):anchor(0, 0.5):add2(priceBg):pos(70, 30)

	if self.money == 1 then
		local maxJBText = "(上限5千万)"

		if not g_data.player:isAuthen() then
			maxJBText = "(上限2百万)"
		end

		self.maxJBTips = an.newLabel(maxJBText, 18, 0, {
			color = def.colors.Cdcd2be
		}):anchor(0, 0.5):add2(priceBg):pos(totalPrice.getPositionX(totalPrice) + totalPrice.getw(totalPrice) + 5, 30)
	end

	an.newLabel("出售时间 ", 20, 0, {
		color = def.colors.labelTitle
	}):add2(self.putPanel):anchor(0, 0.5):pos(10, 90)

	chkbox1 = createToggle(function ()
		if chkbox2:isSelect() then
			chkbox2:unselect()
		end

		if chkbox3:isSelect() then
			chkbox3:unselect()
		end

		if chkbox1:isSelect() == false then
			chkbox1:select()

			return 
		end

		time = shopData.chargeConfig[1].FSellHours
		charge = shopData.chargeConfig[1].FGold

		return 
	end, true).add2(slot15, self.putPanel):pos(10, 40)

	an.newLabel(tostring(shopData.chargeConfig[1].FSellHours) .. "小时", 18, 0, {
		color = def.colors.Cf0c896
	}):anchor(0, 0):add2(self.putPanel):pos(42, 42)

	chkbox2 = createToggle(function ()
		if chkbox1:isSelect() then
			chkbox1:unselect()
		end

		if chkbox3:isSelect() then
			chkbox3:unselect()
		end

		if chkbox2:isSelect() == false then
			chkbox2:select()

			return 
		end

		time = shopData.chargeConfig[2].FSellHours
		charge = shopData.chargeConfig[2].FGold

		return 
	end, false).add2(slot15, self.putPanel):pos(110, 40)

	an.newLabel(tostring(shopData.chargeConfig[2].FSellHours) .. "小时", 18, 0, {
		color = def.colors.Cf0c896
	}):anchor(0, 0):add2(self.putPanel):pos(146, 42)

	chkbox3 = createToggle(function ()
		if chkbox2:isSelect() then
			chkbox2:unselect()
		end

		if chkbox1:isSelect() then
			chkbox1:unselect()
		end

		if chkbox3:isSelect() == false then
			chkbox3:select()

			return 
		end

		time = shopData.chargeConfig[3].FSellHours
		charge = shopData.chargeConfig[3].FGold

		return 
	end, false).add2(slot15, self.putPanel):pos(215, 40)

	an.newLabel(tostring(shopData.chargeConfig[3].FSellHours) .. "小时", 18, 0, {
		color = def.colors.Cf0c896
	}):anchor(0, 0):add2(self.putPanel):pos(250, 42)

	local infoView = an.newScroll(4, 4, 300, 330):add2(self.leftPanel)
	local h = 56
	curData = dataList

	infoView.setScrollSize(infoView, 295, math.max(330, math.modf(g_data.bag.max/5)*h))
	infoView.enableClick(infoView, function ()
		return 
	end)

	local function idx2pos(idx)
		idx = idx - 1
		local h = idx%5
		local v = math.modf(idx/5)

		return h*56 + 35, infoView:getScrollSize().height - 28 - v*56
	end

	local initRightPanel = nil

	for i = 1, g_data.bag.max, 1 do
		local ibg = res.get2("pic/panels/bag/itembg.png").anchor(slot23, 0.5, 0.5):addTo(infoView):pos(idx2pos(i))
		local v = g_data.bag.items[i]

		if v then
			local name = v.getVar(v, "name")
			local itemI = res.get("items", v.getVar(v, "looks")):addto(ibg):anchor(0.5, 0.5):pos(27, 27):enableClick(function ()
				initRightPanel(v)

				return 
			end, {
				support = "scroll"
			})

			if v.isPileUp(slot24) then
				an.newLabel(tostring(v.FDura), 12, 1, {
					color = cc.c3b(0, 255, 0)
				}):anchor(1, 0.5):pos(45, 15):add2(ibg, 2)
			end
		end
	end

	local defaultTip = an.newLabel("点击左侧物品以放入", 24, 1, {
		color = def.colors.labelGray
	}):anchor(0.5, 0.5):pos(self.rightPanel:getw()/2, self.rightPanel:geth()/2):add2(self.rightPanel, 2)

	function initRightPanel(data)
		selectedItem = data

		chkbox1:select()
		chkbox2:unselect()
		chkbox3:unselect()

		itemCount = 1
		time = 12
		local icfg = shopData:getMaxPrice(selectedItem:getVar("name"))

		if not selectedItem:isPileUp() then
			local msgbox = nil
			slot3 = an.newMsgbox("", function (idx)
				if idx == 1 then
					local isGood = data:isGoodItem()

					if selectedItem:isBinded() then
						main_scene.ui:tip("绑定道具不可出售 ")
						msgbox:removeSelf()

						return 
					end

					if isGood == false then
						if not icfg then
							main_scene.ui:tip("该物品不可上架 ")
							msgbox:removeSelf()

							return 
						elseif icfg[3] and icfg[3] ~= 3 then
							if icfg[3] == 0 then
								main_scene.ui:tip("该物品不可上架 ")
								msgbox:removeSelf()

								return 
							elseif icfg[3] == 1 and self.money ~= 0 then
								main_scene.ui:tip("该物品不可上架 ")
								msgbox:removeSelf()

								return 
							elseif icfg[3] == 2 and self.money ~= 1 then
								main_scene.ui:tip("该物品不可上架 ")
								msgbox:removeSelf()

								return 
							end
						end
					end

					self.rightPanel:setVisible(false)
					self.putPanel:setVisible(true)
					itemframe:removeAllChildren()
					item.new(data, itemframe, {
						donotMove = true
					}):addto(itemframe):pos(35, 35)

					local nameColor = def.colors.Cdcd2be

					if isGood then
						nameColor = def.colors.Ccf15e1
					end

					itemName:setColor(nameColor)
					itemName:setText(data:getVar("name"))

					local pricel = (icfg and icfg[1]/100) or 9999

					if self.money == 1 then
						pricel = (icfg and icfg[2]/10000) or 1000
					end

					priceLimit:setText("单价限制：" .. tostring(pricel) .. self.UNITTEXT)
					priceInput:setText("1")

					price_ = 1

					totalPrice:setText("1" .. self.UNITTEXT)

					if self.maxJBTips then
						self.maxJBTips:pos(totalPrice:getPositionX() + totalPrice:getw() + 5, 30)
					end
				else
					selectedItem = nil

					self.putPanel:setVisible(false)
					self.rightPanel:setVisible(true)
				end

				msgbox:removeSelf()

				return 
			end, {
				disableScroll = true,
				title = "道具放入",
				noclose = true,
				manualRemove = true,
				btnTexts = {
					"确定放入",
					"取 消"
				}
			})
			msgbox = chkbox3
			local ibg = res.get2("pic/panels/bag/itembg.png"):anchor(0.5, 0.5):addTo(msgbox.bg, 2):pos(155, 150)

			item.new(selectedItem, ibg):addto(ibg):pos(27, 27)

			local nameColor = def.colors.Cdcd2be

			if data.isGoodItem(data) then
				nameColor = def.colors.Ccf15e1
			end

			an.newLabel(selectedItem:getVar("name"), 22, 0, {
				color = nameColor
			}):anchor(0, 0):add2(msgbox.bg):pos(190, msgbox.bg:geth()*0.5 + 5)
			an.newLabel("点击图标以查看物品", 18, 0, {
				color = def.colors.cellOffline
			}):anchor(0, 0):add2(msgbox.bg):pos(190, msgbox.bg:geth()*0.5 - 20)

			return 
		end

		local countInput, slider, sliderbg, msgbox = nil
		slot6 = an.newMsgbox("", function (idx)
			if idx == 1 then
				if selectedItem:isBinded() then
					main_scene.ui:tip("绑定道具不可出售 ")
					msgbox:removeSelf()

					return 
				end

				if not icfg then
					main_scene.ui:tip("该物品不可上架 ")
					msgbox:removeSelf()

					return 
				elseif icfg[3] and icfg[3] ~= 3 then
					if icfg[3] == 0 then
						main_scene.ui:tip("该物品不可上架 ")
						msgbox:removeSelf()

						return 
					elseif icfg[3] == 1 and self.money ~= 0 then
						main_scene.ui:tip("该物品不可上架 ")
						msgbox:removeSelf()

						return 
					elseif icfg[3] == 2 and self.money ~= 1 then
						main_scene.ui:tip("该物品不可上架 ")
						msgbox:removeSelf()

						return 
					end
				end

				self.rightPanel:setVisible(false)
				self.putPanel:setVisible(true)
				itemframe:removeAllChildren()

				local cdata = clone(data)
				cdata.FDura = itemCount

				item.new(cdata, itemframe, {
					donotMove = true
				}):addto(itemframe):pos(35, 35)

				local nameColor = def.colors.Cdcd2be

				if data:isGoodItem() then
					nameColor = def.colors.Ccf15e1
				end

				itemName:setColor(nameColor)
				itemName:setText(cdata.getVar(cdata, "name"))

				local pricel = (icfg and icfg[1]/100) or 9999

				if self.money == 1 then
					pricel = (icfg and icfg[2]/10000) or 1000
				end

				priceLimit:setText("单价限制：" .. tostring(pricel) .. self.UNITTEXT)
				priceInput:setText("1")

				price_ = itemCount

				totalPrice:setText(tostring(itemCount) .. self.UNITTEXT)

				if self.maxJBTips then
					self.maxJBTips:pos(totalPrice:getPositionX() + totalPrice:getw() + 5, 30)
				end
			else
				selectedItem = nil

				self.putPanel:setVisible(false)
				self.rightPanel:setVisible(true)
			end

			msgbox:removeSelf()

			return 
		end, {
			disableScroll = true,
			title = "道具放入",
			noclose = true,
			manualRemove = true,
			btnTexts = {
				"确定放入",
				"取 消"
			}
		})
		msgbox = shopData
		local ibg = res.get2("pic/panels/bag/itembg.png"):anchor(0.5, 0.5):addTo(msgbox.bg, 2):pos(140, msgbox.bg:geth()*0.5 + 65)

		item.new(selectedItem, ibg):addto(ibg):pos(27, 27)

		local nameColor = def.colors.Cdcd2be

		if data.isGoodItem(data) then
			nameColor = def.colors.Ccf15e1
		end

		an.newLabel(selectedItem:getVar("name"), 22, 0, {
			color = nameColor
		}):anchor(0, 0):add2(msgbox.bg):pos(180, msgbox.bg:geth()*0.5 + 62)
		an.newLabel("点击图标以查看物品", 18, 0, {
			color = def.colors.cellOffline
		}):anchor(0, 0):add2(msgbox.bg):pos(180, msgbox.bg:geth()*0.5 + 42)
		an.newBtn(res.gettex2("pic/common/minus_n.png"), function ()
			if itemCount == 1 then
				return 
			end

			itemCount = itemCount - 1

			countInput:setText(tostring(itemCount))
			slider:setValue(itemCount/selectedItem.FDura)
			sliderbg:setScaleX(itemCount/selectedItem.FDura)

			return 
		end, {
			label = {
				"",
				18,
				0,
				{
					color = def.colors.btn
				}
			},
			pressImage = res.gettex2("pic/common/minus_s.png")
		}).add2(itemframe, msgbox.bg):anchor(0, 0):pos(100, 126)

		countInput = an.newInput(0, 0, 115, 40, 5, {
			label = {
				"1",
				20,
				1
			},
			bg = {
				tex = res.gettex2("pic/scale/edit.png"),
				offset = {
					-10,
					2
				}
			},
			tip = {
				"",
				20,
				1,
				{
					color = cc.c3b(128, 128, 128)
				}
			},
			stop_call = function ()
				itemCount = tonumber(countInput:getText())

				if not itemCount then
					main_scene.ui:tip("只能输入整数", 6)
					countInput:setText("1")

					itemCount = 1

					return 
				end

				if selectedItem.FDura < itemCount then
					itemCount = selectedItem.FDura

					countInput:setText(tostring(itemCount))
				end

				if itemCount <= 0 then
					itemCount = 1

					countInput:setText("1")
				end

				if string.find(countInput:getText() or "", "%.") then
					itemCount = 1

					countInput:setText("1")
				end

				if selectedItem.FDura < itemCount then
					itemCount = selectedItem.FDura

					countInput:setText(tostring(itemCount))
				end

				slider:setValue(itemCount/selectedItem.FDura)
				sliderbg:setScaleX(itemCount/selectedItem.FDura)

				return 
			end
		}).add2(itemframe, msgbox.bg):pos(210, 140)

		an.newLabel("个", 20, 0, {
			color = def.colors.Cdcd2be
		}):anchor(0, 0.5):add2(msgbox.bg):pos(262, 143)
		an.newBtn(res.gettex2("pic/common/add_n.png"), function ()
			if itemCount == selectedItem.FDura then
				return 
			end

			itemCount = itemCount + 1

			countInput:setText(tostring(itemCount))
			slider:setValue(itemCount/selectedItem.FDura)
			sliderbg:setScaleX(itemCount/selectedItem.FDura)

			return 
		end, {
			label = {
				"",
				18,
				0,
				{
					color = def.colors.btn
				}
			},
			pressImage = res.gettex2("pic/common/add_s.png")
		}).add2(itemframe, msgbox.bg):anchor(0, 0):pos(285, 126)

		local function valueChg(value)
			if value == 0 then
				value = selectedItem.FDura/1
			end

			sliderbg:setScaleX(value)

			itemCount = math.ceil(selectedItem.FDura*value)

			countInput:setText(tostring(itemCount))

			return 
		end

		sliderbg = res.get2("pic/panels/tradeshop/slider.png").anchor(item, 0, 0.5):addTo(msgbox.bg):pos(100, 90)

		sliderbg.setScaleX(sliderbg, selectedItem.FDura/1)

		slider = an.newSlider(res.gettex2("pic/panels/tradeshop/sliderbg.png"), nil, res.gettex2("pic/panels/tradeshop/sliderbtn.png"), {
			scale9 = cc.size(220, 10),
			value = selectedItem.FDura/1,
			valueChange = valueChg,
			valueChangeEnd = valueChg
		}):add2(msgbox.bg):pos(210, 90):anchor(0.5, 0.5)

		return 
	end

	an.newBtn(res.gettex2("pic/panels/guild/btn.png"), function ()
		selectedItem = nil

		sound.playSound("103")
		self.putPanel:setVisible(false)
		self.rightPanel:setVisible(true)

		return 
	end, {
		label = {
			"重新选择",
			18,
			0,
			{
				color = def.colors.btn
			}
		},
		pressImage = res.gettex2("pic/panels/guild/btnh.png")
	}).add2(slot20, self.bg):anchor(0, 0):pos(400, 12)
	an.newBtn(res.gettex2("pic/panels/guild/btn.png"), function ()
		sound.playSound("103")

		if not selectedItem then
			main_scene.ui:tip("未选择物品")

			return 
		end

		if not self:ckeckInSafeZone() then
			main_scene.ui:tip("非安全区不可出售物品！")

			return 
		end

		local msgbox = nil
		slot1 = an.newMsgbox("", function (idx)
			if idx == 1 then
				local rsb = DefaultClientMessage(CM_TradeBankSell)
				rsb.FBankType = self.money
				rsb.FClientItemID = selectedItem.FItemIdent
				rsb.FExpireTime = time
				local tempPrice = 0

				if self.money == 1 then
					tempPrice = price_*10000
					local maxJB = 50000000

					if not g_data.player:isAuthen() then
						maxJB = 2000000
					end

					if maxJB < tempPrice then
						main_scene.ui:tip("总价已超上限，上架失败 ")
						msgbox:removeSelf()

						return 
					end
				else
					tempPrice = price_*100
				end

				rsb.FSellPrice = tempPrice
				rsb.FNum = itemCount

				MirTcpClient:getInstance():postRsb(rsb)
				main_scene.ui.waiting:show(3, "tradeshop_wating")
			end

			msgbox:removeSelf()

			return 
		end, {
			title = "上架确认",
			disableScroll = true,
			manualRemove = true,
			btnTexts = {
				"确定上架",
				"取 消"
			}
		})
		msgbox = self
		local ibg = res.get2("pic/panels/bag/itembg.png"):anchor(0.5, 0.5):addTo(msgbox.bg):pos(160, 210)
		local cdata = clone(selectedItem)

		if selectedItem:isPileUp() then
			cdata.FDura = itemCount
		end

		item.new(cdata, ibg):addto(ibg):pos(27, 27)

		local nameColor = def.colors.Cdcd2be

		if cdata.isGoodItem(cdata) then
			nameColor = def.colors.Ccf15e1
		end

		an.newLabel(cdata.getVar(cdata, "name"), 18, 0, {
			color = nameColor
		}):anchor(0, 0):add2(msgbox.bg):pos(190, 200)
		an.newLabel("上架价格", 18, 0, {
			color = def.colors.Cdcd2be
		}):anchor(0, 0):add2(msgbox.bg):pos(40, msgbox.bg:geth()*0.5 - 25)

		local pl = an.newLabel(price_, 18, 0, {
			color = def.colors.Cf30302
		}):anchor(0, 0):add2(msgbox.bg):pos(130, msgbox.bg:geth()*0.5 - 25)

		an.newLabel(self.UNITTEXT, 18, 0, {
			color = def.colors.Cdcd2be
		}):anchor(0, 0):add2(msgbox.bg):pos(pl.getPositionX(pl) + pl.getw(pl) + 3, msgbox.bg:geth()*0.5 - 25)
		an.newLabel("上架时间", 18, 0, {
			color = def.colors.Cdcd2be
		}):anchor(0, 0):add2(msgbox.bg):pos(40, msgbox.bg:geth()*0.5 - 50)
		an.newLabel(tostring(time) .. "小时" .. "(手续费" .. tostring(charge) .. "金币)", 18, 0, {
			color = def.colors.Cdcd2be
		}):anchor(0, 0):add2(msgbox.bg):pos(130, msgbox.bg:geth()*0.5 - 50)

		return 
	end, {
		label = {
			"上  架",
			18,
			0,
			{
				color = def.colors.btn
			}
		},
		pressImage = res.gettex2("pic/panels/guild/btnh.png")
	}).add2(slot20, self.bg):anchor(0, 0):pos(520, 12)

	return 
end
tradeshop.sellingOut = function (self)
	self.Panel = display.newScale9Sprite(res.getframe2("pic/common/black_5.png"), 0, 0, cc.size(615, 342)):addTo(self.bg):pos(15, 405):anchor(0, 1)
	local titlebg = display.newScale9Sprite(res.getframe2("pic/panels/guild/titlebg.png"), 0, 0, cc.size(610, 42)):anchor(0, 0):pos(4, self.Panel:geth() - 44):add2(self.Panel)

	display.newScale9Sprite(res.getframe2("pic/panels/guild/split.png"), 0, 0, cc.size(4, 42)):anchor(0, 0):pos(245, 0):add2(titlebg)
	display.newScale9Sprite(res.getframe2("pic/panels/guild/split.png"), 0, 0, cc.size(4, 42)):anchor(0, 0):pos(400, 0):add2(titlebg)
	an.newLabel("物品名称", 20, 0, {
		color = def.colors.labelTitle
	}):anchor(0.5, 0.5):pos(125, self.Panel:geth() - 23):add2(self.Panel, 2)
	an.newLabel("剩余时间", 20, 0, {
		color = def.colors.labelTitle
	}):anchor(0.5, 0.5):pos(325, self.Panel:geth() - 23):add2(self.Panel, 2)
	an.newLabel("价格", 20, 0, {
		color = def.colors.labelTitle
	}):anchor(0.5, 0.5):pos(500, self.Panel:geth() - 23):add2(self.Panel, 2)

	self.sellingCells = {}
	local refreshItemInfo = nil
	local infoView = an.newScroll(4, 4, 610, 297):add2(self.Panel)
	local h = 65
	local curData = shopData.sellingList

	infoView.setScrollSize(infoView, 480, math.max(297, #curData*h))

	local selectCell = display.newScale9Sprite(res.getframe2("pic/common/select.png"), 0, 0, cc.size(613, 65)):anchor(0, 0):add2(infoView)

	selectCell.setVisible(selectCell, false)

	local selectData = nil

	function refreshItemInfo()
		if #curData == 0 then
			an.newLabel("当前无相关商品上架", 24, 1, {
				color = def.colors.labelGray
			}):anchor(0.5, 0.5):pos(self.Panel:getw()/2, self.Panel:geth()/2):add2(self.Panel, 2)

			return 
		end

		for i = 1, #curData, 1 do
			self.itemIdx = i
			local v = curData[i]
			local nameColor = def.colors.cellNor

			if v.FItemInfo:isGoodItem() then
				nameColor = def.colors.Ccf15e1
			end

			local cell = display.newScale9Sprite(res.getframe2((i%2 == 0 and "pic/panels/guild/joinbg2.png") or "pic/panels/guild/joinbg1.png"), 0, 0, cc.size(610, h)):anchor(0, 0):pos(0, infoView:getScrollSize().height - i*h):add2(infoView)
			cell.data = v

			cell.enableClick(cell, function ()
				selectCell:setVisible(true)
				selectCell:pos(cell:getPositionX(), cell:getPositionY())

				selectData = v

				return 
			end, {
				support = "scroll"
			})

			self.sellingCells[#self.sellingCells + 1] = cell
			local ibg = display.newSprite(res.gettex2("pic/panels/bag/itembg.png")).anchor(slot7, 0, 0):pos(4, 4):add2(cell)

			item.new(v.FItemInfo, ibg):addto(ibg):pos(27, 27)
			an.newLabel(v.FItemInfo:getVar("name"), 18, 0, {
				color = nameColor
			}):add2(cell):anchor(0, 0.5):pos(65, h*0.5)
			an.newLabel(tostring(v.FExpireTime) .. "小时", 18, 0, {
				color = def.colors.cellNor
			}):add2(cell):anchor(0.5, 0.5):pos(310, h*0.5)

			local moneyPic = "pic/console/infobar/yb.png"
			local sprice = tostring(v.FPrice/100)

			if self.money == 1 then
				sprice = tostring(v.FPrice/10000)
				moneyPic = "pic/console/infobar/gold.png"
				sprice = sprice .. "万"
			end

			display.newSprite(res.gettex2(moneyPic)):anchor(0.5, 0.5):pos(470, h*0.5):add2(cell)
			an.newLabel(sprice, 18, 0, {
				color = def.colors.cellNor
			}):add2(cell):anchor(0, 0.5):pos(490, h*0.5)
		end

		return 
	end

	slot2()
	an.newLabel("物品数量: ", 18, 0, {
		color = def.colors.Cf0c896
	}):add2(self.bg):anchor(0, 0.5):pos(270, 35)

	self.sellOutCountLbl = an.newLabel(tostring(#curData), 18, 0, {
		color = def.colors.Cdcd2be
	}):add2(self.bg):anchor(0, 0.5):pos(350, 35)

	an.newBtn(res.gettex2("pic/panels/guild/btn.png"), function ()
		sound.playSound("103")

		if not selectData then
			main_scene.ui:tip("未选择任何物品")

			return 
		end

		local texts_ = {
			{
				"你确定下架",
				def.colors.labelTitle
			},
			{
				selectData.FItemInfo:getVar("name"),
				def.colors.Cdcd2be
			},
			{
				"吗？",
				def.colors.labelTitle
			}
		}
		local msgbox = nil
		slot2 = an.newMsgbox(texts_, function (idx)
			if idx == 1 then
				local rsb = DefaultClientMessage(CM_TradeBankOp)
				rsb.FBankType = self.money
				rsb.FOpType = 1
				rsb.FOrderID = selectData.FOrderID

				MirTcpClient:getInstance():postRsb(rsb)
				selectCell:setVisible(false)

				selectData = nil
			end

			msgbox:removeSelf()

			return 
		end, {
			disableScroll = true,
			title = "提示",
			manualRemove = true,
			center = true,
			btnTexts = {
				"确定下架",
				"取 消"
			}
		})
		msgbox = selectCell

		return 
	end, {
		label = {
			"下  架",
			18,
			0,
			{
				color = def.colors.btn
			}
		},
		pressImage = res.gettex2("pic/panels/guild/btnh.png")
	}).add2(slot8, self.bg):anchor(0, 0):pos(520, 12)

	return 
end
tradeshop.pickUp = function (self)
	self.Panel = display.newScale9Sprite(res.getframe2("pic/common/black_5.png"), 0, 0, cc.size(615, 342)):addTo(self.bg):pos(15, 405):anchor(0, 1)
	local titlebg = display.newScale9Sprite(res.getframe2("pic/panels/guild/titlebg.png"), 0, 0, cc.size(610, 42)):anchor(0, 0):pos(4, self.Panel:geth() - 44):add2(self.Panel)

	display.newScale9Sprite(res.getframe2("pic/panels/guild/split.png"), 0, 0, cc.size(4, 42)):anchor(0, 0):pos(245, 0):add2(titlebg)
	display.newScale9Sprite(res.getframe2("pic/panels/guild/split.png"), 0, 0, cc.size(4, 42)):anchor(0, 0):pos(400, 0):add2(titlebg)
	an.newLabel("物品名称", 20, 0, {
		color = def.colors.labelTitle
	}):anchor(0.5, 0.5):pos(125, self.Panel:geth() - 23):add2(self.Panel, 2)
	an.newLabel("价格", 20, 0, {
		color = def.colors.labelTitle
	}):anchor(0.5, 0.5):pos(325, self.Panel:geth() - 23):add2(self.Panel, 2)
	an.newLabel("状态", 20, 0, {
		color = def.colors.labelTitle
	}):anchor(0.5, 0.5):pos(500, self.Panel:geth() - 23):add2(self.Panel, 2)

	local refreshItemInfo = nil
	local infoView = an.newScroll(4, 4, 610, 297):add2(self.Panel)
	local h = 65
	local curData = shopData.pickList

	infoView.setScrollSize(infoView, 480, math.max(297, #curData*h))

	local selectCell = display.newScale9Sprite(res.getframe2("pic/common/select.png"), 0, 0, cc.size(613, 65)):anchor(0, 0):add2(infoView)

	selectCell.setVisible(selectCell, false)

	local selectedData = nil
	self.pickCells = {}
	local statusTabel = {
		[2] = {
			"已出售",
			def.colors.C32b16c
		},
		[3] = {
			"已下架",
			def.colors.Ce66946
		},
		[4] = {
			"已退回",
			def.colors.Cf0c896
		},
		[5] = {
			"已购买",
			def.colors.C3794fb
		}
	}

	function refreshItemInfo()
		if #curData == 0 then
			an.newLabel("当前无相关商品", 24, 1, {
				color = def.colors.labelGray
			}):anchor(0.5, 0.5):pos(self.Panel:getw()/2, self.Panel:geth()/2):add2(self.Panel, 2)

			return 
		end

		for i = 1, #curData, 1 do
			self.itemIdx = i
			local v = curData[i]
			local nameColor = def.colors.cellNor

			if v.FItemInfo:isGoodItem() then
				nameColor = def.colors.Ccf15e1
			end

			local cell = display.newScale9Sprite(res.getframe2((i%2 == 0 and "pic/panels/guild/joinbg2.png") or "pic/panels/guild/joinbg1.png"), 0, 0, cc.size(610, h)):anchor(0, 0):pos(0, infoView:getScrollSize().height - i*h):add2(infoView)
			cell.data = v

			cell.enableClick(cell, function ()
				selectCell:setVisible(true)
				selectCell:pos(cell:getPositionX(), cell:getPositionY())

				selectedData = v

				return 
			end, {
				support = "scroll"
			})

			self.pickCells[#self.pickCells + 1] = cell
			local ibg = display.newSprite(res.gettex2("pic/panels/bag/itembg.png")).anchor(statusTabel, 0, 0):pos(4, 4):add2(cell)

			item.new(v.FItemInfo, ibg):addto(ibg):pos(27, 27)
			an.newLabel(v.FItemInfo:getVar("name"), 18, 0, {
				color = nameColor
			}):add2(cell):anchor(0, 0.5):pos(65, h*0.5)

			local moneyPic = "pic/console/infobar/yb.png"
			local sprice = tostring(v.FPrice/100)

			if self.money == 1 then
				sprice = tostring(v.FPrice/10000)
				moneyPic = "pic/console/infobar/gold.png"
				sprice = sprice .. "万"
			end

			display.newSprite(res.gettex2(moneyPic)):anchor(0.5, 0.5):pos(290, h*0.5):add2(cell)
			an.newLabel(sprice, 18, 0, {
				color = def.colors.cellNor
			}):add2(cell):anchor(0, 0.5):pos(315, h*0.5)
			an.newLabel(statusTabel[v.FStatus][1], 18, 0, {
				color = statusTabel[v.FStatus][2]
			}):add2(cell):anchor(0.5, 0.5):pos(500, h*0.5)
		end

		return 
	end

	slot2()
	an.newLabel("物品数量: ", 18, 0, {
		color = def.colors.Cf0c896
	}):add2(self.bg):anchor(0, 0.5):pos(240, 35)

	self.pickCountLbl = an.newLabel(tostring(#curData), 18, 0, {
		color = def.colors.Cdcd2be
	}):add2(self.bg):anchor(0, 0.5):pos(320, 35)

	an.newBtn(res.gettex2("pic/panels/guild/btn.png"), function ()
		if not self:ckeckInSafeZone() then
			main_scene.ui:tip("非安全区不可领取物品！")

			return 
		end

		local rsb = DefaultClientMessage(CM_TradeBankOp)
		rsb.FBankType = self.money
		rsb.FOpType = 3
		rsb.FOrderID = ""

		MirTcpClient:getInstance():postRsb(rsb)

		return 
	end, {
		label = {
			"一键领取",
			18,
			0,
			{
				color = def.colors.btn
			}
		},
		pressImage = res.gettex2("pic/panels/guild/btnh.png")
	}).add2(slot9, self.bg):anchor(0, 0):pos(400, 12)
	an.newBtn(res.gettex2("pic/panels/guild/btn.png"), function ()
		sound.playSound("103")

		if not selectedData then
			main_scene.ui:tip("未选择任何物品 ")

			return 
		end

		if not self:ckeckInSafeZone() then
			main_scene.ui:tip("非安全区不可领取物品！")

			return 
		end

		if g_data.bag:getBagItemCounts() == g_data.bag.max then
			main_scene.ui:tip("领取失败，背包空间不足 ")

			return 
		end

		local rsb = DefaultClientMessage(CM_TradeBankOp)
		rsb.FBankType = self.money
		rsb.FOpType = 2
		rsb.FOrderID = selectedData.FOrderID

		MirTcpClient:getInstance():postRsb(rsb)
		selectCell:setVisible(false)

		selectedData = nil

		return 
	end, {
		label = {
			"领  取",
			18,
			0,
			{
				color = def.colors.btn
			}
		},
		pressImage = res.gettex2("pic/panels/guild/btnh.png")
	}).add2(slot9, self.bg):anchor(0, 0):pos(520, 12)

	return 
end

return tradeshop
