--[[
 --
 -- add by vicky
 -- 2014.11.05
 --
 --]]


 local ChongzhiBuyMonthCardMsgbox = class("ChongzhiBuyMonthCardMsgbox", function()
 		return require("utility.ShadeLayer").new() 
 	end)


 function ChongzhiBuyMonthCardMsgbox:ctor(param)
 	local leftDay = param.leftDay 
 	local confirmListen = param.confirmListen  

 	local proxy = CCBProxy:create()
 	local rootnode = {}
 	local node = CCBuilderReaderLoad("ccbi/shop/buyMonthCard_msgBox.ccbi", proxy, rootnode) 
 	node:setPosition(display.width/2, display.height/2)
 	self:addChild(node)  

 	rootnode["leftDay_lbl"]:setString("剩余天数：" .. tostring(leftDay)) 

 	local function closeFunc()
 		self:removeFromParentAndCleanup(true) 
 	end 

 	rootnode["closeBtn"]:addHandleOfControlEvent(function(eventName,sender)
        closeFunc() 
    end, CCControlEventTouchUpInside)

    rootnode["confirmBtn"]:addHandleOfControlEvent(function(eventName,sender)
    	if confirmListen ~= nil then 
    		confirmListen() 
    	end 
        closeFunc() 
    end, CCControlEventTouchUpInside)

    rootnode["cancelBtn"]:addHandleOfControlEvent(function(eventName,sender)
        closeFunc() 
    end, CCControlEventTouchUpInside) 

 end 


 return ChongzhiBuyMonthCardMsgbox 

