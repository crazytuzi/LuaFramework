--[[ 组队镖车 ]]--
local M = class( "bodyguard" , require( "src/TabViewLayer" ) )
local FirendList = class("FirendList", require ("src/TabViewLayer") )
function M:ctor( params )
    params = params or {}
    self.data = params.data or { teamList = { } }
    
    __BODYGUARD = self

    self.cardType = nil --道具ID（ 1铜 2银 3金 ）
    self.base_node = createBgSprite(self,game.getStrByKey("bodyguard_title"))
    
    --createSprite(self.base_node, "res/common/bg/bg-6.png" , cc.p( 17 , 18 ) , cc.p( 0 , 0 ) )
    local leftBg = createScale9Sprite( self.base_node ,"res/common/scalable/bg4.png" , cc.p( 33 , 35 ) , cc.size( 515 , 501 ) , cc.p( 0 , 0 ) )
    local leftSize = leftBg:getContentSize()

    local textCfg = { 
                       { str = game.getStrByKey( "bodyguard_lv" ) .. "：" , y = 170 , color = MColor.lable_yellow } , 
                       { str = string.format( game.getStrByKey( "bodyguard_tip1" ) , self.data.level ), x = 100 , y = 170 , color =  MColor.lable_black } , 
                       { str = game.getStrByKey( "bodyguard_tip" ) .. "：" ,  y = 140 , color = MColor.lable_yellow} , 
                       { str = game.getStrByKey( "bodyguard_tip2" ) .. "：" ,  x = 100 ,  y =  140, color =  MColor.lable_black } , 
                       { str = game.getStrByKey( "bodyguard_tip4" )  , maxWidth = 500 ,  fontSize = 16 , y = 80 , color = MColor.red  } , 
                    }
    for i = 1 , #textCfg do
        local content = createLabel( leftBg , textCfg[i].str , cc.p( textCfg[i].x or 5 , textCfg[i].y ) , cc.p( 0 , 1 ) , textCfg[i].fontSize or 20 , nil , nil , nil , textCfg[i].color , nil , nil , MColor.black , 3 )
        content:setDimensions( textCfg[i].maxWidth or 400 , 0 )
    end


    
    createSprite( leftBg ,"res/common/shadow/bodyguard_shadow.png" , cc.p( leftSize.width/2 , 5 ) ,  cc.p( 0.5 , 0 ) )
    createLabel( leftBg , game.getStrByKey( "bodyguard_team4" )  , cc.p( leftSize.width/2 , 10 ) , cc.p( 0.5 , 0 ) , 22 , nil , nil , nil , MColor.lable_yellow , nil , nil , MColor.black , 2 )
    
    local str = "^c(black)" ..  game.getStrByKey( "bodyguard_team20" ) .. ":^\n"
    str = str .. "^c(deep_brown)" .. game.getStrByKey( "bodyguard_team21" ) .. "^\n"
    str = str .. "^c(red)" .. game.getStrByKey( "bodyguard_team22" ) .. game.getStrByKey( "bodyguard_team23" ) .. "\n" .. game.getStrByKey( "bodyguard_team29" ) .. "\n" .. game.getStrByKey( "bodyguard_team19" ) .. "^\n"
    local helpBtn = __createHelp( { parent = leftBg, str =  str , pos = cc.p( 30 , 80 - 57 ) } )
    -- helpBtn:setScale( 0.8 )
    


    createLabel( leftBg , game.getStrByKey( "bodyguard_team6" ) .. "：" , cc.p( 10 , leftSize.height - 10 ) , cc.p( 0 , 1 ) , 20 , nil , nil , nil , MColor.lable_yellow , nil , nil , MColor.black , 3 )

    local str = ""
    if self.data.dart_state == 0 then
        str = string.format( game.getStrByKey( "bodyguard_team24") , self.data.runNum ) 
    end
    local dartNum = createLabel( leftBg , str ,cc.p( leftSize.width - 10 , leftSize.height - 10  ) , cc.p( 1 , 1 ) , 20 , nil , nil , nil , MColor.green , nil , nil , MColor.black , 3 )
        

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
                    if cc.rectContainsPoint(_btn:getBoundingBox(), pt) and self.data.dart_state == 1 then
                        if curBtn then curBtn:setTexture("res/layers/activity/cell/bodyguard/bg.png" ) end
                        curBtn = _btn
                        curBtn:setTexture("res/layers/activity/cell/bodyguard/bg_sel.png" )
                        self.cardType = _btn.idx
                    end
                end
            end, cc.Handler.EVENT_TOUCH_ENDED)
        local eventDispatcher = _btn:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listenner,_btn)
    end

    local function createPropInfo( i )
        local node = cc.Node:create()
        local str = ""
        if i > 1 then 
            local propNum , propName , propColorName = self:checkPropInfo( i )
            str = "^c(" .. propColorName .. ")" ..  propName .. "^" .. "(^c(" .. ( propNum > 0 and "green)" or "red)" ) ..  propNum .. "^" .. "/1)"
        else
            str = game.getStrByKey("bodyguard_team36")
        end
        
        local richText = require("src/RichText").new( node , cc.p( 0  , 0 ) , cc.size( 200 , 22 ) , cc.p( 0.5 , 0.5 ) , 20 , 18 , MColor.white )
        -- local richText = require("src/RichText").new( cardBtns[i] , cc.p( size.width/2  , 50 ) , cc.size( 200 , 22 ) , cc.p( 0.5 , 0.5 ) , 20 , 18 , MColor.white )
        richText:setAutoWidth()
        richText:addText( str , MColor.lable_yellow , false )
        richText:format()

        return node 
    end

    for i = 1 , 3  do
        cardBtns[i] = createSprite( leftBg , "res/layers/activity/cell/bodyguard/bg.png" , cc.p( 4 + ( i - 1 ) * 170 , 175 ) , cc.p( 0 , 0 )  )
        cardBtns[i].idx = i
        regHandlerFun( cardBtns[i] )
        local size = cardBtns[i]:getContentSize()

        createSprite( cardBtns[i] , "res/layers/activity/cell/bodyguard/pass_card" .. i .. ".png" , cc.p( size.width/2 , 150 ) , cc.p( 0.5 , 0.5 ) )
        createLabel( cardBtns[i] , game.getStrByKey( "bodyguard_team" .. ( 6 + i ) ) .. game.getStrByKey( "bodyguard_team18" ) , cc.p( size.width/2  , size.height - 10 ) , cc.p( 0.5 , 1 ) , 20 , nil , nil , nil , lvColor[i] )

        local function refreshInfo()
            if cardBtns[i].propInfo then removeFromParent( cardBtns[i].propInfo ) end
            cardBtns[i].propInfo = createPropInfo( i )
            setNodeAttr( cardBtns[i].propInfo , cc.p( size.width/2  , 50  ) , cc.p( 0.5 , 0.5 ) )
            cardBtns[i]:addChild( cardBtns[i].propInfo )
        end
        cardBtns[i].propInfoRefresh = refreshInfo
        cardBtns[i].propInfoRefresh()

        createLabel( cardBtns[i] , string.format( game.getStrByKey( "bodyguard_team32" ) , expCfg[i] ) , cc.p( size.width/2 , 25 ) , cc.p( 0.5 , 0.5 ) , 18 , nil , nil , nil , MColor.yellow , nil , nil , MColor.black , 3 )

        cardBtns[i].dartIngFlag = createSprite( cardBtns[i] , "res/layers/activity/cell/bodyguard/dart_ing.png" , getCenterPos( cardBtns[i] ) , cc.p( 0.5 , 0.5 ) )
        cardBtns[i].dartIngFlag:setVisible( false )
    end

    local pack = MPackManager:getPack(MPackStruct.eBag)
    local tmp_node = cc.Node:create()
    local tmp_func = function(observable, event, pos, pos1, new_grid)
        if event == "-" or event == "+" or event == "=" then
            if self.cardType == 0 then return end
            cardBtns[ self.cardType ].propInfoRefresh()
        end
    end
    tmp_node:registerScriptHandler(function(event)
        if event == "enter" then
            pack:register(tmp_func)
        elseif event == "exit" then
            pack:unregister(tmp_func)
        end
    end)
    self:addChild(tmp_node)


    local rightBg = createScale9Sprite( self.base_node ,"res/common/scalable/bg4.png" , cc.p( 555 , 35 ) , cc.size( 375 , 501 )  , cc.p( 0 , 0 ) )
    local rightSize = rightBg:getContentSize()
	CreateListTitle(rightBg, cc.p(rightSize.width/2 , rightSize.height), 369, 43, cc.p( 0.5, 1 ))
    createSprite( rightBg ,"res/common/bg/bg67-2-2.png" , cc.p( rightSize.width/2 , 0 ) ,  cc.p( 0.5 , 0 ) )
    createLabel( rightBg , game.getStrByKey( "bodyguard_team5" )  , cc.p( rightSize.width/2 , rightSize.height - 7 ) , cc.p( 0.5 , 1 ) , 22 , nil , nil , nil , MColor.lable_yellow , nil , nil , MColor.black , 2 )

    self:createTableView( self.base_node , cc.size( 368 , 375 ) , cc.p( 562 , 115 ) , true , true )
    self:getTableView():setBounceable(true)


    local function escortFun( _tag )
        if self:checkOut()  then
            if _tag == 1 then
                --集体护送
                if self.cardType == 1 then
                    self:createTeam()
                else
                    if self.cardType > 0   then
                        local propNum , propName , propColorName = self:checkPropInfo( self.cardType )
                        if propNum == 0 then
                            self:askCreateCar( 0 , 2 )
                        else
                            self:createTeam()
                        end
                    end
                end
            else
                --个人护送
                self:askCreateCar( 1 , 1 )
                -- self.base_node:remove()
            end
        end
    end

    local teamBtn = createMenuItem( rightBg , "res/component/button/2.png" , cc.p( rightSize.width/7*2 , 35 ) , function() escortFun(2) end  )   
    createLabel( teamBtn , game.getStrByKey( "bodyguard_team11") , getCenterPos( teamBtn ) , cc.p( 0.5 , 0.5 ) , 20 , nil , nil , nil , MColor.lable_yellow , nil , nil , MColor.black , 3 )
    
    
    local personalBtn = createMenuItem( rightBg , "res/component/button/2.png" , cc.p( rightSize.width/7*5 , 35 ) , function() escortFun(1) end  )   
    createLabel( personalBtn , game.getStrByKey( "bodyguard_team10") , getCenterPos( personalBtn ) , cc.p( 0.5 , 0.5 ) , 20 , nil , nil , nil , MColor.lable_yellow , nil , nil , MColor.black , 3 )
    local descText = createLabel( rightBg , game.getStrByKey( "bodyguard_team16") , cc.p( rightSize.width/2 , 40  ) , cc.p( 0.5 , 0.5 ) , 24 , nil , nil , nil , MColor.green , nil , nil , MColor.black , 3 )



    local upDataFun = function( _data )
        self.data = _data
 
        if self.data.dart_state == 0 then
            dartNum:setString( "" )
        else
            dartNum:setString( string.format( game.getStrByKey( "bodyguard_team24") , self.data.runNum ) )
        end

        teamBtn:setVisible( self.data.dart_state == 1 )
        personalBtn:setVisible( self.data.dart_state == 1 )
        descText:setString( "" )

        if self.data.dart_state == 3 or self.data.dart_state == 4 then       
            self.data.modeid = self.data.modeid == 0 and 1 or self.data.modeid 
            for i , v in ipairs( cardBtns ) do
                v:setTexture( "res/layers/activity/cell/bodyguard/" .. ( i == self.data.modeid and "bg_sel.png" or "bg.png" ) )
                v.dartIngFlag:setVisible( i == self.data.modeid )
            end
        else
            for i , v in ipairs( cardBtns ) do
                v:setTexture( "res/layers/activity/cell/bodyguard/bg.png"  )
                v.dartIngFlag:setVisible( false )
            end
            self.cardType = 0
        end

        if self.data.dart_state == 0 then
            descText:setString( game.getStrByKey( "bodyguard_team16") )
        elseif self.data.dart_state == 1 then
            
        elseif self.data.dart_state == 2 then       
            descText:setString( game.getStrByKey( "bodyguard_team13") )
        elseif self.data.dart_state == 3 then       
            descText:setString( game.getStrByKey( "bodyguard_team14") )
        elseif self.data.dart_state == 4 then      
            self.data.modeid = self.data.modeid == 0 and 1 or self.data.modeid 
            local propNameCfg = { game.getStrByKey( "bodyguard_team7" ) , game.getStrByKey( "bodyguard_team8" ) , game.getStrByKey( "bodyguard_team9" ) }
            descText:setString( string.format( game.getStrByKey( "bodyguard_team15") , propNameCfg[ self.data.modeid ] )  )
        end

        self:getTableView():reloadData()
    end

    __BODYGUARD.upDataFun = upDataFun
    upDataFun( self.data )



    self:registerScriptHandler(function(event)
        if event == "enter" then
        elseif event == "exit" then
            __BODYGUARD = nil
        end
    end)

end

--需要道具数量统计
function M:checkPropInfo( _idx )
    local needProp =  { 6200033 , 6200034 , 6200035 } 
    local MPropOp = require "src/config/propOp"
    local MPackStruct = require "src/layers/bag/PackStruct"
    local MPackManager = require "src/layers/bag/PackManager"
    local pack = MPackManager:getPack(MPackStruct.eBag)

    return pack:countByProtoId( needProp[_idx] ) , MPropOp.name( needProp[ _idx ] ) , MPropOp.nameColorExEx( needProp[ _idx ] ) 
end

--资格判定
function M:checkOut()
    if self.data.dart_state == 0 then
        TIPS( getConfigItemByKeys("clientmsg",{"sth","mid"},{ 1 , -2 }) )
        return false
    end
    if self.cardType == nil or self.cardType == 0 then
        TIPS( { type = 1 , str = game.getStrByKey("bodyguard_team6") } )
        return false
    end

    -- local propNum , propName = self:checkPropInfo( self.cardType )
    -- if propNum <= 0 then
    --     local msg_item = getConfigItemByKeys("clientmsg",{"sth","mid"},{ 5000 , -40 })
    --     if msg_item  then
    --         local str = string.format( msg_item.msg , propName )
    --         TIPS( { type = msg_item.tswz , str = str , flag = msg_item.flag   } )
    --     end
    --     return false
    -- end

    return true
end

--请求加入队伍
function M:askJoinTeam( _itemData , isExit , isLeader )
    if isExit  then
        --解散或退出
        if isLeader then
            local func = function(tag)
                local switch = {
                                [1] = function() 
                                    g_msgHandlerInst:sendNetDataByTableExEx(DART_CS_JOINTEAM, "DartJoinTeamProtocol", { teamID = _itemData.teamID , rewardType = 0 } )
                                end,
                                [2] = function() 
                                    local text = string.format( game.getStrByKey("bodyguard_team28") , _itemData.teamNum , _itemData.teamMax )
                                    local commConst = require("src/config/CommDef")
                                    local t = {}
                                    t.channel = commConst.Channel_ID_Team
                                    t.message = text
                                    t.area = 1
                                    t.callType = 3
                                    t.paramNum = 1
                                    t.callParams = {"a19"}
                                    g_msgHandlerInst:sendNetDataByTableExEx(CHAT_CS_CALL_MSG, "CallMsgProtocol", t )     
                                    TIPS({ str =  game.getStrByKey("team_hanren2") })
                                end,
                                [3] = function() 
                                    -- INVITE_FIRENDS()
                                    FirendList.new()
                                end,
                                }
                if switch[tag] then switch[tag]() end
                removeFromParent(self.operate)
                self.operate = nil
            end
            local menus = {
                              {game.getStrByKey("bodyguard_team25"),1,func},
                              {game.getStrByKey("bodyguard_team37"),2,func},
                              {game.getStrByKey("social_qq_invite"),3,func},
                            }

            self.operate =  require("src/OperationLayer").new( self , 1 , menus )
            self.operate:setPosition(cc.p( 200 , 0 ) )
        else
            g_msgHandlerInst:sendNetDataByTableExEx(DART_CS_JOINTEAM, "DartJoinTeamProtocol", { teamID = _itemData.teamID , rewardType = 0 } )
        end
    else
        local function askFun()
            if self:checkOut() then
                g_msgHandlerInst:sendNetDataByTableExEx(DART_CS_JOINTEAM, "DartJoinTeamProtocol", { teamID = _itemData.teamID , rewardType = self.cardType } )
            end
        end
        if G_TEAM_INFO.has_team then
            MessageBoxYesNo(nil,game.getStrByKey("bodyguard_team38"), askFun , nil , game.getStrByKey("sure"),game.getStrByKey("cancel") )
        else
            askFun()
        end
    end
end

--请求创建镖车
function M:askCreateCar( _num , _teamType )
    -- _num 人员个数 (0  表示检查集体运镖道具个数 )
    -- teamType: short类型( 1,表示个人镖车，2，表示组队镖车）
    if self.cardType then
        g_msgHandlerInst:sendNetDataByTableExEx(DART_CS_CREATTEAM, "DartCreatTeamProtocol", { rewardType = self.cardType , maxCnt = _num , teamType = _teamType  } )
    end
end

--生成队伍界面
function M:createTeam()
    local tempLayer = popupBox({ parent = getRunScene() , 
                     bg = COMMONPATH .. "bg/bg18.png" , 
                     close = { path = "res/component/button/x2.png" , offX = -50 , offY = -25 , callback = function()  end } , 
                     zorder = 200 , 
                     actionType = 8 ,
                    noNewAction = true ,
                   isNoSwallow = false ,
                   })

    createLabel( tempLayer , game.getStrByKey( "bodyguard_team10" )   , cc.p( tempLayer:getContentSize().width/2 , tempLayer:getContentSize().height - 25  ) , cc.p( 0.5 , 0.5 ) , 22 , true , nil , nil  )

    local size = tempLayer:getContentSize()
    createSprite( tempLayer , "res/common/bg/bg18-7.png" , cc.p( size.width/2 + 3 , size.height/2 -20 ), cc.p( 0.5 , 0.5 ))
    local leftBg = createScale9Sprite( tempLayer ,"res/common/scalable/bg4.png" , cc.p( 42 , size.height/2 -20 ) , cc.size( 422 , 437 ) , cc.p( 0 , 0.5 ) )
    local leftSize = leftBg:getContentSize()
    local rightBg = createSprite( tempLayer , "res/common/bg/bg44-4.png" , cc.p( 472 , size.height/2 -20 ), cc.p( 0 , 0.5 ))
    createSprite( rightBg , "res/layers/mission/bodyguard_bg.png" , getCenterPos( rightBg ), cc.p( 0.5 , 0.5 ))

    
    local tempTab = { self:checkPropInfo( self.cardType ) }
    local textCfg = { 
                       { str = game.getStrByKey( "bodyguard_team20" ) .. ":"  , y = 455 , color = MColor.lable_yellow} , 
                       { str = game.getStrByKey( "bodyguard_team21" ) , y = 430 , color = MColor.lable_black  } , 
                       { str = game.getStrByKey( "bodyguard_team22" )  , y = 345 , color = MColor.lable_black } , 
                       { str = game.getStrByKey( "bodyguard_team23" ) .. "\n" .. game.getStrByKey( "bodyguard_team29" ) , y = 315 , color = MColor.red } , 
                       { str = string.format( game.getStrByKey( "bodyguard_team30" ) , "^c(" .. tempTab[3] .. ")" .. game.getStrByKey( "bodyguard_team" .. ( 6 + self.cardType ) ) .. game.getStrByKey( "bodyguard_team18" ) .. "^" )   , y = 180 , color = MColor.lable_black } , 
                       { str = game.getStrByKey( "bodyguard_team31" )  , y = 145 , color = MColor.lable_black } , 
                    }
    for i = 1 , #textCfg do
        if i == 5 then
            local richText = require("src/RichText").new( tempLayer , cc.p( 60  , textCfg[i].y  ) , cc.size( 420 , 22 ) , cc.p( 0 , 1 ) , 20 , 20 , MColor.white )
            richText:setAutoWidth()
            richText:addText( textCfg[i].str , textCfg[i].color , false )
            richText:format()
        else
            local  content = createLabel( tempLayer , textCfg[i].str , cc.p( 60 , textCfg[i].y ) , cc.p( 0 , 1 ) , 20 , nil , nil , nil , textCfg[i].color , nil , nil , MColor.black , 3 )
            content:setDimensions( 420 , 0 )
        end
    end

    local seleNode = cc.Node:create()
    seleNode:setScale( 0.9 )
    setNodeAttr( seleNode , cc.p( leftSize.width/2 + 45 , 255 ) ,  cc.p( 0.5 , 0.5 ) )
    tempLayer:addChild( seleNode )

    createSprite( tempLayer ,"res/common/bg/bg27-4-2.png" , cc.p( leftSize.width/2 + 45 , 255-40 ) ,  cc.p( 0.5 , 0.5 ) )
    createLabel( tempLayer , game.getStrByKey( "bodyguard_team33" ) , cc.p( leftSize.width/2 + 45 , 255-40 ) , cc.p( 0.5 , 0.5 ) , 22 , nil , nil , nil , MColor.lable_yellow , nil , nil , MColor.black , 3 )


    local function createTeamFun( _num )
        local function askFun()
            if self:checkOut() then
                self:askCreateCar( _num , 2  )
                tempLayer:close()
            end
        end

        if G_TEAM_INFO.has_team and G_TEAM_INFO.team_data and G_TEAM_INFO.team_data[1] and G_TEAM_INFO.team_data[1].roleId and userInfo.currRoleStaticId ~= G_TEAM_INFO.team_data[1].roleId then
            MessageBoxYesNo(nil,game.getStrByKey("bodyguard_team38"), askFun , nil , game.getStrByKey("sure"),game.getStrByKey("cancel") )
        else
            askFun()
        end
    end

    local btnCfg = { 3 , 5 , 8 }
    for i = 1 , #btnCfg do
        local tempBtn = createMenuItem( leftBg , "res/component/button/39.png" , cc.p( leftSize.width/3 * i - 70 , 50 ) , function() createTeamFun( btnCfg[i] ) end  )   
        createLabel( tempBtn , string.format( game.getStrByKey( "bodyguard_team12") , btnCfg[i] ) , getCenterPos( tempBtn ) , cc.p( 0.5 , 0.5 ) , 20 , nil , nil , nil , MColor.lable_yellow , nil , nil , MColor.black , 3 )
    end

end


function M:cellSizeForTable(table,idx) 
    return 72 , 324
end



function M:tableCellAtIndex( table , idx )
    local cell = table:dequeueCell()
    local index = idx + 1 

    if cell == nil  then
        cell = cc.TableViewCell:new()
    else
        cell:removeAllChildren()
    end

    local itemData = self.data["teamList"][ index ]
    local isSelfTemp = ( self.data.selfTeamID ~= 0 and  self.data.selfTeamID == itemData.teamID )

    local isLeader = false
    if isSelfTemp then isLeader = ( itemData.teamName == MRoleStruct:getAttr(ROLE_NAME) ) end
    
    local bg = createSprite( cell , "res/fb/multiple/12.png" , cc.p( 0 , 0 ) , cc.p( 0 , 0 ) )


    local size = bg:getContentSize()
    local str = game.getStrByKey( "bodyguard_team26" )  
    if itemData.teamNum < itemData.teamMax then
        str = game.getStrByKey( "bodyguard_team2" ) .. itemData.teamNum .. "/" .. itemData.teamMax 
    end
    
    if self.data.dart_state == 3 then
        game.getStrByKey( "bodyguard_team27" )   
    end

    createLabel( bg , str , cc.p( isSelfTemp and 35 or 15 , size.height/4 )  , cc.p( 0 , 0.5 ) , 18 , true )

    local  joinBtn = nil
    if ( self.data.dart_state == 1 and itemData.teamNum < itemData.teamMax ) or ( self.data.dart_state == 4 and isSelfTemp ) then
        joinBtn = createMenuItem( cell , "res/component/button/48.png" , cc.p( 300 , size.height/2) , function() self:askJoinTeam( itemData , isSelfTemp , isLeader ) end )
    else
        joinBtn = createSprite( cell , "res/component/button/48_gray.png" , cc.p( 300 , size.height/2) , cc.p( 0.5 , 0.5 ) )
    end

    if isSelfTemp then
        --自己的队伍时
        createSprite( bg , "res/component/flag/team.png" , cc.p( 0 , 0 ) , cc.p( 0 , 0 ) )
        createLabel( joinBtn , game.getStrByKey( isLeader and "faction_top_faction_action" or "exit" ) , getCenterPos( joinBtn )  , cc.p( 0.5 , 0.5 ) , 20 , true )        
    else
        createLabel( joinBtn , game.getStrByKey( "fb_joinIn" ) , getCenterPos( joinBtn )  , cc.p( 0.5 , 0.5 ) , 20 , true )
    end


    local str = string.format( game.getStrByKey( "bodyguard_team1" ) , itemData.teamName )
    local richText = require("src/RichText").new( cell , cc.p( isSelfTemp and 35 or 15  , size.height/4*3 - 5 ) , cc.size( size.width , 22 ) , cc.p( 0 , 0.5 ) , 20 , 20 , MColor.white )
    richText:setAutoWidth()
    richText:addText( str , MColor.white , false )
    richText:format()

    return cell
end

function M:numberOfCellsInTableView(table)
    return #self.data["teamList"]
end



function FirendList:ctor( params )
    self.data = {}

    local bg = createSprite( self , "res/common/bg/bg27.png", cc.p( display.cx , display.cy ) , cc.p( 0.5 , 0.5 ) )

	createScale9Sprite(
        bg,
        "res/common/scalable/panel_inside_scale9.png",
        cc.p(201, 468),
        cc.size(372, 450),
        cc.p(0.5, 1)
    )

    local size = bg:getContentSize()
    createLabel( bg , game.getStrByKey( "social_qq_invite" ) , cc.p( size.width/2 , size.height - 25 ) , cc.p( 0.5 , 0.5 ) , 24 , nil , nil , nil , MColor.lable_yellow )
    local func = function() 
        removeFromParent( self ) 
    end
    registerOutsideCloseFunc( bg , func , true )
    local close_btn = createMenuItem( bg , "res/component/button/x2.png", cc.p( size.width - 30 , size.height - 30 ) , func )


    self:createTableView( bg , cc.size( 370 , 445 ),cc.p( 20 , 20 ) , true )
    self:getTableView():setLocalZOrder(125)

    local function showList( buff )
        local t = g_msgHandlerInst:convertBufferToTable( "CopyGetFriendDataRetProtocol", buff )
        self.data = {}
        for i , v in ipairs( t.info ) do
            -- optional int32 friendSid = 1;
            -- optional int32 friendSchool = 2;
            -- optional string friendName = 3;
            -- optional int32 friendLevel = 4;
            -- optional int32 friendBattle = 5;
            -- optional int32 friendSex = 6;
            -- optional int32 remainCD = 7;
            -- optional int32 needIngot = 8;
            -- optional bool isOnline = 9;
            if v.friendLevel >= 36 and v.isOnline == true then
                self.data[ #self.data + 1 ] = v 
            end
        end
        
        if #self.data > 0 then
            table.sort( self.data , function( a , b )  return a.friendLevel> b.friendLevel  end )
            self:getTableView():reloadData()
        else
            createLabel( bg , game.getStrByKey( "bodyguard_team39" )  , getCenterPos( bg ) , cc.p( 0.5 , 0.5 ) , 22 , nil , nil , nil , MColor.white , nil , nil , MColor.black , 2 )            
        end
    end
    g_msgHandlerInst:registerMsgHandler( COPY_SC_GETFRIENDDATARET , showList )
    g_msgHandlerInst:sendNetDataByTableExEx( COPY_CS_GETFRIENDDATA , "CopyGetFriendDataProtocol" , {} )

    self:registerScriptHandler(function(event)
        if event == "enter" then  
            self:scrollViewDidScroll()
        elseif event == "exit" then
            g_msgHandlerInst:registerMsgHandler( COPY_SC_GETFRIENDDATARET , nil )
        end
    end)
    getRunScene():addChild(self,200)
    
end

function FirendList:numberOfCellsInTableView(table)
    return tablenums( self.data )
end

function FirendList:cellSizeForTable(table,idx) 
    return 75 , 370
end

function FirendList:tableCellAtIndex( table , idx )
    local cell = table:dequeueCell()
    local index = idx + 1 
    local curData = {}

    if cell == nil  then
        cell = cc.TableViewCell:new()
    else
        cell:removeAllChildren()
    end
    local itemData = self.data[index]


    local bg = createSprite( cell , "res/fb/multiple/12.png"  , cc.p( 0 , 0 ) , cc.p( 0 , 0 ) )
    local size = bg:getContentSize()


    createLabel( bg , itemData.friendName .. "   (" .. itemData.friendLevel .. game.getStrByKey( "ji" ) .. ")"  , cc.p( 21 , size.height/4*3 ), cc.p(0 , 0.5 ) , 20 , nil , nil , nil , MColor.yellow , nil , nil)
    createLabel( bg , game.getStrByKey( "faction_top_fight" ) .. "：", cc.p( 21 , size.height/4*1 ), cc.p(0 , 0.5 ) , 20 , nil , nil , nil , MColor.lable_yellow , nil , nil)
    createLabel( bg , itemData.friendBattle , cc.p( 100 , size.height/4*1 ), cc.p(0 , 0.5 ) , 20 , nil , nil , nil , MColor.lable_yellow , nil , nil)

    local invitationFun = function( _ , node )
        g_msgHandlerInst:sendNetDataByTableExEx( DART_CS_INVITE_TEAMDART , "DartInviteTeamDartProtocol", { roleSID = itemData.friendSid })
        performWithDelay(node,function() node:setEnabled( false ) end , 0.18)
    end
    local invitaBtn =  createMenuItem( bg, "res/component/button/48.png" ,  cc.p( 300 , size.height/2 ) , invitationFun )
    createLabel( invitaBtn , game.getStrByKey("p3v3_add_member_name_btn_label"), getCenterPos( invitaBtn ), cc.p(0.5, 0.5) , 20  )

    return cell
end


return M