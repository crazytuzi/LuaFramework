local DengjiTouziBuyMsgbox = class("DengjiTouziBuyMsgbox", function ()
	return require("utility.ShadeLayer").new()
end)
function DengjiTouziBuyMsgbox:ctor(param)
	local needGold = param.needGold
	local cancelListen = param.cancelListen
	local confirmListen = param.confirmListen
	local rootnode = {}
	local proxy = CCBProxy:create()
	local node = CCBuilderReaderLoad("nbhuodong/dengjiTouzi_buyMsgbox.ccbi", proxy, rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	local tips1 = common:getLanguageString("@BloodFundCostTips", needGold)
	local node1 = getRichText(tips1, 500)
	rootnode.label_node_1:addChild(node1)
	local size = node1:getContentSize()
	node1:setPositionX(0 - size.width * 0.5)
	local tips2 = common:getLanguageString("@BloodFundCostTips1", needGold)
	local node2 = getRichText(tips2)
	rootnode.label_node_2:addChild(node2, 500)
	local size = node2:getContentSize()
	node2:setPositionX(0 - size.width * 0.5)
	local function closeFunc()
		if cancelListen ~= nil then
			cancelListen()
		end
		self:removeFromParentAndCleanup(true)
	end
	rootnode.closeBtn:addHandleOfControlEvent(function (eventName, sender)
		closeFunc()
	end,
	CCControlEventTouchUpInside)
	rootnode.cancelBtn:addHandleOfControlEvent(function (eventName, sender)
		closeFunc()
	end,
	CCControlEventTouchUpInside)
	rootnode.confirmBtn:addHandleOfControlEvent(function (eventName, sender)
		if confirmListen ~= nil then
			confirmListen()
		end
		self:removeFromParentAndCleanup(true)
	end,
	CCControlEventTouchUpInside)
end


return DengjiTouziBuyMsgbox