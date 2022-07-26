require"Lang"
UIGameWin = {}
local _data = nil
local backCall = nil
local continueCall = nil
function UIGameWin.init()
    local btn_back = ccui.Helper:seekNodeByName( UIGameWin.Widget , "btn_back" )
    local btn_out = ccui.Helper:seekNodeByName( UIGameWin.Widget , "btn_out" )
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_back then
                backCall()
            elseif sender == btn_out then
                continueCall()
            end
        end
    end
    btn_back:setPressedActionEnabled( true )
    btn_back:addTouchEventListener( onEvent )
    btn_out:setPressedActionEnabled( true )
    btn_out:addTouchEventListener( onEvent )
end
local function getTeamInfo( index )
    local myTeam = {}
    local enemyTeam = {}
    local myTeamIds = utils.stringSplit( _data.myTeam[ index ] , "_" )
    local enemyIds = utils.stringSplit( _data.pvpTeam[ index ] , "_" )
    for i = 1 , 8 do
        local myTeamId = tonumber( myTeamIds[ i ] )
        if myTeamId and myTeamId > 0 then
            table.insert( myTeam , myTeamId )
        end 
        local enemyId = tonumber( enemyIds[ i ] )
        if enemyId and enemyId > 0 then
            table.insert( enemyTeam , enemyId )
        end 
    end
    return myTeam , enemyTeam
end
function UIGameWin.setup()
    for i = 1 , 3 do
        local panel_war = ccui.Helper:seekNodeByName( UIGameWin.Widget , "panel_war" .. i )
        if i <= ( _data.winCount + _data.failCount ) then
            panel_war:setVisible( true )
            local myTeam , enemyTeam = getTeamInfo( i )
            local image_blue = panel_war:getChildByName( "image_blue" )
            local image_red = panel_war:getChildByName( "image_red" )
            for j = 1 , 3 do
                local image_frame_card = image_blue:getChildByName( "image_frame_card" .. j )
                if j <= #myTeam then
                    image_frame_card:setVisible( true )
                    local formation = net.InstPlayerFormation[ tostring( myTeam[ j ] ) ]
                    image_frame_card:getChildByName( "image_card" ):loadTexture( "image/" .. DictUI[ tostring( DictCard[ tostring( formation.int[ "6" ] ) ].smallUiId ) ].fileName )
                else
                    image_frame_card:setVisible( false )
                end

                local image_frame_card1 = image_red:getChildByName( "image_frame_card" .. j )
                if j <= #enemyTeam then
                    image_frame_card1:setVisible( true )
                    local formation = pvp.InstPlayerFormation[ tostring( enemyTeam[ j ] ) ]
                    image_frame_card1:getChildByName( "image_card" ):loadTexture( "image/" .. DictUI[ tostring( DictCard[ tostring( formation.int[ "6" ] ) ].smallUiId ) ].fileName )
                else
                    image_frame_card1:setVisible( false )
                end               
            end
            if _data.fightInfo[ i ] == 1 then
                image_blue:getChildByName( "image_win" ):setVisible( true )
                image_red:getChildByName( "image_win" ):setVisible( false )
            elseif _data.fightInfo[ i ] == 0 then
                image_blue:getChildByName( "image_win" ):setVisible( false )
                image_red:getChildByName( "image_win" ):setVisible( true )
            end
        else
            panel_war:setVisible( false )
        end
    end
    local image_blue = ccui.Helper:seekNodeByName( UIGameWin.Widget , "image_blue" ) --自己
    image_blue:getChildByName( "text_name_blue" ):setString( net.InstPlayer.string[ "3" ] )
    image_blue:getChildByName( "text_number_blue" ):setString( Lang.ui_game_win1 .. _data.myScore )
    local addScore = tonumber( _data.addMy )
    if addScore < 0 then
        image_blue:getChildByName( "text_number_blue_add" ):setString( "-" .. math.abs( addScore ) )
    else
        image_blue:getChildByName( "text_number_blue_add" ):setString( "+" .. math.abs( addScore ) )
    end
    
    local image_red = ccui.Helper:seekNodeByName( UIGameWin.Widget , "image_red" ) --挑战的
    --id_head_name_vip_unionName_score
    local playerInfo = _data.playerInfo
    image_red:getChildByName( "text_name_red" ):setString( playerInfo[ 3 ] )
    image_red:getChildByName( "text_number_red" ):setString( Lang.ui_game_win2 .. playerInfo[ 6 ] )
    local image_vs = ccui.Helper:seekNodeByName( UIGameWin.Widget , "image_vs" ) --比分
    image_vs:getChildByName( "label_blue" ):setString( _data.winCount )
    image_vs:getChildByName( "label_red" ):setString( _data.failCount )

    local addEnemyScore = tonumber( _data.addEnemy )
    if addEnemyScore < 0 then
        image_red:getChildByName( "text_number_red_add" ):setString( "-" .. math.abs( addEnemyScore ) )
    else
        image_red:getChildByName( "text_number_red_add" ):setString( "+" .. math.abs( addEnemyScore ) )
    end

    local rewards = utils.stringSplit( DictChallengeRewardEvery[ "1" ].reward , ";" )
    for i = 1 , 3 do
        local image_frame_good = ccui.Helper:seekNodeByName( UIGameWin.Widget , "image_frame_good" .. i )
        if i <= #rewards then
            image_frame_good:setVisible( true )
            local thing = utils.getItemProp( rewards[ i ] )
            image_frame_good:loadTexture( thing.frameIcon )
            image_frame_good:getChildByName( "image_good" ):loadTexture( thing.smallIcon )
            image_frame_good:getChildByName( "image_good" ):getChildByName( "text_name" ):setString( thing.name )
            image_frame_good:getChildByName( "image_base_number" ):getChildByName( "text_number" ):setString( thing.count )
        else
            image_frame_good:setVisible( false )
        end
    end
end
function UIGameWin.free()
    _data = nil
    backCall = nil
    continueCall = nil
end
function UIGameWin.setData( data , backC , continueC )
    _data = data
    backCall = backC
    continueCall = continueC
end
