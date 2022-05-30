local ChongzhiBuyEndMsgbox = class("ChongzhiBuyEndMsgbox", function()
	return require("utility.ShadeLayer").new()
end)

function ChongzhiBuyEndMsgbox:ctor(param)
	local getGold = param.getGold or 0
	local buyGold = param.buyGold
	local isFirstBuy = param.isFirstBuy
	local isBuyMonthCard = param.isBuyMonthCard
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("ccbi/shop/shop_chongzhi_buyEndMsgBox.ccbi", proxy, rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	if isBuyMonthCard then
		if game.player:getAppOpenData().appstore == APPOPEN_STATE.close then
			rootnode.monthCard_node:setVisible(false)
			rootnode.normal_buy_node:setVisible(true)
			rootnode.buyGold_lbl:setString(common:getLanguageString("@Gold", tostring(buyGold)))
		else
			rootnode.monthCard_node:setVisible(true)
			rootnode.getMonthCard_lbl_normal:setString(common:getLanguageString("@Gold", tostring(buyGold)))
			rootnode.normal_buy_node:setVisible(false)
		end
	else
		rootnode.monthCard_node:setVisible(false)
		rootnode.normal_buy_node:setVisible(true)
		rootnode.buyGold_lbl:setString(common:getLanguageString("@Gold", tostring(buyGold)))
		alignNodesOneByAllCenterX(rootnode.buyGold_lbl:getParent(), {
		rootnode.shop_label_1,
		rootnode.buyGold_lbl,
		rootnode.first_msg_lbl
		}, 1)
		if getGold <= 0 then
			rootnode.shouchong_node:setVisible(false)
			rootnode.normal_node:setVisible(false)
		elseif isFirstBuy then
			rootnode.shouchong_node:setVisible(true)
			rootnode.normal_node:setVisible(false)
			rootnode.getGold_lbl_first:setString(common:getLanguageString("@Gold", tostring(getGold)))
			alignNodesOneByAllCenterX(rootnode.shouchong_node, {
			rootnode.shouchong_msg_lbl_1,
			rootnode.getGold_lbl_first,
			rootnode.shouchong_msg_lbl_2
			}, 1)
		else
			rootnode.shouchong_node:setVisible(false)
			rootnode.normal_node:setVisible(true)
			rootnode.getGold_lbl_normal:setString(common:getLanguageString("@Gold", tostring(getGold)))
			alignNodesOneByAllCenterX(rootnode.normal_node, {
			rootnode.shop_normal_msg_lbl_1,
			rootnode.getGold_lbl_normal,
			rootnode.shop_normal_msg_lbl_2
			}, 1)
		end
	end
	local function closeFunc()
		self:removeSelf()
	end
	
	rootnode.closeBtn:addHandleOfControlEvent(function(eventName, sender)
		closeFunc()
	end,
	
	CCControlEventTouchUpInside)
	rootnode.confirmBtn:addHandleOfControlEvent(function(eventName, sender)
		closeFunc()
	end,
	
	CCControlEventTouchUpInside)
	rootnode.cancelBtn:addHandleOfControlEvent(function(eventName, sender)
		closeFunc()
	end,
	CCControlEventTouchUpInside)
end

return ChongzhiBuyEndMsgbox