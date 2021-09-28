--全服撒花展示
local SHOW_FLOWER = function( buff )
	local t = g_msgHandlerInst:convertBufferToTable( "GiveFlowerNoticeProtocol" , buff ) 
	if getGameSetById( GAME_SET_ID_SHOW_FLOWERS ) == 1 or (not G_MAINSCENE) or (G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.isStory) then 
		return  --新手剧情不展示
	end  

	local sendID = t.sourceID   			--送花者ID
	local sendName = t.sourceName  	--送花者名字	  
	local receiveID = t.targetSID   		--收花者ID
	local receiveName = t.targetName   	--收花者名字
	local sendMsg = t.message		--送花者留言

	local msg_item = getConfigItemByKeys("clientmsg",{"sth","mid"},{ 31000 , 45 })
	local tipsTxt = string.format( msg_item.msg , sendName , receiveName , sendMsg )
		
	TIPS( {type =4 ,str = tipsTxt , isFlower = true })

    --特效
    if getRunScene():getChildByName("showflower") then
    	getRunScene():removeChildByName("showflower")
    end
    local show_node = cc.Node:create()
    show_node:setName("showflower")
    getRunScene():addChild( show_node , 501 )

	local effect = Effects:create(false)
	effect:setRotation( -15 )
	effect:playActionData2("sendFlower", 150, 1, 0)
	show_node:addChild(effect, 500 )
	effect:setAnchorPoint(cc.p(0.5, 0.5))
	effect:setPosition(cc.p(display.width/2 - 150, display.height/2))

	local function showTwo()
		local effect2 = Effects:create(false)
		effect2:setRotation( -15 )
		effect2:playActionData2("sendFlower", 150, 1, 0)
		show_node:addChild(effect2, 500 )
		effect2:setAnchorPoint(cc.p(0.5, 0.5))
		effect2:setPosition(cc.p(display.width/2 + 150, display.height/2))
	end
	local text = createLabel( show_node , sendMsg  , cc.p( display.width/2, display.height/2 + 60 ) , cc.p( 0.5 , 0.5 ) , 25 , true , 501 , nil , MColor.yellow , nil , nil , MColor.yellow , 3 )
	-- text:setRotation( -5 )
	local actions = {}
	actions[#actions+1] = cc.DelayTime:create(1.2)
	actions[#actions+1] = cc.CallFunc:create(showTwo)
	actions[#actions+1] = cc.DelayTime:create(3)
	actions[#actions+1] = cc.CallFunc:create(function() cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("res/effectsplist/sendFlower@0.plist") end)
	actions[#actions+1] = cc.RemoveSelf:create()
	show_node:runAction(cc.Sequence:create(actions))
end

local RECV_RED_BAG_SUCC = function( servData )
	local name = servData:popString()
	local num = servData:popInt()

	TIPS( {type =1 ,str = string.format(game.getStrByKey("succ_get_gold_redbag"), name, num)})
	RefRecvRedBagInfo({time = os.time(), num = num, name = name})
end

local red_hide_status = false
--红包创建
function RED_BAG_CREATE(  )
	if (not G_MAINSCENE) or G_MAINSCENE.REDNODE1 or tablenums(RED_BAG_INTEGRAL.data) == 0 then 
		return 
	end

	local key = nil
	for i,v in pairs(RED_BAG_INTEGRAL.data) do
		if v.time > 0 then
			key = i
			break
		end

		if v.time <= 0 then 
			v = nil
		end
	end
	local item = key and RED_BAG_INTEGRAL.data[key] or nil
	if not item or item.time <= 0 then 
		item = nil 
		return 
	end
	
	local function again()
		if G_MAINSCENE then G_MAINSCENE.REDNODE1 = nil end
		RED_BAG_INTEGRAL.data[key] = nil
		RED_BAG_CREATE()
	end

	local curItem = nil				
	local effTime = 0.5	
	local function createLayout()
			local node = cc.Node:create()

			local width , height = 740 , 25
			local bg = createSprite( node , "res/common/notice_msg_bg.png", cc.p( 0 , 0 ) , cc.p( 0.5 , 0.5 ) ) 
			local bgSize = bg:getContentSize()  
			setNodeAttr( node , cc.p( display.cx , display.height - 200 ) , cc.p( 0 , 0 ) )
			node:setContentSize( bgSize )

			local str = ""
			if item.redtype ~= 1 then
				str = string.format(game.getStrByKey( "red_bag_tip"  .. item.redtype or 0 ),  item.name ) --, item.num or 0
			else
				str = string.format(game.getStrByKey( "red_bag_tip1"),  item.name, item.bossName) --, item.num or 0
			end
			local richText = require("src/RichText").new( node , cc.p( 0 , 0 ) , cc.size( width , height ) , cc.p( 0.5 , 0.5 ) , 27 , 25 , MColor.green )
			richText:setAutoWidth()
			richText:addText( str , MColor.yellow_gray , false )
			richText:format()

			node:setScaleY(0)
			node.text = richText
			richText:setVisible( false )
			setNodeAttr( richText , cc.p( 0 , 30 ) , cc.p( 0.5 , 0.5 ) )
			richText:runAction( cc.Sequence:create( { 
													cc.DelayTime:create( 0.3 ) , 
													cc.CallFunc:create( function() richText:setVisible( not red_hide_status ) end ) , 
													cc.EaseBackOut:create( cc.MoveTo:create( 0.2 , cc.p( 0 , 0 ) ) ) , 
												   } ) )
			bg:setVisible(not red_hide_status)

			local function getFunc()
				if red_hide_status then 
					TIPS({type = 1, str = game.getStrByKey("red_bag_tips1")})
					return
				end
				--G_TUTO_NODE:setTouchNode(nil, TOUCH_MAIN_RED)
				removeFromParent(curItem)
				g_msgHandlerInst:sendNetDataByTableExEx( PUSH_CS_RED_BAG , "PushGetRedBag" , {redBagID = item.bagID})
				again()
			end

			local getBtn = createTouchItem( node , "res/component/button/rob_red.png" , cc.p( bgSize.width/2 - 40 , 0 ) , getFunc , true  )
			--G_TUTO_NODE:setTouchNode(getBtn, TOUCH_MAIN_RED)

			local effLayer = cc.Node:create()
			getBtn:addChild( effLayer , - 1 )
			setNodeAttr( effLayer , cc.p( getBtn:getContentSize().width/2 , getBtn:getContentSize().height/2 ) , cc.p( 0.5 , 0.5 ) )
			local eff = Effects:create(false)
			eff:playActionData("getRedBag", 12 , 2.5 , -1 )
			effLayer:addChild( eff )

			local status_btn = nil
			local changeStatus = function()
				red_hide_status = not red_hide_status
				bg:setVisible(not red_hide_status)
				richText:setVisible(not red_hide_status)
			end
			status_btn = createTouchItem( node , "res/mainui/114.png" , cc.p( bgSize.width/2 - 100 + 133, bgSize.height/2 - 32) , changeStatus, true)

			return node
		end

	curItem= createLayout()
	G_MAINSCENE.REDNODE1 = curItem
	curItem:runAction( cc.Sequence:create( { 
												cc.EaseBackOut:create( cc.ScaleTo:create( effTime  , 1 ) ) , 
												cc.DelayTime:create( item.time ) , 
												cc.CallFunc:create( function() 			
																		--G_TUTO_NODE:setTouchNode(nil, TOUCH_MAIN_RED)			
																		if curItem then removeFromParent(curItem) end
																		curItem = nil
																		again()
																	end )  
												} )
					 )
	G_MAINSCENE:addChild( curItem , 299 )
end

--红包消息接收
local RED_BAG = function(Itemtype, sevData )
	if MRoleStruct:getAttr(ROLE_LEVEL) < 10 then 
		print("RED_BAG del  lev < 10 !!")
		return 
	end
	local item = { }
	item.type = Itemtype or 1
	local retTable = g_msgHandlerInst:convertBufferToTable("PushSendRedBag", sevData)
	item.bagID = retTable.id			--红包ID
	item.name = retTable.name		    --名字
	item.num = retTable.num
	item.redtype = retTable.type
	item.redtype = (item.redtype < 0 or item.redtype > 3) and 0 or item.redtype
	item.time = 10
	item.bossName = retTable.param
	
	if item.name == "" or item.bagID == 0 then 
		--print("!!!!!!!!! RED_BAG  has ERROR! bagID", item.bagID)
		return 
	end

	RED_BAG_INTEGRAL.data = RED_BAG_INTEGRAL.data or {}
	table.insert(RED_BAG_INTEGRAL.data, item)

	--print("RED_BAG",#RED_BAG_INTEGRAL.data ,index)
	--RED_BAG_INTEGRAL.data[ index .. "" ].index = index
	
	RED_BAG_CREATE()
	if G_MAINSCENE then
		G_MAINSCENE:downMoneyEffect()
	end
end

-- local FIELD_BOSS = function(servData)
-- 	if (not G_MAINSCENE) or (G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.isfb) then 
-- 		return  
-- 	end 
-- 	-- --@1110_25_4120_27_35
-- 	local monsterId = servData and servData:popInt() or 6009 --怪物ID
-- 	local mapID = servData and servData:popInt() or 2130 --mapID
-- 	local posx = servData and servData:popInt() or 119 --x
-- 	local posy = servData and servData:popInt() or 88 --y

-- 	local monsterInfo = getConfigItemByKey("monster", "q_id")[monsterId]
-- 	local mapInfo = getConfigItemByKey("MapInfo", "q_id")[mapID]
-- 	if (not monsterInfo) and (not mapInfo)then return end
-- 	local MRoleStruct = require("src/layers/role/RoleStruct")
-- 	local rlvl = MRoleStruct:getAttr(ROLE_LEVEL)
	
-- 	if mapInfo.q_map_min_level and mapInfo.q_map_min_level > rlvl then 
-- 		--TIPS({type =1 , str = string.format(game.getStrByKey("ring_t2"), mapInfo.q_map_min_level)}) 
-- 		return
-- 	end

-- 	local monsterName = monsterInfo["q_name"]
-- 	local mapName = mapInfo["q_map_name"]

--     if getRunScene():getChildByName("FIELD_BOSS") then
--     	getRunScene():removeChildByName("FIELD_BOSS")
--     end

-- 	local node = cc.Node:create()
-- 	node:setName("FIELD_BOSS")
-- 	setNodeAttr( node , cc.p(display.cx, 440), cc.p( 0 , 0 ) )

-- 	local str = string.format(game.getStrByKey( "filed_boss"), monsterName, mapName)
-- 	local bg = createSprite(node, COMMONPATH .. "55.png", cc.p(0, 0), cc.p(0.5, 0.5))
-- 	local bgSize = bg:getContentSize()
-- 	local richText = require("src/RichText").new( node , cc.p( 0, 30 ) , cc.size( 720 , 30 ) , cc.p( 0.5 , 0.5 ) , 20 , 20 , MColor.yellow_gray)
-- 	richText:addText( str , MColor.yellow_gray , true )
-- 	richText:setVisible(false)
-- 	richText:format()

-- 	local function getFunc()
-- 		removeFromParent(node)
-- 		require("src/layers/spiritring/TransmitNode").new(mapID, posx, posy)			
-- 	end
-- 	local getBtn = createTouchItem(node, "res/component/button/34.png", cc.p(305, 0), getFunc, true)

-- 	richText:runAction( cc.Sequence:create( { 
-- 											cc.DelayTime:create( 0.3 ) , 
-- 											cc.Show:create(),
-- 											cc.EaseBackOut:create( cc.MoveTo:create( 0.2 , cc.p( 0 , 0 ) ) ) , 
-- 										} ) )	
	
-- 	node:runAction(cc.Sequence:create( { 
-- 										cc.EaseBackOut:create( cc.ScaleTo:create( 0.5  , 1 ) ) , 
-- 										cc.DelayTime:create( 10) , 
-- 										cc.RemoveSelf:create() 
-- 										} ) 
-- 				)
-- 	getRunScene():addChild( node , 299 )

-- end

--镖车状态返回
local bodyguardStatus = function(buff)
	local t = g_msgHandlerInst:convertBufferToTable("DartStatusRetProtocol", buff) 
	local bool = t.status
	if bool == true then
		if G_MAINSCENE then G_MAINSCENE:createNewActivityNode( "Bodyguard" ) end
	end
end

local onServerNotOpen = function(luaBuffer)
	local function NetErrorToMsgBox(isGotoLogin,text)
		local callback = nil
		if isGotoLogin then
			removeNetLoading()
			callback = function()
				globalInit()
				game.ToLoginScene()
			end
		end
		if not text then
			text = game.getStrByKey("server_stop")
		end
		MessageBox(text,game.getStrByKey("sure"),callback)
	end	

	local retTable = g_msgHandlerInst:convertBufferToTable("LoginLoadPlayerRet", luaBuffer)
    local startTick = retTable.starttick
    local tipStr = game.getStrByKey("tip_notopen_server")
            
    local t = os.date("%Y-%m-%d %H:%M:%S", startTick)
    tipStr = tipStr .. t
    NetErrorToMsgBox(true,tipStr)
end

--模块控制开关
local GAME_CONTROL = function( buff )	
	local t = g_msgHandlerInst:convertBufferToTable( "GameConfigSwitchRetProtocol" , buff ) 
	local gameSwitch =t.gameSwitch
	for i = 1 , #gameSwitch do
		local id = gameSwitch[i].funID
		local isOpen = gameSwitch[i].isActive --true为开，false为关闭
		G_CONTROL:__setData( id , isOpen ) 
	end
end

--查看送镖成员名称
local TEAM_CALL = function( buff )
	local t = g_msgHandlerInst:convertBufferToTable("DartCreatTeamRetProtocol", buff) 

	local isSucc = t.result 	--  队伍是否创建成功
	local num = t.realCnt 	--  当前人数
	local max = t.maxCnt 	--  最大人数


	if isSucc then
		local text = string.format( game.getStrByKey("bodyguard_team28") , num , max )
		local commConst = require("src/config/CommDef")
		local t = {}
		t.channel = commConst.Channel_ID_Team
		t.message = text
		t.area = 1
		t.callType = 3
		t.paramNum = 1
		t.callParams = {"a19"}
		g_msgHandlerInst:sendNetDataByTableExEx(CHAT_CS_CALL_MSG, "CallMsgProtocol", t)						
	end
end

local dartAddrFun = function( buff ) 
	if G_MAINSCENE then
		local t = g_msgHandlerInst:convertBufferToTable( "DartPositionRetProtocol" , buff )
		G_MAINSCENE.dart_objid = t.dartID
		G_MAINSCENE.dart_pos = cc.p(t.x,t.y)
		if G_MAINSCENE.dart_objid <= 0 then
			G_MAINSCENE.dart_objid = nil
		end
		if t.x == -1 and t.y == -1 then
			G_MAINSCENE.dart_pos = nil
			if game.getAutoStatus() == AUTO_MATIC then 
				G_MAINSCENE.map_layer:cleanAstarPath(true,true)
				game.setAutoStatus(0)
			end
		else
			game.setAutoStatus(AUTO_MATIC)
		end
	end
end

--护送任务
local taskAddrFun = function( buff ) 
	if G_MAINSCENE then
		local t = g_msgHandlerInst:convertBufferToTable( "ConvoyPositionRetProtocol" , buff )
		G_MAINSCENE.task_escort_id = t.targetID
		G_MAINSCENE.task_escort_pos = cc.p(t.x,t.y)

		if t.x == -1 and t.y == -1 then
			G_MAINSCENE.task_escort_id = nil
			G_MAINSCENE.task_escort_pos = nil
		end
	end
end

--队长询问组队镖车
local TEAM_DART = function( buff )
	local t = g_msgHandlerInst:convertBufferToTable( "DartQueryTeamDartProtocol", buff ) 
	t.downTime = 30
	t.dart_state = 1 
   	-- local t = { count = 5 , teamID = 5 , runNum = 3 , dart_state = 1 ,  modeid = 2 }
	local createTeamLayer = nil
	createTeamLayer = function( _tempData )
		local timeMax = _tempData.downTime

		local screenBtnFun = nil
		local tempLayer  = createSprite( getRunScene() , "res/common/bg/bg73.png" , cc.p( display.cx , display.cy ) , cc.p( 0.5 , 0.5 ) , 200 )
		local size =  tempLayer:getContentSize()
	    local leftBg =  createScale9Sprite( tempLayer , "res/common/scalable/1.png", cc.p( size.width/2 , 75 ), cc.size( 522 , 320 ) , cc.p( 0.5 , 0 ) )
	    local leftSize = leftBg:getContentSize()

	    createLabel( leftBg , game.getStrByKey( "bodyguard_team6" ) .. "：" , cc.p( 10 , leftSize.height - 5 ) , cc.p( 0 , 1 ) , 20 , nil , nil , nil , MColor.lable_yellow , nil , nil , MColor.black , 3 )
	    local str = string.format( game.getStrByKey( "bodyguard_team24") , _tempData.dartTimes ) 
	    local dartNum = createLabel( leftBg , str ,cc.p( leftSize.width - 10 , leftSize.height - 5  ) , cc.p( 1 , 1 ) , 20 , nil , nil , nil , MColor.green , nil , nil , MColor.black , 3 )
	        

		local timer = nil
	    local func = function() 		
	        removeFromParent( tempLayer )   
	    end
	    registerOutsideCloseFunc( tempLayer , func , true )
	    local close_btn = createMenuItem( tempLayer , "res/component/button/x2.png", cc.p( tempLayer:getContentSize().width-30 , tempLayer:getContentSize().height-27 ) , func )

		
		local propType = 0


		local curBtn = nil
		local cardBtns = {}


		--需要道具数量统计
		local function checkPropInfo( _idx )
		    local needProp =  { 6200033 , 6200034 , 6200035 } 
		    local MPropOp = require "src/config/propOp"
		    local MPackStruct = require "src/layers/bag/PackStruct"
		    local MPackManager = require "src/layers/bag/PackManager"
		    local pack = MPackManager:getPack(MPackStruct.eBag)

		    return pack:countByProtoId( needProp[_idx] ) , MPropOp.name( needProp[ _idx ] ) , MPropOp.nameColorExEx( needProp[ _idx ] ) 
		end


		local addrY = 280
		
		local cardBtns = {}
	    local expCfg = { "25-50" , "50-100" , "105-180" }
	    local lvColor = { MColor.green , MColor.blue , MColor.purple }
	    local curBtn = nil
	    local function regHandlerFun( _btn )
	        local listenner = cc.EventListenerTouchOneByOne:create()
	        listenner:setSwallowTouches( false )
	        listenner:registerScriptHandler(function(touch, event)   
	            local pt = _btn:getParent():convertTouchToNodeSpace(touch)
	            if cc.rectContainsPoint(_btn:getBoundingBox(), pt) then 
	                return true
	            end
	            return false
	            end, cc.Handler.EVENT_TOUCH_BEGAN )
	        listenner:registerScriptHandler(function(touch, event)
	                local start_pos = touch:getStartLocation()
	                local now_pos = touch:getLocation()
	                local span_pos = cc.p(now_pos.x-start_pos.x,now_pos.y-start_pos.y)
	                if math.abs(span_pos.x) < 30 and math.abs(span_pos.y) < 30 then
	                    local pt = _btn:getParent():convertTouchToNodeSpace(touch)
	                    if cc.rectContainsPoint(_btn:getBoundingBox(), pt) and _tempData.dart_state == 1 then
	                        if curBtn then curBtn:setTexture("res/layers/activity/cell/bodyguard/bg.png" ) end
	                        curBtn = _btn
	                        curBtn:setTexture("res/layers/activity/cell/bodyguard/bg_sel.png" )
	                        propType = _btn._idx
	                    end
	                end
	            end, cc.Handler.EVENT_TOUCH_ENDED)
	        local eventDispatcher = _btn:getEventDispatcher()
	        eventDispatcher:addEventListenerWithSceneGraphPriority(listenner,_btn)
	    end

	    
	    for i = 1 , 3  do
	        cardBtns[i] = createSprite( leftBg , "res/layers/activity/cell/bodyguard/bg.png" , cc.p( 4 + ( i - 1 ) * 170 , 5 ) , cc.p( 0 , 0 )  )
	        cardBtns[i]._idx = i
	        regHandlerFun( cardBtns[i] )
	        local size = cardBtns[i]:getContentSize()

	        createSprite( cardBtns[i] , "res/layers/activity/cell/bodyguard/pass_card" .. i .. ".png" , cc.p( size.width/2 , 150 ) , cc.p( 0.5 , 0.5 ) )
	        createLabel( cardBtns[i] , game.getStrByKey( "bodyguard_team" .. ( 6 + i ) ) .. game.getStrByKey( "bodyguard_team18" ) , cc.p( size.width/2  , size.height - 10 ) , cc.p( 0.5 , 1 ) , 20 , nil , nil , nil , lvColor[i] )

	        local str = ""
	        if i > 1 then 
	            local propNum , propName , propColorName = checkPropInfo( i )
	            str = "^c(" .. propColorName .. ")" ..  propName .. "^" .. "(^c(" .. ( propNum > 0 and "green)" or "red)" ) ..  propNum .. "^" .. "/1)"
	        else
	            str = game.getStrByKey("bodyguard_team36")
	        end
	        
	        local richText = require("src/RichText").new( cardBtns[i] , cc.p( size.width/2  , 50 ) , cc.size( 200 , 22 ) , cc.p( 0.5 , 0.5 ) , 20 , 18 , MColor.white )
	        richText:setAutoWidth()
	        richText:addText( str , MColor.lable_yellow , false )
	        richText:format()
	        createLabel( cardBtns[i] , string.format( game.getStrByKey( "bodyguard_team32" ) , expCfg[i] ) , cc.p( size.width/2 , 25 ) , cc.p( 0.5 , 0.5 ) , 18 , nil , nil , nil , MColor.yellow , nil , nil , MColor.black , 3 )

            cardBtns[i].dartIngFlag = createSprite( cardBtns[i] , "res/layers/activity/cell/bodyguard/dart_ing.png" , getCenterPos( cardBtns[i] ) , cc.p( 0.5 , 0.5 ) )
        	cardBtns[i].dartIngFlag:setVisible( false )
	    end

        local upDataFun = function()
	        if _tempData.dart_state == 0 then
	            dartNum:setString( "" )
	        else
	            dartNum:setString( string.format( game.getStrByKey( "bodyguard_team24") , _tempData.dartTimes ) )
	        end

	        if _tempData.dart_state == 3 or _tempData.dart_state == 4 then       
	            _tempData.modeid = _tempData.modeid == 0 and 1 or _tempData.modeid 
	            for i , v in ipairs( cardBtns ) do
	                v:setTexture( "res/layers/activity/cell/bodyguard/" .. ( i == _tempData.modeid and "bg_sel.png" or "bg.png" ) )
	                v.dartIngFlag:setVisible( i == _tempData.modeid )
	            end
	        else
	            for i , v in ipairs( cardBtns ) do
	                v:setTexture( "res/layers/activity/cell/bodyguard/bg.png"  )
	                v.dartIngFlag:setVisible( false )
	            end
	            propType = 0
	        end

	    end
	    upDataFun()

		local function surtHandlerFun()
		    if propType == nil or propType == 0 then
		        TIPS( { type = 1 , str = game.getStrByKey("bodyguard_team6") } )
		        return false
		    end

			g_msgHandlerInst:sendNetDataByTableExEx( DART_CS_ANSWER_TEAMDART , "DartAnswerTeamDartProtocol", { teamID = _tempData.teamID , rewardType = propType , answer = true })
			func()
			
			if propType == 1 then
				if screenBtnFun then screenBtnFun( 0 ) end
			else
			    local num = checkPropInfo( propType )
				if screenBtnFun then screenBtnFun( num <= 0 and timeMax or 0 ) end
			end
		end
		local function cancelHandlerFun()
			--不同意组队镖车
			g_msgHandlerInst:sendNetDataByTableExEx( DART_CS_ANSWER_TEAMDART , "DartAnswerTeamDartProtocol", { teamID = _tempData.teamID , rewardType = 0 , answer = false })
 			func()
			if screenBtnFun then screenBtnFun( 0 ) end
		end
		local sureBtn = createMenuItem( tempLayer , "res/component/button/50.png" , cc.p( size.width/4*3 , 40 ) , surtHandlerFun )
		createLabel( sureBtn , game.getStrByKey( "accept" ) ,getCenterPos( sureBtn ) , nil , 22 , true )

		local cancelBtn = createMenuItem( tempLayer , "res/component/button/50.png" , cc.p( size.width/4*1 , 40 ) , cancelHandlerFun )
		createLabel( cancelBtn  , game.getStrByKey( "refuse" ) , cc.p( 40 , cancelBtn:getContentSize().height/2 ) , nil , 22 , true )
	    
	    local timeStr = createLabel( cancelBtn , "" , cc.p( 90 , cancelBtn:getContentSize().height/2 ) , cc.p( 0.5 , 0.5 ) , 20 , nil , nil , nil , MColor.yellow , nil , nil , MColor.black , 3 )

	    
	    local function refreshTime()
	    	if timeMax >= 0 then
		 		if timeStr and tempLayer then timeStr:setString( "(" .. timeMax ..  game.getStrByKey( "sec" ) .. ")" ) end
		 	else
		 		if timer then timer:stopAllActions() end
		 		func()
		 		cancelHandlerFun()--通知后台
		 	end
		 	if screenBtnFun then screenBtnFun( timeMax ) end
	    	timeMax = timeMax - 1 
	    end

	    timer =  startTimerActionEx( G_MAINSCENE , 1 , true, refreshTime )
	    refreshTime()

	    if G_MAINSCENE  then screenBtnFun = G_MAINSCENE:showDartBtn( createTeamLayer , _tempData ) end
		tempLayer:registerScriptHandler(function(event)
			if event == "enter" then  
			elseif event == "exit" then
				tempLayer = nil
			end
		end)
	end
	
    createTeamLayer( t )

end

--镖车状态
local DART_STATIC = function( buff )
	local t = g_msgHandlerInst:convertBufferToTable( "DartCurStateRetProtocol", buff ) 

	local tempData = {}
	tempData.dart_state = t.state 	--是否满足镖车条件（0：否，1：是，2：已完成镖车(三次用完了),3：正在镖车 4:镖车倒计时中 ）
	tempData.modeid = t.rewardTpye  --道具类型（ 0 无效数据 1青铜 2白银 3黄金 ）
	tempData.hasReward = t.hasReward  		--是否有奖励没领取

	local function onShareToFactionGroup(factionID)
        local title = "行会成员注意了！"
        local desc = "行会运镖时间到，兄弟们一起做活动！"
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

	if tempData.dart_state == 3 or tempData.dart_state == 4 then
		if G_MAINSCENE  then screenBtnFun = G_MAINSCENE:showDartBtn() end
		if tempData.dart_state == 3 then
			local factionID = require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID)
			shareToFactionGroup(factionID)
			if __BODYGUARD then removeFromParent( __BODYGUARD ) end--开始运镖 清除对话框
		end
	end

	local delayFun = function()
		G_MAINSCENE.dart_pos = nil
		if game.getAutoStatus() == AUTO_MATIC and  tempData.dart_state == 0  then 
			G_MAINSCENE.map_layer:cleanAstarPath(true,true)
			game.setAutoStatus(0)
		end

		if DATA_Mission and ( tempData.dart_state == 3 or tempData.dart_state == 2  or tempData.dart_state == 0 ) then
			if DATA_Mission.DART_STATIC then
				if DATA_Mission.DART_STATIC.dart_state ~= tempData.dart_state then
					game.setAutoStatus(AUTO_MATIC)
				end
			elseif tempData.dart_state == 3 then
				game.setAutoStatus(AUTO_MATIC)
			end
			DATA_Mission.DART_STATIC = tempData

			local taskMain = DATA_Mission:getCallback( "main_flag" )
			if taskMain then taskMain() end
		end
	end
	delayFun()
	if G_MAINSCENE then performWithDelay( G_MAINSCENE , delayFun , 1 ) end--延迟生成(预防数据发送过早 DATA_Mission 为空 )
end

local onTssdkAntiData = function( buff ) 
    local t = g_msgHandlerInst:convertBufferToTable( "TssdkSendAntiDataProtocol" , buff )
    TersafeSDK:on_recv_data_which_need_send_to_client_sdk(t.data, t.dataSize)
end

local onSkillSpeedCheckStart = function( buff ) 
	local t = g_msgHandlerInst:convertBufferToTable( "SkillSpeedCheckStart" , buff )
    require("src/base/AttackFuncEx")
    onStartCheckClientSkillSpeed(t.svrStartTime, t.lastTime)
    --print("SKILL_CS_SPEEDCHECK_Start +++++++++++++%%%%%%%%%%+++")
end

local onFactionQQGroupOpenIDNotify = function(buff)
	local t = g_msgHandlerInst:convertBufferToTable( "FactionOpenIdNotify" , buff )
    require("src/layers/faction/FactionMapLayer")
    onGetSvrOpenId(t.openId)
    print("suzhen --------- FactionOpenIdNotify , openId is " .. t.openId)
end

local function charmRankInfo(servData)
	G_CharmRankList = {}
	local retTab = g_msgHandlerInst:convertBufferToTable("RankGlamourRet", servData)
	local strName, totleNum = retTab.name, retTab.glamour
	G_CharmRankList.ListData = {}
	if strName and strName ~= "" and totleNum and totleNum ~= 0 then
		G_CharmRankList.ListData[1] = {}
		G_CharmRankList.ListData[1][2] = strName
		G_CharmRankList.ListData[1][4] = totleNum
	end
	--dump(G_CharmRankList.ListData[1], "G_CharmRankList")

	if G_MAINSCENE then
		G_MAINSCENE.map_layer:setCharmTopName(strName)
	end	
end

local function no1Info(servData)
	--print("no1Info ...............................................")
	G_NO_ONEINFO = {}
	local retTab = g_msgHandlerInst:convertBufferToTable("RankGetNo1RetProtocol", servData)
	retTab = retTab.name 
	G_NO_ONEINFO[1] = retTab[1]
	G_NO_ONEINFO[2] = retTab[3]
	G_NO_ONEINFO[3] = retTab[5]
	G_NO_ONEINFO[4] = retTab[2]
	G_NO_ONEINFO[5] = retTab[4]
	G_NO_ONEINFO[6] = retTab[6]
	--dump(G_NO_ONEINFO, "G_NO_ONEINFO")
	
	if G_MAINSCENE then
		G_MAINSCENE.map_layer:setNo1NpcName()
	end
end

local function BiqiKingInfo(servData)
	local retTab = g_msgHandlerInst:convertBufferToTable("ManorGetLeaderInfoRetProtocol", servData)  
	G_EMPIRE_INFO.BIQI_KING.sex    = retTab.sex
	G_EMPIRE_INFO.BIQI_KING.school = retTab.school
	G_EMPIRE_INFO.BIQI_KING.name   = retTab.name or ""
	--dump(G_EMPIRE_INFO.BIQI_KING, "BIQI_KING")

	if G_MAINSCENE then
		G_MAINSCENE.map_layer:setBiqiKingName()
	end
end

local function shaWarKingInfo(servData)
	local retTab = g_msgHandlerInst:convertBufferToTable("ShaGetLeaderRetProtocol", servData)  
	G_SHAWAR_DATA.KING.sex    = retTab.sex
	G_SHAWAR_DATA.KING.school = retTab.school
	G_SHAWAR_DATA.KING.name   = retTab.name or ""
	
	--dump(G_SHAWAR_DATA.KING, "G_SHAWAR_DATA.KING")

	if G_MAINSCENE then
		G_MAINSCENE.map_layer:setShaKingName()
	end	
end

local function WkInfo(servData)
	local t = g_msgHandlerInst:convertBufferToTable("DigMineOpenRet", servData)
	G_WKINFO.changeFlg = t.canExchange
	-- local award = t.reward
	-- local forNum = 0
	-- if award then forNum = tablenums(award) end
	-- G_WKINFO.awardData = {}
	-- for i=1, forNum do
	-- 	G_WKINFO.awardData[i] = {award[i].itemID, award[i].count}
	-- end
	--dump(G_WKINFO, "G_WKINFO")
end

local function hejiu(servData)
	local retTab = g_msgHandlerInst:convertBufferToTable("GetWineNumRetProtocol", servData)
	userInfo.hejiuLeftTime = retTab.wineNum
	--dump(userInfo.hejiuLeftTime, "userInfo.hejiuLeftTime")
	-- if userInfo.hejiuLeftTime == 0 then
	-- 	DATA_Battle:setRedData( "XWZJ", false)
	-- end
	-- if g_EventHandler["hjTimeChangeCallBack"] then
	-- 	g_EventHandler["hjTimeChangeCallBack"]()
	-- end
	-- if G_MAINSCENE then
	-- 	G_MAINSCENE:removeActivityIconData({
 -- 				btnResName = "res/mainui/subbtns/xwzj.png",
 -- 				})
	-- end
end

--山贼入侵奖励展示
local function INVAED_AWARD_SHOW( buff )
	local t = g_msgHandlerInst:convertBufferToTable( "InvadeRewardRet", buff )
	local awards = FORMAT_AWARDS( t.reward )

	if DATA_Battle.INVAED_NPC_PANEL then
		removeFromParent(DATA_Battle.INVAED_NPC_PANEL)
		DATA_Battle.INVAED_NPC_PANEL = nil
	end

	local tempTab = { 
	                award_tip = game.getStrByKey("invade_title") .. game.getStrByKey("award") , 
	                isGet = false  , 
	                awards = awards ,
	            }

	Awards_Panel( tempTab )

end

--山贼入侵NPC弹出面板
local function INVAED_POPUP( buff )
	local t = g_msgHandlerInst:convertBufferToTable( "InvadeHasReward" , buff ) 

    local tempLayer = popupBox({ 
								bg = COMMONPATH .. "bg/bg18.png" , 
								close = { path = "res/component/button/x2.png" , offX = -50 , offY = -25 , callback = function()  end } , 
								zorder = 200 , 
								actionType = 8 ,
								noNewAction = true ,
								isNoSwallow = false ,
		                   })
    DATA_Battle.INVAED_NPC_PANEL = tempLayer
    local size = tempLayer:getContentSize()
    createLabel( tempLayer , game.getStrByKey( "invade_title" )   , cc.p( size.width/2 , size.height - 25  ) , cc.p( 0.5 , 0.5 ) , 22 , true , nil , nil  )

    local bg = createScale9Sprite( tempLayer , "res/common/scalable/1.png" , cc.p( size.width/2 + 3 , size.height/2 -20 ), cc.size( 790 , 454 ) , cc.p( 0.5 , 0.5 ) )
    createSprite( bg , "res/layers/activity/cell/invade/award_bg.png", cc.p( 8 , bg:getContentSize().height/2 ) , cc.p( 0.0 , 0.5 ))
    local rbg = createScale9Sprite( bg , "res/common/scalable/panel_inside_scale9.png", cc.p( 440 , bg:getContentSize().height/2 ), cc.size( 340 , 435 ) , cc.p(0.0 , 0.5 ) )
    
    



    local strs = { game.getStrByKey( "open") .. game.getStrByKey( "level" ) .. "：" .. string.format( game.getStrByKey( "week_tuto23" ) , "3" ) }  --开启等级
    strs[ #strs + 1 ] = game.getStrByKey( "open_time_ch") .. "：" .. game.getStrByKey( "invade_day" ) .. "^c(white)19：00-20:00^" --开启时间
    strs[ #strs + 1 ] = game.getStrByKey( "activity") .. game.getStrByKey( "desc_text" )  --活动描述
    strs[ #strs + 1 ] = game.getStrByKey("invade_desc") --活动描述

    for i = 1 , #strs do
	    local richText = require("src/RichText").new( rbg , cc.p( 10  , rbg:getContentSize().height - ( i - 1 ) * 30 - 15   ) , cc.size( 320 , 22 ) , cc.p( 0 , 1 ) , 22 , 20 , MColor.lable_yellow )
	    richText:setAutoWidth()
	    richText:addText( strs[i] , MColor.lable_yellow , false )
	    richText:format()
    end
    


    if t.state == 1 then
    	--活动进行中
    	createLabel( rbg , game.getStrByKey( "activity") .. game.getStrByKey( "empire_biqi_time_active" )  , cc.p(  rbg:getContentSize().width/2 , 60  ) , cc.p( 0.5 , 0.5 ) , 24 , nil , nil , nil , MColor.yellow )
    elseif t.state == 2 then
    	--有奖励可领取
	    local tempBtn = createMenuItem( rbg , "res/component/button/50.png" , cc.p( rbg:getContentSize().width/2 , 60 ) , function() g_msgHandlerInst:sendNetDataByTableExEx( INVADE_CS_REWARD , "InvadeReward", {} ) end  )   
	    createLabel( tempBtn , game.getStrByKey( "get_awards") , getCenterPos( tempBtn ) , cc.p( 0.5 , 0.5 ) , 20 , nil , nil , nil , MColor.lable_yellow , nil , nil , MColor.black , 3 )
    elseif t.state == 3 then
    	--未开启
    	createLabel( rbg , game.getStrByKey( "open_tip2")  , cc.p(  rbg:getContentSize().width/2 , 60  ) , cc.p( 0.5 , 0.5 ) , 24 , nil , nil , nil , MColor.yellow )
    end
    
    createLabel( rbg , game.getStrByKey("activity_awards")  , cc.p( 10 , 225 ) , cc.p( 0 , 0.5 ) , 20 , true , 501 , nil , MColor.lable_yellow )

    local awards = {} --奖励道具
    --奖励数据处理
    local DropOp = require("src/config/DropAwardOp")
    local tempTable = DropOp:dropItem_ex( 2235 )
    for i , v in ipairs( tempTable ) do
        awards[i] = { 
                        id = v["q_item"] ,                          --奖励ID
                        binding = v["bdlx"] ,                       --绑定(1绑定0不绑定)
                        streng = v["q_strength"] ,                  --强化等级
                        quality = v["q_quality"] ,                  --品质等级
                        upStar = v["q_star"] ,                      --升星等级
                        time = v["q_time"] ,                        --限时时间
                        showBind = true ,                           --掉落表数据里边的数据  就必须设置当前这个字段存在且为true
                        isBind = tonumber(v["bdlx"] or 0) == 1,     --绑定表现
                    }
    end
    if awards then
        local iconGroup = __createAwardGroup( awards , nil , 90 )
        setNodeAttr( iconGroup , cc.p( -5  , 160  ) , cc.p( 0 , 0.5 ) )
        rbg:addChild( iconGroup )
    end
end

local function onFactionQQGroupBindSuccessNotify()

end

local function capturedMapInfo(servData)
	local retTab = g_msgHandlerInst:convertBufferToTable("GetOwnFactionRetProtocol", servData)
	local info = retTab.ownFactionInfo
	for k,v in pairs(info) do
		local tempManorID = v.manorID
		local factionID = v.facId

		local recode = {facId = factionID}

		G_EMPIRE_INFO.CAPTURED_INFO[tempManorID] = recode		
	end
	--dump(G_EMPIRE_INFO.CAPTURED_INFO)
	--dump(getFactionCapturedMap(MRoleStruct:getAttr(PLAYER_FACTIONID)), "getFactionCapturedMap")
end

g_msgHandlerInst:registerMsgHandler(SPILLFLOWER_SC_RET, SHOW_FLOWER )       --全服撒花展示
g_msgHandlerInst:registerMsgHandler(SPILLFLOWER_SC_CALLMEMBER, function( buff ) if G_MAINSCENE then G_MAINSCENE:showArrowBtn( buff , false ) end end )       --穿云箭号召行会内所有玩家
g_msgHandlerInst:registerMsgHandler(PUSH_SC_GET_INGOT_BAG, RECV_RED_BAG_SUCC)
g_msgHandlerInst:registerMsgHandler( PUSH_SC_RED_BAG , function( ... ) RED_BAG(1, ... )  end )        --发积分红包
--g_msgHandlerInst:registerMsgHandler( WORLDBOSS_SC_NEWBOSS , FIELD_BOSS)        --野外boss刷新
g_msgHandlerInst:registerMsgHandler( DART_SC_STATUS_RET , bodyguardStatus)   --镖车状态查询返回
g_msgHandlerInst:registerMsgHandler( ACTIVITY_SC_LIST_RET , function( buff )  if not DATA_Activity then require("src/layers/activity/ActivityData"):__init() end DATA_Activity:__refreshIconState( buff ) end )        --活动数据处理
g_msgHandlerInst:registerMsgHandler( LOGIN_GC_LOAD_PLAYER, onServerNotOpen)  --服务器未开放
g_msgHandlerInst:registerMsgHandler( GAMECONFIG_SC_GAME_SWITCH , GAME_CONTROL)        --模块控制开关

g_msgHandlerInst:registerMsgHandler( DART_SC_CREATTEAM_RET , TEAM_CALL)        --镖车喊人
g_msgHandlerInst:registerMsgHandler( DART_SC_POSITION_RET , dartAddrFun ) --镖车坐标点
g_msgHandlerInst:registerMsgHandler( DART_SC_CURSTATE_RET , DART_STATIC ) --镖车状态
g_msgHandlerInst:registerMsgHandler( DART_SC_QUERY_TEAMDART, TEAM_DART )  --镖车组队询问

g_msgHandlerInst:registerMsgHandler( CONVOY_SC_POSITION_RET , taskAddrFun)   --护送任务状态查询返回

g_msgHandlerInst:registerMsgHandler( TSSDK_SC_SENDANTIDATA , onTssdkAntiData ) --sdk安全相关
g_msgHandlerInst:registerMsgHandler( SKILL_SC_SPEEDCHECK_START , onSkillSpeedCheckStart ) --通知客户端进行60s 加速校验检测

g_msgHandlerInst:registerMsgHandler( FACTION_OPENID_SC_NTF , onFactionQQGroupOpenIDNotify ) --通知客户端玩家所在公会群的QQ群openID
g_msgHandlerInst:registerMsgHandler( FACTION_OPENID_SC_BIND_RET , onFactionQQGroupBindSuccessNotify ) --通知客户端会长玩家绑定QQ群成功(暂时无用)


g_msgHandlerInst:registerMsgHandler( RANK_SC_GET_NO1_DATA, function(...) no1Info(...) end)  --天下第一		
g_msgHandlerInst:registerMsgHandler( MANORWAR_SC_GET_LEADERINFO_RET, function(...) BiqiKingInfo(...) end)  --中州王		
g_msgHandlerInst:registerMsgHandler( DIGMINE_SC_OPEN_RET, function(...) WkInfo(...) end)  --挖矿
g_msgHandlerInst:registerMsgHandler( SHAWAR_SC_GETLEADER_RET, function(...) shaWarKingInfo(...) end)  --沙城主
g_msgHandlerInst:registerMsgHandler( GIVEWINE_SC_GETWINE_NUM, function(...) hejiu(...) end)  --王城赐福
g_msgHandlerInst:registerMsgHandler( RANK_SC_GLAMOUR_RET, function(...) charmRankInfo(...) end)  --魅力值排行榜数据解析
g_msgHandlerInst:registerMsgHandler( INVADE_SC_HAS_REWARD, INVAED_POPUP )  --山贼入侵NPC面板
g_msgHandlerInst:registerMsgHandler( INVADE_SC_REWARD_RET, INVAED_AWARD_SHOW )  --山贼入侵奖励展示
g_msgHandlerInst:registerMsgHandler( QQVIP_SC_REWARD_INFO, function(...)  require( "src/layers/qqMember/qqMemberLayer" ).onReset(...) end )  --QQ特权信息
g_msgHandlerInst:registerMsgHandler( MANORWAR_SC_GETOWNFACTIONRET, function(...) capturedMapInfo(...) end )  --领地帮派信息

--世界Boss数据
g_msgHandlerInst:registerMsgHandler(ACTIVITY_SC_BOSSRET, function(luabuffer)
    DATA_Activity:ExecuteCallback("WorldBossUpdate", luabuffer);
end)


require("src/layers/chat/ChatMsgHandler")
require("src/layers/mail/MailMsgHandler")
require("src/layers/fb/FBMsgHandler")
require("src/layers/faction/FactionFBMsgHandler")
require("src/layers/teamup/TeamMsgHandler")
require("src/layers/wingAndRiding/WingAndRidingMsgHandler")
require("src/layers/tuto/TutoMsgHandler")
require("src/layers/spiritring/spiritringMsgHandler")
require("src/layers/achievementEx/AchievementAndTitleMsgHandler")
require("src/layers/role/fightMsgHandler")
require("src/layers/mine/MineMsgHandler")
require("src/layers/empire/BiQiMsgHandler")
require("src/layers/shaWar/shaWarMsgHandler")
require("src/layers/shop/consumeMsgHandler")
require("src/layers/skill/SkillMsgHandler")
require("src/layers/friend/MasterMsgHandler")
require("src/layers/faction/FactionMsgHandler")
require("src/layers/char/CharMsgHandler")
require("src/layers/jieyi/JieYiMsgHandler")
require("src/layers/VS/VSMsgHandler")
require("src/layers/mysteriousArea/ma_mysteriousAreaMsgHandler")
require("src/base/BaseMapSceneMsgHandler")
require("src/layers/weddingSystem/WeddingSysMsgHandler")