--[[ 定时 活动 ]]--
local M = class("BattleList", require("src/LeftSelectNode") )

function M:ctor( params )
    params = params or {}
    self.selectIdx = params.activityID or 0  --初始化活动默认激活项
    g_msgHandlerInst:sendNetDataByTableExEx( ACTIVITY_NORMAL_CS_FIND_REWARD_LIST , "ActivityNormalFindRewardList", {} ) --请求找回数据
    
    DATA_Battle.BattleLayer = self
    local base_node ,closebtn  = createBgSprite(self,game.getStrByKey( "title_Battle" ))
    self.base_node = base_node

    self.data = self:filterData()

    self:init(params)

    G_TUTO_NODE:setTouchNode( closebtn , TOUCH_BATTLE_CLOSE)

    self:registerScriptHandler(function(event)
        if event == "enter" then  
        elseif event == "exit" then
            if DATA_Battle.BattleLayer then DATA_Battle.BattleLayer = nil end
        end
    end)
end

--数据过滤
function M:filterData()
    local tempData = copyTable( DATA_Battle:getData() )
    local isExistWill = false
    for k1 , v1 in pairs( tempData.tabData ) do
        for k2 , v2 in pairs( v1.celldata ) do
            if v2.errCode == 2 then
                isExistWill = true
            end
        end
    end

    if isExistWill == false then
        table.remove( tempData.tabData , 4 )
    end

    return tempData
end

function M:refreshDataFun()
    self.data = self:filterData()
    self:getTableView():reloadData()
    self:updateRight()
end

function M:init(params)   
    

    --createSprite( self.base_node , "res/common/bg/bg-6.png" , cc.p( 480 , 290 ) )
    createScale9Frame(
        self.base_node,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(33 , 40 ),
        cc.size(110, 330),
        5
    )
    createScale9Frame(
        self.base_node,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(150 , 40 ),
        cc.size(780, 330),
        5
    )
    --createScale9Sprite( self.base_node , "res/common/scalable/panel_inside_scale9.png", cc.p( 33 , 40 ) , cc.size( 110 , 330 ) , cc.p( 0.0 , 0.0 ) )
    --createScale9Sprite( self.base_node , "res/common/scalable/panel_inside_scale9.png", cc.p( 35 + 115 , 40 ) , cc.size( 780 , 330 ) , cc.p( 0.0 , 0.0 ) )

    self.view_node = cc.Node:create()
    setNodeAttr( self.view_node , cc.p( 150 , 24 ) , cc.p( 0 , 0 ) )    
    self.base_node:addChild( self.view_node )

    self.arror_node = cc.Node:create()
    setNodeAttr( self.arror_node , cc.p( 150 , 24 ) , cc.p( 0 , 0 ) )    
    self.base_node:addChild( self.arror_node , 10 )

    DATA_Battle.BattleLayer.__refreshTopFun = self:createTop() 
    self:createLeft()
end

function M:createLeft()

    DATA_Battle.BattleLayer.__refreshRightFun = function() self:updateRight() end
    self.callBackFunc = function(idx)
        --更新右侧界面
        DATA_Battle:setSelectIndex( self.selectIdx + 1 )
        g_msgHandlerInst:sendNetDataByTableExEx( ACTIVITY_NORMAL_CS_REQ , "ActivityNormalReq" , { tab = self.selectIdx + 1 } )
    end
   

    self.normal_img = "res/component/button/43.png"
    self.select_img = "res/component/button/43_sel.png"
    local msize = size or cc.size(120, 320 )
    self:createTableView(self.base_node, msize, cc.p(36, 48), true )
    self.callBackFunc()
    
end

function M:createTop()
    local function setSwallowTouches( bg )
        local  listenner = cc.EventListenerTouchOneByOne:create()
        listenner:setSwallowTouches( true )--遮挡下方点击事件，没有实际用途
        listenner:registerScriptHandler(function(touch, event)   
            local pt = bg:getParent():convertTouchToNodeSpace(touch)
            if cc.rectContainsPoint(bg:getBoundingBox(), pt) then 
                return true
            end
            return false
            end, cc.Handler.EVENT_TOUCH_BEGAN )
        listenner:registerScriptHandler(function(touch, event)
                local start_pos = touch:getStartLocation()
                local now_pos = touch:getLocation()
                local span_pos = cc.p(now_pos.x-start_pos.x,now_pos.y-start_pos.y)
                if math.abs(span_pos.x) < 30 and math.abs(span_pos.y) < 30 then
                    local pt = bg:getParent():convertTouchToNodeSpace(touch)
                    if cc.rectContainsPoint(bg:getBoundingBox(), pt)  then
                    end
                end
            end, cc.Handler.EVENT_TOUCH_ENDED)
        local eventDispatcher = bg:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listenner,bg)

    end
    local child = cc.LayerColor:create( cc.c4b(0, 0, 0, 0) )
    child:setContentSize( cc.size( display.width , 280 ) )
    setNodeAttr( child , cc.p( 0 , display.height - child:getContentSize().height ) , cc.p( 0 , 1 ) )
    self.base_node:addChild( child )
    setSwallowTouches( child )

    local child = cc.LayerColor:create( cc.c4b(0, 0, 0, 0) )
    child:setContentSize( cc.size( display.width , 40 ) )
    setNodeAttr( child , cc.p( 0 , 0 ) , cc.p( 0 , 0 ) )
    self.base_node:addChild( child )
    setSwallowTouches( child )


    local bg = createSprite( self.base_node , "res/layers/battle/top_bg.png" , cc.p( 35 , 380 ) , cc.p( 0 , 0 ) )
    local scoreSp = createSprite( bg , "res/layers/battle/score_bg.png" , cc.p( 25 , 25 ) , cc.p( 0 , 0 ) , 10 )
    createLabel( scoreSp , game.getStrByKey("active_name")  , cc.p( scoreSp:getContentSize().width/2 , 15 ) , cc.p( 0.5 , 0.5 ) , 18 , nil , nil , nil , MColor.yellow )
    local scoreText =  createLabel( scoreSp , 0  , cc.p( scoreSp:getContentSize().width/2 , 60 ) , cc.p( 0.5 , 0.5 ) , 26 , nil , nil , nil , MColor.white )

    --日历
    self:createCalendar( { parent = bg , pos = cc.p( 815 , 100 ) } ) 
    -- --找回
    local yesterdayBtn = createMenuItem( bg , "res/component/button/48.png",cc.p( 815 , 50 ), function() 
    package.loaded[ "src/layers/battle/BackLayer" ] = nil require("src/layers/battle/BackLayer").new() end )
    createLabel( yesterdayBtn , game.getStrByKey("yesterday")  , getCenterPos(yesterdayBtn)  , cc.p( 0.5 , 0.5 ) , 24 , true )
    DATA_Battle.BattleLayer.yesterdayRed = createSprite( yesterdayBtn, "res/component/flag/red.png", cc.p( yesterdayBtn:getContentSize().width , yesterdayBtn:getContentSize().height ), cc.p( 0.5 , 0.5 ))
    local backData = DATA_Battle:getBackData()
    DATA_Battle.BattleLayer.yesterdayRed:setVisible( #backData.list>0 )
    

    local awardBar = createLoadingBar(true,{
            parent = bg ,
            size = cc.size(667,26),
            percentage = 100,
            pos = cc.p( 70, 80 ),
            res = "res/component/progress/yellowBar.png",
            dir  = true, --向右
            anchor = cc.p(0,0.5),
        })
    



    local boxNode = cc.Node:create()
    bg:addChild( boxNode )


    local refreshTopFun = function(  )
        self.data = self:filterData()
        local awardCfg = self.data.boxAward
        if boxNode then boxNode:removeAllChildren() end
        if  tablenums( awardCfg ) == 0 then return end


        local firstMark = awardCfg[ 1 ]["integral"]
        local lasterMark = awardCfg[ #awardCfg ]["integral"]
        awardBar:setPercent( self.data.nowIntegral /lasterMark*100 )
        scoreText:setString(  self.data.nowIntegral  )

        

        local function awardClick( tempData )
            local clickFun = function() 
                -- status 0可领取 1未达成 2已领取
                if tempData.status == 0  then
                    g_msgHandlerInst:sendNetDataByTableExEx( ACTIVITY_NORMAL_CS_ACTIVENESS_REWARD , "ActivityNormalActivenessReward" , { integral = tempData.integral } )
                elseif tempData.status == 1  then
                    TIPS( { type = 1 , str = game.getStrByKey( "awardNoConditions" )  } )
                elseif tempData.status == 2  then
                    TIPS( { type = 1 , str = game.getStrByKey(  "awardGetOver" ) } )
                end
            end


            if tempData.status ~= 0 then
                    local closeBtn1 = function()
                        removeFromParent(self.smallbg)
                        self.smallbg = nil
                    end
                    closeBtn1()
                    self.smallbg = createSprite( self ,"res/common/bg/bg35.png",cc.p( display.cx ,display.cy  ) , nil , 100 )
                    createLabel(self.smallbg,game.getStrByKey("week_boxgift"),cc.p(203,290),nil,22,true,nil,nil,MColor.lable_yellow)
                    registerOutsideCloseFunc(self.smallbg,closeBtn1,true)
                    createTouchItem(self.smallbg,"res/component/button/X.png",cc.p(375,290),closeBtn1)

                    local iconGroup = __createAwardGroup( tempData.awards ,nil,nil,nil,false )
                    setNodeAttr( iconGroup , cc.p( self.smallbg:getContentSize().width/2 , 170 ) , cc.p( 0.5 , 0.5 ) )
                    self.smallbg:addChild( iconGroup )
                    local sureBtn = createMenuItem(self.smallbg,"res/component/button/2.png" ,cc.p( 203 , 50 ) , closeBtn1  )
                    createLabel( sureBtn , game.getStrByKey( "sure" )  ,getCenterPos( sureBtn ) , cc.p( 0.5 , 0.5 ) , 22 , true , nil , nil , MColor.yellow_gray , 3 , nil , MColor.black , 3 )
            else
                local tempTab = { 
                                    award_tip = string.format( game.getStrByKey("day_get_rawards") , tempData.integral ) , 
                                    isGet = tempData.status == 0  , 
                                    awards = tempData.awards ,
                                    getCallBack = clickFun ,
                                }

                local tempLayer , closeBtn , getBtn = Awards_Panel( tempTab )
            end



        end

        local spCfg = { "boxUnable1" , "boxUnable1" , "unpassed_box1" , "unpassed_box1" ,  "boxCan1" }
        local effCfg = { "copper" , "copper" , "silver" , "silver" ,  "gold" }
        local textColorCfg = { MColor.lable_yellow  , MColor.green , MColor.red  }
        

        local boxEffs = {}
        for i, v in ipairs( awardCfg ) do
            local x = (v.integral/lasterMark)*awardBar:getContentSize().width + 50
            local boxBtn = nil 
            boxBtn = createMenuItem( boxNode , "res/fb/defense/" .. ( i> #spCfg and spCfg[5] or spCfg[i] ) .. ( v.status == 2 and "_cmp"  or "" ) .. ".png" , cc.p( x , 100 ) , function() awardClick( v )  end )
            boxBtn:setScale( 0.8 )
            boxEffs[i] = cc.Node:create()
            setNodeAttr( boxEffs[i] , cc.p( boxBtn:getContentSize().width/2 , boxBtn:getContentSize().height/2 ) , cc.p( 0.5 , 0.5 ) )
            boxBtn:addChild( boxEffs[i] )      
            if i == 1 then
                G_TUTO_NODE:setTouchNode(boxBtn, TOUCH_BATTLE_PRIZE)
            end

            local mc = MColor.yellow
            if v.state == 2 then
                createSprite(boxBtn, "res/component/flag/18.png" , cc.p(boxBtn:getContentSize().width/2 +  20, 40) ,cc.p( 0.5 , 0.5 ), 20)       
                mc = MColor.lable_black
            end

            createLabel( bg , v.integral  , cc.p( x + 10 , 120 - 77 ) , cc.p( 0.5 , 0.5 ) , 20 , false , nil , nil , mc , nil , nil  , MColor.black , 3)

            local eff = Effects:create(false)
            eff:playActionData( effCfg[i] , 10 , 2 , -1 )
            boxEffs[i]:addChild( eff )
           
            boxEffs[i]:setVisible( v.status == 0 )
            addEffectWithMode(eff,1)
        end

    end
    refreshTopFun()

    return refreshTopFun
end

--收集即将标签数据（等级不足)
function M:gatherWillData()
    local tempData = self:filterData()
    tempData = tempData.tabData
    local role_level = MRoleStruct:getAttr(ROLE_LEVEL)
    for k1 , v1 in pairs( tempData ) do
        if k1 ~= 4 then
            local keys = {}
            for k2 , v2 in ipairs( v1.celldata ) do
                if v2.errCode and v2.errCode == 2 and v2.arg > role_level then
                    table.insert( keys , 1 , k2 )
                end
            end
            for k2 , v2 in ipairs( keys ) do
                local tag = table.remove( v1.celldata , v2 )
                if tag then
                    local isExist = false
                    for k3 , v3 in ipairs( tempData[4].celldata ) do
                        if tag.q_id == v3.q_id then
                            isExist = true
                            tempData[4].celldata[ k3 ] = tag
                        end
                    end
                    if isExist == false then
                         table.insert( tempData[4].celldata , tag )
                    end
                end
            end
        end
    end

    table.sort( tempData[4].celldata , function( a , b ) if a.arg and b.arg then return a.arg < b.arg else return false end end )

    return tempData[4].celldata
end
function M:updateRight() 
    if self.view_node then self.view_node:removeAllChildren()  end --清除可视内容
    local curData = nil

    if self.selectIdx == 3 then
        curData = self:gatherWillData()
    else
        curData = DATA_Battle:getCellData( self.selectIdx + 1 ) 
        curData = copyTable( curData.celldata )

        local keys = {}
        for k , v in pairs( curData ) do
            if v.errCode == 2 then
                table.insert( keys , 1 , k )
            end
        end
        for k , v in ipairs( keys ) do
            table.remove( curData , v )
        end

        

     --    table.sort( curData, function( a , b ) 
     --    	local aScore = ( a.time_num or 0 )/a.q_times
     --    	local bScore = ( b.time_num or 0 )/b.q_times
     --    	local resultBool = a.q_id < b.q_id
     --    	if bScore > aScore  then resultBool = true end
     --    	return resultBool
    	-- end )

        -- for k , v in ipairs( curData ) do
        --     local aScore = ( v.time_num or 0 )/v.q_times
        --     for k1 , v1 in ipairs( curData ) do
        --         local resultBool =  false
        --         local bScore = ( v1.time_num or 0 )/v1.q_times
        --         if bScore > aScore  then resultBool = true end
        --         if resultBool == true then
        --             local a = curData[k]
        --             curData[k] = curData[k1]
        --             curData[k1] = a
        --         end
        --     end
        -- end
        --排序方法调整
        local maxNum=#curData       
        for i=1,maxNum do
            for j=1,maxNum-i do
                local aScore = ( curData[j].time_num or 0 )/curData[j].q_times
                local bScore = ( curData[j+1].time_num or 0 )/curData[j+1].q_times
                if bScore < aScore then
                    local a = curData[j]
                    curData[j] = curData[j+1]
                    curData[j+1] = a
                end
            end
        end

    end


    if not curData then return end
    local width , height = 780 , 320 
    local function createLayout()
        local node = cc.Node:create()
        local num = #curData
        local totalHeight = math.ceil(num/2) *105 
        node:setContentSize( cc.size( width , totalHeight ) )
        local  function clickFun( itemData , bgBtn)

            if itemData.q_time or itemData.q_id == 21 then
                --有时间限制的活动，点击就不显示红点
                itemData.redState = false
                if bgBtn and bgBtn.redSp then bgBtn.redSp:setVisible( false ) end
                if itemData.q_tab == 2 then DATA_Battle:setRedData( itemData.q_id , false ) end

                local isRed = false 
                local tempCurData = DATA_Battle:getCellData( itemData.q_tab ) 
                for k ,v in pairs( tempCurData.celldata ) do
                    if v.redState == true then
                        isRed = true
                        break
                    end
                end
                self[ "TableRed" .. itemData.q_tab ]:setVisible( isRed )

                DATA_Battle:countRedNum()
            end

            if ( itemData.errCode == 3 or itemData.errCode == 4 ) and itemData.q_tab == 4 then
                if itemData.errCode == 4 then
                    TIPS( { type=1 , str = game.getStrByKey("faction_level") .. itemData.arg ..  game.getStrByKey("ji") .. game.getStrByKey("goto_activity_now1" ) } )
                else
                    TIPS( { type=1 , str = game.getStrByKey("join_faction_tips") } )
                end
                return
            end

            if itemData.isDesc and itemData.isDesc == 1 then
                package.loaded[ "src/layers/battle/DescLayer" ] = nil
                require( "src/layers/battle/DescLayer" ).new( itemData )
            else
                __GotoTarget( {ru =  itemData.q_go } )
            end
        end
        local tempNode = cc.Node:create()
        setNodeAttr( tempNode , cc.p( 0 , totalHeight ) , cc.p( 0 , 0 ) )
        node:addChild( tempNode )
        for i = 1 , num do
            local itemData = curData[i]
            local addrX , addrY = ( (i-1) %2 ) * 388 , -105 - math.floor( ( i - 1 )/2) *105
            local bgBtn = createSprite( tempNode , "res/layers/battle/bg_frame.png" , cc.p( addrX , addrY ) , cc.p( 0 , 0 ) )

            -- local bgBtn = createScale9SpriteMenu( tempNode , "res/common/scalable/item.png", cc.size( 385 , 100 ) , cc.p( addrX + 385/2, addrY + 50 )  , function() __GotoTarget( {ru =  itemData.q_go } ) end);
            local  listenner = cc.EventListenerTouchOneByOne:create()
            listenner:setSwallowTouches( false )
            listenner:registerScriptHandler(function(touch, event)   
                local pt = bgBtn:getParent():convertTouchToNodeSpace(touch)
                if cc.rectContainsPoint(bgBtn:getBoundingBox(), pt) then 
                    return true
                end
                return false
                end, cc.Handler.EVENT_TOUCH_BEGAN )
            listenner:registerScriptHandler(function(touch, event)
                    local start_pos = touch:getStartLocation()
                    local now_pos = touch:getLocation()
                    local span_pos = cc.p(now_pos.x-start_pos.x,now_pos.y-start_pos.y)
                    if math.abs(span_pos.x) < 30 and math.abs(span_pos.y) < 30 then
                        local pt = bgBtn:getParent():convertTouchToNodeSpace(touch)
                        if cc.rectContainsPoint(bgBtn:getBoundingBox(), pt) then
                            clickFun( itemData , event:getCurrentTarget() )
                        end
                    end
                end, cc.Handler.EVENT_TOUCH_ENDED)
            local eventDispatcher = bgBtn:getEventDispatcher()
            eventDispatcher:addEventListenerWithSceneGraphPriority(listenner,bgBtn)



            
            
            local size = bgBtn:getContentSize()
            
            local q_times = itemData.q_times
            local addY = q_times and q_times ~= 0 and ( size.height/4*3) or  size.height/2 
            if self.selectIdx ~= 0 then
                addY = size.height/2 
            end

            if itemData.q_time and self.selectIdx ~= 0 and  itemData.errCode == 0 then
                addY = size.height/4*3 - 10
                createLabel( bgBtn , game.getStrByKey("battle_tip2") , cc.p( 100 , size.height/4 + 10 ) , cc.p( 0 , 0.5), 22, true, nil, nil, MColor.yellow )
            end

            createLabel( bgBtn , itemData["q_name"] , cc.p( 100 , addY ) , cc.p(0, 0.5), 22, true, nil, nil, MColor.lable_yellow )

            if q_times and q_times ~= 0 and self.selectIdx == 0 then
                local str = ( itemData.time_num or 0 ).. "/" .. itemData.q_times
                local isComplete = false
                if ( itemData.time_num or 0 ) == itemData.q_times then
                    str = game.getStrByKey( "achievement_finish" )
                    isComplete = true
                end
                createLabel( bgBtn , game.getStrByKey( itemData.q_time_type == 1 and "active_txt" or "fast_num" ) .. "：" , cc.p( 100 , size.height/4*2 ) , cc.p(0, 0.5), 18, true, nil, nil, MColor.lable_black )
                createLabel( bgBtn , str , cc.p( 155 , size.height/4*2 ) , cc.p(0, 0.5), 18, true, nil, nil, ( isComplete and MColor.green or MColor.white ) )

                local str = ( itemData.q_integral/itemData.q_times * ( itemData.time_num or 0 ) )..  "/" .. itemData.q_integral 
                if itemData.q_time_type == 1 then
                    if isComplete then
                        str = itemData.q_integral  ..  "/" .. itemData.q_integral 
                    else
                        str = "0" ..  "/" .. itemData.q_integral 
                    end
                end

                createLabel( bgBtn , game.getStrByKey( "battle_txt1" )  .. "：" , cc.p( 100 , size.height/4*1 ) , cc.p(0, 0.5), 18, true, nil, nil, MColor.lable_black )
                createLabel( bgBtn , str , cc.p( 155 , size.height/4*1 ) , cc.p(0, 0.5) , 18 , true , nil , nil , ( isComplete and MColor.green or MColor.white )  )
            end

            local isBind = true
            if itemData.q_bind then
                isBind = itemData.q_bind == 1
            end
            
            local icon = iconCell( {parent = bgBtn , isTip = true , iconID = ( itemData.q_showid or 1001 ) , showBind = true , isBind = isBind , } )
            setNodeAttr( icon , cc.p( 50 , size.height/2 ) , cc.p( 0.5 , 0.5 ) )

            if itemData.q_high and itemData.q_high == 1 then
                createSprite(bgBtn, "res/component/flag/16.png", cc.p( 0 , bgBtn:getContentSize().height) , cc.p( 0 , 1 ) )        
            end
            
            if itemData.errCode == 0 then
                local getBtn = createMenuItem( bgBtn , "res/component/button/48.png" ,  cc.p( 307 , size.height/2 ) , function() clickFun(itemData )  end )
                createLabel( getBtn , game.getStrByKey("join_str") ,   getCenterPos( getBtn )  , cc.p( 0.5 , 0.5 ) , 22 , true )

	            bgBtn.redSp = createSprite( getBtn, "res/component/flag/red.png", cc.p(getBtn:getContentSize().width - 5 , getBtn:getContentSize().height - 5 ), cc.p( 0.5 , 0.5 ))
	            bgBtn.redSp:setVisible( itemData.redState )

                -- createLabel( bgBtn , game.getStrByKey("goto_activity_now1") ,   cc.p( 290 , size.height/2 )  , cc.p( 0.5 , 0.5 ) , 22 , true )
                -- if itemData.q_key and itemData.q_key == "TLCS" then
                --     G_TUTO_NODE:setTouchNode(getBtn, TOUCH_BATTLE_INSTANCE)
                -- end
                -- if itemData.q_key and itemData.q_key == "TTT" then
                --     G_TUTO_NODE:setTouchNode(getBtn, TOUCH_BATTLE_TOWER)
                -- end
            elseif itemData.errCode == 1 then
                --活动未开启
                local timeTab = os.date( "*t" , itemData.arg )
               
                local timeLabel = createLabel( bgBtn , game.getStrByKey( "open_time_ch" )  , cc.p( 290 + 20  , size.height/2 ) , cc.p(0.5, 0) , 22 , true , nil , nil , MColor.lable_yellow )
                if itemData.q_key and itemData.q_key == "skyArena" then
                    G_TUTO_NODE:setTouchNode(timeLabel, TOUCH_BATTLE_BATTLE)
                end

                -- if itemData.q_key and itemData.q_key == "TLCS" then
                --     G_TUTO_NODE:setTouchNode(timeLabel, TOUCH_BATTLE_INSTANCE)
                -- end

                -- if itemData.q_key and itemData.q_key == "TTT" then
                --     G_TUTO_NODE:setTouchNode(timeLabel, TOUCH_BATTLE_TOWER)
                -- end

                local str = ""
                if itemData.q_tab == 3 and ( itemData.q_activity_id == 6 or itemData.q_activity_id == 7 or itemData.q_activity_id == 8 ) then
                    str = game.getStrByKey( "faction_bossTime3" ).. game.getStrByKey( "week_" .. os.date( "%w" , itemData.arg ) )  .. "  "  
                end

                str = str .. (  timeTab.hour < 10 and ( "0" .. timeTab.hour ) or timeTab.hour  ) .. "：" .. ( timeTab.min < 10 and ( "0" .. timeTab.min ) or timeTab.min  )
                if itemData.q_key and itemData.q_key == 'WorldBoss' then
                    --世界Boss特殊处理
                    local localTime = os.date( "*t" , os.time() )
                    if localTime.hour >= 21 then
                        str = game.getStrByKey( "master_time_str_9" ) .. str 
                    end
                end

                createLabel( bgBtn , str , cc.p( 290 + 20 , size.height/2 ) , cc.p(0.5, 1) , 22 , true , nil , nil , MColor.white )

            elseif itemData.errCode == 2 then
                -- 等级不足
                createLabel( bgBtn , itemData.arg .. game.getStrByKey( "level_open" )  , cc.p( 290 , size.height/2 ) , cc.p(0.5, 0.5) , 22 , true , nil , nil , MColor.red )
            elseif itemData.errCode == 3 then
                -- 没有行会
                createLabel( bgBtn , game.getStrByKey( "battle_tip1" )  , cc.p( 290 , size.height/2 ) , cc.p(0.5, 0.5) , 22 , true , nil , nil , MColor.red )
            elseif itemData.errCode == 4 then
                -- 行会等级不足
                createLabel( bgBtn , string.format( game.getStrByKey( "faction_level_title" ) , itemData.arg ) .. game.getStrByKey( "set_open" ) , cc.p( 290 , size.height/2 ) , cc.p(0.5, 0.5) , 22 , true , nil , nil , MColor.red )
            end

            if itemData.q_key and itemData.q_key == "TLCS" then
                G_TUTO_NODE:setTouchNode(bgBtn, TOUCH_BATTLE_INSTANCE)
            end

            if itemData.q_key and itemData.q_key == "TTT" then
                G_TUTO_NODE:setTouchNode(bgBtn, TOUCH_BATTLE_TOWER)
            end

            if itemData.q_key and itemData.q_key == "skyArena" then
                G_TUTO_NODE:setTouchNode(bgBtn, TOUCH_BATTLE_BATTLE)
            end


        end

        G_TUTO_NODE:setShowNode(self, SHOW_BATTLE)

        return node
    end

    if self.arror_node then self.arror_node:removeAllChildren() end
    local topFlag = Effects:create(false)
    topFlag:playActionData2("ActivePage", 200 , -1 , 0 )
    setNodeAttr( topFlag , cc.p( width/2 , height+ 35 ) , cc.p( 0.5 , 0.5 ) )
    addEffectWithMode( topFlag , 1 )
    self.arror_node:addChild( topFlag , 10  )
    topFlag:setRotation(180)

    local bottomFlag = Effects:create(false)
    bottomFlag:playActionData2("ActivePage", 200 , -1 , 0 )
    setNodeAttr( bottomFlag , cc.p( width/2 , 5 ) , cc.p( 0.5 , 0.5 ) )
    addEffectWithMode( bottomFlag , 1 )
    self.arror_node:addChild( bottomFlag , 10  )
    -- bottomFlag:setRotation(-90)
    self.arror_node:setVisible( false )
    
    local setFlagShow = function( value )        
        --value 1在顶端显示向下标记 2在中间上下都显示 3在底端显示上标记 4上下两个都不显示
        if value == 4 then
            topFlag:setVisible( false )
            bottomFlag:setVisible( false )
        else
            topFlag:setVisible( value~=1 )
            bottomFlag:setVisible( value~=3 )
        end
    end

    local scrollView1 = cc.ScrollView:create()
    local layerSize = nil
    local function scrollView1DidScroll() 
        if layerSize.height <= height then
            setFlagShow(4)
        else
            if scrollView1:getContentOffset().y == scrollView1:maxContainerOffset().y then 
                setFlagShow(3) 
            elseif scrollView1:getContentOffset().y == scrollView1:minContainerOffset().y then 
                setFlagShow(1)
            else
                setFlagShow(2)
            end 
        end
    end
    local function scrollView1DidZoom()  end
    scrollView1:setViewSize(cc.size( width , height ))
    scrollView1:setPosition( cc.p( 4 , 20 ) )
    scrollView1:setScale(1.0)
    scrollView1:ignoreAnchorPointForPosition(true)
    scrollView1:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL )
    local layer = createLayout()
    scrollView1:setContainer( layer )
    scrollView1:updateInset()
    scrollView1:addSlider("res/common/slider.png")
    scrollView1:setClippingToBounds(true)
    scrollView1:setBounceable(true)
    scrollView1:setDelegate()
    scrollView1:registerScriptHandler(scrollView1DidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL)
    scrollView1:registerScriptHandler(scrollView1DidZoom,cc.SCROLLVIEW_SCRIPT_ZOOM)
    self.view_node:addChild(scrollView1)
    layerSize = layer:getContentSize()
    scrollView1:setContentOffset( cc.p( 0 ,  height - layerSize.height ) )

    local delayFun = function()
        self.arror_node:setVisible( true )
        if layerSize.height > height then
            setFlagShow(1)
        else
            setFlagShow(4)
        end
    end
    performWithDelay( topFlag , delayFun , 0.1 )
end

function M:tableCellAtIndex( table , idx )
    local cell = table:dequeueCell()
    local index = idx + 1 
    if nil == cell then
        cell = cc.TableViewCell:new()   
    else
        cell:removeAllChildren()
    end

    local button = createSprite(cell, self.normal_img, cc.p(0, 0), cc.p(0, 0))
    if button then
        local size = button:getContentSize()
        button:setTag(10)
        if idx == self.selectIdx then
            button:setTexture(self.select_img)
            local arrow = createSprite(button, "res/group/arrows/9.png", cc.p(size.width, size.height/2), cc.p(0, 0.5))
            arrow:setTag(20)
        end
        local itemData = self.data.tabData[index]
        if itemData and itemData.name then
            createLabel(button, itemData.name, getCenterPos(button),cc.p(0.5, 0.5), 22, true, nil, nil )
        end

        local cell_red = createSprite(button, "res/component/flag/red.png", cc.p(size.width  , size.height  ), cc.p( 1 , 1 ))
        self[ "TableRed" .. index ] = cell_red

        if cell_red then
            local show = not not DATA_Battle:getRedData( index )
            cell_red:setVisible( show )
        end
    end
    

    if index == 1 then
        G_TUTO_NODE:setTouchNode(button, TOUCH_BATTLE_HONOR)
    end
    if index == 2 then
        G_TUTO_NODE:setTouchNode(button, TOUCH_BATTLE_TIME)     
    end
    if index == 3 then
        G_TUTO_NODE:setTouchNode(button, TOUCH_BATTLE_FIGHT)
    end

    return cell
end

function M:numberOfCellsInTableView(table)
    return tablenums( self.data.tabData )
end

function M:getBaseNode()
    return self.base_node
end

function M:createBar()

    local node =  cc.Node:create()
    local bg = createSprite( node , "res/component/progress/active1.png" , cc.p( 0 , 0 ) , cc.p( 0 , 0 ) )
    local bgSize = bg:getContentSize()
    local energyFront = cc.ProgressTimer:create( cc.Sprite:create( "res/component/progress/active2.png") )

    energyFront:setType( cc.PROGRESS_TIMER_TYPE_BAR )
    energyFront:setBarChangeRate( cc.p( 1 , 0 ) )
    energyFront:setMidpoint( cc.p( 0 , 1 ) )
    energyFront:setPercentage( 0  )
    node:addChild( energyFront )

    setNodeAttr( energyFront , cc.p( 0 , bgSize.height/2 ) , cc.p( 0 , 0.5 ) )
    node:setContentSize( bgSize )

    --刷新信息
    function node:setData( value )
        if value then energyFront:setPercentage( value ) end
    end
    node:setContentSize( bg:getContentSize() )
    return node
end

--日历界面
function M:createCalendar( params )
    --do return end
    local parent = params.parent
    local pos = params.pos
    local function showActivLayer()

        -- get server data
        local ldWday = 0 -- lingdi
        local zzWday = 0 -- zhongzhou
        local scWday = 0 -- shacheng
        local dataTabs = nil

        local base_node = popupBox({
                         bg = "res/common/bg/bg18.png" , 
                         close = { path = "res/component/button/x2.png" , offX = -42 , offY = -30 , callback = function() end } ,
                         zorder = 200 ,
                         isNoSwallow = false , 
                         isHalf = true , 
                         actionType = 7 ,
                       })

        createLabel(base_node,game.getStrByKey("activity_time_name") ,cc.p(425,500), cc.p(0.5,0.5), 24, true, nil,nil , MColor.lable_yellow )
        --local contentBg = createSprite(base_node,"res/common/bg/bg18-7.png",cc.p(34,18),cc.p(0,0))
        local contentBg = createScale9Frame(
            base_node,
            "res/common/scalable/panel_outer_base_1.png",
            "res/common/scalable/panel_outer_frame_scale9_1.png",
            cc.p(34,18),
            cc.size(790,454),
            4
        )

        local titleLab = createSprite(contentBg,"res/common/bg/scrollbg.png",cc.p(6,365),cc.p(0,0))

        local function getWeekDayOfToday()
            local wd = tonumber( os.date("%w") )
            if wd == 0 then
                return 7
            end
            return wd
        end

        createSprite(titleLab,"res/common/bg/curactiviBg.png",cc.p( 66 + getWeekDayOfToday() * 95  ,42),cc.p(0.5,0.5))
        for i = 1 , 8 do
            local str = game.getStrByKey( i == 1 and "open_time_ch" or ( "day" .. ( i - 1 ) .. "_name_ch" ) )
            local tmpDis = (i==1 and -11 or 0 ) 
            createLabel( titleLab , str  , cc.p( 66 + ( i - 1 ) * 95 + tmpDis , 40 ) , cc.p( 0.5 , 0.5 ) , 22 , true , nil , nil , MColor.name_gray )
        end


        local rowPosSwitch = {
            [1] = function() return cc.p(160,40) end,
            [2] = function() return cc.p(255,40) end,
            [3] = function() return cc.p(350,40) end,
            [4] = function() return cc.p(445,40) end,
            [5] = function() return cc.p(540,40) end,
            [6] = function() return cc.p(635,40) end,
            [7] = function() return cc.p(730,40) end
        }
        local function isCurTimeInActiviTime(activiTimeId)
            if activiTimeId == 1 then
                return true
            end
            local hour = tonumber(os.date("%H")) 
            local minitues = tonumber(os.date("%M")) 
            if activiTimeId == 2 and hour >= 10 and hour < 22 then
                -- 10:00 - 22:00
                return true
            end
            if activiTimeId == 3 and hour >= 19 and hour < 20 then
                -- 19:00 - 20:00
                return true
            end
            if activiTimeId == 4 and hour == 20 and minitues < 40 and minitues > 30 then
                -- 20:30 - 20:40
                return true
            end
            return false
        end
        local function createLayout()
            local node = cc.Node:create()
            -- local timeCfg = getConfigItemByKey("activiTab","id")
            -- for j , v in ipairs( timeCfg ) do
            --     local itemBg  = createSprite(node,"res/common/bg/scrollbg.png",cc.p( 4 , 275 -( j-1 )*90) , cc.p( 0 , 0  ) )
            --     createLabel( itemBg , v.openTime  , cc.p( 66 , 40 ) , cc.p( 0.5 , 0.5 ) , 22 , true , nil , nil , MColor.name_gray )

            --     for i = 1 , 7 do
            --         local dayData = stringsplit( v[ "Day"..( i - 1 ) ] , ";" )
            --         for _ , s in ipairs( dayData ) do
            --             local activiItem = getConfigItemByKey( "activi" , "id" , tonumber( s ) ) 
            --             if activiItem then
            --                 local text = createLabel( itemBg , str  , cc.p( 161 + ( i - 1 ) * 95 , 83/(2*#dayData) * (i*2-1) ) , cc.p( 0.5 , 0.5 ) , 22 , true , nil , nil , MColor.name_gray )
            --                 addTouchEventListen( text ,function() __GotoTarget( { ru = activiItem.q_go } ) end)
            --             end
            --         end
            --     end
            -- end
            local curLableData = getConfigItemByKey("activiTab","id")

            local oriPos = cc.p(-50,300)
            local lineNum = 1
            local fontSize = 20
            local anchorPoint = cc.p(0.5,0.5)
            local disX = 110
            local disY = 50
            local activi19_20 = 3
            local labelDataIndex = 0
            for k,v in pairs(curLableData) do
                   labelDataIndex = labelDataIndex + 1
                   local scrollContentLab = createSprite(node,"res/common/bg/scrollbg.png",cc.p(4,275-(lineNum-1)*90),cc.p(0,0))
                   local pos = cc.p(55,40)
                   local label = createLabel(scrollContentLab, v.openTime, pos,anchorPoint, fontSize, true, nil, nil, MColor.drop_white)
                   for i=1,7 do
                      local dayData = stringsplit(v["Day"..i],";")
                      if #dayData == 1 and dayData[1] == "0" then
                          dayData = {}
                      end
                      if labelDataIndex == activi19_20 then
                          --[[
                          if ldWday == i then
                            dayData = addStrToTabIfNotExist(dayData,"6")
                          elseif zzWday == i then
                            dayData = addStrToTabIfNotExist(dayData,"7")
                          elseif scWday == i then
                            dayData = addStrToTabIfNotExist(dayData,"8")
                          end
                          ]]
                          
                          for k,v in pairs(dataTabs) do
                              if v == -1 or v > i then
                                  delStrFromTabIfExist(dayData,k .. "")
                              end
                              
                          end
                      end
                      local ii = 1
                      for kk,vv in pairs(dayData) do
                            local curBattleData = getConfigItemByKey("activi","id",tonumber(vv))
                            if not curBattleData then break end
                            --local curLabelData = DATA_Battle:getCellData( curBattleData.type )
                            --local finalData = nil
                            --for _ , itemData in pairs( curLabelData.celldata ) do
                            --    if itemData.q_mark == curBattleData.mark_id then finalData = itemData end
                            --end
                            local finalData = DATA_Battle:getCellDataFromAllData(curBattleData.mark_id)
                            if  finalData then
                                local name = curBattleData.name
                                local finalCallBack = function()
                                        if finalData.isDesc and finalData.isDesc == 1 then
                                            package.loaded[ "src/layers/battle/DescLayer" ] = nil
                                            require( "src/layers/battle/DescLayer" ).new( finalData )
                                        else
                                            __GotoTarget( { ru = finalData.q_go } )  
                                        end 
                                    end
                                local tmpPos = rowPosSwitch[i]()
                                if #dayData == 1 then
                                    pos = tmpPos
                                elseif ii == 1 then
                                    pos = cc.p(tmpPos.x,tmpPos.y+20) 
                                elseif ii == 2 then
                                    pos = cc.p(tmpPos.x,tmpPos.y-20) 
                                end

                                if getWeekDayOfToday() == i and isCurTimeInActiviTime(v.id) and ii == 1 then
                                    createSprite(scrollContentLab,"res/common/bg/curactiviBg.png",cc.p(tmpPos.x+1,tmpPos.y+2),cc.p(0.5,0.5))
                                end

                                local activiLabel = createLabel(scrollContentLab, name, pos,anchorPoint, fontSize, true, nil, nil, MColor.lable_black) 
                                addTouchEventListen(activiLabel,finalCallBack)
                            end
                          ii = ii + 1
                      end
                   end
                   lineNum = lineNum + 1
            end
            node:setContentSize(cc.size(800,360))
            return node
        end
        local scrollView1 = cc.ScrollView:create()    
        scrollView1:setViewSize(cc.size( 800  , 360 ) )
        scrollView1:setPosition( cc.p( 36 , 20  ) )
        scrollView1:ignoreAnchorPointForPosition(true)
        base_node:addChild(scrollView1)

        local function getWeekDayofTime(time)
            if time <= 0 then
                return 0
            end
            local tempD = os.date("*t",time)
            local wd = tempD.wday
            if wd == 1 then
                wd = 7 
            else
                wd = wd - 1
            end
            return wd
        end
        local function calendarInfo(luaBuffer)
            local retTable = g_msgHandlerInst:convertBufferToTable("ActivityNormalCalendarRet", luaBuffer)
            --ldWday = getWeekDayofTime( retTable.time1 and retTable.time1 or 0 )
            --zzWday = getWeekDayofTime( retTable.time2 and retTable.time2 or 0 )
            --scWday = getWeekDayofTime( retTable.time3 and retTable.time3 or 0 )

            dataTabs = {}
            dataTabs[6] = -1        -- -1 not shown 0 all show >0 part show
            dataTabs[7] = -1
            dataTabs[8] = -1
            if retTable.show1 then
                dataTabs[6] = retTable.week1
            end
            if retTable.show2 then
                dataTabs[7] = retTable.week2
            end
            if retTable.show3 then
                dataTabs[8] = retTable.week3
            end

            -- create content layer
            local layer = createLayout()
            scrollView1:setContainer( layer )
            scrollView1:setContentOffset(cc.p(0,360-layer:getContentSize().height)) 
            scrollView1:updateInset()
            scrollView1:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL )
            scrollView1:setClippingToBounds(true)
            scrollView1:setBounceable(true)
            scrollView1:setDelegate()
        end

        g_msgHandlerInst:sendNetDataByTableExEx(ACTIVITY_NORMAL_CS_CALENDAR, "ActivityNormalCalendar", {})
        g_msgHandlerInst:registerMsgHandler( ACTIVITY_NORMAL_SC_CALENDAR_RET , calendarInfo )

    end
    local tempBtn = createMenuItem( parent , "res/component/button/48.png",cc.p(pos.x,pos.y+10), showActivLayer)
    createLabel( tempBtn , game.getStrByKey("check_activity_time")  , getCenterPos(tempBtn)  , cc.p( 0.5 , 0.5 ) , 24 , true )

    return tempBtn
end

--日常提醒面板
function M:showBattleChat( itemData )    
	if itemData == nil then return end --异常数据直接返回
    if getRunScene():getChildByName("npcChat") then return end  --面板存在就不展示

    local npcPanel = cc.Layer:create()
    npcPanel:setName("npcChat")
    
    
    local bg = createSprite(npcPanel,  "res/layers/mission/npcLittle.png", cc.p(display.width/2, display.height/2 - 10), cc.p(0.5, 0.5))
    local bgSize = bg:getContentSize()
    createLabel(bg, itemData.q_name or "" , cc.p( bgSize.width/2 , bgSize.height - 22 ), cc.p( 0.5 , 0.5 ), 24 , true, nil, nil, MColor.yellow)

    local nWidthLeftOff = -30
    local constantWidth = 540
    local str = string.format( game.getStrByKey( "rcwf1" ) , MRoleStruct:getAttr(ROLE_NAME) , ( itemData.q_name or "" ) )
    createSprite(bg, "res/mainui/npc_big_head/0.png", cc.p( 80 , 10 ) , cc.p( 0.5 , 0 ) , nil , 0.75 )

    local richText = require("src/RichText").new( bg , cc.p( 190 - nWidthLeftOff, 150 + 90 ) , cc.size( constantWidth, 0 ) , cc.p( 0 , 1 ) , 22 , 20 , MColor.lable_yellow )
    richText:setAutoWidth()
    richText:addText( str, MColor.lable_black , true )
    richText:format()

    local closeLayer = function()
        if npcPanel then 
            removeFromParent(npcPanel)
        end
        npcPanel = nil
    end

    registerOutsideCloseFunc( bg , closeLayer , true , false ) 

    if itemData.q_showid then
        --奖励
        createLabel( bg , game.getStrByKey( "award") , cc.p( 190 + 30 , 115 ) , cc.p( 0 , 0) , 22 , true, nil, nil, MColor.lable_yellow )
        local isBind = true
        if itemData.q_bind then
            isBind = itemData.q_bind == 1
        end
        local icon = iconCell( { parent = bg , isTip = true , iconID = ( itemData.q_showid or 1001 ) , showBind = true , isBind = isBind , } )
        setNodeAttr( icon , cc.p( 230  , 30 ) , cc.p( 0 , 0 ) )
    end


    local str = game.getStrByKey( itemData.q_time_type == 1 and "active_txt" or "fast_num" ) .. "："
    str = str .. "^c(white)" .. ( itemData.time_num or 0 ).. "/" .. itemData.q_times .. "^"
    str = str .. "　　"
    str = str .. game.getStrByKey( "battle_txt1" )  .. "："
    local integralStr = ""
    if itemData.q_time_type == 1 then
        if itemData.q_integral == itemData.q_times then
            integralStr = itemData.q_integral  ..  "/" .. itemData.q_integral 
        else
            integralStr = "0" ..  "/" .. itemData.q_integral 
        end
    else
        integralStr = ( itemData.q_integral/itemData.q_times * ( itemData.time_num or 0 ) )..  "/" .. itemData.q_integral 
    end
    str = str .. "^c(white)" .. integralStr .. "^"

    local richText = require("src/RichText").new( bg , cc.p( 320 , 75 ) , cc.size( constantWidth, 0 ) , cc.p( 0 , 1 ) , 24 , 22 , MColor.lable_yellow )
    richText:setAutoWidth()
    richText:addText( str, MColor.lable_yellow , true )
    richText:format()


    local  function clickFun()
        if itemData.isDesc and itemData.isDesc == 1 then
            package.loaded[ "src/layers/battle/DescLayer" ] = nil
            require( "src/layers/battle/DescLayer" ).new( itemData )
        else
            __GotoTarget( {ru =  itemData.q_go } )
        end
    end 
    local goBtn = createMenuItem( bg , "res/component/button/50.png", cc.p( 685 , 68 ) , clickFun)
    createLabel( goBtn , game.getStrByKey( "goto_activity_now" ) , getCenterPos( goBtn ) , nil , 22 , true )

    if game.getAutoStatus() ~= AUTO_MINE then --挖矿状态下会导致挖矿声音中断
        game.setAutoStatus(0)
    end
    getRunScene():addChild( npcPanel , 149 )
end



return M