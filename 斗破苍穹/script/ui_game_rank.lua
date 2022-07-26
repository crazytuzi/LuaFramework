require"Lang"
UIGameRank = {}
local _scrollView = nil
local _item = nil
local _score = nil
function UIGameRank.init()
    local btn_close = ccui.Helper:seekNodeByName( UIGameRank.Widget , "btn_close" )
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_close then
                UIManager.popScene()
            end
        end
    end
    btn_close:setPressedActionEnabled( true )
    btn_close:addTouchEventListener( onEvent )

    _scrollView = ccui.Helper:seekNodeByName( UIGameRank.Widget , "view_list" )
    _item = _scrollView:getChildByName("image_di_ranking")
    _item:getChildByName( "text_hint" ):setVisible( false )
    _item:retain()
end
local function setScrollViewItem( item , data )
    --instPlayerId/head/name/score|...
    local obj = utils.stringSplit( data , "/" )
    local image_frame_player = item:getChildByName( "image_frame_player" )
    image_frame_player:getChildByName( "image_player" ):loadTexture( "image/" .. DictUI[ tostring( DictCard[ tostring( obj[ 2 ] ) ].smallUiId ) ].fileName ) 
    image_frame_player:getChildByName( "text_name" ):setString( obj[3] )
    image_frame_player:getChildByName( "text_lv" ):setString( Lang.ui_game_rank1 .. obj[ 4 ] )
    local ji , duan = UIGame.getDuanWei( obj[ 4 ] )
    image_frame_player:getChildByName( "text_alliance" ):setString( string.upper( ji ) .. Lang.ui_game_rank2 .. duan  .. Lang.ui_game_rank3 )
   -- print( obj[5] )
    image_frame_player:getChildByName( "text_ranking" ):setString( obj[ 5 ] )
end
function UIGameRank.setup()
    _scrollView:removeAllChildren()
    UIManager.showLoading()
    netSendPackage( { header = StaticMsgRule.challengeRank , msgdata = {} } , function ( pack )
        local rank = pack.msgdata.string.rank
        local rankInfos = utils.stringSplit( rank , "|" )
        for i = 1 , #rankInfos do
            rankInfos[ i ] = rankInfos[ i ] .. "/" .. i
        end
        utils.updateScrollView( UIGameRank , _scrollView , _item , rankInfos , setScrollViewItem )

        local myRank = pack.msgdata.int.myRank
        local image_basemap = ccui.Helper:seekNodeByName( UIGameRank.Widget , "image_basemap" )
        image_basemap:getChildByName( "text_lv" ):setString( Lang.ui_game_rank4 .. _score )
        image_basemap:getChildByName( "text_name" ):setString( net.InstPlayer.string[ "3" ] )
        image_basemap:getChildByName( "text_rank" ):setString( Lang.ui_game_rank5 .. myRank )
    end)
end
function UIGameRank.free()
    _score = nil
end
function UIGameRank.setData( data )
    _score = data.score
end
