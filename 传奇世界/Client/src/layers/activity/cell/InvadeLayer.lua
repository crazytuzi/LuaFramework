--山贼入侵
local InvadeLayer = class("InvadeLayer", function() return cc.Node:create() end)

function InvadeLayer:ctor()
	local baseLayer = cc.Node:create()
	baseLayer:setVisible( false )
	self:addChild( baseLayer )

	local bg = createScale9Sprite( baseLayer , "res/fb/multiple/bg.png", cc.p(display.width - 10, display.cy + 150 ), cc.size(246, 180 ),cc.p(1, 0.5), nil, nil, 101)	
	local size = bg:getContentSize()
	
	local strs = { 
					{ str = game.getStrByKey("activity") .. game.getStrByKey("countDownTime") .. "："  } , 
					{ str = game.getStrByKey("kill_1") .. "："  } , 
					{ str = game.getStrByKey("kill_2") .. "："  } , 
					{ str = game.getStrByKey("cur_score") , y = 50 } , 
				}

	local texts = { }
	for i = 1 , #strs do
		local offY = size.height - ( i - 1 ) * 40 - 15
		-- if strs[i].y then offY = strs[i].y end
		createLabel( bg , strs[i].str  , cc.p( 10 , offY ) , cc.p( 0 , 1 ) , 20 , nil , nil , nil , strs[i].y and MColor.yellow or MColor.lable_yellow )
		texts[i] = createLabel( bg , "" , cc.p( strs[i].y and 110 or 130 , offY ) , cc.p( 0 , 1 ) , 20 , nil , nil , nil , strs[i].y and MColor.yellow or MColor.white )
	end

	local timeCall = nil
	local timeFun = function() if timeCall then timeCall() end end
	startTimerActionEx( self, 1.0 , true , timeFun )

	local function onShareToFactionGroup(factionID)
        local title = "行会成员注意了！"
        local desc = "山贼入侵活动开始了，请所有成员保卫我们的驻地！"
        local urlIcon = "http://game.gtimg.cn/images/cqsj/m/m201604/web_logo.png"
        sdkSendToWXGroup(1, 1, factionID, title, desc, "MessageExt", "MSG_INVITE", urlIcon, "")
    end

    local function shareToFactionGroup(factionID)
        if isWXInstalled() then
        	local isInWXGroup = getGameSetById(GAME_SET_ISINWXGROUP)
            if isInWXGroup == 1 then
                onShareToFactionGroup(factionID)
            end
    	end
    end

	local function createLayout( buff )
		local t = g_msgHandlerInst:convertBufferToTable( "InvadePushData", buff ) 
		-- local t = { surplusTime = 10 , integral = 10000 , nextIntegral = 20000 , monsterNum1 = 10 , monsterNum2 = 20 }
		local tempData = {}
		local time = t.surplusTime 			--倒计时(秒)
		tempData.nowPoint = t.integral 		--当前积分
		tempData.totalPoint = t.nextIntegral 	--下一级奖励所需积分
		tempData.kill1 = t.monsterNum1 		--击杀纵火贼数量
		tempData.kill2 = t.monsterNum2  		--击杀响马贼数量

		timeCall = function()
			if time <= 0 then
				baseLayer:setVisible( false )
				return
			end

			baseLayer:setVisible( true )
			time = time - 1
			texts[1]:setString( self:refreshTime( time ) ) 
		end

        if texts[2] then texts[2]:setString( tempData.kill1 ) end
        if texts[3] then texts[3]:setString( tempData.kill2 ) end
        if texts[4] then texts[4]:setString( tempData.nowPoint .. "/" .. tempData.totalPoint ) end

        local factionID = require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID)
		shareToFactionGroup(factionID)
	end
	
	g_msgHandlerInst:registerMsgHandler( INVADE_SC_PUSH_DATA , createLayout )

end

function InvadeLayer:refreshTime( curTime )
	if curTime < 0 then curTime = 0 end
	local dayNum = math.floor( tonumber(timeConvert( curTime , "hour"))/24 )
	curTime = curTime - dayNum * 86400

	local hour = math.mod( timeConvert( curTime , "hour") , 24 )
	local min =  timeConvert( curTime , "min")
	local sec = tonumber( timeConvert( curTime , "sec") )

	local str = dayNum>0 and ( dayNum .. game.getStrByKey( "day" ) ) or ""
	str = str .. ( hour > 0 and ( hour .. game.getStrByKey( "hour" ) )  or "" ) 
	str = str .. ( tonumber(min) > 0 and ( string.len(min) == 1 and ( "0" .. min) or min ) or "00" ) .. game.getStrByKey( "min" )
	str = str .. ( tonumber(sec) > 0 and ( string.len(sec) == 1 and ( "0" .. sec) or sec )  or "00" ) .. game.getStrByKey( "sec" )
	return str
end

return InvadeLayer