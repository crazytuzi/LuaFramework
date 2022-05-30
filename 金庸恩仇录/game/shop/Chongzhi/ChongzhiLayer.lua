local data_yueka_yueka = require("data.data_yueka_yueka")
local data_viplevel_viplevel = require("data.data_viplevel_viplevel")
local data_ui_ui = require("data.data_ui_ui")
local data_item_item = require("data.data_item_item")
local data_card_card = require("data.data_card_card")

local baseYuanBao = 600000
local czLevel = {}
czLevel[1] = 100
czLevel[2] = 200
czLevel[3] = 500
czLevel[4] = 1000
czLevel[5] = 2000

require("data.data_error_error")
local MAX_ZORDER = 3222

local ChongzhiLayer = class("ChongzhiLayer", function()
	return require("utility.ShadeLayer").new()
end)

function ChongzhiLayer:getDataList(isRefresh)
	local function requestIap()
		RequestHelper.GameIap.main({
		payway = CurrentPayWay,
		callback = function(data)
			self:initData(data, isRefresh)
		end
		})
	end
	requestIap()
	--[[
	local versionUrl = NewServerInfo.VERSION_URL
	if VERSION_CHECK_DEBUG == true then
		versionUrl = NewServerInfo.DEV_VERSION_URL
	end
	local function requestPayWayAgain()
		NetworkHelper.request(versionUrl, {
		ac = "dwrechargemode",
		package = CSDKShell.GetBoundleID(),
		packetTag = PacketTag
		}, function(data)
			dump(data)
			self:initPayWayAgain(data)
			requestIap()
		end,
		"GET")
	end
	print("request pay way again")
	if CurrentPayWay == nil or CurrentPayWay == "" then
		requestPayWayAgain()
	else
		requestIap()
	end
	]]
end

function ChongzhiLayer:initPayWayAgain(data)
	CurrentPayWay = ""
	if data ~= nil and data.rechargemode ~= nil then
		CurrentPayWay = data.rechargemode
	end
	if TargetPlatForm and TargetPlatForm == PLATFORMS.VN and VERSION_CHECK_DEBUG == false and SHEN_BUILD == true then
		CurrentPayWay = "appstore_nv"
	end
	if CurrentPayWay == nil or CurrentPayWay == "" then
		CurrentPayWay = ""
		show_tip_label(common:getLanguageString("@wangluoyc1"))
	end
end

--[[发送URL购买链接]]
function ChongzhiLayer:buyItem(itemData, isMonthCard)
	local ServerIdx = game.player.m_serverID
	local PlayerName = game.player:getPlayerName()
	local PlayerID = game.player:getPlayerID()
	local price = itemData.price
	local nType = itemData.type
	local czurl = _APPCZURL.."&UserName="..PlayerID.."&jinzhua="..ServerIdx.."&fee="..price.."&jinzhub="..nType
	show_tip_label("未开放充值功能")
	--device.openURL(czurl)
	return
	--dump(czurl)
	--dump(itemData)
	--show_tip_label("请仔细查看游戏公告进入本服官网或者联系客服进行充值！")
	
	--[[local isBuyMonthCard = false
	if isMonthCard ~= nil and isMonthCard == true then
		isBuyMonthCard = isMonthCard
	end
	itemData.isBuyMonthCard = isBuyMonthCard
	dump(itemData)
	dump("#######++++++++++++++++++++++++++++++++######")
	local iapMgr = require("game.shop.Chongzhi.IapMgr").new()
	iapMgr:buyGold({
	itemData = itemData,
	callback = function()
		dump("=============================")
		dump("========== buy end ==========")
		dump("=============================")
		if self.getDataList ~= nil then
			self:getDataList(true)
		end
	end
	})
	dump("#######++++++++++++++++++++++++++++++++######")--]]
end

function ChongzhiLayer:ctor()
	MonthCardTYPE = "Inland_android"
	self._curInfoIndex = -1
	local proxy = CCBProxy:create()
	self._rootnode = {}
	self._totalSize = cc.size(640, display.height - 45)
	if self._totalSize.height > 900 then
		self._totalSize.height = 780
	elseif self._totalSize.height < 650 then
		self._totalSize.height = 650
	end
	self._node = CCBuilderReaderLoad("ccbi/shop/shop_chongzhi_layer.ccbi", proxy, self._rootnode, self, self._totalSize)
	self._node:setPosition(display.cx, display.cy)
	self:addChild(self._node)
	if game.player:getAppOpenData().appstore == APPOPEN_STATE.close then
		self._rootnode.tag_appStore_bg:setVisible(true)
	else
		self._rootnode.tag_appStore_bg:setVisible(false)
	end
	self._rootnode.title_sprite:setPosition(display.cx, self._totalSize.height - 10)
	
	self._rootnode.tag_close:addHandleOfControlEvent(function()
		self._rootnode.tag_close:setEnabled(false)
		self:removeFromParentAndCleanup(true)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
	end,
	CCControlEventTouchUpInside)
	
	self:getDataList(false)
end

function ChongzhiLayer:initData(data, isRefresh)
	self._vipData = data.vipData
	self._listData = data.list
	self._monthcardData = data.yueData
	self._frist = data.frist
	--self._cz = data.cz
	--self._vipData.curExp = data.jf - baseYuanBao
	
	game.player:setAppOpenData(data.extend)
	local curGold = data.curGold
	
	game.player:updateMainMenu({
	gold = curGold,
	vip = self._vipData.level
	})
	if game.player.m_vip == 0 and self._vipData.level == 1 then
		SDKTKData.onCustEvent(5)
	end
	PostNotice(NoticeKey.CommonUpdate_Label_Gold)
	PostNotice(NoticeKey.MainMenuScene_Update)
	if self.callbackFunc then
		self.callbackFunc()
	end
	self._isFullVip = true
	local viplevelData
	local nextVipLv = self._vipData.level + 1
	for i, v in ipairs(data_viplevel_viplevel) do
		if v.vip == nextVipLv and v.open == 1 then
			viplevelData = v
			self._isFullVip = false
		end
	end
	self:initAllNodePos()
	self:initTopVipInfo(isRefresh)
	if self._isFullVip == false then
		self:initVipRewardInfo(viplevelData)
	end
	if not isRefresh then
	end
	self:initShopItemDataInfo(isRefresh)
	local checkVipBtn = self._rootnode.checkVipBtn
	if game.player:getAppOpenData().c_vipbtn == APPOPEN_STATE.close then
		checkVipBtn:setVisible(false)
	else
		checkVipBtn:setVisible(true)
		if not isRefresh then
			checkVipBtn:addHandleOfControlEvent(function()
				GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
				checkVipBtn:setEnabled(false)
				self._rootnode.tag_close:setEnabled(false)
				local vipInfoLayer = require("game.shop.Chongzhi.ChongzhiVipDesInfoLayer").new({
				curVipLv = self._vipData.level,
				curVipExp = self._vipData.curExp,
				vipExpLimit = self._vipData.curExpLimit,
				confirmFunc = function()
					checkVipBtn:setEnabled(true)
					self._rootnode.tag_close:setEnabled(true)
				end
				})
				game.runningScene:addChild(vipInfoLayer, self:getZOrder() + 1)
			end,
			CCControlEventTouchUpInside)
		end
	end
end


function ChongzhiLayer:initAllNodePos()
	local height = 0
	self._rootnode.top_node:setPositionY(self._totalSize.height - 60)
	height = height + self._rootnode.top_node:getContentSize().height + 60
	if self._isFullVip == false then
		self._rootnode.vipReward_node:setVisible(true)
		self._rootnode.monthCard_node:setVisible(false)
		self._rootnode.vipReward_node:setPositionY(self._totalSize.height - height)
		height = height + self._rootnode.vipReward_node:getContentSize().height
	else
		self._rootnode.vipReward_node:setVisible(false)
		self._rootnode.monthCard_node:setVisible(true)
		self._rootnode.monthCard_node:setPositionY(self._totalSize.height - height + 90)
		height = height + self._rootnode.monthCard_node:getContentSize().height - 90
	end
	local shopBgViewSize = cc.size(615, self._totalSize.height - height - 15)
	self._shopItemViewSize = cc.size(shopBgViewSize.width, shopBgViewSize.height - 20)
	self._rootnode.listView_node:removeAllChildren()
	self._shopItemBg = display.newScale9Sprite("#cz_item_innerBg.png", 0, 0, shopBgViewSize)
	self._shopItemBg:setAnchorPoint(0.5, 0)
	self._shopItemBg:setPosition(self._rootnode.listView_node:getContentSize().width / 2, 0)
	self._rootnode.listView_node:addChild(self._shopItemBg)
	self._listViewNode = display.newNode()
	self._listViewNode:setContentSize(self._shopItemViewSize)
	self._listViewNode:setAnchorPoint(0.5, 0.5)
	self._listViewNode:setPosition(self._rootnode.listView_node:getContentSize().width / 2, shopBgViewSize.height / 2)
	self._rootnode.listView_node:addChild(self._listViewNode)
	
end

function ChongzhiLayer:initTopVipInfo(isRefresh)
	self._rootnode.cur_vip_level_lbl:setString(tostring(self._vipData.level))
	self._rootnode.vip_exp_lbl:setString(tostring(self._vipData.curExp) .. "/" .. tostring(self._vipData.curExpLimit))
	local percent = self._vipData.curExp / self._vipData.curExpLimit
	
	if self._isFullVip then
		percent = 1
		self._rootnode.tag_fullVip_node:setVisible(false)
		self._rootnode.next_vip_need_node:setVisible(false)
		self._rootnode.tag_vip_reward_msg:setVisible(false)
		self._rootnode.tag_full_gold_lbl:setString(common:getLanguageString("@yichongzhi", tostring(self._vipData.curExp)))
	else
		self._rootnode.tag_fullVip_node:setVisible(false)
		self._rootnode.next_vip_need_node:setVisible(true)
		self._rootnode.top_next_vip_lbl:setString(tostring(self._vipData.level + 1))
		local needGold = self._vipData.curExpLimit - self._vipData.curExp
		if self._vipData.level <= 0 then
			self._rootnode.tag_vip_reward_msg:setVisible(false)
			self._rootnode.tag_needGold_num_lbl:setString(common:getLanguageString("@zaichongzhi", tostring(needGold)))
			self._rootnode.next_vip_need_node:setPositionY(self._rootnode.tag_fullVip_node:getPositionY())
		else
			self._rootnode.tag_vip_reward_msg:setVisible(true)
			self._rootnode.tag_needGold_num_lbl:setString(common:getLanguageString("@zaichongzhi", tostring(needGold)))
			self._rootnode.next_vip_need_node:setPositionY(self._rootnode.tag_fullVip_node:getPositionY() + 17)
		end
	end
	alignNodesOneByAll({
	self._rootnode.tag_needGold_num_lbl,
	self._rootnode.tag_needGold_icon,
	self._rootnode.tag_needGold_lbl,
	self._rootnode.vipLabel_1
	}, 0)
	local addBar = self._rootnode.vip_addBar
	local normalBar = self._rootnode.vip_normalBar
	addBar:setTextureRect(cc.rect(addBar:getTextureRect().x, addBar:getTextureRect().y, normalBar:getContentSize().width * percent, normalBar:getTextureRect().height))
end

function ChongzhiLayer:initVipRewardInfo(viplevelData)
	local cellDatas = {}
	if self._vipData.level <= 0 then
		self._rootnode.first_title_node:setVisible(true)
		self._rootnode.first_titleEffect_icon:setVisible(true)
		self._rootnode.vip_title_node:setVisible(false)
		self._rootnode.vip_titleEffect_icon:setVisible(false)
		local shouchongData = data_yueka_yueka[1]
		for i = 1, shouchongData.num do
			local type = shouchongData.arr_type[i]
			ResMgr.showAlert(type, "data_yueka_yueka表，月卡赠送物品的type数量和num数量不匹配")
			local num = shouchongData.arr_num[i]
			ResMgr.showAlert(num, "data_yueka_yueka表，月卡赠送物品的num数量和num数量不匹配")
			local itemId = shouchongData.arr_item[i]
			ResMgr.showAlert(itemId, "data_yueka_yueka表，月卡赠送物品的item数量和num数量不匹配")
			local iconType = ResMgr.getResType(type)
			local itemInfo
			if iconType == ResMgr.HERO then
				itemInfo = data_card_card[itemId]
			elseif iconType == ResMgr.ITEM or iconType == ResMgr.EQUIP then
				itemInfo = data_item_item[itemId]
			else
				ResMgr.showAlert(itemId, "data_yueka_yueka表，月卡赠送物品的数据不对index:" .. i)
			end
			table.insert(cellDatas, {
			id = itemId,
			name = itemInfo.name,
			num = num,
			type = type,
			iconType = iconType,
			describe = itemInfo.describe or ""
			})
		end
	else
		self._rootnode.first_titleEffect_icon:setVisible(false)
		self._rootnode.first_title_node:setVisible(false)
		self._rootnode.vip_title_node:setVisible(true)
		self._rootnode.vip_titleEffect_icon:setVisible(true)
		self._rootnode.next_vip_level_lbl:setString(self._vipData.level + 1)
		for i, v in ipairs(viplevelData.arr_type1) do
			local itemId = viplevelData.arr_item1[i]
			local num = viplevelData.arr_num1[i]
			ResMgr.showAlert(itemId, "data_viplevel_viplevel数据表，VIP配置的升级奖励id没有，vip: " .. tostring(self._vipData.level + 1) .. ", type:" .. v .. ", id:" .. itemId)
			ResMgr.showAlert(num, "data_viplevel_viplevel数据表，VIP配置的升级奖励num没有，vip: " .. tostring(self._vipData.level + 1) .. ", type:" .. v .. ", id:" .. itemId)
			local iconType = ResMgr.getResType(v)
			local itemInfo
			if iconType == ResMgr.HERO then
				itemInfo = data_card_card[itemId]
			else
				itemInfo = data_item_item[itemId]
			end
			ResMgr.showAlert(itemInfo, "data_viplevel_viplevel数据表，arr_type1和arr_item1对应不上，vip：" .. tostring(self._vipData.level + 1) .. ", type:" .. v .. ", id:" .. itemId)
			table.insert(cellDatas, {
			id = itemId,
			type = v,
			num = num,
			iconType = iconType,
			name = itemInfo.name,
			describe = itemInfo.describe or ""
			})
		end
	end
	local boardWidth = self._rootnode.vip_reward_listView:getContentSize().width
	local boardHeight = self._rootnode.vip_reward_listView:getContentSize().height
	local function createFunc(index)
		local item = require("game.shop.Chongzhi.ChongzhiRewardItem").new()
		return item:create({
		id = index,
		itemData = cellDatas[index + 1],
		informationListener = function(cell)
			local index = cell:getIdx() + 1
			local itemData = cellDatas[index + 1]
			local itemInfo = require("game.Huodong.ItemInformation").new({
			id = itemData.id,
			type = itemData.type,
			name = itemData.name,
			describe = itemData.describe
			})
			game.runningScene:addChild(itemInfo, self:getZOrder() + 1)
		end
		})
	end
	local function refreshFunc(cell, index)
		cell:refresh({
		index = index,
		itemData = cellDatas[index + 1]
		})
	end
	local cellContentSize = require("game.shop.Chongzhi.ChongzhiRewardItem").new():getContentSize()
	if self.ListTable ~= nil then
		self.ListTable:removeSelf()
	end
	self.ListTable = require("utility.TableViewExt").new({
	size = cc.size(boardWidth, boardHeight),
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #cellDatas,
	cellSize = cellContentSize,
	touchFunc = function(cell)
		if self._curInfoIndex ~= -1 then
			return
		end
		local idx = cell:getIdx() + 1
		self._curInfoIndex = idx
		local itemData = cellDatas[idx]
		local itemInfo = require("game.Huodong.ItemInformation").new({
		id = itemData.id,
		type = itemData.type,
		name = itemData.name,
		describe = itemData.describe,
		endFunc = function()
			self._curInfoIndex = -1
		end
		})
		game.runningScene:addChild(itemInfo, self:getZOrder() + 1)
	end
	})
	self.ListTable:setPosition(0, 0)
	self._rootnode.vip_reward_listView:addChild(self.ListTable)
end

function ChongzhiLayer:initMonthCardDataInfo()
	self._rootnode.month_checkBtn:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if GameStateManager.currentState == GAME_STATE.STATE_JINGCAI_HUODONG then
			game.runningScene:changeShowLayer(nbActivityShowType.MonthCard)
			self:removeFromParentAndCleanup(true)
		else
			GameStateManager:ChangeState(GAME_STATE.STATE_JINGCAI_HUODONG, nbActivityShowType.MonthCard)
		end
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.month_chongzhiBtn:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if not ENABLE_IAP_BUY then
			show_tip_label(common:getLanguageString("@HintPause"))
		elseif self._monthcardData.isCanBuy == 1 then
			do
				local _productID = tostring(self._monthcardData.type)
				local msgBox = require("game.shop.Chongzhi.ChongzhiBuyMonthCardMsgbox").new({
				leftDay = self._monthcardData.days or 0,
				confirmListen = function()
					local itemData = {}
					itemData.price = self._monthcardData.cost
					itemData.basegold = self._monthcardData.goldget
					itemData.index = ""
					itemData.type = self._monthcardData.type
					itemData.productName = common:getLanguageString("@Monthcard")
					itemData.payitemId = _productID
					itemData.isMonthCard = true
					itemData.coolpadItemId = 1
					self:buyItem(itemData, true)
				end
				})
				self:addChild(msgBox, MAX_ZORDER)
			end
		else
			show_tip_label(data_error_error[1800].prompt)
		end
	end,
	CCControlEventTouchUpInside)
end

function ChongzhiLayer:initShopItemDataInfo(isRefresh)
	self._shopItemData = {}
	local tmpShopItemData = {}
	local data_chongzhi = require("game.Chongzhi")
	for i, v in ipairs(self._listData) do
		local data = data_chongzhi["Inland_android"][v.index]
		if data ~= nil then
			local isShowMark = false
			if v.cnt <= 0 and data.mark1 == 1 then
				isShowMark = true
			end
			local _productID = tostring(v.type) .. "_" .. tostring(v.index)
			table.insert(tmpShopItemData, {
			index = v.index,
			type = v.type,
			buyCnt = v.cnt,
			order = data.order,
			price = v.coinnum,
			basegold = data.basegold,
			firstgold = data.firstgold,
			chixugold = data.chixugold,
			iconImgName = "#" .. data.icon .. ".png",
			isShowMark = isShowMark,
			productName = common:getLanguageString("@Gold", tostring(data.basegold)),
			payitemId = _productID,
			isMonthCard = false,
			coolpadItemId = v.index + 1
			})
		end
	end
	
	for i = 1, #tmpShopItemData do
		for j, v in ipairs(tmpShopItemData) do
			if v.order == i then
				table.insert(self._shopItemData, v)
				break
			end
		end
	end
	local num
	if #self._listData % 3 == 0 then
		num = #self._listData / 3
	else
		num = #self._listData / 3 + 1
	end
	local startIndex = 0
	local allItemData = {}
	for i = 1, num do
		local itemData = {}
		for j = 1, 3 do
			local index = startIndex + j
			if index <= #self._shopItemData then
				table.insert(itemData, self._shopItemData[index])
			end
		end
		startIndex = startIndex + 3
		table.insert(allItemData, itemData)
	end
	
	local function buyListen(index, tag, closeListener)
		if game.player:getAppOpenData().appstore == APPOPEN_STATE.close and index == #allItemData + 1 then
			local buyItemData = {
			order = 2,
			price = self._monthcardData.cost,
			chixugold = 0,
			basegold = self._monthcardData.goldget,
			iconImgName = "#cz_icon_5.png",
			buyCnt = 2,
			payitemId = tostring(self._monthcardData.type),
			index = "",
			type = self._monthcardData.type,
			isMonthCard = true,
			productName = common:getLanguageString("@Gold", ""),
			coolpadItemId = 1
			}
			self:buyItemMsgbox({
			itemData = buyItemData,
			buyFunc = function()
				if buyItemData ~= nil then
					self:buyItem(buyItemData, true)
				end
			end,
			closeListener = closeListener
			})
			return
		end
		if index == #allItemData + 1 then
			show_tip_label(common:getLanguageString("@shujuyc1"))
			return
		end
		local buyItemData = allItemData[index][tag]
		dump(buyItemData)
		dump(common:getLanguageString("@Buy") .. buyItemData.index .. ", tag: " .. tag)
		if not ENABLE_IAP_BUY then
			show_tip_label(common:getLanguageString("@HintPause"))
		else
			self:buyItemMsgbox({
			itemData = buyItemData,
			buyFunc = function()
				if buyItemData ~= nil then
					self:buyItem(buyItemData)
				end
			end,
			closeListener = closeListener
			})
		end
	end
	local cellContentSize = require("game.shop.Chongzhi.ChongzhiItem").new():getContentSize()
	local function createFunc(index)
		local item = require("game.shop.Chongzhi.ChongzhiItem").new()
		return item:create({
		viewSize = self._shopItemViewSize,
		itemData = allItemData[index + 1]
		})
	end
	local function refreshFunc(cell, index)
		cell:refresh(allItemData[index + 1])
	end
	
	local cellNum = #allItemData
	--if game.player:getAppOpenData().c_yueka == APPOPEN_STATE.open then
	--	cellNum = #allItemData + 1
	--end
	self._shopListView = require("utility.TableViewExt").new({
	size = self._shopItemViewSize,
	direction = kCCScrollViewDirectionVertical,
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = cellNum,
	cellSize = cellContentSize,
	touchFunc = function(cell,x,y)
		local idx = cell:getIdx()
		if idx == #allItemData then
			local icon = cell:getIcon(4)
			local pos = icon:convertToNodeSpace(cc.p(x, y))
			if cc.rectContainsPoint(cc.rect(0, 0, icon:getContentSize().width, icon:getContentSize().height), pos) then
				GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
				if game.player:getAppOpenData().appstore == APPOPEN_STATE.close then
					self._shopListView:setTouchEnabled(false)
					buyListen(idx + 1, i, function(...)
						self._shopListView:setTouchEnabled(true)
					end)
				elseif GameStateManager.currentState == GAME_STATE.STATE_JINGCAI_HUODONG then
					game.runningScene:changeShowLayer(nbActivityShowType.MonthCard)
					self:removeSelf()
				else
					GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
					if not ENABLE_IAP_BUY then
						show_tip_label(common:getLanguageString("@HintPause"))
					elseif self._monthcardData.isCanBuy == 1 then
						do
							local _productID = tostring(self._monthcardData.type)
							local msgBox = require("game.shop.Chongzhi.ChongzhiBuyMonthCardMsgbox").new({
							leftDay = self._monthcardData.days or 0,
							confirmListen = function()
								local itemData = {}
								itemData.price = self._monthcardData.cost
								itemData.basegold = self._monthcardData.goldget
								itemData.index = ""
								itemData.type = self._monthcardData.type
								itemData.productName = common:getLanguageString("@Monthcard")
								itemData.payitemId = _productID
								itemData.isMonthCard = true
								itemData.coolpadItemId = 1
								self:buyItem(itemData, true)
							end
							})
							self:addChild(msgBox, MAX_ZORDER)
						end
					else
						show_tip_label(data_error_error[1800].prompt)
					end
				end
			end
		else
			for i = 1, 3 do
				local icon = cell:getIcon(i)
				local pos = icon:convertToNodeSpace(cc.p(x, y))
				local width2 = 154
				local width = icon:getContentSize().width
				local height2 = 110
				local height = icon:getContentSize().height
				if cc.rectContainsPoint(cc.rect((width - width2) / 2, (height - height2) / 2, width2, height2), pos) then
					self._shopListView:setTouchEnabled(false)
					buyListen(idx + 1, i, function(...)
						self._shopListView:setTouchEnabled(true)
					end)
					break
				end
			end
		end
	end
	})
	self._listViewNode:removeAllChildren()
	self._listViewNode:addChild(self._shopListView)
end


--[[购买]]
function ChongzhiLayer:buyItemMsgbox(param)
	local buyFunc = param.buyFunc
	local itemData = param.itemData
	local rowAll = {}
	local closeListener = param.closeListener
	local yellow = cc.c3b(255, 210, 0)
	local white = cc.c3b(255, 255, 255)
	local black = cc.c3b(0, 0, 0)
	local size = 24
	if 0 >= itemData.buyCnt then
		local rowOneTable = {}
		local lvTTF_1 = ResMgr.createOutlineMsgTTF({
		text = common:getLanguageString("@gou"),
		color = white,
		outlineColor = black,
		size = size
		})
		local lvTTF_2 = ResMgr.createOutlineMsgTTF({
		text = tostring(itemData.basegold),
		color = yellow,
		outlineColor = black,
		size = size
		})
		local lvTTF_3 = ResMgr.createOutlineMsgTTF({
		text = common:getLanguageString("@yuanbaos"),
		color = white,
		outlineColor = black,
		size = size
		})
		local lvTTF_4 = ResMgr.createOutlineMsgTTF({
		text = tostring(itemData.firstgold),
		color = yellow,
		outlineColor = black,
		size = size
		})
		local lvTTF_5 = ResMgr.createOutlineMsgTTF({
		text = common:getLanguageString("@yuanbao1"),
		color = white,
		outlineColor = black,
		size = size
		})
		local rowOneTable = {
		lvTTF_1,
		lvTTF_2,
		lvTTF_3,
		lvTTF_4,
		lvTTF_5
		}
		local rowTwoTable = {}
		local lvTTF_Two_1 = ResMgr.createOutlineMsgTTF({
		text = common:getLanguageString("@xiangou"),
		color = white,
		outlineColor = black,
		size = size
		})
		local lvTTF_Two_2 = ResMgr.createOutlineMsgTTF({
		text = "1",
		color = yellow,
		outlineColor = black,
		size = size
		})
		local lvTTF_Two_3 = ResMgr.createOutlineMsgTTF({
		text = common:getLanguageString("@ci"),
		color = white,
		outlineColor = black,
		size = size
		})
		local rowTwoTable = {
		lvTTF_Two_1,
		lvTTF_Two_2,
		lvTTF_Two_3
		}
		rowAll = {rowOneTable, rowTwoTable}
	else
		local rowOneTable = {}
		local lvTTF_1 = ResMgr.createOutlineMsgTTF({
		text = common:getLanguageString("@quedingyhf"),
		color = white,
		outlineColor = black,
		size = size
		})
		local lvTTF_2 = ResMgr.createOutlineMsgTTF({
		text = common:getLanguageCoin(itemData.price),
		color = yellow,
		outlineColor = black,
		size = size
		})
		local lvTTF_3 = ResMgr.createOutlineMsgTTF({
		text = common:getLanguageString("@Buy"),
		color = white,
		outlineColor = black,
		size = size
		})
		local lvTTF_4 = ResMgr.createOutlineMsgTTF({
		text = tostring(itemData.basegold),
		color = yellow,
		outlineColor = black,
		size = size
		})
		local lvTTF_5 = ResMgr.createOutlineMsgTTF({
		text = common:getLanguageString("@Goldlabel"),
		color = white,
		outlineColor = black,
		size = size
		})
		local rowOneTable = {
		lvTTF_1,
		lvTTF_2,
		lvTTF_3,
		lvTTF_4,
		lvTTF_5
		}
		local lvTTF_6 = ResMgr.createOutlineMsgTTF({
		text = "角色ID：",
		color = white,
		outlineColor = black,
		size = size
		})
		local lvTTF_7 = ResMgr.createOutlineMsgTTF({
		text = game.player:getPlayerID(),
		color = yellow,
		outlineColor = black,
		size = size
		})
		local lvTTF_8 = ResMgr.createOutlineMsgTTF({
		text = " 用于充值请务必记住。",
		color = white,
		outlineColor = black,
		size = size
		})
		local rowTwoTable = {
		lvTTF_6,
		lvTTF_7,
		lvTTF_8
		}
		local lvTTF_9 = ResMgr.createOutlineMsgTTF({
		text = "充值时ID将默认自动填写。",
		color = white,
		outlineColor = black,
		size = size
		})
		local rowThreeTable = {
		lvTTF_9
		}
		--[[
		local lvTTF_10 = ResMgr.createOutlineMsgTTF({
		text = "阶梯奖励：本次充值超过 ",
		color = white,
		outlineColor = black,
		size = size
		})
		local nLevel = self._cz
		if nLevel > 5 then
			nLevel = 5
		end
		local lvTTF_11 = ResMgr.createOutlineMsgTTF({
		text = czLevel[nLevel],
		color = yellow,
		outlineColor = black,
		size = size
		})
		local lvTTF_12 = ResMgr.createOutlineMsgTTF({
		text = " 元，元宝",
		color = white,
		outlineColor = black,
		size = size
		})
		
		local lvTTF_13 = ResMgr.createOutlineMsgTTF({
		text = "2",
		color = yellow,
		outlineColor = black,
		size = size
		})
		local lvTTF_14 = ResMgr.createOutlineMsgTTF({
		text = "倍",
		color = white,
		outlineColor = black,
		size = size
		})
		]]
		
		local lvTTF_20 = ResMgr.createOutlineMsgTTF({
		text = "首冲3倍：",
		color = white,
		outlineColor = black,
		size = size
		})
		local lvTTF_21 = ResMgr.createOutlineMsgTTF({
		text = "本次充值享受3倍元宝！",
		color = yellow,
		outlineColor = black,
		size = size
		})
		local rowFourTable = {
		--lvTTF_10,
		--lvTTF_11,
		--lvTTF_12,
		--lvTTF_13,
		--lvTTF_14
		}
		
		if self._frist == 1 then
			rowFourTable = {
			lvTTF_20,lvTTF_21
			}
		end
		rowAll = {rowOneTable,rowTwoTable,rowThreeTable,rowFourTable}
	end
	
	local msg = require("utility.MsgBoxEx").new({
	resTable = rowAll,
	confirmFunc = function(node)
		if buyFunc ~= nil then
			buyFunc()
		end
		if closeListener ~= nil then
			closeListener()
		end
		node:removeSelf()
	end,
	closeListener = closeListener
	})
	game.runningScene:addChild(msg, MAX_ZORDER)
end

function ChongzhiLayer:chongzhiCallBack(callbackFunc)
	self.callbackFunc = callbackFunc
end

return ChongzhiLayer