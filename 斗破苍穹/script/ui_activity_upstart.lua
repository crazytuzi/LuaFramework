require"Lang"
UIActivityUpstart = {}
local _data = nil
local _obj = nil
local _reward = nil
local MIN_COUNT = 200
function UIActivityUpstart.init()
    local btn_help = ccui.Helper:seekNodeByName( UIActivityUpstart.Widget , "btn_help" )
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_help then
                UIAllianceHelp.show( { type = 19 , titleName = Lang.ui_activity_upstart1 } )
            end
        end
    end
    btn_help:setPressedActionEnabled( true )
    btn_help:addTouchEventListener( onEvent )
end

local function refreshInfo()
    for i = 1 , 3 do
        local image_info = nil
        local image_frame = nil
        if i == 1 then
            image_info = ccui.Helper:seekNodeByName( UIActivityUpstart.Widget , "image_info_one" )
            image_frame = ccui.Helper:seekNodeByName( UIActivityUpstart.Widget , "image_frame_one" )
        elseif i == 2 then
            image_info = ccui.Helper:seekNodeByName( UIActivityUpstart.Widget , "image_info_two" )
            image_frame = ccui.Helper:seekNodeByName( UIActivityUpstart.Widget , "image_frame_two" )
        elseif i == 3 then
            image_info = ccui.Helper:seekNodeByName( UIActivityUpstart.Widget , "image_info_three" )
            image_frame = ccui.Helper:seekNodeByName( UIActivityUpstart.Widget , "image_frame_three" )
        end

        local goodsData = utils.getItemProp( _reward[ i ] )
        image_frame:loadTexture( goodsData.frameIcon )
        local image_good = image_frame:getChildByName( "image_good" )--物品icon
        image_good:loadTexture( goodsData.smallIcon )
        local text_number = image_frame:getChildByName( "text_number" )--物品数量×20
        text_number:setString( "×"..goodsData.count )
        utils.showThingsInfo(image_good, goodsData.tableTypeId, goodsData.tableFieldId)--点击小图标展示详细

        if #_obj >= i then
           -- image_info:setVisible( true )
            local image_player = image_info:getChildByName( "image_frame_player" ):getChildByName( "image_player" )--头像
            image_info:getChildByName( "image_frame_player" ):setVisible( true )
            image_player:loadTexture( "image/"..DictUI[ tostring( DictCard[ tostring( _obj[ i ][ 5 ] ) ].smallUiId ) ].fileName )
            local text_name = image_info:getChildByName( "text_name" )--联盟名字
            text_name:setString( Lang.ui_activity_upstart2.. _obj[ i ][ 8 ] )
            local text_alliance = image_info:getChildByName( "text_alliance" )--战队名字 
            text_alliance:setString( _obj[ i ][ 2 ] )
            local function onImageEvent( sender , eventType )
                if eventType == ccui.TouchEventType.ended then
                    if sender == image_player then
                        UIAllianceTalk.show({ playerId = _obj[ i ][ 1 ] , userName = _obj[ i ][ 2 ] , userLvl = _obj[ i ][ 3 ] , userFight = _obj[ i ][ 4 ] , userUnio = _obj[ i ][ 8 ] , headId = _obj[ i ][ 5 ] , vip = _obj[ i ][ 6 ] , accountId = _obj[ i ][ 10 ] , serverId = _obj[ i ][ 11 ] })
                    end
                end
            end
            image_player:setTouchEnabled( true )
            image_player:addTouchEventListener( onImageEvent )
        else
            local image_player = image_info:getChildByName( "image_frame_player" )
            image_player:setVisible( false )
            local text_name = image_info:getChildByName( "text_name" )--联盟名字
            text_name:setString( Lang.ui_activity_upstart3 )
            local text_alliance = image_info:getChildByName( "text_alliance" )--战队名字 
            text_alliance:setString( Lang.ui_activity_upstart4 )
           -- image_info:setVisible( false )
        end
    end
end
function UIActivityUpstart.setup()
    local startTime , endTime = _data.string["4"] , _data.string["5"]   
    local timeData = utils.changeTimeFormat( startTime )
    local timeData1 = utils.changeTimeFormat( endTime )
    local text_refresh_time = ccui.Helper:seekNodeByName( UIActivityUpstart.Widget , "text_refresh_time" )
    text_refresh_time:setString( Lang.ui_activity_upstart5..timeData[2]..Lang.ui_activity_upstart6..timeData[3]..Lang.ui_activity_upstart7..timeData[4]..Lang.ui_activity_upstart8..timeData1[2]..Lang.ui_activity_upstart9..timeData1[3]..Lang.ui_activity_upstart10..timeData1[4]..Lang.ui_activity_upstart11 )
    local function netCallbackFunc( pack )
        local data = utils.stringSplit( pack.msgdata.string.list , "/" )
        _obj = {}
        for key ,obj in pairs( data ) do
            local thing = utils.stringSplit( obj , "|" )
            if tonumber( thing[9] ) >= MIN_COUNT then
                table.insert( _obj , thing )
            end
            if tonumber( key ) == 3 then
                break
            end
        end
        local thingReward1 = utils.stringSplit( pack.msgdata.string["1"] , ";" )
        local thingReward2 = utils.stringSplit( pack.msgdata.string["2"] , ";" )
        local thingReward3 = utils.stringSplit( pack.msgdata.string["3"] , ";" )
        _reward = {}
        table.insert( _reward , thingReward1[ 1 ] )
        table.insert( _reward , thingReward2[ 1 ] )
        table.insert( _reward , thingReward3[ 1 ] )
        refreshInfo()
    end
    netSendPackage( {
        header = StaticMsgRule.enterRed,
        msgdata = { }
    } , netCallbackFunc ) 
--    netSendPackage( {
--        header = StaticMsgRule.viewRichRank,
--        msgdata = { }
--    } , nil )   
end
function UIActivityUpstart.free()
    _data = nil
    _obj = nil
    _reward = nil
end
function UIActivityUpstart.onActivity(_params)
    _data = _params  
end
