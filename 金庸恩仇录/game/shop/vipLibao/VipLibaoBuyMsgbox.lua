require("data.data_error_error")
local data_yueka_yueka = require("data.data_yueka_yueka")
local data_viplevel_viplevel = require("data.data_viplevel_viplevel")
local data_item_item = require("data.data_item_item")
local data_card_card = require("data.data_card_card")

local VipLibaoBuyMsgbox = class("VipLibaoBuyMsgbox", function()
	return require("utility.ShadeLayer").new()
end)

function VipLibaoBuyMsgbox:ctor(param)
	local confirmFunc = param.confirmFunc
	local cancelFunc = param.cancelFunc
	local vipLv = param.vipLv
	local price = param.price
	local describe = param.describe
	local title = param.title
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("shop/shop_vipLibao_buy_msgBox.ccbi", proxy, rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	rootnode.vip_lbl_bottom:setString(tostring(vipLv))
	rootnode.vip_lbl_top:setString(tostring(vipLv))
	rootnode.itemDesLbl:setString(tostring(describe))
	rootnode.price_lbl:setString(tostring(price))
	rootnode.top_title_lbl:setString(tostring(title))
	arrangeTTFByPosX({
	rootnode.bottom_lbl_2,
	rootnode.vip_lbl_bottom,
	rootnode.bottom_lbl_3,
	rootnode.bottom_lbl_4
	})
	self._curInfoIndex = -1
	local viplevelData
	for i, v in ipairs(data_viplevel_viplevel) do
		if v.vip == vipLv and v.open == 1 then
			viplevelData = v
			break
		end
	end
	local cellDatas = {}
	if vipLv < 0 then
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
		for i, v in ipairs(viplevelData.arr_type1) do
			local itemId = viplevelData.arr_item1[i]
			local num = viplevelData.arr_num1[i]
			ResMgr.showAlert(itemId, "data_viplevel_viplevel数据表，VIP配置的升级奖励id没有，vip: " .. tostring(vipLv + 1) .. ", type:" .. v .. ", id:" .. itemId)
			ResMgr.showAlert(num, "data_viplevel_viplevel数据表，VIP配置的升级奖励num没有，vip: " .. tostring(vipLv + 1) .. ", type:" .. v .. ", id:" .. itemId)
			local iconType = ResMgr.getResType(v)
			local itemInfo
			if iconType == ResMgr.HERO then
				itemInfo = data_card_card[itemId]
			else
				itemInfo = data_item_item[itemId]
			end
			ResMgr.showAlert(itemInfo, "data_viplevel_viplevel数据表，arr_type1和arr_item1对应不上，vip：" .. tostring(vipLv + 1) .. ", type:" .. v .. ", id:" .. itemId)
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
	local size = rootnode.vipInfoNode:getContentSize()
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
	rootnode.vipInfoNode:addChild(self.ListTable)
	
	rootnode.confirmBtn:addHandleOfControlEvent(function()
		if confirmFunc ~= nil then
			local result = confirmFunc(self)
			if result == true then
				self:removeSelf()
			end
		end
	end,
	CCControlEventTouchUpInside)
	
	local function closeFunc()
		if cancelFunc ~= nil then
			cancelFunc()
		end
		self:removeSelf()
	end
	rootnode.cancelBtn:addHandleOfControlEvent(function()
		closeFunc()
	end,
	CCControlEventTouchUpInside)
	
	rootnode.closeBtn:addHandleOfControlEvent(function()
		closeFunc()
	end,
	CCControlEventTouchUpInside)
end

return VipLibaoBuyMsgbox