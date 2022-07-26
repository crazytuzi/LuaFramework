require"Lang"
UIFireRank = {}
local _dataThings = nil
local _scrollView = nil
local _item = nil
local _item1 = nil --历史排行
local _tag = nil
local DEBUG = false
function netCallbackFunc(data)
    local code = tonumber(data.header)
    if code == StaticMsgRule.enemyPlayerInfo then
        pvp.loadGameData(data)
        UIManager.pushScene("ui_arena_check")
    end
end
local function setScrollViewItem( item , data )
    --排名|头像Id|等级|玩家名|当日最大层数|当日击杀怪物数
    local thing = utils.stringSplit( data , "|" )
    local image_frame_player = item:getChildByName( "image_frame_player" )
  --  cclog( "thing[ 2 ] :" .. thing[ 2 ] )
    image_frame_player:loadTexture( utils.getQualityImage( dp.Quality.card , DictCard[ tostring( thing[ 2 ] ) ].qualityId , dp.QualityImageType.small ) )
    image_frame_player:getChildByName( "image_player" ):loadTexture( "image/" .. DictUI[ tostring( DictCard[ tostring( thing[ 2 ] ) ].smallUiId ) ].fileName ) --头像
    image_frame_player:getChildByName( "text_lv" ):setString( "LV." .. thing[ 3 ] ) --等级
    image_frame_player:getChildByName( "text_name" ):setString( thing[ 4 ] ) --玩家名字
    image_frame_player:getChildByName( "text_ranking" ):setString( thing[ 1 ] ) --排名
    image_frame_player:getChildByName( "text_floor" ):setString( Lang.ui_fire_rank1..thing[ 5 ] ) --闯关层数
    if _tag == 1 then
        image_frame_player:getChildByName( "text_monster" ):setString( Lang.ui_fire_rank2..thing[ 6 ] ) --击杀怪物
    end

    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == image_frame_player then
                local instPlayerId = nil
                if _tag == 1 then
                    instPlayerId = tonumber( thing[ 7 ] )
                elseif _tag == 2 then
                    instPlayerId = tonumber( thing[ 6 ] )
                end
                if instPlayerId then
                    UIManager.showLoading()
                    UIArenaCheck.playerId = instPlayerId
                    netSendPackage( { header = StaticMsgRule.enemyPlayerInfo, msgdata = { int = { playerId = instPlayerId } } }, netCallbackFunc)
                end
            end
        end
    end
    image_frame_player:setTouchEnabled( true )
    image_frame_player:addTouchEventListener( onEvent )

end
local function callBack( pack )   
    local selfInfo = utils.stringSplit( pack.msgdata.string["2"] , "|" )
    _dataThings = utils.stringSplit( pack.msgdata.string["1"] , "/" ) --{ "1|88|20|123|0|0" , "2|89|20|123|0|0" }
    _scrollView:removeAllChildren()
    local image_basemap = ccui.Helper:seekNodeByName( UIFireRank.Widget , "image_basemap" )
    image_basemap:getChildByName( "text_name" ):setString( net.InstPlayer.string["3"] )
    image_basemap:getChildByName( "text_floor_0" ):setString( Lang.ui_fire_rank3 .. selfInfo[ 2 ] )--闯关层数
    local text_rank = image_basemap:getChildByName( "text_rank" )--当前排名：35
    local text_monster_0 = image_basemap:getChildByName( "text_monster_0" )--击杀怪物：1000
    if _tag == 1 then
        text_monster_0:setVisible( true )
        text_monster_0:setString( Lang.ui_fire_rank4 .. selfInfo[ 3 ] )
        utils.updateScrollView( UIFireRank , _scrollView , _item , _dataThings , setScrollViewItem )
        text_rank:setString( Lang.ui_fire_rank5..selfInfo[ 1 ] )
    else
        text_monster_0:setVisible( false )
        utils.updateScrollView( UIFireRank , _scrollView , _item1 , _dataThings , setScrollViewItem )
        text_rank:setString( Lang.ui_fire_rank6..selfInfo[ 1 ] )
    end  
end
local function netSendData()
    if DEBUG then
        callBack()
        return
    end
    UIManager.showLoading()
    netSendPackage( { header = StaticMsgRule.clickFireFamRank , msgdata = { int  = { type = _tag } } } , callBack )
end
local function refreshItem()
    local btn_rank = ccui.Helper:seekNodeByName( UIFireRank.Widget , "btn_rank" ) --历史
    local btn_level = ccui.Helper:seekNodeByName( UIFireRank.Widget , "btn_level" ) --今日
    if _tag == 2 then
        btn_rank:loadTextureNormal( "ui/yh_btn02.png" )
        btn_rank:setTitleColor( cc.c4b(51,25,4,255) )
        btn_level:loadTextureNormal( "ui/yh_btn01.png" )
        btn_level:setTitleColor( cc.c4b(255,255,255,255) )
    elseif _tag == 1 then
        btn_rank:loadTextureNormal( "ui/yh_btn01.png" )
        btn_rank:setTitleColor( cc.c4b(255,255,255,255) )
        btn_level:loadTextureNormal( "ui/yh_btn02.png" )
        btn_level:setTitleColor( cc.c4b(51,25,4,255) )
    end
    netSendData()
end
function UIFireRank.init()
    local btn_close = ccui.Helper:seekNodeByName( UIFireRank.Widget , "btn_close" )
    local btn_rank = ccui.Helper:seekNodeByName( UIFireRank.Widget , "btn_rank" )
    local btn_level = ccui.Helper:seekNodeByName( UIFireRank.Widget , "btn_level" ) 
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_close then
                UIManager.popScene()
            elseif sender == btn_rank then--历史排行
                if _tag == 2 then
                    return
                end
                _tag = 2
                refreshItem()
            elseif sender == btn_level then--今日排行
                if _tag == 1 then
                    return
                end
                _tag = 1
                refreshItem()
            end
        end
    end
    btn_close:setPressedActionEnabled( true )
    btn_close:addTouchEventListener( onEvent )
    btn_rank:setPressedActionEnabled( true )
    btn_rank:addTouchEventListener( onEvent )
    btn_level:setPressedActionEnabled( true )
    btn_level:addTouchEventListener( onEvent )
    _scrollView = ccui.Helper:seekNodeByName( UIFireRank.Widget , "view_rank" )
    _item = _scrollView:getChildByName( "image_di_ranking" )
    _item:retain()
    _item1 = _item:clone()
    local image_frame_player = _item1:getChildByName( "image_frame_player" )
    local text_name = image_frame_player:getChildByName( "text_name" )
    text_name:setPositionY( text_name:getPositionY() - 10 )
    local text_floor = image_frame_player:getChildByName( "text_floor" )
    text_floor:setPositionY( text_floor:getPositionY() - 10 )
    image_frame_player:getChildByName( "text_monster" ):setVisible( false )
    _item1:retain()
end

function UIFireRank.setup()
    _tag = 1
    refreshItem()    
end
function UIFireRank.free()
    _dataThings = nil
    _tag = nil
end
