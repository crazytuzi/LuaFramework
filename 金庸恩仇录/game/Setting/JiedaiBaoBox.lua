local data_item_item = require("data.data_item_item")
local data_card_card = require("data.data_card_card")
local data_message_message = require("data.data_message_message")

local JiedaiBaoBox = class("JiedaiBaoBox", function()
	return require("utility.ShadeLayer").new()
end)

function JiedaiBaoBox:ctor(param)
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("mainmenu/setting_jiedaibao.ccbi", proxy, rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	
	rootnode.closeBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		self:onClose()
	end,
	CCControlEventTouchUpInside)
	
	rootnode.gotoBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if #game.player.jiedaibaoUrl > 0 then
			device.openURL(game.player.jiedaibaoUrl)
		end
	end,
	CCControlEventTouchUpInside)
	
	rootnode.descLabel:setString(data_message_message[33].text)
	local size = rootnode.descLabel:getContentSize()
	rootnode.descView:setContentSize(size)
	rootnode.contentView:setPosition(cc.p(size.width / 2, size.height))
	local scrollView = rootnode.scrollView
	scrollView:setContentOffset(cc.p(0, -size.height + scrollView:getViewSize().height), false)
	self._curInfoIndex = -1
	local data_daojuku_daojuku = require("data.data_daojuku_daojuku")
	viplevelData = data_daojuku_daojuku[11]
	local cellDatas = {}
	for i, v in ipairs(viplevelData.arr_type) do
		local itemId = viplevelData.arr_item[i]
		local num = viplevelData.arr_num[i]
		local iconType = ResMgr.getResType(v)
		local itemInfo
		if iconType == ResMgr.HERO then
			itemInfo = data_card_card[itemId]
		else
			itemInfo = data_item_item[itemId]
		end
		table.insert(cellDatas, {
		id = itemId,
		type = v,
		num = num,
		iconType = iconType,
		name = itemInfo.name,
		describe = itemInfo.describe or ""
		})
	end
	local size = rootnode.rewardInfoNode:getContentSize()
	local boardWidth = size.width
	local boardHeight = size.height
	local function createFunc(index)
		local item = require("game.shop.Chongzhi.ChongzhiRewardItem").new()
		return item:create({
		id = index,
		itemData = cellDatas[index + 1]
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
		self.ListTable:removeFromParentAndCleanup(true)
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
	rootnode.rewardInfoNode:addChild(self.ListTable)
end

function JiedaiBaoBox:onClose()
	self:removeFromParentAndCleanup(true)
end

return JiedaiBaoBox