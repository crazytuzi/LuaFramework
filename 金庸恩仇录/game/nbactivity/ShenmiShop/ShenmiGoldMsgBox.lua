require("data.data_error_error")
local ShenmiGoldMsgBox = class("ShenmiGoldMsgBox", function()
	return require("utility.ShadeLayer").new()
end)
function ShenmiGoldMsgBox:ctor(param)
	local itemData = param.itemData
	local confirmFunc = param.confirmFunc
	local cancelFunc = param.cancelFunc
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("nbhuodong/shenmi_gold_msgBox.ccbi", proxy, rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	local function onClose()
		if cancelFunc ~= nil then
			cancelFunc()
		end
		self:removeSelf()
	end
	
	rootnode.confirmBtn:addHandleOfControlEvent(function(eventName, sender)
		if game.player:getGold() < itemData.price then
			show_tip_label(data_error_error[100004].prompt)
		elseif confirmFunc ~= nil then
			confirmFunc()
			onClose()
		end
	end,
	CCControlEventTouchUpInside)
	
	rootnode.cancelBtn:addHandleOfControlEvent(function(eventName, sender)
		onClose()
	end,
	CCControlEventTouchUpInside)
	
	rootnode.closeBtn:addHandleOfControlEvent(function(eventName, sender)
		onClose()
	end,
	CCControlEventTouchUpInside)
	
	local bgSize = rootnode.tag_bg:getContentSize()
	local text = common:getLanguageString("@BuyItemCostTips", tostring(itemData.price), itemData.name)
	local richText = getRichText(text, bgSize.width * 0.7)
	local richTextSize = richText:getContentSize()
	rootnode.tip_base_node:addChild(richText)
	richText:setPosition(cc.p(0 - richTextSize.width * 0.5, 0))
end
return ShenmiGoldMsgBox