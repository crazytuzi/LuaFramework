--[[
 --
 -- add by vicky
 -- 2014.10.14
 --
 --]]

 require("data.data_error_error") 

 local ShenmiRefreshGoldMsgBox = class("ShenmiRefreshGoldMsgBox", function()
 		return require("utility.ShadeLayer").new() 
 	end)

 
 function ShenmiRefreshGoldMsgBox:ctor(param) 
    local costNum = param.costNum 
    local refreshNum = param.refreshNum 
 	local confirmFunc = param.confirmFunc 

 	local proxy = CCBProxy:create()
 	local rootnode = {}

    local node = CCBuilderReaderLoad("nbhuodong/shenmi_refresh_gold_msgBox.ccbi", proxy, rootnode)
    node:setPosition(display.width/2, display.height/2)
    self:addChild(node) 

    local function onClose()
    	self:removeFromParentAndCleanup(true) 
    end 

   	rootnode["confirmBtn"]:addHandleOfControlEvent(function(eventName, sender)
            if game.player:getGold() < costNum then 
                show_tip_label(data_error_error[100004].prompt)
            elseif confirmFunc ~= nil then 
            	confirmFunc()
            	onClose() 
            end 
        end, CCControlEventTouchUpInside) 

   	rootnode["cancelBtn"]:addHandleOfControlEvent(function(eventName, sender)
            onClose() 
        end, CCControlEventTouchUpInside) 

   	rootnode["closeBtn"]:addHandleOfControlEvent(function(eventName, sender)
            onClose() 
        end, CCControlEventTouchUpInside)  

    -- 消耗元宝数量 
    rootnode["cost_num"]:setString(tostring(costNum))   
    rootnode["gold_icon"]:setPositionX(rootnode["cost_num"]:getPositionX() + rootnode["cost_num"]:getContentSize().width + 5) 

    -- 元宝刷新次数 
    rootnode["refresh_num"]:setString(tostring(refreshNum)) 
    rootnode["bottom_msg"]:setPositionX(rootnode["refresh_num"]:getPositionX() + rootnode["refresh_num"]:getContentSize().width + 5) 

 end


 return ShenmiRefreshGoldMsgBox 
