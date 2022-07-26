require"Lang"
UIAllianceMysteriesRank = {}
local _tag = nil --页签
local _scrollView = nil
local _item = nil
local _dataList = nil
local function refreshInfo() -- 选项卡操作
    local tab_button_zuo = ccui.Helper:seekNodeByName( UIAllianceMysteriesRank.Widget , "tab_button_zuo" )
    local tab_button_jin = ccui.Helper:seekNodeByName( UIAllianceMysteriesRank.Widget , "tab_button_jin" )
    if _tag == 1 then 
        tab_button_jin:loadTextureNormal("ui/tk_j_btn02.png")
        tab_button_jin:getChildByName("text_jin"):setTextColor(cc.c4b(255,255,255,255))
        tab_button_zuo:loadTextureNormal("ui/tk_j_btn01.png")
        tab_button_zuo:getChildByName("text_zuo"):setTextColor(cc.c4b(51,25,4,255))
    elseif _tag ==  2 then
        tab_button_zuo:loadTextureNormal("ui/tk_j_btn02.png")
        tab_button_zuo:getChildByName("text_zuo"):setTextColor(cc.c4b(255,255,255,255))
        tab_button_jin:loadTextureNormal("ui/tk_j_btn01.png")
        tab_button_jin:getChildByName("text_jin"):setTextColor(cc.c4b(51,25,4,255))
    end
end
local function getUnioMemberData( id )
    local data = nil
    if UIAllianceMysteries.members then
        for key ,value in pairs( UIAllianceMysteries.members ) do
            if tonumber( value.int["3"] ) == tonumber( id ) then
                data = value 
                break
            end
        end
    end
    return data
end
local function setScrollViewItem( item , obj )
    local image_box = item:getChildByName( "image_box" )
    local function onItemEvent( sender , eventType )
         if eventType == ccui.TouchEventType.ended then
            if sender == image_box then
                cclog( "开宝箱" )
                netSendPackage( { header = StaticMsgRule.dupAward , msgdata = {} } , function ( pack )
                  --  UIManager.showToast( "领取成功" )
                    UIAllianceMysteriesRank.setup( 1 )
                    local goods = pack.msgdata.string.awards
                    utils.showGetThings( goods )
                end)
            end
         end
    end
    
    image_box:addTouchEventListener( onItemEvent )

    local things = utils.stringSplit( obj , "_" )
    local data = getUnioMemberData( things[ 1 ] )

    --fb_bx02_full.png fb_bx02_empty
   --cclog( "  "..things[1] .. "  "..net.InstPlayer.int[ "1" ] )
    if _tag == 2 then
        image_box:setTouchEnabled( false )
        image_box:loadTexture( "ui/fb_bx02.png" )
    elseif tonumber( things[ 3 ]) == 1 then
        image_box:setTouchEnabled( false )
        image_box:loadTexture( "ui/fb_bx02_empty.png" )
    elseif tonumber( things[ 1 ] ) == tonumber( net.InstPlayer.int[ "1" ] ) then
        image_box:setTouchEnabled( true )
        image_box:loadTexture( "ui/fb_bx02_full.png" )
    else
        image_box:setTouchEnabled( false )
        image_box:loadTexture( "ui/fb_bx02_empty.png" )
    end
    if data then
        local dictCardId = utils.stringSplit(data.string["13"],"_")[1]
        local isAwake = utils.stringSplit(data.string["13"],"_")[2]
        local dictCard = DictCard[tostring(dictCardId)]
        local image_frame_big = item:getChildByName( "image_frame_big" )   
        utils.addBorderImage( StaticTableType.DictCard , dictCard.id , image_frame_big )
        if tonumber(isAwake) == 1 then
            image_frame_big:getChildByName("image_big"):loadTexture( "image/" .. DictUI[tostring(dictCard.awakeSmallUiId)].fileName )
        else
            image_frame_big:getChildByName("image_big"):loadTexture( "image/" .. DictUI[tostring(dictCard.smallUiId)].fileName )
        end
        image_frame_big:getChildByName("text_name"):setString( data.string["10"] )

        item:getChildByName("text_get_number"):setVisible( false )
        local getThing = item:getChildByName("text_get")
        getThing:setPositionY( getThing:getPositionY() + 15 )
        getThing:setString( Lang.ui_alliance_mysteries_rank1..things[ 2 ] )
    else
        local dictCard = DictCard[tostring(51)]
        local image_frame_big = item:getChildByName( "image_frame_big" )   
        utils.addBorderImage( StaticTableType.DictCard , dictCard.id , image_frame_big )
        image_frame_big:getChildByName("image_big"):loadTexture( "image/" .. DictUI[tostring(dictCard.smallUiId)].fileName )
        image_frame_big:getChildByName("text_name"):setString( Lang.ui_alliance_mysteries_rank2 )

        item:getChildByName("text_get_number"):setVisible( false )
        local getThing = item:getChildByName("text_get")
        getThing:setPositionY( getThing:getPositionY() + 15 )
        getThing:setString( Lang.ui_alliance_mysteries_rank3..things[ 2 ] )
    end
end
local function refreshScrollView() -- 刷新页面
    _scrollView:removeAllChildren()
    utils.updateScrollView( UIAllianceMysteriesRank.Widget , _scrollView , _item , _dataList , setScrollViewItem )
end
local function callBack( pack )
    --string.list = (id_score_state;id_score_state...)
    if pack.msgdata.string.list then
        _dataList = utils.stringSplit( pack.msgdata.string.list , ";" )
    else
        _dataList = {}
    end
    refreshScrollView()
end
local function netSendData()
    local index = 0
    if _tag == 1 then
        index = 1
    elseif _tag == 2 then
        index = 0
    end
    local sendData = {
        header = StaticMsgRule.rank , 
        msgdata = {
            int = {
                day = index
            }
        }
    }
    netSendPackage( sendData , callBack )
end
function UIAllianceMysteriesRank.init()
    local btn_close = ccui.Helper:seekNodeByName( UIAllianceMysteriesRank.Widget , "btn_close" )
    local btn_closed = ccui.Helper:seekNodeByName( UIAllianceMysteriesRank.Widget , "btn_closed" )
    local tab_button_zuo = ccui.Helper:seekNodeByName( UIAllianceMysteriesRank.Widget , "tab_button_zuo" )
    local tab_button_jin = ccui.Helper:seekNodeByName( UIAllianceMysteriesRank.Widget , "tab_button_jin" )
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_close or sender == btn_closed then
                UIManager.popScene()
            elseif sender == tab_button_zuo then
                if _tag == 1 then
                else
                    _tag = 1
                    refreshInfo()
                    netSendData()
                end
            elseif sender == tab_button_jin then
                if _tag == 2 then
                else
                    _tag = 2
                    refreshInfo()
                    netSendData()
                end
            end
        end
    end
    btn_close:setPressedActionEnabled( true )
    btn_close:addTouchEventListener( onEvent )
    btn_closed:setPressedActionEnabled( true )
    btn_closed:addTouchEventListener( onEvent )
   -- tab_button_zuo:setPressedActionEnabled( true )
    tab_button_zuo:addTouchEventListener( onEvent )
   -- tab_button_jin:setPressedActionEnabled( true )
    tab_button_jin:addTouchEventListener( onEvent )

    _scrollView = ccui.Helper:seekNodeByName( UIAllianceMysteriesRank.Widget , "view_info" )
    _item = _scrollView:getChildByName( "image_di_alliance" ):clone()
    _item:retain()
end
function UIAllianceMysteriesRank.setup( tag )
    if tag then
        _tag = tag
    else
        _tag = 2
    end
    refreshInfo()
    netSendData()
end
function UIAllianceMysteriesRank.free()
    _tag = nil
    _dataList = nil
end
