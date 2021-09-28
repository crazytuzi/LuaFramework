--[[
 --
 -- add by vicky
 -- 2014.11.04
 --
 --]]


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
 	node:setPosition(display.width/2, display.height/2)
 	self:addChild(node)

 	if isBuyMonthCard then 
 		rootnode["monthCard_node"]:setVisible(true) 
	 	rootnode["normal_buy_node"]:setVisible(false)
 	else 
 		rootnode["monthCard_node"]:setVisible(false) 
	 	rootnode["normal_buy_node"]:setVisible(true)

	 	rootnode["buyGold_lbl"]:setString(tostring(buyGold) .. "元宝")

	 	arrangeTTFByPosX({
	 		rootnode["buyGold_lbl"], 
	 		rootnode["first_msg_lbl"] 
	 		}) 

	 	if getGold <= 0 then 
	 		rootnode["shouchong_node"]:setVisible(false) 
	 		rootnode["normal_node"]:setVisible(false)
	 	elseif isFirstBuy then 
	 		rootnode["shouchong_node"]:setVisible(true) 
	 		rootnode["normal_node"]:setVisible(false)
	 		rootnode["getGold_lbl_first"]:setString(tostring(getGold) .. "元宝")

	 		arrangeTTFByPosX({
		 		rootnode["getGold_lbl_first"], 
		 		rootnode["shouchong_msg_lbl_2"] 
	 		}) 

	 	else
			rootnode["shouchong_node"]:setVisible(false) 
			rootnode["normal_node"]:setVisible(true)
			rootnode["getGold_lbl_normal"]:setString(tostring(getGold) .."元宝") 

			arrangeTTFByPosX({
		 		rootnode["getGold_lbl_normal"], 
		 		rootnode["normal_msg_lbl_2"] 
	 		}) 
	 	end 
	end 

 	local function closeFunc()
 		self:removeFromParentAndCleanup(true) 
 	end 

 	rootnode["closeBtn"]:addHandleOfControlEvent(function(eventName,sender)
        closeFunc() 
    end, CCControlEventTouchUpInside)

    rootnode["confirmBtn"]:addHandleOfControlEvent(function(eventName,sender)
        closeFunc() 
    end, CCControlEventTouchUpInside)

    rootnode["cancelBtn"]:addHandleOfControlEvent(function(eventName,sender)
        closeFunc() 
    end, CCControlEventTouchUpInside) 

 end 


 return ChongzhiBuyEndMsgbox 

