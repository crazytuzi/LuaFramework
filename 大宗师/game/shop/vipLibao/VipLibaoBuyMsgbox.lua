--[[
 --
 -- add by vicky
 -- 2014.12.05 
 --
 --]]

 require("data.data_error_error") 

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

	rootnode["vip_lbl_bottom"]:setString(tostring(vipLv)) 
	rootnode["vip_lbl_top"]:setString(tostring(vipLv)) 
	rootnode["itemDesLbl"]:setString(tostring(describe)) 
	rootnode["price_lbl"]:setString(tostring(price)) 
	rootnode["top_title_lbl"]:setString(tostring(title)) 

	rootnode["bottom_lbl_3"]:setString(tostring(title) .. "需要花费") 

	arrangeTTFByPosX({
		rootnode["bottom_lbl_2"], 
		rootnode["vip_lbl_bottom"], 
		rootnode["bottom_lbl_3"], 
		rootnode["bottom_lbl_4"] 
	}) 

	-- 确定 
	rootnode["confirmBtn"]:addHandleOfControlEvent(function() 
        if confirmFunc ~= nil then 
            local result = confirmFunc(self) 
			if result == true then 
				self:removeFromParentAndCleanup(true) 
			end 
        end 
	end, CCControlEventTouchUpInside) 

	-- 取消 
	local function closeFunc()
		if cancelFunc ~= nil then 
			cancelFunc()  
		end 
		self:removeFromParentAndCleanup(true) 
	end 

	rootnode["cancelBtn"]:addHandleOfControlEvent(function() 
        closeFunc() 
	end, CCControlEventTouchUpInside) 

	rootnode["closeBtn"]:addHandleOfControlEvent(function() 
        closeFunc() 
	end, CCControlEventTouchUpInside) 

 end 


 return VipLibaoBuyMsgbox 

