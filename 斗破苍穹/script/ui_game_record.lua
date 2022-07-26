require"Lang"
UIGameRecord = {}
local _scrollView = nil
local _item = nil
function UIGameRecord.init()
    local text_title = ccui.Helper:seekNodeByName( UIGameRecord.Widget , "text_title" )
    text_title:setString( Lang.ui_game_record1 )
    local btn_closed = ccui.Helper:seekNodeByName( UIGameRecord.Widget , "btn_closed" )
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_closed then
                UIManager.popScene()
            end
        end
    end
    btn_closed:setPressedActionEnabled( true )
    btn_closed:addTouchEventListener( onEvent )

    _scrollView = ccui.Helper:seekNodeByName( UIGameRecord.Widget , "view" )
    _item = ccui.Text:create()
    _item:setFontName( dp.FONT )
    _item:setFontSize( 20 )
    _item:setTextAreaSize(cc.size(_scrollView:getContentSize().width - 10, 55))
    --_item:setString( "比赛记录比赛记录比赛记录比赛记录比赛记录比赛记录比赛记录比赛记录比赛记录比赛记录比赛记录比赛记录比赛记录比赛记录比赛记录比赛记录比赛记录" )	
    _item:setPositionX( _scrollView:getContentSize().width / 2 )
    _item:retain()
    
end
local function setScrollViewItem( item , data )
  --  item:pushBackElement (ccui.RichElementText:create(1, cc.c3b(255,255,255), 255, data .. "   ", dp.FONT, 18))
    item:setString( data )
end
function UIGameRecord.setup()
    UIManager.showLoading()
    netSendPackage( { header = StaticMsgRule.challengeRecord , msgdata = {} } , function ( pack )
        local data = pack.msgdata.string.recordList
        local obj = {}
        _scrollView:removeAllChildren()
        if data then
            obj = utils.stringSplit( data , ";")
        end
        local tempObj = {}
        for i = 1 , #obj do
            tempObj[ i ] = obj[ #obj - i + 1 ]
        end
        utils.updateScrollView( UIGameRecord , _scrollView , _item , tempObj , setScrollViewItem )
    end)
    
end
function UIGameRecord.free()
    
end
