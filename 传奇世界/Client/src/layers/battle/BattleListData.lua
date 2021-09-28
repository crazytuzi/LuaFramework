--[[ 挑战数据存储  ]]--
local M = {}
function M:init()
    M.D = { 
            tabData = {} ,          --页签数据
            nowIntegral = 0 ,       --当前积分
            boxAward = {},          --活跃宝箱数据
            pageIndex = 0 ,         --当前选中的页面
            backData = { list = {} },          --找回数据
            clockNum = -1   ,         --活动提示计时器
            wftxNum = 0     ,       --活动提示次数
            wftxDownTime = 0  ,          --活动提示间隔
            time = nil ,            --计时器
            isOnline = false ,            --是否在线一小时
        }
    M.F = {}
    M.D.tabData = {
            { name = game.getStrByKey( "battle_every" ) ,    redState = false , celldata = {} } ,    --限时
            { name = game.getStrByKey( "battle_time" ) ,   redState = false , celldata = {} } ,    --日常
            { name = game.getStrByKey( "faction" ) ,  redState = false , celldata = {} } ,    --行会
            { name = game.getStrByKey( "battle_empire" ) ,    redState = false , celldata = {} } ,    --即将
            }      


    local cfg = getConfigItemByKey( "ActivityNormalDB" , "q_id"  )
    for i , v in pairs( cfg ) do 
        local celldata = M.D.tabData[ v.q_tab ]["celldata"]
        v.redState = false

        if v.q_go == "a12"  then
        	if G_NO_OPEN_PAY == false then
	    		celldata[ #celldata + 1 ] = v
        	end
        else
    		celldata[ #celldata + 1 ] = v
        end
    end

    local function refreshTopData( buff )

        if M.D.pageIndex  ~= 0 and DATA_Battle.BattleLayer then
            --刷新界面
            g_msgHandlerInst:sendNetDataByTableExEx( ACTIVITY_NORMAL_CS_REQ , "ActivityNormalReq" , { tab = M.D.pageIndex } )
        end

        local t = g_msgHandlerInst:convertBufferToTable( "ActivityNormalActiveness" , buff ) 
        
        M.D.nowIntegral = t.nowIntegral 
        for  i , v in ipairs( t.activeness ) do
            M.D.boxAward[i] = { integral = v.integral ,  status = v.status , awards = FORMAT_AWARDS( v.reward ) } --status 0可领取 1未达成 2已领取

        end
        table.sort( M.D.boxAward , function( a , b ) return a.integral<b.integral end )
        M.D.tabData[1]["redState"] = t.redDot1
        -- if mainBattleRed == false then mainBattleRed = M.D.tabData[1]["redState"] end
        -- M.tabData[2]["redState"] = t.redDot2(暂时无效数据)
        -- M.tabData[3]["redState"] = t.redDot3(暂时无效数据)
        -- M.tabData[4]["redState"] = t.redDot4(暂时无效数据)

        -- if TOPBTNMG then TOPBTNMG:showRedMG("Battle", mainBattleRed ) end
        if DATA_Battle.BattleLayer then DATA_Battle.BattleLayer:refreshDataFun() end
        if DATA_Battle.BattleLayer and DATA_Battle.BattleLayer.__refreshTopFun then 
            DATA_Battle.BattleLayer.__refreshTopFun()
        end

        DATA_Battle:showMainTip()
        DATA_Battle:countRedNum()        
    end
    g_msgHandlerInst:registerMsgHandler( ACTIVITY_NORMAL_SC_ACTIVENESS , refreshTopData ) 

    --单个页面数据返回
    local function receivePageData( buff )

        local needRefreshData = false
        local t = g_msgHandlerInst:convertBufferToTable( "ActivityNormalRet" , buff ) 
        for i , v in ipairs( t.info ) do
            local sc = cfg[v.id]
            if sc then
                local tabData = M.D.tabData[ sc.q_tab ]
                for _ , data in pairs( tabData.celldata ) do
                    if data.q_id == v.id then

                        data.errCode = 0
                        if v.errCode then
                            data.errCode = v.errCode--0可以参加活动  1 活动未开启 2等级不足  3没有行会  4行会等级不足
                        end

                        data.arg = 0
                        if v.arg then
                            data.arg = v.arg
                        end

                        data.time_num = 0 
                        if v.times then
                            data.time_num = v.times
                        end
                        
                        if data.q_tab == 2 then
                            if data.isInit == nil  then
                                --限时初始化一次就好，其它时间不再改变数据
                                DATA_Battle:setRedData( data["q_key"] or data["q_id"] , ( data.errCode == 0 and data.time_num <= data.q_times ) , nil , true )
                                data.isInit = true
                                needRefreshData = true
                            end
                        else
                            local isRed =  data.errCode == 0 and data.time_num < data.q_times
                            if data.q_tab == 3 then
                                isRed =  data.errCode == 0 and data.time_num <= data.q_times
                            end
                            DATA_Battle:setRedData( data["q_key"] or data["q_id"] ,  isRed , nil , true )
                            needRefreshData = true
                        end


                    end
                end
            end
        end

        if DATA_Battle.BattleLayer then
            if needRefreshData then
                DATA_Battle.BattleLayer:refreshDataFun()
            end

            if DATA_Battle.BattleLayer.__refreshRightFun then 
                DATA_Battle.BattleLayer.__refreshRightFun()
            end
        end

        DATA_Battle:countRedNum()

    end
    g_msgHandlerInst:registerMsgHandler( ACTIVITY_NORMAL_SC_RET , receivePageData ) 


    local function handlerFun( buff )
        local t = g_msgHandlerInst:convertBufferToTable( "PushActivityStart" , buff )
        -- local isOpen = t.open or false  --火热进行中(印章是否展示)
        local isRed = t.canJoin   --是否有红点（有红点就是可以参加的活动）
        local tag = nil
        for k ,v in pairs( cfg ) do
            if v.q_activity_id == t.id then
                tag = v
            end
        end

        if tag then
            DATA_Battle:setRedData( tag["q_key"] , isRed , ( isRed and true or false ) )

            if tag.q_key == "XWZJ" then
                --王城赐福
                g_msgHandlerInst:sendNetDataByTableExEx( GIVEWINE_CS_GETWINE_NUM, "GetWineNumReqProtocol", {} )
            end 

            --怪物攻城
            if tag.q_key == "XZKP" and G_MAINSCENE then
                G_MAINSCENE:removeActivityRank()
            end
    
            if isRed then
                if G_MAINSCENE then G_MAINSCENE:createNewActivityNode( tag ) end
            else
                --活动结束
                if G_MAINSCENE then G_MAINSCENE:removeActivityIcon( tag.q_key ) end
            end
        end
        
        DATA_Battle:countRedNum()
    end
    g_msgHandlerInst:registerMsgHandler( PUSH_SC_MSG_START , handlerFun )


    local function resultFun( buff )
        M.D.backData = g_msgHandlerInst:convertBufferToTable( "ActivityNormalFindRewardListRet" , buff )
        local num = #M.D.backData.list          
        if DATA_Battle.BattleLayer and DATA_Battle.BattleLayer.yesterdayRed then DATA_Battle.BattleLayer.yesterdayRed:setVisible( num>0 ) end
        DATA_Battle:countRedNum()
        
        if DATA_Battle.F.BackLayer_refreshLayout then
            DATA_Battle.F.BackLayer_refreshLayout()
        end
    end
    g_msgHandlerInst:registerMsgHandler( ACTIVITY_NORMAL_SC_FIND_REWARD_LIST_RET , resultFun )                  --返回找回数据

    local function resultTimeFun( buff )
        local t = g_msgHandlerInst:convertBufferToTable( "ActivityPushOnlineTime" , buff )
        M.D.isOnline = ( t.time >= 3600 )
    end
    g_msgHandlerInst:registerMsgHandler( ACTIVITY_SC_PUSH_ONLINE_TIME , resultTimeFun )                  --在线时间是否一个小时

end


--日常提示语展示控制
function M:showMainTip()
    if  TOPBTNMG and TOPBTNMG.battleTips then
        local lv =  MRoleStruct:getAttr( ROLE_LEVEL ) 
        if lv and lv >= 30 and lv <= 40 and M.D.nowIntegral < 75 then
            TOPBTNMG.battleTips:setVisible( true )
        else
            TOPBTNMG.battleTips:setVisible( false )
        end
    end
end
--刷新红点个数
function M:countRedNum()

    local redNum = 0
    for key , value in pairs( M.D.tabData ) do 
        for k , v in pairs( value.celldata ) do 
            if v.redState == true then redNum = redNum + 1 end
        end
    end

    for k , v in pairs( M.D.boxAward ) do 
        if v.status == 0 then redNum = redNum + 1 end
    end

    local num = #M.D.backData.list          
    if num > 0 then redNum = redNum + 1 end

    if TOPBTNMG then 
        TOPBTNMG:showRedMG("Battle", redNum>0 ) 
        -- if TOPBTNMG.battle_red_num then TOPBTNMG.battle_red_num:setString( redNum <= 9 and redNum or "9+" ) end
    end
    
end

function M:setSelectIndex( _idx )
    M.D.pageIndex = _idx
end
function M:getBackData()
    return M.D.backData
end
function M:getData()
    return M.D
end

function M:setRedData( _key , _isRed , isOpen , isNotRefreshData)
    for k , v in pairs( M.D.tabData )  do
        local celldata = v.celldata
        local redState = false
        if celldata then
            for h,m in pairs( celldata ) do
                -- if m.errCode == 0 then
                    if type( _key ) == "string" then
                        if m.q_key == _key then 
                            m.redState = _isRed 
                        end
                    elseif type( _key ) == "number" then
                        if m.q_id == _key then 
                            m.redState = _isRed 
                        end
                    end
                -- end
                if m.redState == true then redState = true end
            end
        end
        v.redState = redState
    end

    if not isNotRefreshData then
        DATA_Battle:countRedNum()
        if DATA_Battle.BattleLayer then DATA_Battle.BattleLayer:refreshDataFun() end
    end
end

function M:getRedData(_key)
    if _key then
        if M.D.tabData[_key] then
            return  M.D.tabData[_key].redState
        end

        for k, v in pairs( M.D.tabData ) do
            for m, n in pairs( v.celldata) do
                if  n.q_key ~= nil and n.q_key == _key then
                    local isRed = n.redState
                    return isRed
                end
            end
        end
    end

    return false
end

function M:getCellDataFromAllData(markId)
    for k,v in pairs(M.D.tabData) do
        for m,n in pairs(v.celldata) do
            if n.q_mark == markId then
                return n
            end
        end
    end
    return nil
end

function M:getCellData( _key )
    if _key then return M.D.tabData[_key] end
    return M.D.tabData
end

--格式化
function M:formatTime( str )

    if str == nil or str == "" then
        return { game.getStrByKey( "every_day" ) }
    end
    local result = {}
    local tab = unserialize( str )

    for i , v in ipairs( tab ) do
        local str = "" 
        if #v.week == 0 then
            if i == 1 then str = game.getStrByKey( "faction_bossTime2" ) .. " " end
        else
            if i == 1 then str = game.getStrByKey( "faction_bossTime3" ) end
            for j , c in ipairs( v.week ) do
                str = str .. game.getStrByKey( "week_" ..c ) .. (  j == #v.week and " " or "、" )
            end
        end
        v.time[1] = v.time[1] < 10 and ("0" .. v.time[1] ) or v.time[1] 
        v.time[2] = v.time[2] < 10 and ("0" .. v.time[2] ) or v.time[2] 
        v.time[4] = v.time[4] < 10 and ("0" .. v.time[4] ) or v.time[4] 
        v.time[5] = v.time[5] < 10 and ("0" .. v.time[5] ) or v.time[5] 

        str = str .. string.format( "%s:%s-%s:%s" ,v.time[1] , v.time[2] , v.time[4] , v.time[5] )

        result[i] = str 
    end

    return result 
end

--本地数据存取
function M:setRecord( str ,  _key , _value )
    local readFun = nil
    local writeFun = nil

    readFun = function( key )
        local recordStr = getLocalRecordByKey( 2 , "wftx" .. tostring( userInfo.currRoleStaticId  )  )
        local tempTab = unserialize( recordStr )

        --初始化
        if tablenums( tempTab ) == 0 then
            local inifCfg = { todayNum = 0 , day = os.date( "*t" ,os.time() )["day"] , lastShowID = { 0 , 0 , 0 , 0 , 0 , 0 ,} }
            local dateStr = serialize( inifCfg )
            setLocalRecordByKey( 2 , "wftx" ..  tostring( userInfo.currRoleStaticId )  , dateStr )
            if key then return inifCfg[key] end
            return inifCfg
        end

        if key then 
            local value = tempTab[key] 
            -- if key == "lastShowID" then
            --     value = unserialize( value )
            -- end
            return value
        end
        return tempTab
    end
    writeFun = function( key , value )
        local tempTab = readFun()
        tempTab[ key ] = value
        local dateStr = serialize( tempTab )
        setLocalRecordByKey( 2 , "wftx" ..  tostring( userInfo.currRoleStaticId )  , dateStr )
    end

    if str == "r" then
        return readFun( _key )
    end

    if str == "w" then
        return writeFun( _key , _value )
    end

end

--玩法提示增加一次并重置间隔倒计时
function M:resetTime( num )
    if num then
        --登陆时检查本地记录
        if os.date( "*t" ,os.time() )["day"] == DATA_Battle:setRecord( "r" , "day") then
            --当天的数据
            M.D.wftxNum = ( num > 3 and 3 or num )
        else
            --不是当天数据，清0重记
            M.D.wftxNum = 0
            DATA_Battle:setRecord( "w" , "todayNum" , M.D.wftxNum )
        end
    else
        M.D.wftxNum = M.D.wftxNum + 1    
        if M.D.wftxNum > 3 then M.D.wftxNum = 3 end
        DATA_Battle:setRecord( "w" , "todayNum" , M.D.wftxNum )
        M.D.wftxDownTime = 30*60--设置间隔时间30分钟
    end
end

--日常玩法提醒
function M:beginTime( _type )
    if G_MAINSCENE then
        local function timeFun()
            if M.D.wftxDownTime > 0 then M.D.wftxDownTime = M.D.wftxDownTime - 10 return end --需要间隔30分钟
            if G_MAINSCENE.wftxFlag or G_MAINSCENE.mailFlag then M.D.clockNum = 0 return end --屏幕存在按钮不计时

            if _type == 0 or _type == AUTO_ATTACK then
                M.D.clockNum = M.D.clockNum + 10
                if _type == 0  then
                    if M.D.clockNum >= 60*3 then G_MAINSCENE:showWftx( 1 ) end --静止站立三分钟提示
                elseif _type == 4 then
                    if M.D.clockNum >= 60*15 then G_MAINSCENE:showWftx( 2 ) end --自动挂机15分钟提示
                end
            else
                M.D.clockNum = 0
            end
        end
        if M.D.time then M.D.time:stopAllActions() end
        M.D.time = startTimerActionEx( G_MAINSCENE ,  10 , true , timeFun )
    end
end

--根据活跃度随机选出一个未完成的日常任务
function M:getRandomData()
    local tempTab = {}
    local data = M.D
    local findType = 1 
    if data.nowIntegral < 100 then
        findType = 1
    elseif data.nowIntegral > 100 and data.nowIntegral < 125 then
        findType = 2 
    end
    
    local idStr = DATA_Battle:setRecord( "r" , "lastShowID"  )
    local usedID = {}
    for k , v in pairs( idStr ) do
        usedID[ v .. "" ] = true
    end

    local tempTab = {}
    for k , v in pairs( data.tabData ) do
        for k1 , v1 in pairs( v.celldata ) do
            if v1.q_class == findType and v1.errCode and v1.errCode == 0 and v1.time_num < v1.q_times and usedID[ v1.q_mark .. ""]  == nil then
                table.insert( tempTab , v1 )
            end
        end
    end

    if #tempTab == 0 then return nil end

    local itemData = tempTab[ math.random( 1 , #tempTab ) ]
    table.remove( idStr ) 
    table.insert( idStr , 1 , itemData.q_mark )
    DATA_Battle:setRecord( "w" , "lastShowID" , idStr ) 
    if DATA_Battle then DATA_Battle:resetTime() end

    return itemData
end

DATA_Battle = M

return M
