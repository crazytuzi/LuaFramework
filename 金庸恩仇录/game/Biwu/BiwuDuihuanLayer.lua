local ZORDER = 100

local BiwuDuihuanLayer = class("BiwuDuihuanLayer", function()
	return display.newLayer("BiwuDuihuanLayer")
end)

function BiwuDuihuanLayer:setUpView(param)
	local titleBng = display.newSprite("#arena_shengwang_bg.png")
	titleBng:setPosition(cc.p(param.size.width * 0.5, param.size.height * 0.94))
	self:addChild(titleBng, 10)
	titleBng:setTouchEnabled(true)
	local titleIcon = display.newSprite("#rongyu.png")
	titleIcon:setPosition(cc.p(titleBng:getContentSize().width * 0.38, titleBng:getContentSize().height * 0.5))
	titleBng:addChild(titleIcon)
	local starIcon = display.newSprite("#rongyu_icon.png")
	starIcon:setPosition(cc.p(titleBng:getContentSize().width * 0.51, titleBng:getContentSize().height * 0.5))
	titleBng:addChild(starIcon)
	self.nameDis = ui.newTTFLabel({
	text = self.rongyu,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT,
	size = 30,
	color = cc.c3b(238, 184, 104)
	})
	self.nameDis:setAnchorPoint(cc.p(0, 0.5))
	self.nameDis:setPosition(titleBng:getContentSize().width * 0.55, titleBng:getContentSize().height * 0.5)
	titleBng:addChild(self.nameDis)
	local function createFunc(index)
		local item = require("game.Biwu.BiwuDuihuanItem").new()
		return item:create({
		viewSize = cc.size(param.size.width, param.size.width / 3),
		cellData = self._data[index + 1],
		listener = handler(self, BiwuDuihuanLayer.commitResqust),
		index = index
		})
	end
	local function refreshFunc(cell, index)
		cell:refresh({
		viewSize = cc.size(param.size.width, param.size.width / 3),
		cellData = self._data[index + 1],
		listener = handler(self, BiwuDuihuanLayer.commitResqust),
		index = index
		})
	end
	local boardWidth = param.size.width
	local boardHeight = param.size.height
	self._tableView = require("utility.TableViewExt").new({
	size = cc.size(boardWidth, boardHeight - titleBng:getContentSize().height - 10),
	direction = kCCScrollViewDirectionVertical,
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #self._data,
	cellSize = cc.size(boardWidth, param.size.width / 3)
	})
	self._tableView:setPosition(0, 0)
	self._tableView:setAnchorPoint(cc.p(0, 0))
	self:addChild(self._tableView)
end

function BiwuDuihuanLayer:remove()
	self:removeFromParent()
end

function BiwuDuihuanLayer:ctor(param)
	self._viewSize = param.size
	self:setContentSize(param.size)
	local function fuc()
		self:setUpView(param)
	end
	self:_getData(fuc)
end

function BiwuDuihuanLayer:commitResqust(index)
	local itemData = {
	name = self._data[index + 1].name,
	iconType = self._data[index + 1].iconType,
	id = self._data[index + 1].item,
	had = self._data[index + 1].had,
	limitNum = self._data[index + 1].num1,
	needReputation = self._data[index + 1].price
	}
	if self._data[index + 1].num1 == 0 then
		show_tip_label(common:getLanguageString("@NotChangeNumber"))
		return
	end
	--[[
	local popup = require("game.Biwu.ExchangeCountBox").new({
	reputation = self.rongyu,
	itemData = itemData,
	listener = function(num)
		self:confirmFunc(self._data[index + 1].id, num, index)
	end,
	closeFunc = function()
	end
	})
	]]
	GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	local popup = require("game.Arena.ExchangeCountBox").new({
	reputation = self.rongyu,
	itemData = itemData,
	shopType = BIWU_SHOP_TYPE,
	listener = function(num)
		self:confirmFunc(self._data[index + 1].id, num, index)
	end,
	closeFunc = function()
		
	end
	})
	
	popup:setPositionY(0)
	display.getRunningScene():addChild(popup, 1000000)
end

function BiwuDuihuanLayer:confirmFunc(id, num, index)
	local bagObj = {}
	local function extendBag(data)
		if bagObj[1].curCnt < data["1"] then
			table.remove(bagObj, 1)
		else
			bagObj[1].cost = data["4"]
			bagObj[1].size = data["5"]
		end
		if #bagObj > 0 then
			self:addChild(require("utility.LackBagSpaceLayer").new({
			bagObj = bagObj,
			callback = function(data)
				extendBag(data)
			end
			}), OPENLAYER_ZORDER)
		end
	end
	local function callBackFunc(data)
		bagObj = data.packetOut
		if #bagObj > 0 then
			self:addChild(require("utility.LackBagSpaceLayer").new({
			bagObj = bagObj,
			callback = function(data)
				extendBag(data)
			end
			}), 200)
		else
			self._data[index + 1].num1 = self._data[index + 1].num1 - num
			self._data[index + 1].had = self._data[index + 1].had + num
			if 0 < self._data[index + 1].num1 then
				local param = {
				viewSize = cc.size(self._viewSize.width, self._viewSize.height / 3),
				cellData = self._data[index + 1],
				listener = handler(self, BiwuDuihuanLayer.commitResqust),
				index = index
				}
				self._tableView:reloadCell(index, param)
			elseif self._data[index + 1].type1 == 1 then
				table.remove(self._data, index + 1)
				self._tableView:resetListByNumChange(#self._data)
			else
				local param = {
				viewSize = cc.size(self._viewSize.width, self._viewSize.height / 3),
				cellData = self._data[index + 1],
				listener = handler(self, BiwuDuihuanLayer.commitResqust),
				index = index
				}
				self._tableView:reloadCell(index, param)
			end
			local cellDatas = {}
			local itemData = {
			id = self._data[index + 1].item,
			iconType = self._data[index + 1].iconType,
			num = self._data[index + 1].num,
			name = self._data[index + 1].name,
			describe = self._data[index + 1].dis
			}
			table.insert(cellDatas, itemData)
			display:getRunningScene():addChild(require("game.Huodong.rewardInfo.RewardInfoMsgBox").new({cellDatas = cellDatas, num = num}), 80000)
			self.rongyu = data.honor
			self.nameDis:setString(data.honor)
		end
	end
	RequestHelper.biwuSystem.exChangeItem({
	id = id,
	num = num,
	callback = function(data)
		dump(data)
		callBackFunc(data)
	end
	})
end

function BiwuDuihuanLayer:onRefresh()
	self._tableView:reloadData()
end

function BiwuDuihuanLayer:_getData(func)
	local function initData(data)
		self._data = {}
		dump(data.list)
		local data_biwu_shop_biwu_shop = require("data.data_biwu_shop_biwu_shop")
		local data_item_item = require("data.data_item_item")
		local data_card_card = require("data.data_card_card")
		local data_pet_pet = require("data.data_pet_pet")
		for k, v in pairs(data_biwu_shop_biwu_shop) do
			for k1, v1 in pairs(data.list) do
				if v1.itemId == v.id then
					v.num1 = v1.number
					v.had = v1.had
					v.iconType = ResMgr.getResType(v.type)
					local item = ResMgr.getItemByType(v.item, v.iconType)
					v.dis = item.describe
					v.name = item.name
					table.insert(self._data, v)
				end
			end
		end
		local hasData = {}
		local noData = {}
		for k, v in pairs(self._data) do
			if v.num1 == 0 then
				table.insert(noData, v)
			else
				table.insert(hasData, v)
			end
		end
		table.sort(hasData, function(a, b)
			return a.id < b.id
		end)
		table.sort(noData, function(a, b)
			return a.id < b.id
		end)
		self._data = {}
		for k, v in pairs(hasData) do
			table.insert(self._data, v)
		end
		for k, v in pairs(noData) do
			table.insert(self._data, v)
		end
		self.rongyu = data.honor
		func()
	end
	RequestHelper.biwuSystem.getExchangeList({
	callback = function(data)
		dump(data)
		initData(data)
	end
	})
end

return BiwuDuihuanLayer