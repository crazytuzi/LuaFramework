--[[ 定时活动子界面 ]]--
local M = class( "CellLayer" , function() return cc.Layer:create() end)

function M:ctor( cfgName )
    self.cfgName = cfgName
    local keys = { 
                    Luoxia = "lx" , 
                    -- Bodyguard = "hb" , 
                    XZKP = "qm" , 
                    XWZJ = "hj" , 
                    MXWK = "wk" , 
                }

                print( keys[ cfgName ] , cfgName )
    local image = "res/layers/battle/" .. keys[ cfgName ] .. "-min.jpg"

    local cfg = getConfigItemByKey( "ActivityNormalDB" , "q_id"  )

    for k,v in pairs(cfg) do
        if cfg[k].q_key == cfgName then
            cfg = cfg[k]
            break
        end
    end

    if not cfgName then
    	print("ERROR! .................. ")
    	return
    end

    local awards = {} --奖励道具

    --奖励数据处理
    local DropOp = require("src/config/DropAwardOp")
    local tempTable = DropOp:getItemBySexAndSchool( cfg.q_dropid )
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


    local base_node = createBgSprite( self , cfg.q_name or "" )
    local size = base_node:getContentSize()
    local left_bg_size = cc.size(896, 500)
    local left_bg = createScale9Frame(
        base_node,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(32, 38),
        left_bg_size,
        5
    )

    local insert_bg = createScale9Sprite(
        base_node,
        "res/common/scalable/panel_inside_scale9.png",
        cc.p(41, 46),
        cc.size(878, 254),
        cc.p(0, 0)
    )    

    local viewLayer = cc.Node:create()
    base_node:addChild( viewLayer )

    local sendMsg = function()
        local activityID = cfg and cfg.q_activity_id
        if activityID then
            g_msgHandlerInst:sendNetDataByTableExEx( ACTIVITY_NORMAL_CS_CHECK_CAN_JOIN , "ActivityNormalCanJoin", { activityID = activityID } )
            local msgids = {ACTIVITY_NORMAL_CS_CHECK_CAN_JOIN_RET}
            require("src/MsgHandler").new(self, msgids)
        end
    end


    local function createLayout()
        if viewLayer then viewLayer:removeAllChildren() end
        local keys = { Luoxia = "lx" , Bodyguard = "hb" , XZKP = "qm" , XWZJ = "hj" , MXWK = "wk" }
        local image = "res/layers/battle/" .. keys[ cfgName ] .. "-min.jpg"
        if image then
           local img =  createSprite( viewLayer , image , cc.p( size.width/2 , size.height - 104 ) , cc.p(  0.5 , 1 ) , nil )  
        end
        

        local textCfg = {  
                            { str = game.getStrByKey("activity_time") , pos = cc.p( 75 - 30  , 280 - 20) , } ,
                            { str = game.getStrByKey("bodyguard_lv") .. "：" , pos = cc.p( 740 + 40  , 280 - 20) , } ,
                            { str = game.getStrByKey("activity_rule") , pos = cc.p( 75 - 30 , 280 - 40 - 20) , } ,
                            { str = game.getStrByKey("activity_awards") , pos =  cc.p( 75 - 30 , 260 - 180 + 20 ) , } ,
                        }
        for i = 1 , #textCfg do
            createLabel( viewLayer , textCfg[i]["str"]  , textCfg[i]["pos"] , cc.p( 0 , 0 ) , 22 , nil , nil , nil , MColor.lable_yellow , nil , nil , MColor.black , 3 )
        end


        local timeTab =  DATA_Battle:formatTime( cfg.q_time )      --活动时间
        local str = ""
        for i , v in ipairs( timeTab ) do str = str .. " " .. v end
        createLabel( viewLayer , str , cc.p( 75 + 110 - 30 - 5, 280 - 20) , cc.p( 0 , 0 ) , 22 , nil , nil , nil , MColor.lable_black , nil , nil , MColor.black , 3 )

        createLabel( viewLayer , cfg.q_level or ""  , cc.p( 75 + 110 - 35 + 735 , 280 - 20) , cc.p( 0 , 0 ) , 22 , nil , nil , nil , MColor.lable_black , nil , nil , MColor.black , 3 )
        local ruleText = createLabel( viewLayer , cfg.q_rule  or ""  , cc.p( 75 + 110 - 30, 280 - 15 - 20) , cc.p( 0 , 1 ) , 22 , nil , nil , nil , MColor.lable_black , nil , nil , MColor.black , 3 )
        ruleText:setDimensions( 690  + 60 ,0)
        
        --createSprite( viewLayer , "res/common/bg/bg12-1.png" , cc.p( size.width/2 , 170 - 20) , cc.p(  0.5 , 0.5 )  ) 

        if awards then
            local iconGroup = __createAwardGroup( awards , nil , 90 )
            setNodeAttr( iconGroup , cc.p( 75 + 100 - 30 , 260 - 170 ) , cc.p( 0 , 0.5 ) )
            iconGroup:setScale(0.95)
            viewLayer:addChild( iconGroup )
        end

        local switchFun = { 
                        XZKP = function() --怪物攻城
                            __GotoTarget( { ru = "a95" } )
                        end ,         
                        Luoxia = function()
                             __GotoTarget( { ru = "a106" } )
                        end,          
                        MXWK = function()
                            __GotoTarget( { ru = "a157" } )
                        end,    
                        -- Bodyguard = function()--护镖
                        --     __GotoTarget({ru = "a19"})
                        --     __removeAllLayers()
                        -- end,          
                        XWZJ = function()--王城赐福
                            __GotoTarget({ru = "a148"})
                            -- __GotoTarget({ ru = "a129", Value = 8, notFly = true})
                        end,
                    }

        local checkLev = function()
            if cfg.q_level > MRoleStruct:getAttr(ROLE_LEVEL) then
                TIPS( {str = string.format(game.getStrByKey("activity_begain_atLev"), cfg.q_level)} )
                return false
            end
            local tempMapCfg = {
                                XZKP = 2100,
                                Luoxia = 3100,
                                XWZJ = 2100,
                                Bodyguard = 2100,
                                MXWK = 1120,
                                qmbd = 7000,
                                }
            if tempMapCfg[cfgName] then           
                local mapInfo = getConfigItemByKey("MapInfo", "q_id")[tempMapCfg[cfgName]]
                if mapInfo and mapInfo.q_map_min_level and mapInfo.q_map_min_level > MRoleStruct:getAttr(ROLE_LEVEL) then
                    local msg_item = getConfigItemByKeys( "clientmsg" , { "sth" , "mid" } , { 21000 , -1 } )
                    local msgStr = string.format( msg_item.msg , tostring( mapInfo.q_map_min_level ) )
                    TIPS( { type = msg_item.tswz , flag = msg_item.flag , str = msgStr })                    
                    return false
                end   
            end          

            return true
        end

        local btnCallback = function()
            if checkLev() then 
                switchFun[cfgName]()  
                performWithDelay(self, sendMsg, 0.3)
            end 
        end

        local btn = createMenuItem(viewLayer, "res/component/button/50.png", cc.p( 840 , 260 - 170 + 5 ),  btnCallback, 1, true )
        btn:setEnabled( false)
        self.btn = btn

        self.btnLab = createLabel( btn , game.getStrByKey("join_activityLate")  , getCenterPos( btn ) , cc.p( 0.5 , 0.5 ) , 24 ,true )

        if cfgName ~= "MXWK" then
            local spr = createSprite( viewLayer , "res/component/flag/10.png", cc.p( 500 , 330   ), cc.p( 0.5 , 0.5 ) )
            spr:setVisible(false)
            self.hotSpr = spr
        end

        sendMsg()
    end

    createLayout()
end
function M:networkHander(buff,msgid)
    local switch = 
    {
        [ACTIVITY_NORMAL_CS_CHECK_CAN_JOIN_RET] = function()
            local t = g_msgHandlerInst:convertBufferToTable( "ActivityNormalCanJoinRet" , buff )    
            local retNum = t.canJoin
            dump(retNum, "retNum")

            local str = ""
            if self.cfgName ~= "XWZJ" then
                str = game.getStrByKey("join_activity")
                if retNum == 1 then
                    str = game.getStrByKey("join_activityLate")
                elseif retNum == 2 then
                    str = game.getStrByKey("fb_alreadyGot2")
                elseif retNum == 3 then
                    str = "已参加"
                end
            else
                str = "领取美酒"
                if retNum == 1 then
                    str = game.getStrByKey("join_activityLate")
                elseif retNum == 2 then
                    str = game.getStrByKey("fb_alreadyGot2")
                elseif retNum == 3 then
                    str = "已参加"
                end
            end
                
            if self.btnLab then
                self.btnLab:setString(str)
            end

            if self.btn then
                self.btn:setEnabled(retNum == 0)
            end
            if self.hotSpr then
                self.hotSpr:setVisible(retNum == 0)
            end
        end,
    }

    if switch[msgid] then
        switch[msgid]()
    end
end


return M