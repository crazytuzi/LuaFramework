--界面跳转
local targetMapName = function(name)
    --不同键值跳转同一个界面的 加下映射关系 ，保留一个就好了
    local mapstr = {
        a2 = "a1",
    }
    return mapstr[name] or name
end

function HasTargetTab( _ru )
    local parent = getRunScene()
    local ru = targetMapName(_ru)
    if ru and parent:getChildByName(ru) then
       return true
    end
    return false
end

function __RemoveTargetTab( _ru,parent )
    local parent = parent or getRunScene()
    local ru = targetMapName(_ru)
    if ru and parent:getChildByName(ru) then
       parent:removeChildByName(ru)
    end
end

--- ios 有些界面打不开 问题  ，搞了一天 ，暂时这样修改 
local sub_node = nil
local temp_node = nil
local tempIndex = 0
local isOpen = false

local params = {}

local _gotoSwitchFun = {
    a1 = function()
        --日常任务
        __TASK:popupLayout( "every" )
        isOpen = true
    end ,
    a2 = function()
        --主线任务界面
        __TASK:popupLayout( "plot" )
        isOpen = true
    end ,
    a3 = function()
        -- --帮会界面
        if NewFunctionIsOpen(NF_FACTION) then
            if G_FACTION_INFO.facname and G_FACTION_INFO.id > 0 then
                sub_node = require("src/layers/faction/FactionLayer").new()
                --self:addChild(layer,200,100+index)
            else
                sub_node = require("src/layers/faction/FactionCreateAndListLayer").new()
                --self:addChild(layer,200,100+index)
            end
            isOpen = true
        end
    end ,
    a4 = function()
        --竞技场
        if NewFunctionIsOpen(NF_BATTLE) and G_CONTROL:isFuncOn( GAME_SWITCH_ID_SINPVP )  then
            sub_node = require("src/layers/jjc/JJCHall").new( params.mode or 2 )
            isOpen = true
        end
    end ,
    a5 = function()
        --挑战界面屠龙传说Icon
        if NewFunctionIsOpen( NF_FB_SINGLE )  then
            __GotoTarget({ ru = "a129", Value = 1})
            isOpen = true
        end
    end ,
    a6 = function()
        --挑战界面通天塔Icon
        if NewFunctionIsOpen( NF_FB_TOWER )  then
            __GotoTarget({ ru = "a129", Value = 2})
            isOpen = true
        end
    end ,
    a7 = function()
        sub_node = require("src/layers/battle/BattleList").new( { activityID = 1 } )
        isOpen = true
    end ,
    a8 = function()
        --添加好友界面
        if G_MAINSCENE.gotoSocial and NewFunctionIsOpen(NF_FRIEND) then
            if params.gotoType and params.gotoType == 1 then
                G_MAINSCENE:gotoSocial() --这种跳转是不对的，如果确实需要执行，请加参数( gotoType且值为1 )
            else
                sub_node = require("src/layers/friend/SocialNode").new()
            end
            isOpen = true
        end
    end ,
    a9 = function()
        --世界boss
        if G_NEW_WORLD_BOSS then
            sub_node = require( "src/layers/activity/cell/NewWorldBoss").new()
        else
            sub_node = require( "src/layers/activity/cell/world_boss").new()
        end

        isOpen = true
    end ,
    a10 = function()
        --绑元商城
        sub_node = require("src/layers/shop/shopLayer").new( { shop = 1 } )
        isOpen = true
        tempIndex = 21
    end ,
    a11 = function()
        --寻路至中州运镖路线上
        local pathCfg = require("src/layers/map/DetailMapNode"):getDartPath( 2100 )
        local pos = pathCfg[ math.random( 1 , #pathCfg ) ]
        __removeAllLayers()                                    
        local tempData = { targetType = 4 , mapID = 2100,  x = pos.x , y = pos.y  }
        __TASK:findPath( tempData )   
    end ,
    a12 = function()
        --元宝商城
        sub_node = require("src/layers/shop/shopLayer").new( { shop = 0 } )
        tempIndex = 21
        isOpen = true
    end ,
    a13 = function()
        --装备强化界面
        sub_node = require("src/layers/beautyWoman/RoleAndBeautyLayer").new()
        tempIndex = 1
        isOpen = true
    end ,
    a14 = function()
        --装备进阶界面
        sub_node = require("src/layers/beautyWoman/RoleAndBeautyLayer").new()
        tempIndex = 1
        isOpen = true
    end ,
    a15 = function()
        --装备晋级界面
        sub_node = require("src/layers/beautyWoman/RoleAndBeautyLayer").new()
        tempIndex = 1
        isOpen = true
    end ,
    a16 = function()
        --镖车
        package.loaded[ "src/layers/activity/cell/bodyguard" ] = nil
        sub_node = require( "src/layers/activity/cell/bodyguard" ).new( params )
    end ,
    a17 = function()
        --坐骑晋级界面
        if G_RIDING_INFO.id and G_RIDING_INFO.id[1] then
            sub_node = require("src/layers/beautyWoman/RoleAndBeautyLayer").new(nil,2)
            isOpen = true
            --tempIndex = 1
        else
            MessageBox(string.format(game.getStrByKey("wr_riding_noRidingTip"),getConfigItemByKey("NewFunctionCfg", "q_ID", NF_RIDE).q_level))
        end
    end , 
    a18 = function()
        --光翼晋级界面
        if G_WING_INFO.id then
            sub_node = require("src/layers/beautyWoman/RoleAndBeautyLayer").new(nil,3)
            tempIndex = 1
            isOpen = true
        else
            local cfg = getConfigItemByKeys( "BranchDB" , "q_taskid" )[ 51005]
            TIPS( { type = 1 , str = string.format(game.getStrByKey( "func_unavailable_wing" ) , cfg["q_accept_needmingrade"] ,cfg["q_name"]) } )
        end
    end ,
    a19 = function()
        --镖师NPC
        __GotoTarget({ ru = "a129", Value = 12 })
    end ,
    a20 = function()
        --行会运镖
        __GotoTarget({ ru = "a129", Value = 14 })
    end ,
    a21 = function()
        --光翼技能界面
        if G_WING_INFO.id then
            sub_node = require("src/layers/beautyWoman/RoleAndBeautyLayer").new(nil,3,"toSkill")
            tempIndex = 1
            isOpen = true
        else
            local cfg = getConfigItemByKeys( "BranchDB" , "q_taskid" )[ 51005]
            TIPS( { type = 1 , str = string.format(game.getStrByKey( "func_unavailable_wing" ) , cfg["q_accept_needmingrade"] ,cfg["q_name"]) } )
        end
    end ,
    a22 = function()
        --光翼技能界面
        if G_WING_INFO.id then
            sub_node = require("src/layers/beautyWoman/RoleAndBeautyLayer").new(nil,3)
            tempIndex = 1
            isOpen = true
        else
            local cfg = getConfigItemByKeys( "BranchDB" , "q_taskid" )[ 51005]
            TIPS( { type = 1 , str = string.format(game.getStrByKey( "func_unavailable_wing" ) , cfg["q_accept_needmingrade"] ,cfg["q_name"]) } )
        end
    end ,
    a23 = function()
        --行会篝火界面
        sub_node = require("src/layers/faction/FactionFireLayer").new()
        isOpen = true
    end ,
    -- a24 = function()
    -- end ,
    a25 = function()
        --购买月卡界面
        sub_node = require("src/layers/activity/GiftLayer").new( { targetID = 5 } )
        isOpen = true
    end ,
    a26 = function()
        --装备分解  
        sub_node = require("src/layers/bag/smelter").new()
        isOpen = true
    end ,
    a27 = function()
        --技能升级
        sub_node = require("src/layers/skill/SkillsLayer").new(1)
        isOpen = true
        tempIndex = 3
    end ,
    a28 = function()
        --每日签到
        -- if G_NFTRIGGER_NODE and G_NFTRIGGER_NODE:isFuncOn( NF_SIGN_IN )  then
        --     sub_node = require("src/layers/activity/GiftLayer").new( )
        -- else
        --     TIPS( {type = 1 ,str = game.getStrByKey("func_unavailable")}  )
        -- end
        if NewFunctionIsOpen(NF_SIGN_IN) then
            sub_node = require("src/layers/activity/GiftLayer").new( )
            isOpen = true
        end
    end ,
    a29 = function(params)
        --队伍界面
        --package.loaded[ "src/layers/teamup/TeamUp" ] = nil
        if not bForbidTeamTouch then
            sub_node = require("src/layers/teamup/TeamLayer").new(params.index)
            -- sub_node = require("src/layers/teamup/TeamLayer").new(1)
            tempIndex = 4
            isOpen = true
        end
    end ,
    a30 = function()
        --送花
        if G_MAINSCENE.gotoSocial and NewFunctionIsOpen(NF_FRIEND) then
            G_MAINSCENE:gotoSocial()
            isOpen = true
        end
    end ,
    a31 = function()
        --背包界面
		local view = require("src/layers/bag/BagView").new()
		if view ~= nil then
			sub_node = view
			tempIndex = 2
			isOpen = true
		end
    end ,
    a32 = function()
        --福利界面
        -- package.loaded[ "src/layers/activity/GiftLayer" ] = nil  
        sub_node = require("src/layers/activity/GiftLayer").new( )
        isOpen = true
    end ,
    a33 = function()
        --充值页面
        --关闭潘多拉支付标志位
        G_isPandoraPay = false
        if G_NO_OPEN_PAY then
            TIPS( { type = 1 , str = game.getStrByKey( "fun_not_open_tips" ) } )
        else
            sub_node = require("src/layers/pay/PayView").new()
            isOpen = true
        end 
    end ,
    a34 = function()
        local str = game.getStrByKey( "guild_dart1" )
        str = str .. game.getStrByKey( "guild_dart2" )
        str = str .. game.getStrByKey( "guild_dart3" )
        str = str .. game.getStrByKey( "guild_dart4" )
        str = str .. game.getStrByKey( "guild_dart5" )
        str = str .. game.getStrByKey( "guild_dart6" )
        str = str .. game.getStrByKey( "guild_dart7" )
        str = str .. game.getStrByKey( "guild_dart8" )
        str = str .. game.getStrByKey( "guild_dart9" )
        str = str .. game.getStrByKey( "guild_dart10" )
        local __ , showFun = __createHelp( { parent = nil , str =  str } )
        showFun()
    end ,
    a35 = function()
        local proto = {}
        proto.copyId = 6008
        proto.isInCopy = 0
        g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_ENTERCOPY, "EnterCopyProtocol", proto);

    end ,
    -- a36 = function()
    -- end ,
    a37 = function()
        --多人守卫
		-- local ILevel = MRoleStruct:getAttr(ROLE_LEVEL)
		-- if ILevel == nil or ILevel < 34 then
		-- 	TIPS({type=1, str=string.format(game.getStrByKey("activity_begain_atLev"), 34)})
		-- 	return
		-- end

  --       if NewFunctionIsOpen(NF_FB_PROTECT) then
            -- sub_node = require("src/layers/fb/multiplayer").new()
            --sub_node = require("src/layers/fb/FBHallView").new(4)
            local oPanel = GetMultiPlayerCtr():openMultiPlayerMainPanel()
            sub_node = oPanel:GetUIRoot()
            -- 这个tag是为了在 getRunScene() 中呼出 + 100
            tempIndex = 50
            isOpen = true
        --end
    end ,
    a38 = function()
        --神秘商店
        --dump(NewFunctionIsOpen( NF_FURNACE ))
		if NewFunctionIsOpen( NF_FURNACE )  then
          sub_node = require("src/layers/shop/shopLayer").new({ shop = -3, title = true })
          tempIndex = 21
          isOpen = true
        end

    end ,
    -- a39 = function()
    --     --摇钱树界面
    --       sub_node = require("src/layers/activity/cell/moneyTreeLayer").new()
    --       isOpen = true
    -- end ,
    a40 = function()
        --定时活动界面
        if NewFunctionIsOpen(NF_ACTIVE) then
            package.loaded[ "src/layers/battle/BattleList" ] = nil    
            sub_node = require("src/layers/battle/BattleList").new( { activityID = 0 } )
            isOpen = true
        end
    end ,
    a41 = function()
        if MRoleStruct:getAttr(PLAYER_FACTIONID) == 0 then
            TIPS( getConfigItemByKeys("clientmsg",{"sth","mid"},{ 5000 , -16 })  )
            return
            -- sub_node = require("src/layers/faction/FactionLayer").new()
        else
            --帮会商店
            --sub_node = require("src/layers/shop/FactionShop").new()
            sub_node = require("src/layers/faction/FactionLayer").new(2, 2)
            isOpen = true
        end
    end ,
    a42 = function()
        --添加篝火提示
        sub_node = require("src/layers/faction/FactionAddFireLayer").new()
        isOpen = true
    end ,
    a43 = function()
        --行会驻地
        -- sub_node = require("src/layers/faction/FactionAddFireLayer").new()
        g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_ENTERAREA, "FactionEnterArea", {})
    end ,
    a44 = function()
        --神戒传送界面
        sub_node = require("src/layers/map/MapAndTransfer").new(2)
        isOpen = true
    end ,
    a45 = function()
        --野外传送
        sub_node = require("src/layers/map/MapAndTransfer").new( 3)
        isOpen = true
    end ,
    a46 = function()
         --社交界面
        if NewFunctionIsOpen(NF_FRIEND) then
            sub_node = require("src/layers/friend/SocialNode").new()
            isOpen = true
        end
    end ,
    a47 = function()
        --战斗日志
        sub_node = require("src/layers/role/fightLog").new()
        isOpen = true
        --tempIndex = 7
    end ,
    a48 = function()
        --战神试炼定位金币获得
        if G_NFTRIGGER_NODE and G_NFTRIGGER_NODE:isFuncOn( NF_FB_SINGLE_2 )  then
             sub_node = require("src/layers/battle/BattleList").new( { activityID = 1 } )
             isOpen = true
        else
            TIPS( getConfigItemByKeys("clientmsg",{"sth","mid"},{ 5000 , -16 })  )
            return
        end
    end ,
    -- a49 = function()
    --     --按索引跳转我要
    --     sub_node = require("src/layers/setting/gameHelp").new( { idx = params.index } )
    --     isOpen = true
    -- end ,
    a50 = function()
        -- 勇闯炼狱下一层
        g_msgHandlerInst:sendNetDataByTableExEx(ENVOY_CS_ENTER_NEXT, "EnvoyEnterNextReq", {option = 0})
    end ,
    -- a51 = function()
    --     --美人
    --     if G_VIP_INFO and G_VIP_INFO.vipLevel and G_VIP_INFO.vipLevel>0 then
    --         sub_node = require("src/layers/beautyWoman/RoleAndBeautyLayer").new(nil,4)
    --         tempIndex = 1
    --     else
    --         MessageBox(game.getStrByKey("wr_beauty_noBeautyTip"))
    --     end
    -- end ,
    a52 = function()
    end ,
    a53 = function()
        --打开称号界面
        sub_node = require("src/layers/achievementEx/AchievementAndTitleLayer").new(2)
        isOpen = true
    end ,
    a56 = function()
        --首充
        if G_NO_OPEN_PAY then
            TIPS( { type = 1 , str = game.getStrByKey( "fun_not_open_tips" ) } )
        else
            if DATA_Activity.firstData then
                package.loaded[ "src/layers/activity/template/temp112" ] = nil    
                DATA_Activity.CData = { modelID = DATA_Activity.firstData["modelID"], activityID = DATA_Activity.firstData["activityID"] } 
                require("src/layers/activity/template/temp112").new()
            end
        end
    end ,
    a57 = function()
      --角色界面
		local secondaryPass = require("src/layers/setting/SecondaryPassword")
		if not secondaryPass.isSecPassChecked() then
			secondaryPass.inputPassword()
			return
		else
			sub_node = require("src/layers/beautyWoman/RoleAndBeautyLayer").new()
			isOpen = true
		end
    end ,
    -- a58 = function()
    -- end ,
    -- a59 = function()
    --     --连服竞技场商店
    --     sub_node =  require("src/layers/shop/shopLayer").new({ shop = 13, title = true })
    --     isOpen = true
    -- end ,
    a60 = function()
        --VIP神秘商店
        if NewFunctionIsOpen(NF_MYSTERY) then
            __GotoTarget( { ru = "a38" } )
            isOpen = true
            return
        end
    end ,
    -- a61 = function()
    -- end ,
    -- a62 = function()
    -- end ,
    -- a63 = function()
    -- end ,
    -- a64 = function()
    -- end ,
    -- a65 = function()
    -- end ,
    -- a66 = function()
    -- end ,
    a67 = function(__params)
        --重装使者
        local function goCarry()
            if not G_MAINSCENE.map_layer.isfb then
                dump(zzLevel)
                --g_msgHandlerInst:sendNetDataByFmtExEx(ENVOY_CS_JOIN, "ic", G_ROLE_MAIN.obj_id, __params.zzLevel) 
                local t = {}
                t.model = __params.zzLevel
                g_msgHandlerInst:sendNetDataByTableExEx(ENVOY_CS_JOIN, "EnvoyJoinReq", t)
                addNetLoading(ENVOY_CS_JOIN, ENVOY_SC_JOIN_RET) 
            else
                TIPS({type = 1 , str = game.getStrByKey("carry_tip_unavailable")})
            end
        end

        local MRoleStruct = require("src/layers/role/RoleStruct")
        local lv = MRoleStruct:getAttr(ROLE_LEVEL)

        if lv and lv >= 32 then
            local costTab = 
            {
                game.getStrByKey("cost1_level1"),
                game.getStrByKey("cost1_level2"),
                game.getStrByKey("cost1_level3"),
            }
            local text = string.format(game.getStrByKey("cost1"), costTab[__params.zzLevel])
            MessageBoxYesNo("",  text, goCarry, nil)
        else
            local msg_item = getConfigItemByKeys( "clientmsg" , { "sth" , "mid" } , { 21000 , -1 } )
            local msgStr = string.format( msg_item.msg, 38)
            TIPS( { type = msg_item.tswz , flag = msg_item.flag , str = msgStr })
        end

    end ,

    a79 = function()
        --公平竞技场不能进邮件
        if G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.isSkyArena then 
            TIPS( {type=1,str=game.getStrByKey("sky_arena_cantopen_mail") } ) 
        else
            --邮件
            checkIfSecondaryPassNeed( function()  
                                            sub_node =  nil           
                                            require("src/layers/mail/MailList").new()
                                            tempIndex = 206 
                                        end )
        end
    end ,
    a80 = function()
        --排行榜
        sub_node =  require("src/layers/ranking/RankingView").new(2)
        tempIndex = 21
        isOpen = true
    end ,
    -- a81 = function()
    -- end ,
    -- a82 = function()
    -- end ,
    -- a83 = function()
    --     --魂值商店
    --     sub_node = require("src/layers/shop/shopLayer").new( { shop = 3 } )  
    --     isOpen = true
    -- end ,
    a84 = function()
        --霸业
        sub_node = require("src/layers/empire/EmpireLayer").new(params.index)  
        isOpen = true
    end ,
    a85 = function()

    end ,
    -- a86 = function()
    -- end ,
    a87 = function()
        --魅力排行版
        --package.loaded[ "src/layers/ranking/CharmRankingLayer" ] = nil 
        sub_node = require("src/layers/ranking/RankingView").new(1)
        isOpen = true
    end,
    a88 = function()
        --膜拜
        package.loaded[ "src/layers/worship/worShipLayer" ] = nil 
        sub_node = require("src/layers/worship/worShipLayer").new(params.where)
    end,  
    a89 = function()
        --活动界面
        package.loaded[ "src/layers/activity/ActivityLayer" ] = nil  
        temp_node = require("src/layers/activity/ActivityLayer").new( )
    end,    
    -- a90 = function()
    -- end,    
    -- a91 = function()
    -- end,    
    -- a92 = function()
    -- end,  
    a93 = function()
        --仓库
        sub_node = require("src/layers/bag/BagView").new({target = game.getStrByKey("bank")})
        isOpen = true
    end,
    a94 = function()
        --神装
        sub_node = require("src/layers/dictionary/catalog").new(3)
        isOpen = true
    end,
    a95 = function()
        --怪物攻城---进入
        -- local cfg = getConfigItemByKey( "MonAttackDB" )
        -- local targetAdd = cfg[ math.random( 1 , #cfg ) ]
        -- __shoesGoto( { mapid = targetAdd.q_mapid , x = targetAdd.q_centerx , y = targetAdd.q_centery } )
        local cfg = getConfigItemByKey( "MonAttackDB" )
        local targetAdd = cfg[ math.random( 1 , #cfg ) ]
        require("src/layers/spiritring/TransmitNode").new(targetAdd.q_mapid , targetAdd.q_centerx, targetAdd.q_centery)
    end,
    -- a96 = function()

    -- end,
    a97 = function()
        sub_node = require("src/layers/carry/CarryLayer").new()
        isOpen = true
    end,
    a98 = function()
        --仙翁醉酒远点界面
        sub_node = require("src/layers/battle/CellLayer").new( "XWZJ" )
        isOpen = true
    end,
    -- a100 = function()
    --     --中级炼狱
    --     sub_node = require("src/layers/carry/CarryLayer").new({farAway = params.farAway})
    --     isOpen = true
    -- end,
    -- a101 = function()
    --     --高级炼狱
    --     sub_node = require("src/layers/carry/CarryLayer").new({farAway = params.farAway})
    --     isOpen = true
    -- end ,
    -- a102 = function()
    --     --激活码(位置改动 不能再以独立界面打开了)
    -- end,
    a103 = function()
        --落霞夺宝---寻找NPC
        __GotoTarget({ ru = "a129", Value = 6 })
    end,
    a104 = function()
        --落霞夺宝---寻找NPC
        __GotoTarget({ ru = "a129", Value = 6, notFly = true})
    end,
    a105 = function()
        --挑战
        __GotoTarget( { ru = "a40" } )
    end,
    a106 = function()
        --落霞夺宝---进入
        local function goRobBox()
            if not G_MAINSCENE.map_layer.isfb then
                g_msgHandlerInst:sendNetDataByTableExEx(LUOXIA_CS_JOIN, "LuoxiaJoinProtocol", {}) 
                --addNetLoading(LUOXIA_CS_JOIN, LUOXIA_SC_JOIN_RET) 
            else
                TIPS({type = 1 , str = game.getStrByKey("carry_tip_unavailable")})
            end
        end
        local MRoleStruct = require("src/layers/role/RoleStruct")
        local lv = MRoleStruct:getAttr(ROLE_LEVEL)

        if lv and lv >= 30 then
            MessageBoxYesNo("", game.getStrByKey("cost3") , goRobBox, nil)
        else
            TIPS( {str = game.getStrByKey("lv2") })
        end
    end,
    a107 = function()
        --落霞夺宝---界面
        sub_node = require("src/layers/battle/CellLayer").new( "Luoxia" )
        isOpen = true
    end,
    a108 = function()
        --积分商城
        sub_node = require("src/layers/shop/shopLayer").new( { shop = 12 } )
        isOpen = true
    end,
    a109 = function()
        --怪物攻城远点界面
        sub_node = require("src/layers/battle/CellLayer").new( "XZKP" )
        isOpen = true
    end,
    a110 = function()
        --膜拜中州王
        __GotoTarget( { ru = "a88", where = 1})
    end,
    a111 = function()
        --膜拜沙城城主
        __GotoTarget( { ru = "a88", where = 2})
    end,
    a112 = function()
        --领地战
        __GotoTarget( { ru = "a84", index = 1})
    end,
    a113 = function()
        --中州战
        __GotoTarget( { ru = "a84", index = 2})
    end,
    a114 = function()
        --沙城战
        __GotoTarget( { ru = "a84", index = 3})
    end, 
    -- a115 = function()
    --     --帮助
    --    sub_node = require("src/layers/setting/gameHelp").new( { idx = 2 } )
    --    isOpen = true
    -- end,     
    a116 = function()
        --内测返利
        package.loaded[ "src/layers/activity/template/temp12" ] = nil
        DATA_Activity.CData = { modelID = 12 , activityID = 0 } 
        require("src/layers/activity/template/temp12").new()
    end,         
    -- a117 = function()
    --     --连服竞技场商店

    -- end,
    a118 = function()
        -- 帮会
        if G_FACTION_INFO.facname and G_FACTION_INFO.id > 0 then
            sub_node = require("src/layers/faction/FactionLayer").new(2, 3)
            isOpen = true
        else
            TIPS({str = game.getStrByKey("join_faction_tips"), type = 1})
        end
    end,   
    a119 = function()
    end,                
    -- a120 = function()
    --     --捐赠魔神雕像
    --     package.loaded[ "src/layers/contribution/ContributionView" ] = nil
    --     sub_node = require("src/layers/contribution/ContributionView").new()
    --     isOpen = true
    -- end,                
    -- a121 = function()
    --     --开服好礼
    --     sub_node = require("src/layers/activity/GiftLayer").new( { targetID = 2 } )
    -- end,
    a122 = function()
        --传世宝典
        -- sub_node = require("src/layers/dictionary/CQdictionary").new()
		local secondaryPass = require("src/layers/setting/SecondaryPassword")
		if not secondaryPass.isSecPassChecked() then
			secondaryPass.inputPassword()
			return
		else
			sub_node = require("src/layers/dictionary/catalog").new(1)
			isOpen = true
		end
    end,
    a123 = function()
        --拍卖行
        if G_NFTRIGGER_NODE and G_NFTRIGGER_NODE:isFuncOn(NF_AUCTION) then
            sub_node = require("src/layers/consign/ConsignLayer").new()
            isOpen = true
        else
            TIPS( {type = 1 ,str = game.getStrByKey("func_unavailable")}  )
        end
    end,
    a124 = function()
        --熔炼
        if NewFunctionIsOpen(NF_FURNACE) then
            tempIndex = require("src/config/CommDef").PARTIAL_TAG_SMELTER_DIALOG_TEMP
            sub_node = require("src/layers/bag/SmelterView").new()
            isOpen = true
        end
    end,
    a125 = function()   -- 承接任务
        sub_node = require("src/layers/rewardTask/rewardTaskLayer").new(1);
        isOpen = true
    end,
    a126 = function()   -- 发布任务
        sub_node = require("src/layers/rewardTask/rewardTaskLayer").new(2);
        isOpen = true
    end,
    a127 = function()   -- 屠龙传说
        if NewFunctionIsOpen(NF_FB_SINGLE)  then
            temp_node = require("src/layers/DragonSliayer/DragonSliayer").new();
            isOpen = true
        end
    end,
    a128 = function()   --通天塔
        --if NewFunctionIsOpen(NF_FB_TOWER) then
            sub_node = require("src/layers/fb/fbSubHall/FBTowerHall").new()
            isOpen = true
        --end
    end,
    a129 = function()   --副本Icon寻路
        --1：屠龙传说接引人、2：通天塔接引人、3：恶魔城接引人、4：守卫使者、5：魅力榜、6：落霞夺宝(10407)、7：焰火屠魔(10399)、8：仙翁赐酒(10460)、9：勇闯炼狱(10401)、10：冒险挖矿(10464)
        --11 远古宝藏（10465) 12 镖师(20004) 13幽影阁门人(10395) 14行会物资/运镖（10466) 15行会使者(10462) 16 行会篝火(10463) 17:黑市商人(10490)
        --18 书店老板(10489)、19 战队管理员(10999)、20 宝地使者(10523) 、21 竞技场管理员 (11104)
        local npcIdCfg = {
                            10396, 10397, 10383, 10400, 10394, 10407, 10399, 10460, 10401, 10464, 
                            10465, 20004 , 10395 , 10466 , 10462 , 10463 , 10490 ,10489, 10999, 
                            10523, 11104,
                        }
        if npcIdCfg[params.Value] then
            local npcCfg = getConfigItemByKey("NPC", "q_id", npcIdCfg[params.Value])
            if npcCfg then
                local tempMapID = tonumber(npcCfg.q_map)
                local tempPos = cc.p(tonumber(npcCfg.q_x), tonumber(npcCfg.q_y))
                local npcID = npcIdCfg[params.Value]     
                --寻路前往  
                local handlerFun = function()                                          
                    require("src/layers/mission/MissionNetMsg"):sendClickNPC(npcID)
                end           
                local findWayFunc = function()
                    __removeAllLayers()                                    
                    local tempData = { targetType = 4 , mapID = tempMapID,  x = tempPos.x , y = tempPos.y , callFun = handlerFun  }
                    __TASK:findPath( tempData )                    
                end

                --传送前往
                local TransmitFunc = function()
                    local shoewNeedData = { targetData = { mapID = tempMapID , pos = {cc.p(tempPos.x-1,tempPos.y)}}, noTipShop = false, q_done_event = 0,}
                     __removeAllLayers(true,handlerFun)
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

                if params.notFly then
                    findWayFunc()
                else
                    MessageBoxYesNoEx(nil, string.format( game.getStrByKey("find_npc"), npcCfg.q_name or ""), 
                                          findWayFunc, TransmitFunc, game.getStrByKey("auto_find_way"), game.getStrByKey("delivery"), true
                                         )
                end
            end
        end
    end,

	a130 = function()   --救公主
		G_MAINSCENE.DefensePrincess:startDialog()
    end,
    a131 = function()
        --跳转到挑战副本界面
        sub_node = require("src/layers/battle/BattleList").new( { activityID = 1 } )
        isOpen = true
    end ,
    a132 = function()
        -- --挑战界面拯救公主Icon
        if NewFunctionIsOpen(NF_FB_PROTECT)  then
            __GotoTarget({ ru = "a129", Value = 3})
            isOpen = true
        end
    end ,
    a133 = function()
        --行会篝火NPC
        if NewFunctionIsOpen(NF_FACTION) and  G_FACTION_INFO.facname and G_FACTION_INFO.id > 0 then
            __GotoTarget({ru = "a129", Value = 16 })
        else
            TIPS( { type=1 , str = game.getStrByKey("join_faction_tips") } )
        end
    end ,
    a134 = function()
    	--寻路到NPC打开排行榜
    	__GotoTarget({ru = "a129", Value = 5})
   	end ,
    a135 = function()
        --多人守卫 NPC
        --if NewFunctionIsOpen(NF_FB_PROTECT) then
            __GotoTarget({ ru = "a129", Value = 4})
            isOpen = true
        --end
    end,
    a136 = function()
        --传世宝典之进阶秘籍之我要变强
        sub_node = require("src/layers/dictionary/catalog").new(2)
    end,
    a137 = function()
        --传世宝典之进阶秘籍之我要升级
        sub_node = require("src/layers/dictionary/catalog").new(2,1)
    end,
    a138 = function()
        --勋章界面
        local MpropOp = require "src/config/propOp"
        local dress = MPackManager:getPack(MPackStruct.eDress)        
        local grid = dress:getGirdByGirdId(MPackStruct.eMedal)
        if grid then
            local strengthLv = MPackStruct.attrFromGird(grid, MPackStruct.eAttrStrengthLevel)
            local proId = MPackStruct.protoIdFromGird(grid)
            local school = MpropOp.schoolLimits(proId)
            sub_node = require("src/layers/role/honourLayer").new(strengthLv,school,true,grid)
            isOpen = true
        else
            TIPS( { type = 1 , str = "^c(lable_yellow)"..game.getStrByKey("noHonour").."^" }  )
        end
    end,
    a139 = function()
        --勇者试炼  王者之路
       sub_node = require("src/layers/battle/BattleList").new( { activityID = 2 } )
       isOpen = true
    end,
	a140 = function()
        --祝福当前武器界面
		local dress = MPackManager:getPack(MPackStruct.eDress)        
        local grid = dress:getGirdByGirdId(MPackStruct.eWeapon)
		 if grid then
			MequipWish = require "src/layers/equipment/equipWish"
			sub_node = MequipWish.new({packId=MPackStruct.eDress, grid=grid})
			sub_node:setPosition(cc.p( display.width/2, display.height/2 ))
            isOpen = true
        else
            TIPS( { type = 1 , str = "没有装备武器" }  )
        end
    end,
    a141 = function()
        --装备打造
        --todo:此处需要统一tempIndex的设置方式，应将baseTag + tempIndex统一在src/config/CommDef
        tempIndex = require("src/config/CommDef").PARTIAL_TAG_EQUIP_MAKE_DIALOG_TEMP
        sub_node = require("src/layers/equipment/equipMake").new({q_sort = 1})
		if sub_node then
			sub_node:setPosition(g_scrCenter)
			SwallowTouches(sub_node)
		end
        isOpen = true
    end,
    a142 = function()
        --设置
        sub_node = require("src/layers/setting/SettingLayer").new()
        isOpen = true
        -- g_msgHandlerInst:sendNetDataByTableExEx(DIGMINE_CS_SIMULATION_ENTER, "DigMineSimulationEnter", {});

    end,
    a143 = function()
    end,
    a144 = function()
        --悬赏任务人
        __GotoTarget({ ru = "a129", Value = 13 } )
    end,
	
	a145 = function()
        --药品商城
        sub_node = require("src/layers/shop/shopLayer").new( { shop = 14, title = true } )
        isOpen = true
    end,
    a146 = function()
        --问卷调查
        sub_node = require("src/layers/activity/Questionnaire").new( { index = params.idx } )
    end,
    a147 = function()
        --进入未知暗殿
        g_msgHandlerInst:sendNetDataByTableExEx(UNDEFINED_CS_JOIN, "UndefinedJoin", {});
        --g_msgHandlerInst:sendNetDataByFmtExEx(UNDEFINED_CS_JOIN, "i", userInfo.currRoleId)
    end,
    a148 = function()
        --领取美酒
        g_msgHandlerInst:sendNetDataByTableExEx(3800, "GetWineProtocol", {})
    end,
    a149 = function()
        --申请成为天下第一
        g_msgHandlerInst:sendNetDataByTableExEx(RANK_CS_NO1, "RankNo1Protocol", {})
    end,
    a150 = function()
        --我的问题
        sub_node = require("src/layers/setting/myQuestion").new()
    end,
	a151 =function()
        --勇闯炼狱NPC
        __GotoTarget({ ru = "a129", Value = 9 } )
        isOpen = true
    end,
    a152 =function()
        --勇闯炼狱远点界面
        sub_node = require("src/layers/carry/CarryLayer").new({ farAway = true })
        isOpen = true
    end,
    a153 =function()
        --王城赐福NPC
        __GotoTarget({ ru = "a129", Value = 8 } )
        isOpen = true
    end,
    -- a154 =function()
    -- end,
    -- a155 =function()
    -- end,
    a156 =function(t)
        --装备打造
        local ret = require("src/layers/equipment/equipMake").new({ protoId = t.protoId, q_sort = 1 })
        if not ret then
            return
        end
        sub_node = ret
		sub_node:setPosition(g_scrCenter)
		Mnode.swallowTouchEvent(sub_node)
        isOpen = true
    end,
    a157 =function()
        __GotoTarget( { ru = "a129", Value = 10, notFly = true} )
    end,
    a158 = function()
        if NewFunctionIsOpen(NF_FRIEND) then
            sub_node = require("src/layers/friend/MasterAndSocialLayer").new()
            isOpen = true
        end
    end,
    a159 = function()

        sub_node = require("src/layers/battle/CellLayer").new( "MXWK" )
        isOpen = true
    end,
    a160 = function()
        g_msgHandlerInst:sendNetDataByTableExEx(DIGMINE_CS_JOIN, "DigMineJoin", {})    
    end,
    a161 = function()
        g_msgHandlerInst:sendNetDataByTableExEx(DIGMINE_CS_EXCHANGE, "DigMineExchange", {})
    end,
	a162 = function()	-- 远古宝藏
		sub_node = require("src/layers/teamTreasureTask/teamTreasureTaskIntroduce").new()
        isOpen = true
	end,
    a163 = function()
        --主界面下面按钮的二级按钮---装备传承
        sub_node = require("src/layers/equipment/equipInherit").new({})
        if sub_node then
            sub_node:setPosition(g_scrCenter)
            SwallowTouches(sub_node)
            isOpen = true
        end
    end,
    a164 = function()
        --主界面下面按钮的二级按钮--装备强化
        -- if G_NFTRIGGER_NODE:isFuncOn(NF_STRENGTHEN) then
        if NewFunctionIsOpen(NF_STRENGTHEN) then
            sub_node = require("src/layers/equipment/equipStrengthen").new({})
            if sub_node then
                sub_node:setPosition(g_scrCenter)
                SwallowTouches(sub_node)
                isOpen = true
            end
        end
    end,
    a165 = function()
        --主界面下面按钮的二级按钮--装备祝福
        -- if G_NFTRIGGER_NODE:isFuncOn(NF_BLESS) then
        if NewFunctionIsOpen(NF_BLESS) then
            sub_node = require("src/layers/equipment/equipWish").new({})
            if sub_node then
                sub_node:setPosition(g_scrCenter)
                SwallowTouches(sub_node)
                isOpen = true
            end
        end
    end,
    a166 = function()
        --主界面下面按钮的二级按钮--装备洗练
        -- if G_NFTRIGGER_NODE:isFuncOn(NF_WASH) then
        if NewFunctionIsOpen(NF_WASH) then
            sub_node = require("src/layers/equipment/equipRefine").new({})
            if sub_node then
                sub_node:setPosition(g_scrCenter)
                SwallowTouches(sub_node)
                isOpen = true
            end
        end
    end,
    a167 = function(__params)
        --主界面下面按钮的二级按钮--社交
        if NewFunctionIsOpen(NF_FRIEND) then
            sub_node = require("src/layers/friend/SocialNode").new(__params.index)
            isOpen = true
        end
    end,
    a168 = function()
        --主界面下面按钮的二级按钮--师徒
        if require("src/layers/role/RoleStruct"):getAttr(ROLE_LEVEL) >= 19 then
            sub_node = require("src/layers/friend/MasterAndSocialLayer").new()
            isOpen = true
        end
    end,
    a169 = function()
        --主界面下面按钮的二级按钮--行会
        if NewFunctionIsOpen(NF_FACTION) then
            if G_FACTION_INFO.facname and G_FACTION_INFO.id > 0 then
                sub_node = require("src/layers/faction/FactionLayer").new()
                --self:addChild(layer,200,100+index)
                isOpen = true
            else
                sub_node = require("src/layers/faction/FactionCreateAndListLayer").new()
                --self:addChild(layer,200,100+index)
                isOpen = true
            end
        else
            TIPS({type=1, str=string.format(game.getStrByKey("func_unavailable_lv"), 19)})
        end
    end,
    a170 = function()
        --跳转到世界频道
        local chatLayer = getRunScene():getChildByTag(305)
        if not chatLayer then
            chatLayer = require("src/layers/chat/Chat").new(0)
            G_MAINSCENE.chatLayer = chatLayer
            G_MAINSCENE.base_node:addChild(chatLayer)
            chatLayer:setLocalZOrder(200)
            chatLayer:setTag(305)
            chatLayer:setAnchorPoint(cc.p(0, 0))
            chatLayer:setPosition(cc.p(0, 0))
            chatLayer:selectTab(2)
        else
            chatLayer:show()
            chatLayer:selectTab(2)
        end
        isOpen = true
    end,
    a171 = function()
        sub_node = require("src/net/NetSimulation").new()
        isOpen = true
    end,
	a172 = function()	-- 3V3竞技场

		local ILevel = MRoleStruct:getAttr(ROLE_LEVEL)
		if ILevel == nil or ILevel < 30 then
			TIPS({type=1, str=string.format(game.getStrByKey("activity_begain_atLev"), 30)})
		else
			sub_node = require("src/layers/skyArena/skyArenaLayer").new()
			isOpen = true
		end
	end,
    a173 = function()
        --行会使者
        if NewFunctionIsOpen(NF_FACTION) and  G_FACTION_INFO.facname and G_FACTION_INFO.id > 0 then
            __GotoTarget({ru = "a129", Value = 15 })
        else
            TIPS( { type=1 , str = game.getStrByKey("join_faction_tips") } )
        end
    end ,
    a174 = function()
        --行会入侵
        g_msgHandlerInst:sendNetDataByTableExEx(FACTION_INVADE_CS_GET_FACTION, "FactionInvadeGetFactionReq", {})
    end,
    a175 = function()
        --行会上香
        sub_node = require("src/layers/faction/FactionLayer").new(2, 1, true)
        isOpen = true
    end,
    a176 = function()
        --行会副本（行会Boss）
        if NewFunctionIsOpen(NF_FACTION) and G_FACTION_INFO.facname and G_FACTION_INFO.id > 0 then
            sub_node = require("src/layers/faction/FactionLayer").new(2, 3, true)
            isOpen = true
        else
            TIPS( { type=1 , str = game.getStrByKey("join_faction_tips") } )
        end
    end,
    a177 = function()
        --行会商店
        sub_node = require("src/layers/faction/FactionLayer").new(2, 2, true)
        isOpen = true
    end,
    a178 = function()
        --行会外交
        sub_node = require("src/layers/faction/FactionLayer").new(2, 5, true)
        isOpen = true
    end,
    a179 = function()
        --行会活动
        log("a179")
        -- sub_node = require("src/layers/faction/FactionLayer").new(4, nil, true)
        -- isOpen = true
    end,
    a180 = function()
        --行会任务
        if NewFunctionIsOpen(NF_FACTION) and G_FACTION_INFO.facname and G_FACTION_INFO.id > 0 then
            sub_node = require("src/layers/faction/FactionLayer").new(4, 1, true)
            isOpen = true
        else
            TIPS( { type=1 , str = game.getStrByKey("join_faction_tips") } )
        end

    end,
    a181 = function()
        --行会旗帜
        log("a181")
        sub_node = require("src/layers/faction/FactionLayer").new(2, 4, true)
        isOpen = true
    end,
	
	a182 = function()
        --书店商城
        --sub_node = require("src/layers/shop/shopLayer").new({ shop = 19, title = true })
		local oBlackPanel = GetBlackMarketCtr():openBookMarket()
        -- if oBlackPanel then
        --     sub_node = oBlackPanel:GetUIRoot()
        -- end
		isOpen = true
    end,

    a183 = function()
        --行会入侵界面
        --package.loaded["src/layers/faction/FactionInviteListView"] = nil
        sub_node = require("src/layers/faction/FactionInviteListView").new(params.data)
        isOpen = true
    end,
        
    a184 = function(__params)
        --仙翼技能
        if G_WING_INFO and table.nums(G_WING_INFO) > 0 then
            if __params and __params.jnChoose then
                sub_node = require("src/layers/skill/SkillsLayer").new(2,__params.jnChoose)
            else
                sub_node = require("src/layers/skill/SkillsLayer").new(2)
            end
            isOpen = true
        else
            local cfg = getConfigItemByKeys( "BranchDB" , "q_taskid" )[ 51005]
            TIPS( { type = 1 , str = string.format(game.getStrByKey( "func_unavailable_wing" ) , cfg["q_accept_needmingrade"] ,cfg["q_name"]) } )
        end
    end,
	
	a185 = function()
        --主界面下面按钮的二级按钮--装备点金
        --if G_NFTRIGGER_NODE:isFuncOn(NF_GOLD) then
        if NewFunctionIsOpen(NF_GOLD) then
            sub_node = require("src/layers/equipment/equipGold").new({})
            if sub_node then
                sub_node:setPosition(g_scrCenter)
                SwallowTouches(sub_node)
                isOpen = true
            end
        end
    end,
	
	a186 = function()
        --主界面下面按钮的二级按钮--物品合成
        tempIndex = require("src/config/CommDef").PARTIAL_TAG_EQUIP_MAKE_DIALOG_TEMP
        sub_node = require("src/layers/equipment/equipMake").new({ q_sort = 2 })
		sub_node:setPosition(g_scrCenter)
		Mnode.swallowTouchEvent(sub_node)
        isOpen = true
    end,
    a187 = function (__params)
        --结义传送
        sub_node = require("src/layers/jieyi/JieYiTransform").new(__params.skillId)
        isOpen = true
    end,
    a188 = function (__params)
        --结义召唤
        require("src/layers/jieyi/JieYiZhaoHuan").onSkillZHClick(__params.skillId)
    end,
    a189 = function()
        --黑市商人npc
        __GotoTarget({ru = "a129", Value = 17 })
    end,
    a190 = function()
        --七日盛典
            -- DATA_Activity.CData = { modelID = DATA_Activity.weekList["modelID"], activityID = DATA_Activity.weekList["activityID"] } 
            if DATA_Activity.riteData and DATA_Activity.riteData.cellData then
                sub_node = require("src/layers/activity/riteLayer").new()
                isOpen = true
            end
    end,
    a191 = function()
        --书店老板
        __GotoTarget({ru = "a129", Value = 18 })
    end,
    a192 = function(params)
        -- 3V3 战队管理员
        if NewFunctionIsOpen( NF_BATTLE )  then
            __GotoTarget({ ru = "a129", Value = 19})
            isOpen = true
        end
    end,
    a193 = function()
        --传世宝典（套装）
        sub_node = require("src/layers/dictionary/catalog").new(3)
        isOpen = true
    end,
    a194 = function()
        local targetPage = require("src/layers/targetAwards/targetAwards").new()
        targetPage:setPosition(cc.p(display.width/2, display.height/2))
        G_MAINSCENE.base_node:addChild(targetPage,200)
        isOpen = true
    end,
    a200 = function( ... )
        -- body
        GetBlackMarketCtr():openBlackMarket()
    end,
    a201 =function(t)
        --装备合成
        local ret = require("src/layers/equipment/equipMake").new({ protoId = t.protoId, q_sort = 2 })
        if not ret then
            return
        end
        sub_node = ret
        sub_node:setPosition(g_scrCenter)
        Mnode.swallowTouchEvent(sub_node)
        isOpen = true
    end,
    a202 =function(t)
        --远古宝藏界面
        require("src/layers/teamTreasureTask/teamTreasureTaskStart").new()
    end,
    a203 =function(t)
        --远古宝藏NPC
        __GotoTarget({ ru = "a129", Value = 11 })
    end,
    a204 = function(params)
        -- 日常活动界面的 3V3
        if NewFunctionIsOpen( NF_BATTLE )  then
            -- 只发送这一条协议，由服务器判断应该显示哪一个界面，如果返回海选赛协议就显示海选赛界面，如果返回决赛协议，就显示决赛界面
            g_msgHandlerInst:sendNetDataByTable(FIGHTTEAM3V3_CS_GETAUDITIONDATA, "FightTeam3vGetAuditionDataProtocol", {})
        end
    end,
    a205 = function()   -- NPC 3V3 组建战队
        if NewFunctionIsOpen(NF_BATTLE)  then
            temp_node = require("src/layers/VS/VSCreateTeamNode").new();
            isOpen = true
        end
    end,
    a206 = function()   -- 3V3 战队界面
        --不考虑任务完成条件
		--入口未开
        if not NewFunctionIsOpen(NF_BATTLE) then
            return
        end
        if MRoleStruct:getAttr(PLAYER_FIGHT_TEAM_ID) == 0 then
            TIPS({str = game.getStrByKey("p3v3_tip_get_team_info_failed_no_team")})

            local tmpNpcId = require("src/config/CommDef").NPC_ID_WARBAND_MANAGER;
            local tmpNpcCfg = getConfigItemByKey("NPC", "q_id",  tmpNpcId)
            if tmpNpcCfg and __TASK then
                -- --寻路前往  
                local handlerFun = function()                                          
                    require("src/layers/mission/MissionNetMsg"):sendClickNPC(tmpNpcId)
                end   
                        
                local tarAddr = { mapid = tonumber(tmpNpcCfg.q_map) , x = tonumber(tmpNpcCfg.q_x) , y = tonumber(tmpNpcCfg.q_y) , handlerFun = handlerFun }

                __removeAllLayers()                                    
                local tempData = { targetType = 4 , mapID = tarAddr.mapid ,  x = tarAddr.x , y = tarAddr.y , callFun = tarAddr.handlerFun }
                __TASK:findPath( tempData )
            end

            return
        end
        sub_node = require("src/layers/VS/VSTeamLayer").new()
        tempIndex = require("src/config/CommDef").PARTIAL_TAG_3V3_TEAM_INFO_DIALOG
        isOpen = true
    end,
    a207 = function()
        --远古宝藏(说明页面)
        gotoActivityDescUI("a207")
    end,
    a208 = function()
        --冒险挖矿(说明页面)
        gotoActivityDescUI("a208")
    end,
    a209 = function()
        --通天塔(说明页面)
        gotoActivityDescUI("a209")
    end,
    a210 = function()
        --勇闯炼狱(说明页面)
        gotoActivityDescUI("a210")
    end,
    a211 = function()
        --怪物攻城(说明页面)
        gotoActivityDescUI("a211")
    end,
    a212 = function()
        --镖车护送(说明页面)
        gotoActivityDescUI("a212")
    end,    
    a213 = function()
        --屠龙传说(说明页面)
        gotoActivityDescUI("a213")
    end,
    a214 = function(t)
        --仙翼培养
        if G_WING_INFO.id and G_WING_INFO.id > 0 then
            sub_node = require("src/layers/wingAndRiding/WingAndRidingAdvanceNode").new(t.params)
            isOpen = true
        else
            local cfg = getConfigItemByKeys( "BranchDB" , "q_taskid" )[ 51005]
            TIPS( { type = 1 , str = string.format(game.getStrByKey( "func_unavailable_wing" ) , cfg["q_accept_needmingrade"] ,cfg["q_name"]) } )
        end
    end,
    a215 = function()
        --练功房
        g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_ENTERCOPY, "EnterCopyProtocol",{copyId = 7001})
    end,
    a216 = function()
        --全民宝地
        __GotoTarget({ru = "a129", Value = 20})
    end,
    a217 = function()
        sub_node = require("src/layers/battle/QmbdLayer").new()
        isOpen = true    
    end,
    a218 = function()
        -- 进入宝地
        local MRoleStruct = require("src/layers/role/RoleStruct")
        local roleLv = MRoleStruct:getAttr(ROLE_LEVEL)

        if roleLv and roleLv >= 32 then
            if not G_MAINSCENE.map_layer.isfb then
                g_msgHandlerInst:sendNetDataByTableExEx(TREASURE_CS_JOIN, "TreasureJoinProtocol", {}) 
            else
                TIPS({type = 1 , str = game.getStrByKey("carry_tip_unavailable")})
            end
        else
            TIPS( {str = string.format(game.getStrByKey("lv3", 32)) })
        end
    end,
    a219 = function()
        --练功房2，
        g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_ENTERCOPY, "EnterCopyProtocol",{copyId = 7002})
    end,
    a220 = function()
        --灵兽祭祀
        sub_node = require("src/layers/wingAndRiding/RidingSacrificeNode").new()
    end,
    a221 = function(__params)
        --潘多拉SDK消息showDialog
        require("src/PandoraFunction")
        PandoraShowDialog(__params.flag)
    end,
    a222 = function()
        --迷仙阵
        g_msgHandlerInst:sendNetDataByTable(MAZE_CS_DATA_REQ, "EnterMazeReq", {})
        isOpen = true
    end,

        -- 挖矿完成
    a223 = function()
        if G_MAINSCENE and G_MAINSCENE.map_layer  then 
            g_msgHandlerInst:sendNetDataByTableExEx(DIGMINE_CS_SIMULATION_FINISH, "DigMineSimulationFinish", {})
            -- addFBTipsEffect(G_MAINSCENE, cc.p(480, 320), "res/fb/win_2.png")
            if G_MAINSCENE.map_layer.exitFbTimeStart then
                G_MAINSCENE.map_layer:exitFbTimeStart()
            end
            -- if G_MAINSCENE.map_layer.showRobMineResult then
            --     local robMineEndData = {}
            --     robMineEndData.isWin = false
            --     G_MAINSCENE.map_layer:showRobMineResult(robMineEndData,0)
            -- end

            -- G_MAINSCENE.storyNode:exitStoryRobMine(true)
        end
    end,
    a224 = function()
        --公平竞技场报名
        sub_node = require("src/layers/skyArena/skyArenaLayerEnroll").new();
    end,
    a225 = function()
        --公平竞技场(说明页面)
        gotoActivityDescUI("a225")
    end,    
    a226 = function()
        --多人守卫(说明页面)
        gotoActivityDescUI("a226")
    end,
    a227 = function()
        --全民宝地(说明页面)
        gotoActivityDescUI("a227")
    end,
    a228 = function()
        --迷仙阵(说明页面)
        gotoActivityDescUI("a228")
        isOpen = true
    end,
    a229 = function()
        --点击迷仙阵npc对话
        G_MAINSCENE.map_layer:process_chat_request()
    end,
    a230 = function()
        __GotoTarget({ ru = "a129", Value = 21})
    end,
}


function __GotoTarget( __params )
    if G_ROLE_MAIN == nil then return end --数据异常 不再响应
	-- 加强代码防御能力
    if type(__params) ~= "table" or type(__params.ru) ~= "string" then
        if TIPS( getConfigItemByKeys("clientmsg",{"sth","mid"},{1,-1})  ) then return end  
    end
	
	-- 修正策划在配置字符串时前后加空格的问题
	__params.ru = string.mytrim(__params.ru)
	
    params = __params
    sub_node = nil
    temp_node = nil
    tempIndex = 0
    isOpen = false
    __RemoveTargetTab(__params.ru)
    if __params.ru and _gotoSwitchFun[ __params.ru ] then
        _gotoSwitchFun[ __params.ru ](__params)
        
        if sub_node and not sub_node:getParent() then
            getRunScene():addChild(sub_node,200,100 + tempIndex )
        end

        local parent_node = sub_node or temp_node
        if parent_node then
            parent_node:setName(targetMapName(__params.ru))
        end
    end

    return sub_node,isOpen
end
