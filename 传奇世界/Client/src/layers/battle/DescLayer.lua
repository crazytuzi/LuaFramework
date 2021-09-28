--[[ 活动说明 ]]--
local M = class( "DescLayer" , function() return cc.Layer:create() end)

function M:ctor( params )

    if type( params ) == "number" then
        params = getConfigItemByKey( "ActivityNormalDB" , "q_id"  , params )
    end

    if params == nil then return false end


    local keys = { 
                    [ "a151" ] = 10401 , 
                    [ "a104" ] = 10407 ,
                    [ "a103" ] = 10407 ,
                    [ "a153" ] = 10460 ,
                    [ "a5" ] = 10396 ,
                    [ "a6" ] = 10397 ,
                    [ "a135" ] = 10400 ,
                    [ "a159" ] = 10464 ,
                    [ "a203" ] = 10465 ,
                    [ "a19" ] = 20004 ,
                    [ "a144" ] = 10395 ,
                    [ "a110" ] = 10468 ,
                    [ "a20" ] = 10466 ,
                    [ "a173" ] = 10462 ,
                    [ "a172" ] = 11104 ,
                    [ "a109" ] = -1 ,
                    [ "a216" ] = 10523,
                    [ "a154" ] = 11114,
                    } 
    local npcID = keys[ params.q_go ]


    getRunScene():addChild(self,200)


    local base_node = createSprite( self , "res/common/bg/bg18.png" , cc.p( display.cx , display.cy ) , cc.p( 0.5 , 0.5 ) )
    local size = base_node:getContentSize()
    createSprite( base_node , "res/layers/rewardTask/rewardTaskReleaseBg.png" , cc.p( size.width/2 + 3, size.height/2 - 22 ) , cc.p( 0.5 , 0.5 ) )
    createSprite( base_node , "res/common/shadow/desc_shadow.png" , cc.p( size.width/2 , size.height/2 + 30 ) , cc.p( 0.5 , 0.5 ) )

    local func = function() 
        removeFromParent(self) 
    end
    registerOutsideCloseFunc( base_node , func , true )
    local close_btn = createMenuItem( base_node , "res/component/button/x2.png", cc.p( base_node:getContentSize().width-40 , base_node:getContentSize().height-30 ) , func )

    local size = base_node:getContentSize()
    createLabel( base_node ,  params.q_name , cc.p(size.width/2,size.height - 25 ),cc.p(0.5, 0.5), 24, true, nil, nil)

    local offX = 130
    local textCfg = {  
                        { str = game.getStrByKey("bodyguard_lv") .. "：" , pos = cc.p( 40 + offX, 405 ) , } ,
                        { str = game.getStrByKey("activity_time") , pos = cc.p( 40  + offX , 360 ) , } ,
                        { str = game.getStrByKey("activity_rule") , pos = cc.p( 40  + offX, 315  ) , } ,
                        { str = game.getStrByKey("activity_awards") , pos =  cc.p( 40  + offX, 205 ) , } ,
                    }
    for i = 1 , #textCfg do
        createLabel( base_node , textCfg[i]["str"]  , textCfg[i]["pos"] , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.lable_yellow , nil , nil , MColor.black , 3 )
    end

    local timeTab =  DATA_Battle:formatTime( params.q_time )      --活动时间
    local str = ""
    for i , v in ipairs( timeTab ) do str = str .. " " .. v end
    createLabel( base_node , str , cc.p( 135  + offX , 360 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.lable_black , nil , nil , MColor.black , 3 )

    createLabel( base_node , ( params.q_level or "" ) .. game.getStrByKey( "ji" )  , cc.p(  140  + offX , 405 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.white , nil , nil , MColor.black , 3 )
    local ruleText = createLabel( base_node , params.q_rule  or ""  , cc.p( 140  + offX , 340 ) , cc.p( 0 , 1 ) , 20 , nil , nil , nil , MColor.lable_black , nil , nil , MColor.black , 3 )
    ruleText:setDimensions( 410 , 0 )
    

    local awards = {} --奖励道具
    --奖励数据处理
    local DropOp = require("src/config/DropAwardOp")
    local tempTable = DropOp:getItemBySexAndSchool( params.q_dropid )
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
        setNodeAttr( iconGroup , cc.p( 25 + offX , 155  ) , cc.p( 0 , 0.5 ) )
        -- iconGroup:setScale(0.95)
        base_node:addChild( iconGroup )
    end





    local function gotoFun( btnType )
        removeFromParent(self)
        local TransmitFunc , findWayFunc  = nil , nil 
        local tarAddr = nil

        if npcID == -1 then
            local cfg = getConfigItemByKey( "MonAttackDB" )
            local tar = cfg[ math.random( 1 , #cfg ) ]
            tarAddr = { mapid = tonumber(tar.q_mapid) , x = tonumber(tar.q_centerx) , y = tonumber(tar.q_centery) }            

        else
            local npcCfg = getConfigItemByKey("NPC", "q_id", npcID )
            if npcCfg then
                -- --寻路前往  
                local handlerFun = function()                                          
                    if params.q_go == "a110" then
                        --膜拜沙城主 需手动操作，自动发现NPC请求会弹出垃圾界面
                        __GotoTarget( { ru = "a110"})
                    else
                        require("src/layers/mission/MissionNetMsg"):sendClickNPC(npcID)
                    end
                end           
                tarAddr = { mapid = tonumber(npcCfg.q_map) , x = tonumber(npcCfg.q_x) , y = tonumber(npcCfg.q_y) , handlerFun = handlerFun }
            end
        end
        
        

        if tarAddr then
            findWayFunc = function()
                __removeAllLayers()                                    
                local tempData = { targetType = 4 , mapID = tarAddr.mapid ,  x = tarAddr.x , y = tarAddr.y , callFun = tarAddr.handlerFun }
                __TASK:findPath( tempData )                    
            end

            --传送前往
            TransmitFunc = function()
                local shoewNeedData = { targetData = { mapID = tarAddr.mapid , pos = {cc.p( tarAddr.x - 1 , tarAddr.y ) } }, noTipShop = false, q_done_event = 0, callback = tarAddr.handlerFun  }
                __removeAllLayers(true,tarAddr.handlerFun)
                if __TASK:portalGo( shoewNeedData ) then 
                    DATA_Mission:setAutoPath(false)
                    DATA_Mission.isStopFind = true  
                    if G_MAINSCENE and G_MAINSCENE.map_layer then
                        G_MAINSCENE.map_layer:resetHangup()
                        if tempMapID == G_MAINSCENE.map_layer.mapID then
                            __removeAllLayers()
                        end
                    end
                end
            end
        end

        if btnType == 1 then
            if findWayFunc then findWayFunc() end
        else
            if TransmitFunc then TransmitFunc() end
        end

    end
    if params.q_go == "a11" then
        --使用镖车物资
        local autoBtn = createMenuItem( base_node , "res/component/button/50.png", cc.p( size.width/7 * 2 + 30, 60 ) , function() __GotoTarget( { ru = "a11" } )   end )
        createLabel( autoBtn , game.getStrByKey( "go" ) , getCenterPos( autoBtn ) , nil , 22 , true )

        local gotoBtn = createMenuItem( base_node , "res/component/button/50.png" , cc.p( size.width/7 * 5 - 30 , 60 ) , function() __GotoTarget( { ru = "a31" } ) end )
        createLabel( gotoBtn , game.getStrByKey( "equip_select_button_bag" ), getCenterPos( gotoBtn ) , nil , 22 , true )
    elseif params.q_go == "a45" then
       -- 野外杀怪 猎杀精英
       -- local autoBtn = createMenuItem( base_node , "res/component/button/50.png", cc.p( size.width/7 * 2 + 30, 60 ) , function()  gotoFun( 1 )  end )
       --  createLabel( autoBtn , game.getStrByKey( "go" ) , getCenterPos( autoBtn ) , nil , 22 , true )

        local gotoBtn = createMenuItem( base_node , "res/component/button/50.png" , cc.p( size.width/2 , 60 ) , function() __GotoTarget( { ru = params.q_go } ) end )
        createLabel( gotoBtn , game.getStrByKey( "title_map" ), getCenterPos( gotoBtn ) , nil , 22 , true )
    else
        if npcID then
            if params.q_go == "a20" then
                --行会物资  特殊处理
                local autoBtn = createMenuItem( base_node , "res/component/button/50.png", cc.p( size.width/2 , 60 ) , function()  gotoFun( 1 ) end )
                createLabel( autoBtn , game.getStrByKey( "go" ) , getCenterPos( autoBtn ) , nil , 22 , true )
            else
                
                local autoBtn = createMenuItem( base_node , "res/component/button/50.png", cc.p( size.width/7 * 2 + 30, 60 ) , function()  gotoFun( 1 )  end )
                createLabel( autoBtn , game.getStrByKey( "auto_find_way" ) , getCenterPos( autoBtn ) , nil , 22 , true )

                local gotoBtn = createMenuItem( base_node , "res/component/button/50.png" , cc.p( size.width/7 * 5 - 30 , 60 ) , function() gotoFun( 2 ) end )
                createLabel( gotoBtn , game.getStrByKey( "jy_chuansong" ), getCenterPos( gotoBtn ) , nil , 22 , true )
            end
        else
            local autoBtn = createMenuItem( base_node , "res/component/button/50.png", cc.p( size.width/2 , 60 ) , function()  __GotoTarget( {ru =  params.q_go } )  end )
            createLabel( autoBtn , game.getStrByKey( "go" ) , getCenterPos( autoBtn ) , nil , 22 , true )
        end
    end





    self:registerScriptHandler(function(event)
        if event == "enter" then
        elseif event == "exit" then
            g_EventHandler["hjTimeChangeCallBack"] = nil
        end
    end)
    
end


return M