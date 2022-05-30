require("utility.richtext.richText")

CurrentPayWay = "Inland_android"

local ChongzhiBuyMonthCardMsgbox = class("ChongzhiBuyMonthCardMsgbox", function()
	return require("utility.ShadeLayer").new()
end)

function ChongzhiBuyMonthCardMsgbox:ctor(param)
	local leftDay = param.leftDay
	local confirmListen = param.confirmListen
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("ccbi/shop/buyMonthCard_msgBox.ccbi", proxy, rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	rootnode.leftDay_lbl:setString(common:getLanguageString("@DayLeft") .. tostring(leftDay))
	local data_chongzhi = require("game.Chongzhi")
	local monthCardPrice = data_chongzhi[CurrentPayWay][MonthCardTYPE].coinnum
	local goldGet = data_chongzhi[CurrentPayWay][MonthCardTYPE].basegold
	local chixugold = data_chongzhi[CurrentPayWay][MonthCardTYPE].chixugold
	local strTitle = common:getLanguageString("@BuyMonthcardConfirm", tostring(monthCardPrice))
	rootnode.month_card_tips_1:setVisible(false)
	local mTextRangeTitleNode = rootnode.mTextRangeTitle
	local width = mTextRangeTitleNode:getContentSize().width
	local contentLabel1 = getRichText(strTitle, width, nil, 5)
	local posX = (width - contentLabel1:getContentSize().width) / 2
	contentLabel1:setPosition(posX, contentLabel1:getContentSize().height - contentLabel1.offset)
	mTextRangeTitleNode:addChild(contentLabel1)
	local mTextRangeNode = rootnode.mTextRange
	local txtWidth = mTextRangeNode:getContentSize().width
	local month_card_tips_2 = rootnode.month_card_tips_2
	month_card_tips_2:setVisible(false)
	local contentLabel = getRichText(common:getLanguageString("@BuyVipNotice", tostring(goldGet), tostring(chixugold)), txtWidth, nil, 5)
	contentLabel:setPosition(5, contentLabel:getContentSize().height - contentLabel.offset - 10)
	mTextRangeNode:addChild(contentLabel)
	local function closeFunc()
		self:removeSelf()
	end
	
	rootnode.closeBtn:addHandleOfControlEvent(function(sender, eventName)
		closeFunc()
	end,
	CCControlEventTouchUpInside)
	
	rootnode.confirmBtn:addHandleOfControlEvent(function(sender, eventName)
		if confirmListen ~= nil then
			confirmListen()
		end
		closeFunc()
	end,
	CCControlEventTouchUpInside)
	
	rootnode.cancelBtn:addHandleOfControlEvent(function(sender, eventName)
		closeFunc()
	end,
	CCControlEventTouchUpInside)
	
end

return ChongzhiBuyMonthCardMsgbox