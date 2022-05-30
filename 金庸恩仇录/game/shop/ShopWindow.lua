local BaseScene = require("game.BaseScene")
local ShopWindow = class("ShopWindow", BaseScene)
--[[
local ShopWindow = class("ShopWindow", function(...)
	return require("game.BaseScene").new({
	contentFile = "shop/shop.ccbi",
	bgImage = "ui/jpg_bg/zhaojiang_bg.jpg",
	useScale9 = false,
	scaleMode = 1
	})
end)
]]

local data_config_config = require("data.data_config_config")
local data_card_card = require("data.data_card_card")
local data_item_item = require("data.data_item_item")
local data_viplevel_viplevel = require("data.data_viplevel_viplevel")
local bMaxTime = 86400
local aMaxTime = 172800
local MAX_ZODER = 100

function ShopWindow:ctor(bGoShowList)
	ShopWindow.super.ctor(self, {
	contentFile = "shop/shop.ccbi",
	bgImage = "ui/jpg_bg/zhaojiang_bg.jpg",
	useScale9 = false,
	scaleMode = 1
	})
	
	game.runningScene = self
	self._bExit = false
	
	local function onTabBtn(sender, event)
		local tag = sender:getTag()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if 1 == tag then
			self:onPubView()
		elseif 2 == tag then
			if self._itemsData then
				self:onItemsView()
			else
				RequestHelper.getShopList({
				callback = function(data)
					dump(data)
					if string.len(data["0"]) > 0 then
						CCMessageBox(data["0"], "Tip")
					else
						self._itemsData = data
						self:onItemsView()
					end
				end
				})
			end
		elseif 3 == tag then
			RequestHelper.vipLibao.getData({
			callback = function(data)
				self:onVipLibaoView(data)
			end
			})
		end
		for i = 1, 3 do
			if tag == i then
				self._rootnode["tab" .. tostring(i)]:setEnabled(false)
				self._rootnode["tab" .. tostring(i)]:setZOrder(1)
			else
				self._rootnode["tab" .. tostring(i)]:setEnabled(true)
				self._rootnode["tab" .. tostring(i)]:setZOrder(0)
			end
		end
	end
	
	local function initTab()
		for i = 1, 3 do
			self._rootnode["tab" .. tostring(i)]:addHandleOfControlEvent(onTabBtn, CCControlEventTouchUpInside)
		end
		self._rootnode.payBtn:registerScriptTapHandler(function(tag)
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
			printf("buy something!")
			local iapLayer = require("game.shop.Chongzhi.ChongzhiLayer").new()
			self:addChild(iapLayer, MAX_ZODER)
		end)
		self._rootnode.tab1:setEnabled(false)
		self._rootnode.tab1:setZOrder(1)
	end
	
	local function initLabel()
		self._bDelayTime = 0
		self._aDelayTime = 0
		RequestHelper.getPubStat({
		callback = function(data)
			if game.runningScene ~= self then
				return
			end
			dump(data)
			if string.len(data["0"]) > 0 then
				CCMessageBox(data["0"], "Tip")
			else
				dump(data["2"])
				self._zhaomulingNum = data["1"].n
				self._bDelayTime = data["2"][1]
				self._aDelayTime = data["2"][2]
				if 0 > self._bDelayTime or self._bDelayTime > bMaxTime then
					self._bDelayTime = bMaxTime
					CCMessageBox(common:getLanguageString("@fuwuqidjs"), "Tip")
				end
				if 0 > self._aDelayTime or self._aDelayTime > aMaxTime then
					self._aDelayTime = aMaxTime
					CCMessageBox(common:getLanguageString("@fuwuqidjs"), "Tip")
				end
				self._nextNBCardTime = data["3"]
				dump(self._nextNBCardTime)
				self._rootnode.zhaomulingNumLabel:setString(tostring(self._zhaomulingNum))
				alignNodesOneByOneCenterX(self._rootnode.zhaomulingNumLabel:getParent(), self._rootnode.tagLabel, self._rootnode.zhaomulingNumLabel)
				self._rootnode.bCardDelayTimeLabel:setString(format_time(self._bDelayTime))
				self._rootnode.aCardDelayTimeLabel:setString(format_time(self._aDelayTime))
				self:checkIsShowFreeLbl()
				if data["4"][2] ~= 0 then
					self._rootnode.tag_first_4:setVisible(false)
				end
				if data["4"][3] ~= 0 then
					self._rootnode.tag_first_5:setVisible(false)
				else
					self._rootnode.tag_first_5:setVisible(true)
				end
				if bGoShowList == true then
					onTabBtn(self._rootnode.tab2, nil)
				end
			end
		end
		})
		self:schedule(function()
			if self._bDelayTime > 0 then
				self._bDelayTime = self._bDelayTime - 1
				self._rootnode.bCardDelayTimeLabel:setString(format_time(self._bDelayTime))
			end
			if 0 < self._aDelayTime then
				self._aDelayTime = self._aDelayTime - 1
				self._rootnode.aCardDelayTimeLabel:setString(format_time(self._aDelayTime))
			end
			self:checkIsShowFreeLbl()
		end,
		1)
	end
	if display.widthInPixels / display.heightInPixels == 0.75 then
		self._rootnode.pubNode:setScale(0.75)
		self._rootnode.pubNode:setPositionY(self._rootnode.pubNode:getPositionY() + 45)
	elseif display.widthInPixels / display.heightInPixels > 0.66 then
		self._rootnode.pubNode:setScale(0.85)
		self._rootnode.pubNode:setPositionY(self._rootnode.pubNode:getPositionY() + 25)
	end
	self._rootnode.tag_preview:addHandleOfControlEvent(function(eventName, sender)
		self._rootnode.tag_preview:setEnabled(false)
		local layer = require("game.shop.HeroShowLayer").new()
		self:addChild(layer, MAX_ZODER)
		self._rootnode.tag_preview:setEnabled(true)
	end,
	CCControlEventTouchUpInside)
	self:onPubView()
	initTab()
	initLabel()
	if bGoShowList == true then
		self._rootnode.pubNode:setVisible(false)
		self._rootnode.tag_hero_ui:setVisible(false)
		self._rootnode.itemsBg:setVisible(true)
	end
	self:refreshChoukaNoticeNum()
	if game.player:getAppOpenData().appstore == APPOPEN_STATE.close then
		local frameNo = display.newSpriteFrame("mm_silver.png")
		self._rootnode.aMoney_sign:setDisplayFrame(frameNo)
		self._rootnode.bMoney_sign:setDisplayFrame(frameNo)
	end
	alignNodesOneByOneCenterX(self._rootnode.ConsumeLabel:getParent(), self._rootnode.ConsumeLabel, self._rootnode.RecruitX1)
	alignNodesOneByOneCenterX(self._rootnode.bCardDelayTimeLabel:getParent(), self._rootnode.bCardDelayTimeLabel, self._rootnode.AfterFreeLabel)
	alignNodesOneByOneCenterX(self._rootnode.aCardDelayTimeLabel:getParent(), self._rootnode.aCardDelayTimeLabel, self._rootnode.AfterFreeLabel2)
end

function ShopWindow:checkIsShowFreeLbl()
	if self._bDelayTime <= 0 then
		self._rootnode.bCard_node:setVisible(false)
		self._rootnode.bCard_FreeLbl:setVisible(true)
	else
		self._rootnode.bCard_node:setVisible(true)
		self._rootnode.bCard_FreeLbl:setVisible(false)
	end
	if 0 >= self._aDelayTime then
		self._rootnode.aCard_node:setVisible(false)
		self._rootnode.aCard_FreeLbl:setVisible(true)
	else
		self._rootnode.aCard_node:setVisible(true)
		self._rootnode.aCard_FreeLbl:setVisible(false)
	end
end

function ShopWindow:refreshChoukaNoticeNum()
	local choukaNum = game.player:getChoukaNum()
	dump(choukaNum)
	if choukaNum > 0 then
		self._rootnode.chouka_notice_top:setVisible(true)
		self._rootnode.chouka_num_top:setString(choukaNum)
	else
		self._rootnode.chouka_notice_top:setVisible(false)
	end
	self:refreshChoukaNotice()
end

function ShopWindow:onPubView()
	self._rootnode.tag_hero_ui:setVisible(true)
	self._rootnode.itemsBg:setVisible(false)
	if self._isPubInit then
		self._rootnode.pubNode:setVisible(true)
	else
		do
			local function refreshLabel(tag, data, num)
				local delayTime = data["2"]
				if tag == 2 then
					self._rootnode.tag_first_4:setVisible(false)
					if delayTime < 0 or delayTime > bMaxTime then
						delayTime = bMaxTime
						CCMessageBox(common:getLanguageString("@fuwuqidjs"), "Tip")
					end
					self._bDelayTime = delayTime
					self._rootnode.bCardDelayTimeLabel:setString(format_time(self._bDelayTime))
				elseif tag == 3 then
					self._rootnode.tag_first_5:setVisible(false)
					if delayTime < 0 or delayTime > aMaxTime then
						delayTime = aMaxTime
						CCMessageBox(common:getLanguageString("@fuwuqidjs"), "Tip")
					end
					self._nextNBCardTime = data["4"]
					self._aDelayTime = delayTime
					self._rootnode.aCardDelayTimeLabel:setString(format_time(self._aDelayTime))
				end
				self:checkIsShowFreeLbl()
				game.player:setGold(data["3"])
				if data["5"] then
					game.player:setSilver(data["5"])
				end
				if tag == 2 or tag == 3 and num == 1 then
					game.player:setChoukaNum(game.player:getChoukaNum() - 1)
					self:refreshChoukaNoticeNum()
				end
			end
			local function getOneHero(tag, sender, num, fromLayer)
				if tag == 1 then
					dump("zhaozhoahoahoahoahohaoahaohaohao")
					PostNotice(NoticeKey.LOCK_BOTTOM)
					ResMgr.createBefTutoMask(self)
					if self._zhaomulingNum == 0 then
						return
					end
					self._zhaomulingNum = self._zhaomulingNum - 1
					self._rootnode.zhaomulingNumLabel:setString(tostring(self._zhaomulingNum))
				end
				RequestHelper.recrute({
				callback = function(data)
					if string.len(data["0"]) > 0 then
						CCMessageBox(data["0"], "Tip")
					else
						refreshLabel(tag, data, num or 1)
						local herolist = data["1"]
						local heroName = ""
						for k, v in pairs(herolist) do
							local heroId = v.id
							local heroInfo = ResMgr.getCardData(heroId)
							if heroInfo.star[1] >= 5 then
								Broad_getHeroData.heroName = heroInfo.name
								Broad_getHeroData.type = heroInfo.type
								Broad_getHeroData.star = heroInfo.star[1]
								game.broadcast:showPlayerGetHero()
							end
						end
						local param = {
						type = tag,
						leftTime = self._nextNBCardTime,
						zhaomulingNum = self._zhaomulingNum,
						herolist = data["1"],
						buyListener = getOneHero,
						point = data["6"],
						removeListener = function()
							self._rootnode.tag_preview:setEnabled(true)
						end
						}
						self:removeChildByTag(200)
						if #data["1"] == 1 then
							self:addChild(require("game.shop.ZhaojiangResultNormal").new(param), MAX_ZODER)
						elseif #data["1"] == 10 then
							self:addChild(require("game.shop.ZhaojiangResultTen").new(param), MAX_ZODER)
						end
						--if fromLayer ~= nil then
						--	fromLayer:removeSelf()
						--end
					end
				end,
				t = tag,
				n = num or 1,
				errback = function(data)
					self._rootnode.tag_preview:setEnabled(true)
				end
				})
			end
			self._rootnode.commonHeroBtn:registerScriptTapHandler(function()
				self:resetBtn(self._rootnode.commonHeroBtn)
				if self._zhaomulingNum > 0 then
					getOneHero(1)
				else
					show_tip_label(data_error_error[400006].prompt)
				end
				GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
			end)
			self._rootnode.nbHeroBtn:registerScriptTapHandler(function(tag, sender)
				self:resetBtn(self._rootnode.nbHeroBtn)
				local money, tips
				if game.player:getAppOpenData().appstore == APPOPEN_STATE.close then
					money = game.player:getSilver()
					tips = common:getLanguageString("@SilverCoinEnough")
				else
					money = game.player:getGold()
					tips = common:getLanguageString("@PriceEnough")
				end
				if self._bDelayTime > 0 and money < 80 then
					show_tip_label(tips)
				else
					self._rootnode.tag_preview:setEnabled(false)
					PostNotice(NoticeKey.REMOVE_TUTOLAYER)
					getOneHero(tag, sender, 1)
				end
				GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
			end)
			
			local function showSubMenu(tag, sender)
				self:resetBtn(self._rootnode.superNBHeroBtn)
				local isOneFree = false
				if self._aDelayTime <= 0 then
					isOneFree = true
				end
				local layer = require("game.shop.Get10CardLayer").new(isOneFree, self._nextNBCardTime, function(n)
					local money, tips
					if game.player:getAppOpenData().appstore == APPOPEN_STATE.close then
						money = game.player:getSilver()
						tips = common:getLanguageString("@SilverCoinEnough")
					else
						money = game.player:getGold()
						tips = common:getLanguageString("@PriceEnough")
					end
					local canBuy = true
					if n == 1 then
						if self._aDelayTime > 0 and money < 280 then
							canBuy = false
						end
					elseif n == 10 and money < 2680 then
						canBuy = false
					end
					if canBuy then
						getOneHero(tag, sender, n)
					else
						show_tip_label(tips)
					end
				end)
				self:addChild(layer, 5)
				GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
			end
			self._rootnode.superNBHeroBtn:registerScriptTapHandler(showSubMenu)
			self._isPubInit = true
		end
	end
end

function ShopWindow:resetBtn(btn)
	btn:setEnabled(false)
	self:performWithDelay(function()
		btn:setEnabled(true)
	end,
	0.5)
end
function ShopWindow:onItemsView()
	self._rootnode.pubNode:setVisible(false)
	self._rootnode.tag_hero_ui:setVisible(false)
	self._rootnode.itemsBg:setVisible(true)
	local _data = {}
	dump(self._itemsData)
	for index, v in ipairs(self._itemsData["1"]) do
		local item = data_item_item[v.itemId]
		local price = math.min(v.price + v.addPrice * self._itemsData["2"][index].hadBuy, v.price + v.maxN * v.addPrice)
		table.insert(_data, {
		name = item.name,
		itemId = v.itemId,
		icon = item.icon,
		maxnum = self._itemsData["2"][index].max,
		remainnum = self._itemsData["2"][index].cnt,
		price = price,
		hadBuy = self._itemsData["2"][index].hadBuy,
		desc = item.describe,
		baseprice = v.price,
		havenum = self._itemsData["2"][index].hadCnt,
		coinType = v.coinType,
		id = v.id,
		addPrice = v.addPrice,
		maxN = v.maxN
		})
	end
	local function onBuy(idx)
		local remainnum = _data[idx + 1].remainnum
		dump(_data[idx + 1])
		if remainnum <= 0 and _data[idx + 1].maxnum ~= -1 then
			show_tip_label(common:getLanguageString("@goumaidsx"))
		else
			local countBox = require("game.shop.BuyCountBox").new(_data[idx + 1], function()
				dump(_data[idx + 1])
				for index, v in ipairs(self._itemsData["1"]) do
					if v.itemId == _data[idx + 1].itemId then
						self._itemsData["2"][index].cnt = _data[idx + 1].remainnum
						self._itemsData["2"][index].hadBuy = _data[idx + 1].hadBuy
					end
				end
				self._scrollItemList:reloadCell(idx, {
				idx = idx + 1,
				itemData = _data[idx + 1]
				})
			end,
			function()
				RequestHelper.getShopList({
				callback = function(data)
					dump(data)
					if string.len(data["0"]) > 0 then
						CCMessageBox(data["0"], "Tip")
					else
						self._itemsData = data
						self:onItemsView()
					end
				end
				})
			end)
			game.runningScene:addChild(countBox, MAX_ZODER)
		end
	end
	if self._scrollItemList then
		self._scrollItemList:removeSelf()
		self._scrollItemList = nil
	end
	self._scrollItemList = require("utility.TableViewExt").new({
	size = cc.size(self._rootnode.itemsBg:getContentSize().width, self._rootnode.itemsBg:getContentSize().height - 170),
	direction = kCCScrollViewDirectionVertical,
	createFunc = function(idx)
		local item = require("game.shop.ShopItem").new()
		idx = idx + 1
		return item:create({
		viewSize = self._rootnode.itemsBg:getContentSize(),
		itemData = _data[idx],
		idx = idx,
		buyListener = onBuy
		})
	end,
	refreshFunc = function(cell, idx)
		idx = idx + 1
		cell:refresh({
		idx = idx,
		itemData = _data[idx]
		})
	end,
	cellNum = #_data,
	cellSize = require("game.shop.ShopItem").new():getContentSize(),
	touchFunc = function()
	end
	})
	self._scrollItemList:setPosition(0, 0)
	self._rootnode.itemsBg:addChild(self._scrollItemList)
end

function ShopWindow:onVipLibaoView(data)
	self._rootnode.pubNode:setVisible(false)
	self._rootnode.tag_hero_ui:setVisible(false)
	self._rootnode.itemsBg:setVisible(true)
	local getLevelGiftAry = data.getLevelGiftAry
	local curVipLevel = data.curVipLevel
	local rewardDatas = {}
	for i, viplevelData in ipairs(data_viplevel_viplevel) do
		local itemData = {}
		local limitVip = game.player:getVip() + data_config_config[1].vip_disnum
		if viplevelData.open == 1 and limitVip >= viplevelData.vip then
			for i, v in ipairs(viplevelData.arr_type1) do
				local itemId = viplevelData.arr_item1[i]
				local num = viplevelData.arr_num1[i]
				ResMgr.showAlert(itemId, "data_viplevel_viplevel数据表，VIP配置的升级奖励id没有，vip: " .. tostring(1) .. ", type:" .. v .. ", id:" .. itemId)
				ResMgr.showAlert(num, "data_viplevel_viplevel数据表，VIP配置的升级奖励num没有，vip: " .. tostring(1) .. ", type:" .. v .. ", id:" .. itemId)
				local iconType = ResMgr.getResType(v)
				local itemInfo
				if iconType == ResMgr.HERO then
					itemInfo = data_card_card[itemId]
				else
					itemInfo = data_item_item[itemId]
				end
				ResMgr.showAlert(itemInfo, "data_viplevel_viplevel数据表，arr_type1和arr_item1对应不上，vip：" .. tostring(1) .. ", type:" .. v .. ", id:" .. itemId)
				table.insert(itemData, {
				id = itemId,
				type = v,
				num = num,
				iconType = iconType,
				name = itemInfo.name,
				describe = itemInfo.describe or ""
				})
			end
			table.insert(rewardDatas, {
			itemData = itemData,
			vipLv = viplevelData.vip,
			oldPrice = viplevelData.old_price,
			newPrice = viplevelData.new_price,
			describe = viplevelData.describe,
			title = viplevelData.type
			})
		end
	end
	self:createVipLibaoListView({
	getLevelGiftAry = getLevelGiftAry,
	curVipLevel = curVipLevel,
	rewardDatas = rewardDatas
	})
end

function ShopWindow:createVipLibaoListView(param)
	local getLevelGiftAry = param.getLevelGiftAry
	local curVipLevel = param.curVipLevel
	local rewardDatas = param.rewardDatas
	local function buyReward(cell)
		RequestHelper.vipLibao.getReward({
		vipLv = cell:getVipLevel(),
		callback = function(data)
			if data.result == 1 then
				table.insert(getLevelGiftAry, cell:getVipLevel())
				cell:getReward(getLevelGiftAry)
				show_tip_label(data_error_error[2700001].prompt)
				game.player:updateMainMenu({
				silver = data.silver,
				gold = data.gold
				})
				PostNotice(NoticeKey.CommonUpdate_Label_Gold)
				PostNotice(NoticeKey.CommonUpdate_Label_Silver)
			else
				cell:setBuyBtnEnabled(true)
			end
			
		end
		})
	end
	if self._scrollItemList then
		self._scrollItemList:removeSelf()
		self._scrollItemList = nil
	end
	local viewSize = cc.size(self._rootnode.itemsBg:getContentSize().width, self._rootnode.itemsBg:getContentSize().height - 170)
	local function createFunc(index)
		local item = require("game.shop.vipLibao.VipLibaoItem").new()
		return item:create({
		viewSize = viewSize,
		cellDatas = rewardDatas[index + 1],
		getLevelGiftAry = getLevelGiftAry,
		buyFunc = function(cell)
			local cellDatas = rewardDatas[cell:getIdx() + 1]
			local msgBox = require("game.shop.vipLibao.VipLibaoBuyMsgbox").new({
			vipLv = cellDatas.vipLv,
			price = cellDatas.newPrice,
			describe = cellDatas.describe,
			title = cellDatas.title,
			cancelFunc = function()
				cell:setBuyBtnEnabled(true)
			end,
			confirmFunc = function()
				local result
				if cell:getVipLevel() > curVipLevel then
					show_tip_label(data_error_error[1900003].prompt)
					cell:setBuyBtnEnabled(true)
					result = false
				elseif game.player:getGold() < cellDatas.newPrice then
					show_tip_label(data_error_error[100004].prompt)
					result = false
				else
					result = true
					buyReward(cell)
				end
				return result
			end
			})
			self:addChild(msgBox, MAX_ZODER)
		end
		})
	end
	local function refreshFunc(cell, index)
		cell:refresh(rewardDatas[index + 1])
	end
	local cellContentSize = require("game.shop.vipLibao.VipLibaoItem").new():getContentSize()
	self._scrollItemList = require("utility.TableViewExt").new({
	size = viewSize,
	direction = kCCScrollViewDirectionVertical,
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #rewardDatas,
	cellSize = cellContentSize
	})
	self._scrollItemList:setPosition(0, 0)
	self._rootnode.itemsBg:addChild(self._scrollItemList)
end

function ShopWindow:onEnter()
	game.runningScene = self
	ShopWindow.super.onEnter(self)
	--self:regNotice()
	self._rootnode.goldLabel:setString(tostring(game.player:getGold()))
	self._rootnode.silverLabel:setString(tostring(game.player:getSilver()))
	if self._bExit then
		self._bExit = false
		local broadcastBg = self._rootnode.broadcast_tag
		game.broadcast:reSet(broadcastBg)
	end
	
	TutoMgr.addBtn("shangcheng_zhaomu", self._rootnode.nbHeroBtn)
	TutoMgr.addBtn("zhujiemian_btn_zhenrong", self._rootnode.formSettingBtn)
	TutoMgr.active()
end

function ShopWindow:onExit()
	self._bExit = true
	ShopWindow.super.onExit(self)
	
	TutoMgr.removeBtn("shangcheng_zhaomu")
	TutoMgr.removeBtn("zhujiemian_btn_zhenrong")
	self:unscheduleUpdate()
	--self:unregNotice()
	--self._bExit = true
	display.removeSpriteFrameByImageName("ui/jpg_bg/zhaojiang_bg.jpg")
	display.removeSpriteFramesWithFile("ui/ui_shop.plist", "ui/ui_shop.png")
	display.removeSpriteFramesWithFile("ui/ui_spirit.plist", "ui/ui_spirit.png")
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
end

return ShopWindow