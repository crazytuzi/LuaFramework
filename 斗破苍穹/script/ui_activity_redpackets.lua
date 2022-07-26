require"Lang"
UIActivityRedpackets = {}
local _scrollView = nil
local _item = nil
local _data = nil
local _redCount = nil
local _name = nil
function UIActivityRedpackets.init()
    local image_frame_red = ccui.Helper:seekNodeByName( UIActivityRedpackets.Widget , "image_frame_red" ) --领取红包
    local btn_help = ccui.Helper:seekNodeByName( UIActivityRedpackets.Widget , "btn_help" )
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == image_frame_red then
                if _redCount > 0 then
                    UIActivityRedpacketsInfo.setName( _name , _redCount )
                    UIManager.pushScene( "ui_activity_redpackets_info" )
                else
                    UIManager.showToast( Lang.ui_activity_redpackets1 )
                end
            elseif sender == btn_help then
                UIAllianceHelp.show( { type = 18 , titleName = Lang.ui_activity_redpackets2 } )
            end
        end
    end
    image_frame_red:setTouchEnabled( true )
    image_frame_red:addTouchEventListener( onEvent )
    btn_help:setPressedActionEnabled( true )
    btn_help:addTouchEventListener( onEvent )

    local text_refresh_time = ccui.Helper:seekNodeByName( UIActivityRedpackets.Widget , "text_refresh_time" )
    text_refresh_time:setPositionX( text_refresh_time:getPositionX() - 180 )

    _scrollView = ccui.Helper:seekNodeByName( UIActivityRedpackets.Widget , "view_list_gem" )
    _item = _scrollView:getChildByName( "image_di_ranking" )
    _item:retain()
end
local function setViewItem( item , obj )
    
    local label_rank = ccui.Helper:seekNodeByName( item , "label_rank" )--排名
    label_rank:setString( obj[ #obj ] )
    if tonumber( obj[ #obj ] ) <= 3 then
       -- label_rank:setFntFile("ui/jjc_zi01.fnt")-- jjc_zi02.fnt
        label_rank:getParent():loadTexture("ui/lm"..tonumber( obj[#obj] )..".png")
        label_rank:setVisible( false )
    else
        label_rank:getParent():loadTexture("ui/qd_2.png")
        --label_rank:setFntFile("ui/jjc_zi02.fnt")-- jjc_zi02.fnt
        label_rank:setVisible( true )
    end
    local image_frame_player = ccui.Helper:seekNodeByName( item , "image_frame_player" )--头像图标框
    local image_player = image_frame_player:getChildByName( "image_player" )--头像
    cclog("headId:  "..obj[ 5 ])
    image_player:loadTexture( "image/"..DictUI[ tostring( DictCard[ tostring( obj[ 5 ] ) ].smallUiId ) ].fileName )
    local text_name = ccui.Helper:seekNodeByName( item , "text_name" ) --联盟名字
    text_name:setString( Lang.ui_activity_redpackets3..obj[ 8 ] )
    local text_alliance = ccui.Helper:seekNodeByName( item , "text_alliance" )--战队名字
    text_alliance:setString( obj[ 2 ] )
    local text_number = ccui.Helper:seekNodeByName( item , "text_number" )--红包数量
    text_number:setString( obj[ 9 ] )

end
function UIActivityRedpackets.setup()
    local startTime , endTime = _data.string["4"] , _data.string["5"]   
    local timeData = utils.changeTimeFormat( startTime )
    local timeData1 = utils.changeTimeFormat( endTime )
    local text_refresh_time = ccui.Helper:seekNodeByName( UIActivityRedpackets.Widget , "text_refresh_time" )
    text_refresh_time:setString( Lang.ui_activity_redpackets4..timeData[2]..Lang.ui_activity_redpackets5..timeData[3]..Lang.ui_activity_redpackets6..timeData[4]..Lang.ui_activity_redpackets7..timeData1[2]..Lang.ui_activity_redpackets8..timeData1[3]..Lang.ui_activity_redpackets9..timeData1[4]..Lang.ui_activity_redpackets10 )
    local function netCallbackFunc( pack )
        _redCount = pack.msgdata.int.redCount
        _name = pack.msgdata.string.from
        local image_hint = ccui.Helper:seekNodeByName( UIActivityRedpackets.Widget , "image_hint" )
        local image_red = ccui.Helper:seekNodeByName( UIActivityRedpackets.Widget , "image_frame_red" ):getChildByName("image_red") --领取红包
        if _redCount > 0 then
            image_hint:setVisible( true )
            utils.addFrameParticle( image_red , true )
        else
            image_hint:setVisible( false )
            utils.addFrameParticle( image_red , false )
        end
        local data = utils.stringSplit( pack.msgdata.string.list , "/" )
        local objThing = {}
        for key ,obj in pairs( data ) do
            local thing = utils.stringSplit( obj , "|" )
            thing[ #thing + 1 ] = tonumber( key )
            table.insert( objThing , thing )
        end
        local text_hint = ccui.Helper:seekNodeByName( UIActivityRedpackets.Widget , "text_hint" )
        if #objThing < 1 then
            text_hint:setVisible( true )
        else
            text_hint:setVisible( false )
        end
        _scrollView:removeAllChildren()
        utils.updateScrollView( UIActivityRedpackets , _scrollView , _item , objThing , setViewItem )
    end
    netSendPackage( {
        header = StaticMsgRule.enterRed,
        msgdata = { }
    } , netCallbackFunc )  
end
function UIActivityRedpackets.free()
    _data = nil
    _redCount = nil
    _name = nil
end
function UIActivityRedpackets.onActivity(_params)
    _data = _params  
end
