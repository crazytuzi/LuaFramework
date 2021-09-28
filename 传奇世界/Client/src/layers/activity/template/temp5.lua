--[[ 月卡 ]]--
local M = class( "temp17" ,function() return cc.Layer:create() end )

function M:ctor( params )
    local data = {}
    createSprite( self , "res/layers/activity/bg/bg5_" .. ( DATA_Activity.CData["activityID"] == 5 and 1 or 2 )  .. ".png" , cc.p( 8 ,307 ) , cc.p( 0 , 0 ) )


    local awardBg = createSprite( self , "res/layers/activity/cell/activation_Code/bg.png",cc.p( 365 , 115 ) , cc.p( 0.5 , 0 ) )
    createLabel( awardBg , game.getStrByKey("month_card") .. game.getStrByKey("invade_day") .. game.getStrByKey("rewards") , cc.p( 35 , 150 ) , cc.p( 0 , 1.0 ) , 22 , nil , nil , nil , MColor.lable_yellow )

    local viewLayer = cc.Node:create()
    self:addChild( viewLayer )


    


    local function createLayout()
        if viewLayer then viewLayer:removeAllChildren() end
        local getFun = function()
	        if data.state == 2 and data.dayNum <=  5 then
	            --续费
	            g_msgHandlerInst:sendNetDataByTableExEx(ACTIVITY_REQ, "ActivityReq", { modelID = DATA_Activity.CData["modelID"] , activityID = DATA_Activity.CData["activityID"] , flag = 2 })
	        else
	            DATA_Activity:getAward( { awards = data.awards } )
	        end
	    end

        local btnCfg = { game.getStrByKey("lottery_getOne") , game.getStrByKey("renew") , game.getStrByKey("getOver") }
        local getBtn = createMenuItem( viewLayer , "res/component/button/49.png" ,  cc.p( 560 , 65 + 110  ) , getFun )
    	local getText = createLabel( getBtn , "" ,   getCenterPos( getBtn )  , cc.p( 0.5 , 0.5 ) , 24 , true )
    	createLabel( viewLayer , ( DATA_Activity.CData["activityID"] == 5 and 300 or 600 ) .. game.getStrByKey( "ingot" ) ,  cc.p( 560 , 100 + 110 ) , cc.p( 0.5 , 0.5 ) , 24 , true )


        data = DATA_Activity.CData["netData"]

        local iconGroup = __createAwardGroup( data.awards )
        setNodeAttr( iconGroup , cc.p( 60 , 180 ) , cc.p( 0 , 0.5 ) )
        viewLayer:addChild( iconGroup )


        local str = string.format( game.getStrByKey("month_card_tip") , data.dayNum )

        if data.dayNum == 0 and data.state == 2 then
            getText:setString( game.getStrByKey( "buy" ) )
            str = game.getStrByKey("month_card_tip2")
        elseif data.dayNum <=  5 then
            if data.state ~= 0 then
                getText:setString( btnCfg[2] )
            else
                getText:setString( btnCfg[1] )
            end
            str = str .. "，" .. game.getStrByKey("month_card_tip1")
        else
            if data.state ~= 0 then
                getText:setString( btnCfg[3] )
                getBtn:setEnabled( false )
            else
                getText:setString( btnCfg[1] )
            end
        end

        local tipTxt = require("src/RichText").new( viewLayer , cc.p( 365 + ( data.dayNum <=  5 and 0 or 60 ) , 50) , cc.size( 500 , 0 ) , cc.p( 0.5 , 0 ) , 25 , 20 , MColor.lable_yellow )
        tipTxt:addText(  str , MColor.lable_yellow , true )
        tipTxt:format()
    end

    DATA_Activity:readData(createLayout)
end





return M