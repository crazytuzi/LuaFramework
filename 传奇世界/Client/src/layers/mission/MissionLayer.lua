--[[ 任务界面 ]]--
local M = class( "MissionLayer" , function() return cc.Node:create() end  )
local MRoleStruct = require("src/layers/role/RoleStruct")
local tableIndex = 1         --默认激活table
local ActiveLayer = nil     --当前激活页面

local targetData = nil      --任务目标数据

local isOpen = false        --是否打开任务界面
local no_task = {}
local mainFlagUpdata = nil

function M:ctor( params )
    params = params or {}
    tableIndex = params.index or 1    --激活按钮

    local parent = params.parent
    parent:addChild( self,107)

    require("src/layers/mission/MissionData"):init()
    targetData = nil
    local MissionNetMsg =  require("src/layers/mission/MissionNetMsg").new( parent )

    local offY = 70 + 44 + 15
    local width  = 250
    local height  =  220 - offY + 15

    local scrollView1 = cc.ScrollView:create()
    self.scrollView1 = scrollView1
    local function scrollView1DidScroll() if __TASK and __TASK.startRecordOffPos  then __TASK.startRecordOffPos = scrollView1:getContentOffset() end end
    local function scrollView1DidZoom() end
    scrollView1:setViewSize(cc.size( width , height ))
    scrollView1:setPosition( cc.p( 0 ,  display.cy - 70 + offY ) )
    scrollView1:ignoreAnchorPointForPosition(true)
    scrollView1:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL )
    scrollView1:setClippingToBounds(true)
    scrollView1:setBounceable(true)
    scrollView1:setDelegate()
    scrollView1:registerScriptHandler(scrollView1DidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL)
    scrollView1:registerScriptHandler(scrollView1DidZoom,cc.SCROLLVIEW_SCRIPT_ZOOM)
   
    self:addChild(scrollView1)

    if self.mainFlag then
        removeFromParent(self.mainFlag)
    end
    self.mainFlag = self:createMainIcon()
    scrollView1:setContainer( self.mainFlag )
    self.mainFlag:setVisible( G_CONTROL:isFuncOn( GAME_SWITCH_ID_TASK ) )
    scrollView1:addSlider( "res/common/slider1.png", false )
    mainFlagUpdata = function(  )
        local offset = scrollView1:getContentOffset()
        scrollView1:updateInset()

        if __TASK and __TASK.startRecordOffPos then
            scrollView1:setContentOffset( __TASK.startRecordOffPos )
        else
            local layerSize = self.mainFlag:getContentSize()
            -- if layerSize.height < height then
                scrollView1:setContentOffset( cc.p( 0 ,   -( layerSize.height - height ) ) )
            -- end
        end
    end
    -- 先获取更新数据
    self.mainFlag:refreshData();
    mainFlagUpdata();

    DATA_Mission:setCallback( "main_flag" , function() 
            self.mainFlag:refreshData()  
        end )

end

function M:getMainIcon()
  return self.mainFlag
end


--根据任务状态数据判断需要跳转的地址
function M:__CreateTag( itemData )
    local tempData = {}
    if itemData.isEnd and itemData.q_endnpc then
        --转查提交NPC
        tempData = __NpcAddr( itemData.q_endnpc )
        tempData.targetType  = 1 
        tempData.q_endnpc  = itemData.q_endnpc 
    elseif itemData.isBegin and itemData.q_startnpc then
        --转查接取NPC
        tempData = __NpcAddr( itemData.q_startnpc )
        tempData.targetType  = 1 
        tempData.q_endnpc  = itemData.q_startnpc 
    else
        --正常查找
        tempData = itemData
    end
    return tempData
end

--是否隐藏左侧按钮
function M:hideIcon( _bool )
	self.mailBool = false
	if self.mainFlag then
		if G_CONTROL:isFuncOn( GAME_SWITCH_ID_TASK ) then
			self.mailBool = not _bool
		end
	end
	self.mainFlag:setVisible( self.mailBool )
	self.scrollView1:setVisible( self.mailBool )
end

--检查是否需要飞行靴
function M:portalGo( tempData , isNoPlot , isTask ,no_remove )
    if isTask then
        game.setAutoStatus( AUTO_PATH )
        DATA_Mission:setAutoPath(true)
    end
    local isHaveShoes = false       --是否存在飞行靴
    if tempData.q_done_event and tonumber( tempData.q_done_event ) ~= 0 then return end
    if tempData.q_done_event and tonumber( tempData.q_done_event ) == 0  or isNoPlot then
        local map_id = tempData.targetData.mapID
        local tar_x,tar_y = tempData.targetData.pos[1].x ,  tempData.targetData.pos[1].y
        local suiji = not not tempData.is_suiji
        local resetInfoFunc = function()
            if tempData.finished == 6 then
                local itemData = getConfigItemByKeys( "NPC" , "q_id" )[tempData.isBan and tempData.q_startnpc or  tempData.q_endnpc] 
                map_id = itemData.q_map 
                tar_x = itemData.q_x 
                tar_y = itemData.q_y
            else
                map_id = tempData.targetData.mapID
                tar_x = tempData.targetData.pos[1].x 
                tar_y = tempData.targetData.pos[1].y
            end
        end
        resetInfoFunc()
        if G_MAINSCENE.map_layer:isHideMode() and G_MAINSCENE.mapId ~= 6017 then--行会驻地需要特殊处理
            TIPS( getConfigItemByKeys("clientmsg",{"sth","mid" } , { 17000 , -7 } )  )
            return
        elseif tonumber(getConfigItemByKey("MapInfo","q_map_id",map_id,"xianzhi")) == 1  then
            TIPS( getConfigItemByKeys("clientmsg",{"sth","mid" } , { 17000 , -7 } )  )
            return
        elseif map_id == G_MAINSCENE.mapId then
            if G_MAINSCENE.map_layer and G_ROLE_MAIN and G_ROLE_MAIN.tile_pos then
                local distance = cc.pGetDistance(cc.p(tar_x , tar_y),G_ROLE_MAIN.tile_pos)
                if distance < 20 then
                    TIPS( { type = 1 , str = game.getStrByKey( "too_near_tip" ) } )
                    if not no_remove then 
                        local temp_Data = { targetType = 4 , mapID = map_id,  x = tar_x, y = tar_y , callFun = G_MAINSCENE._removeFunc }
                        self:findPath( temp_Data )
                       __removeAllLayers()
                    end
                    return 
                end
            end
        end

        local doCheckData = function()
           local transformation = self:__CreateTag( tempData )
           for k , v in pairs( transformation ) do
                tempData[k] = v 
           end
           resetInfoFunc()
           if tempData.remvoeFun then tempData.remvoeFun() end
            if isTask then
                DATA_Mission:setTempFindPath( tempData )
            end
          --检测飞鞋点是否为传送圈点
            local transfor = getConfigItemByKey("HotAreaDB","q_id")
            for k,v in pairs(transfor) do
                if v.q_mapid == map_id and 
                    v.q_x == tar_x and v.q_y == tar_y then
                    tar_x= tar_x - 1
                    break
                end
            end
        end
        local popupTip = function()
            local ispay = function()
                doCheckData()
                if isTask or no_remove then 
                    DATA_Mission.isStopFind = false 
                else
                    DATA_Mission:setAutoPath(false)
                    DATA_Mission.isStopFind = true  
                end
                if not no_remove then 
                    __removeAllLayers( map_id ~= G_MAINSCENE.map_layer.mapID , tempData.callback )
                end
                local shoes = "{mapID="..map_id..",posX="..tar_x..",posY="..tar_y.."}"
                -- g_msgHandlerInst:sendNetDataByFmtExEx(TRADE_CS_SPE_TRADE, "iiSb", G_ROLE_MAIN.obj_id , 1 , shoes,suiji)
                g_msgHandlerInst:sendNetDataByTableExEx(TRADE_CS_SPE_TRADE, "SpeTradeProtocol", {["buyParam"] = 1, ["addParam"] = shoes } )

                if G_MAINSCENE and G_MAINSCENE.map_layer then
                    G_MAINSCENE.map_layer:cleanAstarPath(true,true)    
                end  
            end
            MessageBoxYesNo(nil,game.getStrByKey("pay_transmit") , function() checkIfSecondaryPassNeed( ispay ) end )
        end

        local pack = MPackManager:getPack(MPackStruct.eBag)
        local num = pack:countByProtoId(1001)

        if num <= 0 then
            isHaveShoes = false
            if not tempData.noTipShop then
                popupTip()
            end
        else
            isHaveShoes = true
            doCheckData()   
            --g_msgHandlerInst:sendNetDataByFmt(FRAME_CS_SEND_TO, "isssb", G_ROLE_MAIN.obj_id , map_id, tar_x, tar_y ,suiji)
            g_msgHandlerInst:sendNetDataByTable(FRAME_CS_SEND_TO, "FrameSendToProtocol", {mapID=map_id,x=tar_x, y=tar_y})
            if G_MAINSCENE and G_MAINSCENE.map_layer then
                G_MAINSCENE.map_layer:cleanAstarPath(true,true)    
            end   
        end
    else
        self:findPath( tempData )
    end
    

    return isHaveShoes
end

function M:createMainIcon()
    local node = cc.Node:create()   
    node:setLocalZOrder(-1)
    local gatherData , items = {} , {}   
    self.gatherData = gatherData
    local height = -45
    local itemHeight = 56
    local keys = { "wing" , "plot" , "dart" , "every" , "rewardTask" , "branch" , "share", "wedding" }
    local function checkStr( curData )
        local str = ""
        if curData.q_accept_needmingrade then
            if MRoleStruct:getAttr(ROLE_LEVEL) and MRoleStruct:getAttr(ROLE_LEVEL) < tonumber(curData.q_accept_needmingrade)  then
                str = curData.q_accept_needmingrade .. game.getStrByKey( "ji" )
            end
        end
        return str
    end

    local function createIconCell( key )
        local group = cc.Node:create()
        if key ~= "plot" then group:setVisible( false ) end

        local textCfg = { wing = "task_wing" , plot = "task_main" , dart = "task_dart" , every = "task_every" , branch = "task_branch" , rewardTask = "task_crusade" , share = "task_share" }
        local curData = gatherData[key]
        local  function clickFun()
            if __TASK and __TASK:isVisible() then
                local curData = gatherData[key]
                if curData then

                    local _tempData = {} 
                    for key , v in pairs( curData ) do 
                        _tempData[ key ] = v 
                    end 
                    _tempData.isClick = true 
                    local isFinish = false
                    if curData then
                        if curData.finished and ( curData.finished == 6 ) then
                            isFinish = true
                        else
                            if curData.targetData and curData.targetData.cur_num then
                                if curData.targetData.cur_num >= ( curData.targetData.count or 0 ) then
                                    isFinish = true
                                end
                            end
                        end
                    end

                    if key == "plot" and checkStr( curData ) ~= "" then
                        --主线任务 等级不满足
                        if MRoleStruct:getAttr(ROLE_LEVEL) <= 28 and MRoleStruct:getAttr(ROLE_LEVEL) >= 22 then
                            if G_TUTO_DATA then
                                -- for k,v in pairs(G_TUTO_DATA) do
                                --     if v.q_id == 409 then
                                --         -- if v.q_state == TUTO_STATE_HIDE then
                                --         --     v.q_state = TUTO_STATE_OFF
                                --         -- end
                                --         G_TUTO_NODE:checkTuto(v)
                                --     end
                                -- end
                                tutoShow(409)
                            end
                        end 
                         if MRoleStruct:getAttr(ROLE_LEVEL) <= 31 and MRoleStruct:getAttr(ROLE_LEVEL) >= 28 then
                            if G_TUTO_DATA then
                                -- for k,v in pairs(G_TUTO_DATA) do
                                --     if v.q_id == 419 then
                                --         -- if v.q_state == TUTO_STATE_HIDE then
                                --         --     v.q_state = TUTO_STATE_OFF
                                --         -- end
                                --         G_TUTO_NODE:checkTuto(v)
                                --     end
                                -- end
                                tutoShow(419)
                            end
                        end              
                    end

                    if key == "every" and  isFinish  then
                        __GotoTarget( {ru = "a1"} )
    				elseif key == "share" then
    					require("src/layers/teamTreasureTask/teamTreasureTaskLayer"):onClickTaskPanel(curData)
    				elseif key == "dart" then
                        local dartData = DATA_Mission.DART_STATIC
                        if dartData.hasReward then
                            __GotoTarget( { ru = "a19" } )
                        else
                            G_MAINSCENE.map_layer:cleanAstarPath(true,true)
                            game.setAutoStatus(0)

                            performWithDelay( self , function()
                                game.setAutoStatus(AUTO_MATIC)
                                if G_MAINSCENE then G_MAINSCENE.dart_pos = nil end
                                g_msgHandlerInst:sendNetDataByTableExEx(DART_CS_POSITION, "DartPositionProtocol", {} )
                            end , 0.1 )
                        end
                    elseif key == "wedding" then
                        local wsCommFunc = require("src/layers/weddingSystem/WeddingSysCommFunc")
                        wsCommFunc.taskClickCallBack()
                    else
                        if _tempData.q_link and isFinish == false then
                            __GotoTarget( { ru = _tempData.q_link } )
                        else
                            if curData.q_accept_needmingrade and MRoleStruct:getAttr(ROLE_LEVEL) and MRoleStruct:getAttr(ROLE_LEVEL) < tonumber(curData.q_accept_needmingrade)  then
                                TIPS( { type = 1 , str = string.format( game.getStrByKey( "func_unavailable_noTask1" ) , curData.q_accept_needmingrade ) } )
                            else
                                self:findPath( _tempData ) 
                            end
                        end
                    end
                end
            end
        end

            local function regHandler( root )
                Mnode.listenTouchEvent(
                {
                    node = root,
                    swallow = true ,
                    begin = function(touch, event)
                        if __TASK and not __TASK:isVisible() then
                            return false
                        end
                        if DATA_Mission then DATA_Mission:setFindPath( true ) end --有点击操作，就一定是登陆就绪，可以支持密令自动寻路了
                        if gatherData[key] == nil then return false end--如果数据不存在 就直接返回

                        

                        local point = self.scrollView1:convertTouchToNodeSpace(touch)
                        if __TASK then __TASK.startRecordOffPos = cc.p( 0 , 0 )  end
                        if not Mnode.isPointInNodeAABB(self.scrollView1, point, self.scrollView1:getViewSize()) then
                            return false 
                        else
                            local node = event:getCurrentTarget()
                            node.isMove = false
                            local inside = Mnode.isTouchInNodeAABB(node, touch) and node:isVisible()

                            if inside and self.mainFlag and self.mainFlag:isVisible() then
                                node:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.ScaleTo:create(0.05,0.98)))
                                return true
                            end   
                        end
                        return false 
                    end,

                    moved = function(touch, event)
                        local node = event:getCurrentTarget()
                        if node.recovered then return end
                        local startPos = touch:getStartLocation()
                        local currPos  = touch:getLocation()
                        if cc.pGetDistance(startPos,currPos) > 5 then
                            node.isMove = true
                            node:stopAllActions()
                            node:runAction(cc.ScaleTo:create(0.05,1.0))
                        end
                    end,

                    ended = function(touch, event)
                      local node = event:getCurrentTarget()
                      if Mnode.isTouchInNodeAABB(node, touch) and not node.isMove then
                        AudioEnginer.playTouchPointEffect()
                        node:stopAllActions()
                        node:runAction(cc.Sequence:create(cc.ScaleTo:create(0.08,1.1),cc.ScaleTo:create(0.08,1.0)))
                        clickFun()
                      end
                    end,
                })
            end

        local colorCfg = { 
                    plot = MColor.yellow ,          --主线
                    dart = MColor.green ,         	--镖车
                    branch = MColor.green ,         --密令
                    wing = MColor.orange ,          --仙翼
                    every = MColor.orange ,         --诏令
                    rewardTask = MColor.purple ,    --悬赏
					share = MColor.deep_purple,		--共享
                 }


        -- local falgBg = createSprite( group,  "res/layers/mission/task_info_bg.png" , cc.p( 0 , 0 ), cc.p( 0 , 1 ))
        -- falgBg:setOpacity( 0 )
        
        local falgBg = cc.LayerColor:create( cc.c4b( 0, 0, 0 , 0 ) )
        falgBg:setContentSize( cc.size( 256 , itemHeight ) )
        setNodeAttr( falgBg , cc.p( 0 , -itemHeight ) , cc.p( 0 , 0 ) )
        group:addChild( falgBg )

        regHandler( falgBg )
        falgBg.effNode = cc.Node:create()
        falgBg:addChild( falgBg.effNode , 10 )
        local lineSp = createSprite( falgBg,  "res/common/split-2.png" , cc.p( 5 , falgBg:getContentSize().height ), cc.p( 0 , 1 ) )
        local isShowLine = false
        if gatherData[ keys[ 1 ] ] then
            if key ~= "wing" then isShowLine = true end
        else
            if key ~= "plot" then isShowLine = true end
        end
        lineSp:setVisible( isShowLine )

        local function addAward( curData , key )
            if curData == nil then return end
            if group.ringAward then removeFromParent( group.ringAward ) group.ringAward = nil end

            if curData.q_ring_award and curData.q_ring_award ~= 0 then
                local DropOp = require("src/config/DropAwardOp")
                local tempTable = DropOp:getUsadble( curData.q_ring_award )
                if #tempTable > 0  then
	                local callback = nil 
	                if key == "wing" then
	                    callback = function()
	                    	if self.mailBool then
                                if DATA_Mission:getTaskWing() then
	                        	  __TASK:showTaskWing( curData.q_name )
                                end
	                    	end
	                    end
	                end
	                group.ringAward = iconCell( { parent = group , iconID = tempTable[1].id , isTip = ( key ~= "wing" ) , effect = true , callback = callback , effect = true} )
	                setNodeAttr( group.ringAward , cc.p( 220 , -falgBg:getContentSize().height/2 ) , cc.p( 0.5 , 0.5 ) )
	                group.ringAward:setScale( 0.6 )
                end
            end
        end

        
        if key == "plot" then
            createSprite( falgBg,  "res/common/redTask.png" , cc.p( 5 , falgBg:getContentSize().height ), cc.p( 0 , 1 ))
        else
            createSprite( falgBg,  "res/common/blueTask.png" , cc.p( 5 , falgBg:getContentSize().height ), cc.p( 0 , 1 ))
        end

        local label_bg_node = createBatchRootNode(falgBg,18)
        local taskType =  createBatchLabel( label_bg_node , game.getStrByKey( textCfg[ key ] ) , cc.p( 10 ,  falgBg:getContentSize().height - 13 ) , cc.p( 0 , 0.5 ) , 18 , nil , nil , nil , colorCfg[key] , nil , nil )
        local labeltask = createBatchLabel( label_bg_node , "loading..." , cc.p( 70 ,  falgBg:getContentSize().height - 13 ) , cc.p( 0 , 0.5 ) , 18 , nil , nil , nil , colorCfg[key] , nil , nil )


        local typeStr = createBatchLabel( label_bg_node , "loading..." , cc.p( 10 ,  20 ) , cc.p( 0 , 0.5 ) , 18 , nil , nil , nil , MColor.lable_yellow , nil , nil )
        local labelstate = createBatchLabel( label_bg_node , "loading..." , cc.p( 70 , 20 ) , cc.p( 0 , 0.5 ) , 18 )

        local needLv = nil
        if key == "plot"  then
            needLv =  createBatchLabel( label_bg_node , "" , cc.p( 0 ,  falgBg:getContentSize().height - 13 ) , cc.p( 0 , 0.5 ) , 18 , nil , nil , nil , MColor.red , nil , nil )
        elseif key == "wing" then
            addAward( curData , key )
        end

        function group:iconRefresh()
            local isShowLine = false
            if gatherData[ keys[ 1 ] ] then
                if key ~= "wing" then isShowLine = true end
            else
                if key ~= "plot" then isShowLine = true end
            end
            lineSp:setVisible( isShowLine )

            curData = gatherData[ key ] 

            local createFinishEff = function( curData )
                local isComplete = false
                if curData then
                    if curData.hasReward or ( curData.finished and ( curData.finished == 6 ) ) then
                        isComplete = true
                    else
                        if curData.targetData and curData.targetData.cur_num then
                            if curData.targetData.cur_num >= ( curData.targetData.count or 0 ) then
                                isComplete = true
                            end
                        end
                    end
                end


                if isComplete then
                    local myLv = require("src/layers/role/RoleStruct"):getAttr(ROLE_LEVEL) or 0
                    local needMinLv = curData.q_accept_needmingrade or 1
                    if myLv >= needMinLv then
                        if falgBg[key .. "_eff" ] == nil then
                            falgBg[key .. "_eff" ] = Effects:create(false)
                            -- falgBg[key .. "_eff" ]:playActionData2("taskfinishshow", 200 , -1 , 0 )
                            falgBg[key .. "_eff" ]:playActionData2( "taskfinish0" .. ( key == "plot" and 1 or 2 ) , 160 , -1 , 0 )
                            setNodeAttr( falgBg[key .. "_eff" ] , cc.p( -12 , 8 ) , cc.p( 0 , 0 ) )
                            addEffectWithMode(falgBg[key .. "_eff" ],2)
                            falgBg.effNode:addChild(falgBg[key .. "_eff" ] )
                        end
                    else
                        if falgBg[key .. "_eff" ] then
                            removeFromParent( falgBg[key .. "_eff" ] )
                            falgBg[key .. "_eff" ] = nil 
                        end
                    end
                else
                    if falgBg[key .. "_eff" ] then
                        removeFromParent( falgBg[key .. "_eff" ] )
                        falgBg[key .. "_eff" ] = nil 
                    end
                end

            end


            
            if key ~= "plot" then group:setVisible( curData and true or false ) end
            no_task[key] = not curData
            if not curData then return end

            local str = { game.getStrByKey( "task_talk" ), game.getStrByKey( "task_collect" ) , game.getStrByKey( "task_kill" ) ,  game.getStrByKey( "task_complete" ), game.getStrByKey("taskCollect") }--对话 收集 击杀 完成 收集
            if key == "plot" then
                labeltask:setString( curData["q_name"] )
                
                local tagStr = ""
                if curData.q_done_event and tonumber( curData.q_done_event ) ~= 0 then
                    typeStr:setString( str[ 3 ] )
                    labelstate:setColor( MColor.blue )
                    tagStr = curData.q_task_desc 
                    if curData.q_speakID and tagStr == "" then
                        tagStr = getConfigItemByKey( "NPCSpeak" , "q_id" )[ curData.q_speakID ]["q_task_done"] 
                    end
                    if curData.q_word then
                        tagStr = curData.q_word
                    end

                    if curData.finished == 6 or ( curData.q_done_event == "36_1" and curData.finished == 2 ) then
                        local itemData = getConfigItemByKeys( "NPC" , "q_id" )[curData.q_endnpc]    
                        tagStr = itemData.q_name
                        labelstate:setColor( MColor.green )
                    end
                else
                    typeStr:setString( str[ curData.targetType ] )
                    

                    if curData.finished == 6 then
          	            local itemData = getConfigItemByKeys( "NPC" , "q_id" )[curData.q_endnpc]	
                        tagStr = itemData.q_name
                        labelstate:setColor( MColor.green )
                    else
                        local strName = curData.targetData["roleName"]
                        tagStr = strName .. ( curData.targetType == 1 and "" or "(" .. curData.targetData.cur_num  .. "/" .. curData.targetData.count .. ")"  )
                        labelstate:setColor( MColor.white )
                    end
                    typeStr:setString( curData.finished == 6 and str[4] or str[ curData.targetType ]  )

                end
                
                labelstate:setString(  tagStr )

                local function checkStr2()
                    local str = checkStr( curData )
                    if str ~= "" then
                        local stateWidth = labeltask:getContentSize().width or 0 
                        stateWidth = ( stateWidth == 0 and 50 or stateWidth )
                        local typeWidth = taskType:getContentSize().width or 0 
                        typeWidth = ( typeWidth == 0 and 50 or typeWidth )


                        setNodeAttr( needLv , cc.p( 40 + typeWidth + stateWidth , falgBg:getContentSize().height - 13  ) , cc.p( 0 , 0.5 ) )

                        if falgBg[key .. "_eff" ] then
                            removeFromParent( falgBg[key .. "_eff" ] )
                            falgBg[key .. "_eff" ] = nil 
                        end
                    end
                    return str
                end
                


                needLv:setString( checkStr2() )

                local  function cb()
                    local lvStr = checkStr2( curData )
                     needLv:setString( lvStr )
                     if lvStr == "" then createFinishEff( curData ) end
                end
                performWithDelay( self , cb , 1 )    --延时检测等级变化
            elseif key == "dart" then
                local dartData = DATA_Mission.DART_STATIC
                local modeCfg = { "bodyguard_team7" , "bodyguard_team8" , "bodyguard_team9" }
                local modeColor = { MColor.green , MColor.blue , MColor.purple }

                if dartData.modeid ~= 0 then
                    labeltask:setString( game.getStrByKey( modeCfg[dartData.modeid] ) .. game.getStrByKey( "bodyguard_team18" ) )
                    labeltask:setColor( modeColor[dartData.modeid] )
                    taskType:setColor( modeColor[dartData.modeid] )
                end

                typeStr:setString( game.getStrByKey( dartData.hasReward and "award" or "target" )  )

                labelstate:setString( game.getStrByKey( dartData.hasReward and "bodyguard_team35" or "bodyguard_team34" ) )
                labelstate:setColor( dartData.hasReward and MColor.green or MColor.white )

            elseif key == "every" then
                if curData.targetData then
                    labeltask:setString( curData.name )
     
                    labelstate:setString(curData.targetData["roleName"] .. ( "(" .. curData.targetData.cur_num  .. "/" .. ( curData.targetData.count or 0 ) .. ")") )
                    labelstate:setColor( curData.targetData.cur_num == curData.targetData.count and MColor.green or MColor.white )
                    
                    typeStr:setString( curData.targetData.cur_num == curData.targetData.count and str[4] or str[ curData.targetType ]  )
                end
            elseif key == "branch" or key == "wing" then
                -- --密令
                local tagStr = ""

                if curData.q_done_event and tonumber( curData.q_done_event ) ~= 0 then
                    typeStr:setString( str[ 3 ] )
                    labelstate:setColor( MColor.blue )
              
                    tagStr = curData.q_desc

                    if curData.targetData and curData.targetData.cur_num then
                        if curData.targetData.cur_num >= curData.targetData.count then
                            tagStr = curData.NpcName
                            typeStr:setString( str[ 4 ] )
                        else
                            tagStr = tagStr .. "(" .. curData.targetData.cur_num  .. "/" .. ( curData.targetData.count or 0 ) .. ")"
                        end
                        
                    end

                else
                    typeStr:setString( str[ curData.targetType ] )
                    if curData.targetData and curData.targetData.cur_num and ( curData.targetData.cur_num >= curData.targetData.count ) then
                        tagStr = curData.NpcName
                        labelstate:setColor( MColor.green )
                    else
                        local strName = curData.targetData["roleName"]
                        tagStr = strName .. ( curData.targetType == 1 and "" or "(" .. curData.targetData.cur_num  .. "/" .. curData.targetData.count .. ")"  )
                        labelstate:setColor( MColor.white )

                        typeStr:setString( curData.finished == 6 and str[4] or str[ curData.targetType ]  )
                    end
                end

                labelstate:setString(  tagStr )
                labeltask:setString( curData.name )
            elseif key == "rewardTask" then
                local tagStr = ""
                labeltask:setString( curData["q_name"] )

                typeStr:setString( str[ curData.targetType ] )

                if curData.finished == 6 then
      	            local itemData = getConfigItemByKeys( "NPC" , "q_id" )[curData.q_endnpc]	
                    tagStr = itemData.q_name
                else
                    local strName = curData.targetData["roleName"]
                    tagStr = strName .. ( curData.targetType == 1 and "" or "(" .. curData.targetData.cur_num  .. "/" .. curData.targetData.count .. ")"  )
                end
                labelstate:setString(tagStr)
                --这里使用了upvalue labeltask taskType, 因为本方法嵌套于createIconCell中
                local titleColor = 
                (
                    curData.q_rank == DATA_Mission.RewardTaskTypeEnum.JUINOR_TASK and MColor.green or
                    curData.q_rank == DATA_Mission.RewardTaskTypeEnum.SENIOR_TASK and MColor.blue or
                    MColor.purple
                )
                labeltask:setColor(titleColor)
                taskType:setColor(titleColor)
                
			elseif key == "share" then
                local titleColor = 
                (
                    curData.q_rank == 1 and MColor.green or
                    curData.q_rank == 2 and MColor.blue or
                    MColor.deep_purple
                )

                labeltask:setColor(titleColor)
				labeltask:setString(curData.name)
 
                taskType:setColor(titleColor)
				if curData.targetData.cur_num == curData.targetData.count then
					typeStr:setString(str[4])

					labelstate:setColor(MColor.green)

					local npcId = 10465
					local npcName = ""
					local getName = getConfigItemByKey("NPC", "q_id", npcId, "q_name")
					if getName then
						npcName = getName
					end
					local strGo = game.getStrByKey("share_task_go")
					local strContent = string.format(strGo, npcName)
					labelstate:setString(strContent)
				else
					typeStr:setString(str[3])

					labelstate:setColor(MColor.white)

					local monster_name = game.getStrByKey("treasure_guarder");
                    if curData.posData and curData.targetState and curData.targetCount then
                        for i = 1, #curData.posData do
                            -- 顺序开放
		                    if curData.targetState[i] < curData.targetCount[i] then
                                if curData.targetData and (i-1) <= curData.targetData.cur_num then
                                    local target_data = curData.posData[i]
		                            if target_data then
			                            monster_name = getConfigItemByKey("MapInfo", "q_map_id", target_data.map_id, "q_map_name")
                                        break;
                                    end
                                end
		                    end
	                    end
                    end
					local strContent = string.format(game.getStrByKey("week_go") .. "%s (%s/%s)", monster_name, curData.targetData.cur_num, curData.targetData.count)
					labelstate:setString(strContent)
				end
            elseif key == "wedding" then
                local wsCommFunc = require("src/layers/weddingSystem/WeddingSysCommFunc")
                taskType:setString( game.getStrByKey("task_wedding") )
                taskType:setColor(MColor.lable_yellow)
                labeltask:setString( wsCommFunc.getTaskLabel() )
                local typeContent,contentLabel = wsCommFunc.getTypeStrAndContent()
                typeStr:setString( typeContent )
                labelstate:setString( contentLabel)
            end

            addAward( curData , key )
            if key ~= "plot" and key ~= "wedding"  then createFinishEff( curData ) end
        end

        return group, falgBg
    end


    gatherData[ keys[1] ] = DATA_Mission:getTaskWing()                --仙翼
    gatherData[ keys[2] ] = DATA_Mission:getLastTaskData()                  --剧情

    local dartData = DATA_Mission and DATA_Mission.DART_STATIC or nil
    if dartData then
        gatherData[ keys[3] ] = ( ( dartData.hasReward or dartData.dart_state >= 3 ) and dartData or nil )                 --镖车
    else
        gatherData[ keys[3] ] = nil
    end


    gatherData[ keys[4] ] = DATA_Mission:getEveryData()                     --日常
    if gatherData[ keys[4] ] then 
        if gatherData[ keys[4] ].overEvery or gatherData[ keys[4] ].isOverLogin then 
            gatherData[ keys[4] ] = nil 
        end
    end

    gatherData[ keys[5] ] = DATA_Mission:GetRewardTaskData() and DATA_Mission:GetRewardTaskData()["hadTask"]  -- 新悬赏
    gatherData[ keys[6] ] = DATA_Mission:getLastBranch( "branch" )                                    -- 密令任务
	gatherData[ keys[7] ] = DATA_Mission:getShareData()			--共享
    local wsCommFunc = require("src/layers/weddingSystem/WeddingSysCommFunc")
    gatherData[ keys[8] ] = wsCommFunc.showWeddingMission()
    if G_MAINSCENE and G_MAINSCENE.taskLab then 
        local str = game.getStrByKey("task") .. "(" .. tablenums( gatherData ) .. ")" 
        G_MAINSCENE.taskLab:setString( str ) 
        G_MAINSCENE.taskLab1:setString( str ) 
    end

    local cellHight = itemHeight - 3
    local key_num = #keys
    local falgBg
    for i = 1 , key_num do
        items[ keys[i] ], falgBg = createIconCell( keys[i] )
        node:addChild( items[ keys[i] ] ,key_num - i )

        if  keys[i] == "plot" then items[ keys[i] ]:setLocalZOrder(20) end

        if i == 2 then
            G_TUTO_NODE:setTouchNode(falgBg, TOUCH_MAIN_TASK_GUIDE)
        elseif i == 3 then
            G_TUTO_NODE:setTouchNode(falgBg, TOUCH_MAIN_TASK_DAILY)
        elseif i == 4 then
            G_TUTO_NODE:setTouchNode(falgBg, TOUCH_MAIN_TASK_KILL)
        elseif i == 5 then
            G_TUTO_NODE:setTouchNode(falgBg, TOUCH_MAIN_REWARD_TASK)
        end
    end

    if G_MAINSCENE and G_MAINSCENE.taskBgChangeFun then G_MAINSCENE.taskBgChangeFun( key_num ) end

    function node:refreshData( params )
    	local oldNum = tablenums(gatherData)

        gatherData[ keys[1] ] = DATA_Mission:getLastBranch("wing")                    --仙翼
        gatherData[ keys[2] ] = DATA_Mission:getLastTaskData()                  --剧情
        local m_teamId = MRoleStruct:getAttr( PLAYER_TEAMID ) or 0

        local dartData = DATA_Mission and DATA_Mission.DART_STATIC or nil
        if dartData then
            gatherData[ keys[3] ] = ( ( dartData.hasReward or dartData.dart_state >= 3 ) and dartData or nil )                 --镖车
        else
            gatherData[ keys[3] ] = nil
        end

        

        gatherData[ keys[4] ] = DATA_Mission:getEveryData()                     --日常
        --完成日常提示框
        function everyOverFun()
            local curData = DATA_Mission:getEveryData() 
            if curData.isPopupEveryOver then return end
            curData.isPopupEveryOver = true
            Awards_Panel( {  award_tip = game.getStrByKey("every_over") , awards = curData.extraReward } )
            gatherData[ keys[4] ] = nil
        end
        if  gatherData[ keys[4] ] then
            if not gatherData[ keys[4] ].isOverLogin then
                if gatherData[ keys[4] ].overEvery then everyOverFun() end
            else
                gatherData[ keys[4] ] = nil 
            end
        end


        gatherData[ keys[5] ] = DATA_Mission:GetRewardTaskData() and DATA_Mission:GetRewardTaskData()["hadTask"]    -- 新悬赏
        gatherData[ keys[6] ] = DATA_Mission:getLastBranch("branch")                                    -- 密令任务
		gatherData[ keys[7] ] = DATA_Mission:getShareData()			--共享
        local wsCommFunc = require("src/layers/weddingSystem/WeddingSysCommFunc")
        gatherData[ keys[8] ] = wsCommFunc.showWeddingMission()
        if G_MAINSCENE and G_MAINSCENE.taskLab then 
            local str = game.getStrByKey("task") .. "(" .. tablenums( gatherData) .. ")" 
            G_MAINSCENE.taskLab:setString( str ) 
            G_MAINSCENE.taskLab1:setString( str ) 
        end

        local idx = 1
        for i = 1 , #keys do
            if gatherData[ keys[ i ] ] then
                items[ keys[ i ] ]:iconRefresh()
                setNodeAttr( items[ keys[ i ] ] , cc.p( 0 , ( tablenums(gatherData) - ( idx - 1 )  )* cellHight ) , cc.p( 0 , 0 ) )
                idx = idx + 1
            else    -- 失效面板的需要隐藏
                items[ keys[ i ] ]:iconRefresh();
            end
        end
        node:setContentSize( cc.size( 260 , tablenums(gatherData)*cellHight) )        

        

        --左侧任务类型有变动
        local newNum = tablenums(gatherData)
        if oldNum~= newNum then 
            if __TASK then __TASK.startRecordOffPos = nil  end
            if mainFlagUpdata then mainFlagUpdata() end
            
        end
        
        if oldNum~= newNum or newNum == 1 then 
            if G_MAINSCENE and G_MAINSCENE.taskBgChangeFun then G_MAINSCENE.taskBgChangeFun( newNum ) end
        end
    end

    return node
end

local uiMissionNode = nil
function M:popupLayout( targetKey )
    if DATA_Mission then DATA_Mission:setFindPath( true ) end --有点击操作，就一定是登陆就绪，可以支持密令自动寻路了
    if IsNodeValid(uiMissionNode) then
        uiMissionNode:remove()
    end
  isOpen = true

  local base_node = popupBox({ --parent = getRunScene()  , 
                         bg = COMMONPATH .. "2.jpg" , 
                         isMain = true , 
                         close = { callback = function() uiMissionNode = nil isOpen = false  if ActiveLayer and ActiveLayer["clearFun"] then ActiveLayer:clearFun() end DATA_Mission:setParent( nil ) end } , 
                         zorder = 200 , 
                         actionType = 3 ,
                       })

  uiMissionNode = base_node
  uiMissionNode:registerScriptHandler(function(event) 
        if event == "exit" then
            uiMissionNode = nil
        end
    end)
  DATA_Mission:setParent( base_node )
  G_TUTO_NODE:setTouchNode(base_node:getCloseBtn(), TOUCH_TASK_CLOSE)

  --createSprite( base_node , "res/common/bg/bg-6.png" , cc.p( 480 , 290 ) )

  local viewLayer = cc.Node:create()
  base_node:addChild( viewLayer )

  local keys = {}   --保存按钮对应键值
  local function changeLayout( key )
      if type( key ) == "string" then
        for i = 1 , #keys do
            if keys[i] == key then
              tableIndex = i
              break
            end
        end
      elseif type( key ) == "number" then
        key = keys[key]
      end

      
      if ActiveLayer and ActiveLayer["clearFun"] then ActiveLayer:clearFun() end
      viewLayer:removeAllChildren()
      local switchFun = {
                          plot = function( )                              
                            return require( "src/layers/mission/PlotLayer" ).new( viewLayer )
                          end ,
                          every = function( )
                            package.loaded[ "src/layers/mission/EverydayLayer" ] = nil
                            return require( "src/layers/mission/EverydayLayer" ).new( viewLayer )
                          end ,
                          rewardTask = function()
                            return require("src/layers/rewardTask/selfRewardTask").new(viewLayer)
                          end,
                          branch = function()
                            return require("src/layers/mission/BranchLayer" ).new(viewLayer)
                          end,
						  share = function()
							return require("src/layers/mission/ShareLayer").new(viewLayer)
						  end,
                        }
      ActiveLayer = switchFun[key]()

      if not ActiveLayer then return end
  end

  

  
  local TabControl = nil   --按钮组
  local function createBtns()
        if TabControl then
            removeFromParent(TabControl)
            -- 清空数据
            keys = {};
        end

      local btns , funs = { game.getStrByKey( "task_jq" ) .. game.getStrByKey( "task" ) } , { function() changeLayout( "plot" ) end }
      table.insert( keys , "plot" )

      local everyData = DATA_Mission:getEveryData()

      if everyData then
        --日常任务
        -- if not everyData.overEvery then
          table.insert( btns , game.getStrByKey( "rctask" ) )
          table.insert( funs , function() changeLayout( "every" ) end )
          table.insert( keys , "every" )
        -- end
      end
      
      ------------------------------------------------------------------------------------
      -- 新悬赏任务
      local rewardTaskData = DATA_Mission:GetRewardTaskData() and DATA_Mission:GetRewardTaskData()["hadTask"];
      if rewardTaskData ~= nil then
        table.insert(btns, game.getStrByKey("task_tf") .. game.getStrByKey("task"))
        table.insert(funs, function() changeLayout("rewardTask") end)
        table.insert(keys, "rewardTask")
      end
      ------------------------------------------------------------------------------------
      ------------------------------------------------------------------------------------
      -- 密令任务
      local branchData = DATA_Mission:getBranchData() --展示完成的历史记录
      if branchData ~= nil then
        table.insert(btns, game.getStrByKey("task_zx") .. game.getStrByKey("task"))
        table.insert(funs, function() changeLayout("branch") end)
        table.insert(keys, "branch")
      end
      ------------------------------------------------------------------------------------
      ------------------------------------------------------------------------------------
      -- 共享任务
	  local shareData = DATA_Mission:getShareData()
	  if shareData ~= nil then
		table.insert(btns, game.getStrByKey("task_gx") .. game.getStrByKey("task"))
		table.insert(funs, function() changeLayout("share") end)
		table.insert(keys, "share")
	  end
      ------------------------------------------------------------------------------------

      --设置激活指定界面(前提是指定页面有存在)
      if targetKey then 
        for i = 1 , #keys do
            if keys[i] == targetKey then
              tableIndex = i
              break
            end
        end
      end
      if tableIndex == 5 and not shareData then
        tableIndex = 1
    end
      -- groupNode = CreateBtnGroup( { parent = base_node , 
      --                   path = "res/layers/mission/" ,
      --                   isText = true , 
      --                   bg = { "res/component/TabControl/1.png" ,  "res/component/TabControl/2.png" } , 
      --                   btns = btns ,
      --                   callbacks = funs ,
      --                   btnsOffY = 0,
      --                   space = 10 ,
      --                   x = 80 ,
      --                   y = 605 ,
      --                   defIndex = tableIndex ,
      --                 } )

    local tabs = btns
    TabControl = Mnode.createTabControl(
    {
        src = {"res/common/TabControl/3.png", "res/common/TabControl/4.png"},
        size = 20,
        titles = tabs,
        margins = 2,
        ori = "|",
        align = "r",
        side_title = true,
        cb = function(node, tag)
            changeLayout(keys[tag])
            local title_label = base_node:getChildByTag(12580)
            if title_label then title_label:setString(tabs[tag]) end
        end,
        selected = tableIndex,
    })

    Mnode.addChild(
    {
        parent = base_node,
        child = TabControl,
        anchor = cc.p(0, 0.0),
        pos = cc.p(931, 480),
        zOrder = 200,
    })
    if #tabs<=1 then TabControl:setVisible(false) end
    if #tabs >= 2 then
        G_TUTO_NODE:setTouchNode(TabControl:tabAtIdx(2), TOUCH_TASK_DAILY)
    end

    if #tabs >= 3 then
        G_TUTO_NODE:setTouchNode(TabControl:tabAtIdx(3), TOUCH_TASK_BRANCH)
    end

    if #tabs >= 4 then
        G_TUTO_NODE:setTouchNode(TabControl:tabAtIdx(4), TOUCH_TASK_HUNT)
    end

    G_TUTO_NODE:setShowNode(root, SHOW_TASK)
  end
  createBtns()

 function base_node:refreshData( _type )
    --_type  1刷新当前界面 2包括按钮组刷新
    if _type == 1 then
        changeLayout( tableIndex )
    elseif _type == 2 then
        tableIndex = 1
        createBtns()
    end
 end
end

--接取任务动画 playTaskEffect
function M:playTaskEffect( state )
  -- body
  local task_effect = Effects:create(true)
  setNodeAttr( task_effect , cc.p(g_scrSize.width/2,g_scrSize.height*3/4) , cc.p(0.5,0.5) , 100 , nil , 1.5 )
  getRunScene():addChild( task_effect , 3000 )

  local tips = {
    [1] = function ()
      task_effect:playActionData("taskaccept", 8, 0.9, 1)
    end,

    [2] = function ()
      task_effect:playActionData("taskfinish", 12, 1.3, 1)
    end
  }
  if tips[state] then
    tips[state]()
  end
end

--其它任务类型界面跳转
function M:otherPath( tempData )
    local targetStr = stringsplit( tempData.q_done_event , "_") 
    
    if tempData.isBan and targetStr[1] ~= "32" then
        local endNpc = tempData.q_startnpc
        local targetAddr = __NpcAddr( endNpc )
        
        if targetAddr ~= nil then
            targetAddr.targetType = 1
            targetAddr.q_endnpc = endNpc
            __TASK:findPath( targetAddr )  
        end
        return
    end

  local handlerConfig = {
    ["1"] = function()
      --强化装备
        __GotoTarget( { ru = "a164" } )
    end ,
    ["2"] = function()
    -- 2   装备传承
       __GotoTarget( { ru = "a163" } )--装备传承
    end ,
    ["3"] = function()

    end ,
    ["4"] = function()

    end ,
    ["5"] = function()
      --装备熔炼
        __GotoTarget( { ru = "a124" } )
    end ,
    ["6"] = function()
      --技能升级
        __GotoTarget( { ru = "a27" } )
    end ,
    ["7"] = function()

    end ,
    ["8"] = function()
      --光翼进阶
        __GotoTarget( { ru = "a18" } )
    end ,
    ["9"] = function()

    end ,
    ["10"] = function()
      --每日签到
        __GotoTarget( { ru = "a28" } )
    end ,
    ["11"] = function()
      --日常任务
        __GotoTarget( { ru = "a1" } )
    end ,
    ["12"] = function()

    end ,
    ["13"] = function()
      --竞技场争霸
        --__GotoTarget( { ru = "a4" } )
    end ,
    ["14"] = function()
        --副本类型（1屠龙2通天塔3公主4多人6新屠龙）
        __GotoTarget( { ru = "a131" } )
    end ,
    ["15"] = function()
      --添加好友
        __GotoTarget( { ru = "a167"} )
    end ,
    ["16"] = function()
      --创建队伍
        __GotoTarget( { ru = "a29" ,index = 1} )
    end ,
    ["17"] = function()
      --送花
        __GotoTarget( { ru = "a167" } )
    end ,
    ["18"] = function()
      --击杀BOSS
        __GotoTarget( { ru = "a9" } )
    end ,
    ["19"] = function()
      --寻宝
        __GotoTarget( { ru = "a11" } )
    end ,
    ["20"] = function()
      --商城引导·元宝
        __GotoTarget( { ru = "a12" } )
    end ,
    ["21"] = function()
      --商城引导·礼金
        __GotoTarget( { ru = "a10" } )
    end ,
    ["22"] = function()
      --气血石的使用
        __GotoTarget( { ru = "a31" } )
    end ,
    ["23"] = function()
      --升级
      __GotoTarget( { ru = "a2" } )
    end ,
    ["24"] = function()

    end ,
    ["25"] = function()
      --日常任务
        __GotoTarget( { ru = "a1" } )
    end ,
    ["26"] = function()
      --活跃度界面
       __GotoTarget( { ru = "a36" } )
    end ,
    ["27"] = function()

    end ,
    ["28"] = function()
      --穿戴称号
       __GotoTarget( { ru = "a53" } )
    end,
    ["29"] = function()
      --收集物品
       __GotoTarget( { ru = "a31" } )
    end,
    ["30"] = function()
      --使用特定技能
       __GotoTarget( { ru = "a27" } )
    end,
    ["31"] = function()
      -- --写死一个挖矿点
      -- local id, posx, posy = 2132, 36, 30
      -- DATA_Mission.isStopFind = true
      -- DATA_Mission:setLastFind( { targetType = 3 , targetData = {  mapID = id , pos = { { x = posx , y = posy } }  } } )
      
      -- local detailMapNode = require("src/layers/map/DetailMapNode")
      -- detailMapNode:goToMapPos(id, cc.p(posx, posy), false)      
    end,               
    ["32"] = function()
        -- 32  提交某个物品(消耗) 
        if tempData ~= nil and tempData.q_endnpc ~= nil then
            local targetAddr = __NpcAddr( tempData.q_endnpc );

            targetAddr.targetType = 1;
            targetAddr.q_endnpc = tempData.q_endnpc;

            if tempData.targetData.cur_num and tempData.targetData.count and tempData.targetData.cur_num < tempData.targetData.count then
                -- 如果是特殊药品，去找药店掌柜
                local commConst = require("src/config/CommDef");
                if (tempData.targetData.ID == commConst.ITEM_ID_SMART_WATER or tempData.targetData.ID == commConst.ITEM_ID_MAGIC_POTION or tempData.targetData.ID == commConst.ITEM_ID_SUN_POTION) then
                    targetAddr.q_endnpc = commConst.NPC_ID_ZHONGZHOU_DRUGSTORE;
                -- 矿石类 需要引导到冒险挖矿
                elseif ((tempData.targetData.ID >= commConst.ITEM_ID_IRON_ORE_PURTY1 and tempData.targetData.ID <= commConst.ITEM_ID_IRON_ORE_PURTY10) or (tempData.targetData.ID >= commConst.ITEM_ID_BLACK_IRON_ORE_PURTY1 and tempData.targetData.ID <= commConst.ITEM_ID_BLACK_IRON_ORE_PURTY10)) then
                    __GotoTarget( { ru = "a208" } );
                    return;
                -- 强效太阳神水
                elseif tempData.targetData.ID == commConst.ITEM_ID_GREATER_SUN_POTION then
                    TIPS{str=game.getStrByKey("taskRewardItemTips1"), type=1};
                    return;
                -- 镇魔符
                elseif tempData.targetData.ID == commConst.ITEM_ID_TOWN_SIGIL then
                    TIPS{str=game.getStrByKey("taskRewardItemTips2"), type=1};
                    return;
                else
                    -- 查找掉落路径，是否有可以goto的目标
                    local factionWarning = "";
                    local lvlWarning = "";
                    
                    -- 获得途径
                    local MpropOp = require "src/config/propOp"
		            local way = MpropOp.outputWay(tempData.targetData.ID);
                    if #way > 0 then

                        local MPropOutput = require "src/config/PropOutputWayOp";

                        local candidateWay = {};
                        local ingotRecord = nil;
                        local bindIngotRecord = nil;
			            
                        for i, v in ipairs(way) do
					        local finx = tonumber(way[i])
					        if finx then
						        local record = MPropOutput:record(finx)
						        if not record then break end
						
						        if record.key ~= nil and record.key ~= "" then
                                    if finx == 98 or finx == 31 then -- 行会商店 or 行会BOSS
                                        if G_FACTION_INFO and G_FACTION_INFO.facname and G_FACTION_INFO.id > 0 then
                                            local lv = MRoleStruct:getAttr(ROLE_LEVEL)
                                            local limit = MPropOutput:lvLimit(record)
							                if limit and lv < limit then
                                                lvlWarning = game.getStrByKey("get_path") .. ": " .. MPropOutput:name(record) .. ", " .. limit .. game.getStrByKey("rngd")..game.getStrByKey("open");
                                            else
                                                if finx == 1 then
                                                    ingotRecord = record;
                                                elseif finx == 3 then
                                                    bindIngotRecord = record;
                                                end
                                                table.insert(candidateWay, record);
                                            end
                                        else
                                            factionWarning = game.getStrByKey("get_path") .. ": " .. MPropOutput:name(record) .. ", " .. game.getStrByKey("join_faction_tips");
                                        end
                                    else
                                        local lv = MRoleStruct:getAttr(ROLE_LEVEL)
                                        local limit = MPropOutput:lvLimit(record)
							            if limit and lv < limit then
                                            lvlWarning = game.getStrByKey("get_path") .. ": " .. MPropOutput:name(record) .. ", " .. limit .. game.getStrByKey("rngd")..game.getStrByKey("open");
                                        else
                                            if finx == 1 then
                                                ingotRecord = record;
                                            elseif finx == 3 then
                                                bindIngotRecord = record;
                                            end
                                            table.insert(candidateWay, record);
                                        end
                                    end
                                end
							
					        end
				        end

                        if #candidateWay > 0 then
                            
                            -- 优先绑元商城
                            if bindIngotRecord then
                                __GotoTarget({ ru = MPropOutput:goto(bindIngotRecord), protoId = tempData.targetData.ID });
                                return;
                            end

                            -- 开了充值下的元宝商城
                            if ingotRecord and not G_NO_OPEN_PAY then
                                __GotoTarget({ ru = MPropOutput:goto(ingotRecord), protoId = tempData.targetData.ID });
                                return;
                            end

                            -- 任意一个已经搜寻到的结果
                            __GotoTarget({ ru = MPropOutput:goto(candidateWay[1]), protoId = tempData.targetData.ID });
                            return;
                        end
                    end

                    if factionWarning ~= "" and factionWarning ~= nil then
                        TIPS({ type = 1  , str = factionWarning })
                        return;
                    elseif factionWarning ~= "" and factionWarning ~= nil and lvlWarning ~= "" then
                        TIPS({ type = 1  , str = factionWarning })
                        return;
                    else
                        -- 默认指向商城
                        __GotoTarget( { ru = "a12" } );
                        return;
                    end
                end                
            end
            
            self:findPath( targetAddr ) 
        end
    end,              
    ["33"] = function()
        -- 33  装备洗炼
        __GotoTarget( { ru = "a166" } )
    end,               
    ["34"] = function()
        -- 34  发布悬赏任务
        __GotoTarget( { ru = "a144" } )
    end,               
    ["35"] = function()
        -- 35  接取悬赏任务
        __GotoTarget( { ru = "a144" } )
    end,               
    ["36"] = function()
        -- 36  完成悬赏任务
        local curData = DATA_Mission:GetRewardTaskData() and DATA_Mission:GetRewardTaskData()["hadTask"]
        if curData then
            self:findPath( curData ) 
        else
            __GotoTarget( { ru = "a144" } )
        end
    end,               
    ["37"] = function()
        -- 37  完成狩猎任务
        __GotoTarget( { ru = "a143" } )
    end,               
    ["38"] = function()
        -- 38  参加副本副本类型（1屠龙2通天塔3公主4多人6新屠龙）
        __GotoTarget( { ru = "a213" } )
    end,               
    ["39"] = function()
        -- 39  膜拜
        __GotoTarget( { ru = "a88" } )
    end,               
    ["40"] = function()
        -- 40  升级勋章
        __GotoTarget( { ru = "a138" } )
    end,               
    ["41"] = function()
        -- 41  购买神秘商店物品
        __GotoTarget( { ru = "a38" } )
    end,               
    ["42"] = function()
        -- 41  购买神秘商店物品
        __GotoTarget( { ru = "a38" } )
    end,               
    ["43"] = function()
        __GotoTarget( { ru = "a165" } )--装备祝福
    end,               
    ["44"] = function()
        -- 44  加入行会
        __GotoTarget( { ru = "a3" } )
    end,               
    ["45"] = function()
        -- 45  击杀玩家
        __GotoTarget( { ru = "a139" } )
    end,               
    ["46"] = function()
        -- 46  运镖
        __GotoTarget( { ru = "a40" } )
    end,               
    ["47"] = function()
        -- 47  劫镖  次数
        __GotoTarget( { ru = "a40" } )
    end,               
    ["48"] = function()
    -- 48  升级高级技能
        __GotoTarget( { ru = "a27" } )
    end,               
    ["49"] = function()
    -- 49  仙翁赐酒
        __GotoTarget( { ru = "a40" } )
    end,               
    ["50"] = function()
    -- 50  挖矿  次数
        __GotoTarget( { ru = "a40" } )
    end,               
    ["51"] = function()
    -- 51  参加焰火屠魔  次数
        __GotoTarget( { ru = "a40" } )
    end,
    ["52"] = function()
    -- 52  共享藏宝任务
        __GotoTarget( { ru = "a40" } )
    end,
    ["53"] = function()
    -- 53  对NPC使用道具
        local tag = tempData.targetData
        local tempData = { targetType = 4 , mapID = tag.mapID ,  x = tag.pos[1].x , y = tag.pos[1].y , callFun = function() self:usePopupBox( tag ) end  }
        __TASK:findPath( tempData )
    end,
    ["54"] = function()
    -- 54  击杀特定怪物
        -- local endNpc = 20004
        -- local targetAddr = __NpcAddr( endNpc )
        -- targetAddr.targetType = 1
        -- targetAddr.q_endnpc = endNpc
        -- __TASK:findPath( targetAddr )  
        local function handlerFun()
            g_msgHandlerInst:sendNetDataByTableExEx( TASK_CS_REQ_FRESH_MONSTER_TASK , "RequestFreshMonsterTaskProtocol" , {} )
            game.setAutoStatus(AUTO_ATTACK)
        end
        
        local tag = tempData.targetData
        local tempData = { targetType = 4 , mapID = tag.mapID ,  x = tag.pos[1].x , y = tag.pos[1].y , callFun = handlerFun }
        __TASK:findPath( tempData )
    end,
    ["55"] = function()
    -- 55  变身
        local endNpc = tempData.q_startnpc
        local targetAddr = __NpcAddr( endNpc )
        targetAddr.targetType = 1
        targetAddr.q_endnpc = endNpc
        __TASK:findPath( targetAddr )    
    end,
    ["56"] = function()
    -- 56  任务护镖
        -- if tempData.finished == 5 then
        --     local endNpc = tempData.q_startnpc
        --     local targetAddr = __NpcAddr( endNpc )
        --     targetAddr.targetType = 1
        --     targetAddr.q_endnpc = endNpc
        --     __TASK:findPath( targetAddr )  
        -- else
            game.setAutoStatus(AUTO_ESCORT)
        -- end
    end,
    ["57"] = function()
    -- 57  对怪物使用道具
        local tag = tempData.targetData
        local tempData = { targetType = 4 , mapID = tag.mapID ,  x = tag.pos[1].x , y = tag.pos[1].y , callFun = function() self:usePopupBox( tag ) end  }
        __TASK:findPath( tempData )
    end,
    ["58"] = function()
    -- 58  模拟攻杀无效定义(后台代码已删除)
    end,
    ["59"] = function()
        -- 59  物品合成
        __GotoTarget( { ru = "a201" } )
    end,
    ["60"] = function()
        -- 60  悬赏领取奖励
        __GotoTarget( { ru = "a144" } )
    end,
    ["61"] = function()
        -- 61 模拟攻杀
        local endNpc = tempData.q_startnpc
        local targetAddr = __NpcAddr( endNpc )
        targetAddr.targetType = 1
        targetAddr.q_endnpc = endNpc
        __TASK:findPath( targetAddr )    
    end,
  }
  if handlerConfig[ targetStr[1] ] then handlerConfig[ targetStr[1] ]() end

end
function M:findPath( tempData )
    if DATA_Mission and DATA_Mission.plotFindPath == nil then return end

    if G_MAINSCENE then
        game.setAutoStatus(AUTO_PICKUP)
        local node = cc.Node:create()
        local times = 0
        local taskFresh = function()
            if G_MAINSCENE and G_MAINSCENE.map_layer and G_ROLE_MAIN then
                G_MAINSCENE.map_layer:resetTouchTag()
                if times > 10 then
                    G_MAINSCENE.map_layer.on_pickup = nil 
                end
                times = times + 1
                local state = G_ROLE_MAIN:getCurrActionState()
                if G_MAINSCENE.map_layer.on_pickup and (state > 1 and state < 7) then
                    return
                elseif G_MAINSCENE.map_layer:autoPickUp() then
                    times = 0
                else
                    removeFromParent(node)
                    tempData = self:__CreateTag( tempData )
                    __TASK:findPathEX( tempData )
                    return true
                end
            end   
        end
        G_MAINSCENE:addChild(node)
        --if not taskFresh() then
            schedule(node,taskFresh,0.25)
        --end
    end
end
function M:usePopupBox( tag )
    if __TASK.usePopupBoxNode then return end                                           
    local base_node = popupBox({ 
             createScale9Sprite = { size = cc.size( 160 , 200 ) } ,  
             pos = cc.p( 630 , display.height - 200 ) , 
             anch = cc.p( 0 , 1 ) , 
             bg = "res/common/scalable/bg.png" ,  
             close = { callback = function() __TASK.usePopupBoxNode = nil end , scale = 0.5 , offX = -15 , offY = -15 } , 
             zorder = 200 ,
             actionType = 7 ,
             isNoSwallow = false , 
             isHalf = true,
           })
    __TASK.usePopupBoxNode = base_node
    local icon = iconCell( { parent = base_node, name = true , iconID = tag.usePropid , } )
    local size = base_node:getContentSize()
    setNodeAttr( icon, cc.p( size.width/2 , size.height - 20 ) , cc.p( 0.5 , 1 ) )
    local function useClickFun()                
        G_MAINSCENE.map_layer:taskUse( tag.usePropType == 1 and 57 or 53 )
        base_node:close()
    end
    local goBtn = createMenuItem( base_node , "res/component/button/39.png" , cc.p( size.width/2 , 35  ) , useClickFun )
    createLabel( goBtn , game.getStrByKey("use")  , getCenterPos(goBtn)  , cc.p( 0.5 , 0.5 ) , 24 , true )
end
--前往目标
function M:findPathEX( tempData )
    local lastAddr = {}   --记录最后寻路位置
    local detailMapNode = require("src/layers/map/DetailMapNode"):getDetailMapInfo()
    detailMapNode.touch_pos = nil
    DATA_Mission.isStopFind = nil
    if not tempData then return end
    --新添加任务类型  主要跳转界面
    if G_MAINSCENE and G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.isfb then
      return
    end

    if tempData.finished == 1 then
        game.setAutoStatus( 0 )
    else
      game.setAutoStatus(AUTO_TASK)
      DATA_Mission:setAutoPath( true )
    end
    if tempData.q_done_event and tonumber( tempData.q_done_event ) ~= 0 then  self:otherPath( tempData ) return end

    DATA_Mission:setTempFindPath( tempData )
    DATA_Mission:setLastTarget( )
    local handlerFun = function()
        if G_MAINSCENE == nil  then return end
        G_MAINSCENE.map_layer:removeWalkCb()
        DATA_Mission:setTempFindPath( nil )
        if tempData.targetType == 1 or tempData.finished == 6 or tempData.targetType == 5 then            
            require("src/layers/mission/MissionNetMsg"):sendClickNPC( tempData.isBan and tempData.q_startnpc or  tempData.q_endnpc )               
        elseif tempData.targetType == 2 then
            local targetData = tempData.targetData
            game.setAutoStatus(0)
            local num = targetData.count - targetData.cur_num
            G_MAINSCENE.map_layer:taskCaiJi(targetData.ID, num,targetData.isWeddingSys,targetData.caijiTaskId)          
        elseif tempData.targetType == 3 then
            game.setAutoStatus(AUTO_ATTACK)
            resetGmainSceneTime()
        elseif tempData.targetType == 4 then 
            game.setAutoStatus(0)
        end

        if tempData.callFun then tempData.callFun() end
    end
    local isShowFindAction = true --是否显示寻路动画
    local ShowFindAction = function(is_show,tar_pos)
        if G_ROLE_MAIN and G_MAINSCENE and G_MAINSCENE.map_layer then
            if math.max(math.abs(tar_pos.x-G_ROLE_MAIN.tile_pos.x),math.abs(tar_pos.y-G_ROLE_MAIN.tile_pos.y)) > 1 then
                G_MAINSCENE.map_layer:registerWalkCb( handlerFun )
                G_MAINSCENE.map_layer:moveMapByPos( tar_pos ,true)
                game.setAutoStatus(AUTO_PATH,not is_show)
                --if is_show then G_MAINSCENE:playHangupEffect(1) end
            else
                handlerFun()
            end
        end
    end
    G_MAINSCENE.map_layer:removeWalkCb()
    local MRoleStruct = require("src/layers/role/RoleStruct")
    if tempData.finished == 1 or MRoleStruct:getAttr(ROLE_LEVEL) == 1  then isShowFindAction = false end

    if tempData.finished == 6 or tempData.targetType == 1 then
        --对话
        local npc_id = tempData.isBan and tempData.q_startnpc or  tempData.q_endnpc
        local itemData = getConfigItemByKeys( "NPC" , "q_id" )[ npc_id ]

        if itemData ~= nil  then
            lastAddr = { mapid = itemData.q_map , x = itemData.q_x , y = itemData.q_y }
            if G_MAINSCENE.mapId ~= itemData.q_map then
                findTarMap(  itemData.q_map , G_MAINSCENE.mapId )
            else
              ShowFindAction(isShowFindAction,cc.p( itemData.q_x , itemData.q_y ))
            end
        end

    elseif tempData.targetType == 2 then
        local targetData = tempData.targetData
        if targetData and targetData.pos and  targetData.mapID then
            
    	    lastAddr = { mapid = targetData.mapID , x = targetData.pos[1].x , y = targetData.pos[1].y }
            if G_MAINSCENE.mapId  ~= targetData.mapID then
                findTarMap( targetData.mapID , G_MAINSCENE.mapId )
            else
              ShowFindAction(isShowFindAction,cc.p( targetData.pos[1].x , targetData.pos[1].y ))
            end
        end
    elseif tempData.targetType == 3 then
        --杀怪  
        local targetData = tempData.targetData
        DATA_Mission:setLastTarget( { 
                                 id = targetData.ID , 
                                 mapid = targetData.mapID , 
                                 pos = targetData.pos[1]
                             } ) 
        lastAddr = { mapid = targetData.mapID , x = targetData.pos[1].x , y = targetData.pos[1].y }

        if G_MAINSCENE.mapId  ~= targetData.mapID then
            findTarMap( targetData.mapID , G_MAINSCENE.mapId )
        else
          ShowFindAction(isShowFindAction,cc.p( targetData.pos[1].x , targetData.pos[1].y ) )
        end
    elseif tempData.targetType ==  4 then
        --特别情况 （用于非任务寻路）
        lastAddr = { mapid = tempData.mapID , x = tempData.x , y = tempData.y }

        if G_MAINSCENE.mapId  ~= tempData.mapID then
            findTarMap( tempData.mapID , G_MAINSCENE.mapId )
        else
          ShowFindAction(isShowFindAction,cc.p( tempData.x , tempData.y ) )
        end
    end

    DATA_Mission:setLastFind( lastAddr )
end

--最新NPC对话面板
function M:npcNewChat( tempData )      
    if getRunScene():getChildByName("npcChat") then return end  --面板存在就不展示
    if G_TUTO_NODE and G_TUTO_NODE.tutoLayer then return end --新手教程状态，就不展示
    local npcPanel = cc.Layer:create()
    npcPanel:setName("npcChat")


    local bg = createSprite(npcPanel,  "res/layers/mission/npcLittle.png", cc.p(display.width/2, display.height/2 - 10), cc.p(0.5, 0.5))
    local bgSize = bg:getContentSize()
    createLabel(bg, tempData["npcCfg"]["q_name"] or "", cc.p( bgSize.width/2 , bgSize.height - 22 ), cc.p( 0.5 , 0.5 ), 24 , true, nil, nil, MColor.yellow)

    local nWidthLeftOff = 0
    local constantWidth = 570
    local str = tempData["txt"] or ""

    --npc半身像
    if tempData["npcCfg"]["q_boby"] then
        createSprite(bg, "res/mainui/npc_head/" .. tempData["npcCfg"]["q_boby"] .. ".png", cc.p( 90 , 20 ) , cc.p( 0.5 , 0 ) )
    elseif tempData["npcCfg"].q_id >= 10455 and tempData["npcCfg"].q_id <= 10460 then  --中州王雕像
        local sex = 1
        local school = 1
        if G_EMPIRE_INFO and G_EMPIRE_INFO.BIQI_KING and G_EMPIRE_INFO.BIQI_KING.name and G_EMPIRE_INFO.BIQI_KING.name ~= "" then
            sex = G_EMPIRE_INFO.BIQI_KING.sex or 1
            school = G_EMPIRE_INFO.BIQI_KING.school or 1
        end
        local pngIndex =  (sex-1)*3+school
        local spr = createSprite(bg, "res/mainui/npc_big_head/"..pngIndex..".png", cc.p( 90 , 20 ) , cc.p( 0.5 , 0 ) )
        if pngIndex == 2 or pngIndex == 3 or pngIndex == 5 or pngIndex == 6 then
            spr:setScale(0.68)
        else
            spr:setScale(0.70)
        end
    else
        createScale9Frame(
            bg,
            "res/common/scalable/panel_outer_base.png",
            "res/common/scalable/panel_outer_frame_scale9.png",
            cc.p(60 , 19),
            cc.size(725, 232),
            4
        )
        nWidthLeftOff = 50
    end

    local richText = require("src/RichText").new( bg , cc.p( 190 - nWidthLeftOff * 2 , 150 + 90 ) , cc.size( constantWidth, 0 ) , cc.p( 0 , 1 ) , 22 , 20 , MColor.lable_yellow )
    richText:setAutoWidth()
    richText:addText( str, MColor.lable_yellow , true )
    richText:format()

    local closeLayer = function()
        if npcPanel then 
            removeFromParent(npcPanel)
        end
        npcPanel = nil
    end

    registerOutsideCloseFunc( bg , closeLayer , true , false ) 

    --奖励
    local groupAwards, tfLabel = nil, nil
    local commConst = require("src/config/CommDef");
    if tempData["typeV"] == 1 or tempData["npcid"] == commConst.NPC_ID_SHADOW_PAVILION then
        if tempData.awrds then
            tfLabel = createLabel( bg , game.getStrByKey( "task_reward") .. "" , cc.p( 190 - nWidthLeftOff * 2 , 115 ) , cc.p( 0 , 0) , 22 , true, nil, nil, MColor.green )
            groupAwards = __createAwardGroup( tempData.awrds , nil , 100 , nil , false ) 
            setNodeAttr( groupAwards , cc.p( 225 - nWidthLeftOff * 2 , 5 ) , cc.p( 0 , 0 ) )
            bg:addChild( groupAwards )
        end
    end

    local function func( clickData )
        closeLayer() 
        local switchFun = {
                ["1"] = function() 
                        --1Runtime_Task运行时任务类       
                        if not G_ROLE_MAIN then
                            return false
                        end                 
                        g_msgHandlerInst:sendNetDataByTableExEx( DIALOG_CS_CLICKOPTION , "DialogOptionProtocol" , { npcId = tempData["npcid"] , dialogType = clickData["optiontype"] , dialogValue = clickData["optionvalue"] , dialogParam = clickData["optionparam"] } )
                        end , 
                ["2"] = function() 
                        if not G_ROLE_MAIN then
                            return false
                        end
                        __TASK.isClickBtn = true
                            --2Doer执行某项功能 -- roleId int -- npcid int -- optiontype ：short 选项类型 -- optionvalue ：int  选项参数 -- optionparam ：int  选项参数 
                            g_msgHandlerInst:sendNetDataByTableExEx( DIALOG_CS_CLICKOPTION , "DialogOptionProtocol" , { npcId = tempData["npcid"] , dialogType = clickData["optiontype"] , dialogValue = clickData["optionvalue"] , dialogParam = clickData["optionparam"] } )
                        end , 
                ["3"] = function() 
                        --3Client客户端操作( 约定操作 )
                        __GotoTarget( { ru = clickData["optionvalue"] } )
                        end , 
                ["4"] = function() 
                        --4Close关闭对话框
                        -- closeLayer()
                        end , 
                ["5"] = function() 
                        --5执行客户端指定函数
                            __ClientNPCFun( clickData )
                        end , 
                }
         switchFun[ clickData["optiontype"] .. "" ]()   
    end

    tempData["optionTable"] = tempData["optionTable"] or {}

    local addr = nil
    local addrCfg = {
                        { x = 685 - 160 * 0 , y = 68 , num = 0 ,  lineNum = 1 , spaceW = 160 , spaceH = 60 , sp = "res/component/button/2.png" } ,
                        { x = 685 - 160 * 1 , y = 68 , num = 0 ,  lineNum = 2 , spaceW = 160 , spaceH = 60 , sp = "res/component/button/2.png" } ,
                        { x = 685 - 160 * 2 , y = 68 , num = 0 ,  lineNum = 3 , spaceW = 160 , spaceH = 60 , sp = "res/component/button/2.png" } ,
                        { x = 685 - 160 * 3 , y = 68 , num = 0 ,  lineNum = 4 , spaceW = 160 , spaceH = 60 , sp = "res/component/button/2.png" } ,
                        { x = 685 - 160 * 4 , y = 68 , num = 0 ,  lineNum = 5 , spaceW = 160 , spaceH = 60 , sp = "res/component/button/2.png" } ,
                        { x = 685 - 160 * 2 , y = 108 , num = 0 ,  lineNum = 3 , spaceW = 160 , spaceH = 60 , sp = "res/component/button/2.png" } ,
                        { x = 685 - 160 * 3 , y = 108 , num = 0 ,  lineNum = 4 , spaceW = 160 , spaceH = 60 , sp = "res/component/button/2.png" } ,
                        { x = 685 - 160 * 3 , y = 108 , num = 0 ,  lineNum = 4 , spaceW = 160 , spaceH = 60 , sp = "res/component/button/2.png" } ,
                        { x = 685 - 160 * 4 , y = 108 , num = 0 ,  lineNum = 5 , spaceW = 160 , spaceH = 60 , sp = "res/component/button/2.png" } ,
                        { x = 685 - 160 * 4 , y = 108 , num = 0 ,  lineNum = 5 , spaceW = 160 , spaceH = 60 , sp = "res/component/button/2.png" } ,
                    }

    local opNum = tablenums(tempData["optionTable"])
    opNum = ( opNum > #addrCfg and #addrCfg or opNum )

    addr = addrCfg[ opNum ]

    if tempData.awrds then
        if #tempData.awrds <= 3 and false then
            if  opNum > 3 then
                 addr = { x = 685 - 160 * 2 , y = 108 , num = 0 ,  lineNum = 3 , spaceW = 160 , spaceH = 60 , sp = "res/component/button/2.png" } 
            end
        else
            if opNum > 2 then
                 addr = { x = 685 - 160 * 1 , y = 108 , num = 0 ,  lineNum = 2 , spaceW = 160 , spaceH = 60 , sp = "res/component/button/2.png" } 
            end
        end
    end

    for k , v in pairs(tempData["optionTable"]) do
        local itemData = v

        -- local addr = addrCfg[ itemData["optiontype"] ]
        if itemData.optiontype == 1 and itemData.optionparam == 11  then
            local nowData = DATA_Mission:getLastTaskData()
            local str = game.getStrByKey( "insufficient_level" )
            if groupAwards then
                groupAwards:setVisibleAndTouchEnabled(true)
            end

            if tfLabel then
                tfLabel:setVisible(true)
            end
            if nowData.q_taskid == tempData.txtid  then 
                str =  string.format( game.getStrByKey( "func_unavailable_noTask1" ) , nowData.q_accept_needmingrade )
                if groupAwards then
                    groupAwards:setVisibleAndTouchEnabled(false)
                end
                if tfLabel then
                    tfLabel:setVisible(false)
                end
            end
            createLabel( bg, str , cc.p( 770 , addr.y - math.floor(addr.num/addr.lineNum) * addr.spaceH ) , cc.p( 1 , 0.5 ), 22, true , nil,nil,MColor.red )
        else
            local tempBtn = createMenuItem( bg , addr.sp , cc.p( addr.x + ( addr.num%addr.lineNum ) * addr.spaceW , addr.y - math.floor(addr.num/addr.lineNum) * addr.spaceH ) , function() func( itemData ) end )
            createLabel( tempBtn, itemData["optiontext"] , getCenterPos( tempBtn ) , nil, 22, true , nil,nil,MColor.lable_yellow )
            addr.num = addr.num + 1
            tempBtn:setEnabled(nil == itemData.BtnEnabled or itemData.BtnEnabled)

            if tempData["npcid"] == commConst.NPC_ID_SHADOW_PAVILION then --幽影阁门人，做新手用
                 G_TUTO_NODE:setTouchNode(tempBtn,TOUCH_NPC_BTN)
            end
        end
    end

    game.setAutoStatus(0)
    getRunScene():addChild( npcPanel , 149 )

    if tempData["npcid"] == commConst.NPC_ID_SHADOW_PAVILION then --幽影阁门人，做新手用
        G_TUTO_NODE:setShowNode(npcPanel, SHOW_NPC_CHAT)
    elseif tempData["npcid"] == commConst.NPC_ID_JINLANSHIZHE then --结拜，做新手用
        G_TUTO_NODE:setShowNode(npcPanel, SHOW_NPC_CHAT_JIEYI)
    
    end
end


local showTip_num = 0
--展示击杀采集数量变化
function M:showTip( params )
   local tempData = params or DATA_Mission:getLastTaskData()
   if tempData.targetData.cur_num == 0 then return end
   local strRoleName = tempData.targetData.roleName
   strRoleName = strRoleName or tempData.q_name
   strRoleName = strRoleName or ""
   
   if tempData.targetType ~= 1 then
    local str = "^c(green)" .. strRoleName .. "(^^c(red)" .. tempData.targetData.cur_num .. "^^c(green)/" .. tempData.targetData.count .. ")^"

    if tempData.targetData.cur_num >= tempData.targetData.count then
      str = "^c(green)" .. strRoleName .. "(" .. tempData.targetData.cur_num .. "/" .. tempData.targetData.count .. ")^"
      G_MAINSCENE.temp_lock = true
    end

    showTip_num = showTip_num + 1
    if showTip_num > 2 then showTip_num = 0 end
      performWithDelay(self,function() 
        TIPS( { type = 3 , str = str } ) 
        if showTip_num > 0 then showTip_num = showTip_num - 1 end
      end,0.1*showTip_num)
  end

end

--弹出日常任务对话框
function M:popupEveryBox()
    if G_MAINSCENE and G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.isfb then return end   --副本禁弹日常对话框

    local data = DATA_Mission:getEveryData()
    local preData = DATA_Mission:getPreEveryData()

    local rewardLv = data.rewardCfg["q_starLevel"] 
    if not data or not preData then return end

    if DATA_Mission:getEveryTipNode() then
      DATA_Mission:getEveryTipNode():close()
      DATA_Mission:setEveryTipNode( nil )
    end


    local tempLayer = popupBox({ 
                        bg = COMMONPATH .. "bg/bg37.png" , 
                        zorder = 200 ,
                        close = { path = "res/component/button/x2.png" , offX = -25 , offY = -25 ,callback = function() DATA_Mission:setEveryTipNode( nil ) end } ,  
                        isNoSwallow = true ,
                        -- actionType = 8 ,
                       })
    local size = tempLayer:getContentSize()
    DATA_Mission:setEveryTipNode( tempLayer )
    
    local richText = require("src/RichText").new( tempLayer , cc.p( 40 , 310 ) , cc.size( 500 , 0 ) , cc.p( 0 , 0.5 ) , 28 , 20 , MColor.white )
    local objs = require("src/config/propOp")
    local gatherStr = "" 
    for i =1 , #preData.reward do
          if preData.reward[i].id == 444444 or preData.reward[i].id == 999999 then
              gatherStr = gatherStr ..  "^c(yellow)" .. numToFatString( tonumber( preData.reward[i].num ) )  .. "^"  .. (  preData.reward[i].id == 444444 and "EXP" or game.getStrByKey( "gold_text" ) )
          else
              -- gatherStr = gatherStr .. numToFatString( preData.reward[i].num ) .. "^c(" ..  objs.nameColor( preData.reward[i].id ) .. ")" .. objs.name( preData.reward[i].id ) .. "^" 
              gatherStr = gatherStr .. numToFatString( preData.reward[i].num ) .. "^c(yellow)" .. objs.name( preData.reward[i].id ) .. "^" 
          end 
          if i < #preData.reward then
               gatherStr = gatherStr .. "、"
          end
    end
    richText:addText( string.format( game.getStrByKey("complete_task_get") , preData.rewardCfg["q_starLevel"] ) .. gatherStr , MColor.lable_yellow , true )
    richText:format()

    local text = createLabel( tempLayer ,  game.getStrByKey("continue_task_get") , cc.p( 40 , 270 ) , cc.p( 0 , 0 ) , 20 , true , nil , nil , MColor.green , nil , nil , MColor.black , 3 )

    createLabel( tempLayer , game.getStrByKey("award_star_lv") , cc.p( 40 , 130) , cc.p( 0 , 0 ) , 20 , true , nil , nil , MColor.orange , nil , nil , MColor.black , 3 )



    local width = size.width
    local spaceX = 80
    local awardLayer = cc.Node:create()
    tempLayer:addChild( awardLayer )

    local rewardLv = data.rewardCfg["q_starLevel"] 
    for i = 1 , 5 do
        createSprite( awardLayer , "res/group/star/s" .. ( i<=rewardLv and 2 or 0 ) .. ".png" , cc.p( 150 + ( i - 1 ) * 35 , 135 ) , cc.p( 0 , 0 ))
    end


    local groupAwards =  __createAwardGroup( data.reward , nil , 85 , nil , false )
    setNodeAttr( groupAwards , cc.p( 70 , 225 ) , cc.p( 0 , 0.5 ) )
    awardLayer:addChild( groupAwards )



    --升星刷新
    local function upStarFun()

      local function refreshStar()
        DATA_Mission:setCallback( "popup_up_star" ,  nil )
        data = DATA_Mission:getEveryData()
        if awardLayer then awardLayer:removeAllChildren() end
        
        local rewardLv = data.rewardCfg["q_starLevel"] 
        for i = 1 , 5 do
            createSprite( awardLayer , "res/group/star/s" .. ( i<=rewardLv and 2 or 0 ) .. ".png"  , cc.p( 150 + ( i - 1 ) * 35 , 135 ) , cc.p( 0 , 0 ))
        end
    

        

        local groupAwards =  __createAwardGroup( data.reward , nil , 85 , nil , false)
        setNodeAttr( groupAwards , cc.p( 70 , 225 ) , cc.p( 0 , 0.5 ) )
        awardLayer:addChild( groupAwards )

      end

      DATA_Mission:setCallback( "popup_up_star" ,  refreshStar )
      g_msgHandlerInst:sendNetDataByTableExEx(TASK_CS_UP_REWARD_STAR, "UpRewardStarProtocol", {} )
    end

    -- local upBtn = createScale9SpriteMenu( tempLayer , "res/component/button/50.png" ,   cc.size( 70 , 50  ) , cc.p( 380 , 140 ) , upStarFun )
    local upBtn = createMenuItem( tempLayer , "res/component/button/50.png" ,   cc.p( 400 , 140 ) , upStarFun )
    createLabel( upBtn , game.getStrByKey("up_star")  , getCenterPos( upBtn ) , cc.p( 0.5 , 0.5 ) , 22 , true , nil , nil , MColor.lable_yellow , nil , nil , MColor.black , 3 )

    createLabel( tempLayer , game.getStrByKey("task_tip_str")  , cc.p(  155  , 120 ) , cc.p( 0 , 0.5 ) , 18 , true , nil , nil , MColor.lable_yellow , nil , nil , MColor.black , 3 )

    local goBtn = createMenuItem( tempLayer , "res/component/button/50.png" , cc.p( size.width/2 , 60 ) , function()    tempLayer:close() self:findPath( data ) end )
    createLabel( goBtn , game.getStrByKey("go")  , getCenterPos( goBtn ) , cc.p( 0.5 , 0.5 ) , 22 , true , nil , nil , MColor.lable_yellow , nil , nil , MColor.black , 3 )
  
end



--获取日常轮数
function M:getEveryNum()
	local totalNum = 15 --默认为15环
	return totalNum
end

function M:showGod()
  local Mcurrency = require "src/functional/currency"
  local god =  Mnode.combineNode(
          {
            nodes = {
              [2] = Mcurrency.new(
              {
                cate = PLAYER_INGOT,
                --bg = "res/common/19.png",
                color = MColor.yellow,
              }),
              
              [1] = Mcurrency.new(
              {
                cate = PLAYER_BINDINGOT,
                --bg = "res/common/19.png",
                color = MColor.yellow,
              })
            },
            ori = "|" ,
            margins = 0 ,
          })
   setNodeAttr( god , cc.p(50, 575) , cc.p( 0 , 0 ) )

  return god
end

--光翼接取展示
function M:showTaskWing( taskName )
    if G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.isfb then return end--副本中不展示
	if G_MAINSCENE.isOnlyShowTeamNode == true then return end--副本中不展示
	
    taskName = string.gsub( taskName , "/" , "0000"  )
    taskName = string.gsub( taskName , "%W" , ""  )
    taskName = string.gsub( taskName , "0000" , "/"  )

    local scene = getRunScene()
    local bg = createSprite(scene, "res/common/bg/tips1.png", cc.p(display.cx, display.cy), cc.p(0.5, 0.5), 200)

    local titleBg = createSprite(bg, "res/common/bg/titleLine.png", cc.p(bg:getContentSize().width/2, bg:getContentSize().height-3), cc.p(0.5, 0.5))
    createLabel(titleBg, game.getStrByKey("award"), getCenterPos(titleBg), cc.p(0.5, 0.5), 20, nil, nil, nil, MColor.lable_yellow)
    local showBg = createSprite(bg, "res/common/bg/tips1-1.jpg", getCenterPos(bg, 0, 15), cc.p(0.5, 0.5))

    local effect = Effects:create(false)
    effect:setCleanCache()
    effect:playActionData("wingeff", 10, 1.8, -1)
    addEffectWithMode(effect, 1)
    showBg:addChild(effect)
    effect:setAnchorPoint(cc.p(0.5, 0.5))
    effect:setPosition(getCenterPos(showBg, 0, 0))

    local effect = Effects:create(false)
    effect:setCleanCache()
    effect:playActionData("wingefflight", 5, 0.8, -1)
    addEffectWithMode(effect, 1)
    showBg:addChild(effect)
    effect:setAnchorPoint(cc.p(0.5, 0.5))
    effect:setPosition(getCenterPos(showBg))
    --effect:runAction(cc.RepeatForever:create(cc.RotateBy:create(1, 10)))
    
    local wingSpr = createSprite(showBg, "res/showplist/wing/1.png", cc.p(showBg:getContentSize().width/2+20, 260), cc.p(0.5, 0.5))
    wingSpr:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(1, cc.p(showBg:getContentSize().width/2+20, 250)), cc.MoveTo:create(1, cc.p(showBg:getContentSize().width/2+20, 260)))))

    createSprite(bg, "res/wingAndRiding/2.png", cc.p(bg:getContentSize().width/2, 30), cc.p(0.5, 0))
    local progressBg = createSprite(showBg, "res/common/bg/titleLine4.png", cc.p(showBg:getContentSize().width/2, 1), cc.p(0.5, 0))

    local richText = require("src/RichText").new(progressBg,  getCenterPos(progressBg), cc.size(200, 25), cc.p(0.5, 0.5), 25, 20, MColor.white)
    richText:addText("^c(lable_yellow)"..game.getStrByKey("wr_progress").."：".."^".. taskName , MColor.white)
    richText:setAutoWidth()
    richText:format()

    registerOutsideCloseFunc(bg, function() removeFromParent(bg) end, true)

end

--光翼完成展示
function M:playGetWingEffect()
    local roleEndTile = CMagicCtrlMgr:getInstance():MakeLongMacro(110, 94)
    local startPos = cc.p(G_ROLE_MAIN:getPosition())
    local startTile = G_MAINSCENE.map_layer:space2Tile(startPos)
    local roleEndTileEx = CMagicCtrlMgr:getInstance():MakeLongMacro(startTile.x, startTile.y)

    local action = cc.Sequence:create(
        cc.CallFunc:create(function() log("11111111") 
            G_ROLE_MAIN:setWingNodeVisble(false)
            local layer = createMaskingLayer(7.2, true) 
            G_MAINSCENE:addChild(layer, 1000000)
            end),
        cc.FadeOut:create(0.3),
        cc.CallFunc:create(function() G_ROLE_MAIN:setVisible(false) CMagicCtrlMgr:getInstance():CreateMagic(11033, 0, G_ROLE_MAIN:getTag(), roleEndTile, 0) end), 
        cc.DelayTime:create(0.8),
        cc.MoveTo:create(0.6, G_MAINSCENE.map_layer:tile2Space(cc.p(110, 94))), 
        cc.FadeIn:create(0.1),
        cc.CallFunc:create(function() G_ROLE_MAIN:setVisible(true) end),
        cc.DelayTime:create(2.5), 
        cc.FadeOut:create(0.3),
        cc.CallFunc:create(function() G_ROLE_MAIN:setVisible(false) end),
        cc.CallFunc:create(function() CMagicCtrlMgr:getInstance():CreateMagic(7, 0, G_ROLE_MAIN:getTag(), roleEndTileEx, 0) end),
        cc.MoveTo:create(0.8, G_MAINSCENE.map_layer:tile2Space(startTile)),
        cc.CallFunc:create(function() G_ROLE_MAIN:setWingNodeVisble(true) end),
        cc.FadeIn:create(1),
        cc.CallFunc:create(function() G_ROLE_MAIN:setVisible(true) end)
        )
    G_ROLE_MAIN:runAction(action)
end

--对话任务快速传送
function M:fastTalk( tempData )
    local target_info = tempData.targetData
    local tempLayer , useShoseFun = __shoesGoto( { noText = true ,mapid = target_info.mapID , x = target_info.pos[1].x , y = target_info.pos[1].y } )

    if tempLayer then
        local r_size  = tempLayer:getContentSize()

        local contentRichText = require("src/RichText").new( tempLayer , cc.p(r_size.width/2, r_size.height/2 + 60), cc.size(r_size.width-100, 100), cc.p(0.5, 0.5), 25, 20, color)

        contentRichText:addText( game.getStrByKey("delivery_go1") , MColor.lable_yellow)
        contentRichText:setAutoWidth()
        contentRichText:format()

        local theTime = 5
        local countDownLabel = createLabel( tempLayer , "("..theTime..")" , cc.p( r_size.width/2 , 170 ), cc.p(0.5 , 0.5 ) , 18 , true , 5, nil, MColor.green)

        local function countDownFunc()
            theTime = theTime - 1
            if theTime <= 0 then
                if useShoseFun then useShoseFun() end
                if tolua.cast( tempLayer ,"cc.Sprite") then
                    tempLayer:runAction( cc.Sequence:create(cc.ScaleTo:create(0.0, 0), cc.RemoveSelf:create() ) )  
                end
            else
                countDownLabel:setString( "("..theTime..")" )
            end
        end
        startTimerAction( tempLayer , 1 , true , countDownFunc)
    end

end

return M