local data_yueka_yueka = require("data.data_yueka_yueka")
require("data.data_error_error")
local data_item_item = require("data.data_item_item")
local data_card_card = require("data.data_card_card")
local MAX_ZORDER = 1111

local MonthCardLayer = class("MonthCardLayer", function ()
	return display.newNode()
end)

function MonthCardLayer:getMonthData()
	RequestHelper.monthCard.getData({
	payway = CurrentPayWay or "",
	callback = function (data)
		self:initData(data)
	end
	})
end

function MonthCardLayer:getReward()
	RequestHelper.monthCard.getReward({
	callback = function (data)
		if data.getResult == 1 then
			self._isHasGet = true
			self:updateRewardBtn(true)
			local rate = data.rate or 1
			for key, reward in pairs(self._rewardDatas) do
				reward.num = reward.num * rate
			end
			local title = common:getLanguageString("@GetRewards")
			local msgBox = require("game.Huodong.RewardMsgBox").new({
			title = title,
			cellDatas = self._rewardDatas
			})
			game.runningScene:addChild(msgBox, MAX_ZORDER)
		end
	end
	})
end

function MonthCardLayer:updateRewardBtn(isHasGet)
	if isHasGet then
		self._rootnode.getRewardBtn:setEnabled(false)
		self._rootnode.getRewardBtn:setVisible(false)
		self._rootnode.tag_has_get:setVisible(true)
	else
		self._rootnode.getRewardBtn:setEnabled(true)
		self._rootnode.getRewardBtn:setVisible(true)
		self._rootnode.tag_has_get:setVisible(false)
	end
end

function MonthCardLayer:ctor(param)
	self._curInfoIndex = -1
	local viewSize = param.viewSize
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("nbhuodong/month_card_layer.ccbi", proxy, self._rootnode, self, viewSize)
	self:addChild(node)
	local titleIcon = self._rootnode.title_icon
	local bottomNode = self._rootnode.bottom_node
	local disH = viewSize.height - titleIcon:getContentSize().height - bottomNode:getContentSize().height
	if disH > 10 then
		bottomNode:setPosition(bottomNode:getPositionX(), disH / 2)
	end
	local scaleY = (viewSize.height - bottomNode:getContentSize().height) / titleIcon:getContentSize().height
	if scaleY > 1 then
		scaleY = 1
	end
	self._rootnode.title_icon:setScale(scaleY)
	self:getMonthData()
end

function MonthCardLayer:buyItem(itemData, isMonthCard)
	dump("#############")
	local isBuyMonthCard = false
	if isMonthCard ~= nil and isMonthCard == true then
		isBuyMonthCard = isMonthCard
	end
	dump(itemData)
	local iapMgr = require("game.shop.Chongzhi.IapMgr").new()
	dump("#######++++++++++++++++++++++++++++++++######")
	iapMgr:buyGold({
	itemData = itemData,
	callback = function (data)
		dump("=============================")
		dump("========== buy end ==========")
		dump("=============================")
		if isBuyMonthCard == false then
			game.player:setIsHasBuyGold(true)
		end
		local getGold = itemData.chixugold
		local isFirstBuy = false
		if not isBuyMonthCard and itemData.buyCnt <= 0 then
			getGold = itemData.firstgold
			isFirstBuy = true
		end
		local buyEndMsgbox = require("game.shop.Chongzhi.ChongzhiBuyEndMsgbox").new({
		buyGold = itemData.basegold,
		getGold = getGold,
		isFirstBuy = isFirstBuy,
		isBuyMonthCard = isBuyMonthCard
		})
		game.runningScene:addChild(buyEndMsgbox, MAX_ZORDER)
	end
	})
	dump("#######++++++++++++++++++++++++++++++++######")
end

function MonthCardLayer:buyFunc()
	if self._monthcardData ~= nil and self._monthcardData.isCanBuy == 1 then
		local msgBox = require("game.shop.Chongzhi.ChongzhiBuyMonthCardMsgbox").new({
		leftDay = self._monthcardData.days or 0,
		confirmListen = function ()
			local itemData = {}
			itemData.price = self._monthcardData.cost
			itemData.basegold = self._monthcardData.getGold
			itemData.index = ""
			itemData.type = self._monthcardData.type
			itemData.productName = common:getLanguageString("@Monthcard")
			itemData.payitemId = tostring(self._monthcardData.type)
			itemData.isMonthCard = true
			itemData.coolpadItemId = 1
			show_tip_label("未开放充值功能")
			--self:buyItem(itemData, true)
		end
		})
		self:getParent():getParent():addChild(msgBox, MAX_ZORDER + 101010)
	else
		show_tip_label(data_error_error[1800].prompt)
	end
end

function MonthCardLayer:initData(data)
	self._monthcardData = data
	self._days = data.days or 0
	self._isCanBuy = false
	self._isHasGet = true
	if data.isCanBuy and data.isCanBuy == 1 then
		self._isCanBuy = true
	end
	if data.isget and data.isget == 2 then
		self._isHasGet = false
	end
	
	--立即购买
	self._rootnode.buyBtn:addHandleOfControlEvent(function (sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if self._isCanBuy == true then
			dump(data)
			self:buyFunc()
		else
			show_tip_label(data_error_error[1800].prompt)
		end
	end,
	CCControlEventTouchUpInside)
	
	--领奖
	local getRewardBtn = self._rootnode.getRewardBtn
	getRewardBtn:addHandleOfControlEvent(function (sender, eventName)
		getRewardBtn:setEnabled(false)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if self._days > 0 and not self._isHasGet then
			self:getReward()
		else
			show_tip_label(data_error_error[1801].prompt)
			getRewardBtn:setEnabled(true)
		end
	end,
	CCControlEventTouchUpInside)
	
	if self._days > 0 and self._isHasGet then
		self:updateRewardBtn(true)
	else
		self:updateRewardBtn(false)
	end
	local msgLbl1 = ui.newTTFLabelWithShadow({
	text = common:getLanguageString("@MonthcardLeft", 3),
	size = 22,
	color = cc.c3b(60, 243, 35),
	shadowColor = display.COLOR_BLACK,
	font = FONTS_NAME.font_haibao,
	--align = ui.TEXT_ALIGN_CENTER,
	})
	
	ResMgr.replaceKeyLableEx(msgLbl1, self._rootnode, "msg_lbl_1", -60, 0)
	msgLbl1:align(display.LEFT_TOP)
	
	local msgLbl2 = ui.newTTFLabelWithShadow({
	text = common:getLanguageString("@MonthcardContinue"),
	size = 22,
	color = cc.c3b(60, 243, 35),
	shadowColor = display.COLOR_BLACK,
	font = FONTS_NAME.font_haibao,
	--align = ui.TEXT_ALIGN_CENTER,
	})
	ResMgr.replaceKeyLableEx(msgLbl2, self._rootnode, "msg_lbl_2", -60, msgLbl2:getContentSize().height)
	msgLbl2:align(display.LEFT_TOP)
	
	self._rootnode.leftDay_lbl:setString(common:getLanguageString("@DayLeft"))
	self._rootnode.day_num_lbl:setString(tostring(self._days))
	alignNodesOneByOne(self._rootnode.leftDay_lbl, self._rootnode.day_num_lbl)
	self._rewardDatas = {}
	local yuekaData = data_yueka_yueka[2]
	for i = 1, yuekaData.num do
		local type = yuekaData.arr_type[i]
		ResMgr.showAlert(type, "data_yueka_yueka表，月卡赠送物品的type数量和num数量不匹配")
		local num = yuekaData.arr_num[i]
		ResMgr.showAlert(num, "data_yueka_yueka表，月卡赠送物品的num数量和num数量不匹配")
		local itemId = yuekaData.arr_item[i]
		ResMgr.showAlert(itemId, "data_yueka_yueka表，月卡赠送物品的item数量和num数量不匹配")
		local iconType = ResMgr.getResType(type)
		local itemData
		if iconType == ResMgr.HERO then
			itemData = data_card_card[itemId]
		elseif iconType == ResMgr.ITEM or iconType == ResMgr.EQUIP then
			itemData = data_item_item[itemId]
		else
			ResMgr.showAlert(itemId, "data_yueka_yueka表，月卡赠送物品的数据不对index:" .. i)
		end
		table.insert(self._rewardDatas, {
		id = itemId,
		name = itemData.name,
		num = num,
		type = type,
		iconType = iconType
		})
	end
	self:initRewardListView(self._rewardDatas)
end
function MonthCardLayer:initRewardListView(rewardDatas)
	local boardWidth = self._rootnode.listView:getContentSize().width
	local boardHeight = self._rootnode.listView:getContentSize().height
	local function createFunc(index)
		local item = require("game.nbactivity.MonthCard.MonthCardRewardItem").new()
		return item:create({
		id = index,
		viewSize = cc.size(boardWidth, boardHeight),
		itemData = rewardDatas[index + 1]
		})
	end
	local function refreshFunc(cell, index)
		cell:refresh({
		index = index,
		itemData = rewardDatas[index + 1]
		})
	end
	local cellContentSize = require("game.nbactivity.MonthCard.MonthCardRewardItem").new():getContentSize()
	self.ListTable = require("utility.TableViewExt").new({
	size = cc.size(boardWidth, boardHeight),
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #rewardDatas,
	cellSize = cellContentSize,
	touchFunc = function (cell)
		if self._curInfoIndex ~= -1 then
			return
		end
		local idx = cell:getIdx() + 1
		self._curInfoIndex = idx
		local itemData = rewardDatas[idx]
		local itemInfo = require("game.Huodong.ItemInformation").new({
		id = itemData.id,
		type = itemData.type,
		name = itemData.name,
		describe = itemData.describe,
		endFunc = function ()
			self._curInfoIndex = -1
		end
		})
		game.runningScene:addChild(itemInfo, 100)
	end
	})
	self.ListTable:setPosition(0, 0)
	self._rootnode.listView:addChild(self.ListTable)
end

return MonthCardLayer