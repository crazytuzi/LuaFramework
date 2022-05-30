local data_yueka_yueka = require("data.data_yueka_yueka")
require("data.data_error_error")
local data_item_item = require("data.data_item_item")
local data_card_card = require("data.data_card_card")

local MAX_ZORDER = 1111

local ShouchongLibaoLayer = class("ShouchongLibaoLayer", function()
	return display.newNode()
end)


function ShouchongLibaoLayer:ctor(param)
	self._curInfoIndex = -1
	
	local viewSize = param.viewSize
	local proxy = CCBProxy:create()
	self._rootnode = {}
	
	local node = CCBuilderReaderLoad("nbhuodong/shouchong_libao_layer.ccbi", proxy, self._rootnode, self, viewSize)
	self:addChild(node)
	
	--[[
	if CSDKShell.GetSDKTYPE() == CSDKShell.SDKTYPES.IOS_APPSTORE_HANS then
		self._rootnode["tag_zuigaofanli"]:setVisible(false)
	else
		self._rootnode["tag_zuigaofanli"]:setVisible(true)
	end
	]]
	
	self._rootnode["tag_zuigaofanli"]:setVisible(true)
	
	local titleIcon = self._rootnode["title_icon"]
	local bottomNode = self._rootnode["bottom_node"]
	
	local contentHeight = 400
	
	-- 底部信息
	local disH = viewSize.height - contentHeight - bottomNode:getContentSize().height
	if disH > 10 then
		bottomNode:setPosition(bottomNode:getPositionX(), disH/2)
	end
	
	-- 标题自适应
	local scaleY = (viewSize.height - bottomNode:getContentSize().height)/contentHeight
	if scaleY > 1 then
		scaleY = 1
	end
	self._rootnode["title_icon"]:setScale(scaleY)
	
	self:initData()
end


function ShouchongLibaoLayer:initData()
	self._rootnode["buyBtn"]:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		local chongzhiLayer = require("game.shop.Chongzhi.ChongzhiLayer").new()
		game.runningScene:addChild(chongzhiLayer, MAX_ZORDER)
	end,
	CCControlEventTouchUpInside)
	
	self._rewardDatas = {}
	
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
		
		table.insert(self._rewardDatas,  {
		id = itemId,
		name = itemInfo.name,
		num = num,
		type = type,
		iconType = iconType,
		describe = itemInfo.describe or ""
		})
	end
	
	self:initRewardListView(self._rewardDatas)
end


function ShouchongLibaoLayer:initRewardListView(rewardDatas)
	
	local boardWidth = self._rootnode["listView"]:getContentSize().width
	local boardHeight = self._rootnode["listView"]:getContentSize().height
	
	-- 创建
	local function createFunc(index)
		local item = require("game.nbactivity.MonthCard.MonthCardRewardItem").new()
		return item:create({
		id = index,
		viewSize = CCSizeMake(boardWidth, boardHeight),
		itemData = rewardDatas[index + 1]
		})
	end
	
	-- 刷新
	local function refreshFunc(cell, index)
		cell:refresh({
		index = index,
		itemData = rewardDatas[index + 1]
		})
	end
	
	local cellContentSize = require("game.nbactivity.MonthCard.MonthCardRewardItem").new():getContentSize()
	
	self.ListTable = require("utility.TableViewExt").new({
	size        = CCSizeMake(boardWidth, boardHeight),
	createFunc  = createFunc,
	refreshFunc = refreshFunc,
	cellNum   	= #rewardDatas,
	cellSize    = cellContentSize,
	touchFunc = function(cell)
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
		endFunc = function()
			self._curInfoIndex = -1
		end
		})
		game.runningScene:addChild(itemInfo, 100)
	end
	})
	
	self.ListTable:setPosition(0, 0)
	self._rootnode["listView"]:addChild(self.ListTable)
	
end

return ShouchongLibaoLayer