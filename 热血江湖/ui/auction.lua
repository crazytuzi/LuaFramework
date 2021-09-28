-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_auction = i3k_class("wnd_auction", ui.wnd_base)

local EQUIP_TYPE =
{
	[1] = true,
	[2] = true,
	[3] = true,
	[4] = true,
	[5] = true,
	[6] = true,
	[8] = true,
}
local f_changeStateSeverReq =
{
	[1] = function (itemType, page, order, rank, level, classType)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Auction,"sendCmd", itemType, "", page, order, rank, level, classType)
	end,
	[2] = function ()
		i3k_sbean.sync_auction_sale()
	end,
	[3] = function ()
		i3k_sbean.auction_log()
	end
}

local SORT_ORDER_RANK  = 2
local SORT_ORDER_PRICE = 1

function wnd_auction:ctor()
	self._buyState = 1
	self._saleState = 2
	self._recordState = 3

	self._buyType = 1
	self._buyPage = 1

	self._anis = false
	self._timeCounter = 0
	self._timeCounterFlag = false

	self._blue = "FFFFF0D5"
	self._yellow = "FFDBFF7A"
end

function wnd_auction:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	self._tabBar =
	{
		[1] = widgets.buyBtn,
		[2] = widgets.saleBtn,
		[3] = widgets.recordBtn,
	}
	for i,v in ipairs(self._tabBar) do
		v:setTag(i)
		if i==1 then
			v:stateToPressed()
		end
		v:onClick(self, self.onTabBarClick)
	end
	self._tabUI =
	{
		[1] = widgets.buyRoot,
		[2] = widgets.saleRoot,
		[3] = widgets.recordRoot,
	}
	for i,v in ipairs(self._tabUI) do
		v:hide()
		if i==1 then
			v:show()
		end
	end

	self._gradeTable = {
		[0] = {nameLabel = self._layout.vars.gradeLabel1, btn = self._layout.vars.gradeBtn1, color = self._yellow},
		[1] = {nameLabel = self._layout.vars.gradeLabel2, btn = self._layout.vars.gradeBtn2, color = g_i3k_get_color_by_rank(1)},
		[2] = {nameLabel = self._layout.vars.gradeLabel3, btn = self._layout.vars.gradeBtn3, color = g_i3k_get_color_by_rank(2)},
		[3] = {nameLabel = self._layout.vars.gradeLabel4, btn = self._layout.vars.gradeBtn4, color = g_i3k_get_color_by_rank(3)},
		[4] = {nameLabel = self._layout.vars.gradeLabel5, btn = self._layout.vars.gradeBtn5, color = g_i3k_get_color_by_rank(4)},
		[5] = {nameLabel = self._layout.vars.gradeLabel6, btn = self._layout.vars.gradeBtn6, color = g_i3k_get_color_by_rank(5)}
	}

	-- self._levelTable = {
	-- 	[-1] = {nameLabel = self._layout.vars.levelLabel1, btn = self._layout.vars.levelBtn1},
	-- 	[1] = {nameLabel = self._layout.vars.levelLabel2, btn = self._layout.vars.levelBtn2},
	-- 	[2] = {nameLabel = self._layout.vars.levelLabel3, btn = self._layout.vars.levelBtn3},
	-- 	[3] = {nameLabel = self._layout.vars.levelLabel4, btn = self._layout.vars.levelBtn4},
	-- 	[4] = {nameLabel = self._layout.vars.levelLabel5, btn = self._layout.vars.levelBtn5},
	-- }

	self._gradeTable[0].btn:stateToPressed()
	self._gradeTable[0].nameLabel:setTextColor(self._yellow)

	self._gradeTable_needValue = {}
	for i,v in pairs(self._gradeTable) do
		v.btn:setTag(i)
		v.btn:onClick(self, self.selectGrade, i)
	end

	-- self._levelTable[-1].btn:stateToPressed()
	-- self._levelTable[-1].nameLabel:setTextColor(self._yellow)

	self._layout.vars.help_btn:onClick(self, self.toHelp)
	self._selectLevel = 1 -- 等级
	self._selectRank = 0   -- 默认颜色品质
	self._selectType = 1
	self._selectOrder = 2  -- 默认

	self._layout.vars.clearInputBtn:onClick(self, self.clearInput)
	self._layout.vars.clearInputBtn:hide()
	self._layout.vars.searchInput:addEventListener(function(eventType)
		if eventType == "ended" then
			local str = self._layout.vars.searchInput:getText() or ""
			self._layout.vars.clearInputBtn:setVisible(str ~= "")
		end
	end)
	self._layout.vars.selectBtn:onClick(self, self.onSelectBtn)
	self._protocol_data = { itemType = 1 }

	self._layout.vars.gradeBtn:onClick(self, self.toSelectGrade)
	self._layout.vars.levelBtn:onClick(self, self.toSelectLevel)
	self._layout.vars.searchBtn:onClick(self, self.searchResult)
	self._layout.vars.rankBtn:onClick(self, self.sortByOrder, SORT_ORDER_RANK)
	self._layout.vars.priceBtn:onClick(self, self.sortByOrder, SORT_ORDER_PRICE)

end

function wnd_auction:onShow()
	local min = i3k_db_common.aboutAuction.onStoreMin / 60 -- 变成分钟
	local max = i3k_db_common.aboutAuction.onStoreMax / 60
	local text = string.format(i3k_get_string(3023, min, max))
	self._layout.vars.sealLabel:setText(text)
	self._layout.vars.buyLabel:setText(i3k_get_string(3025))
end

function wnd_auction:onUpdate(dTime)
	if self._timeCounterFlag then
		self._timeCounter = self._timeCounter + dTime
		if self._timeCounter > 0.5 then
			local data = self._protocol_data
			i3k_sbean.sync_auction(data.itemType, data.str, data.page, data.order, data.rank, data.level, data.classType, data.callback, data.itemID)
			i3k_log("======auction search:", data.itemType, data.str, data.page, data.order, data.rank, data.level, data.classType)
			g_i3k_ui_mgr:CloseUI(eUIID_AuctionSearching)
			self._timeCounterFlag = false
			self._timeCounter = 0
		end
	end
end

-- 封装一层函数
function wnd_auction:sendCmd(itemType, str, page, order, rank, level, classType, callback, itemID)
	self._timeCounterFlag = true
	local text = self._layout.vars.searchInput:getText() or "" -- 每次发送请求都从输入框中取内容
	self._protocol_data =
	{
		itemType = itemType,
		str = text,
		page = page,
		order = order, -- 颜色品质（0所有，1白色。。。）
		rank = rank,
		level = level,
		itemID = itemID,
		classType = classType,
		callback = callback,
	}
	if not g_i3k_db.i3k_db_test_auction_search_valid(str, itemType) then
		self._timeCounterFlag = false
		self._timeCounter = 0
		-- g_i3k_ui_mgr:PopupTipMessage("输入的搜索参数非法")
		return
	end
	g_i3k_ui_mgr:OpenUI(eUIID_AuctionSearching)
end

function wnd_auction:refresCreditLabel()
	local value = g_i3k_game_context:GetCredit()
	self._layout.vars.creditLabel:setText("商誉值："..value)
end


-- InvokeUIFunction
function wnd_auction:cancelSearch()
	self._timeCounterFlag = false
	self._timeCounter = 0
end

-- ShowClassType 非必要参数
function wnd_auction:refresh(itemType, showClassType)
	local scrollLeft = self._layout.vars.buyScrollLeft
	scrollLeft:setBounceEnabled(false)
	scrollLeft:removeAllChildren(true)
	local index = 1
	local typeTable = {}
	for i,v in pairs(i3k_db_auction_type) do
		table.insert(typeTable, v)
	end
	table.sort(typeTable, function (a, b)
		return a.typeId<b.typeId
	end)
	for i,v in ipairs(typeTable) do
		local node = require("ui/widgets/goumait1")()
		node.vars.nameLabel:setText(v.name)
		--node.vars.nameLabel:setTextColor(itemType==v.typeId and self._yellow or self._blue)
		node.vars.openImg:setVisible(itemType==v.typeId)
		node.vars.pickupImg:setVisible(itemType~=v.typeId)
		scrollLeft:addItem(node)
		node.vars.btn:setTag(v.typeId)
		if itemType==v.typeId then
			node.vars.btn:stateToPressed()
			index = i
			if g_auction_classType[itemType] then
				node.vars.btn:onClick(self, self.pickUpList, index)
				for _,t in ipairs(i3k_db_generals) do
					local widget = require("ui/widgets/goumait2")()
					widget.vars.nameLabel:setText(t.name)
					if classType and classType==t.id then
						widget.vars.nameLabel:setTextColor(self._yellow)
					end
					if showClassType and showClassType == t.id then -- 从筛选那边传递过来的参数
						widget.vars.btn:stateToPressed()
					end
					local needValue = {classType = t.id, itemType = v.typeId, page = 1, order = 2, rank = 0, level = 0}
					widget.vars.btn:setTag(t.id)
					widget.vars.btn:onClick(self, self.selectOccupation, needValue) -- 点小的
					scrollLeft:addItem(widget)
				end
			end
		else
			node.vars.btn:onClick(self, self.selectItemType) -- 点大的
		end
	end
	scrollLeft:jumpToChildWithIndex(index)

	self._layout.vars.gradeRoot:hide()
	self._layout.vars.levelRoot:hide()
	self._layout.vars.levelScroll:hide()
	self:refresCreditLabel()
end

function wnd_auction:pickUpList(sender, index)
	local children = self._layout.vars.buyScrollLeft:getAllChildren()
	for i=1, #i3k_db_generals do
		self._layout.vars.buyScrollLeft:removeChildAtIndex(index + 1)
	end
	children[index].vars.btn:onClick(self, self.selectItemType)
	children[index].vars.openImg:hide()
	children[index].vars.pickupImg:show()
end

--[[function 购买相关()
	end--]]
function wnd_auction:loadBuyData(allItems, itemType, page, order, rank, level, isLastPage, classType, itemID)
	self._curPage = page
	self._layout.vars.pageLabel:setText(page)
	local needValuePageLeft = {itemType = itemType, page = page-1, order = order, rank = rank, level = level, classType = classType, itemID = itemID}
	self._needValuePageLeft = needValuePageLeft

	local needValuePageRight = {itemType = itemType, page = page+1, order = order, rank = rank, level = level, isLastPage = isLastPage, classType = classType, itemID = itemID}
	self._needValuePageRight = needValuePageRight

	local needValuePageLeftTen = {itemType = itemType, page = page-10, order = order, rank = rank, level = level, classType = classType, itemID = itemID}
	self._needValuePageLeftTen = needValuePageLeftTen

	local needValuePageRightTen = {itemType = itemType, page = page+10, order = order, rank = rank, level = level, isLastPage = isLastPage, classType = classType, itemID = itemID}
	self._needValuePageRightTen = needValuePageRightTen


	if not self._onClickPageBtn then
	    self._onClickPageBtn = true
	    self._layout.vars.pageLeft:onClick(self, self.pageBefore)
	    self._layout.vars.pageRight:onClick(self, self.pageNext)
	    self._layout.vars.left10Btn:onClick(self, self.onLeftTenBtn)
	    self._layout.vars.right10Btn:onClick(self, self.onRightTenBtn)
	end

	if isLastPage~=1 then
		self._layout.anis.ss.play(-1)
		self._anis = true
	else
		self._layout.anis.ss.stop()
		self._anis = false
	end
	local priceImg = self._layout.vars.priceSortImg
	local rankImg = self._layout.vars.rankSortImg
	if math.abs(order)==1 then
		priceImg:show()
		rankImg:hide()
		if order==1 then
			priceImg:setScale(-1)
		else
			priceImg:setScale(1)
		end
	else
		priceImg:hide()
		rankImg:show()
		if order==2 then
			rankImg:setScale(-1)
		elseif order==-2 then
			rankImg:setScale(1)
		end
	end

	self._layout.vars.gradeLabel:setText(self._gradeTable[rank].nameLabel:getText())
	-- self._layout.vars.levelLabel:setText(self._levelTable[level].nameLabel:getText())


	self._layout.vars.buyScrollRight:removeAllChildren()

	self._layout.vars.powerOrRankLabel:setText(itemType>10 and "品 质" or "战 力")
	local needOrderRank = 2
	if order == 2 then
		needOrderRank = -2
	elseif order == -2 then
		needOrderRank = 2
	end


	local needValueRank = {itemType = itemType, page = page, order = needOrderRank, rank = rank, level = level, isLastPage = isLastPage, classType = classType, itemID = itemID}
	self._rankBtn_needValueRank = needValueRank

	local needOrderPrice = 1
	if order == 1 then
		needOrderPrice = -1
	elseif order == -1 then
		needOrderPrice = 1
	end

	local needValuePrice = {itemType = itemType, page = page, order = needOrderPrice, rank = rank, level = level, isLastPage = isLastPage, classType = classType, itemID = itemID}
	self._priceBtn_needValuePrice = needValuePrice
	self._layout.vars.selectGradeRoot:setVisible(itemType<=10)
	self._layout.vars.selectLvlRoot:setVisible(itemType<=10)

	for i,v in ipairs(allItems) do
		local id = v.items.id
		local equip
		local node = require("ui/widgets/goumait4")()
		node.vars.gradeIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
		node.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))
		node.vars.nameLabel:setText(g_i3k_db.i3k_db_get_common_item_name(id))
		local needRank = g_i3k_db.i3k_db_get_common_item_rank(id)
		node.vars.nameLabel:setTextColor(g_i3k_get_color_by_rank(needRank))
		if itemType>10 then
			node.vars.countLabel:setVisible(v.items.count>1)
			node.vars.countLabel:setText(v.items.count)
			node.vars.powerLabel:setText(self._gradeTable[needRank].nameLabel:getText())
			node.vars.powerLabel:setTextColor(self._gradeTable[needRank].color)
		else
			equip = v.items.equip and g_i3k_get_equip_from_bean(v.items.equip)
			local needLevel = g_i3k_db.i3k_db_get_common_item_level_require(id)
			node.vars.countLabel:setText(needLevel .. "级")
			local equipPower = g_i3k_game_context:GetBagEquipPower(id, v.items.equip.addValues, v.items.equip.durability, v.items.equip.refine, v.items.equip.legends, v.items.equip.smeltingProps)
			node.vars.powerLabel:setText(equipPower)
			if v.items.equip.durability and v.items.equip.durability ~= -1 then -- 水晶装备
				local rank = g_i3k_db.i3k_db_get_common_item_rank(id)
				node.vars.purpleTX:setVisible(rank == g_RANK_VALUE_PURPLE)
				node.vars.orangeTX:setVisible(rank == g_RANK_VALUE_ORANGE)
			end
		end
		node.vars.priceLabel:setText(v.items.price)
		--local needValue = {item = v.items, dealId = v.cid, serverId = v.serverID, salerId = v.roleID, itemType = itemType, page = page, order = order, rank = rank, level = level, classType = classType}
		local needValue = {item = v.items, dealId = v.cid, salerId = v.roleID, itemType = itemType, page = page, order = order, rank = rank, level = level, classType = classType}
		node.vars.buyBtn:onClick(self, self.buyItem, needValue)
		node.vars.infoBtn:onClick(self, function ()
			if itemType>10 then
				g_i3k_ui_mgr:ShowCommonItemInfo(id)
			else
				g_i3k_ui_mgr:ShowCommonEquipInfo(equip)
			end
		end)
		self._layout.vars.buyScrollRight:addItem(node)
	end

	local needValueGradeAndLevel = {itemType = itemType, page = page, order = order, rank = rank, level = level, classType = classType}
	self._gradeTable_needValue = needValueGradeAndLevel

	-- for i,v in pairs(self._levelTable) do
	-- 	v.btn:setTag(i)
	-- 	v.btn:onClick(self, self.selectLevel, needValueGradeAndLevel)
	-- end
	self._layout.vars.levelScroll:removeAllChildren()
	for i=1, (#g_i3k_db.i3k_db_get_auction_select_level() + 1), 1 do
		local node = require("ui/widgets/pmht")()
		node.vars.levelBtn:setTag(i)
		local text = self:getLevelString(i)
		node.vars.levelLabel:setText(text)
		node.vars.levelBtn:onClick(self, self.selectLevel, needValueGradeAndLevel)
		self._layout.vars.levelScroll:addItem(node)
	end
	self._layout.vars.levelScroll:hide()
	self:setUIVisible(self._buyState)
end

function wnd_auction:toSelectGrade(sender)
	self._layout.vars.gradeRoot:setVisible(not self._layout.vars.gradeRoot:isVisible())
	self._layout.vars.levelRoot:hide()
	self._layout.vars.levelScroll:hide()
end

function wnd_auction:getBeginEndLevel(id)
	local table = g_i3k_db.i3k_db_get_auction_select_level()
	if id == 1 then
		return 1, table[1]
	else
		return table[id - 1] + 1 , table[id]
	end
end
function wnd_auction:getLevelString(id)
	if id == 1 then
		return "全部等级"
	else
		local a, b = self:getBeginEndLevel(id - 1)
		return a.."~"..b.."级"
	end
end

function wnd_auction:setLevelScroll(level)
	local children = self._layout.vars.levelScroll:getAllChildren()
	for i, v in ipairs(children)do
		if v.vars.levelBtn:getTag() ~= level then
			v.vars.levelBtn:stateToNormal()
			v.vars.levelLabel:setTextColor(self._blue)
		else
			v.vars.levelBtn:stateToPressed()
			v.vars.levelLabel:setTextColor(self._yellow)
		end
	end
end

function wnd_auction:toSelectLevel(sender)
	local vis = self._layout.vars.levelRoot:isVisible()
	self._layout.vars.levelRoot:setVisible(not vis)
	self._layout.vars.levelScroll:setVisible(not vis)
	if not vis then
		local level = self._selectLevel
		self._layout.vars.levelLabel:setText(self:getLevelString(level))
		self:setLevelScroll(level)
	end
	self._layout.vars.gradeRoot:hide()
end

-- 选择品质
function wnd_auction:selectGrade(sender, i)
	local needValue = self._gradeTable_needValue
	if not needValue then return end
	local rank = sender:getTag()
	self._selectRank = rank
	self._layout.vars.gradeLabel:setText(self._gradeTable[rank].text)
	--self._layout.vars.gradeLabel:setTextColor(self._gradeTable[rank].color)
	for i,v in pairs(self._gradeTable) do
		if i~=rank then
			v.btn:stateToNormal()
			v.nameLabel:setTextColor(self._blue)
		else
			v.btn:stateToPressed()
			v.nameLabel:setTextColor(self._yellow)
		end
	end
	self._layout.vars.gradeRoot:hide()
	--发协议查询
	self:sendCmd(needValue.itemType, "", needValue.page, needValue.order, rank, needValue.level, needValue.classType)
end

-- 选择等级
function wnd_auction:selectLevel(sender, needValue)
	local level = sender:getTag()
	self._selectLevel = level
	self._layout.vars.levelLabel:setText(self:getLevelString(level))
	self:setLevelScroll(level)
	self._layout.vars.levelRoot:hide()
	self._layout.vars.levelScroll:hide()
	--发协议查询
	self:sendCmd(needValue.itemType, "", needValue.page, needValue.order, needValue.rank, level - 1, needValue.classType)
end

-- 点击搜索按钮
function wnd_auction:searchResult(sender)
	local str = self._layout.vars.searchInput:getText() or ""
	self:sendCmd(self._selectType, str, 1, self._selectOrder, self._selectRank, self._selectLevel - 1, self._selectClassType)
end

function wnd_auction:clearInput(sender)
	self._layout.vars.searchInput:setText("")
	self._layout.vars.clearInputBtn:hide()
end

function wnd_auction:buyItem(sender, needValue)
	local canUseDiamond = g_i3k_game_context:GetDiamondCanUse(true)
	local item = needValue.item
	local isEnoughTable = {[item.id] = item.count}
	local isenough = g_i3k_game_context:IsBagEnough(isEnoughTable)
	local myId = g_i3k_game_context:GetRoleId()
	local needCredit = g_i3k_game_context:buyEquipUseCredit(item.price, item.count, needValue.itemType)
	local totalCredit = g_i3k_game_context:GetCredit()
	--if needValue.serverId==i3k_game_get_server_id() and needValue.salerId==myId then
	if needValue.salerId==myId then
		local str = string.format("%s", "不能买自己的东西")
		g_i3k_ui_mgr:PopupTipMessage(str)
	elseif canUseDiamond<item.price then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(244))
	elseif not isenough then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(215))
	elseif needCredit > totalCredit then
		g_i3k_ui_mgr:ShowMessageBox1(i3k_get_string(3024, needCredit, totalCredit))
	else
		local str = i3k_get_string(245, item.price, item.count, g_i3k_db.i3k_db_get_common_item_name(item.id))
		local callbackMessageBox = function (isOk)
			if isOk then
				--买东西，买完了根据needValue.itemType,needValue.page,needValue.classType刷新当前界面，注意根据classType进行判断发哪个协议
				local callback
				if needValue.classType then
					if needValue.classType == 0 then -- 装备,目前只有装备消耗商誉值
						callback = function ()
							g_i3k_ui_mgr:InvokeUIFunction(eUIID_Auction, "sendCmd", needValue.itemType, "", needValue.page, needValue.order, needValue.rank, needValue.level)
							g_i3k_game_context:UseCommonItem(g_BASE_ITEM_CREDIT, needCredit, AT_BUY_AUCTION_ITEMS)
						end
					else
						callback = function ()
							g_i3k_ui_mgr:InvokeUIFunction(eUIID_Auction, "sendCmd", needValue.itemType, "", needValue.page, needValue.order, needValue.rank, needValue.level)
							g_i3k_ui_mgr:InvokeUIFunction(eUIID_Auction, "selectOccupation", sender, needValue)--这里边的sender不对,但是不影响程序运行
						end
					end
				else
					callback = function ()
						g_i3k_ui_mgr:InvokeUIFunction(eUIID_Auction, "sendCmd", needValue.itemType, "", needValue.page, needValue.order, needValue.rank, needValue.level)
						g_i3k_game_context:UseCommonItem(g_BASE_ITEM_CREDIT, needCredit, AT_BUY_AUCTION_ITEMS)
					end
				end
				--i3k_sbean.buyItem(needValue.dealId, needValue.serverId, needValue.salerId, item, callback)
				i3k_sbean.buyItem(needValue.dealId, needValue.salerId, item, needValue.itemType, callback)
			end
		end
		local func = function (isOk)
			if isOk then
				g_i3k_ui_mgr:ShowMessageBox2(str, callbackMessageBox)
			end
		end
		if self:CanUse(needValue) then
			g_i3k_ui_mgr:ShowMessageBox2(str, callbackMessageBox)
		else
			g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(16368), func)
		end
		--g_i3k_ui_mgr:ShowMessageBox2(str, callbackMessageBox)
	end
end

function wnd_auction:CanUse(needValue)
	local classType = g_i3k_game_context:GetRoleType()
	local bwType = g_i3k_game_context:GetTransformBWtype()
	if needValue.itemType == 18 then -- 气功书
		local itemId = math.abs(needValue.item.id)
		local qigongBw = i3k_db_auction_search_xinfa[needValue.itemType][itemId].bwType
		local qigongType = i3k_db_auction_search_xinfa[needValue.itemType][itemId].classType
		if (qigongBw == 0 or qigongBw == bwType) and (qigongType == -1 or qigongType == classType) then
			return true
		else
			return false
		end
	elseif needValue.itemType <= 10 then -- 装备
		local equipId = math.abs(needValue.item.equip.id)
		local equipType = g_i3k_db.i3k_db_get_equip_item_cfg(equipId).roleType
		local equipBw = g_i3k_db.i3k_db_get_equip_item_cfg(equipId).M_require
		if (bwType == 0 or equipBw == 0 or bwType == equipBw) and (classType == equipType or 0 == equipType) then
			return true
		else
			return false
		end
	else
		return true
	end
end

function wnd_auction:pageBefore(sender)
	local needValue = self._needValuePageLeft
	if needValue.page==0 then
		local str = string.format("%s", "已经是第一页了")
		g_i3k_ui_mgr:PopupTipMessage(str)
	else
		if needValue.classType then
			self:selectOccupation(sender, needValue)--这里边的sender不对,但是不影响程序运行
		else
			local text = self._layout.vars.searchInput:getText() or ""
			self:sendCmd(needValue.itemType, text, needValue.page, needValue.order, needValue.rank, needValue.level, needValue.itemID)
		end
	end
end

function wnd_auction:pageNext(sender)
	local needValue = self._needValuePageRight
	if needValue.isLastPage==1 then
		local str = string.format("%s", "已经是最后一页了")
		g_i3k_ui_mgr:PopupTipMessage(str)
	else
		if needValue.classType then
			self:selectOccupation(sender, needValue)--这里边的sender不对,但是不影响程序运行
		else
			local text = self._layout.vars.searchInput:getText() or ""
			self:sendCmd(needValue.itemType, text, needValue.page, needValue.order, needValue.rank, needValue.level, needValue.itemID)
		end
	end
end

function wnd_auction:onLeftTenBtn(sender)
	local needValue = self._needValuePageLeftTen
	if self._curPage == 1 then
		local str = string.format("%s", "已经是第一页了")
		g_i3k_ui_mgr:PopupTipMessage(str)
	else
		if needValue.page <= 0 then
			needValue.page = 1
		end
		if needValue.classType then
			self:selectOccupation(sender, needValue)--这里边的sender不对,但是不影响程序运行
		else
			local text = self._layout.vars.searchInput:getText() or ""
			self:sendCmd(needValue.itemType, text, needValue.page, needValue.order, needValue.rank, needValue.level, needValue.itemID)
		end
	end
end
function wnd_auction:onRightTenBtn(sender)
	local needValue = self._needValuePageRightTen
	if needValue.isLastPage == 1 then
		local str = string.format("%s", "已经是最后一页了")
		g_i3k_ui_mgr:PopupTipMessage(str)
	else
		if needValue.classType then
			self:selectOccupation(sender, needValue)--这里边的sender不对,但是不影响程序运行
		else
			local text = self._layout.vars.searchInput:getText() or ""
			self:sendCmd(needValue.itemType, text, needValue.page, needValue.order, needValue.rank, needValue.level, needValue.itemID)
		end
	end
end

-- 寄售行搜索中的数据，重新绑定监听器
function wnd_auction:onResetBtnClickData(data, name, itemID)
	-- self._layout.vars.searchInput:setText(name)
	local needValuePageLeft = {itemType = data.itemType, page = data.page-1, order = data.order, rank = data.rank, level = data.level, classType =  data.classType, itemID = itemID}
	self._needValuePageLeft = needValuePageLeft
	local needValuePageRight = {itemType = data.itemType, page = data.page+1, order = data.order, rank = data.rank, level = data.level, classType =  data.classType, itemID = itemID}
	self._needValuePageRight = needValuePageRight
	local needValuePageLeftTen = {itemType = data.itemType, page = data.page-10, order = data.order, rank = data.rank, level = data.level, classType =  data.classType, itemID = itemID}
	self._needValuePageLeftTen = needValuePageLeftTen
	local needValuePageRightTen = {itemType = data.itemType, page = data.page+10, order = data.order, rank = data.rank, level = data.level, classType =  data.classType, itemID = itemID}
	self._needValuePageRightTen = needValuePageRightTen

	if not self._onClickPageBtn then
		self._onClickPageBtn = true
		self._layout.vars.pageLeft:onClick(self, self.pageBefore)
		self._layout.vars.pageRight:onClick(self, self.pageNext)
		self._layout.vars.left10Btn:onClick(self, self.onLeftTenBtn)
		self._layout.vars.right10Btn:onClick(self, self.onRightTenBtn)
	end
end


function wnd_auction:sortByOrder(sender, order)
	local needValue
	if order == SORT_ORDER_PRICE then
		needValue = self._priceBtn_needValuePrice
	elseif order == SORT_ORDER_RANK then
		needValue = self._rankBtn_needValueRank
	end
	if not needValue then return end

	self._selectOrder = needValue.order
	self:sendCmd(needValue.itemType, "", 1, needValue.order, needValue.rank, needValue.level, needValue.classType, nil, needValue.itemID)
end

-- 点击左侧大标签
function wnd_auction:selectItemType(sender)
	local typeId = sender:getTag()
	self._selectType = typeId
	local callback = function (itemType)
		g_i3k_ui_mgr:RefreshUI(eUIID_Auction, itemType)
	end
	local classType = nil
	if EQUIP_TYPE[typeId] then
		classType = 0 -- 默认装备，不区分职业
	end
	self:sendCmd(typeId, "", 1, 2, 0, 0, classType, callback)
end

-- 点击大标签下的小标签
function wnd_auction:selectOccupation(sender, needValue)
	self._selectType = needValue.itemType
	self._selectClassType = needValue.classType
	local callback = function ()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Auction, "selectOccupationCB", needValue)
	end
	self:sendCmd(needValue.itemType, "", needValue.page, needValue.order, needValue.rank, needValue.level, needValue.classType, callback, needValue.itemID)
end

function wnd_auction:selectOccupationCB(needValue)
	local children = self._layout.vars.buyScrollLeft:getAllChildren()
	if children then
		local list = {}
		for k, v in pairs(i3k_db_auction_type) do
			table.insert(list, v)
		end
		table.sort(list, function (a, b)
			return a.typeId < b.typeId
		end)
		for i,v in ipairs(children) do
			-- i 连续，但是 needValue.itemType 不连续
			if list[i].typeId == needValue.itemType then
				for k = 1, #i3k_db_generals do
					if children[i + k] then
						local btn = children[i + k].vars.btn
						local tag = btn:getTag()
						if tag == needValue.classType then
							btn:stateToPressed()
						else
							btn:stateToNormal()
						end
					end
				end
				return;
			end
		end
	end
end





--function 售卖相关() end
function wnd_auction:loadSaleData(items, bagItems, cellSize, expandTimes)
	local scrollRight = self._layout.vars.saleScrollRight
	scrollRight:setBounceEnabled(false)

	local itemsCount = 0
	local saleItems = {}
	for i,v in pairs(items) do
		v.dealId = i
		table.insert(saleItems, v)
		itemsCount = itemsCount + 1
	end

	--右侧数据
	local itemCount = #bagItems
	local totalCount = 5*7
	if itemCount>totalCount then
		totalCount = totalCount + math.ceil((itemCount-totalCount)/5)*5
	end
	local children = scrollRight:addChildWithCount("ui/widgets/jishout1", 5, totalCount)
	for i,v in ipairs(children) do
		if i<=itemCount then
			local id = bagItems[i].id
			local count = bagItems[i].count
			local durability = bagItems[i].durability
			local canPutOn = itemsCount<cellSize
			if canPutOn then
				v.vars.btn:onClick(self, self.checkItemInfo, bagItems[i])
			else
				v.vars.btn:onClick(self, function ()
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(249))
				end)
			end
			v.vars.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
			v.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))
			v.vars.item_count:setText(count)
			v.vars.item_count:setVisible(count>1)
			if durability ~= -1 then -- 水晶装备
				local rank = g_i3k_db.i3k_db_get_common_item_rank(id)
				v.vars.purpleTX:setVisible(rank == g_RANK_VALUE_PURPLE)
				v.vars.orangeTX:setVisible(rank == g_RANK_VALUE_ORANGE)
			end
		else
			v.vars.item_count:hide()
		end
	end

	--左侧数据
	--self:setSaleItemInfo(cellSize, expandTimes)
	self._expandTimes = expandTimes
	local scrollLeft = self._layout.vars.saleScrollLeft
	scrollLeft:setBounceEnabled(false)
	local maxCount = 0
	for i,v in pairs(i3k_db_kungfu_vip) do
		if v.auctionBooth>maxCount then
			maxCount = v.auctionBooth
		end
	end

	local vipLvl = g_i3k_game_context:GetVipLevel()

	local children = scrollLeft:addChildWithCount("ui/widgets/jishout2", 2, maxCount)
	local expandIndex = 0
	for i,v in ipairs(children) do
		v.vars.itemRoot:setVisible(i<=itemsCount)
		v.vars.emptyRoot:setVisible(i>itemsCount and i<=cellSize)
		v.vars.lockRoot:setVisible(i>cellSize)
		if i<=itemsCount then
			local id = saleItems[i].id
			local count = saleItems[i].count
			v.vars.gradeIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
			v.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))
			--v.vars.countLabel:setText("x"..count)
			local itemType = g_i3k_db.i3k_db_get_auction_item_type(id)
			if itemType>10 then
				v.vars.countLabel:setVisible(count>1)
				v.vars.countLabel:setText(count)
			else
				local needLevel = g_i3k_db.i3k_db_get_common_item_level_require(id)
				v.vars.countLabel:setText(needLevel.."级")
			end
			v.vars.nameLabel:setText(g_i3k_db.i3k_db_get_common_item_name(id))
			local rank = g_i3k_db.i3k_db_get_common_item_rank(id)
			v.vars.nameLabel:setTextColor(g_i3k_db.g_i3k_get_color_by_rank(rank))
			--v.vars.coinImage:setImage()
			v.vars.coinCountLabel:setText("x"..saleItems[i].price)
			v.vars.btn:onClick(self, self.onPutOff, saleItems[i])
			if saleItems[i].equip and saleItems[i].equip.durability ~= -1 then -- 水晶装备
				v.vars.purpleTX:setVisible(rank == g_RANK_VALUE_PURPLE)
				v.vars.orangeTX:setVisible(rank == g_RANK_VALUE_ORANGE)
			end
		elseif i>itemsCount and i<=cellSize then

		else
			local needVipLevel
			for _,t in ipairs(i3k_db_kungfu_vip) do
				if i<=t.auctionBooth then
					needVipLevel = t.level
					break
				end
			end
			local str = string.format("贵族%d解锁", needVipLevel)
			if vipLvl>=needVipLevel then
				str = string.format("点击解锁")
				expandIndex = expandIndex + 1
				v.vars.btn:setTag(expandTimes+expandIndex)
				v.vars.btn:onClick(self, self.onExpand, expandTimes)
			end
			v.vars.lockLabel:setText(str)
		end
	end

	self:setUIVisible(self._saleState)
end

function wnd_auction:loadSaleLeftData()
	local scrollLeft = self._layout.vars.saleScrollLeft
	--scrollLeft:removeAllChildren()
	local maxCount = 0
	for i,v in pairs(i3k_db_kungfu_vip) do
		if v.auctionBooth>maxCount then
			maxCount = v.auctionBooth
		end
	end
	local vipLvl = g_i3k_game_context:GetVipLevel()
	local children = scrollLeft:getAllChildren()
	local expandIndex = 0
	for i,v in ipairs(children) do
		if v.vars.lockRoot:isVisible() then
			local needVipLevel
			for _,t in ipairs(i3k_db_kungfu_vip) do
				if i<=t.auctionBooth then
					needVipLevel = t.level
					break
				end
			end
			local str = string.format("贵族%d解锁", needVipLevel)
			if vipLvl>=needVipLevel then
				str = string.format("点击解锁")
				expandIndex = expandIndex + 1
				v.vars.btn:setTag(self._expandTimes+expandIndex)
				v.vars.btn:onClick(self, self.onExpand, self._expandTimes)
			end
			v.vars.lockLabel:setText(str)
		end
	end

end

function wnd_auction:onPutOff(sender, item)
	local uiid = item.equip and eUIID_PutOffEquip or eUIID_AuctionPutOff
	g_i3k_ui_mgr:OpenUI(uiid)
	g_i3k_ui_mgr:RefreshUI(uiid, item)
end

function wnd_auction:checkItemInfo(sender, item)
	i3k_sbean.query_advise_price(item)
	--[[if item.guid then
		local equip = g_i3k_game_context:GetBagEquip(item.id, item.guid)
		g_i3k_ui_mgr:OpenUI(eUIID_SaleEquip)
		g_i3k_ui_mgr:RefreshUI(eUIID_SaleEquip, item, equip)
	else
		g_i3k_ui_mgr:OpenUI(eUIID_SaleProp)
		g_i3k_ui_mgr:RefreshUI(eUIID_SaleProp, item)
	end--]]
end

function wnd_auction:onExpand(sender, hasExpandTimes)
	local expandTimes = sender:getTag()
	local costTable = i3k_db_common.aboutAuction.price
	local needPrice = 0
	for i=hasExpandTimes+1, expandTimes do
		needPrice = costTable[i] + needPrice
	end
	local canUseMoney = g_i3k_game_context:GetMoneyCanUse(false)
	if needPrice<=canUseMoney then
		local desc = i3k_get_string(247, needPrice, expandTimes-hasExpandTimes)
		local callback = function (isOk)
			if isOk then
				i3k_sbean.auction_expand(expandTimes, needPrice)
			end
		end
		g_i3k_ui_mgr:ShowMessageBox2(desc, callback)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(248))
	end
end


--------function 记录相关() end
function wnd_auction:loadRecordData(logs)
	local recordScroll = self._layout.vars.recordScroll
	recordScroll:removeAllChildren()
	for i,v in ipairs(logs) do
		local node = require("ui/widgets/jilvt")()
		recordScroll:addItem(node)
		local id = v.id
		node.vars.nameLabel:setText(g_i3k_db.i3k_db_get_common_item_name(id))
		local rank = g_i3k_db.i3k_db_get_common_item_rank(id)
		node.vars.nameLabel:setTextColor(g_i3k_get_color_by_rank(rank))
		node.vars.countLabel:setText(v.count)
		node.vars.gradeIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
		node.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))
		local time = os.date("%Y-%m-%d", g_i3k_get_GMTtime(v.time))
		node.vars.dateLabel:setText(time)
		local price = v.price
		node.vars.priceLabel:setText(price)
		local stateTable = {"售出", "购入"}
		node.vars.stateLabel:setText(price<0 and stateTable[2] or stateTable[1])
		node.vars.lock:setVisible(false) -- 现在改为全部是绑定元宝
		node.vars.priceLabel:setTextColor(price<0 and g_i3k_get_red_color() or g_i3k_get_green_color())
		node.vars.stateLabel:setTextColor(price<0 and g_i3k_get_red_color() or g_i3k_get_green_color())
	end
	self:setUIVisible(self._recordState)
end

function wnd_auction:setUIVisible(state)
	self._state = state
	for i,v in ipairs(self._tabUI) do
		if i==state then
			v:show()
			if i==self._buyState and self._anis then
				self._layout.anis.ss.play(-1)
			end
		else
			v:hide()
		end
	end
end

function wnd_auction:onTabBarClick(sender)
	local state = sender:getTag()
	for i,v in ipairs(self._tabBar) do
		v:stateToNormal()
	end
	sender:stateToPressed()
	if state~=self._buyState then
		f_changeStateSeverReq[state]()
	end
	if state==self._recordState or state==self._buyState then
		self:setUIVisible(state)
	end
end

function wnd_auction:reloadAuctionData()
	local state = 1
	for i,v in ipairs(self._tabBar) do
		if v:isStatePressed() then
			state = i
			break
		end
	end
	f_changeStateSeverReq[state]()
end

function wnd_auction:toHelp(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(585))
end

function wnd_auction:onSelectBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_AuctionSelect)
	g_i3k_ui_mgr:RefreshUI(eUIID_AuctionSelect, self._protocol_data.itemType, self._protocol_data.classType or 0)
end

function wnd_create(layout, ...)
	local wnd = wnd_auction.new()
	wnd:create(layout, ...)
	return wnd;
end
